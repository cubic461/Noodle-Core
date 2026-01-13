# """
# Terminal Console for NoodleCore Desktop IDE - Integrated Version
# 
# This module provides terminal console functionality with integration
# to backend execution systems and real-time output monitoring.
# """

import typing
import dataclasses
import enum
import logging
import uuid
import time
import json
import threading
import subprocess
import os
from pathlib import Path

from ...desktop import GUIError
from ..core.events.event_system import EventSystem, EventType, MouseEvent
from ..core.rendering.rendering_engine import RenderingEngine
from ..core.components.component_library import ComponentLibrary, TextAreaProperties, ButtonProperties
from .integration.system_integrator import NoodleCoreSystemIntegrator


class TerminalType(Enum):
    # """Types of terminal sessions."""
    SHELL = "shell"
    PYTHON = "python"
    NODEJS = "nodejs"
    BATCH = "batch"
    CUSTOM = "custom"


class ExecutionStatus(Enum):
    # """Execution status types."""
    IDLE = "idle"
    RUNNING = "running"
    SUCCESS = "success"
    ERROR = "error"
    TIMEOUT = "timeout"
    CANCELLED = "cancelled"


class CommandCategory(Enum):
    # """Categories of commands."""
    FILE_OPERATION = "file_operation"
    SYSTEM = "system"
    DEVELOPMENT = "development"
    NOODLECORE = "noodlecore"
    CUSTOM = "custom"


@dataclass
class CommandExecution:
    # """Command execution result."""
    execution_id: str
    command: str
    working_directory: str
    execution_time: float
    start_time: float
    end_time: float = None
    status: ExecutionStatus = ExecutionStatus.IDLE
    stdout: str = ""
    stderr: str = ""
    exit_code: int = None
    process_id: int = None
    category: CommandCategory = CommandCategory.CUSTOM
    
    def __post_init__(self):
        if not self.execution_id:
            self.execution_id = str(uuid.uuid4())
        if not self.start_time:
            self.start_time = time.time()
        if not self.end_time:
            self.end_time = self.start_time + self.execution_time


@dataclass
class TerminalSession:
    # """Terminal session information."""
    session_id: str
    terminal_type: TerminalType
    working_directory: str
    environment_variables: typing.Dict[str, str]
    command_history: typing.List[str]
    current_process: typing.Optional[subprocess.Popen] = None
    is_active: bool = True
    created_time: float = None
    
    def __post_init__(self):
        if not self.session_id:
            self.session_id = str(uuid.uuid4())
        if not self.created_time:
            self.created_time = time.time()


class TerminalConsoleError(GUIError):
    # """Exception raised for terminal console operations."""
    
    def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
        super().__init__(message, "9001", details)


class CommandExecutionError(TerminalConsoleError):
    # """Raised when command execution operations fail."""
    
    def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
        super().__init__(message, "9002", details)


class IntegratedTerminalConsole:
    # """
    # Integrated Terminal Console for NoodleCore Desktop IDE.
    # 
    # This class provides terminal console functionality with integration
    # to backend execution systems and real-time output monitoring.
    # """
    
    def __init__(self, system_integrator: NoodleCoreSystemIntegrator = None):
        # """Initialize the integrated terminal console."""
        self.logger = logging.getLogger(__name__)
        
        # Core GUI systems
        self._event_system = None
        self._rendering_engine = None
        self._component_library = None
        
        # System integration
        self._system_integrator = system_integrator or NoodleCoreSystemIntegrator()
        
        # Window and component references
        self._window_id = None
        self._terminal_component_id = None
        self._input_component_id = None
        self._execute_button_id = None
        self._clear_button_id = None
        
        # Terminal state
        self._current_session: typing.Optional[TerminalSession] = None
        self._sessions: typing.Dict[str, TerminalSession] = {}
        self._current_command = ""
        self._command_history: typing.List[str] = []
        self._execution_history: typing.List[CommandExecution] = []
        self._active_executions: typing.Dict[str, CommandExecution] = {}
        
        # Configuration
        self._use_backend_api = True
        self._default_terminal_type = TerminalType.SHELL
        self._command_timeout = 30.0  # seconds
        self._max_history_size = 100
        self._enable_command_categorization = True
        
        # Execution callbacks
        self._on_execution_start: typing.Optional[typing.Callable] = None
        self._on_execution_complete: typing.Optional[typing.Callable] = None
        self._on_execution_error: typing.Optional[typing.Callable] = None
        
        # Background processing
        self._output_monitor_thread: typing.Optional[threading.Thread] = None
        self._monitor_active = False
        self._output_queue: typing.Queue = None
        
        # Metrics
        self._metrics = {
            "commands_executed": 0,
            "successful_executions": 0,
            "failed_executions": 0,
            "total_execution_time": 0.0,
            "api_operations": 0,
            "backend_executions": 0,
            "sessions_created": 0
        }
    
    def initialize(self, window_id: str, event_system: EventSystem,
                  rendering_engine: RenderingEngine, component_library: ComponentLibrary):
        # """
        # Initialize the terminal console.
        
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
            
            # Initialize system integrator
            if not self._system_integrator.initialize():
                self.logger.warning("System integrator initialization failed, falling back to local operations")
                self._use_backend_api = False
            
            # Create terminal components
            self._create_terminal_components()
            
            # Register event handlers
            self._register_event_handlers()
            
            # Set up integration callbacks
            self._setup_integration_callbacks()
            
            # Create default session
            self._create_default_session()
            
            # Start output monitoring
            self._start_output_monitoring()
            
            self.logger.info("Integrated terminal console initialized")
            
        except Exception as e:
            self.logger.error(f"Failed to initialize terminal console: {str(e)}")
            raise TerminalConsoleError(f"Terminal console initialization failed: {str(e)}")
    
    def _setup_integration_callbacks(self):
        """Set up callbacks for system integrator integration."""
        if self._system_integrator:
            # Set callback for execution results
            self._system_integrator.set_callback("command_execution", self._handle_backend_execution)
            # Set callback for output updates
            self._system_integrator.set_callback("execution_output", self._handle_backend_output)
    
    def _handle_backend_execution(self, execution_data: typing.Dict):
        """Handle command execution from backend API."""
        try:
            self.logger.info("Received execution result from backend")
            
            # Convert to CommandExecution
            execution = CommandExecution(
                execution_id=execution_data.get("execution_id", str(uuid.uuid4())),
                command=execution_data.get("command", ""),
                working_directory=execution_data.get("working_directory", ""),
                execution_time=execution_data.get("execution_time", 0.0),
                start_time=execution_data.get("start_time", time.time()),
                end_time=execution_data.get("end_time", time.time()),
                status=ExecutionStatus(execution_data.get("status", "idle")),
                stdout=execution_data.get("stdout", ""),
                stderr=execution_data.get("stderr", ""),
                exit_code=execution_data.get("exit_code"),
                category=CommandCategory(execution_data.get("category", "custom"))
            )
            
            # Update execution history
            self._execution_history.append(execution)
            if len(self._execution_history) > self._max_history_size:
                self._execution_history.pop(0)
            
            # Update metrics
            self._metrics["backend_executions"] += 1
            self._metrics["commands_executed"] += 1
            self._metrics["total_execution_time"] += execution.execution_time
            
            if execution.status == ExecutionStatus.SUCCESS:
                self._metrics["successful_executions"] += 1
            elif execution.status == ExecutionStatus.ERROR:
                self._metrics["failed_executions"] += 1
            
            # Update terminal display
            self._update_terminal_display()
            
            # Trigger callback
            if self._on_execution_complete:
                self._on_execution_complete(execution)
            
        except Exception as e:
            self.logger.error(f"Error handling backend execution: {str(e)}")
    
    def _handle_backend_output(self, output_data: typing.Dict):
        """Handle execution output from backend API."""
        try:
            execution_id = output_data.get("execution_id")
            output_type = output_data.get("type")  # "stdout" or "stderr"
            content = output_data.get("content", "")
            
            if execution_id in self._active_executions:
                execution = self._active_executions[execution_id]
                if output_type == "stdout":
                    execution.stdout += content
                elif output_type == "stderr":
                    execution.stderr += content
                
                # Update terminal display in real-time
                self._update_terminal_display()
            
        except Exception as e:
            self.logger.error(f"Error handling backend output: {str(e)}")
    
    def _create_terminal_components(self):
        # """Create the terminal console components."""
        try:
            # Create terminal display
            self._terminal_component_id = self._component_library.create_component(
                component_type="text_area",
                window_id=self._window_id,
                x=250,
                y=400,
                width=750,
                height=200,
                read_only=True,
                title="Terminal Output",
                monospace_font=True,
                scrollable=True
            )
            
            # Create command input
            self._input_component_id = self._component_library.create_component(
                component_type="text_field",
                window_id=self._window_id,
                x=250,
                y=610,
                width=650,
                height=30,
                title="Command:"
            )
            
            # Create execute button
            self._execute_button_id = self._component_library.create_component(
                component_type="button",
                window_id=self._window_id,
                x=910,
                y=610,
                width=80,
                height=30,
                text="Execute"
            )
            
            # Create clear button
            self._clear_button_id = self._component_library.create_component(
                component_type="button",
                window_id=self._window_id,
                x=250,
                y=370,
                width=80,
                height=25,
                text="Clear"
            )
            
            self.logger.info("Created terminal console components")
            
        except Exception as e:
            self.logger.error(f"Failed to create terminal components: {str(e)}")
            raise TerminalConsoleError(f"Terminal component creation failed: {str(e)}")
    
    def _register_event_handlers(self):
        # """Register event handlers."""
        try:
            # Button click events
            self._event_system.register_handler(
                EventType.MOUSE_CLICK,
                self._handle_button_click,
                window_id=self._window_id
            )
            
            # Text input events
            self._event_system.register_handler(
                EventType.KEY_PRESS,
                self._handle_key_press,
                window_id=self._window_id
            )
            
        except Exception as e:
            self.logger.error(f"Failed to register event handlers: {str(e)}")
            raise TerminalConsoleError(f"Event handler registration failed: {str(e)}")
    
    def _create_default_session(self):
        """Create the default terminal session."""
        try:
            session = TerminalSession(
                session_id=str(uuid.uuid4()),
                terminal_type=self._default_terminal_type,
                working_directory=os.getcwd(),
                environment_variables=os.environ.copy(),
                command_history=[]
            )
            
            self._sessions[session.session_id] = session
            self._current_session = session
            self._metrics["sessions_created"] += 1
            
            # Display welcome message
            self._display_welcome_message()
            
        except Exception as e:
            self.logger.error(f"Failed to create default session: {str(e)}")
    
    def _start_output_monitoring(self):
        """Start output monitoring thread."""
        try:
            self._monitor_active = True
            
            self._output_monitor_thread = threading.Thread(target=self._monitor_output_loop, daemon=True)
            self._output_monitor_thread.start()
            
            self.logger.info("Output monitoring started")
            
        except Exception as e:
            self.logger.error(f"Failed to start output monitoring: {str(e)}")
    
    def _monitor_output_loop(self):
        """Background output monitoring loop."""
        while self._monitor_active:
            try:
                # Monitor active executions
                for execution_id, execution in list(self._active_executions.items()):
                    if execution.process_id and execution.status == ExecutionStatus.RUNNING:
                        # In a real implementation, would read process output
                        # For now, just sleep
                        pass
                
                time.sleep(0.1)  # Monitor every 100ms
                
            except Exception as e:
                self.logger.error(f"Output monitoring error: {str(e)}")
                time.sleep(1)  # Brief pause on error
    
    def execute_command(self, command: str, working_directory: str = None) -> bool:
        # """
        # Execute a command.
        
        Args:
            command: Command to execute
            working_directory: Working directory (defaults to current session)
        
        Returns:
            True if execution started successfully
        """
        try:
            if not command.strip():
                return False
            
            if not working_directory:
                working_directory = self._current_session.working_directory if self._current_session else os.getcwd()
            
            self.logger.info(f"Executing command: {command}")
            
            # Categorize command
            category = self._categorize_command(command)
            
            # Create execution record
            execution = CommandExecution(
                execution_id=str(uuid.uuid4()),
                command=command,
                working_directory=working_directory,
                execution_time=0.0,
                start_time=time.time(),
                status=ExecutionStatus.RUNNING,
                category=category
            )
            
            if self._use_backend_api and self._system_integrator:
                # Use backend API
                result = self._system_integrator.execute_command(command, working_directory)
                self._metrics["backend_executions"] += 1
                
                if result:
                    # Backend execution started successfully
                    self._active_executions[execution.execution_id] = execution
                    self._display_execution_start(execution)
                    return True
                else:
                    self.logger.warning("Backend execution failed, falling back to local")
                    return self._execute_command_locally(execution)
            else:
                # Execute locally
                return self._execute_command_locally(execution)
                
        except Exception as e:
            self.logger.error(f"Command execution failed: {str(e)}")
            raise CommandExecutionError(f"Command execution failed: {str(e)}")
    
    def _execute_command_locally(self, execution: CommandExecution) -> bool:
        """Execute command locally."""
        try:
            # Update command history
            self._command_history.append(execution.command)
            if len(self._command_history) > self._max_history_size:
                self._command_history.pop(0)
            
            # Update session history
            if self._current_session:
                self._current_session.command_history.append(execution.command)
            
            # Display execution start
            self._display_execution_start(execution)
            
            # Execute command in background thread
            thread = threading.Thread(
                target=self._execute_command_thread,
                args=(execution,),
                daemon=True
            )
            thread.start()
            
            # Add to active executions
            self._active_executions[execution.execution_id] = execution
            
            return True
            
        except Exception as e:
            self.logger.error(f"Local command execution failed: {str(e)}")
            execution.status = ExecutionStatus.ERROR
            execution.stderr = str(e)
            return False
    
    def _execute_command_thread(self, execution: CommandExecution):
        """Execute command in background thread."""
        try:
            # Create process
            process = subprocess.Popen(
                execution.command,
                shell=True,
                cwd=execution.working_directory,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                bufsize=1,
                universal_newlines=True
            )
            
            execution.process_id = process.pid
            
            # Read output
            stdout, stderr = process.communicate(timeout=self._command_timeout)
            
            # Update execution
            execution.end_time = time.time()
            execution.execution_time = execution.end_time - execution.start_time
            execution.stdout = stdout
            execution.stderr = stderr
            execution.exit_code = process.returncode
            
            if process.returncode == 0:
                execution.status = ExecutionStatus.SUCCESS
            else:
                execution.status = ExecutionStatus.ERROR
            
            # Update metrics
            self._metrics["commands_executed"] += 1
            self._metrics["total_execution_time"] += execution.execution_time
            
            if execution.status == ExecutionStatus.SUCCESS:
                self._metrics["successful_executions"] += 1
            else:
                self._metrics["failed_executions"] += 1
            
            # Add to history
            self._execution_history.append(execution)
            if len(self._execution_history) > self._max_history_size:
                self._execution_history.pop(0)
            
            # Remove from active
            if execution.execution_id in self._active_executions:
                del self._active_executions[execution.execution_id]
            
            # Update display
            self._update_terminal_display()
            
            # Trigger callback
            if self._on_execution_complete:
                self._on_execution_complete(execution)
            
        except subprocess.TimeoutExpired:
            execution.status = ExecutionStatus.TIMEOUT
            execution.stderr = f"Command timed out after {self._command_timeout} seconds"
            if execution.process_id:
                try:
                    os.kill(execution.process_id, 9)
                except:
                    pass
        except Exception as e:
            execution.status = ExecutionStatus.ERROR
            execution.stderr = str(e)
        finally:
            # Remove from active executions
            if execution.execution_id in self._active_executions:
                del self._active_executions[execution.execution_id]
            
            # Update display
            self._update_terminal_display()
    
    def _categorize_command(self, command: str) -> CommandCategory:
        """Categorize command for better organization."""
        command_lower = command.lower().strip()
        
        # File operations
        if any(cmd in command_lower for cmd in ['ls', 'dir', 'cd', 'mkdir', 'rm', 'rmdir', 'copy', 'move']):
            return CommandCategory.FILE_OPERATION
        
        # System commands
        elif any(cmd in command_lower for cmd in ['ps', 'kill', 'system', 'uname', 'whoami']):
            return CommandCategory.SYSTEM
        
        # Development commands
        elif any(cmd in command_lower for cmd in ['git', 'npm', 'yarn', 'pip', 'python', 'node', 'gcc']):
            return CommandCategory.DEVELOPMENT
        
        # NoodleCore commands
        elif 'noodle' in command_lower or 'nc' in command_lower:
            return CommandCategory.NOODLECORE
        
        else:
            return CommandCategory.CUSTOM
    
    def _display_welcome_message(self):
        """Display welcome message in terminal."""
        welcome = f"""
NoodleCore Desktop IDE Terminal Console
Type 'help' for available commands, 'clear' to clear the screen.
Current directory: {self._current_session.working_directory if self._current_session else os.getcwd()}
"""
        self._component_library.update_component(
            self._terminal_component_id,
            text=welcome
        )
    
    def _display_execution_start(self, execution: CommandExecution):
        """Display execution start in terminal."""
        timestamp = time.strftime("%H:%M:%S", time.localtime(execution.start_time))
        display_text = f"\n[{timestamp}] $ {execution.command}\n"
        
        # Get current terminal content
        current_content = ""
        try:
            component_info = self._component_library.get_component_info(self._terminal_component_id)
            if component_info:
                current_content = component_info.get("text", "")
        except:
            pass
        
        # Append execution info
        new_content = current_content + display_text
        self._component_library.update_component(
            self._terminal_component_id,
            text=new_content
        )
    
    def _update_terminal_display(self):
        """Update terminal display with latest output."""
        try:
            # Build display content
            display_lines = []
            
            # Show recent executions
            recent_executions = self._execution_history[-5:]  # Show last 5
            for execution in recent_executions:
                timestamp = time.strftime("%H:%M:%S", time.localtime(execution.start_time))
                status_symbol = self._get_status_symbol(execution.status)
                
                display_lines.append(f"[{timestamp}] {status_symbol} {execution.command}")
                
                if execution.stdout:
                    display_lines.append(f"STDOUT: {execution.stdout.strip()}")
                
                if execution.stderr:
                    display_lines.append(f"STDERR: {execution.stderr.strip()}")
                
                display_lines.append("")  # Empty line between executions
            
            # Show active executions
            if self._active_executions:
                display_lines.append("Active executions:")
                for execution in self._active_executions.values():
                    if execution.status == ExecutionStatus.RUNNING:
                        display_lines.append(f"  • {execution.command} (PID: {execution.process_id})")
            
            # Join lines
            content = "\n".join(display_lines)
            
            self._component_library.update_component(
                self._terminal_component_id,
                text=content
            )
            
        except Exception as e:
            self.logger.error(f"Failed to update terminal display: {str(e)}")
    
    def _get_status_symbol(self, status: ExecutionStatus) -> str:
        """Get status symbol for display."""
        symbols = {
            ExecutionStatus.IDLE: "⏸",
            ExecutionStatus.RUNNING: "▶",
            ExecutionStatus.SUCCESS: "✅",
            ExecutionStatus.ERROR: "❌",
            ExecutionStatus.TIMEOUT: "⏰",
            ExecutionStatus.CANCELLED: "🚫"
        }
        return symbols.get(status, "?")
    
    def clear_terminal(self):
        # """Clear the terminal display."""
        try:
            self._component_library.update_component(
                self._terminal_component_id,
                text=""
            )
            
            # Re-display welcome message
            self._display_welcome_message()
            
        except Exception as e:
            self.logger.error(f"Failed to clear terminal: {str(e)}")
    
    def get_command_history(self) -> typing.List[str]:
        # """Get command history."""
        return self._command_history.copy()
    
    def get_execution_history(self) -> typing.List[CommandExecution]:
        # """Get execution history."""
        return self._execution_history.copy()
    
    def get_current_session(self) -> typing.Optional[TerminalSession]:
        # """Get current terminal session."""
        return self._current_session
    
    def set_working_directory(self, directory: str):
        # """Set working directory for current session."""
        try:
            if os.path.exists(directory) and os.path.isdir(directory):
                if self._current_session:
                    self._current_session.working_directory = directory
                self.logger.info(f"Changed working directory to: {directory}")
            else:
                self.logger.warning(f"Directory does not exist: {directory}")
        except Exception as e:
            self.logger.error(f"Failed to change directory: {str(e)}")
    
    def set_system_integrator(self, system_integrator: NoodleCoreSystemIntegrator):
        """Set the system integrator for backend integration."""
        self._system_integrator = system_integrator
        self.logger.info("System integrator updated")
    
    def set_use_backend_api(self, use_api: bool):
        """Set whether to use backend API or local operations."""
        self._use_backend_api = use_api
        self.logger.info(f"Backend API usage: {use_api}")
    
    def set_command_timeout(self, timeout: float):
        """Set command timeout in seconds."""
        self._command_timeout = max(1.0, timeout)
        self.logger.info(f"Command timeout: {self._command_timeout}s")
    
    def set_callbacks(self, on_execution_start: typing.Callable = None,
                     on_execution_complete: typing.Callable = None,
                     on_execution_error: typing.Callable = None):
        # """
        # Set operation callbacks.
        
        Args:
            on_execution_start: Callback when execution starts
            on_execution_complete: Callback when execution completes
            on_execution_error: Callback when execution errors
        """
        self._on_execution_start = on_execution_start
        self._on_execution_complete = on_execution_complete
        self._on_execution_error = on_execution_error
    
    def get_metrics(self) -> typing.Dict[str, typing.Any]:
        # """Get terminal console metrics."""
        metrics = self._metrics.copy()
        
        # Add integration status
        if self._system_integrator:
            metrics["integration_status"] = self._system_integrator.get_integration_status()
            metrics["integration_metrics"] = self._system_integrator.get_integration_metrics()
        
        # Add session info
        metrics["active_sessions"] = len([s for s in self._sessions.values() if s.is_active])
        metrics["current_directory"] = self._current_session.working_directory if self._current_session else None
        
        return metrics
    
    # Event handlers
    
    def _handle_button_click(self, event: MouseEvent):
        # """Handle button clicks."""
        try:
            # Check which button was clicked
            # In a real implementation, would get the button component ID from event
            self.logger.debug(f"Button click at ({event.x}, {event.y})")
            
        except Exception as e:
            self.logger.error(f"Button click handling failed: {str(e)}")
    
    def _handle_key_press(self, event):
        # """Handle key press events."""
        try:
            # Check if Enter was pressed to execute command
            if hasattr(event, 'key') and event.key == 'Enter':
                self._execute_current_command()
            
        except Exception as e:
            self.logger.error(f"Key press handling failed: {str(e)}")
    
    def _execute_current_command(self):
        """Execute the current command in input field."""
        try:
            # Get current command from input field
            component_info = self._component_library.get_component_info(self._input_component_id)
            if component_info:
                command = component_info.get("text", "").strip()
                if command:
                    self.execute_command(command)
                    # Clear input field
                    self._component_library.update_component(
                        self._input_component_id,
                        text=""
                    )
        except Exception as e:
            self.logger.error(f"Current command execution failed: {str(e)}")
    
    def shutdown(self):
        """Shutdown the terminal console."""
        try:
            self.logger.info("Shutting down terminal console...")
            
            # Stop output monitoring
            self._monitor_active = False
            if self._output_monitor_thread:
                self._output_monitor_thread.join(timeout=5)
            
            # Terminate active processes
            for execution in self._active_executions.values():
                if execution.process_id:
                    try:
                        os.kill(execution.process_id, 9)
                    except:
                        pass
            
            self.logger.info("Terminal console shutdown complete")
            
        except Exception as e:
            self.logger.error(f"Error during terminal console shutdown: {str(e)}")