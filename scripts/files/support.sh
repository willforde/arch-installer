#!/usr/bin/env bash

cpToUsers()
{
    # Copy one file to every users home directory
    # arg1 = Source file to copy
    # arg2 = Path source will be copied to, path is relitive to user directory

    for user in $(cat /etc/passwd | grep "/home/" | grep -E "/bin/bash|/bin/zsh" | awk -F ":" '{print $1}'); do
        dest="/home/$user/$2"
        DIR=$(dirname "${dest}")
        if [ ! -d ${DIR} ]; then
            sudo mkdir -p ${DIR}
            sudo chown 700 ${DIR}
            sudo chown ${user}:${user} ${DIR}
        fi
        sudo install -vm 644 $1 ${dest}
        sudo chown ${user}:${user} ${dest}
    done
}

chkShell()
{
    cat /etc/passwd | grep $1 | awk -F ':' '{print $7}'
}

removefallback()
{
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
        sudo rm -v /boot/initramfs-linux-fallback.img
    fi

    if [ -f "/boot/initramfs-linux-lts-fallback.img" ]; then
        sudo rm -v /boot/initramfs-linux-lts-fallback.img
    fi
}
