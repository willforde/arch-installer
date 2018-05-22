#!/usr/bin/env bash

pacman -S --noconfirm zsh zsh-syntax-highlighting zsh-theme-powerlevel9k
pacman -S --noconfirm  --asdeps awesome-terminal-fonts
yay -S --noconfirm oh-my-zsh-git


# Add zsh-syntax-highlighting Plugin to oh-my-zsh
ln -s /usr/share/zsh/plugins/zsh-syntax-highlighting/ /usr/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Add powerlevel9K Theme to oh-my-zsh
ln -s /usr/share/zsh-theme-powerlevel9k /usr/share/oh-my-zsh/custom/themes/powerlevel9k

install -m 644 dotfiles/.zshrc /etc/skel/.zshrc
