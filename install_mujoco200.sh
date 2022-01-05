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

# --- Download key
log "Downloading mjkey.txt ..."
wget -O https://roboti.us/file/mjkey.txt "$MUJOCO_ROOT/mjkey.txt"

# --- Download mujoco200
log "Downloading mujoco200 ..."
wget -O https://www.roboti.us/download/mujoco200_linux.zip "$MUJOCO_ROOT/mujoco200_linux.zip"
unzip $MUJOCO_ROOT/mujoco200_linux.zip -d $MUJOCO_ROOT && rm $MUJOCO_ROOT/mujoco200_linux.zip
ln -s $MUJOCO_ROOT/mujoco200_linux $MUJOCO_ROOT/mujoco200

# --- Add environment variables
log "Adding environment variables to .zshrc ..."
if [[ ! $LD_LIBRARY_PATH =~ .*"/usr/lib/nvidia".* ]]; then
    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/nvidia' >> ${HOME}/.zshrc
fi
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:'"$MUJOCO_ROOT"'/mujoco200/bin' >> ${HOME}/.zshrc
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:'"$MUJOCO_ROOT"'/mujoco200_linux/bin' >> ${HOME}/.zshrc

succ "Mujoco200 installed, but you still need to install mujoco_py-2.0 to get it work."