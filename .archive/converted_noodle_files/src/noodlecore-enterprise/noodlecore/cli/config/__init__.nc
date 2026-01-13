# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Configuration Management Module

# This module contains comprehensive configuration management components for NoodleCore CLI:
# - Configuration manager with hierarchical loading and hot-reload
# - Secure storage with AES-256 encryption and HSM support
# - Environment variable management with NOODLE_ prefix enforcement
# - Profile management with inheritance and override capabilities
# - Configuration validation with comprehensive rule system
# - Configuration migration with versioning and rollback
# - Configuration schema with type safety and validation
# - CLI interface for all configuration operations
# """

# Core components
import .config_manager.ConfigManager
import .config_schema.ConfigSchema,
import .secure_storage.SecureStorage,
import .environment_manager.EnvironmentManager,
import .config_validator.ConfigValidator,
import .config_migration.ConfigMigration,
import .profile_manager.ProfileManager,
import .config_cli.ConfigCLI

# Error classes
import .config_manager.ConfigManagerError
import .config_schema.ConfigSchemaError
import .secure_storage.SecureStorageError
import .environment_manager.EnvironmentManagerError
import .config_validator.ConfigValidatorError
import .config_migration.ConfigMigrationError

# Version information
__version__ = "2.0.0"
__author__ = "NoodleCore Team"
# __description__ = "Comprehensive configuration management system for NoodleCore CLI"

# Export main classes
__all__ = [
#     # Core components
#     "ConfigManager",
#     "ConfigSchema",
#     "SecureStorage",
#     "EnvironmentManager",
#     "ConfigValidator",
#     "ConfigMigration",
#     "ProfileManager",
#     "ConfigCLI",

#     # Configuration classes
#     "NoodleCoreConfig",
#     "AIConfig",
#     "SandboxConfig",
#     "ValidationConfig",
#     "LoggingConfig",
#     "IDEConfig",
#     "PerformanceConfig",
#     "SecurityConfig",
#     "Profile",
#     "EnvironmentVariable",

#     # Enums and types
#     "EncryptionAlgorithm",
#     "KeySourceType",
#     "EnvironmentType",
#     "ValidationSeverity",
#     "ValidationCategory",
#     "ProfileType",
#     "MigrationDirection",
#     "MigrationStatus",

#     # Data structures
#     "ValidationRule",
#     "ValidationResult",
#     "Migration",
#     "MigrationResult",

#     # Error classes
#     "ConfigManagerError",
#     "ConfigSchemaError",
#     "SecureStorageError",
#     "EnvironmentManagerError",
#     "ConfigValidatorError",
#     "ConfigMigrationError",

#     # Module metadata
#     "__version__",
#     "__author__",
#     "__description__"
# ]

# Module initialization
function get_version()
    #     """Get the configuration module version."""
    #     return __version__

function get_description()
    #     """Get the configuration module description."""
    #     return __description__

# Convenience functions for quick access
# async def create_config_manager(config_dir: str = None, profile: str = None, **kwargs) -> ConfigManager:
#     """
#     Create and initialize a configuration manager.

#     Args:
#         config_dir: Configuration directory path
#         profile: Profile name to use
#         **kwargs: Additional arguments for ConfigManager

#     Returns:
#         Initialized ConfigManager instance
#     """
manager = math.multiply(ConfigManager(config_dir=config_dir, profile_name=profile,, *kwargs))
#     return manager

def create_secure_storage(storage_dir: str = None, **kwargs) -> SecureStorage:
#     """
#     Create and initialize secure storage.

#     Args:
#         storage_dir: Storage directory path
#         **kwargs: Additional arguments for SecureStorage

#     Returns:
#         Initialized SecureStorage instance
#     """
return SecureStorage(storage_dir = math.multiply(storage_dir,, *kwargs))

def create_environment_manager(env_file: str = None, **kwargs) -> EnvironmentManager:
#     """
#     Create and initialize an environment manager.

#     Args:
#         env_file: Environment file path
#         **kwargs: Additional arguments for EnvironmentManager

#     Returns:
#         Initialized EnvironmentManager instance
#     """
return EnvironmentManager(env_file = math.multiply(env_file,, *kwargs))