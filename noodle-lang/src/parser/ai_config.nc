# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# AI Configuration Manager for NoodleCore

# This module provides a unified interface for managing AI configuration
from multiple sources (IDE, environment variables, config files).
# """

import os
import json
import logging
import typing.Dict
import pathlib.Path

import ..errors.NoodleCoreError

# Set up logging
logger = logging.getLogger(__name__)

# Constants for error codes
ERROR_CODE_CONFIG_LOAD_FAILED = 2001
ERROR_CODE_CONFIG_SAVE_FAILED = 2002
ERROR_CODE_CONFIG_VALIDATION_FAILED = 2003
ERROR_CODE_CONFIG_NOT_FOUND = 2004


class AIConfigError(NoodleCoreError)
    #     """Custom exception for AI configuration errors."""

    #     def __init__(self, message: str, error_code: int = ERROR_CODE_CONFIG_LOAD_FAILED):
            super().__init__(message)
    self.error_code = error_code


class AIProvider
    #     """Represents an AI provider configuration."""

    #     def __init__(self, name: str, config: Dict[str, Any]):
    self.name = name
    self.api_key = config.get("api_key", "")
    self.base_url = config.get("base_url", "")
    self.model = config.get("model", "")
    self.max_tokens = config.get("max_tokens", 2048)
    self.temperature = config.get("temperature", 0.7)
    self.timeout = config.get("timeout", 30)
    self.custom_params = config.get("custom_params", {})

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert provider to dictionary."""
    #         return {
    #             "name": self.name,
    #             "api_key": self.api_key,
    #             "base_url": self.base_url,
    #             "model": self.model,
    #             "max_tokens": self.max_tokens,
    #             "temperature": self.temperature,
    #             "timeout": self.timeout,
    #             "custom_params": self.custom_params
    #         }


class AIConfig
    #     """
    #     Main AI configuration manager.

    #     This class manages AI configuration from multiple sources and provides
    #     a unified interface for accessing AI configuration.
    #     """

    #     def __init__(self, workspace_path: Optional[str] = None):""
    #         Initialize AI configuration.

    #         Args:
    #             workspace_path: Path to the workspace directory
    #         """
    self.workspace_path = workspace_path or os.getcwd()

    #         # Configuration paths
    self.config_dir = os.path.join(self.workspace_path, ".noodle", "config")
    self.config_file = os.path.join(self.config_dir, "ai_config.json")

    #         # Ensure config directory exists
    os.makedirs(self.config_dir, exist_ok = True)

    #         # Configuration sources priority: IDE Environment > Config File > Defaults
    self._ide_config = {}
    self._env_config = {}
    self._file_config = {}
    self._default_config = self._get_default_config()

    #         # Loaded configuration
    self.providers = {}
    self.default_provider = ""
    self.global_settings = {}

    #         # Load configuration
            self._load_config()

    #     def _get_default_config(self):
    """Dict[str, Any])"""
    #         """Get default configuration."""
    #         return {
    #             "providers": {
    #                 "openai": {
    #                     "api_key": "",
    #                     "base_url": "https://api.openai.com/v1",
    #                     "model": "gpt-3.5-turbo",
    #                     "max_tokens": 2048,
    #                     "temperature": 0.7,
    #                     "timeout": 30,
    #                     "custom_params": {}
    #                 },
    #                 "anthropic": {
    #                     "api_key": "",
    #                     "base_url": "https://api.anthropic.com",
    #                     "model": "claude-3-sonnet-20240229",
    #                     "max_tokens": 2048,
    #                     "temperature": 0.7,
    #                     "timeout": 30,
    #                     "custom_params": {}
    #                 }
    #             },
    #             "default_provider": "openai",
    #             "global_settings": {
    #                 "max_response_time": 30,
    #                 "retry_attempts": 3,
    #                 "cache_enabled": True,
    #                 "cache_ttl": 3600
    #             }
    #         }

    #     def _load_config(self) -None):
    #         """Load configuration from all sources."""
    #         try:
    #             # Load environment variables
                self._load_env_config()

    #             # Load file configuration
                self._load_file_config()

    #             # Merge configuration
                self._merge_config()

                logger.info("AI configuration loaded successfully")

    #         except Exception as e:
                logger.error(f"Failed to load AI configuration: {e}")
                raise AIConfigError(
                    f"Failed to load AI configuration: {str(e)}",
    #                 ERROR_CODE_CONFIG_LOAD_FAILED
    #             )

    #     def _load_env_config(self) -None):
    #         """Load configuration from environment variables."""
    #         # Environment variables with NOODLE_ prefix
    env_mapping = {
                "NOODLE_AI_DEFAULT_PROVIDER": ("default_provider", str),
                "NOODLE_AI_MAX_RESPONSE_TIME": ("global_settings.max_response_time", int),
                "NOODLE_AI_RETRY_ATTEMPTS": ("global_settings.retry_attempts", int),
                "NOODLE_AI_CACHE_ENABLED": ("global_settings.cache_enabled", bool),
                "NOODLE_AI_CACHE_TTL": ("global_settings.cache_ttl", int),
                "NOODLE_AI_OPENAI_API_KEY": ("providers.openai.api_key", str),
                "NOODLE_AI_OPENAI_MODEL": ("providers.openai.model", str),
                "NOODLE_AI_OPENAI_BASE_URL": ("providers.openai.base_url", str),
                "NOODLE_AI_ANTHROPIC_API_KEY": ("providers.anthropic.api_key", str),
                "NOODLE_AI_ANTHROPIC_MODEL": ("providers.anthropic.model", str),
                "NOODLE_AI_ANTHROPIC_BASE_URL": ("providers.anthropic.base_url", str),
    #         }

    self._env_config = {}

    #         for env_var, (config_path, value_type) in env_mapping.items():
    value = os.environ.get(env_var)
    #             if value is not None:
    #                 # Parse the value based on type
    #                 if value_type == bool:
    value = value.lower() in ("true", "1", "yes", "on")
    #                 elif value_type == int:
    #                     try:
    value = int(value)
    #                     except ValueError:
    #                         logger.warning(f"Invalid integer value for {env_var}: {value}")
    #                         continue

    #                 # Set nested key
                    self._set_nested_key(self._env_config, config_path, value)

            logger.debug(f"Loaded {len(self._env_config)} settings from environment")

    #     def _load_file_config(self) -None):
    #         """Load configuration from file."""
    self._file_config = {}

    #         if os.path.exists(self.config_file):
    #             try:
    #                 with open(self.config_file, 'r', encoding='utf-8') as f:
    self._file_config = json.load(f)
                    logger.debug(f"Loaded configuration from {self.config_file}")
    #             except Exception as e:
                    logger.error(f"Failed to load configuration from {self.config_file}: {e}")
                    raise AIConfigError(
                        f"Failed to load configuration from file: {str(e)}",
    #                     ERROR_CODE_CONFIG_LOAD_FAILED
    #                 )
    #         else:
                logger.debug(f"Configuration file {self.config_file} not found, using defaults")

    #     def _merge_config(self) -None):
    #         """Merge configuration from all sources."""
    #         # Start with defaults
    merged_config = self._deep_copy_dict(self._default_config)

    #         # Apply file config
    merged_config = self._deep_merge(merged_config, self._file_config)

    #         # Apply environment config
    merged_config = self._deep_merge(merged_config, self._env_config)

            # Apply IDE config (highest priority)
    merged_config = self._deep_merge(merged_config, self._ide_config)

    #         # Validate configuration
            self._validate_config(merged_config)

    #         # Set instance variables
    self.providers = {
                name: AIProvider(name, config)
    #             for name, config in merged_config.get("providers", {}).items()
    #         }
    self.default_provider = merged_config.get("default_provider", "")
    self.global_settings = merged_config.get("global_settings", {})

    #     def _validate_config(self, config: Dict[str, Any]) -None):
    #         """Validate configuration."""
    #         # Check if default provider exists
    default_provider = config.get("default_provider", "")
    providers = config.get("providers", {})

    #         if default_provider and default_provider not in providers:
                logger.warning(f"Default provider '{default_provider}' not found in providers")
    config["default_provider"] = ""

    #         # Validate providers
    #         for name, provider_config in providers.items():
    #             if not isinstance(provider_config, dict):
                    raise AIConfigError(
    #                     f"Provider configuration for '{name}' must be a dictionary",
    #                     ERROR_CODE_CONFIG_VALIDATION_FAILED
    #                 )

    #             # Check required fields
    #             if "model" not in provider_config:
    #                 logger.warning(f"Model not specified for provider '{name}'")
    provider_config["model"] = "default"

    #     def set_ide_config(self, config: Dict[str, Any]) -None):
    #         """
    #         Set configuration from IDE.

    #         Args:
    #             config: Configuration from IDE
    #         """
    self._ide_config = config
            self._merge_config()
            logger.info("Updated configuration from IDE")

    #     def get_provider(self, name: str) -Optional[AIProvider]):
    #         """
    #         Get a provider by name.

    #         Args:
    #             name: Provider name

    #         Returns:
    #             Provider instance or None if not found
    #         """
            return self.providers.get(name)

    #     def get_default_provider(self) -Optional[AIProvider]):
    #         """
    #         Get the default provider.

    #         Returns:
    #             Default provider instance or None if not set
    #         """
    #         if self.default_provider:
                return self.get_provider(self.default_provider)

    #         # Return first available provider if no default is set
    #         if self.providers:
                return next(iter(self.providers.values()))

    #         return None

    #     def get_all_providers(self) -List[AIProvider]):
    #         """
    #         Get all providers.

    #         Returns:
    #             List of all providers
    #         """
            return list(self.providers.values())

    #     def get_provider_names(self) -List[str]):
    #         """
    #         Get all provider names.

    #         Returns:
    #             List of all provider names
    #         """
            return list(self.providers.keys())

    #     def add_provider(self, provider: AIProvider) -None):
    #         """
    #         Add a new provider.

    #         Args:
    #             provider: Provider to add
    #         """
    self.providers[provider.name] = provider
            logger.info(f"Added provider '{provider.name}'")

    #     def remove_provider(self, name: str) -bool):
    #         """
    #         Remove a provider.

    #         Args:
    #             name: Provider name to remove

    #         Returns:
    #             True if provider was removed, False if not found
    #         """
    #         if name in self.providers:
    #             del self.providers[name]

    #             # Update default provider if it was removed
    #             if self.default_provider == name:
    self.default_provider = ""

                logger.info(f"Removed provider '{name}'")
    #             return True
    #         return False

    #     def set_default_provider(self, name: str) -bool):
    #         """
    #         Set the default provider.

    #         Args:
    #             name: Provider name to set as default

    #         Returns:
    #             True if default was set, False if provider not found
    #         """
    #         if name in self.providers:
    self.default_provider = name
                logger.info(f"Set default provider to '{name}'")
    #             return True
    #         return False

    #     def get_global_setting(self, key: str, default_value: Any = None) -Any):
    #         """
    #         Get a global setting.

    #         Args:
    #             key: Setting key
    #             default_value: Default value if setting not found

    #         Returns:
    #             Setting value
    #         """
            return self.global_settings.get(key, default_value)

    #     def set_global_setting(self, key: str, value: Any) -None):
    #         """
    #         Set a global setting.

    #         Args:
    #             key: Setting key
    #             value: Setting value
    #         """
    self.global_settings[key] = value
            logger.debug(f"Set global setting '{key}' to '{value}'")

    #     def save_config(self) -None):
    #         """Save configuration to file."""
    #         try:
    #             # Prepare configuration data
    config_data = {
    #                 "providers": {
                        name: provider.to_dict()
    #                     for name, provider in self.providers.items()
    #                 },
    #                 "default_provider": self.default_provider,
    #                 "global_settings": self.global_settings
    #             }

    #             # Write to file
    #             with open(self.config_file, 'w', encoding='utf-8') as f:
    json.dump(config_data, f, indent = 2, ensure_ascii=False)

                logger.info(f"Saved configuration to {self.config_file}")

    #         except Exception as e:
                logger.error(f"Failed to save configuration: {e}")
                raise AIConfigError(
                    f"Failed to save configuration: {str(e)}",
    #                 ERROR_CODE_CONFIG_SAVE_FAILED
    #             )

    #     def export_config(self, file_path: str, include_sensitive: bool = False) -bool):
    #         """
    #         Export configuration to a file.

    #         Args:
    #             file_path: Path to export file
    #             include_sensitive: Whether to include sensitive data like API keys

    #         Returns:
    #             True if exported successfully
    #         """
    #         try:
    #             # Prepare configuration data
    config_data = {
    #                 "providers": {},
    #                 "default_provider": self.default_provider,
    #                 "global_settings": self.global_settings
    #             }

    #             # Export providers
    #             for name, provider in self.providers.items():
    provider_data = provider.to_dict()

    #                 # Remove sensitive data if requested
    #                 if not include_sensitive:
                        provider_data.pop("api_key", None)

    config_data["providers"][name] = provider_data

    #             # Write to file
    #             with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(config_data, f, indent = 2, ensure_ascii=False)

                logger.info(f"Exported configuration to {file_path}")
    #             return True

    #         except Exception as e:
                logger.error(f"Failed to export configuration: {e}")
    #             return False

    #     def import_config(self, file_path: str, overwrite: bool = False) -bool):
    #         """
    #         Import configuration from a file.

    #         Args:
    #             file_path: Path to import file
    #             overwrite: Whether to overwrite existing configuration

    #         Returns:
    #             True if imported successfully
    #         """
    #         try:
    #             with open(file_path, 'r', encoding='utf-8') as f:
    config_data = json.load(f)

    #             # Import providers
    #             if "providers" in config_data:
    #                 for name, provider_config in config_data["providers"].items():
    #                     if overwrite or name not in self.providers:
                            self.add_provider(AIProvider(name, provider_config))

    #             # Import default provider
    #             if "default_provider" in config_data:
    #                 if overwrite or not self.default_provider:
                        self.set_default_provider(config_data["default_provider"])

    #             # Import global settings
    #             if "global_settings" in config_data:
    #                 if overwrite:
    self.global_settings = config_data["global_settings"]
    #                 else:
    #                     for key, value in config_data["global_settings"].items():
    #                         if key not in self.global_settings:
    self.global_settings[key] = value

    #             # Save to file
                self.save_config()

                logger.info(f"Imported configuration from {file_path}")
    #             return True

    #         except Exception as e:
                logger.error(f"Failed to import configuration: {e}")
    #             return False

    #     def _set_nested_key(self, obj: Dict[str, Any], path: str, value: Any) -None):
    #         """Set a nested key in a dictionary."""
    keys = path.split('.')
    current = obj

    #         for key in keys[:-1]:
    #             if key not in current:
    current[key] = {}
    current = current[key]

    current[keys[-1]] = value

    #     def _deep_copy_dict(self, obj: Dict[str, Any]) -Dict[str, Any]):
    #         """Deep copy a dictionary."""
    result = {}
    #         for key, value in obj.items():
    #             if isinstance(value, dict):
    result[key] = self._deep_copy_dict(value)
    #             elif isinstance(value, list):
    result[key] = list(value)
    #             else:
    result[key] = value
    #         return result

    #     def _deep_merge(self, base: Dict[str, Any], update: Dict[str, Any]) -Dict[str, Any]):
    #         """Deep merge two dictionaries."""
    result = self._deep_copy_dict(base)

    #         for key, value in update.items():
    #             if key in result and isinstance(result[key], dict) and isinstance(value, dict):
    result[key] = self._deep_merge(result[key], value)
    #             else:
    result[key] = value

    #         return result


# Global configuration instance
_global_config = None


def get_ai_config(workspace_path: Optional[str] = None) -AIConfig):
#     """
#     Get the global AI configuration instance.

#     Args:
#         workspace_path: Path to the workspace directory

#     Returns:
#         AI configuration instance
#     """
#     global _global_config

#     if _global_config is None:
_global_config = AIConfig(workspace_path)

#     return _global_config


def set_ide_config(config: Dict[str, Any]) -None):
#     """
#     Set IDE configuration globally.

#     Args:
#         config: Configuration from IDE
#     """
#     global _global_config

#     if _global_config is None:
_global_config = AIConfig()

    _global_config.set_ide_config(config)