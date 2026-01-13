#!/bin/bash

# Development deployment script for NoodleCore
# Deploys the complete NoodleCore stack in development environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
COMPOSE_FILE="docker-compose.yml"
ENVIRONMENT="development"
PROJECT_NAME="noodle-core-dev"
DATA_DIR="./data"
LOGS_DIR="./logs"
CONFIG_DIR="./config"

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

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed. Please install Docker first."
    fi
    
    # Check if Docker Compose is installed
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose is not installed. Please install Docker Compose first."
    fi
    
    # Check if Docker is running
    if ! docker info &> /dev/null; then
        error "Docker is not running. Please start Docker first."
    fi
    
    log "Prerequisites check completed."
}

# Create necessary directories
create_directories() {
    log "Creating necessary directories..."
    
    mkdir -p $DATA_DIR
    mkdir -p $LOGS_DIR
    mkdir -p $CONFIG_DIR
    mkdir -p ./database
    mkdir -p ./redis
    mkdir -p ./monitoring/grafana/dashboards
    mkdir -p ./monitoring/grafana/datasources
    mkdir -p ./nginx/conf.d
    mkdir -p ./certs
    
    log "Directories created successfully."
}

# Create configuration files
create_config_files() {
    log "Creating configuration files..."
    
    # Create .env file
    cat > .env << EOF
# NoodleCore Development Environment
NOODLE_ENV=development
NOODLE_LOG_LEVEL=DEBUG
NOODLE_PORT=8080
DATABASE_URL=postgresql://noodlecore:password@postgres:5432/noodlecore
REDIS_URL=redis://redis:6379
SECRET_KEY=dev-secret-key-change-in-production
POSTGRES_PASSWORD=password
REDIS_PASSWORD=password
GRAFANA_PASSWORD=admin
EOF

    # Create Redis configuration
    cat > ./redis/redis.conf << EOF
# Redis configuration for development
port 6379
bind 0.0.0.0
daemonize no
supervised no
pidfile /var/run/redis_6379.pid
loglevel notice
logfile ""
databases 16
always-show-logo yes
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir /data
maxmemory 256mb
maxmemory-policy allkeys-lru
appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit replica 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
dynamic-hz yes
aof-rewrite-incremental-fsync yes
EOF

    # Create PostgreSQL configuration
    cat > ./database/postgresql.conf << EOF
# PostgreSQL configuration for development
listen_addresses = '*'
max_connections = 100
shared_buffers = 128MB
effective_cache_size = 4GB
maintenance_work_mem = 64MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 4MB
min_wal_size = 1GB
max_wal_size = 4GB
EOF

    # Create Nginx configuration
    cat > ./nginx/nginx.conf << EOF
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log notice;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    gzip on;
    gzip_vary on;
    gzip_min_length 10240;
    gzip_proxied expired no-cache no-store private must-revalidate max-age=0 auth;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    include /etc/nginx/conf.d/*.conf;
}
EOF

    # Create Prometheus configuration
    cat > ./monitoring/prometheus.yml << EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'noodle-core'
    static_configs:
      - targets: ['noodle-core:8080']
    metrics_path: /metrics
    scrape_interval: 30s
    scrape_timeout: 10s

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres:5432']
    metrics_path: /metrics
    scrape_interval: 30s
    scrape_timeout: 10s

  - job_name: 'redis'
    static_configs:
      - targets: ['redis:6379']
    metrics_path: /metrics
    scrape_interval: 30s
    scrape_timeout: 10s
EOF

    log "Configuration files created successfully."
}

# Start development environment
start_dev() {
    log "Starting development environment..."
    
    # Stop any existing containers
    docker-compose -f $COMPOSE_FILE down --remove-orphans
    
    # Start services
    docker-compose -f $COMPOSE_FILE up -d
    
    log "Development environment started successfully."
}

# Check service status
check_status() {
    log "Checking service status..."
    
    # Check all services
    docker-compose -f $COMPOSE_FILE ps
    
    # Check specific services
    log "Checking NoodleCore service..."
    if curl -f http://localhost:8080/health &> /dev/null; then
        log "NoodleCore service is healthy"
    else
        warn "NoodleCore service is not responding to health check"
    fi
    
    log "Checking PostgreSQL service..."
    if docker-compose -f $COMPOSE_FILE exec -T postgres pg_isready -U noodlecore &> /dev/null; then
        log "PostgreSQL service is healthy"
    else
        warn "PostgreSQL service is not responding"
    fi
    
    log "Checking Redis service..."
    if docker-compose -f $COMPOSE_FILE exec -T redis redis-cli ping &> /dev/null; then
        log "Redis service is healthy"
    else
        warn "Redis service is not responding"
    fi
}

# View logs
view_logs() {
    local service=${1:-all}
    
    if [ "$service" = "all" ]; then
        log "Viewing logs for all services..."
        docker-compose -f $COMPOSE_FILE logs -f --tail=100
    else
        log "Viewing logs for $service..."
        docker-compose -f $COMPOSE_FILE logs -f --tail=100 $service
    fi
}

# Stop development environment
stop_dev() {
    log "Stopping development environment..."
    
    docker-compose -f $COMPOSE_FILE down
    
    log "Development environment stopped successfully."
}

# Clean up
cleanup() {
    log "Cleaning up development environment..."
    
    read -p "Are you sure you want to delete all development data? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker-compose -f $COMPOSE_FILE down -v --remove-orphans
        rm -rf $DATA_DIR $LOGS_DIR $CONFIG_DIR
        log "Cleanup completed."
    else
        log "Cleanup cancelled."
    fi
}

# Show help
show_help() {
    echo "NoodleCore Development Deployment Script"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  setup      Setup development environment"
    echo "  start      Start development environment"
    echo "  stop       Stop development environment"
    echo "  restart    Restart development environment"
    echo "  status     Check service status"
    echo "  logs [service]  View logs (all services by default)"
    echo "  cleanup    Clean up development environment"
    echo "  help       Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  COMPOSE_FILE     Docker Compose file (default: docker-compose.yml)"
    echo "  PROJECT_NAME     Docker Compose project name (default: noodle-core-dev)"
    echo "  DATA_DIR         Data directory (default: ./data)"
    echo "  LOGS_DIR         Logs directory (default: ./logs)"
    echo "  CONFIG_DIR       Config directory (default: ./config)"
}

# Main script
main() {
    case "${1:-help}" in
        setup)
            check_prerequisites
            create_directories
            create_config_files
            start_dev
            check_status
            log "Development environment setup completed successfully!"
            ;;
        start)
            check_prerequisites
            start_dev
            check_status
            log "Development environment started successfully!"
            ;;
        stop)
            stop_dev
            ;;
        restart)
            stop_dev
            sleep 2
            start_dev
            check_status
            log "Development environment restarted successfully!"
            ;;
        status)
            check_status
            ;;
        logs)
            view_logs $2
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