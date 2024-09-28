param(
    # Name to give the new user
    [string]$UserName = "liuxu",
    # Name to register as
    [string]$DistroName = "fc41",
    # Install Location
    [string]$InstallDirectory = "$HOME\AppData\Local\",
    # Fedora version to install
    [string]$Version = "41"
)

$arch = "x86_64"
$scriptDir = Split-Path $PSCommandPath

# Download Cloud Image
if (!(Test-Path "$scriptDir\Fedora-${Version}.tar")) {
    $items = Invoke-RestMethod -Uri https://api.github.com/repos/fedora-cloud/docker-brew-fedora/contents/${arch}?ref=${Version}
    foreach ($item in $items) {
        if ($item.name -match "^fedora.*\.tar$") {
            Invoke-WebRequest -Uri $item.download_url -OutFile "$scriptDir\Fedora-${Version}.tar" -ErrorAction Stop
        }
    }
}

# Make distro folder
if (!(Test-Path "$InstallDirectory\$DistroName")) {
    mkdir "$InstallDirectory\$DistroName"
}

# Import cloud image
wsl --import "$DistroName" "$InstallDirectory\$DistroName" "$scriptDir\Fedora-${Version}.tar"

wsl -d "$DistroName" -u root -e sed -i "/nodocs/d" /etc/dnf/dnf.conf

wsl -d "$DistroName" -u root -e bash -c @"
echo '[boot]
systemd=true' >> /etc/wsl.conf
"@

wsl -d "$DistroName" -u root -e bash -c @"
# disable update-testing repo
dnf config-manager setopt updates-testing.enabled=0
# update system
dnf update -y
# install system command
dnf install -y sudo ncurses dnf-plugins-core dnf-utils passwd findutils cracklib-dicts glibc-locale-source glibc-langpack-en which
# install dev tools
dnf install -y wget curl vim neovim git #tig nethogs
dnf install -y clang make cmake 
dnf install -y gnuplot 

# enable systemd
git clone https://github.com/scaryrawr/bottle-imp 
cd bottle-imp 
make internal-systemd
make internal-binfmt
cd ..
rm -rf bottle-imp

# read username from input or parameter
username=$UserName
if [ -z '$username' ]; then
    echo 'Please enter a new user name: '
    read username
fi

# add user
useradd -m -G adm,wheel,dialout,cdrom,floppy,audio,video $username
passwd $username

# Set default user as first non-root user
echo '[user]
default=$username' >> /etc/wsl.conf
"@

# configure neovim
wsl -d "$DistroName" -e bash -c @"
    cd ~
    git clone https://github.com/liuxu89/kickstart.nvim .config/nvim
    nvim +PlugInstall +qall
"@

# configure rust toolchain
wsl -d "$DistroName" -e bash -c @"
cd ~
echo 'export RUSTUP_UPDATE_ROOT=https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup' >> ~/.bashrc
echo 'export RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup' >> ~/.bashrc

mkdir .cargo
echo '[source.crates-io]
replace-with = "tsinghua"
[source.tsinghua]
registry = "sparse+https://mirrors.tuna.tsinghua.edu.cn/crates.io-index/"
EOF' >> .cargo/config

source .bashrc

curl -sSf https://sh.rustup.rs | sh -s -- -y
"@


# configure julia
wsl -d "$DistroName" -e bash -c @"
cd ~
echo 'export JULIAUP_SERVER=https://mirrors.ustc.edu.cn/julia-releases' >> ~/.bashrc
echo 'export JULIA_PKG_SERVER=https://mirrors.pku.edu.cn/julia' >> ~/.bashrc

source .bashrc

curl -fsSL https://install.julialang.org | sh -s -- -y
"@

# Terminate for launching with systemd support
wsl -t "${DistroName}"
