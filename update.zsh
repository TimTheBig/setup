set -ex

# Declare an associative array to map Linux distribution release files to package managers
declare -A osInfo;
osInfo[/etc/redhat-release]=yum
osInfo[/etc/arch-release]=pacman
osInfo[/etc/gentoo-release]=emerge
osInfo[/etc/SuSE-release]=zypp
osInfo[/etc/debian_version]=apt-get
osInfo[/etc/alpine-release]=apk
if [[ "$OSTYPE" == "darwin"* ]]; then
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

$sudo "$system_pakman" update $args && $sudo "$system_pakman" upgrade $args

# dotfiles
cd $HOME/.dotfiles || echo "~/.dotfiles not found" && exit
tuckr rm \*
if [[ "$system_pakman" == "brew" ]]; then
    tuckr add \* -e zsh_linux
else
    tuckr add \* -e zsh_macos
fi

# rust
cargo install-update --all
