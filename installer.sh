#!/bin/sh
set -e
set -u
clear

##############
## Packages ##
##############

# Constents
VARTARGETDIR="/mnt"
DEVICE="/dev/sda"
KEYMAP="uk"

# DAEMON Services
DAEMONS="sshd.socket"

# Software Packages
EXTRAPKG="base base-devel openssh memtest86+ wget"
OPTIONALDEP="bash-completion"

# Required
# base				= Base linux system packages group						= https://www.archlinux.org/groups/x86_64/base/
# base-devel		= Base packages to compile packages from aur			= https://www.archlinux.org/groups/x86_64/base-devel/
# openssh			= Free version of the SSH connectivity tools			= https://www.archlinux.org/packages/core/x86_64/openssh/
# memtest86+		= An advanced memory diagnostic tool					= https://www.archlinux.org/packages/extra/any/memtest86+/
# wget				= A network utility to retrieve files from the Web		= https://www.archlinux.org/packages/extra/x86_64/wget/

# Optional
# bash-completion	= Programmable completion for the bash shell			= https://www.archlinux.org/packages/extra/any/bash-completion/


#############
## Methods ##
#############

requestPackages()
{
	dialog --title "Extra Packages" --checklist "Please Select Packages:" 15 55 5 1 "nfs-utils" off 2 "reflector" on 3 "mlocate" on 4 "pkgfile" on 5 "archey3" on 2>/tmp/menuitem
	for pkg in $(cat /tmp/menuitem); do
		if [ "$pkg" = 1 ]; then
			EXTRAPKG="$EXTRAPKG nfs-utils"
			DAEMONS="$DAEMONS rpcbind.service nfs-client.target remote-fs.target"
			
			# Extra Packages
			# nfs-utils				= Support programs for Network File Systems		= https://www.archlinux.org/packages/core/x86_64/nfs-utils/
			
			# Extra Services
			# rpcbind.service		= Network File System (NFS) daemon
			# nfs-client.target		= Network File System (NFS) daemon
		
		elif [ "$pkg" = 2 ]; then
			EXTRAPKG="$EXTRAPKG reflector"
			OPTIONALDEP=" $OPTIONALDEP rsync"
			
			# Extra Packages
			# reflector		= Retrieve and filter the latest Pacman mirror list		= https://www.archlinux.org/packages/community/any/reflector/
			# rsync 		= A file transfer program to keep remote files in sync	= https://www.archlinux.org/packages/extra/x86_64/rsync/
		
		elif [ "$pkg" = 3 ]; then
			EXTRAPKG="$EXTRAPKG mlocate"
			
			# Extra Packages
			# mlocate	= Merging locate/updatedb implementation	= https://www.archlinux.org/packages/core/x86_64/mlocate/
		
		elif [ "$pkg" = 4 ]; then
			EXTRAPKG="$EXTRAPKG pkgfile"
			DAEMONS="$DAEMONS pkgfile-update.timer"
			
			# Extra Packages
			# pkgfile	= A pacman files metadata explorer		= https://www.archlinux.org/packages/extra/x86_64/pkgfile/
		
		elif [ "$pkg" = 5 ]; then
			EXTRAPKG="$EXTRAPKG archey3"
			
			# Extra Packages
			# archey3	= Output a logo and various system information		= https://www.archlinux.org/packages/community/any/archey3/
		fi
	done
}

requestHostname()
{
	HOSTNM=""
	while [ "$HOSTNM" = "" ]
	do
		dialog --title "Hostname" --backtitle "Hostname" --inputbox "Please enter hostname:" 8 50 2>/tmp/menuitem
		HOSTNM=$(cat /tmp/menuitem)
	done
	echo ""
}

requestRootPassword()
{
	ROOTPASSWORD=""
	while [ "$ROOTPASSWORD" = "" ]
	do
		dialog --title "Root Password" --backtitle "Root Password" --inputbox "Please enter Root Password:" 8 50 2>/tmp/menuitem
		ROOTPASSWORD=$(cat /tmp/menuitem)
	done
	echo ""
}

requestUser()
{
	USERNAME=""
	while [ "$USERNAME" = "" ]
	do
		dialog --title "Username" --backtitle "Username" --inputbox "Please enter Username:" 8 50 2>/tmp/menuitem
		USERNAME=$(cat /tmp/menuitem)
		requestPassword
	done
	echo ""
}

requestPassword()
{
	USERPASS=""
	while [ "$USERPASS" = "" ]
	do
		dialog --title "Password" --backtitle "Password" --inputbox "Please enter Password:" 8 50 2>/tmp/menuitem
		USERPASS=$(cat /tmp/menuitem)
	done
	echo ""
}


#####################
# Pre Configuration #
#####################

echo "Syncing clocks"
timedatectl set-ntp true
hwclock --systohc --utc

echo "Loading Uk Keyboard Layout"
loadkeys uk

echo "Setting Locale to en_IE"
sed -i 's/^en_US.UTF-8/#en_US.UTF-8/' /etc/locale.gen
sed -i 's/^#en_IE.UTF-8/en_IE.UTF-8/' /etc/locale.gen
echo "LANG=en_IE.UTF-8" > /etc/locale.conf
export LANG=en_IE.UTF-8
locale-gen
echo ""

# Check if runing inside a virtuabox VM and if so, mark virtuabox-guest for install
if [[ -n $(lspci | grep -i "vmware pci express") ]]; then
	EXTRAPKG="$EXTRAPKG open-vm-tools"
	# open-vm-tools		= open-vm-tools are the open source implementation of VMware Tools		= https://www.archlinux.org/packages/community/x86_64/open-vm-tools/
fi

# Check if runing inside a virtuabox VM and if so, mark virtuabox-guest for install
if [[ -n $(lspci | grep -i "virtualbox") ]]; then
	EXTRAPKG="$EXTRAPKG virtualbox-guest-utils"
	# virtualbox-guest-utils	= VirtualBox Guest userspace utilities			= https://www.archlinux.org/packages/community/x86_64/virtualbox-guest-utils/
fi

# Check if system has a Audio device and if so, mark alsa-utils for install
if [[ -n $(lspci | grep -i "Multimedia audio controller:") ]] || [[ -n $(lspci | grep -i "Audio device:") ]]; then
	EXTRAPKG="$EXTRAPKG alsa-utils"
	# alsa-utils				= An implementation of Linux sound support		= https://www.archlinux.org/packages/extra/x86_64/alsa-utils/
fi

# Check if system is using a intel VGA device and if so, mark intel drivers for install
if [[ -n $(lspci | grep -i "VGA compatible controller: Intel Corporation") ]]; then
	EXTRAPKG="$EXTRAPKG xf86-video-intel mesa-libgl libva-intel-driver"
	# xf86-video-intel			= Xorg intel video drivers						= https://www.archlinux.org/packages/extra/i686/xf86-video-intel/
	# mesa-libgl				= Mesa 3-D graphics library						= https://www.archlinux.org/packages/extra/i686/mesa-libgl/
	# libva-intel-driver		= VA-API implementation for intel HD Graphics	= https://www.archlinux.org/packages/extra/x86_64/libva-intel-driver/
fi

# Check if system is using a nvidia VGA device and if so, mark nvidia driver for install
if [[ -n $(lspci | grep -i "VGA compatible controller: NVIDIA Corporation") ]]; then
	EXTRAPKG="$EXTRAPKG libvdpau"
	if [[ -n $(lspci | grep -i "GeForce 9400") ]] || [[ -n $(lspci | grep -i "GT218") ]]; then
		EXTRAPKG="$EXTRAPKG nvidia-340xx nvidia-340xx-libgl"
	else
		EXTRAPKG="$EXTRAPKG nvidia nvidia-libgl"
	fi
	# nvidia					= NVIDIA drivers for linux						= https://www.archlinux.org/packages/extra/x86_64/nvidia/
	# nvidia-utils				= NVIDIA drivers utilities						= https://www.archlinux.org/packages/extra/i686/nvidia-utils/
	# nvidia-libgl				= NVIDIA drivers libraries symlinks				= https://www.archlinux.org/packages/extra/x86_64/nvidia-libgl/
fi

# Check if system is using an intel CPU and if so, mark intel-ucode for install
if [[ -n $(cat /proc/cpuinfo | grep -i "GenuineIntel") ]]; then
	EXTRAPKG="$EXTRAPKG intel-ucode"
	# intel-ucode				= Microcode update files for Intel CPUs			= https://www.archlinux.org/packages/extra/any/intel-ucode/
fi

# Ask what hostname to use
requestHostname

# Ask for Root Password
requestRootPassword

# Ask for user acount info
requestUser

# Display list of extra packages that can be installed
requestPackages

# Install Required Packages if needed
echo "Downloading and Install reflector installation requirements"
pacman -Sy --noconfirm --needed reflector

# Download and sort Mirrors List from Archlinux.org
echo "Downloading and Ranking mirrors"
reflector --verbose --protocol http --latest 200 --number 20 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syy


##################
## Partitioning ##
##################

# Formating Disks
echo "# Wriping Drive"
sgdisk -Z $DEVICE
sgdisk -a 2048 -o $DEVICE

# Install bootloader requirements
EXTRAPKG="$EXTRAPKG grub"
OPTIONALDEP="$OPTIONALDEP os-prober"

# Check witch Bootloader to prepaire for
if [ -d "/sys/firmware/efi/" ]; then
	echo "Creating UEFI Boot Partition"
	sgdisk -n 1:0:+512M $DEVICE
	sgdisk -t 1:ef00 $DEVICE
	echo "Formating Boot Partition"
	mkfs.vfat ${DEVICE}1
	
	# Add efibootmgr to Package list
	OPTIONALDEP="$OPTIONALDEP efibootmgr"
else
	echo "Creating GPT Bios Partition"
	sgdisk -n 1:0:+1M $DEVICE
	sgdisk -t 1:ef02 $DEVICE
fi

echo "Creating Swap Partition"
sgdisk -n 2:0:+2G $DEVICE
sgdisk -t 2:8200 $DEVICE

# Create required partitions
echo "Creating Root Partition"
sgdisk -n 3:0:0 $DEVICE
sgdisk -t 3:8300 $DEVICE

echo "Formating Root Partition"
mkfs.ext4 -F -F ${DEVICE}3

echo "Mounting Root Partition"
mount -o noatime ${DEVICE}3 $VARTARGETDIR

echo "Enable Swap Patitions"
mkswap ${DEVICE}2
swapon ${DEVICE}2


######################
## Install Packages ##
######################

# Install system into $VARTARGETDIR
echo "# Installing Main System"
pacstrap $VARTARGETDIR $EXTRAPKG
pacstrap $VARTARGETDIR --asdeps $OPTIONALDEP


# Generate fstab
echo "# Creating Fstab Entrys"
genfstab -p -U $VARTARGETDIR >> $VARTARGETDIR/etc/fstab


################
## Bootloader ##
################

# Modify grub bootloader options
sed -i 's/^GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' $VARTARGETDIR/etc/default/grub
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=3 udev.log-priority=3"/' $VARTARGETDIR/etc/default/grub

# Create BootLoader Installer
if [ -d "/sys/firmware/efi/" ]; then
echo "Mounting UEFI Boot Partition"
mkdir -p $VARTARGETDIR/boot/EFI
mount ${DEVICE}1 $VARTARGETDIR/boot/EFI

# Create bootloader install script
cat > $VARTARGETDIR/root/bootloader.sh <<BOOT_EOF
#!/bin/bash
set -e
set -u

echo "Installing Grub Bootloader"
grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=Archlinux
grub-mkconfig -o /boot/grub/grub.cfg
rm -rf /root/bootloader.sh
BOOT_EOF

else
# Create bootloader install script
cat > $VARTARGETDIR/root/bootloader.sh <<BOOT_EOF
#!/bin/bash
set -e
set -u

echo "Installing Grub Bootloader"
grub-install --target=i386-pc ${DEVICE}
grub-mkconfig -o /boot/grub/grub.cfg
rm -rf /root/bootloader.sh
BOOT_EOF
fi

# Install bootloader
chmod u+x $VARTARGETDIR/root/bootloader.sh
arch-chroot $VARTARGETDIR /root/bootloader.sh


##########################
## Install Aur Packages ##
##########################

# Change sudoers to allow nobody user access to sudo without password
echo 'nobody ALL=(ALL) NOPASSWD: ALL' > $VARTARGETDIR/etc/sudoers.d/20_nobody

# Create AUR Install Script
# -------------------------
cat > $VARTARGETDIR/root/aurinstall.sh <<AUR_EOF
#!/bin/sh
set -e
set -u

# Add nobody user to wheel group
gpasswd -a nobody wheel

# Create Build Directorys and set permissions
mkdir /tmp/build
chgrp nobody /tmp/build
chmod g+ws /tmp/build
setfacl -m u::rwx,g::rwx /tmp/build
setfacl -d --set u::rwx,g::rwx,o::- /tmp/build
cd /tmp/build/

# Install packer
sudo -u nobody wget https://aur.archlinux.org/cgit/aur.git/snapshot/packer.tar.gz
sudo -u nobody tar -zxvf packer.tar.gz
cd packer
sudo -u nobody makepkg -s -i --noconfirm
cd ..
rm -r packer

# Install package-query dependency
sudo -u nobody wget https://aur.archlinux.org/cgit/aur.git/snapshot/nano-syntax-highlighting-git.tar.gz
sudo -u nobody tar -zxvf nano-syntax-highlighting-git.tar.gz
cd nano-syntax-highlighting-git
sudo -u nobody makepkg -s -i --noconfirm
cd ..
rm -r nano-syntax-highlighting-git

# Cleanup
cd ..
rm -r build/

# Remove nobody user from wheel group
gpasswd -d nobody wheel
rm -rf /root/aurinstall.sh
AUR_EOF

# Install AUR Packages
chmod u+x $VARTARGETDIR/root/aurinstall.sh
arch-chroot $VARTARGETDIR /root/aurinstall.sh

# Change sudoers to allow wheel group access to sudo with password
rm $VARTARGETDIR/etc/sudoers.d/20_nobody


##########################
## System Configuration ##
##########################

# Set Locale Settings
echo "Setting Locale"
sed -i 's/^#en_IE.UTF-8 UTF-8/en_IE.UTF-8 UTF-8/' $VARTARGETDIR/etc/locale.gen
echo 'LANG=en_IE.UTF-8' > $VARTARGETDIR/etc/locale.conf

# Set Console keymap
echo "Setting KEYMAP"
echo "KEYMAP=$KEYMAP" >> $VARTARGETDIR/etc/vconsole.conf
echo "FONT=Lat2-Terminus16" >> $VARTARGETDIR/etc/vconsole.conf

# Set Timezone
echo "Setting Timezone"
ln -sf "/usr/share/zoneinfo/Europe/Dublin" $VARTARGETDIR/etc/localtime

# Set Hostname
echo "Setting Hostname"
echo "${HOSTNM}" > $VARTARGETDIR/etc/hostname
sed -i "s/domain\tlocalhost/domain\tlocalhost\t$HOSTNM/" $VARTARGETDIR/etc/hosts

# Changeing Pacman Configuration to add colored output
sed -i 's/#Color/Color/' $VARTARGETDIR/etc/pacman.conf

# Enable Support for All Highlighters and Disable text wraping
if [ -d "$VARTARGETDIR/usr/share/nano-syntax-highlighting" ]; then
	echo "Enabling nano Highlighting Support"
	echo 'include "/usr/share/nano-syntax-highlighting/*.nanorc"' >> $VARTARGETDIR/etc/skel/.nanorc
fi

# Changing nanorc config
echo "Changing nanorc config"
echo 'set nowrap' >> $VARTARGETDIR/etc/skel/.nanorc
echo 'set suspend' >> $VARTARGETDIR/etc/skel/.nanorc
cp $VARTARGETDIR/etc/skel/.nanorc $VARTARGETDIR/root/.nanorc

# Setup Network
echo "Configuring Network"
DAEMONS="$DAEMONS systemd-networkd.service systemd-resolved.service"
ln -sf "/run/systemd/resolve/resolv.conf" $VARTARGETDIR/etc/resolv.conf
sed -i "s/hosts: files dns myhostname/hosts: files resolve $HOSTNM/" $VARTARGETDIR/etc/nsswitch.conf
cat > $VARTARGETDIR/etc/systemd/network/wired.network <<NET_EOF
[Match]
Name=en*

[Network]
DHCP=yes
NET_EOF

# Install reflector services files
if [ -f "$VARTARGETDIR/usr/bin/reflector" ]; then
	install -m 644 services/reflector.service $VARTARGETDIR/etc/systemd/system/reflector.service
	install -m 644 services/reflector.timer $VARTARGETDIR/etc/systemd/system/reflector.timer
	DAEMONS="$DAEMONS reflector.timer"
fi

# Transfor over .bashrc files for global and local users
echo "Install custom bachrc"
install -m 644 prompts/bash_bashrc_global $VARTARGETDIR/etc/bash.bashrc
install -m 644 prompts/bash_aliases_global $VARTARGETDIR/etc/bash_aliases
install -m 644 prompts/bash_bashrc_local $VARTARGETDIR/etc/skel/.bashrc
install -m 644 prompts/bash_aliases_local $VARTARGETDIR/etc/skel/.bash_aliases

# Setup ls color
echo "Install custom DIR_COLORS"
install -m 666 extras/lscolor $VARTARGETDIR/etc/DIR_COLORS

# Setup archey3
echo "Configuring archey"
if [ -f "$VARTARGETDIR/usr/bin/archey3" ]; then
# Configure archey for root
cat > $VARTARGETDIR/root/.archey3.cfg <<ARCHEY_EOF
[core]
color = red
align = center
display_modules = distro(), uname(n), uname(r), uptime(), packages(), ram(), fs(/)
ARCHEY_EOF

# Configure archey for normal user
cat > $VARTARGETDIR/etc/skel/.archey3.cfg <<ARCHEY_EOF
[core]
color = green
align = center
display_modules = distro(), uname(n), uname(r), uptime(), packages(), ram(), fs(/)
ARCHEY_EOF
fi

# Change sudoers to allow wheel group access to sudo with password
echo '%wheel ALL=(ALL) ALL' > $VARTARGETDIR/etc/sudoers.d/10_wheel
chmod 640 $VARTARGETDIR/etc/sudoers.d/10_wheel


########################
## Post Configuration ##
########################

# Create Post Install Script
# --------------------------
cat > $VARTARGETDIR/root/postScript.sh <<POST_EOF
#!/bin/bash
set -e
set -u

echo "Setting up Systemd Service"
systemctl enable ${DAEMONS}

echo "Setting Locale"
hwclock --systohc --utc
export LANG=en_IE.UTF-8
loadkeys ${KEYMAP}
locale-gen

echo "Changing Root password"
echo -e "${ROOTPASSWORD}\n${ROOTPASSWORD}" | passwd root

# Create user acount
useradd -m -G wheel ${USERNAME}
echo -e "${USERPASS}\n${USERPASS}" | passwd ${USERNAME}

# Check if running in a vmware VM
if [ -d "/usr/lib/open-vm-tools" ]; then
	cat /proc/version > /etc/arch-release
fi

# Update mlocate database if installed
if [ -f "usr/bin/updatedb" ]; then
	updatedb
fi

echo "Optimizing Pacman Database"
pacman-optimize

# ReCreate linux images
echo "Creating Initial Ramdisk"
mkinitcpio -p linux

rm -rf /root/postScript.sh
POST_EOF

# Chroot and configure
echo "Running postScript script"
chmod u+x $VARTARGETDIR/root/postScript.sh
arch-chroot $VARTARGETDIR /root/postScript.sh

################
## Finalizing ##
################

# Copy over installers
cp -r post-install-scripts $VARTARGETDIR/root/post-install-scripts

echo "##########################################"
echo "## Don't forget to execute after reboot ##"
echo "## >>> timedatectl set-ntp true         ##"
echo "##########################################"

# Reboot System
reboot
