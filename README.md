# Arch-installer

Arch-installer is an attempt to automate the installation of Arch Linux. It will install the base system along with some extra packages 
as well as some optional packages. Most from the official repositories and some from the AUR(Arch User Repository). 

Some post install scripts are also available in the post-install-scripts folder. "[install-kodi.sh]" to install kodi and "[disable-fsck-output.sh]" to disable fsck output on bootup. The scripts will be available in the root directory after install.

### Fallowing are the steps that the script takes
  - Ask for the Hostname to give to the computer
  - Ask for the password for root account
  - Ask for username
  - Ask for password for given username
  - Optional package selection
  - The script will wipe the first drive (sda) and uses GPT for the partition scheme. 
  - Setup the first partition as either a 512M EFI partition or a 1M bios partition depending on system type
  - Creates a 2GB swap partition
  - The rest of the drive will be the main root partition
  - Installs all required packages
  - Setup fstab
  - Install Grub bootloader
  - Install AUR Packages
  - Config network interface to use systemd-networkd with DHCP
  - Some common system configurations / optimizations
  - Transfer over post-install-scripts into root directory
  - Reboot

#
# Packages
### Base Packages
  - [base] = Base arch linux system packages
  - [base-devel] = Base packages to compile packages from aur
  - [memtest86+] = An advanced memory diagnostic tool
  - [openssh] = Free version of the SSH connectivity tool
  - [wget] = A network utility to retrieve files from the Web
  - [alsa-utils] = An implementation of Linux sound support -- If audio device is found
  - [open-vm-tools] = Open source implementation of VMware Tools -- If running in a vmware environment
  - [virtualbox-guest-utils] = VirtualBox Guest userspace utilities -- If running in a virtualbox environment
  - [intel-ucode] = Microcode update files for Intel CPUs -- If intel CPU is found
  - [xf86-video-intel] = Xorg intel video drivers -- If intel GPU is found
  - [nvidia] = NVIDIA drivers for linux -- If nvidia GPU is found

### Optional Packages
  - [nfs-utils] = Support programs for NFS (Network File Systems)
  - [reflector] = Retrieve and filter the latest Pacman mirror list
  - [mlocate] = Merging locate/updatedb implementation
  - [pkgfile] = A pacman files metadata explorer
  - [archey3] = Output a logo and various system information

### Aur Packages
  - [packer] = Bash wrapper for pacman and aur
  - [nano-syntax-highlighting-git] = Nano editor syntax highlighting enhancements

#
# Installation
Download the latest ISO from [archlinux.org/download/] and boot into the live ISO. 
Once the installer boots, start the ssh daemon. Then change the password of root so you can 
login to the environment using ssh. Next transfer over this installer folder to arch linux live boot environment
using a file transfer program like [filezilla]. Then just execute this installer
```sh
$ systemctl start sshd
$ passwd
$ ip addr show
$ "Transfer over arch-installer folder"
$ cd arch-installer
$ sh installer.sh
```
---
Development
----
Want to contribute? Great! Any contributions are welcomed

Todo's
----
Create a post install script to install gnome

Version
----
0.1.0

License
----
GPLv3

[base]:https://www.archlinux.org/groups/x86_64/base/
[base-devel]:https://www.archlinux.org/groups/x86_64/base-devel/
[openssh]:https://www.archlinux.org/packages/core/x86_64/openssh/
[memtest86+]:https://www.archlinux.org/packages/extra/any/memtest86+/
[wget]:https://www.archlinux.org/packages/extra/x86_64/wget/
[alsa-utils]:https://www.archlinux.org/packages/extra/x86_64/alsa-utils/
[open-vm-tools]:https://www.archlinux.org/packages/community/x86_64/open-vm-tools/
[virtualbox-guest-utils]:https://www.archlinux.org/packages/community/x86_64/virtualbox-guest-utils/
[xf86-video-intel]:https://www.archlinux.org/packages/extra/i686/xf86-video-intel/
[nvidia]:https://www.archlinux.org/packages/extra/x86_64/nvidia/
[intel-ucode]:https://www.archlinux.org/packages/extra/any/intel-ucode/
[nfs-utils]:https://www.archlinux.org/packages/core/x86_64/nfs-utils/
[reflector]:https://www.archlinux.org/packages/community/any/reflector/
[mlocate]:https://www.archlinux.org/packages/core/x86_64/mlocate/
[pkgfile]:https://www.archlinux.org/packages/extra/x86_64/pkgfile/
[archey3]:https://www.archlinux.org/packages/community/any/archey3/
[packer]:https://aur.archlinux.org/packages/packer/
[nano-syntax-highlighting-git]:https://aur.archlinux.org/packages/nano-syntax-highlighting-git/
[archlinux.org/download/]:https://www.archlinux.org/download/
[disable-fsck-output.sh]:https://github.com/willforde/arch-installer/blob/master/post-install-scripts/disable-fsck-output.sh
[install-kodi.sh]:https://github.com/willforde/arch-installer/blob/master/post-install-scripts/install-kodi.sh
[filezilla]:https://filezilla-project.org/
