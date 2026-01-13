# Converted from Python to NoodleCore
# Original file: src

import __future__.annotations

# """
# PostgreSQL Database Backend for Windows
# ---------------------------------------

# Windows-compatible PostgreSQL database backend implementation for Noodle.
# This backend is optimized for Windows environments and uses psycopg2-binary
# or asyncpg for better compatibility.
# """

import asyncio
import copy
import json
import os
import ssl
import sys
import threading
import time
import pathlib.Path
import typing.Any

# Dynamic imports for different PostgreSQL drivers
try
    #     import psycopg2
    #     from psycopg2 import pool
    #     from psycopg2.extensions import connection

    HAS_PSYCOPG2 = True
except ImportError
    HAS_PSYCOPG2 = False

try
    #     import asyncpg
    #     from asyncpg import Connection, Pool

    HAS_ASYNCpg = True
except ImportError
    HAS_ASYNCpg = False

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


class WindowsPostgreSQLBackend(DatabaseBackend)
    #     """Windows-compatible PostgreSQL database backend implementation."""

    #     def __init__(self, config: Dict[str, Any] = None):""Initialize the PostgreSQL backend for Windows.

    #         Args:
    #             config: Configuration dictionary
                       - host: PostgreSQL host (default: 'localhost')
                       - database: Database name (default: 'postgres')
                       - user: Database user (default: 'postgres')
                       - password: Database password (default: '')
                       - port: Database port (default: 5432)
                       - sslmode: SSL mode (default: 'prefer')
                       - minconn: Minimum connections in pool (default: 1)
                       - maxconn: Maximum connections in pool (default: 20)
                       - timeout: Connection timeout (default: 30.0)
                       - use_asyncpg: Use asyncpg instead of psycopg2 (default: True)
                       - connection_string: Direct connection string (optional)
    #         """
            super().__init__(config or {})

    #         # Set default configuration
    self.host = self.config.get("host", "localhost")
    self.database = self.config.get("database", "postgres")
    self.user = self.config.get("user", "postgres")
    self.password = self.config.get("password", "")
    self.port = self.config.get("port", 5432)
    self.sslmode = self.config.get("sslmode", "prefer")
    self.minconn = self.config.get("minconn", 1)
    self.maxconn = self.config.get("maxconn", 20)
    self.timeout = self.config.get("timeout", 30.0)
    self.use_asyncpg = self.config.get("use_asyncpg", True)

    #         # Determine which driver to use
            self._initialize_driver()

    #         # Connection pool
    self._pool = None

    #         # Thread-local storage for active transactions
    self._local = threading.local()
    self._local.active_transactions = {}
    self._local.transaction_data = {}

    #         # Thread-safe lock for concurrent access
    self.lock = threading.RLock()

    self.is_connected = False

    #         # Windows-specific optimizations
            self.logger.info(
    #             f"Initialized PostgreSQL backend for Windows using {self._driver_name}"
    #         )

    #     def _initialize_driver(self):
    #         """Determine and initialize the appropriate PostgreSQL driver."""
    #         if sys.platform == "win32" and self.use_asyncpg and HAS_ASYNCpg:
    #             # Prefer asyncpg on Windows if available
    self._driver_name = "asyncpg"
    self._async_mode = True
    #             self._pool_class = AsyncpgConnectionPool
    #         elif HAS_PSYCOPG2:
    #             # Fall back to psycopg2 if asyncpg not available
    #             # This will use psycopg2-binary which should work on Windows
    self._driver_name = "psycopg2-binary"
    self._async_mode = False
    #             self._pool_class = Psycopg2ConnectionPool
    #         else:
    error_msg = "No PostgreSQL driver available. "
    #             if not HAS_ASYNCpg:
    error_msg + = "asyncpg not installed. "
    #             if not HAS_PSYCOPG2:
    error_msg + = "psycopg2-binary not installed. "

    #             # Install recommendation
    error_msg + = (
    #                 "Please install one of the following packages:\n"
    #                 "- pip install asyncpg (recommended for Windows)\n"
    #                 "- pip install psycopg2-binary"
    #             )

                raise BackendError(error_msg)

            self.logger.info(f"Using PostgreSQL driver: {self._driver_name}")

    #     def _check_postgresql_binary(self):
    #         """Check if required PostgreSQL binaries are available on Windows."""
    #         if self._driver_name == "psycopg2-binary":
    #             # For psycopg2-binary, we need to check if the binary is in the system path
    #             # or if the PostgreSQL binaries are installed in the standard location
    postgres_paths = [
    #                 "C:\\Program Files\\PostgreSQL\\15\\bin",
    #                 "C:\\Program Files\\PostgreSQL\\14\\bin",
    #                 "C:\\Program Files\\PostgreSQL\\13\\bin",
    #                 "C:\\Program Files\\PostgreSQL\\12\\bin",
    #                 "C:\\Program Files\\PostgreSQL\\11\\bin",
    #             ]

    #             if sys.platform == "win32":
    #                 # Add to PATH if not already there
    added_path = False
    path_to_add = None

    #                 for path in postgres_paths:
    #                     if os.path.exists(path):
    path_to_add = path
    #                         break

    #                 if path_to_add:
    os.environ["PATH"] = path_to_add + ";" + os.environ.get("PATH", "")
    added_path = True

    #                 if added_path:
                        self.logger.info(
    #                         f"Added PostgreSQL path to system PATH: {path_to_add}"
    #                     )
    #                 else:
                        self.logger.warning(
    #                         "PostgreSQL binaries not found in standard locations. "
    #                         "Consider installing PostgreSQL from https://www.postgresql.org/download/windows/"
    #                     )

    #     def connect(self) -bool):
    #         """Establish connection to the PostgreSQL database.

    #         Returns:
    #             True if connection successful, False otherwise
    #         """
    #         try:
    #             # Check for PostgreSQL binaries
                self._check_postgresql_binary()

    #             # Initialize connection pool
    self._pool = self._pool_class.from_config(
    minconn = self.minconn,
    maxconn = self.maxconn,
    host = self.host,
    database = self.database,
    user = self.user,
    password = self.password,
    port = self.port,
    sslmode = self.sslmode,
    timeout = self.timeout,
    #             )

    #             # Test connection
    #             if self._async_mode:
                    asyncio.run(self._health_check_async())
    #             else:
                    self._health_check_sync()

    self.is_connected = True
    #             return True

    #         except Exception as e:
                raise PostgreSQLBackendError(
    #                 f"Failed to connect to PostgreSQL database: {e}"
    #             )

    #     def disconnect(self) -bool):
    #         """Close the database connections.

    #         Returns:
    #             True if disconnection successful, False otherwise
    #         """
    #         try:
    #             if self._pool:
                    self._pool.close_all()
    self._pool = None

    self.is_connected = False
    #             return True

    #         except Exception as e:
                raise PostgreSQLBackendError(
    #                 f"Failed to disconnect from PostgreSQL database: {e}"
    #             )

    #     def health_check(self) -bool):
    #         """Perform a health check on the backend.

    #         Returns:
    #             True if backend is healthy, False otherwise
    #         """
    #         if not self.is_connected:
    #             return False

    #         try:
    #             if self._async_mode:
                    asyncio.run(self._health_check_async())
    #                 return True
    #             else:
                    return self._health_check_sync()
    #         except Exception:
    #             return False

    #     def _health_check_sync(self) -bool):
    #         """Perform synchronous health check."""
    #         if not self._pool:
    #             return False

    #         if self._driver_name == "psycopg2-binary":
    conn = None
    #             try:
    conn = self._pool.get_connection("health")
    cursor = conn.cursor()
                    cursor.execute("SELECT 1")
                    cursor.fetchone()
    #                 return True
    #             except Exception:
    #                 return False
    #             finally:
    #                 if conn:
                        self._pool.release_connection(conn)
    #         else:
    #             # Other synchronous drivers
    #             return False

    #     async def _health_check_async(self) -bool):
    #         """Perform asynchronous health check."""
    #         if not self._pool:
    #             return False

    conn = None
    #         try:
    conn = await self._pool.get_connection()
                await conn.fetchval("SELECT 1")
    #             return True
    #         except Exception:
    #             return False
    #         finally:
    #             if conn:
                    await conn.close()


class Psycopg2ConnectionPool
    #     """psycopg2 connection pool for Windows environments."""

    #     def __init__(
    #         self,
    minconn: int = 1,
    maxconn: int = 20,
    host: str = "localhost",
    database: str = "postgres",
    user: str = "postgres",
    password: str = "",
    port: int = 5432,
    sslmode: str = "prefer",
    timeout: float = 30.0,
    #     ):
    self.minconn = minconn
    self.maxconn = maxconn
    self.host = host
    self.database = database
    self.user = user
    self.password = password
    self.port = port
    self.sslmode = sslmode
    self.timeout = timeout

    #         # Connection string
    self.connection_string = f"host={host} dbname={database} user={user} password={password} port={port} connect_timeout={int(timeout)} sslmode={sslmode}"

    #         # Use psycopg2 pool
    self._pool = pool.ThreadedConnectionPool(
    #             minconn, maxconn, self.connection_string
    #         )

    #     def get_connection(self) -connection):
    #         """Acquire a connection from the pool."""
            return self._pool.getconn()

    #     def release_connection(self, conn: connection):
    #         """Release a connection back to the pool."""
    #         if conn:
                self._pool.putconn(conn)

    #     def close_all(self):
    #         """Close all connections in the pool."""
            self._pool.closeall()

    #     @classmethod
    #     def from_config(cls, **config):
    #         """Create connection pool from configuration."""
            return cls(**config)


class AsyncpgConnectionPool
    #     """asyncpg connection pool for Windows environments."""

    #     def __init__(
    #         self,
    minconn: int = 1,
    maxconn: int = 20,
    host: str = "localhost",
    database: str = "postgres",
    user: str = "postgres",
    password: str = "",
    port: int = 5432,
    sslmode: str = "prefer",
    timeout: float = 30.0,
    #     ):
    self.minconn = minconn
    self.maxconn = maxconn
    self.host = host
    self.database = database
    self.user = user
    self.password = password
    self.port = port
    self.sslmode = sslmode
    self.timeout = timeout

    #         # Build connection parameters
    self._connect_kwargs = {
    #             "host": host,
    #             "port": port,
    #             "database": database,
    #             "user": user,
    #             "password": password,
    #             "timeout": timeout,
    #         }

    #         # Add SSL configuration
    #         if sslmode and sslmode != "disable":
    self._connect_kwargs["ssl"] = (
    #                 "require" if sslmode == "require" else "prefer"
    #             )
    self._connect_kwargs["sslrootcert"] = self._find_ssl_cert()

    #     def _find_ssl_cert(self) -Optional[str]):
    #         """Find SSL certificate for Windows."""
    #         if sys.platform == "win32":
    #             # Common locations for PostgreSQL certificates on Windows
    cert_paths = [
    #                 "C:/Program Files/PostgreSQL/15/data/server.crt",
    #                 "C:/Program Files/PostgreSQL/14/data/server.crt",
    #                 "C:/Program Files/PostgreSQL/13/data/server.crt",
    #             ]

    #             for path in cert_paths:
    #                 if Path(path).exists():
    #                     return path

    #         return None

    #     async def get_connection(self) -Connection):
    #         """Acquire a connection from the pool."""
            return await asyncpg.connect(**self._connect_kwargs)

    #     def release_connection(self, conn: Connection):
    #         """Release a connection back to the pool."""
    #         if conn and not conn.is_closed():
                asyncio.create_task(conn.close())

    #     def close_all(self):
    #         """Close all connections in the pool."""
    #         # asyncpg's connection pool doesn't have explicit close_all in standalone mode
    #         # Each connection is closed individually
    #         pass

    #     @classmethod
    #     def from_config(cls, **config):
    #         """Create connection pool from configuration."""
            return cls(**config)

    #     async def fetchval(self, query: str, *args) -Any):
    #         """Execute a query and return the first column of the first row."""
    #         async with self.get_connection() as conn:
                return await conn.fetchval(query, *args)

    #     async def fetch(self, query: str, *args) -List[dict]):
    #         """Execute a query and return all rows as dictionaries."""
    #         async with self.get_connection() as conn:
                return await conn.fetch(query, *args)

    #     async def execute(self, query: str, *args) -str):
    #         """Execute a command that doesn't return rows."""
    #         async with self.get_connection() as conn:
                return await conn.execute(query, *args)


class WindowsPostgreSQL(WindowsPostgreSQLBackend)
    #     """Main interface for Windows PostgreSQL backend compatibility."""

    #     def __init__(self, config: Dict[str, Any] = None):""Initialize with Windows-optimized PostgreSQL backend."""
            super().__init__(config or {})

    #         # Import the standard PostgreSQL backend for shared functionality
    #         try:
    #             from .postgresql import PostgreSQLBackend

    self._shared_methods = PostgreSQLBackend.Methods
    #         except ImportError:
    #             import warnings

                warnings.warn(
    #                 "Standard PostgreSQL backend not available. "
    #                 "Some shared functionality might be missing."
    #             )
    self._shared_methods = None

    #         # Windows-specific optimizations
            self._setup_windows_optimizations()

    #     def _setup_windows_optimizations(self):
    #         """Windows-specific database optimizations."""
    #         if self._async_mode:
                self.logger.info(
    #                 "Using asyncpg - optimized for Windows with async operations"
    #             )
    #         else:
                self.logger.info(
    #                 "Using psycopg2-binary - fallback for Windows compatibility"
    #             )

    #         # Windows path checks
            self._setup_windows_paths()

    #     def _setup_windows_paths(self):
    #         """Check and setup Windows-specific paths."""
    #         if sys.platform == "win32":
    #             # Check if PostgreSQL is installed
                self._check_postgresql_installation()

    #             # Set environment variables if needed
                self._set_windows_environment()

    #     def _check_postgresql_installation(self):
    #         """Check if PostgreSQL is installed on Windows."""
    postgres_path = None

    #         # Check common installation directories
    versions = ["15", "14", "13", "12", "11"]
    #         for version in versions:
    possible_paths = [
    #                 f"C:\\Program Files\\PostgreSQL\\{version}\\bin",
                    f"C:\\Program Files (x86)\\PostgreSQL\\{version}\\bin",
    #             ]

    #             for path in possible_paths:
    #                 if os.path.exists(path):
    postgres_path = path
    #                     break

    #             if postgres_path:
    #                 break

    #         if postgres_path:
                self.logger.info(f"Found PostgreSQL installation at: {postgres_path}")
    #         else:
                self.logger.warning(
    #                 "PostgreSQL not found in standard installation locations."
    #             )
                self.logger.info(
    #                 "If PostgreSQL is installed, ensure it's in your system PATH."
    #             )

    #     def _set_windows_environment(self):
    #         """Set Windows-specific environment variables."""
    #         # Ensure Microsoft Visual C++ runtime is available
    #         if hasattr(os, "add_dll_directory"):
    #             try:
    #                 # Add PostgreSQL's DLL directory to DLL search path
    #                 for version in ["15", "14", "13", "12", "11"]:
    dll_path = f"C:\\Program Files\\PostgreSQL\\{version}\\bin"
    #                     if os.path.exists(dll_path):
                            os.add_dll_directory(dll_path)
    #                         break
    #             except Exception as e:
                    self.logger.warning(f"Failed to add DLL directory: {e}")

    #     def execute_query(
    self, query: str, params: Optional[Dict[str, Any]] = None
    #     ) -List[Dict[str, Any]]):
    #         """Execute a query with Windows-optimized error handling."""
    #         try:
    #             if self._async_mode:
                    return asyncio.run(self._execute_query_async(query, params))
    #             else:
                    return self._execute_query_sync(query, params)
    #         except Exception as e:
    #             # Windows-specific error handling
                self._handle_windows_error(e)
    #             raise

    #     def _execute_query_sync(
    #         self, query: str, params: Dict[str, Any]
    #     ) -List[Dict[str, Any]]):
    #         """Execute query synchronously."""
    #         if not self._pool:
                self.connect()

    conn = self._pool.get_connection()
    #         try:
    cursor = conn.cursor()

    #             if params:
    #                 if isinstance(params, dict):
                        cursor.execute(query, params)
    #                 else:
                        cursor.execute(query, params)
    #             else:
                    cursor.execute(query)

    #             if query.strip().upper().startswith("SELECT"):
    rows = cursor.fetchall()
    #                 column_names = [desc[0] for desc in cursor.description]
    #                 return [dict(zip(column_names, row)) for row in rows]

    #             return []
    #         finally:
                self._pool.release_connection(conn)

    #     async def _execute_query_async(
    #         self, query: str, params: Dict[str, Any]
    #     ) -List[Dict[str, Any]]):
    #         """Execute query asynchronously."""
    #         async with await self._pool.get_connection() as conn:
    #             if params:
    rows = await conn.fetch(
    #                     query, *params.values() if isinstance(params, list) else params
    #                 )
    #             else:
    rows = await conn.fetch(query)

    #             return [dict(row) for row in rows]

    #     def _handle_windows_error(self, error: Exception):
    #         """Handle Windows-specific error conditions."""
    error_msg = str(error)

    #         # Check for common Windows-specific errors
    #         if "can't adapt" in error_msg.lower():
                raise PostgreSQLBackendError(
    #                 f"Type conversion error on Windows. This might indicate a "
    #                 f"compatibility issue between PostgreSQL and Python versions. "
    #                 f"Consider installing psycopg2-binary or upgrading Python."
    #             )
    #         elif "SSL SYSCALL error" in error_msg.lower():
                raise PostgreSQLBackendError(
    f"SSL connection error on Windows. Try setting sslmode = 'disable' "
    #                 f"or verify your SSL configuration. Ensure OpenSSL is available."
    #             )
    #         elif "permission denied" in error_msg.lower():
                raise PostgreSQLBackendError(
    #                 f"Windows permission error. Verify PostgreSQL service account "
    #                 f"has the necessary permissions for the data directory."
    #             )
