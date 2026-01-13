# Converted from Python to NoodleCore
# Original file: noodle-core

# """NoodleCore Database Schema Manager
 = ===================================

# Schema management utilities for database operations.
# Provides table creation, modification, and validation capabilities.

# Implements the database standards:
# - Type-safe schema definitions
# - Automatic schema validation
# - Migration support
# - Proper error handling with 4-digit error codes
# """

import logging
import time
import uuid
import typing.Dict,
import dataclasses.dataclass,
import datetime.datetime
import enum.Enum

import .errors.(
#     DatabaseError, QueryError, SchemaError, ConnectionError
# )
import .data_mapper.FieldMapping,


class SchemaChangeType(Enum)
    #     """Types of schema changes."""
    CREATE_TABLE = "create_table"
    DROP_TABLE = "drop_table"
    ADD_COLUMN = "add_column"
    DROP_COLUMN = "drop_column"
    ALTER_COLUMN = "alter_column"
    ADD_INDEX = "add_index"
    DROP_INDEX = "drop_index"
    ADD_CONSTRAINT = "add_constraint"
    DROP_CONSTRAINT = "drop_constraint"


# @dataclass
class SchemaChange
    #     """Represents a schema change."""
    #     change_type: SchemaChangeType
    #     table_name: str
    column_name: Optional[str] = None
    old_definition: Optional[Dict[str, Any]] = None
    new_definition: Optional[Dict[str, Any]] = None
    index_name: Optional[str] = None
    constraint_name: Optional[str] = None
    rollback_sql: Optional[str] = None
    description: Optional[str] = None


# @dataclass
class SchemaMigration
    #     """Represents a schema migration."""
    #     version: str
    #     description: str
    #     changes: List[SchemaChange]
    created_at: datetime = field(default_factory=datetime.now)
    applied_at: Optional[datetime] = None
    checksum: Optional[str] = None


class DatabaseSchemaManager
    #     """
    #     Schema manager for database operations.

    #     Features:
    #     - Type-safe schema definitions
    #     - Automatic schema validation
    #     - Migration support
    #     - Rollback capabilities
    #     - Proper error handling with 4-digit error codes
    #     """

    #     def __init__(self, backend=None):
    #         """
    #         Initialize schema manager.

    #         Args:
    #             backend: Optional database backend instance
    #         """
    self.backend = backend
    self.logger = logging.getLogger('noodlecore.database.schema_manager')
    self._table_schemas: Dict[str, TableMapping] = {}
    self._migrations: List[SchemaMigration] = []
    self._migration_table = "schema_migrations"

            self.logger.info("Database schema manager initialized")

    #     def register_table(self, table_mapping: TableMapping) -> None:
    #         """
    #         Register a table schema.

    #         Args:
    #             table_mapping: Table mapping configuration
    #         """
    #         try:
    #             # Validate table name
    #             if not table_mapping.name or not table_mapping.name.strip():
    raise SchemaError(f"Invalid table name: {table_mapping.name}", error_code = 8030)

    #             # Check if table already registered
    #             if table_mapping.name in self._table_schemas:
    raise SchemaError(f"Table {table_mapping.name} already registered", error_code = 8031)

    #             # Validate fields
    #             if not table_mapping.fields:
    raise SchemaError(f"Table {table_mapping.name} must have at least one field", error_code = 8032)

    #             # Store table schema
    self._table_schemas[table_mapping.name] = table_mapping

                self.logger.info(f"Registered table schema: {table_mapping.name}")
    #         except Exception as e:
    error_msg = f"Failed to register table {table_mapping.name}: {str(e)}"
                self.logger.error(error_msg)
    raise SchemaError(error_msg, error_code = 8033)

    #     def create_table(self, table_name: str, if_not_exists: bool = True) -> bool:
    #         """
    #         Create a table from registered schema.

    #         Args:
    #             table_name: Name of the table to create
    #             if_not_exists: Whether to use IF NOT EXISTS clause

    #         Returns:
    #             True if table was created, False if it already existed

    #         Raises:
    #             SchemaError: If table not registered or creation fails
    #             QueryError: If SQL execution fails
    #         """
    #         # Check if table is registered
    #         if table_name not in self._table_schemas:
    raise SchemaError(f"Table {table_name} not registered", error_code = 8034)

    table_mapping = self._table_schemas[table_name]

    #         try:
    #             # Check if table already exists
    #             if self._table_exists(table_name):
    #                 if if_not_exists:
                        self.logger.info(f"Table {table_name} already exists, skipping creation")
    #                     return False
    #                 else:
    raise SchemaError(f"Table {table_name} already exists", error_code = 8035)

    #             # Build CREATE TABLE query
    create_sql = self._build_create_table_sql(table_mapping)

    #             # Execute query
    #             if self.backend:
                    self.backend.execute_raw_sql(create_sql)
    #             else:
                    self.logger.warning(f"No backend available, would execute: {create_sql}")

    #             # Create indexes
    #             for field_mapping in table_mapping.fields:
    #                 if field_mapping.indexed:
                        self._create_index(table_name, field_mapping.name)

    #             # Create constraints
    #             if table_mapping.unique_constraints:
    #                 for constraint_name in table_mapping.unique_constraints:
                        self._create_unique_constraint(table_name, constraint_name)

                self.logger.info(f"Created table: {table_name}")
    #             return True
    #         except Exception as e:
    error_msg = f"Failed to create table {table_name}: {str(e)}"
                self.logger.error(error_msg)
    raise QueryError(error_msg, error_code = 5010)

    #     def drop_table(self, table_name: str, if_exists: bool = True) -> bool:
    #         """
    #         Drop a table.

    #         Args:
    #             table_name: Name of the table to drop
    #             if_exists: Whether to use IF EXISTS clause

    #         Returns:
    #             True if table was dropped, False if it didn't exist

    #         Raises:
    #             QueryError: If SQL execution fails
    #         """
    #         try:
    #             # Check if table exists
    #             if not self._table_exists(table_name):
    #                 if if_exists:
                        self.logger.info(f"Table {table_name} does not exist, skipping drop")
    #                     return False
    #                 else:
    raise SchemaError(f"Table {table_name} does not exist", error_code = 8036)

    #             # Build DROP TABLE query
    #             if_exists_clause = "IF EXISTS" if if_exists else ""
    drop_sql = f"DROP TABLE {if_exists_clause} {table_name}"

    #             # Execute query
    #             if self.backend:
                    self.backend.execute_raw_sql(drop_sql)
    #             else:
                    self.logger.warning(f"No backend available, would execute: {drop_sql}")

    #             # Remove from registered schemas
    #             if table_name in self._table_schemas:
    #                 del self._table_schemas[table_name]

                self.logger.info(f"Dropped table: {table_name}")
    #             return True
    #         except Exception as e:
    error_msg = f"Failed to drop table {table_name}: {str(e)}"
                self.logger.error(error_msg)
    raise QueryError(error_msg, error_code = 5011)

    #     def add_column(self, table_name: str, field_mapping: FieldMapping) -> bool:
    #         """
    #         Add a column to an existing table.

    #         Args:
    #             table_name: Name of the table
    #             field_mapping: Field mapping for the new column

    #         Returns:
    #             True if column was added

    #         Raises:
    #             SchemaError: If table not registered or column already exists
    #             QueryError: If SQL execution fails
    #         """
    #         try:
    #             # Check if table is registered
    #             if table_name not in self._table_schemas:
    raise SchemaError(f"Table {table_name} not registered", error_code = 8037)

    table_mapping = self._table_schemas[table_name]

    #             # Check if column already exists
    #             if self._column_exists(table_name, field_mapping.name):
    raise SchemaError(f"Column {field_mapping.name} already exists in table {table_name}", error_code = 8038)

    #             # Build ALTER TABLE query
    alter_sql = self._build_add_column_sql(table_name, field_mapping)

    #             # Execute query
    #             if self.backend:
                    self.backend.execute_raw_sql(alter_sql)
    #             else:
                    self.logger.warning(f"No backend available, would execute: {alter_sql}")

    #             # Add to table schema
                table_mapping.fields.append(field_mapping)

    #             # Create index if needed
    #             if field_mapping.indexed:
                    self._create_index(table_name, field_mapping.name)

                self.logger.info(f"Added column {field_mapping.name} to table {table_name}")
    #             return True
    #         except Exception as e:
    error_msg = f"Failed to add column {field_mapping.name} to table {table_name}: {str(e)}"
                self.logger.error(error_msg)
    raise QueryError(error_msg, error_code = 5012)

    #     def drop_column(self, table_name: str, column_name: str) -> bool:
    #         """
    #         Drop a column from an existing table.

    #         Args:
    #             table_name: Name of the table
    #             column_name: Name of the column to drop

    #         Returns:
    #             True if column was dropped

    #         Raises:
    #             SchemaError: If table not registered or column doesn't exist
    #             QueryError: If SQL execution fails
    #         """
    #         try:
    #             # Check if table is registered
    #             if table_name not in self._table_schemas:
    raise SchemaError(f"Table {table_name} not registered", error_code = 8039)

    table_mapping = self._table_schemas[table_name]

    #             # Check if column exists
    #             if not self._column_exists(table_name, column_name):
    raise SchemaError(f"Column {column_name} does not exist in table {table_name}", error_code = 8040)

    #             # Build ALTER TABLE query
    alter_sql = f"ALTER TABLE {table_name} DROP COLUMN {column_name}"

    #             # Execute query
    #             if self.backend:
                    self.backend.execute_raw_sql(alter_sql)
    #             else:
                    self.logger.warning(f"No backend available, would execute: {alter_sql}")

    #             # Remove from table schema
    table_mapping.fields = [
    #                 field for field in table_mapping.fields
    #                 if field.name != column_name
    #             ]

                self.logger.info(f"Dropped column {column_name} from table {table_name}")
    #             return True
    #         except Exception as e:
    error_msg = f"Failed to drop column {column_name} from table {table_name}: {str(e)}"
                self.logger.error(error_msg)
    raise QueryError(error_msg, error_code = 5013)

    #     def create_migration(self, version: str, description: str, changes: List[SchemaChange]) -> SchemaMigration:
    #         """
    #         Create a migration.

    #         Args:
    #             version: Migration version
    #             description: Migration description
    #             changes: List of schema changes

    #         Returns:
    #             Created migration
    #         """
    #         try:
    #             # Validate version
    #             if not version or not version.strip():
    raise SchemaError("Migration version cannot be empty", error_code = 8041)

    #             # Check if version already exists
    #             for migration in self._migrations:
    #                 if migration.version == version:
    raise SchemaError(f"Migration version {version} already exists", error_code = 8042)

    #             # Create migration
    migration = SchemaMigration(
    version = version,
    description = description,
    changes = changes
    #             )

    #             # Calculate checksum
    migration.checksum = self._calculate_migration_checksum(migration)

    #             # Store migration
                self._migrations.append(migration)

                self.logger.info(f"Created migration: {version} - {description}")
    #             return migration
    #         except Exception as e:
    error_msg = f"Failed to create migration {version}: {str(e)}"
                self.logger.error(error_msg)
    raise SchemaError(error_msg, error_code = 8043)

    #     def apply_migration(self, migration: SchemaMigration) -> bool:
    #         """
    #         Apply a migration.

    #         Args:
    #             migration: Migration to apply

    #         Returns:
    #             True if migration was applied

    #         Raises:
    #             SchemaError: If migration already applied or validation fails
    #             QueryError: If SQL execution fails
    #         """
    #         try:
    #             # Check if migration already applied
    #             if self._migration_applied(migration.version):
    raise SchemaError(f"Migration {migration.version} already applied", error_code = 8044)

    #             # Validate migration
    #             if not self._validate_migration(migration):
    raise SchemaError(f"Migration {migration.version} validation failed", error_code = 8045)

    #             # Create migration table if needed
                self._ensure_migration_table()

    #             # Apply changes
    #             for change in migration.changes:
                    self._apply_change(change)

    #             # Record migration
                self._record_migration(migration)

    #             # Update migration
    migration.applied_at = datetime.now()

                self.logger.info(f"Applied migration: {migration.version}")
    #             return True
    #         except Exception as e:
    error_msg = f"Failed to apply migration {migration.version}: {str(e)}"
                self.logger.error(error_msg)
    raise QueryError(error_msg, error_code = 5014)

    #     def rollback_migration(self, migration: SchemaMigration) -> bool:
    #         """
    #         Rollback a migration.

    #         Args:
    #             migration: Migration to rollback

    #         Returns:
    #             True if migration was rolled back

    #         Raises:
    #             SchemaError: If migration not applied or rollback fails
    #             QueryError: If SQL execution fails
    #         """
    #         try:
    #             # Check if migration is applied
    #             if not self._migration_applied(migration.version):
    raise SchemaError(f"Migration {migration.version} is not applied", error_code = 8046)

    #             # Rollback changes in reverse order
    #             for change in reversed(migration.changes):
    #                 if change.rollback_sql:
    #                     if self.backend:
                            self.backend.execute_raw_sql(change.rollback_sql)
    #                     else:
                            self.logger.warning(f"No backend available, would execute rollback: {change.rollback_sql}")

    #             # Remove migration record
                self._remove_migration_record(migration.version)

    #             # Update migration
    migration.applied_at = None

                self.logger.info(f"Rolled back migration: {migration.version}")
    #             return True
    #         except Exception as e:
    error_msg = f"Failed to rollback migration {migration.version}: {str(e)}"
                self.logger.error(error_msg)
    raise QueryError(error_msg, error_code = 5015)

    #     def validate_schema(self, table_name: Optional[str] = None) -> Dict[str, Any]:
    #         """
    #         Validate database schema against registered schemas.

    #         Args:
    #             table_name: Optional table name to validate, or None for all tables

    #         Returns:
    #             Dictionary with validation results
    #         """
    #         try:
    results = {
    #                 "valid": True,
    #                 "errors": [],
    #                 "warnings": [],
    #                 "tables": {}
    #             }

    #             tables_to_validate = [table_name] if table_name else list(self._table_schemas.keys())

    #             for tbl_name in tables_to_validate:
    #                 if tbl_name not in self._table_schemas:
                        results["errors"].append(f"Table {tbl_name} not registered")
    results["valid"] = False
    #                     continue

    table_result = self._validate_table_schema(tbl_name)
    results["tables"][tbl_name] = table_result

    #                 if not table_result["valid"]:
    results["valid"] = False
                        results["errors"].extend(table_result["errors"])

                    results["warnings"].extend(table_result["warnings"])

    #             return results
    #         except Exception as e:
    error_msg = f"Schema validation failed: {str(e)}"
                self.logger.error(error_msg)
    raise SchemaError(error_msg, error_code = 8047)

    #     def get_schema_diff(self, table_name: str) -> Dict[str, Any]:
    #         """
    #         Get schema differences between registered and actual schema.

    #         Args:
    #             table_name: Name of the table

    #         Returns:
    #             Dictionary with schema differences
    #         """
    #         try:
    #             if table_name not in self._table_schemas:
    raise SchemaError(f"Table {table_name} not registered", error_code = 8048)

    table_mapping = self._table_schemas[table_name]
    actual_schema = self._get_actual_schema(table_name)

    diff = {
                    "table_exists": self._table_exists(table_name),
    #                 "missing_columns": [],
    #                 "extra_columns": [],
    #                 "column_type_diffs": [],
    #                 "missing_indexes": [],
    #                 "extra_indexes": [],
    #                 "missing_constraints": [],
    #                 "extra_constraints": []
    #             }

    #             if not diff["table_exists"]:
    #                 return diff

    #             # Compare columns
    #             registered_columns = {field.name: field for field in table_mapping.fields}
    #             actual_columns = {col["name"]: col for col in actual_schema.get("columns", [])}

    #             # Find missing columns
    #             for col_name, field_mapping in registered_columns.items():
    #                 if col_name not in actual_columns:
                        diff["missing_columns"].append({
    #                         "name": col_name,
    #                         "type": field_mapping.db_type,
    #                         "nullable": field_mapping.nullable
    #                     })

    #             # Find extra columns
    #             for col_name, column_info in actual_columns.items():
    #                 if col_name not in registered_columns:
                        diff["extra_columns"].append({
    #                         "name": col_name,
                            "type": column_info.get("type"),
                            "nullable": column_info.get("nullable", True)
    #                     })

    #             # Compare column types
    #             for col_name in registered_columns:
    #                 if col_name in actual_columns:
    registered_field = registered_columns[col_name]
    actual_column = actual_columns[col_name]

    #                     if registered_field.db_type != actual_column.get("type"):
                            diff["column_type_diffs"].append({
    #                             "name": col_name,
    #                             "registered_type": registered_field.db_type,
                                "actual_type": actual_column.get("type")
    #                         })

    #             # Compare indexes
    registered_indexes = [
    #                 field.name for field in table_mapping.fields
    #                 if field.indexed
    #             ]
    actual_indexes = actual_schema.get("indexes", [])

    diff["missing_indexes"] = [
    #                 idx for idx in registered_indexes
    #                 if idx not in actual_indexes
    #             ]
    diff["extra_indexes"] = [
    #                 idx for idx in actual_indexes
    #                 if idx not in registered_indexes
    #             ]

    #             return diff
    #         except Exception as e:
    #             error_msg = f"Schema diff failed for table {table_name}: {str(e)}"
                self.logger.error(error_msg)
    raise SchemaError(error_msg, error_code = 8049)

    #     def _table_exists(self, table_name: str) -> bool:
    #         """Check if a table exists in the database."""
    #         if not self.backend:
    #             return False

    #         try:
    query = """
                    SELECT COUNT(*) as count
    #                 FROM information_schema.tables
    WHERE table_name = %s
    #             """
    result = self.backend.fetch_one(query, [table_name])
                return result and result.get("count", 0) > 0
    #         except Exception as e:
    #             self.logger.warning(f"Failed to check if table {table_name} exists: {str(e)}")
    #             return False

    #     def _column_exists(self, table_name: str, column_name: str) -> bool:
    #         """Check if a column exists in a table."""
    #         if not self.backend:
    #             return False

    #         try:
    query = """
                    SELECT COUNT(*) as count
    #                 FROM information_schema.columns
    WHERE table_name = %s AND column_name = %s
    #             """
    result = self.backend.fetch_one(query, [table_name, column_name])
                return result and result.get("count", 0) > 0
    #         except Exception as e:
    #             self.logger.warning(f"Failed to check if column {column_name} exists in table {table_name}: {str(e)}")
    #             return False

    #     def _build_create_table_sql(self, table_mapping: TableMapping) -> str:
    #         """Build CREATE TABLE SQL from table mapping."""
    columns = []

    #         for field_mapping in table_mapping.fields:
    #             column_def = f"{field_mapping.name} {field_mapping.db_type}"

    #             if not field_mapping.nullable:
    #                 column_def += " NOT NULL"

    #             if field_mapping.default is not None:
    #                 if callable(field_mapping.default):
                        # Handle callable defaults (like datetime.now)
    #                     if field_mapping.default == datetime.now:
    #                         column_def += " DEFAULT CURRENT_TIMESTAMP"
    #                     else:
    #                         column_def += f" DEFAULT {field_mapping.default()}"
    #                 else:
    #                     column_def += f" DEFAULT {field_mapping.default}"

    #             if field_mapping.auto_increment:
    #                 column_def += " AUTO_INCREMENT"

    #             if field_mapping.primary_key:
    #                 column_def += " PRIMARY KEY"

    #             if field_mapping.unique:
    #                 column_def += " UNIQUE"

                columns.append(column_def)

    #         # Add primary key if not defined in column
    #         if table_mapping.primary_key and not any(
    #             field.primary_key for field in table_mapping.fields
    #         ):
                columns.append(f"PRIMARY KEY ({table_mapping.primary_key})")

    #         # Add unique constraints
    #         if table_mapping.unique_constraints:
    #             for constraint in table_mapping.unique_constraints:
                    columns.append(f"UNIQUE ({constraint})")

            return f"CREATE TABLE {table_mapping.name} (\n    " + ",\n    ".join(columns) + "\n)"

    #     def _build_add_column_sql(self, table_name: str, field_mapping: FieldMapping) -> str:
    #         """Build ALTER TABLE ADD COLUMN SQL from field mapping."""
    #         column_def = f"{field_mapping.name} {field_mapping.db_type}"

    #         if not field_mapping.nullable:
    #             column_def += " NOT NULL"

    #         if field_mapping.default is not None:
    #             if callable(field_mapping.default):
                    # Handle callable defaults (like datetime.now)
    #                 if field_mapping.default == datetime.now:
    #                     column_def += " DEFAULT CURRENT_TIMESTAMP"
    #                 else:
    #                     column_def += f" DEFAULT {field_mapping.default()}"
    #             else:
    #                 column_def += f" DEFAULT {field_mapping.default}"

    #         if field_mapping.auto_increment:
    #             column_def += " AUTO_INCREMENT"

    #         if field_mapping.unique:
    #             column_def += " UNIQUE"

    #         return f"ALTER TABLE {table_name} ADD COLUMN {column_def}"

    #     def _create_index(self, table_name: str, column_name: str) -> None:
    #         """Create an index on a column."""
    #         try:
    index_name = f"idx_{table_name}_{column_name}"
    create_index_sql = f"CREATE INDEX {index_name} ON {table_name} ({column_name})"

    #             if self.backend:
                    self.backend.execute_raw_sql(create_index_sql)
    #             else:
                    self.logger.warning(f"No backend available, would execute: {create_index_sql}")

                self.logger.info(f"Created index {index_name}")
    #         except Exception as e:
                self.logger.warning(f"Failed to create index on {table_name}.{column_name}: {str(e)}")

    #     def _create_unique_constraint(self, table_name: str, constraint_name: str) -> None:
    #         """Create a unique constraint."""
    #         try:
    constraint_sql = f"ALTER TABLE {table_name} ADD CONSTRAINT uc_{table_name}_{constraint_name} UNIQUE ({constraint_name})"

    #             if self.backend:
                    self.backend.execute_raw_sql(constraint_sql)
    #             else:
                    self.logger.warning(f"No backend available, would execute: {constraint_sql}")

                self.logger.info(f"Created unique constraint on {table_name}.{constraint_name}")
    #         except Exception as e:
                self.logger.warning(f"Failed to create unique constraint on {table_name}.{constraint_name}: {str(e)}")

    #     def _ensure_migration_table(self) -> None:
    #         """Ensure the migration tracking table exists."""
    #         try:
    #             if not self._table_exists(self._migration_table):
    create_sql = f"""
                        CREATE TABLE {self._migration_table} (
                            version VARCHAR(50) PRIMARY KEY,
    #                         description TEXT,
    #                         applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                            checksum VARCHAR(64)
    #                     )
    #                 """

    #                 if self.backend:
                        self.backend.execute_raw_sql(create_sql)
    #                 else:
                        self.logger.warning(f"No backend available, would execute: {create_sql}")

                    self.logger.info(f"Created migration table: {self._migration_table}")
    #         except Exception as e:
                self.logger.warning(f"Failed to ensure migration table: {str(e)}")

    #     def _migration_applied(self, version: str) -> bool:
    #         """Check if a migration has been applied."""
    #         if not self.backend:
    #             return False

    #         try:
    query = f"SELECT COUNT(*) as count FROM {self._migration_table} WHERE version = %s"
    result = self.backend.fetch_one(query, [version])
                return result and result.get("count", 0) > 0
    #         except Exception as e:
    #             self.logger.warning(f"Failed to check if migration {version} applied: {str(e)}")
    #             return False

    #     def _record_migration(self, migration: SchemaMigration) -> None:
    #         """Record a migration as applied."""
    #         try:
    query = f"""
                    INSERT INTO {self._migration_table} (version, description, applied_at, checksum)
                    VALUES (%s, %s, %s, %s)
    #             """

    #             if self.backend:
                    self.backend.execute_raw_sql(query, [
    #                     migration.version,
    #                     migration.description,
    #                     migration.applied_at,
    #                     migration.checksum
    #                 ])
    #             else:
                    self.logger.warning(f"No backend available, would record migration: {migration.version}")
    #         except Exception as e:
                self.logger.warning(f"Failed to record migration {migration.version}: {str(e)}")

    #     def _remove_migration_record(self, version: str) -> None:
    #         """Remove a migration record."""
    #         try:
    query = f"DELETE FROM {self._migration_table} WHERE version = %s"

    #             if self.backend:
                    self.backend.execute_raw_sql(query, [version])
    #             else:
                    self.logger.warning(f"No backend available, would remove migration record: {version}")
    #         except Exception as e:
                self.logger.warning(f"Failed to remove migration record {version}: {str(e)}")

    #     def _validate_migration(self, migration: SchemaMigration) -> bool:
    #         """Validate a migration."""
    #         try:
    #             # Check if migration has changes
    #             if not migration.changes:
    #                 return False

    #             # Validate each change
    #             for change in migration.changes:
    #                 if not self._validate_change(change):
    #                     return False

    #             return True
    #         except Exception as e:
                self.logger.warning(f"Migration validation failed: {str(e)}")
    #             return False

    #     def _validate_change(self, change: SchemaChange) -> bool:
    #         """Validate a schema change."""
    #         try:
    #             # Check if table exists for non-create operations
    #             if change.change_type != SchemaChangeType.CREATE_TABLE:
    #                 if not self._table_exists(change.table_name):
    #                     return False

    #             # Validate change-specific requirements
    #             if change.change_type in [SchemaChangeType.ADD_COLUMN, SchemaChangeType.DROP_COLUMN, SchemaChangeType.ALTER_COLUMN]:
    #                 if not change.column_name:
    #                     return False

    #             return True
    #         except Exception as e:
                self.logger.warning(f"Change validation failed: {str(e)}")
    #             return False

    #     def _apply_change(self, change: SchemaChange) -> None:
    #         """Apply a schema change."""
    #         try:
    #             if change.change_type == SchemaChangeType.CREATE_TABLE:
    #                 if change.table_name in self._table_schemas:
                        self.create_table(change.table_name)

    #             elif change.change_type == SchemaChangeType.DROP_TABLE:
                    self.drop_table(change.table_name)

    #             elif change.change_type == SchemaChangeType.ADD_COLUMN:
    #                 if change.new_definition:
    field_mapping = math.multiply(FieldMapping(, *change.new_definition))
                        self.add_column(change.table_name, field_mapping)

    #             elif change.change_type == SchemaChangeType.DROP_COLUMN:
    #                 if change.column_name:
                        self.drop_column(change.table_name, change.column_name)

    #             # Add other change types as needed

    #         except Exception as e:
                self.logger.error(f"Failed to apply change {change.change_type}: {str(e)}")
    #             raise

    #     def _calculate_migration_checksum(self, migration: SchemaMigration) -> str:
    #         """Calculate checksum for a migration."""
    #         import hashlib

    #         # Create a string representation of the migration
    migration_str = f"{migration.version}:{migration.description}:"
    #         for change in migration.changes:
    migration_str + = f"{change.change_type.value}:{change.table_name}:"

    #         # Calculate MD5 checksum
            return hashlib.md5(migration_str.encode()).hexdigest()

    #     def _validate_table_schema(self, table_name: str) -> Dict[str, Any]:
    #         """Validate a single table schema."""
    result = {
    #             "valid": True,
    #             "errors": [],
    #             "warnings": []
    #         }

    #         try:
    #             if table_name not in self._table_schemas:
                    result["errors"].append(f"Table {table_name} not registered")
    result["valid"] = False
    #                 return result

    table_mapping = self._table_schemas[table_name]

    #             # Check if table exists
    #             if not self._table_exists(table_name):
                    result["errors"].append(f"Table {table_name} does not exist")
    result["valid"] = False
    #                 return result

    #             # Validate columns
    #             for field_mapping in table_mapping.fields:
    #                 if not self._column_exists(table_name, field_mapping.name):
                        result["errors"].append(f"Column {field_mapping.name} does not exist in table {table_name}")
    result["valid"] = False

    #             # Validate indexes
    #             for field_mapping in table_mapping.fields:
    #                 if field_mapping.indexed and not self._index_exists(table_name, field_mapping.name):
                        result["warnings"].append(f"Index on {table_name}.{field_mapping.name} does not exist")

    #         except Exception as e:
                result["errors"].append(f"Validation error: {str(e)}")
    result["valid"] = False

    #         return result

    #     def _get_actual_schema(self, table_name: str) -> Dict[str, Any]:
    #         """Get the actual schema of a table from the database."""
    #         if not self.backend:
    #             return {}

    #         try:
    #             # Get columns
    columns_query = """
    #                 SELECT column_name, data_type, is_nullable, column_default
    #                 FROM information_schema.columns
    WHERE table_name = %s
    #                 ORDER BY ordinal_position
    #             """
    columns = self.backend.fetch_all(columns_query, [table_name])

    #             # Get indexes
    indexes_query = """
    #                 SELECT column_name
    #                 FROM information_schema.statistics
    WHERE table_name = %s AND index_name != 'PRIMARY'
    #                 GROUP BY column_name
    #             """
    indexes_result = self.backend.fetch_all(indexes_query, [table_name])
    #             indexes = [idx["column_name"] for idx in indexes_result]

    #             return {
    #                 "columns": columns,
    #                 "indexes": indexes
    #             }
    #         except Exception as e:
    #             self.logger.warning(f"Failed to get actual schema for {table_name}: {str(e)}")
    #             return {}

    #     def _index_exists(self, table_name: str, column_name: str) -> bool:
    #         """Check if an index exists on a column."""
    #         if not self.backend:
    #             return False

    #         try:
    query = """
                    SELECT COUNT(*) as count
    #                 FROM information_schema.statistics
    WHERE table_name = %s AND column_name = %s AND index_name != 'PRIMARY'
    #             """
    result = self.backend.fetch_one(query, [table_name, column_name])
                return result and result.get("count", 0) > 0
    #         except Exception as e:
    #             self.logger.warning(f"Failed to check if index exists on {table_name}.{column_name}: {str(e)}")
    #             return False