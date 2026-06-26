#!/usr/bin/env bash
set -e

mkdir -p /var/run/dbus /run/dbus /var/run/xrdp /tmp/.X11-unix /var/log
chmod 1777 /tmp/.X11-unix

[ -s /etc/machine-id ] || dbus-uuidgen --ensure=/etc/machine-id
mkdir -p /var/lib/dbus
ln -sf /etc/machine-id /var/lib/dbus/machine-id

dbus-daemon --system --fork

pulseaudio --system --daemonize --disallow-exit --disable-shm --exit-idle-time=-1 || true

if [ -e /dev/fuse ]; then
  chmod 666 /dev/fuse || true
fi

mkdir -p /root/shared-drives /root/Desktop/PhoneFiles
chmod 755 /root/shared-drives /root/Desktop/PhoneFiles

cat > /root/Desktop/PhoneFiles.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Phone Shared Files
Exec=thunar /root/shared-drives
Icon=folder-remote
Terminal=false
Categories=Utility;
EOF
chmod +x /root/Desktop/PhoneFiles.desktop

touch /var/log/xrdp.log /var/log/xrdp-sesman.log

xrdp-sesman --nodaemon &
exec xrdp --nodaemon
