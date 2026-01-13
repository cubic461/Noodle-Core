
# Noodle Deployment Analysis

## Deployment Architecture Overview

### Deployment Strategy
Noodle project implements a comprehensive deployment strategy with containerization, orchestration, and multi-environment support. The deployment architecture is designed for scalability, reliability, and maintainability.

#### Deployment Principles
1. **Containerization**: All services containerized using Docker
2. **Orchestration**: Kubernetes for container orchestration
3. **Infrastructure as Code**: Terraform for infrastructure management
4. **CI/CD**: Automated build, test, and deployment pipelines
5. **Multi-environment**: Support for development, staging, and production environments

#### Deployment Architecture Components
| Component | Purpose | Technology | Key Features |
|-----------|---------|------------|--------------|
| Container Registry | Image storage and management | Docker Registry, Harbor | Image scanning, vulnerability scanning |
| Orchestration | Container orchestration | Kubernetes, Docker Swarm | Auto-scaling, self-healing |
| Load Balancer | Traffic distribution | Nginx, HAProxy | SSL termination, routing |
| Monitoring | System monitoring | Prometheus, Grafana | Metrics collection, alerting |
| Logging | Centralized logging | ELK Stack, Loki | Log aggregation, search |
| CI/CD | Continuous integration/ deployment | GitLab CI, GitHub Actions | Automated testing, deployment |

### Deployment Architecture Diagram
```mermaid
graph TB
    subgraph "Development Environment"
        A[Local Docker]
        B[Minikube]
        C[Kind]
        D[Local Kubernetes]
    end
    
    subgraph "Staging Environment"
        E[Staging Cluster]
        F[Staging Database]
        G[Staging Cache]
        H[Staging Storage]
    end
    
    subgraph "Production Environment"
        I[Production Cluster]
        J[Production Database]
        K[Production Cache]
        L[Production Storage]
    end
    
    subgraph "Infrastructure"
        M[Terraform]
        N[Ansible]
        O[Cloud Provider]
        P[CDN]
        Q[DNS]
    end
    
    subgraph "CI/CD Pipeline"
        R[Git Repository]
        S[Build System]
        T[Test System]
        U[Deployment System]
        V[Monitoring System]
    end
    
    R --> S
    S --> T
    T --> U
    U --> V
    
    S --> A
    S --> B
    S --> C
    S --> D
    
    U --> E
    U --> F
    U --> G
    U --> H
    
    U --> I
    U --> J
    U --> K
    U --> L
    
    M --> O
    N --> E
    N --> I
    
    Q --> I
    P --> I
    
    E --> F
    E --> G
    E --> H
    
    I --> J
    I --> K
    I --> L
```

## Containerization Analysis

### Docker Containerization
#### Dockerfile Structure
```dockerfile
# Base image
FROM python:3.9-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    make \
    curl \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create app user
RUN groupadd -r appuser && useradd -r -g appappuser

# Set working directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create directories
RUN mkdir -p /app/logs /app/data /app/config

# Set permissions
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Start command
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "4", "--timeout", "120", "app:app"]
```

#### Docker Compose Configuration
```yaml
version: '3.8'

services:
  # Noodle Core Service
  noodle-core:
    build:
      context: ./noodle-core
      dockerfile: Dockerfile
    container_name: noodle-core
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=postgresql://noodle_user:noodle_password@postgres:5432/noodle_db
      - REDIS_URL=redis://redis:6379/0
      - RABBITMQ_URL=amqp://guest:guest@rabbitmq:5672/
      - ENVIRONMENT=production
      - DEBUG=0
      - LOG_LEVEL=INFO
    volumes:
      - ./noodle-core/logs:/app/logs
      - ./noodle-core/data:/app/data
      - ./noodle-core/config:/app/config
    depends_on:
      - postgres
      - redis
      - rabbitmq
    networks:
      - noodle-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Noodle Net Service
  noodle-net:
    build:
      context: ./noodlenet
      dockerfile: Dockerfile
    container_name: noodle-net
    ports:
      - "8081:8080"
    environment:
      - DATABASE_URL=postgresql://noodle_user:noodle_password@postgres:5432/noodle_db
      - REDIS_URL=redis://redis:6379/0
      - ENVIRONMENT=production
      - DEBUG=0
      - LOG_LEVEL=INFO
    volumes:
      - ./noodlenet/logs:/app/logs
      - ./noodlenet/data:/app/data
      - ./noodlenet/models:/app/models
    depends_on:
      - postgres
      - redis
    networks:
      - noodle-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # AHR Runtime Service
  ahr-runtime:
    build:
      context: ./ahr-runtime
      dockerfile: Dockerfile
    container_name: ahr-runtime
    ports:
      - "8082:8080"
    environment:
      - DATABASE_URL=postgresql://noodle_user:noodle_password@postgres:5432/noodle_db
      - REDIS_URL=redis://redis:6379/0
      - ENVIRONMENT=production
      - DEBUG=0
      - LOG_LEVEL=INFO
    volumes:
      - ./ahr-runtime/logs:/app/logs
      - ./ahr-runtime/data:/app/data
      - ./ahr-runtime/models:/app/models
    depends_on:
      - postgres
      - redis
    networks:
      - noodle-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # TRM Agent Service
  trm-agent:
    build:
      context: ./trm-agent
      dockerfile: Dockerfile
    container_name: trm-agent
    ports:
      - "8083:8080"
    environment:
      - DATABASE_URL=postgresql://noodle_user:noodle_password@postgres:5432/noodle_db
      - REDIS_URL=redis://redis:6379/0
      - ENVIRONMENT=production
      - DEBUG=0
      - LOG_LEVEL=INFO
    volumes:
      - ./trm-agent/logs:/app/logs
      - ./trm-agent/data:/app/data
      - ./trm-agent/models:/app/models
    depends_on:
      - postgres
      - redis
    networks:
      - noodle-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Noodle IDE Service
  noodle-ide:
    build:
      context: ./noodle-ide
      dockerfile: Dockerfile
    container_name: noodle-ide
    ports:
      - "3000:3000"
    environment:
      - API_BASE_URL=http://noodle-core:8080
      - ENVIRONMENT=production
      - DEBUG=0
    volumes:
      - ./noodle-ide/logs:/app/logs
      - ./noodle-ide/data:/app/data
    depends_on:
      - noodle-core
    networks:
      - noodle-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # PostgreSQL Database
  postgres:
    image: postgres:14
    container_name: postgres
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_DB=noodle_db
      - POSTGRES_USER=noodle_user
      - POSTGRES_PASSWORD=noodle_password
      - PGDATA=/var/lib/postgresql/data/pgdata
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
    networks:
      - noodle-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U noodle_user -d noodle_db"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 40s

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
      - ./redis/redis.conf:/etc/redis/redis.conf
    networks:
      - noodle-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # RabbitMQ Message Queue
  rabbitmq:
    image: rabbitmq:3-management
    container_name: rabbitmq
    ports:
      - "5672:5672"
      - "15672:15672"
    environment:
      - RABBITMQ_DEFAULT_USER=guest
      - RABBITMQ_DEFAULT_PASS=guest
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq
    networks:
      - noodle-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "rabbitmq-diagnostics", "-q", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Nginx Load Balancer
  nginx:
    image: nginx:alpine
    container_name: nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/ssl:/etc/nginx/ssl
    depends_on:
      - noodle-core
      - noodle-net
      - ahr-runtime
      - trm-agent
      - noodle-ide
    networks:
      - noodle-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "nginx", "-t"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Prometheus Monitoring
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
    networks:
      - noodle-network
    restart: unless-stopped

  # Grafana Dashboard
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./monitoring/grafana/datasources:/etc/grafana/provisioning/datasources
    depends_on:
      - prometheus
    networks:
      - noodle-network
    restart: unless-stopped

  # ELK Stack for Logging
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.5.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    networks:
      - noodle-network
    restart: unless-stopped

  logstash:
    image: docker.elastic.co/logstash/logstash:8.5.0
    container_name: logstash
    volumes:
      - ./logging/logstash.conf:/usr/share/logstash/pipeline/logstash.conf
      - ./logs:/logs
    depends_on:
      - elasticsearch
    networks:
      - noodle-network
    restart: unless-stopped

  kibana:
    image: docker.elastic.co/kibana/kibana:8.5.0
    container_name: kibana
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch
    networks:
      - noodle-network
    restart: unless-stopped

# Volumes
volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local
  rabbitmq_data:
    driver: local
  prometheus_data:
    driver: local
  grafana_data:
    driver: local
  elasticsearch_data:
    driver: local

# Networks
networks:
  noodle-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

### Kubernetes Orchestration
#### Kubernetes Deployment Configuration
```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: noodle-prod
  labels:
    name: noodle-prod
    environment: production

---
# service-account.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: noodle-sa
  namespace: noodle-prod
  labels:
    app: noodle

---
# role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: noodle-role
  namespace: noodle-prod
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get", "list"]

---
# role-binding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: noodle-role-binding
  namespace: noodle-prod
subjects:
- kind: ServiceAccount
  name: noodle-sa
  namespace: noodle-prod
roleRef:
  kind: Role
  name: noodle-role
  apiGroup: rbac.authorization.k8s.io

---
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: noodle-config
  namespace: noodle-prod
data:
  config.yaml: |
    database:
      host: postgres-service
      port: 5432
      database: noodle_db
      username: noodle_user
      password: ${POSTGRES_PASSWORD}
    
    redis:
      host: redis-service
      port: 6379
      password: ${REDIS_PASSWORD}
    
    rabbitmq:
      host: rabbitmq-service
      port: 5672
      username: guest
      password: guest
    
    logging:
      level: INFO
      format: json
      file: /app/logs/noodle.log
    
    monitoring:
      enabled: true
      metrics_port: 8080
      health_port: 8081
    
    security:
      jwt_secret: ${JWT_SECRET}
      encryption_key: ${ENCRYPTION_KEY}
    
    performance:
      max_workers: 4
      timeout: 30
      memory_limit: 2048

---
# secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: noodle-secrets
  namespace: noodle-prod
type: Opaque
data:
  POSTGRES_PASSWORD: cG9zdGdyZXNxbDQ1Ng==
  REDIS_PASSWORD: cmVkaXM=
  JWT_SECRET: am90X2tleV9zZWNyZXQ=
  ENCRYPTION_KEY:ZW5jcnlwdGlvbl9rZXk=

---
# postgres-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: noodle-prod
  labels:
    app: postgres
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      serviceAccountName: noodle-sa
      containers:
      - name: postgres
        image: postgres:14
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_DB
          value: "noodle_db"
        - name: POSTGRES_USER
          value: "noodle_user"
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: noodle-secrets
              key: POSTGRES_PASSWORD
        - name: PGDATA
          value: "/var/lib/postgresql/data/pgdata"
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
        - name: init-script
          mountPath: /docker-entrypoint-initdb.d
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - noodle_user
            - -d
            - noodle_db
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - noodle_user
            - -d
            - noodle_db
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 5
          failureThreshold: 3
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: postgres-pvc
      - name: init-script
        configMap:
          name: postgres-init-script
      restartPolicy: Always

---
# postgres-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
  namespace: noodle-prod
  labels:
    app: postgres
spec:
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
    protocol: TCP
  type: ClusterIP

---
# redis-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  namespace: noodle-prod
  labels:
    app: redis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      serviceAccountName: noodle-sa
      containers:
      - name: redis
        image: redis:7-alpine
        ports:
        - containerPort: 6379
        volumeMounts:
        - name: redis-storage
          mountPath: /data
        - name: redis-config
          mountPath: /etc/redis/redis.conf
          subPath: redis.conf
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          exec:
            command:
            - redis-cli
            - ping
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          exec:
            command:
            - redis-cli
            - ping
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 5
          failureThreshold: 3
      volumes:
      - name: redis-storage
        persistentVolumeClaim:
          claimName: redis-pvc
      - name: redis-config
        configMap:
          name: redis-config
      restartPolicy: Always

---
# redis-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: redis-service
  namespace: noodle-prod
  labels:
    app: redis
spec:
  selector:
    app: redis
  ports:
  - port: 6379
    targetPort: 6379
    protocol: TCP
  type: ClusterIP

---
# noodle-core-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: noodle-core
  namespace: noodle-prod
  labels:
    app: noodle-core
spec:
  replicas: 3
  selector:
    matchLabels:
      app: noodle-core
  template:
    metadata:
      labels:
        app: noodle-core
    spec:
      serviceAccountName: noodle-sa
      containers:
      - name: noodle-core
        image: noodle/noodle-core:latest
        ports:
        - containerPort: 8080
        - containerPort: 8081
        env:
        - name: DATABASE_URL
          value: "postgresql://noodle_user:$(POSTGRES_PASSWORD)@postgres-service:5432/noodle_db"
        - name: REDIS_URL
          value: "redis://:$(REDIS_PASSWORD)@redis-service:6379/0"
        - name: RABBITMQ_URL
          value: "amqp://guest:guest@rabbitmq-service:5672/"
        - name: ENVIRONMENT
          value: "production"
        - name: DEBUG
          value: "0"
        - name: LOG_LEVEL
          value: "INFO"
        - name: CONFIG_PATH
          value: "/app/config/config.yaml"
        volumeMounts:
        - name: config-volume
          mountPath: /app/config
        - name: logs-volume
          mountPath: /app/logs
        - name: data-volume
          mountPath: /app/data
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8081
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /ready
            port: 8081
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 5
          failureThreshold: 3
      volumes:
      - name: config-volume
        configMap:
          name: noodle-config
      - name: logs-volume
        persistentVolumeClaim:
          claimName: noodle-logs-pvc
      - name: data-volume
        persistentVolumeClaim:
          claimName: noodle-data-pvc
      restartPolicy: Always

---
# noodle-core-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: noodle-core-service
  namespace: noodle-prod
  labels:
    app: noodle-core
spec:
  selector:
    app: noodle-core
  ports:
  - port: 8080
    targetPort: 8080
    protocol: TCP
  type: ClusterIP

---
# noodle-net-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: noodle-net
  namespace: noodle-prod
  labels:
    app: noodle-net
spec:
  replicas: 2
  selector:
    matchLabels:
      app: noodle-net
  template:
    metadata:
      labels:
        app: noodle-net
    spec:
      serviceAccountName: noodle-sa
      containers:
      - name: noodle-net
        image: noodle/noodle-net:latest
        ports:
        - containerPort: 8080
        env:
        - name: DATABASE_URL
          value: "postgresql://noodle_user:$(POSTGRES_PASSWORD)@postgres-service:5432/noodle_db"
        - name: REDIS_URL
          value: "redis://:$(REDIS_PASSWORD)@redis-service:6379/0"
        - name: ENVIRONMENT
          value: "production"
        - name: DEBUG
          value: "0"
        - name: LOG_LEVEL
          value: "INFO"
        volumeMounts:
        - name: config-volume
          mountPath: /app/config
        - name: logs-volume
          mountPath: /app/logs
        - name: data-volume
          mountPath: /app/data
        - name: models-volume
          mountPath: /app/models
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8081
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /ready
            port: 8081
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 5
          failureThreshold: 3
      volumes:
      - name: config-volume
        configMap:
          name: noodle-config
      - name: logs-volume
        persistentVolumeClaim:
          claimName: noodle-logs-pvc
      - name: data-volume
        persistentVolumeClaim:
          claimName: noodle-data-pvc
      - name: models-volume
        persistentVolumeClaim:
          claimName: noodle-models-pvc
      restartPolicy: Always

---
# noodle-net-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: noodle-net-service
  namespace: noodle-prod
  labels:
    app: noodle-net
spec:
  selector:
    app: noodle-net
  ports:
  - port: 8080
    targetPort: 8080
    protocol: TCP
  type: ClusterIP

---
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: noodle-ingress
  namespace: noodle-prod
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
spec:
  tls:
  - hosts:
    - api.noodle.com
    secretName: noodle-tls
  rules:
  - host: api.noodle.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: noodle-core-service
            port:
              number: 8080
      - path: /net/
        pathType: Prefix
        backend:
          service:
            name: noodle-net-service
            port:
              number: 8080

---
# horizontal-pod-autoscaler.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: noodle-core-hpa
  namespace: noodle-prod
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: noodle-core
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: 100
```

## Infrastructure as Code

### Terraform Configuration
```terraform
# main.tf
provider "aws" {
  region = "eu-west-1"
}

# VPC Configuration
resource "aws_vpc" "noodle_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "noodle-vpc"
  }
}

# Subnets
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.noodle_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "noodle-public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.noodle_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "noodle-private-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "noodle_igw" {
  vpc_id = aws_vpc.noodle_vpc.id
  tags = {
    Name = "noodle-igw"
  }
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.noodle_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.noodle_igw.id
  }
  tags = {
    Name = "noodle-public-rt"
  }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Groups
resource "aws_security_group" "noodle_sg" {
  name        = "noodle-sg"
  description = "Security group for Noodle services"
  vpc_id      = aws_vpc.noodle_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "noodle-sg"
  }
}

# EKS Cluster
resource "aws_eks_cluster" "noodle_cluster" {
  name     = "noodle-cluster"
  role_arn = aws_iam_role.noodle_cluster_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.noodle_cluster_AmazonEKSClusterPolicy,
  ]
}

# EKS Node Group
resource "aws_eks_node_group" "noodle_node_group" {
  cluster_name    = aws_eks_cluster.noodle_cluster.name
  node_group_name = "noodle-node-group"
  node_role_arn   = aws_iam_role.noodle_node_role.arn
  subnet_ids      = [aws_subnet.private_subnet.id]

  scaling_config {
    desired_size = 3
    max_size     = 10
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.noodle_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.noodle_node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.noodle_node_AmazonEC2ContainerRegistryReadOnly