# Converted from Python to NoodleCore
# Original file: src

# """
# Configuration Validator Module

# This module implements comprehensive configuration validation system.
# """

import re
import os
import logging
import asyncio
import typing.Dict
import pathlib.Path
from dataclasses import dataclass
import datetime.datetime
import enum.Enum
import urllib.parse.urlparse


class ValidationSeverity(Enum)
    #     """Validation severity levels."""
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"
    CRITICAL = "critical"


class ValidationCategory(Enum)
    #     """Validation categories."""
    SCHEMA = "schema"
    SECURITY = "security"
    PERFORMANCE = "performance"
    DEPENDENCY = "dependency"
    COMPLIANCE = "compliance"
    BUSINESS_LOGIC = "business_logic"


dataclass
class ValidationRule
    #     """Validation rule definition."""
    #     name: str
    #     description: str
    #     category: ValidationCategory
    #     severity: ValidationSeverity
    #     validator: Callable[[Any], bool]
    #     message_template: str
    fix_suggestion: Optional[str] = None
    enabled: bool = True


dataclass
class ValidationResult
    #     """Validation result."""
    #     rule_name: str
    #     category: ValidationCategory
    #     severity: ValidationSeverity
    #     message: str
    #     path: str
    #     value: Any
    fix_suggestion: Optional[str] = None
    timestamp: datetime = field(default_factory=datetime.now)


class ConfigValidatorError(Exception)
    #     """Configuration validator error with 4-digit error code."""

    #     def __init__(self, message: str, error_code: int = 4201):
    self.error_code = error_code
            super().__init__(message)


class ConfigValidator
    #     """Comprehensive configuration validator."""

    #     def __init__(self):""Initialize the configuration validator."""
    self.name = "ConfigValidator"
    self.logger = logging.getLogger(__name__)
    self._rules: List[ValidationRule] = []
    self._custom_validators: Dict[str, Callable] = {}

    #         # Initialize built-in validation rules
            self._initialize_builtin_rules()

    #     def _initialize_builtin_rules(self):
    #         """Initialize built-in validation rules."""

    #         # Schema validation rules
            self.add_rule(ValidationRule(
    name = "required_sections",
    description = "Validate required configuration sections",
    category = ValidationCategory.SCHEMA,
    severity = ValidationSeverity.ERROR,
    validator = self._validate_required_sections,
    message_template = "Missing required section: {section}",
    fix_suggestion = "Add the missing section to your configuration"
    #         ))

            self.add_rule(ValidationRule(
    name = "ai_model_config",
    description = "Validate AI model configuration",
    category = ValidationCategory.SCHEMA,
    severity = ValidationSeverity.ERROR,
    validator = self._validate_ai_model_config,
    message_template = "Invalid AI model configuration: {error}",
    fix_suggestion = "Check AI model configuration requirements"
    #         ))

            self.add_rule(ValidationRule(
    name = "sandbox_limits",
    description = "Validate sandbox resource limits",
    category = ValidationCategory.SCHEMA,
    severity = ValidationSeverity.ERROR,
    validator = self._validate_sandbox_limits,
    message_template = "Invalid sandbox limit: {limit}",
    fix_suggestion = "Ensure sandbox limits are properly formatted"
    #         ))

    #         # Security validation rules
            self.add_rule(ValidationRule(
    name = "api_key_format",
    description = "Validate API key formats",
    category = ValidationCategory.SECURITY,
    severity = ValidationSeverity.ERROR,
    validator = self._validate_api_keys,
    #             message_template="Invalid API key format for {provider}: {error}",
    fix_suggestion = "Use proper API key format or environment variable reference"
    #         ))

            self.add_rule(ValidationRule(
    name = "sensitive_data_encryption",
    #             description="Check if sensitive data is encrypted",
    category = ValidationCategory.SECURITY,
    severity = ValidationSeverity.WARNING,
    validator = self._validate_sensitive_data_encryption,
    message_template = "Sensitive data not encrypted: {path}",
    #             fix_suggestion="Enable encryption for sensitive configuration data"
    #         ))

            self.add_rule(ValidationRule(
    name = "insecure_urls",
    #             description="Check for insecure URLs",
    category = ValidationCategory.SECURITY,
    severity = ValidationSeverity.WARNING,
    validator = self._validate_url_security,
    message_template = "Insecure URL detected: {url}",
    fix_suggestion = "Use HTTPS URLs instead of HTTP"
    #         ))

    #         # Performance validation rules
            self.add_rule(ValidationRule(
    name = "timeout_values",
    description = "Validate timeout configurations",
    category = ValidationCategory.PERFORMANCE,
    severity = ValidationSeverity.WARNING,
    validator = self._validate_timeouts,
    message_template = "Invalid timeout value: {timeout}",
    fix_suggestion = "Set reasonable timeout values (1-300 seconds)"
    #         ))

            self.add_rule(ValidationRule(
    name = "memory_limits",
    description = "Validate memory limit configurations",
    category = ValidationCategory.PERFORMANCE,
    severity = ValidationSeverity.WARNING,
    validator = self._validate_memory_limits,
    message_template = "Invalid memory limit: {limit}",
    fix_suggestion = "Use proper memory limit format (e.g., 2GB, 512MB)"
    #         ))

            self.add_rule(ValidationRule(
    name = "port_ranges",
    description = "Validate port number ranges",
    category = ValidationCategory.PERFORMANCE,
    severity = ValidationSeverity.ERROR,
    validator = self._validate_port_ranges,
    message_template = "Invalid port number: {port}",
    fix_suggestion = "Use port numbers between 1024 and 65535"
    #         ))

    #         # Dependency validation rules
            self.add_rule(ValidationRule(
    name = "model_dependencies",
    description = "Validate model dependencies",
    category = ValidationCategory.DEPENDENCY,
    severity = ValidationSeverity.ERROR,
    validator = self._validate_model_dependencies,
    message_template = "Missing model dependency: {dependency}",
    fix_suggestion = "Ensure all required models are configured"
    #         ))

    #         # Compliance validation rules
            self.add_rule(ValidationRule(
    name = "noodle_prefix_enforcement",
    #             description="Enforce NOODLE_ prefix for environment variables",
    category = ValidationCategory.COMPLIANCE,
    severity = ValidationSeverity.ERROR,
    validator = self._validate_noodle_prefix,
    message_template = "Environment variable missing NOODLE_ prefix: {var}",
    fix_suggestion = "Add NOODLE_ prefix to environment variable"
    #         ))

    #         # Business logic validation rules
            self.add_rule(ValidationRule(
    name = "default_model_exists",
    description = "Ensure default AI model exists",
    category = ValidationCategory.BUSINESS_LOGIC,
    severity = ValidationSeverity.ERROR,
    validator = self._validate_default_model_exists,
    message_template = "Default AI model not found: {model}",
    fix_suggestion = "Configure the default AI model or change default_model setting"
    #         ))

            self.add_rule(ValidationRule(
    name = "log_level_valid",
    description = "Validate log level settings",
    category = ValidationCategory.BUSINESS_LOGIC,
    severity = ValidationSeverity.WARNING,
    validator = self._validate_log_levels,
    message_template = "Invalid log level: {level}",
    fix_suggestion = "Use valid log levels: DEBUG, INFO, WARNING, ERROR"
    #         ))

    #     def add_rule(self, rule: ValidationRule):
    #         """
    #         Add a validation rule.

    #         Args:
    #             rule: Validation rule to add
    #         """
            self._rules.append(rule)
            self.logger.debug(f"Added validation rule: {rule.name}")

    #     def remove_rule(self, rule_name: str) -bool):
    #         """
    #         Remove a validation rule.

    #         Args:
    #             rule_name: Name of rule to remove

    #         Returns:
    #             True if rule was removed, False if not found
    #         """
    #         for i, rule in enumerate(self._rules):
    #             if rule.name == rule_name:
    #                 del self._rules[i]
                    self.logger.debug(f"Removed validation rule: {rule_name}")
    #                 return True
    #         return False

    #     def enable_rule(self, rule_name: str) -bool):
    #         """
    #         Enable a validation rule.

    #         Args:
    #             rule_name: Name of rule to enable

    #         Returns:
    #             True if rule was enabled, False if not found
    #         """
    #         for rule in self._rules:
    #             if rule.name == rule_name:
    rule.enabled = True
    #                 return True
    #         return False

    #     def disable_rule(self, rule_name: str) -bool):
    #         """
    #         Disable a validation rule.

    #         Args:
    #             rule_name: Name of rule to disable

    #         Returns:
    #             True if rule was disabled, False if not found
    #         """
    #         for rule in self._rules:
    #             if rule.name == rule_name:
    rule.enabled = False
    #                 return True
    #         return False

    #     def add_custom_validator(self, name: str, validator: Callable[[Dict[str, Any]], List[ValidationResult]]):
    #         """
    #         Add a custom validator function.

    #         Args:
    #             name: Validator name
    #             validator: Validator function
    #         """
    self._custom_validators[name] = validator
            self.logger.debug(f"Added custom validator: {name}")

    #     async def validate(self, config: Dict[str, Any], categories: Optional[List[ValidationCategory]] = None) -Dict[str, Any]):
    #         """
    #         Validate configuration against all rules.

    #         Args:
    #             config: Configuration to validate
                categories: Categories to validate (default: all)

    #         Returns:
    #             Validation results
    #         """
    results = []
    start_time = datetime.now()

    #         try:
    #             # Run built-in validation rules
    #             for rule in self._rules:
    #                 if not rule.enabled:
    #                     continue

    #                 if categories and rule.category not in categories:
    #                     continue

    #                 try:
    #                     if asyncio.iscoroutinefunction(rule.validator):
    is_valid = await rule.validator(config)
    #                     else:
    is_valid = rule.validator(config)

    #                     if not is_valid:
    result = ValidationResult(
    rule_name = rule.name,
    category = rule.category,
    severity = rule.severity,
    message = rule.message_template,
    path = "root",
    value = config,
    fix_suggestion = rule.fix_suggestion
    #                         )
                            results.append(result)

    #                 except Exception as e:
                        self.logger.error(f"Validation rule '{rule.name}' failed: {str(e)}")
    result = ValidationResult(
    rule_name = rule.name,
    category = rule.category,
    severity = ValidationSeverity.ERROR,
    message = f"Validation rule failed: {str(e)}",
    path = "root",
    value = config,
    fix_suggestion = "Check validation rule implementation"
    #                     )
                        results.append(result)

    #             # Run custom validators
    #             for validator_name, validator in self._custom_validators.items():
    #                 try:
    #                     if asyncio.iscoroutinefunction(validator):
    custom_results = await validator(config)
    #                     else:
    custom_results = validator(config)

                        results.extend(custom_results)

    #                 except Exception as e:
                        self.logger.error(f"Custom validator '{validator_name}' failed: {str(e)}")
    result = ValidationResult(
    rule_name = validator_name,
    category = ValidationCategory.ERROR,
    severity = ValidationSeverity.ERROR,
    message = f"Custom validator failed: {str(e)}",
    path = "root",
    value = config
    #                     )
                        results.append(result)

    #             # Calculate summary
    end_time = datetime.now()
    duration = (end_time - start_time.total_seconds())

    #             error_count = len([r for r in results if r.severity in [ValidationSeverity.ERROR, ValidationSeverity.CRITICAL]])
    #             warning_count = len([r for r in results if r.severity == ValidationSeverity.WARNING])
    #             info_count = len([r for r in results if r.severity == ValidationSeverity.INFO])

    #             return {
    'valid': error_count = 0,
    #                 'results': [self._serialize_result(r) for r in results],
    #                 'summary': {
                        'total': len(results),
    #                     'errors': error_count,
    #                     'warnings': warning_count,
    #                     'info': info_count
    #                 },
    #                 'duration_seconds': duration,
                    'timestamp': end_time.isoformat()
    #             }

    #         except Exception as e:
                self.logger.error(f"Configuration validation failed: {str(e)}")
                raise ConfigValidatorError(f"Validation failed: {str(e)}", 4202)

    #     def _serialize_result(self, result: ValidationResult) -Dict[str, Any]):
    #         """Serialize validation result to dictionary."""
    #         return {
    #             'rule_name': result.rule_name,
    #             'category': result.category.value,
    #             'severity': result.severity.value,
    #             'message': result.message,
    #             'path': result.path,
    #             'value': result.value,
    #             'fix_suggestion': result.fix_suggestion,
                'timestamp': result.timestamp.isoformat()
    #         }

    #     # Built-in validation methods
    #     def _validate_required_sections(self, config: Dict[str, Any]) -bool):
    #         """Validate required configuration sections."""
    required_sections = ['ai', 'sandbox', 'validation', 'logging', 'ide']
    #         missing_sections = [section for section in required_sections if section not in config]

    #         if missing_sections:
    #             # Store missing sections for error message
    self._last_validation_context = {'section': missing_sections[0]}
    #             return False

    #         return True

    #     def _validate_ai_model_config(self, config: Dict[str, Any]) -bool):
    #         """Validate AI model configuration."""
    #         if 'ai' not in config:
    #             return True

    ai_config = config['ai']

    #         # Check default model exists
    #         if 'default_model' in ai_config and 'models' in ai_config:
    default_model = ai_config['default_model']
    #             if default_model not in ai_config['models']:
    self._last_validation_context = {'error': f'Default model "{default_model}" not found'}
    #                 return False

    #         # Validate each model
    #         if 'models' in ai_config:
    #             for model_name, model_config in ai_config['models'].items():
    #                 if not isinstance(model_config, dict):
    self._last_validation_context = {'error': f'Model "{model_name}" must be a dictionary'}
    #                     return False

    #                 # Required fields
    required_fields = ['provider', 'api_base', 'api_key', 'model_name', 'system_prompt']
    #                 missing_fields = [field for field in required_fields if field not in model_config]

    #                 if missing_fields:
    self._last_validation_context = {'error': f'Model "{model_name}" missing fields: {missing_fields}'}
    #                     return False

    #         return True

    #     def _validate_sandbox_limits(self, config: Dict[str, Any]) -bool):
    #         """Validate sandbox resource limits."""
    #         if 'sandbox' not in config:
    #             return True

    sandbox_config = config['sandbox']

    #         # Validate memory limit format
    #         if 'memory_limit' in sandbox_config:
    memory_limit = sandbox_config['memory_limit']
    #             if not isinstance(memory_limit, str) or not re.match(r'^\d+[KMG]B$', memory_limit):
    self._last_validation_context = {'limit': f'memory_limit: {memory_limit}'}
    #                 return False

    #         # Validate CPU limit format
    #         if 'cpu_limit' in sandbox_config:
    cpu_limit = sandbox_config['cpu_limit']
    #             if not isinstance(cpu_limit, str) or not cpu_limit.endswith('%'):
    self._last_validation_context = {'limit': f'cpu_limit: {cpu_limit}'}
    #                 return False

    #         return True

    #     def _validate_api_keys(self, config: Dict[str, Any]) -bool):
    #         """Validate API key formats."""
    #         if 'ai' not in config or 'models' not in config['ai']:
    #             return True

    #         for model_name, model_config in config['ai']['models'].items():
    #             if 'api_key' in model_config:
    api_key = model_config['api_key']

    #                 # Check if it's an environment variable reference
    #                 if api_key.startswith('env:'):
    env_var = api_key[4:]
    #                     if not env_var.startswith('NOODLE_'):
    self._last_validation_context = {
    #                             'provider': model_name,
    #                             'error': f'Environment variable {env_var} must start with NOODLE_'
    #                         }
    #                         return False
    #                 else:
    #                     # Check if it looks like a valid API key
    #                     if len(api_key) < 10:
    self._last_validation_context = {
    #                             'provider': model_name,
    #                             'error': 'API key too short'
    #                         }
    #                         return False

    #         return True

    #     def _validate_sensitive_data_encryption(self, config: Dict[str, Any]) -bool):
    #         """Check if sensitive data is encrypted."""
    sensitive_patterns = [
                ('password', r'password'),
                ('api_key', r'api[_-]?key'),
                ('secret', r'secret'),
                ('token', r'token')
    #         ]

    #         def check_sensitive(obj, path=""):
    #             for key, value in obj.items() if isinstance(obj, dict) else []:
    #                 current_path = f"{path}.{key}" if path else key

    #                 for pattern_name, pattern in sensitive_patterns:
    #                     if re.search(pattern, key, re.IGNORECASE):
    #                         if isinstance(value, str) and not value.startswith('env:') and len(value) 5):
    #                             if not value.startswith('***'):
    self._last_validation_context = {'path': current_path}
    #                                 return False

    #                 if isinstance(value, dict):
    #                     if not check_sensitive(value, current_path):
    #                         return False

    #             return True

            return check_sensitive(config)

    #     def _validate_url_security(self, config: Dict[str, Any]) -bool):
    #         """Check for insecure URLs."""
    #         def check_urls(obj, path=""):
    #             for key, value in obj.items() if isinstance(obj, dict) else []:
    #                 current_path = f"{path}.{key}" if path else key

    #                 if isinstance(value, str) and (key.endswith('_url') or key.endswith('api_base')):
    #                     try:
    parsed = urlparse(value)
    #                         if parsed.scheme == 'http':
    self._last_validation_context = {'url': value}
    #                             return False
    #                     except Exception:
    #                         pass

    #                 if isinstance(value, dict):
    #                     if not check_urls(value, current_path):
    #                         return False

    #             return True

            return check_urls(config)

    #     def _validate_timeouts(self, config: Dict[str, Any]) -bool):
    #         """Validate timeout configurations."""
    timeout_keys = ['timeout', 'execution_timeout', 'request_timeout', 'connection_timeout']

    #         def check_timeouts(obj, path=""):
    #             for key, value in obj.items() if isinstance(obj, dict) else []:
    #                 current_path = f"{path}.{key}" if path else key

    #                 if any(timeout_key in key.lower() for timeout_key in timeout_keys):
    #                     if isinstance(value, (int, float)):
    #                         if value <= 0 or value 300):  # 5 minutes max
    self._last_validation_context = {'timeout': f'{current_path}: {value}'}
    #                             return False

    #                 if isinstance(value, dict):
    #                     if not check_timeouts(value, current_path):
    #                         return False

    #             return True

            return check_timeouts(config)

    #     def _validate_memory_limits(self, config: Dict[str, Any]) -bool):
    #         """Validate memory limit configurations."""
    memory_keys = ['memory_limit', 'max_memory']

    #         def check_memory_limits(obj, path=""):
    #             for key, value in obj.items() if isinstance(obj, dict) else []:
    #                 current_path = f"{path}.{key}" if path else key

    #                 if any(memory_key in key.lower() for memory_key in memory_keys):
    #                     if isinstance(value, str):
    #                         if not re.match(r'^\d+[KMG]B$', value):
    self._last_validation_context = {'limit': f'{current_path}: {value}'}
    #                             return False

    #                 if isinstance(value, dict):
    #                     if not check_memory_limits(value, current_path):
    #                         return False

    #             return True

            return check_memory_limits(config)

    #     def _validate_port_ranges(self, config: Dict[str, Any]) -bool):
    #         """Validate port number ranges."""
    port_keys = ['port', 'lsp_port', 'metrics_port']

    #         def check_ports(obj, path=""):
    #             for key, value in obj.items() if isinstance(obj, dict) else []:
    #                 current_path = f"{path}.{key}" if path else key

    #                 if any(port_key in key.lower() for port_key in port_keys):
    #                     if isinstance(value, int):
    #                         if not (1024 <= value <= 65535):
    self._last_validation_context = {'port': f'{current_path}: {value}'}
    #                             return False

    #                 if isinstance(value, dict):
    #                     if not check_ports(value, current_path):
    #                         return False

    #             return True

            return check_ports(config)

    #     def _validate_model_dependencies(self, config: Dict[str, Any]) -bool):
    #         """Validate model dependencies."""
    #         if 'ai' not in config or 'models' not in config['ai']:
    #             return True

    #         # Check if all referenced models exist
    ai_config = config['ai']
    models = ai_config.get('models', {})

    #         # Check default model
    #         if 'default_model' in ai_config:
    default_model = ai_config['default_model']
    #             if default_model not in models:
    self._last_validation_context = {'dependency': f'default_model: {default_model}'}
    #                 return False

    #         # Check fallback model
    #         if 'fallback_model' in ai_config and ai_config['fallback_model']:
    fallback_model = ai_config['fallback_model']
    #             if fallback_model not in models:
    self._last_validation_context = {'dependency': f'fallback_model: {fallback_model}'}
    #                 return False

    #         return True

    #     def _validate_noodle_prefix(self, config: Dict[str, Any]) -bool):
    #         """Enforce NOODLE_ prefix for environment variables."""
    #         # This would typically check environment variables, but for config validation
    #         # we check for environment variable references in the config
    #         def check_env_refs(obj, path=""):
    #             for key, value in obj.items() if isinstance(obj, dict) else []:
    #                 current_path = f"{path}.{key}" if path else key

    #                 if isinstance(value, str) and value.startswith('env:'):
    env_var = value[4:]
    #                     if not env_var.startswith('NOODLE_'):
    self._last_validation_context = {'var': env_var}
    #                         return False

    #                 if isinstance(value, dict):
    #                     if not check_env_refs(value, current_path):
    #                         return False

    #             return True

            return check_env_refs(config)

    #     def _validate_default_model_exists(self, config: Dict[str, Any]) -bool):
    #         """Ensure default AI model exists."""
    #         if 'ai' not in config:
    #             return True

    ai_config = config['ai']

    #         if 'default_model' in ai_config and 'models' in ai_config:
    default_model = ai_config['default_model']
    #             if default_model not in ai_config['models']:
    self._last_validation_context = {'model': default_model}
    #                 return False

    #         return True

    #     def _validate_log_levels(self, config: Dict[str, Any]) -bool):
    #         """Validate log level settings."""
    valid_levels = ['DEBUG', 'INFO', 'WARNING', 'ERROR']

    #         def check_log_levels(obj, path=""):
    #             for key, value in obj.items() if isinstance(obj, dict) else []:
    #                 current_path = f"{path}.{key}" if path else key

    #                 if 'level' in key.lower() and isinstance(value, str):
    #                     if value.upper() not in valid_levels:
    self._last_validation_context = {'level': f'{current_path}: {value}'}
    #                         return False

    #                 if isinstance(value, dict):
    #                     if not check_log_levels(value, current_path):
    #                         return False

    #             return True

            return check_log_levels(config)

    #     async def get_validator_info(self) -Dict[str, Any]):
    #         """
    #         Get information about the configuration validator.

    #         Returns:
    #             Validator information
    #         """
    #         return {
    #             'name': self.name,
    #             'version': '1.0.0',
                'total_rules': len(self._rules),
    #             'enabled_rules': len([r for r in self._rules if r.enabled]),
                'custom_validators': len(self._custom_validators),
    #             'categories': [cat.value for cat in ValidationCategory],
    #             'severities': [sev.value for sev in ValidationSeverity],
    #             'features': [
    #                 'schema_validation',
    #                 'security_validation',
    #                 'performance_validation',
    #                 'dependency_validation',
    #                 'compliance_validation',
    #                 'business_logic_validation',
    #                 'custom_validators',
    #                 'rule_management'
    #             ]
    #         }