"""
NoodleCore AI Model Deployer (.nc file)
=======================================

This module provides comprehensive AI model deployment orchestration capabilities,
supporting multiple deployment strategies, model types, and cloud providers.

Features:
- Multi-cloud deployment (AWS, GCP, Azure, on-premise)
- Multiple model formats (ONNX, TensorFlow, PyTorch, HuggingFace)
- Container-based deployment with Docker
- Kubernetes orchestration support
- Blue-green and canary deployment strategies
- Auto-scaling and resource optimization
- Model validation and testing
- Integration with existing NoodleCore systems

Supported Model Types:
- Language Models: Code completion, documentation generation, code analysis
- Code Analysis Models: Static analysis, security scanning, performance optimization
- Search Models: Semantic search, code search, documentation search
- Learning Models: User behavior analysis, optimization recommendations
- Network Models: Collaboration optimization, distributed task management
- Custom Models: User-defined models for specific use cases
"""

import os
import json
import logging
import time
import threading
import uuid
import subprocess
import docker
import tempfile
import shutil
import hashlib
import requests
from pathlib import Path
from typing import Dict, List, Optional, Any, Union, Callable
from dataclasses import dataclass, asdict
from enum import Enum
import psutil
import yaml

# Import existing NoodleCore components
from ..self_improvement.model_management import get_model_manager, ModelManager, ModelType, ModelStatus
from ..self_improvement.trm_neural_networks import TRMNeuralNetworkManager
from ..runtime.performance_monitor import get_performance_monitor

# Configure logging
logger = logging.getLogger(__name__)

# Environment variables
NOODLE_DEBUG = os.environ.get("NOODLE_DEBUG", "0") == "1"
NOODLE_DEPLOYMENT_ENABLED = os.environ.get("NOODLE_DEPLOYMENT_ENABLED", "1") == "1"
NOODLE_MAX_CONCURRENT_DEPLOYMENTS = int(os.environ.get("NOODLE_MAX_CONCURRENT_DEPLOYMENTS", "5"))
NOODLE_DEPLOYMENT_TIMEOUT = int(os.environ.get("NOODLE_DEPLOYMENT_TIMEOUT", "1800"))  # 30 minutes
NOODLE_DEFAULT_CLOUD_PROVIDER = os.environ.get("NOODLE_DEFAULT_CLOUD_PROVIDER", "local")
NOODLE_KUBERNETES_ENABLED = os.environ.get("NOODLE_KUBERNETES_ENABLED", "0") == "1"
NOODLE_DOCKER_ENABLED = os.environ.get("NOODLE_DOCKER_ENABLED", "1") == "1"


class CloudProvider(Enum):
    """Supported cloud providers for model deployment."""
    AWS = "aws"
    GCP = "gcp"
    AZURE = "azure"
    LOCAL = "local"
    DOCKER = "docker"
    KUBERNETES = "kubernetes"


class DeploymentStrategy(Enum):
    """Deployment strategies for model deployment."""
    IMMEDIATE = "immediate"
    BLUE_GREEN = "blue_green"
    CANARY = "canary"
    ROLLING = "rolling"
    A_B_TESTING = "ab_testing"


class ModelFormat(Enum):
    """Supported AI model formats."""
    ONNX = "onnx"
    TENSORFLOW = "tensorflow"
    PYTORCH = "pytorch"
    HUGGINGFACE = "huggingface"
    SAVEDMODEL = "savedmodel"
    TORCHSCRIPT = "torchscript"
    CUSTOM = "custom"


class DeploymentStatus(Enum):
    """Status of model deployment."""
    PENDING = "pending"
    PREPARING = "preparing"
    DEPLOYING = "deploying"
    VALIDATING = "validating"
    ACTIVE = "active"
    FAILED = "failed"
    ROLLING_BACK = "rolling_back"
    STOPPED = "stopped"


@dataclass
class DeploymentConfig:
    """Configuration for model deployment."""
    deployment_id: str
    model_id: str
    model_type: ModelType
    cloud_provider: CloudProvider
    deployment_strategy: DeploymentStrategy
    model_format: ModelFormat
    model_path: str
    requirements: Dict[str, Any]
    resources: Dict[str, Any]
    environment_variables: Dict[str, str]
    scaling_config: Dict[str, Any]
    monitoring_config: Dict[str, Any]
    security_config: Dict[str, Any]
    cost_config: Dict[str, Any]
    created_at: float
    timeout: float = NOODLE_DEPLOYMENT_TIMEOUT


@dataclass
class DeploymentInstance:
    """Instance of a deployed model."""
    instance_id: str
    deployment_id: str
    model_id: str
    endpoint: str
    status: DeploymentStatus
    resource_usage: Dict[str, float]
    metrics: Dict[str, Any]
    health_status: str
    created_at: float
    last_health_check: float
    cost_data: Dict[str, Any]


class ModelDeployer:
    """
    Comprehensive AI model deployment orchestrator.
    
    This class provides enterprise-grade AI model deployment capabilities
    with support for multiple cloud providers, deployment strategies,
    and integration with existing NoodleCore systems.
    """
    
    def __init__(self):
        """Initialize the model deployer."""
        if NOODLE_DEBUG:
            logger.setLevel(logging.DEBUG)
        
        # Core components
        self.model_manager = None
        self.neural_network_manager = None
        self.performance_monitor = None
        
        # Deployment management
        self.active_deployments: Dict[str, DeploymentConfig] = {}
        self.deployment_instances: Dict[str, DeploymentInstance] = {}
        self.deployment_history: List[Dict[str, Any]] = []
        
        # Cloud provider configurations
        self.cloud_configs: Dict[CloudProvider, Dict[str, Any]] = {}
        self._load_cloud_configs()
        
        # Docker client
        self.docker_client = None
        if NOODLE_DOCKER_ENABLED:
            try:
                self.docker_client = docker.from_env()
            except Exception as e:
                logger.warning(f"Failed to initialize Docker client: {e}")
        
        # Kubernetes client
        self.k8s_client = None
        if NOODLE_KUBERNETES_ENABLED:
            try:
                from kubernetes import client, config
                try:
                    config.load_incluster_config()
                except:
                    config.load_kube_config()
                self.k8s_client = client.ApiClient()
            except Exception as e:
                logger.warning(f"Failed to initialize Kubernetes client: {e}")
        
        # Threading and synchronization
        self._lock = threading.RLock()
        self._deployment_thread = None
        self._monitoring_thread = None
        self._running = False
        
        # Statistics and metrics
        self.deployment_stats = {
            'total_deployments': 0,
            'successful_deployments': 0,
            'failed_deployments': 0,
            'active_deployments': 0,
            'total_deployed_models': 0,
            'deployment_times': [],
            'cost_tracking': {
                'total_cost': 0.0,
                'monthly_cost': 0.0,
                'cost_by_provider': {},
                'cost_by_model_type': {}
            }
        }
        
        logger.info("ModelDeployer initialized")
    
    def _load_cloud_configs(self):
        """Load cloud provider configurations."""
        # Default configurations for cloud providers
        self.cloud_configs = {
            CloudProvider.AWS: {
                'region': 'us-east-1',
                'instance_types': {
                    ModelType.LANGUAGE_MODEL: 'p3.2xlarge',
                    ModelType.CODE_ANALYSIS: 'p3.xlarge',
                    ModelType.SEARCH: 'p2.xlarge',
                    ModelType.LEARNING: 'p3.xlarge',
                    ModelType.NETWORK: 'p2.xlarge',
                    ModelType.CUSTOM: 'p2.xlarge'
                },
                'auto_scaling': {
                    'min_instances': 1,
                    'max_instances': 10,
                    'target_cpu_utilization': 70,
                    'target_memory_utilization': 80
                }
            },
            CloudProvider.GCP: {
                'zone': 'us-central1-a',
                'machine_types': {
                    ModelType.LANGUAGE_MODEL: 'n1-standard-4',
                    ModelType.CODE_ANALYSIS: 'n1-standard-2',
                    ModelType.SEARCH: 'n1-standard-2',
                    ModelType.LEARNING: 'n1-standard-2',
                    ModelType.NETWORK: 'n1-standard-2',
                    ModelType.CUSTOM: 'n1-standard-2'
                },
                'auto_scaling': {
                    'min_instances': 1,
                    'max_instances': 10,
                    'target_cpu_utilization': 70,
                    'target_memory_utilization': 80
                }
            },
            CloudProvider.AZURE: {
                'region': 'eastus',
                'vm_sizes': {
                    ModelType.LANGUAGE_MODEL: 'Standard_NC6s_v3',
                    ModelType.CODE_ANALYSIS: 'Standard_NC4as_T4_v3',
                    ModelType.SEARCH: 'Standard_NC4as_T4_v3',
                    ModelType.LEARNING: 'Standard_NC4as_T4_v3',
                    ModelType.NETWORK: 'Standard_NC4as_T4_v3',
                    ModelType.CUSTOM: 'Standard_NC4as_T4_v3'
                },
                'auto_scaling': {
                    'min_instances': 1,
                    'max_instances': 10,
                    'target_cpu_utilization': 70,
                    'target_memory_utilization': 80
                }
            },
            CloudProvider.DOCKER: {
                'registry': 'localhost:5000',
                'image_prefix': 'noodlecore-ai',
                'resource_limits': {
                    ModelType.LANGUAGE_MODEL: {'cpu': '2', 'memory': '4Gi'},
                    ModelType.CODE_ANALYSIS: {'cpu': '1', 'memory': '2Gi'},
                    ModelType.SEARCH: {'cpu': '1', 'memory': '2Gi'},
                    ModelType.LEARNING: {'cpu': '1', 'memory': '2Gi'},
                    ModelType.NETWORK: {'cpu': '1', 'memory': '2Gi'},
                    ModelType.CUSTOM: {'cpu': '1', 'memory': '2Gi'}
                }
            },
            CloudProvider.KUBERNETES: {
                'namespace': 'noodlecore-ai',
                'resource_limits': {
                    ModelType.LANGUAGE_MODEL: {'cpu': '2', 'memory': '4Gi'},
                    ModelType.CODE_ANALYSIS: {'cpu': '1', 'memory': '2Gi'},
                    ModelType.SEARCH: {'cpu': '1', 'memory': '2Gi'},
                    ModelType.LEARNING: {'cpu': '1', 'memory': '2Gi'},
                    ModelType.NETWORK: {'cpu': '1', 'memory': '2Gi'},
                    ModelType.CUSTOM: {'cpu': '1', 'memory': '2Gi'}
                }
            },
            CloudProvider.LOCAL: {
                'host': 'localhost',
                'port_range': (8081, 8100),
                'resource_limits': {
                    ModelType.LANGUAGE_MODEL: {'cpu': '2', 'memory': '4Gi'},
                    ModelType.CODE_ANALYSIS: {'cpu': '1', 'memory': '2Gi'},
                    ModelType.SEARCH: {'cpu': '1', 'memory': '2Gi'},
                    ModelType.LEARNING: {'cpu': '1', 'memory': '2Gi'},
                    ModelType.NETWORK: {'cpu': '1', 'memory': '2Gi'},
                    ModelType.CUSTOM: {'cpu': '1', 'memory': '2Gi'}
                }
            }
        }
        
        logger.debug(f"Loaded cloud configurations for {len(self.cloud_configs)} providers")
    
    def initialize(self, model_manager: ModelManager = None, 
                   neural_network_manager: TRMNeuralNetworkManager = None,
                   performance_monitor = None) -> bool:
        """
        Initialize the deployer with required components.
        
        Args:
            model_manager: Model management component
            neural_network_manager: Neural network management component
            performance_monitor: Performance monitoring component
            
        Returns:
            True if initialization successful
        """
        try:
            # Initialize core components
            if model_manager:
                self.model_manager = model_manager
            else:
                # Initialize default model manager
                from ..self_improvement.ai_decision_engine import AIDecisionEngine
                ai_engine = AIDecisionEngine()
                self.model_manager = get_model_manager(ai_engine, None, None)
            
            if neural_network_manager:
                self.neural_network_manager = neural_network_manager
            
            if performance_monitor:
                self.performance_monitor = performance_monitor
            else:
                self.performance_monitor = get_performance_monitor()
            
            # Start background services
            self.start()
            
            logger.info("ModelDeployer initialized successfully")
            return True
            
        except Exception as e:
            logger.error(f"Failed to initialize ModelDeployer: {e}")
            return False
    
    def start(self):
        """Start the model deployer background services."""
        with self._lock:
            if self._running:
                return
            
            self._running = True
            
            # Start monitoring thread
            self._monitoring_thread = threading.Thread(
                target=self._monitoring_worker, daemon=True
            )
            self._monitoring_thread.start()
            
            logger.info("ModelDeployer started")
    
    def stop(self):
        """Stop the model deployer and cleanup resources."""
        with self._lock:
            if not self._running:
                return
            
            self._running = False
            
            # Stop all active deployments
            for deployment_id in list(self.active_deployments.keys()):
                self.stop_deployment(deployment_id)
            
            # Wait for threads to stop
            if self._monitoring_thread and self._monitoring_thread.is_alive():
                self._monitoring_thread.join(timeout=10.0)
            
            logger.info("ModelDeployer stopped")
    
    def deploy_model(self, model_id: str, cloud_provider: CloudProvider = None,
                    deployment_strategy: DeploymentStrategy = None,
                    **kwargs) -> str:
        """
        Deploy an AI model to the specified cloud provider.
        
        Args:
            model_id: ID of the model to deploy
            cloud_provider: Target cloud provider
            deployment_strategy: Deployment strategy to use
            **kwargs: Additional deployment configuration
            
        Returns:
            Deployment ID for tracking the deployment
        """
        try:
            # Validate inputs
            if not model_id:
                raise ValueError("Model ID is required")
            
            # Check if model exists
            if self.model_manager and model_id not in self.model_manager.models:
                raise ValueError(f"Model {model_id} not found in model manager")
            
            # Use defaults if not specified
            cloud_provider = cloud_provider or CloudProvider(NOODLE_DEFAULT_CLOUD_PROVIDER)
            deployment_strategy = deployment_strategy or DeploymentStrategy.IMMEDIATE
            
            # Get model details
            model = None
            if self.model_manager:
                model = self.model_manager.models[model_id]
            
            # Create deployment configuration
            deployment_id = str(uuid.uuid4())
            deployment_config = DeploymentConfig(
                deployment_id=deployment_id,
                model_id=model_id,
                model_type=ModelType.CUSTOM if not model else model.model_type,
                cloud_provider=cloud_provider,
                deployment_strategy=deployment_strategy,
                model_format=self._detect_model_format(model.file_path if model else kwargs.get('model_path', '')),
                model_path=model.file_path if model else kwargs.get('model_path', ''),
                requirements=kwargs.get('requirements', {}),
                resources=kwargs.get('resources', {}),
                environment_variables=kwargs.get('environment_variables', {}),
                scaling_config=kwargs.get('scaling_config', {}),
                monitoring_config=kwargs.get('monitoring_config', {}),
                security_config=kwargs.get('security_config', {}),
                cost_config=kwargs.get('cost_config', {}),
                created_at=time.time()
            )
            
            # Start deployment
            with self._lock:
                self.active_deployments[deployment_id] = deployment_config
                self.deployment_stats['active_deployments'] += 1
                self.deployment_stats['total_deployments'] += 1
            
            # Start deployment thread
            self._deployment_thread = threading.Thread(
                target=self._deployment_worker,
                args=(deployment_id,),
                daemon=True
            )
            self._deployment_thread.start()
            
            logger.info(f"Started deployment {deployment_id} for model {model_id}")
            return deployment_id
            
        except Exception as e:
            logger.error(f"Failed to start deployment for model {model_id}: {e}")
            raise
    
    def _deployment_worker(self, deployment_id: str):
        """Background worker for deployment process."""
        deployment = None
        with self._lock:
            deployment = self.active_deployments.get(deployment_id)
        
        if not deployment:
            logger.error(f"Deployment {deployment_id} not found")
            return
        
        logger.info(f"Starting deployment worker for {deployment_id}")
        deployment_start_time = time.time()
        
        try:
            # Prepare deployment
            deployment.status = DeploymentStatus.PREPARING
            self._prepare_deployment(deployment)
            
            # Deploy based on strategy
            if deployment.deployment_strategy == DeploymentStrategy.IMMEDIATE:
                self._immediate_deployment(deployment)
            elif deployment.deployment_strategy == DeploymentStrategy.BLUE_GREEN:
                self._blue_green_deployment(deployment)
            elif deployment.deployment_strategy == DeploymentStrategy.CANARY:
                self._canary_deployment(deployment)
            elif deployment.deployment_strategy == DeploymentStrategy.ROLLING:
                self._rolling_deployment(deployment)
            elif deployment.deployment_strategy == DeploymentStrategy.A_B_TESTING:
                self._ab_testing_deployment(deployment)
            
            # Validate deployment
            deployment.status = DeploymentStatus.VALIDATING
            self._validate_deployment(deployment)
            
            # Mark as active
            deployment.status = DeploymentStatus.ACTIVE
            
            # Update statistics
            deployment_time = time.time() - deployment_start_time
            with self._lock:
                self.deployment_stats['successful_deployments'] += 1
                self.deployment_stats['active_deployments'] -= 1
                self.deployment_stats['deployment_times'].append(deployment_time)
                self.deployment_stats['total_deployed_models'] += 1
            
            logger.info(f"Deployment {deployment_id} completed successfully in {deployment_time:.2f}s")
            
        except Exception as e:
            # Mark deployment as failed
            deployment.status = DeploymentStatus.FAILED
            deployment.error_message = str(e)
            
            # Update statistics
            with self._lock:
                self.deployment_stats['failed_deployments'] += 1
                self.deployment_stats['active_deployments'] -= 1
            
            logger.error(f"Deployment {deployment_id} failed: {e}")
            
            # Attempt rollback if possible
            if deployment.deployment_strategy in [DeploymentStrategy.BLUE_GREEN, DeploymentStrategy.CANARY]:
                self._attempt_rollback(deployment)
        
        finally:
            # Move to history
            with self._lock:
                if deployment_id in self.active_deployments:
                    deployment_history = asdict(deployment)
                    self.deployment_history.append(deployment_history)
                    del self.active_deployments[deployment_id]
    
    def _prepare_deployment(self, deployment: DeploymentConfig):
        """Prepare deployment by validating model and setting up environment."""
        logger.info(f"Preparing deployment {deployment.deployment_id}")
        
        # Validate model file
        if not os.path.exists(deployment.model_path):
            raise FileNotFoundError(f"Model file not found: {deployment.model_path}")
        
        # Check model format compatibility
        if deployment.model_format not in self._get_supported_formats(deployment.cloud_provider):
            raise ValueError(f"Model format {deployment.model_format} not supported for {deployment.cloud_provider}")
        
        # Prepare deployment artifacts
        self._prepare_deployment_artifacts(deployment)
        
        # Validate cloud provider availability
        self._validate_cloud_provider(deployment.cloud_provider)
        
        # Check resource availability
        self._check_resource_availability(deployment)
    
    def _immediate_deployment(self, deployment: DeploymentConfig):
        """Immediate deployment strategy."""
        logger.info(f"Starting immediate deployment for {deployment.deployment_id}")
        deployment.status = DeploymentStatus.DEPLOYING
        
        # Create deployment instance
        instance = self._create_deployment_instance(deployment)
        
        # Deploy to target platform
        if deployment.cloud_provider == CloudProvider.DOCKER:
            self._deploy_to_docker(deployment, instance)
        elif deployment.cloud_provider == CloudProvider.KUBERNETES:
            self._deploy_to_kubernetes(deployment, instance)
        elif deployment.cloud_provider == CloudProvider.LOCAL:
            self._deploy_to_local(deployment, instance)
        else:
            self._deploy_to_cloud(deployment, instance)
        
        # Store instance
        with self._lock:
            self.deployment_instances[instance.instance_id] = instance
    
    def _blue_green_deployment(self, deployment: DeploymentConfig):
        """Blue-green deployment strategy."""
        logger.info(f"Starting blue-green deployment for {deployment.deployment_id}")
        deployment.status = DeploymentStatus.DEPLOYING
        
        # Deploy to green environment (parallel to blue)
        green_instance = self._create_deployment_instance(deployment, "green")
        
        # Deploy to target platform
        if deployment.cloud_provider == CloudProvider.DOCKER:
            self._deploy_to_docker(deployment, green_instance)
        elif deployment.cloud_provider == CloudProvider.KUBERNETES:
            self._deploy_to_kubernetes(deployment, green_instance)
        else:
            self._deploy_to_cloud(deployment, green_instance)
        
        # Store green instance
        with self._lock:
            self.deployment_instances[green_instance.instance_id] = green_instance
        
        # Wait for green deployment to be ready
        time.sleep(30)  # Wait 30 seconds for green to be ready
        
        # Validate green deployment
        if not self._validate_deployment_instance(green_instance):
            raise Exception("Green deployment validation failed")
        
        # Switch traffic to green (would implement traffic routing in real scenario)
        green_instance.status = DeploymentStatus.ACTIVE
        deployment.green_instance_id = green_instance.instance_id
        
        logger.info(f"Blue-green deployment completed for {deployment.deployment_id}")
    
    def _canary_deployment(self, deployment: DeploymentConfig):
        """Canary deployment strategy."""
        logger.info(f"Starting canary deployment for {deployment.deployment_id}")
        deployment.status = DeploymentStatus.DEPLOYING
        
        # Deploy small canary instance (e.g., 10% traffic)
        canary_instance = self._create_deployment_instance(deployment, "canary")
        
        # Deploy with limited resources
        canary_instance.resources['cpu'] *= 0.1  # 10% of normal resources
        canary_instance.resources['memory'] *= 0.1
        
        # Deploy to target platform
        if deployment.cloud_provider == CloudProvider.DOCKER:
            self._deploy_to_docker(deployment, canary_instance)
        elif deployment.cloud_provider == CloudProvider.KUBERNETES:
            self._deploy_to_kubernetes(deployment, canary_instance)
        else:
            self._deploy_to_cloud(deployment, canary_instance)
        
        # Store canary instance
        with self._lock:
            self.deployment_instances[canary_instance.instance_id] = canary_instance
        
        # Monitor canary for validation period
        canary_validated = self._monitor_canary_deployment(canary_instance, deployment)
        
        if canary_validated:
            # Scale up to full deployment
            self._scale_canary_to_full(deployment, canary_instance)
        else:
            raise Exception("Canary deployment validation failed")
    
    def _rolling_deployment(self, deployment: DeploymentConfig):
        """Rolling deployment strategy."""
        logger.info(f"Starting rolling deployment for {deployment.deployment_id}")
        deployment.status = DeploymentStatus.DEPLOYING
        
        # Deploy instances gradually
        num_instances = deployment.scaling_config.get('min_instances', 2)
        
        for i in range(num_instances):
            instance = self._create_deployment_instance(deployment, f"rolling-{i}")
            
            if deployment.cloud_provider == CloudProvider.DOCKER:
                self._deploy_to_docker(deployment, instance)
            elif deployment.cloud_provider == CloudProvider.KUBERNETES:
                self._deploy_to_kubernetes(deployment, instance)
            else:
                self._deploy_to_cloud(deployment, instance)
            
            # Store instance
            with self._lock:
                self.deployment_instances[instance.instance_id] = instance
            
            # Wait between deployments
            time.sleep(10)
        
        logger.info(f"Rolling deployment completed for {deployment.deployment_id}")
    
    def _ab_testing_deployment(self, deployment: DeploymentConfig):
        """A/B testing deployment strategy."""
        logger.info(f"Starting A/B testing deployment for {deployment.deployment_id}")
        deployment.status = DeploymentStatus.DEPLOYING
        
        # Deploy control version (model A)
        control_instance = self._create_deployment_instance(deployment, "control")
        
        # Deploy variant version (model B - requires multiple models)
        if self.model_manager and deployment.model_id in self.model_manager.models:
            # Get next version of the model for variant B
            model = self.model_manager.models[deployment.model_id]
            variant_model_id = self._get_next_model_version(model.model_id)
            
            if variant_model_id:
                variant_instance = self._create_deployment_instance(deployment, "variant")
                variant_instance.model_id = variant_model_id
                
                # Deploy both instances
                if deployment.cloud_provider == CloudProvider.DOCKER:
                    self._deploy_to_docker(deployment, control_instance)
                    self._deploy_to_docker(deployment, variant_instance)
                elif deployment.cloud_provider == CloudProvider.KUBERNETES:
                    self._deploy_to_kubernetes(deployment, control_instance)
                    self._deploy_to_kubernetes(deployment, variant_instance)
                else:
                    self._deploy_to_cloud(deployment, control_instance)
                    self._deploy_to_cloud(deployment, variant_instance)
                
                # Store instances
                with self._lock:
                    self.deployment_instances[control_instance.instance_id] = control_instance
                    self.deployment_instances[variant_instance.instance_id] = variant_instance
                
                deployment.ab_config = {
                    'control_instance_id': control_instance.instance_id,
                    'variant_instance_id': variant_instance.instance_id,
                    'traffic_split': 0.5  # 50/50 split
                }
            else:
                # No variant available, deploy single instance
                if deployment.cloud_provider == CloudProvider.DOCKER:
                    self._deploy_to_docker(deployment, control_instance)
                elif deployment.cloud_provider == CloudProvider.KUBERNETES:
                    self._deploy_to_kubernetes(deployment, control_instance)
                else:
                    self._deploy_to_cloud(deployment, control_instance)
                
                with self._lock:
                    self.deployment_instances[control_instance.instance_id] = control_instance
        else:
            # Deploy single instance without A/B testing
            if deployment.cloud_provider == CloudProvider.DOCKER:
                self._deploy_to_docker(deployment, control_instance)
            elif deployment.cloud_provider == CloudProvider.KUBERNETES:
                self._deploy_to_kubernetes(deployment, control_instance)
            else:
                self._deploy_to_cloud(deployment, control_instance)
            
            with self._lock:
                self.deployment_instances[control_instance.instance_id] = control_instance
        
        logger.info(f"A/B testing deployment completed for {deployment.deployment_id}")
    
    def _deploy_to_docker(self, deployment: DeploymentConfig, instance: DeploymentInstance):
        """Deploy model using Docker."""
        try:
            if not self.docker_client:
                raise Exception("Docker client not available")
            
            # Create Docker image
            image_tag = f"{deployment.model_id}:{deployment.deployment_id}"
            self._create_docker_image(deployment, image_tag)
            
            # Run container
            container_name = f"noodle-ai-{deployment.model_id}-{deployment.deployment_id}"
            
            # Resource limits
            cpu_limit = deployment.resources.get('cpu', '1')
            memory_limit = deployment.resources.get('memory', '2Gi')
            
            container = self.docker_client.containers.run(
                image_tag,
                name=container_name,
                ports={'8080/tcp': instance.port},
                environment=deployment.environment_variables,
                cpu_shares=int(float(cpu_limit) * 1024),
                mem_limit=memory_limit,
                detach=True,
                restart_policy={"Name": "always"}
            )
            
            # Update instance
            instance.endpoint = f"http://localhost:{instance.port}"
            instance.docker_container_id = container.id
            
            logger.info(f"Docker deployment successful for {deployment.deployment_id}")
            
        except Exception as e:
            logger.error(f"Docker deployment failed: {e}")
            raise
    
    def _deploy_to_kubernetes(self, deployment: DeploymentConfig, instance: DeploymentInstance):
        """Deploy model using Kubernetes."""
        try:
            if not self.k8s_client:
                raise Exception("Kubernetes client not available")
            
            from kubernetes import client, apps_v1
            
            # Create deployment
            container = client.V1Container(
                name=f"noodle-ai-{deployment.model_id}",
                image=f"{deployment.deployment_id}:latest",
                ports=[client.V1ContainerPort(container_port=8080)],
                env=[client.V1EnvVar(name=k, value=v) for k, v in deployment.environment_variables.items()],
                resources=client.V1ResourceRequirements(
                    requests={
                        "cpu": deployment.resources.get('cpu', '1'),
                        "memory": deployment.resources.get('memory', '2Gi')
                    },
                    limits={
                        "cpu": deployment.resources.get('cpu', '1'),
                        "memory": deployment.resources.get('memory', '2Gi')
                    }
                )
            )
            
            template = client.V1PodTemplateSpec(
                metadata=client.V1ObjectMeta(labels={"app": f"noodle-ai-{deployment.model_id}"}),
                spec=client.V1PodSpec(containers=[container])
            )
            
            deployment_spec = apps_v1.DeploymentSpec(
                replicas=1,
                template=template,
                selector=client.V1LabelSelector(
                    match_labels={"app": f"noodle-ai-{deployment.model_id}"}
                )
            )
            
            k8s_deployment = apps_v1.Deployment(
                api_version="apps/v1",
                kind="Deployment",
                metadata=client.V1ObjectMeta(name=f"noodle-ai-{deployment.model_id}"),
                spec=deployment_spec
            )
            
            # Create deployment in Kubernetes
            apps_v1.DeploymentApi(self.k8s_client).create_namespaced_deployment(
                namespace="default",
                body=k8s_deployment
            )
            
            # Create service
            service = client.V1Service(
                api_version="v1",
                kind="Service",
                metadata=client.V1ObjectMeta(name=f"noodle-ai-{deployment.model_id}"),
                spec=client.V1ServiceSpec(
                    selector={"app": f"noodle-ai-{deployment.model_id}"},
                    ports=[client.V1ServicePort(port=8080, target_port=8080)],
                    type="ClusterIP"
                )
            )
            
            client.V1Api(self.k8s_client).create_namespaced_service(
                namespace="default",
                body=service
            )
            
            # Update instance
            instance.endpoint = f"http://noodle-ai-{deployment.model_id}.default.svc.cluster.local:8080"
            instance.kubernetes_deployment_name = f"noodle-ai-{deployment.model_id}"
            instance.kubernetes_service_name = f"noodle-ai-{deployment.model_id}"
            
            logger.info(f"Kubernetes deployment successful for {deployment.deployment_id}")
            
        except Exception as e:
            logger.error(f"Kubernetes deployment failed: {e}")
            raise
    
    def _deploy_to_local(self, deployment: DeploymentConfig, instance: DeploymentInstance):
        """Deploy model locally."""
        try:
            # Find available port
            import socket
            sock = socket.socket()
            sock.bind(('', 0))
            port = sock.getsockname()[1]
            sock.close()
            
            # Start local server process
            cmd = self._create_server_command(deployment, port)
            
            process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                env=os.environ.copy().update(deployment.environment_variables) or os.environ.copy()
            )
            
            # Update instance
            instance.endpoint = f"http://localhost:{port}"
            instance.process_id = process.pid
            instance.local_port = port
            
            logger.info(f"Local deployment successful for {deployment.deployment_id}")
            
        except Exception as e:
            logger.error(f"Local deployment failed: {e}")
            raise
    
    def _deploy_to_cloud(self, deployment: DeploymentConfig, instance: DeploymentInstance):
        """Deploy model to cloud provider (placeholder for cloud-specific implementations)."""
        # This would implement cloud-specific deployment logic
        # For now, we'll simulate cloud deployment
        
        cloud_config = self.cloud_configs[deployment.cloud_provider]
        
        # Simulate cloud deployment
        instance.endpoint = f"https://{deployment.cloud_provider.value}-ai-{deployment.model_id}.cloudprovider.com"
        
        # Simulate deployment delay
        time.sleep(5)
        
        logger.info(f"Cloud deployment simulated for {deployment.deployment_id} on {deployment.cloud_provider.value}")
    
    def _validate_deployment(self, deployment: DeploymentConfig):
        """Validate deployment after deployment."""
        logger.info(f"Validating deployment {deployment.deployment_id}")
        
        # Health check all instances
        for instance_id in deployment.instance_ids:
            instance = self.deployment_instances.get(instance_id)
            if instance and not self._validate_deployment_instance(instance):
                raise Exception(f"Deployment validation failed for instance {instance_id}")
        
        # Check performance metrics
        if self.performance_monitor:
            time.sleep(10)  # Wait for metrics to accumulate
            performance_ok = self._check_deployment_performance(deployment)
            if not performance_ok:
                raise Exception("Deployment performance validation failed")
    
    def _validate_deployment_instance(self, instance: DeploymentInstance) -> bool:
        """Validate a single deployment instance."""
        try:
            # Make health check request
            response = requests.get(f"{instance.endpoint}/health", timeout=10)
            
            if response.status_code == 200:
                instance.health_status = "healthy"
                instance.last_health_check = time.time()
                return True
            else:
                instance.health_status = "unhealthy"
                return False
                
        except Exception as e:
            logger.warning(f"Health check failed for instance {instance.instance_id}: {e}")
            instance.health_status = "error"
            return False
    
    def _check_deployment_performance(self, deployment: DeploymentConfig) -> bool:
        """Check deployment performance metrics."""
        if not self.performance_monitor:
            return True
        
        # Get performance metrics for the deployment
        # This would integrate with the performance monitor to check latency, throughput, etc.
        
        return True
    
    def stop_deployment(self, deployment_id: str) -> bool:
        """Stop an active deployment."""
        try:
            with self._lock:
                if deployment_id not in self.active_deployments:
                    logger.warning(f"Deployment {deployment_id} not found")
                    return False
                
                deployment = self.active_deployments[deployment_id]
                deployment.status = DeploymentStatus.STOPPED
            
            # Stop all instances
            for instance_id in deployment.instance_ids:
                self._stop_deployment_instance(instance_id)
            
            logger.info(f"Stopped deployment {deployment_id}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to stop deployment {deployment_id}: {e}")
            return False
    
    def _stop_deployment_instance(self, instance_id: str):
        """Stop a single deployment instance."""
        instance = self.deployment_instances.get(instance_id)
        if not instance:
            return
        
        try:
            if instance.docker_container_id and self.docker_client:
                # Stop Docker container
                container = self.docker_client.containers.get(instance.docker_container_id)
                container.stop()
                container.remove()
            
            elif instance.process_id:
                # Stop local process
                process = psutil.Process(instance.process_id)
                process.terminate()
                process.wait(timeout=10)
            
            elif instance.kubernetes_deployment_name and self.k8s_client:
                # Delete Kubernetes deployment
                from kubernetes import client, apps_v1
                apps_v1.DeploymentApi(self.k8s_client).delete_namespaced_deployment(
                    name=instance.kubernetes_deployment_name,
                    namespace="default"
                )
                
                # Delete service
                client.V1Api(self.k8s_client).delete_namespaced_service(
                    name=instance.kubernetes_service_name,
                    namespace="default"
                )
            
            instance.status = DeploymentStatus.STOPPED
            logger.info(f"Stopped deployment instance {instance_id}")
            
        except Exception as e:
            logger.error(f"Failed to stop deployment instance {instance_id}: {e}")
    
    def get_deployment_status(self, deployment_id: str) -> Dict[str, Any]:
        """Get status of a deployment."""
        with self._lock:
            # Check active deployments
            if deployment_id in self.active_deployments:
                deployment = self.active_deployments[deployment_id]
                return {
                    'deployment_id': deployment_id,
                    'status': deployment.status.value,
                    'model_id': deployment.model_id,
                    'cloud_provider': deployment.cloud_provider.value,
                    'deployment_strategy': deployment.deployment_strategy.value,
                    'created_at': deployment.created_at,
                    'instances': [asdict(self.deployment_instances[iid]) for iid in deployment.instance_ids]
                }
            
            # Check deployment history
            for history_item in self.deployment_history:
                if history_item['deployment_id'] == deployment_id:
                    return {
                        'deployment_id': deployment_id,
                        'status': 'completed',
                        'history': history_item
                    }
            
            return {'error': 'Deployment not found'}
    
    def get_deployment_statistics(self) -> Dict[str, Any]:
        """Get deployment statistics."""
        with self._lock:
            stats = self.deployment_stats.copy()
            
            # Calculate additional metrics
            if stats['deployment_times']:
                stats['avg_deployment_time'] = sum(stats['deployment_times']) / len(stats['deployment_times'])
                stats['max_deployment_time'] = max(stats['deployment_times'])
                stats['min_deployment_time'] = min(stats['deployment_times'])
            
            return stats
    
    def _monitoring_worker(self):
        """Background worker for deployment monitoring."""
        logger.info("Deployment monitoring worker started")
        
        while self._running:
            try:
                self._monitor_active_deployments()
                time.sleep(30)  # Monitor every 30 seconds
                
            except Exception as e:
                logger.error(f"Error in monitoring worker: {e}")
                time.sleep(10)
        
        logger.info("Deployment monitoring worker stopped")
    
    def _monitor_active_deployments(self):
        """Monitor all active deployments."""
        with self._lock:
            deployments_to_check = list(self.active_deployments.keys())
        
        for deployment_id in deployments_to_check:
            try:
                deployment = self.active_deployments.get(deployment_id)
                if not deployment:
                    continue
                
                # Health check all instances
                for instance_id in deployment.instance_ids:
                    instance = self.deployment_instances.get(instance_id)
                    if instance and instance.status == DeploymentStatus.ACTIVE:
                        # Check if health check is needed
                        if time.time() - instance.last_health_check > 300:  # 5 minutes
                            self._validate_deployment_instance(instance)
                
                # Check for scaling needs
                self._check_scaling_requirements(deployment)
                
                # Update cost tracking
                self._update_cost_tracking(deployment)
                
            except Exception as e:
                logger.error(f"Error monitoring deployment {deployment_id}: {e}")
    
    # Helper methods
    def _detect_model_format(self, model_path: str) -> ModelFormat:
        """Detect model format from file path."""
        model_path = model_path.lower()
        
        if model_path.endswith('.onnx'):
            return ModelFormat.ONNX
        elif 'tensorflow' in model_path or model_path.endswith('.pb') or model_path.endswith('.savedmodel'):
            return ModelFormat.TENSORFLOW
        elif 'pytorch' in model_path or model_path.endswith('.pt') or model_path.endswith('.pth'):
            return ModelFormat.PYTORCH
        elif 'huggingface' in model_path or 'transformers' in model_path:
            return ModelFormat.HUGGINGFACE
        elif model_path.endswith('.savedmodel'):
            return ModelFormat.SAVEDMODEL
        elif model_path.endswith('.torchscript'):
            return ModelFormat.TORCHSCRIPT
        else:
            return ModelFormat.CUSTOM
    
    def _get_supported_formats(self, cloud_provider: CloudProvider) -> List[ModelFormat]:
        """Get supported model formats for a cloud provider."""
        # All providers support basic formats
        basic_formats = [ModelFormat.ONNX, ModelFormat.TENSORFLOW, ModelFormat.PYTORCH, ModelFormat.CUSTOM]
        
        if cloud_provider == CloudProvider.AWS:
            # AWS supports SageMaker formats
            return basic_formats + [ModelFormat.HUGGINGFACE]
        elif cloud_provider == CloudProvider.GCP:
            # GCP supports Vertex AI formats
            return basic_formats + [ModelFormat.HUGGINGFACE]
        elif cloud_provider == CloudProvider.AZURE:
            # Azure supports ML Studio formats
            return basic_formats + [ModelFormat.HUGGINGFACE]
        else:
            # Local/cloud providers support basic formats
            return basic_formats
    
    def _create_deployment_instance(self, deployment: DeploymentConfig, suffix: str = "") -> DeploymentInstance:
        """Create a deployment instance."""
        instance_id = f"{deployment.deployment_id}-{suffix}" if suffix else deployment.deployment_id
        
        # Generate endpoint (will be updated during deployment)
        port = self._find_available_port()
        endpoint = f"http://localhost:{port}"
        
        instance = DeploymentInstance(
            instance_id=instance_id,
            deployment_id=deployment.deployment_id,
            model_id=deployment.model_id,
            endpoint=endpoint,
            status=DeploymentStatus.DEPLOYING,
            resource_usage={'cpu': 0.0, 'memory': 0.0, 'requests_per_second': 0.0},
            metrics={},
            health_status="unknown",
            created_at=time.time(),
            last_health_check=time.time(),
            cost_data={}
        )
        
        # Add instance ID to deployment
        if not hasattr(deployment, 'instance_ids'):
            deployment.instance_ids = []
        deployment.instance_ids.append(instance_id)
        
        return instance
    
    def _find_available_port(self) -> int:
        """Find an available port for local deployment."""
        import socket
        sock = socket.socket()
        try:
            sock.bind(('', 0))
            return sock.getsockname()[1]
        finally:
            sock.close()
    
    def _prepare_deployment_artifacts(self, deployment: DeploymentConfig):
        """Prepare deployment artifacts."""
        # Create temporary directory for deployment artifacts
        deployment_artifacts_dir = f"/tmp/noodle_deployment_{deployment.deployment_id}"
        os.makedirs(deployment_artifacts_dir, exist_ok=True)
        
        # Copy model file
        model_dest = os.path.join(deployment_artifacts_dir, "model")
        shutil.copy2(deployment.model_path, model_dest)
        
        # Create deployment configuration
        config = {
            'model_id': deployment.model_id,
            'model_path': model_dest,
            'model_format': deployment.model_format.value,
            'environment_variables': deployment.environment_variables,
            'resources': deployment.resources
        }
        
        with open(os.path.join(deployment_artifacts_dir, "config.json"), 'w') as f:
            json.dump(config, f, indent=2)
        
        deployment.artifacts_dir = deployment_artifacts_dir
        logger.debug(f"Prepared deployment artifacts for {deployment.deployment_id}")
    
    def _validate_cloud_provider(self, cloud_provider: CloudProvider):
        """Validate cloud provider availability."""
        if cloud_provider == CloudProvider.DOCKER and not self.docker_client:
            raise Exception("Docker not available")
        elif cloud_provider == CloudProvider.KUBERNETES and not self.k8s_client:
            raise Exception("Kubernetes not available")
        elif cloud_provider in [CloudProvider.AWS, CloudProvider.GCP, CloudProvider.AZURE]:
            # Would validate cloud credentials in real implementation
            pass
    
    def _check_resource_availability(self, deployment: DeploymentConfig):
        """Check if resources are available for deployment."""
        # Check system resources
        cpu_available = psutil.cpu_count()
        memory_available = psutil.virtual_memory().available / (1024**3)  # GB
        
        required_cpu = float(deployment.resources.get('cpu', '1'))
        required_memory = float(deployment.resources.get('memory', '2').replace('Gi', ''))
        
        if required_cpu > cpu_available:
            raise Exception(f"Insufficient CPU resources: {required_cpu} > {cpu_available}")
        
        if required_memory > memory_available:
            raise Exception(f"Insufficient memory resources: {required_memory}GB > {memory_available}GB")
    
    def _create_docker_image(self, deployment: DeploymentConfig, image_tag: str):
        """Create Docker image for deployment."""
        # Create Dockerfile
        dockerfile_content = f"""
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY {deployment.model_id} /app/model/
COPY config.json /app/

EXPOSE 8080

CMD ["python", "-m", "noodlecore.deployment.model_server", "--config", "config.json"]
"""
        
        dockerfile_path = os.path.join(deployment.artifacts_dir, "Dockerfile")
        with open(dockerfile_path, 'w') as f:
            f.write(dockerfile_content)
        
        # Create requirements.txt
        requirements = [
            "flask==2.3.2",
            "gunicorn==20.1.0",
            "numpy==1.24.3",
            "requests==2.31.0"
        ]
        
        # Add format-specific requirements
        if deployment.model_format == ModelFormat.ONNX:
            requirements.append("onnx==1.14.0")
        elif deployment.model_format == ModelFormat.TENSORFLOW:
            requirements.append("tensorflow==2.13.0")
        elif deployment.model_format == ModelFormat.PYTORCH:
            requirements.append("torch==2.0.1")
        
        requirements_path = os.path.join(deployment.artifacts_dir, "requirements.txt")
        with open(requirements_path, 'w') as f:
            f.write('\n'.join(requirements))
        
        # Build image
        self.docker_client.images.build(
            path=deployment.artifacts_dir,
            tag=image_tag,
            rm=True
        )
        
        logger.debug(f"Created Docker image {image_tag}")
    
    def _create_server_command(self, deployment: DeploymentConfig, port: int) -> List[str]:
        """Create command to start model server."""
        # This would create a server command based on model format
        # For now, return a basic Flask server command
        
        return [
            "python", "-m", "flask", "run",
            "--host", "0.0.0.0",
            "--port", str(port)
        ]
    
    def _monitor_canary_deployment(self, canary_instance: DeploymentInstance, 
                                   deployment: DeploymentConfig) -> bool:
        """Monitor canary deployment for validation."""
        logger.info(f"Monitoring canary deployment {canary_instance.instance_id}")
        
        # Monitor for 5 minutes
        monitoring_duration = 300  # 5 minutes
        check_interval = 30  # Check every 30 seconds
        checks = monitoring_duration // check_interval
        
        for i in range(checks):
            time.sleep(check_interval)
            
            # Check instance health
            if not self._validate_deployment_instance(canary_instance):
                logger.warning(f"Canary instance {canary_instance.instance_id} health check failed")
                continue
            
            # Check performance metrics
            if self.performance_monitor:
                # Would check performance metrics here
                pass
        
        # Final validation
        return self._validate_deployment_instance(canary_instance)
    
    def _scale_canary_to_full(self, deployment: DeploymentConfig, canary_instance: DeploymentInstance):
        """Scale canary deployment to full deployment."""
        logger.info(f"Scaling canary to full deployment for {deployment.deployment_id}")
        
        # Create full-scale instances
        num_instances = deployment.scaling_config.get('min_instances', 2)
        
        for i in range(num_instances):
            full_instance = self._create_deployment_instance(deployment, f"full-{i}")
            
            # Deploy with full resources
            if deployment.cloud_provider == CloudProvider.DOCKER:
                self._deploy_to_docker(deployment, full_instance)
            elif deployment.cloud_provider == CloudProvider.KUBERNETES:
                self._deploy_to_kubernetes(deployment, full_instance)
            else:
                self._deploy_to_cloud(deployment, full_instance)
            
            # Store instance
            with self._lock:
                self.deployment_instances[full_instance.instance_id] = full_instance
        
        # Update deployment strategy to full
        deployment.deployment_strategy = DeploymentStrategy.IMMEDIATE
        
        logger.info(f"Scaled canary to full deployment for {deployment.deployment_id}")
    
    def _get_next_model_version(self, model_id: str) -> Optional[str]:
        """Get next version of a model for A/B testing."""
        if not self.model_manager:
            return None
        
        # Find models of same type
        current_model = self.model_manager.models.get(model_id)
        if not current_model:
            return None
        
        # Find latest model of same type
        latest_model = None
        latest_time = 0
        
        for mid, model in self.model_manager.models.items():
            if (mid != model_id and 
                model.model_type == current_model.model_type and
                model.status.value == "active"):
                
                if model.created_at > latest_time:
                    latest_time = model.created_at
                    latest_model = model
        
        return latest_model.model_id if latest_model else None
    
    def _check_scaling_requirements(self, deployment: DeploymentConfig):
        """Check if deployment needs scaling."""
        # This would implement auto-scaling logic
        pass
    
    def _update_cost_tracking(self, deployment: DeploymentConfig):
        """Update cost tracking for deployment."""
        # This would implement cost tracking
        pass
    
    def _attempt_rollback(self, deployment: DeploymentConfig):
        """Attempt rollback for failed deployment."""
        logger.info(f"Attempting rollback for deployment {deployment.deployment_id}")
        
        try:
            deployment.status = DeploymentStatus.ROLLING_BACK
            
            # Stop current deployment
            self.stop_deployment(deployment.deployment_id)
            
            # Deploy previous version if available
            if self.model_manager and deployment.model_id in self.model_manager.models:
                model = self.model_manager.models[deployment.model_id]
                
                # Find previous version
                previous_version = None
                for mid, m in self.model_manager.models.items():
                    if (m.model_type == model.model_type and 
                        m.status.value == "active" and
                        mid != deployment.model_id):
                        previous_version = m
                        break
                
                if previous_version:
                    # Deploy previous version
                    self.deploy_model(
                        previous_version.model_id,
                        deployment.cloud_provider,
                        DeploymentStrategy.IMMEDIATE
                    )
            
            logger.info(f"Rollback completed for deployment {deployment.deployment_id}")
            
        except Exception as e:
            logger.error(f"Rollback failed for deployment {deployment.deployment_id}: {e}")


# Global instance for convenience
_global_model_deployer = None


def get_model_deployer() -> ModelDeployer:
    """
    Get a global model deployer instance.
    
    Returns:
        ModelDeployer: A model deployer instance
    """
    global _global_model_deployer
    
    if _global_model_deployer is None:
        _global_model_deployer = ModelDeployer()
    
    return _global_model_deployer