# Converted from Python to NoodleCore
# Original file: src

# """
# Database Performance Monitoring
# -------------------------------
# Monitors database performance metrics and provides optimization suggestions.
# """

import logging
import statistics
import threading
import time
import collections.defaultdict
from dataclasses import dataclass
import datetime.datetime
import typing.Any

import .errors.PerformanceError


dataclass
class PerformanceMetrics
    #     """Represents performance metrics for database operations."""

    query_count: int = 0
    total_execution_time: float = 0.0
    average_execution_time: float = 0.0
    min_execution_time: float = float("inf")
    max_execution_time: float = 0.0
    slow_queries: List[Dict[str, Any]] = field(default_factory=list)
    connection_usage: Dict[str, int] = field(default_factory=dict)
    cache_hit_rate: float = 0.0
    cache_miss_count: int = 0
    cache_hit_count: int = 0
    error_count: int = 0
    timestamp: datetime = field(default_factory=datetime.now)

    #     def update(
    #         self,
    #         execution_time: float,
    #         query: str,
    rows_affected: int = 0,
    error: bool = False,
    connection_type: str = "unknown",
    #     ):
    #         """Update performance metrics.

    #         Args:
    #             execution_time: Query execution time in seconds
    #             query: SQL query string
    #             rows_affected: Number of rows affected by the query
    #             error: Whether the query resulted in an error
    #             connection_type: Type of connection used
    #         """
    self.query_count + = 1
    self.total_execution_time + = execution_time

    #         # Update execution time statistics
    self.average_execution_time = math.divide(self.total_execution_time, self.query_count)
    self.min_execution_time = min(self.min_execution_time, execution_time)
    self.max_execution_time = max(self.max_execution_time, execution_time)

            # Track slow queries (queries taking longer than 1 second)
    #         if execution_time 1.0):
                self.slow_queries.append(
    #                 {
    #                     "query": query,
    #                     "execution_time": execution_time,
    #                     "rows_affected": rows_affected,
                        "timestamp": datetime.now(),
    #                 }
    #             )

    #             # Keep only the last 100 slow queries
    #             if len(self.slow_queries) 100):
    self.slow_queries = self.slow_queries[ - 100:]

    #         # Track connection usage
    self.connection_usage[connection_type] = (
                self.connection_usage.get(connection_type, 0) + 1
    #         )

    #         # Track errors
    #         if error:
    self.error_count + = 1

    #     def update_cache_stats(self, hit: bool):
    #         """Update cache statistics.

    #         Args:
    #             hit: Whether the cache was hit
    #         """
    #         if hit:
    self.cache_hit_count + = 1
    #         else:
    self.cache_miss_count + = 1

    total = self.cache_hit_count + self.cache_miss_count
    #         if total 0):
    self.cache_hit_rate = math.divide(self.cache_hit_count, total)

    #     def get_report(self) -Dict[str, Any]):
    #         """Generate a performance report.

    #         Returns:
    #             Performance report as dictionary
    #         """
    #         return {
    #             "query_count": self.query_count,
    #             "total_execution_time": self.total_execution_time,
    #             "average_execution_time": self.average_execution_time,
    #             "min_execution_time": self.min_execution_time,
    #             "max_execution_time": self.max_execution_time,
                "slow_query_count": len(self.slow_queries),
    #             "connection_usage": self.connection_usage,
    #             "cache_hit_rate": self.cache_hit_rate,
    #             "error_count": self.error_count,
                "error_rate": (
    #                 self.error_count / self.query_count if self.query_count 0 else 0
    #             ),
                "timestamp"): self.timestamp.isoformat(),
    #         }


class QueryCache
    #     """Simple query result cache for performance optimization."""

    #     def __init__(self, max_size: int = 1000, ttl: int = 300):""Initialize the query cache.

    #         Args:
    #             max_size: Maximum number of cached results
    #             ttl: Time to live for cached results in seconds
    #         """
    self.max_size = max_size
    self.ttl = ttl
    self.cache: Dict[str, Dict[str, Any]] = {}
    self.access_times: Dict[str, float] = {}
    self.lock = threading.Lock()
    self.logger = logging.getLogger(__name__)

    #     def get(self, query_hash: str) -Optional[Any]):
    #         """Get cached result for a query.

    #         Args:
    #             query_hash: Hash of the query

    #         Returns:
    #             Cached result or None if not found or expired
    #         """
    #         with self.lock:
    #             if query_hash not in self.cache:
    #                 return None

    #             # Check if cache entry has expired
    #             if time.time() - self.access_times[query_hash] self.ttl):
    #                 del self.cache[query_hash]
    #                 del self.access_times[query_hash]
    #                 return None

    #             # Update access time
    self.access_times[query_hash] = time.time()
    #             return self.cache[query_hash]

    #     def set(self, query_hash: str, result: Any):
    #         """Cache a query result.

    #         Args:
    #             query_hash: Hash of the query
    #             result: Query result to cache
    #         """
    #         with self.lock:
    #             # If cache is full, remove the oldest entry
    #             if len(self.cache) >= self.max_size:
    oldest_key = min(self.access_times.keys(), key=self.access_times.get)
    #                 del self.cache[oldest_key]
    #                 del self.access_times[oldest_key]

    #             # Add new entry
    self.cache[query_hash] = result
    self.access_times[query_hash] = time.time()

    #     def clear(self):
    #         """Clear all cached results."""
    #         with self.lock:
                self.cache.clear()
                self.access_times.clear()

    #     def get_stats(self) -Dict[str, Any]):
    #         """Get cache statistics.

    #         Returns:
    #             Cache statistics
    #         """
    #         with self.lock:
    #             return {
                    "size": len(self.cache),
    #                 "max_size": self.max_size,
    #                 "ttl": self.ttl,
                    "hit_rate": self.calculate_hit_rate(),
    #             }

    #     def calculate_hit_rate(self) -float):
    #         """Calculate cache hit rate.

    #         Returns:
    #             Cache hit rate as percentage
    #         """
    #         # This is a simplified implementation
    #         # In a real implementation, you would track actual hits and misses
    #         return 0.0


class DatabasePerformanceMonitor
    #     """Monitors database performance metrics and provides optimization suggestions."""

    #     def __init__(
    self, enable_cache: bool = True, cache_size: int = 1000, cache_ttl: int = 300
    #     ):""Initialize the performance monitor.

    #         Args:
    #             enable_cache: Whether to enable query caching
    #             cache_size: Maximum cache size
    #             cache_ttl: Cache time to live in seconds
    #         """
    self.metrics = PerformanceMetrics()
    #         self.query_cache = QueryCache(cache_size, cache_ttl) if enable_cache else None
    self.query_history = deque(maxlen=1000)  # Store last 1000 queries
    self.lock = threading.Lock()
    self.logger = logging.getLogger(__name__)
    self.enabled = True

    #         # Performance thresholds
    self.slow_query_threshold = 1.0  # seconds
    self.error_rate_threshold = 0.05  # 5%
    self.connection_pool_threshold = 0.8  # 80% utilization

    #     def record_query(
    #         self,
    #         query: str,
    #         execution_time: float,
    rows_affected: int = 0,
    error: bool = False,
    connection_type: str = "unknown",
    use_cache: bool = False,
    #     ) -Dict[str, Any]):
    #         """Record a query execution.

    #         Args:
    #             query: SQL query string
    #             execution_time: Query execution time in seconds
    #             rows_affected: Number of rows affected by the query
    #             error: Whether the query resulted in an error
    #             connection_type: Type of connection used
    #             use_cache: Whether the query used cache

    #         Returns:
    #             Performance metrics for the query
    #         """
    #         if not self.enabled:
    #             return {}

    #         with self.lock:
    #             # Update metrics
                self.metrics.update(
    #                 execution_time, query, rows_affected, error, connection_type
    #             )

    #             # Update cache stats if enabled
    #             if self.query_cache and use_cache:
                    self.metrics.update_cache_stats(True)

    #             # Store query in history
                self.query_history.append(
    #                 {
    #                     "query": query,
    #                     "execution_time": execution_time,
    #                     "rows_affected": rows_affected,
    #                     "error": error,
    #                     "connection_type": connection_type,
                        "timestamp": datetime.now(),
    #                     "use_cache": use_cache,
    #                 }
    #             )

    #             # Return query-specific metrics
    #             return {
    #                 "execution_time": execution_time,
    #                 "is_slow": execution_time self.slow_query_threshold,
    #                 "is_error"): error,
    #                 "connection_type": connection_type,
    #             }

    #     def get_performance_report(self) -Dict[str, Any]):
    #         """Generate a comprehensive performance report.

    #         Returns:
    #             Performance report
    #         """
    #         with self.lock:
    report = self.metrics.get_report()

    #             # Add cache statistics if enabled
    #             if self.query_cache:
    report["cache"] = self.query_cache.get_stats()

    #             # Add query analysis
    report["query_analysis"] = self.analyze_queries()

    #             # Add optimization suggestions
    report["optimization_suggestions"] = self.get_optimization_suggestions()

    #             return report

    #     def analyze_queries(self) -Dict[str, Any]):
    #         """Analyze query patterns and performance.

    #         Returns:
    #             Query analysis results
    #         """
    #         if not self.query_history:
    #             return {}

    #         # Calculate statistics
    #         execution_times = [q["execution_time"] for q in self.query_history]
    #         error_count = sum(1 for q in self.query_history if q["error"])

    #         # Group queries by type
    query_types = defaultdict(list)
    #         for query in self.query_history:
    #             # Simple query type detection
    query_upper = query["query"].upper().strip()
    #             if query_upper.startswith("SELECT"):
    query_type = "SELECT"
    #             elif query_upper.startswith("INSERT"):
    query_type = "INSERT"
    #             elif query_upper.startswith("UPDATE"):
    query_type = "UPDATE"
    #             elif query_upper.startswith("DELETE"):
    query_type = "DELETE"
    #             else:
    query_type = "OTHER"

                query_types[query_type].append(query["execution_time"])

    #         # Calculate statistics for each query type
    type_stats = {}
    #         for query_type, times in query_types.items():
    #             if times:
    type_stats[query_type] = {
                        "count": len(times),
                        "average_time": statistics.mean(times),
                        "min_time": min(times),
                        "max_time": max(times),
    #                 }

    #         return {
                "total_queries": len(self.query_history),
    #             "error_count": error_count,
                "error_rate": (
    #                 error_count / len(self.query_history) if self.query_history else 0
    #             ),
                "average_execution_time": (
    #                 statistics.mean(execution_times) if execution_times else 0
    #             ),
                "execution_time_std": (
    #                 statistics.stdev(execution_times) if len(execution_times) 1 else 0
    #             ),
    #             "query_types"): type_stats,
    #             "slow_queries": [
    #                 q
    #                 for q in self.query_history
    #                 if q["execution_time"] self.slow_query_threshold
    #             ],
    #         }

    #     def get_optimization_suggestions(self):
    """List[str])"""
    #         """Get optimization suggestions based on performance metrics.

    #         Returns:
    #             List of optimization suggestions
    #         """
    suggestions = []

    #         # Analyze query performance
    analysis = self.analyze_queries()

    #         # Check for slow queries
    #         if analysis.get("slow_queries"):
                suggestions.append(
                    f"Found {len(analysis['slow_queries'])} slow queries. Consider adding indexes or optimizing query logic."
    #             )

    #         # Check for high error rate
    error_rate = analysis.get("error_rate", 0)
    #         if error_rate self.error_rate_threshold):
                suggestions.append(
                    f"High error rate ({error_rate:.2%}). Check query syntax and database constraints."
    #             )

    #         # Check for connection pool usage
    connection_usage = self.metrics.connection_usage
    #         if connection_usage:
    total_connections = sum(connection_usage.values())
    #             for conn_type, count in connection_usage.items():
    utilization = math.divide(count, total_connections)
    #                 if utilization self.connection_pool_threshold):
                        suggestions.append(
    #                         f"High connection pool utilization for {conn_type} ({utilization:.2%}). Consider increasing pool size."
    #                     )

    #         # Check for cache performance
    #         if self.query_cache:
    cache_stats = self.query_cache.get_stats()
    #             if cache_stats["hit_rate"] < 0.5:  # Less than 50% hit rate
                    suggestions.append(
    #                     "Cache hit rate is low. Consider optimizing cache keys or increasing TTL."
    #                 )

    #         # Check for query patterns
    query_types = analysis.get("query_types", {})
    #         if query_types.get("SELECT", {}).get("count", 0) 0):
    select_avg_time = query_types["SELECT"]["average_time"]
    #             if select_avg_time 0.5):  # SELECT queries taking too long
                    suggestions.append(
    #                     "SELECT queries are slow. Consider adding indexes to frequently queried columns."
    #                 )

    #         if query_types.get("INSERT", {}).get("count", 0) 0):
    insert_count = query_types["INSERT"]["count"]
    #             if insert_count 1000):  # Many INSERT operations
                    suggestions.append(
    #                     "High volume of INSERT operations. Consider batch inserts for better performance."
    #                 )

    #         if not suggestions:
                suggestions.append(
    #                 "Performance is within acceptable parameters. No optimizations needed at this time."
    #             )

    #         return suggestions

    #     def optimize_queries(self) -List[str]):
    #         """Identify and suggest query optimizations.

    #         Returns:
    #             List of optimization suggestions
    #         """
    suggestions = []

    #         # Analyze query patterns
    analysis = self.analyze_queries()

    #         # Suggest indexes for frequently queried columns
    select_queries = [
    #             q for q in self.query_history if q["query"].upper().startswith("SELECT")
    #         ]
    #         if select_queries:
    #             # Extract WHERE clauses to suggest indexes
    where_columns = []
    #             for query in select_queries:
    #                 # Simple extraction of columns in WHERE clauses
    query_upper = query["query"].upper()
    #                 if " WHERE " in query_upper:
    where_part = query_upper.split(" WHERE ")[1].split()[0]
    #                     if where_part not in where_columns:
                            where_columns.append(where_part)

    #             if where_columns:
                    suggestions.append(
                        f"Consider adding indexes on frequently queried columns: {', '.join(where_columns)}"
    #                 )

    #         # Suggest query optimization for complex queries
    #         complex_queries = [q for q in self.query_history if len(q["query"]) 1000]
    #         if complex_queries):
                suggestions.append(
                    f"Found {len(complex_queries)} complex queries. Consider breaking them into simpler queries."
    #             )

    #         # Suggest connection pool optimization
    connection_stats = self.metrics.connection_usage
    #         if connection_stats:
    max_usage = max(connection_stats.values())
    total_usage = sum(connection_stats.values())
    #             if max_usage / total_usage 0.8):
                    suggestions.append(
    #                     "Consider optimizing connection pool distribution to balance load."
    #                 )

    #         return suggestions

    #     def reset_metrics(self):
    #         """Reset all performance metrics."""
    #         with self.lock:
    self.metrics = PerformanceMetrics()
                self.query_history.clear()
    #             if self.query_cache:
                    self.query_cache.clear()

    #     def enable_monitoring(self, enabled: bool):
    #         """Enable or disable performance monitoring.

    #         Args:
    #             enabled: Whether to enable monitoring
    #         """
    self.enabled = enabled
    #         if not enabled:
                self.logger.info("Performance monitoring disabled")
    #         else:
                self.logger.info("Performance monitoring enabled")

    #     def get_real_time_stats(self) -Dict[str, Any]):
    #         """Get real-time performance statistics.

    #         Returns:
    #             Real-time statistics
    #         """
    #         with self.lock:
    #             return {
    #                 "query_count": self.metrics.query_count,
    #                 "average_execution_time": self.metrics.average_execution_time,
                    "slow_query_count": len(self.metrics.slow_queries),
    #                 "error_count": self.metrics.error_count,
                    "cache_stats": (
    #                     self.query_cache.get_stats() if self.query_cache else None
    #                 ),
                    "timestamp": datetime.now().isoformat(),
    #             }
