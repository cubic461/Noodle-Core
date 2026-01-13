# NoodleCore Deployment Repository

A comprehensive deployment and distribution repository for NoodleCore, providing production-ready containerization, orchestration, and deployment solutions.

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Kubernetes (optional)
- Python 3.8+
- Node.js 16+
- Git

### Installation

#### Option 1: Docker Deployment
```bash
# Clone the repository
git clone https://github.com/cubic461/NoodleCore.git
cd noodlecore-deployment

# Build and run with Docker Compose
docker-compose up -d

# Or build multi-arch Docker images
./scripts/build/build-docker-multiarch.sh
```

#### Option 2: Kubernetes Deployment
```bash
# Deploy to Kubernetes
./scripts/deploy/deploy-k8s.sh

# Or with Helm (if available)
helm install noodlecore ./k8s/
```

#### Option 3: Local Installation
```bash
# Install NoodleCore locally
./scripts/install/install-noodlecore.sh

# Or with pip
pip install noodlecore
```

## 📁 Repository Structure

```
noodlecore-deployment/
├── .github/                 # GitHub Actions workflows
│   └── workflows/          # CI/CD pipelines
├── docker/                 # Docker configurations
│   ├── Dockerfile          # Development Docker image
│   ├── Dockerfile.production # Production Docker image
│   ├── docker-compose.yml   # Local development
│   └── docker-compose.production.yml # Production orchestration
├── k8s/                    # Kubernetes manifests
│   ├── deployment.yaml     # Main deployment
│   ├── service.yaml        # Kubernetes service
│   ├── ingress.yaml        # Ingress configuration
│   ├── redis-deployment.yaml # Redis deployment
│   ├── redis-service.yaml   # Redis service
│   ├── database.yaml       # Database configuration
│   ├── namespace.yaml      # Namespace setup
│   ├── logging.yaml        # Logging configuration
│   ├── monitoring.yaml     # Monitoring setup
│   └── pvc.yaml            # Persistent volume claim
├── scripts/                # Deployment scripts
│   ├── build/              # Build scripts
│   │   ├── build-docker-multiarch.sh
│   │   └── build-packages.sh
│   ├── deploy/             # Deployment scripts
│   │   ├── deploy-k8s.sh
│   │   ├── publish-to-dockerhub.sh
│   │   └── publish-to-pypi.sh
│   ├── install/            # Installation scripts
│   │   └── install-noodlecore.sh
│   ├── backup/             # Backup scripts
│   │   └── backup-disaster-recovery.sh
│   └── test/               # Testing scripts
│       └── test-deployment-environments.sh
├── ide/                    # Noodle IDE
│   ├── package.json        # IDE package configuration
│   ├── tsconfig.json       # TypeScript configuration
│   ├── vite.config.ts      # Vite build configuration
│   ├── tailwind.config.js  # Tailwind CSS configuration
│   ├── src/                # IDE source code
│   └── src-tauri/          # Tauri backend
│       ├── Cargo.toml      # Rust configuration
│       ├── tauri.conf.json # Tauri configuration
│       └── build.rs        # Build script
└── docs/                   # Documentation
    ├── DEPLOYMENT_GUIDE.md # Detailed deployment guide
    ├── TROUBLESHOOTING.md  # Troubleshooting guide
    ├── API_DOCUMENTATION.md # API documentation
    ├── API_EXAMPLES.md     # API usage examples
    ├── API_MIGRATION_GUIDE.md # API migration guide
    └── error_handling_documentation.md # Error handling guide
```

## 🏗️ Deployment Options

### Docker Deployment
- **Development**: `docker-compose up`
- **Production**: `docker-compose -f docker-compose.production.yml up -d`
- **Multi-arch**: `./scripts/build/build-docker-multiarch.sh`

### Kubernetes Deployment
- **Local Cluster**: `minikube start && ./scripts/deploy/deploy-k8s.sh`
- **Cloud Cluster**: `kubectl apply -f k8s/`
- **Helm**: `helm install noodlecore ./k8s/`

### Local Installation
- **Python Package**: `pip install noodlecore`
- **Binary**: Download from releases
- **Source**: `git clone https://github.com/your-org/noodlecore.git && cd noodlecore && pip install -e .`

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the root directory:

```env
# Core Configuration
NOODLECORE_ENV=production
NOODLECORE_PORT=8080
NOODLECORE_HOST=0.0.0.0

# Database Configuration
DATABASE_URL=postgresql://user:password@localhost:5432/noodlecore
REDIS_URL=redis://localhost:6379

# Security
SECRET_KEY=your-secret-key-here
JWT_SECRET=your-jwt-secret-here

# Monitoring
ENABLE_METRICS=true
LOG_LEVEL=info
```

### Docker Configuration
Edit `docker/docker-compose.yml` for local development or `docker/docker-compose.production.yml` for production.

### Kubernetes Configuration
Edit `k8s/deployment.yaml` for deployment-specific settings.

## 📦 Distribution

### Docker Hub
```bash
# Build and push to Docker Hub
./scripts/deploy/publish-to-dockerhub.sh
```

### PyPI
```bash
# Build and publish to PyPI
./scripts/deploy/publish-to-pypi.sh
```

### GitHub Releases
```bash
# Create release and build assets
./scripts/build/build-packages.sh
```

## 🧪 Testing

### Environment Testing
```bash
# Test deployment across different environments
./scripts/test/test-deployment-environments.sh
```

### Local Testing
```bash
# Run tests locally
python -m pytest tests/
npm test  # For IDE
```

## 🔒 Security

### Container Security
- Multi-stage builds for minimal attack surface
- Non-root user configuration
- Regular security updates
- Vulnerability scanning with Trivy

### Network Security
- TLS/SSL encryption
- Network policies for Kubernetes
- Firewall rules
- API rate limiting

### Data Security
- Encryption at rest
- Secure backup procedures
- Access controls
- Audit logging

## 📊 Monitoring & Logging

### Metrics
- Prometheus integration
- Grafana dashboards
- Application metrics
- System metrics

### Logging
- ELK stack (Elasticsearch, Logstash, Kibana)
- Structured logging
- Log aggregation
- Log retention policies

### Alerting
- Email notifications
- Slack integration
- PagerDuty integration
- Custom alert rules

## 🔄 Backup & Recovery

### Automated Backups
```bash
# Create backup
./scripts/backup/backup-disaster-recovery.sh
```

### Disaster Recovery
- Automated backup scheduling
- Point-in-time recovery
- Multi-region deployment
- Failover procedures

## 🛠️ Maintenance

### Updates
```bash
# Update dependencies
./scripts/build/dependency-updates.sh

# Update images
./scripts/build/build-docker-multiarch.sh
```

### Scaling
- Horizontal pod autoscaling
- Load balancing
- Resource optimization
- Performance tuning

## 📚 Documentation

- [Deployment Guide](docs/DEPLOYMENT_GUIDE.md)
- [API Documentation](docs/API_DOCUMENTATION.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Error Handling](docs/error_handling_documentation.md)
- [API Migration Guide](docs/API_MIGRATION_GUIDE.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- [Issues](https://github.com/your-org/noodlecore-deployment/issues)
- [Documentation](https://docs.noodlecore.dev)
- [Community Forum](https://community.noodlecore.dev)
- [Email Support](mailto:support@noodlecore.dev)

## 🔗 Related Projects

- [NoodleCore](https://github.com/your-org/noodlecore) - Core library
- [Noodle IDE](https://github.com/your-org/noodle-ide) - Development environment
- [NoodleNet](https://github.com/your-org/noodlenet) - Neural network components

---

**Note**: This repository contains deployment configurations and scripts. For the core NoodleCore library, see the main [NoodleCore repository](https://github.com/your-org/noodlecore).