#!/usr/bin/env bash

# This is the base script that will install a mostly barebone Arch Linux system.
# Installed packages are base, base-devel, openssh, mlocate and reflector.
# The bootloader that will be installed is rEFInd.
#
# WARNING: This script will wipe whatever drive is mapped to '/dev/sda'.
# So make sure that the only drive connected, is the drive you want to install Arch Linux to.
set -e
set -u

if [ ! -d "/sys/firmware/efi/" ]; then
	echo "Sorry, this script only supports UEFI mode"
	exit 1
fi

# Constents
VARTARGETDIR="/mnt"
DEVICE="/dev/sda"
KEYMAP="uk"

# DAEMON Services
DAEMONS=""

# Software Packages
EXTRAPKG="base base-devel refind-efi"
OPTIONALDEP="bash-completion"

# Required
# base			    = Base linux system packages group				    = https://www.archlinux.org/groups/x86_64/base/
# base-devel	    = Base packages to compile packages from aur	    = https://www.archlinux.org/groups/x86_64/base-devel/
# refind-efi        = UEFI Boot Manager - Built with GNU-EFI libs       = https://www.archlinux.org/packages/extra/x86_64/refind-efi/

# Optional
# bash-completion	= Programmable completion for the bash shell	    = https://www.archlinux.org/packages/extra/any/bash-completion/


###########
## Setup ##
###########

handelCanceled()
{
    if [ $1 != 0 ]; then
        exit $1
    fi
}

selectDisk()
{
        MENU=""
        for disk in $(lsblk -l | grep disk | awk '{print $1}'); do
                MODEL=$(hdparm -I /dev/${disk} | awk -F':' '/Model Number/ { print $2 }' | sed 's/^[ \t]*//;s/[ \t]*$//')
                SIZE=$(hdparm -I /dev/${disk} | grep "device size with M = 1000" | awk -F'(' '{ print $2 }' | sed 's/^[ \t]*//;s/[ \t]*$//' | rev | cut -c 2- | rev)
                MENU="$MENU '/dev/$disk' '$MODEL - $SIZE'"
        done
        DEVICE=$(echo ${MENU} | xargs dialog --title "Drive Selection" --menu "Please select drive in witch to install Arch Linux.\nWARNING: All data on selected drive will be WIPED clean." 13 60 10 --output-fd 1)
        handelCanceled $?
}

requestPackages()
{
	dialog --title "Optional Packages" --checklist "Please Select Optional Packages:" 15 55 5 1 "openssh" on 2 "reflector" on 3 "mlocate" on 4 "pkgfile" on 5 "pacman-contrib" on 2>/tmp/menuitem
	handelCanceled $?
	for pkg in $(cat /tmp/menuitem); do
		if [ "$pkg" = 1 ]; then
		    # openssh		= Free version of the SSH connectivity tools            = https://www.archlinux.org/packages/core/x86_64/openssh/
			EXTRAPKG="$EXTRAPKG openssh"
			DAEMONS="$DAEMONS sshd.service"

		elif [ "$pkg" = 2 ]; then
		    # reflector		= Retrieve and filter the latest Pacman mirror list		= https://www.archlinux.org/packages/community/any/reflector/
			# rsync 		= A file transfer program to keep remote files in sync	= https://www.archlinux.org/packages/extra/x86_64/rsync/
			EXTRAPKG="$EXTRAPKG reflector"
			OPTIONALDEP="$OPTIONALDEP rsync"

		elif [ "$pkg" = 3 ]; then
		    # mlocate	    = Merging locate/updatedb implementation	= https://www.archlinux.org/packages/core/x86_64/mlocate/
			EXTRAPKG="$EXTRAPKG mlocate"
			DAEMONS="$DAEMONS updatedb.timer"

		elif [ "$pkg" = 4 ]; then
		    # pkgfile	    = A pacman files metadata explorer		    = https://www.archlinux.org/packages/extra/x86_64/pkgfile/
			EXTRAPKG="$EXTRAPKG pkgfile"
			DAEMONS="$DAEMONS pkgfile-update.timer"
		elif [ "$pkg" = 5 ]; then
		    # pacman-contrib    = Contributed scripts and tools for pacman systems      = https://www.archlinux.org/packages/community/x86_64/pacman-contrib/
		    EXTRAPKG="$EXTRAPKG pacman-contrib"
		fi
	done
}

requestHostname()
{
	HOSTNM=""
	while [ "$HOSTNM" = "" ]
	do
		HOSTNM=$(dialog --title "Hostname" --inputbox "Please enter hostname:" 8 50 --output-fd 1)
		handelCanceled $?
	done
}

requestRoot()
{
        ROOTPASSWORD=""
        CONFIRM="-"
        while [ "$ROOTPASSWORD" != "$CONFIRM" ]; do
                ROOTPASSWORD=$(dialog --title "Root Password" --insecure --passwordbox "Please enter Root Password:" 8 50 --output-fd 1)
                handelCanceled $?

                CONFIRM=$(dialog --title "Root Password" --insecure --passwordbox "Please comfirm Root Password:" 8 50 --output-fd 1)
                handelCanceled $?

                if [ "$ROOTPASSWORD" == "" ]; then
                    dialog --msgbox "A Password is Requred, Please try again.." 8 50
                    CONFIRM="-"
                elif [ "$ROOTPASSWORD" != "$CONFIRM" ]; then
                    dialog --msgbox "Password did not match, Please try again." 8 50
                fi
        done
        unset EXITCODE
        unset CONFIRM
}

requestUser()
{
    USERNAME=""
    while [ "$USERNAME" = "" ]; do
        USERNAME=$(dialog --title "Username" --inputbox "Please enter Username:" 8 50 --output-fd 1)
        handelCanceled $?
    done
    requestUserPass
}

requestUserPass()
{
    USERPASS=""
    CONFIRM="-"
    while [ "$USERPASS" != "$CONFIRM" ]; do
            USERPASS=$(dialog --title "User Password" --insecure --passwordbox "Please enter Password for $USERNAME:" 8 50 --output-fd 1)
            handelCanceled $?

            CONFIRM=$(dialog --title "User Password" --insecure --passwordbox "Please comfirm Password for $USERNAME:" 8 50 --output-fd 1)
            handelCanceled $?

            if [ "$USERPASS" == "" ]; then
                dialog --msgbox "A Password is Requred, Please try again.." 8 50
                CONFIRM="-"
            elif [ "$USERPASS" != "$CONFIRM" ]; then
                dialog --msgbox "Password did not match, Please try again." 8 50
            fi
    done
    unset EXITCODE
    unset CONFIRM
}

confirmation()
{
        data="sda"
        dialog --title "Warning" --yesno "From here on, you will not be asked any more questions, and all data on drive /dev/$data will be Wiped.\n\nAre you sure you want to continue." 10 50
        handelCanceled $?
}


# Check if system has a Audio device
if [[ -n $(lspci | grep -i "Multimedia audio controller:") ]] || [[ -n $(lspci | grep -i "Audio device:") ]]; then
	# alsa-utils		= An implementation of Linux sound support		= https://www.archlinux.org/packages/extra/x86_64/alsa-utils/
	EXTRAPKG="$EXTRAPKG alsa-utils"
fi

# Check GPU the system is using
if [[ -n $(lspci | grep -i "VGA compatible controller: NVIDIA Corporation") ]]; then
    EXTRAPKG="$EXTRAPKG nvidia"
    DECODER='vdpau'
fi


####################
## Virtualization ##
####################

if systemd-detect-virt -q; then
    VM=$(systemd-detect-virt)

    # Check for a VMware virtual machine
    if [ "$VM" == "vmware" ]; then
        # open-vm-tools		= open-vm-tools are the open source implementation of VMware Tools		= https://www.archlinux.org/packages/community/x86_64/open-vm-tools/
        EXTRAPKG="$EXTRAPKG open-vm-tools"
        DAEMONS="$DAEMONS vmtoolsd.service"

        # Required Kernel Drivers
        # vmw_balloon
        # vmw_pvscsi
        # vmw_vmci
        # vmwgfx
        # vmxnet3

        # Esxi Hypervisor drivers
        # vsock
        # vmw_vsock_vmci_transport

    # Check for a Virtuabox virtual machine
    elif [ "$VM" == "oracle" ]; then
        # virtualbox-guest-utils	= VirtualBox Guest userspace utilities		= https://www.archlinux.org/packages/community/x86_64/virtualbox-guest-utils/
        EXTRAPKG="$EXTRAPKG virtualbox-guest-utils"
        OPTIONALDEP="$OPTIONALDEP virtualbox-guest-modules-arch"
        DAEMONS="$DAEMONS vboxservice.service"

    # Check if system is using an intel CPU and if so, install intel-ucode
    elif [ "$VM" == "qemu" ] || [ "$VM" == "kvm" ]; then
        # qemu-guest-agent		= QEMU Guest Agent		= https://www.archlinux.org/packages/extra/x86_64/qemu-guest-agent/
        EXTRAPKG="$EXTRAPKG qemu-guest-agent"
        DAEMONS="$DAEMONS qemu-ga.service"
    fi

elif [[ -n $(cat /proc/cpuinfo | grep -i "GenuineIntel") ]]; then
	EXTRAPKG="$EXTRAPKG intel-ucode"
	# intel-ucode				= Microcode update files for Intel CPUs			= https://www.archlinux.org/packages/extra/any/intel-ucode/
fi


#####################
# Pre Configuration #
#####################

selectDisk
requestPackages
requestHostname
requestRoot
requestUser
confirmation
clear

echo "Loading Uk Keyboard Layout"
loadkeys ${KEYMAP}

echo "Syncing clocks"
timedatectl set-ntp true
hwclock --systohc --utc

echo "Setting Locale to en_IE"
sed -i 's/^en_US.UTF-8/#en_US.UTF-8/' /etc/locale.gen
sed -i 's/^#en_IE.UTF-8/en_IE.UTF-8/' /etc/locale.gen
echo "LANG=en_IE.UTF-8" > /etc/locale.conf
export LANG=en_IE.UTF-8
locale-gen
echo ""


##################
## Partitioning ##
##################

# Formating Disks
echo "# Wriping Drive"
sgdisk -Z ${DEVICE}
sgdisk -a 2048 -o ${DEVICE}

echo "Setup UEFI Boot Partition"
sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"EFI System Partition" ${DEVICE}
mkfs.vfat ${DEVICE}1

echo "Setup Swap Partition"
sgdisk -n 2:0:+2G -t 2:8200 -c 2:"Swap Partition" ${DEVICE}

echo "Setup Root Partition"
sgdisk -n 3:0:0 -t 3:8300 -c 3:"Linux / Partition" ${DEVICE}
mkfs.ext4 -F ${DEVICE}3

echo "# Mounting Partitions"
mount -vo noatime ${DEVICE}3 ${VARTARGETDIR}
mkdir -pv ${VARTARGETDIR}/boot/efi
mount -v ${DEVICE}1 ${VARTARGETDIR}/boot/efi

echo "Enable Swap Partition"
mkswap ${DEVICE}2
swapon ${DEVICE}2


######################
## Install Packages ##
######################

# Install Required Packages if needed
echo "Downloading and Install reflector installation requirements"
pacman -Sy --noconfirm --needed reflector

# Download and sort Mirrors List from Archlinux.org
echo "Downloading and Ranking mirrors"
reflector --verbose --protocol http --latest 50 --number 20 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syy

echo "# Installing Main System"
pacstrap ${VARTARGETDIR} ${EXTRAPKG}
pacstrap ${VARTARGETDIR} --asdeps ${OPTIONALDEP}

echo "# Creating Fstab Entrys"
genfstab -U ${VARTARGETDIR} >> ${VARTARGETDIR}/etc/fstab


################
## Bootloader ##
################

# Create required directories
mkdir -pv ${VARTARGETDIR}/boot/efi/EFI/refind/drivers_x64 ${VARTARGETDIR}/boot/efi/EFI/BOOT/drivers_x64

# Copy over refind system files
cp -v ${VARTARGETDIR}/usr/share/refind/refind_x64.efi ${VARTARGETDIR}/boot/efi/EFI/refind/refind_x64.efi
cp -v ${VARTARGETDIR}/usr/share/refind/refind_x64.efi ${VARTARGETDIR}/boot/efi/EFI/BOOT/bootx64.efi
cp -v ${VARTARGETDIR}/usr/share/refind/drivers_x64/ext4_x64.efi ${VARTARGETDIR}/boot/efi/EFI/refind/drivers_x64/ext4_x64.efi
cp -v ${VARTARGETDIR}/usr/share/refind/drivers_x64/ext4_x64.efi ${VARTARGETDIR}/boot/efi/EFI/BOOT/drivers_x64/ext4_x64.efi
cp -v ${VARTARGETDIR}/usr/share/refind/refind.conf-sample ${VARTARGETDIR}/boot/efi/EFI/refind/refind.conf
cp -v ${VARTARGETDIR}/usr/share/refind/refind.conf-sample ${VARTARGETDIR}/boot/efi/EFI/BOOT/refind.conf
cp -vr ${VARTARGETDIR}/usr/share/refind/icons ${VARTARGETDIR}/boot/efi/EFI/refind/
cp -vr ${VARTARGETDIR}/usr/share/refind/icons ${VARTARGETDIR}/boot/efi/EFI/BOOT/

# Fetch uuid of root partition
DISK_UUID=$(lsblk ${DEVICE}3 -o uuid -n)

# Create refind boot options config with intel microcode added if intel-ucode is installed
if [ -f "${VARTARGETDIR}/boot/intel-ucode.img" ]; then
cat > ${VARTARGETDIR}/boot/refind_linux.conf <<EOF
"Boot to graphical"        "rw root=UUID=${DISK_UUID}  initrd=/boot/intel-ucode.img initrd=/boot/initramfs-linux.img quiet loglevel=3 udev.log-priority=3"
EOF
else
# Create without microcode added
cat > ${VARTARGETDIR}/boot/refind_linux.conf <<EOF
"Boot to graphical"        "rw root=UUID=${DISK_UUID}  initrd=/boot/initramfs-linux.img quiet loglevel=3 udev.log-priority=3"
EOF
fi

# Create Boot options config
cat >> ${VARTARGETDIR}/boot/refind_linux.conf <<EOF
"Boot to terminal"                  "rw root=UUID=${DISK_UUID}  systemd.unit=multi-user.target"
"Boot to single-user mode"          "rw root=UUID=${DISK_UUID}  single"
EOF

# Register rEFInd bootloader
efibootmgr --create --disk ${DEVICE} --part 1 --loader /EFI/refind/refind_x64.efi --label "rEFInd Boot Manager" --verbose


########################
## Core Configuration ##
########################

echo "Configuring Network"
DAEMONS="$DAEMONS systemd-networkd.service systemd-resolved.service"
rm ${VARTARGETDIR}/etc/resolv.conf
ln -sf "/run/systemd/resolve/stub-resolv.conf" ${VARTARGETDIR}/etc/resolv.conf
cat > ${VARTARGETDIR}/etc/systemd/network/20-wired.network <<NET_EOF
[Match]
Name=en*

[Network]
DHCP=ipv4
NET_EOF

# Set Console keymap
echo "Setting KEYMAP"
echo "KEYMAP=$KEYMAP" >> ${VARTARGETDIR}/etc/vconsole.conf

# Set Hostname
echo "Setting Hostname"
echo "${HOSTNM}" > ${VARTARGETDIR}/etc/hostname

# Set Locale Settings
echo "Setting Locale"
sed -i 's/^#en_IE.UTF-8 UTF-8/en_IE.UTF-8 UTF-8/' ${VARTARGETDIR}/etc/locale.gen
echo 'LANG=en_IE.UTF-8' > ${VARTARGETDIR}/etc/locale.conf

# Set Timezone
echo "Setting Timezone"
ln -sf "/usr/share/zoneinfo/Europe/Dublin" ${VARTARGETDIR}/etc/localtime

# Enable required services
echo "Setting up Systemd Services"
arch-chroot ${VARTARGETDIR} systemctl enable ${DAEMONS}


################
## Finalizing ##
################

# Execute the post configurations within chroot
cp -rv scripts ${VARTARGETDIR}/opt/install-scripts
cp -rv localbin/* ${VARTARGETDIR}/usr/local/bin/
cp post.sh ${VARTARGETDIR}/root/
arch-chroot ${VARTARGETDIR} sh /root/post.sh ${ROOTPASSWORD} ${USERNAME} ${USERPASS}
rm ${VARTARGETDIR}/root/post.sh

echo "Unmounting Drive Partitions"
swapoff ${DEVICE}2
umount -v ${VARTARGETDIR}/boot/efi
umount -v ${VARTARGETDIR}

echo ""
echo "##########################################"
echo "##               All Done               ##"
echo "##########################################"
echo "## Don't forget to execute after reboot ##"
echo "## >>> timedatectl set-ntp true         ##"
echo "##########################################"
echo "## Please see '/opt/install-scripts'    ##"
echo "## for extra post install scripts       ##"
echo "##########################################"
