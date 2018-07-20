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

# Copy over systemd fsck services
echo "Copying systemd-fsck services"
sudo cp /usr/lib/systemd/system/systemd-fsck@.service /etc/systemd/system/systemd-fsck@.service
sudo cp /usr/lib/systemd/system/systemd-fsck-root.service /etc/systemd/system/systemd-fsck-root.service

# Modify services to add StandardOutput and StandardError
echo "Modifing systemd-fsck services"
sudo sed -i 's/TimeoutSec=0/StandardOutput=null\nStandardError=journal+console\nTimeoutSec=0/' /etc/systemd/system/systemd-fsck@.service
sudo sed -i 's/TimeoutSec=0/StandardOutput=null\nStandardError=journal+console\nTimeoutSec=0/' /etc/systemd/system/systemd-fsck-root.service
