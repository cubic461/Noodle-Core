# Converted from Python to NoodleCore
# Original file: noodle-core

# """NoodleCore Database Data Mapper
 = ==============================

# Object-relational mapping utilities for database operations.
# Provides type-safe data mapping between Python objects and database rows.

# Implements the database standards:
# - Type-safe field mapping
# - Automatic schema validation
# - Bulk operations support
# - Proper error handling with 4-digit error codes
# """

import logging
import time
import uuid
import typing.Dict,
import dataclasses.dataclass,
import datetime.datetime

import .errors.(
#     DatabaseError, QueryError, SchemaError
# )


# @dataclass
class FieldMapping
    #     """Mapping configuration for a database field."""
    #     name: str
    #     python_type: Type
    #     db_type: str
    nullable: bool = False
    default: Any = None
    primary_key: bool = False
    auto_increment: bool = False
    unique: bool = False
    indexed: bool = False
    foreign_key: Optional[str] = None
    foreign_table: Optional[str] = None
    validation: Optional[callable] = None
    transform: Optional[callable] = None


# @dataclass
class TableMapping
    #     """Mapping configuration for a database table."""
    #     name: str
    #     fields: List[FieldMapping]
    primary_key: Optional[str] = None
    unique_constraints: List[str] = None
    indexes: List[str] = None
    validation: Optional[Dict[str, Any]] = None
    pre_insert_hook: Optional[callable] = None
    pre_update_hook: Optional[callable] = None
    pre_delete_hook: Optional[callable] = None


class DatabaseDataMapper
    #     """
    #     Data mapper for database operations.

    #     Features:
    #     - Type-safe field mapping
    #     - Automatic schema validation
    #     - Bulk operations support
    #     - Transaction support
    #     - Proper error handling with 4-digit error codes
    #     """

    #     def __init__(self, backend=None):
    #         """
    #         Initialize data mapper.

    #         Args:
    #             backend: Optional database backend instance
    #         """
    self.backend = backend
    self.logger = logging.getLogger('noodlecore.database.data_mapper')
    self._table_mappings: Dict[str, TableMapping] = {}
    self._field_mappings: Dict[str, Dict[str, FieldMapping]] = {}

            self.logger.info("Database data mapper initialized")

    #     def register_table(self, table_mapping: TableMapping) -> None:
    #         """
    #         Register a table mapping.

    #         Args:
    #             table_mapping: Table mapping configuration
    #         """
    #         try:
    #             # Validate table name
    #             if not table_mapping.name or not table_mapping.name.strip():
    raise SchemaError(f"Invalid table name: {table_mapping.name}", error_code = 8001)

    #             # Check if table already registered
    #             if table_mapping.name in self._table_mappings:
    raise SchemaError(f"Table {table_mapping.name} already registered", error_code = 8002)

    #             # Validate fields
    #             if not table_mapping.fields:
    raise SchemaError(f"Table {table_mapping.name} must have at least one field", error_code = 8003)

    #             # Store table mapping
    self._table_mappings[table_mapping.name] = table_mapping

    #             # Register field mappings
    #             for field_mapping in table_mapping.fields:
                    self._register_field(table_mapping.name, field_mapping)

                self.logger.info(f"Registered table mapping: {table_mapping.name}")
    #         except Exception as e:
    error_msg = f"Failed to register table {table_mapping.name}: {str(e)}"
                self.logger.error(error_msg)
    raise SchemaError(error_msg, error_code = 8004)

    #     def _register_field(self, table_name: str, field_mapping: FieldMapping) -> None:
    #         """
    #         Register a field mapping for a table.

    #         Args:
    #             table_name: Name of the table
    #             field_mapping: Field mapping configuration
    #         """
    #         try:
    #             # Validate field name
    #             if not field_mapping.name or not field_mapping.name.strip():
    raise SchemaError(f"Invalid field name: {field_mapping.name}", error_code = 8010)

    #             # Check if field already registered for this table
    #             if table_name not in self._field_mappings:
    self._field_mappings[table_name] = {}

    #             if field_mapping.name in self._field_mappings[table_name]:
    #                 raise SchemaError(f"Field {field_mapping.name} already registered for table {table_name}", error_code=8011)

    #             # Store field mapping
    self._field_mappings[table_name][field_mapping.name] = field_mapping

                self.logger.debug(f"Registered field mapping: {table_name}.{field_mapping.name}")
    #         except Exception as e:
    #             error_msg = f"Failed to register field {field_mapping.name} for table {table_name}: {str(e)}"
                self.logger.error(error_msg)
    raise SchemaError(error_msg, error_code = 8012)

    #     def insert(self, table_name: str, data: Dict[str, Any]) -> int:
    #         """
    #         Insert data into a table.

    #         Args:
    #             table_name: Name of the table
    #             data: Dictionary of column-value pairs

    #         Returns:
    #             ID of inserted row

    #         Raises:
    #             SchemaError: If table not registered
    #             QueryError: If insertion fails
    #         """
    #         # Check if table is registered
    #         if table_name not in self._table_mappings:
    raise SchemaError(f"Table {table_name} not registered", error_code = 8013)

    table_mapping = self._table_mappings[table_name]

    #         try:
    #             # Validate data against schema
    validated_data = self._validate_data(table_name, data)

    #             # Transform data
    transformed_data = self._transform_data(table_name, validated_data)

    #             # Execute pre-insert hook
    #             if table_mapping.pre_insert_hook:
    transformed_data = table_mapping.pre_insert_hook(transformed_data)

    #             # Build INSERT query
    columns = []
    values = []
    placeholders = []

    #             for field_name, field_mapping in table_mapping.fields.items():
    value = transformed_data.get(field_name)

    #                 if value is None and not field_mapping.nullable:
    #                     # Skip null values for non-nullable fields
    #                     continue

    #                 # Add to columns and values
                    columns.append(field_mapping.name)
                    values.append(value)

    #                 # Add placeholder
                    placeholders.append("%s")

    #             # Build and execute query
    #             if self.backend:
    query = self._build_insert_query(table_name, columns)
    result = self.backend.insert(table_name, dict(zip(columns, values)))
    #             else:
    #                 # For testing without backend, return mock ID
    result = math.multiply(int(time.time(), 1000)  # Simple mock ID)

    #             self.logger.debug(f"Inserted row into {table_name} with ID: {result}")
    #             return result
    #         except Exception as e:
    error_msg = f"Insert operation failed: {str(e)}"
                self.logger.error(error_msg)
    raise QueryError(error_msg, error_code = 5001)

    #     def update(
    #         self,
    #         table_name: str,
    #         data: Dict[str, Any],
    #         conditions: Dict[str, Any]
    #     ) -> int:
    #         """
    #         Update data in a table.

    #         Args:
    #             table_name: Name of the table
    #             data: Dictionary of column-value pairs to update
    #             conditions: Dictionary of conditions for WHERE clause

    #         Returns:
    #             Number of rows affected

    #         Raises:
    #             SchemaError: If table not registered
    #             QueryError: If update fails
    #         """
    #         # Check if table is registered
    #         if table_name not in self._table_mappings:
    raise SchemaError(f"Table {table_name} not registered", error_code = 8014)

    table_mapping = self._table_mappings[table_name]

    #         try:
    #             # Validate data and conditions
    validated_data = self._validate_data(table_name, data)
    validated_conditions = self._validate_conditions(table_name, conditions)

    #             # Transform data
    transformed_data = self._transform_data(table_name, validated_data)

    #             # Execute pre-update hook
    #             if table_mapping.pre_update_hook:
    transformed_data = table_mapping.pre_update_hook(transformed_data)
    validated_conditions = self._validate_conditions(table_name, conditions)

    #             # Build UPDATE query
    #             if self.backend:
    query = self._build_update_query(table_name, transformed_data, validated_conditions)
    result = self.backend.update(table_name, transformed_data, validated_conditions)
    #             else:
    result = 0  # Mock result

                self.logger.debug(f"Updated {result} rows in {table_name}")
    #             return result
    #         except Exception as e:
    error_msg = f"Update operation failed: {str(e)}"
                self.logger.error(error_msg)
    raise QueryError(error_msg, error_code = 5002)

    #     def delete(self, table_name: str, conditions: Dict[str, Any]) -> int:
    #         """
    #         Delete data from a table.

    #         Args:
    #             table_name: Name of the table
    #             conditions: Dictionary of conditions for WHERE clause

    #         Returns:
    #             Number of rows affected

    #         Raises:
    #             SchemaError: If table not registered
    #             QueryError: If deletion fails
    #         """
    #         # Check if table is registered
    #         if table_name not in self._table_mappings:
    raise SchemaError(f"Table {table_name} not registered", error_code = 8015)

    table_mapping = self._table_mappings[table_name]

    #         try:
    #             # Validate conditions
    validated_conditions = self._validate_conditions(table_name, conditions)

    #             # Execute pre-delete hook
    #             if table_mapping.pre_delete_hook:
    validated_conditions = table_mapping.pre_delete_hook(validated_conditions)

    #             # Build DELETE query
    #             if self.backend:
    query = self._build_delete_query(table_name, validated_conditions)
    result = self.backend.delete(table_name, validated_conditions)
    #             else:
    result = 0  # Mock result

                self.logger.debug(f"Deleted {result} rows from {table_name}")
    #             return result
    #         except Exception as e:
    error_msg = f"Delete operation failed: {str(e)}"
                self.logger.error(error_msg)
    raise QueryError(error_msg, error_code = 5003)

    #     def select(
    #         self,
    #         table_name: str,
    conditions: Optional[Dict[str, Any]] = None,
    limit: Optional[int] = None
    #     ) -> List[Dict[str, Any]]:
    #         """
    #         Select data from a table.

    #         Args:
    #             table_name: Name of the table
    #             conditions: Optional dictionary of conditions
    #             limit: Optional limit for results

    #         Returns:
    #             List of dictionaries representing rows

    #         Raises:
    #             SchemaError: If table not registered
    #             QueryError: If selection fails
    #         """
    #         # Check if table is registered
    #         if table_name not in self._table_mappings:
    raise SchemaError(f"Table {table_name} not registered", error_code = 8016)

    table_mapping = self._table_mappings[table_name]

    #         try:
    #             # Validate conditions
    #             validated_conditions = self._validate_conditions(table_name, conditions) if conditions else {}

    #             # Build SELECT query
    #             if self.backend:
    query = self._build_select_query(table_name, conditions, limit)
    result = self.backend.select(table_name, validated_conditions, limit)
    #             else:
    result = []  # Mock result

                self.logger.debug(f"Selected {len(result)} rows from {table_name}")
    #             return result
    #         except Exception as e:
    error_msg = f"Select operation failed: {str(e)}"
                self.logger.error(error_msg)
    raise QueryError(error_msg, error_code = 5004)

    #     def select_one(
    #         self,
    #         table_name: str,
    #         conditions: Dict[str, Any]
    #     ) -> Optional[Dict[str, Any]]:
    #         """
    #         Select a single row from a table.

    #         Args:
    #             table_name: Name of the table
    #             conditions: Dictionary of conditions for WHERE clause

    #         Returns:
    #             Dictionary representing the row, or None if not found

    #         Raises:
    #             SchemaError: If table not registered
    #             QueryError: If selection fails
    #         """
    result = self.select(table_name, conditions, limit=1)
    #         return result[0] if result else None

    #     def bulk_insert(self, table_name: str, data_list: List[Dict[str, Any]]) -> List[int]:
    #         """
    #         Bulk insert multiple rows.

    #         Args:
    #             table_name: Name of the table
    #             data_list: List of dictionaries to insert

    #         Returns:
    #             List of inserted row IDs

    #         Raises:
    #             SchemaError: If table not registered
    #             QueryError: If bulk insert fails
    #         """
    ids = []

    #         for data in data_list:
    #             try:
    row_id = self.insert(table_name, data)
                    ids.append(row_id)
    #             except Exception as e:
    #                 self.logger.error(f"Bulk insert failed for item: {str(e)}")
    #                 # Continue with other items
    #                 continue

    #         return ids

    #     def bulk_update(self, table_name: str, updates: List[Dict[str, Any]]) -> List[int]:
    #         """
    #         Bulk update multiple rows.

    #         Args:
    #             table_name: Name of the table
                updates: List of tuples containing (data, conditions) pairs

    #         Returns:
    #             List of affected row counts

    #         Raises:
    #             SchemaError: If table not registered
    #             QueryError: If bulk update fails
    #         """
    counts = []

    #         for data, conditions in updates:
    #             try:
    count = self.update(table_name, data, conditions)
                    counts.append(count)
    #             except Exception as e:
    #                 self.logger.error(f"Bulk update failed for item: {str(e)}")
    #                 # Continue with other items
    #                 continue

    #         return counts

    #     def _validate_data(self, table_name: str, data: Dict[str, Any]) -> Dict[str, Any]:
    #         """
    #         Validate data against table schema.

    #         Args:
    #             table_name: Name of the table
    #             data: Dictionary of data to validate

    #         Returns:
    #             Validated and transformed data
    #         """
    #         if table_name not in self._table_mappings:
    raise SchemaError(f"Table {table_name} not registered", error_code = 8017)

    table_mapping = self._table_mappings[table_name]
    validated_data = {}

    #         for field_name, field_mapping in table_mapping.fields.items():
    value = data.get(field_name)

    #             # Check if field is required
    #             if value is None and not field_mapping.nullable:
                    raise SchemaError(
    #                     f"Field {field_name} is required for table {table_name}",
    error_code = 8018
    #                 )

    #             # Validate field type
    #             if field_mapping.validation and not field_mapping.validation(value):
    #                 error_msg = f"Invalid value for field {field_name}: {value}"
                    self.logger.error(error_msg)
    raise SchemaError(error_msg, error_code = 8019)

    #             # Transform field value
    #             if field_mapping.transform:
    transformed_value = field_mapping.transform(value)
    validated_data[field_name] = transformed_value
    #             else:
    validated_data[field_name] = value

    #         return validated_data

    #     def _validate_conditions(self, table_name: str, conditions: Dict[str, Any]) -> Dict[str, Any]:
    #         """
    #         Validate conditions against table schema.

    #         Args:
    #             table_name: Name of the table
    #             conditions: Dictionary of conditions to validate

    #         Returns:
    #             Validated conditions
    #         """
    #         if table_name not in self._table_mappings:
    raise SchemaError(f"Table {table_name} not registered", error_code = 8020)

    table_mapping = self._table_mappings[table_name]
    validated_conditions = {}

    #         for field_name, field_mapping in table_mapping.fields.items():
    #             if field_name in conditions:
    value = conditions[field_name]

    #                 # Validate field type
    #                 if field_mapping.validation and not field_mapping.validation(value):
    #                     error_msg = f"Invalid value for field {field_name}: {value}"
                        self.logger.error(error_msg)
    raise SchemaError(error_msg, error_code = 8021)

    validated_conditions[field_name] = value

    #         return validated_conditions

    #     def _transform_data(self, table_name: str, data: Dict[str, Any]) -> Dict[str, Any]:
    #         """
    #         Transform data for database operations.

    #         Args:
    #             table_name: Name of the table
    #             data: Dictionary of data to transform

    #         Returns:
    #             Transformed data
    #         """
    #         if table_name not in self._table_mappings:
    raise SchemaError(f"Table {table_name} not registered", error_code = 8021)

    table_mapping = self._table_mappings[table_name]
    transformed_data = {}

    #         for field_name, field_mapping in table_mapping.fields.items():
    value = data.get(field_name)

    #             # Apply field transformations
    #             if field_mapping.transform:
    transformed_value = field_mapping.transform(value)
    transformed_data[field_name] = transformed_value
    #             else:
    transformed_data[field_name] = value

    #         return transformed_data

    #     def _build_insert_query(self, table_name: str, columns: List[str]) -> str:
    #         """
    #         Build INSERT query.

    #         Args:
    #             table_name: Name of the table
    #             columns: List of column names

    #         Returns:
    #             INSERT query string
    #         """
    columns_str = ', '.join(columns)
    placeholders = ', '.join(['%s'] * len(columns))

    #         return f"""
                INSERT INTO {table_name} ({columns_str})
                VALUES ({placeholders})
    #         """

    #     def _build_update_query(
    #         self,
    #         table_name: str,
    #         data: Dict[str, Any],
    #         conditions: Dict[str, Any]
    #     ) -> str:
    #         """
    #         Build UPDATE query.

    #         Args:
    #             table_name: Name of the table
    #             data: Dictionary of data to update
    #             conditions: Dictionary of conditions

    #         Returns:
    #             UPDATE query string
    #         """
    #         set_clause = ', '.join([f"{key} = %s" for key in data.keys()])

    #         if conditions:
    where_clause = " WHERE " + " AND ".join([
    #                 f"{key} = %s" for key in conditions.keys()
    #             ])
    #         else:
    where_clause = ""

    #         return f"""
    #             UPDATE {table_name}
    #             SET {set_clause}{where_clause}
    #         """

    #     def _build_select_query(
    #         self,
    #         table_name: str,
    #         conditions: Dict[str, Any],
    limit: Optional[int] = None
    #     ) -> str:
    #         """
    #         Build SELECT query.

    #         Args:
    #             table_name: Name of the table
    #             conditions: Dictionary of conditions
    #             limit: Optional limit for results

    #         Returns:
    #             SELECT query string
    #         """
    where_clause = ""
    #         if conditions:
    where_clause = " WHERE " + " AND ".join([
    #                 f"{key} = %s" for key in conditions.keys()
    #             ])

    limit_clause = ""
    #         if limit:
    limit_clause = f" LIMIT {limit}"

    #         return f"""
    #             SELECT * FROM {table_name}{where_clause}{limit_clause}
    #         """

    #     def _build_delete_query(self, table_name: str, conditions: Dict[str, Any]) -> str:
    #         """
    #         Build DELETE query.

    #         Args:
    #             table_name: Name of the table
    #             conditions: Dictionary of conditions

    #         Returns:
    #             DELETE query string
    #         """
    where_clause = ""
    #         if conditions:
    where_clause = " WHERE " + " AND ".join([
    #                 f"{key} = %s" for key in conditions.keys()
    #             ])

    #         return f"DELETE FROM {table_name}{where_clause}"


# Predefined field mappings for common types
STRING_FIELD = FieldMapping(
name = "string",
python_type = str,
db_type = "TEXT",
nullable = True,
default = ""
# )

INTEGER_FIELD = FieldMapping(
name = "integer",
python_type = int,
db_type = "INTEGER",
nullable = False,
default = 0)

FLOAT_FIELD = FieldMapping(
name = "float",
python_type = float,
db_type = "FLOAT",
nullable = True,
default = 0.0)

BOOLEAN_FIELD = FieldMapping(
name = "boolean",
python_type = bool,
db_type = "BOOLEAN",
nullable = False,
default = False)

DATETIME_FIELD = FieldMapping(
name = "datetime",
python_type = datetime,
db_type = "TIMESTAMP",
nullable = True,
default = lambda: datetime.datetime.now)

JSON_FIELD = FieldMapping(
name = "json",
python_type = dict,
db_type = "TEXT",
nullable = True,
default = dict)

BLOB_FIELD = FieldMapping(
name = "blob",
python_type = bytes,
db_type = "BLOB",
nullable = True,
default = None)


# Convenience function to create common table mappings
def create_table_mapping(
#     name: str,
#     fields: List[FieldMapping],
primary_key: Optional[str] = None,
unique_constraints: Optional[List[str]] = None,
indexes: Optional[List[str]] = None,
validation: Optional[Dict[str, Any]] = None,
pre_insert_hook: Optional[callable] = None,
pre_update_hook: Optional[callable] = None,
pre_delete_hook: Optional[callable] = None
# ) -> TableMapping:
#     """
#     Create a table mapping configuration.

#         Args:
#             name: Table name
#             fields: List of field mappings
#             primary_key: Optional primary key field name
#             unique_constraints: Optional list of unique constraint field names
#             indexes: Optional list of indexed field names
#             validation: Optional validation dictionary
#             hooks: Optional dictionary of lifecycle hooks

#         Returns:
#             Table mapping configuration
#     """
    return TableMapping(
name = name,
fields = fields,
primary_key = primary_key,
unique_constraints = unique_constraints,
indexes = indexes,
validation = validation,
pre_insert_hook = pre_insert_hook,
pre_update_hook = pre_update_hook,
pre_delete_hook = pre_delete_hook
#     )


# Common table mappings
USERS_TABLE = create_table_mapping(
name = "users",
fields = [
#         STRING_FIELD,
#         INTEGER_FIELD,
#         BOOLEAN_FIELD,
#         DATETIME_FIELD
#     ],
primary_key = "id",
unique_constraints = ["email"],
indexes = ["email"]
# )

PROJECTS_TABLE = create_table_mapping(
name = "projects",
fields = [
#         STRING_FIELD,
#         INTEGER_FIELD,
#         BOOLEAN_FIELD,
#         DATETIME_FIELD
#     ],
primary_key = "id",
unique_constraints = ["name"],
indexes = ["name"]
# )

SESSIONS_TABLE = create_table_mapping(
name = "sessions",
fields = [
#         STRING_FIELD,
#         DATETIME_FIELD,
#         JSON_FIELD,
#         INTEGER_FIELD
#     ],
primary_key = "id",
indexes = ["user_id", "created_at"]
# )

SETTINGS_TABLE = create_table_mapping(
name = "settings",
fields = [
#         STRING_FIELD,
#         JSON_FIELD,
#         BOOLEAN_FIELD
#     ],
primary_key = "key",
unique_constraints = ["key"]
# )