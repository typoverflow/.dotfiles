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

# --- install jupyter lab and its dependencies
log "Installing JupyterLab and its dependencies. Note that jupyter lab will be installed in base env, and you need to conda install ipykernel for other envs you need to show in your lab."
pip3 install jupyterlab nodejs npm
conda activate base && conda install nb_conda_kernels ipykernel

jupyter lab --generate-config

log "Setting passwd for jupyter lab ..."
passwd=`python -c "from jupyter_server.auth import passwd; print(passwd())"`
echo "
c.ServerApp.open_browser = False
c.ServerApp.password = '$passwd'
c.ServerApp.port = 8889
c.ServerApp.allow_remote_access = True
c.ServerApp.ip = '0.0.0.0'
" >> ~/.jupyter/jupyter_lab_config.py

succ "JupyterLab installed. Port 8889 will be used."