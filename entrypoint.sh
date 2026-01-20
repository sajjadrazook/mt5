#!/bin/bash

# Function to handle shutdown
cleanup() {
    echo "Shutting down..."
    pkill -f "wine"
    pkill x11vnc
    pkill fluxbox
    pkill Xvfb
    exit
}

trap cleanup SIGINT SIGTERM

echo "=========================================="
echo "   MT5 Docker Container Starting..."
echo "=========================================="

# Clean up any leftover locks
rm -f /tmp/.X0-lock

# Set environment
export WINEPREFIX=/root/.wine
export WINEARCH=win32
export DISPLAY=:0.0

# 1. Start Xvfb (Virtual Framebuffer)
echo "[1/5] Starting Xvfb..."
Xvfb :0 -screen 0 1024x768x24 -maxclients 2048 &
sleep 2

# 2. Start Fluxbox (Window Manager)
echo "[2/5] Starting Fluxbox..."
fluxbox &
sleep 1

# 3. Start x11vnc (VNC Server)
echo "[3/5] Starting x11vnc..."
while true; do
    x11vnc -display :0 -forever -nopw -shared
    sleep 2
done &
sleep 2

# 4. Start websockify (noVNC)
echo "[4/5] Starting noVNC..."
websockify --web /usr/share/novnc/ 6080 localhost:5900 &
sleep 2

# 5. Launch MT5 (pre-installed in image)
echo "[5/5] Launching MT5..."

# Find MT5 executable
MT5_PATH=$(find "$WINEPREFIX/drive_c/Program Files" -name "terminal64.exe" 2>/dev/null | head -1)
if [ -z "$MT5_PATH" ]; then
    MT5_PATH=$(find "$WINEPREFIX/drive_c/Program Files" -name "terminal.exe" 2>/dev/null | head -1)
fi

if [ -n "$MT5_PATH" ]; then
    echo "✅ MT5 found: $MT5_PATH"
    wine "$MT5_PATH" /portable &
else
    echo "⚠️ MT5 not found, launching installer..."
    xterm -geometry 80x24+50+50 -T "MT5 Installer" -e wine /opt/mt5/mt5setup.exe &
fi

echo ""
echo "=========================================="
echo "   Container is running"
echo "=========================================="
echo "Access via: http://your-server:80"
echo ""

# Keep container running
tail -f /dev/null


