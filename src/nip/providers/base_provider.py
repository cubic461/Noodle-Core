"""
NIP v3.0.0 - Base Provider Interface
Abstract base class for all LLM providers
"""

from abc import ABC, abstractmethod
from typing import Optional
from collections.abc import AsyncIterator, Iterator
from dataclasses import dataclass
from enum import Enum
import time
import logging

logger = logging.getLogger(__name__)


class MessageRole(Enum):
    """Message roles in conversations"""
    SYSTEM = "system"
    USER = "user"
    ASSISTANT = "assistant"
    TOOL = "tool"


@dataclass
class Message:
    """A message in a conversation"""
    role: MessageRole
    content: str
    metadata: Optional[dict] = None


@dataclass
class ProviderConfig:
    """Configuration for a provider"""
    api_key: Optional[str] = None
    base_url: Optional[str] = None
    model: Optional[str] = None
    temperature: float = 0.7
    max_tokens: Optional[int] = None
    timeout: int = 60
    max_retries: int = 3
    retry_delay: float = 1.0


@dataclass
class CompletionResponse:
    """Response from a completion request"""
    content: str
    model: str
    finish_reason: str
    usage: dict[str, int]  # prompt_tokens, completion_tokens, total_tokens
    metadata: Optional[dict] = None


@dataclass
class EmbeddingResponse:
    """Response from an embedding request"""
    embedding: list[float]
    model: str
    tokens_used: int


@dataclass
class StreamChunk:
    """A chunk from streaming completion"""
    content: str
    finish_reason: Optional[str] = None
    usage: Optional[dict[str, int]] = None


class ProviderError(Exception):
    """Base exception for provider errors"""
    def __init__(self, message: str, provider: str, code: Optional[str] = None):
        self.message = message
        self.provider = provider
        self.code = code
        super().__init__(f"[{provider}] {message}")


class RateLimitError(ProviderError):
    """Raised when rate limit is exceeded"""
    pass


class AuthenticationError(ProviderError):
    """Raised when authentication fails"""
    pass


class BaseProvider(ABC):
    """
    Abstract base class for all LLM providers.

    All providers must implement these methods to ensure
    consistent interface across different LLM backends.
    """

    def __init__(self, config: ProviderConfig):
        """
        Initialize the provider with configuration.

        Args:
            config: Provider configuration
        """
        self.config = config
        self.provider_name = self.__class__.__name__.replace("Provider", "").lower()

    @abstractmethod
    def complete(
        self,
        messages: list[Message],
        **kwargs
    ) -> CompletionResponse:
        """
        Generate a completion for the given messages.

        Args:
            messages: List of messages in the conversation
            **kwargs: Additional provider-specific parameters

        Returns:
            CompletionResponse with generated content and metadata
        """
        pass

    @abstractmethod
    async def acomplete(
        self,
        messages: list[Message],
        **kwargs
    ) -> CompletionResponse:
        """
        Async version of complete().
        """
        pass

    @abstractmethod
    def stream_complete(
        self,
        messages: list[Message],
        **kwargs
    ) -> Iterator[StreamChunk]:
        """
        Stream completion responses.

        Args:
            messages: List of messages in the conversation
            **kwargs: Additional provider-specific parameters

        Yields:
            StreamChunk objects with partial content
        """
        pass

    @abstractmethod
    async def astream_complete(
        self,
        messages: list[Message],
        **kwargs
    ) -> AsyncIterator[StreamChunk]:
        """
        Async version of stream_complete().
        """
        pass

    def embed(self, text: str, **kwargs) -> EmbeddingResponse:
        """
        Generate embedding for text.

        Args:
            text: Text to embed
            **kwargs: Additional provider-specific parameters

        Returns:
            EmbeddingResponse with embedding vector

        Raises:
            NotImplementedError: If provider doesn't support embeddings
        """
        raise NotImplementedError(f"{self.provider_name} does not support embeddings")

    async def aembed(self, text: str, **kwargs) -> EmbeddingResponse:
        """Async version of embed()"""
        raise NotImplementedError(f"{self.provider_name} does not support embeddings")

    def count_tokens(self, text: str) -> int:
        """
        Count tokens in text.

        Args:
            text: Text to count tokens for

        Returns:
            Approximate token count
        """
        # Default approximation: ~4 characters per token
        return len(text) // 4

    def validate_api_key(self) -> bool:
        """
        Validate that the API key is present and properly formatted.

        Returns:
            True if valid, False otherwise
        """
        if not self.config.api_key:
            return False
        return len(self.config.api_key) > 10

    def _retry_with_backoff(self, func, *args, **kwargs):
        """
        Execute a function with retry logic and exponential backoff.

        Args:
            func: Function to execute
            *args: Positional arguments for func
            **kwargs: Keyword arguments for func

        Returns:
            Result from func

        Raises:
            ProviderError: If all retries are exhausted
        """
        last_exception = None

        for attempt in range(self.config.max_retries):
            try:
                return func(*args, **kwargs)
            except Exception as e:
                last_exception = e
                if attempt < self.config.max_retries - 1:
                    delay = self.config.retry_delay * (2 ** attempt)
                    logger.warning(
                        f"{self.provider_name}: Attempt {attempt + 1} failed, "
                        f"retrying in {delay}s: {str(e)}"
                    )
                    time.sleep(delay)
                else:
                    logger.error(
                        f"{self.provider_name}: All {self.config.max_retries} "
                        f"attempts failed: {str(e)}"
                    )

        raise last_exception

    def get_model_info(self) -> dict[str, any]:
        """
        Get information about available models.

        Returns:
            Dictionary with model information
        """
        return {
            "provider": self.provider_name,
            "model": self.config.model,
            "supports_streaming": True,
            "supports_embeddings": False,
            "supports_async": True,
        }

    def __repr__(self) -> str:
        return f"{self.__class__.__name__}(model={self.config.model})"
