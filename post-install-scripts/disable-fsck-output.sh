#!/bin/sh
set -e
set -u

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Remove fsck hook from mkinitcpio
echo "Removing fsck from mkinitcpio"
sed -i 's/ fsck//' /etc/mkinitcpio.conf

# Copy over systemd fsck services
echo "Copying systemd-fsck services"
cp /usr/lib/systemd/system/systemd-fsck@.service /etc/systemd/system/systemd-fsck@.service
cp /usr/lib/systemd/system/systemd-fsck-root.service /etc/systemd/system/systemd-fsck-root.service

# Modify services to add StandardOutput and StandardError
echo "Modifing systemd-fsck services"
sed -i 's/TimeoutSec=0/StandardOutput=null\nStandardError=journal+console\nTimeoutSec=0/' /etc/systemd/system/systemd-fsck@.service
sed -i 's/TimeoutSec=0/StandardOutput=null\nStandardError=journal+console\nTimeoutSec=0/' /etc/systemd/system/systemd-fsck-root.service

# Regenerate mkinitcpio linux images
echo "Recreating mkinitcpio linux"
mkinitcpio -p linux