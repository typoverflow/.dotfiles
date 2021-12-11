set +x

source utils.sh

# --- install zsh

try_install /bin/zsh zsh


# --- install oh my zsh

if [ ! -e "${HOME}/.oh-my-zsh" ]; then
    log "oh-my-zsh not found, installing..."
    unset ZSH && bash `pwd`/.zsh/ohmyzsh_install_script.sh 

    if [ $? -ne 0 ]; then
        error "Oh my zsh installation failed."
        exit 1
    else
        log "Oh my zsh installation succeeded."
    fi
fi

# --- install autojump

try_install /usr/bin/autojump autojump

# --- install zsh suggestions

if [ ! -e "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    log "zsh-autosuggestions not found, installing..."
    git clone git@github.com:zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    
    if [ $? -ne 0 ]; then
        error "Zsh-autosuggestions installation failed."
        exit 1
    else
        log "Zsh-autosuggestions installation succeeded."
    fi
fi

# --- install chainy zsh theme
scp `pwd`/.zsh/.zshrc ${HOME}/
scp `pwd`/.zsh/chainy-zsh-theme/chainy.zsh-theme ${HOME}/.oh-my-zsh/themes/

# --- change shell
chsh -s /bin/zsh

succ "Zsh installed and configured."