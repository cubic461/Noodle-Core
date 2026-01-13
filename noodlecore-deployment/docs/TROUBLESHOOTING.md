# NoodleCore Troubleshooting Guide

This guide provides solutions to common issues encountered during NoodleCore deployment and operation.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Installation Issues](#installation-issues)
3. [Docker Deployment Issues](#docker-deployment-issues)
4. [Kubernetes Deployment Issues](#kubernetes-deployment-issues)
5. [Performance Issues](#performance-issues)
6. [Database Issues](#database-issues)
7. [Network Issues](#network-issues)
8. [Security Issues](#security-issues)
9. [Backup and Recovery Issues](#backup-and-recovery-issues)
10. [Common Error Messages](#common-error-messages)
11. [Debug Mode](#debug-mode)
12. [Support](#support)

## Getting Started

### Basic Troubleshooting Steps

1. **Check logs**: Always start by checking the logs
2. **Verify configuration**: Ensure all configuration files are correct
3. **Check dependencies**: Verify all required services are running
4. **Test connectivity**: Ensure network connectivity is working
5. **Check resources**: Verify system resources (CPU, memory, disk)

### Log Locations

| Component | Log Location | Description |
|-----------|--------------|-------------|
| NoodleCore | `/opt/noodlecore/logs/noodlecore.log` | Main application logs |
| Docker | `docker logs <container_name>` | Container logs |
| Kubernetes | `kubectl logs <pod_name>` | Pod logs |
| System | `journalctl -u noodlecore` | System service logs |
| Database | `/var/log/postgresql/postgresql.log` | PostgreSQL logs |
| Redis | `/var/log/redis/redis-server.log` | Redis logs |

## Installation Issues

### Python Installation Issues

**Problem**: Python 3.8+ not found

```bash
# Check Python version
python3 --version

# Install Python 3.8+
# Ubuntu/Debian
sudo apt update
sudo apt install python3.8 python3.8-venv python3.8-dev

# CentOS/RHEL
sudo yum install python3.8 python3.8-venv python3.8-devel

# macOS
brew install python@3.8
```

**Problem**: pip not working

```bash
# Install pip
python3 -m ensurepip --upgrade

# Or install manually
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py
```

### Permission Issues

**Problem**: Permission denied when installing

```bash
# Install for current user (recommended)
pip3 install --user noodlecore

# Or use sudo (not recommended)
sudo pip3 install noodlecore

# Fix permissions
sudo chown -R $USER:$USER ~/.local
```

### Virtual Environment Issues

**Problem**: Cannot create virtual environment

```bash
# Install virtualenv
pip3 install --user virtualenv

# Create virtual environment
python3 -m venv noodlecore-env

# Activate virtual environment
source noodlecore-env/bin/activate
```

## Docker Deployment Issues

### Container Won't Start

**Problem**: Container exits immediately

```bash
# Check container logs
docker logs noodlecore

# Check container status
docker ps -a

# Start in interactive mode for debugging
docker run -it --rm noodlecore/noodlecore:latest /bin/bash
```

**Common Solutions**:
- Check if required ports are available
- Verify volume mounts
- Check environment variables
- Ensure image is compatible with your architecture

### Port Conflicts

**Problem**: Port already in use

```bash
# Check port usage
netstat -tlnp | grep 8080

# Find process using port
lsof -i :8080

# Kill process
sudo kill -9 <PID>

# Or use different port
docker run -p 8081:8080 noodlecore/noodlecore:latest
```

### Volume Mount Issues

**Problem**: Cannot access mounted volumes

```bash
# Check volume permissions
ls -la /opt/noodlecore/data/

# Fix permissions
sudo chown -R 1000:1000 /opt/noodlecore/data/

# Or create volume with correct permissions
docker volume create --name noodlecore-data --opt type=none --opt device=/opt/noodlecore/data --opt o=bind
```

### Network Issues

**Problem**: Cannot access container from host

```bash
# Check network settings
docker network ls
docker network inspect bridge

# Use host network (for development only)
docker run --network host noodlecore/noodlecore:latest

# Or expose port correctly
docker run -p 8080:8080 noodlecore/noodlecore:latest
```

## Kubernetes Deployment Issues

### Pod Won't Start

**Problem**: Pod in CrashLoopBackOff state

```bash
# Check pod events
kubectl describe pod <pod_name>

# Check pod logs
kubectl logs <pod_name> --previous

# Check container status
kubectl get pods -o wide
```

**Common Solutions**:
- Check resource limits
- Verify image pull policy
- Check environment variables
- Verify configuration files

### Image Pull Issues

**Problem**: Cannot pull image

```bash
# Check image pull secrets
kubectl get secrets

# Check image repository access
kubectl describe pod <pod_name> | grep -i image

# Test image pull manually
docker pull noodlecore/noodlecore:latest
```

### Resource Issues

**Problem**: Pod OOMKilled or resource limits exceeded

```bash
# Check resource usage
kubectl top pods

# Check pod events
kubectl describe pod <pod_name>

# Increase resource limits
kubectl edit deployment noodle-runtime
```

### Network Issues

**Problem**: Service not accessible

```bash
# Check service status
kubectl get services

# Check endpoints
kubectl get endpoints

# Check network policies
kubectl get networkpolicy

# Test connectivity
kubectl exec -it <pod_name> -- wget -qO- http://localhost:8080/health
```

## Performance Issues

### High CPU Usage

**Problem**: CPU usage too high

```bash
# Check CPU usage
top -p $(pgrep -f noodlecore)
htop

# Check specific process
ps aux | grep noodlecore

# Optimize configuration
# In config/noodlecore.conf:
[Server]
workers = 4  # Reduce number of workers
```

### High Memory Usage

**Problem**: Memory usage too high

```bash
# Check memory usage
free -h
top -p $(pgrep -f noodlecore)

# Check memory limits
docker stats <container_name>

# Optimize configuration
# In config/noodlecore.conf:
[Memory]
max_memory = 2G
cache_size = 512M
```

### Slow Response Times

**Problem**: Application response slow

```bash
# Check system resources
iostat
vmstat

# Check database queries
psql -U postgres -d noodlecore -c "SELECT query, calls, total_time FROM pg_stat_statements ORDER BY total_time DESC LIMIT 10;"

# Enable caching
# In config/noodlecore.conf:
[Cache]
enabled = true
ttl = 300
```

### Database Performance Issues

**Problem**: Database queries slow

```bash
# Check database performance
psql -U postgres -d noodlecore -c "SELECT * FROM pg_stat_activity WHERE state = 'active';"

# Analyze queries
EXPLAIN ANALYZE SELECT * FROM tasks WHERE status = 'pending';

# Add indexes
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_created_at ON tasks(created_at);
```

## Database Issues

### Connection Issues

**Problem**: Cannot connect to database

```bash
# Test database connection
psql -h localhost -U postgres -d noodlecore

# Check database status
systemctl status postgresql

# Check database logs
tail -f /var/log/postgresql/postgresql.log

# Reset password
sudo -u postgres psql
ALTER USER postgres PASSWORD 'new_password';
```

### Database Migration Issues

**Problem**: Migration fails

```bash
# Check migration status
psql -U postgres -d noodlecore -c "SELECT * FROM django_migrations;"

# Run migration manually
python manage.py migrate

# Reset database (last resort)
sudo -u postgres dropdb noodlecore
sudo -u postgres createdb noodlecore
python manage.py migrate
```

### Table Lock Issues

**Problem**: Tables locked

```bash
# Check locked tables
SELECT * FROM pg_locks WHERE relation IN (SELECT oid FROM pg_class WHERE relname = 'tasks');

# Kill blocking queries
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() AND state = 'active';
```

## Network Issues

### Port Access Issues

**Problem**: Cannot access service on specific port

```bash
# Check if port is open
netstat -tlnp | grep 8080

# Test connectivity
telnet localhost 8080
nc -zv localhost 8080

# Check firewall
sudo ufw status
sudo iptables -L
```

### Load Balancer Issues

**Problem**: Load balancer not routing traffic

```bash
# Check load balancer status
kubectl get service <service_name>

# Check endpoints
kubectl get endpoints

# Test service directly
kubectl port-forward svc/<service_name> 8080:8080
```

### DNS Issues

**Problem**: Service discovery not working

```bash
# Check DNS resolution
kubectl exec -it <pod_name> -- nslookup noodle-core-service

# Check DNS configuration
kubectl get configmap -n kube-system coredns

# Test DNS manually
kubectl exec -it <pod_name> -- curl http://noodle-core-service:8080/health
```

## Security Issues

### SSL/TLS Issues

**Problem**: SSL certificate not working

```bash
# Check certificate
openssl x509 -in cert.pem -text

# Test HTTPS connection
curl -k https://localhost:8443/health

# Generate self-signed certificate
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
```

### Authentication Issues

**Problem**: Authentication failing

```bash
# Check authentication logs
tail -f /opt/noodlecore/logs/auth.log

# Reset password
python manage.py changepassword admin

# Check user permissions
psql -U postgres -d noodlecore -c "SELECT * FROM auth_user;"
```

### Permission Issues

**Problem**: File permission errors

```bash
# Check file permissions
ls -la /opt/noodlecore/

# Fix permissions
sudo chown -R noodlecore:noodlecore /opt/noodlecore/
sudo chmod -R 755 /opt/noodlecore/
```

## Backup and Recovery Issues

### Backup Issues

**Problem**: Backup failing

```bash
# Check backup logs
tail -f /opt/noodlecore/logs/backup.log

# Check disk space
df -h

# Test backup manually
/opt/noodlecore/scripts/backup.sh

# Check backup permissions
ls -la /opt/noodlecore/backups/
```

### Recovery Issues

**Problem**: Recovery failing

```bash
# Check recovery logs
tail -f /opt/noodlecore/logs/recovery.log

# Verify backup files
ls -la /opt/noodlecore/backups/

# Test recovery manually
/opt/noodlecore/scripts/recovery.sh 20231201
```

### Database Recovery Issues

**Problem**: Database recovery failing

```bash
# Check backup file
file /opt/noodlecore/backups/database_backup_20231201.sql.gz

# Restore manually
gunzip /opt/noodlecore/backups/database_backup_20231201.sql.gz
psql -U postgres -d noodlecore < /opt/noodlecore/backups/database_backup_20231201.sql
```

## Common Error Messages

### "No module named 'noodlecore'"

**Solution**:
```bash
# Install the package
pip install noodlecore

# Or install from source
git clone https://github.com/noodle/noodlecore.git
cd noodlecore
pip install -e .
```

### "Database connection failed"

**Solution**:
```bash
# Check database service
systemctl status postgresql

# Check database connection
psql -h localhost -U postgres -d noodlecore

# Check database configuration
cat /etc/postgresql/12/main/postgresql.conf
```

### "Port already in use"

**Solution**:
```bash
# Find process using port
lsof -i :8080

# Kill process
sudo kill -9 <PID>

# Or use different port
export PORT=8081
```

### "Permission denied"

**Solution**:
```bash
# Check file permissions
ls -la /opt/noodlecore/

# Fix permissions
sudo chown -R $USER:$USER /opt/noodlecore/
```

### "Container not found"

**Solution**:
```bash
# Check available images
docker images

# Pull image
docker pull noodlecore/noodlecore:latest

# Check image
docker images | grep noodlecore
```

### "Pod not ready"

**Solution**:
```bash
# Check pod status
kubectl get pods

# Check pod events
kubectl describe pod <pod_name>

# Check pod logs
kubectl logs <pod_name>
```

## Debug Mode

### Enable Debug Mode

```bash
# Set environment variables
export NoodleCore_ENV=development
export NoodleCore_LOG_LEVEL=DEBUG

# Restart service
sudo systemctl restart noodlecore

# Or for Docker
docker restart noodlecore
```

### Debug Tools

```bash
# Python debugger
python -m pdb -m noodlecore

# Remote debugger
python -m pdb -m noodlecore --debug-port 5678

# Memory profiler
python -m memory_profiler -m noodlecore

# CPU profiler
python -m cProfile -o profile.out -m noodlecore
```

### Log Analysis

```bash
# Real-time log monitoring
tail -f /opt/noodlecore/logs/noodlecore.log | grep -i error

# Log rotation
sudo logrotate -f /etc/logrotate.d/noodlecore

# Log analysis
grep "ERROR" /opt/noodlecore/logs/noodlecore.log | wc -l
```

## Support

### Getting Help

1. **Check the documentation**: https://noodlecore.readthedocs.io/
2. **Search existing issues**: https://github.com/noodle/noodlecore/issues
3. **Create a new issue**: https://github.com/noodle/noodlecore/issues/new
4. **Community forum**: https://discuss.noodlecore.org/
5. **Email support**: support@noodlecore.com

### Creating a Good Bug Report

When reporting a bug, please include:

1. **Environment details**:
   - Operating system
   - Python version
   - NoodleCore version
   - Docker/Kubernetes version

2. **Steps to reproduce**:
   - What you were trying to do
   - What you expected to happen
   - What actually happened

3. **Error messages**:
   - Full error stack trace
   - Log excerpts

4. **Configuration**:
   - Relevant configuration files
   - Environment variables

5. **System information**:
   - CPU/memory usage
   - Disk space
   - Network topology

### Contributing

If you'd like to contribute to the troubleshooting guide:

1. Fork the repository
2. Create a new branch
3. Add your troubleshooting solution
4. Submit a pull request

### License

This troubleshooting guide is part of the NoodleCore project and is licensed under the MIT License.