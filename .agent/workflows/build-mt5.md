---
description: Build and run MT5 Docker container with Wine
---

# Build and Run MT5 Docker Container

## Prerequisites
- Docker Desktop installed and running
- `justmarkets5setup.exe` file in the project folder

## Steps

// turbo-all

1. Navigate to the MT5 project folder:
```powershell
cd C:\Users\sajja\Documents\mt5
```

2. Stop any running containers:
```powershell
docker-compose down
```

3. Build the container (first time or after changes):
```powershell
docker-compose build --no-cache
```

4. Start the container:
```powershell
docker-compose up -d
```

5. Open VNC in browser:
   - Navigate to: `http://localhost:6080/vnc_lite.html`
   - Click "Connect"

6. Complete MT5 installation via VNC:
   - The installer should launch automatically
   - Click "Next" and follow the wizard
   - If "Debugger detected" error appears, the 32-bit Wine fix should resolve it

## Troubleshooting

### "Debugger detected" error
This is fixed by using 32-bit Wine (`WINEARCH=win32` in Dockerfile).
The current configuration already includes this fix.

### Container won't start
```powershell
docker logs mt5_container
```

### Reset everything
```powershell
docker-compose down -v
docker system prune -f
docker-compose build --no-cache
docker-compose up -d
```
