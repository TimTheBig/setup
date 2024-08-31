# shellcheck enable=add-default-case
# shellcheck source=../setup.zsh

# *take args from setup.sh
# system package manager
export system_pakman=$1
# add install args
export args=$2
# use sudo on linux
export sudo=$3


echo Installing programming languages
$sudo $system_pakman install rustup lua python3 zig make $args
# Tell the user the names of the languages they can install
echo "Optional languages: nodejs(js), openjdk(java), golang(go), perl"
echo "skip all or choose which ones you want [skip/pick]"
read -r choice
if [[ "$choice" == "skip" ]]; then
    echo "Skipping optional languages"
else
    echo "install nodejs(js)? [y/n]"
    read -r node
    if [["$node" == "y"]]; then
        $sudo $system_pakman install nodejs $args
    fi

    echo "install openjdk(java)? [y/n]"
    read -r java
    if [["$java" == "y"]]; then
        $sudo $system_pakman install openjdk $args
    fi

    echo "install golang(go)? [y/n]"
    read -r go
    if [["$go" == "y"]]; then
        $sudo $system_pakman install golang $args
    fi

    echo "install perl? [y/n]"
    read -r perl
    if [["$perl" == "y"]]; then
        $sudo $system_pakman install perl $args
    fi
fi

# echo "you old? [y/n]"
# read -r old
# if [[$old == "y"]]; then
#     $sudo $system_pakman install pascal fortran $args
# fi

echo Installing alacritty
$sudo $system_pakman install font-jetbrains-mono-nerd-font font-fira-code font-fira-code-nerd-font alacritty fastfetch $args
echo Installing editers
$sudo $system_pakman install vscodium nvim $args
# install vscode extensions
codium --install-extension "rust-lang.rust-analyzer"
codium --install-extension "serayuzgur.crates"
codium --install-extension "usernamehw.errorlens"
codium --install-extension "tamasfe.even-better-toml"

# install flatpak if on linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo skiping flatpak
else
    $sudo $system_pakman install flatpak $args
fi

# install gaming stuff on linux and only steam on mac
echo "Are you gaming on this system? [y/n]"
read -r answer
if [[ "$answer" == "y"|"Y" ]]; then
    echo Installing gaming stuff
    if [[ "$OSTYPE" == "darwin"* ]]; then
        $sudo $system_pakman install steam $args
    else
        $sudo $system_pakman install steam protonup-qt gamescope $args
    fi
fi

# rust stuff
rustup-init $args
cargo install sccache -q
# add sccache to cargo config
echo Adding sccache to cargo config
echo '[build]' >> ~/.cargo/config.toml
echo 'rustc-wrapper = "~/.cargo/bin/sccache"' >> ~/.cargo/config.toml

# cli tools
echo Installing cli tools
$sudo $system_pakman install eza bat ripgrep zoxide $args

# ask if user wants to install with cargo bin-install or from source
echo "Cargo bin-install(saves time) or install(from source)? [bin/standard(default)]"
read -r answer
if [[ "$answer" == "bin" ]]; then
    cargo install cargo-binstall -q
    cargo binstall trunk cargo-audit cargo-info cargo-machete cargo-msrv cargo-tarpaulin cargo-update wasm-bindgen-cli sqlx-cli cargo-feature-manager -q
else
    cargo install trunk cargo-audit cargo-info cargo-machete cargo-msrv cargo-tarpaulin cargo-update wasm-bindgen-cli sqlx-cli cargo-feature-manager -q
fi
# install tuckr
cargo install --git 'https://github.com/RaphGL/Tuckr.git'

# zsh plugins
echo Installing zsh plugins
$sudo $system_pakman install zsh-syntax-highlighting zsh-autosuggestions $args

# clone dotfiles
echo Cloning dotfiles
cd $HOME
git clone https://github.com/big-tim-the-big/dotfiles-good.git '.dotfiles' -q --progress --branch 'tuckr'

# simlinking dotfiles
echo Simlinking dotfiles
if [[ "$system_pakman" == "brew" ]]; then
    tuckr add \* -e zsh_linux
else
    tuckr add \* -e zsh_macos
fi

# change default shell to zsh
echo Making zsh the default shell
chsh $USER --shell /bin/zsh

source ~/.zshrc

# open alacritty and run fastfetch in it.
alacritty --hold -e fastfetch

# termanate current shell
sleep 3
exit
