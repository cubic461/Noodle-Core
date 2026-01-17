"""
NIP v3.0.0 - Mistral AI Provider
Mistral AI API integration (Mistral Large, Medium, 7B, 8x7B, Codestral)
"""

from collections.abc import Iterator, AsyncIterator
import logging

try:
    from mistralai.client import MistralClient
    from mistralai.async_client import MistralAsyncClient
    from mistralai.models.chat_completion import ChatMessage
    MISTRAL_AVAILABLE = True
except ImportError:
    MISTRAL_AVAILABLE = False

from .base_provider import (
    BaseProvider, ProviderConfig, Message, MessageRole,
    CompletionResponse, StreamChunk, EmbeddingResponse,
    ProviderError, RateLimitError, AuthenticationError
)

logger = logging.getLogger(__name__)


class MistralProvider(BaseProvider):
    """
    Mistral AI API provider.

    Supported models:
    - mistral-large-latest (Latest Mistral Large)
    - mistral-medium-latest
    - mistral-small-latest
    - codestral-latest (Code-specialized)
    - mistral-7b, mistral-8x7b (Open weights)
    - open-mistral-7b, open-mixtral-8x7b

    Features:
    - Streaming support
    - Async support
    - Function calling
    - JSON mode
    - Code generation (Codestral)
    - Multi-language support
    """

    DEFAULT_MODELS = {
        "large": "mistral-large-latest",
        "medium": "mistral-medium-latest",
        "small": "mistral-small-latest",
        "codestral": "codestral-latest",
        "7b": "open-mistral-7b",
        "8x7b": "open-mixtral-8x7b",
    }

    MODEL_INFO = {
        "mistral-large-latest": {
            "context_window": 128000,
            "max_output": 8192,
            "input_price": 4.0,  # per million tokens
            "output_price": 12.0,
            "supports_function_calling": True,
            "supports_json_mode": True,
        },
        "mistral-medium-latest": {
            "context_window": 32000,
            "max_output": 4096,
            "input_price": 2.50,
            "output_price": 7.0,
            "supports_function_calling": True,
            "supports_json_mode": True,
        },
        "mistral-small-latest": {
            "context_window": 32000,
            "max_output": 4096,
            "input_price": 1.0,
            "output_price": 3.0,
            "supports_function_calling": True,
            "supports_json_mode": True,
        },
        "codestral-latest": {
            "context_window": 32000,
            "max_output": 4096,
            "input_price": 1.0,
            "output_price": 3.0,
            "supports_function_calling": True,
            "supports_json_mode": True,
            "code_specialized": True,
        },
        "open-mistral-7b": {
            "context_window": 32000,
            "max_output": 4096,
            "input_price": 0.25,
            "output_price": 0.25,
            "supports_function_calling": False,
            "supports_json_mode": False,
        },
        "open-mixtral-8x7b": {
            "context_window": 32000,
            "max_output": 4096,
            "input_price": 0.70,
            "output_price": 0.70,
            "supports_function_calling": False,
            "supports_json_mode": False,
        },
    }

    EMBEDDING_MODELS = {
        "embed": "mistral-embed",
    }

    def __init__(self, config: ProviderConfig):
        """
        Initialize Mistral provider.

        Args:
            config: Provider configuration with api_key required
        """
        super().__init__(config)

        if not MISTRAL_AVAILABLE:
            raise ImportError(
                "mistralai package is required. "
                "Install with: pip install mistralai"
            )

        if not self.validate_api_key():
            raise AuthenticationError(
                "Invalid Mistral API key. Get one at: https://console.mistral.ai/",
                "mistral"
            )

        # Initialize clients
        self.client = MistralClient(
            api_key=config.api_key,
            timeout=config.timeout,
        )

        self.async_client = MistralAsyncClient(
            api_key=config.api_key,
            timeout=config.timeout,
        )

        # Set default model if not specified
        if not config.model:
            config.model = self.DEFAULT_MODELS["medium"]

    def _convert_messages(self, messages: list[Message]) -> list[ChatMessage]:
        """Convert NIP messages to Mistral format"""
        mistral_messages = []

        for msg in messages:
            if msg.role == MessageRole.SYSTEM:
                mistral_messages.append(ChatMessage(role="system", content=msg.content))
            elif msg.role == MessageRole.USER:
                mistral_messages.append(ChatMessage(role="user", content=msg.content))
            elif msg.role == MessageRole.ASSISTANT:
                mistral_messages.append(ChatMessage(role="assistant", content=msg.content))
            elif msg.role == MessageRole.TOOL:
                mistral_messages.append(ChatMessage(role="tool", content=msg.content))

        return mistral_messages

    def complete(
        self,
        messages: list[Message],
        **kwargs
    ) -> CompletionResponse:
        """
        Generate a completion using Mistral.

        Args:
            messages: List of messages in the conversation
            **kwargs: Additional parameters

        Returns:
            CompletionResponse with generated content
        """
        try:
            mistral_messages = self._convert_messages(messages)

            params = {
                "model": kwargs.get("model", self.config.model),
                "messages": mistral_messages,
                "temperature": kwargs.get("temperature", self.config.temperature),
                "max_tokens": kwargs.get("max_tokens", self.config.max_tokens or 4096),
                "top_p": kwargs.get("top_p", 1.0),
            }

            # Add optional parameters
            if "tools" in kwargs:
                params["tools"] = kwargs["tools"]
            if "tool_choice" in kwargs:
                params["tool_choice"] = kwargs["tool_choice"]
            if "response_format" in kwargs:
                params["response_format"] = kwargs["response_format"]

            response = self._retry_with_backoff(
                self.client.chat,
                **params
            )

            content = response.choices[0].message.content or ""

            usage = {
                "prompt_tokens": response.usage.prompt_tokens,
                "completion_tokens": response.usage.completion_tokens,
                "total_tokens": response.usage.total_tokens,
            }

            return CompletionResponse(
                content=content,
                model=response.model,
                finish_reason=response.choices[0].finish_reason,
                usage=usage,
                metadata={
                    "id": response.id,
                    "created": response.created,
                }
            )

        except Exception as e:
            error_msg = str(e)
            if "authentication" in error_msg.lower():
                raise AuthenticationError(error_msg, "mistral")
            elif "rate limit" in error_msg.lower():
                raise RateLimitError(error_msg, "mistral")
            else:
                raise ProviderError(f"Unexpected error: {error_msg}", "mistral")

    async def acomplete(
        self,
        messages: list[Message],
        **kwargs
    ) -> CompletionResponse:
        """Async version of complete()"""
        try:
            mistral_messages = self._convert_messages(messages)

            params = {
                "model": kwargs.get("model", self.config.model),
                "messages": mistral_messages,
                "temperature": kwargs.get("temperature", self.config.temperature),
                "max_tokens": kwargs.get("max_tokens", self.config.max_tokens or 4096),
            }

            response = await self.async_client.chat(**params)

            content = response.choices[0].message.content or ""

            usage = {
                "prompt_tokens": response.usage.prompt_tokens,
                "completion_tokens": response.usage.completion_tokens,
                "total_tokens": response.usage.total_tokens,
            }

            return CompletionResponse(
                content=content,
                model=response.model,
                finish_reason=response.choices[0].finish_reason,
                usage=usage,
                metadata={"id": response.id, "created": response.created}
            )

        except Exception as e:
            raise ProviderError(f"Async error: {str(e)}", "mistral")

    def stream_complete(
        self,
        messages: list[Message],
        **kwargs
    ) -> Iterator[StreamChunk]:
        """
        Stream completion responses from Mistral.

        Yields:
            StreamChunk objects with partial content
        """
        try:
            mistral_messages = self._convert_messages(messages)

            params = {
                "model": kwargs.get("model", self.config.model),
                "messages": mistral_messages,
                "temperature": kwargs.get("temperature", self.config.temperature),
                "max_tokens": kwargs.get("max_tokens", self.config.max_tokens or 4096),
                "stream": True,
            }

            stream = self.client.chat_stream(**params)

            for chunk in stream:
                if chunk.choices and chunk.choices[0].delta.content:
                    yield StreamChunk(content=chunk.choices[0].delta.content)

                if chunk.choices and chunk.choices[0].finish_reason:
                    yield StreamChunk(
                        content="",
                        finish_reason=chunk.choices[0].finish_reason,
                        usage={
                            "prompt_tokens": chunk.usage.prompt_tokens,
                            "completion_tokens": chunk.usage.completion_tokens,
                            "total_tokens": chunk.usage.total_tokens,
                        } if chunk.usage else None
                    )

        except Exception as e:
            raise ProviderError(f"Streaming error: {str(e)}", "mistral")

    async def astream_complete(
        self,
        messages: list[Message],
        **kwargs
    ) -> AsyncIterator[StreamChunk]:
        """Async version of stream_complete()"""
        try:
            mistral_messages = self._convert_messages(messages)

            params = {
                "model": kwargs.get("model", self.config.model),
                "messages": mistral_messages,
                "temperature": kwargs.get("temperature", self.config.temperature),
                "max_tokens": kwargs.get("max_tokens", self.config.max_tokens or 4096),
                "stream": True,
            }

            stream = await self.async_client.chat_stream(**params)

            async for chunk in stream:
                if chunk.choices and chunk.choices[0].delta.content:
                    yield StreamChunk(content=chunk.choices[0].delta.content)

                if chunk.choices and chunk.choices[0].finish_reason:
                    yield StreamChunk(content="", finish_reason=chunk.choices[0].finish_reason)

        except Exception as e:
            raise ProviderError(f"Async streaming error: {str(e)}", "mistral")

    def embed(
        self,
        text: str,
        model: str = "mistral-embed",
        **kwargs
    ) -> EmbeddingResponse:
        """
        Generate embedding for text using Mistral.

        Args:
            text: Text to embed
            model: Embedding model name
            **kwargs: Additional parameters

        Returns:
            EmbeddingResponse with embedding vector
        """
        try:
            response = self.client.embeddings(
                model=model,
                inputs=[text],
            )

            return EmbeddingResponse(
                embedding=response.data[0].embedding,
                model=model,
                tokens_used=response.usage.total_tokens,
            )

        except Exception as e:
            raise ProviderError(f"Embedding error: {str(e)}", "mistral")

    async def aembed(self, text: str, **kwargs) -> EmbeddingResponse:
        """Async version of embed()"""
        try:
            response = await self.async_client.embeddings(
                model=kwargs.get("model", "mistral-embed"),
                inputs=[text],
            )

            return EmbeddingResponse(
                embedding=response.data[0].embedding,
                model=kwargs.get("model", "mistral-embed"),
                tokens_used=response.usage.total_tokens,
            )

        except Exception as e:
            raise ProviderError(f"Async embedding error: {str(e)}", "mistral")

    def get_model_info(self) -> dict:
        """Get information about available models"""
        return {
            "provider": "mistral",
            "model": self.config.model,
            "supports_streaming": True,
            "supports_embeddings": True,
            "supports_async": True,
            "supports_function_calling": self.MODEL_INFO.get(
                self.config.model, {}
            ).get("supports_function_calling", False),
            "supports_json_mode": self.MODEL_INFO.get(
                self.config.model, {}
            ).get("supports_json_mode", False),
            "available_models": list(self.DEFAULT_MODELS.values()),
            "embedding_models": list(self.EMBEDDING_MODELS.values()),
            "model_details": self.MODEL_INFO.get(self.config.model, {}),
        }


def create_mistral_provider(
    api_key: str,
    model: str = "mistral-medium-latest",
    **kwargs
) -> MistralProvider:
    """
    Create a Mistral provider with common defaults.

    Args:
        api_key: Mistral API key
        model: Model name (default: mistral-medium-latest)
        **kwargs: Additional config parameters

    Returns:
        Configured MistralProvider instance
    """
    config = ProviderConfig(api_key=api_key, model=model, **kwargs)
    return MistralProvider(config)
