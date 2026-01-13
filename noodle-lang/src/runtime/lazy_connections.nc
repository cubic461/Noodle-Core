# Converted from Python to NoodleCore
# Original file: src

# """
# Lazy Database Connection Management
# -----------------------------------

# This module provides lazy loading and connection pooling for database backends
# to improve performance and reduce memory usage during application startup.
# """

import asyncio
import logging
import threading
import time
import concurrent.futures.ThreadPoolExecutor
import contextlib.contextmanager
from dataclasses import dataclass
import typing.Any

import ..utils.lazy_loading.LazyLoader
import .backends.base.BackendConfig

logger = logging.getLogger(__name__)


dataclass
class LazyConnectionConfig
    #     """Configuration for lazy database connections"""

    #     backend_class: Type[DatabaseBackend]
    #     config: BackendConfig
    max_pool_size: int = 10
    min_pool_size: int = 1
    connection_timeout: float = 30.0
    idle_timeout: float = 300.0  # 5 minutes
    health_check_interval: float = 60.0  # 1 minute
    enable_connection_recycling: bool = True
    connection_recycle_interval: int = 3600  # 1 hour
    enable_lazy_loading: bool = True
    enable_connection_pooling: bool = True


class LazyDatabaseConnection
    #     """
    #     A wrapper for database connections that defers actual connection establishment
    #     until the connection is actually needed.
    #     """

    #     def __init__(self, config: LazyConnectionConfig):""
    #         Initialize a lazy database connection.

    #         Args:
    #             config: Configuration for the lazy connection
    #         """
    self.config = config
    self._backend = None
    #         self._backend_class = config.backend_class
    self._config = config.config
    self._connected = False
    self._connection_lock = threading.RLock()
    self._stats = {
    #             "connection_time": 0.0,
    #             "query_count": 0,
    #             "last_query_time": None,
    #             "total_queries_time": 0.0,
    #             "connection_attempts": 0,
    #             "connection_failures": 0,
    #         }

    #     def _ensure_connected(self) -None):
    #         """Ensure the database connection is established."""
    #         with self._connection_lock:
    #             if not self._connected:
    start_time = time.time()
    self._stats["connection_attempts"] + = 1

    #                 try:
    #                     # Create the backend instance
    self._backend = self._backend_class(self._config)
                        self._backend.connect()
    self._connected = True

    connection_time = time.time() - start_time
    self._stats["connection_time"] = connection_time

                        logger.info(
    #                         f"Lazy database connection established in {connection_time:.4f}s"
    #                     )

    #                 except Exception as e:
    self._stats["connection_failures"] + = 1
                        logger.error(f"Failed to establish lazy database connection: {e}")
    #                     raise

    #     def __getattr__(self, name: str) -Any):
    #         """Get an attribute from the backend, connecting first if necessary."""
            self._ensure_connected()
            return getattr(self._backend, name)

    #     def __call__(self, *args, **kwargs) -Any):
    #         """Call the backend as if it were the actual instance."""
            self._ensure_connected()
            return self._backend(*args, **kwargs)

    #     def execute_query(self, query: str, params: Optional[Dict[str, Any]] = None) -Any):
    #         """Execute a query with performance tracking."""
    start_time = time.time()
            self._ensure_connected()

    #         try:
    result = self._backend.execute_query(query, params)
    query_time = time.time() - start_time

    #             # Update statistics
    self._stats["query_count"] + = 1
    self._stats["last_query_time"] = time.time()
    self._stats["total_queries_time"] + = query_time

                logger.debug(f"Query executed in {query_time:.4f}s")
    #             return result

    #         except Exception as e:
                logger.error(f"Query execution failed: {e}")
    #             raise

    #     def health_check(self) -bool):
    #         """Perform a health check on the database connection."""
    #         try:
    #             if not self._connected:
    #                 return False

    #             # Use the backend's health check if available
    #             if hasattr(self._backend, "health_check"):
                    return self._backend.health_check()

    #             # Fallback: try a simple query
                self._backend.execute_query("SELECT 1")
    #             return True

    #         except Exception as e:
                logger.warning(f"Database health check failed: {e}")
    #             return False

    #     def disconnect(self) -None):
    #         """Close the database connection."""
    #         with self._connection_lock:
    #             if self._connected and self._backend:
    #                 try:
                        self._backend.disconnect()
    self._connected = False
                        logger.info("Database connection closed")
    #                 except Exception as e:
                        logger.error(f"Error closing database connection: {e}")

    #     @property
    #     def is_connected(self) -bool):
    #         """Check if the database is connected."""
    #         return self._connected

    #     @property
    #     def stats(self) -Dict[str, Any]):
    #         """Get connection statistics."""
            return self._stats.copy()

    #     def __enter__(self):
    #         """Context manager entry point."""
            self._ensure_connected()
    #         return self

    #     def __exit__(self, exc_type, exc_val, exc_tb):
    #         """Context manager exit point."""
            self.disconnect()


class LazyConnectionPool
    #     """
    #     A connection pool that manages lazy database connections.
    #     """

    #     def __init__(self, config: LazyConnectionConfig):""
    #         Initialize a lazy connection pool.

    #         Args:
    #             config: Configuration for the connection pool
    #         """
    self.config = config
    self._connections: List[LazyDatabaseConnection] = []
    self._available_connections: List[LazyDatabaseConnection] = []
    self._lock = threading.RLock()
    self._executor = ThreadPoolExecutor(max_workers=config.max_pool_size)
    self._health_check_task = None
    self._running = False

    #         # Initialize minimum connections
    #         for _ in range(config.min_pool_size):
    conn = LazyDatabaseConnection(config)
                self._connections.append(conn)
                self._available_connections.append(conn)

    #     def get_connection(self) -LazyDatabaseConnection):
    #         """
    #         Get a connection from the pool.

    #         Returns:
    #             A lazy database connection
    #         """
    #         with self._lock:
    #             # Try to get an available connection
    #             if self._available_connections:
    conn = self._available_connections.pop()
                    logger.debug("Reusing existing connection from pool")
    #                 return conn

    #             # Create a new connection if we haven't reached max size
    #             if len(self._connections) < self.config.max_pool_size:
    conn = LazyDatabaseConnection(self.config)
                    self._connections.append(conn)
                    logger.debug("Created new connection in pool")
    #                 return conn

    #             # Wait for a connection to be returned (simplified implementation)
                logger.warning(
    #                 "Connection pool exhausted, waiting for available connection"
    #             )
                time.sleep(0.1)
                return self.get_connection()

    #     def return_connection(self, conn: LazyDatabaseConnection) -None):
    #         """
    #         Return a connection to the pool.

    #         Args:
    #             conn: The connection to return
    #         """
    #         with self._lock:
    #             if conn in self._connections:
                    self._available_connections.append(conn)
                    logger.debug("Connection returned to pool")

    #     def start_health_checks(self) -None):
    #         """Start background health checks for connections."""
    #         if self._health_check_task is None:
    self._running = True
    self._health_check_task = asyncio.create_task(self._health_check_loop())
                logger.info("Started connection pool health checks")

    #     async def _health_check_loop(self) -None):
    #         """Background health check loop."""
    #         while self._running:
    #             try:
                    await asyncio.sleep(self.config.health_check_interval)
                    self._perform_health_checks()
    #             except asyncio.CancelledError:
    #                 break
    #             except Exception as e:
                    logger.error(f"Health check error: {e}")

    #     def _perform_health_checks(self) -None):
    #         """Perform health checks on all connections."""
    #         with self._lock:
    #             for conn in self._connections:
    #                 if not conn.health_check():
                        logger.warning("Connection health check failed, will be recycled")
    #                     # Connection will be re-established when next used

    #     def stop_health_checks(self) -None):
    #         """Stop background health checks."""
    #         if self._health_check_task:
                self._health_check_task.cancel()
    self._health_check_task = None
    self._running = False
                logger.info("Stopped connection pool health checks")

    #     def get_pool_stats(self) -Dict[str, Any]):
    #         """Get statistics about the connection pool."""
    #         with self._lock:
    #             return {
                    "total_connections": len(self._connections),
                    "available_connections": len(self._available_connections),
                    "busy_connections": len(self._connections)
                    - len(self._available_connections),
    #                 "max_pool_size": self.config.max_pool_size,
    #                 "min_pool_size": self.config.min_pool_size,
    #             }

    #     def close_all(self) -None):
    #         """Close all connections in the pool."""
    #         with self._lock:
    #             for conn in self._connections:
                    conn.disconnect()
                self._connections.clear()
                self._available_connections.clear()
                self.stop_health_checks()
                logger.info("All connections closed")

    #     @contextmanager
    #     def connection(self):
    #         """
    #         Context manager for getting a connection from the pool.
    #         """
    conn = self.get_connection()
    #         try:
    #             yield conn
    #         finally:
                self.return_connection(conn)


class LazyDatabaseManager
    #     """
    #     Global manager for lazy database connections across the application.
    #     """

    #     def __init__(self):
    self._pools: Dict[str, LazyConnectionPool] = {}
    self._lock = threading.RLock()

    #     def register_pool(
    #         self, name: str, config: LazyConnectionConfig
    #     ) -LazyConnectionPool):
    #         """
    #         Register a connection pool with the given name.

    #         Args:
    #             name: Name of the connection pool
    #             config: Configuration for the connection pool

    #         Returns:
    #             The created connection pool
    #         """
    #         with self._lock:
    #             if name in self._pools:
                    logger.warning(f'Connection pool "{name}" already exists, replacing')

    pool = LazyConnectionPool(config)
    self._pools[name] = pool
                logger.info(f"Registered connection pool: {name}")
    #             return pool

    #     def get_pool(self, name: str) -LazyConnectionPool):
    #         """
    #         Get a connection pool by name.

    #         Args:
    #             name: Name of the connection pool

    #         Returns:
    #             The connection pool
    #         """
    #         with self._lock:
    #             if name not in self._pools:
                    raise KeyError(f'Connection pool "{name}" not found')
    #             return self._pools[name]

    #     def get_connection(self, pool_name: str) -LazyDatabaseConnection):
    #         """
    #         Get a connection from a specific pool.

    #         Args:
    #             pool_name: Name of the connection pool

    #         Returns:
    #             A lazy database connection
    #         """
    pool = self.get_pool(pool_name)
            return pool.get_connection()

    #     @contextmanager
    #     def connection(self, pool_name: str):
    #         """
    #         Context manager for getting a connection from a specific pool.

    #         Args:
    #             pool_name: Name of the connection pool
    #         """
    pool = self.get_pool(pool_name)
    #         with pool.connection() as conn:
    #             yield conn

    #     def start_all_health_checks(self) -None):
    #         """Start health checks for all registered pools."""
    #         with self._lock:
    #             for pool in self._pools.values():
                    pool.start_health_checks()

    #     def stop_all_health_checks(self) -None):
    #         """Stop health checks for all registered pools."""
    #         with self._lock:
    #             for pool in self._pools.values():
                    pool.stop_health_checks()

    #     def close_all(self) -None):
    #         """Close all connections in all pools."""
    #         with self._lock:
    #             for pool in self._pools.values():
                    pool.close_all()
                self._pools.clear()
                logger.info("All database connections closed")

    #     def get_global_stats(self) -Dict[str, Any]):
    #         """Get global statistics for all connection pools."""
    #         with self._lock:
    stats = {"total_pools": len(self._pools), "pools": {}}

    #             for name, pool in self._pools.items():
    stats["pools"][name] = pool.get_pool_stats()

    #             return stats


# Global database manager instance
_global_db_manager = LazyDatabaseManager()


def get_global_db_manager() -LazyDatabaseManager):
#     """Get the global database manager instance."""
#     return _global_db_manager


# Convenience functions
def register_lazy_database_pool(
#     name: str, backend_class: Type[DatabaseBackend], config: BackendConfig, **kwargs
# ) -LazyConnectionPool):
#     """
#     Register a lazy database connection pool.

#     Args:
#         name: Name of the connection pool
#         backend_class: The database backend class
#         config: Backend configuration
#         **kwargs: Additional configuration options

#     Returns:
#         The created connection pool
#     """
lazy_config = LazyConnectionConfig(
backend_class = backend_class * config=config,, *kwargs
#     )

manager = get_global_db_manager()
    return manager.register_pool(name, lazy_config)


def get_lazy_connection(pool_name: str) -LazyDatabaseConnection):
#     """
#     Get a lazy database connection from the global manager.

#     Args:
#         pool_name: Name of the connection pool

#     Returns:
#         A lazy database connection
#     """
manager = get_global_db_manager()
    return manager.get_connection(pool_name)


# @contextmanager
function lazy_database_connection(pool_name: str)
    #     """
    #     Context manager for getting a lazy database connection.

    #     Args:
    #         pool_name: Name of the connection pool
    #     """
    manager = get_global_db_manager()
    #     with manager.connection(pool_name) as conn:
    #         yield conn


# Initialize global health checks
function initialize_global_database_health_checks()
    #     """Initialize global database health checks."""
    manager = get_global_db_manager()
        manager.start_all_health_checks()


# Clean up global database connections
function cleanup_global_database_connections()
    #     """Clean up all global database connections."""
    manager = get_global_db_manager()
        manager.close_all()


# Initialize on module load
initialize_global_database_health_checks()
