# """
# Terminal Console for NoodleCore Desktop IDE
# 
# This module implements an interactive terminal with command execution,
# output redirection, and integration with NoodleCore execution environment.
# """

import typing
import dataclasses
import enum
import logging
import uuid
import time
import subprocess
import threading
import queue
import io
import os
import sys

from ...desktop import GUIError
from ..core.events.event_system import EventSystem, EventType, MouseEvent, KeyboardEvent
from ..core.rendering.rendering_engine import RenderingEngine, Color
from ..core.components.component_library import ComponentLibrary


class ExecutionStatus(Enum):
    # """Execution status types."""
    IDLE = "idle"
    RUNNING = "running"
    COMPLETED = "completed"
    ERROR = "error"
    INTERRUPTED = "interrupted"
    TIMEOUT = "timeout"


class OutputType(Enum):
    # """Output type enumeration."""
    STDOUT = "stdout"
    STDERR = "stderr"
    INPUT = "input"
    SYSTEM = "system"
    ERROR = "error"
    PROGRESS = "progress"


class CommandHistory:
    # """Command history entry."""
    
    def __init__(self, command: str, timestamp: float, directory: str, status: ExecutionStatus):
        self.command = command
        self.timestamp = timestamp
        self.directory = directory
        self.status = status
        self.output = ""


@dataclasses.dataclass
class TerminalOutput:
    # """Terminal output entry."""
    output_id: str
    content: str
    output_type: OutputType
    timestamp: float
    command_id: str = None
    color: Color = None
    
    def __post_init__(self):
        if self.color is None:
            self._set_color_by_type()
    
    def _set_color_by_type(self):
        # """Set color based on output type."""
        if self.output_type == OutputType.STDOUT:
            self.color = Color(0.86, 0.88, 0.91, 1.0)  # White
        elif self.output_type == OutputType.STDERR:
            self.color = Color(1.0, 0.54, 0.54, 1.0)  # Red
        elif self.output_type == OutputType.ERROR:
            self.color = Color(1.0, 0.32, 0.32, 1.0)  # Dark red
        elif self.output_type == OutputType.SYSTEM:
            self.color = Color(0.54, 0.86, 0.54, 1.0)  # Green
        elif self.output_type == OutputType.PROGRESS:
            self.color = Color(0.32, 0.54, 1.0, 1.0)  # Blue
        else:
            self.color = Color(0.8, 0.8, 0.8, 1.0)  # Gray


@dataclasses.dataclass
class TerminalSession:
    # """Terminal session information."""
    session_id: str
    name: str
    working_directory: str
    environment: typing.Dict[str, str]
    creation_time: float
    last_activity: float
    is_active: bool = True
    
    def __post_init__(self):
        if self.environment is None:
            self.environment = {k: v for k, v in os.environ.items()}
        if self.last_activity is None:
            self.last_activity = time.time()


@dataclasses.dataclass
class ExecutionOptions:
    # """Command execution options."""
    timeout: float = 30.0  # 30 seconds
    working_directory: str = None
    environment: typing.Dict[str, str] = None
    capture_output: bool = True
    use_sandbox: bool = True
    max_memory: int = 512  # MB
    allow_network: bool = False


@dataclasses.dataclass
class ExecutionResult:
    # """Command execution result."""
    result_id: str
    command: str
    status: ExecutionStatus
    exit_code: int = 0
    stdout: str = ""
    stderr: str = ""
    execution_time: float = 0.0
    memory_usage: float = 0.0
    timestamp: float = None
    
    def __post_init__(self):
        if self.timestamp is None:
            self.timestamp = time.time()


class TerminalConsoleError(GUIError):
    # """Exception raised for terminal operations."""
    
    def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
        super().__init__(message, "10001", details)


class ExecutionError(TerminalConsoleError):
    # """Raised when command execution fails."""
    
    def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
        super().__init__(message, "10002", details)


class SessionError(TerminalConsoleError):
    # """Raised when session operations fail."""
    
    def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
        super().__init__(message, "10003", details)


class TerminalConsole:
    # """
    # Terminal Console for NoodleCore Desktop IDE.
    # 
    # This class provides interactive terminal functionality with command execution,
    # output capture, session management, and NoodleCore integration.
    # """
    
    def __init__(self):
        # """Initialize the terminal console."""
        self.logger = logging.getLogger(__name__)
        
        # Core GUI systems
        self._event_system = None
        self._rendering_engine = None
        self._component_library = None
        
        # Window and component references
        self._window_id = None
        self._terminal_component_id = None
        self._input_component_id = None
        
        # Terminal state
        self._current_session: typing.Optional[TerminalSession] = None
        self._sessions: typing.Dict[str, TerminalSession] = {}
        self._output_buffer: typing.List[TerminalOutput] = []
        self._command_history: typing.List[CommandHistory] = []
        self._current_command = ""
        self._cursor_position = 0
        
        # Execution management
        self._running_processes: typing.Dict[str, subprocess.Popen] = {}
        self._execution_queue: queue.Queue = queue.Queue()
        self._output_queue: queue.Queue = queue.Queue()
        
        # Configuration
        self._max_history = 100
        self._max_buffer_lines = 1000
        self._default_timeout = 30.0
        self._auto_scroll = True
        self._show_line_numbers = False
        
        # Environment
        self._safe_environment = True
        self._restricted_commands = [
            "rm", "del", "format", "fdisk", "mkfs",
            "shutdown", "reboot", "halt", "poweroff"
        ]
        
        # Metrics
        self._metrics = {
            "commands_executed": 0,
            "sessions_created": 0,
            "total_execution_time": 0.0,
            "output_lines": 0,
            "errors_encountered": 0,
            "processes_terminated": 0
        }
        
        # Initialize default session
        self._create_default_session()
    
    def _create_default_session(self):
        # """Create default terminal session."""
        try:
            session = TerminalSession(
                session_id=str(uuid.uuid4()),
                name="Main Terminal",
                working_directory=os.getcwd(),
                environment={k: v for k, v in os.environ.items()},
                creation_time=time.time(),
                last_activity=time.time()
            )
            
            self._sessions[session.session_id] = session
            self._current_session = session
            
            # Welcome message
            welcome_message = self._create_welcome_message()
            self._add_output(welcome_message, OutputType.SYSTEM)
            
            self._metrics["sessions_created"] += 1
            
        except Exception as e:
            self.logger.error(f"Failed to create default session: {str(e)}")
    
    def _create_welcome_message(self) -> str:
        # """Create welcome message for terminal."""
        return f"""
NoodleCore IDE Terminal v1.0
Type 'help' for available commands.
Type 'exit' to close the terminal.
Working directory: {self._current_session.working_directory}
Python version: {sys.version.split()[0]}
System: {os.name}
"""
    
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
            
            # Create terminal components
            self._create_terminal_interface()
            
            # Register event handlers
            self._register_event_handlers()
            
            # Start background processing
            self._start_background_processes()
            
            self.logger.info("Terminal console initialized")
            
        except Exception as e:
            self.logger.error(f"Failed to initialize terminal console: {str(e)}")
            raise TerminalConsoleError(f"Terminal console initialization failed: {str(e)}")
    
    def _create_terminal_interface(self):
        # """Create the terminal interface components."""
        try:
            # Create terminal output area
            self._terminal_component_id = self._component_library.create_component(
                component_type="terminal",
                window_id=self._window_id,
                x=0,
                y=0,
                width=800,
                height=400,
                background_color=Color(0.0, 0.0, 0.0, 1.0),  # Black background
                text_color=Color(0.86, 0.88, 0.91, 1.0)     # White text
            )
            
            # Create input area
            self._input_component_id = self._component_library.create_component(
                component_type="text_edit",
                window_id=self._window_id,
                x=0,
                y=400,
                width=800,
                height=25,
                text="",
                font="Consolas",
                font_size=12
            )
            
            # Set up terminal prompt
            self._update_prompt()
            
            self.logger.info("Terminal interface created")
            
        except Exception as e:
            self.logger.error(f"Failed to create terminal interface: {str(e)}")
            raise TerminalConsoleError(f"Terminal interface creation failed: {str(e)}")
    
    def _register_event_handlers(self):
        # """Register event handlers."""
        try:
            # Command input
            self._event_system.register_handler(
                EventType.KEY_PRESS,
                self._handle_key_press,
                window_id=self._window_id
            )
            
            # Command submission
            self._event_system.register_handler(
                EventType.KEY_PRESS,
                self._handle_command_submit,
                window_id=self._window_id
            )
            
            # Process output
            self._event_system.register_handler(
                EventType.TEXT_CHANGE,
                self._handle_text_change,
                window_id=self._window_id
            )
            
        except Exception as e:
            self.logger.error(f"Failed to register event handlers: {str(e)}")
            raise TerminalConsoleError(f"Event handler registration failed: {str(e)}")
    
    def _start_background_processes(self):
        # """Start background processing threads."""
        try:
            # Start output processor
            self._output_thread = threading.Thread(target=self._process_output_queue, daemon=True)
            self._output_thread.start()
            
            # Start execution processor
            self._execution_thread = threading.Thread(target=self._process_execution_queue, daemon=True)
            self._execution_thread.start()
            
        except Exception as e:
            self.logger.error(f"Failed to start background processes: {str(e)}")
            raise TerminalConsoleError(f"Background processes failed: {str(e)}")
    
    def execute_command(self, command: str, options: ExecutionOptions = None) -> str:
        # """
        # Execute a command in the terminal.
        
        Args:
            command: Command to execute
            options: Execution options
        
        Returns:
            Execution result ID
        """
        try:
            if options is None:
                options = ExecutionOptions()
            
            # Validate command
            if not self._validate_command(command):
                raise ExecutionError(f"Command validation failed: {command}")
            
            # Create execution result
            result_id = str(uuid.uuid4())
            result = ExecutionResult(
                result_id=result_id,
                command=command,
                status=ExecutionStatus.RUNNING,
                timestamp=time.time()
            )
            
            # Add to queue
            self._execution_queue.put((result, command, options))
            
            # Show command in terminal
            self._show_command(command)
            
            # Add to history
            history_entry = CommandHistory(
                command=command,
                timestamp=time.time(),
                directory=self._current_session.working_directory,
                status=ExecutionStatus.RUNNING
            )
            self._command_history.append(history_entry)
            
            # Update metrics
            self._metrics["commands_executed"] += 1
            self._current_session.last_activity = time.time()
            
            self.logger.info(f"Executing command: {command}")
            return result_id
            
        except Exception as e:
            self.logger.error(f"Failed to execute command {command}: {str(e)}")
            raise ExecutionError(f"Command execution failed: {str(e)}")
    
    def interrupt_execution(self, result_id: str = None) -> bool:
        # """
        # Interrupt currently running command.
        
        Args:
            result_id: Execution result ID to interrupt (None for current)
        
        Returns:
            True if successful
        """
        try:
            if result_id is None:
                # Interrupt current execution
                for rid, process in self._running_processes.items():
                    if process.poll() is None:  # Process is running
                        process.terminate()
                        self._running_processes[rid] = None
                        
                        # Update metrics
                        self._metrics["processes_terminated"] += 1
                        
                        self._add_output("Command interrupted\n", OutputType.SYSTEM)
                        return True
                return False
            else:
                # Interrupt specific execution
                if result_id in self._running_processes:
                    process = self._running_processes[result_id]
                    if process and process.poll() is None:
                        process.terminate()
                        self._running_processes[result_id] = None
                        
                        self._metrics["processes_terminated"] += 1
                        self._add_output("Command interrupted\n", OutputType.SYSTEM)
                        return True
            
            return False
            
        except Exception as e:
            self.logger.error(f"Failed to interrupt execution {result_id}: {str(e)}")
            return False
    
    def create_session(self, name: str, working_directory: str = None) -> str:
        # """
        # Create a new terminal session.
        
        Args:
            name: Session name
            working_directory: Working directory for session
        
        Returns:
            Session ID
        """
        try:
            session_id = str(uuid.uuid4())
            session = TerminalSession(
                session_id=session_id,
                name=name,
                working_directory=working_directory or os.getcwd(),
                environment={k: v for k, v in os.environ.items()},
                creation_time=time.time(),
                last_activity=time.time()
            )
            
            self._sessions[session_id] = session
            self._metrics["sessions_created"] += 1
            
            self.logger.info(f"Created session: {name} ({session_id})")
            return session_id
            
        except Exception as e:
            self.logger.error(f"Failed to create session {name}: {str(e)}")
            raise SessionError(f"Session creation failed: {str(e)}")
    
    def switch_session(self, session_id: str) -> bool:
        # """
        # Switch to a different terminal session.
        
        Args:
            session_id: ID of session to switch to
        
        Returns:
            True if successful
        """
        try:
            if session_id not in self._sessions:
                return False
            
            # Update prompt for new session
            self._current_session = self._sessions[session_id]
            self._update_prompt()
            
            self.logger.info(f"Switched to session: {session_id}")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to switch to session {session_id}: {str(e)}")
            return False
    
    def clear_screen(self):
        # """Clear the terminal screen."""
        try:
            self._output_buffer.clear()
            self._component_library.set_component_text(
                self._terminal_component_id,
                ""
            )
            self._update_prompt()
            
        except Exception as e:
            self.logger.error(f"Failed to clear screen: {str(e)}")
    
    def get_command_history(self, limit: int = 50) -> typing.List[CommandHistory]:
        # """
        # Get command history.
        
        Args:
            limit: Maximum number of entries to return
        
        Returns:
            List of command history entries
        """
        return self._command_history[-limit:] if self._command_history else []
    
    def get_sessions(self) -> typing.Dict[str, TerminalSession]:
        # """Get all terminal sessions."""
        return self._sessions.copy()
    
    def get_active_session(self) -> typing.Optional[TerminalSession]:
        # """Get current active session."""
        return self._current_session
    
    def set_environment_variable(self, name: str, value: str):
        # """
        # Set environment variable for current session.
        
        Args:
            name: Variable name
            value: Variable value
        """
        if self._current_session:
            self._current_session.environment[name] = value
    
    def set_working_directory(self, directory: str):
        # """
        # Set working directory for current session.
        
        Args:
            directory: Working directory path
        """
        if self._current_session:
            if os.path.exists(directory) and os.path.isdir(directory):
                self._current_session.working_directory = directory
                self._update_prompt()
    
    def get_current_directory(self) -> str:
        # """Get current working directory."""
        return self._current_session.working_directory if self._current_session else os.getcwd()
    
    def get_metrics(self) -> typing.Dict[str, typing.Any]:
        # """Get terminal console metrics."""
        return self._metrics.copy()
    
    # Private methods
    
    def _validate_command(self, command: str) -> bool:
        # """Validate command for security."""
        if not command or not command.strip():
            return False
        
        # Check for restricted commands
        cmd_parts = command.strip().split()
        if not cmd_parts:
            return False
        
        base_command = cmd_parts[0].lower()
        if base_command in self._restricted_commands:
            self._add_output(f"Command '{base_command}' is restricted\n", OutputType.ERROR)
            return False
        
        # Basic security checks
        dangerous_patterns = ['&&', '||', '|', '>', '<', '`', '$(']
        if any(pattern in command.lower() for pattern in dangerous_patterns):
            if self._safe_environment:
                self._add_output("Command contains potentially dangerous patterns\n", OutputType.WARNING)
                return False
        
        return True
    
    def _show_command(self, command: str):
        # """Display command in terminal."""
        prompt = self._get_prompt()
        command_display = f"{prompt}{command}\n"
        self._add_output(command_display, OutputType.INPUT)
    
    def _update_prompt(self):
        # """Update terminal prompt."""
        if self._current_session:
            directory = os.path.basename(self._current_session.working_directory)
            if not directory:
                directory = self._current_session.working_directory
            prompt = f"noodle@{directory}$ "
            self._current_prompt = prompt
    
    def _get_prompt(self) -> str:
        # """Get current prompt string."""
        return getattr(self, '_current_prompt', "noodle$ ")
    
    def _add_output(self, content: str, output_type: OutputType):
        # """
        # Add output to terminal buffer.
        
        Args:
            content: Output content
            output_type: Type of output
        """
        try:
            terminal_output = TerminalOutput(
                output_id=str(uuid.uuid4()),
                content=content,
                output_type=output_type,
                timestamp=time.time()
            )
            
            self._output_buffer.append(terminal_output)
            
            # Limit buffer size
            if len(self._output_buffer) > self._max_buffer_lines:
                self._output_buffer = self._output_buffer[-self._max_buffer_lines:]
            
            # Update metrics
            self._metrics["output_lines"] += content.count('\n')
            
            # Add to output queue for processing
            self._output_queue.put(terminal_output)
            
        except Exception as e:
            self.logger.error(f"Failed to add output: {str(e)}")
    
    def _process_output_queue(self):
        # """Process output queue in background thread."""
        while True:
            try:
                output = self._output_queue.get(timeout=1)
                self._update_terminal_display(output)
                self._output_queue.task_done()
            except queue.Empty:
                continue
            except Exception as e:
                self.logger.error(f"Error processing output queue: {str(e)}")
    
    def _process_execution_queue(self):
        # """Process execution queue in background thread."""
        while True:
            try:
                result, command, options = self._execution_queue.get(timeout=1)
                self._execute_command_async(result, command, options)
                self._execution_queue.task_done()
            except queue.Empty:
                continue
            except Exception as e:
                self.logger.error(f"Error processing execution queue: {str(e)}")
    
    def _execute_command_async(self, result: ExecutionResult, command: str, options: ExecutionOptions):
        # """Execute command asynchronously."""
        try:
            start_time = time.time()
            
            # Prepare environment
            env = dict(os.environ)
            if options.environment:
                env.update(options.environment)
            
            # Set working directory
            cwd = options.working_directory or self._current_session.working_directory
            
            # Execute command
            process = subprocess.Popen(
                command,
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                cwd=cwd,
                env=env,
                text=True,
                universal_newlines=True
            )
            
            # Store running process
            self._running_processes[result.result_id] = process
            
            # Wait for completion with timeout
            try:
                stdout, stderr = process.communicate(timeout=options.timeout)
                
                result.stdout = stdout
                result.stderr = stderr
                result.exit_code = process.returncode
                result.status = ExecutionStatus.COMPLETED if process.returncode == 0 else ExecutionStatus.ERROR
                
            except subprocess.TimeoutExpired:
                process.kill()
                stdout, stderr = process.communicate()
                result.stdout = stdout
                result.stderr = stderr
                result.status = ExecutionStatus.TIMEOUT
            
            # Calculate execution time
            result.execution_time = time.time() - start_time
            
            # Update metrics
            self._metrics["total_execution_time"] += result.execution_time
            
            # Add output
            if result.stdout:
                self._add_output(result.stdout, OutputType.STDOUT)
            if result.stderr:
                self._add_output(result.stderr, OutputType.STDERR)
            
            # Update command history
            for history_entry in self._command_history:
                if history_entry.timestamp == result.timestamp:
                    history_entry.status = result.status
                    break
            
            # Remove from running processes
            if result.result_id in self._running_processes:
                del self._running_processes[result.result_id]
            
        except Exception as e:
            result.status = ExecutionStatus.ERROR
            result.stderr = str(e)
            self._metrics["errors_encountered"] += 1
            self._add_output(f"Error executing command: {str(e)}\n", OutputType.ERROR)
    
    def _update_terminal_display(self, output: TerminalOutput):
        # """Update terminal display with new output."""
        try:
            # Get current display content
            current_text = self._component_library.get_component_text(
                self._terminal_component_id
            )
            
            # Append new output
            new_text = current_text + output.content
            
            # Update display
            self._component_library.set_component_text(
                self._terminal_component_id,
                new_text
            )
            
            # Auto-scroll if enabled
            if self._auto_scroll:
                self._component_library.scroll_to_bottom(self._terminal_component_id)
            
        except Exception as e:
            self.logger.error(f"Failed to update terminal display: {str(e)}")
    
    # Event handlers
    
    def _handle_key_press(self, event: KeyboardEvent):
        # """Handle keyboard input."""
        # In real implementation, would handle arrow keys, tab completion, etc.
        self.logger.debug(f"Key press: {event.key}")
    
    def _handle_command_submit(self, event: KeyboardEvent):
        # """Handle command submission."""
        # In real implementation, would detect Enter key and execute command
        if event.key == "Enter":
            # Get command from input component
            command = self._component_library.get_component_text(
                self._input_component_id
            ).strip()
            
            if command:
                self.execute_command(command)
                # Clear input
                self._component_library.set_component_text(
                    self._input_component_id,
                    ""
                )
    
    def _handle_text_change(self, event):
        # """Handle text changes in input."""
        # Track cursor position and enable command history navigation
        self.logger.debug("Text changed in terminal input")