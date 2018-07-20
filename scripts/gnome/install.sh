#!/usr/bin/env bash
set -e
set -u

# Base gnome install
PKGS="gnome-shell gnome-system-monitor"
OPTIONALDEP="gnome-control-center gnome-keyring"

# Expanded install
PKGS="$PKGS gnome-{shell-extensions,backgrounds,calculator,screenshot,contacts,tweaks,user-docs}"

# Apps
PKGS="$PKGS gparted baobab evince eog filezilla"
OPTIONALDEP="$OPTIONALDEP dosfstools exfat-utils ntfs-3g xfsprogs polkit gpart"

# Install required packages
sudo pacman -S --noconfirm --needed ${PKGS}
sudo pacman -S --noconfirm --needed --asdeps ${OPTIONALDEP}

# Settings
dbus-launch gsettings set org.gnome.desktop.notifications show-in-lock-screen false
dbus-launch gsettings set org.gnome.desktop.datetime automatic-timezone true
dbus-launch gsettings set org.gnome.desktop.screensaver lock-enabled false


#####################
## Display Manager ##
#####################

# gdm => Display manager and login screen => https://www.archlinux.org/packages/extra/x86_64/gdm/
# wiki => https://wiki.archlinux.org/index.php/GDM

# Install gdm
sudo pacman -S --noconfirm --needed gdm

# Disable Wayland until there is better support
sudo sed -i s/#WaylandEnable=false/WaylandEnable=false/ /etc/gdm/custom.conf

# Enable GDM to start on boot
sudo systemctl enable gdm.service


###########
## Clock ##
###########

# Install gnome clocks
sudo pacman -S --noconfirm --needed gnome-clocks

# Setup timezones
dbus-launch gsettings set org.gnome.clocks geolocation false
dbus-launch gsettings set org.gnome.clocks world-clocks "[{'location': <(uint32 2, <('San Francisco', 'KSFO', true, [(0.65658801258494626, -2.1356672871875406)], [(0.659296885757089, -2.1366218601153339)])>)>}, {'location': <(uint32 2, <('New York', 'KNYC', true, [(0.71180344078725644, -1.2909618758762367)], [(0.71059804659265924, -1.2916478949920254)])>)>}, {'location': <(uint32 2, <('Dublin', 'EIDW', true, [(0.93258759116453926, -0.1090830782496456)], [(0.93083742735051689, -0.10906368764165594)])>)>}, {'location': <(uint32 2, <('Melbourne', 'YMML', true, [(-0.65740735740229495, 2.5278185274873568)], [(-0.6600253512802865, 2.5301456447922108)])>)>}]"


##################
## File Manager ##
##################

# Install nautilus file manager & optional dependencies
sudo pacman -S --noconfirm --needed nautilus file-roller
sudo pacman -S --noconfirm --needed --asdeps gvfs-google gvfs-goa gvfs-smb gvfs-nfs p7zip unrar

# Set Nautilus to show size of folder and files
dbus-launch gsettings set org.gnome.nautilus.icon-view captions "['none', 'size', 'none']"


#####################
## Network Manager ##
#####################

# Install network manager
sudo pacman -S --noconfirm --needed networkmanager

# Disable Systemd network first
sudo systemctl disable systemd-networkd.service systemd-resolved.service
sudo systemctl stop systemd-networkd.service systemd-resolved.service
sudo rm /etc/systemd/network/20-wired.network /etc/resolv.conf
sudo systemctl enable NetworkManager.service
sudo systemctl start NetworkManager.service
sleep 3


##############
## Terminal ##
##############

# Install Transparency version of gnome-terminal
yay -S --noconfirm gnome-terminal-transparency

# Setup profile data
profile=$(gsettings get org.gnome.Terminal.ProfilesList default)
profile=${profile:1:-1} # remove leading and trailing single quotes
dbus-launch gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" background-color "rgb(2,17,26)"
dbus-launch gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" background-transparency-percent 12
dbus-launch gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" bold-color "rgb(238,238,236)"
dbus-launch gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" bold-color-same-as-fg false
dbus-launch gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" font "Monospace 13"
dbus-launch gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" foreground-color "rgb(154,174,177)"
dbus-launch gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" scrollbar-policy "never"
dbus-launch gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" use-system-font false
dbus-launch gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" use-theme-colors false
dbus-launch gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" use-transparent-background true

# Hide Menu bar
dbus-launch gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar false
