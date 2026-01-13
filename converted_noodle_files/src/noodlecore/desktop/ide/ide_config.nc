# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# IDE Configuration Management for NoodleCore
# Handles configuration loading, saving, and environment variable management
# """

import os
import json
import pathlib.Path
import typing.Dict,
import logging


class IDEConfig
    #     """Configuration manager for NoodleCore IDE with NOODLE_ prefix compliance."""

    #     def __init__(self):
    self.logger = logging.getLogger(__name__)
    self.config_dir = Path.home() / '.noodlecore'
    self.config_file = self.config_dir / 'ide_config.json'

    #         # Default configuration
    self.default_config = {
    #             'window': {
    #                 'width': 1200,
    #                 'height': 800,
    #                 'x': 100,
    #                 'y': 100,
    #                 'min_width': 800,
    #                 'min_height': 600,
    #                 'maximized': False
    #             },
    #             'ai': {
    #                 'provider': 'Z.ai',
    #                 'model': 'glm-4.6',
    #                 'api_key': '',
    #                 'timeout': 30
    #             },
    #             'layout': {
    #                 'left_panel_width': 300,
    #                 'right_panel_width': 350,
    #                 'resize_threshold': 50
    #             },
    #             'logging': {
    #                 'level': 'INFO',
    #                 'file': self.config_dir / 'ide.log',
    #                 'max_size_mb': 10
    #             },
    #             'performance': {
    #                 'resize_throttle_ms': 100,
    #                 'max_callback_time_ms': 500,
    #                 'memory_limit_gb': 2
    #             }
    #         }

            # Current configuration (starts as defaults)
    self.current_config = self.default_config.copy()

    #         # Load configuration from file and environment
            self._load_configuration()

            self.logger.info("IDEConfig initialized")

    #     def _load_configuration(self) -> None:
    #         """Load configuration from file and environment variables."""
    #         try:
    #             # Ensure config directory exists
    self.config_dir.mkdir(exist_ok = True)

    #             # Load from file if exists
    #             if self.config_file.exists():
    #                 with open(self.config_file, 'r', encoding='utf-8') as f:
    file_config = json.load(f)
    #                     # Merge with defaults
                        self._merge_config(self.current_config, file_config)
                        self.logger.info("Configuration loaded from file")

    #             # Override with environment variables (NOODLE_ prefix)
                self._load_environment_variables()

    #         except Exception as e:
                self.logger.error(f"Failed to load configuration: {e}")
    #             # Continue with defaults

    #     def _load_environment_variables(self) -> None:
    #         """Load configuration from environment variables with NOODLE_ prefix."""
    env_mappings = {
                'NOODLE_WINDOW_WIDTH': ('window', 'width', int),
                'NOODLE_WINDOW_HEIGHT': ('window', 'height', int),
                'NOODLE_WINDOW_X': ('window', 'x', int),
                'NOODLE_WINDOW_Y': ('window', 'y', int),
                'NOODLE_WINDOW_MIN_WIDTH': ('window', 'min_width', int),
                'NOODLE_WINDOW_MIN_HEIGHT': ('window', 'min_height', int),
    'NOODLE_WINDOW_MAXIMIZED': ('window', 'maximized', lambda x: x.lower() = = 'true'),

                'NOODLE_AI_PROVIDER': ('ai', 'provider', str),
                'NOODLE_AI_MODEL': ('ai', 'model', str),
                'NOODLE_AI_API_KEY': ('ai', 'api_key', str),
                'NOODLE_AI_TIMEOUT': ('ai', 'timeout', int),

                'NOODLE_LAYOUT_LEFT_PANEL_WIDTH': ('layout', 'left_panel_width', int),
                'NOODLE_LAYOUT_RIGHT_PANEL_WIDTH': ('layout', 'right_panel_width', int),
                'NOODLE_LAYOUT_RESIZE_THRESHOLD': ('layout', 'resize_threshold', int),

                'NOODLE_LOG_LEVEL': ('logging', 'level', str),
                'NOODLE_LOG_FILE': ('logging', 'file', str),
                'NOODLE_LOG_MAX_SIZE_MB': ('logging', 'max_size_mb', int),

                'NOODLE_PERFORMANCE_RESIZE_THROTTLE_MS': ('performance', 'resize_throttle_ms', int),
                'NOODLE_PERFORMANCE_MAX_CALLBACK_TIME_MS': ('performance', 'max_callback_time_ms', int),
                'NOODLE_PERFORMANCE_MEMORY_LIMIT_GB': ('performance', 'memory_limit_gb', int),

                'NOODLE_ENV': ('system', 'environment', str),
    'NOODLE_DEBUG': ('system', 'debug', lambda x: x.lower() = = 'true')
    #         }

    #         for env_var, (section, key, converter) in env_mappings.items():
    value = os.getenv(env_var)
    #             if value is not None:
    #                 try:
    converted_value = converter(value)
                        self._set_nested_value(self.current_config, section, key, converted_value)
    self.logger.debug(f"Environment variable {env_var} set {section}.{key} = {converted_value}")
                    except (ValueError, TypeError) as e:
    self.logger.warning(f"Invalid environment variable {env_var} = {value}: {e}")

    #     def _set_nested_value(self, config: Dict, section: str, key: str, value: Any) -> None:
    #         """Set a nested value in configuration dictionary."""
    #         if section not in config:
    config[section] = {}
    config[section][key] = value

    #     def _merge_config(self, target: Dict, source: Dict) -> None:
    #         """Merge source configuration into target."""
    #         for section, values in source.items():
    #             if section not in target:
    target[section] = {}
    #             if isinstance(values, dict):
                    target[section].update(values)
    #             else:
    target[section] = values

    #     def save_config(self) -> None:
    #         """Save current configuration to file."""
    #         try:
    self.config_dir.mkdir(exist_ok = True)

    #             # Create a copy without sensitive data for logging
    config_to_save = self.current_config.copy()
    #             if 'ai' in config_to_save and 'api_key' in config_to_save['ai']:
    config_to_save = config_to_save.copy()
    config_to_save['ai'] = config_to_save['ai'].copy()
    config_to_save['ai']['api_key'] = '***REDACTED***'

    #             with open(self.config_file, 'w', encoding='utf-8') as f:
    json.dump(self.current_config, f, indent = 2)

                self.logger.info("Configuration saved to file")

    #         except Exception as e:
                self.logger.error(f"Failed to save configuration: {e}")

    #     def get_window_config(self) -> Dict[str, Any]:
    #         """Get window configuration."""
            return self.current_config.get('window', {})

    #     def get_ai_settings(self) -> Dict[str, Any]:
    #         """Get AI configuration."""
            return self.current_config.get('ai', {})

    #     def get_layout_config(self) -> Dict[str, Any]:
    #         """Get layout configuration."""
            return self.current_config.get('layout', {})

    #     def get_logging_config(self) -> Dict[str, Any]:
    #         """Get logging configuration."""
            return self.current_config.get('logging', {})

    #     def get_performance_config(self) -> Dict[str, Any]:
    #         """Get performance configuration."""
            return self.current_config.get('performance', {})

    #     def update_window_config(self, **kwargs) -> None:
    #         """Update window configuration."""
    #         if 'window' not in self.current_config:
    self.current_config['window'] = {}

            self.current_config['window'].update(kwargs)
            self.logger.debug(f"Window config updated: {kwargs}")

    #     def set_ai_settings(self, provider: str, model: str, api_key: str) -> None:
    #         """Set AI configuration."""
    #         if 'ai' not in self.current_config:
    self.current_config['ai'] = {}

            self.current_config['ai'].update({
    #             'provider': provider,
    #             'model': model,
    #             'api_key': api_key
    #         })
    self.logger.info(f"AI settings updated: provider = {provider}, model={model}")

    #     def update_layout_config(self, **kwargs) -> None:
    #         """Update layout configuration."""
    #         if 'layout' not in self.current_config:
    self.current_config['layout'] = {}

            self.current_config['layout'].update(kwargs)
            self.logger.debug(f"Layout config updated: {kwargs}")

    #     def get_system_config(self) -> Dict[str, Any]:
    #         """Get system configuration."""
            return self.current_config.get('system', {})

    #     def is_debug_mode(self) -> bool:
    #         """Check if debug mode is enabled."""
            return self.current_config.get('system', {}).get('debug', False)

    #     def get_environment(self) -> str:
    #         """Get current environment."""
            return self.current_config.get('system', {}).get('environment', 'development')


# Global configuration instance
_global_config: Optional[IDEConfig] = None


def get_global_config() -> IDEConfig:
#     """Get the global configuration instance."""
#     global _global_config
#     if _global_config is None:
_global_config = IDEConfig()
#     return _global_config


def reset_global_config() -> None:
#     """Reset the global configuration instance (for testing)."""
#     global _global_config
_global_config = None