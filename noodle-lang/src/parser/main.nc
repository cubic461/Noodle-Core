# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# NoodleCore CLI Main Entry Point

# This module serves as the main entry point for the NoodleCore CLI system.
# It handles command-line argument parsing, request routing, and response formatting.

# Key Responsibilities:
# - Command-line argument parsing
# - Request ID generation and tracking
# - Command routing to appropriate handlers
- Response formatting (text, JSON, YAML)
# - Error handling and reporting
# """

import argparse
import asyncio
import json
import logging
import sys
import time
import uuid
import typing.Dict

import .commands.ai_command.AiCommand
import .commands.validate_command.ValidateCommand
import .commands.sandbox_command.SandboxCommand
import .commands.config_command.ConfigCommand
import .commands.logs_command.LogsCommand
import .command_router.get_command_router
import .cli_config.get_cli_config
import .exceptions.NoodleCliException

# Set up logging
logging.basicConfig(
level = logging.INFO,
format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
# )
logger = logging.getLogger(__name__)


class NoodleCli
    #     """Main CLI application class for NoodleCore."""

    #     def __init__(self):""Initialize the CLI application."""
    self.request_id = str(uuid.uuid4())
    self.config = get_cli_config()
    self.router = get_command_router()
    self.start_time = time.time()

    #         # Register commands with the router
            self._register_commands()

    #     def _register_commands(self) -None):
    #         """Register all commands with the router."""
    self.router.register_command('ai', AiCommand, aliases = ['a'])
    self.router.register_command('validate', ValidateCommand, aliases = ['val', 'v'])
    self.router.register_command('sandbox', SandboxCommand, aliases = ['sand', 's'])
    self.router.register_command('config', ConfigCommand, aliases = ['cfg', 'c'])
    self.router.register_command('logs', LogsCommand, aliases = ['log', 'l'])

    #     def create_parser(self) -argparse.ArgumentParser):
    #         """Create the main argument parser."""
    parser = argparse.ArgumentParser(
    prog = 'noodle',
    description = 'NoodleCore CLI - High-performance programming ecosystem CLI',
    formatter_class = argparse.RawDescriptionHelpFormatter,
    epilog = """
# Examples:
#   noodle ai zai query "What is NoodleCore?"
#   noodle validate file.nc --strict
#   noodle sandbox run --timeout 30
#   noodle config get ai_provider
#   noodle logs view --level ERROR
#             """
#         )

#         # Global arguments
        parser.add_argument(
#             '--version',
action = 'version',
version = '%(prog)s 1.0.0'
#         )

        parser.add_argument(
#             '--request-id',
type = str,
default = self.request_id,
#             help='Custom request ID for tracking'
#         )

        parser.add_argument(
#             '--output-format',
choices = ['text', 'json', 'yaml'],
default = self.config.get('NOODLE_OUTPUT_FORMAT', 'text'),
help = 'Output format (default: text)'
#         )

        parser.add_argument(
#             '--verbose',
action = 'store_true',
help = 'Enable verbose output'
#         )

        parser.add_argument(
#             '--debug',
action = 'store_true',
help = 'Enable debug mode'
#         )

        parser.add_argument(
#             '--trace',
action = 'store_true',
#             help='Enable detailed tracing for debugging'
#         )

        parser.add_argument(
#             '--dry-run',
action = 'store_true',
help = 'Show what would be done without executing'
#         )

        parser.add_argument(
#             '--timeout',
type = int,
default = self.config.get_int('NOODLE_REQUEST_TIMEOUT', 30),
help = 'Request timeout in seconds'
#         )

#         # Create subparsers for commands
subparsers = parser.add_subparsers(
dest = 'command',
help = 'Available commands',
metavar = 'COMMAND'
#         )

#         # Add command parsers
#         for command_name in self.router.list_commands():
#             command_class = self.router.get_command(command_name)
command_instance = command_class()

command_parser = subparsers.add_parser(
#                 command_name,
help = command_instance.get_help(),
formatter_class = argparse.RawDescriptionHelpFormatter
#             )

#             # Add common arguments to each command
            command_instance.add_common_arguments(command_parser)

#             # Add command-specific arguments
            command_instance.add_arguments(command_parser)

#         # Add alias parsers
#         for alias, command_name in self.router.list_aliases().items():
#             command_class = self.router.get_command(command_name)
command_instance = command_class()

command_parser = subparsers.add_parser(
#                 alias,
#                 help=f"Alias for '{command_name}' command",
formatter_class = argparse.RawDescriptionHelpFormatter
#             )

#             # Add common arguments to each alias
            command_instance.add_common_arguments(command_parser)

#             # Add command-specific arguments
            command_instance.add_arguments(command_parser)

#         return parser

#     async def run(self, args: Optional[list] = None) -int):
#         """
#         Run the CLI application.

#         Args:
            args: Command line arguments (defaults to sys.argv[1:])

#         Returns:
#             Exit code (0 for success, non-zero for error)
#         """
parser = self.create_parser()
parsed_args = parser.parse_args(args)

#         if not parsed_args.command:
            parser.print_help()
#             return 1

#         # Set up logging based on arguments
        self._setup_logging(parsed_args)

#         try:
#             # Log the request
logger.info(f"Request {parsed_args.request_id}: {parsed_args.command}", extra = {'command_args': vars(parsed_args)})

#             # Convert args to dictionary for router
args_dict = vars(parsed_args)
args_dict['command'] = parsed_args.command

#             # Add global settings
args_dict['trace'] = parsed_args.trace or self.config.is_tracing_enabled()
args_dict['dry_run'] = parsed_args.dry_run

#             # Execute the command through the router
result = await self.router.execute_command(
#                 parsed_args.command,
#                 args_dict,
timeout = parsed_args.timeout
#             )

#             # Format and output the result
formatted_result = self.format_output(result, parsed_args.output_format)
            print(formatted_result)

#             # Log completion
execution_time = time.time() - self.start_time
            logger.info(f"Request {parsed_args.request_id}: completed in {execution_time:.3f}s")

#             # Return appropriate exit code
#             return 0 if result.get('success', False) else 1

#         except KeyboardInterrupt:
            logger.warning(f"Request {parsed_args.request_id}: interrupted by user")
print("\nOperation cancelled by user", file = sys.stderr)
#             return 130

#         except Exception as e:
error_msg = f"Error: {str(e)}"
#             if parsed_args.debug or parsed_args.trace:
#                 import traceback
error_msg + = f"\n{traceback.format_exc()}"

print(error_msg, file = sys.stderr)
            logger.error(f"Request {parsed_args.request_id}: {error_msg}")
#             return 1

#     def _setup_logging(self, args: argparse.Namespace) -None):
#         """
#         Set up logging based on arguments.

#         Args:
#             args: Parsed command arguments
#         """
log_level = logging.INFO

#         if args.debug:
log_level = logging.DEBUG
#         elif args.trace:
log_level = logging.DEBUG
#             # Enable more detailed logging for trace mode
            logging.getLogger().setLevel(logging.DEBUG)

#         # Configure logger
        logger.setLevel(log_level)

#         if args.verbose:
#             # Enable verbose logging for all modules
            logging.getLogger().setLevel(logging.DEBUG)

#     def format_output(self, data: Dict[str, Any], format_type: str) -str):
#         """
#         Format output data according to the specified format.

#         Args:
#             data: Data to format
            format_type: Output format ('text', 'json', 'yaml')

#         Returns:
#             Formatted string
#         """
#         if format_type == 'json':
return json.dumps(data, indent = 2)
#         elif format_type == 'yaml':
#             try:
#                 import yaml
return yaml.dump(data, default_flow_style = False)
#             except ImportError:
#                 return "YAML format requires PyYAML package. Install with: pip install PyYAML"
#         else:  # text format
            return self.format_text_output(data)

#     def format_text_output(self, data: Dict[str, Any]) -str):
#         """Format data as plain text."""
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

#     def print_system_info(self) -None):
#         """Print system information for debugging."""
config_info = {
            'environment': self.config.get('NOODLE_ENV'),
            'debug_mode': self.config.is_debug_enabled(),
            'tracing_enabled': self.config.is_tracing_enabled(),
            'log_level': self.config.get('NOODLE_LOG_LEVEL'),
            'output_format': self.config.get('NOODLE_OUTPUT_FORMAT'),
            'timeout': self.config.get_int('NOODLE_REQUEST_TIMEOUT'),
            'max_connections': self.config.get_int('NOODLE_MAX_CONCURRENT_CONNECTIONS'),
#         }

        print("System Information:")
#         for key, value in config_info.items():
            print(f"  {key}: {value}")

        print("\nAvailable Commands:")
#         for command_name in self.router.list_commands():
#             command_class = self.router.get_command(command_name)
command_instance = command_class()
            print(f"  {command_name}: {command_instance.get_help()}")

        print("\nCommand Aliases:")
#         for alias, command_name in self.router.list_aliases().items():
            print(f"  {alias}: {command_name}")

        print("\nPerformance Statistics:")
stats = self.router.get_performance_stats()
#         if stats:
#             for command, data in stats.items():
                print(f"  {command}:")
                print(f"    Count: {data['count']}")
                print(f"    Avg Time: {data['avg_time']:.3f}s")
                print(f"    Min Time: {data['min_time']:.3f}s")
                print(f"    Max Time: {data['max_time']:.3f}s")
#         else:
            print("  No performance data available")


# async def main() -int):
#     """Main entry point for the CLI application."""
cli = NoodleCli()

#     # Handle special system info command
#     if len(sys.argv) 1 and sys.argv[1] == '--system-info'):
        cli.print_system_info()
#         return 0

    return await cli.run()


if __name__ == '__main__'
        sys.exit(asyncio.run(main()))
