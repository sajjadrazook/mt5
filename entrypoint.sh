#!/bin/bash

# Function to handle shutdown
cleanup() {
    echo "Shutting down..."
    # Kill processes in reverse order of start
    pkill -f "wine"
    pkill x11vnc
    pkill fluxbox
    pkill Xvfb
    exit
}

trap cleanup SIGINT SIGTERM

echo "Starting MT5 Docker Container (Ubuntu 25.10)..."

# Clean up any leftover locks
rm -f /tmp/.X0-lock

# 1. Start Xvfb (Virtual Framebuffer)
echo "Starting Xvfb..."
Xvfb :0 -screen 0 1024x768x24 -maxclients 2048 &
sleep 2

# 2. Start Fluxbox (Window Manager)
echo "Starting Fluxbox..."
fluxbox &
sleep 1

# 3. Start x11vnc (VNC Server)
echo "Starting x11vnc..."
# 3. Start x11vnc (VNC Server) in a loop
echo "Starting x11vnc..."
while true; do
    x11vnc -display :0 -forever -nopw -shared
    echo "x11vnc crashed, restarting in 2 seconds..."
    sleep 2
done &

sleep 2

# 3.5 Start websockify (noVNC)
echo "Starting noVNC (Web Terminal)..."
# Using the standard novnc launch script or websockify directly
websockify --web /usr/share/novnc/ 6080 localhost:5900 &

sleep 2

# Verify installer existence
INSTALLER_PATH="/opt/mt5/mt5setup.exe"
if [ ! -f "$INSTALLER_PATH" ]; then
    echo "CRITICAL: MT5 installer missing!"
    echo "The installer should have been downloaded during build."
    exit 1
fi

# 3.8 Launch a terminal for debugging
echo "Starting xterm..."
xterm -geometry 120x40+50+50 -bg black -fg white &
sleep 1

# 4. Initialize Wine (critical step)
echo "Initializing Wine configuration..."

# Fix /tmp permissions and clean stale wine server files
chmod 1777 /tmp
rm -rf /tmp/.wine-* /tmp/wine-*
wineserver -k 2>/dev/null || true
sleep 1

# Workaround for Docker Desktop for Windows: Use alternative socket directory
# The /tmp directory on Docker Desktop + WSL2 has issues with Unix sockets
mkdir -p /run/wine
chmod 1777 /run/wine
export TMPDIR=/run/wine
export XDG_RUNTIME_DIR=/run/wine

# Set WINEPREFIX explicitly and initialize (32-bit for MT5 compatibility)
export WINEPREFIX=/root/.wine
export WINEARCH=win32
wineboot --init 2>/dev/null
# Wait for wineserver to settle
sleep 5

# Configure Wine for Windows 10 (required for modern MT5)
echo "Configuring Wine for Windows 10..."
wine reg add "HKEY_CURRENT_USER\\Software\\Wine" /v Version /t REG_SZ /d "win10" /f 2>/dev/null
wine reg add "HKEY_LOCAL_MACHINE\\Software\\Wine" /v Version /t REG_SZ /d "win10" /f 2>/dev/null
wine reg add "HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Control\\ProductOptions" /v ProductType /t REG_SZ /d "WinNT" /f 2>/dev/null
sleep 2

# 5. Run MT5 or Installer
# Search for terminal.exe (32-bit) as directory name varies by broker
MT5_PATH=$(find "$WINEPREFIX/drive_c/Program Files" -name "terminal.exe" -print -quit 2>/dev/null)

if [ -n "$MT5_PATH" ]; then
    echo "MT5 found at: $MT5_PATH"
    echo "Launching..."
    wine "$MT5_PATH" /portable &
else
    echo "MT5 not installed."
    echo "Launching Custom Installer..."
    echo "PLEASE CONNECT VIA VNC (localhost:5900) TO INSTALL."
    wine "$INSTALLER_PATH" &
fi

# Keep container running
tail -f /dev/null
