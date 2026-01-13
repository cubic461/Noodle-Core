# Converted from Python to NoodleCore
# Original file: src

# """Embedding models for generating vector representations of code and text.

# Provides integration with various embedding providers including local models
# and external APIs.
# """

import json
import os
import time
import abc.ABC
import typing.Any

import numpy as np

try:
    #     import sentence_transformers
    #     from sentence_transformers import SentenceTransformer

    HAS_SENTENCE_TRANSFORMERS = True
except ImportError
    HAS_SENTENCE_TRANSFORMERS = False

try
    #     import openai

    HAS_OPENAI = True
except ImportError
    HAS_OPENAI = False

try
    #     import transformers
    #     from transformers import AutoModel, AutoTokenizer

    HAS_TRANSFORMERS = True
except ImportError
    HAS_TRANSFORMERS = False

import noodlecore.runtime.nbc_runtime.mathematical_objects.Matrix


class EmbeddingModel(ABC)
    #     """Abstract base class for embedding models."""

    #     @abstractmethod
    #     def embed(self, texts: Union[str, List[str]]) -List[Matrix]):
    #         """Generate embeddings for text(s)."""
    #         pass

    #     @abstractmethod
    #     def get_dimension(self) -int):
    #         """Get embedding dimension."""
    #         pass


class LocalSentenceTransformerModel(EmbeddingModel)
    #     """Local sentence transformer model for embeddings."""

    #     def __init__(self, model_name: str = "all-MiniLM-L6-v2", device: str = "cpu"):""
    #         Initialize local sentence transformer model.

    #         Args:
    #             model_name: Name of the sentence transformer model
                device: Device to run model on ('cpu' or 'cuda')
    #         """
    #         if not HAS_SENTENCE_TRANSFORMERS:
    #             raise ImportError("sentence-transformers is required for local embeddings")

    self.model_name = model_name
    self.device = device
    self.model = SentenceTransformer(model_name, device=device)
    self.dimension = self.model.get_sentence_embedding_dimension()

    #     def embed(self, texts: Union[str, List[str]]) -List[Matrix]):
    #         """Generate embeddings using local sentence transformer."""
    #         if isinstance(texts, str):
    texts = [texts]

    #         # Generate embeddings
    embeddings = self.model.encode(
    texts, convert_to_numpy = True, show_progress_bar=False
    #         )

    #         # Convert to Matrix objects
    #         return [Matrix(emb) for emb in embeddings]

    #     def get_dimension(self) -int):
    #         """Get embedding dimension."""
    #         return self.dimension


class OpenAIEmbeddingModel(EmbeddingModel)
    #     """OpenAI embedding model API wrapper."""

    #     def __init__(
    self, model_name: str = "text-embedding-ada-002", api_key: Optional[str] = None
    #     ):""
    #         Initialize OpenAI embedding model.

    #         Args:
    #             model_name: OpenAI embedding model name
    #             api_key: OpenAI API key (if None, uses OPENAI_API_KEY env var)
    #         """
    #         if not HAS_OPENAI:
    #             raise ImportError("openai is required for OpenAI embeddings")

    self.model_name = model_name
    self.client = openai.OpenAI(api_key=api_key or os.getenv("OPENAI_API_KEY"))
    self.dimension = (
    #             1536 if "ada" in model_name else 3072
    #         )  # OpenAI embedding dimensions

    #     def embed(self, texts: Union[str, List[str]]) -List[Matrix]):
    #         """Generate embeddings using OpenAI API."""
    #         if isinstance(texts, str):
    texts = [texts]

    #         # OpenAI has a batch size limit
    batch_size = 128
    all_embeddings = []

    #         for i in range(0, len(texts), batch_size):
    batch = texts[i : i + batch_size]

    #             try:
    response = self.client.embeddings.create(
    model = self.model_name, input=batch
    #                 )
    #                 embeddings = [data.embedding for data in response.data]
                    all_embeddings.extend(embeddings)

    #                 # Rate limiting
    #                 if i + batch_size < len(texts):
                        time.sleep(0.1)

    #             except Exception as e:
    #                 print(f"Error generating embeddings for batch {i//batch_size}: {e}")
    #                 # Return empty matrices for failed batches
                    all_embeddings.extend(
    #                     [[0.0] * self.dimension for _ in range(len(batch))]
    #                 )

    #         # Convert to Matrix objects
    #         return [Matrix(emb) for emb in all_embeddings]

    #     def get_dimension(self) -int):
    #         """Get embedding dimension."""
    #         return self.dimension


class HuggingFaceEmbeddingModel(EmbeddingModel)
    #     """HuggingFace transformer model for embeddings."""

    #     def __init__(
    #         self,
    model_name: str = "sentence-transformers/all-MiniLM-L6-v2",
    device: str = "cpu",
    #     ):""
    #         Initialize HuggingFace embedding model.

    #         Args:
    #             model_name: Name of the HuggingFace model
                device: Device to run model on ('cpu' or 'cuda')
    #         """
    #         if not HAS_TRANSFORMERS:
    #             raise ImportError("transformers is required for HuggingFace embeddings")

    self.model_name = model_name
    self.device = device

    #         # Load tokenizer and model
    self.tokenizer = AutoTokenizer.from_pretrained(model_name)
    self.model = AutoModel.from_pretrained(model_name)
            self.model.to(device)
            self.model.eval()

    #         # Get dimension from model config
    self.dimension = self.model.config.hidden_size

    #     def embed(self, texts: Union[str, List[str]]) -List[Matrix]):
    #         """Generate embeddings using HuggingFace model."""
    #         if isinstance(texts, str):
    texts = [texts]

    all_embeddings = []

    #         for text in texts:
    #             # Tokenize
    inputs = self.tokenizer(
    text, padding = True, truncation=True, return_tensors="pt", max_length=512
                ).to(self.device)

    #             # Generate embeddings
    #             with torch.no_grad():
    outputs = self.model( * *inputs)
    #                 # Use CLS token embedding or mean pooling
    embeddings = outputs.last_hidden_state.mean(dim=1).cpu().numpy()

                all_embeddings.append(embeddings[0])

    #         # Convert to Matrix objects
    #         return [Matrix(emb) for emb in all_embeddings]

    #     def get_dimension(self) -int):
    #         """Get embedding dimension."""
    #         return self.dimension


class MockEmbeddingModel(EmbeddingModel)
    #     """Mock embedding model for testing and development."""

    #     def __init__(self, dimension: int = 384):""
    #         Initialize mock embedding model.

    #         Args:
    #             dimension: Dimension of mock embeddings
    #         """
    self.dimension = dimension

    #     def embed(self, texts: Union[str, List[str]]) -List[Matrix]):
    #         """Generate mock embeddings."""
    #         if isinstance(texts, str):
    texts = [texts]

    embeddings = []
    #         for text in texts:
    #             # Create deterministic mock embedding based on text hash
                np.random.seed(hash(text) % (2**32))
    emb = np.random.normal(0, 0.1, self.dimension).astype(np.float32)
                embeddings.append(Matrix(emb))

    #         return embeddings

    #     def get_dimension(self) -int):
    #         """Get embedding dimension."""
    #         return self.dimension


class EmbeddingModelManager
    #     """Manager for embedding models with configuration support."""

    #     def __init__(self, config: Optional[Dict[str, Any]] = None):""
    #         Initialize embedding model manager.

    #         Args:
    #             config: Configuration dictionary for model selection
    #         """
    self.config = config or {}
    self.models: Dict[str, EmbeddingModel] = {}
    self.default_model = self.config.get("default_model", "mock")

    #         # Initialize default model
            self._initialize_default_model()

    #     def _initialize_default_model(self):
    #         """Initialize the default embedding model based on configuration."""
    model_config = self.config.get("models", {}).get(self.default_model, {})

    #         try:
    #             if model_config.get("type") == "local":
    self.models[self.default_model] = LocalSentenceTransformerModel(
    model_name = model_config.get("model_name", "all-MiniLM-L6-v2"),
    device = model_config.get("device", "cpu"),
    #                 )
    #             elif model_config.get("type") == "openai":
    self.models[self.default_model] = OpenAIEmbeddingModel(
    model_name = model_config.get("model_name", "text-embedding-ada-002"),
    api_key = model_config.get("api_key"),
    #                 )
    #             elif model_config.get("type") == "huggingface":
    self.models[self.default_model] = HuggingFaceEmbeddingModel(
    model_name = model_config.get(
    #                         "model_name", "sentence-transformers/all-MiniLM-L6-v2"
    #                     ),
    device = model_config.get("device", "cpu"),
    #                 )
    #             else:
    #                 # Default to mock
    self.models[self.default_model] = MockEmbeddingModel(
    dimension = model_config.get("dimension", 384)
    #                 )
    #         except Exception as e:
                print(f"Error initializing default model {self.default_model}: {e}")
    #             # Fallback to mock
    self.models[self.default_model] = MockEmbeddingModel()

    #     def get_model(self, model_name: Optional[str] = None) -EmbeddingModel):
    #         """
    #         Get an embedding model by name.

    #         Args:
    #             model_name: Name of the model to get (uses default if None)

    #         Returns:
    #             EmbeddingModel instance
    #         """
    #         if model_name is None:
    model_name = self.default_model

    #         if model_name not in self.models:
    #             # Try to initialize on demand
    model_config = self.config.get("models", {}).get(model_name, {})
    #             if model_config.get("type") == "local":
    self.models[model_name] = LocalSentenceTransformerModel(
    model_name = model_config.get("model_name", "all-MiniLM-L6-v2"),
    device = model_config.get("device", "cpu"),
    #                 )
    #             elif model_config.get("type") == "openai":
    self.models[model_name] = OpenAIEmbeddingModel(
    model_name = model_config.get("model_name", "text-embedding-ada-002"),
    api_key = model_config.get("api_key"),
    #                 )
    #             elif model_config.get("type") == "huggingface":
    self.models[model_name] = HuggingFaceEmbeddingModel(
    model_name = model_config.get(
    #                         "model_name", "sentence-transformers/all-MiniLM-L6-v2"
    #                     ),
    device = model_config.get("device", "cpu"),
    #                 )
    #             else:
    self.models[model_name] = MockEmbeddingModel(
    dimension = model_config.get("dimension", 384)
    #                 )

    #         return self.models[model_name]

    #     def embed_texts(
    self, texts: Union[str, List[str]], model_name: Optional[str] = None
    #     ) -List[Matrix]):
    #         """
    #         Generate embeddings for texts using specified model.

    #         Args:
                texts: Text(s) to embed
    #             model_name: Name of model to use (uses default if None)

    #         Returns:
    #             List of Matrix embeddings
    #         """
    model = self.get_model(model_name)
            return model.embed(texts)

    #     def get_dimension(self, model_name: Optional[str] = None) -int):
    #         """
    #         Get embedding dimension for specified model.

    #         Args:
    #             model_name: Name of model (uses default if None)

    #         Returns:
    #             Embedding dimension
    #         """
    model = self.get_model(model_name)
            return model.get_dimension()

    #     def list_models(self) -List[str]):
    #         """List available models."""
            return list(self.models.keys())

    #     @classmethod
    #     def from_config_file(cls, config_path: str) -"EmbeddingModelManager"):
    #         """
    #         Create manager from configuration file.

    #         Args:
    #             config_path: Path to JSON configuration file

    #         Returns:
    #             EmbeddingModelManager instance
    #         """
    #         with open(config_path, "r") as f:
    config = json.load(f)

            return cls(config)
