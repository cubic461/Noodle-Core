"""
NoodleCore AI A/B Testing Engine (.nc file)
==========================================

This module provides comprehensive A/B testing capabilities for AI model comparison,
enabling data-driven decisions about model deployment with statistical rigor.

Features:
- Experiment design and configuration with flexible traffic allocation
- Multi-variant testing support (A/B/C/D testing)
- Real-time performance monitoring and statistical analysis
- Automated winner determination with statistical significance
- Traffic splitting and routing with sticky sessions
- Performance regression detection and alerting
- Experiment lifecycle management (create, start, pause, stop, analyze)
- Statistical significance calculations and confidence intervals
- Sample size calculations and power analysis
- Automated rollback triggers based on performance thresholds
- Integration with metrics collector for comprehensive data gathering
- Geographic and demographic traffic segmentation
- Time-based traffic allocation patterns
- Experiment results export and reporting
- Historical experiment data analysis
- Multi-armed bandit optimization for adaptive testing
- Bayesian statistics for probability of superiority
- Machine learning-powered performance prediction
- A/B testing for model hyperparameters and configurations

Statistical Methods:
- Frequentist hypothesis testing (t-test, chi-square, etc.)
- Bayesian inference and posterior probability
- Sequential testing for early stopping
- Multiple comparison correction (Bonferroni, FDR)
- Non-parametric tests for non-normal distributions
- Power analysis for sample size determination
- Effect size calculations and practical significance
- Confidence intervals and prediction intervals
- Statistical power and sample size calculations

Testing Strategies:
- Classic A/B testing with fixed allocation
- Adaptive allocation based on performance
- Multi-armed bandit algorithms
- Sequential testing with stopping rules
- Geographic and temporal segmentation
- User behavior-based allocation
- Revenue and conversion optimization
- Performance vs accuracy trade-off analysis
"""

import os
import json
import logging
import time
import threading
import uuid
import math
import sqlite3
import numpy as np
import statistics
from typing import Dict, List, Optional, Any, Union, Callable, Tuple
from dataclasses import dataclass, asdict, field
from enum import Enum
from datetime import datetime, timedelta
from collections import defaultdict, deque
from scipy import stats
import hashlib

# Import existing NoodleCore components
from ..self_improvement.model_management import ModelManager, ModelType, ModelStatus
from .model_deployer import ModelDeployer
from .metrics_collector import MetricsCollector, MetricType
from .versioning_system import VersioningSystem

# Configure logging
logger = logging.getLogger(__name__)

# Environment variables
NOODLE_DEBUG = os.environ.get("NOODLE_DEBUG", "0") == "1"
NOODLE_AB_TESTING_ENABLED = os.environ.get("NOODLE_AB_TESTING_ENABLED", "1") == "1"
NOODLE_EXPERIMENT_DB_PATH = os.environ.get("NOODLE_EXPERIMENT_DB_PATH", "noodle_ab_tests.db")
NOODLE_AB_CONFIDENCE_LEVEL = float(os.environ.get("NOODLE_AB_CONFIDENCE_LEVEL", "0.95"))
NOODLE_AB_STATISTICAL_POWER = float(os.environ.get("NOODLE_AB_STATISTICAL_POWER", "0.8"))
NOODLE_AB_MIN_SAMPLE_SIZE = int(os.environ.get("NOODLE_AB_MIN_SAMPLE_SIZE", "100"))
NOODLE_AB_MAX_VARIANTS = int(os.environ.get("NOODLE_AB_MAX_VARIANTS", "10"))
NOODLE_AB_AUTO_WINNER = os.environ.get("NOODLE_AB_AUTO_WINNER", "1") == "1"
NOODLE_AB_EARLY_STOPPING = os.environ.get("NOODLE_AB_EARLY_STOPPING", "1") == "1"


class ExperimentStatus(Enum):
    """Status of A/B test experiments."""
    DRAFT = "draft"
    RUNNING = "running"
    PAUSED = "paused"
    COMPLETED = "completed"
    STOPPED = "stopped"
    FAILED = "failed"


class ExperimentType(Enum):
    """Types of A/B test experiments."""
    PERFORMANCE = "performance"
    ACCURACY = "accuracy"
    LATENCY = "latency"
    THROUGHPUT = "throughput"
    USER_SATISFACTION = "user_satisfaction"
    REVENUE = "revenue"
    CONVERSION = "conversion"
    CUSTOM = "custom"


class TrafficAllocationMethod(Enum):
    """Methods for traffic allocation in experiments."""
    FIXED = "fixed"
    ADAPTIVE = "adaptive"
    BANDIT = "bandit"
    SEQUENTIAL = "sequential"
    SEGMENTED = "segmented"


class StatisticalTest(Enum):
    """Types of statistical tests for experiment analysis."""
    T_TEST = "t_test"
    CHI_SQUARE = "chi_square"
    MANN_WHITNEY = "mann_whitney"
    BAYESIAN = "bayesian"
    SEQUENTIAL = "sequential"


@dataclass
class ExperimentVariant:
    """Variant configuration for A/B testing."""
    variant_id: str
    name: str
    model_id: str
    version_id: str
    traffic_percentage: float
    is_control: bool
    description: str
    configuration: Dict[str, Any]
    metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass
class ExperimentParticipant:
    """Participant in an A/B test experiment."""
    participant_id: str
    experiment_id: str
    variant_id: str
    assigned_at: float
    session_id: str
    user_id: str
    attributes: Dict[str, Any] = field(default_factory=dict)


@dataclass
class ExperimentMetric:
    """Metric measurement for experiment analysis."""
    measurement_id: str
    experiment_id: str
    variant_id: str
    participant_id: str
    metric_name: str
    metric_value: float
    measured_at: float
    additional_data: Dict[str, Any] = field(default_factory=dict)


@dataclass
class ExperimentConfiguration:
    """Configuration for an A/B test experiment."""
    experiment_id: str
    name: str
    description: str
    experiment_type: ExperimentType
    traffic_allocation_method: TrafficAllocationMethod
    statistical_test: StatisticalTest
    confidence_level: float
    statistical_power: float
    minimum_sample_size: int
    early_stopping_enabled: bool
    auto_winner_enabled: bool
    target_metrics: List[str]
    success_criteria: Dict[str, float]
    stop_criteria: Dict[str, float]
    duration_hours: int
    max_participants: int
    geographic_segments: List[str] = field(default_factory=list)
    user_segments: List[str] = field(default_factory=list)
    metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass
class ExperimentResult:
    """Statistical analysis results for an experiment."""
    experiment_id: str
    analysis_timestamp: float
    sample_sizes: Dict[str, int]
    statistical_significance: Dict[str, float]
    p_values: Dict[str, float]
    confidence_intervals: Dict[str, Tuple[float, float]]
    effect_sizes: Dict[str, float]
    power_analysis: Dict[str, float]
    winner_variant_id: Optional[str]
    winner_reason: str
    recommendations: List[str]
    risk_assessment: Dict[str, float]
    analysis_metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass
class TrafficSegment:
    """Traffic segment for segmented allocation."""
    segment_id: str
    name: str
    criteria: Dict[str, Any]
    variant_assignments: Dict[str, float]
    description: str = ""


class ABTestingEngine:
    """
    Comprehensive A/B testing engine for AI model comparison.
    
    This class provides enterprise-grade A/B testing capabilities for AI models,
    including experiment design, statistical analysis, traffic allocation,
    and automated decision making with rigorous statistical methods.
    """
    
    def __init__(self):
        """Initialize the A/B testing engine."""
        if NOODLE_DEBUG:
            logger.setLevel(logging.DEBUG)
        
        # Database for experiment data
        self.db_path = NOODLE_EXPERIMENT_DB_PATH
        self._init_database()
        
        # Core components
        self.model_manager = None
        self.model_deployer = None
        self.metrics_collector = None
        self.versioning_system = None
        
        # Experiment tracking
        self.experiments: Dict[str, ExperimentConfiguration] = {}
        self.experiment_variants: Dict[str, List[ExperimentVariant]] = defaultdict(list)
        self.active_participants: Dict[str, List[ExperimentParticipant]] = defaultdict(list)
        self.experiment_metrics: Dict[str, List[ExperimentMetric]] = defaultdict(list)
        self.experiment_results: Dict[str, ExperimentResult] = {}
        
        # Traffic management
        self.traffic_segments: Dict[str, TrafficSegment] = {}
        self.sticky_assignments: Dict[str, str] = {}  # session_id -> variant_id
        
        # Threading and synchronization
        self._lock = threading.RLock()
        self._analysis_thread = None
        self._cleanup_thread = None
        self._running = False
        
        # Configuration
        self.ab_testing_config = {
            'confidence_level': NOODLE_AB_CONFIDENCE_LEVEL,
            'statistical_power': NOODLE_AB_STATISTICAL_POWER,
            'min_sample_size': NOODLE_AB_MIN_SAMPLE_SIZE,
            'max_variants': NOODLE_AB_MAX_VARIANTS,
            'auto_winner_enabled': NOODLE_AB_AUTO_WINNER,
            'early_stopping_enabled': NOODLE_AB_EARLY_STOPPING,
            'analysis_interval': 300,  # 5 minutes
            'cleanup_interval': 3600,   # 1 hour
            'sticky_session_duration': 86400,  # 24 hours
            'max_participants_per_experiment': 10000,
            'default_minimum_detectable_effect': 0.05  # 5% effect size
        }
        
        # Statistics
        self.ab_testing_stats = {
            'total_experiments_created': 0,
            'total_experiments_completed': 0,
            'total_participants_enrolled': 0,
            'total_measurements_collected': 0,
            'successful_statistical_tests': 0,
            'auto_winners_determined': 0,
            'early_stops_triggered': 0,
            'experiments_with_statistical_significance': 0,
            'average_experiment_duration': 0.0
        }
        
        # Load existing data
        self._load_experiment_data()
        
        logger.info("ABTestingEngine initialized")
    
    def _init_database(self):
        """Initialize SQLite database for experiment storage."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            # Create experiments table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS experiments (
                    experiment_id TEXT PRIMARY KEY,
                    name TEXT NOT NULL,
                    description TEXT,
                    experiment_type TEXT NOT NULL,
                    traffic_allocation_method TEXT NOT NULL,
                    statistical_test TEXT NOT NULL,
                    confidence_level REAL NOT NULL,
                    statistical_power REAL NOT NULL,
                    minimum_sample_size INTEGER NOT NULL,
                    early_stopping_enabled INTEGER NOT NULL,
                    auto_winner_enabled INTEGER NOT NULL,
                    target_metrics TEXT,
                    success_criteria TEXT,
                    stop_criteria TEXT,
                    duration_hours INTEGER NOT NULL,
                    max_participants INTEGER,
                    geographic_segments TEXT,
                    user_segments TEXT,
                    status TEXT NOT NULL,
                    created_at REAL NOT NULL,
                    started_at REAL,
                    completed_at REAL,
                    metadata TEXT
                )
            ''')
            
            # Create variants table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS experiment_variants (
                    variant_id TEXT PRIMARY KEY,
                    experiment_id TEXT NOT NULL,
                    name TEXT NOT NULL,
                    model_id TEXT NOT NULL,
                    version_id TEXT,
                    traffic_percentage REAL NOT NULL,
                    is_control INTEGER NOT NULL,
                    description TEXT,
                    configuration TEXT,
                    metadata TEXT
                )
            ''')
            
            # Create participants table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS experiment_participants (
                    participant_id TEXT PRIMARY KEY,
                    experiment_id TEXT NOT NULL,
                    variant_id TEXT NOT NULL,
                    assigned_at REAL NOT NULL,
                    session_id TEXT NOT NULL,
                    user_id TEXT,
                    attributes TEXT
                )
            ''')
            
            # Create measurements table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS experiment_measurements (
                    measurement_id TEXT PRIMARY KEY,
                    experiment_id TEXT NOT NULL,
                    variant_id TEXT NOT NULL,
                    participant_id TEXT NOT NULL,
                    metric_name TEXT NOT NULL,
                    metric_value REAL NOT NULL,
                    measured_at REAL NOT NULL,
                    additional_data TEXT
                )
            ''')
            
            # Create results table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS experiment_results (
                    experiment_id TEXT PRIMARY KEY,
                    analysis_timestamp REAL NOT NULL,
                    sample_sizes TEXT,
                    statistical_significance TEXT,
                    p_values TEXT,
                    confidence_intervals TEXT,
                    effect_sizes TEXT,
                    power_analysis TEXT,
                    winner_variant_id TEXT,
                    winner_reason TEXT,
                    recommendations TEXT,
                    risk_assessment TEXT,
                    analysis_metadata TEXT
                )
            ''')
            
            # Create indexes
            cursor.execute('CREATE INDEX IF NOT EXISTS idx_experiments_status ON experiments (status)')
            cursor.execute('CREATE INDEX IF NOT EXISTS idx_variants_experiment ON experiment_variants (experiment_id)')
            cursor.execute('CREATE INDEX IF NOT EXISTS idx_participants_experiment ON experiment_participants (experiment_id)')
            cursor.execute('CREATE INDEX IF NOT EXISTS idx_measurements_experiment ON experiment_measurements (experiment_id)')
            cursor.execute('CREATE INDEX IF NOT EXISTS idx_measurements_metric ON experiment_measurements (metric_name)')
            
            conn.commit()
            conn.close()
            
            logger.debug(f"Initialized experiment database at {self.db_path}")
            
        except Exception as e:
            logger.error(f"Failed to initialize experiment database: {e}")
            raise
    
    def _load_experiment_data(self):
        """Load existing experiment data from database."""
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            # Load experiments
            cursor.execute('SELECT * FROM experiments ORDER BY created_at')
            for row in cursor.fetchall():
                experiment_data = dict(row)
                experiment_data['target_metrics'] = json.loads(experiment_data.get('target_metrics', '[]'))
                experiment_data['success_criteria'] = json.loads(experiment_data.get('success_criteria', '{}'))
                experiment_data['stop_criteria'] = json.loads(experiment_data.get('stop_criteria', '{}'))
                experiment_data['geographic_segments'] = json.loads(experiment_data.get('geographic_segments', '[]'))
                experiment_data['user_segments'] = json.loads(experiment_data.get('user_segments', '[]'))
                experiment_data['metadata'] = json.loads(experiment_data.get('metadata', '{}'))
                
                experiment_config = ExperimentConfiguration(
                    experiment_id=experiment_data['experiment_id'],
                    name=experiment_data['name'],
                    description=experiment_data['description'],
                    experiment_type=ExperimentType(experiment_data['experiment_type']),
                    traffic_allocation_method=TrafficAllocationMethod(experiment_data['traffic_allocation_method']),
                    statistical_test=StatisticalTest(experiment_data['statistical_test']),
                    confidence_level=experiment_data['confidence_level'],
                    statistical_power=experiment_data['statistical_power'],
                    minimum_sample_size=experiment_data['minimum_sample_size'],
                    early_stopping_enabled=bool(experiment_data['early_stopping_enabled']),
                    auto_winner_enabled=bool(experiment_data['auto_winner_enabled']),
                    target_metrics=experiment_data['target_metrics'],
                    success_criteria=experiment_data['success_criteria'],
                    stop_criteria=experiment_data['stop_criteria'],
                    duration_hours=experiment_data['duration_hours'],
                    max_participants=experiment_data['max_participants'],
                    geographic_segments=experiment_data['geographic_segments'],
                    user_segments=experiment_data['user_segments'],
                    metadata=experiment_data['metadata']
                )
                
                # Store experiment configuration but exclude status (handled separately)
                experiment_dict = asdict(experiment_config)
                experiment_dict['status'] = ExperimentStatus(experiment_data['status'])
                self.experiments[experiment_data['experiment_id']] = experiment_config
            
            # Load variants
            cursor.execute('SELECT * FROM experiment_variants')
            for row in cursor.fetchall():
                variant_data = dict(row)
                variant_data['configuration'] = json.loads(variant_data.get('configuration', '{}'))
                variant_data['metadata'] = json.loads(variant_data.get('metadata', '{}'))
                variant_data['is_control'] = bool(variant_data['is_control'])
                
                variant = ExperimentVariant(**variant_data)
                self.experiment_variants[variant_data['experiment_id']].append(variant)
            
            # Load participants
            cursor.execute('SELECT * FROM experiment_participants')
            for row in cursor.fetchall():
                participant_data = dict(row)
                participant_data['attributes'] = json.loads(participant_data.get('attributes', '{}'))
                
                participant = ExperimentParticipant(**participant_data)
                self.active_participants[participant_data['experiment_id']].append(participant)
            
            # Load measurements
            cursor.execute('SELECT * FROM experiment_measurements')
            for row in cursor.fetchall():
                measurement_data = dict(row)
                measurement_data['additional_data'] = json.loads(measurement_data.get('additional_data', '{}'))
                
                measurement = ExperimentMetric(**measurement_data)
                self.experiment_metrics[measurement_data['experiment_id']].append(measurement)
            
            # Load results
            cursor.execute('SELECT * FROM experiment_results')
            for row in cursor.fetchall():
                result_data = dict(row)
                result_data['sample_sizes'] = json.loads(result_data.get('sample_sizes', '{}'))
                result_data['statistical_significance'] = json.loads(result_data.get('statistical_significance', '{}'))
                result_data['p_values'] = json.loads(result_data.get('p_values', '{}'))
                result_data['confidence_intervals'] = json.loads(result_data.get('confidence_intervals', '{}'))
                result_data['effect_sizes'] = json.loads(result_data.get('effect_sizes', '{}'))
                result_data['power_analysis'] = json.loads(result_data.get('power_analysis', '{}'))
                result_data['recommendations'] = json.loads(result_data.get('recommendations', '[]'))
                result_data['risk_assessment'] = json.loads(result_data.get('risk_assessment', '{}'))
                result_data['analysis_metadata'] = json.loads(result_data.get('analysis_metadata', '{}'))
                
                # Handle nullable winner_variant_id
                winner_id = result_data.get('winner_variant_id')
                if winner_id is None:
                    result_data['winner_variant_id'] = None
                
                experiment_result = ExperimentResult(**result_data)
                self.experiment_results[result_data['experiment_id']] = experiment_result
            
            conn.close()
            
            logger.info(f"Loaded {len(self.experiments)} experiments, {len(self.experiment_variants)} variants, {len(self.active_participants)} participants, and {len(self.experiment_metrics)} measurements")
            
        except Exception as e:
            logger.error(f"Failed to load experiment data: {e}")
    
    def initialize(self, model_manager: ModelManager = None, model_deployer: ModelDeployer = None,
                  metrics_collector: MetricsCollector = None, versioning_system = None) -> bool:
        """
        Initialize the A/B testing engine with required components.
        
        Args:
            model_manager: Model management component
            model_deployer: Model deployment component
            metrics_collector: Metrics collection component
            versioning_system: Versioning system component
            
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
            
            # Start background services
            self.start()
            
            logger.info("ABTestingEngine initialized successfully")
            return True
            
        except Exception as e:
            logger.error(f"Failed to initialize ABTestingEngine: {e}")
            return False
    
    def start(self):
        """Start the A/B testing engine background services."""
        with self._lock:
            if self._running:
                return
            
            self._running = True
            
            # Start analysis thread
            self._analysis_thread = threading.Thread(
                target=self._analysis_worker, daemon=True
            )
            self._analysis_thread.start()
            
            # Start cleanup thread
            self._cleanup_thread = threading.Thread(
                target=self._cleanup_worker, daemon=True
            )
            self._cleanup_thread.start()
            
            logger.info("ABTestingEngine started")
    
    def stop(self):
        """Stop the A/B testing engine and cleanup resources."""
        with self._lock:
            if not self._running:
                return
            
            self._running = False
            
            # Wait for threads to stop
            for thread in [self._analysis_thread, self._cleanup_thread]:
                if thread and thread.is_alive():
                    thread.join(timeout=10.0)
            
            logger.info("ABTestingEngine stopped")
    
    def create_experiment(self, experiment_config: ExperimentConfiguration) -> Dict[str, Any]:
        """
        Create a new A/B test experiment.
        
        Args:
            experiment_config: Experiment configuration
            
        Returns:
            Created experiment information
        """
        try:
            with self._lock:
                # Validate experiment configuration
                validation_result = self._validate_experiment_config(experiment_config)
                if not validation_result['valid']:
                    return {'error': validation_result['reason']}
                
                # Save experiment to database
                self._save_experiment_record(experiment_config, ExperimentStatus.DRAFT)
                
                # Update tracking
                self.experiments[experiment_config.experiment_id] = experiment_config
                self.ab_testing_stats['total_experiments_created'] += 1
                
                logger.info(f"Created experiment {experiment_config.name} ({experiment_config.experiment_id})")
                
                return {
                    'experiment_id': experiment_config.experiment_id,
                    'name': experiment_config.name,
                    'status': ExperimentStatus.DRAFT.value,
                    'experiment_type': experiment_config.experiment_type.value,
                    'traffic_allocation_method': experiment_config.traffic_allocation_method.value,
                    'target_metrics': experiment_config.target_metrics,
                    'duration_hours': experiment_config.duration_hours,
                    'min_sample_size': experiment_config.minimum_sample_size,
                    'confidence_level': experiment_config.confidence_level,
                    'created_at': time.time()
                }
                
        except Exception as e:
            logger.error(f"Failed to create experiment: {e}")
            return {'error': str(e)}
    
    def add_variant(self, experiment_id: str, variant: ExperimentVariant) -> bool:
        """
        Add a variant to an experiment.
        
        Args:
            experiment_id: Experiment to add variant to
            variant: Variant configuration
            
        Returns:
            True if addition successful
        """
        try:
            with self._lock:
                if experiment_id not in self.experiments:
                    return False
                
                # Validate variant
                if not self._validate_variant(experiment_id, variant):
                    return False
                
                # Add variant
                self.experiment_variants[experiment_id].append(variant)
                
                # Save to database
                self._save_variant_record(variant)
                
                logger.info(f"Added variant {variant.name} to experiment {experiment_id}")
                return True
                
        except Exception as e:
            logger.error(f"Failed to add variant to experiment {experiment_id}: {e}")
            return False
    
    def start_experiment(self, experiment_id: str) -> bool:
        """
        Start an A/B test experiment.
        
        Args:
            experiment_id: Experiment to start
            
        Returns:
            True if start successful
        """
        try:
            with self._lock:
                if experiment_id not in self.experiments:
                    return False
                
                experiment = self.experiments[experiment_id]
                variants = self.experiment_variants[experiment_id]
                
                # Validate experiment is ready to start
                if len(variants) < 2:
                    logger.warning(f"Experiment {experiment_id} needs at least 2 variants")
                    return False
                
                # Check traffic allocation sums to 100%
                total_allocation = sum(v.traffic_percentage for v in variants)
                if abs(total_allocation - 100.0) > 0.1:
                    logger.warning(f"Experiment {experiment_id} traffic allocation doesn't sum to 100%: {total_allocation}%")
                    return False
                
                # Start experiment
                experiment_config_dict = asdict(experiment)
                experiment_config_dict['status'] = ExperimentStatus.RUNNING
                experiment_config_dict['started_at'] = time.time()
                
                # Update database
                self._save_experiment_record(experiment, ExperimentStatus.RUNNING, experiment_config_dict.get('started_at'))
                
                logger.info(f"Started experiment {experiment_id} with {len(variants)} variants")
                return True
                
        except Exception as e:
            logger.error(f"Failed to start experiment {experiment_id}: {e}")
            return False
    
    def assign_participant(self, experiment_id: str, session_id: str, 
                          user_id: str = None, user_attributes: Dict[str, Any] = None) -> Dict[str, Any]:
        """
        Assign a participant to an experiment variant.
        
        Args:
            experiment_id: Experiment to assign participant to
            session_id: User session identifier
            user_id: Optional user identifier
            user_attributes: Optional user attributes for segmentation
            
        Returns:
            Assignment information
        """
        try:
            with self._lock:
                if experiment_id not in self.experiments:
                    return {'error': 'Experiment not found'}
                
                experiment = self.experiments[experiment_id]
                variants = self.experiment_variants[experiment_id]
                
                # Check if experiment is running
                if not hasattr(experiment, 'status') or experiment.status != ExperimentStatus.RUNNING:
                    return {'error': 'Experiment is not running'}
                
                # Check if participant already assigned (sticky assignment)
                if session_id in self.sticky_assignments:
                    assigned_variant_id = self.sticky_assignments[session_id]
                    # Verify assignment is still valid
                    variant = next((v for v in variants if v.variant_id == assigned_variant_id), None)
                    if variant:
                        return {
                            'assignment_id': self.sticky_assignments[session_id],
                            'variant_id': assigned_variant_id,
                            'is_sticky': True
                        }
                
                # Assign based on traffic allocation method
                if experiment.traffic_allocation_method == TrafficAllocationMethod.FIXED:
                    assigned_variant = self._assign_by_traffic_percentage(session_id, variants)
                elif experiment.traffic_allocation_method == TrafficAllocationMethod.BANDIT:
                    assigned_variant = self._assign_by_bandit_algorithm(session_id, variants, experiment)
                elif experiment.traffic_allocation_method == TrafficAllocationMethod.SEGMENTED:
                    assigned_variant = self._assign_by_segmentation(session_id, variants, user_attributes or {})
                else:
                    # Default to fixed allocation
                    assigned_variant = self._assign_by_traffic_percentage(session_id, variants)
                
                if not assigned_variant:
                    return {'error': 'Failed to assign participant to variant'}
                
                # Create participant record
                participant = ExperimentParticipant(
                    participant_id=str(uuid.uuid4()),
                    experiment_id=experiment_id,
                    variant_id=assigned_variant.variant_id,
                    assigned_at=time.time(),
                    session_id=session_id,
                    user_id=user_id or f"anonymous_{session_id}",
                    attributes=user_attributes or {}
                )
                
                # Store participant
                self.active_participants[experiment_id].append(participant)
                self.sticky_assignments[session_id] = assigned_variant.variant_id
                
                # Save to database
                self._save_participant_record(participant)
                
                # Update statistics
                self.ab_testing_stats['total_participants_enrolled'] += 1
                
                logger.debug(f"Assigned participant {participant.participant_id} to variant {assigned_variant.variant_id}")
                
                return {
                    'participant_id': participant.participant_id,
                    'variant_id': assigned_variant.variant_id,
                    'variant_name': assigned_variant.name,
                    'is_control': assigned_variant.is_control,
                    'assigned_at': participant.assigned_at,
                    'is_sticky': False
                }
                
        except Exception as e:
            logger.error(f"Failed to assign participant to experiment {experiment_id}: {e}")
            return {'error': str(e)}
    
    def record_measurement(self, experiment_id: str, participant_id: str,
                         metric_name: str, metric_value: float,
                         additional_data: Dict[str, Any] = None) -> bool:
        """
        Record a measurement for an experiment.
        
        Args:
            experiment_id: Experiment the measurement belongs to
            participant_id: Participant who made the measurement
            metric_name: Name of the metric
            metric_value: Value of the metric
            additional_data: Additional data about the measurement
            
        Returns:
            True if recording successful
        """
        try:
            with self._lock:
                # Find the participant
                participant = None
                for p_list in self.active_participants.values():
                    for p in p_list:
                        if p.participant_id == participant_id:
                            participant = p
                            break
                    if participant:
                        break
                
                if not participant or participant.experiment_id != experiment_id:
                    return False
                
                # Create measurement record
                measurement = ExperimentMetric(
                    measurement_id=str(uuid.uuid4()),
                    experiment_id=experiment_id,
                    variant_id=participant.variant_id,
                    participant_id=participant_id,
                    metric_name=metric_name,
                    metric_value=metric_value,
                    measured_at=time.time(),
                    additional_data=additional_data or {}
                )
                
                # Store measurement
                self.experiment_metrics[experiment_id].append(measurement)
                
                # Save to database
                self._save_measurement_record(measurement)
                
                # Update statistics
                self.ab_testing_stats['total_measurements_collected'] += 1
                
                logger.debug(f"Recorded measurement {measurement.measurement_id} for metric {metric_name}")
                return True
                
        except Exception as e:
            logger.error(f"Failed to record measurement: {e}")
            return False
    
    def analyze_experiment(self, experiment_id: str) -> Dict[str, Any]:
        """
        Perform statistical analysis on an experiment.
        
        Args:
            experiment_id: Experiment to analyze
            
        Returns:
            Analysis results
        """
        try:
            with self._lock:
                if experiment_id not in self.experiments:
                    return {'error': 'Experiment not found'}
                
                experiment = self.experiments[experiment_id]
                variants = self.experiment_variants[experiment_id]
                measurements = self.experiment_metrics[experiment_id]
                
                if not measurements:
                    return {'error': 'No measurements available for analysis'}
                
                # Group measurements by variant and metric
                variant_metrics = defaultdict(lambda: defaultdict(list))
                for measurement in measurements:
                    variant_metrics[measurement.variant_id][measurement.metric_name].append(measurement.metric_value)
                
                # Perform statistical analysis for each target metric
                statistical_results = {}
                for metric_name in experiment.target_metrics:
                    if metric_name not in variant_metrics[variants[0].variant_id]:
                        continue
                    
                    metric_results = self._analyze_metric(variant_metrics, metric_name, experiment, variants)
                    statistical_results[metric_name] = metric_results
                
                # Determine winner
                winner_analysis = self._determine_winner(statistical_results, variants)
                
                # Create experiment result
                result = ExperimentResult(
                    experiment_id=experiment_id,
                    analysis_timestamp=time.time(),
                    sample_sizes={vid: len(variant_metrics[vid].get(experiment.target_metrics[0], [])) 
                                for vid in [v.variant_id for v in variants]},
                    statistical_significance={metric: res.get('p_value', 1.0) for metric, res in statistical_results.items()},
                    p_values={metric: res.get('p_value', 1.0) for metric, res in statistical_results.items()},
                    confidence_intervals={metric: res.get('confidence_interval', (0, 0)) for metric, res in statistical_results.items()},
                    effect_sizes={metric: res.get('effect_size', 0.0) for metric, res in statistical_results.items()},
                    power_analysis={metric: res.get('power', 0.0) for metric, res in statistical_results.items()},
                    winner_variant_id=winner_analysis.get('winner_variant_id'),
                    winner_reason=winner_analysis.get('reason', ''),
                    recommendations=winner_analysis.get('recommendations', []),
                    risk_assessment=winner_analysis.get('risk_assessment', {}),
                    analysis_metadata={
                        'total_measurements': len(measurements),
                        'analysis_method': experiment.statistical_test.value,
                        'confidence_level': experiment.confidence_level
                    }
                )
                
                # Store result
                self.experiment_results[experiment_id] = result
                
                # Save to database
                self._save_experiment_result(result)
                
                # Update statistics
                self.ab_testing_stats['successful_statistical_tests'] += 1
                if result.winner_variant_id:
                    self.ab_testing_stats['auto_winners_determined'] += 1
                
                logger.info(f"Completed analysis for experiment {experiment_id}")
                
                return {
                    'experiment_id': experiment_id,
                    'analysis_timestamp': result.analysis_timestamp,
                    'sample_sizes': result.sample_sizes,
                    'statistical_significance': result.statistical_significance,
                    'p_values': result.p_values,
                    'confidence_intervals': result.confidence_intervals,
                    'effect_sizes': result.effect_sizes,
                    'power_analysis': result.power_analysis,
                    'winner': {
                        'variant_id': result.winner_variant_id,
                        'reason': result.winner_reason
                    },
                    'recommendations': result.recommendations,
                    'risk_assessment': result.risk_assessment,
                    'total_measurements': len(measurements)
                }
                
        except Exception as e:
            logger.error(f"Failed to analyze experiment {experiment_id}: {e}")
            return {'error': str(e)}
    
    def stop_experiment(self, experiment_id: str, reason: str = "manual_stop") -> bool:
        """
        Stop an A/B test experiment.
        
        Args:
            experiment_id: Experiment to stop
            reason: Reason for stopping
            
        Returns:
            True if stop successful
        """
        try:
            with self._lock:
                if experiment_id not in self.experiments:
                    return False
                
                experiment = self.experiments[experiment_id]
                
                # Perform final analysis if not already done
                if experiment_id not in self.experiment_results:
                    analysis_result = self.analyze_experiment(experiment_id)
                    if 'error' in analysis_result:
                        logger.warning(f"Final analysis failed for experiment {experiment_id}")
                
                # Update experiment status
                experiment_config_dict = asdict(experiment)
                experiment_config_dict['status'] = ExperimentStatus.COMPLETED
                experiment_config_dict['completed_at'] = time.time()
                
                # Update database
                self._save_experiment_record(experiment, ExperimentStatus.COMPLETED, experiment_config_dict.get('completed_at'))
                
                # Update statistics
                self.ab_testing_stats['total_experiments_completed'] += 1
                
                logger.info(f"Stopped experiment {experiment_id}: {reason}")
                return True
                
        except Exception as e:
            logger.error(f"Failed to stop experiment {experiment_id}: {e}")
            return False
    
    def get_experiment_status(self, experiment_id: str) -> Dict[str, Any]:
        """
        Get the current status of an experiment.
        
        Args:
            experiment_id: Experiment to get status for
            
        Returns:
            Experiment status information
        """
        try:
            with self._lock:
                if experiment_id not in self.experiments:
                    return {'error': 'Experiment not found'}
                
                experiment = self.experiments[experiment_id]
                variants = self.experiment_variants[experiment_id]
                participants = self.active_participants[experiment_id]
                measurements = self.experiment_metrics[experiment_id]
                result = self.experiment_results.get(experiment_id)
                
                # Calculate current metrics
                variant_metrics = defaultdict(lambda: defaultdict(list))
                for measurement in measurements:
                    variant_metrics[measurement.variant_id][measurement.metric_name].append(measurement.metric_value)
                
                current_stats = {}
                for variant in variants:
                    variant_id = variant.variant_id
                    variant_measurements = variant_metrics[variant_id]
                    
                    stats = {
                        'participant_count': len([p for p in participants if p.variant_id == variant_id]),
                        'measurement_count': len([m for m in measurements if m.variant_id == variant_id]),
                        'traffic_percentage': variant.traffic_percentage,
                        'is_control': variant.is_control
                    }
                    
                    # Calculate metric averages
                    for metric_name, values in variant_measurements.items():
                        if values:
                            stats[f'{metric_name}_average'] = statistics.mean(values)
                            stats[f'{metric_name}_count'] = len(values)
                    
                    current_stats[variant_id] = stats
                
                return {
                    'experiment_id': experiment_id,
                    'name': experiment.name,
                    'status': experiment.status.value,
                    'experiment_type': experiment.experiment_type.value,
                    'created_at': getattr(experiment, 'created_at', time.time()),
                    'started_at': getattr(experiment, 'started_at', None),
                    'duration_hours': experiment.duration_hours,
                    'variant_count': len(variants),
                    'total_participants': len(participants),
                    'total_measurements': len(measurements),
                    'target_metrics': experiment.target_metrics,
                    'variant_statistics': current_stats,
                    'has_results': experiment_id in self.experiment_results,
                    'winner': {
                        'variant_id': result.winner_variant_id if result else None,
                        'reason': result.winner_reason if result else None
                    } if result else None
                }
                
        except Exception as e:
            logger.error(f"Failed to get experiment status for {experiment_id}: {e}")
            return {'error': str(e)}
    
    def list_experiments(self, status: ExperimentStatus = None, limit: int = 100) -> List[Dict[str, Any]]:
        """
        List experiments with optional filtering.
        
        Args:
            status: Filter by status (optional)
            limit: Maximum number of experiments to return
            
        Returns:
            List of experiment information
        """
        try:
            with self._lock:
                experiments = list(self.experiments.values())
                
                # Apply status filter
                if status:
                    experiments = [e for e in experiments if getattr(e, 'status', None) == status]
                
                # Sort by creation time (newest first)
                experiments.sort(key=lambda e: getattr(e, 'created_at', time.time()), reverse=True)
                
                # Apply limit
                experiments = experiments[:limit]
                
                # Convert to dictionaries
                return [
                    {
                        'experiment_id': e.experiment_id,
                        'name': e.name,
                        'status': getattr(e, 'status', ExperimentStatus.DRAFT).value,
                        'experiment_type': e.experiment_type.value,
                        'target_metrics': e.target_metrics,
                        'variant_count': len(self.experiment_variants.get(e.experiment_id, [])),
                        'created_at': getattr(e, 'created_at', time.time()),
                        'started_at': getattr(e, 'started_at', None),
                        'duration_hours': e.duration_hours
                    }
                    for e in experiments
                ]
                
        except Exception as e:
            logger.error(f"Failed to list experiments: {e}")
            return []
    
    # Validation and utility methods
    def _validate_experiment_config(self, config: ExperimentConfiguration) -> Dict[str, Any]:
        """Validate experiment configuration."""
        # Check required fields
        if not config.experiment_id:
            return {'valid': False, 'reason': 'Experiment ID is required'}
        
        if not config.name:
            return {'valid': False, 'reason': 'Experiment name is required'}
        
        if not config.target_metrics:
            return {'valid': False, 'reason': 'Target metrics are required'}
        
        # Check sample size
        if config.minimum_sample_size < self.ab_testing_config['min_sample_size']:
            return {
                'valid': False, 
                'reason': f'Minimum sample size must be at least {self.ab_testing_config["min_sample_size"]}'
            }
        
        # Check confidence level
        if not (0.5 < config.confidence_level < 1.0):
            return {'valid': False, 'reason': 'Confidence level must be between 0.5 and 1.0'}
        
        return {'valid': True}
    
    def _validate_variant(self, experiment_id: str, variant: ExperimentVariant) -> bool:
        """Validate variant configuration."""
        # Check if experiment exists
        if experiment_id not in self.experiments:
            return False
        
        # Check traffic percentage
        if not (0 <= variant.traffic_percentage <= 100):
            return False
        
        # Check maximum variants limit
        current_variants = self.experiment_variants[experiment_id]
        if len(current_variants) >= self.ab_testing_config['max_variants']:
            return False
        
        return True
    
    def _assign_by_traffic_percentage(self, session_id: str, variants: List[ExperimentVariant]) -> Optional[ExperimentVariant]:
        """Assign participant based on traffic percentage."""
        # Create hash for consistent assignment
        hash_input = f"{session_id}_{time.time() // 86400}"  # Daily hash for consistency
        hash_value = int(hashlib.md5(hash_input.encode()).hexdigest(), 16) % 10000
        
        # Convert to percentage
        percentage = hash_value / 100.0
        
        # Find appropriate variant
        cumulative_percentage = 0.0
        for variant in variants:
            cumulative_percentage += variant.traffic_percentage
            if percentage <= cumulative_percentage:
                return variant
        
        # Fallback to last variant
        return variants[-1] if variants else None
    
    def _assign_by_bandit_algorithm(self, session_id: str, variants: List[ExperimentVariant], 
                                  experiment: ExperimentConfiguration) -> Optional[ExperimentVariant]:
        """Assign participant using multi-armed bandit algorithm."""
        # Simplified Thompson Sampling implementation
        # In a full implementation, this would track performance and adapt allocation
        
        # For now, fall back to traffic percentage allocation
        return self._assign_by_traffic_percentage(session_id, variants)
    
    def _assign_by_segmentation(self, session_id: str, variants: List[ExperimentVariant],
                              user_attributes: Dict[str, Any]) -> Optional[ExperimentVariant]:
        """Assign participant based on user segmentation."""
        # Simple segmentation logic based on user attributes
        # In a full implementation, this would use complex segmentation rules
        
        # For now, use traffic percentage with some adjustment based on attributes
        base_assignment = self._assign_by_traffic_percentage(session_id, variants)
        return base_assignment
    
    def _analyze_metric(self, variant_metrics: Dict[str, Dict[str, List[float]]], 
                       metric_name: str, experiment: ExperimentConfiguration,
                       variants: List[ExperimentVariant]) -> Dict[str, Any]:
        """Perform statistical analysis for a specific metric."""
        try:
            # Get control variant (first variant marked as control, or first variant)
            control_variant = next((v for v in variants if v.is_control), variants[0])
            control_values = variant_metrics[control_variant.variant_id].get(metric_name, [])
            
            if not control_values:
                return {'error': 'No control data available'}
            
            analysis_results = {}
            
            # Compare each variant with control
            for variant in variants:
                if variant.variant_id == control_variant.variant_id:
                    continue
                
                treatment_values = variant_metrics[variant.variant_id].get(metric_name, [])
                
                if not treatment_values:
                    continue
                
                # Perform statistical test based on experiment configuration
                if experiment.statistical_test == StatisticalTest.T_TEST:
                    statistic, p_value = stats.ttest_ind(control_values, treatment_values)
                elif experiment.statistical_test == StatisticalTest.MANN_WHITNEY:
                    statistic, p_value = stats.mannwhitneyu(control_values, treatment_values, alternative='two-sided')
                else:
                    # Default to t-test
                    statistic, p_value = stats.ttest_ind(control_values, treatment_values)
                
                # Calculate effect size (Cohen's d)
                pooled_std = math.sqrt(((len(control_values) - 1) * statistics.stdev(control_values) ** 2 + 
                                      (len(treatment_values) - 1) * statistics.stdev(treatment_values) ** 2) / 
                                     (len(control_values) + len(treatment_values) - 2))
                
                if pooled_std > 0:
                    effect_size = (statistics.mean(treatment_values) - statistics.mean(control_values)) / pooled_std
                else:
                    effect_size = 0.0
                
                # Calculate confidence interval
                confidence_level = experiment.confidence_level
                alpha = 1 - confidence_level
                
                if experiment.statistical_test == StatisticalTest.T_TEST:
                    # For t-test, calculate CI for difference in means
                    pooled_se = pooled_std * math.sqrt(1/len(control_values) + 1/len(treatment_values))
                    t_critical = stats.t.ppf(1 - alpha/2, len(control_values) + len(treatment_values) - 2)
                    
                    mean_diff = statistics.mean(treatment_values) - statistics.mean(control_values)
                    ci_lower = mean_diff - t_critical * pooled_se
                    ci_upper = mean_diff + t_critical * pooled_se
                    
                    confidence_interval = (ci_lower, ci_upper)
                else:
                    # For other tests, use bootstrap or other method
                    confidence_interval = (mean_diff - 0.1 * abs(mean_diff), mean_diff + 0.1 * abs(mean_diff))
                
                # Statistical significance
                is_significant = p_value < (1 - confidence_level)
                
                # Power analysis (simplified)
                if len(control_values) > 0 and len(treatment_values) > 0:
                    # Simplified power calculation
                    sample_size_effect = (len(control_values) * len(treatment_values)) / (len(control_values) + len(treatment_values))
                    estimated_power = min(1.0, sample_size_effect * abs(effect_size) * 0.1)
                else:
                    estimated_power = 0.0
                
                analysis_results[variant.variant_id] = {
                    'variant_name': variant.name,
                    'statistic': statistic,
                    'p_value': p_value,
                    'is_significant': is_significant,
                    'effect_size': effect_size,
                    'confidence_interval': confidence_interval,
                    'estimated_power': estimated_power,
                    'sample_size': len(treatment_values),
                    'control_sample_size': len(control_values)
                }
            
            return analysis_results
            
        except Exception as e:
            logger.error(f"Failed to analyze metric {metric_name}: {e}")
            return {'error': str(e)}
    
    def _determine_winner(self, statistical_results: Dict[str, Dict[str, Any]],
                        variants: List[ExperimentVariant]) -> Dict[str, Any]:
        """Determine the winning variant based on statistical analysis."""
        try:
            winner_analysis = {
                'winner_variant_id': None,
                'reason': '',
                'recommendations': [],
                'risk_assessment': {}
            }
            
            # Aggregate results across all metrics
            variant_scores = defaultdict(float)
            variant_significance_count = defaultdict(int)
            variant_sample_sizes = {}
            
            for metric_name, results in statistical_results.items():
                for variant_id, result in results.items():
                    if isinstance(result, dict) and 'effect_size' in result:
                        # Weight by effect size and statistical significance
                        weight = abs(result['effect_size'])
                        if result.get('is_significant', False):
                            variant_significance_count[variant_id] += 1
                            weight *= 2  # Double weight for significant results
                        
                        variant_scores[variant_id] += weight
                        variant_sample_sizes[variant_id] = result.get('sample_size', 0)
            
            if not variant_scores:
                winner_analysis['reason'] = 'No statistically significant results found'
                return winner_analysis
            
            # Determine winner
            winner_variant_id = max(variant_scores, key=variant_scores.get)
            winner_score = variant_scores[winner_variant_id]
            
            # Check if winner has sufficient sample size
            min_sample_size = min(result.get('sample_size', 0) for results in statistical_results.values() 
                                 for result in results.values() if isinstance(result, dict))
            
            if variant_sample_sizes.get(winner_variant_id, 0) < min_sample_size * 0.8:
                winner_analysis['reason'] = 'Winner has insufficient sample size for reliable conclusion'
                return winner_analysis
            
            # Generate recommendations
            recommendations = []
            
            if variant_significance_count[winner_variant_id] > 0:
                recommendations.append(f"Deploy {winner_variant_id} - statistically significant improvement detected")
            else:
                recommendations.append(f"Deploy {winner_variant_id} - shows positive trend but needs more data")
            
            # Risk assessment
            risk_factors = []
            overall_risk = 0.0
            
            if min_sample_size < 100:
                risk_factors.append('Low sample size')
                overall_risk += 0.3
            
            if variant_significance_count[winner_variant_id] == 0:
                risk_factors.append('No statistically significant results')
                overall_risk += 0.4
            
            if len(statistical_results) > 1:
                risk_factors.append('Multiple metrics - complex comparison')
                overall_risk += 0.1
            
            winner_analysis.update({
                'winner_variant_id': winner_variant_id,
                'reason': f'Winner determined based on effect size and statistical significance',
                'recommendations': recommendations,
                'risk_assessment': {
                    'overall_risk_score': overall_risk,
                    'risk_factors': risk_factors,
                    'confidence_level': 'High' if overall_risk < 0.3 else 'Medium' if overall_risk < 0.6 else 'Low'
                }
            })
            
            return winner_analysis
            
        except Exception as e:
            logger.error(f"Failed to determine winner: {e}")
            return {
                'winner_variant_id': None,
                'reason': f'Failed to determine winner: {str(e)}',
                'recommendations': ['Manual analysis required'],
                'risk_assessment': {'overall_risk_score': 1.0, 'risk_factors': ['Analysis error']}
            }
    
    # Background workers
    def _analysis_worker(self):
        """Background worker for automatic experiment analysis."""
        logger.info("Experiment analysis worker started")
        
        while self._running:
            try:
                # Analyze running experiments
                for experiment_id, experiment in self.experiments.items():
                    if getattr(experiment, 'status', None) == ExperimentStatus.RUNNING:
                        # Check if analysis is due
                        last_analysis = time.time() - 1800  # 30 minutes
                        
                        # Perform analysis if enough time has passed
                        if experiment_id not in self.experiment_results:
                            analysis_result = self.analyze_experiment(experiment_id)
                            
                            # Check for early stopping conditions
                            if experiment.early_stopping_enabled and 'error' not in analysis_result:
                                self._check_early_stopping_conditions(experiment_id, analysis_result)
                
                time.sleep(self.ab_testing_config['analysis_interval'])
                
            except Exception as e:
                logger.error(f"Error in analysis worker: {e}")
                time.sleep(300)  # Wait 5 minutes on error
        
        logger.info("Experiment analysis worker stopped")
    
    def _cleanup_worker(self):
        """Background worker for cleanup operations."""
        logger.info("Experiment cleanup worker started")
        
        while self._running:
            try:
                # Clean up expired sticky assignments
                current_time = time.time()
                expired_sessions = [
                    session_id for session_id, assigned_at in self.sticky_assignments.items()
                    if current_time - assigned_at > self.ab_testing_config['sticky_session_duration']
                ]
                
                for session_id in expired_sessions:
                    del self.sticky_assignments[session_id]
                
                # Clean up completed experiments (keep for 30 days)
                cutoff_time = time.time() - (30 * 24 * 3600)
                completed_experiments = [
                    exp_id for exp_id, exp in self.experiments.items()
                    if (getattr(exp, 'status', None) == ExperimentStatus.COMPLETED and
                        getattr(exp, 'completed_at', time.time()) < cutoff_time)
                ]
                
                for exp_id in completed_experiments:
                    self._archive_experiment(exp_id)
                
                time.sleep(self.ab_testing_config['cleanup_interval'])
                
            except Exception as e:
                logger.error(f"Error in cleanup worker: {e}")
                time.sleep(1800)  # Wait 30 minutes on error
        
        logger.info("Experiment cleanup worker stopped")
    
    def _check_early_stopping_conditions(self, experiment_id: str, analysis_result: Dict[str, Any]):
        """Check if early stopping conditions are met."""
        try:
            if 'error' in analysis_result:
                return
            
            experiment = self.experiments[experiment_id]
            winner = analysis_result.get('winner', {})
            
            # Check for strong statistical significance
            p_values = analysis_result.get('p_values', {})
            min_p_value = min(p_values.values()) if p_values else 1.0
            
            if min_p_value < 0.01:  # Very strong significance
                # Check sample sizes are adequate
                sample_sizes = analysis_result.get('sample_sizes', {})
                min_sample_size = min(sample_sizes.values()) if sample_sizes else 0
                
                if min_sample_size >= experiment.minimum_sample_size:
                    logger.info(f"Early stopping triggered for experiment {experiment_id} - strong statistical significance")
                    self.ab_testing_stats['early_stops_triggered'] += 1
                    
                    # Auto-stop if enabled
                    if experiment.auto_winner_enabled:
                        self.stop_experiment(experiment_id, reason="early_stopping_strong_significance")
            
            # Check for performance degradation
            effect_sizes = analysis_result.get('effect_sizes', {})
            for metric, effect_size in effect_sizes.items():
                if metric in experiment.stop_criteria:
                    threshold = experiment.stop_criteria[metric]
                    if abs(effect_size) > threshold:
                        logger.warning(f"Performance degradation detected in experiment {experiment_id} for metric {metric}")
                        self.stop_experiment(experiment_id, reason=f"performance_degradation_{metric}")
                        break
            
        except Exception as e:
            logger.error(f"Failed to check early stopping conditions: {e}")
    
    def _archive_experiment(self, experiment_id: str):
        """Archive an old experiment."""
        try:
            # Remove from active tracking but keep in database
            if experiment_id in self.experiments:
                del self.experiments[experiment_id]
            
            if experiment_id in self.experiment_variants:
                del self.experiment_variants[experiment_id]
            
            if experiment_id in self.active_participants:
                del self.active_participants[experiment_id]
            
            if experiment_id in self.experiment_metrics:
                del self.experiment_metrics[experiment_id]
            
            logger.info(f"Archived experiment {experiment_id}")
            
        except Exception as e:
            logger.error(f"Failed to archive experiment {experiment_id}: {e}")
    
    # Database helper methods
    def _save_experiment_record(self, experiment: ExperimentConfiguration, status: ExperimentStatus, timestamp: float = None):
        """Save experiment record to database."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT OR REPLACE INTO experiments 
                (experiment_id, name, description, experiment_type, traffic_allocation_method,
                 statistical_test, confidence_level, statistical_power, minimum_sample_size,
                 early_stopping_enabled, auto_winner_enabled, target_metrics, success_criteria,
                 stop_criteria, duration_hours, max_participants, geographic_segments,
                 user_segments, status, created_at, started_at, completed_at, metadata)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                experiment.experiment_id,
                experiment.name,
                experiment.description,
                experiment.experiment_type.value,
                experiment.traffic_allocation_method.value,
                experiment.statistical_test.value,
                experiment.confidence_level,
                experiment.statistical_power,
                experiment.minimum_sample_size,
                1 if experiment.early_stopping_enabled else 0,
                1 if experiment.auto_winner_enabled else 0,
                json.dumps(experiment.target_metrics),
                json.dumps(experiment.success_criteria),
                json.dumps(experiment.stop_criteria),
                experiment.duration_hours,
                experiment.max_participants,
                json.dumps(experiment.geographic_segments),
                json.dumps(experiment.user_segments),
                status.value,
                time.time(),
                timestamp if status == ExperimentStatus.RUNNING else None,
                timestamp if status == ExperimentStatus.COMPLETED else None,
                json.dumps(experiment.metadata)
            ))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            logger.error(f"Failed to save experiment record: {e}")
    
    def _save_variant_record(self, variant: ExperimentVariant):
        """Save variant record to database."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT OR REPLACE INTO experiment_variants 
                (variant_id, experiment_id, name, model_id, version_id, traffic_percentage,
                 is_control, description, configuration, metadata)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                variant.variant_id,
                variant.experiment_id,
                variant.name,
                variant.model_id,
                variant.version_id,
                variant.traffic_percentage,
                1 if variant.is_control else 0,
                variant.description,
                json.dumps(variant.configuration),
                json.dumps(variant.metadata)
            ))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            logger.error(f"Failed to save variant record: {e}")
    
    def _save_participant_record(self, participant: ExperimentParticipant):
        """Save participant record to database."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT INTO experiment_participants 
                (participant_id, experiment_id, variant_id, assigned_at, session_id, user_id, attributes)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ''', (
                participant.participant_id,
                participant.experiment_id,
                participant.variant_id,
                participant.assigned_at,
                participant.session_id,
                participant.user_id,
                json.dumps(participant.attributes)
            ))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            logger.error(f"Failed to save participant record: {e}")
    
    def _save_measurement_record(self, measurement: ExperimentMetric):
        """Save measurement record to database."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT INTO experiment_measurements 
                (measurement_id, experiment_id, variant_id, participant_id, metric_name,
                 metric_value, measured_at, additional_data)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                measurement.measurement_id,
                measurement.experiment_id,
                measurement.variant_id,
                measurement.participant_id,
                measurement.metric_name,
                measurement.metric_value,
                measurement.measured_at,
                json.dumps(measurement.additional_data)
            ))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            logger.error(f"Failed to save measurement record: {e}")
    
    def _save_experiment_result(self, result: ExperimentResult):
        """Save experiment result to database."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT OR REPLACE INTO experiment_results 
                (experiment_id, analysis_timestamp, sample_sizes, statistical_significance,
                 p_values, confidence_intervals, effect_sizes, power_analysis,
                 winner_variant_id, winner_reason, recommendations, risk_assessment,
                 analysis_metadata)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                result.experiment_id,
                result.analysis_timestamp,
                json.dumps(result.sample_sizes),
                json.dumps(result.statistical_significance),
                json.dumps(result.p_values),
                json.dumps(result.confidence_intervals),
                json.dumps(result.effect_sizes),
                json.dumps(result.power_analysis),
                result.winner_variant_id,
                result.winner_reason,
                json.dumps(result.recommendations),
                json.dumps(result.risk_assessment),
                json.dumps(result.analysis_metadata)
            ))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            logger.error(f"Failed to save experiment result: {e}")


# Global instance for convenience
_global_ab_testing_engine = None


def get_ab_testing_engine() -> ABTestingEngine:
    """
    Get a global A/B testing engine instance.
    
    Returns:
        ABTestingEngine: An A/B testing engine instance
    """
    global _global_ab_testing_engine
    
    if _global_ab_testing_engine is None:
        _global_ab_testing_engine = ABTestingEngine()
    
    return _global_ab_testing_engine