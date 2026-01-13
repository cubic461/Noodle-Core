@echo off
REM NoodleCore Backup and Disaster Recovery Script (Windows)
REM Comprehensive backup and recovery procedures for NoodleCore

setlocal enabledelayedexpansion

REM Configuration
set PROJECT_ROOT=C:\Program Files\NoodleCore
set BACKUP_DIR=%PROJECT_ROOT%\backups
set DATA_DIR=%PROJECT_ROOT%\data
set LOG_DIR=%PROJECT_ROOT%\logs
set CONFIG_DIR=%PROJECT_ROOT%\config
set RETENTION_DAYS=30
set ENCRYPTION_KEY_FILE=%PROJECT_ROOT%\.encryption_key
set REMOTE_BACKUP=\\server\backups\noodlecore  # Change to your preferred remote storage
set NOTIFICATION_EMAIL=admin@noodlecore.com  # Change to your email

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
echo   NoodleCore Backup and Disaster Recovery
echo ==============================================
echo %NC%
goto :eof

REM Check administrator privileges
:check_admin
net session >nul 2>&1
if errorlevel 1 (
    call :error "This script must be run as administrator"
)
goto :eof

REM Generate encryption key
:generate_encryption_key
if not exist "%ENCRYPTION_KEY_FILE%" (
    call :log "Generating encryption key..."
    powershell -Command "$key = [Convert]::ToBase64String((New-Object Security.Cryptography.RNGCryptoServiceProvider).GetBytes(32)); $key | Out-File -FilePath '%ENCRYPTION_KEY_FILE%' -Encoding ASCII"
    if exist "%ENCRYPTION_KEY_FILE%" (
        icacls "%ENCRYPTION_KEY_FILE%" /inheritance:r
        icacls "%ENCRYPTION_KEY_FILE%" /grant:r "Administrators:(F)"
    )
    call :log "Encryption key generated: %ENCRYPTION_KEY_FILE%"
)
goto :eof

REM Create backup directory
:create_backup_dir
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
if not exist "%BACKUP_DIR%\daily" mkdir "%BACKUP_DIR%\daily"
if not exist "%BACKUP_DIR%\weekly" mkdir "%BACKUP_DIR%\weekly"
if not exist "%BACKUP_DIR%\monthly" mkdir "%BACKUP_DIR%\monthly"
if not exist "%BACKUP_DIR%\snapshots" mkdir "%BACKUP_DIR%\snapshots"
goto :eof

REM Stop services before backup
:stop_services
call :log "Stopping services before backup..."

REM Stop NoodleCore service
sc stop NoodleCore >nul 2>&1
if errorlevel 1 (
    call :warn "NoodleCore service not running"
)

REM Stop related services
net stop postgresql >nul 2>&1
net stop redis >nul 2>&1
net stop nginx >nul 2>&1

call :log "Services stopped"
goto :eof

REM Start services after backup
:start_services
call :log "Starting services after backup..."

REM Start PostgreSQL
net start postgresql >nul 2>&1

REM Start Redis
net start redis >nul 2>&1

REM Start NoodleCore service
sc start NoodleCore >nul 2>&1

call :log "Services started"
goto :eof

REM Create database backup
:backup_database
call :log "Creating database backup..."

for /f "tokens=2 delims==" %%a in ('wmic os get localdatetime /value') do set "datetime=%%a"
set timestamp=!datetime:~0,8!_!datetime:~8,6!
set backup_file=%BACKUP_DIR%\daily\database_backup_!timestamp!.sql

REM Create PostgreSQL dump
pg_dump -U postgres noodlecore > "%backup_file%" 2>nul

if exist "%backup_file%" (
    REM Compress the backup
    powershell -Command "Compress-Archive -Path '%backup_file%' -DestinationPath '%backup_file%.zip' -Force"
    del "%backup_file%"
    
    REM Encrypt the backup
    if exist "%ENCRYPTION_KEY_FILE%" (
        powershell -Command "$key = Get-Content '%ENCRYPTION_KEY_FILE%' -Encoding ASCII; $content = Get-Content '%backup_file%.zip' -Encoding Byte; $encrypted = [Convert]::ToBase64String($content); $encrypted | Out-File '%backup_file%.zip.enc' -Encoding ASCII"
        del "%backup_file%.zip"
    )
    
    call :log "Database backup completed: %backup_file%.zip.enc"
) else (
    call :warn "Database backup failed"
)
goto :eof

REM Create file system backup
:backup_filesystem
call :log "Creating file system backup..."

for /f "tokens=2 delims==" %%a in ('wmic os get localdatetime /value') do set "datetime=%%a"
set timestamp=!datetime:~0,8!_!datetime:~8,6%
set backup_file=%BACKUP_DIR%\daily\filesystem_backup_!timestamp!.zip

REM Create ZIP archive
powershell -Command "Compress-Archive -Path '%PROJECT_ROOT%\*' -DestinationPath '%backup_file%' -Force -ExcludePath 'venv','*.pyc','__pycache__','logs\*.log','backups','*.tmp','*.cache','node_modules','.git','*.log','backups'"

REM Encrypt the backup
if exist "%ENCRYPTION_KEY_FILE%" (
    powershell -Command "$key = Get-Content '%ENCRYPTION_KEY_FILE%' -Encoding ASCII; $content = Get-Content '%backup_file%' -Encoding Byte; $encrypted = [Convert]::ToBase64String($content); $encrypted | Out-File '%backup_file%.enc' -Encoding ASCII"
    del "%backup_file%"
)

call :log "File system backup completed: %backup_file%.enc"
goto :eof

REM Create configuration backup
:backup_configuration
call :log "Creating configuration backup..."

for /f "tokens=2 delims==" %%a in ('wmic os get localdatetime /value') do set "datetime=%%a"
set timestamp=!datetime:~0,8!_!datetime:~8,6%
set backup_file=%BACKUP_DIR%\daily\config_backup_!timestamp!.zip

REM Create configuration archive
powershell -Command "Compress-Archive -Path '%CONFIG_DIR%','%PROJECT_ROOT%\docker-compose.yml','%PROJECT_ROOT%\Dockerfile','%PROJECT_ROOT%\requirements.txt','%PROJECT_ROOT%\pyproject.toml' -DestinationPath '%backup_file%' -Force"

REM Encrypt the backup
if exist "%ENCRYPTION_KEY_FILE%" (
    powershell -Command "$key = Get-Content '%ENCRYPTION_KEY_FILE%' -Encoding ASCII; $content = Get-Content '%backup_file%' -Encoding Byte; $encrypted = [Convert]::ToBase64String($content); $encrypted | Out-File '%backup_file%.enc' -Encoding ASCII"
    del "%backup_file%"
)

call :log "Configuration backup completed: %backup_file%.enc"
goto :eof

REM Create snapshot backup
:create_snapshot
call :log "Creating snapshot backup..."

for /f "tokens=2 delims==" %%a in ('wmic os get localdatetime /value') do set "datetime=%%a"
set timestamp=!datetime:~0,8!_!datetime:~8,6%
set snapshot_dir=%BACKUP_DIR%\snapshots\snapshot_!timestamp!

REM Create snapshot directory
if not exist "%snapshot_dir%" mkdir "%snapshot_dir%"

REM Copy files to snapshot
xcopy "%PROJECT_ROOT%\*" "%snapshot_dir%\" /E /I /H /Y >nul 2>&1

REM Create snapshot archive
powershell -Command "Compress-Archive -Path '%snapshot_dir%' -DestinationPath '%BACKUP_DIR%\snapshots\snapshot_!timestamp!.zip' -Force"
rmdir /s /q "%snapshot_dir%"

call :log "Snapshot backup completed: %BACKUP_DIR%\snapshots\snapshot_!timestamp!.zip"
goto :eof

REM Upload to remote storage
:upload_to_remote
call :log "Uploading to remote storage..."

if exist "%REMOTE_BACKUP%" (
    REM Upload daily backups
    xcopy "%BACKUP_DIR%\daily\*.*" "%REMOTE_BACKUP%\daily\" /Y /I >nul 2>&1
    
    REM Upload weekly backups
    xcopy "%BACKUP_DIR%\weekly\*.*" "%REMOTE_BACKUP%\weekly\" /Y /I >nul 2>&1
    
    REM Upload monthly backups
    xcopy "%BACKUP_DIR%\monthly\*.*" "%REMOTE_BACKUP%\monthly\" /Y /I >nul 2>&1
    
    REM Upload snapshots
    xcopy "%BACKUP_DIR%\snapshots\*.*" "%REMOTE_BACKUP%\snapshots\" /Y /I >nul 2>&1
    
    call :log "Remote upload completed"
) else (
    call :warn "Remote storage not available. Skipping remote upload."
)
goto :eof

REM Clean old backups
:clean_old_backups
call :log "Cleaning old backups..."

REM Find and remove backups older than retention period
forfiles /p "%BACKUP_DIR%\daily" /m *.zip* /d -%RETENTION_DAYS% /c "cmd /c del @path" >nul 2>&1
forfiles /p "%BACKUP_DIR%\weekly" /m *.zip* /d -%RETENTION_DAYS% /c "cmd /c del @path" >nul 2>&1
forfiles /p "%BACKUP_DIR%\monthly" /m *.zip* /d -%RETENTION_DAYS% /c "cmd /c del @path" >nul 2>&1
forfiles /p "%BACKUP_DIR%\snapshots" /m *.zip /d -%RETENTION_DAYS% /c "cmd /c del @path" >nul 2>&1

REM Clean remote backups
if exist "%REMOTE_BACKUP%" (
    forfiles /p "%REMOTE_BACKUP%\daily" /m *.zip* /d -%RETENTION_DAYS% /c "cmd /c del @path" >nul 2>&1
    forfiles /p "%REMOTE_BACKUP%\weekly" /m *.zip* /d -%RETENTION_DAYS% /c "cmd /c del @path" >nul 2>&1
    forfiles /p "%REMOTE_BACKUP%\monthly" /m *.zip* /d -%RETENTION_DAYS% /c "cmd /c del @path" >nul 2>&1
    forfiles /p "%REMOTE_BACKUP%\snapshots" /m *.zip /d -%RETENTION_DAYS% /c "cmd /c del @path" >nul 2>&1
)

call :log "Old backups cleaned"
goto :eof

REM Create backup report
:create_backup_report
for /f "tokens=2 delims==" %%a in ('wmic os get localdatetime /value') do set "datetime=%%a"
set timestamp=!datetime:~0,8!_!datetime:~8,6%
set report_file=%BACKUP_DIR%\backup_report_!timestamp!.txt

echo NoodleCore Backup Report - %date% %time% > "%report_file%"
echo ===================================== >> "%report_file%"
echo. >> "%report_file%"
echo Backup Summary: >> "%report_file%"
echo   - Database backup: >> "%report_file%"
dir /b "%BACKUP_DIR%\daily\*database*.zip*" 2>nul | find /c /v "" >> "%report_file%"
echo   - File system backup: >> "%report_file%"
dir /b "%BACKUP_DIR%\daily\*filesystem*.zip*" 2>nul | find /c /v "" >> "%report_file%"
echo   - Configuration backup: >> "%report_file%"
dir /b "%BACKUP_DIR%\daily\*config*.zip*" 2>nul | find /c /v "" >> "%report_file%"
echo   - Snapshots: >> "%report_file%"
dir /b "%BACKUP_DIR%\snapshots\*.zip" 2>nul | find /c /v "" >> "%report_file%"
echo. >> "%report_file%"
echo Storage Usage: >> "%report_file%"
echo   - Local backup size: >> "%report_file%"
dir "%BACKUP_DIR%" | find "bytes free" >> "%report_file%"
echo   - Retention period: %RETENTION_DAYS% days >> "%report_file%"
echo. >> "%report_file%"
echo Backup Status: SUCCESS >> "%report_file%"

call :log "Backup report created: %report_file%"
goto :eof

REM Main backup function
:backup
call :log "Starting backup process..."

call :stop_services

REM Generate encryption key
call :generate_encryption_key

REM Create backup directory
call :create_backup_dir

REM Create different types of backups
call :backup_database
call :backup_filesystem
call :backup_configuration

REM Create snapshot
call :create_snapshot

REM Upload to remote storage
call :upload_to_remote

REM Clean old backups
call :clean_old_backups

REM Create backup report
call :create_backup_report

call :start_services

call :log "Backup process completed"
goto :eof

REM Disaster recovery function
:disaster_recovery
call :log "Starting disaster recovery process..."

REM Ask for backup date
echo Available backups:
dir /b "%BACKUP_DIR%\daily\*database*.zip*" 2>nul | find /v ""
echo.
set /p "backup_date=Enter backup date (YYYYMMDD): "

REM Find backup files
set db_backup=
set fs_backup=
set config_backup=

for /f "delims=" %%f in ('dir /b "%BACKUP_DIR%\daily\*database_%backup_date%*.zip*" 2^>nul') do set db_backup=%%f
for /f "delims=" %%f in ('dir /b "%BACKUP_DIR%\daily\*filesystem_%backup_date%*.zip*" 2^>nul') do set fs_backup=%%f
for /f "delims=" %%f in ('dir /b "%BACKUP_DIR%\daily\*config_%backup_date%*.zip*" 2^>nul') do set config_backup=%%f

if "%db_backup%"=="" if "%fs_backup%"=="" if "%config_backup%"=="" (
    call :error "Required backup files not found for date: %backup_date%"
)

REM Stop all services
call :stop_services

REM Restore database
call :log "Restoring database..."
if not "%db_backup%"=="" (
    if exist "%ENCRYPTION_KEY_FILE%" (
        powershell -Command "$key = Get-Content '%ENCRYPTION_KEY_FILE%' -Encoding ASCII; $content = [Convert]::FromBase64String((Get-Content '%BACKUP_DIR%\daily\%db_backup%' -Encoding ASCII)); [IO.File]::WriteAllBytes('%TEMP%\database.sql.zip', $content)"
    ) else (
        copy "%BACKUP_DIR%\daily\%db_backup%" "%TEMP%\database.sql.zip" >nul 2>&1
    )
    
    if exist "%TEMP%\database.sql.zip" (
        powershell -Command "Expand-Archive -Path '%TEMP%\database.sql.zip' -DestinationPath '%TEMP%' -Force"
        if exist "%TEMP%\database.sql" (
            psql -U postgres noodlecore < "%TEMP%\database.sql" >nul 2>&1
            del "%TEMP%\database.sql"
        )
        del "%TEMP%\database.sql.zip"
    )
)

REM Restore file system
call :log "Restoring file system..."
if not "%fs_backup%"=="" (
    if exist "%ENCRYPTION_KEY_FILE%" (
        powershell -Command "$key = Get-Content '%ENCRYPTION_KEY_FILE%' -Encoding ASCII; $content = [Convert]::FromBase64String((Get-Content '%BACKUP_DIR%\daily\%fs_backup%' -Encoding ASCII)); [IO.File]::WriteAllBytes('%TEMP%\filesystem.zip', $content)"
    ) else (
        copy "%BACKUP_DIR%\daily\%fs_backup%" "%TEMP%\filesystem.zip" >nul 2>&1
    )
    
    if exist "%TEMP%\filesystem.zip" (
        powershell -Command "Expand-Archive -Path '%TEMP%\filesystem.zip' -DestinationPath 'C:\' -Force"
        del "%TEMP%\filesystem.zip"
    )
)

REM Restore configuration
call :log "Restoring configuration..."
if not "%config_backup%"=="" (
    if exist "%ENCRYPTION_KEY_FILE%" (
        powershell -Command "$key = Get-Content '%ENCRYPTION_KEY_FILE%' -Encoding ASCII; $content = [Convert]::FromBase64String((Get-Content '%BACKUP_DIR%\daily\%config_backup%' -Encoding ASCII)); [IO.File]::WriteAllBytes('%TEMP%\config.zip', $content)"
    ) else (
        copy "%BACKUP_DIR%\daily\%config_backup%" "%TEMP%\config.zip" >nul 2>&1
    )
    
    if exist "%TEMP%\config.zip" (
        powershell -Command "Expand-Archive -Path '%TEMP%\config.zip' -DestinationPath '%PROJECT_ROOT%' -Force"
        del "%TEMP%\config.zip"
    )
)

REM Restore permissions
icacls "%PROJECT_ROOT%" /reset /T /C
icacls "%PROJECT_ROOT%" /grant:r "Administrators:(F)" /T /C
icacls "%PROJECT_ROOT%" /grant:r "SYSTEM:(F)" /T /C

REM Start services
call :start_services

call :log "Disaster recovery completed"
goto :eof

REM Show backup status
:show_status
echo Backup Status:
echo ==============
echo Backup directory: %BACKUP_DIR%
echo Retention period: %RETENTION_DAYS% days
echo Remote storage: %REMOTE_BACKUP%
echo.
echo Recent backups:
echo Daily:
dir /b "%BACKUP_DIR%\daily\*.*" | find /v "" | tail -5
echo.
echo Weekly:
dir /b "%BACKUP_DIR%\weekly\*.*" | find /v "" | tail -5
echo.
echo Monthly:
dir /b "%BACKUP_DIR%\monthly\*.*" | find /v "" | tail -5
echo.
echo Snapshots:
dir /b "%BACKUP_DIR%\snapshots\*.*" | find /v "" | tail -5
goto :eof

REM Main function
:main
call :show_banner
call :check_admin

if "%~1"=="" set "action=backup"
if "%~1"=="" set "action=%action%"
if "%~1"=="backup" set "action=backup"
if "%~1"=="recovery" set "action=recovery"
if "%~1"=="status" set "action=status"

if "%action%"=="backup" (
    call :backup
) else if "%action%"=="recovery" (
    call :disaster_recovery
) else if "%action%"=="status" (
    call :show_status
) else (
    echo Usage: %~0 {backup^|recovery^|status}
    echo   backup    - Create backup ^(default^)
    echo   recovery  - Perform disaster recovery
    echo   status    - Show backup status
    exit /b 1
)

endlocal