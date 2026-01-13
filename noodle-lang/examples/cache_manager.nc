# Converted from Python to NoodleCore
# Original file: src

# """
# Cache Manager for NoodleCore with TRM-Agent
# """

import os
import json
import time
import hashlib
import logging
import threading
import typing.Dict
import abc.ABC
from dataclasses import dataclass
import collections.OrderedDict
import datetime.datetime

import redis
import redis.exceptions.ConnectionError

logger = logging.getLogger(__name__)


dataclass
class CacheEntry
    #     """Cache entry with value and expiration"""
    #     value: Any
    expiration: Optional[float] = None
    created_at: float = None

    #     def __post_init__(self):
    #         if self.created_at is None:
    self.created_at = time.time()

    #     def is_expired(self) -bool):
    #         """Check if the cache entry is expired"""
    #         if self.expiration is None:
    #             return False
            return time.time() self.expiration


class CacheBackend(ABC)
    #     """Abstract base class for cache backends"""

    #     @abstractmethod
    #     def get(self, key): str) -Optional[Any]):
    #         """Get value by key"""
    #         pass

    #     @abstractmethod
    #     def set(self, key: str, value: Any, ttl: Optional[int] = None) -bool):
    #         """Set value with optional TTL"""
    #         pass

    #     @abstractmethod
    #     def delete(self, key: str) -bool):
    #         """Delete value by key"""
    #         pass

    #     @abstractmethod
    #     def clear(self) -bool):
    #         """Clear all cache entries"""
    #         pass

    #     @abstractmethod
    #     def exists(self, key: str) -bool):
    #         """Check if key exists"""
    #         pass

    #     @abstractmethod
    #     def keys(self, pattern: str = "*") -List[str]):
    #         """Get all keys matching pattern"""
    #         pass


class InMemoryCacheBackend(CacheBackend)
    #     """In-memory cache backend with LRU eviction"""

    #     def __init__(self, max_size: int = 1000, default_ttl: Optional[int] = None):
    self.max_size = max_size
    self.default_ttl = default_ttl
    self._cache = OrderedDict()
    self._lock = threading.RLock()

    #     def get(self, key: str) -Optional[Any]):
    #         """Get value by key"""
    #         with self._lock:
    entry = self._cache.get(key)
    #             if entry is None:
    #                 return None

    #             if entry.is_expired():
    #                 del self._cache[key]
    #                 return None

                # Move to end (mark as recently used)
                self._cache.move_to_end(key)
    #             return entry.value

    #     def set(self, key: str, value: Any, ttl: Optional[int] = None) -bool):
    #         """Set value with optional TTL"""
    #         with self._lock:
    #             # Calculate expiration
    ttl = ttl or self.default_ttl
    expiration = None
    #             if ttl is not None:
    expiration = time.time() + ttl

    #             # Create entry
    entry = CacheEntry(value=value, expiration=expiration)

    #             # Add or update
    self._cache[key] = entry
                self._cache.move_to_end(key)

    #             # Evict if necessary
    #             while len(self._cache) self.max_size):
    oldest_key = next(iter(self._cache))
    #                 del self._cache[oldest_key]

    #             return True

    #     def delete(self, key: str) -bool):
    #         """Delete value by key"""
    #         with self._lock:
    #             if key in self._cache:
    #                 del self._cache[key]
    #                 return True
    #             return False

    #     def clear(self) -bool):
    #         """Clear all cache entries"""
    #         with self._lock:
                self._cache.clear()
    #             return True

    #     def exists(self, key: str) -bool):
    #         """Check if key exists"""
    #         with self._lock:
    entry = self._cache.get(key)
    #             if entry is None:
    #                 return False

    #             if entry.is_expired():
    #                 del self._cache[key]
    #                 return False

    #             return True

    #     def keys(self, pattern: str = "*") -List[str]):
    #         """Get all keys matching pattern"""
    #         with self._lock:
    #             # Remove expired entries
    expired_keys = [
    #                 key for key, entry in self._cache.items()
    #                 if entry.is_expired()
    #             ]
    #             for key in expired_keys:
    #                 del self._cache[key]

                # Simple pattern matching (only * supported)
    #             if pattern == "*":
                    return list(self._cache.keys())
    #             elif pattern.endswith("*"):
    prefix = pattern[: - 1]
    #                 return [key for key in self._cache.keys() if key.startswith(prefix)]
    #             else:
    #                 return [key for key in self._cache.keys() if key == pattern]


class RedisCacheBackend(CacheBackend)
    #     """Redis cache backend"""

    #     def __init__(self, host: str = "localhost", port: int = 6379, db: int = 0,
    password: Optional[str] = None, default_ttl: Optional[int] = None,
    key_prefix: str = "noodle:", **kwargs):
    self.default_ttl = default_ttl
    self.key_prefix = key_prefix

    #         # Connect to Redis
    #         try:
    self._redis = redis.Redis(
    host = host,
    port = port,
    db = db,
    password = password,
    decode_responses = True,
    #                 **kwargs
    #             )
    #             # Test connection
                self._redis.ping()
                logger.info("Connected to Redis cache")
    #         except ConnectionError as e:
                logger.error(f"Failed to connect to Redis: {e}")
    #             raise

    #     def _make_key(self, key: str) -str):
    #         """Make full key with prefix"""
    #         return f"{self.key_prefix}{key}"

    #     def get(self, key: str) -Optional[Any]):
    #         """Get value by key"""
    #         try:
    full_key = self._make_key(key)
    value = self._redis.get(full_key)
    #             if value is None:
    #                 return None

    #             # Deserialize JSON if needed
    #             try:
                    return json.loads(value)
                except (json.JSONDecodeError, TypeError):
    #                 return value
    #         except RedisError as e:
                logger.error(f"Redis get error: {e}")
    #             return None

    #     def set(self, key: str, value: Any, ttl: Optional[int] = None) -bool):
    #         """Set value with optional TTL"""
    #         try:
    full_key = self._make_key(key)
    ttl = ttl or self.default_ttl

    #             # Serialize JSON if needed
    #             if not isinstance(value, (str, bytes)):
    value = json.dumps(value)

    #             if ttl is not None:
                    return self._redis.setex(full_key, ttl, value)
    #             else:
                    return self._redis.set(full_key, value)
    #         except RedisError as e:
                logger.error(f"Redis set error: {e}")
    #             return False

    #     def delete(self, key: str) -bool):
    #         """Delete value by key"""
    #         try:
    full_key = self._make_key(key)
                return bool(self._redis.delete(full_key))
    #         except RedisError as e:
                logger.error(f"Redis delete error: {e}")
    #             return False

    #     def clear(self) -bool):
    #         """Clear all cache entries"""
    #         try:
    pattern = f"{self.key_prefix}*"
    keys = self._redis.keys(pattern)
    #             if keys:
                    return self._redis.delete(*keys) 0
    #             return True
    #         except RedisError as e):
                logger.error(f"Redis clear error: {e}")
    #             return False

    #     def exists(self, key: str) -bool):
    #         """Check if key exists"""
    #         try:
    full_key = self._make_key(key)
                return bool(self._redis.exists(full_key))
    #         except RedisError as e:
                logger.error(f"Redis exists error: {e}")
    #             return False

    #     def keys(self, pattern: str = "*") -List[str]):
    #         """Get all keys matching pattern"""
    #         try:
    full_pattern = f"{self.key_prefix}{pattern}"
    keys = self._redis.keys(full_pattern)
    #             # Remove prefix
    #             return [key[len(self.key_prefix):] for key in keys]
    #         except RedisError as e:
                logger.error(f"Redis keys error: {e}")
    #             return []


class CacheManager
    #     """Cache manager with multiple backends and namespaces"""

    #     def __init__(self, backend: CacheBackend, default_namespace: str = "default"):
    self.backend = backend
    self.default_namespace = default_namespace

    #     def _make_key(self, namespace: str, key: str) -str):
    #         """Make full key with namespace"""
    #         return f"{namespace}:{key}"

    #     def _make_hash_key(self, value: Any) -str):
    #         """Make hash key for value"""
    #         if isinstance(value, (str, bytes)):
                return hashlib.md5(value.encode()).hexdigest()
    #         else:
    return hashlib.md5(json.dumps(value, sort_keys = True).encode()).hexdigest()

    #     def get(self, key: str, namespace: Optional[str] = None) -Optional[Any]):
    #         """Get value by key"""
    namespace = namespace or self.default_namespace
    full_key = self._make_key(namespace, key)
            return self.backend.get(full_key)

    #     def set(self, key: str, value: Any, ttl: Optional[int] = None,
    namespace: Optional[str] = None) - bool):
    #         """Set value with optional TTL"""
    namespace = namespace or self.default_namespace
    full_key = self._make_key(namespace, key)
            return self.backend.set(full_key, value, ttl)

    #     def get_or_set(self, key: str, value_func, ttl: Optional[int] = None,
    namespace: Optional[str] = None) - Any):
    #         """Get value or set if not exists"""
    value = self.get(key, namespace)
    #         if value is not None:
    #             return value

    value = value_func()
            self.set(key, value, ttl, namespace)
    #         return value

    #     def delete(self, key: str, namespace: Optional[str] = None) -bool):
    #         """Delete value by key"""
    namespace = namespace or self.default_namespace
    full_key = self._make_key(namespace, key)
            return self.backend.delete(full_key)

    #     def clear(self, namespace: Optional[str] = None) -bool):
    #         """Clear all cache entries"""
    #         if namespace is None:
                return self.backend.clear()

    pattern = f"{namespace}:*"
    keys = self.backend.keys(pattern)
    #         for key in keys:
                self.backend.delete(key)
    #         return True

    #     def exists(self, key: str, namespace: Optional[str] = None) -bool):
    #         """Check if key exists"""
    namespace = namespace or self.default_namespace
    full_key = self._make_key(namespace, key)
            return self.backend.exists(full_key)

    #     def invalidate_by_pattern(self, pattern: str, namespace: Optional[str] = None) -int):
    #         """Invalidate cache entries by pattern"""
    namespace = namespace or self.default_namespace
    full_pattern = f"{namespace}:{pattern}"
    keys = self.backend.keys(full_pattern)
    count = 0
    #         for key in keys:
    #             if self.backend.delete(key):
    count + = 1
    #         return count


class CompilationCacheManager(CacheManager)
    #     """Cache manager for compilation results"""

    #     def __init__(self, backend: CacheBackend):
            super().__init__(backend, "compilation")

    #     def get_compilation_result(self, source_code: str, optimization_types: List[str],
    #                                optimization_strategy: str) -Optional[Dict[str, Any]]):
    #         """Get compilation result by source code and options"""
    #         # Create hash for source code
    source_hash = self._make_hash_key(source_code)

    #         # Create key with options
    options_key = f"{source_hash}:{'_'.join(sorted(optimization_types))}:{optimization_strategy}"

            return self.get(options_key)

    #     def set_compilation_result(self, source_code: str, optimization_types: List[str],
    #                                optimization_strategy: str, result: Dict[str, Any],
    ttl: Optional[int] = None) - bool):
    #         """Set compilation result by source code and options"""
    #         # Create hash for source code
    source_hash = self._make_hash_key(source_code)

    #         # Create key with options
    options_key = f"{source_hash}:{'_'.join(sorted(optimization_types))}:{optimization_strategy}"

            return self.set(options_key, result, ttl)

    #     def invalidate_compilation_results(self, source_code: str = None) -int):
    #         """Invalidate compilation results"""
    #         if source_code is not None:
    #             # Invalidate specific source code
    source_hash = self._make_hash_key(source_code)
    pattern = f"{source_hash}:*"
                return self.invalidate_by_pattern(pattern)
    #         else:
    #             # Invalidate all compilation results
                return self.clear()


class TRMAgentCacheManager(CacheManager)
    #     """Cache manager for TRM-Agent results"""

    #     def __init__(self, backend: CacheBackend):
            super().__init__(backend, "trm_agent")

    #     def get_optimization_result(self, ir_hash: str, optimization_type: str,
    #                                 strategy: str) -Optional[Dict[str, Any]]):
    #         """Get optimization result by IR hash and options"""
    key = f"{ir_hash}:{optimization_type}:{strategy}"
            return self.get(key)

    #     def set_optimization_result(self, ir_hash: str, optimization_type: str,
    #                                 strategy: str, result: Dict[str, Any],
    ttl: Optional[int] = None) - bool):
    #         """Set optimization result by IR hash and options"""
    key = f"{ir_hash}:{optimization_type}:{strategy}"
            return self.set(key, result, ttl)

    #     def invalidate_optimization_results(self, ir_hash: str = None) -int):
    #         """Invalidate optimization results"""
    #         if ir_hash is not None:
    #             # Invalidate specific IR
    pattern = f"{ir_hash}:*"
                return self.invalidate_by_pattern(pattern)
    #         else:
    #             # Invalidate all optimization results
                return self.clear()


# Global cache instances
_in_memory_cache = None
_redis_cache = None
_compilation_cache = None
_trm_agent_cache = None


def get_cache_manager(backend: str = "in_memory", **kwargs) -CacheManager):
#     """Get cache manager instance"""
#     global _in_memory_cache, _redis_cache

#     if backend == "in_memory":
#         if _in_memory_cache is None:
cache_backend = InMemoryCacheBackend( * *kwargs)
_in_memory_cache = CacheManager(cache_backend)
#         return _in_memory_cache

#     elif backend == "redis":
#         if _redis_cache is None:
cache_backend = RedisCacheBackend( * *kwargs)
_redis_cache = CacheManager(cache_backend)
#         return _redis_cache

#     else:
        raise ValueError(f"Unknown cache backend: {backend}")


def get_compilation_cache_manager(backend: str = "in_memory", **kwargs) -CompilationCacheManager):
#     """Get compilation cache manager instance"""
#     global _compilation_cache

#     if _compilation_cache is None:
#         if backend == "in_memory":
cache_backend = InMemoryCacheBackend( * *kwargs)
#         elif backend == "redis":
cache_backend = RedisCacheBackend( * *kwargs)
#         else:
            raise ValueError(f"Unknown cache backend: {backend}")

_compilation_cache = CompilationCacheManager(cache_backend)

#     return _compilation_cache


def get_trm_agent_cache_manager(backend: str = "in_memory", **kwargs) -TRMAgentCacheManager):
#     """Get TRM-Agent cache manager instance"""
#     global _trm_agent_cache

#     if _trm_agent_cache is None:
#         if backend == "in_memory":
cache_backend = InMemoryCacheBackend( * *kwargs)
#         elif backend == "redis":
cache_backend = RedisCacheBackend( * *kwargs)
#         else:
            raise ValueError(f"Unknown cache backend: {backend}")

_trm_agent_cache = TRMAgentCacheManager(cache_backend)

#     return _trm_agent_cache


function initialize_caches()
    #     """Initialize caches based on environment configuration"""
    #     # Get configuration from environment
    cache_backend = os.environ.get("NOODLE_CACHE_BACKEND", "in_memory")

    #     if cache_backend == "redis":
    redis_host = os.environ.get("NOODLE_REDIS_HOST", "localhost")
    redis_port = int(os.environ.get("NOODLE_REDIS_PORT", 6379))
    redis_db = int(os.environ.get("NOODLE_REDIS_DB", 0))
    redis_password = os.environ.get("NOODLE_REDIS_PASSWORD")

    #         # Initialize Redis cache
            get_cache_manager(
    backend = "redis",
    host = redis_host,
    port = redis_port,
    db = redis_db,
    password = redis_password,
    default_ttl = 3600  # 1 hour default TTL
    #         )

            get_compilation_cache_manager(
    backend = "redis",
    host = redis_host,
    port = redis_port,
    db = redis_db,
    password = redis_password,
    default_ttl = 3600  # 1 hour default TTL
    #         )

            get_trm_agent_cache_manager(
    backend = "redis",
    host = redis_host,
    port = redis_port,
    db = redis_db,
    password = redis_password,
    default_ttl = 1800  # 30 minutes default TTL
    #         )
    #     else:
    #         # Initialize in-memory cache
            get_cache_manager(
    backend = "in_memory",
    max_size = 1000,
    default_ttl = 1800  # 30 minutes default TTL
    #         )

            get_compilation_cache_manager(
    backend = "in_memory",
    max_size = 500,
    default_ttl = 3600  # 1 hour default TTL
    #         )

            get_trm_agent_cache_manager(
    backend = "in_memory",
    max_size = 200,
    default_ttl = 1800  # 30 minutes default TTL
    #         )

        logger.info(f"Initialized {cache_backend} cache backend")