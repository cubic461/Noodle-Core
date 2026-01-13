# Converted from Python to NoodleCore
# Original file: noodle-core

# """NoodleCore Database Backup Manager
 = ===================================

# Backup and restore utilities for database operations.
# Provides comprehensive backup/restore capabilities with compression.

# Implements database standards:
# - Full and incremental backups
# - Compression support
# - Restore validation
# - Proper error handling with 4-digit error codes
# """

import logging
import time
import uuid
import os
import gzip
import json
import shutil
import typing.Dict,
import dataclasses.dataclass,
import datetime.datetime
import enum.Enum
import pathlib.Path

import .errors.(
#     DatabaseError, QueryError, ConnectionError
# )


class BackupType(Enum)
    #     """Types of database backups."""
    FULL = "full"
    INCREMENTAL = "incremental"
    DIFFERENTIAL = "differential"


class BackupStatus(Enum)
    #     """Backup operation status."""
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"


# @dataclass
class BackupInfo
    #     """Information about a backup."""
    #     backup_id: str
    #     backup_type: BackupType
    #     status: BackupStatus
    created_at: datetime = field(default_factory=datetime.now)
    completed_at: Optional[datetime] = None
    file_path: Optional[str] = None
    file_size: Optional[int] = None
    compressed_size: Optional[int] = None
    table_count: Optional[int] = None
    record_count: Optional[int] = None
    checksum: Optional[str] = None
    parent_backup_id: Optional[str] = None
    description: Optional[str] = None
    error_message: Optional[str] = None


# @dataclass
class RestoreInfo
    #     """Information about a restore operation."""
    #     restore_id: str
    #     backup_id: str
    #     status: BackupStatus
    started_at: datetime = field(default_factory=datetime.now)
    completed_at: Optional[datetime] = None
    tables_restored: Optional[List[str]] = None
    records_restored: Optional[int] = None
    validation_passed: Optional[bool] = None
    error_message: Optional[str] = None


class DatabaseBackupManager
    #     """
    #     Backup manager for database operations.

    #     Features:
    #     - Full and incremental backups
    #     - Compression support
    #     - Restore validation
    #     - Backup scheduling
    #     - Proper error handling with 4-digit error codes
    #     """

    #     def __init__(self, backend=None, backup_dir: str = "backups"):
    #         """
    #         Initialize backup manager.

    #         Args:
    #             backend: Optional database backend instance
    #             backup_dir: Directory to store backups
    #         """
    self.backend = backend
    self.backup_dir = Path(backup_dir)
    self.logger = logging.getLogger('noodlecore.database.backup_manager')
    self._backups: Dict[str, BackupInfo] = {}
    self._restores: Dict[str, RestoreInfo] = {}

    #         # Ensure backup directory exists
    self.backup_dir.mkdir(exist_ok = True)

            self.logger.info("Database backup manager initialized")

    #     def create_backup(
    #         self,
    backup_type: BackupType = BackupType.FULL,
    tables: Optional[List[str]] = None,
    description: Optional[str] = None,
    compress: bool = True,
    parent_backup_id: Optional[str] = None
    #     ) -> str:
    #         """
    #         Create a database backup.

    #         Args:
    #             backup_type: Type of backup to create
    #             tables: Optional list of tables to backup
    #             description: Optional backup description
    #             compress: Whether to compress the backup
    #             parent_backup_id: Parent backup ID for incremental backups

    #         Returns:
    #             Backup ID

    #         Raises:
    #             DatabaseError: If backup creation fails
    #         """
    #         try:
    #             # Generate backup ID
    backup_id = str(uuid.uuid4())

    #             # Create backup info
    backup_info = BackupInfo(
    backup_id = backup_id,
    backup_type = backup_type,
    status = BackupStatus.PENDING,
    parent_backup_id = parent_backup_id,
    description = description
    #             )

    #             # Store backup info
    self._backups[backup_id] = backup_info

    #             # Start backup process
                self._perform_backup(backup_info, tables, compress)

                self.logger.info(f"Created backup: {backup_id}")
    #             return backup_id
    #         except Exception as e:
    error_msg = f"Failed to create backup: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6050)

    #     def restore_backup(
    #         self,
    #         backup_id: str,
    tables: Optional[List[str]] = None,
    validate_before_restore: bool = True,
    drop_existing_tables: bool = False
    #     ) -> str:
    #         """
    #         Restore a database backup.

    #         Args:
    #             backup_id: Backup ID to restore
    #             tables: Optional list of tables to restore
    #             validate_before_restore: Whether to validate before restore
    #             drop_existing_tables: Whether to drop existing tables

    #         Returns:
    #             Restore ID

    #         Raises:
    #             DatabaseError: If restore fails
    #         """
    #         try:
    #             # Check if backup exists
    #             if backup_id not in self._backups:
    raise DatabaseError(f"Backup {backup_id} not found", error_code = 6051)

    backup_info = self._backups[backup_id]

    #             # Check if backup is completed
    #             if backup_info.status != BackupStatus.COMPLETED:
    raise DatabaseError(f"Backup {backup_id} is not completed", error_code = 6052)

    #             # Generate restore ID
    restore_id = str(uuid.uuid4())

    #             # Create restore info
    restore_info = RestoreInfo(
    restore_id = restore_id,
    backup_id = backup_id,
    status = BackupStatus.PENDING
    #             )

    #             # Store restore info
    self._restores[restore_id] = restore_info

    #             # Start restore process
                self._perform_restore(restore_info, backup_info, tables, validate_before_restore, drop_existing_tables)

                self.logger.info(f"Started restore: {restore_id} from backup: {backup_id}")
    #             return restore_id
    #         except Exception as e:
    error_msg = f"Failed to restore backup {backup_id}: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6053)

    #     def list_backups(self, backup_type: Optional[BackupType] = None) -> List[BackupInfo]:
    #         """
    #         List available backups.

    #         Args:
    #             backup_type: Optional filter by backup type

    #         Returns:
    #             List of backup info
    #         """
    backups = list(self._backups.values())

    #         if backup_type:
    #             backups = [b for b in backups if b.backup_type == backup_type]

    #         # Sort by creation date
    backups.sort(key = lambda b: b.created_at, reverse=True)

    #         return backups

    #     def get_backup_info(self, backup_id: str) -> Optional[BackupInfo]:
    #         """
    #         Get information about a backup.

    #         Args:
    #             backup_id: Backup ID

    #         Returns:
    #             Backup info or None if not found
    #         """
            return self._backups.get(backup_id)

    #     def delete_backup(self, backup_id: str) -> bool:
    #         """
    #         Delete a backup.

    #         Args:
    #             backup_id: Backup ID to delete

    #         Returns:
    #             True if deleted successfully

    #         Raises:
    #             DatabaseError: If deletion fails
    #         """
    #         try:
    #             # Check if backup exists
    #             if backup_id not in self._backups:
    raise DatabaseError(f"Backup {backup_id} not found", error_code = 6054)

    backup_info = self._backups[backup_id]

    #             # Delete backup file
    #             if backup_info.file_path and os.path.exists(backup_info.file_path):
                    os.remove(backup_info.file_path)

    #             # Remove from backups
    #             del self._backups[backup_id]

                self.logger.info(f"Deleted backup: {backup_id}")
    #             return True
    #         except Exception as e:
    error_msg = f"Failed to delete backup {backup_id}: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6055)

    #     def validate_backup(self, backup_id: str) -> Dict[str, Any]:
    #         """
    #         Validate a backup.

    #         Args:
    #             backup_id: Backup ID to validate

    #         Returns:
    #             Validation results
    #         """
    #         try:
    #             # Check if backup exists
    #             if backup_id not in self._backups:
    raise DatabaseError(f"Backup {backup_id} not found", error_code = 6056)

    backup_info = self._backups[backup_id]

    #             # Check if backup file exists
    #             if not backup_info.file_path or not os.path.exists(backup_info.file_path):
    #                 return {
    #                     "valid": False,
    #                     "errors": ["Backup file not found"]
    #                 }

    #             # Validate file integrity
    validation_result = self._validate_backup_file(backup_info.file_path)

    #             return validation_result
    #         except Exception as e:
    error_msg = f"Failed to validate backup {backup_id}: {str(e)}"
                self.logger.error(error_msg)
    #             return {
    #                 "valid": False,
    #                 "errors": [error_msg]
    #             }

    #     def schedule_backup(
    #         self,
    #         backup_type: BackupType,
    #         schedule: str,
    tables: Optional[List[str]] = None,
    description: Optional[str] = None,
    compress: bool = True
    #     ) -> str:
    #         """
    #         Schedule a recurring backup.

    #         Args:
    #             backup_type: Type of backup to schedule
    #             schedule: Cron-style schedule
    #             tables: Optional list of tables to backup
    #             description: Optional backup description
    #             compress: Whether to compress the backup

    #         Returns:
    #             Schedule ID
    #         """
    #         # This would integrate with a job scheduler
    #         # For now, just return a mock schedule ID
    schedule_id = str(uuid.uuid4())

            self.logger.info(f"Scheduled backup: {schedule_id}")
    #         return schedule_id

    #     def _perform_backup(
    #         self,
    #         backup_info: BackupInfo,
    #         tables: Optional[List[str]],
    #         compress: bool
    #     ) -> None:
    #         """Perform the actual backup operation."""
    #         try:
    #             # Update status
    backup_info.status = BackupStatus.IN_PROGRESS

    #             # Generate backup filename
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"backup_{backup_info.backup_id}_{timestamp}.json"
    #             if compress:
    filename + = ".gz"

    file_path = math.divide(self.backup_dir, filename)

    #             # Get table list
    #             if not tables:
    tables = self._get_all_tables()

    #             # Backup data
    backup_data = {}
    total_records = 0

    #             for table in tables:
    table_data = self._backup_table(table)
    #                 if table_data:
    backup_data[table] = table_data
    total_records + = len(table_data.get("records", []))

    #             # Create backup file
    backup_content = {
    #                 "backup_id": backup_info.backup_id,
    #                 "backup_type": backup_info.backup_type.value,
                    "created_at": backup_info.created_at.isoformat(),
    #                 "tables": backup_data
    #             }

    #             # Write backup file
    #             if compress:
    #                 with gzip.open(file_path, 'wt', encoding='utf-8') as f:
    json.dump(backup_content, f, indent = 2)
    #             else:
    #                 with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(backup_content, f, indent = 2)

    #             # Update backup info
    backup_info.status = BackupStatus.COMPLETED
    backup_info.completed_at = datetime.now()
    backup_info.file_path = str(file_path)
    backup_info.file_size = os.path.getsize(file_path)
    backup_info.table_count = len(backup_data)
    backup_info.record_count = total_records
    backup_info.checksum = self._calculate_file_checksum(file_path)

                self.logger.info(f"Backup completed: {backup_info.backup_id}")
    #         except Exception as e:
    #             # Update backup info with error
    backup_info.status = BackupStatus.FAILED
    backup_info.error_message = str(e)

                self.logger.error(f"Backup failed: {backup_info.backup_id} - {str(e)}")
    #             raise

    #     def _perform_restore(
    #         self,
    #         restore_info: RestoreInfo,
    #         backup_info: BackupInfo,
    #         tables: Optional[List[str]],
    #         validate_before_restore: bool,
    #         drop_existing_tables: bool
    #     ) -> None:
    #         """Perform the actual restore operation."""
    #         try:
    #             # Update status
    restore_info.status = BackupStatus.IN_PROGRESS

    #             # Load backup file
    #             if not backup_info.file_path or not os.path.exists(backup_info.file_path):
    raise DatabaseError(f"Backup file not found: {backup_info.file_path}", error_code = 6057)

    #             # Read backup file
    #             if backup_info.file_path.endswith('.gz'):
    #                 with gzip.open(backup_info.file_path, 'rt', encoding='utf-8') as f:
    backup_content = json.load(f)
    #             else:
    #                 with open(backup_info.file_path, 'r', encoding='utf-8') as f:
    backup_content = json.load(f)

    #             # Validate backup content
    #             if validate_before_restore:
    validation_result = self._validate_backup_content(backup_content)
    #                 if not validation_result["valid"]:
    raise DatabaseError(f"Backup validation failed: {validation_result['errors']}", error_code = 6058)

    #             # Get tables to restore
    backup_tables = backup_content.get("tables", {})
    #             if tables:
    #                 # Filter tables
    #                 backup_tables = {k: v for k, v in backup_tables.items() if k in tables}

    tables_restored = []
    records_restored = 0

    #             # Restore each table
    #             for table_name, table_data in backup_tables.items():
    #                 if drop_existing_tables:
                        self._drop_table(table_name)

    #                 # Restore table structure
                    self._restore_table_structure(table_name, table_data)

    #                 # Restore table data
    record_count = self._restore_table_data(table_name, table_data)

                    tables_restored.append(table_name)
    records_restored + = record_count

    #             # Update restore info
    restore_info.status = BackupStatus.COMPLETED
    restore_info.completed_at = datetime.now()
    restore_info.tables_restored = tables_restored
    restore_info.records_restored = records_restored
    restore_info.validation_passed = True

                self.logger.info(f"Restore completed: {restore_info.restore_id}")
    #         except Exception as e:
    #             # Update restore info with error
    restore_info.status = BackupStatus.FAILED
    restore_info.error_message = str(e)

                self.logger.error(f"Restore failed: {restore_info.restore_id} - {str(e)}")
    #             raise

    #     def _backup_table(self, table_name: str) -> Optional[Dict[str, Any]]:
    #         """Backup a single table."""
    #         try:
    #             if not self.backend:
    #                 return None

    #             # Get table structure
    structure = self._get_table_structure(table_name)

    #             # Get table data
    records = self._get_table_data(table_name)

    #             return {
    #                 "structure": structure,
    #                 "records": records
    #             }
    #         except Exception as e:
                self.logger.warning(f"Failed to backup table {table_name}: {str(e)}")
    #             return None

    #     def _restore_table_structure(self, table_name: str, table_data: Dict[str, Any]) -> None:
    #         """Restore table structure."""
    #         try:
    structure = table_data.get("structure", {})
    #             if not structure:
    #                 return

    #             # Create table based on structure
    #             # This would need to be implemented based on the backend
    #             if self.backend:
    #                 # Generate CREATE TABLE statement from structure
    create_sql = self._generate_create_table_sql(table_name, structure)
                    self.backend.execute_raw_sql(create_sql)

                self.logger.info(f"Restored table structure: {table_name}")
    #         except Exception as e:
                self.logger.error(f"Failed to restore table structure {table_name}: {str(e)}")
    #             raise

    #     def _restore_table_data(self, table_name: str, table_data: Dict[str, Any]) -> int:
    #         """Restore table data."""
    #         try:
    records = table_data.get("records", [])
    #             if not records:
    #                 return 0

    #             # Insert records
    #             if self.backend:
    #                 for record in records:
    #                     # Generate INSERT statement
    insert_sql = self._generate_insert_sql(table_name, record)
                        self.backend.execute_raw_sql(insert_sql)

                self.logger.info(f"Restored {len(records)} records to table: {table_name}")
                return len(records)
    #         except Exception as e:
                self.logger.error(f"Failed to restore table data {table_name}: {str(e)}")
    #             raise

    #     def _get_all_tables(self) -> List[str]:
    #         """Get all table names from the database."""
    #         if not self.backend:
    #             return []

    #         try:
    query = """
    #                 SELECT table_name
    #                 FROM information_schema.tables
    WHERE table_schema = 'public'
    #                 ORDER BY table_name
    #             """
    result = self.backend.fetch_all(query)
    #             return [row["table_name"] for row in result]
    #         except Exception as e:
                self.logger.warning(f"Failed to get table list: {str(e)}")
    #             return []

    #     def _get_table_structure(self, table_name: str) -> Dict[str, Any]:
    #         """Get table structure information."""
    #         if not self.backend:
    #             return {}

    #         try:
    query = """
    #                 SELECT column_name, data_type, is_nullable, column_default
    #                 FROM information_schema.columns
    WHERE table_name = %s
    #                 ORDER BY ordinal_position
    #             """
    result = self.backend.fetch_all(query, [table_name])

    structure = {}
    #             for row in result:
    structure[row["column_name"]] = {
    #                     "type": row["data_type"],
    "nullable": row["is_nullable"] = = "YES",
    #                     "default": row["column_default"]
    #                 }

    #             return structure
    #         except Exception as e:
                self.logger.warning(f"Failed to get table structure {table_name}: {str(e)}")
    #             return {}

    #     def _get_table_data(self, table_name: str) -> List[Dict[str, Any]]:
    #         """Get all data from a table."""
    #         if not self.backend:
    #             return []

    #         try:
    query = f"SELECT * FROM {table_name}"
    result = self.backend.fetch_all(query)

    #             # Convert to list of dictionaries
    #             return [dict(row) for row in result]
    #         except Exception as e:
                self.logger.warning(f"Failed to get table data {table_name}: {str(e)}")
    #             return []

    #     def _drop_table(self, table_name: str) -> None:
    #         """Drop a table if it exists."""
    #         try:
    #             if self.backend:
    drop_sql = f"DROP TABLE IF EXISTS {table_name}"
                    self.backend.execute_raw_sql(drop_sql)

                self.logger.info(f"Dropped table: {table_name}")
    #         except Exception as e:
                self.logger.warning(f"Failed to drop table {table_name}: {str(e)}")

    #     def _generate_create_table_sql(self, table_name: str, structure: Dict[str, Any]) -> str:
    #         """Generate CREATE TABLE SQL from structure."""
    columns = []

    #         for column_name, column_info in structure.items():
    #             column_def = f"{column_name} {column_info['type']}"

    #             if not column_info.get("nullable", True):
    #                 column_def += " NOT NULL"

    #             if column_info.get("default"):
    #                 column_def += f" DEFAULT {column_info['default']}"

                columns.append(column_def)

            return f"CREATE TABLE {table_name} (\n    " + ",\n    ".join(columns) + "\n)"

    #     def _generate_insert_sql(self, table_name: str, record: Dict[str, Any]) -> str:
    #         """Generate INSERT SQL from record."""
    columns = list(record.keys())
    values = []

    #         for value in record.values():
    #             if value is None:
                    values.append("NULL")
    #             elif isinstance(value, str):
    escaped_value = value.replace("'", "''")
                    values.append(f"'{escaped_value}'")
    #             else:
                    values.append(str(value))

    columns_str = ", ".join(columns)
    values_str = ", ".join(values)

            return f"INSERT INTO {table_name} ({columns_str}) VALUES ({values_str})"

    #     def _validate_backup_file(self, file_path: str) -> Dict[str, Any]:
    #         """Validate backup file integrity."""
    #         try:
    #             # Check file size
    file_size = os.path.getsize(file_path)
    #             if file_size == 0:
    #                 return {
    #                     "valid": False,
    #                     "errors": ["Backup file is empty"]
    #                 }

    #             # Try to read the file
    #             if file_path.endswith('.gz'):
    #                 with gzip.open(file_path, 'rt', encoding='utf-8') as f:
    content = json.load(f)
    #             else:
    #                 with open(file_path, 'r', encoding='utf-8') as f:
    content = json.load(f)

    #             # Validate content structure
    #             if not isinstance(content, dict):
    #                 return {
    #                     "valid": False,
    #                     "errors": ["Invalid backup file format"]
    #                 }

    required_keys = ["backup_id", "backup_type", "created_at", "tables"]
    #             missing_keys = [key for key in required_keys if key not in content]

    #             if missing_keys:
    #                 return {
    #                     "valid": False,
                        "errors": [f"Missing required keys: {', '.join(missing_keys)}"]
    #                 }

    #             return {
    #                 "valid": True,
    #                 "errors": []
    #             }
    #         except Exception as e:
    #             return {
    #                 "valid": False,
                    "errors": [f"File validation error: {str(e)}"]
    #             }

    #     def _validate_backup_content(self, backup_content: Dict[str, Any]) -> Dict[str, Any]:
    #         """Validate backup content structure."""
    #         try:
    errors = []

    #             # Check required keys
    required_keys = ["backup_id", "backup_type", "created_at", "tables"]
    #             missing_keys = [key for key in required_keys if key not in backup_content]

    #             if missing_keys:
                    errors.append(f"Missing required keys: {', '.join(missing_keys)}")

    #             # Validate tables
    tables = backup_content.get("tables", {})
    #             if not isinstance(tables, dict):
                    errors.append("Tables must be a dictionary")

    #             for table_name, table_data in tables.items():
    #                 if not isinstance(table_data, dict):
                        errors.append(f"Table {table_name} data must be a dictionary")
    #                     continue

    #                 # Check table structure
    #                 if "structure" not in table_data:
                        errors.append(f"Table {table_name} missing structure")

    #                 # Check table records
    #                 if "records" not in table_data:
                        errors.append(f"Table {table_name} missing records")
    #                 elif not isinstance(table_data["records"], list):
                        errors.append(f"Table {table_name} records must be a list")

    #             return {
    "valid": len(errors) = = 0,
    #                 "errors": errors
    #             }
    #         except Exception as e:
    #             return {
    #                 "valid": False,
                    "errors": [f"Content validation error: {str(e)}"]
    #             }

    #     def _calculate_file_checksum(self, file_path: str) -> str:
    #         """Calculate MD5 checksum of a file."""
    #         import hashlib

    hash_md5 = hashlib.md5()

    #         with open(file_path, "rb") as f:
    #             for chunk in iter(lambda: f.read(4096), b""):
                    hash_md5.update(chunk)

            return hash_md5.hexdigest()