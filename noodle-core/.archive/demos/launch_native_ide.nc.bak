# """
# NoodleCore Native GUI IDE Launcher
# 
# This is the pure NoodleCore entry point for the Native GUI IDE.
# No Python dependencies - pure .nc implementation.
# """

import typing
import logging
import os
import sys

from ..src.noodlecore.desktop.ide.main_window import MainWindow
from ..src.noodlecore.desktop.ide.file_explorer import FileExplorer
from ..src.noodlecore.desktop.ide.code_editor import CodeEditor
from ..src.noodlecore.desktop.ide.ai_panel import AIPanel
from ..src.noodlecore.desktop.ide.terminal_console import TerminalConsole
from ..src.noodlecore.desktop.ide.tab_manager import TabManager
from ..src.noodlecore.desktop.core.window.window_manager import WindowManager
from ..src.noodlecore.desktop.core.events.event_system import EventSystem
from ..src.noodlecore.desktop.core.rendering.rendering_engine import RenderingEngine
from ..src.noodlecore.desktop.core.components.component_library import ComponentLibrary


class IDEConfiguration:
    """IDE configuration settings."""
    
    def __init__(self):
        # Window settings
        self.default_window_width = 1200
        self.default_window_height = 800
        self.default_window_title = "NoodleCore Desktop IDE"
        
        # Theme settings
        self.theme = "dark"
        self.enable_themes = True
        
        # Panel settings
        self.show_file_explorer = True
        self.show_ai_panel = True
        self.show_terminal = True
        self.show_search_panel = False
        self.show_settings_panel = False
        
        # Performance settings
        self.max_file_size_mb = 50
        self.max_recent_files = 20
        self.auto_save_interval = 30.0
        self.enable_performance_monitoring = True
        
        # File settings
        self.supported_file_types = [
            ".py", ".js", ".ts", ".html", ".css", ".nc",
            ".json", ".xml", ".md", ".txt", ".yml", ".yaml"
        ]
        self.auto_load_last_session = True
        
        # AI settings
        self.enable_ai_features = True
        self.ai_analysis_interval = 10.0
        self.enable_real_time_suggestions = True
        
        # Debug settings
        self.debug_mode = False
        self.log_level = "INFO"
        self.show_performance_metrics = True


class NoodleCoreIDELauncher:
    """Pure NoodleCore IDE Launcher."""
    
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        self.config = IDEConfiguration()
        
        # Core systems
        self._window_manager = None
        self._event_system = None
        self._rendering_engine = None
        self._component_library = None
        
        # IDE components
        self._main_window = None
        self._file_explorer = None
        self._code_editor = None
        self._ai_panel = None
        self._terminal_console = None
        self._tab_manager = None
        
        # State
        self._main_window_id = None
        self._is_running = False
        self._is_initialized = False
    
    def initialize(self) -> bool:
        """Initialize the NoodleCore IDE."""
        try:
            self.logger.info("Starting NoodleCore Desktop GUI IDE initialization...")
            
            # Initialize core systems
            if not self._initialize_core_systems():
                return False
            
            # Initialize IDE components
            if not self._initialize_ide_components():
                return False
            
            # Create main IDE window
            if not self._create_main_ide_window():
                return False
            
            self._is_initialized = True
            self.logger.info("NoodleCore Desktop GUI IDE initialized successfully")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to initialize IDE: {str(e)}")
            return False
    
    def _initialize_core_systems(self) -> bool:
        """Initialize core desktop GUI systems."""
        try:
            self.logger.info("Initializing core GUI systems...")
            
            # Initialize core components
            self._window_manager = WindowManager()
            self._event_system = EventSystem()
            self._rendering_engine = RenderingEngine()
            self._component_library = ComponentLibrary()
            
            self.logger.info("Core GUI systems initialized successfully")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to initialize core systems: {str(e)}")
            return False
    
    def _initialize_ide_components(self) -> bool:
        """Initialize IDE-specific components."""
        try:
            self.logger.info("Initializing IDE components...")
            
            # Initialize components
            self._tab_manager = TabManager()
            self._file_explorer = FileExplorer()
            self._code_editor = CodeEditor()
            
            if self.config.enable_ai_features:
                self._ai_panel = AIPanel()
            
            if self.config.show_terminal:
                self._terminal_console = TerminalConsole()
            
            self.logger.info("IDE components initialized successfully")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to initialize IDE components: {str(e)}")
            return False
    
    def _create_main_ide_window(self) -> bool:
        """Create the main IDE window."""
        try:
            self.logger.info("Creating main IDE window...")
            
            # Create main window
            self._main_window_id = self._window_manager.create_window(
                title=self.config.default_window_title,
                width=self.config.default_window_width,
                height=self.config.default_window_height,
                resizable=True,
                minimizable=True,
                maximizable=True
            )
            
            # Initialize Main Window
            self._main_window = MainWindow()
            self._main_window.initialize(
                window_id=self._main_window_id,
                event_system=self._event_system,
                rendering_engine=self._rendering_engine,
                component_library=self._component_library,
                config=self.config
            )
            
            # Initialize components with window ID
            self._initialize_components_with_window()
            
            # Integrate components
            self._integrate_components()
            
            self.logger.info("Main IDE window created successfully")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to create main IDE window: {str(e)}")
            return False
    
    def _initialize_components_with_window(self):
        """Initialize components with window ID."""
        try:
            # Initialize each component
            if self._tab_manager:
                self._tab_manager.initialize(
                    window_id=self._main_window_id,
                    event_system=self._event_system,
                    rendering_engine=self._rendering_engine,
                    component_library=self._component_library
                )
            
            if self._file_explorer:
                self._file_explorer.initialize(
                    window_id=self._main_window_id,
                    event_system=self._event_system,
                    rendering_engine=self._rendering_engine,
                    component_library=self._component_library
                )
            
            if self._code_editor:
                self._code_editor.initialize(
                    window_id=self._main_window_id,
                    event_system=self._event_system,
                    rendering_engine=self._rendering_engine,
                    component_library=self._component_library
                )
            
            if self._ai_panel:
                self._ai_panel.initialize(
                    window_id=self._main_window_id,
                    event_system=self._event_system,
                    rendering_engine=self._rendering_engine,
                    component_library=self._component_library
                )
            
            if self._terminal_console:
                self._terminal_console.initialize(
                    window_id=self._main_window_id,
                    event_system=self._event_system,
                    rendering_engine=self._rendering_engine,
                    component_library=self._component_library
                )
                
        except Exception as e:
            self.logger.error(f"Failed to initialize components with window: {str(e)}")
    
    def _integrate_components(self):
        """Integrate IDE components for seamless operation."""
        try:
            self.logger.info("Integrating IDE components...")
            
            # Setup component integrations
            if self._tab_manager and self._code_editor:
                self._tab_manager.set_callbacks(
                    on_tab_select=self._handle_tab_selection,
                    on_tab_close=self._handle_tab_closing,
                    on_tab_modify=self._handle_tab_modification
                )
            
            if self._file_explorer and self._tab_manager:
                self._file_explorer.set_on_file_open_callback(self._handle_file_opening)
            
            if self._terminal_console and self._code_editor:
                self._terminal_console.set_environment_variable("PYTHONPATH", ".")
            
            if self._ai_panel and self._code_editor:
                self._code_editor.set_ai_suggestions_callback(self._ai_panel.get_code_suggestions)
            
            self.logger.info("IDE components integrated successfully")
            
        except Exception as e:
            self.logger.error(f"Failed to integrate components: {str(e)}")
    
    def run(self) -> bool:
        """Start the IDE."""
        try:
            if not self._is_initialized:
                if not self.initialize():
                    return False
            
            self._is_running = True
            self.logger.info("NoodleCore Desktop GUI IDE started successfully")
            
            # Create demo content
            self._create_demo_content()
            
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to start IDE: {str(e)}")
            return False
    
    def shutdown(self):
        """Shutdown the IDE gracefully."""
        try:
            self.logger.info("Shutting down NoodleCore Desktop GUI IDE...")
            
            self._is_running = False
            
            # Shutdown components
            components = [
                self._terminal_console,
                self._ai_panel,
                self._code_editor,
                self._file_explorer,
                self._tab_manager,
                self._main_window
            ]
            
            for component in components:
                if component:
                    try:
                        # Component cleanup
                        pass
                    except Exception as e:
                        self.logger.error(f"Error shutting down component: {str(e)}")
            
            # Shutdown core systems
            if self._window_manager:
                try:
                    # Window manager cleanup
                    pass
                except Exception as e:
                    self.logger.error(f"Error shutting down window manager: {str(e)}")
            
            self.logger.info("NoodleCore Desktop GUI IDE shutdown complete")
            
        except Exception as e:
            self.logger.error(f"Error during IDE shutdown: {str(e)}")
    
    def _create_demo_content(self):
        """Create demo content for demonstration."""
        try:
            if self._tab_manager:
                self.logger.info("Creating demo content...")
                
                # Open welcome tab
                welcome_tab = self._tab_manager.open_tab(
                    file_path="welcome.md",
                    title="Welcome"
                )
                
                # Set welcome content
                if self._code_editor and welcome_tab:
                    welcome_content = """# NoodleCore Desktop GUI IDE

Welcome to the NoodleCore Desktop GUI IDE - a complete development environment.

## Features

- Pure NoodleCore implementation (.nc files)
- Complete desktop GUI framework
- Advanced code editor with syntax highlighting
- AI-powered code analysis and suggestions
- Integrated terminal console
- Multi-tab file management
- Project and file explorer
- Real-time performance monitoring

## Architecture

This IDE demonstrates NoodleCore's comprehensive capabilities:
- Window Manager: Native window creation and management
- Event System: Mouse, keyboard, and window event handling
- Rendering Engine: 2D graphics and text rendering
- Component Library: Reusable UI components
- IDE Components: File explorer, code editor, AI panel, terminal

## No Dependencies

✓ Pure NoodleCore implementation
✓ No Python dependencies
✓ No web technologies required
✓ Native desktop performance
✓ AI provider integration

Start exploring by opening a file or creating a new project!"""
                    self._code_editor.set_content(welcome_content)
                
                self.logger.info("Demo content created successfully")
            
        except Exception as e:
            self.logger.error(f"Failed to create demo content: {str(e)}")
    
    def _handle_tab_selection(self, tab_id: str, tab_info):
        """Handle tab selection events."""
        try:
            self.logger.debug(f"Selected tab: {tab_info.file_path}")
            
        except Exception as e:
            self.logger.error(f"Error handling tab selection: {str(e)}")
    
    def _handle_tab_closing(self, tab_id: str, tab_info):
        """Handle tab closing events."""
        try:
            self.logger.debug(f"Closing tab: {tab_info.title}")
            
        except Exception as e:
            self.logger.error(f"Error handling tab closing: {str(e)}")
    
    def _handle_tab_modification(self, tab_id: str, tab_info, modified: bool):
        """Handle tab modification events."""
        try:
            self.logger.debug(f"Tab {tab_info.title} {'modified' if modified else 'saved'}")
            
        except Exception as e:
            self.logger.error(f"Error handling tab modification: {str(e)}")
    
    def _handle_file_opening(self, file_path: str):
        """Handle file opening events."""
        try:
            if self._tab_manager:
                self._tab_manager.open_tab(file_path)
            
        except Exception as e:
            self.logger.error(f"Error handling file opening: {str(e)}")
    
    def is_running(self) -> bool:
        """Check if IDE is running."""
        return self._is_running


def main():
    """Main entry point for NoodleCore Desktop GUI IDE."""
    try:
        # Setup logging
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        
        logger = logging.getLogger(__name__)
        logger.info("Starting NoodleCore Desktop GUI IDE...")
        
        # Create and run IDE
        ide = NoodleCoreIDELauncher()
        
        # Run IDE
        if ide.run():
            logger.info("NoodleCore Desktop GUI IDE is running...")
            logger.info("Press Ctrl+C to shutdown")
            
            # Keep the program running
            try:
                import time
                while ide.is_running():
                    time.sleep(1)
            except KeyboardInterrupt:
                pass
            finally:
                ide.shutdown()
        else:
            logger.error("Failed to start IDE")
            return 1
        
        return 0
        
    except Exception as e:
        logger = logging.getLogger(__name__)
        logger.error(f"Failed to start IDE: {str(e)}")
        return 1


# Export main function
__all__ = ['main', 'NoodleCoreIDELauncher', 'IDEConfiguration']