# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Performance Monitoring System for NoodleCore Self-Improvement

# This module activates and configures existing performance monitoring infrastructure
# to collect comprehensive metrics for compilation and execution performance.
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
import collections.deque

# Configure logging
logger = logging.getLogger(__name__)

# Environment variables
NOODLE_DEBUG = os.environ.get("NOODLE_DEBUG", "0") == "1"
NOODLE_PERFORMANCE_MONITORING = os.environ.get("NOODLE_PERFORMANCE_MONITORING", "1") == "1"
NOODLE_METRICS_COLLECTION_INTERVAL = int(os.environ.get("NOODLE_METRICS_COLLECTION_INTERVAL", "30"))
NOODLE_PERFORMANCE_COMPARISON_ENABLED = os.environ.get("NOODLE_PERFORMANCE_COMPARISON_ENABLED", "1") == "1"

# Import existing monitoring components
import ..monitoring.performance_monitor.PerformanceMonitor,
import ..monitoring.metrics_collector.MetricsCollector
import ..optimization.adaptive_optimization.AdaptiveOptimizationSystem


class MonitoringStatus(Enum)
    #     """Status of monitoring system"""
    INACTIVE = "inactive"
    INITIALIZING = "initializing"
    ACTIVE = "active"
    ERROR = "error"
    PAUSED = "paused"


# @dataclass
class PerformanceSnapshot
    #     """Snapshot of performance metrics at a point in time."""
    #     timestamp: float
    #     component_name: str
    #     implementation_type: str
    #     execution_time: float
    #     memory_usage: float
    #     cpu_usage: float
    #     success: bool
    error_message: Optional[str] = None
    metadata: Optional[Dict[str, Any]] = None


class PerformanceMonitoringSystem
    #     """
    #     Performance monitoring system that activates and coordinates existing monitoring infrastructure.

    #     This class provides a foundation for self-improvement system by collecting
    #     comprehensive performance metrics and enabling automated comparison between implementations.
    #     """

    #     def __init__(self, component_manager=None):
    #         """Initialize performance monitoring system."""
    #         if NOODLE_DEBUG:
                logger.setLevel(logging.DEBUG)

    self.component_manager = component_manager

    #         # Monitoring components
    self.performance_monitor = None
    self.metrics_collector = None
    self.adaptive_optimizer = None

    #         # Data storage
    self.performance_snapshots: List[PerformanceSnapshot] = []
    self.comparison_results: Dict[str, Any] = {}

    #         # Threading
    self._monitoring_thread = None
    self._lock = threading.RLock()
    self._running = False

    #         # Initialize configuration
            self._load_configuration()

            logger.info("Performance monitoring system initialized")

    #     def _load_configuration(self):
    #         """Load monitoring configuration from environment and defaults."""
    self.monitoring_config = {
    #             'enabled': NOODLE_PERFORMANCE_MONITORING,
    #             'collection_interval': NOODLE_METRICS_COLLECTION_INTERVAL,
    #             'comparison_enabled': NOODLE_PERFORMANCE_COMPARISON_ENABLED,
    #             'metrics_retention': 10000,
    #             'auto_comparison_threshold': 10,  # Run comparison after 10 executions
    #             'alert_thresholds': {
    #                 'execution_time': 500.0,  # ms
    #                 'memory_usage': 80.0,     # percentage
    #                 'cpu_usage': 80.0,        # percentage
    #                 'error_rate': 5.0           # percentage
    #             }
    #         }

    #     def activate(self) -> bool:
    #         """Activate performance monitoring system."""
    #         with self._lock:
    #             if self._running:
    #                 return True

    self._running = True

    #             # Initialize existing monitoring components
                self._initialize_monitoring_components()

    #             # Start background monitoring
                self._start_monitoring_thread()

    self.status = MonitoringStatus.ACTIVE
                logger.info("Performance monitoring system activated successfully")
    #             return True

    #     def _initialize_monitoring_components(self):
    #         """Initialize existing monitoring components."""
    #         # Initialize performance monitor
    #         if not self.performance_monitor:
    #             # Create a mock task distributor for the performance monitor
    #             from ..runtime.distributed.task_distributor import TaskDistributor
    task_distributor = TaskDistributor()

    self.performance_monitor = PerformanceMonitor(
    task_distributor = task_distributor,
    metrics_retention = self.monitoring_config['metrics_retention']
    #             )
                self.performance_monitor.start()

    #         # Initialize metrics collector
    #         if not self.metrics_collector:
    self.metrics_collector = MetricsCollector()
                self.metrics_collector.start_collection(
    interval = self.monitoring_config['collection_interval']
    #             )

    #         # Initialize adaptive optimization system
    #         if not self.adaptive_optimizer:
    self.adaptive_optimizer = AdaptiveOptimizationSystem(
    performance_monitor = self.performance_monitor,
    metrics_collector = self.metrics_collector
    #             )
                self.adaptive_optimizer.start()

    #         # Initialize performance benchmark for comparison
    #         if self.monitoring_config['comparison_enabled'] and not hasattr(self, 'performance_benchmark'):
    #             from ...bridge_modules.performance_compare.performance_benchmark import PerformanceBenchmark, ImplementationType
    self.performance_benchmark = PerformanceBenchmark()
                self.performance_benchmark.start()

    #     def _start_monitoring_thread(self):
    #         """Start background monitoring thread."""
    #         if self._monitoring_thread and self._monitoring_thread.is_alive():
    #             return

    self._monitoring_thread = threading.Thread(
    target = self._monitoring_worker,
    daemon = True
    #         )
            self._monitoring_thread.start()

    #     def _monitoring_worker(self):
    #         """Background worker for monitoring tasks."""
            logger.info("Performance monitoring worker started")

    #         while self._running:
    #             try:
    #                 # Collect current metrics
    #                 if self.metrics_collector:
    current_metrics = self.metrics_collector.get_current_metrics()
    #                 if self.performance_monitor:
                        current_metrics.update(self.performance_monitor.get_statistics())

    #                 # Check if auto-comparison should run
    #                 if self.monitoring_config['comparison_enabled']:
                        self._check_auto_comparison()

    #                 # Sleep until next collection
                    time.sleep(self.monitoring_config['collection_interval'])
    #             except Exception as e:
                    logger.error(f"Error in monitoring worker: {e}")
                    time.sleep(5)  # Brief pause before retrying

    #     def _collect_current_metrics(self):
    #         """Collect current performance metrics."""
    #         if not self.metrics_collector:
    #             return {}

    #         try:
    #             # Get current metrics from collector
    current_metrics = self.metrics_collector.get_current_metrics()

    #             # Store snapshot for each component being monitored
    #             for component_name, metrics in current_metrics.items():
    snapshot = PerformanceSnapshot(
    timestamp = time.time(),
    component_name = component_name,
    implementation_type = self._get_component_implementation_type(component_name),
    execution_time = metrics.get('execution_time', 0.0),
    memory_usage = metrics.get('memory_usage', 0.0),
    cpu_usage = metrics.get('cpu_usage', 0.0),
    success = metrics.get('success', True),
    error_message = metrics.get('error_message'),
    metadata = metrics.get('metadata', {})
    #                 )

    #                 with self._lock:
                        self.performance_snapshots.append(snapshot)

    #                     # Keep only recent snapshots
    #                     if len(self.performance_snapshots) > self.monitoring_config['metrics_retention']:
    self.performance_snapshots = self.performance_snapshots[-self.monitoring_config['metrics_retention']:]
    #         except Exception as e:
                logger.error(f"Error collecting current metrics: {e}")

    #     def _get_component_implementation_type(self, component_name: str) -> str:
    #         """Get the implementation type for a component."""
    #         if not self.component_manager:
    #             return "python"

    #         try:
    #             # Get the latest decision for this component
    decisions = self.component_manager.get_decision_history(limit=1)
    #             if decisions and decisions[0].component_name == component_name:
    #                 return decisions[0].component_type
    #         except Exception:
    #             pass

    #         # Default to Python if we can't determine the type
    #         return "python"

    #     def _check_auto_comparison(self):
    #         """Check if automatic performance comparison should run."""
    #         if not self.performance_benchmark:
    #             return

    #         with self._lock:
    snapshot_count = len(self.performance_snapshots)

    #             # Check if we have enough snapshots for comparison
    #             if snapshot_count >= self.monitoring_config['auto_comparison_threshold']:
    #                 # Group snapshots by component name
    component_snapshots = {}
    #                 for snapshot in self.performance_snapshots:
    #                     if snapshot.component_name not in component_snapshots:
    component_snapshots[snapshot.component_name] = []
                        component_snapshots[snapshot.component_name].append(snapshot)

    #                 # Run comparison for components with multiple implementations
    #                 for component_name, snapshots in component_snapshots.items():
    #                     if self._has_multiple_implementations(snapshots):
                            self._run_performance_comparison(component_name, snapshots)

    #                 # Reset snapshots after comparison
    self.performance_snapshots = []

    #     def _has_multiple_implementations(self, snapshots: List[PerformanceSnapshot]) -> bool:
    #         """Check if snapshots contain multiple implementation types."""
    #         implementation_types = set(s.implementation_type for s in snapshots)
            return len(implementation_types) > 1

    #     def _run_performance_comparison(self, component_name: str, snapshots: List[PerformanceSnapshot]):
    #         """Run performance comparison for a component."""
    #         try:
    #             # Group snapshots by implementation type
    impl_snapshots = {}
    #             for snapshot in snapshots:
    impl_type = snapshot.implementation_type
    #                 if impl_type not in impl_snapshots:
    impl_snapshots[impl_type] = []
                    impl_snapshots[impl_type].append(snapshot)

    #             # Calculate statistics for each implementation
    comparison_data = {
    #                 'component_name': component_name,
                    'timestamp': time.time(),
    #                 'implementations': {}
    #             }

    #             for impl_type, impl_data in impl_snapshots.items():
    #                 successful = [s for s in impl_data if s.success]

    #                 if successful:
    #                     execution_times = [s.execution_time for s in successful]
    #                     memory_usages = [s.memory_usage for s in successful]
    #                     cpu_usages = [s.cpu_usage for s in successful]

    comparison_data['implementations'][impl_type] = {
                            'sample_count': len(successful),
                            'avg_execution_time': sum(execution_times) / len(execution_times),
                            'min_execution_time': min(execution_times),
                            'max_execution_time': max(execution_times),
                            'avg_memory_usage': sum(memory_usages) / len(memory_usages),
                            'min_memory_usage': min(memory_usages),
                            'max_memory_usage': max(memory_usages),
                            'avg_cpu_usage': sum(cpu_usages) / len(cpu_usages),
                            'min_cpu_usage': min(cpu_usages),
                            'max_cpu_usage': max(cpu_usages),
                            'success_rate': len(successful) / len(impl_data) * 100.0
    #                     }
    #                 else:
    comparison_data['implementations'][impl_type] = {
    #                         'sample_count': 0,
    #                         'success_rate': 0.0
    #                     }

    #             # Store comparison result
    self.comparison_results[component_name] = comparison_data

    #             # Log comparison summary
                self._log_comparison_summary(comparison_data)
    #         except Exception as e:
    #             logger.error(f"Error running performance comparison for {component_name}: {e}")

    #     def _log_comparison_summary(self, comparison_data: Dict[str, Any]):
    #         """Log a summary of the comparison results."""
    component_name = comparison_data['component_name']
    implementations = comparison_data['implementations']

    #         if len(implementations) < 2:
    #             return

    #         logger.info(f"Performance comparison for {component_name}")

    #         # Find the best performing implementation
    best_impl = None
    best_time = float('inf')

    #         for impl_type, impl_data in implementations.items():
    #             if impl_data['sample_count'] > 0:
    avg_time = impl_data['avg_execution_time']
    success_rate = impl_data['success_rate']

                    logger.info(
    #                     f"  {impl_type}: {avg_time:.4f}s avg, "
    #                     f"{success_rate:.1f}% success rate"
    #                 )

    #                 if avg_time < best_time:
    best_time = avg_time
    best_impl = impl_type

    #         if best_impl:
                logger.info(f"Best performing: {best_impl}")

    #     def record_execution(self,
    #                      component_name: str,
    #                      implementation_type: str,
    #                      execution_time: float,
    success: bool = True,
    error_message: Optional[str] = None,
    metadata: Optional[Dict[str, Any]] = None):
    #         """
    #         Record an execution for performance monitoring.
    #         """
    #         if self.status != MonitoringStatus.ACTIVE:
    #             return

    snapshot = PerformanceSnapshot(
    timestamp = time.time(),
    component_name = component_name,
    implementation_type = implementation_type,
    execution_time = execution_time,
    memory_usage = 0.0,  # Will be filled by monitoring worker
    cpu_usage = 0.0,      # Will be filled by monitoring worker
    success = success,
    error_message = error_message,
    metadata = metadata
    #         )

    #         with self._lock:
                self.performance_snapshots.append(snapshot)

    #             # Also record in the existing performance monitor
    #             if self.performance_monitor:
    metric_name = f"{component_name}_execution_time"
                    self.performance_monitor.record_metric(
    name = metric_name,
    value = math.multiply(execution_time, 1000.0,  # Convert to ms)
    metric_type = MetricType.TIMER,
    tags = {
    #                         'implementation': implementation_type,
                            'success': str(success)
    #                     }
    #                 )

    #     def get_performance_summary(self, component_name: str = None) -> Dict[str, Any]:
    #         """
    #         Get performance summary for a component or all components.
    #         """
    #         with self._lock:
    snapshots = self.performance_snapshots.copy()

    #             if component_name:
    #                 snapshots = [s for s in snapshots if s.component_name == component_name]
    #             else:
    #                 # Return all snapshots if no component specified
    #                 pass

    #             # Group by implementation type
    impl_data = {}
    #             for snapshot in snapshots:
    impl_type = snapshot.implementation_type
    #                 if impl_type not in impl_data:
    impl_data[impl_type] = []
                    impl_data[impl_type].append(snapshot)

    #             # Calculate summary statistics
    summary = {
    #                 'component_name': component_name or 'all',
                    'timestamp': time.time(),
                    'total_executions': len(snapshots),
    #                 'implementations': {}
    #             }

    #             for impl_type, impl_data in impl_data.items():
    #                 successful = [s for s in impl_data if s.success]

    #                 if successful:
    #                     execution_times = [s.execution_time for s in successful]
    #                     memory_usages = [s.memory_usage for s in successful]
    #                     cpu_usages = [s.cpu_usage for s in successful]

    summary['implementations'][impl_type] = {
                            'executions': len(successful),
                            'success_rate': len(successful) / len(impl_data) * 100.0,
                            'avg_execution_time': sum(execution_times) / len(execution_times),
                            'min_execution_time': min(execution_times),
                            'max_execution_time': max(execution_times),
                            'avg_memory_usage': sum(memory_usages) / len(memory_usages),
                            'min_memory_usage': min(memory_usages),
                            'max_memory_usage': max(memory_usages),
                            'avg_cpu_usage': sum(cpu_usages) / len(cpu_usages),
                            'min_cpu_usage': min(cpu_usages),
                            'max_cpu_usage': max(cpu_usages),
                            'success_rate': len(successful) / len(impl_data) * 100.0
    #                     }
    #                 else:
    summary['implementations'][impl_type] = {
    #                         'executions': 0,
    #                         'success_rate': 0.0
    #                     }

    #             return summary

    #     def get_comparison_results(self, component_name: str = None) -> Dict[str, Any]:
    #         """
    #         Get performance comparison results.
    #         """
    #         with self._lock:
    #             if component_name:
                    return self.comparison_results.get(component_name, {})
                return self.comparison_results.copy()

    #     def deactivate(self) -> bool:
    #         """
    #         Deactivate performance monitoring system.
    #         """
    #         with self._lock:
    #             if self.status != MonitoringStatus.ACTIVE:
    #                 return True

    self._running = False

    #             try:
    #                 # Stop monitoring thread
    #                 if self._monitoring_thread and self._monitoring_thread.is_alive():
    self._monitoring_thread.join(timeout = 5.0)

    #                 # Stop monitoring components
    #                 if self.performance_monitor:
                        self.performance_monitor.stop()
    #                 if self.metrics_collector:
                        self.metrics_collector.stop_collection()
    #                 if self.adaptive_optimizer:
                        self.adaptive_optimizer.stop()
    #                 if self.performance_benchmark:
                        self.performance_benchmark.stop()

    self.status = MonitoringStatus.INACTIVE
                    logger.info("Performance monitoring system deactivated")
    #                 return True
    #             except Exception as e:
                    logger.error(f"Error deactivating performance monitoring: {e}")
    #                 with self._lock:
    self.status = MonitoringStatus.ERROR
    #                 return False

    #     def get_status(self) -> Dict[str, Any]:
    #         """
    #         Get the current status of the monitoring system.
    #         """
    #         with self._lock:
    #             return {
    #                 'status': self.status.value,
                    'snapshots_count': len(self.performance_snapshots),
                    'comparisons_count': len(self.comparison_results),
                    'monitoring_config': self.monitoring_config.copy(),
    #                 'components': {
    #                     'performance_monitor': self.performance_monitor is not None,
    #                     'metrics_collector': self.metrics_collector is not None,
    #                     'adaptive_optimizer': self.adaptive_optimizer is not None,
    #                     'performance_benchmark': self.performance_benchmark is not None
    #                 }
    #             }


# Global instance for convenience
_global_monitoring_system_instance = None


def get_performance_monitoring_system(component_manager=None) -> PerformanceMonitoringSystem:
#     """
#     Get a global performance monitoring system instance.
#     """
#     global _global_monitoring_system_instance

#     if _global_monitoring_system_instance is None:
_global_monitoring_system_instance = PerformanceMonitoringSystem(component_manager)

#     return _global_monitoring_system_instance