#!/bin/bash
# This script determines the package manager based on the Linux distribution and installs necessary packages using the package manager.
# It then executes a setup script called "setup.zsh" using the Zsh shell.

# Declare an associative array to map Linux distribution release files to package managers
declare -A osInfo;
osInfo[/etc/redhat-release]=yum
osInfo[/etc/arch-release]=pacman
osInfo[/etc/gentoo-release]=emerge
osInfo[/etc/SuSE-release]=zypp
osInfo[/etc/debian_version]=apt-get
osInfo[/etc/alpine-release]=apk
if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! which -s brew ; then
        # Install Homebrew
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    export system_pakman="brew"
    # brew does not need sudo
    export sudo=""
    # brew does not have a -y flag
    export args="-q"
else
    # use sudo on linux
    export sudo="sudo"
    # add install args
    export args="-qy"
fi

# Iterate over the keys of the osInfo array
for f in "${!osInfo[@]}"
do
    if [[ -f $f ]];then
        echo "Package manager:" "${osInfo[$f]}"
        export system_pakman=${osInfo[$f]}
    fi
done

# Use the package manager to install necessary packages
$sudo "$system_pakman" install git pkg-config gcc curl zsh $args

# Execute the rest of the setup script using the Zsh shell
zsh ./setup.zsh "$system_pakman" "$args" "$sudo"
