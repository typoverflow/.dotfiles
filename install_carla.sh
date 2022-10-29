set +x

source utils.sh

# only supports ubuntu
# TESTED_OS = ( "Ubuntu" )
# if [ ! "${TESTED_OS[@]}" =~ "$OS" ]; then
#     error "Only support installing carla on ${TESTED_OS[@]}"
#     exit 1
# fi

# --- check whether anaconda is installed
# if [ ! -d "$HOME/anaconda3" ]; then
#     error "Anaconda3 not found in $HOME/anaconda3. Please install anaconda3, activate the virtual env you wish to install carla in. "
#     exit 1
# fi

# --- check conda env
warn "Are you going to install in $(get_activated_conda) env? "
echo -n "(yes) > "
read
case $REPLY in
    [Nn]o )
        error "Abort. " && exit 1
        ;;
esac

# --- install pip dependencies
log "installing python dependencies ..."
pip install -r `pwd`/.carla/requirements.txt

# --- get binary
if [ ! -d "$HOME/.carla" ]; then
    mkdir -p "$HOME/.carla"
fi

# --- 