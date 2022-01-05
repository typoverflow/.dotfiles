set +x

source utils.sh

MUJOCO_ROOT="${HOME}/.mujoco"

# only supports ubuntu
if [ ! $OS == "Ubuntu" ]; then
    error "Only support installing mujoco on Ubuntu."
    exit 1
fi

if [ ! -d $MUJOCO_ROOT ]; then
    mkdir -p $MUJOCO_ROOT
fi

# --- Install dependencies
sudo apt-get install patchelf

# --- Download mujoco210
log "Downloading mujoco210 ..."
scp `pwd`/.mujoco/mujoco210-linux-x86_64.tar.gz $MUJOCO_ROOT/
tar -xzvf "$MUJOCO_ROOT/mujoco210-linux-x86_64.tar.gz" -C $MUJOCO_ROOT/
ln -s $MUJOCO_ROOT/mujoco210 $MUJOCO_ROOT/mujoco210_linux

# --- Add environment variables
log "Adding environment variables to .zshrc ..."
if [[ ! $LD_LIBRARY_PATH =~ .*"/usr/lib/nvidia".* ]]; then
    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/nvidia' >> ${HOME}/.zshrc
fi
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:'"$MUJOCO_ROOT"'/mujoco210/bin' >> ${HOME}/.zshrc
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:'"$MUJOCO_ROOT"'/mujoco210_linux/bin' >> ${HOME}/.zshrc

succ "Mujoco210 installed, but you still need to install mujoco_py-2.1 to get it work."