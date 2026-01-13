# Converted from Python to NoodleCore
# Original file: src

# """
# Code Completion Engine Module

# This module implements intelligent code completion for NoodleCore IDE integration.
# """

import asyncio
import json
import os
import re
import uuid
import hashlib
import typing.Dict
import pathlib.Path
import datetime.datetime
import collections.defaultdict

# Import logging
import ..logs.get_logger
import ..adapters.get_adapter_manager

# Code Completion Engine error codes (6501-6599)
COMPLETION_ENGINE_ERROR_CODES = {
#     "COMPLETION_FAILED": 6501,
#     "CONTEXT_ANALYSIS_FAILED": 6502,
#     "SUGGESTION_GENERATION_FAILED": 6503,
#     "COMPLETION_CACHE_ERROR": 6504,
#     "COMPLETION_CONFIG_ERROR": 6505,
#     "COMPLETION_TIMEOUT": 6506,
#     "COMPLETION_RANKING_FAILED": 6507,
#     "COMPLETION_FILTERING_FAILED": 6508,
#     "COMPLETION_LEARNING_FAILED": 6509,
#     "COMPLETION_PERSONALIZATION_FAILED": 6510,
# }


class CompletionItem
    #     """Represents a code completion item."""

    #     def __init__(self,
    #                  label: str,
    #                  kind: int,
    detail: Optional[str] = None,
    documentation: Optional[str] = None,
    insert_text: Optional[str] = None,
    insert_text_format: int = 1,  # 1=PlainText, 2=Snippet
    filter_text: Optional[str] = None,
    sort_text: Optional[str] = None,
    data: Optional[Dict[str, Any]] = None,
    priority: float = 0.0,
    source: str = "noodlecore"):""
    #         Initialize completion item.

    #         Args:
    #             label: Display label
    #             kind: Completion item kind
    #             detail: Detail information
    #             documentation: Documentation
    #             insert_text: Text to insert
    #             insert_text_format: Insert text format
    #             filter_text: Filter text
    #             sort_text: Sort text
    #             data: Additional data
    #             priority: Priority for ranking
    #             source: Source of completion
    #         """
    self.label = label
    self.kind = kind
    self.detail = detail
    self.documentation = documentation
    self.insert_text = insert_text or label
    self.insert_text_format = insert_text_format
    self.filter_text = filter_text or label
    self.sort_text = sort_text or label
    self.data = data or {}
    self.priority = priority
    self.source = source

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary."""
    result = {
    #             'label': self.label,
    #             'kind': self.kind,
    #             'insertText': self.insert_text,
    #             'insertTextFormat': self.insert_text_format,
    #             'filterText': self.filter_text,
    #             'sortText': self.sort_text,
    #             'data': self.data,
    #             'priority': self.priority,
    #             'source': self.source
    #         }

    #         if self.detail:
    result['detail'] = self.detail

    #         if self.documentation:
    result['documentation'] = {
    #                 'kind': 'markdown',
    #                 'value': self.documentation
    #             }

    #         return result


class CompletionContext
    #     """Represents completion context."""

    #     def __init__(self,
    #                  file_path: str,
    #                  line: int,
    #                  character: int,
    #                  line_text: str,
    #                  prefix: str,
    #                  suffix: str,
    #                  previous_lines: List[str],
    #                  next_lines: List[str],
    #                  file_content: str):""
    #         Initialize completion context.

    #         Args:
    #             file_path: Path to the file
    #             line: Line number
    #             character: Character position
    #             line_text: Current line text
    #             prefix: Text before cursor
    #             suffix: Text after cursor
    #             previous_lines: Previous lines
    #             next_lines: Next lines
    #             file_content: Entire file content
    #         """
    self.file_path = file_path
    self.line = line
    self.character = character
    self.line_text = line_text
    self.prefix = prefix
    self.suffix = suffix
    self.previous_lines = previous_lines
    self.next_lines = next_lines
    self.file_content = file_content


class CompletionEngine
    #     """Code completion engine for NoodleCore IDE integration."""

    #     def __init__(self, workspace_dir: Optional[str] = None):""
    #         Initialize the Completion Engine.

    #         Args:
    #             workspace_dir: Workspace directory
    #         """
    self.name = "CompletionEngine"
    self.workspace_dir = Path(workspace_dir or os.getcwd())
    self.cache_dir = self.workspace_dir / ".noodlecore" / "completion_cache"
    self.config_file = self.workspace_dir / ".noodlecore" / "completion_config.json"
    self.snippets_file = self.workspace_dir / ".noodlecore" / "snippets.json"
    self.learning_file = self.workspace_dir / ".noodlecore" / "completion_learning.json"

    #         # Initialize logger
    self.logger = get_logger(f"{__name__}.{self.name}")

    #         # Ensure directories exist
    self.cache_dir.mkdir(parents = True, exist_ok=True)

    #         # AI adapter manager
    self.adapter_manager = get_adapter_manager()

    #         # Default configuration
    self.default_config = {
    #             'enabled': True,
    #             'ai_powered': True,
    #             'max_suggestions': 10,
    #             'auto_import': True,
    #             'snippet_support': True,
    #             'context_aware': True,
    #             'learning_enabled': True,
    #             'personalization_enabled': True,
    #             'debounce_delay': 100,  # milliseconds
    #             'cache_enabled': True,
    #             'cache_ttl': 3600,  # seconds
    #             'cache_size': 1000,
    #             'timeout': 2000,  # milliseconds
                'trigger_characters': ['.', ':', '(', '[', ' ', '"', "'"],
    #             'providers': {
    #                 'keywords': True,
    #                 'snippets': True,
    #                 'functions': True,
    #                 'variables': True,
    #                 'modules': True,
    #                 'ai_suggestions': True,
    #                 'context_aware': True
    #             },
    #             'ranking': {
    #                 'frequency_weight': 0.3,
    #                 'context_weight': 0.4,
    #                 'recency_weight': 0.2,
    #                 'ai_confidence_weight': 0.1
    #             },
    #             'filtering': {
    #                 'fuzzy_matching': True,
    #                 'case_sensitive': False,
    #                 'min_prefix_length': 1,
    #                 'max_results': 20
    #             },
    #             'learning': {
    #                 'track_usage': True,
    #                 'track_context': True,
    #                 'track_success': True,
    #                 'adapt_to_user_style': True,
    #                 'learning_rate': 0.1
    #             },
    #             'personalization': {
    #                 'user_preferences': True,
    #                 'code_style_adaptation': True,
    #                 'frequent_items_boost': True,
    #                 'recent_items_boost': True
    #             }
    #         }

    #         # Configuration
    self.config = {}

    #         # Completion items database
    self.keywords = []
    self.snippets = {}
    self.functions = defaultdict(list)
    self.variables = defaultdict(list)
    self.modules = []

    #         # Learning data
    self.usage_stats = defaultdict(int)
    self.context_stats = defaultdict(list)
    self.success_stats = defaultdict(float)
    self.user_preferences = {}

    #         # Cache
    self.completion_cache = {}
    self.cache_timestamps = {}

    #         # Performance tracking
    self.performance_stats = {
    #             'total_completions': 0,
    #             'successful_completions': 0,
    #             'failed_completions': 0,
    #             'cache_hits': 0,
    #             'cache_misses': 0,
    #             'average_completion_time': 0,
    #             'total_completion_time': 0,
                'last_reset': datetime.now()
    #         }

            # Completion kinds (LSP)
    self.COMPLETION_KINDS = {
    #             'text': 1,
    #             'method': 2,
    #             'function': 3,
    #             'constructor': 4,
    #             'field': 5,
    #             'variable': 6,
    #             'class': 7,
    #             'interface': 8,
    #             'module': 9,
    #             'property': 10,
    #             'unit': 11,
    #             'value': 12,
    #             'enum': 13,
    #             'keyword': 14,
    #             'snippet': 15,
    #             'color': 16,
    #             'file': 17,
    #             'reference': 18,
    #             'folder': 19,
    #             'enum_member': 20,
    #             'constant': 21,
    #             'struct': 22,
    #             'event': 23,
    #             'operator': 24,
    #             'type_parameter': 25
    #         }

    #     async def initialize(self) -Dict[str, Any]):
    #         """
    #         Initialize the Completion Engine.

    #         Returns:
    #             Dictionary containing initialization result
    #         """
    #         try:
                self.logger.info("Initializing Completion Engine")

    #             # Load configuration
    self.config = await self._load_config()

    #             # Initialize completion items
                await self._initialize_completion_items()

    #             # Load learning data
                await self._load_learning_data()

    #             # Load cache
                await self._load_cache()

                self.logger.info("Completion Engine initialized successfully")

    #             return {
    #                 'success': True,
    #                 'message': "Completion Engine initialized successfully",
    #                 'features': {
                        'ai_powered': self.config.get('ai_powered', True),
                        'snippet_support': self.config.get('snippet_support', True),
                        'context_aware': self.config.get('context_aware', True),
                        'learning_enabled': self.config.get('learning_enabled', True),
                        'personalization_enabled': self.config.get('personalization_enabled', True)
    #                 },
                    'max_suggestions': self.config.get('max_suggestions', 10),
                    'request_id': str(uuid.uuid4())
    #             }

    #         except Exception as e:
    error_code = COMPLETION_ENGINE_ERROR_CODES["COMPLETION_CONFIG_ERROR"]
    self.logger.error(f"Failed to initialize Completion Engine: {str(e)}", exc_info = True)

    #             return {
    #                 'success': False,
                    'error': f"Failed to initialize Completion Engine: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def shutdown(self) -Dict[str, Any]):
    #         """
    #         Shutdown the Completion Engine.

    #         Returns:
    #             Dictionary containing shutdown result
    #         """
    #         try:
                self.logger.info("Shutting down Completion Engine")

    #             # Save learning data
                await self._save_learning_data()

    #             # Save cache
                await self._save_cache()

                self.logger.info("Completion Engine shutdown successfully")

    #             return {
    #                 'success': True,
    #                 'message': "Completion Engine shutdown successfully",
    #                 'performance_stats': self.performance_stats,
                    'request_id': str(uuid.uuid4())
    #             }

    #         except Exception as e:
    error_code = COMPLETION_ENGINE_ERROR_CODES["COMPLETION_CONFIG_ERROR"]
    self.logger.error(f"Failed to shutdown Completion Engine: {str(e)}", exc_info = True)

    #             return {
    #                 'success': False,
                    'error': f"Failed to shutdown Completion Engine: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def get_completions(self, file_path: str, line: int, character: int, file_content: str) -Dict[str, Any]):
    #         """
    #         Get code completions for a position.

    #         Args:
    #             file_path: Path to the file
    #             line: Line number
    #             character: Character position
    #             file_content: File content

    #         Returns:
    #             Dictionary containing completion results
    #         """
    #         try:
    start_time = datetime.now()

    #             if not self.config.get('enabled', True):
    #                 return {
    #                     'success': True,
    #                     'completions': [],
                        'request_id': str(uuid.uuid4())
    #                 }

    #             # Parse context
    context = self._parse_context(file_path, line, character, file_content)

    #             # Check cache first
    cache_key = self._get_cache_key(context)
    cached_result = await self._get_from_cache(cache_key)
    #             if cached_result:
    self.performance_stats['cache_hits'] + = 1
    #                 return {
    #                     'success': True,
    #                     'completions': cached_result,
    #                     'cache_hit': True,
                        'request_id': str(uuid.uuid4())
    #                 }

    self.performance_stats['cache_misses'] + = 1

    #             # Generate completions
    completions = await self._generate_completions(context)

    #             # Rank and filter completions
    ranked_completions = await self._rank_completions(completions, context)
    filtered_completions = await self._filter_completions(ranked_completions, context)

    #             # Limit to max suggestions
    max_suggestions = self.config.get('max_suggestions', 10)
    final_completions = filtered_completions[:max_suggestions]

    #             # Convert to dictionaries
    #             completion_dicts = [item.to_dict() for item in final_completions]

    #             # Cache result
                await self._save_to_cache(cache_key, completion_dicts)

    #             # Update performance stats
    end_time = datetime.now()
    completion_time = (end_time - start_time).total_seconds() * 1000  # Convert to milliseconds
                self._update_performance_stats(completion_time, True)

    #             return {
    #                 'success': True,
    #                 'completions': completion_dicts,
    #                 'cache_hit': False,
                    'request_id': str(uuid.uuid4())
    #             }

    #         except Exception as e:
    error_code = COMPLETION_ENGINE_ERROR_CODES["COMPLETION_FAILED"]
    self.logger.error(f"Error getting completions: {str(e)}", exc_info = True)
                self._update_performance_stats(0, False)

    #             return {
    #                 'success': False,
                    'error': f"Error getting completions: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def record_completion_usage(self, file_path: str, completion_item: Dict[str, Any], success: bool = True) -Dict[str, Any]):
    #         """
    #         Record usage of a completion item for learning.

    #         Args:
    #             file_path: Path to the file
    #             completion_item: The completion item that was used
    #             success: Whether the completion was successful

    #         Returns:
    #             Dictionary containing result
    #         """
    #         try:
    #             if not self.config.get('learning_enabled', True):
    #                 return {
    #                     'success': True,
    #                     'message': "Learning is disabled",
                        'request_id': str(uuid.uuid4())
    #                 }

    label = completion_item.get('label', '')
    source = completion_item.get('source', 'noodlecore')

    #             # Update usage stats
    key = f"{source}:{label}"
    self.usage_stats[key] + = 1

    #             # Update success stats
    #             if success:
    self.success_stats[key] = (self.success_stats.get(key + 0.0 * 0.9), 0.1  # Moving average)
    #             else:
    self.success_stats[key] = (self.success_stats.get(key * 0.0, 0.9)  # Decrease on failure)

    #             # Update context stats
    #             # TODO: Add more sophisticated context tracking

    #             return {
    #                 'success': True,
    #                 'message': "Completion usage recorded",
                    'request_id': str(uuid.uuid4())
    #             }

    #         except Exception as e:
    error_code = COMPLETION_ENGINE_ERROR_CODES["COMPLETION_LEARNING_FAILED"]
    self.logger.error(f"Error recording completion usage: {str(e)}", exc_info = True)

    #             return {
    #                 'success': False,
                    'error': f"Error recording completion usage: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     def _parse_context(self, file_path: str, line: int, character: int, file_content: str) -CompletionContext):
    #         """
    #         Parse completion context.

    #         Args:
    #             file_path: Path to the file
    #             line: Line number
    #             character: Character position
    #             file_content: File content

    #         Returns:
    #             Completion context
    #         """
    lines = file_content.split('\n')

    #         # Get current line
    #         line_text = lines[line] if line < len(lines) else ""

    #         # Get prefix and suffix
    prefix = line_text[:character]
    suffix = line_text[character:]

    #         # Get previous and next lines
    previous_lines = lines[max(0 - line, 5:line])
    next_lines = lines[line + 1:line+6]

            return CompletionContext(
    file_path = file_path,
    line = line,
    character = character,
    line_text = line_text,
    prefix = prefix,
    suffix = suffix,
    previous_lines = previous_lines,
    next_lines = next_lines,
    file_content = file_content
    #         )

    #     async def _generate_completions(self, context: CompletionContext) -List[CompletionItem]):
    #         """
    #         Generate completion items.

    #         Args:
    #             context: Completion context

    #         Returns:
    #             List of completion items
    #         """
    completions = []

    #         # Generate keyword completions
    #         if self.config.get('providers', {}).get('keywords', True):
    keyword_completions = await self._generate_keyword_completions(context)
                completions.extend(keyword_completions)

    #         # Generate snippet completions
    #         if self.config.get('providers', {}).get('snippets', True):
    snippet_completions = await self._generate_snippet_completions(context)
                completions.extend(snippet_completions)

    #         # Generate function completions
    #         if self.config.get('providers', {}).get('functions', True):
    function_completions = await self._generate_function_completions(context)
                completions.extend(function_completions)

    #         # Generate variable completions
    #         if self.config.get('providers', {}).get('variables', True):
    variable_completions = await self._generate_variable_completions(context)
                completions.extend(variable_completions)

    #         # Generate module completions
    #         if self.config.get('providers', {}).get('modules', True):
    module_completions = await self._generate_module_completions(context)
                completions.extend(module_completions)

    #         # Generate AI-powered completions
    #         if self.config.get('providers', {}).get('ai_suggestions', True) and self.config.get('ai_powered', True):
    ai_completions = await self._generate_ai_completions(context)
                completions.extend(ai_completions)

    #         return completions

    #     async def _generate_keyword_completions(self, context: CompletionContext) -List[CompletionItem]):
    #         """Generate keyword completions."""
    completions = []

    #         # NoodleCore keywords
    keywords = [
                ('func', self.COMPLETION_KINDS['keyword'], 'Define a function', 'func ${1:name}(${2:params}) {\n\t${3:// body}\n}', 'func ${1:name}(${2:params}) {\n\t${3:// body}\n}'),
    ('var', self.COMPLETION_KINDS['keyword'], 'Declare a variable', 'var ${1:name} = ${2:value};', 'var ${1:name} = ${2:value};'),
    ('const', self.COMPLETION_KINDS['keyword'], 'Declare a constant', 'const ${1:name} = ${2:value};', 'const ${1:name} = ${2:value};'),
    #             ('if', self.COMPLETION_KINDS['keyword'], 'Conditional statement', 'if (${1:condition}) {\n\t${2:// body}\n}', 'if (${1:condition}) {\n\t${2:// body}\n}'),
                ('else', self.COMPLETION_KINDS['keyword'], 'Else clause', 'else {\n\t${1:// body}\n}', 'else {\n\t${1:// body}\n}'),
    #             ('for', self.COMPLETION_KINDS['keyword'], 'For loop', 'for (${1:init}; ${2:condition}; ${3:increment}) {\n\t${4:// body}\n}', 'for (${1:init}; ${2:condition}; ${3:increment}) {\n\t${4:// body}\n}'),
    #             ('while', self.COMPLETION_KINDS['keyword'], 'While loop', 'while (${1:condition}) {\n\t${2:// body}\n}', 'while (${1:condition}) {\n\t${2:// body}\n}'),
                ('return', self.COMPLETION_KINDS['keyword'], 'Return statement', 'return ${1:value};', 'return ${1:value};'),
                ('import', self.COMPLETION_KINDS['keyword'], 'Import module', 'import ${1:module};', 'import ${1:module};'),
                ('export', self.COMPLETION_KINDS['keyword'], 'Export module', 'export ${1:name};', 'export ${1:name};'),
    #             ('class', self.COMPLETION_KINDS['keyword'], 'Define a class', 'class ${1:name} {\n\t${2:// body}\n}', 'class ${1:name} {\n\t${2:// body}\n}'),
                ('try', self.COMPLETION_KINDS['keyword'], 'Try block', 'try {\n\t${1:// body}\n} catch (${2:error}) {\n\t${3:// handler}\n}', 'try {\n\t${1:// body}\n} catch (${2:error}) {\n\t${3:// handler}\n}'),
                ('catch', self.COMPLETION_KINDS['keyword'], 'Catch block', 'catch (${1:error}) {\n\t${2:// handler}\n}', 'catch (${1:error}) {\n\t${2:// handler}\n}'),
                ('throw', self.COMPLETION_KINDS['keyword'], 'Throw exception', 'throw ${1:error};', 'throw ${1:error};'),
                ('async', self.COMPLETION_KINDS['keyword'], 'Async function', 'async func ${1:name}(${2:params}) {\n\t${3:// body}\n}', 'async func ${1:name}(${2:params}) {\n\t${3:// body}\n}'),
                ('await', self.COMPLETION_KINDS['keyword'], 'Await expression', 'await ${1:expression};', 'await ${1:expression};')
    #         ]

    #         for keyword, kind, detail, documentation, insert_text in keywords:
    #             if keyword.startswith(context.prefix):
    priority = self._calculate_priority(f"keyword:{keyword}", context)
    completion = CompletionItem(
    label = keyword,
    kind = kind,
    detail = detail,
    documentation = documentation,
    insert_text = insert_text,
    insert_text_format = 2,  # Snippet
    priority = priority,
    source = "keywords"
    #                 )
                    completions.append(completion)

    #         return completions

    #     async def _generate_snippet_completions(self, context: CompletionContext) -List[CompletionItem]):
    #         """Generate snippet completions."""
    completions = []

    #         # Common snippets
    snippets = [
                ('func', 'function', 'func ${1:name}(${2:params}) {\n\t${3:// body}\n}', 'Define a function'),
    #             ('class', 'class', 'class ${1:name} {\n\tconstructor(${2:params}) {\n\t\t${3:// init}\n\t}\n\t${4:// methods}\n}', 'Define a class'),
    #             ('if', 'if statement', 'if (${1:condition}) {\n\t${2:// body}\n}', 'If statement'),
    #             ('for', 'for loop', 'for (${1:init}; ${2:condition}; ${3:increment}) {\n\t${4:// body}\n}', 'For loop'),
    #             ('while', 'while loop', 'while (${1:condition}) {\n\t${2:// body}\n}', 'While loop'),
                ('try', 'try-catch', 'try {\n\t${1:// body}\n} catch (${2:error}) {\n\t${3:// handler}\n}', 'Try-catch block'),
                ('log', 'console.log', 'console.log(${1:message});', 'Log to console'),
                ('import', 'import', 'import ${1:module} from "${2:path}";', 'Import module'),
                ('export', 'export', 'export default ${1:name};', 'Export default')
    #         ]

    #         for prefix, label, insert_text, documentation in snippets:
    #             if prefix.startswith(context.prefix):
    priority = self._calculate_priority(f"snippet:{label}", context)
    completion = CompletionItem(
    label = label,
    kind = self.COMPLETION_KINDS['snippet'],
    detail = f"Snippet: {label}",
    documentation = documentation,
    insert_text = insert_text,
    insert_text_format = 2,  # Snippet
    priority = priority,
    source = "snippets"
    #                 )
                    completions.append(completion)

    #         return completions

    #     async def _generate_function_completions(self, context: CompletionContext) -List[CompletionItem]):
    #         """Generate function completions."""
    completions = []

    #         # Extract functions from file content
    functions = self._extract_functions(context.file_content)

    #         for func_name, func_info in functions.items():
    #             if func_name.startswith(context.prefix):
    priority = self._calculate_priority(f"function:{func_name}", context)
    completion = CompletionItem(
    label = func_name,
    kind = self.COMPLETION_KINDS['function'],
    detail = f"Function: {func_name}",
    documentation = func_info.get('doc', f"Function {func_name}"),
    insert_text = f"{func_name}(${{1}})",
    insert_text_format = 2,  # Snippet
    priority = priority,
    source = "functions",
    data = func_info
    #                 )
                    completions.append(completion)

    #         return completions

    #     async def _generate_variable_completions(self, context: CompletionContext) -List[CompletionItem]):
    #         """Generate variable completions."""
    completions = []

    #         # Extract variables from file content
    variables = self._extract_variables(context.file_content)

    #         for var_name, var_info in variables.items():
    #             if var_name.startswith(context.prefix):
    priority = self._calculate_priority(f"variable:{var_name}", context)
    completion = CompletionItem(
    label = var_name,
    kind = self.COMPLETION_KINDS['variable'],
    detail = f"Variable: {var_name}",
    documentation = var_info.get('doc', f"Variable {var_name}"),
    insert_text = var_name,
    priority = priority,
    source = "variables",
    data = var_info
    #                 )
                    completions.append(completion)

    #         return completions

    #     async def _generate_module_completions(self, context: CompletionContext) -List[CompletionItem]):
    #         """Generate module completions."""
    completions = []

    #         # Check if we're in an import statement
    #         if 'import' in context.prefix or 'from' in context.prefix:
    #             # Common modules
    modules = [
                    ('std', 'Standard library'),
                    ('math', 'Mathematical functions'),
                    ('io', 'Input/output operations'),
                    ('fs', 'File system operations'),
                    ('net', 'Network operations'),
                    ('crypto', 'Cryptographic functions'),
                    ('http', 'HTTP client/server'),
                    ('json', 'JSON parsing/serialization'),
                    ('utils', 'Utility functions'),
                    ('async', 'Async operations')
    #             ]

    #             for module_name, description in modules:
    #                 if module_name.startswith(context.prefix.split()[-1]):
    priority = self._calculate_priority(f"module:{module_name}", context)
    completion = CompletionItem(
    label = module_name,
    kind = self.COMPLETION_KINDS['module'],
    detail = f"Module: {module_name}",
    documentation = description,
    insert_text = module_name,
    priority = priority,
    source = "modules"
    #                     )
                        completions.append(completion)

    #         return completions

    #     async def _generate_ai_completions(self, context: CompletionContext) -List[CompletionItem]):
    #         """Generate AI-powered completions."""
    completions = []

    #         try:
    #             # Get AI adapter
    adapter = await self.adapter_manager.get_adapter(self.config.get('ai_model', 'zai_glm'))

    #             if not adapter:
    #                 return completions

    #             # Prepare prompt
    prompt = self._prepare_ai_completion_prompt(context)

    #             # Get AI response
    request_data = {
    #                 'prompt': prompt,
    #                 'max_tokens': 200,
    #                 'temperature': 0.3,
                    'timeout': self.config.get('timeout', 2000)
    #             }

    response = await adapter.generate(request_data)

    #             if response.get('success'):
    #                 # Parse AI suggestions
    ai_suggestions = self._parse_ai_suggestions(response.get('content', ''))

    #                 for suggestion in ai_suggestions:
    priority = self._calculate_priority(f"ai:{suggestion['label']}", context)
    completion = CompletionItem(
    label = suggestion['label'],
    kind = suggestion.get('kind', self.COMPLETION_KINDS['text']),
    detail = suggestion.get('detail', 'AI suggestion'),
    documentation = suggestion.get('documentation', ''),
    insert_text = suggestion.get('insert_text', suggestion['label']),
    insert_text_format = suggestion.get('insert_text_format', 1),
    #                         priority=priority * 0.8,  # Slightly lower priority for AI suggestions
    source = "ai",
    data = {'confidence': suggestion.get('confidence', 0.5)}
    #                     )
                        completions.append(completion)

    #         except Exception as e:
    self.logger.error(f"Error generating AI completions: {str(e)}", exc_info = True)

    #         return completions

    #     def _prepare_ai_completion_prompt(self, context: CompletionContext) -str):
    #         """Prepare prompt for AI completion."""
    #         # Get surrounding context
    context_lines = []
            context_lines.extend(context.previous_lines[-3:])
            context_lines.append(context.line_text)
            context_lines.extend(context.next_lines[:3])

    context_text = '\n'.join(context_lines)

    #         return f"""You are a NoodleCore code completion assistant. Based on the following code context, suggest relevant code completions for the cursor position.

# File: {context.file_path}
# Line: {context.line}, Character: {context.character}
# Prefix: "{context.prefix}"
# Suffix: "{context.suffix}"

# Context:
# {context_text}

# Provide 3-5 relevant completion suggestions in JSON format:
# {{
#   "suggestions": [
#     {{
#       "label": "completion_label",
#       "kind": "function|variable|keyword|snippet",
#       "detail": "brief description",
#       "documentation": "detailed description",
#       "insert_text": "text to insert",
#       "insert_text_format": 1|2,
#       "confidence": 0.8
#     }}
#   ]
# }}

# Only respond with the JSON, no additional text."""

#     def _parse_ai_suggestions(self, content: str) -List[Dict[str, Any]]):
#         """Parse AI suggestions from response."""
#         try:
#             # Try to extract JSON from response
#             if '{' in content and '}' in content:
start = content.find('{')
end = content.rfind('}') + 1
json_str = content[start:end]

data = json.loads(json_str)
                return data.get('suggestions', [])
#         except json.JSONDecodeError:
#             pass

#         # Fallback: extract simple suggestions
suggestions = []
lines = content.strip().split('\n')

#         for line in lines:
line = line.strip()
#             if line and not line.startswith('#') and not line.startswith('//'):
                suggestions.append({
#                     'label': line,
#                     'kind': 'text',
#                     'detail': 'AI suggestion',
#                     'documentation': '',
#                     'insert_text': line,
#                     'insert_text_format': 1,
#                     'confidence': 0.5
#                 })

#         return suggestions[:5]  # Limit to 5 suggestions

#     def _extract_functions(self, content: str) -Dict[str, Dict[str, Any]]):
#         """Extract functions from content."""
functions = {}

#         # Simple regex for function extraction
pattern = r'func\s+(\w+)\s*\([^)]*\)\s*\{'
matches = re.finditer(pattern, content)

#         for match in matches:
func_name = match.group(1)
functions[func_name] = {
#                 'name': func_name,
                'line': content[:match.start()].count('\n'),
#                 'doc': f"Function {func_name}"
#             }

#         return functions

#     def _extract_variables(self, content: str) -Dict[str, Dict[str, Any]]):
#         """Extract variables from content."""
variables = {}

#         # Simple regex for variable extraction
pattern = r'(?:var|const)\s+(\w+)\s*='
matches = re.finditer(pattern, content)

#         for match in matches:
var_name = match.group(1)
variables[var_name] = {
#                 'name': var_name,
                'line': content[:match.start()].count('\n'),
#                 'doc': f"Variable {var_name}"
#             }

#         return variables

#     async def _rank_completions(self, completions: List[CompletionItem], context: CompletionContext) -List[CompletionItem]):
#         """Rank completion items."""
#         try:
#             # Calculate scores for each completion
#             for completion in completions:
score = completion.priority

#                 # Apply ranking weights
ranking_config = self.config.get('ranking', {})

#                 # Frequency weight
#                 if ranking_config.get('frequency_weight', 0) 0):
key = f"{completion.source}:{completion.label}"
frequency = self.usage_stats.get(key, 0)
score + = frequency * ranking_config.get('frequency_weight', 0)

#                 # Context weight
#                 if ranking_config.get('context_weight', 0) 0):
context_score = self._calculate_context_score(completion, context)
score + = context_score * ranking_config.get('context_weight', 0)

#                 # Recency weight
#                 if ranking_config.get('recency_weight', 0) 0):
recency_score = self._calculate_recency_score(completion)
score + = recency_score * ranking_config.get('recency_weight', 0)

#                 # AI confidence weight
#                 if ranking_config.get('ai_confidence_weight', 0) 0 and completion.source == 'ai'):
confidence = completion.data.get('confidence', 0.5)
score + = confidence * ranking_config.get('ai_confidence_weight', 0)

completion.priority = score

            # Sort by priority (descending)
completions.sort(key = lambda x: x.priority, reverse=True)

#             return completions

#         except Exception as e:
self.logger.error(f"Error ranking completions: {str(e)}", exc_info = True)
#             return completions

#     async def _filter_completions(self, completions: List[CompletionItem], context: CompletionContext) -List[CompletionItem]):
#         """Filter completion items."""
#         try:
filtering_config = self.config.get('filtering', {})

#             # Apply prefix filter
#             if context.prefix:
min_prefix_length = filtering_config.get('min_prefix_length', 1)
#                 if len(context.prefix) >= min_prefix_length:
filtered = []

#                     for completion in completions:
#                         if self._matches_filter(completion.filter_text, context.prefix, filtering_config):
                            filtered.append(completion)

completions = filtered

#             # Limit results
max_results = filtering_config.get('max_results', 20)
#             if len(completions) max_results):
completions = completions[:max_results]

#             return completions

#         except Exception as e:
self.logger.error(f"Error filtering completions: {str(e)}", exc_info = True)
#             return completions

#     def _matches_filter(self, text: str, prefix: str, config: Dict[str, Any]) -bool):
#         """Check if text matches filter."""
#         if config.get('fuzzy_matching', True):
#             # Simple fuzzy matching
            return self._fuzzy_match(text, prefix)
#         else:
#             # Exact matching
case_sensitive = config.get('case_sensitive', False)
#             if case_sensitive:
                return text.startswith(prefix)
#             else:
                return text.lower().startswith(prefix.lower())

#     def _fuzzy_match(self, text: str, pattern: str) -bool):
#         """Simple fuzzy matching."""
pattern_chars = list(pattern.lower())
text_chars = list(text.lower())

pattern_idx = 0
#         for char in text_chars:
#             if pattern_idx < len(pattern_chars) and char == pattern_chars[pattern_idx]:
pattern_idx + = 1

return pattern_idx == len(pattern_chars)

#     def _calculate_priority(self, key: str, context: CompletionContext) -float):
#         """Calculate priority for a completion item."""
#         # Base priority
priority = 1.0

#         # Usage frequency
usage = self.usage_stats.get(key, 0)
priority + = usage * 0.1

#         # Success rate
success_rate = self.success_stats.get(key, 0.5)
priority + = success_rate * 0.2

#         return priority

#     def _calculate_context_score(self, completion: CompletionItem, context: CompletionContext) -float):
#         """Calculate context score for a completion item."""
#         # Simple context scoring
score = 0.0

#         # Check if completion matches current context
#         if completion.source == 'keywords' and 'func' in context.prefix:
score + = 0.5

#         if completion.source == 'variables' and '=' in context.line_text:
score + = 0.5

#         if completion.source == 'modules' and 'import' in context.prefix:
score + = 0.5

#         return score

#     def _calculate_recency_score(self, completion: CompletionItem) -float):
#         """Calculate recency score for a completion item."""
#         # Simple recency scoring (could be enhanced with timestamps)
#         return 0.1

#     def _get_cache_key(self, context: CompletionContext) -str):
#         """Get cache key for context."""
#         # Create a hash of the context
context_str = f"{context.file_path}:{context.line}:{context.character}:{context.prefix}"
        return hashlib.md5(context_str.encode()).hexdigest()

#     async def _get_from_cache(self, key: str) -Optional[List[Dict[str, Any]]]):
#         """Get completions from cache."""
#         try:
#             if not self.config.get('cache_enabled', True):
#                 return None

#             if key in self.completion_cache:
#                 # Check TTL
#                 if key in self.cache_timestamps:
timestamp = datetime.fromisoformat(self.cache_timestamps[key])
ttl = self.config.get('cache_ttl', 3600)

#                     if (datetime.now() - timestamp).total_seconds() < ttl:
#                         return self.completion_cache[key]
#                     else:
#                         # Expired, remove from cache
#                         del self.completion_cache[key]
#                         del self.cache_timestamps[key]

#             return None

#         except Exception as e:
self.logger.error(f"Error getting from completion cache: {str(e)}", exc_info = True)
#             return None

#     async def _save_to_cache(self, key: str, data: List[Dict[str, Any]]) -None):
#         """Save completions to cache."""
#         try:
#             if not self.config.get('cache_enabled', True):
#                 return

#             # Check cache size
max_size = self.config.get('cache_size', 1000)
#             if len(self.completion_cache) >= max_size:
#                 # Remove oldest entry
oldest_key = min(self.cache_timestamps.keys(),
key = lambda k: datetime.fromisoformat(self.cache_timestamps[k]))
#                 del self.completion_cache[oldest_key]
#                 del self.cache_timestamps[oldest_key]

#             # Save to cache
self.completion_cache[key] = data
self.cache_timestamps[key] = datetime.now().isoformat()

#         except Exception as e:
self.logger.error(f"Error saving to completion cache: {str(e)}", exc_info = True)

#     async def _load_config(self) -Dict[str, Any]):
#         """Load completion configuration."""
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
self.logger.error(f"Error loading completion config: {str(e)}", exc_info = True)
            return self.default_config.copy()

#     async def _save_config(self, config: Dict[str, Any]) -None):
#         """Save completion configuration."""
#         try:
#             with open(self.config_file, 'w', encoding='utf-8') as f:
json.dump(config, f, indent = 2)
#         except IOError as e:
self.logger.error(f"Error saving completion config: {str(e)}", exc_info = True)

#     def _merge_configs(self, default: Dict[str, Any], custom: Dict[str, Any]) -Dict[str, Any]):
#         """Merge custom config with default config."""
result = default.copy()

#         for key, value in custom.items():
#             if key in result and isinstance(result[key], dict) and isinstance(value, dict):
result[key] = self._merge_configs(result[key], value)
#             else:
result[key] = value

#         return result

#     async def _initialize_completion_items(self) -None):
#         """Initialize completion items database."""
#         try:
#             # Load snippets
#             if self.snippets_file.exists():
#                 with open(self.snippets_file, 'r', encoding='utf-8') as f:
self.snippets = json.load(f)

#             # Initialize default snippets if needed
#             if not self.snippets:
self.snippets = {
#                     'func': {
#                         'prefix': 'func',
                        'body': ['func ${1:name}(${2:params}) {', '\t${3:// body}', '}'],
#                         'description': 'Define a function'
#                     },
#                     'class': {
#                         'prefix': 'class',
#                         'body': ['class ${1:name} {', '\tconstructor(${2:params}) {', '\t\t${3:// init}', '\t}', '\t${4:// methods}', '}'],
#                         'description': 'Define a class'
#                     }
#                 }

                await self._save_snippets()

#         except Exception as e:
self.logger.error(f"Error initializing completion items: {str(e)}", exc_info = True)

#     async def _save_snippets(self) -None):
#         """Save snippets to file."""
#         try:
#             with open(self.snippets_file, 'w', encoding='utf-8') as f:
json.dump(self.snippets, f, indent = 2)
#         except IOError as e:
self.logger.error(f"Error saving snippets: {str(e)}", exc_info = True)

#     async def _load_learning_data(self) -None):
#         """Load learning data."""
#         try:
#             if self.learning_file.exists():
#                 with open(self.learning_file, 'r', encoding='utf-8') as f:
data = json.load(f)

self.usage_stats = defaultdict(int, data.get('usage_stats', {}))
self.context_stats = defaultdict(list, data.get('context_stats', {}))
self.success_stats = defaultdict(float, data.get('success_stats', {}))
self.user_preferences = data.get('user_preferences', {})

#         except Exception as e:
self.logger.error(f"Error loading learning data: {str(e)}", exc_info = True)

#     async def _save_learning_data(self) -None):
#         """Save learning data."""
#         try:
data = {
                'usage_stats': dict(self.usage_stats),
                'context_stats': dict(self.context_stats),
                'success_stats': dict(self.success_stats),
#                 'user_preferences': self.user_preferences,
                'last_updated': datetime.now().isoformat()
#             }

#             with open(self.learning_file, 'w', encoding='utf-8') as f:
json.dump(data, f, indent = 2, default=str)

#         except Exception as e:
self.logger.error(f"Error saving learning data: {str(e)}", exc_info = True)

#     async def _load_cache(self) -None):
#         """Load completion cache."""
#         try:
cache_file = self.cache_dir / "completion_cache.json"

#             if cache_file.exists():
#                 with open(cache_file, 'r') as f:
cache_data = json.load(f)

self.completion_cache = cache_data.get('data', {})
self.cache_timestamps = cache_data.get('timestamps', {})

#                 # Check TTL and remove expired entries
                await self._cleanup_cache()

#         except Exception as e:
self.logger.error(f"Error loading completion cache: {str(e)}", exc_info = True)
self.completion_cache = {}
self.cache_timestamps = {}

#     async def _save_cache(self) -None):
#         """Save completion cache."""
#         try:
cache_file = self.cache_dir / "completion_cache.json"

cache_data = {
#                 'data': self.completion_cache,
#                 'timestamps': self.cache_timestamps
#             }

#             with open(cache_file, 'w') as f:
json.dump(cache_data, f, indent = 2, default=str)

#         except Exception as e:
self.logger.error(f"Error saving completion cache: {str(e)}", exc_info = True)

#     async def _cleanup_cache(self) -None):
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
#                 if key in self.completion_cache:
#                     del self.completion_cache[key]
#                 del self.cache_timestamps[key]

#         except Exception as e:
self.logger.error(f"Error cleaning up completion cache: {str(e)}", exc_info = True)

#     def _update_performance_stats(self, completion_time: float, success: bool) -None):
#         """Update performance statistics."""
self.performance_stats['total_completions'] + = 1

#         if success:
self.performance_stats['successful_completions'] + = 1
self.performance_stats['total_completion_time'] + = completion_time
self.performance_stats['average_completion_time'] = (
#                 self.performance_stats['total_completion_time'] /
#                 self.performance_stats['successful_completions']
#             )
#         else:
self.performance_stats['failed_completions'] + = 1

#     async def get_engine_info(self) -Dict[str, Any]):
#         """
#         Get information about the Completion Engine.

#         Returns:
#             Dictionary containing engine information
#         """
#         try:
#             return {
#                 'name': self.name,
#                 'version': '1.0.0',
                'enabled': self.config.get('enabled', True),
#                 'features': {
                    'ai_powered': self.config.get('ai_powered', True),
                    'snippet_support': self.config.get('snippet_support', True),
                    'context_aware': self.config.get('context_aware', True),
                    'learning_enabled': self.config.get('learning_enabled', True),
                    'personalization_enabled': self.config.get('personalization_enabled', True)
#                 },
                'max_suggestions': self.config.get('max_suggestions', 10),
#                 'performance_stats': self.performance_stats,
#                 'cache_stats': {
                    'enabled': self.config.get('cache_enabled', True),
                    'size': len(self.completion_cache),
                    'max_size': self.config.get('cache_size', 1000),
                    'ttl': self.config.get('cache_ttl', 3600)
#                 },
#                 'learning_stats': {
                    'usage_entries': len(self.usage_stats),
                    'success_entries': len(self.success_stats),
                    'user_preferences': len(self.user_preferences)
#                 },
                'request_id': str(uuid.uuid4())
#             }

#         except Exception as e:
error_code = COMPLETION_ENGINE_ERROR_CODES["COMPLETION_CONFIG_ERROR"]
self.logger.error(f"Error getting engine info: {str(e)}", exc_info = True)

#             return {
#                 'success': False,
                'error': f"Error getting engine info: {str(e)}",
#                 'error_code': error_code,
                'request_id': str(uuid.uuid4())
#             }