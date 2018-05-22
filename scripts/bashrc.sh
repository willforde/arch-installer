#!/usr/bin/env bash

# Transfor over .bashrc files for global and local users
echo "Install custom bachrc"
install -m 644 dotfiles/bash.bashrc /etc/bash.bashrc
install -m 644 dotfiles/.bashrc /etc/skel/.bashrc
