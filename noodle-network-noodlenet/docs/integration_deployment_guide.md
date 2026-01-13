# NoodleVision Integration and Deployment Guide

This guide provides comprehensive instructions for integrating NoodleVision into your applications and deploying it in production environments.

## Table of Contents

1. [Integration Strategies](#integration-strategies)
2. [Application Integration](#application-integration)
3. [Deployment Options](#deployment-options)
4. [Containerization](#containerization)
5. [Cloud Deployment](#cloud-deployment)
6. [Monitoring and Logging](#monitoring-and-logging)
7. [Performance Optimization](#performance-optimization)
8. [Security Considerations](#security-considerations)
9. [Maintenance and Updates](#maintenance-and-updates)

## Integration Strategies

### 1. Direct Integration

Integrate NoodleVision directly into your Python application:

```python
# Import NoodleVision modules
import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'vision'))

from ops_audio import SpectrogramOperator, MFCCOperator, ChromaOperator, TonnetzOperator
from memory import MemoryManager, MemoryPolicy

class MyAudioApplication:
    def __init__(self):
        # Initialize NoodleVision components
        self.memory_manager = MemoryManager(policy=MemoryPolicy.BALANCED)
        self.operators = {
            'spectrogram': SpectrogramOperator(),
            'mfcc': MFCCOperator(n_mfcc=13),
            'chroma': ChromaOperator(),
            'tonnetz': TonnetzOperator()
        }
    
    def process_audio(self, audio):
        """Process audio using NoodleVision"""
        features = {}
        for name, operator in self.operators.items():
            try:
                feature = operator(audio)
                features[name] = feature
            except Exception as e:
                print(f"Error processing {name}: {e}")
                features[name] = None
        return features
```

### 2. Service Integration

Deploy NoodleVision as a microservice:

```python
# audio_service.py
from fastapi import FastAPI, HTTPException
import numpy as np
from typing import Dict, Any
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'vision'))

from ops_audio import SpectrogramOperator, MFCCOperator, ChromaOperator, TonnetzOperator
from memory import MemoryManager, MemoryPolicy

app = FastAPI(title="NoodleVision Audio Service")

# Initialize NoodleVision
memory_manager = MemoryManager(policy=MemoryPolicy.BALANCED)
operators = {
    'spectrogram': SpectrogramOperator(),
    'mfcc': MFCCOperator(n_mfcc=13),
    'chroma': ChromaOperator(),
    'tonnetz': TonnetzOperator()
}

@app.post("/extract-features/")
async def extract_features(audio_data: Dict[str, Any]):
    """Extract audio features from provided audio data"""
    try:
        # Extract audio from request
        audio = np.array(audio_data['audio'])
        sample_rate = audio_data.get('sample_rate', 22050)
        
        # Process audio
        features = {}
        for name, operator in operators.items():
            feature = operator(audio)
            features[name] = feature.tolist()
        
        return {
            "success": True,
            "features": features,
            "sample_rate": sample_rate
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

### 3. Plugin Integration

Create NoodleVision as a plugin for existing applications:

```python
# noodlevision_plugin.py
import numpy as np
from abc import ABC, abstractmethod
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'vision'))

from ops_audio import SpectrogramOperator, MFCCOperator, ChromaOperator, TonnetzOperator
from memory import MemoryManager, MemoryPolicy

class AudioProcessorPlugin(ABC):
    """Abstract base class for audio processing plugins"""
    
    @abstractmethod
    def process_audio(self, audio):
        """Process audio and return features"""
        pass

class NoodleVisionPlugin(AudioProcessorPlugin):
    """NoodleVision plugin implementation"""
    
    def __init__(self, memory_policy=MemoryPolicy.BALANCED):
        self.memory_manager = MemoryManager(policy=memory_policy)
        self.operators = {
            'spectrogram': SpectrogramOperator(),
            'mfcc': MFCCOperator(n_mfcc=13),
            'chroma': ChromaOperator(),
            'tonnetz': TonnetzOperator()
        }
    
    def process_audio(self, audio):
        """Process audio using NoodleVision"""
        features = {}
        for name, operator in self.operators.items():
            try:
                feature = operator(audio)
                features[name] = feature
            except Exception as e:
                print(f"Error processing {name}: {e}")
                features[name] = None
        return features
    
    def cleanup(self):
        """Clean up resources"""
        self.memory_manager.cleanup()

# Usage in host application
class AudioApplication:
    def __init__(self):
        self.plugin = NoodleVisionPlugin()
    
    def analyze_audio(self, audio_file):
        """Analyze audio file using the plugin"""
        # Load audio (simplified)
        audio = self.load_audio(audio_file)
        
        # Process using plugin
        features = self.plugin.process_audio(audio)
        
        return features
    
    def load_audio(self, file_path):
        """Load audio file"""
        # Implementation would depend on your audio library
        return np.random.randn(22050)  # Placeholder
```

## Application Integration

### 1. Web Application Integration

Integrate NoodleVision into a web application using Flask:

```python
# app.py
from flask import Flask, request, jsonify
import numpy as np
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'vision'))

from ops_audio import SpectrogramOperator, MFCCOperator, ChromaOperator, TonnetzOperator
from memory import MemoryManager, MemoryPolicy

app = Flask(__name__)

# Initialize NoodleVision
memory_manager = MemoryManager(policy=MemoryPolicy.BALANCED)
operators = {
    'spectrogram': SpectrogramOperator(),
    'mfcc': MFCCOperator(n_mfcc=13),
    'chroma': ChromaOperator(),
    'tonnetz': TonnetzOperator()
}

@app.route('/api/extract-features', methods=['POST'])
def extract_features():
    """Extract audio features from uploaded audio"""
    try:
        if 'audio' not in request.files:
            return jsonify({'error': 'No audio file provided'}), 400
        
        audio_file = request.files['audio']
        audio_data = np.frombuffer(audio_file.read(), dtype=np.float64)
        
        # Process audio
        features = {}
        for name, operator in operators.items():
            feature = operator(audio_data)
            features[name] = feature.tolist()
        
        return jsonify({
            'success': True,
            'features': features,
            'audio_length': len(audio_data)
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
```

### 2. Desktop Application Integration

Integrate NoodleVision into a desktop application using PyQt:

```python
# audio_analyzer.py
import sys
import numpy as np
from PyQt5.QtWidgets import QApplication, QMainWindow, QPushButton, QVBoxLayout, QWidget, QTextEdit
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'vision'))

from ops_audio import SpectrogramOperator, MFCCOperator, ChromaOperator, TonnetzOperator
from memory import MemoryManager, MemoryPolicy

class AudioAnalyzerWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("NoodleVision Audio Analyzer")
        self.setGeometry(100, 100, 800, 600)
        
        # Initialize NoodleVision
        self.memory_manager = MemoryManager(policy=MemoryPolicy.BALANCED)
        self.operators = {
            'spectrogram': SpectrogramOperator(),
            'mfcc': MFCCOperator(n_mfcc=13),
            'chroma': ChromaOperator(),
            'tonnetz': TonnetzOperator()
        }
        
        # Create UI
        self.init_ui()
    
    def init_ui(self):
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        
        layout = QVBoxLayout()
        
        # Analyze button
        self.analyze_button = QPushButton("Analyze Audio")
        self.analyze_button.clicked.connect(self.analyze_audio)
        layout.addWidget(self.analyze_button)
        
        # Results text area
        self.results_text = QTextEdit()
        self.results_text.setReadOnly(True)
        layout.addWidget(self.results_text)
        
        central_widget.setLayout(layout)
    
    def analyze_audio(self):
        """Generate and analyze test audio"""
        try:
            # Generate test audio
            audio = self.generate_test_audio()
            
            # Process audio
            features = {}
            for name, operator in self.operators.items():
                feature = operator(audio)
                features[name] = feature
            
            # Display results
            self.display_results(features)
            
        except Exception as e:
            self.results_text.setText(f"Error: {str(e)}")
    
    def generate_test_audio(self):
        """Generate test audio signal"""
        duration = 5.0
        sample_rate = 22050
        t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
        
        # Generate complex audio
        audio = (
            0.5 * np.sin(2 * np.pi * 440 * t) +
            0.3 * np.sin(2 * np.pi * 880 * t) +
            0.2 * np.sin(2 * np.pi * 220 * t) +
            0.1 * np.random.randn(len(t))
        )
        
        return audio / np.max(np.abs(audio))
    
    def display_results(self, features):
        """Display analysis results"""
        result_text = "Analysis Results:\n\n"
        
        for name, feature in features.items():
            result_text += f"{name}:\n"
            result_text += f"  Shape: {feature.shape}\n"
            result_text += f"  Mean: {np.mean(feature):.3f}\n"
            result_text += f"  Std: {np.std(feature):.3f}\n\n"
        
        self.results_text.setText(result_text)

if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = AudioAnalyzerWindow()
    window.show()
    sys.exit(app.exec_())
```

### 3. Command Line Interface

Create a CLI tool for NoodleVision:

```python
# noodlevision_cli.py
import argparse
import numpy as np
import json
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'vision'))

from ops_audio import SpectrogramOperator, MFCCOperator, ChromaOperator, TonnetzOperator
from memory import MemoryManager, MemoryPolicy

def generate_test_audio(duration=5.0, sample_rate=22050):
    """Generate test audio signal"""
    t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
    
    audio = (
        0.5 * np.sin(2 * np.pi * 440 * t) +
        0.3 * np.sin(2 * np.pi * 880 * t) +
        0.2 * np.sin(2 * np.pi * 220 * t) +
        0.1 * np.random.randn(len(t))
    )
    
    return audio / np.max(np.abs(audio))

def main():
    parser = argparse.ArgumentParser(description='NoodleVision CLI Tool')
    parser.add_argument('--mode', choices=['demo', 'benchmark'], default='demo',
                       help='Operation mode')
    parser.add_argument('--output', type=str, help='Output file path')
    parser.add_argument('--policy', choices=['conservative', 'balanced', 'aggressive_reuse', 
                                           'quality_first', 'latency_first'], 
                       default='balanced', help='Memory policy')
    
    args = parser.parse_args()
    
    # Initialize NoodleVision
    memory_policy = MemoryPolicy[args.policy.upper()]
    memory_manager = MemoryManager(policy=memory_policy)
    
    operators = {
        'spectrogram': SpectrogramOperator(),
        'mfcc': MFCCOperator(n_mfcc=13),
        'chroma': ChromaOperator(),
        'tonnetz': TonnetzOperator()
    }
    
    if args.mode == 'demo':
        # Demo mode
        print("Running NoodleVision demo...")
        
        # Generate test audio
        audio = generate_test_audio()
        
        # Extract features
        features = {}
        for name, operator in operators.items():
            try:
                feature = operator(audio)
                features[name] = {
                    'shape': feature.shape,
                    'mean': float(np.mean(feature)),
                    'std': float(np.std(feature))
                }
                print(f"✓ {name}: {feature.shape}")
            except Exception as e:
                print(f"✗ {name} failed: {e}")
        
        # Output results
        if args.output:
            with open(args.output, 'w') as f:
                json.dump(features, f, indent=2)
            print(f"Results saved to {args.output}")
        
        # Memory statistics
        stats = memory_manager.get_statistics()
        print(f"\nMemory Statistics:")
        print(f"  CPU usage: {stats['cpu_pool']['usage_percentage']:.1f}%")
        print(f"  GPU usage: {stats['gpu_pool']['usage_percentage']:.1f}%")
        print(f"  Cache efficiency: {stats['cache_stats']['cache_efficiency']:.2f}")
    
    elif args.mode == 'benchmark':
        # Benchmark mode
        print("Running NoodleVision benchmark...")
        
        iterations = 10
        times = []
        
        for i in range(iterations):
            start_time = time.time()
            
            # Process audio
            for name, operator in operators.items():
                feature = operator(audio)
            
            end_time = time.time()
            times.append(end_time - start_time)
        
        avg_time = np.mean(times)
        std_time = np.std(times)
        
        print(f"\nBenchmark Results ({iterations} iterations):")
        print(f"  Average time: {avg_time:.3f}s ± {std_time:.3f}")
        print(f"  Throughput: {1/avg_time:.2f} audio files/second")
    
    # Cleanup
    memory_manager.cleanup()

if __name__ == '__main__':
    import time
    main()
```

## Deployment Options

### 1. Local Deployment

Deploy NoodleVision locally on a workstation or server:

```bash
# Create deployment directory
mkdir -p /opt/noodlevision
cd /opt/noodlevision

# Copy NoodleVision files
cp -r /path/to/noodlenet/* .

# Create virtual environment
python -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Create service file
sudo tee /etc/systemd/system/noodlevision.service > /dev/null <<EOF
[Unit]
Description=NoodleVision Audio Processing Service
After=network.target

[Service]
Type=simple
User=noodlevision
WorkingDirectory=/opt/noodlevision
Environment=PATH=/opt/noodlevision/venv/bin
ExecStart=/opt/noodlevision/venv/bin/python audio_service.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Create user and set permissions
sudo useradd -r -s /bin/false noodlevision
sudo chown -R noodlevision:noodlevision /opt/noodlevision

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable noodlevision
sudo systemctl start noodlevision

# Check status
sudo systemctl status noodlevision
```

### 2. Docker Deployment

Create a Docker container for NoodleVision:

```dockerfile
# Dockerfile
FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy NoodleVision source code
COPY . .

# Create non-root user
RUN useradd -m -u 1000 noodlevision
USER noodlevision

# Expose port for API service
EXPOSE 8000

# Default command
CMD ["python", "audio_service.py"]
```

Build and run the Docker container:

```bash
# Build image
docker build -t noodlevision:latest .

# Run container
docker run -d \
  --name noodlevision \
  -p 8000:8000 \
  -v /path/to/audio:/app/audio \
  noodlevision:latest

# Or use docker-compose
version: '3.8'

services:
  noodlevision:
    build: .
    ports:
      - "8000:8000"
    volumes:
      - ./audio:/app/audio
    environment:
      - NOODLEVISION_MEMORY_POLICY=balanced
    restart: unless-stopped
```

### 3. Kubernetes Deployment

Deploy NoodleVision on Kubernetes:

```yaml
# noodlevision-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: noodlevision
  labels:
    app: noodlevision
spec:
  replicas: 3
  selector:
    matchLabels:
      app: noodlevision
  template:
    metadata:
      labels:
        app: noodlevision
    spec:
      containers:
      - name: noodlevision
        image: noodlevision:latest
        ports:
        - containerPort: 8000
        env:
        - name: NOODLEVISION_MEMORY_POLICY
          value: "balanced"
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        volumeMounts:
        - name: audio-storage
          mountPath: /app/audio
      volumes:
      - name: audio-storage
        persistentVolumeClaim:
          claimName: audio-pvc

---
apiVersion: v1
kind: Service
metadata:
  name: noodlevision-service
spec:
  selector:
    app: noodlevision
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8000
  type: LoadBalancer

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: audio-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

Apply the deployment:

```bash
kubectl apply -f noodlevision-deployment.yaml
kubectl get pods
kubectl get services
```

## Containerization

### 1. Multi-stage Docker Build

Create optimized Docker images:

```dockerfile
# Multi-stage Dockerfile
FROM python:3.9-slim as builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Runtime stage
FROM python:3.9-slim

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -u 1000 noodlevision

# Copy installed packages from builder
COPY --from=builder /root/.local /home/noodlevision/.local
ENV PATH=/home/noodlevision/.local/bin:$PATH

# Copy application code
COPY --chown=noodlevision:noodlevision . .

# Switch to non-root user
USER noodlevision

# Create directories
RUN mkdir -p /app/audio/input /app/audio/output

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Default command
CMD ["python", "audio_service.py"]
```

### 2. Docker Compose with Multiple Services

Create a complete audio processing pipeline:

```yaml
# docker-compose.yml
version: '3.8'

services:
  # NoodleVision API service
  noodlevision-api:
    build: .
    ports:
      - "8000:8000"
    environment:
      - NOODLEVISION_MEMORY_POLICY=balanced
      - REDIS_URL=redis://redis:6379
    volumes:
      - ./audio:/app/audio
    depends_on:
      - redis
    restart: unless-stopped

  # Redis for caching
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    restart: unless-stopped

  # PostgreSQL for storing results
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: noodlevision
      POSTGRES_USER: noodlevision
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  # Nginx reverse proxy
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - noodlevision-api
    restart: unless-stopped

  # Monitoring with Prometheus and Grafana
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
    restart: unless-stopped

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
    restart: unless-stopped

volumes:
  redis_data:
  postgres_data:
  grafana_data:
```

## Cloud Deployment

### 1. AWS Deployment

Deploy NoodleVision on AWS:

```python
# cloudformation-template.yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'NoodleVision CloudFormation Template'

Parameters:
  Environment:
    Type: String
    Default: production
    Description: 'Environment name'

  InstanceType:
    Type: String
    Default: t3.medium
    Description: 'EC2 instance type'

Resources:
  # VPC
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
      EnableDnsHostnames: true
      EnableDnsSupport: true
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-vpc'

  # Subnets
  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.1.0/24
      AvailabilityZone: !Select [ 0, !GetAZs '' ]
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-public-subnet-1'

  # Security Group
  SecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: 'Allow HTTP and SSH'
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 0.0.0.0/0

  # EC2 Instance
  EC2Instance:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: !Ref InstanceType
      SubnetId: !Ref PublicSubnet1
      SecurityGroupIds:
        - !Ref SecurityGroup
      KeyName: !Ref KeyName
      UserData:
        Fn::Base64: !Sub |
          #!/bin/bash -xe
          # Install Docker
          apt-get update
          apt-get install -y docker.io
          usermod -aG docker ubuntu
          
          # Install Docker Compose
          curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
          chmod +x /usr/local/bin/docker-compose
          
          # Start Docker service
          service docker start
          
          # Deploy NoodleVision
          cd /home/ubuntu
          git clone https://github.com/your-org/noodlenet.git
          cd noodlenet
          docker-compose up -d

  # Application Load Balancer
  LoadBalancer:
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
    Properties:
      Name: !Sub '${Environment}-alb'
      Subnets:
        - !Ref PublicSubnet1
      Scheme: internet-facing
      Type: application
      IpAddressType: ipv4

  # Target Group
  TargetGroup:
    Type: AWS::ElasticLoadBalancingV2::TargetGroup
    Properties:
      Name: !Sub '${Environment}-tg'
      Port: 8000
      Protocol: HTTP
      VpcId: !Ref VPC
      HealthCheckPath: /health
      HealthCheckProtocol: HTTP
      HealthCheckIntervalSeconds: 30
      HealthCheckTimeoutSeconds: 5
      HealthyThresholdCount: 2
      UnhealthyThresholdCount: 2

  # Listener
  Listener:
    Type: AWS::ElasticLoadBalancingV2::Listener
    Properties:
      DefaultActions:
        - Type: forward
          TargetGroupArn: !Ref TargetGroup
      LoadBalancerArn: !Ref LoadBalancer
      Port: 80
      Protocol: HTTP

Outputs:
  LoadBalancerDNS:
    Description: 'DNS name of the load balancer'
    Value: !GetAtt LoadBalancer.DNSName
    Export:
      Name: !Sub '${Environment}-LoadBalancerDNS'
```

### 2. Google Cloud Platform Deployment

Deploy NoodleVision on GCP:

```python
# main.tf
variable "project" {
  description = "Your GCP project ID"
  type        = string
}

variable "region" {
  description = "Region to deploy resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zone to deploy VM instance"
  type        = string
  default     = "us-central1-a"
}

provider "google" {
  project = var.project
  region  = var.region
}

# VPC Network
resource "google_compute_network" "vpc_network" {
  name                    = "noodlevision-network"
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "noodlevision-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

# Firewall Rules
resource "google_compute_firewall" "http_rule" {
  name    = "allow-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "https_rule" {
  name    = "allow-https"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Compute Instance
resource "google_compute_instance" "noodlevision_vm" {
  name         = "noodlevision-vm"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.name
    # Access to the public internet
    access_config {}
  }

  metadata = {
    startup-script = <<-EOF
      #!/bin/bash
      # Install Docker
      apt-get update
      apt-get install -y docker.io
      usermod -aG docker ubuntu
      
      # Install Docker Compose
      curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      chmod +x /usr/local/bin/docker-compose
      
      # Start Docker service
      service docker start
      
      # Deploy NoodleVision
      cd /home/ubuntu
      git clone https://github.com/your-org/noodlenet.git
      cd noodlenet
      docker-compose up -d
    EOF
  }

  labels = {
    environment = "production"
  }
}

# Static IP
resource "google_compute_address" "static_ip" {
  name = "noodlevision-ip"
}

# Outputs
output "instance_ip" {
  value = google_compute_instance.noodlevision_vm.network_interface.0.access_config.0.nat_ip
}

output "static_ip" {
  value = google_compute_address.static_ip.address
}
```

### 3. Azure Deployment

Deploy NoodleVision on Azure:

```python
# azuredeploy.json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]"
    },
    "vmSize": {
      "type": "string",
      "defaultValue": "Standard_DS1_v2",
      "allowedValues": [
        "Standard_DS1_v2",
        "Standard_DS2_v2",
        "Standard_DS3_v2"
      ]
    },
    "adminUsername": {
      "type": "string",
      "metadata": {
        "description": "Admin username for the VM"
      }
    },
    "adminPassword": {
      "type": "securestring",
      "metadata": {
        "description": "Admin password for the VM"
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.Network/virtualNetworks",
      "apiVersion": "2021-02-01",
      "name": "noodlevision-vnet",
      "location": "[parameters('location')]",
      "properties": {
        "addressSpace": {
          "addressPrefixes": [
            "10.0.0.0/16"
          ]
        },
        "subnets": [
          {
            "name": "noodlevision-subnet",
            "properties": {
              "addressPrefix": "10.0.0.0/24"
            }
          }
        ]
      }
    },
    {
      "type": "Microsoft.Network/networkInterfaces",
      "apiVersion": "2021-02-01",
      "name": "noodlevision-nic",
      "location": "[parameters('location')]",
      "dependsOn": [
        "[resourceId('Microsoft.Network/virtualNetworks', 'noodlevision-vnet')]"
      ],
      "properties": {
        "ipConfigurations": [
          {
            "name": "ipconfig",
            "properties": {
              "privateIPAllocationMethod": "Dynamic",
              "subnet": {
                "id": "[resourceId('Microsoft.Network/virtualNetworks/subnets', 'noodlevision-vnet', 'noodlevision-subnet')]"
              }
            }
          }
        ]
      }
    },
    {
      "type": "Microsoft.Compute/virtualMachines",
      "apiVersion": "2021-03-01",
      "name": "noodlevision-vm",
      "location": "[parameters('location')]",
      "dependsOn": [
        "[resourceId('Microsoft.Network/networkInterfaces', 'noodlevision-nic')]"
      ],
      "properties": {
        "hardwareProfile": {
          "vmSize": "[parameters('vmSize')]"
        },
        "storageProfile": {
          "imageReference": {
            "publisher": "Debian",
            "offer": "debian-11",
            "sku": "11",
            "version": "latest"
          },
          "osDisk": {
            "createOption": "FromImage",
            "caching": "ReadWrite",
            "managedDisk": {
              "storageAccountType": "Standard_LRS"
            }
          }
        },
        "osProfile": {
          "computerName": "noodlevision-vm",
          "adminUsername": "[parameters('adminUsername')]",
          "adminPassword": "[parameters('adminPassword')]",
          "customData": "[base64('#!/bin/bash\nset -e\n\n# Install Docker\napt-get update\napt-get install -y docker.io\nusermod -aG docker ${adminUsername}\n\n# Install Docker Comncurl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose\nchmod +x /usr/local/bin/docker-compose\n\n# Start Docker service\nsystemctl start docker\nsystemctl enable docker\n\n# Deploy NoodleVision\ncd /home/${adminUsername}\ngit clone https://github.com/your-org/noodlenet.git\ncd noodlenet\ndocker-compose up -d\n')]"
        },
        "networkProfile": {
          "networkInterfaces": [
            {
              "id": "[resourceId('Microsoft.Network/networkInterfaces', 'noodlevision-nic')]"
            }
          ]
        }
      }
    },
    {
      "type": "Microsoft.Network/publicIPAddresses",
      "apiVersion": "2021-02-01",
      "name": "noodlevision-pip",
      "location": "[parameters('location')]",
      "properties": {
        "publicIPAllocationMethod": "Static"
      },
      "dependsOn": [
        "[resourceId('Microsoft.Compute/virtualMachines', 'noodlevision-vm')]"
      ]
    },
    {
      "type": "Microsoft.Network/networkSecurityGroups",
      "apiVersion": "2021-02-01",
      "name": "noodlevision-nsg",
      "location": "[parameters('location')]",
      "properties": {
        "securityRules": [
          {
            "name": "AllowHTTP",
            "properties": {
              "protocol": "TCP",
              "sourceAddressPrefix": "*",
              "sourcePortRange": "*",
              "destinationAddressPrefix": "*",
              "destinationPortRange": "80",
              "access": "Allow",
              "priority": 100,
              "direction": "Inbound"
            }
          },
          {
            "name": "AllowSSH",
            "properties": {
              "protocol": "TCP",
              "sourceAddressPrefix": "*",
              "sourcePortRange": "*",
              "destinationAddressPrefix": "*",
              "destinationPortRange": "22",
              "access": "Allow",
              "priority": 110,
              "direction": "Inbound"
            }
          }
        ]
      }
    }
  ]
}
```

## Monitoring and Logging

### 1. Application Monitoring

Set up monitoring for NoodleVision:

```python
# monitoring.py
import time
import psutil
import logging
from typing import Dict, Any
from collections import defaultdict
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'vision'))

from memory import MemoryManager, MemoryPolicy

class NoodleVisionMonitor:
    def __init__(self, memory_manager: MemoryManager):
        self.memory_manager = memory_manager
        self.metrics = defaultdict(list)
        self.logger = logging.getLogger(__name__)
        
        # Configure logging
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('noodlevision.log'),
                logging.StreamHandler()
            ]
        )
    
    def collect_system_metrics(self) -> Dict[str, Any]:
        """Collect system metrics"""
        metrics = {
            'timestamp': time.time(),
            'cpu_percent': psutil.cpu_percent(),
            'memory_percent': psutil.virtual_memory().percent,
            'disk_usage': psutil.disk_usage('/').percent,
            'network_io': psutil.net_io_counters()._asdict(),
            'process_info': {
                'memory_rss': psutil.Process().memory_info().rss,
                'cpu_percent': psutil.Process().cpu_percent()
            }
        }
        
        # Collect NoodleVision specific metrics
        stats = self.memory_manager.get_statistics()
        metrics.update({
            'noodlevision_memory': {
                'cpu_usage': stats['cpu_pool']['usage_percentage'],
                'gpu_usage': stats['gpu_pool']['usage_percentage'],
                'cache_efficiency': stats['cache_stats']['cache_efficiency'],
                'allocations_count': stats['allocations_count']
            }
        })
        
        return metrics
    
    def record_operation(self, operation: str, duration: float, success: bool = True):
        """Record operation metrics"""
        self.metrics[operation].append({
            'timestamp': time.time(),
            'duration': duration,
            'success': success
        })
        
        self.logger.info(f"Operation {operation}: {duration:.3f}s (success: {success})")
    
    def get_average_time(self, operation: str) -> float:
        """Get average time for operation"""
        if operation in self.metrics and self.metrics[operation]:
            durations = [m['duration'] for m in self.metrics[operation]]
            return sum(durations) / len(durations)
        return 0.0
    
    def get_success_rate(self, operation: str) -> float:
        """Get success rate for operation"""
        if operation in self.metrics and self.metrics[operation]:
            total = len(self.metrics[operation])
            successful = sum(1 for m in self.metrics[operation] if m['success'])
            return successful / total if total > 0 else 0.0
        return 0.0
    
    def generate_report(self) -> Dict[str, Any]:
        """Generate monitoring report"""
        report = {
            'system_metrics': self.collect_system_metrics(),
            'operations': {}
        }
        
        for operation in self.metrics:
            report['operations'][operation] = {
                'count': len(self.metrics[operation]),
                'average_time': self.get_average_time(operation),
                'success_rate': self.get_success_rate(operation)
            }
        
        return report
    
    def log_alert(self, message: str, level: str = 'WARNING'):
        """Log alert message"""
        if level == 'ERROR':
            self.logger.error(message)
        elif level == 'WARNING':
            self.logger.warning(message)
        else:
            self.logger.info(message)

# Usage
memory_manager = MemoryManager(policy=MemoryPolicy.BALANCED)
monitor = NoodleVisionMonitor(memory_manager)

# Example usage
start_time = time.time()
# Perform some operation
duration = time.time() - start_time
monitor.record_operation('feature_extraction', duration, success=True)

# Generate report
report = monitor.generate_report()
print(f"Monitoring report: {report}")
```

### 2. Logging Configuration

Configure advanced logging for NoodleVision:

```python
# logging_config.py
import logging
import logging.handlers
import os
from typing import Dict, Any
import json
from datetime import datetime

class NoodleVisionLogger:
    def __init__(self, log_dir: str = 'logs'):
        self.log_dir = log_dir
        self.ensure_log_directory()
        
        # Create loggers
        self.setup_loggers()
    
    def ensure_log_directory(self):
        """Ensure log directory exists"""
        os.makedirs(self.log_dir, exist_ok=True)
    
    def setup_loggers(self):
        """Setup all loggers"""
        # Main application logger
        self.app_logger = logging.getLogger('noodlevision')
        self.app_logger.setLevel(logging.INFO)
        
        # Create formatter
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        
        # Console handler
        console_handler = logging.StreamHandler()
        console_handler.setFormatter(formatter)
        self.app_logger.addHandler(console_handler)
        
        # File handler for application logs
        file_handler = logging.handlers.RotatingFileHandler(
            os.path.join(self.log_dir, 'app.log'),
            maxBytes=10*1024*1024,  # 10MB
            backupCount=5
        )
        file_handler.setFormatter(formatter)
        self.app_logger.addHandler(file_handler)
        
        # Separate error log file
        error_handler = logging.handlers.RotatingFileHandler(
            os.path.join(self.log_dir, 'errors.log'),
            maxBytes=10*1024*1024,  # 10MB
            backupCount=5
        )
        error_handler.setLevel(logging.ERROR)
        error_handler.setFormatter(formatter)
        self.app_logger.addHandler(error_handler)
        
        # Performance logger
        self.perf_logger = logging.getLogger('noodlevision.performance')
        self.perf_logger.setLevel(logging.INFO)
        
        perf_handler = logging.handlers.RotatingFileHandler(
            os.path.join(self.log_dir, 'performance.log'),
            maxBytes=10*1024*1024,  # 10MB
            backupCount=5
        )
        perf_handler.setFormatter(formatter)
        self.perf_logger.addHandler(perf_handler)
        
        # API logger
        self.api_logger = logging.getLogger('noodlevision.api')
        self.api_logger.setLevel(logging.INFO)
        
        api_handler = logging.handlers.RotatingFileHandler(
            os.path.join(self.log_dir, 'api.log'),
            maxBytes=10*1024*1024,  # 10MB
            backupCount=5
        )
        api_handler.setFormatter(formatter)
        self.api_logger.addHandler(api_handler)
    
    def log_performance(self, operation: str, duration: float, **kwargs):
        """Log performance metrics"""
        log_data = {
            'timestamp': datetime.utcnow().isoformat(),
            'operation': operation,
            'duration': duration,
            **kwargs
        }
        
        self.perf_logger.info(json.dumps(log_data))
    
    def log_api_request(self, method: str, endpoint: str, status_code: int, 
                       duration: float, **kwargs):
        """Log API request"""
        log_data = {
            'timestamp': datetime.utcnow().isoformat(),
            'method': method,
            'endpoint': endpoint,
            'status_code': status_code,
            'duration': duration,
            **kwargs
        }
        
        self.api_logger.info(json.dumps(log_data))
    
    def log_error(self, error: Exception, context: Dict[str, Any] = None):
        """Log error with context"""
        error_data = {
            'timestamp': datetime.utcnow().isoformat(),
            'error_type': type(error).__name__,
            'error_message': str(error),
            'context': context or {}
        }
        
        self.app_logger.error(json.dumps(error_data))
    
    def log_feature_extraction(self, audio_length: int, features: Dict[str, Any]):
        """Log feature extraction results"""
        log_data = {
            'timestamp': datetime.utcnow().isoformat(),
            'audio_length': audio_length,
            'features': {
                name: {
                    'shape': feature.shape,
                    'dtype': str(feature.dtype),
                    'mean': float(np.mean(feature)) if hasattr(feature, 'mean') else None,
                    'std': float(np.std(feature)) if hasattr(feature, 'std') else None
                }
                for name, feature in features.items()
            }
        }
        
        self.app_logger.info(f"Feature extraction: {json.dumps(log_data)}")

# Usage
logger = NoodleVisionLogger()

# Log different events
logger.log_performance('spectrogram_extraction', 0.123, audio_length=22050)
logger.log_api_request('POST', '/extract-features', 200, 0.455, request_size=1024)
logger.log_error(ValueError("Invalid audio format"), context={'audio_file': 'test.wav'})
```

### 3. Prometheus Integration

Integrate Prometheus for metrics collection:

```python
# prometheus_metrics.py
from prometheus_client import Counter, Histogram, Gauge, start_http_server
import time
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'vision'))

from memory import MemoryManager, MemoryPolicy

# Define metrics
REQUEST_COUNT = Counter(
    'noodlevision_requests_total',
    'Total number of requests',
    ['method', 'endpoint', 'status']
)

REQUEST_DURATION = Histogram(
    'noodlevision_request_duration_seconds',
    'Request duration in seconds',
    ['method', 'endpoint']
)

FEATURE_EXTRACTION_TIME = Histogram(
    'noodlevision_feature_extraction_duration_seconds',
    'Feature extraction duration in seconds',
    ['feature_type']
)

MEMORY_USAGE = Gauge(
    'noodlevision_memory_usage_bytes',
    'Memory usage in bytes',
    ['memory_type']
)

CACHE_HITS = Counter(
    'noodlevision_cache_hits_total',
    'Total number of cache hits',
    ['cache_type']
)

CACHE_MISSES = Counter(
    'noodlevision_cache_misses_total',
    'Total number of cache misses',
    ['cache_type']
)

class PrometheusMetrics:
    def __init__(self, port: int = 8001):
        self.port = port
        self.memory_manager = None
        
        # Start metrics server
        start_http_server(self.port)
        print(f"Prometheus metrics server started on port {self.port}")
    
    def set_memory_manager(self, memory_manager: MemoryManager):
        """Set memory manager for metrics collection"""
        self.memory_manager = memory_manager
        self.start_memory_monitoring()
    
    def start_memory_monitoring(self):
        """Start memory monitoring"""
        def update_memory_metrics():
            while True:
                if self.memory_manager:
                    stats = self.memory_manager.get_statistics()
                    
                    # Update memory usage metrics
                    MEMORY_USAGE.labels(memory_type='cpu').set(
                        stats['cpu_pool']['current_usage']
                    )
                    MEMORY_USAGE.labels(memory_type='gpu').set(
                        stats['gpu_pool']['current_usage']
                    )
                    
                    # Update cache metrics
                    cache_stats = stats['cache_stats']
                    CACHE_HITS.labels(cache_type='tensor').inc(
                        cache_stats.get('hits', 0)
                    )
                    CACHE_MISSES.labels(cache_type='tensor').inc(
                        cache_stats.get('misses', 0)
                    )
                
                time.sleep(10)  # Update every 10 seconds
        
        import threading
        thread = threading.Thread(target=update_memory_metrics, daemon=True)
        thread.start()
    
    def record_request(self, method: str, endpoint: str, 
                      status_code: int, duration: float):
        """Record request metrics"""
        REQUEST_COUNT.labels(
            method=method,
            endpoint=endpoint,
            status=status_code
        ).inc()
        
        REQUEST_DURATION.labels(
            method=method,
            endpoint=endpoint
        ).observe(duration)
    
    def record_feature_extraction(self, feature_type: str, duration: float):
        """Record feature extraction metrics"""
        FEATURE_EXTRACTION_TIME.labels(
            feature_type=feature_type
        ).observe(duration)
    
    def record_cache_hit(self, cache_type: str):
        """Record cache hit"""
        CACHE_HITS.labels(cache_type=cache_type).inc()
    
    def record_cache_miss(self, cache_type: str):
        """Record cache miss"""
        CACHE_MISSES.labels(cache_type=cache_type).inc()

# Usage
metrics = PrometheusMetrics(port=8001)

# In your API endpoints
def extract_features_endpoint(request_data):
    start_time = time.time()
    
    try:
        # Process request
        features = process_audio(request_data['audio'])
        
        # Record metrics
        metrics.record_request('POST', '/extract-features', 200, 
                             time.time() - start_time)
        metrics.record_feature_extraction('all', time.time() - start_time)
        
        return {'success': True, 'features': features}
    
    except Exception as e:
        metrics.record_request('POST', '/extract-features', 500, 
                             time.time() - start_time)
        raise
```

## Performance Optimization

### 1. Caching Strategy

Implement advanced caching for NoodleVision:

```python
# caching_strategy.py
import time
import pickle
import hashlib
import os
from typing import Any, Dict, Optional, Callable
from functools import wraps
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'vision'))

from memory import TensorCache

class NoodleVisionCache:
    def __init__(self, cache_dir: str = 'cache', max_size: int = 1000):
        self.cache_dir = cache_dir
        self.max_size = max_size
        self.ensure_cache_directory()
        
        # Memory cache for frequently accessed items
        self.memory_cache = TensorCache(max_size=max_size//10)
        
        # Disk cache for larger items
        self.disk_cache = {}
        self.load_disk_cache()
        
        # Statistics
        self.stats = {
            'hits': 0,
            'misses': 0,
            'disk_hits': 0,
            'disk_misses': 0
        }
    
    def ensure_cache_directory(self):
        """Ensure cache directory exists"""
        os.makedirs(self.cache_dir, exist_ok=True)
    
    def load_disk_cache(self):
        """Load disk cache index"""
        index_file = os.path.join(self.cache_dir, 'cache_index.pkl')
        if os.path.exists(index_file):
            try:
                with open(index_file, 'rb') as f:
                    self.disk_cache = pickle.load(f)
            except Exception as e:
                print(f"Warning: Could not load cache index: {e}")
                self.disk_cache = {}
    
    def save_disk_cache(self):
        """Save disk cache index"""
        index_file = os.path.join(self.cache_dir, 'cache_index.pkl')
        try:
            with open(index_file, 'wb') as f:
                pickle.dump(self.disk_cache, f)
        except Exception as e:
            print(f"Warning: Could not save cache index: {e}")
    
    def _get_cache_key(self, func: Callable, *args, **kwargs) -> str:
        """Generate cache key for function call"""
        # Create a deterministic representation of the arguments
        arg_str = f"{func.__name__}:{args}:{sorted(kwargs.items())}"
        return hashlib.md5(arg_str.encode()).hexdigest()
    
    def _get_file_path(self, cache_key: str) -> str:
        """Get file path for cache key"""
        return os.path.join(self.cache_dir, f"{cache_key}.pkl")
    
    def get(self, cache_key: str) -> Optional[Any]:
        """Get item from cache"""
        # Try memory cache first
        item = self.memory_cache.get(cache_key)
        if item is not None:
            self.stats['hits'] += 1
            return item
        
        # Try disk cache
        if cache_key in self.disk_cache:
            try:
                file_path = self._get_file_path(cache_key)
                with open(file_path, 'rb') as f:
                    item = pickle.load(f)
                
                # Add to memory cache for faster access
                self.memory_cache.add(item)
                self.stats['disk_hits'] += 1
                return item
            except Exception as e:
                print(f"Warning: Could not load cached item {cache_key}: {e}")
                # Remove corrupted item
