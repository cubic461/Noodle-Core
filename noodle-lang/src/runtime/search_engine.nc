#!/usr/bin/env python3
"""
NoodleCore Search Engine Module
==============================

Unified search orchestration engine that combines file indexing, content search,
semantic search, and caching to provide comprehensive search capabilities.
This is the main interface for all search operations in NoodleCore.

Features:
- Unified search interface for all search types
- Intelligent search type detection and routing
- Combined search results with relevance scoring
- Search result aggregation and deduplication
- Performance optimization and caching
- Integration with Monaco Editor
- Real-time search suggestions and completion
- Search analytics and optimization
- Multi-threading and async search support
- Advanced search result ranking

Author: NoodleCore Search Team
Version: 1.0.0
"""

import os
import time
import logging
import threading
import uuid
from typing import Dict, List, Optional, Set, Any, Tuple, Union
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from concurrent.futures import ThreadPoolExecutor, as_completed
from enum import Enum
import json
import hashlib

# Configure logging
logger = logging.getLogger(__name__)

# NoodleCore environment variables
NOODLE_DEBUG = os.environ.get("NOODLE_DEBUG", "0") == "1"
NOODLE_SEARCH_WORKERS = int(os.environ.get("NOODLE_SEARCH_WORKERS", "4"))
NOODLE_MAX_SEARCH_RESULTS = int(os.environ.get("NOODLE_MAX_SEARCH_RESULTS", "200"))
NOODLE_DEFAULT_TIMEOUT = float(os.environ.get("NOODLE_DEFAULT_TIMEOUT", "30.0"))


class SearchType(Enum):
    """Types of search operations."""
    FILES = "files"
    CONTENT = "content"
    SEMANTIC = "semantic"
    GLOBAL = "global"
    SUGGESTIONS = "suggestions"
    HISTORY = "history"


@dataclass
class SearchResult:
    """Unified search result."""
    search_id: str
    query: str
    search_type: str
    success: bool
    total_results: int
    results: List[Dict[str, Any]]
    search_time: float
    timestamp: str
    error: Optional[str] = None
    search_summary: Optional[Dict[str, Any]] = None
    performance: Optional[Dict[str, Any]] = None


class SimpleSearchCache:
    """Simple in-memory search result cache."""
    
    def __init__(self, max_size: int = 1000, ttl: int = 300):
        """Initialize cache.
        
        Args:
            max_size: Maximum number of cached results
            ttl: Time to live for cached results in seconds
        """
        self.cache: Dict[str, Tuple[Any, float]] = {}
        self.max_size = max_size
        self.ttl = ttl
        self.lock = threading.RLock()
    
    def get(self, key: str) -> Optional[Any]:
        """Get cached value."""
        with self.lock:
            if key in self.cache:
                value, timestamp = self.cache[key]
                if time.time() - timestamp < self.ttl:
                    return value
                else:
                    del self.cache[key]
            return None
    
    def set(self, key: str, value: Any, ttl: int = None) -> None:
        """Set cached value."""
        with self.lock:
            if len(self.cache) >= self.max_size:
                # Remove oldest entry
                oldest_key = min(self.cache.keys(), key=lambda k: self.cache[k][1])
                del self.cache[oldest_key]
            
            self.cache[key] = (value, time.time())
    
    def clear(self) -> None:
        """Clear all cached values."""
        with self.lock:
            self.cache.clear()


class SearchEngine:
    """
    Unified search engine for NoodleCore search functionality.
    
    This class provides a unified interface for all search operations,
    combining file indexing, content search, and semantic search.
    """
    
    def __init__(self, file_indexer=None, content_searcher=None, semantic_searcher=None):
        """Initialize the search engine.
        
        Args:
            file_indexer: FileIndexer instance
            content_searcher: ContentSearcher instance
            semantic_searcher: SemanticSearcher instance
        """
        # Initialize search components (will be lazy-loaded if not provided)
        self._file_indexer = file_indexer
        self._content_searcher = content_searcher
        self._semantic_searcher = semantic_searcher
        
        self.max_workers = NOODLE_SEARCH_WORKERS
        self.max_results = NOODLE_MAX_SEARCH_RESULTS
        self.default_timeout = NOODLE_DEFAULT_TIMEOUT
        
        # Initialize simple cache
        self.cache = SimpleSearchCache()
        
        # Search statistics
        self.search_stats = {
            'total_searches': 0,
            'searches_by_type': {t.value: 0 for t in SearchType},
            'total_results': 0,
            'average_search_time': 0.0,
            'cache_hits': 0,
            'cache_misses': 0,
            'failed_searches': 0
        }
        
        # Search history for analytics
        self.search_history: List[Dict[str, Any]] = []
        self.history_lock = threading.RLock()
        
        # Performance monitoring
        self.performance_metrics = {
            'fastest_search': float('inf'),
            'slowest_search': 0.0,
            'search_time_distribution': [],
            'results_per_search': [],
            'error_rate': 0.0
        }
        
        # Search configuration
        self.search_config = {
            'enable_caching': True,
            'enable_semantic_fallback': True,
            'enable_performance_monitoring': True,
            'default_search_timeout': self.default_timeout,
            'max_concurrent_searches': 10,
            'search_result_cache_ttl': 300  # 5 minutes
        }
        
        logger.info(f"SearchEngine initialized: workers={self.max_workers}, cache=enabled")
    
    @property
    def file_indexer(self):
        """Get file indexer, initializing if needed."""
        if self._file_indexer is None:
            try:
                from .file_indexer import get_file_indexer
                self._file_indexer = get_file_indexer()
            except Exception as e:
                logger.warning(f"Could not initialize file_indexer: {e}")
                self._file_indexer = None
        return self._file_indexer
    
    @property
    def content_searcher(self):
        """Get content searcher, initializing if needed."""
        if self._content_searcher is None:
            try:
                from .content_searcher import get_content_searcher
                self._content_searcher = get_content_searcher(self.file_indexer)
            except Exception as e:
                logger.warning(f"Could not initialize content_searcher: {e}")
                self._content_searcher = None
        return self._content_searcher
    
    @property
    def semantic_searcher(self):
        """Get semantic searcher, initializing if needed."""
        if self._semantic_searcher is None:
            try:
                from .semantic_searcher import get_semantic_searcher
                self._semantic_searcher = get_semantic_searcher(self.file_indexer)
            except Exception as e:
                logger.warning(f"Could not initialize semantic_searcher: {e}")
                self._semantic_searcher = None
        return self._semantic_searcher
    
    def search(self, query: str, search_type: Union[SearchType, str] = SearchType.GLOBAL,
               options: Dict[str, Any] = None) -> Dict[str, Any]:
        """Perform a unified search operation.
        
        Args:
            query: Search query string
            search_type: Type of search to perform
            options: Search options and configuration
            
        Returns:
            Dictionary containing search results and metadata
        """
        start_time = time.time()
        search_id = str(uuid.uuid4())
        
        try:
            # Normalize search type
            if isinstance(search_type, str):
                search_type = SearchType(search_type)
            
            # Merge options with defaults
            search_options = self._merge_search_options(options or {})
            
            logger.info(f"Starting {search_type.value} search: '{query}'")
            
            # Check cache first
            if self.search_config['enable_caching']:
                cached_result = self._get_cached_result(search_id, query, search_type, search_options)
                if cached_result:
                    self.search_stats['cache_hits'] += 1
                    logger.debug(f"Returning cached result for search {search_id}")
                    return cached_result
                
                self.search_stats['cache_misses'] += 1
            
            # Perform search based on type
            if search_type == SearchType.FILES:
                result = self._search_files(query, search_options)
            elif search_type == SearchType.CONTENT:
                result = self._search_content(query, search_options)
            elif search_type == SearchType.SEMANTIC:
                result = self._search_semantic(query, search_options)
            elif search_type == SearchType.GLOBAL:
                result = self._search_global(query, search_options)
            elif search_type == SearchType.SUGGESTIONS:
                result = self._search_suggestions(query, search_options)
            else:
                raise ValueError(f"Unknown search type: {search_type}")
            
            # Add search metadata
            search_time = time.time() - start_time
            result.update({
                'search_id': search_id,
                'query': query,
                'search_type': search_type.value,
                'search_time': search_time,
                'timestamp': datetime.utcnow().isoformat() + "Z",
                'options': search_options
            })
            
            # Cache the result
            if self.search_config['enable_caching']:
                self._cache_result(search_id, query, search_type, search_options, result)
            
            # Update statistics
            self._update_search_stats(search_type, result, search_time, True)
            
            logger.info(f"{search_type.value} search completed: {result.get('total_results', 0)} results in {search_time:.3f}s")
            return result
            
        except Exception as e:
            logger.error(f"Search failed for query '{query}': {e}")
            
            # Update statistics for failed search
            self._update_search_stats(search_type, {}, 0, False)
            
            # Return error result
            return {
                'search_id': search_id,
                'query': query,
                'search_type': search_type.value if isinstance(search_type, SearchType) else str(search_type),
                'success': False,
                'error': str(e),
                'search_time': time.time() - start_time,
                'timestamp': datetime.utcnow().isoformat() + "Z"
            }
    
    def _search_files(self, query: str, options: Dict[str, Any]) -> Dict[str, Any]:
        """Search for files by name and path."""
        try:
            if not self.file_indexer:
                return {
                    'success': False,
                    'error': 'File indexer not available',
                    'total_results': 0,
                    'results': []
                }
            
            # Extract search parameters
            file_type = options.get('file_type')
            language = options.get('language')
            min_size = options.get('min_size')
            max_size = options.get('max_size')
            modified_after = options.get('modified_after')
            limit = min(options.get('limit', 100), self.max_results)
            
            # Perform file search
            file_entries = self.file_indexer.search_files(
                query=query,
                file_type=file_type,
                language=language,
                min_size=min_size,
                max_size=max_size,
                modified_after=modified_after,
                limit=limit
            )
            
            # Format results
            results = []
            for entry in file_entries:
                results.append({
                    'file_id': entry.file_id,
                    'path': entry.path,
                    'filename': entry.filename,
                    'extension': entry.extension,
                    'size_bytes': entry.size_bytes,
                    'modified_time': entry.modified_time,
                    'file_type': entry.file_type,
                    'language': entry.language,
                    'relevance_score': self._calculate_file_relevance(query, entry),
                    'metadata': entry.metadata
                })
            
            return {
                'success': True,
                'total_results': len(results),
                'results': results,
                'search_summary': {
                    'files_found': len(results),
                    'search_criteria': {
                        'query': query,
                        'file_type': file_type,
                        'language': language,
                        'size_range': [min_size, max_size]
                    }
                }
            }
            
        except Exception as e:
            logger.error(f"File search failed: {e}")
            return {
                'success': False,
                'error': str(e),
                'total_results': 0,
                'results': []
            }
    
    def _search_content(self, query: str, options: Dict[str, Any]) -> Dict[str, Any]:
        """Search file contents for text matches."""
        try:
            if not self.content_searcher:
                return {
                    'success': False,
                    'error': 'Content searcher not available',
                    'total_results': 0,
                    'results': []
                }
            
            # Convert to ContentSearchOptions
            from .content_searcher import SearchOptions as ContentSearchOptions
            content_options = ContentSearchOptions(
                case_sensitive=options.get('case_sensitive', False),
                whole_words=options.get('whole_words', False),
                regex_enabled=options.get('regex_enabled', False),
                fuzzy_matching=options.get('fuzzy_matching', False),
                fuzzy_threshold=options.get('fuzzy_threshold', 0.6),
                context_lines=options.get('context_lines', 3),
                max_results=min(options.get('limit', 100), self.max_results),
                file_types=options.get('file_types'),
                exclude_patterns=options.get('exclude_patterns'),
                include_patterns=options.get('include_patterns'),
                max_file_size=options.get('max_file_size', 10 * 1024 * 1024),
                timeout=options.get('timeout', self.default_timeout)
            )
            
            # Perform content search
            search_result = self.content_searcher.search_content(query, content_options)
            
            # Format results
            results = []
            for match in search_result.matches:
                results.append({
                    'file_path': match.file_path,
                    'line_number': match.line_number,
                    'column_start': match.column_start,
                    'column_end': match.column_end,
                    'matched_text': match.matched_text,
                    'context_before': match.context_before,
                    'context_after': match.context_after,
                    'line_text': match.line_text,
                    'match_type': match.match_type,
                    'relevance_score': match.relevance_score,
                    'file_type': match.file_type,
                    'language': match.language
                })
            
            return {
                'success': True,
                'total_results': len(results),
                'results': results,
                'search_summary': {
                    'matches_found': len(results),
                    'files_with_matches': search_result.files_with_matches,
                    'search_criteria': {
                        'query': query,
                        'case_sensitive': content_options.case_sensitive,
                        'whole_words': content_options.whole_words,
                        'regex_enabled': content_options.regex_enabled,
                        'fuzzy_matching': content_options.fuzzy_matching
                    }
                }
            }
            
        except Exception as e:
            logger.error(f"Content search failed: {e}")
            return {
                'success': False,
                'error': str(e),
                'total_results': 0,
                'results': []
            }
    
    def _search_semantic(self, query: str, options: Dict[str, Any]) -> Dict[str, Any]:
        """Perform semantic search using AI and vector embeddings."""
        try:
            if not self.semantic_searcher:
                return {
                    'success': False,
                    'error': 'Semantic searcher not available',
                    'total_results': 0,
                    'results': []
                }
            
            # Convert to SemanticSearchOptions
            from .semantic_searcher import SemanticSearchOptions
            semantic_options = SemanticSearchOptions(
                similarity_threshold=options.get('similarity_threshold', 0.7),
                max_results=min(options.get('limit', 100), self.max_results),
                context_window=options.get('context_window', 500),
                include_metadata=options.get('include_metadata', True),
                ai_enhancement=options.get('ai_enhancement', True),
                timeout=options.get('timeout', self.default_timeout)
            )
            
            # Perform semantic search
            search_result = self.semantic_searcher.semantic_search(query, semantic_options)
            
            # Format results
            results = []
            for match in search_result.matches:
                results.append({
                    'file_path': match.file_path,
                    'content': match.content,
                    'similarity_score': match.similarity_score,
                    'semantic_concepts': match.semantic_concepts,
                    'language': match.language,
                    'file_type': match.file_type,
                    'chunk_id': match.chunk_id,
                    'context_window': match.context_window,
                    'relevance_score': match.similarity_score,  # Use similarity as relevance
                    'metadata': match.metadata
                })
            
            return {
                'success': True,
                'total_results': len(results),
                'results': results,
                'search_summary': {
                    'semantic_matches': len(results),
                    'query_embedding_dim': len(search_result.query_embedding) if search_result.query_embedding else 0,
                    'search_criteria': {
                        'query': query,
                        'similarity_threshold': semantic_options.similarity_threshold,
                        'ai_enhancement': semantic_options.ai_enhancement
                    }
                }
            }
            
        except Exception as e:
            logger.error(f"Semantic search failed: {e}")
            return {
                'success': False,
                'error': str(e),
                'total_results': 0,
                'results': []
            }
    
    def _search_global(self, query: str, options: Dict[str, Any]) -> Dict[str, Any]:
        """Perform global search across all search types."""
        try:
            start_time = time.time()
            
            # Determine search types to include
            search_types = options.get('search_types', ['files', 'content', 'semantic'])
            parallel = options.get('parallel', True)
            timeout = options.get('timeout', self.default_timeout)
            
            results = {}
            
            if parallel:
                # Execute searches in parallel
                with ThreadPoolExecutor(max_workers=min(len(search_types), self.max_workers)) as executor:
                    future_to_type = {
                        executor.submit(self.search, query, search_type, options): search_type
                        for search_type in search_types
                    }
                    
                    for future in as_completed(future_to_type):
                        search_type = future_to_type[future]
                        try:
                            result = future.result(timeout=timeout)
                            results[search_type] = result
                        except Exception as e:
                            logger.error(f"Parallel {search_type} search failed: {e}")
                            results[search_type] = {
                                'success': False,
                                'error': str(e),
                                'total_results': 0,
                                'results': []
                            }
            else:
                # Execute searches sequentially
                for search_type in search_types:
                    try:
                        result = self.search(query, search_type, options)
                        results[search_type] = result
                    except Exception as e:
                        logger.error(f"Sequential {search_type} search failed: {e}")
                        results[search_type] = {
                            'success': False,
                            'error': str(e),
                            'total_results': 0,
                            'results': []
                        }
            
            # Combine and deduplicate results
            combined_results = self._combine_search_results(results)
            
            # Calculate overall statistics
            total_time = time.time() - start_time
            total_results = sum(r.get('total_results', 0) for r in results.values())
            successful_searches = sum(1 for r in results.values() if r.get('success', False))
            
            return {
                'success': True,
                'total_results': total_results,
                'results': combined_results,
                'individual_results': results,
                'search_summary': {
                    'search_types': search_types,
                    'parallel_execution': parallel,
                    'successful_searches': successful_searches,
                    'total_searches': len(search_types),
                    'combined_results': len(combined_results)
                },
                'performance': {
                    'total_time': total_time,
                    'average_time_per_search': total_time / len(search_types)
                }
            }
            
        except Exception as e:
            logger.error(f"Global search failed: {e}")
            return {
                'success': False,
                'error': str(e),
                'total_results': 0,
                'results': []
            }
    
    def _search_suggestions(self, query: str, options: Dict[str, Any]) -> Dict[str, Any]:
        """Get search suggestions and completions."""
        try:
            limit = min(options.get('limit', 10), 50)
            
            suggestions = []
            
            # Get file name suggestions
            file_suggestions = self._get_file_suggestions(query, limit // 3)
            suggestions.extend(file_suggestions)
            
            # Get content suggestions
            if self.search_config['enable_semantic_fallback'] and self.semantic_searcher:
                content_suggestions = self.semantic_searcher.get_search_suggestions(query, limit // 3)
                suggestions.extend(content_suggestions)
            
            # Get recent search history suggestions
            history_suggestions = self._get_history_suggestions(query, limit // 3)
            suggestions.extend(history_suggestions)
            
            # Remove duplicates and limit
            unique_suggestions = list(dict.fromkeys(suggestions))[:limit]
            
            return {
                'success': True,
                'total_results': len(unique_suggestions),
                'results': [{'suggestion': s, 'type': self._classify_suggestion(s)} for s in unique_suggestions],
                'search_summary': {
                    'suggestions_found': len(unique_suggestions),
                    'search_criteria': {
                        'query': query,
                        'suggestion_types': ['filename', 'semantic', 'history']
                    }
                }
            }
            
        except Exception as e:
            logger.error(f"Suggestion search failed: {e}")
            return {
                'success': False,
                'error': str(e),
                'total_results': 0,
                'results': []
            }
    
    def _combine_search_results(self, results: Dict[str, Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Combine and deduplicate results from multiple search types."""
        combined = []
        seen_files = set()  # Track seen file paths to avoid duplicates
        
        # Priority order for results
        priority_order = ['semantic', 'content', 'files']
        
        for search_type in priority_order:
            if search_type not in results:
                continue
                
            result = results[search_type]
            if not result.get('success', False):
                continue
            
            for item in result.get('results', []):
                file_path = item.get('file_path') or item.get('path')
                if not file_path:
                    continue
                
                # Skip if we've already seen this file
                if file_path in seen_files:
                    continue
                
                # Add search type to metadata
                item['search_types'] = [search_type]
                item['primary_search_type'] = search_type
                
                # Calculate combined relevance score
                item['combined_relevance_score'] = self._calculate_combined_relevance(item, search_type)
                
                combined.append(item)
                seen_files.add(file_path)
        
        # Sort by combined relevance score
        combined.sort(key=lambda x: x.get('combined_relevance_score', 0), reverse=True)
        
        return combined
    
    def _calculate_file_relevance(self, query: str, file_entry) -> float:
        """Calculate relevance score for a file entry."""
        score = 0.0
        query_lower = query.lower()
        
        # Exact filename match gets highest score
        if file_entry.filename.lower() == query_lower:
            score += 1.0
        elif file_entry.filename.lower().startswith(query_lower):
            score += 0.8
        elif query_lower in file_entry.filename.lower():
            score += 0.6
        
        # Path component matches
        if query_lower in file_entry.path.lower():
            score += 0.4
        
        # Extension match
        if query_lower in (file_entry.extension or '').lower():
            score += 0.3
        
        # Recent files get slight boost
        import time
        current_time = time.time()
        age_hours = (current_time - file_entry.modified_time) / 3600
        if age_hours < 24:  # Files modified in last 24 hours
            score += 0.1
        
        return min(score, 1.0)
    
    def _calculate_combined_relevance(self, item: Dict[str, Any], search_type: str) -> float:
        """Calculate combined relevance score for aggregated results."""
        base_score = item.get('relevance_score', 0.0)
        
        # Boost semantic results slightly as they're more intelligent
        if search_type == 'semantic':
            base_score *= 1.1
        elif search_type == 'content':
            base_score *= 1.0
        elif search_type == 'files':
            base_score *= 0.9
        
        return min(base_score, 1.0)
    
    def _get_file_suggestions(self, query: str, limit: int) -> List[str]:
        """Get file name suggestions."""
        try:
            if not self.file_indexer:
                return []
            
            # Search for files that start with or contain the query
            files = self.file_indexer.search_files(query=query, limit=limit * 2)
            suggestions = []
            
            for file_entry in files:
                if file_entry.filename.lower().startswith(query.lower()):
                    suggestions.append(file_entry.filename)
                elif query.lower() in file_entry.filename.lower():
                    suggestions.append(file_entry.filename)
            
            return suggestions[:limit]
            
        except Exception as e:
            logger.debug(f"File suggestions failed: {e}")
            return []
    
    def _get_history_suggestions(self, query: str, limit: int) -> List[str]:
        """Get suggestions from search history."""
        try:
            with self.history_lock:
                recent_searches = [h['query'] for h in self.search_history[-50:]]
            
            suggestions = []
            query_lower = query.lower()
            
            for search_query in recent_searches:
                if (query_lower in search_query.lower() and 
                    search_query not in suggestions):
                    suggestions.append(search_query)
                
                if len(suggestions) >= limit:
                    break
            
            return suggestions
            
        except Exception as e:
            logger.debug(f"History suggestions failed: {e}")
            return []
    
    def _classify_suggestion(self, suggestion: str) -> str:
        """Classify the type of a suggestion."""
        if '.' in suggestion:
            return 'filename'
        elif ' ' in suggestion and len(suggestion.split()) > 1:
            return 'phrase'
        else:
            return 'keyword'
    
    def _merge_search_options(self, options: Dict[str, Any]) -> Dict[str, Any]:
        """Merge user options with defaults."""
        merged = {
            'limit': min(options.get('limit', 100), self.max_results),
            'timeout': options.get('timeout', self.default_timeout),
            'cache_results': options.get('cache_results', True),
            'include_metadata': options.get('include_metadata', True)
        }
        
        # Add all other options
        merged.update(options)
        
        return merged
    
    def _get_cached_result(self, search_id: str, query: str, 
                          search_type: SearchType, options: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Get cached search result if available."""
        try:
            cache_key = self._generate_cache_key(query, search_type, options)
            return self.cache.get(cache_key)
        except Exception as e:
            logger.debug(f"Cache retrieval failed: {e}")
            return None
    
    def _cache_result(self, search_id: str, query: str, 
                     search_type: SearchType, options: Dict[str, Any], 
                     result: Dict[str, Any]):
        """Cache search result."""
        try:
            cache_key = self._generate_cache_key(query, search_type, options)
            ttl = options.get('cache_ttl', self.search_config['search_result_cache_ttl'])
            self.cache.set(cache_key, result, ttl)
        except Exception as e:
            logger.debug(f"Cache storage failed: {e}")
    
    def _generate_cache_key(self, query: str, search_type: SearchType, options: Dict[str, Any]) -> str:
        """Generate cache key for search."""
        # Create cache key from query, type, and relevant options
        cache_data = {
            'query': query,
            'type': search_type.value,
            'options': {k: v for k, v in options.items() 
                       if k in ['limit', 'file_type', 'language', 'case_sensitive']}
        }
        
        cache_string = json.dumps(cache_data, sort_keys=True)
        return hashlib.md5(cache_string.encode()).hexdigest()
    
    def _update_search_stats(self, search_type: SearchType, result: Dict[str, Any], 
                           search_time: float, success: bool):
        """Update search statistics."""
        with self.history_lock:
            # Update basic stats
            self.search_stats['total_searches'] += 1
            self.search_stats['searches_by_type'][search_type.value] += 1
            
            if success:
                self.search_stats['total_results'] += result.get('total_results', 0)
                
                # Update average search time
                total_searches = self.search_stats['total_searches']
                current_avg = self.search_stats['average_search_time']
                self.search_stats['average_search_time'] = (
                    (current_avg * (total_searches - 1) + search_time) / total_searches
                )
                
                # Update performance metrics
                self.performance_metrics['fastest_search'] = min(
                    self.performance_metrics['fastest_search'], search_time
                )
                self.performance_metrics['slowest_search'] = max(
                    self.performance_metrics['slowest_search'], search_time
                )
                self.performance_metrics['search_time_distribution'].append(search_time)
                self.performance_metrics['results_per_search'].append(result.get('total_results', 0))
                
                # Keep only recent data
                if len(self.performance_metrics['search_time_distribution']) > 1000:
                    self.performance_metrics['search_time_distribution'] = \
                        self.performance_metrics['search_time_distribution'][-500:]
                    self.performance_metrics['results_per_search'] = \
                        self.performance_metrics['results_per_search'][-500:]
            else:
                self.search_stats['failed_searches'] += 1
            
            # Update error rate
            total = self.search_stats['total_searches']
            failed = self.search_stats['failed_searches']
            self.performance_metrics['error_rate'] = failed / max(total, 1)
            
            # Add to search history
            self.search_history.append({
                'timestamp': time.time(),
                'search_type': search_type.value,
                'success': success,
                'search_time': search_time,
                'results_count': result.get('total_results', 0)
            })
            
            # Keep only recent history
            if len(self.search_history) > 1000:
                self.search_history = self.search_history[-500:]
    
    def get_search_statistics(self) -> Dict[str, Any]:
        """Get comprehensive search engine statistics."""
        with self.history_lock:
            component_stats = {}
            
            # Get component statistics if available
            if self.file_indexer:
                try:
                    component_stats['file_indexer'] = self.file_indexer.get_statistics()
                except:
                    pass
            
            if self.content_searcher:
                try:
                    component_stats['content_searcher'] = self.content_searcher.get_search_statistics()
                except:
                    pass
            
            if self.semantic_searcher:
                try:
                    component_stats['semantic_searcher'] = self.semantic_searcher.get_statistics()
                except:
                    pass
            
            return {
                'search_stats': self.search_stats.copy(),
                'performance_metrics': self.performance_metrics.copy(),
                'search_config': self.search_config.copy(),
                'recent_searches': len(self.search_history),
                'search_history_sample': self.search_history[-10:] if self.search_history else [],
                'component_stats': component_stats
            }
    
    def configure_search_engine(self, **config):
        """Configure search engine settings."""
        for key, value in config.items():
            if key in self.search_config:
                self.search_config[key] = value
                logger.info(f"Updated search config: {key} = {value}")
            else:
                logger.warning(f"Unknown search config: {key}")
    
    def clear_caches(self):
        """Clear all search caches."""
        self.cache.clear()
        
        if self.content_searcher:
            try:
                self.content_searcher.clear_cache()
            except:
                pass
        
        if self.semantic_searcher:
            try:
                self.semantic_searcher.cleanup()
            except:
                pass
        
        logger.info("All search caches cleared")
    
    def cleanup(self):
        """Cleanup search engine resources."""
        self.clear_caches()
        logger.info("SearchEngine cleanup completed")


# Global search engine instance
_global_search_engine = None


def get_search_engine(file_indexer=None, content_searcher=None, semantic_searcher=None) -> SearchEngine:
    """
    Get a global search engine instance.
    
    Args:
        file_indexer: FileIndexer instance
        content_searcher: ContentSearcher instance
        semantic_searcher: SemanticSearcher instance
        
    Returns:
        SearchEngine instance
    """
    global _global_search_engine
    
    if _global_search_engine is None:
        _global_search_engine = SearchEngine(file_indexer, content_searcher, semantic_searcher)
    
    return _global_search_engine


if __name__ == "__main__":
    # Example usage
    print("NoodleCore Search Engine Module")
    print("===============================")
    
    # Initialize search engine
    search_engine = get_search_engine()
    
    # Test different search types
    queries = [
        "python function",
        "class definition",
        "config file",
        "import statement"
    ]
    
    for query in queries:
        print(f"\nTesting search: '{query}'")
        
        # Global search
        result = search_engine.search(query, SearchType.GLOBAL)
        print(f"Global search: {result['total_results']} results in {result['search_time']:.3f}s")
        
        # Content search
        content_result = search_engine.search(query, SearchType.CONTENT)
        print(f"Content search: {content_result['total_results']} results in {content_result['search_time']:.3f}s")
        
        # File search
        file_result = search_engine.search(query, SearchType.FILES)
        print(f"File search: {file_result['total_results']} results in {file_result['search_time']:.3f}s")
    
    # Get statistics
    stats = search_engine.get_search_statistics()
    print(f"\nSearch engine statistics:")
    print(f"Total searches: {stats['search_stats']['total_searches']}")
    print(f"Average search time: {stats['search_stats']['average_search_time']:.3f}s")
    print(f"Cache hit rate: {stats['search_stats']['cache_hits'] / max(stats['search_stats']['cache_hits'] + stats['search_stats']['cache_misses'], 1):.2%}")
    
    # Cleanup
    search_engine.cleanup()
    print("\nSearch engine demo completed")