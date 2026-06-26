#!/bin/bash

# Start dbus
service dbus start

# Start PulseAudio
pulseaudio --start --system --disallow-exit --disable-shm

# Enable FUSE for drive redirection
modprobe fuse 2>/dev/null || echo "FUSE module loading skipped (may not be available in container)"
chmod 666 /dev/fuse 2>/dev/null || echo "FUSE device permissions skipped"

# Create shared directories
mkdir -p /root/shared-drives
mkdir -p /root/Desktop/PhoneFiles
chmod 755 /root/shared-drives
chmod 755 /root/Desktop/PhoneFiles

# Create a desktop shortcut to shared drives
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

# Create symbolic link on desktop
ln -sf /root/shared-drives /root/Desktop/PhoneFiles 2>/dev/null

# Create README in shared folder
cat > /root/Desktop/README-FileSharing.txt << 'EOF'
=== RDP FILE SHARING INSTRUCTIONS ===

To share files from your Android phone:

1. Open your RDP app (like Microsoft Remote Desktop or aRDP)
2. Edit your connection settings
3. Enable "Local Storage" or "Redirect Local Storage" option
4. Connect to this desktop
5. Your phone's storage will appear in:
   - /root/shared-drives/
   - Desktop shortcut: "Phone Shared Files"

You can now:
- Copy files from phone to desktop
- Copy files from desktop to phone
- Access your phone's folders directly

Supported Android RDP Apps:
- Microsoft Remote Desktop
- aRDP Pro
- RD Client

Note: Make sure to enable storage permissions in your RDP app!
EOF

# Start XRDP
service xrdp start

mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

echo "======================================"
echo "XRDP Server with File Sharing Ready!"
echo "======================================"
echo "RDP Port: 3389"
echo "Username: root"
echo "Password: root"
echo "Shared Folder: /root/Desktop/PhoneFiles"
echo "======================================"

# Keep container running and show logs
tail -f /var/log/xrdp-sesman.log
