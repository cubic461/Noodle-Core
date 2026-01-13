# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Real-time Monitoring Dashboard for NoodleCore Self-Improvement System

# This module implements a comprehensive real-time monitoring dashboard with
# performance trend analysis, anomaly detection, and visualization capabilities.
# """

import os
import json
import logging
import time
import threading
import typing
import typing.Any,
import dataclasses.dataclass,
import enum.Enum
import statistics
import math
import collections.deque,
import uuid

# Configure logging
logger = logging.getLogger(__name__)

# Environment variables
NOODLE_DEBUG = os.environ.get("NOODLE_DEBUG", "0") == "1"
NOODLE_DASHBOARD_ENABLED = os.environ.get("NOODLE_DASHBOARD_ENABLED", "1") == "1"
NOODLE_DASHBOARD_HOST = os.environ.get("NOODLE_DASHBOARD_HOST", "0.0.0.0")
NOODLE_DASHBOARD_PORT = int(os.environ.get("NOODLE_DASHBOARD_PORT", "8081"))
NOODLE_ANOMALY_DETECTION = os.environ.get("NOODLE_ANOMALY_DETECTION", "1") == "1"

# Import self-improvement components
import .self_improvement_manager.SelfImprovementManager
import .ai_decision_engine.AIDecisionEngine
import .performance_monitoring.PerformanceMonitoringSystem

# Import monitoring components
import ..monitoring.performance_monitor.PerformanceMonitor,


class MetricType(Enum)
    #     """Types of metrics tracked by dashboard."""
    SYSTEM_HEALTH = "system_health"
    PERFORMANCE = "performance"
    AI_DECISIONS = "ai_decisions"
    OPTIMIZATIONS = "optimizations"
    ERRORS = "errors"
    RESOURCE_USAGE = "resource_usage"
    TRENDS = "trends"
    ANOMALIES = "anomalies"


class AnomalyType(Enum)
    #     """Types of anomalies detected."""
    PERFORMANCE_DEGRADATION = "performance_degradation"
    ERROR_SPIKE = "error_spike"
    RESOURCE_EXHAUSTION = "resource_exhaustion"
    MODEL_REGRESSION = "model_regression"
    UNUSUAL_PATTERN = "unusual_pattern"


# @dataclass
class MetricDataPoint
    #     """A single data point in a time series."""
    #     timestamp: float
    #     value: float
    tags: Dict[str, str] = None

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary."""
    #         return {
    #             'timestamp': self.timestamp,
    #             'value': self.value,
    #             'tags': self.tags or {}
    #         }


# @dataclass
class AnomalyDetection
    #     """An anomaly detected by the system."""
    #     anomaly_id: str
    #     anomaly_type: AnomalyType
    #     metric_name: str
    #     severity: str
    #     confidence: float
    #     description: str
    #     detected_at: float
    #     data_points: List[MetricDataPoint]
    resolved: bool = False
    resolved_at: Optional[float] = None

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary."""
    #         return {
    #             'anomaly_id': self.anomaly_id,
    #             'anomaly_type': self.anomaly_type.value,
    #             'metric_name': self.metric_name,
    #             'severity': self.severity,
    #             'confidence': self.confidence,
    #             'description': self.description,
    #             'detected_at': self.detected_at,
    #             'data_points': [dp.to_dict() for dp in self.data_points],
    #             'resolved': self.resolved,
    #             'resolved_at': self.resolved_at
    #         }


# @dataclass
class TrendAnalysis
    #     """Analysis of metric trends."""
    #     metric_name: str
    #     trend_direction: str  # "increasing", "decreasing", "stable"
    #     trend_strength: float  # 0-1, higher is stronger
    #     slope: float
    #     correlation: float
    prediction: Optional[float] = None
    confidence: float = 0.0

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary."""
    #         return {
    #             'metric_name': self.metric_name,
    #             'trend_direction': self.trend_direction,
    #             'trend_strength': self.trend_strength,
    #             'slope': self.slope,
    #             'correlation': self.correlation,
    #             'prediction': self.prediction,
    #             'confidence': self.confidence
    #         }


class MonitoringDashboard
    #     """
    #     Real-time monitoring dashboard for self-improvement system.

    #     This class provides comprehensive monitoring with real-time updates,
    #     trend analysis, anomaly detection, and visualization data.
    #     """

    #     def __init__(self,
    #                  self_improvement_manager: SelfImprovementManager,
    #                  ai_decision_engine: AIDecisionEngine,
    #                  performance_monitor: PerformanceMonitoringSystem):
    #         """Initialize monitoring dashboard."""
    #         if NOODLE_DEBUG:
                logger.setLevel(logging.DEBUG)

    self.self_improvement_manager = self_improvement_manager
    self.ai_decision_engine = ai_decision_engine
    self.performance_monitor = performance_monitor

    #         # Data storage
    self.metrics_data: Dict[str, deque] = defaultdict(lambda: deque(maxlen=1000))
    self.anomalies: List[AnomalyDetection] = []
    self.trends: Dict[str, TrendAnalysis] = {}

    #         # Dashboard state
    self.dashboard_active = False
    self.last_update = 0.0
    self.update_interval = 5.0  # seconds

    #         # Anomaly detection configuration
    self.anomaly_config = {
    #             'enabled': NOODLE_ANOMALY_DETECTION,
    #             'window_size': 20,  # data points
    #             'z_score_threshold': 2.5,  # standard deviations
    #             'min_data_points': 10,
    #             'trend_change_threshold': 0.3,  # correlation change
    #             'error_spike_threshold': 3.0,  # multiplier over baseline
    #             'performance_degradation_threshold': 0.2  # 20% degradation
    #         }

    #         # Threading
    self._lock = threading.RLock()
    self._update_thread = None
    self._anomaly_thread = None
    self._trend_thread = None
    self._running = False

    #         # Statistics
    self.dashboard_stats = {
    #             'total_data_points': 0,
    #             'total_anomalies': 0,
    #             'active_anomalies': 0,
    #             'total_trends': 0,
    #             'last_analysis_time': 0.0,
    #             'update_rate': 0.0
    #         }

            logger.info("Monitoring dashboard initialized")

    #     def start(self) -> bool:
    #         """Start the monitoring dashboard."""
    #         with self._lock:
    #             if self.dashboard_active:
                    logger.warning("Dashboard already active")
    #                 return True

    #             if not NOODLE_DASHBOARD_ENABLED:
                    logger.info("Dashboard disabled by configuration")
    #                 return False

    self.dashboard_active = True
    self._running = True

    #             # Start background threads
    self._update_thread = threading.Thread(target=self._update_worker, daemon=True)
                self._update_thread.start()

    self._anomaly_thread = threading.Thread(target=self._anomaly_worker, daemon=True)
                self._anomaly_thread.start()

    self._trend_thread = threading.Thread(target=self._trend_worker, daemon=True)
                self._trend_thread.start()

                logger.info(f"Monitoring dashboard started on {NOODLE_DASHBOARD_HOST}:{NOODLE_DASHBOARD_PORT}")
    #             return True

    #     def stop(self) -> bool:
    #         """Stop the monitoring dashboard."""
    #         with self._lock:
    #             if not self.dashboard_active:
    #                 return True

    self.dashboard_active = False
    self._running = False

    #             # Wait for threads to stop
    #             for thread in [self._update_thread, self._anomaly_thread, self._trend_thread]:
    #                 if thread and thread.is_alive():
    thread.join(timeout = 5.0)

                logger.info("Monitoring dashboard stopped")
    #             return True

    #     def _update_worker(self):
    #         """Background worker for updating dashboard data."""
            logger.info("Dashboard update worker started")

    #         while self._running:
    #             try:
    update_start = time.time()

    #                 # Collect metrics from all sources
                    self._collect_metrics()

    #                 # Update statistics
    self.dashboard_stats['last_analysis_time'] = time.time()
    #                 self.dashboard_stats['update_rate'] = 1.0 / (time.time() - self.last_update) if self.last_update > 0 else 0.0
    self.last_update = update_start

    #                 # Sleep until next update
    sleep_time = math.subtract(max(0, self.update_interval, (time.time() - update_start)))
                    time.sleep(sleep_time)

    #             except Exception as e:
                    logger.error(f"Error in dashboard update worker: {e}")
                    time.sleep(5.0)

            logger.info("Dashboard update worker stopped")

    #     def _collect_metrics(self):
    #         """Collect metrics from all sources."""
    #         try:
    #             # Collect self-improvement system metrics
    si_status = self.self_improvement_manager.get_system_status()
                self._add_metric_data_point("system_health", si_status.get('uptime', 0.0))
                self._add_metric_data_point("total_optimizations", si_status.get('metrics', {}).get('total_optimizations', 0.0))
                self._add_metric_data_point("successful_optimizations", si_status.get('metrics', {}).get('successful_optimizations', 0.0))
                self._add_metric_data_point("failed_optimizations", si_status.get('metrics', {}).get('failed_optimizations', 0.0))
                self._add_metric_data_point("performance_improvements", si_status.get('metrics', {}).get('performance_improvements', 0.0))
                self._add_metric_data_point("rollbacks_triggered", si_status.get('metrics', {}).get('rollbacks_triggered', 0.0))

    #             # Collect AI decision engine metrics
    #             if self.ai_decision_engine:
    ai_stats = self.ai_decision_engine.get_engine_statistics()
                    self._add_metric_data_point("ai_decisions", ai_stats.get('total_decisions', 0.0))
                    self._add_metric_data_point("ai_confidence", ai_stats.get('average_confidence', 0.0) * 100.0)
                    self._add_metric_data_point("high_confidence_decisions", ai_stats.get('high_confidence_decisions', 0.0))

    #             # Collect performance monitoring metrics
    #             if self.performance_monitor:
    pm_stats = self.performance_monitor.get_statistics()
                    self._add_metric_data_point("metrics_collection_rate", pm_stats.get('metrics_collection_rate', 0.0))
                    self._add_metric_data_point("total_alerts", pm_stats.get('total_alerts', 0.0))
                    self._add_metric_data_point("active_alerts", pm_stats.get('active_alerts', 0.0))

    #                 # Get performance summary
    perf_summary = self.performance_monitor.get_performance_summary()
    #                 if 'implementations' in perf_summary:
    #                     for impl_type, impl_data in perf_summary['implementations'].items():
    #                         if 'avg_execution_time' in impl_data:
                                self._add_metric_data_point(
    #                                 f"avg_execution_time_{impl_type}",
    #                                 impl_data['avg_execution_time'] * 1000.0,  # Convert to ms
    #                                 {'implementation': impl_type}
    #                             )

    #                         if 'success_rate' in impl_data:
                                self._add_metric_data_point(
    #                                 f"success_rate_{impl_type}",
    #                                 impl_data['success_rate'],
    #                                 {'implementation': impl_type}
    #                             )

    #             # Collect system resource metrics
                self._collect_system_metrics()

    #         except Exception as e:
                logger.error(f"Error collecting metrics: {e}")

    #     def _collect_system_metrics(self):
    #         """Collect system resource metrics."""
    #         try:
    #             import psutil

    #             # CPU usage
    cpu_percent = psutil.cpu_percent(interval=1.0)
                self._add_metric_data_point("cpu_usage", cpu_percent)

    #             # Memory usage
    memory = psutil.virtual_memory()
    memory_percent = memory.percent
                self._add_metric_data_point("memory_usage", memory_percent)

    #             # Disk usage
    disk = psutil.disk_usage('/')
    disk_percent = math.multiply(disk.used / disk.total, 100.0)
                self._add_metric_data_point("disk_usage", disk_percent)

    #             # Network I/O
    network = psutil.net_io_counters()
                self._add_metric_data_point("network_bytes_sent", network.bytes_sent)
                self._add_metric_data_point("network_bytes_recv", network.bytes_recv)

    #         except ImportError:
                logger.warning("psutil not available, system metrics disabled")
    #         except Exception as e:
                logger.error(f"Error collecting system metrics: {e}")

    #     def _add_metric_data_point(self, metric_name: str, value: float, tags: Dict[str, str] = None):
    #         """Add a data point to a metric time series."""
    data_point = MetricDataPoint(
    timestamp = time.time(),
    value = value,
    tags = tags
    #         )

    #         with self._lock:
                self.metrics_data[metric_name].append(data_point)
    self.dashboard_stats['total_data_points'] + = 1

    #     def _anomaly_worker(self):
    #         """Background worker for anomaly detection."""
            logger.info("Anomaly detection worker started")

    #         while self._running:
    #             try:
    #                 if self.anomaly_config['enabled']:
    #                     # Detect anomalies in all metrics
    #                     for metric_name, data_points in self.metrics_data.items():
    #                         if len(data_points) >= self.anomaly_config['min_data_points']:
    anomaly = self._detect_anomaly(metric_name, list(data_points))
    #                             if anomaly:
                                    self.anomalies.append(anomaly)
    self.dashboard_stats['total_anomalies'] + = 1
                                    logger.warning(f"Anomaly detected: {anomaly.description}")

    #                 # Clean up old anomalies
                    self._cleanup_old_anomalies()

    #                 # Update active anomaly count
    #                 self.dashboard_stats['active_anomalies'] = sum(1 for a in self.anomalies if not a.resolved)

    #                 # Sleep until next check
                    time.sleep(10.0)  # Check every 10 seconds

    #             except Exception as e:
                    logger.error(f"Error in anomaly detection worker: {e}")
                    time.sleep(5.0)

            logger.info("Anomaly detection worker stopped")

    #     def _detect_anomaly(self, metric_name: str, data_points: List[MetricDataPoint]) -> Optional[AnomalyDetection]:
    #         """Detect anomalies in a metric time series."""
    #         if len(data_points) < self.anomaly_config['min_data_points']:
    #             return None

    #         values = [dp.value for dp in data_points[-self.anomaly_config['window_size']:]]

    #         # Z-score based anomaly detection
    mean = statistics.mean(values)
    #         stdev = statistics.stdev(values) if len(values) > 1 else 0.0

    #         if stdev > 0:
    latest_value = math.subtract(values[, 1])
    z_score = math.subtract(abs(latest_value, mean) / stdev)

    #             if z_score > self.anomaly_config['z_score_threshold']:
                    return AnomalyDetection(
    anomaly_id = str(uuid.uuid4()),
    anomaly_type = AnomalyType.UNUSUAL_PATTERN,
    metric_name = metric_name,
    #                     severity="high" if z_score > 3.5 else "medium",
    confidence = min(z_score / self.anomaly_config['z_score_threshold'], 1.0),
    description = f"Unusual value detected in {metric_name}: {latest_value:.2f} (z-score: {z_score:.2f})",
    detected_at = time.time(),
    data_points = math.subtract(data_points[, 5:]  # Last 5 points)
    #                 )

    #         # Error spike detection
    #         if 'error' in metric_name.lower() or 'failure' in metric_name.lower():
    baseline = math.subtract(statistics.mean(values[:, 5])  # Exclude last 5 points)
    recent_avg = math.subtract(statistics.mean(values[, 5:]))

    #             if baseline > 0 and recent_avg > baseline * self.anomaly_config['error_spike_threshold']:
                    return AnomalyDetection(
    anomaly_id = str(uuid.uuid4()),
    anomaly_type = AnomalyType.ERROR_SPIKE,
    metric_name = metric_name,
    severity = "critical",
    confidence = min(recent_avg / (baseline * self.anomaly_config['error_spike_threshold']), 1.0),
    description = f"Error spike detected in {metric_name}: {recent_avg:.2f} (baseline: {baseline:.2f})",
    detected_at = time.time(),
    data_points = math.subtract(data_points[, 5:])
    #                 )

    #         # Performance degradation detection
    #         if 'execution_time' in metric_name or 'response_time' in metric_name:
    baseline = math.subtract(statistics.mean(values[:, 10])  # Exclude last 10 points)
    recent_avg = math.subtract(statistics.mean(values[, 10:]))

    #             if baseline > 0 and recent_avg > baseline * (1.0 + self.anomaly_config['performance_degradation_threshold']):
    degradation = math.subtract((recent_avg, baseline) / baseline)
                    return AnomalyDetection(
    anomaly_id = str(uuid.uuid4()),
    anomaly_type = AnomalyType.PERFORMANCE_DEGRADATION,
    metric_name = metric_name,
    #                     severity="high" if degradation > 0.5 else "medium",
    confidence = min(degradation / self.anomaly_config['performance_degradation_threshold'], 1.0),
    description = f"Performance degradation detected in {metric_name}: {degradation:.2%} increase",
    detected_at = time.time(),
    data_points = math.subtract(data_points[, 10:])
    #                 )

    #         # Resource exhaustion detection
    #         if metric_name in ['cpu_usage', 'memory_usage', 'disk_usage']:
    latest_value = math.subtract(values[, 1])
    #             if latest_value > 90.0:  # 90% threshold
                    return AnomalyDetection(
    anomaly_id = str(uuid.uuid4()),
    anomaly_type = AnomalyType.RESOURCE_EXHAUSTION,
    metric_name = metric_name,
    #                     severity="critical" if latest_value > 95.0 else "high",
    confidence = math.divide(min(latest_value, 100.0, 1.0),)
    description = f"Resource exhaustion detected in {metric_name}: {latest_value:.2f}%",
    detected_at = time.time(),
    data_points = math.subtract(data_points[, 5:])
    #                 )

    #         return None

    #     def _cleanup_old_anomalies(self):
    #         """Clean up old resolved anomalies."""
    current_time = time.time()
    #         cutoff_time = current_time - 3600.0  # Keep for 1 hour

    #         with self._lock:
    #             # Remove old resolved anomalies
    self.anomalies = [
    #                 a for a in self.anomalies
    #                 if not a.resolved or a.resolved_at > cutoff_time
    #             ]

    #     def _trend_worker(self):
    #         """Background worker for trend analysis."""
            logger.info("Trend analysis worker started")

    #         while self._running:
    #             try:
    #                 # Analyze trends for all metrics
    #                 for metric_name, data_points in self.metrics_data.items():
    #                     if len(data_points) >= 20:  # Need at least 20 points
    trend = self._analyze_trend(metric_name, list(data_points))
    #                         if trend:
    self.trends[metric_name] = trend
    self.dashboard_stats['total_trends'] = len(self.trends)

    #                 # Sleep until next analysis
                    time.sleep(60.0)  # Analyze every minute

    #             except Exception as e:
                    logger.error(f"Error in trend analysis worker: {e}")
                    time.sleep(5.0)

            logger.info("Trend analysis worker stopped")

    #     def _analyze_trend(self, metric_name: str, data_points: List[MetricDataPoint]) -> Optional[TrendAnalysis]:
    #         """Analyze trend in a metric time series."""
    #         if len(data_points) < 20:
    #             return None

    #         # Extract values and timestamps
    #         values = [dp.value for dp in data_points]
    #         timestamps = [dp.timestamp for dp in data_points]

    #         # Normalize timestamps to start from 0
    min_timestamp = min(timestamps)
    #         normalized_timestamps = [t - min_timestamp for t in timestamps]

    #         # Calculate linear regression
    n = len(values)
    sum_x = sum(normalized_timestamps)
    sum_y = sum(values)
    #         sum_xy = sum(normalized_timestamps[i] * values[i] for i in range(n))
    #         sum_x2 = sum(x * x for x in normalized_timestamps)

    #         # Calculate slope and correlation
    denominator = math.multiply(n, sum_x2 - sum_x * sum_x)
    #         if denominator != 0:
    slope = math.multiply((n, sum_xy - sum_x * sum_y) / denominator)
    #         else:
    slope = 0.0

    #         # Calculate correlation coefficient
    y_mean = math.divide(sum_y, n)
    x_mean = math.divide(sum_x, n)

    #         sum_xy_deviation = sum((normalized_timestamps[i] - x_mean) * (values[i] - y_mean) for i in range(n))
    #         sum_x_deviation_sq = sum((x - x_mean) ** 2 for x in normalized_timestamps)
    #         sum_y_deviation_sq = sum((y - y_mean) ** 2 for y in values)

    denominator = math.multiply(math.sqrt(sum_x_deviation_sq, sum_y_deviation_sq))
    #         if denominator > 0:
    correlation = math.divide(sum_xy_deviation, denominator)
    #         else:
    correlation = 0.0

    #         # Determine trend direction
    #         if abs(slope) < 0.01:
    trend_direction = "stable"
    #         elif slope > 0:
    trend_direction = "increasing"
    #         else:
    trend_direction = "decreasing"

            # Calculate trend strength (0-1)
    trend_strength = min(abs(correlation), 1.0)

    #         # Make prediction for next time point
    #         if len(values) >= 10:
    prediction = math.add(values[-1], slope * (normalized_timestamps[-1] - normalized_timestamps[-10]))
    #         else:
    prediction = None

    #         # Calculate confidence based on correlation and data consistency
    confidence = math.add(trend_strength * (1.0 - (statistics.stdev(values) / (abs(statistics.mean(values)), 1.0)))
    confidence = max(0.0, min(1.0, confidence))

            return TrendAnalysis(
    metric_name = metric_name,
    trend_direction = trend_direction,
    trend_strength = trend_strength,
    slope = slope,
    correlation = correlation,
    prediction = prediction,
    confidence = confidence
    #         )

    #     def get_dashboard_data(self,
    metric_types: List[str] = None,
    time_range: int = math.subtract(3600), > Dict[str, Any]:)
    #         """
    #         Get dashboard data for visualization.

    #         Args:
    #             metric_types: Types of metrics to include (None for all)
                time_range: Time range in seconds (default: 1 hour)

    #         Returns:
    #             Dashboard data dictionary
    #         """
    #         with self._lock:
    current_time = time.time()
    cutoff_time = math.subtract(current_time, time_range)

    #             # Filter metrics by type and time
    filtered_metrics = {}
    #             for metric_name, data_points in self.metrics_data.items():
    #                 # Filter by metric type if specified
    #                 if metric_types:
    include = False
    #                     for metric_type in metric_types:
    #                         if metric_type.lower() in metric_name.lower():
    include = True
    #                             break
    #                     if not include:
    #                         continue

    #                 # Filter by time range
    #                 recent_points = [dp for dp in data_points if dp.timestamp >= cutoff_time]
    #                 if recent_points:
    #                     filtered_metrics[metric_name] = [dp.to_dict() for dp in recent_points]

    #             # Filter anomalies by time range
    recent_anomalies = [
    #                 a.to_dict() for a in self.anomalies
    #                 if a.detected_at >= cutoff_time
    #             ]

    #             # Filter trends
    filtered_trends = {
    #                 name: trend.to_dict() for name, trend in self.trends.items()
    #                 if metric_types is None or any(
                        metric_type.lower() in name.lower()
    #                     for metric_type in metric_types
    #                 )
    #             }

    #             return {
    #                 'timestamp': current_time,
    #                 'time_range': time_range,
    #                 'metrics': filtered_metrics,
    #                 'anomalies': recent_anomalies,
    #                 'trends': filtered_trends,
                    'statistics': self.dashboard_stats.copy(),
                    'system_status': self.self_improvement_manager.get_system_status()
    #             }

    #     def get_anomaly_summary(self, time_range: int = 3600) -> Dict[str, Any]:
    #         """
    #         Get anomaly summary for a time range.

    #         Args:
                time_range: Time range in seconds (default: 1 hour)

    #         Returns:
    #             Anomaly summary dictionary
    #         """
    #         with self._lock:
    current_time = time.time()
    cutoff_time = math.subtract(current_time, time_range)

    #             # Filter anomalies by time range
    recent_anomalies = [
    #                 a for a in self.anomalies
    #                 if a.detected_at >= cutoff_time
    #             ]

    #             # Group by type
    anomaly_counts = {}
    severity_counts = {}
    #             for anomaly in recent_anomalies:
    anomaly_type = anomaly.anomaly_type.value
    severity = anomaly.severity

    anomaly_counts[anomaly_type] = math.add(anomaly_counts.get(anomaly_type, 0), 1)
    severity_counts[severity] = math.add(severity_counts.get(severity, 0), 1)

    #             # Calculate metrics
    total_anomalies = len(recent_anomalies)
    #             active_anomalies = sum(1 for a in recent_anomalies if not a.resolved)
    resolved_anomalies = math.subtract(total_anomalies, active_anomalies)

    #             return {
    #                 'timestamp': current_time,
    #                 'time_range': time_range,
    #                 'total_anomalies': total_anomalies,
    #                 'active_anomalies': active_anomalies,
    #                 'resolved_anomalies': resolved_anomalies,
    #                 'anomaly_types': anomaly_counts,
    #                 'severity_distribution': severity_counts,
    #                 'most_common_type': max(anomaly_counts.items(), key=lambda x: x[1])[0] if anomaly_counts else None,
    #                 'most_severe': max(severity_counts.items(), key=lambda x: {'critical': 4, 'high': 3, 'medium': 2, 'low': 1}.get(x[0], 0))[0] if severity_counts else None
    #             }

    #     def get_performance_summary(self, time_range: int = 3600) -> Dict[str, Any]:
    #         """
    #         Get performance summary for a time range.

    #         Args:
                time_range: Time range in seconds (default: 1 hour)

    #         Returns:
    #             Performance summary dictionary
    #         """
    #         with self._lock:
    current_time = time.time()
    cutoff_time = math.subtract(current_time, time_range)

    #             # Get performance metrics
    performance_metrics = {}

    #             # Execution time metrics
    #             for impl_type in ['python', 'noodlecore', 'hybrid']:
    metric_name = f"avg_execution_time_{impl_type}"
    #                 if metric_name in self.metrics_data:
    data_points = [
    #                         dp for dp in self.metrics_data[metric_name]
    #                         if dp.timestamp >= cutoff_time
    #                     ]

    #                     if data_points:
    #                         values = [dp.value for dp in data_points]
    performance_metrics[f'{impl_type}_execution_time'] = {
                                'avg': statistics.mean(values),
                                'min': min(values),
                                'max': max(values),
                                'median': statistics.median(values),
    #                             'std_dev': statistics.stdev(values) if len(values) > 1 else 0.0,
                                'count': len(values)
    #                         }

    #             # Success rate metrics
    #             for impl_type in ['python', 'noodlecore', 'hybrid']:
    metric_name = f"success_rate_{impl_type}"
    #                 if metric_name in self.metrics_data:
    data_points = [
    #                         dp for dp in self.metrics_data[metric_name]
    #                         if dp.timestamp >= cutoff_time
    #                     ]

    #                     if data_points:
    #                         values = [dp.value for dp in data_points]
    performance_metrics[f'{impl_type}_success_rate'] = {
                                'avg': statistics.mean(values),
                                'min': min(values),
                                'max': max(values),
                                'median': statistics.median(values),
    #                             'std_dev': statistics.stdev(values) if len(values) > 1 else 0.0,
                                'count': len(values)
    #                         }

    #             # System metrics
    #             for metric_name in ['cpu_usage', 'memory_usage', 'disk_usage']:
    #                 if metric_name in self.metrics_data:
    data_points = [
    #                         dp for dp in self.metrics_data[metric_name]
    #                         if dp.timestamp >= cutoff_time
    #                     ]

    #                     if data_points:
    #                         values = [dp.value for dp in data_points]
    performance_metrics[metric_name] = {
                                'avg': statistics.mean(values),
                                'min': min(values),
                                'max': max(values),
                                'median': statistics.median(values),
    #                             'std_dev': statistics.stdev(values) if len(values) > 1 else 0.0,
                                'count': len(values)
    #                         }

    #             # Calculate comparisons
    comparisons = {}
    #             if 'python_execution_time' in performance_metrics and 'noodlecore_execution_time' in performance_metrics:
    python_avg = performance_metrics['python_execution_time']['avg']
    noodlecore_avg = performance_metrics['noodlecore_execution_time']['avg']

    #                 if python_avg > 0:
    improvement = math.subtract((python_avg, noodlecore_avg) / python_avg)
    comparisons['execution_time_improvement'] = {
    #                         'percentage': improvement * 100.0,
    #                         'faster': improvement > 0
    #                     }

    #             return {
    #                 'timestamp': current_time,
    #                 'time_range': time_range,
    #                 'performance_metrics': performance_metrics,
    #                 'comparisons': comparisons,
    #                 'trends': {
    #                     name: trend.to_dict() for name, trend in self.trends.items()
    #                     if name in performance_metrics
    #                 }
    #             }

    #     def resolve_anomaly(self, anomaly_id: str) -> bool:
    #         """
    #         Resolve an anomaly.

    #         Args:
    #             anomaly_id: ID of anomaly to resolve

    #         Returns:
    #             True if resolved, False if not found
    #         """
    #         with self._lock:
    #             for anomaly in self.anomalies:
    #                 if anomaly.anomaly_id == anomaly_id and not anomaly.resolved:
    anomaly.resolved = True
    anomaly.resolved_at = time.time()
                        logger.info(f"Resolved anomaly: {anomaly_id}")
    #                     return True

    #             return False

    #     def get_dashboard_statistics(self) -> Dict[str, Any]:
    #         """
    #         Get dashboard statistics.

    #         Returns:
    #             Dashboard statistics dictionary
    #         """
    #         with self._lock:
    stats = self.dashboard_stats.copy()
    stats['metrics_count'] = len(self.metrics_data)
    #             stats['data_points_total'] = sum(len(data_points) for data_points in self.metrics_data.values())
    stats['anomalies_count'] = len(self.anomalies)
    stats['trends_count'] = len(self.trends)
    stats['dashboard_active'] = self.dashboard_active
    stats['anomaly_config'] = self.anomaly_config.copy()
    #             return stats


# Global instance for convenience
_global_monitoring_dashboard = None


def get_monitoring_dashboard(
#     self_improvement_manager: SelfImprovementManager,
#     ai_decision_engine: AIDecisionEngine,
#     performance_monitor: PerformanceMonitoringSystem
# ) -> MonitoringDashboard:
#     """
#     Get a global monitoring dashboard instance.

#     Args:
#         self_improvement_manager: Self-improvement manager instance
#         ai_decision_engine: AI decision engine instance
#         performance_monitor: Performance monitoring system instance

#     Returns:
#         MonitoringDashboard: A monitoring dashboard instance
#     """
#     global _global_monitoring_dashboard

#     if _global_monitoring_dashboard is None:
_global_monitoring_dashboard = MonitoringDashboard(
#             self_improvement_manager, ai_decision_engine, performance_monitor
#         )

#     return _global_monitoring_dashboard