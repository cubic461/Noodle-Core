# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Ollama Adapter Module

# This module implements the adapter for Ollama local model provider with full API integration.
# """

import asyncio
import json
import logging
import typing.Dict,
import aiohttp

import .adapter_base.(
#     AdapterBase, ChatMessage, ChatResponse, ModelInfo,
#     AdapterError, AdapterErrorCode
# )


class OllamaAdapter(AdapterBase)
    #     """Adapter for Ollama local model provider with full API integration."""

    #     def __init__(self, api_key: str, base_url: Optional[str] = None, config: Optional[Dict[str, Any]] = None):
    #         """
    #         Initialize the Ollama adapter.

    #         Args:
    #             api_key: API key for Ollama (not typically used for local instances)
    #             base_url: Base URL for Ollama API (default: http://localhost:11434)
    #             config: Additional configuration parameters
    #         """
            super().__init__(
    #             api_key or "",
    #             base_url or "http://localhost:11434",
    #             config
    #         )
    self.default_model = "llama2"
    self.chat_endpoint = f"{self.base_url}/api/chat"
    self.generate_endpoint = f"{self.base_url}/api/generate"
    self.models_endpoint = f"{self.base_url}/api/tags"
    self.pull_endpoint = f"{self.base_url}/api/pull"
    self.delete_endpoint = f"{self.base_url}/api/delete"

    #         # Ollama specific settings
    #         self.max_retries = config.get('max_retries', 3) if config else 3
    #         self.retry_delay = config.get('retry_delay', 1) if config else 1
    #         self.timeout = config.get('timeout', 60) if config else 60  # Longer timeout for local models

    #     async def chat(
    #         self,
    #         messages: List[ChatMessage],
    model: Optional[str] = None,
    temperature: float = 0.7,
    max_tokens: int = 1000,
    stream: bool = False,
    #         **kwargs
    #     ) -> Union[ChatResponse, AsyncGenerator[str, None]]:
    #         """
    #         Send a chat request to Ollama.

    #         Args:
    #             messages: List of chat messages
                model: The model to use (default: llama2)
    #             temperature: Temperature for response generation (0.0-1.0)
    #             max_tokens: Maximum tokens in response
    #             stream: Whether to stream the response
    #             **kwargs: Additional provider-specific parameters

    #         Returns:
    #             ChatResponse or AsyncGenerator for streaming
    #         """
            await self._ensure_session()
            self._validate_parameters(temperature, max_tokens)

    model = model or self.default_model
    request_id = self._generate_request_id()

    #         # Prepare request payload
    payload = math.multiply(self._prepare_chat_payload(messages, model, temperature, max_tokens, stream,, *kwargs))

    headers = self._prepare_request_headers()

    #         try:
    #             if stream:
                    return self._stream_chat_response(payload, headers, request_id)
    #             else:
                    return await self._send_chat_request(payload, headers, request_id)

    #         except Exception as e:
                self.logger.error(f"Ollama chat request failed: {str(e)}")
                raise self._handle_error(e)

    #     async def _send_chat_request(self, payload: Dict[str, Any], headers: Dict[str, str], request_id: str) -> ChatResponse:
    #         """Send a non-streaming chat request."""
    #         async with self.session.post(
    #             self.chat_endpoint,
    json = payload,
    headers = headers,
    timeout = aiohttp.ClientTimeout(total=self.timeout)
    #         ) as response:
    #             if response.status != 200:
    error_text = await response.text()
                    self.logger.error(f"Ollama API error {response.status}: {error_text}")
                    raise AdapterError(
    #                     f"Ollama API error: {response.status} - {error_text}",
    #                     AdapterErrorCode.PROVIDER_ERROR,
    #                     self.name
    #                 )

    response_data = await response.json()
                return self._parse_chat_response(response_data, request_id)

    #     async def _stream_chat_response(self, payload: Dict[str, Any], headers: Dict[str, str], request_id: str) -> AsyncGenerator[str, None]:
    #         """Stream a chat response."""
    #         async with self.session.post(
    #             self.chat_endpoint,
    json = payload,
    headers = headers,
    timeout = aiohttp.ClientTimeout(total=self.timeout)
    #         ) as response:
    #             if response.status != 200:
    error_text = await response.text()
                    self.logger.error(f"Ollama streaming API error {response.status}: {error_text}")
                    raise AdapterError(
    #                     f"Ollama streaming API error: {response.status} - {error_text}",
    #                     AdapterErrorCode.PROVIDER_ERROR,
    #                     self.name
    #                 )

    #             async for line in response.content:
    #                 if line:
    line_str = line.decode('utf-8').strip()
    #                     try:
    data = json.loads(line_str)
    #                         if 'message' in data and 'content' in data['message']:
    #                             yield data['message']['content']
    #                         if data.get('done', False):
    #                             break
    #                     except json.JSONDecodeError:
    #                         continue

    #     def _prepare_chat_payload(
    #         self,
    #         messages: List[ChatMessage],
    #         model: str,
    #         temperature: float,
    #         max_tokens: int,
    #         stream: bool,
    #         **kwargs
    #     ) -> Dict[str, Any]:
    #         """Prepare the chat request payload for Ollama API."""
    #         # Convert ChatMessage objects to Ollama format
    formatted_messages = []
    #         for msg in messages:
                formatted_messages.append({
    #                 "role": msg.role,
    #                 "content": msg.content
    #             })

    #         # Ensure system message is present with NoodleCore prompt
    #         if not any(msg.role == 'system' for msg in messages):
                formatted_messages.insert(0, {
    #                 "role": "system",
    #                 "content": self.noodlecore_system_prompt
    #             })

    payload = {
    #             "model": model,
    #             "messages": formatted_messages,
    #             "stream": stream,
    #             "options": {
    #                 "temperature": temperature,
    #                 "num_predict": max_tokens,
                    "top_p": kwargs.get('top_p', 0.9),
                    "top_k": kwargs.get('top_k', 40),
                    "repeat_penalty": kwargs.get('repeat_penalty', 1.1)
    #             }
    #         }

    #         # Add additional options
    #         if 'stop' in kwargs:
    payload['options']['stop'] = kwargs['stop']
    #         if 'seed' in kwargs:
    payload['options']['seed'] = kwargs['seed']

    #         return payload

    #     def _parse_chat_response(self, response_data: Dict[str, Any], request_id: str) -> ChatResponse:
    #         """Parse the chat response from Ollama API."""
    #         try:
    message = response_data.get('message', {})
    content = message.get('content', '')

    #             # Ollama doesn't provide token usage in the same way, so we'll estimate
    content_length = len(content.split())

                return ChatResponse(
    content = content,
    model = response_data.get('model', self.default_model),
    usage = {
                        'prompt_tokens': response_data.get('prompt_eval_count', 0),
                        'completion_tokens': response_data.get('eval_count', content_length),
                        'total_tokens': response_data.get('prompt_eval_count', 0) + response_data.get('eval_count', content_length)
    #                 },
    #                 finish_reason='stop' if response_data.get('done', False) else None,
    request_id = request_id,
    provider = self.name
    #             )
            except (KeyError, TypeError) as e:
                raise AdapterError(
                    f"Invalid response format from Ollama: {str(e)}",
    #                 AdapterErrorCode.RESPONSE_VALIDATION_FAILED,
    #                 self.name
    #             )

    #     async def validate_connection(self) -> bool:
    #         """
    #         Validate connection to Ollama API.

    #         Returns:
    #             True if connection is valid, False otherwise
    #         """
    #         try:
                await self._ensure_session()

    #             # Check if Ollama is running by listing models
    models = await self.get_available_models()
    #             return True  # If we can list models, connection is valid

    #         except Exception as e:
                self.logger.error(f"Ollama connection validation failed: {str(e)}")
    #             return False

    #     async def get_model_info(self, model: str) -> ModelInfo:
    #         """
    #         Get information about a specific Ollama model.

    #         Args:
    #             model: Model name

    #         Returns:
    #             ModelInfo object
    #         """
    #         # Get detailed model information
    #         try:
                await self._ensure_session()
    headers = self._prepare_request_headers()

    #             # Get model details
    #             async with self.session.post(
    #                 f"{self.base_url}/api/show",
    json = {"name": model},
    headers = headers
    #             ) as response:
    #                 if response.status == 200:
    model_data = await response.json()
                        return ModelInfo(
    name = model,
    provider = "ollama",
    max_tokens = model_data.get('modelinfo', {}).get('context_length', 4096),
    supports_streaming = True,
    supports_function_calling = False,  # Ollama typically doesn't support function calling
    input_cost_per_1k = 0.0,  # Local models are free
    output_cost_per_1k = 0.0
    #                     )
    #                 else:
    #                     # Fallback to default info
                        return ModelInfo(
    name = model,
    provider = "ollama",
    max_tokens = 4096,
    supports_streaming = True,
    supports_function_calling = False,
    input_cost_per_1k = 0.0,
    output_cost_per_1k = 0.0
    #                     )
    #         except Exception as e:
    #             self.logger.warning(f"Failed to get detailed info for model {model}: {str(e)}")
    #             # Return default info
                return ModelInfo(
    name = model,
    provider = "ollama",
    max_tokens = 4096,
    supports_streaming = True,
    supports_function_calling = False,
    input_cost_per_1k = 0.0,
    output_cost_per_1k = 0.0
    #             )

    #     async def get_available_models(self) -> List[str]:
    #         """
    #         Get list of available models from Ollama.

    #         Returns:
    #             List of model names
    #         """
    #         try:
                await self._ensure_session()
    headers = self._prepare_request_headers()

    #             async with self.session.get(self.models_endpoint, headers=headers) as response:
    #                 if response.status == 200:
    data = await response.json()
    #                     return [model['name'] for model in data.get('models', [])]
    #                 else:
                        self.logger.warning(f"Failed to fetch models from Ollama: {response.status}")
    #                     return []
    #         except Exception as e:
                self.logger.error(f"Error fetching Ollama models: {str(e)}")
    #             return []

    #     async def get_provider_info(self) -> Dict[str, Any]:
    #         """
    #         Get information about Ollama provider.

    #         Returns:
    #             Dictionary containing provider information
    #         """
    #         return {
    #             'name': 'Ollama',
    #             'description': 'Ollama local model provider',
    #             'base_url': self.base_url,
    #             'default_model': self.default_model,
    #             'features': [
    #                 'local_models',
    #                 'code_generation',
    #                 'code_validation',
    #                 'text_completion',
    #                 'conversation',
    #                 'streaming',
    #                 'model_management',
    #                 'offline_capability'
    #             ],
    #             'rate_limits': {
    #                 'requests_per_minute': self.rate_limiter.requests_per_minute,
    #                 'tokens_per_minute': self.rate_limiter.tokens_per_minute
    #             },
                'supported_models': await self.get_available_models(),
    #             'is_local': True,
    #             'cost_model': 'free'
    #         }

    #     def _prepare_request_headers(self) -> Dict[str, str]:
    #         """
    #         Prepare Ollama specific request headers.

    #         Returns:
    #             Dictionary of headers
    #         """
    headers = super()._prepare_request_headers()
    #         # Ollama doesn't require special headers
    #         return headers

    #     async def _retry_request(self, request_func, *args, **kwargs) -> Any:
    #         """
    #         Retry a request with exponential backoff.

    #         Args:
    #             request_func: The request function to retry
    #             *args: Arguments to pass to the request function
    #             **kwargs: Keyword arguments to pass to the request function

    #         Returns:
    #             The result of the request function
    #         """
    #         for attempt in range(self.max_retries):
    #             try:
                    return await request_func(*args, **kwargs)
    #             except aiohttp.ClientError as e:
    #                 if attempt == self.max_retries - 1:
    #                     raise

    delay = math.multiply(self.retry_delay, (2 ** attempt))
                    self.logger.warning(f"Request failed, retrying in {delay}s: {str(e)}")
                    await asyncio.sleep(delay)

    #     def _sanitize_input(self, text: str) -> str:
    #         """
    #         Sanitize input to prevent injection attacks.

    #         Args:
    #             text: Input text to sanitize

    #         Returns:
    #             Sanitized text
    #         """
    #         # Basic HTML escaping
    text = text.replace('&', '&')
    text = text.replace('<', '<')
    text = text.replace('>', '>')
    text = text.replace('"', '"')
    text = text.replace("'", '&#x27;')

    #         # Remove any potential control characters
    #         text = ''.join(char for char in text if ord(char) >= 32 or char in '\n\r\t')

    #         return text

    #     async def validate_noodlecore_code(self, code: str, model: Optional[str] = None) -> Dict[str, Any]:
    #         """
    #         Validate NoodleCore code using Ollama.

    #         Args:
    #             code: NoodleCore code to validate
    #             model: Specific model to use for validation

    #         Returns:
    #             Dictionary containing validation results
    #         """
    #         try:
    #             # Sanitize input
    sanitized_code = self._sanitize_input(code)

    validation_messages = [
    ChatMessage(role = "system", content=self.noodlecore_system_prompt),
                    ChatMessage(
    role = "user",
    #                     content=f"Please validate this NoodleCore (.nc-code) for syntax correctness, security, and best practices:\n\n```\n{sanitized_code}\n```\n\nProvide a detailed analysis with specific feedback on any issues found."
    #                 )
    #             ]

    response = await self.chat(
    messages = validation_messages,
    model = model,
    temperature = 0.1,
    max_tokens = 2000
    #             )

                # Simple validation logic (in a real implementation, this would be more sophisticated)
    content = response.content.lower()
    is_valid = "no errors" in content or "syntactically correct" in content
    has_errors = "error" in content or "issue" in content or "problem" in content

    #             return {
    #                 'success': True,
    #                 'provider': 'Ollama',
    #                 'model': response.model,
                    'code_length': len(code),
    #                 'validation_result': response.content,
    #                 'is_valid': is_valid and not has_errors,
    #                 'errors': [] if is_valid else ["Validation issues detected"],
    #                 'warnings': [],
    #                 'usage': response.usage
    #             }

    #         except Exception as e:
                self.logger.error(f"NoodleCore code validation failed: {str(e)}")
    #             return {
    #                 'success': False,
    #                 'provider': 'Ollama',
                    'error': str(e),
    #                 'is_valid': False,
                    'errors': [f"Validation failed: {str(e)}"]
    #             }

    #     async def generate_noodlecore_code(self, prompt: str, context: Optional[str] = None, model: Optional[str] = None) -> Dict[str, Any]:
    #         """
    #         Generate NoodleCore code using Ollama.

    #         Args:
    #             prompt: Description of code to generate
    #             context: Additional context for code generation
    #             model: Specific model to use for generation

    #         Returns:
    #             Dictionary containing generated code and metadata
    #         """
    #         try:
    #             # Sanitize inputs
    sanitized_prompt = self._sanitize_input(prompt)
    #             sanitized_context = self._sanitize_input(context) if context else ""

    code_generation_messages = [
    ChatMessage(role = "system", content=self.noodlecore_system_prompt),
                    ChatMessage(
    role = "user",
    #                     content=f"""Generate NoodleCore (.nc-code) for the following requirement:

# {sanitized_prompt}

# {f"Additional context: {sanitized_context}" if sanitized_context else ""}

# Please provide:
# 1. Complete NoodleCore code with proper syntax
# 2. Brief explanation of the implementation
# 3. Any assumptions made

# Format your response with the code in a proper .nc-code block."""
#                 )
#             ]

response = await self.chat(
messages = code_generation_messages,
model = model,
temperature = 0.3,
max_tokens = 3000
#             )

#             return {
#                 'success': True,
#                 'provider': 'Ollama',
#                 'model': response.model,
#                 'generated_code': response.content,
                'prompt_length': len(prompt),
#                 'context_length': len(context) if context else 0,
#                 'usage': response.usage,
#                 'request_id': response.request_id
#             }

#         except Exception as e:
            self.logger.error(f"NoodleCore code generation failed: {str(e)}")
#             return {
#                 'success': False,
#                 'provider': 'Ollama',
                'error': str(e),
#                 'generated_code': None
#             }

#     async def pull_model(self, model_name: str) -> Dict[str, Any]:
#         """
#         Pull a model from Ollama registry.

#         Args:
#             model_name: Name of the model to pull

#         Returns:
#             Dictionary containing pull operation results
#         """
#         try:
            await self._ensure_session()
headers = self._prepare_request_headers()

payload = {"name": model_name}

#             async with self.session.post(
#                 self.pull_endpoint,
json = payload,
headers = headers,
#                 timeout=aiohttp.ClientTimeout(total=300)  # 5 minutes timeout for pulling
#             ) as response:
#                 if response.status == 200:
#                     return {
#                         'success': True,
#                         'provider': 'Ollama',
#                         'model': model_name,
#                         'message': f"Model {model_name} pulled successfully"
#                     }
#                 else:
error_text = await response.text()
#                     return {
#                         'success': False,
#                         'provider': 'Ollama',
#                         'error': f"Failed to pull model {model_name}: {error_text}"
#                     }

#         except Exception as e:
            self.logger.error(f"Failed to pull model {model_name}: {str(e)}")
#             return {
#                 'success': False,
#                 'provider': 'Ollama',
                'error': str(e)
#             }

#     async def delete_model(self, model_name: str) -> Dict[str, Any]:
#         """
#         Delete a model from Ollama.

#         Args:
#             model_name: Name of the model to delete

#         Returns:
#             Dictionary containing deletion operation results
#         """
#         try:
            await self._ensure_session()
headers = self._prepare_request_headers()

payload = {"name": model_name}

#             async with self.session.delete(
#                 self.delete_endpoint,
json = payload,
headers = headers
#             ) as response:
#                 if response.status == 200:
#                     return {
#                         'success': True,
#                         'provider': 'Ollama',
#                         'model': model_name,
#                         'message': f"Model {model_name} deleted successfully"
#                     }
#                 else:
error_text = await response.text()
#                     return {
#                         'success': False,
#                         'provider': 'Ollama',
#                         'error': f"Failed to delete model {model_name}: {error_text}"
#                     }

#         except Exception as e:
            self.logger.error(f"Failed to delete model {model_name}: {str(e)}")
#             return {
#                 'success': False,
#                 'provider': 'Ollama',
                'error': str(e)
#             }

#     async def get_model_status(self, model_name: str) -> Dict[str, Any]:
#         """
#         Get status information for a specific model.

#         Args:
#             model_name: Name of the model

#         Returns:
#             Dictionary containing model status
#         """
#         try:
            await self._ensure_session()
headers = self._prepare_request_headers()

#             async with self.session.post(
#                 f"{self.base_url}/api/show",
json = {"name": model_name},
headers = headers
#             ) as response:
#                 if response.status == 200:
model_data = await response.json()
#                     return {
#                         'success': True,
#                         'provider': 'Ollama',
#                         'model': model_name,
#                         'status': 'available',
#                         'details': model_data
#                     }
#                 else:
#                     return {
#                         'success': False,
#                         'provider': 'Ollama',
#                         'model': model_name,
#                         'status': 'not_available'
#                     }

#         except Exception as e:
#             self.logger.error(f"Failed to get status for model {model_name}: {str(e)}")
#             return {
#                 'success': False,
#                 'provider': 'Ollama',
#                 'model': model_name,
                'error': str(e)
#             }