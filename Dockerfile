FROM ubuntu:24.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Environment variables
ENV WINEPREFIX=/root/.wine
ENV WINEARCH=win32
ENV DISPLAY=:0.0

# Enable 32-bit architecture
RUN dpkg --add-architecture i386

# Install base dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    gnupg2 \
    software-properties-common \
    xvfb \
    x11vnc \
    fluxbox \
    cabextract \
    net-tools \
    xterm \
    novnc \
    websockify \
    && rm -rf /var/lib/apt/lists/*

# Install Wine prerequisites9
RUN apt-get update && apt-get install -y \
    winbind \
    zenity \
    xz-utils \
    dbus-x11 \
    libgl1 \
    libvulkan1 \
    && rm -rf /var/lib/apt/lists/*

# Add WineHQ repository
RUN mkdir -pm755 /etc/apt/keyrings \
    && wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources

# Install specific Wine version (9.0) to avoid MT5 debugger detection
# Newer versions (10.3+) cause "debugger detected" error
RUN apt-get update && apt-get install -y --install-recommends \
    winehq-stable=9.0~noble-1 \
    wine-stable=9.0~noble-1 \
    wine-stable-amd64=9.0~noble-1 \
    wine-stable-i386=9.0~noble-1 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /opt/mt5

# Download official MetaTrader 5 installer from MetaQuotes
RUN wget -O /opt/mt5/mt5setup.exe https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe

# Expose VNC (5900) and Web (6080) ports
EXPOSE 5900 6080

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Start the container
CMD ["/entrypoint.sh"]
