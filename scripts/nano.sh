#!/usr/bin/env bash

mkdir -p /root/.config/nano /etc/skel/.config/nano
yay -S --noconfirm nano-syntax-highlighting-git

# Enable Support for All Highlighters and Disable text wraping
echo 'include "/usr/share/nano-syntax-highlighting/*.nanorc"' >> /root/.config/nano/nanorc
echo 'set nowrap' >> /root/.config/nano/nanorc
cp /root/.config/nano/nanorc /etc/skel/.config/nano/nanorc

# Replace VI with nano as the default text editor
echo 'VISUAL=nano' >> /etc/environment
echo 'EDITOR=nano' >> /etc/environment
