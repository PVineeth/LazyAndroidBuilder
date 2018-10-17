#!/bin/bash

# LazyAndroidBuilder v0.1
# Script For Building Android Oreo
# Author: Vineeth Penugonda
# License: GPL v3

#Print Software Version
echo -e "\nLazyAndroidBuilder v0.1\n"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

# store arguments in a special array 
args=("$@") 
# get number of elements 
ELEMENTS=${#args[@]}

# Global Var
SCRIPT_DIR=$( cd ${0%/*} && pwd -P )

# Functions

clean () {
    make clean && make clobber
}

changedir () {
    cd $DIRECTORYPATH
}

printVar () {
    echo "SCRIPT_DIR: $SCRIPT_DIR"
    echo "DIRECTORYPATH: $DIRECTORYPATH"
}

clrscr () {
    printf "\033c"
}

# FirstRun
if [ ! -f .firstrun.dat ]; then 
    echo "Enter the directory path to the source code and press [ENTER]:"
    echo "Example: /home/abc/Android/los_15.1/"
    read DIRECTORYPATH
    if [[ ! -z "$DIRECTORYPATH" ]]; then
        echo $DIRECTORYPATH > .firstrun.dat
    else 
        echo "Please enter the directory path to continue. It cannot be empty!"
    fi
else 
    DIRECTORYPATH=$(<.firstrun.dat)
    # Print Variable Values
    printVar
    printf '%*s\n\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
fi

# Change shell directory
cd $DIRECTORYPATH

# Globally Required
export ANDROID_JACK_VM_ARGS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx4G"
export LC_ALL=C
export ALLOW_MISSING_DEPENDENCIES=true
# export KBUILD_BUILD_USER=vineethp-linuxninja
# export KBUILD_BUILD_HOST=vineethp-linux-ninja

# echo each element in array  
# for loop 
for (( i=0;i<$ELEMENTS;i++)); do 
    # echo ${args[${i}]}

    if [[ ${args[${i}]} = "sync" ]]; then
        echo "Syncing Sources..."
        repo sync --force-sync
    fi
    
    if [[ ${args[${i}]} = "kernel" ]]; then
        clean
        source build/envsetup.sh
        lunch lineage_c90-userdebug
        make bootimage
    fi

    if [[ ${args[${i}]} = "rom" ]]; then
        clean
        source build/envsetup.sh
        croot
        brunch c90
    fi

    if [[ ${args[${i}]} = "erom" ]]; then
        clean
        source build/envsetup.sh
        croot
        brunch lineage_c90-eng
    fi

    if [[ ${args[${i}]} = "reset" ]]; then
        cd $SCRIPT_DIR
        rm -f ".firstrun.dat"
    fi

    if [[ ${args[$[i]]} = "help" ]]; then
        clrscr
        echo "LazyAndroidBuilder v0.1 - Help"
        echo "Author: Vineeth Penugonda"
        echo -e "\nCommands Available: sync, kernel, rom, erom\n\n(1) sync -  Useful for syncing the ROM source code\n(2) kernel - Builds the kernel\n(3) rom - Builds the ROM\n(4) erom - Builds the Engineering ROM."
    fi
done