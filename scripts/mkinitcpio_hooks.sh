#!/usr/bin/env bash

# Replace Hooks with custom set of hooks
# This mainly just removes fsck & keyboard from hooks
echo "Removing fsck hooks"
sudo sed -E 's/^HOOKS=(.+)/HOOKS=(base udev autodetect modconf block filesystems keyboard)/' /etc/mkinitcpio.conf
echo ""

# Remove fallback preset from linux mkinitcpio
if [ -f "/etc/mkinitcpio.d/linux.preset" ]; then
    sudo sed -i "s/^PRESETS=('default' 'fallback')/PRESETS=('default')/" /etc/mkinitcpio.d/linux.preset
fi

# Remove fallback preset from lts mkinitcpio
if [ -f "/etc/mkinitcpio.d/linux-lts.preset" ]; then
    sudo sed -i "s/^PRESETS=('default' 'fallback')/PRESETS=('default')/" /etc/mkinitcpio.d/linux-lts.preset
fi

# Remove old fallback files
if [ -f "/boot/initramfs-linux-fallback.img" ]; then
    rm -v /boot/initramfs-linux-fallback.img
fi

if [ -f "/boot/initramfs-linux-lts-fallback.img" ]; then
    rm -v /boot/initramfs-linux-lts-fallback.img
fi

# Rebuild mkinitcpio
sudo mkinitcpio -P
