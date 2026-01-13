# NoodleCore Deployment Guide

This guide provides comprehensive instructions for deploying NoodleCore in various environments, from development to production.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Installation Methods](#installation-methods)
4. [Docker Deployment](#docker-deployment)
5. [Kubernetes Deployment](#kubernetes-deployment)
6. [Cloud Provider Deployment](#cloud-provider-deployment)
7. [On-Premises Deployment](#on-premises-deployment)
8. [Configuration](#configuration)
9. [Monitoring and Logging](#monitoring-and-logging)
10. [Security Considerations](#security-considerations)
11. [Backup and Recovery](#backup-and-recovery)
12. [Troubleshooting](#troubleshooting)
13. [Performance Optimization](#performance-optimization)

## Overview

NoodleCore is a distributed AI programming language and runtime system designed for high-performance computing and machine learning workloads. This deployment guide covers various deployment scenarios to ensure optimal performance and reliability.

### Key Features

- Multi-architecture support (x86_64, ARM64)
- Containerized deployment options
- Kubernetes orchestration
- Comprehensive monitoring and logging
- Security hardening
- Automated backup and recovery

## Prerequisites

### System Requirements

- **CPU**: 2+ cores (4+ cores recommended for production)
- **Memory**: 4GB RAM (8GB+ recommended for production)
- **Storage**: 10GB+ free space
- **OS**: Linux (Ubuntu 18.04+, CentOS 7+), macOS 10.14+, or Windows Server 2016+
- **Python**: 3.8+ (if installing from source)

### Network Requirements

- **Inbound Ports**: 8080 (HTTP), 8443 (HTTPS), 5432 (PostgreSQL), 6379 (Redis)
- **Outbound Ports**: 443 (HTTPS), 80 (HTTP)
- **Bandwidth**: 10Mbps+ (recommended for distributed workloads)

### Software Dependencies

- Docker 20.10+ (for containerized deployment)
- Kubernetes 1.20+ (for orchestration)
- Docker Compose 1.29+ (for local development)
- OpenSSL 1.1+ (for encryption)
- Git (for source code management)

## Installation Methods

### 1. Quick Installation (Recommended)

#### Linux/macOS
```bash
curl -fsSL https://raw.githubusercontent.com/noodle/noodlecore/main/scripts/install-noodlecore.sh | sudo bash
```

#### Windows
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/noodle/noodlecore/main/scripts/install-noodlecore.bat" -OutFile "install-noodlecore.bat"
.\install-noodlecore.bat
```

### 2. Docker Installation

```bash
# Pull the latest image
docker pull noodlecore/noodlecore:latest

# Run the container
docker run -d \
  --name noodlecore \
  -p 8080:8080 \
  -v /opt/noodlecore/data:/app/data \
  -v /opt/noodlecore/logs:/app/logs \
  noodlecore/noodlecore:latest
```

### 3. Source Code Installation

```bash
# Clone the repository
git clone https://github.com/noodle/noodlecore.git
cd noodlecore

# Install dependencies
pip install -r requirements.txt

# Install the package
pip install -e .
```

## Docker Deployment

### Basic Docker Deployment

1. **Pull the image**:
   ```bash
   docker pull noodlecore/noodlecore:latest
   ```

2. **Create a data directory**:
   ```bash
   mkdir -p /opt/noodlecore/{data,logs,config}
   ```

3. **Run the container**:
   ```bash
   docker run -d \
     --name noodlecore \
     -p 8080:8080 \
     -v /opt/noodlecore/data:/app/data \
     -v /opt/noodlecore/logs:/app/logs \
     -v /opt/noodlecore/config:/app/config \
     -e NoodleCore_ENV=production \
     -e NoodleCore_LOG_LEVEL=INFO \
     noodlecore/noodlecore:latest
   ```

### Docker Compose Deployment

1. **Create a `docker-compose.yml` file**:
   ```yaml
   version: '3.8'
   
   services:
     noodlecore:
       image: noodlecore/noodlecore:latest
       ports:
         - "8080:8080"
       volumes:
         - ./data:/app/data
         - ./logs:/app/logs
         - ./config:/app/config
       environment:
         - NoodleCore_ENV=production
         - NoodleCore_LOG_LEVEL=INFO
       restart: unless-stopped
   
     postgres:
       image: postgres:15
       environment:
         POSTGRES_DB: noodlecore
         POSTGRES_USER: postgres
         POSTGRES_PASSWORD: password
       volumes:
         - postgres_data:/var/lib/postgresql/data
       ports:
         - "5432:5432"
   
     redis:
       image: redis:7-alpine
       ports:
         - "6379:6379"
       volumes:
         - redis_data:/data
   
   volumes:
     postgres_data:
     redis_data:
   ```

2. **Start the services**:
   ```bash
   docker-compose up -d
   ```

### Production Docker Deployment

For production, use the enhanced Docker Compose configuration:

```bash
docker-compose -f docker-compose.production.yml up -d
```

This includes:
- Multi-container architecture
- Load balancing
- Health checks
- Monitoring and logging
- Security hardening

## Kubernetes Deployment

### Prerequisites

- Kubernetes cluster (v1.20+)
- kubectl configured
- Helm 3.0+ (optional)

### Basic Kubernetes Deployment

1. **Apply the manifests**:
   ```bash
   kubectl apply -f k8s-deployment.yaml
   kubectl apply -f k8s-service.yaml
   kubectl apply -f k8s-ingress.yaml
   ```

2. **Check deployment status**:
   ```bash
   kubectl get pods -l app=noodle-runtime
   kubectl get services
   kubectl get ingress
   ```

### Production Kubernetes Deployment

For production, use the enhanced manifests:

```bash
# Create namespace
kubectl create namespace noodle-prod

# Apply production manifests
kubectl apply -f k8s-namespace.yaml
kubectl apply -f k8s-configmap.yaml
kubectl apply -f k8s-secret.yaml
kubectl apply -f k8s-deployment.yaml
kubectl apply -f k8s-service.yaml
kubectl apply -f k8s-ingress.yaml
kubectl apply -f k8s-pvc.yaml
kubectl apply -f k8s-redis-deployment.yaml
kubectl apply -f k8s-redis-service.yaml
```

### Helm Chart Deployment

```bash
# Add the Helm repository
helm repo add noodle-core https://noodle.github.io/noodle-core

# Install the chart
helm install noodle-core noodle-core/noodle-core \
  --namespace noodle-prod \
  --create-namespace \
  --set image.tag=latest \
  --set service.type=LoadBalancer
```

## Cloud Provider Deployment

### AWS Deployment

#### Using AWS ECS

1. **Create a task definition**:
   ```json
   {
     "family": "noodlecore",
     "networkMode": "awsvpc",
     "requiresCompatibilities": ["FARGATE"],
     "cpu": "256",
     "memory": "512",
     "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
     "containerDefinitions": [
       {
         "name": "noodlecore",
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
             "value": "production"
           }
         ],
         "logConfiguration": {
           "logDriver": "awslogs",
           "options": {
             "awslogs-group": "/ecs/noodlecore",
             "awslogs-region": "us-east-1",
             "awslogs-stream-prefix": "ecs"
           }
         }
       }
     ]
   }
   ```

2. **Create a service**:
   ```bash
   aws ecs create-service \
     --cluster noodlecore-cluster \
     --service-name noodlecore-service \
     --task-definition noodlecore:1 \
     --desired-count 3 \
     --launch-type FARGATE \
     --network-configuration "awsvpcConfiguration={subnets=[subnet-12345678],securityGroups=[sg-12345678],assignPublicIp=ENABLED}"
   ```

#### Using AWS EKS

```bash
# Deploy to EKS
kubectl apply -f https://raw.githubusercontent.com/noodle/noodlecore/main/k8s/aws-eks.yaml
```

### Google Cloud Platform (GCP) Deployment

#### Using Google Kubernetes Engine (GKE)

```bash
# Create a GKE cluster
gcloud container clusters create noodlecore-cluster \
  --zone us-central1-a \
  --machine-type e2-medium \
  --num-nodes 3

# Deploy NoodleCore
kubectl apply -f https://raw.githubusercontent.com/noodle/noodlecore/main/k8s/gcp-gke.yaml
```

### Microsoft Azure Deployment

#### Using Azure Kubernetes Service (AKS)

```bash
# Create an AKS cluster
az aks create \
  --resource-group noodlecore-rg \
  --name noodlecore-cluster \
  --node-count 3 \
  --node-vm-size Standard_DS2_v2

# Get credentials
az aks get-credentials --resource-group noodlecore-rg --name noodlecore-cluster

# Deploy NoodleCore
kubectl apply -f https://raw.githubusercontent.com/noodle/noodlecore/main/k8s/aks.yaml
```

## On-Premises Deployment

### Bare Metal Installation

1. **Prepare the server**:
   ```bash
   # Update the system
   sudo apt update && sudo apt upgrade -y
   
   # Install dependencies
   sudo apt install -y python3 python3-pip python3-venv postgresql redis-server
   
   # Create service user
   sudo useradd -r -s /bin/false noodlecore
   ```

2. **Install NoodleCore**:
   ```bash
   # Download and install
   curl -fsSL https://raw.githubusercontent.com/noodle/noodlecore/main/scripts/install-noodlecore.sh | sudo bash
   
   # Start the service
   sudo systemctl start noodlecore
   sudo systemctl enable noodlecore
   ```

### Virtual Machine Deployment

1. **Create VM**:
   - Ubuntu 20.04 LTS
   - 4 vCPUs
   - 8GB RAM
   - 50GB storage

2. **Follow the bare metal installation steps**

## Configuration

### Environment Variables

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `NoodleCore_ENV` | Environment (development/production) | `development` |
| `NoodleCore_LOG_LEVEL` | Logging level (DEBUG/INFO/WARNING/ERROR) | `INFO` |
| `NoodleCore_DATA_DIR` | Data directory path | `/app/data` |
| `NoodleCore_LOG_DIR` | Log directory path | `/app/logs` |
| `NoodleCore_CONFIG_DIR` | Configuration directory path | `/app/config` |
| `DATABASE_URL` | Database connection URL | `sqlite:///data/noodlecore.db` |
| `REDIS_URL` | Redis connection URL | `redis://localhost:6379` |
| `SECRET_KEY` | Secret key for encryption | Auto-generated |

### Configuration Files

#### Main Configuration (`config/noodlecore.conf`)

```ini
[NoodleCore]
environment = production
log_level = INFO
data_dir = /app/data
log_dir = /app/logs
config_dir = /app/config
cache_dir = /app/cache

[Database]
url = postgresql://user:pass@localhost:5432/noodlecore
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
secret_key = your-secret-key-here
debug = false
```

#### Database Configuration

```ini
[Database]
url = postgresql://user:pass@localhost:5432/noodlecore
pool_size = 20
max_overflow = 30
pool_timeout = 30
pool_recycle = 3600
```

## Monitoring and Logging

### Built-in Monitoring

NoodleCore includes built-in monitoring endpoints:

```bash
# Health check
curl http://localhost:8080/health

# Metrics
curl http://localhost:8080/metrics

# Logs
curl http://localhost:8080/logs
```

### External Monitoring Tools

#### Prometheus + Grafana

1. **Configure Prometheus**:
   ```yaml
   scrape_configs:
     - job_name: 'noodlecore'
       static_configs:
         - targets: ['noodlecore:8080']
   ```

2. **Configure Grafana**:
   - Import the NoodleCore dashboard
   - Set up data source
   - Configure alerts

#### ELK Stack (Elasticsearch, Logstash, Kibana)

```yaml
# Filebeat configuration
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /app/logs/*.log
  fields:
    service: noodlecore
```

## Security Considerations

### Network Security

1. **Firewall Rules**:
   ```bash
   # Allow HTTP/HTTPS
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   
   # Allow database ports (if needed)
   sudo ufw allow 5432/tcp
   sudo ufw allow 6379/tcp
   ```

2. **SSL/TLS Configuration**:
   ```bash
   # Generate SSL certificate
   openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365
   
   # Configure Nginx
   server {
       listen 443 ssl;
       server_name your-domain.com;
       
       ssl_certificate /path/to/cert.pem;
       ssl_certificate_key /path/to/key.pem;
       
       location / {
           proxy_pass http://noodlecore:8080;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

### Application Security

1. **Environment Variables**:
   ```bash
   # Set secure environment variables
   export SECRET_KEY=$(openssl rand -hex 32)
   export DATABASE_URL="postgresql://user:secure_password@localhost:5432/noodlecore"
   ```

2. **Container Security**:
   ```dockerfile
   # Use non-root user
   USER noodlecore
   
   # Read-only filesystem
   VOLUME ["/app/data", "/app/logs", "/app/config"]
   ```

## Backup and Recovery

### Automated Backups

1. **Schedule daily backups**:
   ```bash
   # Add to crontab
   0 2 * * * /opt/noodlecore/scripts/backup.sh
   ```

2. **Backup script**:
   ```bash
   # Create backup
   /opt/noodlecore/scripts/backup.sh
   
   # Restore from backup
   /opt/noodlecore/scripts/restore.sh 20231201
   ```

### Disaster Recovery

1. **Backup Strategy**:
   - Daily backups (retained for 30 days)
   - Weekly backups (retained for 3 months)
   - Monthly backups (retained for 1 year)
   - Off-site replication

2. **Recovery Procedure**:
   ```bash
   # Stop services
   sudo systemctl stop noodlecore
   
   # Restore from backup
   sudo /opt/noodlecore/scripts/disaster-recovery.sh
   
   # Start services
   sudo systemctl start noodlecore
   ```

## Troubleshooting

### Common Issues

#### 1. Service Won't Start

**Problem**: NoodleCore service fails to start

**Solution**:
```bash
# Check logs
journalctl -u noodlecore -f

# Check dependencies
systemctl status postgresql
systemctl status redis

# Verify configuration
/opt/noodlecore/venv/bin/noodlecore --validate-config
```

#### 2. Database Connection Issues

**Problem**: Cannot connect to database

**Solution**:
```bash
# Test database connection
psql -h localhost -U postgres -d noodlecore

# Check database logs
tail -f /var/log/postgresql/postgresql.log

# Reset database password
sudo -u postgres psql
ALTER USER postgres PASSWORD 'new_password';
```

#### 3. Memory Issues

**Problem**: High memory usage or out of memory errors

**Solution**:
```bash
# Check memory usage
free -h
top -p $(pgrep -f noodlecore)

# Adjust memory limits
# In config/noodlecore.conf:
[Memory]
max_memory = 4G
cache_size = 1G
```

#### 4. Network Issues

**Problem**: Cannot access NoodleCore service

**Solution**:
```bash
# Check if service is running
systemctl status noodlecore

# Check port usage
netstat -tlnp | grep 8080

# Check firewall
sudo ufw status

# Test connectivity
curl http://localhost:8080/health
```

### Performance Issues

#### 1. Slow Response Times

**Solution**:
```bash
# Check system resources
htop
iostat

# Optimize database
psql -U postgres -d noodlecore -c "VACUUM ANALYZE;"

# Enable caching
# In config/noodlecore.conf:
[Cache]
enabled = true
ttl = 300
max_size = 1000
```

#### 2. High CPU Usage

**Solution**:
```bash
# Identify CPU-intensive processes
top -H -p $(pgrep -f noodlecore)

# Optimize code
# Enable JIT compilation
export NoodleCore_JIT_ENABLED=true

# Use worker processes
# In config/noodlecore.conf:
[Server]
workers = 8
```

### Log Analysis

#### 1. View Logs

```bash
# Application logs
tail -f /opt/noodlecore/logs/noodlecore.log

# System logs
journalctl -u noodlecore -f

# Docker logs
docker logs -f noodlecore
```

#### 2. Search Logs

```bash
# Search for errors
grep -i error /opt/noodlecore/logs/noodlecore.log

# Search for specific patterns
grep "2023-12-01" /opt/noodlecore/logs/noodlecore.log

# Real-time monitoring
tail -f /opt/noodlecore/logs/noodlecore.log | grep -i error
```

### Debug Mode

Enable debug mode for troubleshooting:

```bash
# Set environment variable
export NoodleCore_ENV=development
export NoodleCore_LOG_LEVEL=DEBUG

# Restart service
sudo systemctl restart noodlecore
```

## Performance Optimization

### System Optimization

1. **Filesystem Optimization**:
   ```bash
   # Use XFS for better performance
   mkfs.xfs /dev/sdb
   mount /dev/sdb /opt/noodlecore/data
   ```

2. **Network Optimization**:
   ```bash
   # Increase TCP buffer sizes
   echo 'net.core.rmem_max = 16777216' >> /etc/sysctl.conf
   echo 'net.core.wmem_max = 16777216' >> /etc/sysctl.conf
   sysctl -p
   ```

### Application Optimization

1. **Database Optimization**:
   ```sql
   -- Add indexes
   CREATE INDEX idx_tasks_status ON tasks(status);
   CREATE INDEX idx_tasks_created_at ON tasks(created_at);
   
   -- Optimize queries
   EXPLAIN ANALYZE SELECT * FROM tasks WHERE status = 'pending';
   ```

2. **Caching Optimization**:
   ```ini
   [Cache]
   enabled = true
   ttl = 300
   max_size = 1000
   redis_url = redis://localhost:6379
   ```

### Container Optimization

1. **Docker Optimization**:
   ```dockerfile
   # Use multi-stage build
   FROM python:3.12-slim as builder
   RUN pip install --user -r requirements.txt
   
   FROM python:3.12-slim
   COPY --from=builder /root/.local /root/.local
   ENV PATH=/root/.local/bin:$PATH
   ```

2. **Kubernetes Optimization**:
   ```yaml
   resources:
     limits:
       memory: "1Gi"
       cpu: "1000m"
     requests:
       memory: "512Mi"
       cpu: "500m"
   ```

## Support

### Getting Help

1. **Documentation**: https://noodlecore.readthedocs.io/
2. **GitHub Issues**: https://github.com/noodle/noodlecore/issues
3. **Community Forum**: https://discuss.noodlecore.org/
4. **Email**: support@noodlecore.com

### Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.