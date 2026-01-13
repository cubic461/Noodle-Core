# Noodle Development Environment with Docker

This document describes how to set up and use the Docker-based development environment for Noodle.

## Overview

The Docker development environment provides:

- **Consistent Development Setup**: All services (Noodle, PostgreSQL, Redis, Nginx) running in isolated containers
- **Python 3.9+ Runtime**: Uses Python 3.11 as the base, ensuring compatibility with project requirements
- **Database Integration**: PostgreSQL with initialization scripts and sample data
- **Development Tools**: Pre-installed development tools and dependencies
- **Hot Reloading**: Volume mounts for live code changes without rebuilding containers

## Prerequisites

- Docker Desktop (Windows/Mac) or Docker Engine (Linux)
- Docker Compose
- Git (for cloning the repository)

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd noodle
```

### 2. Start the Development Environment

#### On Linux/macOS

```bash
chmod +x scripts/docker-dev.sh
./scripts/docker-dev.sh start
```

#### On Windows

```cmd
scripts\docker-dev.bat start
```

### 3. Verify the Setup

Once the containers are running, you can access:

- **Noodle API**: <http://localhost:8080>
- **Noodle IDE**: <http://localhost:8080/ide>
- **PostgreSQL**: localhost:5433
- **Redis**: localhost:6380

## Available Commands

### Linux/macOS (docker-dev.sh)

```bash
./scripts/docker-dev.sh help
```

### Windows (docker-dev.bat)

```cmd
scripts\docker-dev.bat help
```

#### Common Commands

- `build` - Build all Docker images
- `start` - Start the development environment
- `stop` - Stop the development environment
- `restart` - Restart the development environment
- `clean` - Clean up Docker resources
- `logs [service]` - Show logs for all or specific service
- `exec <service> <command>` - Execute command in a container

#### Services

- `noodle-dev` - Main Noodle application
- `postgres` - PostgreSQL database
- `redis` - Redis cache
- `nginx` - Nginx reverse proxy

## Development Workflow

### 1. Making Changes

- Edit code in your local IDE
- Changes are automatically reflected in the running containers due to volume mounts
- No need to rebuild containers for code changes

### 2. Database Operations

```bash
# Connect to PostgreSQL
./scripts/docker-dev.sh exec postgres psql -U noodleuser -d noodlecore_dev

# View database logs
./scripts/docker-dev.sh logs postgres
```

### 3. Running Tests

```bash
# Run all tests
./scripts/docker-dev.sh exec noodle-dev python -m pytest tests/

# Run specific test file
./scripts/docker-dev.sh exec noodle-dev python -m pytest tests/test_ai_agents.py -v
```

### 4. Viewing Logs

```bash
# View all logs
./scripts/docker-dev.sh logs

# View specific service logs
./scripts/docker-dev.sh logs noodle-dev
./scripts/docker-dev.sh logs postgres
```

## Environment Variables

The development environment uses the following environment variables:

- `NOODLE_ENV=development` - Sets the environment to development mode
- `NOODLE_PORT=8080` - Port for the Noodle application
- `NOODLE_LOG_LEVEL=DEBUG` - Enables debug logging
- `PYTHONPATH=/app/noodle-core/src:/app/noodle-lang/src` - Python path configuration

## Database Configuration

### PostgreSQL

- **Host**: localhost:5433
- **Database**: noodlecore_dev
- **Username**: noodleuser
- **Password**: noodlepass
- **Initialization**: Automatic table creation and sample data

### Redis

- **Host**: localhost:6380
- **No authentication** (development only)

## Troubleshooting

### Port Conflicts

If ports are already in use:

1. Stop the development environment: `./scripts/docker-dev.sh stop`
2. Change ports in `docker-compose.yml`
3. Restart: `./scripts/docker-dev.sh start`

### Container Issues

```bash
# Check container status
docker-compose ps

# View container logs
./scripts/docker-dev.sh logs [service-name]

# Restart specific service
docker-compose restart [service-name]
```

### Performance Issues

```bash
# Check resource usage
docker stats

# Clean up if needed
./scripts/docker-dev.sh clean
```

### Rebuilding Images

```bash
# Force rebuild without cache
./scripts/docker-dev.sh build

# Clean and rebuild
./scripts/docker-dev.sh clean
./scripts/docker-dev.sh build
./scripts/docker-dev.sh start
```

## Architecture

```
┌─────────────────┐
│   nginx        │  (Port 80)
│   (Reverse     │
│    Proxy)      │
└─────┬─────────┘
      │
      ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   noodle-dev    │    │   postgres      │    │   redis         │
│   (Port 8080) │    │   (Port 5433) │    │   (Port 6380) │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
       │                        │                 │
       └────────────────────────┴─────────────────┘
               Volume Mounts (Local Code)
```

## Production Deployment

For production deployment, use the production Docker Compose file:

```bash
docker-compose -f docker-compose.production.yml up -d
```

## Security Notes

- Development environment uses default passwords
- Database is accessible from localhost only
- No SSL/TLS in development
- All services run in a custom Docker network

## Contributing

When making changes to the Docker setup:

1. Update `Dockerfile` for base image changes
2. Update `docker-compose.yml` for service configuration
3. Update `scripts/docker-dev.sh` and `scripts/docker-dev.bat` for new commands
4. Test changes with `./scripts/docker-dev.sh clean && ./scripts/docker-dev.sh build`
5. Update this documentation

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Noodle Project Documentation](./docs/)
- [Development Guidelines](./NOODLE_IMPLEMENTATION_PLAN.md)
