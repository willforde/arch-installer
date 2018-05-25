#!/usr/bin/env bash
set -e
set -u

# This script will install zsh & oh-my-zsh to make configuring zsh easier
# Also adds a pre-configured .zshrc file for all users

# This script will only run when running as a normal user
if [[ $EUID == 0 ]]; then
    echo "This script must be run as a normal user."
    exit 1
fi

# Load common functions
source /opt/install-scripts/files/support.sh

# Install zsh & zsh extras
sudo pacman -S --noconfirm --needed zsh zsh-syntax-highlighting zsh-theme-powerlevel9k pkgfile
sudo pacman -S --noconfirm --needed --asdeps awesome-terminal-fonts
yay -S --noconfirm oh-my-zsh-git

# Enable pkgfile timer to update db
sudo systemctl enable pkgfile-update.timer

# Add zsh-syntax-highlighting & powerlevel9K to oh-my-zsh
if [[ ! -d "/usr/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]; then
    sudo ln -s /usr/share/zsh/plugins/zsh-syntax-highlighting/ /usr/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi

if [[ ! -d "/usr/share/oh-my-zsh/custom/themes/powerlevel9k" ]]; then
    sudo ln -s /usr/share/zsh-theme-powerlevel9k /usr/share/oh-my-zsh/custom/themes/powerlevel9k
fi

# Install all the zshrc files
sudo install -vm 644 /opt/install-scripts/files/dotzshrc /etc/skel/.zshrc
sudo install -vm 644 /opt/install-scripts/files/dotzshrc /root/.zshrc
cpToUsers /opt/install-scripts/files/dotzshrc .zshrc

# Change current users shell to ZSH
chsh -s /bin/zsh
echo "Please logout and login again for changes to take effect"
