#!/usr/bin/env bash

# This script will only run when running as a normal user
if [[ $EUID == 0 ]]; then
    echo "This script must be run as a normal user."
    exit 1
fi

# Enable multilib repository
sudo sed -zi "s|#\[multilib\]\n#Include = /etc/pacman.d/mirrorlist|\[multilib\]\nInclude = /etc/pacman.d/mirrorlist|" /etc/pacman.conf
sudo pacman -Syy

# Generated en_US.UTF-8 locale, preventing invalid pointer error
sudo sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen


# Install 32bit variants of Nvidia driver if exists
if pacman -Qq nvidia-utils; then
    sudo pacman -S --noconfirm --needed --asdeps lib32-nvidia-utils
fi

# Install steam
sudo pacman -S --noconfirm --needed --asdeps ttf-liberation
sudo pacman -S --noconfirm --needed steam steam-native-runtime
