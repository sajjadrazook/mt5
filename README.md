# MetaTrader 5 Docker Container

Run MetaTrader 5 inside a Docker container using Ubuntu and Wine, accessible via VNC.

## Prerequisites

- Docker and Docker Compose installed
- A VNC Viewer (e.g., [RealVNC Viewer](https://www.realvnc.com/en/connect/download/viewer/)) for desktop access

## Quick Start

```bash
# Clone the repository
git clone https://github.com/sajjadrazook/mt5.git
cd mt5

# Build and run
docker-compose up --build -d
```

## Access

- **Web VNC**: Open `http://your-server-ip` in your browser
- **VNC Client**: Connect to `your-server-ip:5900`

## First Run

1. Connect via VNC
2. The MT5 installer will launch automatically
3. Follow the installation wizard
4. After installation, MT5 will start automatically on future container starts

## Configuration

The `docker-compose.yml` uses these default settings:
- Port 80 → Web VNC interface
- Port 5900 → VNC protocol

## Notes

- **Wine Version**: Uses Wine 9.0 (stable) to avoid MT5 debugger detection issues
- **Data Persistence**: Use Docker volumes to persist your MT5 data
- **Restart Policy**: Container restarts automatically unless stopped manually

## Updating (Safe Update)

To update the container while **preserving your MT5 data, accounts, and Wine configuration**:

```bash
# Option 1: Use the update script (recommended)
chmod +x update.sh
./update.sh

# Option 2: Manual update
git pull
docker-compose down      # ⚠️ Do NOT use -v flag!
docker-compose build
docker-compose up -d
```

> ⚠️ **IMPORTANT**: Never use `docker-compose down -v` as it deletes all your data!

## Auto-Install & State Transfer

- **Silent Install**: MT5 now installs automatically without asking for confirmation.
- **Sync Your Files**: Put your EAs, Indicators, or Settings in the `my_mt5_files/` folder in this repository. They will be automatically copied to MT5 when the server starts.

## Full State Migration (Local → Server)

To transfer **everything** (Wine, MT5, accounts, settings) from local Docker to server:

### On Local Machine (Windows/WSL):
```bash
# Create backup
chmod +x backup.sh
./backup.sh
```

### Transfer to Server:
```bash
scp backups/mt5_backup_*.tar.gz user@your-server:~/mt5/backups/
```

### On Server:
```bash
cd ~/mt5
chmod +x restore.sh
./restore.sh
```

This will restore your exact MT5 state including:
- ✅ Wine configuration
- ✅ MT5 installation
- ✅ Trading accounts
- ✅ Expert Advisors
- ✅ Indicators & scripts
- ✅ All settings


