#!/bin/sh
set -e
set -u

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Install the LTS Kernel
pacman -S linux-lts linux-lts-headers

# Remove current linux Kernel
pacman -R linux

# Recreate linux boot images
mkinitcpio -p linux-lts

# Update grub boot menu
grub-mkconfig -o /boot/grub/grub.cfg