# Converted from Python to NoodleCore
# Original file: src

# """
# AI Adapter Base Module

# This module provides the base class for all AI provider adapters.
# It defines the common interface and functionality that all adapters must implement.
# """

import asyncio
import hashlib
import json
import logging
import time
import abc.ABC
import typing.Dict
from dataclasses import dataclass
import datetime.datetime
import aiohttp
import enum.Enum


class AdapterErrorCode(Enum)
    #     """4-digit error codes for AI adapter operations."""
    CONNECTION_FAILED = 1001
    AUTHENTICATION_FAILED = 1002
    RATE_LIMIT_EXCEEDED = 1003
    MODEL_NOT_AVAILABLE = 1004
    INVALID_REQUEST = 1005
    TIMEOUT_EXCEEDED = 1006
    RESPONSE_VALIDATION_FAILED = 1007
    PROVIDER_ERROR = 1008
    CACHE_ERROR = 1009
    CONFIGURATION_ERROR = 1010


class AdapterError(Exception)
    #     """Custom exception for AI adapter errors with 4-digit error codes."""

    #     def __init__(self, message: str, error_code: AdapterErrorCode, provider: str = None):
            super().__init__(message)
    self.error_code = error_code
    self.error_code_value = error_code.value
    self.provider = provider
    self.timestamp = datetime.utcnow()


dataclass
class ChatMessage
    #     """Represents a chat message."""
    #     role: str  # 'system', 'user', 'assistant'
    #     content: str
    timestamp: Optional[datetime] = None


dataclass
class ChatResponse
    #     """Represents a chat response."""
    #     content: str
    #     model: str
    #     usage: Dict[str, int]
    finish_reason: Optional[str] = None
    request_id: Optional[str] = None
    provider: Optional[str] = None
    response_time: Optional[float] = None


dataclass
class ModelInfo
    #     """Information about an AI model."""
    #     name: str
    #     provider: str
    #     max_tokens: int
    #     supports_streaming: bool
    #     supports_function_calling: bool
    #     input_cost_per_1k: float
    #     output_cost_per_1k: float


class RateLimiter
    #     """Rate limiter for API requests."""

    #     def __init__(self, requests_per_minute: int, tokens_per_minute: int):
    self.requests_per_minute = requests_per_minute
    self.tokens_per_minute = tokens_per_minute
    self.request_times = []
    self.token_usage = []
    self._lock = asyncio.Lock()

    #     async def acquire(self, tokens: int = 0) -None):
    #         """Acquire permission to make a request."""
    #         async with self._lock:
    now = time.time()
    minute_ago = now - 60

    #             # Clean old entries
    #             self.request_times = [t for t in self.request_times if t minute_ago]
    #             self.token_usage = [(t, count) for t, count in self.token_usage if t > minute_ago]

    #             # Check request limit
    #             if len(self.request_times) >= self.requests_per_minute):
    sleep_time = 60 - (now - self.request_times[0])
    #                 if sleep_time 0):
                        await asyncio.sleep(sleep_time)
                        return await self.acquire(tokens)

    #             # Check token limit
    #             current_tokens = sum(count for _, count in self.token_usage)
    #             if current_tokens + tokens self.tokens_per_minute):
    sleep_time = 60 - (now - self.token_usage[0][0])
    #                 if sleep_time 0):
                        await asyncio.sleep(sleep_time)
                        return await self.acquire(tokens)

    #             # Record this request
                self.request_times.append(now)
                self.token_usage.append((now, tokens))


class ResponseCache
    #     """Simple in-memory response cache."""

    #     def __init__(self, max_size: int = 1000, ttl_seconds: int = 3600):
    self.max_size = max_size
    self.ttl_seconds = ttl_seconds
    self.cache: Dict[str, tuple] = {}
    self._lock = asyncio.Lock()

    #     def _generate_key(self, prompt: str, model: str, temperature: float, **kwargs) -str):
    #         """Generate cache key from request parameters."""
    key_data = {
    #             'prompt': prompt,
    #             'model': model,
    #             'temperature': temperature,
                'kwargs': sorted(kwargs.items())
    #         }
    key_str = json.dumps(key_data, sort_keys=True)
            return hashlib.md5(key_str.encode()).hexdigest()

    #     async def get(self, prompt: str, model: str, temperature: float, **kwargs) -Optional[ChatResponse]):
    #         """Get cached response if available and not expired."""
    #         async with self._lock:
    key = self._generate_key(prompt * model, temperature,, *kwargs)

    #             if key in self.cache:
    response, timestamp = self.cache[key]
    #                 if time.time() - timestamp < self.ttl_seconds:
    #                     return response
    #                 else:
    #                     del self.cache[key]

    #             return None

    #     async def set(self, prompt: str, model: str, temperature: float, response: ChatResponse, **kwargs) -None):
    #         """Cache a response."""
    #         async with self._lock:
    key = self._generate_key(prompt * model, temperature,, *kwargs)

    #             # Remove oldest if cache is full
    #             if len(self.cache) >= self.max_size:
    oldest_key = min(self.cache.keys(), key=lambda k: self.cache[k][1])
    #                 del self.cache[oldest_key]

    self.cache[key] = (response, time.time())


class AdapterBase(ABC)
    #     """Base class for AI provider adapters with enhanced functionality."""

    #     def __init__(self, api_key: str, base_url: Optional[str] = None, config: Optional[Dict[str, Any]] = None):""
    #         Initialize the adapter.

    #         Args:
    #             api_key: API key for the AI provider
    #             base_url: Base URL for the AI provider API
    #             config: Additional configuration parameters
    #         """
    self.api_key = api_key
    self.base_url = base_url
    self.config = config or {}
    self.name = self.__class__.__name__

    #         # Initialize components
    self.logger = logging.getLogger(f"noodlecore.adapters.{self.name}")
    self.rate_limiter = RateLimiter(
    requests_per_minute = self.config.get('requests_per_minute', 60),
    tokens_per_minute = self.config.get('tokens_per_minute', 100000)
    #         )
    self.cache = ResponseCache(
    max_size = self.config.get('cache_max_size', 1000),
    ttl_seconds = self.config.get('cache_ttl_seconds', 3600)
    #         )

    #         # HTTP session with connection pooling
    self.session: Optional[aiohttp.ClientSession] = None
    self.timeout = aiohttp.ClientTimeout(total=self.config.get('timeout', 30))

    #         # NoodleCore specific settings
    self.noodlecore_system_prompt = self._get_noodlecore_system_prompt()

    #     def _get_noodlecore_system_prompt(self) -str):
    #         """Get the default NoodleCore system prompt."""
            return """You are NoodleCore AI Assistant, specialized in NoodleCore (.nc-code) development.

# Your role is to:
1. Generate and validate NoodleCore code following proper syntax (.nc-code)
# 2. Ensure all output adheres to NoodleCore standards and constraints
# 3. Provide clear explanations of NoodleCore concepts and implementations
# 4. Validate code for correctness, security, and performance
# 5. Follow NoodleCore naming conventions and architectural patterns

# Always format your code responses with proper .nc-code syntax and include relevant metadata.
# If you're unsure about NoodleCore-specific requirements, ask for clarification."""

#     async def __aenter__(self):
#         """Async context manager entry."""
        await self._ensure_session()
#         return self

#     async def __aexit__(self, exc_type, exc_val, exc_tb):
#         """Async context manager exit."""
        await self.close()

#     async def _ensure_session(self):
#         """Ensure HTTP session is created."""
#         if self.session is None or self.session.closed:
connector = aiohttp.TCPConnector(
limit = self.config.get('max_connections', 20),
limit_per_host = self.config.get('max_connections_per_host', 10),
ttl_dns_cache = 300,
use_dns_cache = True,
#             )
self.session = aiohttp.ClientSession(
connector = connector,
timeout = self.timeout,
headers = self._prepare_request_headers()
#             )

#     async def close(self):
#         """Close the HTTP session."""
#         if self.session and not self.session.closed:
            await self.session.close()

#     @abstractmethod
#     async def chat(
#         self,
#         messages: List[ChatMessage],
model: Optional[str] = None,
temperature: float = 0.7,
max_tokens: int = 1000,
stream: bool = False,
#         **kwargs
#     ) -Union[ChatResponse, AsyncGenerator[str, None]]):
#         """
#         Send a chat request to the AI provider.

#         Args:
#             messages: List of chat messages
            model: The model to use (optional)
#             temperature: Temperature for response generation (0.0-1.0)
#             max_tokens: Maximum tokens in response
#             stream: Whether to stream the response
#             **kwargs: Additional provider-specific parameters

#         Returns:
#             ChatResponse or AsyncGenerator for streaming
#         """
#         pass

#     @abstractmethod
#     async def validate_connection(self) -bool):
#         """
#         Validate connection to the AI provider.

#         Returns:
#             True if connection is valid, False otherwise
#         """
#         pass

#     @abstractmethod
#     async def get_model_info(self, model: str) -ModelInfo):
#         """
#         Get information about a specific model.

#         Args:
#             model: Model name

#         Returns:
#             ModelInfo object
#         """
#         pass

#     async def chat_with_cache(
#         self,
#         messages: List[ChatMessage],
model: Optional[str] = None,
temperature: float = 0.7,
max_tokens: int = 1000,
use_cache: bool = True,
#         **kwargs
#     ) -ChatResponse):
#         """
#         Send a chat request with caching support.

#         Args:
#             messages: List of chat messages
            model: The model to use (optional)
#             temperature: Temperature for response generation (0.0-1.0)
#             max_tokens: Maximum tokens in response
#             use_cache: Whether to use caching
#             **kwargs: Additional provider-specific parameters

#         Returns:
#             ChatResponse object
#         """
#         # Convert messages to prompt string for caching
prompt = self._messages_to_prompt(messages)

#         # Check cache first
#         if use_cache:
cached_response = await self.cache.get(prompt, model or "", temperature, **kwargs)
#             if cached_response:
#                 self.logger.debug(f"Cache hit for model {model}")
#                 return cached_response

#         # Apply rate limiting
estimated_tokens = len(prompt.split()) + max_tokens
        await self.rate_limiter.acquire(estimated_tokens)

#         # Make the request
start_time = time.time()
#         try:
response = await self.chat(messages * model, temperature, max_tokens,, *kwargs)
response.response_time = time.time() - start_time

#             # Cache the response
#             if use_cache:
                await self.cache.set(prompt, model or "", temperature, response, **kwargs)

#             return response

#         except Exception as e:
            self.logger.error(f"Chat request failed: {str(e)}")
            raise self._handle_error(e)

#     async def chat_stream(
#         self,
#         messages: List[ChatMessage],
model: Optional[str] = None,
temperature: float = 0.7,
max_tokens: int = 1000,
#         **kwargs
#     ) -AsyncGenerator[str, None]):
#         """
#         Stream a chat response.

#         Args:
#             messages: List of chat messages
            model: The model to use (optional)
#             temperature: Temperature for response generation (0.0-1.0)
#             max_tokens: Maximum tokens in response
#             **kwargs: Additional provider-specific parameters

#         Yields:
#             Response chunks as strings
#         """
#         # Apply rate limiting
prompt = self._messages_to_prompt(messages)
estimated_tokens = len(prompt.split()) + max_tokens
        await self.rate_limiter.acquire(estimated_tokens)

#         try:
#             async for chunk in self.chat(messages, model, temperature, max_tokens, stream=True, **kwargs):
#                 yield chunk
#         except Exception as e:
            self.logger.error(f"Streaming chat request failed: {str(e)}")
            raise self._handle_error(e)

#     def _messages_to_prompt(self, messages: List[ChatMessage]) -str):
#         """Convert messages to a prompt string for caching."""
#         return "\n".join([f"{msg.role}: {msg.content}" for msg in messages])

#     def _prepare_request_headers(self) -Dict[str, str]):
#         """
#         Prepare common request headers.

#         Returns:
#             Dictionary of headers
#         """
#         return {
#             'Content-Type': 'application/json',
            'User-Agent': f'NoodleCore-CLI/1.0 ({self.name})',
#         }

#     def _validate_parameters(self, temperature: float, max_tokens: int) -None):
#         """
#         Validate common parameters.

#         Args:
#             temperature: Temperature parameter
#             max_tokens: Max tokens parameter

#         Raises:
#             AdapterError: If parameters are invalid
#         """
#         if not 0.0 <= temperature <= 1.0:
            raise AdapterError(
#                 "Temperature must be between 0.0 and 1.0",
#                 AdapterErrorCode.INVALID_REQUEST,
#                 self.name
#             )

#         if max_tokens <= 0:
            raise AdapterError(
#                 "Max tokens must be positive",
#                 AdapterErrorCode.INVALID_REQUEST,
#                 self.name
#             )

#     def _handle_error(self, error: Exception) -AdapterError):
#         """
#         Convert exceptions to AdapterError with appropriate error codes.

#         Args:
#             error: The original exception

#         Returns:
#             AdapterError with appropriate error code
#         """
#         if isinstance(error, aiohttp.ClientConnectorError):
            return AdapterError(
                f"Connection failed: {str(error)}",
#                 AdapterErrorCode.CONNECTION_FAILED,
#                 self.name
#             )
#         elif isinstance(error, aiohttp.ClientResponseError):
#             if error.status = 401:
                return AdapterError(
#                     "Authentication failed",
#                     AdapterErrorCode.AUTHENTICATION_FAILED,
#                     self.name
#                 )
#             elif error.status = 429:
                return AdapterError(
#                     "Rate limit exceeded",
#                     AdapterErrorCode.RATE_LIMIT_EXCEEDED,
#                     self.name
#                 )
#             elif 400 <= error.status < 500:
                return AdapterError(
                    f"Invalid request: {str(error)}",
#                     AdapterErrorCode.INVALID_REQUEST,
#                     self.name
#                 )
#             else:
                return AdapterError(
                    f"Provider error: {str(error)}",
#                     AdapterErrorCode.PROVIDER_ERROR,
#                     self.name
#                 )
#         elif isinstance(error, asyncio.TimeoutError):
            return AdapterError(
#                 "Request timeout exceeded",
#                 AdapterErrorCode.TIMEOUT_EXCEEDED,
#                 self.name
#             )
#         else:
            return AdapterError(
                f"Unexpected error: {str(error)}",
#                 AdapterErrorCode.PROVIDER_ERROR,
#                 self.name
#             )

#     def _generate_request_id(self) -str):
#         """Generate a unique request ID."""
#         import uuid
        return str(uuid.uuid4())

#     async def health_check(self) -Dict[str, Any]):
#         """
#         Perform a comprehensive health check on the adapter.

#         Returns:
#             Dictionary containing health status and metrics
#         """
#         try:
start_time = time.time()
is_connected = await self.validate_connection()
response_time = time.time() - start_time

#             return {
#                 'status': 'healthy' if is_connected else 'unhealthy',
#                 'provider': self.name,
#                 'base_url': self.base_url,
#                 'response_time': response_time,
                'cache_size': len(self.cache.cache),
#                 'rate_limit_status': {
#                     'requests_per_minute': self.rate_limiter.requests_per_minute,
#                     'tokens_per_minute': self.rate_limiter.tokens_per_minute,
                    'recent_requests': len(self.rate_limiter.request_times),
#                     'recent_tokens': sum(count for _, count in self.rate_limiter.token_usage)
#                 },
                'timestamp': datetime.utcnow().isoformat()
#             }
#         except Exception as e:
#             return {
#                 'status': 'unhealthy',
#                 'provider': self.name,
                'error': str(e),
                'error_type': type(e).__name__,
                'timestamp': datetime.utcnow().isoformat()
#             }