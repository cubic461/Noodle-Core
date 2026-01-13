# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# SQLite Database Backend
# -----------------------
# This module provides a SQLite database backend implementation for persistent storage.
# """

import json
import sqlite3
import threading
import time
import contextlib.contextmanager
import dataclasses.dataclass,
import pathlib.Path
import typing.Any,

import .base.BackendConfig,


class SQLiteBackendError(DatabaseError)
    #     pass


# @dataclass
class SQLiteTableInfo
    #     """Information about a SQLite table"""

    #     name: str
    #     schema: Dict[str, str]
    #     row_count: int
    #     created_at: float
    #     updated_at: float


class SQLiteBackend(DatabaseBackend)
    #     """
    #     SQLite database backend implementation.
    #     This backend uses SQLite for persistent storage.
    #     """

    #     def __init__(self, config: BackendConfig):
    #         """
    #         Initialize the SQLite backend.

    #         Args:
    #             config: Backend configuration
    #         """
            super().__init__(config)
    self._connection: Optional[sqlite3.Connection] = None
    self._lock = threading.RLock()
    self._database_path = config.connection_string

    #         # Ensure database directory exists
    db_path = Path(self._database_path)
    db_path.parent.mkdir(parents = True, exist_ok=True)

    #     def connect(self) -> None:
    #         """
    #         Establish connection to the SQLite database.
    #         """
    #         with self._lock:
    #             if self._is_connected:
    #                 return

    #             try:
    #                 # Connect to SQLite database
    self._connection = sqlite3.connect(
    #                     self._database_path,
    timeout = self.config.timeout,
    check_same_thread = False,
    #                 )

    #                 # Enable foreign key constraints
    self._connection.execute("PRAGMA foreign_keys = ON")

    #                 # Enable WAL mode for better performance
    self._connection.execute("PRAGMA journal_mode = WAL")

    #                 # Enable synchronous mode for data safety
    self._connection.execute("PRAGMA synchronous = NORMAL")

    #                 # Set busy timeout
                    self._connection.execute(
    f"PRAGMA busy_timeout = {int(self.config.timeout * 1000)}"
    #                 )

    #                 # Enable recursive triggers
    self._connection.execute("PRAGMA recursive_triggers = ON")

    self._is_connected = True

    #                 # Initialize connection pool (simulated for SQLite)
    #                 for _ in range(self.config.max_connections):
                        self._connection_pool.append({"available": True})

    #             except sqlite3.Error as e:
                    raise DatabaseError(f"Failed to connect to SQLite database: {e}") from e

    #     def disconnect(self) -> None:
    #         """
    #         Close connection to the SQLite database.
    #         """
    #         with self._lock:
    #             if not self._is_connected:
    #                 return

    #             try:
    #                 if self._connection:
                        self._connection.close()
    self._connection = None

    self._is_connected = False
                    self._connection_pool.clear()

    #             except sqlite3.Error as e:
                    raise DatabaseError(
    #                     f"Failed to disconnect from SQLite database: {e}"
    #                 ) from e

    #     def execute_query(self, query: str, params: Optional[Dict[str, Any]] = None) -> Any:
    #         """
    #         Execute a raw SQL query.

    #         Args:
    #             query: SQL query string
    #             params: Optional parameters for the query

    #         Returns:
    #             QueryResult containing the results
    #         """
    #         with self._lock:
    #             if not self._is_connected:
                    raise DatabaseError("Database not connected")

    #             if not self._connection:
                    raise DatabaseError("No database connection available")

    #             try:
    #                 # Prepare parameters
    sql_params = []
    #                 if params:
    #                     for key, value in params.items():
    #                         # Convert Python types to SQLite-compatible types
    #                         if isinstance(value, dict):
                                sql_params.append(json.dumps(value))
    #                         elif isinstance(value, list):
                                sql_params.append(json.dumps(value))
    #                         else:
                                sql_params.append(value)

    #                 # Execute query
    cursor = self._connection.cursor()
    #                 if sql_params:
                        cursor.execute(query, sql_params)
    #                 else:
                        cursor.execute(query)

    #                 # Handle different query types
    #                 if query.strip().upper().startswith("SELECT"):
    #                     # Fetch results
    #                     columns = [description[0] for description in cursor.description]
    rows = cursor.fetchall()

    #                     # Convert rows to dictionaries
    data = []
    #                     for row in rows:
                            data.append(dict(zip(columns, row)))

                        return {"data": data, "total_rows": len(data), "columns": columns}
    #                 else:
    #                     # For non-SELECT queries, return affected rows
                        self._connection.commit()
    #                     return {
    #                         "affected_rows": cursor.rowcount,
    #                         "last_rowid": cursor.lastrowid,
    #                     }

    #             except sqlite3.Error as e:
    #                 # Rollback on error
    #                 if self._connection:
                        self._connection.rollback()
                    raise DatabaseError(f"SQL query failed: {e}") from e

    #     def insert(self, table: str, data: Dict[str, Any]) -> int:
    #         """
    #         Insert data into a table.

    #         Args:
    #             table: Target table name
    #             data: Dictionary of column-value pairs to insert

    #         Returns:
    #             ID of the inserted row (if applicable)
    #         """
    #         with self._lock:
    #             if not self._is_connected:
                    raise DatabaseError("Database not connected")

    #             if not self._connection:
                    raise DatabaseError("No database connection available")

    #             try:
    #                 # Validate table exists
    #                 if not self.table_exists(table):
                        raise DatabaseError(f"Table '{table}' not found")

    #                 # Prepare columns and values
    columns = list(data.keys())
    #                 placeholders = ["?" for _ in columns]
    values = []

    #                 for value in data.values():
    #                     # Convert Python types to SQLite-compatible types
    #                     if isinstance(value, dict):
                            values.append(json.dumps(value))
    #                     elif isinstance(value, list):
                            values.append(json.dumps(value))
    #                     else:
                            values.append(value)

    #                 # Build and execute INSERT statement
    query = f"INSERT INTO {table} ({', '.join(columns)}) VALUES ({', '.join(placeholders)})"
    cursor = self._connection.cursor()
                    cursor.execute(query, values)
                    self._connection.commit()

    #                 return cursor.lastrowid or 0

    #             except sqlite3.Error as e:
    #                 if self._connection:
                        self._connection.rollback()
                    raise DatabaseError(f"Insert failed: {e}") from e

    #     def update(
    #         self, table: str, data: Dict[str, Any], conditions: Dict[str, Any]
    #     ) -> int:
    #         """
    #         Update data in a table.

    #         Args:
    #             table: Target table name
    #             data: Dictionary of column-value pairs to update
    #             conditions: Dictionary of conditions to determine which rows to update

    #         Returns:
    #             Number of rows affected
    #         """
    #         with self._lock:
    #             if not self._is_connected:
                    raise DatabaseError("Database not connected")

    #             if not self._connection:
                    raise DatabaseError("No database connection available")

    #             try:
    #                 # Validate table exists
    #                 if not self.table_exists(table):
                        raise DatabaseError(f"Table '{table}' not found")

    #                 # Build SET clause
    set_clauses = []
    values = []

    #                 for column, value in data.items():
    set_clauses.append(f"{column} = ?")
    #                     # Convert Python types to SQLite-compatible types
    #                     if isinstance(value, dict):
                            values.append(json.dumps(value))
    #                     elif isinstance(value, list):
                            values.append(json.dumps(value))
    #                     else:
                            values.append(value)

    #                 # Build WHERE clause
    where_clauses = []
    #                 for column, value in conditions.items():
    where_clauses.append(f"{column} = ?")
    #                     # Convert Python types to SQLite-compatible types
    #                     if isinstance(value, dict):
                            values.append(json.dumps(value))
    #                     elif isinstance(value, list):
                            values.append(json.dumps(value))
    #                     else:
                            values.append(value)

    #                 # Build and execute UPDATE statement
    query = f"UPDATE {table} SET {', '.join(set_clauses)}"
    #                 if where_clauses:
    query + = f" WHERE {' AND '.join(where_clauses)}"

    cursor = self._connection.cursor()
                    cursor.execute(query, values)
                    self._connection.commit()

    #                 return cursor.rowcount

    #             except sqlite3.Error as e:
    #                 if self._connection:
                        self._connection.rollback()
                    raise DatabaseError(f"Update failed: {e}") from e

    #     def delete(self, table: str, conditions: Dict[str, Any]) -> int:
    #         """
    #         Delete data from a table.

    #         Args:
    #             table: Target table name
    #             conditions: Dictionary of conditions to determine which rows to delete

    #         Returns:
    #             Number of rows affected
    #         """
    #         with self._lock:
    #             if not self._is_connected:
                    raise DatabaseError("Database not connected")

    #             if not self._connection:
                    raise DatabaseError("No database connection available")

    #             try:
    #                 # Validate table exists
    #                 if not self.table_exists(table):
                        raise DatabaseError(f"Table '{table}' not found")

    #                 # Build WHERE clause
    where_clauses = []
    values = []

    #                 for column, value in conditions.items():
    where_clauses.append(f"{column} = ?")
    #                     # Convert Python types to SQLite-compatible types
    #                     if isinstance(value, dict):
                            values.append(json.dumps(value))
    #                     elif isinstance(value, list):
                            values.append(json.dumps(value))
    #                     else:
                            values.append(value)

    #                 # Build and execute DELETE statement
    query = f"DELETE FROM {table}"
    #                 if where_clauses:
    query + = f" WHERE {' AND '.join(where_clauses)}"

    cursor = self._connection.cursor()
                    cursor.execute(query, values)
                    self._connection.commit()

    #                 return cursor.rowcount

    #             except sqlite3.Error as e:
    #                 if self._connection:
                        self._connection.rollback()
                    raise DatabaseError(f"Delete failed: {e}") from e

    #     def select(
    #         self,
    #         table: str,
    columns: Optional[List[str]] = None,
    conditions: Optional[Dict[str, Any]] = None,
    #     ) -> Any:
    #         """
    #         Select data from a table.

    #         Args:
    #             table: Target table name
                columns: Optional list of column names to select (defaults to all)
    #             conditions: Optional dictionary of conditions for WHERE clause

    #         Returns:
    #             QueryResult containing the selected data
    #         """
    #         with self._lock:
    #             if not self._is_connected:
                    raise DatabaseError("Database not connected")

    #             if not self._connection:
                    raise DatabaseError("No database connection available")

    #             try:
    #                 # Validate table exists
    #                 if not self.table_exists(table):
                        raise DatabaseError(f"Table '{table}' not found")

    #                 # Build SELECT statement
    #                 if columns:
    select_clause = f"SELECT {', '.join(columns)}"
    #                 else:
    select_clause = "SELECT *"

    query = f"{select_clause} FROM {table}"

    #                 # Build WHERE clause if conditions provided
    #                 if conditions:
    where_clauses = []
    values = []

    #                     for column, value in conditions.items():
    where_clauses.append(f"{column} = ?")
    #                         # Convert Python types to SQLite-compatible types
    #                         if isinstance(value, dict):
                                values.append(json.dumps(value))
    #                         elif isinstance(value, list):
                                values.append(json.dumps(value))
    #                         else:
                                values.append(value)

    query + = f" WHERE {' AND '.join(where_clauses)}"

    #                 # Execute query
    cursor = self._connection.cursor()
    #                 if conditions:
                        cursor.execute(query, values)
    #                 else:
                        cursor.execute(query)

    #                 # Fetch results
    #                 if columns:
    selected_columns = columns
    #                 else:
    selected_columns = [
    #                         description[0] for description in cursor.description
    #                     ]

    rows = cursor.fetchall()
    data = []

    #                 for row in rows:
    #                     # Convert row to dictionary
    row_dict = dict(zip(selected_columns, row))

    #                     # Parse JSON fields back to Python objects
    #                     for column in selected_columns:
    #                         if column in row_dict and isinstance(row_dict[column], str):
    #                             try:
    #                                 # Try to parse as JSON
    parsed = json.loads(row_dict[column])
    row_dict[column] = parsed
                                except (json.JSONDecodeError, TypeError):
    #                                 # Not JSON, keep as string
    #                                 pass

                        data.append(row_dict)

    #                 return {
    #                     "data": data,
                        "total_rows": len(data),
    #                     "table": table,
    #                     "columns": selected_columns,
    #                 }

    #             except sqlite3.Error as e:
                    raise DatabaseError(f"Select failed: {e}") from e

    #     def begin_transaction(self) -> Any:
    #         """
    #         Begin a database transaction.

    #         Returns:
                Transaction object (SQLite connection)
    #         """
    #         with self._lock:
    #             if not self._is_connected:
                    raise DatabaseError("Database not connected")

    #             if not self._connection:
                    raise DatabaseError("No database connection available")

    #             try:
    #                 # Begin transaction
                    self._connection.execute("BEGIN TRANSACTION")
    #                 return self._connection

    #             except sqlite3.Error as e:
                    raise DatabaseError(f"Failed to begin transaction: {e}") from e

    #     def commit_transaction(self, transaction: Any) -> None:
    #         """
    #         Commit a database transaction.

    #         Args:
                transaction: Transaction object (SQLite connection)
    #         """
    #         with self._lock:
    #             if not self._is_connected:
                    raise DatabaseError("Database not connected")

    #             if not self._connection:
                    raise DatabaseError("No database connection available")

    #             try:
    #                 # Commit transaction
                    self._connection.execute("COMMIT")

    #             except sqlite3.Error as e:
                    raise DatabaseError(f"Failed to commit transaction: {e}") from e

    #     def rollback_transaction(self, transaction: Any) -> None:
    #         """
    #         Roll back a database transaction.

    #         Args:
                transaction: Transaction object (SQLite connection)
    #         """
    #         with self._lock:
    #             if not self._is_connected:
                    raise DatabaseError("Database not connected")

    #             if not self._connection:
                    raise DatabaseError("No database connection available")

    #             try:
    #                 # Roll back transaction
                    self._connection.execute("ROLLBACK")

    #             except sqlite3.Error as e:
                    raise DatabaseError(f"Failed to rollback transaction: {e}") from e

    #     def table_exists(self, table_name: str) -> bool:
    #         """
    #         Check if a table exists in the database.

    #         Args:
    #             table_name: Name of the table to check

    #         Returns:
    #             True if table exists, False otherwise
    #         """
    #         with self._lock:
    #             if not self._is_connected:
                    raise DatabaseError("Database not connected")

    #             if not self._connection:
                    raise DatabaseError("No database connection available")

    #             try:
    cursor = self._connection.cursor()
                    cursor.execute(
    f"SELECT name FROM sqlite_master WHERE type = 'table' AND name='{table_name}'"
    #                 )
    result = cursor.fetchone()
    #                 return result is not None

    #             except sqlite3.Error as e:
                    raise DatabaseError(f"Failed to check table existence: {e}") from e

    #     def create_table(self, table_name: str, schema: Dict[str, str]) -> None:
    #         """
    #         Create a table with the given schema.

    #         Args:
    #             table_name: Name of the table to create
    #             schema: Dictionary mapping column names to their SQL types
    #         """
    #         with self._lock:
    #             if not self._is_connected:
                    raise DatabaseError("Database not connected")

    #             if not self._connection:
                    raise DatabaseError("No database connection available")

    #             try:
    #                 # Validate schema
    #                 if not schema:
                        raise DatabaseError("Schema cannot be empty")

    #                 # Build CREATE TABLE statement
    column_definitions = []
    #                 for column_name, column_type in schema.items():
                        column_definitions.append(f"{column_name} {column_type}")

    query = f"CREATE TABLE {table_name} ({', '.join(column_definitions)})"

    cursor = self._connection.cursor()
                    cursor.execute(query)
                    self._connection.commit()

    #             except sqlite3.Error as e:
    #                 if self._connection:
                        self._connection.rollback()
                    raise DatabaseError(f"Failed to create table: {e}") from e

    #     def drop_table(self, table_name: str) -> None:
    #         """
    #         Drop a table from the database.

    #         Args:
    #             table_name: Name of the table to drop
    #         """
    #         with self._lock:
    #             if not self._is_connected:
                    raise DatabaseError("Database not connected")

    #             if not self._connection:
                    raise DatabaseError("No database connection available")

    #             try:
    #                 # Build DROP TABLE statement
    query = f"DROP TABLE IF EXISTS {table_name}"

    cursor = self._connection.cursor()
                    cursor.execute(query)
                    self._connection.commit()

    #             except sqlite3.Error as e:
    #                 if self._connection:
                        self._connection.rollback()
                    raise DatabaseError(f"Failed to drop table: {e}") from e

    #     def get_table_schema(self, table_name: str) -> Dict[str, str]:
    #         """
    #         Get the schema of a table.

    #         Args:
    #             table_name: Name of the table

    #         Returns:
    #             Dictionary mapping column names to their SQL types
    #         """
    #         with self._lock:
    #             if not self._is_connected:
                    raise DatabaseError("Database not connected")

    #             if not self._connection:
                    raise DatabaseError("No database connection available")

    #             try:
    cursor = self._connection.cursor()
                    cursor.execute(f"PRAGMA table_info({table_name})")
    columns_info = cursor.fetchall()

    schema = {}
    #                 for column_info in columns_info:
    column_name = column_info[1]
    column_type = column_info[2]
    schema[column_name] = column_type

    #                 return schema

    #             except sqlite3.Error as e:
                    raise DatabaseError(f"Failed to get table schema: {e}") from e

    #     def get_table_info(self, table_name: str) -> Dict[str, Any]:
    #         """
    #         Get information about a table.

    #         Args:
    #             table_name: Name of the table

    #         Returns:
    #             Dictionary containing table information
    #         """
    #         with self._lock:
    #             if not self._is_connected:
                    raise DatabaseError("Database not connected")

    #             if not self._connection:
                    raise DatabaseError("No database connection available")

    #             try:
    #                 # Get table schema
    schema = self.get_table_schema(table_name)

    #                 # Get row count
    cursor = self._connection.cursor()
                    cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
    row_count = cursor.fetchone()[0]

                    # Get table creation time (approximate)
                    cursor.execute(
    f"SELECT name, sql FROM sqlite_master WHERE type = 'table' AND name='{table_name}'"
    #                 )
    table_info = cursor.fetchone()

    created_at = time.time()
    #                 if table_info:
                        # Extract creation time from SQL (basic approximation)
    created_at = time.time()

    #                 return {
    #                     "name": table_name,
    #                     "schema": schema,
    #                     "row_count": row_count,
    #                     "created_at": created_at,
                        "updated_at": time.time(),
    #                 }

    #             except sqlite3.Error as e:
                    raise DatabaseError(f"Failed to get table info: {e}") from e

    #     def backup_database(self, backup_path: str) -> None:
    #         """
    #         Create a backup of the database.

    #         Args:
    #             backup_path: Path where to store the backup
    #         """
    #         with self._lock:
    #             if not self._is_connected:
                    raise DatabaseError("Database not connected")

    #             if not self._connection:
                    raise DatabaseError("No database connection available")

    #             try:
    #                 # Ensure backup directory exists
    backup_dir = Path(backup_path)
    backup_dir.parent.mkdir(parents = True, exist_ok=True)

    #                 # Create backup using SQLite backup API
    backup_conn = sqlite3.connect(backup_path)

    #                 with self._connection:
                        backup_conn.backup(backup_conn)

                    backup_conn.close()

    #             except sqlite3.Error as e:
                    raise DatabaseError(f"Failed to create database backup: {e}") from e

    #     def restore_database(self, backup_path: str) -> None:
    #         """
    #         Restore a database from a backup.

    #         Args:
    #             backup_path: Path to the backup file
    #         """
    #         with self._lock:
    #             if not self._is_connected:
                    raise DatabaseError("Database not connected")

    #             if not self._connection:
                    raise DatabaseError("No database connection available")

    #             try:
    #                 # Ensure backup file exists
    #                 if not Path(backup_path).exists():
                        raise DatabaseError(f"Backup file '{backup_path}' not found")

    #                 # Create backup of current database
    temp_backup = f"{self._database_path}.backup.{int(time.time())}"
                    self.backup_database(temp_backup)

    #                 # Restore from backup
    backup_conn = sqlite3.connect(backup_path)

    #                 with backup_conn:
                        backup_conn.backup(self._connection)

                    backup_conn.close()

    #             except sqlite3.Error as e:
    #                 # Try to restore from temp backup if restore fails
    #                 try:
    #                     if Path(temp_backup).exists():
    temp_conn = sqlite3.connect(temp_backup)
    #                         with temp_conn:
                                temp_conn.backup(self._connection)
                            temp_conn.close()
    #                 except:
    #                     pass

                    raise DatabaseError(
    #                     f"Failed to restore database from backup: {e}"
    #                 ) from e

    #     def optimize_database(self) -> None:
    #         """
    #         Optimize the database for better performance.
    #         """
    #         with self._lock:
    #             if not self._is_connected:
                    raise DatabaseError("Database not connected")

    #             if not self._connection:
                    raise DatabaseError("No database connection available")

    #             try:
    #                 # Run VACUUM to rebuild database and free space
                    self._connection.execute("VACUUM")

    #                 # Analyze database to update statistics
                    self._connection.execute("ANALYZE")

    #                 # Optimize database
                    self._connection.execute("PRAGMA optimize")

                    self._connection.commit()

    #             except sqlite3.Error as e:
    #                 if self._connection:
                        self._connection.rollback()
                    raise DatabaseError(f"Failed to optimize database: {e}") from e

    #     def get_database_stats(self) -> Dict[str, Any]:
    #         """
    #         Get database statistics.

    #         Returns:
    #             Dictionary containing database statistics
    #         """
    #         with self._lock:
    #             if not self._is_connected:
                    raise DatabaseError("Database not connected")

    #             if not self._connection:
                    raise DatabaseError("No database connection available")

    #             try:
    #                 # Get database file info
    db_path = Path(self._database_path)
    #                 file_size = db_path.stat().st_size if db_path.exists() else 0

    #                 # Get table count
    cursor = self._connection.cursor()
    cursor.execute("SELECT COUNT(*) FROM sqlite_master WHERE type = 'table'")
    table_count = cursor.fetchone()[0]

    #                 # Get total row count
                    cursor.execute(
    "SELECT SUM((SELECT COUNT(*) FROM sqlite_master WHERE type = 'table'))"
    #                 )
    total_rows = cursor.fetchone()[0] or 0

    #                 # Get database version
                    cursor.execute("SELECT sqlite_version()")
    version = cursor.fetchone()[0]

    #                 return {
    #                     "connected": self._is_connected,
    #                     "database_path": self._database_path,
    #                     "file_size_bytes": file_size,
    #                     "table_count": table_count,
    #                     "total_rows": total_rows,
    #                     "sqlite_version": version,
                        "connection_pool": self.get_connection_pool_info(),
    #                 }

    #             except sqlite3.Error as e:
                    raise DatabaseError(f"Failed to get database stats: {e}") from e

    #     def health_check(self) -> bool:
    #         """
    #         Check if the database is healthy and accessible.

    #         Returns:
    #             True if database is healthy, False otherwise
    #         """
    #         with self._lock:
    #             if not self._is_connected:
    #                 return False

    #             if not self._connection:
    #                 return False

    #             try:
    #                 # Try to execute a simple query
    cursor = self._connection.cursor()
                    cursor.execute("SELECT 1")
                    cursor.fetchone()
    #                 return True

    #             except sqlite3.Error:
    #                 return False

    #     def __enter__(self):
    #         """Context manager entry point."""
            self.connect()
    #         return self

    #     def __exit__(self, exc_type, exc_val, exc_tb):
    #         """Context manager exit point."""
            self.disconnect()
