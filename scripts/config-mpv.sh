#!/usr/bin/env bash
set -e
set -u

sudo pacman -S --noconfirm --needed mpv
DECODER='vaapi'

# Check GPU the system is using
if pacman -Qq nvidia-utils; then
    sudo pacman -S --noconfirm --needed --asdeps libva-vdpau-driver
    DECODER='vdpau'

elif [[ -n $(lspci | grep -i "VGA compatible controller: Intel Corporation") ]]; then
    sudo pacman -S --noconfirm --needed --asdeps libva-intel-driver
    sudo pacman -S --noconfirm --needed libvdpau-va-gl # This really need to be a depenancy of libva-intel-driver
fi

echo "Writing out mpv configuration"
cat > /tmp/mpv.conf <<EOF
profile=opengl-hq
hwdec=${DECODER}
audio-channels=6
border=no
sid=no
EOF

sudo mv /tmp/mpv.conf /etc/mpv/mpv.conf
sudo chown root:root /etc/mpv/mpv.conf
