#!/usr/bin/env bash
set -e
set -u

echo "This will enable trim support"
echo "Only enable trim when you know for sure that your storage device supports trim"

read -p "Continue (y/n)?" yn
case ${yn} in
    [Yy]* ) sudo systemctl enable fstrim.timer;;
    [Nn]* ) exit;;
    * ) exit;;
esac
