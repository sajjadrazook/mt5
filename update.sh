#!/bin/bash

# MT5 Docker Update Script
# This script updates the container while preserving all data (Wine, MT5 accounts, settings)

set -e

echo "=========================================="
echo "   MT5 Docker Safe Update Script"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if docker-compose exists
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Error: docker-compose is not installed${NC}"
    exit 1
fi

# Step 1: Check current volume status
echo -e "${YELLOW}[1/5] Checking data volume...${NC}"
VOLUME_NAME=$(docker volume ls -q | grep mt5 || true)
if [ -n "$VOLUME_NAME" ]; then
    echo -e "${GREEN}✓ Found volume: $VOLUME_NAME (your data is safe)${NC}"
else
    echo -e "${YELLOW}⚠ No MT5 volume found. This might be a fresh install.${NC}"
fi
echo ""

# Step 2: Pull latest code from GitHub
echo -e "${YELLOW}[2/5] Pulling latest updates from GitHub...${NC}"
git pull origin main || git pull origin master || echo "Git pull skipped (not a git repo or no remote)"
echo ""

# Step 3: Stop container (WITHOUT removing volumes!)
echo -e "${YELLOW}[3/5] Stopping current container...${NC}"
docker-compose down
echo -e "${GREEN}✓ Container stopped (volumes preserved)${NC}"
echo ""

# Step 4: Rebuild image
echo -e "${YELLOW}[4/5] Rebuilding Docker image...${NC}"
docker-compose build
echo -e "${GREEN}✓ Image rebuilt${NC}"
echo ""

# Step 5: Start container
echo -e "${YELLOW}[5/5] Starting container...${NC}"
docker-compose up -d
echo -e "${GREEN}✓ Container started${NC}"
echo ""

# Final status
echo "=========================================="
echo -e "${GREEN}   Update Complete!${NC}"
echo "=========================================="
echo ""
echo "Your MT5 data, accounts, and Wine configuration are preserved."
echo ""
echo "Access MT5 at: http://$(hostname -I | awk '{print $1}'):80"
echo "VNC port: 5900"
echo ""
echo "To view logs: docker-compose logs -f"
