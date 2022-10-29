set +x

source utils.sh

CARLA_ROOT="$HOME/.carla"

declare -a VERSIONS
VERSIONS=(  
    # "0.8.2" "0.8.3" "0.8.4" 
    # "0.9.0" "0.9.1" "0.9.2" "0.9.3" "0.9.4" 
    # "0.9.5" "0.9.6" "0.9.7" "0.9.8" "0.9.9"
    # "0.9.10" 
    # "0.9.11" 
    "0.9.12" "0.9.13"
)

declare -A binary_link
binary_link=(
    ["0.8.2"]="https://drive.google.com/open?id=1ZtVt1AqdyGxgyTm69nzuwrOYoPUn_Dsm"
    ["0.8.3"]="https://drive.google.com/open?id=1L8SfwGOGUsDF12orO-WYGc5CaArjgLyS"
    ["0.8.4"]="https://drive.google.com/open?id=18OaDbQ2K9Dcs25d-nIxpw3GPRHhG1r_2"
    ["0.9.0"]="https://drive.google.com/open?id=1JprRbFf6UlvpqX98hQiUG9U4W_E-keiv"
    ["0.9.1"]="https://drive.google.com/open?id=1FNZ9js4NBw1faZTts-dpGa1sRAKh0G0j"
    ["0.9.2"]="https://drive.google.com/open?id=1Wt2cxXCtWI3cSI4rt3_HjGnVfkK8Z9bl"
    ["0.9.3"]="https://drive.google.com/open?id=1sFf8WnsSVsLhVzXnB2CMdM8LiWoZDE0c"
    ["0.9.4"]="https://drive.google.com/open?id=1p5qdXU4hVS2k5BOYSlEm7v7_ez3Et9bP"
    ["0.9.5"]="http://carla-assets-internal.s3.amazonaws.com/Releases/Linux/CARLA_0.9.5.tar.gz"
    ["0.9.6"]="http://carla-assets-internal.s3.amazonaws.com/Releases/Linux/CARLA_0.9.6.tar.gz"
    ["0.9.7"]="http://carla-assets-internal.s3.amazonaws.com/Releases/Linux/Dev/CARLA_0.9.7.4.tar.gz"
    ["0.9.8"]="https://carla-releases.s3.eu-west-3.amazonaws.com/Linux/CARLA_0.9.8.tar.gz"
    ["0.9.9"]="https://carla-releases.s3.eu-west-3.amazonaws.com/Linux/CARLA_0.9.9.4.tar.gz"
    ["0.9.10"]="https://carla-releases.s3.eu-west-3.amazonaws.com/Linux/CARLA_0.9.10.tar.gz"
    ["0.9.11"]="https://carla-releases.s3.eu-west-3.amazonaws.com/Linux/CARLA_0.9.11.tar.gz"
    ["0.9.12"]="https://carla-releases.s3.eu-west-3.amazonaws.com/Linux/CARLA_0.9.12.tar.gz"
    ["0.9.13"]="https://carla-releases.s3.eu-west-3.amazonaws.com/Linux/CARLA_0.9.13.tar.gz"
)

declare -A map_link
map_link=(
    ["0.9.12"]="https://carla-releases.s3.eu-west-3.amazonaws.com/Linux/AdditionalMaps_0.9.12.tar.gz"
    ["0.9.13"]="https://carla-releases.s3.eu-west-3.amazonaws.com/Linux/AdditionalMaps_0.9.13.tar.gz"
)

# only supports ubuntu
TESTED_OS=( "Ubuntu" )
if [[ ! "${TESTED_OS[@]}" =~ "$OS" ]]; then
    error "Only support installing carla on ${TESTED_OS[@]}"
    exit 1
fi

# --- check whether anaconda is installed
if [ ! -d "$HOME/anaconda3" ]; then
    error "Anaconda3 not found in $HOME/anaconda3. Please install anaconda3, activate the virtual env you wish to install carla in. "
    exit 1
fi

# --- check conda env
warn "Are you going to install in $(get_activated_conda) env? "
echo -n "(yes/no, default yes) > "
read
case $REPLY in
    [Nn]o )
        error "Abort. " && exit 1
        ;;
esac

# --- install pip dependencies
log "installing python dependencies ..."
pip install -r `pwd`/.carla/requirements.txt

# --- install
if [ ! -d "$HOME/.carla" ]; then
    mkdir -p "$HOME/.carla"
fi

warn "which version of carla to install? options: ${VERSIONS[@]}, default ${VERSIONS[-1]}"
warn "(note that mixing different versions of carla can lead to undefined behaviors, please uninstall a pre-installed version if necessary.)"
echo -n ">>> "
read
select_version=$REPLY
if [[ ! ${VERSIONS[@]} =~ $select_version ]]; then
    error "version ${select_version} not available, aborting."
    exit 1
fi

# for 0.9.12 0.9.13
install1(){
    local version=$1
    if [ -d $CARLA_ROOT/$version ]; then
        error "directory $CARLA_ROOT/$version not empty, aborting."
        exit 1
    else
        mkdir -p $CARLA_ROOT/$version
    fi

    log "downloading version $version, which may take several minutes ..."
    wget -O "$CARLA_ROOT/$version/CARLA_$version.tar.gz" ${binary_link[$version]}
    if [ ! -f "$CARLA_ROOT/$version/CARLA_$version.tar.gz" ]; then
        error "cala binary zip not found. aborting."
    else
        log "installing from $CARLA_ROOT/$version/CARLA_$version.tar.gz ..."
        tar -zxvf "$CARLA_ROOT/$version/CARLA_$version.tar.gz" -C $CARLA_ROOT/$version/
        rm "$CARLA_ROOT/$version/CARLA_$version.tar.gz"
        pip3 install $CARLA_ROOT/$version/PythonAPI/carla/dist/*cp37*.whl
    fi

    warn "install additional maps?"
    echo -n "(yes/no, default no) >>> "
    read
    case $REPLY in 
        [yY]es )
            log "downloading additional maps ..."
            wget -O "$CARLA_ROOT/$version/Import/AdditionalMaps_$version.tar.gz" ${map_link[$version]}
            log "installing maps ..."
            pushd $CARLA_ROOT/$version && ./ImportAssets.sh
            popd
            ;;
    esac
    succ "All tasks done."
}

declare -A install_fn_registry=(
    ["0.9.12"]=install1
    ["0.9.13"]=install1
)

eval ${install_fn_registry[$select_version]} "$select_version"
