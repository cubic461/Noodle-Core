# NoodleCore Multi-Machine Deploy Script (Windows)
# Usage: .\deploy_multi_machine.ps1 -RemoteIP "192.168.1.102"

param(
    [Parameter(Mandatory=$true)]
    [string]$RemoteIP,

    [Parameter(Mandatory=$false)]
    [string]$RemoteUser = $env:USERNAME
)

$ErrorActionPreference = "Stop"

# Project root (adjust if needed)
$ProjectDir = "C:\Users\$env:USERNAME\Noodle\noodle-poc-fase1"

# Derived paths
$RemoteProjectDir = "/home/$RemoteUser/noodle-poc"  # Linux target (adjust if needed)

# Colors for console output
function Write-ColorOutput($Message, $Color) {
    Write-Host $Message -ForegroundColor $Color
}

try {
    Write-ColorOutput "`n========================================" Green
    Write-ColorOutput "🤖 NoodleCore Multi-Machine Deployment" Green
    Write-ColorOutput "========================================" Green

    Write-Host "`nConfiguration:"
    Write-Host "  Project: $ProjectDir"
    Write-Host "  Remote IP: $RemoteIP"
    Write-Host "  Remote User: $RemoteUser"
    Write-Host "  Remote Dir: $RemoteProjectDir"

    # Step 1: Check if rsync is available (Git Bash)
    $rsyncAvailable = $false
    if (Get-Command rsync -ErrorAction SilentlyContinue) {
        $rsyncAvailable = $true
    }
    elseif (Test-Path "C:\Program Files\Git\usr\bin\rsync.exe") {
        $env:Path += ";C:\Program Files\Git\usr\bin"
        $rsyncAvailable = $true
    }

    if (-not $rsyncAvailable) {
        Write-ColorOutput "`n⚠️  WARNING: rsync not found" Yellow
        Write-Host "Installing Git for Windows is recommended for fast synchronization"
        Write-Host "Download: https://git-scm.com/download/win"
        Write-Host "Alternatively, we will use SCP (slower)"
        Write-Host ""
        $confirm = Read-Host "Continue with SCP? (y/n)"
        if ($confirm -ne 'y') {
            Exit 1
        }
    }

    # Step 2: Upload code to remote machine
    Write-ColorOutput "`n[STEP 1/3] Uploading code to $RemoteIP..." Cyan

    if ($rsyncAvailable) {
        Write-Host "Using rsync for fast transfer..."
        $rsyncArgs = @(
            "-avz",
            "--update",
            "--delete",
            "--exclude=__pycache__",
            "--exclude=*.pyc",
            "--exclude=.git",
            "--exclude=*.log",
            "--exclude=data",
            "-e", "ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10",
            "$ProjectDir/",
            "$RemoteUser@${RemoteIP}:$RemoteProjectDir/"
        )
        $rsyncOutput = rsync @rsyncArgs 2>&1

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  ✅ Upload complete" Green
        }
        else {
            Write-ColorOutput "  ❌ rsync failed, falling back to SCP..." Red
            Write-Host $rsyncOutput -ForegroundColor Red
            $rsyncAvailable = $false
        }
    }

    if (-not $rsyncAvailable) {
        Write-Host "Using SCP..."
        $scpArgs = @(
            "-r",
            "-o", "StrictHostKeyChecking=no",
            "-o", "ConnectTimeout=10",
            "$ProjectDir",
            "$RemoteUser@${RemoteIP}:$RemoteProjectDir"
        )

        scp @scpArgs
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "  ❌ Upload FAILED" Red
            Exit 1
        }

        Write-ColorOutput "  ✅ Upload complete" Green
    }

    # Step 3: Start worker server on remote machine
    Write-ColorOutput "`n[STEP 2/3] Starting worker server on $RemoteIP..." Cyan

    $sshArgs = @("-o", "StrictHostKeyChecking=no", "-o", "ConnectTimeout=10")
    $envVars = "WORKER_ID=remote_cpu WORKER_PORT=8081 COORDINATOR_URL=http://$(hostname -I | %{ $_.Trim() } | Select-Object -First 1):8080"

    Write-Host "  Executing remote command via SSH..."
    $startCmd = "cd $RemoteProjectDir && $envVars nohup python examples/worker_server.py > worker.log 2>&1 &"
    $sshOutput = ssh @sshArgs ${RemoteUser}@${RemoteIP} $startCmd 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "  ✅ Worker started" Green
        Write-Host "  Worker log: $RemoteProjectDir/worker.log"
    }
    else {
        Write-ColorOutput "  ❌ Failed to start worker" Red
        Write-Host $sshOutput -ForegroundColor Red
        Exit 1
    }

    # Wait a moment for worker to come online
    Write-Host "`n  Waiting for worker to start... (3s)"
    Start-Sleep -Seconds 3

    # Step 4: Verify worker is accessible
    Write-ColorOutput "`n[STEP 3/3] Verifying worker health at http://${RemoteIP}:8081/health" Cyan

    try {
        $healthResponse = ssh @sshArgs ${RemoteUser}@${RemoteIP} "curl -s http://localhost:8081/health" 2>$null

        if ($healthResponse -match '"status":"ready"') {
            Write-ColorOutput "  ✅ Worker is ready and responding" Green
        }
        else {
            Write-ColorOutput "  ⚠️  Worker returned unexpected response" Yellow
            Write-Host "  Raw output: $healthResponse" -ForegroundColor Yellow
        }
    }
    catch {
        Write-ColorOutput "  ⚠️  Health check failed (worker may still be starting)" Yellow
    }

    # Step 5: Start coordinator on local machine
    Write-ColorOutput "`n[LOCAL] Starting coordinator on laptop..." Cyan

    # Check if FastAPI is installed
    $fastapiAvailable = python -m pip list 2>$null | Select-String "fastapi"

    if (-not $fastapiAvailable) {
        Write-ColorOutput "  Installing FastAPI..." Yellow
        python -m pip install fastapi uvicorn requests 2>$null
    }

    # Start coordinator in new PowerShell window
    $coordinatorScript = @"
cd '$ProjectDir'
python examples/coordinator_api.py
"@

    Write-Host "  Opening new PowerShell for coordinator..."
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $coordinatorScript

    # Step 6: Final info
    Write-ColorOutput "`n========================================" Green
    Write-ColorOutput "✅ Deploy Complete!" Green
    Write-ColorOutput "========================================" Green

    Write-Host "`nEndpoints:"
    Write-Host "  Coordinator (Laptop):    http://localhost:8080"
    Write-Host "  Worker Health (Remote):  http://$RemoteIP :8081/health"
    Write-Host ""

    Write-Host "Logs:"
    Write-Host "  Remote worker logs:      worker.log on remote machine"
    Write-Host "  Coordinator logs:        PowerShell window"
    Write-Host ""

    Write-Host "Next Steps:"
    Write-Host "  1. Check coordinator is running: http://localhost:8080/health"
    Write-Host "  2. Run tests:                     python examples/test_remote_connection.py"
    Write-Host "  3. Run distributed demo:          python examples/distributed_demo.py"
    Write-Host ""

    Write-ColorOutput "💡 TIP: Run 'test_remote_connection.py' to verify communication" Yellow
}

catch {
    Write-ColorOutput "`n❌ DEPLOYMENT FAILED!" Red
    Write-ColorOutput "Error: $_" Red

    if ($_.Exception -match "Connection refused") {
        Write-Host "`nTroubleshooting:"
        Write-Host "  1. Check if $RemoteIP is accessible (ping $RemoteIP)"
        Write-Host "  2. Ensure SSH is enabled on remote machine"
        Write-Host "  3. Verify firewall rules (ports 22 for SSH, 8080/8081 for web)"
    }

    Exit 1
}
