# Arch-installer
This script will automate the installation of Arch Linux. Will install the base Arch Linux system
along with some other extra packages, as well as some optional packages. A AUR(Arch User Repository).
helper called 'Yay' will also be installed. Below is the list of tasks that the script does, in order of execution.

  - Ask to selected drive that will be use for the install of Arch. All data on drive will be "wiped".
  - Ask for the Hostname for the computer
  - Ask for a Password for root user
  - Ask for Username for a normal user account
  - Ask for a Password for given Username
  - Optional package selection
  - Speed rate the pacman mirror list
  - Wipe the selected drive and uses GPT for the partition scheme
  - Setup the first partition as a 512M EFI partition
  - The seconed as a 2GB swap partition
  - The rest of the drive will be the main root(/) partition
  - Installs all required packages
  - Setup fstab
  - Install rEFInd bootloader
  - Setup user account
  - Config network interface to use DHCP, using systemd-networkd as the network manager
  - Common system configurations & optimizations
  - Packman hooks to update 'mirrors', bootloader & remove old cached pacman files
  - Install AUR Helper

## Packages
#### Explicit Packages
  - [base] = Base arch linux system packages
  - [base-devel] = Base packages to compile packages from aur
  - [refind-efi] = UEFI Boot Manager - Built with GNU-EFI libs

#### Optional Packages
  - [openssh] = Free version of the SSH connectivity tool
  - [reflector] = Retrieve and filter the latest Pacman mirror list
  - [mlocate] = Merging locate/updatedb implementation
  - [pkgfile] = A pacman files metadata explorer
  - [pacman-contrib] = Contributed scripts and tools for pacman systems

#### Aur Packages
  - [yay] = Pacman wrapper and AUR helper written in go.

#### Extra Packages
  - [alsa-utils] = An implementation of Linux sound support -- If audio device is detected
  - [open-vm-tools] = Open source implementation of VMware Tools -- If running in a VMware environment
  - [virtualbox-guest-utils] = VirtualBox Guest userspace utilities -- If running in a VirtualBox environment
  - [qemu-guest-agent] = QEMU/KVM Guest userspace utilities -- If running in a QEMU/KVM environment


## Download & Run
Download the latest ISO from [archlinux.org], then boot into the live ISO(Archiso).
Once the installer boots, run the following commands to download and execute the install script.

```sh
$ curl -SLO https://github.com/willforde/arch-installer/archive/master.tar.gz
$ tar zxf master.tar.gz && cd arch-installer-master
$ sh base.sh
```

[base]:https://www.archlinux.org/groups/x86_64/base/
[base-devel]:https://www.archlinux.org/groups/x86_64/base-devel/
[openssh]:https://www.archlinux.org/packages/core/x86_64/openssh/
[refind-efi]:https://www.archlinux.org/packages/extra/x86_64/refind-efi/
[alsa-utils]:https://www.archlinux.org/packages/extra/x86_64/alsa-utils/
[open-vm-tools]:https://www.archlinux.org/packages/community/x86_64/open-vm-tools/
[virtualbox-guest-utils]:https://www.archlinux.org/packages/community/x86_64/virtualbox-guest-utils/
[reflector]:https://www.archlinux.org/packages/community/any/reflector/
[mlocate]:https://www.archlinux.org/packages/core/x86_64/mlocate/
[pkgfile]:https://www.archlinux.org/packages/extra/x86_64/pkgfile/
[yay]:https://aur.archlinux.org/packages/yay/
[qemu-guest-agent]:https://www.archlinux.org/packages/extra/x86_64/qemu-guest-agent/
[archlinux.org]:https://www.archlinux.org/download/
[pacman-contrib]:https://www.archlinux.org/packages/community/x86_64/pacman-contrib/
