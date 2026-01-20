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
