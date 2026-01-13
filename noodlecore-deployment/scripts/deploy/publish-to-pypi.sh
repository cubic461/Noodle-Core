
#!/bin/bash

# PyPI publishing script for NoodleCore
# Automates the process of publishing packages to PyPI

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="${PROJECT_ROOT}/dist"
PACKAGE_NAME="noodlecore"
TWINE_REPOSITORY_URL="https://upload.pypi.org/legacy/"
TEST_TWINE_REPOSITORY_URL="https://test.pypi.org/legacy/"

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
    
    if ! command -v python3 &> /dev/null; then
        error "Python3 is not installed"
    fi
    
    if ! command -v twine &> /dev/null; then
        warn "Twine is not installed. Installing..."
        pip install twine
    fi
    
    if ! command -v build &> /dev/null; then
        warn "Build package is not installed. Installing..."
        pip install build
    fi
    
    log "Requirements check completed"
}

# Build the package
build_package() {
    log "Building package..."
    
    # Clean previous builds
    rm -rf "${DIST_DIR}"
    mkdir -p "${DIST_DIR}"
    
    # Build the package
    python3 -m build
    
    # Check if build was successful
    if [ ! -d "${DIST_DIR}" ] || [ -z "$(ls -A "${DIST_DIR}")" ]; then
        error "Package build failed"
    fi
    
    log "Package built successfully"
    ls -la "${DIST_DIR}/"
}

# Check package integrity
check_package() {
    log "Checking package integrity..."
    
    # Check for common issues
    twine check "${DIST_DIR}"/*
    
    # Check for sensitive information
    if grep -r -i "password\|secret\|key" "${DIST_DIR}"/* --exclude-dir=.git; then
        warn "Potential sensitive information found in package"
        read -p "Continue publishing? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    log "Package integrity check completed"
}

# Upload to Test PyPI
upload_test_pypi() {
    log "Uploading to Test PyPI..."
    
    twine upload --repository-url "${TEST_TWINE_REPOSITORY_URL}" "${DIST_DIR}"/*
    
    log "Package uploaded to Test PyPI successfully"
}

# Upload to Production PyPI
upload_production_pypi() {
    log "Uploading to Production PyPI..."
    
    # Ask for confirmation
    read -p "Are you sure you want to upload to Production PyPI? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Upload cancelled"
        exit 0
    fi
    
    twine upload "${DIST_DIR}"/*
    
    log "Package uploaded to Production PyPI successfully"
}

# Create release notes
create_release_notes() {
    log "Creating release notes..."
    
    local version=$(python3 -c "import sys;