# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# IDE Configuration Management for NoodleCore
# Implements configuration management with NOODLE_ prefix
# """

import os
import json
import pathlib.Path
import typing.Dict,
import .logging_config.setup_config_logging
import .layout_errors.ConfigError,


class IdeConfig
    #     """NoodleCore IDE configuration manager."""

    #     def __init__(self):
    self.logger = setup_config_logging()
    self.config_file = Path("noodlecore_ide_config.json")
    self._config = {}
    self._default_config = {
    #             "window": {
    #                 "width": 1200,
    #                 "height": 800,
    #                 "min_width": 800,
    #                 "min_height": 600,
    #                 "x": 100,
    #                 "y": 100,
    #                 "maximized": False,
    #                 "fullscreen": False
    #             },
    #             "panels": {
    #                 "left_panel": {
    #                     "width": 300,
    #                     "visible": True,
    #                     "resizable": True
    #                 },
    #                 "right_panel": {
    #                     "width": 350,
    #                     "visible": True,
    #                     "resizable": True
    #                 },
    #                 "bottom_panel": {
    #                     "height": 200,
    #                     "visible": True,
    #                     "resizable": True
    #                 }
    #             },
    #             "layout": {
    #                 "type": "resizable",
    #                 "theme": "dark",
    #                 "font_family": "Consolas",
    #                 "font_size": 12,
    #                 "auto_save_layout": True,
    #                 "remember_panel_sizes": True
    #             },
    #             "ai_settings": {
    #                 "provider": "Z.ai",
    #                 "model": "glm-4.6",
    #                 "api_key": "",
    #                 "auto_save": True
    #             },
    #             "editor": {
    #                 "tab_size": 4,
    #                 "line_numbers": True,
    #                 "word_wrap": True,
    #                 "syntax_highlighting": True
    #             },
    #             "logging": {
                    "level": os.getenv("NOODLE_DEBUG", "0"),
    #                 "file_logging": True,
    #                 "console_logging": True
    #             }
    #         }
            self._load_config()

    #     def _load_config(self) -> None:
    #         """Load configuration from file or environment."""
    #         try:
    #             # First try to load from file
    #             if self.config_file.exists():
    #                 with open(self.config_file, 'r', encoding='utf-8') as f:
    self._config = json.load(f)
                    self.logger.info(f"Configuration loaded from {self.config_file}")
    #             else:
    self._config = self._default_config.copy()
                    self.logger.info("Using default configuration")

    #             # Override with environment variables
                self._load_from_environment()

    #         except Exception as e:
                self.logger.error(f"Failed to load configuration: {e}")
    self._config = self._default_config.copy()

    #     def _load_from_environment(self) -> None:
    #         """Load configuration from environment variables."""
    #         # Window configuration
    #         if os.getenv("NOODLE_WINDOW_WIDTH"):
    self._config["window"]["width"] = int(os.getenv("NOODLE_WINDOW_WIDTH"))
    #         if os.getenv("NOODLE_WINDOW_HEIGHT"):
    self._config["window"]["height"] = int(os.getenv("NOODLE_WINDOW_HEIGHT"))
    #         if os.getenv("NOODLE_WINDOW_MAXIMIZED"):
    self._config["window"]["maximized"] = os.getenv("NOODLE_WINDOW_MAXIMIZED").lower() == "true"

    #         # Panel configuration
    #         if os.getenv("NOODLE_LEFT_PANEL_WIDTH"):
    self._config["panels"]["left_panel"]["width"] = int(os.getenv("NOODLE_LEFT_PANEL_WIDTH"))
    #         if os.getenv("NOODLE_RIGHT_PANEL_WIDTH"):
    self._config["panels"]["right_panel"]["width"] = int(os.getenv("NOODLE_RIGHT_PANEL_WIDTH"))

    #         # Layout configuration
    #         if os.getenv("NOODLE_LAYOUT_THEME"):
    self._config["layout"]["theme"] = os.getenv("NOODLE_LAYOUT_THEME")
    #         if os.getenv("NOODLE_LAYOUT_AUTO_SAVE"):
    self._config["layout"]["auto_save_layout"] = os.getenv("NOODLE_LAYOUT_AUTO_SAVE").lower() == "true"

    #         # AI settings
    #         if os.getenv("NOODLE_AI_PROVIDER"):
    self._config["ai_settings"]["provider"] = os.getenv("NOODLE_AI_PROVIDER")
    #         if os.getenv("NOODLE_AI_MODEL"):
    self._config["ai_settings"]["model"] = os.getenv("NOODLE_AI_MODEL")
    #         if os.getenv("NOODLE_AI_API_KEY"):
    self._config["ai_settings"]["api_key"] = os.getenv("NOODLE_AI_API_KEY")

            self.logger.debug("Configuration loaded from environment variables")

    #     def save_config(self) -> None:
    #         """Save current configuration to file."""
    #         try:
    #             with open(self.config_file, 'w', encoding='utf-8') as f:
    json.dump(self._config, f, indent = 2, ensure_ascii=False)
                self.logger.info(f"Configuration saved to {self.config_file}")
    #         except Exception as e:
                raise LayoutStatePersistenceError(f"Failed to save configuration: {e}")

    #     def get(self, key: str, default: Any = None) -> Any:
    #         """Get configuration value by key."""
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
                self.logger.error(f"Failed to get config key '{key}': {e}")
    #             return default

    #     def set(self, key: str, value: Any) -> None:
    #         """Set configuration value by key."""
    #         try:
    keys = key.split('.')
    config = self._config
    #             for k in keys[:-1]:
    #                 if k not in config:
    config[k] = {}
    config = config[k]
    config[keys[-1]] = value
                self.logger.debug(f"Config key '{key}' set to: {value}")
    #         except Exception as e:
                raise ConfigError(f"Failed to set config key '{key}': {e}")

    #     def update_window_config(self, width: int, height: int, x: int, y: int,
    maximized: bool = math.subtract(False), > None:)
    #         """Update window configuration."""
    #         try:
                self.set("window.width", width)
                self.set("window.height", height)
                self.set("window.x", x)
                self.set("window.y", y)
                self.set("window.maximized", maximized)
                self.logger.debug(f"Window config updated: {width}x{height} at ({x},{y})")
    #         except Exception as e:
                self.logger.error(f"Failed to update window config: {e}")

    #     def get_window_config(self) -> Dict[str, Any]:
    #         """Get window configuration."""
    #         return {
                "width": self.get("window.width", 1200),
                "height": self.get("window.height", 800),
                "min_width": self.get("window.min_width", 800),
                "min_height": self.get("window.min_height", 600),
                "x": self.get("window.x", 100),
                "y": self.get("window.y", 100),
                "maximized": self.get("window.maximized", False),
                "fullscreen": self.get("window.fullscreen", False)
    #         }

    #     def get_panel_configs(self) -> Dict[str, Dict[str, Any]]:
    #         """Get all panel configurations."""
            return self._config.get("panels", {})

    #     def update_panel_config(self, panel_name: str, **kwargs) -> None:
    #         """Update specific panel configuration."""
    #         try:
    #             if f"panels.{panel_name}" not in [f"panels.{k}" for k in self._config.get("panels", {}).keys()]:
    self._config.setdefault("panels", {})[panel_name] = {}

    #             for key, value in kwargs.items():
                    self.set(f"panels.{panel_name}.{key}", value)

                self.logger.debug(f"Panel '{panel_name}' config updated: {kwargs}")
    #         except Exception as e:
    #             self.logger.error(f"Failed to update panel config for '{panel_name}': {e}")

    #     def get_ai_settings(self) -> Dict[str, Any]:
    #         """Get AI settings."""
            return self._config.get("ai_settings", {})

    #     def set_ai_settings(self, provider: str, model: str, api_key: str = "") -> None:
    #         """Set AI settings."""
    #         try:
                self.set("ai_settings.provider", provider)
                self.set("ai_settings.model", model)
                self.set("ai_settings.api_key", api_key)
                self.logger.debug(f"AI settings updated: {provider}/{model}")
    #         except Exception as e:
                self.logger.error(f"Failed to set AI settings: {e}")

    #     def get_layout_settings(self) -> Dict[str, Any]:
    #         """Get layout settings."""
            return self._config.get("layout", {})

    #     def set_layout_setting(self, key: str, value: Any) -> None:
    #         """Set layout setting."""
            self.set(f"layout.{key}", value)

    #     def reset_to_defaults(self) -> None:
    #         """Reset configuration to defaults."""
    #         try:
    self._config = self._default_config.copy()
                self.save_config()
                self.logger.info("Configuration reset to defaults")
    #         except Exception as e:
                self.logger.error(f"Failed to reset configuration: {e}")

    #     def validate_config(self) -> bool:
    #         """Validate current configuration."""
    #         try:
    #             # Check window configuration
    window = self.get_window_config()
    #             if not all(isinstance(window.get(k, 0), int) for k in ["width", "height", "x", "y"]):
                    self.logger.warning("Invalid window configuration")
    #                 return False

    #             # Check panel configurations
    panels = self.get_panel_configs()
    #             for panel_name, panel_config in panels.items():
    #                 if not isinstance(panel_config, dict):
    #                     self.logger.warning(f"Invalid panel configuration for '{panel_name}'")
    #                     return False

                self.logger.info("Configuration validation successful")
    #             return True

    #         except Exception as e:
                self.logger.error(f"Configuration validation failed: {e}")
    #             return False


# Global configuration instance
_global_config = None


def get_global_config() -> IdeConfig:
#     """Get global configuration instance."""
#     global _global_config
#     if _global_config is None:
_global_config = IdeConfig()
#     return _global_config


def reload_global_config() -> IdeConfig:
#     """Reload global configuration instance."""
#     global _global_config
_global_config = IdeConfig()
#     return _global_config