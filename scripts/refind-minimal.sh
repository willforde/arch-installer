#!/usr/bin/env bash
set -e
set -u

# Download rEFInd-minimal theme and customize it
# Then configure rEFInd to use it
# https://github.com/anthon38/refind-black

# This script will only run when running as a root user
if [[ $EUID -ne 0 ]]; then
    echo "You need to be root to run this script."
    exit 1
fi

# Remove old refind-black directory if it already exists, this allows for updating
if [ -d "/boot/efi/EFI/refind/themes/rEFInd-minimal" ]; then
    echo "Removing old rEFInd-minimal..."
    rm -rf /boot/efi/EFI/refind/themes/rEFInd-minimal
else
    # Make sure that the themes directory exists
    mkdir -p /boot/efi/EFI/refind/themes/
fi

# Download a copy of the refind theme
echo "Downloading rEFInd-minimal..."
cd /boot/efi/EFI/refind/themes/
curl -SLO https://github.com/EvanPurkhiser/rEFInd-minimal/archive/master.tar.gz
tar zxf master.tar.gz
rm -f master.tar.gz
mv rEFInd-minimal-master rEFInd-minimal

# Cleanup
echo ""
rm -fv rEFInd-minimal/README.md
rm -fv rEFInd-minimal/theme.conf

# Create a slightly custom version of rEFInd-black theme.conf
echo "Creating custom theme.conf"
cat > rEFInd-minimal/theme.conf <<EOF
hideui singleuser,hints,arrows,label
icons_dir themes/rEFInd-minimal/icons
banner themes/rEFInd-minimal/background.png
selection_big   themes/rEFInd-minimal/selection_big.png
selection_small themes/rEFInd-minimal/selection_small.png
use_graphics_for osx,linux,windows
showtools
timeout 2
EOF

# Add include line to refind.conf if it don't exist, to enable this theme
if grep -Exq "include themes/rEFInd-\w+/theme.conf" ../refind.conf; then
    sed -Ei "s|include themes/rEFInd-\w+/theme.conf|include themes/rEFInd-minimal/theme.conf|" refind.conf
else
    echo 'include themes/rEFInd-minimal/theme.conf' >> ../refind.conf
fi
