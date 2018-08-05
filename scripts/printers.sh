#!/usr/bin/env bash

# This will install the drivers for the following printer and much more. see (http://foo2zjs.rkkda.com/)
# Hp laserjet m1005 MFP

files=$(dirname $0)/files
source ${files}/support.sh
check_yay

# This install's HP laserjet Pinter drivers
yay -S --noconfirm foo2zjs-nightly
yay -c --noconfirm

# Start & enable to cups damon
sudo systemctl start org.cups.cupsd.service
sudo systemctl enable org.cups.cupsd.socket
