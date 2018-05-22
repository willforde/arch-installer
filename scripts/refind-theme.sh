#!/usr/bin/env bash

if [ -d "/boot/efi/EFI/refind" ]; then
    mkdir -p /boot/efi/EFI/refind/themes/
    git clone https://github.com/EvanPurkhiser/rEFInd-minimal.git /boot/efi/EFI/refind/themes/rEFInd-minimal
    echo 'include themes/rEFInd-minimal/theme.conf' >> /boot/efi/EFI/refind/refind.conf
fi
