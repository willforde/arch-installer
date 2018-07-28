#!/usr/bin/env bash
set -e
set -u

if [[ $EUID == 0 ]]; then
    echo "This script must be run as a normal user."
    exit 1
fi

set +u
if [[ -z "${DISPLAY}" ]]; then
    echo "This script must be run under a gui windows i.e. no ssh"
    exit 1
fi
set -u

# Install the british version of firefox
sudo pacman -S --noconfirm --needed firefox-i18n-en-gb

set +e
# Start firefox for 3 seconds for it to create a user profile
echo "Starting Firefox if not already runing"
FOUND=$(ps -A | grep "firefox")
if [[ -z "$FOUND" ]]; then
    firefox &
    sleep 3
    FOUND=$(ps -A | grep "firefox")
    if [[ -z "$FOUND" ]]; then
        echo "Unable to find firefox runing process id"
        exit 1
    fi
fi
set -e

# Ready to close firefox
sleep 1
echo "Killing firefox process: $FOUND"
kill ${FOUND}

echo "Searching for firefox profile directory"
PROFILE=$(ls ~/.mozilla/firefox | grep ".default$")
if [[ -z "$PROFILE" ]]; then
    echo "Unable to determine filefox default profile"
    exit 1
fi

echo "Creating custom firefox user preferences file"
cat > ~/.mozilla/firefox/${PROFILE}/user.js <<EOF
// Used to allow use of the middle mouse button for scroling
// Enable "Use autoscrolling"user_pref("general.autoScroll", true);
user_pref("general.autoScroll", true);

// Allow searching by just typing anywhere
// Enable "Search for text when I start typing"
user_pref("accessibility.typeaheadfind", true);

// Disable firefox buildin password manage witch is replaced with lastpass
// Disable "Remember logins for sites"
user_pref("signon.rememberSignons", false);

// Enable to show the tabs from the last firefox session
// Sets "Show my windows and tabs from last time" when firefox starts
user_pref("browser.startup.page", 3);

// Set Home Page
user_pref("browser.startup.homepage", "http://www.google.ie");

// Enable OMTC witch will enable hardware acceleration
user_pref("layers.acceleration.force-enabled", true);

// Enable firefox optional tracking protection
user_pref("privacy.trackingprotection.enabled", true);

// Enable Do Not Track Header
user_pref("privacy.donottrackheader.enabled", true);

// Turn off sponsored content and tiles
user_pref("browser.newtabpage.directory.source", "");
user_pref("browser.newtabpage.directory.ping", "");

// Disable 1024-bit Diffie-Hellman primes
user_pref("security.ssl3.dhe_rsa_aes_128_sha", false);
user_pref("security.ssl3.dhe_rsa_aes_256_sha", false);

// Set Download directory
user_pref("browser.download.dir", "/home/willforde/Downloads/Misc");

// Set process count to 4
user_pref("browser.preferences.defaultPerformanceSettings.enabled", false);
user_pref("dom.ipc.processCount", 7);

// Immediate rendering of pages
user_pref("nglayout.initialpaint.delay", 0);

// Disable Pocket
user_pref("extensions.pocket.enabled", false);

// Remove fullscreen warning
user_pref("full-screen-api.warning.timeout", 0);

// Enable Search bar in toolbar
user_pref("browser.search.widget.inNavBar", true);
EOF

# To relocate the profile and cache to memory, the program psd & asd is required
yay -S --noconfirm profile-sync-daemon anything-sync-daemon

# Create psd config
echo "Creating PSD config file"
mkdir -p ~/.config/psd
cat > ~/.config/psd/psd.conf <<EOF
USE_OVERLAYFS="yes"
BROWSERS="firefox"
USE_BACKUPS="yes"
BACKUP_LIMIT=2
EOF

# Allow current user full sudo access to use psd-overlays without password
echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/psd-overlay-helper" > /tmp/20_psdoverlayfs
sudo -u root cp /tmp/20_psdoverlayfs /etc/sudoers.d/20_psdoverlayfs
rm /tmp/20_psdoverlayfs

# Enable psd as a normal user
systemctl --user enable psd.service
systemctl --user start psd.service

# Change asd config
echo "Modifying ASD config file"
sudo sed -Ei "s|^WHATTOSYNC=\(\)|WHATTOSYNC=\('/home/$USER/.cache/mozilla/firefox/$PROFILE'\)|"  /etc/asd.conf
sudo sed -Ei 's/^#USE_OVERLAYFS="no"/USE_OVERLAYFS="yes"/' /etc/asd.conf
sudo sed -Ei 's/^#USE_BACKUPS=".+"/USE_BACKUPS="yes"/' /etc/asd.conf

# Enable asd
sudo systemctl enable asd.service
sudo systemctl start asd.service
