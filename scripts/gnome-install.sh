#!/usr/bin/env bash
set -e
set -u

# Load common functions
files=$(dirname $0)/files
source ${files}/support.sh
check_yay

# Base gnome
sudo pacman -S --noconfirm --needed gnome-shell gnome-system-monitor
sudo pacman -S --noconfirm --needed --asdeps gnome-control-center gnome-keyring

# Expanded gnome
sudo pacman -S --noconfirm --needed gnome-shell-extensions gnome-backgrounds gnome-calculator gnome-screenshot gnome-contacts gnome-tweaks gnome-user-docs

# Third party applications
sudo pacman -S --noconfirm --needed gparted baobab evince eog filezilla atom firefox-i18n-en-gb chromium deluge gimp mpv youtube-dl pycharm-community-edition remmina variety kodi git
sudo pacman -S --noconfirm --needed --asdeps dosfstools exfat-utils ntfs-3g xfsprogs polkit gpart ttf-dejavu python2-notify pygtk librsvg freerdp gdb libnfs lsb-release

# Install jdownload download manager
yay -S --noconfirm jdownloader2

# Enable the Avahi daemon
sudo systemctl enable avahi-daemon.service


################
## Extensions ##
################

# Disable gnome unredirect to fix slow video playback problems
yay -S --noconfirm gnome-shell-extension-disable-unredirect
cd /tmp

# Manually install openweather to fix git url before install
yay -G gnome-shell-extension-openweather-git
cd gnome-shell-extension-openweather-git

# Switch from github repo to gitlab repo
sed -i "s|https://github.com/jenslody/gnome|https://gitlab.com/jenslody/gnome|" PKGBUILD
makepkg -si --noconfirm
yay -c --noconfirm
cd ..
rm -rf gnome-shell-extension-openweather-git

# Openweather settings
dbus-launch gsettings set org.gnome.shell.extensions.openweather pressure-unit "kPa"
dbus-launch gsettings set org.gnome.shell.extensions.openweather wind-speed-unit "kph"
dbus-launch gsettings set org.gnome.shell.extensions.openweather unit "celsius"


############
## Themes ##
############

sudo pacman -S --noconfirm --needed adapta-gtk-theme
yay -S --noconfirm numix-square-icon-theme-git

dbus-launch gsettings set org.gnome.shell.extensions.user-theme name "Adapta-Nokto"
dbus-launch gsettings set org.gnome.desktop.interface gtk-theme "Adapta-Nokto"
dbus-launch gsettings set org.gnome.desktop.interface icon-theme "Numix-Square"


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


###############
## GSettings ##
###############

# Settings
dbus-launch gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
dbus-launch gsettings set org.gnome.desktop.interface clock-show-date true
dbus-launch gsettings set org.gnome.desktop.notifications show-in-lock-screen false
dbus-launch gsettings set org.gnome.desktop.datetime automatic-timezone true
dbus-launch gsettings set org.gnome.desktop.screensaver lock-enabled false
dbus-launch gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'ie')]"
dbus-launch gsettings set org.gnome.desktop.privacy remember-recent-files false
dbus-launch gsettings set org.gnome.desktop.privacy remove-old-trash-files true
dbus-launch gsettings set org.gnome.desktop.privacy remove-old-temp-files true
dbus-launch gsettings set org.gnome.desktop.privacy old-files-age 14
dbus-launch gsettings set org.gnome.desktop.session idle-delay 0
dbus-launch gsettings set org.gnome.desktop.wm.preferences action-middle-click-titlebar "minimize"
dbus-launch gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 3600
dbus-launch gsettings set org.gnome.system.location enabled true

# Enable extensions and set favorites
dbus-launch gsettings set org.gnome.shell enabled-extensions "['user-theme@gnome-shell-extensions.gcampax.github.com', 'unredirect@vaina.lt', 'openweather-extension@jenslody.de']"
dbus-launch gsettings set org.gnome.shell favorite-apps "['org.gnome.Terminal.desktop', 'firefox.desktop', 'chromium.desktop', 'org.gnome.Nautilus.desktop', 'pycharm-community-eap.desktop']"


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


#############
## Cleanup ##
#############

yay -c --noconfirm

echo ""
echo "##########################################"
echo "##               All Done               ##"
echo "##########################################"
