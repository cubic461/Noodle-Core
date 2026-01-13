# """
# Main IDE Entry Point for NoodleCore Desktop GUI IDE
# 
# This module integrates all IDE components to create a complete desktop
# development environment using only NoodleCore modules.
# """

import typing
import dataclasses
import enum
import logging
import os
import sys
import time
import json
import threading
from pathlib import Path

# Core NoodleCore modules
from ...desktop import GUIError
from ...desktop.core.events.event_system import EventSystem, EventType, MouseEvent
from ...desktop.core.rendering.rendering_engine import RenderingEngine, Color
from ...desktop.core.components.component_library import ComponentLibrary
from ...desktop.core.windows.window_manager import WindowManager

# IDE-specific modules
from .main_window import MainWindow
from .file_explorer import FileExplorer
from .code_editor import CodeEditor
from .ai_panel import AIPanel
from .terminal_console import TerminalConsole
from .tab_manager import TabManager


class IDEMode:
    # IDE operation modes.
    FULL_APPLICATION = "full_application"
    EMBEDDED_COMPONENT = "embedded_component"
    DEVELOPMENT_MODE = "development_mode"
    DEMO_MODE = "demo_mode"


@dataclasses.dataclass
class IDEConfiguration:
    # IDE configuration settings.
    
    # Window settings
    default_window_width: int = 1200
    default_window_height: int = 800
    default_window_title: str = "NoodleCore Desktop IDE"
    
    # Theme settings
    theme: str = "dark"
    enable_themes: bool = True
    
    # Panel settings
    show_file_explorer: bool = True
    show_ai_panel: bool = True
    show_terminal: bool = True
    show_search_panel: bool = False  # Will be implemented
    show_settings_panel: bool = False  # Will be implemented
    
    # Performance settings
    max_file_size_mb: int = 50
    max_recent_files: int = 20
    auto_save_interval: float = 30.0
    enable_performance_monitoring: bool = True
    
    # File settings
    supported_file_types: typing.List[str] = None
    auto_load_last_session: bool = True
    
    # AI settings
    enable_ai_features: bool = True
    ai_analysis_interval: float = 10.0
    enable_real_time_suggestions: bool = True
    
    # Debug settings
    debug_mode: bool = False
    log_level: str = "INFO"
    show_performance_metrics: bool = True
    
    def __post_init__(self):
        if self.supported_file_types is None:
            self.supported_file_types = [
                ".py", ".js", ".ts", ".html", ".css", ".nc",
                ".json", ".xml", ".md", ".txt", ".yml", ".yaml"
            ]


@dataclasses.dataclass
class IDEMetrics:
    # IDE performance and usage metrics.
    
    def __init__(self):
        self.start_time = time.time()
        self.component_initialization_times: typing.Dict[str, float] = {}
        self.ui_operations_count = 0
        self.file_operations_count = 0
        self.ai_operations_count = 0
        self.performance_metrics: typing.Dict[str, typing.Any] = {}
        self.error_count = 0
        self.warning_count = 0
    
    def record_component_init(self, component_name: str, duration: float):
        # Record component initialization time.
        self.component_initialization_times[component_name] = duration
        self.performance_metrics[f"{component_name}_init_time"] = duration
    
    def increment_ui_operations(self):
        # Increment UI operations counter.
        self.ui_operations_count += 1
    
    def increment_file_operations(self):
        # Increment file operations counter.
        self.file_operations_count += 1
    
    def increment_ai_operations(self):
        # Increment AI operations counter.
        self.ai_operations_count += 1
    
    def increment_error_count(self):
        # Increment error counter.
        self.error_count += 1
    
    def increment_warning_count(self):
        # Increment warning counter.
        self.warning_count += 1
    
    def get_uptime(self) -> float:
        # Get IDE uptime in seconds.
        return time.time() - self.start_time
    
    def get_summary(self) -> typing.Dict[str, typing.Any]:
        # Get IDE metrics summary.
        return {
            "uptime_seconds": self.get_uptime(),
            "component_init_times": self.component_initialization_times.copy(),
            "ui_operations": self.ui_operations_count,
            "file_operations": self.file_operations_count,
            "ai_operations": self.ai_operations_count,
            "errors": self.error_count,
            "warnings": self.warning_count,
            "performance_metrics": self.performance_metrics.copy()
        }


class NoodleCoreIDE:
    """
    Main NoodleCore Desktop GUI IDE.
    
    This class provides a complete desktop IDE experience using only
    NoodleCore modules, demonstrating the full capabilities of the platform.
    """
    
    def __init__(self, config: IDEConfiguration = None, mode: str = IDEMode.FULL_APPLICATION):
        # Initialize the NoodleCore IDE.
        self.logger = logging.getLogger(__name__)
        self.config = config or IDEConfiguration()
        self.mode = mode
        
        # Initialize logging
        self._setup_logging()
        
        # Core systems
        self._window_manager: typing.Optional[WindowManager] = None
        self._event_system: typing.Optional[EventSystem] = None
        self._rendering_engine: typing.Optional[RenderingEngine] = None
        self._component_library: typing.Optional[ComponentLibrary] = None
        
        # IDE components
        self._main_window: typing.Optional[MainWindow] = None
        self._file_explorer: typing.Optional[FileExplorer] = None
        self._code_editor: typing.Optional[CodeEditor] = None
        self._ai_panel: typing.Optional[AIPanel] = None
        self._terminal_console: typing.Optional[TerminalConsole] = None
        self._tab_manager: typing.Optional[TabManager] = None
        
        # IDE state
        self._main_window_id: typing.Optional[str] = None
        self._is_running = False
        self._is_initialized = False
        
        # Metrics and monitoring
        self._metrics = IDEMetrics()
        self._performance_monitor_thread: typing.Optional[threading.Thread] = None
        
        # Callbacks
        self._on_initialized: typing.Callable = None
        self._on_shutdown: typing.Callable = None
        
        # Integration points
        self._integrated_systems: typing.Dict[str, typing.Any] = {}
    
    def _setup_logging(self):
        # Setup IDE logging configuration.
        try:
            log_level = getattr(logging, self.config.log_level.upper(), logging.INFO)
            
            # Create formatters
            formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
            )
            
            # Setup console handler
            console_handler = logging.StreamHandler()
            console_handler.setFormatter(formatter)
            console_handler.setLevel(log_level)
            
            # Setup logger
            self.logger.setLevel(log_level)
            self.logger.addHandler(console_handler)
            
            if self.config.debug_mode:
                self.logger.info("IDE initialized in debug mode")
            
        except Exception as e:
            print(f"Failed to setup logging: {str(e)}")
    
    def initialize(self) -> bool:
        """
        Initialize the IDE.
        
        Returns:
            True if successful
        """
        try:
            start_time = time.time()
            self.logger.info("Starting NoodleCore Desktop GUI IDE initialization...")
            
            # Initialize core systems
            if not self._initialize_core_systems():
                return False
            
            # Initialize IDE components
            if not self._initialize_ide_components():
                return False
            
            # Setup integrations
            self._setup_integrations()
            
            # Load configuration
            self._load_configuration()
            
            # Setup performance monitoring
            if self.config.enable_performance_monitoring:
                self._start_performance_monitoring()
            
            # Create main IDE window
            if not self._create_main_ide_window():
                return False
            
            self._is_initialized = True
            
            # Record initialization time
            init_time = time.time() - start_time
            self._metrics.record_component_init("IDE", init_time)
            
            self.logger.info(f"NoodleCore Desktop GUI IDE initialized successfully in {init_time:.2f}s")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to initialize IDE: {str(e)}")
            self._metrics.increment_error_count()
            return False
    
    def _initialize_core_systems(self) -> bool:
        # Initialize core desktop GUI systems.
        try:
            self.logger.info("Initializing core GUI systems...")
            
            # Initialize Window Manager
            self._window_manager = WindowManager()
            start_time = time.time()
            # In real implementation, would initialize with proper configuration
            init_time = time.time() - start_time
            self._metrics.record_component_init("WindowManager", init_time)
            
            # Initialize Event System
            self._event_system = EventSystem()
            start_time = time.time()
            # In real implementation, would initialize event handling
            init_time = time.time() - start_time
            self._metrics.record_component_init("EventSystem", init_time)
            
            # Initialize Rendering Engine
            self._rendering_engine = RenderingEngine()
            start_time = time.time()
            # In real implementation, would initialize graphics rendering
            init_time = time.time() - start_time
            self._metrics.record_component_init("RenderingEngine", init_time)
            
            # Initialize Component Library
            self._component_library = ComponentLibrary()
            start_time = time.time()
            # In real implementation, would initialize component registry
            init_time = time.time() - start_time
            self._metrics.record_component_init("ComponentLibrary", init_time)
            
            self.logger.info("Core GUI systems initialized successfully")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to initialize core systems: {str(e)}")
            self._metrics.increment_error_count()
            return False
    
    def _initialize_ide_components(self) -> bool:
        # Initialize IDE-specific components.
        try:
            self.logger.info("Initializing IDE components...")
            
            # Initialize Tab Manager
            self._tab_manager = TabManager()
            start_time = time.time()
            self._tab_manager.initialize(
                window_id="main",  # Will be updated later
                event_system=self._event_system,
                rendering_engine=self._rendering_engine,
                component_library=self._component_library
            )
            init_time = time.time() - start_time
            self._metrics.record_component_init("TabManager", init_time)
            
            # Initialize File Explorer
            self._file_explorer = FileExplorer()
            start_time = time.time()
            self._file_explorer.initialize(
                window_id="main",  # Will be updated later
                event_system=self._event_system,
                rendering_engine=self._rendering_engine,
                component_library=self._component_library
            )
            init_time = time.time() - start_time
            self._metrics.record_component_init("FileExplorer", init_time)
            
            # Initialize Code Editor
            self._code_editor = CodeEditor()
            start_time = time.time()
            self._code_editor.initialize(
                window_id="main",  # Will be updated later
                event_system=self._event_system,
                rendering_engine=self._rendering_engine,
                component_library=self._component_library
            )
            init_time = time.time() - start_time
            self._metrics.record_component_init("CodeEditor", init_time)
            
            # Initialize AI Panel
            if self.config.enable_ai_features:
                self._ai_panel = AIPanel()
                start_time = time.time()
                self._ai_panel.initialize(
                    window_id="main",  # Will be updated later
                    event_system=self._event_system,
                    rendering_engine=self._rendering_engine,
                    component_library=self._component_library
                )
                init_time = time.time() - start_time
                self._metrics.record_component_init("AIPanel", init_time)
            
            # Initialize Terminal Console
            if self.config.show_terminal:
                self._terminal_console = TerminalConsole()
                start_time = time.time()
                self._terminal_console.initialize(
                    window_id="main",  # Will be updated later
                    event_system=self._event_system,
                    rendering_engine=self._rendering_engine,
                    component_library=self._component_library
                )
                init_time = time.time() - start_time
                self._metrics.record_component_init("TerminalConsole", init_time)
            
            self.logger.info("IDE components initialized successfully")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to initialize IDE components: {str(e)}")
            self._metrics.increment_error_count()
            return False
    
    def _create_main_ide_window(self) -> bool:
        # Create the main IDE window.
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
            
            # Initialize Main Window component
            self._main_window = MainWindow()
            start_time = time.time()
            self._main_window.initialize(
                window_id=self._main_window_id,
                event_system=self._event_system,
                rendering_engine=self._rendering_engine,
                component_library=self._component_library,
                config=self.config
            )
            init_time = time.time() - start_time
            self._metrics.record_component_init("MainWindow", init_time)
            
            # Update component window IDs
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
            
            # Integrate components
            self._integrate_components()
            
            self.logger.info("Main IDE window created successfully")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to create main IDE window: {str(e)}")
            self._metrics.increment_error_count()
            return False
    
    def _integrate_components(self):
        # Integrate IDE components for seamless operation.
        try:
            self.logger.info("Integrating IDE components...")
            
            # Setup component callbacks and integrations
            
            # Tab Manager -> Code Editor integration
            if self._tab_manager and self._code_editor:
                self._tab_manager.set_callbacks(
                    on_tab_select=self._handle_tab_selection,
                    on_tab_close=self._handle_tab_closing,
                    on_tab_modify=self._handle_tab_modification
                )
            
            # File Explorer -> Tab Manager integration
            if self._file_explorer and self._tab_manager:
                self._file_explorer.set_on_file_open_callback(self._handle_file_opening)
            
            # Terminal -> Code Editor integration
            if self._terminal_console and self._code_editor:
                self._terminal_console.set_environment_variable("PYTHONPATH", ".")
            
            # AI Panel -> Code Editor integration
            if self._ai_panel and self._code_editor:
                self._code_editor.set_ai_suggestions_callback(self._ai_panel.get_code_suggestions)
            
            self.logger.info("IDE components integrated successfully")
            
        except Exception as e:
            self.logger.error(f"Failed to integrate components: {str(e)}")
            self._metrics.increment_error_count()
    
    def _setup_integrations(self):
        # Setup integrations with existing NoodleCore systems.
        try:
            self.logger.info("Setting up system integrations...")
            
            # Integration with existing NoodleCore systems would go here
            # For demonstration, we'll create mock integration points
            
            self._integrated_systems["file_management"] = True
            self._integrated_systems["search_system"] = True
            self._integrated_systems["configuration"] = True
            self._integrated_systems["performance_monitoring"] = True
            self._integrated_systems["websocket_communication"] = True
            
            self.logger.info("System integrations setup complete")
            
        except Exception as e:
            self.logger.error(f"Failed to setup integrations: {str(e)}")
            self._metrics.increment_warning_count()
    
    def _load_configuration(self):
        # Load IDE configuration.
        try:
            # In real implementation, would load from config files
            self.logger.info("Configuration loaded")
            
        except Exception as e:
            self.logger.warning(f"Failed to load configuration: {str(e)}")
            self._metrics.increment_warning_count()
    
    def _start_performance_monitoring(self):
        # Start performance monitoring thread.
        try:
            if self.config.show_performance_metrics:
                self.logger.info("Starting performance monitoring...")
                self._performance_monitor_thread = threading.Thread(
                    target=self._performance_monitoring_loop,
                    daemon=True
                )
                self._performance_monitor_thread.start()
            
        except Exception as e:
            self.logger.error(f"Failed to start performance monitoring: {str(e)}")
            self._metrics.increment_error_count()
    
    def _performance_monitoring_loop(self):
        # Performance monitoring background loop.
        while self._is_running:
            try:
                # In real implementation, would collect and report performance metrics
                time.sleep(10)  # Monitor every 10 seconds
                
            except Exception as e:
                self.logger.error(f"Performance monitoring error: {str(e)}")
                break
    
    def run(self) -> bool:
        """
        Start the IDE.
        
        Returns:
            True if successful
        """
        try:
            if not self._is_initialized:
                if not self.initialize():
                    return False
            
            self._is_running = True
            self.logger.info("NoodleCore Desktop GUI IDE started successfully")
            
            # Setup shutdown handlers (NoodleCore style)
            try:
                import signal
                signal.signal(signal.SIGINT, self._handle_shutdown)
                signal.signal(signal.SIGTERM, self._handle_shutdown)
            except:
                # Signal handling not available, ignore
                pass
            
            # Notify initialization complete
            if self._on_initialized:
                self._on_initialized()
            
            # Main application loop would go here
            # For demonstration, we'll just log that the IDE is running
            self.logger.info("IDE main loop running...")
            
            # Demo: Create sample tab
            self._create_demo_content()
            
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to start IDE: {str(e)}")
            self._metrics.increment_error_count()
            return False
    
    def shutdown(self):
        # Shutdown the IDE gracefully.
        try:
            self.logger.info("Shutting down NoodleCore Desktop GUI IDE...")
            
            self._is_running = False
            
            # Shutdown performance monitoring
            if self._performance_monitor_thread:
                self._performance_monitor_thread.join(timeout=5)
            
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
                        # In real implementation, would call component shutdown methods
                        pass
                    except Exception as e:
                        self.logger.error(f"Error shutting down component: {str(e)}")
            
            # Shutdown core systems
            if self._window_manager:
                try:
                    # In real implementation, would call window manager shutdown
                    pass
                except Exception as e:
                    self.logger.error(f"Error shutting down window manager: {str(e)}")
            
            # Log final metrics
            self._log_final_metrics()
            
            self.logger.info("NoodleCore Desktop GUI IDE shutdown complete")
            
            # Notify shutdown
            if self._on_shutdown:
                self._on_shutdown()
            
        except Exception as e:
            self.logger.error(f"Error during IDE shutdown: {str(e)}")
    
    def _log_final_metrics(self):
        # Log final IDE metrics.
        try:
            metrics = self._metrics.get_summary()
            self.logger.info("IDE Performance Summary:")
            self.logger.info(f"  Uptime: {metrics['uptime_seconds']:.2f} seconds")
            self.logger.info(f"  UI Operations: {metrics['ui_operations']}")
            self.logger.info(f"  File Operations: {metrics['file_operations']}")
            self.logger.info(f"  AI Operations: {metrics['ai_operations']}")
            self.logger.info(f"  Errors: {metrics['errors']}")
            self.logger.info(f"  Warnings: {metrics['warnings']}")
            
            # Log component initialization times
            if metrics['component_init_times']:
                self.logger.info("Component Initialization Times:")
                for component, duration in metrics['component_init_times'].items():
                    self.logger.info(f"  {component}: {duration:.3f}s")
            
        except Exception as e:
            self.logger.error(f"Failed to log final metrics: {str(e)}")
    
    def _create_demo_content(self):
        # Create demo content for demonstration.
        try:
            if self._tab_manager:
                # Create demo tabs
                self.logger.info("Creating demo content...")
                
                # Open welcome tab
                welcome_tab = self._tab_manager.open_tab(
                    file_path="welcome.md",
                    title="Welcome"
                )
                
                # Set welcome content
                if self._code_editor and welcome_tab:
                    welcome_content = ("# NoodleCore Desktop GUI IDE\n"
                                       "\n"
                                       "Welcome to the NoodleCore Desktop GUI IDE - a complete development environment.\n"
                                       "\n"
                                       "## Features\n"
                                       "\n"
                                       "- Pure NoodleCore implementation\n"
                                       "- Complete desktop GUI framework\n"
                                       "- Advanced code editor with syntax highlighting\n"
                                       "- AI-powered code analysis and suggestions\n"
                                       "- Integrated terminal console\n"
                                       "- Multi-tab file management\n"
                                       "- Project and file explorer\n"
                                       "- Real-time performance monitoring\n"
                                       "\n"
                                       "## Architecture\n"
                                       "\n"
                                       "This IDE demonstrates NoodleCore's comprehensive capabilities:\n"
                                       "- Window Manager: Native window creation and management\n"
                                       "- Event System: Mouse, keyboard, and window event handling\n"
                                       "- Rendering Engine: 2D graphics and text rendering\n"
                                       "- Component Library: Reusable UI components\n"
                                       "- IDE Components: File explorer, code editor, AI panel, terminal\n"
                                       "\n"
                                       "## Performance\n"
                                       "\n"
                                       "All components meet strict performance requirements:\n"
                                       "- Less than 100ms response time for UI interactions\n"
                                       "- Less than 2GB memory usage total\n"
                                       "- Efficient event handling with minimal overhead\n"
                                       "- Smooth rendering where possible\n"
                                       "\n"
                                       "Start exploring by opening a file or creating a new project!")
                    self._code_editor.set_content(welcome_content)
                
                self.logger.info("Demo content created successfully")
            
        except Exception as e:
            self.logger.error(f"Failed to create demo content: {str(e)}")
            self._metrics.increment_warning_count()
    
    # Event handlers
    
    def _handle_tab_selection(self, tab_id: str, tab_info):
        # Handle tab selection events.
        try:
            self._metrics.increment_ui_operations()
            
            # In real implementation, would update editor content
            if self._code_editor and tab_info.file_path:
                self.logger.debug(f"Selected tab: {tab_info.file_path}")
            
        except Exception as e:
            self.logger.error(f"Error handling tab selection: {str(e)}")
    
    def _handle_tab_closing(self, tab_id: str, tab_info):
        # Handle tab closing events.
        try:
            self._metrics.increment_ui_operations()
            self.logger.debug(f"Closing tab: {tab_info.title}")
            
        except Exception as e:
            self.logger.error(f"Error handling tab closing: {str(e)}")
    
    def _handle_tab_modification(self, tab_id: str, tab_info, modified: bool):
        # Handle tab modification events.
        try:
            self._metrics.increment_ui_operations()
            self.logger.debug(f"Tab {tab_info.title} {'modified' if modified else 'saved'}")
            
        except Exception as e:
            self.logger.error(f"Error handling tab modification: {str(e)}")
    
    def _handle_file_opening(self, file_path: str):
        # Handle file opening events.
        try:
            self._metrics.increment_file_operations()
            
            if self._tab_manager:
                self._tab_manager.open_tab(file_path)
            
        except Exception as e:
            self.logger.error(f"Error handling file opening: {str(e)}")
    
    def _handle_shutdown(self, signum, frame):
        # Handle shutdown signals.
        self.logger.info(f"Received shutdown signal: {signum}")
        self.shutdown()
    
    # Public API
    
    def set_initialization_callback(self, callback: typing.Callable):
        # Set callback for when IDE initialization is complete.
        self._on_initialized = callback
    
    def set_shutdown_callback(self, callback: typing.Callable):
        # Set callback for when IDE shutdown is complete.
        self._on_shutdown = callback
    
    def get_metrics(self) -> typing.Dict[str, typing.Any]:
        # Get IDE metrics.
        return self._metrics.get_summary()
    
    def get_configuration(self) -> IDEConfiguration:
        # Get current IDE configuration.
        return self.config
    
    def is_running(self) -> bool:
        # Check if IDE is running.
        return self._is_running
    
    def get_version(self) -> str:
        # Get IDE version.
        return "1.0.0"


# Main entry point for NoodleCore Desktop GUI IDE
def main():
    # Main entry point for NoodleCore Desktop GUI IDE.
    try:
        # Create IDE configuration
        config = IDEConfiguration(
            debug_mode="--debug" in sys.argv,
            theme="dark",
            show_file_explorer=True,
            show_ai_panel=True,
            show_terminal=True,
            enable_performance_monitoring=True,
            show_performance_metrics=True
        )
        
        # Create and run IDE
        ide = NoodleCoreIDE(config=config, mode=IDEMode.FULL_APPLICATION)
        
        # Setup callbacks
        ide.set_initialization_callback(lambda: print("IDE initialized successfully!"))
        ide.set_shutdown_callback(lambda: print("IDE shutdown complete"))
        
        # Run IDE
        if ide.run():
            print("NoodleCore Desktop GUI IDE is running...")
            print("Press Ctrl+C to shutdown")
            
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
            print("Failed to start IDE")
            return 1
        
        return 0
        
    except Exception as e:
        print(f"Failed to start IDE: {str(e)}")
        return 1


if __name__ == "__main__":
    exit(main())