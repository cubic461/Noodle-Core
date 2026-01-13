# NoodleCore Native GUI IDE PowerShell Launcher
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  NoodleCore Native GUI IDE Launcher" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Starting NoodleCore IDE..." -ForegroundColor Green
Write-Host ""

# Navigate to the script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

# Check if Python is available
try {
    $pythonVersion = python --version 2>$null
    Write-Host "Found Python: $pythonVersion" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Python is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Python 3.9+ and try again" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if NoodleCore files exist
$launcherPath = "src\noodlecore\desktop\ide\launch_native_ide.py"
if (-not (Test-Path $launcherPath)) {
    Write-Host "ERROR: NoodleCore IDE launcher not found at: $launcherPath" -ForegroundColor Red
    Write-Host "Please ensure you are in the correct directory" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Launching NoodleCore Desktop IDE (canonical)..." -ForegroundColor Green
Write-Host ""
 
# Launch the canonical IDE via unified launcher
try {
    python $launcherPath
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "NoodleCore IDE closed successfully" -ForegroundColor Green
    }
    else {
        Write-Host ""
        Write-Host "ERROR: Failed to launch NoodleCore IDE" -ForegroundColor Red
        Write-Host "Exit code: $LASTEXITCODE" -ForegroundColor Yellow
    }
}
catch {
    Write-Host ""
    Write-Host "ERROR: Exception occurred while launching NoodleCore IDE" -ForegroundColor Red
    Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Press Enter to exit"