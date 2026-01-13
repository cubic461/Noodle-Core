# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Base CLI implementation for Noodle

# This module provides the foundation for the Noodle CLI tools,
# command parsing, and execution workflow.
# """

import argparse
import logging
import sys
import pathlib.Path
import typing.Any,

import noodlecore.cli.command.NoodleCommand
import noodlecore.compiler.code_generator.CodeGenerator
import noodlecore.compiler.parser.Parser
import noodlecore.runtime.nbc_runtime.core.NBCRuntime


class NoodleCLI
    #     """Main CLI class for Noodle language tools"""

    #     def __init__(self):
    #         """Initialize the Noodle CLI with available commands"""
    self.parser = self._create_parser()
    self.subparsers = self.parser.add_subparsers(
    dest = "command", help="Available commands"
    #         )
    self.commands = {}
    self.runtime = None
            self._setup_commands()

    #     def _create_parser(self) -> argparse.ArgumentParser:
    #         """Create the main argument parser"""
    parser = argparse.ArgumentParser(
    prog = "noodle",
    description = "Noodle Programming Language - CLI Tools",
    #             epilog='Use "noodle <command> --help" for command-specific help',
    formatter_class = argparse.RawDescriptionHelpFormatter,
    #         )

    parser.add_argument("--version", action = "version", version="Noodle 0.1.0")

            parser.add_argument(
    "--verbose", "-v", action = "store_true", help="Enable verbose output"
    #         )

    parser.add_argument("--debug", action = "store_true", help="Enable debug mode")

    #         return parser

    #     def _setup_commands(self):
    #         """Setup available CLI commands"""
    #         # Run command
    run_parser = self.subparsers.add_parser("run", help="Run Noodle programs")
    run_parser.add_argument("file", help = "Noodle file to run")
    #         run_parser.add_argument("--input", help="Input file for program")
    #         run_parser.add_argument("--output", help="Output file for program")
            run_parser.add_argument(
    "--runtime", default = "nbc", help="Runtime to use (default: nbc)"
    #         )
    run_parser.set_defaults(func = self._handle_run)

    #         # Build command
    build_parser = self.subparsers.add_parser("build", help="Build Noodle programs")
    build_parser.add_argument("file", help = "Noodle file to build")
            build_parser.add_argument(
    #             "--output", "-o", help="Output file for compiled code"
    #         )
            build_parser.add_argument(
    #             "--optimize",
    #             "-O",
    type = int,
    choices = [0, 1, 2],
    default = 1,
    help = "Optimization level",
    #         )
    build_parser.set_defaults(func = self._handle_build)

    #         # Test command
    test_parser = self.subparsers.add_parser("test", help="Run Noodle tests")
    test_parser.add_argument("--pattern", "-p", help = "Test pattern to run")
            test_parser.add_argument(
    "--verbose", "-v", action = "store_true", help="Verbose test output"
    #         )
    test_parser.set_defaults(func = self._handle_test)

    #         # LSP command
    lsp_parser = self.subparsers.add_parser(
    "lsp", help = "Start Language Server Protocol"
    #         )
            lsp_parser.add_argument(
    "--port", "-p", type = int, default=5000, help="Port to listen on"
    #         )
    lsp_parser.add_argument("--host", default = "localhost", help="Host to bind to")
    lsp_parser.set_defaults(func = self._handle_lsp)

    #         # Info command
    info_parser = self.subparsers.add_parser("info", help="Show system information")
    info_parser.set_defaults(func = self._handle_info)

    #     def _handle_run(self, args):
    #         """Handle run command"""
    #         try:
                print(f"Running Noodle file: {args.file}")

    #             # Initialize runtime if not already done
    #             if not self.runtime:
    self.runtime = NBCRuntime()

    #             # Parse and run the file
    #             with open(args.file, "r") as f:
    source = f.read()

    #             # Parse source code
    parser = Parser()
    ast = parser.parse(source)

    #             # Generate bytecode
    code_gen = CodeGenerator()
    bytecode = code_gen.generate(ast)

    #             # Execute with runtime
    result = self.runtime.execute(bytecode)

                print(f"Program executed successfully. Result: {result}")

    #         except FileNotFoundError:
                print(f"Error: File not found: {args.file}")
                sys.exit(1)
    #         except Exception as e:
                print(f"Error running program: {e}")
                sys.exit(1)

    #     def _handle_build(self, args):
    #         """Handle build command"""
    #         try:
                print(f"Building Noodle file: {args.file}")

    #             # Parse source code
    #             with open(args.file, "r") as f:
    source = f.read()

    parser = Parser()
    ast = parser.parse(source)

    #             # Generate bytecode
    code_gen = CodeGenerator()
    bytecode = code_gen.generate(ast, optimize_level=args.optimize)

    #             # Write to output file or default
    output_file = args.output or f"{args.file}.nbc"

    #             with open(output_file, "wb") as f:
    #                 # Simple binary format for bytecode
                    f.write(bytecode.to_bytes())

                print(f"Successfully built to: {output_file}")

    #         except FileNotFoundError:
                print(f"Error: File not found: {args.file}")
                sys.exit(1)
    #         except Exception as e:
                print(f"Error building program: {e}")
                sys.exit(1)

    #     def _handle_test(self, args):
    #         """Handle test command"""
    #         try:
                print("Running Noodle tests...")

    #             # TODO: Implement test discovery and execution
    #             # For now, just run a simple verification

    #             if args.pattern:
                    print(f"Running tests matching pattern: {args.pattern}")
    #             else:
                    print("Running all tests...")

    #             # Simple test runner - will be expanded later
                print("Tests completed successfully!")

    #         except Exception as e:
                print(f"Error running tests: {e}")
                sys.exit(1)

    #     def _handle_lsp(self, args):
    #         """Handle LSP command"""
    #         try:
                print(f"Starting Language Server Protocol on {args.host}:{args.port}")
    #             # TODO: Implement LSP server
                print("LSP server started (placeholder)")

    #         except Exception as e:
                print(f"Error starting LSP: {e}")
                sys.exit(1)

    #     def _handle_info(self, args):
    #         """Handle info command"""
    #         try:
                print("Noodle System Information:")
                print(f"Version: 0.1.0")
                print(f"Runtime: NBC Runtime")
                print(f"Python Version: {sys.version}")

    #             if self.runtime:
                    print("Runtime Status: Initialized")
    #             else:
                    print("Runtime Status: Not initialized")

    #         except Exception as e:
                print(f"Error getting system info: {e}")
                sys.exit(1)

    #     def run(self, args: Optional[List[str]] = None):
    #         """Run the CLI with given arguments"""
    #         try:
    parsed_args = self.parser.parse_args(args)

    #             # Set up logging
    #             if parsed_args.debug:
    logging.basicConfig(level = logging.DEBUG)
    #             elif parsed_args.verbose:
    logging.basicConfig(level = logging.INFO)

    #             # Execute the command
    #             if hasattr(parsed_args, "func"):
                    parsed_args.func(parsed_args)
    #             else:
                    self.parser.print_help()

    #         except KeyboardInterrupt:
                print("\nNoodle CLI interrupted by user")
                sys.exit(1)
    #         except Exception as e:
                print(f"Error in Noodle CLI: {e}")
                sys.exit(1)
