FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386

RUN apt-get update && apt-get install -y --no-install-recommends \
    xrdp \
    xorgxrdp \
    xfce4 \
    xfce4-goodies \
    xorg \
    dbus \
    dbus-x11 \
    xauth \
    sudo \
    curl \
    wget \
    nano \
    net-tools \
    policykit-1 \
    pulseaudio \
    pulseaudio-utils \
    wine \
    wine32 \
    firefox-esr \
    fuse \
    kmod \
    && (apt-get install -y --no-install-recommends pulseaudio-module-xrdp || true) \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo "root:root" | chpasswd

RUN sed -i 's/^allowed_users=.*/allowed_users=anybody/' /etc/X11/Xwrapper.config || \
    echo "allowed_users=anybody" >> /etc/X11/Xwrapper.config

RUN dbus-uuidgen --ensure=/etc/machine-id && \
    mkdir -p /var/lib/dbus && ln -sf /etc/machine-id /var/lib/dbus/machine-id

RUN sed -i 's/crypt_level=high/crypt_level=low/' /etc/xrdp/xrdp.ini && \
    sed -i 's/security_layer=negotiate/security_layer=rdp/' /etc/xrdp/xrdp.ini

# Ensure XRDP actually starts XFCE (proper shell script; fixes many green-screen cases)
RUN cat > /etc/xrdp/startwm.sh <<'EOF' && chmod +x /etc/xrdp/startwm.sh
#!/bin/sh
unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR
exec startxfce4
EOF

RUN echo "startxfce4" > /root/.xsession && chmod 700 /root/.xsession

# Allow root login via XRDP sesman (some builds default to false)
RUN if grep -q '^\[Security\]' /etc/xrdp/sesman.ini; then \
      grep -q '^AllowRootLogin=' /etc/xrdp/sesman.ini && \
      sed -i 's/^AllowRootLogin=.*/AllowRootLogin=true/' /etc/xrdp/sesman.ini || \
      sed -i '/^\[Security\]/a AllowRootLogin=true' /etc/xrdp/sesman.ini ; \
    else \
      printf '\n[Security]\nAllowRootLogin=true\n' >> /etc/xrdp/sesman.ini ; \
    fi

# (Optional) drive redirection config (works only if platform allows /dev/fuse)
RUN sed -i 's/FuseMountName=thinclient_drives/FuseMountName=shared-drives/' /etc/xrdp/sesman.ini || true && \
    grep -q '^\[Chansrv\]' /etc/xrdp/sesman.ini || cat >> /etc/xrdp/sesman.ini <<'EOF'

[Chansrv]
FuseMountName=shared-drives
EnableClipboard=true
EnableFuseMount=true
EOF

RUN mkdir -p /root/shared-drives /root/Desktop/PhoneFiles && chmod 755 /root/shared-drives

RUN adduser xrdp ssl-cert

COPY pulse-client.conf /etc/pulse/client.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
