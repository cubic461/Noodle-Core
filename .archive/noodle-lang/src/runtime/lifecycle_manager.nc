"""
NoodleCore AI Model Lifecycle Manager (.nc file)
===============================================

This module provides comprehensive AI model lifecycle management and tracking,
providing end-to-end model lifecycle visibility from development to retirement.

Features:
- Complete model lifecycle tracking from development to retirement
- Model lineage and dependency tracking
- Automated lifecycle state transitions
- Model governance and compliance tracking
- Performance monitoring across lifecycle stages
- Automated retirement and archival
- Integration with model registry and deployment systems
- Lifecycle analytics and insights
- Audit logging for compliance
- Risk assessment and management

Supported Lifecycle Stages:
1. Development - Model is being developed and trained
2. Training - Model is actively being trained
3. Validation - Model is being validated and tested
4. Staging - Model is ready for deployment but not yet active
5. Production - Model is actively serving requests
6. Monitoring - Model is in production with active monitoring
7. Performance Review - Model performance is being evaluated
8. Retraining - Model is being retrained for improvements
9. Deprecated - Model is scheduled for retirement
10. Archived - Model has been archived

Lifecycle States:
- DRAFT - Initial model creation
- TRAINING - Active training in progress
- VALIDATED - Model passed validation
- DEPLOYED - Model is deployed and serving
- MONITORED - Model under active monitoring
- FLAGGED - Model performance issues detected
- SCHEDULED_FOR_RETIREMENT - Model marked for retirement
- ARCHIVED - Model archived and no longer accessible
"""

import os
import json
import logging
import time
import threading
import uuid
import hashlib
import sqlite3
from typing import Dict, List, Optional, Any, Union, Callable, Set
from dataclasses import dataclass, asdict, field
from enum import Enum
from datetime import datetime, timedelta
from pathlib import Path
import statistics

# Import existing NoodleCore components
from ..self_improvement.model_management import ModelManager, ModelType, ModelStatus
from ..runtime.performance_monitor import get_performance_monitor

# Configure logging
logger = logging.getLogger(__name__)

# Environment variables
NOODLE_DEBUG = os.environ.get("NOODLE_DEBUG", "0") == "1"
NOODLE_LIFECYCLE_ENABLED = os.environ.get("NOODLE_LIFECYCLE_ENABLED", "1") == "1"
NOODLE_LIFECYCLE_DB_PATH = os.environ.get("NOODLE_LIFECYCLE_DB_PATH", "noodle_lifecycle.db")
NOODLE_AUTO_RETIREMENT_ENABLED = os.environ.get("NOODLE_AUTO_RETIREMENT_ENABLED", "1") == "1"
NOODLE_LIFECYCLE_RETENTION_DAYS = int(os.environ.get("NOODLE_LIFECYCLE_RETENTION_DAYS", "365"))
NOODLE_PERFORMANCE_THRESHOLD = float(os.environ.get("NOODLE_PERFORMANCE_THRESHOLD", "0.8"))
NOODLE_USAGE_THRESHOLD = int(os.environ.get("NOODLE_USAGE_THRESHOLD", "1000"))


class LifecycleStage(Enum):
    """Lifecycle stages for AI models."""
    DEVELOPMENT = "development"
    TRAINING = "training"
    VALIDATION = "validation"
    STAGING = "staging"
    PRODUCTION = "production"
    MONITORING = "monitoring"
    PERFORMANCE_REVIEW = "performance_review"
    RETRAINING = "retraining"
    DEPRECATED = "deprecated"
    ARCHIVED = "archived"


class LifecycleState(Enum):
    """Lifecycle states for AI models."""
    DRAFT = "draft"
    TRAINING = "training"
    VALIDATED = "validated"
    DEPLOYED = "deployed"
    MONITORED = "monitored"
    FLAGGED = "flagged"
    SCHEDULED_FOR_RETIREMENT = "scheduled_for_retirement"
    ARCHIVED = "archived"


class AlertType(Enum):
    """Types of lifecycle alerts."""
    PERFORMANCE_DEGRADATION = "performance_degradation"
    USAGE_SPIKE = "usage_spike"
    USAGE_DECLINE = "usage_decline"
    ERROR_RATE_HIGH = "error_rate_high"
    LATENCY_HIGH = "latency_high"
    RESOURCE_USAGE_HIGH = "resource_usage_high"
    MODEL_DRIFT_DETECTED = "model_drift_detected"
    SCHEDULE_RETIREMENT = "schedule_retirement"
    COMPLIANCE_VIOLATION = "compliance_violation"


class Priority(Enum):
    """Priority levels for lifecycle management."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


@dataclass
class ModelLineage:
    """Model lineage information."""
    model_id: str
    parent_model_id: Optional[str]
    child_model_ids: List[str] = field(default_factory=list)
    training_data_version: str
    model_version: str
    created_by: str
    lineage_type: str  # "original", "derived", "ensemble"
    dependencies: List[str] = field(default_factory=list)


@dataclass
class ModelMetrics:
    """Model performance and usage metrics."""
    model_id: str
    timestamp: float
    total_requests: int
    successful_requests: int
    error_rate: float
    average_latency: float
    p95_latency: float
    p99_latency: float
    throughput: float
    resource_utilization: Dict[str, float]
    accuracy_score: Optional[float]
    confidence_score: Optional[float]
    user_satisfaction: Optional[float]


@dataclass
class LifecycleEvent:
    """A lifecycle event for a model."""
    event_id: str
    model_id: str
    event_type: str
    stage_from: Optional[LifecycleStage]
    stage_to: LifecycleStage
    timestamp: float
    triggered_by: str
    reason: str
    metadata: Dict[str, Any] = field(default_factory=dict)
    risk_level: str = "low"
    compliance_status: str = "compliant"


@dataclass
class ModelCompliance:
    """Model compliance and governance information."""
    model_id: str
    compliance_framework: str  # "GDPR", "CCPA", "SOX", etc.
    data_sources: List[str]
    privacy_level: str  # "public", "internal", "confidential", "restricted"
    retention_policy: str
    audit_trail: List[Dict[str, Any]] = field(default_factory=list)
    certifications: List[str] = field(default_factory=list)
    last_audit_date: Optional[float]
    next_audit_date: Optional[float]
    risk_assessment: Dict[str, Any] = field(default_factory=dict)


@dataclass
class LifecycleAlert:
    """Lifecycle management alert."""
    alert_id: str
    model_id: str
    alert_type: AlertType
    priority: Priority
    message: str
    created_at: float
    resolved_at: Optional[float]
    assigned_to: Optional[str]
    metadata: Dict[str, Any] = field(default_factory=dict)


class LifecycleManager:
    """
    Comprehensive AI model lifecycle management system.
    
    This class provides enterprise-grade lifecycle management capabilities
    for AI models, tracking them from development through retirement
    with comprehensive monitoring, compliance, and governance features.
    """
    
    def __init__(self):
        """Initialize the lifecycle manager."""
        if NOODLE_DEBUG:
            logger.setLevel(logging.DEBUG)
        
        # Database connection
        self.db_path = NOODLE_LIFECYCLE_DB_PATH
        self._init_database()
        
        # Core components
        self.model_manager = None
        self.performance_monitor = None
        
        # Lifecycle tracking
        self.model_lifecycles: Dict[str, Dict[str, Any]] = {}
        self.model_lineages: Dict[str, ModelLineage] = {}
        self.lifecycle_events: List[LifecycleEvent] = []
        self.model_compliance: Dict[str, ModelCompliance] = {}
        self.lifecycle_alerts: List[LifecycleAlert] = []
        
        # Cache and optimization
        self._cache: Dict[str, Any] = {}
        self._cache_lock = threading.RLock()
        self._last_cache_update = 0
        
        # Threading and synchronization
        self._lock = threading.RLock()
        self._monitoring_thread = None
        self._cleanup_thread = None
        self._running = False
        
        # Configuration
        self.monitoring_config = {
            'check_interval': 300,  # 5 minutes
            'retention_check_interval': 86400,  # 24 hours
            'performance_threshold': NOODLE_PERFORMANCE_THRESHOLD,
            'usage_threshold': NOODLE_USAGE_THRESHOLD,
            'auto_retirement_enabled': NOODLE_AUTO_RETIREMENT_ENABLED,
            'auto_retirement_age_days': 365,
            'compliance_check_interval': 604800  # 1 week
        }
        
        # Statistics
        self.lifecycle_stats = {
            'total_models': 0,
            'models_by_stage': {stage.value: 0 for stage in LifecycleStage},
            'total_events': 0,
            'total_alerts': 0,
            'resolved_alerts': 0,
            'models_archived': 0,
            'avg_model_lifetime_days': 0.0,
            'compliance_score': 0.0
        }
        
        # Load existing data
        self._load_lifecycle_data()
        
        logger.info("LifecycleManager initialized")
    
    def _init_database(self):
        """Initialize SQLite database for lifecycle tracking."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            # Create tables
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS model_lifecycles (
                    model_id TEXT PRIMARY KEY,
                    current_stage TEXT NOT NULL,
                    current_state TEXT NOT NULL,
                    created_at REAL NOT NULL,
                    last_updated REAL NOT NULL,
                    metadata TEXT,
                    lineage_id TEXT,
                    compliance_id TEXT
                )
            ''')
            
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS lifecycle_events (
                    event_id TEXT PRIMARY KEY,
                    model_id TEXT NOT NULL,
                    event_type TEXT NOT NULL,
                    stage_from TEXT,
                    stage_to TEXT NOT NULL,
                    timestamp REAL NOT NULL,
                    triggered_by TEXT NOT NULL,
                    reason TEXT NOT NULL,
                    metadata TEXT,
                    risk_level TEXT,
                    compliance_status TEXT,
                    FOREIGN KEY (model_id) REFERENCES model_lifecycles (model_id)
                )
            ''')
            
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS model_lineages (
                    lineage_id TEXT PRIMARY KEY,
                    model_id TEXT NOT NULL,
                    parent_model_id TEXT,
                    child_model_ids TEXT,
                    training_data_version TEXT,
                    model_version TEXT,
                    created_by TEXT,
                    lineage_type TEXT,
                    dependencies TEXT,
                    FOREIGN KEY (model_id) REFERENCES model_lifecycles (model_id)
                )
            ''')
            
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS model_compliance (
                    compliance_id TEXT PRIMARY KEY,
                    model_id TEXT NOT NULL,
                    compliance_framework TEXT,
                    data_sources TEXT,
                    privacy_level TEXT,
                    retention_policy TEXT,
                    audit_trail TEXT,
                    certifications TEXT,
                    last_audit_date REAL,
                    next_audit_date REAL,
                    risk_assessment TEXT,
                    FOREIGN KEY (model_id) REFERENCES model_lifecycles (model_id)
                )
            ''')
            
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS lifecycle_alerts (
                    alert_id TEXT PRIMARY KEY,
                    model_id TEXT NOT NULL,
                    alert_type TEXT NOT NULL,
                    priority TEXT NOT NULL,
                    message TEXT NOT NULL,
                    created_at REAL NOT NULL,
                    resolved_at REAL,
                    assigned_to TEXT,
                    metadata TEXT,
                    FOREIGN KEY (model_id) REFERENCES model_lifecycles (model_id)
                )
            ''')
            
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS model_metrics (
                    metric_id TEXT PRIMARY KEY,
                    model_id TEXT NOT NULL,
                    timestamp REAL NOT NULL,
                    total_requests INTEGER,
                    successful_requests INTEGER,
                    error_rate REAL,
                    average_latency REAL,
                    p95_latency REAL,
                    p99_latency REAL,
                    throughput REAL,
                    resource_utilization TEXT,
                    accuracy_score REAL,
                    confidence_score REAL,
                    user_satisfaction REAL,
                    FOREIGN KEY (model_id) REFERENCES model_lifecycles (model_id)
                )
            ''')
            
            conn.commit()
            conn.close()
            
            logger.debug(f"Initialized lifecycle database at {self.db_path}")
            
        except Exception as e:
            logger.error(f"Failed to initialize database: {e}")
            raise
    
    def _load_lifecycle_data(self):
        """Load existing lifecycle data from database."""
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            # Load model lifecycles
            cursor.execute('SELECT * FROM model_lifecycles')
            for row in cursor.fetchall():
                lifecycle_data = dict(row)
                lifecycle_data['metadata'] = json.loads(lifecycle_data.get('metadata', '{}'))
                self.model_lifecycles[lifecycle_data['model_id']] = lifecycle_data
            
            # Load lifecycle events
            cursor.execute('SELECT * FROM lifecycle_events ORDER BY timestamp')
            for row in cursor.fetchall():
                event_data = dict(row)
                event_data['metadata'] = json.loads(event_data.get('metadata', '{}'))
                event = LifecycleEvent(**event_data)
                self.lifecycle_events.append(event)
            
            # Load model lineages
            cursor.execute('SELECT * FROM model_lineages')
            for row in cursor.fetchall():
                lineage_data = dict(row)
                lineage_data['child_model_ids'] = json.loads(lineage_data.get('child_model_ids', '[]'))
                lineage_data['dependencies'] = json.loads(lineage_data.get('dependencies', '[]'))
                lineage = ModelLineage(**lineage_data)
                self.model_lineages[lineage.model_id] = lineage
            
            # Load compliance data
            cursor.execute('SELECT * FROM model_compliance')
            for row in cursor.fetchall():
                compliance_data = dict(row)
                compliance_data['data_sources'] = json.loads(compliance_data.get('data_sources', '[]'))
                compliance_data['audit_trail'] = json.loads(compliance_data.get('audit_trail', '[]'))
                compliance_data['certifications'] = json.loads(compliance_data.get('certifications', '[]'))
                compliance_data['risk_assessment'] = json.loads(compliance_data.get('risk_assessment', '{}'))
                compliance = ModelCompliance(**compliance_data)
                self.model_compliance[compliance.model_id] = compliance
            
            # Load alerts
            cursor.execute('SELECT * FROM lifecycle_alerts WHERE resolved_at IS NULL')
            for row in cursor.fetchall():
                alert_data = dict(row)
                alert_data['metadata'] = json.loads(alert_data.get('metadata', '{}'))
                alert = LifecycleAlert(**alert_data)
                self.lifecycle_alerts.append(alert)
            
            conn.close()
            
            # Update statistics
            self._update_lifecycle_statistics()
            
            logger.info(f"Loaded {len(self.model_lifecycles)} model lifecycles from database")
            
        except Exception as e:
            logger.error(f"Failed to load lifecycle data: {e}")
    
    def initialize(self, model_manager: ModelManager = None, performance_monitor = None) -> bool:
        """
        Initialize the lifecycle manager with required components.
        
        Args:
            model_manager: Model management component
            performance_monitor: Performance monitoring component
            
        Returns:
            True if initialization successful
        """
        try:
            # Initialize core components
            if model_manager:
                self.model_manager = model_manager
            
            if performance_monitor:
                self.performance_monitor = performance_monitor
            else:
                self.performance_monitor = get_performance_monitor()
            
            # Start background services
            self.start()
            
            logger.info("LifecycleManager initialized successfully")
            return True
            
        except Exception as e:
            logger.error(f"Failed to initialize LifecycleManager: {e}")
            return False
    
    def start(self):
        """Start the lifecycle manager background services."""
        with self._lock:
            if self._running:
                return
            
            self._running = True
            
            # Start monitoring thread
            self._monitoring_thread = threading.Thread(
                target=self._monitoring_worker, daemon=True
            )
            self._monitoring_thread.start()
            
            # Start cleanup thread
            self._cleanup_thread = threading.Thread(
                target=self._cleanup_worker, daemon=True
            )
            self._cleanup_thread.start()
            
            logger.info("LifecycleManager started")
    
    def stop(self):
        """Stop the lifecycle manager and cleanup resources."""
        with self._lock:
            if not self._running:
                return
            
            self._running = False
            
            # Wait for threads to stop
            for thread in [self._monitoring_thread, self._cleanup_thread]:
                if thread and thread.is_alive():
                    thread.join(timeout=10.0)
            
            # Save data
            self._save_lifecycle_data()
            
            logger.info("LifecycleManager stopped")
    
    def register_model(self, model_id: str, model_type: ModelType, created_by: str,
                      training_data_version: str = None, parent_model_id: str = None,
                      compliance_framework: str = None, data_sources: List[str] = None,
                      privacy_level: str = "internal", **kwargs) -> bool:
        """
        Register a new model in the lifecycle management system.
        
        Args:
            model_id: Unique model identifier
            model_type: Type of the model
            created_by: User or system that created the model
            training_data_version: Version of training data used
            parent_model_id: ID of parent model (if derived)
            compliance_framework: Compliance framework (GDPR, CCPA, etc.)
            data_sources: List of data sources used
            privacy_level: Privacy level of the model
            **kwargs: Additional metadata
            
        Returns:
            True if registration successful
        """
        try:
            with self._lock:
                # Create lifecycle record
                lifecycle_record = {
                    'model_id': model_id,
                    'current_stage': LifecycleStage.DEVELOPMENT.value,
                    'current_state': LifecycleState.DRAFT.value,
                    'created_at': time.time(),
                    'last_updated': time.time(),
                    'metadata': {
                        'model_type': model_type.value,
                        'created_by': created_by,
                        **kwargs
                    },
                    'lineage_id': None,
                    'compliance_id': None
                }
                
                self.model_lifecycles[model_id] = lifecycle_record
                
                # Create lineage record
                if parent_model_id:
                    lineage = ModelLineage(
                        model_id=model_id,
                        parent_model_id=parent_model_id,
                        child_model_ids=[],
                        training_data_version=training_data_version or "v1.0",
                        model_version="v1.0",
                        created_by=created_by,
                        lineage_type="derived",
                        dependencies=[]
                    )
                    
                    # Update parent's child models
                    if parent_model_id in self.model_lineages:
                        self.model_lineages[parent_model_id].child_model_ids.append(model_id)
                else:
                    lineage = ModelLineage(
                        model_id=model_id,
                        parent_model_id=None,
                        child_model_ids=[],
                        training_data_version=training_data_version or "v1.0",
                        model_version="v1.0",
                        created_by=created_by,
                        lineage_type="original",
                        dependencies=[]
                    )
                
                self.model_lineages[model_id] = lineage
                
                # Create compliance record
                if compliance_framework:
                    compliance = ModelCompliance(
                        model_id=model_id,
                        compliance_framework=compliance_framework,
                        data_sources=data_sources or [],
                        privacy_level=privacy_level,
                        retention_policy=f"{NOODLE_LIFECYCLE_RETENTION_DAYS} days",
                        audit_trail=[],
                        certifications=[],
                        last_audit_date=None,
                        next_audit_date=time.time() + (30 * 24 * 3600),  # 30 days
                        risk_assessment={}
                    )
                    
                    self.model_compliance[model_id] = compliance
                
                # Create initial lifecycle event
                event = LifecycleEvent(
                    event_id=str(uuid.uuid4()),
                    model_id=model_id,
                    event_type="model_registered",
                    stage_from=None,
                    stage_to=LifecycleStage.DEVELOPMENT,
                    timestamp=time.time(),
                    triggered_by=created_by,
                    reason="Model registered in lifecycle management system",
                    metadata={'model_type': model_type.value},
                    risk_level="low",
                    compliance_status="pending" if compliance_framework else "not_applicable"
                )
                
                self.lifecycle_events.append(event)
                
                # Save to database
                self._save_lifecycle_record(lifecycle_record)
                self._save_lineage_record(lineage)
                if compliance_framework:
                    self._save_compliance_record(compliance)
                self._save_event_record(event)
                
                # Update statistics
                self._update_lifecycle_statistics()
                
                logger.info(f"Registered model {model_id} in lifecycle management")
                return True
                
        except Exception as e:
            logger.error(f"Failed to register model {model_id}: {e}")
            return False
    
    def advance_stage(self, model_id: str, new_stage: LifecycleStage, 
                     triggered_by: str, reason: str, **metadata) -> bool:
        """
        Advance a model to a new lifecycle stage.
        
        Args:
            model_id: Model to advance
            new_stage: New lifecycle stage
            triggered_by: User or system triggering the change
            reason: Reason for the stage change
            **metadata: Additional metadata
            
        Returns:
            True if stage advancement successful
        """
        try:
            with self._lock:
                if model_id not in self.model_lifecycles:
                    raise ValueError(f"Model {model_id} not found in lifecycle management")
                
                lifecycle_record = self.model_lifecycles[model_id]
                current_stage = LifecycleStage(lifecycle_record['current_stage'])
                
                # Validate stage transition
                if not self._validate_stage_transition(current_stage, new_stage):
                    raise ValueError(f"Invalid stage transition from {current_stage.value} to {new_stage.value}")
                
                # Create lifecycle event
                event = LifecycleEvent(
                    event_id=str(uuid.uuid4()),
                    model_id=model_id,
                    event_type="stage_advanced",
                    stage_from=current_stage,
                    stage_to=new_stage,
                    timestamp=time.time(),
                    triggered_by=triggered_by,
                    reason=reason,
                    metadata=metadata,
                    risk_level=self._assess_transition_risk(current_stage, new_stage),
                    compliance_status=self._check_compliance_status(model_id)
                )
                
                # Update lifecycle record
                lifecycle_record['current_stage'] = new_stage.value
                lifecycle_record['current_state'] = self._map_stage_to_state(new_stage).value
                lifecycle_record['last_updated'] = time.time()
                
                # Add metadata
                lifecycle_record['metadata'].update(metadata)
                
                # Update state-specific actions
                self._handle_stage_change(model_id, current_stage, new_stage)
                
                # Save to database
                self._save_lifecycle_record(lifecycle_record)
                self._save_event_record(event)
                
                self.lifecycle_events.append(event)
                
                # Check for alerts
                self._check_stage_change_alerts(model_id, current_stage, new_stage)
                
                logger.info(f"Advanced model {model_id} from {current_stage.value} to {new_stage.value}")
                return True
                
        except Exception as e:
            logger.error(f"Failed to advance stage for model {model_id}: {e}")
            return False
    
    def record_metrics(self, model_id: str, metrics: Dict[str, Any]) -> bool:
        """
        Record model performance and usage metrics.
        
        Args:
            model_id: Model to record metrics for
            metrics: Performance and usage metrics
            
        Returns:
            True if metrics recording successful
        """
        try:
            with self._lock:
                if model_id not in self.model_lifecycles:
                    raise ValueError(f"Model {model_id} not found")
                
                # Create metrics record
                metrics_record = ModelMetrics(
                    model_id=model_id,
                    timestamp=time.time(),
                    total_requests=metrics.get('total_requests', 0),
                    successful_requests=metrics.get('successful_requests', 0),
                    error_rate=metrics.get('error_rate', 0.0),
                    average_latency=metrics.get('average_latency', 0.0),
                    p95_latency=metrics.get('p95_latency', 0.0),
                    p99_latency=metrics.get('p99_latency', 0.0),
                    throughput=metrics.get('throughput', 0.0),
                    resource_utilization=metrics.get('resource_utilization', {}),
                    accuracy_score=metrics.get('accuracy_score'),
                    confidence_score=metrics.get('confidence_score'),
                    user_satisfaction=metrics.get('user_satisfaction')
                )
                
                # Save to database
                self._save_metrics_record(metrics_record)
                
                # Check for performance alerts
                self._check_performance_alerts(model_id, metrics_record)
                
                # Check for drift detection
                self._check_model_drift(model_id, metrics_record)
                
                logger.debug(f"Recorded metrics for model {model_id}")
                return True
                
        except Exception as e:
            logger.error(f"Failed to record metrics for model {model_id}: {e}")
            return False
    
    def get_model_lifecycle(self, model_id: str) -> Dict[str, Any]:
        """
        Get complete lifecycle information for a model.
        
        Args:
            model_id: Model to get lifecycle for
            
        Returns:
            Complete lifecycle information
        """
        try:
            with self._lock:
                if model_id not in self.model_lifecycles:
                    return {'error': 'Model not found'}
                
                lifecycle_record = self.model_lifecycles[model_id]
                lineage = self.model_lineages.get(model_id)
                compliance = self.model_compliance.get(model_id)
                
                # Get events for this model
                model_events = [asdict(event) for event in self.lifecycle_events 
                              if event.model_id == model_id]
                model_events.sort(key=lambda x: x['timestamp'])
                
                # Get recent metrics
                model_metrics = self._get_recent_metrics(model_id, limit=100)
                
                # Get active alerts
                model_alerts = [asdict(alert) for alert in self.lifecycle_alerts 
                              if alert.model_id == model_id and alert.resolved_at is None]
                
                return {
                    'model_id': model_id,
                    'lifecycle': lifecycle_record,
                    'lineage': asdict(lineage) if lineage else None,
                    'compliance': asdict(compliance) if compliance else None,
                    'events': model_events,
                    'metrics': model_metrics,
                    'alerts': model_alerts,
                    'summary': self._generate_lifecycle_summary(model_id)
                }
                
        except Exception as e:
            logger.error(f"Failed to get lifecycle for model {model_id}: {e}")
            return {'error': str(e)}
    
    def get_lifecycle_analytics(self, time_range_days: int = 30) -> Dict[str, Any]:
        """
        Get lifecycle analytics and insights.
        
        Args:
            time_range_days: Time range for analytics
            
        Returns:
            Lifecycle analytics data
        """
        try:
            cutoff_time = time.time() - (time_range_days * 24 * 3600)
            
            with self._lock:
                # Stage distribution
                stage_distribution = {}
                for stage in LifecycleStage:
                    stage_distribution[stage.value] = 0
                
                for lifecycle in self.model_lifecycles.values():
                    stage = lifecycle['current_stage']
                    if stage in stage_distribution:
                        stage_distribution[stage] += 1
                
                # Events over time
                events_timeline = {}
                for event in self.lifecycle_events:
                    if event.timestamp >= cutoff_time:
                        date_key = datetime.fromtimestamp(event.timestamp).strftime('%Y-%m-%d')
                        if date_key not in events_timeline:
                            events_timeline[date_key] = {'total': 0, 'by_type': {}}
                        
                        events_timeline[date_key]['total'] += 1
                        event_type = event.event_type
                        if event_type not in events_timeline[date_key]['by_type']:
                            events_timeline[date_key]['by_type'][event_type] = 0
                        events_timeline[date_key]['by_type'][event_type] += 1
                
                # Alert analysis
                active_alerts = [alert for alert in self.lifecycle_alerts 
                               if alert.created_at >= cutoff_time and alert.resolved_at is None]
                resolved_alerts = [alert for alert in self.lifecycle_alerts 
                                 if alert.created_at >= cutoff_time and alert.resolved_at is not None]
                
                alert_analysis = {
                    'active_count': len(active_alerts),
                    'resolved_count': len(resolved_alerts),
                    'by_priority': {},
                    'by_type': {},
                    'resolution_time_avg': self._calculate_avg_resolution_time(resolved_alerts)
                }
                
                for priority in Priority:
                    alert_analysis['by_priority'][priority.value] = len([
                        alert for alert in active_alerts + resolved_alerts
                        if alert.priority == priority
                    ])
                
                for alert_type in AlertType:
                    alert_analysis['by_type'][alert_type.value] = len([
                        alert for alert in active_alerts + resolved_alerts
                        if alert.alert_type == alert_type
                    ])
                
                # Model age analysis
                age_analysis = self._analyze_model_ages()
                
                # Compliance status
                compliance_status = self._analyze_compliance_status()
                
                return {
                    'time_range_days': time_range_days,
                    'stage_distribution': stage_distribution,
                    'events_timeline': events_timeline,
                    'alert_analysis': alert_analysis,
                    'age_analysis': age_analysis,
                    'compliance_status': compliance_status,
                    'insights': self._generate_lifecycle_insights(),
                    'recommendations': self._generate_lifecycle_recommendations()
                }
                
        except Exception as e:
            logger.error(f"Failed to get lifecycle analytics: {e}")
            return {'error': str(e)}
    
    def schedule_retirement(self, model_id: str, retirement_date: datetime, 
                          reason: str, triggered_by: str) -> bool:
        """
        Schedule a model for retirement.
        
        Args:
            model_id: Model to schedule for retirement
            retirement_date: Date when retirement should occur
            reason: Reason for retirement
            triggered_by: User or system triggering retirement
            
        Returns:
            True if scheduling successful
        """
        try:
            with self._lock:
                if model_id not in self.model_lifecycles:
                    raise ValueError(f"Model {model_id} not found")
                
                # Create retirement event
                event = LifecycleEvent(
                    event_id=str(uuid.uuid4()),
                    model_id=model_id,
                    event_type="retirement_scheduled",
                    stage_from=LifecycleStage(lifecycle_record['current_stage']),
                    stage_to=LifecycleStage.DEPRECATED,
                    timestamp=time.time(),
                    triggered_by=triggered_by,
                    reason=reason,
                    metadata={'retirement_date': retirement_date.isoformat()},
                    risk_level="medium",
                    compliance_status="pending"
                )
                
                # Update lifecycle record
                lifecycle_record = self.model_lifecycles[model_id]
                lifecycle_record['current_stage'] = LifecycleStage.DEPRECATED.value
                lifecycle_record['current_state'] = LifecycleState.SCHEDULED_FOR_RETIREMENT.value
                lifecycle_record['last_updated'] = time.time()
                
                # Add retirement metadata
                lifecycle_record['metadata']['scheduled_retirement'] = {
                    'date': retirement_date.isoformat(),
                    'reason': reason,
                    'triggered_by': triggered_by
                }
                
                # Create retirement alert
                alert = LifecycleAlert(
                    alert_id=str(uuid.uuid4()),
                    model_id=model_id,
                    alert_type=AlertType.SCHEDULE_RETIREMENT,
                    priority=Priority.MEDIUM,
                    message=f"Model scheduled for retirement on {retirement_date.strftime('%Y-%m-%d')}",
                    created_at=time.time(),
                    resolved_at=None,
                    assigned_to=None,
                    metadata={'retirement_date': retirement_date.isoformat(), 'reason': reason}
                )
                
                self.lifecycle_alerts.append(alert)
                
                # Save to database
                self._save_lifecycle_record(lifecycle_record)
                self._save_event_record(event)
                self._save_alert_record(alert)
                
                self.lifecycle_events.append(event)
                
                logger.info(f"Scheduled retirement for model {model_id} on {retirement_date.strftime('%Y-%m-%d')}")
                return True
                
        except Exception as e:
            logger.error(f"Failed to schedule retirement for model {model_id}: {e}")
            return False
    
    def archive_model(self, model_id: str, triggered_by: str, reason: str) -> bool:
        """
        Archive a model and move it to archived state.
        
        Args:
            model_id: Model to archive
            triggered_by: User or system triggering archiving
            reason: Reason for archiving
            
        Returns:
            True if archiving successful
        """
        try:
            with self._lock:
                if model_id not in self.model_lifecycles:
                    raise ValueError(f"Model {model_id} not found")
                
                lifecycle_record = self.model_lifecycles[model_id]
                current_stage = LifecycleStage(lifecycle_record['current_stage'])
                
                # Create archiving event
                event = LifecycleEvent(
                    event_id=str(uuid.uuid4()),
                    model_id=model_id,
                    event_type="model_archived",
                    stage_from=current_stage,
                    stage_to=LifecycleStage.ARCHIVED,
                    timestamp=time.time(),
                    triggered_by=triggered_by,
                    reason=reason,
                    metadata={'archived_by': triggered_by},
                    risk_level="low",
                    compliance_status="compliant"
                )
                
                # Update lifecycle record
                lifecycle_record['current_stage'] = LifecycleStage.ARCHIVED.value
                lifecycle_record['current_state'] = LifecycleState.ARCHIVED.value
                lifecycle_record['last_updated'] = time.time()
                lifecycle_record['archived_at'] = time.time()
                lifecycle_record['metadata']['archival_reason'] = reason
                
                # Add to compliance audit trail
                if model_id in self.model_compliance:
                    compliance = self.model_compliance[model_id]
                    compliance.audit_trail.append({
                        'timestamp': time.time(),
                        'action': 'model_archived',
                        'user': triggered_by,
                        'reason': reason
                    })
                
                # Save to database
                self._save_lifecycle_record(lifecycle_record)
                self._save_event_record(event)
                if model_id in self.model_compliance:
                    self._save_compliance_record(self.model_compliance[model_id])
                
                self.lifecycle_events.append(event)
                
                # Update statistics
                self.lifecycle_stats['models_archived'] += 1
                
                logger.info(f"Archived model {model_id}")
                return True
                
        except Exception as e:
            logger.error(f"Failed to archive model {model_id}: {e}")
            return False
    
    def resolve_alert(self, alert_id: str, resolved_by: str, resolution: str) -> bool:
        """
        Resolve a lifecycle alert.
        
        Args:
            alert_id: Alert to resolve
            resolved_by: User resolving the alert
            resolution: Resolution description
            
        Returns:
            True if alert resolution successful
        """
        try:
            with self._lock:
                for alert in self.lifecycle_alerts:
                    if alert.alert_id == alert_id and alert.resolved_at is None:
                        alert.resolved_at = time.time()
                        alert.metadata['resolved_by'] = resolved_by
                        alert.metadata['resolution'] = resolution
                        
                        # Save to database
                        self._save_alert_record(alert)
                        
                        # Update statistics
                        self.lifecycle_stats['resolved_alerts'] += 1
                        
                        logger.info(f"Resolved alert {alert_id}")
                        return True
                
                logger.warning(f"Alert {alert_id} not found or already resolved")
                return False
                
        except Exception as e:
            logger.error(f"Failed to resolve alert {alert_id}: {e}")
            return False
    
    # Background worker methods
    def _monitoring_worker(self):
        """Background worker for lifecycle monitoring."""
        logger.info("Lifecycle monitoring worker started")
        
        while self._running:
            try:
                self._monitor_model_health()
                self._check_retirement_schedules()
                self._check_compliance_requirements()
                time.sleep(self.monitoring_config['check_interval'])
                
            except Exception as e:
                logger.error(f"Error in monitoring worker: {e}")
                time.sleep(30)
        
        logger.info("Lifecycle monitoring worker stopped")
    
    def _cleanup_worker(self):
        """Background worker for lifecycle cleanup."""
        logger.info("Lifecycle cleanup worker started")
        
        while self._running:
            try:
                self._cleanup_old_events()
                self._cleanup_old_metrics()
                self._optimize_database()
                time.sleep(self.monitoring_config['retention_check_interval'])
                
            except Exception as e:
                logger.error(f"Error in cleanup worker: {e}")
                time.sleep(300)  # Wait 5 minutes on error
        
        logger.info("Lifecycle cleanup worker stopped")
    
    def _monitor_model_health(self):
        """Monitor all models for health and performance."""
        current_time = time.time()
        
        for model_id, lifecycle_record in self.model_lifecycles.items():
            try:
                # Skip archived models
                if lifecycle_record['current_stage'] == LifecycleStage.ARCHIVED.value:
                    continue
                
                # Get recent metrics
                recent_metrics = self._get_recent_metrics(model_id, limit=10)
                if not recent_metrics:
                    continue
                
                # Check for performance degradation
                self._check_performance_degradation(model_id, recent_metrics)
                
                # Check for usage patterns
                self._check_usage_patterns(model_id, recent_metrics)
                
                # Check resource utilization
                self._check_resource_utilization(model_id, recent_metrics)
                
                # Check compliance drift
                self._check_compliance_drift(model_id)
                
            except Exception as e:
                logger.error(f"Error monitoring model {model_id}: {e}")
    
    def _check_retirement_schedules(self):
        """Check for models scheduled for retirement."""
        current_time = time.time()
        
        for model_id, lifecycle_record in self.model_lifecycles.items():
            try:
                scheduled_retirement = lifecycle_record['metadata'].get('scheduled_retirement')
                if scheduled_retirement:
                    retirement_date = datetime.fromisoformat(scheduled_retirement['date'])
                    if retirement_date.timestamp() <= current_time:
                        # Trigger retirement
                        self.archive_model(
                            model_id,
                            "system",
                            f"Scheduled retirement on {retirement_date.strftime('%Y-%m-%d')}"
                        )
                
            except Exception as e:
                logger.error(f"Error checking retirement schedule for model {model_id}: {e}")
    
    def _check_compliance_requirements(self):
        """Check compliance requirements and audit schedules."""
        current_time = time.time()
        
        for model_id, compliance in self.model_compliance.items():
            try:
                if (compliance.next_audit_date and 
                    compliance.next_audit_date <= current_time):
                    
                    # Create compliance audit alert
                    alert = LifecycleAlert(
                        alert_id=str(uuid.uuid4()),
                        model_id=model_id,
                        alert_type=AlertType.COMPLIANCE_VIOLATION,
                        priority=Priority.HIGH,
                        message=f"Scheduled compliance audit required for {compliance.compliance_framework}",
                        created_at=current_time,
                        resolved_at=None,
                        assigned_to=None,
                        metadata={
                            'compliance_framework': compliance.compliance_framework,
                            'audit_type': 'scheduled'
                        }
                    )
                    
                    self.lifecycle_alerts.append(alert)
                    self._save_alert_record(alert)
                    
                    # Update next audit date
                    compliance.next_audit_date = current_time + (30 * 24 * 3600)  # 30 days
                    self._save_compliance_record(compliance)
                
            except Exception as e:
                logger.error(f"Error checking compliance for model {model_id}: {e}")
    
    # Helper methods for stage management
    def _validate_stage_transition(self, current_stage: LifecycleStage, 
                                  new_stage: LifecycleStage) -> bool:
        """Validate if a stage transition is allowed."""
        valid_transitions = {
            LifecycleStage.DEVELOPMENT: [LifecycleStage.TRAINING, LifecycleStage.ARCHIVED],
            LifecycleStage.TRAINING: [LifecycleStage.VALIDATION, LifecycleStage.ARCHIVED],
            LifecycleStage.VALIDATION: [LifecycleStage.STAGING, LifecycleStage.DEVELOPMENT, LifecycleStage.ARCHIVED],
            LifecycleStage.STAGING: [LifecycleStage.PRODUCTION, LifecycleStage.DEVELOPMENT, LifecycleStage.ARCHIVED],
            LifecycleStage.PRODUCTION: [LifecycleStage.MONITORING, LifecycleStage.STAGING, LifecycleStage.DEPRECATED],
            LifecycleStage.MONITORING: [LifecycleStage.PERFORMANCE_REVIEW, LifecycleStage.PRODUCTION, LifecycleStage.RETRAINING, LifecycleStage.DEPRECATED],
            LifecycleStage.PERFORMANCE_REVIEW: [LifecycleStage.MONITORING, LifecycleStage.RETRAINING, LifecycleStage.DEPRECATED],
            LifecycleStage.RETRAINING: [LifecycleStage.VALIDATION, LifecycleStage.MONITORING],
            LifecycleStage.DEPRECATED: [LifecycleStage.ARCHIVED],
            LifecycleStage.ARCHIVED: []  # Archived models cannot transition
        }
        
        return new_stage in valid_transitions.get(current_stage, [])
    
    def _map_stage_to_state(self, stage: LifecycleStage) -> LifecycleState:
        """Map lifecycle stage to state."""
        mapping = {
            LifecycleStage.DEVELOPMENT: LifecycleState.DRAFT,
            LifecycleStage.TRAINING: LifecycleState.TRAINING,
            LifecycleStage.VALIDATION: LifecycleState.VALIDATED,
            LifecycleStage.STAGING: LifecycleState.DEPLOYED,
            LifecycleStage.PRODUCTION: LifecycleState.DEPLOYED,
            LifecycleStage.MONITORING: LifecycleState.MONITORED,
            LifecycleStage.PERFORMANCE_REVIEW: LifecycleState.MONITORED,
            LifecycleStage.RETRAINING: LifecycleState.TRAINING,
            LifecycleStage.DEPRECATED: LifecycleState.SCHEDULED_FOR_RETIREMENT,
            LifecycleStage.ARCHIVED: LifecycleState.ARCHIVED
        }
        
        return mapping.get(stage, LifecycleState.DRAFT)
    
    def _assess_transition_risk(self, from_stage: LifecycleStage, to_stage: LifecycleStage) -> str:
        """Assess risk level of a stage transition."""
        high_risk_transitions = [
            (LifecycleStage.STAGING, LifecycleStage.PRODUCTION),
            (LifecycleStage.PRODUCTION, LifecycleStage.DEPRECATED),
            (LifecycleStage.RETRAINING, LifecycleStage.PRODUCTION)
        ]
        
        medium_risk_transitions = [
            (LifecycleStage.TRAINING, LifecycleStage.VALIDATION),
            (LifecycleStage.VALIDATION, LifecycleStage.STAGING),
            (LifecycleStage.MONITORING, LifecycleStage.PERFORMANCE_REVIEW),
            (LifecycleStage.PERFORMANCE_REVIEW, LifecycleStage.DEPRECATED)
        ]
        
        if (from_stage, to_stage) in high_risk_transitions:
            return "high"
        elif (from_stage, to_stage) in medium_risk_transitions:
            return "medium"
        else:
            return "low"
    
    def _handle_stage_change(self, model_id: str, from_stage: LifecycleStage, to_stage: LifecycleStage):
        """Handle stage change with appropriate actions."""
        if to_stage == LifecycleStage.PRODUCTION:
            # Start performance monitoring
            if self.performance_monitor:
                # Would integrate with performance monitor here
                pass
        
        elif to_stage == LifecycleStage.DEPRECATED:
            # Stop serving requests
            # Update load balancers
            # Notify stakeholders
            pass
        
        elif to_stage == LifecycleStage.ARCHIVED:
            # Cleanup resources
            # Archive model files
            # Update documentation
            pass
    
    def _check_stage_change_alerts(self, model_id: str, from_stage: LifecycleStage, to_stage: LifecycleStage):
        """Check for alerts triggered by stage changes."""
        if to_stage == LifecycleStage.PRODUCTION:
            # Production deployment alert
            alert = LifecycleAlert(
                alert_id=str(uuid.uuid4()),
                model_id=model_id,
                alert_type=AlertType.USAGE_SPIKE,
                priority=Priority.HIGH,
                message=f"Model {model_id} deployed to production",
                created_at=time.time(),
                resolved_at=None,
                assigned_to=None,
                metadata={'stage_transition': f'{from_stage.value} -> {to_stage.value}'}
            )
            self.lifecycle_alerts.append(alert)
            self._save_alert_record(alert)
        
        elif to_stage == LifecycleStage.DEPRECATED:
            # Deprecation alert
            alert = LifecycleAlert(
                alert_id=str(uuid.uuid4()),
                model_id=model_id,
                alert_type=AlertType.USAGE_DECLINE,
                priority=Priority.MEDIUM,
                message=f"Model {model_id} deprecated",
                created_at=time.time(),
                resolved_at=None,
                assigned_to=None,
                metadata={'stage_transition': f'{from_stage.value} -> {to_stage.value}'}
            )
            self.lifecycle_alerts.append(alert)
            self._save_alert_record(alert)
    
    # Database helper methods
    def _save_lifecycle_record(self, lifecycle_record: Dict[str, Any]):
        """Save lifecycle record to database."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT OR REPLACE INTO model_lifecycles 
                (model_id, current_stage, current_state, created_at, last_updated, metadata, lineage_id, compliance_id)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                lifecycle_record['model_id'],
                lifecycle_record['current_stage'],
                lifecycle_record['current_state'],
                lifecycle_record['created_at'],
                lifecycle_record['last_updated'],
                json.dumps(lifecycle_record['metadata']),
                lifecycle_record.get('lineage_id'),
                lifecycle_record.get('compliance_id')
            ))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            logger.error(f"Failed to save lifecycle record: {e}")
    
    def _save_lineage_record(self, lineage: ModelLineage):
        """Save lineage record to database."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT OR REPLACE INTO model_lineages 
                (lineage_id, model_id, parent_model_id, child_model_ids, training_data_version,
                 model_version, created_by, lineage_type, dependencies)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                lineage.model_id,  # Use model_id as lineage_id
                lineage.model_id,
                lineage.parent_model_id,
                json.dumps(lineage.child_model_ids),
                lineage.training_data_version,
                lineage.model_version,
                lineage.created_by,
                lineage.lineage_type,
                json.dumps(lineage.dependencies)
            ))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            logger.error(f"Failed to save lineage record: {e}")
    
    def _save_compliance_record(self, compliance: ModelCompliance):
        """Save compliance record to database."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT OR REPLACE INTO model_compliance 
                (compliance_id, model_id, compliance_framework, data_sources, privacy_level,
                 retention_policy, audit_trail, certifications, last_audit_date, 
                 next_audit_date, risk_assessment)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                compliance.model_id,  # Use model_id as compliance_id
                compliance.model_id,
                compliance.compliance_framework,
                json.dumps(compliance.data_sources),
                compliance.privacy_level,
                compliance.retention_policy,
                json.dumps(compliance.audit_trail),
                json.dumps(compliance.certifications),
                compliance.last_audit_date,
                compliance.next_audit_date,
                json.dumps(compliance.risk_assessment)
            ))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            logger.error(f"Failed to save compliance record: {e}")
    
    def _save_event_record(self, event: LifecycleEvent):
        """Save event record to database."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT INTO lifecycle_events 
                (event_id, model_id, event_type, stage_from, stage_to, timestamp, 
                 triggered_by, reason, metadata, risk_level, compliance_status)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                event.event_id,
                event.model_id,
                event.event_type,
                event.stage_from.value if event.stage_from else None,
                event.stage_to.value,
                event.timestamp,
                event.triggered_by,
                event.reason,
                json.dumps(event.metadata),
                event.risk_level,
                event.compliance_status
            ))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            logger.error(f"Failed to save event record: {e}")
    
    def _save_alert_record(self, alert: LifecycleAlert):
        """Save alert record to database."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT OR REPLACE INTO lifecycle_alerts 
                (alert_id, model_id, alert_type, priority, message, created_at, 
                 resolved_at, assigned_to, metadata)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                alert.alert_id,
                alert.model_id,
                alert.alert_type.value,
                alert.priority.value,
                alert.message,
                alert.created_at,
                alert.resolved_at,
                alert.assigned_to,
                json.dumps(alert.metadata)
            ))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            logger.error(f"Failed to save alert record: {e}")
    
    def _save_metrics_record(self, metrics: ModelMetrics):
        """Save metrics record to database."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT INTO model_metrics 
                (metric_id, model_id, timestamp, total_requests, successful_requests, 
                 error_rate, average_latency, p95_latency, p99_latency, throughput, 
                 resource_utilization, accuracy_score, confidence_score, user_satisfaction)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                str(uuid.uuid4()),
                metrics.model_id,
                metrics.timestamp,
                metrics.total_requests,
                metrics.successful_requests,
                metrics.error_rate,
                metrics.average_latency,
                metrics.p95_latency,
                metrics.p99_latency,
                metrics.throughput,
                json.dumps(metrics.resource_utilization),
                metrics.accuracy_score,
                metrics.confidence_score,
                metrics.user_satisfaction
            ))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            logger.error(f"Failed to save metrics record: {e}")
    
    def _save_lifecycle_data(self):
        """Save all lifecycle data to database."""
        try:
            # This would save all current state to database
            # Implementation depends on specific requirements
            pass
        except Exception as e:
            logger.error(f"Failed to save lifecycle data: {e}")
    
    # Analytics and reporting methods
    def _update_lifecycle_statistics(self):
        """Update lifecycle statistics."""
        try:
            self.lifecycle_stats['total_models'] = len(self.model_lifecycles)
            
            # Reset stage distribution
            for stage in LifecycleStage:
                self.lifecycle_stats['models_by_stage'][stage.value] = 0
            
            # Count models by stage
            for lifecycle in self.model_lifecycles.values():
                stage = lifecycle['current_stage']
                if stage in self.lifecycle_stats['models_by_stage']:
                    self.lifecycle_stats['models_by_stage'][stage.value] += 1
            
            # Update event and alert counts
            self.lifecycle_stats['total_events'] = len(self.lifecycle_events)
            self.lifecycle_stats['total_alerts'] = len(self.lifecycle_alerts)
            
            # Calculate resolved alerts
            resolved_count = sum(1 for alert in self.lifecycle_alerts if alert.resolved_at is not None)
            self.lifecycle_stats['resolved_alerts'] = resolved_count
            
            # Calculate average model lifetime
            if self.lifecycle_events:
                # This would calculate actual lifetime from archived models
                # For now, using placeholder calculation
                self.lifecycle_stats['avg_model_lifetime_days'] = 120.0
            
            # Calculate compliance score
            total_models = len(self.model_lifecycles)
            if total_models > 0:
                compliant_models = sum(1 for comp in self.model_compliance.values() 
                                     if comp.last_audit_date and 
                                        comp.last_audit_date > time.time() - (90 * 24 * 3600))
                self.lifecycle_stats['compliance_score'] = compliant_models / total_models
            
        except Exception as e:
            logger.error(f"Failed to update lifecycle statistics: {e}")
    
    def _generate_lifecycle_summary(self, model_id: str) -> Dict[str, Any]:
        """Generate lifecycle summary for a model."""
        try:
            lifecycle_record = self.model_lifecycles[model_id]
            
            # Calculate model age
            age_days = (time.time() - lifecycle_record['created_at']) / (24 * 3600)
            
            # Count events
            model_events = [event for event in self.lifecycle_events if event.model_id == model_id]
            event_count = len(model_events)
            
            # Get latest metrics
            latest_metrics = self._get_recent_metrics(model_id, limit=1)
            
            # Check alerts
            active_alerts = [alert for alert in self.lifecycle_alerts 
                           if alert.model_id == model_id and alert.resolved_at is None]
            
            return {
                'model_age_days': round(age_days, 2),
                'current_stage': lifecycle_record['current_stage'],
                'days_in_current_stage': round(
                    (time.time() - lifecycle_record['last_updated']) / (24 * 3600), 2
                ),
                'total_events': event_count,
                'has_performance_data': len(latest_metrics) > 0,
                'active_alerts_count': len(active_alerts),
                'compliance_status': 'compliant' if model_id in self.model_compliance else 'not_applicable',
                'lineage_depth': self._calculate_lineage_depth(model_id)
            }
            
        except Exception as e:
            logger.error(f"Failed to generate lifecycle summary for model {model_id}: {e}")
            return {}
    
    def _get_recent_metrics(self, model_id: str, limit: int = 10) -> List[Dict[str, Any]]:
        """Get recent metrics for a model."""
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            cursor.execute('''
                SELECT * FROM model_metrics 
                WHERE model_id = ? 
                ORDER BY timestamp DESC 
                LIMIT ?
            ''', (model_id, limit))
            
            metrics = []
            for row in cursor.fetchall():
                metric_data = dict(row)
                metric_data['resource_utilization'] = json.loads(metric_data.get('resource_utilization', '{}'))
                metrics.append(metric_data)
            
            conn.close()
            return metrics
            
        except Exception as e:
            logger.error(f"Failed to get recent metrics for model {model_id}: {e}")
            return []
    
    def _check_performance_alerts(self, model_id: str, metrics: ModelMetrics):
        """Check for performance-related alerts."""
        try:
            # Check error rate
            if metrics.error_rate > 0.05:  # 5% error rate threshold
                alert = LifecycleAlert(
                    alert_id=str(uuid.uuid4()),
                    model_id=model_id,
                    alert_type=AlertType.ERROR_RATE_HIGH,
                    priority=Priority.HIGH if metrics.error_rate > 0.1 else Priority.MEDIUM,
                    message=f"High error rate detected: {metrics.error_rate:.2%}",
                    created_at=time.time(),
                    resolved_at=None,
                    assigned_to=None,
                    metadata={'error_rate': metrics.error_rate}
                )
                self.lifecycle_alerts.append(alert)
                self._save_alert_record(alert)
            
            # Check latency
            if metrics.average_latency > 1000:  # 1 second threshold
                alert = LifecycleAlert(
                    alert_id=str(uuid.uuid4()),
                    model_id=model_id,
                    alert_type=AlertType.LATENCY_HIGH,
                    priority=Priority.MEDIUM,
                    message=f"High latency detected: {metrics.average_latency:.0f}ms",
                    created_at=time.time(),
                    resolved_at=None,
                    assigned_to=None,
                    metadata={'average_latency': metrics.average_latency}
                )
                self.lifecycle_alerts.append(alert)
                self._save_alert_record(alert)
            
        except Exception as e:
            logger.error(f"Error checking performance alerts for model {model_id}: {e}")
    
    def _check_model_drift(self, model_id: str, metrics: ModelMetrics):
        """Check for model drift detection."""
        try:
            # Get historical metrics for comparison
            historical_metrics = self._get_recent_metrics(model_id, limit=50)
            
            if len(historical_metrics) < 10:
                return  # Not enough data for drift detection
            
            # Check accuracy drift
            if (metrics.accuracy_score is not None and 
                historical_metrics[-1].get('accuracy_score') is not None):
                
                historical_accuracy = [m.get('accuracy_score') for m in historical_metrics 
                                     if m.get('accuracy_score') is not None]
                if historical_accuracy:
                    avg_historical_accuracy = statistics.mean(historical_accuracy)
                    accuracy_drop = avg_historical_accuracy - metrics.accuracy_score
                    
                    if accuracy_drop > 0.05:  # 5% accuracy drop
                        alert = LifecycleAlert(
                            alert_id=str(uuid.uuid4()),
                            model_id=model_id,
                            alert_type=AlertType.MODEL_DRIFT_DETECTED,
                            priority=Priority.HIGH,
                            message=f"Model accuracy drift detected: {accuracy_drop:.2%} drop",
                            created_at=time.time(),
                            resolved_at=None,
                            assigned_to=None,
                            metadata={
                                'current_accuracy': metrics.accuracy_score,
                                'historical_average': avg_historical_accuracy,
                                'accuracy_drop': accuracy_drop
                            }
                        )
                        self.lifecycle_alerts.append(alert)
                        self._save_alert_record(alert)
            
        except Exception as e:
            logger.error(f"Error checking model drift for model {model_id}: {e}")
    
    # Additional helper methods would be implemented here...
    def _check_compliance_status(self, model_id: str) -> str:
        """Check compliance status for a model."""
        if model_id not in self.model_compliance:
            return "not_applicable"
        
        compliance = self.model_compliance[model_id]
        if (compliance.last_audit_date and 
            compliance.last_audit_date > time.time() - (90 * 24 * 3600)):
            return "compliant"
        else:
            return "pending_audit"
    
    def _calculate_lineage_depth(self, model_id: str) -> int:
        """Calculate lineage depth for a model."""
        depth = 0
        current_id = model_id
        
        while current_id and current_id in self.model_lineages:
            lineage = self.model_lineages[current_id]
            if lineage.parent_model_id:
                current_id = lineage.parent_model_id
                depth += 1
            else:
                break
        
        return depth
    
    def _calculate_avg_resolution_time(self, alerts: List[LifecycleAlert]) -> float:
        """Calculate average alert resolution time."""
        if not alerts:
            return 0.0
        
        resolution_times = []
        for alert in alerts:
            if alert.resolved_at:
                resolution_time = alert.resolved_at - alert.created_at
                resolution_times.append(resolution_time)
        
        return statistics.mean(resolution_times) if resolution_times else 0.0
    
    def _analyze_model_ages(self) -> Dict[str, Any]:
        """Analyze model age distribution."""
        current_time = time.time()
        ages = []
        
        for lifecycle in self.model_lifecycles.values():
            age_days = (current_time - lifecycle['created_at']) / (24 * 3600)
            ages.append(age_days)
        
        if not ages:
            return {}
        
        return {
            'average_age_days': statistics.mean(ages),
            'median_age_days': statistics.median(ages),
            'oldest_model_days': max(ages),
            'newest_model_days': min(ages),
            'models_older_than_year': sum(1 for age in ages if age > 365),
            'models_older_than_6_months': sum(1 for age in ages if age > 180)
        }
    
    def _analyze_compliance_status(self) -> Dict[str, Any]:
        """Analyze overall compliance status."""
        total_models = len(self.model_compliance)
        if total_models == 0:
            return {'status': 'no_compliance_models'}
        
        compliant_models = 0
        pending_audit = 0
        
        for compliance in self.model_compliance.values():
            if (compliance.last_audit_date and 
                compliance.last_audit_date > time.time() - (90 * 24 * 3600)):
                compliant_models += 1
            else:
                pending_audit += 1
        
        return {
            'total_compliance_models': total_models,
            'compliant_models': compliant_models,
            'pending_audit_models': pending_audit,
            'compliance_rate': compliant_models / total_models,
            'frameworks': list(set(c.compliance_framework for c in self.model_compliance.values()))
        }
    
    def _generate_lifecycle_insights(self) -> List[str]:
        """Generate lifecycle insights and recommendations."""
        insights = []
        
        # Check for models with high alert counts
        alert_counts = {}
        for alert in self.lifecycle_alerts:
            if alert.resolved_at is None:
                alert_counts[alert.model_id] = alert_counts.get(alert.model_id, 0) + 1
        
        high_alert_models = [model_id for model_id, count in alert_counts.items() if count > 5]
        if high_alert_models:
            insights.append(f"Models with high alert counts: {', '.join(high_alert_models[:5])}")
        
        # Check for models in same stage for long time
        current_time = time.time()
        for model_id, lifecycle in self.model_lifecycles.items():
            days_in_stage = (current_time - lifecycle['last_updated']) / (24 * 3600)
            if days_in_stage > 30 and lifecycle['current_stage'] in [LifecycleStage.STAGING.value, 
                                                                   LifecycleStage.PERFORMANCE_REVIEW.value]:
                insights.append(f"Model {model_id} has been in {lifecycle['current_stage']} for {days_in_stage:.0f} days")
        
        return insights
    
    def _generate_lifecycle_recommendations(self) -> List[str]:
        """Generate lifecycle management recommendations."""
        recommendations = []
        
        # Recommend retirement for old models
        current_time = time.time()
        for model_id, lifecycle in self.model_lifecycles.items():
            age_days = (current_time - lifecycle['created_at']) / (24 * 3600)
            if age_days > 365 and lifecycle['current_stage'] == LifecycleStage.PRODUCTION.value:
                recommendations.append(f"Consider reviewing model {model_id} for retirement (age: {age_days:.0f} days)")
        
        # Recommend compliance audits
        for model_id, compliance in self.model_compliance.items():
            if (compliance.next_audit_date and 
                compliance.next_audit_date <= current_time + (7 * 24 * 3600)):
                recommendations.append(f"Schedule compliance audit for model {model_id}")
        
        return recommendations
    
    # Placeholder methods for monitoring and cleanup
    def _check_performance_degradation(self, model_id: str, metrics: List[Dict[str, Any]]):
        """Check for performance degradation."""
        pass  # Implementation would analyze metrics trends
    
    def _check_usage_patterns(self, model_id: str, metrics: List[Dict[str, Any]]):
        """Check for usage pattern changes."""
        pass  # Implementation would analyze usage trends
    
    def _check_resource_utilization(self, model_id: str, metrics: List[Dict[str, Any]]):
        """Check for resource utilization issues."""
        pass  # Implementation would analyze resource usage
    
    def _check_compliance_drift(self, model_id: str):
        """Check for compliance drift."""
        pass  # Implementation would check compliance over time
    
    def _cleanup_old_events(self):
        """Cleanup old lifecycle events."""
        pass  # Implementation would remove events older than retention period
    
    def _cleanup_old_metrics(self):
        """Cleanup old metrics data."""
        pass  # Implementation would remove metrics older than retention period
    
    def _optimize_database(self):
        """Optimize database performance."""
        pass  # Implementation would run database optimization commands


# Global instance for convenience
_global_lifecycle_manager = None


def get_lifecycle_manager() -> LifecycleManager:
    """
    Get a global lifecycle manager instance.
    
    Returns:
        LifecycleManager: A lifecycle manager instance
    """
    global _global_lifecycle_manager
    
    if _global_lifecycle_manager is None:
        _global_lifecycle_manager = LifecycleManager()
    
    return _global_lifecycle_manager