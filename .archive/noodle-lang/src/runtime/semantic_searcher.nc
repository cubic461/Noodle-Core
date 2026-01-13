#!/usr/bin/env python3
"""
NoodleCore Semantic Searcher Module
==================================

AI-powered semantic search engine for intelligent code and content discovery.
Integrates with vector databases and AI APIs to provide contextual understanding
and concept-based search capabilities.

Features:
- Vector embedding generation for semantic search
- Integration with existing vector database (data/vector_index.db)
- AI API integration for semantic analysis
- Contextual understanding and concept matching
- Similarity-based ranking and search
- Multi-language semantic support
- Real-time embedding generation and search
- Integration with Monaco Editor for intelligent suggestions
- Support for code semantics and meaning-based search

Author: NoodleCore Search Team
Version: 1.0.0
"""

import os
import time
import logging
import threading
import sqlite3
import json
import numpy as np
from pathlib import Path
from typing import Dict, List, Optional, Set, Any, Tuple, Generator
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from concurrent.futures import ThreadPoolExecutor, as_completed
import hashlib
import pickle

# Configure logging
logger = logging.getLogger(__name__)

# NoodleCore environment variables
NOODLE_DEBUG = os.environ.get("NOODLE_DEBUG", "0") == "1"
NOODLE_SEMANTIC_WORKERS = int(os.environ.get("NOODLE_SEMANTIC_WORKERS", "2"))
NOODLE_VECTOR_DB_PATH = os.environ.get("NOODLE_VECTOR_DB_PATH", "data/vector_index.db")
NOODLE_EMBEDDING_MODEL = os.environ.get("NOODLE_EMBEDDING_MODEL", "sentence-transformers")
NOODLE_MAX_EMBEDDING_DIM = int(os.environ.get("NOODLE_MAX_EMBEDDING_DIM", "384"))
NOODLE_SIMILARITY_THRESHOLD = float(os.environ.get("NOODLE_SIMILARITY_THRESHOLD", "0.7"))
NOODLE_MAX_SEMANTIC_RESULTS = int(os.environ.get("NOODLE_MAX_SEMANTIC_RESULTS", "100"))


@dataclass
class SemanticMatch:
    """Represents a semantic search match."""
    file_path: str
    content: str
    similarity_score: float
    embedding_vector: List[float]
    semantic_concepts: List[str]
    language: str
    file_type: str
    chunk_id: str
    context_window: str
    metadata: Dict[str, Any]


@dataclass
class SemanticSearchResult:
    """Represents a complete semantic search result."""
    search_id: str
    query: str
    query_embedding: List[float]
    total_matches: int
    search_time: float
    matches: List[SemanticMatch]
    search_type: str = "semantic"
    search_options: Dict[str, Any] = None
    progress: float = 0.0
    streaming: bool = False


@dataclass
class SemanticSearchOptions:
    """Configuration for semantic searches."""
    similarity_threshold: float = NOODLE_SIMILARITY_THRESHOLD
    max_results: int = NOODLE_MAX_SEMANTIC_RESULTS
    context_window: int = 500  # characters
    chunk_size: int = 1000     # characters
    overlap_size: int = 100    # characters
    include_metadata: bool = True
    use_cache: bool = True
    ai_enhancement: bool = True
    streaming: bool = True
    timeout: float = 30.0


class VectorDatabase:
    """Vector database interface for semantic search."""
    
    def __init__(self, db_path: str = None):
        """Initialize vector database.
        
        Args:
            db_path: Path to vector database file
        """
        self.db_path = db_path or NOODLE_VECTOR_DB_PATH
        self.max_dim = NOODLE_MAX_EMBEDDING_DIM
        
        # Ensure directory exists
        os.makedirs(os.path.dirname(self.db_path), exist_ok=True)
        
        # Initialize database
        self._init_database()
    
    def _init_database(self):
        """Initialize vector database tables."""
        try:
            self.conn = sqlite3.connect(self.db_path, check_same_thread=False)
            self.conn.execute('PRAGMA journal_mode=WAL')
            
            # Create embeddings table
            self.conn.execute('''
                CREATE TABLE IF NOT EXISTS embeddings (
                    chunk_id TEXT PRIMARY KEY,
                    file_path TEXT NOT NULL,
                    content TEXT NOT NULL,
                    embedding BLOB NOT NULL,
                    language TEXT,
                    file_type TEXT,
                    chunk_index INTEGER,
                    semantic_concepts TEXT,
                    metadata TEXT,
                    created_at REAL,
                    last_accessed REAL,
                    access_count INTEGER DEFAULT 0
                )
            ''')
            
            # Create indices for performance
            self.conn.execute('CREATE INDEX IF NOT EXISTS idx_file_path ON embeddings(file_path)')
            self.conn.execute('CREATE INDEX IF NOT EXISTS idx_language ON embeddings(language)')
            self.conn.execute('CREATE INDEX IF NOT EXISTS idx_file_type ON embeddings(file_type)')
            self.conn.execute('CREATE INDEX IF NOT EXISTS idx_created_at ON embeddings(created_at)')
            self.conn.execute('CREATE INDEX IF NOT EXISTS idx_access_count ON embeddings(access_count)')
            
            self.conn.commit()
            
            logger.info(f"Vector database initialized: {self.db_path}")
            
        except Exception as e:
            logger.error(f"Failed to initialize vector database: {e}")
            raise
    
    def store_embedding(self, chunk_id: str, file_path: str, content: str, 
                       embedding: List[float], language: str = None, 
                       file_type: str = None, chunk_index: int = 0,
                       semantic_concepts: List[str] = None,
                       metadata: Dict[str, Any] = None) -> bool:
        """Store embedding in vector database."""
        try:
            # Serialize embedding
            embedding_blob = pickle.dumps(np.array(embedding, dtype=np.float32))
            
            with self.conn:
                self.conn.execute('''
                    INSERT OR REPLACE INTO embeddings 
                    (chunk_id, file_path, content, embedding, language, file_type, 
                     chunk_index, semantic_concepts, metadata, created_at, last_accessed)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ''', (
                    chunk_id, file_path, content, embedding_blob, language, file_type,
                    chunk_index, json.dumps(semantic_concepts or []),
                    json.dumps(metadata or {}), time.time(), time.time()
                ))
            
            return True
            
        except Exception as e:
            logger.error(f"Failed to store embedding {chunk_id}: {e}")
            return False
    
    def search_embeddings(self, query_embedding: List[float], 
                         similarity_threshold: float = 0.7,
                         max_results: int = 100,
                         language: str = None,
                         file_type: str = None) -> List[Tuple[str, str, float, str]]:
        """Search embeddings by similarity."""
        try:
            query_vector = np.array(query_embedding, dtype=np.float32)
            
            # Get all embeddings from database
            cursor = self.conn.execute('''
                SELECT chunk_id, file_path, content, embedding, language, file_type
                FROM embeddings
                WHERE (? IS NULL OR language = ?)
                  AND (? IS NULL OR file_type = ?)
                ORDER BY last_accessed DESC
            ''', (language, language, file_type, file_type))
            
            similarities = []
            
            for row in cursor.fetchall():
                chunk_id, file_path, content, embedding_blob, row_language, row_file_type = row
                
                # Deserialize embedding
                try:
                    stored_embedding = pickle.loads(embedding_blob)
                    
                    # Calculate cosine similarity
                    similarity = self._cosine_similarity(query_vector, stored_embedding)
                    
                    if similarity >= similarity_threshold:
                        similarities.append((chunk_id, file_path, similarity, content))
                        
                except Exception as e:
                    logger.debug(f"Error processing embedding for {chunk_id}: {e}")
                    continue
            
            # Sort by similarity and limit results
            similarities.sort(key=lambda x: x[2], reverse=True)
            return similarities[:max_results]
            
        except Exception as e:
            logger.error(f"Vector search failed: {e}")
            return []
    
    def _cosine_similarity(self, a: np.ndarray, b: np.ndarray) -> float:
        """Calculate cosine similarity between two vectors."""
        try:
            # Ensure same length
            min_len = min(len(a), len(b))
            a = a[:min_len]
            b = b[:min_len]
            
            # Calculate cosine similarity
            dot_product = np.dot(a, b)
            norm_a = np.linalg.norm(a)
            norm_b = np.linalg.norm(b)
            
            if norm_a == 0 or norm_b == 0:
                return 0.0
            
            return dot_product / (norm_a * norm_b)
            
        except Exception:
            return 0.0
    
    def get_chunk_by_id(self, chunk_id: str) -> Optional[Tuple[str, str, str, str]]:
        """Get chunk content by ID."""
        try:
            cursor = self.conn.execute('''
                SELECT file_path, content, language, file_type
                FROM embeddings WHERE chunk_id = ?
            ''', (chunk_id,))
            
            row = cursor.fetchone()
            if row:
                # Update access statistics
                self.conn.execute('''
                    UPDATE embeddings 
                    SET last_accessed = ?, access_count = access_count + 1
                    WHERE chunk_id = ?
                ''', (time.time(), chunk_id))
                
                return row
            
            return None
            
        except Exception as e:
            logger.error(f"Failed to get chunk {chunk_id}: {e}")
            return None
    
    def get_file_chunks(self, file_path: str) -> List[str]:
        """Get all chunk IDs for a file."""
        try:
            cursor = self.conn.execute('''
                SELECT chunk_id FROM embeddings WHERE file_path = ?
                ORDER BY chunk_index
            ''', (file_path,))
            
            return [row[0] for row in cursor.fetchall()]
            
        except Exception as e:
            logger.error(f"Failed to get chunks for {file_path}: {e}")
            return []
    
    def delete_file_chunks(self, file_path: str) -> int:
        """Delete all chunks for a file."""
        try:
            with self.conn:
                cursor = self.conn.execute('''
                    DELETE FROM embeddings WHERE file_path = ?
                ''', (file_path,))
                
                return cursor.rowcount
                
        except Exception as e:
            logger.error(f"Failed to delete chunks for {file_path}: {e}")
            return 0
    
    def cleanup_old_chunks(self, days: int = 30) -> int:
        """Clean up old, rarely accessed chunks."""
        try:
            cutoff_time = time.time() - (days * 24 * 3600)
            
            with self.conn:
                cursor = self.conn.execute('''
                    DELETE FROM embeddings 
                    WHERE last_accessed < ? AND access_count < 3
                ''', (cutoff_time,))
                
                return cursor.rowcount
                
        except Exception as e:
            logger.error(f"Failed to cleanup old chunks: {e}")
            return 0
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get vector database statistics."""
        try:
            cursor = self.conn.execute('SELECT COUNT(*) FROM embeddings')
            total_chunks = cursor.fetchone()[0]
            
            cursor = self.conn.execute('SELECT COUNT(DISTINCT file_path) FROM embeddings')
            total_files = cursor.fetchone()[0]
            
            cursor = self.conn.execute('SELECT language, COUNT(*) FROM embeddings WHERE language IS NOT NULL GROUP BY language')
            languages = dict(cursor.fetchall())
            
            cursor = self.conn.execute('SELECT file_type, COUNT(*) FROM embeddings WHERE file_type IS NOT NULL GROUP BY file_type')
            file_types = dict(cursor.fetchall())
            
            return {
                'total_chunks': total_chunks,
                'total_files': total_files,
                'languages': languages,
                'file_types': file_types,
                'database_path': self.db_path
            }
            
        except Exception as e:
            logger.error(f"Failed to get vector database statistics: {e}")
            return {}


class EmbeddingGenerator:
    """Generate embeddings for text content."""
    
    def __init__(self, model_name: str = None):
        """Initialize embedding generator.
        
        Args:
            model_name: Name of embedding model to use
        """
        self.model_name = model_name or NOODLE_EMBEDDING_MODEL
        self.model = None
        self.embedding_cache: Dict[str, List[float]] = {}
        self.cache_lock = threading.RLock()
        self.max_cache_size = 10000
        
        # Initialize model
        self._init_model()
    
    def _init_model(self):
        """Initialize the embedding model."""
        try:
            # Try to import sentence transformers
            try:
                from sentence_transformers import SentenceTransformer
                self.model = SentenceTransformer(self.model_name)
                logger.info(f"Initialized SentenceTransformer model: {self.model_name}")
                return
            except ImportError:
                pass
            
            # Try to import OpenAI embeddings
            try:
                import openai
                # Check if OpenAI API key is available
                if os.environ.get('OPENAI_API_KEY'):
                    self.openai_client = openai.OpenAI()
                    logger.info("Initialized OpenAI embeddings")
                    return
            except ImportError:
                pass
            
            # Fallback to mock embeddings
            self.model = "mock"
            logger.warning("Using mock embeddings - install sentence-transformers or OpenAI for real embeddings")
            
        except Exception as e:
            logger.error(f"Failed to initialize embedding model: {e}")
            self.model = "mock"
    
    def generate_embedding(self, text: str) -> Optional[List[float]]:
        """Generate embedding for text.
        
        Args:
            text: Text to generate embedding for
            
        Returns:
            List of float values representing the embedding
        """
        if not text or not text.strip():
            return None
        
        # Check cache first
        text_hash = hashlib.md5(text.encode()).hexdigest()
        with self.cache_lock:
            if text_hash in self.embedding_cache:
                return self.embedding_cache[text_hash]
        
        try:
            if self.model == "mock":
                # Generate mock embedding for testing
                embedding = self._generate_mock_embedding(text)
            elif hasattr(self.model, 'encode'):
                # SentenceTransformer model
                embedding = self.model.encode(text).tolist()
            elif hasattr(self, 'openai_client'):
                # OpenAI embeddings
                response = self.openai_client.embeddings.create(
                    model="text-embedding-ada-002",
                    input=text
                )
                embedding = response.data[0].embedding
            else:
                logger.error("No valid embedding model available")
                return None
            
            # Cache the embedding
            with self.cache_lock:
                self.embedding_cache[text_hash] = embedding
                
                # Evict old cache entries if cache is full
                if len(self.embedding_cache) > self.max_cache_size:
                    oldest_key = min(self.embedding_cache.keys())
                    del self.embedding_cache[oldest_key]
            
            return embedding
            
        except Exception as e:
            logger.error(f"Failed to generate embedding: {e}")
            return None
    
    def _generate_mock_embedding(self, text: str) -> List[float]:
        """Generate mock embedding for testing purposes."""
        # Simple hash-based mock embedding
        hash_obj = hashlib.md5(text.encode())
        hash_bytes = hash_obj.digest()
        
        # Convert to float values between -1 and 1
        embedding = []
        for i in range(min(len(hash_bytes), NOODLE_MAX_EMBEDDING_DIM)):
            embedding.append((hash_bytes[i] / 255.0) * 2.0 - 1.0)
        
        # Pad or truncate to desired dimension
        while len(embedding) < NOODLE_MAX_EMBEDDING_DIM:
            embedding.append(0.0)
        
        return embedding[:NOODLE_MAX_EMBEDDING_DIM]
    
    def generate_batch_embeddings(self, texts: List[str]) -> List[Optional[List[float]]]:
        """Generate embeddings for multiple texts.
        
        Args:
            texts: List of texts to generate embeddings for
            
        Returns:
            List of embeddings (or None for failed generations)
        """
        embeddings = []
        
        for text in texts:
            embedding = self.generate_embedding(text)
            embeddings.append(embedding)
        
        return embeddings
    
    def clear_cache(self):
        """Clear the embedding cache."""
        with self.cache_lock:
            self.embedding_cache.clear()


class SemanticSearcher:
    """
    AI-powered semantic search engine for NoodleCore.
    
    This class provides semantic search capabilities by integrating with
    vector databases and AI APIs to understand meaning and context.
    """
    
    def __init__(self, file_indexer=None, vector_db_path: str = None):
        """Initialize the semantic searcher.
        
        Args:
            file_indexer: FileIndexer instance for file metadata
            vector_db_path: Path to vector database file
        """
        self.file_indexer = file_indexer
        self.max_workers = NOODLE_SEMANTIC_WORKERS
        
        # Initialize components
        self.vector_db = VectorDatabase(vector_db_path)
        self.embedding_generator = EmbeddingGenerator()
        
        # Search statistics
        self.search_stats = {
            'total_searches': 0,
            'total_matches': 0,
            'average_search_time': 0.0,
            'embedding_generations': 0,
            'cache_hits': 0,
            'cache_misses': 0
        }
        
        # Search history
        self.search_history: List[Dict[str, Any]] = []
        self.history_lock = threading.RLock()
        
        logger.info(f"SemanticSearcher initialized: workers={self.max_workers}")
    
    def _chunk_text(self, text: str, chunk_size: int = 1000, overlap: int = 100) -> List[Tuple[str, int]]:
        """Split text into overlapping chunks.
        
        Args:
            text: Text to chunk
            chunk_size: Maximum size of each chunk
            overlap: Overlap between chunks
            
        Returns:
            List of (chunk_text, chunk_index) tuples
        """
        chunks = []
        
        if len(text) <= chunk_size:
            return [(text, 0)]
        
        start = 0
        chunk_index = 0
        
        while start < len(text):
            end = start + chunk_size
            chunk = text[start:end]
            chunks.append((chunk, chunk_index))
            
            # Move start position with overlap
            start = end - overlap
            if start >= len(text):
                break
                
            chunk_index += 1
        
        return chunks
    
    def _extract_semantic_concepts(self, content: str, language: str = None) -> List[str]:
        """Extract semantic concepts from content.
        
        Args:
            content: Text content to analyze
            language: Programming language (if any)
            
        Returns:
            List of semantic concepts
        """
        concepts = []
        
        try:
            import re
            
            if language == 'python':
                # Extract Python-specific concepts
                concepts.extend(re.findall(r'\b(?:def|class|import|from|try|except|with|as)\b', content))
                
                # Extract function and class names
                functions = re.findall(r'\bdef\s+(\w+)', content)
                classes = re.findall(r'\bclass\s+(\w+)', content)
                concepts.extend(functions)
                concepts.extend(classes)
                
            elif language in ['javascript', 'typescript']:
                # Extract JavaScript-specific concepts
                concepts.extend(re.findall(r'\b(?:function|const|let|var|if|else|for|while|try|catch)\b', content))
                
                # Extract function and variable names
                functions = re.findall(r'\bfunction\s+(\w+)|const\s+(\w+)', content)
                concepts.extend([f[0] or f[1] for f in functions if f[0] or f[1]])
            
            # Extract general concepts
            # Keywords and identifiers
            concepts.extend(re.findall(r'\b[a-zA-Z_][a-zA-Z0-9_]*\b', content))
            
            # Remove duplicates and filter
            concepts = list(set(concepts))
            concepts = [c for c in concepts if len(c) > 2]  # Filter short terms
            
        except Exception as e:
            logger.debug(f"Failed to extract semantic concepts: {e}")
        
        return concepts
    
    def index_file_content(self, file_path: str, content: str = None) -> int:
        """Index file content for semantic search.
        
        Args:
            file_path: Path to the file
            content: File content (if None, will be read from file)
            
        Returns:
            Number of chunks indexed
        """
        try:
            # Read content if not provided
            if content is None:
                try:
                    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                        content = f.read()
                except Exception as e:
                    logger.debug(f"Could not read file {file_path}: {e}")
                    return 0
            
            # Get file metadata
            file_type = 'text'
            language = 'text'
            if self.file_indexer:
                file_info = self.file_indexer.get_file_info(file_path)
                if file_info:
                    file_type = file_info.file_type
                    language = file_info.language
            
            # Skip binary files
            if file_type == 'binary':
                return 0
            
            # Chunk the content
            chunks = self._chunk_text(content)
            indexed_chunks = 0
            
            for chunk_text, chunk_index in chunks:
                # Generate chunk ID
                chunk_id = f"{hashlib.md5(file_path.encode()).hexdigest()}_{chunk_index}"
                
                # Generate embedding
                embedding = self.embedding_generator.generate_embedding(chunk_text)
                if embedding is None:
                    continue
                
                # Extract semantic concepts
                concepts = self._extract_semantic_concepts(chunk_text, language)
                
                # Store in vector database
                success = self.vector_db.store_embedding(
                    chunk_id=chunk_id,
                    file_path=file_path,
                    content=chunk_text,
                    embedding=embedding,
                    language=language,
                    file_type=file_type,
                    chunk_index=chunk_index,
                    semantic_concepts=concepts,
                    metadata={'file_size': len(content), 'chunk_size': len(chunk_text)}
                )
                
                if success:
                    indexed_chunks += 1
                    self.search_stats['embedding_generations'] += 1
            
            logger.debug(f"Indexed {indexed_chunks} chunks for {file_path}")
            return indexed_chunks
            
        except Exception as e:
            logger.error(f"Failed to index file content {file_path}: {e}")
            return 0
    
    def index_files_batch(self, file_paths: List[str]) -> Dict[str, int]:
        """Index multiple files in batch.
        
        Args:
            file_paths: List of file paths to index
            
        Returns:
            Dictionary mapping file paths to number of chunks indexed
        """
        results = {}
        
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            # Submit indexing tasks
            future_to_file = {
                executor.submit(self.index_file_content, file_path): file_path
                for file_path in file_paths
            }
            
            # Collect results
            for future in as_completed(future_to_file):
                file_path = future_to_file[future]
                try:
                    chunks_indexed = future.result()
                    results[file_path] = chunks_indexed
                except Exception as e:
                    logger.error(f"Error indexing {file_path}: {e}")
                    results[file_path] = 0
        
        return results
    
    def semantic_search(self, query: str, options: SemanticSearchOptions = None) -> SemanticSearchResult:
        """Perform semantic search.
        
        Args:
            query: Search query
            options: Search options
            
        Returns:
            SemanticSearchResult with matches
        """
        if options is None:
            options = SemanticSearchOptions()
        
        start_time = time.time()
        search_id = f"semantic_{int(time.time() * 1000000)}"
        
        try:
            logger.info(f"Starting semantic search: '{query}'")
            
            # Generate query embedding
            query_embedding = self.embedding_generator.generate_embedding(query)
            if query_embedding is None:
                raise ValueError("Failed to generate query embedding")
            
            # Search vector database
            raw_matches = self.vector_db.search_embeddings(
                query_embedding=query_embedding,
                similarity_threshold=options.similarity_threshold,
                max_results=options.max_results
            )
            
            # Process matches
            matches = []
            for chunk_id, file_path, similarity, content in raw_matches:
                # Get full chunk information
                chunk_info = self.vector_db.get_chunk_by_id(chunk_id)
                if not chunk_info:
                    continue
                
                _, _, language, file_type = chunk_info
                
                # Extract semantic concepts
                concepts = self._extract_semantic_concepts(content, language)
                
                # Create match object
                match = SemanticMatch(
                    file_path=file_path,
                    content=content,
                    similarity_score=similarity,
                    embedding_vector=query_embedding,  # Store query embedding for reference
                    semantic_concepts=concepts,
                    language=language or 'text',
                    file_type=file_type or 'text',
                    chunk_id=chunk_id,
                    context_window=content[:options.context_window],
                    metadata={}
                )
                
                matches.append(match)
            
            # Sort by similarity
            matches.sort(key=lambda x: x.similarity_score, reverse=True)
            
            # Apply final limits
            final_matches = matches[:options.max_results]
            
            # Calculate search time
            search_time = time.time() - start_time
            
            # Update statistics
            self.search_stats['total_searches'] += 1
            self.search_stats['total_matches'] += len(final_matches)
            
            # Update average search time
            total_searches = self.search_stats['total_searches']
            current_avg = self.search_stats['average_search_time']
            self.search_stats['average_search_time'] = (
                (current_avg * (total_searches - 1) + search_time) / total_searches
            )
            
            # Add to search history
            with self.history_lock:
                self.search_history.append({
                    'timestamp': time.time(),
                    'query': query,
                    'matches_found': len(final_matches),
                    'search_time': search_time,
                    'similarity_threshold': options.similarity_threshold
                })
                
                # Keep only recent history
                if len(self.search_history) > 100:
                    self.search_history = self.search_history[-100:]
            
            # Create result
            result = SemanticSearchResult(
                search_id=search_id,
                query=query,
                query_embedding=query_embedding,
                total_matches=len(final_matches),
                search_time=search_time,
                matches=final_matches,
                search_options=asdict(options)
            )
            
            logger.info(f"Semantic search completed: {len(final_matches)} matches in {search_time:.3f}s")
            return result
            
        except Exception as e:
            logger.error(f"Semantic search failed: {e}")
            raise
    
    def stream_semantic_search(self, query: str, options: SemanticSearchOptions = None) -> Generator[SemanticSearchResult, None, None]:
        """Stream semantic search results.
        
        Args:
            query: Search query
            options: Search options
            
        Yields:
            SemanticSearchResult with incremental results
        """
        if options is None:
            options = SemanticSearchOptions()
        
        start_time = time.time()
        search_id = f"semantic_stream_{int(time.time() * 1000000)}"
        
        try:
            logger.info(f"Starting streaming semantic search: '{query}'")
            
            # Generate query embedding
            query_embedding = self.embedding_generator.generate_embedding(query)
            if query_embedding is None:
                raise ValueError("Failed to generate query embedding")
            
            # Stream results from vector database
            raw_matches = self.vector_db.search_embeddings(
                query_embedding=query_embedding,
                similarity_threshold=options.similarity_threshold,
                max_results=options.max_results
            )
            
            # Process matches incrementally
            matches = []
            processed_count = 0
            
            for chunk_id, file_path, similarity, content in raw_matches:
                processed_count += 1
                
                # Process match
                chunk_info = self.vector_db.get_chunk_by_id(chunk_id)
                if chunk_info:
                    _, _, language, file_type = chunk_info
                    concepts = self._extract_semantic_concepts(content, language)
                    
                    match = SemanticMatch(
                        file_path=file_path,
                        content=content,
                        similarity_score=similarity,
                        embedding_vector=query_embedding,
                        semantic_concepts=concepts,
                        language=language or 'text',
                        file_type=file_type or 'text',
                        chunk_id=chunk_id,
                        context_window=content[:options.context_window],
                        metadata={}
                    )
                    
                    matches.append(match)
                
                # Sort and limit
                matches.sort(key=lambda x: x.similarity_score, reverse=True)
                
                # Yield incremental result
                if processed_count % 5 == 0 or len(matches) >= 10:
                    progress = min(processed_count / len(raw_matches), 1.0)
                    
                    result = SemanticSearchResult(
                        search_id=search_id,
                        query=query,
                        query_embedding=query_embedding,
                        total_matches=len(matches),
                        search_time=time.time() - start_time,
                        matches=matches[:options.max_results],
                        search_options=asdict(options),
                        progress=progress,
                        streaming=True
                    )
                    
                    yield result
            
            # Final result
            final_matches = matches[:options.max_results]
            yield SemanticSearchResult(
                search_id=search_id,
                query=query,
                query_embedding=query_embedding,
                total_matches=len(final_matches),
                search_time=time.time() - start_time,
                matches=final_matches,
                search_options=asdict(options),
                progress=1.0,
                streaming=False
            )
            
        except Exception as e:
            logger.error(f"Streaming semantic search failed: {e}")
            raise
    
    def get_search_suggestions(self, partial_query: str, limit: int = 10) -> List[str]:
        """Get search suggestions based on semantic understanding.
        
        Args:
            partial_query: Partial query to complete
            limit: Maximum number of suggestions
            
        Returns:
            List of suggested queries
        """
        suggestions = []
        
        try:
            # Get recent search history for suggestions
            with self.history_lock:
                recent_queries = [h['query'] for h in self.search_history[-20:]]
            
            # Simple suggestion logic
            for query in recent_queries:
                if (partial_query.lower() in query.lower() and 
                    query not in suggestions):
                    suggestions.append(query)
                    
                if len(suggestions) >= limit:
                    break
            
            # Add semantic suggestions based on concepts
            embedding = self.embedding_generator.generate_embedding(partial_query)
            if embedding:
                concept_matches = self._search_concepts(partial_query)
                suggestions.extend(concept_matches[:limit - len(suggestions)])
            
        except Exception as e:
            logger.debug(f"Failed to get search suggestions: {e}")
        
        return suggestions[:limit]
    
    def _search_concepts(self, query: str) -> List[str]:
        """Search for concepts related to the query."""
        # This is a simplified concept search
        # In a full implementation, this would query the semantic concepts stored in the vector database
        try:
            # Get recent embeddings and their concepts
            cursor = self.vector_db.conn.execute('''
                SELECT semantic_concepts FROM embeddings 
                WHERE semantic_concepts IS NOT NULL
                ORDER BY last_accessed DESC LIMIT 100
            ''')
            
            all_concepts = []
            for row in cursor.fetchall():
                concepts = json.loads(row[0])
                all_concepts.extend(concepts)
            
            # Find concept matches
            matching_concepts = []
            for concept in all_concepts:
                if query.lower() in concept.lower():
                    matching_concepts.append(concept)
            
            return list(set(matching_concepts))
            
        except Exception as e:
            logger.debug(f"Concept search failed: {e}")
            return []
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get semantic search statistics."""
        with self.history_lock:
            return {
                'search_stats': self.search_stats.copy(),
                'embedding_cache_size': len(self.embedding_generator.embedding_cache),
                'vector_db_stats': self.vector_db.get_statistics(),
                'recent_searches': len(self.search_history),
                'search_history_sample': self.search_history[-5:] if self.search_history else []
            }
    
    def cleanup(self):
        """Cleanup resources."""
        try:
            self.embedding_generator.clear_cache()
            self.vector_db.cleanup_old_chunks()
            logger.info("SemanticSearcher cleanup completed")
        except Exception as e:
            logger.error(f"Error during cleanup: {e}")


# Global semantic searcher instance
_global_semantic_searcher = None


def get_semantic_searcher(file_indexer=None, vector_db_path: str = None) -> SemanticSearcher:
    """
    Get a global semantic searcher instance.
    
    Args:
        file_indexer: FileIndexer instance
        vector_db_path: Path to vector database
        
    Returns:
        SemanticSearcher instance
    """
    global _global_semantic_searcher
    
    if _global_semantic_searcher is None:
        _global_semantic_searcher = SemanticSearcher(file_indexer, vector_db_path)
    
    return _global_semantic_searcher


if __name__ == "__main__":
    # Example usage
    print("NoodleCore Semantic Searcher Module")
    print("==================================")
    
    # Initialize semantic searcher
    from .file_indexer import get_file_indexer
    file_indexer = get_file_indexer()
    semantic_searcher = get_semantic_searcher(file_indexer)
    
    # Perform semantic search
    options = SemanticSearchOptions(
        similarity_threshold=0.7,
        max_results=20,
        context_window=300
    )
    
    result = semantic_searcher.semantic_search("function definition python", options)
    print(f"Found {result.total_matches} semantic matches in {result.search_time:.3f} seconds")
    
    # Display some matches
    for match in result.matches[:5]:
        print(f"  {match.file_path} - similarity: {match.similarity_score:.3f}")
        print(f"    concepts: {', '.join(match.semantic_concepts[:5])}")
    
    # Get statistics
    stats = semantic_searcher.get_statistics()
    print(f"Semantic search statistics: {stats}")
    
    # Cleanup
    semantic_searcher.cleanup()
    print("Semantic searcher demo completed")