# Converted from Python to NoodleCore
# Original file: src

# """
# Configuration Manager Module

# This module implements the centralized configuration manager for NoodleCore CLI with
# MessagePack support, hot-reload capabilities, and integration with all configuration components.
# """

import json
import os
import logging
import asyncio
import msgpack
import typing.Dict
import pathlib.Path
from dataclasses import dataclass
import datetime.datetime
import enum.Enum
import copy
import threading
import time

import .config_schema.ConfigSchema
import .environment_manager.EnvironmentManager
import .config_validator.ConfigValidator
import .config_migration.ConfigMigration
import .profile_manager.ProfileManager
import .secure_storage.SecureStorage


class SerializationFormat(Enum)
    #     """Supported serialization formats."""
    MSGPACK = "msgpack"
    JSON = "json"
    YAML = "yaml"


class ConfigSource(Enum)
    #     """Configuration source types."""
    DEFAULT = "default"
    FILE = "file"
    ENVIRONMENT = "environment"
    PROFILE = "profile"
    COMMAND_LINE = "command_line"


dataclass
class ConfigChange
    #     """Configuration change record."""
    #     key: str
    #     old_value: Any
    #     new_value: Any
    #     source: ConfigSource
    timestamp: datetime = field(default_factory=datetime.now)
    metadata: Dict[str, Any] = field(default_factory=dict)


class ConfigManagerError(Exception)
    #     """Configuration manager error with 4-digit error code."""

    #     def __init__(self, message: str, error_code: int = 4601):
    self.error_code = error_code
            super().__init__(message)


class ConfigManager
    #     """Centralized configuration manager for NoodleCore CLI."""

    DEFAULT_CONFIG_DIR = "~/.noodle"
    DEFAULT_CONFIG_FILE = "config.msgpack"
    DEFAULT_BACKUP_FILE = "config.backup.json"
    DEFAULT_SECURE_DIR = "secure"
    DEFAULT_PROJECT_CONFIG = ".project/.noodle/config.local"

    #     def __init__(self, config_dir: Optional[str] = None, profile_name: Optional[str] = None,
    hot_reload: bool = True, auto_migrate: bool = True, encryption_enabled: bool = True):""
    #         Initialize the configuration manager.

    #         Args:
    #             config_dir: Configuration directory
    #             profile_name: Profile name to use
    #             hot_reload: Enable hot-reload capabilities
    #             auto_migrate: Enable automatic migration
    #             encryption_enabled: Enable encryption for sensitive data
    #         """
    self.name = "ConfigManager"
    self.logger = logging.getLogger(__name__)

    #         # Configuration paths
    self.config_dir = Path(config_dir or self.DEFAULT_CONFIG_DIR).expanduser()
    self.config_dir.mkdir(parents = True, exist_ok=True)

    self.config_file = math.divide(self.config_dir, self.DEFAULT_CONFIG_FILE)
    self.backup_file = math.divide(self.config_dir, self.DEFAULT_BACKUP_FILE)
    self.project_config_file = Path(self.DEFAULT_PROJECT_CONFIG).expanduser()

    #         # Settings
    self.hot_reload = hot_reload
    self.auto_migrate = auto_migrate
    self.encryption_enabled = encryption_enabled
    self.serialization_format = SerializationFormat.MSGPACK

    #         # Initialize components
    self._schema = ConfigSchema()
    self._environment_manager = EnvironmentManager()
    self._validator = ConfigValidator()
    self._migration = ConfigMigration(str(self.config_dir))
    self._profile_manager = ProfileManager(str(self.config_dir / "profiles"))

    #         if encryption_enabled:
    self._secure_storage = math.divide(SecureStorage(str(self.config_dir, self.DEFAULT_SECURE_DIR)))
    #         else:
    self._secure_storage = None

    #         # Configuration state
    self._config: Dict[str, Any] = {}
    self._active_profile: Optional[str] = profile_name
    self._config_sources: Dict[str, ConfigSource] = {}
    self._change_listeners: List[Callable[[ConfigChange], None]] = []
    self._last_modified: Optional[float] = None

    #         # Hot-reload state
    self._reload_thread: Optional[threading.Thread] = None
    self._reload_running = False
    self._reload_interval = 1.0  # seconds

    #         # Performance metrics
    self._load_count = 0
    self._save_count = 0
    self._reload_count = 0

    #         # Initialize configuration
            asyncio.create_task(self._initialize())

    #     async def _initialize(self):
    #         """Initialize the configuration manager."""
    #         try:
    #             # Load default configuration
    self._config = self._schema.get_schema()

    #             # Load configuration in hierarchy order
                await self._load_configuration_hierarchy()

    #             # Run automatic migration if enabled
    #             if self.auto_migrate:
                    await self._run_auto_migration()

    #             # Validate final configuration
    validation_result = await self._validator.validate(self._config)
    #             if not validation_result['valid']:
                    self.logger.warning(f"Configuration validation failed: {validation_result['errors']}")

    #             # Start hot-reload if enabled
    #             if self.hot_reload:
                    self._start_hot_reload()

                self.logger.info("Configuration manager initialized successfully")

    #         except Exception as e:
                self.logger.error(f"Failed to initialize configuration manager: {str(e)}")
                raise ConfigManagerError(f"Initialization failed: {str(e)}", 4602)

    #     async def _load_configuration_hierarchy(self):
            """Load configuration in hierarchy order (env vars config files > defaults)."""
            # 1. Load defaults (already done in _initialize)

    #         # 2. Load profile configuration
    #         if self._active_profile):
    profile_result = await self._profile_manager.get_active_profile()
    #             if profile_result['success']:
    profile_config = profile_result['profile']['config']
                    self._merge_config(profile_config, ConfigSource.PROFILE)

    #         # 3. Load project-specific configuration
    #         if self.project_config_file.exists():
    project_config = await self._load_config_file(self.project_config_file)
    #             if project_config:
                    self._merge_config(project_config, ConfigSource.FILE)

    #         # 4. Load main configuration file
    #         if self.config_file.exists():
    main_config = await self._load_config_file(self.config_file)
    #             if main_config:
                    self._merge_config(main_config, ConfigSource.FILE)

            # 5. Load environment variables (highest priority)
    env_config = await self._load_environment_config()
    #         if env_config:
                self._merge_config(env_config, ConfigSource.ENVIRONMENT)

    #     async def _load_config_file(self, file_path: Path) -Optional[Dict[str, Any]]):
    #         """Load configuration from file."""
    #         try:
    #             if file_path.suffix == '.msgpack':
    #                 with open(file_path, 'rb') as f:
    return msgpack.unpack(f, raw = False)
    #             elif file_path.suffix == '.json':
    #                 with open(file_path, 'r', encoding='utf-8') as f:
                        return json.load(f)
    #             else:
                    self.logger.warning(f"Unsupported config file format: {file_path.suffix}")
    #                 return None

    #         except Exception as e:
                self.logger.error(f"Failed to load config from {file_path}: {str(e)}")
    #             return None

    #     async def _load_environment_config(self) -Dict[str, Any]):
    #         """Load configuration from environment variables."""
    env_config = {}

    #         # Get all NOODLE_ environment variables
    env_vars = await self._environment_manager.list(include_sensitive=False)

    #         for var in env_vars['variables']:
    key = var['name']
    #             if key.startswith('NOODLE_'):
    #                 # Convert environment variable to config key
    config_key = key[7:].lower()  # Remove NOODLE_ prefix and lowercase

                    # Convert nested keys (e.g., NOODLE_AI_DEFAULT_MODEL -ai.default_model)
    #                 if '_' in config_key):
    parts = config_key.split('_')
    current = env_config
    #                     for part in parts[:-1]:
    #                         if part not in current:
    current[part] = {}
    current = current[part]
    current[parts[-1]] = var['value']
    #                 else:
    env_config[config_key] = var['value']

    #         return env_config

    #     def _merge_config(self, new_config: Dict[str, Any], source: ConfigSource):
    #         """Merge new configuration with existing configuration."""
    #         def deep_merge(base: Dict, update: Dict) -Dict):
    result = copy.deepcopy(base)
    #             for key, value in update.items():
    #                 if key in result and isinstance(result[key], dict) and isinstance(value, dict):
    result[key] = deep_merge(result[key], value)
    #                 else:
    result[key] = value
    #             return result

    #         # Track changes
    old_config = copy.deepcopy(self._config)
    self._config = deep_merge(self._config, new_config)

    #         # Record configuration sources
    #         def record_sources(config: Dict, prefix: str = ""):
    #             for key, value in config.items():
    #                 full_key = f"{prefix}.{key}" if prefix else key
    self._config_sources[full_key] = source

    #                 if isinstance(value, dict):
                        record_sources(value, full_key)

            record_sources(new_config)

    #         # Notify listeners of changes
            self._notify_changes(old_config, self._config, source)

    #     def _notify_changes(self, old_config: Dict[str, Any], new_config: Dict[str, Any], source: ConfigSource):
    #         """Notify listeners of configuration changes."""
    #         def find_changes(old: Dict, new: Dict, prefix: str = ""):
    changes = []

    #             # Check for changed and new values
    #             for key, new_value in new.items():
    #                 full_key = f"{prefix}.{key}" if prefix else key

    #                 if key not in old:
                        changes.append(ConfigChange(full_key, None, new_value, source))
    #                 elif isinstance(old[key], dict) and isinstance(new_value, dict):
                        changes.extend(find_changes(old[key], new_value, full_key))
    #                 elif old[key] != new_value:
                        changes.append(ConfigChange(full_key, old[key], new_value, source))

    #             # Check for deleted values
    #             for key, old_value in old.items():
    #                 if key not in new:
    #                     full_key = f"{prefix}.{key}" if prefix else key
                        changes.append(ConfigChange(full_key, old_value, None, source))

    #             return changes

    changes = find_changes(old_config, new_config)

    #         for change in changes:
    #             for listener in self._change_listeners:
    #                 try:
    #                     if asyncio.iscoroutinefunction(listener):
                            asyncio.create_task(listener(change))
    #                     else:
                            listener(change)
    #                 except Exception as e:
                        self.logger.error(f"Change listener failed: {str(e)}")

    #     async def _run_auto_migration(self):
    #         """Run automatic configuration migration."""
    #         try:
    current_version = self._config.get('version', '0.7.0')
    latest_version = self._migration.CURRENT_VERSION

    #             if current_version != latest_version:
                    self.logger.info(f"Migrating configuration from {current_version} to {latest_version}")

    migration_result = await self._migration.migrate_up(latest_version)
    #                 if migration_result['success']:
    self._config = migration_result.get('migrated_config', self._config)
                        await self.save_config()
                        self.logger.info("Configuration migration completed successfully")
    #                 else:
                        self.logger.error(f"Configuration migration failed: {migration_result['error']}")

    #         except Exception as e:
                self.logger.error(f"Auto-migration failed: {str(e)}")

    #     def _start_hot_reload(self):
    #         """Start hot-reload monitoring."""
    #         if self._reload_thread is None or not self._reload_thread.is_alive():
    self._reload_running = True
    self._reload_thread = threading.Thread(target=self._reload_worker, daemon=True)
                self._reload_thread.start()
                self.logger.debug("Hot-reload monitoring started")

    #     def _reload_worker(self):
    #         """Hot-reload worker thread."""
    #         while self._reload_running:
    #             try:
    #                 if self.config_file.exists():
    current_modified = self.config_file.stat().st_mtime

    #                     if self._last_modified is None:
    self._last_modified = current_modified
    #                     elif current_modified self._last_modified):
                            self.logger.debug("Configuration file changed, reloading")
                            asyncio.create_task(self._reload_config())
    self._last_modified = current_modified
    self._reload_count + = 1

                    time.sleep(self._reload_interval)

    #             except Exception as e:
                    self.logger.error(f"Hot-reload worker error: {str(e)}")
                    time.sleep(self._reload_interval)

    #     async def _reload_config(self):
    #         """Reload configuration from file."""
    #         try:
    old_config = copy.deepcopy(self._config)

    #             # Reload configuration hierarchy
                await self._load_configuration_hierarchy()

    #             # Validate reloaded configuration
    validation_result = await self._validator.validate(self._config)
    #             if not validation_result['valid']:
                    self.logger.warning(f"Reloaded configuration validation failed: {validation_result['errors']}")

    self._load_count + = 1

    #         except Exception as e:
                self.logger.error(f"Failed to reload configuration: {str(e)}")

    #     def add_change_listener(self, listener: Callable[[ConfigChange], None]):
    #         """Add a configuration change listener."""
            self._change_listeners.append(listener)

    #     def remove_change_listener(self, listener: Callable[[ConfigChange], None]):
    #         """Remove a configuration change listener."""
    #         if listener in self._change_listeners:
                self._change_listeners.remove(listener)

    #     async def get(self, key: str, default: Any = None) -Any):
    #         """
    #         Get a configuration value.

    #         Args:
                key: Configuration key (supports dot notation)
    #             default: Default value if key not found

    #         Returns:
    #             Configuration value
    #         """
    #         try:
    keys = key.split('.')
    value = self._config

    #             for k in keys:
    #                 if isinstance(value, dict) and k in value:
    value = value[k]
    #                 else:
    #                     return default

    #             return value

    #         except Exception as e:
                self.logger.error(f"Failed to get config key '{key}': {str(e)}")
    #             return default

    #     async def set(self, key: str, value: Any, source: ConfigSource = ConfigSource.COMMAND_LINE,
    persist: bool = True) - Dict[str, Any]):
    #         """
    #         Set a configuration value.

    #         Args:
                key: Configuration key (supports dot notation)
    #             value: Configuration value
    #             source: Configuration source
    #             persist: Whether to persist to file

    #         Returns:
    #             Operation result
    #         """
    #         try:
    keys = key.split('.')
    old_value = await self.get(key)

    #             # Navigate to the parent of the target key
    config = self._config
    #             for k in keys[:-1]:
    #                 if k not in config:
    config[k] = {}
    config = config[k]

    #             # Set the value
    config[keys[-1]] = value
    self._config_sources[key] = source

    #             # Notify listeners
    change = ConfigChange(key, old_value, value, source)
    #             for listener in self._change_listeners:
    #                 try:
    #                     if asyncio.iscoroutinefunction(listener):
                            await listener(change)
    #                     else:
                            listener(change)
    #                 except Exception as e:
                        self.logger.error(f"Change listener failed: {str(e)}")

    #             # Persist if requested
    #             if persist:
    save_result = await self.save_config()
    #                 if not save_result['success']:
    #                     return save_result

    #             return {
    #                 'success': True,
    #                 'message': f"Configuration key '{key}' set successfully",
    #                 'key': key,
    #                 'old_value': old_value,
    #                 'new_value': value
    #             }

    #         except Exception as e:
                self.logger.error(f"Failed to set config key '{key}': {str(e)}")
    #             return {
    #                 'success': False,
                    'error': f"Failed to set configuration: {str(e)}",
    #                 'error_code': 4603
    #             }

    #     async def save_config(self, create_backup: bool = True) -Dict[str, Any]):
    #         """
    #         Save configuration to file.

    #         Args:
    #             create_backup: Whether to create backup before saving

    #         Returns:
    #             Save result
    #         """
    #         try:
    #             # Create backup if requested
    #             if create_backup and self.config_file.exists():
    backup_path = self.backup_file
    #                 if self.config_file.suffix == '.msgpack':
    #                     # Convert to JSON for backup
    #                     with open(self.config_file, 'rb') as src:
    config_data = msgpack.unpack(src, raw=False)
    #                     with open(backup_path, 'w', encoding='utf-8') as dst:
    json.dump(config_data, dst, indent = 2)
    #                 else:
    #                     import shutil
                        shutil.copy2(self.config_file, backup_path)

    #             # Save configuration
    #             if self.serialization_format == SerializationFormat.MSGPACK:
    #                 with open(self.config_file, 'wb') as f:
                        msgpack.pack(self._config, f)
    #             else:
    #                 with open(self.config_file, 'w', encoding='utf-8') as f:
    json.dump(self._config, f, indent = 2)

    self._save_count + = 1
    self._last_modified = time.time()

    #             return {
    #                 'success': True,
    #                 'message': f"Configuration saved to {self.config_file}",
                    'file_path': str(self.config_file),
    #                 'format': self.serialization_format.value,
    #                 'backup_created': create_backup
    #             }

    #         except Exception as e:
                self.logger.error(f"Failed to save configuration: {str(e)}")
    #             return {
    #                 'success': False,
                    'error': f"Failed to save configuration: {str(e)}",
    #                 'error_code': 4604
    #             }

    #     async def validate_config(self) -Dict[str, Any]):
    #         """
    #         Validate the current configuration.

    #         Returns:
    #             Validation result
    #         """
            return await self._validator.validate(self._config)

    #     async def switch_profile(self, profile_name: str) -Dict[str, Any]):
    #         """
    #         Switch to a different configuration profile.

    #         Args:
    #             profile_name: Profile name to switch to

    #         Returns:
    #             Switch result
    #         """
    #         try:
    #             # Activate profile
    activate_result = await self._profile_manager.activate_profile(profile_name)
    #             if not activate_result['success']:
    #                 return activate_result

    #             # Reload configuration with new profile
    self._active_profile = profile_name
                await self._load_configuration_hierarchy()

    #             # Validate new configuration
    validation_result = await self.validate_config()
    #             if not validation_result['valid']:
                    self.logger.warning(f"Profile configuration validation failed: {validation_result['errors']}")

    #             return {
    #                 'success': True,
    #                 'message': f"Switched to profile '{profile_name}'",
    #                 'profile_name': profile_name,
                    'validation_errors': validation_result.get('errors', [])
    #             }

    #         except Exception as e:
                self.logger.error(f"Failed to switch profile: {str(e)}")
    #             return {
    #                 'success': False,
                    'error': f"Failed to switch profile: {str(e)}",
    #                 'error_code': 4605
    #             }

    #     async def export_config(self, file_path: str, format_type: str = "json",
    include_sensitive: bool = False) - Dict[str, Any]):
    #         """
    #         Export configuration to file.

    #         Args:
    #             file_path: Export file path
                format_type: Export format (json, msgpack, yaml)
    #             include_sensitive: Whether to include sensitive data

    #         Returns:
    #             Export result
    #         """
    #         try:
    #             # Prepare configuration for export
    export_config = copy.deepcopy(self._config)

    #             if not include_sensitive:
    #                 # Remove sensitive data
                    await self._remove_sensitive_data(export_config)

    #             # Export in specified format
    #             if format_type == "json":
    #                 with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(export_config, f, indent = 2)
    #             elif format_type == "msgpack":
    #                 with open(file_path, 'wb') as f:
                        msgpack.pack(export_config, f)
    #             else:
    #                 return {
    #                     'success': False,
    #                     'error': f"Unsupported export format: {format_type}",
    #                     'error_code': 4606
    #                 }

    #             return {
    #                 'success': True,
    #                 'message': f"Configuration exported to {file_path}",
    #                 'file_path': file_path,
    #                 'format': format_type,
    #                 'sensitive_included': include_sensitive
    #             }

    #         except Exception as e:
                self.logger.error(f"Failed to export configuration: {str(e)}")
    #             return {
    #                 'success': False,
                    'error': f"Failed to export configuration: {str(e)}",
    #                 'error_code': 4607
    #             }

    #     async def _remove_sensitive_data(self, config: Dict[str, Any]):
    #         """Remove sensitive data from configuration."""
    sensitive_keys = ['password', 'api_key', 'secret', 'token', 'key']

    #         def remove_sensitive(obj):
    #             if isinstance(obj, dict):
    keys_to_remove = []
    #                 for key, value in obj.items():
    #                     if any(sensitive in key.lower() for sensitive in sensitive_keys):
                            keys_to_remove.append(key)
    #                     elif isinstance(value, (dict, list)):
                            remove_sensitive(value)

    #                 for key in keys_to_remove:
    obj[key] = "***REDACTED***"

    #             elif isinstance(obj, list):
    #                 for item in obj:
    #                     if isinstance(item, (dict, list)):
                            remove_sensitive(item)

            remove_sensitive(config)

    #     async def get_config_info(self) -Dict[str, Any]):
    #         """
    #         Get information about the configuration manager.

    #         Returns:
    #             Configuration manager information
    #         """
    #         return {
    #             'name': self.name,
    #             'version': '2.0.0',
                'config_dir': str(self.config_dir),
                'config_file': str(self.config_file),
    #             'active_profile': self._active_profile,
    #             'serialization_format': self.serialization_format.value,
    #             'hot_reload_enabled': self.hot_reload,
    #             'auto_migrate_enabled': self.auto_migrate,
    #             'encryption_enabled': self.encryption_enabled,
    #             'metrics': {
    #                 'load_count': self._load_count,
    #                 'save_count': self._save_count,
    #                 'reload_count': self._reload_count
    #             },
    #             'components': {
    #                 'schema': self._schema.name,
    #                 'environment_manager': self._environment_manager.name,
    #                 'validator': self._validator.name,
    #                 'migration': self._migration.name,
    #                 'profile_manager': self._profile_manager.name,
    #                 'secure_storage': self._secure_storage.name if self._secure_storage else None
    #             },
    #             'features': [
    #                 'hierarchical_configuration',
    #                 'messagepack_support',
    #                 'hot_reload',
    #                 'profile_management',
    #                 'environment_integration',
    #                 'configuration_validation',
    #                 'automatic_migration',
    #                 'secure_storage',
    #                 'change_notifications',
    #                 'configuration_export'
    #             ]
    #         }

    #     async def cleanup(self):
    #         """Cleanup resources."""
    #         try:
    #             # Stop hot-reload
    self._reload_running = False
    #             if self._reload_thread and self._reload_thread.is_alive():
    self._reload_thread.join(timeout = 2.0)

                self.logger.info("Configuration manager cleaned up")

    #         except Exception as e:
                self.logger.error(f"Failed to cleanup configuration manager: {str(e)}")