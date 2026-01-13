# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Native NoodleCore CLI - Command-line interface for the native NoodleCore runtime

# This module provides the CLI interface for the native NoodleCore runtime,
# demonstrating that NoodleCore works independently of Python wrappers.
# """

import os
import sys
import json
import logging
import uuid
import argparse
import traceback
import pathlib.Path
import typing.Dict

# Add src to path to allow imports from noodle
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

# Import NoodleCore modules
import ..runtime.native.NoodleRuntime
import ..structured_logging.get_logger
import ..errors.NoodleCoreError

# Set up logging
logger = get_logger(__name__)

# Constants for error codes
ERROR_CODE_SUCCESS = 0
ERROR_CODE_GENERAL_ERROR = 1001
ERROR_CODE_FILE_NOT_FOUND = 1002
ERROR_CODE_COMPILATION_ERROR = 1003
ERROR_CODE_EXECUTION_ERROR = 1004
ERROR_CODE_INVALID_ARGUMENT = 1005


class NativeCLIError(NoodleCoreError)
    #     """Custom exception for native CLI errors with error codes."""

    #     def __init__(self, message: str, error_code: int = ERROR_CODE_GENERAL_ERROR):
            super().__init__(message)
    self.error_code = error_code


class NativeNoodleCLI
    #     """
    #     Native CLI class for NoodleCore.

    #     This class provides the command-line interface for the native NoodleCore runtime,
    #     demonstrating that NoodleCore works independently of Python wrappers.
    #     """

    #     def __init__(self):""Initialize the CLI."""
    self.runtime = None
    self.request_id = None
    self.verbose = False
    self.debug = False
    self.output_format = "text"
    self.config = {}

    #         # Initialize logging
            self._setup_logging()

    #         # Initialize native runtime
            self._initialize_runtime()

    #     def _setup_logging(self):
    #         """Set up logging based on environment variables."""
    #         # Get log level from environment
    log_level = os.environ.get("NOODLE_LOG_LEVEL", "INFO").upper()

    #         # Set debug mode from environment
    self.debug = os.environ.get("NOODLE_DEBUG", "0") == "1"

    #         # Initialize logging
            initialize_logging(
    log_level = getattr(logging, log_level, logging.INFO),
    #             log_format="json" if self.debug else "text"
    #         )

            logger.info("Native Noodle CLI logging initialized")

    #     def _initialize_runtime(self):
    #         """Initialize the native NoodleCore runtime."""
    #         try:
    self.runtime = NoodleRuntime(debug=self.debug)
                logger.info("Native NoodleCore runtime initialized successfully")
    #         except Exception as e:
                logger.error(f"Failed to initialize native NoodleCore runtime: {e}")
                raise NativeCLIError(
    #                 f"Failed to initialize native NoodleCore runtime: {e}",
    #                 ERROR_CODE_GENERAL_ERROR
    #             )

    #     def _generate_request_id(self) -str):
    #         """Generate a unique request ID."""
    #         if not self.request_id:
    self.request_id = str(uuid.uuid4())
    #         return self.request_id

    #     def _format_output(self, data: Any, format_type: str = "text") -str):
    #         """Format output data based on the specified format."""
    #         if format_type == "json":
    return json.dumps(data, indent = 2)
    #         elif format_type == "yaml":
    #             try:
    #                 import yaml
    return yaml.dump(data, default_flow_style = False)
    #             except ImportError:
                    logger.warning("PyYAML not installed, falling back to JSON")
    return json.dumps(data, indent = 2)
    #         else:
    #             # Default text format
    #             if isinstance(data, dict):
    #                 if "status" in data:
    #                     if data["status"] == "success":
                            return data.get("message", "Operation completed successfully")
    #                     else:
                            return f"Error: {data.get('error', 'Unknown error')}"
    #                 else:
                        return str(data)
    #             else:
                    return str(data)

    #     def _handle_error(self, error: Exception, context: str = "") -int):
    #         """Handle errors and return appropriate exit code."""
    #         if isinstance(error, NativeCLIError):
    error_code = error.error_code
    error_message = str(error)
    #         elif isinstance(error, NoodleRuntimeError):
    error_code = ERROR_CODE_EXECUTION_ERROR
    error_message = str(error)
    #         else:
    error_code = ERROR_CODE_GENERAL_ERROR
    error_message = f"Unexpected error: {str(error)}"

    #         if context:
    error_message = f"{context}: {error_message}"

            logger.error(error_message)

    #         if self.debug:
                logger.debug(f"Error details: {traceback.format_exc()}")

    print(f"Error: {error_message}", file = sys.stderr)
    #         return error_code

    #     def run_command(self, args: argparse.Namespace) -int):
    #         """
    #         Execute the run command using the native runtime.

    #         Args:
    #             args: Parsed command-line arguments

    #         Returns:
    #             Exit code
    #         """
    #         try:
    #             # Generate request ID
    request_id = self._generate_request_id()

    #             # Get the code to execute
    #             if args.file:
    #                 # Run Noodle file using native runtime
    file_path = Path(args.file)
    #                 if not file_path.exists():
                        raise NativeCLIError(
    #                         f"File not found: {args.file}",
    #                         ERROR_CODE_FILE_NOT_FOUND
    #                     )

                    logger.info(f"Executing Noodle program from file: {args.file}")

    #                 # Execute using native runtime
    result = self.runtime.run_file(str(file_path))

    #                 # Print output
    #                 if result['output']:
    #                     for line in result['output']:
                            print(line)

    #                 if self.verbose:
                        print(f"\nExecution completed successfully (Request ID: {request_id})")
                        print(f"Execution time: {result['execution_time']:.4f}s")
                        print(f"Instructions executed: {result['instruction_count']}")

    #                 return ERROR_CODE_SUCCESS
    #             else:
    #                 # Use code from argument
    code = args.code
                    logger.info("Executing Noodle program from command line")

    #                 # Execute using native runtime
    result = self.runtime.run_source(code)

    #                 # Print output
    #                 if result['output']:
    #                     for line in result['output']:
                            print(line)

    #                 if self.verbose:
                        print(f"\nExecution completed successfully (Request ID: {request_id})")
                        print(f"Execution time: {result['execution_time']:.4f}s")
                        print(f"Instructions executed: {result['instruction_count']}")

    #                 return ERROR_CODE_SUCCESS

    #         except Exception as e:
                return self._handle_error(e, "Failed to run Noodle program")

    #     def build_command(self, args: argparse.Namespace) -int):
    #         """
    #         Execute the build command using the native runtime.

    #         Args:
    #             args: Parsed command-line arguments

    #         Returns:
    #             Exit code
    #         """
    #         try:
    #             # Generate request ID
    request_id = self._generate_request_id()

    #             # Get the source file
    source_file = Path(args.source)
    #             if not source_file.exists():
                    raise NativeCLIError(
    #                     f"Source file not found: {args.source}",
    #                     ERROR_CODE_FILE_NOT_FOUND
    #                 )

    #             # Determine output file
    #             if args.output:
    output_file = Path(args.output)
    #             else:
    #                 # Default output file with .nbc extension
    output_file = source_file.with_suffix('.nbc')

                logger.info(f"Building Noodle program: {args.source} -{output_file}")

    #             # Compile using native runtime
                self.runtime.compile_to_bytecode(str(source_file), str(output_file))

                print(f"Successfully built): {output_file}")

    #             if self.verbose:
                    print(f"Build completed (Request ID: {request_id})")

    #             return ERROR_CODE_SUCCESS

    #         except Exception as e:
                return self._handle_error(e, "Failed to build Noodle program")

    #     def execute_command(self, args: argparse.Namespace) -int):
    #         """
    #         Execute the execute command for bytecode files.

    #         Args:
    #             args: Parsed command-line arguments

    #         Returns:
    #             Exit code
    #         """
    #         try:
    #             # Generate request ID
    request_id = self._generate_request_id()

    #             # Get the bytecode file
    bytecode_file = Path(args.bytecode)
    #             if not bytecode_file.exists():
                    raise NativeCLIError(
    #                     f"Bytecode file not found: {args.bytecode}",
    #                     ERROR_CODE_FILE_NOT_FOUND
    #                 )

                logger.info(f"Executing Noodle bytecode: {args.bytecode}")

    #             # Load and execute bytecode using native runtime
    bytecode = self.runtime.load_bytecode(str(bytecode_file))
    result = self.runtime.execute_bytecode(bytecode, args.function)

    #             # Print output
    #             if result['output']:
    #                 for line in result['output']:
                        print(line)

    #             if self.verbose:
                    print(f"\nExecution completed successfully (Request ID: {request_id})")
                    print(f"Execution time: {result['execution_time']:.4f}s")
                    print(f"Instructions executed: {result['instruction_count']}")
                    print(f"Function: {args.function}")

    #             return ERROR_CODE_SUCCESS

    #         except Exception as e:
                return self._handle_error(e, "Failed to execute Noodle bytecode")

    #     def create_parser(self) -argparse.ArgumentParser):
    #         """
    #         Create the argument parser for the CLI.

    #         Returns:
    #             Configured argument parser
    #         """
    parser = argparse.ArgumentParser(
    prog = "noodle-native",
    #             description="Native NoodleCore CLI - Command-line interface for the native NoodleCore runtime",
    formatter_class = argparse.ArgumentDefaultsHelpFormatter
    #         )

    #         # Global options
            parser.add_argument(
    #             "--verbose", "-v",
    action = "store_true",
    help = "Enable verbose output"
    #         )

            parser.add_argument(
    #             "--debug", "-d",
    action = "store_true",
    help = "Enable debug output"
    #         )

            parser.add_argument(
    #             "--format", "-f",
    choices = ["text", "json", "yaml"],
    default = "text",
    help = "Output format"
    #         )

    #         # Subcommands
    subparsers = parser.add_subparsers(
    dest = "command",
    help = "Available commands",
    metavar = "COMMAND"
    #         )

    #         # Run command
    run_parser = subparsers.add_parser(
    #             "run",
    help = "Run a Noodle program using the native runtime"
    #         )

    run_group = run_parser.add_mutually_exclusive_group(required=True)
            run_group.add_argument(
    #             "code",
    nargs = "?",
    help = "Noodle code to execute"
    #         )
            run_group.add_argument(
    #             "--file", "-f",
    help = "File containing Noodle code to execute"
    #         )

    #         # Build command
    build_parser = subparsers.add_parser(
    #             "build",
    help = "Build a Noodle program to native bytecode"
    #         )

            build_parser.add_argument(
    #             "source",
    help = "Source file to build"
    #         )

            build_parser.add_argument(
    #             "--output", "-o",
    #             help="Output file for compiled bytecode"
    #         )

    #         # Execute command
    execute_parser = subparsers.add_parser(
    #             "execute",
    help = "Execute compiled Noodle bytecode"
    #         )

            execute_parser.add_argument(
    #             "bytecode",
    help = "Bytecode file to execute"
    #         )

            execute_parser.add_argument(
    #             "--function", "-f",
    default = "main",
    help = "Function to execute (default: main)"
    #         )

    #         return parser

    #     def main(self, args: Optional[List[str]] = None) -int):
    #         """
    #         Main entry point for the CLI.

    #         Args:
                args: Command-line arguments (defaults to sys.argv[1:])

    #         Returns:
    #             Exit code
    #         """
    #         try:
    #             # Parse arguments
    parser = self.create_parser()
    parsed_args = parser.parse_args(args)

    #             # Set instance variables from arguments
    self.verbose = parsed_args.verbose
    self.debug = parsed_args.debug or self.debug
    self.output_format = parsed_args.format

    #             # Update logging level if debug is enabled
    #             if self.debug:
                    logging.getLogger().setLevel(logging.DEBUG)

    #             # Check if a command was provided
    #             if not parsed_args.command:
                    parser.print_help()
    #                 return ERROR_CODE_INVALID_ARGUMENT

    #             # Execute the appropriate command
    #             if parsed_args.command == "run":
                    return self.run_command(parsed_args)
    #             elif parsed_args.command == "build":
                    return self.build_command(parsed_args)
    #             elif parsed_args.command == "execute":
                    return self.execute_command(parsed_args)
    #             else:
    print(f"Unknown command: {parsed_args.command}", file = sys.stderr)
                    parser.print_help()
    #                 return ERROR_CODE_INVALID_ARGUMENT

    #         except KeyboardInterrupt:
    print("\nOperation cancelled by user", file = sys.stderr)
    #             return ERROR_CODE_GENERAL_ERROR
    #         except Exception as e:
                return self._handle_error(e, "CLI error")


function main()
    #     """Main entry point for the native Noodle CLI."""
    cli = NativeNoodleCLI()
    exit_code = cli.main()
        sys.exit(exit_code)


if __name__ == "__main__"
        main()