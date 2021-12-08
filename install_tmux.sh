set +x

source utils.sh

# --- install tmux

if [ ! -e /usr/bin/tmux ]; then
    log "Tmux not found, installing tmux and dependencies..."
    if [ "$OS" = "Arch Linux" ]; then
        sudo pacman -S tmux awk sed perl
    elif [ "$OS" = "Ubuntu" ]; then
        sudo apt-get install tmux awk sed perl
    elif [ "$OS" = "Darwin" ]; then
        brew install tmux awk sed perl
    fi
else
    log "Tmux found in /usr/bin/tmux, installing dependencies ..."
    if [ "$OS" = "Arch Linux" ]; then
        sudo pacman -S awk sed perl
    elif [ "$OS" = "Ubuntu" ]; then
        sudo apt-get install awk sed perl
    elif [ "$OS" = "Darwin" ]; then
        brew install awk sed perl
    fi
fi

if [ $? -ne 0 ]; then
    error "Tmux installation failed."
    exit 1
fi

# --- install configurations

log "configuring tmux from ./.tmux ..."

ln -s -f `pwd`/.tmux/.tmux.conf ~/.tmux.conf
cp `pwd`/.tmux/.tmux.conf.local ~/.tmux.conf.local

succ "Tmux installed and configured."




# sudo apt-get install tmux
# cd
# ln -s -f ./.tmux/.tmux.conf ~/.tmux.conf
# cp ./.tmux/.tmux.conf.local ~/

