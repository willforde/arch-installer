#!/usr/bin/env bash
set -e
set -u

files=$(dirname $0)/files
source ${files}/support.sh

# Replace Hooks with custom set of hooks
# This mainly just removes fsck & keyboard from hooks
echo "Removing fsck hooks"
sudo sed -Ei 's/^HOOKS=(.+)/HOOKS=(base udev autodetect modconf block filesystems)/' /etc/mkinitcpio.conf
echo ""

# Remove fallback kernel images
removefallback

# Rebuild mkinitcpio
sudo mkinitcpio -P
