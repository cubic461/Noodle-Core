@echo off
echo ========================================
echo   NoodleCore Native GUI IDE Launcher (DEBUG)
echo ========================================
echo.
echo Starting NoodleCore IDE in DEBUG mode...
echo.

REM Navigate to the project directory
cd /d "%~dp0"

REM Check if Python is available
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.9+ and try again
    pause
    exit /b 1
)

REM Launch the canonical IDE via unified launcher in debug mode (relative, portable)
echo Launching NoodleCore Desktop IDE in DEBUG mode (canonical)...
python src\noodlecore\desktop\ide\launch_native_ide.py --debug

REM Check for errors
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Failed to launch NoodleCore IDE
    echo Please check the error messages above
    pause
    exit /b 1
)

echo.
echo NoodleCore IDE closed successfully
pause