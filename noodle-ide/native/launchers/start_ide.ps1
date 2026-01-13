# NoodleCore Native GUI IDE - PowerShell Launcher
Write-Host "🚀 Starting NoodleCore Native GUI IDE v2.0..." -ForegroundColor Green
Write-Host "📂 Current directory: $(Get-Location)" -ForegroundColor Yellow

# Change to the parent directory of this script
Set-Location $PSScriptRoot/..
Write-Host "📁 Working directory: $(Get-Location)" -ForegroundColor Yellow

try {
    # Launch the IDE
    python launchers/start_ide.py
} catch {
    Write-Host "❌ Error starting IDE: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit"
}