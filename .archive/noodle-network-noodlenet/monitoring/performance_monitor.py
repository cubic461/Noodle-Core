"""
Monitoring::Performance Monitor - performance_monitor.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Performance Monitoring and Metrics Collection for NoodleNet
Provides real-time monitoring, metrics collection, and performance analysis
"""

import asyncio
import time
import logging
import json
import threading
from typing import Dict, List, Optional, Set, Any, Callable, Union
from dataclasses import dataclass, field
from enum import Enum
from collections import defaultdict, deque
import psutil
import statistics
import uuid
from datetime import datetime, timedelta
from ..config import NoodleNetConfig
from ..mesh import NoodleMesh, NodeMetrics
from ..link import NoodleLink
from ..identity import NodeIdentity, NoodleIdentityManager

logger = logging.getLogger(__name__)


class MetricType(Enum):
    """Types of performance metrics"""
    CPU = "cpu"
    MEMORY = "memory"
    NETWORK = "network"
    DISK = "disk"
    RESPONSE_TIME = "response_time"
    THROUGHPUT = "throughput"
    ERROR_RATE = "error_rate"
    CACHE_HIT_RATE = "cache_hit_rate"
    LOAD_BALANCING = "load_balancing"
    SCALING = "scaling"


class AlertLevel(Enum):
    """Alert severity levels"""
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"
    CRITICAL = "critical"


@dataclass
class MetricData:
    """Represents a single metric data point"""
    timestamp: float
    metric_type: MetricType
    value: float
    node_id: Optional[str] = None
    component_id: Optional[str] = None
    model_id: Optional[str] = None
    metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass
class Alert:
    """Represents a performance alert"""
    alert_id: str
    level: AlertLevel
    message: str
    metric_type: MetricType
    current_value: float
    threshold: float
    node_id: Optional[str] = None
    component_id: Optional[str] = None
    model_id: Optional[str] = None
    timestamp: float = field(default_factory=time.time)
    resolved: bool = False
    resolved_at: Optional[float] = None


class PerformanceMonitor:
    """Main performance monitoring system"""
    
    def __init__(self, mesh: NoodleMesh, config: NoodleNetConfig):
        self.mesh = mesh
        self.config = config
        
        # Metrics storage
        self.metrics: Dict[str, deque] = defaultdict(lambda: deque(maxlen=10000))
        self.alerts: Dict[str, Alert] = {}
        self.alert_history = deque(maxlen=1000)
        
        # Monitoring configuration
        self.collection_interval = config.get('metrics_collection_interval', 5.0)
        self.alert_thresholds = {
            MetricType.CPU: config.get('cpu_alert_threshold', 90.0),
            MetricType.MEMORY: config.get('memory_alert_threshold', 95.0),
            MetricType.RESPONSE_TIME: config.get('response_time_alert_threshold', 2000.0),
            MetricType.ERROR_RATE: config.get('error_rate_alert_threshold', 0.1),
            MetricType.CACHE_HIT_RATE: config.get('cache_hit_rate_alert_threshold', 0.5)
        }
        
        # Performance analysis
        self.performance_baselines = {}
        self.anomalies = deque(maxlen=100)
        
        # Monitoring state
        self._running = False
        self._monitoring_task = None
        self._alert_task = None
        
        # Statistics
        self.stats = {
            'total_metrics_collected': 0,
            'total_alerts_generated': 0,
            'active_alerts': 0,
            'resolved_alerts': 0,
            'anomalies_detected': 0
        }
        
        logger.info("PerformanceMonitor initialized")
    
    async def start(self):
        """Start the performance monitor"""
        if self._running:
            return
        
        self._running = True
        self._monitoring_task = asyncio.create_task(self._monitoring_loop())
        self._alert_task = asyncio.create_task(self._alert_loop())
        
        logger.info("PerformanceMonitor started")
    
    async def stop(self):
        """Stop the performance monitor"""
        if not self._running:
            return
        
        self._running = False
        
        if self._monitoring_task:
            self._monitoring_task.cancel()
            try:
                await self._monitoring_task
            except asyncio.CancelledError:
                pass
        
        if self._alert_task:
            self._alert_task.cancel()
            try:
                await self._alert_task
            except asyncio.CancelledError:
                pass
        
        logger.info("PerformanceMonitor stopped")
    
    async def _monitoring_loop(self):
        """Main monitoring loop"""
        while self._running:
            try:
                # Collect metrics from all nodes
                await self._collect_node_metrics()
                
                # Collect system-wide metrics
                await self._collect_system_metrics()
                
                # Analyze performance
                await self._analyze_performance()
                
                # Wait for next collection
                await asyncio.sleep(self.collection_interval)
                
            except Exception as e:
                logger.error(f"Error in monitoring loop: {e}")
                await asyncio.sleep(1.0)
    
    async def _alert_loop(self):
        """Alert monitoring loop"""
        while self._running:
            try:
                # Check for new alerts
                await self._check_alerts()
                
                # Clean up old alerts
                await self._cleanup_alerts()
                
                # Wait for next check
                await asyncio.sleep(10.0)
                
            except Exception as e:
                logger.error(f"Error in alert loop: {e}")
                await asyncio.sleep(5.0)
    
    async def _collect_node_metrics(self):
        """Collect metrics from all nodes"""
        for node_id in self.mesh.get_all_nodes():
            try:
                # Get node metrics from mesh
                node_metrics = self.mesh.get_node_metrics(node_id)
                
                if node_metrics:
                    # Collect various metrics
                    await self._collect_cpu_metrics(node_id, node_metrics)
                    await self._collect_memory_metrics(node_id, node_metrics)
                    await self._collect_network_metrics(node_id, node_metrics)
                    await self._collect_application_metrics(node_id, node_metrics)
                
            except Exception as e:
                logger.error(f"Error collecting metrics from node {node_id}: {e}")
    
    async def _collect_system_metrics(self):
        """Collect system-wide metrics"""
        try:
            # CPU metrics
            cpu_percent = psutil.cpu_percent(interval=1)
            self._record_metric(
                MetricData(
                    timestamp=time.time(),
                    metric_type=MetricType.CPU,
                    value=cpu_percent,
                    metadata={'system_wide': True}
                )
            )
            
            # Memory metrics
            memory = psutil.virtual_memory()
            self._record_metric(
                MetricData(
                    timestamp=time.time(),
                    metric_type=MetricType.MEMORY,
                    value=memory.percent,
                    metadata={'system_wide': True, 'available_mb': memory.available / (1024*1024)}
                )
            )
            
            # Disk metrics
            disk = psutil.disk_usage('/')
            self._record_metric(
                MetricData(
                    timestamp=time.time(),
                    metric_type=MetricType.DISK,
                    value=disk.percent,
                    metadata={'system_wide': True, 'free_gb': disk.free / (1024*1024*1024)}
                )
            )
            
        except Exception as e:
            logger.error(f"Error collecting system metrics: {e}")
    
    async def _collect_cpu_metrics(self, node_id: str, node_metrics: Dict[str, Any]):
        """Collect CPU metrics for a node"""
        cpu_usage = node_metrics.get('cpu_usage', 0.0)
        
        self._record_metric(
            MetricData(
                timestamp=time.time(),
                metric_type=MetricType.CPU,
                value=cpu_usage,
                node_id=node_id,
                metadata={'cpu_cores': psutil.cpu_count()}
            )
        )
    
    async def _collect_memory_metrics(self, node_id: str, node_metrics: Dict[str, Any]):
        """Collect memory metrics for a node"""
        memory_usage = node_metrics.get('memory_usage', 0.0)
        
        self._record_metric(
            MetricData(
                timestamp=time.time(),
                metric_type=MetricType.MEMORY,
                value=memory_usage,
                node_id=node_id,
                metadata={'available_mb': node_metrics.get('available_memory', 0) / (1024*1024)}
            )
        )
    
    async def _collect_network_metrics(self, node_id: str, node_metrics: Dict[str, Any]):
        """Collect network metrics for a node"""
        # Network throughput
        bandwidth_up = node_metrics.get('bandwidth_up', 0.0)
        bandwidth_down = node_metrics.get('bandwidth_down', 0.0)
        
        self._record_metric(
            MetricData(
                timestamp=time.time(),
                metric_type=MetricType.NETWORK,
                value=bandwidth_up,
                node_id=node_id,
                metadata={'direction': 'up', 'bandwidth_mbps': bandwidth_up}
            )
        )
        
        self._record_metric(
            MetricData(
                timestamp=time.time(),
                metric_type=MetricType.NETWORK,
                value=bandwidth_down,
                node_id=node_id,
                metadata={'direction': 'down', 'bandwidth_mbps': bandwidth_down}
            )
        )
    
    async def _collect_application_metrics(self, node_id: str, node_metrics: Dict[str, Any]):
        """Collect application-specific metrics for a node"""
        # Response time
        response_time = node_metrics.get('response_time', 0.0)
        self._record_metric(
            MetricData(
                timestamp=time.time(),
                metric_type=MetricType.RESPONSE_TIME,
                value=response_time,
                node_id=node_id,
                metadata={'unit': 'ms'}
            )
        )
        
        # Error rate
        error_rate = node_metrics.get('error_rate', 0.0)
        self._record_metric(
            MetricData(
                timestamp=time.time(),
                metric_type=MetricType.ERROR_RATE,
                value=error_rate,
                node_id=node_id,
                metadata={'unit': 'percentage'}
            )
        )
    
    def _record_metric(self, metric_data: MetricData):
        """Record a metric data point"""
        metric_key = f"{metric_data.metric_type.value}_{metric_data.node_id or 'system'}"
        self.metrics[metric_key].append(metric_data)
        self.stats['total_metrics_collected'] += 1
    
    async def _analyze_performance(self):
        """Analyze collected performance data"""
        try:
            # Analyze trends
            await self._analyze_trends()
            
            # Detect anomalies
            await self._detect_anomalies()
            
            # Update baselines
            await self._update_baselines()
            
        except Exception as e:
            logger.error(f"Error analyzing performance: {e}")
    
    async def _analyze_trends(self):
        """Analyze performance trends"""
        for metric_type in MetricType:
            metric_key = f"{metric_type.value}_system"
            
            if metric_key in self.metrics and len(self.metrics[metric_key]) > 10:
                recent_metrics = list(self.metrics[metric_key])[-20:]
                values = [m.value for m in recent_metrics]
                
                # Calculate trend
                if len(values) >= 2:
                    trend = values[-1] - values[0]
                    
                    # Log significant trends
                    if abs(trend) > 10:  # 10% change
                        logger.info(f"Significant {metric_type.value} trend detected: {trend:.2f}")
    
    async def _detect_anomalies(self):
        """Detect performance anomalies"""
        for metric_type in MetricType:
            metric_key = f"{metric_type.value}_system"
            
            if metric_key in self.metrics and len(self.metrics[metric_key]) > 20:
                recent_metrics = list(self.metrics[metric_key])[-50:]
                values = [m.value for m in recent_metrics]
                
                # Simple anomaly detection using standard deviation
                if len(values) >= 10:
                    mean = statistics.mean(values)
                    stdev = statistics.stdev(values)
                    
                    if stdev > 0:
                        # Check for values that are more than 2 standard deviations from mean
                        for metric_data in recent_metrics[-10:]:
                            z_score = abs(metric_data.value - mean) / stdev
                            if z_score > 2.0:
                                anomaly = {
                                    'timestamp': metric_data.timestamp,
                                    'metric_type': metric_type,
                                    'value': metric_data.value,
                                    'z_score': z_score,
                                    'mean': mean,
                                    'stdev': stdev
                                }
                                self.anomalies.append(anomaly)
                                self.stats['anomalies_detected'] += 1
                                
                                logger.warning(f"Anomaly detected in {metric_type.value}: "
                                             f"value={metric_data.value:.2f}, "
                                             f"z_score={z_score:.2f}")
    
    async def _update_baselines(self):
        """Update performance baselines"""
        for metric_type in MetricType:
            metric_key = f"{metric_type.value}_system"
            
            if metric_key in self.metrics and len(self.metrics[metric_key]) > 100:
                recent_metrics = list(self.metrics[metric_key])[-100:]
                values = [m.value for m in recent_metrics]
                
                # Calculate baseline statistics
                baseline = {
                    'mean': statistics.mean(values),
                    'median': statistics.median(values),
                    'stdev': statistics.stdev(values) if len(values) > 1 else 0,
                    'min': min(values),
                    'max': max(values),
                    'percentile_95': statistics.quantiles(values, n=20)[18] if len(values) >= 20 else max(values),
                    'last_updated': time.time()
                }
                
                self.performance_baselines[metric_type] = baseline
    
    async def _check_alerts(self):
        """Check for alert conditions"""
        for metric_type, threshold in self.alert_thresholds.items():
            metric_key = f"{metric_type.value}_system"
            
            if metric_key in self.metrics and self.metrics[metric_key]:
                latest_metric = self.metrics[metric_key][-1]
                
                # Check if threshold is exceeded
                if latest_metric.value > threshold:
                    await self._create_alert(
                        metric_type=metric_type,
                        current_value=latest_metric.value,
                        threshold=threshold,
                        node_id=latest_metric.node_id,
                        message=f"{metric_type.value} threshold exceeded: {latest_metric.value:.2f} > {threshold}"
                    )
    
    async def _create_alert(self, metric_type: MetricType, current_value: float, 
                          threshold: float, node_id: Optional[str] = None, 
                          message: str = ""):
        """Create a performance alert"""
        alert_id = str(uuid.uuid4())
        
        # Determine alert level based on severity
        severity_ratio = current_value / threshold
        if severity_ratio > 2.0:
            level = AlertLevel.CRITICAL
        elif severity_ratio > 1.5:
            level = AlertLevel.ERROR
        elif severity_ratio > 1.2:
            level = AlertLevel.WARNING
        else:
            level = AlertLevel.INFO
        
        alert = Alert(
            alert_id=alert_id,
            level=level,
            message=message or f"{metric_type.value} performance alert",
            metric_type=metric_type,
            current_value=current_value,
            threshold=threshold,
            node_id=node_id,
            timestamp=time.time()
        )
        
        self.alerts[alert_id] = alert
        self.alert_history.append(alert)
        self.stats['total_alerts_generated'] += 1
        self.stats['active_alerts'] += 1
        
        logger.warning(f"Alert created: {alert.message}")
    
    async def _cleanup_alerts(self):
        """Clean up old resolved alerts"""
        current_time = time.time()
        cutoff_time = current_time - 86400  # 24 hours
        
        resolved_alerts = []
        for alert_id, alert in self.alerts.items():
            if (alert.resolved and 
                alert.resolved_at and 
                alert.resolved_at < cutoff_time):
                resolved_alerts.append(alert_id)
        
        for alert_id in resolved_alerts:
            del self.alerts[alert_id]
            self.stats['active_alerts'] -= 1
    
    def resolve_alert(self, alert_id: str):
        """Resolve an alert"""
        if alert_id in self.alerts:
            alert = self.alerts[alert_id]
            alert.resolved = True
            alert.resolved_at = time.time()
            self.stats['active_alerts'] -= 1
            self.stats['resolved_alerts'] += 1
            
            logger.info(f"Alert resolved: {alert.message}")
    
    def get_metrics_summary(self, metric_type: MetricType, 
                          time_range: Optional[float] = None) -> Dict[str, Any]:
        """Get metrics summary for a specific metric type"""
        metric_key = f"{metric_type.value}_system"
        
        if metric_key not in self.metrics:
            return {}
        
        metrics = list(self.metrics[metric_key])
        
        # Filter by time range if specified
        if time_range:
            cutoff_time = time.time() - time_range
            metrics = [m for m in metrics if m.timestamp >= cutoff_time]
        
        if not metrics:
            return {}
        
        values = [m.value for m in metrics]
        
        return {
            'metric_type': metric_type.value,
            'count': len(metrics),
            'latest_value': values[-1],
            'min_value': min(values),
            'max_value': max(values),
            'mean_value': statistics.mean(values),
            'median_value': statistics.median(values),
            'stdev_value': statistics.stdev(values) if len(values) > 1 else 0,
            'time_range': time_range,
            'first_timestamp': metrics[0].timestamp,
            'last_timestamp': metrics[-1].timestamp
        }
    
    def get_alerts_summary(self) -> Dict[str, Any]:
        """Get alerts summary"""
        active_alerts = [alert for alert in self.alerts.values() if not alert.resolved]
        
        alerts_by_level = defaultdict(int)
        for alert in active_alerts:
            alerts_by_level[alert.level.value] += 1
        
        return {
            'total_alerts': len(self.alerts),
            'active_alerts': len(active_alerts),
            'resolved_alerts': self.stats['resolved_alerts'],
            'alerts_by_level': dict(alerts_by_level),
            'recent_alerts': list(self.alert_history)[-10:]
        }
    
    def get_performance_report(self) -> Dict[str, Any]:
        """Generate comprehensive performance report"""
        report = {
            'timestamp': time.time(),
            'system_metrics': {},
            'alerts': self.get_alerts_summary(),
            'anomalies': list(self.anomalies)[-10:],
            'baselines': self.performance_baselines,
            'statistics': self.stats.copy()
        }
        
        # Get metrics summary for all metric types
        for metric_type in MetricType:
            summary = self.get_metrics_summary(metric_type, time_range=3600)  # Last hour
            if summary:
                report['system_metrics'][metric_type.value] = summary
        
        return report
    
    def is_monitoring_active(self) -> bool:
        """Check if monitoring is active"""
        return self._running

