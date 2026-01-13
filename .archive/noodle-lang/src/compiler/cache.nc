# Converted from Python to NoodleCore
# Original file: src

# """
# JIT Cache for NBC Runtime
# -------------------------
# Provides caching mechanisms for JIT compiled code and optimization results.
# """

import functools
import hashlib
import json
import logging
import pickle
import threading
import time
import weakref
import collections.OrderedDict
import concurrent.futures.ThreadPoolExecutor
from dataclasses import dataclass
import pathlib.Path
import typing.Any

import noodlecore.runtime.nbc_runtime.optimization.errors.CacheError

logger = logging.getLogger(__name__)


dataclass
class CacheEntry
    #     """Represents a cache entry."""

    #     key: str
    #     value: Any
    created_at: float = field(default_factory=time.time)
    last_accessed: float = field(default_factory=time.time)
    access_count: int = 0
    size: int = 0
    metadata: Dict[str, Any] = field(default_factory=dict)

    #     def update_access(self):
    #         """Update access statistics."""
    self.last_accessed = time.time()
    self.access_count + = 1

    #     def is_expired(self, ttl: float) -bool):
    #         """Check if cache entry is expired."""
            return (time.time() - self.created_at) ttl


dataclass
class CacheConfig
    #     """Configuration for JIT cache."""

    max_size): int = 1000  # Maximum number of entries
    default_ttl: float = 3600.0  # Default time - to-live in seconds (1 hour)
    enable_persistence: bool = False  # Enable cache persistence
    persistence_file: str = "jit_cache.pkl"
    #     enable_compression: bool = True  # Enable compression for large entries
    #     compression_threshold: int = 1024  # Size threshold for compression in bytes
    enable_eviction_policy: bool = True  # Enable cache eviction policy
    eviction_policy: str = "lru"  # lru, lfu, or fifo
    enable_background_cleanup: bool = True  # Enable background cleanup
    cleanup_interval: float = 300.0  # Cleanup interval in seconds (5 minutes)
    enable_stats: bool = True  # Enable cache statistics
    #     enable_weak_references: bool = False  # Use weak references for values
    redis_url: Optional[str] = (
    #         None  # Redis connection URL, e.g., 'redis://localhost:6379'
    #     )

    #     def validate(self) -bool):
    #         """Validate the cache configuration."""
    #         if self.max_size <= 0:
    #             return False
    #         if self.default_ttl <= 0:
    #             return False
    #         if self.cleanup_interval <= 0:
    #             return False
    #         if self.compression_threshold <= 0:
    #             return False
    #         if self.eviction_policy not in ["lru", "lfu", "fifo"]:
    #             return False
    #         return True


class JITCache
    #     """Just-In-Time cache for compiled code and optimization results."""

    #     def __init__(self, config: CacheConfig = None):""Initialize the JIT cache.

    #         Args:
    #             config: Cache configuration
    #         """
    self.config = config or CacheConfig()

    #         if not self.config.validate():
                raise CacheError(f"Invalid cache configuration: {self.config}")

    #         # Main cache storage
    self._cache: OrderedDict[str, CacheEntry] = OrderedDict()
    self._lock = threading.RLock()

    #         # Statistics
    self.hits = 0
    self.misses = 0
    self.evictions = 0
    self.total_size = 0
    self.total_entries = 0

    #         # Background cleanup
    self._cleanup_thread = None
    self._stop_cleanup = threading.Event()

    #         # Persistence
    self.persistence_file = Path(self.config.persistence_file)

    #         # Initialize background cleanup
    #         if self.config.enable_background_cleanup:
                self._start_background_cleanup()

    #         # Load persisted cache if enabled
    #         if self.config.enable_persistence:
                self._load_cache()

    #         logger.info(f"JIT Cache initialized with config: {self.config}")

    #     def _generate_key(self, *args, **kwargs) -str):
    #         """Generate cache key from arguments."""
    #         # Create a deterministic string representation
    key_data = {"args": args, "kwargs": kwargs, "timestamp": time.time()}

    #         # Convert to JSON string for consistent hashing
    key_str = json.dumps(key_data, sort_keys=True, default=str)

    #         # Generate hash
            return hashlib.sha256(key_str.encode()).hexdigest()

    #     def _compress_value(self, value: Any) -Tuple[Any, bool]):
    #         """Compress value if it's large enough."""
    #         if not self.config.enable_compression:
    #             return value, False

    #         try:
    serialized = pickle.dumps(value)
    #             if len(serialized) self.config.compression_threshold):
    compressed = pickle.loads(
    #                     serialized
    #                 )  # In practice, use actual compression
    #                 return compressed, True
    #         except Exception as e:
                logger.warning(f"Failed to compress value: {e}")

    #         return value, False

    #     def _decompress_value(self, value: Any, compressed: bool) -Any):
    #         """Decompress value if it was compressed."""
    #         if not compressed:
    #             return value

    #         try:
    #             # In practice, use actual decompression
    #             return value
    #         except Exception as e:
                logger.warning(f"Failed to decompress value: {e}")
    #             return value

    #     def _calculate_size(self, value: Any) -int):
    #         """Calculate size of cache entry."""
    #         try:
                return len(pickle.dumps(value))
    #         except Exception:
    #             return 0

    #     def _evict_entry(self):
    #         """Evict an entry based on the eviction policy."""
    #         if not self.config.enable_eviction_policy:
    #             return

    #         with self._lock:
    #             if not self._cache:
    #                 return

    #             if self.config.eviction_policy == "lru":
    #                 # Evict least recently used
    _, entry = self._cache.popitem(last=False)
    #             elif self.config.eviction_policy == "lfu":
    #                 # Evict least frequently used
    #                 # Find entry with lowest access count
    min_key = min(
    self._cache.keys(), key = lambda k: self._cache[k].access_count
    #                 )
    entry = self._cache.pop(min_key)
    #             else:  # fifo
                    # Evict first entry (first in, first out)
    _, entry = self._cache.popitem(last=False)

    self.evictions + = 1
    self.total_size - = entry.size
    self.total_entries - = 1

                logger.debug(f"Evicted cache entry: {entry.key}")

    #     def _cleanup_expired_entries(self):
    #         """Clean up expired cache entries."""
    #         with self._lock:
    current_time = time.time()
    expired_keys = []

    #             for key, entry in self._cache.items():
    #                 if entry.is_expired(self.config.default_ttl):
                        expired_keys.append(key)

    #             for key in expired_keys:
    entry = self._cache.pop(key, None)
    #                 if entry:
    self.total_size - = entry.size
    self.total_entries - = 1
                        logger.debug(f"Cleaned up expired cache entry: {key}")

    #     def _start_background_cleanup(self):
    #         """Start background cleanup thread."""

    #         def cleanup_worker():
    #             while not self._stop_cleanup.wait(self.config.cleanup_interval):
    #                 try:
                        self._cleanup_expired_entries()
                        logger.debug("Background cleanup completed")
    #                 except Exception as e:
                        logger.error(f"Background cleanup failed: {e}")

    self._cleanup_thread = threading.Thread(target=cleanup_worker, daemon=True)
            self._cleanup_thread.start()
            logger.info("Background cleanup thread started")

    #     def _stop_background_cleanup(self):
    #         """Stop background cleanup thread."""
    #         if self._cleanup_thread:
                self._stop_cleanup.set()
    self._cleanup_thread.join(timeout = 5.0)
    self._cleanup_thread = None
                logger.info("Background cleanup thread stopped")

    #     def _save_cache(self):
    #         """Save cache to persistent storage."""
    #         if not self.config.enable_persistence:
    #             return

    #         try:
    #             with self._lock:
    cache_data = {
    #                     "entries": {
    #                         key: {
    #                             "value": entry.value,
    #                             "created_at": entry.created_at,
    #                             "last_accessed": entry.last_accessed,
    #                             "access_count": entry.access_count,
    #                             "size": entry.size,
    #                             "metadata": entry.metadata,
    #                         }
    #                         for key, entry in self._cache.items()
    #                     },
    #                     "stats": {
    #                         "hits": self.hits,
    #                         "misses": self.misses,
    #                         "evictions": self.evictions,
    #                         "total_size": self.total_size,
    #                         "total_entries": self.total_entries,
    #                     },
    #                 }

    #                 with open(self.persistence_file, "wb") as f:
                        pickle.dump(cache_data, f)

                    logger.debug(f"Cache saved to {self.persistence_file}")
    #         except Exception as e:
                logger.error(f"Failed to save cache: {e}")

    #     def _load_cache(self):
    #         """Load cache from persistent storage."""
    #         if not self.config.enable_persistence or not self.persistence_file.exists():
    #             return

    #         try:
    #             with open(self.persistence_file, "rb") as f:
    cache_data = pickle.load(f)

    #             with self._lock:
    #                 # Load entries
    #                 for key, entry_data in cache_data.get("entries", {}).items():
    entry = CacheEntry(
    key = key,
    value = entry_data["value"],
    created_at = entry_data["created_at"],
    last_accessed = entry_data["last_accessed"],
    access_count = entry_data["access_count"],
    size = entry_data["size"],
    metadata = entry_data["metadata"],
    #                     )
    self._cache[key] = entry
    self.total_size + = entry.size
    self.total_entries + = 1

    #                 # Load statistics
    stats = cache_data.get("stats", {})
    self.hits = stats.get("hits", 0)
    self.misses = stats.get("misses", 0)
    self.evictions = stats.get("evictions", 0)
    self.total_size = stats.get("total_size", 0)
    self.total_entries = stats.get("total_entries", 0)

                    logger.debug(f"Cache loaded from {self.persistence_file}")
    #         except Exception as e:
                logger.error(f"Failed to load cache: {e}")

    #     def get(self, key: str) -Optional[Any]):
            """Get value from cache (local or Redis).

    #         Args:
    #             key: Cache key

    #         Returns:
    #             Cached value or None if not found
    #         """
    #         # Try Redis first if available
    #         if self.redis_client:
    #             try:
    cached_value = self.redis_client.get(key)
    #                 if cached_value:
    #                     # Deserialize
    value = pickle.loads(cached_value)
    #                     # Update local cache if needed
    #                     with self._lock:
    entry = self._cache.get(key)
    #                         if entry:
                                entry.update_access()
    #                             if self.config.eviction_policy == "lru":
                                    self._cache.move_to_end(key)
    #                         else:
    size = self._calculate_size(value)
    entry = CacheEntry(key=key, value=value, size=size)
    self._cache[key] = entry
    self.total_entries + = 1
    self.total_size + = size
    #                             if self.config.eviction_policy == "lru":
                                    self._cache.move_to_end(key)
    self.hits + = 1
    #                     logger.debug(f"Redis cache hit for key: {key}")
    #                     return value
    #                 else:
    self.misses + = 1
    #                     logger.debug(f"Redis cache miss for key: {key}")
    #             except Exception as e:
                    logger.warning(
    #                     f"Redis get failed for {key}: {e}. Falling back to local cache."
    #                 )

    #         # Fallback to local cache
    #         with self._lock:
    entry = self._cache.get(key)
    #             if entry:
                    entry.update_access()
    self.hits + = 1
    #                 if self.config.eviction_policy == "lru":
                        self._cache.move_to_end(key)
    #                 logger.debug(f"Local cache hit for key: {key}")
    #                 return entry.value
    #             else:
    self.misses + = 1
    #                 logger.debug(f"Local cache miss for key: {key}")
    #                 return None

    #     def put(
    self, key: str, value: Any, ttl: float = None, metadata: Dict[str, Any] = None
    #     ):
            """Put value into cache (local and Redis).

    #         Args:
    #             key: Cache key
    #             value: Value to cache
                ttl: Time-to-live in seconds (overrides default)
    #             metadata: Additional metadata for the cache entry
    #         """
    #         if ttl is None:
    ttl = self.config.default_ttl

    #         # Calculate size
    size = self._calculate_size(value)

    #         # Compress if needed
    compressed_value, is_compressed = self._compress_value(value)

    #         # Create cache entry
    entry = CacheEntry(
    key = key, value=compressed_value, size=size, metadata=metadata or {}
    #         )
    entry.metadata["compressed"] = is_compressed
    entry.metadata["ttl"] = ttl

    #         # Put to Redis if available
    #         if self.redis_client:
    #             try:
    serialized_value = pickle.dumps(compressed_value)
                    self.redis_client.setex(key, int(ttl), serialized_value)
                    logger.debug(f"Redis cache entry added: {key}")
    #             except Exception as e:
                    logger.warning(
    #                     f"Redis put failed for {key}: {e}. Using local cache only."
    #                 )

    #         with self._lock:
    #             # Check if we need to evict entries
    #             while (
    len(self._cache) = self.config.max_size
    #                 and self.config.enable_eviction_policy
    #             )):
                    self._evict_entry()

    #             # Add entry to local cache
    self._cache[key] = entry
                self._cache.move_to_end(key)  # For LRU policy

    self.total_size + = size
    self.total_entries + = 1

                logger.debug(f"Local cache entry added: {key} (size: {size})")

    #     def delete(self, key: str) -bool):
    #         """Delete value from cache.

    #         Args:
    #             key: Cache key

    #         Returns:
    #             True if entry was deleted, False if not found
    #         """
    #         with self._lock:
    entry = self._cache.pop(key, None)
    #             if entry:
    self.total_size - = entry.size
    self.total_entries - = 1
                    logger.debug(f"Cache entry deleted: {key}")
    #                 return True
    #             return False

    #     def clear(self):
            """Clear all cache entries (local and Redis)."""
    #         # Clear local cache
    #         with self._lock:
                self._cache.clear()
    self.total_size = 0
    self.total_entries = 0
                logger.info("Local cache cleared")

    #         # Clear Redis if available
    #         if self.redis_client:
    #             try:
                    self.redis_client.flushdb()
                    logger.info("Redis cache cleared")
    #             except Exception as e:
                    logger.warning(f"Redis clear failed: {e}")

    #     def get_stats(self) -Dict[str, Any]):
    #         """Get cache statistics."""
    #         with self._lock:
    hit_rate = (
                    self.hits / (self.hits + self.misses)
    #                 if (self.hits + self.misses) 0
    #                 else 0
    #             )

    #             return {
    #                 "hits"): self.hits,
    #                 "misses": self.misses,
    #                 "hit_rate": hit_rate,
    #                 "evictions": self.evictions,
    #                 "total_size": self.total_size,
    #                 "total_entries": self.total_entries,
    #                 "max_size": self.config.max_size,
                    "usage_percent": (
                        (self.total_entries / self.config.max_size) * 100
    #                     if self.config.max_size 0
    #                     else 0
    #                 ),
    #                 "eviction_policy"): self.config.eviction_policy,
    #                 "default_ttl": self.config.default_ttl,
    #                 "enable_persistence": self.config.enable_persistence,
    #                 "enable_background_cleanup": self.config.enable_background_cleanup,
    #             }

    #     def get_all_keys(self) -List[str]):
    #         """Get all cache keys."""
    #         with self._lock:
                return list(self._cache.keys())

    #     def get_entry_info(self, key: str) -Optional[Dict[str, Any]]):
    #         """Get information about a specific cache entry.

    #         Args:
    #             key: Cache key

    #         Returns:
    #             Entry information or None if not found
    #         """
    #         with self._lock:
    entry = self._cache.get(key)
    #             if entry:
    #                 return {
    #                     "key": entry.key,
    #                     "size": entry.size,
    #                     "created_at": entry.created_at,
    #                     "last_accessed": entry.last_accessed,
    #                     "access_count": entry.access_count,
    #                     "metadata": entry.metadata,
    #                 }
    #             return None

    #     def cleanup(self):
    #         """Manually trigger cache cleanup."""
            self._cleanup_expired_entries()
            logger.info("Manual cache cleanup completed")

    #     def health_check(self) -Dict[str, Any]):
    #         """Perform health check on cache."""
    stats = self.get_stats()

    issues = []
    #         if stats["usage_percent"] 90):  # Cache almost full
                issues.append("Cache usage is very high")

    #         if stats["hit_rate"] < 0.5:  # Low hit rate
                issues.append("Low cache hit rate")

    #         if stats["evictions"] stats["total_entries"] * 0.1):  # High eviction rate
                issues.append("High eviction rate - consider increasing cache size")

    #         return {
    #             "status": "healthy" if not issues else "warning",
    #             "issues": issues,
    #             "statistics": stats,
    #         }

    #     def __enter__(self):
    #         """Context manager entry."""
    #         return self

    #     def __exit__(self, exc_type, exc_val, exc_tb):
    #         """Context manager exit."""
    #         # Save cache and cleanup on exit
    #         if self.config.enable_persistence:
                self._save_cache()

            self._stop_background_cleanup()

    #     def __del__(self):
    #         """Cleanup on destruction."""
            self._stop_background_cleanup()


# Export JITCache for backward compatibility
JITCache == JITCache