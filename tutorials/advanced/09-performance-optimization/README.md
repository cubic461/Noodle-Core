# ⚡ Tutorial 09: Performance Optimization

> **Advanced NIP v3.0.0 Tutorial** - Maximizing performance and scalability

## Table of Contents
- [Overview](#overview)
- [Profiling and Monitoring](#profiling-and-monitoring)
- [Caching Strategies](#caching-strategies)
- [Database Optimization](#database-optimization)
- [Connection Pooling](#connection-pooling)
- [Async Operations](#async-operations)
- [Load Testing](#load-testing)
- [Performance Benchmarks](#performance-benchmarks)
- [Optimization Techniques](#optimization-techniques)
- [Practical Exercises](#practical-exercises)
- [Best Practices](#best-practices)

---

## Overview

Performance optimization is critical for production deployments. This tutorial covers comprehensive strategies to maximize throughput, minimize latency, and ensure scalability of your NIP v3.0.0 applications.

### What You'll Learn
- Profiling tools and monitoring techniques
- Multi-layer caching strategies
- Database query optimization
- Connection pooling for high concurrency
- Async/await patterns for I/O-bound operations
- Load testing methodologies
- Performance benchmarking
- Production optimization techniques

### Prerequisites
- Completed Tutorials 01-08
- Basic understanding of async programming
- Familiarity with Redis and PostgreSQL
- Linux system administration basics

### Key Performance Metrics

| Metric | Target | Description |
|--------|--------|-------------|
| **P50 Latency** | < 100ms | Median response time |
| **P99 Latency** | < 500ms | 99th percentile response time |
| **Throughput** | > 1000 req/s | Requests per second |
| **Memory Usage** | < 80% | Maximum memory utilization |
| **CPU Usage** | < 70% | Average CPU utilization |
| **Cache Hit Rate** | > 85% | Percentage of cache hits |

---

## Profiling and Monitoring

### Built-in Profiler

NIP v3.0.0 includes a comprehensive profiling system:

```python
# nip/utils/profiler.py
import time
import functools
import psutil
import asyncio
from typing import Dict, Any, Callable, Optional
from contextlib import asynccontextmanager
from dataclasses import dataclass, asdict
from datetime import datetime
import json

@dataclass
class ProfileStats:
    """Performance statistics for a function call"""
    name: str
    duration_ms: float
    cpu_percent: float
    memory_mb: float
    timestamp: str
    
    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


class Profiler:
    """Performance profiler for monitoring function execution"""
    
    def __init__(self, enabled: bool = True):
        self.enabled = enabled
        self.stats: list[ProfileStats] = []
        self.process = psutil.Process()
    
    def profile(self, name: Optional[str] = None) -> Callable:
        """Decorator to profile a function"""
        def decorator(func: Callable) -> Callable:
            @functools.wraps(func)
            def sync_wrapper(*args, **kwargs):
                if not self.enabled:
                    return func(*args, **kwargs)
                
                func_name = name or func.__name__
                
                # Measure before
                cpu_before = self.process.cpu_percent()
                mem_before = self.process.memory_info().rss / 1024 / 1024
                start_time = time.perf_counter()
                
                try:
                    result = func(*args, **kwargs)
                    return result
                finally:
                    # Measure after
                    duration = (time.perf_counter() - start_time) * 1000
                    cpu_after = self.process.cpu_percent()
                    mem_after = self.process.memory_info().rss / 1024 / 1024
                    
                    stats = ProfileStats(
                        name=func_name,
                        duration_ms=round(duration, 2),
                        cpu_percent=round((cpu_before + cpu_after) / 2, 2),
                        memory_mb=round(mem_after - mem_before, 2),
                        timestamp=datetime.now().isoformat()
                    )
                    self.stats.append(stats)
            
            @functools.wraps(func)
            async def async_wrapper(*args, **kwargs):
                if not self.enabled:
                    return await func(*args, **kwargs)
                
                func_name = name or func.__name__
                
                # Measure before
                cpu_before = self.process.cpu_percent()
                mem_before = self.process.memory_info().rss / 1024 / 1024
                start_time = time.perf_counter()
                
                try:
                    result = await func(*args, **kwargs)
                    return result
                finally:
                    # Measure after
                    duration = (time.perf_counter() - start_time) * 1000
                    cpu_after = self.process.cpu_percent()
                    mem_after = self.process.memory_info().rss / 1024 / 1024
                    
                    stats = ProfileStats(
                        name=func_name,
                        duration_ms=round(duration, 2),
                        cpu_percent=round((cpu_before + cpu_after) / 2, 2),
                        memory_mb=round(mem_after - mem_before, 2),
                        timestamp=datetime.now().isoformat()
                    )
                    self.stats.append(stats)
            
            # Return appropriate wrapper based on function type
            if asyncio.iscoroutinefunction(func):
                return async_wrapper
            else:
                return sync_wrapper
        
        return decorator
    
    def get_stats(self, filter_name: Optional[str] = None) -> list[ProfileStats]:
        """Get profiling statistics, optionally filtered by name"""
        if filter_name:
            return [s for s in self.stats if s.name == filter_name]
        return self.stats
    
    def get_summary(self) -> Dict[str, Any]:
        """Get summary statistics"""
        if not self.stats:
            return {}
        
        # Group by name
        grouped: Dict[str, list[ProfileStats]] = {}
        for stat in self.stats:
            if stat.name not in grouped:
                grouped[stat.name] = []
            grouped[stat.name].append(stat)
        
        # Calculate aggregates
        summary = {}
        for name, stats_list in grouped.items():
            durations = [s.duration_ms for s in stats_list]
            memory = [s.memory_mb for s in stats_list]
            
            summary[name] = {
                "calls": len(stats_list),
                "avg_duration_ms": round(sum(durations) / len(durations), 2),
                "min_duration_ms": round(min(durations), 2),
                "max_duration_ms": round(max(durations), 2),
                "p95_duration_ms": round(sorted(durations)[int(len(durations) * 0.95)], 2),
                "p99_duration_ms": round(sorted(durations)[int(len(durations) * 0.99)], 2),
                "avg_memory_mb": round(sum(memory) / len(memory), 2),
                "total_memory_mb": round(sum(memory), 2)
            }
        
        return summary
    
    def save_report(self, path: str):
        """Save profiling report to JSON file"""
        report = {
            "summary": self.get_summary(),
            "detailed": [s.to_dict() for s in self.stats]
        }
        
        with open(path, 'w') as f:
            json.dump(report, f, indent=2)
    
    def clear(self):
        """Clear all statistics"""
        self.stats.clear()


# Global profiler instance
profiler = Profiler()
```

### Usage Example

```python
# examples/profiling_example.py
from nip.utils.profiler import profiler
import time

@profiler.profile("database_query")
def fetch_user_data(user_id: int):
    """Simulate database query"""
    time.sleep(0.05)  # Simulate 50ms query
    return {"id": user_id, "name": "John Doe"}

@profiler.profile("api_call")
async def process_request(user_id: int):
    """Process API request"""
    user = fetch_user_data(user_id)
    time.sleep(0.02)  # Simulate processing
    return user

async def main():
    # Run multiple requests
    for i in range(100):
        await process_request(i)
    
    # Print summary
    summary = profiler.get_summary()
    print("Performance Summary:")
    for name, stats in summary.items():
        print(f"\n{name}:")
        print(f"  Calls: {stats['calls']}")
        print(f"  Avg Duration: {stats['avg_duration_ms']}ms")
        print(f"  P95 Duration: {stats['p95_duration_ms']}ms")
        print(f"  P99 Duration: {stats['p99_duration_ms']}ms")
    
    # Save detailed report
    profiler.save_report("profile_report.json")

if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
```

---

## Caching Strategies

### Multi-Layer Caching Architecture

```python
# nip/cache/multi_layer.py
import json
import hashlib
import asyncio
from typing import Any, Optional, Dict, List, Callable
from functools import wraps
from datetime import timedelta
import aioredis
from cachetools import TTLCache
import pickle

class MultiLayerCache:
    """Multi-layer caching system with L1 (memory) and L2 (Redis)"""
    
    def __init__(
        self,
        redis_url: str = "redis://localhost:6379",
        l1_size: int = 1000,
        l1_ttl: int = 300,  # 5 minutes
        l2_ttl: int = 3600  # 1 hour
    ):
        self.l1_cache = TTLCache(maxsize=l1_size, ttl=l1_ttl)
        self.l2_ttl = l2_ttl
        self.redis_client: Optional[aioredis.Redis] = None
        self.redis_url = redis_url
        self.enabled = True
    
    async def initialize(self):
        """Initialize Redis connection"""
        if self.redis_url:
            self.redis_client = await aioredis.from_url(self.redis_url)
    
    async def close(self):
        """Close Redis connection"""
        if self.redis_client:
            await self.redis_client.close()
    
    def _generate_key(self, func_name: str, args: tuple, kwargs: dict) -> str:
        """Generate cache key from function arguments"""
        # Create a deterministic hash of arguments
        args_str = f"{func_name}:{args}:{kwargs}"
        return hashlib.sha256(args_str.encode()).hexdigest()
    
    async def get(self, key: str) -> Optional[Any]:
        """Get value from cache (L1 then L2)"""
        if not self.enabled:
            return None
        
        # Try L1 cache first (fastest)
        if key in self.l1_cache:
            return self.l1_cache[key]
        
        # Try L2 cache (Redis)
        if self.redis_client:
            try:
                value = await self.redis_client.get(key)
                if value:
                    # Deserialize and store in L1
                    deserialized = pickle.loads(value)
                    self.l1_cache[key] = deserialized
                    return deserialized
            except Exception as e:
                print(f"Redis error: {e}")
        
        return None
    
    async def set(self, key: str, value: Any, ttl: Optional[int] = None):
        """Set value in both L1 and L2 cache"""
        if not self.enabled:
            return
        
        ttl = ttl or self.l2_ttl
        
        # Store in L1
        self.l1_cache[key] = value
        
        # Store in L2
        if self.redis_client:
            try:
                serialized = pickle.dumps(value)
                await self.redis_client.setex(key, ttl, serialized)
            except Exception as e:
                print(f"Redis error: {e}")
    
    async def delete(self, key: str):
        """Delete from both cache layers"""
        # Delete from L1
        if key in self.l1_cache:
            del self.l1_cache[key]
        
        # Delete from L2
        if self.redis_client:
            try:
                await self.redis_client.delete(key)
            except Exception as e:
                print(f"Redis error: {e}")
    
    async def clear_all(self):
        """Clear all cache layers"""
        # Clear L1
        self.l1_cache.clear()
        
        # Clear L2
        if self.redis_client:
            try:
                await self.redis_client.flushdb()
            except Exception as e:
                print(f"Redis error: {e}")
    
    def cache_decorator(
        self,
        ttl: Optional[int] = None,
        key_prefix: Optional[str] = None
    ) -> Callable:
        """Decorator for caching function results"""
        def decorator(func: Callable) -> Callable:
            @wraps(func)
            async def async_wrapper(*args, **kwargs):
                if not self.enabled:
                    return await func(*args, **kwargs)
                
                # Generate cache key
                func_name = key_prefix or func.__name__
                cache_key = self._generate_key(func_name, args, kwargs)
                
                # Try to get from cache
                cached = await self.get(cache_key)
                if cached is not None:
                    return cached
                
                # Execute function
                result = await func(*args, **kwargs)
                
                # Cache result
                await self.set(cache_key, result, ttl)
                
                return result
            
            return async_wrapper
        
        return decorator


class CacheWarmer:
    """Proactive cache warming for frequently accessed data"""
    
    def __init__(self, cache: MultiLayerCache):
        self.cache = cache
        self.warmup_tasks: Dict[str, Callable] = {}
    
    def register_task(self, name: str, loader: Callable):
        """Register a cache warming task"""
        self.warmup_tasks[name] = loader
    
    async def warm_cache(self, task_name: str, *args, **kwargs):
        """Execute a cache warming task"""
        if task_name in self.warmup_tasks:
            loader = self.warmup_tasks[task_name]
            result = await loader(*args, **kwargs)
            
            # Cache the result
            key = f"warmup:{task_name}"
            await self.cache.set(key, result)
            
            return result
        return None
    
    async def warm_all(self):
        """Execute all registered warmup tasks"""
        for task_name in self.warmup_tasks:
            await self.warm_cache(task_name)
```

### Caching Implementation Examples

```python
# examples/caching_example.py
from nip.cache.multi_layer import MultiLayerCache, CacheWarmer
import asyncio
import time

# Initialize cache
cache = MultiLayerCache(
    redis_url="redis://localhost:6379",
    l1_size=1000,
    l1_ttl=300,
    l2_ttl=3600
)

# Example 1: Database query caching
@cache.cache_decorator(ttl=600, key_prefix="user_profile")
async def get_user_profile(user_id: int) -> dict:
    """Fetch user profile with caching"""
    # Simulate database query
    time.sleep(0.1)  # 100ms query time
    return {
        "id": user_id,
        "name": f"User {user_id}",
        "email": f"user{user_id}@example.com",
        "created_at": "2024-01-01"
    }

# Example 2: API response caching
@cache.cache_decorator(ttl=3600, key_prefix="weather_data")
async def get_weather(city: str) -> dict:
    """Fetch weather data with caching"""
    # Simulate API call
    time.sleep(0.05)  # 50ms API call
    return {
        "city": city,
        "temperature": 22,
        "condition": "Sunny"
    }

# Example 3: Computation caching
@cache.cache_decorator(ttl=1800)
async def expensive_computation(n: int) -> int:
    """Cache expensive computation results"""
    # Simulate heavy computation
    time.sleep(0.2)
    return sum(range(n))

async def main():
    await cache.initialize()
    
    # Test cache performance
    print("First call (cache miss):")
    start = time.time()
    user = await get_user_profile(1)
    print(f"  Duration: {(time.time() - start) * 1000:.2f}ms")
    
    print("\nSecond call (cache hit):")
    start = time.time()
    user = await get_user_profile(1)
    print(f"  Duration: {(time.time() - start) * 1000:.2f}ms")
    
    # Cache warmer example
    warmer = CacheWarmer(cache)
    
    async def load_popular_posts():
        time.sleep(0.1)
        return [{"id": i, "title": f"Post {i}"} for i in range(10)]
    
    warmer.register_task("popular_posts", load_popular_posts)
    await warmer.warm_cache("popular_posts")
    
    print("\nCache warmed successfully!")
    
    await cache.close()

if __name__ == "__main__":
    asyncio.run(main())
```

---

## Database Optimization

### Query Optimization

```python
# nip/database/optimizer.py
from typing import List, Dict, Any, Optional
from sqlalchemy import text, create_engine
from sqlalchemy.orm import Session
from sqlalchemy.pool import QueuePool
import psycopg2
from psycopg2 import sql
import time

class DatabaseOptimizer:
    """Database query and connection optimization"""
    
    def __init__(
        self,
        connection_string: str,
        pool_size: int = 20,
        max_overflow: int = 40
    ):
        self.engine = create_engine(
            connection_string,
            poolclass=QueuePool,
            pool_size=pool_size,
            max_overflow=max_overflow,
            pool_pre_ping=True,  # Verify connections
            pool_recycle=3600,   # Recycle after 1 hour
            echo=False
        )
        
        self.connection_string = connection_string
    
    def analyze_query(self, query: str) -> Dict[str, Any]:
        """Analyze query performance"""
        with self.engine.connect() as conn:
            # Get query plan
            result = conn.execute(
                text(f"EXPLAIN ANALYZE {query}")
            )
            
            plan = result.fetchall()
            
            # Extract metrics
            execution_time = None
            for line in plan:
                if "Execution Time:" in str(line):
                    execution_time = float(
                        str(line).split("Execution Time:")[1].split("ms")[0].strip()
                    )
            
            return {
                "plan": plan,
                "execution_time_ms": execution_time
            }
    
    def create_index(self, table: str, columns: List[str], unique: bool = False):
        """Create database index"""
        index_name = f"idx_{table}_{'_'.join(columns)}"
        unique_str = "UNIQUE " if unique else ""
        
        query = f"""
        CREATE {unique_str}INDEX IF NOT EXISTS {index_name}
        ON {table} ({', '.join(columns)})
        """
        
        with self.engine.connect() as conn:
            conn.execute(text(query))
            conn.commit()
    
    def analyze_table(self, table: str) -> Dict[str, Any]:
        """Get table statistics"""
        with self.engine.connect() as conn:
            # Row count
            count_result = conn.execute(
                text(f"SELECT COUNT(*) FROM {table}")
            )
            row_count = count_result.scalar()
            
            # Table size
            size_result = conn.execute(
                text(f"""
                SELECT 
                    pg_size_pretty(pg_total_relation_size('{table}')) AS size
                """)
            )
            size = size_result.scalar()
            
            # Index usage
            index_result = conn.execute(
                text(f"""
                SELECT 
                    indexrelname,
                    idx_scan,
                    idx_tup_read,
                    idx_tup_fetch
                FROM pg_stat_user_indexes
                WHERE schemaname = 'public' AND relname = '{table}'
                """)
            )
            indexes = index_result.fetchall()
            
            return {
                "row_count": row_count,
                "size": size,
                "indexes": indexes
            }
    
    def optimize_table(self, table: str):
        """Run VACUUM ANALYZE on table"""
        with self.engine.connect() as conn:
            conn.execute(text(f"VACUUM ANALYZE {table}"))
            conn.commit()
    
    def batch_insert(self, table: str, data: List[Dict[str, Any]], batch_size: int = 1000):
        """Optimized batch insert"""
        if not data:
            return
        
        columns = list(data[0].keys())
        
        # Process in batches
        for i in range(0, len(data), batch_size):
            batch = data[i:i + batch_size]
            
            # Build bulk insert query
            values = []
            for row in batch:
                row_values = [f"'{row[col]}'" for col in columns]
                values.append(f"({', '.join(row_values)})")
            
            query = f"""
            INSERT INTO {table} ({', '.join(columns)})
            VALUES {', '.join(values)}
            """
            
            with self.engine.connect() as conn:
                conn.execute(text(query))
                conn.commit()
            
            print(f"Inserted batch {i//batch_size + 1}/{(len(data)-1)//batch_size + 1}")
    
    def close(self):
        """Close database connections"""
        self.engine.dispose()


# Query optimization examples
class OptimizedQueries:
    """Examples of optimized database queries"""
    
    @staticmethod
    def bad_query():
        """INNEFICIENT: N+1 query problem"""
        query = """
        SELECT * FROM users;
        -- Then for each user:
        SELECT * FROM posts WHERE user_id = ?;
        """
        return query
    
    @staticmethod
    def good_query():
        """EFFICIENT: Single query with JOIN"""
        query = """
        SELECT 
            u.id, u.name, u.email,
            p.id as post_id, p.title, p.created_at
        FROM users u
        LEFT JOIN posts p ON u.id = p.user_id
        """
        return query
    
    @staticmethod
    def indexed_query(user_id: int):
        """EFFICIENT: Using indexed columns"""
        query = f"""
        SELECT * FROM posts
        WHERE user_id = {user_id}
        AND created_at > NOW() - INTERVAL '30 days'
        ORDER BY created_at DESC
        LIMIT 100
        """
        return query
    
    @staticmethod
    def aggregate_query():
        """EFFICIENT: Database-side aggregation"""
        query = """
        SELECT 
            DATE(created_at) as date,
            COUNT(*) as post_count,
            AVG(likes) as avg_likes
        FROM posts
        WHERE created_at > NOW() - INTERVAL '30 days'
        GROUP BY DATE(created_at)
        ORDER BY date DESC
        """
        return query
```

---

## Connection Pooling

### Advanced Connection Pool

```python
# nip/database/pool.py
import asyncio
from typing import Optional, Callable, Any
import asyncpg
from contextlib import asynccontextmanager
import time

class ConnectionPool:
    """Advanced PostgreSQL connection pool"""
    
    def __init__(
        self,
        dsn: str,
        min_size: int = 10,
        max_size: int = 50,
        command_timeout: float = 60.0,
        max_queries: int = 50000,
        max_inactive_connection_lifetime: float = 300.0
    ):
        self.dsn = dsn
        self.min_size = min_size
        self.max_size = max_size
        self.command_timeout = command_timeout
        self.max_queries = max_queries
        self.max_inactive_connection_lifetime = max_inactive_connection_lifetime
        
        self.pool: Optional[asyncpg.Pool] = None
    
    async def initialize(self):
        """Initialize connection pool"""
        self.pool = await asyncpg.create_pool(
            self.dsn,
            min_size=self.min_size,
            max_size=self.max_size,
            command_timeout=self.command_timeout,
            max_queries=self.max_queries,
            max_inactive_connection_lifetime=self.max_inactive_connection_lifetime
        )
    
    @asynccontextmanager
    async def acquire(self):
        """Acquire connection from pool"""
        async with self.pool.acquire() as connection:
            yield connection
    
    async def execute(self, query: str, *args) -> str:
        """Execute SQL query"""
        async with self.acquire() as conn:
            return await conn.execute(query, *args)
    
    async def fetch(self, query: str, *args) -> list:
        """Fetch rows from query"""
        async with self.acquire() as conn:
            return await conn.fetch(query, *args)
    
    async def fetchrow(self, query: str, *args) -> Optional[asyncpg.Record]:
        """Fetch single row"""
        async with self.acquire() as conn:
            return await conn.fetchrow(query, *args)
    
    async def fetchval(self, query: str, *args, column: int = 0) -> Any:
        """Fetch single value"""
        async with self.acquire() as conn:
            return await conn.fetchval(query, *args, column=column)
    
    async def transaction(self, callback: Callable):
        """Execute callback within transaction"""
        async with self.acquire() as conn:
            async with conn.transaction():
                await callback(conn)
    
    def get_stats(self) -> dict:
        """Get pool statistics"""
        if self.pool:
            return {
                "size": self.pool.get_size(),
                "available": self.pool.get_idle_size(),
                "max_size": self.pool.maxsize,
                "min_size": self.pool.minsize
            }
        return {}
    
    async def close(self):
        """Close connection pool"""
        if self.pool:
            await self.pool.close()


class ConnectionPoolManager:
    """Manage multiple connection pools"""
    
    def __init__(self):
        self.pools: dict[str, ConnectionPool] = {}
    
    async def create_pool(
        self,
        name: str,
        dsn: str,
        **kwargs
    ):
        """Create a named connection pool"""
        pool = ConnectionPool(dsn, **kwargs)
        await pool.initialize()
        self.pools[name] = pool
        return pool
    
    def get_pool(self, name: str) -> Optional[ConnectionPool]:
        """Get pool by name"""
        return self.pools.get(name)
    
    async def close_all(self):
        """Close all pools"""
        for pool in self.pools.values():
            await pool.close()
```

---

## Async Operations

### Async Batch Processing

```python
# nip/utils/async_utils.py
import asyncio
from typing import List, Callable, Any, Optional, TypeVar
from concurrent.futures import ThreadPoolExecutor
import time

T = TypeVar('T')
R = TypeVar('R')

class AsyncBatchProcessor:
    """Process items in batches asynchronously"""
    
    def __init__(
        self,
        batch_size: int = 100,
        concurrency: int = 10,
        delay_between_batches: float = 0.1
    ):
        self.batch_size = batch_size
        self.concurrency = concurrency
        self.delay_between_batches = delay_between_batches
    
    async def process_items(
        self,
        items: List[T],
        processor: Callable[[T], R],
        show_progress: bool = False
    ) -> List[R]:
        """Process items in async batches"""
        results = []
        total_batches = (len(items) - 1) // self.batch_size + 1
        
        for batch_idx in range(total_batches):
            start_idx = batch_idx * self.batch_size
            end_idx = start_idx + self.batch_size
            batch = items[start_idx:end_idx]
            
            # Process batch with semaphore
            semaphore = asyncio.Semaphore(self.concurrency)
            
            async def process_item(item: T) -> R:
                async with semaphore:
                    if asyncio.iscoroutinefunction(processor):
                        return await processor(item)
                    else:
                        return processor(item)
            
            # Process all items in batch
            batch_results = await asyncio.gather(
                *[process_item(item) for item in batch],
                return_exceptions=True
            )
            
            results.extend(batch_results)
            
            if show_progress:
                progress = (batch_idx + 1) / total_batches * 100
                print(f"Progress: {progress:.1f}%")
            
            # Small delay between batches
            if batch_idx < total_batches - 1:
                await asyncio.sleep(self.delay_between_batches)
        
        return results
    
    async def process_with_retry(
        self,
        items: List[T],
        processor: Callable[[T], R],
        max_retries: int = 3,
        backoff_factor: float = 2.0
    ) -> List[R]:
        """Process items with retry logic"""
        results = []
        
        for item in items:
            for attempt in range(max_retries):
                try:
                    if asyncio.iscoroutinefunction(processor):
                        result = await processor(item)
                    else:
                        result = processor(item)
                    
                    results.append(result)
                    break
                except Exception as e:
                    if attempt == max_retries - 1:
                        print(f"Failed after {max_retries} attempts: {e}")
                        results.append(None)
                    else:
                        delay = backoff_factor ** attempt
                        await asyncio.sleep(delay)
        
        return results


class AsyncTaskQueue:
    """Async task queue with priority and rate limiting"""
    
    def __init__(self, max_concurrent: int = 10):
        self.queue = asyncio.PriorityQueue()
        self.max_concurrent = max_concurrent
        self.semaphore = asyncio.Semaphore(max_concurrent)
        self.running = False
    
    async def add_task(self, task: Callable, priority: int = 0, *args, **kwargs):
        """Add task to queue"""
        await self.queue.put((priority, task, args, kwargs))
    
    async def worker(self):
        """Process tasks from queue"""
        while self.running:
            try:
                # Get task with timeout
                priority, task, args, kwargs = await asyncio.wait_for(
                    self.queue.get(),
                    timeout=1.0
                )
                
                async with self.semaphore:
                    try:
                        if asyncio.iscoroutinefunction(task):
                            await task(*args, **kwargs)
                        else:
                            task(*args, **kwargs)
                    except Exception as e:
                        print(f"Task error: {e}")
                    finally:
                        self.queue.task_done()
            except asyncio.TimeoutError:
                continue
    
    async def start(self, num_workers: int = 4):
        """Start worker tasks"""
        self.running = True
        self.workers = [
            asyncio.create_task(self.worker())
            for _ in range(num_workers)
        ]
    
    async def stop(self):
        """Stop all workers"""
        self.running = False
        await self.queue.join()
        
        for worker in self.workers:
            worker.cancel()
        
        await asyncio.gather(*self.workers, return_exceptions=True)
```

---

## Load Testing

### Load Testing Framework

```python
# tests/load_test.py
import asyncio
import time
import statistics
from typing import List, Dict, Any, Callable
from dataclasses import dataclass
import aiohttp
import numpy as np

@dataclass
class LoadTestResult:
    """Results from load test"""
    total_requests: int
    successful_requests: int
    failed_requests: int
    requests_per_second: float
    avg_latency_ms: float
    p50_latency_ms: float
    p95_latency_ms: float
    p99_latency_ms: float
    min_latency_ms: float
    max_latency_ms: float
    std_dev_ms: float
    error_rate: float


class LoadTester:
    """HTTP load testing framework"""
    
    def __init__(
        self,
        base_url: str,
        num_requests: int = 1000,
        concurrency: int = 10,
        timeout: float = 30.0
    ):
        self.base_url = base_url
        self.num_requests = num_requests
        self.concurrency = concurrency
        self.timeout = timeout
        
        self.session: Optional[aiohttp.ClientSession] = None
    
    async def initialize(self):
        """Initialize HTTP session"""
        timeout = aiohttp.ClientTimeout(total=self.timeout)
        connector = aiohttp.TCPConnector(
            limit=self.concurrency,
            limit_per_host=self.concurrency
        )
        self.session = aiohttp.ClientSession(
            timeout=timeout,
            connector=connector
        )
    
    async def make_request(
        self,
        method: str,
        endpoint: str,
        **kwargs
    ) -> tuple[float, bool, Optional[str]]:
        """Make HTTP request and measure latency"""
        url = f"{self.base_url}{endpoint}"
        start_time = time.perf_counter()
        
        try:
            async with self.session.request(method, url, **kwargs) as response:
                await response.read()
                latency = (time.perf_counter() - start_time) * 1000
                success = 200 <= response.status < 400
                error = None if success else f"Status: {response.status}"
                return latency, success, error
        except Exception as e:
            latency = (time.perf_counter() - start_time) * 1000
            return latency, False, str(e)
    
    async def run_test(
        self,
        method: str = "GET",
        endpoint: str = "/",
        **kwargs
    ) -> LoadTestResult:
        """Run load test"""
        await self.initialize()
        
        latencies: List[float] = []
        successful = 0
        failed = 0
        errors: List[str] = []
        
        # Semaphore for concurrency control
        semaphore = asyncio.Semaphore(self.concurrency)
        
        async def request_worker():
            async with semaphore:
                latency, success, error = await self.make_request(
                    method, endpoint, **kwargs
                )
                return latency, success, error
        
        # Execute all requests
        start_time = time.perf_counter()
        results = await asyncio.gather(
            *[request_worker() for _ in range(self.num_requests)],
            return_exceptions=True
        )
        total_time = time.perf_counter() - start_time
        
        # Process results
        for result in results:
            if isinstance(result, Exception):
                failed += 1
                errors.append(str(result))
            else:
                latency, success, error = result
                latencies.append(latency)
                
                if success:
                    successful += 1
                else:
                    failed += 1
                    if error:
                        errors.append(error)
        
        # Calculate statistics
        sorted_latencies = sorted(latencies)
        
        return LoadTestResult(
            total_requests=self.num_requests,
            successful_requests=successful,
            failed_requests=failed,
            requests_per_second=self.num_requests / total_time,
            avg_latency_ms=statistics.mean(latencies) if latencies else 0,
            p50_latency_ms=statistics.median(latencies) if latencies else 0,
            p95_latency_ms=np.percentile(latencies, 95) if latencies else 0,
            p99_latency_ms=np.percentile(latencies, 99) if latencies else 0,
            min_latency_ms=min(latencies) if latencies else 0,
            max_latency_ms=max(latencies) if latencies else 0,
            std_dev_ms=statistics.stdev(latencies) if len(latencies) > 1 else 0,
            error_rate=(failed / self.num_requests * 100) if self.num_requests > 0 else 0
        )
    
    async def close(self):
        """Close HTTP session"""
        if self.session:
            await self.session.close()
    
    def print_results(self, result: LoadTestResult):
        """Print load test results"""
        print("\n" + "="*60)
        print("LOAD TEST RESULTS")
        print("="*60)
        print(f"Total Requests:     {result.total_requests}")
        print(f"Successful:         {result.successful_requests}")
        print(f"Failed:             {result.failed_requests}")
        print(f"Requests/sec:       {result.requests_per_second:.2f}")
        print(f"Error Rate:         {result.error_rate:.2f}%")
        print("\nLatency Statistics:")
        print(f"  Average:          {result.avg_latency_ms:.2f}ms")
        print(f"  Median (P50):     {result.p50_latency_ms:.2f}ms")
        print(f"  P95:              {result.p95_latency_ms:.2f}ms")
        print(f"  P99:              {result.p99_latency_ms:.2f}ms")
        print(f"  Min:              {result.min_latency_ms:.2f}ms")
        print(f"  Max:              {result.max_latency_ms:.2f}ms")
        print(f"  Std Dev:          {result.std_dev_ms:.2f}ms")
        print("="*60 + "\n")
```

---

## Performance Benchmarks

### Benchmark Suite

```python
# tests/benchmarks.py
import time
import asyncio
from typing import Dict, List, Callable, Any
from dataclasses import dataclass, asdict
import json

@dataclass
class BenchmarkResult:
    """Result from a benchmark run"""
    name: str
    iterations: int
    total_time_ms: float
    avg_time_ms: float
    min_time_ms: float
    max_time_ms: float
    ops_per_second: float
    
    def to_dict(self):
        return asdict(self)


class BenchmarkSuite:
    """Performance benchmarking suite"""
    
    def __init__(self):
        self.results: List[BenchmarkResult] = []
    
    def benchmark(
        self,
        name: str,
        iterations: int = 1000,
        warmup_iterations: int = 100
    ) -> Callable:
        """Decorator to benchmark a function"""
        def decorator(func: Callable) -> Callable:
            def wrapper(*args, **kwargs):
                # Warmup
                for _ in range(warmup_iterations):
                    func(*args, **kwargs)
                
                # Benchmark
                times: List[float] = []
                for _ in range(iterations):
                    start = time.perf_counter()
                    func(*args, **kwargs)
                    times.append((time.perf_counter() - start) * 1000)
                
                # Calculate statistics
                total_time = sum(times)
                result = BenchmarkResult(
                    name=name,
                    iterations=iterations,
                    total_time_ms=round(total_time, 2),
                    avg_time_ms=round(total_time / iterations, 2),
                    min_time_ms=round(min(times), 2),
                    max_time_ms=round(max(times), 2),
                    ops_per_second=round(iterations / (total_time / 1000), 2)
                )
                
                self.results.append(result)
                return result
            
            return wrapper
        return decorator
    
    async def benchmark_async(
        self,
        name: str,
        iterations: int = 1000,
        warmup_iterations: int = 100
    ) -> Callable:
        """Decorator to benchmark async function"""
        def decorator(func: Callable) -> Callable:
            async def wrapper(*args, **kwargs):
                # Warmup
                for _ in range(warmup_iterations):
                    await func(*args, **kwargs)
                
                # Benchmark
                times: List[float] = []
                for _ in range(iterations):
                    start = time.perf_counter()
                    await func(*args, **kwargs)
                    times.append((time.perf_counter() - start) * 1000)
                
                # Calculate statistics
                total_time = sum(times)
                result = BenchmarkResult(
                    name=name,
                    iterations=iterations,
                    total_time_ms=round(total_time, 2),
                    avg_time_ms=round(total_time / iterations, 2),
                    min_time_ms=round(min(times), 2),
                    max_time_ms=round(max(times), 2),
                    ops_per_second=round(iterations / (total_time / 1000), 2)
                )
                
                self.results.append(result)
                return result
            
            return wrapper
        return decorator
    
    def compare(self, baseline: str, contender: str) -> Dict[str, float]:
        """Compare two benchmark results"""
        baseline_result = next((r for r in self.results if r.name == baseline), None)
        contender_result = next((r for r in self.results if r.name == contender), None)
        
        if not baseline_result or not contender_result:
            return {}
        
        baseline_time = baseline_result.avg_time_ms
        contender_time = contender_result.avg_time_ms
        
        improvement = ((baseline_time - contender_time) / baseline_time) * 100
        
        return {
            "baseline_avg_ms": baseline_time,
            "contender_avg_ms": contender_time,
            "improvement_percent": round(improvement, 2),
            "speedup": round(baseline_time / contender_time, 2)
        }
    
    def print_results(self):
        """Print all benchmark results"""
        print("\n" + "="*80)
        print("BENCHMARK RESULTS")
        print("="*80)
        
        for result in self.results:
            print(f"\n{result.name}:")
            print(f"  Iterations:       {result.iterations}")
            print(f"  Total Time:       {result.total_time_ms:.2f}ms")
            print(f"  Average Time:     {result.avg_time_ms:.4f}ms")
            print(f"  Min Time:         {result.min_time_ms:.4f}ms")
            print(f"  Max Time:         {result.max_time_ms:.4f}ms")
            print(f"  Ops/Second:       {result.ops_per_second:.2f}")
        
        print("="*80 + "\n")
    
    def save_report(self, path: str):
        """Save benchmark report to JSON"""
        report = {
            "benchmarks": [r.to_dict() for r in self.results]
        }
        
        with open(path, 'w') as f:
            json.dump(report, f, indent=2)
```

---

## Optimization Techniques

### Code Optimization Patterns

```python
# examples/optimization_patterns.py
import asyncio
from typing import List, Dict, Any
import time

# 1. Use generators for large datasets
def process_large_dataset_naive(data: List[int]) -> List[int]:
    """INNEFICIENT: Loads all results into memory"""
    results = []
    for item in data:
        processed = item * 2
        results.append(processed)
    return results

def process_large_dataset_efficient(data: List[int]):
    """EFFICIENT: Uses generator to save memory"""
    for item in data:
        yield item * 2

# 2. Use list comprehensions instead of loops
def transform_naive(items: List[str]) -> List[str]:
    """SLOWER: Uses append in loop"""
    results = []
    for item in items:
        results.append(item.upper())
    return results

def transform_efficient(items: List[str]) -> List[str]:
    """FASTER: List comprehension"""
    return [item.upper() for item in items]

# 3. Batch database operations
async def insert_items_naive(items: List[Dict]):
    """SLOW: Individual inserts"""
    for item in items:
        # Simulate database insert
        await asyncio.sleep(0.01)

async def insert_items_efficient(items: List[Dict], batch_size: int = 100):
    """FAST: Batch inserts"""
    for i in range(0, len(items), batch_size):
        batch = items[i:i + batch_size]
        # Simulate batch insert
        await asyncio.sleep(0.01)

# 4. Cache expensive computations
class NaiveCalculator:
    """INNEFICIENT: Recalculates everything"""
    def fibonacci(self, n: int) -> int:
        if n <= 1:
            return n
        return self.fibonacci(n - 1) + self.fibonacci(n - 2)

class OptimizedCalculator:
    """EFFICIENT: Uses memoization"""
    def __init__(self):
        self._cache = {}
    
    def fibonacci(self, n: int) -> int:
        if n in self._cache:
            return self._cache[n]
        
        if n <= 1:
            return n
        
        result = self.fibonacci(n - 1) + self.fibonacci(n - 2)
        self._cache[n] = result
        return result

# 5. Use appropriate data structures
def search_naive(items: List[int], target: int) -> bool:
    """SLOW: Linear search"""
    return target in items

def search_efficient(items: set, target: int) -> bool:
    """FAST: Set lookup (O(1))"""
    return target in items

# 6. Avoid unnecessary copies
def process_data_naive(data: List[List[int]]) -> List[List[int]]:
    """INNEFICIENT: Creates copies"""
    results = data.copy()
    for row in results:
        row_copy = row.copy()
        row_copy.append(42)
    return results

def process_data_efficient(data: List[List[int]]) -> List[List[int]]:
    """EFFICIENT: Modifies in place"""
    for row in data:
        row.append(42)
    return data
```

---

## Practical Exercises

### Exercise 1: Profile and Optimize a Function

**Task**: Profile the following function and optimize it:

```python
def find_duplicates(items: List[str]) -> List[str]:
    """Find duplicate items in list"""
    duplicates = []
    for i, item1 in enumerate(items):
        for j, item2 in enumerate(items):
            if i != j and item1 == item2 and item1 not in duplicates:
                duplicates.append(item1)
    return duplicates
```

**Hints**:
- Current complexity: O(n³)
- Use set for O(1) lookups
- Target: O(n) complexity

**Solution**:

```python
def find_duplicates_optimized(items: List[str]) -> List[str]:
    """Find duplicates efficiently - O(n)"""
    seen = set()
    duplicates = set()
    
    for item in items:
        if item in seen:
            duplicates.add(item)
        else:
            seen.add(item)
    
    return list(duplicates)
```

### Exercise 2: Implement Caching

**Task**: Add caching to this API endpoint:

```python
async def get_user_posts(user_id: int) -> List[Dict]:
    """Fetch user posts from database"""
    # Simulate database query
    await asyncio.sleep(0.1)
    return [{"id": i, "user_id": user_id} for i in range(10)]
```

**Requirements**:
- Use the MultiLayerCache class
- Cache for 5 minutes
- Invalidate cache when new post is created

### Exercise 3: Load Test an Endpoint

**Task**: Create a load test for your API endpoint:

**Requirements**:
- Test with 1000 requests
- Concurrency of 20
- Measure P95 and P99 latency
- Target: P99 < 100ms

**Usage**:

```python
tester = LoadTester(
    base_url="http://localhost:8000",
    num_requests=1000,
    concurrency=20
)

result = await tester.run_test(
    method="GET",
    endpoint="/api/users"
)

tester.print_results()

# Assert performance targets
assert result.p99_latency_ms < 100, "P99 latency too high!"
```

### Exercise 4: Optimize Database Query

**Task**: Optimize this query that retrieves user posts with comments:

```sql
SELECT * FROM posts WHERE user_id = 123;
-- Then for each post:
SELECT * FROM comments WHERE post_id = ?;
```

**Requirements**:
- Single query using JOIN
- Add appropriate indexes
- Verify with EXPLAIN ANALYZE

**Solution**:

```sql
-- Create indexes
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX idx_comments_post_id ON comments(post_id);

-- Optimized query
SELECT 
    p.id, p.title, p.created_at,
    c.id as comment_id, c.body, c.created_at
FROM posts p
LEFT JOIN comments c ON p.id = c.post_id
WHERE p.user_id = 123
ORDER BY p.created_at DESC;
```

---

## Best Practices

### 1. Performance Monitoring

- ✅ **Always profile before optimizing**
- ✅ **Monitor key metrics in production**
- ✅ **Set up alerts for performance degradation**
- ✅ **Track trends over time**

### 2. Caching Strategy

- ✅ **Cache frequently accessed, rarely changed data**
- ✅ **Use multi-layer caching (L1 + L2)**
- ✅ **Implement cache warming**
- ✅ **Handle cache failures gracefully**
- ✅ **Monitor cache hit rates**

### 3. Database Optimization

- ✅ **Use connection pooling**
- ✅ **Create appropriate indexes**
- ✅ **Use EXPLAIN ANALYZE**
- ✅ **Avoid N+1 queries**
- ✅ **Use batch operations**
- ✅ **Regularly run VACUUM ANALYZE**

### 4. Async Operations

- ✅ **Use async for I/O-bound operations**
- ✅ **Limit concurrency with semaphores**
- ✅ **Use connection pools**
- ✅ **Handle async context managers properly**
- ✅ **Avoid mixing sync and async code**

### 5. Load Testing

- ✅ **Test at production scale**
- ✅ **Test failure scenarios**
- ✅ **Monitor system resources**
- ✅ **Test gradual load increase**
- ✅ **Run tests regularly**

### 6. Code Optimization

- ✅ **Profile before optimizing**
- ✅ **Focus on hot paths**
- ✅ **Use appropriate data structures**
- ✅ **Avoid premature optimization**
- ✅ **Document optimizations**

### Performance Checklist

- [ ] Profiling tools configured
- [ ] Caching layer implemented
- [ ] Database indexes created
- [ ] Connection pooling configured
- [ ] Async operations optimized
- [ ] Load tests passing
- [ ] Monitoring in place
- [ ] Alerts configured
- [ ] Documentation updated

---

## Summary

This tutorial covered comprehensive performance optimization strategies for NIP v3.0.0:

**Key Takeaways**:
1. **Profile first, optimize second** - Always measure before making changes
2. **Multi-layer caching** - Combine in-memory and Redis for optimal performance
3. **Database optimization** - Indexes, query optimization, and connection pooling
4. **Async operations** - Leverage async/await for I/O-bound workloads
5. **Load testing** - Validate performance under realistic conditions
6. **Continuous monitoring** - Track metrics and trends in production

**Next Steps**:
- Complete Tutorial 10: Security Hardening
- Implement profiling in your applications
- Set up comprehensive monitoring
- Run regular load tests
- Establish performance budgets

---

**Tutorial Complete! 🎉**

You've learned advanced performance optimization techniques for production NIP applications. Continue with Tutorial 10 to learn about security hardening.
