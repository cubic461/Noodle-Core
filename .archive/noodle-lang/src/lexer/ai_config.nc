# Converted from Python to NoodleCore
# Original file: src

# """
# AI Configuration Management Module

# This module provides configuration management for AI providers, including:
# - Loading provider configurations from MessagePack/JSON files
# - Model-specific settings and prompts
# - Configuration validation and defaults
# - Secure storage for API keys
# """

import json
import os
import logging
import typing.Dict
from dataclasses import dataclass
import pathlib.Path
import hashlib
import base64
import cryptography.fernet.Fernet
import cryptography.hazmat.primitives.hashes
import cryptography.hazmat.primitives.kdf.pbkdf2.PBKDF2HMAC


dataclass
class ProviderConfig
    #     """Configuration for an AI provider."""
    #     name: str
    #     base_url: str
    #     api_key_env: str
    #     default_model: str
    #     max_tokens: int
    #     requests_per_minute: int
    #     tokens_per_minute: int
    #     timeout: int
    #     supports_streaming: bool
    #     supports_function_calling: bool
    #     input_cost_per_1k: float
    #     output_cost_per_1k: float
    #     additional_headers: Dict[str, str]
    #     model_specific_config: Dict[str, Dict[str, Any]]


dataclass
class ModelConfig
    #     """Configuration for a specific model."""
    #     name: str
    #     provider: str
    #     max_tokens: int
    #     supports_streaming: bool
    #     supports_function_calling: bool
    #     input_cost_per_1k: float
    #     output_cost_per_1k: float
    system_prompt: Optional[str] = None
    temperature_default: float = 0.7
    max_tokens_default: int = 1000
    top_p_default: float = 1.0
    frequency_penalty_default: float = 0.0
    presence_penalty_default: float = 0.0


dataclass
class NoodleCoreConfig
    #     """NoodleCore-specific AI configuration."""
    #     system_prompt: str
    #     code_validation_prompt: str
    #     code_generation_prompt: str
    #     syntax_rules: Dict[str, str]
    #     naming_conventions: Dict[str, str]
    #     architectural_patterns: List[str]
    #     security_guidelines: List[str]
    #     performance_constraints: Dict[str, Any]


class ConfigEncryption
    #     """Handles encryption/decryption of sensitive configuration data."""

    #     def __init__(self, password: str):""Initialize encryption with a password."""
    self.password = password.encode()
    self.salt = b'noodlecore_ai_config_salt'  # In production, use a random salt
    self.key = self._derive_key()
    self.cipher = Fernet(self.key)

    #     def _derive_key(self) -bytes):
    #         """Derive encryption key from password."""
    kdf = PBKDF2HMAC(
    algorithm = hashes.SHA256(),
    length = 32,
    salt = self.salt,
    iterations = 100000,
    #         )
    key = base64.urlsafe_b64encode(kdf.derive(self.password))
    #         return key

    #     def encrypt(self, data: str) -str):
    #         """Encrypt sensitive data."""
    encrypted_data = self.cipher.encrypt(data.encode())
            return base64.urlsafe_b64encode(encrypted_data).decode()

    #     def decrypt(self, encrypted_data: str) -str):
    #         """Decrypt sensitive data."""
    encrypted_bytes = base64.urlsafe_b64decode(encrypted_data.encode())
    decrypted_data = self.cipher.decrypt(encrypted_bytes)
            return decrypted_data.decode()


class AIConfigManager
    #     """Manages AI provider configurations with security and validation."""

    #     def __init__(self, config_dir: Optional[str] = None, encryption_password: Optional[str] = None):""
    #         Initialize the configuration manager.

    #         Args:
    #             config_dir: Directory containing configuration files
    #             encryption_password: Password for encrypting sensitive data
    #         """
    self.config_dir = Path(config_dir or os.path.expanduser("~/.noodlecore/ai_config"))
    self.config_dir.mkdir(parents = True, exist_ok=True)

    self.logger = logging.getLogger("noodlecore.ai_config")

    #         # Initialize encryption if password provided
    #         self.encryption = ConfigEncryption(encryption_password) if encryption_password else None

    #         # Configuration file paths
    self.providers_file = self.config_dir / "providers.json"
    self.models_file = self.config_dir / "models.json"
    self.noodlecore_file = self.config_dir / "noodlecore.json"
    self.secrets_file = self.config_dir / "secrets.enc"

    #         # Load configurations
    self.providers: Dict[str, ProviderConfig] = {}
    self.models: Dict[str, ModelConfig] = {}
    self.noodlecore_config: Optional[NoodleCoreConfig] = None
    self.secrets: Dict[str, str] = {}

            self._load_configurations()

    #     def _load_configurations(self):
    #         """Load all configuration files."""
    #         try:
                self._load_providers()
                self._load_models()
                self._load_noodlecore_config()
                self._load_secrets()
                self.logger.info("AI configurations loaded successfully")
    #         except Exception as e:
                self.logger.error(f"Failed to load configurations: {str(e)}")
                self._load_default_configurations()

    #     def _load_providers(self):
    #         """Load provider configurations."""
    #         if self.providers_file.exists():
    #             with open(self.providers_file, 'r', encoding='utf-8') as f:
    data = json.load(f)
    #                 for name, config_data in data.items():
    self.providers[name] = ProviderConfig( * *config_data)
    #         else:
                self._create_default_providers()

    #     def _load_models(self):
    #         """Load model configurations."""
    #         if self.models_file.exists():
    #             with open(self.models_file, 'r', encoding='utf-8') as f:
    data = json.load(f)
    #                 for name, config_data in data.items():
    self.models[name] = ModelConfig( * *config_data)
    #         else:
                self._create_default_models()

    #     def _load_noodlecore_config(self):
    #         """Load NoodleCore-specific configuration."""
    #         if self.noodlecore_file.exists():
    #             with open(self.noodlecore_file, 'r', encoding='utf-8') as f:
    data = json.load(f)
    self.noodlecore_config = NoodleCoreConfig( * *data)
    #         else:
                self._create_default_noodlecore_config()

    #     def _load_secrets(self):
    #         """Load encrypted secrets."""
    #         if self.secrets_file.exists() and self.encryption:
    #             with open(self.secrets_file, 'rb') as f:
    encrypted_data = f.read().decode()
    decrypted_data = self.encryption.decrypt(encrypted_data)
    self.secrets = json.loads(decrypted_data)
    #         else:
    #             # Load from environment variables as fallback
                self._load_secrets_from_env()

    #     def _load_secrets_from_env(self):
    #         """Load secrets from environment variables."""
    env_secrets = {
                'ZAI_API_KEY': os.getenv('ZAI_API_KEY', ''),
                'OPENROUTER_API_KEY': os.getenv('OPENROUTER_API_KEY', ''),
                'ANTHROPIC_API_KEY': os.getenv('ANTHROPIC_API_KEY', ''),
                'OPENAI_API_KEY': os.getenv('OPENAI_API_KEY', ''),
                'OLLAMA_API_KEY': os.getenv('OLLAMA_API_KEY', ''),
    #         }
    #         self.secrets = {k: v for k, v in env_secrets.items() if v}

    #     def _create_default_providers(self):
    #         """Create default provider configurations."""
    default_providers = {
                "zai": ProviderConfig(
    name = "zai",
    base_url = "https://open.bigmodel.cn/api/paas/v4",
    api_key_env = "ZAI_API_KEY",
    default_model = "glm-4.6",
    max_tokens = 8192,
    requests_per_minute = 60,
    tokens_per_minute = 100000,
    timeout = 30,
    supports_streaming = True,
    supports_function_calling = True,
    input_cost_per_1k = 0.001,
    output_cost_per_1k = 0.002,
    additional_headers = {},
    model_specific_config = {}
    #             ),
                "openrouter": ProviderConfig(
    name = "openrouter",
    base_url = "https://openrouter.ai/api/v1",
    api_key_env = "OPENROUTER_API_KEY",
    default_model = "meta-llama/llama-3.1-70b-instruct",
    max_tokens = 4096,
    requests_per_minute = 100,
    tokens_per_minute = 200000,
    timeout = 30,
    supports_streaming = True,
    supports_function_calling = True,
    input_cost_per_1k = 0.0005,
    output_cost_per_1k = 0.0015,
    additional_headers = {
    #                     "HTTP-Referer": "https://noodlecore.ai",
    #                     "X-Title": "NoodleCore CLI"
    #                 },
    model_specific_config = {}
    #             ),
                "anthropic": ProviderConfig(
    name = "anthropic",
    base_url = "https://api.anthropic.com/v1",
    api_key_env = "ANTHROPIC_API_KEY",
    default_model = "claude-3-5-sonnet-20241022",
    max_tokens = 4096,
    requests_per_minute = 50,
    tokens_per_minute = 100000,
    timeout = 30,
    supports_streaming = True,
    supports_function_calling = True,
    input_cost_per_1k = 0.003,
    output_cost_per_1k = 0.015,
    additional_headers = {"anthropic-version": "2023-06-01"},
    model_specific_config = {}
    #             ),
                "openai": ProviderConfig(
    name = "openai",
    base_url = "https://api.openai.com/v1",
    api_key_env = "OPENAI_API_KEY",
    default_model = "gpt-4",
    max_tokens = 4096,
    requests_per_minute = 60,
    tokens_per_minute = 150000,
    timeout = 30,
    supports_streaming = True,
    supports_function_calling = True,
    input_cost_per_1k = 0.03,
    output_cost_per_1k = 0.06,
    additional_headers = {},
    model_specific_config = {}
    #             ),
                "ollama": ProviderConfig(
    name = "ollama",
    base_url = "http://localhost:11434",
    api_key_env = "OLLAMA_API_KEY",
    default_model = "llama2",
    max_tokens = 4096,
    requests_per_minute = 1000,
    tokens_per_minute = 1000000,
    timeout = 60,
    supports_streaming = True,
    supports_function_calling = False,
    input_cost_per_1k = 0.0,
    output_cost_per_1k = 0.0,
    additional_headers = {},
    model_specific_config = {}
    #             )
    #         }
    self.providers = default_providers
            self._save_providers()

    #     def _create_default_models(self):
    #         """Create default model configurations."""
    default_models = {
                "glm-4.6": ModelConfig(
    name = "glm-4.6",
    provider = "zai",
    max_tokens = 8192,
    supports_streaming = True,
    supports_function_calling = True,
    input_cost_per_1k = 0.001,
    output_cost_per_1k = 0.002
    #             ),
                "llama-3.1-70b-instruct": ModelConfig(
    name = "meta-llama/llama-3.1-70b-instruct",
    provider = "openrouter",
    max_tokens = 4096,
    supports_streaming = True,
    supports_function_calling = True,
    input_cost_per_1k = 0.0005,
    output_cost_per_1k = 0.0015
    #             ),
                "claude-3-5-sonnet": ModelConfig(
    name = "claude-3-5-sonnet-20241022",
    provider = "anthropic",
    max_tokens = 4096,
    supports_streaming = True,
    supports_function_calling = True,
    input_cost_per_1k = 0.003,
    output_cost_per_1k = 0.015
    #             ),
                "gpt-4": ModelConfig(
    name = "gpt-4",
    provider = "openai",
    max_tokens = 4096,
    supports_streaming = True,
    supports_function_calling = True,
    input_cost_per_1k = 0.03,
    output_cost_per_1k = 0.06
    #             ),
                "llama2": ModelConfig(
    name = "llama2",
    provider = "ollama",
    max_tokens = 4096,
    supports_streaming = True,
    supports_function_calling = False,
    input_cost_per_1k = 0.0,
    output_cost_per_1k = 0.0
    #             )
    #         }
    self.models = default_models
            self._save_models()

    #     def _create_default_noodlecore_config(self):
    #         """Create default NoodleCore configuration."""
    self.noodlecore_config = NoodleCoreConfig(
    system_prompt = """You are NoodleCore AI Assistant, specialized in NoodleCore (.nc-code) development.

# Your role is to:
1. Generate and validate NoodleCore code following proper syntax (.nc-code)
# 2. Ensure all output adheres to NoodleCore standards and constraints
# 3. Provide clear explanations of NoodleCore concepts and implementations
# 4. Validate code for correctness, security, and performance
# 5. Follow NoodleCore naming conventions and architectural patterns

# Always format your code responses with proper .nc-code syntax and include relevant metadata.
# If you're unsure about NoodleCore-specific requirements, ask for clarification.""",

code_validation_prompt = """Please validate this NoodleCore (.nc-code) for:
# 1. Syntax correctness
# 2. Security vulnerabilities
# 3. Performance issues
# 4. Best practices compliance
# 5. Naming conventions
# 6. Architectural pattern adherence

# Provide specific feedback and suggestions for improvement.""",

code_generation_prompt = """Generate NoodleCore (.nc-code) that:
# 1. Follows proper syntax and structure
# 2. Implements the requested functionality
# 3. Adheres to security best practices
# 4. Uses appropriate naming conventions
# 5. Follows NoodleCore architectural patterns
# 6. Includes necessary error handling
# 7. Is optimized for performance

# Include comments and documentation as needed.""",

syntax_rules = {
#                 "file_extension": ".nc",
#                 "comment_syntax": "//",
#                 "block_comment": "/* */",
                "function_declaration": "function name() {}",
"variable_declaration": "let variable = value",
#                 "class_declaration": "class ClassName {}"
#             },

naming_conventions = {
#                 "variables": "snake_case",
#                 "functions": "snake_case",
#                 "classes": "PascalCase",
#                 "constants": "UPPER_SNAKE_CASE",
#                 "files": "snake_case.nc"
#             },

architectural_patterns = [
                "MVC (Model-View-Controller)",
#                 "Repository Pattern",
#                 "Service Layer",
#                 "Dependency Injection",
#                 "Event-Driven Architecture"
#             ],

security_guidelines = [
#                 "Input validation and sanitization",
#                 "SQL injection prevention",
#                 "XSS prevention",
#                 "Authentication and authorization",
#                 "Secure data storage",
#                 "Error handling without information leakage"
#             ],

performance_constraints = {
#                 "max_response_time_ms": 500,
#                 "max_memory_usage_mb": 2048,
#                 "max_concurrent_requests": 100,
#                 "database_query_timeout_s": 3,
#                 "api_timeout_s": 30
#             }
#         )
        self._save_noodlecore_config()

#     def _load_default_configurations(self):
#         """Load default configurations when files are missing or corrupted."""
        self._create_default_providers()
        self._create_default_models()
        self._create_default_noodlecore_config()
        self.logger.warning("Loaded default configurations due to missing or corrupted config files")

#     def _save_providers(self):
#         """Save provider configurations to file."""
#         providers_data = {name: asdict(config) for name, config in self.providers.items()}
#         with open(self.providers_file, 'w', encoding='utf-8') as f:
json.dump(providers_data, f, indent = 2, ensure_ascii=False)

#     def _save_models(self):
#         """Save model configurations to file."""
#         models_data = {name: asdict(config) for name, config in self.models.items()}
#         with open(self.models_file, 'w', encoding='utf-8') as f:
json.dump(models_data, f, indent = 2, ensure_ascii=False)

#     def _save_noodlecore_config(self):
#         """Save NoodleCore configuration to file."""
#         with open(self.noodlecore_file, 'w', encoding='utf-8') as f:
json.dump(asdict(self.noodlecore_config), f, indent = 2, ensure_ascii=False)

#     def save_secrets(self):
#         """Save encrypted secrets to file."""
#         if self.encryption:
secrets_json = json.dumps(self.secrets)
encrypted_data = self.encryption.encrypt(secrets_json)
#             with open(self.secrets_file, 'w', encoding='utf-8') as f:
                f.write(encrypted_data)

#     def get_provider_config(self, provider_name: str) -Optional[ProviderConfig]):
#         """Get configuration for a specific provider."""
        return self.providers.get(provider_name)

#     def get_model_config(self, model_name: str) -Optional[ModelConfig]):
#         """Get configuration for a specific model."""
        return self.models.get(model_name)

#     def get_api_key(self, provider_name: str) -Optional[str]):
#         """Get API key for a provider."""
provider_config = self.get_provider_config(provider_name)
#         if not provider_config:
#             return None

#         # Try to get from secrets first
env_var = provider_config.api_key_env
#         if env_var in self.secrets:
#             return self.secrets[env_var]

#         # Fallback to environment variable
        return os.getenv(env_var)

#     def set_api_key(self, provider_name: str, api_key: str):
#         """Set API key for a provider."""
provider_config = self.get_provider_config(provider_name)
#         if not provider_config:
            raise ValueError(f"Unknown provider: {provider_name}")

self.secrets[provider_config.api_key_env] = api_key
        self.save_secrets()

#     def validate_config(self) -List[str]):
#         """Validate all configurations and return list of issues."""
issues = []

#         # Validate providers
#         for name, config in self.providers.items():
#             if not config.base_url:
                issues.append(f"Provider {name}: missing base_url")
#             if not config.api_key_env:
                issues.append(f"Provider {name}: missing api_key_env")
#             if not self.get_api_key(name):
                issues.append(f"Provider {name}: no API key configured")

#         # Validate models
#         for name, config in self.models.items():
#             if config.provider not in self.providers:
                issues.append(f"Model {name}: unknown provider {config.provider}")
#             if config.max_tokens <= 0:
                issues.append(f"Model {name}: invalid max_tokens")

#         # Validate NoodleCore config
#         if self.noodlecore_config:
#             if not self.noodlecore_config.system_prompt:
                issues.append("NoodleCore config: missing system prompt")

#         return issues

#     def get_available_providers(self) -List[str]):
#         """Get list of available providers with API keys configured."""
available = []
#         for name in self.providers.keys():
#             if self.get_api_key(name):
                available.append(name)
#         return available

#     def get_provider_models(self, provider_name: str) -List[str]):
#         """Get list of models available for a provider."""
#         return [name for name, config in self.models.items() if config.provider == provider_name]

#     def update_provider_config(self, provider_name: str, updates: Dict[str, Any]):
#         """Update provider configuration."""
#         if provider_name not in self.providers:
            raise ValueError(f"Unknown provider: {provider_name}")

config = self.providers[provider_name]
#         for key, value in updates.items():
#             if hasattr(config, key):
                setattr(config, key, value)
#             else:
                raise ValueError(f"Unknown config key: {key}")

        self._save_providers()

#     def add_model_config(self, model_config: ModelConfig):
#         """Add a new model configuration."""
self.models[model_config.name] = model_config
        self._save_models()

#     def remove_model_config(self, model_name: str):
#         """Remove a model configuration."""
#         if model_name in self.models:
#             del self.models[model_name]
            self._save_models()