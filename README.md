# \<dot\>Dotfiles
This repo contains (nearly) all of the dot files which I need to configure my coding environment. To quickly reconstruct the environments and deploy these dot files, scripts are also included in this repo. 

<div align="center"><img src="https://gist.githubusercontent.com/typoverflow/3f2d6daa0f0b6eb33934238dc1c025e7/raw/ea1787c5ddb83142ad688a5d4ab360fc809ab903/it-works-on-my-machine.jpg" width=200></div>

## Installation
1. clone this repo with --recursive option.
    ```bash
    git clone --recurse-submodules git@github.com:typoverflow/.dotfiles.git
    ```

2. run the script inside the repo.
    ```bash
    bash install_zsh.sh   # install zsh, oh-my-zsh, plugins and themes
    bash install_tmux.sh  # install tmux and theme
    ```

## Contents
### Jupyter Lab
Install Jupyter Lab within on command, simply `bash isntall_jupyter.sh` and enter your password. 
+ compatable with
  + [x] Ubuntu
  + [ ] MacOS

### mujoco
```bash
bash install_mujoco200.sh
bash install_mujoco210,sh
```

### Zsh, Oh-My-Zsh
<div align=center><img src=img/zsh.png width=400></div>

+ Compatable with
  + [x] Ubuntu
  + [x] ArchLinux
  + [ ] MacOS

### **Tmux**

<div align=center><img src=img/tmux.png width=400></div>

+ Compatable with 
  + [x] Ubuntu, Arch Linux
  + [ ] MacOS

This part is inspired by [Johnny4Fun](https://github.com/Johnny4Fun/.tmux).

## ToDos
Have a look at [ToDos](./TODO.md) and help to improve!
