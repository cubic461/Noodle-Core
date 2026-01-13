# Converted from Python to NoodleCore
# Original file: src

# """
# Anthropic Adapter Module

# This module implements the adapter for Anthropic Claude provider with full API integration.
# """

import asyncio
import json
import logging
import typing.Dict
import aiohttp

import .adapter_base.(
#     AdapterBase, ChatMessage, ChatResponse, ModelInfo,
#     AdapterError, AdapterErrorCode
# )


class AnthropicAdapter(AdapterBase)
    #     """Adapter for Anthropic Claude provider with full API integration."""

    #     def __init__(self, api_key: str, base_url: Optional[str] = None, config: Optional[Dict[str, Any]] = None):""
    #         Initialize the Anthropic adapter.

    #         Args:
    #             api_key: API key for Anthropic
    #             base_url: Base URL for Anthropic API (default: https://api.anthropic.com/v1)
    #             config: Additional configuration parameters
    #         """
            super().__init__(
    #             api_key,
    #             base_url or "https://api.anthropic.com/v1",
    #             config
    #         )
    self.default_model = "claude-3-5-sonnet-20241022"
    self.messages_endpoint = f"{self.base_url}/messages"
    self.models_endpoint = f"{self.base_url}/models"

    #         # Anthropic specific settings
    #         self.max_retries = config.get('max_retries', 3) if config else 3
    #         self.retry_delay = config.get('retry_delay', 1) if config else 1
    #         self.anthropic_version = config.get('anthropic_version', '2023-06-01') if config else '2023-06-01'

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
    #         Send a chat request to Anthropic Claude.

    #         Args:
    #             messages: List of chat messages
                model: The model to use (default: claude-3-5-sonnet-20241022)
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
    payload = self._prepare_chat_payload(messages * model, temperature, max_tokens, stream,, *kwargs)

    headers = self._prepare_request_headers()
    headers['x-api-key'] = self.api_key
    headers['anthropic-version'] = self.anthropic_version

    #         try:
    #             if stream:
                    return self._stream_chat_response(payload, headers, request_id)
    #             else:
                    return await self._send_chat_request(payload, headers, request_id)

    #         except Exception as e:
                self.logger.error(f"Anthropic chat request failed: {str(e)}")
                raise self._handle_error(e)

    #     async def _send_chat_request(self, payload: Dict[str, Any], headers: Dict[str, str], request_id: str) -ChatResponse):
    #         """Send a non-streaming chat request."""
    #         async with self.session.post(
    #             self.messages_endpoint,
    json = payload,
    headers = headers
    #         ) as response:
    #             if response.status != 200:
    error_text = await response.text()
                    self.logger.error(f"Anthropic API error {response.status}: {error_text}")
                    raise AdapterError(
    #                     f"Anthropic API error: {response.status} - {error_text}",
    #                     AdapterErrorCode.PROVIDER_ERROR,
    #                     self.name
    #                 )

    response_data = await response.json()
                return self._parse_chat_response(response_data, request_id)

    #     async def _stream_chat_response(self, payload: Dict[str, Any], headers: Dict[str, str], request_id: str) -AsyncGenerator[str, None]):
    #         """Stream a chat response."""
    payload['stream'] = True

    #         async with self.session.post(
    #             self.messages_endpoint,
    json = payload,
    headers = headers
    #         ) as response:
    #             if response.status != 200:
    error_text = await response.text()
                    self.logger.error(f"Anthropic streaming API error {response.status}: {error_text}")
                    raise AdapterError(
    #                     f"Anthropic streaming API error: {response.status} - {error_text}",
    #                     AdapterErrorCode.PROVIDER_ERROR,
    #                     self.name
    #                 )

    #             async for line in response.content:
    #                 if line:
    line_str = line.decode('utf-8').strip()
    #                     if line_str.startswith('data: '):
    data_str = line_str[6:]  # Remove 'data: ' prefix
    #                         if data_str == '[DONE]':
    #                             break
    #                         try:
    data = json.loads(data_str)
    #                             if data.get('type') == 'content_block_delta':
    delta = data.get('delta', {})
    #                                 if 'text' in delta:
    #                                     yield delta['text']
    #                         except json.JSONDecodeError:
    #                             continue

    #     def _prepare_chat_payload(
    #         self,
    #         messages: List[ChatMessage],
    #         model: str,
    #         temperature: float,
    #         max_tokens: int,
    #         stream: bool,
    #         **kwargs
    #     ) -Dict[str, Any]):
    #         """Prepare the chat request payload for Anthropic API."""
    #         # Convert ChatMessage objects to Anthropic format
    #         # Anthropic expects system message separately and conversation as a list
    system_message = None
    conversation = []

    #         for msg in messages:
    #             if msg.role == 'system':
    system_message = msg.content
    #             else:
                    conversation.append({
    #                     "role": msg.role,
    #                     "content": msg.content
    #                 })

    #         # If no system message, use NoodleCore prompt
    #         if not system_message:
    system_message = self.noodlecore_system_prompt

    #         # Build the payload
    payload = {
    #             "model": model,
    #             "max_tokens": max_tokens,
    #             "temperature": temperature,
    #             "messages": conversation,
    #             "stream": stream
    #         }

    #         if system_message:
    payload["system"] = system_message

    #         # Add Anthropic specific parameters
    #         if 'top_p' in kwargs:
    payload['top_p'] = kwargs['top_p']
    #         if 'top_k' in kwargs:
    payload['top_k'] = kwargs['top_k']
    #         if 'stop_sequences' in kwargs:
    payload['stop_sequences'] = kwargs['stop_sequences']
    #         if 'metadata' in kwargs:
    payload['metadata'] = kwargs['metadata']

    #         return payload

    #     def _parse_chat_response(self, response_data: Dict[str, Any], request_id: str) -ChatResponse):
    #         """Parse the chat response from Anthropic API."""
    #         try:
    #             content = response_data['content'][0]['text'] if response_data.get('content') else ""
    usage = response_data.get('usage', {})
    stop_reason = response_data.get('stop_reason')

    #             # Map Anthropic stop reasons to standard format
    finish_reason = {
    #                 'end_turn': 'stop',
    #                 'max_tokens': 'length',
    #                 'stop_sequence': 'stop'
                }.get(stop_reason, 'stop')

                return ChatResponse(
    content = content,
    model = response_data['model'],
    usage = {
                        'prompt_tokens': usage.get('input_tokens', 0),
                        'completion_tokens': usage.get('output_tokens', 0),
                        'total_tokens': usage.get('input_tokens', 0) + usage.get('output_tokens', 0)
    #                 },
    finish_reason = finish_reason,
    request_id = request_id,
    provider = self.name
    #             )
            except (KeyError, IndexError) as e:
                raise AdapterError(
                    f"Invalid response format from Anthropic: {str(e)}",
    #                 AdapterErrorCode.RESPONSE_VALIDATION_FAILED,
    #                 self.name
    #             )

    #     async def validate_connection(self) -bool):
    #         """
    #         Validate connection to Anthropic API.

    #         Returns:
    #             True if connection is valid, False otherwise
    #         """
    #         try:
                await self._ensure_session()

    #             # Send a simple test request
    test_messages = [
    ChatMessage(role = "user", content="Hello, this is a connection test.")
    #             ]

    response = await self.chat(
    messages = test_messages,
    max_tokens = 10,
    temperature = 0.1
    #             )

                return bool(response.content)

    #         except Exception as e:
                self.logger.error(f"Anthropic connection validation failed: {str(e)}")
    #             return False

    #     async def get_model_info(self, model: str) -ModelInfo):
    #         """
    #         Get information about a specific Anthropic model.

    #         Args:
    #             model: Model name

    #         Returns:
    #             ModelInfo object
    #         """
    #         # Anthropic model information
    model_configs = {
                "claude-3-5-sonnet-20241022": ModelInfo(
    name = "claude-3-5-sonnet-20241022",
    provider = "anthropic",
    max_tokens = 4096,
    supports_streaming = True,
    supports_function_calling = True,
    input_cost_per_1k = 0.003,
    output_cost_per_1k = 0.015
    #             ),
                "claude-3-5-haiku-20241022": ModelInfo(
    name = "claude-3-5-haiku-20241022",
    provider = "anthropic",
    max_tokens = 8192,
    supports_streaming = True,
    supports_function_calling = True,
    input_cost_per_1k = 0.0008,
    output_cost_per_1k = 0.004
    #             ),
                "claude-3-opus-20240229": ModelInfo(
    name = "claude-3-opus-20240229",
    provider = "anthropic",
    max_tokens = 4096,
    supports_streaming = True,
    supports_function_calling = True,
    input_cost_per_1k = 0.015,
    output_cost_per_1k = 0.075
    #             ),
                "claude-3-sonnet-20240229": ModelInfo(
    name = "claude-3-sonnet-20240229",
    provider = "anthropic",
    max_tokens = 4096,
    supports_streaming = True,
    supports_function_calling = True,
    input_cost_per_1k = 0.003,
    output_cost_per_1k = 0.015
    #             ),
                "claude-3-haiku-20240307": ModelInfo(
    name = "claude-3-haiku-20240307",
    provider = "anthropic",
    max_tokens = 4096,
    supports_streaming = True,
    supports_function_calling = True,
    input_cost_per_1k = 0.00025,
    output_cost_per_1k = 0.00125
    #             )
    #         }

    #         if model not in model_configs:
                raise AdapterError(
    #                 f"Unknown model: {model}",
    #                 AdapterErrorCode.MODEL_NOT_AVAILABLE,
    #                 self.name
    #             )

    #         return model_configs[model]

    #     async def get_available_models(self) -List[str]):
    #         """
    #         Get list of available models from Anthropic.

    #         Returns:
    #             List of model names
    #         """
    #         return [
    #             "claude-3-5-sonnet-20241022",
    #             "claude-3-5-haiku-20241022",
    #             "claude-3-opus-20240229",
    #             "claude-3-sonnet-20240229",
    #             "claude-3-haiku-20240307"
    #         ]

    #     async def get_provider_info(self) -Dict[str, Any]):
    #         """
    #         Get information about Anthropic provider.

    #         Returns:
    #             Dictionary containing provider information
    #         """
    #         return {
    #             'name': 'Anthropic',
    #             'description': 'Anthropic Claude language model provider',
    #             'base_url': self.base_url,
    #             'default_model': self.default_model,
    #             'features': [
    #                 'code_generation',
    #                 'code_validation',
    #                 'text_completion',
    #                 'conversation',
    #                 'streaming',
    #                 'function_calling',
    #                 'analysis',
    #                 'long_context'
    #             ],
    #             'rate_limits': {
    #                 'requests_per_minute': self.rate_limiter.requests_per_minute,
    #                 'tokens_per_minute': self.rate_limiter.tokens_per_minute
    #             },
                'supported_models': await self.get_available_models(),
    #             'api_version': self.anthropic_version
    #         }

    #     def _prepare_request_headers(self) -Dict[str, str]):
    #         """
    #         Prepare Anthropic specific request headers.

    #         Returns:
    #             Dictionary of headers
    #         """
    headers = super()._prepare_request_headers()
    headers['anthropic-version'] = self.anthropic_version
    #         return headers

    #     async def _retry_request(self, request_func, *args, **kwargs) -Any):
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

    delay = self.retry_delay * (2 ** attempt)
                    self.logger.warning(f"Request failed, retrying in {delay}s: {str(e)}")
                    await asyncio.sleep(delay)

    #     def _sanitize_input(self, text: str) -str):
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

    #     async def validate_noodlecore_code(self, code: str, model: Optional[str] = None) -Dict[str, Any]):
    #         """
    #         Validate NoodleCore code using Anthropic Claude.

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
    #                 'provider': 'Anthropic',
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
    #                 'provider': 'Anthropic',
                    'error': str(e),
    #                 'is_valid': False,
                    'errors': [f"Validation failed: {str(e)}"]
    #             }

    #     async def generate_noodlecore_code(self, prompt: str, context: Optional[str] = None, model: Optional[str] = None) -Dict[str, Any]):
    #         """
    #         Generate NoodleCore code using Anthropic Claude.

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
#                 'provider': 'Anthropic',
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
#                 'provider': 'Anthropic',
                'error': str(e),
#                 'generated_code': None
#             }

#     async def analyze_code_quality(self, code: str, model: Optional[str] = None) -Dict[str, Any]):
#         """
#         Analyze code quality using Anthropic Claude's analysis capabilities.

#         Args:
#             code: Code to analyze
#             model: Specific model to use for analysis

#         Returns:
#             Dictionary containing quality analysis results
#         """
#         try:
sanitized_code = self._sanitize_input(code)

analysis_messages = [
                ChatMessage(
role = "user",
content = f"""Analyze the quality of this NoodleCore (.nc-code) from multiple perspectives:

# ```
# {sanitized_code}
# ```

# Please evaluate:
# 1. Code readability and maintainability
# 2. Performance considerations
# 3. Security best practices
# 4. Architectural patterns adherence
# 5. Error handling robustness
# 6. Documentation quality

# Provide specific scores (1-10) for each category and overall recommendations."""
#                 )
#             ]

response = await self.chat(
messages = analysis_messages,
model = model,
temperature = 0.2,
max_tokens = 2500
#             )

#             return {
#                 'success': True,
#                 'provider': 'Anthropic',
#                 'model': response.model,
                'code_length': len(code),
#                 'analysis_result': response.content,
#                 'usage': response.usage,
#                 'request_id': response.request_id
#             }

#         except Exception as e:
            self.logger.error(f"Code quality analysis failed: {str(e)}")
#             return {
#                 'success': False,
#                 'provider': 'Anthropic',
                'error': str(e),
#                 'analysis_result': None
#             }