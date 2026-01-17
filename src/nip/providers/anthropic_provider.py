"""
NIP v3.0.0 - Anthropic Claude Provider
Anthropic Claude API integration (Claude 3 Opus, Sonnet, Haiku)
"""

import asyncio
from typing import List, Iterator, AsyncIterator, Dict, Optional
import logging

try:
    import anthropic
    from anthropic import Anthropic, AsyncAnthropic
    ANTHROPIC_AVAILABLE = True
except ImportError:
    ANTHROPIC_AVAILABLE = False

from .base_provider import (
    BaseProvider, ProviderConfig, Message, MessageRole,
    CompletionResponse, StreamChunk, EmbeddingResponse,
    ProviderError, RateLimitError, AuthenticationError
)

logger = logging.getLogger(__name__)


class AnthropicProvider(BaseProvider):
    """
    Anthropic Claude API provider.
    
    Supported models:
    - claude-3-5-sonnet-20241022 (Latest Sonnet)
    - claude-3-5-sonnet-20240620
    - claude-3-opus-20240229
    - claude-3-sonnet-20240229
    - claude-3-haiku-20240307
    
    Features:
    - Streaming support
    - Async support
    - Vision support (images)
    - Tool use/function calling
    - System messages
    """
    
    DEFAULT_MODELS = {
        "opus": "claude-3-opus-20240229",
        "sonnet": "claude-3-5-sonnet-20241022",
        "haiku": "claude-3-haiku-20240307",
    }
    
    MODEL_INFO = {
        "claude-3-opus-20240229": {
            "context_window": 200000,
            "max_output": 4096,
            "input_price": 15.0,  # per million tokens
            "output_price": 75.0,
            "supports_vision": True,
            "supports_tools": True,
        },
        "claude-3-5-sonnet-20241022": {
            "context_window": 200000,
            "max_output": 8192,
            "input_price": 3.0,
            "output_price": 15.0,
            "supports_vision": True,
            "supports_tools": True,
        },
        "claude-3-haiku-20240307": {
            "context_window": 200000,
            "max_output": 4096,
            "input_price": 0.25,
            "output_price": 1.25,
            "supports_vision": True,
            "supports_tools": False,
        },
    }
    
    def __init__(self, config: ProviderConfig):
        """
        Initialize Anthropic provider.
        
        Args:
            config: Provider configuration with api_key required
        """
        super().__init__(config)
        
        if not ANTHROPIC_AVAILABLE:
            raise ImportError(
                "anthropic package is required. "
                "Install with: pip install anthropic"
            )
        
        if not self.validate_api_key():
            raise AuthenticationError(
                "Invalid Anthropic API key. Get one at: https://console.anthropic.com/",
                "anthropic"
            )
        
        # Initialize clients
        self.client = Anthropic(
            api_key=config.api_key,
            timeout=config.timeout,
            max_retries=config.max_retries,
        )
        
        self.async_client = AsyncAnthropic(
            api_key=config.api_key,
            timeout=config.timeout,
            max_retries=config.max_retries,
        )
        
        # Set default model if not specified
        if not config.model:
            config.model = self.DEFAULT_MODELS["sonnet"]
    
    def _convert_messages(self, messages: List[Message]) -> List[Dict]:
        """Convert NIP messages to Anthropic format"""
        anthropic_messages = []
        system_message = None
        
        for msg in messages:
            if msg.role == MessageRole.SYSTEM:
                system_message = msg.content
            elif msg.role == MessageRole.USER:
                anthropic_messages.append({
                    "role": "user",
                    "content": msg.content
                })
            elif msg.role == MessageRole.ASSISTANT:
                anthropic_messages.append({
                    "role": "assistant",
                    "content": msg.content
                })
        
        return anthropic_messages, system_message
    
    def complete(
        self,
        messages: List[Message],
        **kwargs
    ) -> CompletionResponse:
        """
        Generate a completion using Anthropic Claude.
        
        Args:
            messages: List of messages in the conversation
            **kwargs: Additional parameters (temperature, max_tokens, etc.)
            
        Returns:
            CompletionResponse with generated content
        """
        try:
            anthropic_messages, system_message = self._convert_messages(messages)
            
            params = {
                "model": kwargs.get("model", self.config.model),
                "messages": anthropic_messages,
                "max_tokens": kwargs.get("max_tokens", self.config.max_tokens or 4096),
                "temperature": kwargs.get("temperature", self.config.temperature),
            }
            
            if system_message:
                params["system"] = system_message
            
            # Execute with retry
            response = self._retry_with_backoff(
                self.client.messages.create,
                **params
            )
            
            # Extract usage
            usage = {
                "prompt_tokens": response.usage.input_tokens,
                "completion_tokens": response.usage.output_tokens,
                "total_tokens": response.usage.input_tokens + response.usage.output_tokens,
            }
            
            return CompletionResponse(
                content=response.content[0].text,
                model=response.model,
                finish_reason=response.stop_reason,
                usage=usage,
                metadata={
                    "id": response.id,
                    "type": response.type,
                }
            )
            
        except anthropic.errors.AuthenticationError as e:
            raise AuthenticationError(str(e), "anthropic")
        except anthropic.errors.RateLimitError as e:
            raise RateLimitError(str(e), "anthropic")
        except anthropic.errors.APIError as e:
            raise ProviderError(str(e), "anthropic", e.status_code)
        except Exception as e:
            raise ProviderError(f"Unexpected error: {str(e)}", "anthropic")
    
    async def acomplete(
        self,
        messages: List[Message],
        **kwargs
    ) -> CompletionResponse:
        """Async version of complete()"""
        try:
            anthropic_messages, system_message = self._convert_messages(messages)
            
            params = {
                "model": kwargs.get("model", self.config.model),
                "messages": anthropic_messages,
                "max_tokens": kwargs.get("max_tokens", self.config.max_tokens or 4096),
                "temperature": kwargs.get("temperature", self.config.temperature),
            }
            
            if system_message:
                params["system"] = system_message
            
            response = await self.async_client.messages.create(**params)
            
            usage = {
                "prompt_tokens": response.usage.input_tokens,
                "completion_tokens": response.usage.output_tokens,
                "total_tokens": response.usage.input_tokens + response.usage.output_tokens,
            }
            
            return CompletionResponse(
                content=response.content[0].text,
                model=response.model,
                finish_reason=response.stop_reason,
                usage=usage,
                metadata={"id": response.id, "type": response.type}
            )
            
        except anthropic.errors.AuthenticationError as e:
            raise AuthenticationError(str(e), "anthropic")
        except anthropic.errors.RateLimitError as e:
            raise RateLimitError(str(e), "anthropic")
        except Exception as e:
            raise ProviderError(f"Unexpected error: {str(e)}", "anthropic")
    
    def stream_complete(
        self,
        messages: List[Message],
        **kwargs
    ) -> Iterator[StreamChunk]:
        """
        Stream completion responses from Anthropic Claude.
        
        Yields:
            StreamChunk objects with partial content
        """
        try:
            anthropic_messages, system_message = self._convert_messages(messages)
            
            params = {
                "model": kwargs.get("model", self.config.model),
                "messages": anthropic_messages,
                "max_tokens": kwargs.get("max_tokens", self.config.max_tokens or 4096),
                "temperature": kwargs.get("temperature", self.config.temperature),
                "stream": True,
            }
            
            if system_message:
                params["system"] = system_message
            
            with self.client.messages.stream(**params) as stream:
                for event in stream:
                    if event.type == "content_block_delta":
                        yield StreamChunk(content=event.delta.text)
                    elif event.type == "message_stop":
                        # Get final usage
                        if hasattr(event, 'message') and event.message.usage:
                            yield StreamChunk(
                                content="",
                                finish_reason="stop",
                                usage={
                                    "prompt_tokens": event.message.usage.input_tokens,
                                    "completion_tokens": event.message.usage.output_tokens,
                                    "total_tokens": (
                                        event.message.usage.input_tokens + 
                                        event.message.usage.output_tokens
                                    ),
                                }
                            )
                        else:
                            yield StreamChunk(content="", finish_reason="stop")
                            
        except anthropic.errors.AuthenticationError as e:
            raise AuthenticationError(str(e), "anthropic")
        except anthropic.errors.RateLimitError as e:
            raise RateLimitError(str(e), "anthropic")
        except Exception as e:
            raise ProviderError(f"Streaming error: {str(e)}", "anthropic")
    
    async def astream_complete(
        self,
        messages: List[Message],
        **kwargs
    ) -> AsyncIterator[StreamChunk]:
        """Async version of stream_complete()"""
        try:
            anthropic_messages, system_message = self._convert_messages(messages)
            
            params = {
                "model": kwargs.get("model", self.config.model),
                "messages": anthropic_messages,
                "max_tokens": kwargs.get("max_tokens", self.config.max_tokens or 4096),
                "temperature": kwargs.get("temperature", self.config.temperature),
                "stream": True,
            }
            
            if system_message:
                params["system"] = system_message
            
            async with await self.async_client.messages.stream(**params) as stream:
                async for event in stream:
                    if event.type == "content_block_delta":
                        yield StreamChunk(content=event.delta.text)
                    elif event.type == "message_stop":
                        yield StreamChunk(content="", finish_reason="stop")
                        
        except Exception as e:
            raise ProviderError(f"Async streaming error: {str(e)}", "anthropic")
    
    def count_tokens(self, text: str) -> int:
        """
        Count tokens using Anthropic's tokenizer.
        
        Args:
            text: Text to count tokens for
            
        Returns:
            Token count
        """
        try:
            # Use Anthropic's tokenizer if available
            return self.client.count_tokens(text)
        except Exception:
            # Fallback to approximation
            return super().count_tokens(text)
    
    def get_model_info(self) -> Dict:
        """Get information about available models"""
        return {
            "provider": "anthropic",
            "model": self.config.model,
            "supports_streaming": True,
            "supports_embeddings": False,
            "supports_async": True,
            "supports_vision": True,
            "supports_tools": True,
            "available_models": list(self.DEFAULT_MODELS.values()),
            "model_details": self.MODEL_INFO.get(self.config.model, {}),
        }


# Convenience function for quick initialization
def create_anthropic_provider(
    api_key: str,
    model: str = "claude-3-5-sonnet-20241022",
    **kwargs
) -> AnthropicProvider:
    """
    Create an Anthropic provider with common defaults.
    
    Args:
        api_key: Anthropic API key
        model: Model name (default: claude-3-5-sonnet-20241022)
        **kwargs: Additional config parameters
        
    Returns:
        Configured AnthropicProvider instance
    """
    config = ProviderConfig(
        api_key=api_key,
        model=model,
        **kwargs
    )
    return AnthropicProvider(config)
