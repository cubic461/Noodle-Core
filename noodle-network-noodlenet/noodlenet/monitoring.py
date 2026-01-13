"""
Noodlenet::Monitoring - monitoring.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Comprehensive monitoring system for NoodleNet distributed systems.

This module provides real-time monitoring of distributed systems including
performance metrics, health checks, and system-wide observability.
"""

import asyncio
import time
import logging
import json
import statistics
from typing import Dict, List, Optional, Set, Tuple, Any, Callable, Union
from dataclasses import dataclass, field
from enum import Enum
from collections import defaultdict, deque
import uuid
from .config import NoodleNetConfig
from .identity import NodeIdentity
from .routing import MessageRouter, RouteInfo
from .link import Message

logger = logging.getLogger(__name__)


class MetricType(Enum):
    """Types of metrics"""
    COUNTER = "counter"
    GAUGE = "gauge"
    HISTOGRAM = "histogram"
    SUMMARY = "summary"


class MetricUnit(Enum):
    """Units for metrics"""
    NONE = "none"
    BYTES = "bytes"
    SECONDS = "seconds"
    MILLISECONDS = "milliseconds"
    COUNT = "count"
    PERCENT = "percent"
    RATE = "rate"
    TEMPERATURE = "celsius"


class AlertSeverity(Enum):
    """Alert severity levels"""
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"
    CRITICAL = "critical"


class HealthStatus(Enum):
    """Health status levels"""
    HEALTHY = "healthy"
    DEGRADED = "degraded"
    UNHEALTHY = "unhealthy"
    UNKNOWN = "unknown"


@dataclass
class Metric:
    """Represents a monitoring metric"""
    
    name: str
    metric_type: MetricType
    value: Union[int, float]
    unit: MetricUnit = MetricUnit.NONE
    timestamp: float = field(default_factory=time.time)
    labels: Dict[str, str] = field(default_factory=dict)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary"""
        return {
            'name': self.name,
            'type': self.metric_type.value,
            'value': self.value,
            'unit': self.unit.value,
            'timestamp': self.timestamp,
            'labels': self.labels
        }


@dataclass
class MetricFamily:
    """A family of related metrics"""
    
    name: str
    metric_type: MetricType
    unit: MetricUnit = MetricUnit.NONE
    help_text: str = ""
    metrics: List[Metric] = field(default_factory=list)
    
    def add_metric(self, value: Union[int, float], labels: Dict[str, str] = None) -> Metric:
        """Add a metric to this family"""
        metric = Metric(
            name=self.name,
            metric_type=self.metric_type,
            value=value,
            unit=self.unit,
            labels=labels or {}
        )
        self.metrics.append(metric)
        return metric
    
    def get_metric(self, labels: Dict[str, str]) -> Optional[Metric]:
        """Get a metric by labels"""
        for metric in self.metrics:
            if metric.labels == labels:
                return metric
        return None
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary"""
        return {
            'name': self.name,
            'type': self.metric_type.value,
            'unit': self.unit.value,
            'help': self.help_text,
            'metrics': [metric.to_dict() for metric in self.metrics]
        }


@dataclass
class HealthCheck:
    """Health check definition"""
    
    name: str
    check_function: Callable
    timeout: float = 5.0
    interval: float = 30.0
    critical: bool = True
    
    # Status
    last_check: float = 0.0
    last_status: HealthStatus = HealthStatus.UNKNOWN
    last_duration: float = 0.0
    failure_count: int = 0
    max_failures: int = 3
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary"""
        return {
            'name': self.name,
            'timeout': self.timeout,
            'interval': self.interval,
            'critical': self.critical,
            'last_check': self.last_check,
            'last_status': self.last_status.value,
            'last_duration': self.last_duration,
            'failure_count': self.failure_count,
            'max_failures': self.max_failures
        }


@dataclass
class Alert:
    """Alert definition"""
    
    alert_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    name: str = ""
    severity: AlertSeverity = AlertSeverity.WARNING
    condition: str = ""
    description: str = ""
    
    # Status
    active: bool = False
    triggered_at: Optional[float] = None
    resolved_at: Optional[float] = None
    trigger_count: int = 0
    
    # Configuration
    evaluation_interval: float = 60.0
    for_duration: float = 300.0  # Alert must be active for this duration
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary"""
        return {
            'alert_id': self.alert_id,
            'name': self.name,
            'severity': self.severity.value,
            'condition': self.condition,
            'description': self.description,
            'active': self.active,
            'triggered_at': self.triggered_at,
            'resolved_at': self.resolved_at,
            'trigger_count': self.trigger_count,
            'evaluation_interval': self.evaluation_interval,
            'for_duration': self.for_duration
        }


class MetricsCollector:
    """Collects and manages metrics"""
    
    def __init__(self, config: Optional[NoodleNetConfig] = None):
        """
        Initialize metrics collector
        
        Args:
            config: NoodleNet configuration
        """
        self.config = config or NoodleNetConfig()
        
        # Metrics storage
        self._metrics: Dict[str, MetricFamily] = {}
        self._metric_history: Dict[str, deque] = defaultdict(lambda: deque(maxlen=1000))
        
        # Statistics
        self._stats = {
            'metrics_collected': 0,
            'metric_families': 0,
            'total_samples': 0
        }
    
    def create_metric_family(self, name: str, metric_type: MetricType,
                            unit: MetricUnit = MetricUnit.NONE,
                            help_text: str = "") -> MetricFamily:
        """
        Create a metric family
        
        Args:
            name: Metric name
            metric_type: Type of metric
            unit: Unit of measurement
            help_text: Help text for the metric
            
        Returns:
            Created metric family
        """
        if name in self._metrics:
            return self._metrics[name]
        
        metric_family = MetricFamily(
            name=name,
            metric_type=metric_type,
            unit=unit,
            help_text=help_text
        )
        
        self._metrics[name] = metric_family
        self._stats['metric_families'] += 1
        
        return metric_family
    
    def record_metric(self, name: str, value: Union[int, float],
                      labels: Dict[str, str] = None,
                      metric_type: MetricType = MetricType.GAUGE,
                      unit: MetricUnit = MetricUnit.NONE) -> Metric:
        """
        Record a metric value
        
        Args:
            name: Metric name
            value: Metric value
            labels: Metric labels
            metric_type: Type of metric
            unit: Unit of measurement
            
        Returns:
            Recorded metric
        """
        # Get or create metric family
        if name not in self._metrics:
            self.create_metric_family(name, metric_type, unit)
        
        metric_family = self._metrics[name]
        
        # Add metric
        metric = metric_family.add_metric(value, labels)
        
        # Store in history
        history_key = f"{name}:{json.dumps(labels or {}, sort_keys=True)}"
        self._metric_history[history_key].append(metric)
        
        # Update statistics
        self._stats['metrics_collected'] += 1
        self._stats['total_samples'] += 1
        
        return metric
    
    def increment_counter(self, name: str, value: int = 1,
                         labels: Dict[str, str] = None) -> Metric:
        """Increment a counter metric"""
        # Get existing counter value
        history_key = f"{name}:{json.dumps(labels or {}, sort_keys=True)}"
        current_value = 0
        
        if history_key in self._metric_history and self._metric_history[history_key]:
            current_value = self._metric_history[history_key][-1].value
        
        # Increment and record
        new_value = current_value + value
        return self.record_metric(name, new_value, labels, MetricType.COUNTER)
    
    def set_gauge(self, name: str, value: Union[int, float],
                   labels: Dict[str, str] = None) -> Metric:
        """Set a gauge metric value"""
        return self.record_metric(name, value, labels, MetricType.GAUGE)
    
    def record_histogram(self, name: str, value: float,
                        labels: Dict[str, str] = None,
                        buckets: List[float] = None) -> List[Metric]:
        """Record a histogram metric"""
        if buckets is None:
            buckets = [0.1, 0.5, 1.0, 2.5, 5.0, 10.0]
        
        metrics = []
        
        # Record count
        count_metric = self.increment_counter(f"{name}_count", 1, labels)
        metrics.append(count_metric)
        
        # Record sum
        sum_metric = self.increment_counter(f"{name}_sum", value, labels)
        metrics.append(sum_metric)
        
        # Record bucket counts
        for bucket in buckets:
            bucket_labels = {**(labels or {}), 'le': str(bucket)}
            self.increment_counter(f"{name}_bucket", 1, bucket_labels)
        
        # Record +Inf bucket
        inf_labels = {**(labels or {}), 'le': '+Inf'}
        self.increment_counter(f"{name}_bucket", 1, inf_labels)
        
        return metrics
    
    def record_timing(self, name: str, duration: float,
                     labels: Dict[str, str] = None) -> List[Metric]:
        """Record a timing metric (histogram with time buckets)"""
        time_buckets = [0.001, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0]
        return self.record_histogram(name, duration, labels, time_buckets)
    
    def get_metric(self, name: str, labels: Dict[str, str] = None) -> Optional[Metric]:
        """Get a specific metric"""
        if name not in self._metrics:
            return None
        
        metric_family = self._metrics[name]
        return metric_family.get_metric(labels or {})
    
    def get_metric_family(self, name: str) -> Optional[MetricFamily]:
        """Get a metric family"""
        return self._metrics.get(name)
    
    def get_all_metrics(self) -> Dict[str, MetricFamily]:
        """Get all metric families"""
        return self._metrics.copy()
    
    def get_metric_history(self, name: str, labels: Dict[str, str] = None,
                          limit: int = 100) -> List[Metric]:
        """Get metric history"""
        history_key = f"{name}:{json.dumps(labels or {}, sort_keys=True)}"
        
        if history_key not in self._metric_history:
            return []
        
        history = list(self._metric_history[history_key])
        
        # Return most recent metrics
        return history[-limit:] if limit > 0 else history
    
    def calculate_rate(self, name: str, labels: Dict[str, str] = None,
                      window_seconds: float = 60.0) -> float:
        """Calculate rate of change for a counter metric"""
        history = self.get_metric_history(name, labels, 100)
        
        if len(history) < 2:
            return 0.0
        
        # Get first and last values in window
        current_time = time.time()
        window_start = current_time - window_seconds
        
        first_value = None
        first_time = None
        last_value = None
        last_time = None
        
        for metric in history:
            if metric.timestamp >= window_start:
                if first_value is None:
                    first_value = metric.value
                    first_time = metric.timestamp
                
                last_value = metric.value
                last_time = metric.timestamp
        
        if first_value is None or last_value is None or first_time is None or last_time is None:
            return 0.0
        
        # Calculate rate
        time_diff = last_time - first_time
        if time_diff <= 0:
            return 0.0
        
        value_diff = last_value - first_value
        return value_diff / time_diff
    
    def calculate_percentile(self, name: str, percentile: float,
                           labels: Dict[str, str] = None,
                           window_seconds: float = 300.0) -> float:
        """Calculate percentile for a metric"""
        history = self.get_metric_history(name, labels, 1000)
        
        if not history:
            return 0.0
        
        # Filter by time window
        current_time = time.time()
        window_start = current_time - window_seconds
        
        values = [metric.value for metric in history if metric.timestamp >= window_start]
        
        if not values:
            return 0.0
        
        return statistics.quantiles(values, n=100)[int(percentile) - 1] if percentile < 100 else max(values)
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get collector statistics"""
        return self._stats.copy()


class HealthChecker:
    """Manages health checks"""
    
    def __init__(self, config: Optional[NoodleNetConfig] = None):
        """
        Initialize health checker
        
        Args:
            config: NoodleNet configuration
        """
        self.config = config or NoodleNetConfig()
        
        # Health checks
        self._health_checks: Dict[str, HealthCheck] = {}
        
        # Overall health status
        self._overall_status = HealthStatus.UNKNOWN
        self._last_check_time = 0.0
        
        # Background task
        self._check_task: Optional[asyncio.Task] = None
        self._running = False
        
        # Event handlers
        self._health_changed_handler: Optional[Callable] = None
    
    async def start(self):
        """Start health checker"""
        if self._running:
            return
        
        self._running = True
        self._check_task = asyncio.create_task(self._check_loop())
        
        logger.info("Health checker started")
    
    async def stop(self):
        """Stop health checker"""
        if not self._running:
            return
        
        self._running = False
        
        if self._check_task and not self._check_task.done():
            self._check_task.cancel()
            try:
                await self._check_task
            except asyncio.CancelledError:
                pass
        
        logger.info("Health checker stopped")
    
    def register_health_check(self, name: str, check_function: Callable,
                             timeout: float = 5.0, interval: float = 30.0,
                             critical: bool = True, max_failures: int = 3):
        """
        Register a health check
        
        Args:
            name: Health check name
            check_function: Function to execute for the check
            timeout: Timeout for the check
            interval: Interval between checks
            critical: Whether this check is critical for overall health
            max_failures: Maximum failures before considering unhealthy
        """
        health_check = HealthCheck(
            name=name,
            check_function=check_function,
            timeout=timeout,
            interval=interval,
            critical=critical,
            max_failures=max_failures
        )
        
        self._health_checks[name] = health_check
        logger.info(f"Registered health check: {name}")
    
    def unregister_health_check(self, name: str):
        """Unregister a health check"""
        if name in self._health_checks:
            del self._health_checks[name]
            logger.info(f"Unregistered health check: {name}")
    
    def get_health_status(self, name: str = None) -> Union[HealthStatus, Dict[str, HealthStatus]]:
        """Get health status"""
        if name:
            if name in self._health_checks:
                return self._health_checks[name].last_status
            else:
                return HealthStatus.UNKNOWN
        else:
            return {name: check.last_status for name, check in self._health_checks.items()}
    
    def get_health_checks(self) -> Dict[str, HealthCheck]:
        """Get all health checks"""
        return self._health_checks.copy()
    
    def get_overall_status(self) -> HealthStatus:
        """Get overall health status"""
        return self._overall_status
    
    def set_health_changed_handler(self, handler: Callable):
        """Set handler for health status changes"""
        self._health_changed_handler = handler
    
    async def _check_loop(self):
        """Main health check loop"""
        while self._running:
            try:
                await self._run_health_checks()
                await asyncio.sleep(10)  # Check every 10 seconds
                
            except Exception as e:
                logger.error(f"Error in health check loop: {e}")
                await asyncio.sleep(30)
    
    async def _run_health_checks(self):
        """Run all health checks"""
        current_time = time.time()
        overall_healthy = True
        overall_degraded = False
        
        for name, health_check in self._health_checks.items():
            # Check if it's time to run this check
            if current_time - health_check.last_check < health_check.interval:
                continue
            
            # Run the health check
            try:
                start_time = time.time()
                
                # Execute check with timeout
                result = await asyncio.wait_for(
                    health_check.check_function(),
                    timeout=health_check.timeout
                )
                
                duration = time.time() - start_time
                
                # Update health check status
                if result:
                    health_check.last_status = HealthStatus.HEALTHY
                    health_check.failure_count = 0
                else:
                    health_check.last_status = HealthStatus.UNHEALTHY
                    health_check.failure_count += 1
                
                health_check.last_duration = duration
                health_check.last_check = current_time
                
            except asyncio.TimeoutError:
                health_check.last_status = HealthStatus.UNHEALTHY
                health_check.failure_count += 1
                health_check.last_duration = health_check.timeout
                health_check.last_check = current_time
                
                logger.warning(f"Health check {name} timed out")
                
            except Exception as e:
                health_check.last_status = HealthStatus.UNHEALTHY
                health_check.failure_count += 1
                health_check.last_duration = time.time() - start_time
                health_check.last_check = current_time
                
                logger.error(f"Health check {name} failed: {e}")
            
            # Update overall status
            if health_check.critical:
                if health_check.failure_count >= health_check.max_failures:
                    overall_healthy = False
                elif health_check.last_status == HealthStatus.UNHEALTHY:
                    overall_degraded = True
        
        # Determine overall status
        old_status = self._overall_status
        
        if overall_healthy:
            self._overall_status = HealthStatus.HEALTHY
        elif overall_degraded:
            self._overall_status = HealthStatus.DEGRADED
        else:
            self._overall_status = HealthStatus.UNHEALTHY
        
        self._last_check_time = current_time
        
        # Call handler if status changed
        if old_status != self._overall_status and self._health_changed_handler:
            await self._health_changed_handler(self._overall_status, old_status)


class AlertManager:
    """Manages alerts based on metrics"""
    
    def __init__(self, metrics_collector: MetricsCollector,
                 config: Optional[NoodleNetConfig] = None):
        """
        Initialize alert manager
        
        Args:
            metrics_collector: Metrics collector for alert conditions
            config: NoodleNet configuration
        """
        self.metrics_collector = metrics_collector
        self.config = config or NoodleNetConfig()
        
        # Alerts
        self._alerts: Dict[str, Alert] = {}
        
        # Background task
        self._evaluation_task: Optional[asyncio.Task] = None
        self._running = False
        
        # Event handlers
        self._alert_triggered_handler: Optional[Callable] = None
        self._alert_resolved_handler: Optional[Callable] = None
    
    async def start(self):
        """Start alert manager"""
        if self._running:
            return
        
        self._running = True
        self._evaluation_task = asyncio.create_task(self._evaluation_loop())
        
        logger.info("Alert manager started")
    
    async def stop(self):
        """Stop alert manager"""
        if not self._running:
            return
        
        self._running = False
        
        if self._evaluation_task and not self._evaluation_task.done():
            self._evaluation_task.cancel()
            try:
                await self._evaluation_task
            except asyncio.CancelledError:
                pass
        
        logger.info("Alert manager stopped")
    
    def create_alert(self, name: str, condition: str, severity: AlertSeverity = AlertSeverity.WARNING,
                    description: str = "", evaluation_interval: float = 60.0,
                    for_duration: float = 300.0) -> Alert:
        """
        Create an alert
        
        Args:
            name: Alert name
            condition: Alert condition (expression)
            severity: Alert severity
            description: Alert description
            evaluation_interval: How often to evaluate the condition
            for_duration: How long condition must be true before triggering
            
        Returns:
            Created alert
        """
        alert = Alert(
            name=name,
            condition=condition,
            severity=severity,
            description=description,
            evaluation_interval=evaluation_interval,
            for_duration=for_duration
        )
        
        self._alerts[alert.alert_id] = alert
        logger.info(f"Created alert: {name}")
        
        return alert
    
    def delete_alert(self, alert_id: str) -> bool:
        """Delete an alert"""
        if alert_id in self._alerts:
            del self._alerts[alert_id]
            logger.info(f"Deleted alert: {alert_id}")
            return True
        return False
    
    def get_alert(self, alert_id: str) -> Optional[Alert]:
        """Get an alert"""
        return self._alerts.get(alert_id)
    
    def get_all_alerts(self) -> Dict[str, Alert]:
        """Get all alerts"""
        return self._alerts.copy()
    
    def get_active_alerts(self) -> Dict[str, Alert]:
        """Get active alerts"""
        return {alert_id: alert for alert_id, alert in self._alerts.items() if alert.active}
    
    def set_alert_triggered_handler(self, handler: Callable):
        """Set handler for alert triggered events"""
        self._alert_triggered_handler = handler
    
    def set_alert_resolved_handler(self, handler: Callable):
        """Set handler for alert resolved events"""
        self._alert_resolved_handler = handler
    
    async def _evaluation_loop(self):
        """Main alert evaluation loop"""
        while self._running:
            try:
                await self._evaluate_alerts()
                await asyncio.sleep(10)  # Check every 10 seconds
                
            except Exception as e:
                logger.error(f"Error in alert evaluation loop: {e}")
                await asyncio.sleep(30)
    
    async def _evaluate_alerts(self):
        """Evaluate all alerts"""
        current_time = time.time()
        
        for alert_id, alert in self._alerts.items():
            # Check if it's time to evaluate this alert
            if current_time - (alert.triggered_at or 0) < alert.evaluation_interval:
                continue
            
            # Evaluate alert condition
            try:
                condition_met = await self._evaluate_condition(alert.condition)
                
                if condition_met:
                    # Condition is met
                    if not alert.active:
                        # Alert just triggered
                        alert.active = True
                        alert.triggered_at = current_time
                        alert.trigger_count += 1
                        
                        # Check if we should trigger the alert (after for_duration)
                        if current_time - alert.triggered_at >= alert.for_duration:
                            # Call handler
                            if self._alert_triggered_handler:
                                await self._alert_triggered_handler(alert)
                            
                            logger.warning(f"Alert triggered: {alert.name} ({alert.severity.value})")
                    else:
                        # Alert is already active
                        pass
                else:
                    # Condition is not met
                    if alert.active:
                        # Alert just resolved
                        alert.active = False
                        alert.resolved_at = current_time
                        
                        # Call handler
                        if self._alert_resolved_handler:
                            await self._alert_resolved_handler(alert)
                        
                        logger.info(f"Alert resolved: {alert.name}")
                    else:
                        # Alert is already inactive
                        pass
                
            except Exception as e:
                logger.error(f"Failed to evaluate alert {alert.name}: {e}")
    
    async def _evaluate_condition(self, condition: str) -> bool:
        """Evaluate an alert condition"""
        # This is a simplified implementation
        # In a real system, this would use a proper expression evaluator
        
        # Parse simple conditions like "metric_name > value"
        try:
            if ">" in condition:
                parts = condition.split(">")
                if len(parts) == 2:
                    metric_name = parts[0].strip()
                    threshold = float(parts[1].strip())
                    
                    metric = self.metrics_collector.get_metric(metric_name)
                    if metric:
                        return metric.value > threshold
            
            elif "<" in condition:
                parts = condition.split("<")
                if len(parts) == 2:
                    metric_name = parts[0].strip()
                    threshold = float(parts[1].strip())
                    
                    metric = self.metrics_collector.get_metric(metric_name)
                    if metric:
                        return metric.value < threshold
            
            elif "==" in condition:
                parts = condition.split("==")
                if len(parts) == 2:
                    metric_name = parts[0].strip()
                    value = float(parts[1].strip())
                    
                    metric = self.metrics_collector.get_metric(metric_name)
                    if metric:
                        return metric.value == value
            
        except Exception as e:
            logger.error(f"Failed to parse condition '{condition}': {e}")
        
        return False


class DistributedMonitoringManager:
    """Comprehensive monitoring manager for distributed systems"""
    
    def __init__(self, local_node_id: str, message_router: MessageRouter,
                 config: Optional[NoodleNetConfig] = None):
        """
        Initialize distributed monitoring manager
        
        Args:
            local_node_id: ID of the local node
            message_router: Message router for communication
            config: NoodleNet configuration
        """
        self.local_node_id = local_node_id
        self.message_router = message_router
        self.config = config or NoodleNetConfig()
        
        # Components
        self.metrics_collector = MetricsCollector(config)
        self.health_checker = HealthChecker(config)
        self.alert_manager = AlertManager(self.metrics_collector, config)
        
        # Distributed monitoring
        self._remote_metrics: Dict[str, Dict[str, Any]] = {}
        self._remote_health: Dict[str, Dict[str, Any]] = {}
        self._node_last_seen: Dict[str, float] = {}
        
        # Background tasks
        self._sync_task: Optional[asyncio.Task] = None
        self._running = False
        
        # Statistics
        self._stats = {
            'metrics_collected': 0,
            'health_checks_run': 0,
            'alerts_triggered': 0,
            'alerts_resolved': 0,
            'nodes_monitored': 0,
            'last_sync': 0.0
        }
        
        # Setup default health checks and alerts
        self._setup_default_monitoring()
    
    async def start(self):
        """Start distributed monitoring manager"""
        # Start all components
        await self.health_checker.start()
        await self.alert_manager.start()
        
        # Start background tasks
        self._running = True
        self._sync_task = asyncio.create_task(self._sync_loop())
        
        logger.info("Distributed monitoring manager started")
    
    async def stop(self):
        """Stop distributed monitoring manager"""
        # Stop background tasks
        self._running = False
        
        if self._sync_task and not self._sync_task.done():
            self._sync_task.cancel()
            try:
                await self._sync_task
            except asyncio.CancelledError:
                pass
        
        # Stop all components
        await self.health_checker.stop()
        await self.alert_manager.stop()
        
        logger.info("Distributed monitoring manager stopped")
    
    async def handle_metrics_report(self, message: Message) -> Dict[str, Any]:
        """
        Handle metrics report from another node
        
        Args:
            message: Metrics report message
            
        Returns:
            Response dictionary
        """
        try:
            sender_id = message.sender_id
            metrics_data = message.payload
            
            # Store remote metrics
            self._remote_metrics[sender_id] = metrics_data
            self._node_last_seen[sender_id] = time.time()
            
            # Update statistics
            self._stats['metrics_collected'] += len(metrics_data.get('metrics', {}))
            
            return {
                'success': True,
                'message': 'Metrics received'
            }
            
        except Exception as e:
            logger.error(f"Failed to handle metrics report: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    async def handle_health_report(self, message: Message) -> Dict[str, Any]:
        """
        Handle health report from another node
        
        Args:
            message: Health report message
            
        Returns:
            Response dictionary
        """
        try:
            sender_id = message.sender_id
            health_data = message.payload
            
            # Store remote health
            self._remote_health[sender_id] = health_data
            self._node_last_seen[sender_id] = time.time()
            
            # Update statistics
            self._stats['health_checks_run'] += 1
            
            return {
                'success': True,
                'message': 'Health report received'
            }
            
        except Exception as e:
            logger.error(f"Failed to handle health report: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    def get_cluster_metrics(self) -> Dict[str, Any]:
        """Get metrics for the entire cluster"""
        cluster_metrics = {
            'local_node': self.local_node_id,
            'local_metrics': {name: family.to_dict() for name, family in self.metrics_collector.get_all_metrics().items()},
            'remote_nodes': {}
        }
        
        # Add remote metrics
        for node_id, metrics_data in self._remote_metrics.items():
            cluster_metrics['remote_nodes'][node_id] = {
                'metrics': metrics_data.get('metrics', {}),
                'last_seen': self._node_last_seen.get(node_id, 0)
            }
        
        return cluster_metrics
    
    def get_cluster_health(self) -> Dict[str, Any]:
        """Get health status for the entire cluster"""
        cluster_health = {
            'local_node': self.local_node_id,
            'local_status': self.health_checker.get_overall_status().value,
            'local_health_checks': {name: check.to_dict() for name, check in self.health_checker.get_health_checks().items()},
            'remote_nodes': {}
        }
        
        # Add remote health
        for node_id, health_data in self._remote_health.items():
            cluster_health['remote_nodes'][node_id] = {
                'status': health_data.get('overall_status', 'unknown'),
                'health_checks': health_data.get('health_checks', {}),
                'last_seen': self._node_last_seen.get(node_id, 0)
            }
        
        return cluster_health
    
    def get_cluster_alerts(self) -> Dict[str, Any]:
        """Get alerts for the entire cluster"""
        cluster_alerts = {
            'local_node': self.local_node_id,
            'local_alerts': {alert_id: alert.to_dict() for alert_id, alert in self.alert_manager.get_all_alerts().items()},
            'active_alerts': {alert_id: alert.to_dict() for alert_id, alert in self.alert_manager.get_active_alerts().items()},
            'remote_nodes': {}
        }
        
        # Add remote alerts (would be received via messages)
        for node_id in self._remote_metrics.keys():
            cluster_alerts['remote_nodes'][node_id] = {
                'alerts': {},
                'active_alerts': {},
                'last_seen': self._node_last_seen.get(node_id, 0)
            }
        
        return cluster_alerts
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get monitoring statistics"""
        stats = self._stats.copy()
        
        # Add component statistics
        stats['metrics_stats'] = self.metrics_collector.get_statistics()
        stats['health_checks_count'] = len(self.health_checker.get_health_checks())
        stats['alerts_count'] = len(self.alert_manager.get_all_alerts())
        stats['active_alerts_count'] = len(self.alert_manager.get_active_alerts())
        stats['nodes_monitored'] = len(self._node_last_seen)
        
        return stats
    
    def _setup_default_monitoring(self):
        """Setup default health checks and alerts"""
        
        # Default health checks
        async def check_memory_usage():
            import psutil
            memory = psutil.virtual_memory()
            return memory.percent < 90
        
        async def check_cpu_usage():
            import psutil
            cpu_percent = psutil.cpu_percent(interval=1)
            return cpu_percent < 90
        
        async def check_disk_usage():
            import psutil
            disk = psutil.disk_usage('/')
            return (disk.used / disk.total) < 0.9
        
        # Register health checks
        self.health_checker.register_health_check("memory_usage", check_memory_usage)
        self.health_checker.register_health_check("cpu_usage", check_cpu_usage)
        self.health_checker.register_health_check("disk_usage", check_disk_usage)
        
        # Default alerts
        self.alert_manager.create_alert(
            "high_memory_usage",
            "memory_usage_percent > 80",
            AlertSeverity.WARNING,
            "Memory usage is above 80%"
        )
        
        self.alert_manager.create_alert(
            "high_cpu_usage",
            "cpu_usage_percent > 80",
            AlertSeverity.WARNING,
            "CPU usage is above 80%"
        )
        
        self.alert_manager.create_alert(
            "high_disk_usage",
            "disk_usage_percent > 85",
            AlertSeverity.ERROR,
            "Disk usage is above 85%"
        )
    
    async def _sync_loop(self):
        """Synchronization loop for distributed monitoring"""
        while self._running:
            try:
                # Collect local metrics
                local_metrics = {
                    'node_id': self.local_node_id,
                    'timestamp': time.time(),
                    'metrics': {name: family.to_dict() for name, family in self.metrics_collector.get_all_metrics().items()}
                }
                
                # Collect local health
                local_health = {
                    'node_id': self.local_node_id,
                    'timestamp': time.time(),
                    'overall_status': self.health_checker.get_overall_status().value,
                    'health_checks': {name: check.to_dict() for name, check in self.health_checker.get_health_checks().items()}
                }
                
                # Send to other nodes (in a real implementation)
                # For now, we'll just update local statistics
                
                self._stats['last_sync'] = time.time()
                
                await asyncio.sleep(self.config.monitoring_sync_interval)
                
            except Exception as e:
                logger.error(f"Error in monitoring sync loop: {e}")
                await asyncio.sleep(30)

