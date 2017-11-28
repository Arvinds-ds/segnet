#!/usr/bin/env bash


environment_name=$1



################# USER SET VARIABLES #####################

# Set environment path
# $HOME can be used for a shortcut to your home directory
ENV_PATH="$HOME/miniconda"
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
# Set environment name
# NOTE: there's not an easy way to determine if an existing environment
# has the same name. Conda itself will throw an error during installation
# of second environment.
ENV_NAME="$environment_name"
PYTHON_VER=3.6

# Set packages to be installed (do not list python itself)
# be sure to name/spell them exactly as Conda does or installation will fail
PACKAGES="numpy scipy jupyter matplotlib Pillow scikit-learn"

################# USER SET VARIABLES ABOVE THIS LINE #####################

# BASH prompt colors
BLUE='\033[1;34m'
RED='\033[1;31m'
NC='\033[0m'

# get python major version (2 or 3)
PYTHON_BASE_VER=`echo $PYTHON_VER | cut -d'.' -f1`

echo -e $BLUE"Using Python $PYTHON_VER."$NC

if [[ -e $ENV_PATH ]]; then

    if [[ ! -e $ENV_PATH/bin/conda ]]; then

        # the destination directory does not seem to contain a Conda installation
        # don't want to risk overwriting files, so time to bail...

        echo -e $RED"There doesn't appear to be a Conda installation at $ENV_PATH."$NC
        echo -e $RED"Quitting without installing anything."$NC

        exit 0

    fi

elif [[ ! -e $ENV_PATH ]]; then

    echo -e $BLUE"Conda does not seem to be installed at $ENV_PATH. Installing now."$NC

    # set Linux/Darwin url
    if [[ `uname` == "Darwin" ]]; then
        echo -e $BLUE"Detected Mac OS X."$NC
        OS_VER="MacOSX"
        exit 0
    else
        echo -e $BLUE"Detected Linux."$NC
        OS_VER="Linux"
   fi

    URL="https://repo.continuum.io/miniconda/Miniconda${PYTHON_BASE_VER}-latest-${OS_VER}-x86_64.sh"

    # set install script name
    SCRIPT_NAME="miniconda.sh"

    # download the installation script
    echo -e $BLUE"Downloading Conda installation script."$NC

    if [[ -e $SCRIPT_NAME ]]; then
        rm $SCRIPT_NAME
    fi

    curl -s -o $SCRIPT_NAME $URL

    # create temporary conda installation
    echo -e $BLUE"Creating Conda installation at $ENV_PATH."$NC

    if [[ -e $ENV_PATH ]]; then
        rm -rf $ENV_PATH
    fi

    bash $SCRIPT_NAME -b -f -p $ENV_PATH >> /dev/null

    rm $SCRIPT_NAME

else

    # setup path and create environment
    echo -e $BLUE"Conda seems to be installed already. Skipping installation."$NC

fi

# Setup the environment

if [[ `uname` == "Darwin" ]]; then
    echo -e $BLUE"Detected Mac OS X. Cannot install tensorflow Serving"$NC
    OS_VER="MacOSX"
else
    echo -e $BLUE"Detected Linux."$NC
    OS_VER="Linux"
fi

unset PYTHONHOME
unset PYTHONPATH

export PATH=$ENV_PATH:$PATH

echo -e $BLUE"Python environment will be based on version $PYTHON_VER"$NC

PACKAGES="python=$PYTHON_VER $PACKAGES"

#$ENV_PATH/bin/conda create --quiet -y -n $ENV_NAME $PACKAGES >> /dev/null
$ENV_PATH/bin/conda create -y -n $ENV_NAME $PACKAGES
$ENV_PATH/envs/$ENV_NAME/bin/pip install tensorflow-gpu
$ENV_PATH/envs/$ENV_NAME/bin/pip install edward


if [[ $?==0 ]]; then
    echo -e $BLUE"Finished creating Conda environment. Any errors directly above regarding psutil or \"command not found\" can probably be ignored."$NC

else
    echo -e $RED"There was an error creating the Conda environment."$NC
fi