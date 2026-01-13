# Converted from Python to NoodleCore
# Original file: src

# """
# Environment Manager Module

# This module implements environment variable management with NOODLE_ prefix enforcement.
# """

import os
import json
import logging
import asyncio
import typing.Dict
import pathlib.Path
from dataclasses import dataclass
import datetime.datetime
import enum.Enum


class EnvironmentType(Enum)
    #     """Environment types."""
    DEVELOPMENT = "development"
    PRODUCTION = "production"
    TESTING = "testing"
    STAGING = "staging"


dataclass
class EnvironmentVariable
    #     """Environment variable definition."""
    #     name: str
    #     value: str
    type: str = "string"  # string, int, float, bool, json
    required: bool = False
    default: Optional[str] = None
    description: str = ""
    sensitive: bool = False
    encrypted: bool = False
    created_at: datetime = field(default_factory=datetime.now)
    updated_at: datetime = field(default_factory=datetime.now)


class EnvironmentManagerError(Exception)
    #     """Environment manager error with 4-digit error code."""

    #     def __init__(self, message: str, error_code: int = 4101):
    self.error_code = error_code
            super().__init__(message)


class EnvironmentManager
    #     """Environment variable manager with NOODLE_ prefix enforcement."""

    NOODLE_PREFIX = "NOODLE_"

    #     def __init__(self, env_file: Optional[str] = None, backup_dir: Optional[str] = None):""
    #         Initialize the environment manager.

    #         Args:
    #             env_file: Path to .env file
    #             backup_dir: Directory for environment backups
    #         """
    self.name = "EnvironmentManager"
    self.logger = logging.getLogger(__name__)
    self.env_file = Path(env_file or ".env")
    self.backup_dir = Path(backup_dir or "~/.noodle/env_backups").expanduser()
    self.backup_dir.mkdir(parents = True, exist_ok=True)

    #         # Environment variable definitions
    self._variables: Dict[str, EnvironmentVariable] = {}
    self._change_callbacks: List[Callable[[str, str, str], None]] = []
    self._last_snapshot: Dict[str, str] = {}

    #         # Initialize default environment variables
            self._initialize_default_variables()

    #         # Load current environment
            self._load_environment()

    #     def _initialize_default_variables(self):
    #         """Initialize default NOODLE_ environment variables."""
    default_vars = {
                "NOODLE_ENV": EnvironmentVariable(
    name = "NOODLE_ENV",
    value = "development",
    type = "string",
    default = "development",
    description = "NoodleCore environment (development, production, testing, staging)"
    #             ),
                "NOODLE_DEBUG": EnvironmentVariable(
    name = "NOODLE_DEBUG",
    value = "0",
    type = "bool",
    default = "0",
    description = "Enable debug mode (1 or 0)"
    #             ),
                "NOODLE_LOG_LEVEL": EnvironmentVariable(
    name = "NOODLE_LOG_LEVEL",
    value = "INFO",
    type = "string",
    default = "INFO",
    description = "Log level (DEBUG, INFO, WARNING, ERROR)"
    #             ),
                "NOODLE_CONFIG_DIR": EnvironmentVariable(
    name = "NOODLE_CONFIG_DIR",
    value = "~/.noodle",
    type = "string",
    default = "~/.noodle",
    description = "Configuration directory path"
    #             ),
                "NOODLE_DATA_DIR": EnvironmentVariable(
    name = "NOODLE_DATA_DIR",
    value = "~/.noodle/data",
    type = "string",
    default = "~/.noodle/data",
    description = "Data directory path"
    #             ),
                "NOODLE_CACHE_DIR": EnvironmentVariable(
    name = "NOODLE_CACHE_DIR",
    value = "~/.noodle/cache",
    type = "string",
    default = "~/.noodle/cache",
    description = "Cache directory path"
    #             ),
                "NOODLE_PORT": EnvironmentVariable(
    name = "NOODLE_PORT",
    value = "8080",
    type = "int",
    default = "8080",
    #                 description="Default port for NoodleCore services"
    #             ),
                "NOODLE_HOST": EnvironmentVariable(
    name = "NOODLE_HOST",
    value = "0.0.0.0",
    type = "string",
    default = "0.0.0.0",
    #                 description="Default host for NoodleCore services"
    #             ),
                "NOODLE_SECURE_KEY": EnvironmentVariable(
    name = "NOODLE_SECURE_KEY",
    value = "",
    type = "string",
    sensitive = True,
    encrypted = True,
    #                 description="Encryption key for secure storage"
    #             ),
                "NOODLE_DB_PASSWORD": EnvironmentVariable(
    name = "NOODLE_DB_PASSWORD",
    value = "",
    type = "string",
    sensitive = True,
    encrypted = True,
    description = "Database password"
    #             ),
                "NOODLE_ZAI_API_KEY": EnvironmentVariable(
    name = "NOODLE_ZAI_API_KEY",
    value = "",
    type = "string",
    sensitive = True,
    encrypted = True,
    #                 description="ZAI API key for AI services"
    #             ),
                "NOODLE_OPENROUTER_API_KEY": EnvironmentVariable(
    name = "NOODLE_OPENROUTER_API_KEY",
    value = "",
    type = "string",
    sensitive = True,
    encrypted = True,
    #                 description="OpenRouter API key for AI services"
    #             ),
                "NOODLE_MAX_MEMORY": EnvironmentVariable(
    name = "NOODLE_MAX_MEMORY",
    value = "2GB",
    type = "string",
    default = "2GB",
    description = "Maximum memory usage"
    #             ),
                "NOODLE_MAX_CPU": EnvironmentVariable(
    name = "NOODLE_MAX_CPU",
    value = "50%",
    type = "string",
    default = "50%",
    description = "Maximum CPU usage"
    #             ),
                "NOODLE_TIMEOUT": EnvironmentVariable(
    name = "NOODLE_TIMEOUT",
    value = "30",
    type = "int",
    default = "30",
    description = "Default timeout in seconds"
    #             ),
                "NOODLE_PROFILE": EnvironmentVariable(
    name = "NOODLE_PROFILE",
    value = "default",
    type = "string",
    default = "default",
    description = "Configuration profile name"
    #             )
    #         }

            self._variables.update(default_vars)

    #     def _load_environment(self):
    #         """Load environment variables from .env file and system environment."""
    #         # Load from .env file if it exists
    #         if self.env_file.exists():
    #             try:
    #                 with open(self.env_file, 'r', encoding='utf-8') as f:
    #                     for line in f:
    line = line.strip()
    #                         if line and not line.startswith('#') and '=' in line:
    key, value = line.split('=', 1)
    key = key.strip()
    value = value.strip().strip('"\'')

    #                             if key.startswith(self.NOODLE_PREFIX):
    self._variables[key] = EnvironmentVariable(
    name = key,
    value = value,
    type = self._infer_type(value),
    updated_at = datetime.now()
    #                                 )
    #             except Exception as e:
                    self.logger.warning(f"Failed to load .env file: {str(e)}")

    #         # Load from system environment
    #         for key, value in os.environ.items():
    #             if key.startswith(self.NOODLE_PREFIX):
    #                 if key not in self._variables:
    self._variables[key] = EnvironmentVariable(
    name = key,
    value = value,
    type = self._infer_type(value)
    #                     )
    #                 else:
    #                     # Update existing variable
    self._variables[key].value = value
    self._variables[key].updated_at = datetime.now()

    #         # Create snapshot for change detection
    #         self._last_snapshot = {k: v.value for k, v in self._variables.items()}

    #     def _infer_type(self, value: str) -str):
    #         """Infer variable type from value."""
    #         if value.lower() in ('true', 'false', '1', '0'):
    #             return "bool"
    #         elif value.isdigit():
    #             return "int"
    #         elif self._is_float(value):
    #             return "float"
    #         elif value.startswith(('{', '[')):
    #             return "json"
    #         else:
    #             return "string"

    #     def _is_float(self, value: str) -bool):
    #         """Check if value can be converted to float."""
    #         try:
                float(value)
    #             return True
    #         except ValueError:
    #             return False

    #     def _convert_value(self, value: str, target_type: str) -Any):
    #         """Convert value to target type."""
    #         try:
    #             if target_type == "bool":
                    return value.lower() in ('true', '1', 'yes', 'on')
    #             elif target_type == "int":
                    return int(value)
    #             elif target_type == "float":
                    return float(value)
    #             elif target_type == "json":
                    return json.loads(value)
    #             else:
    #                 return value
            except (ValueError, json.JSONDecodeError) as e:
                raise EnvironmentManagerError(
                    f"Cannot convert value '{value}' to type {target_type}: {str(e)}",
    #                 4102
    #             )

    #     def _validate_noodle_prefix(self, key: str) -bool):
    #         """Validate that key has NOODLE_ prefix."""
    #         if not key.startswith(self.NOODLE_PREFIX):
                raise EnvironmentManagerError(
    #                 f"Environment variable '{key}' must start with '{self.NOODLE_PREFIX}'",
    #                 4103
    #             )
    #         return True

    #     async def get(self, key: str, default: Any = None) -Any):
    #         """
    #         Get environment variable value.

    #         Args:
    #             key: Environment variable name (must start with NOODLE_)
    #             default: Default value if not found

    #         Returns:
    #             Environment variable value converted to appropriate type
    #         """
            self._validate_noodle_prefix(key)

    #         if key not in self._variables:
    #             return default

    var = self._variables[key]
            return self._convert_value(var.value, var.type)

    #     async def set(self, key: str, value: Any, persist: bool = True, encrypt: bool = False) -Dict[str, Any]):
    #         """
    #         Set environment variable value.

    #         Args:
    #             key: Environment variable name (must start with NOODLE_)
    #             value: Value to set
    #             persist: Whether to persist to .env file
    #             encrypt: Whether to encrypt the value

    #         Returns:
    #             Operation result
    #         """
            self._validate_noodle_prefix(key)

    #         try:
    #             # Convert value to string
    #             if isinstance(value, (dict, list)):
    str_value = json.dumps(value)
    var_type = "json"
    #             elif isinstance(value, bool):
    #                 str_value = "1" if value else "0"
    var_type = "bool"
    #             elif isinstance(value, int):
    str_value = str(value)
    var_type = "int"
    #             elif isinstance(value, float):
    str_value = str(value)
    var_type = "float"
    #             else:
    str_value = str(value)
    var_type = "string"

    #             # Get old value for change detection
    old_value = self._variables.get(key, EnvironmentVariable(key, "")).value

    #             # Update variable
    #             if key in self._variables:
    self._variables[key].value = str_value
    self._variables[key].type = var_type
    self._variables[key].updated_at = datetime.now()
    self._variables[key].encrypted = encrypt
    #             else:
    self._variables[key] = EnvironmentVariable(
    name = key,
    value = str_value,
    type = var_type,
    encrypted = encrypt
    #                 )

    #             # Set in system environment
    os.environ[key] = str_value

    #             # Persist to .env file if requested
    #             if persist:
                    await self._save_to_file()

    #             # Notify change callbacks
    #             if old_value != str_value:
                    await self._notify_change(key, old_value, str_value)

    #             return {
    #                 'success': True,
    #                 'message': f"Environment variable '{key}' set successfully",
    #                 'key': key,
    #                 'encrypted': encrypt,
    #                 'persisted': persist
    #             }

    #         except Exception as e:
                self.logger.error(f"Failed to set environment variable '{key}': {str(e)}")
    #             return {
    #                 'success': False,
                    'error': f"Failed to set environment variable: {str(e)}",
    #                 'error_code': 4104
    #             }

    #     async def delete(self, key: str, persist: bool = True) -Dict[str, Any]):
    #         """
    #         Delete environment variable.

    #         Args:
    #             key: Environment variable name (must start with NOODLE_)
    #             persist: Whether to persist changes to .env file

    #         Returns:
    #             Operation result
    #         """
            self._validate_noodle_prefix(key)

    #         if key not in self._variables:
    #             return {
    #                 'success': False,
    #                 'error': f"Environment variable '{key}' not found",
    #                 'error_code': 4105
    #             }

    #         try:
    #             # Remove from memory
    old_value = self._variables[key].value
    #             del self._variables[key]

    #             # Remove from system environment
    #             if key in os.environ:
    #                 del os.environ[key]

    #             # Persist to .env file if requested
    #             if persist:
                    await self._save_to_file()

    #             # Notify change callbacks
                await self._notify_change(key, old_value, None)

    #             return {
    #                 'success': True,
    #                 'message': f"Environment variable '{key}' deleted successfully",
    #                 'key': key
    #             }

    #         except Exception as e:
                self.logger.error(f"Failed to delete environment variable '{key}': {str(e)}")
    #             return {
    #                 'success': False,
                    'error': f"Failed to delete environment variable: {str(e)}",
    #                 'error_code': 4106
    #             }

    #     async def list(self, include_sensitive: bool = False, filter_prefix: Optional[str] = None) -Dict[str, Any]):
    #         """
    #         List environment variables.

    #         Args:
    #             include_sensitive: Whether to include sensitive variables
                filter_prefix: Filter by prefix (default: NOODLE_)

    #         Returns:
    #             List of environment variables
    #         """
    prefix = filter_prefix or self.NOODLE_PREFIX
    variables = []

    #         for key, var in self._variables.items():
    #             if key.startswith(prefix):
    #                 if var.sensitive and not include_sensitive:
                        variables.append({
    #                         'name': var.name,
    #                         'type': var.type,
    #                         'required': var.required,
    #                         'default': var.default,
    #                         'description': var.description,
    #                         'sensitive': True,
    #                         'encrypted': var.encrypted,
    #                         'value': '***REDACTED***',
                            'created_at': var.created_at.isoformat(),
                            'updated_at': var.updated_at.isoformat()
    #                     })
    #                 else:
                        variables.append({
    #                         'name': var.name,
    #                         'value': var.value,
    #                         'type': var.type,
    #                         'required': var.required,
    #                         'default': var.default,
    #                         'description': var.description,
    #                         'sensitive': var.sensitive,
    #                         'encrypted': var.encrypted,
                            'created_at': var.created_at.isoformat(),
                            'updated_at': var.updated_at.isoformat()
    #                     })

    #         return {
    #             'success': True,
    #             'variables': variables,
                'count': len(variables),
    #             'prefix': prefix
    #         }

    #     async def validate(self) -Dict[str, Any]):
    #         """
    #         Validate environment variables.

    #         Returns:
    #             Validation result
    #         """
    errors = []
    warnings = []

    #         for key, var in self._variables.items():
    #             # Check required variables
    #             if var.required and not var.value:
                    errors.append(f"Required environment variable '{key}' is not set")

    #             # Validate type conversion
    #             try:
                    self._convert_value(var.value, var.type)
    #             except Exception as e:
                    errors.append(f"Environment variable '{key}' has invalid type: {str(e)}")

    #             # Check sensitive variables
    #             if var.sensitive and not var.encrypted and var.value:
                    warnings.append(f"Sensitive environment variable '{key}' is not encrypted")

    #         # Check for non-NOODLE_ variables
    #         for key in os.environ:
    #             if not key.startswith(self.NOODLE_PREFIX) and 'NOODLE' in key.upper():
    #                 warnings.append(f"Environment variable '{key}' contains 'NOODLE' but doesn't start with '{self.NOODLE_PREFIX}'")

    #         return {
    'valid': len(errors) = = 0,
    #             'errors': errors,
    #             'warnings': warnings,
                'total_variables': len(self._variables)
    #         }

    #     async def backup(self, backup_name: Optional[str] = None) -Dict[str, Any]):
    #         """
    #         Create backup of environment variables.

    #         Args:
    #             backup_name: Name for backup (default: timestamp)

    #         Returns:
    #             Backup result
    #         """
    #         if not backup_name:
    backup_name = datetime.now().strftime("%Y%m%d_%H%M%S")

    backup_file = self.backup_dir / f"env_backup_{backup_name}.json"

    #         try:
    backup_data = {
                    'timestamp': datetime.now().isoformat(),
    #                 'name': backup_name,
    #                 'variables': {
    #                     key: {
    #                         'value': var.value if not var.sensitive else '***ENCRYPTED***',
    #                         'type': var.type,
    #                         'required': var.required,
    #                         'default': var.default,
    #                         'description': var.description,
    #                         'sensitive': var.sensitive,
    #                         'encrypted': var.encrypted,
                            'created_at': var.created_at.isoformat(),
                            'updated_at': var.updated_at.isoformat()
    #                     }
    #                     for key, var in self._variables.items()
    #                 }
    #             }

    #             with open(backup_file, 'w', encoding='utf-8') as f:
    json.dump(backup_data, f, indent = 2)

    #             return {
    #                 'success': True,
    #                 'message': f"Environment backup created: {backup_file}",
                    'backup_file': str(backup_file),
    #                 'backup_name': backup_name,
                    'variables_count': len(self._variables)
    #             }

    #         except Exception as e:
                self.logger.error(f"Failed to create environment backup: {str(e)}")
    #             return {
    #                 'success': False,
                    'error': f"Failed to create backup: {str(e)}",
    #                 'error_code': 4107
    #             }

    #     async def restore(self, backup_name: str, merge: bool = False) -Dict[str, Any]):
    #         """
    #         Restore environment variables from backup.

    #         Args:
    #             backup_name: Name of backup to restore
    #             merge: Whether to merge with existing variables or replace

    #         Returns:
    #             Restore result
    #         """
    backup_file = self.backup_dir / f"env_backup_{backup_name}.json"

    #         if not backup_file.exists():
    #             return {
    #                 'success': False,
    #                 'error': f"Backup file not found: {backup_file}",
    #                 'error_code': 4108
    #             }

    #         try:
    #             with open(backup_file, 'r', encoding='utf-8') as f:
    backup_data = json.load(f)

    #             if not merge:
                    self._variables.clear()

    restored_count = 0
    #             for key, var_data in backup_data['variables'].items():
    self._variables[key] = EnvironmentVariable(
    name = key,
    value = var_data['value'],
    type = var_data['type'],
    required = var_data.get('required', False),
    default = var_data.get('default'),
    description = var_data.get('description', ''),
    sensitive = var_data.get('sensitive', False),
    encrypted = var_data.get('encrypted', False),
    created_at = datetime.fromisoformat(var_data['created_at']),
    updated_at = datetime.fromisoformat(var_data['updated_at'])
    #                 )

    #                 # Set in system environment
    #                 if not var_data.get('sensitive', False) or var_data['value'] != '***ENCRYPTED***':
    os.environ[key] = var_data['value']

    restored_count + = 1

    #             # Save to .env file
                await self._save_to_file()

    #             return {
    #                 'success': True,
    #                 'message': f"Environment restored from backup: {backup_name}",
    #                 'backup_name': backup_name,
    #                 'restored_variables': restored_count,
    #                 'merge': merge
    #             }

    #         except Exception as e:
                self.logger.error(f"Failed to restore environment backup: {str(e)}")
    #             return {
    #                 'success': False,
                    'error': f"Failed to restore backup: {str(e)}",
    #                 'error_code': 4109
    #             }

    #     async def _save_to_file(self):
    #         """Save environment variables to .env file."""
    #         try:
    #             with open(self.env_file, 'w', encoding='utf-8') as f:
                    f.write("# NoodleCore Environment Variables\n")
                    f.write("# Generated automatically - do not edit manually\n\n")

    #                 for key, var in sorted(self._variables.items()):
    #                     if var.sensitive and var.encrypted:
                            f.write(f"# {var.description}\n")
    f.write(f"# {key} = ***ENCRYPTED***\n\n")
    #                     else:
                            f.write(f"# {var.description}\n")
    f.write(f"{key} = {var.value}\n\n")

    #         except Exception as e:
                raise EnvironmentManagerError(f"Failed to save environment file: {str(e)}", 4110)

    #     async def _notify_change(self, key: str, old_value: Optional[str], new_value: Optional[str]):
    #         """Notify change callbacks of environment variable changes."""
    #         for callback in self._change_callbacks:
    #             try:
    #                 if asyncio.iscoroutinefunction(callback):
                        await callback(key, old_value, new_value)
    #                 else:
                        callback(key, old_value, new_value)
    #             except Exception as e:
    #                 self.logger.error(f"Change callback failed for variable '{key}': {str(e)}")

    #     def add_change_callback(self, callback: Callable[[str, str, str], None]):
    #         """
    #         Add callback for environment variable changes.

    #         Args:
                callback: Callback function (key, old_value, new_value)
    #         """
            self._change_callbacks.append(callback)

    #     def remove_change_callback(self, callback: Callable[[str, str, str], None]):
    #         """
    #         Remove change callback.

    #         Args:
    #             callback: Callback function to remove
    #         """
    #         if callback in self._change_callbacks:
                self._change_callbacks.remove(callback)

    #     async def get_environment_info(self) -Dict[str, Any]):
    #         """
    #         Get information about the environment manager.

    #         Returns:
    #             Environment manager information
    #         """
    #         return {
    #             'name': self.name,
    #             'version': '1.0.0',
    #             'prefix': self.NOODLE_PREFIX,
                'env_file': str(self.env_file),
                'backup_dir': str(self.backup_dir),
                'total_variables': len(self._variables),
    #             'sensitive_variables': len([v for v in self._variables.values() if v.sensitive]),
    #             'encrypted_variables': len([v for v in self._variables.values() if v.encrypted]),
                'change_callbacks': len(self._change_callbacks),
    #             'features': [
    #                 'noodle_prefix_enforcement',
    #                 'type_validation',
    #                 'sensitive_variable_handling',
    #                 'encryption_support',
    #                 'backup_restore',
    #                 'change_notifications',
    #                 'environment_validation'
    #             ]
    #         }