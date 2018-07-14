#!/usr/bin/env bash
set -e
set -u

files=$(dirname $0)/files
source ${files}/support.sh

if [ "$#" == 1 ]; then
    if [ "$1" == "linux" ]; then
        sudo pacman -S --noconfirm --needed linux linux-headers
        echo "Setting refind to load lts kernel"
        sudo sed -i 's|initrd=/boot/initramfs-linux-lts.img|initrd=/boot/initramfs-linux.img|' /boot/refind_linux.conf

        # Remove linux lts if exists
        if [ -f "/boot/vmlinuz-linux-lts" ]; then
            sudo pacman -R --noconfirm linux-lts linux-lts-headers
            if [ -f "/etc/mkinitcpio.d/linux-lts.preset.pacsave" ]; then
                sudo rm -v /etc/mkinitcpio.d/linux-lts.preset.pacsave
            fi
        fi

        # Remove fallback kernel images
        removefallback

    elif [ "$1" == "lts" ]; then
        sudo pacman -S --noconfirm --needed linux-lts linux-lts-headers
        echo "Setting refind to load lts kernel"
        sudo sed -i 's|initrd=/boot/initramfs-linux.img|initrd=/boot/initramfs-linux-lts.img|' /boot/refind_linux.conf

        # Remove linux lts if exists
        if [ -f "/boot/vmlinuz-linux" ]; then
            sudo pacman -R --noconfirm linux linux-headers
            if [ -f "/etc/mkinitcpio.d/linux.preset.pacsave" ]; then
                sudo rm -v /etc/mkinitcpio.d/linux.preset.pacsave
            fi
        fi

        # Remove fallback kernel images
        removefallback

    else
        echo "Unknown kernel type specified, options are: linux, lts"
    fi
else
    echo "Please specify kernel type, options are: linux, lts"
fi
