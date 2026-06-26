FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386

RUN apt update && apt install -y \
    xrdp \
    xfce4 \
    xfce4-goodies \
    xorg \
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
    fusermount \
    xrdp-pulseaudio-installer && \
    apt clean && rm -rf /var/lib/apt/lists/*

RUN echo "root:root" | chpasswd

RUN sed -i 's/^allowed_users=.*/allowed_users=anybody/' /etc/X11/Xwrapper.config || echo "allowed_users=anybody" >> /etc/X11/Xwrapper.config

RUN echo "startxfce4" > /root/.xsession && chmod 700 /root/.xsession

RUN mkdir -p /var/run/dbus && dbus-uuidgen > /var/lib/dbus/machine-id

RUN sed -i 's/crypt_level=high/crypt_level=low/' /etc/xrdp/xrdp.ini && \
    sed -i 's/security_layer=negotiate/security_layer=rdp/' /etc/xrdp/xrdp.ini && \
    echo "exec startxfce4" > /etc/xrdp/startwm.sh && chmod +x /etc/xrdp/startwm.sh

RUN sed -i 's/FuseMountName=thinclient_drives/FuseMountName=shared-drives/' /etc/xrdp/sesman.ini || \
    echo -e "\n[ChansrvLogging]\nLogFile=chansrv.log\nLogLevel=DEBUG\n\n[Chansrv]\nFuseMountName=shared-drives\nEnableClipboard=true\nEnableFuseMount=true" >> /etc/xrdp/sesman.ini

RUN mkdir -p /root/shared-drives && \
    mkdir -p /root/Desktop/PhoneFiles && \
    chmod 755 /root/shared-drives

RUN adduser xrdp ssl-cert

COPY pulse-client.conf /etc/pulse/client.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
