# Converted from Python to NoodleCore
# Original file: noodle-core

# """NoodleCore Database Migration Manager
 = =======================================

# Migration management utilities for database schema evolution.
# Provides versioned migration system with rollback capabilities.

# Implements the database standards:
# - Versioned migration tracking
# - Automatic rollback support
# - Migration validation
# - Proper error handling with 4-digit error codes
# """

import logging
import time
import uuid
import os
import json
import typing.Dict,
import dataclasses.dataclass,
import datetime.datetime
import enum.Enum
import pathlib.Path

import .errors.(
#     DatabaseError, QueryError, SchemaError, ConnectionError
# )
import .schema_manager.SchemaChange,


class MigrationStatus(Enum)
    #     """Migration status values."""
    PENDING = "pending"
    APPLIED = "applied"
    FAILED = "failed"
    ROLLED_BACK = "rolled_back"


# @dataclass
class MigrationRecord
    #     """Record of a migration execution."""
    #     version: str
    #     status: MigrationStatus
    applied_at: Optional[datetime] = None
    rolled_back_at: Optional[datetime] = None
    execution_time: Optional[float] = None
    error_message: Optional[str] = None
    checksum: Optional[str] = None


# @dataclass
class MigrationFile
    #     """Represents a migration file."""
    #     path: str
    #     version: str
    #     description: str
    #     up_sql: str
    #     down_sql: str
    checksum: str = field(init=False)


class DatabaseMigrationManager
    #     """
    #     Migration manager for database schema evolution.

    #     Features:
    #     - Versioned migration tracking
    #     - Automatic rollback support
    #     - Migration validation
    #     - File-based migrations
    #     - Proper error handling with 4-digit error codes
    #     """

    #     def __init__(self, backend=None, migrations_dir: str = "migrations"):
    #         """
    #         Initialize migration manager.

    #         Args:
    #             backend: Optional database backend instance
    #             migrations_dir: Directory containing migration files
    #         """
    self.backend = backend
    self.migrations_dir = Path(migrations_dir)
    self.logger = logging.getLogger('noodlecore.database.migration_manager')
    self._migration_table = "schema_migrations"
    self._applied_migrations: Dict[str, MigrationRecord] = {}

            self.logger.info("Database migration manager initialized")

    #     def initialize(self) -> None:
    #         """Initialize the migration system."""
    #         try:
    #             # Create migrations directory if it doesn't exist
    self.migrations_dir.mkdir(exist_ok = True)

    #             # Create migration table if needed
                self._ensure_migration_table()

    #             # Load applied migrations
                self._load_applied_migrations()

                self.logger.info("Migration system initialized")
    #         except Exception as e:
    error_msg = f"Failed to initialize migration system: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6000)

    #     def create_migration(self, description: str) -> str:
    #         """
    #         Create a new migration file.

    #         Args:
    #             description: Description of the migration

    #         Returns:
    #             Path to the created migration file
    #         """
    #         try:
    #             # Generate version based on timestamp
    version = datetime.now().strftime("%Y%m%d_%H%M%S")

    #             # Generate filename
    filename = f"{version}_{description.replace(' ', '_').lower()}.sql"
    filepath = math.divide(self.migrations_dir, filename)

    #             # Generate migration content
    migration_content = self._generate_migration_template(version, description)

    #             # Write migration file
    #             with open(filepath, 'w') as f:
                    f.write(migration_content)

                self.logger.info(f"Created migration file: {filepath}")
                return str(filepath)
    #         except Exception as e:
    error_msg = f"Failed to create migration: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6001)

    #     def load_migrations(self) -> List[MigrationFile]:
    #         """
    #         Load all migration files.

    #         Returns:
    #             List of migration files sorted by version
    #         """
    #         try:
    migrations = []

    #             # Get all SQL files in migrations directory
    #             for filepath in self.migrations_dir.glob("*.sql"):
    migration = self._parse_migration_file(filepath)
    #                 if migration:
                        migrations.append(migration)

    #             # Sort by version
    migrations.sort(key = lambda m: m.version)

    #             return migrations
    #         except Exception as e:
    error_msg = f"Failed to load migrations: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6002)

    #     def get_pending_migrations(self) -> List[MigrationFile]:
    #         """
    #         Get list of pending migrations.

    #         Returns:
    #             List of migration files that haven't been applied
    #         """
    #         try:
    all_migrations = self.load_migrations()
    pending_migrations = []

    #             for migration in all_migrations:
    #                 if migration.version not in self._applied_migrations:
                        pending_migrations.append(migration)

    #             return pending_migrations
    #         except Exception as e:
    error_msg = f"Failed to get pending migrations: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6003)

    #     def get_applied_migrations(self) -> List[MigrationRecord]:
    #         """
    #         Get list of applied migrations.

    #         Returns:
    #             List of applied migration records
    #         """
            return list(self._applied_migrations.values())

    #     def migrate_up(self, target_version: Optional[str] = None) -> List[MigrationRecord]:
    #         """
    #         Apply pending migrations up to target version.

    #         Args:
    #             target_version: Optional target version to migrate to

    #         Returns:
    #             List of applied migration records
    #         """
    #         try:
    pending_migrations = self.get_pending_migrations()
    applied_records = []

    #             for migration in pending_migrations:
    #                 # Stop if target version reached
    #                 if target_version and migration.version > target_version:
    #                     break

    #                 # Apply migration
    record = self._apply_migration(migration)
                    applied_records.append(record)

                    self.logger.info(f"Applied migration: {migration.version}")

    #             return applied_records
    #         except Exception as e:
    error_msg = f"Migration up failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6004)

    #     def migrate_down(self, target_version: str) -> List[MigrationRecord]:
    #         """
    #         Rollback migrations down to target version.

    #         Args:
    #             target_version: Target version to rollback to

    #         Returns:
    #             List of rolled back migration records
    #         """
    #         try:
    #             # Get applied migrations in reverse order
    applied_migrations = sorted(
                    self.get_applied_migrations(),
    key = lambda r: r.version,
    reverse = True
    #             )

    rolled_back_records = []

    #             for record in applied_migrations:
    #                 # Stop if target version reached
    #                 if record.version <= target_version:
    #                     break

    #                 # Rollback migration
    updated_record = self._rollback_migration(record)
                    rolled_back_records.append(updated_record)

                    self.logger.info(f"Rolled back migration: {record.version}")

    #             return rolled_back_records
    #         except Exception as e:
    error_msg = f"Migration down failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6005)

    #     def validate_migrations(self) -> Dict[str, Any]:
    #         """
    #         Validate all migrations.

    #         Returns:
    #             Dictionary with validation results
    #         """
    #         try:
    results = {
    #                 "valid": True,
    #                 "errors": [],
    #                 "warnings": [],
    #                 "migrations": {}
    #             }

    #             # Load all migrations
    migrations = self.load_migrations()

    #             for migration in migrations:
    migration_result = self._validate_migration(migration)
    results["migrations"][migration.version] = migration_result

    #                 if not migration_result["valid"]:
    results["valid"] = False
                        results["errors"].extend(migration_result["errors"])

                    results["warnings"].extend(migration_result["warnings"])

    #             # Check for duplicate versions
    #             versions = [m.version for m in migrations]
    #             if len(versions) != len(set(versions)):
    results["valid"] = False
                    results["errors"].append("Duplicate migration versions found")

    #             # Check version ordering
    sorted_versions = sorted(versions)
    #             if versions != sorted_versions:
                    results["warnings"].append("Migrations are not in chronological order")

    #             return results
    #         except Exception as e:
    error_msg = f"Migration validation failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6006)

    #     def get_migration_status(self) -> Dict[str, Any]:
    #         """
    #         Get migration status information.

    #         Returns:
    #             Dictionary with migration status
    #         """
    #         try:
    pending_migrations = self.get_pending_migrations()
    applied_migrations = self.get_applied_migrations()

    #             return {
                    "total_migrations": len(pending_migrations) + len(applied_migrations),
                    "pending_count": len(pending_migrations),
                    "applied_count": len(applied_migrations),
    #                 "pending_migrations": [m.version for m in pending_migrations],
    #                 "applied_migrations": [r.version for r in applied_migrations],
    #                 "latest_applied": max([r.version for r in applied_migrations]) if applied_migrations else None,
    #                 "latest_pending": max([m.version for m in pending_migrations]) if pending_migrations else None
    #             }
    #         except Exception as e:
    error_msg = f"Failed to get migration status: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6007)

    #     def _ensure_migration_table(self) -> None:
    #         """Ensure the migration tracking table exists."""
    #         try:
    #             if not self._table_exists(self._migration_table):
    create_sql = f"""
                        CREATE TABLE {self._migration_table} (
                            version VARCHAR(50) PRIMARY KEY,
    #                         description TEXT,
                            status VARCHAR(20) NOT NULL DEFAULT 'pending',
    #                         applied_at TIMESTAMP,
    #                         rolled_back_at TIMESTAMP,
    #                         execution_time FLOAT,
    #                         error_message TEXT,
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

    #     def _load_applied_migrations(self) -> None:
    #         """Load applied migrations from database."""
    #         if not self.backend:
    #             return

    #         try:
    query = f"SELECT * FROM {self._migration_table} ORDER BY version"
    results = self.backend.fetch_all(query)

    #             for row in results:
    record = MigrationRecord(
    version = row["version"],
    status = MigrationStatus(row["status"]),
    applied_at = row.get("applied_at"),
    rolled_back_at = row.get("rolled_back_at"),
    execution_time = row.get("execution_time"),
    error_message = row.get("error_message"),
    checksum = row.get("checksum")
    #                 )
    self._applied_migrations[record.version] = record

                self.logger.info(f"Loaded {len(self._applied_migrations)} applied migrations")
    #         except Exception as e:
                self.logger.warning(f"Failed to load applied migrations: {str(e)}")

    #     def _parse_migration_file(self, filepath: Path) -> Optional[MigrationFile]:
    #         """Parse a migration file."""
    #         try:
    #             with open(filepath, 'r') as f:
    content = f.read()

    #             # Extract version and description from filename
    filename = filepath.stem
    parts = filename.split('_', 1)

    #             if len(parts) < 2:
                    self.logger.warning(f"Invalid migration filename: {filepath}")
    #                 return None

    version = parts[0]
    description = parts[1].replace('_', ' ')

    #             # Parse up and down SQL
    up_sql = ""
    down_sql = ""

    #             # Split by -- DOWN section
    #             if "-- DOWN" in content:
    up_sql, down_sql = content.split("-- DOWN", 1)
    up_sql = up_sql.replace("-- UP", "").strip()
    down_sql = down_sql.strip()
    #             else:
    up_sql = content.replace("-- UP", "").strip()

                return MigrationFile(
    path = str(filepath),
    version = version,
    description = description,
    up_sql = up_sql,
    down_sql = down_sql
    #             )
    #         except Exception as e:
                self.logger.warning(f"Failed to parse migration file {filepath}: {str(e)}")
    #             return None

    #     def _generate_migration_template(self, version: str, description: str) -> str:
    #         """Generate migration file template."""
    #         return f"""-- Migration: {version}
# -- Description: {description}

# -- UP
# -- Add your migration SQL here
# -- Example:
-- CREATE TABLE example_table (
# --     id INTEGER PRIMARY KEY,
--     name VARCHAR(255) NOT NULL
# -- );

# -- DOWN
# -- Add your rollback SQL here
# -- Example:
# -- DROP TABLE IF EXISTS example_table;
# """

#     def _apply_migration(self, migration: MigrationFile) -> MigrationRecord:
#         """Apply a migration."""
start_time = time.time()

#         try:
#             # Calculate checksum
checksum = self._calculate_migration_checksum(migration)

#             # Execute up SQL
#             if self.backend and migration.up_sql:
#                 # Split into individual statements
statements = self._split_sql_statements(migration.up_sql)

#                 for statement in statements:
#                     if statement.strip():
                        self.backend.execute_raw_sql(statement)

#             # Record migration
execution_time = math.subtract(time.time(), start_time)
record = MigrationRecord(
version = migration.version,
status = MigrationStatus.APPLIED,
applied_at = datetime.now(),
execution_time = execution_time,
checksum = checksum
#             )

            self._record_migration(record)
self._applied_migrations[migration.version] = record

#             return record
#         except Exception as e:
error_msg = f"Failed to apply migration {migration.version}: {str(e)}"
            self.logger.error(error_msg)

#             # Record failed migration
execution_time = math.subtract(time.time(), start_time)
record = MigrationRecord(
version = migration.version,
status = MigrationStatus.FAILED,
execution_time = execution_time,
error_message = error_msg
#             )

            self._record_migration(record)
self._applied_migrations[migration.version] = record

raise DatabaseError(error_msg, error_code = 6008)

#     def _rollback_migration(self, record: MigrationRecord) -> MigrationRecord:
#         """Rollback a migration."""
#         try:
#             # Load migration file
migration = None
#             for m in self.load_migrations():
#                 if m.version == record.version:
migration = m
#                     break

#             if not migration:
#                 raise DatabaseError(f"Migration file not found for version {record.version}", error_code=6009)

#             # Execute down SQL
#             if self.backend and migration.down_sql:
#                 # Split into individual statements
statements = self._split_sql_statements(migration.down_sql)

#                 for statement in statements:
#                     if statement.strip():
                        self.backend.execute_raw_sql(statement)

#             # Update record
record.status = MigrationStatus.ROLLED_BACK
record.rolled_back_at = datetime.now()

            self._update_migration_record(record)
self._applied_migrations[record.version] = record

#             return record
#         except Exception as e:
error_msg = f"Failed to rollback migration {record.version}: {str(e)}"
            self.logger.error(error_msg)
raise DatabaseError(error_msg, error_code = 6010)

#     def _validate_migration(self, migration: MigrationFile) -> Dict[str, Any]:
#         """Validate a migration file."""
result = {
#             "valid": True,
#             "errors": [],
#             "warnings": []
#         }

#         try:
#             # Check version format
#             if not migration.version.isdigit():
                result["errors"].append(f"Invalid version format: {migration.version}")
result["valid"] = False

#             # Check if up SQL exists
#             if not migration.up_sql.strip():
                result["errors"].append("Migration has no UP SQL")
result["valid"] = False

#             # Check if down SQL exists
#             if not migration.down_sql.strip():
                result["warnings"].append("Migration has no DOWN SQL")

            # Validate SQL syntax (basic check)
#             try:
#                 if self.backend:
#                     # Test with EXPLAIN if available
statements = self._split_sql_statements(migration.up_sql)
#                     for statement in statements:
#                         if statement.strip() and not statement.strip().startswith("--"):
#                             # Basic syntax check
#                             if statement.strip().upper().startswith(("SELECT", "INSERT", "UPDATE", "DELETE", "CREATE", "ALTER", "DROP")):
#                                 try:
                                    self.backend.execute_raw_sql(f"EXPLAIN {statement}")
#                                 except Exception:
#                                     # EXPLAIN might not be supported, skip syntax check
#                                     pass
#             except Exception as e:
                result["warnings"].append(f"Could not validate SQL syntax: {str(e)}")

#         except Exception as e:
            result["errors"].append(f"Validation error: {str(e)}")
result["valid"] = False

#         return result

#     def _calculate_migration_checksum(self, migration: MigrationFile) -> str:
#         """Calculate checksum for a migration."""
#         import hashlib

#         # Create a string representation of the migration
migration_str = f"{migration.version}:{migration.up_sql}:{migration.down_sql}"

#         # Calculate MD5 checksum
        return hashlib.md5(migration_str.encode()).hexdigest()

#     def _split_sql_statements(self, sql: str) -> List[str]:
#         """Split SQL into individual statements."""
statements = []
current_statement = ""

#         for line in sql.split('\n'):
line = line.strip()

#             # Skip comments and empty lines
#             if not line or line.startswith('--'):
#                 continue

current_statement + = line + '\n'

#             # Check if statement ends with semicolon
#             if line.endswith(';'):
                statements.append(current_statement.strip())
current_statement = ""

#         # Add any remaining statement
#         if current_statement.strip():
            statements.append(current_statement.strip())

#         return statements

#     def _record_migration(self, record: MigrationRecord) -> None:
#         """Record a migration in the database."""
#         if not self.backend:
#             return

#         try:
query = f"""
#                 INSERT INTO {self._migration_table}
                (version, description, status, applied_at, execution_time, error_message, checksum)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
#             """

            self.backend.execute_raw_sql(query, [
#                 record.version,
#                 "",  # Description could be loaded from file
#                 record.status.value,
#                 record.applied_at,
#                 record.execution_time,
#                 record.error_message,
#                 record.checksum
#             ])
#         except Exception as e:
            self.logger.warning(f"Failed to record migration {record.version}: {str(e)}")

#     def _update_migration_record(self, record: MigrationRecord) -> None:
#         """Update a migration record in the database."""
#         if not self.backend:
#             return

#         try:
query = f"""
#                 UPDATE {self._migration_table}
SET status = %s, rolled_back_at = %s
WHERE version = %s
#             """

            self.backend.execute_raw_sql(query, [
#                 record.status.value,
#                 record.rolled_back_at,
#                 record.version
#             ])
#         except Exception as e:
            self.logger.warning(f"Failed to update migration record {record.version}: {str(e)}")