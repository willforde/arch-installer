#!/usr/bin/env bash
set -e
set -u


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

check_yay()
{
    # This script will only run when running as a normal user
    if [[ $EUID == 0 ]]; then
        echo "This script must be run as a normal user."
        exit 1
    fi

    # Install yay if missing
    if [[ ! -r "/usr/bin/yay" ]]; then
        # Create Build Directory
        mkdir /tmp/build
        cd /tmp/build/

        # Install Yay AUR Helper
        curl -SLO https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz
        tar -zxvf yay.tar.gz
        cd yay
        makepkg -s -i --noconfirm

        # Cleanup
        cd ../..
        rm -r build
    fi
}
