set +x

source utils.sh

TESTED_OS=( "Ubuntu" )
if [[ ! "${TESTED_OS[@]}" =~ "$OS" ]]; then
    error "Only support installing jupyter lab and its kernels on ${TESTED_OS[@]}"
    exit 1
fi

if [ -z $1 ]; then
    error "You must specify a env name to install the ipykernel."
    exit 1
fi

all_envs=$(ls `conda info | grep "envs directories" | awk '{print $4}'`)
all_envs="base "$all_envs
if [[ ! ${all_envs} =~ $1 ]]; then
    error "Cannot find target env: {$1}. Existing envs include: ${all_envs}."
    exit 1
fi

conda activate $1 && conda install nb_conda_kernels ipykernel ipywidgets
python -m ipykernel install --user --name $1
succ "Successfully installed kernel for ${1}."