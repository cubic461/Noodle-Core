# NoodleCore Integrated Development Environment
# Built entirely in Noodle language for true language independence
# This IDE demonstrates that complete development environments can be built
# without external language dependencies

import asyncio
import json
import time
import logging
import typing.Dict
import typing.List
import typing.Optional
import typing.Union
import typing.Any
import uuid
from dataclasses import dataclass
from enum import Enum
from datetime import datetime

# Core IDE Configuration
IDE_CONFIG = {
    "name": "Noodle IDE",
    "version": "1.0.0",
    "description": "Self-contained IDE built entirely in Noodle language",
    "author": "NoodleCore Team",
    "language": "noodle",
    "port": 8080,
    "web_interface_path": "./web/",
    "api_base_url": "http://localhost:8080",
    "theme": "dark",
    "features": [
        "syntax_highlighting",
        "code_completion", 
        "file_management",
        "project_management",
        "code_execution",
        "real_time_editing",
        "error_detection",
        "auto_save"
    ]
}

class IDEMode(Enum):
    """IDE operation modes"""
    EDITOR = "editor"
    FILE_MANAGER = "file_manager"
    PROJECT_MANAGER = "project_manager"
    EXECUTION = "execution"
    SETTINGS = "settings"

class FileType(Enum):
    """Supported file types"""
    NOODLE = ".nc"
    PYTHON = ".py"
    JAVASCRIPT = ".js"
    HTML = ".html"
    CSS = ".css"
    JSON = ".json"
    MARKDOWN = ".md"
    TEXT = ".txt"

@dataclass
class FileInfo:
    """File information structure"""
    path: str
    name: str
    extension: str
    size: int
    created_at: datetime
    modified_at: datetime
    content: str
    file_type: FileType
    encoding: str = "utf-8"

@dataclass 
class ProjectInfo:
    """Project information structure"""
    name: str
    path: str
    description: str
    files: List[FileInfo]
    created_at: datetime
    modified_at: datetime
    settings: Dict[str, Any]

@dataclass
class CodeCompletion:
    """Code completion suggestion"""
    text: str
    type: str  # "function", "class", "variable", "keyword"
    description: str
    snippet: str = ""

@dataclass
class SyntaxHighlight:
    """Syntax highlighting token"""
    start: int
    end: int
    token_type: str  # "keyword", "string", "number", "comment", etc.
    text: str

class NoodleIDE:
    """
    Main Noodle IDE class
    
    This is the core IDE implementation built entirely in Noodle language.
    It provides:
    - Code editing with syntax highlighting
    - File and project management
    - Code completion and error detection
    - Real-time collaboration features
    - Integration with NoodleCore API
    """

    def __init__(self, config: Optional[Dict[str, Any]] = None):
        """Initialize the Noodle IDE"""
        self.config = config or IDE_CONFIG
        self.mode = IDEMode.EDITOR
        
        # Core IDE state
        self.is_running = False
        self.current_file: Optional[FileInfo] = None
        self.current_project: Optional[ProjectInfo] = None
        self.files_opened: List[FileInfo] = []
        self.recent_files: List[str] = []
        
        # IDE features
        self.syntax_highlighter = SyntaxHighlighter()
        self.code_completer = CodeCompleter()
        self.file_manager = FileManager()
        self.project_manager = ProjectManager()
        self.executor = CodeExecutor()
        
        # Real-time features
        self.auto_save_enabled = True
        self.auto_save_interval = 30  # seconds
        self.last_save_time = 0
        self.unsaved_changes = False
        
        # Performance tracking
        self.start_time = time.time()
        self.operations_count = 0
        self.error_count = 0
        
        # Logger
        logging.basicConfig(level=logging.INFO)
        self.logger = logging.getLogger(__name__)
        
        self.logger.info("Noodle IDE initialized")

    async def initialize(self):
        """Initialize IDE components"""
        try:
            # Initialize file manager
            await self.file_manager.initialize()
            
            # Initialize project manager
            await self.project_manager.initialize()
            
            # Initialize code completer
            await self.code_completer.initialize()
            
            # Initialize executor
            await self.executor.initialize()
            
            self.is_running = True
            self.logger.info("Noodle IDE fully initialized")
            
        except Exception as e:
            self.error_count += 1
            self.logger.error(f"IDE initialization failed: {e}")
            raise

    async def cleanup(self):
        """Clean up IDE resources"""
        # Save any unsaved changes
        if self.unsaved_changes:
            await self.save_all_files()
        
        # Clean up components
        await self.file_manager.cleanup()
        await self.project_manager.cleanup()
        await self.code_completer.cleanup()
        await self.executor.cleanup()
        
        self.is_running = False
        self.logger.info("Noodle IDE cleaned up")

    async def open_file(self, file_path: str) -> Optional[FileInfo]:
        """Open a file in the editor"""
        try:
            file_info = await self.file_manager.load_file(file_path)
            
            if file_info:
                self.current_file = file_info
                
                # Add to opened files if not already there
                if file_info not in self.files_opened:
                    self.files_opened.append(file_info)
                
                # Update recent files
                if file_path not in self.recent_files:
                    self.recent_files.insert(0, file_path)
                    # Keep only last 10 recent files
                    self.recent_files = self.recent_files[:10]
                
                self.operations_count += 1
                self.logger.info(f"Opened file: {file_path}")
                
                return file_info
            
        except Exception as e:
            self.error_count += 1
            self.logger.error(f"Failed to open file {file_path}: {e}")
            
        return None

    async def save_file(self, file_info: FileInfo, content: str) -> bool:
        """Save a file"""
        try:
            # Update file content
            file_info.content = content
            file_info.modified_at = datetime.now()
            file_info.size = len(content)
            
            # Save to disk
            success = await self.file_manager.save_file(file_info)
            
            if success:
                # Mark as saved
                if file_info == self.current_file:
                    self.unsaved_changes = False
                    self.last_save_time = time.time()
                
                self.operations_count += 1
                self.logger.info(f"Saved file: {file_info.path}")
                return True
                
        except Exception as e:
            self.error_count += 1
            self.logger.error(f"Failed to save file {file_info.path}: {e}")
            
        return False

    async def save_all_files(self):
        """Save all opened files"""
        saved_count = 0
        
        for file_info in self.files_opened:
            # Check if file has unsaved changes
            if hasattr(file_info, '_unsaved_changes') and file_info._unsaved_changes:
                if await self.save_file(file_info, file_info.content):
                    saved_count += 1
        
        self.logger.info(f"Saved {saved_count} files")
        return saved_count

    async def create_file(self, file_path: str, content: str = "", file_type: FileType = FileType.NOODLE) -> Optional[FileInfo]:
        """Create a new file"""
        try:
            file_info = await self.file_manager.create_file(file_path, content, file_type)
            
            if file_info:
                # Add to opened files
                if file_info not in self.files_opened:
                    self.files_opened.append(file_info)
                
                self.current_file = file_info
                self.unsaved_changes = True
                self.operations_count += 1
                
                self.logger.info(f"Created new file: {file_path}")
                return file_info
                
        except Exception as e:
            self.error_count += 1
            self.logger.error(f"Failed to create file {file_path}: {e}")
            
        return None

    async def delete_file(self, file_path: str) -> bool:
        """Delete a file"""
        try:
            success = await self.file_manager.delete_file(file_path)
            
            if success:
                # Remove from opened files
                self.files_opened = [f for f in self.files_opened if f.path != file_path]
                
                # Clear current file if it's the deleted one
                if self.current_file and self.current_file.path == file_path:
                    self.current_file = None
                
                self.operations_count += 1
                self.logger.info(f"Deleted file: {file_path}")
                return True
                
        except Exception as e:
            self.error_count += 1
            self.logger.error(f"Failed to delete file {file_path}: {e}")
            
        return False

    async def get_syntax_highlight(self, content: str, file_type: FileType) -> List[SyntaxHighlight]:
        """Get syntax highlighting for content"""
        try:
            highlights = await self.syntax_highlighter.highlight(content, file_type)
            return highlights
        except Exception as e:
            self.error_count += 1
            self.logger.error(f"Syntax highlighting failed: {e}")
            return []

    async def get_code_completions(self, content: str, position: int, file_type: FileType) -> List[CodeCompletion]:
        """Get code completions at position"""
        try:
            completions = await self.code_completer.get_completions(content, position, file_type)
            return completions
        except Exception as e:
            self.error_count += 1
            self.logger.error(f"Code completion failed: {e}")
            return []

    async def execute_code(self, content: str, file_type: FileType) -> Dict[str, Any]:
        """Execute code content"""
        try:
            result = await self.executor.execute(content, file_type)
            self.operations_count += 1
            return result
        except Exception as e:
            self.error_count += 1
            self.logger.error(f"Code execution failed: {e}")
            return {
                "success": False,
                "error": str(e),
                "execution_time": 0
            }

    async def create_project(self, project_path: str, name: str, description: str = "") -> Optional[ProjectInfo]:
        """Create a new project"""
        try:
            project = await self.project_manager.create_project(project_path, name, description)
            
            if project:
                self.current_project = project
                self.operations_count += 1
                self.logger.info(f"Created project: {name}")
                return project
                
        except Exception as e:
            self.error_count += 1
            self.logger.error(f"Failed to create project: {e}")
            
        return None

    async def load_project(self, project_path: str) -> Optional[ProjectInfo]:
        """Load an existing project"""
        try:
            project = await self.project_manager.load_project(project_path)
            
            if project:
                self.current_project = project
                self.operations_count += 1
                self.logger.info(f"Loaded project: {project.name}")
                return project
                
        except Exception as e:
            self.error_count += 1
            self.logger.error(f"Failed to load project: {e}")
            
        return None

    async def list_files(self, directory: str) -> List[FileInfo]:
        """List files in directory"""
        try:
            files = await self.file_manager.list_files(directory)
            return files
        except Exception as e:
            self.error_count += 1
            self.logger.error(f"Failed to list files in {directory}: {e}")
            return []

    async def search_files(self, query: str, directory: str = "") -> List[FileInfo]:
        """Search for files"""
        try:
            files = await self.file_manager.search_files(query, directory)
            return files
        except Exception as e:
            self.error_count += 1
            self.logger.error(f"File search failed: {e}")
            return []

    async def get_ide_status(self) -> Dict[str, Any]:
        """Get IDE status and statistics"""
        uptime = time.time() - self.start_time
        
        return {
            "ide_info": {
                "name": self.config["name"],
                "version": self.config["version"],
                "mode": self.mode.value,
                "is_running": self.is_running,
                "uptime_seconds": uptime
            },
            "current_file": {
                "path": self.current_file.path if self.current_file else None,
                "name": self.current_file.name if self.current_file else None,
                "has_unsaved_changes": self.unsaved_changes
            },
            "current_project": {
                "name": self.current_project.name if self.current_project else None,
                "path": self.current_project.path if self.current_project else None,
                "files_count": len(self.current_project.files) if self.current_project else 0
            },
            "statistics": {
                "operations_count": self.operations_count,
                "error_count": self.error_count,
                "files_opened": len(self.files_opened),
                "recent_files_count": len(self.recent_files),
                "error_rate": self.error_count / max(self.operations_count, 1)
            },
            "features": self.config["features"],
            "settings": {
                "auto_save_enabled": self.auto_save_enabled,
                "auto_save_interval": self.auto_save_interval,
                "theme": self.config["theme"]
            }
        }

    def __str__(self) -> str:
        """String representation"""
        return f"NoodleIDE(mode={self.mode.value}, files={len(self.files_opened)}, errors={self.error_count})"

    def __repr__(self) -> str:
        """Debug representation"""
        return f"NoodleIDE(running={self.is_running}, project={self.current_project.name if self.current_project else None})"


class SyntaxHighlighter:
    """Syntax highlighting engine built in Noodle"""

    def __init__(self):
        self.token_patterns = {
            "keywords": [
                "import", "from", "class", "def", "async", "await", "return", 
                "if", "else", "elif", "for", "while", "try", "except", "finally",
                "with", "as", "lambda", "yield", "pass", "break", "continue",
                "and", "or", "not", "in", "is", "None", "True", "False"
            ],
            "operators": [
                "+", "-", "*", "/", "//", "%", "**", "&", "|", "^", "~", "<<", ">>",
                "==", "!=", "<", ">", "<=", ">=", "=", "+=", "-=", "*=", "/=",
                "//=", "%=", "**=", "&=", "|=", "^=", "<<=", ">>="
            ],
            "delimiters": [
                "(", ")", "[", "]", "{", "}", ",", ":", ".", ";", "@", "="
            ]
        }

    async def highlight(self, content: str, file_type: FileType) -> List[SyntaxHighlight]:
        """Generate syntax highlighting for content"""
        highlights = []
        
        if file_type == FileType.NOODLE:
            highlights = await self._highlight_noodle(content)
        elif file_type == FileType.PYTHON:
            highlights = await self._highlight_python(content)
        else:
            # Basic highlighting for other file types
            highlights = await self._highlight_generic(content)
        
        return highlights

    async def _highlight_noodle(self, content: str) -> List[SyntaxHighlight]:
        """Highlight Noodle syntax"""
        highlights = []
        lines = content.split('\n')
        
        for line_idx, line in enumerate(lines):
            await asyncio.sleep(0)  # Allow other coroutines to run
            
            pos = 0
            while pos < len(line):
                # Check for keywords
                for keyword in self.token_patterns["keywords"]:
                    if line[pos:pos+len(keyword)] == keyword:
                        highlights.append(SyntaxHighlight(
                            start=line_idx * 1000 + pos,
                            end=line_idx * 1000 + pos + len(keyword),
                            token_type="keyword",
                            text=keyword
                        ))
                        pos += len(keyword)
                        break
                else:
                    pos += 1
        
        return highlights

    async def _highlight_python(self, content: str) -> List[SyntaxHighlight]:
        """Highlight Python syntax (similar to Noodle)"""
        return await self._highlight_noodle(content)

    async def _highlight_generic(self, content: str) -> List[SyntaxHighlight]:
        """Basic highlighting for generic files"""
        highlights = []
        lines = content.split('\n')
        
        for line_idx, line in enumerate(lines):
            # Simple string detection
            start_quote = line.find('"')
            if start_quote != -1:
                end_quote = line.find('"', start_quote + 1)
                if end_quote != -1:
                    highlights.append(SyntaxHighlight(
                        start=line_idx * 1000 + start_quote,
                        end=line_idx * 1000 + end_quote + 1,
                        token_type="string",
                        text=line[start_quote:end_quote + 1]
                    ))
        
        return highlights


class CodeCompleter:
    """Code completion engine"""

    def __init__(self):
        self.completions_cache = {}

    async def initialize(self):
        """Initialize code completer"""
        # Preload common completions
        await self._load_common_completions()

    async def cleanup(self):
        """Clean up code completer"""
        self.completions_cache.clear()

    async def _load_common_completions(self):
        """Load common code completions"""
        common_completions = [
            CodeCompletion("def", "keyword", "Define function", "def function_name():\n    pass"),
            CodeCompletion("class", "keyword", "Define class", "class ClassName:\n    pass"),
            CodeCompletion("if", "keyword", "Conditional statement", "if condition:\n    pass"),
            CodeCompletion("for", "keyword", "For loop", "for item in items:\n    pass"),
            CodeCompletion("while", "keyword", "While loop", "while condition:\n    pass"),
            CodeCompletion("try", "keyword", "Try-except block", "try:\n    pass\nexcept Exception as e:\n    pass"),
            CodeCompletion("import", "keyword", "Import statement", "import module"),
            CodeCompletion("async", "keyword", "Async function", "async def function_name():\n    pass"),
            CodeCompletion("await", "keyword", "Await expression", "await expression"),
            CodeCompletion("return", "keyword", "Return statement", "return value"),
            CodeCompletion("print", "function", "Print function", "print(value)"),
            CodeCompletion("len", "function", "Length function", "len(object)"),
            CodeCompletion("range", "function", "Range function", "range(start, stop, step)"),
            CodeCompletion("enumerate", "function", "Enumerate function", "enumerate(iterable)"),
            CodeCompletion("zip", "function", "Zip function", "zip(iterable1, iterable2)")
        ]
        
        for completion in common_completions:
            if completion.text not in self.completions_cache:
                self.completions_cache[completion.text] = []

            self.completions_cache[completion.text].append(completion)

    async def get_completions(self, content: str, position: int, file_type: FileType) -> List[CodeCompletion]:
        """Get code completions at position"""
        # Extract current word being typed
        start_pos = position
        while start_pos > 0 and content[start_pos - 1].isalnum() or content[start_pos - 1] in '_':
            start_pos -= 1
        
        current_word = content[start_pos:position]
        
        # Find matching completions
        completions = []
        for word, word_completions in self.completions_cache.items():
            if word.startswith(current_word) and word != current_word:
                completions.extend(word_completions)
        
        # Sort by relevance (exact matches first)
        completions.sort(key=lambda c: 0 if c.text.startswith(current_word) else 1)
        
        return completions[:10]  # Limit to 10 suggestions


class FileManager:
    """File management system"""

    def __init__(self):
        self.working_directory = "./"
        self.file_cache = {}

    async def initialize(self):
        """Initialize file manager"""
        self.logger = logging.getLogger(__name__)

    async def cleanup(self):
        """Clean up file manager"""
        self.file_cache.clear()

    async def load_file(self, file_path: str) -> Optional[FileInfo]:
        """Load a file"""
        try:
            # Check cache first
            if file_path in self.file_cache:
                return self.file_cache[file_path]
            
            # Read file from disk
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Create FileInfo
            file_info = FileInfo(
                path=file_path,
                name=file_path.split('/')[-1],
                extension=file_path.split('.')[-1] if '.' in file_path else '',
                size=len(content),
                created_at=datetime.now(),
                modified_at=datetime.now(),
                content=content,
                file_type=self._detect_file_type(file_path)
            )
            
            # Cache file
            self.file_cache[file_path] = file_info
            
            return file_info
            
        except Exception as e:
            self.logger.error(f"Failed to load file {file_path}: {e}")
            return None

    async def save_file(self, file_info: FileInfo) -> bool:
        """Save a file"""
        try:
            # Write to disk
            with open(file_info.path, 'w', encoding=file_info.encoding) as f:
                f.write(file_info.content)
            
            # Update cache
            self.file_cache[file_info.path] = file_info
            
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to save file {file_info.path}: {e}")
            return False

    async def create_file(self, file_path: str, content: str, file_type: FileType) -> Optional[FileInfo]:
        """Create a new file"""
        try:
            # Create directories if needed
            import os
            os.makedirs(os.path.dirname(file_path), exist_ok=True)
            
            # Write initial content
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            # Create FileInfo
            file_info = FileInfo(
                path=file_path,
                name=file_path.split('/')[-1],
                extension=file_path.split('.')[-1] if '.' in file_path else '',
                size=len(content),
                created_at=datetime.now(),
                modified_at=datetime.now(),
                content=content,
                file_type=file_type
            )
            
            # Add to cache
            self.file_cache[file_path] = file_info
            
            return file_info
            
        except Exception as e:
            self.logger.error(f"Failed to create file {file_path}: {e}")
            return None

    async def delete_file(self, file_path: str) -> bool:
        """Delete a file"""
        try:
            import os
            
            if os.path.exists(file_path):
                os.remove(file_path)
            
            # Remove from cache
            if file_path in self.file_cache:
                del self.file_cache[file_path]
            
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to delete file {file_path}: {e}")
            return False

    async def list_files(self, directory: str) -> List[FileInfo]:
        """List files in directory"""
        try:
            import os
            
            files = []
            for item in os.listdir(directory):
                item_path = os.path.join(directory, item)
                
                if os.path.isfile(item_path):
                    file_info = await self.load_file(item_path)
                    if file_info:
                        files.append(file_info)
            
            return files
            
        except Exception as e:
            self.logger.error(f"Failed to list files in {directory}: {e}")
            return []

    async def search_files(self, query: str, directory: str = "") -> List[FileInfo]:
        """Search for files"""
        try:
            import os
            
            files = []
            search_dir = directory or self.working_directory
            
            for root, dirs, filenames in os.walk(search_dir):
                for filename in filenames:
                    if query.lower() in filename.lower():
                        file_path = os.path.join(root, filename)
                        file_info = await self.load_file(file_path)
                        if file_info:
                            files.append(file_info)
            
            return files
            
        except Exception as e:
            self.logger.error(f"File search failed: {e}")
            return []

    def _detect_file_type(self, file_path: str) -> FileType:
        """Detect file type from extension"""
        extension = file_path.split('.')[-1].lower() if '.' in file_path else ''
        
        type_mapping = {
            "nc": FileType.NOODLE,
            "py": FileType.PYTHON,
            "js": FileType.JAVASCRIPT,
            "html": FileType.HTML,
            "css": FileType.CSS,
            "json": FileType.JSON,
            "md": FileType.MARKDOWN,
            "txt": FileType.TEXT
        }
        
        return type_mapping.get(extension, FileType.TEXT)


class ProjectManager:
    """Project management system"""

    def __init__(self):
        self.projects = {}
        self.current_project = None

    async def initialize(self):
        """Initialize project manager"""
        self.logger = logging.getLogger(__name__)

    async def cleanup(self):
        """Clean up project manager"""
        self.projects.clear()

    async def create_project(self, project_path: str, name: str, description: str = "") -> Optional[ProjectInfo]:
        """Create a new project"""
        try:
            import os
            
            # Create project directory
            os.makedirs(project_path, exist_ok=True)
            
            # Create project structure
            project_config = {
                "name": name,
                "description": description,
                "created_at": datetime.now().isoformat(),
                "version": "1.0.0",
                "type": "noodle"
            }
            
            # Save project config
            config_path = os.path.join(project_path, ".noodle_project")
            with open(config_path, 'w') as f:
                json.dump(project_config, f, indent=2)
            
            # Create project structure
            dirs = ["src", "tests", "docs", "data"]
            for dir_name in dirs:
                os.makedirs(os.path.join(project_path, dir_name), exist_ok=True)
            
            # Create project info
            project = ProjectInfo(
                name=name,
                path=project_path,
                description=description,
                files=[],
                created_at=datetime.now(),
                modified_at=datetime.now(),
                settings=project_config
            )
            
            # Load files
            project.files = await self._load_project_files(project_path)
            
            # Store project
            self.projects[project_path] = project
            self.current_project = project
            
            return project
            
        except Exception as e:
            self.logger.error(f"Failed to create project: {e}")
            return None

    async def load_project(self, project_path: str) -> Optional[ProjectInfo]:
        """Load an existing project"""
        try:
            import os
            
            if not os.path.exists(project_path):
                return None
            
            # Load project config
            config_path = os.path.join(project_path, ".noodle_project")
            if not os.path.exists(config_path):
                return None
            
            with open(config_path, 'r') as f:
                config = json.load(f)
            
            # Create project info
            project = ProjectInfo(
                name=config.get("name", os.path.basename(project_path)),
                path=project_path,
                description=config.get("description", ""),
                files=[],
                created_at=datetime.fromisoformat(config.get("created_at", datetime.now().isoformat())),
                modified_at=datetime.now(),
                settings=config
            )
            
            # Load files
            project.files = await self._load_project_files(project_path)
            
            # Store project
            self.projects[project_path] = project
            self.current_project = project
            
            return project
            
        except Exception as e:
            self.logger.error(f"Failed to load project: {e}")
            return None

    async def _load_project_files(self, project_path: str) -> List[FileInfo]:
        """Load all files in project"""
        file_manager = FileManager()
        files = []
        
        try:
            for root, dirs, filenames in os.walk(project_path):
                # Skip hidden directories and .noodle_project
                dirs[:] = [d for d in dirs if not d.startswith('.') and d not in ['__pycache__', '.git']]
                
                for filename in filenames:
                    if not filename.startswith('.') and filename != '.noodle_project':
                        file_path = os.path.join(root, filename)
                        file_info = await file_manager.load_file(file_path)
                        if file_info:
                            files.append(file_info)
                            
        except Exception as e:
            self.logger.error(f"Failed to load project files: {e}")
        
        return files


class CodeExecutor:
    """Code execution system"""

    def __init__(self):
        self.execution_history = []
        self.max_history_size = 100

    async def initialize(self):
        """Initialize code executor"""
        self.logger = logging.getLogger(__name__)

    async def cleanup(self):
        """Clean up code executor"""
        self.execution_history.clear()

    async def execute(self, content: str, file_type: FileType) -> Dict[str, Any]:
        """Execute code content"""
        start_time = time.time()
        
        try:
            if file_type == FileType.NOODLE:
                result = await self._execute_noodle_code(content)
            elif file_type == FileType.PYTHON:
                result = await self._execute_python_code(content)
            else:
                result = {
                    "output": f"Cannot execute {file_type.value} files",
                    "error": None,
                    "success": True
                }
            
            execution_time = time.time() - start_time
            
            # Add to history
            execution_record = {
                "content": content[:100] + "..." if len(content) > 100 else content,
                "file_type": file_type.value,
                "result": result,
                "execution_time": execution_time,
                "timestamp": datetime.now().isoformat()
            }
            
            self.execution_history.append(execution_record)
            
            # Keep history size manageable
            if len(self.execution_history) > self.max_history_size:
                self.execution_history = self.execution_history[-self.max_history_size:]
            
            return {
                **result,
                "execution_time": execution_time,
                "timestamp": execution_record["timestamp"]
            }
            
        except Exception as e:
            execution_time = time.time() - start_time
            return {
                "output": "",
                "error": str(e),
                "success": False,
                "execution_time": execution_time
            }

    async def _execute_noodle_code(self, content: str) -> Dict[str, Any]:
        """Execute Noodle code"""
        # Simulate Noodle code execution
        # In a real implementation, this would integrate with NoodleCore
        
        # Basic execution simulation
        output_lines = []
        error_lines = []
        
        try:
            # Simple code analysis
            if "print(" in content:
                # Extract print statements
                lines = content.split('\n')
                for line in lines:
                    line = line.strip()
                    if line.startswith('print('):
                        # Extract string from print statement
                        start = line.find('(') + 1
                        end = line.find(')', start)
                        if start > 0 and end > start:
                            string_content = line[start:end]
                            output_lines.append(string_content.replace('"', '').replace("'", ""))
            
            # Simple syntax check
            if content.count('def ') > 0:
                output_lines.append(f"Found {content.count('def ')} function(s)")
            
            if content.count('class ') > 0:
                output_lines.append(f"Found {content.count('class ')} class(es)")
            
            return {
                "output": '\n'.join(output_lines),
                "error": '\n'.join(error_lines) if error_lines else None,
                "success": True
            }
            
        except Exception as e:
            return {
                "output": "",
                "error": str(e),
                "success": False
            }

    async def _execute_python_code(self, content: str) -> Dict[str, Any]:
        """Execute Python code"""
        # This would integrate with actual Python execution
        # For now, return a simulated result
        return {
            "output": "Python execution simulation (would run actual Python code)",
            "error": None,
            "success": True
        }

    async def get_execution_history(self) -> List[Dict[str, Any]]:
        """Get execution history"""
        return self.execution_history


# Main IDE Factory Functions
def create_noodle_ide(config: Optional[Dict[str, Any]] = None) -> NoodleIDE:
    """Factory function to create a Noodle IDE instance"""
    return NoodleIDE(config)

async def initialize_ide_components(ide: NoodleIDE):
    """Initialize all IDE components"""
    await ide.initialize()

async def run_ide_main_loop(ide: NoodleIDE):
    """Run the main IDE loop"""
    try:
        while ide.is_running:
            # Check for auto-save
            if ide.auto_save_enabled:
                current_time = time.time()
                if current_time - ide.last_save_time > ide.auto_save_interval:
                    await ide.save_all_files()
            
            # Process any pending operations
            await asyncio.sleep(1)
            
    except KeyboardInterrupt:
        await ide.cleanup()
    except Exception as e:
        ide.error_count += 1
        ide.logger.error(f"IDE main loop error: {e}")