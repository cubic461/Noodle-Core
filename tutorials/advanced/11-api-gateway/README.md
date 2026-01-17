# 🚪 API Gateway Integration for NIP v3.0.0

**Tutorial 11: Advanced Configuration**

## Table of Contents
1. [Overview](#overview)
2. [Kong Gateway Integration](#kong-gateway-integration)
3. [NGINX Gateway Configuration](#nginx-gateway-configuration)
4. [AWS API Gateway](#aws-api-gateway)
5. [Azure API Management](#azure-api-management)
6. [Request Routing & Load Balancing](#request-routing--load-balancing)
7. [Rate Limiting at Gateway Level](#rate-limiting-at-gateway-level)
8. [Authentication & Authorization](#authentication--authorization)
9. [API Versioning](#api-versioning)
10. [Practical Exercises](#practical-exercises)
11. [Best Practices](#best-practices)
12. [Comparison Table](#comparison-table)

---

## Overview

API gateways serve as the entry point for all client requests, providing a centralized layer for handling cross-cutting concerns like security, routing, rate limiting, and monitoring. When integrating with NIP v3.0.0, the gateway acts as a reverse proxy that forwards requests to your Noodle applications while enforcing policies at the edge.

**Key Benefits:**
- **Centralized Security**: Authentication, authorization, and threat protection
- **Traffic Management**: Load balancing, rate limiting, and request routing
- **Protocol Translation**: REST to gRPC, WebSocket, or other protocols
- **Observability**: Logging, metrics, and tracing at the edge
- **API Versioning**: Route requests to different service versions

**Architecture:**
```
Clients → API Gateway → NIP Services
         ↓                    ↓
    Security Policies    Application Logic
    Rate Limiting        Business Rules
    Request Routing      Data Processing
```

---

## Kong Gateway Integration

Kong is a popular, cloud-native API gateway built on top of NGINX. It provides a flexible plugin system and excellent performance for NIP deployments.

### Installation

```bash
# Using Docker
docker network create kong-net

docker run -d --name kong \
  --network=kong-net \
  -e "KONG_DATABASE=postgres" \
  -e "KONG_PG_HOST=kong-database" \
  -e "KONG_PG_USER=kong" \
  -e "KONG_PG_PASSWORD=kong" \
  -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
  -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
  -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
  -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
  -e "KONG_ADMIN_LISTEN=0.0.0.0:8001" \
  -p 8000:8000 \
  -p 8443:8443 \
  -p 8001:8001 \
  -p 8444:8444 \
  kong:latest
```

### Configuration for NIP

**1. Register NIP Services:**

```bash
# Add NIP service to Kong
curl -i -X POST http://localhost:8001/services \
  --data name=nip-service \
  --data url=http://nip-app:8080

# Add routes
curl -i -X POST http://localhost:8001/services/nip-service/routes \
  --data paths[]=/api/v1 \
  --data strip_path=true

curl -i -X POST http://localhost:8001/services/nip-service/routes \
  --data paths[]=/api/v2 \
  --data strip_path=true
```

**2. Enable Plugins:**

```bash
# Rate limiting
curl -X POST http://localhost:8001/services/nip-service/plugins \
  --data name=rate-limiting \
  --data config.minute=100 \
  --data config.hour=1000 \
  --data config.policy=local

# JWT Authentication
curl -X POST http://localhost:8001/services/nip-service/plugins \
  --data name=jwt \
  --data config.uri_param_names=jwt

# CORS
curl -X POST http://localhost:8001/services/nip-service/plugins \
  --data name=cors \
  --data config.origins=* \
  --data config.methods=GET,POST,PUT,DELETE,OPTIONS
```

**3. Kong Configuration File (kong.conf):**

```ini
# NIP Gateway Configuration
proxy_listen = 0.0.0.0:8000, 0.0.0.0:8443 ssl
admin_listen = 0.0.0.0:8001, 0.0.0.0:8444 ssl

# Database
database = postgres
pg_host = localhost
pg_port = 5432
pg_user = kong
pg_password = kong
pg_database = kong

# Nginx worker processes for NIP
nginx_worker_processes = auto
nginx_worker_connections = 16384

# Performance tuning for NIP
client_max_body_size = 50m
client_body_timeout = 60s
client_header_timeout = 60s
keepalive_timeout = 60s
```

### Declarative Configuration

**kong.yml (Declarative Config):**

```yaml
_format_version: "3.0"

services:
  - name: nip-service-v1
    url: http://nip-app-v1:8080
    routes:
      - name: nip-v1-route
        paths:
          - /api/v1
        strip_path: true
        plugins:
          - name: rate-limiting
            config:
              minute: 100
              hour: 1000
          - name: jwt
          - name: cors
            config:
              origins:
                - "*"
              methods:
                - GET
                - POST
                - PUT
                - DELETE

  - name: nip-service-v2
    url: http://nip-app-v2:8080
    routes:
      - name: nip-v2-route
        paths:
          - /api/v2
        strip_path: true

plugins:
  - name: prometheus
    config:
      per_consumer: true
```

---

## NGINX Gateway Configuration

NGINX as a gateway provides high performance and flexibility for NIP deployments.

### Basic Configuration

**nginx.conf:**

```nginx
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 4096;
    use epoll;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for" '
                    'rt=$request_time uct="$upstream_connect_time" '
                    'uht="$upstream_header_time" urt="$upstream_response_time"';

    access_log /var/log/nginx/access.log main;

    # Performance
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 50M;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml application/json application/javascript;

    # Rate limiting zones
    limit_req_zone $binary_remote_addr zone=nip_limit:10m rate=10r/s;
    limit_conn_zone $binary_remote_addr zone=nip_conn:10m;

    # Upstream NIP services
    upstream nip_cluster {
        least_conn;
        server nip-app-1:8080 weight=3;
        server nip-app-2:8080 weight=2;
        server nip-app-3:8080 weight=1;
        keepalive 32;
    }

    # Cache zone
    proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=nip_cache:10m 
                     max_size=1g inactive=60m use_temp_path=off;

    server {
        listen 80;
        listen 443 ssl http2;
        server_name api.noodle.example.com;

        # SSL configuration
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;

        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;

        # NIP v1 API
        location /api/v1/ {
            # Rate limiting
            limit_req zone=nip_limit burst=20 nodelay;
            limit_conn nip_conn 10;

            # Proxy settings
            proxy_pass http://nip-cluster;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            # Timeouts
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;

            # Buffering
            proxy_buffering on;
            proxy_buffer_size 4k;
            proxy_buffers 8 4k;
            proxy_busy_buffers_size 8k;

            # Cache
            proxy_cache nip_cache;
            proxy_cache_valid 200 302 10m;
            proxy_cache_valid 404 1m;
            proxy_cache_bypass $http_cache_control;
            add_header X-Cache-Status $upstream_cache_status;
        }

        # NIP v2 API
        location /api/v2/ {
            proxy_pass http://nip-cluster;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        # Health check endpoint
        location /health {
            access_log off;
            proxy_pass http://nip-cluster/health;
        }

        # Nginx status for monitoring
        location /nginx_status {
            stub_status on;
            access_log off;
            allow 127.0.0.1;
            deny all;
        }
    }
}
```

### Advanced Load Balancing

```nginx
# Weighted least connections
upstream nip_weighted {
    least_conn;
    server nip-app-1:8080 weight=3;
    server nip-app-2:8080 weight=2;
    server nip-app-3:8080 weight=1;
}

# IP hash for session persistence
upstream nip_sticky {
    ip_hash;
    server nip-app-1:8080;
    server nip-app-2:8080;
}

# Least time (NGINX Plus)
upstream nip_least_time {
    least_time header;
    server nip-app-1:8080;
    server nip-app-2:8080;
}

# Health checks (NGINX Plus)
upstream nip_cluster {
    zone nip_backend 64k;
    server nip-app-1:8080 max_fails=3 fail_timeout=30s;
    server nip-app-2:8080 max_fails=3 fail_timeout=30s;
    server nip-app-3:8080 max_fails=3 fail_timeout=30s;
}
```

---

## AWS API Gateway

AWS API Gateway provides a fully managed service for creating, publishing, and securing APIs at scale.

### REST API Configuration

**Terraform Configuration:**

```hcl
resource "aws_api_gateway_rest_api" "nip_api" {
  name        = "nip-api-gateway"
  description = "API Gateway for NIP v3.0.0"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# API Resource
resource "aws_api_gateway_resource" "nip_v1" {
  rest_api_id = aws_api_gateway_rest_api.nip_api.id
  parent_id   = aws_api_gateway_rest_api.nip_api.root_resource_id
  path_part   = "v1"
}

# GET Method
resource "aws_api_gateway_method" "nip_get" {
  rest_api_id   = aws_api_gateway_rest_api.nip_api.id
  resource_id   = aws_api_gateway_resource.nip_v1.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
}

# Integration with NIP service
resource "aws_api_gateway_integration" "nip_integration" {
  rest_api_id = aws_api_gateway_rest_api.nip_api.id
  resource_id = aws_api_gateway_resource.nip_v1.id
  http_method = aws_api_gateway_method.nip_get.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  uri                     = "http://nip-app:8080/api/v1/{proxy}"

  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.nip_vpc_link.id
}

# VPC Link for private integration
resource "aws_api_gateway_vpc_link" "nip_vpc_link" {
  name        = "nip-vpc-link"
  description = "VPC link for NIP services"
  target_arns = [aws_lb.nip_alb.arn]
}

# Usage plan for rate limiting
resource "aws_api_gateway_usage_plan" "nip_usage_plan" {
  name = "nip-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.nip_api.id
    stage  = aws_api_gateway_stage.nip_stage.stage_name
  }

  throttle_settings {
    burst_limit = 100
    rate_limit  = 50
  }

  quota_settings {
    limit  = 10000
    offset = 0
    period = "MONTH"
  }
}

# API Key
resource "aws_api_gateway_api_key" "nip_api_key" {
  name = "nip-api-key"
}

# Deployment
resource "aws_api_gateway_deployment" "nip_deployment" {
  rest_api_id = aws_api_gateway_rest_api.nip_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.nip_v1.id,
      aws_api_gateway_method.nip_get.id,
      aws_api_gateway_integration.nip_integration.id,
    ]))
  }
}

resource "aws_api_gateway_stage" "nip_stage" {
  deployment_id = aws_api_gateway_deployment.nip_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.nip_api.id
  stage_name    = "prod"

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.nip_api_log.arn
    format         = jsonencode({
      requestId = "$context.requestId"
      ip        = "$context.identity.sourceIp"
      caller    = "$context.identity.caller"
      user      = "$context.identity.user"
      requestTime = "$context.requestTime"
      httpMethod   = "$context.httpMethod"
      resourcePath = "$context.resourcePath"
      status       = "$context.status"
      protocol     = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }
}
```

### Lambda Authorizer

```python
# lambda_authorizer.py
import json
import jwt

def lambda_handler(event, context):
    token = event['authorizationToken'].replace('Bearer ', '')
    
    try:
        # Verify JWT token
        decoded = jwt.decode(token, 'your-secret', algorithms=['HS256'])
        
        # Generate IAM policy
        policy = {
            'principalId': decoded['user_id'],
            'policyDocument': {
                'Version': '2012-10-17',
                'Statement': [{
                    'Action': 'execute-api:Invoke',
                    'Effect': 'Allow',
                    'Resource': event['methodArn']
                }]
            },
            'context': {
                'user_id': decoded['user_id'],
                'role': decoded.get('role', 'user')
            }
        }
        
        return policy
    except Exception as e:
        print(f'Authorization failed: {str(e)}')
        return {
            'principalId': 'user',
            'policyDocument': {
                'Version': '2012-10-17',
                'Statement': [{
                    'Action': 'execute-api:Invoke',
                    'Effect': 'Deny',
                    'Resource': event['methodArn']
                }]
            }
        }
```

---

## Azure API Management

Azure API Management provides a hybrid, multi-cloud management platform for APIs.

### ARM Template Configuration

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "apiManagementName": {
      "type": "String",
      "defaultValue": "nip-apim"
    },
    "publisherEmail": {
      "type": "String",
      "defaultValue": "admin@noodle.example.com"
    },
    "publisherName": {
      "type": "String",
      "defaultValue": "Noodle Inc"
    }
  },
  "resources": [
    {
      "type": "Microsoft.ApiManagement/service",
      "apiVersion": "2021-08-01",
      "name": "[parameters('apiManagementName')]",
      "location": "[resourceGroup().location]",
      "sku": {
        "name": "Developer",
        "capacity": 1
      },
      "properties": {
        "publisherEmail": "[parameters('publisherEmail')]",
        "publisherName": "[parameters('publisherName')]"
      }
    },
    {
      "type": "Microsoft.ApiManagement/service/apis",
      "apiVersion": "2021-08-01",
      "name": "[concat(parameters('apiManagementName'), '/nip-api')]",
      "dependsOn": [
        "[resourceId('Microsoft.ApiManagement/service', parameters('apiManagementName'))]"
      ],
      "properties": {
        "displayName": "NIP API",
        "description": "NIP v3.0.0 API",
        "path": "nip",
        "protocols": ["https"],
        "serviceUrl": "http://nip-app:8080/api"
      }
    },
    {
      "type": "Microsoft.ApiManagement/service/apis/operations",
      "apiVersion": "2021-08-01",
      "name": "[concat(parameters('apiManagementName'), '/nip-api/get-data')]",
      "dependsOn": [
        "[resourceId('Microsoft.ApiManagement/service/apis', parameters('apiManagementName'), 'nip-api')]"
      ],
      "properties": {
        "displayName": "Get Data",
        "method": "GET",
        "urlTemplate": "/v1/data",
        "description": "Retrieve data from NIP service"
      }
    },
    {
      "type": "Microsoft.ApiManagement/service/products",
      "apiVersion": "2021-08-01",
      "name": "[concat(parameters('apiManagementName'), '/nip-product')]",
      "dependsOn": [
        "[resourceId('Microsoft.ApiManagement/service', parameters('apiManagementName'))]"
      ],
      "properties": {
        "displayName": "NIP Product",
        "description": "Product for NIP API access",
        "approvalRequired": false,
        "subscriptionsLimit": 100
      }
    }
  ]
}
```

### Policies

**inbound-policy.xml:**

```xml
<policies>
    <inbound>
        <!-- Rate limiting -->
        <rate-limit calls="100" renewal-period="60" />
        
        <!-- CORS -->
        <cors>
            <allowed-origins>
                <origin>*</origin>
            </allowed-origins>
            <allowed-methods>
                <method>GET</method>
                <method>POST</method>
                <method>PUT</method>
                <method>DELETE</method>
            </allowed-methods>
            <allowed-headers>
                <header>*</header>
            </allowed-headers>
        </cors>
        
        <!-- Authentication -->
        <validate-jwt header-name="Authorization" failed-validation-httpcode="401">
            <openid-config url="https://login.microsoftonline.com/{tenant}/.well-known/openid-configuration" />
            <required-claims>
                <claim name="aud" match="all">
                    <value>nip-api</value>
                </claim>
            </required-claims>
        </validate-jwt>
        
        <!-- Rewrite path -->
        <rewrite-uri template="/api/v1{(request.path)}" copy-unmatched-params="true" />
        
        <!-- Backend authentication -->
        <authentication-managed-identity resource="api://nip-backend" />
        
        <base />
    </inbound>
    <backend>
        <forward-request timeout="180" follow-redirects="true" />
    </backend>
    <outbound>
        <set-header name="X-Powered-By" exists-action="delete" />
        <set-header name="X-Content-Type-Options" exists-action="override">
            <value>nosniff</value>
        </set-header>
    </outbound>
    <on-error>
        <base />
        <set-header name="Error-Message" exists-action="override">
            <value>@(context.LastError.Message)</value>
        </set-header>
    </on-error>
</policies>
```

---

## Request Routing & Load Balancing

Effective request routing and load balancing ensure high availability and optimal performance for NIP deployments.

### Routing Strategies

**1. Path-Based Routing**

```nginx
# NGINX path-based routing
location /api/v1/ {
    proxy_pass http://nip-v1-cluster;
}

location /api/v2/ {
    proxy_pass http://nip-v2-cluster;
}

location /internal/ {
    proxy_pass http://nip-internal;
    internal;
}
```

**2. Header-Based Routing**

```nginx
map $http_x_api_version $backend {
    default  "nip-v1-cluster";
    "2"      "nip-v2-cluster";
    "beta"   "nip-beta-cluster";
}

server {
    location /api/ {
        proxy_pass http://$backend;
    }
}
```

**3. Canary Deployments**

```nginx
upstream nip_stable {
    server nip-app-1:8080;
    server nip-app-2:8080;
}

upstream nip_canary {
    server nip-app-canary:8080;
}

# 10% traffic to canary
split_clients "${remote_addr}" $backend {
    10%      "nip_canary";
    *        "nip_stable";
}

location /api/ {
    proxy_pass http://$backend;
}
```

### Load Balancing Algorithms

**Round Robin (Default):**
```nginx
upstream nip_roundrobin {
    server nip-app-1:8080;
    server nip-app-2:8080;
    server nip-app-3:8080;
}
```

**Least Connections:**
```nginx
upstream nip_leastconn {
    least_conn;
    server nip-app-1:8080;
    server nip-app-2:8080;
}
```

**Weighted Distribution:**
```nginx
upstream nip_weighted {
    server nip-app-1:8080 weight=5;
    server nip-app-2:8080 weight=3;
    server nip-app-3:8080 weight=2;
}
```

**IP Hash (Session Persistence):**
```nginx
upstream nip_iphash {
    ip_hash;
    server nip-app-1:8080;
    server nip-app-2:8080;
}
```

---

## Rate Limiting at Gateway Level

Rate limiting protects your NIP services from abuse and ensures fair resource allocation.

### NGINX Rate Limiting

```nginx
# Define rate limit zones
http {
    # Limit requests per second
    limit_req_zone $binary_remote_addr zone=general_limit:10m rate=10r/s;
    
    # Limit concurrent connections
    limit_conn_zone $binary_remote_addr zone=conn_limit:10m;
    
    # Limit burst requests
    limit_req_zone $binary_remote_addr zone=burst_limit:10m rate=5r/s;
}

server {
    # Apply rate limiting
    location /api/v1/ {
        # 10 requests/second with burst of 20
        limit_req zone=general_limit burst=20 nodelay;
        limit_conn conn_limit 10;
        
        # Custom rate limit for authenticated users
        limit_req zone=$user_limit burst=50 nodelay;
        
        proxy_pass http://nip-cluster;
    }
    
    # Rate limiting by user
    map $http_x_user_id $user_limit {
        default "general_limit";
        "~*premium" "premium_limit";
    }
    
    limit_req_zone $user_id zone=premium_limit:10m rate=100r/s;
    
    # Custom error for rate limiting
    limit_req_status 429;
    error_page 429 =429 /rate_limited.html;
}
```

### Kong Rate Limiting

```yaml
plugins:
  - name: rate-limiting
    config:
      minute: 100              # 100 requests per minute
      hour: 1000               # 1000 requests per hour
      day: 10000               # 10000 requests per day
      policy: redis            # Redis for distributed limiting
      redis_host: redis
      redis_port: 6379
      redis_database: 0
      fault_tolerant: true

  - name: response-ratelimiting
    config:
      limits:
        - minute: 60
          hour: 600
      policy: local
      headers_are_null: false
```

### AWS API Gateway Throttling

```json
{
  "ThrottleSettings": {
    "burstLimit": 100,
    "rateLimit": 50
  },
  "QuotaSettings": {
    "limit": 10000,
    "period": "MONTH",
    "offset": 0
  }
}
```

### Advanced Rate Limiting Strategies

**1. Token Bucket Algorithm:**
```nginx
# Allow bursts while maintaining average rate
limit_req zone=api_limit burst=30 nodelay;
```

**2. Sliding Window:**
```python
# Python-based sliding window rate limiter
from collections import deque
import time

class SlidingWindowLimiter:
    def __init__(self, max_requests, window_seconds):
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self.requests = {}
    
    def is_allowed(self, key):
        now = time.time()
        if key not in self.requests:
            self.requests[key] = deque()
        
        # Remove old requests
        while self.requests[key] and self.requests[key][0] < now - self.window_seconds:
            self.requests[key].popleft()
        
        # Check if allowed
        if len(self.requests[key]) < self.max_requests:
            self.requests[key].append(now)
            return True
        return False

# Usage
limiter = SlidingWindowLimiter(max_requests=100, window_seconds=60)
if limiter.is_allowed(client_ip):
    # Process request
    pass
```

---

## Authentication & Authorization

Implement robust security at the gateway layer to protect NIP services.

### JWT Authentication

**NGINX Lua JWT Validation:**

```nginx
init_by_lua_block {
    local jwt = require "resty.jwt"
}

server {
    location /api/v1/ {
        access_by_lua_block {
            local jwt = require "resty.jwt"
            
            local auth_header = ngx.var.http_authorization
            if not auth_header then
                ngx.status = 401
                ngx.say("Missing Authorization header")
                return ngx.exit(401)
            end
            
            local _, _, token = auth_header:find("Bearer%s+(.+)")
            if not token then
                ngx.status = 401
                ngx.say("Invalid token format")
                return ngx.exit(401)
            end
            
            -- Verify JWT
            local jwt_obj = jwt:verify("your-secret", token)
            if not jwt_obj.valid then
                ngx.status = 401
                ngx.say("Invalid token: " .. jwt_obj.reason)
                return ngx.exit(401)
            end
            
            -- Set user context
            ngx.ctx.user_id = jwt_obj.payload.sub
            ngx.req.set_header("X-User-Id", jwt_obj.payload.sub)
        }
        
        proxy_pass http://nip-cluster;
    }
}
```

### OAuth 2.0 Integration

**Kong OAuth 2.0 Plugin:**

```bash
# Enable OAuth 2.0 plugin
curl -X POST http://localhost:8001/services/nip-service/plugins \
  --data name=oauth2 \
  --data config.scopes=email,profile \
  --data config.mandatory_scope=true \
  --data config.enable_authorization_code=true \
  --data config.enable_client_credentials=true \
  --data config.enable_password_grant=true \
  --data config.enable_implicit_grant=true

# Create OAuth 2.0 application
curl -X POST http://localhost:8001/consumers/default/oauth2 \
  --data name=nip-app \
  --data client_id=nip_client \
  --data client_secret=nip_secret \
  --data redirect_uris=http://example.com/callback
```

### API Key Authentication

```nginx
# Map API keys to users
map $http_x_api_key $auth_valid {
    default 0;
    "key123abc" 1;
    "key456def" 1;
}

server {
    location /api/v1/ {
        if ($auth_valid = 0) {
            return 401 "Invalid API Key";
        }
        
        proxy_pass http://nip-cluster;
    }
}
```

### Mutual TLS (mTLS)

```nginx
server {
    listen 443 ssl http2;
    server_name api.noodle.example.com;
    
    # Server certificate
    ssl_certificate /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/ssl/server.key;
    
    # Client certificate verification
    ssl_client_certificate /etc/nginx/ssl/ca.crt;
    ssl_verify_client on;
    ssl_verify_depth 2;
    
    location /api/v1/ {
        # Check client certificate
        if ($ssl_client_verify != "SUCCESS") {
            return 403 "Invalid client certificate";
        }
        
        # Pass client info to backend
        proxy_set_header X-Client-Subject-DN $ssl_client_s_dn;
        proxy_set_header X-Client-Verify $ssl_client_verify;
        
        proxy_pass http://nip-cluster;
    }
}
```

---

## API Versioning

Implement effective API versioning strategies for NIP services.

### Versioning Strategies

**1. URL Path Versioning:**

```nginx
location /api/v1/ {
    proxy_pass http://nip-v1-cluster;
}

location /api/v2/ {
    proxy_pass http://nip-v2-cluster;
}

location /api/v3/ {
    proxy_pass http://nip-v3-cluster;
}
```

**2. Header-Based Versioning:**

```nginx
map $http_x_api_version $backend {
    default        "nip-v1-cluster";
    "2"            "nip-v2-cluster";
    "3"            "nip-v3-cluster";
}

server {
    location /api/ {
        proxy_pass http://$backend;
    }
}
```

**3. Query Parameter Versioning:**

```nginx
map $arg_version $backend {
    default        "nip-v1-cluster";
    "2"            "nip-v2-cluster";
    "3"            "nip-v3-cluster";
}

server {
    location /api/ {
        proxy_pass http://$backend;
    }
}
```

### Version Routing Configuration

**Kong Versioning:**

```yaml
services:
  - name: nip-v1
    url: http://nip-v1:8080
    routes:
      - name: v1-route
        paths:
          - /v1
        strip_path: true
        tags:
          - version:1
          - deprecated

  - name: nip-v2
    url: http://nip-v2:8080
    routes:
      - name: v2-route
        paths:
          - /v2
        strip_path: true
        tags:
          - version:2
          - stable

  - name: nip-v3
    url: http://nip-v3:8080
    routes:
      - name: v3-route
        paths:
          - /v3
        strip_path: true
        tags:
          - version:3
          - latest
```

### Deprecation Strategy

```nginx
# Add deprecation headers for old versions
location /api/v1/ {
    add_header X-API-Deprecated "true";
    add_header X-API-Sunset "2026-12-31";
    add_header X-API-Alternate-Version "2, 3";
    add_header X-API-Upgrade-Path "/api/v2/";
    
    proxy_pass http://nip-v1-cluster;
}
```

---

## Practical Exercises

### Exercise 1: Set Up Kong Gateway for NIP

**Objective**: Configure Kong Gateway with rate limiting and JWT authentication.

**Steps**:
1. Deploy Kong using Docker
2. Register your NIP service
3. Configure rate limiting (100 req/min)
4. Enable JWT authentication
5. Test the configuration

**Solution**:
```bash
# Deploy Kong
docker run -d --name kong \
  -e "KONG_DATABASE=off" \
  -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
  -p 8000:8000 \
  -p 8443:8443 \
  kong:kong-alpine

# Add service
curl -i -X POST http://localhost:8001/services \
  --data name=nip-service \
  --data url=http://localhost:8080

# Add route
curl -i -X POST http://localhost:8001/services/nip-service/routes \
  --data paths[]=/api

# Add rate limiting
curl -X POST http://localhost:8001/services/nip-service/plugins \
  --data name=rate-limiting \
  --data config.minute=100

# Test
for i in {1..150}; do
  curl http://localhost:8000/api/data
done
```

### Exercise 2: Configure NGINX Load Balancing

**Objective**: Set up NGINX with weighted load balancing for 3 NIP instances.

**Solution**:
```nginx
upstream nip_cluster {
    least_conn;
    server nip-1:8080 weight=3 max_fails=3 fail_timeout=30s;
    server nip-2:8080 weight=2 max_fails=3 fail_timeout=30s;
    server nip-3:8080 weight=1 max_fails=3 fail_timeout=30s;
}

server {
    listen 80;
    
    location /api/ {
        proxy_pass http://nip_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Exercise 3: Implement Canary Deployment

**Objective**: Route 20% of traffic to a canary version.

**Solution**:
```nginx
split_clients "${remote_addr}" $backend {
    20%     "nip_canary";
    *       "nip_stable";
}

upstream nip_stable {
    server nip-stable-1:8080;
    server nip-stable-2:8080;
}

upstream nip_canary {
    server nip-canary:8080;
}

server {
    location /api/ {
        proxy_pass http://$backend;
    }
}
```

---

## Best Practices

### 1. Gateway Configuration
- **Use declarative configuration** for version control
- **Separate environments** (dev, staging, prod)
- **Enable caching** for read-heavy endpoints
- **Configure proper timeouts** for long-running requests
- **Monitor gateway metrics** (latency, error rates, throughput)

### 2. Security
- **Always use HTTPS** in production
- **Implement rate limiting** at multiple levels
- **Validate JWT tokens** at the gateway
- **Use mTLS** for service-to-service communication
- **Rotate secrets** regularly

### 3. Performance
- **Enable HTTP/2** for improved performance
- **Configure proper keep-alive** settings
- **Use connection pooling** to backend services
- **Optimize buffer sizes** based on payload
- **Enable compression** for API responses

### 4. Observability
- **Log all requests** with unique correlation IDs
- **Distribute tracing** across services
- **Collect metrics** at the gateway level
- **Set up alerts** for error rates and latency
- **Create dashboards** for monitoring

### 5. High Availability
- **Deploy multiple gateway instances** behind a load balancer
- **Use health checks** to detect failed instances
- **Configure auto-scaling** based on traffic
- **Implement circuit breakers** for backend services
- **Test failover scenarios** regularly

---

## Comparison Table

| Feature | Kong Gateway | NGINX | AWS API Gateway | Azure APIM |
|---------|--------------|-------|-----------------|------------|
| **Type** | Open Source | Open Source | Managed Service | Managed Service |
| **Deployment** | Self-hosted | Self-hosted | Cloud-only | Cloud + Hybrid |
| **Cost** | Free (self-hosted) | Free (self-hosted) | Pay-per-request | Tiered pricing |
| **Extensibility** | Plugin ecosystem | Lua scripting | Lambda integration | Policies |
| **Performance** | High | Very High | High | High |
| **Setup Complexity** | Medium | Medium | Low | Medium |
| **Rate Limiting** | ✓ Native | ✓ Native | ✓ Native | ✓ Native |
| **JWT Auth** | ✓ Plugin | ✓ Lua required | ✓ Native | ✓ Native |
| **OAuth 2.0** | ✓ Plugin | Config required | ✓ Native | ✓ Native |
| **Monitoring** | ✓ Built-in | ✓ Basic | ✓ CloudWatch | ✓ Azure Monitor |
| **Developer Portal** | ✓ Available | ✗ Separate | ✓ Native | ✓ Native |
| **Documentation** | ✓ Built-in | ✗ Separate | ✓ Swagger import | ✓ Swagger import |
| **Versioning** | ✓ Flexible | ✓ Flexible | ✓ Stages | ✓ Revisions |
| **Caching** | ✓ Plugin | ✓ Native | ✓ Native | ✓ Native |
| **WebSockets** | ✓ Native | ✓ Native | ✓ Native | ✓ Native |
| **gRPC Support** | ✓ Plugin | ✓ Native | ✓ Native | ✓ Native |
| **CLI** | ✓ Kong CLI | nginx command | AWS CLI | Azure CLI |
| **IaC Support** | ✓ Terraform/Ansible | ✓ Terraform/Ansible | ✓ CloudFormation | ✓ ARM Templates |

---

## Next Steps

- **Tutorial 12**: Advanced Security Patterns
- **Tutorial 13**: Performance Optimization
- **Tutorial 14**: Disaster Recovery Planning

---

## Additional Resources

- [Kong Documentation](https://docs.konghq.com/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [AWS API Gateway](https://docs.aws.amazon.com/apigateway/)
- [Azure API Management](https://docs.microsoft.com/azure/api-management/)
- [NIP Documentation](https://noodle.example.com/docs)

---

**Tutorial Version**: 1.0.0  
**Last Updated**: 2026-01-17  
**Author**: Noodle Documentation Team  
**License**: MIT

---

**← Previous Tutorial**: [10-Service-Mesh](../10-service-mesh/README.md)  
**Next Tutorial →**: [12-Advanced-Security](../12-advanced-security/README.md)
