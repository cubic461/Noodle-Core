# 🏭 Tutorial 14: Production Operations with NIP v3.0.0

## Introduction

Welcome to Tutorial 14! In this advanced guide, we'll explore production operations strategies for NIP applications. Running code in production requires careful planning, robust deployment strategies, and comprehensive incident management procedures.

**What you'll learn:**
- Production deployment strategies
- Blue-green and canary deployments
- Rollback procedures
- Incident management workflows
- On-call rotations and escalation
- Runbooks and playbooks
- SLA guarantees and monitoring
- Disaster recovery planning
- Post-incident reviews

**Prerequisites:**
- Completed Tutorials 1-13
- Understanding of Docker and container orchestration
- Basic knowledge of CI/CD pipelines
- Familiarity with monitoring tools

---

## Table of Contents

1. [Production Deployment Strategies](#1-production-deployment-strategies)
2. [Blue-Green Deployments](#2-blue-green-deployments)
3. [Canary Releases](#3-canary-releases)
4. [Rollback Procedures](#4-rollback-procedures)
5. [Incident Management](#5-incident-management)
6. [On-Call Rotations](#6-on-call-rotations)
7. [Runbooks and Playbooks](#7-runbooks-and-playbooks)
8. [SLA Guarantees and Compliance](#8-sla-guarantees-and-compliance)
9. [Disaster Recovery Planning](#9-disaster-recovery-planning)
10. [Post-Incident Reviews](#10-post-incident-reviews)
11. [Practical Exercises](#11-practical-exercises)
12. [Best Practices](#12-best-practices)

---

## 1. Production Deployment Strategies

### 1.1 Deployment Overview

Production deployment strategies determine how you release new versions of your application while minimizing risk and downtime.

### 1.2 Common Deployment Patterns

```yaml
# deployment-strategies/comparison.yaml
strategies:
  rolling_deployment:
    description: "Gradually replace instances with new version"
    advantages:
      - "Zero downtime"
      - "Quick rollback capability"
      - "Resource efficient"
    disadvantages:
      - "Mixed versions during deployment"
      - "Potential compatibility issues"
    use_case: "Small to medium deployments"
  
  blue_green:
    description: "Maintain two identical production environments"
    advantages:
      - "Instant rollback (switch traffic back)"
      - "Clean environment separation"
      - "Testing before cutover"
    disadvantages:
      - "Double resource requirements"
      - "Complex database migrations"
    use_case: "Critical applications requiring instant rollback"
  
  canary:
    description: "Roll out to small subset of users first"
    advantages:
      - "Gradual risk exposure"
      - "Real-world testing"
      - "Easy to stop issues"
    disadvantages:
      - "Complex traffic routing"
      - "Longer rollout timeline"
    use_case: "High-risk changes or major releases"
  
  shadow:
    description: "Deploy new version alongside old, but don't route to it"
    advantages:
      - "No production risk"
      - "Performance testing"
      - "Data validation"
    disadvantages:
      - "No user testing"
      - "Resource intensive"
    use_case: "Data pipeline validation"
```

### 1.3 Production Deployment Script

```python
# deploy/production_deployment.py
#!/usr/bin/env python3
"""
NIP Production Deployment Script
Supports multiple deployment strategies with automated health checks
"""

import os
import sys
import time
import click
import requests
from enum import Enum
from typing import List, Dict, Optional
from dataclasses import dataclass
import docker
import yaml

class DeploymentStrategy(Enum):
    ROLLING = "rolling"
    BLUE_GREEN = "blue_green"
    CANARY = "canary"
    SHADOW = "shadow"

@dataclass
class DeploymentConfig:
    """Configuration for deployment"""
    strategy: DeploymentStrategy
    image_tag: str
    namespace: str
    replicas: int
    health_check_url: str
    health_check_interval: int = 10
    health_check_timeout: int = 300
    canary_percentage: int = 10

class ProductionDeployer:
    """Handle production deployments"""
    
    def __init__(self, config: DeploymentConfig):
        self.config = config
        self.docker_client = docker.from_env()
    
    def pre_deployment_checks(self) -> bool:
        """Run pre-deployment validation checks"""
        print("🔍 Running pre-deployment checks...")
        
        checks = [
            self._check_image_exists,
            self._check_environment_config,
            self._check_database_connectivity,
            self._check_dependencies,
            self._check_resource_availability
        ]
        
        for check in checks:
            if not check():
                print(f"❌ Pre-deployment check failed: {check.__name__}")
                return False
            print(f"✅ {check.__name__} passed")
        
        return True
    
    def _check_image_exists(self) -> bool:
        """Verify Docker image exists"""
        try:
            self.docker_client.images.get(self.config.image_tag)
            return True
        except docker.errors.ImageNotFound:
            print(f"Image not found: {self.config.image_tag}")
            return False
    
    def _check_environment_config(self) -> bool:
        """Verify environment configuration"""
        required_vars = [
            'DATABASE_URL',
            'REDIS_URL',
            'SECRET_KEY',
            'ALLOWED_HOSTS'
        ]
        
        missing = [var for var in required_vars if not os.getenv(var)]
        if missing:
            print(f"Missing environment variables: {missing}")
            return False
        return True
    
    def _check_database_connectivity(self) -> bool:
        """Check database connectivity"""
        try:
            # Add your database connectivity check here
            return True
        except Exception as e:
            print(f"Database check failed: {e}")
            return False
    
    def _check_dependencies(self) -> bool:
        """Check external dependencies"""
        dependencies = [
            os.getenv('REDIS_URL'),
            os.getenv('DATABASE_URL')
        ]
        
        for dep in dependencies:
            if not self._check_service_health(dep):
                return False
        return True
    
    def _check_service_health(self, url: str) -> bool:
        """Check if a service is healthy"""
        try:
            response = requests.get(url, timeout=5)
            return response.status_code == 200
        except:
            return False
    
    def _check_resource_availability(self) -> bool:
        """Check system resources"""
        # Add resource checks (CPU, memory, disk)
        return True
    
    def deploy(self):
        """Execute deployment based on strategy"""
        print(f"🚀 Starting {self.config.strategy.value} deployment...")
        
        if not self.pre_deployment_checks():
            print("❌ Pre-deployment checks failed. Aborting.")
            sys.exit(1)
        
        if self.config.strategy == DeploymentStrategy.ROLLING:
            self._rolling_deployment()
        elif self.config.strategy == DeploymentStrategy.BLUE_GREEN:
            self._blue_green_deployment()
        elif self.config.strategy == DeploymentStrategy.CANARY:
            self._canary_deployment()
        elif self.config.strategy == DeploymentStrategy.SHADOW:
            self._shadow_deployment()
    
    def _rolling_deployment(self):
        """Execute rolling deployment"""
        print("🔄 Executing rolling deployment...")
        
        batch_size = max(1, self.config.replicas // 3)
        batches = (self.config.replicas + batch_size - 1) // batch_size
        
        for batch in range(batches):
            print(f"Deploying batch {batch + 1}/{batches}...")
            
            # Update pods in this batch
            self._update_pods(batch_size)
            
            # Wait for health checks
            if not self._wait_for_healthy_state():
                print("❌ Health check failed. Rolling back...")
                self._rollback()
                return
            
            print(f"✅ Batch {batch + 1} deployed successfully")
        
        print("✅ Rolling deployment completed successfully")
    
    def _blue_green_deployment(self):
        """Execute blue-green deployment"""
        print("🔵🟢 Executing blue-green deployment...")
        
        # Determine active environment
        active_env = self._get_active_environment()
        new_env = "green" if active_env == "blue" else "blue"
        
        print(f"Active environment: {active_env}")
        print(f"New environment: {new_env}")
        
        # Deploy to new environment
        print(f"Deploying to {new_env} environment...")
        self._deploy_to_environment(new_env)
        
        # Health checks on new environment
        print(f"Running health checks on {new_env}...")
        if not self._wait_for_healthy_state():
            print(f"❌ Health checks failed on {new_env}. Cleaning up...")
            self._cleanup_environment(new_env)
            return
        
        # Run smoke tests
        if not self._run_smoke_tests(new_env):
            print(f"❌ Smoke tests failed on {new_env}")
            self._cleanup_environment(new_env)
            return
        
        # Switch traffic
        print(f"Switching traffic to {new_env}...")
        self._switch_traffic(new_env)
        
        print(f"✅ Blue-green deployment completed. Traffic now on {new_env}")
        
        # Keep old environment for rollback window
        print(f"Keeping {active_env} available for rollback...")
    
    def _canary_deployment(self):
        """Execute canary deployment"""
        print("🐤 Executing canary deployment...")
        
        percentage = self.config.canary_percentage
        canary_replicas = max(1, (self.config.replicas * percentage) // 100)
        
        print(f"Deploying {percentage}% canary ({canary_replicas} replicas)...")
        
        # Deploy canary instances
        self._deploy_canary(canary_replicas)
        
        # Monitor canary
        print("Monitoring canary deployment...")
        if not self._monitor_canary(duration_minutes=30):
            print("❌ Canary monitoring detected issues. Rolling back...")
            self._rollback_canary()
            return
        
        # Gradual increase
        for pct in [25, 50, 75, 100]:
            print(f"Increasing canary to {pct}%...")
            self._update_canary_percentage(pct)
            
            if not self._monitor_canary(duration_minutes=15):
                print(f"❌ Issues detected at {pct}%. Rolling back...")
                self._rollback_canary()
                return
        
        # Promote canary to full release
        print("Promoting canary to full release...")
        self._promote_canary()
        
        print("✅ Canary deployment completed successfully")
    
    def _shadow_deployment(self):
        """Execute shadow deployment"""
        print("👤 Executing shadow deployment...")
        
        # Deploy shadow instances
        print("Deploying shadow instances...")
        self._deploy_shadow()
        
        # Run tests against shadow
        print("Running tests against shadow deployment...")
        if not self._run_shadow_tests():
            print("❌ Shadow tests failed")
            self._cleanup_shadow()
            return
        
        print("✅ Shadow deployment validated")
        self._cleanup_shadow()
    
    def _wait_for_healthy_state(self) -> bool:
        """Wait for deployment to become healthy"""
        start_time = time.time()
        timeout = self.config.health_check_timeout
        
        while time.time() - start_time < timeout:
            if self._check_deployment_health():
                return True
            time.sleep(self.config.health_check_interval)
        
        return False
    
    def _check_deployment_health(self) -> bool:
        """Check if deployment is healthy"""
        try:
            response = requests.get(self.config.health_check_url, timeout=5)
            if response.status_code == 200:
                data = response.json()
                return data.get('status') == 'healthy'
            return False
        except:
            return False
    
    def _rollback(self):
        """Rollback to previous version"""
        print("🔄 Executing rollback...")
        # Implement rollback logic
        print("✅ Rollback completed")
    
    def _get_active_environment(self) -> str:
        """Get currently active environment"""
        # Implement logic to determine active env
        return "blue"
    
    def _deploy_to_environment(self, env: str):
        """Deploy to specific environment"""
        # Implementation
        pass
    
    def _switch_traffic(self, env: str):
        """Switch traffic to environment"""
        # Implementation
        pass
    
    def _deploy_canary(self, replicas: int):
        """Deploy canary instances"""
        # Implementation
        pass
    
    def _update_canary_percentage(self, percentage: int):
        """Update canary traffic percentage"""
        # Implementation
        pass
    
    def _promote_canary(self):
        """Promote canary to full release"""
        # Implementation
        pass
    
    def _rollback_canary(self):
        """Rollback canary deployment"""
        # Implementation
        pass
    
    def _monitor_canary(self, duration_minutes: int) -> bool:
        """Monitor canary deployment for issues"""
        # Implement monitoring logic (error rates, latency, etc.)
        return True
    
    def _run_smoke_tests(self, env: str) -> bool:
        """Run smoke tests on environment"""
        # Implement smoke tests
        return True
    
    def _run_shadow_tests(self) -> bool:
        """Run tests against shadow deployment"""
        # Implementation
        return True
    
    def _cleanup_environment(self, env: str):
        """Cleanup environment"""
        # Implementation
        pass
    
    def _cleanup_shadow(self):
        """Cleanup shadow deployment"""
        # Implementation
        pass
    
    def _update_pods(self, count: int):
        """Update specified number of pods"""
        # Implementation
        pass
    
    def _deploy_shadow(self):
        """Deploy shadow instances"""
        # Implementation
        pass

# CLI interface
@click.command()
@click.option('--strategy', type=click.Choice(['rolling', 'blue_green', 'canary', 'shadow']),
              default='rolling', help='Deployment strategy')
@click.option('--image-tag', required=True, help='Docker image tag to deploy')
@click.option('--namespace', default='production', help='Kubernetes namespace')
@click.option('--replicas', default=3, help='Number of replicas')
@click.option('--health-check-url', required=True, help='Health check endpoint URL')
@click.option('--canary-percentage', default=10, help='Canary traffic percentage')
def main(strategy, image_tag, namespace, replicas, health_check_url, canary_percentage):
    """Deploy NIP application to production"""
    config = DeploymentConfig(
        strategy=DeploymentStrategy(strategy),
        image_tag=image_tag,
        namespace=namespace,
        replicas=replicas,
        health_check_url=health_check_url,
        canary_percentage=canary_percentage
    )
    
    deployer = ProductionDeployer(config)
    deployer.deploy()

if __name__ == '__main__':
    main()
```

---

## 2. Blue-Green Deployments

### 2.1 Architecture Overview

Blue-green deployments maintain two identical production environments:
- **Blue**: Current production version
- **Green**: New version being deployed

Traffic is switched between environments using a load balancer or service mesh.

### 2.2 Blue-Green Infrastructure Setup

```yaml
# kubernetes/blue-green-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nip-app
  namespace: production
spec:
  type: LoadBalancer
  selector:
    app: nip-app
    # Use labels to switch between blue and green
    version: blue  # Change to 'green' to switch traffic
  ports:
  - port: 80
    targetPort: 8000
    name: http
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nip-app-blue
  namespace: production
  labels:
    app: nip-app
    version: blue
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nip-app
      version: blue
  template:
    metadata:
      labels:
        app: nip-app
        version: blue
    spec:
      containers:
      - name: nip-app
        image: nip-app:1.0.0
        ports:
        - containerPort: 8000
        env:
        - name: ENVIRONMENT
          value: "production"
        - name: VERSION
          value: "blue"
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
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nip-app-green
  namespace: production
  labels:
    app: nip-app
    version: green
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nip-app
      version: green
  template:
    metadata:
      labels:
        app: nip-app
        version: green
    spec:
      containers:
      - name: nip-app
        image: nip-app:2.0.0
        ports:
        - containerPort: 8000
        env:
        - name: ENVIRONMENT
          value: "production"
        - name: VERSION
          value: "green"
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
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
```

### 2.3 Blue-Green Deployment Script

```bash
#!/bin/bash
# scripts/blue-green-deploy.sh

set -e

# Configuration
NAMESPACE="production"
APP_NAME="nip-app"
NEW_IMAGE_TAG=$1
HEALTH_CHECK_URL="${HEALTH_CHECK_URL:-http://nip-app.example.com/health}"
MAX_RETRIES=30
RETRY_INTERVAL=5

if [ -z "$NEW_IMAGE_TAG" ]; then
    echo "Usage: $0 <image-tag>"
    exit 1
fi

echo "🔵🟢 Starting Blue-Green Deployment"
echo "===================================="

# Determine current active environment
echo "🔍 Determining active environment..."
CURRENT_VERSION=$(kubectl get service $APP_NAME -n $NAMESPACE -o jsonpath='{.spec.selector.version}')

if [ "$CURRENT_VERSION" = "blue" ]; then
    CURRENT_ENV="blue"
    NEW_ENV="green"
else
    CURRENT_ENV="green"
    NEW_ENV="blue"
fi

echo "Current active: $CURRENT_ENV"
echo "New deployment: $NEW_ENV"
echo "New image tag: $NEW_IMAGE_TAG"

# Update the new environment
echo ""
echo "🚀 Deploying to $NEW_ENV environment..."

# Update image in new environment
kubectl set image deployment/$APP_NAME-$NEW_ENV \
    nip-app=nip-app:$NEW_IMAGE_TAG \
    -n $NAMESPACE

# Wait for rollout to complete
echo "⏳ Waiting for rollout to complete..."
kubectl rollout status deployment/$APP_NAME-$NEW_ENV -n $NAMESPACE --timeout=5m

# Get new pods
NEW_PODS=$(kubectl get pods -n $NAMESPACE -l app=$APP_NAME,version=$NEW_ENV -o jsonpath='{.items[*].metadata.name}')
echo "New pods: $NEW_PODS"

# Health checks
echo ""
echo "🏥 Running health checks..."
for i in $(seq 1 $MAX_RETRIES); do
    echo "Attempt $i/$MAX_RETRIES..."
    
    # Check pod status
    READY_PODS=$(kubectl get pods -n $NAMESPACE -l app=$APP_NAME,version=$NEW_ENV \
        -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}' | tr ' ' '\n' | grep -c "True" || echo "0")
    
    if [ "$READY_PODS" -ge "3" ]; then
        echo "✅ All pods are ready"
        
        # Check HTTP health endpoint
        if curl -f -s $HEALTH_CHECK_URL > /dev/null; then
            echo "✅ Health check passed"
            break
        else
            echo "❌ Health check failed"
        fi
    fi
    
    if [ $i -eq $MAX_RETRIES ]; then
        echo "❌ Health checks failed after $MAX_RETRIES attempts"
        echo "Rolling back deployment..."
        kubectl rollout undo deployment/$APP_NAME-$NEW_ENV -n $NAMESPACE
        exit 1
    fi
    
    sleep $RETRY_INTERVAL
done

# Run smoke tests
echo ""
echo "🧪 Running smoke tests..."
if ./scripts/smoke-tests.sh $NEW_ENV; then
    echo "✅ Smoke tests passed"
else
    echo "❌ Smoke tests failed"
    echo "Rolling back deployment..."
    kubectl rollout undo deployment/$APP_NAME-$NEW_ENV -n $NAMESPACE
    exit 1
fi

# Switch traffic
echo ""
echo "🔀 Switching traffic to $NEW_ENV..."
kubectl patch service $APP_NAME -n $NAMESPACE -p '{"spec":{"selector":{"version":"'"$NEW_ENV"'"}}}'

echo "✅ Traffic switched to $NEW_ENV"

# Verify new environment
echo ""
echo "🔍 Verifying new environment..."
sleep 10
if curl -f -s $HEALTH_CHECK_URL > /dev/null; then
    echo "✅ New environment is serving traffic successfully"
else
    echo "❌ Health check failed after traffic switch"
    echo "Rolling back traffic to $CURRENT_ENV..."
    kubectl patch service $APP_NAME -n $NAMESPACE -p '{"spec":{"selector":{"version":"'"$CURRENT_ENV"'"}}}'
    exit 1
fi

echo ""
echo "✅ Blue-Green Deployment completed successfully!"
echo "Traffic is now on: $NEW_ENV"
echo "Previous environment ($CURRENT_ENV) is available for rollback"

# Optional: Keep old environment for defined rollback window
echo ""
echo "ℹ️  Keeping $CURRENT_ENV available for 24 hours..."
echo "After that, it can be scaled down to save resources"
```

---

## 3. Canary Releases

### 3.1 Canary Strategy

Canary deployments roll out new versions to a small percentage of users first, then gradually increase based on metrics and health indicators.

### 3.2 Canary Infrastructure with Istio

```yaml
# istio/canary-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nip-app-v1
  namespace: production
spec:
  replicas: 10
  selector:
    matchLabels:
      app: nip-app
      version: v1
  template:
    metadata:
      labels:
        app: nip-app
        version: v1
    spec:
      containers:
      - name: nip-app
        image: nip-app:1.0.0
        ports:
        - containerPort: 8000
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nip-app-v2
  namespace: production
spec:
  replicas: 1
  selector:
    matchLabels:
        app: nip-app
      - version: v2
  template:
    metadata:
      labels:
        app: nip-app
        version: v2
    spec:
      containers:
      - name: nip-app
        image: nip-app:2.0.0
        ports:
        - containerPort: 8000
---
apiVersion: v1
kind: Service
metadata:
  name: nip-app
  namespace: production
spec:
  ports:
  - port: 80
    targetPort: 8000
    name: http
  selector:
    app: nip-app
---
# Istio VirtualService for traffic splitting
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: nip-app
  namespace: production
spec:
  hosts:
  - nip-app
  http:
  - match:
    - headers:
        x-canary:
          exact: "true"
    route:
    - destination:
        host: nip-app
        subset: v2
  - route:
    - destination:
        host: nip-app
        subset: v1
      weight: 90
    - destination:
        host: nip-app
        subset: v2
      weight: 10  # Start with 10% canary
---
# DestinationRule for subset definitions
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: nip-app
  namespace: production
spec:
  host: nip-app
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
```

### 3.3 Automated Canary Promotion

```python
# deploy/canary_promoter.py
#!/usr/bin/env python3
"""
Automated Canary Promotion Script
Monitors canary deployment and promotes based on health metrics
"""

import time
import click
import requests
from typing import Dict, List
import yaml
from datetime import datetime, timedelta

class CanaryPromoter:
    """Monitor and promote canary deployments"""
    
    def __init__(self, config_path: str):
        self.config = self._load_config(config_path)
        self.metrics_history = []
    
    def _load_config(self, path: str) -> Dict:
        """Load configuration from YAML file"""
        with open(path) as f:
            return yaml.safe_load(f)
    
    def monitor_and_promote(self):
        """Monitor canary and promote if healthy"""
        current_percentage = self.config['initial_canary_percentage']
        stages = self.config['promotion_stages']
        
        print(f"🐤 Starting canary monitoring at {current_percentage}%")
        
        for stage in stages:
            target_percentage = stage['percentage']
            duration_minutes = stage['duration_minutes']
            
            print(f"\n📊 Stage: {current_percentage}% → {target_percentage}%")
            print(f"⏱️  Monitoring for {duration_minutes} minutes...")
            
            # Update traffic split
            self._update_traffic_split(current_percentage, target_percentage)
            
            # Monitor for duration
            start_time = datetime.now()
            while (datetime.now() - start_time).seconds < duration_minutes * 60:
                if not self._check_canary_health():
                    self._handle_canary_failure(current_percentage)
                    return
                
                time.sleep(30)  # Check every 30 seconds
            
            # Verify stage success
            if not self._verify_stage_metrics(target_percentage):
                self._handle_canary_failure(current_percentage)
                return
            
            current_percentage = target_percentage
            print(f"✅ Stage completed successfully. Now at {current_percentage}%")
        
        # Full promotion
        print("\n🎉 Promoting to 100%")
        self._promote_to_full()
        print("✅ Canary deployment completed successfully!")
    
    def _check_canary_health(self) -> bool:
        """Check if canary is healthy"""
        checks = [
            self._check_error_rate,
            self._check_latency,
            self._check_success_rate,
            self._check_pod_health
        ]
        
        for check in checks:
            if not check():
                return False
        
        return True
    
    def _check_error_rate(self) -> bool:
        """Check if error rate is within threshold"""
        threshold = self.config['thresholds']['max_error_rate']
        # Query metrics from Prometheus/Grafana
        error_rate = self._get_error_rate()
        
        print(f"Error rate: {error_rate}% (threshold: {threshold}%)")
        
        if error_rate > threshold:
            print(f"❌ Error rate exceeds threshold: {error_rate}% > {threshold}%")
            return False
        
        return True
    
    def _check_latency(self) -> bool:
        """Check if latency is within threshold"""
        threshold = self.config['thresholds']['max_latency_p95']
        latency = self._get_latency_p95()
        
        print(f"P95 Latency: {latency}ms (threshold: {threshold}ms)")
        
        if latency > threshold:
            print(f"❌ Latency exceeds threshold: {latency}ms > {threshold}ms")
            return False
        
        return True
    
    def _check_success_rate(self) -> bool:
        """Check if success rate is within threshold"""
        threshold = self.config['thresholds']['min_success_rate']
        success_rate = self._get_success_rate()
        
        print(f"Success rate: {success_rate}% (threshold: {threshold}%)")
        
        if success_rate < threshold:
            print(f"❌ Success rate below threshold: {success_rate}% < {threshold}%")
            return False
        
        return True
    
    def _check_pod_health(self) -> bool:
        """Check if canary pods are healthy"""
        # Check pod status via Kubernetes API
        return True
    
    def _get_error_rate(self) -> float:
        """Get current error rate from metrics"""
        # Query Prometheus/Grafana
        # Placeholder: return actual error rate
        return 0.5
    
    def _get_latency_p95(self) -> int:
        """Get P95 latency from metrics"""
        # Query Prometheus/Grafana
        # Placeholder: return actual latency
        return 120
    
    def _get_success_rate(self) -> float:
        """Get current success rate from metrics"""
        # Query Prometheus/Grafana
        # Placeholder: return actual success rate
        return 99.5
    
    def _update_traffic_split(self, current_pct: int, target_pct: int):
        """Update traffic split between versions"""
        print(f"🔀 Updating traffic: v1 → {100 - target_pct}%, v2 → {target_pct}%")
        # Update Istio VirtualService via API or kubectl
        # Placeholder: actual implementation
    
    def _verify_stage_metrics(self, percentage: int) -> bool:
        """Verify metrics for the stage"""
        print(f"🔍 Verifying metrics at {percentage}% canary...")
        return True
    
    def _handle_canary_failure(self, rollback_percentage: int):
        """Handle canary failure and rollback"""
        print(f"\n❌ Canary failure detected!")
        print(f"🔄 Rolling back to {rollback_percentage}% canary...")
        self._update_traffic_split(rollback_percentage, rollback_percentage)
        print("✅ Rollback completed")
    
    def _promote_to_full(self):
        """Promote canary to 100%"""
        self._update_traffic_split(0, 100)
        # Optionally scale down old version
        # Update deployment labels

@click.command()
@click.option('--config', default='canary-config.yaml', help='Canary configuration file')
def main(config):
    """Monitor and promote canary deployment"""
    promoter = CanaryPromoter(config)
    promoter.monitor_and_promote()

if __name__ == '__main__':
    main()
```

---

## 4. Rollback Procedures

### 4.1 Rollback Strategy

Rollback procedures should be fast, automated, and well-tested.

### 4.2 Rollback Script

```bash
#!/bin/bash
# scripts/rollback.sh

set -e

NAMESPACE="production"
APP_NAME="nip-app"
ROLLBACK_VERSION=${1:-"previous"}

echo "🔄 Starting Rollback Procedure"
echo "================================"
echo "Rollback version: $ROLLBACK_VERSION"

# Pre-rollback checks
echo ""
echo "🔍 Pre-rollback checks..."

# Check if rollback version exists
echo "Verifying rollback version exists..."
if ! kubectl get deployment $APP_NAME-$ROLLBACK_VERSION -n $NAMESPACE > /dev/null 2>&1; then
    echo "❌ Rollback version $ROLLBACK_VERSION not found"
    exit 1
fi

# Check current deployment status
echo "Checking current deployment status..."
CURRENT_REPLICAS=$(kubectl get deployment $APP_NAME -n $NAMESPACE -o jsonpath='{.spec.replicas}')
READY_REPLICAS=$(kubectl get deployment $APP_NAME -n $NAMESPACE -o jsonpath='{.status.readyReplicas}')

echo "Current replicas: $CURRENT_REPLICAS"
echo "Ready replicas: $READY_REPLICAS"

# Create backup of current configuration
echo ""
echo "💾 Creating backup of current configuration..."
BACKUP_DIR="backups/rollback-$(date +%Y%m%d-%H%M%S)"
mkdir -p $BACKUP_DIR

kubectl get deployment $APP_NAME -n $NAMESPACE -o yaml > $BACKUP_DIR/deployment.yaml
kubectl get service $APP_NAME -n $NAMESPACE -o yaml > $BACKUP_DIR/service.yaml
kubectl get configmap $APP_NAME -n $NAMESPACE -o yaml > $BACKUP_DIR/configmap.yaml 2>/dev/null || true

echo "Backup saved to: $BACKUP_DIR"

# Get previous deployment info
echo ""
echo "🔍 Getting previous deployment info..."
PREVIOUS_IMAGE=$(kubectl get deployment $APP_NAME-$ROLLBACK_VERSION -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].image}')
echo "Previous image: $PREVIOUS_IMAGE"

# Execute rollback
echo ""
echo "🔄 Executing rollback..."

# Option 1: Update service selector (for blue-green)
if [ "$DEPLOYMENT_STRATEGY" = "blue-green" ]; then
    echo "Rolling back via blue-green switch..."
    kubectl patch service $APP_NAME -n $NAMESPACE -p '{"spec":{"selector":{"version":"'"$ROLLBACK_VERSION"'"}}}'
else
    # Option 2: Rollback deployment
    echo "Rolling back deployment..."
    kubectl rollout undo deployment/$APP_NAME -n $NAMESPACE
fi

# Wait for rollback to complete
echo "⏳ Waiting for rollback to complete..."
kubectl rollout status deployment/$APP_NAME -n $NAMESPACE --timeout=5m

# Verify rollback
echo ""
echo "🔍 Verifying rollback..."
sleep 10

CURRENT_IMAGE=$(kubectl get deployment $APP_NAME -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].image}')
echo "Current image after rollback: $CURRENT_IMAGE"

# Health check
if curl -f -s $HEALTH_CHECK_URL > /dev/null; then
    echo "✅ Rollback successful - application is healthy"
else
    echo "❌ Rollback failed - application is not healthy"
    echo "Restoring from backup..."
    kubectl apply -f $BACKUP_DIR/deployment.yaml
    exit 1
fi

# Rollback notification
echo ""
echo "📧 Sending rollback notification..."
# Send notification to Slack/PagerDuty/Email
# webhook-notification.sh "Rollback completed for $APP_NAME to version $ROLLBACK_VERSION"

echo ""
echo "✅ Rollback completed successfully!"
echo "Backup location: $BACKUP_DIR"
```

### 4.3 Database Migration Rollback

```python
# scripts/rollback_migrations.py
#!/usr/bin/env python3
"""
Database Migration Rollback Script
Safely roll back database migrations
"""

import sys
import logging
from typing import List
from datetime import datetime

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class MigrationRollback:
    """Handle database migration rollbacks"""
    
    def __init__(self, db_connection):
        self.db = db_connection
        self.backup_dir = "backups/migrations"
    
    def rollback_to_version(self, target_version: int):
        """Rollback migrations to target version"""
        logger.info(f"Starting rollback to version {target_version}")
        
        # Get current version
        current_version = self._get_current_version()
        logger.info(f"Current version: {current_version}")
        
        if current_version <= target_version:
            logger.error(f"Current version {current_version} is not newer than target {target_version}")
            return False
        
        # List migrations to rollback
        migrations = self._get_migrations_to_rollback(current_version, target_version)
        
        # Create backup
        self._create_backup()
        
        # Rollback each migration in reverse order
        for migration in reversed(migrations):
            logger.info(f"Rolling back migration: {migration['name']}")
            
            if not self._rollback_migration(migration):
                logger.error(f"Failed to rollback migration {migration['name']}")
                logger.info("Attempting to restore from backup...")
                self._restore_backup()
                return False
        
        logger.info(f"✅ Successfully rolled back to version {target_version}")
        return True
    
    def _get_current_version(self) -> int:
        """Get current database schema version"""
        # Query schema_migrations table
        return 15
    
    def _get_migrations_to_rollback(self, current: int, target: int) -> List[Dict]:
        """Get list of migrations to rollback"""
        # Query migrations table
        migrations = []
        for version in range(target + 1, current + 1):
            migrations.append({
                'version': version,
                'name': f'migration_{version:03d}',
                'down_script': f'migrations/down/{version:03d}_rollback.sql'
            })
        return migrations
    
    def _create_backup(self):
        """Create database backup before rollback"""
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        backup_file = f"{self.backup_dir}/backup_{timestamp}.sql"
        
        logger.info(f"Creating backup: {backup_file}")
        # Execute pg_dump or equivalent
        logger.info("✅ Backup created")
    
    def _rollback_migration(self, migration: Dict) -> bool:
        """Rollback a single migration"""
        logger.info(f"Executing rollback script: {migration['down_script']}")
        
        # Read and execute rollback script
        try:
            with open(migration['down_script'], 'r') as f:
                rollback_sql = f.read()
            
            # Execute SQL in transaction
            self.db.execute_transaction(rollback_sql)
            
            # Update schema version
            self.db.execute(
                "UPDATE schema_migrations SET version = ? WHERE version = ?",
                (migration['version'] - 1, migration['version'])
            )
            
            logger.info(f"✅ Rolled back migration {migration['name']}")
            return True
        except Exception as e:
            logger.error(f"Error rolling back migration: {e}")
            return False
    
    def _restore_backup(self):
        """Restore database from backup"""
        logger.info("Restoring from backup...")
        # Execute restore command
        logger.info("✅ Database restored")

# CLI
if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python rollback_migrations.py <target_version>")
        sys.exit(1)
    
    target_version = int(sys.argv[1])
    # Initialize database connection
    # rollback = MigrationRollback(db)
    # rollback.rollback_to_version(target_version)
```

---

## 5. Incident Management

### 5.1 Incident Lifecycle

1. **Detection**: Monitoring alerts trigger
2. **Response**: Team acknowledges and investigates
3. **Mitigation**: Temporary fix applied
4. **Resolution**: Root cause identified and fixed
5. **Post-Incident**: Review and improvements

### 5.2 Incident Response Script

```python
# incident/incident_manager.py
#!/usr/bin/env python3
"""
Incident Management System
Handle incident detection, escalation, and coordination
"""

import json
from datetime import datetime, timedelta
from typing import Dict, List, Optional
from enum import Enum
import requests

class SeverityLevel(Enum):
    P1 = "P1 - Critical"
    P2 = "P2 - High"
    P3 = "P3 - Medium"
    P4 = "P4 - Low"

class IncidentStatus(Enum):
    DETECTED = "detected"
    ACKNOWLEDGED = "acknowledged"
    INVESTIGATING = "investigating"
    MITIGATED = "mitigated"
    RESOLVED = "resolved"
    CLOSED = "closed"

class Incident:
    """Represents an incident"""
    
    def __init__(self, title: str, severity: SeverityLevel, description: str):
        self.id = self._generate_id()
        self.title = title
        self.severity = severity
        self.description = description
        self.status = IncidentStatus.DETECTED
        self.created_at = datetime.now()
        self.acknowledged_at: Optional[datetime] = None
        self.resolved_at: Optional[datetime] = None
        self.assigned_to: Optional[str] = None
        self.timeline: List[Dict] = []
        self.actions_taken: List[str] = []
        self.root_cause: Optional[str] = None
        self.resolution: Optional[str] = None
        
        self._add_to_timeline("Incident detected")
    
    def _generate_id(self) -> str:
        """Generate unique incident ID"""
        timestamp = datetime.now().strftime('%Y%m%d')
        # Generate sequential number
        return f"INC-{timestamp}-{id(self) % 1000:04d}"
    
    def acknowledge(self, responder: str):
        """Acknowledge incident"""
        self.status = IncidentStatus.ACKNOWLEDGED
        self.assigned_to = responder
        self.acknowledged_at = datetime.now()
        self._add_to_timeline(f"Incident acknowledged by {responder}")
    
    def update_status(self, status: IncidentStatus, note: str = ""):
        """Update incident status"""
        self.status = status
        self._add_to_timeline(f"Status changed to {status.value}. {note}")
    
    def add_action(self, action: str):
        """Add action taken"""
        self.actions_taken.append(action)
        self._add_to_timeline(f"Action: {action}")
    
    def resolve(self, root_cause: str, resolution: str):
        """Mark incident as resolved"""
        self.status = IncidentStatus.RESOLVED
        self.root_cause = root_cause
        self.resolution = resolution
        self.resolved_at = datetime.now()
        self._add_to_timeline(f"Incident resolved. Root cause: {root_cause}")
    
    def _add_to_timeline(self, event: str):
        """Add event to timeline"""
        self.timeline.append({
            'timestamp': datetime.now().isoformat(),
            'event': event
        })
    
    def to_dict(self) -> Dict:
        """Convert incident to dictionary"""
        return {
            'id': self.id,
            'title': self.title,
            'severity': self.severity.value,
            'status': self.status.value,
            'description': self.description,
            'created_at': self.created_at.isoformat(),
            'acknowledged_at': self.acknowledged_at.isoformat() if self.acknowledged_at else None,
            'resolved_at': self.resolved_at.isoformat() if self.resolved_at else None,
            'assigned_to': self.assigned_to,
            'timeline': self.timeline,
            'actions_taken': self.actions_taken,
            'root_cause': self.root_cause,
            'resolution': self.resolution,
            'duration_minutes': self._calculate_duration()
        }
    
    def _calculate_duration(self) -> float:
        """Calculate incident duration in minutes"""
        end_time = self.resolved_at or datetime.now()
        return (end_time - self.created_at).total_seconds() / 60

class IncidentManager:
    """Manage incidents and response coordination"""
    
    def __init__(self, config: Dict):
        self.config = config
        self.active_incidents: List[Incident] = []
        self.incident_history: List[Incident] = []
    
    def create_incident(self, title: str, severity: SeverityLevel, 
                       description: str) -> Incident:
        """Create new incident"""
        incident = Incident(title, severity, description)
        self.active_incidents.append(incident)
        
        # Send notifications
        self._notify_incident_created(incident)
        
        # Auto-escalate based on severity
        if severity in [SeverityLevel.P1, SeverityLevel.P2]:
            self._escalate_incident(incident)
        
        return incident
    
    def _notify_incident_created(self, incident: Incident):
        """Send notifications for new incident"""
        message = f"""
🚨 New Incident Created

ID: {incident.id}
Title: {incident.title}
Severity: {incident.severity.value}
Description: {incident.description}
Time: {incident.created_at}
"""
        # Send to Slack
        self._send_slack_alert(message)
        
        # Create PagerDuty incident for P1/P2
        if incident.severity in [SeverityLevel.P1, SeverityLevel.P2]:
            self._create_pagerduty_incident(incident)
    
    def _send_slack_alert(self, message: str):
        """Send alert to Slack"""
        webhook_url = self.config['slack_webhook']
        requests.post(webhook_url, json={'text': message})
    
    def _create_pagerduty_incident(self, incident: Incident):
        """Create PagerDuty incident"""
        api_key = self.config['pagerduty_api_key']
        # Create PD incident via API
        pass
    
    def _escalate_incident(self, incident: Incident):
        """Escalate incident based on severity"""
        escalation_rules = self.config.get('escalation_rules', {})
        
        for rule in escalation_rules.get(incident.severity.name, []):
            delay_minutes = rule.get('delay_minutes', 0)
            recipients = rule.get('recipients', [])
            
            # Schedule escalation
            self._schedule_escalation(incident, recipients, delay_minutes)
    
    def _schedule_escalation(self, incident: Incident, recipients: List[str], 
                            delay_minutes: int):
        """Schedule escalation notification"""
        # Implement delayed notification
        pass
    
    def update_incident(self, incident_id: str, status: Optional[IncidentStatus] = None,
                       note: str = ""):
        """Update incident status"""
        incident = self._get_incident(incident_id)
        if incident:
            if status:
                incident.update_status(status, note)
            
            # Send update notification
            self._notify_incident_update(incident)
    
    def _notify_incident_update(self, incident: Incident):
        """Send incident update notification"""
        message = f"""
📝 Incident Update

ID: {incident.id}
Status: {incident.status.value}
Last Event: {incident.timeline[-1]['event']}
"""
        self._send_slack_alert(message)
    
    def _get_incident(self, incident_id: str) -> Optional[Incident]:
        """Get incident by ID"""
        for incident in self.active_incidents:
            if incident.id == incident_id:
                return incident
        return None
    
    def close_incident(self, incident_id: str, postmortem_required: bool = True):
        """Close incident and move to history"""
        incident = self._get_incident(incident_id)
        if incident:
            incident.status = IncidentStatus.CLOSED
            incident._add_to_timeline("Incident closed")
            self.active_incidents.remove(incident)
            self.incident_history.append(incident)
            
            if postmortem_required:
                self._schedule_postmortem(incident)
    
    def _schedule_postmortem(self, incident: Incident):
        """Schedule post-incident review"""
        # Schedule postmortem meeting
        pass
    
    def generate_report(self, incident_id: str) -> str:
        """Generate incident report"""
        incident = self._get_incident(incident_id) or \
                  next((i for i in self.incident_history if i.id == incident_id), None)
        
        if not incident:
            return "Incident not found"
        
        report = f"""
# Incident Report: {incident.id}

## Summary
**Title**: {incident.title}
**Severity**: {incident.severity.value}
**Status**: {incident.status.value}
**Duration**: {incident._calculate_duration():.1f} minutes

## Description
{incident.description}

## Timeline
"""
        for event in incident.timeline:
            report += f"- {event['timestamp']}: {event['event']}\n"
        
        report += f"\n## Actions Taken\n"
        for action in incident.actions_taken:
            report += f"- {action}\n"
        
        if incident.root_cause:
            report += f"\n## Root Cause\n{incident.root_cause}\n"
        
        if incident.resolution:
            report += f"\n## Resolution\n{incident.resolution}\n"
        
        return report
```

---

## 6. On-Call Rotations

### 6.1 On-Call Schedule Configuration

```yaml
# oncall/schedule.yaml
schedule:
  name: "NIP Platform On-Call"
  timezone: "UTC"
  
  rotation:
    type: "weekly"
    handover_day: "Monday"
    handover_time: "09:00"
  
  primary_oncall:
    - user: "alice@example.com"
      start: "2025-01-06"
    - user: "bob@example.com"
      start: "2025-01-13"
    - user: "carol@example.com"
      start: "2025-01-20"
  
  secondary_oncall:
    - user: "dave@example.com"
      start: "2025-01-06"
    - user: "eve@example.com"
      start: "2025-01-13"
  
  escalation_policy:
    level_1:
      - "primary_oncall"
      wait_minutes: 15
    level_2:
      - "secondary_oncall"
      wait_minutes: 30
    level_3:
      - "engineering_manager@example.com"
      wait_minutes: 60
    level_4:
      - "cto@example.com"
      wait_minutes: 90

  coverage:
    holidays:
      - date: "2025-12-25"
        covered_by: "oncall-team@example.com"
      - date: "2026-01-01"
        covered_by: "oncall-team@example.com"
    
    overrides:
      - date: "2025-01-15"
        original: "alice@example.com"
        replacement: "bob@example.com"
        reason: "Alice out of office"

  notification_rules:
    high_severity:
      channels: ["pagerduty", "slack", "sms", "call"]
      timeout_minutes: 5
    
    medium_severity:
      channels: ["slack", "email"]
      timeout_minutes: 15
    
    low_severity:
      channels: ["slack"]
      timeout_minutes: 60
```

### 6.2 On-Call Handoff Script

```python
# oncall/handoff.py
#!/usr/bin/env python3
"""
On-Call Handoff Automation
Facilitate smooth transitions between on-call shifts
"""

from datetime import datetime, timedelta
from typing import Dict, List
import yaml

class OnCallHandoff:
    """Manage on-call handoff procedures"""
    
    def __init__(self, config_path: str):
        self.config = self._load_config(config_path)
    
    def _load_config(self, path: str) -> Dict:
        """Load on-call configuration"""
        with open(path) as f:
            return yaml.safe_load(f)
    
    def generate_handoff_report(self) -> str:
        """Generate handoff report for outgoing on-call"""
        report = f"""
# On-Call Handoff Report
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}

## Current Status
- Open Incidents: {self._count_open_incidents()}
- Systems Health: {self._get_systems_health()}

## Active Incidents
{self._list_active_incidents()}

## Recent Changes
{self._list_recent_changes()}

## Known Issues
{self._list_known_issues()}

## Upcoming Events
{self._list_upcoming_events()}

## Handover Notes
{self._get_handover_notes()}

## Resources
- Runbooks: https://docs.nip.io/runbooks
- Escalation: https://docs.nip.io/escalation
- Status Page: https://status.nip.io
"""
        return report
    
    def _count_open_incidents(self) -> int:
        """Count open incidents"""
        # Query incident management system
        return 0
    
    def _get_systems_health(self) -> str:
        """Get overall systems health status"""
        # Query monitoring system
        return "All systems operational"
    
    def _list_active_incidents(self) -> str:
        """List active incidents"""
        # Query active incidents
        return "No active incidents"
    
    def _list_recent_changes(self) -> str:
        """List recent deployments/changes"""
        # Query deployment history
        return "No recent changes"
    
    def _list_known_issues(self) -> str:
        """List known issues being tracked"""
        return "No known issues"
    
    def _list_upcoming_events(self) -> str:
        """List upcoming scheduled events"""
        return "No upcoming events"
    
    def _get_handover_notes(self) -> str:
        """Get handover notes from outgoing on-call"""
        return "No specific notes"
    
    def send_handoff(self, from_user: str, to_user: str):
        """Send handoff notification"""
        report = self.generate_handoff_report()
        
        message = f"""
@{to_user} - You are now the primary on-call engineer.

{report}

Please acknowledge this message to confirm handoff.

Good luck! 🤞
"""
        
        # Send to Slack
        print(f"Sending handoff to {to_user}...")
        # slack.send(message)
        
        # Log handoff
        self._log_handoff(from_user, to_user, report)
    
    def _log_handoff(self, from_user: str, to_user: str, report: str):
        """Log handoff for audit"""
        log_entry = {
            'timestamp': datetime.now().isoformat(),
            'from': from_user,
            'to': to_user,
            'report': report
        }
        # Save to log file or database
        print(f"Handoff logged: {from_user} → {to_user}")
```

---

## 7. Runbooks and Playbooks

### 7.1 Standard Runbook Template

```markdown
# Runbook: [Incident/Scenario Title]

## Metadata
- **Category**: [Database/API/Infrastructure/Application]
- **Severity**: [P1/P2/P3/P4]
- **Estimated Time to Resolve**: [X minutes]
- **Last Updated**: [Date]
- **Owner**: [Team/Person]

## Overview
[Brief description of the scenario and its impact]

## Detection
**Alerts**:
- [Alert name 1]
- [Alert name 2]

**Symptoms**:
- [Symptom 1]
- [Symptom 2]

## Diagnosis Steps

### Step 1: Verify Issue
```bash
# Command to verify issue
command_here
```
Expected output: [What you should see]
If failed: [What it means]

### Step 2: Check Service Health
```bash
# Check service status
systemctl status nip-service
```

### Step 3: Review Logs
```bash
# Check recent logs
journalctl -u nip-service -n 100 --since "10 minutes ago"
```

### Step 4: Check Metrics
```bash
# Query relevant metrics
curl http://prometheus:9090/api/v1/query?query=metric_name
```

## Resolution Steps

### Option 1: [First Resolution Approach]
**When to use**: [Conditions]
**Risk level**: [Low/Medium/High]
**Estimated time**: [X minutes]

```bash
# Commands to execute
```

### Option 2: [Alternative Approach]
**When to use**: [If Option 1 fails or specific conditions]
**Risk level**: [Low/Medium/High]

```bash
# Commands to execute
```

## Verification
```bash
# Verify fix is working
curl -f http://nip-app:8000/health
```

Expected: HTTP 200 with `{"status": "healthy"}`

## Escalation
If unresolved after [X] minutes:
1. Escalate to: [Role/Person]
2. Contact: [Slack/Phone/Email]
3. Escalation reason: [Why escalate]

## Prevention
**Long-term fixes**:
- [Fix 1]
- [Fix 2]

**Related runbooks**:
- [Link to related runbook]
- [Link to related runbook]

## Examples
### Example 1: [Specific scenario]
**Time occurred**: [Date]
**Root cause**: [What happened]
**Resolution**: [What fixed it]
**Prevention implemented**: [What changed]

## Notes
[Additional notes, tips, or edge cases]
```

### 7.2 Specific Runbook Examples

```markdown
# Runbook: Database Connection Pool Exhaustion

## Metadata
- **Category**: Database
- **Severity**: P1 - Critical
- **Estimated Time to Resolve**: 15 minutes
- **Last Updated**: 2025-01-15
- **Owner**: Platform Team

## Overview
Database connection pool is exhausted, preventing new connections. Application cannot process requests.

## Detection
**Alerts**:
- `database_connection_pool_usage > 90%`
- `application_error_rate > 5%`

**Symptoms**:
- Application returns HTTP 500/503 errors
- Database connections timing out
- Slow response times

## Diagnosis Steps

### Step 1: Verify Connection Pool Status
```bash
# Check connection pool metrics
curl -s http://prometheus:9090/api/v1/query?query=pg_stat_activity_count
```

Expected: Connection count should be < 90% of max connections

### Step 2: Check Active Connections
```python
# From Python admin shell
from nip.db import engine
print(f"Pool size: {engine.pool.size()}")
print(f"Checked out: {engine.pool.checkedout()}")
```

### Step 3: Review Slow Queries
```bash
# Check for long-running queries
psql -h $DB_HOST -U postgres -d nip -c "
SELECT pid, now() - query_start as duration, query 
FROM pg_stat_activity 
WHERE state = 'active' 
ORDER BY duration DESC 
LIMIT 10;"
```

## Resolution Steps

### Option 1: Kill Long-Running Queries
**When to use**: Connection pool exhausted due to stuck queries
**Risk level**: Medium - May interrupt in-progress transactions

```bash
# Kill queries running longer than 5 minutes
psql -h $DB_HOST -U postgres -d nip -c "
SELECT pg_terminate_backend(pid) 
FROM pg_stat_activity 
WHERE state = 'active' 
AND now() - query_start > interval '5 minutes';"
```

### Option 2: Increase Pool Size
**When to use**: Pool size is too small for load
**Risk level**: Low - Temporary fix

```bash
# Update environment variable
kubectl set env deployment/nip-app DB_POOL_SIZE=50 -n production
kubectl rollout restart deployment/nip-app -n production
```

### Option 3: Scale Application
**When to use**: Need more application instances to handle load
**Risk level**: Low

```bash
# Scale up application
kubectl scale deployment/nip-app --replicas=10 -n production
```

## Verification
```bash
# Check connection pool usage
curl -s http://prometheus:9090/api/v1/query?query=db_pool_usage_percent

# Verify application health
curl -f http://nip-app/health
```

Expected: Connection pool < 80%, HTTP 200 response

## Escalation
If unresolved after 15 minutes:
1. Escalate to: Database Team Lead
2. Contact: #database-escalation Slack
3. Create incident: `incident create "DB Connection Pool"`

## Prevention
**Long-term fixes**:
- Implement query timeouts
- Add connection pool monitoring
- Optimize slow queries
- Implement query rate limiting

**Related runbooks**:
- [Database High CPU](./runbooks/database-high-cpu.md)
- [Application Scaling](./runbooks/application-scaling.md)

## Notes
- Connection pool size should be based on DB connection limits
- Formula: `pool_size = (max_connections - reserved) / num_app_instances`
- Reserve 10 connections for administrative tasks
```

### 7.3 Automated Runbook Execution

```python
# runbooks/executor.py
#!/usr/bin/env python3
"""
Runbook Executor
Automatically execute runbook steps for common incidents
"""

import subprocess
import logging
from typing import Dict, List
from dataclasses import dataclass

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@dataclass
class RunbookStep:
    """Represents a single runbook step"""
    name: str
    command: str
    expected_result: str
    verification_command: str = None

class RunbookExecutor:
    """Execute runbook steps automatically"""
    
    def __init__(self):
        self.execution_log: List[Dict] = []
    
    def execute_runbook(self, runbook_name: str, steps: List[RunbookStep]) -> bool:
        """Execute all steps in a runbook"""
        logger.info(f"📘 Executing runbook: {runbook_name}")
        
        for step in steps:
            logger.info(f"\n📋 Step: {step.name}")
            
            if not self._execute_step(step):
                logger.error(f"❌ Step failed: {step.name}")
                self._log_execution(step.name, False)
                return False
            
            logger.info(f"✅ Step completed: {step.name}")
            self._log_execution(step.name, True)
        
        logger.info(f"\n✅ Runbook {runbook_name} completed successfully")
        return True
    
    def _execute_step(self, step: RunbookStep) -> bool:
        """Execute a single runbook step"""
        try:
            # Execute command
            result = subprocess.run(
                step.command,
                shell=True,
                capture_output=True,
                text=True,
                timeout=60
            )
            
            if result.returncode != 0:
                logger.error(f"Command failed: {result.stderr}")
                return False
            
            # Verify result
            if step.expected_result and step.expected_result not in result.stdout:
                logger.error(f"Unexpected output: {result.stdout}")
                return False
            
            # Run verification command if provided
            if step.verification_command:
                verify_result = subprocess.run(
                    step.verification_command,
                    shell=True,
                    capture_output=True,
                    text=True,
                    timeout=30
                )
                
                if verify_result.returncode != 0:
                    logger.error(f"Verification failed: {verify_result.stderr}")
                    return False
            
            return True
        except subprocess.TimeoutExpired:
            logger.error("Command timed out")
            return False
        except Exception as e:
            logger.error(f"Error executing step: {e}")
            return False
    
    def _log_execution(self, step_name: str, success: bool):
        """Log execution result"""
        self.execution_log.append({
            'step': step_name,
            'success': success,
            'timestamp': datetime.now().isoformat()
        })

# Predefined runbooks
RUNBOOKS = {
    'database_connection_pool': [
        RunbookStep(
            name="Check connection pool status",
            command="curl -s http://prometheus:9090/api/v1/query?query=db_pool_usage",
            expected_result="\"status\":\"success\"",
            verification_command="curl -f http://nip-app/health"
        ),
        RunbookStep(
            name="Kill long-running queries",
            command="psql -h $DB_HOST -U postgres -c \"SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE now() - query_start > interval '5 minutes';\"",
            expected_result="pg_terminate_backend"
        ),
        RunbookStep(
            name="Scale application",
            command="kubectl scale deployment/nip-app --replicas=10 -n production",
            expected_result="scaled"
        ),
    ],
    
    'high_memory_usage': [
        RunbookStep(
            name="Check memory usage",
            command="kubectl top pods -n production -l app=nip-app",
            expected_result="MEMORY"
        ),
        RunbookStep(
            name="Restart affected pods",
            command="kubectl rollout restart deployment/nip-app -n production",
            expected_result="deployment.apps/nip-app restarted"
        ),
    ]
}
```

---

## 8. SLA Guarantees and Compliance

### 8.1 SLA Definition

```yaml
# sla/sla_definition.yaml
service_level_agreements:
  uptime:
    monthly_target: 99.95
    quarterly_target: 99.9
    annual_target: 99.9
    calculation_window: "calendar_month"
    excluded_maintenance:
      - "Scheduled maintenance windows"
      - "Force majeure events"
  
  performance:
    response_time_p50: 200  # milliseconds
    response_time_p95: 500
    response_time_p99: 1000
    
  error_rate:
    target: 0.01  # percentage
    threshold: 0.05  # percentage for alerting
  
  availability:
    api_endpoints:
      critical: 99.99
      normal: 99.95
    
    database:
      primary: 99.95
      replica: 99.9

compliance:
  data_retention:
    logs: "90 days"
    metrics: "13 months"
    incidents: "7 years"
  
  audit_requirements:
    - "All changes must be reviewed"
    - "Incidents must be documented"
    - "Access logs must be retained"
  
  regulatory:
    - "GDPR compliant"
    - "SOC 2 Type II compliant"
    - "ISO 27001 compliant"

monitoring:
  sla_breach_threshold: 99.0
  notification_channels:
    - slack
    - email
    - pagerduty
  
  reporting:
    daily: true
    weekly_summary: true
    monthly_report: true
    quarterly_review: true
```

### 8.2 SLA Monitoring Script

```python
# monitoring/sla_monitor.py
#!/usr/bin/env python3
"""
SLA Monitoring and Reporting
Track and report on Service Level Agreement compliance
"""

from datetime import datetime, timedelta
from typing import Dict, List, Optional
import pandas as pd
import requests

class SLAMonitor:
    """Monitor and report SLA compliance"""
    
    def __init__(self, prometheus_url: str, sla_config: Dict):
        self.prometheus_url = prometheus_url
        self.sla_config = sla_config
    
    def calculate_uptime(self, start_time: datetime, 
                        end_time: datetime) -> Dict[str, float]:
        """Calculate uptime for specified period"""
        query = f"""
        sum(rate(up{{job="nip-app"}}[{self._get_range(start_time, end_time)}]))
        """
        
        result = self._query_prometheus(query)
        
        total_minutes = (end_time - start_time).total_seconds() / 60
        uptime_minutes = result * total_minutes
        uptime_percentage = (uptime_minutes / total_minutes) * 100
        
        return {
            'uptime_percentage': uptime_percentage,
            'downtime_minutes': total_minutes - uptime_minutes,
            'total_minutes': total_minutes,
            'target': self.sla_config['uptime']['monthly_target'],
            'compliant': uptime_percentage >= self.sla_config['uptime']['monthly_target']
        }
    
    def calculate_performance_sla(self, start_time: datetime,
                                  end_time: datetime) -> Dict[str, float]:
        """Calculate performance metrics against SLA"""
        p50_query = f"""
        histogram_quantile(0.5, 
            sum(rate(http_request_duration_seconds_bucket{{job="nip-app"}}[{self._get_range(start_time, end_time)}])) by (le)
        ) * 1000
        """
        
        p95_query = f"""
        histogram_quantile(0.95, 
            sum(rate(http_request_duration_seconds_bucket{{job="nip-app"}}[{self._get_range(start_time, end_time)}])) by (le)
        ) * 1000
        """
        
        p50 = self._query_prometheus(p50_query)
        p95 = self._query_prometheus(p95_query)
        
        sla = self.sla_config['performance']
        
        return {
            'p50_ms': p50,
            'p95_ms': p95,
            'p50_target': sla['response_time_p50'],
            'p95_target': sla['response_time_p95'],
            'p50_compliant': p50 <= sla['response_time_p50'],
            'p95_compliant': p95 <= sla['response_time_p95']
        }
    
    def calculate_error_rate_sla(self, start_time: datetime,
                                end_time: datetime) -> Dict[str, float]:
        """Calculate error rate against SLA"""
        query = f"""
        sum(rate(http_requests_total{{job="nip-app",status=~"5.."}}[{self._get_range(start_time, end_time)}])) 
        / 
        sum(rate(http_requests_total{{job="nip-app"}}[{self._get_range(start_time, end_time)}])) 
        * 100
        """
        
        error_rate = self._query_prometheus(query)
        target = self.sla_config['error_rate']['target']
        
        return {
            'error_rate_percentage': error_rate,
            'target_percentage': target,
            'compliant': error_rate <= target
        }
    
    def generate_sla_report(self, period: str = "monthly") -> str:
        """Generate comprehensive SLA report"""
        start_time, end_time = self._get_period_dates(period)
        
        uptime = self.calculate_uptime(start_time, end_time)
        performance = self.calculate_performance_sla(start_time, end_time)
        error_rate = self.calculate_error_rate_sla(start_time, end_time)
        
        report = f"""
# SLA Compliance Report - {period.title()}

## Period
{start_time.strftime('%Y-%m-%d')} to {end_time.strftime('%Y-%m-%d')}

## Uptime
- **Actual**: {uptime['uptime_percentage']:.4f}%
- **Target**: {uptime['target']}%
- **Status**: {'✅ COMPLIANT' if uptime['compliant'] else '❌ NON-COMPLIANT'}
- **Downtime**: {uptime['downtime_minutes']:.2f} minutes

## Performance
### Response Time (P50)
- **Actual**: {performance['p50_ms']:.2f}ms
- **Target**: {performance['p50_target']}ms
- **Status**: {'✅ COMPLIANT' if performance['p50_compliant'] else '❌ NON-COMPLIANT'}

### Response Time (P95)
- **Actual**: {performance['p95_ms']:.2f}ms
- **Target**: {performance['p95_target']}ms
- **Status**: {'✅ COMPLIANT' if performance['p95_compliant'] else '❌ NON-COMPLIANT'}

## Error Rate
- **Actual**: {error_rate['error_rate_percentage']:.4f}%
- **Target**: {error_rate['target_percentage']}%
- **Status**: {'✅ COMPLIANT' if error_rate['compliant'] else '❌ NON-COMPLIANT'}

## Summary
{'✅ All SLAs met' if all([uptime['compliant'], performance['p50_compliant'], 
                            performance['p95_compliant'], error_rate['compliant']]) 
    else '❌ One or more SLAs not met'}

## Incidents Affecting SLA
{self._list_sla_impacting_incidents(start_time, end_time)}

## Recommendations
{self._generate_recommendations(uptime, performance, error_rate)}

---
*Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}*
"""
        return report
    
    def _query_prometheus(self, query: str) -> float:
        """Query Prometheus for metrics"""
        response = requests.get(
            f"{self.prometheus_url}/api/v1/query",
            params={'query': query}
        )
        response.raise_for_status()
        
        data = response.json()
        if data['data']['result']:
            return float(data['data']['result'][0]['value'][1])
        return 0.0
    
    def _get_range(self, start: datetime, end: datetime) -> str:
        """Get time range for Prometheus query"""
        duration = (end - start).total_seconds()
        hours = int(duration // 3600)
        return f"{hours}h"
    
    def _get_period_dates(self, period: str) -> tuple:
        """Get start and end dates for period"""
        now = datetime.now()
        
        if period == "daily":
            start = now - timedelta(days=1)
        elif period == "weekly":
            start = now - timedelta(weeks=1)
        elif period == "monthly":
            start = now.replace(day=1)
        elif period == "quarterly":
            quarter = (now.month - 1) // 3
            start = now.replace(month=quarter*3+1, day=1)
        else:
            start = now - timedelta(days=30)
        
        return start, now
    
    def _list_sla_impacting_incidents(self, start: datetime, 
                                     end: datetime) -> str:
        """List incidents that impacted SLA"""
        # Query incident management system
        return "No SLA-impacting incidents recorded"
    
    def _generate_recommendations(self, uptime: Dict, 
                                 performance: Dict,
                                 error_rate: Dict) -> str:
        """Generate recommendations based on SLA results"""
        recommendations = []
        
        if not uptime['compliant']:
            recommendations.append("- Improve uptime through better failover mechanisms")
        
        if not performance['p95_compliant']:
            recommendations.append("- Optimize slow queries causing high P95 latency")
        
        if not error_rate['compliant']:
            recommendations.append("- Investigate and fix error rate issues")
        
        if not recommendations:
            return "No recommendations - all SLAs are being met"
        
        return "\n".join(recommendations)
```

---

## 9. Disaster Recovery Planning

### 9.1 Disaster Recovery Strategy

```yaml
# disaster_recovery/strategy.yaml
disaster_recovery:
  RTO: "4 hours"  # Recovery Time Objective
  RPO: "15 minutes"  # Recovery Point Objective
  
  backup_strategy:
    database:
      type: "continuous"
      retention:
        daily: 30
        weekly: 12
        monthly: 24
      backup_location: "multi_region_s3"
      encryption: true
      cross_region_replication: true
    
    application_data:
      type: "incremental"
      frequency: "hourly"
      retention: 90
      backup_location: "s3"
    
    configuration:
      type: "version_control"
      repository: "git"
      frequency: "on_change"
  
  recovery_procedures:
    region_failure:
      procedure: "failover_to_backup_region"
      steps:
        - "Verify primary region failure"
        - "Route DNS to backup region"
        - "Scale backup region resources"
        - "Verify application health"
        - "Monitor for 24 hours"
    
    database_failure:
      procedure: "promote_read_replica"
      steps:
        - "Promote read replica to primary"
        - "Update application connection strings"
        - "Create new read replicas"
        - "Verify data integrity"
    
    site_wide_failure:
      procedure: "activate_disaster_recovery_site"
      steps:
        - "Activate DR site"
        - "Restore from backups"
        - "Validate data integrity"
        - "Route traffic"
        - "Rebuild primary site"

  testing:
    frequency: "quarterly"
    scope:
      - "Database failover"
      - "Region failover"
      - "Full DR site activation"
    
    success_criteria:
      - "RTO < 4 hours"
      - "Zero data loss (within RPO)"
      - "All services operational"
```

### 9.2 Disaster Recovery Automation

```python
# disaster_recovery/failover.py
#!/usr/bin/env python3
"""
Disaster Recovery Failover Automation
Automated failover procedures for disaster recovery
"""

import time
import logging
from enum import Enum
from typing import Dict, List

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class FailoverType(Enum):
    REGION = "region"
    DATABASE = "database"
    FULL_SITE = "full_site"

class DisasterRecoveryManager:
    """Manage disaster recovery procedures"""
    
    def __init__(self, config: Dict):
        self.config = config
        self.failover_log = []
    
    def execute_failover(self, failover_type: FailoverType) -> bool:
        """Execute failover procedure"""
        logger.info(f"🚨 Starting {failover_type.value} failover...")
        
        if failover_type == FailoverType.REGION:
            return self._region_failover()
        elif failover_type == FailoverType.DATABASE:
            return self._database_failover()
        elif failover_type == FailoverType.FULL_SITE:
            return self._full_site_failover()
        
        return False
    
    def _region_failover(self) -> bool:
        """Execute region failover"""
        logger.info("🔄 Executing region failover...")
        
        steps = [
            ("Verify primary region failure", self._verify_primary_failure),
            ("Route DNS to backup region", self._update_dns_records),
            ("Scale backup region resources", self._scale_backup_region),
            ("Verify application health", self._verify_health),
            ("Monitor for stability", self._monitor_stability)
        ]
        
        for step_name, step_func in steps:
            logger.info(f"📋 {step_name}...")
            
            if not step_func():
                logger.error(f"❌ Failed: {step_name}")
                return False
            
            logger.info(f"✅ Completed: {step_name}")
        
        logger.info("✅ Region failover completed successfully")
        return True
    
    def _database_failover(self) -> bool:
        """Execute database failover"""
        logger.info("🗄️ Executing database failover...")
        
        steps = [
            ("Promote read replica to primary", self._promote_replica),
            ("Update application connection strings", self._update_db_connections),
            ("Create new read replicas", self._create_replicas),
            ("Verify data integrity", self._verify_data_integrity),
            ("Update DNS/Load Balancer", self._update_database_dns)
        ]
        
        for step_name, step_func in steps:
            logger.info(f"📋 {step_name}...")
            
            if not step_func():
                logger.error(f"❌ Failed: {step_name}")
                return False
            
            logger.info(f"✅ Completed: {step_name}")
        
        logger.info("✅ Database failover completed successfully")
        return True
    
    def _full_site_failover(self) -> bool:
        """Execute full site failover"""
        logger.info("🏢 Executing full site failover...")
        
        steps = [
            ("Activate DR site", self._activate_dr_site),
            ("Restore from backups", self._restore_backups),
            ("Validate data integrity", self._verify_data_integrity),
            ("Route traffic to DR site", self._route_to_dr_site),
            ("Monitor for stability", self._monitor_stability)
        ]
        
        for step_name, step_func in steps:
            logger.info(f"📋 {step_name}...")
            
            if not step_func():
                logger.error(f"❌ Failed: {step_name}")
                return False
            
            logger.info(f"✅ Completed: {step_name}")
        
        logger.info("✅ Full site failover completed successfully")
        return True
    
    def _verify_primary_failure(self) -> bool:
        """Verify primary region is actually failed"""
        # Implement health checks
        return True
    
    def _update_dns_records(self) -> bool:
        """Update DNS to point to backup region"""
        # Implement DNS update
        return True
    
    def _scale_backup_region(self) -> bool:
        """Scale resources in backup region"""
        # Implement scaling
        return True
    
    def _verify_health(self) -> bool:
        """Verify application health in new location"""
        max_attempts = 30
        for i in range(max_attempts):
            if self._check_health():
                return True
            time.sleep(10)
        return False
    
    def _check_health(self) -> bool:
        """Check application health"""
        # Implement health check
        return True
    
    def _monitor_stability(self) -> bool:
        """Monitor for stability period"""
        logger.info("⏳ Monitoring for 1 hour...")
        # Implement monitoring
        return True
    
    def _promote_replica(self) -> bool:
        """Promote database read replica to primary"""
        # Implement replica promotion
        return True
    
    def _update_db_connections(self) -> bool:
        """Update application database connections"""
        # Implement connection update
        return True
    
    def _create_replicas(self) -> bool:
        """Create new read replicas"""
        # Implement replica creation
        return True
    
    def _verify_data_integrity(self) -> bool:
        """Verify data integrity after failover"""
        # Implement data verification
        return True
    
    def _update_database_dns(self) -> bool:
        """Update database DNS/load balancer"""
        # Implement DNS update
        return True
    
    def _activate_dr_site(self) -> bool:
        """Activate disaster recovery site"""
        # Implement DR site activation
        return True
    
    def _restore_backups(self) -> bool:
        """Restore data from backups"""
        # Implement backup restoration
        return True
    
    def _route_to_dr_site(self) -> bool:
        """Route traffic to DR site"""
        # Implement traffic routing
        return True
```

---

## 10. Post-Incident Reviews

### 10.1 Post-Incident Review Template

```markdown
# Post-Incident Review: [Incident ID]

## Incident Summary
- **Date**: [Date of incident]
- **Duration**: [X hours/Y minutes]
- **Severity**: [P1/P2/P3/P4]
- **Impact**: [Number of users affected, revenue impact, etc.]
- **Incident Commander**: [Name]
- **Contributors**: [List of team members involved]

## Timeline
[Chronological timeline of events]

### Pre-Incident
- **[Time]**: [Event leading to incident]

### During Incident
- **[Time]**: [Alert triggered] - [Alert name]
- **[Time]**: [Incident acknowledged by] [Name]
- **[Time]**: [Investigation started]
- **[Time]**: [Root cause identified] - [Description]
- **[Time]**: [Mitigation implemented] - [What was done]
- **[Time]**: [Incident resolved]

### Post-Incident
- **[Time]**: [Monitoring period started]
- **[Time]**: [Normal operation confirmed]

## Root Cause Analysis

### What Happened?
[Description of what happened]

### Why Did It Happen?
[Technical explanation of root cause]

### Five Whys Analysis
1. [First why]
2. [Second why]
3. [Third why]
4. [Fourth why]
5. [Fifth why - root cause]

### Contributing Factors
- [Factor 1]
- [Factor 2]
- [Factor 3]

## Resolution

### What Fixed It?
[Description of what fixed the issue]

### Mitigation Steps
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Rollback (if applicable)
[Description of rollback procedure used]

## Impact Assessment

### User Impact
- [Number] users affected
- [Duration] of impact
- [Geographic areas] affected

### Business Impact
- [Revenue loss] (if applicable)
- [SLA credits] owed (if applicable)
- [Customer complaints]

### Technical Impact
- [Systems affected]
- [Data loss] (if any)
- [Performance degradation]

## What Went Well
- [Positive aspect 1]
- [Positive aspect 2]
- [Positive aspect 3]

## What Could Be Improved
- [Area for improvement 1]
- [Area for improvement 2]
- [Area for improvement 3]

## Action Items

### Immediate Actions (Within 1 week)
- [ ] [Action item] - [Owner] - [Due date]
- [ ] [Action item] - [Owner] - [Due date]

### Short-term Actions (Within 1 month)
- [ ] [Action item] - [Owner] - [Due date]
- [ ] [Action item] - [Owner] - [Due date]

### Long-term Actions (Within 3 months)
- [ ] [Action item] - [Owner] - [Due date]
- [ ] [Action item] - [Owner] - [Due date]

## Prevention Plan

### Technical Changes
- [ ] [Change 1] - [Priority] - [Owner]
- [ ] [Change 2] - [Priority] - [Owner]

### Process Changes
- [ ] [Process change 1] - [Priority] - [Owner]
- [ ] [Process change 2] - [Priority] - [Owner]

### Monitoring Improvements
- [ ] [Monitoring improvement 1] - [Priority] - [Owner]
- [ ] [Monitoring improvement 2] - [Priority] - [Owner]

### Documentation Updates
- [ ] [Runbook to create/update] - [Owner]
- [ ] [Documentation to update] - [Owner]

## Follow-Up
- **Follow-up meeting scheduled**: [Date/Time]
- **Action items tracked in**: [Project management tool]
- **Next review date**: [Date]

## Appendices

### Logs and Metrics
[Links to relevant logs and metrics]

### Communication History
[Timeline of communication during incident]

### Related Incidents
[Links to similar past incidents]

---

**Review prepared by**: [Name]
**Review date**: [Date]
**Approved by**: [Name], [Date]
```

### 10.2 Post-Incident Review Automation

```python
# incident/postmortem_generator.py
#!/usr/bin/env python3
"""
Post-Incident Review Generator
Automatically generate post-incident reviews from incident data
"""

from datetime import datetime, timedelta
from typing import Dict, List
import json

class PostmortemGenerator:
    """Generate post-incident reviews"""
    
    def __init__(self, incident_data: Dict):
        self.incident = incident_data
    
    def generate_postmortem(self) -> str:
        """Generate post-incident review document"""
        postmortem = f"""# Post-Incident Review: {self.incident['id']}

## Incident Summary
- **Date**: {self.incident['created_at'].split('T')[0]}
- **Duration**: {self._calculate_duration()}
- **Severity**: {self.incident['severity']}
- **Impact**: {self.incident.get('impact', 'To be determined')}
- **Incident Commander**: {self.incident.get('assigned_to', 'TBD')}
- **Contributors**: {self._get_contributors()}

## Timeline
{self._generate_timeline()}

## Root Cause Analysis

### What Happened?
{self.incident.get('description', 'To be documented')}

### Root Cause
{self.incident.get('root_cause', 'To be determined')}

### Five Whys Analysis
{self._generate_five_whys()}

## Resolution

### What Fixed It?
{self.incident.get('resolution', 'To be documented')}

### Mitigation Steps
{self._format_actions_taken()}

## Impact Assessment

### User Impact
- Users affected: {self.incident.get('users_affected', 'TBD')}
- Duration of impact: {self._calculate_duration()}
- Affected areas: {self.incident.get('affected_areas', 'TBD')}

### Business Impact
- Revenue impact: {self.incident.get('revenue_impact', 'TBD')}
- SLA credits: {self.incident.get('sla_credits', 'None')}

## What Went Well
{self._get_positive_aspects()}

## What Could Be Improved
{self._get_improvement_areas()}

## Action Items

### Immediate Actions (Within 1 week)
{self._generate_action_items('immediate')}

### Short-term Actions (Within 1 month)
{self._generate_action_items('short_term')}

### Long-term Actions (Within 3 months)
{self._generate_action_items('long_term')}

## Prevention Plan

### Technical Changes
{self._generate_prevention_items('technical')}

### Process Changes
{self._generate_prevention_items('process')}

### Monitoring Improvements
{self._generate_prevention_items('monitoring')}

## Follow-Up
- **Action items tracked in**: [Project management system]
- **Next review date**: {(datetime.now() + timedelta(days=30)).strftime('%Y-%m-%d')}

---

**Review prepared by**: {self.incident.get('assigned_to', 'TBD')}
**Review date**: {datetime.now().strftime('%Y-%m-%d')}
**Status**: Draft - Pending review
"""
        return postmortem
    
    def _calculate_duration(self) -> str:
        """Calculate incident duration"""
        if self.incident.get('resolved_at'):
            start = datetime.fromisoformat(self.incident['created_at'])
            end = datetime.fromisoformat(self.incident['resolved_at'])
            duration = end - start
            hours = duration.total_seconds() / 3600
            if hours >= 1:
                return f"{hours:.1f} hours"
            else:
                minutes = duration.total_seconds() / 60
                return f"{minutes:.0f} minutes"
        return "In progress"
    
    def _get_contributors(self) -> str:
        """Get list of contributors"""
        # Extract contributors from timeline
        contributors = set()
        for event in self.incident.get('timeline', []):
            if 'by' in event.get('event', ''):
                # Extract name from event
                pass
        return ', '.join(sorted(contributors)) if contributors else 'TBD'
    
    def _generate_timeline(self) -> str:
        """Generate formatted timeline"""
        timeline = ""
        for event in self.incident.get('timeline', []):
            timestamp = event.get('timestamp', '')
            event_text = event.get('event', '')
            timeline += f"- **{timestamp}**: {event_text}\n"
        return timeline
    
    def _generate_five_whys(self) -> str:
        """Generate five whys analysis"""
        return """1. [To be filled during review]
2. [To be filled during review]
3. [To be filled during review]
4. [To be filled during review]
5. [To be filled during review]"""
    
    def _format_actions_taken(self) -> str:
        """Format actions taken during incident"""
        actions = ""
        for action in self.incident.get('actions_taken', []):
            actions += f"- {action}\n"
        return actions if actions else "- To be documented"
    
    def _get_positive_aspects(self) -> str:
        """Get positive aspects from incident"""
        return """- To be filled during review
- What worked well?
- What should be replicated?"""
    
    def _get_improvement_areas(self) -> str:
        """Get areas for improvement"""
        return """- To be filled during review
- What could be done better?
- What processes need improvement?"""
    
    def _generate_action_items(self, timeframe: str) -> str:
        """Generate action items for timeframe"""
        return """- [ ] Action item - Owner - Due date
- [ ] Action item - Owner - Due date"""
    
    def _generate_prevention_items(self, category: str) -> str:
        """Generate prevention items"""
        return """- [ ] Item - Priority - Owner
- [ ] Item - Priority - Owner"""
```

---

## 11. Practical Exercises

### Exercise 1: Blue-Green Deployment

**Task**: Implement a blue-green deployment for a NIP application

**Requirements**:
1. Set up two Kubernetes deployments (blue and green)
2. Create a service that can switch between them
3. Write a script to automate the deployment process
4. Implement health checks before traffic switch
5. Test rollback functionality

**Solution Steps**:
1. Create deployment manifests for both environments
2. Implement health check endpoint
3. Write deployment script that:
   - Deploys to inactive environment
   - Runs health checks
   - Switches traffic on success
   - Rolls back on failure
4. Test with various failure scenarios

### Exercise 2: Canary Deployment

**Task**: Implement a canary deployment with gradual traffic increase

**Requirements**:
1. Set up Istio or similar service mesh
2. Create canary deployment configuration
3. Implement automated monitoring
4. Write promotion script based on metrics
5. Test with error rate increases

**Solution Steps**:
1. Install and configure Istio
2. Create VirtualService with traffic splitting
3. Deploy monitoring for canary metrics
4. Write promotion script that:
   - Monitors error rates and latency
   - Gradually increases canary traffic
   - Auto-rolls back on issues
5. Test with deliberate bugs

### Exercise 3: Incident Response Drill

**Task**: Simulate and respond to a production incident

**Scenario**: Application is experiencing high error rates

**Requirements**:
1. Detect the issue using monitoring
2. Create and acknowledge incident
3. Follow runbook procedures
4. Implement fix
5. Document incident and create postmortem

**Solution Steps**:
1. Set up monitoring alerts
2. Trigger simulated incident (increase load)
3. Practice incident response:
   - Acknowledge alert
   - Investigate using logs/metrics
   - Apply fix from runbook
   - Verify resolution
4. Generate postmortem document

### Exercise 4: SLA Monitoring

**Task**: Implement SLA monitoring and reporting

**Requirements**:
1. Define SLA targets for uptime and performance
2. Set up Prometheus queries for SLA metrics
3. Create automated SLA reports
4. Implement alerting for SLA breaches
5. Generate monthly SLA compliance report

**Solution Steps**:
1. Define SLA configuration
2. Write Prometheus queries for metrics
3. Create SLA monitoring script
4. Set up alerting rules
5. Generate and review monthly report

### Exercise 5: Disaster Recovery Drill

**Task**: Execute a disaster recovery failover

**Requirements**:
1. Set up multi-region deployment
2. Implement database replication
3. Practice region failover
4. Verify data integrity
5. Document and improve procedures

**Solution Steps**:
1. Deploy to backup region
2. Configure database replication
3. Simulate primary region failure
4. Execute failover procedure
5. Verify application functionality
6. Document lessons learned

---

## 12. Best Practices

### Deployment Best Practices

1. **Always use blue-green or canary deployments for production**
   - Never deploy directly to production
   - Maintain ability to rollback instantly
   
2. **Automate everything possible**
   - Automated tests before deployment
   - Automated health checks
   - Automated rollback on failure

3. **Monitor deployments in real-time**
   - Watch error rates and latency
   - Set up alerts for deployment failures
   - Have dashboards ready for monitoring

4. **Test rollback procedures regularly**
   - Rollbacks should be as fast as deployments
   - Document rollback steps clearly
   - Practice rollbacks in staging

### Incident Management Best Practices

1. **Acknowledge incidents quickly**
   - Set clear acknowledgement SLAs (e.g., 5 minutes for P1)
   - Always update incident status
   - Communicate proactively

2. **Follow documented runbooks**
   - Keep runbooks up to date
   - Review runbooks after incidents
   - Create new runbooks for new scenarios

3. **Document everything during incidents**
   - Keep detailed timeline
   - Record commands executed
   - Note what worked and didn't work

4. **Conduct blameless postmortems**
   - Focus on process, not people
   - Identify systemic issues
   - Create actionable improvements

### On-Call Best Practices

1. **Maintain clear escalation paths**
   - Document who to contact and when
   - Set up automatic escalations
   - Keep contact info current

2. **Prepare comprehensive handoffs**
   - Document active issues
   - Note recent changes
   - Share any concerns

3. **Avoid hero culture**
   - Don't encourage excessive overtime
   - Distribute on-call burden fairly
   - Support on-call engineers

### SLA and Compliance Best Practices

1. **Define SLAs realistically**
   - Base on actual capabilities
   - Include room for maintenance
   - Consider business needs

2. **Monitor SLAs continuously**
   - Set up automated monitoring
   - Alert before breaches occur
   - Generate regular reports

3. **Plan for compliance audits**
   - Keep detailed logs
   - Document processes
   - Regular security reviews

### Disaster Recovery Best Practices

1. **Test recovery procedures regularly**
   - Schedule quarterly DR tests
   - Test all failure scenarios
   - Update procedures based on tests

2. **Maintain backups properly**
   - Regular backup verification
   - Off-site backup storage
   - Document restoration procedures

3. **Keep documentation current**
   - Update runbooks after incidents
   - Document new procedures
   - Share knowledge across teams

---

## Conclusion

Production operations is about more than just deploying code - it's about running reliable, resilient systems that your users can depend on. By implementing the strategies, tools, and practices covered in this tutorial, you'll be well-equipped to handle the challenges of running NIP applications in production.

**Key Takeaways**:
- Use blue-green or canary deployments for safe releases
- Maintain comprehensive runbooks for common scenarios
- Establish clear incident management procedures
- Monitor SLAs continuously and report regularly
- Practice disaster recovery procedures regularly
- Conduct blameless postmortems to improve continuously

**Next Steps**:
1. Implement deployment automation in your environment
2. Create runbooks for your common failure scenarios
3. Set up comprehensive monitoring and alerting
4. Establish on-call rotation and escalation procedures
5. Schedule regular disaster recovery tests

**Resources**:
- [NIP Documentation](https://docs.nip.io)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Site Reliability Engineering](https://sre.google/books/)
- [Incident Management Guide](https://www.atlassian.com/incident-management)

Happy deploying, and may your pagers stay silent! 🚀
