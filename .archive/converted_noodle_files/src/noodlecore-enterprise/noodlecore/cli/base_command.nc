# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Base Command Class

# This module implements the abstract base class for all NoodleCore CLI commands.
# It provides common functionality for argument parsing, validation, error handling,
# and response formatting.
# """

import argparse
import asyncio
import logging
import time
import uuid
import abc.ABC,
import typing.Dict,

import .exceptions.(
#     NoodleCliException,
#     InvalidArgumentError,
#     MissingArgumentError,
#     format_error_response
# )
import .cli_config.get_cli_config

logger = logging.getLogger(__name__)


class BaseCommand(ABC)
    #     """Abstract base class for all CLI commands."""

    #     def __init__(self, name: Optional[str] = None):
    #         """
    #         Initialize the base command.

    #         Args:
    #             name: Command name (defaults to class name in snake_case)
    #         """
    self.name = name or self._get_default_name()
    self.config = get_cli_config()
    self.start_time = None
    self.request_id = None

    #     def _get_default_name(self) -> str:
    #         """Get default command name from class name."""
    class_name = self.__class__.__name__
    #         if class_name.endswith('Command'):
    class_name = class_name[:-7]  # Remove 'Command' suffix
    #         # Convert PascalCase to snake_case
    #         import re
    return re.sub(r'(?<!^)(? = [A-Z])', '_', class_name).lower()

    #     @abstractmethod
    #     def get_help(self) -> str:
    #         """
    #         Get help text for the command.

    #         Returns:
    #             Help text string
    #         """
    #         pass

    #     @abstractmethod
    #     def add_arguments(self, parser: argparse.ArgumentParser) -> None:
    #         """
    #         Add command-specific arguments to the parser.

    #         Args:
    #             parser: Argument parser to add arguments to
    #         """
    #         pass

    #     @abstractmethod
    #     async def execute(self, args: argparse.Namespace) -> Dict[str, Any]:
    #         """
    #         Execute the command.

    #         Args:
    #             args: Parsed command arguments

    #         Returns:
    #             Command result dictionary
    #         """
    #         pass

    #     def validate_args(self, args: argparse.Namespace) -> None:
    #         """
    #         Validate command arguments.

    #         Args:
    #             args: Parsed command arguments

    #         Raises:
    #             InvalidArgumentError: If arguments are invalid
    #             MissingArgumentError: If required arguments are missing
    #         """
    #         # Override in subclasses for custom validation
    #         pass

    #     async def run(self, args: argparse.Namespace) -> Dict[str, Any]:
    #         """
    #         Run the command with common functionality.

    #         Args:
    #             args: Parsed command arguments

    #         Returns:
    #             Command result dictionary
    #         """
    #         # Initialize timing and request ID
    self.start_time = time.time()
    self.request_id = getattr(args, 'request_id', str(uuid.uuid4()))

    #         # Add request ID to args if not present
    #         if not hasattr(args, 'request_id'):
    args.request_id = self.request_id

    #         try:
    #             # Validate arguments
                self.validate_args(args)

    #             # Check for dry run mode
    #             if getattr(args, 'dry_run', False):
                    return self._dry_run_response(args)

    #             # Execute the command
    result = await self.execute(args)

    #             # Add common response fields
    result['requestId'] = self.request_id
    result['success'] = True
    result['command'] = self.name
    result['execution_time'] = f"{time.time() - self.start_time:.3f}s"

    #             # Add audit trail if enabled
    #             if self.config.get_bool('NOODLE_ENABLE_AUDIT_LOG'):
                    await self._log_audit_trail(args, result)

    #             return result

    #         except NoodleCliException as e:
                logger.error(f"Command {self.name} failed: {e.message}")
                return format_error_response(e, self.request_id)

    #         except Exception as e:
                logger.error(f"Unexpected error in command {self.name}: {str(e)}")
    error = NoodleCliException(
                    f"Command execution failed: {str(e)}",
    error_code = 5000,
    details = {'command': self.name, 'original_error': str(e)}
    #             )
                return format_error_response(error, self.request_id)

    #     def _dry_run_response(self, args: argparse.Namespace) -> Dict[str, Any]:
    #         """
    #         Generate a dry run response.

    #         Args:
    #             args: Parsed command arguments

    #         Returns:
    #             Dry run response dictionary
    #         """
    #         return {
    #             'requestId': self.request_id,
    #             'success': True,
    #             'command': self.name,
    #             'dry_run': True,
    #             'message': f'Dry run: {self.name} command would be executed with these arguments',
                'args': vars(args),
                'execution_time': f"{time.time() - self.start_time:.3f}s"
    #         }

    #     async def _log_audit_trail(self, args: argparse.Namespace, result: Dict[str, Any]) -> None:
    #         """
    #         Log audit trail for the command execution.

    #         Args:
    #             args: Parsed command arguments
    #             result: Command result
    #         """
    audit_entry = {
                'timestamp': time.time(),
    #             'request_id': self.request_id,
    #             'command': self.name,
                'args': vars(args),
    #             'result': {
                    'success': result.get('success', False),
                    'execution_time': result.get('execution_time')
    #             },
                'user': self.config.get('NOODLE_USER', 'unknown')
    #         }

            logger.info(f"Audit trail: {audit_entry}")

    #     def format_output(self, data: Dict[str, Any], format_type: str = 'text') -> str:
    #         """
    #         Format output data according to the specified format.

    #         Args:
    #             data: Data to format
                format_type: Output format ('text', 'json', 'yaml')

    #         Returns:
    #             Formatted string
    #         """
    #         if format_type == 'json':
    #             import json
    return json.dumps(data, indent = 2)
    #         elif format_type == 'yaml':
    #             try:
    #                 import yaml
    return yaml.dump(data, default_flow_style = False)
    #             except ImportError:
    #                 return "YAML format requires PyYAML package. Install with: pip install PyYAML"
    #         else:  # text format
                return self._format_text_output(data)

    #     def _format_text_output(self, data: Dict[str, Any]) -> str:
    #         """
    #         Format data as plain text.

    #         Args:
    #             data: Data to format

    #         Returns:
    #             Formatted text string
    #         """
    #         if 'message' in data:
    #             return data['message']

    #         if 'result' in data:
                return str(data['result'])

    #         # Default formatting
    lines = []
    #         for key, value in data.items():
    #             if key not in ['requestId', 'success', 'execution_time']:
                    lines.append(f"{key}: {value}")

    #         if lines:
                return '\n'.join(lines)
    #         else:
    #             return "Command executed successfully"

    #     def add_common_arguments(self, parser: argparse.ArgumentParser) -> None:
    #         """
    #         Add common arguments to the parser.

    #         Args:
    #             parser: Argument parser to add arguments to
    #         """
            parser.add_argument(
    #             '--request-id',
    type = str,
    #             help='Custom request ID for tracking'
    #         )

            parser.add_argument(
    #             '--dry-run',
    action = 'store_true',
    help = 'Show what would be done without executing'
    #         )

            parser.add_argument(
    #             '--trace',
    action = 'store_true',
    help = 'Enable detailed tracing'
    #         )

            parser.add_argument(
    #             '--output-format',
    choices = ['text', 'json', 'yaml'],
    default = self.config.get('NOODLE_OUTPUT_FORMAT', 'text'),
    help = 'Output format'
    #         )

    #     def create_parser(self) -> argparse.ArgumentParser:
    #         """
    #         Create argument parser for the command.

    #         Returns:
    #             Configured argument parser
    #         """
    parser = argparse.ArgumentParser(
    prog = f'noodle {self.name}',
    description = self.get_help(),
    formatter_class = argparse.RawDescriptionHelpFormatter
    #         )

    #         # Add common arguments
            self.add_common_arguments(parser)

    #         # Add command-specific arguments
            self.add_arguments(parser)

    #         return parser

    #     async def handle_timeout(self, timeout_seconds: int) -> Dict[str, Any]:
    #         """
    #         Handle command timeout.

    #         Args:
    #             timeout_seconds: Timeout duration in seconds

    #         Returns:
    #             Timeout error response
    #         """
    #         from .exceptions import TimeoutError
    error = TimeoutError(self.name, timeout_seconds)
            return format_error_response(error, self.request_id)

    #     def get_progress_callback(self, total_steps: int = 100):
    #         """
    #         Get a progress callback function for long-running operations.

    #         Args:
    #             total_steps: Total number of steps

    #         Returns:
    #             Progress callback function
    #         """
    #         def progress_callback(current_step: int, message: str = ""):
    percentage = math.multiply((current_step / total_steps), 100)
                logger.info(f"Progress: {percentage:.1f}% - {message}")

    #         return progress_callback

    #     def validate_file_path(self, file_path: str, must_exist: bool = True) -> str:
    #         """
    #         Validate a file path argument.

    #         Args:
    #             file_path: File path to validate
    #             must_exist: Whether the file must exist

    #         Returns:
    #             Validated file path

    #         Raises:
    #             InvalidArgumentError: If file path is invalid
    #         """
    #         from pathlib import Path

    path = Path(file_path)

    #         if must_exist and not path.exists():
                raise InvalidArgumentError('file', file_path, 'File does not exist')

    #         if must_exist and not path.is_file():
                raise InvalidArgumentError('file', file_path, 'Path is not a file')

            return str(path.absolute())

    #     def validate_directory_path(self, dir_path: str, must_exist: bool = True) -> str:
    #         """
    #         Validate a directory path argument.

    #         Args:
    #             dir_path: Directory path to validate
    #             must_exist: Whether the directory must exist

    #         Returns:
    #             Validated directory path

    #         Raises:
    #             InvalidArgumentError: If directory path is invalid
    #         """
    #         from pathlib import Path

    path = Path(dir_path)

    #         if must_exist and not path.exists():
                raise InvalidArgumentError('directory', dir_path, 'Directory does not exist')

    #         if must_exist and not path.is_dir():
                raise InvalidArgumentError('directory', dir_path, 'Path is not a directory')

            return str(path.absolute())
