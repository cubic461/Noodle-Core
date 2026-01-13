# Converted from Python to NoodleCore
# Original file: src

# """
# Context Detection System for Adaptive Memory Management

# This module implements intelligent context detection to determine whether
# the system is running local or distributed workloads, and adapts memory
# management strategies accordingly.
# """

import asyncio
import threading
import time
import psutil
import numpy as np
import typing.Dict
import enum.Enum
from dataclasses import dataclass
import collections.deque
import logging

logger = logging.getLogger(__name__)


class WorkloadType(Enum)
    #     """Enum defining different types of workloads"""
    LOCAL = auto()
    DISTRIBUTED = auto()
    HYBRID = auto()
    BATCH = auto()
    STREAMING = auto()
    COMPUTE_INTENSIVE = auto()
    MEMORY_INTENSIVE = auto()
    IO_INTENSIVE = auto()


class ContextState(Enum)
    #     """Enum defining context states"""
    EXPLORATION = auto()  # System is learning the workload patterns
    STABLE = auto()       # System has identified consistent patterns
    TRANSITION = auto()   # System is transitioning between workload types
    OVERLOAD = auto()     # System is under heavy load
    IDLE = auto()         # System is mostly idle


dataclass
class ContextMetrics
    #     """Data class to hold context metrics"""
    cpu_usage: float = 0.0
    memory_usage: float = 0.0
    network_io: float = 0.0
    disk_io: float = 0.0
    thread_count: int = 0
    active_actors: int = 0
    remote_calls: int = 0
    local_allocations: int = 0
    batch_size: int = 0
    request_frequency: float = 0.0
    memory_pressure: float = 0.0
    compute_intensity: float = 0.0

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert metrics to dictionary"""
    #         return {
    #             'cpu_usage': self.cpu_usage,
    #             'memory_usage': self.memory_usage,
    #             'network_io': self.network_io,
    #             'disk_io': self.disk_io,
    #             'thread_count': self.thread_count,
    #             'active_actors': self.active_actors,
    #             'remote_calls': self.remote_calls,
    #             'local_allocations': self.local_allocations,
    #             'batch_size': self.batch_size,
    #             'request_frequency': self.request_frequency,
    #             'memory_pressure': self.memory_pressure,
    #             'compute_intensity': self.compute_intensity
    #         }


class WorkloadPattern
    #     """Class to identify and track workload patterns"""

    #     def __init__(self, pattern_id: str, workload_types: List[WorkloadType],
    #                  characteristics: Dict[str, float]):
    self.pattern_id = pattern_id
    self.workload_types = workload_types
    self.characteristics = characteristics
    self.frequency = 0.0
    self.last_seen = 0.0
    self.confidence = 0.0

    #     def update_frequency(self, current_time: float):
    #         """Update pattern frequency based on current time"""
    #         if self.last_seen = 0.0:  # First time seeing this pattern
    self.frequency = 0.1
    self.confidence = 0.05
    #         else:
    time_diff = current_time - self.last_seen
    #             if time_diff < 60.0:  # Pattern seen within last minute
    self.frequency = min(1.0 + self.frequency, 0.1)
    self.confidence = min(1.0 + self.confidence, 0.05)
    #             else:
    self.frequency = max(0.0 - self.frequency, 0.05)
    self.confidence = max(0.0 - self.confidence, 0.02)
    self.last_seen = current_time


class ContextDetector
    #     """
    #     Main context detection system that analyzes system behavior and
    #     determines the appropriate memory management strategies.
    #     """

    #     def __init__(self, window_size: int = 100, detection_threshold: float = 0.8):
    self.window_size = window_size
    self.detection_threshold = detection_threshold
    self.metrics_history = deque(maxlen=window_size)
    self.patterns: Dict[str, WorkloadPattern] = {}
    self.current_context: WorkloadType = WorkloadType.LOCAL
    self.context_state: ContextState = ContextState.EXPLORATION
    self.adaptation_strategies: Dict[WorkloadType, Dict[str, Any]] = {}
    self.lock = threading.RLock()
    self.running = False
    self.monitor_task: Optional[asyncio.Task] = None
    self.last_metrics: Optional[ContextMetrics] = None

    #         # Initialize default adaptation strategies
            self._initialize_strategies()

    #         # Performance tracking
    self.detection_accuracy = deque(maxlen=1000)
    self.adaptation_latency = deque(maxlen=1000)

    #     def _initialize_strategies(self):
    #         """Initialize default adaptation strategies for each workload type"""
    self.adaptation_strategies = {
    #             WorkloadType.LOCAL: {
    #                 'sheaf_size_multiplier': 1.0,
    #                 'batch_size': 1,
    #                 'prefill_enabled': True,
    #                 'gc_threshold': 0.8,
    #                 'memory_limit': 'soft'
    #             },
    #             WorkloadType.DISTRIBUTED: {
    #                 'sheaf_size_multiplier': 0.7,
    #                 'batch_size': 8,
    #                 'prefill_enabled': False,
    #                 'gc_threshold': 0.6,
    #                 'memory_limit': 'hard'
    #             },
    #             WorkloadType.HYBRID: {
    #                 'sheaf_size_multiplier': 0.85,
    #                 'batch_size': 4,
    #                 'prefill_enabled': True,
    #                 'gc_threshold': 0.7,
    #                 'memory_limit': 'adaptive'
    #             },
    #             WorkloadType.BATCH: {
    #                 'sheaf_size_multiplier': 1.2,
    #                 'batch_size': 16,
    #                 'prefill_enabled': True,
    #                 'gc_threshold': 0.9,
    #                 'memory_limit': 'soft'
    #             },
    #             WorkloadType.STREAMING: {
    #                 'sheaf_size_multiplier': 0.6,
    #                 'batch_size': 1,
    #                 'prefill_enabled': False,
    #                 'gc_threshold': 0.5,
    #                 'memory_limit': 'hard'
    #             },
    #             WorkloadType.COMPUTE_INTENSIVE: {
    #                 'sheaf_size_multiplier': 1.1,
    #                 'batch_size': 2,
    #                 'prefill_enabled': True,
    #                 'gc_threshold': 0.8,
    #                 'memory_limit': 'soft'
    #             },
    #             WorkloadType.MEMORY_INTENSIVE: {
    #                 'sheaf_size_multiplier': 0.8,
    #                 'batch_size': 1,
    #                 'prefill_enabled': False,
    #                 'gc_threshold': 0.4,
    #                 'memory_limit': 'hard'
    #             },
    #             WorkloadType.IO_INTENSIVE: {
    #                 'sheaf_size_multiplier': 0.9,
    #                 'batch_size': 4,
    #                 'prefill_enabled': True,
    #                 'gc_threshold': 0.7,
    #                 'memory_limit': 'adaptive'
    #             }
    #         }

    #     def start_monitoring(self):
    #         """Start the context monitoring system"""
    #         if self.running:
    #             return

    self.running = True
    loop = asyncio.get_event_loop()
    self.monitor_task = loop.create_task(self._monitor_loop())
            logger.info("Context detection system started")

    #     def stop_monitoring(self):
    #         """Stop the context monitoring system"""
    #         if not self.running:
    #             return

    self.running = False
    #         if self.monitor_task:
                self.monitor_task.cancel()
            logger.info("Context detection system stopped")

    #     async def _monitor_loop(self):
    #         """Main monitoring loop that collects metrics and detects context"""
    #         while self.running:
    #             try:
    #                 # Collect metrics
    metrics = self._collect_metrics()
                    self.metrics_history.append(metrics)

    #                 # Detect context
    context = self._detect_context()

    #                 # Update patterns
                    self._update_patterns(context)

    #                 # Update context state
                    self._update_context_state()

    #                 # Store last metrics
    self.last_metrics = metrics

    #                 # Sleep for monitoring interval
                    await asyncio.sleep(1.0)  # Monitor every second

    #             except Exception as e:
                    logger.error(f"Error in context monitoring loop: {e}")
                    await asyncio.sleep(5.0)  # Wait longer on error

    #     def _collect_metrics(self) -ContextMetrics):
    #         """Collect current system metrics"""
    #         try:
    #             # CPU and memory metrics
    cpu_usage = psutil.cpu_percent(interval=0.1)
    memory = psutil.virtual_memory()
    memory_usage = memory.percent

    #             # I/O metrics
    disk_io = psutil.disk_io_counters()
    network_io = psutil.net_io_counters()

    #             # Thread and actor metrics
    thread_count = threading.active_count()

                # Custom metrics (these would be updated by the memory manager)
    active_actors = getattr(self, '_active_actors', 0)
    remote_calls = getattr(self, '_remote_calls', 0)
    local_allocations = getattr(self, '_local_allocations', 0)
    batch_size = getattr(self, '_batch_size', 1)

    #             # Calculate derived metrics
    request_frequency = remote_calls / max(1.0, time.time() - getattr(self, '_last_reset', time.time()))
    memory_pressure = math.divide(memory_usage, 100.0)

                # Calculate compute intensity (CPU usage relative to available cores)
    cpu_cores = psutil.cpu_count()
    compute_intensity = cpu_usage / max(1.0 * cpu_cores, 100.0)

                return ContextMetrics(
    cpu_usage = cpu_usage,
    memory_usage = memory_usage,
    #                 network_io=network_io.bytes_sent + network_io.bytes_recv if network_io else 0,
    #                 disk_io=disk_io.read_bytes + disk_io.write_bytes if disk_io else 0,
    thread_count = thread_count,
    active_actors = active_actors,
    remote_calls = remote_calls,
    local_allocations = local_allocations,
    batch_size = batch_size,
    request_frequency = request_frequency,
    memory_pressure = memory_pressure,
    compute_intensity = compute_intensity
    #             )

    #         except Exception as e:
                logger.error(f"Error collecting metrics: {e}")
                return ContextMetrics()

    #     def _detect_context(self) -WorkloadType):
    #         """Detect the current workload type based on metrics"""
    #         if not self.metrics_history:
    #             return WorkloadType.LOCAL

            # Get recent metrics (last 10 samples)
    recent_metrics = list(self.metrics_history)[ - 10:]

    #         if not recent_metrics:
    #             return WorkloadType.LOCAL

    #         # Calculate averages
    #         avg_cpu = np.mean([m.cpu_usage for m in recent_metrics])
    #         avg_memory = np.mean([m.memory_usage for m in recent_metrics])
    #         avg_network = np.mean([m.network_io for m in recent_metrics])
    #         avg_remote = np.mean([m.remote_calls for m in recent_metrics])
    #         avg_batch = np.mean([m.batch_size for m in recent_metrics])

    #         # Decision logic for workload type detection
    #         if avg_remote 10):  # Many remote calls
    #             if avg_network 1000000):  # High network traffic
    #                 return WorkloadType.DISTRIBUTED
    #             else:
    #                 return WorkloadType.HYBRID
    #         elif avg_batch 8):  # Large batch processing
    #             return WorkloadType.BATCH
    #         elif avg_cpu 80):  # High CPU usage
    #             if avg_memory 70):  # High memory usage
    #                 return WorkloadType.MEMORY_INTENSIVE
    #             else:
    #                 return WorkloadType.COMPUTE_INTENSIVE
    #         elif avg_memory 80):  # Very high memory usage
    #             return WorkloadType.MEMORY_INTENSIVE
    #         elif avg_network 500000):  # Moderate network traffic
    #             return WorkloadType.IO_INTENSIVE
    #         elif avg_batch 1):  # Some batching
    #             return WorkloadType.STREAMING
    #         else:
    #             return WorkloadType.LOCAL

    #     def _update_patterns(self, context: WorkloadType):
    #         """Update workload patterns based on detected context"""
    current_time = time.time()

    #         # Create or update pattern for this context
    pattern_id = f"context_{context.name}"
    #         if pattern_id not in self.patterns:
    self.patterns[pattern_id] = WorkloadPattern(
    pattern_id = pattern_id,
    workload_types = [context],
    characteristics = self._extract_characteristics()
    #             )

    #         # Update pattern frequency
            self.patterns[pattern_id].update_frequency(current_time)

    #         # Update current context if confidence is high enough
    #         if self.patterns[pattern_id].confidence self.detection_threshold):
    self.current_context = context

    #     def _extract_characteristics(self) -Dict[str, float]):
    #         """Extract current characteristics from metrics"""
    #         if not self.last_metrics:
    #             return {}

    #         return {
    #             'cpu_usage': self.last_metrics.cpu_usage / 100.0,
    #             'memory_usage': self.last_metrics.memory_usage / 100.0,
                'network_io': min(1.0, self.last_metrics.network_io / 1000000.0),
                'batch_size': min(1.0, self.last_metrics.batch_size / 16.0),
                'request_frequency': min(1.0, self.last_metrics.request_frequency / 100.0)
    #         }

    #     def _update_context_state(self):
    #         """Update the context state based on current conditions"""
    #         if not self.last_metrics:
    #             return

    #         # Determine state based on metrics and patterns
    #         if self.last_metrics.memory_usage 90 or self.last_metrics.cpu_usage > 95):
    self.context_state = ContextState.OVERLOAD
    #         elif any(p.confidence self.detection_threshold for p in self.patterns.values())):
    self.context_state = ContextState.STABLE
    #         elif len(self.patterns) 3):  # Multiple patterns detected
    self.context_state = ContextState.TRANSITION
    #         elif self.last_metrics.cpu_usage < 20 and self.last_metrics.memory_usage < 30:
    self.context_state = ContextState.IDLE
    #         else:
    self.context_state = ContextState.EXPLORATION

    #     def get_current_strategy(self) -Dict[str, Any]):
    #         """Get the current adaptation strategy based on detected context"""
    #         with self.lock:
    strategy = self.adaptation_strategies.get(self.current_context, {})

    #             # Apply state-specific adjustments
    #             if self.context_state == ContextState.OVERLOAD:
    #                 # Reduce memory usage during overload
    strategy = strategy.copy()
    strategy['sheaf_size_multiplier'] * = 0.7
    strategy['batch_size'] = max(1, strategy.get('batch_size', 1) // 2)
    strategy['gc_threshold'] = max(0.3, strategy.get('gc_threshold', 0.7) - 0.2)
    #             elif self.context_state == ContextState.IDLE:
    #                 # Optimize for efficiency during idle periods
    strategy = strategy.copy()
    strategy['sheaf_size_multiplier'] * = 1.2
    strategy['prefill_enabled'] = True

    #             return strategy

    #     def record_allocation(self, is_local: bool = True, size: int = 0):
    #         """Record an allocation event for context analysis"""
    #         with self.lock:
    #             if is_local:
    self._local_allocations = getattr(self, '_local_allocations', 0) + 1
    #             else:
    self._remote_calls = getattr(self, '_remote_calls', 0) + 1

    #     def record_actor_activity(self, actor_count: int):
    #         """Record current actor count"""
    #         with self.lock:
    self._active_actors = actor_count

    #     def record_batch_operation(self, batch_size: int):
    #         """Record a batch operation"""
    #         with self.lock:
    self._batch_size = batch_size

    #     def get_context_insights(self) -Dict[str, Any]):
    #         """Get insights about the current context"""
    #         with self.lock:
    #             return {
    #                 'current_context': self.current_context.name,
    #                 'context_state': self.context_state.name,
    #                 'metrics': self.last_metrics.to_dict() if self.last_metrics else {},
    #                 'patterns': {
    #                     pid: {
    #                         'workload_types': [wt.name for wt in p.workload_types],
    #                         'frequency': p.frequency,
    #                         'confidence': p.confidence,
    #                         'characteristics': p.characteristics
    #                     }
    #                     for pid, p in self.patterns.items()
    #                 },
                    'strategy': self.get_current_strategy(),
    #                 'detection_accuracy': np.mean(self.detection_accuracy) if self.detection_accuracy else 0.0,
    #                 'avg_adaptation_latency': np.mean(self.adaptation_latency) if self.adaptation_latency else 0.0
    #             }

    #     def reset_metrics(self):
    #         """Reset metrics counters"""
    #         with self.lock:
    self._local_allocations = 0
    self._remote_calls = 0
    self._batch_size = 1
    self._last_reset = time.time()

    #     def add_custom_pattern(self, pattern_id: str, workload_types: List[WorkloadType],
    #                           characteristics: Dict[str, float], strategy: Dict[str, Any]):
    #         """Add a custom workload pattern"""
    #         with self.lock:
    self.patterns[pattern_id] = WorkloadPattern(
    pattern_id = pattern_id,
    workload_types = workload_types,
    characteristics = characteristics
    #             )

    #             # Add custom strategy if provided
    #             if workload_types:
    self.adaptation_strategies[workload_types[0]] = strategy

    #     def export_config(self) -Dict[str, Any]):
    #         """Export current configuration"""
    #         with self.lock:
    #             return {
    #                 'window_size': self.window_size,
    #                 'detection_threshold': self.detection_threshold,
    #                 'current_context': self.current_context.name,
    #                 'context_state': self.context_state.name,
    #                 'patterns': {
    #                     pid: {
    #                         'workload_types': [wt.name for wt in p.workload_types],
    #                         'characteristics': p.characteristics
    #                     }
    #                     for pid, p in self.patterns.items()
    #                 },
    #                 'strategies': {
    #                     wt.name: strategy
    #                     for wt, strategy in self.adaptation_strategies.items()
    #                 }
    #             }

    #     def import_config(self, config: Dict[str, Any]):
    #         """Import configuration"""
    #         with self.lock:
    self.window_size = config.get('window_size', self.window_size)
    self.detection_threshold = config.get('detection_threshold', self.detection_threshold)

    #             # Import patterns
    #             for pid, pattern_data in config.get('patterns', {}).items():
    #                 workload_types = [WorkloadType[wt] for wt in pattern_data.get('workload_types', [])]
    characteristics = pattern_data.get('characteristics', {})
    self.patterns[pid] = WorkloadPattern(pid, workload_types, characteristics)

    #             # Import strategies
    #             for wt_name, strategy in config.get('strategies', {}).items():
    #                 try:
    workload_type = WorkloadType[wt_name]
    self.adaptation_strategies[workload_type] = strategy
    #                 except KeyError:
                        logger.warning(f"Unknown workload type: {wt_name}")


# Global instance for easy access
_context_detector: Optional[ContextDetector] = None


def get_context_detector() -ContextDetector):
#     """Get the global context detector instance"""
#     global _context_detector
#     if _context_detector is None:
_context_detector = ContextDetector()
#     return _context_detector


def initialize_context_detector(window_size: int = 100, detection_threshold: float = 0.8) -ContextDetector):
#     """Initialize the global context detector"""
#     global _context_detector
_context_detector = ContextDetector(window_size, detection_threshold)
#     return _context_detector
