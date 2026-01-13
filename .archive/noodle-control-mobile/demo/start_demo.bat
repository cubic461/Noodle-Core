@echo off
echo Starting NoodleControl Mobile App Demo Server...
echo.

REM Change to the demo directory
cd /d "%~dp0"

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed or not in PATH.
    echo Please install Python 3.9 or higher from https://python.org
    pause
    exit /b 1
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
    exit /b 1
)

if %MAJOR_VERSION% EQU 3 (
    if %MINOR_VERSION% LSS 9 (
        echo ERROR: Python 3.9+ is required. Found version %PYTHON_VERSION%
        pause
        exit /b 1
    )
)

echo Python version %PYTHON_VERSION% is OK.

REM Check if server.py exists
if not exist "server.py" (
    echo ERROR: server.py not found in current directory.
    echo Make sure you're running this script from the demo directory.
    pause
    exit /b 1
)

REM Check if index.html exists
if not exist "index.html" (
    echo ERROR: index.html not found in current directory.
    echo Make sure you're running this script from the demo directory.
    pause
    exit /b 1
)

REM Start the Python HTTP server in a new window
echo Starting frontend server on port 8081...
start "NoodleControl Demo Server" cmd /k "title NoodleControl Frontend Server && echo Starting NoodleControl Frontend Server... && python server.py"

echo.
echo The demo server is starting in a new window.
echo Once the server is running, you can access the demo at:
echo http://localhost:8081
echo.
echo To stop the server, close the server window or press Ctrl+C in that window.
echo.
pause