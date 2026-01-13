@echo off
REM NoodleCore Deployment Testing Script (Windows)
REM Tests deployment across different environments and cloud providers

setlocal enabledelayedexpansion

REM Configuration
set PROJECT_ROOT=C:\Program Files\NoodleCore
set TEST_RESULTS_DIR=%PROJECT_ROOT%\test-results
set LOG_FILE=%TEST_RESULTS_DIR%\deployment-test.log
set REPORT_FILE=%TEST_RESULTS_DIR%\deployment-test-report.html

REM Colors for output (Windows compatible)
set GREEN=[INFO]
set YELLOW=[WARN]
set RED=[ERROR]
set BLUE=[INFO]

REM Logging function
:log
echo %GREEN% %~1
echo %date% %time% [INFO] %~1 >> "%LOG_FILE%"
goto :eof

:warn
echo %YELLOW% %~1
echo %date% %time% [WARN] %~1 >> "%LOG_FILE%"
goto :eof

:error
echo %RED% %~1
echo %date% %time% [ERROR] %~1 >> "%LOG_FILE%"
exit /b 1

REM Display banner
:show_banner
echo %BLUE%
echo ==============================================
echo   NoodleCore Deployment Testing
echo ==============================================
echo %NC%
goto :eof

REM Initialize test environment
:init_test_environment
call :log "Initializing test environment..."

REM Create test results directory
if not exist "%TEST_RESULTS_DIR%" mkdir "%TEST_RESULTS_DIR%"

REM Clear previous test results
if exist "%LOG_FILE%" del "%LOG_FILE%"

REM Create HTML report template
echo ^<!DOCTYPE html^> > "%REPORT_FILE%"
echo ^<html lang="en"^> >> "%REPORT_FILE%"
echo ^<head^> >> "%REPORT_FILE%"
echo     ^<meta charset="UTF-8"^> >> "%REPORT_FILE%"
echo     ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^> >> "%REPORT_FILE%"
echo     ^<title^>NoodleCore Deployment Test Report^</title^> >> "%REPORT_FILE%"
echo     ^<style^> >> "%REPORT_FILE%"
echo         body { font-family: Arial, sans-serif; margin: 20px; } >> "%REPORT_FILE%"
echo         .header { background-color: #f0f0f0; padding: 20px; border-radius: 5px; } >> "%REPORT_FILE%"
echo         .test-section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; } >> "%REPORT_FILE%"
echo         .test-result { margin: 10px 0; padding: 10px; border-radius: 3px; } >> "%REPORT_FILE%"
echo         .success { background-color: #d4edda; color: #155724; } >> "%REPORT_FILE%"
echo         .failure { background-color: #f8d7da; color: #721c24; } >> "%REPORT_FILE%"
echo         .warning { background-color: #fff3cd; color: #856404; } >> "%REPORT_FILE%"
echo         .log-section { background-color: #f8f9fa; padding: 10px; border-radius: 3px; font-family: monospace; } >> "%REPORT_FILE%"
echo     ^</style^> >> "%REPORT_FILE%"
echo ^</head^> >> "%REPORT_FILE%"
echo ^<body^> >> "%REPORT_FILE%"
echo     ^<div class="header"^> >> "%REPORT_FILE%"
echo         ^<h1^>NoodleCore Deployment Test Report^</h1^> >> "%REPORT_FILE%"
echo         ^<p^>Generated on: %date% %time%^</p^> >> "%REPORT_FILE%"
echo     ^</div^> >> "%REPORT_FILE%"
goto :eof

REM Test local Docker deployment
:test_docker_deployment
call :log "Testing local Docker deployment..."

set test_name=Docker Deployment
set start_time=%time%

REM Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    call :error "Docker not installed"
    call :add_test_result "%test_name%" "failure" "Docker not installed"
    exit /b 1
)

REM Pull the latest image
call :log "Pulling Docker image..."
docker pull noodlecore/noodlecore:latest >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    call :error "Failed to pull Docker image"
    call :add_test_result "%test_name%" "failure" "Failed to pull Docker image"
    exit /b 1
)

REM Create test container
call :log "Creating test container..."
docker run -d --name noodlecore-test -p 8081:8080 -v "%TEST_RESULTS_DIR%\docker-data:C:\app\data" noodlecore/noodlecore:latest >nul 2>&1
if errorlevel 1 (
    call :error "Failed to create container"
    call :add_test_result "%test_name%" "failure" "Failed to create container"
    exit /b 1
)

REM Wait for container to start
call :log "Waiting for container to start..."
timeout /t 10 /nobreak >nul

REM Check if container is running
docker ps --filter "name=noodlecore-test" --format "{{.Names}}" | findstr /c:"noodlecore-test" >nul
if errorlevel 1 (
    call :error "Container is not running"
    call :add_test_result "%test_name%" "failure" "Container is not running"
    docker logs noodlecore-test >> "%LOG_FILE%" 2>&1
    docker rm -f noodlecore-test >> "%LOG_FILE%" 2>&1
    exit /b 1
)

REM Test health endpoint
call :log "Testing health endpoint..."
for /f "tokens=2 delims=:" %%a in ('curl -s -o /dev/null -w "%%{http_code}" http://localhost:8081/health') do set health_response=%%a
if "!health_response!"=="200" (
    call :log "Health endpoint test passed"
) else (
    call :warn "Health endpoint test failed with status: !health_response!"
)

REM Test basic functionality
call :log "Testing basic functionality..."
for /f %%a in ('curl -s http://localhost:8081/api/v1/status') do set test_response=%%a
if not "!test_response!"=="" (
    call :log "Basic functionality test passed"
) else (
    call :warn "Basic functionality test failed"
)

REM Clean up
call :log "Cleaning up test container..."
docker stop noodlecore-test >> "%LOG_FILE%" 2>&1
docker rm noodlecore-test >> "%LOG_FILE%" 2>&1

REM Calculate duration
set end_time=%time%
call :calculate_duration "%start_time%" "%end_time%" duration
call :add_test_result "%test_name%" "success" "Docker deployment test completed in !duration!s"
goto :eof

REM Test Docker Compose deployment
:test_docker_compose_deployment
call :log "Testing Docker Compose deployment..."

set test_name=Docker Compose Deployment
set start_time=%time%

REM Check if Docker Compose is installed
docker-compose --version >nul 2>&1
if errorlevel 1 (
    call :error "Docker Compose not installed"
    call :add_test_result "%test_name%" "failure" "Docker Compose not installed"
    exit /b 1
)

REM Create test docker-compose.yml
echo version: '3.8' > "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo. >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo services: >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo   noodlecore: >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo     image: noodlecore/noodlecore:latest >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo     ports: >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo       - "8082:8080" >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo     volumes: >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo       - ./docker-data:/app/data >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo     environment: >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo       - NoodleCore_ENV=production >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo       - NoodleCore_LOG_LEVEL=INFO >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo     restart: unless-stopped >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo     healthcheck: >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo       test: ["CMD", "curl", "-f", "http://localhost:8080/health"] >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo       interval: 30s >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo       timeout: 10s >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo       retries: 3 >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo. >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo   postgres: >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo     image: postgres:15 >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo     environment: >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo       POSTGRES_DB: noodlecore_test >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo       POSTGRES_USER: test_user >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo       POSTGRES_PASSWORD: test_password >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo     volumes: >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo       - postgres_data:/var/lib/postgresql/data >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo     ports: >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo       - "5433:5432" >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo. >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo   redis: >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo     image: redis:7-alpine >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo     ports: >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo       - "6380:6379" >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo. >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo volumes: >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"
echo   postgres_data: >> "%TEST_RESULTS_DIR%\docker-compose-test.yml"

REM Start services
call :log "Starting Docker Compose services..."
docker-compose -f "%TEST_RESULTS_DIR%\docker-compose-test.yml" up -d >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    call :error "Failed to start Docker Compose services"
    call :add_test_result "%test_name%" "failure" "Failed to start Docker Compose services"
    exit /b 1
)

REM Wait for services to be healthy
call :log "Waiting for services to be healthy..."
timeout /t 30 /nobreak >nul

REM Check service health
for /f "tokens=4" %%a in ('docker-compose -f "%TEST_RESULTS_DIR%\docker-compose-test.yml" ps ^| findstr noodlecore') do set noodlecore_health=%%a
if "!noodlecore_health!"=="healthy" (
    call :log "NoodleCore service is healthy"
) else (
    call :warn "NoodleCore service health status: !noodlecore_health!"
)

REM Test endpoints
call :log "Testing endpoints..."
for /f "tokens=2 delims=:" %%a in ('curl -s -o /dev/null -w "%%{http_code}" http://localhost:8082/health') do set health_response=%%a
if "!health_response!"=="200" (
    call :log "Health endpoint test passed"
) else (
    call :warn "Health endpoint test failed with status: !health_response!"
)

REM Clean up
call :log "Cleaning up Docker Compose services..."
docker-compose -f "%TEST_RESULTS_DIR%\docker-compose-test.yml" down -v >> "%LOG_FILE%" 2>&1

REM Calculate duration
set end_time=%time%
call :calculate_duration "%start_time%" "%end_time%" duration
call :add_test_result "%test_name%" "success" "Docker Compose deployment test completed in !duration!s"
goto :eof

REM Test Kubernetes deployment
:test_kubernetes_deployment
call :log "Testing Kubernetes deployment..."

set test_name=Kubernetes Deployment
set start_time=%time%

REM Check if kubectl is installed
kubectl version --client >nul 2>&1
if errorlevel 1 (
    call :error "kubectl not installed"
    call :add_test_result "%test_name%" "failure" "kubectl not installed"
    exit /b 1
)

REM Check if Kubernetes cluster is accessible
kubectl cluster-info >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    call :error "Cannot access Kubernetes cluster"
    call :add_test_result "%test_name%" "failure" "Cannot access Kubernetes cluster"
    exit /b 1
)

REM Create test namespace
call :log "Creating test namespace..."
kubectl create namespace noodle-test --dry-run=client -o yaml | kubectl apply -f - >> "%LOG_FILE%" 2>&1

REM Create test deployment
call :log "Creating test deployment..."
echo apiVersion: apps/v1 > "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo kind: Deployment >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo metadata: >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo   name: noodle-test >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo   namespace: noodle-test >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo spec: >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo   replicas: 1 >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo   selector: >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo     matchLabels: >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo       app: noodle-test >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo   template: >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo     metadata: >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo       labels: >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo         app: noodle-test >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo     spec: >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo       containers: >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo       - name: noodle-test >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo         image: noodlecore/noodlecore:latest >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo         ports: >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo         - containerPort: 8080 >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo         env: >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo         - name: NoodleCore_ENV >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo           value: "test" >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo         - name: NoodleCore_LOG_LEVEL >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo           value: "DEBUG" >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo         resources: >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo           requests: >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo             memory: "256Mi" >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo             cpu: "250m" >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo           limits: >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo             memory: "512Mi" >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo             cpu: "500m" >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo         livenessProbe: >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo           httpGet: >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo             path: /health >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo             port: 8080 >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo           initialDelaySeconds: 30 >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo           periodSeconds: 10 >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo         readinessProbe: >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo           httpGet: >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo             path: /health >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo             port: 8080 >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo           initialDelaySeconds: 5 >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo           periodSeconds: 5 >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo --- >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo apiVersion: v1 >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo kind: Service >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo metadata: >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo   name: noodle-test-service >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo   namespace: noodle-test >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo spec: >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo   selector: >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo     app: noodle-test >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo   ports: >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo   - protocol: TCP >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo     port: 80 >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo     targetPort: 8080 >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"
echo   type: ClusterIP >> "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml"

kubectl apply -f "%TEST_RESULTS_DIR%\k8s-test-deployment.yaml" >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    call :error "Failed to create Kubernetes deployment"
    call :add_test_result "%test_name%" "failure" "Failed to create Kubernetes deployment"
    exit /b 1
)

REM Wait for deployment to be ready
call :log "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/noodle-test -n noodle-test >> "%LOG_FILE%" 2>&1

REM Check pod status
for /f "tokens=4" %%a in ('kubectl get pods -n noodle-test -l app=noodle-test -o jsonpath={.items[0].status.phase}') do set pod_status=%%a
if "!pod_status!"=="Running" (
    call :log "Pod is running"
) else (
    call :warn "Pod status: !pod_status!"
)

REM Clean up
call :log "Cleaning up Kubernetes resources..."
kubectl delete namespace noodle-test >> "%LOG_FILE%" 2>&1

REM Calculate duration
set end_time=%time%
call :calculate_duration "%start_time%" "%end_time%" duration
call :add_test_result "%test_name%" "success" "Kubernetes deployment test completed in !duration!s"
goto :eof

REM Test on-premises deployment
:test_on_premises_deployment
call :log "Testing on-premises deployment..."

set test_name=On-Premises Deployment
set start_time=%time%

REM Test system requirements
call :log "Testing system requirements..."

REM Check CPU
for /f "tokens=2 delims=:" %%a in ('wmic cpu get NumberOfCores /value') do set cpu_cores=%%a
if !cpu_cores! LSS 2 (
    call :warn "CPU cores less than 2: !cpu_cores!"
) else (
    call :log "CPU cores: !cpu_cores!"
)

REM Check memory
for /f "tokens=3 delims= " %%a in ('wmic OS get TotalVisibleMemorySize /value') do set memory_kb=%%a
set /a memory_gb=!memory_kb!/1024/1024
if !memory_gb! LSS 4 (
    call :warn "Memory less than 4GB: !memory_gb!GB"
) else (
    call :log "Memory: !memory_gb!GB"
)

REM Check disk space
for /f "tokens=4" %%a in ('dir C:\ ^| find "bytes free"') do set disk_space=%%a
call :log "Disk space: !disk_space!"

REM Test Python environment
call :log "Testing Python environment..."
python --version >nul 2>&1
if errorlevel 1 (
    call :warn "Python not available"
) else (
    for /f "tokens=2" %%a in ('python --version') do set python_version=%%a
    call :log "Python version: !python_version!"
    
    pip --version >nul 2>&1
    if errorlevel 1 (
        call :warn "pip not available"
    ) else (
        call :log "pip is available"
    )
)

REM Test network connectivity
ping -n 1 google.com >nul 2>&1
if errorlevel 1 (
    call :warn "Network connectivity test failed"
) else (
    call :log "Network connectivity test passed"
)

REM Calculate duration
set end_time=%time%
call :calculate_duration "%start_time%" "%end_time%" duration
call :add_test_result "%test_name%" "success" "On-premises deployment test completed in !duration!s"
goto :eof

REM Add test result to HTML report
:add_test_result
set test_name=%~1
set status=%~2
set message=%~3

echo     ^<div class="test-section"^> >> "%REPORT_FILE%"
echo         ^<h3^>%test_name%^</h3^> >> "%REPORT_FILE%"
echo         ^<div class="test-result %status%^> >> "%REPORT_FILE%"
echo             ^<strong^>Status:^</strong^> %status%^<br^> >> "%REPORT_FILE%"
echo             ^<strong^>Message:^</strong^> %message%^</div^> >> "%REPORT_FILE%"
echo     ^</div^> >> "%REPORT_FILE%"
goto :eof

REM Calculate duration between two times
:calculate_duration
setlocal
set start_time=%~1
set end_time=%~2

REM Parse start time
for /f "tokens=1-3 delims=:." %%a in ("%start_time%") do (
    set start_h=%%a
    set start_m=%%b
    set start_s=%%c
)

REM Parse end time
for /f "tokens=1-3 delims=:." %%a in ("%end_time%") do (
    set end_h=%%a
    set end_m=%%b
    set end_s=%%c
)

REM Convert to seconds
set /a start_total=!start_h!*3600 + !start_m!*60 + !start_s!
set /a end_total=!end_h!*3600 + !end_m!*60 + !end_s!

REM Calculate duration
set /a duration=!end_total! - !start_total!

if !duration! LSS 0 (
    set /a duration+=86400
)

endlocal & set %~3=!duration!
goto :eof

REM Generate final report
:generate_report
call :log "Generating final report..."

REM Add test results to HTML report
echo ^</body^> >> "%REPORT_FILE%"
echo ^</html^> >> "%REPORT_FILE%"

REM Display summary
echo %GREEN%
echo ==============================================
echo   Deployment Test Summary
echo ==============================================
echo %NC%

echo Test results saved to: %REPORT_FILE%
echo Test logs saved to: %LOG_FILE%

REM Show test results summary
echo.
echo Test Results Summary:
echo ====================

REM Count test results
find /c "success" "%REPORT_FILE%" >nul && set success_count=0
for /f %%a in ('find /c "success" "%REPORT_FILE%"') do set success_count=%%a

find /c "failure" "%REPORT_FILE%" >nul && set failure_count=0
for /f %%a in ('find /c "failure" "%REPORT_FILE%"') do set failure_count=%%a

find /c "warning" "%REPORT_FILE%" >nul && set warning_count=0
for /f %%a in ('find /c "warning" "%REPORT_FILE%"') do set warning_count=%%a

echo ✓ Tests passed: !success_count!
echo ✗ Tests failed: !failure_count!
echo ⚠ Tests with warnings: !warning_count!

if !failure_count! GTR 0 (
    echo.
    echo %RED%Some tests failed. Please check the report for details.%NC%
    exit /b 1
) else (
    echo.
    echo %GREEN%All tests passed successfully!%NC%
    exit /b 0
)
goto :eof

REM Main function
:main
call :show_banner
call :init_test_environment

REM Run all tests
call :test_docker_deployment
call :test_docker_compose_deployment
call :test_kubernetes_deployment
call :test_on_premises_deployment

REM Generate report
call :generate_report

endlocal