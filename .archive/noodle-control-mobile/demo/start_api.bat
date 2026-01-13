@echo off
echo Starting NoodleControl Demo API Server...
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python is not installed or not in PATH
    echo Please install Python 3.9+ and try again
    pause
    exit /b 1
)

REM Check if pip is installed
pip --version >nul 2>&1
if errorlevel 1 (
    echo Error: pip is not installed or not in PATH
    echo Please install pip and try again
    pause
    exit /b 1
)

REM Install dependencies if not already installed
echo Installing dependencies...
pip install -r requirements.txt
if errorlevel 1 (
    echo Error: Failed to install dependencies
    pause
    exit /b 1
)

REM Set environment variables
set NOODLE_ENV=development
set NOODLE_PORT=8080
set DEBUG=1

REM Start the API server
echo.
echo Starting API server on http://localhost:8080
echo Press Ctrl+C to stop the server
echo.
python api.py

pause