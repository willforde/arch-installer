#!/usr/bin/env bash
set -e
set -u

sudo pacman -S --noconfirm --needed mpv
DECODER='vaapi'

# Check GPU the system is using
if [[ -n $(lspci | grep -i "VGA compatible controller: NVIDIA Corporation") ]]; then
    sudo pacman -S --noconfirm --needed nvidia libva-vdpau-driver
    DECODER='vdpau'
fi

if [[ -n $(lspci | grep -i "VGA compatible controller: Intel Corporation") ]]; then
    sudo pacman -S --noconfirm --needed libva-intel-driver libvdpau-va-gl
fi

cat > /tmp/mpv.conf <<EOF
profile=opengl-hq
hwdec=${DECODER}
audio-channels=6
border=no
sid=no
EOF
sudo mv /tmp/mpv.conf /etc/mpv/mpv.conf
sudo chown root:root /etc/mpv/mpv.conf
