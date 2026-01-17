#!/bin/bash
# NIP v3.0.0 Web UI - Startup Script for Linux/Mac
# This script activates the virtual environment and starts the Streamlit app

echo "========================================"
echo "NIP v3.0.0 Web UI"
echo "========================================"
echo ""

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
    echo "Virtual environment created."
    echo ""
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Check if requirements are installed
if ! pip show streamlit > /dev/null 2>&1; then
    echo "Installing dependencies..."
    pip install -r requirements.txt
    echo ""
fi

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "Creating .env file from template..."
    cp env.example .env
    echo "WARNING: Please edit .env with your API keys and configuration!"
    echo ""
fi

echo "Starting Streamlit application..."
echo ""
echo "The application will open in your browser at:"
echo "http://localhost:8501"
echo ""
echo "Press Ctrl+C to stop the server"
echo "========================================"
echo ""

# Start Streamlit
streamlit run app.py
