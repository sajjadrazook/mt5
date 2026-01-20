FROM ubuntu:24.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Environment variables
ENV WINEPREFIX=/root/.wine
ENV WINEARCH=win32
ENV DISPLAY=:99

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

# Install Wine prerequisites
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

# Install Wine stable
RUN apt-get update && apt-get install -y --install-recommends \
    winehq-stable \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /opt/mt5

# Download official MetaTrader 5 installer
RUN wget -O /opt/mt5/mt5setup.exe https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe

# ============================================
# PRE-INSTALL WINE AND MT5 DURING BUILD
# This makes the image ready to use immediately
# ============================================

# Start virtual display for Wine initialization
RUN Xvfb :99 -screen 0 1024x768x24 & \
    sleep 2 && \
    # Initialize Wine
    wineboot --init && \
    sleep 10 && \
    # Configure Wine for Windows 10
    wine reg add "HKEY_CURRENT_USER\\Software\\Wine" /v Version /t REG_SZ /d "win10" /f && \
    wine reg add "HKEY_LOCAL_MACHINE\\Software\\Wine" /v Version /t REG_SZ /d "win10" /f && \
    sleep 2 && \
    # Install MT5 silently
    wine /opt/mt5/mt5setup.exe /auto && \
    sleep 30 && \
    # Wait for installation to complete
    for i in 1 2 3 4 5 6 7 8 9 10; do \
    if find /root/.wine/drive_c -name "terminal*.exe" 2>/dev/null | grep -q .; then \
    echo "MT5 installed successfully!"; \
    break; \
    fi; \
    sleep 5; \
    done && \
    # Kill wine processes
    wineserver -k || true && \
    pkill -9 Xvfb || true

# Copy local user files (EAs, indicators, settings)
COPY my_mt5_files /opt/mt5/my_mt5_files

# Expose VNC (5900) and Web (6080) ports
EXPOSE 5900 6080

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Start the container
CMD ["/entrypoint.sh"]

