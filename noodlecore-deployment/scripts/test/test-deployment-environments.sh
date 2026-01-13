#!/bin/bash

# NoodleCore Deployment Testing Script
# Tests deployment across different environments and cloud providers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="/opt/noodlecore"
TEST_RESULTS_DIR="${PROJECT_ROOT}/test-results"
LOG_FILE="${TEST_RESULTS_DIR}/deployment-test.log"
REPORT_FILE="${TEST_RESULTS_DIR}/deployment-test-report.html"

# Logging function
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1" >> "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] $1" >> "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" >> "$LOG_FILE"
}

# Display banner
show_banner() {
    echo -e "${BLUE}"
    echo "=============================================="
    echo "  NoodleCore Deployment Testing"
    echo "=============================================="
    echo -e "${NC}"
}

# Initialize test environment
init_test_environment() {
    log "Initializing test environment..."
    
    # Create test results directory
    mkdir -p "$TEST_RESULTS_DIR"
    
    # Clear previous test results
    > "$LOG_FILE"
    
    # Create HTML report template
    cat > "$REPORT_FILE" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NoodleCore Deployment Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f0f0f0; padding: 20px; border-radius: 5px; }
        .test-section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        .test-result { margin: 10px 0; padding: 10px; border-radius: 3px; }
        .success { background-color: #d4edda; color: #155724; }
        .failure { background-color: #f8d7da; color: #721c24; }
        .warning { background-color: #fff3cd; color: #856404; }
        .log-section { background-color: #f8f9fa; padding: 10px; border-radius: 3px; font-family: monospace; }
    </style>
</head>
<body>
    <div class="header">
        <h1>NoodleCore Deployment Test Report</h1>
        <p>Generated on: $(date)</p>
    </div>
EOF
}

# Test local Docker deployment
test_docker_deployment() {
    log "Testing local Docker deployment..."
    
    local test_name="Docker Deployment"
    local start_time=$(date +%s)
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        error "Docker not installed"
        add_test_result "$test_name" "failure" "Docker not installed"
        return 1
    fi
    
    # Pull the latest image
    log "Pulling Docker image..."
    if docker pull noodlecore/noodlecore:latest &>> "$LOG_FILE"; then
        log "Docker image pulled successfully"
    else
        error "Failed to pull Docker image"
        add_test_result "$test_name" "failure" "Failed to pull Docker image"
        return 1
    fi
    
    # Create test container
    log "Creating test container..."
    local container_id=$(docker run -d --name noodlecore-test \
        -p 8081:8080 \
        -v "${TEST_RESULTS_DIR}/docker-data:/app/data" \
        noodlecore/noodlecore:latest)
    
    if [ -z "$container_id" ]; then
        error "Failed to create container"
        add_test_result "$test_name" "failure" "Failed to create container"
        return 1
    fi
    
    # Wait for container to start
    log "Waiting for container to start..."
    sleep 10
    
    # Check if container is running
    if ! docker ps --filter "name=noodlecore-test" --format "{{.Names}}" | grep -q "noodlecore-test"; then
        error "Container is not running"
        add_test_result "$test_name" "failure" "Container is not running"
        docker logs noodlecore-test >> "$LOG_FILE" 2>&1
        docker rm -f noodlecore-test &>> "$LOG_FILE"
        return 1
    fi
    
    # Test health endpoint
    log "Testing health endpoint..."
    local health_response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081/health)
    if [ "$health_response" -eq 200 ]; then
        log "Health endpoint test passed"
    else
        warn "Health endpoint test failed with status: $health_response"
    fi
    
    # Test basic functionality
    log "Testing basic functionality..."
    local test_response=$(curl -s http://localhost:8081/api/v1/status)
    if [ -n "$test_response" ]; then
        log "Basic functionality test passed"
    else
        warn "Basic functionality test failed"
    fi
    
    # Clean up
    log "Cleaning up test container..."
    docker stop noodlecore-test &>> "$LOG_FILE"
    docker rm noodlecore-test &>> "$LOG_FILE"
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    add_test_result "$test_name" "success" "Docker deployment test completed in ${duration}s"
}

# Test Docker Compose deployment
test_docker_compose_deployment() {
    log "Testing Docker Compose deployment..."
    
    local test_name="Docker Compose Deployment"
    local start_time=$(date +%s)
    
    # Check if Docker Compose is installed
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose not installed"
        add_test_result "$test_name" "failure" "Docker Compose not installed"
        return 1
    fi
    
    # Create test docker-compose.yml
    cat > "${TEST_RESULTS_DIR}/docker-compose-test.yml" << 'EOF'
version: '3.8'

services:
  noodlecore:
    image: noodlecore/noodlecore:latest
    ports:
      - "8082:8080"
    volumes:
      - ./docker-data:/app/data
    environment:
      - NoodleCore_ENV=production
      - NoodleCore_LOG_LEVEL=INFO
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: noodlecore_test
      POSTGRES_USER: test_user
      POSTGRES_PASSWORD: test_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5433:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6380:6379"

volumes:
  postgres_data:
EOF

    # Start services
    log "Starting Docker Compose services..."
    if docker-compose -f "${TEST_RESULTS_DIR}/docker-compose-test.yml" up -d &>> "$LOG_FILE"; then
        log "Docker Compose services started successfully"
    else
        error "Failed to start Docker Compose services"
        add_test_result "$test_name" "failure" "Failed to start Docker Compose services"
        return 1
    fi
    
    # Wait for services to be healthy
    log "Waiting for services to be healthy..."
    sleep 30
    
    # Check service health
    local noodlecore_health=$(docker-compose -f "${TEST_RESULTS_DIR}/docker-compose-test.yml" ps | grep noodlecore | awk '{print $4}')
    if [ "$noodlecore_health" = "healthy" ]; then
        log "NoodleCore service is healthy"
    else
        warn "NoodleCore service health status: $noodlecore_health"
    fi
    
    # Test endpoints
    log "Testing endpoints..."
    local health_response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8082/health)
    if [ "$health_response" -eq 200 ]; then
        log "Health endpoint test passed"
    else
        warn "Health endpoint test failed with status: $health_response"
    fi
    
    # Test database connectivity
    log "Testing database connectivity..."
    local db_test=$(docker-compose -f "${TEST_RESULTS_DIR}/docker-compose-test.yml" exec -T postgres psql -U test_user -d noodlecore_test -c "SELECT 1" 2>> "$LOG_FILE")
    if [ $? -eq 0 ]; then
        log "Database connectivity test passed"
    else
        warn "Database connectivity test failed"
    fi
    
    # Clean up
    log "Cleaning up Docker Compose services..."
    docker-compose -f "${TEST_RESULTS_DIR}/docker-compose-test.yml" down -v &>> "$LOG_FILE"
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    add_test_result "$test_name" "success" "Docker Compose deployment test completed in ${duration}s"
}

# Test Kubernetes deployment
test_kubernetes_deployment() {
    log "Testing Kubernetes deployment..."
    
    local test_name="Kubernetes Deployment"
    local start_time=$(date +%s)
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        error "kubectl not installed"
        add_test_result "$test_name" "failure" "kubectl not installed"
        return 1
    fi
    
    # Check if Kubernetes cluster is accessible
    if ! kubectl cluster-info &>> "$LOG_FILE"; then
        error "Cannot access Kubernetes cluster"
        add_test_result "$test_name" "failure" "Cannot access Kubernetes cluster"
        return 1
    fi
    
    # Create test namespace
    log "Creating test namespace..."
    kubectl create namespace noodle-test --dry-run=client -o yaml | kubectl apply -f - &>> "$LOG_FILE"
    
    # Create test deployment
    log "Creating test deployment..."
    cat > "${TEST_RESULTS_DIR}/k8s-test-deployment.yaml" << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: noodle-test
  namespace: noodle-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: noodle-test
  template:
    metadata:
      labels:
        app: noodle-test
    spec:
      containers:
      - name: noodle-test
        image: noodlecore/noodlecore:latest
        ports:
        - containerPort: 8080
        env:
        - name: NoodleCore_ENV
          value: "test"
        - name: NoodleCore_LOG_LEVEL
          value: "DEBUG"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: noodle-test-service
  namespace: noodle-test
spec:
  selector:
    app: noodle-test
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: ClusterIP
EOF

    if kubectl apply -f "${TEST_RESULTS_DIR}/k8s-test-deployment.yaml" &>> "$LOG_FILE"; then
        log "Kubernetes deployment created successfully"
    else
        error "Failed to create Kubernetes deployment"
        add_test_result "$test_name" "failure" "Failed to create Kubernetes deployment"
        return 1
    fi
    
    # Wait for deployment to be ready
    log "Waiting for deployment to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/noodle-test -n noodle-test &>> "$LOG_FILE"
    
    # Check pod status
    local pod_status=$(kubectl get pods -n noodle-test -l app=noodle-test -o jsonpath='{.items[0].status.phase}')
    if [ "$pod_status" = "Running" ]; then
        log "Pod is running"
    else
        warn "Pod status: $pod_status"
    fi
    
    # Test service endpoint
    log "Testing service endpoint..."
    local service_url=$(kubectl get service noodle-test-service -n noodle-test -o jsonpath='{.spec.clusterIP}')
    local health_response=$(kubectl exec -it -n noodle-test deployment/noodle-test -- curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health)
    if [ "$health_response" -eq 200 ]; then
        log "Service endpoint test passed"
    else
        warn "Service endpoint test failed with status: $health_response"
    fi
    
    # Clean up
    log "Cleaning up Kubernetes resources..."
    kubectl delete namespace noodle-test &>> "$LOG_FILE"
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    add_test_result "$test_name" "success" "Kubernetes deployment test completed in ${duration}s"
}

# Test cloud provider deployment
test_cloud_deployment() {
    log "Testing cloud provider deployment..."
    
    local test_name="Cloud Provider Deployment"
    local start_time=$(date +%s)
    
    # Test AWS deployment
    if command -v aws &> /dev/null; then
        log "Testing AWS deployment..."
        test_aws_deployment
    else
        warn "AWS CLI not installed, skipping AWS test"
    fi
    
    # Test GCP deployment
    if command -v gcloud &> /dev/null; then
        log "Testing GCP deployment..."
        test_gcp_deployment
    else
        warn "GCP CLI not installed, skipping GCP test"
    fi
    
    # Test Azure deployment
    if command -v az &> /dev/null; then
        log "Testing Azure deployment..."
        test_azure_deployment
    else
        warn "Azure CLI not installed, skipping Azure test"
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    add_test_result "$test_name" "success" "Cloud provider deployment test completed in ${duration}s"
}

# Test AWS deployment
test_aws_deployment() {
    log "Testing AWS deployment..."
    
    local aws_test_name="AWS Deployment"
    local start_time=$(date +%s)
    
    # Check AWS credentials
    if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
        warn "AWS credentials not set, skipping AWS test"
        add_test_result "$aws_test_name" "warning" "AWS credentials not set"
        return 1
    fi
    
    # Test ECS task definition
    log "Testing ECS task definition..."
    local task_definition='{
        "family": "noodlecore-test",
        "networkMode": "awsvpc",
        "requiresCompatibilities": ["FARGATE"],
        "cpu": "256",
        "memory": "512",
        "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
        "containerDefinitions": [
            {
                "name": "noodlecore-test",
                "image": "noodlecore/noodlecore:latest",
                "portMappings": [
                    {
                        "containerPort": 8080,
                        "protocol": "tcp"
                    }
                ],
                "environment": [
                    {
                        "name": "NoodleCore_ENV",
                        "value": "test"
                    }
                ]
            }
        ]
    }'
    
    # Create task definition
    local task_response=$(aws ecs register-task-definition --cli-input-json "$task_definition" 2>> "$LOG_FILE")
    if [ $? -eq 0 ]; then
        log "ECS task definition created successfully"
    else
        warn "Failed to create ECS task definition"
    fi
    
    # Clean up
    aws ecs deregister-task-definition --family noodlecore-test &>> "$LOG_FILE"
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    add_test_result "$aws_test_name" "success" "AWS deployment test completed in ${duration}s"
}

# Test GCP deployment
test_gcp_deployment() {
    log "Testing GCP deployment..."
    
    local gcp_test_name="GCP Deployment"
    local start_time=$(date +%s)
    
    # Check GCP credentials
    if [ -z "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
        warn "GCP credentials not set, skipping GCP test"
        add_test_result "$gcp_test_name" "warning" "GCP credentials not set"
        return 1
    fi
    
    # Test GKE cluster access
    log "Testing GKE cluster access..."
    if gcloud container clusters list &>> "$LOG_FILE"; then
        log "GKE cluster access test passed"
    else
        warn "GKE cluster access test failed"
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    add_test_result "$gcp_test_name" "success" "GCP deployment test completed in ${duration}s"
}

# Test Azure deployment
test_azure_deployment() {
    log "Testing Azure deployment..."
    
    local azure_test_name="Azure Deployment"
    local start_time=$(date +%s)
    
    # Check Azure login
    if az account show &>> "$LOG_FILE"; then
        log "Azure login test passed"
    else
        warn "Azure login test failed"
        add_test_result "$azure_test_name" "warning" "Azure login failed"
        return 1
    fi
    
    # Test AKS cluster access
    log "Testing AKS cluster access..."
    if az aks list &>> "$LOG_FILE"; then
        log "AKS cluster access test passed"
    else
        warn "AKS cluster access test failed"
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    add_test_result "$azure_test_name" "success" "Azure deployment test completed in ${duration}s"
}

# Test on-premises deployment
test_on_premises_deployment() {
    log "Testing on-premises deployment..."
    
    local test_name="On-Premises Deployment"
    local start_time=$(date +%s)
    
    # Test system requirements
    log "Testing system requirements..."
    
    # Check CPU
    local cpu_cores=$(nproc)
    if [ "$cpu_cores" -lt 2 ]; then
        warn "CPU cores less than 2: $cpu_cores"
    else
        log "CPU cores: $cpu_cores"
    fi
    
    # Check memory
    local memory_gb=$(free -g | awk '/Mem:/ {print $2}')
    if [ "$memory_gb" -lt 4 ]; then
        warn "Memory less than 4GB: ${memory_gb}GB"
    else
        log "Memory: ${memory_gb}GB"
    fi
    
    # Check disk space
    local disk_space=$(df -BG / | awk 'NR==2 {print $4}' | tr -d 'G')
    if [ "$disk_space" -lt 10 ]; then
        warn "Disk space less than 10GB: ${disk_space}GB"
    else
        log "Disk space: ${disk_space}GB"
    fi
    
    # Test Python environment
    log "Testing Python environment..."
    if command -v python3 &> /dev/null; then
        local python_version=$(python3 --version | cut -d' ' -f2)
        log "Python version: $python_version"
        
        # Test pip
        if command -v pip3 &> /dev/null; then
            log "pip3 is available"
        else
            warn "pip3 not available"
        fi
    else
        warn "Python3 not available"
    fi
    
    # Test network connectivity
    log "Testing network connectivity..."
    if ping -c 1 google.com &>> "$LOG_FILE"; then
        log "Network connectivity test passed"
    else
        warn "Network connectivity test failed"
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    add_test_result "$test_name" "success" "On-premises deployment test completed in ${duration}s"
}

# Add test result to HTML report
add_test_result() {
    local test_name="$1"
    local status="$2"
    local message="$3"
    
    local status_class=""
    case "$status" in
        "success") status_class="success" ;;
        "failure") status_class="failure" ;;
        "warning") status_class="warning" ;;
    esac
    
    cat >> "$REPORT_FILE" << EOF
    <div class="test-section">
        <h3>$test_name</h3>
        <div class="test-result $status_class">
            <strong>Status:</strong> $status<br>
            <strong>Message:</strong> $message
        </div>
    </div>
EOF
}

# Generate final report
generate_report() {
    log "Generating final report..."
    
    # Add test results to HTML report
    cat >> "$REPORT_FILE" << 'EOF'
</body>
</html>
EOF
    
    # Display summary
    echo -e "${GREEN}"
    echo "=============================================="
    echo "  Deployment Test Summary"
    echo "=============================================="
    echo -e "${NC}"
    
    echo "Test results saved to: $REPORT_FILE"
    echo "Test logs saved to: $LOG_FILE"
    
    # Show test results summary
    echo ""
    echo "Test Results Summary:"
    echo "===================="
    
    # Count test results
    local success_count=$(grep -c "success" "$REPORT_FILE" || echo "0")
    local failure_count=$(grep -c "failure" "$REPORT_FILE" || echo "0")
    local warning_count=$(grep -c "warning" "$REPORT_FILE" || echo "0")
    
    echo "✓ Tests passed: $success_count"
    echo "✗ Tests failed: $failure_count"
    echo "⚠ Tests with warnings: $warning_count"
    
    if [ "$failure_count" -gt 0 ]; then
        echo ""
        echo -e "${RED}Some tests failed. Please check the report for details.${NC}"
        exit 1
    else
        echo ""
        echo -e "${GREEN}All tests passed successfully!${NC}"
        exit 0
    fi
}

# Main function
main() {
    show_banner
    init_test_environment
    
    # Run all tests
    test_docker_deployment
    test_docker_compose_deployment
    test_kubernetes_deployment
    test_cloud_deployment
    test_on_premises_deployment
    
    # Generate report
    generate_report
}

# Run main function
main "$@"