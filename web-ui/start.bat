@echo off
REM NIP v3.0.0 Web UI - Startup Script for Windows
REM This script activates the virtual environment and starts the Streamlit app

echo ========================================
echo NIP v3.0.0 Web UI
echo ========================================
echo.

REM Check if virtual environment exists
if not exist "venv\" (
    echo Creating virtual environment...
    python -m venv venv
    echo Virtual environment created.
    echo.
)

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Check if requirements are installed
pip show streamlit >nul 2>&1
if errorlevel 1 (
    echo Installing dependencies...
    pip install -r requirements.txt
    echo.
)

REM Check if .env exists
if not exist ".env" (
    echo Creating .env file from template...
    copy env.example .env
    echo WARNING: Please edit .env with your API keys and configuration!
    echo.
)

echo Starting Streamlit application...
echo.
echo The application will open in your browser at:
echo http://localhost:8501
echo.
echo Press Ctrl+C to stop the server
echo ========================================
echo.

REM Start Streamlit
streamlit run app.py

pause
