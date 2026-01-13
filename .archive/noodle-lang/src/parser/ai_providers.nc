# """
# AI Provider Integration for NoodleCore Desktop IDE
# 
# This module provides real AI provider integration to replace mock AI
# with actual providers like OpenRouter, Ollama, OpenAI, Z.ai, LM Studio.
# """

import typing
import dataclasses
import enum
import logging
import json
import time
import uuid
import aiohttp
import asyncio
from pathlib import Path
from urllib.parse import urljoin


class AIProviderType(enum.Enum):
    """AI provider types."""
    OPENROUTER = "openrouter"
    OLLAMA = "ollama"
    OPENAI = "openai"
    Z_AI = "z.ai"
    LM_STUDIO = "lm_studio"
    ANTHROPIC = "anthropic"
    CUSTOM = "custom"


class ModelCapability(enum.Enum):
    """AI model capabilities."""
    TEXT_GENERATION = "text_generation"
    CODE_COMPLETION = "code_completion"
    CODE_ANALYSIS = "code_analysis"
    ERROR_DETECTION = "error_detection"
    DOCUMENTATION = "documentation"
    REFACTORING = "refactoring"


@dataclasses.dataclass
class AIModel:
    """AI model information."""
    model_id: str
    name: str
    description: str
    provider: AIProviderType
    capabilities: typing.List[ModelCapability]
    context_length: int = 4096
    supports_streaming: bool = True
    rate_limit: typing.Optional[typing.Dict[str, int]] = None
    pricing: typing.Optional[typing.Dict[str, float]] = None


@dataclasses.dataclass
class AIProviderConfig:
    """AI provider configuration."""
    provider_type: AIProviderType
    api_key: str
    base_url: str
    models: typing.List[AIModel] = None
    default_model: str = None
    rate_limits: typing.Dict[str, int] = None
    timeout: float = 30.0
    max_retries: int = 3
    
    def __post_init__(self):
        if self.models is None:
            self.models = []
        if self.rate_limits is None:
            self.rate_limits = {}


@dataclasses.dataclass
class AIRequest:
    """AI request configuration."""
    request_id: str
    provider_type: AIProviderType
    model: str
    prompt: str
    max_tokens: int = 1000
    temperature: float = 0.7
    stream: bool = False
    context: typing.Dict[str, typing.Any] = None
    
    def __post_init__(self):
        if self.request_id is None:
            self.request_id = str(uuid.uuid4())
        if self.context is None:
            self.context = {}


@dataclasses.dataclass
class AIResponse:
    """AI response configuration."""
    request_id: str
    success: bool
    content: str = ""
    model: str = ""
    usage: typing.Dict[str, int] = None
    cost: typing.Optional[float] = None
    error: str = None
    timestamp: float = None
    
    def __post_init__(self):
        if self.usage is None:
            self.usage = {}
        if self.timestamp is None:
            self.timestamp = time.time()


class AIProviderError(Exception):
    """Base exception for AI provider operations."""
    pass


class AIProviderConfigError(AIProviderError):
    """Configuration error for AI providers."""
    pass


class AIProviderConnectionError(AIProviderError):
    """Connection error for AI providers."""
    pass


class AIProviderAPIError(AIProviderError):
    """API error for AI providers."""
    pass


class AIProviderManager:
    """
    AI Provider Manager for NoodleCore IDE.
    
    Manages multiple AI providers with configuration, model loading,
    and request handling.
    """
    
    def __init__(self):
        """Initialize AI Provider Manager."""
        self.logger = logging.getLogger(__name__)
        self._providers: typing.Dict[AIProviderType, AIProviderConfig] = {}
        self._available_models: typing.Dict[AIProviderType, typing.List[AIModel]] = {}
        self._current_provider: typing.Optional[AIProviderType] = None
        self._current_model: typing.Optional[str] = None
        self._session: typing.Optional[aiohttp.ClientSession] = None
        
        # Initialize default providers
        self._initialize_default_providers()
    
    def _initialize_default_providers(self):
        """Initialize default provider configurations."""
        try:
            # OpenRouter configuration
            openrouter_config = AIProviderConfig(
                provider_type=AIProviderType.OPENROUTER,
                api_key="",  # Will be set by user
                base_url="https://openrouter.ai/api/v1",
                timeout=30.0
            )
            self._providers[AIProviderType.OPENROUTER] = openrouter_config
            
            # Ollama configuration (local)
            ollama_config = AIProviderConfig(
                provider_type=AIProviderType.OLLAMA,
                api_key="",  # No API key needed for local Ollama
                base_url="http://localhost:11434",
                timeout=60.0
            )
            self._providers[AIProviderType.OLLAMA] = ollama_config
            
            # OpenAI configuration
            openai_config = AIProviderConfig(
                provider_type=AIProviderType.OPENAI,
                api_key="",  # Will be set by user
                base_url="https://api.openai.com/v1",
                timeout=30.0
            )
            self._providers[AIProviderType.OPENAI] = openai_config
            
            # Z.ai configuration
            zai_config = AIProviderConfig(
                provider_type=AIProviderType.Z_AI,
                api_key="",  # Will be set by user
                base_url="https://api.z.ai/v1",
                timeout=30.0
            )
            self._providers[AIProviderType.Z_AI] = zai_config
            
            # LM Studio configuration (local)
            lm_studio_config = AIProviderConfig(
                provider_type=AIProviderType.LM_STUDIO,
                api_key="",  # No API key needed for local LM Studio
                base_url="http://localhost:1234",
                timeout=60.0
            )
            self._providers[AIProviderType.LM_STUDIO] = lm_studio_config
            
            self.logger.info("Default providers initialized")
            
        except Exception as e:
            self.logger.error(f"Failed to initialize default providers: {e}")
    
    async def initialize(self):
        """Initialize AI Provider Manager with async session."""
        try:
            self._session = aiohttp.ClientSession()
            
            # Load provider configurations from file
            await self._load_provider_configs()
            
            self.logger.info("AI Provider Manager initialized")
            
        except Exception as e:
            self.logger.error(f"Failed to initialize AI Provider Manager: {e}")
            raise AIProviderError(f"Initialization failed: {e}")
    
    async def shutdown(self):
        """Shutdown AI Provider Manager."""
        try:
            if self._session:
                await self._session.close()
                self._session = None
            self.logger.info("AI Provider Manager shutdown")
            
        except Exception as e:
            self.logger.error(f"Error during shutdown: {e}")
    
    async def _load_provider_configs(self):
        """Load provider configurations from file."""
        try:
            config_path = Path.home() / ".noodlecore" / "ai_providers.json"
            if config_path.exists():
                with open(config_path, 'r') as f:
                    config_data = json.load(f)
                
                # Load saved configurations
                for provider_type_str, provider_data in config_data.get("providers", {}).items():
                    provider_type = AIProviderType(provider_type_str)
                    if provider_type in self._providers:
                        # Update API key and settings
                        self._providers[provider_type].api_key = provider_data.get("api_key", "")
                        self._providers[provider_type].base_url = provider_data.get("base_url", "")
                        self._providers[provider_type].default_model = provider_data.get("default_model", "")
                
                # Set current provider and model
                self._current_provider = AIProviderType(config_data.get("current_provider"))
                self._current_model = config_data.get("current_model")
                
                self.logger.info("Provider configurations loaded from file")
            
        except Exception as e:
            self.logger.warning(f"Failed to load provider configurations: {e}")
    
    async def _save_provider_configs(self):
        """Save provider configurations to file."""
        try:
            config_path = Path.home() / ".noodlecore"
            config_path.mkdir(exist_ok=True)
            
            config_data = {
                "providers": {
                    provider_type.value: {
                        "api_key": config.api_key,
                        "base_url": config.base_url,
                        "default_model": config.default_model
                    }
                    for provider_type, config in self._providers.items()
                },
                "current_provider": self._current_provider.value if self._current_provider else None,
                "current_model": self._current_model
            }
            
            with open(config_path / "ai_providers.json", 'w') as f:
                json.dump(config_data, f, indent=2)
            
            self.logger.info("Provider configurations saved to file")
            
        except Exception as e:
            self.logger.error(f"Failed to save provider configurations: {e}")
    
    def get_available_providers(self) -> typing.List[AIProviderType]:
        """Get list of available providers."""
        return list(self._providers.keys())
    
    def get_provider_models(self, provider_type: AIProviderType) -> typing.List[AIModel]:
        """Get available models for a provider."""
        try:
            if provider_type not in self._providers:
                return []
            
            provider_config = self._providers[provider_type]
            
            # Return cached models if available
            if provider_type in self._available_models:
                return self._available_models[provider_type]
            
            # Load default models for known providers
            models = self._load_default_models(provider_type)
            self._available_models[provider_type] = models
            
            return models
            
        except Exception as e:
            self.logger.error(f"Failed to get models for {provider_type}: {e}")
            return []
    
    def _load_default_models(self, provider_type: AIProviderType) -> typing.List[AIModel]:
        """Load default models for a provider."""
        models = []
        
        try:
            if provider_type == AIProviderType.OPENROUTER:
                models = [
                    AIModel("anthropic/claude-3-sonnet", "Claude 3 Sonnet", "Advanced reasoning and analysis", 
                           provider_type, [ModelCapability.TEXT_GENERATION, ModelCapability.CODE_COMPLETION]),
                    AIModel("openai/gpt-4", "GPT-4", "OpenAI's most capable model", 
                           provider_type, [ModelCapability.TEXT_GENERATION, ModelCapability.CODE_COMPLETION]),
                    AIModel("openai/gpt-3.5-turbo", "GPT-3.5 Turbo", "Fast and efficient model", 
                           provider_type, [ModelCapability.TEXT_GENERATION])
                ]
            
            elif provider_type == AIProviderType.OLLAMA:
                models = [
                    AIModel("codellama:7b", "Code Llama 7B", "Code generation and completion", 
                           provider_type, [ModelCapability.CODE_COMPLETION, ModelCapability.CODE_ANALYSIS]),
                    AIModel("llama2:7b", "Llama 2 7B", "General purpose language model", 
                           provider_type, [ModelCapability.TEXT_GENERATION]),
                    AIModel("mistral:7b", "Mistral 7B", "Fast and efficient model", 
                           provider_type, [ModelCapability.TEXT_GENERATION])
                ]
            
            elif provider_type == AIProviderType.OPENAI:
                models = [
                    AIModel("gpt-4", "GPT-4", "OpenAI's most capable model", 
                           provider_type, [ModelCapability.TEXT_GENERATION, ModelCapability.CODE_COMPLETION]),
                    AIModel("gpt-3.5-turbo", "GPT-3.5 Turbo", "Fast and efficient model", 
                           provider_type, [ModelCapability.TEXT_GENERATION])
                ]
            
            elif provider_type == AIProviderType.LM_STUDIO:
                models = [
                    AIModel("local-model", "Local Model", "Locally running model", 
                           provider_type, [ModelCapability.TEXT_GENERATION, ModelCapability.CODE_COMPLETION])
                ]
            
            # Set default model if not set
            if models and not self._providers[provider_type].default_model:
                self._providers[provider_type].default_model = models[0].model_id
            
        except Exception as e:
            self.logger.error(f"Failed to load default models for {provider_type}: {e}")
        
        return models
    
    def set_provider_config(self, provider_type: AIProviderType, api_key: str, 
                          base_url: str = None, default_model: str = None):
        """Set provider configuration."""
        try:
            if provider_type not in self._providers:
                raise AIProviderConfigError(f"Unknown provider type: {provider_type}")
            
            provider_config = self._providers[provider_type]
            provider_config.api_key = api_key
            
            if base_url:
                provider_config.base_url = base_url
            
            if default_model:
                provider_config.default_model = default_model
            
            # Save configurations
            asyncio.create_task(self._save_provider_configs())
            
            self.logger.info(f"Provider configuration updated for {provider_type}")
            
        except Exception as e:
            self.logger.error(f"Failed to set provider config for {provider_type}: {e}")
            raise AIProviderConfigError(f"Configuration update failed: {e}")
    
    def set_current_provider(self, provider_type: AIProviderType, model: str = None):
        """Set current provider and model."""
        try:
            if provider_type not in self._providers:
                raise AIProviderConfigError(f"Unknown provider type: {provider_type}")
            
            provider_config = self._providers[provider_type]
            
            # Validate API key
            if not provider_config.api_key and provider_type != AIProviderType.OLLAMA and provider_type != AIProviderType.LM_STUDIO:
                raise AIProviderConfigError(f"API key required for {provider_type}")
            
            self._current_provider = provider_type
            
            # Set model
            if model:
                self._current_model = model
            elif provider_config.default_model:
                self._current_model = provider_config.default_model
            else:
                models = self.get_provider_models(provider_type)
                if models:
                    self._current_model = models[0].model_id
            
            # Save configurations
            asyncio.create_task(self._save_provider_configs())
            
            self.logger.info(f"Current provider set to {provider_type} with model {self._current_model}")
            
        except Exception as e:
            self.logger.error(f"Failed to set current provider: {e}")
            raise AIProviderConfigError(f"Provider selection failed: {e}")
    
    def get_current_provider(self) -> typing.Tuple[typing.Optional[AIProviderType], typing.Optional[str]]:
        """Get current provider and model."""
        return self._current_provider, self._current_model
    
    async def send_request(self, request: AIRequest) -> AIResponse:
        """Send request to AI provider."""
        try:
            if not self._session:
                await self.initialize()
            
            # Route to appropriate provider
            if request.provider_type == AIProviderType.OPENROUTER:
                return await self._send_openrouter_request(request)
            elif request.provider_type == AIProviderType.OLLAMA:
                return await self._send_ollama_request(request)
            elif request.provider_type == AIProviderType.OPENAI:
                return await self._send_openai_request(request)
            elif request.provider_type == AIProviderType.Z_AI:
                return await self._send_zai_request(request)
            elif request.provider_type == AIProviderType.LM_STUDIO:
                return await self._send_lm_studio_request(request)
            else:
                raise AIProviderAPIError(f"Unsupported provider type: {request.provider_type}")
            
        except Exception as e:
            self.logger.error(f"Failed to send request: {e}")
            return AIResponse(
                request_id=request.request_id,
                success=False,
                error=str(e)
            )
    
    async def _send_openrouter_request(self, request: AIRequest) -> AIResponse:
        """Send request to OpenRouter."""
        try:
            provider_config = self._providers[AIProviderType.OPENROUTER]
            
            headers = {
                "Authorization": f"Bearer {provider_config.api_key}",
                "Content-Type": "application/json",
                "HTTP-Referer": "NoodleCore IDE",
                "X-Title": "NoodleCore Desktop IDE"
            }
            
            payload = {
                "model": request.model,
                "messages": [
                    {"role": "user", "content": request.prompt}
                ],
                "max_tokens": request.max_tokens,
                "temperature": request.temperature,
                "stream": request.stream
            }
            
            async with self._session.post(
                f"{provider_config.base_url}/chat/completions",
                headers=headers,
                json=payload,
                timeout=aiohttp.ClientTimeout(total=provider_config.timeout)
            ) as response:
                if response.status == 200:
                    data = await response.json()
                    content = data["choices"][0]["message"]["content"]
                    
                    return AIResponse(
                        request_id=request.request_id,
                        success=True,
                        content=content,
                        model=request.model,
                        usage=data.get("usage", {})
                    )
                else:
                    error_data = await response.text()
                    raise AIProviderAPIError(f"OpenRouter API error {response.status}: {error_data}")
        
        except Exception as e:
            return AIResponse(
                request_id=request.request_id,
                success=False,
                error=str(e)
            )
    
    async def _send_ollama_request(self, request: AIRequest) -> AIResponse:
        """Send request to Ollama."""
        try:
            provider_config = self._providers[AIProviderType.OLLAMA]
            
            payload = {
                "model": request.model,
                "prompt": request.prompt,
                "stream": request.stream
            }
            
            async with self._session.post(
                f"{provider_config.base_url}/api/generate",
                json=payload,
                timeout=aiohttp.ClientTimeout(total=provider_config.timeout)
            ) as response:
                if response.status == 200:
                    data = await response.json()
                    content = data.get("response", "")
                    
                    return AIResponse(
                        request_id=request.request_id,
                        success=True,
                        content=content,
                        model=request.model
                    )
                else:
                    error_data = await response.text()
                    raise AIProviderAPIError(f"Ollama API error {response.status}: {error_data}")
        
        except Exception as e:
            return AIResponse(
                request_id=request.request_id,
                success=False,
                error=str(e)
            )
    
    async def _send_openai_request(self, request: AIRequest) -> AIResponse:
        """Send request to OpenAI."""
        try:
            provider_config = self._providers[AIProviderType.OPENAI]
            
            headers = {
                "Authorization": f"Bearer {provider_config.api_key}",
                "Content-Type": "application/json"
            }
            
            payload = {
                "model": request.model,
                "messages": [
                    {"role": "user", "content": request.prompt}
                ],
                "max_tokens": request.max_tokens,
                "temperature": request.temperature,
                "stream": request.stream
            }
            
            async with self._session.post(
                f"{provider_config.base_url}/chat/completions",
                headers=headers,
                json=payload,
                timeout=aiohttp.ClientTimeout(total=provider_config.timeout)
            ) as response:
                if response.status == 200:
                    data = await response.json()
                    content = data["choices"][0]["message"]["content"]
                    
                    return AIResponse(
                        request_id=request.request_id,
                        success=True,
                        content=content,
                        model=request.model,
                        usage=data.get("usage", {})
                    )
                else:
                    error_data = await response.text()
                    raise AIProviderAPIError(f"OpenAI API error {response.status}: {error_data}")
        
        except Exception as e:
            return AIResponse(
                request_id=request.request_id,
                success=False,
                error=str(e)
            )
    
    async def _send_zai_request(self, request: AIRequest) -> AIResponse:
        """Send request to Z.ai."""
        try:
            provider_config = self._providers[AIProviderType.Z_AI]
            
            headers = {
                "Authorization": f"Bearer {provider_config.api_key}",
                "Content-Type": "application/json"
            }
            
            payload = {
                "model": request.model,
                "input": request.prompt,
                "max_tokens": request.max_tokens,
                "temperature": request.temperature
            }
            
            async with self._session.post(
                f"{provider_config.base_url}/chat/completions",
                headers=headers,
                json=payload,
                timeout=aiohttp.ClientTimeout(total=provider_config.timeout)
            ) as response:
                if response.status == 200:
                    data = await response.json()
                    content = data.get("content", "")
                    
                    return AIResponse(
                        request_id=request.request_id,
                        success=True,
                        content=content,
                        model=request.model
                    )
                else:
                    error_data = await response.text()
                    raise AIProviderAPIError(f"Z.ai API error {response.status}: {error_data}")
        
        except Exception as e:
            return AIResponse(
                request_id=request.request_id,
                success=False,
                error=str(e)
            )
    
    async def _send_lm_studio_request(self, request: AIRequest) -> AIResponse:
        """Send request to LM Studio."""
        try:
            provider_config = self._providers[AIProviderType.LM_STUDIO]
            
            payload = {
                "model": request.model,
                "prompt": request.prompt,
                "max_tokens": request.max_tokens,
                "temperature": request.temperature,
                "stream": request.stream
            }
            
            async with self._session.post(
                f"{provider_config.base_url}/v1/chat/completions",
                json=payload,
                timeout=aiohttp.ClientTimeout(total=provider_config.timeout)
            ) as response:
                if response.status == 200:
                    data = await response.json()
                    content = data["choices"][0]["message"]["content"]
                    
                    return AIResponse(
                        request_id=request.request_id,
                        success=True,
                        content=content,
                        model=request.model
                    )
                else:
                    error_data = await response.text()
                    raise AIProviderAPIError(f"LM Studio API error {response.status}: {error_data}")
        
        except Exception as e:
            return AIResponse(
                request_id=request.request_id,
                success=False,
                error=str(e)
            )
    
    async def get_code_suggestions(self, code_context: str, cursor_position: typing.Tuple[int, int] = None) -> typing.List[str]:
        """Get code suggestions from current provider."""
        try:
            if not self._current_provider or not self._current_model:
                return []
            
            # Create code completion prompt
            prompt = f"""Please analyze the following code and provide helpful suggestions for improvement:

```python
{code_context}
```

Provide specific suggestions for:
1. Code optimization
2. Best practices
3. Error handling
4. Security improvements
5. Performance enhancements

Return your suggestions as a clear, actionable list."""
            
            request = AIRequest(
                provider_type=self._current_provider,
                model=self._current_model,
                prompt=prompt,
                max_tokens=1000
            )
            
            response = await self.send_request(request)
            
            if response.success:
                # Parse suggestions from response
                suggestions = self._parse_suggestions(response.content)
                return suggestions
            else:
                self.logger.error(f"Failed to get code suggestions: {response.error}")
                return []
        
        except Exception as e:
            self.logger.error(f"Error getting code suggestions: {e}")
            return []
    
    def _parse_suggestions(self, content: str) -> typing.List[str]:
        """Parse suggestions from AI response content."""
        try:
            suggestions = []
            
            # Simple parsing - split by lines and look for numbered items
            lines = content.split('\n')
            for line in lines:
                line = line.strip()
                if line.startswith(('1.', '2.', '3.', '4.', '5.', '-', '*', '•')):
                    suggestions.append(line)
            
            # If no structured suggestions found, split by double newlines
            if not suggestions:
                suggestions = [s.strip() for s in content.split('\n\n') if s.strip()]
            
            return suggestions[:10]  # Limit to 10 suggestions
        
        except Exception as e:
            self.logger.error(f"Error parsing suggestions: {e}")
            return [content]  # Return raw content as fallback
    
    async def analyze_code_errors(self, code: str) -> typing.Dict[str, typing.Any]:
        """Analyze code for errors and issues."""
        try:
            if not self._current_provider or not self._current_model:
                return {"errors": [], "warnings": [], "suggestions": []}
            
            prompt = f"""Please analyze the following code for errors, warnings, and improvement suggestions:

```python
{code}
```

Provide your analysis in JSON format:
{{
  "errors": ["list of syntax/runtime errors"],
  "warnings": ["list of warnings and potential issues"],
  "suggestions": ["list of improvement suggestions"],
  "complexity_score": 1-10,
  "maintainability_score": 1-10
}}"""
            
            request = AIRequest(
                provider_type=self._current_provider,
                model=self._current_model,
                prompt=prompt,
                max_tokens=800
            )
            
            response = await self.send_request(request)
            
            if response.success:
                try:
                    # Try to parse as JSON
                    analysis = json.loads(response.content)
                    return analysis
                except json.JSONDecodeError:
                    # Fallback to text parsing
                    return {
                        "errors": [],
                        "warnings": [],
                        "suggestions": [response.content],
                        "complexity_score": 5,
                        "maintainability_score": 5
                    }
            else:
                return {
                    "errors": [f"Analysis failed: {response.error}"],
                    "warnings": [],
                    "suggestions": [],
                    "complexity_score": 0,
                    "maintainability_score": 0
                }
        
        except Exception as e:
            self.logger.error(f"Error analyzing code: {e}")
            return {
                "errors": [f"Analysis error: {str(e)}"],
                "warnings": [],
                "suggestions": [],
                "complexity_score": 0,
                "maintainability_score": 0
            }