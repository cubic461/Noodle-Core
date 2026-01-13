# Converted from Python to NoodleCore
# Original file: src

# """
# OpenAI Adapter Module

# This module implements the adapter for OpenAI GPT provider with full API integration.
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


class OpenAIAdapter(AdapterBase)
    #     """Adapter for OpenAI GPT provider with full API integration."""

    #     def __init__(self, api_key: str, base_url: Optional[str] = None, config: Optional[Dict[str, Any]] = None):""
    #         Initialize the OpenAI adapter.

    #         Args:
    #             api_key: API key for OpenAI
    #             base_url: Base URL for OpenAI API (default: https://api.openai.com/v1)
    #             config: Additional configuration parameters
    #         """
            super().__init__(
    #             api_key,
    #             base_url or "https://api.openai.com/v1",
    #             config
    #         )
    self.default_model = "gpt-4"
    self.chat_endpoint = f"{self.base_url}/chat/completions"
    self.models_endpoint = f"{self.base_url}/models"

    #         # OpenAI specific settings
    #         self.max_retries = config.get('max_retries', 3) if config else 3
    #         self.retry_delay = config.get('retry_delay', 1) if config else 1
    #         self.organization = config.get('organization') if config else None

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
    #         Send a chat request to OpenAI GPT.

    #         Args:
    #             messages: List of chat messages
                model: The model to use (default: gpt-4)
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
    headers['Authorization'] = f'Bearer {self.api_key}'

    #         try:
    #             if stream:
                    return self._stream_chat_response(payload, headers, request_id)
    #             else:
                    return await self._send_chat_request(payload, headers, request_id)

    #         except Exception as e:
                self.logger.error(f"OpenAI chat request failed: {str(e)}")
                raise self._handle_error(e)

    #     async def _send_chat_request(self, payload: Dict[str, Any], headers: Dict[str, str], request_id: str) -ChatResponse):
    #         """Send a non-streaming chat request."""
    #         async with self.session.post(
    #             self.chat_endpoint,
    json = payload,
    headers = headers
    #         ) as response:
    #             if response.status != 200:
    error_text = await response.text()
                    self.logger.error(f"OpenAI API error {response.status}: {error_text}")
                    raise AdapterError(
    #                     f"OpenAI API error: {response.status} - {error_text}",
    #                     AdapterErrorCode.PROVIDER_ERROR,
    #                     self.name
    #                 )

    response_data = await response.json()
                return self._parse_chat_response(response_data, request_id)

    #     async def _stream_chat_response(self, payload: Dict[str, Any], headers: Dict[str, str], request_id: str) -AsyncGenerator[str, None]):
    #         """Stream a chat response."""
    payload['stream'] = True

    #         async with self.session.post(
    #             self.chat_endpoint,
    json = payload,
    headers = headers
    #         ) as response:
    #             if response.status != 200:
    error_text = await response.text()
                    self.logger.error(f"OpenAI streaming API error {response.status}: {error_text}")
                    raise AdapterError(
    #                     f"OpenAI streaming API error: {response.status} - {error_text}",
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
    #                             if 'choices' in data and data['choices']:
    delta = data['choices'][0].get('delta', {})
    #                                 if 'content' in delta:
    #                                     yield delta['content']
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
    #         """Prepare the chat request payload for OpenAI API."""
    #         # Convert ChatMessage objects to dict format
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
    #             "temperature": temperature,
    #             "max_tokens": max_tokens,
    #             "stream": stream,
                "top_p": kwargs.get('top_p', 1.0),
                "frequency_penalty": kwargs.get('frequency_penalty', 0.0),
                "presence_penalty": kwargs.get('presence_penalty', 0.0)
    #         }

    #         # Add OpenAI specific parameters
    #         if 'logit_bias' in kwargs:
    payload['logit_bias'] = kwargs['logit_bias']
    #         if 'logprobs' in kwargs:
    payload['logprobs'] = kwargs['logprobs']
    #         if 'top_logprobs' in kwargs:
    payload['top_logprobs'] = kwargs['top_logprobs']
    #         if 'stop' in kwargs:
    payload['stop'] = kwargs['stop']
    #         if 'user' in kwargs:
    payload['user'] = kwargs['user']
    #         if 'functions' in kwargs:
    payload['functions'] = kwargs['functions']
    #         if 'function_call' in kwargs:
    payload['function_call'] = kwargs['function_call']
    #         if 'tools' in kwargs:
    payload['tools'] = kwargs['tools']
    #         if 'tool_choice' in kwargs:
    payload['tool_choice'] = kwargs['tool_choice']
    #         if 'response_format' in kwargs:
    payload['response_format'] = kwargs['response_format']

    #         return payload

    #     def _parse_chat_response(self, response_data: Dict[str, Any], request_id: str) -ChatResponse):
    #         """Parse the chat response from OpenAI API."""
    #         try:
    choice = response_data['choices'][0]
    message = choice['message']
    usage = response_data.get('usage', {})

                return ChatResponse(
    content = message['content'],
    model = response_data['model'],
    usage = {
                        'prompt_tokens': usage.get('prompt_tokens', 0),
                        'completion_tokens': usage.get('completion_tokens', 0),
                        'total_tokens': usage.get('total_tokens', 0)
    #                 },
    finish_reason = choice.get('finish_reason'),
    request_id = request_id,
    provider = self.name
    #             )
            except (KeyError, IndexError) as e:
                raise AdapterError(
                    f"Invalid response format from OpenAI: {str(e)}",
    #                 AdapterErrorCode.RESPONSE_VALIDATION_FAILED,
    #                 self.name
    #             )

    #     async def validate_connection(self) -bool):
    #         """
    #         Validate connection to OpenAI API.

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
                self.logger.error(f"OpenAI connection validation failed: {str(e)}")
    #             return False

    #     async def get_model_info(self, model: str) -ModelInfo):
    #         """
    #         Get information about a specific OpenAI model.

    #         Args:
    #             model: Model name

    #         Returns:
    #             ModelInfo object
    #         """
    #         # OpenAI model information
    model_configs = {
                "gpt-4": ModelInfo(
    name = "gpt-4",
    provider = "openai",
    max_tokens = 4096,
    supports_streaming = True,
    supports_function_calling = True,
    input_cost_per_1k = 0.03,
    output_cost_per_1k = 0.06
    #             ),
                "gpt-4-turbo": ModelInfo(
    name = "gpt-4-turbo",
    provider = "openai",
    max_tokens = 4096,
    supports_streaming = True,
    supports_function_calling = True,
    input_cost_per_1k = 0.01,
    output_cost_per_1k = 0.03
    #             ),
                "gpt-4-turbo-preview": ModelInfo(
    name = "gpt-4-turbo-preview",
    provider = "openai",
    max_tokens = 4096,
    supports_streaming = True,
    supports_function_calling = True,
    input_cost_per_1k = 0.01,
    output_cost_per_1k = 0.03
    #             ),
                "gpt-3.5-turbo": ModelInfo(
    name = "gpt-3.5-turbo",
    provider = "openai",
    max_tokens = 4096,
    supports_streaming = True,
    supports_function_calling = True,
    input_cost_per_1k = 0.0005,
    output_cost_per_1k = 0.0015
    #             ),
                "gpt-3.5-turbo-16k": ModelInfo(
    name = "gpt-3.5-turbo-16k",
    provider = "openai",
    max_tokens = 16384,
    supports_streaming = True,
    supports_function_calling = True,
    input_cost_per_1k = 0.003,
    output_cost_per_1k = 0.004
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
    #         Get list of available models from OpenAI.

    #         Returns:
    #             List of model names
    #         """
    #         try:
                await self._ensure_session()
    headers = self._prepare_request_headers()
    headers['Authorization'] = f'Bearer {self.api_key}'

    #             async with self.session.get(self.models_endpoint, headers=headers) as response:
    #                 if response.status = 200:
    data = await response.json()
    #                     # Filter for chat models
    chat_models = [
    #                         model['id'] for model in data.get('data', [])
    #                         if 'gpt' in model['id'] and ('chat' in model.get('object', '') or 'turbo' in model['id'])
    #                     ]
    #                     return chat_models
    #                 else:
                        self.logger.warning(f"Failed to fetch models from OpenAI: {response.status}")
    #                     # Return fallback list
    #                     return [
    #                         "gpt-4",
    #                         "gpt-4-turbo",
    #                         "gpt-4-turbo-preview",
    #                         "gpt-3.5-turbo",
    #                         "gpt-3.5-turbo-16k"
    #                     ]
    #         except Exception as e:
                self.logger.error(f"Error fetching OpenAI models: {str(e)}")
    #             # Return fallback list
    #             return [
    #                 "gpt-4",
    #                 "gpt-4-turbo",
    #                 "gpt-4-turbo-preview",
    #                 "gpt-3.5-turbo",
    #                 "gpt-3.5-turbo-16k"
    #             ]

    #     async def get_provider_info(self) -Dict[str, Any]):
    #         """
    #         Get information about OpenAI provider.

    #         Returns:
    #             Dictionary containing provider information
    #         """
    #         return {
    #             'name': 'OpenAI',
    #             'description': 'OpenAI GPT language model provider',
    #             'base_url': self.base_url,
    #             'default_model': self.default_model,
    #             'features': [
    #                 'code_generation',
    #                 'code_validation',
    #                 'text_completion',
    #                 'conversation',
    #                 'streaming',
    #                 'function_calling',
    #                 'json_mode',
    #                 'vision'
    #             ],
    #             'rate_limits': {
    #                 'requests_per_minute': self.rate_limiter.requests_per_minute,
    #                 'tokens_per_minute': self.rate_limiter.tokens_per_minute
    #             },
                'supported_models': await self.get_available_models(),
    #             'organization': self.organization,
    #             'api_version': 'v1'
    #         }

    #     def _prepare_request_headers(self) -Dict[str, str]):
    #         """
    #         Prepare OpenAI specific request headers.

    #         Returns:
    #             Dictionary of headers
    #         """
    headers = super()._prepare_request_headers()
    #         if self.organization:
    headers['OpenAI-Organization'] = self.organization
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
    #         Validate NoodleCore code using OpenAI GPT.

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
    #                 'provider': 'OpenAI',
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
    #                 'provider': 'OpenAI',
                    'error': str(e),
    #                 'is_valid': False,
                    'errors': [f"Validation failed: {str(e)}"]
    #             }

    #     async def generate_noodlecore_code(self, prompt: str, context: Optional[str] = None, model: Optional[str] = None) -Dict[str, Any]):
    #         """
    #         Generate NoodleCore code using OpenAI GPT.

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
#                 'provider': 'OpenAI',
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
#                 'provider': 'OpenAI',
                'error': str(e),
#                 'generated_code': None
#             }

#     async def generate_structured_response(
#         self,
#         prompt: str,
#         schema: Dict[str, Any],
model: Optional[str] = None
#     ) -Dict[str, Any]):
#         """
#         Generate a structured JSON response using OpenAI's JSON mode.

#         Args:
#             prompt: Prompt for generating structured response
#             schema: JSON schema for the response format
#             model: Specific model to use

#         Returns:
#             Dictionary containing structured response and metadata
#         """
#         try:
sanitized_prompt = self._sanitize_input(prompt)

messages = [
ChatMessage(role = "system", content=self.noodlecore_system_prompt),
ChatMessage(role = "user", content=sanitized_prompt)
#             ]

response = await self.chat(
messages = messages,
model = model,
temperature = 0.1,
max_tokens = 2000,
response_format = {"type": "json_object", "schema": schema}
#             )

#             # Try to parse the JSON response
#             try:
structured_data = json.loads(response.content)
#             except json.JSONDecodeError:
structured_data = {"error": "Failed to parse JSON response", "raw_content": response.content}

#             return {
#                 'success': True,
#                 'provider': 'OpenAI',
#                 'model': response.model,
#                 'structured_data': structured_data,
                'prompt_length': len(prompt),
#                 'usage': response.usage,
#                 'request_id': response.request_id
#             }

#         except Exception as e:
            self.logger.error(f"Structured response generation failed: {str(e)}")
#             return {
#                 'success': False,
#                 'provider': 'OpenAI',
                'error': str(e),
#                 'structured_data': None
#             }