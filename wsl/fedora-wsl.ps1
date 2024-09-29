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
Write-Output $scriptDir

# Download Cloud Image
if (!(Test-Path "$scriptDir\Fedora-${Version}.tar")) {
    $items = Invoke-RestMethod -Uri https://api.github.com/repos/fedora-cloud/docker-brew-fedora/contents/${arch}?ref=${Version}
    foreach ($item in $items) {
        if ($item.name -match "^fedora.*\.tar$") {
            Write-Output $item.name
            Invoke-WebRequest -Uri $item.download_url -OutFile "$scriptDir\Fedora-${Version}.tar" -ErrorAction Stop
        }
    }
}
if (!(Test-Path "$scriptDir\Fedora-${Version}.tar")) { Write-Output "Can not download image !!"; exit }

# create distro folder
if (!(Test-Path "$InstallDirectory\$DistroName")) {
    mkdir "$InstallDirectory\$DistroName"
}

# Import cloud image
wsl --import "$DistroName" "$InstallDirectory\$DistroName" "$scriptDir\Fedora-${Version}.tar"

wsl -d "$DistroName" -u root -e sed -i "/nodocs/d" /etc/dnf/dnf.conf

wsl -d "$DistroName" -u root -e bash -c @"
# disable update-testing repo
mv /etc/yum.repos.d/fedora-updates-testing.repo /etc/yum.repos.d/fedora-updates-testing.repo.bak
# update system
echo 'dnf update -y'
dnf update -y > /dev/null 2>&1
# install system command
echo 'dnf install -y sudo ncurses passwd findutils cracklib-dicts glibc-locale-source glibc-langpack-en which dnf-utils dnf-plugins-core'
dnf install -y sudo ncurses passwd findutils cracklib-dicts glibc-locale-source glibc-langpack-en which dnf-utils dnf-plugins-core > /dev/null 2>&1
# install dev tools
echo 'dnf install -y wget curl neovim git gcc make procps-ng'
dnf install -y wget curl neovim git gcc make procps-ng > /dev/null 2>&1

# read username from input or parameter
username=$UserName
if [ -z '$username' ]; then
    echo 'Please enter a new user name: '
    read username
fi

# add user
echo ''
useradd -m -G adm,wheel,dialout,cdrom,floppy,audio,video $username
passwd $username

# Set default user as first non-root user
echo '[boot]
systemd=true
[user]
default=$username' >> /etc/wsl.conf
"@
wsl -t "${DistroName}"

# configure neovim
wsl -d "$DistroName" -e bash -c @"
    cd ~
    pwd
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

curl -sSf https://sh.rustup.rs | sh -s -- -y > /dev/null
"@


# configure julia
wsl -d "$DistroName" -e bash -c @"
cd ~
echo 'export JULIAUP_SERVER=https://mirrors.ustc.edu.cn/julia-releases' >> ~/.bashrc
echo 'export JULIA_PKG_SERVER=https://mirrors.pku.edu.cn/julia' >> ~/.bashrc

source .bashrc

curl -fsSL https://install.julialang.org | sh -s -- -y > /dev/null
"@

# Terminate for launching with systemd support
wsl -t "${DistroName}"
