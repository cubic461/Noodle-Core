# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Main IDE Entry Point for NoodleCore Desktop GUI IDE - Integrated Version

# This module integrates all IDE components with backend systems to create a complete
# desktop development environment using NoodleCore modules and APIs.
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
import pathlib.Path

# Core NoodleCore modules
import ...desktop.GUIError
import ...desktop.core.events.event_system.EventSystem,
import ...desktop.core.rendering.rendering_engine.RenderingEngine,
import ...desktop.core.components.component_library.ComponentLibrary
import ...desktop.core.windows.window_manager.WindowManager

# Integrated IDE-specific modules
import .file_explorer_integrated.IntegratedFileExplorer,
import .ai_panel_integrated.IntegratedAIPanel,
import .terminal_console_integrated.IntegratedTerminalConsole,
import .integration.system_integrator.NoodleCoreSystemIntegrator

# Additional IDE components (using existing implementations)
import .main_window.MainWindow
import .tab_manager.TabManager
import .code_editor.CodeEditor


class IntegratedIDEMode(Enum)
    #     """IDE operation modes for integrated system."""
    FULL_APPLICATION = "full_application"
    EMBEDDED_COMPONENT = "embedded_component"
    DEVELOPMENT_MODE = "development_mode"
    DEMO_MODE = "demo_mode"
    INTEGRATED_MODE = "integrated_mode"


# @dataclasses.dataclass
class IntegratedIDEConfiguration
    #     """Integrated IDE configuration settings."""
    #     # Window settings
    default_window_width: int = 1200
    default_window_height: int = 800
    default_window_title: str = "NoodleCore Desktop IDE - Integrated"

    #     # Integration settings
    use_backend_api: bool = True
    backend_api_url: str = "http://localhost:8080"
    enable_real_time_sync: bool = True
    auto_connect_backend: bool = True

    #     # Panel settings
    show_file_explorer: bool = True
    show_ai_panel: bool = True
    show_terminal: bool = True
    show_search_panel: bool = False  # Will be implemented
    show_settings_panel: bool = False  # Will be implemented

    #     # Performance settings
    max_file_size_mb: int = 50
    max_recent_files: int = 20
    auto_save_interval: float = 30.0
    enable_performance_monitoring: bool = True

    #     # File settings
    supported_file_types: typing.List[str] = None
    auto_load_last_session: bool = True

    #     # AI settings
    enable_ai_features: bool = True
    ai_analysis_interval: float = 10.0
    enable_real_time_suggestions: bool = True

    #     # Terminal settings
    enable_terminal_features: bool = True
    terminal_timeout: float = 30.0
    enable_command_history: bool = True

    #     # File system settings
    enable_file_operations: bool = True
    auto_refresh_file_tree: bool = True

    #     # Debug settings
    debug_mode: bool = False
    log_level: str = "INFO"
    show_performance_metrics: bool = True
    enable_detailed_logging: bool = False

    #     def __post_init__(self):
    #         if self.supported_file_types is None:
    self.supported_file_types = [
    #                 ".py", ".js", ".ts", ".html", ".css", ".nc",
    #                 ".json", ".xml", ".md", ".txt", ".yml", ".yaml"
    #             ]


# @dataclasses.dataclass
class IntegratedIDEMetrics
    #     """Integrated IDE performance and usage metrics."""

    #     def __init__(self):
    self.start_time = time.time()
    self.component_initialization_times: typing.Dict[str, float] = {}
    self.ui_operations_count = 0
    self.file_operations_count = 0
    self.ai_operations_count = 0
    self.terminal_operations_count = 0
    self.api_operations_count = 0
    self.backend_operations_count = 0
    self.performance_metrics: typing.Dict[str, typing.Any] = {}
    self.error_count = 0
    self.warning_count = 0
    self.integration_metrics: typing.Dict[str, typing.Any] = {}

    #     def record_component_init(self, component_name: str, duration: float):
    #         """Record component initialization time."""
    self.component_initialization_times[component_name] = duration
    self.performance_metrics[f"{component_name}_init_time"] = duration

    #     def increment_ui_operations(self):
    #         """Increment UI operations counter."""
    self.ui_operations_count + = 1

    #     def increment_file_operations(self):
    #         """Increment file operations counter."""
    self.file_operations_count + = 1

    #     def increment_ai_operations(self):
    #         """Increment AI operations counter."""
    self.ai_operations_count + = 1

    #     def increment_terminal_operations(self):
    #         """Increment terminal operations counter."""
    self.terminal_operations_count + = 1

    #     def increment_api_operations(self):
    #         """Increment API operations counter."""
    self.api_operations_count + = 1

    #     def increment_backend_operations(self):
    #         """Increment backend operations counter."""
    self.backend_operations_count + = 1

    #     def increment_error_count(self):
    #         """Increment error counter."""
    self.error_count + = 1

    #     def increment_warning_count(self):
    #         """Increment warning counter."""
    self.warning_count + = 1

    #     def get_uptime(self) -> float:
    #         """Get IDE uptime in seconds."""
            return time.time() - self.start_time

    #     def get_summary(self) -> typing.Dict[str, typing.Any]:
    #         """Get IDE metrics summary."""
    #         return {
                "uptime_seconds": self.get_uptime(),
                "component_init_times": self.component_initialization_times.copy(),
    #             "ui_operations": self.ui_operations_count,
    #             "file_operations": self.file_operations_count,
    #             "ai_operations": self.ai_operations_count,
    #             "terminal_operations": self.terminal_operations_count,
    #             "api_operations": self.api_operations_count,
    #             "backend_operations": self.backend_operations_count,
    #             "errors": self.error_count,
    #             "warnings": self.warning_count,
                "performance_metrics": self.performance_metrics.copy(),
                "integration_metrics": self.integration_metrics.copy()
    #         }


class IntegratedNoodleCoreIDE
    #     """
    #     Integrated NoodleCore Desktop GUI IDE.

    #     This class provides a complete integrated desktop IDE experience using
    #     NoodleCore modules with full backend API integration.
    #     """

    #     def __init__(self, config: IntegratedIDEConfiguration = None, mode: IntegratedIDEMode = IntegratedIDEMode.INTEGRATED_MODE):
    #         """Initialize the integrated IDE."""
    self.logger = logging.getLogger(__name__)
    self.config = config or IntegratedIDEConfiguration()
    self.mode = mode

    #         # Initialize logging
            self._setup_logging()

    #         # Core systems
    self._window_manager: typing.Optional[WindowManager] = None
    self._event_system: typing.Optional[EventSystem] = None
    self._rendering_engine: typing.Optional[RenderingEngine] = None
    self._component_library: typing.Optional[ComponentLibrary] = None

    #         # System integrator
    self._system_integrator: typing.Optional[NoodleCoreSystemIntegrator] = None

    #         # Integrated IDE components
    self._file_explorer: typing.Optional[IntegratedFileExplorer] = None
    self._ai_panel: typing.Optional[IntegratedAIPanel] = None
    self._terminal_console: typing.Optional[IntegratedTerminalConsole] = None

    #         # Additional IDE components
    self._main_window: typing.Optional[MainWindow] = None
    self._tab_manager: typing.Optional[TabManager] = None
    self._code_editor: typing.Optional[CodeEditor] = None

    #         # IDE state
    self._main_window_id: typing.Optional[str] = None
    self._is_running = False
    self._is_initialized = False
    self._backend_connected = False

    #         # Metrics and monitoring
    self._metrics = IntegratedIDEMetrics()
    self._performance_monitor_thread: typing.Optional[threading.Thread] = None

    #         # Callbacks
    self._on_initialized: typing.Callable = None
    self._on_shutdown: typing.Callable = None
    self._on_backend_connected: typing.Callable = None
    self._on_backend_disconnected: typing.Callable = None

    #         # Integration status
    self._integration_status = {
    #             "system_integrator": False,
    #             "file_explorer": False,
    #             "ai_panel": False,
    #             "terminal_console": False,
    #             "main_window": False,
    #             "tab_manager": False,
    #             "code_editor": False,
    #             "backend_api": False
    #         }

    #     def _setup_logging(self):
    #         """Setup IDE logging configuration."""
    #         try:
    log_level = getattr(logging, self.config.log_level.upper(), logging.INFO)

    #             # Create formatters
    formatter = logging.Formatter(
                    '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    #             )

    #             # Setup console handler
    console_handler = logging.StreamHandler()
                console_handler.setFormatter(formatter)
                console_handler.setLevel(log_level)

    #             # Setup logger
                self.logger.setLevel(log_level)
                self.logger.addHandler(console_handler)

    #             if self.config.debug_mode:
                    self.logger.info("IDE initialized in debug mode")

    #         except Exception as e:
                print(f"Failed to setup logging: {str(e)}")

    #     def initialize(self) -> bool:
    #         """
    #         Initialize the IDE.

    #         Returns:
    #             True if successful
    #         """
    #         try:
    start_time = time.time()
                self.logger.info("Starting NoodleCore Desktop GUI IDE (Integrated) initialization...")

    #             # Initialize core systems
    #             if not self._initialize_core_systems():
    #                 return False

    #             # Initialize system integrator
    #             if not self._initialize_system_integrator():
    #                 return False

    #             # Initialize integrated components
    #             if not self._initialize_integrated_components():
    #                 return False

    #             # Initialize additional components
    #             if not self._initialize_additional_components():
    #                 return False

    #             # Setup all integrations
                self._setup_all_integrations()

    #             # Load configuration
                self._load_configuration()

    #             # Setup performance monitoring
    #             if self.config.enable_performance_monitoring:
                    self._start_performance_monitoring()

    #             # Create main IDE window
    #             if not self._create_main_ide_window():
    #                 return False

    self._is_initialized = True

    #             # Record initialization time
    init_time = math.subtract(time.time(), start_time)
                self._metrics.record_component_init("IntegratedIDE", init_time)

                self.logger.info(f"NoodleCore Desktop GUI IDE (Integrated) initialized successfully in {init_time:.2f}s")
    #             return True

    #         except Exception as e:
                self.logger.error(f"Failed to initialize integrated IDE: {str(e)}")
                self._metrics.increment_error_count()
    #             return False

    #     def _initialize_core_systems(self) -> bool:
    #         """Initialize core desktop GUI systems."""
    #         try:
                self.logger.info("Initializing core GUI systems...")

    #             # Initialize Window Manager
    self._window_manager = WindowManager()
    start_time = time.time()
    #             # In real implementation, would initialize with proper configuration
    init_time = math.subtract(time.time(), start_time)
                self._metrics.record_component_init("WindowManager", init_time)

    #             # Initialize Event System
    self._event_system = EventSystem()
    start_time = time.time()
    #             # In real implementation, would initialize event handling
    init_time = math.subtract(time.time(), start_time)
                self._metrics.record_component_init("EventSystem", init_time)

    #             # Initialize Rendering Engine
    self._rendering_engine = RenderingEngine()
    start_time = time.time()
    #             # In real implementation, would initialize graphics rendering
    init_time = math.subtract(time.time(), start_time)
                self._metrics.record_component_init("RenderingEngine", init_time)

    #             # Initialize Component Library
    self._component_library = ComponentLibrary()
    start_time = time.time()
    #             # In real implementation, would initialize component registry
    init_time = math.subtract(time.time(), start_time)
                self._metrics.record_component_init("ComponentLibrary", init_time)

                self.logger.info("Core GUI systems initialized successfully")
    #             return True

    #         except Exception as e:
                self.logger.error(f"Failed to initialize core systems: {str(e)}")
                self._metrics.increment_error_count()
    #             return False

    #     def _initialize_system_integrator(self) -> bool:
    #         """Initialize system integrator."""
    #         try:
                self.logger.info("Initializing system integrator...")

    #             # Create system integrator with API configuration
    self._system_integrator = NoodleCoreSystemIntegrator(
    api_base_url = self.config.backend_api_url,
    enable_real_time_sync = self.config.enable_real_time_sync
    #             )

    start_time = time.time()
    #             if self._system_integrator.initialize():
    init_time = math.subtract(time.time(), start_time)
                    self._metrics.record_component_init("SystemIntegrator", init_time)
    self._integration_status["system_integrator"] = True

    #                 # Update backend connection status
    self._backend_connected = self._system_integrator.is_connected()
    #                 if self._backend_connected:
    self._integration_status["backend_api"] = True
                        self.logger.info("Backend API connected successfully")

    #                     if self._on_backend_connected:
                            self._on_backend_connected()
    #                 else:
                        self.logger.warning("Backend API not available, falling back to local operations")
    self.config.use_backend_api = False

                    self.logger.info("System integrator initialized successfully")
    #                 return True
    #             else:
                    self.logger.warning("System integrator initialization failed")
    self.config.use_backend_api = False
    #                 return True  # Continue without backend API

    #         except Exception as e:
                self.logger.error(f"Failed to initialize system integrator: {str(e)}")
                self._metrics.increment_error_count()
    self.config.use_backend_api = False
    #             return True  # Continue without system integrator

    #     def _initialize_integrated_components(self) -> bool:
    #         """Initialize integrated IDE components."""
    #         try:
                self.logger.info("Initializing integrated components...")

    #             # Initialize Integrated File Explorer
    #             if self.config.enable_file_operations:
    self._file_explorer = IntegratedFileExplorer(self._system_integrator)
    start_time = time.time()
                    self._file_explorer.initialize(
    window_id = "main",  # Will be updated later
    event_system = self._event_system,
    rendering_engine = self._rendering_engine,
    component_library = self._component_library
    #                 )
    init_time = math.subtract(time.time(), start_time)
                    self._metrics.record_component_init("IntegratedFileExplorer", init_time)
    self._integration_status["file_explorer"] = True
                    self._file_explorer.set_use_backend_api(self.config.use_backend_api)

    #             # Initialize Integrated AI Panel
    #             if self.config.enable_ai_features:
    self._ai_panel = IntegratedAIPanel(self._system_integrator)
    start_time = time.time()
                    self._ai_panel.initialize(
    window_id = "main",  # Will be updated later
    event_system = self._event_system,
    rendering_engine = self._rendering_engine,
    component_library = self._component_library
    #                 )
    init_time = math.subtract(time.time(), start_time)
                    self._metrics.record_component_init("IntegratedAIPanel", init_time)
    self._integration_status["ai_panel"] = True
                    self._ai_panel.set_use_backend_api(self.config.use_backend_api)

    #             # Initialize Integrated Terminal Console
    #             if self.config.enable_terminal_features:
    self._terminal_console = IntegratedTerminalConsole(self._system_integrator)
    start_time = time.time()
                    self._terminal_console.initialize(
    window_id = "main",  # Will be updated later
    event_system = self._event_system,
    rendering_engine = self._rendering_engine,
    component_library = self._component_library
    #                 )
    init_time = math.subtract(time.time(), start_time)
                    self._metrics.record_component_init("IntegratedTerminalConsole", init_time)
    self._integration_status["terminal_console"] = True
                    self._terminal_console.set_use_backend_api(self.config.use_backend_api)
                    self._terminal_console.set_command_timeout(self.config.terminal_timeout)

                self.logger.info("Integrated components initialized successfully")
    #             return True

    #         except Exception as e:
                self.logger.error(f"Failed to initialize integrated components: {str(e)}")
                self._metrics.increment_error_count()
    #             return False

    #     def _initialize_additional_components(self) -> bool:
    #         """Initialize additional IDE components."""
    #         try:
                self.logger.info("Initializing additional components...")

    #             # Initialize Tab Manager
    self._tab_manager = TabManager()
    start_time = time.time()
                self._tab_manager.initialize(
    window_id = "main",  # Will be updated later
    event_system = self._event_system,
    rendering_engine = self._rendering_engine,
    component_library = self._component_library
    #             )
    init_time = math.subtract(time.time(), start_time)
                self._metrics.record_component_init("TabManager", init_time)
    self._integration_status["tab_manager"] = True

    #             # Initialize Code Editor
    self._code_editor = CodeEditor()
    start_time = time.time()
                self._code_editor.initialize(
    window_id = "main",  # Will be updated later
    event_system = self._event_system,
    rendering_engine = self._rendering_engine,
    component_library = self._component_library
    #             )
    init_time = math.subtract(time.time(), start_time)
                self._metrics.record_component_init("CodeEditor", init_time)
    self._integration_status["code_editor"] = True

                self.logger.info("Additional components initialized successfully")
    #             return True

    #         except Exception as e:
                self.logger.error(f"Failed to initialize additional components: {str(e)}")
                self._metrics.increment_error_count()
    #             return False

    #     def _setup_all_integrations(self):
    #         """Setup all integrations between components."""
    #         try:
                self.logger.info("Setting up all component integrations...")

    #             # Setup Tab Manager -> Code Editor integration
    #             if self._tab_manager and self._code_editor:
                    self._tab_manager.set_callbacks(
    on_tab_select = self._handle_tab_selection,
    on_tab_close = self._handle_tab_closing,
    on_tab_modify = self._handle_tab_modification
    #                 )

    #             # Setup File Explorer -> Tab Manager integration
    #             if self._file_explorer and self._tab_manager:
                    self._file_explorer.set_callbacks(
    on_file_open = self._handle_file_opening
    #                 )

    #             # Setup Terminal -> Code Editor integration
    #             if self._terminal_console and self._code_editor:
                    self._terminal_console.set_callbacks(
    on_execution_complete = self._handle_execution_complete
    #                 )

    #             # Setup AI Panel -> Code Editor integration
    #             if self._ai_panel and self._code_editor:
                    self._ai_panel.set_callbacks(
    on_analysis_complete = self._handle_ai_analysis_complete,
    on_suggestion_accepted = self._handle_suggestion_accepted
    #                 )

    #             # Setup cross-component integrations
                self._setup_cross_component_integrations()

                self.logger.info("All component integrations setup complete")

    #         except Exception as e:
                self.logger.error(f"Failed to setup integrations: {str(e)}")
                self._metrics.increment_warning_count()

    #     def _setup_cross_component_integrations(self):
    #         """Setup cross-component integrations."""
    #         try:
    #             # File Explorer -> AI Panel integration
    #             if self._file_explorer and self._ai_panel:
    #                 # AI panel can analyze files opened through file explorer
    #                 pass

    #             # Terminal -> File Explorer integration
    #             if self._terminal_console and self._file_explorer:
    #                 # Terminal can refresh file tree after file operations
    #                 pass

    #             # AI Panel -> Terminal integration
    #             if self._ai_panel and self._terminal_console:
    #                 # AI can suggest terminal commands
    #                 pass

                self.logger.info("Cross-component integrations setup complete")

    #         except Exception as e:
                self.logger.error(f"Failed to setup cross-component integrations: {str(e)}")

    #     def _create_main_ide_window(self) -> bool:
    #         """Create the main IDE window."""
    #         try:
                self.logger.info("Creating main IDE window...")

    #             # Create main window
    self._main_window_id = self._window_manager.create_window(
    title = self.config.default_window_title,
    width = self.config.default_window_width,
    height = self.config.default_window_height,
    resizable = True,
    minimizable = True,
    maximizable = True
    #             )

    #             # Initialize Main Window component
    self._main_window = MainWindow()
    start_time = time.time()
                self._main_window.initialize(
    window_id = self._main_window_id,
    event_system = self._event_system,
    rendering_engine = self._rendering_engine,
    component_library = self._component_library,
    config = self.config
    #             )
    init_time = math.subtract(time.time(), start_time)
                self._metrics.record_component_init("MainWindow", init_time)
    self._integration_status["main_window"] = True

    #             # Update component window IDs
                self._update_component_window_ids()

    #             # Update integrated component configurations
                self._update_integrated_component_configs()

                self.logger.info("Main IDE window created successfully")
    #             return True

    #         except Exception as e:
                self.logger.error(f"Failed to create main IDE window: {str(e)}")
                self._metrics.increment_error_count()
    #             return False

    #     def _update_component_window_ids(self):
    #         """Update window IDs for all components."""
    components = [
                (self._tab_manager, "TabManager"),
                (self._code_editor, "CodeEditor")
    #         ]

    #         for component, name in components:
    #             if component:
    #                 try:
                        component.initialize(
    window_id = self._main_window_id,
    event_system = self._event_system,
    rendering_engine = self._rendering_engine,
    component_library = self._component_library
    #                     )
    #                 except Exception as e:
                        self.logger.warning(f"Failed to update {name} window ID: {str(e)}")

    #     def _update_integrated_component_configs(self):
    #         """Update configurations for integrated components."""
    #         # Update File Explorer
    #         if self._file_explorer:
                self._file_explorer.set_use_backend_api(self.config.use_backend_api)
                self._file_explorer.set_auto_refresh(self.config.auto_refresh_file_tree)

    #         # Update AI Panel
    #         if self._ai_panel:
                self._ai_panel.set_use_backend_api(self.config.use_backend_api)
                self._ai_panel.set_auto_analysis(self.config.enable_real_time_suggestions)
                self._ai_panel.set_analysis_interval(self.config.ai_analysis_interval)

    #         # Update Terminal Console
    #         if self._terminal_console:
                self._terminal_console.set_use_backend_api(self.config.use_backend_api)
                self._terminal_console.set_command_timeout(self.config.terminal_timeout)

    #     def _load_configuration(self):
    #         """Load IDE configuration."""
    #         try:
    #             # Load from backend API if available
    #             if self.config.use_backend_api and self._system_integrator:
    #                 try:
    config_data = self._system_integrator.get_ide_configuration()
    #                     if config_data:
                            self._apply_backend_configuration(config_data)
                            self.logger.info("Configuration loaded from backend API")
    #                 except Exception as e:
                        self.logger.warning(f"Failed to load configuration from backend: {str(e)}")

                self.logger.info("Configuration loaded")

    #         except Exception as e:
                self.logger.warning(f"Failed to load configuration: {str(e)}")
                self._metrics.increment_warning_count()

    #     def _apply_backend_configuration(self, config_data: typing.Dict):
    #         """Apply configuration from backend API."""
    #         try:
    #             # Apply theme settings
    #             if "theme" in config_data:
    self.config.theme = config_data["theme"]

    #             # Apply panel settings
    #             if "panels" in config_data:
    panels = config_data["panels"]
    self.config.show_file_explorer = panels.get("file_explorer", True)
    self.config.show_ai_panel = panels.get("ai_panel", True)
    self.config.show_terminal = panels.get("terminal", True)

    #             # Apply performance settings
    #             if "performance" in config_data:
    perf = config_data["performance"]
    self.config.enable_performance_monitoring = perf.get("monitoring", True)
    self.config.max_file_size_mb = perf.get("max_file_size_mb", 50)

    #         except Exception as e:
                self.logger.warning(f"Failed to apply backend configuration: {str(e)}")

    #     def _start_performance_monitoring(self):
    #         """Start performance monitoring thread."""
    #         try:
    #             if self.config.show_performance_metrics:
                    self.logger.info("Starting performance monitoring...")
    self._performance_monitor_thread = threading.Thread(
    target = self._performance_monitoring_loop,
    daemon = True
    #                 )
                    self._performance_monitor_thread.start()

    #         except Exception as e:
                self.logger.error(f"Failed to start performance monitoring: {str(e)}")
                self._metrics.increment_error_count()

    #     def _performance_monitoring_loop(self):
    #         """Performance monitoring background loop."""
    #         while self._is_running:
    #             try:
    #                 # Update integration metrics
                    self._update_integration_metrics()

    #                 # Collect component metrics
                    self._collect_component_metrics()

                    time.sleep(10)  # Monitor every 10 seconds

    #             except Exception as e:
                    self.logger.error(f"Performance monitoring error: {str(e)}")
    #                 break

    #     def _update_integration_metrics(self):
    #         """Update integration-specific metrics."""
    #         try:
    self._integration_status["backend_api"] = self._backend_connected

    #             # Update metrics with integration status
                self._metrics.integration_metrics.update(self._integration_status)

    #         except Exception as e:
                self.logger.error(f"Failed to update integration metrics: {str(e)}")

    #     def _collect_component_metrics(self):
    #         """Collect metrics from all components."""
    #         try:
    #             # File Explorer metrics
    #             if self._file_explorer:
    file_metrics = self._file_explorer.get_metrics()
    self._metrics.performance_metrics["file_explorer"] = file_metrics

    #             # AI Panel metrics
    #             if self._ai_panel:
    ai_metrics = self._ai_panel.get_metrics()
    self._metrics.performance_metrics["ai_panel"] = ai_metrics

    #             # Terminal Console metrics
    #             if self._terminal_console:
    terminal_metrics = self._terminal_console.get_metrics()
    self._metrics.performance_metrics["terminal_console"] = terminal_metrics

    #             # System integrator metrics
    #             if self._system_integrator:
    integrator_metrics = self._system_integrator.get_integration_metrics()
    self._metrics.performance_metrics["system_integrator"] = integrator_metrics

    #         except Exception as e:
                self.logger.error(f"Failed to collect component metrics: {str(e)}")

    #     def run(self) -> bool:
    #         """
    #         Start the IDE.

    #         Returns:
    #             True if successful
    #         """
    #         try:
    #             if not self._is_initialized:
    #                 if not self.initialize():
    #                     return False

    self._is_running = True
                self.logger.info("NoodleCore Desktop GUI IDE (Integrated) started successfully")

    #             # Setup shutdown handlers
    #             import signal
                signal.signal(signal.SIGINT, self._handle_shutdown)
                signal.signal(signal.SIGTERM, self._handle_shutdown)

    #             # Notify initialization complete
    #             if self._on_initialized:
                    self._on_initialized()

    #             # Load default project if configured
    #             if self.config.auto_load_last_session:
                    self._load_default_project()

    #             # Main application loop
                self._run_main_loop()

    #             return True

    #         except Exception as e:
                self.logger.error(f"Failed to start IDE: {str(e)}")
                self._metrics.increment_error_count()
    #             return False

    #     def _run_main_loop(self):
    #         """Main application loop."""
    #         try:
                self.logger.info("IDE main loop running...")

    #             # Demo: Create sample content
                self._create_demo_content()

    #             # Keep the program running
    #             try:
    #                 import time
    #                 while self._is_running:
    #                     # Check backend connection status
    #                     if self.config.use_backend_api and self._system_integrator:
    current_status = self._system_integrator.is_connected()
    #                         if current_status != self._backend_connected:
    self._backend_connected = current_status
    self._integration_status["backend_api"] = current_status

    #                             if current_status:
                                    self.logger.info("Backend API reconnected")
    #                                 if self._on_backend_connected:
                                        self._on_backend_connected()
    #                             else:
                                    self.logger.warning("Backend API disconnected")
    #                                 if self._on_backend_disconnected:
                                        self._on_backend_disconnected()

                        time.sleep(1)
    #             except KeyboardInterrupt:
    #                 pass

    #         except Exception as e:
                self.logger.error(f"Main loop error: {str(e)}")

    #     def _load_default_project(self):
    #         """Load default project."""
    #         try:
    #             if self._file_explorer:
    #                 # Load current directory as default project
    current_dir = os.getcwd()
                    self._file_explorer.load_project(current_dir, "generic")
                    self.logger.info(f"Loaded default project: {current_dir}")
    #         except Exception as e:
                self.logger.warning(f"Failed to load default project: {str(e)}")

    #     def _create_demo_content(self):
    #         """Create demo content for demonstration."""
    #         try:
    #             if self._tab_manager:
    #                 # Create welcome tab
    welcome_tab = self._tab_manager.open_tab(
    file_path = "welcome.md",
    title = "Welcome"
    #                 )

    #                 # Set welcome content
    #                 if self._code_editor and welcome_tab:
    welcome_content = """# NoodleCore Desktop GUI IDE - Integrated Version

# Welcome to the **integrated** NoodleCore Desktop GUI IDE!

## 🎯 Integrated Features

# This IDE demonstrates **complete integration** with all NoodleCore backend systems:

### ✅ File System Integration
# - **Backend API Integration**: Real file operations via API
# - **Automatic Fallback**: Seamless transition to local operations
# - **Real-time Sync**: Live file tree updates

### ✅ AI System Integration
# - **Backend AI Analysis**: Real AI-powered code analysis
# - **Real-time Suggestions**: Live code improvement suggestions
# - **Learning Progress**: AI system performance tracking

### ✅ Terminal Console Integration
# - **Backend Execution**: Command execution via API
# - **Real-time Output**: Live command output streaming
# - **Multi-language Support**: Python, Node.js, Shell commands

### ✅ System Integrator
# - **Unified Backend**: Single integration point for all APIs
# - **Health Monitoring**: Real-time backend connection status
# - **Performance Metrics**: Comprehensive system monitoring

## 🚀 Quick Start

# 1. **File Operations**: Use the file explorer to browse and manage files
# 2. **Code Analysis**: Open any file to see AI analysis results
# 3. **Terminal Commands**: Use the terminal for command execution
# 4. **AI Suggestions**: Review AI suggestions in the AI panel

## 🔧 Configuration

# - **Backend API**: Uses `""" + self.config.backend_api_url + """`
# - **Real-time Sync**: """ + ("Enabled" if self.config.enable_real_time_sync else "Disabled") + """
# - **Debug Mode**: """ + ("Enabled" if self.config.debug_mode else "Disabled") + """

# Start exploring the integrated capabilities!
# """
                    self._code_editor.set_content(welcome_content)

                self.logger.info("Demo content created successfully")

#         except Exception as e:
            self.logger.error(f"Failed to create demo content: {str(e)}")
            self._metrics.increment_warning_count()

#     # Event handlers

#     def _handle_tab_selection(self, tab_id: str, tab_info):
#         """Handle tab selection events."""
#         try:
            self._metrics.increment_ui_operations()

#             if self._code_editor and tab_info.file_path:
#                 # Trigger AI analysis if enabled
#                 if self._ai_panel and self.config.enable_ai_features:
#                     try:
#                         # Get file content and analyze
#                         if self._code_editor.get_content():
                            self._ai_panel.analyze_code(
                                self._code_editor.get_content(),
#                                 tab_info.file_path
#                             )
#                     except Exception as e:
                        self.logger.warning(f"AI analysis on tab selection failed: {str(e)}")

#         except Exception as e:
            self.logger.error(f"Error handling tab selection: {str(e)}")

#     def _handle_tab_closing(self, tab_id: str, tab_info):
#         """Handle tab closing events."""
#         try:
            self._metrics.increment_ui_operations()
            self.logger.debug(f"Closing tab: {tab_info.title}")

#         except Exception as e:
            self.logger.error(f"Error handling tab closing: {str(e)}")

#     def _handle_tab_modification(self, tab_id: str, tab_info, modified: bool):
#         """Handle tab modification events."""
#         try:
            self._metrics.increment_ui_operations()
#             self.logger.debug(f"Tab {tab_info.title} {'modified' if modified else 'saved'}")

#         except Exception as e:
            self.logger.error(f"Error handling tab modification: {str(e)}")

#     def _handle_file_opening(self, file_path: str, file_info):
#         """Handle file opening events."""
#         try:
            self._metrics.increment_file_operations()

#             if self._tab_manager:
                self._tab_manager.open_tab(file_path)

#         except Exception as e:
            self.logger.error(f"Error handling file opening: {str(e)}")

#     def _handle_execution_complete(self, execution):
#         """Handle command execution completion."""
#         try:
            self._metrics.increment_terminal_operations()

#             # Analyze execution results if needed
#             if self._ai_panel and execution.stderr:
#                 # AI could analyze error output for suggestions
#                 pass

#         except Exception as e:
            self.logger.error(f"Error handling execution completion: {str(e)}")

#     def _handle_ai_analysis_complete(self, analysis_result):
#         """Handle AI analysis completion."""
#         try:
            self._metrics.increment_ai_operations()

#             # Could trigger additional actions based on analysis
#             pass

#         except Exception as e:
            self.logger.error(f"Error handling AI analysis completion: {str(e)}")

#     def _handle_suggestion_accepted(self, suggestion):
#         """Handle AI suggestion acceptance."""
#         try:
            self._metrics.increment_ai_operations()

#             # Could update learning metrics
#             pass

#         except Exception as e:
            self.logger.error(f"Error handling suggestion acceptance: {str(e)}")

#     def _handle_shutdown(self, signum, frame):
#         """Handle shutdown signals."""
        self.logger.info(f"Received shutdown signal: {signum}")
        self.shutdown()

#     # Public API

#     def set_initialization_callback(self, callback: typing.Callable):
#         """Set callback for when IDE initialization is complete."""
self._on_initialized = callback

#     def set_shutdown_callback(self, callback: typing.Callable):
#         """Set callback for when IDE shutdown is complete."""
self._on_shutdown = callback

#     def set_backend_connected_callback(self, callback: typing.Callable):
#         """Set callback for backend connection status changes."""
self._on_backend_connected = callback

#     def set_backend_disconnected_callback(self, callback: typing.Callable):
#         """Set callback for backend disconnection."""
self._on_backend_disconnected = callback

#     def get_integration_status(self) -> typing.Dict[str, bool]:
#         """Get integration status for all components."""
        return self._integration_status.copy()

#     def get_metrics(self) -> typing.Dict[str, typing.Any]:
#         """Get IDE metrics."""
        return self._metrics.get_summary()

#     def is_backend_connected(self) -> bool:
#         """Check if backend API is connected."""
#         return self._backend_connected

#     def get_configuration(self) -> IntegratedIDEConfiguration:
#         """Get current IDE configuration."""
#         return self.config

#     def is_running(self) -> bool:
#         """Check if IDE is running."""
#         return self._is_running

#     def get_version(self) -> str:
#         """Get IDE version."""
#         return "1.0.0-integrated"

#     def shutdown(self):
#         """Shutdown the IDE gracefully."""
#         try:
            self.logger.info("Shutting down NoodleCore Desktop GUI IDE (Integrated)...")

self._is_running = False

#             # Shutdown performance monitoring
#             if self._performance_monitor_thread:
self._performance_monitor_thread.join(timeout = 5)

#             # Shutdown integrated components
#             if self._terminal_console:
#                 try:
                    self._terminal_console.shutdown()
#                 except Exception as e:
                    self.logger.error(f"Error shutting down terminal console: {str(e)}")

#             if self._ai_panel:
#                 try:
                    self._ai_panel.shutdown()
#                 except Exception as e:
                    self.logger.error(f"Error shutting down AI panel: {str(e)}")

#             # Shutdown system integrator
#             if self._system_integrator:
#                 try:
                    self._system_integrator.shutdown()
#                 except Exception as e:
                    self.logger.error(f"Error shutting down system integrator: {str(e)}")

#             # Shutdown components
components = [
#                 self._tab_manager,
#                 self._code_editor,
#                 self._main_window
#             ]

#             for component in components:
#                 if component:
#                     try:
#                         # In real implementation, would call component shutdown methods
#                         pass
#                     except Exception as e:
                        self.logger.error(f"Error shutting down component: {str(e)}")

#             # Log final metrics
            self._log_final_metrics()

            self.logger.info("NoodleCore Desktop GUI IDE (Integrated) shutdown complete")

#             # Notify shutdown
#             if self._on_shutdown:
                self._on_shutdown()

#         except Exception as e:
            self.logger.error(f"Error during IDE shutdown: {str(e)}")

#     def _log_final_metrics(self):
#         """Log final IDE metrics."""
#         try:
metrics = self._metrics.get_summary()
            self.logger.info("Integrated IDE Performance Summary:")
            self.logger.info(f"  Uptime: {metrics['uptime_seconds']:.2f} seconds")
            self.logger.info(f"  UI Operations: {metrics['ui_operations']}")
            self.logger.info(f"  File Operations: {metrics['file_operations']}")
            self.logger.info(f"  AI Operations: {metrics['ai_operations']}")
            self.logger.info(f"  Terminal Operations: {metrics['terminal_operations']}")
            self.logger.info(f"  API Operations: {metrics['api_operations']}")
            self.logger.info(f"  Backend Operations: {metrics['backend_operations']}")
            self.logger.info(f"  Errors: {metrics['errors']}")
            self.logger.info(f"  Warnings: {metrics['warnings']}")

#             # Log integration status
            self.logger.info("Integration Status:")
#             for component, status in self._integration_status.items():
#                 self.logger.info(f"  {component}: {'✅' if status else '❌'}")

#             # Log component initialization times
#             if metrics['component_init_times']:
                self.logger.info("Component Initialization Times:")
#                 for component, duration in metrics['component_init_times'].items():
                    self.logger.info(f"  {component}: {duration:.3f}s")

#         except Exception as e:
            self.logger.error(f"Failed to log final metrics: {str(e)}")


function main()
    #     """Main entry point for Integrated NoodleCore Desktop GUI IDE."""
    #     try:
    #         # Create IDE configuration
    config = IntegratedIDEConfiguration(
    debug_mode = "--debug" in sys.argv,
    use_backend_api = "--no-api" not in sys.argv,
    backend_api_url = os.getenv("NOODLE_API_URL", "http://localhost:8080"),
    theme = "dark",
    show_file_explorer = True,
    show_ai_panel = True,
    show_terminal = True,
    enable_performance_monitoring = True,
    show_performance_metrics = True,
    enable_real_time_sync = True
    #         )

    #         # Create and run IDE
    ide = IntegratedNoodleCoreIDE(
    config = config,
    mode = IntegratedIDEMode.INTEGRATED_MODE
    #         )

    #         # Setup callbacks
            ide.set_initialization_callback(lambda: print("✅ Integrated IDE initialized successfully!"))
            ide.set_shutdown_callback(lambda: print("Integrated IDE shutdown complete"))
            ide.set_backend_connected_callback(lambda: print("Backend API connected"))
            ide.set_backend_disconnected_callback(lambda: print("Backend API disconnected"))

    #         # Run IDE
    #         if ide.run():
                print("🚀 NoodleCore Desktop GUI IDE (Integrated) is running...")
                print("Press Ctrl+C to shutdown")

    #             # Keep the program running
    #             try:
    #                 import time
    #                 while ide.is_running():
                        time.sleep(1)
    #             except KeyboardInterrupt:
    #                 pass
    #             finally:
                    ide.shutdown()
    #         else:
                print("Failed to start integrated IDE")
    #             return 1

    #         return 0

    #     except Exception as e:
            print(f"Failed to start integrated IDE: {str(e)}")
    #         return 1


if __name__ == "__main__"
        exit(main())