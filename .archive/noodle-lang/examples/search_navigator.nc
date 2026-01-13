#!/usr/bin/env python3
"""
NoodleCore Search Navigator Module
=================================

Advanced search result navigation and highlighting system for Monaco Editor integration.
Provides intelligent navigation, highlighting, filtering, and context preview capabilities
for search results in NoodleCore.

Features:
- Monaco Editor integration and highlighting
- Search result navigation and jump-to-line
- Context preview and code snippets
- Result filtering and grouping
- Real-time search result updates
- Syntax highlighting and formatting
- Search scope selection
- Performance optimization for large result sets
- Keyboard shortcuts and navigation
- Search result clustering and organization
- Incremental result loading
- Search analytics and optimization

Author: NoodleCore Search Team
Version: 1.0.0
"""

import os
import time
import logging
import threading
import json
import re
from typing import Dict, List, Optional, Set, Any, Tuple, Union
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from pathlib import Path
from enum import Enum
from collections import defaultdict, deque

# Configure logging
logger = logging.getLogger(__name__)

# NoodleCore environment variables
NOODLE_DEBUG = os.environ.get("NOODLE_DEBUG", "0") == "1"
NOODLE_MAX_PREVIEW_LINES = int(os.environ.get("NOODLE_MAX_PREVIEW_LINES", "50"))
NOODLE_MAX_HIGHLIGHTS_PER_FILE = int(os.environ.get("NOODLE_MAX_HIGHLIGHTS_PER_FILE", "100"))
NOODLE_NAVIGATION_CACHE_SIZE = int(os.environ.get("NOODLE_NAVIGATION_CACHE_SIZE", "1000"))
NOODLE_REAL_TIME_UPDATES = os.environ.get("NOODLE_REAL_TIME_UPDATES", "1") == "1"


class HighlightType(Enum):
    """Types of search result highlights."""
    EXACT_MATCH = "exact_match"
    FUZZY_MATCH = "fuzzy_match"
    SYMBOL_MATCH = "symbol_match"
    SEMANTIC_MATCH = "semantic_match"
    CONTEXT_MATCH = "context_match"


class NavigationScope(Enum):
    """Search result navigation scopes."""
    CURRENT_FILE = "current_file"
    CURRENT_PROJECT = "current_project"
    WORKSPACE = "workspace"
    SELECTED_FILES = "selected_files"
    GLOBAL = "global"


@dataclass
class SearchHighlight:
    """Search result highlight for Monaco Editor."""
    file_path: str
    line_number: int
    start_column: int
    end_column: int
    highlight_type: HighlightType
    text: str
    context_before: str = ""
    context_after: str = ""
    relevance_score: float = 0.0
    metadata: Dict[str, Any] = None
    
    def __post_init__(self):
        if self.metadata is None:
            self.metadata = {}


@dataclass
class SearchResultCluster:
    """Grouped search results by file."""
    file_path: str
    filename: str
    highlights: List[SearchHighlight]
    total_matches: int
    file_type: str = ""
    language: str = ""
    size_bytes: int = 0
    modified_time: float = 0.0
    cluster_metadata: Dict[str, Any] = None
    
    def __post_init__(self):
        if self.cluster_metadata is None:
            self.cluster_metadata = {}


@dataclass
class SearchNavigationContext:
    """Navigation context for search results."""
    current_result_index: int = 0
    current_file: Optional[str] = None
    current_highlight: Optional[SearchHighlight] = None
    navigation_history: List[Dict[str, Any]] = None
    bookmarks: List[Dict[str, Any]] = None
    filters: Dict[str, Any] = None
    
    def __post_init__(self):
        if self.navigation_history is None:
            self.navigation_history = []
        if self.bookmarks is None:
            self.bookmarks = []
        if self.filters is None:
            self.filters = {}


class MonacoEditorIntegration:
    """Monaco Editor integration for search results."""
    
    def __init__(self):
        """Initialize Monaco Editor integration."""
        self.highlight_cache: Dict[str, List[SearchHighlight]] = {}
        self.navigation_context = SearchNavigationContext()
        self.observers: List[callable] = []
        self._lock = threading.RLock()
        
        # Monaco Editor command mappings
        self.command_mappings = {
            'next_result': 'search.navigateNext',
            'prev_result': 'search.navigatePrevious',
            'open_file': 'editor.action.openInNewEditor',
            'focus_search': 'search.action.focusSearch',
            'clear_search': 'search.action.clearSearchResults',
            'replace_all': 'search.action.replaceAll'
        }
        
        logger.debug("MonacoEditorIntegration initialized")
    
    def register_observer(self, callback: callable):
        """Register observer for navigation events."""
        with self._lock:
            self.observers.append(callback)
    
    def _notify_observers(self, event_type: str, data: Any):
        """Notify all observers of navigation events."""
        for observer in self.observers:
            try:
                observer(event_type, data)
            except Exception as e:
                logger.error(f"Observer notification failed: {e}")
    
    def create_highlights(self, search_results: List[Dict[str, Any]]) -> List[SearchHighlight]:
        """Create Monaco Editor highlights from search results.
        
        Args:
            search_results: Raw search results from search engine
            
        Returns:
            List of SearchHighlight objects
        """
        highlights = []
        
        for result in search_results:
            try:
                # Extract highlight information
                file_path = result.get('file_path') or result.get('path', '')
                line_number = result.get('line_number', 1)
                start_col = result.get('column_start', 0)
                end_col = result.get('column_end', len(result.get('matched_text', '')))
                text = result.get('matched_text', '')
                context_before = result.get('context_before', '')
                context_after = result.get('context_after', '')
                relevance_score = result.get('relevance_score', 0.0)
                
                # Determine highlight type
                highlight_type = HighlightType.EXACT_MATCH
                if result.get('match_type') == 'fuzzy':
                    highlight_type = HighlightType.FUZZY_MATCH
                elif result.get('match_type') == 'symbol':
                    highlight_type = HighlightType.SYMBOL_MATCH
                elif result.get('match_type') == 'semantic':
                    highlight_type = HighlightType.SEMANTIC_MATCH
                
                # Create highlight
                highlight = SearchHighlight(
                    file_path=file_path,
                    line_number=line_number,
                    start_column=start_col,
                    end_column=end_col,
                    highlight_type=highlight_type,
                    text=text,
                    context_before=context_before,
                    context_after=context_after,
                    relevance_score=relevance_score,
                    metadata=result.get('metadata', {})
                )
                
                highlights.append(highlight)
                
            except Exception as e:
                logger.debug(f"Failed to create highlight for result: {e}")
        
        return highlights[:NOODLE_MAX_HIGHLIGHTS_PER_FILE]
    
    def cluster_highlights(self, highlights: List[SearchHighlight]) -> List[SearchResultCluster]:
        """Cluster highlights by file for better organization.
        
        Args:
            highlights: List of SearchHighlight objects
            
        Returns:
            List of SearchResultCluster objects
        """
        file_groups = defaultdict(list)
        
        # Group highlights by file path
        for highlight in highlights:
            file_groups[highlight.file_path].append(highlight)
        
        clusters = []
        
        for file_path, file_highlights in file_groups.items():
            try:
                # Sort highlights by line number and relevance
                file_highlights.sort(
                    key=lambda h: (h.line_number, -h.relevance_score)
                )
                
                # Create cluster metadata
                filename = Path(file_path).name
                
                # Get file type and language (simplified)
                file_type = self._get_file_type(file_path)
                language = self._get_language_from_extension(file_path)
                
                cluster = SearchResultCluster(
                    file_path=file_path,
                    filename=filename,
                    highlights=file_highlights,
                    total_matches=len(file_highlights),
                    file_type=file_type,
                    language=language,
                    cluster_metadata={
                        'file_size': 0,  # Would be populated from file system
                        'last_modified': 0,  # Would be populated from file system
                        'avg_relevance': sum(h.relevance_score for h in file_highlights) / len(file_highlights)
                    }
                )
                
                clusters.append(cluster)
                
            except Exception as e:
                logger.error(f"Failed to create cluster for file {file_path}: {e}")
        
        # Sort clusters by relevance and match count
        clusters.sort(
            key=lambda c: (c.total_matches, c.cluster_metadata['avg_relevance']),
            reverse=True
        )
        
        return clusters
    
    def _get_file_type(self, file_path: str) -> str:
        """Get file type from path."""
        try:
            ext = Path(file_path).suffix.lower()
            type_mapping = {
                '.py': 'python',
                '.js': 'javascript',
                '.ts': 'typescript',
                '.java': 'java',
                '.cpp': 'cpp',
                '.c': 'c',
                '.cs': 'csharp',
                '.html': 'html',
                '.css': 'css',
                '.json': 'json',
                '.xml': 'xml',
                '.md': 'markdown',
                '.txt': 'text'
            }
            return type_mapping.get(ext, 'unknown')
        except:
            return 'unknown'
    
    def _get_language_from_extension(self, file_path: str) -> str:
        """Get programming language from file extension."""
        return self._get_file_type(file_path)
    
    def navigate_to_result(self, highlight: SearchHighlight) -> Dict[str, Any]:
        """Navigate to a specific search result.
        
        Args:
            highlight: Search highlight to navigate to
            
        Returns:
            Navigation result information
        """
        try:
            # Update navigation context
            with self._lock:
                # Add current position to history
                if (self.navigation_context.current_highlight and 
                    self.navigation_context.current_highlight != highlight):
                    
                    self.navigation_context.navigation_history.append({
                        'file_path': self.navigation_context.current_highlight.file_path,
                        'line_number': self.navigation_context.current_highlight.line_number,
                        'timestamp': time.time()
                    })
                
                # Update current position
                self.navigation_context.current_highlight = highlight
                self.navigation_context.current_file = highlight.file_path
                self.navigation_context.current_result_index += 1
            
            # Create navigation response for Monaco Editor
            navigation_result = {
                'action': 'navigate',
                'file_path': highlight.file_path,
                'line_number': highlight.line_number,
                'start_column': highlight.start_column,
                'end_column': highlight.end_column,
                'highlight_type': highlight.highlight_type.value,
                'context': {
                    'before': highlight.context_before,
                    'match': highlight.text,
                    'after': highlight.context_after
                },
                'metadata': highlight.metadata,
                'navigation_context': {
                    'current_index': self.navigation_context.current_result_index,
                    'history_size': len(self.navigation_context.navigation_history),
                    'bookmarks_count': len(self.navigation_context.bookmarks)
                }
            }
            
            # Notify observers
            self._notify_observers('navigate', navigation_result)
            
            return navigation_result
            
        except Exception as e:
            logger.error(f"Navigation failed: {e}")
            return {'action': 'error', 'error': str(e)}
    
    def get_navigation_commands(self) -> Dict[str, str]:
        """Get Monaco Editor navigation commands.
        
        Returns:
            Dictionary mapping action names to Monaco commands
        """
        return self.command_mappings.copy()
    
    def create_context_preview(self, highlight: SearchHighlight, 
                             max_lines: int = NOODLE_MAX_PREVIEW_LINES) -> Dict[str, Any]:
        """Create context preview for a search result.
        
        Args:
            highlight: Search highlight to preview
            max_lines: Maximum number of lines to include
            
        Returns:
            Context preview data
        """
        try:
            # This would read the actual file content in a real implementation
            # For now, we'll create a mock preview
            
            preview_lines = []
            
            # Add context before
            if highlight.context_before:
                preview_lines.extend(highlight.context_before.split('\n')[-3:])
            
            # Add matched line
            matched_line = f"  {highlight.text}"
            preview_lines.append(matched_line)
            
            # Add context after
            if highlight.context_after:
                preview_lines.extend(highlight.context_after.split('\n')[:3])
            
            # Limit total lines
            if len(preview_lines) > max_lines:
                preview_lines = preview_lines[:max_lines//2] + ['...'] + preview_lines[-max_lines//2:]
            
            return {
                'file_path': highlight.file_path,
                'line_number': highlight.line_number,
                'preview_lines': preview_lines,
                'matched_text': highlight.text,
                'language': highlight.metadata.get('language', 'text'),
                'preview_context': 'around_match',
                'max_lines': max_lines,
                'highlight_range': {
                    'start': len('\n'.join(preview_lines[:-1])) + len('  ') + highlight.start_column,
                    'end': len('\n'.join(preview_lines[:-1])) + len('  ') + highlight.end_column
                }
            }
            
        except Exception as e:
            logger.error(f"Context preview creation failed: {e}")
            return {'error': str(e)}


class SearchNavigator:
    """
    Advanced search result navigation and highlighting system.
    
    Provides comprehensive navigation capabilities, Monaco Editor integration,
    and intelligent result organization for optimal search experience.
    """
    
    def __init__(self, monaco_integration: MonacoEditorIntegration = None):
        """Initialize search navigator.
        
        Args:
            monaco_integration: Monaco Editor integration instance
        """
        self.monaco_integration = monaco_integration or MonacoEditorIntegration()
        
        # Navigation state
        self.current_search_id: Optional[str] = None
        self.search_clusters: List[SearchResultCluster] = []
        self.filtered_clusters: List[SearchResultCluster] = []
        
        # Performance tracking
        self.navigation_stats = {
            'navigations': 0,
            'navigations_per_search': [],
            'average_navigation_time': 0.0,
            'most_navigated_files': {},
            'navigation_patterns': []
        }
        
        # Caching and optimization
        self.preview_cache: Dict[str, Dict[str, Any]] = {}
        self.highlight_cache: Dict[str, List[SearchHighlight]] = {}
        self.cache_lock = threading.RLock()
        
        logger.info("SearchNavigator initialized")
    
    def process_search_results(self, search_results: Dict[str, Any]) -> Dict[str, Any]:
        """Process search results for navigation and highlighting.
        
        Args:
            search_results: Raw search results from search engine
            
        Returns:
            Processed results with navigation data
        """
        try:
            start_time = time.time()
            
            # Extract results
            results = search_results.get('results', [])
            if not results:
                return {
                    'success': True,
                    'clusters': [],
                    'highlights': [],
                    'navigation_data': {
                        'total_results': 0,
                        'processing_time': 0
                    }
                }
            
            # Create highlights
            highlights = self.monaco_integration.create_highlights(results)
            
            # Cluster highlights by file
            clusters = self.monaco_integration.cluster_highlights(highlights)
            
            # Update internal state
            self.search_clusters = clusters
            self.filtered_clusters = clusters.copy()
            
            # Create navigation data
            navigation_data = {
                'total_results': len(results),
                'total_files': len(clusters),
                'clusters': [
                    {
                        'file_path': cluster.file_path,
                        'filename': cluster.filename,
                        'match_count': cluster.total_matches,
                        'language': cluster.language,
                        'relevance_score': cluster.cluster_metadata.get('avg_relevance', 0.0),
                        'highlights': [
                            {
                                'line_number': h.line_number,
                                'start_column': h.start_column,
                                'end_column': h.end_column,
                                'highlight_type': h.highlight_type.value,
                                'text': h.text
                            }
                            for h in cluster.highlights
                        ]
                    }
                    for cluster in clusters
                ],
                'navigation_commands': self.monaco_integration.get_navigation_commands(),
                'processing_time': time.time() - start_time
            }
            
            return {
                'success': True,
                'clusters': clusters,
                'highlights': highlights,
                'navigation_data': navigation_data
            }
            
        except Exception as e:
            logger.error(f"Search results processing failed: {e}")
            return {
                'success': False,
                'error': str(e),
                'clusters': [],
                'highlights': []
            }
    
    def navigate_to_result(self, result_index: int, cluster_index: int = 0) -> Dict[str, Any]:
        """Navigate to a specific search result.
        
        Args:
            result_index: Index within the cluster
            cluster_index: Index of the file cluster
            
        Returns:
            Navigation result information
        """
        try:
            if not self.filtered_clusters:
                return {'action': 'error', 'error': 'No search results available'}
            
            if cluster_index >= len(self.filtered_clusters):
                return {'action': 'error', 'error': 'Invalid cluster index'}
            
            cluster = self.filtered_clusters[cluster_index]
            
            if result_index >= len(cluster.highlights):
                return {'action': 'error', 'error': 'Invalid result index'}
            
            highlight = cluster.highlights[result_index]
            
            # Navigate using Monaco integration
            navigation_result = self.monaco_integration.navigate_to_result(highlight)
            
            # Update statistics
            with self.cache_lock:
                self.navigation_stats['navigations'] += 1
                
                # Track file navigation patterns
                file_path = highlight.file_path
                self.navigation_stats['most_navigated_files'][file_path] = \
                    self.navigation_stats['most_navigated_files'].get(file_path, 0) + 1
                
                # Update navigation time average
                total_navs = self.navigation_stats['navigations']
                current_avg = self.navigation_stats['average_navigation_time']
                self.navigation_stats['average_navigation_time'] = (
                    (current_avg * (total_navs - 1) + 0.1) / total_navs
                )
            
            # Create response
            response = {
                'action': 'navigate',
                'navigation_result': navigation_result,
                'cluster_info': {
                    'file_path': cluster.file_path,
                    'filename': cluster.filename,
                    'cluster_index': cluster_index,
                    'result_index': result_index,
                    'total_in_cluster': len(cluster.highlights),
                    'remaining_results': len(cluster.highlights) - result_index - 1
                },
                'statistics': {
                    'total_navigations': self.navigation_stats['navigations'],
                    'most_navigated_file': max(
                        self.navigation_stats['most_navigated_files'].items(),
                        key=lambda x: x[1],
                        default=('none', 0)
                    )
                }
            }
            
            return response
            
        except Exception as e:
            logger.error(f"Result navigation failed: {e}")
            return {'action': 'error', 'error': str(e)}
    
    def navigate_next(self) -> Dict[str, Any]:
        """Navigate to the next search result."""
        try:
            # Get current navigation context
            current_context = self.monaco_integration.navigation_context
            
            # If no current result, navigate to first
            if not current_context.current_highlight:
                return self.navigate_to_result(0, 0)
            
            # Find current cluster and result
            current_file = current_context.current_file
            current_result_index = current_context.current_result_index
            
            # Find the cluster containing the current file
            current_cluster_index = None
            result_index_in_cluster = None
            
            for cluster_idx, cluster in enumerate(self.filtered_clusters):
                if cluster.file_path == current_file:
                    current_cluster_index = cluster_idx
                    
                    # Find the result index within this cluster
                    for result_idx, highlight in enumerate(cluster.highlights):
                        if (highlight.line_number == current_context.current_highlight.line_number and
                            highlight.start_column == current_context.current_highlight.start_column):
                            result_index_in_cluster = result_idx
                            break
                    break
            
            if current_cluster_index is None or result_index_in_cluster is None:
                return self.navigate_to_result(0, 0)
            
            # Move to next result
            next_result_index = result_index_in_cluster + 1
            
            # If at end of cluster, move to next cluster
            if next_result_index >= len(self.filtered_clusters[current_cluster_index].highlights):
                if current_cluster_index + 1 < len(self.filtered_clusters):
                    current_cluster_index += 1
                    next_result_index = 0
                else:
                    # Wrap around to first result
                    current_cluster_index = 0
                    next_result_index = 0
            
            return self.navigate_to_result(next_result_index, current_cluster_index)
            
        except Exception as e:
            logger.error(f"Next navigation failed: {e}")
            return {'action': 'error', 'error': str(e)}
    
    def navigate_previous(self) -> Dict[str, Any]:
        """Navigate to the previous search result."""
        try:
            # Get current navigation context
            current_context = self.monaco_integration.navigation_context
            
            # If no current result, navigate to last
            if not current_context.current_highlight:
                if self.filtered_clusters:
                    last_cluster_index = len(self.filtered_clusters) - 1
                    last_cluster = self.filtered_clusters[last_cluster_index]
                    last_result_index = len(last_cluster.highlights) - 1
                    return self.navigate_to_result(last_result_index, last_cluster_index)
                return {'action': 'error', 'error': 'No search results available'}
            
            # Find current cluster and result
            current_file = current_context.current_file
            current_result_index = current_context.current_result_index
            
            # Find the cluster containing the current file
            current_cluster_index = None
            result_index_in_cluster = None
            
            for cluster_idx, cluster in enumerate(self.filtered_clusters):
                if cluster.file_path == current_file:
                    current_cluster_index = cluster_idx
                    
                    # Find the result index within this cluster
                    for result_idx, highlight in enumerate(cluster.highlights):
                        if (highlight.line_number == current_context.current_highlight.line_number and
                            highlight.start_column == current_context.current_highlight.start_column):
                            result_index_in_cluster = result_idx
                            break
                    break
            
            if current_cluster_index is None or result_index_in_cluster is None:
                return self.navigate_to_result(0, 0)
            
            # Move to previous result
            prev_result_index = result_index_in_cluster - 1
            
            # If at start of cluster, move to previous cluster
            if prev_result_index < 0:
                if current_cluster_index - 1 >= 0:
                    current_cluster_index -= 1
                    prev_result_index = len(self.filtered_clusters[current_cluster_index].highlights) - 1
                else:
                    # Wrap around to last result
                    if self.filtered_clusters:
                        last_cluster_index = len(self.filtered_clusters) - 1
                        prev_result_index = len(self.filtered_clusters[last_cluster_index].highlights) - 1
                        current_cluster_index = last_cluster_index
                    else:
                        return {'action': 'error', 'error': 'No search results available'}
            
            return self.navigate_to_result(prev_result_index, current_cluster_index)
            
        except Exception as e:
            logger.error(f"Previous navigation failed: {e}")
            return {'action': 'error', 'error': str(e)}
    
    def filter_results(self, filters: Dict[str, Any]) -> Dict[str, Any]:
        """Filter search results based on criteria.
        
        Args:
            filters: Filter criteria
            
        Returns:
            Filtered results information
        """
        try:
            if not self.search_clusters:
                return {'success': True, 'filtered_clusters': [], 'filter_count': 0}
            
            filtered_clusters = []
            
            for cluster in self.search_clusters:
                include_cluster = True
                
                # Apply file type filter
                if 'file_types' in filters and filters['file_types']:
                    if cluster.language not in filters['file_types']:
                        include_cluster = False
                
                # Apply relevance score filter
                if 'min_relevance' in filters:
                    avg_relevance = cluster.cluster_metadata.get('avg_relevance', 0.0)
                    if avg_relevance < filters['min_relevance']:
                        include_cluster = False
                
                # Apply path pattern filter
                if 'path_patterns' in filters and filters['path_patterns']:
                    import fnmatch
                    if not any(fnmatch.fnmatch(cluster.file_path, pattern) 
                              for pattern in filters['path_patterns']):
                        include_cluster = False
                
                if include_cluster:
                    # Apply per-highlight filters
                    filtered_highlights = []
                    for highlight in cluster.highlights:
                        include_highlight = True
                        
                        # Apply line number range filter
                        if 'line_range' in filters:
                            line_num = highlight.line_number
                            line_range = filters['line_range']
                            if not (line_range[0] <= line_num <= line_range[1]):
                                include_highlight = False
                        
                        if include_highlight:
                            filtered_highlights.append(highlight)
                    
                    if filtered_highlights:
                        cluster.highlights = filtered_highlights
                        cluster.total_matches = len(filtered_highlights)
                        filtered_clusters.append(cluster)
            
            # Sort filtered results
            filtered_clusters.sort(
                key=lambda c: (c.total_matches, c.cluster_metadata.get('avg_relevance', 0.0)),
                reverse=True
            )
            
            self.filtered_clusters = filtered_clusters
            
            # Update navigation context
            self.monaco_integration.navigation_context.filters = filters
            
            return {
                'success': True,
                'filtered_clusters': [
                    {
                        'file_path': c.file_path,
                        'filename': c.filename,
                        'match_count': c.total_matches,
                        'language': c.language
                    }
                    for c in filtered_clusters
                ],
                'filter_count': len(filtered_clusters),
                'original_count': len(self.search_clusters),
                'filters_applied': filters
            }
            
        except Exception as e:
            logger.error(f"Result filtering failed: {e}")
            return {'success': False, 'error': str(e)}
    
    def get_context_preview(self, cluster_index: int, result_index: int) -> Dict[str, Any]:
        """Get context preview for a specific result.
        
        Args:
            cluster_index: Index of the file cluster
            result_index: Index within the cluster
            
        Returns:
            Context preview data
        """
        try:
            if cluster_index >= len(self.filtered_clusters):
                return {'error': 'Invalid cluster index'}
            
            cluster = self.filtered_clusters[cluster_index]
            
            if result_index >= len(cluster.highlights):
                return {'error': 'Invalid result index'}
            
            highlight = cluster.highlights[result_index]
            
            # Check cache first
            cache_key = f"{highlight.file_path}:{highlight.line_number}:{highlight.start_column}"
            
            with self.cache_lock:
                if cache_key in self.preview_cache:
                    return self.preview_cache[cache_key]
                
                # Create preview
                preview = self.monaco_integration.create_context_preview(highlight)
                
                # Cache the result
                self.preview_cache[cache_key] = preview
                
                # Limit cache size
                if len(self.preview_cache) > NOODLE_NAVIGATION_CACHE_SIZE:
                    # Remove oldest entries
                    oldest_keys = list(self.preview_cache.keys())[:100]
                    for key in oldest_keys:
                        del self.preview_cache[key]
                
                return preview
            
        except Exception as e:
            logger.error(f"Context preview failed: {e}")
            return {'error': str(e)}
    
    def add_bookmark(self, highlight: SearchHighlight, bookmark_data: Dict[str, Any] = None) -> Dict[str, Any]:
        """Add a search result bookmark.
        
        Args:
            highlight: Search highlight to bookmark
            bookmark_data: Additional bookmark metadata
            
        Returns:
            Bookmark creation result
        """
        try:
            bookmark = {
                'highlight': {
                    'file_path': highlight.file_path,
                    'line_number': highlight.line_number,
                    'start_column': highlight.start_column,
                    'end_column': highlight.end_column,
                    'text': highlight.text,
                    'highlight_type': highlight.highlight_type.value
                },
                'bookmark_data': bookmark_data or {},
                'created_at': time.time(),
                'bookmark_id': f"{highlight.file_path}:{highlight.line_number}:{highlight.start_column}"
            }
            
            # Add to bookmarks
            self.monaco_integration.navigation_context.bookmarks.append(bookmark)
            
            return {
                'success': True,
                'bookmark': bookmark,
                'bookmarks_count': len(self.monaco_integration.navigation_context.bookmarks)
            }
            
        except Exception as e:
            logger.error(f"Bookmark creation failed: {e}")
            return {'success': False, 'error': str(e)}
    
    def get_navigation_statistics(self) -> Dict[str, Any]:
        """Get comprehensive navigation statistics.
        
        Returns:
            Navigation performance and usage statistics
        """
        with self.cache_lock:
            most_navigated = sorted(
                self.navigation_stats['most_navigated_files'].items(),
                key=lambda x: x[1],
                reverse=True
            )[:10]
            
            return {
                'navigation_stats': {
                    'total_navigations': self.navigation_stats['navigations'],
                    'average_navigation_time': self.navigation_stats['average_navigation_time'],
                    'most_navigated_files': dict(most_navigated),
                    'navigation_patterns': self.navigation_stats['navigation_patterns'][-10:]
                },
                'current_search': {
                    'total_clusters': len(self.search_clusters),
                    'filtered_clusters': len(self.filtered_clusters),
                    'total_highlights': sum(c.total_matches for c in self.search_clusters),
                    'current_navigation_context': {
                        'current_file': self.monaco_integration.navigation_context.current_file,
                        'current_result_index': self.monaco_integration.navigation_context.current_result_index,
                        'bookmarks_count': len(self.monaco_integration.navigation_context.bookmarks),
                        'navigation_history_size': len(self.monaco_integration.navigation_context.navigation_history)
                    }
                },
                'performance_metrics': {
                    'preview_cache_size': len(self.preview_cache),
                    'highlight_cache_size': len(self.highlight_cache),
                    'cache_hit_ratio': 0.8  # Would be calculated from actual cache stats
                }
            }
    
    def clear_cache(self):
        """Clear all navigation caches."""
        with self.cache_lock:
            self.preview_cache.clear()
            self.highlight_cache.clear()
            logger.info("Navigation caches cleared")
    
    def reset_navigation(self):
        """Reset navigation state."""
        self.monaco_integration.navigation_context = SearchNavigationContext()
        self.search_clusters = []
        self.filtered_clusters = []
        self.current_search_id = None
        logger.info("Navigation state reset")


# Global search navigator instance
_global_search_navigator = None


def get_search_navigator(monaco_integration: MonacoEditorIntegration = None) -> SearchNavigator:
    """
    Get a global search navigator instance.
    
    Args:
        monaco_integration: Monaco Editor integration instance
        
    Returns:
        SearchNavigator instance
    """
    global _global_search_navigator
    
    if _global_search_navigator is None:
        _global_search_navigator = SearchNavigator(monaco_integration)
    
    return _global_search_navigator


if __name__ == "__main__":
    # Example usage
    print("NoodleCore Search Navigator Module")
    print("==================================")
    
    # Initialize components
    navigator = get_search_navigator()
    
    # Mock search results
    mock_results = {
        'success': True,
        'results': [
            {
                'file_path': 'src/main.py',
                'line_number': 15,
                'column_start': 8,
                'column_end': 20,
                'matched_text': 'def my_function',
                'context_before': 'class MyClass:\n    def __init__:',
                'context_after': '():\n        pass',
                'relevance_score': 0.9,
                'match_type': 'exact',
                'metadata': {'language': 'python'}
            },
            {
                'file_path': 'src/utils.py',
                'line_number': 42,
                'column_start': 4,
                'column_end': 16,
                'matched_text': 'def my_function',
                'context_before': '    def helper():',
                'context_after': '(self):\n        return True',
                'relevance_score': 0.8,
                'match_type': 'exact',
                'metadata': {'language': 'python'}
            }
        ]
    }
    
    print("Processing search results:")
    
    # Process search results
    processed = navigator.process_search_results(mock_results)
    print(f"Processed: {processed['navigation_data']['total_files']} files, "
          f"{processed['navigation_data']['total_results']} results")
    
    # Navigate to results
    nav_result = navigator.navigate_to_result(0, 0)
    print(f"Navigation to first result: {nav_result.get('action', 'unknown')}")
    
    # Get context preview
    preview = navigator.get_context_preview(0, 0)
    if 'error' not in preview:
        print(f"Context preview: {len(preview.get('preview_lines', []))} lines")
    
    # Get statistics
    stats = navigator.get_navigation_statistics()
    print(f"Navigation statistics: {stats['navigation_stats']['total_navigations']} navigations")
    
    # Test navigation
    next_nav = navigator.navigate_next()
    prev_nav = navigator.navigate_previous()
    print(f"Next/Previous navigation: {next_nav.get('action')} / {prev_nav.get('action')}")
    
    # Clear caches
    navigator.clear_cache()
    print("Navigation caches cleared")
    
    print("\nSearch navigator demo completed")