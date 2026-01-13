@echo off
REM Universal NoodleCore IDE Launcher
REM This script can be placed anywhere and will find NoodleCore automatically

echo ========================================
echo   NoodleCore Universal IDE Launcher
echo ========================================
echo.

REM Try to find NoodleCore installation
SET NOODLECORE_PATH=""

REM Check common installation locations
if exist "C:\Users\%USERNAME%\Noodle\noodle-core" set NOODLECORE_PATH="C:\Users\%USERNAME%\Noodle\noodle-core"
if exist "D:\Noodle\noodle-core" set NOODLECORE_PATH="D:\Noodle\noodle-core"  
if exist "E:\Noodle\noodle-core" set NOODLECORE_PATH="E:\Noodle\noodle-core"
if exist "F:\Noodle\noodle-core" set NOODLECORE_PATH="F:\Noodle\noodle-core"

REM Try current directory first
if exist "START_NOODLECORE_IDE.bat" set NOODLECORE_PATH="."

REM If still not found, ask user
if %NOODLECORE_PATH%=="" (
    echo NoodleCore installation not found automatically.
    echo.
    echo Please enter the full path to your noodle-core folder:
    echo Example: C:\Users\%USERNAME%\Noodle\noodle-core
    echo.
    set /p USER_PATH="Path: "
    if exist "%USER_PATH%" (
        set NOODLECORE_PATH="%USER_PATH%"
    ) else (
        echo ERROR: Path not found: %USER_PATH%
        pause
        exit /b 1
    )
)

echo Found NoodleCore at: %NOODLECORE_PATH%
echo.

REM Check Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.9+ and try again
    pause
    exit /b 1
)

REM Launch the canonical IDE via unified launcher
cd /d %NOODLECORE_PATH%
python src\noodlecore\desktop\ide\launch_native_ide.py

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