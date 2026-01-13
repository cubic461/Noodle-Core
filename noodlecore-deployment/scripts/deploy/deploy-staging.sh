#!/bin/bash

# Staging deployment script for NoodleCore
# Deploys the complete NoodleCore stack in staging environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
COMPOSE_FILE="docker-compose.staging.yml"
ENVIRONMENT="staging"
PROJECT_NAME="noodle-core-staging"
DATA_DIR="./staging-data"
LOGS_DIR="./staging-logs"
CONFIG_DIR="./staging-config"
DOMAIN="staging.noodle-core.example.com"
CERT_DIR="./certs"

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
    
    # Check if required files exist
    if [ ! -f "$COMPOSE_FILE" ]; then
        error "Docker Compose file $COMPOSE_FILE not found."
    fi
    
    log "Prerequisites check completed."
}

# Generate SSL certificates
generate_certificates() {
    log "Generating SSL certificates..."
    
    # Create certificates directory
    mkdir -p $CERT_DIR
    
    # Check if Let's Encrypt certificates exist
    if [ ! -f "$CERT_DIR/$DOMAIN.crt" ] || [ ! -f "$CERT_DIR/$DOMAIN.key" ]; then
        warn "SSL certificates not found. Generating self-signed certificates..."
        
        # Generate private key
        openssl genrsa -out $CERT_DIR/$DOMAIN.key 2048
        
        # Generate certificate signing request
        openssl req -new -key $CERT_DIR/$DOMAIN.key -out $CERT_DIR/$DOMAIN.csr -subj "/C=US/ST=State/L=City/O=Organization/OU=IT/CN=$DOMAIN"
        
        # Generate self-signed certificate
        openssl x509 -req -days 365 -in $CERT_DIR/$DOMAIN.csr -signkey $CERT_DIR/$DOMAIN.key -out $CERT_DIR/$DOMAIN.crt
        
        # Clean up CSR
        rm $CERT_DIR/$DOMAIN.csr
        
        log "Self-signed SSL certificates generated successfully."
        warn "For production use, please obtain valid certificates from Let's Encrypt or your CA."
    else
        log "SSL certificates already exist."
    fi
}

# Create staging configuration
create_staging_config() {
    log "Creating staging configuration..."
    
    # Create .env file for staging
    cat > .env.staging << EOF
# NoodleCore Staging Environment
NOODLE_ENV=staging
NOODLE_LOG_LEVEL=INFO
NOODLE_PORT=8080
NOODLE_DATA_DIR=/app/data
NOODLE_CONFIG_DIR=/app/config
DATABASE_URL=postgresql://noodlecore:password@postgres:5432/noodlecore
REDIS_URL=redis://redis:6379
SECRET_KEY=${SECRET_KEY:-$(openssl rand -hex 32)}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-$(openssl rand -hex 16)}
REDIS_PASSWORD=${REDIS_PASSWORD:-$(openssl rand -hex 16)}
GRAFANA_PASSWORD=${GRAFANA_PASSWORD:-$(openssl rand -hex 16)}
DOMAIN=$DOMAIN
EOF

    # Create Nginx staging configuration
    cat > ./nginx/conf.d/staging.conf << EOF
server {
    listen 80;
    server_name $DOMAIN;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN;
    
    ssl_certificate /etc/nginx/certs/$DOMAIN.crt;
    ssl_certificate_key /etc/nginx/certs/$DOMAIN.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1d;
    ssl_session_tickets off;
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 10240;
    gzip_proxied expired no-cache no-store private must-revalidate max-age=0 auth;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
    
    # Rate limiting
    limit_req_zone \$binary_remote_addr zone=api:10m rate=10r/s;
    limit_req zone=api burst=20 nodelay;
    
    # Proxy to NoodleCore
    location / {
        proxy_pass http://noodle-core:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-Host \$host;
        proxy_set_header X-Forwarded-Port \$server_port;
        
        # Timeouts
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
        
        # Buffer settings
        proxy_buffering on;
        proxy_buffer_size 4k;
        proxy_buffers 8 4k;
        
        # Health check
        proxy_intercept_errors on;
        error_page 500 502 503 504 /50x.html;
    }
    
    # Proxy to IDE
    location /ide {
        proxy_pass http://noodle-ide:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # CORS headers
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
        add_header Access-Control-Allow-Headers "Origin, X-Requested-With, Content-Type, Accept, Authorization";
    }
    
    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
    
    # Static files
    location /static/ {
        alias /app/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Error pages
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}
EOF

    # Create Grafana staging configuration
    cat > ./monitoring/grafana/datasources/prometheus.yml << EOF
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    orgId: 1
    url: http://prometheus:9090
    basicAuth: false
    isDefault: true
    version: 1
    editable: false
    jsonData:
      httpMethod: POST
      queryTimeout: 60s
      timeInterval: 15s
EOF

    log "Staging configuration created successfully."
}

# Start staging environment
start_staging() {
    log "Starting staging environment..."
    
    # Stop any existing containers
    docker-compose -f $COMPOSE_FILE down --remove-orphans
    
    # Start services
    docker-compose -f $COMPOSE_FILE up -d
    
    log "Staging environment started successfully."
}

# Check service status
check_status() {
    log "Checking service status..."
    
    # Check all services
    docker-compose -f $COMPOSE_FILE ps
    
    # Check specific services
    log "Checking NoodleCore service..."
    if curl -f https://$DOMAIN/health &> /dev/null; then
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
    
    log "Checking Nginx service..."
    if curl -f http://localhost:80/health &> /dev/null; then
        log "Nginx service is healthy"
    else
        warn "Nginx service is not responding"
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

# Stop staging environment
stop_staging() {
    log "Stopping staging environment..."
    
    docker-compose -f $COMPOSE_FILE down
    
    log "Staging environment stopped successfully."
}

# Clean up
cleanup() {
    log "Cleaning up staging environment..."
    
    read -p "Are you sure you want to delete all staging data? (y/N): " -n 1 -r
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
    echo "NoodleCore Staging Deployment Script"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  setup      Setup staging environment"
    echo "  start      Start staging environment"
    echo "  stop       Stop staging environment"
    echo "  restart    Restart staging environment"
    echo "  status     Check service status"
    echo "  logs [service]  View logs (all services by default)"
    echo "  cleanup    Clean up staging environment"
    echo "  help       Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  COMPOSE_FILE     Docker Compose file (default: docker-compose.staging.yml)"
    echo "  PROJECT_NAME     Docker Compose project name (default: noodle-core-staging)"
    echo "  DATA_DIR         Data directory (default: ./staging-data)"
    echo "  LOGS_DIR         Logs directory (default: ./staging-logs)"
    echo "  CONFIG_DIR       Config directory (default: ./staging-config)"
    echo "  DOMAIN           Staging domain (default: staging.noodle-core.example.com)"
}

# Main script
main() {
    case "${1:-help}" in
        setup)
            check_prerequisites
            generate_certificates
            create_staging_config
            start_staging
            check_status
            log "Staging environment setup completed successfully!"
            ;;
        start)
            check_prerequisites
            start_staging
            check_status
            log "Staging environment started successfully!"
            ;;
        stop)
            stop_staging
            ;;
        restart)
            stop_staging
            sleep 2
            start_staging
            check_status
            log "Staging environment restarted successfully!"
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