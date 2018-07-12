#!/usr/bin/env bash

# Replace Hooks with custom set of hooks
# This mainly just removes fsck & keyboard from hooks
echo "Removing fsck & keyboard hooks"
sudo sed -E 's/^HOOKS=(.+)/HOOKS=(base udev autodetect modconf block filesystems)/' /etc/mkinitcpio.conf
echo ""

# Remove fallback preset from linux mkinitcpio
if [ -f "/etc/mkinitcpio.d/linux.preset" ]; then
    sudo sed -i "s/^PRESETS=('default' 'fallback')/PRESETS=('default')/" /etc/mkinitcpio.d/linux.preset
fi

# Remove fallback preset from lts mkinitcpio
if [ -f "/etc/mkinitcpio.d/linux-lts.preset" ]; then
    sudo sed -i "s/^PRESETS=('default' 'fallback')/PRESETS=('default')/" /etc/mkinitcpio.d/linux-lts.preset
fi

# Rebuild mkinitcpio
sudo mkinitcpio -P
