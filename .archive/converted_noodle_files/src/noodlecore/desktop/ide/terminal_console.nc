# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Terminal Console for NoodleCore Desktop IDE
#
# This module implements the terminal console component for the desktop IDE.
# """

import typing
import dataclasses
import enum
import logging
import os
import subprocess
import threading
import time
import queue
import pathlib.Path

# Import desktop GUI classes
import ...desktop.GUIError
import ..core.events.event_system.EventSystem,
import ..core.rendering.rendering_engine.RenderingEngine,
import ..core.components.component_library.ComponentLibrary,


class CommandResult(enum.Enum)
    #     """Command execution results."""
    SUCCESS = "success"
    ERROR = "error"
    TIMEOUT = "timeout"
    CANCELLED = "cancelled"


# @dataclasses.dataclass
class ConsoleOutput
    #     """Console output entry."""
    #     content: str
    #     timestamp: float
    output_type: str = "stdout"  # stdout, stderr, command
    command: str = ""
    result: CommandResult = CommandResult.SUCCESS

    #     def __post_init__(self):
    #         if self.timestamp == 0.0:
    self.timestamp = time.time()


# @dataclasses.dataclass
class ConsoleCommand
    #     """Console command execution."""
    #     command: str
    #     timestamp: float
    working_directory: str = ""
    environment: typing.Dict[str, str] = None
    timeout: float = 30.0

    #     def __post_init__(self):
    #         if self.timestamp == 0.0:
    self.timestamp = time.time()
    #         if self.environment is None:
    self.environment = {}


# @dataclasses.dataclass
class TerminalConfig
    #     """Configuration for terminal console."""
    font_family: str = "Consolas"
    font_size: int = 12
    background_color: Color = None
    foreground_color: Color = None
    selection_color: Color = None
    cursor_color: Color = None
    max_output_lines: int = 1000
    auto_scroll: bool = True
    show_timestamps: bool = True
    command_prompt: str = "$ "
    working_directory: str = "."
    #     shell_command: str = "cmd"  # Windows cmd, bash for Linux/Mac
    history_size: int = 100
    tab_completion: bool = True
    auto_resize: bool = True

    #     def __post_init__(self):
    #         if self.background_color is None:
    self.background_color = Color(0.05, 0.05, 0.05, 1.0)  # Dark background
    #         if self.foreground_color is None:
    self.foreground_color = Color(0.9, 0.9, 0.9, 1.0)    # Light text
    #         if self.selection_color is None:
    self.selection_color = Color(0.3, 0.6, 1.0, 0.3)
    #         if self.cursor_color is None:
    self.cursor_color = Color(1.0, 1.0, 1.0, 1.0)


class TerminalConsoleError(GUIError)
    #     """Exception raised for terminal console operations."""

    #     def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
            super().__init__(message, "8001", details)


class TerminalConsole
    #     """
    #     Terminal Console component for NoodleCore Desktop IDE.

    #     This class provides terminal/console functionality for command execution and output display.
    #     """

    #     def __init__(self):
    #         """Initialize the terminal console."""
    self.logger = logging.getLogger(__name__)
    self._window_id: typing.Optional[str] = None
    self._event_system: typing.Optional[EventSystem] = None
    self._rendering_engine: typing.Optional[RenderingEngine] = None
    self._component_library: typing.Optional[ComponentLibrary] = None
    self._config: typing.Optional[TerminalConfig] = None
    self._is_initialized = False

    #         # Terminal state
    self._current_directory: str = "."
    self._output_lines: typing.List[ConsoleOutput] = []
    self._command_history: typing.List[str] = []
    self._history_index: int = math.subtract(, 1)
    self._current_command: str = ""
    self._cursor_position: int = 0

    #         # Process management
    self._running_processes: typing.Dict[int, subprocess.Popen] = {}
    self._next_process_id: int = 1

    #         # UI components
    self._console_panel_id: typing.Optional[str] = None
    self._input_area_id: typing.Optional[str] = None

    #         # Threading
    self._command_queue: queue.Queue = queue.Queue()
    self._output_queue: queue.Queue = queue.Queue()
    self._command_thread: typing.Optional[threading.Thread] = None
    self._is_running: bool = False

    #         # Event callbacks
    self._on_command_executed: typing.Callable = None
    self._on_directory_changed: typing.Callable = None

    #         # Statistics
    self._stats = {
    #             'commands_executed': 0,
    #             'commands_succeeded': 0,
    #             'commands_failed': 0,
    #             'total_output_lines': 0,
    #             'average_command_time': 0.0,
    #             'last_command_time': 0.0
    #         }

    #     def initialize(self, window_id: str, event_system: EventSystem,
    #                   rendering_engine: RenderingEngine, component_library: ComponentLibrary,
    config: TerminalConfig = None):
    #         """
    #         Initialize the terminal console.

    #         Args:
    #             window_id: Window ID to attach to
    #             event_system: Event system instance
    #             rendering_engine: Rendering engine instance
    #             component_library: Component library instance
    #             config: Terminal configuration
    #         """
    #         try:
    self._window_id = window_id
    self._event_system = event_system
    self._rendering_engine = rendering_engine
    self._component_library = component_library
    self._config = config or TerminalConfig()

    #             # Create console UI components
                self._create_console_ui()

    #             # Initialize working directory
    self._current_directory = self._config.working_directory

    #             # Register event handlers
                self._register_event_handlers()

    #             # Start command processing thread
                self._start_command_processor()

    #             # Display welcome message
                self._display_welcome_message()

    self._is_initialized = True
                self.logger.info("Terminal console initialized")

    #         except Exception as e:
                self.logger.error(f"Failed to initialize terminal console: {e}")
                raise TerminalConsoleError(f"Initialization failed: {str(e)}")

    #     def _create_console_ui(self):
    #         """Create the terminal console UI components."""
    #         try:
    #             # Create main console panel
    self._console_panel_id = self._component_library.create_component(
    #                 ComponentType.PANEL, self._window_id,
                    ComponentProperties(
    x = 0, y=0, width=600, height=200,
    text = "",
    background_color = self._config.background_color,
    foreground_color = self._config.foreground_color,
    border = True
    #                 )
    #             )

    #             # Create input area
    self._input_area_id = self._component_library.create_component(
    #                 ComponentType.PANEL, self._window_id,
                    ComponentProperties(
    x = 5, y=180, width=590, height=15,
    text = "",
    background_color = self._config.background_color,
    foreground_color = self._config.foreground_color,
    border = False
    #                 )
    #             )

                self.logger.debug("Terminal console UI created")

    #         except Exception as e:
                self.logger.error(f"Failed to create console UI: {e}")
                raise TerminalConsoleError(f"UI creation failed: {str(e)}")

    #     def _register_event_handlers(self):
    #         """Register event handlers for the terminal console."""
    #         try:
    #             # Keyboard events for command input
                self._event_system.register_handler(
    #                 EventType.KEY_PRESS,
    #                 self._handle_key_press,
    window_id = self._window_id
    #             )

                self.logger.debug("Terminal console event handlers registered")

    #         except Exception as e:
                self.logger.error(f"Failed to register event handlers: {e}")
                raise TerminalConsoleError(f"Event handler registration failed: {str(e)}")

    #     def _handle_key_press(self, event_info):
    #         """Handle keyboard events for command input."""
    #         try:
    #             if hasattr(event_info, 'data') and event_info.data:
    keyboard_event = event_info.data.get('keyboard_event')
    #                 if keyboard_event:
                        self._process_key_input(keyboard_event)

    #         except Exception as e:
                self.logger.error(f"Error handling key press: {e}")

    #     def _process_key_input(self, keyboard_event: KeyboardEvent):
    #         """Process keyboard input."""
    #         try:
    #             # Handle special keys
    #             if keyboard_event.key == "Enter":
                    self._execute_command()
    #             elif keyboard_event.key == "Backspace":
    #                 if self._cursor_position > 0:
    self._current_command = (
    #                         self._current_command[:self._cursor_position - 1] +
    #                         self._current_command[self._cursor_position:]
    #                     )
    self._cursor_position - = 1
    #             elif keyboard_event.key == "Delete":
    #                 if self._cursor_position < len(self._current_command):
    self._current_command = (
    #                         self._current_command[:self._cursor_position] +
    #                         self._current_command[self._cursor_position + 1:]
    #                     )
    #             elif keyboard_event.key == "Left":
    #                 if self._cursor_position > 0:
    self._cursor_position - = 1
    #             elif keyboard_event.key == "Right":
    #                 if self._cursor_position < len(self._current_command):
    self._cursor_position + = 1
    #             elif keyboard_event.key == "Up":
                    self._navigate_history(-1)
    #             elif keyboard_event.key == "Down":
                    self._navigate_history(1)
    #             elif keyboard_event.key == "Tab":
                    self._handle_tab_completion()
    #             else:
    #                 # Regular character input
    #                 if keyboard_event.char and keyboard_event.char.isprintable():
    self._current_command = (
    #                         self._current_command[:self._cursor_position] +
    #                         keyboard_event.char +
    #                         self._current_command[self._cursor_position:]
    #                     )
    self._cursor_position + = 1

    #         except Exception as e:
                self.logger.error(f"Error processing key input: {e}")

    #     def _navigate_history(self, direction: int):
    #         """Navigate command history."""
    #         try:
    #             if not self._command_history:
    #                 return

    #             # Update history index
    self._history_index + = direction

    #             # Clamp index to valid range
    #             if self._history_index >= len(self._command_history):
    self._history_index = math.subtract(len(self._command_history), 1)
    #             elif self._history_index < -1:
    self._history_index = math.subtract(, 1)

    #             # Update current command
    #             if self._history_index == -1:
    self._current_command = ""
    self._cursor_position = 0
    #             else:
    self._current_command = self._command_history[self._history_index]
    self._cursor_position = len(self._current_command)

    #         except Exception as e:
                self.logger.error(f"Error navigating history: {e}")

    #     def _handle_tab_completion(self):
    #         """Handle tab completion for commands and paths."""
    #         try:
    #             if not self._config.tab_completion:
    #                 return

    #             # Simple tab completion for paths and commands
    #             # This is a basic implementation - would be more sophisticated in real terminal

    #             # Add tab character to indicate completion
    self._current_command + = "\t"
    self._cursor_position = len(self._current_command)

    #         except Exception as e:
                self.logger.error(f"Error handling tab completion: {e}")

    #     def _execute_command(self):
    #         """Execute the current command."""
    #         try:
    command = self._current_command.strip()
    #             if not command:
    #                 return

    #             # Add to history
    #             if command not in self._command_history:
                    self._command_history.append(command)
    #                 # Keep history within limit
    #                 if len(self._command_history) > self._config.history_size:
                        self._command_history.pop(0)

    #             # Reset for next command
    self._history_index = math.subtract(, 1)
    self._current_command = ""
    self._cursor_position = 0

    #             # Display command
                self._add_output(
    #                 f"{self._config.command_prompt}{command}",
    output_type = "command"
    #             )

    #             # Execute command
                self._queue_command(ConsoleCommand(
    command = command,
    working_directory = self._current_directory
    #             ))

    #         except Exception as e:
                self.logger.error(f"Error executing command: {e}")

    #     def _queue_command(self, console_command: ConsoleCommand):
    #         """Queue a command for execution."""
    #         try:
                self._command_queue.put(console_command)

    #         except Exception as e:
                self.logger.error(f"Error queuing command: {e}")

    #     def _start_command_processor(self):
    #         """Start the command processing thread."""
    #         try:
    self._is_running = True
    self._command_thread = threading.Thread(
    target = self._command_processor_loop,
    daemon = True
    #             )
                self._command_thread.start()

    #         except Exception as e:
                self.logger.error(f"Failed to start command processor: {e}")
                raise TerminalConsoleError(f"Command processor startup failed: {str(e)}")

    #     def _command_processor_loop(self):
    #         """Main command processing loop."""
    #         try:
    #             while self._is_running:
    #                 try:
    #                     # Get command from queue (with timeout)
    console_command = self._command_queue.get(timeout=1.0)

    #                     # Execute command
                        self._execute_console_command(console_command)

                        self._command_queue.task_done()

    #                 except queue.Empty:
    #                     continue
    #                 except Exception as e:
                        self.logger.error(f"Error in command processor: {e}")

    #         except Exception as e:
                self.logger.error(f"Command processor loop error: {e}")

    #     def _execute_console_command(self, console_command: ConsoleCommand):
    #         """Execute a console command."""
    #         try:
    start_time = time.time()

    #             # Handle built-in commands
    #             if self._handle_builtin_command(console_command):
    execution_time = math.subtract(time.time(), start_time)
    self._stats['commands_executed'] + = 1
    self._stats['commands_succeeded'] + = 1
    self._stats['last_command_time'] = execution_time
    #                 return

    #             # Execute external command
    #             try:
    #                 # Change to working directory
                    os.chdir(console_command.working_directory)

    #                 # Execute command
    process = subprocess.Popen(
    #                     console_command.command,
    shell = True,
    stdout = subprocess.PIPE,
    stderr = subprocess.PIPE,
    text = True,
    cwd = console_command.working_directory,
    env = console_command.environment
    #                 )

    #                 # Store process for monitoring
    process_id = self._next_process_id
    self._next_process_id + = 1
    self._running_processes[process_id] = process

    #                 # Wait for completion
    stdout, stderr = process.communicate(timeout=console_command.timeout)

    #                 # Display output
    #                 if stdout:
    self._add_output(stdout, output_type = "stdout")

    #                 if stderr:
    self._add_output(stderr, output_type = "stderr")

    #                 # Remove from running processes
    #                 del self._running_processes[process_id]

    #                 # Update statistics
    execution_time = math.subtract(time.time(), start_time)
    self._stats['commands_executed'] + = 1

    #                 if process.returncode == 0:
    self._stats['commands_succeeded'] + = 1
    #                 else:
    self._stats['commands_failed'] + = 1

    self._stats['last_command_time'] = execution_time

    #             except subprocess.TimeoutExpired:
    self._add_output("Command timed out", output_type = "stderr")
    self._stats['commands_failed'] + = 1

    #             except Exception as e:
    self._add_output(f"Command execution failed: {str(e)}", output_type = "stderr")
    self._stats['commands_failed'] + = 1

    #         except Exception as e:
                self.logger.error(f"Error executing console command: {e}")
    self._add_output(f"Command execution error: {str(e)}", output_type = "stderr")

    #     def _handle_builtin_command(self, console_command: ConsoleCommand) -> bool:
    #         """Handle built-in terminal commands."""
    #         try:
    command = console_command.command.strip()
    parts = command.split()
    #             if not parts:
    #                 return False

    cmd = parts[0].lower()

    #             if cmd == "cd":
    #                 if len(parts) > 1:
    new_dir = parts[1]
    #                     if new_dir == "..":
    new_dir = os.path.dirname(self._current_directory)
    #                     elif new_dir == "~":
    new_dir = os.path.expanduser("~")
    #                     elif not os.path.isabs(new_dir):
    new_dir = os.path.join(self._current_directory, new_dir)

    #                     if os.path.exists(new_dir) and os.path.isdir(new_dir):
    old_dir = self._current_directory
    self._current_directory = os.path.abspath(new_dir)
                            self._add_output(f"Changed directory from {old_dir} to {self._current_directory}")

    #                         if self._on_directory_changed:
                                self._on_directory_changed(self._current_directory)
    #                     else:
    self._add_output(f"Directory not found: {parts[1]}", output_type = "stderr")
    #                 else:
    #                     # cd with no arguments - go to home directory
    home_dir = os.path.expanduser("~")
    #                     if os.path.exists(home_dir):
    old_dir = self._current_directory
    self._current_directory = home_dir
                            self._add_output(f"Changed directory from {old_dir} to {self._current_directory}")

    #                         if self._on_directory_changed:
                                self._on_directory_changed(self._current_directory)

    #             elif cmd == "pwd":
                    self._add_output(self._current_directory)

    #             elif cmd == "ls":
    #                 try:
    items = os.listdir(self._current_directory)
                        self._add_output("  ".join(sorted(items)))
    #                 except Exception as e:
    self._add_output(f"ls error: {str(e)}", output_type = "stderr")

    #             elif cmd == "clear":
                    self._clear_output()

    #             elif cmd == "help":
    help_text = """
# Available built-in commands:
#   cd [dir]     - Change directory
#   pwd          - Print working directory
#   ls           - List directory contents
#   clear        - Clear terminal output
#   help         - Show this help message
# """
                self._add_output(help_text)

#             else:
#                 return False  # Not a built-in command

#             return True

#         except Exception as e:
            self.logger.error(f"Error handling built-in command: {e}")
#             return False

#     def _add_output(self, content: str, output_type: str = "stdout", command: str = ""):
#         """Add output to the console."""
#         try:
#             # Split content into lines and add each as separate output
lines = content.splitlines()
#             for line in lines:
output = ConsoleOutput(
content = line,
timestamp = time.time(),
output_type = output_type,
command = command
#                 )
                self._output_lines.append(output)

#                 # Keep output within limit
#                 if len(self._output_lines) > self._config.max_output_lines:
                    self._output_lines.pop(0)

self._stats['total_output_lines'] + = 1

#             # Auto-scroll if enabled
#             if self._config.auto_scroll:
                self._scroll_to_bottom()

#         except Exception as e:
            self.logger.error(f"Error adding output: {e}")

#     def _clear_output(self):
#         """Clear all console output."""
#         try:
            self._output_lines.clear()
            self._add_output("Console cleared")

#         except Exception as e:
            self.logger.error(f"Error clearing output: {e}")

#     def _scroll_to_bottom(self):
#         """Scroll console to bottom."""
#         try:
#             # This would implement scrolling in real terminal
#             pass

#         except Exception as e:
            self.logger.error(f"Error scrolling to bottom: {e}")

#     def _display_welcome_message(self):
#         """Display welcome message."""
#         try:
welcome_text = f"""
# NoodleCore Terminal Console
 = =========================
Working Directory: {os.getcwd()}
# Type 'help' for available commands.
# """
            self._add_output(welcome_text)

#         except Exception as e:
            self.logger.error(f"Error displaying welcome message: {e}")

#     def execute_command(self, command: str, working_directory: str = None) -> bool:
#         """Execute a command programmatically."""
#         try:
#             if working_directory is None:
working_directory = self._current_directory

console_command = ConsoleCommand(
command = command,
working_directory = working_directory
#             )

            self._queue_command(console_command)
#             return True

#         except Exception as e:
            self.logger.error(f"Failed to execute command: {e}")
#             return False

#     def set_environment_variable(self, name: str, value: str):
#         """Set an environment variable for commands."""
#         try:
#             # This would update the environment for subsequent commands
#             # Implementation would depend on how environment is managed
self.logger.debug(f"Set environment variable: {name} = {value}")

#         except Exception as e:
            self.logger.error(f"Error setting environment variable: {e}")

#     def set_on_command_executed_callback(self, callback: typing.Callable):
#         """Set callback for command execution events."""
self._on_command_executed = callback

#     def set_on_directory_changed_callback(self, callback: typing.Callable):
#         """Set callback for directory change events."""
self._on_directory_changed = callback

#     def get_current_directory(self) -> str:
#         """Get the current working directory."""
#         return self._current_directory

#     def get_output_history(self, limit: int = None) -> typing.List[ConsoleOutput]:
#         """Get console output history."""
#         if limit is None:
            return self._output_lines.copy()
#         else:
#             return self._output_lines[-limit:]

#     def get_command_history(self) -> typing.List[str]:
#         """Get command history."""
        return self._command_history.copy()

#     def clear_history(self):
#         """Clear command history."""
        self._command_history.clear()
self._history_index = math.subtract(, 1)

#     def get_stats(self) -> typing.Dict[str, typing.Any]:
#         """Get terminal console statistics."""
stats = self._stats.copy()
        stats.update({
#             'current_directory': self._current_directory,
            'running_processes': len(self._running_processes),
            'output_lines': len(self._output_lines),
            'command_history_size': len(self._command_history)
#         })
#         return stats

#     def is_initialized(self) -> bool:
#         """Check if the terminal console is initialized."""
#         return self._is_initialized

#     def shutdown(self):
#         """Shutdown the terminal console."""
#         try:
self._is_running = False

#             # Stop command processing thread
#             if self._command_thread and self._command_thread.is_alive():
self._command_thread.join(timeout = 5)

#             # Terminate running processes
#             for process_id, process in self._running_processes.items():
#                 try:
                    process.terminate()
#                 except Exception:
#                     pass

            self._running_processes.clear()

            self.logger.info("Terminal console shutdown complete")

#         except Exception as e:
            self.logger.error(f"Error during shutdown: {e}")


# Export main classes
__all__ = ['CommandResult', 'ConsoleOutput', 'ConsoleCommand', 'TerminalConfig', 'TerminalConsole']