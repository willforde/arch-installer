#!/usr/bin/env bash

# Minimal install
pacman -S --noconfirm --needed gnome-{shell,system-monitor,terminal}
pacman -S --noconfirm --needed --asdeps gnome-{control-center,keyring}

# Expanded install
pacman -S --noconfirm --needed gnome-{shell-extensions,backgrounds,calculator,screenshot,clocks,contacts,tweaks,user-docs}

# Apps
pacman -S --noconfirm --needed gparted baobab evince eog filezilla
pacman -S --noconfirm --needed --asdeps dosfstools exfat-utils ntfs-3g xfsprogs polkit gpart


#####################
## Display Manager ##
#####################

pacman -S --noconfirm --needed gdm


##################
## File Manager ##
##################

pacman -S --noconfirm --needed nautilus file-roller
pacman -S --noconfirm --needed --asdeps gvfs-google gvfs-goa gvfs-smb gvfs-nfs p7zip unrar


#####################
## Network Manager ##
#####################

pacman -S --noconfirm --needed networkmanager
