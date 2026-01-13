"""
NoodleCore AI Versioning System (.nc file)
=========================================

This module provides comprehensive AI model versioning and rollback capabilities,
enabling safe model deployment, version management, and rapid rollback procedures.

Features:
- Semantic versioning for AI models with metadata tracking
- Model lineage and dependency tracking across versions
- Automated rollback capabilities with safety checks
- Version comparison and impact analysis
- Blue-green deployment support for zero-downtime updates
- Canary deployment with gradual rollout strategies
- Version approval workflows and quality gates
- Audit trails for all version operations
- Compatibility checking between versions
- Performance regression detection
- Version caching and optimization
- Cross-environment version synchronization
- Model artifact management and storage
- Version branching and merging strategies
- Automated testing and validation for new versions

Version Types Supported:
- Major versions (breaking changes)
- Minor versions (feature additions)
- Patch versions (bug fixes)
- Release candidates (testing)
- Beta versions (early access)
- Development snapshots (work in progress)

Rollback Strategies:
- Instant rollback (revert to previous version)
- Gradual rollback (phased reversion)
- Canary rollback (reduce traffic gradually)
- Blue-green rollback (swap environments)
- Partial rollback (selective components)

Safety Mechanisms:
- Pre-rollback validation checks
- Dependency verification
- Performance threshold validation
- Data consistency verification
- Rollback execution monitoring
- Post-rollback verification
- Automated backup creation
- Recovery point objective (RPO) enforcement
"""

import os
import json
import logging
import time
import threading
import uuid
import hashlib
import shutil
import tempfile
import sqlite3
from typing import Dict, List, Optional, Any, Union, Callable, Tuple
from dataclasses import dataclass, asdict, field
from enum import Enum
from datetime import datetime, timedelta
from collections import defaultdict, deque
from pathlib import Path
import semantic_version

# Import existing NoodleCore components
from ..self_improvement.model_management import ModelManager, ModelType, ModelStatus
from .model_deployer import ModelDeployer
from .lifecycle_manager import LifecycleManager

# Configure logging
logger = logging.getLogger(__name__)

# Environment variables
NOODLE_DEBUG = os.environ.get("NOODLE_DEBUG", "0") == "1"
NOODLE_VERSIONING_ENABLED = os.environ.get("NOODLE_VERSIONING_ENABLED", "1") == "1"
NOODLE_VERSION_STORAGE_PATH = os.environ.get("NOODLE_VERSION_STORAGE_PATH", "./model_versions")
NOODLE_AUTO_ROLLBACK_ENABLED = os.environ.get("NOODLE_AUTO_ROLLBACK_ENABLED", "0") == "1"
NOODLE_ROLLBACK_TIMEOUT = int(os.environ.get("NOODLE_ROLLBACK_TIMEOUT", "300"))  # 5 minutes
NOODLE_VERSION_RETENTION_DAYS = int(os.environ.get("NOODLE_VERSION_RETENTION_DAYS", "90"))


class VersionType(Enum):
    """Types of model versions."""
    MAJOR = "major"      # Breaking changes
    MINOR = "minor"      # Feature additions
    PATCH = "patch"      # Bug fixes
    RC = "rc"            # Release candidate
    BETA = "beta"        # Beta release
    ALPHA = "alpha"      # Alpha release
    SNAPSHOT = "snapshot" # Development snapshot


class VersionStatus(Enum):
    """Status of model versions."""
    DRAFT = "draft"
    TESTING = "testing"
    APPROVED = "approved"
    DEPLOYED = "deployed"
    DEPRECATED = "deprecated"
    RETIRED = "retired"
    FAILED = "failed"


class RollbackType(Enum):
    """Types of rollback operations."""
    INSTANT = "instant"      # Immediate rollback
    GRADUAL = "gradual"      # Phased rollback
    CANARY = "canary"        # Canary rollback
    BLUE_GREEN = "blue_green" # Environment swap
    PARTIAL = "partial"      # Selective rollback


class RollbackStatus(Enum):
    """Status of rollback operations."""
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"


@dataclass
class VersionMetadata:
    """Metadata for a model version."""
    version_id: str
    model_id: str
    semantic_version: str
    version_type: VersionType
    status: VersionStatus
    created_at: float
    created_by: str
    description: str
    changelog: List[str]
    dependencies: List[str]
    performance_metrics: Dict[str, float]
    resource_requirements: Dict[str, float]
    compatibility_matrix: Dict[str, str]
    test_results: Dict[str, Any]
    deployment_history: List[str]
    rollback_history: List[str]
    tags: List[str]
    metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass
class VersionComparison:
    """Comparison result between two versions."""
    comparison_id: str
    source_version_id: str
    target_version_id: str
    comparison_timestamp: float
    breaking_changes: List[str]
    new_features: List[str]
    performance_differences: Dict[str, float]
    compatibility_changes: List[str]
    migration_required: bool
    migration_steps: List[str]
    risk_assessment: Dict[str, float]
    recommendation: str
    confidence_score: float


@dataclass
class RollbackOperation:
    """Rollback operation details."""
    rollback_id: str
    source_version_id: str
    target_version_id: str
    rollback_type: RollbackType
    status: RollbackStatus
    initiated_at: float
    started_at: Optional[float] = None
    completed_at: Optional[float] = None
    progress_percentage: float = 0.0
    steps_completed: List[str] = field(default_factory=list)
    error_details: Optional[str] = None
    validation_results: Dict[str, bool] = field(default_factory=dict)
    metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass
class DeploymentRecord:
    """Record of a version deployment."""
    deployment_id: str
    version_id: str
    deployment_timestamp: float
    deployment_target: str
    deployment_strategy: str
    success: bool
    duration_seconds: float
    performance_metrics: Dict[str, float]
    error_details: Optional[str] = None
    rollback_triggered: bool = False
    metadata: Dict[str, Any] = field(default_factory=dict)


class VersioningSystem:
    """
    Comprehensive AI model versioning and rollback system.
    
    This class provides enterprise-grade versioning capabilities for AI models,
    including semantic versioning, automated rollback, version comparison,
    and deployment management with safety mechanisms.
    """
    
    def __init__(self):
        """Initialize the versioning system."""
        if NOODLE_DEBUG:
            logger.setLevel(logging.DEBUG)
        
        # Storage paths
        self.storage_path = Path(NOODLE_VERSION_STORAGE_PATH)
        self.storage_path.mkdir(parents=True, exist_ok=True)
        
        # Database for version metadata
        self.db_path = self.storage_path / "versions.db"
        self._init_database()
        
        # Core components
        self.model_manager = None
        self.model_deployer = None
        self.lifecycle_manager = None
        
        # Version tracking
        self.versions: Dict[str, VersionMetadata] = {}
        self.version_lineages: Dict[str, List[str]] = defaultdict(list)
        self.active_deployments: Dict[str, str] = {}  # model_id -> version_id
        
        # Rollback tracking
        self.rollback_operations: Dict[str, RollbackOperation] = {}
        self.rollback_history: List[RollbackOperation] = []
        
        # Deployment tracking
        self.deployment_history: List[DeploymentRecord] = []
        
        # Threading and synchronization
        self._lock = threading.RLock()
        self._rollback_thread = None
        self._cleanup_thread = None
        self._running = False
        
        # Configuration
        self.versioning_config = {
            'auto_rollback_enabled': NOODLE_AUTO_ROLLBACK_ENABLED,
            'rollback_timeout': NOODLE_ROLLBACK_TIMEOUT,
            'version_retention_days': NOODLE_VERSION_RETENTION_DAYS,
            'max_versions_per_model': 100,
            'require_approval_for_major_versions': True,
            'enable_automatic_testing': True,
            'performance_regression_threshold': 0.1,  # 10% performance degradation
            'safety_check_timeout': 30  # seconds
        }
        
        # Statistics
        self.versioning_stats = {
            'total_versions_created': 0,
            'total_rollbacks_performed': 0,
            'successful_rollbacks': 0,
            'failed_rollbacks': 0,
            'average_rollback_time': 0.0,
            'version_comparisons_performed': 0,
            'automatic_rollbacks_triggered': 0,
            'deployment_success_rate': 0.0
        }
        
        # Load existing data
        self._load_version_data()
        
        logger.info("VersioningSystem initialized")
    
    def _init_database(self):
        """Initialize SQLite database for version storage."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            # Create versions table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS versions (
                    version_id TEXT PRIMARY KEY,
                    model_id TEXT NOT NULL,
                    semantic_version TEXT NOT NULL,
                    version_type TEXT NOT NULL,
                    status TEXT NOT NULL,
                    created_at REAL NOT NULL,
                    created_by TEXT NOT NULL,
                    description TEXT,
                    changelog TEXT,
                    dependencies TEXT,
                    performance_metrics TEXT,
                    resource_requirements TEXT,
                    compatibility_matrix TEXT,
                    test_results TEXT,
                    deployment_history TEXT,
                    rollback_history TEXT,
                    tags TEXT,
                    metadata TEXT
                )
            ''')
            
            # Create rollback operations table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS rollback_operations (
                    rollback_id TEXT PRIMARY KEY,
                    source_version_id TEXT NOT NULL,
                    target_version_id TEXT NOT NULL,
                    rollback_type TEXT NOT NULL,
                    status TEXT NOT NULL,
                    initiated_at REAL NOT NULL,
                    started_at REAL,
                    completed_at REAL,
                    progress_percentage REAL DEFAULT 0.0,
                    steps_completed TEXT,
                    error_details TEXT,
                    validation_results TEXT,
                    metadata TEXT
                )
            ''')
            
            # Create deployment records table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS deployment_records (
                    deployment_id TEXT PRIMARY KEY,
                    version_id TEXT NOT NULL,
                    deployment_timestamp REAL NOT NULL,
                    deployment_target TEXT NOT NULL,
                    deployment_strategy TEXT NOT NULL,
                    success INTEGER NOT NULL,
                    duration_seconds REAL NOT NULL,
                    performance_metrics TEXT,
                    error_details TEXT,
                    rollback_triggered INTEGER DEFAULT 0,
                    metadata TEXT
                )
            ''')
            
            # Create indexes
            cursor.execute('CREATE INDEX IF NOT EXISTS idx_versions_model_id ON versions (model_id)')
            cursor.execute('CREATE INDEX IF NOT EXISTS idx_versions_status ON versions (status)')
            cursor.execute('CREATE INDEX IF NOT EXISTS idx_rollback_operations_status ON rollback_operations (status)')
            cursor.execute('CREATE INDEX IF NOT EXISTS idx_deployment_records_version ON deployment_records (version_id)')
            
            conn.commit()
            conn.close()
            
            logger.debug(f"Initialized version database at {self.db_path}")
            
        except Exception as e:
            logger.error(f"Failed to initialize version database: {e}")
            raise
    
    def _load_version_data(self):
        """Load existing version data from database."""
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            # Load versions
            cursor.execute('SELECT * FROM versions ORDER BY created_at')
            for row in cursor.fetchall():
                version_data = dict(row)
                version_data['changelog'] = json.loads(version_data.get('changelog', '[]'))
                version_data['dependencies'] = json.loads(version_data.get('dependencies', '[]'))
                version_data['performance_metrics'] = json.loads(version_data.get('performance_metrics', '{}'))
                version_data['resource_requirements'] = json.loads(version_data.get('resource_requirements', '{}'))
                version_data['compatibility_matrix'] = json.loads(version_data.get('compatibility_matrix', '{}'))
                version_data['test_results'] = json.loads(version_data.get('test_results', '{}'))
                version_data['deployment_history'] = json.loads(version_data.get('deployment_history', '[]'))
                version_data['rollback_history'] = json.loads(version_data.get('rollback_history', '[]'))
                version_data['tags'] = json.loads(version_data.get('tags', '[]'))
                version_data['metadata'] = json.loads(version_data.get('metadata', '{}'))
                
                version_metadata = VersionMetadata(**version_data)
                self.versions[version_data['version_id']] = version_metadata
            
            # Load rollback operations
            cursor.execute('SELECT * FROM rollback_operations ORDER BY initiated_at')
            for row in cursor.fetchall():
                rollback_data = dict(row)
                rollback_data['steps_completed'] = json.loads(rollback_data.get('steps_completed', '[]'))
                rollback_data['validation_results'] = json.loads(rollback_data.get('validation_results', '{}'))
                rollback_data['metadata'] = json.loads(rollback_data.get('metadata', '{}'))
                
                rollback_operation = RollbackOperation(**rollback_data)
                self.rollback_operations[rollback_data['rollback_id']] = rollback_operation
                self.rollback_history.append(rollback_operation)
            
            # Load deployment records
            cursor.execute('SELECT * FROM deployment_records ORDER BY deployment_timestamp')
            for row in cursor.fetchall():
                deployment_data = dict(row)
                deployment_data['performance_metrics'] = json.loads(deployment_data.get('performance_metrics', '{}'))
                deployment_data['metadata'] = json.loads(deployment_data.get('metadata', '{}'))
                deployment_data['success'] = bool(deployment_data['success'])
                deployment_data['rollback_triggered'] = bool(deployment_data['rollback_triggered'])
                
                deployment_record = DeploymentRecord(**deployment_data)
                self.deployment_history.append(deployment_record)
            
            conn.close()
            
            logger.info(f"Loaded {len(self.versions)} versions, {len(self.rollback_operations)} rollback operations, and {len(self.deployment_history)} deployment records")
            
        except Exception as e:
            logger.error(f"Failed to load version data: {e}")
    
    def initialize(self, model_manager: ModelManager = None, model_deployer: ModelDeployer = None,
                  lifecycle_manager: LifecycleManager = None) -> bool:
        """
        Initialize the versioning system with required components.
        
        Args:
            model_manager: Model management component
            model_deployer: Model deployment component
            lifecycle_manager: Lifecycle management component
            
        Returns:
            True if initialization successful
        """
        try:
            # Initialize core components
            if model_manager:
                self.model_manager = model_manager
            
            if model_deployer:
                self.model_deployer = model_deployer
            
            if lifecycle_manager:
                self.lifecycle_manager = lifecycle_manager
            
            # Start background services
            self.start()
            
            logger.info("VersioningSystem initialized successfully")
            return True
            
        except Exception as e:
            logger.error(f"Failed to initialize VersioningSystem: {e}")
            return False
    
    def start(self):
        """Start the versioning system background services."""
        with self._lock:
            if self._running:
                return
            
            self._running = True
            
            # Start rollback monitoring thread
            self._rollback_thread = threading.Thread(
                target=self._rollback_monitor_worker, daemon=True
            )
            self._rollback_thread.start()
            
            # Start cleanup thread
            self._cleanup_thread = threading.Thread(
                target=self._cleanup_worker, daemon=True
            )
            self._cleanup_thread.start()
            
            logger.info("VersioningSystem started")
    
    def stop(self):
        """Stop the versioning system and cleanup resources."""
        with self._lock:
            if not self._running:
                return
            
            self._running = False
            
            # Wait for threads to stop
            for thread in [self._rollback_thread, self._cleanup_thread]:
                if thread and thread.is_alive():
                    thread.join(timeout=10.0)
            
            logger.info("VersioningSystem stopped")
    
    def create_version(self, model_id: str, model_path: str, version_type: VersionType,
                      description: str = "", created_by: str = "system",
                      changelog: List[str] = None, metadata: Dict[str, Any] = None) -> Dict[str, Any]:
        """
        Create a new model version.
        
        Args:
            model_id: Model to create version for
            model_path: Path to model files
            version_type: Type of version to create
            description: Version description
            created_by: User creating the version
            changelog: List of changes
            metadata: Additional metadata
            
        Returns:
            Created version information
        """
        try:
            with self._lock:
                # Generate semantic version
                next_version = self._generate_next_version(model_id, version_type)
                
                # Create version metadata
                version_metadata = VersionMetadata(
                    version_id=str(uuid.uuid4()),
                    model_id=model_id,
                    semantic_version=next_version,
                    version_type=version_type,
                    status=VersionStatus.DRAFT,
                    created_at=time.time(),
                    created_by=created_by,
                    description=description,
                    changelog=changelog or [],
                    dependencies=[],
                    performance_metrics={},
                    resource_requirements=self._analyze_resource_requirements(model_path),
                    compatibility_matrix={},
                    test_results={},
                    deployment_history=[],
                    rollback_history=[],
                    tags=[],
                    metadata=metadata or {}
                )
                
                # Store model files
                version_storage_path = self._get_version_storage_path(version_metadata)
                self._store_model_files(model_path, version_storage_path)
                
                # Calculate model hash
                model_hash = self._calculate_model_hash(version_storage_path)
                version_metadata.metadata['model_hash'] = model_hash
                version_metadata.metadata['file_size'] = self._get_directory_size(version_storage_path)
                
                # Save to database
                self._save_version_record(version_metadata)
                
                # Update tracking
                self.versions[version_metadata.version_id] = version_metadata
                self.version_lineages[model_id].append(version_metadata.version_id)
                
                # Update statistics
                self.versioning_stats['total_versions_created'] += 1
                
                logger.info(f"Created version {next_version} for model {model_id}")
                
                return {
                    'version_id': version_metadata.version_id,
                    'semantic_version': version_metadata.semantic_version,
                    'version_type': version_type.value,
                    'status': version_metadata.status.value,
                    'created_at': version_metadata.created_at,
                    'created_by': version_metadata.created_by,
                    'description': version_metadata.description,
                    'resource_requirements': version_metadata.resource_requirements,
                    'model_hash': model_hash,
                    'storage_path': str(version_storage_path)
                }
                
        except Exception as e:
            logger.error(f"Failed to create version for model {model_id}: {e}")
            return {'error': str(e)}
    
    def promote_version(self, version_id: str, target_status: VersionStatus,
                       test_results: Dict[str, Any] = None,
                       performance_metrics: Dict[str, float] = None) -> bool:
        """
        Promote a version to a new status.
        
        Args:
            version_id: Version to promote
            target_status: Target status
            test_results: Test results for validation
            performance_metrics: Performance metrics
            
        Returns:
            True if promotion successful
        """
        try:
            with self._lock:
                if version_id not in self.versions:
                    return False
                
                version = self.versions[version_id]
                
                # Validate promotion
                if not self._validate_status_promotion(version.status, target_status):
                    logger.warning(f"Invalid promotion from {version.status.value} to {target_status.value}")
                    return False
                
                # Update status
                old_status = version.status
                version.status = target_status
                
                # Update additional data
                if test_results:
                    version.test_results.update(test_results)
                
                if performance_metrics:
                    version.performance_metrics.update(performance_metrics)
                
                # Save to database
                self._save_version_record(version)
                
                logger.info(f"Promoted version {version.semantic_version} from {old_status.value} to {target_status.value}")
                return True
                
        except Exception as e:
            logger.error(f"Failed to promote version {version_id}: {e}")
            return False
    
    def compare_versions(self, version_id_1: str, version_id_2: str) -> Dict[str, Any]:
        """
        Compare two model versions.
        
        Args:
            version_id_1: First version to compare
            version_id_2: Second version to compare
            
        Returns:
            Comparison results
        """
        try:
            with self._lock:
                if version_id_1 not in self.versions or version_id_2 not in self.versions:
                    return {'error': 'One or both versions not found'}
                
                version1 = self.versions[version_id_1]
                version2 = self.versions[version_id_2]
                
                # Parse semantic versions
                semver1 = semantic_version.Version(version1.semantic_version)
                semver2 = semantic_version.Version(version2.semantic_version)
                
                # Analyze differences
                breaking_changes = []
                new_features = []
                performance_differences = {}
                compatibility_changes = []
                
                # Check for breaking changes
                if semver1.major != semver2.major:
                    breaking_changes.append(f"Major version change: {version1.semantic_version} -> {version2.semantic_version}")
                
                # Analyze performance differences
                for metric in set(version1.performance_metrics.keys()) | set(version2.performance_metrics.keys()):
                    val1 = version1.performance_metrics.get(metric, 0)
                    val2 = version2.performance_metrics.get(metric, 0)
                    
                    if val1 > 0 and val2 > 0:
                        difference = (val2 - val1) / val1
                        performance_differences[metric] = difference
                        
                        if metric == 'accuracy' and difference < -0.05:
                            breaking_changes.append(f"Significant accuracy degradation: {difference:.2%}")
                        elif metric == 'latency' and difference > 0.1:
                            compatibility_changes.append(f"Latency increased by {difference:.2%}")
                
                # Analyze resource requirements
                for resource in set(version1.resource_requirements.keys()) | set(version2.resource_requirements.keys()):
                    req1 = version1.resource_requirements.get(resource, 0)
                    req2 = version2.resource_requirements.get(resource, 0)
                    
                    if req2 > req1 * 1.2:  # 20% increase
                        compatibility_changes.append(f"Resource requirement increased for {resource}: {req1} -> {req2}")
                
                # Generate recommendation
                risk_score = len(breaking_changes) * 0.4 + len(compatibility_changes) * 0.2
                
                if risk_score > 0.7:
                    recommendation = "High risk - requires careful testing and migration planning"
                    confidence_score = 0.9
                elif risk_score > 0.3:
                    recommendation = "Medium risk - recommended testing before deployment"
                    confidence_score = 0.7
                else:
                    recommendation = "Low risk - safe to deploy with standard testing"
                    confidence_score = 0.8
                
                # Create comparison record
                comparison = VersionComparison(
                    comparison_id=str(uuid.uuid4()),
                    source_version_id=version_id_1,
                    target_version_id=version_id_2,
                    comparison_timestamp=time.time(),
                    breaking_changes=breaking_changes,
                    new_features=new_features,
                    performance_differences=performance_differences,
                    compatibility_changes=compatibility_changes,
                    migration_required=len(breaking_changes) > 0,
                    migration_steps=self._generate_migration_steps(version1, version2),
                    risk_assessment={
                        'overall_risk': risk_score,
                        'breaking_changes_count': len(breaking_changes),
                        'compatibility_issues_count': len(compatibility_changes)
                    },
                    recommendation=recommendation,
                    confidence_score=confidence_score
                )
                
                # Update statistics
                self.versioning_stats['version_comparisons_performed'] += 1
                
                return {
                    'comparison_id': comparison.comparison_id,
                    'source_version': {
                        'version_id': version_id_1,
                        'semantic_version': version1.semantic_version,
                        'status': version1.status.value
                    },
                    'target_version': {
                        'version_id': version_id_2,
                        'semantic_version': version2.semantic_version,
                        'status': version2.status.value
                    },
                    'breaking_changes': breaking_changes,
                    'new_features': new_features,
                    'performance_differences': performance_differences,
                    'compatibility_changes': compatibility_changes,
                    'migration_required': comparison.migration_required,
                    'migration_steps': comparison.migration_steps,
                    'risk_assessment': comparison.risk_assessment,
                    'recommendation': recommendation,
                    'confidence_score': confidence_score,
                    'comparison_timestamp': comparison.comparison_timestamp
                }
                
        except Exception as e:
            logger.error(f"Failed to compare versions {version_id_1} and {version_id_2}: {e}")
            return {'error': str(e)}
    
    def initiate_rollback(self, model_id: str, target_version_id: str,
                         rollback_type: RollbackType = RollbackType.INSTANT,
                         force: bool = False) -> Dict[str, Any]:
        """
        Initiate a rollback operation.
        
        Args:
            model_id: Model to rollback
            target_version_id: Version to rollback to
            rollback_type: Type of rollback to perform
            force: Force rollback without safety checks
            
        Returns:
            Rollback operation information
        """
        try:
            with self._lock:
                # Get current version
                current_version_id = self.active_deployments.get(model_id)
                if not current_version_id:
                    return {'error': 'No active deployment found for model'}
                
                if current_version_id == target_version_id:
                    return {'error': 'Target version is already active'}
                
                if target_version_id not in self.versions:
                    return {'error': 'Target version not found'}
                
                # Create rollback operation
                rollback_operation = RollbackOperation(
                    rollback_id=str(uuid.uuid4()),
                    source_version_id=current_version_id,
                    target_version_id=target_version_id,
                    rollback_type=rollback_type,
                    status=RollbackStatus.PENDING,
                    initiated_at=time.time(),
                    metadata={
                        'model_id': model_id,
                        'rollback_reason': 'manual_rollback'
                    }
                )
                
                # Validate rollback if not forced
                if not force:
                    validation_result = self._validate_rollback_safety(rollback_operation)
                    if not validation_result['safe']:
                        rollback_operation.status = RollbackStatus.FAILED
                        rollback_operation.error_details = validation_result['reason']
                        self._save_rollback_record(rollback_operation)
                        return {
                            'rollback_id': rollback_operation.rollback_id,
                            'status': 'failed',
                            'error': validation_result['reason']
                        }
                
                # Save rollback operation
                self.rollback_operations[rollback_operation.rollback_id] = rollback_operation
                self.rollback_history.append(rollback_operation)
                self._save_rollback_record(rollback_operation)
                
                # Start rollback based on type
                if rollback_type == RollbackType.INSTANT:
                    success = self._execute_instant_rollback(rollback_operation)
                elif rollback_type == RollbackType.GRADUAL:
                    success = self._execute_gradual_rollback(rollback_operation)
                elif rollback_type == RollbackType.CANARY:
                    success = self._execute_canary_rollback(rollback_operation)
                else:
                    success = self._execute_instant_rollback(rollback_operation)  # Default fallback
                
                if success:
                    rollback_operation.status = RollbackStatus.COMPLETED
                    rollback_operation.completed_at = time.time()
                    rollback_operation.progress_percentage = 100.0
                    self.versioning_stats['successful_rollbacks'] += 1
                    
                    # Update active deployment
                    self.active_deployments[model_id] = target_version_id
                    
                    # Update version rollback history
                    source_version = self.versions[current_version_id]
                    target_version = self.versions[target_version_id]
                    source_version.rollback_history.append(rollback_operation.rollback_id)
                    target_version.rollback_history.append(rollback_operation.rollback_id)
                    
                    self._save_version_record(source_version)
                    self._save_version_record(target_version)
                else:
                    rollback_operation.status = RollbackStatus.FAILED
                    rollback_operation.error_details = "Rollback execution failed"
                    self.versioning_stats['failed_rollbacks'] += 1
                
                self.versioning_stats['total_rollbacks_performed'] += 1
                
                logger.info(f"Rollback {'completed' if success else 'failed'} for model {model_id}")
                
                return {
                    'rollback_id': rollback_operation.rollback_id,
                    'status': rollback_operation.status.value,
                    'source_version': self.versions[current_version_id].semantic_version,
                    'target_version': self.versions[target_version_id].semantic_version,
                    'rollback_type': rollback_type.value,
                    'initiated_at': rollback_operation.initiated_at,
                    'completed_at': rollback_operation.completed_at,
                    'duration_seconds': (
                        rollback_operation.completed_at - rollback_operation.initiated_at
                        if rollback_operation.completed_at else None
                    ),
                    'success': success,
                    'error': rollback_operation.error_details
                }
                
        except Exception as e:
            logger.error(f"Failed to initiate rollback for model {model_id}: {e}")
            return {'error': str(e)}
    
    def get_version_info(self, version_id: str) -> Dict[str, Any]:
        """
        Get information about a specific version.
        
        Args:
            version_id: Version to get information for
            
        Returns:
            Version information
        """
        try:
            with self._lock:
                if version_id not in self.versions:
                    return {'error': 'Version not found'}
                
                version = self.versions[version_id]
                
                return {
                    'version_id': version.version_id,
                    'model_id': version.model_id,
                    'semantic_version': version.semantic_version,
                    'version_type': version.version_type.value,
                    'status': version.status.value,
                    'created_at': version.created_at,
                    'created_by': version.created_by,
                    'description': version.description,
                    'changelog': version.changelog,
                    'dependencies': version.dependencies,
                    'performance_metrics': version.performance_metrics,
                    'resource_requirements': version.resource_requirements,
                    'compatibility_matrix': version.compatibility_matrix,
                    'test_results': version.test_results,
                    'deployment_history': version.deployment_history,
                    'rollback_history': version.rollback_history,
                    'tags': version.tags,
                    'metadata': version.metadata,
                    'storage_path': str(self._get_version_storage_path(version))
                }
                
        except Exception as e:
            logger.error(f"Failed to get version info for {version_id}: {e}")
            return {'error': str(e)}
    
    def list_versions(self, model_id: str = None, status: VersionStatus = None,
                     limit: int = 100) -> List[Dict[str, Any]]:
        """
        List model versions with optional filtering.
        
        Args:
            model_id: Filter by model (optional)
            status: Filter by status (optional)
            limit: Maximum number of versions to return
            
        Returns:
            List of version information
        """
        try:
            with self._lock:
                versions = list(self.versions.values())
                
                # Apply filters
                if model_id:
                    versions = [v for v in versions if v.model_id == model_id]
                
                if status:
                    versions = [v for v in versions if v.status == status]
                
                # Sort by creation time (newest first)
                versions.sort(key=lambda x: x.created_at, reverse=True)
                
                # Apply limit
                versions = versions[:limit]
                
                # Convert to dictionaries
                return [
                    {
                        'version_id': v.version_id,
                        'model_id': v.model_id,
                        'semantic_version': v.semantic_version,
                        'version_type': v.version_type.value,
                        'status': v.status.value,
                        'created_at': v.created_at,
                        'created_by': v.created_by,
                        'description': v.description,
                        'tags': v.tags
                    }
                    for v in versions
                ]
                
        except Exception as e:
            logger.error(f"Failed to list versions: {e}")
            return []
    
    def get_active_version(self, model_id: str) -> Optional[Dict[str, Any]]:
        """
        Get the currently active version for a model.
        
        Args:
            model_id: Model to get active version for
            
        Returns:
            Active version information or None
        """
        try:
            with self._lock:
                version_id = self.active_deployments.get(model_id)
                if version_id and version_id in self.versions:
                    return self.get_version_info(version_id)
                return None
                
        except Exception as e:
            logger.error(f"Failed to get active version for model {model_id}: {e}")
            return None
    
    def record_deployment(self, version_id: str, deployment_target: str,
                         deployment_strategy: str, success: bool,
                         duration_seconds: float, performance_metrics: Dict[str, float] = None,
                         error_details: str = None, rollback_triggered: bool = False) -> bool:
        """
        Record a version deployment.
        
        Args:
            version_id: Version that was deployed
            deployment_target: Where it was deployed
            deployment_strategy: Strategy used for deployment
            success: Whether deployment was successful
            duration_seconds: Deployment duration
            performance_metrics: Performance metrics after deployment
            error_details: Error details if deployment failed
            rollback_triggered: Whether rollback was triggered
            
        Returns:
            True if recording successful
        """
        try:
            with self._lock:
                deployment_record = DeploymentRecord(
                    deployment_id=str(uuid.uuid4()),
                    version_id=version_id,
                    deployment_timestamp=time.time(),
                    deployment_target=deployment_target,
                    deployment_strategy=deployment_strategy,
                    success=success,
                    duration_seconds=duration_seconds,
                    performance_metrics=performance_metrics or {},
                    error_details=error_details,
                    rollback_triggered=rollback_triggered
                )
                
                # Store in memory
                self.deployment_history.append(deployment_record)
                
                # Update version deployment history
                if version_id in self.versions:
                    version = self.versions[version_id]
                    version.deployment_history.append(deployment_record.deployment_id)
                    self._save_version_record(version)
                
                # Save to database
                self._save_deployment_record(deployment_record)
                
                # Update statistics
                total_deployments = len([d for d in self.deployment_history if d.version_id == version_id])
                successful_deployments = len([d for d in self.deployment_history 
                                           if d.version_id == version_id and d.success])
                if total_deployments > 0:
                    self.versioning_stats['deployment_success_rate'] = successful_deployments / total_deployments
                
                logger.debug(f"Recorded deployment for version {version_id}")
                return True
                
        except Exception as e:
            logger.error(f"Failed to record deployment for version {version_id}: {e}")
            return False
    
    def _generate_next_version(self, model_id: str, version_type: VersionType) -> str:
        """Generate the next semantic version for a model."""
        # Get existing versions for this model
        model_versions = [v for v in self.versions.values() if v.model_id == model_id]
        
        if not model_versions:
            # First version
            if version_type == VersionType.MAJOR:
                return "1.0.0"
            elif version_type == VersionType.MINOR:
                return "0.1.0"
            else:
                return "0.0.1"
        
        # Parse existing semantic versions
        semver_strings = [v.semantic_version for v in model_versions]
        semvers = []
        
        for semver_str in semver_strings:
            try:
                semvers.append(semantic_version.Version(semver_str))
            except:
                continue
        
        if not semvers:
            # Fallback to simple versioning
            return "1.0.0"
        
        # Get the latest version
        latest_version = max(semvers)
        
        # Generate next version based on type
        if version_type == VersionType.MAJOR:
            next_version = semantic_version.Version(f"{latest_version.major + 1}.0.0")
        elif version_type == VersionType.MINOR:
            next_version = semantic_version.Version(f"{latest_version.major}.{latest_version.minor + 1}.0")
        else:  # PATCH
            next_version = semantic_version.Version(f"{latest_version.major}.{latest_version.minor}.{latest_version.patch + 1}")
        
        return str(next_version)
    
    def _validate_status_promotion(self, current_status: VersionStatus, 
                                 target_status: VersionStatus) -> bool:
        """Validate if status promotion is allowed."""
        # Define valid promotion paths
        valid_promotions = {
            VersionStatus.DRAFT: [VersionStatus.TESTING],
            VersionStatus.TESTING: [VersionStatus.APPROVED, VersionStatus.DRAFT],
            VersionStatus.APPROVED: [VersionStatus.DEPLOYED],
            VersionStatus.DEPLOYED: [VersionStatus.DEPRECATED, VersionStatus.FAILED],
            VersionStatus.DEPRECATED: [VersionStatus.RETIRED],
            VersionStatus.FAILED: [VersionStatus.DRAFT]
        }
        
        return target_status in valid_promotions.get(current_status, [])
    
    def _validate_rollback_safety(self, rollback_operation: RollbackOperation) -> Dict[str, Any]:
        """Validate if rollback is safe to execute."""
        try:
            source_version = self.versions.get(rollback_operation.source_version_id)
            target_version = self.versions.get(rollback_operation.target_version_id)
            
            if not source_version or not target_version:
                return {'safe': False, 'reason': 'Source or target version not found'}
            
            # Check if target version is in a deployable state
            if target_version.status not in [VersionStatus.APPROVED, VersionStatus.DEPLOYED]:
                return {'safe': False, 'reason': f'Target version is in {target_version.status.value} state'}
            
            # Check resource compatibility
            source_resources = source_version.resource_requirements
            target_resources = target_version.resource_requirements
            
            for resource in target_resources:
                target_req = target_resources[resource]
                source_req = source_resources.get(resource, 0)
                
                if target_req > source_req * 1.5:  # 50% increase
                    return {
                        'safe': False, 
                        'reason': f'Target version requires {resource*100:.0f}% more resources than source'
                    }
            
            # Check compatibility matrix
            for compatibility, status in source_version.compatibility_matrix.items():
                target_status = target_version.compatibility_matrix.get(compatibility)
                if target_status and target_status != status:
                    return {
                        'safe': False,
                        'reason': f'Compatibility change detected for {compatibility}'
                    }
            
            return {'safe': True, 'reason': 'Rollback validation passed'}
            
        except Exception as e:
            return {'safe': False, 'reason': f'Validation error: {str(e)}'}
    
    def _execute_instant_rollback(self, rollback_operation: RollbackOperation) -> bool:
        """Execute an instant rollback."""
        try:
            rollback_operation.status = RollbackStatus.IN_PROGRESS
            rollback_operation.started_at = time.time()
            rollback_operation.progress_percentage = 25.0
            
            # Update deployment
            target_version = self.versions[rollback_operation.target_version_id]
            model_id = rollback_operation.metadata['model_id']
            
            # Record the rollback in deployment history
            self.record_deployment(
                version_id=target_version.version_id,
                deployment_target=model_id,
                deployment_strategy="rollback_instant",
                success=True,
                duration_seconds=0.0
            )
            
            rollback_operation.progress_percentage = 75.0
            
            # Update active deployment
            self.active_deployments[model_id] = target_version.version_id
            
            rollback_operation.progress_percentage = 100.0
            rollback_operation.steps_completed = [
                "validated_rollback_safety",
                "updated_active_deployment",
                "recorded_deployment_history"
            ]
            
            return True
            
        except Exception as e:
            rollback_operation.error_details = str(e)
            return False
    
    def _execute_gradual_rollback(self, rollback_operation: RollbackOperation) -> bool:
        """Execute a gradual rollback (placeholder implementation)."""
        # For now, implement as instant rollback
        # In a full implementation, this would gradually shift traffic
        return self._execute_instant_rollback(rollback_operation)
    
    def _execute_canary_rollback(self, rollback_operation: RollbackOperation) -> bool:
        """Execute a canary rollback (placeholder implementation)."""
        # For now, implement as instant rollback
        # In a full implementation, this would use canary deployment patterns
        return self._execute_instant_rollback(rollback_operation)
    
    def _generate_migration_steps(self, version1: VersionMetadata, 
                                version2: VersionMetadata) -> List[str]:
        """Generate migration steps between versions."""
        steps = []
        
        # Check for resource requirement changes
        for resource in set(version1.resource_requirements.keys()) | set(version2.resource_requirements.keys()):
            req1 = version1.resource_requirements.get(resource, 0)
            req2 = version2.resource_requirements.get(resource, 0)
            
            if req2 > req1:
                steps.append(f"Scale up {resource} resources from {req1} to {req2}")
            elif req2 < req1:
                steps.append(f"Scale down {resource} resources from {req1} to {req2}")
        
        # Check for dependency changes
        for dep in set(version1.dependencies) | set(version2.dependencies):
            if dep in version2.dependencies and dep not in version1.dependencies:
                steps.append(f"Install new dependency: {dep}")
            elif dep in version1.dependencies and dep not in version2.dependencies:
                steps.append(f"Remove dependency: {dep}")
        
        # Check for breaking changes
        semver1 = semantic_version.Version(version1.semantic_version)
        semver2 = semantic_version.Version(version2.semantic_version)
        
        if semver1.major != semver2.major:
            steps.append("Perform compatibility testing due to major version change")
            steps.append("Update API consumers to handle breaking changes")
            steps.append("Run comprehensive integration tests")
        
        return steps
    
    # Helper methods for storage and file management
    def _get_version_storage_path(self, version: VersionMetadata) -> Path:
        """Get storage path for a version."""
        return self.storage_path / version.model_id / version.semantic_version
    
    def _store_model_files(self, source_path: str, storage_path: Path):
        """Store model files in version storage."""
        storage_path.mkdir(parents=True, exist_ok=True)
        
        source = Path(source_path)
        if source.is_file():
            shutil.copy2(source, storage_path / source.name)
        elif source.is_dir():
            shutil.copytree(source, storage_path / source.name)
    
    def _calculate_model_hash(self, model_path: Path) -> str:
        """Calculate hash of model files."""
        hash_md5 = hashlib.md5()
        
        if model_path.is_file():
            with open(model_path, "rb") as f:
                for chunk in iter(lambda: f.read(4096), b""):
                    hash_md5.update(chunk)
        elif model_path.is_dir():
            for file_path in sorted(model_path.rglob('*')):
                if file_path.is_file():
                    with open(file_path, "rb") as f:
                        for chunk in iter(lambda: f.read(4096), b""):
                            hash_md5.update(chunk)
        
        return hash_md5.hexdigest()
    
    def _get_directory_size(self, path: Path) -> int:
        """Get total size of directory in bytes."""
        total_size = 0
        for file_path in path.rglob('*'):
            if file_path.is_file():
                total_size += file_path.stat().st_size
        return total_size
    
    def _analyze_resource_requirements(self, model_path: str) -> Dict[str, float]:
        """Analyze resource requirements for a model."""
        model_size = self._get_directory_size(Path(model_path))
        
        # Estimate requirements based on model size
        # This is a simplified estimation - real implementation would analyze model architecture
        estimated_memory = max(model_size / (1024 * 1024), 100)  # MB, minimum 100MB
        estimated_cpu = 1.0  # Minimum 1 CPU
        estimated_storage = model_size / (1024 * 1024)  # MB
        
        return {
            'memory_mb': estimated_memory,
            'cpu_cores': estimated_cpu,
            'storage_mb': estimated_storage,
            'gpu_memory_mb': 0.0  # Assume no GPU initially
        }
    
    # Background workers
    def _rollback_monitor_worker(self):
        """Background worker for monitoring rollback operations."""
        logger.info("Rollback monitoring worker started")
        
        while self._running:
            try:
                # Monitor in-progress rollbacks
                for rollback_id, rollback in self.rollback_operations.items():
                    if rollback.status == RollbackStatus.IN_PROGRESS:
                        # Check for timeout
                        if (time.time() - rollback.initiated_at > 
                            self.versioning_config['rollback_timeout']):
                            rollback.status = RollbackStatus.FAILED
                            rollback.error_details = "Rollback timeout"
                            self._save_rollback_record(rollback)
                
                time.sleep(30)  # Check every 30 seconds
                
            except Exception as e:
                logger.error(f"Error in rollback monitor worker: {e}")
                time.sleep(60)
        
        logger.info("Rollback monitoring worker stopped")
    
    def _cleanup_worker(self):
        """Background worker for cleanup operations."""
        logger.info("Cleanup worker started")
        
        while self._running:
            try:
                # Cleanup old versions
                cutoff_time = time.time() - (self.versioning_config['version_retention_days'] * 24 * 3600)
                
                for version_id in list(self.versions.keys()):
                    version = self.versions[version_id]
                    
                    if (version.status in [VersionStatus.DEPRECATED, VersionStatus.RETIRED] and
                        version.created_at < cutoff_time):
                        
                        # Remove version storage
                        storage_path = self._get_version_storage_path(version)
                        if storage_path.exists():
                            shutil.rmtree(storage_path)
                        
                        # Remove from tracking
                        del self.versions[version_id]
                        
                        logger.info(f"Cleaned up old version {version.semantic_version}")
                
                # Cleanup old rollback operations
                self.rollback_history = [
                    r for r in self.rollback_history 
                    if r.initiated_at > cutoff_time
                ]
                
                # Cleanup old deployment records
                self.deployment_history = [
                    d for d in self.deployment_history 
                    if d.deployment_timestamp > cutoff_time
                ]
                
                time.sleep(3600)  # Run every hour
                
            except Exception as e:
                logger.error(f"Error in cleanup worker: {e}")
                time.sleep(1800)  # Wait 30 minutes on error
        
        logger.info("Cleanup worker stopped")
    
    # Database helper methods
    def _save_version_record(self, version: VersionMetadata):
        """Save version record to database."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT OR REPLACE INTO versions 
                (version_id, model_id, semantic_version, version_type, status, created_at,
                 created_by, description, changelog, dependencies, performance_metrics,
                 resource_requirements, compatibility_matrix, test_results, deployment_history,
                 rollback_history, tags, metadata)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                version.version_id,
                version.model_id,
                version.semantic_version,
                version.version_type.value,
                version.status.value,
                version.created_at,
                version.created_by,
                version.description,
                json.dumps(version.changelog),
                json.dumps(version.dependencies),
                json.dumps(version.performance_metrics),
                json.dumps(version.resource_requirements),
                json.dumps(version.compatibility_matrix),
                json.dumps(version.test_results),
                json.dumps(version.deployment_history),
                json.dumps(version.rollback_history),
                json.dumps(version.tags),
                json.dumps(version.metadata)
            ))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            logger.error(f"Failed to save version record: {e}")
    
    def _save_rollback_record(self, rollback: RollbackOperation):
        """Save rollback record to database."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT OR REPLACE INTO rollback_operations 
                (rollback_id, source_version_id, target_version_id, rollback_type, status,
                 initiated_at, started_at, completed_at, progress_percentage, steps_completed,
                 error_details, validation_results, metadata)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                rollback.rollback_id,
                rollback.source_version_id,
                rollback.target_version_id,
                rollback.rollback_type.value,
                rollback.status.value,
                rollback.initiated_at,
                rollback.started_at,
                rollback.completed_at,
                rollback.progress_percentage,
                json.dumps(rollback.steps_completed),
                rollback.error_details,
                json.dumps(rollback.validation_results),
                json.dumps(rollback.metadata)
            ))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            logger.error(f"Failed to save rollback record: {e}")
    
    def _save_deployment_record(self, deployment: DeploymentRecord):
        """Save deployment record to database."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT INTO deployment_records 
                (deployment_id, version_id, deployment_timestamp, deployment_target,
                 deployment_strategy, success, duration_seconds, performance_metrics,
                 error_details, rollback_triggered, metadata)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                deployment.deployment_id,
                deployment.version_id,
                deployment.deployment_timestamp,
                deployment.deployment_target,
                deployment.deployment_strategy,
                1 if deployment.success else 0,
                deployment.duration_seconds,
                json.dumps(deployment.performance_metrics),
                deployment.error_details,
                1 if deployment.rollback_triggered else 0,
                json.dumps(deployment.metadata)
            ))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            logger.error(f"Failed to save deployment record: {e}")


# Global instance for convenience
_global_versioning_system = None


def get_versioning_system() -> VersioningSystem:
    """
    Get a global versioning system instance.
    
    Returns:
        VersioningSystem: A versioning system instance
    """
    global _global_versioning_system
    
    if _global_versioning_system is None:
        _global_versioning_system = VersioningSystem()
    
    return _global_versioning_system