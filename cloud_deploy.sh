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

    # Append environment setup commands to shell startup files if desired and using bash or zsh

    SHELL_NAME=`basename $SHELL`
    SHELLRC="$HOME/.${SHELL_NAME}rc"

    if [[ ($SHELL_NAME == "zsh") || ($SHELL_NAME == "bash") ]]; then

        read -p $'\e[1;34mAppend environment creation variables to shell setup file (.bashrc/.zshrc)? [Y/N]: \e[0m' APPEND

        if [[ ($APPEND == "Y") || ($APPEND == "y") ]]; then

            SHELL_APPEND='\n
            #### Appended by setup_conda.sh #### \n\n
            if [[ -e '"$ENV_PATH"'/bin ]]; then \n
            \t     export PATH='"$ENV_PATH"'/bin:$PATH \n
            \t     source activate '"$ENV_NAME"' \n
            fi \n'

            echo -e $SHELL_APPEND >> $SHELLRC
            echo -e $BLUE"Appended Conda environment setup commands to $SHELLRC"$NC

        else
            echo -e $BLUE"No changes were made to $SHELLRC"$NC
        fi
    fi

    # Jupyter's tokens are a pain when dealing with remote access and not really required
    # if SSH tunnels are used in a trusted environment

    read -p $'\e[1;34mSetup Jupyter config for remote access? [Y/N]: \e[0m' GENERATE_CONFIG

    if [[ ($GENERATE_CONFIG == "Y") || ($GENERATE_CONFIG == "y") ]]; then

        # Backup config file if one exists
        if [[ -e $HOME/.jupyter/jupyter_notebook_config.py ]]; then
            mv -f $HOME/.jupyter/jupyter_notebook_config.py     $HOME/.jupyter/jupyter_notebook_config_bkup.py
        fi

        # Create new config file
        jupyter notebook --generate-config -y

        # Fix settings for config file
        cat $HOME/.jupyter/jupyter_notebook_config.py \
        | sed "s/#c.NotebookApp.password = ''/c.NotebookApp.password = ''/g" \
        | sed "s/#c.NotebookApp.token = '<generated>'/c.NotebookApp.token = ''/g" \
        | sed "s/#c.NotebookApp.open_browser = True/c.NotebookApp.open_browser = False/g" \
        > $HOME/.jupyter/jupyter_notebook_config_new.py

        mv -f $HOME/.jupyter/jupyter_notebook_config_new.py $HOME/.jupyter/jupyter_notebook_config.py

        echo -e $BLUE"Jupyter configuration setup."$NC

    else
        echo -e $BLUE"No Jupyter config file generated."$NC
        echo -e $BLUE"A token from the command line may have to be entered when accessing notebook remotely."$NC
    fi

else
    echo -e $RED"There was an error creating the Conda environment."$NC
fi