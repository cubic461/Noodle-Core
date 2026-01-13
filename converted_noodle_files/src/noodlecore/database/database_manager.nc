# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# NoodleCore Database Manager
 = =========================

# Central manager for database operations using the connection pool.
# Provides high-level database operations with proper error handling
# and connection management according to development standards.

# Implements:
# - Connection pooling with configurable limits (max 20 connections)
# - 30 second timeout for all operations
# - Parameterized queries to prevent SQL injection
# - Transaction management with auto-commit/rollback
# - Proper error handling with error codes
# - Health monitoring and statistics
# """

import os
import logging
import time
import uuid
import contextlib.contextmanager
import dataclasses.dataclass
import typing.Dict,

import .connection_pool.DatabaseConnectionPool,
import .failover_manager.(
#     DatabaseFailoverManager, FailoverConfig, FailoverMode, FailoverPolicy,
#     DatabaseEndpoint, FailoverState
# )
import .backends.base.DatabaseBackend,
import ..error.DatabaseError,


# @dataclass
class DatabaseConfig
    #     """Database configuration with environment variable support."""
    host: str = os.getenv('NOODLE_DB_HOST', 'localhost')
    port: int = int(os.getenv('NOODLE_DB_PORT', '5432'))
    database: str = os.getenv('NOODLE_DB_NAME', 'noodlecore')
    username: str = os.getenv('NOODLE_DB_USER', '')
    password: str = os.getenv('NOODLE_DB_PASSWORD', '')
    ssl_mode: bool = os.getenv('NOODLE_DB_SSL', 'false').lower() == 'true'
    max_connections: int = int(os.getenv('NOODLE_DB_MAX_CONNECTIONS', '20'))
    timeout: int = int(os.getenv('NOODLE_DB_TIMEOUT', '30'))
    retry_attempts: int = int(os.getenv('NOODLE_DB_RETRY_ATTEMPTS', '3'))
    connection_string: str = ""

    #     def __post_init__(self):
    #         """Generate connection string after initialization."""
    #         if self.connection_string:
    #             return

    #         # Build connection string based on database type
    #         if self.database and self.username and self.password:
    self.connection_string = (
    #                 f"postgresql://{self.username}:{self.password}@"
    #                 f"{self.host}:{self.port}/{self.database}"
    #             )
    #         elif self.database:
    #             # SQLite fallback
    self.connection_string = f"sqlite:///{self.database}"


class DatabaseManager
    #     """
    #     Central database manager for NoodleCore.

    #     Features:
    #     - Connection pooling with proper limits
    #     - Backend-agnostic operations
    #     - Transaction management
    #     - Health monitoring
    #     - Error handling with proper error codes
    #     """

    #     def __init__(
    #         self,
    #         backend_factory,
    config: Optional[DatabaseConfig] = None,
    enable_failover: bool = False,
    failover_endpoints: Optional[List[DatabaseEndpoint]] = None,
    failover_config: Optional[FailoverConfig] = None
    #     ):
    #         """
    #         Initialize database manager.

    #         Args:
    #             backend_factory: Factory function to create backend instances
    #             config: Optional database configuration
    #             enable_failover: Whether to enable automatic failover
    #             failover_endpoints: List of failover endpoints
    #             failover_config: Optional failover configuration
    #         """
    self.backend_factory = backend_factory
    self.config = config or DatabaseConfig()
    self.enable_failover = enable_failover
    self.logger = logging.getLogger('noodlecore.database.manager')
    self._current_backend = None
    self._current_backend_name = None

    #         # Initialize connection pool or failover manager
    #         if enable_failover and failover_endpoints:
    #             # Initialize failover manager
    self.failover_manager = DatabaseFailoverManager(
    endpoints = failover_endpoints,
    backend_factory = backend_factory,
    config = failover_config or FailoverConfig()
    #             )
    self.connection_pool = None
    #             self.logger.info(f"Database manager initialized with failover support ({len(failover_endpoints)} endpoints)")
    #         else:
    #             # Initialize standard connection pool
    self.failover_manager = None
    self.connection_pool = DatabaseConnectionPool(backend_factory, self.config.__dict__)
    #             self.logger.info(f"Database manager initialized with {self.config.max_connections} max connections")

    #     def connect(self, backend_name: str = None) -> None:
    #         """
    #         Connect to specified database backend.

    #         Args:
    #             backend_name: Name of backend to connect to

    #         Raises:
    #             DatabaseError: If connection fails
    #         """
    #         try:
    #             if self.enable_failover and self.failover_manager:
    #                 # Start failover monitoring
                    self.failover_manager.start_monitoring()
    #                 self.logger.info("Connected to database with failover support")
    #                 return None

    #             if backend_name:
    self._current_backend_name = backend_name
    self._current_backend = self.backend_factory(backend_name, self.config)
    #             else:
    #                 # Use default backend
    self._current_backend_name = 'postgresql'
    self._current_backend = self.backend_factory('postgresql', self.config)

    #             # Connect through connection pool
    #             with self.connection_pool.get_connection(self._current_backend_name) as conn:
                    conn.backend.connect()
                    self.logger.info(f"Connected to {self._current_backend_name} database")
    #                 return conn

    #         except Exception as e:
    error_msg = f"Failed to connect to {backend_name or 'default'}: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 3001)

    #     def disconnect(self) -> None:
    #         """Disconnect from current database backend."""
    #         if self._current_backend:
    #             try:
                    self._current_backend.disconnect()
                    self.logger.info(f"Disconnected from {self._current_backend_name}")
    self._current_backend = None
    self._current_backend_name = None
    #             except Exception as e:
    error_msg = f"Error disconnecting from database: {str(e)}"
                    self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 3002)

    #     def execute_query(
    #         self,
    #         query: str,
    params: Optional[Dict[str, Any]] = None,
    timeout: Optional[int] = None
    #     ) -> Any:
    #         """
    #         Execute a parameterized query on the current backend.

    #         Args:
    #             query: SQL query string with parameter placeholders
    #             params: Dictionary of parameters for query
    #             timeout: Optional timeout override in seconds

    #         Returns:
    #             Query results from backend

    #         Raises:
    #             DatabaseError: If query execution fails
    #         """
    #         if self.enable_failover and self.failover_manager:
    #             # Use failover manager for query execution
    #             try:
    start_time = time.time()

    #                 with self.failover_manager.get_connection() as conn:
    result = conn.execute_query(query, params)

    #                     # Log slow queries
    execution_time = math.subtract(time.time(), start_time)
    #                     if execution_time > 1.0:  # 1 second threshold
                            self.logger.warning(
                                f"Slow query ({execution_time:.2f}s): {query[:100]}..."
    #                         )

    #                     return result

    #             except Exception as e:
    error_msg = f"Query execution failed: {str(e)}"
                    self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 3005)

    #         # Standard query execution without failover
    #         if not self._current_backend:
    raise DatabaseError("No database connection", error_code = 3003)

    #         try:
    start_time = time.time()
    query_timeout = timeout or self.config.timeout

    #             with self.connection_pool.get_connection(self._current_backend_name) as conn:
    result = conn.execute_query(query, params)

    #                 # Log slow queries
    execution_time = math.subtract(time.time(), start_time)
    #                 if execution_time > 1.0:  # 1 second threshold
                        self.logger.warning(
                            f"Slow query ({execution_time:.2f}s): {query[:100]}..."
    #                     )

    #                 return result

    #         except TimeoutError as e:
    error_msg = f"Query timeout after {query_timeout}s: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 3004)
    #         except Exception as e:
    error_msg = f"Query execution failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 3005)

    #     def execute_batch(
    #         self,
    #         queries: List[tuple]
    #     ) -> List[Any]:
    #         """
    #         Execute multiple queries in a transaction.

    #         Args:
                queries: List of (query, params) tuples

    #         Returns:
    #             List of results

    #         Raises:
    #             DatabaseError: If any query fails
    #         """
    #         if not self._current_backend:
    raise DatabaseError("No database connection", error_code = 3006)

    #         try:
    #             with self.connection_pool.get_connection(self._current_backend_name) as conn:
    #                 with conn.backend.transaction():
    results = []
    #                     for query, params in queries:
    result = conn.execute_query(query, params)
                            results.append(result)
    #                     return results
    #         except Exception as e:
    error_msg = f"Batch execution failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 3007)

    #     @contextmanager
    #     def transaction(self):
    #         """
    #         Context manager for database transactions.

    #         Yields:
    #             Transaction context from backend

    #         Raises:
    #             DatabaseError: If transaction creation fails
    #         """
    #         if not self._current_backend:
    raise DatabaseError("No database connection", error_code = 3008)

    #         try:
    #             with self.connection_pool.get_connection(self._current_backend_name) as conn:
    #                 with conn.backend.transaction() as tx:
    #                     yield tx
    #         except Exception as e:
    error_msg = f"Transaction failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 3009)

    #     def insert(self, table: str, data: Dict[str, Any]) -> int:
    #         """
    #         Insert data into a table.

    #         Args:
    #             table: Target table name
    #             data: Dictionary of column-value pairs

    #         Returns:
    #             ID of inserted row

    #         Raises:
    #             DatabaseError: If insertion fails
    #         """
    #         if not self._current_backend:
    raise DatabaseError("No database connection", error_code = 3010)

    #         try:
    #             with self.connection_pool.get_connection(self._current_backend_name) as conn:
                    return conn.backend.insert(table, data)
    #         except Exception as e:
    error_msg = f"Insert operation failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 3011)

    #     def update(
    #         self,
    #         table: str,
    #         data: Dict[str, Any],
    #         conditions: Dict[str, Any]
    #     ) -> int:
    #         """
    #         Update data in a table.

    #         Args:
    #             table: Target table name
    #             data: Dictionary of column-value pairs
    #             conditions: Dictionary of conditions for WHERE clause

    #         Returns:
    #             Number of rows affected

    #         Raises:
    #             DatabaseError: If update fails
    #         """
    #         if not self._current_backend:
    raise DatabaseError("No database connection", error_code = 3012)

    #         try:
    #             with self.connection_pool.get_connection(self._current_backend_name) as conn:
                    return conn.backend.update(table, data, conditions)
    #         except Exception as e:
    error_msg = f"Update operation failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 3013)

    #     def delete(self, table: str, conditions: Dict[str, Any]) -> int:
    #         """
    #         Delete data from a table.

    #         Args:
    #             table: Target table name
    #             conditions: Dictionary of conditions for WHERE clause

    #         Returns:
    #             Number of rows affected

    #         Raises:
    #             DatabaseError: If deletion fails
    #         """
    #         if not self._current_backend:
    raise DatabaseError("No database connection", error_code = 3014)

    #         try:
    #             with self.connection_pool.get_connection(self._current_backend_name) as conn:
                    return conn.backend.delete(table, conditions)
    #         except Exception as e:
    error_msg = f"Delete operation failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 3015)

    #     def select(
    #         self,
    #         table: str,
    columns: Optional[List[str]] = None,
    conditions: Optional[Dict[str, Any]] = None,
    limit: Optional[int] = None
    #     ) -> List[Dict[str, Any]]:
    #         """
    #         Select data from a table.

    #         Args:
    #             table: Target table name
    #             columns: Optional list of column names
    #             conditions: Optional dictionary of conditions
    #             limit: Optional limit for results

    #         Returns:
    #             List of dictionaries representing rows

    #         Raises:
    #             DatabaseError: If selection fails
    #         """
    #         if not self._current_backend:
    raise DatabaseError("No database connection", error_code = 3016)

    #         try:
    #             with self.connection_pool.get_connection(self._current_backend_name) as conn:
                    return conn.backend.select(table, columns, conditions, limit)
    #         except Exception as e:
    error_msg = f"Select operation failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 3017)

    #     def table_exists(self, table_name: str) -> bool:
    #         """
    #         Check if a table exists.

    #         Args:
    #             table_name: Name of table to check

    #         Returns:
    #             True if table exists, False otherwise

    #         Raises:
    #             DatabaseError: If check fails
    #         """
    #         if not self._current_backend:
    raise DatabaseError("No database connection", error_code = 3018)

    #         try:
    #             with self.connection_pool.get_connection(self._current_backend_name) as conn:
                    return conn.backend.table_exists(table_name)
    #         except Exception as e:
    error_msg = f"Table existence check failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 3019)

    #     def create_table(self, table_name: str, schema: Dict[str, str]) -> None:
    #         """
    #         Create a table with the given schema.

    #         Args:
    #             table_name: Name of table to create
    #             schema: Dictionary mapping column names to SQL types

    #         Raises:
    #             DatabaseError: If table creation fails
    #         """
    #         if not self._current_backend:
    raise DatabaseError("No database connection", error_code = 3020)

    #         try:
    #             with self.connection_pool.get_connection(self._current_backend_name) as conn:
                    conn.backend.create_table(table_name, schema)
                    self.logger.info(f"Table {table_name} created successfully")
    #         except Exception as e:
    error_msg = f"Table creation failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 3021)

    #     def drop_table(self, table_name: str) -> None:
    #         """
    #         Drop a table from the database.

    #         Args:
    #             table_name: Name of table to drop

    #         Raises:
    #             DatabaseError: If table dropping fails
    #         """
    #         if not self._current_backend:
    raise DatabaseError("No database connection", error_code = 3022)

    #         try:
    #             with self.connection_pool.get_connection(self._current_backend_name) as conn:
                    conn.backend.drop_table(table_name)
                    self.logger.info(f"Table {table_name} dropped successfully")
    #         except Exception as e:
    error_msg = f"Table dropping failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 3023)

    #     def get_table_schema(self, table_name: str) -> Dict[str, str]:
    #         """
    #         Get the schema of a table.

    #         Args:
    #             table_name: Name of table

    #         Returns:
    #             Dictionary mapping column names to their SQL types

    #         Raises:
    #             DatabaseError: If schema retrieval fails
    #         """
    #         if not self._current_backend:
    raise DatabaseError("No database connection", error_code = 3024)

    #         try:
    #             with self.connection_pool.get_connection(self._current_backend_name) as conn:
                    return conn.backend.get_table_schema(table_name)
    #         except Exception as e:
    error_msg = f"Schema retrieval failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 3025)

    #     def backup_database(self, backup_path: str) -> None:
    #         """
    #         Create a backup of the current database.

    #         Args:
    #             backup_path: Path where to store the backup

    #         Raises:
    #             DatabaseError: If backup fails
    #         """
    #         if not self._current_backend:
    raise DatabaseError("No database connection", error_code = 3026)

    #         try:
    #             with self.connection_pool.get_connection(self._current_backend_name) as conn:
                    conn.backend.backup_database(backup_path)
                    self.logger.info(f"Database backed up to {backup_path}")
    #         except Exception as e:
    error_msg = f"Backup failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 3027)

    #     def restore_database(self, backup_path: str) -> None:
    #         """
    #         Restore a database from a backup.

    #         Args:
    #             backup_path: Path to the backup file

    #         Raises:
    #             DatabaseError: If restore fails
    #         """
    #         if not self._current_backend:
    raise DatabaseError("No database connection", error_code = 3028)

    #         try:
    #             with self.connection_pool.get_connection(self._current_backend_name) as conn:
                    conn.backend.restore_database(backup_path)
                    self.logger.info(f"Database restored from {backup_path}")
    #         except Exception as e:
    error_msg = f"Restore failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 3029)

    #     def optimize_database(self) -> None:
    #         """
    #         Optimize the database for better performance.

    #         Raises:
    #             DatabaseError: If optimization fails
    #         """
    #         if not self._current_backend:
    raise DatabaseError("No database connection", error_code = 3030)

    #         try:
    #             with self.connection_pool.get_connection(self._current_backend_name) as conn:
                    conn.backend.optimize_database()
                    self.logger.info("Database optimization completed")
    #         except Exception as e:
    error_msg = f"Database optimization failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 3031)

    #     def get_database_stats(self) -> Dict[str, Any]:
    #         """
    #         Get database statistics.

    #         Returns:
    #             Dictionary containing database statistics

    #         Raises:
    #             DatabaseError: If stats retrieval fails
    #         """
    #         if not self._current_backend:
    raise DatabaseError("No database connection", error_code = 3032)

    #         try:
    #             with self.connection_pool.get_connection(self._current_backend_name) as conn:
    stats = conn.backend.get_database_stats()
    pool_stats = self.connection_pool.get_stats()

    #                 # Combine backend and pool stats
    combined_stats = {
    #                     "backend": self._current_backend_name,
    #                     "connection_string": self.config.connection_string,
    #                     "pool_stats": {
    #                         "total_connections": pool_stats.total_connections,
    #                         "active_connections": pool_stats.active_connections,
    #                         "idle_connections": pool_stats.idle_connections,
    #                         "pool_health_score": pool_stats.pool_health_score
    #                     },
    #                     **stats
    #                 }
    #                 return combined_stats
    #         except Exception as e:
    error_msg = f"Stats retrieval failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 3033)

    #     def health_check(self) -> bool:
    #         """
    #         Check if the database is healthy and accessible.

    #         Returns:
    #             True if database is healthy, False otherwise

    #         Raises:
    #             DatabaseError: If health check fails
    #         """
    #         if not self._current_backend:
    raise DatabaseError("No database connection", error_code = 3034)

    #         try:
    #             with self.connection_pool.get_connection(self._current_backend_name) as conn:
                    return conn.backend.health_check()
    #         except Exception as e:
    error_msg = f"Health check failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 3035)

    #     def get_pool_stats(self) -> PoolStats:
    #         """
    #         Get connection pool statistics.

    #         Returns:
    #             Current pool statistics
    #         """
            return self.connection_pool.get_stats()

    #     def get_connection_info(self) -> Dict[str, int]:
    #         """
    #         Get information about current connections.

    #         Returns:
    #             Dictionary with connection pool information
    #         """
    #         if not self._current_backend:
    #             return {
    #                 "total_connections": 0,
    #                 "available_connections": 0,
    #                 "busy_connections": 0
    #             }

            return self.connection_pool.get_pool_stats()

    #     def close(self) -> None:
    #         """
    #         Close all database connections and shutdown the pool/failover manager.
    #         """
    #         try:
    #             if self.enable_failover and self.failover_manager:
                    self.failover_manager.shutdown()
    #             elif self.connection_pool:
                    self.connection_pool.shutdown()

    self._current_backend = None
    self._current_backend_name = None
                self.logger.info("Database manager closed")
    #         except Exception as e:
    error_msg = f"Error closing database manager: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 3036)

    #     def get_failover_status(self) -> Optional[Dict[str, Any]]:
    #         """
    #         Get failover status if failover is enabled.

    #         Returns:
    #             Failover status dictionary or None if failover is not enabled
    #         """
    #         if self.enable_failover and self.failover_manager:
                return self.failover_manager.get_status()
    #         return None

    #     def trigger_failover(self, reason: str = "Manual failover") -> bool:
    #         """
    #         Manually trigger a failover if failover is enabled.

    #         Args:
    #             reason: Reason for failover

    #         Returns:
    #             True if failover was successful

    #         Raises:
    #             DatabaseError: If failover is not enabled or fails
    #         """
    #         if not self.enable_failover or not self.failover_manager:
    raise DatabaseError("Failover is not enabled", error_code = 3037)

            return self.failover_manager.trigger_failover(reason)

    #     def trigger_recovery(self) -> bool:
    #         """
    #         Manually trigger recovery to primary endpoint if failover is enabled.

    #         Returns:
    #             True if recovery was successful

    #         Raises:
    #             DatabaseError: If failover is not enabled or recovery fails
    #         """
    #         if not self.enable_failover or not self.failover_manager:
    raise DatabaseError("Failover is not enabled", error_code = 3038)

            return self.failover_manager.trigger_recovery()


# Global database manager instance
_global_manager = None


def get_database_manager(backend_factory=None, config=None) -> DatabaseManager:
#     """
#     Get the global database manager instance.

#     Args:
#         backend_factory: Optional factory function for creating backends
#         config: Optional database configuration

#     Returns:
#         DatabaseManager instance
#     """
#     global _global_manager
#     if _global_manager is None:
_global_manager = DatabaseManager(backend_factory, config)
#     return _global_manager