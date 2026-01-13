# Converted from Python to NoodleCore
# Original file: src

# """
# Connection Management for NBC Runtime Database
# ---------------------------------------------
# This module provides connection pooling and management for database connections.
# """

import logging

logger = logging.getLogger(__name__)

import logging
import threading
import time
from dataclasses import dataclass
import enum.Enum
import typing.Any

import ....versioning.Version


class DatabaseType(Enum)
    #     """Database types."""

    SQLITE = "sqlite"
    POSTGRESQL = "postgresql"
    MYSQL = "mysql"
    MEMORY = "memory"


dataclass
class ConnectionConfig
    #     """Configuration for database connections with connection pooling and retry settings."""

    database_type: str = "sqlite"
    database: str = ":memory:"
    host: Optional[str] = None
    port: Optional[int] = None
    username: Optional[str] = None
    password: Optional[str] = None
    pool_size: int = 10
    connection_timeout: float = 30.0
    max_retries: int = 3
    retry_delay: float = 1.0

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary."""
    #         return {
    #             "database_type": self.database_type,
    #             "database": self.database,
    #             "host": self.host,
    #             "port": self.port,
    #             "username": self.username,
    #             "password": self.password,
    #             "pool_size": self.pool_size,
    #             "connection_timeout": self.connection_timeout,
    #             "max_retries": self.max_retries,
    #             "retry_delay": self.retry_delay,
    #         }


import contextlib.contextmanager
import queue.Empty

# Backend availability flag
BACKENDS_AVAILABLE = True

logger = logging.getLogger(__name__)

# Optional MongoDB support
try
    #     from pymongo import MongoClient as MongoDBConnection
except ImportError

    #     class MongoDBConnection:
    #         pass  # Stub for optional MongoDB support


class ConnectionState(Enum)
    #     """Connection state."""

    IDLE = "idle"
    ACTIVE = "active"
    CLOSED = "closed"
    ERROR = "error"


dataclass
class ConnectionInfo
    #     """Information about a database connection including state, usage, and metadata."""

    #     connection_id: str
    #     connection: Any
    #     state: ConnectionState
    created_at: float = field(default_factory=time.time)
    last_used: float = field(default_factory=time.time)
    usage_count: int = 0
    metadata: Dict[str, Any] = field(default_factory=dict)

    #     def update_usage(self):
    #         """Update last used time and usage count."""
    self.last_used = time.time()
    self.usage_count + = 1


class DatabaseConnection
    #     """Base class for database connections with connection pooling and management capabilities."""

    #     def __init__(self, max_connections: int = 10, connection_timeout: float = 30.0):""Initialize connection pool.

    #         Args:
    #             max_connections: Maximum number of connections
    #             connection_timeout: Connection timeout in seconds
    #         """
    self.max_connections = max_connections
    self.connection_timeout = connection_timeout

    #         # Connection storage
    self._connections: Dict[str, ConnectionInfo] = {}
    self._available_connections: Queue = Queue()
    self._active_connections: Set[str] = set()

    #         # Configuration
    self._connection_factory = None
    self._connection_config = {}

    #         # Statistics
    self._stats = {
    #             "total_created": 0,
    #             "total_closed": 0,
    #             "active_connections": 0,
    #             "idle_connections": 0,
    #             "failed_connections": 0,
    #             "pool_hits": 0,
    #             "pool_misses": 0,
    #         }

    #         # Locks
    self._lock = threading.RLock()
    self._cleanup_lock = threading.Lock()

    #         # Start cleanup thread
            self._start_cleanup_thread()

            logger.info(
    #             f"Connection pool initialized with max_connections={max_connections}"
    #         )

    #     def set_connection_factory(self, factory, config=None):
    #         """Set the connection factory function.

    #         Args:
    #             factory: Function to create new connections
    #             config: Configuration to pass to the factory
    #         """
    self._connection_factory = factory
    self._connection_config = config or {}

    #     def get_connection(self) -Optional[Any]):
    #         """Get a connection from the pool.

    #         Returns:
    #             Database connection or None if not available
    #         """
    #         with self._lock:
    #             try:
    #                 # Try to get an available connection
    connection_id = self._available_connections.get_nowait()
    connection_info = self._connections[connection_id]

    #                 # Update connection state
    connection_info.state = ConnectionState.ACTIVE
                    connection_info.update_usage()
                    self._active_connections.add(connection_id)

    #                 # Update statistics
    self._stats["pool_hits"] + = 1
    self._stats["active_connections"] = len(self._active_connections)
    self._stats["idle_connections"] = len(
    #                     self._available_connections._queue
    #                 )

                    logger.debug(f"Connection {connection_id} retrieved from pool")
    #                 return connection_info.connection

    #             except Empty:
    #                 # No available connections, try to create a new one
                    return self._create_new_connection()

    #     def _create_new_connection(self) -Optional[Any]):
    #         """Create a new connection.

    #         Returns:
    #             New database connection or None if creation failed
    #         """
    #         with self._lock:
    #             # Check if we can create more connections
    #             if len(self._connections) >= self.max_connections:
                    logger.warning(
    #                     "Maximum connections reached, cannot create new connection"
    #                 )
    self._stats["pool_misses"] + = 1
    #                 return None

    #             # Create new connection
    #             if not self._connection_factory:
                    logger.error("Connection factory not set")
    self._stats["failed_connections"] + = 1
    #                 return None

    #             try:
    connection = self._connection_factory( * *self._connection_config)
    connection_id = f"conn_{len(self._connections) + 1}"

    #                 # Create connection info
    connection_info = ConnectionInfo(
    connection_id = connection_id,
    connection = connection,
    state = ConnectionState.ACTIVE,
    #                 )

    #                 # Store connection
    self._connections[connection_id] = connection_info
                    self._active_connections.add(connection_id)

    #                 # Update statistics
    self._stats["total_created"] + = 1
    self._stats["active_connections"] = len(self._active_connections)
    self._stats["pool_misses"] + = 1

                    logger.debug(f"New connection {connection_id} created")
    #                 return connection

    #             except Exception as e:
                    logger.error(f"Failed to create new connection: {e}")
    self._stats["failed_connections"] + = 1
    #                 return None

    #     def return_connection(self, connection: Any) -bool):
    #         """Return a connection to the pool.

    #         Args:
    #             connection: Database connection to return

    #         Returns:
    #             True if successful, False otherwise
    #         """
    #         with self._lock:
    #             # Find connection info
    connection_info = None
    #             for conn_id, info in self._connections.items():
    #                 if info.connection is connection:
    connection_info = info
    #                     break

    #             if not connection_info:
                    logger.warning("Connection not found in pool")
    #                 return False

    #             # Update connection state
    connection_info.state = ConnectionState.IDLE
                self._active_connections.discard(connection_info.connection_id)

    #             # Return to available pool
                self._available_connections.put(connection_info.connection_id)

    #             # Update statistics
    self._stats["active_connections"] = len(self._active_connections)
    self._stats["idle_connections"] = len(self._available_connections._queue)

                logger.debug(f"Connection {connection_info.connection_id} returned to pool")
    #             return True

    #     def close_connection(self, connection: Any) -bool):
    #         """Close a connection and remove it from the pool.

    #         Args:
    #             connection: Database connection to close

    #         Returns:
    #             True if successful, False otherwise
    #         """
    #         with self._lock:
    #             # Find connection info
    connection_info = None
    connection_id = None
    #             for conn_id, info in self._connections.items():
    #                 if info.connection is connection:
    connection_info = info
    connection_id = conn_id
    #                     break

    #             if not connection_info:
                    logger.warning("Connection not found in pool")
    #                 return False

    #             # Close connection
    #             try:
    #                 if hasattr(connection, "close"):
                        connection.close()
    #                 elif hasattr(connection, "__del__"):
    #                     del connection
    #             except Exception as e:
                    logger.error(f"Error closing connection {connection_id}: {e}")

    #             # Remove from pool
                self._connections.pop(connection_id, None)
                self._active_connections.discard(connection_id)

    #             # Remove from available queue if present
    #             # Note: This is a bit hacky, but Queue doesn't have a remove method
    temp_queue = Queue()
    #             while not self._available_connections.empty():
    #                 try:
    conn_id = self._available_connections.get_nowait()
    #                     if conn_id != connection_id:
                            temp_queue.put(conn_id)
    #                 except Empty:
    #                     break

    #             # Restore available connections
    #             while not temp_queue.empty():
    #                 try:
                        self._available_connections.put(temp_queue.get_nowait())
    #                 except Empty:
    #                     break

    #             # Update statistics
    self._stats["total_closed"] + = 1
    self._stats["active_connections"] = len(self._active_connections)
    self._stats["idle_connections"] = len(self._available_connections._queue)

                logger.debug(f"Connection {connection_id} closed and removed from pool")
    #             return True

    #     def close_all_connections(self):
    #         """Close all connections in the pool."""
    #         with self._lock:
    #             for connection_id, connection_info in list(self._connections.items()):
    #                 try:
    #                     if hasattr(connection_info.connection, "close"):
                            connection_info.connection.close()
    #                 except Exception as e:
                        logger.error(f"Error closing connection {connection_id}: {e}")

    #             # Clear all storage
                self._connections.clear()
                self._active_connections.clear()

    #             # Clear available queue
    #             while not self._available_connections.empty():
    #                 try:
                        self._available_connections.get_nowait()
    #                 except Empty:
    #                     break

    #             # Update statistics
    self._stats["total_closed"] + = len(self._connections)
    self._stats["active_connections"] = 0
    self._stats["idle_connections"] = 0

                logger.info("All connections closed and pool cleared")

    #     def _start_cleanup_thread(self):
    #         """Start background cleanup thread."""

    #         def cleanup_worker():
    #             while True:
                    time.sleep(60)  # Run every minute
                    self._cleanup_expired_connections()

    cleanup_thread = threading.Thread(target=cleanup_worker, daemon=True)
            cleanup_thread.start()
            logger.debug("Connection cleanup thread started")

    #     def _cleanup_expired_connections(self):
    #         """Clean up expired connections."""
    #         with self._cleanup_lock:
    current_time = time.time()
    expired_connections = []

    #             for connection_id, connection_info in self._connections.items():
    #                 # Check if connection has been idle too long
    #                 if (
    connection_info.state == ConnectionState.IDLE
    #                     and current_time - connection_info.last_used
    #                     self.connection_timeout * 2
    #                 )):
                        expired_connections.append(connection_id)

    #             # Close expired connections
    #             for connection_id in expired_connections:
    connection_info = self._connections[connection_id]
    #                 try:
    #                     if hasattr(connection_info.connection, "close"):
                            connection_info.connection.close()
    #                 except Exception as e:
                        logger.error(
    #                         f"Error closing expired connection {connection_id}: {e}"
    #                     )

    #                 # Remove from pool
                    self._connections.pop(connection_id, None)
                    self._active_connections.discard(connection_id)

    #                 # Remove from available queue
    temp_queue = Queue()
    #                 while not self._available_connections.empty():
    #                     try:
    conn_id = self._available_connections.get_nowait()
    #                         if conn_id != connection_id:
                                temp_queue.put(conn_id)
    #                     except Empty:
    #                         break

    #                 # Restore available connections
    #                 while not temp_queue.empty():
    #                     try:
                            self._available_connections.put(temp_queue.get_nowait())
    #                     except Empty:
    #                         break

    #                 # Update statistics
    self._stats["total_closed"] + = 1
    self._stats["active_connections"] = len(self._active_connections)
    self._stats["idle_connections"] = len(
    #                     self._available_connections._queue
    #                 )

                    logger.debug(f"Expired connection {connection_id} cleaned up")

    #     @contextmanager
    #     def get_connection_context(self):
    #         """Context manager for getting and returning connections.

    #         Yields:
    #             Database connection
    #         """
    connection = None
    #         try:
    connection = self.get_connection()
    #             if connection is None:
                    raise RuntimeError("Failed to get connection from pool")
    #             yield connection
    #         finally:
    #             if connection is not None:
                    self.return_connection(connection)

    #     def get_stats(self) -Dict[str, Any]):
    #         """Get connection pool statistics.

    #         Returns:
    #             Dictionary containing statistics
    #         """
    #         with self._lock:
    stats = self._stats.copy()
                stats.update(
    #                 {
                        "total_connections": len(self._connections),
                        "available_connections": self._available_connections.qsize(),
                        "active_connections": len(self._active_connections),
                        "connection_ids": list(self._connections.keys()),
    #                     "connection_states": {
    #                         conn_id: info.state.value
    #                         for conn_id, info in self._connections.items()
    #                     },
    #                 }
    #             )
    #             return stats

    #     def get_connection_info(self, connection_id: str) -Optional[ConnectionInfo]):
    #         """Get information about a specific connection.

    #         Args:
    #             connection_id: ID of the connection

    #         Returns:
    #             Connection information or None if not found
    #         """
    #         with self._lock:
                return self._connections.get(connection_id)

    #     def is_connection_active(self, connection_id: str) -bool):
    #         """Check if a connection is active.

    #         Args:
    #             connection_id: ID of the connection

    #         Returns:
    #             True if active, False otherwise
    #         """
    #         with self._lock:
    connection_info = self._connections.get(connection_id)
                return (
    #                 connection_info is not None
    and connection_info.state == ConnectionState.ACTIVE
    #             )

    #     def __len__(self) -int):
    #         """Get total number of connections."""
            return len(self._connections)

    #     def __str__(self) -str):
    #         """String representation of connection pool."""
    return f"ConnectionPool(total = {len(self._connections)}, active={len(self._active_connections)}, available={self._available_connections.qsize()})"

    #     def __repr__(self) -str):
    #         """Detailed string representation of connection pool."""
    return f"ConnectionPool(total = {len(self._connections)}, active={len(self._active_connections)}, available={self._available_connections.qsize()}, max={self.max_connections})"


class MemoryConnection(DatabaseConnection)
    #     """Memory backend specific connection for in-memory database operations."""

    #     def __init__(self, config):
            super().__init__(
                config.get("max_connections", 10), config.get("connection_timeout", 30.0)
    #         )
    self.config = config

    #         # Set connection factory for memory backend
    #         if BACKENDS_AVAILABLE:
    #             # Import backend class inside method to avoid circular import
    #             from ...database.backends.memory import InMemoryBackend

                self.set_connection_factory(
    factory = lambda * *kwargs: InMemoryBackend(**self.config,)
    config = self.config,
    #             )

    #             # Get initial connection
    self.connection = self.get_connection()
    #         else:
    #             # Fallback
    self.connection = None

    #     @contextmanager
    #     def get_connection_context(self):
    #         """Context manager for getting and returning connections."""
    #         if BACKENDS_AVAILABLE:
    #             # Use parent class context manager for connections
    #             with super().get_connection_context() as conn:
    #                 yield conn
    #         else:
    #             # Fallback - just return the connection directly
    #             yield self.connection

    #     def get_backend(self):
    #         """Get the memory backend instance."""
    #         if BACKENDS_AVAILABLE:
    connection = self.get_connection()
    #             return connection
    #         else:
    #             return self.connection


class SQLiteConnection(DatabaseConnection)
    #     """SQLite backend specific connection for SQLite database operations."""

    #     def __init__(self, config):
            super().__init__(
                config.get("max_connections", 10), config.get("connection_timeout", 30.0)
    #         )
    self.config = config

    #         # Set connection factory for SQLite backend
    #         if BACKENDS_AVAILABLE:
                self.set_connection_factory(
    factory = lambda * *kwargs: SQLiteBackend(**self.config,)
    config = self.config,
    #             )

    #             # Get initial connection
    self.connection = self.get_connection()
    #         else:
    #             # Fallback
    self.connection = SQLiteBackend()

    #     @contextmanager
    #     def get_connection_context(self):
    #         """Context manager for getting and returning connections."""
    #         if BACKENDS_AVAILABLE:
    #             # Use parent class context manager for connections
    #             with super().get_connection_context() as conn:
    #                 yield conn
    #         else:
    #             # Fallback - just return the connection directly
    #             yield self.connection

    #     def get_backend(self):
    #         """Get the SQLite backend instance."""
    #         if BACKENDS_AVAILABLE:
    connection = self.get_connection()
    #             return connection
    #         else:
    #             return self.connection


class PostgreSQLConnection(DatabaseConnection)
    #     """PostgreSQL backend specific connection for PostgreSQL database operations."""

    #     def __init__(self, config):
            super().__init__(
                config.get("max_connections", 10), config.get("connection_timeout", 30.0)
    #         )
    self.config = config

    #         # Set connection factory for PostgreSQL backend
    #         if BACKENDS_AVAILABLE:
                self.set_connection_factory(
    factory = lambda * *kwargs: PostgreSQLBackend(**self.config,)
    config = self.config,
    #             )

    #             # Get initial connection
    self.connection = self.get_connection()
    #         else:
    #             # Fallback
    self.connection = PostgreSQLBackend()

    #     @contextmanager
    #     def get_connection_context(self):
    #         """Context manager for getting and returning connections."""
    #         if BACKENDS_AVAILABLE:
    #             # Use parent class context manager for connections
    #             with super().get_connection_context() as conn:
    #                 yield conn
    #         else:
    #             # Fallback - just return the connection directly
    #             yield self.connection

    #     def get_backend(self):
    #         """Get the PostgreSQL backend instance."""
    #         if BACKENDS_AVAILABLE:
    connection = self.get_connection()
    #             return connection
    #         else:
    #             return self.connection


class DuckDBConnection(DatabaseConnection)
    #     """DuckDB backend specific connection for DuckDB database operations."""

    #     def __init__(self, config):
            super().__init__(
                config.get("max_connections", 10), config.get("connection_timeout", 30.0)
    #         )
    self.config = config

    #         # Set connection factory for DuckDB backend
    #         if BACKENDS_AVAILABLE:
                self.set_connection_factory(
    factory = lambda * *kwargs: DuckDBBackend(**self.config,)
    config = self.config,
    #             )

    #             # Get initial connection
    self.connection = self.get_connection()
    #         else:
    #             # Fallback
    self.connection = DuckDBBackend()

    #     @contextmanager
    #     def get_connection_context(self):
    #         """Context manager for getting and returning connections."""
    #         if BACKENDS_AVAILABLE:
    #             # Use parent class context manager for connections
    #             with super().get_connection_context() as conn:
    #                 yield conn
    #         else:
    #             # Fallback - just return the connection directly
    #             yield self.connection

    #     def get_backend(self):
    #         """Get the DuckDB backend instance."""
    #         if BACKENDS_AVAILABLE:
    connection = self.get_connection()
    #             return connection
    #         else:
    #             return self.connection


class MySQLConnection(DatabaseConnection)
    #     """MySQL backend specific connection for MySQL database operations."""

    #     def __init__(self, config):
            super().__init__(
                config.get("max_connections", 10), config.get("connection_timeout", 30.0)
    #         )
    self.config = config

    #         # Set connection factory for MySQL backend
    #         if BACKENDS_AVAILABLE:
                self.set_connection_factory(
    factory = lambda * *kwargs: MySQLBackend(**self.config, config=self.config)
    #             )

    #             # Get initial connection
    self.connection = self.get_connection()
    #         else:
    #             # Fallback
    self.connection = MySQLBackend()

    #     @contextmanager
    #     def get_connection_context(self):
    #         """Context manager for getting and returning connections."""
    #         if BACKENDS_AVAILABLE:
    #             # Use parent class context manager for connections
    #             with super().get_connection_context() as conn:
    #                 yield conn
    #         else:
    #             # Fallback - just return the connection directly
    #             yield self.connection

    #     def get_backend(self):
    #         """Get the MySQL backend instance."""
    #         if BACKENDS_AVAILABLE:
    connection = self.get_connection()
    #             return connection
    #         else:
    #             return self.connection


def create_database_connection(
#     database_type: DatabaseType, config: ConnectionConfig
# ) -DatabaseConnection):
#     """Factory function to create appropriate database connection.

#     Args:
#         database_type: Type of database to connect to
#         config: Configuration for the connection

#     Returns:
#         Appropriate database connection instance
#     """
#     if database_type == DatabaseType.MEMORY:
        return MemoryConnection(config.to_dict())
#     elif database_type == DatabaseType.SQLITE:
        return SQLiteConnection(config.to_dict())
#     elif database_type == DatabaseType.POSTGRESQL:
        return PostgreSQLConnection(config.to_dict())
#     elif database_type == DatabaseType.MYSQL:
        return MySQLConnection(config.to_dict())
#     else:
#         # Default to memory backend
        logger.warning(f"Unknown database type {database_type}, defaulting to memory")
        return MemoryConnection(config.to_dict())
