# NoodleControl Demo - Deployment Guide

This document provides comprehensive instructions for deploying the NoodleControl demo application in various environments.

## Table of Contents

1. [Deployment Options](#deployment-options)
2. [Local Development Deployment](#local-development-deployment)
3. [Docker Deployment](#docker-deployment)
4. [Production Deployment](#production-deployment)
5. [Environment Configuration](#environment-configuration)
6. [Security Considerations](#security-considerations)
7. [Monitoring and Logging](#monitoring-and-logging)
8. [Troubleshooting](#troubleshooting)
9. [Performance Optimization](#performance-optimization)
10. [Backup and Recovery](#backup-and-recovery)

## Deployment Options

The NoodleControl demo can be deployed in several ways:

1. **Local Development**: Direct Python execution on localhost
2. **Docker Containers**: Containerized deployment with Docker Compose
3. **Production Server**: Hosted on a cloud provider or dedicated server

Choose the option that best fits your needs:

| Option | Best For | Complexity | Scalability |
|--------|----------|------------|-------------|
| Local Development | Testing, development | Low | Limited |
| Docker | Staging, small production | Medium | Good |
| Production Server | Large-scale deployment | High | Excellent |

## Local Development Deployment

### Prerequisites

- Python 3.9 or higher
- pip 21.0 or higher
- Git

### Quick Start

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd noodle_control_mobile_app/demo
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Start the application:
   ```bash
   # Option 1: Use startup script
   start_complete_app.bat
   # Select option 1 (Local Python)
   
   # Option 2: Manual start
   # Terminal 1
   python server.py
   
   # Terminal 2
   python api.py
   ```

4. Access the application:
   - Frontend: http://localhost:8081
   - Backend API: http://localhost:8082

### Custom Configuration

To customize the local deployment:

1. Create a `.env` file:
   ```env
   NOODLE_ENV=development
   DEBUG=1
   NOODLE_PORT=8082
   FRONTEND_PORT=8081
   ```

2. Modify ports in `server.py` and `api.py` if needed.

## Docker Deployment

### Prerequisites

- Docker Desktop (Windows/Mac) or Docker Engine (Linux)
- Docker Compose

### Quick Start

1. Navigate to the demo directory:
   ```bash
   cd noodle_control_mobile_app/demo
   ```

2. Run the Docker startup script:
   ```bash
   # Windows
   start_docker.bat
   
   # Or use the complete app script
   start_complete_app.bat
   # Select option 2 (Docker)
   ```

3. Access the application:
   - Frontend: http://localhost:8081
   - Backend API: http://localhost:8082

### Manual Docker Commands

If you prefer to run Docker commands manually:

1. Build the images:
   ```bash
   docker-compose build
   ```

2. Start the containers:
   ```bash
   docker-compose up -d
   ```

3. View logs:
   ```bash
   docker-compose logs -f
   ```

4. Stop the containers:
   ```bash
   docker-compose down
   ```

### Docker Configuration

The Docker deployment consists of two containers:

#### Frontend Container
- **Base Image**: nginx:alpine
- **Port**: 8081
- **Purpose**: Serves static files
- **Configuration**: nginx.conf

#### Backend Container
- **Base Image**: python:3.9-slim
- **Port**: 8082
- **Purpose**: Runs Flask API with WebSocket support
- **Environment**: Production mode

### Custom Docker Deployment

To customize the Docker deployment:

1. Modify `docker-compose.yml`:
   ```yaml
   version: '3.8'
   
   services:
     frontend:
       build:
         context: .
         dockerfile: Dockerfile.frontend
       ports:
         - "8081:8081"  # Change host port if needed
       environment:
         - NGINX_HOST=localhost
         - NGINX_PORT=8081
       
     backend:
       build:
         context: .
         dockerfile: Dockerfile.backend
       ports:
         - "8082:8082"  # Change host port if needed
       environment:
         - NOODLE_ENV=production
         - NOODLE_PORT=8082
         - DEBUG=0
   ```

2. Rebuild and restart:
   ```bash
   docker-compose down
   docker-compose build --no-cache
   docker-compose up -d
   ```

## Production Deployment

### Prerequisites

- Linux server (Ubuntu 20.04+ recommended)
- Docker and Docker Compose
- Nginx (for reverse proxy)
- SSL certificate (for HTTPS)
- Domain name (optional but recommended)

### Production Architecture

```
Internet
    |
    v
[Load Balancer]
    |
    v
[Nginx Reverse Proxy]
    |
    +-------------------+
    |                   |
    v                   v
[Frontend Container] [Backend Container]
    |                   |
    v                   v
[Static Files]    [API/WebSocket]
```

### Step-by-Step Production Deployment

#### 1. Server Preparation

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Nginx
sudo apt install nginx -y

# Create application directory
sudo mkdir -p /opt/noodlecontrol
sudo chown $USER:$USER /opt/noodlecontrol
```

#### 2. Application Setup

```bash
# Clone repository
cd /opt/noodlecontrol
git clone <repository-url> .

# Navigate to demo directory
cd demo

# Create production environment file
cp .env.example .env
```

#### 3. Environment Configuration

Create `/opt/noodlecontrol/demo/.env`:
```env
NOODLE_ENV=production
DEBUG=0
NOODLE_PORT=8082
FRONTEND_PORT=8081

# Security
SECRET_KEY=your-secret-key-here
CORS_ORIGIN=https://yourdomain.com

# Performance
MAX_CONNECTIONS=100
CONNECTION_TIMEOUT=30

# Logging
LOG_LEVEL=INFO
LOG_FILE=/var/log/noodlecontrol.log
```

#### 4. Nginx Configuration

Create `/etc/nginx/sites-available/noodlecontrol`:
```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    
    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;
    
    # SSL Configuration
    ssl_certificate /path/to/ssl/cert.pem;
    ssl_certificate_key /path/to/ssl/private.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    # Security Headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";
    
    # Frontend
    location / {
        proxy_pass http://localhost:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Backend API
    location /api/ {
        proxy_pass http://localhost:8082;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # WebSocket
    location /socket.io/ {
        proxy_pass http://localhost:8082;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/noodlecontrol /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

#### 5. SSL Certificate

Let's Encrypt (recommended):
```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

#### 6. Application Deployment

```bash
# Build and start containers
docker-compose -f docker-compose.prod.yml up -d

# Verify deployment
docker-compose ps
curl http://localhost:8081/api/health
```

#### 7. Systemd Service (Optional)

Create `/etc/systemd/system/noodlecontrol.service`:
```ini
[Unit]
Description=NoodleControl Demo
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/noodlecontrol/demo
ExecStart=/usr/local/bin/docker-compose -f docker-compose.prod.yml up -d
ExecStop=/usr/local/bin/docker-compose -f docker-compose.prod.yml down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

Enable the service:
```bash
sudo systemctl enable noodlecontrol
sudo systemctl start noodlecontrol
```

## Environment Configuration

### Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| NOODLE_ENV | Environment mode | development | No |
| DEBUG | Debug mode | 1 (development) / 0 (production) | No |
| NOODLE_PORT | Backend port | 8082 | No |
| FRONTEND_PORT | Frontend port | 8081 | No |
| SECRET_KEY | Secret key for sessions | None | Production |
| CORS_ORIGIN | Allowed CORS origin | * | Production |
| MAX_CONNECTIONS | Max WebSocket connections | 100 | No |
| LOG_LEVEL | Logging level | DEBUG (dev) / INFO (prod) | No |

### Production .env Template

```env
# Environment
NOODLE_ENV=production
DEBUG=0

# Ports
NOODLE_PORT=8082
FRONTEND_PORT=8081

# Security
SECRET_KEY=your-very-secret-key-here
CORS_ORIGIN=https://yourdomain.com

# Performance
MAX_CONNECTIONS=100
CONNECTION_TIMEOUT=30

# Logging
LOG_LEVEL=INFO
LOG_FILE=/var/log/noodlecontrol.log

# Monitoring
METRICS_ENABLED=true
HEALTH_CHECK_INTERVAL=30
```

## Security Considerations

### Basic Security Measures

1. **Environment Variables**:
   - Never commit `.env` files to version control
   - Use strong, random secrets
   - Rotate secrets regularly

2. **Network Security**:
   - Use HTTPS in production
   - Implement proper CORS policies
   - Limit exposed ports

3. **Container Security**:
   - Use non-root users in containers
   - Regularly update base images
   - Scan for vulnerabilities

4. **Application Security**:
   - Validate all input
   - Implement rate limiting
   - Use secure headers

### Advanced Security

1. **Authentication** (for future enhancement):
   ```python
   # Example JWT implementation
   from flask_jwt_extended import JWTManager
   
   jwt = JWTManager(app)
   
   @app.route('/api/protected')
   @jwt_required()
   def protected():
       return create_response({"message": "Protected resource"})
   ```

2. **Rate Limiting**:
   ```python
   # Example rate limiting
   from flask_limiter import Limiter
   from flask_limiter.util import get_remote_address
   
   limiter = Limiter(app, key_func=get_remote_address)
   
   @app.route('/api/nodes/<node_id>/start', methods=['POST'])
   @limiter.limit("10 per minute")
   def start_node(node_id):
       # Implementation
   ```

## Monitoring and Logging

### Application Logging

Configure logging in `api.py`:
```python
import logging
from logging.handlers import RotatingFileHandler

def setup_logging():
    log_level = os.getenv('LOG_LEVEL', 'INFO')
    log_file = os.getenv('LOG_FILE', 'noodlecontrol.log')
    
    logging.basicConfig(
        level=getattr(logging, log_level),
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            RotatingFileHandler(log_file, maxBytes=10485760, backupCount=5),
            logging.StreamHandler()
        ]
    )
```

### Health Monitoring

Monitor application health with:
```bash
# Check API health
curl -f http://localhost:8082/api/health || echo "Health check failed"

# Monitor containers
docker-compose ps
docker stats

# Check logs
docker-compose logs -f backend
docker-compose logs -f frontend
```

### External Monitoring

Consider these monitoring solutions:
- Prometheus + Grafana
- ELK Stack (Elasticsearch, Logstash, Kibana)
- Datadog
- New Relic

## Troubleshooting

### Common Issues

1. **Port Conflicts**:
   ```bash
   # Check port usage
   netstat -tulpn | grep :8081
   netstat -tulpn | grep :8082
   
   # Kill process using port
   sudo kill -9 <PID>
   ```

2. **Docker Issues**:
   ```bash
   # Rebuild containers
   docker-compose down
   docker-compose build --no-cache
   docker-compose up -d
   
   # Check container logs
   docker-compose logs backend
   docker-compose logs frontend
   ```

3. **Permission Issues**:
   ```bash
   # Fix Docker permissions
   sudo usermod -aG docker $USER
   
   # Fix file permissions
   sudo chown -R $USER:$USER /opt/noodlecontrol
   ```

4. **SSL Certificate Issues**:
   ```bash
   # Check certificate
   openssl x509 -in /path/to/cert.pem -text -noout
   
   # Renew certificate
   sudo certbot renew
   ```

### Debug Mode

Enable debug mode in production:
```bash
# Set debug environment variable
export DEBUG=1

# Restart application
docker-compose restart backend
```

## Performance Optimization

### Frontend Optimization

1. **Enable Compression**:
   ```nginx
   # In nginx.conf
   gzip on;
   gzip_types text/css application/javascript application/json;
   ```

2. **Browser Caching**:
   ```nginx
   # In nginx.conf
   location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
       expires 1y;
       add_header Cache-Control "public, immutable";
   }
   ```

3. **Resource Optimization**:
   - Minify CSS and JavaScript
   - Optimize images
   - Use CDN for static assets

### Backend Optimization

1. **Connection Pooling**:
   ```python
   # Example database connection pool
   from sqlalchemy import create_engine
   from sqlalchemy.pool import QueuePool
   
   engine = create_engine(
       database_url,
       poolclass=QueuePool,
       pool_size=10,
       max_overflow=20
   )
   ```

2. **Caching**:
   ```python
   # Example caching
   from flask_caching import Cache
   
   cache = Cache(app, config={'CACHE_TYPE': 'redis'})
   
   @app.route('/api/metrics')
   @cache.cached(timeout=5)
   def get_metrics():
       # Implementation
   ```

3. **Load Balancing**:
   ```yaml
   # In docker-compose.yml
   version: '3.8'
   
   services:
     backend:
       deploy:
         replicas: 3
   ```

## Backup and Recovery

### Data Backup

1. **Application Backup**:
   ```bash
   # Backup application files
   tar -czf noodlecontrol-$(date +%Y%m%d).tar.gz /opt/noodlecontrol
   
   # Backup Docker volumes
   docker run --rm -v noodlecontrol_data:/data -v $(pwd):/backup alpine tar czf /backup/noodlecontrol-data-$(date +%Y%m%d).tar.gz -C /data .
   ```

2. **Configuration Backup**:
   ```bash
   # Backup Nginx configuration
   sudo cp -r /etc/nginx/sites-available/noodlecontrol /backup/
   
   # Backup SSL certificates
   sudo cp -r /etc/letsencrypt /backup/
   ```

### Recovery Procedure

1. **Restore Application**:
   ```bash
   # Stop application
   docker-compose down
   
   # Restore files
   tar -xzf noodcontrol-YYYYMMDD.tar.gz -C /
   
   # Start application
   docker-compose up -d
   ```

2. **Verify Recovery**:
   ```bash
   # Check application health
   curl http://localhost:8081/api/health
   
   # Verify functionality
   curl http://localhost:8082/api/nodes
   ```

### Disaster Recovery Plan

1. **Documentation**:
   - Keep this deployment guide updated
   - Document all custom configurations
   - Maintain a runbook for common issues

2. **Monitoring**:
   - Set up alerting for critical failures
   - Monitor system resources
   - Track application performance

3. **Testing**:
   - Regularly test backup and recovery procedures
   - Perform disaster recovery drills
   - Validate restore procedures

## Conclusion

This deployment guide covers various deployment scenarios for the NoodleControl demo application. For most use cases, the Docker deployment provides a good balance of simplicity and functionality. For production environments, follow the production deployment checklist and ensure proper security measures are in place.

For additional support or questions:
1. Review the troubleshooting section
2. Check the main README.md file
3. Consult the DEVELOPMENT.md for code-related questions
4. Create an issue in the project repository