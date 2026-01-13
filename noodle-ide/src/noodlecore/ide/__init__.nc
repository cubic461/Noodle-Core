# NoodleCore Integrated Development Environment
# Self-contained IDE built entirely in Noodle language

__version__ = "1.0.0"
__author__ = "NoodleCore Team"
__description__ = "Complete IDE built entirely in Noodle language"

# Core IDE components
from .noodle_ide import NoodleIDE, create_noodle_ide, initialize_ide_components, run_ide_main_loop
from .noodle_ide_ui import NOODLE_IDE_UI

# API and communication
from .api.noodle_api_client import NoodleAPIClient, APIResponse, FileInfo, ProjectInfo, create_api_client, test_noodle_core_connection

# File management
from .file.file_manager import FileManager, FileOperation, WatchEvent, FileWatchEvent, FileHistoryEntry

# Code analysis and editing
from .editor.code_analyzer import CodeAnalyzer, SyntaxToken, SyntaxError, CodeSuggestion, CodeMetrics, LanguageSupport

# UI components
from .ui.theme_manager import NOODLE_THEME_MANAGER, ThemeMode, ColorScheme, ThemeTokens
from .ui.event_system import NOODLE_EVENT_SYSTEM, EventType, IDEEvent, EventHandler

# Export configuration
IDE_CONFIG = {
    "name": "Noodle IDE",
    "version": __version__,
    "description": __description__,
    "author": __author__,
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

# Main factory functions
def create_noodle_ide_instance(config=None):
    """Create a complete Noodle IDE instance"""
    return create_noodle_ide(config)

def create_noodle_ide_ui(api_client=None):
    """Create Noodle IDE UI instance"""
    return NOODLE_IDE_UI(api_client)

def create_noodle_theme_manager():
    """Create theme manager instance"""
    return NOODLE_THEME_MANAGER()

def create_noodle_event_system():
    """Create event system instance"""
    return NOODLE_EVENT_SYSTEM()

def create_file_manager(api_client):
    """Create file manager instance"""
    return FileManager(api_client)

def create_code_analyzer():
    """Create code analyzer instance"""
    return CodeAnalyzer()

def create_api_client_instance(base_url="http://localhost:8080", timeout=30):
    """Create API client instance"""
    return create_api_client(base_url, timeout)

# Utility functions
async def test_ide_integration():
    """Test IDE integration with NoodleCore"""
    try:
        async with create_api_client() as api_client:
            # Test connection
            health_response = await api_client.health_check()
            
            # Test IDE endpoints (these would be added to the API)
            # ide_response = await api_client.get_status()
            
            return {
                "success": health_response.success,
                "api_connected": health_response.success,
                "noodle_core_status": health_response.data.get("status") if health_response.success else "unknown"
            }
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "noodle_core_status": "unreachable"
        }

def get_ide_version():
    """Get IDE version information"""
    return __version__

def get_ide_config():
    """Get IDE configuration"""
    return IDE_CONFIG.copy()

# Export all components
__all__ = [
    # Core IDE
    'NoodleIDE',
    'NOODLE_IDE_UI',
    
    # Factory functions
    'create_noodle_ide',
    'create_noodle_ide_instance', 
    'create_noodle_ide_ui',
    'initialize_ide_components',
    'run_ide_main_loop',
    
    # API client
    'NoodleAPIClient',
    'APIResponse',
    'FileInfo', 
    'ProjectInfo',
    'create_api_client',
    'create_api_client_instance',
    'test_noodle_core_connection',
    
    # File management
    'FileManager',
    'FileOperation',
    'WatchEvent',
    'FileWatchEvent',
    'FileHistoryEntry',
    
    # Code analysis
    'CodeAnalyzer',
    'SyntaxToken',
    'SyntaxError',
    'CodeSuggestion',
    'CodeMetrics',
    'LanguageSupport',
    
    # UI components
    'NOODLE_THEME_MANAGER',
    'ThemeMode',
    'ColorScheme',
    'ThemeTokens',
    
    # Event system
    'NOODLE_EVENT_SYSTEM',
    'EventType',
    'IDEEvent',
    'EventHandler',
    
    # Utilities
    'IDE_CONFIG',
    'test_ide_integration',
    'get_ide_version',
    'get_ide_config'
]

# IDE initialization message
def print_ide_banner():
    """Print IDE initialization banner"""
    banner = f"""
╔══════════════════════════════════════════════════════════════╗
║                    NOODLE IDE v{__version__}                        ║
║                                                              ║
║  Built entirely in Noodle language for true language         ║
║  independence. Complete development environment powered      ║
║  by NoodleCore APIs.                                        ║
║                                                              ║
║  Features: Syntax highlighting, Code completion,            ║
║  File management, Project management, Code execution,       ║
║  Real-time editing, Error detection, Auto save              ║
║                                                              ║
║  Author: {__author__:<52} ║
╚══════════════════════════════════════════════════════════════╝
    """
    print(banner)

# Auto-initialization
if __name__ == "__main__":
    print_ide_banner()
    print("Noodle IDE is ready!")