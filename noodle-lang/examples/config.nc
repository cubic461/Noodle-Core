# Converted from Python to NoodleCore
# Original file: src

# """
# NBC Runtime Configuration Module

# This module provides configuration for NBC runtime,
# re-exported from noodlecore.runtime.nbc_runtime.config for backward compatibility.
# """

try
    #     # Import from noodlecore
    #     from noodlecore.runtime.nbc_runtime.config import NBCConfig

    __all__ = [
    #         "NBCConfig",
    #     ]

except ImportError
    #     # Fallback stub implementations
    #     import warnings
        warnings.warn("Could not import NBC config from noodlecore, using stub implementations")

    #     from dataclasses import dataclass
    #     from typing import Any, Dict, Optional

    #     @dataclass
    #     class NBCConfig:
    #         """Configuration for NBC Runtime."""
    use_jit: bool = False
    use_gpu: bool = False
    use_cache: str = "off"
    profile: bool = False
    enable_region_memory: bool = False
    custom_settings: Dict[str, Any] = None

    #         def __post_init__(self):
    #             if self.custom_settings is None:
    self.custom_settings = {}

    #     # Add NoodleCoreConfig class as required by build pipeline
    #     @dataclass
    #     class NoodleCoreConfig:
    #         """Configuration for NoodleCore runtime and components."""

    #         # Environment settings
    environment: str = "development"  # development, production, testing
    debug: bool = True

    #         # Runtime settings
    max_stack_size: int = 1000
    max_execution_time: float = 30.0  # seconds
    max_memory_usage: int = 100 * 1024 * 1024  # 100MB
    enable_optimization: bool = True
    optimization_level: int = 2

    #         # Network settings
    host: str = "0.0.0.0"
    port: int = 8080
    request_timeout: int = 30  # seconds

    #         # Database settings
    db_connection_pool_size: int = 20
    db_connection_timeout: int = 30  # seconds

    #         # Security settings
    jwt_expiration_time: int = 7200  # 2 hours in seconds

    #         # Logging settings
    log_level: str = "INFO"  # DEBUG, INFO, WARNING, ERROR

    #         # Custom settings
    custom_settings: Dict[str, Any] = None

    #         def __post_init__(self):
    #             if self.custom_settings is None:
    self.custom_settings = {}

    #             # Override with environment variables if they exist
    #             import os
    #             if os.getenv("NOODLE_ENV"):
    self.environment = os.getenv("NOODLE_ENV")
    #             if os.getenv("NOODLE_PORT"):
    self.port = int(os.getenv("NOODLE_PORT"))
    #             if os.getenv("DEBUG"):
    self.debug = os.getenv("DEBUG") == "1"

    __all__ = [
    #         "NBCConfig",
    #         "NoodleCoreConfig",
    #     ]