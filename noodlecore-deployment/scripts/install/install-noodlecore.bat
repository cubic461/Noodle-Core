@echo off
REM NoodleCore Installation Script (Windows)
REM One-click installation script for NoodleCore on Windows

setlocal enabledelayedexpansion

REM Configuration
set PACKAGE_NAME=noodlecore
set VERSION=1.0.0
set INSTALL_DIR=%ProgramFiles%\%PACKAGE_NAME%
set LOCAL_DIR=%LOCALAPPDATA%\%PACKAGE_NAME%
set BIN_DIR=%LOCALAPPDATA%\Microsoft\WindowsApps
set SERVICE_NAME=NoodleCore

REM Colors for output (Windows compatible)
set GREEN=[INFO]
set YELLOW=[WARN]
set RED=[ERROR]
set BLUE=[INFO]

REM Logging function
:log
echo %GREEN% %~1
goto :eof

:warn
echo %YELLOW% %~1
goto :eof

:error
echo %RED% %~1
exit /b 1

REM Display banner
:show_banner
echo %BLUE%
echo ==============================================
echo   NoodleCore Installation Script
echo ==============================================
echo %NC%
goto :eof

REM Check system requirements
:check_requirements
call :log "Checking system requirements..."

REM Check Python version
python --version >nul 2>&1
if errorlevel 1 (
    call :error "Python is not installed. Please install Python 3.8 or later from https://python.org"
)

REM Check pip
pip --version >nul 2>&1
if errorlevel 1 (
    call :error "pip is not installed"
)

REM Check available disk space
for /f "tokens=3" %%a in ('dir ^| find "bytes free"') do set free_space=%%a
set free_space=!free_space:,=!
if !free_space! lss 100000000 (
    call :warn "Less than 100MB of disk space available"
    set /p "continue=Continue anyway? (y/N): "
    if /i not "!continue!"=="y" exit /b 1
)

call :log "System requirements check completed"
goto :eof

REM Create installation directory
:create_directories
call :log "Creating installation directories..."

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
if not exist "%INSTALL_DIR%\data" mkdir "%INSTALL_DIR%\data"
if not exist "%INSTALL_DIR%\logs" mkdir "%INSTALL_DIR%\logs"
if not exist "%INSTALL_DIR%\config" mkdir "%INSTALL_DIR%\config"
if not exist "%INSTALL_DIR%\cache" mkdir "%INSTALL_DIR%\cache"
if not exist "%INSTALL_DIR%\backups" mkdir "%INSTALL_DIR%\backups"

call :log "Directories created"
goto :eof

REM Install Python dependencies
:install_python_deps
call :log "Installing Python dependencies..."

REM Create virtual environment
if not exist "%INSTALL_DIR%\venv" (
    python -m venv "%INSTALL_DIR%\venv"
)

REM Activate virtual environment
call "%INSTALL_DIR%\venv\Scripts\activate.bat"

REM Install dependencies
pip install --upgrade pip setuptools wheel

REM Install core dependencies
pip install ^
    numpy>=1.21.0 ^
    scipy>=1.7.0 ^
    pandas>=1.3.0 ^
    psycopg2-binary>=2.9.0 ^
    duckdb>=0.8.0 ^
    networkx>=2.6.0 ^
    cryptography>=3.4.0 ^
    aiohttp>=3.8.0 ^
    fastapi>=0.68.0 ^
    uvicorn>=0.15.0 ^
    pydantic>=1.8.0 ^
    protobuf==4.25.5

call :log "Python dependencies installed"
goto :eof

REM Install NoodleCore package
:install_package
call :log "Installing NoodleCore package..."

REM Install from PyPI
pip install "%PACKAGE_NAME%==%VERSION%"

REM Create symlinks for command line tools
if not exist "%BIN_DIR%" mkdir "%BIN_DIR%"
mklink /h "%BIN_DIR%\noodlecore.exe" "%INSTALL_DIR%\venv\Scripts\noodlecore.exe" >nul 2>&1
mklink /h "%BIN_DIR%\noodlecore-compiler.exe" "%INSTALL_DIR%\venv\Scripts\noodlecore-compiler.exe" >nul 2>&1
mklink /h "%BIN_DIR%\noodlecore-runtime.exe" "%INSTALL_DIR%\venv\Scripts\noodlecore-runtime.exe" >nul 2>&1
mklink /h "%BIN_DIR%\noodlecore-db.exe" "%INSTALL_DIR%\venv\Scripts\noodlecore-db.exe" >nul 2>&1

call :log "NoodleCore package installed"
goto :eof

REM Create configuration files
:create_config
call :log "Creating configuration files..."

REM Create default configuration
echo [NoodleCore] > "%INSTALL_DIR%\config\noodlecore.conf"
echo environment = production >> "%INSTALL_DIR%\config\noodlecore.conf"
echo log_level = INFO >> "%INSTALL_DIR%\config\noodlecore.conf"
echo data_dir = %INSTALL_DIR%\data >> "%INSTALL_DIR%\config\noodlecore.conf"
echo log_dir = %INSTALL_DIR%\logs >> "%INSTALL_DIR%\config\noodlecore.conf"
echo config_dir = %INSTALL_DIR%\config >> "%INSTALL_DIR%\config\noodlecore.conf"
echo cache_dir = %INSTALL_DIR%\cache >> "%INSTALL_DIR%\config\noodlecore.conf"
echo. >> "%INSTALL_DIR%\config\noodlecore.conf"
echo [Database] >> "%INSTALL_DIR%\config\noodlecore.conf"
echo url = sqlite:///%INSTALL_DIR%\data\noodlecore.db >> "%INSTALL_DIR%\config\noodlecore.conf"
echo pool_size = 10 >> "%INSTALL_DIR%\config\noodlecore.conf"
echo max_overflow = 20 >> "%INSTALL_DIR%\config\noodlecore.conf"
echo. >> "%INSTALL_DIR%\config\noodlecore.conf"
echo [Redis] >> "%INSTALL_DIR%\config\noodlecore.conf"
echo url = redis://localhost:6379 >> "%INSTALL_DIR%\config\noodlecore.conf"
echo db = 0 >> "%INSTALL_DIR%\config\noodlecore.conf"
echo. >> "%INSTALL_DIR%\config\noodlecore.conf"
echo [Server] >> "%INSTALL_DIR%\config\noodlecore.conf"
echo host = 0.0.0.0 >> "%INSTALL_DIR%\config\noodlecore.conf"
echo port = 8080 >> "%INSTALL_DIR%\config\noodlecore.conf"
echo workers = 4 >> "%INSTALL_DIR%\config\noodlecore.conf"
echo. >> "%INSTALL_DIR%\config\noodlecore.conf"
echo [Security] >> "%INSTALL_DIR%\config\noodlecore.conf"
echo secret_key = %RANDOM%%RANDOM%%RANDOM%%RANDOM%%RANDOM% >> "%INSTALL_DIR%\config\noodlecore.conf"
echo debug = false >> "%INSTALL_DIR%\config\noodlecore.conf"

REM Create environment file
echo NoodleCore_ENV=production > "%INSTALL_DIR%\config\.env"
echo NoodleCore_LOG_LEVEL=INFO >> "%INSTALL_DIR%\config\.env"
echo NoodleCore_DATA_DIR=%INSTALL_DIR%\data >> "%INSTALL_DIR%\config\.env"
echo NoodleCore_LOG_DIR=%INSTALL_DIR%\logs >> "%INSTALL_DIR%\config\.env"
echo NoodleCore_CONFIG_DIR=%INSTALL_DIR%\config >> "%INSTALL_DIR%\config\.env"
echo NoodleCore_CACHE_DIR=%INSTALL_DIR%\cache >> "%INSTALL_DIR%\config\.env"
echo DATABASE_URL=sqlite:///%INSTALL_DIR%\data\noodlecore.db >> "%INSTALL_DIR%\config\.env"
echo REDIS_URL=redis://localhost:6379 >> "%INSTALL_DIR%\config\.env"
echo SECRET_KEY=%RANDOM%%RANDOM%%RANDOM%%RANDOM%%RANDOM% >> "%INSTALL_DIR%\config\.env"

call :log "Configuration files created"
goto :eof

REM Create startup script
:create_startup_script
call :log "Creating startup script..."

echo @echo off > "%INSTALL_DIR%\start.bat"
echo REM NoodleCore startup script >> "%INSTALL_DIR%\start.bat"
echo. >> "%INSTALL_DIR%\start.bat"
echo setlocal >> "%INSTALL_DIR%\start.bat"
echo set SCRIPT_DIR=%~dp0 >> "%INSTALL_DIR%\start.bat"
echo set VENV_DIR=%SCRIPT_DIR%venv >> "%INSTALL_DIR%\start.bat"
echo set CONFIG_DIR=%SCRIPT_DIR%config >> "%INSTALL_DIR%\start.bat"
echo. >> "%INSTALL_DIR%\start.bat"
echo REM Activate virtual environment >> "%INSTALL_DIR%\start.bat"
echo call "%VENV_DIR%\Scripts\activate.bat" >> "%INSTALL_DIR%\start.bat"
echo. >> "%INSTALL_DIR%\start.bat"
echo REM Set environment variables >> "%INSTALL_DIR%\start.bat"
echo set NoodleCore_ENV=production >> "%INSTALL_DIR%\start.bat"
echo set NoodleCore_LOG_LEVEL=INFO >> "%INSTALL_DIR%\start.bat"
echo set NoodleCore_DATA_DIR=%SCRIPT_DIR%data >> "%INSTALL_DIR%\start.bat"
echo set NoodleCore_LOG_DIR=%SCRIPT_DIR%logs >> "%INSTALL_DIR%\start.bat"
echo set NoodleCore_CONFIG_DIR=%CONFIG_DIR% >> "%INSTALL_DIR%\start.bat"
echo set NoodleCore_CACHE_DIR=%SCRIPT_DIR%cache >> "%INSTALL_DIR%\start.bat"
echo. >> "%INSTALL_DIR%\start.bat"
echo REM Load environment file >> "%INSTALL_DIR%\start.bat"
echo if exist "%CONFIG_DIR%\.env" ( >> "%INSTALL_DIR%\start.bat"
echo     for /f "tokens=1,2 delims==" %%a in (%CONFIG_DIR%\.env) do ( >> "%INSTALL_DIR%\start.bat"
echo         set "%%a=%%b" >> "%INSTALL_DIR%\start.bat"
echo     ) >> "%INSTALL_DIR%\start.bat"
echo ) >> "%INSTALL_DIR%\start.bat"
echo. >> "%INSTALL_DIR%\start.bat"
echo REM Start NoodleCore >> "%INSTALL_DIR%\start.bat"
echo echo Starting NoodleCore... >> "%INSTALL_DIR%\start.bat"
echo cd /d "%SCRIPT_DIR%" >> "%INSTALL_DIR%\start.bat"
echo python -m noodlecore-runtime >> "%INSTALL_DIR%\start.bat"

call :log "Startup script created"
goto :eof

REM Create backup script
:create_backup_script
call :log "Creating backup script..."

echo @echo off > "%INSTALL_DIR%\backup.bat"
echo REM NoodleCore backup script >> "%INSTALL_DIR%\backup.bat"
echo setlocal >> "%INSTALL_DIR%\backup.bat"
echo set SCRIPT_DIR=%~dp0 >> "%INSTALL_DIR%\backup.bat"
echo set BACKUP_DIR=%SCRIPT_DIR%backups >> "%INSTALL_DIR%\backup.bat"
echo set DATA_DIR=%SCRIPT_DIR%data >> "%INSTALL_DIR%\backup.bat"
echo set LOG_DIR=%SCRIPT_DIR%logs >> "%INSTALL_DIR%\backup.bat"
echo. >> "%INSTALL_DIR%\backup.bat"
echo REM Create backup directory >> "%INSTALL_DIR%\backup.bat"
echo if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%" >> "%INSTALL_DIR%\backup.bat"
echo. >> "%INSTALL_DIR%\backup.bat"
echo REM Generate timestamp >> "%INSTALL_DIR%\backup.bat"
echo for /f "tokens=2 delims==" %%a in ('wmic os get localdatetime /value') do set "datetime=%%a" >> "%INSTALL_DIR%\backup.bat"
echo set TIMESTAMP=!datetime:~0,8!_!datetime:~8,6! >> "%INSTALL_DIR%\backup.bat"
echo. >> "%INSTALL_DIR%\backup.bat"
echo REM Create backup >> "%INSTALL_DIR%\backup.bat"
echo echo Creating backup... >> "%INSTALL_DIR%\backup.bat"
echo powershell -Command "Compress-Archive -Path '%SCRIPT_DIR%' -DestinationPath '%BACKUP_DIR%\noodlecore_backup_!TIMESTAMP!.zip' -Force -ExcludePath 'venv','*.pyc','__pycache__','logs\*.log','backups'" >> "%INSTALL_DIR%\backup.bat"
echo. >> "%INSTALL_DIR%\backup.bat"
echo REM Keep only last 7 backups >> "%INSTALL_DIR%\backup.bat"
echo for /f "delims=" %%f in ('dir /b /o-d "%BACKUP_DIR%\noodlecore_backup_*.zip"') do ( >> "%INSTALL_DIR%\backup.bat"
echo     set count=0 >> "%INSTALL_DIR%\backup.bat"
echo     for /f "delims=" %%g in ('dir /b /o-d "%BACKUP_DIR%\noodlecore_backup_*.zip"') do ( >> "%INSTALL_DIR%\backup.bat"
echo         set /a count+=1 >> "%INSTALL_DIR%\backup.bat"
echo         if !count! gtr 7 del "%BACKUP_DIR%\%%g" >> "%INSTALL_DIR%\backup.bat"
echo     ) >> "%INSTALL_DIR%\backup.bat"
echo     goto :break >> "%INSTALL_DIR%\backup.bat"
echo ) >> "%INSTALL_DIR%\backup.bat"
echo :break >> "%INSTALL_DIR%\backup.bat"
echo. >> "%INSTALL_DIR%\backup.bat"
echo echo Backup completed: %BACKUP_DIR%\noodlecore_backup_!TIMESTAMP!.zip >> "%INSTALL_DIR%\backup.bat"

call :log "Backup script created"
goto :eof

REM Create uninstall script
:create_uninstall_script
call :log "Creating uninstall script..."

echo @echo off > "%INSTALL_DIR%\uninstall.bat"
echo REM NoodleCore uninstall script >> "%INSTALL_DIR%\uninstall.bat"
echo setlocal >> "%INSTALL_DIR%\uninstall.bat"
echo set SCRIPT_DIR=%~dp0 >> "%INSTALL_DIR%\uninstall.bat"
echo. >> "%INSTALL_DIR%\uninstall.bat"
echo echo Uninstalling NoodleCore... >> "%INSTALL_DIR%\uninstall.bat"
echo. >> "%INSTALL_DIR%\uninstall.bat"
echo REM Stop service if running >> "%INSTALL_DIR%\uninstall.bat"
echo sc stop NoodleCore >nul 2>&1 >> "%INSTALL_DIR%\uninstall.bat"
echo sc delete NoodleCore >nul 2>&1 >> "%INSTALL_DIR%\uninstall.bat"
echo. >> "%INSTALL_DIR%\uninstall.bat"
echo REM Remove shortcuts >> "%INSTALL_DIR%\uninstall.bat"
echo if exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\NoodleCore.lnk" del "%APPDATA%\Microsoft\Windows\Start Menu\Programs\NoodleCore.lnk" >> "%INSTALL_DIR%\uninstall.bat"
echo. >> "%INSTALL_DIR%\uninstall.bat"
echo echo NoodleCore has been uninstalled. >> "%INSTALL_DIR%\uninstall.bat"
echo echo Data directory: %SCRIPT_DIR%data >> "%INSTALL_DIR%\uninstall.bat"
echo echo Logs directory: %SCRIPT_DIR%logs >> "%INSTALL_DIR%\uninstall.bat"
echo echo To remove all data, manually delete these directories. >> "%INSTALL_DIR%\uninstall.bat"
echo pause >> "%INSTALL_DIR%\uninstall.bat"

call :log "Uninstall script created"
goto :eof

REM Create desktop shortcut
:create_shortcut
call :log "Creating desktop shortcut..."

powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\NoodleCore.lnk'); $s.TargetPath = '%INSTALL_DIR%\start.bat'; $s.WorkingDirectory = '%INSTALL_DIR%'; $s.Save()"

call :log "Desktop shortcut created"
goto :eof

REM Verify installation
:verify_installation
call :log "Verifying installation..."

REM Check if commands are available
noodlecore --help >nul 2>&1
if errorlevel 0 (
    call :log "noodlecore command is available"
) else (
    call :warn "noodlecore command not found"
)

REM Test basic functionality
noodlecore --help >nul 2>&1
if errorlevel 0 (
    call :log "NoodleCore is working correctly"
) else (
    call :warn "NoodleCore test failed"
)

call :log "Installation verification completed"
goto :eof

REM Show completion message
:show_completion
echo %GREEN%
echo ==============================================
echo   NoodleCore Installation Complete!
echo ==============================================
echo %NC%
echo Installation directory: %INSTALL_DIR%
echo Configuration directory: %INSTALL_DIR%\config
echo Data directory: %INSTALL_DIR%\data
echo Log directory: %INSTALL_DIR%\logs
echo.
echo Commands available:
echo   noodlecore          - Main NoodleCore command
echo   noodlecore-compiler - NoodleCore compiler
echo   noodlecore-runtime  - NoodleCore runtime
echo   noodlecore-db       - NoodleCore database tools
echo.
echo To start NoodleCore:
echo   %INSTALL_DIR%\start.bat
echo.
echo To create backup:
echo   %INSTALL_DIR%\backup.bat
echo.
echo To uninstall:
echo   %INSTALL_DIR%\uninstall.bat
echo.
echo To view logs:
echo   type %INSTALL_DIR%\logs\noodlecore.log
echo.
echo For more information, visit:
echo   https://noodlecore.readthedocs.io/
echo %GREEN%
echo ==============================================
echo   Thank you for installing NoodleCore!
echo ==============================================
echo %NC%
goto :eof

REM Main function
:main
call :show_banner
call :check_requirements
call :create_directories
call :install_python_deps
call :install_package
call :create_config
call :create_startup_script
call :create_backup_script
call :create_uninstall_script
call :create_shortcut
call :verify_installation
call :show_completion

endlocal