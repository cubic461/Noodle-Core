# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Database Manager
# ----------------
# Central manager for database operations using the plugin loader.
# Allows runtime selection and switching between backends.
# Integrates with Noodle runtime for seamless access.
# """

import typing.Any,

import ..utils.error_handler.ErrorHandler
import .backends.base.BackendConfig,
import .plugin_loader.PluginLoaderError,
import .query_interface.QueryResult


class DatabaseManager
    #     """
    #     Manages multiple database backends via plugin loader.
    #     Handles connection, query routing, and switching.
    #     """

    #     def __init__(self):
    self.loader = get_plugin_loader()
    self.current_backend_name: Optional[str] = None
    self.current_backend: Optional[DatabaseBackend] = None
    self.configs: Dict[str, BackendConfig] = {}
    self.error_handler = ErrorHandler()
    self.is_connected = False

    #     def register_config(self, backend_name: str, config: BackendConfig) -> None:
    #         """Register configuration for a backend."""
    self.configs[backend_name] = config

    #     def switch_backend(self, backend_name: str) -> None:
    #         """
    #         Switch to a different backend.
    #         Loads if not already loaded, connects if needed.

    #         Args:
    #             backend_name: Name of the backend to switch to

    #         Raises:
    #             DatabaseManagerError: If backend not available or config missing
    #         """
    #         if backend_name not in self.loader.loaded_backends:
                raise ValueError(
                    f"Backend {backend_name} not loaded. Available: {self.loader.get_available_backends()}"
    #             )

    #         if backend_name not in self.configs:
    #             raise ValueError(f"No config registered for backend {backend_name}")

    config = self.configs[backend_name]

    #         # Disconnect current if connected
    #         if self.is_connected:
                self.current_backend.disconnect()

    #         # Load and connect new
    self.current_backend = self.loader.load_backend(backend_name, config)
    self.current_backend_name = backend_name
            self.current_backend.connect()
    self.is_connected = True

    #     def get_current_backend_name(self) -> Optional[str]:
    #         """Get the name of the current backend."""
    #         return self.current_backend_name

    #     # Proxy methods to current backend
    #     def execute_query(
    self, query: str, params: Optional[Dict[str, Any]] = None
    #     ) -> QueryResult:
    #         """Execute query on current backend."""
    #         if not self.is_connected:
                raise DatabaseError("No backend connected")
            return self.current_backend.execute_query(query, params)

    #     def insert(self, table: str, data: Dict[str, Any]) -> int:
    #         """Insert data on current backend."""
    #         if not self.is_connected:
                raise DatabaseError("No backend connected")
            return self.current_backend.insert(table, data)

    #     def update(
    #         self, table: str, data: Dict[str, Any], conditions: Dict[str, Any]
    #     ) -> int:
    #         """Update data on current backend."""
    #         if not self.is_connected:
                raise DatabaseError("No backend connected")
            return self.current_backend.update(table, data, conditions)

    #     def delete(self, table: str, conditions: Dict[str, Any]) -> int:
    #         """Delete data on current backend."""
    #         if not self.is_connected:
                raise DatabaseError("No backend connected")
            return self.current_backend.delete(table, conditions)

    #     def select(
    #         self,
    #         table: str,
    columns: Optional[List[str]] = None,
    conditions: Optional[Dict[str, Any]] = None,
    #     ) -> QueryResult:
    #         """Select data on current backend."""
    #         if not self.is_connected:
                raise DatabaseError("No backend connected")
            return self.current_backend.select(table, columns, conditions)

    #     def begin_transaction(self) -> Any:
    #         """Begin transaction on current backend."""
    #         if not self.is_connected:
                raise DatabaseError("No backend connected")
            return self.current_backend.begin_transaction()

    #     def commit_transaction(self, transaction: Any) -> None:
    #         """Commit transaction on current backend."""
    #         if not self.is_connected:
                raise DatabaseError("No backend connected")
            self.current_backend.commit_transaction(transaction)

    #     def rollback_transaction(self, transaction: Any) -> None:
    #         """Rollback transaction on current backend."""
    #         if not self.is_connected:
                raise DatabaseError("No backend connected")
            self.current_backend.rollback_transaction(transaction)

    #     def table_exists(self, table_name: str) -> bool:
    #         """Check table existence on current backend."""
    #         if not self.is_connected:
                raise DatabaseError("No backend connected")
            return self.current_backend.table_exists(table_name)

    #     def create_table(self, table_name: str, schema: Dict[str, str]) -> None:
    #         """Create table on current backend."""
    #         if not self.is_connected:
                raise DatabaseError("No backend connected")
            self.current_backend.create_table(table_name, schema)

    #     def drop_table(self, table_name: str) -> None:
    #         """Drop table on current backend."""
    #         if not self.is_connected:
                raise DatabaseError("No backend connected")
            self.current_backend.drop_table(table_name)

    #     def get_table_schema(self, table_name: str) -> Dict[str, str]:
    #         """Get table schema from current backend."""
    #         if not self.is_connected:
                raise DatabaseError("No backend connected")
            return self.current_backend.get_table_schema(table_name)

    #     def get_table_info(self, table_name: str) -> Dict[str, Any]:
    #         """Get table info from current backend."""
    #         if not self.is_connected:
                raise DatabaseError("No backend connected")
            return self.current_backend.get_table_info(table_name)

    #     def backup_database(self, backup_path: str) -> None:
    #         """Backup current backend."""
    #         if not self.is_connected:
                raise DatabaseError("No backend connected")
            self.current_backend.backup_database(backup_path)

    #     def restore_database(self, backup_path: str) -> None:
    #         """Restore to current backend."""
    #         if not self.is_connected:
                raise DatabaseError("No backend connected")
            self.current_backend.restore_database(backup_path)

    #     def optimize_database(self) -> None:
    #         """Optimize current backend."""
    #         if not self.is_connected:
                raise DatabaseError("No backend connected")
            self.current_backend.optimize_database()

    #     def get_database_stats(self) -> Dict[str, Any]:
    #         """Get stats from current backend."""
    #         if not self.is_connected:
                raise DatabaseError("No backend connected")
            return self.current_backend.get_database_stats()

    #     def health_check(self) -> bool:
    #         """Health check on current backend."""
    #         if not self.is_connected:
                raise DatabaseError("No backend connected")
            return self.current_backend.health_check()

    #     @property
    #     def connection_pool_info(self) -> Dict[str, int]:
    #         """Get connection pool info from current backend."""
    #         if not self.is_connected:
    #             return {
    #                 "total_connections": 0,
    #                 "available_connections": 0,
    #                 "busy_connections": 0,
    #             }
            return self.current_backend.get_connection_pool_info()

    #     def close(self) -> None:
    #         """Close current backend."""
    #         if self.is_connected:
                self.current_backend.disconnect()
    self.is_connected = False
    self.current_backend = None
    self.current_backend_name = None


# Global manager instance
manager = DatabaseManager()


def get_database_manager() -> DatabaseManager:
#     """Get the global database manager."""
#     return manager
