# Converted from Python to NoodleCore
# Original file: src

# """
# DuckDB Database Backend
# -----------------------
# Provides DuckDB backend implementation for analytical workloads in Noodle.
# DuckDB is an in-process SQL OLAP database management system.
# """

import copy
import json
import os
import threading
import time
import pathlib.Path
import typing.Any

import duckdb
import numpy as np
import pandas as pd
import sympy as sp

import noodlecore.database.backends.base.DatabaseBackend
import noodlecore.database.errors.BackendError
import noodlecore.database.mappers.mathematical_object_mapper.(
#     create_mathematical_object_mapper,
# )
import noodlecore.runtime.mathematical_objects.(
#     MathematicalObject,
#     Matrix,
#     ObjectType,
#     Tensor,
# )


class DuckDBBackend(DatabaseBackend)
    #     """DuckDB database backend implementation for analytical workloads."""

    #     def __init__(self, config: Dict[str, Any] = None):""Initialize the DuckDB backend.

    #         Args:
    #             config: Configuration dictionary
                       - database_path: Path to DuckDB database file (default: ':memory:')
                       - read_only: Open in read-only mode (default: False)
                       - memory_limit: Memory limit in MB (default: 'none')
    #                    - threads: Number of threads (default: 0 for auto)
                       - allow_unsigned_extensions: Allow unsigned extensions (default: False)
    #         """
            super().__init__(config or {})

    #         # Set default configuration
    self.database_path = self.config.get("database_path", ":memory:")
    self.read_only = self.config.get("read_only", False)
    self.memory_limit = self.config.get("memory_limit", "none")
    self.threads = self.config.get("threads", 0)  # 0 = auto-detect
    self.allow_unsigned_extensions = self.config.get(
    #             "allow_unsigned_extensions", False
    #         )

    #         # Connection parameters
    self.connection_params = {
    #             "path": self.database_path,
    #             "read_only": self.read_only,
    #             "memory_limit": self.memory_limit,
    #             "threads": self.threads,
    #         }

    #         # Thread-local storage for connections (DuckDB is thread-safe but we manage per-thread)
    self._local = threading.local()

    #         # Thread-local storage for active transactions
    self._local.active_transactions = {}
    self._local.transaction_data = {}

    #         # Performance monitoring
    self._query_times = []
    self._rows_processed = 0
    self._lock = threading.RLock()

    self.is_connected = False

    #     def connect(self) -bool):
    #         """Establish connection to the DuckDB database.

    #         Returns:
    #             True if connection successful, False otherwise
    #         """
    #         try:
    #             if not hasattr(self._local, "connection"):
    self._local.connection = duckdb.connect( * *self.connection_params)

    #                 # Configure DuckDB for optimal analytical performance
                    self._apply_duckdb_optimizations(self._local.connection)

    #                 # Enable unsigned extensions if requested
    #                 if self.allow_unsigned_extensions:
                        self._local.connection.execute("INSTALL httpfs; LOAD httpfs;")

    self.is_connected = True
    #             return True
    #         except Exception as e:
                raise DuckDBBackendError(f"Failed to connect to DuckDB database: {e}")

    #     def _apply_duckdb_optimizations(self, connection):
    #         """Apply DuckDB-specific optimizations for analytical workloads."""
    #         try:
    #             # Set configuration for analytical queries
    connection.execute("SET threads = %d" % self.threads)
    connection.execute("SET memory_limit = '%s'" % self.memory_limit)

    #             # Enable automatic statistics collection
    connection.execute("SET enable_progress_bar = false")

    #             # Configure for columnar storage efficiency
    connection.execute("SET preserve_insertion_order = false")

    #             # Optimize for vectorized execution
    connection.execute("SET enable_object_cache = true")

    #             # Set up for mathematical operations
    #             connection.execute("LOAD spatial")  # If available for geometric ops
                connection.execute("LOAD json")  # For JSON handling

    #             # Create persistent storage optimizations if not in-memory
    #             if self.database_path != ":memory:":
    #                 # Enable WAL mode for better concurrency
    connection.execute("PRAGMA journal_mode = WAL")
    connection.execute("PRAGMA synchronous = NORMAL")

    #         except Exception as e:
    #             # Optimizations are best-effort
                self.logger.warning(f"DuckDB optimization failed: {e}")

    #     def disconnect(self) -bool):
    #         """Close the database connection.

    #         Returns:
    #             True if disconnection successful, False otherwise
    #         """
    #         try:
    #             if hasattr(self._local, "connection"):
                    self._local.connection.close()
                    delattr(self._local, "connection")

    self.is_connected = False
    #             return True
    #         except Exception as e:
                raise DuckDBBackendError(f"Failed to disconnect from DuckDB database: {e}")

    #     def _get_connection(self):
    #         """Get the current connection, creating one if needed."""
    #         if not self.is_connected:
                self.connect()
    #         if not hasattr(self._local, "connection"):
                self.connect()
    #         return self._local.connection

    #     def execute_query(
    #         self,
    #         query: str,
    params: Optional[Dict[str, Any]] = None,
    active_transaction: Optional[Dict[str, Any]] = None,
    #     ) -List[Dict[str, Any]]):
    #         """Execute a raw SQL query.

    #         Args:
    #             query: SQL query string
    #             params: Optional parameters for query (not directly supported in DuckDB, but can be formatted)
    #             active_transaction: Optional transaction context

    #         Returns:
    #             List of result rows as dictionaries
    #         """
    start_time = time.time()
    connection = None
    #         try:
    connection = self._get_connection()

    #             # Use parameterized queries to prevent SQL injection
    #             if params:
    #                 # Replace named parameters with ? placeholders for DuckDB
    #                 import re

    param_query = re.sub(r":(\w+)", r"?", query)

    #                 # Convert params dict to list in the correct order
    param_values = []
    #                 for match in re.finditer(r":(\w+)", query):
    param_name = match.group(1)
    #                     if param_name in params:
                            param_values.append(params[param_name])
    #                     else:
                            raise DuckDBBackendError(
    #                             f"Parameter '{param_name}' not found in provided parameters"
    #                         )

    formatted_query = param_query
    #             else:
    formatted_query = query

    #             # Execute query and time it for performance monitoring
    result = connection.execute(formatted_query)

    #             # For SELECT queries, fetch results
    #             if query.strip().upper().startswith("SELECT"):
    rows = result.fetchall()
    #                 # DuckDB returns Arrow tables, convert to dicts
    #                 if hasattr(result, "description"):
    #                     column_names = [desc[0] for desc in result.description]
    #                     return [dict(zip(column_names, row)) for row in rows]
    #                 else:
    #                     # Arrow table case
    df = result.df()
                        return df.to_dict("records")
    #             else:
    #                 # For INSERT, UPDATE, DELETE, commit if no active transaction
    #                 if not active_transaction:
                        connection.commit()
    #                 return []

    #         except Exception as e:
    #             if connection:
                    connection.rollback()
                raise DuckDBBackendError(f"DuckDB query execution failed: {e}")
    #         finally:
    #             # Record performance metrics
    #             if start_time:
    query_time = time.time() - start_time
    #                 with self._lock:
                        self._query_times.append(query_time)
    #                     if len(self._query_times) 1000):  # Keep last 1000 queries
                            self._query_times.pop(0)

    #             if connection and not active_transaction:
    #                 pass  # Connection is reused in DuckDB

    #     def create_table(
    #         self,
    #         table_name: str,
    #         schema: Dict[str, str],
    obj_type: Optional[ObjectType] = None,
    #     ) -bool):
    #         """Create a new table optimized for analytical workloads.

    #         Args:
    #             table_name: Name of the table to create
    #             schema: Dictionary mapping column names to SQL types
    #             obj_type: Optional mathematical object type for index creation

    #         Returns:
    #             True if table created successfully, False otherwise
    #         """
    connection = None
    active_tx_id = self._get_active_transaction_id()
    #         try:
    #             if (
    #                 active_tx_id
                    and hasattr(self._local, "transaction_data")
    #                 and active_tx_id in self._local.transaction_data
    #             ):
    transaction = self._local.transaction_data[active_tx_id]
    transaction["schemas"][table_name] = schema
    #                 return True

    #             # Build CREATE TABLE statement with analytical optimizations
    columns = []
    #             for column_name, column_type in schema.items():
    #                 # Map to DuckDB types optimized for analytics
    duckdb_type = self._map_to_duckdb_type(column_type)
    #                 # Add compression and sorting hints for analytical performance
    #                 if (
                        "mathematical" in column_name.lower()
                        or "data" in column_name.lower()
    #                 ):
                        columns.append(
    #                         f'"{column_name}" {duckdb_type} ENCODE ZSTD SORTKEY'
    #                     )  # Columnar compression
    #                 else:
                        columns.append(f'"{column_name}" {duckdb_type}')

    create_sql = (
                    f'CREATE TABLE IF NOT EXISTS "{table_name}" ({", ".join(columns)})'
    #             )

    connection = self._get_connection()
                connection.execute(create_sql)

    #             # Create analytical indexes if object type is provided
    #             if obj_type is not None:
    mapper = create_mathematical_object_mapper()
    index_sql_statements = mapper.generate_index_sql(
    #                     table_name, obj_type, "duckdb"
    #                 )
    #                 for index_sql in index_sql_statements:
                        connection.execute(index_sql)

    #                 # Add analytical-specific indexes
                    self._create_analytical_indexes(connection, table_name, obj_type)

    #             # DuckDB-specific analytical optimizations
                self._apply_analytical_optimizations(connection, table_name)

    #             if not active_tx_id:
                    connection.commit()

    #             return True

    #         except Exception as e:
    #             if connection:
                    connection.rollback()
                raise DuckDBBackendError(f"Failed to create table {table_name}: {e}")
    #         finally:
    #             if connection and not active_tx_id:
    #                 pass  # Connection reused

    #     def _map_to_duckdb_type(self, py_type: str) -str):
    #         """Map Python/SQLite types to DuckDB types optimized for analytics."""
    type_mapping = {
    #             "INTEGER": "BIGINT",  # Use BIGINT for analytical range
    #             "TEXT": "VARCHAR",
    #             "REAL": "DOUBLE",  # Double precision for numerical accuracy
    #             "BLOB": "BLOB",
    #             "BOOLEAN": "BOOLEAN",
    #             "TIMESTAMP": "TIMESTAMP",
    #             "JSON": "JSON",  # DuckDB has good JSON support
    #             "MATHEMATICAL_OBJECT": "BLOB",  # Serialized objects
    #         }
            return type_mapping.get(py_type.upper(), py_type)

    #     def _create_analytical_indexes(
    #         self, connection, table_name: str, obj_type: ObjectType
    #     ):
    #         """Create indexes optimized for analytical queries."""
    #         try:
    #             # Create composite indexes for common analytical patterns
    #             if obj_type in [ObjectType.MATRIX, ObjectType.TENSOR]:
    #                 # Index on dimensions and data types for analytical filtering
                    connection.execute(
    f'CREATE INDEX IF NOT EXISTS idx_{table_name}_dimensions ON "{table_name}" (rows, cols, dtype) WHERE type = "{obj_type.value}"'
    #                 )

    #             # Time-based indexes for temporal analytics
                connection.execute(
                    f'CREATE INDEX IF NOT EXISTS idx_{table_name}_temporal ON "{table_name}" (created_at, updated_at)'
    #             )

    #             # Operation-based indexes for mathematical operations
                connection.execute(
                    f'CREATE INDEX IF NOT EXISTS idx_{table_name}_operations ON "{table_name}" (operation, type)'
    #             )

    #         except Exception as e:
                self.logger.warning(
    #                 f"Failed to create analytical indexes for {table_name}: {e}"
    #             )

    #     def _apply_analytical_optimizations(self, connection, table_name: str):
    #         """Apply DuckDB-specific optimizations for analytical workloads."""
    #         try:
    #             # Create materialized views for common analytical queries
                connection.execute(
    #                 f"""
    #                 CREATE MATERIALIZED VIEW IF NOT EXISTS mv_{table_name}_summary AS
    #                 SELECT
    #                     type,
    #                     operation,
                        COUNT(*) as count,
                        AVG(rows) as avg_rows,
                        AVG(cols) as avg_cols
    #                 FROM "{table_name}"
    #                 GROUP BY type, operation
    #             """
    #             )

    #             # Set up columnstore-like optimization through partitioning
    #             if self.database_path != ":memory:":
    #                 # Create partitioned tables for large analytical datasets
                    connection.execute(f'ALTER TABLE "{table_name}" PARTITION BY (type)')

    #             # Configure for vectorized analytical operations
                connection.execute(
    "SET vector_size = 1024"
    #             )  # Larger vector size for analytics

    #             # Enable automatic statistics for better query planning
                connection.execute(f'ANALYZE "{table_name}"')

    #         except Exception as e:
    #             self.logger.warning(f"Analytical optimization failed for {table_name}: {e}")

    #     def drop_table(self, table_name: str) -bool):
    #         """Drop a table and associated analytical structures.

    #         Args:
    #             table_name: Name of the table to drop

    #         Returns:
    #             True if table dropped successfully, False otherwise
    #         """
    connection = None
    active_tx_id = self._get_active_transaction_id()
    #         try:
    #             if (
    #                 active_tx_id
                    and hasattr(self._local, "transaction_data")
    #                 and active_tx_id in self._local.transaction_data
    #             ):
    transaction = self._local.transaction_data[active_tx_id]
    #                 if table_name in transaction["schemas"]:
    #                     del transaction["schemas"][table_name]
    #                 return True

    connection = self._get_connection()

    #             # Drop materialized views first
                connection.execute(
    #                 f"DROP MATERIALIZED VIEW IF EXISTS mv_{table_name}_summary"
    #             )

    #             # Drop the main table
                connection.execute(f'DROP TABLE IF EXISTS "{table_name}"')

    #             if not active_tx_id:
                    connection.commit()

    #             return True

    #         except Exception as e:
    #             if connection:
                    connection.rollback()
                raise DuckDBBackendError(f"Failed to drop table {table_name}: {e}")
    #         finally:
    #             if connection and not active_tx_id:
    #                 pass  # Connection reused

    #     def insert(
    #         self, table_name: str, data: Union[Dict[str, Any], List[Dict[str, Any]]]
    #     ) -bool):
    #         """Insert data optimized for analytical workloads.

    #         Args:
    #             table_name: Name of the table to insert into
    #             data: Dictionary or list of dictionaries representing rows

    #         Returns:
    #             True if insertion successful, False otherwise
    #         """
    connection = None
    active_tx_id = self._get_active_transaction_id()
    start_time = time.time()
    rows_inserted = 0
    #         try:
    #             if (
    #                 active_tx_id
                    and hasattr(self._local, "transaction_data")
    #                 and active_tx_id in self._local.transaction_data
    #             ):
    transaction = self._local.transaction_data[active_tx_id]
    #                 if table_name not in transaction["data"]:
    transaction["data"][table_name] = []

    #                 if isinstance(data, dict):
                        transaction["data"][table_name].append(data)
    rows_inserted = 1
    #                 elif isinstance(data, list):
                        transaction["data"][table_name].extend(data)
    rows_inserted = len(data)

    #                 return True

    connection = self._get_connection()

    #             if isinstance(data, dict):
    #                 # Single row insert
    columns = '"' + '", "'.join(data.keys()) + '"'
    placeholders = ", ".join(["?"] * len(data))  # DuckDB uses ?
    values = list(data.values())

    insert_sql = (
                        f'INSERT INTO "{table_name}" ({columns}) VALUES ({placeholders})'
    #                 )
                    connection.execute(insert_sql, values)
    rows_inserted = 1

    #             elif isinstance(data, list):
    #                 # Bulk insert optimized for analytics
    #                 if len(data) == 0:
    #                     return True

    #                 # Convert to DataFrame for efficient bulk insert
    df = pd.DataFrame(data)

    #                 # Use Arrow integration for columnar efficiency
                    connection.register("temp_table", df)
    columns = '"' + '", "'.join(df.columns) + '"'
    insert_sql = f'INSERT INTO "{table_name}" ({columns}) SELECT {", ".join(df.columns)} FROM temp_table'
                    connection.execute(insert_sql)
                    connection.unregister("temp_table")

    rows_inserted = len(data)

    #             # Refresh materialized views after insert for analytical consistency
                connection.execute(f"REFRESH MATERIALIZED VIEW mv_{table_name}_summary")

    #             if not active_tx_id:
                    connection.commit()

    #             # Update performance monitoring
    #             with self._lock:
    self._rows_processed + = rows_inserted

    #             return True

    #         except Exception as e:
    #             if connection:
                    connection.rollback()
                raise DuckDBBackendError(f"Failed to insert into table {table_name}: {e}")
    #         finally:
    #             # Record performance
    #             if start_time:
    query_time = time.time() - start_time
    #                 with self._lock:
                        self._query_times.append(query_time)
    #                     if len(self._query_times) 1000):
                            self._query_times.pop(0)

    #     def select(
    #         self,
    #         table_name: str,
    columns: Optional[List[str]] = None,
    where: Optional[Dict[str, Any]] = None,
    limit: Optional[int] = None,
    #     ) -List[Dict[str, Any]]):
    #         """Select data optimized for analytical queries.

    #         Args:
    #             table_name: Name of the table to select from
    #             columns: Optional list of column names to select
    #             where: Optional dictionary of WHERE clause conditions
    #             limit: Optional maximum number of rows to return

    #         Returns:
    #             List of result rows as dictionaries
    #         """
    connection = None
    active_tx_id = self._get_active_transaction_id()
    start_time = time.time()
    #         try:
    #             if (
    #                 active_tx_id
                    and hasattr(self._local, "transaction_data")
    #                 and active_tx_id in self._local.transaction_data
    #             ):
    transaction = self._local.transaction_data[active_tx_id]
    #                 if table_name in transaction["data"]:
    #                     return transaction["data"][table_name]
    #                 return []

    #             # Build analytical query with optimizations
    #             if columns:
    select_columns = '"%s"' % '", "'.join(columns)
    #             else:
    select_columns = "*"

    select_sql = f'SELECT {select_columns} FROM "{table_name}"'

    #             # Add WHERE conditions with analytical optimizations
    params = []
    #             if where:
    conditions = []

    #                 for column, value in where.items():
    #                     if isinstance(value, (list, tuple)):
    #                         if len(value) == 2 and value[0] in (
    #                             ">",
    #                             "<",
    "= ",
    "< = ",
    " = ",
    "! = ",
    #                             "IN",
    #                             "NOT IN",
    #                         )):
                                conditions.append(f'"{column}" {value[0]} ?')
                                params.append(value[1])
    #                         else:
    placeholders = ", ".join(["?"] * len(value))
                                conditions.append(f'"{column}" IN ({placeholders})')
                                params.extend(value)
    #                     else:
    conditions.append(f'"{column}" = ?')
                            params.append(value)

    #                 if conditions:
    select_sql + = " WHERE " + " AND ".join(conditions)

    #             # Add analytical LIMIT with OFFSET support
    #             if limit is not None:
    select_sql + = f" LIMIT ?"
                    params.append(limit)

    #             # Add analytical query hints
    select_sql + = " OPTION (analyze=true, vector_size=1024)"

    connection = self._get_connection()
    result = connection.execute(select_sql, params)

    #             # Get results as DataFrame for analytical efficiency
    df = result.df()
    rows = df.to_dict("records")

    #             # Update performance monitoring
    #             with self._lock:
    self._rows_processed + = len(rows)

    #             return rows

    #         except Exception as e:
    #             if connection:
                    connection.rollback()
                raise DuckDBBackendError(f"Failed to select from table {table_name}: {e}")
    #         finally:
    #             # Record performance
    #             if start_time:
    query_time = time.time() - start_time
    #                 with self._lock:
                        self._query_times.append(query_time)
    #                     if len(self._query_times) 1000):
                            self._query_times.pop(0)

    #     def update(
    #         self,
    #         table_name: str,
    #         data: Dict[str, Any],
    where: Optional[Dict[str, Any]] = None,
    #     ) -bool):
    #         """Update data in analytical tables.

    #         Args:
    #             table_name: Name of the table to update
    #             data: Dictionary of column-value pairs to update
    #             where: Optional dictionary of WHERE clause conditions

    #         Returns:
    #             True if update successful, False otherwise
    #         """
    connection = None
    active_tx_id = self._get_active_transaction_id()
    #         try:
    #             if (
    #                 active_tx_id
                    and hasattr(self._local, "transaction_data")
    #                 and active_tx_id in self._local.transaction_data
    #             ):
    transaction = self._local.transaction_data[active_tx_id]
    update_op = {
    #                     "type": "update",
    #                     "table": table_name,
    #                     "data": data,
    #                     "where": where,
    #                 }
    #                 if "_operations" not in transaction:
    transaction["_operations"] = []
                    transaction["_operations"].append(update_op)
    #                 return True

    #             # For analytical workloads, updates are less common but supported
    set_clauses = []
    params = []

    #             for column, value in data.items():
    set_clauses.append(f'"{column}" = ?')
                    params.append(value)

    update_sql = f'UPDATE "{table_name}" SET {", ".join(set_clauses)}'

    #             if where:
    conditions = []
    #                 for column, value in where.items():
    conditions.append(f'"{column}" = ?')
                        params.append(value)

    update_sql + = " WHERE " + " AND ".join(conditions)

    connection = self._get_connection()
                connection.execute(update_sql, params)

    #             # Refresh analytical structures
                connection.execute(
    #                 f"REFRESH MATERIALIZED VIEW IF EXISTS mv_{table_name}_summary"
    #             )

    #             if not active_tx_id:
                    connection.commit()

    #             return True

    #         except Exception as e:
    #             if connection:
                    connection.rollback()
                raise DuckDBBackendError(f"Failed to update table {table_name}: {e}")
    #         finally:
    #             if connection and not active_tx_id:
    #                 pass  # Connection reused

    #     def delete(self, table_name: str, where: Optional[Dict[str, Any]] = None) -bool):
    #         """Delete data from analytical tables.

    #         Args:
    #             table_name: Name of the table to delete from
    #             where: Optional dictionary of WHERE clause conditions

    #         Returns:
    #             True if deletion successful, False otherwise
    #         """
    connection = None
    active_tx_id = self._get_active_transaction_id()
    #         try:
    #             if (
    #                 active_tx_id
                    and hasattr(self._local, "transaction_data")
    #                 and active_tx_id in self._local.transaction_data
    #             ):
    transaction = self._local.transaction_data[active_tx_id]
    delete_op = {"type": "delete", "table": table_name, "where": where}
    #                 if "_operations" not in transaction:
    transaction["_operations"] = []
                    transaction["_operations"].append(delete_op)
    #                 return True

    delete_sql = f'DELETE FROM "{table_name}"'

    params = []
    #             if where:
    conditions = []
    #                 for column, value in where.items():
    conditions.append(f'"{column}" = ?')
                        params.append(value)

    delete_sql + = " WHERE " + " AND ".join(conditions)

    connection = self._get_connection()
                connection.execute(delete_sql, params)

    #             # Refresh analytical structures
                connection.execute(
    #                 f"REFRESH MATERIALIZED VIEW IF EXISTS mv_{table_name}_summary"
    #             )

    #             if not active_tx_id:
                    connection.commit()

    #             return True

    #         except Exception as e:
    #             if connection:
                    connection.rollback()
                raise DuckDBBackendError(f"Failed to delete from table {table_name}: {e}")
    #         finally:
    #             if connection and not active_tx_id:
    #                 pass  # Connection reused

    #     def table_exists(self, table_name: str) -bool):
    #         """Check if a table exists.

    #         Args:
    #             table_name: Name of the table to check

    #         Returns:
    #             True if table exists, False otherwise
    #         """
    connection = None
    #         try:
    connection = self._get_connection()

    result = connection.execute(
    f"SELECT COUNT(*) FROM information_schema.tables WHERE table_name = ?",
    #                 [table_name],
                ).fetchone()
    #             return result[0] 0 if result else False

    #         except Exception as e):
                raise DuckDBBackendError(
    #                 f"Failed to check if table {table_name} exists: {e}"
    #             )
    #         finally:
    #             if connection:
    #                 pass  # Connection reused

    #     def get_table_schema(self, table_name: str) -Dict[str, str]):
    #         """Get the schema of a table.

    #         Args:
    #             table_name: Name of the table to get schema for

    #         Returns:
    #             Dictionary mapping column names to SQL types
    #         """
    connection = None
    #         try:
    connection = self._get_connection()

    result = connection.execute(
    #                 f"""
    #                 SELECT column_name, data_type
    #                 FROM information_schema.columns
    WHERE table_name = ?
    #                 ORDER BY ordinal_position
    #             """,
    #                 [table_name],
    #             )

    columns = result.fetchall()
    schema = {}
    #             for col in columns:
    schema[col[0]] = col[1]

    #             return schema

    #         except Exception as e:
                raise DuckDBBackendError(
    #                 f"Failed to get schema for table {table_name}: {e}"
    #             )
    #         finally:
    #             if connection:
    #                 pass  # Connection reused

    #     def _get_active_transaction_id(self) -Optional[str]):
    #         """Get the ID of the currently active transaction."""
    #         if hasattr(self._local, "active_transactions"):
    #             for tx_id in self._local.active_transactions:
    #                 if self._local.active_transactions[tx_id]:
    #                     return tx_id
    #         return None

    #     def begin_transaction(self) -str):
    #         """Begin a new transaction.

    #         Returns:
    #             Transaction ID
    #         """
    #         try:
    transaction_id = (
                    f"tx_{int(time.time() * 1000)}_{threading.current_thread().ident}"
    #             )

    #             # Track active transaction
    self._local.active_transactions[transaction_id] = True

    #             # Initialize transaction data for isolation
    #             if not hasattr(self._local, "transaction_data"):
    self._local.transaction_data = {}

    #             # Get current schema information
    connection = self._get_connection()
    #             try:
    tables_result = connection.execute(
    #                     """
    #                     SELECT table_name
    #                     FROM information_schema.tables
    WHERE table_type = 'BASE TABLE'
    #                 """
    #                 )
    tables = tables_result.fetchall()
    current_schemas = {}
    #                 for table in tables:
    table_name = table[0]
    columns_result = connection.execute(
    #                         """
    #                         SELECT column_name, data_type
    #                         FROM information_schema.columns
    WHERE table_name = ?
    #                         ORDER BY ordinal_position
    #                     """,
    #                         [table_name],
    #                     )
    columns = columns_result.fetchall()
    schema = {}
    #                     for col in columns:
    schema[col[0]] = col[1]
    current_schemas[table_name] = schema
    #             finally:
    #                 pass  # Connection reused

    #             # Store transaction snapshot
    self._local.transaction_data[transaction_id] = {
    #                 "data": {},
                    "schemas": copy.deepcopy(current_schemas),
    #                 "_operations": [],
    #             }

    #             # Start transaction
                connection.execute("BEGIN TRANSACTION")

    #             return transaction_id

    #         except Exception as e:
                raise DuckDBBackendError(f"Failed to begin transaction: {e}")

    #     def commit_transaction(self, transaction_id: str) -bool):
    #         """Commit a transaction.

    #         Args:
    #             transaction_id: ID of the transaction to commit

    #         Returns:
    #             True if commit successful, False otherwise
    #         """
    connection = None
    #         try:
    #             if transaction_id not in self._local.transaction_data:
                    raise DuckDBBackendError(f"Transaction {transaction_id} not found")

    transaction = self._local.transaction_data[transaction_id]

    #             # Apply transaction operations
    connection = self._get_connection()
    cursor = connection.cursor()

    #             # Process operations
    #             for op in transaction.get("_operations", []):
    #                 if op["type"] == "insert" and op["table"] in transaction["data"]:
                        self.insert(
    #                         op["table"],
    #                         transaction["data"][op["table"]],
    active_transaction = True,
    #                     )
    #                 elif op["type"] == "update":
                        self.update(
    op["table"], op["data"], op["where"], active_transaction = True
    #                     )
    #                 elif op["type"] == "delete":
    self.delete(op["table"], op["where"], active_transaction = True)

    #             # Commit the transaction
                connection.execute("COMMIT")

    #             # Clean up
                self._local.active_transactions.pop(transaction_id, None)
                self._local.transaction_data.pop(transaction_id, None)

    #             # Refresh analytical structures
    #             for table_name in transaction["schemas"].keys():
    #                 try:
                        connection.execute(
    #                         f"REFRESH MATERIALIZED VIEW IF EXISTS mv_{table_name}_summary"
    #                     )
    #                 except:
    #                     pass

    #             return True

    #         except Exception as e:
    #             if connection:
                    connection.rollback()
                raise DuckDBBackendError(
    #                 f"Failed to commit transaction {transaction_id}: {e}"
    #             )
    #         finally:
    #             if connection:
    #                 pass  # Connection reused

    #     def rollback_transaction(self, transaction_id: str) -bool):
    #         """Rollback a transaction.

    #         Args:
    #             transaction_id: ID of the transaction to rollback

    #         Returns:
    #             True if rollback successful, False otherwise
    #         """
    connection = None
    #         try:
    connection = self._get_connection()

                connection.execute("ROLLBACK")

    #             # Clean up transaction tracking
                self._local.active_transactions.pop(transaction_id, None)
                self._local.transaction_data.pop(transaction_id, None)

    #             return True

    #         except Exception as e:
    #             if connection:
                    connection.rollback()
                raise DuckDBBackendError(
    #                 f"Failed to rollback transaction {transaction_id}: {e}"
    #             )
    #         finally:
    #             if connection:
    #                 pass  # Connection reused

    #     def health_check(self) -bool):
    #         """Perform a health check on the backend.

    #         Returns:
    #             True if backend is healthy, False otherwise
    #         """
    #         try:
    connection = self._get_connection()

    result = connection.execute("SELECT 1").fetchone()

    return result is not None and result[0] = = 1

    #         except Exception:
    #             return False

    #     def query_mathematical_objects(
    #         self,
    object_type: Optional[ObjectType] = None,
    operation: Optional[str] = None,
    conditions: Optional[Dict[str, Any]] = None,
    limit: Optional[int] = None,
    #     ) -List[MathematicalObject]):
    #         """Query mathematical objects optimized for analytical processing.

    #         Args:
    #             object_type: Type of mathematical objects to query
    #             operation: Specific mathematical operation to apply
    #             conditions: Dictionary of filtering conditions
    #             limit: Maximum number of objects to return

    #         Returns:
    #             List of MathematicalObject instances matching the criteria
    #         """
    connection = None
    #         try:
    mapper = create_mathematical_object_mapper()

    #             # Build analytical query with columnar optimizations
    query = 'SELECT * FROM "mathematical_objects" WHERE 1=1'
    params = []

    #             # Add object type filter with analytical optimization
    #             if object_type:
    query + = ' AND "type" = ?'
                    params.append(object_type.value)

    #             # Add operation filter
    #             if operation:
    query + = ' AND "operation" = ?'
                    params.append(operation)

    #             # Add analytical conditions
    #             if conditions:
    #                 for key, value in conditions.items():
    query + = f' AND "{key}" = ?'
                        params.append(value)

    #             # Add limit with analytical sampling
    #             if limit:
    query + = f" LIMIT ?"
                    params.append(limit)

    #             # Add analytical query hints for columnar processing
    query + = " OPTION (analyze=true, vector_size=2048)"

    connection = self._get_connection()
    result = connection.execute(query, params)

    #             # Use DataFrame for efficient analytical processing
    df = result.df()

    #             # Convert to MathematicalObject instances
    results = []
    #             for _, row in df.iterrows():
    row_dict = row.to_dict()
    obj = mapper.deserialize_object(row_dict)
    #                 if obj:
                        results.append(obj)

    #             return results
    #         finally:
    #             if connection:
    #                 pass  # Connection reused

    #     def query_matrix_operations(
    #         self,
    #         operation: str,
    conditions: Optional[Dict[str, Any]] = None,
    limit: Optional[int] = None,
    #     ) -List[Matrix]):
    #         """Query matrices optimized for matrix analytical operations."""
    objects = self.query_mathematical_objects(
    object_type = ObjectType.MATRIX,
    operation = operation,
    conditions = conditions,
    limit = limit,
    #         )
    #         return [obj for obj in objects if isinstance(obj, Matrix)]

    #     def query_category_theory_constructs(
    #         self,
    #         construct_type: str,
    conditions: Optional[Dict[str, Any]] = None,
    limit: Optional[int] = None,
    #     ) -List[MathematicalObject]):
    #         """Query category theory constructs with analytical optimizations."""
            return self.query_mathematical_objects(
    object_type = ObjectType.CATEGORY_THEORY,
    operation = construct_type,
    conditions = conditions,
    limit = limit,
    #         )

    #     def query_tensor_operations(
    #         self,
    #         operation: str,
    conditions: Optional[Dict[str, Any]] = None,
    limit: Optional[int] = None,
    #     ) -List[Tensor]):
    #         """Query tensors optimized for tensor analytical operations."""
    objects = self.query_mathematical_objects(
    object_type = ObjectType.TENSOR,
    operation = operation,
    conditions = conditions,
    limit = limit,
    #         )
    #         return [obj for obj in objects if isinstance(obj, Tensor)]

    #     def query_mathematical_expressions(
    #         self,
    #         expression: str,
    variables: Optional[Dict[str, Any]] = None,
    limit: Optional[int] = None,
    #     ) -List[MathematicalObject]):
    #         """Query mathematical objects using symbolic expressions with analytical processing."""
    #         try:
    expr = sp.sympify(expression)

    #             # Use analytical query to get objects
    objects = self.query_mathematical_objects(limit=limit)

    #             # Apply symbolic evaluation
    results = []
    #             for obj in objects:
    #                 if self._evaluate_expression_for_object(expr, obj, variables):
                        results.append(obj)
    #                     if limit and len(results) >= limit:
    #                         break

    #             return results
    #         except Exception as e:
                raise DuckDBBackendError(
                    f"Failed to evaluate mathematical expression: {str(e)}"
    #             )

    #     def _evaluate_expression_for_object(
    #         self,
    #         expr: sp.Expr,
    #         obj: MathematicalObject,
    variables: Optional[Dict[str, Any]] = None,
    #     ) -bool):
    #         """Evaluate if a mathematical object satisfies a symbolic expression."""
    properties = self._extract_object_properties(obj)

    context = variables or {}
            context.update(properties)

    #         try:
    result = expr.subs(context)
                return bool(result)
    #         except Exception:
    #             return False

    #     def _extract_object_properties(self, obj: MathematicalObject) -Dict[str, Any]):
    #         """Extract numerical properties from a mathematical object for analytical processing."""
    properties = {}

    #         if isinstance(obj, Matrix):
    properties["rows"] = obj.rows
    properties["cols"] = obj.cols
    properties["determinant"] = (
    #                 float(np.linalg.det(obj.data)) if obj.data.size 0 else 0.0
    #             )
    properties["trace"] = (
    #                 float(np.trace(obj.data)) if obj.data.size > 0 else 0.0
    #             )
    properties["rank"] = int(np.linalg.matrix_rank(obj.data))

    #             # Eigenvalues for analytical properties
    #             if obj.data.size > 0):
    eigenvalues = np.linalg.eigvals(obj.data)
    properties["max_eigenvalue"] = float(np.max(eigenvalues))
    properties["min_eigenvalue"] = float(np.min(eigenvalues))
    properties["eigenvalue_sum"] = float(np.sum(eigenvalues))
    #             else:
    properties["max_eigenvalue"] = 0.0
    properties["min_eigenvalue"] = 0.0
    properties["eigenvalue_sum"] = 0.0

    #         elif isinstance(obj, Tensor):
    properties["order"] = len(obj.shape)
    properties["size"] = obj.size
    properties["dtype"] = str(obj.dtype)

    #         # Add analytical metadata
    properties["created_at"] = obj.created_at
    properties["updated_at"] = obj.updated_at

    #         return properties

    #     def get_performance_metrics(self) -Dict[str, Any]):
    #         """Get performance metrics for analytical queries."""
    #         with self._lock:
    #             avg_query_time = np.mean(self._query_times) if self._query_times else 0.0
    total_queries = len(self._query_times)
    total_rows = self._rows_processed

    #         return {
    #             "average_query_time_ms": avg_query_time * 1000,
    #             "total_queries_executed": total_queries,
    #             "total_rows_processed": total_rows,
                "throughput_rows_per_second": (
                    total_rows / (avg_query_time * total_queries)
    #                 if avg_query_time 0
    #                 else 0
    #             ),
                "memory_limit_mb"): (
    #                 self.memory_limit if self.memory_limit != "none" else "unlimited"
    #             ),
    #             "threads": self.threads,
    #         }

    #     def create_analytical_view(
    self, view_name: str, query: str, replace: bool = True
    #     ) -bool):
    #         """Create an analytical materialized view for complex queries.

    #         Args:
    #             view_name: Name of the view to create
    #             query: The analytical query defining the view
    #             replace: Whether to replace existing view

    #         Returns:
    #             True if view created successfully
    #         """
    #         try:
    connection = self._get_connection()

    #             if replace:
                    connection.execute(f'DROP VIEW IF EXISTS "{view_name}"')

    create_sql = f'CREATE VIEW "{view_name}" AS {query}'
                connection.execute(create_sql)

    #             # Refresh materialized view if it's a materialized one
                connection.execute(f'REFRESH MATERIALIZED VIEW IF EXISTS "{view_name}"')

    #             return True

    #         except Exception as e:
                raise DuckDBBackendError(
    #                 f"Failed to create analytical view {view_name}: {e}"
    #             )

    #     def execute_analytical_query(
    self, query: str, params: Optional[List[Any]] = None
    #     ) -pd.DataFrame):
    #         """Execute an analytical query returning a pandas DataFrame for analysis.

    #         Args:
    #             query: Analytical SQL query
    #             params: Optional parameters

    #         Returns:
    #             Pandas DataFrame with query results
    #         """
    #         try:
    connection = self._get_connection()

    #             if params:
    result = connection.execute(query, params)
    #             else:
    result = connection.execute(query)

    #             # Return as DataFrame for analytical processing
                return result.df()

    #         except Exception as e:
                raise DuckDBBackendError(f"Failed to execute analytical query: {e}")

    #     def register_dataframe(self, name: str, df: pd.DataFrame) -bool):
    #         """Register a pandas DataFrame as a temporary table for analytical processing.

    #         Args:
    #             name: Name to register the DataFrame under
    #             df: Pandas DataFrame to register

    #         Returns:
    #             True if registration successful
    #         """
    #         try:
    connection = self._get_connection()
                connection.register(name, df)
    #             return True
    #         except Exception as e:
                raise DuckDBBackendError(f"Failed to register DataFrame {name}: {e}")

    #     def unregister_dataframe(self, name: str) -bool):
    #         """Unregister a temporary table.

    #         Args:
    #             name: Name of the table to unregister

    #         Returns:
    #             True if unregistration successful
    #         """
    #         try:
    connection = self._get_connection()
                connection.unregister(name)
    #             return True
    #         except Exception as e:
                raise DuckDBBackendError(f"Failed to unregister table {name}: {e}")
