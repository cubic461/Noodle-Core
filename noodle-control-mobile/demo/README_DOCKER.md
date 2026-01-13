# NoodleControl Demo - Docker Deployment

This document provides instructions for running the NoodleControl demo application using Docker containers.

**For a complete overview of the demo application, see the main [README.md](README.md).**

## Additional Documentation

- [DEVELOPMENT.md](DEVELOPMENT.md) - Development setup and guidelines
- [DEPLOYMENT.md](DEPLOYMENT.md) - Comprehensive deployment instructions
- [README_API.md](README_API.md) - API documentation
- [CHANGELOG.md](CHANGELOG.md) - Version history

## Overview

The Docker deployment solution consists of:
- **Frontend Container**: Nginx server serving the static HTML/CSS/JS files on port 8081
- **Backend Container**: Python Flask API with WebSocket support on port 8082
- **Docker Compose**: Orchestrates both containers with proper networking

## Prerequisites

- Docker Desktop installed and running
- Docker Compose (included with Docker Desktop)

## Quick Start

1. Open a command prompt or terminal
2. Navigate to the demo directory:
   ```
   cd noodle_control_mobile_app/demo
   ```
3. Run one of the start scripts:

   For PowerShell users:
   ```powershell
   .\start_complete_app.ps1
   ```
   Then select option 2 from the menu.

   For Command Prompt users:
   ```
   start_complete_app.bat
   ```
   Then select option 2 from the menu.

   Or use the Docker-specific script:
   ```
   start_docker.bat
   ```
   
   The scripts will:
   - Check if Docker is running
   - Build the Docker images
   - Start the containers
   - Display the URLs for accessing the application

4. Open your browser and navigate to:
   - Frontend: http://localhost:8081
   - Backend API: http://localhost:8082
   - WebSocket Test: http://localhost:8081/websocket_test.html

5. Press any key in the terminal to stop the containers

## Manual Docker Commands

If you prefer to run Docker commands manually:

### Build and Start Containers
```bash
# Build the images
docker-compose build

# Start the containers in detached mode
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the containers
docker-compose down
```

### Individual Container Management
```bash
# View running containers
docker-compose ps

# Restart a specific service
docker-compose restart frontend
docker-compose restart backend

# View logs for a specific service
docker-compose logs frontend
docker-compose logs backend
```

## Architecture

### Frontend Container
- Based on nginx:alpine
- Serves static files from /usr/share/nginx/html
- Configured with CORS headers for API requests
- Listens on port 8081

### Backend Container
- Based on Python 3.9-slim
- Runs the Flask API with WebSocket support
- Health check endpoint at /api/health
- Listens on port 8082
- Non-root user for security

### Networking
- Containers communicate through a Docker bridge network
- Frontend can access backend at http://backend:8082
- Host can access both services through exposed ports

## Configuration

### Environment Variables
- `NOODLE_ENV`: Set to 'production' for the backend container
- `NOODLE_PORT`: Set to 8082 for the backend container
- `DEBUG`: Set to 0 for production mode

### Ports
- Frontend: 8081 (host) → 8081 (container)
- Backend: 8082 (host) → 8082 (container)

## Troubleshooting

### Port Conflicts
If ports 8081 or 8082 are already in use, you can change them in the docker-compose.yml file:
```yaml
ports:
  - "8081:8081"  # Change to "8083:8081" for example
```

### Connection Issues
1. Verify both containers are running: `docker-compose ps`
2. Check container logs: `docker-compose logs`
3. Ensure the backend container is healthy: `docker-compose ps`

### Rebuilding Containers
If you make changes to the application code:
```bash
# Stop containers
docker-compose down

# Rebuild with no cache
docker-compose build --no-cache

# Start containers
docker-compose up -d
```

## Development vs Production

### Development Mode
For development with hot reloading, use the original start scripts:
- `start_demo.bat` or `start_demo_port8081.bat`
- Or use `start_complete_app.ps1` (PowerShell) or `start_complete_app.bat` (Command Prompt) and select option 1

### Production Mode
For production or demonstration, use the Docker deployment:
- `start_docker.bat`
- Or use `start_complete_app.ps1` (PowerShell) or `start_complete_app.bat` (Command Prompt) and select option 2

The Docker deployment provides:
- Isolated environment
- Consistent runtime
- Easy distribution
- No dependency installation

## Files

- `Dockerfile.frontend`: Defines the frontend nginx container
- `Dockerfile.backend`: Defines the backend Python container
- `docker-compose.yml`: Orchestrates the containers
- `start_docker.bat`: Windows batch script to build and run
- `start_complete_app.bat`: Windows batch script with menu options
- `start_complete_app.ps1`: PowerShell script with menu options
- `script.js`: Modified to work with Docker environment
- `websocket_test.html`: Modified to work with Docker environment

## Security Considerations

- Non-root user in backend container
- Minimal base images
- Health checks for monitoring
- CORS properly configured

## Performance

- Nginx serves static files efficiently
- Backend container uses Python 3.9 for performance
- WebSocket connections handled natively by Flask-SocketIO
- Resource limits can be set in docker-compose.yml if needed