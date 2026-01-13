# Converted from Python to NoodleCore
# Original file: src

# """
# Configuration Migration Module

# This module implements configuration versioning and migration system.
# """

import json
import logging
import shutil
import asyncio
import typing.Dict
import pathlib.Path
from dataclasses import dataclass
import datetime.datetime
import enum.Enum
import hashlib


class MigrationDirection(Enum)
    #     """Migration directions."""
    UP = "up"
    DOWN = "down"


class MigrationStatus(Enum)
    #     """Migration status."""
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    ROLLED_BACK = "rolled_back"


dataclass
class Migration
    #     """Migration definition."""
    #     version: str
    #     description: str
    #     up_migration: Callable[[Dict[str, Any]], Dict[str, Any]]
    down_migration: Optional[Callable[[Dict[str, Any]], Dict[str, Any]]] = None
    dependencies: List[str] = field(default_factory=list)
    timestamp: datetime = field(default_factory=datetime.now)
    checksum: Optional[str] = None


dataclass
class MigrationResult
    #     """Migration result."""
    #     migration: Migration
    #     status: MigrationStatus
    #     direction: MigrationDirection
    #     message: str
    #     start_time: datetime
    end_time: Optional[datetime] = None
    error: Optional[str] = None
    backup_path: Optional[str] = None


class ConfigMigrationError(Exception)
    #     """Configuration migration error with 4-digit error code."""

    #     def __init__(self, message: str, error_code: int = 4301):
    self.error_code = error_code
            super().__init__(message)


class ConfigMigration
    #     """Configuration versioning and migration system."""

    CURRENT_VERSION = "1.0.0"

    #     def __init__(self, config_dir: Optional[str] = None, backup_dir: Optional[str] = None):""
    #         Initialize the configuration migration system.

    #         Args:
    #             config_dir: Configuration directory
    #             backup_dir: Backup directory for migration backups
    #         """
    self.name = "ConfigMigration"
    self.logger = logging.getLogger(__name__)
    self.config_dir = Path(config_dir or "~/.noodle").expanduser()
    self.backup_dir = Path(backup_dir or "~/.noodle/migration_backups").expanduser()
    self.backup_dir.mkdir(parents = True, exist_ok=True)

    #         # Migration registry
    self._migrations: Dict[str, Migration] = {}
    self._migration_history: List[MigrationResult] = []

    #         # Migration state file
    self.state_file = self.config_dir / "migration_state.json"

    #         # Initialize built-in migrations
            self._initialize_builtin_migrations()

    #         # Load migration state
            self._load_migration_state()

    #     def _initialize_builtin_migrations(self):
    #         """Initialize built-in migrations."""

    #         # Migration 0.9.0 -1.0.0): Major schema restructure
            self.add_migration(Migration(
    version = "1.0.0",
    description = "Major configuration schema restructure",
    up_migration = self._migrate_090_to_100,
    down_migration = self._migrate_100_to_090,
    dependencies = []
    #         ))

    #         # Migration 0.8.0 -0.9.0): Add AI model configuration
            self.add_migration(Migration(
    version = "0.9.0",
    description = "Add AI model configuration structure",
    up_migration = self._migrate_080_to_090,
    down_migration = self._migrate_090_to_080,
    dependencies = []
    #         ))

    #         # Migration 0.7.0 -0.8.0): Add sandbox configuration
            self.add_migration(Migration(
    version = "0.8.0",
    description = "Add sandbox configuration section",
    up_migration = self._migrate_070_to_080,
    down_migration = self._migrate_080_to_070,
    dependencies = []
    #         ))

    #     def add_migration(self, migration: Migration):
    #         """
    #         Add a migration to the registry.

    #         Args:
    #             migration: Migration to add
    #         """
    #         # Calculate checksum
    migration.checksum = self._calculate_migration_checksum(migration)

    self._migrations[migration.version] = migration
            self.logger.debug(f"Added migration: {migration.version} - {migration.description}")

    #     def remove_migration(self, version: str) -bool):
    #         """
    #         Remove a migration from the registry.

    #         Args:
    #             version: Migration version to remove

    #         Returns:
    #             True if migration was removed, False if not found
    #         """
    #         if version in self._migrations:
    #             del self._migrations[version]
                self.logger.debug(f"Removed migration: {version}")
    #             return True
    #         return False

    #     def _calculate_migration_checksum(self, migration: Migration) -str):
    #         """Calculate checksum for migration."""
    content = f"{migration.version}{migration.description}{migration.timestamp.isoformat()}"
            return hashlib.sha256(content.encode()).hexdigest()[:16]

    #     def _load_migration_state(self):
    #         """Load migration state from file."""
    #         if self.state_file.exists():
    #             try:
    #                 with open(self.state_file, 'r', encoding='utf-8') as f:
    state_data = json.load(f)

    #                 # Load migration history
    #                 for result_data in state_data.get('migration_history', []):
    result = MigrationResult(
    migration = self._migrations.get(result_data['version'], None),
    status = MigrationStatus(result_data['status']),
    direction = MigrationDirection(result_data['direction']),
    message = result_data['message'],
    start_time = datetime.fromisoformat(result_data['start_time']),
    #                         end_time=datetime.fromisoformat(result_data['end_time']) if result_data.get('end_time') else None,
    error = result_data.get('error'),
    backup_path = result_data.get('backup_path')
    #                     )
                        self._migration_history.append(result)

    #             except Exception as e:
                    self.logger.warning(f"Failed to load migration state: {str(e)}")

    #     def _save_migration_state(self):
    #         """Save migration state to file."""
    #         try:
    state_data = {
                    'current_version': self.get_current_version(),
    #                 'migration_history': [
    #                     {
    #                         'version': result.migration.version if result.migration else 'unknown',
    #                         'status': result.status.value,
    #                         'direction': result.direction.value,
    #                         'message': result.message,
                            'start_time': result.start_time.isoformat(),
    #                         'end_time': result.end_time.isoformat() if result.end_time else None,
    #                         'error': result.error,
    #                         'backup_path': result.backup_path
    #                     }
    #                     for result in self._migration_history
    #                 ]
    #             }

    #             with open(self.state_file, 'w', encoding='utf-8') as f:
    json.dump(state_data, f, indent = 2)

    #         except Exception as e:
                self.logger.error(f"Failed to save migration state: {str(e)}")

    #     def get_current_version(self) -str):
    #         """
    #         Get the current configuration version.

    #         Returns:
    #             Current version string
    #         """
    #         if not self._migration_history:
    #             return "0.7.0"  # Earliest version

    #         # Get the latest successful migration
    #         successful_migrations = [r for r in self._migration_history
    #                                if r.status == MigrationStatus.COMPLETED
    and r.direction == MigrationDirection.UP]

    #         if successful_migrations:
    latest = max(successful_migrations, key=lambda r: r.start_time)
    #             return latest.migration.version

    #         return "0.7.0"

    #     def get_pending_migrations(self, target_version: Optional[str] = None) -List[Migration]):
    #         """
    #         Get pending migrations.

    #         Args:
                target_version: Target version (default: latest)

    #         Returns:
    #             List of pending migrations
    #         """
    current_version = self.get_current_version()
    target_version = target_version or self.CURRENT_VERSION

    #         # Get all versions between current and target
    all_versions = sorted(self._migrations.keys())
    #         current_index = all_versions.index(current_version) if current_version in all_versions else -1
    #         target_index = all_versions.index(target_version) if target_version in all_versions else len(all_versions) - 1

    pending_versions = all_versions[current_index + 1:target_index + 1]

    #         # Get migrations in dependency order
    pending_migrations = []
    #         for version in pending_versions:
    migration = self._migrations[version]

    #             # Check if dependencies are satisfied
    dependencies_satisfied = all(
    #                 dep in [r.migration.version for r in self._migration_history
    #                        if r.status == MigrationStatus.COMPLETED]
    #                 for dep in migration.dependencies
    #             )

    #             if dependencies_satisfied:
                    pending_migrations.append(migration)

    #         return pending_migrations

    #     async def migrate_up(self, target_version: Optional[str] = None, create_backup: bool = True) -Dict[str, Any]):
    #         """
    #         Migrate configuration up to target version.

    #         Args:
                target_version: Target version (default: latest)
    #             create_backup: Whether to create backup before migration

    #         Returns:
    #             Migration result
    #         """
    target_version = target_version or self.CURRENT_VERSION
    pending_migrations = self.get_pending_migrations(target_version)

    #         if not pending_migrations:
    #             return {
    #                 'success': True,
    #                 'message': f"Configuration is already at version {target_version}",
    #                 'migrations_performed': 0,
                    'current_version': self.get_current_version(),
    #                 'target_version': target_version
    #             }

    results = []

    #         try:
    #             # Create backup if requested
    backup_path = None
    #             if create_backup:
    backup_result = await self._create_backup()
    #                 if backup_result['success']:
    backup_path = backup_result['backup_path']
    #                 else:
    #                     return {
    #                         'success': False,
    #                         'error': f"Failed to create backup: {backup_result['error']}",
    #                         'error_code': 4302
    #                     }

    #             # Load current configuration
    config_file = self.config_dir / "config.json"
    #             if not config_file.exists():
    config_file = self.config_dir / "config.msgpack"

    #             if not config_file.exists():
    #                 return {
    #                     'success': False,
    #                     'error': "No configuration file found",
    #                     'error_code': 4303
    #                 }

    #             # Read configuration
    #             if config_file.suffix == '.json':
    #                 with open(config_file, 'r', encoding='utf-8') as f:
    config = json.load(f)
    #             else:
    #                 # TODO: Implement MessagePack reading
    #                 return {
    #                     'success': False,
    #                     'error': "MessagePack format not yet supported for migration",
    #                     'error_code': 4304
    #                 }

    #             # Apply migrations
    current_config = config.copy()
    #             for migration in pending_migrations:
    result = await self._apply_migration(migration, current_config, MigrationDirection.UP, backup_path)
                    results.append(result)

    #                 if result.status == MigrationStatus.COMPLETED:
    current_config = result.message  # Store migrated config
    #                 else:
    #                     # Migration failed, stop and rollback
                        await self._rollback_migrations(results[:-1])
    #                     return {
    #                         'success': False,
    #                         'error': f"Migration {migration.version} failed: {result.error}",
    #                         'error_code': 4305,
    #                         'failed_migration': migration.version,
                            'performed_migrations': len(results) - 1
    #                     }

    #             # Save migrated configuration
                await self._save_config(current_config)

    #             # Update migration state
                self._migration_history.extend(results)
                self._save_migration_state()

    #             return {
    #                 'success': True,
    #                 'message': f"Successfully migrated to version {target_version}",
                    'migrations_performed': len(results),
                    'current_version': self.get_current_version(),
    #                 'target_version': target_version,
    #                 'backup_path': backup_path,
    #                 'migration_results': [self._serialize_result(r) for r in results]
    #             }

    #         except Exception as e:
                self.logger.error(f"Migration failed: {str(e)}")
    #             return {
    #                 'success': False,
                    'error': f"Migration failed: {str(e)}",
    #                 'error_code': 4306
    #             }

    #     async def migrate_down(self, target_version: str, create_backup: bool = True) -Dict[str, Any]):
    #         """
    #         Migrate configuration down to target version.

    #         Args:
    #             target_version: Target version to migrate down to
    #             create_backup: Whether to create backup before migration

    #         Returns:
    #             Migration result
    #         """
    current_version = self.get_current_version()

    #         if current_version == target_version:
    #             return {
    #                 'success': True,
    #                 'message': f"Configuration is already at version {target_version}",
    #                 'migrations_performed': 0,
    #                 'current_version': current_version,
    #                 'target_version': target_version
    #             }

    #         # Get migrations to rollback
    all_versions = sorted(self._migrations.keys())
    #         current_index = all_versions.index(current_version) if current_version in all_versions else len(all_versions) - 1
    #         target_index = all_versions.index(target_version) if target_version in all_versions else 0

    rollback_versions = all_versions[target_index + 1:current_index + 1][::-1]  # Reverse order

    #         if not rollback_versions:
    #             return {
    #                 'success': False,
    #                 'error': f"Cannot migrate down from {current_version} to {target_version}",
    #                 'error_code': 4307
    #             }

    results = []

    #         try:
    #             # Create backup if requested
    backup_path = None
    #             if create_backup:
    backup_result = await self._create_backup()
    #                 if backup_result['success']:
    backup_path = backup_result['backup_path']
    #                 else:
    #                     return {
    #                         'success': False,
    #                         'error': f"Failed to create backup: {backup_result['error']}",
    #                         'error_code': 4302
    #                     }

    #             # Load current configuration
    config_file = self.config_dir / "config.json"
    #             if not config_file.exists():
    config_file = self.config_dir / "config.msgpack"

    #             if not config_file.exists():
    #                 return {
    #                     'success': False,
    #                     'error': "No configuration file found",
    #                     'error_code': 4303
    #                 }

    #             # Read configuration
    #             if config_file.suffix == '.json':
    #                 with open(config_file, 'r', encoding='utf-8') as f:
    config = json.load(f)
    #             else:
    #                 return {
    #                     'success': False,
    #                     'error': "MessagePack format not yet supported for migration",
    #                     'error_code': 4304
    #                 }

    #             # Apply rollback migrations
    current_config = config.copy()
    #             for version in rollback_versions:
    migration = self._migrations[version]

    #                 if migration.down_migration is None:
    #                     return {
    #                         'success': False,
    #                         'error': f"Migration {version} does not support rollback",
    #                         'error_code': 4308
    #                     }

    result = await self._apply_migration(migration, current_config, MigrationDirection.DOWN, backup_path)
                    results.append(result)

    #                 if result.status == MigrationStatus.COMPLETED:
    current_config = result.message  # Store migrated config
    #                 else:
    #                     # Rollback failed
    #                     return {
    #                         'success': False,
    #                         'error': f"Rollback migration {migration.version} failed: {result.error}",
    #                         'error_code': 4309,
    #                         'failed_migration': migration.version,
                            'performed_migrations': len(results) - 1
    #                     }

    #             # Save migrated configuration
                await self._save_config(current_config)

    #             # Update migration state
                self._migration_history.extend(results)
                self._save_migration_state()

    #             return {
    #                 'success': True,
    #                 'message': f"Successfully migrated down to version {target_version}",
                    'migrations_performed': len(results),
                    'current_version': self.get_current_version(),
    #                 'target_version': target_version,
    #                 'backup_path': backup_path,
    #                 'migration_results': [self._serialize_result(r) for r in results]
    #             }

    #         except Exception as e:
                self.logger.error(f"Down migration failed: {str(e)}")
    #             return {
    #                 'success': False,
                    'error': f"Down migration failed: {str(e)}",
    #                 'error_code': 4310
    #             }

    #     async def _apply_migration(self, migration: Migration, config: Dict[str, Any],
    #                              direction: MigrationDirection, backup_path: Optional[str]) -MigrationResult):
    #         """Apply a single migration."""
    start_time = datetime.now()

    #         try:
                self.logger.info(f"Applying migration {migration.version} ({direction.value})")

    #             if direction == MigrationDirection.UP:
    migrated_config = migration.up_migration(config)
    #             else:
    #                 if migration.down_migration is None:
                        raise ConfigMigrationError(f"Migration {migration.version} does not support rollback", 4311)
    migrated_config = migration.down_migration(config)

    end_time = datetime.now()

                return MigrationResult(
    migration = migration,
    status = MigrationStatus.COMPLETED,
    direction = direction,
    message = migrated_config,  # Store migrated config
    start_time = start_time,
    end_time = end_time,
    backup_path = backup_path
    #             )

    #         except Exception as e:
    end_time = datetime.now()
                self.logger.error(f"Migration {migration.version} failed: {str(e)}")

                return MigrationResult(
    migration = migration,
    status = MigrationStatus.FAILED,
    direction = direction,
    message = f"Migration failed: {str(e)}",
    start_time = start_time,
    end_time = end_time,
    error = str(e),
    backup_path = backup_path
    #             )

    #     async def _rollback_migrations(self, results: List[MigrationResult]):
    #         """Rollback applied migrations."""
    #         for result in reversed(results):
    #             try:
    #                 if result.migration.down_migration:
                        await self._apply_migration(
    #                         result.migration,
    #                         result.message,  # Use the migrated config
    #                         MigrationDirection.DOWN,
    #                         result.backup_path
    #                     )
    result.status = MigrationStatus.ROLLED_BACK
    #             except Exception as e:
                    self.logger.error(f"Failed to rollback migration {result.migration.version}: {str(e)}")

    #     async def _create_backup(self) -Dict[str, Any]):
    #         """Create backup of current configuration."""
    #         try:
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_name = f"config_backup_{timestamp}"
    backup_path = math.divide(self.backup_dir, backup_name)
    backup_path.mkdir(exist_ok = True)

    #             # Backup configuration files
    config_files = ["config.json", "config.msgpack", "config.backup.json"]
    backed_up_files = []

    #             for config_file in config_files:
    source = math.divide(self.config_dir, config_file)
    #                 if source.exists():
    dest = math.divide(backup_path, config_file)
                        shutil.copy2(source, dest)
                        backed_up_files.append(config_file)

    #             # Backup migration state
    #             if self.state_file.exists():
                    shutil.copy2(self.state_file, backup_path / "migration_state.json")
                    backed_up_files.append("migration_state.json")

    #             return {
    #                 'success': True,
    #                 'message': f"Backup created: {backup_path}",
                    'backup_path': str(backup_path),
    #                 'backup_name': backup_name,
    #                 'files_backed_up': backed_up_files
    #             }

    #         except Exception as e:
                self.logger.error(f"Failed to create backup: {str(e)}")
    #             return {
    #                 'success': False,
                    'error': f"Failed to create backup: {str(e)}",
    #                 'error_code': 4312
    #             }

    #     async def _save_config(self, config: Dict[str, Any]):
    #         """Save configuration to file."""
    config_file = self.config_dir / "config.json"

    #         with open(config_file, 'w', encoding='utf-8') as f:
    json.dump(config, f, indent = 2)

    #     def _serialize_result(self, result: MigrationResult) -Dict[str, Any]):
    #         """Serialize migration result to dictionary."""
    #         return {
    #             'migration_version': result.migration.version if result.migration else 'unknown',
    #             'status': result.status.value,
    #             'direction': result.direction.value,
    #             'message': result.message,
                'start_time': result.start_time.isoformat(),
    #             'end_time': result.end_time.isoformat() if result.end_time else None,
    #             'error': result.error,
    #             'backup_path': result.backup_path
    #         }

    #     # Built-in migration implementations
    #     def _migrate_070_to_080(self, config: Dict[str, Any]) -Dict[str, Any]):
    #         """Migrate from 0.7.0 to 0.8.0 - Add sandbox configuration."""
    config = config.copy()

    #         # Add sandbox section with defaults
    #         if 'sandbox' not in config:
    config['sandbox'] = {
    #                 'directory': '.project/.noodle/sandbox/',
    #                 'execution_timeout': 30,
    #                 'memory_limit': '2GB',
    #                 'cpu_limit': '50%',
    #                 'disk_limit': '1GB',
    #                 'network_enabled': False,
    #                 'security_level': 'medium'
    #             }

    #         # Update version
    config['version'] = '0.8.0'

    #         return config

    #     def _migrate_080_to_070(self, config: Dict[str, Any]) -Dict[str, Any]):
    #         """Migrate from 0.8.0 to 0.7.0 - Remove sandbox configuration."""
    config = config.copy()

    #         # Remove sandbox section
    #         if 'sandbox' in config:
    #             del config['sandbox']

    #         # Update version
    config['version'] = '0.7.0'

    #         return config

    #     def _migrate_080_to_090(self, config: Dict[str, Any]) -Dict[str, Any]):
    #         """Migrate from 0.8.0 to 0.9.0 - Add AI model configuration."""
    config = config.copy()

    #         # Add AI section with model structure
    #         if 'ai' not in config:
    config['ai'] = {
    #                 'default_model': 'zai_glm',
    #                 'models': {
    #                     'zai_glm': {
    #                         'provider': 'zai',
    #                         'api_base': 'https://open.bigmodel.cn/api/paas/v4/chat/completions',
    #                         'api_key': 'env:ZAI_API_KEY',
    #                         'model_name': 'glm-4-6',
    #                         'system_prompt': 'Je bent een NoodleCore-ontwikkelaar...'
    #                     }
    #                 }
    #             }
    #         else:
    #             # Migrate existing AI configuration
    ai_config = config['ai']
    #             if 'models' not in ai_config:
    #                 # Convert old AI config to new structure
    default_model = ai_config.get('default_model', 'zai_glm')
    ai_config['models'] = {
    #                     default_model: {
                            'provider': ai_config.get('provider', 'zai'),
                            'api_base': ai_config.get('api_base', 'https://open.bigmodel.cn/api/paas/v4/chat/completions'),
                            'api_key': ai_config.get('api_key', 'env:ZAI_API_KEY'),
                            'model_name': ai_config.get('model_name', 'glm-4-6'),
                            'system_prompt': ai_config.get('system_prompt', 'Je bent een NoodleCore-ontwikkelaar...')
    #                     }
    #                 }

    #         # Update version
    config['version'] = '0.9.0'

    #         return config

    #     def _migrate_090_to_080(self, config: Dict[str, Any]) -Dict[str, Any]):
    #         """Migrate from 0.9.0 to 0.8.0 - Remove AI model configuration."""
    config = config.copy()

    #         # Revert AI configuration
    #         if 'ai' in config:
    ai_config = config['ai']
    #             if 'models' in ai_config:
    #                 # Convert to old format using default model
    default_model = ai_config.get('default_model', 'zai_glm')
    #                 if default_model in ai_config['models']:
    model_config = ai_config['models'][default_model]
                        ai_config.update({
                            'provider': model_config.get('provider', 'zai'),
                            'api_base': model_config.get('api_base', 'https://open.bigmodel.cn/api/paas/v4/chat/completions'),
                            'api_key': model_config.get('api_key', 'env:ZAI_API_KEY'),
                            'model_name': model_config.get('model_name', 'glm-4-6'),
                            'system_prompt': model_config.get('system_prompt', 'Je bent een NoodleCore-ontwikkelaar...')
    #                     })
    #                 del ai_config['models']

    #         # Update version
    config['version'] = '0.8.0'

    #         return config

    #     def _migrate_090_to_100(self, config: Dict[str, Any]) -Dict[str, Any]):
    #         """Migrate from 0.9.0 to 1.0.0 - Major schema restructure."""
    config = config.copy()

    #         # Add new sections
    #         if 'validation' not in config:
    config['validation'] = {
    #                 'strict_mode': True,
    #                 'auto_fix': False,
    #                 'security_scan': True
    #             }

    #         if 'logging' not in config:
    config['logging'] = {
    #                 'level': 'INFO',
    #                 'format': 'json',
    #                 'outputs': ['file', 'console'],
    #                 'file_path': '.project/.noodle/logs/cli.log'
    #             }

    #         if 'ide' not in config:
    config['ide'] = {
    #                 'lsp_port': 8080,
    #                 'auto_start': True,
    #                 'real_time_validation': True
    #             }

    #         if 'performance' not in config:
    config['performance'] = {
    #                 'cache_enabled': True,
    #                 'cache_size': '100MB',
    #                 'cache_ttl': 3600
    #             }

    #         if 'security' not in config:
    config['security'] = {
    #                 'encryption_enabled': True,
    #                 'key_rotation_days': 90,
    #                 'audit_logging': True
    #             }

    #         # Update version
    config['version'] = '1.0.0'

    #         return config

    #     def _migrate_100_to_090(self, config: Dict[str, Any]) -Dict[str, Any]):
    #         """Migrate from 1.0.0 to 0.9.0 - Revert major schema restructure."""
    config = config.copy()

    #         # Remove new sections
    sections_to_remove = ['validation', 'logging', 'ide', 'performance', 'security']
    #         for section in sections_to_remove:
    #             if section in config:
    #                 del config[section]

    #         # Update version
    config['version'] = '0.9.0'

    #         return config

    #     async def get_migration_info(self) -Dict[str, Any]):
    #         """
    #         Get information about the migration system.

    #         Returns:
    #             Migration system information
    #         """
    #         return {
    #             'name': self.name,
    #             'version': '1.0.0',
                'current_version': self.get_current_version(),
    #             'latest_version': self.CURRENT_VERSION,
                'total_migrations': len(self._migrations),
                'migration_history_count': len(self._migration_history),
                'pending_migrations': len(self.get_pending_migrations()),
                'config_dir': str(self.config_dir),
                'backup_dir': str(self.backup_dir),
                'state_file': str(self.state_file),
    #             'features': [
    #                 'version_tracking',
    #                 'automatic_migration',
    #                 'rollback_support',
    #                 'backup_creation',
    #                 'dependency_resolution',
    #                 'migration_history',
    #                 'checksum_verification'
    #             ]
    #         }