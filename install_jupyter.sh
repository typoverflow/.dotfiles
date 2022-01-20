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
log "Installing JupyterLab and its dependencies ..."
pip3 install jupyterlab nodejs npm

log "Setting password ..."
jupyter lab password

jupyter lab --generate-config && mv .jupyter/jupyter_lab_config.py ~/.jupyter/jupyter_lab_config.py

succ "JupyterLab installed. Listening port at 8889."
nohup jupyter lab $HOME &