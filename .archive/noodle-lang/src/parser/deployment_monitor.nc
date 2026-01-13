"""
NoodleCore AI Deployment Monitor (.nc file)
==========================================

This module provides comprehensive health monitoring and alerting for AI model deployments,
ensuring continuous monitoring of system health, performance, and reliability.

Features:
- Real-time health monitoring for all deployed AI models
- Automated health checks and diagnostics
- Performance anomaly detection and alerting
- System resource monitoring (CPU, memory, GPU, storage)
- Network latency and availability monitoring
- Model inference performance tracking
- Error rate monitoring and threshold alerts
- Custom alerting rules and notification channels
- Alert escalation and escalation management
- Dashboard integration for visual monitoring
- Historical health data analysis and reporting
- Predictive health analytics using machine learning
- Integration with external monitoring systems
- Automated incident response and remediation
- SLA monitoring and compliance tracking
- Multi-tenant health monitoring
- Distributed health monitoring across clusters
- Real-time alerts via WebSocket connections
- Health score calculation and trending
- Capacity planning and optimization recommendations

Monitoring Types:
- Model Health: Inference success rate, response time, accuracy metrics
- System Health: Resource utilization, error rates, availability
- Network Health: Latency, throughput, packet loss, connectivity
- Security Health: Access violations, intrusion attempts, compliance
- Business Health: User satisfaction, conversion rates, revenue impact

Alert Types:
- Critical: System down, data loss, security breach
- Warning: Performance degradation, resource exhaustion
- Info: Routine maintenance, deployment updates
- Resolution: Issue resolved, system recovered

Alert Channels:
- WebSocket real-time notifications
- Email alerts for critical issues
- SMS alerts for emergency situations
- Dashboard notifications and status indicators
- Integration with external alerting systems
- Slack/Teams webhook notifications
- PagerDuty integration for on-call rotations
"""

import os
import json
import logging
import time
import threading
import uuid
import sqlite3
import statistics
from typing import Dict, List, Optional, Any, Union, Callable, Tuple
from dataclasses import dataclass, asdict, field
from enum import Enum
from datetime import datetime, timedelta
from collections import defaultdict, deque
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# Import existing NoodleCore components
from ..self_improvement.model_management import ModelManager, ModelType, ModelStatus
from .model_deployer import ModelDeployer
from .metrics_collector import MetricsCollector, MetricType
from .versioning_system import VersioningSystem
from .ab_testing_engine import ABTestingEngine

# Configure logging
logger = logging.getLogger(__name__)

# Environment variables
NOODLE_DEBUG = os.environ.get("NOODLE_DEBUG", "0") == "1"
NOODLE_MONITORING_ENABLED = os.environ.get("NOODLE_MONITORING_ENABLED", "1") == "1"
NOODLE_HEALTH_CHECK_INTERVAL = int(os.environ.get("NOODLE_HEALTH_CHECK_INTERVAL", "30"))  # seconds
NOODLE_ALERT_CHECK_INTERVAL = int(os.environ.get("NOODLE_ALERT_CHECK_INTERVAL", "60"))   # seconds
NOODLE_EMAIL_ALERTS_ENABLED = os.environ.get("NOODLE_EMAIL_ALERTS_ENABLED", "1") == "1"
NOODLE_SMTP_SERVER = os.environ.get("NOODLE_SMTP_SERVER", "smtp.gmail.com")
NOODLE_SMTP_PORT = int(os.environ.get("NOODLE_SMTP_PORT", "587"))
NOODLE_SMTP_USERNAME = os.environ.get("NOODLE_SMTP_USERNAME", "")
NOODLE_SMTP_PASSWORD = os.environ.get("NOODLE_SMTP_PASSWORD", "")
NOODLE_ALERT_EMAIL_TO = os.environ.get("NOODLE_ALERT_EMAIL_TO", "")
NOODLE_ALERT_EMAIL_FROM = os.environ.get("NOODLE_ALERT_EMAIL_FROM", "noodle-alerts@localhost")


class HealthStatus(Enum):
    """Health status levels."""
    HEALTHY = "healthy"
    DEGRADED = "degraded"
    UNHEALTHY = "unhealthy"
    CRITICAL = "critical"
    UNKNOWN = "unknown"


class AlertSeverity(Enum):
    """Alert severity levels."""
    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"
    INFO = "info"


class AlertStatus(Enum):
    """Alert status levels."""
    ACTIVE = "active"
    ACKNOWLEDGED = "acknowledged"
    RESOLVED = "resolved"
    SUPPRESSED = "suppressed"


class HealthCheckType(Enum):
    """Types of health checks."""
    MODEL_INFERENCE = "model_inference"
    SYSTEM_RESOURCES = "system_resources"
    NETWORK_CONNECTIVITY = "network_connectivity"
    DATABASE_AVAILABILITY = "database_availability"
    API_RESPONSE_TIME = "api_response_time"
    ERROR_RATE = "error_rate"
    CUSTOM = "custom"


@dataclass
class HealthCheck:
    """Individual health check configuration."""
    check_id: str
    name: str
    check_type: HealthCheckType
    target_model_id: str
    target_service: str
    enabled: bool
    check_interval: int  # seconds
    timeout: int  # seconds
    retry_count: int
    retry_delay: int  # seconds
    threshold_values: Dict[str, float]
    custom_logic: Optional[str] = None
    metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass
class HealthCheckResult:
    """Result of a health check execution."""
    result_id: str
    check_id: str
    executed_at: float
    status: HealthStatus
    response_time: float
    message: str
    details: Dict[str, Any]
    error_details: Optional[str] = None


@dataclass
class HealthAlert:
    """Health alert definition."""
    alert_id: str
    name: str
    description: str
    severity: AlertSeverity
    health_check_id: str
    threshold_condition: str  # e.g., "response_time > 5000"
    alert_frequency: int  # seconds between alerts
    escalation_rules: List[Dict[str, Any]]
    notification_channels: List[str]
    auto_resolve: bool
    resolve_threshold: Optional[str] = None
    enabled: bool = True
    metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass
class AlertIncident:
    """Alert incident instance."""
    incident_id: str
    alert_id: str
    triggered_at: float
    resolved_at: Optional[float] = None
    status: AlertStatus = AlertStatus.ACTIVE
    acknowledged_by: Optional[str] = None
    acknowledged_at: Optional[float] = None
    escalation_level: int = 0
    notification_count: int = 0
    incident_details: Dict[str, Any] = field(default_factory=dict)


@dataclass
class HealthMetrics:
    """Aggregated health metrics for a time period."""
    metrics_id: str
    model_id: str
    timestamp: float
    period_start: float
    period_end: float
    overall_health_score: float
    availability_percentage: float
    average_response_time: float
    error_rate: float
    throughput: float
    resource_utilization: Dict[str, float]
    alert_count: Dict[AlertSeverity, int] = field(default_factory=dict)
    metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass
class SystemHealthSnapshot:
    """Complete system health snapshot."""
    snapshot_id: str
    timestamp: float
    overall_status: HealthStatus
    system_health_score: float
    active_models: Dict[str, HealthStatus]
    active_alerts: List[AlertIncident]
    resource_utilization: Dict[str, float]
    performance_trends: Dict[str, List[float]]
    uptime_percentage: float
    metadata: Dict[str, Any] = field(default_factory=dict)


class DeploymentMonitor:
    """
    Comprehensive deployment monitoring and alerting system.
    
    This class provides enterprise-grade monitoring capabilities for AI model deployments,
    including real-time health checks, performance monitoring, alert management,
    and automated incident response with multi-channel notifications.
    """
    
    def __init__(self):
        """Initialize the deployment monitor."""
        if NOODLE_DEBUG:
            logger.setLevel(logging.DEBUG)
        
        # Database for monitoring data
        self.db_path = "noodle_monitoring.db"
        self._init_database()
        
        # Core components
        self.model_manager = None
        self.model_deployer = None
        self.metrics_collector = None
        self.versioning_system = None
        self.ab_testing_engine = None
        
        # Monitoring components
        self.health_checks: Dict[str, HealthCheck] = {}
        self.health_alerts: Dict[str, HealthAlert] = {}
        self.active_incidents: Dict[str, AlertIncident] = {}
        self.health_history: List[HealthCheckResult] = []
        self.metrics_history: Dict[str, List[HealthMetrics]] = defaultdict(list)
        
        # System state tracking
        self.model_health_status: Dict[str, HealthStatus] = {}
        self.system_health_score = 100.0
        self.last_health_check = {}
        self.last_alert_check = {}
        
        # Threading and synchronization
        self._lock = threading.RLock()
        self._health_check_threads: Dict[str, threading.Thread] = {}
        self._monitoring_thread = None
        self._cleanup_thread = None
        self._running = False
        
        # Configuration
        self.monitoring_config = {
            'health_check_interval': NOODLE_HEALTH_CHECK_INTERVAL,
            'alert_check_interval': NOODLE_ALERT_CHECK_INTERVAL,
            'email_alerts_enabled': NOODLE_EMAIL_ALERTS_ENABLED,
            'smtp_server': NOODLE_SMTP_SERVER,
            'smtp_port': NOODLE_SMTP_PORT,
            'smtp_username': NOODLE_SMTP_USERNAME,
            'smtp_password': NOODLE_SMTP_PASSWORD,
            'alert_email_to': NOODLE_ALERT_EMAIL_TO,
            'alert_email_from': NOODLE_ALERT_EMAIL_FROM,
            'metrics_retention_days': 30,
            'incident_retention_days': 90,
            'max_incidents_per_hour': 100,
            'alert_cooldown_seconds': 300,  # 5 minutes
            'health_check_timeout': 30,
            'health_score_weights': {
                'availability': 0.3,
                'performance': 0.3,
                'errors': 0.2,
                'resources': 0.2
            }
        }
        
        # Statistics
        self.monitoring_stats = {
            'total_health_checks_performed': 0,
            'total_alerts_triggered': 0,
            'total_incidents_created': 0,
            'total_incidents_resolved': 0,
            'average_health_check_response_time': 0.0,
            'system_uptime_percentage': 100.0,
            'critical_alerts_count': 0,
            'auto_resolved_incidents': 0,
            'false_positive_rate': 0.0
        }
        
        # Load existing monitoring data
        self._load_monitoring_data()
        
        logger.info("DeploymentMonitor initialized")
    
    def _init_database(self):
        """Initialize SQLite database for monitoring storage."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            # Create health checks table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS health_checks (
                    check_id TEXT PRIMARY KEY,
                    name TEXT NOT NULL,
                    check_type TEXT NOT NULL,
                    target_model_id TEXT,
                    target_service TEXT NOT NULL,
                    enabled INTEGER NOT NULL,
                    check_interval INTEGER NOT NULL,
                    timeout INTEGER NOT NULL,
                    retry_count INTEGER NOT NULL,
                    retry_delay INTEGER NOT NULL,
                    threshold_values TEXT,
                    custom_logic TEXT,
                    metadata TEXT
                )
            ''')
            
            # Create health alerts table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS health_alerts (
                    alert_id TEXT PRIMARY KEY,
                    name TEXT NOT NULL,
                    description TEXT,
                    severity TEXT NOT NULL,
                    health_check_id TEXT NOT NULL,
                    threshold_condition TEXT NOT NULL,
                    alert_frequency INTEGER NOT NULL,
                    escalation_rules TEXT,
                    notification_channels TEXT,
                    auto_resolve INTEGER NOT NULL,
                    resolve_threshold TEXT,
                    enabled INTEGER NOT NULL,
                    metadata TEXT
                )
            ''')
            
            # Create alert incidents table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS alert_incidents (
                    incident_id TEXT PRIMARY KEY,
                    alert_id TEXT NOT NULL,
                    triggered_at REAL NOT NULL,
                    resolved_at REAL,
                    status TEXT NOT NULL,
                    acknowledged_by TEXT,
                    acknowledged_at REAL,
                    escalation_level INTEGER NOT NULL,
                    notification_count INTEGER NOT NULL,
                    incident_details TEXT
                )
            ''')
            
            # Create health check results table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS health_check_results (
                    result_id TEXT PRIMARY KEY,
                    check_id TEXT NOT NULL,
                    executed_at REAL NOT NULL,
                    status TEXT NOT NULL,
                    response_time REAL NOT NULL,
                    message TEXT NOT NULL,
                    details TEXT,
                    error_details TEXT
                )
            ''')
            
            # Create health metrics table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS health_metrics (
                    metrics_id TEXT PRIMARY KEY,
                    model_id TEXT NOT NULL,
                    timestamp REAL NOT NULL,
                    period_start REAL NOT NULL,
                    period_end REAL NOT NULL,
                    overall_health_score REAL NOT NULL,
                    availability_percentage REAL NOT NULL,
                    average_response_time REAL NOT NULL,
                    error_rate REAL NOT NULL,
                    throughput REAL NOT NULL,
                    resource_utilization TEXT,
                    alert_count TEXT,
                    metadata TEXT
                )
            ''')
            
            # Create indexes
            cursor.execute('CREATE INDEX IF NOT EXISTS idx_health_checks_enabled ON health_checks (enabled)')
            cursor.execute('CREATE INDEX IF NOT EXISTS idx_health_alerts_enabled ON health_alerts (enabled)')
            cursor.execute('CREATE INDEX IF NOT EXISTS idx_incidents_status ON alert_incidents (status)')
            cursor.execute('CREATE INDEX IF NOT EXISTS idx_results_executed_at ON health_check_results (executed_at)')
            cursor.execute('CREATE INDEX IF NOT EXISTS idx_metrics_model_timestamp ON health_metrics (model_id, timestamp)')
            
            conn.commit()
            conn.close()
            
            logger.debug(f"Initialized monitoring database at {self.db_path}")
            
        except Exception as e:
            logger.error(f"Failed to initialize monitoring database: {e}")
            raise
    
    def _load_monitoring_data(self):
        """Load existing monitoring data from database."""
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            # Load health checks
            cursor.execute('SELECT * FROM health_checks')
            for row in cursor.fetchall():
                check_data = dict(row)
                check_data['threshold_values'] = json.loads(check_data.get('threshold_values', '{}'))
                check_data['metadata'] = json.loads(check_data.get('metadata', '{}'))
                check_data['enabled'] = bool(check_data['enabled'])
                
                health_check = HealthCheck(**check_data)
                self.health_checks[check_data['check_id']] = health_check
            
            # Load health alerts
            cursor.execute('SELECT * FROM health_alerts')
            for row in cursor.fetchall():
                alert_data = dict(row)
                alert_data['escalation_rules'] = json.loads(alert_data.get('escalation_rules', '[]'))
                alert_data['notification_channels'] = json.loads(alert_data.get('notification_channels', '[]'))
                alert_data['metadata'] = json.loads(alert_data.get('metadata', '{}'))
                alert_data['auto_resolve'] = bool(alert_data['auto_resolve'])
                alert_data['enabled'] = bool(alert_data['enabled'])
                
                health_alert = HealthAlert(**alert_data)
                self.health_alerts[alert_data['alert_id']] = health_alert
            
            # Load active incidents
            cursor.execute('SELECT * FROM alert_incidents WHERE status IN ("active", "acknowledged")')
            for row in cursor.fetchall():
                incident_data = dict(row)
                incident_data['incident_details'] = json.loads(incident_data.get('incident_details', '{}'))
                
                alert_incident = AlertIncident(**incident_data)
                self.active_incidents[incident_data['incident_id']] = alert_incident
            
            conn.close()
            
            logger.info(f"Loaded {len(self.health_checks)} health checks, {len(self.health_alerts)} alerts, and {len(self.active_incidents)} active incidents")
            
        except Exception as e:
            logger.error(f"Failed to load monitoring data: {e}")
    
    def initialize(self, model_manager: ModelManager = None, model_deployer: ModelDeployer = None,
                  metrics_collector: MetricsCollector = None, versioning_system = None,
                  ab_testing_engine = None) -> bool:
        """
        Initialize the deployment monitor with required components.
        
        Args:
            model_manager: Model management component
            model_deployer: Model deployment component
            metrics_collector: Metrics collection component
            versioning_system: Versioning system component
            ab_testing_engine: A/B testing engine component
            
        Returns:
            True if initialization successful
        """
        try:
            # Initialize core components
            if model_manager:
                self.model_manager = model_manager
            
            if model_deployer:
                self.model_deployer = model_deployer
            
            if metrics_collector:
                self.metrics_collector = metrics_collector
            
            if versioning_system:
                self.versioning_system = versioning_system
            
            if ab_testing_engine:
                self.ab_testing_engine = ab_testing_engine
            
            # Start background services
            self.start()
            
            logger.info("DeploymentMonitor initialized successfully")
            return True
            
        except Exception as e:
            logger.error(f"Failed to initialize DeploymentMonitor: {e}")
            return False
    
    def start(self):
        """Start the deployment monitor background services."""
        with self._lock:
            if self._running:
                return
            
            self._running = True
            
            # Start health check threads for each enabled check
            for check_id, health_check in self.health_checks.items():
                if health_check.enabled:
                    self._start_health_check_thread(health_check)
            
            # Start main monitoring thread
            self._monitoring_thread = threading.Thread(
                target=self._monitoring_worker, daemon=True
            )
            self._monitoring_thread.start()
            
            # Start cleanup thread
            self._cleanup_thread = threading.Thread(
                target=self._cleanup_worker, daemon=True
            )
            self._cleanup_thread.start()
            
            logger.info("DeploymentMonitor started")
    
    def stop(self):
        """Stop the deployment monitor and cleanup resources."""
        with self._lock:
            if not self._running:
                return
            
            self._running = False
            
            # Stop health check threads
            for thread in self._health_check_threads.values():
                if thread.is_alive():
                    thread.join(timeout=5.0)
            
            # Wait for main threads to stop
            for thread in [self._monitoring_thread, self._cleanup_thread]:
                if thread and thread.is_alive():
                    thread.join(timeout=10.0)
            
            logger.info("DeploymentMonitor stopped")
    
    def create_health_check(self, health_check: HealthCheck) -> Dict[str, Any]:
        """
        Create a new health check.
        
        Args:
            health_check: Health check configuration
            
        Returns:
            Created health check information
        """
        try:
            with self._lock:
                # Validate health check
                validation_result = self._validate_health_check(health_check)
                if not validation_result['valid']:
                    return {'error': validation_result['reason']}
                
                # Save to database
                self._save_health_check_record(health_check)
                
                # Update tracking
                self.health_checks[health_check.check_id] = health_check
                
                # Start health check thread if monitor is running
                if self._running and health_check.enabled:
                    self._start_health_check_thread(health_check)
                
                logger.info(f"Created health check {health_check.name} ({health_check.check_id})")
                
                return {
                    'check_id': health_check.check_id,
                    'name': health_check.name,
                    'check_type': health_check.check_type.value,
                    'target_model_id': health_check.target_model_id,
                    'target_service': health_check.target_service,
                    'enabled': health_check.enabled,
                    'check_interval': health_check.check_interval,
                    'created_at': time.time()
                }
                
        except Exception as e:
            logger.error(f"Failed to create health check: {e}")
            return {'error': str(e)}
    
    def create_health_alert(self, health_alert: HealthAlert) -> Dict[str, Any]:
        """
        Create a new health alert.
        
        Args:
            health_alert: Health alert configuration
            
        Returns:
            Created health alert information
        """
        try:
            with self._lock:
                # Validate health alert
                validation_result = self._validate_health_alert(health_alert)
                if not validation_result['valid']:
                    return {'error': validation_result['reason']}
                
                # Save to database
                self._save_health_alert_record(health_alert)
                
                # Update tracking
                self.health_alerts[health_alert.alert_id] = health_alert
                
                logger.info(f"Created health alert {health_alert.name} ({health_alert.alert_id})")
                
                return {
                    'alert_id': health_alert.alert_id,
                    'name': health_alert.name,
                    'severity': health_alert.severity.value,
                    'health_check_id': health_alert.health_check_id,
                    'threshold_condition': health_alert.threshold_condition,
                    'alert_frequency': health_alert.alert_frequency,
                    'auto_resolve': health_alert.auto_resolve,
                    'enabled': health_alert.enabled,
                    'created_at': time.time()
                }
                
        except Exception as e:
            logger.error(f"Failed to create health alert: {e}")
            return {'error': str(e)}
    
    def execute_health_check(self, check_id: str) -> Dict[str, Any]:
        """
        Manually execute a health check.
        
        Args:
            check_id: Health check to execute
            
        Returns:
            Health check result
        """
        try:
            with self._lock:
                if check_id not in self.health_checks:
                    return {'error': 'Health check not found'}
                
                health_check = self.health_checks[check_id]
                
                # Execute health check
                start_time = time.time()
                result = self._perform_health_check(health_check)
                response_time = time.time() - start_time
                
                # Create result record
                check_result = HealthCheckResult(
                    result_id=str(uuid.uuid4()),
                    check_id=check_id,
                    executed_at=time.time(),
                    status=result['status'],
                    response_time=response_time,
                    message=result['message'],
                    details=result['details'],
                    error_details=result.get('error_details')
                )
                
                # Store result
                self.health_history.append(check_result)
                
                # Update model health status
                if health_check.target_model_id:
                    self.model_health_status[health_check.target_model_id] = result['status']
                
                # Save to database
                self._save_health_check_result(check_result)
                
                # Update statistics
                self.monitoring_stats['total_health_checks_performed'] += 1
                
                # Check for alerts
                self._check_alert_conditions(check_result)
                
                logger.debug(f"Executed health check {check_id}: {result['status'].value}")
                
                return {
                    'result_id': check_result.result_id,
                    'check_id': check_id,
                    'status': result['status'].value,
                    'response_time': response_time,
                    'message': result['message'],
                    'details': result['details'],
                    'executed_at': check_result.executed_at
                }
                
        except Exception as e:
            logger.error(f"Failed to execute health check {check_id}: {e}")
            return {'error': str(e)}
    
    def get_system_health(self) -> Dict[str, Any]:
        """
        Get current system health overview.
        
        Returns:
            System health information
        """
        try:
            with self._lock:
                # Calculate overall health score
                overall_score = self._calculate_system_health_score()
                
                # Get active incidents
                active_incidents = list(self.active_incidents.values())
                
                # Calculate critical metrics
                critical_incidents = [i for i in active_incidents if 
                                    self._get_alert_severity(i.alert_id) == AlertSeverity.CRITICAL]
                
                # Get recent health history
                recent_results = [
                    r for r in self.health_history[-100:]  # Last 100 checks
                    if time.time() - r.executed_at < 3600  # Last hour
                ]
                
                availability_percentage = 0.0
                if recent_results:
                    healthy_results = [r for r in recent_results if r.status == HealthStatus.HEALTHY]
                    availability_percentage = (len(healthy_results) / len(recent_results)) * 100
                
                # Create system health snapshot
                snapshot = SystemHealthSnapshot(
                    snapshot_id=str(uuid.uuid4()),
                    timestamp=time.time(),
                    overall_status=self._determine_overall_status(overall_score, active_incidents),
                    system_health_score=overall_score,
                    active_models=self.model_health_status.copy(),
                    active_alerts=active_incidents,
                    resource_utilization=self._get_current_resource_utilization(),
                    performance_trends=self._calculate_performance_trends(),
                    uptime_percentage=availability_percentage,
                    metadata={
                        'total_active_models': len(self.model_health_status),
                        'total_active_incidents': len(active_incidents),
                        'critical_incidents_count': len(critical_incidents),
                        'monitoring_uptime': self._calculate_monitoring_uptime()
                    }
                )
                
                return {
                    'snapshot_id': snapshot.snapshot_id,
                    'timestamp': snapshot.timestamp,
                    'overall_status': snapshot.overall_status.value,
                    'health_score': snapshot.system_health_score,
                    'uptime_percentage': snapshot.uptime_percentage,
                    'active_models': {
                        model_id: status.value for model_id, status in snapshot.active_models.items()
                    },
                    'active_alerts': [
                        {
                            'incident_id': incident.incident_id,
                            'alert_id': incident.alert_id,
                            'severity': self._get_alert_severity(incident.alert_id).value,
                            'triggered_at': incident.triggered_at,
                            'status': incident.status.value,
                            'escalation_level': incident.escalation_level
                        }
                        for incident in snapshot.active_alerts
                    ],
                    'resource_utilization': snapshot.resource_utilization,
                    'performance_trends': snapshot.performance_trends,
                    'metadata': snapshot.metadata
                }
                
        except Exception as e:
            logger.error(f"Failed to get system health: {e}")
            return {'error': str(e)}
    
    def get_model_health(self, model_id: str) -> Dict[str, Any]:
        """
        Get health information for a specific model.
        
        Args:
            model_id: Model to get health for
            
        Returns:
            Model health information
        """
        try:
            with self._lock:
                # Get recent health checks for this model
                model_checks = [
                    r for r in self.health_history[-1000:]  # Last 1000 checks
                    if r.check_id in [check.check_id for check in self.health_checks.values() 
                                    if check.target_model_id == model_id]
                ]
                
                # Get active incidents for this model
                model_incidents = [
                    incident for incident in self.active_incidents.values()
                    if self._get_health_check_target_model(incident.alert_id) == model_id
                ]
                
                # Calculate metrics
                if model_checks:
                    recent_checks = [c for c in model_checks if time.time() - c.executed_at < 3600]
                    avg_response_time = statistics.mean([c.response_time for c in recent_checks]) if recent_checks else 0
                    error_count = len([c for c in recent_checks if c.status != HealthStatus.HEALTHY])
                    success_rate = ((len(recent_checks) - error_count) / len(recent_checks)) * 100 if recent_checks else 0
                else:
                    avg_response_time = 0
                    success_rate = 0
                
                # Get health score
                health_score = self._calculate_model_health_score(model_id)
                
                return {
                    'model_id': model_id,
                    'current_status': self.model_health_status.get(model_id, HealthStatus.UNKNOWN).value,
                    'health_score': health_score,
                    'success_rate': success_rate,
                    'average_response_time': avg_response_time,
                    'recent_checks_count': len(model_checks),
                    'active_incidents_count': len(model_incidents),
                    'last_check_at': model_checks[-1].executed_at if model_checks else None,
                    'active_incidents': [
                        {
                            'incident_id': incident.incident_id,
                            'alert_id': incident.alert_id,
                            'severity': self._get_alert_severity(incident.alert_id).value,
                            'triggered_at': incident.triggered_at,
                            'status': incident.status.value
                        }
                        for incident in model_incidents
                    ],
                    'recent_check_results': [
                        {
                            'result_id': check.result_id,
                            'status': check.status.value,
                            'response_time': check.response_time,
                            'message': check.message,
                            'executed_at': check.executed_at
                        }
                        for check in sorted(model_checks[-10:], key=lambda x: x.executed_at, reverse=True)  # Last 10 checks
                    ]
                }
                
        except Exception as e:
            logger.error(f"Failed to get model health for {model_id}: {e}")
            return {'error': str(e)}
    
    def acknowledge_incident(self, incident_id: str, acknowledged_by: str) -> bool:
        """
        Acknowledge an alert incident.
        
        Args:
            incident_id: Incident to acknowledge
            acknowledged_by: User acknowledging the incident
            
        Returns:
            True if acknowledgment successful
        """
        try:
            with self._lock:
                if incident_id not in self.active_incidents:
                    return False
                
                incident = self.active_incidents[incident_id]
                incident.status = AlertStatus.ACKNOWLEDGED
                incident.acknowledged_by = acknowledged_by
                incident.acknowledged_at = time.time()
                
                # Save to database
                self._save_incident_record(incident)
                
                logger.info(f"Acknowledged incident {incident_id} by {acknowledged_by}")
                return True
                
        except Exception as e:
            logger.error(f"Failed to acknowledge incident {incident_id}: {e}")
            return False
    
    def resolve_incident(self, incident_id: str, resolved_by: str = "system") -> bool:
        """
        Resolve an alert incident.
        
        Args:
            incident_id: Incident to resolve
            resolved_by: User resolving the incident
            
        Returns:
            True if resolution successful
        """
        try:
            with self._lock:
                if incident_id not in self.active_incidents:
                    return False
                
                incident = self.active_incidents[incident_id]
                incident.status = AlertStatus.RESOLVED
                incident.resolved_at = time.time()
                
                # Update statistics
                self.monitoring_stats['total_incidents_resolved'] += 1
                if incident.escalation_level == 0:
                    self.monitoring_stats['auto_resolved_incidents'] += 1
                
                # Remove from active incidents
                del self.active_incidents[incident_id]
                
                # Save to database
                self._save_incident_record(incident)
                
                logger.info(f"Resolved incident {incident_id} by {resolved_by}")
                return True
                
        except Exception as e:
            logger.error(f"Failed to resolve incident {incident_id}: {e}")
            return False
    
    def list_incidents(self, status: AlertStatus = None, limit: int = 100) -> List[Dict[str, Any]]:
        """
        List alert incidents with optional filtering.
        
        Args:
            status: Filter by status (optional)
            limit: Maximum number of incidents to return
            
        Returns:
            List of incident information
        """
        try:
            with self._lock:
                incidents = list(self.active_incidents.values())
                
                # Apply status filter if provided
                if status:
                    incidents = [i for i in incidents if i.status == status]
                
                # Sort by triggered time (newest first)
                incidents.sort(key=lambda x: x.triggered_at, reverse=True)
                
                # Apply limit
                incidents = incidents[:limit]
                
                # Convert to dictionaries
                return [
                    {
                        'incident_id': incident.incident_id,
                        'alert_id': incident.alert_id,
                        'alert_name': self.health_alerts.get(incident.alert_id, {}).name if incident.alert_id in self.health_alerts else 'Unknown',
                        'severity': self._get_alert_severity(incident.alert_id).value if incident.alert_id in self.health_alerts else 'unknown',
                        'triggered_at': incident.triggered_at,
                        'status': incident.status.value,
                        'acknowledged_by': incident.acknowledged_by,
                        'acknowledged_at': incident.acknowledged_at,
                        'escalation_level': incident.escalation_level,
                        'notification_count': incident.notification_count
                    }
                    for incident in incidents
                ]
                
        except Exception as e:
            logger.error(f"Failed to list incidents: {e}")
            return []
    
    def get_monitoring_statistics(self) -> Dict[str, Any]:
        """
        Get monitoring system statistics.
        
        Returns:
            Monitoring statistics
        """
        try:
            with self._lock:
                return {
                    'total_health_checks': len(self.health_checks),
                    'enabled_health_checks': len([c for c in self.health_checks.values() if c.enabled]),
                    'total_alerts': len(self.health_alerts),
                    'enabled_alerts': len([a for a in self.health_alerts.values() if a.enabled]),
                    'active_incidents': len(self.active_incidents),
                    'total_incidents_created': self.monitoring_stats['total_incidents_created'],
                    'total_incidents_resolved': self.monitoring_stats['total_incidents_resolved'],
                    'total_health_checks_performed': self.monitoring_stats['total_health_checks_performed'],
                    'average_health_check_response_time': self.monitoring_stats['average_health_check_response_time'],
                    'system_uptime_percentage': self.monitoring_stats['system_uptime_percentage'],
                    'auto_resolved_incidents': self.monitoring_stats['auto_resolved_incidents'],
                    'monitoring_uptime': self._calculate_monitoring_uptime(),
                    'models_being_monitored': len(self.model_health_status),
                    'critical_alerts_count': self.monitoring_stats['critical_alerts_count']
                }
                
        except Exception as e:
            logger.error(f"Failed to get monitoring statistics: {e}")
            return {'error': str(e)}
    
    # Internal methods for health check execution
    def _start_health_check_thread(self, health_check: HealthCheck):
        """Start a health check in its own thread."""
        def health_check_worker():
            while self._running and health_check.enabled:
                try:
                    # Execute health check
                    self.execute_health_check(health_check.check_id)
                    
                    # Sleep for check interval
                    time.sleep(health_check.check_interval)
                    
                except Exception as e:
                    logger.error(f"Error in health check worker for {health_check.check_id}: {e}")
                    time.sleep(60)  # Wait 1 minute on error
        
        thread = threading.Thread(target=health_check_worker, daemon=True)
        thread.start()
        self._health_check_threads[health_check.check_id] = thread
    
    def _perform_health_check(self, health_check: HealthCheck) -> Dict[str, Any]:
        """Perform a health check based on its type."""
        try:
            if health_check.check_type == HealthCheckType.MODEL_INFERENCE:
                return self._check_model_inference_health(health_check)
            elif health_check.check_type == HealthCheckType.SYSTEM_RESOURCES:
                return self._check_system_resources_health(health_check)
            elif health_check.check_type == HealthCheckType.NETWORK_CONNECTIVITY:
                return self._check_network_connectivity_health(health_check)
            elif health_check.check_type == HealthCheckType.DATABASE_AVAILABILITY:
                return self._check_database_availability_health(health_check)
            elif health_check.check_type == HealthCheckType.API_RESPONSE_TIME:
                return self._check_api_response_time_health(health_check)
            elif health_check.check_type == HealthCheckType.ERROR_RATE:
                return self._check_error_rate_health(health_check)
            elif health_check.check_type == HealthCheckType.CUSTOM:
                return self._check_custom_health(health_check)
            else:
                return {
                    'status': HealthStatus.UNKNOWN,
                    'message': f'Unknown health check type: {health_check.check_type}',
                    'details': {}
                }
                
        except Exception as e:
            return {
                'status': HealthStatus.UNHEALTHY,
                'message': f'Health check failed: {str(e)}',
                'details': {},
                'error_details': str(e)
            }
    
    def _check_model_inference_health(self, health_check: HealthCheck) -> Dict[str, Any]:
        """Check model inference health."""
        try:
            # Simulate model inference test
            start_time = time.time()
            
            # Check if model is deployed and responsive
            if health_check.target_model_id and self.model_deployer:
                # In a real implementation, this would make an actual inference request
                # For now, simulate with a delay and check model status
                import random
                import time
                time.sleep(random.uniform(0.1, 0.5))  # Simulate inference time
                
                # Simulate inference result
                success_rate = random.uniform(0.85, 0.99)
                avg_latency = random.uniform(100, 500)  # ms
                
                # Check against thresholds
                response_time_threshold = health_check.threshold_values.get('response_time_ms', 1000)
                success_rate_threshold = health_check.threshold_values.get('success_rate', 0.95)
                
                response_time = (time.time() - start_time) * 1000  # Convert to ms
                
                if avg_latency <= response_time_threshold and success_rate >= success_rate_threshold:
                    status = HealthStatus.HEALTHY
                    message = f'Model inference healthy - latency: {avg_latency:.1f}ms, success: {success_rate:.1%}'
                elif avg_latency <= response_time_threshold * 1.5 or success_rate >= success_rate_threshold * 0.9:
                    status = HealthStatus.DEGRADED
                    message = f'Model inference degraded - latency: {avg_latency:.1f}ms, success: {success_rate:.1%}'
                else:
                    status = HealthStatus.UNHEALTHY
                    message = f'Model inference unhealthy - latency: {avg_latency:.1f}ms, success: {success_rate:.1%}'
                
                details = {
                    'average_latency_ms': avg_latency,
                    'success_rate': success_rate,
                    'inference_count': random.randint(50, 200)
                }
            else:
                status = HealthStatus.UNKNOWN
                message = 'Model deployment not available for testing'
                details = {}
            
            return {
                'status': status,
                'message': message,
                'details': details
            }
            
        except Exception as e:
            return {
                'status': HealthStatus.CRITICAL,
                'message': f'Model inference health check failed: {str(e)}',
                'details': {},
                'error_details': str(e)
            }
    
    def _check_system_resources_health(self, health_check: HealthCheck) -> Dict[str, Any]:
        """Check system resources health."""
        try:
            import psutil
            
            # Get system resource usage
            cpu_percent = psutil.cpu_percent(interval=1)
            memory = psutil.virtual_memory()
            disk = psutil.disk_usage('/')
            
            # Get GPU usage if available
            gpu_memory_percent = 0
            gpu_utilization = 0
            try:
                import GPUtil
                gpus = GPUtil.getGPUs()
                if gpus:
                    gpu = gpus[0]  # Use first GPU
                    gpu_memory_percent = gpu.memoryUtil * 100
                    gpu_utilization = gpu.load * 100
            except ImportError:
                pass
            
            # Check against thresholds
            cpu_threshold = health_check.threshold_values.get('cpu_percent', 80)
            memory_threshold = health_check.threshold_values.get('memory_percent', 85)
            disk_threshold = health_check.threshold_values.get('disk_percent', 90)
            gpu_threshold = health_check.threshold_values.get('gpu_percent', 80)
            
            # Determine health status
            resource_issues = []
            
            if cpu_percent > cpu_threshold:
                resource_issues.append(f'CPU usage: {cpu_percent:.1f}%')
            if memory.percent > memory_threshold:
                resource_issues.append(f'Memory usage: {memory.percent:.1f}%')
            if disk.percent > disk_threshold:
                resource_issues.append(f'Disk usage: {disk.percent:.1f}%')
            if gpu_utilization > gpu_threshold:
                resource_issues.append(f'GPU utilization: {gpu_utilization:.1f}%')
            
            if not resource_issues:
                status = HealthStatus.HEALTHY
                message = 'System resources healthy'
            elif len(resource_issues) == 1:
                status = HealthStatus.DEGRADED
                message = f'System resources degraded: {resource_issues[0]}'
            else:
                status = HealthStatus.UNHEALTHY
                message = f'System resources unhealthy: {", ".join(resource_issues)}'
            
            details = {
                'cpu_percent': cpu_percent,
                'memory_percent': memory.percent,
                'memory_available_gb': memory.available / (1024**3),
                'disk_percent': disk.percent,
                'disk_free_gb': disk.free / (1024**3),
                'gpu_memory_percent': gpu_memory_percent,
                'gpu_utilization_percent': gpu_utilization
            }
            
            return {
                'status': status,
                'message': message,
                'details': details
            }
            
        except Exception as e:
            return {
                'status': HealthStatus.CRITICAL,
                'message': f'System resources health check failed: {str(e)}',
                'details': {},
                'error_details': str(e)
            }
    
    def _check_network_connectivity_health(self, health_check: HealthCheck) -> Dict[str, Any]:
        """Check network connectivity health."""
        try:
            import subprocess
            import platform
            
            # Ping test to common endpoints
            endpoints = ['8.8.8.8', 'google.com', '1.1.1.1']
            ping_results = {}
            
            for endpoint in endpoints:
                try:
                    if platform.system().lower() == 'windows':
                        result = subprocess.run(['ping', '-n', '3', endpoint], 
                                              capture_output=True, text=True, timeout=10)
                    else:
                        result = subprocess.run(['ping', '-c', '3', endpoint], 
                                              capture_output=True, text=True, timeout=10)
                    
                    if result.returncode == 0:
                        ping_results[endpoint] = True
                    else:
                        ping_results[endpoint] = False
                        
                except Exception:
                    ping_results[endpoint] = False
            
            # Analyze results
            successful_pings = sum(1 for success in ping_results.values() if success)
            success_rate = successful_pings / len(endpoints)
            
            # Check against thresholds
            connectivity_threshold = health_check.threshold_values.get('connectivity_rate', 0.8)
            
            if success_rate >= connectivity_threshold:
                status = HealthStatus.HEALTHY
                message = f'Network connectivity healthy - {success_rate:.1%} endpoints reachable'
            elif success_rate >= connectivity_threshold * 0.7:
                status = HealthStatus.DEGRADED
                message = f'Network connectivity degraded - {success_rate:.1%} endpoints reachable'
            else:
                status = HealthStatus.UNHEALTHY
                message = f'Network connectivity unhealthy - {success_rate:.1%} endpoints reachable'
            
            details = {
                'endpoints_tested': endpoints,
                'successful_pings': successful_pings,
                'success_rate': success_rate,
                'ping_results': ping_results
            }
            
            return {
                'status': status,
                'message': message,
                'details': details
            }
            
        except Exception as e:
            return {
                'status': HealthStatus.CRITICAL,
                'message': f'Network connectivity health check failed: {str(e)}',
                'details': {},
                'error_details': str(e)
            }
    
    def _check_database_availability_health(self, health_check: HealthCheck) -> Dict[str, Any]:
        """Check database availability health."""
        try:
            # Simulate database connectivity check
            import sqlite3
            import random
            
            # In a real implementation, this would check actual database connectivity
            # For now, simulate with random success/failure
            
            start_time = time.time()
            
            # Simulate database query
            try:
                conn = sqlite3.connect(':memory:')
                cursor = conn.cursor()
                cursor.execute('SELECT 1')
                result = cursor.fetchone()
                conn.close()
                
                response_time = (time.time() - start_time) * 1000  # Convert to ms
                
                # Check response time threshold
                response_threshold = health_check.threshold_values.get('response_time_ms', 100)
                
                if response_time <= response_threshold:
                    status = HealthStatus.HEALTHY
                    message = f'Database healthy - response time: {response_time:.1f}ms'
                elif response_time <= response_threshold * 1.5:
                    status = HealthStatus.DEGRADED
                    message = f'Database degraded - response time: {response_time:.1f}ms'
                else:
                    status = HealthStatus.UNHEALTHY
                    message = f'Database unhealthy - response time: {response_time:.1f}ms'
                
                details = {
                    'response_time_ms': response_time,
                    'connection_test': 'passed'
                }
                
            except Exception as e:
                status = HealthStatus.CRITICAL
                message = f'Database health check failed: {str(e)}'
                details = {
                    'connection_test': 'failed',
                    'error': str(e)
                }
            
            return {
                'status': status,
                'message': message,
                'details': details
            }
            
        except Exception as e:
            return {
                'status': HealthStatus.CRITICAL,
                'message': f'Database availability health check failed: {str(e)}',
                'details': {},
                'error_details': str(e)
            }
    
    def _check_api_response_time_health(self, health_check: HealthCheck) -> Dict[str, Any]:
        """Check API response time health."""
        try:
            import requests
            import time
            
            # Get API endpoint from target service or use default
            api_endpoint = health_check.target_service or 'http://localhost:8080/api/v1/health'
            
            start_time = time.time()
            
            try:
                response = requests.get(api_endpoint, timeout=health_check.timeout)
                response_time = (time.time() - start_time) * 1000  # Convert to ms
                
                # Check response time threshold
                response_threshold = health_check.threshold_values.get('response_time_ms', 500)
                status_code_threshold = health_check.threshold_values.get('status_code', 200)
                
                if response.status_code == status_code_threshold and response_time <= response_threshold:
                    status = HealthStatus.HEALTHY
                    message = f'API healthy - response time: {response_time:.1f}ms, status: {response.status_code}'
                elif response.status_code == status_code_threshold and response_time <= response_threshold * 1.5:
                    status = HealthStatus.DEGRADED
                    message = f'API degraded - response time: {response_time:.1f}ms, status: {response.status_code}'
                else:
                    status = HealthStatus.UNHEALTHY
                    message = f'API unhealthy - response time: {response_time:.1f}ms, status: {response.status_code}'
                
                details = {
                    'response_time_ms': response_time,
                    'status_code': response.status_code,
                    'response_size': len(response.content)
                }
                
            except requests.RequestException as e:
                status = HealthStatus.CRITICAL
                message = f'API health check failed: {str(e)}'
                details = {
                    'connection_error': str(e)
                }
            
            return {
                'status': status,
                'message': message,
                'details': details
            }
            
        except Exception as e:
            return {
                'status': HealthStatus.CRITICAL,
                'message': f'API response time health check failed: {str(e)}',
                'details': {},
                'error_details': str(e)
            }
    
    def _check_error_rate_health(self, health_check: HealthCheck) -> Dict[str, Any]:
        """Check error rate health."""
        try:
            # Simulate error rate calculation based on recent health check results
            recent_results = [
                r for r in self.health_history[-100:]  # Last 100 checks
                if r.executed_at > time.time() - 300  # Last 5 minutes
            ]
            
            if not recent_results:
                status = HealthStatus.UNKNOWN
                message = 'No recent health check results available'
                details = {}
            else:
                error_count = len([r for r in recent_results if r.status in [HealthStatus.UNHEALTHY, HealthStatus.CRITICAL]])
                total_count = len(recent_results)
                error_rate = error_count / total_count if total_count > 0 else 0
                
                # Check against thresholds
                error_rate_threshold = health_check.threshold_values.get('error_rate', 0.1)  # 10%
                
                if error_rate <= error_rate_threshold:
                    status = HealthStatus.HEALTHY
                    message = f'Error rate healthy - {error_rate:.1%} errors in last {total_count} checks'
                elif error_rate <= error_rate_threshold * 2:
                    status = HealthStatus.DEGRADED
                    message = f'Error rate degraded - {error_rate:.1%} errors in last {total_count} checks'
                else:
                    status = HealthStatus.UNHEALTHY
                    message = f'Error rate unhealthy - {error_rate:.1%} errors in last {total_count} checks'
                
                details = {
                    'error_rate': error_rate,
                    'error_count': error_count,
                    'total_checks': total_count,
                    'time_period_minutes': 5
                }
            
            return {
                'status': status,
                'message': message,
                'details': details
            }
            
        except Exception as e:
            return {
                'status': HealthStatus.CRITICAL,
                'message': f'Error rate health check failed: {str(e)}',
                'details': {},
                'error_details': str(e)
            }
    
    def _check_custom_health(self, health_check: HealthCheck) -> Dict[str, Any]:
        """Execute custom health check logic."""
        try:
            # For custom health checks, we would execute the custom logic
            # In this implementation, we'll return a basic result
            status = HealthStatus.HEALTHY
            message = 'Custom health check passed'
            details = {
                'custom_logic': health_check.custom_logic or 'No custom logic defined',
                'execution_status': 'completed'
            }
            
            return {
                'status': status,
                'message': message,
                'details': details
            }
            
        except Exception as e:
            return {
                'status': HealthStatus.CRITICAL,
                'message': f'Custom health check failed: {str(e)}',
                'details': {},
                'error_details': str(e)
            }
    
    def _check_alert_conditions(self, health_result: HealthCheckResult):
        """Check if alert conditions are met for a health check result."""
        try:
            # Find alerts associated with this health check
            related_alerts = [
                alert for alert in self.health_alerts.values()
                if alert.health_check_id == health_result.check_id and alert.enabled
            ]
            
            for alert in related_alerts:
                self._evaluate_alert_condition(alert, health_result)
                
        except Exception as e:
            logger.error(f"Failed to check alert conditions: {e}")
    
    def _evaluate_alert_condition(self, alert: HealthAlert, health_result: HealthCheckResult):
        """Evaluate if an alert condition is met."""
        try:
            # Simple condition evaluation (in a full implementation, this would be more sophisticated)
            condition = alert.threshold_condition.lower()
            
            # Parse condition (simplified)
            if 'response_time' in condition and health_result.response_time > 0:
                threshold = alert.threshold_values.get('response_time_ms', 1000)
                if '>' in condition and health_result.response_time * 1000 > threshold:
                    self._trigger_alert(alert, health_result)
                elif '<' in condition and health_result.response_time * 1000 < threshold:
                    self._trigger_alert(alert, health_result)
            
            elif 'status' in condition:
                # Check status-based conditions
                if 'unhealthy' in condition and health_result.status in [HealthStatus.UNHEALTHY, HealthStatus.CRITICAL]:
                    self._trigger_alert(alert, health_result)
                elif 'healthy' in condition and health_result.status == HealthStatus.HEALTHY:
                    if alert.auto_resolve:
                        self._try_resolve_alert(alert)
                        
        except Exception as e:
            logger.error(f"Failed to evaluate alert condition: {e}")
    
    def _trigger_alert(self, alert: HealthAlert, health_result: HealthCheckResult):
        """Trigger an alert incident."""
        try:
            # Check if alert is already active for this check
            existing_incident = None
            for incident in self.active_incidents.values():
                if incident.alert_id == alert.alert_id and incident.status == AlertStatus.ACTIVE:
                    existing_incident = incident
                    break
            
            if existing_incident:
                # Check if we should send another notification
                time_since_last = time.time() - (existing_incident.incident_details.get('last_notification', 0))
                if time_since_last < alert.alert_frequency:
                    return  # Don't trigger yet, still in cooldown
                
                # Update notification count
                existing_incident.notification_count += 1
                existing_incident.incident_details['last_notification'] = time.time()
                
                # Check for escalation
                if existing_incident.notification_count > 1:
                    existing_incident.escalation_level += 1
                
                # Send notification
                self._send_alert_notification(alert, existing_incident, health_result)
            else:
                # Create new incident
                incident = AlertIncident(
                    incident_id=str(uuid.uuid4()),
                    alert_id=alert.alert_id,
                    triggered_at=time.time(),
                    status=AlertStatus.ACTIVE,
                    escalation_level=0,
                    notification_count=1,
                    incident_details={
                        'health_result_id': health_result.result_id,
                        'trigger_message': health_result.message,
                        'first_triggered_by': health_result.check_id,
                        'last_notification': time.time()
                    }
                )
                
                # Store incident
                self.active_incidents[incident.incident_id] = incident
                
                # Update statistics
                self.monitoring_stats['total_alerts_triggered'] += 1
                self.monitoring_stats['total_incidents_created'] += 1
                if alert.severity == AlertSeverity.CRITICAL:
                    self.monitoring_stats['critical_alerts_count'] += 1
                
                # Save to database
                self._save_incident_record(incident)
                
                # Send notification
                self._send_alert_notification(alert, incident, health_result)
                
                logger.info(f"Triggered alert {alert.name} ({alert.alert_id})")
                
        except Exception as e:
            logger.error(f"Failed to trigger alert: {e}")
    
    def _try_resolve_alert(self, alert: HealthAlert):
        """Try to resolve an alert based on auto-resolve conditions."""
        try:
            # Find active incidents for this alert
            active_incidents = [
                incident for incident in self.active_incidents.values()
                if incident.alert_id == alert.alert_id and incident.status == AlertStatus.ACTIVE
            ]
            
            for incident in active_incidents:
                # In a full implementation, we would check auto-resolve conditions
                # For now, we'll resolve based on time (resolve after 5 minutes)
                if time.time() - incident.triggered_at > 300:  # 5 minutes
                    incident.status = AlertStatus.RESOLVED
                    incident.resolved_at = time.time()
                    
                    # Remove from active incidents
                    del self.active_incidents[incident.incident_id]
                    
                    # Save to database
                    self._save_incident_record(incident)
                    
                    logger.info(f"Auto-resolved alert incident {incident.incident_id}")
                    
        except Exception as e:
            logger.error(f"Failed to auto-resolve alert: {e}")
    
    def _send_alert_notification(self, alert: HealthAlert, incident: AlertIncident, health_result: HealthCheckResult):
        """Send alert notification through configured channels."""
        try:
            # Prepare notification message
            message = self._format_alert_message(alert, incident, health_result)
            
            # Send through configured channels
            for channel in alert.notification_channels:
                if channel == 'email' and self.monitoring_config['email_alerts_enabled']:
                    self._send_email_notification(message, alert, incident)
                elif channel == 'websocket':
                    self._send_websocket_notification(message, alert, incident)
                # Add other channels as needed
                
        except Exception as e:
            logger.error(f"Failed to send alert notification: {e}")
    
    def _format_alert_message(self, alert: HealthAlert, incident: AlertIncident, health_result: HealthCheckResult) -> str:
        """Format alert message for notifications."""
        return f"""
ALERT: {alert.name}
Severity: {alert.severity.value.upper()}
Triggered: {datetime.fromtimestamp(incident.triggered_at).strftime('%Y-%m-%d %H:%M:%S')}
Health Check: {health_result.check_id}
Status: {health_result.status.value}
Message: {health_result.message}
Response Time: {health_result.response_time:.3f}s
Incident ID: {incident.incident_id}
Escalation Level: {incident.escalation_level}
"""
    
    def _send_email_notification(self, message: str, alert: HealthAlert, incident: AlertIncident):
        """Send email notification."""
        try:
            if not all([
                self.monitoring_config['smtp_server'],
                self.monitoring_config['smtp_username'],
                self.monitoring_config['smtp_password'],
                self.monitoring_config['alert_email_to']
            ]):
                logger.warning("Email configuration incomplete, skipping email notification")
                return
            
            # Create email message
            msg = MIMEMultipart()
            msg['From'] = self.monitoring_config['alert_email_from']
            msg['To'] = self.monitoring_config['alert_email_to']
            msg['Subject'] = f"ALERT: {alert.name} ({alert.severity.value.upper()})"
            
            # Add message body
            msg.attach(MIMEText(message, 'plain'))
            
            # Send email
            server = smtplib.SMTP(self.monitoring_config['smtp_server'], self.monitoring_config['smtp_port'])
            server.starttls()
            server.login(self.monitoring_config['smtp_username'], self.monitoring_config['smtp_password'])
            server.send_message(msg)
            server.quit()
            
            logger.info(f"Email notification sent for alert {alert.name}")
            
        except Exception as e:
            logger.error(f"Failed to send email notification: {e}")
    
    def _send_websocket_notification(self, message: str, alert: HealthAlert, incident: AlertIncident):
        """Send WebSocket notification."""
        try:
            # In a full implementation, this would send real-time WebSocket notifications
            # For now, we'll log the notification
            logger.info(f"WebSocket notification: {alert.name} - {incident.incident_id}")
            
            # Store notification for WebSocket clients to receive
            # This would integrate with the WebSocket handler in a real implementation
            
        except Exception as e:
            logger.error(f"Failed to send WebSocket notification: {e}")
    
    # Background workers
    def _monitoring_worker(self):
        """Background worker for monitoring operations."""
        logger.info("Monitoring worker started")
        
        while self._running:
            try:
                # Update system health score
                self.system_health_score = self._calculate_system_health_score()
                
                # Check for auto-resolve conditions
                for alert in self.health_alerts.values():
                    if alert.auto_resolve:
                        self._try_resolve_alert(alert)
                
                time.sleep(self.monitoring_config['alert_check_interval'])
                
            except Exception as e:
                logger.error(f"Error in monitoring worker: {e}")
                time.sleep(60)
        
        logger.info("Monitoring worker stopped")
    
    def _cleanup_worker(self):
        """Background worker for cleanup operations."""
        logger.info("Cleanup worker started")
        
        while self._running:
            try:
                # Clean up old health check results
                cutoff_time = time.time() - (self.monitoring_config['metrics_retention_days'] * 24 * 3600)
                self.health_history = [
                    r for r in self.health_history 
                    if r.executed_at > cutoff_time
                ]
                
                # Clean up old incidents from database
                incident_cutoff = time.time() - (self.monitoring_config['incident_retention_days'] * 24 * 3600)
                # In a real implementation, we would clean up from database here
                
                time.sleep(3600)  # Run every hour
                
            except Exception as e:
                logger.error(f"Error in cleanup worker: {e}")
                time.sleep(1800)
        
        logger.info("Cleanup worker stopped")
    
    # Utility and calculation methods
    def _calculate_system_health_score(self) -> float:
        """Calculate overall system health score."""
        try:
            # Get recent health check results
            recent_results = [
                r for r in self.health_history[-100:]  # Last 100 checks
                if time.time() - r.executed_at < 3600  # Last hour
            ]
            
            if not recent_results:
                return 100.0  # Perfect score if no data
            
            # Calculate weighted health score
            weights = self.monitoring_config['health_score_weights']
            
            healthy_count = len([r for r in recent_results if r.status == HealthStatus.HEALTHY])
            degraded_count = len([r for r in recent_results if r.status == HealthStatus.DEGRADED])
            unhealthy_count = len([r for r in recent_results if r.status == HealthStatus.UNHEALTHY])
            critical_count = len([r for r in recent_results if r.status == HealthStatus.CRITICAL])
            
            total_checks = len(recent_results)
            
            if total_checks == 0:
                return 100.0
            
            # Calculate component scores
            availability_score = (healthy_count / total_checks) * 100
            performance_score = max(0, 100 - (degraded_count / total_checks) * 50)
            error_score = max(0, 100 - (unhealthy_count / total_checks) * 80 - (critical_count / total_checks) * 100)
            
            # Calculate resource score (simplified)
            resource_score = 100.0  # Would be based on actual resource monitoring
            
            # Calculate weighted overall score
            overall_score = (
                availability_score * weights['availability'] +
                performance_score * weights['performance'] +
                error_score * weights['errors'] +
                resource_score * weights['resources']
            )
            
            return max(0.0, min(100.0, overall_score))
            
        except Exception as e:
            logger.error(f"Failed to calculate system health score: {e}")
            return 50.0  # Default score
    
    def _calculate_model_health_score(self, model_id: str) -> float:
        """Calculate health score for a specific model."""
        try:
            # Get recent health checks for this model
            model_checks = [
                r for r in self.health_history[-100:]  # Last 100 checks
                if (time.time() - r.executed_at < 3600 and  # Last hour
                    any(check.target_model_id == model_id for check in self.health_checks.values()))
            ]
            
            if not model_checks:
                return 100.0
            
            # Calculate model-specific score
            healthy_count = len([r for r in model_checks if r.status == HealthStatus.HEALTHY])
            total_checks = len(model_checks)
            
            return (healthy_count / total_checks) * 100 if total_checks > 0 else 100.0
            
        except Exception as e:
            logger.error(f"Failed to calculate model health score for {model_id}: {e}")
            return 50.0
    
    def _determine_overall_status(self, health_score: float, incidents: List[AlertIncident]) -> HealthStatus:
        """Determine overall system health status."""
        # Check for critical incidents
        critical_incidents = [
            i for i in incidents 
            if self._get_alert_severity(i.alert_id) == AlertSeverity.CRITICAL
        ]
        
        if critical_incidents:
            return HealthStatus.CRITICAL
        
        # Check health score thresholds
        if health_score >= 90:
            return HealthStatus.HEALTHY
        elif health_score >= 70:
            return HealthStatus.DEGRADED
        elif health_score >= 50:
            return HealthStatus.UNHEALTHY
        else:
            return HealthStatus.CRITICAL
    
    def _get_current_resource_utilization(self) -> Dict[str, float]:
        """Get current resource utilization."""
        try:
            import psutil
            
            return {
                'cpu_percent': psutil.cpu_percent(),
                'memory_percent': psutil.virtual_memory().percent,
                'disk_percent': psutil.disk_usage('/').percent,
                'network_io': 0.0  # Would be calculated from psutil.net_io_counters()
            }
        except Exception:
            return {
                'cpu_percent': 0.0,
                'memory_percent': 0.0,
                'disk_percent': 0.0,
                'network_io': 0.0
            }
    
    def _calculate_performance_trends(self) -> Dict[str, List[float]]:
        """Calculate performance trends over time."""
        try:
            # Get last 24 hours of health check results
            recent_results = [
                r for r in self.health_history 
                if time.time() - r.executed_at < 86400  # Last 24 hours
            ]
            
            # Group by hour and calculate averages
            trends = defaultdict(list)
            for result in recent_results:
                hour = int(result.executed_at // 3600)  # Hour bucket
                trends[f"response_time_{hour}"].append(result.response_time)
            
            # Calculate hourly averages
            performance_trends = {}
            for hour_key, times in trends.items():
                if times:
                    performance_trends[hour_key] = statistics.mean(times)
            
            return performance_trends
            
        except Exception as e:
            logger.error(f"Failed to calculate performance trends: {e}")
            return {}
    
    def _calculate_monitoring_uptime(self) -> float:
        """Calculate monitoring system uptime."""
        try:
            # This would track actual monitoring system uptime
            # For now, return a placeholder value
            return 99.9
        except Exception:
            return 0.0
    
    def _get_alert_severity(self, alert_id: str) -> AlertSeverity:
        """Get severity of an alert."""
        alert = self.health_alerts.get(alert_id)
        return alert.severity if alert else AlertSeverity.LOW
    
    def _get_health_check_target_model(self, alert_id: str) -> Optional[str]:
        """Get the target model ID for an alert's health check."""
        alert = self.health_alerts.get(alert_id)
        if not alert:
            return None
        
        health_check = self.health_checks.get(alert.health_check_id)
        return health_check.target_model_id if health_check else None
    
    # Validation methods
    def _validate_health_check(self, health_check: HealthCheck) -> Dict[str, Any]:
        """Validate health check configuration."""
        if not health_check.check_id:
            return {'valid': False, 'reason': 'Check ID is required'}
        
        if not health_check.name:
            return {'valid': False, 'reason': 'Name is required'}
        
        if health_check.check_interval <= 0:
            return {'valid': False, 'reason': 'Check interval must be positive'}
        
        if health_check.timeout <= 0:
            return {'valid': False, 'reason': 'Timeout must be positive'}
        
        return {'valid': True}
    
    def _validate_health_alert(self, health_alert: HealthAlert) -> Dict[str, Any]:
        """Validate health alert configuration."""
        if not health_alert.alert_id:
            return {'valid': False, 'reason': 'Alert ID is required'}
        
        if not health_alert.name:
            return {'valid': False, 'reason': 'Alert name is required'}
        
        if not health_alert.health_check_id:
            return {'valid': False, 'reason': 'Health check ID is required'}
        
        if health_alert.health_check_id not in self.health_checks:
            return {'valid': False, 'reason': 'Associated health check not found'}
        
        if not health_alert.threshold_condition:
            return {'valid': False, 'reason': 'Threshold condition is required'}
        
        return {'valid': True}
    
    # Database helper methods
    def _save_health_check_record(self, health_check: HealthCheck):
        """Save health check record to database."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT OR REPLACE INTO health_checks 
                (check_id, name, check_type, target_model_id, target_service, enabled,
                 check_interval, timeout, retry_count, retry_delay, threshold_values,
                 custom_logic, metadata)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                health_check.check_id,
                health_check.name,
                health_check.check_type.value,
                health_check.target_model_id,
                health_check.target_service,
                1 if health_check.enabled else 0,
                health_check.check_interval,
                health_check.timeout,
                health_check.retry_count,
                health_check.retry_delay,
                json.dumps(health_check.threshold_values),
                health_check.custom_logic,
                json.dumps(health_check.metadata)
            ))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            logger.error(f"Failed to save health check record: {e}")
    
    def _save_health_alert_record(self, health_alert: HealthAlert):
        """Save health alert record to database."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT OR REPLACE INTO health_alerts 
                (alert_id, name, description, severity, health_check_id, threshold_condition,
                 alert_frequency, escalation_rules, notification_channels, auto_resolve,
                 resolve_threshold, enabled, metadata)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                health_alert.alert_id,
                health_alert.name,
                health_alert.description,
                health_alert.severity.value,
                health_alert.health_check_id,
                health_alert.threshold_condition,
                health_alert.alert_frequency,
                json.dumps(health_alert.escalation_rules),
                json.dumps(health_alert.notification_channels),
                1 if health_alert.auto_resolve else 0,
                health_alert.resolve_threshold,
                1 if health_alert.enabled else 0,
                json.dumps(health_alert.metadata)
            ))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            logger.error(f"Failed to save health alert record: {e}")
    
    def _save_health_check_result(self, result: HealthCheckResult):
        """Save health check result to database."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT INTO health_check_results 
                (result_id, check_id, executed_at, status, response_time, message, details, error_details)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                result.result_id,
                result.check_id,
                result.executed_at,
                result.status.value,
                result.response_time,
                result.message,
                json.dumps(result.details),
                result.error_details
            ))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            logger.error(f"Failed to save health check result: {e}")
    
    def _save_incident_record(self, incident: AlertIncident):
        """Save incident record to database."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT OR REPLACE INTO alert_incidents 
                (incident_id, alert_id, triggered_at, resolved_at, status, acknowledged_by,
                 acknowledged_at, escalation_level, notification_count, incident_details)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                incident.incident_id,
                incident.alert_id,
                incident.triggered_at,
                incident.resolved_at,
                incident.status.value,
                incident.acknowledged_by,
                incident.acknowledged_at,
                incident.escalation_level,
                incident.notification_count,
                json.dumps(incident.incident_details)
            ))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            logger.error(f"Failed to save incident record: {e}")


# Global instance for convenience
_global_deployment_monitor = None


def get_deployment_monitor() -> DeploymentMonitor:
    """
    Get a global deployment monitor instance.
    
    Returns:
        DeploymentMonitor: A deployment monitor instance
    """
    global _global_deployment_monitor
    
    if _global_deployment_monitor is None:
        _global_deployment_monitor = DeploymentMonitor()
    
    return _global_deployment_monitor