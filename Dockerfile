FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      xrdp \
      xfce4 \
      xfce4-goodies \
      xorg \
      dbus \
      dbus-x11 \
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

RUN echo "startxfce4" > /root/.xsession && chmod 700 /root/.xsession

RUN dbus-uuidgen --ensure=/etc/machine-id && \
    mkdir -p /var/lib/dbus && ln -sf /etc/machine-id /var/lib/dbus/machine-id

RUN sed -i 's/crypt_level=high/crypt_level=low/' /etc/xrdp/xrdp.ini && \
    sed -i 's/security_layer=negotiate/security_layer=rdp/' /etc/xrdp/xrdp.ini

RUN printf '%s\n' '#!/bin/sh' 'exec startxfce4' > /etc/xrdp/startwm.sh && \
    chmod +x /etc/xrdp/startwm.sh

RUN sed -i 's/FuseMountName=thinclient_drives/FuseMountName=shared-drives/' /etc/xrdp/sesman.ini || true && \
    grep -q '^\[Chansrv\]' /etc/xrdp/sesman.ini || cat >> /etc/xrdp/sesman.ini <<'EOF'

[Chansrv]
FuseMountName=shared-drives
EnableClipboard=true
EnableFuseMount=true
EOF

RUN mkdir -p /root/shared-drives /root/Desktop/PhoneFiles && \
    chmod 755 /root/shared-drives

RUN adduser xrdp ssl-cert

COPY pulse-client.conf /etc/pulse/client.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
