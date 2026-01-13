#!/bin/bash
echo "🚀 Starting NoodleCore Native GUI IDE v2.0..."
echo "📂 Current directory: $(pwd)"

# Change to the parent directory of this script
cd "$(dirname "$0")/.."
echo "📁 Working directory: $(pwd)"

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    if ! command -v python &> /dev/null; then
        echo "❌ Python is not installed or not in PATH"
        echo "Please install Python 3.9 or later"
        exit 1
    else
        PYTHON_CMD="python"
    fi
else
    PYTHON_CMD="python3"
fi

echo "🐍 Using Python: $PYTHON_CMD"
$PYTHON_CMD --version

# Launch the IDE
echo "🚀 Launching IDE..."
try {
    $PYTHON_CMD launchers/start_ide.py
} catch {
    echo "❌ Error starting IDE: $_"
    echo "Press Enter to exit"
    read
}