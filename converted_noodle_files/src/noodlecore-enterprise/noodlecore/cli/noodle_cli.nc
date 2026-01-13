# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# NoodleCore CLI - Main CLI Interface for NoodleCore

# This module provides the main CLI interface for NoodleCore with the core
# commands: run and build. It follows the Noodle AI Coding Agent Development Standards.
# """

import os
import sys
import json
import logging
import uuid
import argparse
import traceback
import pathlib.Path
import typing.Dict,

# Add src to path to allow imports from noodle
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

# Import NoodleCore modules
import ..core_entry_point.CoreEntryPoint,
import ..structured_logging.get_logger,
import ..errors.NoodleCoreError
import ..config.ai_config.get_ai_config,

# Set up logging
logger = get_logger(__name__)

# Constants for error codes
ERROR_CODE_SUCCESS = 0
ERROR_CODE_GENERAL_ERROR = 1001
ERROR_CODE_FILE_NOT_FOUND = 1002
ERROR_CODE_COMPILATION_ERROR = 1003
ERROR_CODE_EXECUTION_ERROR = 1004
ERROR_CODE_INVALID_ARGUMENT = 1005


class NoodleCLIError(NoodleCoreError)
    #     """Custom exception for CLI errors with error codes."""

    #     def __init__(self, message: str, error_code: int = ERROR_CODE_GENERAL_ERROR):
            super().__init__(message)
    self.error_code = error_code


class NoodleCLI
    #     """
    #     Main CLI class for NoodleCore.

    #     This class provides the command-line interface for NoodleCore,
    #     including the run and build commands.
    #     """

    #     def __init__(self):
    #         """Initialize the CLI."""
    self.core_entry_point = None
    self.request_id = None
    self.verbose = False
    self.debug = False
    self.output_format = "text"
    self.config = {}
    self.ai_config = None

    #         # Initialize logging
            self._setup_logging()

    #         # Initialize AI configuration
            self._initialize_ai_config()

    #         # Initialize core entry point
            self._initialize_core()

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

            logger.info("Noodle CLI logging initialized")

    #     def _initialize_ai_config(self):
    #         """Initialize AI configuration from IDE or environment."""
    #         try:
    #             # Get AI configuration
    self.ai_config = get_ai_config()

    #             # Check for IDE configuration in environment variable
    ide_config_str = os.environ.get("NOODLE_IDE_CONFIG")
    #             if ide_config_str:
    #                 try:
    ide_config = json.loads(ide_config_str)
                        set_ide_config(ide_config)
                        logger.info("Loaded AI configuration from IDE")
    #                 except json.JSONDecodeError as e:
                        logger.warning(f"Failed to parse IDE configuration: {e}")

    #             # Check for configuration file argument
    #             if "--config" in sys.argv:
    config_index = sys.argv.index("--config")
    #                 if config_index + 1 < len(sys.argv):
    config_file = math.add(sys.argv[config_index, 1])
    #                     try:
    #                         with open(config_file, 'r') as f:
    config = json.load(f)
                            set_ide_config(config)
                            logger.info(f"Loaded AI configuration from {config_file}")
    #                     except Exception as e:
                            logger.error(f"Failed to load configuration from {config_file}: {e}")

                logger.info("AI configuration initialized successfully")
    #         except Exception as e:
                logger.error(f"Failed to initialize AI configuration: {e}")

    #     def _initialize_core(self):
    #         """Initialize the core entry point."""
    #         try:
    self.core_entry_point = CoreEntryPoint()

    #             # Initialize the core system
    #             if not self.core_entry_point.initialize():
                    raise NoodleCLIError(
    #                     "Failed to initialize NoodleCore system",
    #                     ERROR_CODE_GENERAL_ERROR
    #                 )

                logger.info("NoodleCore system initialized successfully")
    #         except Exception as e:
                logger.error(f"Failed to initialize NoodleCore: {e}")
                raise NoodleCLIError(
    #                 f"Failed to initialize NoodleCore: {e}",
    #                 ERROR_CODE_GENERAL_ERROR
    #             )

    #     def _generate_request_id(self) -> str:
    #         """Generate a unique request ID."""
    #         if not self.request_id:
    self.request_id = str(uuid.uuid4())
    #         return self.request_id

    #     def _format_output(self, data: Any, format_type: str = "text") -> str:
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

    #     def _handle_error(self, error: Exception, context: str = "") -> int:
    #         """Handle errors and return appropriate exit code."""
    #         if isinstance(error, NoodleCLIError):
    error_code = error.error_code
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

    #     def run_command(self, args: argparse.Namespace) -> int:
    #         """
    #         Execute the run command.

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
    #                 # Read code from file
    file_path = Path(args.file)
    #                 if not file_path.exists():
                        raise NoodleCLIError(
    #                         f"File not found: {args.file}",
    #                         ERROR_CODE_FILE_NOT_FOUND
    #                     )

    #                 with open(file_path, 'r', encoding='utf-8') as f:
    code = f.read()

                    logger.info(f"Executing Noodle program from file: {args.file}")
    #             else:
    #                 # Use code from argument
    code = args.code
                    logger.info("Executing Noodle program from command line")

    #             # Prepare execution parameters
    params = {
    #                 "code": code,
    #                 "request_id": request_id,
    #                 "debug": self.debug,
    #                 "timeout": args.timeout
    #             }

    #             # Execute the code
    result = self.core_entry_point.execute_command("execute", params)

    #             # Check result
    #             if result.get("status") == "success":
    output = result.get("output", "")
    #                 if output:
                        print(output)

    #                 if self.verbose:
                        print(f"\nExecution completed successfully (Request ID: {request_id})")

    #                 return ERROR_CODE_SUCCESS
    #             else:
    error_msg = result.get("error", "Unknown execution error")
                    raise NoodleCLIError(error_msg, ERROR_CODE_EXECUTION_ERROR)

    #         except Exception as e:
                return self._handle_error(e, "Failed to run Noodle program")

    #     def build_command(self, args: argparse.Namespace) -> int:
    #         """
    #         Execute the build command.

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
                    raise NoodleCLIError(
    #                     f"Source file not found: {args.source}",
    #                     ERROR_CODE_FILE_NOT_FOUND
    #                 )

    #             # Read source code
    #             with open(source_file, 'r', encoding='utf-8') as f:
    source_code = f.read()

    #             # Determine output file
    #             if args.output:
    output_file = Path(args.output)
    #             else:
    #                 # Default output file with .nbc extension
    output_file = source_file.with_suffix('.nbc')

                logger.info(f"Building Noodle program: {args.source} -> {output_file}")

    #             # Prepare build parameters
    params = {
    #                 "source_code": source_code,
                    "source_file": str(source_file),
                    "output_file": str(output_file),
    #                 "request_id": request_id,
    #                 "debug": self.debug,
    #                 "optimization_level": args.optimization_level,
    #                 "target": args.target
    #             }

    #             # Build the code
    result = self.core_entry_point.execute_command("build", params)

    #             # Check result
    #             if result.get("status") == "success":
    #                 # Get the compiled bytecode
    bytecode = result.get("bytecode")
    #                 if bytecode:
    #                     # Write bytecode to output file
    #                     with open(output_file, 'w', encoding='utf-8') as f:
    #                         if isinstance(bytecode, str):
                                f.write(bytecode)
    #                         else:
    #                             # If bytecode is not a string, serialize it as JSON
    json.dump(bytecode, f, indent = 2)

                        print(f"Successfully built: {output_file}")

    #                     if self.verbose:
    build_info = result.get("build_info", {})
                            print(f"Build completed (Request ID: {request_id})")
    #                         if build_info:
                                print("Build info:")
    #                             for key, value in build_info.items():
                                    print(f"  {key}: {value}")
    #                 else:
                        raise NoodleCLIError(
    #                         "Build completed but no bytecode generated",
    #                         ERROR_CODE_COMPILATION_ERROR
    #                     )

    #                 return ERROR_CODE_SUCCESS
    #             else:
    error_msg = result.get("error", "Unknown build error")
                    raise NoodleCLIError(error_msg, ERROR_CODE_COMPILATION_ERROR)

    #         except Exception as e:
                return self._handle_error(e, "Failed to build Noodle program")

    #     def create_parser(self) -> argparse.ArgumentParser:
    #         """
    #         Create the argument parser for the CLI.

    #         Returns:
    #             Configured argument parser
    #         """
    parser = argparse.ArgumentParser(
    prog = "noodle",
    #             description="NoodleCore CLI - Command-line interface for NoodleCore",
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

            parser.add_argument(
    #             "--timeout", "-t",
    type = int,
    default = 30,
    #             help="Timeout in seconds for operations"
    #         )

            parser.add_argument(
    #             "--config",
    help = "Path to AI configuration file"
    #         )

            parser.add_argument(
    #             "--request-id",
    #             help="Request ID for tracking (used by IDE integration)"
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
    help = "Run a Noodle program"
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

            run_parser.add_argument(
    #             "--timeout",
    type = int,
    default = 30,
    help = "Execution timeout in seconds"
    #         )

    #         # Build command
    build_parser = subparsers.add_parser(
    #             "build",
    help = "Build a Noodle program to NBC bytecode"
    #         )

            build_parser.add_argument(
    #             "source",
    help = "Source file to build"
    #         )

            build_parser.add_argument(
    #             "--output", "-o",
    #             help="Output file for compiled bytecode"
    #         )

            build_parser.add_argument(
    #             "--optimization-level", "-O",
    type = int,
    choices = [0, 1, 2, 3],
    default = 2,
    help = "Optimization level (0-3)"
    #         )

            build_parser.add_argument(
    #             "--target",
    choices = ["nbc", "python", "javascript"],
    default = "nbc",
    #             help="Target platform for compilation"
    #         )

    #         return parser

    #     def main(self, args: Optional[List[str]] = None) -> int:
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

    #             # Set request ID if provided
    #             if hasattr(parsed_args, 'request_id') and parsed_args.request_id:
    self.request_id = parsed_args.request_id

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
    #     """Main entry point for the Noodle CLI."""
    cli = NoodleCLI()
    exit_code = cli.main()
        sys.exit(exit_code)


if __name__ == "__main__"
        main()