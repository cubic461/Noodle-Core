# Converted from Python to NoodleCore
# Original file: src

# """
# Memory Backend for Noodle Database System

# In-memory storage backend for testing and development purposes.
# Provides a simple key-value store with basic CRUD operations.
# """

import json
import logging
import uuid
import datetime.datetime
import typing.Any

import .base.BackendConfig

logger = logging.getLogger(__name__)


class BackendNotImplementedError(NotImplementedError)
    #     """Exception raised when a backend feature is not implemented."""

    #     def __init__(self, feature_name: str, backend_name: str = "MemoryBackend"):
    self.feature_name = feature_name
    self.backend_name = backend_name
    message = f"Feature '{feature_name}' is not implemented in {backend_name}"
            super().__init__(message)


class MemoryBackend
    #     """In-memory database backend implementation."""

    #     def __init__(self, config: Optional[Union[Dict[str, Any], BackendConfig]] = None):""
    #         Initialize the memory backend.

    #         Args:
    #             config: Optional configuration dictionary or BackendConfig instance
    #         """
    #         if isinstance(config, BackendConfig):
    self.config = config
    self.connection_string = config.connection_string
    #         else:
    self.config = config or {}
    self.connection_string = (
                    self.config.get("connection_string", "memory://default")
    #                 if isinstance(self.config, dict)
    #                 else "memory://default"
    #             )

    self.tables: Dict[str, Dict[Any, Dict[str, Any]]] = {}
    self._table_schemas: Dict[str, Dict[str, str]] = {}
    self.next_id: Dict[str, int] = {}
    self.connected = False

            logger.info(
    #             f"MemoryBackend initialized with connection: {self.connection_string}"
    #         )

    #     def connect(self):
    #         """Establish connection to the backend."""
    #         if not self.connected:
    self.connected = True
                logger.info("Connected to MemoryBackend")

    #     def disconnect(self):
    #         """Close connection to the backend."""
    self.connected = False
            self.tables.clear()
            self._table_schemas.clear()
            self.next_id.clear()
            logger.info("Disconnected from MemoryBackend")

    #     def create_table(self, table_name: str, schema: Dict[str, str]):
    #         """
    #         Create a new table with the given schema.

    #         Args:
    #             table_name: Name of the table to create
    #             schema: Dictionary of column names to data types
    #         """
    #         if not self.connected:
                raise ConnectionError("Not connected to backend")

    #         if table_name in self.tables:
                logger.warning(f"Table {table_name} already exists")
    #             return

    self.tables[table_name] = {}
    self._table_schemas[table_name] = schema
    self.next_id[table_name] = 1

    #         logger.info(f"Created table '{table_name}' with schema: {schema}")

    #     def drop_table(self, table_name: str):
    #         """Drop the specified table."""
    #         if table_name in self.tables:
    #             del self.tables[table_name]
    #             del self._table_schemas[table_name]
    #             if table_name in self.next_id:
    #                 del self.next_id[table_name]
                logger.info(f"Dropped table '{table_name}'")
    #         else:
                logger.warning(f"Table '{table_name}' does not exist")

    #     def insert(self, table_name: str, record: Dict[str, Any], **kwargs):
    #         """
    #         Insert a record into the specified table.

    #         Args:
    #             table_name: Name of the table
    #             record: Dictionary representing the record to insert
    #         """
    #         if not self.connected:
                raise ConnectionError("Not connected to backend")

    #         if table_name not in self.tables:
                raise ValueError(f"Table '{table_name}' does not exist")

    #         # Generate ID if not provided
    #         if "id" not in record:
    record_id = self.next_id.get(table_name, 1)
    record["id"] = f"mem_{table_name}_{record_id}"
    self.next_id[table_name] = record_id + 1
    #         else:
    record_id = record["id"]

    #         # Validate schema
    schema = self._table_schemas[table_name]
    #         for col, val in record.items():
    #             if col in schema and isinstance(val, str) and len(val) 10000):
                    logger.warning(f"Large value in column {col}, truncating")
    record[col] = str(val)[:10000] + "..."

    #         # Add timestamps if not present
    #         if "created_at" not in record:
    record["created_at"] = datetime.utcnow().isoformat()
    #         if "updated_at" not in record:
    record["updated_at"] = record["created_at"]

    self.tables[table_name][record_id] = record

            logger.debug(f"Inserted record {record_id} into table '{table_name}'")
    #         return record_id

    #     def update(self, table_name: str, record_id: Any, updates: Dict[str, Any]):
    #         """
    #         Update a record in the specified table.

    #         Args:
    #             table_name: Name of the table
    #             record_id: ID of the record to update
    #             updates: Dictionary of updates to apply
    #         """
    #         if table_name not in self.tables or record_id not in self.tables[table_name]:
                raise ValueError(f"Record {record_id} not found in table '{table_name}'")

    #         for key, value in updates.items():
    #             if key == "updated_at":
    updates[key] = datetime.utcnow().isoformat()
    self.tables[table_name][record_id][key] = value

            logger.debug(f"Updated record {record_id} in table '{table_name}'")
    #         return self.tables[table_name][record_id]

    #     def delete(self, table_name: str, record_id: Any):
    #         """
    #         Delete a record from the specified table.

    #         Args:
    #             table_name: Name of the table
    #             record_id: ID of the record to delete
    #         """
    #         if table_name in self.tables and record_id in self.tables[table_name]:
    deleted = self.tables[table_name].pop(record_id)
                logger.debug(f"Deleted record {record_id} from table '{table_name}'")
    #             return deleted
    #         else:
                raise ValueError(f"Record {record_id} not found in table '{table_name}'")

    #     def select(
    #         self,
    #         table_name: str,
    conditions: Optional[Dict[str, Any]] = None,
    limit: Optional[int] = None,
    #     ) -Dict[str, Any]):
    #         """
    #         Select records from the specified table.

    #         Args:
    #             table_name: Name of the table
    #             conditions: Optional filter conditions
    #             limit: Optional limit on number of results

    #         Returns:
    #             Dictionary with 'data' containing list of records
    #         """
    #         if table_name not in self.tables:
                raise ValueError(f"Table '{table_name}' does not exist")

    records = list(self.tables[table_name].values())

    #         # Apply conditions
    #         if conditions:
    filtered_records = []
    #             for record in records:
    match = True
    #                 for key, value in conditions.items():
    #                     if record.get(key) != value:
    match = False
    #                         break
    #                 if match:
                        filtered_records.append(record)
    records = filtered_records

    #         # Apply limit
    #         if limit is not None:
    records = records[:limit]

    result = {
    #             "data": records,
                "count": len(records),
    #             "table": table_name,
                "timestamp": datetime.utcnow().isoformat(),
    #         }

            logger.debug(f"Selected {len(records)} records from table '{table_name}'")
    #         return result

    #     def get_schema(self, table_name: str) -Dict[str, str]):
    #         """Get the schema for the specified table."""
    #         if table_name not in self._table_schemas:
                raise ValueError(f"Table '{table_name}' does not exist")
            return self._table_schemas[table_name].copy()

    #     def list_tables(self) -List[str]):
    #         """List all available tables."""
            return list(self.tables.keys())

    #     def execute_query(self, query: str) -Any):
    #         """
    #         Execute a custom query (basic implementation for memory backend).

    #         Args:
    #             query: SQL-like query string

    #         Returns:
    #             Query result
    #         """
            logger.warning("Custom query execution not fully implemented in MemoryBackend")
    #         # Simple parsing for basic operations
    query = query.strip().lower()

    #         if query.startswith("select"):
    #             # Extract table name
    parts = query.split()
    #             if len(parts) >= 3:
    table_name = parts[3].strip(";")
    #                 if table_name in self.tables:
                        return {"data": list(self.tables[table_name].values())}

            raise ValueError(f"Unsupported query in MemoryBackend: {query}")

    #     def transaction_start(self):
    #         """Start a transaction."""
    #         if hasattr(self, "_transaction_stack"):
                self._transaction_stack.append(self.tables.copy())
    #         else:
    self._transaction_stack = [self.tables.copy()]
            logger.debug("Transaction started")

    #     def transaction_commit(self):
    #         """Commit the current transaction."""
    #         if self._transaction_stack:
                self._transaction_stack.pop()
            logger.debug("Transaction committed")

    #     def transaction_rollback(self):
    #         """Rollback the current transaction."""
    #         if self._transaction_stack:
    self.tables = self._transaction_stack.pop()
            logger.debug("Transaction rolled back")


class InMemoryBackend(MemoryBackend)
    #     """Alias for MemoryBackend for backward compatibility."""
    #     pass
