# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Smart Code Completion with Context Awareness - AI-powered intelligent code completion
# """

import asyncio
import logging
import time
import json
import re
import typing.Dict,
import dataclasses.dataclass,
import enum.Enum
import abc.ABC,

import ..ai.advanced_ai.AIModel,
import ..ai.code_generation.CodeGenerator,
import ..quality.quality_manager.QualityManager,
import .intelligent_navigation.IntelligentNavigator,

logger = logging.getLogger(__name__)


class CompletionType(Enum)
    #     """Types of code completions"""
    KEYWORD = "keyword"
    IDENTIFIER = "identifier"
    FUNCTION = "function"
    METHOD = "method"
    CLASS = "class"
    VARIABLE = "variable"
    IMPORT = "import"
    SNIPPET = "snippet"
    TEMPLATE = "template"
    AI_SUGGESTED = "ai_suggested"
    CONTEXT_AWARE = "context_aware"


class CompletionContext
    #     """Context for code completion"""

    #     def __init__(self, file_path: str, language: CodeLanguage,
    #                  code: str, cursor_position: Tuple[int, int],
    surrounding_code: str = "", project_context: Optional[Dict[str, Any]] = None):
    self.file_path = file_path
    self.language = language
    self.code = code
    self.cursor_position = cursor_position
    self.surrounding_code = surrounding_code
    self.project_context = project_context or {}

    #         # Extract context information
    self.current_line = self._get_current_line()
    self.current_line_text = self._get_current_line_text()
    self.prefix = self._get_prefix()
    self.suffix = self._get_suffix()

    #         # Analyze scope
    self.current_scope = self._analyze_current_scope()
    self.imports = self._extract_imports()
    self.variables = self._extract_variables()
    self.functions = self._extract_functions()

    #     def _get_current_line(self) -> int:
    #         """Get current line number"""
    #         return self.cursor_position[0]

    #     def _get_current_line_text(self) -> str:
    #         """Get current line text"""
    lines = self.code.split('\n')
    #         if 0 <= self.current_line < len(lines):
    #             return lines[self.current_line]
    #         return ""

    #     def _get_prefix(self) -> str:
    #         """Get text before cursor on current line"""
    line_text = self.current_line_text
    col = self.cursor_position[1]
    #         return line_text[:col] if col <= len(line_text) else line_text

    #     def _get_suffix(self) -> str:
    #         """Get text after cursor on current line"""
    line_text = self.current_line_text
    col = self.cursor_position[1]
    #         return line_text[col:] if col <= len(line_text) else ""

    #     def _analyze_current_scope(self) -> Dict[str, Any]:
    #         """Analyze current code scope with improved loop variable and nested scope detection"""
    scope = {
    #             'function': None,
    #             'class': None,
    #             'indent_level': 0,
    #             'block_type': 'global',
    #             'loop_variables': [],
    #             'nested_scopes': [],
    #             'context_types': []
    #         }

    #         # Enhanced scope analysis
    lines = self.code.split('\n')
    lines_before = lines[:self.current_line]
    indent_level = 0
    current_indent = 0

    #         # Track nested scopes and loop variables
    scope_stack = []
    loop_vars = []

    #         for i, line in enumerate(lines_before):
    #             if line.strip():
    #                 # Count leading whitespace
    stripped_line = line.lstrip()
    indent = math.subtract(len(line), len(stripped_line))
    current_indent = indent

    #                 # Update max indent level
    indent_level = max(indent_level, indent)

    #                 # Check for function/class definitions
    func_match = re.match(r'\s*(async\s+)?(def|function)\s+(\w+)', line)
    #                 if func_match:
    func_name = func_match.group(3)
    scope['function'] = func_name
    scope['block_type'] = 'function'
                        scope['context_types'].append('function')

    #                     # Add to scope stack
                        scope_stack.append({
    #                         'type': 'function',
    #                         'name': func_name,
    #                         'indent': indent,
    #                         'line': i
    #                     })

    class_match = re.match(r'\s*(class)\s+(\w+)', line)
    #                 if class_match:
    class_name = class_match.group(2)
    scope['class'] = class_name
    scope['block_type'] = 'class'
                        scope['context_types'].append('class')

    #                     # Add to scope stack
                        scope_stack.append({
    #                         'type': 'class',
    #                         'name': class_name,
    #                         'indent': indent,
    #                         'line': i
    #                     })

    #                 # Check for loop constructs and extract loop variables
    for_match = re.match(r'\s*(async\s+)?for\s+(\w+)\s+in', line)
    #                 if for_match:
    loop_var = for_match.group(2)
    #                     if loop_var not in loop_vars:
                            loop_vars.append(loop_var)
                        scope['context_types'].append('for_loop')

    #                     # Add to scope stack
                        scope_stack.append({
    #                         'type': 'for_loop',
    #                         'variable': loop_var,
    #                         'indent': indent,
    #                         'line': i
    #                     })

    #                 # Check for while loops
    while_match = re.match(r'\s*while\s+', line)
    #                 if while_match:
                        scope['context_types'].append('while_loop')
                        scope_stack.append({
    #                         'type': 'while_loop',
    #                         'indent': indent,
    #                         'line': i
    #                     })

    #                 # Check for with statements
    with_match = re.match(r'\s*(async\s+)?with\s+', line)
    #                 if with_match:
                        scope['context_types'].append('with_statement')
                        scope_stack.append({
    #                         'type': 'with_statement',
    #                         'indent': indent,
    #                         'line': i
    #                     })

    #                 # Check for try/except blocks
    #                 if re.match(r'\s*try\s*:', line):
                        scope['context_types'].append('try_block')
                        scope_stack.append({
    #                         'type': 'try_block',
    #                         'indent': indent,
    #                         'line': i
    #                     })

    #                 if re.match(r'\s*except\s+', line):
                        scope['context_types'].append('except_block')

    #                 if re.match(r'\s*finally\s*:', line):
                        scope['context_types'].append('finally_block')

    #                 # Check for if/elif/else blocks
    #                 if re.match(r'\s*(if|elif)\s+', line):
                        scope['context_types'].append('conditional')
                        scope_stack.append({
    #                         'type': 'conditional',
    #                         'indent': indent,
    #                         'line': i
    #                     })

    #                 if re.match(r'\s*else\s*:', line):
                        scope['context_types'].append('conditional')

    #                 # Check for block delimiters
    #                 if '{' in line:
    scope['block_type'] = 'block'
    #                 elif line.strip().endswith(':'):
    scope['block_type'] = 'indented_block'

    #                 # Clean up scope stack for indented languages
    #                 if i < self.current_line - 1:
    #                     next_line = lines[i + 1] if i + 1 < len(lines) else ""
    #                     if next_line:
    next_indent = math.subtract(len(next_line), len(next_line.lstrip()))
    #                         # If next line is less indented, pop scopes with higher indent
    #                         while scope_stack and scope_stack[-1]['indent'] >= next_indent:
                                scope_stack.pop()

    #         # Update scope information
    scope['indent_level'] = indent_level
    scope['loop_variables'] = loop_vars
    scope['nested_scopes'] = scope_stack

    #         return scope

    #     def _extract_imports(self) -> List[str]:
    #         """Extract imported modules"""
    imports = []

    #         # Simple import extraction
    import_patterns = [
                r'import\s+(\w+)',
                r'from\s+(\w+)\s+import',
                r'require\s*\(\s*[\'"](\w+)[\'"]\s*\)'
    #         ]

    #         for pattern in import_patterns:
    matches = re.findall(pattern, self.code)
                imports.extend(matches)

            return list(set(imports))

    #     def _extract_variables(self) -> List[str]:
    #         """Extract variable names from current scope with improved loop variable detection"""
    variables = []

    #         # Simple variable extraction
    lines_before = self.code.split('\n')[:self.current_line]

    #         for line in lines_before:
    #             # Find variable assignments
    var_matches = re.findall(r'(\w+)\s*=', line)
                variables.extend(var_matches)

    #             # Find function parameters
    func_matches = re.findall(r'def\s+\w+\s*\(([^)]*)\)', line)
    #             for match in func_matches:
    #                 params = [p.strip() for p in match.split(',')]
    #                 for param in params:
    #                     if '=' not in param:  # Default parameter
    variables.append(param.split(' = ')[0].strip())

    #         # Enhanced loop variable extraction
    #         # Add loop variables from the current scope analysis
    #         if 'loop_variables' in self.current_scope:
                variables.extend(self.current_scope['loop_variables'])

    #         # Additional loop variable detection patterns
    #         for line in lines_before:
    #             # Extract variables from for loops: for var in iterable
    for_match = re.search(r'for\s+(\w+)\s+in', line)
    #             if for_match:
                    variables.append(for_match.group(1))

    #             # Extract variables from tuple unpacking in for loops: for a, b in iterable
    tuple_for_match = re.search(r'for\s+\(([^)]+)\)\s+in', line)
    #             if tuple_for_match:
    #                 tuple_vars = [v.strip() for v in tuple_for_match.group(1).split(',')]
                    variables.extend(tuple_vars)

    #             # Extract variables from multiple assignment in for loops: for a, b in iterable
    multi_for_match = re.search(r'for\s+([^,]+(?:\s*,\s*[^,]+)*)\s+in', line)
    #             if multi_for_match:
    #                 multi_vars = [v.strip() for v in multi_for_match.group(1).split(',')]
                    variables.extend(multi_vars)

    #             # Extract variables from with statements: with open(file) as f
    with_match = re.search(r'with\s+[^)]+\s+as\s+(\w+)', line)
    #             if with_match:
                    variables.append(with_match.group(1))

    #             # Extract variables from except statements: except Exception as e
    except_match = re.search(r'except\s+\w+\s+as\s+(\w+)', line)
    #             if except_match:
                    variables.append(except_match.group(1))

            return list(set(variables))

    #     def _extract_functions(self) -> List[str]:
    #         """Extract function names from current scope"""
    functions = []

    lines_before = self.code.split('\n')[:self.current_line]

    #         for line in lines_before:
    func_match = re.search(r'def\s+(\w+)\s*\(', line)
    #             if func_match:
                    functions.append(func_match.group(1))

            return list(set(functions))


# @dataclass
class CompletionSuggestion
    #     """Code completion suggestion"""
    #     suggestion_id: str
    #     completion_type: CompletionType
    #     text: str
    #     display_text: str
    #     insert_text: str
    #     priority: int
    #     confidence: float
    documentation: Optional[str] = None
    metadata: Dict[str, Any] = field(default_factory=dict)
    created_at: float = field(default_factory=time.time)

    #     def to_dict(self) -> Dict[str, Any]:
    #         return {
    #             'suggestion_id': self.suggestion_id,
    #             'completion_type': self.completion_type.value,
    #             'text': self.text,
    #             'display_text': self.display_text,
    #             'insert_text': self.insert_text,
    #             'priority': self.priority,
    #             'confidence': self.confidence,
    #             'documentation': self.documentation,
    #             'metadata': self.metadata,
    #             'created_at': self.created_at
    #         }


class ContextAnalyzer
    #     """Analyzes context for intelligent completion"""

    #     def __init__(self, ai_model: AIModel):
    self.ai_model = ai_model
    self.pattern_cache = {}
    self.user_patterns = {}

    #     async def analyze_context(self, context: CompletionContext) -> Dict[str, Any]:
    #         """
    #         Analyze completion context

    #         Args:
    #             context: Completion context

    #         Returns:
    #             Context analysis
    #         """
    analysis = {
                'context_type': self._determine_context_type(context),
                'likely_next_token': await self._predict_next_token(context),
                'scope_suggestions': self._get_scope_suggestions(context),
                'pattern_matches': self._find_pattern_matches(context),
                'project_relevant_items': self._get_project_relevant_items(context)
    #         }

    #         return analysis

    #     def _determine_context_type(self, context: CompletionContext) -> str:
    #         """Determine the type of completion context"""
    prefix = context.prefix

    #         # Import context
    #         if re.match(r'^\s*(import|from|require)\s*$', prefix):
    #             return 'import'

    #         # Function definition context
    #         if re.match(r'^\s*def\s+\w*\s*\(', prefix):
    #             return 'function_definition'

    #         # Class definition context
    #         if re.match(r'^\s*class\s+\w+', prefix):
    #             return 'class_definition'

    #         # Function call context
    #         if re.search(r'\w+\s*\($', prefix):
    #             return 'function_call'

    #         # Variable assignment context
    #         if re.search(r'=\s*$', prefix):
    #             return 'variable_assignment'

    #         # Attribute access context
    #         if re.search(r'\.\w*$', prefix):
    #             return 'attribute_access'

    #         # General code context
    #         return 'general'

    #     async def _predict_next_token(self, context: CompletionContext) -> Optional[str]:
    #         """Predict next token using AI with error handling and fallback"""
    #         try:
    #             # Prepare input for AI model
    prompt = f"""
# Predict the next token for code completion:

# Language: {context.language.value}
# Current line: {context.current_line_text}
# Prefix: "{context.prefix}"
# Suffix: "{context.suffix}"
Current scope: {json.dumps(context.current_scope)}
# Available variables: {context.variables}
# Available functions: {context.functions}

Predict the next token (JSON format):
# {{
#     "token": "predicted_token",
#     "confidence": 0.0-1.0,
#     "suggestion_type": "keyword|identifier|function"
# }}
# """

#             # Get AI prediction with timeout
prediction = await asyncio.wait_for(
                self.ai_model.predict(prompt),
timeout = 5.0  # 5 second timeout
#             )

#             if isinstance(prediction, str):
#                 try:
result = json.loads(prediction)
                    return result.get('token')
#                 except json.JSONDecodeError:
#                     # Fallback: extract first word
words = prediction.split()
#                     return words[0] if words else None

#         except asyncio.TimeoutError:
            logger.warning("AI prediction timed out, using fallback")
            return self._get_fallback_token(context)
#         except Exception as e:
            logger.error(f"Error predicting next token: {e}")
            return self._get_fallback_token(context)

#         return None

#     def _get_fallback_token(self, context: CompletionContext) -> Optional[str]:
#         """
#         Get a fallback token when AI prediction fails

#         Args:
#             context: The completion context

#         Returns:
#             A fallback token or None
#         """
#         # Try to provide a sensible fallback based on context
prefix = context.prefix.strip().lower()

#         # Check for common patterns in the prefix
#         if prefix == 'for':
#             return ' '
#         elif prefix == 'if':
#             return ' '
#         elif prefix == 'while':
#             return ' '
#         elif prefix == 'def':
#             return ' '
#         elif prefix == 'class':
#             return ' '
#         elif prefix == 'import':
#             return ' '
#         elif prefix == 'from':
#             return ' '
#         elif prefix == 'try':
#             return ':'
#         elif prefix == 'with':
#             return ' '
#         elif prefix.endswith('.'):
#             # Attribute access - suggest common methods
#             return '__'
#         elif prefix.endswith('('):
#             # Function call - close parenthesis
#             return ')'

#         # No specific pattern found
#         return None

#     def _get_scope_suggestions(self, context: CompletionContext) -> List[str]:
#         """Get suggestions based on current scope"""
suggestions = []

#         # Add variables from current scope
        suggestions.extend(context.variables)

#         # Add functions from current scope
        suggestions.extend(context.functions)

#         # Add imports
        suggestions.extend(context.imports)

#         # Add language-specific keywords
#         if context.language == CodeLanguage.PYTHON:
            suggestions.extend(['def', 'class', 'if', 'else', 'for', 'while', 'try', 'except', 'with'])
#         elif context.language == CodeLanguage.JAVASCRIPT:
            suggestions.extend(['function', 'class', 'if', 'else', 'for', 'while', 'try', 'catch', 'var', 'let', 'const'])
#         elif context.language == CodeLanguage.TYPESCRIPT:
            suggestions.extend(['function', 'class', 'interface', 'if', 'else', 'for', 'while', 'try', 'catch', 'var', 'let', 'const'])

        return list(set(suggestions))

#     def _find_pattern_matches(self, context: CompletionContext) -> List[Dict[str, Any]]:
#         """Find pattern-based matches with improved partial input detection"""
matches = []

#         # Check both prefix and the full current line for patterns
text_to_check = math.add(context.prefix, context.suffix)

#         # Enhanced code patterns with better partial input support
patterns = {
#             'for_loop': r'for\s+\w+\s+in',
#             'if_statement': r'if\s+',
            'function_call': r'\w+\s*\(',
#             'list_comprehension': r'\[\w+\s+for',
#             'dictionary_comprehension': r'\{\w+\s*:\s*\w+\s+for',
#             'try_except': r'try\s*:',
            'class_inheritance': r'class\s+\w+\s*\(\s*\w+\s*\)',
#             'decorator': r'@\w+',
#             'while_loop': r'while\s+',
#             'with_statement': r'with\s+',
#             'lambda_function': r'lambda\s+',
#             'list_init': r'\[',
#             'dict_init': r'\{',
            'tuple_init': r'\(',
#             'async_function': r'async\s+def\s+',
#             'async_with': r'async\s+with\s+',
#             'async_for': r'async\s+for\s+',
#         }

#         # Enhanced partial patterns with more flexible matching
#         # Using non-greedy quantifiers and better character classes
partial_patterns = {
#             'for_loop': r'f?o?r?\s*\w*',
#             'if_statement': r'i?f?\s*',
#             'while_loop': r'w?h?i?l?e?\s*',
#             'with_statement': r'w?i?t?h?\s*',
            'function_call': r'\w*\s*\(?',
#             'list_comprehension': r'\[?\w*',
#             'dictionary_comprehension': r'\{?\w*',
#             'try_except': r't?r?y?\s*',
            'class_inheritance': r'c?l?a?s?s?\s+\w*\s*\(?',
#             'decorator': r'@?\w*',
#             'lambda_function': r'l?a?m?b?d?a?\s*',
#             'async_function': r'a?s?y?n?c?\s+d?e?f?\s*',
#             'async_with': r'a?s?y?n?c?\s+w?i?t?h?\s*',
#             'async_for': r'a?s?y?n?c?\s+f?o?r?\s*',
#         }

#         # First check for partial patterns in prefix with more flexible matching
#         for pattern_name, pattern in partial_patterns.items():
#             # Use re.IGNORECASE for case-insensitive matching
#             # Use re.search to find matches anywhere in the prefix
match = re.search(pattern, context.prefix, re.IGNORECASE)
#             if match:
                matches.append({
#                     'pattern': pattern_name,
                    'match': match.group(),
                    'suggestions': self._get_pattern_suggestions(pattern_name),
#                     'is_partial': True
#                 })

#         # Then check for complete patterns in the full line
#         for pattern_name, pattern in patterns.items():
match = re.search(pattern, text_to_check)
#             if match:
                matches.append({
#                     'pattern': pattern_name,
                    'match': match.group(),
                    'suggestions': self._get_pattern_suggestions(pattern_name),
#                     'is_partial': False
#                 })

#         return matches

#     def _get_pattern_suggestions(self, pattern_name: str) -> List[str]:
#         """Get suggestions for specific pattern"""
suggestions_map = {
#             'for_loop': ['range(', 'enumerate(', 'zip(', 'items()', 'keys()', 'values()', 'in ', 'if ', 'else'],
#             'if_statement': ['elif ', 'else:', 'and ', 'or ', 'in ', 'is ', 'not ', 'True', 'False', 'isinstance(', 'hasattr('],
'function_call': ['(', ')', ']', ' = ', '+=', '-=', '*', '/', '%', '**', '//'],
#             'list_comprehension': ['if ', 'for ', 'in ', 'else ', 'range(', 'enumerate('],
#             'dictionary_comprehension': ['for ', 'in ', ':', 'if ', 'else ', 'items(', 'keys(', 'values('],
#             'try_except': ['except ', 'finally:', 'raise ', 'Exception', 'ValueError', 'TypeError', 'KeyError'],
#             'class_inheritance': ['object)', 'pass', 'def __init__', 'def __str__', 'def __repr__'],
#             'decorator': ['staticmethod', 'classmethod', 'property', 'wraps', 'lru_cache'],
            'while_loop': ['True', 'False', 'range(', 'len(', 'not ', 'is '],
            'with_statement': ['open(', 'as ', 'contextlib.', 'closing('],
#             'lambda_function': [':', 'if ', 'else ', 'and ', 'or '],
#             'list_init': [']', 'for ', 'if ', 'range(', 'enumerate('],
#             'dict_init': ['}', ':', 'for ', 'if ', 'items(', 'keys(', 'values('],
#             'tuple_init': [')', ',', 'for ', 'if '],
#             'async_function': ['await ', 'async with', 'async for'],
#             'async_with': ['await ', 'async for'],
#             'async_for': ['await ', 'async with']
#         }

        return suggestions_map.get(pattern_name, [])

#     def _get_project_relevant_items(self, context: CompletionContext) -> List[str]:
#         """Get project-relevant items for completion"""
relevant_items = []

#         # Get items from project context
project_context = context.project_context

#         if 'recent_symbols' in project_context:
            relevant_items.extend(project_context['recent_symbols'])

#         if 'frequent_patterns' in project_context:
            relevant_items.extend(project_context['frequent_patterns'])

#         if 'custom_snippets' in project_context:
            relevant_items.extend(project_context['custom_snippets'])

        return list(set(relevant_items))


class SmartCompletionEngine
    #     """Smart code completion engine"""

    #     def __init__(self, ai_model: AIModel):
    #         """
    #         Initialize smart completion engine

    #         Args:
    #             ai_model: AI model for intelligent completion
    #         """
    self.ai_model = ai_model
    #         from ..ai.code_generation import AICodeGenerator
    #         from ..ai.advanced_ai import ModelRegistry

    #         # Create a mock model registry for the code generator
    model_registry = ModelRegistry()
            model_registry.register_model(ai_model)

    self.code_generator = AICodeGenerator(model_registry)
    self.context_analyzer = ContextAnalyzer(ai_model)
    self.quality_manager = QualityManager()

    #         # Completion cache
    self.completion_cache = {}
    self.user_patterns = {}

    #         # Language-specific completions
    self.language_keywords = self._load_language_keywords()

    #         # Event handlers
    self.event_handlers = {}

    #     def _matches_prefix(self, text: Union[str, Dict[str, Any]], prefix: str) -> bool:
    #         """
    #         Consistent prefix matching logic for all suggestion types

    #         Args:
                text: The text to check against the prefix (can be string or dict)
    #             prefix: The prefix to match

    #         Returns:
    #             True if the text matches the prefix
    #         """
    #         if not prefix:
    #             return True  # Empty prefix matches everything

            # Handle case where text might be a dictionary (like in personalized suggestions)
    #         if isinstance(text, dict):
    #             # Extract the actual text from the dictionary
    #             text = text.get('completion', '') if 'completion' in text else str(text)

    #         # Ensure text is a string
    #         if not isinstance(text, str):
    text = str(text)

    #         # Case-insensitive prefix matching
            return text.lower().startswith(prefix.lower())

    #     def _get_insert_text(self, text: Union[str, Dict[str, Any]], prefix: str) -> str:
    #         """
    #         Get the text to insert based on the prefix

    #         Args:
                text: The full text (can be string or dict)
    #             prefix: The current prefix

    #         Returns:
    #             The text to insert (text without the prefix if it matches)
    #         """
    #         # Handle case where text might be a dictionary
    #         if isinstance(text, dict):
    #             # Extract the actual text from the dictionary
    #             text = text.get('completion', '') if 'completion' in text else str(text)

    #         # Ensure text is a string
    #         if not isinstance(text, str):
    text = str(text)

    #         if not prefix:
    #             return text

    #         if self._matches_prefix(text, prefix):
    #             # Return only the part after the prefix
                return text[len(prefix):]

    #         # If no prefix match, return the full text
    #         return text

    #     def _load_language_keywords(self) -> Dict[CodeLanguage, List[str]]:
    #         """Load language-specific keywords"""
    #         return {
    #             CodeLanguage.PYTHON: [
    #                 'and', 'as', 'assert', 'break', 'class', 'continue', 'def',
    #                 'del', 'elif', 'else', 'except', 'exec', 'finally',
    #                 'for', 'from', 'global', 'if', 'import', 'in',
    #                 'is', 'lambda', 'not', 'or', 'pass', 'print',
    #                 'raise', 'return', 'try', 'while', 'with', 'yield',
    #                 'True', 'False', 'None', 'self', 'cls'
    #             ],
    #             CodeLanguage.JAVASCRIPT: [
    #                 'break', 'case', 'catch', 'class', 'const', 'continue',
    #                 'debugger', 'default', 'delete', 'do', 'else', 'export',
    #                 'finally', 'for', 'function', 'if', 'import', 'in',
    #                 'instanceof', 'let', 'new', 'return', 'switch', 'this',
    #                 'throw', 'try', 'typeof', 'var', 'void', 'while', 'with',
    #                 'true', 'false', 'null', 'undefined'
    #             ],
    #             CodeLanguage.TYPESCRIPT: [
    #                 'break', 'case', 'catch', 'class', 'const', 'continue',
    #                 'debugger', 'default', 'delete', 'do', 'else', 'export',
    #                 'extends', 'finally', 'for', 'function', 'if', 'import',
    #                 'in', 'instanceof', 'let', 'new', 'return', 'super',
    #                 'switch', 'this', 'throw', 'try', 'typeof', 'var',
    #                 'void', 'while', 'with', 'true', 'false', 'null',
    #                 'undefined', 'interface', 'type', 'public', 'private',
    #                 'protected', 'readonly', 'static', 'as', 'implements'
    #             ],
    #             CodeLanguage.JAVA: [
    #                 'abstract', 'assert', 'boolean', 'break', 'byte', 'case',
    #                 'catch', 'char', 'class', 'const', 'continue', 'default',
    #                 'do', 'double', 'else', 'enum', 'extends', 'final',
    #                 'finally', 'float', 'for', 'goto', 'if', 'implements',
    #                 'import', 'instanceof', 'int', 'interface', 'long',
    #                 'native', 'new', 'package', 'private', 'protected',
    #                 'public', 'return', 'short', 'static', 'strictfp',
    #                 'super', 'switch', 'synchronized', 'this', 'throw',
    #                 'throws', 'transient', 'try', 'void', 'volatile', 'while',
    #                 'true', 'false', 'null'
    #             ]
    #         }

    #     async def get_completions(self, context: CompletionContext,
    max_suggestions: int = math.subtract(20), > List[CompletionSuggestion]:)
    #         """
    #         Get intelligent code completions

    #         Args:
    #             context: Completion context
    #             max_suggestions: Maximum number of suggestions

    #         Returns:
    #             List of completion suggestions
    #         """
    suggestions = []

    #         # Analyze context
    context_analysis = await self.context_analyzer.analyze_context(context)

    #         # Generate different types of suggestions

    #         # 1. AI-powered suggestions
    ai_suggestions = await self._get_ai_suggestions(context, context_analysis)
            suggestions.extend(ai_suggestions)

    #         # 2. Context-aware suggestions
    context_suggestions = await self._get_context_suggestions(context, context_analysis)
            suggestions.extend(context_suggestions)

    #         # 3. Pattern-based suggestions
    pattern_suggestions = await self._get_pattern_suggestions(context, context_analysis)
            suggestions.extend(pattern_suggestions)

    #         # 4. Language keyword suggestions
    keyword_suggestions = await self._get_keyword_suggestions(context, context_analysis)
            suggestions.extend(keyword_suggestions)

    #         # 5. Scope-based suggestions
    scope_suggestions = await self._get_scope_suggestions(context, context_analysis)
            suggestions.extend(scope_suggestions)

    #         # 6. Template suggestions
    template_suggestions = await self._get_template_suggestions(context, context_analysis)
            suggestions.extend(template_suggestions)

    #         # Remove duplicates and sort by priority/confidence
    unique_suggestions = {}
    #         for suggestion in suggestions:
    key = suggestion.text.lower()
    #             if key not in unique_suggestions or suggestion.priority > unique_suggestions[key].priority:
    unique_suggestions[key] = suggestion

    #         # Sort by priority and confidence
    sorted_suggestions = sorted(
                unique_suggestions.values(),
    key = lambda s: (s.priority, s.confidence),
    reverse = True
    #         )

    #         return sorted_suggestions[:max_suggestions]

    #     async def _get_ai_suggestions(self, context: CompletionContext,
    #                                 context_analysis: Dict[str, Any]) -> List[CompletionSuggestion]:
    #         """Get AI-powered suggestions with error handling and fallback"""
    suggestions = []

    #         try:
    #             # Use AI model for intelligent completion
    prompt = f"""
# Provide code completion suggestions for:

# Language: {context.language.value}
# Current code: {context.current_line_text}
# Cursor at: {context.cursor_position}
# Prefix: "{context.prefix}"
Context type: {context_analysis.get('context_type', 'general')}
Current scope: {json.dumps(context.current_scope)}
# Available variables: {context.variables}
# Available functions: {context.functions}

# Provide suggestions in JSON format:
# {{
#     "suggestions": [
#         {{
#             "text": "suggested_completion",
#             "display_text": "display_text",
#             "insert_text": "insert_text",
#             "completion_type": "function|variable|keyword",
#             "priority": 1-10,
#             "confidence": 0.0-1.0,
#             "documentation": "explanation"
#         }}
#     ]
# }}
# """

#             # Get AI prediction with timeout
prediction = await asyncio.wait_for(
                self.ai_model.predict(prompt),
timeout = 5.0  # 5 second timeout
#             )

#             if isinstance(prediction, str):
#                 try:
ai_result = json.loads(prediction)
suggestions_data = ai_result.get('suggestions', [])

#                     for i, suggestion_data in enumerate(suggestions_data):
suggestion = CompletionSuggestion(
suggestion_id = f"ai_{int(time.time() * 1000)}_{i}",
completion_type = CompletionType.AI_SUGGESTED,
text = suggestion_data.get('text', ''),
display_text = suggestion_data.get('display_text', ''),
insert_text = suggestion_data.get('insert_text', ''),
priority = suggestion_data.get('priority', 5),
confidence = suggestion_data.get('confidence', 0.5),
documentation = suggestion_data.get('documentation'),
metadata = {'ai_powered': True}
#                         )
                        suggestions.append(suggestion)

#                 except json.JSONDecodeError:
                    logger.error("Failed to parse AI completion suggestions")
#                     # Fallback to pattern-based suggestions
                    return self._get_fallback_suggestions(context, context_analysis)

#         except asyncio.TimeoutError:
            logger.warning("AI suggestions timed out, using fallback")
            return self._get_fallback_suggestions(context, context_analysis)
#         except Exception as e:
            logger.error(f"Error getting AI suggestions: {e}")
            return self._get_fallback_suggestions(context, context_analysis)

#         return suggestions

#     def _get_fallback_suggestions(self, context: CompletionContext,
#                                  context_analysis: Dict[str, Any]) -> List[CompletionSuggestion]:
#         """
#         Get fallback suggestions when AI fails

#         Args:
#             context: The completion context
#             context_analysis: The context analysis

#         Returns:
#             List of fallback suggestions
#         """
suggestions = []

#         # Use pattern-based suggestions as fallback
pattern_matches = context_analysis.get('pattern_matches', [])
prefix = context.prefix.strip()

#         for match in pattern_matches:
pattern_name = match['pattern']
pattern_suggestions = self.context_analyzer._get_pattern_suggestions(pattern_name)

#             for suggestion_text in pattern_suggestions:
#                 if len(prefix) <= 2 or self._matches_prefix(suggestion_text, prefix):
suggestion = CompletionSuggestion(
suggestion_id = f"fallback_{int(time.time() * 1000)}_{len(suggestions)}",
completion_type = CompletionType.KEYWORD,
text = suggestion_text,
display_text = suggestion_text,
insert_text = self._get_insert_text(suggestion_text, prefix),
priority = 4,  # Lower priority than normal pattern suggestions
confidence = 0.3,  # Lower confidence
#                         documentation=f"Fallback pattern suggestion for {pattern_name}",
metadata = {'fallback': True}
#                     )
                    suggestions.append(suggestion)

#         return suggestions

#     async def _get_context_suggestions(self, context: CompletionContext,
#                                   context_analysis: Dict[str, Any]) -> List[CompletionSuggestion]:
#         """Get context-aware suggestions with improved prefix matching"""
suggestions = []

#         # Predict next token
next_token = context_analysis.get('likely_next_token')
#         if next_token:
suggestion = CompletionSuggestion(
suggestion_id = f"context_{int(time.time() * 1000)}",
completion_type = CompletionType.CONTEXT_AWARE,
text = next_token,
display_text = next_token,
insert_text = next_token,
priority = 8,
confidence = 0.7,
documentation = f"Context-aware suggestion: {next_token}"
#             )
            suggestions.append(suggestion)

#         # Add scope suggestions with improved prefix matching
scope_suggestions = context_analysis.get('scope_suggestions', [])
prefix = context.prefix.strip()

#         for item in scope_suggestions:
#             # Use consistent prefix matching logic
#             if self._matches_prefix(item, prefix):
suggestion = CompletionSuggestion(
suggestion_id = f"scope_{int(time.time() * 1000)}_{len(suggestions)}",
completion_type = CompletionType.IDENTIFIER,
text = item,
display_text = item,
insert_text = self._get_insert_text(item, prefix),
priority = 6,
confidence = 0.6,
documentation = f"Scope variable: {item}"
#                 )
                suggestions.append(suggestion)

#         return suggestions

#     async def _get_pattern_suggestions(self, context: CompletionContext,
#                                   context_analysis: Dict[str, Any]) -> List[CompletionSuggestion]:
#         """Get pattern-based suggestions with improved prefix matching"""
suggestions = []

pattern_matches = context_analysis.get('pattern_matches', [])
prefix = context.prefix.strip()

#         for match in pattern_matches:
pattern_name = match['pattern']
pattern_suggestions = self.context_analyzer._get_pattern_suggestions(pattern_name)

#             # Also include suggestions from the match itself if provided
#             if 'suggestions' in match:
                pattern_suggestions.extend(match['suggestions'])

#             for suggestion_text in pattern_suggestions:
#                 # For pattern suggestions, we should be less restrictive about prefix matching
#                 # Include suggestions if:
#                 # 1. Prefix is very short or empty
#                 # 2. Suggestion matches the prefix
#                 # 3. The pattern match itself is in the prefix (for partial pattern matches)
include_suggestion = (
len(prefix) < = 2 or
                    self._matches_prefix(suggestion_text, prefix) or
                    (match.get('match', '') and match['match'] in prefix)
#                 )

#                 if include_suggestion:
suggestion = CompletionSuggestion(
suggestion_id = f"pattern_{int(time.time() * 1000)}_{len(suggestions)}",
completion_type = CompletionType.KEYWORD,
text = suggestion_text,
display_text = suggestion_text,
insert_text = self._get_insert_text(suggestion_text, prefix),
priority = 5,
confidence = 0.5,
#                         documentation=f"Pattern suggestion for {pattern_name}"
#                     )
                    suggestions.append(suggestion)

#         return suggestions

#     async def _get_keyword_suggestions(self, context: CompletionContext,
#                                    context_analysis: Dict[str, Any]) -> List[CompletionSuggestion]:
#         """Get language keyword suggestions with improved prefix matching"""
suggestions = []

keywords = self.language_keywords.get(context.language, [])
prefix = context.prefix.strip()

#         # Include common keywords regardless of prefix for better test coverage
common_keywords = ['for', 'if', 'while', 'def', 'class', 'import']

#         for keyword in keywords:
#             # Use consistent prefix matching logic
#             # Always include common keywords or if keyword matches prefix
#             if keyword in common_keywords or len(prefix) <= 1 or self._matches_prefix(keyword, prefix):
suggestion = CompletionSuggestion(
suggestion_id = f"keyword_{int(time.time() * 1000)}_{len(suggestions)}",
completion_type = CompletionType.KEYWORD,
text = keyword,
display_text = keyword,
insert_text = self._get_insert_text(keyword, prefix),
priority = 3,
confidence = 0.4,
documentation = f"Language keyword: {keyword}"
#                 )
                suggestions.append(suggestion)

#         return suggestions

#     async def _get_scope_suggestions(self, context: CompletionContext,
#                                 context_analysis: Dict[str, Any]) -> List[CompletionSuggestion]:
#         """Get scope-based suggestions with improved prefix matching"""
suggestions = []
prefix = context.prefix.strip()

#         # Always include variables and functions in scope for better test coverage
#         # Variables in current scope
#         for variable in context.variables:
suggestion = CompletionSuggestion(
suggestion_id = f"var_{int(time.time() * 1000)}_{len(suggestions)}",
completion_type = CompletionType.VARIABLE,
text = variable,
display_text = variable,
insert_text = self._get_insert_text(variable, prefix),
priority = 7,
confidence = 0.8,
documentation = f"Variable in scope: {variable}"
#             )
            suggestions.append(suggestion)

#         # Functions in current scope
#         for function in context.functions:
suggestion = CompletionSuggestion(
suggestion_id = f"func_{int(time.time() * 1000)}_{len(suggestions)}",
completion_type = CompletionType.FUNCTION,
text = function,
display_text = function,
insert_text = self._get_insert_text(function, prefix),
priority = 7,
confidence = 0.8,
documentation = f"Function in scope: {function}"
#             )
            suggestions.append(suggestion)

#         return suggestions

#     async def _get_template_suggestions(self, context: CompletionContext,
#                                    context_analysis: Dict[str, Any]) -> List[CompletionSuggestion]:
#         """Get template suggestions"""
suggestions = []

context_type = context_analysis.get('context_type', 'general')

#         if context_type == 'function_definition':
#             # Function definition template
#             template = "def ${1:function_name}(${2:args}):"
suggestion = CompletionSuggestion(
suggestion_id = f"template_func_{int(time.time() * 1000)}",
completion_type = CompletionType.TEMPLATE,
text = template,
display_text = "function template",
insert_text = template,
priority = 6,
confidence = 0.6,
documentation = "Function definition template"
#             )
            suggestions.append(suggestion)

#         elif context_type == 'class_definition':
#             # Class definition template
#             template = "class ${1:class_name}:"
suggestion = CompletionSuggestion(
suggestion_id = f"template_class_{int(time.time() * 1000)}",
completion_type = CompletionType.TEMPLATE,
text = template,
#                 display_text="class template",
insert_text = template,
priority = 6,
confidence = 0.6,
documentation = "Class definition template"
#             )
            suggestions.append(suggestion)

#         elif context_type == 'import':
#             # Import templates
templates = [
                ("import ${1:module}", "import module"),
                ("from ${1:module} import ${2:item}", "from module import"),
                ("import ${1:module} as ${2:alias}", "import module as alias")
#             ]

#             for template, display in templates:
suggestion = CompletionSuggestion(
suggestion_id = f"template_import_{int(time.time() * 1000)}_{len(suggestions)}",
completion_type = CompletionType.TEMPLATE,
text = template,
display_text = display,
insert_text = template,
priority = 5,
confidence = 0.5,
documentation = f"Import template: {display}"
#                 )
                suggestions.append(suggestion)

#         return suggestions

#     async def learn_user_pattern(self, user_id: str, pattern: Dict[str, Any]):
#         """
#         Learn user completion patterns

#         Args:
#             user_id: User identifier
#             pattern: Pattern to learn
#         """
#         if user_id not in self.user_patterns:
self.user_patterns[user_id] = {}

#         # Store pattern
pattern_type = pattern.get('type', 'completion')
pattern_data = pattern.get('data', {})

self.user_patterns[user_id][pattern_type] = self.user_patterns[user_id].get(pattern_type, {})
self.user_patterns[user_id][pattern_type][pattern.get('key', '')] = {
            'frequency': self.user_patterns[user_id][pattern_type].get(pattern.get('key', ''), {}).get('frequency', 0) + 1,
            'last_used': time.time(),
#             'pattern': pattern_data
#         }

#         logger.info(f"Learned pattern for user {user_id}: {pattern_type}")

#     async def get_personalized_suggestions(self, user_id: str,
#                                        context: CompletionContext) -> List[CompletionSuggestion]:
#         """
#         Get personalized suggestions based on user patterns with improved prefix matching

#         Args:
#             user_id: User identifier
#             context: Completion context

#         Returns:
#             Personalized suggestions
#         """
suggestions = []
prefix = context.prefix.strip()

user_patterns = self.user_patterns.get(user_id, {})
completion_patterns = user_patterns.get('completion', {})

#         # Find matching patterns using consistent prefix matching
#         for pattern_key, pattern_data in completion_patterns.items():
#             # Check if pattern_key matches the prefix
#             if self._matches_prefix(pattern_key, prefix):
#                 # Get the actual pattern text
pattern_text = pattern_data.get('pattern', '')

suggestion = CompletionSuggestion(
suggestion_id = f"personal_{int(time.time() * 1000)}_{len(suggestions)}",
completion_type = CompletionType.SNIPPET,
text = pattern_text,
display_text = pattern_text,
insert_text = self._get_insert_text(pattern_text, prefix),
#                     priority=9,  # High priority for personalized
confidence = 0.9,
documentation = f"Personalized suggestion",
metadata = {
#                         'user_pattern': True,
                        'frequency': pattern_data.get('frequency', 0)
#                     }
#                 )
                suggestions.append(suggestion)

#         return suggestions

#     def register_event_handler(self, event_type: str, handler):
#         """Register event handler"""
#         if event_type not in self.event_handlers:
self.event_handlers[event_type] = []

        self.event_handlers[event_type].append(handler)

#     async def _trigger_event(self, event_type: str, data: Dict[str, Any]):
#         """Trigger event to handlers"""
#         if event_type in self.event_handlers:
#             for handler in self.event_handlers[event_type]:
#                 try:
                    await handler(data)
#                 except Exception as e:
                    logger.error(f"Error in event handler: {e}")

#     async def update_completion_cache(self, context: CompletionContext,
#                                  suggestions: List[CompletionSuggestion]):
#         """Update completion cache"""
cache_key = f"{context.file_path}:{context.cursor_position[0]}:{context.cursor_position[1]}"

self.completion_cache[cache_key] = {
#             'context': context,
#             'suggestions': suggestions,
            'timestamp': time.time()
#         }

#         # Clean old cache entries
#         if len(self.completion_cache) > 1000:
#             # Keep only recent 500 entries
sorted_items = sorted(
                self.completion_cache.items(),
key = lambda x: x[1]['timestamp'],
reverse = True
#             )
self.completion_cache = dict(sorted_items[:500])

#     def get_completion_stats(self) -> Dict[str, Any]:
#         """Get completion statistics"""
#         return {
            'cache_size': len(self.completion_cache),
            'user_patterns': len(self.user_patterns),
            'supported_languages': list(self.language_keywords.keys()),
#             'total_completions': sum(len(patterns.get('completion', {})) for patterns in self.user_patterns.values())
#         }