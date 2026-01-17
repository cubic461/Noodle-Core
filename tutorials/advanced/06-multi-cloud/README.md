# ☁️ Tutorial 06: Multi-Cloud Deployment Strategies

## Advanced Deployment for NIP v3.0.0

Deploying NIP across multiple cloud providers provides redundancy, avoids vendor lock-in, and enables geographic distribution. This comprehensive guide covers deployment strategies across AWS, Azure, and GCP.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [AWS Deployment](#aws-deployment)
3. [Azure Deployment](#azure-deployment)
4. [GCP Deployment](#gcp-deployment)
5. [Terraform Configurations](#terraform-configurations)
6. [Multi-Cloud Networking](#multi-cloud-networking)
7. [Cost Optimization](#cost-optimization)
8. [Disaster Recovery](#disaster-recovery)
9. [Multi-Region Replication](#multi-region-replication)
10. [Practical Exercises](#practical-exercises)
11. [Best Practices](#best-practices)

---

## Overview

### Why Multi-Cloud?

**Benefits:**
- **Redundancy**: No single point of failure
- **Flexibility**: Choose best services from each provider
- **Compliance**: Meet data residency requirements
- **Negotiation Power**: Leverage pricing competition
- **Risk Mitigation**: Avoid vendor lock-in

**Challenges:**
- Increased complexity
- Skill requirements across platforms
- Data transfer costs
- Consistent operations across providers

### Architecture Pattern

```
                    ┌─────────────────┐
                    │  Global CDN     │
                    │  (CloudFlare)   │
                    └────────┬────────┘
                             │
            ┌────────────────┼────────────────┐
            │                │                │
       ┌────▼────┐     ┌────▼────┐     ┌────▼────┐
       │   AWS   │     │  Azure  │     │   GCP   │
       │  (US)   │     │ (EU)    │     │ (Asia)  │
       └─────────┘     └─────────┘     └─────────┘
            │                │                │
            └────────────────┼────────────────┘
                             │
                    ┌────────▼────────┐
                    │  Replication    │
                    │  & Failover     │
                    └─────────────────┘
```

---

## AWS Deployment

### ECS (Elastic Container Service) Deployment

**Prerequisites:**
```bash
# Install AWS CLI v2
# Configure credentials
aws configure

# Create ECR repository
aws ecr create-repository --repository-name nip-app
```

**Task Definition:**
```json
{
  "family": "nip-app",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "2048",
  "memory": "4096",
  "executionRoleArn": "arn:aws:iam::ACCOUNT_ID:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "nip-app",
      "image": "ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/nip-app:latest",
      "cpu": 2048,
      "memory": 4096,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "ENVIRONMENT",
          "value": "production"
        },
        {
          "name": "DB_CONNECTION",
          "value": "postgresql://aws-db:5432/nip"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/nip-app",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      }
    }
  ]
}
```

**ECS Service:**
```bash
# Create cluster
aws ecs create-cluster --cluster-name nip-cluster

# Create service
aws ecs create-service \
  --cluster nip-cluster \
  --service-name nip-service \
  --task-definition nip-app \
  --desired-count 3 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-1,subnet-2],securityGroups=[sg-1],assignPublicIp=ENABLED}" \
  --deployment-configuration "maximumPercent=200,minimumHealthyPercent=50"

# Enable auto-scaling
aws application-autoscaling register-scalable-target \
  --service-namespace ecs \
  --resource-id service/nip-cluster/nip-service \
  --scalable-dimension ecs:service:DesiredCount \
  --min-capacity 2 \
  --max-capacity 10

aws application-autoscaling put-scaling-policy \
  --service-namespace ecs \
  --resource-id service/nip-cluster/nip-service \
  --scalable-dimension ecs:service:DesiredCount \
  --policy-name nip-auto-scale \
  --policy-type TargetTrackingScaling \
  --target-tracking-scaling-policy-configuration file://scaling-policy.json
```

**Scaling Policy:**
```json
{
  "TargetValue": 70.0,
  "PredefinedMetricSpecification": {
    "PredefinedMetricType": "ECSServiceAverageCPUUtilization"
  },
  "ScaleOutCooldown": 300,
  "ScaleInCooldown": 300
}
```

### Lambda Deployment (Serverless)

**Lambda Function:**
```python
# lambda_function.py
import json
import os
import psycopg2
from datetime import datetime

def lambda_handler(event, context):
    """Handle API Gateway events"""
    try:
        # Database connection
        conn = psycopg2.connect(
            host=os.environ['DB_HOST'],
            database=os.environ['DB_NAME'],
            user=os.environ['DB_USER'],
            password=os.environ['DB_PASSWORD']
        )
        
        # Process event
        path = event['path']
        method = event['httpMethod']
        
        if path == '/health' and method == 'GET':
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'status': 'healthy',
                    'timestamp': datetime.utcnow().isoformat(),
                    'region': os.environ['AWS_REGION']
                })
            }
        
        return {
            'statusCode': 404,
            'body': json.dumps({'error': 'Not found'})
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
        finally:
            if 'conn' in locals():
                conn.close()
```

**Deployment Script:**
```bash
# Deploy Lambda
aws lambda create-function \
  --function-name nip-lambda \
  --runtime python3.11 \
  --role arn:aws:iam::ACCOUNT_ID:role/lambda-role \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://function.zip \
  --environment Variables={DB_HOST=...,DB_NAME=nip} \
  --timeout 30 \
  --memory-size 512

# Create API Gateway
aws apigateway create-rest-api \
  --name nip-api \
  --description "NIP Lambda API"

# Deploy API
aws apigateway create-deployment \
  --rest-api-id API_ID \
  --stage-name prod
```

### EC2 Deployment (Traditional)

**User Data Script:**
```bash
#!/bin/bash
# EC2 user data for NIP deployment

# Update system
yum update -y

# Install Docker
amazon-linux-extras install docker
service docker start
usermod -aG docker ec2-user

# Install NIP
docker pull nipapp/nip:latest

# Run container
docker run -d \
  --name nip-app \
  -p 80:8080 \
  -e ENVIRONMENT=production \
  -e DB_HOST=${db_endpoint} \
  --restart unless-stopped \
  nipapp/nip:latest

# Install CloudWatch agent
yum install -y amazon-cloudwatch-agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s
```

**Launch Template:**
```bash
aws ec2 create-launch-template \
  --launch-template-name nip-launch-template \
  --launch-template-data file://launch-template.json
```

---

## Azure Deployment

### AKS (Azure Kubernetes Service)

**Resource Group & Cluster:**
```bash
# Create resource group
az group create \
  --name nip-rg \
  --location eastus

# Create AKS cluster
az aks create \
  --resource-group nip-rg \
  --name nip-aks \
  --node-count 3 \
  --node-vm-size Standard_DS2_v2 \
  --enable-cluster-autoscaler \
  --min-count 2 \
  --max-count 5 \
  --enable-addons monitoring \
  --generate-ssh-keys

# Get credentials
az aks get-credentials \
  --resource-group nip-rg \
  --name nip-aks
```

**Kubernetes Deployment:**
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nip-app
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nip-app
  template:
    metadata:
      labels:
        app: nip-app
    spec:
      containers:
      - name: nip-app
        image: nipapp.azurecr.io/nip:latest
        ports:
        - containerPort: 8080
        env:
        - name: ENVIRONMENT
          value: "production"
        - name: DB_CONNECTION
          valueFrom:
            secretKeyRef:
              name: nip-secrets
              key: db-connection
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
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
---
apiVersion: v1
kind: Service
metadata:
  name: nip-service
  namespace: production
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: nip-app
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nip-hpa
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nip-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

**Deploy to AKS:**
```bash
# Create namespace
kubectl create namespace production

# Create secret
kubectl create secret generic nip-secrets \
  --from-literal=db-connection='postgresql://azure-db:5432/nip' \
  --namespace=production

# Apply deployment
kubectl apply -f deployment.yaml

# Verify
kubectl get pods -n production
kubectl get service nip-service -n production
```

### Azure Functions (Serverless)

**Function App:**
```bash
# Create storage account
az storage account create \
  --name nipstorage \
  --location eastus \
  --resource-group nip-rg \
  --sku Standard_LRS

# Create function app
az functionapp create \
  --resource-group nip-rg \
  --consumption-plan-location eastus \
  --runtime python \
  --runtime-version 3.11 \
  --functions-version 4 \
  --name nip-functions \
  --storage-account nipstorage

# Deploy code
func azure functionapp publish nip-functions
```

**Function Code:**
```python
# function_app.py
import azure.functions as func
import logging
import os

app = func.FunctionApp()

@app.route(route="health", auth_level=func.AuthLevel.ANONYMOUS)
def health_check(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Health check triggered')
    
    return func.HttpResponse(
        json.dumps({
            "status": "healthy",
            "timestamp": datetime.utcnow().isoformat(),
            "region": os.environ["REGION_NAME"]
        }),
        status_code=200,
        mimetype="application/json"
    )

@app.queue_trigger(
    queue_name="nip-tasks",
    connection="AzureWebJobsStorage"
)
def process_queue_message(msg: func.QueueMessage):
    logging.info(f'Processing queue message: {msg.get_body().decode()}')
    # Process message
```

### Azure VMs (Virtual Machines)

**VM Deployment:**
```bash
# Create VM
az vm create \
  --resource-group nip-rg \
  --name nip-vm \
  --image Ubuntu2204 \
  --size Standard_DS2_v2 \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/id_rsa.pub \
  --custom-data cloud-init.txt

# Open port
az vm open-port \
  --resource-group nip-rg \
  --name nip-vm \
  --port 80

# Enable auto-scaling
az vmss create \
  --resource-group nip-rg \
  --name nip-vmss \
  --image Ubuntu2204 \
  --instance-count 2 \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/id_rsa.pub
```

**Cloud Init:**
```yaml
# cloud-init.txt
#cloud-config
package_update: true
package_upgrade: true
packages:
  - docker.io
  - docker-compose
runcmd:
  - systemctl start docker
  - systemctl enable docker
  - docker pull nipapp/nip:latest
  - docker run -d --name nip-app -p 80:8080 nipapp/nip:latest
```

---

## GCP Deployment

### GKE (Google Kubernetes Engine)

**Cluster Creation:**
```bash
# Create cluster
gcloud container clusters create nip-gke \
  --zone us-central1-a \
  --num-nodes 3 \
  --machine-type e2-medium \
  --enable-autoscaling \
  --min-nodes 2 \
  --max-nodes 6 \
  --enable-ip-alias \
  --enable-autorepair \
  --enable-autoupgrade

# Get credentials
gcloud container clusters get-credentials nip-gke \
  --zone us-central1-a
```

**Deployment:**
```yaml
# gke-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nip-app
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nip-app
  template:
    metadata:
      labels:
        app: nip-app
    spec:
      containers:
      - name: nip-app
        image: gcr.io/PROJECT_ID/nip:latest
        ports:
        - containerPort: 8080
        env:
        - name: ENVIRONMENT
          value: "production"
        - name: DB_HOST
          value: "cloud-sql-ip"
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
---
apiVersion: v1
kind: Service
metadata:
  name: nip-service
spec:
  type: LoadBalancer
  loadBalancerIP: RESERVED_IP
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: nip-app
```

**Deploy:**
```bash
# Build and push image
gcloud builds submit --tag gcr.io/PROJECT_ID/nip:latest

# Deploy
kubectl apply -f gke-deployment.yaml
```

### Cloud Functions

**Deploy Function:**
```bash
# Deploy HTTP function
gcloud functions deploy nip-http \
  --runtime python311 \
  --trigger-http \
  --allow-unauthenticated \
  --entry-point handler \
  --region us-central1 \
  --memory 512MB \
  --timeout 30s

# Deploy pub/sub function
gcloud functions deploy nip-processor \
  --runtime python311 \
  --trigger-topic nip-tasks \
  --entry-point process_message \
  --region us-central1
```

**Function Code:**
```python
# main.py
import json
from datetime import datetime

def handler(request):
    """HTTP function handler"""
    request_json = request.get_json(silent=True)
    
    return json.dumps({
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "region": "us-central1"
    }), 200

def process_message(event, context):
    """Pub/Sub function handler"""
    import base64
    
    if 'data' in event:
        message = base64.b64decode(event['data']).decode('utf-8')
        print(f"Processing: {message}")
```

### Compute Engine

**Instance Creation:**
```bash
# Create instance template
gcloud compute instance-templates create nip-template \
  --machine-type e2-medium \
  --image-family ubuntu-2204-lts \
  --image-project ubuntu-os-cloud \
  --boot-disk-size 20GB \
  --metadata startup-script='#!/bin/bash
    docker run -d -p 80:8080 nipapp/nip:latest'

# Create instance group
gcloud compute instance-groups managed create nip-ig \
  --base-instance-name nip \
  --size 2 \
  --template nip-template \
  --zone us-central1-a

# Set auto-scaling
gcloud compute instance-groups managed set-autoscaling nip-ig \
  --zone us-central1-a \
  --max 5 \
  --min 2 \
  --target-cpu-utilization 0.7
```

---

## Terraform Configurations

### Multi-Provider Terraform

**Provider Configuration:**
```hcl
# providers.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "azurerm" {
  features {}
}

provider "google" {
  region = var.gcp_region
}
```

**AWS ECS Module:**
```hcl
# modules/aws-ecs/main.tf
resource "aws_ecs_cluster" "nip" {
  name = "${var.environment}-nip-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "nip" {
  family                   = "${var.environment}-nip"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  
  container_definitions = jsonencode([
    {
      name      = "nip-app"
      image     = var.container_image
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
      
      environment = [
        {
          name  = "ENVIRONMENT"
          value = var.environment
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.nip.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])
}

resource "aws_ecs_service" "nip" {
  name            = "${var.environment}-nip-service"
  cluster         = aws_ecs_cluster.nip.id
  task_definition = aws_ecs_task_definition.nip.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }
  
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "nip-app"
    container_port   = 8080
  }
  
  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 50
  }
  
  enable_execute_command = true
}

resource "aws_appautoscaling_target" "nip" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.nip.name}/${aws_ecs_service.nip.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "nip" {
  name               = "${var.environment}-nip-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.nip.resource_id
  scalable_dimension = aws_appautoscaling_target.nip.scalable_dimension
  service_namespace  = aws_appautoscaling_target.nip.service_namespace
  
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}
```

**Azure AKS Module:**
```hcl
# modules/azure-aks/main.tf
resource "azurerm_resource_group" "nip" {
  name     = "${var.environment}-nip-rg"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "nip" {
  name                = "${var.environment}-nip-aks"
  location            = azurerm_resource_group.nip.location
  resource_group_name = azurerm_resource_group.nip.name
  dns_prefix          = "${var.environment}-nip"
  
  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size
    min_count  = var.min_count
    max_count  = var.max_count
    enable_auto_scaling = true
  }
  
  identity {
    type = "SystemAssigned"
  }
  
  addons {
    oms_agent = true
  }
  
  tags = {
    environment = var.environment
  }
}

resource "azurerm_container_registry" "nip" {
  name                = "${var.environment}nipacr"
  resource_group_name = azurerm_resource_group.nip.name
  location            = azurerm_resource_group.nip.location
  sku                 = "Standard"
  admin_enabled       = true
}
```

**GCP GKE Module:**
```hcl
# modules/gcp-gke/main.tf
resource "google_container_cluster" "nip" {
  name     = "${var.environment}-nip-gke"
  location = var.region
  
  remove_default_node_pool = true
  initial_node_count       = 1
  
  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
  }
}

resource "google_container_node_pool" "nip" {
  name       = "${var.environment}-nip-node-pool"
  location   = var.region
  cluster    = google_container_cluster.nip.name
  node_count = var.node_count
  
  node_config {
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  
  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }
}
```

**Main Configuration:**
```hcl
# main.tf
module "aws_ecs" {
  source = "./modules/aws-ecs"
  
  environment      = "production"
  aws_region       = "us-east-1"
  container_image  = "nipapp/nip:latest"
  cpu              = 2048
  memory           = 4096
  desired_count    = 3
  min_capacity     = 2
  max_capacity     = 10
  subnet_ids       = ["subnet-1", "subnet-2"]
  security_group_id = "sg-1"
  target_group_arn = "arn:..."
}

module "azure_aks" {
  source = "./modules/azure-aks"
  
  environment = "production"
  location    = "eastus"
  node_count  = 3
  vm_size     = "Standard_DS2_v2"
  min_count   = 2
  max_count   = 5
}

module "gcp_gke" {
  source = "./modules/gcp-gke"
  
  environment     = "production"
  region          = "us-central1"
  node_count      = 3
  machine_type    = "e2-medium"
  min_node_count  = 2
  max_node_count  = 6
}
```

---

## Multi-Cloud Networking

### DNS & Load Balancing

**Global DNS with CloudFlare:**
```yaml
# cloudflare-config.yaml
proxies:
  - name: nip-aws
    region: us-east-1
    origin: alb-aws.us-east-1.elb.amazonaws.com
    healthcheck: /health
    
  - name: nip-azure
    region: eastus
    origin: azure-aks.eastus.cloudapp.azure.com
    healthcheck: /health
    
  - name: nip-gcp
    region: us-central1
    origin: gcp-ingress.us-central1.elb.amazonaws.com
    healthcheck: /health

load_balancing:
  algorithm: latency
  pools:
    - name: us-pool
      regions: [us-east-1, us-central1]
      weight: 60
      
    - name: eu-pool
      regions: [eastus]
      weight: 30
      
    - name: asia-pool
      regions: [asia-east1]
      weight: 10
```

**Cross-Cloud VPN:**
```bash
# AWS Transit Gateway
aws ec2 create-transit-gateway \
  --description "NIP Transit Gateway" \
  --options file://transit-options.json

# Azure Virtual Network Gateway
az network vnet-gateway create \
  --name nip-vpn-gateway \
  --resource-group nip-rg \
  --vnet nip-vnet \
  --gateway-type Vpn \
  --vpn-type RouteBased

# GCP Cloud VPN
gcloud compute vpn-tunnels create nip-tunnel \
  --region us-central1 \
  --peer-external-gateway AZURE_GATEWAY_IP \
  --ike-version 2 \
  --shared-secrets SECRET
```

### Service Mesh

**Istio Multi-Cluster:**
```yaml
# istio-multi-cluster.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: istio-multi-cluster
spec:
  profile: default
  values:
    global:
      meshID: mesh1
      multiCluster:
        clusterName: aws-cluster
      network: network1
    pilot:
      env:
        EXTERNAL_ISTIOD: true
```

---

## Cost Optimization

### Cost Comparison

**Monthly Cost Estimation (3 nodes, 8GB RAM, 2 vCPU):**

| Service | AWS (us-east-1) | Azure (eastus) | GCP (us-central1) |
|---------|-----------------|----------------|-------------------|
| **Compute** |
| ECS Fargate | $97.20 | - | - |
| AKS | - | $86.40 | - |
| GKE | - | - | $73.80 |
| **Load Balancer** |
| ALB | $20.40 | - | - |
| Azure LB | - | $18.00 | - |
| GCP LB | - | - | $19.50 |
| **Storage (100GB)** |
| EBS | $10.00 | - | - |
| Azure Disk | - | $9.60 | - |
| GCP PD | - | - | $8.00 |
| **Data Transfer** |
| Outbound | $90.00 | $87.00 | $85.00 |
| **TOTAL** | **$217.60** | **$201.00** | **$186.30** |

*Prices are estimates and vary by region and usage*

### Optimization Strategies

**1. Right-Sizing Resources:**
```bash
# AWS - Check utilization
aws cloudwatch get-metric-statistics \
  --namespace AWS/ECS \
  --metric-name CPUUtilization \
  --dimensions Name=ServiceName,Value=nip-service \
  --statistics Average \
  --period 3600 \
  --start-time $(date -u -d '30 days ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S)

# Azure - Check metrics
az monitor metrics list \
  --resource /subscriptions/.../resourceGroups/nip-rg/providers/Microsoft.ContainerService/managedClusters/nip-aks \
  --metric "CPUUtilization"

# GCP - Check metrics
gcloud compute instances get-serial-port-output INSTANCE_NAME \
  --zone us-central1-a
```

**2. Scheduled Scaling:**
```hcl
# Terraform - Scheduled actions
resource "aws_appautoscaling_scheduled_action" "nip_scale_up" {
  name               = "nip-scale-up"
  service_namespace  = aws_appautoscaling_target.nip.service_namespace
  resource_id        = aws_appautoscaling_target.nip.resource_id
  scalable_dimension = aws_appautoscaling_target.nip.scalable_dimension
  
  schedule           = "cron(0 8 * * MON-FRI *)"
  scalable_target_action {
    min_capacity = 5
    max_capacity = 15
  }
}

resource "aws_appautoscaling_scheduled_action" "nip_scale_down" {
  name               = "nip-scale-down"
  service_namespace  = aws_appautoscaling_target.nip.service_namespace
  resource_id        = aws_appautoscaling_target.nip.resource_id
  scalable_dimension = aws_appautoscaling_target.nip.scalable_dimension
  
  schedule           = "cron(0 20 * * MON-FRI *)"
  scalable_target_action {
    min_capacity = 2
    max_capacity = 5
  }
}
```

**3. Reserved Instances:**
```bash
# AWS - Purchase reserved instances
aws ec2 purchase-reserved-instances-offering \
  --reserved-instances-offering-id ID \
  --instance-count 3

# Azure - Reserved instances
az reserved-instance list \
  --resource-group nip-rg

# GCP - Committed use discounts
gcloud compute commitments create \
  --region us-central1 \
  --resources vcpu=4,memory=16384
```

**4. Spot/Preemptible Instances:**
```yaml
# Kubernetes - Spot instances
apiVersion: v1
kind: Pod
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: cloud.google.com/gke-preemptible
            operator: Exists
```

---

## Disaster Recovery

### Backup Strategy

**Database Backups:**
```yaml
# AWS RDS automated backups
resource "aws_db_instance" "nip_db" {
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  multi_az               = true
  final_snapshot_identifier = true
}

# Azure SQL backup
resource "azurerm_mssql_database" "nip_db" {
  server_id         = azurerm_mssql_server.nip.id
  name             = "nip-db"
  
  long_term_retention_policy {
    weekly_retention = "P4W"
    monthly_retention = "P12M"
  }
}

# GCP Cloud SQL backup
resource "google_sql_database_instance" "nip_db" {
  name = "nip-db-instance"
  database_version = "POSTGRES_14"
  region = "us-central1"
  
  backup_configuration {
    enabled            = true
    binary_log_enabled = true
    start_time         = "03:00"
  }
}
```

### Failover Configuration

**Multi-Region Failover:**
```yaml
# AWS - Route53 health checks
resource "aws_route53_health_check" "nip_aws" {
  fqdn              = aws_lb.nip_aws.dns_name
  port              = 80
  type              = "HTTPS"
  resource_path     = "/health"
  request_interval  = 30
  failure_threshold = 3
}

resource "aws_route53_record" "nip_failover" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "nip.example.com"
  type    = "A"
  
  failover_routing_policy {
    type = "PRIMARY"
  }
  
  set_identifier = "aws-primary"
  alias {
    name                   = aws_lb.nip_aws.dns_name
    zone_id                = aws_lb.nip_aws.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "nip_failover_secondary" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "nip.example.com"
  type    = "A"
  
  failover_routing_policy {
    type = "SECONDARY"
  }
  
  set_identifier = "azure-secondary"
  alias {
    name                   = azurerm_public_ip.nip.ip_address
    zone_id                = "Z1D633PEXAMPLE"
    evaluate_target_health = true
  }
}
```

**Recovery Procedures:**
```bash
# Disaster recovery script
#!/bin/bash
set -e

echo "Starting disaster recovery..."

# Check primary health
if ! curl -f http://primary-nip.example.com/health; then
  echo "Primary is down, initiating failover..."
  
  # Update DNS to point to secondary
  aws route53 change-resource-record-sets \
    --hosted-zone-id Z1D633PEXAMPLE \
    --change-batch file://failover-change.json
  
  # Scale up secondary
  az aks scale \
    --resource-group nip-secondary-rg \
    --name nip-aks-secondary \
    --node-count 10
  
  echo "Failover complete!"
else
  echo "Primary is healthy, no action needed."
fi
```

---

## Multi-Region Replication

### Data Replication

**Cross-Region Replication:**
```hcl
# AWS S3 replication
resource "aws_s3_bucket" "primary" {
  bucket = "nip-primary-us-east-1"
}

resource "aws_s3_bucket" "secondary" {
  bucket = "nip-secondary-us-west-2"
  provider = aws.west
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  role = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.primary.id
  
  rule {
    id     = "nip-replication"
    status = "Enabled"
    
    destination {
      bucket        = aws_s3_bucket.secondary.arn
      storage_class = "STANDARD"
    }
  }
}

# Azure Geo-Replication
resource "azurerm_storage_account" "nip" {
  name                     = "nipstorage"
  location                 = "eastus"
  resource_group_name      = azurerm_resource_group.nip.name
  account_tier             = "Standard"
  account_replication_type = "GRS"  # Geo-Redundant Storage
}
```

**Database Replication:**
```bash
# PostgreSQL logical replication
# Primary (AWS)
psql -h aws-primary -U admin -d nip
CREATE PUBLICATION nip_pub FOR ALL TABLES;

# Secondary (Azure)
psql -h azure-secondary -U admin -d nip
CREATE SUBSCRIPTION nip_sub
CONNECTION 'host=aws-primary dbname=nip user=admin'
PUBLICATION nip_pub;
```

### Application Deployment

**Multi-Region Kubernetes Federation:**
```yaml
# kubefed-config.yaml
apiVersion: core.kubefed.io/v1beta1
kind: KubeFedCluster
metadata:
  name: aws-cluster
spec:
  apiEndpoint: https://aws-cluster.example.com
  caBundle: LS0tLS1CRUdJTi...
  secretRef:
    name: aws-cluster-secret

---
apiVersion: core.kubefed.io/v1beta1
kind: KubeFedCluster
metadata:
  name: azure-cluster
spec:
  apiEndpoint: https://azure-cluster.example.com
  caBundle: LS0tLS1CRUdJTi...
  secretRef:
    name: azure-cluster-secret

---
apiVersion: types.kubefed.io/v1beta1
kind: FederatedDeployment
metadata:
  name: nip-app
spec:
  template:
    metadata:
      labels:
        app: nip-app
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: nip-app
      template:
        metadata:
          labels:
            app: nip-app
        spec:
          containers:
          - name: nip-app
            image: nipapp/nip:latest
  placement:
    clusters:
    - name: aws-cluster
    - name: azure-cluster
```

---

## Practical Exercises

### Exercise 1: Deploy to AWS ECS

**Objective**: Deploy NIP to AWS ECS with auto-scaling

**Steps**:
1. Create ECR repository
2. Build and push Docker image
3. Create ECS task definition
4. Deploy ECS service
5. Configure auto-scaling
6. Test deployment

**Verification**:
```bash
# Check service status
aws ecs describe-services \
  --cluster nip-cluster \
  --services nip-service

# Check task health
aws ecs describe-tasks \
  --cluster nip-cluster \
  --tasks $(aws ecs list-tasks --cluster nip-cluster --output text --query taskArns)

# Test endpoint
curl http://ALB-DNS-NAME/health
```

### Exercise 2: Deploy to Azure AKS

**Objective**: Deploy NIP to Azure AKS with monitoring

**Steps**:
1. Create AKS cluster
2. Configure kubectl
3. Deploy application
4. Enable monitoring
5. Configure horizontal pod autoscaler
6. Test scaling

**Verification**:
```bash
# Check pods
kubectl get pods -n production

# Check HPA
kubectl get hpa -n production

# Check metrics
kubectl top nodes
kubectl top pods -n production

# Test endpoint
curl http://EXTERNAL-IP/health
```

### Exercise 3: Multi-Cloud Networking

**Objective**: Set up global load balancing

**Steps**:
1. Deploy to multiple regions
2. Configure CloudFlare
3. Set up health checks
4. Configure latency-based routing
5. Test failover

**Verification**:
```bash
# Test from different locations
curl -H "CF-IPCountry: US" https://nip.example.com/health
curl -H "CF-IPCountry: EU" https://nip.example.com/health

# Simulate failover
# (stop primary region and test)
```

### Exercise 4: Disaster Recovery Drill

**Objective**: Test disaster recovery procedures

**Steps**:
1. Note current configuration
2. Simulate primary region failure
3. Trigger failover
4. Verify secondary takes over
5. Restore primary
6. Failback
7. Document results

**Verification Checklist**:
- [ ] DNS updated correctly
- [ ] Secondary region handles traffic
- [ ] Data replication working
- [ ] No data loss
- [ ] RTO within SLA
- [ ] RPO within SLA

---

## Best Practices

### Security

**1. Identity Management:**
```yaml
# Use IAM roles across all platforms
- AWS: IAM roles for service accounts
- Azure: Managed identities
- GCP: Workload Identity

# Implement least privilege access
- Regular audit of permissions
- Use temporary credentials
- Rotate secrets regularly
```

**2. Network Security:**
```yaml
# Implement zero-trust networking
- VPC/VNet peering
- Network policies in Kubernetes
- Service mesh with mTLS
- WAF at edge

# Encryption
- Encrypt data at rest
- Use TLS 1.3 for data in transit
- Manage keys with KMS
- Rotate certificates
```

### Operations

**1. Monitoring:**
```yaml
# Unified monitoring
# - Prometheus + Grafana
# - CloudWatch + Azure Monitor + Cloud Monitoring

# Key metrics to track:
# - Request rate and latency
# - Error rate
# - CPU, memory, disk usage
# - Network I/O
# - Database connections
# - Queue depth

# Alerting:
# - Set thresholds appropriately
# - Use anomaly detection
# - Route alerts to on-call
```

**2. Logging:**
```yaml
# Centralized logging
# - ELK Stack (Elasticsearch, Logstash, Kibana)
# - Cloud Logging
# - CloudWatch Logs Insights

# Log format:
# - Structured JSON logs
# - Include correlation IDs
# - Add context (region, instance, etc.)
# - Sanitize sensitive data
```

**3. Deployment:**
```yaml
# CI/CD pipeline
# - Automated testing
# - Blue-green deployments
# - Canary releases
# - Automated rollback

# Deployment checklist:
# - Run pre-deployment checks
# - Notify team
# - Deploy to canary first
# - Monitor metrics
# - Gradual rollout
# - Post-deployment verification
```

### Cost Management

**1. Tagging Strategy:**
```yaml
# Standard tags:
# - Environment (prod/staging/dev)
# - Application (nip)
# - Owner (team)
# - CostCenter
# - Project

# Use tags for:
# - Cost allocation
# - Resource identification
# - Automation
```

**2. Budget Alerts:**
```bash
# AWS Budgets
aws budgets create-budget \
  --account-id ACCOUNT_ID \
  --budget file://budget.json

# Azure Budgets
az consumption budget create \
  --budget-name nip-monthly \
  --amount 500 \
  --resource-group nip-rg

# GCP Budget Alerts
gcloud billing budgets create \
  --billing-account-id XXXXXX-XXXXXX-XXXXXX \
  --display-name "NIP Monthly" \
  --amount 500.00
```

**3. Cost Optimization:**
```yaml
# Regular reviews:
# - Monthly cost review
# - Identify unused resources
# - Right-size instances
# - Delete orphaned resources
# - Review reserved instance coverage

# Automation:
# - Auto-delete temporary resources
# - Schedule start/stop for dev environments
# - Use spot instances for batch workloads
```

---

## Conclusion

Multi-cloud deployment provides resilience and flexibility but requires careful planning and management. This tutorial covered:

✅ Deployment strategies for AWS, Azure, and GCP  
✅ Infrastructure as code with Terraform  
✅ Multi-cloud networking and load balancing  
✅ Cost optimization techniques  
✅ Disaster recovery and failover  
✅ Multi-region replication  

**Next Steps:**
1. Start with a single cloud provider
2. Gradually expand to multi-cloud
3. Implement monitoring and alerting early
4. Regularly test disaster recovery procedures
5. Continuously optimize costs

**Remember**: The best multi-cloud strategy is one that matches your specific requirements for availability, compliance, and cost.

---

## Additional Resources

- [AWS ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/)
- [Azure Kubernetes Service Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Google Kubernetes Engine Guide](https://cloud.google.com/kubernetes-engine/docs)
- [Terraform Multi-Cloud Provider](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Istio Multi-Cluster](https://istio.io/latest/docs/setup/install/multicluster/)

---

**Version**: v3.0.0  
**Last Updated**: 2025-01-17  
**Maintained By**: NIP Development Team
