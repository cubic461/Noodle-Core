#!/bin/bash

# NoodleCore Installation Script
# One-click installation script for NoodleCore on Linux/macOS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PACKAGE_NAME="noodlecore"
VERSION="1.0.0"
INSTALL_DIR="/opt/${PACKAGE_NAME}"
BIN_DIR="/usr/local/bin"
SERVICE_USER="noodle"
SERVICE_NAME="noodlecore"

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

# Display banner
show_banner() {
    echo -e "${BLUE}"
    echo "=============================================="
    echo "  NoodleCore Installation Script"
    echo "=============================================="
    echo -e "${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log "Running as root - proceeding with system-wide installation"
    else
        warn "Not running as root"
        warn "Some features may require sudo privileges"
        read -p "Continue with user installation? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
        INSTALL_DIR="$HOME/.local/${PACKAGE_NAME}"
        BIN_DIR="$HOME/.local/bin"
    fi
}

# Check system requirements
check_requirements() {
    log "Checking system requirements..."
    
    # Check Python version
    if ! command -v python3 &> /dev/null; then
        error "Python 3 is not installed. Please install Python 3.8 or later."
    fi
    
    local python_version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    log "Python version: $python_version"
    
    if ! python3 -c "import sys; sys.exit(0 if sys.version_info >= (3, 8) else 1)"; then
        error "Python 3.8 or later is required"
    fi
    
    # Check pip
    if ! command -v pip3 &> /dev/null; then
        error "pip3 is not installed"
    fi
    
    # Check available disk space
    local available_space=$(df -k . | awk 'NR==2 {print $4}')
    if [ "$available_space" -lt 100000 ]; then
        warn "Less than 100MB of disk space available"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    log "System requirements check completed"
}

# Install system dependencies
install_dependencies() {
    log "Installing system dependencies..."
    
    if command -v apt-get &> /dev/null; then
        # Debian/Ubuntu
        sudo apt-get update
        sudo apt-get install -y \
            python3-pip \
            python3-venv \
            python3-dev \
            build-essential \
            libssl-dev \
            libffi-dev \
            curl \
            wget \
            git
    elif command -v yum &> /dev/null; then
        # CentOS/RHEL
        sudo yum install -y \
            python3-pip \
            python3-venv \
            python3-devel \
            gcc \
            openssl-devel \
            libffi-devel \
            curl \
            wget \
            git
    elif command -v brew &> /dev/null; then
        # macOS
        brew install python3
    else
        warn "Unable to detect package manager"
        warn "Please install Python 3.8+ and pip manually"
    fi
    
    log "System dependencies installed"
}

# Create installation directory
create_directories() {
    log "Creating installation directories..."
    
    sudo mkdir -p "${INSTALL_DIR}"
    sudo mkdir -p "${INSTALL_DIR}/data"
    sudo mkdir -p "${INSTALL_DIR}/logs"
    sudo mkdir -p "${INSTALL_DIR}/config"
    sudo mkdir -p "${INSTALL_DIR}/cache"
    
    # Set permissions
    if [[ $EUID -eq 0 ]]; then
        sudo chown -R "${SERVICE_USER}:${SERVICE_USER}" "${INSTALL_DIR}"
    else
        mkdir -p "${INSTALL_DIR}"
        mkdir -p "${INSTALL_DIR}/data"
        mkdir -p "${INSTALL_DIR}/logs"
        mkdir -p "${INSTALL_DIR}/config"
        mkdir -p "${INSTALL_DIR}/cache"
    fi
    
    log "Directories created"
}

# Install Python dependencies
install_python_deps() {
    log "Installing Python dependencies..."
    
    # Create virtual environment
    python3 -m venv "${INSTALL_DIR}/venv"
    
    # Activate virtual environment
    source "${INSTALL_DIR}/venv/bin/activate"
    
    # Install dependencies
    pip install --upgrade pip setuptools wheel
    pip install -r "${INSTALL_DIR}/requirements.txt" 2>/dev/null || {
        log "Installing core dependencies..."
        pip install \
            numpy>=1.21.0 \
            scipy>=1.7.0 \
            pandas>=1.3.0 \
            psycopg2-binary>=2.9.0 \
            duckdb>=0.8.0 \
            networkx>=2.6.0 \
            cryptography>=3.4.0 \
            aiohttp>=3.8.0 \
            fastapi>=0.68.0 \
            uvicorn>=0.15.0 \
            pydantic>=1.8.0 \
            protobuf==4.25.5
    }
    
    log "Python dependencies installed"
}

# Install NoodleCore package
install_package() {
    log "Installing NoodleCore package..."
    
    # Download and install from PyPI
    pip install "${PACKAGE_NAME}==${VERSION}"
    
    # Create symlink for command line tools
    if [[ $EUID -eq 0 ]]; then
        sudo ln -sf "${INSTALL_DIR}/venv/bin/noodlecore" "${BIN_DIR}/noodlecore"
        sudo ln -sf "${INSTALL_DIR}/venv/bin/noodlecore-compiler" "${BIN_DIR}/noodlecore-compiler"
        sudo ln -sf "${INSTALL_DIR}/venv/bin/noodlecore-runtime" "${BIN_DIR}/noodlecore-runtime"
        sudo ln -sf "${INSTALL_DIR}/venv/bin/noodlecore-db" "${BIN_DIR}/noodlecore-db"
    else
        mkdir -p "${BIN_DIR}"
        ln -sf "${INSTALL_DIR}/venv/bin/noodlecore" "${BIN_DIR}/noodlecore"
        ln -sf "${INSTALL_DIR}/venv/bin/noodlecore-compiler" "${BIN_DIR}/noodlecore-compiler"
        ln -sf "${INSTALL_DIR}/venv/bin/noodlecore-runtime" "${BIN_DIR}/noodlecore-runtime"
        ln -sf "${INSTALL_DIR}/venv/bin/noodlecore-db" "${BIN_DIR}/noodlecore-db"
    fi
    
    # Add to PATH if not already there
    if [[ ":$PATH:" != *":${BIN_DIR}:"* ]]; then
        echo "export PATH=\"${BIN_DIR}:\$PATH\"" >> ~/.bashrc
        echo "export PATH=\"${BIN_DIR}:\$PATH\"" >> ~/.zshrc 2>/dev/null || true
    fi
    
    log "NoodleCore package installed"
}

# Create configuration files
create_config() {
    log "Creating configuration files..."
    
    # Create default configuration
    cat > "${INSTALL_DIR}/config/noodlecore.conf" << EOF
[NoodleCore]
environment = production
log_level = INFO
data_dir = ${INSTALL_DIR}/data
log_dir = ${INSTALL_DIR}/logs
config_dir = ${INSTALL_DIR}/config
cache_dir = ${INSTALL_DIR}/cache

[Database]
url = sqlite:///${INSTALL_DIR}/data/noodlecore.db
pool_size = 10
max_overflow = 20

[Redis]
url = redis://localhost:6379
db = 0

[Server]
host = 0.0.0.0
port = 8080
workers = 4

[Security]
secret_key = $(openssl rand -hex 32)
debug = false
EOF
    
    # Create environment file
    cat > "${INSTALL_DIR}/config/.env" << EOF
NoodleCore_ENV=production
NoodleCore_LOG_LEVEL=INFO
NoodleCore_DATA_DIR=${INSTALL_DIR}/data
NoodleCore_LOG_DIR=${INSTALL_DIR}/logs
NoodleCore_CONFIG_DIR=${INSTALL_DIR}/config
NoodleCore_CACHE_DIR=${INSTALL_DIR}/cache
DATABASE_URL=sqlite:///${INSTALL_DIR}/data/noodlecore.db
REDIS_URL=redis://localhost:6379
SECRET_KEY=$(openssl rand -hex 32)
EOF
    
    log "Configuration files created"
}

# Create systemd service
create_service() {
    if [[ $EUID -eq 0 ]] && command -v systemctl &> /dev/null; then
        log "Creating systemd service..."
        
        sudo tee "/etc/systemd/system/${SERVICE_NAME}.service" > /dev/null << EOF
[Unit]
Description=NoodleCore Service
After=network.target

[Service]
Type=simple
User=${SERVICE_USER}
WorkingDirectory=${INSTALL_DIR}
Environment=PATH=${INSTALL_DIR}/venv/bin
ExecStart=${INSTALL_DIR}/venv/bin/noodlecore-runtime
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
        
        sudo systemctl daemon-reload
        sudo systemctl enable "${SERVICE_NAME}"
        sudo systemctl start "${SERVICE_NAME}"
        
        log "Systemd service created and started"
    fi
}

# Create startup script
create_startup_script() {
    log "Creating startup script..."
    
    cat > "${INSTALL_DIR}/start.sh" << 'EOF'
#!/bin/bash
# NoodleCore startup script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${SCRIPT_DIR}/venv"
CONFIG_DIR="${SCRIPT_DIR}/config"

# Activate virtual environment
source "${VENV_DIR}/bin/activate"

# Set environment variables
export NoodleCore_ENV=production
export NoodleCore_LOG_LEVEL=INFO
export NoodleCore_DATA_DIR="${SCRIPT_DIR}/data"
export NoodleCore_LOG_DIR="${SCRIPT_DIR}/logs"
export NoodleCore_CONFIG_DIR="${CONFIG_DIR}"
export NoodleCore_CACHE_DIR="${SCRIPT_DIR}/cache"

# Load environment file
if [ -f "${CONFIG_DIR}/.env" ]; then
    export $(grep -v '^#' "${CONFIG_DIR}/.env" | xargs)
fi

# Start NoodleCore
echo "Starting NoodleCore..."
cd "${SCRIPT_DIR}"
python -m noodlecore-runtime
EOF
    
    chmod +x "${INSTALL_DIR}/start.sh"
    
    log "Startup script created"
}

# Create backup script
create_backup_script() {
    log "Creating backup script..."
    
    cat > "${INSTALL_DIR}/backup.sh" << 'EOF'
#!/bin/bash
# NoodleCore backup script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${SCRIPT_DIR}/backups"
DATA_DIR="${SCRIPT_DIR}/data"
LOG_DIR="${SCRIPT_DIR}/logs"

# Create backup directory
mkdir -p "${BACKUP_DIR}"

# Generate timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create backup
echo "Creating backup..."
tar -czf "${BACKUP_DIR}/noodlecore_backup_${TIMESTAMP}.tar.gz" \
    -C "${SCRIPT_DIR}" \
    --exclude="venv" \
    --exclude="*.pyc" \
    --exclude="__pycache__" \
    --exclude="logs/*.log" \
    --exclude="backups" \
    .

# Keep only last 7 backups
ls -t "${BACKUP_DIR}"/noodlecore_backup_*.tar.gz | tail -n +8 | xargs rm -f

echo "Backup completed: ${BACKUP_DIR}/noodlecore_backup_${TIMESTAMP}.tar.gz"
EOF
    
    chmod +x "${INSTALL_DIR}/backup.sh"
    
    log "Backup script created"
}

# Verify installation
verify_installation() {
    log "Verifying installation..."
    
    # Check if commands are available
    if command -v noodlecore &> /dev/null; then
        log "noodlecore command is available"
    else
        warn "noodlecore command not found in PATH"
    fi
    
    # Test basic functionality
    if noodlecore --help &> /dev/null; then
        log "NoodleCore is working correctly"
    else
        warn "NoodleCore test failed"
    fi
    
    log "Installation verification completed"
}

# Show completion message
show_completion() {
    echo -e "${GREEN}"
    echo "=============================================="
    echo "  NoodleCore Installation Complete!"
    echo "=============================================="
    echo -e "${NC}"
    echo "Installation directory: ${INSTALL_DIR}"
    echo "Configuration directory: ${INSTALL_DIR}/config"
    echo "Data directory: ${INSTALL_DIR}/data"
    echo "Log directory: ${INSTALL_DIR}/logs"
    echo ""
    echo "Commands available:"
    echo "  noodlecore          - Main NoodleCore command"
    echo "  noodlecore-compiler - NoodleCore compiler"
    echo "  noodlecore-runtime  - NoodleCore runtime"
    echo "  noodlecore-db       - NoodleCore database tools"
    echo ""
    echo "To start NoodleCore:"
    echo "  ${INSTALL_DIR}/start.sh"
    echo ""
    echo "To create backup:"
    echo "  ${INSTALL_DIR}/backup.sh"
    echo ""
    echo "To view logs:"
    echo "  tail -f ${INSTALL_DIR}/logs/noodlecore.log"
    echo ""
    echo "For more information, visit:"
    echo "  https://noodlecore.readthedocs.io/"
    echo -e "${GREEN}"
    echo "=============================================="
    echo "  Thank you for installing NoodleCore!"
    echo "=============================================="
    echo -e "${NC}"
}

# Main function
main() {
    show_banner
    check_root
    check_requirements
    install_dependencies
    create_directories
    install_python_deps
    install_package
    create_config
    create_service
    create_startup_script
    create_backup_script
    verify_installation
    show_completion
}

# Run main function
main "$@"