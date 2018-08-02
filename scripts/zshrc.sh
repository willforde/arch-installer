#!/usr/bin/env bash
set -e
set -u

# This script will install zsh & oh-my-zsh to make configuring zsh easier
# Also adds a pre-configured .zshrc file for all users

# Load common functions
files=$(dirname $0)/files
source ${files}/support.sh
check_yay

# Install zsh & zsh extras
sudo pacman -S --noconfirm --needed zsh zsh-syntax-highlighting zsh-theme-powerlevel9k pkgfile
sudo pacman -S --noconfirm --needed --asdeps awesome-terminal-fonts
if [[ ! -d "/usr/share/oh-my-zsh" ]]; then
    yay -S --noconfirm oh-my-zsh-git
fi

if [[ ! -d "/usr/share/fonts/nerd-fonts-complete" ]]; then
    yay -S --noconfirm nerd-fonts-complete
fi

# Install 'powerline-fonts' from community repo after a new release, v2.7 or greater
if [[ ! -d "/usr/share/licenses/powerline" ]]; then
    yay -S --noconfirm --asdeps powerline-fonts-git
fi

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
sudo install -vm 644 ${files}/dotzshrc /etc/skel/.zshrc
sudo install -vm 644 ${files}/dotzshrc /root/.zshrc
cpToUsers ${files}/dotzshrc .zshrc

# Change current users shell to ZSH
if [ ! $(chkShell "${USER}") == "/bin/zsh" ]; then
    chsh -s /bin/zsh
    echo "Please logout and login again for changes to take effect"
fi
