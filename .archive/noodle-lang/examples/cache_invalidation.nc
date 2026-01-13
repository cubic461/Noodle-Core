# Converted from Python to NoodleCore
# Original file: src

# """
# Cache Invalidation Module
# ------------------------

# This module provides comprehensive cache invalidation strategies to ensure data consistency
# while maintaining optimal cache performance across different cache types.
# """

import hashlib
import heapq
import json
import logging
import pickle
import random
import re
import statistics
import threading
import time
import uuid
import weakref
import abc.ABC
import collections.OrderedDict
import concurrent.futures.ThreadPoolExecutor
from dataclasses import dataclass
import datetime.datetime
import enum.Enum
import typing.(
#     Any,
#     Callable,
#     Dict,
#     Generic,
#     List,
#     Optional,
#     Set,
#     Tuple,
#     TypeVar,
#     Union,
# )


class InvalidationStrategy(Enum)
    #     """Cache invalidation strategies."""

    TIME_BASED = "time_based"
    DEPENDENCY_BASED = "dependency_based"
    EVENT_DRIVEN = "event_driven"
    WRITE_THROUGH = "write_through"
    WRITE_AROUND = "write_around"
    ADAPTIVE = "adaptive"
    PROBABILISTIC = "probabilistic"
    VERSION_BASED = "version_based"
    HIERARCHICAL = "hierarchical"
    MANUAL = "manual"


class CacheType(Enum)
    #     """Types of cache entries."""

    MATHEMATICAL_OBJECT = "mathematical_object"
    DATABASE_QUERY = "database_query"
    COMPUTATION_RESULT = "computation_result"
    INTERMEDIATE_DATA = "intermediate_data"
    METADATA = "metadata"


class InvalidationEvent(Enum)
    #     """Types of invalidation events."""

    DATA_UPDATE = "data_update"
    SCHEMA_CHANGE = "schema_change"
    TIMEOUT = "timeout"
    DEPENDENCY_CHANGE = "dependency_change"
    MANUAL_INVALIDATION = "manual_invalidation"
    SYSTEM_SHUTDOWN = "system_shutdown"
    SPACE_PRESSURE = "space_pressure"


dataclass
class CacheEntry
    #     """Represents a cache entry with metadata."""

    #     key: str
    #     value: Any
    #     cache_type: CacheType
    #     created_at: float
    #     last_accessed: float
    access_count: int = 0
    ttl: Optional[float] = None
    version: str = "1.0"
    dependencies: Set[str] = field(default_factory=set)
    tags: Set[str] = field(default_factory=set)
    size: int = 0
    checksum: str = ""
    volatile: bool = False
    probability_factor: float = 1.0

    #     def is_expired(self, current_time: float = None) -bool):
    #         """Check if the entry has expired based on TTL."""
    #         if self.ttl is None:
    #             return False
    current_time = current_time or time.time()
    #         return current_time - self.created_at self.ttl

    #     def update_access(self):
    """None)"""
    #         """Update access metadata."""
    self.last_accessed = time.time()
    self.access_count + = 1

    #     def calculate_checksum(self) -str):
    #         """Calculate checksum of the value."""
    #         if isinstance(self.value, (str, bytes)):
    data = self.value
    #         else:
    data = pickle.dumps(self.value)

            return hashlib.sha256(data).hexdigest()

    #     def matches_checksum(self) -bool):
    #         """Verify if the current value matches the stored checksum."""
    return self.calculate_checksum() = = self.checksum


dataclass
class DependencyNode
    #     """Represents a node in the dependency graph."""

    #     key: str
    depends_on: Set[str] = field(default_factory=set)
    dependents: Set[str] = field(default_factory=set)
    invalidation_count: int = 0
    last_invalidated: float = 0.0

    #     def add_dependency(self, key: str) -None):
    #         """Add a dependency to this node."""
            self.depends_on.add(key)

    #     def add_dependent(self, key: str) -None):
    #         """Add a dependent to this node."""
            self.dependents.add(key)

    #     def invalidate(self) -None):
    #         """Mark this node as invalidated."""
    self.invalidation_count + = 1
    self.last_invalidated = time.time()


dataclass
class InvalidationEventRecord
    #     """Represents an invalidation event record."""

    #     event_id: str
    #     timestamp: float
    #     event_type: InvalidationEvent
    #     cache_key: str
    #     cache_type: CacheType
    #     reason: str
    triggered_by: str = "system"
    metadata: Dict[str, Any] = field(default_factory=dict)


dataclass
class CacheInvalidationConfig
    #     """Configuration for cache invalidation."""

    #     # Time-based invalidation
    enable_time_based: bool = True
    default_ttl: float = 3600.0  # 1 hour
    ttl_by_cache_type: Dict[CacheType, float] = field(
    default_factory = lambda: {
    #             CacheType.MATHEMATICAL_OBJECT: 7200.0,  # 2 hours
    #             CacheType.DATABASE_QUERY: 1800.0,  # 30 minutes
    #             CacheType.COMPUTATION_RESULT: 3600.0,  # 1 hour
    #             CacheType.INTERMEDIATE_DATA: 900.0,  # 15 minutes
    #             CacheType.METADATA: 86400.0,  # 24 hours
    #         }
    #     )

    #     # Dependency-based invalidation
    enable_dependency_tracking: bool = True
    dependency_check_interval: float = 300.0  # 5 minutes
    max_dependency_depth: int = 5

    #     # Event-driven invalidation
    enable_event_driven: bool = True
    event_listeners: Dict[str, Callable] = field(default_factory=dict)
    event_history_size: int = 1000

    #     # Write-through and write-around
    enable_write_through: bool = True
    enable_write_around: bool = False
    write_batch_size: int = 100
    write_batch_timeout: float = 1.0  # 1 second

    #     # Adaptive invalidation
    enable_adaptive: bool = True
    volatility_threshold: float = 0.7
    access_pattern_window: float = 3600.0  # 1 hour
    adaptation_interval: float = 600.0  # 10 minutes

    #     # Probabilistic invalidation
    enable_probabilistic: bool = True
    stale_probability: float = 0.01  # 1% chance per check
    volatility_factor: float = 2.0

    #     # Version-based invalidation
    enable_version_based: bool = True
    version_check_interval: float = 1800.0  # 30 minutes
    version_history_size: int = 100

    #     # Hierarchical invalidation
    enable_hierarchical: bool = True
    hierarchy_levels: int = 3
    parent_child_ratio: float = 0.3

    #     # Manual invalidation
    enable_manual: bool = True
    bulk_operation_limit: int = 1000

    #     # Logging and analytics
    enable_logging: bool = True
    log_level: str = "INFO"
    analytics_history_size: int = 5000
    performance_metrics_interval: float = 60.0  # 1 minute


class CacheInvalidationStrategy(ABC)
    #     """Abstract base class for cache invalidation strategies."""

    #     def __init__(self, cache: Any, config: CacheInvalidationConfig):""Initialize the invalidation strategy.

    #         Args:
    #             cache: Cache instance to apply invalidation to
    #             config: Invalidation configuration
    #         """
    self.cache = cache
    self.config = config
    self.logger = logging.getLogger(__name__)
    self._stop_event = threading.Event()
    self._strategy_thread = None

    #     @abstractmethod
    #     def invalidate(self, key: str, reason: str = "") -bool):
    #         """Invalidate a specific cache entry.

    #         Args:
    #             key: Cache key to invalidate
    #             reason: Reason for invalidation

    #         Returns:
    #             True if successful, False otherwise
    #         """
    #         pass

    #     @abstractmethod
    #     def invalidate_all(self, pattern: str = "", reason: str = "") -int):
    #         """Invalidate multiple cache entries.

    #         Args:
                pattern: Pattern to match keys (optional)
    #             reason: Reason for invalidation

    #         Returns:
    #             Number of entries invalidated
    #         """
    #         pass

    #     def start_background_tasks(self):
    #         """Start background tasks for the strategy."""
    #         pass

    #     def stop_background_tasks(self):
    #         """Stop background tasks for the strategy."""
    #         if self._strategy_thread is not None:
                self._stop_event.set()
                self._strategy_thread.join()
    self._strategy_thread = None


class TimeBasedInvalidation(CacheInvalidationStrategy)
    #     """Time-based invalidation strategy with configurable TTL."""

    #     def __init__(self, cache: Any, config: CacheInvalidationConfig):""Initialize time-based invalidation."""
            super().__init__(cache, config)
    self.expired_entries: Dict[str, float] = {}
            self._start_cleanup_thread()

    #     def _start_cleanup_thread(self):
    #         """Start background thread for expired entry cleanup."""

    #         def cleanup_worker():
    #             while not self._stop_event.wait(60.0):  # Check every minute
    #                 try:
                        self._cleanup_expired_entries()
    #                 except Exception as e:
                        self.logger.error(f"Error in cleanup thread: {e}")

    self._strategy_thread = threading.Thread(target=cleanup_worker, daemon=True)
            self._strategy_thread.start()

    #     def _cleanup_expired_entries(self):
    #         """Clean up expired entries from the cache."""
    current_time = time.time()
    expired_keys = []

    #         with self.cache._cache_lock:
    #             for key, entry in self.cache._cache.items():
    #                 if entry.is_expired(current_time):
                        expired_keys.append(key)

    #             for key in expired_keys:
    #                 if key in self.cache._cache:
    #                     del self.cache._cache[key]
                        self.logger.debug(f"Expired entry removed: {key}")

    #     def invalidate(self, key: str, reason: str = "") -bool):
    #         """Invalidate a specific cache entry."""
    #         if not self.config.enable_time_based:
    #             return False

    #         with self.cache._cache_lock:
    #             if key in self.cache._cache:
    #                 del self.cache._cache[key]
                    self.logger.info(f"Time-based invalidation: {key} - {reason}")
    #                 return True
    #         return False

    #     def invalidate_all(self, pattern: str = "", reason: str = "") -int):
    #         """Invalidate multiple cache entries based on pattern."""
    #         if not self.config.enable_time_based:
    #             return 0

    current_time = time.time()
    invalidated_count = 0

    #         with self.cache._cache_lock:
    keys_to_remove = []

    #             for key, entry in self.cache._cache.items():
    #                 if pattern and not re.search(pattern, key):
    #                     continue

    #                 if entry.is_expired(current_time):
                        keys_to_remove.append(key)

    #             for key in keys_to_remove:
    #                 del self.cache._cache[key]
    invalidated_count + = 1

    #             if invalidated_count 0):
                    self.logger.info(
    #                     f"Time-based batch invalidation: {invalidated_count} entries - {reason}"
    #                 )

    #         return invalidated_count

    #     def stop_background_tasks(self):
    #         """Stop background tasks."""
            super().stop_background_tasks()
            self.expired_entries.clear()


class DependencyBasedInvalidation(CacheInvalidationStrategy)
    #     """Dependency-based invalidation strategy."""

    #     def __init__(self, cache: Any, config: CacheInvalidationConfig):""Initialize dependency-based invalidation."""
            super().__init__(cache, config)
    self.dependency_graph: Dict[str, DependencyNode] = {}
            self._start_dependency_checker()

    #     def _start_dependency_checker(self):
    #         """Start background thread for dependency checking."""

    #         def dependency_worker():
    #             while not self._stop_event.wait(self.config.dependency_check_interval):
    #                 try:
                        self._check_dependencies()
    #                 except Exception as e:
                        self.logger.error(f"Error in dependency checker: {e}")

    self._strategy_thread = threading.Thread(target=dependency_worker, daemon=True)
            self._strategy_thread.start()

    #     def _check_dependencies(self):
    #         """Check and invalidate entries with invalidated dependencies."""
    current_time = time.time()
    keys_to_invalidate = set()

    #         with self.cache._cache_lock:
    #             # Find all entries with invalidated dependencies
    #             for key, entry in self.cache._cache.items():
    #                 for dep_key in entry.dependencies:
    #                     if dep_key in self.dependency_graph:
    dep_node = self.dependency_graph[dep_key]
    #                         if dep_node.last_invalidated entry.last_accessed):
                                keys_to_invalidate.add(key)
    #                             break

    #             # Invalidate dependent entries
    #             for key in keys_to_invalidate:
    #                 if key in self.cache._cache:
    #                     del self.cache._cache[key]
                        self.logger.debug(f"Dependency-based invalidation: {key}")

    #     def add_dependency(self, key: str, depends_on: str) -None):
    #         """Add a dependency between two cache entries."""
    #         if not self.config.enable_dependency_tracking:
    #             return

    #         if key not in self.dependency_graph:
    self.dependency_graph[key] = DependencyNode(key)

    #         if depends_on not in self.dependency_graph:
    self.dependency_graph[depends_on] = DependencyNode(depends_on)

            self.dependency_graph[key].add_dependency(depends_on)
            self.dependency_graph[depends_on].add_dependent(key)

    #     def invalidate(self, key: str, reason: str = "") -bool):
    #         """Invalidate a specific cache entry and its dependents."""
    #         if not self.config.enable_dependency_tracking:
    #             return False

    invalidated_count = 0

    #         with self.cache._cache_lock:
    #             # Invalidate the specified key
    #             if key in self.cache._cache:
    #                 del self.cache._cache[key]
    invalidated_count + = 1

    #                 # Mark dependency node as invalidated
    #                 if key in self.dependency_graph:
                        self.dependency_graph[key].invalidate()

    #                 # Invalidate all dependents
                    self._invalidate_dependents(key)

                    self.logger.info(f"Dependency-based invalidation: {key} - {reason}")

    #         return invalidated_count 0

    #     def _invalidate_dependents(self, key): str):
    #         """Recursively invalidate all dependents of a key."""
    #         if key not in self.dependency_graph:
    #             return

    #         for dependent_key in self.dependency_graph[key].dependents:
    #             if dependent_key in self.cache._cache:
    #                 del self.cache._cache[dependent_key]
                    self.logger.debug(f"Invalidating dependent: {dependent_key}")

    #                 # Recursively invalidate dependents of dependents
                    self._invalidate_dependents(dependent_key)

    #     def invalidate_all(self, pattern: str = "", reason: str = "") -int):
    #         """Invalidate multiple cache entries and their dependents."""
    #         if not self.config.enable_dependency_tracking:
    #             return 0

    invalidated_count = 0

    #         with self.cache._cache_lock:
    keys_to_invalidate = []

    #             # Find keys matching the pattern
    #             for key in self.cache._cache.keys():
    #                 if pattern and not re.search(pattern, key):
    #                     continue
                    keys_to_invalidate.append(key)

    #             # Invalidate each key and its dependents
    #             for key in keys_to_invalidate:
    #                 if key in self.cache._cache:
    #                     del self.cache._cache[key]
    invalidated_count + = 1

    #                     # Mark dependency node as invalidated
    #                     if key in self.dependency_graph:
                            self.dependency_graph[key].invalidate()

    #                     # Invalidate all dependents
                        self._invalidate_dependents(key)

    #             if invalidated_count 0):
                    self.logger.info(
    #                     f"Dependency-based batch invalidation: {invalidated_count} entries - {reason}"
    #                 )

    #         return invalidated_count

    #     def stop_background_tasks(self):
    #         """Stop background tasks."""
            super().stop_background_tasks()
            self.dependency_graph.clear()


class EventDrivenInvalidation(CacheInvalidationStrategy)
    #     """Event-driven invalidation strategy."""

    #     def __init__(self, cache: Any, config: CacheInvalidationConfig):""Initialize event-driven invalidation."""
            super().__init__(cache, config)
    self.event_history: List[InvalidationEventRecord] = []
    self.event_handlers: Dict[InvalidationEvent, List[Callable]] = defaultdict(list)
            self._start_event_processor()

    #     def _start_event_processor(self):
    #         """Start background thread for event processing."""

    #         def event_worker():
    #             while not self._stop_event.wait(30.0):  # Check every 30 seconds
    #                 try:
                        self._process_events()
    #                 except Exception as e:
                        self.logger.error(f"Error in event processor: {e}")

    self._strategy_thread = threading.Thread(target=event_worker, daemon=True)
            self._strategy_thread.start()

    #     def _process_events(self):
    #         """Process pending invalidation events."""
    #         # This would typically connect to event sources like database change listeners
    #         # For now, we'll simulate some events
    #         pass

    #     def register_event_listener(self, event_type: InvalidationEvent, handler: Callable):
    #         """Register an event listener for specific event types."""
            self.event_handlers[event_type].append(handler)

    #     def emit_event(
    #         self,
    #         event_type: InvalidationEvent,
    #         cache_key: str,
    #         cache_type: CacheType,
    #         reason: str,
    metadata: Dict[str, Any] = None,
    #     ):
    #         """Emit an invalidation event."""
    event_record = InvalidationEventRecord(
    event_id = str(uuid.uuid4()),
    timestamp = time.time(),
    event_type = event_type,
    cache_key = cache_key,
    cache_type = cache_type,
    reason = reason,
    metadata = metadata or {},
    #         )

            self.event_history.append(event_record)

    #         # Keep only recent events
    #         if len(self.event_history) self.config.event_history_size):
    self.event_history = self.event_history[ - self.config.event_history_size :]

    #         # Notify event handlers
    #         for handler in self.event_handlers[event_type]:
    #             try:
                    handler(event_record)
    #             except Exception as e:
                    self.logger.error(f"Error in event handler: {e}")

    #     def invalidate(self, key: str, reason: str = "") -bool):
    #         """Invalidate a specific cache entry due to an event."""
    #         if not self.config.enable_event_driven:
    #             return False

    #         with self.cache._cache_lock:
    #             if key in self.cache._cache:
    entry = self.cache._cache[key]
    #                 del self.cache._cache[key]

    #                 # Emit invalidation event
                    self.emit_event(
    #                     InvalidationEvent.DATA_UPDATE,
    #                     key,
    #                     entry.cache_type,
    #                     reason or "Event-driven invalidation",
    #                 )

                    self.logger.info(f"Event-driven invalidation: {key} - {reason}")
    #                 return True
    #         return False

    #     def invalidate_all(self, pattern: str = "", reason: str = "") -int):
    #         """Invalidate multiple cache entries due to an event."""
    #         if not self.config.enable_event_driven:
    #             return 0

    invalidated_count = 0

    #         with self.cache._cache_lock:
    keys_to_remove = []

    #             for key, entry in self.cache._cache.items():
    #                 if pattern and not re.search(pattern, key):
    #                     continue
                    keys_to_remove.append(key)

    #             for key in keys_to_remove:
    entry = self.cache._cache[key]
    #                 del self.cache._cache[key]

    #                 # Emit invalidation event
                    self.emit_event(
    #                     InvalidationEvent.DATA_UPDATE,
    #                     key,
    #                     entry.cache_type,
    #                     reason or "Event-driven batch invalidation",
    #                 )

    invalidated_count + = 1

    #             if invalidated_count 0):
                    self.logger.info(
    #                     f"Event-driven batch invalidation: {invalidated_count} entries - {reason}"
    #                 )

    #         return invalidated_count

    #     def stop_background_tasks(self):
    #         """Stop background tasks."""
            super().stop_background_tasks()
            self.event_history.clear()
            self.event_handlers.clear()


class WriteThroughInvalidation(CacheInvalidationStrategy)
    #     """Write-through cache invalidation strategy."""

    #     def __init__(self, cache: Any, config: CacheInvalidationConfig):""Initialize write-through invalidation."""
            super().__init__(cache, config)
    self.write_queue: List[Tuple[str, Any]] = []
    self.write_lock = threading.Lock()
            self._start_writer_thread()

    #     def _start_writer_thread(self):
    #         """Start background thread for writing through to persistent storage."""

    #         def writer_worker():
    #             while not self._stop_event.wait(self.config.write_batch_timeout):
    #                 try:
                        self._process_write_queue()
    #                 except Exception as e:
                        self.logger.error(f"Error in writer thread: {e}")

    self._strategy_thread = threading.Thread(target=writer_worker, daemon=True)
            self._strategy_thread.start()

    #     def _process_write_queue(self):
    #         """Process the write queue and write to persistent storage."""
    #         if not self.write_queue:
    #             return

    batch = []
    #         with self.write_lock:
    #             if self.write_queue:
    batch = self.write_queue[: self.config.write_batch_size]
    self.write_queue = self.write_queue[self.config.write_batch_size :]

            # Write to persistent storage (implementation would depend on the specific storage)
    #         for key, value in batch:
    #             try:
    #                 # This would be the actual write to persistent storage
                    # self.persistent_storage.write(key, value)
                    self.logger.debug(f"Write-through: {key}")
    #             except Exception as e:
                    self.logger.error(f"Error writing to persistent storage: {e}")

    #     def write_through(self, key: str, value: Any) -bool):
    #         """Write through to persistent storage."""
    #         if not self.config.enable_write_through:
    #             return False

    #         with self.write_lock:
                self.write_queue.append((key, value))

    #             # If queue is full, process immediately
    #             if len(self.write_queue) >= self.config.write_batch_size:
                    self._process_write_queue()

    #         return True

    #     def invalidate(self, key: str, reason: str = "") -bool):
    #         """Invalidate a specific cache entry and write through."""
    #         if not self.config.enable_write_through:
    #             return False

    #         with self.cache._cache_lock:
    #             if key in self.cache._cache:
    entry = self.cache._cache[key]

    #                 # Write through to persistent storage before invalidation
                    self.write_through(key, entry.value)

    #                 # Invalidate from cache
    #                 del self.cache._cache[key]

                    self.logger.info(f"Write-through invalidation: {key} - {reason}")
    #                 return True
    #         return False

    #     def invalidate_all(self, pattern: str = "", reason: str = "") -int):
    #         """Invalidate multiple cache entries and write through."""
    #         if not self.config.enable_write_through:
    #             return 0

    invalidated_count = 0

    #         with self.cache._cache_lock:
    keys_to_remove = []

    #             for key, entry in self.cache._cache.items():
    #                 if pattern and not re.search(pattern, key):
    #                     continue
                    keys_to_remove.append(key)

    #             # Write through and invalidate
    #             for key in keys_to_remove:
    entry = self.cache._cache[key]
                    self.write_through(key, entry.value)
    #                 del self.cache._cache[key]
    invalidated_count + = 1

    #             if invalidated_count 0):
                    self.logger.info(
    #                     f"Write-through batch invalidation: {invalidated_count} entries - {reason}"
    #                 )

    #         return invalidated_count

    #     def stop_background_tasks(self):
    #         """Stop background tasks and process remaining writes."""
            super().stop_background_tasks()
            self._process_write_queue()
            self.write_queue.clear()


class WriteAroundInvalidation(CacheInvalidationStrategy)
    #     """Write-around cache invalidation strategy."""

    #     def __init__(self, cache: Any, config: CacheInvalidationConfig):""Initialize write-around invalidation."""
            super().__init__(cache, config)
    self.write_threshold = 0.8  # Invalidate when cache is 80% full

    #     def invalidate(self, key: str, reason: str = "") -bool):
    #         """Invalidate a specific cache entry without writing through."""
    #         if not self.config.enable_write_around:
    #             return False

    #         with self.cache._cache_lock:
    #             if key in self.cache._cache:
    #                 del self.cache._cache[key]
                    self.logger.info(f"Write-around invalidation: {key} - {reason}")
    #                 return True
    #         return False

    #     def invalidate_all(self, pattern: str = "", reason: str = "") -int):
    #         """Invalidate multiple cache entries without writing through."""
    #         if not self.config.enable_write_around:
    #             return 0

    invalidated_count = 0

    #         with self.cache._cache_lock:
    keys_to_remove = []

    #             for key in self.cache._cache.keys():
    #                 if pattern and not re.search(pattern, key):
    #                     continue
                    keys_to_remove.append(key)

    #             for key in keys_to_remove:
    #                 del self.cache._cache[key]
    invalidated_count + = 1

    #             if invalidated_count 0):
                    self.logger.info(
    #                     f"Write-around batch invalidation: {invalidated_count} entries - {reason}"
    #                 )

    #         return invalidated_count

    #     def check_space_pressure(self) -bool):
    #         """Check if cache space pressure requires invalidation."""
    #         with self.cache._cache_lock:
    current_size = len(self.cache._cache)
    max_size = getattr(self.cache.config, "max_size", 1000)
    #             return current_size / max_size self.write_threshold


class AdaptiveInvalidation(CacheInvalidationStrategy)
    #     """Adaptive invalidation based on access patterns and data volatility."""

    #     def __init__(self, cache): Any, config: CacheInvalidationConfig):
    #         """Initialize adaptive invalidation."""
            super().__init__(cache, config)
    self.access_patterns: Dict[str, List[float]] = defaultdict(list)
    self.volatility_scores: Dict[str, float] = {}
            self._start_adaptation_thread()

    #     def _start_adaptation_thread(self):
    #         """Start background thread for adaptation analysis."""

    #         def adaptation_worker():
    #             while not self._stop_event.wait(self.config.adaptation_interval):
    #                 try:
                        self._analyze_access_patterns()
                        self._update_volatility_scores()
                        self._apply_adaptive_invalidation()
    #                 except Exception as e:
                        self.logger.error(f"Error in adaptation worker: {e}")

    self._strategy_thread = threading.Thread(target=adaptation_worker, daemon=True)
            self._strategy_thread.start()

    #     def _analyze_access_patterns(self):
    #         """Analyze access patterns for all cache entries."""
    current_time = time.time()
    window_start = current_time - self.config.access_pattern_window

    #         with self.cache._cache_lock:
    #             for key, entry in self.cache._cache.items():
    #                 # Record access if within window
    #                 if entry.last_accessed >= window_start:
                        self.access_patterns[key].append(entry.last_accessed)

    #                 # Keep only recent accesses
    recent_accesses = [
    #                     t for t in self.access_patterns[key] if t >= window_start
    #                 ]
    #                 if len(recent_accesses) != len(self.access_patterns[key]):
    self.access_patterns[key] = recent_accesses

    #     def _update_volatility_scores(self):
    #         """Update volatility scores for cache entries."""
    current_time = time.time()

    #         with self.cache._cache_lock:
    #             for key, entry in self.cache._cache.items():
    #                 # Calculate volatility based on access frequency and recency
    access_count = len(self.access_patterns[key])
    time_since_access = current_time - entry.last_accessed

    #                 # Higher volatility for frequently accessed but recently stale entries
    #                 if access_count 0 and time_since_access > 0):
    recency_factor = math.divide(1.0, ()
    #                         1.0 + time_since_access / 3600.0
    #                     )  # Normalize by hour
    frequency_factor = min(
    #                         1.0, access_count / 10.0
    #                     )  # Normalize by 10 accesses
    self.volatility_scores[key] = recency_factor * frequency_factor
    #                 else:
    self.volatility_scores[key] = 0.0

    #     def _apply_adaptive_invalidation(self):
    #         """Apply adaptive invalidation based on volatility scores."""
    #         if not self.config.enable_adaptive:
    #             return

    current_time = time.time()
    keys_to_invalidate = []

    #         with self.cache._cache_lock:
    #             # Find entries with high volatility
    #             for key, entry in self.cache._cache.items():
    volatility = self.volatility_scores.get(key, 0.0)
    #                 if volatility self.config.volatility_threshold):
                        keys_to_invalidate.append(key)

    #             # Invalidate high volatility entries
    #             for key in keys_to_invalidate:
    #                 if key in self.cache._cache:
    #                     del self.cache._cache[key]
                        self.logger.debug(
                            f"Adaptive invalidation: {key} (volatility: {self.volatility_scores[key]:.2f})"
    #                     )

    #     def invalidate(self, key: str, reason: str = "") -bool):
    #         """Invalidate a specific cache entry adaptively."""
    #         if not self.config.enable_adaptive:
    #             return False

    #         with self.cache._cache_lock:
    #             if key in self.cache._cache:
    volatility = self.volatility_scores.get(key, 0.0)
    #                 if volatility self.config.volatility_threshold):
    #                     del self.cache._cache[key]
                        self.logger.info(
                            f"Adaptive invalidation: {key} (volatility: {volatility:.2f}) - {reason}"
    #                     )
    #                     return True
    #         return False

    #     def invalidate_all(self, pattern: str = "", reason: str = "") -int):
    #         """Invalidate multiple cache entries adaptively."""
    #         if not self.config.enable_adaptive:
    #             return 0

    invalidated_count = 0

    #         with self.cache._cache_lock:
    keys_to_remove = []

    #             for key, entry in self.cache._cache.items():
    #                 if pattern and not re.search(pattern, key):
    #                     continue

    volatility = self.volatility_scores.get(key, 0.0)
    #                 if volatility self.config.volatility_threshold):
                        keys_to_remove.append(key)

    #             for key in keys_to_remove:
    #                 del self.cache._cache[key]
    invalidated_count + = 1

    #             if invalidated_count 0):
                    self.logger.info(
    #                     f"Adaptive batch invalidation: {invalidated_count} entries - {reason}"
    #                 )

    #         return invalidated_count

    #     def stop_background_tasks(self):
    #         """Stop background tasks."""
            super().stop_background_tasks()
            self.access_patterns.clear()
            self.volatility_scores.clear()


class ProbabilisticInvalidation(CacheInvalidationStrategy)
    #     """Probabilistic invalidation for stale data detection."""

    #     def __init__(self, cache: Any, config: CacheInvalidationConfig):""Initialize probabilistic invalidation."""
            super().__init__(cache, config)
            self._start_probabilistic_checker()

    #     def _start_probabilistic_checker(self):
    #         """Start background thread for probabilistic checking."""

    #         def probabilistic_worker():
    #             while not self._stop_event.wait(60.0):  # Check every minute
    #                 try:
                        self._check_stale_entries()
    #                 except Exception as e:
                        self.logger.error(f"Error in probabilistic checker: {e}")

    self._strategy_thread = threading.Thread(
    target = probabilistic_worker, daemon=True
    #         )
            self._strategy_thread.start()

    #     def _check_stale_entries(self):
    #         """Check entries for staleness probabilistically."""
    #         if not self.config.enable_probabilistic:
    #             return

    current_time = time.time()
    keys_to_invalidate = []

    #         with self.cache._cache_lock:
    #             for key, entry in self.cache._cache.items():
    #                 # Calculate probability of staleness
    age = current_time - entry.last_accessed
    #                 base_probability = min(1.0, age / 3600.0)  # Increase with age

    #                 # Apply volatility factor
    volatility_factor = 1.0 + (
    #                     entry.volatile * self.config.volatility_factor
    #                 )
    stale_probability = (
    #                     base_probability * volatility_factor * self.config.stale_probability
    #                 )

    #                 # Probabilistic decision
    #                 if random.random() < stale_probability:  # Note: need to import random
                        keys_to_invalidate.append(key)

    #             # Invalidate stale entries
    #             for key in keys_to_invalidate:
    #                 if key in self.cache._cache:
    #                     del self.cache._cache[key]
                        self.logger.debug(f"Probabilistic invalidation: {key}")

    #     def invalidate(self, key: str, reason: str = "") -bool):
    #         """Invalidate a specific cache entry probabilistically."""
    #         if not self.config.enable_probabilistic:
    #             return False

    #         with self.cache._cache_lock:
    #             if key in self.cache._cache:
    entry = self.cache._cache[key]

    #                 # Calculate probability of staleness
    current_time = time.time()
    age = current_time - entry.last_accessed
    base_probability = math.divide(min(1.0, age, 3600.0))
    volatility_factor = 1.0 + (
    #                     entry.volatile * self.config.volatility_factor
    #                 )
    stale_probability = (
    #                     base_probability * volatility_factor * self.config.stale_probability
    #                 )

    #                 # Probabilistic decision
    #                 if random.random() < stale_probability:
    #                     del self.cache._cache[key]
                        self.logger.info(f"Probabilistic invalidation: {key} - {reason}")
    #                     return True
    #         return False

    #     def invalidate_all(self, pattern: str = "", reason: str = "") -int):
    #         """Invalidate multiple cache entries probabilistically."""
    #         if not self.config.enable_probabilistic:
    #             return 0

    invalidated_count = 0

    #         with self.cache._cache_lock:
    keys_to_remove = []

    #             for key, entry in self.cache._cache.items():
    #                 if pattern and not re.search(pattern, key):
    #                     continue

    #                 # Calculate probability of staleness
    current_time = time.time()
    age = current_time - entry.last_accessed
    base_probability = math.divide(min(1.0, age, 3600.0))
    volatility_factor = 1.0 + (
    #                     entry.volatile * self.config.volatility_factor
    #                 )
    stale_probability = (
    #                     base_probability * volatility_factor * self.config.stale_probability
    #                 )

    #                 # Probabilistic decision
    #                 if random.random() < stale_probability:
                        keys_to_remove.append(key)

    #             for key in keys_to_remove:
    #                 del self.cache._cache[key]
    invalidated_count + = 1

    #             if invalidated_count 0):
                    self.logger.info(
    #                     f"Probabilistic batch invalidation: {invalidated_count} entries - {reason}"
    #                 )

    #         return invalidated_count

    #     def stop_background_tasks(self):
    #         """Stop background tasks."""
            super().stop_background_tasks()


class VersionBasedInvalidation(CacheInvalidationStrategy)
    #     """Version-based invalidation for schema and data versioning."""

    #     def __init__(self, cache: Any, config: CacheInvalidationConfig):""Initialize version-based invalidation."""
            super().__init__(cache, config)
    self.version_history: Dict[str, List[str]] = defaultdict(list)
    self.current_versions: Dict[str, str] = {}
            self._start_version_checker()

    #     def _start_version_checker(self):
    #         """Start background thread for version checking."""

    #         def version_worker():
    #             while not self._stop_event.wait(self.config.version_check_interval):
    #                 try:
                        self._check_versions()
    #                 except Exception as e:
                        self.logger.error(f"Error in version checker: {e}")

    self._strategy_thread = threading.Thread(target=version_worker, daemon=True)
            self._strategy_thread.start()

    #     def _check_versions(self):
    #         """Check for version mismatches and invalidate outdated entries."""
    #         if not self.config.enable_version_based:
    #             return

    current_time = time.time()
    keys_to_invalidate = []

    #         with self.cache._cache_lock:
    #             for key, entry in self.cache._cache.items():
    #                 # Check if entry version matches current version
    #                 if key in self.current_versions:
    current_version = self.current_versions[key]
    #                     if entry.version != current_version:
                            keys_to_invalidate.append(key)

    #             # Invalidate outdated entries
    #             for key in keys_to_invalidate:
    #                 if key in self.cache._cache:
    #                     del self.cache._cache[key]
                        self.logger.debug(f"Version-based invalidation: {key}")

    #     def update_version(self, key: str, version: str):
    #         """Update the version for a cache entry."""
    self.current_versions[key] = version
            self.version_history[key].append(version)

    #         # Keep only recent versions
    #         if len(self.version_history[key]) self.config.version_history_size):
    self.version_history[key] = self.version_history[key][
    #                 -self.config.version_history_size :
    #             ]

    #     def invalidate(self, key: str, reason: str = "") -bool):
    #         """Invalidate a specific cache entry based on version."""
    #         if not self.config.enable_version_based:
    #             return False

    #         with self.cache._cache_lock:
    #             if key in self.cache._cache:
    entry = self.cache._cache[key]

    #                 # Check version mismatch
    #                 if (
    #                     key in self.current_versions
    and entry.version != self.current_versions[key]
    #                 ):
    #                     del self.cache._cache[key]
                        self.logger.info(f"Version-based invalidation: {key} - {reason}")
    #                     return True
    #         return False

    #     def invalidate_all(self, pattern: str = "", reason: str = "") -int):
    #         """Invalidate multiple cache entries based on version."""
    #         if not self.config.enable_version_based:
    #             return 0

    invalidated_count = 0

    #         with self.cache._cache_lock:
    keys_to_remove = []

    #             for key, entry in self.cache._cache.items():
    #                 if pattern and not re.search(pattern, key):
    #                     continue

    #                 # Check version mismatch
    #                 if (
    #                     key in self.current_versions
    and entry.version != self.current_versions[key]
    #                 ):
                        keys_to_remove.append(key)

    #             for key in keys_to_remove:
    #                 del self.cache._cache[key]
    invalidated_count + = 1

    #             if invalidated_count 0):
                    self.logger.info(
    #                     f"Version-based batch invalidation: {invalidated_count} entries - {reason}"
    #                 )

    #         return invalidated_count

    #     def stop_background_tasks(self):
    #         """Stop background tasks."""
            super().stop_background_tasks()
            self.version_history.clear()
            self.current_versions.clear()


class HierarchicalInvalidation(CacheInvalidationStrategy)
    #     """Hierarchical invalidation for nested and related data structures."""

    #     def __init__(self, cache: Any, config: CacheInvalidationConfig):""Initialize hierarchical invalidation."""
            super().__init__(cache, config)
    self.hierarchy: Dict[int, Set[str]] = defaultdict(set)
    self.parent_map: Dict[str, str] = {}
    self.child_map: Dict[str, Set[str]] = defaultdict(set)
            self._build_hierarchy()

    #     def _build_hierarchy(self):
    #         """Build the hierarchical structure of cache entries."""
    #         if not self.config.enable_hierarchical:
    #             return

    #         with self.cache._cache_lock:
    #             for key, entry in self.cache._cache.items():
    #                 # Determine hierarchy level based on key patterns or entry properties
    level = self._determine_hierarchy_level(key, entry)
                    self.hierarchy[level].add(key)

    #                 # Set parent-child relationships
    parent_key = self._find_parent_key(key, entry)
    #                 if parent_key:
    self.parent_map[key] = parent_key
                        self.child_map[parent_key].add(key)

    #     def _determine_hierarchy_level(self, key: str, entry: CacheEntry) -int):
    #         """Determine the hierarchy level of a cache entry."""
    #         # Simple implementation based on key depth
    parts = key.split(".")
            return min(len(parts) - 1, self.config.hierarchy_levels - 1)

    #     def _find_parent_key(self, key: str, entry: CacheEntry) -Optional[str]):
    #         """Find the parent key for a cache entry."""
    #         # Simple implementation based on key structure
    parts = key.split(".")
    #         if len(parts) 1):
                return ".".join(parts[:-1])
    #         return None

    #     def invalidate(self, key: str, reason: str = "") -bool):
    #         """Invalidate a specific cache entry and its hierarchical children."""
    #         if not self.config.enable_hierarchical:
    #             return False

    invalidated_count = 0

    #         with self.cache._cache_lock:
    #             # Invalidate the specified key
    #             if key in self.cache._cache:
    #                 del self.cache._cache[key]
    invalidated_count + = 1

    #                 # Invalidate all children
                    self._invalidate_children(key)

                    self.logger.info(f"Hierarchical invalidation: {key} - {reason}")

    #         return invalidated_count 0

    #     def _invalidate_children(self, key): str):
    #         """Recursively invalidate all children of a key."""
    #         for child_key in self.child_map[key]:
    #             if child_key in self.cache._cache:
    #                 del self.cache._cache[child_key]
                    self.logger.debug(f"Invalidating child: {child_key}")

    #                 # Recursively invalidate children of children
                    self._invalidate_children(child_key)

    #     def invalidate_all(self, pattern: str = "", reason: str = "") -int):
    #         """Invalidate multiple cache entries hierarchically."""
    #         if not self.config.enable_hierarchical:
    #             return 0

    invalidated_count = 0

    #         with self.cache._cache_lock:
    keys_to_invalidate = []

    #             # Find keys matching the pattern
    #             for key in self.cache._cache.keys():
    #                 if pattern and not re.search(pattern, key):
    #                     continue
                    keys_to_invalidate.append(key)

    #             # Invalidate each key and its children
    #             for key in keys_to_invalidate:
    #                 if key in self.cache._cache:
    #                     del self.cache._cache[key]
    invalidated_count + = 1

    #                     # Invalidate all children
                        self._invalidate_children(key)

    #             if invalidated_count 0):
                    self.logger.info(
    #                     f"Hierarchical batch invalidation: {invalidated_count} entries - {reason}"
    #                 )

    #         return invalidated_count

    #     def stop_background_tasks(self):
    #         """Stop background tasks."""
            super().stop_background_tasks()
            self.hierarchy.clear()
            self.parent_map.clear()
            self.child_map.clear()


class ManualInvalidation(CacheInvalidationStrategy)
    #     """Manual invalidation with selective and bulk operations."""

    #     def __init__(self, cache: Any, config: CacheInvalidationConfig):""Initialize manual invalidation."""
            super().__init__(cache, config)
    self.invalidation_log: List[Tuple[str, str, str]] = (
    #             []
            )  # (key, reason, timestamp)

    #     def invalidate(self, key: str, reason: str = "") -bool):
    #         """Invalidate a specific cache entry manually."""
    #         if not self.config.enable_manual:
    #             return False

    #         with self.cache._cache_lock:
    #             if key in self.cache._cache:
    #                 del self.cache._cache[key]
    timestamp = datetime.now().isoformat()
                    self.invalidation_log.append(
                        (key, reason or "Manual invalidation", timestamp)
    #                 )

    #                 # Keep only recent log entries
    #                 if len(self.invalidation_log) 1000):
    self.invalidation_log = self.invalidation_log[ - 1000:]

                    self.logger.info(f"Manual invalidation: {key} - {reason}")
    #                 return True
    #         return False

    #     def invalidate_all(self, pattern: str = "", reason: str = "") -int):
    #         """Invalidate multiple cache entries manually."""
    #         if not self.config.enable_manual:
    #             return 0

    invalidated_count = 0

    #         with self.cache._cache_lock:
    keys_to_remove = []

    #             # Find keys matching the pattern
    #             for key in self.cache._cache.keys():
    #                 if pattern and not re.search(pattern, key):
    #                     continue
                    keys_to_remove.append(key)

    #             # Limit bulk operations
    #             if len(keys_to_remove) self.config.bulk_operation_limit):
                    self.logger.warning(
                        f"Bulk operation limit exceeded: {len(keys_to_remove)} {self.config.bulk_operation_limit}"
    #                 )
    keys_to_remove = keys_to_remove[): self.config.bulk_operation_limit]

    #             # Remove keys
    #             for key in keys_to_remove:
    #                 del self.cache._cache[key]
    timestamp = datetime.now().isoformat()
                    self.invalidation_log.append(
                        (key, reason or "Manual batch invalidation", timestamp)
    #                 )
    invalidated_count + = 1

    #             if invalidated_count 0):
                    self.logger.info(
    #                     f"Manual batch invalidation: {invalidated_count} entries - {reason}"
    #                 )

    #         return invalidated_count

    #     def get_invalidation_log(self, limit: int = 100) -List[Tuple[str, str, str]]):
    #         """Get the invalidation log."""
    #         return self.invalidation_log[-limit:]

    #     def clear_invalidation_log(self):
    #         """Clear the invalidation log."""
            self.invalidation_log.clear()

    #     def stop_background_tasks(self):
    #         """Stop background tasks."""
            super().stop_background_tasks()


class CacheInvalidationAnalytics
    #     """Analytics and logging for cache invalidation performance."""

    #     def __init__(self, config: CacheInvalidationConfig):""Initialize cache invalidation analytics."""
    self.config = config
    self.logger = logging.getLogger(__name__)
    self.metrics_history: List[Dict[str, Any]] = []
    self.invalidation_stats: Dict[str, int] = defaultdict(int)
    self.performance_metrics: Dict[str, List[float]] = defaultdict(list)
    self._stop_event = threading.Event()
    self._strategy_thread = None
            self._start_metrics_collection()

    #     def _start_metrics_collection(self):
    #         """Start background thread for metrics collection."""

    #         def metrics_worker():
    #             while not self._stop_event.wait(self.config.performance_metrics_interval):
    #                 try:
                        self._collect_metrics()
    #                 except Exception as e:
                        self.logger.error(f"Error in metrics collection: {e}")

    self._strategy_thread = threading.Thread(target=metrics_worker, daemon=True)
            self._strategy_thread.start()

    #     def _collect_metrics(self):
    #         """Collect performance metrics."""
    metrics = {
                "timestamp": time.time(),
                "invalidation_counts": self.invalidation_stats.copy(),
    #             "performance_metrics": {
    #                 metric: values[-10:] if len(values) 10 else values
    #                 for metric, values in self.performance_metrics.items()
    #             },
    #         }

            self.metrics_history.append(metrics)

    #         # Keep only recent metrics
    #         if len(self.metrics_history) > self.config.analytics_history_size):
    self.metrics_history = self.metrics_history[
    #                 -self.config.analytics_history_size :
    #             ]

    #     def log_invalidation(self, strategy: str, count: int, duration: float):
    #         """Log invalidation statistics."""
    self.invalidation_stats[strategy] + = count
            self.performance_metrics[f"{strategy}_duration"].append(duration)
            self.performance_metrics[f"{strategy}_count"].append(count)

    #     def get_metrics(self) -Dict[str, Any]):
    #         """Get current metrics."""
    #         return {
                "metrics_history": (
    #                 self.metrics_history[-10:] if self.metrics_history else []
    #             ),
                "invalidation_stats": dict(self.invalidation_stats),
    #             "performance_metrics": {
    #                 metric: statistics.mean(values) if values else 0.0
    #                 for metric, values in self.performance_metrics.items()
    #             },
    #         }

    #     def generate_report(self) -str):
    #         """Generate a performance report."""
    #         if not self.metrics_history:
    #             return "No metrics available"

    total_invalidations = sum(self.invalidation_stats.values())
    avg_duration = (
                statistics.mean(self.performance_metrics.get("total_duration", [0.0]))
    #             if self.performance_metrics.get("total_duration")
    #             else 0.0
    #         )

    report = f"""
# Cache Invalidation Performance Report
 = ===================================
# Total Invalidations: {total_invalidations}
# Average Duration: {avg_duration:.4f}s

# Strategy Breakdown:
# """

#         for strategy, count in self.invalidation_stats.items():
percentage = (
#                 (count / total_invalidations * 100) if total_invalidations 0 else 0
#             )
report + = f"- {strategy}): {count} ({percentage:.1f}%)\n"

#         return report

#     def stop_background_tasks(self):
#         """Stop background tasks."""
#         if self._strategy_thread is not None:
            self._stop_event.set()
            self._strategy_thread.join()
self._strategy_thread = None


class CacheInvalidationManager
    #     """Manager for coordinating cache invalidation strategies."""

    #     def __init__(self, cache: Any, config: Optional[CacheInvalidationConfig] = None):""Initialize the cache invalidation manager.

    #         Args:
    #             cache: Cache instance to manage invalidation for
    #             config: Invalidation configuration (uses defaults if None)
    #         """
    self.cache = cache
    self.config = config or CacheInvalidationConfig()
    self.logger = logging.getLogger(__name__)

    #         # Initialize strategies
    self.strategies: Dict[InvalidationStrategy, CacheInvalidationStrategy] = {}
            self._initialize_strategies()

    #         # Initialize analytics
    self.analytics = CacheInvalidationAnalytics(self.config)

    #         # Thread pool for concurrent invalidation
    self.executor = ThreadPoolExecutor(max_workers=self.config.bulk_operation_limit)

    #     def _initialize_strategies(self):
    #         """Initialize all enabled invalidation strategies."""
    #         if self.config.enable_time_based:
    self.strategies[InvalidationStrategy.TIME_BASED] = TimeBasedInvalidation(
    #                 self.cache, self.config
    #             )

    #         if self.config.enable_dependency_tracking:
    self.strategies[InvalidationStrategy.DEPENDENCY_BASED] = (
                    DependencyBasedInvalidation(self.cache, self.config)
    #             )

    #         if self.config.enable_event_driven:
    self.strategies[InvalidationStrategy.EVENT_DRIVEN] = (
                    EventDrivenInvalidation(self.cache, self.config)
    #             )

    #         if self.config.enable_write_through:
    self.strategies[InvalidationStrategy.WRITE_THROUGH] = (
                    WriteThroughInvalidation(self.cache, self.config)
    #             )

    #         if self.config.enable_write_around:
    self.strategies[InvalidationStrategy.WRITE_AROUND] = (
                    WriteAroundInvalidation(self.cache, self.config)
    #             )

    #         if self.config.enable_adaptive:
    self.strategies[InvalidationStrategy.ADAPTIVE] = AdaptiveInvalidation(
    #                 self.cache, self.config
    #             )

    #         if self.config.enable_probabilistic:
    self.strategies[InvalidationStrategy.PROBABILISTIC] = (
                    ProbabilisticInvalidation(self.cache, self.config)
    #             )

    #         if self.config.enable_version_based:
    self.strategies[InvalidationStrategy.VERSION_BASED] = (
                    VersionBasedInvalidation(self.cache, self.config)
    #             )

    #         if self.config.enable_hierarchical:
    self.strategies[InvalidationStrategy.HIERARCHICAL] = (
                    HierarchicalInvalidation(self.cache, self.config)
    #             )

    #         if self.config.enable_manual:
    self.strategies[InvalidationStrategy.MANUAL] = ManualInvalidation(
    #                 self.cache, self.config
    #             )

    #     def invalidate(
    self, key: str, reason: str = "", strategies: List[InvalidationStrategy] = None
    #     ) -Dict[str, bool]):
    #         """Invalidate a specific cache entry using specified strategies.

    #         Args:
    #             key: Cache key to invalidate
    #             reason: Reason for invalidation
    #             strategies: List of strategies to use (all if None)

    #         Returns:
    #             Dictionary mapping strategy names to success status
    #         """
    #         if strategies is None:
    strategies = list(self.strategies.keys())

    results = {}
    start_time = time.time()

    #         for strategy in strategies:
    #             if strategy in self.strategies:
    #                 try:
    success = self.strategies[strategy].invalidate(key, reason)
    results[strategy.value] = success
    #                 except Exception as e:
                        self.logger.error(f"Error in {strategy.value} invalidation: {e}")
    results[strategy.value] = False

    duration = time.time() - start_time
            self.analytics.log_invalidation("total", 1, duration)

    #         return results

    #     def invalidate_all(
    #         self,
    pattern: str = "",
    reason: str = "",
    strategies: List[InvalidationStrategy] = None,
    #     ) -Dict[str, int]):
    #         """Invalidate multiple cache entries using specified strategies.

    #         Args:
                pattern: Pattern to match keys (optional)
    #             reason: Reason for invalidation
    #             strategies: List of strategies to use (all if None)

    #         Returns:
    #             Dictionary mapping strategy names to number of invalidations
    #         """
    #         if strategies is None:
    strategies = list(self.strategies.keys())

    results = {}
    start_time = time.time()

    #         for strategy in strategies:
    #             if strategy in self.strategies:
    #                 try:
    count = self.strategies[strategy].invalidate_all(pattern, reason)
    results[strategy.value] = count
    #                 except Exception as e:
                        self.logger.error(
    #                         f"Error in {strategy.value} batch invalidation: {e}"
    #                     )
    results[strategy.value] = 0

    duration = time.time() - start_time
    total_invalidated = sum(results.values())
            self.analytics.log_invalidation("total", total_invalidated, duration)

    #         return results

    #     def get_metrics(self) -Dict[str, Any]):
    #         """Get performance metrics from all strategies."""
            return self.analytics.get_metrics()

    #     def generate_report(self) -str):
    #         """Generate a comprehensive performance report."""
            return self.analytics.generate_report()

    #     def start_background_tasks(self):
    #         """Start all background tasks."""
    #         for strategy in self.strategies.values():
                strategy.start_background_tasks()
    #         # The analytics collection is already started in the constructor

    #     def stop_background_tasks(self):
    #         """Stop all background tasks."""
    #         for strategy in self.strategies.values():
                strategy.stop_background_tasks()
            self.analytics.stop_background_tasks()
    self.executor.shutdown(wait = True)

    #     def __del__(self):
    #         """Cleanup when object is destroyed."""
            self.stop_background_tasks()


def create_cache_invalidation_manager(
cache: Any, config: Optional[CacheInvalidationConfig] = None
# ) -CacheInvalidationManager):
#     """Create a cache invalidation manager.

#     Args:
#         cache: Cache instance to manage invalidation for
#         config: Invalidation configuration (uses defaults if None)

#     Returns:
#         CacheInvalidationManager instance
#     """
    return CacheInvalidationManager(cache, config)
