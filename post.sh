#!/usr/bin/env bash
set -e
set -u

# Locale Settings
locale-gen
hwclock --systohc

echo "Optimizing Pacman Database"
pacman-key --populate archlinux
pacman-key --init

# Update mlocate database if installed
if [ -f "/usr/bin/updatedb" ]; then
    echo "Updating mlocate database"
	updatedb
fi

# Update pkgfile database if installed
if [ -f "/usr/bin/pkgfile" ]; then
    echo "Updating pkgfile database"
	pkgfile --update
fi

# Changeing Pacman Configuration to add colored output
sed -i 's/#Color/Color/' /etc/pacman.conf

# Create 'arch-release' if runing under vmware
if [ $(systemd-detect-virt) == "vmware" ]; then
    cat /proc/version > /etc/arch-release
fi

# Create important directorys
mkdir -p /root/.config/
mkdir -p /etc/skel/.config/


##########
## Bash ##
##########

# Ensure that extra bash functionality is installed
pacman -S --noconfirm --needed pkgfile
pacman -S --noconfirm --needed --asdeps bash-completion

# Ensure that pkgfile updater is enabled
systemctl enable pkgfile-update.timer

echo "Install custom bachrc"
install -vm 644 /opt/install-scripts/bash.bashrc /etc/bash.bashrc
install -vm 644 /opt/install-scripts/dotbashrc /etc/skel/.bashrc


##################
## Pacman Hooks ##
##################

# Create any missing directories
mkdir -p /etc/pacman.d/hooks

# Update rEFInd boot files on refind-efi
cat > /etc/pacman.d/hooks/refind.hook <<EOF
[Trigger]
Operation = Upgrade
Type = Package
Target = refind-efi

[Action]
Description = Updating rEFInd on ESP...
When=PostTransaction
Exec=/usr/bin/refind-install
EOF

# Keep currently installed & the last 2 cached
if [ -f "/usr/bin/paccache" ]; then
cat > /etc/pacman.d/hooks/paccache.hook <<EOF
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = *

[Action]
Description = Keep currently installed & the last 2 cached...
When = PostTransaction
Exec = /usr/bin/paccache -rv
EOF
fi


###############
## Reflector ##
###############

# Update pacman-mirrorlist on upgrade
if [ -f "/usr/bin/reflector" ]; then
cat > /etc/pacman.d/hooks/mirrorupgrade.hook <<EOF
[Trigger]
Operation = Upgrade
Type = Package
Target = pacman-mirrorlist

[Action]
Description = Updating pacman-mirrorlist with reflector...
When = PostTransaction
Depends = reflector
Exec = /bin/sh -c "reflector --country 'Ireland' --country 'United Kingdom' --latest 200 --age 24 --sort rate --save /etc/pacman.d/mirrorlist;  rm -f /etc/pacman.d/mirrorlist.pacnew"
EOF

cat > /etc/systemd/system/reflector.service <<EOF
[Unit]
Description=Pacman mirrorlist update
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/reflector --country 'Ireland' --country 'United Kingdom' --latest 200 --age 24 --sort rate --save /etc/pacman.d/mirrorlist

[Install]
RequiredBy=multi-user.target
EOF

cat > /etc/systemd/system/reflector.timer <<EOF
[Unit]
Description=Run reflector weekly

[Timer]
OnCalendar=Mon *-*-* 7:00:00
RandomizedDelaySec=15h
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Enable reflector timer
systemctl enable reflector.timer
fi


###################
## User Accounts ##
###################

ROOTPASSWORD=$1
USERNAME=$2
USERPASS=$3

echo "Changing Root password"
echo -e "${ROOTPASSWORD}\n${ROOTPASSWORD}" | passwd root

# Create user acount
useradd -m -G wheel,users -s /bin/bash ${USERNAME}
echo -e "${USERPASS}\n${USERPASS}" | passwd ${USERNAME}

# Change sudoers to allow wheel group access to sudo with password
echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/10_wheel
chmod 640 /etc/sudoers.d/10_wheel


################
## Aur Helper ##
################

sudo -u ${USERNAME} mkdir /tmp/build
cd /tmp/build/

sudo -u ${USERNAME} curl -SLO https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz
sudo -u ${USERNAME} tar -zxvf yay.tar.gz
cd yay
sudo -u ${USERNAME} makepkg -s -i --noconfirm
cd ../..
rm -rf build


##########
## Nano ##
##########

# Install syntax highlighting scripts
sudo -u ${USERNAME} yay -S --noconfirm nano-syntax-highlighting-git

# Make required directorys
mkdir -p /root/.config/nano /etc/skel/.config/nano
sudo -u ${USERNAME} mkdir -p /home/${USERNAME}/.config/nano/

# Enable Support for All Syntax Highlighters and custom settings
cat > /root/.config/nano/nanorc <<EOF
include "/usr/share/nano-syntax-highlighting/*.nanorc"
set nowrap
set boldtext
set linenumbers
set smooth
EOF

# Copy nanorc file to common places and change to requred ownership
cp -v /root/.config/nano/nanorc /etc/skel/.config/nano/nanorc
cp -v /root/.config/nano/nanorc /home/${USERNAME}/.config/nano/nanorc
chown ${USERNAME}:${USERNAME} /home/${USERNAME}/.config/nano/nanorc


#########
## ZSH ##
#########

# Install zsh core
pacman -S --noconfirm --needed zsh zsh-syntax-highlighting zsh-theme-powerlevel9k
pacman -S --noconfirm --needed --asdeps awesome-terminal-fonts # powerline-fonts

# Install 'powerline-fonts' from community repo after a new release, v2.7 or greater
sudo u ${USERNAME} yay -S --noconfirm oh-my-zsh-git nerd-fonts-complete powerline-fonts-git

# Add zsh-syntax-highlighting & powerlevel9K to oh-my-zsh
ln -s /usr/share/zsh/plugins/zsh-syntax-highlighting/ /usr/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting
ln -s /usr/share/zsh-theme-powerlevel9k /usr/share/oh-my-zsh/custom/themes/powerlevel9k

# Install all the zshrc files
install -vm 644 /opt/install-scripts/dotzshrc /etc/skel/.zshrc
install -vm 644 /opt/install-scripts/dotzshrc /root/.zshrc
install -vm 644 /opt/install-scripts/dotzshrc /home/${USERNAME}/.zshrc
chown ${USERNAME}:${USERNAME} /home/${USERNAME}/.zshrc


################
## Clean Boot ##
################

# Replace Hooks with custom set of hooks
# This mainly just removes fsck & keyboard from hooks
echo "Removing fsck hooks"
sed -Ei 's/^HOOKS=(.+)/HOOKS=(base udev autodetect modconf block filesystems)/' /etc/mkinitcpio.conf

# Remove fallback kernel images
echo "Removing fallback kernel images"
sed -i "s/^PRESETS=('default' 'fallback')/PRESETS=('default')/" /etc/mkinitcpio.d/linux.preset
rm -v /boot/initramfs-linux-fallback.img

# Rebuild mkinitcpio
mkinitcpio -P

# Copy over systemd fsck services
echo "Copying systemd-fsck services"
cp -v /usr/lib/systemd/system/systemd-fsck@.service /etc/systemd/system/systemd-fsck@.service
cp -v /usr/lib/systemd/system/systemd-fsck-root.service /etc/systemd/system/systemd-fsck-root.service

# Modify services to add StandardOutput and StandardError
echo "Modifing systemd-fsck services"
sed -i 's/TimeoutSec=0/StandardOutput=null\nStandardError=journal+console\nTimeoutSec=0/' /etc/systemd/system/systemd-fsck@.service
sed -i 's/TimeoutSec=0/StandardOutput=null\nStandardError=journal+console\nTimeoutSec=0/' /etc/systemd/system/systemd-fsck-root.service
