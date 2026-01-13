# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Performance Regression Detection System for Noodle

# This module implements a comprehensive system for automatically detecting performance
# regressions compared to previous baselines or expected levels. It includes statistical
# analysis, automated detection, trend analysis, alerting, and reporting capabilities.
# """

import asyncio
import gzip
import json
import logging
import math
import pickle
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

import numpy as np
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import redis
import scipy.stats
import scipy.signal.find_peaks
import sklearn.linear_model.LinearRegression
import sklearn.preprocessing.StandardScaler

logger = logging.getLogger(__name__)


class RegressionSeverity(Enum)
    #     """Regression severity levels"""

    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class RegressionType(Enum)
    #     """Types of performance regressions"""

    SUDDEN_DROP = "sudden_drop"
    GRADUAL_DEGRADATION = "gradual_degradation"
    SPIKE = "spike"
    VOLATILITY_INCREASE = "volatility_increase"
    TREND_REVERSAL = "trend_reversal"


class TimeWindow(Enum)
    #     """Time windows for analysis"""

    LAST_5_MINUTES = "5m"
    LAST_15_MINUTES = "15m"
    LAST_30_MINUTES = "30m"
    LAST_HOUR = "1h"
    LAST_3_HOURS = "3h"
    LAST_6_HOURS = "6h"
    LAST_12_HOURS = "12h"
    LAST_24_HOURS = "24h"
    LAST_7_DAYS = "7d"
    LAST_30_DAYS = "30d"


# @dataclass
class BaselineConfig
    #     """Configuration for performance baselines"""

    #     metric_name: str
    #     time_window: TimeWindow
    aggregation_method: str = "median"  # mean, median, p95, p99
    #     sensitivity: float = 2.0  # Standard deviations for detection
    min_data_points: int = 10
    recalculation_interval: int = 3600  # seconds
    enabled: bool = True
    tags: Dict[str, str] = field(default_factory=dict)


# @dataclass
class RegressionConfig
    #     """Configuration for regression detection"""

    #     metric_name: str
    #     baseline_config: BaselineConfig
    #     regression_types: List[RegressionType]
    #     severity_thresholds: Dict[RegressionSeverity, float]
    cooldown_seconds: int = 300
    enabled: bool = True
    callback: Optional[Callable[[str, Dict[str, Any]], None]] = None
    tags: Dict[str, str] = field(default_factory=dict)


# @dataclass
class RegressionEvent
    #     """Represents a detected performance regression"""

    #     id: str
    #     metric_name: str
    #     regression_type: RegressionType
    #     severity: RegressionSeverity
    #     current_value: float
    #     baseline_value: float
    #     deviation_percent: float
    #     timestamp: datetime
    #     time_window: TimeWindow
    #     confidence: float
    description: str = ""
    suggested_actions: List[str] = field(default_factory=list)
    metadata: Dict[str, Any] = field(default_factory=dict)
    acknowledged: bool = False


# @dataclass
class TrendAnalysisResult
    #     """Result of trend analysis"""

    #     metric_name: str
    #     trend_direction: str  # "increasing", "decreasing", "stable"
    #     trend_strength: float  # 0.0 to 1.0
    #     change_rate: float
    #     prediction: float
    #     confidence_interval: Tuple[float, float]
    #     time_window: TimeWindow
    #     timestamp: datetime


class BaselineManager
    #     """Manages performance baselines for regression detection"""

    #     def __init__(self, storage_path: str = "baselines"):
    self.storage_path = Path(storage_path)
    self.storage_path.mkdir(parents = True, exist_ok=True)
    self.baselines: Dict[str, Dict[str, float]] = {}
    self.last_updates: Dict[str, datetime] = {}
    self.lock = threading.Lock()
    self.executor = ThreadPoolExecutor(max_workers=2)

    #         # Initialize SQLite database for persistent storage
    self.db_path = self.storage_path / "baselines.db"
            self._init_database()

    #     def _init_database(self):
    #         """Initialize SQLite database for baseline storage"""
    #         with sqlite3.connect(self.db_path) as conn:
                conn.execute(
    #                 """
                    CREATE TABLE IF NOT EXISTS baselines (
    #                     id INTEGER PRIMARY KEY AUTOINCREMENT,
    #                     metric_name TEXT NOT NULL,
    #                     time_window TEXT NOT NULL,
    #                     aggregation_method TEXT NOT NULL,
    #                     baseline_value REAL NOT NULL,
    #                     std_dev REAL,
    #                     min_value REAL,
    #                     max_value REAL,
    #                     p95 REAL,
    #                     p99 REAL,
    #                     data_points INTEGER,
    #                     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    #                     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    #                 )
    #             """
    #             )
                conn.execute(
    #                 """
    #                 CREATE INDEX IF NOT EXISTS idx_baselines_metric
                    ON baselines(metric_name, time_window)
    #             """
    #             )
                conn.commit()

    #     def establish_baseline(
    #         self, metrics: List[Dict[str, Any]], config: BaselineConfig
    #     ) -> Dict[str, float]:
    #         """Establish a performance baseline from historical metrics"""
    #         if not metrics:
    #             return {}

    #         # Filter metrics by time window
    end_time = datetime.now()
    time_delta_map = {
    TimeWindow.LAST_5_MINUTES: timedelta(minutes = 5),
    TimeWindow.LAST_15_MINUTES: timedelta(minutes = 15),
    TimeWindow.LAST_30_MINUTES: timedelta(minutes = 30),
    TimeWindow.LAST_HOUR: timedelta(hours = 1),
    TimeWindow.LAST_3_HOURS: timedelta(hours = 3),
    TimeWindow.LAST_6_HOURS: timedelta(hours = 6),
    TimeWindow.LAST_12_HOURS: timedelta(hours = 12),
    TimeWindow.LAST_24_HOURS: timedelta(hours = 24),
    TimeWindow.LAST_7_DAYS: timedelta(days = 7),
    TimeWindow.LAST_30_DAYS: timedelta(days = 30),
    #         }

    time_delta = time_delta_map.get(config.time_window, timedelta(hours=1))
    start_time = math.subtract(end_time, time_delta)

    #         # Filter metrics within time window
    relevant_metrics = [
    #             m
    #             for m in metrics
    #             if start_time <= datetime.fromisoformat(m["timestamp"]) <= end_time
    and m["name"] = = config.metric_name
    #         ]

    #         if len(relevant_metrics) < config.min_data_points:
                logger.warning(
    #                 f"Insufficient data points for baseline: {len(relevant_metrics)} < {config.min_data_points}"
    #             )
    #             return {}

    #         values = [m["value"] for m in relevant_metrics]

    #         # Calculate baseline statistics
    baseline_stats = {
                "mean": statistics.mean(values),
                "median": statistics.median(values),
    #             "std": statistics.stdev(values) if len(values) > 1 else 0,
                "min": min(values),
                "max": max(values),
                "p95": np.percentile(values, 95),
                "p99": np.percentile(values, 99),
                "count": len(values),
    #         }

    #         # Store baseline based on aggregation method
    baseline_value = baseline_stats[config.aggregation_method]

    baseline_key = f"{config.metric_name}_{config.time_window.value}"

    #         with self.lock:
    self.baselines[baseline_key] = baseline_stats
    self.last_updates[baseline_key] = datetime.now()

    #         # Store in database
    #         with sqlite3.connect(self.db_path) as conn:
                conn.execute(
    #                 """
    #                 INSERT OR REPLACE INTO baselines
                    (metric_name, time_window, aggregation_method, baseline_value, std_dev,
    #                  min_value, max_value, p95, p99, data_points, updated_at)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    #             """,
                    (
    #                     config.metric_name,
    #                     config.time_window.value,
    #                     config.aggregation_method,
    #                     baseline_value,
    #                     baseline_stats["std"],
    #                     baseline_stats["min"],
    #                     baseline_stats["max"],
    #                     baseline_stats["p95"],
    #                     baseline_stats["p99"],
    #                     baseline_stats["count"],
                        datetime.now().isoformat(),
    #                 ),
    #             )
                conn.commit()

            logger.info(
    #             f"Established baseline for {config.metric_name}: {baseline_value:.2f} ({config.aggregation_method})"
    #         )
    #         return baseline_stats

    #     def get_baseline(
    #         self,
    #         metric_name: str,
    #         time_window: TimeWindow,
    aggregation_method: str = "median",
    #     ) -> Optional[Dict[str, float]]:
    #         """Get baseline for a specific metric"""
    baseline_key = f"{metric_name}_{time_window.value}"

    #         # Check memory first
    #         with self.lock:
    #             if baseline_key in self.baselines:
    #                 return self.baselines[baseline_key]

    #         # Check database if not in memory
    #         with sqlite3.connect(self.db_path) as conn:
    cursor = conn.execute(
    #                 """
    #                 SELECT baseline_value, std_dev, min_value, max_value, p95, p99, data_points
    #                 FROM baselines
    WHERE metric_name = ? AND time_window = ? AND aggregation_method = ?
    #                 ORDER BY updated_at DESC LIMIT 1
    #             """,
                    (metric_name, time_window.value, aggregation_method),
    #             )

    row = cursor.fetchone()
    #             if row:
    baseline_stats = {
    #                     "mean": row[0],  # Using baseline_value as mean for compatibility
    #                     "median": row[0],
    #                     "std": row[1],
    #                     "min": row[2],
    #                     "max": row[3],
    #                     "p95": row[4],
    #                     "p99": row[5],
    #                     "count": row[6],
    #                 }

    #                 # Cache in memory
    #                 with self.lock:
    self.baselines[baseline_key] = baseline_stats
    self.last_updates[baseline_key] = datetime.now()

    #                 return baseline_stats

    #         return None

    #     def should_recalculate(self, config: BaselineConfig) -> bool:
    #         """Check if baseline should be recalculated"""
    baseline_key = f"{config.metric_name}_{config.time_window.value}"

    #         with self.lock:
    last_update = self.last_updates.get(baseline_key)

    #         if last_update is None:
    #             return True

    time_since_update = math.subtract((datetime.now(), last_update).total_seconds())
    #         return time_since_update > config.recalculation_interval

    #     def cleanup_old_baselines(self, max_age_days: int = 30):
    #         """Remove baselines older than specified days"""
    cutoff_date = math.subtract(datetime.now(), timedelta(days=max_age_days))

    #         with sqlite3.connect(self.db_path) as conn:
                conn.execute(
    #                 """
    #                 DELETE FROM baselines
                    WHERE datetime(updated_at) < ?
    #             """,
                    (cutoff_date.isoformat(),),
    #             )
                conn.commit()

            logger.info(f"Cleaned up baselines older than {max_age_days} days")


class RegressionDetector
    #     """Detects performance regressions using statistical methods"""

    #     def __init__(self, baseline_manager: BaselineManager):
    self.baseline_manager = baseline_manager
    self.regression_history: deque = deque(maxlen=1000)
    self.last_detections: Dict[str, datetime] = {}
    self.lock = threading.Lock()
    self.metric_windows: Dict[str, deque] = defaultdict(lambda: deque(maxlen=1000))

    #     def detect_regressions(
    #         self, metrics: List[Dict[str, Any]], configs: List[RegressionConfig]
    #     ) -> List[RegressionEvent]:
    #         """Detect regressions in metrics using baseline comparison"""
    regressions = []

    #         for metric in metrics:
    metric_name = metric["name"]
    current_value = metric["value"]
    timestamp = datetime.fromisoformat(metric["timestamp"])

    #             # Find relevant configs for this metric
    relevant_configs = [
    #                 c for c in configs if c.metric_name == metric_name and c.enabled
    #             ]

    #             for config in relevant_configs:
    regression_events = self._detect_metric_regressions(
    #                     metric_name, current_value, timestamp, config
    #                 )
                    regressions.extend(regression_events)

    #         # Store regressions
    #         with self.lock:
    #             for regression in regressions:
                    self.regression_history.append(regression)
    self.last_detections[regression.id] = regression.timestamp

    #         return regressions

    #     def _detect_metric_regressions(
    #         self,
    #         metric_name: str,
    #         current_value: float,
    #         timestamp: datetime,
    #         config: RegressionConfig,
    #     ) -> List[RegressionEvent]:
    #         """Detect regressions for a specific metric"""
    regressions = []

    #         # Check cooldown period
    last_detection = self.last_detections.get(config.metric_name)
    #         if (
    #             last_detection
                and (timestamp - last_detection).total_seconds() < config.cooldown_seconds
    #         ):
    #             return regressions

    #         # Get baseline
    baseline_stats = self.baseline_manager.get_baseline(
    #             metric_name,
    #             config.baseline_config.time_window,
    #             config.baseline_config.aggregation_method,
    #         )

    #         if not baseline_stats:
    #             return regressions

    baseline_value = baseline_stats[config.baseline_config.aggregation_method]

    #         # Update metric window for trend analysis
            self.metric_windows[metric_name].append((timestamp, current_value))

    #         # Check each regression type
    #         for regression_type in config.regression_types:
    regression = self._check_regression_type(
    #                 metric_name,
    #                 current_value,
    #                 baseline_value,
    #                 baseline_stats,
    #                 regression_type,
    #                 config,
    #                 timestamp,
    #             )

    #             if regression:
                    regressions.append(regression)

    #         return regressions

    #     def _check_regression_type(
    #         self,
    #         metric_name: str,
    #         current_value: float,
    #         baseline_value: float,
    #         baseline_stats: Dict[str, float],
    #         regression_type: RegressionType,
    #         config: RegressionConfig,
    #         timestamp: datetime,
    #     ) -> Optional[RegressionEvent]:
    #         """Check for a specific type of regression"""
    deviation = math.subtract(current_value, baseline_value)
    deviation_percent = (
    #             (deviation / baseline_value) * 100 if baseline_value != 0 else 0
    #         )

    #         # Calculate confidence based on data points and standard deviation
    confidence = min(
    #             1.0, baseline_stats["count"] / 100.0
    )  # More data = higher confidence

    #         if regression_type == RegressionType.SUDDEN_DROP:
    #             # Check for sudden drop using z-score
    #             if baseline_stats["std"] > 0:
    z_score = abs(deviation) / baseline_stats["std"]
    #                 if z_score > config.baseline_config.sensitivity and deviation < 0:
    severity = self._calculate_severity(
    #                         deviation_percent, config.severity_thresholds
    #                     )
                        return self._create_regression_event(
    #                         metric_name,
    #                         regression_type,
    #                         severity,
    #                         current_value,
    #                         baseline_value,
    #                         deviation_percent,
    #                         timestamp,
    #                         config.baseline_config.time_window,
    #                         confidence,
    #                         f"Sudden performance drop detected: {deviation_percent:.1f}% below baseline",
                            self._get_suggested_actions(regression_type, severity),
    #                         config,
    #                     )

    #         elif regression_type == RegressionType.GRADUAL_DEGRADATION:
    #             # Check for gradual degradation using trend analysis
    trend_result = self._analyze_trend(
    #                 metric_name, config.baseline_config.time_window
    #             )
    #             if trend_result and trend_result.trend_direction == "decreasing":
    severity = self._calculate_severity(
    #                     deviation_percent, config.severity_thresholds
    #                 )
                    return self._create_regression_event(
    #                     metric_name,
    #                     regression_type,
    #                     severity,
    #                     current_value,
    #                     baseline_value,
    #                     deviation_percent,
    #                     timestamp,
    #                     config.baseline_config.time_window,
    #                     confidence,
    #                     f"Gradual performance degradation detected: {trend_result.change_rate:.2f}/unit",
                        self._get_suggested_actions(regression_type, severity),
    #                     config,
    #                     {"trend_strength": trend_result.trend_strength},
    #                 )

    #         elif regression_type == RegressionType.SPIKE:
    #             # Check for unusual spikes
    #             if baseline_stats["std"] > 0:
    z_score = abs(deviation) / baseline_stats["std"]
    #                 if z_score > config.baseline_config.sensitivity * 1.5 and deviation > 0:
    severity = self._calculate_severity(
    #                         deviation_percent, config.severity_thresholds
    #                     )
                        return self._create_regression_event(
    #                         metric_name,
    #                         regression_type,
    #                         severity,
    #                         current_value,
    #                         baseline_value,
    #                         deviation_percent,
    #                         timestamp,
    #                         config.baseline_config.time_window,
    #                         confidence,
    #                         f"Unusual performance spike detected: {deviation_percent:.1f}% above baseline",
                            self._get_suggested_actions(regression_type, severity),
    #                         config,
    #                     )

    #         elif regression_type == RegressionType.VOLATILITY_INCREASE:
    #             # Check for increased volatility
    #             recent_values = [v for _, v in list(self.metric_windows[metric_name])[-50:]]
    #             if len(recent_values) > 10:
    recent_std = statistics.stdev(recent_values)
    baseline_std = baseline_stats["std"]

    #                 if baseline_std > 0 and recent_std > baseline_std * 2:
    severity = self._calculate_severity(
    #                         deviation_percent, config.severity_thresholds
    #                     )
                        return self._create_regression_event(
    #                         metric_name,
    #                         regression_type,
    #                         severity,
    #                         current_value,
    #                         baseline_value,
    #                         deviation_percent,
    #                         timestamp,
    #                         config.baseline_config.time_window,
    #                         confidence,
    #                         f"Increased volatility detected: {recent_std:.2f} vs baseline {baseline_std:.2f}",
                            self._get_suggested_actions(regression_type, severity),
    #                         config,
    #                         {"recent_std": recent_std, "baseline_std": baseline_std},
    #                     )

    #         elif regression_type == RegressionType.TREND_REVERSAL:
    #             # Check for trend reversal
    trend_result = self._analyze_trend(
    #                 metric_name, config.baseline_config.time_window
    #             )
    #             if trend_result and trend_result.trend_direction == "increasing":
    #                 # Check if previous trend was decreasing
    long_term_trend = self._analyze_trend(
    #                     metric_name, TimeWindow.LAST_7_DAYS
    #                 )
    #                 if long_term_trend and long_term_trend.trend_direction == "decreasing":
    severity = self._calculate_severity(
    #                         deviation_percent, config.severity_thresholds
    #                     )
                        return self._create_regression_event(
    #                         metric_name,
    #                         regression_type,
    #                         severity,
    #                         current_value,
    #                         baseline_value,
    #                         deviation_percent,
    #                         timestamp,
    #                         config.baseline_config.time_window,
    #                         confidence,
    #                         f"Trend reversal detected: performance increasing after previous decrease",
                            self._get_suggested_actions(regression_type, severity),
    #                         config,
    #                         {"trend_strength": trend_result.trend_strength},
    #                     )

    #         return None

    #     def _analyze_trend(
    #         self, metric_name: str, time_window: TimeWindow
    #     ) -> Optional[TrendAnalysisResult]:
    #         """Analyze trend for a metric"""
    #         if (
    #             metric_name not in self.metric_windows
                or len(self.metric_windows[metric_name]) < 10
    #         ):
    #             return None

    #         # Get recent data points
    data_points = math.subtract(list(self.metric_windows[metric_name])[, 100:]  # Last 100 points)
    timestamps, values = math.multiply(zip(, data_points))

    #         # Convert timestamps to numeric values for regression
    #         timestamps_numeric = [(t - timestamps[0]).total_seconds() for t in timestamps]

    #         # Perform linear regression
    X = math.subtract(np.array(timestamps_numeric).reshape(, 1, 1))
    y = np.array(values)

    model = LinearRegression()
            model.fit(X, y)

            # Calculate trend strength (R² score)
    y_pred = model.predict(X)
    ss_res = math.multiply(np.sum((y - y_pred), * 2))
    ss_tot = math.multiply(np.sum((y - np.mean(y)), * 2))
    #         r_squared = 1 - (ss_res / ss_tot) if ss_tot > 0 else 0

    #         # Determine trend direction
    slope = model.coef_[0]
    trend_direction = (
    #             "increasing" if slope > 0 else "decreasing" if slope < 0 else "stable"
    #         )

    #         # Calculate change rate
    change_rate = slope

    #         # Make prediction
    last_timestamp = math.subtract(timestamps[, 1])
    next_timestamp = math.add(last_timestamp, timedelta(minutes=30))
    prediction_time = math.subtract((next_timestamp, timestamps[0]).total_seconds())
    prediction = model.predict([[prediction_time]])[0]

    #         # Calculate confidence interval
    residuals = math.subtract(y, y_pred)
    mse = math.multiply(np.mean(residuals, *2))
    se = math.multiply(np.sqrt(mse), np.sqrt()
    #             1
                + 1 / len(X)
                + (prediction_time - np.mean(X)) ** 2 / np.sum((X - np.mean(X)) ** 2)
    #         )

    #         # 95% confidence interval
    t_value = math.subtract(stats.t.ppf(0.975, len(X), 2))
    confidence_interval = math.add((prediction - t_value * se, prediction, t_value * se))

            return TrendAnalysisResult(
    metric_name = metric_name,
    trend_direction = trend_direction,
    trend_strength = r_squared,
    change_rate = change_rate,
    prediction = prediction,
    confidence_interval = confidence_interval,
    time_window = time_window,
    timestamp = datetime.now(),
    #         )

    #     def _calculate_severity(
    #         self, deviation_percent: float, thresholds: Dict[RegressionSeverity, float]
    #     ) -> RegressionSeverity:
    #         """Calculate regression severity based on deviation percentage"""
    #         if deviation_percent >= thresholds.get(RegressionSeverity.CRITICAL, 20):
    #             return RegressionSeverity.CRITICAL
    #         elif deviation_percent >= thresholds.get(RegressionSeverity.HIGH, 10):
    #             return RegressionSeverity.HIGH
    #         elif deviation_percent >= thresholds.get(RegressionSeverity.MEDIUM, 5):
    #             return RegressionSeverity.MEDIUM
    #         else:
    #             return RegressionSeverity.LOW

    #     def _create_regression_event(
    #         self,
    #         metric_name: str,
    #         regression_type: RegressionType,
    #         severity: RegressionSeverity,
    #         current_value: float,
    #         baseline_value: float,
    #         deviation_percent: float,
    #         timestamp: datetime,
    #         time_window: TimeWindow,
    #         confidence: float,
    #         description: str,
    #         suggested_actions: List[str],
    #         config: RegressionConfig,
    metadata: Optional[Dict[str, Any]] = None,
    #     ) -> RegressionEvent:
    #         """Create a regression event"""
    event_id = str(uuid.uuid4())

    regression_event = RegressionEvent(
    id = event_id,
    metric_name = metric_name,
    regression_type = regression_type,
    severity = severity,
    current_value = current_value,
    baseline_value = baseline_value,
    deviation_percent = deviation_percent,
    timestamp = timestamp,
    time_window = time_window,
    confidence = confidence,
    description = description,
    suggested_actions = suggested_actions,
    metadata = metadata or {},
    acknowledged = False,
    #         )

    #         # Execute callback if provided
    #         if config.callback:
    #             try:
                    config.callback(str(regression_event), regression_event.__dict__)
    #             except Exception as e:
                    logger.error(f"Error executing regression callback: {e}")

    #         return regression_event

    #     def _get_suggested_actions(
    #         self, regression_type: RegressionType, severity: RegressionSeverity
    #     ) -> List[str]:
    #         """Get suggested actions for a regression"""
    actions = []

    #         if regression_type == RegressionType.SUDDEN_DROP:
                actions.extend(
    #                 [
    #                     "Check for recent code changes or deployments",
                        "Verify system resources (CPU, memory, disk)",
    #                     "Review recent logs for errors or warnings",
    #                     "Check network connectivity and latency",
    #                 ]
    #             )

    #         elif regression_type == RegressionType.GRADUAL_DEGRADATION:
                actions.extend(
    #                 [
    #                     "Review query optimization opportunities",
    #                     "Check for memory leaks or resource accumulation",
    #                     "Analyze long-term trends in system usage",
    #                     "Consider scaling or resource allocation adjustments",
    #                 ]
    #             )

    #         elif regression_type == RegressionType.SPIKE:
                actions.extend(
    #                 [
    #                     "Check for temporary load spikes or anomalies",
    #                     "Review caching effectiveness",
    #                     "Check for garbage collection or cleanup issues",
    #                     "Verify external service dependencies",
    #                 ]
    #             )

    #         elif regression_type == RegressionType.VOLATILITY_INCREASE:
                actions.extend(
    #                 [
    #                     "Review system stability and error rates",
    #                     "Check for inconsistent resource allocation",
    #                     "Analyze timing dependencies or race conditions",
    #                     "Review monitoring and alerting thresholds",
    #                 ]
    #             )

    #         elif regression_type == RegressionType.TREND_REVERSAL:
                actions.extend(
    #                 [
    #                     "Investigate recent changes that may have improved performance",
    #                     "Document optimization successes for future reference",
    #                     "Check if temporary fixes were applied",
    #                     "Verify if performance improvements are sustainable",
    #                 ]
    #             )

    #         # Adjust actions based on severity
    #         if severity in [RegressionSeverity.HIGH, RegressionSeverity.CRITICAL]:
                actions.insert(0, "Immediate investigation required")

    #         return actions

    #     def get_regression_history(
    #         self,
    metric_name: Optional[str] = None,
    severity: Optional[RegressionSeverity] = None,
    limit: int = 100,
    #     ) -> List[RegressionEvent]:
    #         """Get regression history with optional filtering"""
    #         with self.lock:
    history = list(self.regression_history)

    #         if metric_name:
    #             history = [r for r in history if r.metric_name == metric_name]

    #         if severity:
    #             history = [r for r in history if r.severity == severity]

    return sorted(history, key = lambda r: r.timestamp, reverse=True)[:limit]

    #     def acknowledge_regression(self, regression_id: str) -> bool:
    #         """Acknowledge a regression event"""
    #         with self.lock:
    #             for regression in self.regression_history:
    #                 if regression.id == regression_id:
    regression.acknowledged = True
                        logger.info(f"Acknowledged regression: {regression_id}")
    #                     return True
    #         return False


class RegressionReporter
    #     """Generates reports and visualizations for performance regressions"""

    #     def __init__(self, baseline_manager: BaselineManager, detector: RegressionDetector):
    self.baseline_manager = baseline_manager
    self.detector = detector

    #     def generate_regression_report(
    #         self,
    metric_name: Optional[str] = None,
    start_time: Optional[datetime] = None,
    end_time: Optional[datetime] = None,
    #     ) -> Dict[str, Any]:
    #         """Generate a comprehensive regression report"""
    #         if start_time is None:
    start_time = math.subtract(datetime.now(), timedelta(days=7))

    #         if end_time is None:
    end_time = datetime.now()

    #         # Get regression history
    regressions = self.detector.get_regression_history(
    metric_name = metric_name, limit=1000
    #         )

    #         # Filter by time range
    #         regressions = [r for r in regressions if start_time <= r.timestamp <= end_time]

    #         # Group by metric
    metric_regressions = defaultdict(list)
    #         for regression in regressions:
                metric_regressions[regression.metric_name].append(regression)

    #         # Generate report
    report = {
                "report_timestamp": datetime.now().isoformat(),
    #             "time_range": {
                    "start": start_time.isoformat(),
                    "end": end_time.isoformat(),
    #             },
                "total_regressions": len(regressions),
                "metrics_affected": len(metric_regressions),
                "severity_distribution": defaultdict(int),
                "regression_type_distribution": defaultdict(int),
    #             "metric_summary": {},
    #             "top_regressions": [],
    #             "recommendations": [],
    #         }

    #         # Calculate distributions
    #         for regression in regressions:
    report["severity_distribution"][regression.severity.value] + = 1
    #             report["regression_type_distribution"][
    #                 regression.regression_type.value
    ] + = 1

    #         # Generate metric summaries
    #         for metric_name, metric_regs in metric_regressions.items():
    summary = {
                    "regression_count": len(metric_regs),
                    "avg_deviation": statistics.mean(
    #                     [r.deviation_percent for r in metric_regs]
    #                 ),
    #                 "max_deviation": max([r.deviation_percent for r in metric_regs]),
                    "severity_breakdown": defaultdict(int),
                    "recent_regression": (
    #                     max([r.timestamp for r in metric_regs]).isoformat()
    #                     if metric_regs
    #                     else None
    #                 ),
    #             }

    #             for reg in metric_regs:
    summary["severity_breakdown"][reg.severity.value] + = 1

    report["metric_summary"][metric_name] = summary

    #         # Get top regressions by severity and recency
    sorted_regressions = sorted(
    regressions, key = lambda r: (r.severity.value, r.timestamp), reverse=True
    #         )

    #         for regression in sorted_regressions[:10]:  # Top 10
                report["top_regressions"].append(
    #                 {
    #                     "id": regression.id,
    #                     "metric_name": regression.metric_name,
    #                     "regression_type": regression.regression_type.value,
    #                     "severity": regression.severity.value,
    #                     "deviation_percent": regression.deviation_percent,
                        "timestamp": regression.timestamp.isoformat(),
    #                     "description": regression.description,
    #                     "suggested_actions": regression.suggested_actions,
    #                 }
    #             )

    #         # Generate recommendations
    report["recommendations"] = self._generate_recommendations(metric_regressions)

    #         return report

    #     def _generate_recommendations(
    #         self, metric_regressions: Dict[str, List[RegressionEvent]]
    #     ) -> List[str]:
    #         """Generate recommendations based on regression patterns"""
    recommendations = []

    #         # Check for frequently regressing metrics
    #         for metric_name, regressions in metric_regressions.items():
    #             if len(regressions) > 5:  # More than 5 regressions
                    recommendations.append(
    #                     f"Metric '{metric_name}' shows frequent regressions. Consider "
    #                     f"implementing additional monitoring or optimization."
    #                 )

    #         # Check for critical severity regressions
    critical_regressions = [
    #             r
    #             for r in sum(metric_regressions.values(), [])
    #             if r.severity == RegressionSeverity.CRITICAL
    #         ]

    #         if critical_regressions:
                recommendations.append(
                    f"Found {len(critical_regressions)} critical regressions requiring "
    #                 f"immediate attention and investigation."
    #             )

    #         # Check for gradual degradation patterns
    gradual_degradations = [
    #             r
    #             for r in sum(metric_regressions.values(), [])
    #             if r.regression_type == RegressionType.GRADUAL_DEGRADATION
    #         ]

    #         if gradual_degradations:
                recommendations.append(
    #                 "Detected gradual degradation patterns. Consider implementing "
    #                 "proactive monitoring and performance optimization routines."
    #             )

    #         return recommendations

    #     def create_regression_visualization(
    #         self,
    #         metric_name: str,
    start_time: Optional[datetime] = None,
    end_time: Optional[datetime] = None,
    #     ) -> str:
    #         """Create a visualization for regression analysis"""
    #         if start_time is None:
    start_time = math.subtract(datetime.now(), timedelta(days=7))

    #         if end_time is None:
    end_time = datetime.now()

            # Get historical metrics (this would typically come from a metrics store)
    #         # For now, we'll create a placeholder visualization
    fig = go.Figure()

    #         # Add title
            fig.update_layout(
    title = f"Performance Regression Analysis: {metric_name}",
    xaxis_title = "Time",
    yaxis_title = "Value",
    height = 600,
    #         )

    #         # Add empty trace with message
            fig.add_annotation(
    text = "Regression visualization requires historical metrics data",
    xref = "paper",
    yref = "paper",
    x = 0.5,
    y = 0.5,
    showarrow = False,
    font = dict(size=16),
    #         )

    return fig.to_html(include_plotlyjs = "cdn", div_id="regression-visualization")


class RegressionIntegration
    #     """Integrates regression detection with existing monitoring systems"""

    #     def __init__(
    #         self,
    #         baseline_manager: BaselineManager,
    #         detector: RegressionDetector,
    #         reporter: RegressionReporter,
    #     ):
    self.baseline_manager = baseline_manager
    self.detector = detector
    self.reporter = reporter
    self.redis_client = None
    self.integration_configs = {}

    #     def setup_redis_integration(self, host: str = "localhost", port: int = 6379):
    #         """Setup Redis integration for distributed regression detection"""
    #         try:
    self.redis_client = redis.Redis(host=host, port=port, decode_responses=True)
    #             logger.info("Redis integration initialized for regression detection")
    #         except Exception as e:
                logger.error(f"Failed to initialize Redis integration: {e}")

    #     def setup_prometheus_integration(self, endpoint: str = "http://localhost:9090"):
    #         """Setup Prometheus integration for metrics collection"""
    self.prometheus_endpoint = endpoint
    #         logger.info(f"Prometheus integration configured for endpoint: {endpoint}")

    #     async def collect_metrics_from_redis(
    self, channels: List[str], timeout: int = 30
    #     ) -> List[Dict[str, Any]]:
    #         """Collect metrics from Redis channels"""
    #         if not self.redis_client:
    #             return []

    metrics = []
    #         try:
    #             # Subscribe to channels
    pubsub = self.redis_client.pubsub()
    #             for channel in channels:
                    pubsub.subscribe(channel)

    #             # Collect messages for specified timeout
    start_time = time.time()
    #             for message in pubsub.listen():
    #                 if time.time() - start_time > timeout:
    #                     break

    #                 if message["type"] == "message":
    #                     try:
    metric_data = json.loads(message["data"])
                            metrics.append(metric_data)
                        except (json.JSONDecodeError, KeyError) as e:
                            logger.warning(f"Error parsing Redis message: {e}")

                pubsub.unsubscribe()
    #         except Exception as e:
                logger.error(f"Error collecting metrics from Redis: {e}")

    #         return metrics

    #     async def collect_metrics_from_prometheus(
    #         self,
    #         queries: List[str],
    #         start_time: datetime,
    #         end_time: datetime,
    step: str = "1m",
    #     ) -> List[Dict[str, Any]]:
    #         """Collect metrics from Prometheus using range queries"""
    #         if not hasattr(self, "prometheus_endpoint"):
    #             return []

    metrics = []
    #         try:
    #             async with aiohttp.ClientSession() as session:
    #                 for query in queries:
    params = {
    #                         "query": query,
                            "start": start_time.isoformat(),
                            "end": end_time.isoformat(),
    #                         "step": step,
    #                     }

    #                     async with session.get(
    f"{self.prometheus_endpoint}/api/v1/query_range", params = params
    #                     ) as response:
    #                         if response.status == 200:
    data = await response.json()
    #                             if data["status"] == "success":
    #                                 # Convert Prometheus response to our format
    #                                 for result in data["data"]["result"]:
    metric_name = result["metric"]["__name__"]
    #                                     for value in result["values"]:
    timestamp = datetime.fromisoformat(value[0])
                                            metrics.append(
    #                                             {
    #                                                 "name": metric_name,
                                                    "value": float(value[1]),
                                                    "timestamp": timestamp.isoformat(),
    #                                                 "tags": {
    #                                                     k: v
    #                                                     for k, v in result["metric"].items()
    #                                                     if k != "__name__"
    #                                                 },
    #                                             }
    #                                         )
    #         except Exception as e:
                logger.error(f"Error collecting metrics from Prometheus: {e}")

    #         return metrics

    #     def setup_alert_webhook(
    self, webhook_url: str, headers: Optional[Dict[str, str]] = None
    #     ):
    #         """Setup webhook integration for regression alerts"""
    self.webhook_url = webhook_url
    self.webhook_headers = headers or {}
    #         logger.info(f"Webhook integration configured for URL: {webhook_url}")

    #     async def send_regression_alert(self, regression: RegressionEvent):
    #         """Send regression alert via webhook"""
    #         if not hasattr(self, "webhook_url"):
    #             return

    alert_data = {
    #             "alert_id": regression.id,
    #             "metric_name": regression.metric_name,
    #             "regression_type": regression.regression_type.value,
    #             "severity": regression.severity.value,
    #             "current_value": regression.current_value,
    #             "baseline_value": regression.baseline_value,
    #             "deviation_percent": regression.deviation_percent,
                "timestamp": regression.timestamp.isoformat(),
    #             "description": regression.description,
    #             "suggested_actions": regression.suggested_actions,
    #         }

    #         try:
    #             async with aiohttp.ClientSession() as session:
    #                 async with session.post(
    self.webhook_url, json = alert_data, headers=self.webhook_headers
    #                 ) as response:
    #                     if response.status == 200:
                            logger.info(
    #                             f"Regression alert sent successfully: {regression.id}"
    #                         )
    #                     else:
                            logger.warning(
    #                             f"Failed to send regression alert: {response.status}"
    #                         )
    #         except Exception as e:
                logger.error(f"Error sending regression alert: {e}")

    #     def setup_slack_integration(self, webhook_url: str, channel: str = "#alerts"):
    #         """Setup Slack integration for regression notifications"""
    self.slack_webhook_url = webhook_url
    self.slack_channel = channel
    #         logger.info(f"Slack integration configured for channel: {channel}")

    #     async def send_slack_notification(self, regression: RegressionEvent):
    #         """Send regression notification to Slack"""
    #         if not hasattr(self, "slack_webhook_url"):
    #             return

    #         # Create Slack message
    color_map = {
    #             RegressionSeverity.LOW: "good",
    #             RegressionSeverity.MEDIUM: "warning",
    #             RegressionSeverity.HIGH: "danger",
    #             RegressionSeverity.CRITICAL: "danger",
    #         }

    message = {
    #             "channel": self.slack_channel,
    #             "attachments": [
    #                 {
    #                     "color": color_map[regression.severity],
    #                     "title": f"Performance Regression Detected: {regression.metric_name}",
    #                     "text": regression.description,
    #                     "fields": [
    #                         {
    #                             "title": "Regression Type",
    #                             "value": regression.regression_type.value,
    #                             "short": True,
    #                         },
    #                         {
    #                             "title": "Severity",
    #                             "value": regression.severity.value,
    #                             "short": True,
    #                         },
    #                         {
    #                             "title": "Current Value",
                                "value": str(regression.current_value),
    #                             "short": True,
    #                         },
    #                         {
    #                             "title": "Baseline Value",
                                "value": str(regression.baseline_value),
    #                             "short": True,
    #                         },
    #                         {
    #                             "title": "Deviation",
    #                             "value": f"{regression.deviation_percent:.1f}%",
    #                             "short": True,
    #                         },
    #                         {
    #                             "title": "Time",
                                "value": regression.timestamp.strftime("%Y-%m-%d %H:%M:%S"),
    #                             "short": True,
    #                         },
    #                     ],
    #                     "footer": "Noodle Performance Monitor",
                        "ts": int(regression.timestamp.timestamp()),
    #                 }
    #             ],
    #         }

    #         try:
    #             async with aiohttp.ClientSession() as session:
    #                 async with session.post(
    self.slack_webhook_url, json = message
    #                 ) as response:
    #                     if response.status == 200:
                            logger.info(
    #                             f"Slack notification sent for regression: {regression.id}"
    #                         )
    #                     else:
                            logger.warning(
    #                             f"Failed to send Slack notification: {response.status}"
    #                         )
    #         except Exception as e:
                logger.error(f"Error sending Slack notification: {e}")


class RegressionFixVerifier
    #     """Verifies that regression fixes have resolved performance issues"""

    #     def __init__(self, baseline_manager: BaselineManager, detector: RegressionDetector):
    self.baseline_manager = baseline_manager
    self.detector = detector
    self.fix_verification_history: deque = deque(maxlen=500)
    self.lock = threading.Lock()

    #     def verify_regression_fix(
    #         self,
    #         regression_id: str,
    verification_window: TimeWindow = TimeWindow.LAST_3_HOURS,
    improvement_threshold: float = 5.0,
    #     ) -> Dict[str, Any]:
    #         """Verify that a regression has been fixed"""
    #         # Get the original regression
    original_regression = None
    #         with self.detector.lock:
    #             for reg in self.detector.regression_history:
    #                 if reg.id == regression_id:
    original_regression = reg
    #                     break

    #         if not original_regression:
    #             return {"status": "error", "message": "Regression not found"}

    #         # Get current metrics for the regression metric
    current_time = datetime.now()
    start_time = math.subtract(current_time, self._get_time_delta(verification_window))

    #         # In a real implementation, this would fetch actual metrics
    #         # For now, we'll simulate the verification process
    current_metrics = self._get_current_metrics(
    #             original_regression.metric_name, start_time, current_time
    #         )

    #         if not current_metrics:
    #             return {"status": "error", "message": "No current metrics available"}

    #         # Compare with baseline
    baseline_stats = self.baseline_manager.get_baseline(
    #             original_regression.metric_name,
    #             original_regression.time_window,
                original_regression.metadata.get("aggregation_method", "median"),
    #         )

    #         if not baseline_stats:
    #             return {"status": "error", "message": "Baseline not available"}

    baseline_value = baseline_stats[
                original_regression.metadata.get("aggregation_method", "median")
    #         ]
    #         current_value = statistics.mean([m["value"] for m in current_metrics])

    #         # Calculate improvement
    deviation_before = original_regression.deviation_percent
    deviation_after = math.multiply(((current_value - baseline_value) / baseline_value), 100)

    improvement = math.subtract(abs(deviation_before), abs(deviation_after))

    #         # Determine if fix was successful
    fix_successful = improvement >= improvement_threshold

    verification_result = {
    #             "regression_id": regression_id,
    #             "metric_name": original_regression.metric_name,
    #             "fix_successful": fix_successful,
    #             "improvement_percent": improvement,
    #             "deviation_before": deviation_before,
    #             "deviation_after": deviation_after,
    #             "current_value": current_value,
    #             "baseline_value": baseline_value,
                "verification_timestamp": current_time.isoformat(),
    #             "verification_window": verification_window.value,
                "recommendation": (
    #                 "Fix verified" if fix_successful else "Further investigation needed"
    #             ),
    #         }

    #         # Store verification result
    #         with self.lock:
                self.fix_verification_history.append(verification_result)

    #         return verification_result

    #     def _get_time_delta(self, time_window: TimeWindow) -> timedelta:
    #         """Get timedelta for a time window"""
    time_delta_map = {
    TimeWindow.LAST_5_MINUTES: timedelta(minutes = 5),
    TimeWindow.LAST_15_MINUTES: timedelta(minutes = 15),
    TimeWindow.LAST_30_MINUTES: timedelta(minutes = 30),
    TimeWindow.LAST_HOUR: timedelta(hours = 1),
    TimeWindow.LAST_3_HOURS: timedelta(hours = 3),
    TimeWindow.LAST_6_HOURS: timedelta(hours = 6),
    TimeWindow.LAST_12_HOURS: timedelta(hours = 12),
    TimeWindow.LAST_24_HOURS: timedelta(hours = 24),
    TimeWindow.LAST_7_DAYS: timedelta(days = 7),
    TimeWindow.LAST_30_DAYS: timedelta(days = 30),
    #         }
    return time_delta_map.get(time_window, timedelta(hours = 1))

    #     def _get_current_metrics(
    #         self, metric_name: str, start_time: datetime, end_time: datetime
    #     ) -> List[Dict[str, Any]]:
    #         """Get current metrics for verification (placeholder implementation)"""
    #         # In a real implementation, this would fetch metrics from a time-series database
    #         # For now, return empty list to simulate no current metrics
    #         return []

    #     def get_fix_verification_summary(self, limit: int = 50) -> Dict[str, Any]:
    #         """Get summary of fix verification results"""
    #         with self.lock:
    history = list(self.fix_verification_history)

    #         if not history:
    #             return {"total_verifications": 0, "success_rate": 0}

    #         successful_fixes = sum(1 for v in history if v["fix_successful"])
    success_rate = math.multiply((successful_fixes / len(history)), 100)

    #         return {
                "total_verifications": len(history),
    #             "successful_fixes": successful_fixes,
    #             "success_rate": success_rate,
                "average_improvement": (
    #                 statistics.mean([v["improvement_percent"] for v in history])
    #                 if history
    #                 else 0
    #             ),
    #             "recent_verifications": history[:limit],
    #         }


class PerformanceRegressionDetector
    #     """Main performance regression detection system"""

    #     def __init__(self, storage_path: str = "regression_detection"):
    self.storage_path = Path(storage_path)
    self.storage_path.mkdir(parents = True, exist_ok=True)

    #         # Initialize components
    self.baseline_manager = BaselineManager(str(self.storage_path))
    self.detector = RegressionDetector(self.baseline_manager)
    self.reporter = RegressionReporter(self.baseline_manager, self.detector)
    self.integration = RegressionIntegration(
    #             self.baseline_manager, self.detector, self.reporter
    #         )
    self.fix_verifier = RegressionFixVerifier(self.baseline_manager, self.detector)

    #         # Configuration
    self.regression_configs: List[RegressionConfig] = []
    self.baseline_configs: List[BaselineConfig] = []
    self.running = False
    self.monitoring_thread = None
    self.monitoring_interval = 300  # 5 minutes

            logger.info("Performance regression detection system initialized")

    #     def add_baseline_config(self, config: BaselineConfig):
    #         """Add a baseline configuration"""
            self.baseline_configs.append(config)
    #         logger.info(f"Added baseline config for {config.metric_name}")

    #     def add_regression_config(self, config: RegressionConfig):
    #         """Add a regression detection configuration"""
            self.regression_configs.append(config)
    #         logger.info(f"Added regression config for {config.metric_name}")

    #     def setup_integrations(
    #         self,
    redis_config: Optional[Dict[str, Any]] = None,
    prometheus_config: Optional[Dict[str, Any]] = None,
    webhook_config: Optional[Dict[str, Any]] = None,
    slack_config: Optional[Dict[str, Any]] = None,
    #     ):
    #         """Setup external integrations"""
    #         if redis_config:
                self.integration.setup_redis_integration(
    host = redis_config.get("host", "localhost"),
    port = redis_config.get("port", 6379),
    #             )

    #         if prometheus_config:
                self.integration.setup_prometheus_integration(
    endpoint = prometheus_config.get("endpoint", "http://localhost:9090")
    #             )

    #         if webhook_config:
                self.integration.setup_alert_webhook(
    webhook_url = webhook_config["url"], headers=webhook_config.get("headers")
    #             )

    #         if slack_config:
                self.integration.setup_slack_integration(
    webhook_url = slack_config["url"],
    channel = slack_config.get("channel", "#alerts"),
    #             )

    #     def start(self):
    #         """Start the regression detection system"""
    #         if self.running:
    #             return

    self.running = True
    self.monitoring_thread = threading.Thread(
    target = self._monitoring_loop, daemon=True
    #         )
            self.monitoring_thread.start()
            logger.info("Performance regression detection system started")

    #     def stop(self):
    #         """Stop the regression detection system"""
    self.running = False
    #         if self.monitoring_thread:
    self.monitoring_thread.join(timeout = 5.0)
            logger.info("Performance regression detection system stopped")

    #     def _monitoring_loop(self):
    #         """Main monitoring loop for regression detection"""
    #         while self.running:
    #             try:
                    # Collect metrics (placeholder - would normally fetch from monitoring system)
    metrics = self._collect_metrics()

    #                 # Update baselines if needed
    #                 for config in self.baseline_configs:
    #                     if self.baseline_manager.should_recalculate(config):
                            self.baseline_manager.establish_baseline(metrics, config)

    #                 # Detect regressions
    regressions = self.detector.detect_regressions(
    #                     metrics, self.regression_configs
    #                 )

    #                 # Send notifications for new regressions
    #                 for regression in regressions:
                        asyncio.run(self._send_notifications(regression))

                    time.sleep(self.monitoring_interval)

    #             except Exception as e:
                    logger.error(f"Error in regression detection monitoring loop: {e}")
                    time.sleep(self.monitoring_interval)

    #     async def _send_notifications(self, regression: RegressionEvent):
    #         """Send notifications for a regression"""
    #         # Send webhook notification
            await self.integration.send_regression_alert(regression)

    #         # Send Slack notification
            await self.integration.send_slack_notification(regression)

    #     def _collect_metrics(self) -> List[Dict[str, Any]]:
    #         """Collect metrics for regression detection (placeholder implementation)"""
    #         # In a real implementation, this would fetch metrics from monitoring systems
    #         # For now, return empty list
    #         return []

    #     def get_regression_report(self, **kwargs) -> Dict[str, Any]:
    #         """Generate a regression report"""
            return self.reporter.generate_regression_report(**kwargs)

    #     def get_regression_visualization(self, **kwargs) -> str:
    #         """Generate a regression visualization"""
            return self.reporter.create_regression_visualization(**kwargs)

    #     def verify_regression_fix(self, regression_id: str, **kwargs) -> Dict[str, Any]:
    #         """Verify that a regression has been fixed"""
            return self.fix_verifier.verify_regression_fix(regression_id, **kwargs)

    #     def get_fix_verification_summary(self) -> Dict[str, Any]:
    #         """Get summary of fix verification results"""
            return self.fix_verifier.get_fix_verification_summary()

    #     def cleanup_old_data(self, max_age_days: int = 30):
    #         """Clean up old regression data"""
            self.baseline_manager.cleanup_old_baselines(max_age_days)

    #         # Clean up regression history
    cutoff_date = math.subtract(datetime.now(), timedelta(days=max_age_days))
    #         with self.detector.lock:
    self.detector.regression_history = deque(
    #                 [
    #                     r
    #                     for r in self.detector.regression_history
    #                     if r.timestamp > cutoff_date
    #                 ],
    maxlen = 1000,
    #             )

            logger.info(f"Cleaned up regression data older than {max_age_days} days")


# Global instance
_global_regression_detector: Optional[PerformanceRegressionDetector] = None


def get_regression_detector(
storage_path: str = "regression_detection",
# ) -> PerformanceRegressionDetector:
#     """Get global regression detector instance"""
#     global _global_regression_detector

#     if _global_regression_detector is None:
_global_regression_detector = PerformanceRegressionDetector(storage_path)

#     return _global_regression_detector


def start_regression_detection(
storage_path: str = "regression_detection",
# ) -> PerformanceRegressionDetector:
#     """Start the global regression detection system"""
detector = get_regression_detector(storage_path)
    detector.start()
#     return detector


function stop_regression_detection()
    #     """Stop the global regression detection system"""
    detector = get_regression_detector()
        detector.stop()
