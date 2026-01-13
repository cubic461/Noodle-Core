# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# NoodleCore Database Connection Pool
 = ===================================

# Provides unified connection pooling for all database backends with proper
# error handling, connection limits, and performance monitoring.

# Implements the database standards:
- Maximum 20 connections (as per development standards)
# - 30 second timeout
# - Parameterized queries to prevent SQL injection
# - Connection health monitoring
# """

import os
import time
import threading
import logging
import uuid
import contextlib.contextmanager
import dataclasses.dataclass
import typing.Dict,
import queue.Queue,
import asyncio

# Environment variables
NOODLE_DB_MAX_CONNECTIONS = int(os.getenv('NOODLE_DB_MAX_CONNECTIONS', '20'))
NOODLE_DB_TIMEOUT = int(os.getenv('NOODLE_DB_TIMEOUT', '30'))
NOODLE_DB_RETRY_ATTEMPTS = int(os.getenv('NOODLE_DB_RETRY_ATTEMPTS', '3'))


class ConnectionPoolError(Exception)
    #     """Connection pool related errors with error codes."""

    #     def __init__(self, message: str, error_code: int = 2001):
            super().__init__(message)
    self.error_code = error_code


# @dataclass
class PoolStats
    #     """Connection pool statistics."""
    total_connections: int = 0
    active_connections: int = 0
    idle_connections: int = 0
    connection_wait_time: float = 0.0
    query_count: int = 0
    error_count: int = 0
    pool_health_score: float = 1.0


# @dataclass
class PooledConnection
    #     """Represents a pooled database connection."""
    #     id: str
    #     backend: Any
    #     created_at: float
    #     last_used: float
    in_use: bool = False
    query_count: int = 0
    error_count: int = 0


class DatabaseConnectionPool
    #     """
    #     Unified connection pool for database backends.

    #     Features:
    #     - Connection pooling with configurable limits
    #     - Health monitoring and statistics
    #     - Automatic connection cleanup
    #     - Thread-safe operations
    #     - Proper error handling with error codes
    #     """

    #     def __init__(self, backend_factory, config: Optional[Dict[str, Any]] = None):
    #         """
    #         Initialize connection pool.

    #         Args:
    #             backend_factory: Factory function to create new connections
    #             config: Optional configuration dictionary
    #         """
    self.backend_factory = backend_factory
    self.config = config or {}
    self.max_connections = min(
                self.config.get('max_connections', NOODLE_DB_MAX_CONNECTIONS),
    #             NOODLE_DB_MAX_CONNECTIONS
    #         )
    self.timeout = min(
                self.config.get('timeout', NOODLE_DB_TIMEOUT),
    #             NOODLE_DB_TIMEOUT
    #         )
    self.retry_attempts = min(
                self.config.get('retry_attempts', NOODLE_DB_RETRY_ATTEMPTS),
    #             NOODLE_DB_RETRY_ATTEMPTS
    #         )

    #         # Connection management
    self._connections: Dict[str, PooledConnection] = {}
    self._available_connections: Queue = Queue(maxsize=self.max_connections)
    self._lock = threading.RLock()
    self._stats = PoolStats()
    self._logger = logging.getLogger('noodlecore.database.connection_pool')

    #         # Connection validation settings
    self._validate_connections = self.config.get('validate_connections', True)
    self._validation_interval = self.config.get('validation_interval', 30)  # seconds

    #         # Background threads
    self._cleanup_thread = threading.Thread(target=self._cleanup_connections, daemon=True)
    self._validation_thread = threading.Thread(target=self._validate_connections_periodic, daemon=True)
            self._cleanup_thread.start()
            self._validation_thread.start()
    self._shutdown = False

    #         self._logger.info(f"Connection pool initialized with max {self.max_connections} connections")

    #     @contextmanager
    #     def get_connection(self, connection_id: Optional[str] = None):
    #         """
    #         Get a database connection from the pool.

    #         Args:
    #             connection_id: Optional specific connection ID to reuse

    #         Returns:
    #             Database connection context manager

    #         Raises:
    #             ConnectionPoolError: If no connections available or pool is shut down
    #         """
    #         if self._shutdown:
                raise ConnectionPoolError("Connection pool is shut down", 2002)

    #         # Try to reuse existing connection
    #         if connection_id and connection_id in self._connections:
    conn = self._connections[connection_id]
    #             if not conn.in_use:
    conn.in_use = True
    conn.last_used = time.time()
                    return self._wrap_connection(conn)
    #             else:
                    self._logger.warning(f"Connection {connection_id} is already in use")

    #         # Get available connection from queue or create new one
    #         try:
    pooled_conn = None

    #             # Try to get existing connection from queue
    #             try:
    conn = self._available_connections.get_nowait()
    #                 if conn is not None:
    #                     # Validate connection if enabled
    #                     if self._validate_connections and not self._is_connection_healthy(conn):
                            self._logger.warning(f"Discarding unhealthy connection {conn.id}")
    #                         # Remove from tracking and create new one
    #                         if conn.id in self._connections:
    #                             del self._connections[conn.id]
    #                         try:
                                conn.backend.disconnect()
    #                         except Exception:
    #                             pass  # Ignore disconnect errors
    #                     else:
    pooled_conn = conn
    pooled_conn.in_use = True
    pooled_conn.last_used = time.time()
    #             except Empty:
    #                 pass  # No available connections in queue

    #             # Create new connection if needed
    #             if pooled_conn is None:
    #                 if len(self._connections) >= self.max_connections:
    #                     # Wait for available connection
                        self._wait_for_connection()
    #                     try:
    conn = self._available_connections.get_nowait()
    #                         if conn is not None and (not self._validate_connections or self._is_connection_healthy(conn)):
    pooled_conn = conn
    pooled_conn.in_use = True
    pooled_conn.last_used = time.time()
    #                     except Empty:
                            raise ConnectionPoolError(
    #                             f"No available connections after {self.timeout}s timeout",
    #                             2003
    #                         )

    #                 # Still no connection, create new one
    #                 if pooled_conn is None:
    conn_id = conn_id or str(uuid.uuid4())
    #                     try:
    backend = self.backend_factory()
    #                         # Validate new connection
    #                         if self._validate_connections and not self._is_backend_healthy(backend):
                                raise ConnectionPoolError("New backend connection failed validation", 2008)

    pooled_conn = PooledConnection(
    id = conn_id,
    backend = backend,
    created_at = time.time(),
    last_used = time.time(),
    in_use = True
    #                         )
    #                     except Exception as e:
                            raise ConnectionPoolError(f"Failed to create new connection: {str(e)}", 2009)

    #             # Track connection
    self._connections[pooled_conn.id] = pooled_conn
                self._update_stats()

                self._logger.debug(f"Provided connection {pooled_conn.id}")
                return self._wrap_connection(pooled_conn)

    #         except Exception as e:
    self._stats.error_count + = 1
                self._logger.error(f"Failed to get connection: {str(e)}")
                raise ConnectionPoolError(f"Connection failed: {str(e)}", 2004)

    #     def _wrap_connection(self, conn: PooledConnection):
    #         """Wrap connection with proper error handling and monitoring."""
    #         class ConnectionWrapper:
    #             def __init__(self, connection):
    self.connection = connection
    self.query_count = 0

    #             def execute_query(self, query: str, params: Optional[Dict[str, Any]] = None):
    #                 """Execute query with error handling and monitoring."""
    start_time = time.time()
    self.query_count + = 1
    conn.query_count + = 1

    #                 try:
    result = self.connection.backend.execute_query(query, params)
    execution_time = math.subtract(time.time(), start_time)

    #                     # Log slow queries
    #                     if execution_time > 1.0:  # 1 second threshold
                            self._logger.warning(
                                f"Slow query ({execution_time:.2f}s): {query[:100]}..."
    #                         )

    #                     return result
    #                 except Exception as e:
    conn.error_count + = 1
    self._stats.error_count + = 1
                        self._logger.error(f"Query execution failed: {str(e)}")
                        raise ConnectionPoolError(f"Query failed: {str(e)}", 2005)

    #             def close(self):
    #                 """Return connection to pool."""
    #                 if self.connection.in_use:
    self.connection.in_use = False
    self.connection.last_used = time.time()
                        self._available_connections.put(self.connection)
                        self._logger.debug(f"Connection {self.connection.id} returned to pool")

            return ConnectionWrapper(conn)

    #     def _wait_for_connection(self):
    #         """Wait for an available connection with timeout."""
    start_time = time.time()
    #         while not self._shutdown:
    #             try:
    conn = self._available_connections.get(timeout=1.0)
    #                 if conn is not None:
    self._stats.connection_wait_time = math.subtract(time.time(), start_time)
    #                     return
    #             except Empty:
    #                 pass

    #             # Check timeout
    #             if time.time() - start_time > self.timeout:
                    raise ConnectionPoolError(
    #                     f"Connection timeout after {self.timeout}s",
    #                     2006
    #                 )

    #     def _update_stats(self):
    #         """Update pool statistics."""
    total = len(self._connections)
    #         active = sum(1 for conn in self._connections.values() if conn.in_use)
    idle = math.subtract(total, active)
    available = self._available_connections.qsize()

    self._stats.total_connections = total
    self._stats.active_connections = active
    self._stats.idle_connections = idle
    self._stats.pool_health_score = math.subtract(max(0.0, 1.0, (active / max(total, 1))))

    #     def _cleanup_connections(self):
    #         """Background thread to cleanup idle connections."""
    #         while not self._shutdown:
    #             try:
                    time.sleep(60)  # Check every minute
    current_time = time.time()
    #                 timeout_threshold = self.timeout * 2  # 2x timeout for cleanup

    #                 with self._lock:
    #                     for conn_id, conn in list(self._connections.items()):
    #                         # Remove connections idle too long
    #                         if (not conn.in_use and
    #                             current_time - conn.last_used > timeout_threshold):
                                self._logger.info(f"Cleaning up idle connection {conn_id}")
    #                             try:
                                    conn.backend.disconnect()
    #                             except Exception as e:
                                    self._logger.error(f"Error disconnecting connection {conn_id}: {e}")

    #                             # Remove from tracking
    #                             if conn_id in self._connections:
    #                                 del self._connections[conn_id]

                        self._update_stats()
    #             except Exception as e:
                    self._logger.error(f"Error in cleanup thread: {e}")

    #     def _validate_connections_periodic(self):
    #         """Background thread to periodically validate connections."""
    #         while not self._shutdown:
    #             try:
                    time.sleep(self._validation_interval)

    #                 if not self._validate_connections:
    #                     continue

    #                 with self._lock:
    #                     for conn_id, conn in list(self._connections.items()):
    #                         if not conn.in_use:
    #                             # Validate idle connections
    #                             if not self._is_connection_healthy(conn):
                                    self._logger.warning(f"Removing unhealthy idle connection {conn_id}")
    #                                 try:
                                        conn.backend.disconnect()
    #                                 except Exception:
    #                                     pass

    #                                 # Remove from tracking
    #                                 if conn_id in self._connections:
    #                                     del self._connections[conn_id]

    #                                 # Try to create replacement connection
    #                                 try:
                                        self._create_replacement_connection()
    #                                 except Exception as e:
                                        self._logger.error(f"Failed to create replacement connection: {e}")

                        self._update_stats()
    #             except Exception as e:
                    self._logger.error(f"Error in validation thread: {e}")

    #     def _is_connection_healthy(self, conn: PooledConnection) -> bool:
    #         """Check if a connection is healthy."""
    #         try:
    #             # Simple health check - try to execute a query
    #             if hasattr(conn.backend, 'execute_query'):
                    conn.backend.execute_query("SELECT 1", {})
    #                 return True
    #             elif hasattr(conn.backend, 'ping'):
                    return conn.backend.ping()
    #             else:
    #                 # Fallback - assume healthy if no error checking method
    #                 return True
    #         except Exception as e:
                self._logger.debug(f"Connection {conn.id} health check failed: {e}")
    #             return False

    #     def _is_backend_healthy(self, backend) -> bool:
    #         """Check if a backend is healthy."""
    #         try:
    #             if hasattr(backend, 'execute_query'):
                    backend.execute_query("SELECT 1", {})
    #                 return True
    #             elif hasattr(backend, 'ping'):
                    return backend.ping()
    #             else:
    #                 return True
    #         except Exception as e:
                self._logger.debug(f"Backend health check failed: {e}")
    #             return False

    #     def _create_replacement_connection(self):
    #         """Create a replacement connection for the pool."""
    #         try:
    backend = self.backend_factory()
    #             if self._validate_connections and not self._is_backend_healthy(backend):
                    raise ConnectionPoolError("Replacement backend connection failed validation", 2010)

    conn = PooledConnection(
    id = str(uuid.uuid4()),
    backend = backend,
    created_at = time.time(),
    last_used = time.time()
    #             )

    #             # Add to available connections queue
                self._available_connections.put(conn)
                self._logger.debug("Created replacement connection")
    #         except Exception as e:
                raise ConnectionPoolError(f"Failed to create replacement connection: {str(e)}", 2011)

    #     def get_stats(self) -> PoolStats:
    #         """Get current pool statistics."""
            self._update_stats()
    #         return self._stats

    #     def shutdown(self):
    #         """Shutdown connection pool and cleanup all connections."""
    self._shutdown = True
            self._logger.info("Shutting down connection pool")

    #         # Close all connections
    #         with self._lock:
    #             for conn_id, conn in list(self._connections.items()):
    #                 try:
    #                     if conn.in_use:
                            self._logger.warning(f"Force closing in-use connection {conn_id}")
                        conn.backend.disconnect()
    #                 except Exception as e:
                        self._logger.error(f"Error closing connection {conn_id}: {e}")

    #             # Clear tracking
                self._connections.clear()

    #         # Wait for background threads to finish
    #         if hasattr(self, '_cleanup_thread') and self._cleanup_thread.is_alive():
    self._cleanup_thread.join(timeout = 5)

    #         if hasattr(self, '_validation_thread') and self._validation_thread.is_alive():
    self._validation_thread.join(timeout = 5)

            self._logger.info("Connection pool shutdown complete")

    #     def __enter__(self):
    #         return self

    #     def __exit__(self, exc_type, exc_val, exc_tb):
            self.shutdown()