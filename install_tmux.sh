set +x

source utils.sh

# --- install tmux
try_install /usr/bin/tmux tmux gawk sed perl

# --- install configurations

log "configuring tmux from ./.tmux ..."

ln -s -f `pwd`/.tmux/.tmux.conf ~/.tmux.conf
cp `pwd`/.tmux/.tmux.conf.local ~/.tmux.conf.local

succ "Tmux installed and configured."
