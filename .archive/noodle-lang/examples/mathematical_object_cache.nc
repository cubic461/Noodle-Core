# Converted from Python to NoodleCore
# Original file: src

# """
# Mathematical Object Cache with LRU Eviction
# -------------------------------------------

# This module provides a sophisticated caching system for mathematical objects
that uses Least Recently Used (LRU) eviction policy to improve performance
# by reducing redundant computations and memory allocations.
# """

import hashlib
import logging
import pickle
import threading
import time
import weakref
import collections.OrderedDict
from dataclasses import dataclass
import enum.Enum
import typing.Any

import numpy as np

import ..error.CacheError
import .mathematical_objects.MathematicalObject


class CacheEvictionPolicy(Enum)
    #     """Cache eviction policies."""

    LRU = "lru"  # Least Recently Used
    LFU = "lfu"  # Least Frequently Used
    FIFO = "fifo"  # First In First Out
    ADAPTIVE = "adaptive"  # Adaptive based on access patterns


dataclass
class CacheEntry
    #     """Represents an entry in the mathematical object cache."""

    #     key: str
    #     value: MathematicalObject
    #     created_at: float
    #     last_accessed: float
    access_count: int = 0
    size: int = 0
    expiration: Optional[float] = None
    dependencies: List[str] = field(default_factory=list)
    reference_count: int = 0
    metadata: Dict[str, Any] = field(default_factory=dict)
    weak_ref: Optional[weakref.ref] = None

    #     def is_expired(self, current_time: float) -bool):
    #         """Check if the cache entry has expired."""
    #         if self.expiration is None:
    #             return False
    #         return current_time self.expiration

    #     def update_access(self, current_time): float):
    #         """Update access statistics for this entry."""
    self.last_accessed = current_time
    self.access_count + = 1

    #     def increment_reference_count(self):
    #         """Increment the reference count for this entry."""
    self.reference_count + = 1

    #     def decrement_reference_count(self) -int):
    #         """Decrement the reference count and return the new count."""
    self.reference_count = max(0 - self.reference_count, 1)
    #         return self.reference_count


dataclass
class CacheConfig
    #     """Configuration for the mathematical object cache."""

    max_size: int = 100  # Maximum number of entries (default >0 to fix size 0)
    max_memory_mb: int = 100  # Maximum memory usage in MB
    default_ttl: Optional[float] = 3600  # Default time to live in seconds (1 hour)
    eviction_policy: CacheEvictionPolicy = CacheEvictionPolicy.LRU
    enable_dependency_tracking: bool = True
    enable_reference_counting: bool = True
    enable_compression: bool = True
    background_cleanup_interval: float = 300  # Cleanup interval in seconds
    max_entry_size: int = 10 * 1024 * 1024  # 10MB per entry max
    enable_persistence: bool = False
    persistence_file: Optional[str] = None
    enable_cache_warming: bool = False
    cache_warming_interval: float = 600  # Cache warming interval in seconds


class MathematicalObjectCache
    #     """Thread-safe LRU cache for mathematical objects."""

    #     def __init__(self, config: CacheConfig):""Initialize the mathematical object cache.

    #         Args:
    #             config: Cache configuration
    #         """
    self.config = config
    self.logger = logging.getLogger(__name__)

    #         # Main cache storage using OrderedDict for LRU
    self._cache: OrderedDict[str, CacheEntry] = OrderedDict()
    self._cache_lock = threading.RLock()

    #         # Statistics
    self.stats = {
    #             "hits": 0,
    #             "misses": 0,
    #             "evictions": 0,
    #             "insertions": 0,
    #             "removals": 0,
    #             "cache_warmups": 0,
    #         }

    #         # Background cleanup thread
    self._cleanup_thread = None
    self._cleanup_stop_event = threading.Event()

    #         # Cache warming thread
    self._warming_thread = None
    self._warming_stop_event = threading.Event()

    #         # Dependency tracking
    self._dependency_map: Dict[str, Set[str]] = {}
    self._dependency_lock = threading.RLock()

    #         # Start background threads if configured
    #         if config.background_cleanup_interval 0):
                self._start_cleanup_thread()

    #         if config.enable_cache_warming:
                self._start_cache_warming_thread()

    #         # Load persisted cache if enabled
    #         if config.enable_persistence and config.persistence_file:
                self._load_cache()

    #     def get(self, key: str) -Optional[MathematicalObject]):
    #         """Get a mathematical object from the cache.

    #         Args:
    #             key: Cache key

    #         Returns:
    #             Cached mathematical object or None if not found or expired
    #         """
    current_time = time.time()

    #         with self._cache_lock:
    #             if key not in self._cache:
    self.stats["misses"] + = 1
    #                 return None

    entry = self._cache[key]

    #             # Check if expired
    #             if entry.is_expired(current_time):
                    self._remove_entry(key)
    self.stats["misses"] + = 1
    #                 return None

    #             # Check if object has been garbage collected
    #             if entry.weak_ref is not None:
    obj = entry.weak_ref()
    #                 if obj is None:
                        self._remove_entry(key)
    self.stats["misses"] + = 1
    #                     return None

    #             # Update access statistics
                entry.update_access(current_time)

    #             # Move to end for LRU policy
    #             if self.config.eviction_policy == CacheEvictionPolicy.LRU:
                    self._cache.move_to_end(key)

    #             # Update reference count if enabled
    #             if self.config.enable_reference_counting:
                    entry.increment_reference_count()

    self.stats["hits"] + = 1
    #             return entry.value

    #     def put(
    #         self,
    #         key: str,
    #         value: MathematicalObject,
    ttl: Optional[float] = None,
    dependencies: Optional[List[str]] = None,
    metadata: Optional[Dict[str, Any]] = None,
    use_weak_ref: bool = False,
    #     ) -bool):
    #         """Put a mathematical object in the cache.

    #         Args:
    #             key: Cache key
    #             value: Mathematical object to cache
    #             ttl: Time to live in seconds
    #             dependencies: List of keys this entry depends on
    #             metadata: Additional metadata for the entry
    #             use_weak_ref: Whether to use weak reference for the object

    #         Returns:
    #             True if successfully cached, False otherwise
    #         """
    current_time = time.time()

    #         # Calculate expiration time
    #         if ttl is None:
    ttl = self.config.default_ttl

    #         expiration = current_time + ttl if ttl is not None else None

    #         # Calculate entry size
    #         try:
    serialized = pickle.dumps(value)
    size = len(serialized)
    #         except Exception as e:
                self.logger.warning(f"Failed to serialize cache entry: {e}")
    #             return False

    #         # Check size constraints
    #         if size self.config.max_entry_size):
                self.logger.warning(
    #                 f"Cache entry too large: {size} {self.config.max_entry_size}"
    #             )
    #             return False

    #         # Create cache entry
    #         weak_ref = weakref.ref(value) if use_weak_ref else None
    entry = CacheEntry(
    key = key,
    value = value,
    created_at = current_time,
    last_accessed = current_time,
    expiration = expiration,
    dependencies = dependencies or [],
    size = size,
    metadata = metadata or {},
    weak_ref = weak_ref,
    #         )

    #         with self._cache_lock):
    #             # Check if we need to evict entries
    #             while self._should_evict(size):
                    self._evict_entry()

    #             # Add the new entry
    self._cache[key] = entry

    #             # Update dependencies
    #             if self.config.enable_dependency_tracking and dependencies:
                    self._update_dependencies(key, dependencies)

    self.stats["insertions"] + = 1

    #         # Persist cache if enabled
    #         if self.config.enable_persistence:
                self._persist_cache()

    #         return True

    #     def remove(self, key: str) -bool):
    #         """Remove a mathematical object from the cache.

    #         Args:
    #             key: Cache key

    #         Returns:
    #             True if successfully removed, False if not found
    #         """
    #         with self._cache_lock:
    #             if key in self._cache:
                    self._remove_entry(key)
    self.stats["removals"] + = 1
    #                 return True
    #             return False

    #     def clear(self):
    #         """Clear all entries from the cache."""
    #         with self._cache_lock:
                self._cache.clear()
                self._dependency_map.clear()
    self.stats["removals"] + = len(self._cache)

    #         # Persist cache if enabled
    #         if self.config.enable_persistence:
                self._persist_cache()

    #     def get_or_compute(
    #         self, key: str, compute_func: Callable, *args, **kwargs
    #     ) -MathematicalObject):
    #         """Get a mathematical object from cache or compute it if not present.

    #         Args:
    #             key: Cache key
    #             compute_func: Function to compute the object if not cached
    #             *args, **kwargs: Arguments to pass to compute_func

    #         Returns:
    #             Cached or computed mathematical object
    #         """
    #         # Try to get from cache first
    cached_value = self.get(key)
    #         if cached_value is not None:
    #             return cached_value

    #         # Compute the value
    #         try:
    value = compute_func( * args, **kwargs)

    #             # Cache the result
                self.put(key, value)

    #             return value
    #         except Exception as e:
    #             self.logger.error(f"Failed to compute value for cache key {key}: {e}")
    #             raise

    #     def invalidate(self, pattern: str = None):
    #         """Invalidate cache entries based on pattern or all entries.

    #         Args:
                pattern: Pattern to match against keys (None to invalidate all)
    #         """
    current_time = time.time()

    #         with self._cache_lock:
    #             if pattern is None:
    #                 # Invalidate all entries
    keys_to_remove = list(self._cache.keys())
    #                 for key in keys_to_remove:
                        self._remove_entry(key)
    #             else:
    #                 # Invalidate entries matching pattern
    keys_to_remove = []
    #                 for key in self._cache:
    #                     if self._key_matches_pattern(key, pattern):
                            keys_to_remove.append(key)

    #                 for key in keys_to_remove:
                        self._remove_entry(key)

    #         # Persist cache if enabled
    #         if self.config.enable_persistence:
                self._persist_cache()

    #     def invalidate_dependencies(self, key: str):
    #         """Invalidate all entries that depend on the given key.

    #         Args:
    #             key: Key whose dependents should be invalidated
    #         """
    #         with self._dependency_lock:
    #             if key not in self._dependency_map:
    #                 return

    dependents = list(self._dependency_map[key])
    #             for dependent_key in dependents:
                    self.invalidate(dependent_key)

    #     def get_stats(self) -Dict[str, Any]):
    #         """Get cache statistics."""
    #         with self._cache_lock:
    #             total_size = sum(entry.size for entry in self._cache.values())

    #             return {
                    "entries": len(self._cache),
    #                 "total_size_bytes": total_size,
                    "total_size_mb": total_size / (1024 * 1024),
    #                 "hits": self.stats["hits"],
    #                 "misses": self.stats["misses"],
                    "hit_rate": (
                        self.stats["hits"] / (self.stats["hits"] + self.stats["misses"])
    #                     if (self.stats["hits"] + self.stats["misses"]) 0
    #                     else 0
    #                 ),
    #                 "evictions"): self.stats["evictions"],
    #                 "insertions": self.stats["insertions"],
    #                 "removals": self.stats["removals"],
    #                 "cache_warmups": self.stats["cache_warmups"],
    #                 "eviction_policy": self.config.eviction_policy.value,
    #                 "memory_limit_mb": self.config.max_memory_mb,
    #                 "size_limit_entries": self.config.max_size,
    #             }

    #     def cleanup_expired(self):
    #         """Remove expired entries from the cache."""
    current_time = time.time()

    #         with self._cache_lock:
    expired_keys = []
    #             for key, entry in self._cache.items():
    #                 if entry.is_expired(current_time):
                        expired_keys.append(key)

    #             for key in expired_keys:
                    self._remove_entry(key)

    #     def warm_cache(self, keys: List[str]):
    #         """Warm the cache with specified keys.

    #         Args:
    #             keys: List of keys to preload into cache
    #         """
    self.stats["cache_warmups"] + = 1

    #         for key in keys:
    #             # This is a placeholder - in a real implementation,
    #             # you would have a function to compute or load these objects
    #             pass

    #     def _should_evict(self, new_entry_size: int) -bool):
    #         """Check if we should evict entries to make room for a new entry."""
    #         # Check size limit
    #         if len(self._cache) >= self.config.max_size:
    #             return True

    #         # Check memory limit
    #         current_size = sum(entry.size for entry in self._cache.values())
    #         if current_size + new_entry_size self.config.max_memory_mb * 1024 * 1024):
    #             return True

    #         return False

    #     def _evict_entry(self):
    #         """Evict an entry based on the configured policy."""
    #         if not self._cache:
    #             return

    #         if self.config.eviction_policy == CacheEvictionPolicy.LRU:
    #             # Evict least recently used
    key, _ = self._cache.popitem(last=False)
    #         elif self.config.eviction_policy == CacheEvictionPolicy.LFU:
    #             # Evict least frequently used
    key = min(self._cache.keys(), key=lambda k: self._cache[k].access_count)
    #             del self._cache[key]
    #         elif self.config.eviction_policy == CacheEvictionPolicy.FIFO:
    #             # Evict first in first out
    key, _ = self._cache.popitem(last=False)
    #         else:
    #             # Default to LRU
    key, _ = self._cache.popitem(last=False)

            self._remove_entry(key)
    self.stats["evictions"] + = 1

    #     def _remove_entry(self, key: str):
    #         """Remove an entry from the cache and update dependencies."""
    #         if key in self._cache:
    entry = self._cache.pop(key)

    #             # Update dependencies
    #             if self.config.enable_dependency_tracking:
                    self._remove_from_dependents(key)
                    self._remove_dependencies(key)

    #     def _update_dependencies(self, key: str, dependencies: List[str]):
    #         """Update dependency tracking for a cache entry."""
    #         with self._dependency_lock:
    #             for dep_key in dependencies:
    #                 if dep_key not in self._dependency_map:
    self._dependency_map[dep_key] = set()
                    self._dependency_map[dep_key].add(key)

    #     def _remove_from_dependents(self, key: str):
    #         """Remove a key from the dependency lists of other entries."""
    #         with self._dependency_lock:
    #             for dependent_keys in self._dependency_map.values():
    #                 if key in dependent_keys:
                        dependent_keys.remove(key)

    #     def _remove_dependencies(self, key: str):
    #         """Remove all dependencies for a key."""
    #         with self._dependency_lock:
    #             if key in self._dependency_map:
    #                 del self._dependency_map[key]

    #     def _key_matches_pattern(self, key: str, pattern: str) -bool):
    #         """Check if a key matches a pattern."""
    #         # Simple pattern matching - could be enhanced with regex
    #         return pattern in key

    #     def _start_cleanup_thread(self):
    #         """Start the background cleanup thread."""

    #         def cleanup_worker():
    #             while not self._cleanup_stop_event.wait(
    #                 self.config.background_cleanup_interval
    #             ):
    #                 try:
                        self.cleanup_expired()
    #                 except Exception as e:
                        self.logger.error(f"Error in background cleanup: {e}")

    self._cleanup_thread = threading.Thread(target=cleanup_worker, daemon=True)
            self._cleanup_thread.start()

    #     def _start_cache_warming_thread(self):
    #         """Start the cache warming thread."""

    #         def warming_worker():
    #             while not self._warming_stop_event.wait(self.config.cache_warming_interval):
    #                 try:
    #                     # This is a placeholder - in a real implementation,
    #                     # you would have a function to determine which keys to warm
                        self.warm_cache([])
    #                 except Exception as e:
                        self.logger.error(f"Error in cache warming: {e}")

    self._warming_thread = threading.Thread(target=warming_worker, daemon=True)
            self._warming_thread.start()

    #     def stop_background_threads(self):
    #         """Stop all background threads."""
    #         if self._cleanup_thread:
                self._cleanup_stop_event.set()
                self._cleanup_thread.join()

    #         if self._warming_thread:
                self._warming_stop_event.set()
                self._warming_thread.join()

    #     def _persist_cache(self):
    #         """Persist the cache to disk."""
    #         if not self.config.enable_persistence or not self.config.persistence_file:
    #             return

    #         try:
    cache_data = {"config": self.config, "stats": self.stats, "entries": {}}

    #             # Convert cache entries to serializable format
    #             for key, entry in self._cache.items():
    cache_data["entries"][key] = {
    #                     "key": entry.key,
                        "value_type": (
    #                         entry.value.type.value
    #                         if hasattr(entry.value, "type")
    #                         else "unknown"
    #                     ),
    #                     "created_at": entry.created_at,
    #                     "last_accessed": entry.last_accessed,
    #                     "access_count": entry.access_count,
    #                     "size": entry.size,
    #                     "expiration": entry.expiration,
    #                     "dependencies": entry.dependencies,
    #                     "reference_count": entry.reference_count,
    #                     "metadata": entry.metadata,
    #                 }

    #             with open(self.config.persistence_file, "wb") as f:
                    pickle.dump(cache_data, f)

    #         except Exception as e:
                self.logger.error(f"Failed to persist cache: {e}")

    #     def _load_cache(self):
    #         """Load the cache from disk."""
    #         if not self.config.persistence_file:
    #             return

    #         try:
    #             with open(self.config.persistence_file, "rb") as f:
    cache_data = pickle.load(f)

    #             # Note: This is a simplified load implementation
    #             # In a real implementation, you would need to reconstruct
    #             # the mathematical objects from the serialized data

                self.logger.info(f"Loaded cache from {self.config.persistence_file}")

    #         except Exception as e:
                self.logger.error(f"Failed to load cache: {e}")

    #     def __del__(self):
    #         """Cleanup when object is destroyed."""
            self.stop_background_threads()


def create_mathematical_object_cache(
config: Optional[CacheConfig] = None,
# ) -MathematicalObjectCache):
#     """Create a mathematical object cache with the specified configuration.

#     Args:
#         config: Cache configuration (uses defaults if None)

#     Returns:
#         MathematicalObjectCache instance
#     """
#     if config is None:
config = CacheConfig()

    return MathematicalObjectCache(config)
