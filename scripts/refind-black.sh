#!/usr/bin/env bash
set -e
set -u

# Download rEFInd-black theme and customize it
# Then configure rEFInd to use it
# https://github.com/anthon38/refind-black

# This script will only run when running as a root user
if [[ $EUID -ne 0 ]]; then
    echo "You need to be root to run this script."
    exit 1
fi

# Remove old refind-black directory if it already exists, this allows for updating
if [ -d "/boot/efi/EFI/refind/themes/rEFInd-black" ]; then
    echo "Removing old rEFInd-black..."
    rm -rf /boot/efi/EFI/refind/themes/rEFInd-black
else
    # Make sure that the themes directory exists
    mkdir -p /boot/efi/EFI/refind/themes/
fi

# Download a copy of the refind theme
echo "Downloading rEFInd-black..."
cd /boot/efi/EFI/refind/themes/
curl -SLO https://github.com/anthon38/refind-black/archive/master.tar.gz
tar zxf master.tar.gz
rm -f master.tar.gz
mv refind-black-master rEFInd-black

# Cleanup
echo ""
rm -fv rEFInd-black/README.md
rm -fv rEFInd-black/theme.conf

# Create a slightly custom version of rEFInd-black theme.conf
echo "Creating custom theme.conf"
cat > rEFInd-black/theme.conf <<EOF
hideui singleuser,hints,arrows,label
icons_dir themes/rEFInd-black/icons
banner themes/rEFInd-black/background.png
selection_big   themes/rEFInd-black/selection_big.png
selection_small themes/rEFInd-black/selection_small.png
use_graphics_for osx,linux,windows
showtools
timeout 2
EOF

# Add include line to refind.conf if it don't exist, to enable this theme
if grep -Exq "include themes/rEFInd-\w+/theme.conf" ../refind.conf; then
    sed -Ei "s|include themes/rEFInd-\w+/theme.conf|include themes/rEFInd-black/theme.conf|" ../refind.conf
else
    echo 'include themes/rEFInd-black/theme.conf' >> ../refind.conf
fi
