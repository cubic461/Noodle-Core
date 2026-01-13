# Advanced Search Functionality for NoodleCore IDE
# -------------------------------------------------

import .utils.common.CommonUtils
import .runtime.error_handler.ErrorHandler
import .validation.validation_engine.ValidationEngine
import .vector.vector.VectorManager

class AdvancedSearchManager:
    """
    Advanced search manager for NoodleCore IDE.
    
    Provides intelligent search functionality including file search,
    content search, semantic search, and AI-powered code search
    with real-time indexing and fuzzy matching capabilities.
    """
    
    def __init__(self, error_handler, validation_engine, vector_manager):
        """
        Initialize Advanced Search Manager.
        
        Args:
            error_handler: Error handling system
            validation_engine: Code validation engine
            vector_manager: Vector database manager for semantic search
        """
        self.error_handler = error_handler
        self.validation_engine = validation_engine
        self.vector_manager = vector_manager
        
        # Search configuration
        self.search_config = {
            'semantic_search_enabled': True,
            'indexing_enabled': True,
            'fuzzy_search_enabled': True,
            'real_time_indexing': True,
            'max_search_results': 50,
            'max_context_lines': 3,
            'min_similarity_score': 0.6,
            'search_timeout': 5000,  # 5 seconds
            'cache_results': True,
            'cache_ttl': 300,  # 5 minutes
            'support_languages': ['python', 'noodle', 'javascript', 'typescript', 'html', 'css', 'json'],
            'ignored_patterns': [
                '**/node_modules/**',
                '**/venv/**',
                '**/.git/**',
                '**/__pycache__/**',
                '**/*.pyc',
                '**/*.log',
                '**/.DS_Store'
            ]
        }
        
        # Search index
        self.search_index = {}
        self.file_metadata = {}
        self.search_cache = {}
        
        # Search types
        self.search_types = {
            'filename': {
                'name': 'Filename Search',
                'description': 'Search files by name and path',
                'icon': 'fas fa-file-alt',
                'priority': 1
            },
            'content': {
                'name': 'Content Search',
                'description': 'Search text within file contents',
                'icon': 'fas fa-search',
                'priority': 2
            },
            'semantic': {
                'name': 'Semantic Search',
                'description': 'AI-powered semantic code search',
                'icon': 'fas fa-brain',
                'priority': 3
            },
            'symbol': {
                'name': 'Symbol Search',
                'description': 'Search for functions, classes, variables',
                'icon': 'fas fa-code',
                'priority': 4
            },
            'pattern': {
                'name': 'Pattern Search',
                'description': 'Search using regex patterns',
                'icon': 'fas fa-regular-expression',
                'priority': 5
            }
        }
        
        # Search filters
        self.search_filters = {
            'language': {
                'name': 'Programming Language',
                'type': 'multiselect',
                'options': self.search_config['support_languages']
            },
            'file_size': {
                'name': 'File Size',
                'type': 'range',
                'min': 0,
                'max': 10 * 1024 * 1024,  # 10MB
                'unit': 'bytes'
            },
            'modified_date': {
                'name': 'Last Modified',
                'type': 'date_range',
                'max_range_days': 365
            },
            'file_type': {
                'name': 'File Type',
                'type': 'multiselect',
                'options': ['source', 'documentation', 'configuration', 'asset']
            }
        }
        
        # Initialize search components
        self.setup_search_components()
    
    def setup_search_components(self):
        """Setup search components and indexes."""
        try:
            # Initialize vector search if enabled
            if self.search_config['semantic_search_enabled'] and self.vector_manager:
                self.vector_search_enabled = True
            else:
                self.vector_search_enabled = False
            
            # Initialize search cache
            if self.search_config['cache_results']:
                self.setup_cache_cleanup()
            
            self.search_index_initialized = True
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to setup search components: {str(e)}')
            self.search_index_initialized = False
    
    async def initialize_search_index(self, workspace_path):
        """
        Initialize search index for workspace.
        
        Args:
            workspace_path: Path to workspace directory
            
        Returns:
            dict: Initialization result
        """
        try:
            if not self.search_config['indexing_enabled']:
                return {
                    'success': True,
                    'message': 'Indexing disabled',
                    'indexed_files': 0
                }
            
            # Scan workspace files
            files = await self._scan_workspace_files(workspace_path)
            
            # Index files
            indexed_count = 0
            for file_path in files:
                try:
                    await self._index_file(file_path)
                    indexed_count += 1
                except Exception as e:
                    self.error_handler.handle_error(f'Failed to index file {file_path}: {str(e)}')
            
            # Build semantic index if enabled
            if self.vector_search_enabled:
                await self._build_semantic_index()
            
            return {
                'success': True,
                'indexed_files': indexed_count,
                'total_files': len(files),
                'index_type': 'full' if self.vector_search_enabled else 'basic'
            }
            
        except Exception as e:
            self.error_handler.handle_error(f'Search index initialization failed: {str(e)}')
            return {
                'success': False,
                'error': str(e)
            }
    
    async def perform_search(self, query, search_type='content', filters=None, max_results=None):
        """
        Perform search operation.
        
        Args:
            query: Search query
            search_type: Type of search (filename, content, semantic, symbol, pattern)
            filters: Search filters
            max_results: Maximum number of results
            
        Returns:
            dict: Search results
        """
        try:
            # Validate search parameters
            if not query or not query.strip():
                return self._error_response('Search query is required', '8001')
            
            if search_type not in self.search_types:
                return self._error_response(f'Invalid search type: {search_type}', '8002')
            
            # Setup search parameters
            max_results = max_results or self.search_config['max_search_results']
            filters = filters or {}
            
            # Check cache first
            cache_key = self._generate_cache_key(query, search_type, filters)
            if self.search_config['cache_results'] and cache_key in self.search_cache:
                cached_result = self.search_cache[cache_key]
                if self._is_cache_valid(cached_result):
                    return cached_result['result']
            
            # Perform search based on type
            search_results = []
            search_time = 0
            
            start_time = self._get_current_time()
            
            if search_type == 'filename':
                search_results = await self._search_filename(query, filters, max_results)
            elif search_type == 'content':
                search_results = await self._search_content(query, filters, max_results)
            elif search_type == 'semantic' and self.vector_search_enabled:
                search_results = await self._search_semantic(query, filters, max_results)
            elif search_type == 'symbol':
                search_results = await self._search_symbols(query, filters, max_results)
            elif search_type == 'pattern':
                search_results = await self._search_pattern(query, filters, max_results)
            
            search_time = self._get_current_time() - start_time
            
            # Format results
            formatted_results = self._format_search_results(search_results, query, search_type)
            
            # Create response
            result = {
                'success': True,
                'request_id': self._generate_request_id(),
                'data': {
                    'query': query,
                    'search_type': search_type,
                    'results': formatted_results,
                    'total_results': len(formatted_results),
                    'search_time': search_time,
                    'filters_applied': filters,
                    'search_metadata': {
                        'index_used': self.search_types[search_type]['name'],
                        'cache_hit': cache_key in self.search_cache,
                        'semantic_search': search_type == 'semantic' and self.vector_search_enabled
                    },
                    'timestamp': self._get_timestamp()
                }
            }
            
            # Cache results
            if self.search_config['cache_results']:
                self.search_cache[cache_key] = {
                    'result': result,
                    'timestamp': self._get_timestamp()
                }
            
            return result
            
        except Exception as e:
            self.error_handler.handle_error(f'Search failed: {str(e)}')
            return self._error_response('Search failed', '8003')
    
    async def _search_filename(self, query, filters, max_results):
        """Search files by filename."""
        results = []
        
        for file_path, metadata in self.search_index.items():
            filename = metadata.get('filename', '')
            
            # Simple filename matching
            if query.lower() in filename.lower():
                # Calculate relevance score
                score = self._calculate_filename_relevance(query, filename)
                
                # Apply filters
                if self._passes_filters(metadata, filters):
                    results.append({
                        'file_path': file_path,
                        'filename': filename,
                        'score': score,
                        'match_type': 'filename',
                        'line_number': 0,
                        'context': '',
                        'metadata': metadata
                    })
        
        # Sort by score and limit results
        results.sort(key=lambda x: x['score'], reverse=True)
        return results[:max_results]
    
    async def _search_content(self, query, filters, max_results):
        """Search content within files."""
        results = []
        
        for file_path, metadata in self.search_index.items():
            if 'content' not in metadata:
                continue
            
            content = metadata['content']
            lines = content.split('\n')
            
            # Search each line
            for line_num, line in enumerate(lines, 1):
                if query.lower() in line.lower():
                    # Calculate relevance score
                    score = self._calculate_content_relevance(query, line)
                    
                    # Apply filters
                    if self._passes_filters(metadata, filters):
                        # Get context lines
                        context = self._get_context_lines(lines, line_num, self.search_config['max_context_lines'])
                        
                        results.append({
                            'file_path': file_path,
                            'filename': metadata.get('filename', ''),
                            'score': score,
                            'match_type': 'content',
                            'line_number': line_num,
                            'matched_line': line.strip(),
                            'context': context,
                            'metadata': metadata
                        })
        
        # Sort by score and limit results
        results.sort(key=lambda x: x['score'], reverse=True)
        return results[:max_results]
    
    async def _search_semantic(self, query, filters, max_results):
        """Perform semantic search using vector embeddings."""
        if not self.vector_search_enabled:
            return []
        
        try:
            # Get query embedding
            query_embedding = await self.vector_manager.embed_query(query)
            
            # Search vector database
            vector_results = await self.vector_manager.search(
                query_embedding,
                limit=max_results * 2,  # Get more results for filtering
                min_similarity=self.search_config['min_similarity_score']
            )
            
            results = []
            for vector_result in vector_results:
                file_id = vector_result.get('file_id')
                
                # Find file in index
                file_metadata = None
                for path, metadata in self.search_index.items():
                    if metadata.get('file_id') == file_id:
                        file_metadata = metadata
                        break
                
                if file_metadata and self._passes_filters(file_metadata, filters):
                    results.append({
                        'file_path': path,
                        'filename': file_metadata.get('filename', ''),
                        'score': vector_result.get('similarity', 0),
                        'match_type': 'semantic',
                        'line_number': 0,
                        'context': '',
                        'metadata': file_metadata,
                        'semantic_explanation': vector_result.get('explanation', '')
                    })
            
            # Sort by similarity score
            results.sort(key=lambda x: x['score'], reverse=True)
            return results[:max_results]
            
        except Exception as e:
            self.error_handler.handle_error(f'Semantic search failed: {str(e)}')
            return []
    
    async def _search_symbols(self, query, filters, max_results):
        """Search for symbols (functions, classes, variables)."""
        results = []
        
        for file_path, metadata in self.search_index.items():
            symbols = metadata.get('symbols', {})
            
            for symbol_name, symbol_data in symbols.items():
                if query.lower() in symbol_name.lower():
                    # Calculate relevance score
                    score = self._calculate_symbol_relevance(query, symbol_name, symbol_data)
                    
                    # Apply filters
                    if self._passes_filters(metadata, filters):
                        results.append({
                            'file_path': file_path,
                            'filename': metadata.get('filename', ''),
                            'score': score,
                            'match_type': 'symbol',
                            'symbol_name': symbol_name,
                            'symbol_type': symbol_data.get('type', 'unknown'),
                            'line_number': symbol_data.get('line_number', 0),
                            'context': symbol_data.get('context', ''),
                            'metadata': metadata
                        })
        
        # Sort by score and limit results
        results.sort(key=lambda x: x['score'], reverse=True)
        return results[:max_results]
    
    async def _search_pattern(self, query, filters, max_results):
        """Search using regex patterns."""
        import re
        
        results = []
        
        try:
            # Compile regex pattern
            pattern = re.compile(query, re.IGNORECASE)
            
            for file_path, metadata in self.search_index.items():
                if 'content' not in metadata:
                    continue
                
                content = metadata['content']
                lines = content.split('\n')
                
                # Search each line
                for line_num, line in enumerate(lines, 1):
                    matches = pattern.findall(line)
                    if matches:
                        # Calculate relevance score
                        score = self._calculate_pattern_relevance(query, line, len(matches))
                        
                        # Apply filters
                        if self._passes_filters(metadata, filters):
                            # Get context lines
                            context = self._get_context_lines(lines, line_num, self.search_config['max_context_lines'])
                            
                            results.append({
                                'file_path': file_path,
                                'filename': metadata.get('filename', ''),
                                'score': score,
                                'match_type': 'pattern',
                                'line_number': line_num,
                                'matched_line': line.strip(),
                                'matches': matches,
                                'context': context,
                                'metadata': metadata
                            })
            
            # Sort by score and limit results
            results.sort(key=lambda x: x['score'], reverse=True)
            return results[:max_results]
            
        except re.error as e:
            self.error_handler.handle_error(f'Invalid regex pattern: {str(e)}')
            return []
    
    async def _index_file(self, file_path):
        """Index a single file."""
        try:
            # Read file content
            content = await self._read_file_content(file_path)
            if content is None:
                return
            
            # Extract file metadata
            metadata = self._extract_file_metadata(file_path, content)
            
            # Extract symbols
            symbols = self._extract_symbols(file_path, content, metadata.get('language', 'plaintext'))
            
            # Store in search index
            self.search_index[file_path] = {
                'file_path': file_path,
                'filename': metadata.get('filename', ''),
                'language': metadata.get('language', 'plaintext'),
                'content': content,
                'size': len(content),
                'modified_date': metadata.get('modified_date', 0),
                'symbols': symbols,
                'metadata': metadata,
                'file_id': self._generate_file_id(file_path)
            }
            
            # Store file metadata separately
            self.file_metadata[file_path] = metadata
            
            # Index for semantic search if enabled
            if self.vector_search_enabled:
                await self._index_for_semantic_search(file_path, content, metadata)
                
        except Exception as e:
            self.error_handler.handle_error(f'Failed to index file {file_path}: {str(e)}')
    
    def _extract_file_metadata(self, file_path, content):
        """Extract metadata from file."""
        import os
        from datetime import datetime
        
        filename = os.path.basename(file_path)
        extension = os.path.splitext(filename)[1][1:].lower()
        
        # Detect language
        language_map = {
            'py': 'python',
            'nc': 'noodle',
            'js': 'javascript',
            'ts': 'typescript',
            'html': 'html',
            'css': 'css',
            'json': 'json'
        }
        
        language = language_map.get(extension, 'plaintext')
        
        # Get file stats
        try:
            stat = os.stat(file_path)
            modified_date = stat.st_mtime
            size = stat.st_size
        except:
            modified_date = 0
            size = len(content)
        
        return {
            'filename': filename,
            'extension': extension,
            'language': language,
            'size': size,
            'modified_date': modified_date,
            'line_count': len(content.split('\n')),
            'char_count': len(content)
        }
    
    def _extract_symbols(self, file_path, content, language):
        """Extract symbols (functions, classes, variables) from content."""
        symbols = {}
        
        if language == 'python':
            symbols = self._extract_python_symbols(content)
        elif language == 'noodle':
            symbols = self._extract_noodle_symbols(content)
        # Add more language-specific symbol extraction
        
        return symbols
    
    def _extract_python_symbols(self, content):
        """Extract Python symbols."""
        import re
        
        symbols = {}
        
        # Function definitions
        func_pattern = r'^\s*def\s+(\w+)\s*\('
        for line_num, line in enumerate(content.split('\n'), 1):
            match = re.match(func_pattern, line)
            if match:
                func_name = match.group(1)
                symbols[func_name] = {
                    'type': 'function',
                    'line_number': line_num,
                    'context': line.strip()
                }
        
        # Class definitions
        class_pattern = r'^\s*class\s+(\w+)'
        for line_num, line in enumerate(content.split('\n'), 1):
            match = re.match(class_pattern, line)
            if match:
                class_name = match.group(1)
                symbols[class_name] = {
                    'type': 'class',
                    'line_number': line_num,
                    'context': line.strip()
                }
        
        # Variable assignments (simple)
        var_pattern = r'^(\w+)\s*='
        for line_num, line in enumerate(content.split('\n'), 1):
            match = re.match(var_pattern, line)
            if match:
                var_name = match.group(1)
                # Skip if already a function or class
                if var_name not in symbols:
                    symbols[var_name] = {
                        'type': 'variable',
                        'line_number': line_num,
                        'context': line.strip()
                    }
        
        return symbols
    
    def _extract_noodle_symbols(self, content):
        """Extract NoodleCore symbols."""
        # Simplified symbol extraction for NoodleCore
        import re
        
        symbols = {}
        
        # Function definitions (simplified)
        func_pattern = r'^\s*def\s+(\w+)\s*\('
        for line_num, line in enumerate(content.split('\n'), 1):
            match = re.match(func_pattern, line)
            if match:
                func_name = match.group(1)
                symbols[func_name] = {
                    'type': 'function',
                    'line_number': line_num,
                    'context': line.strip()
                }
        
        # Class definitions (simplified)
        class_pattern = r'^\s*class\s+(\w+)'
        for line_num, line in enumerate(content.split('\n'), 1):
            match = re.match(class_pattern, line)
            if match:
                class_name = match.group(1)
                symbols[class_name] = {
                    'type': 'class',
                    'line_number': line_num,
                    'context': line.strip()
                }
        
        return symbols
    
    async def _index_for_semantic_search(self, file_path, content, metadata):
        """Index file for semantic search."""
        if not self.vector_search_enabled:
            return
        
        try:
            # Generate embeddings for file content
            content_embedding = await self.vector_manager.embed_text(content)
            
            # Store in vector database
            file_id = self._generate_file_id(file_path)
            await self.vector_manager.upsert_document(
                document_id=file_id,
                content=content,
                embedding=content_embedding,
                metadata={
                    'file_path': file_path,
                    'filename': metadata.get('filename', ''),
                    'language': metadata.get('language', 'plaintext'),
                    'size': metadata.get('size', 0)
                }
            )
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to index for semantic search: {str(e)}')
    
    def _calculate_filename_relevance(self, query, filename):
        """Calculate relevance score for filename match."""
        query_lower = query.lower()
        filename_lower = filename.lower()
        
        if query_lower == filename_lower:
            return 1.0
        elif filename_lower.startswith(query_lower):
            return 0.9
        elif query_lower in filename_lower:
            return 0.8
        else:
            # Fuzzy match
            return self._fuzzy_match_score(query_lower, filename_lower)
    
    def _calculate_content_relevance(self, query, line):
        """Calculate relevance score for content match."""
        query_lower = query.lower()
        line_lower = line.lower()
        
        if query_lower == line_lower:
            return 1.0
        elif line_lower.startswith(query_lower):
            return 0.9
        elif query_lower in line_lower:
            return 0.8
        else:
            return 0.6
    
    def _calculate_symbol_relevance(self, query, symbol_name, symbol_data):
        """Calculate relevance score for symbol match."""
        base_score = self._calculate_filename_relevance(query, symbol_name)
        
        # Boost score based on symbol type
        type_boost = {
            'function': 0.1,
            'class': 0.05,
            'variable': 0.0
        }
        
        symbol_type = symbol_data.get('type', 'unknown')
        boost = type_boost.get(symbol_type, 0)
        
        return min(1.0, base_score + boost)
    
    def _calculate_pattern_relevance(self, pattern, line, match_count):
        """Calculate relevance score for pattern match."""
        base_score = 0.8
        
        # Boost score based on number of matches
        match_boost = min(0.2, match_count * 0.05)
        
        return min(1.0, base_score + match_boost)
    
    def _fuzzy_match_score(self, query, text):
        """Calculate fuzzy match score using simple algorithm."""
        # Simple fuzzy matching - can be enhanced with more sophisticated algorithms
        if len(query) == 0:
            return 0.0
        
        matches = 0
        query_index = 0
        
        for char in text:
            if query_index < len(query) and char.lower() == query[query_index].lower():
                matches += 1
                query_index += 1
        
        return matches / len(query)
    
    def _passes_filters(self, metadata, filters):
        """Check if metadata passes search filters."""
        for filter_name, filter_value in filters.items():
            if filter_name == 'language':
                if metadata.get('language') not in filter_value:
                    return False
            elif filter_name == 'file_size':
                min_size, max_size = filter_value
                file_size = metadata.get('size', 0)
                if file_size < min_size or file_size > max_size:
                    return False
            elif filter_name == 'modified_date':
                start_date, end_date = filter_value
                file_date = metadata.get('modified_date', 0)
                if file_date < start_date or file_date > end_date:
                    return False
            elif filter_name == 'file_type':
                if metadata.get('file_type') not in filter_value:
                    return False
        
        return True
    
    def _get_context_lines(self, lines, line_number, context_lines):
        """Get context around a specific line."""
        start = max(0, line_number - context_lines - 1)
        end = min(len(lines), line_number + context_lines)
        
        context = []
        for i in range(start, end):
            context.append({
                'line_number': i + 1,
                'content': lines[i].rstrip(),
                'is_match': i == line_number - 1
            })
        
        return context
    
    def _format_search_results(self, raw_results, query, search_type):
        """Format search results for API response."""
        formatted = []
        
        for result in raw_results:
            formatted_result = {
                'file_path': result['file_path'],
                'filename': result['filename'],
                'relevance_score': result['score'],
                'match_type': result['match_type'],
                'highlight': self._create_search_highlight(result, query),
                'metadata': {
                    'language': result['metadata'].get('language', 'plaintext'),
                    'file_size': result['metadata'].get('size', 0),
                    'last_modified': result['metadata'].get('modified_date', 0)
                }
            }
            
            # Add type-specific information
            if result['match_type'] == 'content':
                formatted_result.update({
                    'line_number': result['line_number'],
                    'matched_content': result['matched_line'],
                    'context': result['context']
                })
            elif result['match_type'] == 'symbol':
                formatted_result.update({
                    'symbol_name': result['symbol_name'],
                    'symbol_type': result['symbol_type'],
                    'line_number': result['line_number']
                })
            elif result['match_type'] == 'semantic':
                formatted_result.update({
                    'semantic_explanation': result.get('semantic_explanation', '')
                })
            elif result['match_type'] == 'pattern':
                formatted_result.update({
                    'line_number': result['line_number'],
                    'matched_content': result['matched_line'],
                    'match_count': len(result.get('matches', [])),
                    'context': result['context']
                })
            
            formatted.append(formatted_result)
        
        return formatted
    
    def _create_search_highlight(self, result, query):
        """Create highlighted text for search results."""
        query_lower = query.lower()
        
        if result['match_type'] == 'content':
            content = result['matched_line']
            highlighted = content.replace(query, f'<mark>{query}</mark>')
            return highlighted
        elif result['match_type'] == 'filename':
            filename = result['filename']
            highlighted = filename.replace(query, f'<mark>{query}</mark>')
            return highlighted
        else:
            return result['filename']
    
    def _generate_cache_key(self, query, search_type, filters):
        """Generate cache key for search results."""
        import hashlib
        
        key_data = f"{query}:{search_type}:{str(sorted(filters.items()))}"
        return hashlib.md5(key_data.encode()).hexdigest()
    
    def _is_cache_valid(self, cached_entry):
        """Check if cached entry is still valid."""
        if not self.search_config['cache_results']:
            return False
        
        cache_time = cached_entry['timestamp']
        current_time = self._get_timestamp()
        
        return (current_time - cache_time) < (self.search_config['cache_ttl'] * 1000)
    
    def _generate_file_id(self, file_path):
        """Generate unique file ID."""
        import hashlib
        return hashlib.md5(file_path.encode()).hexdigest()
    
    def _generate_request_id(self):
        """Generate unique request ID."""
        import uuid
        return str(uuid.uuid4())
    
    def _get_timestamp(self):
        """Get current timestamp."""
        import time
        return int(time.time() * 1000)
    
    def _get_current_time(self):
        """Get current time in milliseconds."""
        import time
        return time.time() * 1000
    
    def setup_cache_cleanup(self):
        """Setup periodic cache cleanup."""
        import threading
        
        def cleanup_cache():
            current_time = self._get_timestamp()
            expired_keys = []
            
            for key, entry in self.search_cache.items():
                if not self._is_cache_valid(entry):
                    expired_keys.append(key)
            
            for key in expired_keys:
                del self.search_cache[key]
        
        # Schedule cleanup every 5 minutes
        threading.Timer(300, cleanup_cache).start()
    
    async def _scan_workspace_files(self, workspace_path):
        """Scan workspace for files to index."""
        import os
        
        files = []
        
        try:
            for root, dirs, filenames in os.walk(workspace_path):
                # Skip ignored patterns
                dirs[:] = [d for d in dirs if not any(pattern.replace('**', '').strip('/\\') in d for pattern in self.search_config['ignored_patterns'])]
                
                for filename in filenames:
                    file_path = os.path.join(root, filename)
                    
                    # Skip ignored files
                    if any(pattern.replace('*', '') in file_path for pattern in self.search_config['ignored_patterns']):
                        continue
                    
                    files.append(file_path)
        
        except Exception as e:
            self.error_handler.handle_error(f'Failed to scan workspace: {str(e)}')
        
        return files
    
    async def _read_file_content(self, file_path):
        """Read file content safely."""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                return f.read()
        except Exception:
            return None
    
    async def _build_semantic_index(self):
        """Build semantic search index."""
        if not self.vector_search_enabled:
            return
        
        try:
            # Build semantic index for all indexed files
            for file_path in self.search_index.keys():
                metadata = self.search_index[file_path]
                content = metadata.get('content', '')
                
                if content:
                    await self._index_for_semantic_search(file_path, content, metadata)
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to build semantic index: {str(e)}')
    
    def _error_response(self, message, error_code):
        """Create standardized error response."""
        return {
            'success': False,
            'request_id': self._generate_request_id(),
            'error': {
                'message': message,
                'code': error_code,
                'timestamp': self._get_timestamp()
            }
        }