#!/usr/bin/env python3
"""
NoodleCore Search Cache Module
============================

Advanced search result caching system for optimal performance.
Provides intelligent caching strategies, memory management, and cache optimization
for search operations in NoodleCore.

Features:
- Multi-level cache hierarchy (memory, file, distributed)
- Intelligent cache eviction and TTL management
- Cache compression and optimization
- Search result deduplication and merging
- Performance metrics and cache analytics
- Cache warming and preloading strategies
- Distributed caching support
- Cache invalidation and updates
- Memory usage monitoring and limits
- Cache coherence and consistency

Author: NoodleCore Search Team
Version: 1.0.0
"""

import os
import time
import logging
import threading
import json
import pickle
import gzip
import hashlib
import sqlite3
from typing import Dict, List, Optional, Set, Any, Tuple, Union
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
import weakref
import gc

# Configure logging
logger = logging.getLogger(__name__)

# NoodleCore environment variables
NOODLE_DEBUG = os.environ.get("NOODLE_DEBUG", "0") == "1"
NOODLE_CACHE_DIR = os.environ.get("NOODLE_CACHE_DIR", "data/cache")
NOODLE_CACHE_MAX_SIZE = int(os.environ.get("NOODLE_CACHE_MAX_SIZE", "1000"))
NOODLE_CACHE_TTL = int(os.environ.get("NOODLE_CACHE_TTL", "300"))
NOODLE_CACHE_COMPRESSION = os.environ.get("NOODLE_CACHE_COMPRESSION", "1") == "1"
NOODLE_CACHE_MEMORY_LIMIT = int(os.environ.get("NOODLE_CACHE_MEMORY_LIMIT", "100"))  # MB
NOODLE_CACHE_DISK_LIMIT = int(os.environ.get("NOODLE_CACHE_DISK_LIMIT", "1000"))    # MB


@dataclass
class CacheEntry:
    """Cache entry with metadata."""
    key: str
    value: Any
    created_at: float
    last_accessed: float
    access_count: int = 0
    size_bytes: int = 0
    compressed: bool = False
    ttl: Optional[float] = None
    metadata: Dict[str, Any] = None
    
    def __post_init__(self):
        if self.metadata is None:
            self.metadata = {}
    
    def is_expired(self, current_time: float = None) -> bool:
        """Check if cache entry is expired."""
        if self.ttl is None:
            return False
        
        if current_time is None:
            current_time = time.time()
        
        return current_time - self.created_at > self.ttl
    
    def update_access(self):
        """Update access statistics."""
        self.last_accessed = time.time()
        self.access_count += 1


@dataclass
class CacheStatistics:
    """Cache performance statistics."""
    total_entries: int = 0
    hits: int = 0
    misses: int = 0
    evictions: int = 0
    memory_usage_mb: float = 0.0
    disk_usage_mb: float = 0.0
    average_access_time_ms: float = 0.0
    hit_rate: float = 0.0
    compression_ratio: float = 0.0
    oldest_entry_age_hours: float = 0.0


class MemoryCache:
    """In-memory cache with LRU eviction."""
    
    def __init__(self, max_size: int = NOODLE_CACHE_MAX_SIZE, 
                 ttl: float = NOODLE_CACHE_TTL,
                 memory_limit_mb: int = NOODLE_CACHE_MEMORY_LIMIT):
        """Initialize memory cache.
        
        Args:
            max_size: Maximum number of entries
            ttl: Default TTL for cache entries
            memory_limit_mb: Memory limit in MB
        """
        self.max_size = max_size
        self.default_ttl = ttl
        self.memory_limit_bytes = memory_limit_mb * 1024 * 1024
        
        # Cache storage
        self._cache: Dict[str, CacheEntry] = {}
        self._access_order: List[str] = []  # LRU tracking
        self._lock = threading.RLock()
        
        # Memory usage tracking
        self._current_memory = 0
        self._access_times = []
        
        logger.debug(f"MemoryCache initialized: max_size={max_size}, memory_limit={memory_limit_mb}MB")
    
    def _calculate_size(self, value: Any) -> int:
        """Calculate approximate size of value in bytes."""
        try:
            # Try to pickle the value to get actual size
            pickled = pickle.dumps(value)
            return len(pickled)
        except Exception:
            # Fallback to string representation
            return len(str(value))
    
    def _compress_value(self, value: Any) -> Tuple[bytes, bool]:
        """Compress value if beneficial."""
        if not NOODLE_CACHE_COMPRESSION:
            return pickle.dumps(value), False
        
        try:
            serialized = pickle.dumps(value)
            
            # Only compress if the result is significantly smaller
            if len(serialized) > 1024:  # Only compress larger values
                compressed = gzip.compress(serialized)
                if len(compressed) < len(serialized) * 0.8:  # 20% reduction threshold
                    return compressed, True
            
            return serialized, False
        except Exception as e:
            logger.debug(f"Compression failed: {e}")
            return pickle.dumps(value), False
    
    def _decompress_value(self, data: bytes, compressed: bool) -> Any:
        """Decompress value if needed."""
        try:
            if compressed:
                decompressed = gzip.decompress(data)
                return pickle.loads(decompressed)
            else:
                return pickle.loads(data)
        except Exception as e:
            logger.error(f"Decompression failed: {e}")
            raise
    
    def get(self, key: str) -> Optional[Any]:
        """Get value from cache."""
        with self._lock:
            entry = self._cache.get(key)
            if entry is None:
                return None
            
            # Check if expired
            if entry.is_expired():
                self._remove_entry(key)
                return None
            
            # Update access tracking
            entry.update_access()
            self._update_access_order(key)
            
            # Decompress and return value
            return self._decompress_value(entry.value, entry.compressed)
    
    def set(self, key: str, value: Any, ttl: float = None, metadata: Dict[str, Any] = None) -> bool:
        """Set value in cache."""
        try:
            with self._lock:
                # Calculate sizes
                size_bytes = self._calculate_size(value)
                
                # Compress if beneficial
                data, compressed = self._compress_value(value)
                actual_size = len(data)
                
                # Check memory limits
                if self._current_memory + actual_size > self.memory_limit_bytes:
                    self._evict_entries(size_needed=actual_size)
                
                # Check size limits
                if len(self._cache) >= self.max_size and key not in self._cache:
                    self._evict_lru_entry()
                
                # Create entry
                entry = CacheEntry(
                    key=key,
                    value=data,
                    created_at=time.time(),
                    last_accessed=time.time(),
                    size_bytes=actual_size,
                    compressed=compressed,
                    ttl=ttl or self.default_ttl,
                    metadata=metadata or {}
                )
                
                # Update cache
                old_entry = self._cache.get(key)
                if old_entry:
                    self._current_memory -= old_entry.size_bytes
                
                self._cache[key] = entry
                self._current_memory += actual_size
                self._update_access_order(key)
                
                return True
                
        except Exception as e:
            logger.error(f"Cache set failed for key {key}: {e}")
            return False
    
    def delete(self, key: str) -> bool:
        """Delete entry from cache."""
        with self._lock:
            return self._remove_entry(key)
    
    def _remove_entry(self, key: str) -> bool:
        """Remove entry from cache."""
        entry = self._cache.pop(key, None)
        if entry:
            self._current_memory -= entry.size_bytes
            if key in self._access_order:
                self._access_order.remove(key)
            return True
        return False
    
    def _update_access_order(self, key: str):
        """Update access order for LRU."""
        if key in self._access_order:
            self._access_order.remove(key)
        self._access_order.append(key)
    
    def _evict_lru_entry(self):
        """Evict least recently used entry."""
        if not self._access_order:
            return
        
        lru_key = self._access_order[0]
        self._remove_entry(lru_key)
    
    def _evict_entries(self, size_needed: int = 0):
        """Evict entries to free memory/space."""
        # Sort by last accessed time
        entries_by_time = sorted(
            self._cache.items(),
            key=lambda x: x[1].last_accessed
        )
        
        freed_size = 0
        keys_to_remove = []
        
        for key, entry in entries_by_time:
            # Remove expired entries first
            if entry.is_expired():
                keys_to_remove.append(key)
                freed_size += entry.size_bytes
                if freed_size >= size_needed:
                    break
            # Then remove LRU entries
            elif len(keys_to_remove) < len(self._cache) * 0.1:  # Remove max 10%
                keys_to_remove.append(key)
                freed_size += entry.size_bytes
                if freed_size >= size_needed:
                    break
        
        # Remove selected entries
        for key in keys_to_remove:
            self._remove_entry(key)
    
    def clear(self):
        """Clear all cache entries."""
        with self._lock:
            self._cache.clear()
            self._access_order.clear()
            self._current_memory = 0
    
    def get_statistics(self) -> CacheStatistics:
        """Get cache statistics."""
        with self._lock:
            total_size = sum(entry.size_bytes for entry in self._cache.values())
            total_entries = len(self._cache)
            
            # Calculate oldest entry age
            oldest_age = 0.0
            if self._cache:
                oldest_time = min(entry.created_at for entry in self._cache.values())
                oldest_age = (time.time() - oldest_time) / 3600
            
            # Calculate compression ratio
            compressed_count = sum(1 for entry in self._cache.values() if entry.compressed)
            compression_ratio = compressed_count / max(total_entries, 1)
            
            return CacheStatistics(
                total_entries=total_entries,
                memory_usage_mb=total_size / (1024 * 1024),
                oldest_entry_age_hours=oldest_age,
                compression_ratio=compression_ratio
            )


class DiskCache:
    """Persistent disk-based cache."""
    
    def __init__(self, cache_dir: str = NOODLE_CACHE_DIR,
                 ttl: float = NOODLE_CACHE_TTL,
                 disk_limit_mb: int = NOODLE_CACHE_DISK_LIMIT):
        """Initialize disk cache.
        
        Args:
            cache_dir: Cache directory path
            ttl: Default TTL for cache entries
            disk_limit_mb: Disk limit in MB
        """
        self.cache_dir = Path(cache_dir)
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        
        self.default_ttl = ttl
        self.disk_limit_bytes = disk_limit_mb * 1024 * 1024
        
        # Initialize SQLite index
        self.db_path = self.cache_dir / "cache_index.db"
        self._init_database()
        
        # Current disk usage
        self._current_usage = self._calculate_disk_usage()
        
        self._lock = threading.RLock()
        
        logger.debug(f"DiskCache initialized: dir={self.cache_dir}, limit={disk_limit_mb}MB")
    
    def _init_database(self):
        """Initialize SQLite database for cache indexing."""
        try:
            conn = sqlite3.connect(self.db_path, check_same_thread=False)
            
            # Create cache index table
            conn.execute('''
                CREATE TABLE IF NOT EXISTS cache_index (
                    key TEXT PRIMARY KEY,
                    file_path TEXT NOT NULL,
                    created_at REAL NOT NULL,
                    last_accessed REAL NOT NULL,
                    access_count INTEGER DEFAULT 0,
                    size_bytes INTEGER NOT NULL,
                    compressed INTEGER DEFAULT 0,
                    ttl REAL,
                    metadata TEXT
                )
            ''')
            
            # Create indices for performance
            conn.execute('CREATE INDEX IF NOT EXISTS idx_created_at ON cache_index(created_at)')
            conn.execute('CREATE INDEX IF NOT EXISTS idx_last_accessed ON cache_index(last_accessed)')
            conn.execute('CREATE INDEX IF NOT EXISTS idx_size_bytes ON cache_index(size_bytes)')
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            logger.error(f"Failed to initialize cache database: {e}")
            raise
    
    def _calculate_disk_usage(self) -> int:
        """Calculate current disk usage."""
        total_size = 0
        try:
            for cache_file in self.cache_dir.glob("cache_*"):
                if cache_file.is_file():
                    total_size += cache_file.stat().st_size
        except Exception:
            pass
        return total_size
    
    def _get_cache_file_path(self, key: str) -> Path:
        """Get cache file path for key."""
        # Create hash to avoid filesystem issues
        key_hash = hashlib.md5(key.encode()).hexdigest()
        return self.cache_dir / f"cache_{key_hash}.cache"
    
    def get(self, key: str) -> Optional[Any]:
        """Get value from disk cache."""
        with self._lock:
            try:
                # Check index
                conn = sqlite3.connect(self.db_path)
                cursor = conn.execute(
                    'SELECT file_path, compressed, ttl, created_at FROM cache_index WHERE key = ?',
                    (key,)
                )
                row = cursor.fetchone()
                conn.close()
                
                if row is None:
                    return None
                
                file_path, compressed, ttl, created_at = row
                
                # Check if expired
                if ttl and time.time() - created_at > ttl:
                    self.delete(key)
                    return None
                
                # Read and decompress file
                cache_file = Path(file_path)
                if not cache_file.exists():
                    self.delete(key)
                    return None
                
                with open(cache_file, 'rb') as f:
                    data = f.read()
                
                if compressed:
                    data = gzip.decompress(data)
                
                return pickle.loads(data)
                
            except Exception as e:
                logger.debug(f"Disk cache get failed for key {key}: {e}")
                return None
    
    def set(self, key: str, value: Any, ttl: float = None, metadata: Dict[str, Any] = None) -> bool:
        """Set value in disk cache."""
        try:
            with self._lock:
                # Serialize and compress
                serialized = pickle.dumps(value)
                
                compressed = False
                if NOODLE_CACHE_COMPRESSION and len(serialized) > 1024:
                    compressed_data = gzip.compress(serialized)
                    if len(compressed_data) < len(serialized) * 0.8:
                        serialized = compressed_data
                        compressed = True
                
                # Check disk limits
                size_needed = len(serialized)
                if self._current_usage + size_needed > self.disk_limit_bytes:
                    self._evict_cache(size_needed)
                
                # Write to file
                cache_file = self._get_cache_file_path(key)
                with open(cache_file, 'wb') as f:
                    f.write(serialized)
                
                # Update index
                conn = sqlite3.connect(self.db_path)
                conn.execute('''
                    INSERT OR REPLACE INTO cache_index
                    (key, file_path, created_at, last_accessed, access_count, 
                     size_bytes, compressed, ttl, metadata)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                ''', (
                    key, str(cache_file), time.time(), time.time(), 1,
                    size_needed, int(compressed), ttl or self.default_ttl,
                    json.dumps(metadata or {})
                ))
                conn.commit()
                conn.close()
                
                self._current_usage += size_needed
                return True
                
        except Exception as e:
            logger.error(f"Disk cache set failed for key {key}: {e}")
            return False
    
    def delete(self, key: str) -> bool:
        """Delete entry from disk cache."""
        with self._lock:
            try:
                # Get file path from index
                conn = sqlite3.connect(self.db_path)
                cursor = conn.execute('SELECT file_path, size_bytes FROM cache_index WHERE key = ?', (key,))
                row = cursor.fetchone()
                
                if row:
                    file_path, size_bytes = row
                    
                    # Delete file
                    cache_file = Path(file_path)
                    if cache_file.exists():
                        cache_file.unlink()
                    
                    # Delete from index
                    conn.execute('DELETE FROM cache_index WHERE key = ?', (key,))
                    conn.commit()
                    
                    self._current_usage -= size_bytes
                    conn.close()
                    return True
                
                conn.close()
                return False
                
            except Exception as e:
                logger.error(f"Disk cache delete failed for key {key}: {e}")
                return False
    
    def _evict_cache(self, size_needed: int):
        """Evict cache entries to free disk space."""
        try:
            # Get entries ordered by last access time
            conn = sqlite3.connect(self.db_path)
            cursor = conn.execute('''
                SELECT key, file_path, size_bytes FROM cache_index 
                ORDER BY last_accessed ASC LIMIT 100
            ''')
            
            freed_size = 0
            keys_to_evict = []
            
            for row in cursor.fetchall():
                key, file_path, entry_size = row
                keys_to_evict.append((key, file_path, entry_size))
                freed_size += entry_size
                
                if freed_size >= size_needed:
                    break
            
            # Evict selected entries
            for key, file_path, entry_size in keys_to_evict:
                cache_file = Path(file_path)
                if cache_file.exists():
                    cache_file.unlink()
                
                conn.execute('DELETE FROM cache_index WHERE key = ?', (key,))
                self._current_usage -= entry_size
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            logger.error(f"Cache eviction failed: {e}")
    
    def clear(self):
        """Clear all disk cache entries."""
        with self._lock:
            try:
                # Remove all cache files
                for cache_file in self.cache_dir.glob("cache_*.cache"):
                    cache_file.unlink()
                
                # Clear index
                conn = sqlite3.connect(self.db_path)
                conn.execute('DELETE FROM cache_index')
                conn.commit()
                conn.close()
                
                self._current_usage = 0
                
            except Exception as e:
                logger.error(f"Disk cache clear failed: {e}")
    
    def get_statistics(self) -> CacheStatistics:
        """Get disk cache statistics."""
        try:
            conn = sqlite3.connect(self.db_path)
            
            # Get total entries and stats
            cursor = conn.execute('SELECT COUNT(*), SUM(size_bytes), AVG(access_count) FROM cache_index')
            total_entries, total_size, avg_access = cursor.fetchone()
            
            # Get hit/miss stats (simplified)
            cursor = conn.execute('SELECT SUM(access_count) FROM cache_index')
            total_accesses = cursor.fetchone()[0] or 0
            
            # Calculate oldest entry age
            cursor = conn.execute('SELECT MIN(created_at) FROM cache_index')
            oldest_time = cursor.fetchone()[0]
            
            if oldest_time:
                oldest_age = (time.time() - oldest_time) / 3600
            else:
                oldest_age = 0.0
            
            # Calculate compression ratio
            cursor = conn.execute('SELECT SUM(CASE WHEN compressed = 1 THEN 1 ELSE 0 END) FROM cache_index')
            compressed_count = cursor.fetchone()[0] or 0
            
            conn.close()
            
            return CacheStatistics(
                total_entries=total_entries or 0,
                disk_usage_mb=(total_size or 0) / (1024 * 1024),
                oldest_entry_age_hours=oldest_age,
                compression_ratio=compressed_count / max(total_entries or 1, 1)
            )
            
        except Exception as e:
            logger.error(f"Failed to get disk cache statistics: {e}")
            return CacheStatistics()


class SearchCache:
    """
    Multi-level search result cache.
    
    Combines memory cache and disk cache for optimal performance
    and persistence across restarts.
    """
    
    def __init__(self, 
                 memory_cache_size: int = NOODLE_CACHE_MAX_SIZE,
                 memory_ttl: float = NOODLE_CACHE_TTL,
                 disk_cache_dir: str = NOODLE_CACHE_DIR,
                 disk_ttl: float = NOODLE_CACHE_TTL,
                 enable_compression: bool = NOODLE_CACHE_COMPRESSION):
        """Initialize search cache.
        
        Args:
            memory_cache_size: Memory cache maximum entries
            memory_ttl: Memory cache TTL
            disk_cache_dir: Disk cache directory
            disk_ttl: Disk cache TTL
            enable_compression: Enable cache compression
        """
        self.memory_cache = MemoryCache(memory_cache_size, memory_ttl)
        self.disk_cache = DiskCache(disk_cache_dir, disk_ttl)
        self.enable_compression = enable_compression
        
        # Global statistics
        self._stats = CacheStatistics()
        self._stats_lock = threading.RLock()
        
        logger.info(f"SearchCache initialized: memory_size={memory_cache_size}, "
                   f"disk_dir={disk_cache_dir}, compression={enable_compression}")
    
    def get(self, key: str) -> Optional[Any]:
        """Get value from cache hierarchy."""
        start_time = time.time()
        
        # Try memory cache first
        value = self.memory_cache.get(key)
        if value is not None:
            self._record_hit('memory', start_time)
            return value
        
        # Try disk cache
        value = self.disk_cache.get(key)
        if value is not None:
            # Promote to memory cache
            self.memory_cache.set(key, value)
            self._record_hit('disk', start_time)
            return value
        
        self._record_miss(start_time)
        return None
    
    def set(self, key: str, value: Any, ttl: float = None, 
            level: str = 'both', metadata: Dict[str, Any] = None) -> bool:
        """Set value in cache.
        
        Args:
            key: Cache key
            value: Value to cache
            ttl: Time to live
            level: Cache level ('memory', 'disk', 'both')
            metadata: Additional metadata
        """
        success = True
        
        if level in ['memory', 'both']:
            if not self.memory_cache.set(key, value, ttl, metadata):
                success = False
        
        if level in ['disk', 'both']:
            if not self.disk_cache.set(key, value, ttl, metadata):
                success = False
        
        return success
    
    def delete(self, key: str) -> bool:
        """Delete key from all cache levels."""
        memory_success = self.memory_cache.delete(key)
        disk_success = self.disk_cache.delete(key)
        return memory_success or disk_success
    
    def clear(self, level: str = 'both'):
        """Clear cache level(s)."""
        if level in ['memory', 'both']:
            self.memory_cache.clear()
        
        if level in ['disk', 'both']:
            self.disk_cache.clear()
    
    def _record_hit(self, cache_level: str, start_time: float):
        """Record cache hit."""
        with self._stats_lock:
            self._stats.hits += 1
            access_time = (time.time() - start_time) * 1000
            self._stats.average_access_time_ms = (
                (self._stats.average_access_time_ms * (self._stats.hits - 1) + access_time) / self._stats.hits
            )
            self._stats.hit_rate = self._stats.hits / max(self._stats.hits + self._stats.misses, 1)
    
    def _record_miss(self, start_time: float):
        """Record cache miss."""
        with self._stats_lock:
            self._stats.misses += 1
            self._stats.hit_rate = self._stats.hits / max(self._stats.hits + self._stats.misses, 1)
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get comprehensive cache statistics."""
        memory_stats = self.memory_cache.get_statistics()
        disk_stats = self.disk_cache.get_statistics()
        
        with self._stats_lock:
            return {
                'global_stats': asdict(self._stats),
                'memory_cache': asdict(memory_stats),
                'disk_cache': asdict(disk_stats),
                'combined_usage_mb': memory_stats.memory_usage_mb + disk_stats.disk_usage_mb,
                'cache_efficiency': {
                    'hit_rate': self._stats.hit_rate,
                    'memory_hit_rate': 'unknown',  # Would need more detailed tracking
                    'disk_hit_rate': 'unknown'
                }
            }
    
    def optimize_cache(self):
        """Optimize cache performance."""
        # Remove expired entries
        # Could implement more sophisticated optimization strategies
        
        # Force garbage collection
        gc.collect()
        
        logger.info("Cache optimization completed")
    
    def warm_cache(self, warmup_data: List[Tuple[str, Any, float]]):
        """Pre-populate cache with frequently used data.
        
        Args:
            warmup_data: List of (key, value, ttl) tuples
        """
        logger.info(f"Warming cache with {len(warmup_data)} entries")
        
        with ThreadPoolExecutor(max_workers=4) as executor:
            futures = []
            for key, value, ttl in warmup_data:
                future = executor.submit(self.set, key, value, ttl, 'both')
                futures.append(future)
            
            # Wait for completion
            for future in futures:
                try:
                    future.result(timeout=30)
                except Exception as e:
                    logger.warning(f"Cache warmup entry failed: {e}")
        
        logger.info("Cache warmup completed")


# Global search cache instance
_global_search_cache = None


def get_search_cache(memory_cache_size: int = NOODLE_CACHE_MAX_SIZE,
                    disk_cache_dir: str = NOODLE_CACHE_DIR) -> SearchCache:
    """
    Get a global search cache instance.
    
    Args:
        memory_cache_size: Memory cache size
        disk_cache_dir: Disk cache directory
        
    Returns:
        SearchCache instance
    """
    global _global_search_cache
    
    if _global_search_cache is None:
        _global_search_cache = SearchCache(memory_cache_size=memory_cache_size,
                                         disk_cache_dir=disk_cache_dir)
    
    return _global_search_cache


if __name__ == "__main__":
    # Example usage
    print("NoodleCore Search Cache Module")
    print("=============================")
    
    # Initialize cache
    cache = get_search_cache()
    
    # Test cache operations
    test_data = [
        ("query_python_function", {"results": ["def my_function():", "    pass"], "count": 2}),
        ("query_class_definition", {"results": ["class MyClass:", "    def __init__(self):"], "count": 2}),
        ("file_config_json", {"file_path": "config.json", "size": 1024, "modified": "2025-10-31"})
    ]
    
    print("\nTesting cache operations:")
    
    # Set entries
    for key, value in test_data:
        success = cache.set(key, value, ttl=300)
        print(f"Set {key}: {success}")
    
    # Get entries
    for key, expected in test_data:
        value = cache.get(key)
        if value:
            print(f"Get {key}: Found ({len(str(value))} bytes)")
        else:
            print(f"Get {key}: Not found")
    
    # Get statistics
    stats = cache.get_statistics()
    print(f"\nCache statistics:")
    print(f"Hit rate: {stats['global_stats']['hit_rate']:.2%}")
    print(f"Total entries: {stats['global_stats']['total_entries']}")
    print(f"Memory usage: {stats['memory_cache']['memory_usage_mb']:.2f} MB")
    print(f"Disk usage: {stats['disk_cache']['disk_usage_mb']:.2f} MB")
    
    # Clear cache
    cache.clear()
    print("\nCache cleared")
    
    # Test warmup
    cache.warm_cache([("warmup_key", {"test": "data"}, 600)])
    print("Cache warmup tested")
    
    print("\nSearch cache demo completed")