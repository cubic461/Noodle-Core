# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# NoodleCore AI Client for TRM Agent Integration

# This module provides AI client functionality for the TRM agent and other
# AI components in the NoodleCore ecosystem.
# """

import json
import asyncio
import aiohttp
import logging
import typing.Dict,
import dataclasses.dataclass
import uuid
import time

# @dataclass
class AIRequest
    #     """AI request structure."""
    #     command_id: str
    #     context: Dict[str, Any]
    #     provider_id: str
    #     role_id: str
    request_id: str = None

    #     def __post_init__(self):
    #         if not self.request_id:
    self.request_id = str(uuid.uuid4())

# @dataclass
class AIResponse
    #     """AI response structure."""
    #     ok: bool
    content: Optional[str] = None
    error: Optional[str] = None
    request_id: str = None
    metadata: Optional[Dict[str, Any]] = None

class NoodleCoreAIClient
    #     """AI Client for NoodleCore with Z.ai integration."""

    #     def __init__(self, providers: Dict[str, Any], roles: Dict[str, Any]):
    self.providers = providers
    self.roles = roles
    self.logger = logging.getLogger(__name__)
    self.session = None

    #     async def invoke(self, command_id: str, context: Dict[str, Any],
    provider_id: str = "zai", role_id: str = "default") -> AIResponse:
    #         """Invoke AI command with specified context."""
    request = AIRequest(
    command_id = command_id,
    context = context,
    provider_id = provider_id,
    role_id = role_id
    #         )

    start_time = time.time()

    #         try:
    #             # Get provider configuration
    provider_config = self.providers.get(provider_id)
    #             if not provider_config:
                    return AIResponse(
    ok = False,
    error = f"Provider '{provider_id}' not found",
    request_id = request.request_id
    #                 )

    #             # Get role configuration
    role_config = self.roles.get(role_id, {})
    system_prompt = role_config.get('system_prompt', 'You are a helpful AI assistant.')

    #             # Prepare API request
    headers = {
                    "Authorization": f"Bearer {provider_config.get('api_key', '')}",
    #                 "Content-Type": "application/json",
    #                 "HTTP-Referer": "https://noodlecore-ide.com",
    #                 "X-Title": "NoodleCore IDE"
    #             }

    #             # Build request payload
    payload = {
                    "model": provider_config.get('model', 'glm-4.6'),
    #                 "messages": [
    #                     {"role": "system", "content": system_prompt},
                        {"role": "user", "content": self._build_user_prompt(context, command_id)}
    #                 ],
    #                 "max_tokens": 2000,
    #                 "temperature": 0.7
    #             }

    #             # Make API call
    api_url = provider_config.get('base_url', 'https://open.bigmodel.cn/api/paas/v4')

    #             async with aiohttp.ClientSession() as session:
    #                 async with session.post(api_url, json=payload, headers=headers) as response:
    #                     if response.status == 200:
    result = await response.json()
                            return AIResponse(
    ok = True,
    content = result.get('choices', [{}])[0].get('message', ''),
    request_id = request.request_id,
    metadata = {
    #                                 'provider': provider_id,
    #                                 'model': payload['model'],
                                    'response_time': time.time() - start_time
    #                             }
    #                         )
    #                     else:
    error_text = await response.text()
                            return AIResponse(
    ok = False,
    error = f"API error: {response.status} - {error_text}",
    request_id = request.request_id
    #                         )

    #         except Exception as e:
                self.logger.error(f"AI invocation failed: {e}")
                return AIResponse(
    ok = False,
    error = f"Request failed: {str(e)}",
    request_id = request.request_id
    #             )

    #     def _build_user_prompt(self, context: Dict[str, Any], command_id: str) -> str:
    #         """Build user prompt based on context and command."""
    #         # Extract relevant context information
    context_str = json.dumps(context, indent=2)

    #         # Build command-specific prompt
    #         if command_id == "optimize_code":
    #             return f"""Please analyze and optimize the following code:

# Context:
# {context_str}

# Focus on:
# 1. Performance improvements
# 2. Code quality and readability
# 3. Best practices adherence
# 4. Security considerations
# 5. NoodleCore compliance

# Provide specific, actionable recommendations with code examples where applicable."""
#         else:
#             return f"""Please help with the following task:

# Context:
# {context_str}

# Task: {command_id}

# Provide helpful assistance and suggestions."""

#     async def get_available_models(self, provider_id: str = "zai") -> List[str]:
#         """Get available models from provider."""
#         try:
provider_config = self.providers.get(provider_id)
#             if not provider_config:
#                 return []

headers = {
                "Authorization": f"Bearer {provider_config.get('api_key', '')}",
#                 "Content-Type": "application/json"
#             }

api_url = provider_config.get('base_url', 'https://open.bigmodel.cn/api/paas/v4')

#             async with aiohttp.ClientSession() as session:
#                 async with session.get(f"{api_url}/models", headers=headers) as response:
#                     if response.status == 200:
result = await response.json()
#                         models = [model['id'] for model in result.get('data', [])]
                        return sorted(models)
#                     else:
                        self.logger.warning(f"Failed to get models from {provider_id}: {response.status}")
#                         return []

#         except Exception as e:
            self.logger.error(f"Error getting models: {e}")
#             return []

#     def close(self):
#         """Close the AI client session."""
#         if self.session:
            asyncio.create_task(self.session.close())
self.session = None