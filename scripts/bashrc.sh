#!/usr/bin/env bash
set -e
set -u

files=$(dirname $0)/files
source ${files}/support.sh

# Ensure that extra bash functionality is installed
sudo pacman -S --noconfirm --needed pkgfile
sudo pacman -S --noconfirm --needed --asdeps bash-completion

echo "Install custom bachrc"
sudo install -vm 644 ${files}/bash.bashrc /etc/bash.bashrc
sudo install -vm 644 ${files}/dotbashrc /etc/skel/.bashrc

# Install localized .bashrc for normal users
if [[ $EUID -ne 0 ]]; then
    install -vm 644 ${files}/dotbashrc ~/.bashrc
fi

# Change current users shell to Bash
if [ ! $(chkShell "${USER}") == "/bin/bash" ]; then
    chsh -s /bin/bash
    echo "Please logout and login again for changes to take effect"
fi
