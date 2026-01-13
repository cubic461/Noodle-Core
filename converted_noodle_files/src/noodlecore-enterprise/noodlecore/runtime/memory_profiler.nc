# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Memory Profiler for Noodle Project

# This module provides comprehensive memory profiling capabilities for the Noodle project,
# including allocation tracking, hotspot detection, leak detection, and visualization tools.
# """

import functools
import gc
import inspect
import json
import logging
import math
import os
import threading
import time
import tracemalloc
import weakref
import collections.defaultdict,
import contextlib.contextmanager
import dataclasses.asdict,
import datetime.datetime,
import enum.Enum
import typing.Any,

import psutil

import ..versioning.Version,
import .nbc_runtime.core.error_handler.ErrorCategory,
import .nbc_runtime.core.resource_manager.ResourceManager,
import .nbc_runtime.performance.monitor.PerformanceMetric,

logger = logging.getLogger(__name__)


class MemoryEventType(Enum)
    #     """Types of memory events to track."""

    ALLOCATION = "allocation"
    DEALLOCATION = "deallocation"
    REALLOCATION = "reallocation"
    GC_COLLECTION = "gc_collection"
    LEAK_DETECTED = "leak_detected"
    HOTSPOT_IDENTIFIED = "hotspot_identified"


# @dataclass
class MemoryEvent
    #     """Represents a memory event in the profiling system."""

    #     event_type: MemoryEventType
    #     timestamp: float
    #     size: int
    stack_trace: Optional[List[Tuple[str, int, str]]] = None
    context: Optional[Dict[str, Any]] = None
    object_id: Optional[int] = None
    object_type: Optional[str] = None
    thread_id: Optional[int] = None

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary for serialization."""
    #         return {
    #             "event_type": self.event_type.value,
    #             "timestamp": self.timestamp,
    #             "size": self.size,
    #             "stack_trace": self.stack_trace,
    #             "context": self.context,
    #             "object_id": self.object_id,
    #             "object_type": self.object_type,
    #             "thread_id": self.thread_id,
    #         }


# @dataclass
class MemorySnapshot
    #     """Represents a memory snapshot at a specific point in time."""

    #     timestamp: float
    #     current_memory: int
    #     peak_memory: int
    #     total_allocated: int
    #     total_freed: int
    #     active_objects: int
    #     gc_collections: int
    context: Optional[Dict[str, Any]] = None

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary for serialization."""
    #         return {
    #             "timestamp": self.timestamp,
    #             "current_memory": self.current_memory,
    #             "peak_memory": self.peak_memory,
    #             "total_allocated": self.total_allocated,
    #             "total_freed": self.total_freed,
    #             "active_objects": self.active_objects,
    #             "gc_collections": self.gc_collections,
    #             "context": self.context,
    #         }


# @dataclass
class MemoryHotspot
    #     """Identifies a memory hotspot in the code."""

    #     location: str  # File and line number
    #     function_name: str
    #     total_allocated: int
    #     peak_usage: int
    #     allocation_count: int
    #     deallocation_count: int
    #     net_change: int
    context: Optional[Dict[str, Any]] = None

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary for serialization."""
    #         return {
    #             "location": self.location,
    #             "function_name": self.function_name,
    #             "total_allocated": self.total_allocated,
    #             "peak_usage": self.peak_usage,
    #             "allocation_count": self.allocation_count,
    #             "deallocation_count": self.deallocation_count,
    #             "net_change": self.net_change,
    #             "context": self.context,
    #         }


# @dataclass
class MemoryLeak
    #     """Represents a detected memory leak."""

    #     object_id: int
    #     object_type: str
    #     allocated_at: float
    #     last_seen: float
    #     size: int
    #     stack_trace: Optional[List[Tuple[str, int, str]]]
    potential_cause: Optional[str] = None
    context: Optional[Dict[str, Any]] = None

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary for serialization."""
    #         return {
    #             "object_id": self.object_id,
    #             "object_type": self.object_type,
    #             "allocated_at": self.allocated_at,
    #             "last_seen": self.last_seen,
    #             "size": self.size,
    #             "stack_trace": self.stack_trace,
    #             "potential_cause": self.potential_cause,
    #             "context": self.context,
    #         }


@versioned(
version = "1.0.0",
deprecated = False,
#     description="Memory profiler for tracking allocation patterns and detecting memory issues.",
constraints = VersionRange(min_version="1.0.0"),
compatibility = {
#         "backward_compatible": True,
#         "forward_compatible": False,
#         "notes": "Future versions may introduce additional profiling strategies and analysis algorithms.",
#     },
# )
class MemoryProfiler
    #     """Main memory profiler class for tracking allocation patterns and detecting memory issues."""

    #     def __init__(
    #         self,
    enabled: bool = True,
    track_allocations: bool = True,
    track_deallocations: bool = True,
    track_gc: bool = True,
    snapshot_interval: float = 1.0,
    max_events: int = 10000,
    max_snapshots: int = 1000,
    enable_hotspot_detection: bool = True,
    enable_leak_detection: bool = True,
    leak_threshold_percent: float = 5.0,
    leak_threshold_time: float = 60.0,
    #     ):
    #         """
    #         Initialize memory profiler.

    #         Args:
    #             enabled: Whether profiler is enabled
    #             track_allocations: Track memory allocations
    #             track_deallocations: Track memory deallocations
    #             track_gc: Track garbage collection events
    #             snapshot_interval: Interval for memory snapshots (seconds)
    #             max_events: Maximum number of events to store
    #             max_snapshots: Maximum number of snapshots to store
    #             enable_hotspot_detection: Enable hotspot detection
    #             enable_leak_detection: Enable leak detection
    #             leak_threshold_percent: Memory growth threshold for leak detection (%)
    #             leak_threshold_time: Time threshold for leak detection (seconds)
    #         """
    self.enabled = enabled
    self.track_allocations = track_allocations
    self.track_deallocations = track_deallocations
    self.track_gc = track_gc
    self.snapshot_interval = snapshot_interval
    self.max_events = max_events
    self.max_snapshots = max_snapshots
    self.enable_hotspot_detection = enable_hotspot_detection
    self.enable_leak_detection = enable_leak_detection
    self.leak_threshold_percent = leak_threshold_percent
    self.leak_threshold_time = leak_threshold_time

    #         # Data storage
    self.events: deque = deque(maxlen=max_events)
    self.snapshots: deque = deque(maxlen=max_snapshots)
    self.allocation_stats: Dict[str, Dict[str, Any]] = defaultdict(
    #             lambda: {
    #                 "total_allocated": 0,
    #                 "total_freed": 0,
    #                 "peak_usage": 0,
    #                 "allocation_count": 0,
    #                 "deallocation_count": 0,
    #                 "last_access": 0,
    #             }
    #         )

    #         # Leak detection
    self.allocated_objects: Dict[int, MemoryEvent] = {}
    self.suspicious_objects: Dict[int, MemoryLeak] = {}

    #         # Hotspot detection
    self.hotspots: List[MemoryHotspot] = []

    #         # State tracking
    self.start_time: Optional[float] = None
    self.last_snapshot_time: float = 0
    self.total_allocated: int = 0
    self.total_freed: int = 0
    self.peak_memory: int = 0
    self.current_memory: int = 0
    self.gc_collections: int = 0

    #         # Threading
    self._lock = threading.Lock()
    self._profiling_thread: Optional[threading.Thread] = None
    self._stop_event = threading.Event()
    self._original_tracefuncs: List[Callable] = []

    #         # Error handling
    self.error_handler = ErrorHandler()

    #         # Performance monitoring integration
    self.performance_monitor: Optional[PerformanceMonitor] = None

    #         # Mathematical object tracking
    self.mathematical_object_types: Set[str] = set()

    #         # Start profiling if enabled
    #         if self.enabled:
                self.start()

    #     def start(self):
    #         """Start memory profiling."""
    #         if not self.enabled:
    #             return

    #         with self._lock:
    #             if self._profiling_thread and self._profiling_thread.is_alive():
                    logger.warning("Memory profiler is already running")
    #                 return

    #             # Initialize tracemalloc
                tracemalloc.start()

    #             # Set up event tracking
                self._setup_event_tracking()

    #             # Start profiling thread
    self.start_time = time.time()
                self._stop_event.clear()
    self._profiling_thread = threading.Thread(
    target = self._profiling_loop, daemon=True
    #             )
                self._profiling_thread.start()

                logger.info("Memory profiler started")

    #     def stop(self):
    #         """Stop memory profiling."""
    #         if not self.enabled:
    #             return

    #         with self._lock:
    #             if not self._profiling_thread or not self._profiling_thread.is_alive():
                    logger.warning("Memory profiler is not running")
    #                 return

    #             # Stop profiling thread
                self._stop_event.set()
    #             if self._profiling_thread:
    self._profiling_thread.join(timeout = 5)

    #             # Clean up event tracking
                self._cleanup_event_tracking()

    #             # Stop tracemalloc
                tracemalloc.stop()

                logger.info("Memory profiler stopped")

    #     def _setup_event_tracking(self):
    #         """Set up memory event tracking."""
    #         # Track allocations
    #         if self.track_allocations:
                self._original_tracefuncs.append(sys.gettrace())
                sys.settrace(self._trace_allocations)

    #         # Track garbage collection
    #         if self.track_gc:
    self._original_gc_handlers = gc.get_debug()
                gc.set_debug(gc.DEBUG_STATS | gc.DEBUG_LEAK)
                gc.callbacks.append(self._gc_callback)

    #     def _cleanup_event_tracking(self):
    #         """Clean up event tracking."""
    #         # Restore original trace function
    #         if self._original_tracefuncs:
                sys.settrace(self._original_tracefuncs[-1])
    self._original_tracefuncs = []

    #         # Restore original GC handlers
    #         if hasattr(self, "_original_gc_handlers"):
                gc.set_debug(self._original_gc_handlers)
                gc.callbacks.remove(self._gc_callback)

    #     def _trace_allocations(self, frame, event, arg):
    #         """Trace memory allocations."""
    #         if event == "line" and self.enabled:
    #             try:
    #                 # Get memory info
    current, peak = tracemalloc.get_traced_memory()

    #                 # Create allocation event
    stack_trace = self._get_stack_trace(frame)
    #                 object_id = id(arg) if arg is not None else None

    event = MemoryEvent(
    event_type = MemoryEventType.ALLOCATION,
    timestamp = time.time(),
    size = current,
    stack_trace = stack_trace,
    object_id = object_id,
    #                     object_type=type(arg).__name__ if arg is not None else None,
    thread_id = threading.get_ident(),
    #                 )

                    self._record_event(event)

    #                 # Track object for leak detection
    #                 if object_id and arg is not None:
    self.allocated_objects[object_id] = event

    #             except Exception as e:
                    logger.debug(f"Error in allocation tracing: {e}")

    #         return self._trace_allocations

    #     def _gc_callback(self, phase, info):
    #         """Handle garbage collection events."""
    #         if not self.enabled or not self.track_gc:
    #             return

    #         try:
    event = MemoryEvent(
    event_type = MemoryEventType.GC_COLLECTION,
    timestamp = time.time(),
    size = 0,
    context = {"phase": phase, "info": info},
    thread_id = threading.get_ident(),
    #             )

                self._record_event(event)
    self.gc_collections + = 1

    #         except Exception as e:
                logger.debug(f"Error in GC callback: {e}")

    #     def _get_stack_trace(self, frame, depth: int = 5) -> List[Tuple[str, int, str]]:
    #         """Get stack trace from frame."""
    stack_trace = []
    current_frame = frame

    #         for _ in range(depth):
    #             if current_frame is None:
    #                 break

    filename = current_frame.f_code.co_filename
    lineno = current_frame.f_lineno
    funcname = current_frame.f_code.co_name

                stack_trace.append((filename, lineno, funcname))
    current_frame = current_frame.f_back

    #         return stack_trace

    #     def _record_event(self, event: MemoryEvent):
    #         """Record a memory event."""
    #         with self._lock:
                self.events.append(event)

    #             # Update allocation statistics
    #             if event.stack_trace:
    location = f"{event.stack_trace[0][0]}:{event.stack_trace[0][1]}"
    funcname = event.stack_trace[0][2]

    stats = self.allocation_stats[location]
    stats["last_access"] = event.timestamp

    #                 if event.event_type == MemoryEventType.ALLOCATION:
    stats["total_allocated"] + = event.size
    stats["allocation_count"] + = 1
    stats["peak_usage"] = max(stats["peak_usage"], event.size)
    #                 elif event.event_type == MemoryEventType.DEALLOCATION:
    stats["total_freed"] + = event.size
    stats["deallocation_count"] + = 1

    #             # Check for leaks
    #             if self.enable_leak_detection and event.object_id:
                    self._check_for_leaks(event)

    #             # Check for hotspots
    #             if self.enable_hotspot_detection and event.stack_trace:
                    self._check_for_hotspots(event)

    #     def _check_for_leaks(self, event: MemoryEvent):
    #         """Check for potential memory leaks."""
    #         if event.event_type == MemoryEventType.ALLOCATION:
    #             # Object was allocated, track it
    #             pass
    #         elif event.event_type == MemoryEventType.DEALLOCATION:
    #             # Object was deallocated, remove from tracking
    #             if event.object_id in self.allocated_objects:
    #                 del self.allocated_objects[event.object_id]
    #                 if event.object_id in self.suspicious_objects:
    #                     del self.suspicious_objects[event.object_id]
    #         else:
    #             # Check for objects that have been allocated but not deallocated
    current_time = time.time()
    #             for obj_id, alloc_event in list(self.allocated_objects.items()):
    #                 if (current_time - alloc_event.timestamp) > self.leak_threshold_time:
    #                     # This object has been allocated for a long time without being deallocated
    #                     if obj_id not in self.suspicious_objects:
    leak = MemoryLeak(
    object_id = obj_id,
    object_type = alloc_event.object_type or "unknown",
    allocated_at = alloc_event.timestamp,
    last_seen = current_time,
    size = alloc_event.size,
    stack_trace = alloc_event.stack_trace,
    potential_cause = "Object allocated but not deallocated",
    context = {"threshold_time": self.leak_threshold_time},
    #                         )
    self.suspicious_objects[obj_id] = leak
                            logger.warning(f"Potential memory leak detected: {leak}")

    #     def _check_for_hotspots(self, event: MemoryEvent):
    #         """Check for memory hotspots."""
    #         if not event.stack_trace:
    #             return

    location = f"{event.stack_trace[0][0]}:{event.stack_trace[0][1]}"
    funcname = event.stack_trace[0][2]

    #         # Get allocation statistics for this location
    stats = self.allocation_stats.get(
    #             location,
    #             {
    #                 "total_allocated": 0,
    #                 "total_freed": 0,
    #                 "peak_usage": 0,
    #                 "allocation_count": 0,
    #                 "deallocation_count": 0,
    #                 "last_access": 0,
    #             },
    #         )

    #         # Calculate net change
    net_change = stats["total_allocated"] - stats["total_freed"]

    #         # Check if this is a hotspot (high allocation count or significant net change)
    is_hotspot = (
    #             stats["allocation_count"] > 100
    #             or net_change > 1024 * 1024  # 1MB
                or (stats["allocation_count"] > 10 and net_change > 0)
    #         )

    #         if is_hotspot:
    #             # Check if we already have this hotspot
    existing = None
    #             for hotspot in self.hotspots:
    #                 if hotspot.location == location and hotspot.function_name == funcname:
    existing = hotspot
    #                     break

    #             if existing:
    #                 # Update existing hotspot
    existing.total_allocated = stats["total_allocated"]
    existing.peak_usage = stats["peak_usage"]
    existing.allocation_count = stats["allocation_count"]
    existing.deallocation_count = stats["deallocation_count"]
    existing.net_change = net_change
    #             else:
    #                 # Create new hotspot
    hotspot = MemoryHotspot(
    location = location,
    function_name = funcname,
    total_allocated = stats["total_allocated"],
    peak_usage = stats["peak_usage"],
    allocation_count = stats["allocation_count"],
    deallocation_count = stats["deallocation_count"],
    net_change = net_change,
    #                 )
                    self.hotspots.append(hotspot)
                    logger.info(f"Memory hotspot identified: {hotspot}")

    #     def _profiling_loop(self):
    #         """Main profiling loop."""
    #         while not self._stop_event.is_set():
    #             try:
    #                 # Take memory snapshot
                    self._take_snapshot()

    #                 # Sleep for interval
                    self._stop_event.wait(self.snapshot_interval)

    #             except Exception as e:
                    logger.error(f"Error in profiling loop: {e}")

    #     def _take_snapshot(self):
    #         """Take a memory snapshot."""
    #         try:
    current_time = time.time()

    #             # Get memory usage
    current, peak = tracemalloc.get_traced_memory()
    process = psutil.Process()
    process_memory = process.memory_info().rss

    #             # Update totals
    self.current_memory = current
    self.peak_memory = max(self.peak_memory, peak)
    self.total_allocated = math.add(current, self.total_freed)

    #             # Create snapshot
    snapshot = MemorySnapshot(
    timestamp = current_time,
    current_memory = current,
    peak_memory = self.peak_memory,
    total_allocated = self.total_allocated,
    total_freed = self.total_freed,
    active_objects = len(self.allocated_objects),
    gc_collections = self.gc_collections,
    #             )

    #             with self._lock:
                    self.snapshots.append(snapshot)

    #             # Send to performance monitor if available
    #             if self.performance_monitor:
    metric = PerformanceMetric(
    name = "memory_usage_bytes",
    value = current,
    unit = "bytes",
    timestamp = current_time,
    #                 )
                    self.performance_monitor.record_metric(metric)

    metric = PerformanceMetric(
    name = "memory_peak_bytes",
    value = peak,
    unit = "bytes",
    timestamp = current_time,
    #                 )
                    self.performance_monitor.record_metric(metric)

    self.last_snapshot_time = current_time

    #         except Exception as e:
                logger.debug(f"Error taking memory snapshot: {e}")

    #     def get_memory_usage(self) -> Dict[str, Any]:
    #         """Get current memory usage statistics."""
    #         with self._lock:
    #             return {
    #                 "current_memory": self.current_memory,
    #                 "peak_memory": self.peak_memory,
    #                 "total_allocated": self.total_allocated,
    #                 "total_freed": self.total_freed,
                    "active_objects": len(self.allocated_objects),
    #                 "gc_collections": self.gc_collections,
    #                 "uptime": time.time() - self.start_time if self.start_time else 0,
                    "hotspot_count": len(self.hotspots),
                    "suspicious_leak_count": len(self.suspicious_objects),
    #             }

    #     def get_events(self, limit: Optional[int] = None) -> List[MemoryEvent]:
    #         """Get memory events."""
    #         with self._lock:
    events = list(self.events)
    #             if limit:
    events = math.subtract(events[, limit:])
    #             return events

    #     def get_snapshots(self, limit: Optional[int] = None) -> List[MemorySnapshot]:
    #         """Get memory snapshots."""
    #         with self._lock:
    snapshots = list(self.snapshots)
    #             if limit:
    snapshots = math.subtract(snapshots[, limit:])
    #             return snapshots

    #     def get_hotspots(self, limit: Optional[int] = None) -> List[MemoryHotspot]:
    #         """Get memory hotspots."""
    #         with self._lock:
    hotspots = sorted(
    self.hotspots, key = lambda h: h.total_allocated, reverse=True
    #             )
    #             if limit:
    hotspots = hotspots[:limit]
    #             return hotspots

    #     def get_suspicious_leaks(self) -> List[MemoryLeak]:
    #         """Get suspicious memory leaks."""
    #         with self._lock:
                return list(self.suspicious_objects.values())

    #     def get_allocation_stats(self) -> Dict[str, Dict[str, Any]]:
    #         """Get allocation statistics by location."""
    #         with self._lock:
                return dict(self.allocation_stats)

    #     def generate_report(self) -> Dict[str, Any]:
    #         """Generate comprehensive memory profiling report."""
    #         with self._lock:
    #             # Get current stats
    usage = self.get_memory_usage()
    hotspots = self.get_hotspots()
    leaks = self.get_suspicious_leaks()
    snapshots = list(self.snapshots)

    #             # Calculate trends
    memory_trend = "stable"
    #             if len(snapshots) >= 2:
    recent = math.subtract(snapshots[, 5:]  # Last 5 snapshots)
    #                 if len(recent) >= 2:
    first = recent[0].current_memory
    last = math.subtract(recent[, 1].current_memory)
    #                     if last > first * 1.1:  # 10% increase
    memory_trend = "increasing"
    #                     elif last < first * 0.9:  # 10% decrease
    memory_trend = "decreasing"

    #             # Generate recommendations
    recommendations = []

    #             if memory_trend == "increasing":
    #                 recommendations.append("Memory usage is increasing - check for leaks")

    #             if hotspots:
                    recommendations.append(
                        f"Found {len(hotspots)} memory hotspots - consider optimization"
    #                 )

    #             if leaks:
                    recommendations.append(
                        f"Found {len(leaks)} potential memory leaks - investigate"
    #                 )

    #             # Create report
    report = {
                    "timestamp": datetime.now().isoformat(),
    #                 "summary": {
    #                     "memory_trend": memory_trend,
                        "current_memory_mb": usage["current_memory"] / (1024 * 1024),
                        "peak_memory_mb": usage["peak_memory"] / (1024 * 1024),
                        "total_allocated_mb": usage["total_allocated"] / (1024 * 1024),
    #                     "active_objects": usage["active_objects"],
    #                     "gc_collections": usage["gc_collections"],
    #                     "uptime_seconds": usage["uptime"],
    #                     "hotspot_count": usage["hotspot_count"],
    #                     "suspicious_leak_count": usage["suspicious_leak_count"],
    #                 },
    #                 "hotspots": [hs.to_dict() for hs in hotspots],
    #                 "leaks": [leak.to_dict() for leak in leaks],
    #                 "recommendations": recommendations,
    #                 "snapshots": [
    #                     snap.to_dict() for snap in snapshots[-10:]
    #                 ],  # Last 10 snapshots
    #             }

    #             return report

    #     def export_data(self, filepath: str):
    #         """Export profiling data to file."""
    #         try:
    data = {
    #                 "events": [event.to_dict() for event in self.get_events()],
    #                 "snapshots": [snapshot.to_dict() for snapshot in self.get_snapshots()],
    #                 "hotspots": [hotspot.to_dict() for hotspot in self.get_hotspots()],
    #                 "leaks": [leak.to_dict() for leak in self.get_suspicious_leaks()],
                    "allocation_stats": self.get_allocation_stats(),
                    "report": self.generate_report(),
    #             }

    #             with open(filepath, "w") as f:
    json.dump(data, f, indent = 2)

                logger.info(f"Memory profiling data exported to {filepath}")

    #         except Exception as e:
                logger.error(f"Error exporting profiling data: {e}")

    #     def clear_data(self):
    #         """Clear all profiling data."""
    #         with self._lock:
                self.events.clear()
                self.snapshots.clear()
                self.allocation_stats.clear()
                self.allocated_objects.clear()
                self.suspicious_objects.clear()
                self.hotspots.clear()
    self.total_allocated = 0
    self.total_freed = 0
    self.peak_memory = 0
    self.current_memory = 0
    self.gc_collections = 0

                logger.info("Memory profiling data cleared")

    #     def set_performance_monitor(self, monitor: PerformanceMonitor):
    #         """Set performance monitor for integration."""
    self.performance_monitor = monitor

    #     def track_mathematical_object(self, obj: Any):
    #         """Track a mathematical object for memory analysis."""
    #         if not self.enabled:
    #             return

    obj_type = type(obj).__name__
            self.mathematical_object_types.add(obj_type)

    #         # Create allocation event for mathematical object
    event = MemoryEvent(
    event_type = MemoryEventType.ALLOCATION,
    timestamp = time.time(),
    size = self._get_object_size(obj),
    stack_trace = self._get_stack_trace(inspect.currentframe()),
    object_id = id(obj),
    object_type = obj_type,
    thread_id = threading.get_ident(),
    context = {"mathematical_object": True},
    #         )

            self._record_event(event)
    self.allocated_objects[id(obj)] = event

    #     def _get_object_size(self, obj: Any) -> int:
    #         """Get size of object in bytes."""
    #         try:
                return sys.getsizeof(obj)
    #         except:
    #             return 0

    #     @contextmanager
    #     def profile_context(self, context_name: str):
    #         """Context manager for profiling specific code blocks."""
    #         if not self.enabled:
    #             yield
    #             return

    start_time = time.time()
    start_memory = self.current_memory

    #         try:
    #             yield
    #         finally:
    end_time = time.time()
    end_memory = self.current_memory

    #             # Create context event
    event = MemoryEvent(
    event_type = MemoryEventType.ALLOCATION,
    timestamp = end_time,
    size = math.subtract(end_memory, start_memory,)
    context = {
    #                     "context_name": context_name,
    #                     "duration": end_time - start_time,
    #                     "memory_change": end_memory - start_memory,
    #                 },
    #             )

                self._record_event(event)

    #     def __enter__(self):
    #         """Context manager entry."""
    #         return self

    #     def __exit__(self, exc_type, exc_val, exc_tb):
    #         """Context manager exit."""
            self.stop()

    #     def __str__(self) -> str:
    #         """String representation."""
    usage = self.get_memory_usage()
            return (
    f"MemoryProfiler(enabled = {self.enabled}, "
    f"current = {usage['current_memory']/(1024*1024):.2f}MB, "
    f"peak = {usage['peak_memory']/(1024*1024):.2f}MB, "
    f"hotspots = {usage['hotspot_count']}, "
    f"leaks = {usage['suspicious_leak_count']})"
    #         )


# Global profiler instance
_global_profiler: Optional[MemoryProfiler] = None


def get_global_profiler() -> MemoryProfiler:
#     """Get the global memory profiler instance."""
#     global _global_profiler
#     if _global_profiler is None:
_global_profiler = MemoryProfiler()
#     return _global_profiler


def start_profiling(**kwargs) -> MemoryProfiler:
#     """Start memory profiling with optional configuration."""
#     global _global_profiler
#     if _global_profiler is None:
_global_profiler = math.multiply(MemoryProfiler(, *kwargs))
#     else:
        _global_profiler.start()
#     return _global_profiler


function stop_profiling()
    #     """Stop global memory profiling."""
    #     global _global_profiler
    #     if _global_profiler:
            _global_profiler.stop()


def profile_function(func: Callable) -> Callable:
#     """Decorator to profile a function's memory usage."""

    @functools.wraps(func)
#     def wrapper(*args, **kwargs):
profiler = get_global_profiler()

#         with profiler.profile_context(func.__name__):
            return func(*args, **kwargs)

#     return wrapper


# Required imports
import sys
