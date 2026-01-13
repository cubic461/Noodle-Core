# Converted from Python to NoodleCore
# Original file: src

# """
# Data Mapper
# -----------
# Handles type conversions between Noodle data structures and database formats.
# """

import datetime
import decimal
import json
import uuid
from dataclasses import dataclass
import typing.Any

import .errors.BackendError


dataclass
class TypeMapping
    #     """Represents a type mapping between Noodle and database types."""

    #     noodle_type: Type
    #     db_type: str
    #     backend: str
    converter: Optional[callable] = None
    reverse_converter: Optional[callable] = None


class DataTypeMapper
    #     """Maps Noodle types to database-specific types and handles conversions."""

    #     def __init__(self):""Initialize the data type mapper."""
    self.mappings: Dict[str, List[TypeMapping]] = {}
            self._setup_default_mappings()

    #     def _setup_default_mappings(self):
    #         """Set up default type mappings for common backends."""
    #         # SQLite mappings
    sqlite_mappings = [
                TypeMapping(int, "INTEGER", "sqlite"),
                TypeMapping(float, "REAL", "sqlite"),
                TypeMapping(str, "TEXT", "sqlite"),
                TypeMapping(
    #                 bool, "INTEGER", "sqlite", self._bool_to_int, self._int_to_bool
    #             ),
                TypeMapping(
    #                 bool, "BOOLEAN", "sqlite", self._bool_to_int, self._int_to_bool
    #             ),
                TypeMapping(list, "TEXT", "sqlite", self._list_to_json, self._json_to_list),
                TypeMapping(dict, "TEXT", "sqlite", self._dict_to_json, self._json_to_dict),
                TypeMapping(
    #                 datetime.date,
    #                 "TEXT",
    #                 "sqlite",
    #                 self._date_to_string,
    #                 self._string_to_date,
    #             ),
                TypeMapping(
    #                 datetime.datetime,
    #                 "TEXT",
    #                 "sqlite",
    #                 self._datetime_to_string,
    #                 self._string_to_datetime,
    #             ),
                TypeMapping(
    #                 uuid.UUID, "TEXT", "sqlite", self._uuid_to_string, self._string_to_uuid
    #             ),
                TypeMapping(decimal.Decimal, "REAL", "sqlite"),
    #         ]

    #         # PostgreSQL mappings
    postgres_mappings = [
                TypeMapping(int, "BIGINT", "postgresql"),
                TypeMapping(float, "DOUBLE PRECISION", "postgresql"),
                TypeMapping(str, "TEXT", "postgresql"),
                TypeMapping(bool, "BOOLEAN", "postgresql"),
                TypeMapping(
    #                 list, "JSONB", "postgresql", self._list_to_json, self._json_to_list
    #             ),
                TypeMapping(
    #                 dict, "JSONB", "postgresql", self._dict_to_json, self._json_to_dict
    #             ),
                TypeMapping(datetime.date, "DATE", "postgresql"),
                TypeMapping(datetime.datetime, "TIMESTAMP", "postgresql"),
                TypeMapping(uuid.UUID, "UUID", "postgresql"),
                TypeMapping(decimal.Decimal, "NUMERIC", "postgresql"),
    #         ]

    #         # In-memory mappings
    memory_mappings = [
                TypeMapping(int, "int", "memory"),
                TypeMapping(float, "float", "memory"),
                TypeMapping(str, "str", "memory"),
                TypeMapping(bool, "bool", "memory"),
                TypeMapping(list, "list", "memory"),
                TypeMapping(dict, "dict", "memory"),
                TypeMapping(datetime.date, "date", "memory"),
                TypeMapping(datetime.datetime, "datetime", "memory"),
                TypeMapping(uuid.UUID, "uuid", "memory"),
                TypeMapping(decimal.Decimal, "decimal", "memory"),
    #         ]

    #         # Register mappings
    #         for mapping in sqlite_mappings:
                self.register_mapping(mapping)

    #         for mapping in postgres_mappings:
                self.register_mapping(mapping)

    #         for mapping in memory_mappings:
                self.register_mapping(mapping)

    #     def register_mapping(self, mapping: TypeMapping):
    #         """Register a type mapping.

    #         Args:
    #             mapping: Type mapping to register
    #         """
    #         if mapping.backend not in self.mappings:
    self.mappings[mapping.backend] = []

            self.mappings[mapping.backend].append(mapping)

    #     def noodle_to_db_type(self, noodle_type: Type, backend: str) -str):
    #         """Convert Noodle type to database type.

    #         Args:
    #             noodle_type: Noodle type to convert
    #             backend: Target backend

    #         Returns:
    #             Database type string
    #         """
    #         if backend not in self.mappings:
                raise BackendError(f"Unsupported backend: {backend}")

    #         for mapping in self.mappings[backend]:
    #             if mapping.noodle_type == noodle_type:
    #                 return mapping.db_type

    #         # Default fallback
    #         return "TEXT"

    #     def db_to_noodle_type(self, db_type: str, backend: str) -Type):
    #         """Convert database type to Noodle type.

    #         Args:
    #             db_type: Database type string
    #             backend: Source backend

    #         Returns:
    #             Noodle type
    #         """
    #         if backend not in self.mappings:
                raise BackendError(f"Unsupported backend: {backend}")

    db_type_upper = db_type.upper()

    #         for mapping in self.mappings[backend]:
    #             if mapping.db_type.upper() == db_type_upper:
    #                 return mapping.noodle_type

    #         # Default fallback
    #         return str

    #     def serialize_value(self, value: Any, backend: str) -Any):
    #         """Serialize Noodle value for database storage.

    #         Args:
    #             value: Value to serialize
    #             backend: Target backend

    #         Returns:
    #             Serialized value
    #         """
    #         if value is None:
    #             return None

    #         if backend not in self.mappings:
                raise BackendError(f"Unsupported backend: {backend}")

    #         # Find the appropriate converter using isinstance to support subclasses
    #         for mapping in self.mappings[backend]:
    #             if isinstance(value, mapping.noodle_type) and mapping.converter:
                    return mapping.converter(value)

    #         # No converter found, return as-is
    #         return value

    #     def deserialize_value(self, value: Any, db_type: str, backend: str) -Any):
    #         """Deserialize database value to Noodle value.

    #         Args:
    #             value: Value to deserialize
    #             db_type: Database type string
    #             backend: Source backend

    #         Returns:
    #             Deserialized value
    #         """
    #         if value is None:
    #             return None

    #         if backend not in self.mappings:
                raise BackendError(f"Unsupported backend: {backend}")

    #         # Find the appropriate reverse converter
    db_type_upper = db_type.upper()
    #         for mapping in self.mappings[backend]:
    #             if mapping.db_type.upper() == db_type_upper and mapping.reverse_converter:
                    return mapping.reverse_converter(value)

    #         # No reverse converter found, return as-is
    #         return value

    #     # Converter methods
    #     @staticmethod
    #     def _bool_to_int(value: bool) -int):
    #         """Convert boolean to integer."""
    #         return 1 if value else 0

    #     @staticmethod
    #     def _int_to_bool(value: int) -bool):
    #         """Convert integer to boolean."""
            return bool(value)

    #     @staticmethod
    #     def _list_to_json(value: list) -str):
    #         """Convert list to JSON string."""
            return json.dumps(value)

    #     @staticmethod
    #     def _json_to_list(value: str) -list):
    #         """Convert JSON string to list."""
            return json.loads(value)

    #     @staticmethod
    #     def _dict_to_json(value: dict) -str):
    #         """Convert dictionary to JSON string."""
            return json.dumps(value)

    #     @staticmethod
    #     def _json_to_dict(value: str) -dict):
    #         """Convert JSON string to dictionary."""
            return json.loads(value)

    #     @staticmethod
    #     def _date_to_string(value: datetime.date) -str):
    #         """Convert date to string."""
            return value.isoformat()

    #     @staticmethod
    #     def _string_to_date(value: str) -datetime.date):
    #         """Convert string to date."""
            return datetime.date.fromisoformat(value)

    #     @staticmethod
    #     def _datetime_to_string(value: datetime.datetime) -str):
    #         """Convert datetime to string."""
            return value.isoformat()

    #     @staticmethod
    #     def _string_to_datetime(value: str) -datetime.datetime):
    #         """Convert string to datetime."""
            return datetime.datetime.fromisoformat(value)

    #     @staticmethod
    #     def _uuid_to_string(value: uuid.UUID) -str):
    #         """Convert UUID to string."""
            return str(value)

    #     @staticmethod
    #     def _string_to_uuid(value: str) -uuid.UUID):
    #         """Convert string to UUID."""
            return uuid.UUID(value)

    #     def get_supported_types(self, backend: str) -List[Type]):
    #         """Get list of supported types for a backend.

    #         Args:
    #             backend: Backend name

    #         Returns:
    #             List of supported types
    #         """
    #         if backend not in self.mappings:
    #             return []

    #         return list(set(mapping.noodle_type for mapping in self.mappings[backend]))


class DatabaseSchemaManager
    #     """Manages database schema operations."""

    #     def __init__(self, data_mapper: DataTypeMapper):""Initialize the schema manager.

    #         Args:
    #             data_mapper: Data type mapper instance
    #         """
    self.data_mapper = data_mapper

    #     def create_schema(self, schema: Dict[str, Any], backend: str) -Dict[str, str]):
    #         """Create database schema from Noodle definition.

    #         Args:
    #             schema: Schema definition in Noodle format
    #             backend: Target backend

    #         Returns:
    #             Database schema
    #         """
    db_schema = {}

    #         for column_name, column_def in schema.items():
    #             if isinstance(column_def, type):
    #                 # Simple type definition
    db_type = self.data_mapper.noodle_to_db_type(column_def, backend)
    #             elif isinstance(column_def, str):
    #                 # Already a database type string
    db_type = column_def
    #             elif isinstance(column_def, dict):
    #                 # Complex definition with type and constraints
    noodle_type = column_def.get("type")
    #                 if noodle_type is None:
                        raise SchemaError(
    #                         f"Missing type in column definition for {column_name}"
    #                     )

    db_type = self.data_mapper.noodle_to_db_type(noodle_type, backend)

    #                 # Add constraints
    constraints = column_def.get("constraints", [])
    #                 for constraint in constraints:
    #                     if constraint.upper() in [
    #                         "PRIMARY KEY",
    #                         "NOT NULL",
    #                         "UNIQUE",
    #                         "AUTOINCREMENT",
    #                     ]:
    db_type + = f" {constraint}"
    #             else:
    #                 raise SchemaError(f"Invalid column definition for {column_name}")

    db_schema[column_name] = db_type

    #         return db_schema

    #     def migrate_schema(
    #         self, old_schema: Dict[str, str], new_schema: Dict[str, str], backend: str
    #     ) -List[str]):
    #         """Generate migration SQL from old schema to new schema.

    #         Args:
    #             old_schema: Old database schema
    #             new_schema: New database schema
    #             backend: Target backend

    #         Returns:
    #             List of SQL migration statements
    #         """
    migrations = []

    #         # Check for dropped columns
    old_columns = set(old_schema.keys())
    new_columns = set(new_schema.keys())

    dropped_columns = old_columns - new_columns
    #         if dropped_columns:
    #             # Note: SQLite doesn't support dropping columns directly
    #             if backend == "sqlite":
                    migrations.append(
    #                     f"-- SQLite doesn't support dropping columns directly"
    #                 )
                    migrations.append(
    #                     f"-- Consider creating a new table with the desired schema"
    #                 )
    #             else:
    #                 for column in dropped_columns:
                        migrations.append(
                            f"ALTER TABLE {self._get_table_name()} DROP COLUMN {column}"
    #                     )

    #         # Check for added columns
    added_columns = new_columns - old_columns
    #         for column in added_columns:
    db_type = new_schema[column]
                migrations.append(
                    f"ALTER TABLE {self._get_table_name()} ADD COLUMN {column} {db_type}"
    #             )

    #         # Check for modified columns
    common_columns = old_columns & new_columns
    #         for column in common_columns:
    #             if old_schema[column] != new_schema[column]:
    #                 # Column type changed
    old_type = old_schema[column]
    new_type = new_schema[column]

    #                 if backend == "sqlite":
                        migrations.append(
    #                         f"-- SQLite doesn't support modifying column types directly"
    #                     )
                        migrations.append(
    #                         f"-- Consider creating a new table with the desired schema"
    #                     )
    #                 else:
                        migrations.append(
                            f"ALTER TABLE {self._get_table_name()} ALTER COLUMN {column} TYPE {new_type}"
    #                     )

    #         return migrations

    #     def validate_schema(self, schema: Dict[str, Any], backend: str) -List[str]):
    #         """Validate schema compatibility with backend.

    #         Args:
    #             schema: Schema definition in Noodle format
    #             backend: Target backend

    #         Returns:
    #             List of validation errors (empty if valid)
    #         """
    errors = []

    #         # Check if backend is supported
    #         if backend not in self.data_mapper.mappings:
                errors.append(f"Unsupported backend: {backend}")
    #             return errors

    #         # Validate each column
    #         for column_name, column_def in schema.items():
    #             if isinstance(column_def, type):
    #                 # Simple type definition
    noodle_type = column_def
    #             elif isinstance(column_def, str):
    #                 # Already a database type string - assume it's valid
    #                 continue
    #             elif isinstance(column_def, dict):
    #                 # Complex definition with type and constraints
    noodle_type = column_def.get("type")
    #                 if noodle_type is None:
                        errors.append(
    #                         f"Missing type in column definition for {column_name}"
    #                     )
    #                     continue
    #             else:
    #                 errors.append(f"Invalid column definition for {column_name}")
    #                 continue

    #             # Check if type is supported
    supported_types = self.data_mapper.get_supported_types(backend)
    #             if noodle_type not in supported_types:
                    errors.append(
    #                     f"Unsupported type {noodle_type} for column {column_name} in backend {backend}"
    #                 )

    #         return errors

    #     def _get_table_name(self) -str):
    #         """Get the table name (placeholder for actual implementation).

    #         Returns:
    #             Table name
    #         """
    #         # This should be implemented to get the actual table name
    #         # For now, return a placeholder
    #         return "table_name"

    #     def generate_create_table_sql(
    #         self, table_name: str, schema: Dict[str, str], backend: str
    #     ) -str):
    #         """Generate CREATE TABLE SQL statement.

    #         Args:
    #             table_name: Name of the table
    #             schema: Database schema
    #             backend: Target backend

    #         Returns:
    #             CREATE TABLE SQL statement
    #         """
    columns = []
    #         for column_name, column_type in schema.items():
                columns.append(f"{column_name} {column_type}")

    #         if backend == "sqlite":
    #             # SQLite uses IF NOT EXISTS
                return f"CREATE TABLE IF NOT EXISTS {table_name} ({', '.join(columns)})"
    #         else:
    #             # PostgreSQL and others use standard syntax
                return f"CREATE TABLE {table_name} ({', '.join(columns)})"

    #     def generate_drop_table_sql(self, table_name: str, backend: str) -str):
    #         """Generate DROP TABLE SQL statement.

    #         Args:
    #             table_name: Name of the table
    #             backend: Target backend

    #         Returns:
    #             DROP TABLE SQL statement
    #         """
    #         if backend == "sqlite":
    #             # SQLite uses IF EXISTS
    #             return f"DROP TABLE IF EXISTS {table_name}"
    #         else:
    #             # PostgreSQL and others use standard syntax
    #             return f"DROP TABLE {table_name}"
