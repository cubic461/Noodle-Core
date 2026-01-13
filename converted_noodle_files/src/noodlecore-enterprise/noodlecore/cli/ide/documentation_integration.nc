# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Documentation Integration Module

# This module implements documentation generation and integration within IDE for NoodleCore.
# """

import asyncio
import json
import os
import re
import uuid
import hashlib
import typing.Dict,
import pathlib.Path
import datetime.datetime
import collections.defaultdict

# Import logging
import ..logs.get_logger
import ..adapters.get_adapter_manager

# Documentation Integration error codes (6601-6699)
DOCUMENTATION_INTEGRATION_ERROR_CODES = {
#     "DOCUMENTATION_GENERATION_FAILED": 6601,
#     "DOCUMENTATION_PARSING_FAILED": 6602,
#     "DOCUMENTATION_FORMATTING_FAILED": 6603,
#     "DOCUMENTATION_CACHE_ERROR": 6604,
#     "DOCUMENTATION_CONFIG_ERROR": 6605,
#     "DOCUMENTATION_TIMEOUT": 6606,
#     "DOCUMENTATION_RENDERING_FAILED": 6607,
#     "DOCUMENTATION_INDEXING_FAILED": 6608,
#     "DOCUMENTATION_SEARCH_FAILED": 6609,
#     "DOCUMENTATION_EXPORT_FAILED": 6610,
# }


class DocumentationItem
    #     """Represents a documentation item."""

    #     def __init__(self,
    #                  name: str,
    #                  kind: str,
    #                  content: str,
    #                  file_path: str,
    #                  line: int,
    #                  character: int,
    signature: Optional[str] = None,
    parameters: Optional[List[Dict[str, Any]]] = None,
    returns: Optional[str] = None,
    examples: Optional[List[str]] = None,
    see_also: Optional[List[str]] = None,
    tags: Optional[List[str]] = None):
    #         """
    #         Initialize documentation item.

    #         Args:
    #             name: Name of the item
                kind: Kind of item (function, class, variable, etc.)
    #             content: Documentation content
    #             file_path: Path to the file
    #             line: Line number
    #             character: Character position
    #             signature: Function or method signature
    #             parameters: List of parameters
    #             returns: Return value description
    #             examples: List of examples
    #             see_also: List of related items
    #             tags: List of tags
    #         """
    self.name = name
    self.kind = kind
    self.content = content
    self.file_path = file_path
    self.line = line
    self.character = character
    self.signature = signature
    self.parameters = parameters or []
    self.returns = returns
    self.examples = examples or []
    self.see_also = see_also or []
    self.tags = tags or []
    self.id = self._generate_id()

    #     def _generate_id(self) -> str:
    #         """Generate unique ID for documentation item."""
    content = f"{self.file_path}:{self.line}:{self.name}"
            return hashlib.md5(content.encode()).hexdigest()

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary."""
    #         return {
    #             'id': self.id,
    #             'name': self.name,
    #             'kind': self.kind,
    #             'content': self.content,
    #             'file_path': self.file_path,
    #             'line': self.line,
    #             'character': self.character,
    #             'signature': self.signature,
    #             'parameters': self.parameters,
    #             'returns': self.returns,
    #             'examples': self.examples,
    #             'see_also': self.see_also,
    #             'tags': self.tags
    #         }


class DocumentationIntegration
    #     """Documentation integration for NoodleCore IDE integration."""

    #     def __init__(self, workspace_dir: Optional[str] = None):
    #         """
    #         Initialize the Documentation Integration.

    #         Args:
    #             workspace_dir: Workspace directory
    #         """
    self.name = "DocumentationIntegration"
    self.workspace_dir = Path(workspace_dir or os.getcwd())
    self.docs_dir = self.workspace_dir / ".noodlecore" / "docs"
    self.cache_dir = self.workspace_dir / ".noodlecore" / "docs_cache"
    self.config_file = self.workspace_dir / ".noodlecore" / "docs_config.json"
    self.index_file = self.docs_dir / "index.json"

    #         # Initialize logger
    self.logger = get_logger(f"{__name__}.{self.name}")

    #         # Ensure directories exist
    self.docs_dir.mkdir(parents = True, exist_ok=True)
    self.cache_dir.mkdir(parents = True, exist_ok=True)

    #         # AI adapter manager
    self.adapter_manager = get_adapter_manager()

    #         # Default configuration
    self.default_config = {
    #             'enabled': True,
    #             'hover_docs': True,
    #             'auto_generate': True,
    #             'include_examples': True,
    #             'parse_comments': True,
    #             'generate_from_code': True,
    #             'cache_enabled': True,
    #             'cache_ttl': 3600,  # seconds
    #             'cache_size': 1000,
    #             'timeout': 5000,  # milliseconds
    #             'formats': {
    #                 'markdown': True,
    #                 'html': True,
    #                 'json': True
    #             },
    #             'generation': {
    #                 'include_private': False,
    #                 'include_internal': False,
    #                 'include_inherited': True,
    #                 'include_type_info': True,
    #                 'include_parameter_types': True,
    #                 'include_return_type': True,
    #                 'include_examples': True,
    #                 'include_see_also': True
    #             },
    #             'parsing': {
    #                 'comment_styles': ['//', '#', '/* */'],
    #                 'doc_block_patterns': [
                        r'/\*\*(.*?)\*/',
                        r'///(.*?)$',
                        r'##(.*?)$'
    #                 ],
                    'parameter_pattern': r'@param\s+(\w+)\s+(.+)',
                    'return_pattern': r'@return\s+(.+)',
                    'example_pattern': r'@example\s+(.+)',
                    'see_also_pattern': r'@see\s+(.+)'
    #             },
    #             'indexing': {
    #                 'enabled': True,
    #                 'full_text_search': True,
    #                 'tag_search': True,
    #                 'kind_search': True,
    #                 'auto_rebuild': True,
    #                 'rebuild_interval': 300  # seconds
    #             },
    #             'export': {
    #                 'formats': ['markdown', 'html'],
    #                 'output_dir': 'docs',
    #                 'include_toc': True,
    #                 'include_index': True,
    #                 'theme': 'default'
    #             }
    #         }

    #         # Configuration
    self.config = {}

    #         # Documentation database
    self.documentation_items = {}
    self.documentation_index = defaultdict(list)

    #         # Cache
    self.documentation_cache = {}
    self.cache_timestamps = {}

    #         # Performance tracking
    self.performance_stats = {
    #             'total_generations': 0,
    #             'successful_generations': 0,
    #             'failed_generations': 0,
    #             'cache_hits': 0,
    #             'cache_misses': 0,
    #             'average_generation_time': 0,
    #             'total_generation_time': 0,
                'last_reset': datetime.now()
    #         }

    #         # Index rebuild task
    self.index_rebuild_task = None

    #     async def initialize(self) -> Dict[str, Any]:
    #         """
    #         Initialize the Documentation Integration.

    #         Returns:
    #             Dictionary containing initialization result
    #         """
    #         try:
                self.logger.info("Initializing Documentation Integration")

    #             # Load configuration
    self.config = await self._load_config()

    #             # Load documentation index
                await self._load_documentation_index()

    #             # Load cache
                await self._load_cache()

    #             # Build initial documentation index
    #             if self.config.get('indexing', {}).get('enabled', True):
                    await self._build_documentation_index()

    #             # Start periodic index rebuild
    #             if self.config.get('indexing', {}).get('auto_rebuild', True):
                    await self._start_index_rebuild_task()

                self.logger.info("Documentation Integration initialized successfully")

    #             return {
    #                 'success': True,
    #                 'message': "Documentation Integration initialized successfully",
    #                 'features': {
                        'hover_docs': self.config.get('hover_docs', True),
                        'auto_generate': self.config.get('auto_generate', True),
                        'parse_comments': self.config.get('parse_comments', True),
                        'generate_from_code': self.config.get('generate_from_code', True)
    #                 },
                    'documentation_count': len(self.documentation_items),
                    'request_id': str(uuid.uuid4())
    #             }

    #         except Exception as e:
    error_code = DOCUMENTATION_INTEGRATION_ERROR_CODES["DOCUMENTATION_CONFIG_ERROR"]
    self.logger.error(f"Failed to initialize Documentation Integration: {str(e)}", exc_info = True)

    #             return {
    #                 'success': False,
                    'error': f"Failed to initialize Documentation Integration: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def shutdown(self) -> Dict[str, Any]:
    #         """
    #         Shutdown the Documentation Integration.

    #         Returns:
    #             Dictionary containing shutdown result
    #         """
    #         try:
                self.logger.info("Shutting down Documentation Integration")

    #             # Stop index rebuild task
    #             if self.index_rebuild_task:
                    self.index_rebuild_task.cancel()
    #                 try:
    #                     await self.index_rebuild_task
    #                 except asyncio.CancelledError:
    #                     pass

    #             # Save documentation index
                await self._save_documentation_index()

    #             # Save cache
                await self._save_cache()

                self.logger.info("Documentation Integration shutdown successfully")

    #             return {
    #                 'success': True,
    #                 'message': "Documentation Integration shutdown successfully",
    #                 'performance_stats': self.performance_stats,
                    'request_id': str(uuid.uuid4())
    #             }

    #         except Exception as e:
    error_code = DOCUMENTATION_INTEGRATION_ERROR_CODES["DOCUMENTATION_CONFIG_ERROR"]
    self.logger.error(f"Failed to shutdown Documentation Integration: {str(e)}", exc_info = True)

    #             return {
    #                 'success': False,
                    'error': f"Failed to shutdown Documentation Integration: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def get_hover_documentation(self, file_path: str, line: int, character: int, file_content: str) -> Dict[str, Any]:
    #         """
    #         Get hover documentation for a position.

    #         Args:
    #             file_path: Path to the file
    #             line: Line number
    #             character: Character position
    #             file_content: File content

    #         Returns:
    #             Dictionary containing hover documentation
    #         """
    #         try:
    start_time = datetime.now()

    #             if not self.config.get('hover_docs', True):
    #                 return {
    #                     'success': True,
    #                     'documentation': None,
                        'request_id': str(uuid.uuid4())
    #                 }

    #             # Get word at position
    word = self._get_word_at_position(file_content, line, character)

    #             if not word:
    #                 return {
    #                     'success': True,
    #                     'documentation': None,
                        'request_id': str(uuid.uuid4())
    #                 }

    #             # Check cache first
    cache_key = f"hover:{file_path}:{line}:{character}:{word}"
    cached_result = await self._get_from_cache(cache_key)
    #             if cached_result:
    self.performance_stats['cache_hits'] + = 1
    #                 return {
    #                     'success': True,
    #                     'documentation': cached_result,
    #                     'cache_hit': True,
                        'request_id': str(uuid.uuid4())
    #                 }

    self.performance_stats['cache_misses'] + = 1

    #             # Find documentation items
    documentation = await self._find_documentation_for_word(word, file_path)

    #             # If no documentation found, try to generate it
    #             if not documentation and self.config.get('auto_generate', True):
    documentation = await self._generate_documentation_for_word(word, file_path, file_content, line, character)

    #             # Cache result
                await self._save_to_cache(cache_key, documentation)

    #             # Update performance stats
    end_time = datetime.now()
    generation_time = math.multiply((end_time - start_time).total_seconds(), 1000  # Convert to milliseconds)
                self._update_performance_stats(generation_time, True)

    #             return {
    #                 'success': True,
    #                 'documentation': documentation,
    #                 'cache_hit': False,
                    'request_id': str(uuid.uuid4())
    #             }

    #         except Exception as e:
    error_code = DOCUMENTATION_INTEGRATION_ERROR_CODES["DOCUMENTATION_GENERATION_FAILED"]
    self.logger.error(f"Error getting hover documentation: {str(e)}", exc_info = True)
                self._update_performance_stats(0, False)

    #             return {
    #                 'success': False,
                    'error': f"Error getting hover documentation: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def generate_documentation(self, file_path: str, file_content: str) -> Dict[str, Any]:
    #         """
    #         Generate documentation for a file.

    #         Args:
    #             file_path: Path to the file
    #             file_content: File content

    #         Returns:
    #             Dictionary containing generation result
    #         """
    #         try:
    start_time = datetime.now()

    #             # Parse documentation from comments
    documentation_items = []

    #             if self.config.get('parse_comments', True):
    comment_docs = await self._parse_documentation_from_comments(file_path, file_content)
                    documentation_items.extend(comment_docs)

    #             # Generate documentation from code
    #             if self.config.get('generate_from_code', True):
    code_docs = await self._generate_documentation_from_code(file_path, file_content)
                    documentation_items.extend(code_docs)

    #             # Update documentation database
    #             for doc_item in documentation_items:
    self.documentation_items[doc_item.id] = doc_item

    #                 # Update index
                    self._update_documentation_index(doc_item)

    #             # Save documentation index
                await self._save_documentation_index()

    #             # Update performance stats
    end_time = datetime.now()
    generation_time = math.multiply((end_time - start_time).total_seconds(), 1000  # Convert to milliseconds)
                self._update_performance_stats(generation_time, True)

    #             return {
    #                 'success': True,
                    'message': f"Generated {len(documentation_items)} documentation items",
    #                 'documentation_items': [item.to_dict() for item in documentation_items],
                    'request_id': str(uuid.uuid4())
    #             }

    #         except Exception as e:
    error_code = DOCUMENTATION_INTEGRATION_ERROR_CODES["DOCUMENTATION_GENERATION_FAILED"]
    self.logger.error(f"Error generating documentation: {str(e)}", exc_info = True)
                self._update_performance_stats(0, False)

    #             return {
    #                 'success': False,
                    'error': f"Error generating documentation: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def search_documentation(self, query: str, filters: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    #         """
    #         Search documentation.

    #         Args:
    #             query: Search query
    #             filters: Optional filters

    #         Returns:
    #             Dictionary containing search results
    #         """
    #         try:
    start_time = datetime.now()

    #             # Apply filters
    filtered_items = self._apply_search_filters(self.documentation_items.values(), filters)

    #             # Search items
    results = []

    #             if self.config.get('indexing', {}).get('full_text_search', True):
    #                 # Full text search
    #                 for item in filtered_items:
    #                     if self._matches_search_query(item, query):
                            results.append(item.to_dict())

    #             # Sort by relevance
    results = self._sort_search_results(results, query)

    #             # Limit results
    max_results = 50
    #             if len(results) > max_results:
    results = results[:max_results]

    #             # Update performance stats
    end_time = datetime.now()
    search_time = math.multiply((end_time - start_time).total_seconds(), 1000  # Convert to milliseconds)

    #             return {
    #                 'success': True,
    #                 'query': query,
    #                 'filters': filters,
    #                 'results': results,
                    'total_count': len(results),
    #                 'search_time': search_time,
                    'request_id': str(uuid.uuid4())
    #             }

    #         except Exception as e:
    error_code = DOCUMENTATION_INTEGRATION_ERROR_CODES["DOCUMENTATION_SEARCH_FAILED"]
    self.logger.error(f"Error searching documentation: {str(e)}", exc_info = True)

    #             return {
    #                 'success': False,
                    'error': f"Error searching documentation: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def export_documentation(self, format: str, output_dir: Optional[str] = None) -> Dict[str, Any]:
    #         """
    #         Export documentation to a file.

    #         Args:
                format: Export format (markdown, html, json)
    #             output_dir: Output directory

    #         Returns:
    #             Dictionary containing export result
    #         """
    #         try:
    start_time = datetime.now()

    #             if format not in self.config.get('formats', {}):
    #                 return {
    #                     'success': False,
    #                     'error': f"Unsupported format: {format}",
    #                     'error_code': DOCUMENTATION_INTEGRATION_ERROR_CODES["DOCUMENTATION_EXPORT_FAILED"],
                        'request_id': str(uuid.uuid4())
    #                 }

    #             # Determine output directory
    #             if not output_dir:
    output_dir = self.workspace_dir / self.config.get('export', {}).get('output_dir', 'docs')
    #             else:
    output_dir = Path(output_dir)

    output_dir.mkdir(parents = True, exist_ok=True)

    #             # Export documentation
    #             if format == 'markdown':
    result = await self._export_markdown(output_dir)
    #             elif format == 'html':
    result = await self._export_html(output_dir)
    #             elif format == 'json':
    result = await self._export_json(output_dir)
    #             else:
    result = {'success': False, 'error': f"Unsupported format: {format}"}

    #             # Update performance stats
    end_time = datetime.now()
    export_time = math.multiply((end_time - start_time).total_seconds(), 1000  # Convert to milliseconds)

    result['export_time'] = export_time
    result['request_id'] = str(uuid.uuid4())

    #             return result

    #         except Exception as e:
    error_code = DOCUMENTATION_INTEGRATION_ERROR_CODES["DOCUMENTATION_EXPORT_FAILED"]
    self.logger.error(f"Error exporting documentation: {str(e)}", exc_info = True)

    #             return {
    #                 'success': False,
                    'error': f"Error exporting documentation: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     def _get_word_at_position(self, content: str, line: int, character: int) -> Optional[str]:
    #         """Get word at position."""
    #         try:
    lines = content.split('\n')

    #             if line >= len(lines):
    #                 return None

    line_text = lines[line]

    #             # Find word boundaries
    start = character
    #             while start > 0 and (line_text[start-1].isalnum() or line_text[start-1] == '_'):
    start - = 1

    end = character
    #             while end < len(line_text) and (line_text[end].isalnum() or line_text[end] == '_'):
    end + = 1

    #             if start < end:
    #                 return line_text[start:end]

    #             return None

    #         except Exception as e:
    self.logger.error(f"Error getting word at position: {str(e)}", exc_info = True)
    #             return None

    #     async def _find_documentation_for_word(self, word: str, file_path: str) -> Optional[Dict[str, Any]]:
    #         """Find documentation for a word."""
    #         try:
    #             # Search in documentation index
    #             if word in self.documentation_index:
    items = self.documentation_index[word]

    #                 # Prefer items from the same file
    #                 for item_id in items:
    item = self.documentation_items.get(item_id)
    #                     if item and item.file_path == file_path:
                            return item.to_dict()

    #                 # Return any item
    #                 if items:
    item_id = items[0]
    item = self.documentation_items.get(item_id)
    #                     if item:
                            return item.to_dict()

    #             return None

    #         except Exception as e:
    #             self.logger.error(f"Error finding documentation for word: {str(e)}", exc_info=True)
    #             return None

    #     async def _generate_documentation_for_word(self, word: str, file_path: str, file_content: str, line: int, character: int) -> Optional[Dict[str, Any]]:
    #         """Generate documentation for a word."""
    #         try:
    #             # Get AI adapter
    adapter = await self.adapter_manager.get_adapter(self.config.get('ai_model', 'zai_glm'))

    #             if not adapter:
    #                 return None

    #             # Get context around the word
    lines = file_content.split('\n')
    context_lines = []

    #             # Get 5 lines before and after
    #             for i in range(max(0, line-5), min(len(lines), line+6)):
                    context_lines.append(lines[i])

    context = '\n'.join(context_lines)

    #             # Prepare prompt
    #             prompt = f"""Generate documentation for the NoodleCore symbol "{word}" based on the following context:

# File: {file_path}
# Line: {line}, Character: {character}

# Context:
# {context}

# Provide documentation in JSON format:
# {{
#   "name": "{word}",
#   "kind": "function|class|variable|keyword",
#   "content": "Detailed description",
#   "signature": "Signature if applicable",
#   "parameters": [
#     {{
#       "name": "param1",
#       "type": "string",
#       "description": "Parameter description"
#     }}
#   ],
#   "returns": "Return value description",
#   "examples": [
#     "Example code"
#   ],
#   "see_also": [
#     "Related items"
#   ]
# }}

# Only respond with the JSON, no additional text."""

#             # Get AI response
request_data = {
#                 'prompt': prompt,
#                 'max_tokens': 500,
#                 'temperature': 0.3,
                'timeout': self.config.get('timeout', 5000)
#             }

response = await adapter.generate(request_data)

#             if response.get('success'):
#                 # Parse AI response
#                 try:
content = response.get('content', '')
#                     if '{' in content and '}' in content:
start = content.find('{')
end = content.rfind('}') + 1
json_str = content[start:end]

doc_data = json.loads(json_str)

#                         # Create documentation item
doc_item = DocumentationItem(
name = doc_data.get('name', word),
kind = doc_data.get('kind', 'unknown'),
content = doc_data.get('content', ''),
file_path = file_path,
line = line,
character = character,
signature = doc_data.get('signature'),
parameters = doc_data.get('parameters', []),
returns = doc_data.get('returns'),
examples = doc_data.get('examples', []),
see_also = doc_data.get('see_also', [])
#                         )

#                         # Add to documentation database
self.documentation_items[doc_item.id] = doc_item
                        self._update_documentation_index(doc_item)

                        return doc_item.to_dict()
#                 except json.JSONDecodeError:
#                     pass

#             return None

#         except Exception as e:
#             self.logger.error(f"Error generating documentation for word: {str(e)}", exc_info=True)
#             return None

#     async def _parse_documentation_from_comments(self, file_path: str, content: str) -> List[DocumentationItem]:
#         """Parse documentation from comments."""
documentation_items = []

#         try:
lines = content.split('\n')
parsing_config = self.config.get('parsing', {})

#             # Find documentation blocks
#             for pattern in parsing_config.get('doc_block_patterns', []):
matches = re.finditer(pattern, content, re.DOTALL)

#                 for match in matches:
doc_content = match.group(1).strip()

#                     # Find the line number
line_number = content[:match.start()].count('\n')

#                     # Parse documentation content
doc_data = self._parse_documentation_content(doc_content, parsing_config)

#                     # Try to find associated code element
code_element = self._find_code_element_after_line(lines, line_number)

#                     if code_element:
doc_item = DocumentationItem(
name = code_element.get('name', 'unknown'),
kind = code_element.get('kind', 'unknown'),
content = doc_data.get('content', doc_content),
file_path = file_path,
line = line_number,
character = 0,
signature = code_element.get('signature'),
parameters = doc_data.get('parameters', []),
returns = doc_data.get('returns'),
examples = doc_data.get('examples', []),
see_also = doc_data.get('see_also', []),
tags = doc_data.get('tags', [])
#                         )

                        documentation_items.append(doc_item)

#         except Exception as e:
self.logger.error(f"Error parsing documentation from comments: {str(e)}", exc_info = True)

#         return documentation_items

#     async def _generate_documentation_from_code(self, file_path: str, content: str) -> List[DocumentationItem]:
#         """Generate documentation from code."""
documentation_items = []

#         try:
#             if not self.config.get('auto_generate', True):
#                 return documentation_items

lines = content.split('\n')

#             # Find functions
func_pattern = r'func\s+(\w+)\s*\([^)]*\)\s*\{'
matches = re.finditer(func_pattern, content)

#             for match in matches:
func_name = match.group(1)
line_number = content[:match.start()].count('\n')

#                 # Generate basic documentation
doc_content = f"Function {func_name}"

doc_item = DocumentationItem(
name = func_name,
kind = 'function',
content = doc_content,
file_path = file_path,
line = line_number,
character = 0,
signature = match.group(0),
tags = ['auto-generated']
#                 )

                documentation_items.append(doc_item)

#             # Find classes
class_pattern = r'class\s+(\w+)\s*\{'
matches = re.finditer(class_pattern, content)

#             for match in matches:
class_name = match.group(1)
line_number = content[:match.start()].count('\n')

#                 # Generate basic documentation
doc_content = f"Class {class_name}"

doc_item = DocumentationItem(
name = class_name,
kind = 'class',
content = doc_content,
file_path = file_path,
line = line_number,
character = 0,
signature = match.group(0),
tags = ['auto-generated']
#                 )

                documentation_items.append(doc_item)

#             # Find variables
var_pattern = r'(?:var|const)\s+(\w+)\s*='
matches = re.finditer(var_pattern, content)

#             for match in matches:
var_name = match.group(1)
line_number = content[:match.start()].count('\n')

#                 # Generate basic documentation
doc_content = f"Variable {var_name}"

doc_item = DocumentationItem(
name = var_name,
kind = 'variable',
content = doc_content,
file_path = file_path,
line = line_number,
character = 0,
tags = ['auto-generated']
#                 )

                documentation_items.append(doc_item)

#         except Exception as e:
self.logger.error(f"Error generating documentation from code: {str(e)}", exc_info = True)

#         return documentation_items

#     def _parse_documentation_content(self, content: str, config: Dict[str, Any]) -> Dict[str, Any]:
#         """Parse documentation content."""
doc_data = {
#             'content': content,
#             'parameters': [],
#             'returns': None,
#             'examples': [],
#             'see_also': [],
#             'tags': []
#         }

lines = content.split('\n')

#         for line in lines:
line = line.strip()

#             # Parse parameters
param_match = re.match(config.get('parameter_pattern', r'@param\s+(\w+)\s+(.+)'), line)
#             if param_match:
                doc_data['parameters'].append({
                    'name': param_match.group(1),
                    'description': param_match.group(2)
#                 })
#                 continue

#             # Parse return
return_match = re.match(config.get('return_pattern', r'@return\s+(.+)'), line)
#             if return_match:
doc_data['returns'] = return_match.group(1)
#                 continue

#             # Parse example
example_match = re.match(config.get('example_pattern', r'@example\s+(.+)'), line)
#             if example_match:
                doc_data['examples'].append(example_match.group(1))
#                 continue

#             # Parse see also
see_match = re.match(config.get('see_also_pattern', r'@see\s+(.+)'), line)
#             if see_match:
                doc_data['see_also'].append(see_match.group(1))
#                 continue

#         return doc_data

#     def _find_code_element_after_line(self, lines: List[str], line_number: int) -> Optional[Dict[str, Any]]:
#         """Find code element after a line."""
#         try:
#             # Look in the next few lines
#             for i in range(line_number + 1, min(len(lines), line_number + 5)):
line = lines[i].strip()

#                 # Check for function
func_match = re.match(r'func\s+(\w+)\s*\(', line)
#                 if func_match:
#                     return {
                        'name': func_match.group(1),
#                         'kind': 'function',
#                         'signature': line
#                     }

#                 # Check for class
class_match = re.match(r'class\s+(\w+)', line)
#                 if class_match:
#                     return {
                        'name': class_match.group(1),
#                         'kind': 'class',
#                         'signature': line
#                     }

#                 # Check for variable
var_match = re.match(r'(?:var|const)\s+(\w+)\s*=', line)
#                 if var_match:
#                     return {
                        'name': var_match.group(1),
#                         'kind': 'variable',
#                         'signature': line
#                     }

#             return None

#         except Exception as e:
self.logger.error(f"Error finding code element after line: {str(e)}", exc_info = True)
#             return None

#     def _update_documentation_index(self, doc_item: DocumentationItem) -> None:
#         """Update documentation index."""
#         try:
#             # Index by name
            self.documentation_index[doc_item.name.lower()].append(doc_item.id)

#             # Index by tags
#             for tag in doc_item.tags:
                self.documentation_index[f"tag:{tag.lower()}"].append(doc_item.id)

#             # Index by kind
            self.documentation_index[f"kind:{doc_item.kind.lower()}"].append(doc_item.id)

#         except Exception as e:
self.logger.error(f"Error updating documentation index: {str(e)}", exc_info = True)

#     async def _build_documentation_index(self) -> None:
#         """Build documentation index from workspace files."""
#         try:
            self.logger.info("Building documentation index")

#             # Find all NoodleCore files
nc_files = list(self.workspace_dir.rglob("*.nc"))
            nc_files.extend(self.workspace_dir.rglob("*.noodle"))

#             # Process each file
#             for file_path in nc_files:
#                 try:
#                     with open(file_path, 'r', encoding='utf-8') as f:
content = f.read()

#                     # Generate documentation
                    await self.generate_documentation(str(file_path), content)

#                 except Exception as e:
self.logger.error(f"Error processing file {file_path}: {str(e)}", exc_info = True)

#             self.logger.info(f"Built documentation index with {len(self.documentation_items)} items")

#         except Exception as e:
self.logger.error(f"Error building documentation index: {str(e)}", exc_info = True)

#     async def _start_index_rebuild_task(self) -> None:
#         """Start periodic index rebuild task."""
#         try:
rebuild_interval = self.config.get('indexing', {}).get('rebuild_interval', 300)

#             async def rebuild_index():
#                 while True:
                    await asyncio.sleep(rebuild_interval)
                    await self._build_documentation_index()

self.index_rebuild_task = asyncio.create_task(rebuild_index())

#         except Exception as e:
self.logger.error(f"Error starting index rebuild task: {str(e)}", exc_info = True)

#     def _apply_search_filters(self, items: List[DocumentationItem], filters: Optional[Dict[str, Any]]) -> List[DocumentationItem]:
#         """Apply search filters to items."""
#         if not filters:
            return list(items)

filtered_items = []

#         for item in items:
include = True

#             # Filter by kind
#             if 'kind' in filters and item.kind != filters['kind']:
include = False

#             # Filter by tags
#             if 'tags' in filters:
required_tags = filters['tags']
#                 if not any(tag in item.tags for tag in required_tags):
include = False

#             # Filter by file path
#             if 'file_path' in filters and item.file_path != filters['file_path']:
include = False

#             if include:
                filtered_items.append(item)

#         return filtered_items

#     def _matches_search_query(self, item: DocumentationItem, query: str) -> bool:
#         """Check if item matches search query."""
query_lower = query.lower()

#         # Check name
#         if query_lower in item.name.lower():
#             return True

#         # Check content
#         if query_lower in item.content.lower():
#             return True

#         # Check tags
#         for tag in item.tags:
#             if query_lower in tag.lower():
#                 return True

#         return False

#     def _sort_search_results(self, results: List[Dict[str, Any]], query: str) -> List[Dict[str, Any]]:
#         """Sort search results by relevance."""
#         def calculate_relevance(result):
score = 0
query_lower = query.lower()

#             # Name match
#             if query_lower in result['name'].lower():
score + = 10

#             # Exact name match
#             if result['name'].lower() == query_lower:
score + = 20

#             # Content match
#             if query_lower in result['content'].lower():
score + = 5

#             return score

results.sort(key = calculate_relevance, reverse=True)
#         return results

#     async def _export_markdown(self, output_dir: Path) -> Dict[str, Any]:
#         """Export documentation to Markdown."""
#         try:
export_config = self.config.get('export', {})

#             # Create index file
index_content = "# Documentation Index\n\n"

#             # Group by kind
by_kind = defaultdict(list)
#             for item in self.documentation_items.values():
                by_kind[item.kind].append(item)

#             # Generate content for each kind
#             for kind, items in by_kind.items():
index_content + = f"## {kind.title()}s\n\n"

#                 # Create kind file
kind_content = f"# {kind.title()}s\n\n"

#                 for item in items:
#                     # Add to index
index_content + = f"- [{item.name}](./{kind}/{item.name}.md)\n"

#                     # Add to kind file
kind_content + = f"## {item.name}\n\n"

#                     if item.signature:
kind_content + = f"```\n{item.signature}\n```\n\n"

kind_content + = f"{item.content}\n\n"

#                     if item.parameters:
kind_content + = "### Parameters\n\n"
#                         for param in item.parameters:
kind_content + = f"- **{param.get('name', '')}**: {param.get('description', '')}\n"
kind_content + = "\n"

#                     if item.returns:
kind_content + = f"### Returns\n\n{item.returns}\n\n"

#                     if item.examples:
kind_content + = "### Examples\n\n"
#                         for example in item.examples:
kind_content + = f"```\n{example}\n```\n\n"

#                     if item.see_also:
kind_content + = "### See Also\n\n"
#                         for see in item.see_also:
kind_content + = f"- {see}\n"
kind_content + = "\n"

#                 # Write kind file
kind_dir = math.divide(output_dir, kind)
kind_dir.mkdir(exist_ok = True)

#                 with open(kind_dir / "index.md", 'w', encoding='utf-8') as f:
                    f.write(kind_content)

#             # Write index file
#             with open(output_dir / "index.md", 'w', encoding='utf-8') as f:
                f.write(index_content)

#             return {
#                 'success': True,
#                 'message': f"Exported documentation to Markdown in {output_dir}",
#                 'format': 'markdown'
#             }

#         except Exception as e:
self.logger.error(f"Error exporting to Markdown: {str(e)}", exc_info = True)
#             return {
#                 'success': False,
                'error': f"Error exporting to Markdown: {str(e)}"
#             }

#     async def _export_html(self, output_dir: Path) -> Dict[str, Any]:
#         """Export documentation to HTML."""
#         # Simplified HTML export
#         try:
#             # Create index file
index_content = """<!DOCTYPE html>
# <html>
# <head>
#     <title>Documentation</title>
#     <style>
#         body { font-family: Arial, sans-serif; margin: 40px; }
#         h1, h2, h3 { color: #333; }
#         code { background-color: #f5f5f5; padding: 2px 4px; border-radius: 3px; }
#         pre { background-color: #f5f5f5; padding: 10px; border-radius: 5px; overflow-x: auto; }
#     </style>
# </head>
# <body>
#     <h1>Documentation</h1>
# """

#             # Add items
#             for item in self.documentation_items.values():
index_content + = f"<h2>{item.name}</h2>\n"

#                 if item.signature:
index_content + = f"<pre><code>{item.signature}</code></pre>\n"

index_content + = f"<p>{item.content}</p>\n"

index_content + = """
# </body>
# </html>
# """

#             # Write index file
#             with open(output_dir / "index.html", 'w', encoding='utf-8') as f:
                f.write(index_content)

#             return {
#                 'success': True,
#                 'message': f"Exported documentation to HTML in {output_dir}",
#                 'format': 'html'
#             }

#         except Exception as e:
self.logger.error(f"Error exporting to HTML: {str(e)}", exc_info = True)
#             return {
#                 'success': False,
                'error': f"Error exporting to HTML: {str(e)}"
#             }

#     async def _export_json(self, output_dir: Path) -> Dict[str, Any]:
#         """Export documentation to JSON."""
#         try:
#             # Convert items to dictionaries
#             items_data = [item.to_dict() for item in self.documentation_items.values()]

#             # Write JSON file
#             with open(output_dir / "documentation.json", 'w', encoding='utf-8') as f:
json.dump(items_data, f, indent = 2)

#             return {
#                 'success': True,
#                 'message': f"Exported documentation to JSON in {output_dir}",
#                 'format': 'json'
#             }

#         except Exception as e:
self.logger.error(f"Error exporting to JSON: {str(e)}", exc_info = True)
#             return {
#                 'success': False,
                'error': f"Error exporting to JSON: {str(e)}"
#             }

#     async def _load_config(self) -> Dict[str, Any]:
#         """Load documentation configuration."""
#         try:
#             if self.config_file.exists():
#                 with open(self.config_file, 'r', encoding='utf-8') as f:
config = json.load(f)

#                 # Merge with default config
merged_config = self._merge_configs(self.default_config, config)
#                 return merged_config
#             else:
#                 # Create default config file
                await self._save_config(self.default_config)
                return self.default_config.copy()

        except (json.JSONDecodeError, IOError) as e:
self.logger.error(f"Error loading documentation config: {str(e)}", exc_info = True)
            return self.default_config.copy()

#     async def _save_config(self, config: Dict[str, Any]) -> None:
#         """Save documentation configuration."""
#         try:
#             with open(self.config_file, 'w', encoding='utf-8') as f:
json.dump(config, f, indent = 2)
#         except IOError as e:
self.logger.error(f"Error saving documentation config: {str(e)}", exc_info = True)

#     def _merge_configs(self, default: Dict[str, Any], custom: Dict[str, Any]) -> Dict[str, Any]:
#         """Merge custom config with default config."""
result = default.copy()

#         for key, value in custom.items():
#             if key in result and isinstance(result[key], dict) and isinstance(value, dict):
result[key] = self._merge_configs(result[key], value)
#             else:
result[key] = value

#         return result

#     async def _load_documentation_index(self) -> None:
#         """Load documentation index."""
#         try:
#             if self.index_file.exists():
#                 with open(self.index_file, 'r', encoding='utf-8') as f:
index_data = json.load(f)

#                 # Load items
#                 for item_data in index_data.get('items', []):
item = DocumentationItem(
name = item_data['name'],
kind = item_data['kind'],
content = item_data['content'],
file_path = item_data['file_path'],
line = item_data['line'],
character = item_data['character'],
signature = item_data.get('signature'),
parameters = item_data.get('parameters', []),
returns = item_data.get('returns'),
examples = item_data.get('examples', []),
see_also = item_data.get('see_also', []),
tags = item_data.get('tags', [])
#                     )

self.documentation_items[item.id] = item
                    self._update_documentation_index(item)

#         except Exception as e:
self.logger.error(f"Error loading documentation index: {str(e)}", exc_info = True)

#     async def _save_documentation_index(self) -> None:
#         """Save documentation index."""
#         try:
index_data = {
#                 'items': [item.to_dict() for item in self.documentation_items.values()],
                'last_updated': datetime.now().isoformat()
#             }

#             with open(self.index_file, 'w', encoding='utf-8') as f:
json.dump(index_data, f, indent = 2, default=str)

#         except Exception as e:
self.logger.error(f"Error saving documentation index: {str(e)}", exc_info = True)

#     async def _load_cache(self) -> None:
#         """Load documentation cache."""
#         try:
cache_file = self.cache_dir / "docs_cache.json"

#             if cache_file.exists():
#                 with open(cache_file, 'r') as f:
cache_data = json.load(f)

self.documentation_cache = cache_data.get('data', {})
self.cache_timestamps = cache_data.get('timestamps', {})

#                 # Check TTL and remove expired entries
                await self._cleanup_cache()

#         except Exception as e:
self.logger.error(f"Error loading documentation cache: {str(e)}", exc_info = True)
self.documentation_cache = {}
self.cache_timestamps = {}

#     async def _save_cache(self) -> None:
#         """Save documentation cache."""
#         try:
cache_file = self.cache_dir / "docs_cache.json"

cache_data = {
#                 'data': self.documentation_cache,
#                 'timestamps': self.cache_timestamps
#             }

#             with open(cache_file, 'w') as f:
json.dump(cache_data, f, indent = 2, default=str)

#         except Exception as e:
self.logger.error(f"Error saving documentation cache: {str(e)}", exc_info = True)

#     async def _get_from_cache(self, key: str) -> Optional[Dict[str, Any]]:
#         """Get data from cache."""
#         try:
#             if not self.config.get('cache_enabled', True):
#                 return None

#             if key in self.documentation_cache:
#                 # Check TTL
#                 if key in self.cache_timestamps:
timestamp = datetime.fromisoformat(self.cache_timestamps[key])
ttl = self.config.get('cache_ttl', 3600)

#                     if (datetime.now() - timestamp).total_seconds() < ttl:
#                         return self.documentation_cache[key]
#                     else:
#                         # Expired, remove from cache
#                         del self.documentation_cache[key]
#                         del self.cache_timestamps[key]

#             return None

#         except Exception as e:
self.logger.error(f"Error getting from documentation cache: {str(e)}", exc_info = True)
#             return None

#     async def _save_to_cache(self, key: str, data: Dict[str, Any]) -> None:
#         """Save data to cache."""
#         try:
#             if not self.config.get('cache_enabled', True):
#                 return

#             # Check cache size
max_size = self.config.get('cache_size', 1000)
#             if len(self.documentation_cache) >= max_size:
#                 # Remove oldest entry
oldest_key = min(self.cache_timestamps.keys(),
key = lambda k: datetime.fromisoformat(self.cache_timestamps[k]))
#                 del self.documentation_cache[oldest_key]
#                 del self.cache_timestamps[oldest_key]

#             # Save to cache
self.documentation_cache[key] = data
self.cache_timestamps[key] = datetime.now().isoformat()

#         except Exception as e:
self.logger.error(f"Error saving to documentation cache: {str(e)}", exc_info = True)

#     async def _cleanup_cache(self) -> None:
#         """Clean up expired cache entries."""
#         try:
ttl = self.config.get('cache_ttl', 3600)
current_time = datetime.now()

expired_keys = []
#             for key, timestamp_str in self.cache_timestamps.items():
timestamp = datetime.fromisoformat(timestamp_str)
#                 if (current_time - timestamp).total_seconds() >= ttl:
                    expired_keys.append(key)

#             for key in expired_keys:
#                 if key in self.documentation_cache:
#                     del self.documentation_cache[key]
#                 del self.cache_timestamps[key]

#         except Exception as e:
self.logger.error(f"Error cleaning up documentation cache: {str(e)}", exc_info = True)

#     def _update_performance_stats(self, generation_time: float, success: bool) -> None:
#         """Update performance statistics."""
self.performance_stats['total_generations'] + = 1

#         if success:
self.performance_stats['successful_generations'] + = 1
self.performance_stats['total_generation_time'] + = generation_time
self.performance_stats['average_generation_time'] = (
#                 self.performance_stats['total_generation_time'] /
#                 self.performance_stats['successful_generations']
#             )
#         else:
self.performance_stats['failed_generations'] + = 1

#     async def get_integration_info(self) -> Dict[str, Any]:
#         """
#         Get information about the Documentation Integration.

#         Returns:
#             Dictionary containing integration information
#         """
#         try:
#             return {
#                 'name': self.name,
#                 'version': '1.0.0',
                'enabled': self.config.get('enabled', True),
#                 'features': {
                    'hover_docs': self.config.get('hover_docs', True),
                    'auto_generate': self.config.get('auto_generate', True),
                    'parse_comments': self.config.get('parse_comments', True),
                    'generate_from_code': self.config.get('generate_from_code', True)
#                 },
#                 'performance_stats': self.performance_stats,
#                 'cache_stats': {
                    'enabled': self.config.get('cache_enabled', True),
                    'size': len(self.documentation_cache),
                    'max_size': self.config.get('cache_size', 1000),
                    'ttl': self.config.get('cache_ttl', 3600)
#                 },
                'documentation_count': len(self.documentation_items),
#                 'index_stats': {
                    'entries': len(self.documentation_index),
                    'auto_rebuild': self.config.get('indexing', {}).get('auto_rebuild', True),
                    'rebuild_interval': self.config.get('indexing', {}).get('rebuild_interval', 300)
#                 },
                'request_id': str(uuid.uuid4())
#             }

#         except Exception as e:
error_code = DOCUMENTATION_INTEGRATION_ERROR_CODES["DOCUMENTATION_CONFIG_ERROR"]
self.logger.error(f"Error getting integration info: {str(e)}", exc_info = True)

#             return {
#                 'success': False,
                'error': f"Error getting integration info: {str(e)}",
#                 'error_code': error_code,
                'request_id': str(uuid.uuid4())
#             }