#!/usr/bin/env bash

# Replace Hooks with custom set of hooks
# This mainly just removes fsck & keyboard from hooks
echo "Removing fsck & keyboard hooks"
sudo sed -Ei 's/^HOOKS=".+"/HOOKS="base udev autodetect modconf block filesystems"/' /etc/mkinitcpio.conf

# Remove fallback preset from mkinitcpio
echo ""
sudo sed -i "s/^PRESETS=('default' 'fallback')/PRESETS=('default')/" /etc/mkinitcpio.d/linux.preset

# Rebuild mkinitcpio
sudo mkinitcpio -P
