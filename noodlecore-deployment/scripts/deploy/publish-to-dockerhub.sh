#!/bin/bash

# Docker Hub publishing script for NoodleCore
# Automates the process of publishing Docker images to Docker Hub

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_NAME="noodlecore"
DOCKERHUB_USERNAME="noodlecore"
DOCKERHUB_REPOSITORY="${DOCKERHUB_USERNAME}/${PACKAGE_NAME}"
VERSION=$(python -c "import sys; sys.path.append('${PROJECT_ROOT}/src'); import noodlecore; print(noodlecore.__version__)" 2>/dev/null || echo "1.0.0")
TAGS=("${VERSION}" "latest" "latest-stable")

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

# Check if required tools are installed
check_requirements() {
    log "Checking requirements..."
    
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed"
    fi
    
    if ! command -v jq &> /dev/null; then
        warn "jq is not installed. Installing..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y jq
        elif command -v yum &> /dev/null; then
            sudo yum install -y jq
        elif command -v brew &> /dev/null; then
            brew install jq
        else
            error "Please install jq manually"
        fi
    fi
    
    log "Requirements check completed"
}

# Login to Docker Hub
docker_login() {
    log "Logging in to Docker Hub..."
    
    if [ -n "${DOCKERHUB_USERNAME}" ] && [ -n "${DOCKERHUB_PASSWORD}" ]; then
        echo "${DOCKERHUB_PASSWORD}" | docker login -u "${DOCKERHUB_USERNAME}" --password-stdin
    else
        docker login
    fi
    
    if [ $? -ne 0 ]; then
        error "Docker Hub login failed"
    fi
    
    log "Docker Hub login successful"
}

# Build Docker image
build_docker_image() {
    log "Building Docker image..."
    
    # Build the production Docker image
    docker build -f "${PROJECT_ROOT}/Dockerfile.production" \
        -t "${DOCKERHUB_REPOSITORY}:${VERSION}" \
        -t "${DOCKERHUB_REPOSITORY}:latest" \
        -t "${DOCKERHUB_REPOSITORY}:latest-stable" \
        "${PROJECT_ROOT}"
    
    if [ $? -ne 0 ]; then
        error "Docker image build failed"
    fi
    
    log "Docker image built successfully"
}

# Build multi-architecture images
build_multiarch() {
    log "Building multi-architecture images..."
    
    # Create buildx builder if it doesn't exist
    if ! docker buildx inspect multiarch &> /dev/null; then
        docker buildx create --name multiarch --use
    fi
    
    # Build and push multi-arch images
    docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 \
        -t "${DOCKERHUB_REPOSITORY}:${VERSION}" \
        -t "${DOCKERHUB_REPOSITORY}:latest" \
        -t "${DOCKERHUB_REPOSITORY}:latest-stable" \
        --push \
        "${PROJECT_ROOT}"
    
    if [ $? -ne 0 ]; then
        error "Multi-architecture build failed"
    fi
    
    log "Multi-architecture images built successfully"
}

# Push Docker images
push_docker_images() {
    log "Pushing Docker images..."
    
    # Push all tags
    for tag in "${TAGS[@]}"; do
        log "Pushing ${DOCKERHUB_REPOSITORY}:${tag}..."
        docker push "${DOCKERHUB_REPOSITORY}:${tag}"
        
        if [ $? -ne 0 ]; then
            error "Failed to push ${DOCKERHUB_REPOSITORY}:${tag}"
        fi
    done
    
    log "Docker images pushed successfully"
}

# Create and push manifest
create_manifest() {
    log "Creating Docker manifest..."
    
    # Create manifest for multi-arch support
    docker manifest create "${DOCKERHUB_REPOSITORY}:${VERSION}" \
        "${DOCKERHUB_REPOSITORY}:${VERSION}-amd64" \
        "${DOCKERHUB_REPOSITORY}:${VERSION}-arm64" \
        "${DOCKERHUB_REPOSITORY}:${VERSION}-armv7"
    
    docker manifest create "${DOCKERHUB_REPOSITORY}:latest" \
        "${DOCKERHUB_REPOSITORY}:latest-amd64" \
        "${DOCKERHUB_REPOSITORY}:latest-arm64" \
        "${DOCKERHUB_REPOSITORY}:latest-armv7"
    
    docker manifest create "${DOCKERHUB_REPOSITORY}:latest-stable" \
        "${DOCKERHUB_REPOSITORY}:latest-stable-amd64" \
        "${DOCKERHUB_REPOSITORY}:latest-stable-arm64" \
        "${DOCKERHUB_REPOSITORY}:latest-stable-armv7"
    
    # Push manifests
    for tag in "${TAGS[@]}"; do
        log "Pushing manifest for ${tag}..."
        docker manifest push "${DOCKERHUB_REPOSITORY}:${tag}"
    done
    
    log "Docker manifest created successfully"
}

# Verify images
verify_images() {
    log "Verifying Docker images..."
    
    # Check if images exist on Docker Hub
    for tag in "${TAGS[@]}"; do
        log "Checking ${DOCKERHUB_REPOSITORY}:${tag}..."
        if curl -s "https://hub.docker.com/v2/repositories/${DOCKERHUB_REPOSITORY}/tags/${tag}" | jq -e '.name' > /dev/null; then
            log "${DOCKERHUB_REPOSITORY}:${tag} exists on Docker Hub"
        else
            warn "${DOCKERHUB_REPOSITORY}:${tag} not found on Docker Hub"
        fi
    done
    
    log "Image verification completed"
}

# Create release notes
create_release_notes() {
    log "Creating release notes..."
    
    cat > "${PROJECT_ROOT}/DOCKER_RELEASE_NOTES.md" << EOF
# NoodleCore ${VERSION} Docker Release

## What's New

This release includes significant improvements to NoodleCore's Docker deployment capabilities.

### Features

- Multi-architecture support (linux/amd64, linux/arm64, linux/arm/v7)
- Enhanced security hardening
- Comprehensive monitoring and logging integration
- Production-ready Docker Compose configuration
- Kubernetes deployment manifests
- Health checks and readiness probes

### Improvements

- Optimized Docker image size
- Better layer caching
- Enhanced security scanning
- Improved startup performance
- Better resource management

### Usage

#### Pull the image
\`\`\`bash
docker pull ${DOCKERHUB_REPOSITORY}:${VERSION}
\`\`\`

#### Run the container
\`\`\`bash
docker run -d -p 8080:8080 ${DOCKERHUB_REPOSITORY}:${VERSION}
\`\`\`

#### Docker Compose
\`\`\`bash
docker-compose -f docker-compose.production.yml up -d
\`\`\`

### Environment Variables

- \`NoodleCore_ENV\`: Set to "production" for production mode
- \`NoodleCore_LOG_LEVEL\`: Logging level (DEBUG, INFO, WARNING, ERROR)
- \`NoodleCore_DATA_DIR\`: Data directory path
- \`NoodleCore_CONFIG_DIR\`: Configuration directory path
- \`DATABASE_URL\`: Database connection URL
- \`REDIS_URL\`: Redis connection URL

### Volumes

- \`/app/data\`: Application data
- \`/app/logs\`: Application logs
- \`/app/config\`: Application configuration

### Ports

- \`8080\`: Application HTTP port
- \`8443\`: Application HTTPS port

### Health Checks

The image includes health checks that can be monitored with:
\`\`\`bash
docker inspect --format='{{.State.Health.Status}}' <container_id>
\`\`\`

### Documentation

- Full documentation: https://noodlecore.readthedocs.io/
- Docker deployment guide: https://github.com/noodle/noodlecore/wiki/docker-deployment
- API documentation: https://github.com/noodle/noodlecore/wiki/api

### Support

- GitHub Issues: https://github.com/noodle/noodlecore/issues
- Documentation: https://noodlecore.readthedocs.io/
- Community: https://discord.gg/noodlecore

### License

This project is licensed under the MIT License - see the LICENSE file for details.
EOF
    
    log "Release notes created successfully"
}

# Main function
main() {
    log "Starting Docker Hub publishing process..."
    log "Version: ${VERSION}"
    log "Repository: ${DOCKERHUB_REPOSITORY}"
    
    # Check requirements
    check_requirements
    
    # Login to Docker Hub
    docker_login
    
    # Ask for build type
    echo
    echo "Select build type:"
    echo "1) Single architecture (current platform)"
    echo "2) Multi-architecture (amd64, arm64, arm/v7)"
    echo "3) Cancel"
    echo
    
    read -p "Enter your choice (1-3): " choice
    
    case $choice in
        1)
            build_docker_image
            push_docker_images
            ;;
        2)
            build_multiarch
            ;;
        3)
            log "Publishing cancelled"
            exit 0
            ;;
        *)
            error "Invalid choice"
            ;;
    esac
    
    # Create manifest
    create_manifest
    
    # Verify images
    verify_images
    
    # Create release notes
    create_release_notes
    
    log "Docker Hub publishing completed successfully!"
    log "Images available at: https://hub.docker.com/r/${DOCKERHUB_REPOSITORY}"
}

# Run main function
main "$@"