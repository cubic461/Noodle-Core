@echo off
REM Kubernetes deployment script for NoodleCore (Windows)
REM Deploys the complete NoodleCore stack on Kubernetes

setlocal enabledelayedexpansion

REM Configuration
set NAMESPACE=noodle-core
set MONITORING_NAMESPACE=noodle-core-monitoring
set LOGGING_NAMESPACE=noodle-core-logging
set KUBECONFIG=%KUBECONFIG:%USERPROFILE%=%USERPROFILE%\kubeconfig%
set CLUSTER_NAME=noodle-core-cluster
set REGION=us-west-2

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

REM Check prerequisites
:check_prerequisites
call :log "Checking prerequisites..."

REM Check if kubectl is installed
kubectl --version >nul 2>&1
if errorlevel 1 (
    call :error "kubectl is not installed. Please install kubectl first."
    exit /b 1
)

REM Check if kubectl can connect to cluster
kubectl cluster-info >nul 2>&1
if errorlevel 1 (
    call :error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
    exit /b 1
)

REM Check if helm is installed
helm version >nul 2>&1
if errorlevel 1 (
    call :warn "Helm is not installed. Some features may not work properly."
)

call :log "Prerequisites check completed."
goto :eof

REM Create namespaces
:create_namespaces
call :log "Creating namespaces..."

kubectl create namespace %NAMESPACE% --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace %MONITORING_NAMESPACE% --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace %LOGGING_NAMESPACE% --dry-run=client -o yaml | kubectl apply -f -

call :log "Namespaces created successfully."
goto :eof

REM Apply core manifests
:apply_core_manifests
call :log "Applying core manifests..."

REM Apply namespace configuration
kubectl apply -f k8s\namespace.yaml

REM Apply database configuration
kubectl apply -f k8s\database.yaml

REM Apply core deployment
kubectl apply -f k8s\deployment.yaml

call :log "Core manifests applied successfully."
goto :eof

REM Apply monitoring manifests
:apply_monitoring_manifests
call :log "Applying monitoring manifests..."

REM Apply monitoring configuration
kubectl apply -f k8s\monitoring.yaml

call :log "Monitoring manifests applied successfully."
goto :eof

REM Apply logging manifests
:apply_logging_manifests
call :log "Applying logging manifests..."

REM Apply logging configuration
kubectl apply -f k8s\logging.yaml

call :log "Logging manifests applied successfully."
goto :eof

REM Create secrets
:create_secrets
call :log "Creating secrets..."

REM Create database secret
kubectl create secret generic noodle-core-secrets ^
    --from-literal=database-url=postgresql://noodlecore:password@postgres-service:5432/noodlecore ^
    --from-literal=redis-url=redis://redis-service:6379 ^
    --from-literal=jwt-secret=openssl rand -hex 32 ^
    --namespace=%NAMESPACE% ^
    --dry-run=client -o yaml | kubectl apply -f -

REM Create monitoring secrets
kubectl create secret generic prometheus-alertmanager-config ^
    --from-literal=alertmanager.yml=$(cat k8s\monitoring\alertmanager-config) ^
    --namespace=%MONITORING_NAMESPACE% ^
    --dry-run=client -o yaml | kubectl apply -f -

call :log "Secrets created successfully."
goto :eof

REM Verify deployment
:verify_deployment
call :log "Verifying deployment..."

REM Check core pods
call :log "Checking core pods..."
kubectl get pods -n %NAMESPACE%

REM Check monitoring pods
call :log "Checking monitoring pods..."
kubectl get pods -n %MONITORING_NAMESPACE%

REM Check logging pods
call :log "Checking logging pods..."
kubectl get pods -n %LOGGING_NAMESPACE%

REM Check services
call :log "Checking services..."
kubectl get services -n %NAMESPACE%
kubectl get services -n %MONITORING_NAMESPACE%
kubectl get services -n %LOGGING_NAMESPACE%

call :log "Deployment verification completed."
goto :eof

REM Get deployment status
:get_deployment_status
call :log "Getting deployment status..."

REM Get deployment status
kubectl get deployments -n %NAMESPACE%
kubectl get deployments -n %MONITORING_NAMESPACE%
kubectl get deployments -n %LOGGING_NAMESPACE%

REM Get pod status
call :log "Watching pod status..."
kubectl get pods -n %NAMESPACE% --watch
kubectl get pods -n %MONITORING_NAMESPACE% --watch
kubectl get pods -n %LOGGING_NAMESPACE% --watch

call :log "Deployment status check completed."
goto :eof

REM Scale deployment
:scale_deployment
set replicas=%~1
call :log "Scaling deployment to %replicas% replicas..."

kubectl scale deployment noodle-core-deployment --replicas=%replicas% -n %NAMESPACE%
kubectl scale deployment prometheus --replicas=%replicas% -n %MONITORING_NAMESPACE%
kubectl scale deployment grafana --replicas=%replicas% -n %MONITORING_NAMESPACE%
kubectl scale deployment alertmanager --replicas=%replicas% -n %MONITORING_NAMESPACE%

call :log "Deployment scaled successfully."
goto :eof

REM Rollback deployment
:rollback_deployment
set deployment=%~1
set revision=%~2
call :log "Rolling back deployment %deployment% to revision %revision%..."

kubectl rollout undo %deployment% --to-revision=%revision% -n %NAMESPACE%

call :log "Deployment rollback completed."
goto :eof

REM Clean up
:cleanup
call :log "Cleaning up deployment..."

set /p "cleanup=Are you sure you want to delete all NoodleCore resources? (y/N): "
if /i "%cleanup%"=="y" (
    REM Delete all resources
    kubectl delete namespace %NAMESPACE% --ignore-not-found=true
    kubectl delete namespace %MONITORING_NAMESPACE% --ignore-not-found=true
    kubectl delete namespace %LOGGING_NAMESPACE% --ignore-not-found=true
    
    REM Delete persistent volumes
    kubectl delete pvc -l app=noodle-core -n %NAMESPACE% --ignore-not-found=true
    kubectl delete pvc -l app=prometheus -n %MONITORING_NAMESPACE% --ignore-not-found=true
    kubectl delete pvc -l app=grafana -n %MONITORING_NAMESPACE% --ignore-not-found=true
    kubectl delete pvc -l app=alertmanager -n %MONITORING_NAMESPACE% --ignore-not-found=true
    
    call :log "Cleanup completed."
) else (
    call :log "Cleanup cancelled."
)
goto :eof

REM Show help
:show_help
echo NoodleCore Kubernetes Deployment Script
echo.
echo Usage: %~n0 [command]
echo.
echo Commands:
echo   deploy      Deploy NoodleCore to Kubernetes
echo   verify      Verify deployment status
echo   status      Get deployment status
echo   scale ^<n^>   Scale deployment to n replicas
echo   rollback ^<deployment^> ^<revision^>  Rollback deployment
echo   cleanup     Clean up deployment
echo   help        Show this help message
echo.
echo Environment Variables:
echo   NAMESPACE           Kubernetes namespace ^(default: noodle-core^)
echo   MONITORING_NAMESPACE Monitoring namespace ^(default: noodle-core-monitoring^)
echo   LOGGING_NAMESPACE   Logging namespace ^(default: noodle-core-logging^)
echo   KUBECONFIG          Kubernetes config file ^(default: %%USERPROFILE%%\.kube\config^)
echo   CLUSTER_NAME        Cluster name ^(default: noodle-core-cluster^)
echo   REGION              Region ^(default: us-west-2^)
goto :eof

REM Main script
:main
if "%~1"=="" (
    set command=deploy
) else (
    set command=%~1
)

if "%command%"=="deploy" (
    call :check_prerequisites
    call :create_namespaces
    call :create_secrets
    call :apply_core_manifests
    call :apply_monitoring_manifests
    call :apply_logging_manifests
    call :verify_deployment
    call :log "Deployment completed successfully!"
) else if "%command%"=="verify" (
    call :verify_deployment
) else if "%command%"=="status" (
    call :get_deployment_status
) else if "%command%"=="scale" (
    if "%~2"=="" (
        call :error "Please specify the number of replicas"
        exit /b 1
    )
    call :scale_deployment %~2
) else if "%command%"=="rollback" (
    if "%~2"=="" if "%~3"=="" (
        call :error "Please specify deployment name and revision"
        exit /b 1
    )
    call :rollback_deployment %~2 %~3
) else if "%command%"=="cleanup" (
    call :cleanup
) else if "%command%"=="help" if "%~1"=="--help" if "%~1"=="-h" (
    call :show_help
) else (
    call :error "Unknown command: %command%"
    call :show_help
    exit /b 1
)

endlocal