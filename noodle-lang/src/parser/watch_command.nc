# Converted from Python to NoodleCore
# Original file: src

# """
# Watch Command Module
# --------------------

# This module implements the watch command for the NoodleCore CLI enforcement system.
# The watch command follows live changes in directory and validates real-time.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import argparse
import asyncio
import json
import logging
import os
import sys
import time
import pathlib.Path
import typing.Any

import noodlecore.cli.command_handlers.CommandContext
import noodlecore.cli.error_handler.CLIError
import noodlecore.compiler.frontend.get_frontend
import noodlecore.linter.NoodleLinter


class WatchCommand
    #     """Command to watch for file changes and validate in real-time."""

    #     def __init__(self):""Initialize the watch command."""
    self.logger = logging.getLogger(__name__)
    self.compiler_frontend = get_frontend()
    self.linter = NoodleLinter(LinterConfig(
    enable_syntax_check = True,
    enable_semantic_check = True,
    strict_mode = os.environ.get("NOODLE_STRICT_MODE", "false").lower() == "true"
    #         ))
    self._watching = False
    self._file_states = {}  # Track file modification times

    #     def add_arguments(self, parser: argparse.ArgumentParser) -None):
    #         """Add command-specific arguments to the parser."""
            parser.add_argument(
    #             "directory",
    nargs = "?",
    default = ".",
    help = "Directory to watch (default: current directory)"
    #         )
            parser.add_argument(
    #             "--pattern",
    default = "**/*.noodle",
    help = "File pattern to watch (default: **/*.noodle)"
    #         )
            parser.add_argument(
    #             "--interval",
    type = float,
    default = 1.0,
    help = "Check interval in seconds (default: 1.0)"
    #         )
            parser.add_argument(
    #             "--syntax-only",
    action = "store_true",
    help = "Only perform syntax checking"
    #         )
            parser.add_argument(
    #             "--json",
    action = "store_true",
    help = "Output results in JSON format"
    #         )
            parser.add_argument(
    #             "--teach",
    action = "store_true",
    #             help="Provide AI feedback for learning"
    #         )
            parser.add_argument(
    #             "--initial-scan",
    action = "store_true",
    default = True,
    help = "Perform initial scan of directory"
    #         )
            parser.add_argument(
    #             "--no-initial-scan",
    dest = "initial_scan",
    action = "store_false",
    help = "Skip initial scan of directory"
    #         )
            parser.add_argument(
    #             "--exclude",
    action = "append",
    help = "Patterns to exclude from watching (can be used multiple times)"
    #         )

    #     async def execute(self, context: CommandContext) -Dict[str, Any]):
    #         """Execute the watch command."""
    directory = context.args.directory
    pattern = context.args.pattern
    interval = context.args.interval
    syntax_only = context.args.syntax_only
    output_json = context.args.json
    teach = context.args.teach
    initial_scan = context.args.initial_scan
    exclude_patterns = context.args.exclude or []

            self.logger.info(f"Starting to watch directory: {directory}")

    #         # Check if directory exists
    #         if not os.path.exists(directory):
                raise CLIError(1012, f"Directory not found: {directory}")

    #         if not os.path.isdir(directory):
                raise CLIError(1012, f"Path is not a directory: {directory}")

    results = {
    #             "directory": directory,
    #             "pattern": pattern,
    #             "interval": interval,
    #             "request_id": context.request_id,
    #             "teach": teach,
    #             "syntax_only": syntax_only,
    #             "exclude_patterns": exclude_patterns
    #         }

    #         # Initialize file tracking
    self._watching = True
    self._file_states = {}

    #         # Perform initial scan if requested
    #         if initial_scan:
                print(f"Performing initial scan of {directory}...")
    initial_results = await self._scan_directory(directory, pattern, syntax_only, teach, output_json, exclude_patterns)
    results["initial_scan"] = initial_results

    #         # Start watching for changes
    #         print(f"Watching for changes in {directory} (Press Ctrl+C to stop)...")

    #         try:
    #             while self._watching:
                    await self._check_for_changes(directory, pattern, syntax_only, teach, output_json, exclude_patterns)
                    await asyncio.sleep(interval)
    #         except KeyboardInterrupt:
                print("\nStopping file watcher...")
    self._watching = False

    results["stopped"] = True
    #         return results

    #     async def _scan_directory(self, directory: str, pattern: str, syntax_only: bool,
    #                             teach: bool, output_json: bool, exclude_patterns: List[str]) -Dict[str, Any]):
    #         """Perform an initial scan of the directory."""
    scan_results = {
    #             "files_found": 0,
    #             "files_valid": 0,
    #             "files_invalid": 0,
    #             "files_with_errors": []
    #         }

    #         # Find all matching files
    path_obj = Path(directory)
    files = list(path_obj.glob(pattern))

    #         # Filter out excluded patterns
    #         if exclude_patterns:
    filtered_files = []
    #             for file in files:
    exclude = False
    #                 for exclude_pattern in exclude_patterns:
    #                     if file.match(exclude_pattern):
    exclude = True
    #                         break
    #                 if not exclude:
                        filtered_files.append(file)
    files = filtered_files

    scan_results["files_found"] = len(files)

    #         # Validate each file
    #         for file_path in files:
    #             if file_path.is_file():
    #                 try:
    #                     # Record initial file state
    self._file_states[str(file_path)] = file_path.stat().st_mtime

    #                     # Validate the file
    result = await self._validate_file(str(file_path), syntax_only)

    #                     if result["valid"]:
    scan_results["files_valid"] + = 1
    #                         if not output_json:
                                print(f"✓ {file_path}")
    #                     else:
    scan_results["files_invalid"] + = 1
                            scan_results["files_with_errors"].append({
                                "file": str(file_path),
                                "errors": result.get("errors", [])
    #                         })
    #                         if not output_json:
                                print(f"✗ {file_path}")

    #                             # Show errors if teaching mode is enabled
    #                             if teach:
    #                                 for error in result.get("errors", []):
                                        print(f"    - {error}")

    #                 except Exception as e:
    scan_results["files_invalid"] + = 1
                        scan_results["files_with_errors"].append({
                            "file": str(file_path),
                            "errors": [f"Failed to validate: {str(e)}"]
    #                     })
    #                     if not output_json:
                            print(f"? {file_path} (Error: {str(e)})")

    #         # Summary
    #         if not output_json:
                print(f"\nInitial scan complete: {scan_results['files_valid']}/{scan_results['files_found']} files valid")

    #         return scan_results

    #     async def _check_for_changes(self, directory: str, pattern: str, syntax_only: bool,
    #                                teach: bool, output_json: bool, exclude_patterns: List[str]) -None):
    #         """Check for file changes and validate modified files."""
    path_obj = Path(directory)
    files = list(path_obj.glob(pattern))

    #         # Filter out excluded patterns
    #         if exclude_patterns:
    filtered_files = []
    #             for file in files:
    exclude = False
    #                 for exclude_pattern in exclude_patterns:
    #                     if file.match(exclude_pattern):
    exclude = True
    #                         break
    #                 if not exclude:
                        filtered_files.append(file)
    files = filtered_files

    #         # Check each file for changes
    #         for file_path in files:
    #             if file_path.is_file():
    file_str = str(file_path)
    current_mtime = file_path.stat().st_mtime

    #                 # Check if file is new or modified
    #                 if file_str not in self._file_states:
    #                     # New file
    self._file_states[file_str] = current_mtime
    #                     if not output_json:
                            print(f"\n[NEW] {file_path}")
                        await self._validate_and_report(file_str, syntax_only, teach, output_json)
    #                 elif current_mtime self._file_states[file_str]):
    #                     # Modified file
    self._file_states[file_str] = current_mtime
    #                     if not output_json:
                            print(f"\n[MODIFIED] {file_path}")
                        await self._validate_and_report(file_str, syntax_only, teach, output_json)

    #         # Check for deleted files
    deleted_files = []
    #         for file_str in self._file_states:
    #             if not os.path.exists(file_str):
                    deleted_files.append(file_str)

    #         for file_str in deleted_files:
    #             del self._file_states[file_str]
    #             if not output_json:
                    print(f"\n[DELETED] {file_str}")

    #     async def _validate_and_report(self, file_path: str, syntax_only: bool,
    #                                  teach: bool, output_json: bool) -None):
    #         """Validate a file and report the results."""
    #         try:
    result = await self._validate_file(file_path, syntax_only)

    #             if output_json:
                    print(json.dumps({
    #                     "file": file_path,
                        "timestamp": time.time(),
    #                     "valid": result["valid"],
                        "errors": result.get("errors", []),
                        "warnings": result.get("warnings", [])
    }, indent = 2))
    #             else:
    #                 if result["valid"]:
                        print(f"  ✓ Valid")
    #                 else:
                        print(f"  ✗ Invalid")

    #                     # Show errors
    #                     for error in result.get("errors", []):
                            print(f"    - {error}")

    #                     # Show teaching feedback if requested
    #                     if teach:
    feedback = self._generate_teaching_feedback(result)
    #                         if feedback:
                                print("  Teaching Feedback:")
    #                             for line in feedback:
                                    print(f"    {line}")

    #         except Exception as e:
    #             if output_json:
                    print(json.dumps({
    #                     "file": file_path,
                        "timestamp": time.time(),
    #                     "valid": False,
                        "errors": [f"Validation failed: {str(e)}"]
    }, indent = 2))
    #             else:
                    print(f"  ? Error: {str(e)}")

    #     async def _validate_file(self, file_path: str, syntax_only: bool) -Dict[str, Any]):
    #         """Validate a single file."""
    result = {
    #             "valid": False,
    #             "errors": [],
    #             "warnings": []
    #         }

    #         try:
    #             # Read file
    #             with open(file_path, 'r', encoding='utf-8') as f:
    code = f.read()

    #             # Perform syntax checking
    parse_request = ParseRequest(
    code = code,
    file_path = file_path,
    mode = "syntax_check"
    #             )
    parse_result = await self.compiler_frontend.parse(parse_request)

    #             if not parse_result.success:
    result["errors"] = parse_result.errors
    #                 return result

    #             # Perform semantic checking if not syntax-only mode
    #             if not syntax_only:
    linter_result = self.linter.check(code, file_path)
    #                 if not linter_result.success:
    result["errors"] = linter_result.errors
    result["warnings"] = linter_result.warnings
    #                     return result
    #                 else:
    result["warnings"] = linter_result.warnings

    result["valid"] = True
    #             return result

    #         except Exception as e:
    result["errors"] = [f"Validation failed: {str(e)}"]
    #             return result

    #     def _generate_teaching_feedback(self, result: Dict[str, Any]) -List[str]):
    #         """Generate teaching feedback for validation errors."""
    feedback = []

    #         if result.get("errors"):
                feedback.append("Common issues and fixes:")

    #             for error in result["errors"][:3]:  # Limit to first 3 errors
    #                 if "syntax" in error.lower():
    #                     feedback.append("  - Check for proper indentation and matching brackets")
    #                 elif "undefined" in error.lower() or "not defined" in error.lower():
                        feedback.append("  - Ensure variables are declared before use")
    #                 elif "type" in error.lower():
                        feedback.append("  - Verify that types match expected values")
    #                 else:
                        feedback.append(f"  - {error}")

    #         return feedback