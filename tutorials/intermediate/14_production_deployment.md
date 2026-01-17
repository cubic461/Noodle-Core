# Tutorial 14: Production Deployment

## 📚 Table of Contents
1. [Introduction](#introduction)
2. [Deployment Strategies](#deployment-strategies)
3. [Environment Setup](#environment-setup)
4. [Monitoring and Alerting](#monitoring-and-alerting)
5. [Security Best Practices](#security-best-practices)
6. [Disaster Recovery](#disaster-recovery)
7. [Maintenance](#maintenance)
8. [Performance Tuning](#performance-tuning)
9. [Checklist](#checklist)

---

## Introduction

**Production Deployment** covers everything you need to run Noodle reliably in a production environment. From deployment strategies to disaster recovery, learn how to deploy and operate Noodle at scale.

### Why Production Deployment Matters

Without proper production setup:
- ❌ Downtime during deployments
- ❌ No monitoring or alerting
- ❌ Security vulnerabilities
- ❌ Slow recovery from failures
- ❌ Poor performance under load

**With proper production deployment:**
- ✅ **Zero-downtime** deployments
- ✅ **Comprehensive** monitoring
- ✅ **Secure** by default
- ✅ **Fast** disaster recovery
- ✅ **Scalable** architecture

### Real-World Impact

```
❌ Without Production Setup:
Deployment: 30 minutes downtime
Incident: 4 hours to recover
Security: 2 data breaches/year
Performance: Frequent timeouts

✅ With Production Setup:
Deployment: 0 seconds downtime
Incident: 5 minutes to recover
Security: 0 data breaches
Performance: <100ms p99 latency
```

---

## Deployment Strategies

### 1. Blue-Green Deployment

Maintain two identical production environments:

```
┌─────────────────────────────────────────┐
│                                         │
│  [Blue]          [Green]                │
│  (Current)       (Next)                 │
│     │               │                   │
│     ▼               ▼                   │
│  Version 1.0     Version 1.1            │
│  (Live)         (Staging)               │
│                                         │
└─────────────────────────────────────────┘

Deployment Process:
1. Deploy to Green
2. Test Green thoroughly
3. Switch traffic: Blue → Green
4. Blue becomes idle (ready for next deploy)
```

**Configuration:**
```json
{
  "deployment": {
    "strategy": "blue-green",
    "environments": {
      "blue": {
        "url": "https://noodle-blue.example.com",
        "active": true
      },
      "green": {
        "url": "https://noodle-green.example.com",
        "active": false
      }
    }
  }
}
```

### 2. Canary Deployment

Gradually roll out to subset of users:

```
Traffic Distribution:
┌──────────────────────────────────────┐
│                                      │
│  100% Traffic                        │
│      │                               │
│      ├─ 90% → Stable (v1.0)          │
│      │                               │
│      └─ 10% → Canary (v1.1)          │
│              │                       │
│              ▼                       │
│         Monitor metrics              │
│              │                       │
│         ✓ Success?                  │
│              │                       │
│         Yes: Ramp up to 100%         │
│         No: Rollback to v1.0          │
│                                      │
└──────────────────────────────────────┘
```

**Configuration:**
```json
{
  "deployment": {
    "strategy": "canary",
    "steps": [
      {
        "percentage": 10,
        "duration": 300000,
        "metrics": {
          "error_rate": {
            "threshold": 0.01
          },
          "latency_p99": {
            "threshold": 500
          }
        }
      },
      {
        "percentage": 50,
        "duration": 600000
      },
      {
        "percentage": 100,
        "duration": 0
      }
    ]
  }
}
```

### 3. Rolling Deployment

Update instances gradually:

```
Instance Pool:
┌──────────────────────────────────────┐
│                                      │
│  [1] [2] [3] [4] [5] [6] [7] [8]    │
│   ↓   ↓   ↓   ↓   ↓   ↓   ↓   ↓    │
│  v1.0 v1.0 v1.0 v1.0 v1.0 v1.0 v1.0 v1.0
│                                      │
│  Update 2 instances at a time:       │
│                                      │
│  [1] [2] [3] [4] [5] [6] [7] [8]    │
│   ↓   ↓   ↓   ↓   ↓   ↓   ↓   ↓    │
│  v1.1 v1.1 v1.0 v1.0 v1.0 v1.0 v1.0 v1.0
│   ↑   ↑                              │
│  Updated (drain & restart)          │
│                                      │
└──────────────────────────────────────┘
```

**Configuration:**
```json
{
  "deployment": {
    "strategy": "rolling",
    "batchSize": 2,
    "batchInterval": 60000,
    "healthCheck": {
      "path": "/health",
      "timeout": 5000
    }
  }
}
```

---

## Environment Setup

### 1. Production Environment Variables

```bash
# .env.production
NOODLE_PROFILE=production
NOODLE_ENV=production

# LLM Configuration
LLM_PROVIDER=z_ai
LLM_API_KEY=${ZAI_API_KEY}
LLM_MODEL=glm-4.7
LLM_TEMPERATURE=0.3
LLM_MAX_TOKENS=4096

# Security
SECRET_KEY=${SECRET_KEY}
ENCRYPTION_KEY=${ENCRYPTION_KEY}

# Database
DATABASE_URL=${DATABASE_URL}

# Monitoring
SENTRY_DSN=${SENTRY_DSN}
DATADOG_API_KEY=${DATADOG_API_KEY}

# Alerts
SLACK_WEBHOOK=${SLACK_WEBHOOK}
PAGERDUTY_API_KEY=${PAGERDUTY_API_KEY}

# Performance
NODE_ENV=production
LOG_LEVEL=warn
```

### 2. Infrastructure as Code

**Terraform Example:**
```hcl
# main.tf
resource "aws_ecs_task_definition" "noodle" {
  family                   = "noodle"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = "4096"

  container_definitions = jsonencode([
    {
      name      = "noodle"
      image     = "${var.ecr_repository}:latest"
      cpu       = 2048
      memory    = 4096
      essential = true

      environment = [
        {
          name  = "NOODLE_PROFILE"
          value = "production"
        },
        {
          name  = "LLM_PROVIDER"
          value = "z_ai"
        }
      ]

      secrets = [
        {
          name      = "LLM_API_KEY"
          valueFrom = aws_secretsmanager_secret.llm_api_key.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.noodle.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "noodle"
        }
      }

      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])
}
```

### 3. Docker Configuration

**Dockerfile:**
```dockerfile
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy application
COPY . .

# Build application
RUN npm run build

# Production image
FROM node:20-alpine

WORKDIR /app

# Copy from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S noodle -u 1001

# Change ownership
RUN chown -R noodle:nodejs /app
USER noodle

# Health check
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

EXPOSE 3000

CMD ["node", "dist/index.js"]
```

**docker-compose.yml:**
```yaml
version: '3.8'

services:
  noodle:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NOODLE_PROFILE=production
      - LLM_PROVIDER=${LLM_PROVIDER}
      - LLM_API_KEY=${LLM_API_KEY}
    secrets:
      - llm_api_key
      - database_url
    volumes:
      - noodle_cache:/app/.noodle/cache
      - noodle_logs:/app/.noodle/logs
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 2G
    healthcheck:
      test: ["CMD", "wget", "--spider", "http://localhost:3000/health"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 60s

secrets:
  llm_api_key:
    external: true
  database_url:
    external: true

volumes:
  noodle_cache:
  noodle_logs:
```

---

## Monitoring and Alerting

### 1. Health Checks

Comprehensive health check endpoint:

```typescript
// health.ts
import express from 'express';

const router = express.Router();

router.get('/health', async (req, res) => {
  const checks = {
    uptime: process.uptime(),
    timestamp: Date.now(),
    status: 'healthy',
    checks: {}
  };

  // LLM connectivity
  try {
    await llmProvider.healthCheck();
    checks.checks.llm = { status: 'ok' };
  } catch (error) {
    checks.checks.llm = { status: 'error', message: error.message };
    checks.status = 'unhealthy';
  }

  // Database
  try {
    await db.query('SELECT 1');
    checks.checks.database = { status: 'ok' };
  } catch (error) {
    checks.checks.database = { status: 'error', message: error.message };
    checks.status = 'unhealthy';
  }

  // Disk space
  const diskUsage = await getDiskUsage();
  checks.checks.disk = {
    status: diskUsage.percent > 90 ? 'error' : 'ok',
    usage: diskUsage
  };

  // Memory
  const memUsage = process.memoryUsage();
  checks.checks.memory = {
    status: 'ok',
    heapUsed: `${Math.round(memUsage.heapUsed / 1024 / 1024)}MB`,
    heapTotal: `${Math.round(memUsage.heapTotal / 1024 / 1024)}MB`
  };

  const statusCode = checks.status === 'healthy' ? 200 : 503;
  res.status(statusCode).json(checks);
});

export default router;
```

### 2. Metrics Collection

Prometheus metrics:

```typescript
// metrics.ts
import promClient from 'prom-client';

// Create registry
const register = new promClient.Registry();

// HTTP request duration
const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.5, 1, 2, 5]
});

// LLM request duration
const llmRequestDuration = new promClient.Histogram({
  name: 'llm_request_duration_seconds',
  help: 'Duration of LLM requests in seconds',
  labelNames: ['provider', 'model', 'status'],
  buckets: [1, 5, 10, 30, 60]
});

// Pipeline runs
const pipelineRuns = new promClient.Counter({
  name: 'pipeline_runs_total',
  help: 'Total number of pipeline runs',
  labelNames: ['status']
});

// Active worktrees
const activeWorktrees = new promClient.Gauge({
  name: 'active_worktrees',
  help: 'Number of active worktrees'
});

// Cache hit rate
const cacheHits = new promClient.Counter({
  name: 'cache_hits_total',
  help: 'Total number of cache hits',
  labelNames: ['cache_type']
});

const cacheMisses = new promClient.Counter({
  name: 'cache_misses_total',
  help: 'Total number of cache misses',
  labelNames: ['cache_type']
});

register.registerMetric(httpRequestDuration);
register.registerMetric(llmRequestDuration);
register.registerMetric(pipelineRuns);
register.registerMetric(activeWorktrees);
register.registerMetric(cacheHits);
register.registerMetric(cacheMisses);

export {
  register,
  httpRequestDuration,
  llmRequestDuration,
  pipelineRuns,
  activeWorktrees,
  cacheHits,
  cacheMisses
};
```

### 3. Alert Rules

**Prometheus Alert Rules:**
```yaml
groups:
  - name: noodle_alerts
    interval: 30s
    rules:
      # High error rate
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} errors/sec"

      # Slow LLM responses
      - alert: SlowLLMResponses
        expr: histogram_quantile(0.99, rate(llm_request_duration_seconds_bucket[5m])) > 30
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Slow LLM responses"
          description: "P99 LLM response time is {{ $value }}s"

      # High memory usage
      - alert: HighMemoryUsage
        expr: process_resident_memory_bytes / 1024 / 1024 > 4096
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage"
          description: "Memory usage is {{ $value }}MB"

      # Disk space low
      - alert: DiskSpaceLow
        expr: (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) < 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Disk space low"
          description: "Only {{ $value | humanizePercentage }} disk space available"

      # Pipeline failure rate
      - alert: HighPipelineFailureRate
        expr: rate(pipeline_runs_total{status="failed"}[1h]) / rate(pipeline_runs_total[1h]) > 0.1
        for: 15m
        labels:
          severity: warning
        annotations:
          summary: "High pipeline failure rate"
          description: "Pipeline failure rate is {{ $value | humanizePercentage }}"
```

### 4. Dashboards

**Grafana Dashboard:**
```json
{
  "dashboard": {
    "title": "Noodle Production",
    "panels": [
      {
        "title": "Request Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])"
          }
        ]
      },
      {
        "title": "Error Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total{status=~\"5..\"}[5m])"
          }
        ]
      },
      {
        "title": "LLM Response Time (P99)",
        "targets": [
          {
            "expr": "histogram_quantile(0.99, rate(llm_request_duration_seconds_bucket[5m]))"
          }
        ]
      },
      {
        "title": "Pipeline Success Rate",
        "targets": [
          {
            "expr": "rate(pipeline_runs_total{status=\"success\"}[1h]) / rate(pipeline_runs_total[1h])"
          }
        ]
      }
    ]
  }
}
```

---

## Security Best Practices

### 1. Secret Management

Never commit secrets:

```bash
# .gitignore
.env
.env.local
.env.*.local
*.key
*.pem
secrets/
```

Use secret management:
```bash
# AWS Secrets Manager
aws secretsmanager create-secret \
  --name noodle/production \
  --secret-string '{"LLM_API_KEY":"sk-...","DATABASE_URL":"postgres://..."}'

# HashiCorp Vault
vault kv put secret/noodle/production \
  LLM_API_KEY=sk-... \
  DATABASE_URL=postgres://...
```

### 2. API Security

Rate limiting:
```typescript
// rateLimit.ts
import rateLimit from 'express-rate-limit';

export const apiRateLimit = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 100, // 100 requests per minute
  message: 'Too many requests from this IP',
  standardHeaders: true,
  legacyHeaders: false,
});

export const llmRateLimit = rateLimit({
  windowMs: 60 * 1000,
  max: 10, // 10 LLM requests per minute
  message: 'Too many LLM requests'
});
```

Authentication:
```typescript
// auth.ts
import jwt from 'jsonwebtoken';

export function authenticate(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }

  try {
    const decoded = jwt.verify(token, process.env.SECRET_KEY);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
}
```

### 3. Input Validation

Validate all inputs:
```typescript
// validation.ts
import { z } from 'zod';

const improveSchema = z.object({
  task: z.string().min(1).max(1000),
  context: z.string().max(10000).optional(),
  temperature: z.number().min(0).max(2).optional(),
  maxTokens: z.number().min(1).max(128000).optional()
});

export function validateImproveRequest(req, res, next) {
  try {
    improveSchema.parse(req.body);
    next();
  } catch (error) {
    return res.status(400).json({ error: error.errors });
  }
}
```

### 4. CORS Configuration

```typescript
// cors.ts
import cors from 'cors';

export const corsConfig = cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  maxAge: 86400 // 24 hours
});
```

---

## Disaster Recovery

### 1. Backup Strategy

Regular backups:
```bash
#!/bin/bash
# backup.sh

DATE=$(date +%Y%m%d_%H%M%S)

# Backup database
pg_dump $DATABASE_URL > "backups/db_$DATE.sql"

# Backup cache
tar -czf "backups/cache_$DATE.tar.gz" .noodle/cache

# Backup logs
tar -czf "backups/logs_$DATE.tar.gz" .noodle/logs

# Upload to S3
aws s3 cp "backups/db_$DATE.sql" "s3://backups/db_$DATE.sql"
aws s3 cp "backups/cache_$DATE.tar.gz" "s3://backups/cache_$DATE.tar.gz"
aws s3 cp "backups/logs_$DATE.tar.gz" "s3://backups/logs_$DATE.tar.gz"

# Cleanup old backups (keep last 30 days)
find backups/ -mtime +30 -delete
```

### 2. Recovery Procedure

```bash
#!/bin/bash
# restore.sh

BACKUP_DATE=$1

# Restore database
aws s3 cp "s3://backups/db_$BACKUP_DATE.sql" "backups/db_$BACKUP_DATE.sql"
psql $DATABASE_URL < "backups/db_$BACKUP_DATE.sql"

# Restore cache
aws s3 cp "s3://backups/cache_$BACKUP_DATE.tar.gz" "backups/cache_$BACKUP_DATE.tar.gz"
tar -xzf "backups/cache_$BACKUP_DATE.tar.gz" -C .noodle/

# Restart services
systemctl restart noodle
```

### 3. Incident Response

Incident response runbook:

```markdown
# Incident Response Runbook

## Severity Levels
- **P1**: Complete system outage
- **P2**: Major functionality degraded
- **P3**: Minor functionality degraded

## P1 Incident Procedure

1. **Declare Incident** (5 min)
   - Send alert to #incidents channel
   - Create incident Slack channel
   - Assign incident commander

2. **Assess Impact** (10 min)
   - Determine affected users
   - Estimate business impact
   - Update status page

3. **Mitigate** (30 min)
   - Implement temporary fix
   - Rollback if necessary
   - Communicate status

4. **Resolve** (1 hour)
   - Implement permanent fix
   - Verify resolution
   - Close incident

5. **Post-Mortem** (1 week)
   - Write post-mortem document
   - Identify action items
   - Implement improvements
```

---

## Maintenance

### 1. Regular Maintenance Tasks

```bash
#!/bin/bash
# maintenance.sh

# Clean up old worktrees
find .noodle/improve/worktrees -type d -mtime +7 -exec rm -rf {} \;

# Clean up old logs
find .noodle/logs -type f -mtime +30 -delete

# Clean up old cache entries
find .noodle/cache -type f -mtime +7 -delete

# Vacuum database
psql $DATABASE_URL -c "VACUUM ANALYZE;"

# Restart services
systemctl restart noodle
```

### 2. Dependency Updates

```bash
#!/bin/bash
# update-deps.sh

# Update dependencies
npm update

# Run tests
npm test

# If tests pass, commit
if [ $? -eq 0 ]; then
  git add package.json package-lock.json
  git commit -m "chore: update dependencies"
  git push
fi
```

---

## Performance Tuning

### 1. Node.js Optimization

```typescript
// cluster.ts
import cluster from 'cluster';
import os from 'os';

if (cluster.isPrimary) {
  const numCPUs = os.cpus().length;

  console.log(`Primary ${process.pid} is running`);

  // Fork workers
  for (let i = 0; i < numCPUs; i++) {
    cluster.fork();
  }

  cluster.on('exit', (worker, code, signal) => {
    console.log(`Worker ${worker.process.pid} died`);
    cluster.fork();
  });
} else {
  // Worker processes
  require('./index');
}
```

### 2. Connection Pooling

```typescript
// pool.ts
import { Pool } from 'pg';

export const dbPool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20, // Maximum pool size
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000
});
```

---

## Checklist

### Pre-Deployment Checklist

- [ ] All tests passing
- [ ] Code reviewed and approved
- [ ] Environment variables configured
- [ ] Secrets properly stored
- [ ] Database migrations run
- [ ] Backups verified
- [ ] Monitoring and alerting configured
- [ ] Documentation updated
- [ ] Rollback plan documented
- [ ] Team notified of deployment

### Post-Deployment Checklist

- [ ] Health checks passing
- [ ] Metrics normal
- [ ] No errors in logs
- [ ] Performance baseline met
- [ ] Alert rules tested
- [ ] Documentation updated
- [ ] Post-mortem if issues occurred

---

## Summary

✅ **Production Deployment provides:**
- Zero-downtime deployment strategies
- Comprehensive monitoring
- Security best practices
- Disaster recovery procedures
- Performance tuning guidelines
- Maintenance automation

🎯 **Best for:**
- Production environments
- High-availability systems
- Security-critical applications
- Teams following DevOps practices

📚 **Next Steps:**
- Advanced Tutorials
- CI/CD Integration
- Custom Extensions

---

## 🎉 Congratulations!

You've completed all 14 Intermediate Tutorials! You now have a comprehensive understanding of Noodle v3.0.0 and are ready to use it effectively in production.

**What you've learned:**
- ✅ Parallel Execution
- ✅ Performance Detection
- ✅ Multi-Candidate Comparison
- ✅ A/B Testing
- ✅ LLM Integration
- ✅ LSP Gate
- ✅ Automatic Rollback
- ✅ Analytics Dashboard
- ✅ Advanced Configuration
- ✅ Error Handling
- ✅ Optimization Strategies
- ✅ Production Deployment

**Next: Advanced Tutorials**
