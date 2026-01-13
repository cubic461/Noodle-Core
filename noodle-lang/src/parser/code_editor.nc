# """
# Code Editor for NoodleCore Desktop IDE
# 
# This module implements a text editor with syntax highlighting, code completion,
# AI integration, and integration with NoodleCore lexer and parser systems.
# """

import typing
import dataclasses
import enum
import logging
import uuid
import time
import os

from ...desktop import GUIError
from ..core.events.event_system import EventSystem, EventType, MouseEvent, KeyboardEvent
from ..core.rendering.rendering_engine import RenderingEngine, Color, Font, Rectangle, Point
from ..core.components.component_library import ComponentLibrary


class SyntaxLanguage(Enum):
    # """Supported programming languages."""
    PLAIN_TEXT = "plaintext"
    NOODLE = "noodle"
    PYTHON = "python"
    JAVASCRIPT = "javascript"
    TYPESCRIPT = "typescript"
    HTML = "html"
    CSS = "css"
    JSON = "json"
    MARKDOWN = "markdown"
    YAML = "yaml"
    SQL = "sql"


class CursorPosition:
    # """Cursor position in editor."""
    
    def __init__(self, line: int = 1, column: int = 1):
        self.line = line
        self.column = column
    
    def __str__(self):
        return f"Line {self.line}, Column {self.column}"
    
    def __repr__(self):
        return f"CursorPosition(line={self.line}, column={self.column})"


@dataclasses.dataclass
class TextBuffer:
    # """Text buffer for editor content."""
    lines: typing.List[str] = None
    cursor_position: CursorPosition = None
    selection_start: typing.Optional[CursorPosition] = None
    selection_end: typing.Optional[CursorPosition] = None
    modified: bool = False
    file_path: str = ""
    
    def __post_init__(self):
        if self.lines is None:
            self.lines = [""]
        if self.cursor_position is None:
            self.cursor_position = CursorPosition(1, 1)


@dataclasses.dataclass
class SyntaxToken:
    # """Syntax highlighting token."""
    text: str
    start_pos: CursorPosition
    end_pos: CursorPosition
    token_type: str
    color: Color
    is_keyword: bool = False
    is_string: bool = False
    is_comment: bool = False
    is_number: bool = False


@dataclasses.dataclass
class CodeSuggestion:
    # """Code completion suggestion."""
    text: str
    description: str
    kind: str = "text"  # text, function, keyword, variable
    confidence: float = 1.0
    insert_text: str = ""
    additional_text_edits: typing.List[typing.Dict] = None
    
    def __post_init__(self):
        if self.insert_text == "":
            self.insert_text = self.text
        if self.additional_text_edits is None:
            self.additional_text_edits = []


@dataclasses.dataclass
class CodeAnalysis:
    # """Code analysis result."""
    errors: typing.List[str] = None
    warnings: typing.List[str] = None
    suggestions: typing.List[str] = None
    syntax_valid: bool = True
    complexity_score: float = 0.0
    ai_insights: typing.Dict[str, typing.Any] = None
    
    def __post_init__(self):
        if self.errors is None:
            self.errors = []
        if self.warnings is None:
            self.warnings = []
        if self.suggestions is None:
            self.suggestions = []
        if self.ai_insights is None:
            self.ai_insights = {}


@dataclasses.dataclass
class EditorSettings:
    # """Editor settings and preferences."""
    font_family: str = "Consolas"
    font_size: int = 12
    line_numbers: bool = True
    word_wrap: bool = False
    auto_indent: bool = True
    tab_size: int = 4
    show_whitespace: bool = False
    highlight_current_line: bool = True
    theme: str = "dark"
    show_minimap: bool = True
    auto_save: bool = False
    ai_assistance: bool = True
    
    # Theme colors
    background_color: Color = None
    foreground_color: Color = None
    selection_color: Color = None
    line_number_color: Color = None
    comment_color: Color = None
    keyword_color: Color = None
    string_color: Color = None
    number_color: Color = None
    
    def __post_init__(self):
        # Dark theme defaults
        if self.background_color is None:
            self.background_color = Color(0.13, 0.14, 0.17, 1.0)
        if self.foreground_color is None:
            self.foreground_color = Color(0.86, 0.88, 0.91, 1.0)
        if self.selection_color is None:
            self.selection_color = Color(0.31, 0.72, 1.0, 0.3)
        if self.line_number_color is None:
            self.line_number_color = Color(0.56, 0.63, 0.68, 1.0)
        if self.comment_color is None:
            self.comment_color = Color(0.56, 0.64, 0.71, 1.0)
        if self.keyword_color is None:
            self.keyword_color = Color(0.95, 0.65, 0.47, 1.0)
        if self.string_color is None:
            self.string_color = Color(0.80, 0.86, 0.61, 1.0)
        if self.number_color is None:
            self.number_color = Color(0.80, 0.52, 0.82, 1.0)


class CodeEditorError(GUIError):
    # """Exception raised for code editor operations."""
    
    def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
        super().__init__(message, "8001", details)


class FileLoadError(CodeEditorError):
    # """Raised when file loading fails."""
    
    def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
        super().__init__(message, "8002", details)


class SyntaxAnalysisError(CodeEditorError):
    # """Raised when syntax analysis fails."""
    
    def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
        super().__init__(message, "8003", details)


class CodeEditor:
    # """
    # Code Editor for NoodleCore Desktop IDE.
    # 
    # This class provides a comprehensive code editor with syntax highlighting,
    # code completion, AI integration, and NoodleCore system integration.
    # """
    
    def __init__(self):
        # """Initialize the code editor."""
        self.logger = logging.getLogger(__name__)
        
        # Core GUI systems
        self._event_system = None
        self._rendering_engine = None
        self._component_library = None
        
        # Window and component references
        self._window_id = None
        self._text_area_component_id = None
        
        # Editor state
        self._text_buffer = TextBuffer()
        self._language = SyntaxLanguage.PLAIN_TEXT
        self._settings = EditorSettings()
        
        # Syntax highlighting
        self._syntax_tokens: typing.List[SyntaxToken] = []
        self._highlight_cache: typing.Dict[int, typing.List[SyntaxToken]] = {}
        
        # Code completion
        self._completion_cache: typing.List[CodeSuggestion] = []
        self._show_completions = False
        self._completion_position = CursorPosition()
        
        # Code analysis
        self._analysis_result: typing.Optional[CodeAnalysis] = None
        self._auto_analysis_enabled = True
        
        # Search and replace
        self._search_text = ""
        self._replace_text = ""
        self._search_matches: typing.List[typing.Tuple[int, int, int]] = []  # line, start_col, end_col
        self._current_search_match_index = 0
        
        # Folding
        self._foldable_ranges: typing.List[typing.Tuple[int, int]] = []  # start_line, end_line
        self._folded_lines: typing.Set[int] = set()
        
        # History
        self._undo_stack: typing.List[TextBuffer] = []
        self._redo_stack: typing.List[TextBuffer] = []
        self._max_history = 50
        
        # Metrics
        self._metrics = {
            "files_opened": 0,
            "files_saved": 0,
            "lines_typed": 0,
            "completions_triggered": 0,
            "syntax_errors": 0,
            "ai_suggestions_used": 0
        }
    
    def initialize(self, window_id: str, event_system: EventSystem,
                  rendering_engine: RenderingEngine, component_library: ComponentLibrary):
        # """
        # Initialize the code editor.
        
        Args:
            window_id: Window ID to attach to
            event_system: Event system instance
            rendering_engine: Rendering engine instance
            component_library: Component library instance
        """
        try:
            self._window_id = window_id
            self._event_system = event_system
            self._rendering_engine = rendering_engine
            self._component_library = component_library
            
            # Create text area component
            self._create_text_area()
            
            # Register event handlers
            self._register_event_handlers()
            
            # Set up theme
            self._apply_theme()
            
            self.logger.info("Code editor initialized")
            
        except Exception as e:
            self.logger.error(f"Failed to initialize code editor: {str(e)}")
            raise CodeEditorError(f"Code editor initialization failed: {str(e)}")
    
    def _create_text_area(self):
        # """Create the text area component."""
        try:
            self._text_area_component_id = self._component_library.create_component(
                component_type="text_edit",
                window_id=self._window_id,
                x=0,
                y=0,
                width=800,
                height=500,
                text="",
                font=self._settings.font_family,
                font_size=self._settings.font_size
            )
            
            self.logger.info(f"Created text area component: {self._text_area_component_id}")
            
        except Exception as e:
            self.logger.error(f"Failed to create text area: {str(e)}")
            raise CodeEditorError(f"Text area creation failed: {str(e)}")
    
    def _register_event_handlers(self):
        # """Register event handlers."""
        try:
            # Text input events
            self._event_system.register_handler(
                EventType.KEY_PRESS,
                self._handle_key_press,
                window_id=self._window_id
            )
            
            # Text change events
            self._event_system.register_handler(
                EventType.TEXT_CHANGE,
                self._handle_text_change,
                window_id=self._window_id
            )
            
            # Mouse events for cursor positioning
            self._event_system.register_handler(
                EventType.MOUSE_CLICK,
                self._handle_mouse_click,
                window_id=self._window_id
            )
            
            # Cursor position tracking
            self._event_system.register_handler(
                EventType.CURSOR_CHANGE,
                self._handle_cursor_change,
                window_id=self._window_id
            )
            
        except Exception as e:
            self.logger.error(f"Failed to register event handlers: {str(e)}")
            raise CodeEditorError(f"Event handler registration failed: {str(e)}")
    
    def load_file(self, file_path: str) -> bool:
        # """
        # Load a file into the editor.
        
        Args:
            file_path: Path to file to load
        
        Returns:
            True if successful
        """
        try:
            if not os.path.exists(file_path):
                raise FileLoadError(f"File does not exist: {file_path}")
            
            if not os.path.isfile(file_path):
                raise FileLoadError(f"Path is not a file: {file_path}")
            
            # Read file content
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            # Detect language from extension
            self._detect_language(file_path)
            
            # Set text buffer
            self._text_buffer = TextBuffer(
                lines=content.split('\n'),
                file_path=file_path,
                modified=False
            )
            self._text_buffer.cursor_position = CursorPosition(1, 1)
            
            # Update component
            self._component_library.set_component_text(
                self._text_area_component_id,
                content
            )
            
            # Analyze syntax
            self._analyze_syntax()
            
            # Update metrics
            self._metrics["files_opened"] += 1
            
            self.logger.info(f"Loaded file: {file_path} ({self._language.value})")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to load file {file_path}: {str(e)}")
            raise FileLoadError(f"File loading failed: {str(e)}")
    
    def save_file(self, file_path: str = None) -> bool:
        # """
        # Save the current file.
        
        Args:
            file_path: Path to save to (uses current file if None)
        
        Returns:
            True if successful
        """
        try:
            if file_path is None:
                file_path = self._text_buffer.file_path
            
            if not file_path:
                raise FileLoadError("No file path specified")
            
            # Get content from text buffer
            content = '\n'.join(self._text_buffer.lines)
            
            # Write file
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            # Update buffer state
            self._text_buffer.file_path = file_path
            self._text_buffer.modified = False
            
            # Update metrics
            self._metrics["files_saved"] += 1
            
            self.logger.info(f"Saved file: {file_path}")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to save file {file_path}: {str(e)}")
            raise FileLoadError(f"File saving failed: {str(e)}")
    
    def set_language(self, language: SyntaxLanguage):
        # """
        # Set the programming language for syntax highlighting.
        
        Args:
            language: Programming language to set
        """
        self._language = language
        self._analyze_syntax()
        self.logger.info(f"Set language to: {language.value}")
    
    def insert_text(self, text: str, position: typing.Optional[CursorPosition] = None) -> bool:
        # """
        # Insert text at specified position.
        
        Args:
            text: Text to insert
            position: Position to insert at (uses cursor if None)
        
        Returns:
            True if successful
        """
        try:
            if position is None:
                position = self._text_buffer.cursor_position
            
            # Save current state for undo
            self._save_undo_state()
            
            # Insert text
            self._text_buffer.lines[position.line - 1] = (
                self._text_buffer.lines[position.line - 1][:position.column - 1] +
                text +
                self._text_buffer.lines[position.line - 1][position.column - 1:]
            )
            
            # Update cursor position
            self._text_buffer.cursor_position = CursorPosition(
                position.line,
                position.column + len(text)
            )
            
            # Update component
            self._update_component_text()
            
            # Mark as modified
            self._text_buffer.modified = True
            
            # Analyze syntax
            self._analyze_syntax()
            
            self._metrics["lines_typed"] += text.count('\n')
            
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to insert text: {str(e)}")
            return False
    
    def delete_text(self, start_pos: CursorPosition, end_pos: CursorPosition) -> bool:
        # """
        # Delete text in range.
        
        Args:
            start_pos: Start position
            end_pos: End position
        
        Returns:
            True if successful
        """
        try:
            # Save current state for undo
            self._save_undo_state()
            
            # Simplified deletion logic
            if start_pos.line == end_pos.line:
                # Same line deletion
                line = self._text_buffer.lines[start_pos.line - 1]
                self._text_buffer.lines[start_pos.line - 1] = (
                    line[:start_pos.column - 1] + line[end_pos.column - 1:]
                )
            else:
                # Multi-line deletion (simplified)
                # In real implementation, would handle complex multi-line deletions
            
            # Update component
            self._update_component_text()
            
            # Mark as modified
            self._text_buffer.modified = True
            
            # Analyze syntax
            self._analyze_syntax()
            
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to delete text: {str(e)}")
            return False
    
    def get_code_suggestions(self, position: typing.Optional[CursorPosition] = None) -> typing.List[CodeSuggestion]:
        # """
        # Get code completion suggestions.
        
        Args:
            position: Position to get suggestions for (uses cursor if None)
        
        Returns:
            List of code suggestions
        """
        try:
            if position is None:
                position = self._text_buffer.cursor_position
            
            # Get current word context
            current_line = self._text_buffer.lines[position.line - 1]
            before_cursor = current_line[:position.column - 1]
            
            # Simple word-based completion (in real implementation would be AI-powered)
            suggestions = []
            
            # Common language keywords
            keywords = self._get_language_keywords()
            current_word = self._get_current_word(before_cursor)
            
            for keyword in keywords:
                if keyword.startswith(current_word) and keyword != current_word:
                    suggestions.append(CodeSuggestion(
                        text=keyword,
                        description=f"Keyword: {keyword}",
                        kind="keyword",
                        confidence=0.9
                    ))
            
            # Add common completions based on current language
            if self._language == SyntaxLanguage.PYTHON:
                suggestions.extend([
                    CodeSuggestion(text="def ", description="Define function", kind="keyword"),
                    CodeSuggestion(text="class ", description="Define class", kind="keyword"),
                    CodeSuggestion(text="import ", description="Import module", kind="keyword"),
                    CodeSuggestion(text="if ", description="If statement", kind="keyword"),
                    CodeSuggestion(text="for ", description="For loop", kind="keyword"),
                    CodeSuggestion(text="while ", description="While loop", kind="keyword"),
                ])
            elif self._language == SyntaxLanguage.NOODLE:
                suggestions.extend([
                    CodeSuggestion(text="class ", description="Define class", kind="keyword"),
                    CodeSuggestion(text="def ", description="Define function", kind="keyword"),
                    CodeSuggestion(text="import ", description="Import module", kind="keyword"),
                ])
            
            # Sort by confidence and limit results
            suggestions.sort(key=lambda s: s.confidence, reverse=True)
            self._completion_cache = suggestions[:20]
            
            self._metrics["completions_triggered"] += 1
            
            return self._completion_cache
            
        except Exception as e:
            self.logger.error(f"Failed to get code suggestions: {str(e)}")
            return []
    
    def accept_suggestion(self, suggestion: CodeSuggestion) -> bool:
        # """
        # Accept a code completion suggestion.
        
        Args:
            suggestion: Suggestion to accept
        
        Returns:
            True if successful
        """
        try:
            # Insert suggestion text
            return self.insert_text(suggestion.insert_text)
            
        except Exception as e:
            self.logger.error(f"Failed to accept suggestion: {str(e)}")
            return False
    
    def get_ai_suggestions(self, position: typing.Optional[CursorPosition] = None) -> typing.List[CodeSuggestion]:
        # """
        # Get AI-powered code suggestions.
        
        Args:
            position: Position to get AI suggestions for
        
        Returns:
            List of AI-powered suggestions
        """
        try:
            if position is None:
                position = self._text_buffer.cursor_position
            
            # In real implementation, would integrate with NoodleCore AI system
            # For now, return mock AI suggestions
            
            ai_suggestions = []
            
            # Mock AI analysis based on context
            current_line = self._text_buffer.lines[position.line - 1]
            
            if "def " in current_line:
                ai_suggestions.append(CodeSuggestion(
                    text="    \"\"\"Function description\"\"\"\n    ",
                    description="AI: Add function docstring",
                    kind="ai_suggestion",
                    confidence=0.8
                ))
            
            if self._language == SyntaxLanguage.PYTHON:
                ai_suggestions.append(CodeSuggestion(
                    text="    return None",
                    description="AI: Add return statement",
                    kind="ai_suggestion",
                    confidence=0.7
                ))
            
            self._metrics["ai_suggestions_used"] += len(ai_suggestions)
            
            return ai_suggestions
            
        except Exception as e:
            self.logger.error(f"Failed to get AI suggestions: {str(e)}")
            return []
    
    def find_text(self, search_text: str, replace_text: str = None) -> bool:
        # """
        # Find text in the editor.
        
        Args:
            search_text: Text to search for
            replace_text: Text to replace with (optional)
        
        Returns:
            True if found
        """
        try:
            self._search_text = search_text
            self._replace_text = replace_text or ""
            self._search_matches = []
            self._current_search_match_index = 0
            
            # Search all lines
            for line_num, line in enumerate(self._text_buffer.lines, 1):
                start = 0
                while True:
                    pos = line.find(search_text, start)
                    if pos == -1:
                        break
                    
                    self._search_matches.append((line_num, pos, pos + len(search_text)))
                    start = pos + 1
            
            self.logger.info(f"Found {len(self._search_matches)} matches for '{search_text}'")
            return len(self._search_matches) > 0
            
        except Exception as e:
            self.logger.error(f"Failed to find text: {str(e)}")
            return False
    
    def replace_text(self, search_text: str, replace_text: str, replace_all: bool = False) -> int:
        # """
        # Replace text in the editor.
        
        Args:
            search_text: Text to search for
            replace_text: Text to replace with
            replace_all: Replace all occurrences
        
        Returns:
            Number of replacements made
        """
        try:
            replacements_made = 0
            
            if replace_all:
                # Replace all occurrences
                for i, line in enumerate(self._text_buffer.lines):
                    if search_text in line:
                        self._text_buffer.lines[i] = line.replace(search_text, replace_text)
                        replacements_made += line.count(search_text)
            else:
                # Replace current match
                if self._current_search_match_index < len(self._search_matches):
                    line_num, start_col, end_col = self._search_matches[self._current_search_match_index]
                    line = self._text_buffer.lines[line_num - 1]
                    self._text_buffer.lines[line_num - 1] = (
                        line[:start_col] + replace_text + line[end_col:]
                    )
                    replacements_made = 1
            
            if replacements_made > 0:
                self._update_component_text()
                self._text_buffer.modified = True
                self._analyze_syntax()
            
            self.logger.info(f"Replaced {replacements_made} occurrences of '{search_text}'")
            return replacements_made
            
        except Exception as e:
            self.logger.error(f"Failed to replace text: {str(e)}")
            return 0
    
    def set_cursor_position(self, line: int, column: int):
        # """
        # Set cursor position.
        
        Args:
            line: Line number (1-based)
            column: Column number (1-based)
        """
        self._text_buffer.cursor_position = CursorPosition(line, column)
        # In real implementation, would update component cursor position
    
    def get_cursor_position(self) -> CursorPosition:
        # """Get current cursor position."""
        return self._text_buffer.cursor_position
    
    def set_editor_settings(self, **kwargs):
        # """
        # Update editor settings.
        
        Args:
            **kwargs: Settings to update
        """
        for key, value in kwargs.items():
            if hasattr(self._settings, key):
                setattr(self._settings, key, value)
        
        # Apply theme changes
        if 'theme' in kwargs or any(k.startswith('color') for k in kwargs.keys()):
            self._apply_theme()
        
        self.logger.info("Editor settings updated")
    
    def get_text_content(self) -> str:
        # """Get the complete text content."""
        return '\n'.join(self._text_buffer.lines)
    
    def get_analysis(self) -> typing.Optional[CodeAnalysis]:
        # """Get current code analysis."""
        return self._analysis_result
    
    def get_metrics(self) -> typing.Dict[str, typing.Any]:
        # """Get code editor metrics."""
        return self._metrics.copy()
    
    # Private methods
    
    def _detect_language(self, file_path: str):
        # """Detect programming language from file extension."""
        ext = os.path.splitext(file_path)[1].lower()
        
        language_map = {
            '.py': SyntaxLanguage.PYTHON,
            '.js': SyntaxLanguage.JAVASCRIPT,
            '.ts': SyntaxLanguage.TYPESCRIPT,
            '.html': SyntaxLanguage.HTML,
            '.css': SyntaxLanguage.CSS,
            '.json': SyntaxLanguage.JSON,
            '.md': SyntaxLanguage.MARKDOWN,
            '.yaml': SyntaxLanguage.YAML,
            '.yml': SyntaxLanguage.YAML,
            '.sql': SyntaxLanguage.SQL,
            '.nc': SyntaxLanguage.NOODLE,
            '.noodle': SyntaxLanguage.NOODLE,
        }
        
        self._language = language_map.get(ext, SyntaxLanguage.PLAIN_TEXT)
    
    def _analyze_syntax(self):
        # """Analyze syntax and generate tokens."""
        try:
            self._syntax_tokens = []
            self._analysis_result = CodeAnalysis()
            
            # Process each line
            for line_num, line in enumerate(self._text_buffer.lines, 1):
                tokens = self._tokenize_line(line, line_num)
                self._syntax_tokens.extend(tokens)
            
            # Update analysis result
            self._analysis_result.syntax_valid = len(self._analysis_result.errors) == 0
            
        except Exception as e:
            self.logger.error(f"Failed to analyze syntax: {str(e)}")
            raise SyntaxAnalysisError(f"Syntax analysis failed: {str(e)}")
    
    def _tokenize_line(self, line: str, line_num: int) -> typing.List[SyntaxToken]:
        # """Tokenize a single line for syntax highlighting."""
        tokens = []
        
        # Simple tokenization (in real implementation would use NoodleCore lexer)
        i = 0
        while i < len(line):
            char = line[i]
            
            # Skip whitespace
            if char.isspace():
                i += 1
                continue
            
            # String literals
            if char in ['"', "'"]:
                string_end = line.find(char, i + 1)
                if string_end != -1:
                    token_text = line[i:string_end + 1]
                    tokens.append(SyntaxToken(
                        text=token_text,
                        start_pos=CursorPosition(line_num, i + 1),
                        end_pos=CursorPosition(line_num, string_end + 2),
                        token_type="string",
                        color=self._settings.string_color,
                        is_string=True
                    ))
                    i = string_end + 1
                    continue
            
            # Numbers
            if char.isdigit():
                j = i + 1
                while j < len(line) and (line[j].isdigit() or line[j] == '.'):
                    j += 1
                tokens.append(SyntaxToken(
                    text=line[i:j],
                    start_pos=CursorPosition(line_num, i + 1),
                    end_pos=CursorPosition(line_num, j + 1),
                    token_type="number",
                    color=self._settings.number_color,
                    is_number=True
                ))
                i = j
                continue
            
            # Comments
            if line[i:i+2] == '//':
                tokens.append(SyntaxToken(
                    text=line[i:],
                    start_pos=CursorPosition(line_num, i + 1),
                    end_pos=CursorPosition(line_num, len(line) + 1),
                    token_type="comment",
                    color=self._settings.comment_color,
                    is_comment=True
                ))
                break
            
            if line[i:i+1] == '#':
                tokens.append(SyntaxToken(
                    text=line[i:],
                    start_pos=CursorPosition(line_num, i + 1),
                    end_pos=CursorPosition(line_num, len(line) + 1),
                    token_type="comment",
                    color=self._settings.comment_color,
                    is_comment=True
                ))
                break
            
            # Simple keyword detection
            keywords = self._get_language_keywords()
            for keyword in keywords:
                if line.startswith(keyword, i) and (i + len(keyword) == len(line) or not line[i + len(keyword)].isalnum()):
                    tokens.append(SyntaxToken(
                        text=keyword,
                        start_pos=CursorPosition(line_num, i + 1),
                        end_pos=CursorPosition(line_num, i + len(keyword) + 1),
                        token_type="keyword",
                        color=self._settings.keyword_color,
                        is_keyword=True
                    ))
                    i += len(keyword)
                    break
            else:
                # Regular text
                j = i + 1
                while j < len(line) and not line[j].isspace() and line[j] not in ['"', "'", '#']:
                    j += 1
                tokens.append(SyntaxToken(
                    text=line[i:j],
                    start_pos=CursorPosition(line_num, i + 1),
                    end_pos=CursorPosition(line_num, j + 1),
                    token_type="text",
                    color=self._settings.foreground_color
                ))
                i = j
        
        return tokens
    
    def _get_language_keywords(self) -> typing.Set[str]:
        # """Get keywords for current language."""
        if self._language == SyntaxLanguage.PYTHON:
            return {
                'def', 'class', 'if', 'elif', 'else', 'for', 'while', 'try', 'except',
                'finally', 'with', 'as', 'import', 'from', 'return', 'yield', 'break',
                'continue', 'pass', 'and', 'or', 'not', 'in', 'is', 'lambda', 'True',
                'False', 'None', 'async', 'await', 'global', 'nonlocal'
            }
        elif self._language == SyntaxLanguage.NOODLE:
            return {
                'class', 'def', 'if', 'else', 'for', 'while', 'try', 'except', 'finally',
                'import', 'from', 'return', 'yield', 'break', 'continue', 'pass', 'and',
                'or', 'not', 'in', 'is', 'lambda', 'True', 'False', 'None', 'async',
                'await', 'global', 'nonlocal', 'enum', 'dataclass', 'dataclasses'
            }
        else:
            return set()
    
    def _get_current_word(self, text: str) -> str:
        # """Get the current word being typed."""
        # Extract current word (alphanumeric and underscore)
        import re
        match = re.search(r'\\w+$', text)
        return match.group(0) if match else ""
    
    def _update_component_text(self):
        # """Update the text area component with current buffer content."""
        content = '\n'.join(self._text_buffer.lines)
        self._component_library.set_component_text(
            self._text_area_component_id,
            content
        )
    
    def _apply_theme(self):
        # """Apply the current theme to the editor."""
        # In real implementation, would update component theme
        self.logger.info(f"Applied theme: {self._settings.theme}")
    
    def _save_undo_state(self):
        # """Save current state to undo stack."""
        # Create a copy of current buffer
        undo_state = TextBuffer(
            lines=self._text_buffer.lines.copy(),
            cursor_position=CursorPosition(
                self._text_buffer.cursor_position.line,
                self._text_buffer.cursor_position.column
            ),
            file_path=self._text_buffer.file_path,
            modified=self._text_buffer.modified
        )
        
        self._undo_stack.append(undo_state)
        
        # Limit undo history
        if len(self._undo_stack) > self._max_history:
            self._undo_stack.pop(0)
    
    # Event handlers
    
    def _handle_key_press(self, event: KeyboardEvent):
        # """Handle keyboard input."""
        # In real implementation, would handle various key presses
        self.logger.debug(f"Key press: {event.key}")
    
    def _handle_text_change(self, event):
        # """Handle text changes."""
        # In real implementation, would update buffer and analyze syntax
        self.logger.debug("Text changed")
    
    def _handle_mouse_click(self, event: MouseEvent):
        # """Handle mouse clicks for cursor positioning."""
        # In real implementation, would calculate cursor position from click
        self.logger.debug(f"Mouse click at ({event.x}, {event.y})")
    
    def _handle_cursor_change(self, event):
        # """Handle cursor position changes."""
        # In real implementation, would update cursor tracking
        self.logger.debug("Cursor position changed")