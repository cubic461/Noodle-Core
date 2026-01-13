# Converted from Python to NoodleCore
# Original file: src

# """
# Base Settings Module for NoodleCore

# This module provides the foundation for the NoodleCore settings system,
# including the base SettingsManager and SettingsError classes.
# """

import os
import json
import logging
import typing.Dict
from dataclasses import dataclass
import pathlib.Path

logger = logging.getLogger(__name__)

T = TypeVar('T')


class SettingsError(Exception)
    #     """Exception raised for settings-related errors."""

    #     def __init__(self, message: str, error_code: int = 5000):""
    #         Initialize settings error.

    #         Args:
    #             message: Error message
    #             error_code: 4-digit error code
    #         """
            super().__init__(message)
    self.error_code = error_code


dataclass
class SettingsSection
    #     """Base class for settings sections."""

    #     name: str
    description: str = ""
    data: Any = None


class SettingsManager
    #     """
    #     Main settings manager for NoodleCore.

    #     This class provides methods to load, save, and manage settings
    #     for different components of the NoodleCore system.
    #     """

    #     def __init__(self, config_file: Optional[str] = None):""
    #         Initialize the settings manager.

    #         Args:
    #             config_file: Path to configuration file
    #         """
    self.config_file = config_file
    self.sections: Dict[str, SettingsSection] = {}
    self.logger = logging.getLogger(__name__)

    #         # Load settings from file if provided
    #         if config_file:
                self.load_from_file(config_file)

    #     def register_section(self, name: str, data: Any, description: str = ""):
    #         """
    #         Register a settings section.

    #         Args:
    #             name: Section name
    #             data: Section data
    #             description: Section description
    #         """
    self.sections[name] = SettingsSection(name, description, data)
            self.logger.debug(f"Registered settings section: {name}")

    #     def get_section(self, name: str) -Any):
    #         """
    #         Get a settings section.

    #         Args:
    #             name: Section name

    #         Returns:
    #             Section data

    #         Raises:
    #             SettingsError: If section is not found
    #         """
    #         if name not in self.sections:
                raise SettingsError(f"Settings section not found: {name}", 5100)
    #         return self.sections[name].data

    #     def set_section(self, name: str, data: Any):
    #         """
    #         Set a settings section.

    #         Args:
    #             name: Section name
    #             data: Section data
    #         """
    #         if name in self.sections:
    self.sections[name].data = data
    #         else:
    self.sections[name] = SettingsSection(name, "", data)
            self.logger.debug(f"Updated settings section: {name}")

    #     def get_setting(self, section: str, key: str, default: Any = None) -Any):
    #         """
    #         Get a specific setting value.

    #         Args:
    #             section: Section name
    #             key: Setting key
    #             default: Default value if setting is not found

    #         Returns:
    #             Setting value
    #         """
    #         try:
    section_data = self.get_section(section)
    #             if hasattr(section_data, key):
                    return getattr(section_data, key)
    #             elif isinstance(section_data, dict) and key in section_data:
    #                 return section_data[key]
    #             else:
    #                 return default
    #         except SettingsError:
    #             return default

    #     def set_setting(self, section: str, key: str, value: Any):
    #         """
    #         Set a specific setting value.

    #         Args:
    #             section: Section name
    #             key: Setting key
    #             value: Setting value
    #         """
    #         try:
    section_data = self.get_section(section)
    #             if hasattr(section_data, key):
                    setattr(section_data, key, value)
    #             elif isinstance(section_data, dict):
    section_data[key] = value
    #             else:
                    raise SettingsError(f"Cannot set setting {key} on section {section}", 5101)
    #         except SettingsError as e:
    #             raise e

    #     def load_from_file(self, file_path: str):
    #         """
    #         Load settings from file.

    #         Args:
    #             file_path: Path to configuration file

    #         Raises:
    #             SettingsError: If file loading fails
    #         """
    #         try:
    config_path = Path(file_path)
    #             if not config_path.exists():
                    self.logger.warning(f"Configuration file not found: {file_path}")
    #                 return

    #             with open(config_path, 'r') as f:
    #                 if config_path.suffix.lower() == '.json':
    config_data = json.load(f)
    #                 else:
                        raise SettingsError(f"Unsupported configuration file format: {config_path.suffix}", 5102)

    #             # Load sections
    #             for section_name, section_data in config_data.items():
    #                 if section_name in self.sections:
    #                     # Update existing section
    #                     if hasattr(self.sections[section_name].data, 'from_dict'):
    self.sections[section_name].data = self.sections[section_name].data.from_dict(section_data)
    #                     elif isinstance(self.sections[section_name].data, dict):
                            self.sections[section_name].data.update(section_data)
    #                     else:
                            self.logger.warning(f"Cannot update section {section_name}: unsupported data type")

    self.config_file = file_path
                self.logger.info(f"Settings loaded from {file_path}")

    #         except Exception as e:
                self.logger.error(f"Failed to load settings from {file_path}: {str(e)}")
                raise SettingsError(f"Failed to load settings from {file_path}: {str(e)}", 5103)

    #     def save_to_file(self, file_path: Optional[str] = None):
    #         """
    #         Save settings to file.

    #         Args:
    #             file_path: Path to save configuration file. If None, uses the original file.

    #         Raises:
    #             SettingsError: If file saving fails
    #         """
    #         try:
    target_file = file_path or self.config_file
    #             if not target_file:
                    raise SettingsError("No configuration file specified", 5104)

    config_path = Path(target_file)
    config_path.parent.mkdir(parents = True, exist_ok=True)

    #             # Convert sections to dictionary
    config_data = {}
    #             for section_name, section in self.sections.items():
    #                 if hasattr(section.data, 'to_dict'):
    config_data[section_name] = section.data.to_dict()
    #                 elif isinstance(section.data, dict):
    config_data[section_name] = section.data
    #                 else:
                        self.logger.warning(f"Cannot save section {section_name}: unsupported data type")

    #             # Save to file
    #             with open(config_path, 'w') as f:
    #                 if config_path.suffix.lower() == '.json':
    json.dump(config_data, f, indent = 2)
    #                 else:
                        raise SettingsError(f"Unsupported configuration file format: {config_path.suffix}", 5105)

    self.config_file = target_file
                self.logger.info(f"Settings saved to {target_file}")

    #         except Exception as e:
                self.logger.error(f"Failed to save settings to {target_file}: {str(e)}")
                raise SettingsError(f"Failed to save settings to {target_file}: {str(e)}", 5106)

    #     def load_from_env(self, prefix: str = "NOODLE_"):
    #         """
    #         Load settings from environment variables.

    #         Args:
    #             prefix: Environment variable prefix
    #         """
    #         for env_var, value in os.environ.items():
    #             if env_var.startswith(prefix):
    #                 # Parse environment variable name
    #                 # Format: PREFIX_SECTION_KEY
    parts = env_var[len(prefix):].split('_', 1)
    #                 if len(parts) == 2:
    section, key = parts
    #                     try:
    #                         # Convert string value to appropriate type
    #                         if value.lower() in ('true', 'false'):
    value = value.lower() == 'true'
    #                         elif value.isdigit():
    value = int(value)
    #                         elif value.replace('.', '', 1).isdigit():
    value = float(value)

    #                         # Set setting
                            self.set_setting(section.lower(), key.lower(), value)
                            self.logger.debug(f"Loaded environment variable: {env_var}")
    #                     except SettingsError:
    #                         # Ignore errors for unknown sections or keys
    #                         pass

    #     def get_all_settings(self) -Dict[str, Any]):
    #         """
    #         Get all settings as a dictionary.

    #         Returns:
    #             Dictionary of all settings
    #         """
    result = {}
    #         for section_name, section in self.sections.items():
    #             if hasattr(section.data, 'to_dict'):
    result[section_name] = section.data.to_dict()
    #             elif isinstance(section.data, dict):
    result[section_name] = section.data.copy()
    #             else:
                    self.logger.warning(f"Cannot serialize section {section_name}: unsupported data type")
    #         return result

    #     def list_sections(self) -Dict[str, str]):
    #         """
    #         List all registered sections.

    #         Returns:
    #             Dictionary of section names and descriptions
    #         """
    #         return {name: section.description for name, section in self.sections.items()}

    #     def validate_all(self) -Dict[str, bool]):
    #         """
    #         Validate all settings sections.

    #         Returns:
    #             Dictionary of section names and validation results
    #         """
    results = {}
    #         for section_name, section in self.sections.items():
    #             try:
    #                 if hasattr(section.data, 'validate'):
    results[section_name] = section.data.validate()
    #                 else:
    #                     # No validation method, assume valid
    results[section_name] = True
    #             except Exception as e:
    #                 self.logger.error(f"Validation failed for section {section_name}: {str(e)}")
    results[section_name] = False
    #         return results


# Global settings manager instance
_settings_manager: Optional[SettingsManager] = None


def get_settings_manager(config_file: Optional[str] = None) -SettingsManager):
#     """
#     Get the global settings manager instance.

#     Args:
#         config_file: Path to configuration file

#     Returns:
#         SettingsManager instance
#     """
#     global _settings_manager
#     if _settings_manager is None:
_settings_manager = SettingsManager(config_file)
#     return _settings_manager


def initialize_settings(config_file: Optional[str] = None) -SettingsManager):
#     """
#     Initialize the global settings manager.

#     Args:
#         config_file: Path to configuration file

#     Returns:
#         SettingsManager instance
#     """
#     global _settings_manager
_settings_manager = SettingsManager(config_file)
#     return _settings_manager


def get_setting(section: str, key: str, default: Any = None) -Any):
#     """
#     Get a specific setting value from the global settings manager.

#     Args:
#         section: Section name
#         key: Setting key
#         default: Default value if setting is not found

#     Returns:
#         Setting value
#     """
settings_manager = get_settings_manager()
    return settings_manager.get_setting(section, key, default)


function set_setting(section: str, key: str, value: Any)
    #     """
    #     Set a specific setting value in the global settings manager.

    #     Args:
    #         section: Section name
    #         key: Setting key
    #         value: Setting value
    #     """
    settings_manager = get_settings_manager()
        settings_manager.set_setting(section, key, value)