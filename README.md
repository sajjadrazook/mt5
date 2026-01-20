# MetaTrader 5 on Ubuntu 25.10 Docker

This project runs MetaTrader 5 inside a Docker container using the latest Ubuntu 25.10 and Wine.

## Prerequisites

- Docker Desktop installed.
- A VNC Viewer (e.g., [RealVNC Viewer](https://www.realvnc.com/en/connect/download/viewer/) or [TightVNC](https://www.tightvnc.com/)).

- A VNC Viewer (e.g., [RealVNC Viewer](https://www.realvnc.com/en/connect/download/viewer/) or [TightVNC](https://www.tightvnc.com/)).
- **Important**: This repo includes `justmarkets5setup.exe` which is required for the Docker build. If you clone this repo, ensure this file is present or download the MT5 installer for your broker and rename/update the Dockerfile accordingly.

## Security Note

The `docker-compose.yml` file contains default credentials (`admin`/`admin123`) for the VNC/Web interface. **Please change these before deploying to a public environment.**

## How to Run

1.  Open a terminal in this directory.
2.  Run the following command to build and start the container:
    ```bash
    docker-compose up --build -d
    ```

3.  Wait a few seconds for the container to start and initialize services.

## How to Access

1.  Open your VNC Viewer.
2.  Connect to: `localhost:5900`
3.  You should see the Ubuntu desktop environment (Fluxbox).
4.  **First Run**: You will see the MT5 Installer. Click "Next", agree to terms, and "Finish" to install.
5.  After installation, MT5 should launch automatically.

## Notes

- **Ubuntu Version**: This setup uses Ubuntu 25.10 (Questing Quokka).
- **Data Persistence**: The folder `mt5_data` in your project directory stores the Wine C: drive. Your charts, EAs, and login sessions are saved here.
- **Restarting**: To stop, run `docker-compose down`. To start again, run `docker-compose up -d`. MT5 will launch automatically if installed.
