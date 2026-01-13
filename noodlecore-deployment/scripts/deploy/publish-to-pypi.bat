@echo off
REM PyPI publishing script for NoodleCore (Windows)
REM Automates the process of publishing packages to PyPI

setlocal enabledelayedexpansion

REM Configuration
set PROJECT_ROOT=%~dp0
set DIST_DIR=%PROJECT_ROOT%\dist
set PACKAGE_NAME=noodlecore
set TWINE_REPOSITORY_URL=https://upload.pypi.org/legacy/
set TEST_TWINE_REPOSITORY_URL=https://test.pypi.org/legacy/

REM Colors for output (Windows compatible)
set GREEN=[INFO]
set YELLOW=[WARN]
set RED=[ERROR]

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

REM Check if required tools are installed
:check_requirements
call :log "Checking requirements..."

python --version >nul 2>&1
if errorlevel 1 (
    call :error "Python is not installed"
)

pip show twine >nul 2>&1
if errorlevel 1 (
    call :warn "Twine is not installed. Installing..."
    pip install twine
)

pip show build >nul 2>&1
if errorlevel 1 (
    call :warn "Build package is not installed. Installing..."
    pip install build
)

call :log "Requirements check completed"
goto :eof

REM Build the package
:build_package
call :log "Building package..."

REM Clean previous builds
if exist "%DIST_DIR%" rmdir /s /q "%DIST_DIR%"
mkdir "%DIST_DIR%"

REM Build the package
python -m build

REM Check if build was successful
if not exist "%DIST_DIR%" (
    call :error "Package build failed"
)

dir "%DIST_DIR%" >nul 2>&1
if errorlevel 1 (
    call :error "Package build failed"
)

call :log "Package built successfully"
goto :eof

REM Check package integrity
:check_package
call :log "Checking package integrity..."

REM Check for common issues
twine check "%DIST_DIR%"\*

REM Check for sensitive information
findstr /i "password secret key" "%DIST_DIR%"\* >nul 2>&1
if not errorlevel 1 (
    call :warn "Potential sensitive information found in package"
    set /p "continue=Continue publishing? (y/N): "
    if /i not "%continue%"=="y" exit /b 1
)

call :log "Package integrity check completed"
goto :eof

REM Upload to Test PyPI
:upload_test_pypi
call :log "Uploading to Test PyPI..."

twine upload --repository-url "%TEST_TWINE_REPOSITORY_URL%" "%DIST_DIR%"\*

call :log "Package uploaded to Test PyPI successfully"
goto :eof

REM Upload to Production PyPI
:upload_production_pypi
call :log "Uploading to Production PyPI..."

set /p "continue=Are you sure you want to upload to Production PyPI? (y/N): "
if /i not "%continue%"=="y" (
    call :log "Upload cancelled"
    exit /b 0
)

twine upload "%DIST_DIR%"\*

call :log "Package uploaded to Production PyPI successfully"
goto :eof

REM Create release notes
:create_release_notes
call :log "Creating release notes..."

set VERSION=1.0.0

echo # NoodleCore %VERSION% Release Notes > "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo ## What's New >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo This release includes significant improvements to NoodleCore's deployment and distribution capabilities. >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo ### Features >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo - Enhanced Docker configuration with multi-architecture support >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo - Comprehensive monitoring and logging infrastructure >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo - Security hardening and vulnerability scanning >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo - Distribution packages for multiple platforms >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo - CI/CD pipeline automation >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo - Kubernetes deployment manifests >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo - Production-ready deployment guides >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo ### Improvements >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo - Performance optimizations for production deployments >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo - Enhanced security scanning capabilities >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo - Improved monitoring and alerting >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo - Better error handling and logging >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo - Streamlined installation process >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo ### Installation >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo ```bash >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo pip install noodlecore >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo ``` >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo ### Documentation >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo - Full documentation: https://noodlecore.readthedocs.io/ >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo - Deployment guide: https://github.com/noodle/noodlecore/wiki/deployment >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo - API documentation: https://github.com/noodle/noodlecore/wiki/api >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo ### Support >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo - GitHub Issues: https://github.com/noodle/noodlecore/issues >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo - Documentation: https://noodlecore.readthedocs.io/ >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo - Community: https://discord.gg/noodlecore >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo ### License >> "%PROJECT_ROOT%\RELEASE_NOTES.md"
echo This project is licensed under the MIT License - see the LICENSE file for details. >> "%PROJECT_ROOT%\RELEASE_NOTES.md"

call :log "Release notes created successfully"
goto :eof

REM Main function
:main
call :log "Starting PyPI publishing process..."

REM Check requirements
call :check_requirements

REM Build package
call :build_package

REM Check package integrity
call :check_package

REM Create release notes
call :create_release_notes

REM Ask for upload target
echo.
echo Select upload target:
echo 1) Test PyPI only
echo 2) Production PyPI only
echo 3) Test PyPI first, then Production PyPI
echo 4) Cancel
echo.

set /p "choice=Enter your choice (1-4): "

if "%choice%"=="1" (
    call :upload_test_pypi
) else if "%choice%"=="2" (
    call :upload_production_pypi
) else if "%choice%"=="3" (
    call :upload_test_pypi
    call :log "Waiting 30 seconds before uploading to Production PyPI..."
    timeout /t 30 /nobreak >nul
    call :upload_production_pypi
) else if "%choice%"=="4" (
    call :log "Publishing cancelled"
    exit /b 0
) else (
    call :error "Invalid choice"
)

call :log "PyPI publishing completed successfully!"

endlocal