# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# IDE-CLI Integration Module for NoodleCore

# This module provides a bridge between the IDE and CLI, allowing the IDE to start
# the CLI with proper configuration and handle communication between IDE and CLI processes.
# """

import os
import sys
import json
import uuid
import logging
import subprocess
import threading
import time
import typing.Dict,
import pathlib.Path
import queue.Queue,

import ..config.ai_config.get_ai_config,
import ..errors.NoodleCoreError

# Set up logging
logger = logging.getLogger(__name__)

# Constants for error codes
ERROR_CODE_CLI_START_FAILED = 3001
ERROR_CODE_CLI_COMMUNICATION_FAILED = 3002
ERROR_CODE_CLI_TIMEOUT = 3003
ERROR_CODE_INVALID_CONFIG = 3004


class CLIIntegrationError(NoodleCoreError)
    #     """Custom exception for CLI integration errors."""

    #     def __init__(self, message: str, error_code: int = ERROR_CODE_CLI_START_FAILED):
            super().__init__(message)
    self.error_code = error_code


class CLIProcess
    #     """Represents a running CLI process."""

    #     def __init__(self, process: subprocess.Popen, request_id: str):
    self.process = process
    self.request_id = request_id
    self.start_time = time.time()
    self.output_queue = Queue()
    self.error_queue = Queue()
    self.status = "running"
    self.return_code = None

    #         # Start output monitoring threads
    self._output_thread = threading.Thread(
    target = self._monitor_output,
    daemon = True
    #         )
    self._error_thread = threading.Thread(
    target = self._monitor_error,
    daemon = True
    #         )

            self._output_thread.start()
            self._error_thread.start()

    #     def _monitor_output(self) -> None:
    #         """Monitor stdout of the process."""
    #         try:
    #             for line in iter(self.process.stdout.readline, b''):
    #                 if line:
                        self.output_queue.put(line.decode('utf-8').rstrip())
    #                 else:
    #                     break
    #         except Exception as e:
                logger.error(f"Error monitoring CLI output: {e}")
    #         finally:
                self.process.stdout.close()

    #     def _monitor_error(self) -> None:
    #         """Monitor stderr of the process."""
    #         try:
    #             for line in iter(self.process.stderr.readline, b''):
    #                 if line:
                        self.error_queue.put(line.decode('utf-8').rstrip())
    #                 else:
    #                     break
    #         except Exception as e:
                logger.error(f"Error monitoring CLI error output: {e}")
    #         finally:
                self.process.stderr.close()

    #     def get_output(self, timeout: float = 0.1) -> List[str]:
    #         """
    #         Get available output from the process.

    #         Args:
    #             timeout: Timeout in seconds

    #         Returns:
    #             List of output lines
    #         """
    output = []
    #         try:
    #             while True:
    line = self.output_queue.get(timeout=timeout)
                    output.append(line)
    #         except Empty:
    #             pass
    #         return output

    #     def get_errors(self, timeout: float = 0.1) -> List[str]:
    #         """
    #         Get available error output from the process.

    #         Args:
    #             timeout: Timeout in seconds

    #         Returns:
    #             List of error lines
    #         """
    errors = []
    #         try:
    #             while True:
    line = self.error_queue.get(timeout=timeout)
                    errors.append(line)
    #         except Empty:
    #             pass
    #         return errors

    #     def is_running(self) -> bool:
    #         """Check if the process is still running."""
    #         if self.process.poll() is None:
    #             return True

    #         # Process has finished, update status
    self.return_code = self.process.poll()
    #         self.status = "completed" if self.return_code == 0 else "failed"
    #         return False

    #     def wait(self, timeout: Optional[float] = None) -> int:
    #         """
    #         Wait for the process to complete.

    #         Args:
    #             timeout: Timeout in seconds

    #         Returns:
    #             Return code
    #         """
    #         try:
    return_code = self.process.wait(timeout=timeout)
    self.return_code = return_code
    #             self.status = "completed" if return_code == 0 else "failed"
    #             return return_code
    #         except subprocess.TimeoutExpired:
    self.status = "timeout"
                raise CLIIntegrationError(
    #                 f"CLI process timed out after {timeout} seconds",
    #                 ERROR_CODE_CLI_TIMEOUT
    #             )

    #     def terminate(self) -> None:
    #         """Terminate the process."""
    #         try:
                self.process.terminate()
    self.status = "terminated"
    #         except Exception as e:
                logger.error(f"Failed to terminate CLI process: {e}")

    #     def kill(self) -> None:
    #         """Force kill the process."""
    #         try:
                self.process.kill()
    self.status = "killed"
    #         except Exception as e:
                logger.error(f"Failed to kill CLI process: {e}")


class CLIIntegration
    #     """
    #     Main class for IDE-CLI integration.

    #     This class provides a bridge between the IDE and CLI, allowing the IDE to start
    #     the CLI with proper configuration and handle communication between IDE and CLI processes.
    #     """

    #     def __init__(self, workspace_path: Optional[str] = None):
    #         """
    #         Initialize CLI integration.

    #         Args:
    #             workspace_path: Path to the workspace directory
    #         """
    self.workspace_path = workspace_path or os.getcwd()

    #         # Get AI configuration
    self.ai_config = get_ai_config(self.workspace_path)

    #         # CLI process management
    self.processes = {}
    self.default_timeout = 30

    #         # CLI path
    self.cli_path = self._find_cli_path()

    #         logger.info(f"CLI integration initialized with workspace: {self.workspace_path}")

    #     def _find_cli_path(self) -> str:
    #         """Find the path to the CLI executable."""
    #         # Try to find the CLI in the current environment
    possible_paths = [
    #             # Development paths
                os.path.join(os.path.dirname(__file__), "..", "..", "cli", "noodle_cli.py"),
                os.path.join(os.path.dirname(__file__), "..", "cli", "noodle_cli.py"),
                os.path.join(os.getcwd(), "noodle-core", "src", "noodlecore", "cli", "noodle_cli.py"),

    #             # Installation paths
    #             "noodle",
    #             "noodle-cli",
    #             "python -m noodlecore.cli.noodle_cli",
    #         ]

    #         for path in possible_paths:
    #             if os.path.exists(path) or path.startswith("python"):
                    logger.info(f"Found CLI at: {path}")
    #                 return path

    #         # Default to python module
    #         return "python -m noodlecore.cli.noodle_cli"

    #     def start_cli(
    #         self,
    #         command: str,
    args: Optional[List[str]] = None,
    config: Optional[Dict[str, Any]] = None,
    timeout: Optional[int] = None,
    capture_output: bool = True
    #     ) -> CLIProcess:
    #         """
    #         Start a CLI process with the given command and arguments.

    #         Args:
    #             command: CLI command to run
    #             args: Command arguments
    #             config: AI configuration to pass to CLI
    #             timeout: Process timeout in seconds
    #             capture_output: Whether to capture output

    #         Returns:
    #             CLI process instance

    #         Raises:
    #             CLIIntegrationError: If CLI process fails to start
    #         """
    #         try:
    #             # Generate request ID
    request_id = str(uuid.uuid4())

    #             # Prepare command
    cmd = self._prepare_command(command, args or [], config, request_id)

    #             # Set up environment
    env = os.environ.copy()
    #             if config:
    #                 # Pass configuration through environment variable
    env["NOODLE_IDE_CONFIG"] = json.dumps(config)

    #             # Start process
                logger.info(f"Starting CLI process: {' '.join(cmd)}")

    #             if capture_output:
    process = subprocess.Popen(
    #                     cmd,
    stdout = subprocess.PIPE,
    stderr = subprocess.PIPE,
    #                     text=False,  # Use bytes for better handling
    env = env,
    shell = True
    #                 )
    #             else:
    process = subprocess.Popen(
    #                     cmd,
    env = env,
    shell = True
    #                 )

    #             # Create CLI process wrapper
    cli_process = CLIProcess(process, request_id)

    #             # Store process
    self.processes[request_id] = cli_process

    #             # Set timeout if provided
    #             if timeout:
    cli_process.default_timeout = timeout

    #             return cli_process

    #         except Exception as e:
                logger.error(f"Failed to start CLI process: {e}")
                raise CLIIntegrationError(
                    f"Failed to start CLI process: {str(e)}",
    #                 ERROR_CODE_CLI_START_FAILED
    #             )

    #     def _prepare_command(
    #         self,
    #         command: str,
    #         args: List[str],
    #         config: Optional[Dict[str, Any]],
    #         request_id: str
    #     ) -> List[str]:
    #         """Prepare the CLI command."""
    #         # Base command
    cmd = [self.cli_path]

    #         # Add command
            cmd.append(command)

    #         # Add arguments
            cmd.extend(args)

    #         # Add request ID
            cmd.extend(["--request-id", request_id])

    #         # Add configuration if provided
    #         if config:
    #             # Write config to temporary file
    config_file = os.path.join(
    #                 self.workspace_path,
    #                 ".noodle",
    #                 f"cli_config_{request_id}.json"
    #             )
    os.makedirs(os.path.dirname(config_file), exist_ok = True)

    #             with open(config_file, 'w') as f:
    json.dump(config, f, indent = 2)

                cmd.extend(["--config", config_file])

    #         return cmd

    #     def execute_cli(
    #         self,
    #         command: str,
    args: Optional[List[str]] = None,
    config: Optional[Dict[str, Any]] = None,
    timeout: Optional[int] = None
    #     ) -> Dict[str, Any]:
    #         """
    #         Execute a CLI command and wait for completion.

    #         Args:
    #             command: CLI command to run
    #             args: Command arguments
    #             config: AI configuration to pass to CLI
    #             timeout: Process timeout in seconds

    #         Returns:
    #             Execution result
    #         """
    #         try:
    #             # Start CLI process
    process = self.start_cli(
    command = command,
    args = args,
    config = config,
    timeout = timeout or self.default_timeout
    #             )

    #             # Wait for completion
    return_code = process.wait(timeout=timeout or self.default_timeout)

    #             # Get output
    output = process.get_output(timeout=1.0)
    errors = process.get_errors(timeout=1.0)

    #             # Clean up
                self.cleanup_process(process.request_id)

    #             # Return result
    #             return {
    "success": return_code = = 0,
    #                 "return_code": return_code,
    #                 "output": output,
    #                 "errors": errors,
    #                 "request_id": process.request_id
    #             }

    #         except Exception as e:
                logger.error(f"Failed to execute CLI command: {e}")
    #             return {
    #                 "success": False,
    #                 "return_code": -1,
    #                 "output": [],
                    "errors": [str(e)],
    #                 "request_id": ""
    #             }

    #     def get_process(self, request_id: str) -> Optional[CLIProcess]:
    #         """
    #         Get a CLI process by request ID.

    #         Args:
    #             request_id: Request ID

    #         Returns:
    #             CLI process or None if not found
    #         """
            return self.processes.get(request_id)

    #     def cleanup_process(self, request_id: str) -> bool:
    #         """
    #         Clean up a CLI process.

    #         Args:
    #             request_id: Request ID

    #         Returns:
    #             True if process was cleaned up, False if not found
    #         """
    #         try:
    process = self.processes.get(request_id)
    #             if process:
    #                 # Terminate if still running
    #                 if process.is_running():
                        process.terminate()

    #                 # Remove from processes
    #                 del self.processes[request_id]

    #                 # Clean up config file if it exists
    config_file = os.path.join(
    #                     self.workspace_path,
    #                     ".noodle",
    #                     f"cli_config_{request_id}.json"
    #                 )
    #                 if os.path.exists(config_file):
                        os.remove(config_file)

                    logger.info(f"Cleaned up CLI process {request_id}")
    #                 return True

    #             return False

    #         except Exception as e:
                logger.error(f"Failed to clean up CLI process {request_id}: {e}")
    #             return False

    #     def cleanup_all_processes(self) -> int:
    #         """
    #         Clean up all CLI processes.

    #         Returns:
    #             Number of processes cleaned up
    #         """
    count = 0
    #         for request_id in list(self.processes.keys()):
    #             if self.cleanup_process(request_id):
    count + = 1

            logger.info(f"Cleaned up {count} CLI processes")
    #         return count

    #     def set_ai_config(self, config: Dict[str, Any]) -> None:
    #         """
    #         Set AI configuration from IDE.

    #         Args:
    #             config: AI configuration from IDE
    #         """
    #         try:
    #             # Validate configuration
                self._validate_ai_config(config)

    #             # Set configuration
                set_ide_config(config)

                logger.info("Updated AI configuration from IDE")

    #         except Exception as e:
                logger.error(f"Failed to set AI configuration: {e}")
                raise CLIIntegrationError(
                    f"Failed to set AI configuration: {str(e)}",
    #                 ERROR_CODE_INVALID_CONFIG
    #             )

    #     def _validate_ai_config(self, config: Dict[str, Any]) -> None:
    #         """Validate AI configuration."""
    #         # Check if providers exist
    #         if "providers" in config:
    #             if not isinstance(config["providers"], dict):
                    raise CLIIntegrationError(
    #                     "Providers configuration must be a dictionary",
    #                     ERROR_CODE_INVALID_CONFIG
    #                 )

    #             for name, provider_config in config["providers"].items():
    #                 if not isinstance(provider_config, dict):
                        raise CLIIntegrationError(
    #                         f"Provider configuration for '{name}' must be a dictionary",
    #                         ERROR_CODE_INVALID_CONFIG
    #                     )

    #                 # Check required fields
    #                 if "model" not in provider_config:
                        raise CLIIntegrationError(
    #                         f"Model not specified for provider '{name}'",
    #                         ERROR_CODE_INVALID_CONFIG
    #                     )

    #     def get_ai_config(self) -> Dict[str, Any]:
    #         """
    #         Get current AI configuration.

    #         Returns:
    #             Current AI configuration
    #         """
    #         return {
    #             "providers": {
                    name: provider.to_dict()
    #                 for name, provider in self.ai_config.get_all_providers()
    #             },
    #             "default_provider": self.ai_config.default_provider,
    #             "global_settings": self.ai_config.global_settings
    #         }

    #     def get_available_commands(self) -> List[Dict[str, Any]]:
    #         """
    #         Get available CLI commands.

    #         Returns:
    #             List of available commands
    #         """
    #         return [
    #             {
    #                 "name": "run",
    #                 "description": "Run a Noodle program",
    #                 "arguments": [
    #                     {
    #                         "name": "code",
    #                         "description": "Noodle code to execute",
    #                         "required": False
    #                     },
    #                     {
    #                         "name": "--file",
    #                         "description": "File containing Noodle code to execute",
    #                         "required": False
    #                     },
    #                     {
    #                         "name": "--timeout",
    #                         "description": "Execution timeout in seconds",
    #                         "required": False,
    #                         "type": "int"
    #                     }
    #                 ]
    #             },
    #             {
    #                 "name": "build",
    #                 "description": "Build a Noodle program to NBC bytecode",
    #                 "arguments": [
    #                     {
    #                         "name": "source",
    #                         "description": "Source file to build",
    #                         "required": True
    #                     },
    #                     {
    #                         "name": "--output",
    #                         "description": "Output file for compiled bytecode",
    #                         "required": False
    #                     },
    #                     {
    #                         "name": "--optimization-level",
                            "description": "Optimization level (0-3)",
    #                         "required": False,
    #                         "type": "int"
    #                     },
    #                     {
    #                         "name": "--target",
    #                         "description": "Target platform for compilation",
    #                         "required": False,
    #                         "choices": ["nbc", "python", "javascript"]
    #                     }
    #                 ]
    #             }
    #         ]

    #     def get_process_status(self, request_id: str) -> Optional[Dict[str, Any]]:
    #         """
    #         Get the status of a CLI process.

    #         Args:
    #             request_id: Request ID

    #         Returns:
    #             Process status or None if not found
    #         """
    process = self.get_process(request_id)
    #         if not process:
    #             return None

    #         return {
    #             "request_id": process.request_id,
    #             "status": process.status,
    #             "return_code": process.return_code,
                "is_running": process.is_running(),
    #             "start_time": process.start_time,
                "runtime": time.time() - process.start_time
    #         }

    #     def get_all_process_statuses(self) -> List[Dict[str, Any]]:
    #         """
    #         Get the status of all CLI processes.

    #         Returns:
    #             List of process statuses
    #         """
    #         return [
                self.get_process_status(request_id)
    #             for request_id in self.processes.keys()
    #         ]


# Global integration instance
_global_integration = None


def get_cli_integration(workspace_path: Optional[str] = None) -> CLIIntegration:
#     """
#     Get the global CLI integration instance.

#     Args:
#         workspace_path: Path to the workspace directory

#     Returns:
#         CLI integration instance
#     """
#     global _global_integration

#     if _global_integration is None:
_global_integration = CLIIntegration(workspace_path)

#     return _global_integration