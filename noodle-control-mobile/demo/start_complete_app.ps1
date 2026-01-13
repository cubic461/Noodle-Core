# NoodleControl Demo - Complete Application Startup Script for PowerShell

# Set window title
$Host.UI.RawUI.WindowTitle = "NoodleControl Demo - Complete Application"

Write-Host ""
Write-Host "==============================================="
Write-Host "  NoodleControl Demo - Complete Application"
Write-Host "==============================================="
Write-Host ""

# Get the directory of this script
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

# Function to display menu and get user choice
function Show-Menu {
    Write-Host ""
    Write-Host "Please select an option:"
    Write-Host ""
    Write-Host "1. Start with Local Python (Recommended for development)"
    Write-Host "2. Start with Docker (Recommended for production)"
    Write-Host "3. Install Dependencies Only"
    Write-Host "4. View Application Status"
    Write-Host "5. Exit"
    Write-Host ""
    
    $choice = Read-Host "Enter your choice (1-5)"
    return $choice
}

# Function to start with local Python
function Start-LocalPython {
    Write-Host ""
    Write-Host "Starting NoodleControl Demo with Local Python..."
    Write-Host ""
    
    # Check if Python is installed and meets version requirement
    Write-Host "Checking Python installation..."
    try {
        $pythonVersion = python --version 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Python not found"
        }
        
        # Extract version number
        $versionString = $pythonVersion -replace 'Python ', ''
        $versionParts = $versionString -split '\.'
        $majorVersion = [int]$versionParts[0]
        $minorVersion = [int]$versionParts[1]
        
        if ($majorVersion -lt 3 -or ($majorVersion -eq 3 -and $minorVersion -lt 9)) {
            Write-Host "ERROR: Python 3.9+ is required. Found version $versionString" -ForegroundColor Red
            Write-Host "Please install Python 3.9 or higher from https://python.org"
            Read-Host "Press Enter to continue"
            return
        }
        
        Write-Host "Python version $versionString is OK."
    }
    catch {
        Write-Host "ERROR: Python is not installed or not in PATH." -ForegroundColor Red
        Write-Host "Please install Python 3.9 or higher from https://python.org"
        Read-Host "Press Enter to continue"
        return
    }
    
    # Check if pip is available
    Write-Host "Checking pip installation..."
    try {
        $pipVersion = pip --version 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "pip not found"
        }
        
        # Extract version number
        $pipVersionString = ($pipVersion -split ' ')[1]
        Write-Host "pip version $pipVersionString is OK."
    }
    catch {
        Write-Host "ERROR: pip is not installed or not in PATH." -ForegroundColor Red
        Read-Host "Press Enter to continue"
        return
    }
    
    # Check if requirements.txt exists
    if (-not (Test-Path "requirements.txt")) {
        Write-Host "ERROR: requirements.txt not found in current directory." -ForegroundColor Red
        Write-Host "Make sure you're running this script from the demo directory."
        Read-Host "Press Enter to continue"
        return
    }
    
    # Install dependencies
    Write-Host ""
    Write-Host "Installing Python dependencies..."
    pip install -r requirements.txt
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to install dependencies." -ForegroundColor Red
        Read-Host "Press Enter to continue"
        return
    }
    
    Write-Host "Dependencies installed successfully."
    
    # Check if API and server files exist
    if (-not (Test-Path "api.py")) {
        Write-Host "ERROR: api.py not found in current directory." -ForegroundColor Red
        Read-Host "Press Enter to continue"
        return
    }
    
    if (-not (Test-Path "server.py")) {
        Write-Host "ERROR: server.py not found in current directory." -ForegroundColor Red
        Read-Host "Press Enter to continue"
        return
    }
    
    # Start the backend API server
    Write-Host ""
    Write-Host "Starting Backend API Server (with WebSocket support)..."
    Write-Host "Backend will be available at: http://localhost:8082"
    Write-Host "WebSocket endpoint: ws://localhost:8082"
    Write-Host ""
    
    # Set environment variables according to the rules
    $env:NOODLE_ENV = "development"
    $env:NOODLE_PORT = "8082"
    $env:DEBUG = "1"
    
    # Start the backend in a new window
    Start-Process -FilePath "cmd" -ArgumentList "/k", "title NoodleControl Backend API && echo Starting Backend API Server... && python api.py"
    
    # Wait a moment for the backend to start
    Start-Sleep -Seconds 3
    
    # Start the frontend server
    Write-Host ""
    Write-Host "Starting Frontend Server..."
    Write-Host "Frontend will be available at: http://localhost:8081"
    Write-Host ""
    
    # Start the frontend in a new window
    Start-Process -FilePath "cmd" -ArgumentList "/k", "title NoodleControl Frontend && echo Starting Frontend Server... && python server.py"
    
    # Wait a moment for the frontend to start
    Start-Sleep -Seconds 2
    
    Write-Host ""
    Write-Host "==============================================="
    Write-Host "  NoodleControl Demo is now running!"
    Write-Host "==============================================="
    Write-Host ""
    Write-Host "Frontend: http://localhost:8081"
    Write-Host "Backend API: http://localhost:8082"
    Write-Host "WebSocket: ws://localhost:8082"
    Write-Host ""
    Read-Host "Press Enter to return to the menu"
}

# Function to start with Docker
function Start-Docker {
    Write-Host ""
    Write-Host "Starting NoodleControl Demo with Docker..."
    Write-Host ""
    
    # Check if Docker is running
    try {
        docker version 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Docker not running"
        }
    }
    catch {
        Write-Host "ERROR: Docker is not running or not installed." -ForegroundColor Red
        Write-Host "Please start Docker Desktop or install Docker."
        Read-Host "Press Enter to continue"
        return
    }
    
    # Check if Docker Compose is available
    try {
        docker-compose version 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Docker Compose not available"
        }
    }
    catch {
        Write-Host "ERROR: Docker Compose is not available." -ForegroundColor Red
        Write-Host "Please install Docker Compose."
        Read-Host "Press Enter to continue"
        return
    }
    
    # Check if docker-compose.yml exists
    if (-not (Test-Path "docker-compose.yml")) {
        Write-Host "ERROR: docker-compose.yml not found in current directory." -ForegroundColor Red
        Write-Host "Make sure you're running this script from the demo directory."
        Read-Host "Press Enter to continue"
        return
    }
    
    Write-Host "Building Docker images..."
    docker-compose build
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to build Docker images." -ForegroundColor Red
        Read-Host "Press Enter to continue"
        return
    }
    
    Write-Host ""
    Write-Host "Starting Docker containers..."
    docker-compose up -d
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to start Docker containers." -ForegroundColor Red
        Read-Host "Press Enter to continue"
        return
    }
    
    Write-Host ""
    Write-Host "==============================================="
    Write-Host "  NoodleControl Demo is now running with Docker!"
    Write-Host "==============================================="
    Write-Host ""
    Write-Host "Frontend: http://localhost:8081"
    Write-Host "Backend API: http://localhost:8082"
    Write-Host "WebSocket: ws://localhost:8082"
    Write-Host ""
    Write-Host "To stop the containers, run: docker-compose down"
    Write-Host ""
    Read-Host "Press Enter to return to the menu"
}

# Function to install dependencies only
function Install-Dependencies {
    Write-Host ""
    Write-Host "Installing Python dependencies only..."
    Write-Host ""
    
    # Check if Python is installed
    try {
        python --version 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Python not found"
        }
    }
    catch {
        Write-Host "ERROR: Python is not installed or not in PATH." -ForegroundColor Red
        Read-Host "Press Enter to continue"
        return
    }
    
    # Check if requirements.txt exists
    if (-not (Test-Path "requirements.txt")) {
        Write-Host "ERROR: requirements.txt not found in current directory." -ForegroundColor Red
        Read-Host "Press Enter to continue"
        return
    }
    
    pip install -r requirements.txt
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to install dependencies." -ForegroundColor Red
        Read-Host "Press Enter to continue"
        return
    }
    
    Write-Host "Dependencies installed successfully."
    Write-Host ""
    Read-Host "Press Enter to return to the menu"
}

# Function to check application status
function Check-Status {
    Write-Host ""
    Write-Host "Checking application status..."
    Write-Host ""
    
    # Check if local servers are running
    Write-Host "Checking local servers..."
    $frontendPort = ":8081"
    $backendPort = ":8082"
    
    $frontendRunning = Get-NetTCPConnection -LocalPort 8081 -ErrorAction SilentlyContinue
    if ($frontendRunning) {
        Write-Host "[RUNNING] Frontend server on port 8081" -ForegroundColor Green
    } else {
        Write-Host "[STOPPED] Frontend server on port 8081" -ForegroundColor Red
    }
    
    $backendRunning = Get-NetTCPConnection -LocalPort 8082 -ErrorAction SilentlyContinue
    if ($backendRunning) {
        Write-Host "[RUNNING] Backend API server on port 8082" -ForegroundColor Green
    } else {
        Write-Host "[STOPPED] Backend API server on port 8082" -ForegroundColor Red
    }
    
    # Check Docker containers
    Write-Host ""
    Write-Host "Checking Docker containers..."
    try {
        $dockerContainers = docker ps --filter "name=noodle" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host $dockerContainers
        } else {
            Write-Host "Docker is not running or no noodle containers found."
        }
    }
    catch {
        Write-Host "Docker is not running or no noodle containers found."
    }
    
    Write-Host ""
    Read-Host "Press Enter to return to the menu"
}

# Main menu loop
do {
    $choice = Show-Menu
    
    switch ($choice) {
        "1" { Start-LocalPython }
        "2" { Start-Docker }
        "3" { Install-Dependencies }
        "4" { Check-Status }
        "5" { 
            Write-Host ""
            Write-Host "Thank you for using NoodleControl Demo!"
            Write-Host ""
            exit
        }
        default { 
            Write-Host "Invalid choice. Please enter a number between 1 and 5."
            Start-Sleep -Seconds 2
        }
    }
} while ($choice -ne "5")