set +x

source utils.sh

TESTED_OS=( "Ubuntu" )
if [[ ! "${TESTED_OS[@]}" =~ "$OS" ]]; then
    error "Only support installing JupyterLab on ${TESTED_OS[@]}"
    exit 1
fi

# --- check whether anaconda is installed.
if [ ! -d "$HOME/anaconda3" ]; then
    error "Anaconda3 not found in $HOME/anaconda3. Please install anaconda3, and then activate to the virtual env you wish to install jupyter lab in. "
    exit 1
fi

# --- check install or add kernel
warn "Install kernel or add new envs to existing kernel? "
echo -n "(i for installing, a for adding) >>> "
read
case $REPLY in
    [aA] )
        log "Adding new kernel ..."
        op="add"
        ;;
    [iI] )
        log "Installing jupyter lab ..."
        op="install"
        ;;
esac

# --- check conda env
conda_act_env=$(get_activated_conda)
warn "Operate in ${conda_act_env} env ?"
echo -n "(yes/no) >>> "
read
case $REPLY in 
    [Nn]o )
        error "Abort. " && exit 1
        ;;
esac

# --- install jupyter lab and its dependencies
case $op in
    add )
        log "Adding ${conda_act_env} to jupyter kernels"
        conda install nb_conda_kernels ipykernel ipywidgets
        python -m ipykernel install --user --name $conda_act_env
        ;;
    install )
        log "Installing jupyter lab in ${conda_act_env}"
        pip3 install jupyterlab nodejs npm
        conda install nb_conda_kernels ipykernel ipywidgets
        jupyter lab --generate-config
        log "Setting passwd for jupyter lab ..."
        passwd=`python -c "from jupyter_server.auth import passwd; print(passwd())"`
        log "specify a port number for jupyter lab to use:"
        echo -n ">>> "
        read
        echo "
        c.ServerApp.open_browser = False
        c.ServerApp.password = '$passwd'
        c.ServerApp.port = ${REPLY}
        c.ServerApp.allow_remote_access = True
        c.ServerApp.ip = '0.0.0.0'
        " >> ~/.jupyter/jupyter_lab_config.py
        ;;
esac

succ "All tasks done."