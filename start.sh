#!/bin/bash

service dbus start

pulseaudio --start --system --disallow-exit --disable-shm

modprobe fuse 2>/dev/null || echo "FUSE module loading skipped (may not be available in container)"
chmod 666 /dev/fuse 2>/dev/null || echo "FUSE device permissions skipped"

mkdir -p /root/shared-drives
mkdir -p /root/Desktop/PhoneFiles
chmod 755 /root/shared-drives
chmod 755 /root/Desktop/PhoneFiles

cat > /root/Desktop/PhoneFiles.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Phone Shared Files
Comment=Access files from your phone
Exec=thunar /root/shared-drives
Icon=folder-remote
Terminal=false
Categories=Utility;
EOF
chmod +x /root/Desktop/PhoneFiles.desktop

ln -sf /root/shared-drives /root/Desktop/PhoneFiles 2>/dev/null

service xrdp start

mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

tail -f /var/log/xrdp-sesman.log
