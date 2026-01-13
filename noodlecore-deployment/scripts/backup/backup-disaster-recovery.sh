#!/bin/bash

# NoodleCore Backup and Disaster Recovery Script
# Comprehensive backup and recovery procedures for NoodleCore

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="/opt/noodlecore"
BACKUP_DIR="${PROJECT_ROOT}/backups"
DATA_DIR="${PROJECT_ROOT}/data"
LOG_DIR="${PROJECT_ROOT}/logs"
CONFIG_DIR="${PROJECT_ROOT}/config"
RETENTION_DAYS=30
ENCRYPTION_KEY_FILE="${PROJECT_ROOT}/.encryption_key"
REMOTE_BACKUP="s3://noodlecore-backups/"  # Change to your preferred remote storage
NOTIFICATION_EMAIL="admin@noodlecore.com"  # Change to your email

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
    echo "  NoodleCore Backup and Disaster Recovery"
    echo "=============================================="
    echo -e "${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
    fi
}

# Generate encryption key
generate_encryption_key() {
    if [[ ! -f "${ENCRYPTION_KEY_FILE}" ]]; then
        log "Generating encryption key..."
        openssl rand -hex 32 > "${ENCRYPTION_KEY_FILE}"
        chmod 600 "${ENCRYPTION_KEY_FILE}"
        log "Encryption key generated: ${ENCRYPTION_KEY_FILE}"
    fi
}

# Create backup directory
create_backup_dir() {
    mkdir -p "${BACKUP_DIR}"
    mkdir -p "${BACKUP_DIR}/daily"
    mkdir -p "${BACKUP_DIR}/weekly"
    mkdir -p "${BACKUP_DIR}/monthly"
    mkdir -p "${BACKUP_DIR}/snapshots"
}

# Stop services before backup
stop_services() {
    log "Stopping services before backup..."
    
    # Stop NoodleCore service
    systemctl stop noodlecore 2>/dev/null || true
    
    # Stop related services
    systemctl stop postgresql 2>/dev/null || true
    systemctl stop redis 2>/dev/null || true
    
    log "Services stopped"
}

# Start services after backup
start_services() {
    log "Starting services after backup..."
    
    # Start PostgreSQL
    systemctl start postgresql 2>/dev/null || true
    
    # Start Redis
    systemctl start redis 2>/dev/null || true
    
    # Start NoodleCore service
    systemctl start noodlecore 2>/dev/null || true
    
    log "Services started"
}

# Create database backup
backup_database() {
    log "Creating database backup..."
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="${BACKUP_DIR}/daily/database_backup_${timestamp}.sql"
    
    # Create PostgreSQL dump
    sudo -u postgres pg_dump noodlecore > "${backup_file}"
    
    # Compress the backup
    gzip "${backup_file}"
    
    # Encrypt the backup
    if [[ -f "${ENCRYPTION_KEY_FILE}" ]]; then
        openssl enc -aes-256-cbc -salt -in "${backup_file}.gz" -out "${backup_file}.gz.enc" -kfile "${ENCRYPTION_KEY_FILE}"
        rm "${backup_file}.gz"
    fi
    
    log "Database backup completed: ${backup_file}.gz.enc"
}

# Create file system backup
backup_filesystem() {
    log "Creating file system backup..."
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="${BACKUP_DIR}/daily/filesystem_backup_${timestamp}.tar.gz"
    
    # Create tar archive
    tar -czf "${backup_file}" \
        -C "${PROJECT_ROOT}" \
        --exclude="venv" \
        --exclude="*.pyc" \
        --exclude="__pycache__" \
        --exclude="logs/*.log" \
        --exclude="backups" \
        --exclude="*.tmp" \
        --exclude="*.cache" \
        --exclude="node_modules" \
        --exclude=".git" \
        --exclude="*.log" \
        --exclude="backups" \
        .
    
    # Encrypt the backup
    if [[ -f "${ENCRYPTION_KEY_FILE}" ]]; then
        openssl enc -aes-256-cbc -salt -in "${backup_file}" -out "${backup_file}.enc" -kfile "${ENCRYPTION_KEY_FILE}"
        rm "${backup_file}"
    fi
    
    log "File system backup completed: ${backup_file}.enc"
}

# Create configuration backup
backup_configuration() {
    log "Creating configuration backup..."
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="${BACKUP_DIR}/daily/config_backup_${timestamp}.tar.gz"
    
    # Create configuration archive
    tar -czf "${backup_file}" \
        -C "${PROJECT_ROOT}" \
        config/ \
        systemd/ \
        nginx/ \
        docker-compose.yml \
        Dockerfile \
        requirements.txt \
        pyproject.toml
    
    # Encrypt the backup
    if [[ -f "${ENCRYPTION_KEY_FILE}" ]]; then
        openssl enc -aes-256-cbc -salt -in "${backup_file}" -out "${backup_file}.enc" -kfile "${ENCRYPTION_KEY_FILE}"
        rm "${backup_file}"
    fi
    
    log "Configuration backup completed: ${backup_file}.enc"
}

# Create snapshot backup
create_snapshot() {
    log "Creating snapshot backup..."
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local snapshot_dir="${BACKUP_DIR}/snapshots/snapshot_${timestamp}"
    
    # Create snapshot directory
    mkdir -p "${snapshot_dir}"
    
    # Create LVM snapshot (if available)
    if command -v lvcreate &> /dev/null; then
        lvcreate -L 1G -s -n noodlecore_snapshot /dev/vg/noodlecore_lv
        mount /dev/vg/noodlecore_snapshot "${snapshot_dir}"
        cp -a "${PROJECT_ROOT}"/* "${snapshot_dir}/"
        umount "${snapshot_dir}"
        lvremove -f /dev/vg/noodlecore_snapshot
    else
        # Fallback to regular copy
        cp -a "${PROJECT_ROOT}"/* "${snapshot_dir}/"
    fi
    
    # Create snapshot archive
    tar -czf "${BACKUP_DIR}/snapshots/snapshot_${timestamp}.tar.gz" -C "${BACKUP_DIR}/snapshots" "snapshot_${timestamp}"
    rm -rf "${snapshot_dir}"
    
    log "Snapshot backup completed: ${BACKUP_DIR}/snapshots/snapshot_${timestamp}.tar.gz"
}

# Upload to remote storage
upload_to_remote() {
    log "Uploading to remote storage..."
    
    # Check if AWS CLI is available
    if command -v aws &> /dev/null; then
        # Upload daily backups
        aws s3 sync "${BACKUP_DIR}/daily" "${REMOTE_BACKUP}daily/" --sse AES256
        
        # Upload weekly backups
        aws s3 sync "${BACKUP_DIR}/weekly" "${REMOTE_BACKUP}weekly/" --sse AES256
        
        # Upload monthly backups
        aws s3 sync "${BACKUP_DIR}/monthly" "${REMOTE_BACKUP}monthly/" --sse AES256
        
        # Upload snapshots
        aws s3 sync "${BACKUP_DIR}/snapshots" "${REMOTE_BACKUP}snapshots/" --sse AES256
        
        log "Remote upload completed"
    else
        warn "AWS CLI not available. Skipping remote upload."
    fi
}

# Clean old backups
clean_old_backups() {
    log "Cleaning old backups..."
    
    # Find and remove backups older than retention period
    find "${BACKUP_DIR}" -name "*.tar.gz" -mtime +${RETENTION_DAYS} -delete
    find "${BACKUP_DIR}" -name "*.enc" -mtime +${RETENTION_DAYS} -delete
    
    # Clean remote backups
    if command -v aws &> /dev/null; then
        aws s3 ls "${REMOTE_BACKUP}" --recursive | while read -r line; do
            create_date=$(echo "$line" | awk '{print $1" "$2}')
            file_date=$(date -d "$create_date" +%s)
            cutoff_date=$(date -d "${RETENTION_DAYS} days ago" +%s)
            
            if [[ $file_date -lt $cutoff_date ]]; then
                file_name=$(echo "$line" | awk '{print $4}')
                aws s3 rm "${REMOTE_BACKUP}${file_name}"
            fi
        done
    fi
    
    log "Old backups cleaned"
}

# Send notification
send_notification() {
    local subject=$1
    local message=$2
    
    if command -v mail &> /dev/null; then
        echo "$message" | mail -s "$subject" "$NOTIFICATION_EMAIL"
    elif command -v sendmail &> /dev/null; then
        echo "Subject: $subject" > /tmp/notification.txt
        echo "To: $NOTIFICATION_EMAIL" >> /tmp/notification.txt
        echo "" >> /tmp/notification.txt
        echo "$message" >> /tmp/notification.txt
        sendmail -t < /tmp/notification.txt
        rm -f /tmp/notification.txt
    else
        warn "No email notification available"
    fi
}

# Create backup report
create_backup_report() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local report_file="${BACKUP_DIR}/backup_report_${timestamp}.txt"
    
    echo "NoodleCore Backup Report - $(date)" > "${report_file}"
    echo "====================================" >> "${report_file}"
    echo "" >> "${report_file}"
    echo "Backup Summary:" >> "${report_file}"
    echo "  - Database backup: $(ls -la ${BACKUP_DIR}/daily/*database* 2>/dev/null | wc -l) files" >> "${report_file}"
    echo "  - File system backup: $(ls -la ${BACKUP_DIR}/daily/*filesystem* 2>/dev/null | wc -l) files" >> "${report_file}"
    echo "  - Configuration backup: $(ls -la ${BACKUP_DIR}/daily/*config* 2>/dev/null | wc -l) files" >> "${report_file}"
    echo "  - Snapshots: $(ls -la ${BACKUP_DIR}/snapshots/ 2>/dev/null | wc -l) files" >> "${report_file}"
    echo "" >> "${report_file}"
    echo "Storage Usage:" >> "${report_file}"
    echo "  - Local backup size: $(du -sh ${BACKUP_DIR} | cut -f1)" >> "${report_file}"
    echo "  - Retention period: ${RETENTION_DAYS} days" >> "${report_file}"
    echo "" >> "${report_file}"
    echo "Backup Status: SUCCESS" >> "${report_file}"
    
    log "Backup report created: ${report_file}"
}

# Main backup function
backup() {
    log "Starting backup process..."
    
    stop_services
    
    # Generate encryption key
    generate_encryption_key
    
    # Create backup directory
    create_backup_dir
    
    # Create different types of backups
    backup_database
    backup_filesystem
    backup_configuration
    
    # Create snapshot
    create_snapshot
    
    # Upload to remote storage
    upload_to_remote
    
    # Clean old backups
    clean_old_backups
    
    # Create backup report
    create_backup_report
    
    start_services
    
    # Send notification
    send_notification "NoodleCore Backup Completed" "Backup completed successfully on $(date)"
    
    log "Backup process completed"
}

# Disaster recovery function
disaster_recovery() {
    log "Starting disaster recovery process..."
    
    # Ask for backup date
    echo "Available backups:"
    ls -la "${BACKUP_DIR}/daily/" | tail -10
    echo ""
    read -p "Enter backup date (YYYYMMDD): " backup_date
    
    # Find backup files
    local db_backup=$(find "${BACKUP_DIR}/daily/" -name "*database_${backup_date}*.enc" | tail -1)
    local fs_backup=$(find "${BACKUP_DIR}/daily/" -name "*filesystem_${backup_date}*.enc" | tail -1)
    local config_backup=$(find "${BACKUP_DIR}/daily/" -name "*config_${backup_date}*.enc" | tail -1)
    
    if [[ -z "$db_backup" || -z "$fs_backup" || -z "$config_backup" ]]; then
        error "Required backup files not found for date: ${backup_date}"
    fi
    
    # Stop all services
    systemctl stop noodlecore
    systemctl stop postgresql
    systemctl stop nginx
    systemctl stop docker
    
    # Restore database
    log "Restoring database..."
    mkdir -p /tmp/restore
    openssl enc -d -aes-256-cbc -in "${db_backup}" -out /tmp/restore/database.sql -kfile "${ENCRYPTION_KEY_FILE}"
    gunzip /tmp/restore/database.sql.gz
    sudo -u postgres poodlecore < /tmp/restore/database.sql
    
    # Restore file system
    log "Restoring file system..."
    openssl enc -d -aes-256-cbc -in "${fs_backup}" -out /tmp/restore/filesystem.tar.gz -kfile "${ENCRYPTION_KEY_FILE}"
    tar -xzf /tmp/restore/filesystem.tar.gz -C /
    
    # Restore configuration
    log "Restoring configuration..."
    openssl enc -d -aes-256-cbc -in "${config_backup}" -out /tmp/restore/config.tar.gz -kfile "${ENCRYPTION_KEY_FILE}"
    tar -xzf /tmp/restore/config.tar.gz -C /
    
    # Restore permissions
    chown -R noodlecore:noodlecore /opt/noodlecore
    chmod -R 755 /opt/noodlecore
    
    # Start services
    systemctl start postgresql
    systemctl start nginx
    systemctl start docker
    systemctl start noodlecore
    
    # Clean up
    rm -rf /tmp/restore
    
    log "Disaster recovery completed"
    send_notification "NoodleCore Disaster Recovery Completed" "Disaster recovery completed successfully on $(date)"
}

# Show backup status
show_status() {
    echo "Backup Status:"
    echo "=============="
    echo "Backup directory: ${BACKUP_DIR}"
    echo "Retention period: ${RETENTION_DAYS} days"
    echo "Remote storage: ${REMOTE_BACKUP}"
    echo ""
    echo "Recent backups:"
    echo "Daily:"
    ls -la "${BACKUP_DIR}/daily/" | tail -5
    echo ""
    echo "Weekly:"
    ls -la "${BACKUP_DIR}/weekly/" | tail -5
    echo ""
    echo "Monthly:"
    ls -la "${BACKUP_DIR}/monthly/" | tail -5
    echo ""
    echo "Snapshots:"
    ls -la "${BACKUP_DIR}/snapshots/" | tail -5
}

# Main function
main() {
    show_banner
    check_root
    
    case "${1:-backup}" in
        backup)
            backup
            ;;
        recovery)
            disaster_recovery
            ;;
        status)
            show_status
            ;;
        *)
            echo "Usage: $0 {backup|recovery|status}"
            echo "  backup    - Create backup (default)"
            echo "  recovery  - Perform disaster recovery"
            echo "  status    - Show backup status"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"