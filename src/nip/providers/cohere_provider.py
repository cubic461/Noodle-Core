"""
NIP v3.0.0 - Cohere Provider
Cohere API integration (Command, Command R, Command R+, Embeddings, Reranking)
"""

import asyncio
from typing import List, Iterator, AsyncIterator, Dict, Optional
import logging

try:
    import cohere
    COHERE_AVAILABLE = True
except ImportError:
    COHERE_AVAILABLE = False

from .base_provider import (
    BaseProvider, ProviderConfig, Message, MessageRole,
    CompletionResponse, StreamChunk, EmbeddingResponse,
    ProviderError, RateLimitError, AuthenticationError
)

logger = logging.getLogger(__name__)


class CohereProvider(BaseProvider):
    """
    Cohere API provider.
    
    Supported models:
    - command-r-plus-08-2024 (Latest Command R+)
    - command-r-08-2024
    - command (Command, Command Light)
    - embed-english-v3.0, embed-multilingual-v3.0 (Embeddings)
    - rerank-english-v3.0 (Reranking)
    
    Features:
    - Streaming support
    - Async support
    - Embedding support
    - Reranking API
    - Citation support
    - Multi-language support
    """
    
    DEFAULT_MODELS = {
        "command_r_plus": "command-r-plus-08-2024",
        "command_r": "command-r-08-2024",
        "command": "command",
        "command_light": "command-light",
    }
    
    EMBEDDING_MODELS = {
        "embed_english": "embed-english-v3.0",
        "embed_multilingual": "embed-multilingual-v3.0",
        "embed_english_light": "embed-english-light-v3.0",
    }
    
    RERANK_MODELS = {
        "rerank_english": "rerank-english-v3.0",
        "rerank_multilingual": "rerank-multilingual-v3.0",
    }
    
    MODEL_INFO = {
        "command-r-plus-08-2024": {
            "context_window": 128000,
            "max_output": 4096,
            "input_price": 3.0,  # per million tokens
            "output_price": 15.0,
            "supports_citations": True,
            "supports_tools": True,
        },
        "command-r-08-2024": {
            "context_window": 128000,
            "max_output": 4096,
            "input_price": 0.50,
            "output_price": 1.50,
            "supports_citations": True,
            "supports_tools": True,
        },
        "command": {
            "context_window": 4096,
            "max_output": 4096,
            "input_price": 1.50,
            "output_price": 2.00,
            "supports_citations": False,
            "supports_tools": False,
        },
    }
    
    EMBEDDING_INFO = {
        "embed-english-v3.0": {
            "dimensions": 1024,
            "max_tokens": 512,
            "price": 0.10,  # per million tokens
        },
        "embed-multilingual-v3.0": {
            "dimensions": 1024,
            "max_tokens": 512,
            "price": 0.10,
        },
    }
    
    def __init__(self, config: ProviderConfig):
        """
        Initialize Cohere provider.
        
        Args:
            config: Provider configuration with api_key required
        """
        super().__init__(config)
        
        if not COHERE_AVAILABLE:
            raise ImportError(
                "cohere package is required. "
                "Install with: pip install cohere"
            )
        
        if not self.validate_api_key():
            raise AuthenticationError(
                "Invalid Cohere API key. Get one at: https://dashboard.cohere.ai/",
                "cohere"
            )
        
        # Initialize client
        self.client = cohere.Client(
            api_key=config.api_key,
            timeout=config.timeout,
            max_retries=config.max_retries,
            client_name="nip-v3",
        )
        
        # Set default model if not specified
        if not config.model:
            config.model = self.DEFAULT_MODELS["command_r"]
    
    def _convert_messages(self, messages: List[Message]) -> str:
        """Convert NIP messages to Cohere chat format"""
        chat_history = []
        system_message = ""
        
        for msg in messages:
            if msg.role == MessageRole.SYSTEM:
                system_message = msg.content
            elif msg.role == MessageRole.USER:
                chat_history.append({"role": "USER", "message": msg.content})
            elif msg.role == MessageRole.ASSISTANT:
                chat_history.append({"role": "CHATBOT", "message": msg.content})
        
        # Build prompt with system message if present
        if system_message:
            return f"System: {system_message}\n\n" + "\n".join(
                f"{m['role']}: {m['message']}" for m in chat_history
            )
        return chat_history
    
    def complete(
        self,
        messages: List[Message],
        **kwargs
    ) -> CompletionResponse:
        """
        Generate a completion using Cohere.
        
        Args:
            messages: List of messages in the conversation
            **kwargs: Additional parameters
            
        Returns:
            CompletionResponse with generated content
        """
        try:
            chat_history = self._convert_messages(messages)
            
            # Build message list for chat API
            message_list = []
            for msg in messages:
                if msg.role == MessageRole.USER:
                    message_list.append({"role": "user", "content": msg.content})
                elif msg.role == MessageRole.ASSISTANT:
                    message_list.append({"role": "assistant", "content": msg.content})
            
            # Get last user message
            last_user_msg = next(
                (msg for msg in reversed(messages) if msg.role == MessageRole.USER),
                None
            )
            
            if not last_user_msg:
                raise ProviderError("No user message found", "cohere")
            
            params = {
                "model": kwargs.get("model", self.config.model),
                "message": last_user_msg.content,
                "chat_history": [
                    {"role": m["role"], "message": m["content"]}
                    for m in messages[:-1]
                    if m.role != MessageRole.SYSTEM
                ],
                "temperature": kwargs.get("temperature", self.config.temperature),
                "max_tokens": kwargs.get("max_tokens", self.config.max_tokens or 4096),
            }
            
            # Add system message if present
            system_msg = next((m for m in messages if m.role == MessageRole.SYSTEM), None)
            if system_msg:
                params["preamble"] = system_msg.content
            
            response = self._retry_with_backoff(
                self.client.chat,
                **params
            )
            
            usage = {
                "prompt_tokens": response.meta.billed_units.input_tokens,
                "completion_tokens": response.meta.billed_units.output_tokens,
                "total_tokens": (
                    response.meta.billed_units.input_tokens + 
                    response.meta.billed_units.output_tokens
                ),
            }
            
            return CompletionResponse(
                content=response.text,
                model=response.model,
                finish_reason=response.finish_reason,
                usage=usage,
                metadata={
                    "id": response.generation_id,
                    "citations": getattr(response, 'citations', None),
                }
            )
            
        except cohere.errors.UnauthorizedException as e:
            raise AuthenticationError(str(e), "cohere")
        except cohere.errors.RateLimitError as e:
            raise RateLimitError(str(e), "cohere")
        except cohere.errors.CohereError as e:
            raise ProviderError(str(e), "cohere")
        except Exception as e:
            raise ProviderError(f"Unexpected error: {str(e)}", "cohere")
    
    async def acomplete(
        self,
        messages: List[Message],
        **kwargs
    ) -> CompletionResponse:
        """Async version of complete()"""
        # Note: Cohere's async client may not be fully available
        # Fallback to sync for now
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(None, self.complete, messages, **kwargs)
    
    def stream_complete(
        self,
        messages: List[Message],
        **kwargs
    ) -> Iterator[StreamChunk]:
        """
        Stream completion responses from Cohere.
        
        Yields:
            StreamChunk objects with partial content
        """
        try:
            last_user_msg = next(
                (msg for msg in reversed(messages) if msg.role == MessageRole.USER),
                None
            )
            
            if not last_user_msg:
                raise ProviderError("No user message found", "cohere")
            
            params = {
                "model": kwargs.get("model", self.config.model),
                "message": last_user_msg.content,
                "chat_history": [
                    {"role": m["role"], "message": m["content"]}
                    for m in messages[:-1]
                    if m.role != MessageRole.SYSTEM
                ],
                "temperature": kwargs.get("temperature", self.config.temperature),
                "max_tokens": kwargs.get("max_tokens", self.config.max_tokens or 4096),
                "stream": True,
            }
            
            system_msg = next((m for m in messages if m.role == MessageRole.SYSTEM), None)
            if system_msg:
                params["preamble"] = system_msg.content
            
            stream = self.client.chat_stream(**params)
            
            for event in stream:
                if event.event_type == "text-generation":
                    yield StreamChunk(content=event.text)
                elif event.event_type == "stream-end":
                    yield StreamChunk(content="", finish_reason=event.finish_reason)
                    
        except Exception as e:
            raise ProviderError(f"Streaming error: {str(e)}", "cohere")
    
    async def astream_complete(
        self,
        messages: List[Message],
        **kwargs
    ) -> AsyncIterator[StreamChunk]:
        """Async version of stream_complete()"""
        loop = asyncio.get_event_loop()
        
        def sync_gen():
            yield from self.stream_complete(messages, **kwargs)
        
        queue = asyncio.Queue()
        
        def run_sync():
            for chunk in sync_gen():
                loop.call_soon_threadsafe(queue.put_nowait, chunk)
            loop.call_soon_threadsafe(queue.put_nowait, None)
        
        import threading
        thread = threading.Thread(target=run_sync)
        thread.start()
        
        while True:
            chunk = await queue.get()
            if chunk is None:
                break
            yield chunk
    
    def embed(
        self,
        text: str,
        model: str = "embed-english-v3.0",
        **kwargs
    ) -> EmbeddingResponse:
        """
        Generate embedding for text using Cohere.
        
        Args:
            text: Text to embed
            model: Embedding model name
            **kwargs: Additional parameters
            
        Returns:
            EmbeddingResponse with embedding vector
        """
        try:
            response = self.client.embed(
                texts=[text],
                model=model,
                input_type="search_document",
            )
            
            return EmbeddingResponse(
                embedding=response.embeddings[0],
                model=model,
                tokens_used=response.meta.billed_units.input_tokens,
            )
            
        except Exception as e:
            raise ProviderError(f"Embedding error: {str(e)}", "cohere")
    
    async def aembed(self, text: str, **kwargs) -> EmbeddingResponse:
        """Async version of embed()"""
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(None, self.embed, text, **kwargs)
    
    def embed_batch(
        self,
        texts: List[str],
        model: str = "embed-english-v3.0",
        **kwargs
    ) -> List[EmbeddingResponse]:
        """
        Generate embeddings for multiple texts.
        
        Args:
            texts: List of texts to embed
            model: Embedding model name
            **kwargs: Additional parameters
            
        Returns:
            List of EmbeddingResponse objects
        """
        try:
            response = self.client.embed(
                texts=texts,
                model=model,
                input_type="search_document",
            )
            
            return [
                EmbeddingResponse(
                    embedding=emb,
                    model=model,
                    tokens_used=response.meta.billed_units.input_tokens // len(texts),
                )
                for emb in response.embeddings
            ]
            
        except Exception as e:
            raise ProviderError(f"Batch embedding error: {str(e)}", "cohere")
    
    def rerank(
        self,
        query: str,
        documents: List[str],
        model: str = "rerank-english-v3.0",
        top_n: int = 10,
        **kwargs
    ) -> List[Dict]:
        """
        Rerank documents based on query relevance.
        
        Args:
            query: Search query
            documents: List of documents to rerank
            model: Rerank model name
            top_n: Number of top results to return
            **kwargs: Additional parameters
            
        Returns:
            List of dicts with index, score, and relevance_score
        """
        try:
            response = self.client.rerank(
                model=model,
                query=query,
                documents=documents,
                top_n=top_n,
            )
            
            return [
                {
                    "index": result.index,
                    "score": result.relevance_score,
                    "document": documents[result.index],
                }
                for result in response.results
            ]
            
        except Exception as e:
            raise ProviderError(f"Reranking error: {str(e)}", "cohere")
    
    def get_model_info(self) -> Dict:
        """Get information about available models"""
        return {
            "provider": "cohere",
            "model": self.config.model,
            "supports_streaming": True,
            "supports_embeddings": True,
            "supports_async": True,
            "supports_reranking": True,
            "available_models": list(self.DEFAULT_MODELS.values()),
            "embedding_models": list(self.EMBEDDING_MODELS.values()),
            "rerank_models": list(self.RERANK_MODELS.values()),
            "model_details": self.MODEL_INFO.get(self.config.model, {}),
        }


def create_cohere_provider(
    api_key: str,
    model: str = "command-r-08-2024",
    **kwargs
) -> CohereProvider:
    """
    Create a Cohere provider with common defaults.
    
    Args:
        api_key: Cohere API key
        model: Model name (default: command-r-08-2024)
        **kwargs: Additional config parameters
        
    Returns:
        Configured CohereProvider instance
    """
    config = ProviderConfig(api_key=api_key, model=model, **kwargs)
    return CohereProvider(config)
