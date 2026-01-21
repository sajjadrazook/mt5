FROM ubuntu:24.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root

# Environment variables for display
ENV DISPLAY=:1
ENV VNC_PORT=5901
ENV VNC_PORT=5901
ENV VNC_PORT=5901
ENV NO_VNC_PORT=6080
ENV XDG_RUNTIME_DIR=/tmp/runtime-root
ENV USER=root

# Enable 32-bit architecture
RUN dpkg --add-architecture i386

# Install desktop environment and VNC
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    gnupg2 \
    software-properties-common \
    # Desktop environment
    xfce4 \
    xfce4-terminal \
    dbus-x11 \
    # VNC
    tigervnc-standalone-server \
    tigervnc-common \
    novnc \
    websockify \
    # Wine dependencies
    cabextract \
    winbind \
    zenity \
    xz-utils \
    libgl1 \
    libvulkan1 \
    && rm -rf /var/lib/apt/lists/*

# Add WineHQ repository
RUN mkdir -pm755 /etc/apt/keyrings \
    && wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources

# Install Wine stable
RUN apt-get update && apt-get install -y --install-recommends \
    winehq-stable \
    && rm -rf /var/lib/apt/lists/*

# Set up VNC
RUN mkdir -p /root/.vnc && \
    echo "#!/bin/bash" > /root/.vnc/xstartup && \
    echo "unset SESSION_MANAGER" >> /root/.vnc/xstartup && \
    echo "unset DBUS_SESSION_BUS_ADDRESS" >> /root/.vnc/xstartup && \
    echo "startxfce4" >> /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Set VNC password (empty for no password)
RUN echo "" | vncpasswd -f > /root/.vnc/passwd && chmod 600 /root/.vnc/passwd

# Wine environment
ENV WINEPREFIX=/root/.wine
ENV WINEARCH=win64

# Download MT5 installer
WORKDIR /opt/mt5
RUN wget -O /opt/mt5/mt5setup.exe https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe

# Copy user files
COPY my_mt5_files /opt/mt5/my_mt5_files

# Copy auto-restore scripts and config
COPY config.env /opt/mt5/config.env
COPY auto_restore.sh /opt/mt5/auto_restore.sh
RUN sed -i 's/\r$//' /opt/mt5/auto_restore.sh && chmod +x /opt/mt5/auto_restore.sh
RUN sed -i 's/\r$//' /opt/mt5/config.env

# Create backups directory (for local backup files)
COPY backups /opt/mt5/backups

# Expose ports
EXPOSE 5901 6080

# Copy and setup entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
