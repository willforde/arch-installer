#!/usr/bin/env bash
set -e
set -u

# Load common functions
files=$(dirname $0)/files
source ${files}/support.sh
check_yay

if [[ ! -d "/usr/share/nano-syntax-highlighting" ]]; then
    yay -S --noconfirm nano-syntax-highlighting-git
fi

# Enable Support for All Highlighters and Disable text wraping
sudo mkdir -p /root/.config/nano /etc/skel/.config/nano
echo 'include "/usr/share/nano-syntax-highlighting/*.nanorc"' | sudo tee /root/.config/nano/nanorc >/dev/null
echo 'set nowrap' | sudo tee -a /root/.config/nano/nanorc >/dev/null
echo 'set autoindent' | sudo tee -a /root/.config/nano/nanorc >/dev/null
echo 'set boldtext' | sudo tee -a /root/.config/nano/nanorc >/dev/null
echo 'set linenumbers' | sudo tee -a /root/.config/nano/nanorc >/dev/null
echo 'set smooth' | sudo tee -a /root/.config/nano/nanorc >/dev/null
sudo cp /root/.config/nano/nanorc /etc/skel/.config/nano/nanorc

cpToUsers /root/.config/nano/nanorc .config/nano/nanorc
