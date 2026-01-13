# NoodleCore Deployment Infrastructure

## Overview

This document provides a comprehensive guide to the NoodleCore deployment infrastructure, including Docker containerization, Kubernetes orchestration, and deployment scripts for different environments.

## Deployment Architecture

### Components

1. **NoodleCore Runtime** - Main application server
2. **PostgreSQL Database** - Primary data storage
3. **Redis Cache** - Session and data caching
4. **NoodleCore IDE** - Development interface
5. **Prometheus** - Monitoring and metrics collection
6. **Grafana** - Monitoring dashboard
7. **Nginx** - Reverse proxy and load balancer

### Environments

- **Development** - Local development with hot-reload
- **Staging** - Pre-production environment with SSL
- **Production** - Production-ready deployment

## Docker Containerization

### Docker Images

#### Base Dockerfile (`docker/Dockerfile`)
- Multi-stage build for development
- Python 3.12-slim base image
- Non-root user configuration
- Health checks and monitoring

#### Production Dockerfile (`docker/Dockerfile.production`)
- Multi-architecture support (linux/amd64, linux/arm64)
- Security scanning with Trivy
- Optimized runtime environment
- Production-ready configuration

#### PostgreSQL Dockerfile (`docker/Dockerfile.postgres`)
- PostgreSQL 15-alpine
- Custom configuration
- Database initialization scripts
- Security best practices

#### Redis Dockerfile (`docker/Dockerfile.redis`)
- Redis 7-alpine
- Custom configuration
- Password protection
- AOF persistence

### Docker Compose Files

#### Development (`docker/docker-compose.yml`)
```bash
# Start development environment
./scripts/deploy/deploy-dev.sh setup

# Start services
./scripts/deploy/deploy-dev.sh start

# Check status
./scripts/deploy/deploy-dev.sh status

# View logs
./scripts/deploy/deploy-dev.sh logs

# Stop environment
./scripts/deploy/deploy-dev.sh stop
```

**Features:**
- Hot-reload for development
- Debug logging
- Health checks
- Volume mounting for development
- Prometheus and Grafana monitoring

#### Staging (`docker/docker-compose.staging.yml`)
```bash
# Start staging environment
./scripts/deploy/deploy-staging.sh setup

# Start services
./scripts/deploy/deploy-staging.sh start

# Check status
./scripts/deploy/deploy-staging.sh status

# View logs
./scripts/deploy/deploy-staging.sh logs

# Stop environment
./scripts/deploy/deploy-staging.sh stop
```

**Features:**
- SSL/TLS encryption
- Load balancing
- Resource limits
- Health checks
- Monitoring and logging
- Nginx reverse proxy

## Kubernetes Deployment

### Namespace Configuration

```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: noodle-core
  labels:
    name: noodle-core
    environment: production
```

### PostgreSQL Deployment

```yaml
# k8s/postgres-deployment.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  namespace: noodle-core
spec:
  serviceName: postgres-service
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15-alpine
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_DB
          value: "noodlecore"
        - name: POSTGRES_USER
          value: "noodlecore"
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: POSTGRES_PASSWORD
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
        livenessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - noodlecore
```

### Redis Deployment

```yaml
# k8s/redis-deployment.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis
  namespace: noodle-core
spec:
  serviceName: redis-service
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:7-alpine
        ports:
        - containerPort: 6379
        command:
        - redis-server
        - /etc/redis/redis.conf
        - --requirepass
        - $(REDIS_PASSWORD)
        env:
        - name: REDIS_PASSWORD
          valueFrom:
            secretKeyRef:
              name: redis-secret
              key: REDIS_PASSWORD
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        volumeMounts:
        - name: redis-data
          mountPath: /data
```

### NoodleCore Runtime Deployment

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: noodle-runtime
  namespace: noodle-core
spec:
  replicas: 3
  selector:
    matchLabels:
      app: noodle-runtime
  template:
    metadata:
      labels:
        app: noodle-runtime
    spec:
      containers:
      - name: noodle-runtime
        image: noodle-runtime:latest
        ports:
        - containerPort: 8080
        env:
        - name: NOODLE_ENV
          value: "production"
        - name: REDIS_URL
          value: "redis://redis-service:6379"
        - name: DATABASE_URL
          value: "postgresql://postgres-service:5432/noodlecore"
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
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
```

### Service Configuration

```yaml
# k8s/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: noodle-runtime-service
  namespace: noodle-core
spec:
  selector:
    app: noodle-runtime
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: LoadBalancer
```

### Ingress Configuration

```yaml
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: noodle-ingress
  namespace: noodle-core
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - noodle.example.com
    secretName: noodle-tls
  rules:
  - host: noodle.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: noodle-runtime-service
            port:
              number: 80
```

## Deployment Scripts

### Development Environment

```bash
# Setup development environment
./scripts/deploy/deploy-dev.sh setup

# Start development environment
./scripts/deploy/deploy-dev.sh start

# Check service status
./scripts/deploy/deploy-dev.sh status

# View logs
./scripts/deploy/deploy-dev.sh logs

# Stop development environment
./scripts/deploy/deploy-dev.sh stop

# Clean up
./scripts/deploy/deploy-dev.sh cleanup
```

### Staging Environment

```bash
# Setup staging environment
./scripts/deploy/deploy-staging.sh setup

# Start staging environment
./scripts/deploy/deploy-staging.sh start

# Check service status
./scripts/deploy/deploy-staging.sh status

# View logs
./scripts/deploy/deploy-staging.sh logs

# Stop staging environment
./scripts/deploy/deploy-staging.sh stop

# Clean up
./scripts/deploy/deploy-staging.sh cleanup
```

### Kubernetes Deployment

```bash
# Deploy to Kubernetes
./scripts/deploy/deploy-k8s.sh deploy

# Verify deployment
./scripts/deploy/deploy-k8s.sh verify

# Get deployment status
./scripts/deploy/deploy-k8s.sh status

# Scale deployment
./scripts/deploy/deploy-k8s.sh scale 5

# Rollback deployment
./scripts/deploy/deploy-k8s.sh rollback noodle-runtime 2

# Clean up
./scripts/deploy/deploy-k8s.sh cleanup
```

## Configuration Management

### Environment Variables

| Variable | Description | Default | Environment |
|----------|-------------|---------|-------------|
| `NOODLE_ENV` | Environment type | development | All |
| `NOODLE_LOG_LEVEL` | Logging level | INFO | All |
| `NOODLE_PORT` | Application port | 8080 | All |
| `NOODLE_DATA_DIR` | Data directory | /app/data | All |
| `NOODLE_CONFIG_DIR` | Config directory | /app/config | All |
| `DATABASE_URL` | Database connection string | - | All |
| `REDIS_URL` | Redis connection string | - | All |
| `SECRET_KEY` | Application secret | - | Production |
| `POSTGRES_PASSWORD` | PostgreSQL password | - | Production |
| `REDIS_PASSWORD` | Redis password | - | Production |
| `GRAFANA_PASSWORD` | Grafana password | - | Production |

### Configuration Files

#### Redis Configuration (`redis/redis.conf`)
- Memory limits and eviction policies
- Persistence settings
- Security configuration
- Performance tuning

#### PostgreSQL Configuration (`database/postgresql.conf`)
- Connection limits
- Memory settings
- Performance tuning
- Logging configuration

#### Nginx Configuration (`nginx/nginx.conf`)
- SSL/TLS settings
- Load balancing
- Security headers
- Compression settings

#### Prometheus Configuration (`monitoring/prometheus.yml`)
- Scraping targets
- Alert rules
- Storage settings
- Retention policies

## Security Considerations

### Container Security

- **Non-root users**: All containers run as non-root users
- **Security scanning**: Trivy integration for vulnerability scanning
- **Image signing**: Docker Content Trust for image verification
- **Resource limits**: CPU and memory limits for all containers

### Network Security

- **Network policies**: Kubernetes network policies for service isolation
- **TLS encryption**: SSL/TLS for all external communications
- **Authentication**: JWT tokens for API authentication
- **Authorization**: Role-based access control

### Data Security

- **Secrets management**: Kubernetes secrets for sensitive data
- **Encryption**: Data encryption at rest and in transit
- **Backup strategies**: Regular database backups
- **Access control**: Database connection pooling with limits

## Monitoring and Logging

### Prometheus Metrics

- Application metrics (response times, error rates)
- Database metrics (connection counts, query performance)
- Redis metrics (memory usage, hit rates)
- System metrics (CPU, memory, disk usage)

### Grafana Dashboards

- Application performance monitoring
- Database performance monitoring
- System resource monitoring
- Error rate tracking

### Logging

- **Structured logging**: JSON format for easy parsing
- **Log levels**: DEBUG, INFO, WARNING, ERROR
- **Log aggregation**: Centralized logging with Fluentd
- **Log retention**: Configurable retention policies

## Performance Optimization

### Container Optimization

- **Multi-stage builds**: Reduced image sizes
- **Layer caching**: Optimized Docker layer caching
- **Resource limits**: CPU and memory limits
- **Health checks**: Efficient health check intervals

### Database Optimization

- **Connection pooling**: 20 maximum connections
- **Query optimization**: Prepared statements
- **Indexing**: Proper indexing strategies
- **Caching**: Redis for frequently accessed data

### Network Optimization

- **Load balancing**: Multiple replicas for high availability
- **Caching**: Redis for session and data caching
- **Compression**: Gzip compression for static assets
- **CDN integration**: Content delivery network for static assets

## Backup and Recovery

### Database Backups

```bash
# Create database backup
docker-compose exec postgres pg_dump -U noodlecore noodlecore > backup.sql

# Restore database
docker-compose exec -T postgres psql -U noodlecore noodlecore < backup.sql
```

### Application Backups

```bash
# Create application backup
tar -czf backup-$(date +%Y%m%d).tar.gz data/ logs/ config/

# Restore application backup
tar -xzf backup-20231201.tar.gz
```

### Disaster Recovery

- **Automated backups**: Scheduled daily backups
- **Multi-region deployment**: Geographic redundancy
- **Failover mechanisms**: Automatic failover to standby
- **Recovery procedures**: Step-by-step recovery documentation

## Troubleshooting

### Common Issues

#### Service Not Starting
```bash
# Check container logs
docker-compose logs [service]

# Check container status
docker-compose ps

# Check resource usage
docker stats
```

#### Database Connection Issues
```bash
# Check database connectivity
docker-compose exec postgres pg_isready -U noodlecore

# Check database logs
docker-compose logs postgres

# Check database connections
docker-compose exec postgres psql -U noodlecore -c "SELECT count(*) FROM pg_stat_activity;"
```

#### Network Issues
```bash
# Check network connectivity
docker-compose exec noodle-core curl http://postgres:5432

# Check network configuration
docker network inspect noodle-dev-net

# Check port mapping
docker-compose port postgres 5432
```

### Performance Issues

#### High CPU Usage
```bash
# Check CPU usage
docker stats

# Analyze performance
docker-compose exec noodle-core python -m cProfile -s cumtime app.py

# Optimize queries
docker-compose exec postgres psql -U noodlecore -c "EXPLAIN ANALYZE SELECT * FROM table;"
```

#### Memory Issues
```bash
# Check memory usage
docker stats

# Analyze memory usage
docker-compose exec noodle-core python -m memory_profiler app.py

# Optimize memory usage
docker-compose exec noodle-core python -c "import gc; gc.collect()"
```

## Best Practices

### Development

1. **Use development environment** for local development
2. **Enable debug logging** for troubleshooting
3. **Use hot-reload** for rapid development
4. **Test changes** in development before staging

### Staging

1. **Use staging environment** for testing
2. **Test all features** thoroughly
3. **Performance testing** under load
4. **Security testing** for vulnerabilities

### Production

1. **Use production environment** for live deployment
2. **Monitor performance** continuously
3. **Regular backups** and testing
4. **Update regularly** for security patches

### Security

1. **Use strong passwords** and secrets
2. **Enable SSL/TLS** for all communications
3. **Regular security audits**
4. **Monitor for vulnerabilities**

### Performance

1. **Monitor performance** continuously
2. **Optimize queries** regularly
3. **Scale resources** as needed
4. **Use caching** effectively

## Support

### Documentation

- [API Documentation](./API_DOCUMENTATION.md)
- [Configuration Guide](./CONFIGURATION_GUIDE.md)
- [Troubleshooting Guide](./TROUBLESHOOTING.md)
- [Performance Guide](./PERFORMANCE_GUIDE.md)

### Community

- GitHub Issues: [NoodleCore Issues](https://github.com/noodle/noodlecore/issues)
- Community Forum: [NoodleCore Community](https://discuss.noodlecore.org/)
- Email Support: support@noodlecore.com

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License. See the [LICENSE](../LICENSE) file for details.