#!/bin/bash
# Script to start JustMarkets MT5 instead of default MT5

# Correct path for JustMarkets in this container
JUSTMARKETS_PATH="/config/.wine/drive_c/Program Files/JustMarkets MetaTrader 5/terminal64.exe"

if [ -f "$JUSTMARKETS_PATH" ]; then
    echo "Starting JustMarkets MetaTrader 5..."
    wine "$JUSTMARKETS_PATH" &
else
    echo "JustMarkets not found at: $JUSTMARKETS_PATH"
    echo "Starting default MT5..."
    wine "/root/.wine/drive_c/Program Files/MetaTrader 5/terminal64.exe" &
fi
