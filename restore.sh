#!/bin/bash

# MT5 Docker Restore Script
# Restores a complete backup of MT5 data (Wine, accounts, settings)

set -e

BACKUP_DIR="./backups"

echo "=========================================="
echo "   MT5 Docker Full Restore"
echo "=========================================="
echo ""

# Check for backup files
if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Error: Backup directory not found!"
    echo "Create a 'backups' folder and place your backup file there."
    exit 1
fi

# List available backups
echo "📋 Available backups:"
ls -lh "$BACKUP_DIR"/*.tar.gz 2>/dev/null || {
    echo "❌ No backup files found in $BACKUP_DIR/"
    exit 1
}
echo ""

# Get the latest backup or ask user
LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | head -1)
echo "🔹 Latest backup: $(basename "$LATEST_BACKUP")"
echo ""

read -p "Use this backup? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Enter backup filename (from backups folder):"
    read BACKUP_NAME
    LATEST_BACKUP="$BACKUP_DIR/$BACKUP_NAME"
fi

if [ ! -f "$LATEST_BACKUP" ]; then
    echo "❌ Error: Backup file not found: $LATEST_BACKUP"
    exit 1
fi

# Find or create the volume
ACTUAL_VOLUME=$(docker volume ls -q | grep -E "mt5.*config" | head -1)
if [ -z "$ACTUAL_VOLUME" ]; then
    echo "📦 Creating new volume..."
    docker-compose up -d
    sleep 5
    docker-compose stop
    ACTUAL_VOLUME=$(docker volume ls -q | grep -E "mt5.*config" | head -1)
fi

echo "📦 Target volume: $ACTUAL_VOLUME"
echo ""

# Stop container
echo "⏸️  Stopping container..."
docker-compose stop || true
sleep 2

# Clear existing data and restore
echo "🔄 Restoring data..."
docker run --rm \
    -v "$ACTUAL_VOLUME":/data \
    -v "$(pwd)/$BACKUP_DIR":/backup \
    ubuntu:24.04 \
    bash -c "rm -rf /data/* /data/..?* /data/.[!.]* 2>/dev/null; tar xzvf /backup/$(basename "$LATEST_BACKUP") -C /data"

# Start container
echo "▶️  Starting container..."
docker-compose up -d

echo ""
echo "=========================================="
echo "✅ Restore Complete!"
echo "=========================================="
echo ""
echo "Your MT5 installation, accounts, and settings have been restored."
echo "Access MT5 at: http://$(hostname -I 2>/dev/null | awk '{print $1}' || echo 'your-server-ip'):80"
echo ""
