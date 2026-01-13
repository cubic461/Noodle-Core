# Converted from Python to NoodleCore
# Original file: src

# """
# Configuration Schema Module

# This module defines the comprehensive configuration schema for all NoodleCore CLI components.
# """

import logging
import typing.Dict
from dataclasses import dataclass
import enum.Enum


class LogLevel(Enum):""Log levels for configuration."""
    DEBUG = "DEBUG"
    INFO = "INFO"
    WARNING = "WARNING"
    ERROR = "ERROR"


class SerializationFormat(Enum)
    #     """Supported serialization formats."""
    MSGPACK = "msgpack"
    JSON = "json"
    YAML = "yaml"


dataclass
class AIModelConfig
    #     """Configuration for AI model."""
    #     provider: str
    #     api_base: str
    #     api_key: str  # Can be "env:VAR_NAME" format
    #     model_name: str
    #     system_prompt: str
    max_tokens: int = 4096
    temperature: float = 0.7
    timeout: int = 30
    retry_attempts: int = 3
    retry_delay: float = 1.0


dataclass
class AIConfig
    #     """AI configuration section."""
    default_model: str = "zai_glm"
    models: Dict[str, AIModelConfig] = field(default_factory=dict)
    fallback_enabled: bool = True
    fallback_model: Optional[str] = None
    request_timeout: int = 30
    max_concurrent_requests: int = 5


dataclass
class SandboxConfig
    #     """Sandbox configuration section."""
    directory: str = ".project/.noodle/sandbox/"
    execution_timeout: int = 30
    memory_limit: str = "2GB"
    cpu_limit: str = "50%"
    disk_limit: str = "1GB"
    network_enabled: bool = False
    allowed_paths: List[str] = field(default_factory=list)
    blocked_paths: List[str] = field(default_factory=list)
    environment_variables: Dict[str, str] = field(default_factory=dict)
    security_level: str = "medium"  # low, medium, high


dataclass
class ValidationConfig
    #     """Validation configuration section."""
    strict_mode: bool = True
    auto_fix: bool = False
    security_scan: bool = True
    performance_scan: bool = True
    code_style_check: bool = True
    dependency_check: bool = True
    custom_rules: List[str] = field(default_factory=list)
    excluded_patterns: List[str] = field(default_factory=list)
    timeout: int = 60


dataclass
class LoggingConfig
    #     """Logging configuration section."""
    level: LogLevel = LogLevel.INFO
    format: str = "json"  # json, text, structured
    outputs: List[str] = field(default_factory=lambda: ["file", "console"])
    file_path: str = ".project/.noodle/logs/cli.log"
    max_file_size: str = "10MB"
    backup_count: int = 5
    rotation: str = "daily"  # daily, weekly, size
    structured_fields: List[str] = field(default_factory=lambda: ["timestamp", "level", "message", "module"])


dataclass
class IDEConfig
    #     """IDE integration configuration section."""
    lsp_port: int = 8080
    auto_start: bool = True
    real_time_validation: bool = True
    auto_save: bool = True
    auto_format: bool = True
    completion_enabled: bool = True
    diagnostics_enabled: bool = True
    hover_enabled: bool = True
    goto_definition_enabled: bool = True
    find_references_enabled: bool = True


dataclass
class PerformanceConfig
    #     """Performance and monitoring configuration section."""
    cache_enabled: bool = True
    cache_size: str = "100MB"
    cache_ttl: int = 3600
    profiling_enabled: bool = False
    metrics_enabled: bool = True
    metrics_port: int = 9090
    memory_monitoring: bool = True
    cpu_monitoring: bool = True
    response_time_threshold: float = 0.5


dataclass
class SecurityConfig
    #     """Security configuration section."""
    encryption_enabled: bool = True
    key_rotation_days: int = 90
    audit_logging: bool = True
    access_control_enabled: bool = False
    allowed_ips: List[str] = field(default_factory=list)
    blocked_ips: List[str] = field(default_factory=list)
    max_login_attempts: int = 5
    session_timeout: int = 7200


dataclass
class NetworkConfig
    #     """Network configuration section."""
    proxy_enabled: bool = False
    proxy_host: Optional[str] = None
    proxy_port: Optional[int] = None
    proxy_username: Optional[str] = None
    proxy_password: Optional[str] = None
    ssl_verify: bool = True
    connection_timeout: int = 30
    read_timeout: int = 60
    max_retries: int = 3


dataclass
class DatabaseConfig
    #     """Database configuration section."""
    enabled: bool = False
    host: str = "localhost"
    port: int = 5432
    database: str = "noodlecore"
    username: str = "noodlecore"
    password: str = "env:NOODLE_DB_PASSWORD"
    pool_size: int = 20
    connection_timeout: int = 30
    ssl_mode: str = "prefer"


dataclass
class NoodleCoreConfig
    #     """Main configuration schema for NoodleCore CLI."""
    version: str = "1.0.0"
    profile: str = "default"

    #     # Configuration sections
    ai: AIConfig = field(default_factory=AIConfig)
    sandbox: SandboxConfig = field(default_factory=SandboxConfig)
    validation: ValidationConfig = field(default_factory=ValidationConfig)
    logging: LoggingConfig = field(default_factory=LoggingConfig)
    ide: IDEConfig = field(default_factory=IDEConfig)
    performance: PerformanceConfig = field(default_factory=PerformanceConfig)
    security: SecurityConfig = field(default_factory=SecurityConfig)
    network: NetworkConfig = field(default_factory=NetworkConfig)
    database: DatabaseConfig = field(default_factory=DatabaseConfig)

    #     # Global settings
    debug_mode: bool = False
    auto_backup: bool = True
    backup_retention_days: int = 30
    serialization_format: SerializationFormat = SerializationFormat.MSGPACK
    hot_reload: bool = True


class ConfigSchemaError(Exception)
    #     """Configuration schema error with 4-digit error code."""

    #     def __init__(self, message: str, error_code: int = 4001):
    self.error_code = error_code
            super().__init__(message)


class ConfigSchema
    #     """Configuration schema manager."""

    #     def __init__(self):""Initialize the configuration schema manager."""
    self.name = "ConfigSchema"
    self.logger = logging.getLogger(__name__)
    self._schema = self._get_default_schema()

    #     def _get_default_schema(self) -Dict[str, Any]):
    #         """Get the default configuration schema."""
    #         # Create default AI models
    default_models = {
                "zai_glm": AIModelConfig(
    provider = "zai",
    api_base = "https://open.bigmodel.cn/api/paas/v4/chat/completions",
    api_key = "env:ZAI_API_KEY",
    model_name = "glm-4-6",
    system_prompt = "Je bent een NoodleCore-ontwikkelaar..."
    #             ),
                "openrouter": AIModelConfig(
    provider = "openrouter",
    api_base = "https://openrouter.ai/api/v1/chat/completions",
    api_key = "env:OPENROUTER_API_KEY",
    model_name = "meta-llama/llama-3.1-70b-instruct",
    system_prompt = "Je schrijft uitsluitend NoodleCore-code..."
    #             )
    #         }

    #         # Create default config
    config = NoodleCoreConfig()
    config.ai.models = default_models

            return self._dataclass_to_dict(config)

    #     def _dataclass_to_dict(self, obj) -Dict[str, Any]):
    #         """Convert dataclass to dictionary."""
    #         if hasattr(obj, '__dataclass_fields__'):
    result = {}
    #             for field_name, field_def in obj.__dataclass_fields__.items():
    value = getattr(obj, field_name)
    #                 if hasattr(value, '__dataclass_fields__'):
    result[field_name] = self._dataclass_to_dict(value)
    #                 elif isinstance(value, dict):
    result[field_name] = {
    #                         k: self._dataclass_to_dict(v) if hasattr(v, '__dataclass_fields__') else v
    #                         for k, v in value.items()
    #                     }
    #                 elif isinstance(value, list):
    result[field_name] = [
    #                         self._dataclass_to_dict(item) if hasattr(item, '__dataclass_fields__') else item
    #                         for item in value
    #                     ]
    #                 elif isinstance(value, Enum):
    result[field_name] = value.value
    #                 else:
    result[field_name] = value
    #             return result
    #         else:
    #             return obj

    #     def get_schema(self) -Dict[str, Any]):
    #         """
    #         Get the configuration schema.

    #         Returns:
    #             Configuration schema dictionary
    #         """
            return self._schema.copy()

    #     def validate_config(self, config: Dict[str, Any]) -Dict[str, Any]):
    #         """
    #         Validate configuration against schema.

    #         Args:
    #             config: Configuration to validate

    #         Returns:
    #             Validation result
    #         """
    #         try:
    errors = []
    warnings = []

    #             # Validate required sections
    required_sections = ['ai', 'sandbox', 'validation', 'logging', 'ide']
    #             for section in required_sections:
    #                 if section not in config:
                        errors.append(f"Missing required section: {section}")

    #             # Validate AI configuration
    #             if 'ai' in config:
    ai_errors = self._validate_ai_config(config['ai'])
                    errors.extend(ai_errors)

    #             # Validate sandbox configuration
    #             if 'sandbox' in config:
    sandbox_errors = self._validate_sandbox_config(config['sandbox'])
                    errors.extend(sandbox_errors)

    #             # Validate logging configuration
    #             if 'logging' in config:
    logging_errors = self._validate_logging_config(config['logging'])
                    errors.extend(logging_errors)

    #             # Validate IDE configuration
    #             if 'ide' in config:
    ide_errors = self._validate_ide_config(config['ide'])
                    errors.extend(ide_errors)

    #             # Validate performance configuration
    #             if 'performance' in config:
    perf_errors = self._validate_performance_config(config['performance'])
                    errors.extend(perf_errors)

    #             return {
    'valid': len(errors) = = 0,
    #                 'errors': errors,
    #                 'warnings': warnings
    #             }

    #         except Exception as e:
                self.logger.error(f"Schema validation failed: {str(e)}")
    #             return {
    #                 'valid': False,
                    'errors': [f"Schema validation error: {str(e)}"],
    #                 'warnings': []
    #             }

    #     def _validate_ai_config(self, ai_config: Dict[str, Any]) -List[str]):
    #         """Validate AI configuration section."""
    errors = []

    #         # Check default model exists
    #         if 'default_model' in ai_config and 'models' in ai_config:
    default_model = ai_config['default_model']
    #             if default_model not in ai_config['models']:
                    errors.append(f"Default AI model '{default_model}' not found in models configuration")

    #         # Validate each model
    #         if 'models' in ai_config:
    #             for model_name, model_config in ai_config['models'].items():
    #                 if not isinstance(model_config, dict):
                        errors.append(f"Model '{model_name}' configuration must be a dictionary")
    #                     continue

    #                 # Required fields
    required_fields = ['provider', 'api_base', 'api_key', 'model_name', 'system_prompt']
    #                 for field in required_fields:
    #                     if field not in model_config:
                            errors.append(f"Model '{model_name}' missing required field: {field}")

    #                 # Validate API key format
    #                 if 'api_key' in model_config:
    api_key = model_config['api_key']
    #                     if not (api_key.startswith('env:') or len(api_key) 10)):
                            errors.append(f"Model '{model_name}' API key must be environment variable or valid key")

    #         return errors

    #     def _validate_sandbox_config(self, sandbox_config: Dict[str, Any]) -List[str]):
    #         """Validate sandbox configuration section."""
    errors = []

    #         # Validate timeout
    #         if 'execution_timeout' in sandbox_config:
    timeout = sandbox_config['execution_timeout']
    #             if not isinstance(timeout, int) or timeout <= 0:
                    errors.append("Sandbox execution_timeout must be a positive integer")

    #         # Validate memory limit format
    #         if 'memory_limit' in sandbox_config:
    memory_limit = sandbox_config['memory_limit']
    #             if not isinstance(memory_limit, str) or not memory_limit.endswith(('GB', 'MB', 'KB')):
    #                 errors.append("Sandbox memory_limit must end with GB, MB, or KB")

    #         # Validate CPU limit format
    #         if 'cpu_limit' in sandbox_config:
    cpu_limit = sandbox_config['cpu_limit']
    #             if not isinstance(cpu_limit, str) or not cpu_limit.endswith('%'):
    #                 errors.append("Sandbox cpu_limit must end with %")

    #         return errors

    #     def _validate_logging_config(self, logging_config: Dict[str, Any]) -List[str]):
    #         """Validate logging configuration section."""
    errors = []

    #         # Validate log level
    #         if 'level' in logging_config:
    level = logging_config['level']
    valid_levels = ['DEBUG', 'INFO', 'WARNING', 'ERROR']
    #             if level not in valid_levels:
                    errors.append(f"Log level must be one of: {', '.join(valid_levels)}")

    #         # Validate format
    #         if 'format' in logging_config:
    format_type = logging_config['format']
    valid_formats = ['json', 'text', 'structured']
    #             if format_type not in valid_formats:
                    errors.append(f"Log format must be one of: {', '.join(valid_formats)}")

    #         return errors

    #     def _validate_ide_config(self, ide_config: Dict[str, Any]) -List[str]):
    #         """Validate IDE configuration section."""
    errors = []

    #         # Validate LSP port
    #         if 'lsp_port' in ide_config:
    port = ide_config['lsp_port']
    #             if not isinstance(port, int) or not (1024 <= port <= 65535):
                    errors.append("IDE lsp_port must be between 1024 and 65535")

    #         return errors

    #     def _validate_performance_config(self, perf_config: Dict[str, Any]) -List[str]):
    #         """Validate performance configuration section."""
    errors = []

    #         # Validate metrics port
    #         if 'metrics_port' in perf_config:
    port = perf_config['metrics_port']
    #             if not isinstance(port, int) or not (1024 <= port <= 65535):
                    errors.append("Performance metrics_port must be between 1024 and 65535")

    #         # Validate response time threshold
    #         if 'response_time_threshold' in perf_config:
    threshold = perf_config['response_time_threshold']
    #             if not isinstance(threshold, (int, float)) or threshold <= 0:
                    errors.append("Performance response_time_threshold must be a positive number")

    #         return errors

    #     def get_schema_info(self) -Dict[str, Any]):
    #         """
    #         Get information about the configuration schema.

    #         Returns:
    #             Schema information
    #         """
    #         return {
    #             'name': self.name,
    #             'version': '1.0.0',
                'sections': list(self._schema.keys()),
    #             'supported_formats': ['msgpack', 'json', 'yaml'],
    #             'validation_enabled': True,
    #             'hot_reload_supported': True,
    #             'profile_support': True,
    #             'encryption_support': True
    #         }