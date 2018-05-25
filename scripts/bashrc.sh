#!/usr/bin/env bash
set -e
set -u

# This script will only run when running as a normal user
if [[ $EUID == 0 ]]; then
    echo "This script must be run as a normal user."
    exit 1
fi

# Load common functions
source /opt/install-scripts/files/support.sh

# Ensure that extra bash functionality is installed
sudo pacman -S --noconfirm --needed pkgfile
sudo pacman -S --noconfirm --needed --asdeps bash-completion

echo "Install custom bachrc"
sudo install -vm 644 /opt/install-scripts/files/bash.bashrc /etc/bash.bashrc
sudo install -vm 644 /opt/install-scripts/files/dotbashrc /etc/skel/.bashrc
cpToUsers /opt/install-scripts/files/dotbashrc .bashrc

# Change current users shell to Bash
chsh -s /bin/bash
echo "Please logout and login again for changes to take effect"
