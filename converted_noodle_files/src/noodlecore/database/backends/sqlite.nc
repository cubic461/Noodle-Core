# Converted from Python to NoodleCore
# Original file: noodle-core

# """NoodleCore SQLite Database Backend
 = =================================

# SQLite backend implementation for local development and testing.
# Provides fast, file-based storage with full SQL compatibility.

# Implements the database standards:
- Connection pooling support (max 20 connections, 30s timeout)
# - Parameterized queries to prevent SQL injection
# - Transaction management with auto-commit/rollback
# - Proper error handling with 4-digit error codes
# """

import os
import logging
import time
import uuid
import sqlite3
import typing.Dict,
import contextlib.contextmanager

import .base.DatabaseBackend,
import ..errors.(
#     DatabaseError, BackendError, ConnectionError, TimeoutError,
#     QueryError, TransactionError
# )


class SQLiteBackend(DatabaseBackend)
    #     """
    #     SQLite database backend implementation.

    #     Features:
    #     - Full SQLite compatibility
    #     - Connection pooling support
    #     - Transaction management
    #     - Index management
    #     - Proper error handling with error codes
    #     - In-memory database option for testing
    #     """

    #     def __init__(self, config: Optional[BackendConfig] = None):
    #         """
    #         Initialize SQLite backend.

    #         Args:
    #             config: Optional backend configuration
    #         """
            super().__init__(config or BackendConfig())
    self._connection = None
    self._connection_id = None
    self._cursor = None
    self.logger = logging.getLogger('noodlecore.database.backends.sqlite')

    #         # Validate required configuration
    #         if not self.config.database:
    raise ConnectionError("Database name is required", error_code = 6001)

    #         self.logger.info(f"SQLite backend initialized for database: {self.config.database}")

    #     def connect(self) -> bool:
    #         """
    #         Establish SQLite connection.

    #         Returns:
    #             True if connection successful, False otherwise

    #         Raises:
    #             ConnectionError: If connection fails
    #         """
    #         try:
    #             # Build database path
    #             if self.config.connection_string:
    #                 # Use provided connection string
    db_path = self.config.connection_string.replace("sqlite:///", "")
    #             elif self.config.database:
    #                 # Use database name as file path
    db_path = self.config.database
    #                 if not db_path.endswith('.db') and not db_path.endswith('.sqlite'):
    db_path + = '.db'
    #             else:
    #                 # Default to in-memory database
    db_path = ':memory:'

    #             # Connect with timeout
    self._connection = sqlite3.connect(
    #                 db_path,
    timeout = self.config.timeout,
    check_same_thread = False
    #             )

    self._connection_id = str(uuid.uuid4())
    self._connected = True

    #             # Enable foreign keys and WAL mode for better performance
    self._connection.execute("PRAGMA foreign_keys = ON")
    self._connection.execute("PRAGMA journal_mode = WAL")

    #             self.logger.info(f"Connected to SQLite with ID: {self._connection_id}")
    #             return True

    #         except sqlite3.Error as e:
    error_msg = f"SQLite connection failed: {str(e)}"
                self.logger.error(error_msg)
    raise ConnectionError(error_msg, error_code = 6002)
    #         except Exception as e:
    error_msg = f"Unexpected connection error: {str(e)}"
                self.logger.error(error_msg)
    raise ConnectionError(error_msg, error_code = 6003)

    #     def disconnect(self) -> None:
    #         """
    #         Close SQLite connection.

    #         Raises:
    #             ConnectionError: If disconnection fails
    #         """
    #         try:
    #             if self._connection:
                    self._connection.close()
    self._connection = None
    self._cursor = None
    self._connected = False
                    self.logger.info(f"Disconnected from SQLite: {self._connection_id}")
    #         except Exception as e:
    error_msg = f"Disconnection failed: {str(e)}"
                self.logger.error(error_msg)
    raise ConnectionError(error_msg, error_code = 6004)

    #     def execute_query(
    #         self,
    #         query: str,
    params: Optional[Dict[str, Any]] = None,
    timeout: Optional[int] = None
    #     ) -> Any:
    #         """
    #         Execute a parameterized query.

    #         Args:
    #             query: SQL query string with parameter placeholders
    #             params: Dictionary of parameters for query
    #             timeout: Optional timeout override in seconds

    #         Returns:
    #             Query results

    #         Raises:
    #             QueryError: If query execution fails
    #             TimeoutError: If query times out
    #         """
    #         if not self._connected:
    raise ConnectionError("Not connected to SQLite", error_code = 6005)

    #         # Validate query
    #         if not self._validate_query(query):
    raise QueryError(f"Invalid query detected: {query}", error_code = 6006)

    #         # Sanitize parameters
    #         sanitized_params = self._sanitize_params(params) if params else {}

    #         try:
    #             with self._get_cursor() as cursor:
    start_time = time.time()

    #                 # Execute with timeout
                    cursor.execute(query, sanitized_params)

    #                 # Get results
    #                 if cursor.description:
    #                     columns = [desc[0] for desc in cursor.description]
    results = [
    #                         dict(zip(columns, row)) for row in cursor.fetchall()
    #                     ]
    #                 else:
    results = cursor.fetchall()

    execution_time = math.subtract(time.time(), start_time)

    #                 # Log slow queries
    #                 if execution_time > 1.0:  # 1 second threshold
                        self.logger.warning(
                            f"Slow query ({execution_time:.2f}s): {query[:100]}..."
    #                     )

    #                 return results
    #         except sqlite3.Error as e:
    error_msg = f"Query execution failed: {str(e)}"
                self.logger.error(error_msg)
    raise QueryError(error_msg, error_code = 6007)
    #         except Exception as e:
    error_msg = f"Unexpected query error: {str(e)}"
                self.logger.error(error_msg)
    raise QueryError(error_msg, error_code = 6008)

    #     def execute_batch(
    #         self,
    #         queries: List[tuple[str, Optional[Dict[str, Any]]]]
    #     ) -> List[Any]:
    #         """
    #         Execute multiple queries in a transaction.

    #         Args:
                queries: List of (query, params) tuples

    #         Returns:
    #             List of results

    #         Raises:
    #             TransactionError: If transaction fails
    #         """
    #         if not self._connected:
    raise ConnectionError("Not connected to SQLite", error_code = 6009)

    results = []

    #         try:
    #             with self.transaction():
    #                 for query, params in queries:
    #                     sanitized_params = self._sanitize_params(params) if params else {}
    result = self.execute_query(query, sanitized_params)
                        results.append(result)

    #             return results
    #         except Exception as e:
    error_msg = f"Batch execution failed: {str(e)}"
                self.logger.error(error_msg)
    raise TransactionError(error_msg, error_code = 6010)

    #     def insert(self, table: str, data: Dict[str, Any]) -> int:
    #         """
    #         Insert data into a table.

    #         Args:
    #             table: Target table name
    #             data: Dictionary of column-value pairs

    #         Returns:
    #             ID of inserted row

    #         Raises:
    #             QueryError: If insertion fails
    #         """
    #         if not self._connected:
    raise ConnectionError("Not connected to SQLite", error_code = 6011)

    #         try:
    #             with self._get_cursor() as cursor:
    #                 # Build INSERT query
    columns = ', '.join(data.keys())
    placeholders = ', '.join(['?'] * len(data))

    query = f"""
                        INSERT INTO {table} ({columns})
                        VALUES ({placeholders})
    #                 """

                    cursor.execute(query, list(data.values()))
    row_id = cursor.lastrowid

    #                 self.logger.debug(f"Inserted row into {table} with ID: {row_id}")
    #                 return row_id
    #         except sqlite3.Error as e:
    error_msg = f"Insert operation failed: {str(e)}"
                self.logger.error(error_msg)
    raise QueryError(error_msg, error_code = 6012)

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
    #             data: Dictionary of column-value pairs to update
    #             conditions: Dictionary of conditions for WHERE clause

    #         Returns:
    #             Number of rows affected

    #         Raises:
    #             QueryError: If update fails
    #         """
    #         if not self._connected:
    raise ConnectionError("Not connected to SQLite", error_code = 6013)

    #         try:
    #             with self._get_cursor() as cursor:
    #                 # Build SET clause
    #                 set_clause = ', '.join([f"{key} = ?" for key in data.keys()])

    #                 # Build WHERE clause
    where_clause = ""
    #                 if conditions:
    where_conditions = [
    #                         f"{key} = ?" for key in conditions.keys()
    #                     ]
    where_clause = " WHERE " + " AND ".join(where_conditions)

    #                 # Build UPDATE query
    query = f"""
    #                     UPDATE {table}
    #                     SET {set_clause}
    #                     {where_clause}
    #                 """

                    cursor.execute(query, list(data.values()) + list(conditions.values()))
    affected_rows = cursor.rowcount

                    self.logger.debug(f"Updated {affected_rows} rows in {table}")
    #                 return affected_rows
    #         except sqlite3.Error as e:
    error_msg = f"Update operation failed: {str(e)}"
                self.logger.error(error_msg)
    raise QueryError(error_msg, error_code = 6014)

    #     def delete(self, table: str, conditions: Dict[str, Any]) -> int:
    #         """
    #         Delete data from a table.

    #         Args:
    #             table: Target table name
    #             conditions: Dictionary of conditions for WHERE clause

    #         Returns:
    #             Number of rows affected

    #         Raises:
    #             QueryError: If deletion fails
    #         """
    #         if not self._connected:
    raise ConnectionError("Not connected to SQLite", error_code = 6015)

    #         try:
    #             with self._get_cursor() as cursor:
    #                 # Build WHERE clause
    where_clause = ""
    #                 if conditions:
    where_conditions = [
    #                         f"{key} = ?" for key in conditions.keys()
    #                     ]
    where_clause = " WHERE " + " AND ".join(where_conditions)

    #                 # Build DELETE query
    query = f"DELETE FROM {table}{where_clause}"

                    cursor.execute(query, list(conditions.values()))
    affected_rows = cursor.rowcount

                    self.logger.debug(f"Deleted {affected_rows} rows from {table}")
    #                 return affected_rows
    #         except sqlite3.Error as e:
    error_msg = f"Delete operation failed: {str(e)}"
                self.logger.error(error_msg)
    raise QueryError(error_msg, error_code = 6016)

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
    #             QueryError: If selection fails
    #         """
    #         if not self._connected:
    raise ConnectionError("Not connected to SQLite", error_code = 6017)

    #         try:
    #             with self._get_cursor() as cursor:
    #                 # Build column clause
    column_clause = "*"
    #                 if columns:
    column_clause = ', '.join(columns)

    #                 # Build WHERE clause
    where_clause = ""
    #                 if conditions:
    where_conditions = [
    #                         f"{key} = ?" for key in conditions.keys()
    #                     ]
    where_clause = " WHERE " + " AND ".join(where_conditions)

    #                 # Build LIMIT clause
    limit_clause = ""
    #                 if limit:
    limit_clause = f" LIMIT {limit}"

    #                 # Build SELECT query
    query = f"""
    #                     SELECT {column_clause}
    #                     FROM {table}{where_clause}{limit_clause}
    #                 """

    #                 cursor.execute(query, list(conditions.values()) if conditions else [])

    #                 if cursor.description:
    #                     columns = [desc[0] for desc in cursor.description]
    results = [
    #                         dict(zip(columns, row)) for row in cursor.fetchall()
    #                     ]
    #                 else:
    results = cursor.fetchall()

                    self.logger.debug(f"Selected {len(results)} rows from {table}")
    #                 return results
    #         except sqlite3.Error as e:
    error_msg = f"Select operation failed: {str(e)}"
                self.logger.error(error_msg)
    raise QueryError(error_msg, error_code = 6018)

    #     def table_exists(self, table_name: str) -> bool:
    #         """
    #         Check if a table exists.

    #         Args:
    #             table_name: Name of table to check

    #         Returns:
    #             True if table exists, False otherwise

    #         Raises:
    #             QueryError: If check fails
    #         """
    #         if not self._connected:
    raise ConnectionError("Not connected to SQLite", error_code = 6019)

    #         try:
    #             with self._get_cursor() as cursor:
                    cursor.execute("""
    #                     SELECT name FROM sqlite_master
    WHERE type = 'table' AND name=?
    #                 """, [table_name])

    result = cursor.fetchone()
    exists = result is not None

                    self.logger.debug(f"Table {table_name} exists: {exists}")
    #                 return exists
    #         except sqlite3.Error as e:
    error_msg = f"Table existence check failed: {str(e)}"
                self.logger.error(error_msg)
    raise QueryError(error_msg, error_code = 6020)

    #     def create_table(self, table_name: str, schema: Dict[str, str]) -> None:
    #         """
    #         Create a table with the given schema.

    #         Args:
    #             table_name: Name of table to create
    #             schema: Dictionary mapping column names to SQL types

    #         Raises:
    #             QueryError: If table creation fails
    #         """
    #         if not self._connected:
    raise ConnectionError("Not connected to SQLite", error_code = 6021)

    #         try:
    #             with self._get_cursor() as cursor:
    #                 # Build column definitions
    columns = []
    #                 for column_name, column_type in schema.items():
                        columns.append(f"{column_name} {column_type}")

    columns_str = ', '.join(columns)

    #                 # Build CREATE TABLE query
    query = f"""
                        CREATE TABLE {table_name} (
    #                         {columns_str}
    #                     )
    #                 """

                    cursor.execute(query)
                    self.logger.info(f"Created table: {table_name}")
    #         except sqlite3.Error as e:
    error_msg = f"Table creation failed: {str(e)}"
                self.logger.error(error_msg)
    raise QueryError(error_msg, error_code = 6022)

    #     def drop_table(self, table_name: str) -> None:
    #         """
    #         Drop a table from the database.

    #         Args:
    #             table_name: Name of table to drop

    #         Raises:
    #             QueryError: If table dropping fails
    #         """
    #         if not self._connected:
    raise ConnectionError("Not connected to SQLite", error_code = 6023)

    #         try:
    #             with self._get_cursor() as cursor:
                    cursor.execute(f"DROP TABLE {table_name}")
                    self.logger.info(f"Dropped table: {table_name}")
    #         except sqlite3.Error as e:
    error_msg = f"Table dropping failed: {str(e)}"
                self.logger.error(error_msg)
    raise QueryError(error_msg, error_code = 6024)

    #     def get_table_schema(self, table_name: str) -> Dict[str, str]:
    #         """
    #         Get the schema of a table.

    #         Args:
    #             table_name: Name of table

    #         Returns:
    #             Dictionary mapping column names to their SQL types

    #         Raises:
    #             QueryError: If schema retrieval fails
    #         """
    #         if not self._connected:
    raise ConnectionError("Not connected to SQLite", error_code = 6025)

    #         try:
    #             with self._get_cursor() as cursor:
                    cursor.execute(f"PRAGMA table_info({table_name})")

    schema = {}
    #                 for row in cursor.fetchall():
    schema[row[1]] = row[2]  # Map type to column name

    #                 self.logger.debug(f"Retrieved schema for {table_name}: {schema}")
    #                 return schema
    #         except sqlite3.Error as e:
    error_msg = f"Schema retrieval failed: {str(e)}"
                self.logger.error(error_msg)
    raise QueryError(error_msg, error_code = 6026)

    #     def backup_database(self, backup_path: str) -> None:
    #         """
    #         Create a backup of the current database.

    #         Args:
    #             backup_path: Path where to store the backup

    #         Raises:
    #             DatabaseError: If backup fails
    #         """
    #         if not self._connected:
    raise ConnectionError("Not connected to SQLite", error_code = 6027)

    #         try:
    #             # Use SQLite backup API
    #             with self._get_cursor() as cursor:
                    cursor.execute(f"VACUUM INTO '{backup_path}'")
                    self.logger.info(f"Database backed up to: {backup_path}")
    #         except sqlite3.Error as e:
    error_msg = f"Backup failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6028)

    #     def restore_database(self, backup_path: str) -> None:
    #         """
    #         Restore a database from a backup.

    #         Args:
    #             backup_path: Path to the backup file

    #         Raises:
    #             DatabaseError: If restore fails
    #         """
    #         if not self._connected:
    raise ConnectionError("Not connected to SQLite", error_code = 6029)

    #         try:
    #             # Close current connection
                self.disconnect()

    #             # Restore from backup
    self._connection = sqlite3.connect(backup_path, timeout=self.config.timeout)
    self._connection_id = str(uuid.uuid4())
    self._connected = True

                self.logger.info(f"Database restored from: {backup_path}")
    #         except sqlite3.Error as e:
    error_msg = f"Restore failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6030)

    #     def optimize_database(self) -> None:
    #         """
    #         Optimize the database for better performance.

    #         Raises:
    #             DatabaseError: If optimization fails
    #         """
    #         if not self._connected:
    raise ConnectionError("Not connected to SQLite", error_code = 6031)

    #         try:
    #             with self._get_cursor() as cursor:
    #                 # Run VACUUM with ANALYZE for optimization
                    cursor.execute("VACUUM")
                    cursor.execute("ANALYZE")
    #                 self.logger.info("Database optimized with VACUUM and ANALYZE")
    #         except sqlite3.Error as e:
    error_msg = f"Database optimization failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6032)

    #     def get_database_stats(self) -> Dict[str, Any]:
    #         """
    #         Get database statistics.

    #         Returns:
    #             Dictionary containing database statistics

    #         Raises:
    #             DatabaseError: If stats retrieval fails
    #         """
    #         if not self._connected:
    raise ConnectionError("Not connected to SQLite", error_code = 6033)

    #         try:
    #             with self._get_cursor() as cursor:
    #                 # Get database page count
                    cursor.execute("PRAGMA page_count")
    page_count_result = cursor.fetchone()

    #                 # Get database size
                    cursor.execute("PRAGMA page_size")
    page_size_result = cursor.fetchone()

    #                 # Get table count
                    cursor.execute("""
                        SELECT COUNT(*) FROM sqlite_master
    WHERE type = 'table'
    #                 """)
    table_count_result = cursor.fetchone()

    #                 # Calculate size
    #                 if page_count_result and page_size_result:
    total_pages = page_count_result[0]
    page_size = page_size_result[0]
    db_size = math.multiply(total_pages, page_size)
    #                 else:
    db_size = 0

    stats = {
    #                     'backend': 'sqlite',
    #                     'database': self.config.database,
    #                     'connection_id': self._connection_id,
    #                     'database_size': db_size,
    #                     'table_count': table_count_result[0] if table_count_result else 0,
    #                     'page_count': page_count_result[0] if page_count_result else 0,
    #                     'page_size': page_size_result[0] if page_size_result else 0
    #                 }

    #                 return stats
    #         except sqlite3.Error as e:
    error_msg = f"Stats retrieval failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6034)

    #     def health_check(self) -> bool:
    #         """
    #         Check if the database is healthy and accessible.

    #         Returns:
    #             True if database is healthy, False otherwise

    #         Raises:
    #             DatabaseError: If health check fails
    #         """
    #         if not self._connected:
    #             return False

    #         try:
    #             with self._get_cursor() as cursor:
                    cursor.execute("SELECT 1")
    result = cursor.fetchone()

    #                 # Check if we got a result
    is_healthy = result is not None

    #                 self.logger.debug(f"Database health check: {'healthy' if is_healthy else 'unhealthy'}")
    #                 return is_healthy
    #         except sqlite3.Error as e:
                self.logger.error(f"Health check failed: {str(e)}")
    #             return False

    #     @contextmanager
    #     def transaction(self):
    #         """
    #         Context manager for database transactions.

    #         Yields:
    #             Transaction context
    #         """
    #         if not self._connected:
    raise ConnectionError("Not connected to SQLite", error_code = 6035)

    #         try:
    #             with self._get_cursor() as cursor:
                    cursor.execute("BEGIN")
                    yield TransactionContext(cursor, self)
                    cursor.execute("COMMIT")
    #         except sqlite3.Error as e:
    #             try:
                    cursor.execute("ROLLBACK")
    #             except:
    #                 pass
    raise TransactionError(f"Transaction failed: {str(e)}", error_code = 6036)

    #     def _get_cursor(self):
    #         """Get a database cursor."""
    #         if not self._cursor or self._cursor.closed:
    self._cursor = self._connection.cursor()
    #         return self._cursor


class TransactionContext
    #     """
    #     Context for SQLite transactions.
    #     """

    #     def __init__(self, cursor, backend):
    self.cursor = cursor
    self.backend = backend

    #     def __enter__(self):
    #         return self

    #     def __exit__(self, exc_type, exc_val, exc_tb):
    #         if exc_type is not None:
    #             try:
                    self.cursor.execute("ROLLBACK")
    #             except:
    #                 pass
                self.backend.logger.error("Transaction rolled back")