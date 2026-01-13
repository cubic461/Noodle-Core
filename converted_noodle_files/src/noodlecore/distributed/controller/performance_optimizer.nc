# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Performance Optimizer for NoodleCore Distributed System.

# This module provides NBC runtime optimization and performance monitoring
# for the distributed AI task management system.
# """

import asyncio
import json
import time
import datetime.datetime,
import pathlib.Path
import typing.Dict,
import dataclasses.dataclass
import collections.deque
import threading

import ..utils.logging_utils.LoggingUtils


# @dataclass
class PerformanceMetrics
    #     """Performance metrics data structure."""
    #     timestamp: datetime
    #     cpu_usage: float  # 0.0 to 1.0
    #     memory_usage: float  # 0.0 to 1.0
    #     network_latency: float  # seconds
    #     task_throughput: float  # tasks per minute
    #     error_rate: float  # 0.0 to 1.0
    #     response_time: float  # seconds
    #     active_connections: int
    #     queue_depth: int


class PerformanceOptimizer
    #     """
    #     Performance optimizer with NBC runtime integration.

    #     This class provides real-time performance monitoring, optimization
    #     recommendations, and system health assessment using NoodleCore's
    #     NBC runtime for matrix operations and performance calculations.
    #     """

    #     def __init__(self, workspace_path: Path):
    #         """
    #         Initialize the performance optimizer.

    #         Args:
    #             workspace_path: Path to workspace for metrics storage
    #         """
    self.workspace = workspace_path / "distributed_system"
    self.metrics_file = self.workspace / "metrics" / "performance.json"
    self.optimization_file = self.workspace / "metrics" / "optimization.json"

    self.initialized = False
    self.monitoring = False
    self.optimization_enabled = True

    #         # Metrics storage
    self.metrics_history: deque = deque(maxlen=1000)  # Keep last 1000 metrics
    self.optimization_recommendations: List[Dict[str, Any]] = []

    #         # Performance thresholds
    self.thresholds = {
    #             "cpu_usage": 0.8,
    #             "memory_usage": 0.8,
    #             "network_latency": 0.1,
    #             "error_rate": 0.05,
    #             "response_time": 1.0,
    #             "queue_depth": 100
    #         }

    #         # NBC runtime integration
    self.nbc_available = self._check_nbc_availability()

    #         # Threading for monitoring
    self.monitoring_thread: Optional[threading.Thread] = None
    self.stop_event = threading.Event()

    #         # Setup logging
    self.logger = LoggingUtils.get_logger("noodlecore.distributed.performance")

    #         # Performance statistics
    self.stats = {
    #             "total_measurements": 0,
    #             "optimizations_applied": 0,
    #             "alerts_generated": 0,
    #             "start_time": None,
    #             "last_optimization": None
    #         }

    #     def _check_nbc_availability(self) -> bool:
    #         """Check if NoodleCore NBC runtime is available."""
    #         try:
    #             # Try to import NBC-related modules (placeholder for actual implementation)
    #             # This would check for actual NBC runtime availability
                self.logger.info("NBC runtime integration enabled")
    #             return True
    #         except Exception as e:
                self.logger.warning(f"NBC runtime not available, using fallback: {e}")
    #             return False

    #     async def initialize(self) -> bool:
    #         """
    #         Initialize the performance optimizer.

    #         Returns:
    #             bool: True if initialization successful
    #         """
    #         try:
                self.logger.info("Initializing Performance Optimizer...")

    #             # Ensure directories exist
    self.metrics_file.parent.mkdir(parents = True, exist_ok=True)

    #             # Load historical metrics if available
                await self._load_historical_metrics()

    #             # Initialize NBC runtime if available
    #             if self.nbc_available:
                    await self._initialize_nbc_runtime()

    self.initialized = True
    self.stats["start_time"] = datetime.now()

                self.logger.info("✅ Performance Optimizer initialized successfully")
    #             return True

    #         except Exception as e:
                self.logger.error(f"❌ Performance Optimizer initialization failed: {e}")
    #             return False

    #     async def _initialize_nbc_runtime(self):
    #         """Initialize NBC runtime for performance optimization."""
    #         # This would initialize the actual NoodleCore NBC runtime
    #         # For now, this is a placeholder implementation
            self.logger.info("Initializing NBC runtime integration...")
            await asyncio.sleep(0.1)  # Simulate initialization

    #     async def _load_historical_metrics(self):
    #         """Load historical performance metrics."""
    #         try:
    #             if self.metrics_file.exists():
    #                 with open(self.metrics_file, 'r') as f:
    data = json.load(f)

    #                 for metric_data in data.get("metrics", []):
    #                     # Convert timestamp string back to datetime
    timestamp = datetime.fromisoformat(metric_data["timestamp"])
    metrics = PerformanceMetrics(**{**metric_data, "timestamp": timestamp})
                        self.metrics_history.append(metrics)

                    self.logger.info(f"Loaded {len(self.metrics_history)} historical metrics")

    #         except Exception as e:
                self.logger.warning(f"Could not load historical metrics: {e}")

    #     async def start_monitoring(self) -> bool:
    #         """
    #         Start performance monitoring.

    #         Returns:
    #             bool: True if monitoring started successfully
    #         """
    #         if not self.initialized:
                self.logger.error("Cannot start monitoring: not initialized")
    #             return False

    #         try:
                self.logger.info("Starting Performance Monitoring...")

    self.monitoring = True
                self.stop_event.clear()

    #             # Start monitoring thread
    self.monitoring_thread = threading.Thread(target=self._monitoring_loop)
                self.monitoring_thread.start()

                self.logger.info("✅ Performance monitoring started")
    #             return True

    #         except Exception as e:
                self.logger.error(f"❌ Failed to start monitoring: {e}")
    #             return False

    #     def _monitoring_loop(self):
    #         """Main monitoring loop running in separate thread."""
    #         while not self.stop_event.is_set():
    #             try:
    #                 # Collect current metrics
    metrics = self._collect_current_metrics()

    #                 # Store metrics
                    self.metrics_history.append(metrics)

    #                 # Analyze performance
                    self._analyze_performance(metrics)

    #                 # Apply optimizations if needed
    #                 if self.optimization_enabled:
                        self._apply_optimizations(metrics)

    #                 # Save metrics periodically
    #                 if self.stats["total_measurements"] % 10 == 0:
                        asyncio.run(self._save_metrics())

    self.stats["total_measurements"] + = 1

    #                 # Sleep for monitoring interval
                    time.sleep(5)  # Monitor every 5 seconds

    #             except Exception as e:
                    self.logger.error(f"Error in monitoring loop: {e}")
                    time.sleep(1)

    #     def _collect_current_metrics(self) -> PerformanceMetrics:
    #         """Collect current system performance metrics."""
    #         try:
    #             import psutil

    #             # Get system metrics
    cpu_percent = math.divide(psutil.cpu_percent(interval=0.1), 100.0)
    memory = psutil.virtual_memory()
    memory_percent = math.divide(memory.percent, 100.0)

                # Get network latency (simplified)
    network_latency = 0.05  # Placeholder

                # Get application-specific metrics (these would come from the system)
    task_throughput = 50.0  # Placeholder
    error_rate = 0.01  # Placeholder
    response_time = 0.1  # Placeholder
    active_connections = 10  # Placeholder
    queue_depth = 5  # Placeholder

                return PerformanceMetrics(
    timestamp = datetime.now(),
    cpu_usage = cpu_percent,
    memory_usage = memory_percent,
    network_latency = network_latency,
    task_throughput = task_throughput,
    error_rate = error_rate,
    response_time = response_time,
    active_connections = active_connections,
    queue_depth = queue_depth
    #             )

    #         except Exception as e:
                self.logger.error(f"Error collecting metrics: {e}")
    #             # Return default metrics if collection fails
                return PerformanceMetrics(
    timestamp = datetime.now(),
    cpu_usage = 0.1,
    memory_usage = 0.1,
    network_latency = 0.1,
    task_throughput = 0.0,
    error_rate = 0.0,
    response_time = 0.1,
    active_connections = 0,
    queue_depth = 0
    #             )

    #     def _analyze_performance(self, metrics: PerformanceMetrics):
    #         """Analyze performance metrics for issues."""
    alerts = []

    #         # Check thresholds
    #         if metrics.cpu_usage > self.thresholds["cpu_usage"]:
                alerts.append({
    #                 "type": "high_cpu_usage",
    #                 "value": metrics.cpu_usage,
    #                 "threshold": self.thresholds["cpu_usage"],
    #                 "severity": "warning" if metrics.cpu_usage < 0.9 else "critical"
    #             })

    #         if metrics.memory_usage > self.thresholds["memory_usage"]:
                alerts.append({
    #                 "type": "high_memory_usage",
    #                 "value": metrics.memory_usage,
    #                 "threshold": self.thresholds["memory_usage"],
    #                 "severity": "warning" if metrics.memory_usage < 0.9 else "critical"
    #             })

    #         if metrics.error_rate > self.thresholds["error_rate"]:
                alerts.append({
    #                 "type": "high_error_rate",
    #                 "value": metrics.error_rate,
    #                 "threshold": self.thresholds["error_rate"],
    #                 "severity": "warning"
    #             })

    #         # Generate alerts
    #         for alert in alerts:
    self.stats["alerts_generated"] + = 1
    #             severity_emoji = "🚨" if alert["severity"] == "critical" else "⚠️"
    self.logger.warning(f"{severity_emoji} Performance alert: {alert['type']} = {alert['value']:.3f} (threshold: {alert['threshold']:.3f})")

    #     def _apply_optimizations(self, metrics: PerformanceMetrics):
    #         """Apply performance optimizations using NBC runtime."""
    #         if not self.nbc_available:
    #             return

    #         try:
    #             # NBC runtime optimization would go here
    #             # This is a placeholder for actual NBC optimization logic

    recommendations = []

    #             # Simple optimization based on metrics
    #             if metrics.cpu_usage > 0.8:
                    recommendations.append({
    #                     "type": "reduce_concurrent_tasks",
    #                     "description": "Reduce concurrent tasks to lower CPU usage",
    #                     "impact": "high",
    #                     "priority": "urgent"
    #                 })

    #             if metrics.memory_usage > 0.8:
                    recommendations.append({
    #                     "type": "clear_cache",
    #                     "description": "Clear non-essential caches to free memory",
    #                     "impact": "medium",
    #                     "priority": "high"
    #                 })

    #             if metrics.queue_depth > 50:
                    recommendations.append({
    #                     "type": "increase_processing_rate",
    #                     "description": "Increase task processing rate to clear queue",
    #                     "impact": "high",
    #                     "priority": "high"
    #                 })

    #             # Apply simple optimizations immediately
    #             for rec in recommendations:
                    self._apply_optimization(rec)

    #             # Store recommendations
    #             if recommendations:
                    self.optimization_recommendations.extend(recommendations)
    self.stats["optimizations_applied"] + = len(recommendations)
    self.stats["last_optimization"] = datetime.now()

    #         except Exception as e:
                self.logger.error(f"Error applying optimizations: {e}")

    #     def _apply_optimization(self, optimization: Dict[str, Any]):
    #         """Apply a specific optimization."""
    opt_type = optimization["type"]

    #         if opt_type == "reduce_concurrent_tasks":
                self.logger.info("🔧 Applying optimization: Reducing concurrent tasks")
    #             # This would actually reduce task concurrency

    #         elif opt_type == "clear_cache":
                self.logger.info("🔧 Applying optimization: Clearing cache")
    #             # This would clear non-essential caches

    #         elif opt_type == "increase_processing_rate":
                self.logger.info("🔧 Applying optimization: Increasing processing rate")
    #             # This would increase task processing rate

    #     async def _save_metrics(self):
    #         """Save performance metrics to disk."""
    #         try:
    #             # Convert metrics to serializable format
    metrics_data = []
    #             for metrics in self.metrics_history:
    metric_dict = {
                        "timestamp": metrics.timestamp.isoformat(),
    #                     "cpu_usage": metrics.cpu_usage,
    #                     "memory_usage": metrics.memory_usage,
    #                     "network_latency": metrics.network_latency,
    #                     "task_throughput": metrics.task_throughput,
    #                     "error_rate": metrics.error_rate,
    #                     "response_time": metrics.response_time,
    #                     "active_connections": metrics.active_connections,
    #                     "queue_depth": metrics.queue_depth
    #                 }
                    metrics_data.append(metric_dict)

    #             # Save to file
    data = {
    #                 "metrics": metrics_data,
    #                 "statistics": self.stats,
                    "last_updated": datetime.now().isoformat()
    #             }

    #             with open(self.metrics_file, 'w') as f:
    json.dump(data, f, indent = 2)

    #         except Exception as e:
                self.logger.error(f"Error saving metrics: {e}")

    #     async def stop_monitoring(self) -> bool:
    #         """
    #         Stop performance monitoring.

    #         Returns:
    #             bool: True if monitoring stopped successfully
    #         """
    #         try:
                self.logger.info("Stopping Performance Monitoring...")

    self.monitoring = False
                self.stop_event.set()

    #             # Wait for monitoring thread to finish
    #             if self.monitoring_thread and self.monitoring_thread.is_alive():
    self.monitoring_thread.join(timeout = 5)

    #             # Save final metrics
                await self._save_metrics()

                self.logger.info("✅ Performance monitoring stopped")
    #             return True

    #         except Exception as e:
                self.logger.error(f"❌ Error stopping monitoring: {e}")
    #             return False

    #     async def record_metrics(self, metrics: PerformanceMetrics):
    #         """
    #         Record performance metrics manually.

    #         Args:
    #             metrics: Performance metrics to record
    #         """
    #         try:
                self.metrics_history.append(metrics)
    self.stats["total_measurements"] + = 1

    #             # Analyze and apply optimizations
                self._analyze_performance(metrics)

    #             if self.optimization_enabled:
                    self._apply_optimizations(metrics)

    #         except Exception as e:
                self.logger.error(f"Error recording metrics: {e}")

    #     async def get_performance_report(self) -> Dict[str, Any]:
    #         """
    #         Get comprehensive performance report.

    #         Returns:
    #             Dict containing performance report
    #         """
    #         try:
    #             if not self.metrics_history:
    #                 return {
                        "timestamp": datetime.now().isoformat(),
    #                     "error": "No metrics available",
    #                     "performance_summary": {},
    #                     "system_health": {}
    #                 }

    #             # Calculate performance summary
    recent_metrics = math.subtract(list(self.metrics_history)[, 50:]  # Last 50 measurements)

    summary = {
    #                 "cpu_usage": {
    #                     "average": sum(m.cpu_usage for m in recent_metrics) / len(recent_metrics),
    #                     "current": recent_metrics[-1].cpu_usage,
    #                     "trend": "stable"
    #                 },
    #                 "memory_usage": {
    #                     "average": sum(m.memory_usage for m in recent_metrics) / len(recent_metrics),
    #                     "current": recent_metrics[-1].memory_usage,
    #                     "trend": "stable"
    #                 },
    #                 "task_throughput": {
    #                     "average": sum(m.task_throughput for m in recent_metrics) / len(recent_metrics),
    #                     "current": recent_metrics[-1].task_throughput,
    #                     "trend": "stable"
    #                 },
    #                 "error_rate": {
    #                     "average": sum(m.error_rate for m in recent_metrics) / len(recent_metrics),
    #                     "current": recent_metrics[-1].error_rate,
    #                     "trend": "stable"
    #                 }
    #             }

    #             # System health assessment
    current = math.subtract(recent_metrics[, 1])
    health_score = self._calculate_health_score(current)

    health = {
    #                 "overall_score": health_score,
    #                 "cpu_usage": current.cpu_usage,
    #                 "memory_usage": current.memory_usage,
    #                 "network_latency": current.network_latency,
    #                 "error_rate": current.error_rate,
    #                 "active_connections": current.active_connections,
    #                 "queue_depth": current.queue_depth
    #             }

    #             # Recent optimizations
    #             recent_optimizations = self.optimization_recommendations[-10:] if self.optimization_recommendations else []

    report = {
                    "timestamp": datetime.now().isoformat(),
    #                 "performance_summary": summary,
    #                 "system_health": health,
    #                 "statistics": self.stats,
    #                 "recent_optimizations": recent_optimizations,
    #                 "nbc_integration": self.nbc_available
    #             }

    #             return report

    #         except Exception as e:
                self.logger.error(f"Error generating performance report: {e}")
    #             return {
                    "timestamp": datetime.now().isoformat(),
                    "error": str(e)
    #             }

    #     def _calculate_health_score(self, metrics: PerformanceMetrics) -> float:
    #         """
            Calculate overall system health score (0.0 to 1.0).

    #         Args:
    #             metrics: Current performance metrics

    #         Returns:
    #             float: Health score
    #         """
    #         try:
    score = 1.0

    #             # Deduct points for high resource usage
    #             if metrics.cpu_usage > 0.8:
    score - = 0.3
    #             elif metrics.cpu_usage > 0.6:
    score - = 0.1

    #             if metrics.memory_usage > 0.8:
    score - = 0.3
    #             elif metrics.memory_usage > 0.6:
    score - = 0.1

    #             # Deduct points for errors
    #             if metrics.error_rate > 0.05:
    score - = 0.2
    #             elif metrics.error_rate > 0.01:
    score - = 0.1

    #             # Deduct points for performance issues
    #             if metrics.response_time > 1.0:
    score - = 0.2
    #             elif metrics.response_time > 0.5:
    score - = 0.1

                return max(0.0, min(1.0, score))

    #         except Exception as e:
                self.logger.error(f"Error calculating health score: {e}")
    #             return 0.5  # Default score

    #     async def get_overall_performance_score(self) -> float:
    #         """
    #         Get overall system performance score.

    #         Returns:
                float: Performance score (0.0 to 1.0)
    #         """
    #         try:
    #             if not self.metrics_history:
    #                 return 0.5  # Default score if no data

    current = math.subtract(self.metrics_history[, 1])
                return self._calculate_health_score(current)

    #         except Exception as e:
                self.logger.error(f"Error getting performance score: {e}")
    #             return 0.5

    #     async def get_optimization_recommendations(self) -> List[Dict[str, Any]]:
    #         """
    #         Get current optimization recommendations.

    #         Returns:
    #             List of optimization recommendations
    #         """
    #         try:
    #             # Generate fresh recommendations based on current metrics
    recommendations = []

    #             if not self.metrics_history:
    #                 return recommendations

    current = math.subtract(self.metrics_history[, 1])

    #             # Analyze current state and generate recommendations
    #             if current.cpu_usage > 0.8:
                    recommendations.append({
    #                     "action": "Reduce concurrent tasks",
    #                     "impact": "high",
    #                     "priority": "urgent",
    #                     "description": f"CPU usage is at {current.cpu_usage:.1%}, which is above the optimal threshold"
    #                 })

    #             if current.memory_usage > 0.8:
                    recommendations.append({
    #                     "action": "Clear memory caches",
    #                     "impact": "medium",
    #                     "priority": "high",
    #                     "description": f"Memory usage is at {current.memory_usage:.1%}, consider clearing caches"
    #                 })

    #             if current.queue_depth > 50:
                    recommendations.append({
    #                     "action": "Increase processing rate",
    #                     "impact": "high",
    #                     "priority": "high",
    #                     "description": f"Queue depth is {current.queue_depth}, increase processing capacity"
    #                 })

    #             return recommendations

    #         except Exception as e:
                self.logger.error(f"Error getting optimization recommendations: {e}")
    #             return []

    #     async def configure_thresholds(self, thresholds: Dict[str, float]):
    #         """
    #         Configure performance thresholds.

    #         Args:
    #             thresholds: New threshold values
    #         """
    #         try:
                self.thresholds.update(thresholds)
                self.logger.info(f"Updated performance thresholds: {thresholds}")

    #         except Exception as e:
                self.logger.error(f"Error configuring thresholds: {e}")

    #     async def cleanup(self) -> bool:
    #         """
    #         Clean up performance optimizer resources.

    #         Returns:
    #             bool: True if cleanup successful
    #         """
    #         try:
                self.logger.info("Cleaning up Performance Optimizer...")

    #             # Stop monitoring if running
    #             if self.monitoring:
                    await self.stop_monitoring()

    #             # Save final metrics
                await self._save_metrics()

    #             # Save optimization recommendations
    #             if self.optimization_recommendations:
    #                 try:
    #                     with open(self.optimization_file, 'w') as f:
                            json.dump({
    #                             "recommendations": self.optimization_recommendations,
                                "last_updated": datetime.now().isoformat()
    }, f, indent = 2)
    #                 except Exception as e:
                        self.logger.warning(f"Could not save optimization recommendations: {e}")

                self.logger.info("✅ Performance Optimizer cleanup completed")
    #             return True

    #         except Exception as e:
                self.logger.error(f"❌ Error during cleanup: {e}")
    #             return False