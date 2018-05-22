#!/usr/bin/env bash

pacman -S --noconfirm archey3

# Configure archey for root
cat > /root/.config/archey3.cfg <<EOF
[core]
align = center
display_modules = de(), distro(), uname(r), fs(/), ram(), uname(n), packages(), uptime()
EOF

# Configure archey for normal user
cp /root/.config/archey3.cfg /etc/skel/.config/archey3.cfg

cat >> /root/.bashrc <<EOF

# Output system info using archey3 (https://lclarkmichalek.github.io/archey3/)
clear && /usr/bin/archey3 -c red
EOF

cat >> /etc/skel/.bashrc <<EOF

# Output system info using archey3 (https://lclarkmichalek.github.io/archey3/)
[ -r /usr/bin/archey3 ] && clear && /usr/bin/archey3 -c cyan
EOF
