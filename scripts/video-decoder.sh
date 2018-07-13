#!/usr/bin/env bash
set -e
set -u

# Check if system is using a nvidia VGA device and if so, mark nvidia driver for install
if [[ -n $(lspci | grep -i "VGA compatible controller: NVIDIA Corporation") ]]; then
    sudo pacman -S --noconfirm --needed nvidia libva-vdpau-driver

elif [[ -n $(lspci | grep -i "VGA compatible controller: Intel Corporation") ]]; then
    sudo pacman -S --noconfirm --needed libva-intel-driver libvdpau-va-gl
else
    echo "No Video decoding hardware found"
fi
