set +x

source utils.sh

# --- install zsh

try_install /bin/zsh zsh


# --- install oh my zsh

cd ${HOME} && sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

if [ $? -ne 0 ]; then
    error "Oh my zsh installation failed."
    exit 1
else
    log "Oh my zsh installation succeeded."

# --- install autojump

try_install /usr/bin/autojump autojump

# --- install zsh suggestions

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
if [ $? -ne 0 ]; then
    error "Zsh-autosuggestions installation failed."
    exit 1
else
    log "Zsh-autosuggestions installation succeeded."
fi

# --- install chainy zsh theme
scp `pwd`/.zsh/chainy-zsh-theme/chainy.zsh-theme ${HOME}/.oh-my-zsh/themes/

# --- change shell
chsh -s /bin/zsh