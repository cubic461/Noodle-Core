# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Advanced Metrics Collection and Analysis System for Noodle

# This module implements comprehensive metrics collection, analysis, and export capabilities
# to complement the real-time performance monitoring system with advanced features like
# predictive analytics, bottleneck detection, and external system integration.
# """

import asyncio
import gzip
import json
import logging
import pickle
import queue
import sqlite3
import statistics
import threading
import time
import uuid
import collections.defaultdict,
import concurrent.futures.ThreadPoolExecutor
import dataclasses.dataclass,
import datetime.datetime,
import enum.Enum
import pathlib.Path
import typing.Any,

import aiofiles
import aiohttp
import numpy as np
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import prometheus_client
import psutil
import redis
import plotly.subplots.make_subplots
import prometheus_client.CollectorRegistry,
import sklearn.cluster.DBSCAN
import sklearn.linear_model.LinearRegression
import sklearn.preprocessing.StandardScaler

logger = logging.getLogger(__name__)


class TimeWindow(Enum)
    #     """Time windows for metrics aggregation"""

    SECOND = "1s"
    MINUTE = "1m"
    HOUR = "1h"
    DAY = "1d"
    WEEK = "1w"
    MONTH = "1M"


class CompressionType(Enum)
    #     """Data compression types for archival"""

    NONE = "none"
    GZIP = "gzip"
    PICKLE = "pickle"
    PARQUET = "parquet"


# @dataclass
class MetricsQuery
    #     """Query parameters for metrics retrieval"""

    #     metric_names: List[str]
    #     start_time: datetime
    #     end_time: datetime
    time_window: TimeWindow = TimeWindow.MINUTE
    group_by: List[str] = field(default_factory=list)
    filters: Dict[str, Any] = field(default_factory=dict)
    aggregations: List[str] = field(default_factory=lambda: ["mean", "max", "min"])


# @dataclass
class PredictionResult
    #     """Result of predictive analytics"""

    #     metric_name: str
    #     predicted_values: List[float]
    #     confidence_intervals: List[Tuple[float, float]]
    #     timestamp: datetime
    #     model_accuracy: float
    #     trend_direction: str


# @dataclass
class BottleneckInfo
    #     """Information about detected performance bottlenecks"""

    #     component: str
    #     bottleneck_type: str
    #     severity: str
    #     description: str
    #     metrics_affected: List[str]
    #     timestamp: datetime
    #     suggested_actions: List[str]


class MetricsNormalizer
    #     """Normalizes and standardizes metrics for consistent analysis"""

    #     def __init__(self):
    self.scalers: Dict[str, StandardScaler] = {}
    self.normalization_params: Dict[str, Dict[str, float]] = {}

    #     def normalize_metric(
    self, metric_name: str, value: float, method: str = "zscore"
    #     ) -> float:
    #         """Normalize a single metric value"""
    #         if method == "zscore":
    #             if metric_name not in self.scalers:
    self.scalers[metric_name] = StandardScaler()
    #                 # Initialize with placeholder data
                    self.scalers[metric_name].fit(np.array([[0], [1]]))

    #             # Reshape for sklearn
    normalized = self.scalers[metric_name].transform(np.array([[value]]))[0][0]
                return float(normalized)

    #         elif method == "minmax":
    #             if metric_name not in self.normalization_params:
    self.normalization_params[metric_name] = {"min": 0, "max": 1}

    params = self.normalization_params[metric_name]
    normalized = (value - params["min"]) / (params["max"] - params["min"])
                return max(0, min(1, normalized))

    #         return value

    #     def batch_normalize(
    self, metrics: List[Tuple[str, float]], method: str = "zscore"
    #     ) -> List[float]:
    #         """Normalize a batch of metrics"""
    normalized_values = []

    #         # Group by metric name for efficient processing
    metric_groups = defaultdict(list)
    #         for name, value in metrics:
                metric_groups[name].append(value)

    #         # Fit scalers if needed
    #         for name, values in metric_groups.items():
    #             if method == "zscore" and name not in self.scalers:
    self.scalers[name] = StandardScaler()
                    self.scalers[name].fit(np.array(values).reshape(-1, 1))

    #         # Normalize each metric
    #         for name, value in metrics:
    normalized = self.normalize_metric(name, value, method)
                normalized_values.append(normalized)

    #         return normalized_values


class MetricsAggregator
    #     """Advanced metrics aggregation with rollup services for different time windows"""

    #     def __init__(self, storage_path: str = "metrics_aggregated"):
    self.storage_path = Path(storage_path)
    self.storage_path.mkdir(parents = True, exist_ok=True)
    self.aggregated_data: Dict[str, Dict[TimeWindow, pd.DataFrame]] = defaultdict(
    #             dict
    #         )
    self.lock = threading.Lock()
    self.executor = ThreadPoolExecutor(max_workers=4)

    #     def aggregate_metrics(
    #         self, metrics: List[PerformanceMetric], time_window: TimeWindow
    #     ) -> pd.DataFrame:
    #         """Aggregate metrics by specified time window"""
    #         if not metrics:
                return pd.DataFrame()

    #         # Convert to DataFrame
    df = pd.DataFrame(
    #             [
    #                 {
    #                     "timestamp": m.timestamp,
    #                     "value": m.value,
    #                     "name": m.name,
    #                     "tags": json.dumps(m.tags) if m.tags else "",
    #                     "unit": m.unit,
    #                 }
    #                 for m in metrics
    #             ]
    #         )

    #         # Set timestamp as index
    df["timestamp"] = pd.to_datetime(df["timestamp"])
    df.set_index("timestamp", inplace = True)

    #         # Resample based on time window
    resample_map = {
    #             TimeWindow.SECOND: "1S",
    #             TimeWindow.MINUTE: "1T",
    #             TimeWindow.HOUR: "1H",
    #             TimeWindow.DAY: "1D",
    #             TimeWindow.WEEK: "1W",
    #             TimeWindow.MONTH: "1M",
    #         }

    resample_rule = resample_map.get(time_window, "1T")
    aggregated = (
                df.groupby("name")
                .resample(resample_rule)
                .agg(
    #                 {
    #                     "value": ["mean", "max", "min", "std", "count"],
    #                     "unit": "first",
    #                     "tags": "first",
    #                 }
    #             )
    #         )

    #         # Flatten column names
    aggregated.columns = [
    #             "_".join(col).strip() for col in aggregated.columns.values
    #         ]

    #         return aggregated

    #     def store_aggregated(
    #         self, metric_name: str, time_window: TimeWindow, data: pd.DataFrame
    #     ) -> None:
    #         """Store aggregated metrics"""
    #         with self.lock:
    self.aggregated_data[metric_name][time_window] = data

    #             # Save to disk
    file_path = self.storage_path / f"{metric_name}_{time_window.value}.parquet"
                data.to_parquet(file_path)

    #     def get_aggregated(
    #         self,
    #         metric_name: str,
    #         time_window: TimeWindow,
    #         start_time: datetime,
    #         end_time: datetime,
    #     ) -> pd.DataFrame:
    #         """Retrieve aggregated metrics for a time range"""
    #         with self.lock:
    #             if (
    #                 metric_name not in self.aggregated_data
    #                 or time_window not in self.aggregated_data[metric_name]
    #             ):
    #                 # Try to load from disk if not in memory
    file_path = (
    #                     self.storage_path / f"{metric_name}_{time_window.value}.parquet"
    #                 )
    #                 if file_path.exists():
    data = pd.read_parquet(file_path)
    self.aggregated_data[metric_name][time_window] = data
    #                 else:
                        return pd.DataFrame()

    data = self.aggregated_data[metric_name][time_window]

    #             # Filter by time range
    mask = (data.index >= start_time) & (data.index <= end_time)
    #             return data.loc[mask]


class MetricsCorrelator
    #     """Advanced metrics correlation and dependency analysis"""

    #     def __init__(self, correlation_window: int = 1000):
    self.correlation_window = correlation_window
    self.metric_data: Dict[str, deque] = defaultdict(
    lambda: deque(maxlen = correlation_window)
    #         )
    self.dependency_graph: Dict[str, List[str]] = defaultdict(list)
    self.lock = threading.Lock()

    #     def update_metric(self, metric: PerformanceMetric) -> None:
    #         """Update metric data for correlation analysis"""
    #         with self.lock:
                self.metric_data[metric.name].append((metric.timestamp, metric.value))

    #     def calculate_correlation_matrix(self, metric_names: List[str]) -> pd.DataFrame:
    #         """Calculate correlation matrix for specified metrics"""
    data = {}

    #         with self.lock:
    #             for name in metric_names:
    #                 if name in self.metric_data and len(self.metric_data[name]) > 10:
    #                     # Align timestamps and get values
    timestamps, values = math.multiply(zip(, self.metric_data[name]))
    data[name] = values

    #         if not data:
                return pd.DataFrame()

    df = pd.DataFrame(data)
            return df.corr()

    #     def detect_dependencies(
    self, metric_names: List[str], correlation_threshold: float = 0.7
    #     ) -> Dict[str, List[str]]:
    #         """Detect metric dependencies based on correlation analysis"""
    correlation_matrix = self.calculate_correlation_matrix(metric_names)

    #         if correlation_matrix.empty:
    #             return {}

    dependencies = defaultdict(list)

    #         for i, metric1 in enumerate(metric_names):
    #             for j, metric2 in enumerate(metric_names):
    #                 if i != j:
    correlation = correlation_matrix.loc[metric1, metric2]
    #                     if abs(correlation) >= correlation_threshold:
                            dependencies[metric1].append(metric2)

            return dict(dependencies)

    #     def find_causal_relationships(
    self, metric_names: List[str], lag_window: int = 10
    #     ) -> Dict[str, Dict[str, int]]:
    #         """Find potential causal relationships with time lag analysis"""
    causal_relationships = {}

    #         with self.lock:
    #             for i, metric1 in enumerate(metric_names):
    #                 if metric1 not in self.metric_data:
    #                     continue

    #                 for j, metric2 in enumerate(metric_names):
    #                     if i == j or metric2 not in self.metric_data:
    #                         continue

    #                     # Get aligned data
    data1 = list(self.metric_data[metric1])
    data2 = list(self.metric_data[metric2])

    #                     if len(data1) < lag_window * 2 or len(data2) < lag_window * 2:
    #                         continue

    #                     # Calculate cross-correlation for different lags
    best_correlation = 0
    best_lag = 0

    #                     for lag in range(-lag_window, lag_window + 1):
    #                         if lag == 0:
    #                             continue

    #                         # Align data based on lag
    #                         if lag > 0:
    #                             aligned1 = [v for _, v in data1[lag:]]
    aligned2 = [
    #                                 v
    #                                 for _, v in data2[:-lag]
    #                                 if len(data1[lag:]) == len(data2[:-lag])
    #                             ]
    #                         else:
    #                             aligned1 = [v for _, v in data1[:lag]]
    aligned2 = [
    #                                 v
    #                                 for _, v in data2[-lag:]
    #                                 if len(data1[:lag]) == len(data2[-lag:])
    #                             ]

    #                         if len(aligned1) < 10 or len(aligned2) < 10:
    #                             continue

    #                         # Calculate correlation
    correlation = np.corrcoef(aligned1, aligned2)[0, 1]
    #                         if (
                                not np.isnan(correlation)
                                and abs(correlation) > best_correlation
    #                         ):
    best_correlation = abs(correlation)
    best_lag = lag

    #                     if best_correlation > 0.6:  # Threshold for causal relationship
    #                         if metric1 not in causal_relationships:
    causal_relationships[metric1] = {}
    causal_relationships[metric1][metric2] = best_lag

    #         return causal_relationships


class PerformanceProfiler
    #     """Metrics-based performance profiling and bottleneck detection"""

    #     def __init__(self):
    self.baseline_metrics: Dict[str, Dict[str, float]] = {}
    self.bottlenecks: deque = deque(maxlen=100)
    self.lock = threading.Lock()

    #     def establish_baseline(
    #         self,
    #         metrics: List[PerformanceMetric],
    duration: timedelta = timedelta(hours=24),
    #     ) -> None:
    #         """Establish performance baseline from historical metrics"""
    end_time = datetime.now()
    start_time = math.subtract(end_time, duration)

    #         # Group metrics by name
    metric_groups = defaultdict(list)
    #         for metric in metrics:
    #             if start_time <= metric.timestamp <= end_time:
                    metric_groups[metric.name].append(metric.value)

    #         # Calculate baseline statistics
    baseline = {}
    #         for name, values in metric_groups.items():
    #             if values:
    baseline[name] = {
                        "mean": statistics.mean(values),
    #                     "std": statistics.stdev(values) if len(values) > 1 else 0,
                        "p95": np.percentile(values, 95),
                        "p99": np.percentile(values, 99),
                        "min": min(values),
                        "max": max(values),
    #                 }

    #         with self.lock:
    self.baseline_metrics = baseline

    #     def detect_bottlenecks(
    #         self, metrics: List[PerformanceMetric]
    #     ) -> List[BottleneckInfo]:
    #         """Detect performance bottlenecks based on current metrics"""
    bottlenecks = []

    #         with self.lock:
    #             if not self.baseline_metrics:
    #                 return bottlenecks

    #             # Group metrics by name
    metric_groups = defaultdict(list)
    #             for metric in metrics:
                    metric_groups[metric.name].append(metric)

    #             # Check each metric against baseline
    #             for name, metric_list in metric_groups.items():
    #                 if name not in self.baseline_metrics:
    #                     continue

    baseline = self.baseline_metrics[name]

    #                 for metric in metric_list:
    value = metric.value

    #                     # Check for significant deviations
    deviations = []

    #                     # Check against mean + 3 standard deviations
    #                     if value > baseline["mean"] + 3 * baseline["std"]:
                            deviations.append(
    #                             {
    #                                 "type": "high_value",
                                    "severity": (
    #                                     "high" if value > baseline["p99"] else "medium"
    #                                 ),
    #                                 "description": f"Value {value:.2f} is above expected range",
    #                             }
    #                         )

    #                     # Check against p95
    #                     if value > baseline["p95"] * 1.5:  # 50% above p95
                            deviations.append(
    #                             {
    #                                 "type": "above_p95",
    #                                 "severity": "high",
                                    "description": f"Value {value:.2f} is significantly above p95 ({baseline['p95']:.2f})",
    #                             }
    #                         )

    #                     # Check for sudden changes
    #                     if len(metric_list) > 5:
    #                         recent_values = [m.value for m in metric_list[-5:]]
    #                         if statistics.stdev(recent_values) > baseline["std"] * 2:
                                deviations.append(
    #                                 {
    #                                     "type": "high_volatility",
    #                                     "severity": "medium",
    #                                     "description": f"High volatility detected in recent values",
    #                                 }
    #                             )

    #                     # Create bottleneck info for each deviation
    #                     for deviation in deviations:
    bottleneck = BottleneckInfo(
    component = self._infer_component_from_metric_name(name),
    bottleneck_type = deviation["type"],
    severity = deviation["severity"],
    description = deviation["description"],
    metrics_affected = [name],
    timestamp = metric.timestamp,
    suggested_actions = self._get_suggested_actions(
    #                                 deviation["type"]
    #                             ),
    #                         )
                            bottlenecks.append(bottleneck)

    #         return bottlenecks

    #     def _infer_component_from_metric_name(self, metric_name: str) -> str:
    #         """Infer component name from metric name"""
    #         if "cpu" in metric_name.lower():
    #             return "CPU"
    #         elif "memory" in metric_name.lower():
    #             return "Memory"
    #         elif "disk" in metric_name.lower():
    #             return "Disk"
    #         elif "network" in metric_name.lower():
    #             return "Network"
    #         elif "database" in metric_name.lower():
    #             return "Database"
    #         elif "cache" in metric_name.lower():
    #             return "Cache"
    #         else:
    #             return "Unknown"

    #     def _get_suggested_actions(self, bottleneck_type: str) -> List[str]:
    #         """Get suggested actions for different bottleneck types"""
    actions_map = {
    #             "high_value": [
    #                 "Check resource allocation",
    #                 "Review application configuration",
    #                 "Consider scaling resources",
    #             ],
    #             "above_p95": [
    #                 "Investigate recent changes",
    #                 "Monitor for sustained high values",
    #                 "Prepare for potential scaling",
    #             ],
    #             "high_volatility": [
    #                 "Check for intermittent processes",
    #                 "Review scheduled tasks",
    #                 "Investigate external dependencies",
    #             ],
    #         }
            return actions_map.get(bottleneck_type, ["Monitor the situation"])


class PredictiveAnalytics
    #     """Predictive analytics for performance trends and capacity planning"""

    #     def __init__(self, prediction_window: int = 24):
    self.prediction_window = prediction_window  # hours
    self.models: Dict[str, LinearRegression] = {}
    self.scalers: Dict[str, StandardScaler] = {}
    self.lock = threading.Lock()

    #     def train_model(self, metric_name: str, metrics: List[PerformanceMetric]) -> None:
    #         """Train a predictive model for a specific metric"""
    #         if len(metrics) < 24:  # Need sufficient data
    #             return

    #         # Prepare training data
    timestamps = [
    #             (m.timestamp - metrics[0].timestamp).total_seconds() / 3600 for m in metrics
    #         ]
    #         values = [m.value for m in metrics]

    #         # Reshape for sklearn
    X = math.subtract(np.array(timestamps).reshape(, 1, 1))
    y = np.array(values)

    #         # Create and train model
    model = LinearRegression()
    scaler = StandardScaler()

    X_scaled = scaler.fit_transform(X)
            model.fit(X_scaled, y)

    #         with self.lock:
    self.models[metric_name] = model
    self.scalers[metric_name] = scaler

    #     def predict_metric(
    #         self, metric_name: str, current_time: datetime
    #     ) -> Optional[PredictionResult]:
    #         """Predict future values for a specific metric"""
    #         with self.lock:
    #             if metric_name not in self.models or metric_name not in self.scalers:
    #                 return None

    model = self.models[metric_name]
    scaler = self.scalers[metric_name]

    #             # Create future timestamps
    future_hours = math.add(np.arange(1, self.prediction_window, 1).reshape(-1, 1))
    future_scaled = scaler.transform(future_hours)

    #             # Make predictions
    predictions = model.predict(future_scaled)

                # Calculate confidence intervals (simplified approach)
    residuals = (
    #                 model.residues_
    #                 if hasattr(model, "residues_")
                    else np.zeros(len(predictions))
    #             )
    #             std_error = np.std(residuals) if len(residuals) > 0 else 1.0

    confidence_intervals = [
                    (pred - 1.96 * std_error, pred + 1.96 * std_error)
    #                 for pred in predictions
    #             ]

    #             # Determine trend direction
    #             if len(predictions) >= 2:
    #                 if predictions[-1] > predictions[0] * 1.05:
    trend = "increasing"
    #                 elif predictions[-1] < predictions[0] * 0.95:
    trend = "decreasing"
    #                 else:
    trend = "stable"
    #             else:
    trend = "unknown"

                # Calculate model accuracy (R² score)
    r_squared = model.score(future_scaled, predictions)

                return PredictionResult(
    metric_name = metric_name,
    predicted_values = predictions.tolist(),
    confidence_intervals = confidence_intervals,
    timestamp = current_time,
    model_accuracy = float(r_squared),
    trend_direction = trend,
    #             )

    #     def capacity_recommendations(
    #         self, predictions: List[PredictionResult]
    #     ) -> Dict[str, Any]:
    #         """Generate capacity planning recommendations based on predictions"""
    recommendations = {
                "timestamp": datetime.now().isoformat(),
    #             "recommendations": [],
    #             "priority_actions": [],
    #         }

    #         for prediction in predictions:
    metric_name = prediction.metric_name
    values = prediction.predicted_values
    trend = prediction.trend_direction

    #             # Check for capacity concerns
    #             if trend == "increasing":
    #                 if values[-1] > values[0] * 1.5:  # 50% increase
                        recommendations["priority_actions"].append(
    #                         {
    #                             "metric": metric_name,
    #                             "action": "Plan capacity increase",
    #                             "reason": f"Predicted {trend} trend with significant growth",
    #                             "urgency": "high",
    #                         }
    #                     )
    #                 else:
                        recommendations["recommendations"].append(
    #                         {
    #                             "metric": metric_name,
    #                             "action": "Monitor capacity usage",
    #                             "reason": f"Predicted {trend} trend",
    #                             "urgency": "medium",
    #                         }
    #                     )

    #             elif trend == "decreasing":
                    recommendations["recommendations"].append(
    #                     {
    #                         "metric": metric_name,
    #                         "action": "Consider rightsizing",
    #                         "reason": f"Predicted {trend} trend",
    #                         "urgency": "low",
    #                     }
    #                 )

    #         return recommendations


class MetricsExporter
    #     """Export metrics to external monitoring systems"""

    #     def __init__(self):
    self.prometheus_registry = CollectorRegistry()
    self.prometheus_metrics = {}
    self.export_configs = {}
    self.lock = threading.Lock()

    #     def configure_prometheus_export(
    self, port: int = 8000, path: str = "/metrics"
    #     ) -> None:
    #         """Configure Prometheus export"""
    self.export_configs["prometheus"] = {"port": port, "path": path}

    #         # Create Prometheus metrics
    self.prometheus_metrics["cpu_usage"] = Gauge(
    #             "noodle_cpu_usage_percent",
    #             "CPU usage percentage",
    registry = self.prometheus_registry,
    #         )
    self.prometheus_metrics["memory_usage"] = Gauge(
    #             "noodle_memory_usage_percent",
    #             "Memory usage percentage",
    registry = self.prometheus_registry,
    #         )
    self.prometheus_metrics["disk_usage"] = Gauge(
    #             "noodle_disk_usage_percent",
    #             "Disk usage percentage",
    registry = self.prometheus_registry,
    #         )
    self.prometheus_metrics["network_bytes_sent"] = Counter(
    #             "noodle_network_bytes_sent",
    #             "Network bytes sent",
    registry = self.prometheus_registry,
    #         )
    self.prometheus_metrics["network_bytes_recv"] = Counter(
    #             "noodle_network_bytes_recv",
    #             "Network bytes received",
    registry = self.prometheus_registry,
    #         )

    #     def export_to_prometheus(self, metrics: List[PerformanceMetric]) -> None:
    #         """Export metrics to Prometheus"""
    #         if "prometheus" not in self.export_configs:
    #             return

    #         with self.lock:
    #             for metric in metrics:
    metric_name = metric.name.replace(".", "_").replace("-", "_")

    #                 if metric_name in self.prometheus_metrics:
    prom_metric = self.prometheus_metrics[metric_name]

    #                     if metric.metric_type == MetricType.GAUGE:
                            prom_metric.set(metric.value)
    #                     elif metric.metric_type == MetricType.COUNTER:
                            prom_metric.inc(metric.value)

    #     def export_to_grafana(
    #         self, metrics: List[PerformanceMetric], grafana_url: str, api_key: str
    #     ) -> bool:
            """Export metrics to Grafana (simplified implementation)"""
    #         # This is a simplified implementation
    #         # In a real implementation, you would use Grafana's API

    #         try:
    #             # Prepare data for Grafana
    data = {"dashboard": {"id": None, "title": "Noodle Metrics", "panels": []}}

    #             # Create panels for each metric
    metric_panels = {}
    #             for metric in metrics:
    #                 if metric.name not in metric_panels:
    metric_panels[metric.name] = {
    #                         "title": metric.name,
    #                         "targets": [
    #                             {
    #                                 "expr": f"noodle_{metric.name}",
    #                                 "legendFormat": metric.name,
    #                             }
    #                         ],
    #                         "type": "graph",
    #                     }

    #             # Add panels to dashboard
    #             for panel in metric_panels.values():
                    data["dashboard"]["panels"].append(panel)

    #             # In a real implementation, you would send this to Grafana's API
    # headers = {'Authorization': f'Bearer {api_key}'}
    # response = requests.post(f'{grafana_url}/api/dashboards/db', json=data, headers=headers)
    # return response.status_code = = 200

    #             return True  # Placeholder

    #         except Exception as e:
                logger.error(f"Error exporting to Grafana: {e}")
    #             return False

    #     def start_prometheus_server(self) -> None:
    #         """Start Prometheus HTTP server"""
    #         if "prometheus" not in self.export_configs:
    #             return

            prometheus_client.start_http_server(
    port = self.export_configs["prometheus"]["port"],
    registry = self.prometheus_registry,
    #         )

            logger.info(
    #             f"Prometheus exporter started on port {self.export_configs['prometheus']['port']}"
    #         )


class MetricsArchiver
    #     """Metrics data compression and archival strategies"""

    #     def __init__(self, storage_path: str = "metrics_archive"):
    self.storage_path = Path(storage_path)
    self.storage_path.mkdir(parents = True, exist_ok=True)
    self.archive_index: Dict[str, Dict[str, Any]] = {}
    self.lock = threading.Lock()

    #     def compress_metrics(
    #         self,
    #         metrics: List[PerformanceMetric],
    compression_type: CompressionType = CompressionType.GZIP,
    #     ) -> bytes:
    #         """Compress metrics data"""
    #         # Convert to DataFrame for efficient compression
    df = pd.DataFrame(
    #             [
    #                 {
    #                     "name": m.name,
    #                     "value": m.value,
    #                     "unit": m.unit,
                        "timestamp": m.timestamp.isoformat(),
    #                     "metric_type": m.metric_type.value,
    #                     "tags": json.dumps(m.tags) if m.tags else "",
    #                     "metadata": json.dumps(m.metadata) if m.metadata else "",
    #                 }
    #                 for m in metrics
    #             ]
    #         )

    #         if compression_type == CompressionType.NONE:
                return df.to_json().encode("utf-8")

    #         elif compression_type == CompressionType.GZIP:
    json_data = df.to_json().encode("utf-8")
                return gzip.compress(json_data)

    #         elif compression_type == CompressionType.PICKLE:
                return pickle.dumps(df)

    #         elif compression_type == CompressionType.PARQUET:
    #             # Parquet requires binary format
    buffer = io.BytesIO()
                df.to_parquet(buffer)
                return buffer.getvalue()

            return df.to_json().encode("utf-8")

    #     def archive_metrics(
    #         self,
    #         metrics: List[PerformanceMetric],
    compression_type: CompressionType = CompressionType.GZIP,
    retention_days: int = 365,
    #     ) -> str:
    #         """Archive metrics with compression"""
    timestamp = datetime.now()
    archive_id = str(uuid.uuid4())

    #         # Compress metrics
    compressed_data = self.compress_metrics(metrics, compression_type)

    #         # Determine file path
    date_str = timestamp.strftime("%Y-%m-%d")
    file_path = (
    #             self.storage_path / f"{archive_id}_{date_str}.{compression_type.value}"
    #         )

    #         # Write to disk
    #         with open(file_path, "wb") as f:
                f.write(compressed_data)

    #         # Update index
    #         with self.lock:
    self.archive_index[archive_id] = {
                    "file_path": str(file_path),
    #                 "compression_type": compression_type.value,
                    "timestamp": timestamp.isoformat(),
                    "metric_count": len(metrics),
                    "retention_until": (
    timestamp + timedelta(days = retention_days)
                    ).isoformat(),
    #                 "metrics": list(set(m.name for m in metrics)),
    #             }

    #         # Save index
            self._save_index()

    #         logger.info(f"Archived {len(metrics)} metrics with ID {archive_id}")
    #         return archive_id

    #     def retrieve_metrics(self, archive_id: str) -> Optional[List[PerformanceMetric]]:
    #         """Retrieve metrics from archive"""
    #         with self.lock:
    #             if archive_id not in self.archive_index:
    #                 return None

    archive_info = self.archive_index[archive_id]
    file_path = archive_info["file_path"]
    compression_type = CompressionType(archive_info["compression_type"])

    #         if not Path(file_path).exists():
    #             return None

    #         # Read and decompress
    #         with open(file_path, "rb") as f:
    #             if compression_type == CompressionType.NONE:
    data = f.read().decode("utf-8")
    df = pd.read_json(io.StringIO(data))
    #             elif compression_type == CompressionType.GZIP:
    data = gzip.decompress(f.read())
    df = pd.read_json(io.StringIO(data.decode("utf-8")))
    #             elif compression_type == CompressionType.PICKLE:
    data = f.read()
    df = pickle.loads(data)
    #             elif compression_type == CompressionType.PARQUET:
    data = f.read()
    df = pd.read_parquet(io.BytesIO(data))
    #             else:
    #                 return None

    #         # Convert back to PerformanceMetric objects
    metrics = []
    #         for _, row in df.iterrows():
    metric = PerformanceMetric(
    name = row["name"],
    value = row["value"],
    unit = row["unit"],
    timestamp = datetime.fromisoformat(row["timestamp"]),
    metric_type = MetricType(row["metric_type"]),
    #                 tags=json.loads(row["tags"]) if row["tags"] else {},
    #                 metadata=json.loads(row["metadata"]) if row["metadata"] else {},
    #             )
                metrics.append(metric)

    #         return metrics

    #     def cleanup_expired_archives(self) -> None:
    #         """Clean up expired archives based on retention policy"""
    current_time = datetime.now()
    expired_archives = []

    #         with self.lock:
    #             for archive_id, info in self.archive_index.items():
    retention_until = datetime.fromisoformat(info["retention_until"])
    #                 if current_time > retention_until:
                        expired_archives.append(archive_id)

    #         # Remove expired archives
    #         for archive_id in expired_archives:
    #             with self.lock:
    #                 if archive_id in self.archive_index:
    file_path = self.archive_index[archive_id]["file_path"]
    #                     del self.archive_index[archive_id]

    #                     # Delete file
    #                     if Path(file_path).exists():
                            Path(file_path).unlink()

                logger.info(f"Cleaned up expired archive: {archive_id}")

    #         # Save updated index
            self._save_index()

    #     def _save_index(self) -> None:
    #         """Save archive index to disk"""
    index_file = self.storage_path / "archive_index.json"
    #         with open(index_file, "w") as f:
    json.dump(self.archive_index, f, indent = 2)


class MetricsQueryEngine
    #     """Metrics query language and filtering capabilities"""

    #     def __init__(self):
    self.query_cache: Dict[str, pd.DataFrame] = {}
    self.cache_ttl = 300  # 5 minutes
    self.lock = threading.Lock()

    #     def execute_query(
    #         self,
    #         query: MetricsQuery,
    #         data_source: Callable[[str, datetime, datetime], List[PerformanceMetric]],
    #     ) -> pd.DataFrame:
    #         """Execute a metrics query with filtering and aggregation"""
    #         # Generate cache key
    cache_key = self._generate_cache_key(query)

    #         # Check cache
    #         with self.lock:
    #             if cache_key in self.query_cache:
    cached_data, timestamp = self.query_cache[cache_key]
    #                 if (datetime.now() - timestamp).total_seconds() < self.cache_ttl:
    #                     return cached_data

    #         # Retrieve raw data
    all_metrics = []
    #         for metric_name in query.metric_names:
    metrics = data_source(metric_name, query.start_time, query.end_time)
                all_metrics.extend(metrics)

    #         if not all_metrics:
                return pd.DataFrame()

    #         # Convert to DataFrame
    df = pd.DataFrame(
    #             [
    #                 {
    #                     "timestamp": m.timestamp,
    #                     "value": m.value,
    #                     "name": m.name,
    #                     "unit": m.unit,
    #                     "tags": json.dumps(m.tags) if m.tags else "",
    #                     **m.metadata,
    #                 }
    #                 for m in all_metrics
    #             ]
    #         )

    #         # Convert timestamp to datetime
    df["timestamp"] = pd.to_datetime(df["timestamp"])

    #         # Apply filters
    #         for field, condition in query.filters.items():
    #             if field in df.columns:
    #                 if isinstance(condition, dict):
    #                     # Handle complex conditions
    #                     if "eq" in condition:
    df = df[df[field] == condition["eq"]]
    #                     if "gt" in condition:
    df = df[df[field] > condition["gt"]]
    #                     if "lt" in condition:
    df = df[df[field] < condition["lt"]]
    #                     if "in" in condition:
    df = df[df[field].isin(condition["in"])]
    #                 else:
    #                     # Simple equality filter
    df = df[df[field] == condition]

    #         # Apply time window aggregation
    #         if query.time_window != TimeWindow.SECOND:
    resample_map = {
    #                 TimeWindow.MINUTE: "1T",
    #                 TimeWindow.HOUR: "1H",
    #                 TimeWindow.DAY: "1D",
    #                 TimeWindow.WEEK: "1W",
    #                 TimeWindow.MONTH: "1M",
    #             }

    resample_rule = resample_map.get(query.time_window, "1T")
    df.set_index("timestamp", inplace = True)
    df = (
                    df.groupby("name")
                    .resample(resample_rule)
                    .agg({"value": query.aggregations, "unit": "first"})
    #             )
    df.reset_index(inplace = True)
    #         else:
    #             # For second-level granularity, just ensure timestamps are aligned
    df["timestamp"] = df["timestamp"].dt.floor("1S")

    #         # Apply group by if specified
    #         if query.group_by:
    #             if query.time_window != TimeWindow.SECOND:
    #                 # For aggregated data, group by the specified fields
    grouped = (
                        df.groupby(["name"] + query.group_by + ["timestamp"])
                        .agg({"value": query.aggregations, "unit": "first"})
                        .reset_index()
    #                 )
    #             else:
    #                 # For raw data, group by the specified fields
    grouped = (
                        df.groupby(query.group_by + ["timestamp"])
                        .agg({"value": query.aggregations, "unit": "first"})
                        .reset_index()
    #                 )

    df = grouped

    #         # Cache result
    #         with self.lock:
    self.query_cache[cache_key] = (df.copy(), datetime.now())

    #         return df

    #     def _generate_cache_key(self, query: MetricsQuery) -> str:
    #         """Generate a unique cache key for a query"""
    #         # Create a deterministic string representation of the query
    key_parts = [
                ",".join(sorted(query.metric_names)),
                query.start_time.isoformat(),
                query.end_time.isoformat(),
    #             query.time_window.value,
                ",".join(sorted(query.group_by)),
    json.dumps(query.filters, sort_keys = True),
                ",".join(sorted(query.aggregations)),
    #         ]
            return "|".join(key_parts)

    #     def clear_cache(self) -> None:
    #         """Clear the query cache"""
    #         with self.lock:
                self.query_cache.clear()


class MetricsAnalysisSystem
    #     """Main metrics analysis system that integrates all components"""

    #     def __init__(self, storage_path: str = "metrics_analysis"):
    self.storage_path = Path(storage_path)
    self.storage_path.mkdir(parents = True, exist_ok=True)

    #         # Initialize components
    self.normalizer = MetricsNormalizer()
    self.aggregator = MetricsAggregator(str(self.storage_path / "aggregated"))
    self.correlator = MetricsCorrelator()
    self.profiler = PerformanceProfiler()
    self.predictor = PredictiveAnalytics()
    self.exporter = MetricsExporter()
    self.archiver = MetricsArchiver(str(self.storage_path / "archive"))
    self.query_engine = MetricsQueryEngine()

    #         # System state
    self.running = False
    self.analysis_thread = None
    self.executor = ThreadPoolExecutor(max_workers=8)

            logger.info("Metrics analysis system initialized")

    #     def start(self) -> None:
    #         """Start the metrics analysis system"""
    #         if self.running:
    #             return

    self.running = True
    self.analysis_thread = threading.Thread(target=self._analysis_loop, daemon=True)
            self.analysis_thread.start()

    #         # Start Prometheus exporter if configured
    #         if "prometheus" in self.exporter.export_configs:
                self.exporter.start_prometheus_server()

            logger.info("Metrics analysis system started")

    #     def stop(self) -> None:
    #         """Stop the metrics analysis system"""
    self.running = False

    #         if self.analysis_thread:
    self.analysis_thread.join(timeout = 5.0)

    self.executor.shutdown(wait = True)
            logger.info("Metrics analysis system stopped")

    #     def process_metrics(self, metrics: List[PerformanceMetric]) -> None:
    #         """Process a batch of metrics through the analysis pipeline"""
    #         if not metrics:
    #             return

    #         # Submit tasks to thread pool
    futures = []

    #         # Normalization
            futures.append(self.executor.submit(self._normalize_metrics, metrics))

    #         # Correlation analysis
            futures.append(self.executor.submit(self._update_correlations, metrics))

    #         # Aggregation
            futures.append(self.executor.submit(self._aggregate_metrics, metrics))

    #         # Bottleneck detection
            futures.append(self.executor.submit(self._detect_bottlenecks, metrics))

    #         # Predictive analytics
            futures.append(self.executor.submit(self._run_predictions, metrics))

    #         # Export to external systems
            futures.append(self.executor.submit(self._export_metrics, metrics))

    #         # Archive older metrics
            futures.append(self.executor.submit(self._archive_old_metrics, metrics))

    #         # Wait for all tasks to complete
    #         for future in futures:
    #             try:
                    future.result()
    #             except Exception as e:
                    logger.error(f"Error in metrics processing: {e}")

    #     def _normalize_metrics(self, metrics: List[PerformanceMetric]) -> None:
    #         """Normalize metrics for consistent analysis"""
    normalized_values = self.normalizer.batch_normalize(
    #             [(m.name, m.value) for m in metrics]
    #         )

    #         # Update metrics with normalized values (if needed)
    #         for i, metric in enumerate(metrics):
    #             # Store normalized value in metadata
    metric.metadata["normalized_value"] = normalized_values[i]

    #     def _update_correlations(self, metrics: List[PerformanceMetric]) -> None:
    #         """Update correlation analysis"""
    #         for metric in metrics:
                self.correlator.update_metric(metric)

    #     def _aggregate_metrics(self, metrics: List[PerformanceMetric]) -> None:
    #         """Aggregate metrics for different time windows"""
    #         for time_window in TimeWindow:
    aggregated = self.aggregator.aggregate_metrics(metrics, time_window)
    #             if not aggregated.empty:
    #                 # Store aggregated data
    #                 for metric_name in aggregated.index.get_level_values("name").unique():
    metric_data = aggregated.xs(metric_name, level="name")
                        self.aggregator.store_aggregated(
    #                         metric_name, time_window, metric_data
    #                     )

    #     def _detect_bottlenecks(self, metrics: List[PerformanceMetric]) -> None:
    #         """Detect performance bottlenecks"""
    bottlenecks = self.profiler.detect_bottlenecks(metrics)

    #         if bottlenecks:
    #             # Log bottlenecks
    #             for bottleneck in bottlenecks:
                    logger.warning(f"Bottleneck detected: {bottleneck.description}")

    #             # Store bottlenecks
    #             with self.archiver.lock:
    #                 for bottleneck in bottlenecks:
    bottleneck_data = {
    #                         "component": bottleneck.component,
    #                         "type": bottleneck.bottleneck_type,
    #                         "severity": bottleneck.severity,
    #                         "description": bottleneck.description,
    #                         "metrics_affected": bottleneck.metrics_affected,
                            "timestamp": bottleneck.timestamp.isoformat(),
    #                         "suggested_actions": bottleneck.suggested_actions,
    #                     }

    #                     # Store in archive
                        self.archiver.archive_metrics(
    #                         [
                                PerformanceMetric(
    name = f"bottleneck_{bottleneck.component}_{bottleneck.bottleneck_type}",
    value = 1.0,
    unit = "count",
    timestamp = bottleneck.timestamp,
    metadata = bottleneck_data,
    #                             )
    #                         ],
    #                         CompressionType.JSON,
    #                     )

    #     def _run_predictions(self, metrics: List[PerformanceMetric]) -> None:
    #         """Run predictive analytics"""
    #         # Group metrics by name
    metric_groups = defaultdict(list)
    #         for metric in metrics:
                metric_groups[metric.name].append(metric)

    #         # Train models and make predictions
    predictions = []
    #         for name, metric_list in metric_groups.items():
    #             # Train model if we have enough data
    #             if len(metric_list) >= 24:
                    self.predictor.train_model(name, metric_list)

    #             # Make prediction
    prediction = self.predictor.predict_metric(name, datetime.now())
    #             if prediction:
                    predictions.append(prediction)

    #         # Generate capacity recommendations
    #         if predictions:
    recommendations = self.predictor.capacity_recommendations(predictions)

    #             # Log recommendations
    #             for action in recommendations.get("priority_actions", []):
                    logger.warning(
    #                     f"Capacity priority action: {action['action']} for {action['metric']}"
    #                 )

    #             for action in recommendations.get("recommendations", []):
                    logger.info(
    #                     f"Capacity recommendation: {action['action']} for {action['metric']}"
    #                 )

    #             # Store recommendations
                self.archiver.archive_metrics(
    #                 [
                        PerformanceMetric(
    name = "capacity_recommendations",
    value = 1.0,
    unit = "count",
    timestamp = datetime.now(),
    metadata = recommendations,
    #                     )
    #                 ],
    #                 CompressionType.JSON,
    #             )

    #     def _export_metrics(self, metrics: List[PerformanceMetric]) -> None:
    #         """Export metrics to external systems"""
    #         # Export to Prometheus
            self.exporter.export_to_prometheus(metrics)

    #         # Export to Grafana if configured
    #         for config_name, config in self.exporter.export_configs.items():
    #             if config_name == "grafana":
                    self.exporter.export_to_grafana(
    #                     metrics,
                        config.get("url", "http://localhost:3000"),
                        config.get("api_key", ""),
    #                 )

    #     def _archive_old_metrics(self, metrics: List[PerformanceMetric]) -> None:
    #         """Archive older metrics based on retention policy"""
    #         # Archive metrics older than 7 days
    cutoff_time = math.subtract(datetime.now(), timedelta(days=7))

    #         old_metrics = [m for m in metrics if m.timestamp < cutoff_time]
    #         if old_metrics:
                self.archiver.archive_metrics(
    old_metrics, CompressionType.GZIP, retention_days = 365
    #             )

    #     def _analysis_loop(self) -> None:
    #         """Main analysis loop for background processing"""
    #         while self.running:
    #             try:
    #                 # Clean up expired archives
                    self.archiver.cleanup_expired_archives()

    #                 # Clear query cache periodically
    #                 if datetime.now().minute % 10 == 0:  # Every 10 minutes
                        self.query_engine.clear_cache()

                    time.sleep(60)  # Run every minute

    #             except Exception as e:
                    logger.error(f"Error in analysis loop: {e}")
                    time.sleep(60)

    #     def query_metrics(
    #         self,
    #         query: MetricsQuery,
    #         data_source: Callable[[str, datetime, datetime], List[PerformanceMetric]],
    #     ) -> pd.DataFrame:
    #         """Query metrics with advanced filtering and aggregation"""
            return self.query_engine.execute_query(query, data_source)

    #     def get_correlation_matrix(self, metric_names: List[str]) -> pd.DataFrame:
    #         """Get correlation matrix for specified metrics"""
            return self.correlator.calculate_correlation_matrix(metric_names)

    #     def get_dependency_graph(self, metric_names: List[str]) -> Dict[str, List[str]]:
    #         """Get dependency graph for specified metrics"""
            return self.correlator.detect_dependencies(metric_names)

    #     def get_bottlenecks(self, metrics: List[PerformanceMetric]) -> List[BottleneckInfo]:
    #         """Get detected bottlenecks"""
            return self.profiler.detect_bottlenecks(metrics)

    #     def get_predictions(self, metric_names: List[str]) -> List[PredictionResult]:
    #         """Get predictions for specified metrics"""
    predictions = []
    current_time = datetime.now()

    #         for name in metric_names:
    prediction = self.predictor.predict_metric(name, current_time)
    #             if prediction:
                    predictions.append(prediction)

    #         return predictions


# Global instance
_global_metrics_analysis: Optional[MetricsAnalysisSystem] = None


def get_metrics_analysis_system() -> MetricsAnalysisSystem:
#     """Get global metrics analysis system instance"""
#     global _global_metrics_analysis

#     if _global_metrics_analysis is None:
_global_metrics_analysis = MetricsAnalysisSystem()

#     return _global_metrics_analysis


def start_metrics_analysis() -> MetricsAnalysisSystem:
#     """Start the global metrics analysis system"""
system = get_metrics_analysis_system()
    system.start()
#     return system


def stop_metrics_analysis() -> None:
#     """Stop the global metrics analysis system"""
system = get_metrics_analysis_system()
    system.stop()
