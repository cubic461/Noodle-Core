# Converted from Python to NoodleCore
# Original file: src

# """
# Database Query Cache
# --------------------
# Cache for database queries to improve performance.
# """

import hashlib
import json
import logging
import threading
import time
import collections.OrderedDict
from dataclasses import dataclass
import datetime.datetime
import enum.Enum
import typing.Any

logger = logging.getLogger(__name__)


class CachePolicy(Enum)
    #     """Cache policy types for database query caching."""

    LRU = "lru"  # Least Recently Used
    LFU = "lfu"  # Least Frequently Used
    FIFO = "fifo"  # First In First Out
    TTL = "ttl"  # Time To Live based
    ADAPTIVE = "adaptive"  # Adaptive policy based on usage patterns


dataclass
class CacheEntry
    #     """Cache entry for a query result."""

    #     key: str
    #     query: str
    #     params: Dict[str, Any]
    #     result: List[Dict[str, Any]]
    #     timestamp: datetime
    access_count: int = 0
    hit_count: int = 0
    size_bytes: int = 0

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary."""
    #         return {
    #             "key": self.key,
    #             "query": self.query,
    #             "params": self.params,
    #             "result": self.result,
                "timestamp": self.timestamp.isoformat(),
    #             "access_count": self.access_count,
    #             "hit_count": self.hit_count,
    #             "size_bytes": self.size_bytes,
    #         }


dataclass
class CacheConfig
    #     """Cache configuration."""

    max_size: int = 1000  # Maximum number of entries
    max_memory_mb: int = 100  # Maximum memory usage in MB
    ttl_seconds: int = 300  # Time to live in seconds
    cleanup_interval: int = 60  # Cleanup interval in seconds
    enabled: bool = True
    compression: bool = True

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary."""
    #         return {
    #             "max_size": self.max_size,
    #             "max_memory_mb": self.max_memory_mb,
    #             "ttl_seconds": self.ttl_seconds,
    #             "cleanup_interval": self.cleanup_interval,
    #             "enabled": self.enabled,
    #             "compression": self.compression,
    #         }


class DatabaseQueryCache
    #     """Cache for database queries."""

    #     def __init__(self, config: Optional[CacheConfig] = None):
    self.config = config or CacheConfig()
    self._cache: OrderedDict[str, CacheEntry] = OrderedDict()
    self._lock = threading.RLock()
    self._last_cleanup = datetime.now()
    self._stats = {"hits": 0, "misses": 0, "evictions": 0, "cleanup_count": 0}
    self._cleanup_thread: Optional[threading.Thread] = None
    self._monitoring = False

    #         # Start cleanup thread if enabled
    #         if self.config.enabled:
                self._start_cleanup_thread()

    #     def _start_cleanup_thread(self) -None):
    #         """Start the cleanup thread."""
    #         if self._monitoring:
    #             return

    self._monitoring = True
    self._cleanup_thread = threading.Thread(target=self._cleanup_loop, daemon=True)
            self._cleanup_thread.start()
            logger.info("Started database query cache cleanup thread")

    #     def _cleanup_loop(self) -None):
    #         """Main cleanup loop."""
    #         while self._monitoring:
    #             try:
                    self._cleanup_expired_entries()
                    time.sleep(self.config.cleanup_interval)
    #             except Exception as e:
                    logger.error(f"Error in cleanup loop: {e}")
                    time.sleep(self.config.cleanup_interval)

    #     def _cleanup_expired_entries(self) -None):
    #         """Clean up expired cache entries."""
    #         with self._lock:
    current_time = datetime.now()
    expired_keys = []

    #             for key, entry in self._cache.items():
    #                 if (
    #                     current_time - entry.timestamp
                    ).total_seconds() self.config.ttl_seconds):
                        expired_keys.append(key)

    #             for key in expired_keys:
                    self._cache.pop(key, None)
    self._stats["evictions"] + = 1

    self._stats["cleanup_count"] + = len(expired_keys)
    self._last_cleanup = current_time

    #             if expired_keys:
                    logger.info(f"Cleaned up {len(expired_keys)} expired cache entries")

    #     def _generate_key(self, query: str, params: Optional[Dict[str, Any]] = None) -str):
    #         """Generate a cache key for a query."""
    #         # Create a string representation of the query and params
    query_str = query.strip()
    #         params_str = json.dumps(params or {}, sort_keys=True) if params else ""

    #         # Create a hash of the query and params
    hash_input = f"{query_str}:{params_str}"
            return hashlib.md5(hash_input.encode("utf-8")).hexdigest()

    #     def _calculate_size(self, result: List[Dict[str, Any]]) -int):
    #         """Calculate the size of a result in bytes."""
    #         try:
    json_str = json.dumps(result)
                return len(json_str.encode("utf-8"))
    #         except Exception:
    #             return 0

    #     def _check_memory_limit(self, new_size: int) -bool):
    #         """Check if adding a new entry would exceed memory limits."""
    #         current_memory = sum(entry.size_bytes for entry in self._cache.values())
    return (current_memory + new_size) < = (self.config.max_memory_mb * 1024 * 1024)

    #     def get(
    self, query: str, params: Optional[Dict[str, Any]] = None
    #     ) -Optional[List[Dict[str, Any]]]):
    #         """Get a cached query result."""
    #         if not self.config.enabled:
    #             return None

    key = self._generate_key(query, params)

    #         with self._lock:
    entry = self._cache.get(key)

    #             if entry:
    #                 # Check if entry is expired
    #                 if (
                        datetime.now() - entry.timestamp
                    ).total_seconds() self.config.ttl_seconds):
                        self._cache.pop(key, None)
    self._stats["misses"] + = 1
    #                     return None

    #                 # Update access statistics
    entry.access_count + = 1
    entry.hit_count + = 1

                    # Move to end (LRU)
                    self._cache.move_to_end(key)

    self._stats["hits"] + = 1
    #                 logger.debug(f"Cache hit for query: {query[:100]}...")
    #                 return entry.result

    self._stats["misses"] + = 1
    #             logger.debug(f"Cache miss for query: {query[:100]}...")
    #             return None

    #     def put(
    #         self,
    #         query: str,
    params: Optional[Dict[str, Any]] = None,
    result: Optional[List[Dict[str, Any]]] = None,
    #     ) -None):
    #         """Put a query result in the cache."""
    #         if not self.config.enabled or result is None:
    #             return

    key = self._generate_key(query, params)
    size = self._calculate_size(result)

    #         with self._lock:
    #             # Check if entry already exists
    #             if key in self._cache:
    existing_entry = self._cache[key]
    #                 if existing_entry.size_bytes >= size:
    #                     # Update existing entry
    existing_entry.result = result
    existing_entry.timestamp = datetime.now()
    existing_entry.size_bytes = size
                        self._cache.move_to_end(key)
    #                     return

    #             # Check memory limit
    #             if not self._check_memory_limit(size):
    #                 # Remove oldest entries until we have space
                    self._evict_entries(size)

    #             # Create new entry
    entry = CacheEntry(
    key = key,
    query = query,
    params = params or {},
    result = result,
    timestamp = datetime.now(),
    size_bytes = size,
    #             )

    #             # Add to cache
    self._cache[key] = entry
                self._cache.move_to_end(key)

    #             # Check size limit
    #             if len(self._cache) self.config.max_size):
    #                 # Remove oldest entry
    self._cache.popitem(last = False)
    self._stats["evictions"] + = 1

    #             logger.debug(f"Cache put for query: {query[:100]}...")

    #     def _evict_entries(self, required_size: int) -None):
    #         """Evict entries to make space for a new entry."""
    #         current_memory = sum(entry.size_bytes for entry in self._cache.values())
    target_memory = (self.config.max_memory_mb * 1024 * 1024 - required_size)

    #         while current_memory target_memory and self._cache):
    #             # Remove oldest entry
    _, entry = self._cache.popitem(last=False)
    current_memory - = entry.size_bytes
    self._stats["evictions"] + = 1

    #     def remove(self, query: str, params: Optional[Dict[str, Any]] = None) -bool):
    #         """Remove a query from the cache."""
    key = self._generate_key(query, params)

    #         with self._lock:
    #             if key in self._cache:
                    self._cache.pop(key)
                    logger.debug(f"Removed query from cache: {query[:100]}...")
    #                 return True
    #             return False

    #     def clear(self) -None):
    #         """Clear all cache entries."""
    #         with self._lock:
                self._cache.clear()
    self._stats["evictions"] + = len(self._cache)
                logger.info("Cleared all cache entries")

    #     def get_stats(self) -Dict[str, Any]):
    #         """Get cache statistics."""
    #         with self._lock:
    total_accesses = self._stats["hits"] + self._stats["misses"]
    hit_rate = (
                    (self._stats["hits"] / total_accesses * 100)
    #                 if total_accesses 0
    #                 else 0
    #             )

    #             total_memory = sum(entry.size_bytes for entry in self._cache.values())

    #             return {
    #                 "hits"): self._stats["hits"],
    #                 "misses": self._stats["misses"],
    #                 "hit_rate_percent": hit_rate,
    #                 "evictions": self._stats["evictions"],
    #                 "cleanup_count": self._stats["cleanup_count"],
                    "entry_count": len(self._cache),
    #                 "memory_bytes": total_memory,
                    "memory_mb": total_memory / (1024 * 1024),
                    "last_cleanup": self._last_cleanup.isoformat(),
    #             }

    #     def get_entries(self) -List[CacheEntry]):
    #         """Get all cache entries."""
    #         with self._lock:
                return list(self._cache.values())

    #     def get_entry(
    self, query: str, params: Optional[Dict[str, Any]] = None
    #     ) -Optional[CacheEntry]):
    #         """Get a specific cache entry."""
    key = self._generate_key(query, params)

    #         with self._lock:
                return self._cache.get(key)

    #     def export_cache(self, filename: str) -None):
    #         """Export cache to a file."""
    entries = self.get_entries()

    data = {
                "export_time": datetime.now().isoformat(),
                "config": self.config.to_dict(),
                "stats": self.get_stats(),
    #             "entries": [entry.to_dict() for entry in entries],
    #         }

    #         with open(filename, "w") as f:
    json.dump(data, f, indent = 2)

            logger.info(f"Exported {len(entries)} cache entries to {filename}")

    #     def import_cache(self, filename: str) -None):
    #         """Import cache from a file."""
    #         with open(filename, "r") as f:
    data = json.load(f)

    entries = []
    #         for entry_data in data["entries"]:
    entry = CacheEntry(
    key = entry_data["key"],
    query = entry_data["query"],
    params = entry_data["params"],
    result = entry_data["result"],
    timestamp = datetime.fromisoformat(entry_data["timestamp"]),
    access_count = entry_data.get("access_count", 0),
    hit_count = entry_data.get("hit_count", 0),
    size_bytes = entry_data.get("size_bytes", 0),
    #             )
                entries.append(entry)

    #         with self._lock:
                self._cache.clear()
    #             for entry in entries:
    self._cache[entry.key] = entry
                    self._cache.move_to_end(entry.key)

            logger.info(f"Imported {len(entries)} cache entries from {filename}")

    #     def set_config(self, config: CacheConfig) -None):
    #         """Set new configuration."""
    self.config = config

    #         # Restart cleanup thread if enabled
    #         if self.config.enabled and not self._monitoring:
                self._start_cleanup_thread()
    #         elif not self.config.enabled and self._monitoring:
                self.stop_monitoring()

            logger.info("Updated database query cache configuration")

    #     def get_config(self) -CacheConfig):
    #         """Get current configuration."""
    #         return self.config

    #     def stop_monitoring(self) -None):
    #         """Stop the cleanup thread."""
    self._monitoring = False
    #         if self._cleanup_thread:
    self._cleanup_thread.join(timeout = 5)
    self._cleanup_thread = None
            logger.info("Stopped database query cache monitoring")

    #     def is_monitoring(self) -bool):
    #         """Check if monitoring is active."""
    #         return self._monitoring

    #     def add_callback(
    #         self, callback: Callable[[str, Dict[str, Any], List[Dict[str, Any]]], None]
    #     ) -None):
    #         """Add a callback for cache events."""
    #         # This would be implemented to notify of cache hits/misses
    #         pass

    #     def remove_callback(
    #         self, callback: Callable[[str, Dict[str, Any], List[Dict[str, Any]]], None]
    #     ) -None):
    #         """Remove a callback for cache events."""
    #         # This would be implemented to remove callbacks
    #         pass

    #     def get_hot_queries(self, limit: int = 10) -List[Dict[str, Any]]):
    #         """Get the most frequently accessed queries."""
    #         with self._lock:
    sorted_entries = sorted(
    self._cache.values(), key = lambda x: x.access_count, reverse=True
    #             )

    #             return [
    #                 {
    #                     "query": entry.query,
    #                     "params": entry.params,
    #                     "access_count": entry.access_count,
    #                     "hit_count": entry.hit_count,
                        "hit_rate": (
    #                         entry.hit_count / entry.access_count
    #                         if entry.access_count 0
    #                         else 0
    #                     ),
                        "last_access"): entry.timestamp.isoformat(),
    #                     "size_bytes": entry.size_bytes,
    #                 }
    #                 for entry in sorted_entries[:limit]
    #             ]

    #     def get_expired_queries(self) -List[Dict[str, Any]]):
    #         """Get queries that are expired or about to expire."""
    current_time = datetime.now()
    expired_queries = []

    #         with self._lock:
    #             for entry in self._cache.values():
    age = (current_time - entry.timestamp.total_seconds())
    #                 if age self.config.ttl_seconds * 0.8):  # 80% of TTL
                        expired_queries.append(
    #                         {
    #                             "query": entry.query,
    #                             "params": entry.params,
    #                             "age_seconds": age,
    #                             "ttl_seconds": self.config.ttl_seconds,
    #                             "access_count": entry.access_count,
    #                             "hit_count": entry.hit_count,
    #                         }
    #                     )

    #         return expired_queries
