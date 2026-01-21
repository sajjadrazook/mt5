#!/bin/bash

cleanup() {
    echo "Shutting down..."
    pkill -f wine
    vncserver -kill :1 2>/dev/null
    pkill websockify
    exit 0
}

trap cleanup SIGINT SIGTERM

echo "=========================================="
echo "   MT5 Docker - Starting Desktop..."
echo "=========================================="

# Set environment
export HOME=/root
export DISPLAY=:1
export WINEPREFIX=/root/.wine
export WINEARCH=win64

# Setup XDG runtime
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

# Remove old VNC locks and sockets
echo "Cleaning up old VNC locks..."
vncserver -kill :1 >/dev/null 2>&1 || true
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1 /root/.vnc/*.pid /root/.vnc/*.log 2>/dev/null
rm -rf "$XDG_RUNTIME_DIR"/*

# Start VNC Server
echo "[1/3] Starting VNC Desktop..."
vncserver :1 -geometry 1280x720 -depth 24 -localhost no
sleep 3

# Start noVNC (Web access)
echo "[2/3] Starting Web VNC..."
websockify --web /usr/share/novnc/ 6080 localhost:5901 &
sleep 2

# Auto-restore from backup if available
echo "[3/4] Checking for backup restore..."
if [ -f /opt/mt5/auto_restore.sh ]; then
    bash /opt/mt5/auto_restore.sh
fi

# Launch MT5
echo "[4/4] Launching MT5..."

# Find existing MT5
MT5_PATH=$(find "$WINEPREFIX/drive_c/Program Files" -name "terminal64.exe" 2>/dev/null | head -1)
if [ -z "$MT5_PATH" ]; then
    MT5_PATH=$(find "$WINEPREFIX/drive_c/Program Files" -name "terminal.exe" 2>/dev/null | head -1)
fi

if [ -n "$MT5_PATH" ]; then
    echo "✅ MT5 found: $MT5_PATH"
    wine "$MT5_PATH" /portable &
else
    echo "⚠️ MT5 not installed. Starting installer..."
    # Initialize Wine first
    wineboot --init
    sleep 5
    # Configure for Windows 10
    wine reg add "HKEY_CURRENT_USER\\Software\\Wine" /v Version /t REG_SZ /d "win10" /f 2>/dev/null
    sleep 2
    # Run installer
    wine /opt/mt5/mt5setup.exe &
fi

echo ""
echo "=========================================="
echo "   Desktop Ready!"
echo "=========================================="
echo "Web VNC: http://your-server:6080"
echo "VNC: your-server:5901"
echo ""

# Keep running
tail -f /dev/null
