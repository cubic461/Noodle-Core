# Code Analyzer for Noodle IDE
# Analyzes code for errors, suggestions, and syntax highlighting
# Provides language-independent code analysis through NoodleCore

import asyncio
import re
import time
import logging
from typing import Dict, List, Optional, Any, Tuple
from dataclasses import dataclass
from enum import Enum
from collections import defaultdict

@dataclass
class SyntaxToken:
    """Syntax highlighting token"""
    start: int
    end: int
    token_type: str  # "keyword", "string", "number", "comment", etc.
    text: str
    style: Dict[str, str] = None
    
    def __post_init__(self):
        if self.style is None:
            self.style = {}

@dataclass
class SyntaxError:
    """Syntax error information"""
    line: int
    column: int
    message: str
    error_type: str = "syntax_error"
    severity: str = "error"  # "error", "warning", "info"
    suggestions: List[str] = None
    
    def __post_init__(self):
        if self.suggestions is None:
            self.suggestions = []

@dataclass
class CodeSuggestion
    """Code completion suggestion"""
    text: str
    type: str  # "function", "class", "variable", "keyword"
    description: str
    snippet: str = ""
    priority: int = 0

@dataclass
class CodeMetrics
    """Code metrics and statistics"""
    lines: int = 0
    characters: int = 0
    words: int = 0
    functions: int = 0
    classes: int = 0
    imports: int = 0
    comments: int = 0
    blank_lines: int = 0
    complexity_score: float = 0.0

class LanguageSupport(Enum)
    """Supported programming languages"""
    NOODLE = "noodle"
    PYTHON = "python"
    JAVASCRIPT = "javascript"
    HTML = "html"
    CSS = "css"
    JSON = "json"
    MARKDOWN = "markdown"

class CodeAnalyzer
    """Noodle IDE Code Analyzer
    
    Provides comprehensive code analysis including:
    - Syntax highlighting
    - Error detection
    - Code completion
    - Metrics calculation
    - Language-specific features
    """

    def __init__(self):
        """Initialize the code analyzer"""
        self.logger = logging.getLogger(__name__)
        
        # Language definitions
        self.language_patterns = self._initialize_language_patterns()
        self.syntax_highlighting_rules = self._initialize_syntax_rules()
        
        # Analysis cache
        self.analysis_cache: Dict[str, Dict[str, Any]] = {}
        self.cache_expiry = 300  # 5 minutes
        self.max_cache_size = 100
        
        # Performance tracking
        self.analysis_count = 0
        self.error_count = 0
        self.average_analysis_time = 0.0

    def _initialize_language_patterns(self) -> Dict[str, Dict[str, Any]]:
        """Initialize language-specific patterns"""
        return {
            "noodle": {
                "keywords": [
                    'import', 'from', 'class', 'def', 'if', 'else', 'elif', 'for', 
                    'while', 'try', 'except', 'finally', 'with', 'as', 'return', 
                    'yield', 'break', 'continue', 'pass', 'and', 'or', 'not', 
                    'in', 'is', 'lambda', 'async', 'await', 'None', 'True', 'False'
                ],
                "builtins": [
                    'print', 'len', 'range', 'str', 'int', 'float', 'list', 
                    'dict', 'set', 'tuple', 'bool', 'type', 'isinstance'
                ],
                "comment_pattern": r'#.*',
                "string_delimiters": ['"""', "'''", '"', "'"],
                "operators": ['=', '==', '!=', '<', '>', '<=', '>=', '+', '-', '*', '/', '//', '%', '**'],
                "type_annotations": True,
                "async_support": True
            },
            "python": {
                "keywords": [
                    'import', 'from', 'class', 'def', 'if', 'else', 'elif', 'for', 
                    'while', 'try', 'except', 'finally', 'with', 'as', 'return', 
                    'yield', 'break', 'continue', 'pass', 'and', 'or', 'not', 
                    'in', 'is', 'lambda', 'async', 'await', 'None', 'True', 'False'
                ],
                "builtins": [
                    'print', 'len', 'range', 'str', 'int', 'float', 'list', 
                    'dict', 'set', 'tuple', 'bool', 'type', 'isinstance'
                ],
                "comment_pattern": r'#.*',
                "string_delimiters": ['"""', "'''", '"', "'"],
                "operators": ['=', '==', '!=', '<', '>', '<=', '>=', '+', '-', '*', '/', '//', '%', '**'],
                "type_annotations": True,
                "async_support": True
            },
            "javascript": {
                "keywords": [
                    'function', 'var', 'let', 'const', 'if', 'else', 'else if', 'for', 
                    'while', 'do', 'try', 'catch', 'finally', 'return', 'break', 
                    'continue', 'switch', 'case', 'default', 'new', 'class', 
                    'extends', 'super', 'this', 'null', 'undefined', 'true', 'false'
                ],
                "builtins": [
                    'console', 'setTimeout', 'setInterval', 'clearTimeout', 'clearInterval',
                    'Array', 'Object', 'String', 'Number', 'Boolean', 'Date', 'Math'
                ],
                "comment_pattern": r'//.*',
                "string_delimiters": ['"', "'"],
                "operators": ['=', '==', '===', '!=', '!==', '<', '>', '<=', '>=', '+', '-', '*', '/', '%'],
                "type_annotations": False,
                "async_support": True
            },
            "html": {
                "keywords": [],
                "builtins": [],
                "comment_pattern": r'<!--.*-->',
                "string_delimiters": ['"', "'"],
                "operators": [],
                "tags": [
                    'html', 'head', 'title', 'body', 'div', 'span', 'p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
                    'a', 'img', 'ul', 'ol', 'li', 'table', 'tr', 'td', 'th', 'form', 'input', 'button',
                    'script', 'style', 'link', 'meta', 'doctype', 'br', 'hr'
                ],
                "attributes": [
                    'class', 'id', 'src', 'href', 'style', 'type', 'name', 'value', 'placeholder',
                    'required', 'disabled', 'checked', 'selected', 'onclick', 'onload', 'onerror'
                ],
                "type_annotations": False,
                "async_support": False
            },
            "css": {
                "keywords": [],
                "builtins": [],
                "comment_pattern": r'/\*.*\*/',
                "string_delimiters": ['"', "'"],
                "operators": [],
                "properties": [
                    'color', 'background-color', 'font-size', 'font-family', 'font-weight',
                    'margin', 'padding', 'border', 'width', 'height', 'display', 'position',
                    'top', 'right', 'bottom', 'left', 'z-index', 'opacity', 'visibility',
                    'text-align', 'text-decoration', 'text-transform', 'line-height'
                ],
                "values": [
                    'block', 'inline', 'inline-block', 'none', 'relative', 'absolute',
                    'fixed', 'static', 'center', 'left', 'right', 'top', 'bottom',
                    'bold', 'normal', 'italic', 'underline', 'none', 'visible', 'hidden'
                ],
                "type_annotations": False,
                "async_support": False
            }
        }

    def _initialize_syntax_rules(self) -> Dict[str, Dict[str, str]]:
        """Initialize syntax highlighting style rules"""
        return {
            "noodle": {
                "keyword": {"color": "#f92672", "font-weight": "bold"},
                "string": {"color": "#e6db74"},
                "number": {"color": "#ae81ff"},
                "comment": {"color": "#75715e", "font-style": "italic"},
                "function": {"color": "#a6e22e"},
                "class": {"color": "#a6e22e", "font-weight": "bold"},
                "operator": {"color": "#f8f8f2"},
                "delimiter": {"color": "#f8f8f2"},
                "builtin": {"color": "#66d9ef"}
            },
            "python": {
                "keyword": {"color": "#f92672", "font-weight": "bold"},
                "string": {"color": "#e6db74"},
                "number": {"color": "#ae81ff"},
                "comment": {"color": "#75715e", "font-style": "italic"},
                "function": {"color": "#a6e22e"},
                "class": {"color": "#a6e22e", "font-weight": "bold"},
                "operator": {"color": "#f8f8f2"},
                "delimiter": {"color": "#f8f8f2"},
                "builtin": {"color": "#66d9ef"}
            },
            "javascript": {
                "keyword": {"color": "#f92672", "font-weight": "bold"},
                "string": {"color": "#e6db74"},
                "number": {"color": "#ae81ff"},
                "comment": {"color": "#75715e", "font-style": "italic"},
                "function": {"color": "#a6e22e"},
                "class": {"color": "#a6e22e", "font-weight": "bold"},
                "operator": {"color": "#f8f8f2"},
                "delimiter": {"color": "#f8f8f2"},
                "builtin": {"color": "#66d9ef"}
            },
            "html": {
                "tag": {"color": "#f92672"},
                "attribute": {"color": "#a6e22e"},
                "string": {"color": "#e6db74"},
                "comment": {"color": "#75715e", "font-style": "italic"},
                "operator": {"color": "#f8f8f2"}
            },
            "css": {
                "property": {"color": "#a6e22e"},
                "value": {"color": "#e6db74"},
                "comment": {"color": "#75715e", "font-style": "italic"},
                "operator": {"color": "#f8f8f2"}
            }
        }

    async def analyze_code(self, code: str, language: str = "noodle") -> Dict[str, Any]:
        """Analyze code and return comprehensive analysis"""
        start_time = time.time()
        
        try:
            self.analysis_count += 1
            
            # Check cache
            cache_key = f"{hash(code)}:{language}"
            if cache_key in self.analysis_cache:
                cached_result = self.analysis_cache[cache_key]
                if time.time() - cached_result.get("timestamp", 0) < self.cache_expiry:
                    return cached_result["result"]
            
            # Get language patterns
            patterns = self.language_patterns.get(language, self.language_patterns["noodle"])
            
            # Perform analysis
            syntax_tokens = await self._get_syntax_tokens(code, patterns, language)
            errors = await self._detect_syntax_errors(code, patterns, language)
            suggestions = await self._get_code_suggestions(code, patterns, language)
            metrics = await self._calculate_code_metrics(code, patterns)
            
            result = {
                "tokens": syntax_tokens,
                "errors": errors,
                "suggestions": suggestions,
                "metrics": metrics,
                "language": language,
                "analysis_time": time.time() - start_time
            }
            
            # Cache result
            self._cache_analysis_result(cache_key, result)
            
            # Update performance metrics
            analysis_time = time.time() - start_time
            self._update_performance_metrics(analysis_time, True)
            
            return result
            
        except Exception as e:
            self.error_count += 1
            self.logger.error(f"Code analysis failed: {e}")
            
            analysis_time = time.time() - start_time
            self._update_performance_metrics(analysis_time, False)
            
            return {
                "tokens": [],
                "errors": [SyntaxError(1, 0, f"Analysis error: {str(e)}", severity="error")],
                "suggestions": [],
                "metrics": CodeMetrics(),
                "language": language,
                "analysis_time": analysis_time
            }

    async def _get_syntax_tokens(self, code: str, patterns: Dict[str, Any], language: str) -> List[SyntaxToken]:
        """Extract syntax highlighting tokens"""
        tokens = []
        
        try:
            lines = code.split('\n')
            
            for line_idx, line in enumerate(lines):
                # Process comments
                if patterns.get("comment_pattern"):
                    comment_match = re.search(patterns["comment_pattern"], line)
                    if comment_match:
                        start_col = comment_match.start()
                        end_col = comment_match.end()
                        tokens.append(SyntaxToken(
                            start=line_idx * 1000 + start_col,
                            end=line_idx * 1000 + end_col,
                            token_type="comment",
                            text=comment_match.group(),
                            style=self.syntax_highlighting_rules.get(language, {}).get("comment", {})
                        ))
                        
                        # Remove comment from line for further processing
                        line = line[:start_col]
                
                # Process strings
                for delimiter in patterns.get("string_delimiters", []):
                    pos = 0
                    while pos < len(line):
                        start_pos = line.find(delimiter, pos)
                        if start_pos == -1:
                            break
                        
                        end_pos = line.find(delimiter, start_pos + len(delimiter))
                        if end_pos == -1:
                            # Unclosed string
                            end_pos = len(line)
                        
                        tokens.append(SyntaxToken(
                            start=line_idx * 1000 + start_pos,
                            end=line_idx * 1000 + end_pos + len(delimiter),
                            token_type="string",
                            text=line[start_pos:end_pos + len(delimiter)],
                            style=self.syntax_highlighting_rules.get(language, {}).get("string", {})
                        ))
                        
                        pos = end_pos + len(delimiter)
                
                # Process numbers
                number_matches = re.finditer(r'\b\d+(?:\.\d+)?\b', line)
                for match in number_matches:
                    tokens.append(SyntaxToken(
                        start=line_idx * 1000 + match.start(),
                        end=line_idx * 1000 + match.end(),
                        token_type="number",
                        text=match.group(),
                        style=self.syntax_highlighting_rules.get(language, {}).get("number", {})
                    ))
                
                # Process keywords
                for keyword in patterns.get("keywords", []):
                    keyword_matches = re.finditer(r'\b' + keyword + r'\b', line)
                    for match in keyword_matches:
                        tokens.append(SyntaxToken(
                            start=line_idx * 1000 + match.start(),
                            end=line_idx * 1000 + match.end(),
                            token_type="keyword",
                            text=match.group(),
                            style=self.syntax_highlighting_rules.get(language, {}).get("keyword", {})
                        ))
                
                # Process builtins
                for builtin in patterns.get("builtins", []):
                    builtin_matches = re.finditer(r'\b' + builtin + r'\b', line)
                    for match in builtin_matches:
                        tokens.append(SyntaxToken(
                            start=line_idx * 1000 + match.start(),
                            end=line_idx * 1000 + match.end(),
                            token_type="builtin",
                            text=match.group(),
                            style=self.syntax_highlighting_rules.get(language, {}).get("builtin", {})
                        ))
            
        except Exception as e:
            self.logger.error(f"Error extracting syntax tokens: {e}")
        
        return tokens

    async def _detect_syntax_errors(self, code: str, patterns: Dict[str, Any], language: str) -> List[SyntaxError]:
        """Detect syntax errors in code"""
        errors = []
        
        try:
            lines = code.split('\n')
            
            for line_idx, line in enumerate(lines):
                line_num = line_idx + 1
                
                # Check for common syntax errors based on language
                if language in ["noodle", "python"]:
                    # Check for missing colons after control structures
                    if re.search(r'^\s*(if|elif|else|for|while|try|except|def|class)\s+.*[^:]\s*$', line):
                        errors.append(SyntaxError(
                            line=line_num,
                            column=len(line.rstrip()),
                            message="Missing colon",
                            suggestions=["Add ':' at the end of the line"]
                        ))
                    
                    # Check for unbalanced parentheses
                    open_parens = line.count('(')
                    open_brackets = line.count('[')
                    open_braces = line.count('{')
                    
                    if open_parens + open_brackets + open_braces > 0:
                        errors.append(SyntaxError(
                            line=line_num,
                            column=0,
                            message="Unbalanced brackets detected",
                            suggestions=["Check matching brackets and parentheses"]
                        ))
                
                elif language == "javascript":
                    # Check for missing semicolons (basic check)
                    if re.search(r'^\s*[\w)\]]+\s*$', line) and line.strip() and not line.strip().endswith((';', '{', '}')):
                        # This is a very basic check
                        pass  # Could add more sophisticated checks
                
                elif language == "html":
                    # Check for unclosed tags (basic check)
                    tag_matches = re.findall(r'<(\w+)[^>]*>(?:[^<]*</\1>)?', line)
                    for tag in tag_matches:
                        if not re.search(r'</' + tag + r'>', line):
                            errors.append(SyntaxError(
                                line=line_num,
                                column=0,
                                message=f"Unclosed tag: <{tag}>",
                                suggestions=[f"Add closing tag </{tag}>"]
                            ))
        
        except Exception as e:
            self.logger.error(f"Error detecting syntax errors: {e}")
        
        return errors

    async def _get_code_suggestions(self, code: str, patterns: Dict[str, Any], language: str) -> List[CodeSuggestion]:
        """Get code completion suggestions"""
        suggestions = []
        
        try:
            lines = code.split('\n')
            current_line = lines[-1] if lines else ""
            
            # Get word before cursor
            word_match = re.search(r'(\w+)$', current_line)
            if word_match:
                partial_word = word_match.group(1)
                
                # Suggest keywords
                for keyword in patterns.get("keywords", []):
                    if keyword.startswith(partial_word) and keyword != partial_word:
                        suggestions.append(CodeSuggestion(
                            text=keyword,
                            type="keyword",
                            description=f"Keyword: {keyword}",
                            snippet=keyword
                        ))
                
                # Suggest builtins
                for builtin in patterns.get("builtins", []):
                    if builtin.startswith(partial_word) and builtin != partial_word:
                        suggestions.append(CodeSuggestion(
                            text=builtin,
                            type="function",
                            description=f"Built-in function: {builtin}",
                            snippet=builtin
                        ))
                
                # Sort suggestions by relevance
                suggestions.sort(key=lambda s: (s.text.startswith(partial_word), s.text), reverse=True)
                
                # Limit to top 10 suggestions
                suggestions = suggestions[:10]
        
        except Exception as e:
            self.logger.error(f"Error getting code suggestions: {e}")
        
        return suggestions

    async def _calculate_code_metrics(self, code: str, patterns: Dict[str, Any]) -> CodeMetrics:
        """Calculate code metrics and statistics"""
        try:
            lines = code.split('\n')
            
            metrics = CodeMetrics()
            metrics.lines = len(lines)
            metrics.characters = len(code)
            
            # Count different types of lines
            function_defs = 0
            class_defs = 0
            import_statements = 0
            comments = 0
            blank_lines = 0
            
            for line in lines:
                stripped = line.strip()
                
                if not stripped:
                    blank_lines += 1
                    continue
                
                # Count comments
                if patterns.get("comment_pattern") and re.search(patterns["comment_pattern"], stripped):
                    comments += 1
                
                # Count function definitions
                if patterns.get("keywords", []) and 'def' in patterns["keywords"]:
                    if stripped.startswith('def ') or stripped.startswith('async def '):
                        function_defs += 1
                
                # Count class definitions
                if patterns.get("keywords", []) and 'class' in patterns["keywords"]:
                    if stripped.startswith('class '):
                        class_defs += 1
                
                # Count imports
                if patterns.get("keywords", []) and 'import' in patterns["keywords"]:
                    if stripped.startswith(('import ', 'from ')):
                        import_statements += 1
            
            metrics.functions = function_defs
            metrics.classes = class_defs
            metrics.imports = import_statements
            metrics.comments = comments
            metrics.blank_lines = blank_lines
            metrics.words = len(re.findall(r'\w+', code))
            
            # Calculate basic complexity score
            # This is a simplified complexity calculation
            complexity_factors = [
                function_defs * 2,
                class_defs * 3,
                import_statements,
                len(re.findall(r'\b(if|for|while|try|except)\b', code)) * 2,
                len(re.findall(r'\band\b|\bor\b|\bnot\b', code)) * 1.5
            ]
            
            metrics.complexity_score = sum(complexity_factors) / max(1, metrics.lines)
            
        except Exception as e:
            self.logger.error(f"Error calculating code metrics: {e}")
        
        return metrics

    def _cache_analysis_result(self, cache_key: str, result: Dict[str, Any]):
        """Cache analysis result"""
        if len(self.analysis_cache) >= self.max_cache_size:
            # Remove oldest entry
            oldest_key = min(self.analysis_cache.keys())
            del self.analysis_cache[oldest_key]
        
        self.analysis_cache[cache_key] = {
            "result": result,
            "timestamp": time.time()
        }

    def _update_performance_metrics(self, analysis_time: float, success: bool):
        """Update performance metrics"""
        if success:
            if self.average_analysis_time == 0:
                self.average_analysis_time = analysis_time
            else:
                # Exponential moving average
                alpha = 0.1
                self.average_analysis_time = (alpha * analysis_time + 
                                           (1 - alpha) * self.average_analysis_time)

    def clear_cache(self):
        """Clear analysis cache"""
        self.analysis_cache.clear()
        self.logger.info("Analysis cache cleared")

    def get_performance_stats(self) -> Dict[str, Any]:
        """Get analyzer performance statistics"""
        return {
            "total_analyses": self.analysis_count,
            "error_count": self.error_count,
            "success_rate": (self.analysis_count - self.error_count) / max(1, self.analysis_count),
            "average_analysis_time_ms": self.average_analysis_time * 1000,
            "cache_size": len(self.analysis_cache),
            "max_cache_size": self.max_cache_size
        }

    def get_language_patterns(self, language: str) -> Dict[str, Any]:
        """Get patterns for a specific language"""
        return self.language_patterns.get(language, self.language_patterns["noodle"])

    def get_syntax_styles(self, language: str) -> Dict[str, str]:
        """Get syntax highlighting styles for a language"""
        return self.syntax_highlighting_rules.get(language, {})

    def __str__(self):
        return f"CodeAnalyzer(analyses={self.analysis_count}, cache={len(self.analysis_cache)})"

    def __repr__(self):
        return f"CodeAnalyzer(errors={self.error_count}, avg_time={self.average_analysis_time:.3f}s)"