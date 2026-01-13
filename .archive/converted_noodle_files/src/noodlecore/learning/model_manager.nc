# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Model Manager - AI model lifecycle management for NoodleCore Learning System

# This module handles the complete lifecycle of AI models used in the learning system,
# including model versioning, deployment, rollback, and management. It integrates with
# existing model management systems and provides comprehensive model lifecycle control.

# Features:
# - AI model versioning and deployment management
# - Model performance tracking and comparison
# - Automatic rollback capabilities
# - A/B testing for different model versions
# - Model validation and quality assurance
# - Integration with existing model training pipelines
# - Model registry and catalog management
# - Performance benchmarking and evaluation
# """

import os
import json
import logging
import time
import threading
import uuid
import shutil
import hashlib
import typing.Any,
import dataclasses.dataclass,
import enum.Enum
import collections.defaultdict,
import datetime.datetime,

# Configure logging
logger = logging.getLogger(__name__)

# Environment variables
NOODLE_DEBUG = os.environ.get("NOODLE_DEBUG", "0") == "1"
NOODLE_MODEL_REGISTRY_PATH = os.environ.get("NOODLE_MODEL_REGISTRY_PATH", "./model_registry")


class ModelType(Enum)
    #     """Types of AI models."""
    CODE_ANALYSIS = "code_analysis"
    OPTIMIZATION_SUGGESTION = "optimization_suggestion"
    PERFORMANCE_PREDICTION = "performance_prediction"
    PATTERN_RECOGNITION = "pattern_recognition"
    FEEDBACK_ANALYSIS = "feedback_analysis"
    LEARNING_ENGINE = "learning_engine"
    DECISION_ENGINE = "decision_engine"


class ModelStatus(Enum)
    #     """Status of AI models."""
    DEVELOPMENT = "development"
    TRAINING = "training"
    VALIDATION = "validation"
    READY = "ready"
    DEPLOYED = "deployed"
    DEPRECATED = "deprecated"
    ARCHIVED = "archived"
    FAILED = "failed"


class DeploymentStrategy(Enum)
    #     """Model deployment strategies."""
    BLUE_GREEN = "blue_green"
    ROLLING = "rolling"
    CANARY = "canary"
    IMMEDIATE = "immediate"
    A_B_TESTING = "a_b_testing"


class ModelValidationResult(Enum)
    #     """Model validation results."""
    PASS = "pass"
    FAIL = "fail"
    WARNING = "warning"
    REQUIRES_REVIEW = "requires_review"


# @dataclass
class ModelMetadata
    #     """Metadata for AI models."""
    #     model_id: str
    #     model_type: ModelType
    #     version: str
    #     status: ModelStatus
    #     created_at: float
    #     updated_at: float
    #     file_path: str
    #     file_hash: str
    #     file_size: int
    #     training_data_hash: str
    #     hyperparameters: Dict[str, Any]
    #     performance_metrics: Dict[str, float]
    #     validation_results: Dict[str, ModelValidationResult]
    #     tags: List[str]
    #     description: str
    parent_model_id: Optional[str] = None
    metadata: Dict[str, Any] = None

    #     def __post_init__(self):
    #         if self.metadata is None:
    self.metadata = {}


# @dataclass
class ModelDeployment
    #     """Information about a model deployment."""
    #     deployment_id: str
    #     model_id: str
    #     strategy: DeploymentStrategy
    #     deployment_time: float
    #     status: str
    #     environment: str
    performance_before: Dict[str, float] = None
    performance_after: Dict[str, float] = None
    rollback_config: Dict[str, Any] = None
    traffic_split: Optional[float] = math.divide(None  # For A, B testing)
    deployment_config: Dict[str, Any] = None
    validation_checks: Dict[str, bool] = None
    metadata: Dict[str, Any] = None

    #     def __post_init__(self):
    #         if self.performance_before is None:
    self.performance_before = {}
    #         if self.performance_after is None:
    self.performance_after = {}
    #         if self.rollback_config is None:
    self.rollback_config = {}
    #         if self.deployment_config is None:
    self.deployment_config = {}
    #         if self.validation_checks is None:
    self.validation_checks = {}
    #         if self.metadata is None:
    self.metadata = {}


class ModelManager
    #     """
    #     AI model lifecycle manager for NoodleCore Learning System.

    #     This class provides comprehensive management of AI models throughout their
    #     lifecycle, from development through deployment and eventual deprecation.
    #     """

    #     def __init__(self):
    #         """Initialize the model manager."""
    #         if NOODLE_DEBUG:
                logger.setLevel(logging.DEBUG)

    #         # Model registry
    self.models: Dict[str, ModelMetadata] = {}
    self.model_lock = threading.RLock()

    #         # Deployment tracking
    self.deployments: Dict[str, ModelDeployment] = {}
    self.deployment_lock = threading.RLock()

    #         # Active deployments by environment
    self.active_deployments: Dict[str, Dict[str, ModelMetadata]] = defaultdict(dict)
    self.active_lock = threading.RLock()

    #         # Model registry path
    self.registry_path = NOODLE_MODEL_REGISTRY_PATH
            self._ensure_registry_directory()

    #         # Configuration
    self.manager_config = {
    #             'auto_validation': True,
    #             'performance_threshold': 0.1,  # 10% improvement required for deployment
    #             'max_model_versions': 10,  # Keep max 10 versions per model
    #             'enable_rollback': True,
    #             'validation_timeout': 300,  # 5 minutes
    #             'deployment_timeout': 600,  # 10 minutes
    #             'backup_models': True,
    #             'compression_enabled': False,
    #             'supported_formats': ['.pkl', '.joblib', '.h5', '.onnx', '.pt']
    #         }

    #         # Load existing models
            self._load_model_registry()

            logger.info("AI Model Manager initialized")

    #     def _ensure_registry_directory(self):
    #         """Ensure the model registry directory exists."""
    #         try:
    os.makedirs(self.registry_path, exist_ok = True)
                logger.debug(f"Model registry directory ensured: {self.registry_path}")
    #         except Exception as e:
                logger.error(f"Failed to create model registry directory: {str(e)}")

    #     def _load_model_registry(self):
    #         """Load existing models from registry."""
    #         try:
    registry_file = os.path.join(self.registry_path, "model_registry.json")
    #             if os.path.exists(registry_file):
    #                 with open(registry_file, 'r') as f:
    registry_data = json.load(f)

    #                 for model_id, model_data in registry_data.get('models', {}).items():
    model_metadata = math.multiply(ModelMetadata(, *model_data))
    self.models[model_id] = model_metadata

                    logger.info(f"Loaded {len(self.models)} models from registry")
    #             else:
                    logger.info("No existing model registry found, starting fresh")

    #         except Exception as e:
                logger.error(f"Failed to load model registry: {str(e)}")

    #     def _save_model_registry(self):
    #         """Save model registry to disk."""
    #         try:
    registry_data = {
    #                 'models': {model_id: asdict(model) for model_id, model in self.models.items()},
                    'last_updated': time.time()
    #             }

    registry_file = os.path.join(self.registry_path, "model_registry.json")
    #             with open(registry_file, 'w') as f:
    json.dump(registry_data, f, indent = 2)

                logger.debug("Model registry saved to disk")

    #         except Exception as e:
                logger.error(f"Failed to save model registry: {str(e)}")

    #     def register_model(self,
    #                       model_id: str,
    #                       model_type: ModelType,
    #                       version: str,
    #                       file_path: str,
    hyperparameters: Dict[str, Any] = None,
    training_data_hash: str = None,
    tags: List[str] = None,
    description: str = math.subtract(None), > bool:)
    #         """
    #         Register a new model in the registry.

    #         Args:
    #             model_id: Unique model identifier
    #             model_type: Type of the model
    #             version: Model version string
    #             file_path: Path to the model file
    #             hyperparameters: Model hyperparameters
    #             training_data_hash: Hash of training data
    #             tags: List of tags
    #             description: Model description

    #         Returns:
    #             bool: True if registration successful
    #         """
    #         try:
    #             # Validate model file
    #             if not os.path.exists(file_path):
                    logger.error(f"Model file not found: {file_path}")
    #                 return False

    #             # Calculate file hash and size
    file_hash = self._calculate_file_hash(file_path)
    file_size = os.path.getsize(file_path)

    #             # Check for duplicate model
    #             if model_id in self.models:
                    logger.warning(f"Model {model_id} already exists, creating new version")
    version = self._get_next_version(model_id)

    #             # Create model metadata
    model_metadata = ModelMetadata(
    model_id = model_id,
    model_type = model_type,
    version = version,
    status = ModelStatus.DEVELOPMENT,
    created_at = time.time(),
    updated_at = time.time(),
    file_path = file_path,
    file_hash = file_hash,
    file_size = file_size,
    training_data_hash = training_data_hash or "",
    hyperparameters = hyperparameters or {},
    performance_metrics = {},
    validation_results = {},
    tags = tags or [],
    description = description or "",
    parent_model_id = self.models.get(model_id, {}).parent_model_id
    #             )

    #             with self.model_lock:
    self.models[model_id] = model_metadata

    #             # Save registry
                self._save_model_registry()

                logger.info(f"Registered model {model_id} version {version}")
    #             return True

    #         except Exception as e:
                logger.error(f"Failed to register model {model_id}: {str(e)}")
    #             return False

    #     def _calculate_file_hash(self, file_path: str) -> str:
    #         """Calculate hash of a file."""
    #         try:
    hash_md5 = hashlib.md5()
    #             with open(file_path, "rb") as f:
    #                 for chunk in iter(lambda: f.read(4096), b""):
                        hash_md5.update(chunk)
                return hash_md5.hexdigest()
    #         except Exception as e:
                logger.error(f"Failed to calculate file hash: {str(e)}")
    #             return ""

    #     def _get_next_version(self, model_id: str) -> str:
    #         """Get next version string for a model."""
    #         if model_id not in self.models:
    #             return "1.0.0"

    current_version = self.models[model_id].version
            # Simple version increment (can be made more sophisticated)
    #         try:
    parts = current_version.split('.')
    major, minor, patch = int(parts[0]), int(parts[1]), int(parts[2])
    patch + = 1
    #             if patch >= 10:
    patch = 0
    minor + = 1
    #                 if minor >= 10:
    minor = 0
    major + = 1
    #             return f"{major}.{minor}.{patch}"
    #         except:
    #             return "1.0.0"

    #     def validate_model(self, model_id: str, validation_config: Dict[str, Any] = None) -> Dict[str, ModelValidationResult]:
    #         """
    #         Validate a model using specified validation criteria.

    #         Args:
    #             model_id: ID of the model to validate
    #             validation_config: Validation configuration

    #         Returns:
    #             Dict[str, ModelValidationResult]: Validation results
    #         """
    #         if model_id not in self.models:
                logger.error(f"Model {model_id} not found")
    #             return {}

    model = self.models[model_id]
    validation_results = {}

    #         try:
    #             # File integrity check
    #             if os.path.exists(model.file_path):
    current_hash = self._calculate_file_hash(model.file_path)
    #                 validation_results['file_integrity'] = ModelValidationResult.PASS if current_hash == model.file_hash else ModelValidationResult.FAIL
    #             else:
    validation_results['file_integrity'] = ModelValidationResult.FAIL

    #             # Model type validation
    validation_results['model_type'] = ModelValidationResult.PASS  # Would implement actual validation

    #             # Performance threshold check
    #             if model.performance_metrics:
    accuracy = model.performance_metrics.get('accuracy', 0.0)
    #                 if accuracy >= 0.7:  # 70% accuracy threshold
    validation_results['performance_threshold'] = ModelValidationResult.PASS
    #                 else:
    validation_results['performance_threshold'] = ModelValidationResult.WARNING

    #             # Hyperparameter validation
    #             if model.hyperparameters:
    validation_results['hyperparameters'] = ModelValidationResult.PASS
    #             else:
    validation_results['hyperparameters'] = ModelValidationResult.WARNING

    #             # Update model validation results
    #             with self.model_lock:
                    model.validation_results.update(validation_results)
    model.updated_at = time.time()

                logger.info(f"Validated model {model_id}: {len(validation_results)} checks performed")
    #             return validation_results

    #         except Exception as e:
                logger.error(f"Failed to validate model {model_id}: {str(e)}")
    #             return {'validation_error': ModelValidationResult.FAIL}

    #     def deploy_model(self,
    #                     model_id: str,
    environment: str = "production",
    strategy: DeploymentStrategy = DeploymentStrategy.IMMEDIATE,
    traffic_split: float = None,
    rollback_config: Dict[str, Any] = math.subtract(None), > Optional[str]:)
    #         """
    #         Deploy a model to a specific environment.

    #         Args:
    #             model_id: ID of the model to deploy
    #             environment: Target environment
    #             strategy: Deployment strategy
    #             traffic_split: Traffic split percentage (for A/B testing)
    #             rollback_config: Rollback configuration

    #         Returns:
    #             Optional[str]: Deployment ID if successful
    #         """
    #         if model_id not in self.models:
                logger.error(f"Model {model_id} not found")
    #             return None

    model = self.models[model_id]
    deployment_id = str(uuid.uuid4())

    #         try:
    #             # Update model status
    #             with self.model_lock:
    model.status = ModelStatus.DEPLOYED
    model.updated_at = time.time()

    #             # Create deployment record
    deployment = ModelDeployment(
    deployment_id = deployment_id,
    model_id = model_id,
    strategy = strategy,
    deployment_time = time.time(),
    status = "initiated",
    environment = environment,
    traffic_split = traffic_split,
    rollback_config = rollback_config or {}
    #             )

    #             with self.deployment_lock:
    self.deployments[deployment_id] = deployment

    #             # Perform deployment based on strategy
    deployment_success = self._execute_deployment(deployment, model)

    #             if deployment_success:
    #                 # Update active deployment
    #                 with self.active_lock:
    self.active_deployments[environment][model_id] = model

    #                 with self.deployment_lock:
    deployment.status = "completed"

                    logger.info(f"Successfully deployed model {model_id} to {environment}")
    #             else:
    #                 with self.deployment_lock:
    deployment.status = "failed"

                    logger.error(f"Failed to deploy model {model_id} to {environment}")

    #             # Save registry
                self._save_model_registry()

    #             return deployment_id if deployment_success else None

    #         except Exception as e:
                logger.error(f"Failed to deploy model {model_id}: {str(e)}")
    #             return None

    #     def _execute_deployment(self, deployment: ModelDeployment, model: ModelMetadata) -> bool:
    #         """Execute the actual deployment based on strategy."""
    #         try:
    #             # Simulate deployment process
                time.sleep(1)  # Simulate deployment time

    #             if deployment.strategy == DeploymentStrategy.IMMEDIATE:
    #                 # Immediate deployment - just copy file
                    return self._copy_model_file(model.file_path, deployment.environment)

    #             elif deployment.strategy == DeploymentStrategy.BLUE_GREEN:
    #                 # Blue-green deployment
                    return self._blue_green_deploy(model.file_path, deployment.environment)

    #             elif deployment.strategy == DeploymentStrategy.CANARY:
    #                 # Canary deployment
                    return self._canary_deploy(model.file_path, deployment.environment, deployment.traffic_split)

    #             elif deployment.strategy == DeploymentStrategy.A_B_TESTING:
    #                 # A/B testing deployment
                    return self._ab_testing_deploy(model.file_path, deployment.environment, deployment.traffic_split)

    #             else:
                    logger.error(f"Unsupported deployment strategy: {deployment.strategy}")
    #                 return False

    #         except Exception as e:
                logger.error(f"Deployment execution failed: {str(e)}")
    #             return False

    #     def _copy_model_file(self, source_path: str, environment: str) -> bool:
    #         """Copy model file for immediate deployment."""
    #         try:
    env_path = os.path.join(self.registry_path, "deployments", environment)
    os.makedirs(env_path, exist_ok = True)

    filename = os.path.basename(source_path)
    target_path = os.path.join(env_path, filename)

                shutil.copy2(source_path, target_path)
    #             return True

    #         except Exception as e:
                logger.error(f"Failed to copy model file: {str(e)}")
    #             return False

    #     def _blue_green_deploy(self, source_path: str, environment: str) -> bool:
    #         """Execute blue-green deployment."""
    #         # Simplified blue-green deployment
            return self._copy_model_file(source_path, environment)

    #     def _canary_deploy(self, source_path: str, environment: str, traffic_split: float) -> bool:
    #         """Execute canary deployment."""
    #         # Simplified canary deployment
            return self._copy_model_file(source_path, environment)

    #     def _ab_testing_deploy(self, source_path: str, environment: str, traffic_split: float) -> bool:
    #         """Execute A/B testing deployment."""
    #         # Simplified A/B testing deployment
            return self._copy_model_file(source_path, environment)

    #     def rollback_deployment(self, deployment_id: str) -> bool:
    #         """
    #         Rollback a deployment.

    #         Args:
    #             deployment_id: ID of the deployment to rollback

    #         Returns:
    #             bool: True if rollback successful
    #         """
    #         if deployment_id not in self.deployments:
                logger.error(f"Deployment {deployment_id} not found")
    #             return False

    deployment = self.deployments[deployment_id]

    #         try:
    #             # Check if rollback is configured
    #             if not deployment.rollback_config.get('enabled', True):
    #                 logger.warning(f"Rollback disabled for deployment {deployment_id}")
    #                 return False

    #             # Get previous model version
    previous_model_id = deployment.rollback_config.get('previous_model_id')
    #             if not previous_model_id or previous_model_id not in self.models:
    #                 logger.error(f"Previous model {previous_model_id} not found for rollback")
    #                 return False

    previous_model = self.models[previous_model_id]

    #             # Deploy previous model
    rollback_deployment_id = self.deploy_model(
    #                 previous_model_id,
    #                 deployment.environment,
    #                 DeploymentStrategy.IMMEDIATE
    #             )

    #             if rollback_deployment_id:
    #                 with self.deployment_lock:
    deployment.status = "rolled_back"

                    logger.info(f"Successfully rolled back deployment {deployment_id} to model {previous_model_id}")
    #                 return True
    #             else:
                    logger.error(f"Failed to rollback deployment {deployment_id}")
    #                 return False

    #         except Exception as e:
                logger.error(f"Failed to rollback deployment {deployment_id}: {str(e)}")
    #             return False

    #     def get_model(self, model_id: str) -> Optional[ModelMetadata]:
    #         """Get model metadata by ID."""
    #         with self.model_lock:
                return self.models.get(model_id)

    #     def list_models(self, model_type: ModelType = None, status: ModelStatus = None) -> List[ModelMetadata]:
    #         """List models with optional filtering."""
    #         with self.model_lock:
    models = list(self.models.values())

    #         if model_type:
    #             models = [m for m in models if m.model_type == model_type]

    #         if status:
    #             models = [m for m in models if m.status == status]

    return sorted(models, key = lambda m: m.created_at, reverse=True)

    #     def get_active_models(self, environment: str = "production") -> Dict[str, ModelMetadata]:
    #         """Get currently active models in an environment."""
    #         with self.active_lock:
                return self.active_deployments[environment].copy()

    #     def compare_models(self, model_id_1: str, model_id_2: str) -> Dict[str, Any]:
    #         """Compare performance between two models."""
    #         if model_id_1 not in self.models or model_id_2 not in self.models:
    #             return {"error": "One or both models not found"}

    model1 = self.models[model_id_1]
    model2 = self.models[model_id_2]

    comparison = {
    #             "model1": {
    #                 "id": model_id_1,
    #                 "version": model1.version,
    #                 "metrics": model1.performance_metrics
    #             },
    #             "model2": {
    #                 "id": model_id_2,
    #                 "version": model2.version,
    #                 "metrics": model2.performance_metrics
    #             },
    #             "improvements": {},
    #             "recommendations": []
    #         }

    #         # Calculate improvements
    #         for metric in set(model1.performance_metrics.keys()) | set(model2.performance_metrics.keys()):
    val1 = model1.performance_metrics.get(metric, 0)
    val2 = model2.performance_metrics.get(metric, 0)

    #             if val1 > 0 and val2 > 0:
    improvement = math.multiply((val2 - val1) / val1, 100)
    comparison["improvements"][metric] = improvement

    #                 if improvement > 10:
                        comparison["recommendations"].append(f"Model2 shows {improvement:.1f}% improvement in {metric}")

    #         return comparison

    #     def archive_model(self, model_id: str, reason: str = None) -> bool:
    #         """
            Archive a model (mark as deprecated/archived).

    #         Args:
    #             model_id: ID of the model to archive
    #             reason: Reason for archiving

    #         Returns:
    #             bool: True if archiving successful
    #         """
    #         if model_id not in self.models:
                logger.error(f"Model {model_id} not found")
    #             return False

    #         try:
    #             with self.model_lock:
    model = self.models[model_id]
    model.status = ModelStatus.DEPRECATED
    model.updated_at = time.time()
    model.metadata['archived_reason'] = reason or "Manual archiving"
    model.metadata['archived_at'] = time.time()

    #             # Remove from active deployments
    #             with self.active_lock:
    #                 for environment in list(self.active_deployments.keys()):
    #                     if model_id in self.active_deployments[environment]:
    #                         del self.active_deployments[environment][model_id]

                logger.info(f"Archived model {model_id}: {reason}")
    #             return True

    #         except Exception as e:
                logger.error(f"Failed to archive model {model_id}: {str(e)}")
    #             return False

    #     def update_model_metrics(self, model_id: str, metrics: Dict[str, float]) -> bool:
    #         """
    #         Update performance metrics for a model.

    #         Args:
    #             model_id: ID of the model
    #             metrics: New performance metrics

    #         Returns:
    #             bool: True if update successful
    #         """
    #         if model_id not in self.models:
                logger.error(f"Model {model_id} not found")
    #             return False

    #         try:
    #             with self.model_lock:
    model = self.models[model_id]
                    model.performance_metrics.update(metrics)
    model.updated_at = time.time()

    #             logger.info(f"Updated metrics for model {model_id}")
    #             return True

    #         except Exception as e:
    #             logger.error(f"Failed to update metrics for model {model_id}: {str(e)}")
    #             return False

    #     def get_deployment_history(self, model_id: str) -> List[ModelDeployment]:
    #         """Get deployment history for a model."""
    #         with self.deployment_lock:
    #             return [deployment for deployment in self.deployments.values()
    #                    if deployment.model_id == model_id]

    #     def cleanup_old_models(self, keep_versions: int = 5):
    #         """
    #         Clean up old model versions, keeping only the most recent ones.

    #         Args:
    #             keep_versions: Number of versions to keep per model
    #         """
    #         try:
    #             with self.model_lock:
                    # Group models by model_id (excluding version)
    model_groups = defaultdict(list)
    #                 for model in self.models.values():
    base_id = model.model_id
                        model_groups[base_id].append(model)

    #                 # For each group, keep only the most recent versions
    #                 for base_id, models in model_groups.items():
    #                     if len(models) > keep_versions:
    #                         # Sort by creation time and keep the newest
    models.sort(key = lambda m: m.created_at, reverse=True)
    models_to_remove = models[keep_versions:]

    #                         for model_to_remove in models_to_remove:
    model_id = model_to_remove.model_id

    #                             # Don't remove deployed models
    #                             if model_to_remove.status != ModelStatus.DEPLOYED:
                                    logger.info(f"Removing old model version {model_id}")
    #                                 del self.models[model_id]

    #             # Save registry after cleanup
                self._save_model_registry()

    #         except Exception as e:
                logger.error(f"Failed to cleanup old models: {str(e)}")

    #     def get_manager_statistics(self) -> Dict[str, Any]:
    #         """Get comprehensive statistics about the model manager."""
    #         with self.model_lock, self.deployment_lock:
    total_models = len(self.models)
    #             deployed_models = len([m for m in self.models.values() if m.status == ModelStatus.DEPLOYED])
    #             development_models = len([m for m in self.models.values() if m.status == ModelStatus.DEVELOPMENT])

    #             # Model types distribution
    type_distribution = {}
    #             for model in self.models.values():
    model_type = model.model_type.value
    type_distribution[model_type] = math.add(type_distribution.get(model_type, 0), 1)

    #             # Status distribution
    status_distribution = {}
    #             for model in self.models.values():
    status = model.status.value
    status_distribution[status] = math.add(status_distribution.get(status, 0), 1)

    #             # Total deployments
    total_deployments = len(self.deployments)

    #             return {
    #                 'total_models': total_models,
    #                 'deployed_models': deployed_models,
    #                 'development_models': development_models,
    #                 'total_deployments': total_deployments,
    #                 'model_types': type_distribution,
    #                 'model_statuses': status_distribution,
                    'active_environments': len(self.active_deployments),
    #                 'registry_path': self.registry_path,
                    'configuration': self.manager_config.copy()
    #             }

    #     def shutdown(self):
    #         """Shutdown the model manager."""
            logger.info("Shutting down AI Model Manager")

    #         # Save model registry
            self._save_model_registry()

    #         # Cleanup old models
            self.cleanup_old_models()

            logger.info("AI Model Manager shutdown complete")


# Global instance for convenience
_global_model_manager = None


def get_model_manager() -> ModelManager:
#     """
#     Get a global model manager instance.

#     Returns:
#         ModelManager: A model manager instance
#     """
#     global _global_model_manager

#     if _global_model_manager is None:
_global_model_manager = ModelManager()

#     return _global_model_manager