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

# 1. Start Xvfb (Virtual Framebuffer)
echo "[1/6] Starting Xvfb..."
Xvfb :0 -screen 0 1024x768x24 -maxclients 2048 &
sleep 2

# 2. Start Fluxbox (Window Manager)
echo "[2/6] Starting Fluxbox..."
fluxbox &
sleep 1

# 3. Start x11vnc (VNC Server) with auto-restart
echo "[3/6] Starting x11vnc..."
while true; do
    x11vnc -display :0 -forever -nopw -shared
    echo "x11vnc crashed, restarting..."
    sleep 2
done &
sleep 2

# 4. Start websockify (noVNC)
echo "[4/6] Starting noVNC (Web Terminal)..."
websockify --web /usr/share/novnc/ 6080 localhost:5900 &
sleep 2

# Set up Wine environment
export WINEPREFIX=/config/.wine
export WINEARCH=win32
export TMPDIR=/run/wine
export XDG_RUNTIME_DIR=/run/wine

# Fix permissions
chmod 1777 /tmp
mkdir -p /run/wine
chmod 1777 /run/wine
rm -rf /tmp/.wine-* /tmp/wine-* 2>/dev/null
wineserver -k 2>/dev/null || true

# 5. Initialize Wine and Install/Launch MT5
echo "[5/6] Checking MT5 installation..."

# Search for existing MT5 installation
MT5_PATH=$(find "$WINEPREFIX/drive_c/Program Files" -name "terminal64.exe" -o -name "terminal.exe" 2>/dev/null | head -1)

if [ -n "$MT5_PATH" ]; then
    echo "✅ MT5 found at: $MT5_PATH"
    echo "[6/6] Launching MT5..."
    wine "$MT5_PATH" /portable &
else
    echo "⚠️ MT5 not installed. Starting installation..."
    
    # Show status in xterm so user can see progress
    xterm -geometry 100x30+50+50 -bg black -fg green -T "MT5 Installation Status" -e bash -c '
        echo "=========================================="
        echo "   MT5 INSTALLATION IN PROGRESS"
        echo "=========================================="
        echo ""
        echo "Please wait... This may take 3-5 minutes."
        echo ""
        
        export WINEPREFIX=/config/.wine
        export WINEARCH=win32
        export TMPDIR=/run/wine
        export XDG_RUNTIME_DIR=/run/wine
        export DISPLAY=:0.0
        
        # Initialize Wine
        echo "[1/3] Initializing Wine..."
        wineboot --init 2>&1 | tail -5
        sleep 5
        
        # Configure Wine for Windows 10
        echo "[2/3] Configuring Wine for Windows 10..."
        wine reg add "HKEY_CURRENT_USER\\Software\\Wine" /v Version /t REG_SZ /d "win10" /f 2>/dev/null
        wine reg add "HKEY_LOCAL_MACHINE\\Software\\Wine" /v Version /t REG_SZ /d "win10" /f 2>/dev/null
        sleep 2
        
        # Run installer
        echo "[3/3] Running MT5 installer..."
        echo ""
        wine /opt/mt5/mt5setup.exe /auto
        
        # Wait for installation
        echo ""
        echo "Waiting for installation to complete..."
        for i in {1..60}; do
            MT5=$(find /config/.wine/drive_c/Program\ Files -name "terminal*.exe" 2>/dev/null | head -1)
            if [ -n "$MT5" ]; then
                echo ""
                echo "✅ Installation complete!"
                echo "Launching MT5..."
                wine "$MT5" /portable &
                break
            fi
            echo -n "."
            sleep 2
        done
        
        echo ""
        echo "Press Enter to close this window..."
        read
    ' &
fi

# Keep container running
echo ""
echo "=========================================="
echo "   Container is running"
echo "=========================================="
echo "Access via: http://your-server:80"
echo ""

tail -f /dev/null

