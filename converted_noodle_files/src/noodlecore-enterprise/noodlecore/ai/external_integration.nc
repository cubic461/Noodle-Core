# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# External AI Integration Module for NoodleCore
# --------------------------------------------

# This module provides a simple API for connecting to external AI services (OpenAI, Anthropic, etc.)
# and validating their output through the NoodleCore AI guard.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import os
import asyncio
import json
import logging
import time
import uuid
import abc.ABC,
import dataclasses.dataclass,
import enum.Enum
import typing.Any,

import aiohttp
import tenacity

import .guard.AIGuard,


class AIProvider(Enum)
    #     """Supported AI providers"""
    OPENAI = "openai"
    ANTHROPIC = "anthropic"
    CUSTOM = "custom"


# @dataclass
class AIRequest
    #     """Request to an AI provider"""
    #     prompt: str
    max_tokens: int = 1000
    temperature: float = 0.7
    model: Optional[str] = None
    system_prompt: Optional[str] = None
    context: Optional[Dict[str, Any]] = None
    request_id: str = field(default_factory=lambda: str(uuid.uuid4()))


# @dataclass
class AIResponse
    #     """Response from an AI provider"""
    #     content: str
    #     model: str
    usage: Dict[str, int] = field(default_factory=dict)
    request_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    response_time_ms: int = 0
    provider: AIProvider = AIProvider.CUSTOM
    metadata: Dict[str, Any] = field(default_factory=dict)


# @dataclass
class ExternalAIConfig
    #     """Configuration for external AI integration"""
    provider: AIProvider = AIProvider.OPENAI
    api_key: Optional[str] = None
    api_base: Optional[str] = None
    model: str = "gpt-3.5-turbo"
    max_tokens: int = 1000
    temperature: float = 0.7
    timeout_ms: int = 30000  # 30 seconds
    max_retries: int = 3
    retry_delay_ms: int = 1000
    validate_output: bool = True
    guard_config: Optional[GuardConfig] = None

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert config to dictionary"""
    #         return {
    #             "provider": self.provider.value,
    #             "api_key": "***" if self.api_key else None,  # Hide API key
    #             "api_base": self.api_base,
    #             "model": self.model,
    #             "max_tokens": self.max_tokens,
    #             "temperature": self.temperature,
    #             "timeout_ms": self.timeout_ms,
    #             "max_retries": self.max_retries,
    #             "retry_delay_ms": self.retry_delay_ms,
    #             "validate_output": self.validate_output,
    #             "guard_config": self.guard_config.to_dict() if self.guard_config else None,
    #         }


class ExternalAIException(Exception)
    #     """Exception raised by external AI integration"""

    #     def __init__(self, message: str, code: str = "AI_ERROR", provider: AIProvider = AIProvider.CUSTOM):
    self.message = message
    self.code = code
    self.provider = provider
            super().__init__(self.message)


class BaseAIProvider(ABC)
    #     """Base class for AI providers"""

    #     def __init__(self, config: ExternalAIConfig):
    self.config = config
    self.logger = logging.getLogger(f"noodlecore.ai.{config.provider.value}")

    #     @abstractmethod
    #     async def generate_response(self, request: AIRequest) -> AIResponse:
    #         """Generate a response from the AI provider"""
    #         pass

    #     @abstractmethod
    #     def get_headers(self) -> Dict[str, str]:
    #         """Get headers for API requests"""
    #         pass


class OpenAIProvider(BaseAIProvider)
    #     """OpenAI API provider"""

    #     def __init__(self, config: ExternalAIConfig):
            super().__init__(config)
    self.api_key = config.api_key or os.environ.get("OPENAI_API_KEY")
    self.api_base = config.api_base or "https://api.openai.com/v1"

    #         if not self.api_key:
                raise ExternalAIException(
    #                 "OpenAI API key not provided. Set OPENAI_API_KEY environment variable or pass in config.",
    #                 "MISSING_API_KEY",
    #                 AIProvider.OPENAI
    #             )

    #     def get_headers(self) -> Dict[str, str]:
    #         """Get headers for OpenAI API requests"""
    #         return {
    #             "Authorization": f"Bearer {self.api_key}",
    #             "Content-Type": "application/json",
    #         }

    #     async def generate_response(self, request: AIRequest) -> AIResponse:
    #         """Generate a response from OpenAI"""
    start_time = time.time()

    #         # Prepare the request payload
    messages = []

    #         if request.system_prompt:
                messages.append({"role": "system", "content": request.system_prompt})

            messages.append({"role": "user", "content": request.prompt})

    payload = {
    #             "model": request.model or self.config.model,
    #             "messages": messages,
    #             "max_tokens": request.max_tokens or self.config.max_tokens,
    #             "temperature": request.temperature if request.temperature is not None else self.config.temperature,
    #         }

    #         # Make the API request
    #         try:
    timeout = math.divide(aiohttp.ClientTimeout(total=self.config.timeout_ms, 1000))
    #             async with aiohttp.ClientSession(timeout=timeout) as session:
    #                 async with session.post(
    #                     f"{self.api_base}/chat/completions",
    headers = self.get_headers(),
    json = payload
    #                 ) as response:
    #                     if response.status != 200:
    error_text = await response.text()
                            raise ExternalAIException(
    #                             f"OpenAI API error: {response.status} - {error_text}",
    #                             "API_ERROR",
    #                             AIProvider.OPENAI
    #                         )

    data = await response.json()

    #                     # Extract the response content
    content = data["choices"][0]["message"]["content"]

    #                     # Create response object
    response_time_ms = math.multiply(int((time.time() - start_time), 1000))

                        return AIResponse(
    content = content,
    model = data["model"],
    usage = data.get("usage", {}),
    request_id = request.request_id,
    response_time_ms = response_time_ms,
    provider = AIProvider.OPENAI,
    metadata = {"raw_response": data}
    #                     )

    #         except asyncio.TimeoutError:
                raise ExternalAIException(
    #                 f"Request timed out after {self.config.timeout_ms}ms",
    #                 "TIMEOUT",
    #                 AIProvider.OPENAI
    #             )
    #         except aiohttp.ClientError as e:
                raise ExternalAIException(
                    f"Network error: {str(e)}",
    #                 "NETWORK_ERROR",
    #                 AIProvider.OPENAI
    #             )


class AnthropicProvider(BaseAIProvider)
    #     """Anthropic Claude API provider"""

    #     def __init__(self, config: ExternalAIConfig):
            super().__init__(config)
    self.api_key = config.api_key or os.environ.get("ANTHROPIC_API_KEY")
    self.api_base = config.api_base or "https://api.anthropic.com/v1"

    #         if not self.api_key:
                raise ExternalAIException(
    #                 "Anthropic API key not provided. Set ANTHROPIC_API_KEY environment variable or pass in config.",
    #                 "MISSING_API_KEY",
    #                 AIProvider.ANTHROPIC
    #             )

    #     def get_headers(self) -> Dict[str, str]:
    #         """Get headers for Anthropic API requests"""
    #         return {
    #             "x-api-key": self.api_key,
    #             "Content-Type": "application/json",
    #             "anthropic-version": "2023-06-01"
    #         }

    #     async def generate_response(self, request: AIRequest) -> AIResponse:
    #         """Generate a response from Anthropic Claude"""
    start_time = time.time()

    #         # Prepare the request payload
    messages = [{"role": "user", "content": request.prompt}]

    payload = {
    #             "model": request.model or self.config.model,
    #             "max_tokens": request.max_tokens or self.config.max_tokens,
    #             "temperature": request.temperature if request.temperature is not None else self.config.temperature,
    #             "messages": messages,
    #         }

    #         if request.system_prompt:
    payload["system"] = request.system_prompt

    #         # Make the API request
    #         try:
    timeout = math.divide(aiohttp.ClientTimeout(total=self.config.timeout_ms, 1000))
    #             async with aiohttp.ClientSession(timeout=timeout) as session:
    #                 async with session.post(
    #                     f"{self.api_base}/messages",
    headers = self.get_headers(),
    json = payload
    #                 ) as response:
    #                     if response.status != 200:
    error_text = await response.text()
                            raise ExternalAIException(
    #                             f"Anthropic API error: {response.status} - {error_text}",
    #                             "API_ERROR",
    #                             AIProvider.ANTHROPIC
    #                         )

    data = await response.json()

    #                     # Extract the response content
    content = data["content"][0]["text"]

    #                     # Create response object
    response_time_ms = math.multiply(int((time.time() - start_time), 1000))

                        return AIResponse(
    content = content,
    model = data["model"],
    usage = data.get("usage", {}),
    request_id = request.request_id,
    response_time_ms = response_time_ms,
    provider = AIProvider.ANTHROPIC,
    metadata = {"raw_response": data}
    #                     )

    #         except asyncio.TimeoutError:
                raise ExternalAIException(
    #                 f"Request timed out after {self.config.timeout_ms}ms",
    #                 "TIMEOUT",
    #                 AIProvider.ANTHROPIC
    #             )
    #         except aiohttp.ClientError as e:
                raise ExternalAIException(
                    f"Network error: {str(e)}",
    #                 "NETWORK_ERROR",
    #                 AIProvider.ANTHROPIC
    #             )


class CustomProvider(BaseAIProvider)
    #     """Custom AI provider for testing or custom implementations"""

    #     def __init__(self, config: ExternalAIConfig):
            super().__init__(config)
    self.response_callback = None

    #     def set_response_callback(self, callback: Callable[[AIRequest], AIResponse]):
    #         """Set a callback function to generate responses"""
    self.response_callback = callback

    #     def get_headers(self) -> Dict[str, str]:
    #         """Get headers for custom API requests"""
    #         return {}

    #     async def generate_response(self, request: AIRequest) -> AIResponse:
    #         """Generate a response from custom provider"""
    start_time = time.time()

    #         if self.response_callback:
    response = self.response_callback(request)
    response.request_id = request.request_id
    response.response_time_ms = math.multiply(int((time.time() - start_time), 1000))
    #             return response

    #         # Default mock response
    response_time_ms = math.multiply(int((time.time() - start_time), 1000))
            return AIResponse(
    content = f"Mock response to: {request.prompt[:50]}...",
    model = "mock-model",
    usage = {"prompt_tokens": 10, "completion_tokens": 20, "total_tokens": 30},
    request_id = request.request_id,
    response_time_ms = response_time_ms,
    provider = AIProvider.CUSTOM,
    #         )


class ExternalAIIntegration
    #     """
    #     Main class for integrating with external AI services and validating output
    #     through the NoodleCore AI guard.
    #     """

    #     def __init__(self, config: Optional[ExternalAIConfig] = None):
    #         """Initialize the external AI integration"""
    self.config = config or ExternalAIConfig()
    self.logger = logging.getLogger("noodlecore.ai.external_integration")

    #         # Initialize the AI provider
    self.provider = self._create_provider()

    #         # Initialize the AI guard if validation is enabled
    self.ai_guard = None
    #         if self.config.validate_output:
    guard_config = self.config.guard_config or GuardConfig()
    self.ai_guard = AIGuard(guard_config)

    #         # Statistics
    self.stats = {
    #             "total_requests": 0,
    #             "successful_requests": 0,
    #             "failed_requests": 0,
    #             "validation_failures": 0,
    #             "total_time_ms": 0,
    #         }

    #         self.logger.info(f"External AI Integration initialized with provider: {self.config.provider.value}")

    #     def _create_provider(self) -> BaseAIProvider:
    #         """Create the appropriate AI provider based on configuration"""
    #         if self.config.provider == AIProvider.OPENAI:
                return OpenAIProvider(self.config)
    #         elif self.config.provider == AIProvider.ANTHROPIC:
                return AnthropicProvider(self.config)
    #         else:  # CUSTOM
                return CustomProvider(self.config)

        @tenacity.retry(
    stop = tenacity.stop_after_attempt(3),
    wait = tenacity.wait_fixed(1),
    retry = tenacity.retry_if_exception_type(ExternalAIException),
    before_sleep = tenacity.before_sleep_log(logger=logging.getLogger("noodlecore.ai.external_integration"), logging.WARNING),
    #     )
    #     async def generate(
    #         self,
    #         prompt: str,
    max_tokens: Optional[int] = None,
    temperature: Optional[float] = None,
    model: Optional[str] = None,
    system_prompt: Optional[str] = None,
    validate: Optional[bool] = None,
    file_path: Optional[str] = None
    #     ) -> Dict[str, Any]:
    #         """
    #         Generate a response from the external AI and optionally validate it

    #         Args:
    #             prompt: The prompt to send to the AI
    #             max_tokens: Maximum number of tokens to generate
    #             temperature: Temperature for generation (0.0-1.0)
    #             model: Model to use for generation
    #             system_prompt: System prompt to use
                validate: Whether to validate the output (overrides config)
    #             file_path: Optional file path for validation error reporting

    #         Returns:
    #             Dictionary containing the response and validation results
    #         """
    start_time = time.time()
    self.stats["total_requests"] + = 1

    #         try:
    #             # Create the request
    request = AIRequest(
    prompt = prompt,
    max_tokens = max_tokens or self.config.max_tokens,
    #                 temperature=temperature if temperature is not None else self.config.temperature,
    model = model or self.config.model,
    system_prompt = system_prompt,
    #             )

                self.logger.info(f"Generating AI response (request_id: {request.request_id})")

    #             # Generate the response
    response = await self.provider.generate_response(request)

    #             # Validate the response if enabled
    validation_result = None
    #             should_validate = validate if validate is not None else self.config.validate_output

    #             if should_validate and self.ai_guard:
                    self.logger.info(f"Validating AI response (request_id: {request.request_id})")

    #                 # Create a correction callback if needed
    #                 async def correction_callback(original_output: str, errors: List) -> str:
    #                     # In a real implementation, this would send the errors back to the AI
    #                     # For now, we'll just return the original output
                        self.logger.warning(f"Correction requested but not implemented (request_id: {request.request_id})")
    #                     return original_output

    validation_result = self.ai_guard.validate_output(
    #                     response.content,
    file_path = file_path,
    correction_callback = correction_callback
    #                 )

    #                 if not validation_result.success:
    self.stats["validation_failures"] + = 1
                        self.logger.warning(f"Validation failed (request_id: {request.request_id})")

    #             # Update statistics
    self.stats["successful_requests"] + = 1
    total_time_ms = math.multiply(int((time.time() - start_time), 1000))
    self.stats["total_time_ms"] + = total_time_ms

    #             # Return the result
    result = {
    #                 "requestId": request.request_id,
    #                 "response": {
    #                     "content": response.content,
    #                     "model": response.model,
    #                     "usage": response.usage,
    #                     "responseTimeMs": response.response_time_ms,
    #                     "provider": response.provider.value,
    #                 },
    #                 "validation": validation_result.to_dict() if validation_result else None,
    #                 "success": True,
    #                 "totalTimeMs": total_time_ms,
    #             }

                self.logger.info(f"AI response generated successfully (request_id: {request.request_id})")
    #             return result

    #         except Exception as e:
    self.stats["failed_requests"] + = 1
                self.logger.error(f"Failed to generate AI response: {str(e)}")

    #             # Return error result
    #             return {
    #                 "requestId": request.request_id if 'request' in locals() else str(uuid.uuid4()),
                    "error": str(e),
    #                 "success": False,
                    "totalTimeMs": int((time.time() - start_time) * 1000),
    #             }

    #     async def generate_sync(
    #         self,
    #         prompt: str,
    max_tokens: Optional[int] = None,
    temperature: Optional[float] = None,
    model: Optional[str] = None,
    system_prompt: Optional[str] = None,
    validate: Optional[bool] = None,
    file_path: Optional[str] = None
    #     ) -> Dict[str, Any]:
    #         """
    #         Synchronous wrapper for the generate method

    #         This method provides a synchronous interface for the async generate method.
    #         It's useful for contexts where async/await is not available.
    #         """
    loop = asyncio.get_event_loop()
            return await loop.run_in_executor(
    #             None,
                lambda: asyncio.run(self.generate(
    prompt = prompt,
    max_tokens = max_tokens,
    temperature = temperature,
    model = model,
    system_prompt = system_prompt,
    validate = validate,
    file_path = file_path
    #             ))
    #         )

    #     def get_statistics(self) -> Dict[str, Any]:
    #         """Get integration statistics"""
    #         return {
    #             "total_requests": self.stats["total_requests"],
    #             "successful_requests": self.stats["successful_requests"],
    #             "failed_requests": self.stats["failed_requests"],
    #             "validation_failures": self.stats["validation_failures"],
                "success_rate": (
    #                 self.stats["successful_requests"] / self.stats["total_requests"]
    #                 if self.stats["total_requests"] > 0 else 0
    #             ),
    #             "total_time_ms": self.stats["total_time_ms"],
                "average_time_ms": (
    #                 self.stats["total_time_ms"] / self.stats["total_requests"]
    #                 if self.stats["total_requests"] > 0 else 0
    #             ),
                "config": self.config.to_dict(),
    #         }

    #     def reset_statistics(self):
    #         """Reset integration statistics"""
    self.stats = {
    #             "total_requests": 0,
    #             "successful_requests": 0,
    #             "failed_requests": 0,
    #             "validation_failures": 0,
    #             "total_time_ms": 0,
    #         }
            self.logger.info("Statistics reset")


# Convenience function for quick usage
# async def quick_generate(
#     prompt: str,
provider: AIProvider = AIProvider.OPENAI,
api_key: Optional[str] = None,
model: Optional[str] = None,
validate: bool = True,
file_path: Optional[str] = None
# ) -> Dict[str, Any]:
#     """
#     Quick function to generate a response from an AI provider

#     Args:
#         prompt: The prompt to send to the AI
#         provider: The AI provider to use
#         api_key: API key for the provider (if not set in environment)
#         model: Model to use for generation
#         validate: Whether to validate the output
#         file_path: Optional file path for validation error reporting

#     Returns:
#         Dictionary containing the response and validation results
#     """
config = ExternalAIConfig(
provider = provider,
api_key = api_key,
#         model=model or ("gpt-3.5-turbo" if provider == AIProvider.OPENAI else "claude-3-haiku-20240307"),
validate_output = validate
#     )

integration = ExternalAIIntegration(config)
return await integration.generate(prompt, file_path = file_path)