if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    ...
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi

error(){
    >&2 echo -e "\033[31;1m[Error]\033[0m "$@;
}

succ(){
    >&1 echo -e "\033[32;1m[Success]\033[0m "$@
}

warn(){
    >&1 echo -e "\033[33;1m[Warning]\033[0m "$@
}

log(){
    >&1 echo -e "\033[34;1m[Log]\033[0m "$@
}

try_install(){
    if [ ! -e $1 ]; then 
        log "${@:2} not found, installing ${@:2} ..."
        if [ "$OS" = "Arch Linux" ]; then
            sudo pacman -S ${@:2}
        elif [ "$OS" = "Ubuntu" ]; then
            sudo apt-get install -y ${@:2}
        elif [ "$OS" = "Darwin" ]; then
            brew install ${@:2}
        else
            error "Unsupported OS: $OS"
            exit 1
        fi

        if [ $? -ne 0 ]; then
            error "${@:2} installation failed."
            exit 1
        else
            log "${@:2} installation succeeded."
        fi
    else
        log "found ${@:2} in $1."
    fi
}

get_activated_conda(){
    cmd='conda info | grep "active environment" | awk '"'{print \$4}'"
    eval $cmd
}
