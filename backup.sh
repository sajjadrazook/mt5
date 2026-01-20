#!/bin/bash

# MT5 Docker Backup Script
# Creates a complete backup of your MT5 data (Wine, accounts, settings)

set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="mt5_backup_${TIMESTAMP}.tar.gz"
VOLUME_NAME="mt5_mt5_config"

echo "=========================================="
echo "   MT5 Docker Full Backup"
echo "=========================================="
echo ""

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Find the correct volume name
ACTUAL_VOLUME=$(docker volume ls -q | grep -E "mt5.*config" | head -1)
if [ -z "$ACTUAL_VOLUME" ]; then
    echo "❌ Error: No MT5 volume found!"
    echo "Make sure the container has been run at least once."
    exit 1
fi

echo "📦 Found volume: $ACTUAL_VOLUME"
echo ""

# Stop container to ensure data consistency
echo "⏸️  Stopping container for consistent backup..."
docker-compose stop || true
sleep 2

# Create backup using a temporary container
echo "💾 Creating backup..."
docker run --rm \
    -v "$ACTUAL_VOLUME":/data \
    -v "$(pwd)/$BACKUP_DIR":/backup \
    ubuntu:24.04 \
    tar czvf "/backup/$BACKUP_FILE" -C /data .

# Restart container
echo "▶️  Restarting container..."
docker-compose start || true

echo ""
echo "=========================================="
echo "✅ Backup Complete!"
echo "=========================================="
echo ""
echo "📁 Backup file: $BACKUP_DIR/$BACKUP_FILE"
echo "📊 Size: $(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)"
echo ""
echo "📤 To transfer to server:"
echo "   scp $BACKUP_DIR/$BACKUP_FILE user@server:~/mt5/backups/"
echo ""
