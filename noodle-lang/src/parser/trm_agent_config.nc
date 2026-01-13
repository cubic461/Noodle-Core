# Converted from Python to NoodleCore
# Original file: src

# """
# TRM-Agent Configuration Adapter Module

# This module provides configuration management for TRM-Agent components,
# including loading from environment variables, configuration files, and
# providing default values.
# """

import os
import json
import enum.Enum
from dataclasses import dataclass
import typing.Dict

# Import TRM-Agent components
try
        from ..trm_agent_base import (         TRMModelConfig, OptimizationConfig, FeedbackConfig, TRMAgentConfig,
    #         QuantizationLevel, OptimizationType, ConfigurationError, Logger
    #     )
except ImportError
    #     # Fallback for when TRM-Agent components are not available
    #     class TRMModelConfig:
    #         def __init__(self):
    self.model_path = ""
    self.quantization_level = QuantizationLevel.SIXTEEN_BIT
    self.device = "cpu"
    self.enable_fallback = True
    self.max_memory_usage = 2 * 1024 * 1024 * 1024  # 2GB
    self.cache_dir = ""
    self.model_version = "latest"

    #     class OptimizationConfig:
    #         def __init__(self):
    self.enable_constant_folding = True
    self.enable_dead_code_elimination = True
    self.enable_loop_optimization = True
    self.enable_branch_optimization = True
    self.enable_memory_optimization = True
    self.enable_custom_optimizations = True
    self.optimization_threshold = 0.7
    self.max_optimization_time = 30.0  # seconds

    #     class FallbackConfig:
    #         def __init__(self):
    self.enable_fallback = True
    self.fallback_mode = "automatic"  # automatic, manual, disabled, forced
    self.timeout_threshold = 30.0  # seconds
    self.memory_limit_threshold = 0.8  # 80% of max memory
    self.enable_timeout_fallback = True
    self.enable_memory_fallback = True
    self.enable_model_unavailable_fallback = True
    self.enable_optimization_failure_fallback = True
    self.enable_transpiler_failure_fallback = True
    self.enable_compilation_error_fallback = True
    self.enable_memory_monitoring = True
    self.memory_check_interval = 1.0  # seconds
    self.max_fallback_events = 1000  # Maximum number of fallback events to store

    #     class FeedbackConfig:
    #         def __init__(self):
    self.collection_interval = 100  # collect feedback every N executions
    self.learning_rate = 0.001
    self.effectiveness_threshold = 0.9
    self.max_feedback_history = 10000
    self.enable_model_updates = True
    self.update_interval = 1000  # update model every N feedbacks

    #     class TRMAgentConfig:
    #         def __init__(self):
    self.model_config = TRMModelConfig()
    self.optimization_config = OptimizationConfig()
    self.feedback_config = FeedbackConfig()
    self.fallback_config = FallbackConfig()
    self.debug_mode = False
    self.log_level = "INFO"
    self.enable_profiling = False

    #     class QuantizationLevel(Enum):
    SIXTEEN_BIT = "16bit"
    EIGHT_BIT = "8bit"
    FOUR_BIT = "4bit"
    ONE_BIT = "1bit"

    #     class OptimizationType(Enum):
    CONSTANT_FOLDING = "constant_folding"
    DEAD_CODE_ELIMINATION = "dead_code_elimination"
    LOOP_OPTIMIZATION = "loop_optimization"
    BRANCH_OPTIMIZATION = "branch_optimization"
    MEMORY_OPTIMIZATION = "memory_optimization"
    CUSTOM = "custom"

    #     class ConfigurationError(Exception):
    #         def __init__(self, message, error_code=5003):
                super().__init__(message)
    self.error_code = error_code

    #     class Logger:
    #         def __init__(self, name):
    self.name = name

    #         def debug(self, msg):
                print(f"DEBUG: {msg}")

    #         def info(self, msg):
                print(f"INFO: {msg}")

    #         def warning(self, msg):
                print(f"WARNING: {msg}")

    #         def error(self, msg):
                print(f"ERROR: {msg}")


class TRMAgentConfigAdapter
    #     """
    #     Adapter for TRM-Agent configuration management.

    #     This class provides methods to load, validate, and manage TRM-Agent
    #     configuration from various sources including environment variables,
    #     configuration files, and default values.
    #     """

    #     def __init__(self):""Initialize the TRM-Agent configuration adapter."""
    self.logger = Logger("trm_agent_config_adapter")
    self._config = None
    self._config_file_path = None

    #     def load_config(self, config_file_path: Optional[str] = None) -TRMAgentConfig):
    #         """
    #         Load TRM-Agent configuration from file and environment variables.

    #         Args:
    #             config_file_path: Path to configuration file. If None, uses default paths.

    #         Returns:
    #             TRMAgentConfig: Loaded configuration.

    #         Raises:
    #             ConfigurationError: If configuration loading fails.
    #         """
    #         try:
    #             # Create default configuration
    config = TRMAgentConfig()

    #             # Load from file if provided or found in default locations
    file_path = config_file_path or self._find_config_file()
    #             if file_path and os.path.exists(file_path):
                    self.logger.info(f"Loading configuration from {file_path}")
    config = self._load_config_from_file(file_path, config)
    self._config_file_path = file_path
    #             else:
                    self.logger.info("No configuration file found, using defaults")

    #             # Override with environment variables
                self._load_config_from_env(config)

    #             # Validate configuration
                self._validate_config(config)

    #             # Store the configuration
    self._config = config

                self.logger.info("TRM-Agent configuration loaded successfully")
    #             return config

    #         except Exception as e:
                self.logger.error(f"Failed to load configuration: {str(e)}")
                raise ConfigurationError(f"Failed to load configuration: {str(e)}")

    #     def get_config(self) -TRMAgentConfig):
    #         """
    #         Get the current configuration.

    #         Returns:
    #             TRMAgentConfig: Current configuration.

    #         Raises:
    #             ConfigurationError: If configuration is not loaded.
    #         """
    #         if self._config is None:
                raise ConfigurationError("Configuration not loaded. Call load_config() first.")
    #         return self._config

    #     def save_config(self, config: TRMAgentConfig, file_path: str):
    #         """
    #         Save configuration to file.

    #         Args:
    #             config: Configuration to save.
    #             file_path: Path to save the configuration.

    #         Raises:
    #             ConfigurationError: If configuration saving fails.
    #         """
    #         try:
    config_dict = {
    #                 'model_config': {
    #                     'model_path': config.model_config.model_path,
    #                     'quantization_level': config.model_config.quantization_level.value,
    #                     'device': config.model_config.device,
    #                     'enable_fallback': config.model_config.enable_fallback,
    #                     'max_memory_usage': config.model_config.max_memory_usage,
    #                     'cache_dir': config.model_config.cache_dir,
    #                     'model_version': config.model_config.model_version
    #                 },
    #                 'optimization_config': {
    #                     'enable_constant_folding': config.optimization_config.enable_constant_folding,
    #                     'enable_dead_code_elimination': config.optimization_config.enable_dead_code_elimination,
    #                     'enable_loop_optimization': config.optimization_config.enable_loop_optimization,
    #                     'enable_branch_optimization': config.optimization_config.enable_branch_optimization,
    #                     'enable_memory_optimization': config.optimization_config.enable_memory_optimization,
    #                     'enable_custom_optimizations': config.optimization_config.enable_custom_optimizations,
    #                     'optimization_threshold': config.optimization_config.optimization_threshold,
    #                     'max_optimization_time': config.optimization_config.max_optimization_time
    #                 },
    #                 'feedback_config': {
    #                     'collection_interval': config.feedback_config.collection_interval,
    #                     'learning_rate': config.feedback_config.learning_rate,
    #                     'effectiveness_threshold': config.feedback_config.effectiveness_threshold,
    #                     'max_feedback_history': config.feedback_config.max_feedback_history,
    #                     'enable_model_updates': config.feedback_config.enable_model_updates,
    #                     'update_interval': config.feedback_config.update_interval
    #                 },
    #                 'fallback_config': {
    #                     'enable_fallback': config.fallback_config.enable_fallback,
    #                     'fallback_mode': config.fallback_config.fallback_mode,
    #                     'timeout_threshold': config.fallback_config.timeout_threshold,
    #                     'memory_limit_threshold': config.fallback_config.memory_limit_threshold,
    #                     'enable_timeout_fallback': config.fallback_config.enable_timeout_fallback,
    #                     'enable_memory_fallback': config.fallback_config.enable_memory_fallback,
    #                     'enable_model_unavailable_fallback': config.fallback_config.enable_model_unavailable_fallback,
    #                     'enable_optimization_failure_fallback': config.fallback_config.enable_optimization_failure_fallback,
    #                     'enable_transpiler_failure_fallback': config.fallback_config.enable_transpiler_failure_fallback,
    #                     'enable_compilation_error_fallback': config.fallback_config.enable_compilation_error_fallback,
    #                     'enable_memory_monitoring': config.fallback_config.enable_memory_monitoring,
    #                     'memory_check_interval': config.fallback_config.memory_check_interval,
    #                     'max_fallback_events': config.fallback_config.max_fallback_events
    #                 },
    #                 'debug_mode': config.debug_mode,
    #                 'log_level': config.log_level,
    #                 'enable_profiling': config.enable_profiling
    #             }

    #             # Create directory if it doesn't exist
    os.makedirs(os.path.dirname(file_path), exist_ok = True)

    #             with open(file_path, 'w') as f:
    json.dump(config_dict, f, indent = 2)

                self.logger.info(f"Configuration saved to {file_path}")

    #         except Exception as e:
                self.logger.error(f"Failed to save configuration: {str(e)}")
                raise ConfigurationError(f"Failed to save configuration: {str(e)}")

    #     def update_config(self, updates: Dict[str, Any]):
    #         """
    #         Update configuration with new values.

    #         Args:
    #             updates: Dictionary of configuration updates.

    #         Raises:
    #             ConfigurationError: If configuration update fails.
    #         """
    #         if self._config is None:
                raise ConfigurationError("Configuration not loaded. Call load_config() first.")

    #         try:
    #             # Apply updates
    #             for key, value in updates.items():
    #                 if hasattr(self._config, key):
                        setattr(self._config, key, value)
    #                 else:
                        self.logger.warning(f"Unknown configuration key: {key}")

    #             # Validate updated configuration
                self._validate_config(self._config)

                self.logger.info("Configuration updated successfully")

    #         except Exception as e:
                self.logger.error(f"Failed to update configuration: {str(e)}")
                raise ConfigurationError(f"Failed to update configuration: {str(e)}")

    #     def _find_config_file(self) -Optional[str]):
    #         """
    #         Find configuration file in default locations.

    #         Returns:
    #             Optional[str]: Path to configuration file if found, None otherwise.
    #         """
    #         # Possible configuration file locations
    possible_paths = [
                os.path.join(os.getcwd(), "trm_agent_config.json"),
                os.path.join(os.path.expanduser("~"), ".noodle", "trm_agent_config.json"),
                os.path.join(os.environ.get("NOODLE_CONFIG_DIR", ""), "trm_agent_config.json"),
                os.path.join(os.path.dirname(__file__), "..", "..", "config", "trm_agent_config.json")
    #         ]

    #         for path in possible_paths:
    #             if os.path.exists(path):
    #                 return path

    #         return None

    #     def _load_config_from_file(self, file_path: str, config: TRMAgentConfig) -TRMAgentConfig):
    #         """
    #         Load configuration from file.

    #         Args:
    #             file_path: Path to configuration file.
    #             config: Configuration to update.

    #         Returns:
    #             TRMAgentConfig: Updated configuration.
    #         """
    #         try:
    #             with open(file_path, 'r') as f:
    config_dict = json.load(f)

    #             # Parse model config
    model_config_dict = config_dict.get('model_config', {})
    config.model_config.model_path = model_config_dict.get('model_path', "")
    quantization = model_config_dict.get('quantization_level', "16bit")
    #             try:
    config.model_config.quantization_level = QuantizationLevel(quantization)
    #             except ValueError:
                    self.logger.warning(f"Invalid quantization level: {quantization}")
    config.model_config.device = model_config_dict.get('device', "cpu")
    config.model_config.enable_fallback = model_config_dict.get('enable_fallback', True)
    config.model_config.max_memory_usage = model_config_dict.get('max_memory_usage', 2 * 1024 * 1024 * 1024)
    config.model_config.cache_dir = model_config_dict.get('cache_dir', "")
    config.model_config.model_version = model_config_dict.get('model_version', "latest")

    #             # Parse optimization config
    optimization_config_dict = config_dict.get('optimization_config', {})
    config.optimization_config.enable_constant_folding = optimization_config_dict.get('enable_constant_folding', True)
    config.optimization_config.enable_dead_code_elimination = optimization_config_dict.get('enable_dead_code_elimination', True)
    config.optimization_config.enable_loop_optimization = optimization_config_dict.get('enable_loop_optimization', True)
    config.optimization_config.enable_branch_optimization = optimization_config_dict.get('enable_branch_optimization', True)
    config.optimization_config.enable_memory_optimization = optimization_config_dict.get('enable_memory_optimization', True)
    config.optimization_config.enable_custom_optimizations = optimization_config_dict.get('enable_custom_optimizations', True)
    config.optimization_config.optimization_threshold = optimization_config_dict.get('optimization_threshold', 0.7)
    config.optimization_config.max_optimization_time = optimization_config_dict.get('max_optimization_time', 30.0)

    #             # Parse feedback config
    feedback_config_dict = config_dict.get('feedback_config', {})
    config.feedback_config.collection_interval = feedback_config_dict.get('collection_interval', 100)
    config.feedback_config.learning_rate = feedback_config_dict.get('learning_rate', 0.001)
    config.feedback_config.effectiveness_threshold = feedback_config_dict.get('effectiveness_threshold', 0.9)
    config.feedback_config.max_feedback_history = feedback_config_dict.get('max_feedback_history', 10000)
    config.feedback_config.enable_model_updates = feedback_config_dict.get('enable_model_updates', True)
    config.feedback_config.update_interval = feedback_config_dict.get('update_interval', 1000)

    #             # Parse fallback config
    fallback_config_dict = config_dict.get('fallback_config', {})
    config.fallback_config.enable_fallback = fallback_config_dict.get('enable_fallback', True)
    config.fallback_config.fallback_mode = fallback_config_dict.get('fallback_mode', "automatic")
    config.fallback_config.timeout_threshold = fallback_config_dict.get('timeout_threshold', 30.0)
    config.fallback_config.memory_limit_threshold = fallback_config_dict.get('memory_limit_threshold', 0.8)
    config.fallback_config.enable_timeout_fallback = fallback_config_dict.get('enable_timeout_fallback', True)
    config.fallback_config.enable_memory_fallback = fallback_config_dict.get('enable_memory_fallback', True)
    config.fallback_config.enable_model_unavailable_fallback = fallback_config_dict.get('enable_model_unavailable_fallback', True)
    config.fallback_config.enable_optimization_failure_fallback = fallback_config_dict.get('enable_optimization_failure_fallback', True)
    config.fallback_config.enable_transpiler_failure_fallback = fallback_config_dict.get('enable_transpiler_failure_fallback', True)
    config.fallback_config.enable_compilation_error_fallback = fallback_config_dict.get('enable_compilation_error_fallback', True)
    config.fallback_config.enable_memory_monitoring = fallback_config_dict.get('enable_memory_monitoring', True)
    config.fallback_config.memory_check_interval = fallback_config_dict.get('memory_check_interval', 1.0)
    config.fallback_config.max_fallback_events = fallback_config_dict.get('max_fallback_events', 1000)

    #             # Parse other config
    config.debug_mode = config_dict.get('debug_mode', False)
    config.log_level = config_dict.get('log_level', "INFO")
    config.enable_profiling = config_dict.get('enable_profiling', False)

    #             return config

    #         except Exception as e:
                self.logger.error(f"Failed to load configuration from file: {str(e)}")
                raise ConfigurationError(f"Failed to load configuration from file: {str(e)}")

    #     def _load_config_from_env(self, config: TRMAgentConfig):
    #         """
    #         Load configuration from environment variables.

    #         Args:
    #             config: Configuration to update.
    #         """
    #         # Model configuration
    model_path = os.environ.get("NOODLE_TRM_MODEL_PATH", "")
    #         if model_path:
    config.model_config.model_path = model_path

    quantization = os.environ.get("NOODLE_TRM_QUANTIZATION", "")
    #         if quantization:
    #             try:
    config.model_config.quantization_level = QuantizationLevel(quantization)
    #             except ValueError:
                    self.logger.warning(f"Invalid quantization level: {quantization}")

    device = os.environ.get("NOODLE_TRM_DEVICE", "")
    #         if device:
    config.model_config.device = device

    enable_fallback = os.environ.get("NOODLE_TRM_ENABLE_FALLBACK", "")
    #         if enable_fallback:
    config.model_config.enable_fallback = enable_fallback.lower() in ["true", "1", "yes"]

    max_memory = os.environ.get("NOODLE_TRM_MAX_MEMORY", "")
    #         if max_memory:
    #             try:
    config.model_config.max_memory_usage = int(max_memory)
    #             except ValueError:
                    self.logger.warning(f"Invalid max memory value: {max_memory}")

    #         # Optimization configuration
    opt_threshold = os.environ.get("NOODLE_TRM_OPTIMIZATION_THRESHOLD", "")
    #         if opt_threshold:
    #             try:
    config.optimization_config.optimization_threshold = float(opt_threshold)
    #             except ValueError:
                    self.logger.warning(f"Invalid optimization threshold: {opt_threshold}")

    max_opt_time = os.environ.get("NOODLE_TRM_MAX_OPTIMIZATION_TIME", "")
    #         if max_opt_time:
    #             try:
    config.optimization_config.max_optimization_time = float(max_opt_time)
    #             except ValueError:
                    self.logger.warning(f"Invalid max optimization time: {max_opt_time}")

    #         # Feedback configuration
    feedback_interval = os.environ.get("NOODLE_TRM_FEEDBACK_INTERVAL", "")
    #         if feedback_interval:
    #             try:
    config.feedback_config.collection_interval = int(feedback_interval)
    #             except ValueError:
                    self.logger.warning(f"Invalid feedback interval: {feedback_interval}")

    enable_updates = os.environ.get("NOODLE_TRM_ENABLE_MODEL_UPDATES", "")
    #         if enable_updates:
    config.feedback_config.enable_model_updates = enable_updates.lower() in ["true", "1", "yes"]

    #         # Fallback configuration
    enable_fallback = os.environ.get("NOODLE_TRM_ENABLE_FALLBACK", "")
    #         if enable_fallback:
    config.fallback_config.enable_fallback = enable_fallback.lower() in ["true", "1", "yes"]

    fallback_mode = os.environ.get("NOODLE_TRM_FALLBACK_MODE", "")
    #         if fallback_mode:
    config.fallback_config.fallback_mode = fallback_mode

    timeout_threshold = os.environ.get("NOODLE_TRM_TIMEOUT_THRESHOLD", "")
    #         if timeout_threshold:
    #             try:
    config.fallback_config.timeout_threshold = float(timeout_threshold)
    #             except ValueError:
                    self.logger.warning(f"Invalid timeout threshold: {timeout_threshold}")

    memory_limit_threshold = os.environ.get("NOODLE_TRM_MEMORY_LIMIT_THRESHOLD", "")
    #         if memory_limit_threshold:
    #             try:
    config.fallback_config.memory_limit_threshold = float(memory_limit_threshold)
    #             except ValueError:
                    self.logger.warning(f"Invalid memory limit threshold: {memory_limit_threshold}")

    enable_timeout_fallback = os.environ.get("NOODLE_TRM_ENABLE_TIMEOUT_FALLBACK", "")
    #         if enable_timeout_fallback:
    config.fallback_config.enable_timeout_fallback = enable_timeout_fallback.lower() in ["true", "1", "yes"]

    enable_memory_fallback = os.environ.get("NOODLE_TRM_ENABLE_MEMORY_FALLBACK", "")
    #         if enable_memory_fallback:
    config.fallback_config.enable_memory_fallback = enable_memory_fallback.lower() in ["true", "1", "yes"]

    enable_optimization_failure_fallback = os.environ.get("NOODLE_TRM_ENABLE_OPTIMIZATION_FAILURE_FALLBACK", "")
    #         if enable_optimization_failure_fallback:
    config.fallback_config.enable_optimization_failure_fallback = enable_optimization_failure_fallback.lower() in ["true", "1", "yes"]

    #         # General configuration
    log_level = os.environ.get("NOODLE_TRM_LOG_LEVEL", "")
    #         if log_level:
    config.log_level = log_level

    debug_mode = os.environ.get("NOODLE_TRM_DEBUG_MODE", "")
    #         if debug_mode:
    config.debug_mode = debug_mode.lower() in ["true", "1", "yes"]

    profiling = os.environ.get("NOODLE_TRM_ENABLE_PROFILING", "")
    #         if profiling:
    config.enable_profiling = profiling.lower() in ["true", "1", "yes"]

    #     def _validate_config(self, config: TRMAgentConfig):
    #         """
    #         Validate the configuration.

    #         Args:
    #             config: Configuration to validate.

    #         Raises:
    #             ConfigurationError: If configuration is invalid.
    #         """
    #         # Validate model path if provided
    #         if config.model_config.model_path and not os.path.exists(config.model_config.model_path):
                self.logger.warning(f"Model path does not exist: {config.model_config.model_path}")

    #         # Validate device
    valid_devices = ["cpu", "cuda", "mps"]
    #         if config.model_config.device not in valid_devices:
                raise ConfigurationError(f"Invalid device: {config.model_config.device}. Valid devices: {valid_devices}")

    #         # Validate memory usage
    #         if config.model_config.max_memory_usage <= 0:
                raise ConfigurationError("Maximum memory usage must be positive")

    #         # Validate optimization threshold
    #         if not (0.0 <= config.optimization_config.optimization_threshold <= 1.0):
                raise ConfigurationError("Optimization threshold must be between 0.0 and 1.0")

    #         # Validate optimization time
    #         if config.optimization_config.max_optimization_time <= 0:
                raise ConfigurationError("Maximum optimization time must be positive")

    #         # Validate feedback interval
    #         if config.feedback_config.collection_interval <= 0:
                raise ConfigurationError("Feedback collection interval must be positive")

    #         # Validate learning rate
    #         if config.feedback_config.learning_rate <= 0:
                raise ConfigurationError("Learning rate must be positive")

    #         # Validate effectiveness threshold
    #         if not (0.0 <= config.feedback_config.effectiveness_threshold <= 1.0):
                raise ConfigurationError("Effectiveness threshold must be between 0.0 and 1.0")

    #         # Validate feedback history
    #         if config.feedback_config.max_feedback_history <= 0:
                raise ConfigurationError("Max feedback history must be positive")

    #         # Validate update interval
    #         if config.feedback_config.update_interval <= 0:
                raise ConfigurationError("Update interval must be positive")

    #         # Validate log level
    valid_log_levels = ["DEBUG", "INFO", "WARNING", "ERROR"]
    #         if config.log_level not in valid_log_levels:
                raise ConfigurationError(f"Invalid log level: {config.log_level}. Valid levels: {valid_log_levels}")

    #     def create_default_config_file(self, file_path: str):
    #         """
    #         Create a default configuration file.

    #         Args:
    #             file_path: Path to create the configuration file.

    #         Raises:
    #             ConfigurationError: If file creation fails.
    #         """
    #         try:
    #             # Create default configuration
    config = TRMAgentConfig()

    #             # Save to file
                self.save_config(config, file_path)

                self.logger.info(f"Default configuration file created at {file_path}")

    #         except Exception as e:
                self.logger.error(f"Failed to create default configuration file: {str(e)}")
                raise ConfigurationError(f"Failed to create default configuration file: {str(e)}")

    #     def get_config_summary(self) -Dict[str, Any]):
    #         """
    #         Get a summary of the current configuration.

    #         Returns:
    #             Dict[str, Any]: Configuration summary.

    #         Raises:
    #             ConfigurationError: If configuration is not loaded.
    #         """
    #         if self._config is None:
                raise ConfigurationError("Configuration not loaded. Call load_config() first.")

    #         return {
    #             'model_path': self._config.model_config.model_path,
    #             'quantization_level': self._config.model_config.quantization_level.value,
    #             'device': self._config.model_config.device,
    #             'enable_fallback': self._config.model_config.enable_fallback,
    #             'max_memory_usage': self._config.model_config.max_memory_usage,
    #             'optimization_threshold': self._config.optimization_config.optimization_threshold,
    #             'max_optimization_time': self._config.optimization_config.max_optimization_time,
    #             'enable_model_updates': self._config.feedback_config.enable_model_updates,
    #             'fallback_enabled': self._config.fallback_config.enable_fallback,
    #             'fallback_mode': self._config.fallback_config.fallback_mode,
    #             'timeout_threshold': self._config.fallback_config.timeout_threshold,
    #             'memory_limit_threshold': self._config.fallback_config.memory_limit_threshold,
    #             'debug_mode': self._config.debug_mode,
    #             'log_level': self._config.log_level,
    #             'config_file_path': self._config_file_path
    #         }


# Global configuration adapter instance
_config_adapter = None


def get_config_adapter() -TRMAgentConfigAdapter):
#     """
#     Get the global configuration adapter instance.

#     Returns:
#         TRMAgentConfigAdapter: Global configuration adapter.
#     """
#     global _config_adapter
#     if _config_adapter is None:
_config_adapter = TRMAgentConfigAdapter()
#     return _config_adapter


def load_trm_agent_config(config_file_path: Optional[str] = None) -TRMAgentConfig):
#     """
#     Load TRM-Agent configuration using the global adapter.

#     Args:
#         config_file_path: Path to configuration file.

#     Returns:
#         TRMAgentConfig: Loaded configuration.
#     """
adapter = get_config_adapter()
    return adapter.load_config(config_file_path)


def get_trm_agent_config() -TRMAgentConfig):
#     """
#     Get the current TRM-Agent configuration using the global adapter.

#     Returns:
#         TRMAgentConfig: Current configuration.
#     """
adapter = get_config_adapter()
    return adapter.get_config()