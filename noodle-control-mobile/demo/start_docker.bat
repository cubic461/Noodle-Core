@echo off
echo Starting NoodleControl Demo with Docker...
echo.

REM Check if Docker is running
docker version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Docker is not running or not installed.
    echo Please start Docker Desktop or install Docker.
    pause
    exit /b 1
)

REM Check if Docker Compose is available
docker-compose version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Docker Compose is not available.
    echo Please install Docker Compose.
    pause
    exit /b 1
)

echo Building Docker images...
docker-compose build

if %errorlevel% neq 0 (
    echo Error: Failed to build Docker images.
    pause
    exit /b 1
)

echo.
echo Starting Docker containers...
docker-compose up -d

if %errorlevel% neq 0 (
    echo Error: Failed to start Docker containers.
    pause
    exit /b 1
)

echo.
echo NoodleControl Demo is starting...
echo.
echo Frontend will be available at: http://localhost:8081
echo Backend API will be available at: http://localhost:8082
echo WebSocket endpoint: ws://localhost:8082
echo.
echo Press Ctrl+C to stop the containers.
echo.

REM Wait for user input to stop containers
pause

echo.
echo Stopping Docker containers...
docker-compose down

echo.
echo NoodleControl Demo stopped.
pause