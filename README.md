# \<dot\>Dotfiles
This repo contains (nearly) all of the dot files which I need to configure my coding environment. To quickly reconstruct the environments and deploy these dot files, scripts are also included in this repo. 

## Installation
1. clone this repo with --recursive option.
    ```bash
    git clone --recurse-submodules https://github.com/typoverflow/.dotfiles.git
    ```

2. run the script inside the repo.
    ```bash
    bash install_zsh.sh   # install zsh, oh-my-zsh, plugins and themes
    bash install_tmux.sh  # install tmux and theme
    ```

## Contents
### Zsh, Oh-My-Zsh
<div align=center><img src=img/zsh.png width=400></div>

+ NOT TESTED on
  + [ ] Ubuntu, Arch Linux, MacOS

### **Tmux**

<div align=center><img src=img/tmux.png width=400></div>

+ OK on
  + [x] Ubuntu, Arch Linux
+ NOT TESTED on
  + [ ] MacOS

This part is inspired by [Johnny4Fun](https://github.com/Johnny4Fun/.tmux).

## ToDos
Have a look at [ToDos](./TODO.md) and help to improve!
