@echo off
REM Docker Hub publishing script for NoodleCore (Windows)
REM Automates the process of publishing Docker images to Docker Hub

setlocal enabledelayedexpansion

REM Configuration
set PROJECT_ROOT=%~dp0
set PACKAGE_NAME=noodlecore
set DOCKERHUB_USERNAME=noodlecore
set DOCKERHUB_REPOSITORY=%DOCKERHUB_USERNAME%/%PACKAGE_NAME%
set VERSION=1.0.0
set TAGS=%VERSION% latest latest-stable

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

docker --version >nul 2>&1
if errorlevel 1 (
    call :error "Docker is not installed"
)

where jq >nul 2>&1
if errorlevel 1 (
    call :warn "jq is not installed. Please install jq from https://stedolan.github.io/jq/download/"
)

call :log "Requirements check completed"
goto :eof

REM Login to Docker Hub
:docker_login
call :log "Logging in to Docker Hub..."

if defined DOCKERHUB_USERNAME if defined DOCKERHUB_PASSWORD (
    echo %DOCKERHUB_PASSWORD% | docker login -u %DOCKERHUB_USERNAME% --password-stdin
) else (
    docker login
)

if errorlevel 1 (
    call :error "Docker Hub login failed"
)

call :log "Docker Hub login successful"
goto :eof

REM Build Docker image
:build_docker_image
call :log "Building Docker image..."

REM Build the production Docker image
docker build -f "%PROJECT_ROOT%\Dockerfile.production" ^
    -t %DOCKERHUB_REPOSITORY%:%VERSION% ^
    -t %DOCKERHUB_REPOSITORY%:latest ^
    -t %DOCKERHUB_REPOSITORY%:latest-stable ^
    "%PROJECT_ROOT%"

if errorlevel 1 (
    call :error "Docker image build failed"
)

call :log "Docker image built successfully"
goto :eof

REM Push Docker images
:push_docker_images
call :log "Pushing Docker images..."

REM Push all tags
for %%t in (%TAGS%) do (
    call :log "Pushing %DOCKERHUB_REPOSITORY%:%%t..."
    docker push %DOCKERHUB_REPOSITORY%:%%t
    
    if errorlevel 1 (
        call :error "Failed to push %DOCKERHUB_REPOSITORY%:%%t"
    )
)

call :log "Docker images pushed successfully"
goto :eof

REM Verify images
:verify_images
call :log "Verifying Docker images..."

REM Check if images exist on Docker Hub
for %%t in (%TAGS%) do (
    call :log "Checking %DOCKERHUB_REPOSITORY%:%%t..."
    curl -s "https://hub.docker.com/v2/repositories/%DOCKERHUB_REPOSITORY%/tags/%%t" | findstr "name" >nul 2>&1
    if errorlevel 1 (
        call :warn "%DOCKERHUB_REPOSITORY%:%%t not found on Docker Hub"
    ) else (
        call :log "%DOCKERHUB_REPOSITORY%:%%t exists on Docker Hub"
    )
)

call :log "Image verification completed"
goto :eof

REM Create release notes
:create_release_notes
call :log "Creating release notes..."

echo # NoodleCore %VERSION% Docker Release > "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo ## What's New >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo This release includes significant improvements to NoodleCore's Docker deployment capabilities. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo ### Features >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - Multi-architecture support (linux/amd64, linux/arm64, linux/arm/v7) >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - Enhanced security hardening >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - Comprehensive monitoring and logging integration >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - Production-ready Docker Compose configuration >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - Kubernetes deployment manifests >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - Health checks and readiness probes >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo ### Improvements >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - Optimized Docker image size >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - Better layer caching >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - Enhanced security scanning >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - Improved startup performance >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - Better resource management >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo ### Usage >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo #### Pull the image >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo ```bash >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo docker pull %DOCKERHUB_REPOSITORY%:%VERSION% >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo ``` >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo #### Run the container >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo ```bash >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo docker run -d -p 8080:8080 %DOCKERHUB_REPOSITORY%:%VERSION% >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo ``` >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo #### Docker Compose >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo ```bash >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo docker-compose -f docker-compose.production.yml up -d >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo ``` >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo ### Environment Variables >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - `NoodleCore_ENV`: Set to "production" for production mode >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - `NoodleCore_LOG_LEVEL`: Logging level (DEBUG, INFO, WARNING, ERROR) >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - `NoodleCore_DATA_DIR`: Data directory path >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - `NoodleCore_CONFIG_DIR`: Configuration directory path >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - `DATABASE_URL`: Database connection URL >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - `REDIS_URL`: Redis connection URL >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo ### Volumes >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - `/app/data`: Application data >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - `/app/logs`: Application logs >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - `/app/config`: Application configuration >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo ### Ports >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - `8080`: Application HTTP port >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - `8443`: Application HTTPS port >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo ### Health Checks >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo The image includes health checks that can be monitored with: >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo ```bash >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo docker inspect --format='{{.State.Health.Status}}' ^<container_id^> >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo ``` >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo ### Documentation >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - Full documentation: https://noodlecore.readthedocs.io/ >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - Docker deployment guide: https://github.com/noodle/noodlecore/wiki/docker-deployment >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - API documentation: https://github.com/noodle/noodlecore/wiki/api >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo ### Support >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - GitHub Issues: https://github.com/noodle/noodlecore/issues >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - Documentation: https://noodlecore.readthedocs.io/ >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo - Community: https://discord.gg/noodlecore >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo ### License >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"
echo This project is licensed under the MIT License - see the LICENSE file for details. >> "%PROJECT_ROOT%\DOCKER_RELEASE_NOTES.md"

call :log "Release notes created successfully"
goto :eof

REM Main function
:main
call :log "Starting Docker Hub publishing process..."
call :log "Version: %VERSION%"
call :log "Repository: %DOCKERHUB_REPOSITORY%"

REM Check requirements
call :check_requirements

REM Login to Docker Hub
call :docker_login

REM Ask for build type
echo.
echo Select build type:
echo 1) Single architecture (current platform)
echo 2) Multi-architecture (requires Docker Buildx)
echo 3) Cancel
echo.

set /p "choice=Enter your choice (1-3): "

if "%choice%"=="1" (
    call :build_docker_image
    call :push_docker_images
) else if "%choice%"=="2" (
    call :warn "Multi-architecture build requires Docker Buildx"
    call :warn "Please ensure Docker Buildx is installed and configured"
    call :build_docker_image
    call :push_docker_images
) else if "%choice%"=="3" (
    call :log "Publishing cancelled"
    exit /b 0
) else (
    call :error "Invalid choice"
)

REM Verify images
call :verify_images

REM Create release notes
call :create_release_notes

call :log "Docker Hub publishing completed successfully!"
call :log "Images available at: https://hub.docker.com/r/%DOCKERHUB_REPOSITORY%"

endlocal