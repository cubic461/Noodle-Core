@echo off
setlocal enabledelayedexpansion

title NoodleControl Demo - Complete Application Startup

echo.
echo ===============================================
echo   NoodleControl Demo - Complete Application
echo ===============================================
echo.

REM Get the directory of this batch file
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

REM Display menu options
:MENU
echo.
echo Please select an option:
echo.
echo 1. Start with Local Python (Recommended for development)
echo 2. Start with Docker (Recommended for production)
echo 3. Install Dependencies Only
echo 4. View Application Status
echo 5. Exit
echo.
set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" goto LOCAL_START
if "%choice%"=="2" goto DOCKER_START
if "%choice%"=="3" goto INSTALL_DEPS
if "%choice%"=="4" goto CHECK_STATUS
if "%choice%"=="5" goto EXIT_SCRIPT
goto MENU

:LOCAL_START
echo.
echo Starting NoodleControl Demo with Local Python...
echo.

REM Check if Python is installed and meets version requirement
echo Checking Python installation...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed or not in PATH.
    echo Please install Python 3.9 or higher from https://python.org
    pause
    goto MENU
)

REM Check Python version
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
for /f "tokens=1,2 delims=." %%a in ("%PYTHON_VERSION%") do (
    set MAJOR_VERSION=%%a
    set MINOR_VERSION=%%b
)

if %MAJOR_VERSION% LSS 3 (
    echo ERROR: Python 3.9+ is required. Found version %PYTHON_VERSION%
    pause
    goto MENU
)

if %MAJOR_VERSION% EQU 3 (
    if %MINOR_VERSION% LSS 9 (
        echo ERROR: Python 3.9+ is required. Found version %PYTHON_VERSION%
        pause
        goto MENU
    )
)

echo Python version %PYTHON_VERSION% is OK.

REM Check if pip is available
echo Checking pip installation...
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: pip is not installed or not in PATH.
    pause
    goto MENU
)

for /f "tokens=2" %%i in ('pip --version') do set PIP_VERSION=%%i
echo pip version %PIP_VERSION% is OK.

REM Check if requirements.txt exists
if not exist "requirements.txt" (
    echo ERROR: requirements.txt not found in current directory.
    echo Make sure you're running this script from the demo directory.
    pause
    goto MENU
)

REM Install dependencies
echo.
echo Installing Python dependencies...
pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo ERROR: Failed to install dependencies.
    pause
    goto MENU
)

echo Dependencies installed successfully.

REM Check if API and server files exist
if not exist "api.py" (
    echo ERROR: api.py not found in current directory.
    pause
    goto MENU
)

if not exist "server.py" (
    echo ERROR: server.py not found in current directory.
    pause
    goto MENU
)

REM Start the backend API server
echo.
echo Starting Backend API Server (with WebSocket support)...
echo Backend will be available at: http://localhost:8082
echo WebSocket endpoint: ws://localhost:8082
echo.

REM Set environment variables according to the rules
set NOODLE_ENV=development
set NOODLE_PORT=8082
set DEBUG=1

REM Start the backend in a new window
start "NoodleControl Backend API" cmd /k "title NoodleControl Backend API && echo Starting Backend API Server... && python api.py"

REM Wait a moment for the backend to start
timeout /t 3 /nobreak >nul

REM Start the frontend server
echo.
echo Starting Frontend Server...
echo Frontend will be available at: http://localhost:8081
echo.

REM Check if frontend files exist
if not exist "index.html" (
    echo ERROR: index.html not found in current directory.
    echo Make sure you're running this script from the demo directory.
    pause
    goto MENU
)

REM Start the frontend in a new window with better feedback
start "NoodleControl Frontend" cmd /k "title NoodleControl Frontend Server && echo Starting NoodleControl Frontend Server on port 8081... && echo Server will be available at http://localhost:8081 && echo. && python server.py"

REM Wait a moment for the frontend to start
timeout /t 2 /nobreak >nul

echo.
echo ===============================================
echo   NoodleControl Demo is now running!
echo ===============================================
echo.
echo Frontend: http://localhost:8081
echo Backend API: http://localhost:8082
echo WebSocket: ws://localhost:8082
echo.
echo Press any key to return to the menu...
pause >nul
goto MENU

:DOCKER_START
echo.
echo Starting NoodleControl Demo with Docker...
echo.

REM Check if Docker is running
docker version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not running or not installed.
    echo Please start Docker Desktop or install Docker.
    pause
    goto MENU
)

REM Check if Docker Compose is available
docker-compose version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker Compose is not available.
    echo Please install Docker Compose.
    pause
    goto MENU
)

REM Check if docker-compose.yml exists
if not exist "docker-compose.yml" (
    echo ERROR: docker-compose.yml not found in current directory.
    echo Make sure you're running this script from the demo directory.
    pause
    goto MENU
)

echo Building Docker images...
docker-compose build
if %errorlevel% neq 0 (
    echo ERROR: Failed to build Docker images.
    pause
    goto MENU
)

echo.
echo Starting Docker containers...
docker-compose up -d
if %errorlevel% neq 0 (
    echo ERROR: Failed to start Docker containers.
    pause
    goto MENU
)

echo.
echo ===============================================
echo   NoodleControl Demo is now running with Docker!
echo ===============================================
echo.
echo Frontend: http://localhost:8081
echo Backend API: http://localhost:8082
echo WebSocket: ws://localhost:8082
echo.
echo To stop the containers, run: docker-compose down
echo.
echo Press any key to return to the menu...
pause >nul
goto MENU

:INSTALL_DEPS
echo.
echo Installing Python dependencies only...
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed or not in PATH.
    pause
    goto MENU
)

REM Check if requirements.txt exists
if not exist "requirements.txt" (
    echo ERROR: requirements.txt not found in current directory.
    pause
    goto MENU
)

pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo ERROR: Failed to install dependencies.
    pause
    goto MENU
)

echo Dependencies installed successfully.
echo.
echo Press any key to return to the menu...
pause >nul
goto MENU

:CHECK_STATUS
echo.
echo Checking application status...
echo.

REM Check if local servers are running
echo Checking local servers...
netstat -an | findstr ":8081" >nul
if %errorlevel% equ 0 (
    echo [RUNNING] Frontend server on port 8081
) else (
    echo [STOPPED] Frontend server on port 8081
)

netstat -an | findstr ":8082" >nul
if %errorlevel% equ 0 (
    echo [RUNNING] Backend API server on port 8082
) else (
    echo [STOPPED] Backend API server on port 8082
)

REM Check Docker containers
echo.
echo Checking Docker containers...
docker ps --filter "name=noodle" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>nul
if %errorlevel% neq 0 (
    echo Docker is not running or no noodle containers found.
)

echo.
echo Press any key to return to the menu...
pause >nul
goto MENU

:EXIT_SCRIPT
echo.
echo Thank you for using NoodleControl Demo!
echo.
exit /b 0