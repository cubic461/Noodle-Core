#!/bin/bash

# Kubernetes deployment script for NoodleCore
# Deploys the complete NoodleCore stack on Kubernetes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="noodle-core"
MONITORING_NAMESPACE="noodle-core-monitoring"
LOGGING_NAMESPACE="noodle-core-logging"
KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"
CLUSTER_NAME="${CLUSTER_NAME:-noodle-core-cluster}"
REGION="${REGION:-us-west-2}"

# Logging function
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        error "kubectl is not installed. Please install kubectl first."
    fi
    
    # Check if kubectl can connect to cluster
    if ! kubectl cluster-info &> /dev/null; then
        error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
    fi
    
    # Check if helm is installed
    if ! command -v helm &> /dev/null; then
        warn "Helm is not installed. Some features may not work properly."
    fi
    
    log "Prerequisites check completed."
}

# Create namespaces
create_namespaces() {
    log "Creating namespaces..."
    
    kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
    kubectl create namespace $MONITORING_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
    kubectl create namespace $LOGGING_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
    
    log "Namespaces created successfully."
}

# Apply core manifests
apply_core_manifests() {
    log "Applying core manifests..."
    
    # Apply namespace configuration
    kubectl apply -f k8s/namespace.yaml
    
    # Apply database configuration
    kubectl apply -f k8s/database.yaml
    
    # Apply core deployment
    kubectl apply -f k8s/deployment.yaml
    
    log "Core manifests applied successfully."
}

# Apply monitoring manifests
apply_monitoring_manifests() {
    log "Applying monitoring manifests..."
    
    # Apply monitoring configuration
    kubectl apply -f k8s/monitoring.yaml
    
    log "Monitoring manifests applied successfully."
}

# Apply logging manifests
apply_logging_manifests() {
    log "Applying logging manifests..."
    
    # Apply logging configuration
    kubectl apply -f k8s/logging.yaml
    
    log "Logging manifests applied successfully."
}

# Create secrets
create_secrets() {
    log "Creating secrets..."
    
    # Create database secret
    kubectl create secret generic noodle-core-secrets \
        --from-literal=database-url=postgresql://noodlecore:password@postgres-service:5432/noodlecore \
        --from-literal=redis-url=redis://redis-service:6379 \
        --from-literal=jwt-secret=$(openssl rand -hex 32) \
        --namespace=$NAMESPACE \
        --dry-run=client -o yaml | kubectl apply -f -
    
    # Create monitoring secrets
    kubectl create secret generic prometheus-alertmanager-config \
        --from-literal=alertmanager.yml=$(cat k8s/monitoring/alertmanager-config) \
        --namespace=$MONITORING_NAMESPACE \
        --dry-run=client -o yaml | kubectl apply -f -
    
    log "Secrets created successfully."
}

# Verify deployment
verify_deployment() {
    log "Verifying deployment..."
    
    # Check core pods
    log "Checking core pods..."
    kubectl get pods -n $NAMESPACE
    
    # Check monitoring pods
    log "Checking monitoring pods..."
    kubectl get pods -n $MONITORING_NAMESPACE
    
    # Check logging pods
    log "Checking logging pods..."
    kubectl get pods -n $LOGGING_NAMESPACE
    
    # Check services
    log "Checking services..."
    kubectl get services -n $NAMESPACE
    kubectl get services -n $MONITORING_NAMESPACE
    kubectl get services -n $LOGGING_NAMESPACE
    
    log "Deployment verification completed."
}

# Get deployment status
get_deployment_status() {
    log "Getting deployment status..."
    
    # Get deployment status
    kubectl get deployments -n $NAMESPACE
    kubectl get deployments -n $MONITORING_NAMESPACE
    kubectl get deployments -n $LOGGING_NAMESPACE
    
    # Get pod status
    kubectl get pods -n $NAMESPACE --watch &
    kubectl get pods -n $MONITORING_NAMESPACE --watch &
    kubectl get pods -n $LOGGING_NAMESPACE --watch &
    
    # Wait for user to stop watching
    read -p "Press Enter to stop watching..."
    
    log "Deployment status check completed."
}

# Scale deployment
scale_deployment() {
    local replicas=$1
    log "Scaling deployment to $replicas replicas..."
    
    kubectl scale deployment noodle-core-deployment --replicas=$replicas -n $NAMESPACE
    kubectl scale deployment prometheus --replicas=$replicas -n $MONITORING_NAMESPACE
    kubectl scale deployment grafana --replicas=$replicas -n $MONITORING_NAMESPACE
    kubectl scale deployment alertmanager --replicas=$replicas -n $MONITORING_NAMESPACE
    
    log "Deployment scaled successfully."
}

# Rollback deployment
rollback_deployment() {
    local deployment=$1
    local revision=$2
    log "Rolling back deployment $deployment to revision $revision..."
    
    kubectl rollout undo $deployment --to-revision=$revision -n $NAMESPACE
    
    log "Deployment rollback completed."
}

# Clean up
cleanup() {
    log "Cleaning up deployment..."
    
    read -p "Are you sure you want to delete all NoodleCore resources? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Delete all resources
        kubectl delete namespace $NAMESPACE --ignore-not-found=true
        kubectl delete namespace $MONITORING_NAMESPACE --ignore-not-found=true
        kubectl delete namespace $LOGGING_NAMESPACE --ignore-not-found=true
        
        # Delete persistent volumes
        kubectl delete pvc -l app=noodle-core -n $NAMESPACE --ignore-not-found=true
        kubectl delete pvc -l app=prometheus -n $MONITORING_NAMESPACE --ignore-not-found=true
        kubectl delete pvc -l app=grafana -n $MONITORING_NAMESPACE --ignore-not-found=true
        kubectl delete pvc -l app=alertmanager -n $MONITORING_NAMESPACE --ignore-not-found=true
        
        log "Cleanup completed."
    else
        log "Cleanup cancelled."
    fi
}

# Show help
show_help() {
    echo "NoodleCore Kubernetes Deployment Script"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  deploy      Deploy NoodleCore to Kubernetes"
    echo "  verify      Verify deployment status"
    echo "  status      Get deployment status"
    echo "  scale <n>   Scale deployment to n replicas"
    echo "  rollback <deployment> <revision>  Rollback deployment"
    echo "  cleanup     Clean up deployment"
    echo "  help        Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  NAMESPACE           Kubernetes namespace (default: noodle-core)"
    echo "  MONITORING_NAMESPACE Monitoring namespace (default: noodle-core-monitoring)"
    echo "  LOGGING_NAMESPACE   Logging namespace (default: noodle-core-logging)"
    echo "  KUBECONFIG          Kubernetes config file (default: \$HOME/.kube/config)"
    echo "  CLUSTER_NAME        Cluster name (default: noodle-core-cluster)"
    echo "  REGION              Region (default: us-west-2)"
}

# Main script
main() {
    case "${1:-deploy}" in
        deploy)
            check_prerequisites
            create_namespaces
            create_secrets
            apply_core_manifests
            apply_monitoring_manifests
            apply_logging_manifests
            verify_deployment
            log "Deployment completed successfully!"
            ;;
        verify)
            verify_deployment
            ;;
        status)
            get_deployment_status
            ;;
        scale)
            if [ -z "$2" ]; then
                error "Please specify the number of replicas"
            fi
            scale_deployment $2
            ;;
        rollback)
            if [ -z "$2" ] || [ -z "$3" ]; then
                error "Please specify deployment name and revision"
            fi
            rollback_deployment $2 $3
            ;;
        cleanup)
            cleanup
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main script
main "$@"