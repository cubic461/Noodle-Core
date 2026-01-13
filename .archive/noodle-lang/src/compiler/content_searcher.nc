#!/usr/bin/env python3
"""
NoodleCore Content Searcher Module
=================================

Advanced text content search engine for file contents with support for
multiple search algorithms, fuzzy matching, and context extraction.
Designed for lightning-fast search across large file systems.

Features:
- Full-text search with regular expressions
- Fuzzy matching and typo tolerance
- Context extraction and preview generation
- Multi-language search support
- Incremental search result streaming
- Search result ranking and relevance scoring
- Integration with file indexer for efficient searches
- Support for case-insensitive and whole-word searches
- Search highlighting and navigation support

Author: NoodleCore Search Team
Version: 1.0.0
"""

import os
import time
import re
import logging
import threading
import sqlite3
import json
import difflib
from pathlib import Path
from typing import Dict, List, Optional, Set, Any, Tuple, Generator, NamedTuple
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from concurrent.futures import ThreadPoolExecutor, as_completed
import fnmatch

# Configure logging
logger = logging.getLogger(__name__)

# NoodleCore environment variables
NOODLE_DEBUG = os.environ.get("NOODLE_DEBUG", "0") == "1"
NOODLE_SEARCH_WORKERS = int(os.environ.get("NOODLE_SEARCH_WORKERS", "4"))
NOODLE_MAX_SEARCH_RESULTS = int(os.environ.get("NOODLE_MAX_SEARCH_RESULTS", "1000"))
NOODLE_CONTEXT_LINES = int(os.environ.get("NOODLE_CONTEXT_LINES", "3"))


@dataclass
class SearchMatch:
    """Represents a search match within a file."""
    file_path: str
    line_number: int
    column_start: int
    column_end: int
    matched_text: str
    context_before: str
    context_after: str
    line_text: str
    match_type: str  # 'exact', 'fuzzy', 'regex', 'case_insensitive'
    relevance_score: float
    file_type: str
    language: str


@dataclass
class SearchResult:
    """Represents a complete search result."""
    search_id: str
    query: str
    total_matches: int
    files_with_matches: int
    search_time: float
    matches: List[SearchMatch]
    search_type: str  # 'exact', 'fuzzy', 'regex', 'semantic'
    search_options: Dict[str, Any]
    progress: float = 0.0
    streaming: bool = False


@dataclass
class SearchOptions:
    """Configuration options for searches."""
    case_sensitive: bool = False
    whole_words: bool = False
    regex_enabled: bool = False
    fuzzy_matching: bool = False
    fuzzy_threshold: float = 0.6
    context_lines: int = NOODLE_CONTEXT_LINES
    max_results: int = NOODLE_MAX_SEARCH_RESULTS
    file_types: List[str] = None
    exclude_patterns: List[str] = None
    include_patterns: List[str] = None
    max_file_size: int = 10 * 1024 * 1024  # 10MB
    streaming: bool = True
    timeout: float = 30.0
    
    def __post_init__(self):
        if self.file_types is None:
            self.file_types = []
        if self.exclude_patterns is None:
            self.exclude_patterns = ['.git', '.svn', '__pycache__', 'node_modules', '.DS_Store']
        if self.include_patterns is None:
            self.include_patterns = ['*']


class ContentSearcher:
    """
    Advanced content search engine for NoodleCore search functionality.
    
    This class provides comprehensive text search capabilities including
    exact matching, fuzzy search, regular expressions, and context extraction.
    """
    
    def __init__(self, file_indexer=None):
        """Initialize the content searcher.
        
        Args:
            file_indexer: FileIndexer instance for file metadata
        """
        self.file_indexer = file_indexer
        self.max_workers = NOODLE_SEARCH_WORKERS
        self.max_results = NOODLE_MAX_SEARCH_RESULTS
        self.context_lines = NOODLE_CONTEXT_LINES
        
        # Search statistics
        self.search_stats = {
            'total_searches': 0,
            'total_matches': 0,
            'average_search_time': 0.0,
            'cache_hits': 0,
            'cache_misses': 0
        }
        
        # Content cache for frequently searched files
        self.content_cache: Dict[str, Tuple[str, float]] = {}  # path -> (content, timestamp)
        self.cache_lock = threading.RLock()
        self.max_cache_size = 1000
        self.cache_ttl = 300  # 5 minutes
        
        # Search history for analytics and optimization
        self.search_history: List[Dict[str, Any]] = []
        self.search_lock = threading.RLock()
        
        # Compiled regex patterns for performance
        self.compiled_patterns: Dict[str, re.Pattern] = {}
        
        logger.info(f"ContentSearcher initialized: workers={self.max_workers}, cache_size={self.max_cache_size}")
    
    def _should_include_file(self, file_path: str, options: SearchOptions) -> bool:
        """Check if a file should be included in the search."""
        try:
            path = Path(file_path)
            
            # Check exclude patterns
            for pattern in options.exclude_patterns:
                if any(part.startswith(pattern) for part in path.parts):
                    return False
                if fnmatch.fnmatch(path.name, pattern):
                    return False
            
            # Check include patterns
            if options.include_patterns:
                include_match = False
                for pattern in options.include_patterns:
                    if (fnmatch.fnmatch(path.name, pattern) or 
                        fnmatch.fnmatch(str(path), pattern)):
                        include_match = True
                        break
                if not include_match:
                    return False
            
            # Check file size
            if path.exists():
                stat = path.stat()
                if stat.st_size > options.max_file_size:
                    return False
            
            # Check file types if specified
            if options.file_types and self.file_indexer:
                file_entry = self.file_indexer.get_file_info(file_path)
                if file_entry and file_entry.file_type not in options.file_types:
                    return False
            
            return True
            
        except Exception as e:
            logger.debug(f"Error checking file inclusion for {file_path}: {e}")
            return False
    
    def _get_cached_content(self, file_path: str) -> Optional[str]:
        """Get cached file content if available and valid."""
        with self.cache_lock:
            cached = self.content_cache.get(file_path)
            if cached:
                content, timestamp = cached
                if time.time() - timestamp < self.cache_ttl:
                    self.search_stats['cache_hits'] += 1
                    return content
                else:
                    # Expired cache entry
                    del self.content_cache[file_path]
            
            self.search_stats['cache_misses'] += 1
            return None
    
    def _cache_content(self, file_path: str, content: str):
        """Cache file content with LRU eviction."""
        with self.cache_lock:
            # Add to cache
            self.content_cache[file_path] = (content, time.time())
            
            # Evict old entries if cache is full
            if len(self.content_cache) > self.max_cache_size:
                # Remove oldest entry
                oldest_key = min(self.content_cache.keys(), 
                               key=lambda k: self.content_cache[k][1])
                del self.content_cache[oldest_key]
    
    def _read_file_content(self, file_path: str) -> Optional[str]:
        """Read file content with caching and error handling."""
        # Check cache first
        cached_content = self._get_cached_content(file_path)
        if cached_content is not None:
            return cached_content
        
        try:
            # Try different encodings
            encodings = ['utf-8', 'latin-1', 'cp1252', 'iso-8859-1']
            
            for encoding in encodings:
                try:
                    with open(file_path, 'r', encoding=encoding, errors='ignore') as f:
                        content = f.read()
                    
                    # Cache successful read
                    self._cache_content(file_path, content)
                    return content
                    
                except UnicodeDecodeError:
                    continue
            
            logger.debug(f"Could not decode file: {file_path}")
            return None
            
        except Exception as e:
            logger.debug(f"Error reading file {file_path}: {e}")
            return None
    
    def _calculate_fuzzy_score(self, text: str, query: str) -> float:
        """Calculate fuzzy matching score using difflib."""
        # Use SequenceMatcher for similarity ratio
        ratio = difflib.SequenceMatcher(None, text.lower(), query.lower()).ratio()
        return ratio
    
    def _find_exact_matches(self, content: str, query: str, 
                          case_sensitive: bool, whole_words: bool) -> List[Tuple[int, int, str]]:
        """Find exact matches in content."""
        matches = []
        
        if not case_sensitive:
            content_lower = content.lower()
            query_lower = query.lower()
        else:
            content_lower = content
            query_lower = query
        
        start = 0
        while True:
            if whole_words:
                # Find word boundaries
                pattern = r'\b' + re.escape(query_lower) + r'\b'
                match = re.search(pattern, content_lower[start:], re.IGNORECASE if not case_sensitive else 0)
            else:
                match = content_lower.find(query_lower, start)
            
            if match == -1:
                break
            
            if isinstance(match, re.Match):
                start_pos = start + match.start()
                end_pos = start + match.end()
            else:
                start_pos = match
                end_pos = start_pos + len(query_lower)
            
            matched_text = content[start_pos:end_pos]
            matches.append((start_pos, end_pos, matched_text))
            
            start = end_pos if not isinstance(match, re.Match) else end_pos
        
        return matches
    
    def _find_regex_matches(self, content: str, pattern: str, 
                          case_sensitive: bool) -> List[Tuple[int, int, str]]:
        """Find regex matches in content."""
        matches = []
        
        try:
            flags = 0 if case_sensitive else re.IGNORECASE
            regex = re.compile(pattern, flags)
            
            for match in regex.finditer(content):
                start_pos = match.start()
                end_pos = match.end()
                matched_text = content[start_pos:end_pos]
                matches.append((start_pos, end_pos, matched_text))
                
        except re.error as e:
            logger.error(f"Invalid regex pattern '{pattern}': {e}")
        
        return matches
    
    def _find_fuzzy_matches(self, content: str, query: str, 
                          threshold: float) -> List[Tuple[int, int, str, float]]:
        """Find fuzzy matches in content."""
        matches = []
        
        # Split content into words and check each word
        words = re.findall(r'\w+', content.lower())
        query_words = query.lower().split()
        
        # For each word in content, check similarity with query
        for i, word in enumerate(words):
            for query_word in query_words:
                if len(query_word) < 3:  # Skip very short queries
                    continue
                
                score = self._calculate_fuzzy_score(word, query_word)
                if score >= threshold:
                    # Find the position of this word in the original content
                    word_start = content.lower().find(word, i * 10 if i > 0 else 0)  # Rough estimate
                    if word_start != -1:
                        word_end = word_start + len(word)
                        matches.append((word_start, word_end, word, score))
        
        return matches
    
    def _extract_context(self, content: str, line_number: int, 
                        start_col: int, end_col: int, context_lines: int) -> Tuple[str, str]:
        """Extract context around a match."""
        lines = content.split('\n')
        
        if not lines or line_number >= len(lines):
            return "", ""
        
        line = lines[line_number]
        
        # Extract context before and after the match
        context_before_start = max(0, start_col - 100)
        context_after_end = min(len(line), end_col + 100)
        
        context_before = line[context_before_start:start_col]
        context_after = line[end_col:context_after_end]
        
        # Add surrounding lines if requested
        if context_lines > 0:
            start_line = max(0, line_number - context_lines)
            end_line = min(len(lines), line_number + context_lines + 1)
            
            context_lines_before = []
            context_lines_after = []
            
            for i in range(start_line, line_number):
                context_lines_before.append(lines[i])
            
            for i in range(line_number + 1, end_line):
                context_lines_after.append(lines[i])
            
            before_context = '\n'.join(context_lines_before)
            after_context = '\n'.join(context_lines_after)
            
            return before_context, after_context
        
        return context_before, context_after
    
    def _calculate_relevance_score(self, match: SearchMatch, query: str) -> float:
        """Calculate relevance score for a search match."""
        score = 0.0
        
        # Base score from match type
        match_type_scores = {
            'exact': 1.0,
            'case_insensitive': 0.9,
            'whole_word': 0.95,
            'fuzzy': 0.7,
            'regex': 0.8
        }
        score += match_type_scores.get(match.match_type, 0.5)
        
        # Adjust for exactness of match
        if match.match_type == 'exact':
            if match.matched_text.lower() == query.lower():
                score += 0.2
        
        # Adjust for position in file (earlier is better)
        line_position = 1.0 / (match.line_number + 1)
        score += line_position * 0.1
        
        # Adjust for file type relevance
        if match.language in ['python', 'javascript', 'typescript', 'java']:
            score += 0.05  # Favor code files
        
        return min(score, 1.0)
    
    def search_content(self, query: str, options: SearchOptions = None) -> SearchResult:
        """Search for content in indexed files.
        
        Args:
            query: Search query string
            options: Search options and configuration
            
        Returns:
            SearchResult with matches and metadata
        """
        if options is None:
            options = SearchOptions()
        
        start_time = time.time()
        search_id = f"search_{int(time.time() * 1000000)}"
        
        try:
            logger.info(f"Starting content search: '{query}' with options: {options}")
            
            # Get files to search
            if self.file_indexer:
                files_to_search = self.file_indexer.search_files(limit=10000)  # Reasonable limit
            else:
                # Fallback to directory scanning
                files_to_search = []
                root_path = os.environ.get('NOODLE_INDEX_ROOT', '.')
                for root, dirs, files in os.walk(root_path):
                    for file in files:
                        file_path = os.path.join(root, file)
                        files_to_search.append(file_path)
            
            # Filter files based on options
            filtered_files = []
            for file_entry in files_to_search:
                if isinstance(file_entry, str):
                    file_path = file_entry
                else:
                    file_path = file_entry.path
                
                if self._should_include_file(file_path, options):
                    filtered_files.append(file_path)
            
            logger.info(f"Searching {len(filtered_files)} files for: '{query}'")
            
            # Perform search
            all_matches = []
            total_processed = 0
            
            with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
                # Submit search tasks
                future_to_file = {
                    executor.submit(self._search_file_content, file_path, query, options): file_path
                    for file_path in filtered_files[:options.max_results * 2]  # Reasonable limit
                }
                
                # Process results as they complete
                for future in as_completed(future_to_file):
                    file_path = future_to_file[future]
                    total_processed += 1
                    
                    try:
                        file_matches = future.result(timeout=options.timeout)
                        all_matches.extend(file_matches)
                        
                        # Update progress
                        if total_processed % 10 == 0:
                            progress = total_processed / len(filtered_files)
                            logger.debug(f"Search progress: {progress:.1%}")
                        
                        # Early termination if we have enough results
                        if len(all_matches) >= options.max_results:
                            logger.info(f"Reached maximum results limit: {options.max_results}")
                            break
                            
                    except Exception as e:
                        logger.debug(f"Error searching file {file_path}: {e}")
                        continue
            
            # Sort matches by relevance
            all_matches.sort(key=lambda x: x.relevance_score, reverse=True)
            
            # Apply final limits
            final_matches = all_matches[:options.max_results]
            
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
            with self.search_lock:
                self.search_history.append({
                    'timestamp': time.time(),
                    'query': query,
                    'matches_found': len(final_matches),
                    'search_time': search_time,
                    'files_searched': len(filtered_files),
                    'options': asdict(options)
                })
                
                # Keep only recent history (last 100 searches)
                if len(self.search_history) > 100:
                    self.search_history = self.search_history[-100:]
            
            # Create result
            result = SearchResult(
                search_id=search_id,
                query=query,
                total_matches=len(final_matches),
                files_with_matches=len(set(m.file_path for m in final_matches)),
                search_time=search_time,
                matches=final_matches,
                search_type='content',
                search_options=asdict(options),
                progress=1.0,
                streaming=False
            )
            
            logger.info(f"Content search completed: {len(final_matches)} matches in {search_time:.3f}s")
            return result
            
        except Exception as e:
            logger.error(f"Content search failed: {e}")
            raise
    
    def _search_file_content(self, file_path: str, query: str, 
                           options: SearchOptions) -> List[SearchMatch]:
        """Search content within a single file."""
        matches = []
        
        try:
            # Read file content
            content = self._read_file_content(file_path)
            if not content:
                return matches
            
            # Get file metadata
            file_type = 'text'
            language = 'text'
            if self.file_indexer:
                file_info = self.file_indexer.get_file_info(file_path)
                if file_info:
                    file_type = file_info.file_type
                    language = file_info.language
            
            # Determine search type and perform searches
            if options.regex_enabled:
                # Regex search
                file_matches = self._find_regex_matches(content, query, options.case_sensitive)
                match_type = 'regex'
            elif options.fuzzy_matching:
                # Fuzzy search
                file_matches = self._find_fuzzy_matches(content, query, options.fuzzy_threshold)
                match_type = 'fuzzy'
            else:
                # Exact search
                file_matches = self._find_exact_matches(content, query, 
                                                       options.case_sensitive, 
                                                       options.whole_words)
                match_type = 'exact'
                
                # Adjust match type for case sensitivity
                if not options.case_sensitive and any(match[2].lower() == query.lower() 
                                                     for match in file_matches):
                    match_type = 'case_insensitive'
            
            # Process matches
            lines = content.split('\n')
            
            for match_info in file_matches:
                if options.regex_enabled or options.fuzzy_matching:
                    start_pos, end_pos, matched_text, score = match_info
                else:
                    start_pos, end_pos, matched_text = match_info
                    score = 1.0
                
                # Find line number
                line_number = content[:start_pos].count('\n')
                
                # Ensure line number is valid
                if line_number >= len(lines):
                    continue
                
                line_text = lines[line_number]
                
                # Find column positions
                line_start = content.rfind('\n', 0, start_pos) + 1
                column_start = start_pos - line_start
                column_end = end_pos - line_start
                
                # Extract context
                context_before, context_after = self._extract_context(
                    content, line_number, column_start, column_end, options.context_lines
                )
                
                # Create match object
                match = SearchMatch(
                    file_path=file_path,
                    line_number=line_number + 1,  # 1-based line numbers
                    column_start=column_start + 1,  # 1-based column numbers
                    column_end=column_end,
                    matched_text=matched_text,
                    context_before=context_before,
                    context_after=context_after,
                    line_text=line_text,
                    match_type=match_type,
                    relevance_score=score,
                    file_type=file_type,
                    language=language
                )
                
                # Calculate final relevance score
                match.relevance_score = self._calculate_relevance_score(match, query)
                
                matches.append(match)
                
        except Exception as e:
            logger.debug(f"Error searching file {file_path}: {e}")
        
        return matches
    
    def stream_search(self, query: str, options: SearchOptions = None) -> Generator[SearchResult, None, None]:
        """Stream search results as they become available.
        
        Args:
            query: Search query string
            options: Search options and configuration
            
        Yields:
            SearchResult with incremental results
        """
        if options is None:
            options = SearchOptions()
        
        start_time = time.time()
        search_id = f"stream_{int(time.time() * 1000000)}"
        
        try:
            logger.info(f"Starting streaming content search: '{query}'")
            
            # Get files to search
            if self.file_indexer:
                files_to_search = self.file_indexer.search_files(limit=10000)
            else:
                files_to_search = []
                root_path = os.environ.get('NOODLE_INDEX_ROOT', '.')
                for root, dirs, files in os.walk(root_path):
                    for file in files:
                        file_path = os.path.join(root, file)
                        files_to_search.append(file_path)
            
            # Filter files
            filtered_files = []
            for file_entry in files_to_search:
                if isinstance(file_entry, str):
                    file_path = file_entry
                else:
                    file_path = file_entry.path
                
                if self._should_include_file(file_path, options):
                    filtered_files.append(file_path)
            
            # Stream results
            all_matches = []
            processed_files = 0
            files_with_matches = 0
            
            with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
                future_to_file = {
                    executor.submit(self._search_file_content, file_path, query, options): file_path
                    for file_path in filtered_files
                }
                
                for future in as_completed(future_to_file):
                    file_path = future_to_file[future]
                    processed_files += 1
                    
                    try:
                        file_matches = future.result(timeout=options.timeout)
                        all_matches.extend(file_matches)
                        
                        if file_matches:
                            files_with_matches += 1
                        
                        # Yield incremental results
                        if processed_files % 5 == 0 or file_matches:
                            progress = processed_files / len(filtered_files)
                            
                            # Sort and limit matches
                            all_matches.sort(key=lambda x: x.relevance_score, reverse=True)
                            current_matches = all_matches[:options.max_results]
                            
                            result = SearchResult(
                                search_id=search_id,
                                query=query,
                                total_matches=len(all_matches),
                                files_with_matches=files_with_matches,
                                search_time=time.time() - start_time,
                                matches=current_matches,
                                search_type='content',
                                search_options=asdict(options),
                                progress=progress,
                                streaming=True
                            )
                            
                            yield result
                        
                    except Exception as e:
                        logger.debug(f"Error searching file {file_path}: {e}")
                        continue
            
            # Final result
            all_matches.sort(key=lambda x: x.relevance_score, reverse=True)
            final_matches = all_matches[:options.max_results]
            
            yield SearchResult(
                search_id=search_id,
                query=query,
                total_matches=len(final_matches),
                files_with_matches=files_with_matches,
                search_time=time.time() - start_time,
                matches=final_matches,
                search_type='content',
                search_options=asdict(options),
                progress=1.0,
                streaming=False
            )
            
        except Exception as e:
            logger.error(f"Streaming search failed: {e}")
            raise
    
    def get_search_statistics(self) -> Dict[str, Any]:
        """Get search performance statistics."""
        with self.search_lock:
            return {
                'search_stats': self.search_stats.copy(),
                'cache_size': len(self.content_cache),
                'cache_hit_rate': (
                    self.search_stats['cache_hits'] / 
                    max(self.search_stats['cache_hits'] + self.search_stats['cache_misses'], 1)
                ),
                'recent_searches': len(self.search_history),
                'search_history_sample': self.search_history[-5:] if self.search_history else []
            }
    
    def clear_cache(self):
        """Clear the content cache."""
        with self.cache_lock:
            self.content_cache.clear()
            logger.info("Content cache cleared")
    
    def cleanup(self):
        """Cleanup resources."""
        self.clear_cache()
        logger.info("ContentSearcher cleanup completed")


# Global content searcher instance
_global_content_searcher = None


def get_content_searcher(file_indexer=None) -> ContentSearcher:
    """
    Get a global content searcher instance.
    
    Args:
        file_indexer: FileIndexer instance
        
    Returns:
        ContentSearcher instance
    """
    global _global_content_searcher
    
    if _global_content_searcher is None:
        _global_content_searcher = ContentSearcher(file_indexer)
    
    return _global_content_searcher


if __name__ == "__main__":
    # Example usage
    print("NoodleCore Content Searcher Module")
    print("=================================")
    
    # Initialize searcher
    from .file_indexer import get_file_indexer
    file_indexer = get_file_indexer()
    searcher = get_content_searcher(file_indexer)
    
    # Perform a search
    options = SearchOptions(
        case_sensitive=False,
        whole_words=True,
        context_lines=2,
        max_results=50
    )
    
    result = searcher.search_content("def", options)
    print(f"Found {result.total_matches} matches in {result.search_time:.3f} seconds")
    
    # Display some matches
    for match in result.matches[:5]:
        print(f"  {match.file_path}:{match.line_number} - {match.matched_text}")
    
    # Get statistics
    stats = searcher.get_search_statistics()
    print(f"Search statistics: {stats}")
    
    # Cleanup
    searcher.cleanup()
    print("Content searcher demo completed")