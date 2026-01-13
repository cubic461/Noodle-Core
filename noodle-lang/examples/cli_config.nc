# Converted from Python to NoodleCore
# Original file: src

# """
# CLI Configuration Management

# This module implements CLI-specific configuration management for the NoodleCore CLI system.
# It handles loading configuration from environment variables with NOODLE_ prefix.
# """

import os
import logging
import typing.Dict
import pathlib.Path

import .exceptions.ConfigurationError

logger = logging.getLogger(__name__)


class CliConfig
    #     """CLI configuration manager for NoodleCore."""

    #     # Default configuration values
    DEFAULT_CONFIG = {
    #         'NOODLE_ENV': 'development',
    #         'NOODLE_PORT': '8080',
    #         'NOODLE_HOST': '0.0.0.0',
    #         'NOODLE_LOG_LEVEL': 'INFO',
    #         'NOODLE_DEBUG': '0',
    #         'NOODLE_OUTPUT_FORMAT': 'text',
    #         'NOODLE_REQUEST_TIMEOUT': '30',
    #         'NOODLE_MAX_CONCURRENT_CONNECTIONS': '100',
    #         'NOODLE_MEMORY_LIMIT': '2GB',
    #         'NOODLE_AI_PROVIDER': 'zai',
    #         'NOODLE_AI_MODEL': 'glm-4.6',
    #         'NOODLE_SANDBOX_TIMEOUT': '30',
    #         'NOODLE_SANDBOX_MEMORY_LIMIT': '512M',
    #         'NOODLE_SANDBOX_CPU_LIMIT': '1',
    #         'NOODLE_VALIDATION_STRICT': '0',
    #         'NOODLE_CONFIG_DIR': '~/.noodlecore',
    #         'NOODLE_DATA_DIR': '~/.noodlecore/data',
    #         'NOODLE_LOG_DIR': '~/.noodlecore/logs',
    #         'NOODLE_CACHE_DIR': '~/.noodlecore/cache',
    #         'NOODLE_ENCRYPTION_KEY': '',
    #         'NOODLE_API_KEY': '',
    #         'NOODLE_JWT_SECRET': '',
    #         'NOODLE_JWT_EXPIRATION': '7200',
    #         'NOODLE_ENABLE_METRICS': '1',
    #         'NOODLE_ENABLE_TRACING': '0',
    #         'NOODLE_ENABLE_AUDIT_LOG': '1',
    #         'NOODLE_DB_HOST': 'localhost',
    #         'NOODLE_DB_PORT': '5432',
    #         'NOODLE_DB_NAME': 'noodlecore',
    #         'NOODLE_DB_USER': 'noodlecore',
    #         'NOODLE_DB_PASSWORD': '',
    #         'NOODLE_DB_POOL_SIZE': '20',
    #         'NOODLE_DB_TIMEOUT': '30',
    #         'NOODLE_REDIS_HOST': 'localhost',
    #         'NOODLE_REDIS_PORT': '6379',
    #         'NOODLE_REDIS_DB': '0',
    #         'NOODLE_REDIS_PASSWORD': '',
    #         'NOODLE_TLS_VERSION': '1.3',
    #         'NOODLE_ENABLE_HTTPS': '0',
    #         'NOODLE_CERT_FILE': '',
    #         'NOODLE_KEY_FILE': '',
    #     }

    #     def __init__(self, config_file: Optional[str] = None):
    #         """
    #         Initialize the CLI configuration manager.

    #         Args:
                config_file: Path to configuration file (optional)
    #         """
    self.config_file = config_file
    self._config = {}
            self._load_config()

    #     def _load_config(self) -None):
    #         """Load configuration from environment variables and config file."""
    #         try:
    #             # Start with default configuration
    self._config = self.DEFAULT_CONFIG.copy()

    #             # Override with environment variables (NOODLE_ prefix)
    #             for key, value in os.environ.items():
    #                 if key.startswith('NOODLE_'):
    self._config[key] = value

    #             # Load from config file if provided
    #             if self.config_file and Path(self.config_file).exists():
                    self._load_config_file()

    #             # Validate configuration
                self._validate_config()

                logger.debug("CLI configuration loaded successfully")

    #         except Exception as e:
                raise ConfigurationError(f"Failed to load configuration: {str(e)}")

    #     def _load_config_file(self) -None):
    #         """Load configuration from file."""
    #         try:
    #             import json

    #             with open(self.config_file, 'r', encoding='utf-8') as f:
    file_config = json.load(f)

    #             # Convert keys to NOODLE_ prefix format
    #             for key, value in file_config.items():
    #                 if not key.startswith('NOODLE_'):
    noodle_key = f'NOODLE_{key.upper()}'
    #                 else:
    noodle_key = key

    self._config[noodle_key] = str(value)

            except (json.JSONDecodeError, IOError) as e:
                raise ConfigurationError(f"Failed to load config file {self.config_file}: {str(e)}")

    #     def _validate_config(self) -None):
    #         """Validate configuration values."""
    #         # Validate environment
    valid_envs = ['development', 'production', 'testing']
    #         if self.get('NOODLE_ENV') not in valid_envs:
                raise ConfigurationError(
                    f"Invalid NOODLE_ENV: {self.get('NOODLE_ENV')}. Must be one of: {', '.join(valid_envs)}"
    #             )

    #         # Validate log level
    valid_log_levels = ['DEBUG', 'INFO', 'WARNING', 'ERROR']
    #         if self.get('NOODLE_LOG_LEVEL') not in valid_log_levels:
                raise ConfigurationError(
                    f"Invalid NOODLE_LOG_LEVEL: {self.get('NOODLE_LOG_LEVEL')}. Must be one of: {', '.join(valid_log_levels)}"
    #             )

    #         # Validate output format
    valid_formats = ['text', 'json', 'yaml']
    #         if self.get('NOODLE_OUTPUT_FORMAT') not in valid_formats:
                raise ConfigurationError(
                    f"Invalid NOODLE_OUTPUT_FORMAT: {self.get('NOODLE_OUTPUT_FORMAT')}. Must be one of: {', '.join(valid_formats)}"
    #             )

    #         # Validate numeric values
    self._validate_numeric('NOODLE_PORT', min_value = 1, max_value=65535)
    self._validate_numeric('NOODLE_REQUEST_TIMEOUT', min_value = 1)
    self._validate_numeric('NOODLE_MAX_CONCURRENT_CONNECTIONS', min_value = 1)
    self._validate_numeric('NOODLE_SANDBOX_TIMEOUT', min_value = 1)
    self._validate_numeric('NOODLE_SANDBOX_CPU_LIMIT', min_value = 1)
    self._validate_numeric('NOODLE_DB_PORT', min_value = 1, max_value=65535)
    self._validate_numeric('NOODLE_DB_POOL_SIZE', min_value = 1, max_value=20)
    self._validate_numeric('NOODLE_DB_TIMEOUT', min_value = 1)
    self._validate_numeric('NOODLE_REDIS_PORT', min_value = 1, max_value=65535)

    #         # Validate boolean values
            self._validate_boolean('NOODLE_DEBUG')
            self._validate_boolean('NOODLE_VALIDATION_STRICT')
            self._validate_boolean('NOODLE_ENABLE_METRICS')
            self._validate_boolean('NOODLE_ENABLE_TRACING')
            self._validate_boolean('NOODLE_ENABLE_AUDIT_LOG')
            self._validate_boolean('NOODLE_ENABLE_HTTPS')

    #     def _validate_numeric(self, key: str, min_value: Optional[int] = None, max_value: Optional[int] = None) -None):
    #         """Validate a numeric configuration value."""
    #         try:
    value = int(self.get(key))
    #             if min_value is not None and value < min_value:
    raise ConfigurationError(f"{key} must be = {min_value}, got {value}")
    #             if max_value is not None and value > max_value):
    raise ConfigurationError(f"{key} must be < = {max_value}, got {value}")
    self._config[key] = str(value)
    #         except ValueError:
                raise ConfigurationError(f"{key} must be a numeric value, got {self.get(key)}")

    #     def _validate_boolean(self, key: str) -None):
    #         """Validate a boolean configuration value."""
    value = self.get(key).lower()
    #         if value in ('1', 'true', 'yes', 'on'):
    self._config[key] = '1'
    #         elif value in ('0', 'false', 'no', 'off'):
    self._config[key] = '0'
    #         else:
                raise ConfigurationError(f"{key} must be a boolean value (1/0, true/false, yes/no, on/off), got {value}")

    #     def get(self, key: str, default: Optional[str] = None) -str):
    #         """
    #         Get a configuration value.

    #         Args:
    #             key: Configuration key (with or without NOODLE_ prefix)
    #             default: Default value if key not found

    #         Returns:
    #             Configuration value
    #         """
    #         # Ensure key has NOODLE_ prefix
    #         if not key.startswith('NOODLE_'):
    key = f'NOODLE_{key.upper()}'

            return self._config.get(key, default or '')

    #     def get_int(self, key: str, default: int = 0) -int):
    #         """
    #         Get a configuration value as integer.

    #         Args:
    #             key: Configuration key
    #             default: Default value if key not found

    #         Returns:
    #             Configuration value as integer
    #         """
    value = self.get(key, str(default))
    #         try:
                return int(value)
    #         except ValueError:
    #             logger.warning(f"Invalid integer value for {key}: {value}, using default: {default}")
    #             return default

    #     def get_bool(self, key: str, default: bool = False) -bool):
    #         """
    #         Get a configuration value as boolean.

    #         Args:
    #             key: Configuration key
    #             default: Default value if key not found

    #         Returns:
    #             Configuration value as boolean
    #         """
    #         value = self.get(key, '1' if default else '0')
            return value in ('1', 'true', 'yes', 'on')

    #     def get_path(self, key: str, default: Optional[str] = None) -Path):
    #         """
    #         Get a configuration value as a Path object.

    #         Args:
    #             key: Configuration key
    #             default: Default value if key not found

    #         Returns:
    #             Configuration value as Path object
    #         """
    value = self.get(key, default or '')
    #         # Expand ~ to home directory
    #         if value.startswith('~/'):
    value = os.path.expanduser(value)
            return Path(value)

    #     def set(self, key: str, value: str) -None):
    #         """
    #         Set a configuration value.

    #         Args:
    #             key: Configuration key (with or without NOODLE_ prefix)
    #             value: Configuration value
    #         """
    #         # Ensure key has NOODLE_ prefix
    #         if not key.startswith('NOODLE_'):
    key = f'NOODLE_{key.upper()}'

    self._config[key] = value
    logger.debug(f"Configuration updated: {key} = {value}")

    #     def get_all(self) -Dict[str, str]):
    #         """
    #         Get all configuration values.

    #         Returns:
    #             Dictionary of all configuration values
    #         """
            return self._config.copy()

    #     def get_profile_config(self, profile: str) -Dict[str, str]):
    #         """
    #         Get configuration for a specific profile.

    #         Args:
                profile: Profile name (development, production, testing)

    #         Returns:
    #             Dictionary of profile-specific configuration
    #         """
    profile_config = self._config.copy()
    profile_config['NOODLE_ENV'] = profile

    #         # Apply profile-specific overrides
    #         if profile == 'production':
    profile_config['NOODLE_DEBUG'] = '0'
    profile_config['NOODLE_LOG_LEVEL'] = 'WARNING'
    profile_config['NOODLE_ENABLE_TRACING'] = '1'
    #         elif profile == 'development':
    profile_config['NOODLE_DEBUG'] = '1'
    profile_config['NOODLE_LOG_LEVEL'] = 'DEBUG'
    profile_config['NOODLE_ENABLE_TRACING'] = '0'
    #         elif profile == 'testing':
    profile_config['NOODLE_DEBUG'] = '1'
    profile_config['NOODLE_LOG_LEVEL'] = 'DEBUG'
    profile_config['NOODLE_ENABLE_TRACING'] = '0'

    #         return profile_config

    #     def is_development(self) -bool):
    #         """Check if running in development mode."""
    return self.get('NOODLE_ENV') = = 'development'

    #     def is_production(self) -bool):
    #         """Check if running in production mode."""
    return self.get('NOODLE_ENV') = = 'production'

    #     def is_debug_enabled(self) -bool):
    #         """Check if debug mode is enabled."""
            return self.get_bool('NOODLE_DEBUG')

    #     def is_tracing_enabled(self) -bool):
    #         """Check if tracing is enabled."""
            return self.get_bool('NOODLE_ENABLE_TRACING')


# Global configuration instance
_cli_config = None


def get_cli_config() -CliConfig):
#     """
#     Get the global CLI configuration instance.

#     Returns:
#         CliConfig instance
#     """
#     global _cli_config
#     if _cli_config is None:
_cli_config = CliConfig()
#     return _cli_config


def reload_cli_config(config_file: Optional[str] = None) -CliConfig):
#     """
#     Reload the CLI configuration.

#     Args:
        config_file: Path to configuration file (optional)

#     Returns:
#         New CliConfig instance
#     """
#     global _cli_config
_cli_config = CliConfig(config_file)
#     return _cli_config