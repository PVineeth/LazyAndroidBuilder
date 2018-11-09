#!/bin/bash

# LazyAndroidBuilder v0.2
# Script For Building Android Oreo
# Author: Vineeth Penugonda
# License: AGPL v3

# Print Software Version
echo -e "\nLazyAndroidBuilder v0.2"
echo -e "Author: Vineeth Penugonda\n"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

# store arguments in a special array 
args=("$@") 
# get number of elements 
ELEMENTS=${#args[@]}

# Global Var
SCRIPT_DIR=$( cd ${0%/*} && pwd -P )

# Colors
red=$'\e[1;31m' # Errors
mag=$'\e[1;35m' # Success
end=$'\e[0m'

# Functions

clean () {
    make clean && make clobber
}

changedir () {
    # Change shell directory
    cd $DIRECTORYPATH
}

printVar () {
    echo "SCRIPT_DIR: $SCRIPT_DIR"
    echo "DIRECTORYPATH: $DIRECTORYPATH"
    echo "DEVICE_NAME: $DEVICE_NAME"
}

clrscr () {
    printf "\033c"
}

set_env() {
# Globally Required
export ANDROID_JACK_VM_ARGS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx4G"
export LC_ALL=C
export ALLOW_MISSING_DEPENDENCIES=true
export KBUILD_BUILD_USER=vineethp-linuxninja
export KBUILD_BUILD_HOST=vineethp-linux-ninja
}

device_name() {
if [ ! -f .devicename.dat ]; then
    echo "Enter device codename (usually 'ro.product.device' in build.prop):"
    read DEVICE_NAME
    if [[ ! -z "$DEVICE_NAME" ]]; then
        echo $DEVICE_NAME > .devicename.dat
    else 
        echo "Please enter the device codename to continue. It cannot be empty!"
    fi
else
    DEVICE_NAME=$(<.devicename.dat)
fi
}

first_run() {
# FirstRun
if [ ! -f .firstrun.dat ]; then 
    echo "Enter the directory path to the source code and press [ENTER]:"
    echo "Example: /home/abc/Android/los_15.1/"
    read DIRECTORYPATH
    if [[ ! -z "$DIRECTORYPATH" ]]; then
        echo $DIRECTORYPATH > .firstrun.dat
        device_name
    else 
        echo "Please enter the directory path to continue. It cannot be empty!"
    fi
else 
    DIRECTORYPATH=$(<.firstrun.dat)
    device_name
    # Print Variable Values
    printVar
    printf '%*s\n\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
fi
}

reset() {
    if [[ -f .firstrun.dat || -f .devicename.dat ]]; then
        cd $SCRIPT_DIR
        rm -f ".firstrun.dat"
        rm -f ".devicename.dat"
        clrscr
        printf "%s\n" "${mag}Done resetting the script!${end}"
        exit 0 # 0 = successfully
    else 
        clrscr
        printf "%s\n" "${red}The LazyAndroidBuilder did not even run once. No use of resetting now.${end}"
        exit 1 # 1 = unsuccessfully
    fi
}

update_script(){
    rm -rf .tmp_labscript.sh
    echo "LazyAndroidBuilder Updater"
    cd $SCRIPT_DIR
    wget --output-document=.tmp_labscript.sh -q https://raw.githubusercontent.com/PVineeth/LazyAndroidBuilder/master/build.sh
    cp .tmp_labscript.sh build.sh
    rm -rf .tmp_labscript.sh
    printf '%*s\n\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
    printf "%s\n" "${mag}Done Updating!${end}"
    echo -e "\nRun the script again."
    printf '%*s\n\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
    # Sets permission automatically
    chmod a+x build.sh
}

help() {
        clrscr
        echo "LazyAndroidBuilder v0.2 - Help"
        echo "Author: Vineeth Penugonda"
        echo -e "\nCommands Available: sync, kernel, rom, erom. reset, clean\n\n(1) sync -  Useful for syncing the ROM source code\n(2) kernel - Builds the kernel\n(3) rom - Builds the ROM\n(4) erom - Builds the Engineering ROM.\n(5) reset - Resets the build script.\n(6) clean - Cleans the build directory. Same as 'make clean && make clobber'."
}

main() {
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
        lunch lineage_$DEVICE_NAME-userdebug
        make bootimage
    fi

    if [[ ${args[${i}]} = "rom" ]]; then
        clean
        source build/envsetup.sh
        croot
        brunch $DEVICE_NAME
    fi

    if [[ ${args[${i}]} = "erom" ]]; then
        clean
        source build/envsetup.sh
        croot
        brunch lineage_$DEVICE_NAME-eng
    fi

    if [[ ${args[${i}]} = "reset" ]]; then
        reset
    fi

    if [[ ${args[${i}]} = "clean" ]]; then
        clean
    fi

    if [[ ${args[${i}]} = "update" ]]; then
        if [[ $ELEMENTS -ne 1 ]]; then
            update_script
        fi
    fi

    if [[ ${args[${i}]} = "help" ]]; then
        help
    fi
done
}

# Execution starts here

if [[ $1 = "help" ]]; then
    help
elif [[ $1 = "reset" ]]; then
    reset
elif [[ $1 = "update" ]]; then
    update_script
else
    first_run
fi

changedir
set_env
main