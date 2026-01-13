# Converted from Python to NoodleCore
# Original file: src

# """
# Native NoodleCore Runtime
# -------------------------

# This module provides the main entry point for the native NoodleCore runtime.
# It integrates the parser, bytecode format, and interpreter to provide a complete
# execution environment for Noodle programs.
# """

import os
import sys
import time
import pathlib.Path
import typing.Dict

import .noodle_bytecode.BytecodeFile
import .noodle_parser.parse_noodle_source
import .noodle_interpreter.NoodleCoreInterpreter


class NoodleRuntime
    #     """Main NoodleCore runtime class"""

    #     def __init__(self, debug: bool = False):""Initialize the runtime"""
    self.debug = debug
    self.interpreter = NoodleCoreInterpreter(debug=debug)
    self.bytecode_cache: Dict[str, BytecodeFile] = {}
    self.execution_stats = {}

    #     def parse_file(self, file_path: str) -BytecodeFile):
    #         """Parse a Noodle source file and return bytecode"""
    file_path = str(Path(file_path).resolve())

    #         # Check cache first
    #         if file_path in self.bytecode_cache:
    #             if self.debug:
    #                 print(f"Using cached bytecode for {file_path}")
    #             return self.bytecode_cache[file_path]

    #         # Read source file
    #         try:
    #             with open(file_path, 'r', encoding='utf-8') as f:
    source = f.read()
    #         except IOError as e:
                raise NoodleRuntimeError(f"Could not read file {file_path}: {e}")

    #         # Parse source
    #         try:
    bytecode = parse_noodle_source(source)

    #             # Cache the bytecode
    self.bytecode_cache[file_path] = bytecode

    #             if self.debug:
                    print(f"Parsed {file_path} into {len(bytecode.functions)} functions")
    #                 for name, instructions in bytecode.functions.items():
                        print(f"  Function '{name}': {len(instructions)} instructions")

    #             return bytecode

    #         except ParseError as e:
                raise NoodleRuntimeError(f"Parse error in {file_path}: {e}")

    #     def parse_source(self, source: str, filename: str = "<string>") -BytecodeFile):
    #         """Parse Noodle source code and return bytecode"""
    #         try:
    bytecode = parse_noodle_source(source)

    #             if self.debug:
                    print(f"Parsed {filename} into {len(bytecode.functions)} functions")
    #                 for name, instructions in bytecode.functions.items():
                        print(f"  Function '{name}': {len(instructions)} instructions")

    #             return bytecode

    #         except ParseError as e:
                raise NoodleRuntimeError(f"Parse error in {filename}: {e}")

    #     def execute_bytecode(self, bytecode: BytecodeFile, function: str = "main") -Dict[str, any]):
    #         """Execute bytecode and return results"""
    #         # Load bytecode into interpreter
            self.interpreter.load_bytecode(bytecode)

    #         # Clear output buffer
            self.interpreter.clear_output()

    #         # Record start time
    start_time = time.time()

    #         # Execute the function
    #         try:
    result = self.interpreter.execute_function(function)

    #             # Record end time
    end_time = time.time()
    execution_time = end_time - start_time

    #             # Get statistics
    stats = self.interpreter.get_statistics()
    stats['execution_time'] = execution_time
    stats['output'] = self.interpreter.get_output()
    stats['result'] = result

    #             # Store execution stats
    self.execution_stats[function] = stats

    #             if self.debug:
                    print(f"Execution completed in {execution_time:.4f}s")
                    print(f"Instructions executed: {stats['instruction_count']}")
                    print(f"Max stack depth: {stats['max_stack_depth']}")

    #             return stats

    #         except NoodleRuntimeError as e:
                raise NoodleRuntimeError(f"Runtime error: {e}")

    #     def run_file(self, file_path: str, function: str = "main") -Dict[str, any]):
    #         """Parse and execute a Noodle file"""
    #         # Parse the file
    bytecode = self.parse_file(file_path)

    #         # Execute the bytecode
            return self.execute_bytecode(bytecode, function)

    #     def run_source(self, source: str, filename: str = "<string>", function: str = "main") -Dict[str, any]):
    #         """Parse and execute Noodle source code"""
    #         # Parse the source
    bytecode = self.parse_source(source, filename)

    #         # Execute the bytecode
            return self.execute_bytecode(bytecode, function)

    #     def save_bytecode(self, bytecode: BytecodeFile, output_path: str):
    #         """Save bytecode to a file"""
    #         try:
                bytecode.save_to_file(output_path)
    #             if self.debug:
                    print(f"Saved bytecode to {output_path}")
    #         except IOError as e:
                raise NoodleRuntimeError(f"Could not save bytecode to {output_path}: {e}")

    #     def load_bytecode(self, file_path: str) -BytecodeFile):
    #         """Load bytecode from a file"""
    #         try:
    bytecode = BytecodeFile.load_from_file(file_path)

    #             if self.debug:
                    print(f"Loaded bytecode from {file_path}")
                    print(f"Functions: {list(bytecode.functions.keys())}")

    #             return bytecode

    #         except Exception as e:
                raise NoodleRuntimeError(f"Could not load bytecode from {file_path}: {e}")

    #     def compile_to_bytecode(self, source_path: str, output_path: str):
    #         """Compile a Noodle source file to bytecode"""
    #         # Parse the source file
    bytecode = self.parse_file(source_path)

    #         # Save the bytecode
            self.save_bytecode(bytecode, output_path)

    #     def get_execution_stats(self, function: str = "main") -Optional[Dict[str, any]]):
    #         """Get execution statistics for a function"""
            return self.execution_stats.get(function)

    #     def clear_cache(self):
    #         """Clear the bytecode cache"""
            self.bytecode_cache.clear()
    #         if self.debug:
                print("Cleared bytecode cache")

    #     def list_functions(self, bytecode: BytecodeFile) -List[str]):
    #         """List all functions in bytecode"""
            return list(bytecode.functions.keys())


function main()
    #     """Command-line interface for the NoodleCore runtime"""
    #     import argparse

    parser = argparse.ArgumentParser(description="Native NoodleCore Runtime")
    parser.add_argument("file", help = "Noodle source file to execute")
    parser.add_argument("-d", "--debug", action = "store_true", help="Enable debug output")
    parser.add_argument("-f", "--function", default = "main", help="Function to execute (default: main)")
    parser.add_argument("-c", "--compile", help = "Compile to bytecode file")
    parser.add_argument("-b", "--bytecode", help = "Execute bytecode file instead of source")
    parser.add_argument("--stats", action = "store_true", help="Show execution statistics")

    args = parser.parse_args()

    #     # Create runtime
    runtime = NoodleRuntime(debug=args.debug)

    #     try:
    #         if args.bytecode:
    #             # Load and execute bytecode
    bytecode = runtime.load_bytecode(args.bytecode)
    result = runtime.execute_bytecode(bytecode, args.function)
    #         else:
    #             # Parse and execute source file
    #             if args.compile:
    #                 # Compile to bytecode
                    runtime.compile_to_bytecode(args.file, args.compile)
                    print(f"Compiled {args.file} to {args.compile}")
    #                 return

    #             # Execute source file
    result = runtime.run_file(args.file, args.function)

    #         # Show output
    #         if result['output']:
    #             for line in result['output']:
                    print(line)

    #         # Show statistics if requested
    #         if args.stats:
    print("\n = == Execution Statistics ===")
                print(f"Execution time: {result['execution_time']:.4f}s")
                print(f"Instructions executed: {result['instruction_count']}")
                print(f"Max stack depth: {result['max_stack_depth']}")
                print(f"Current stack depth: {result['current_stack_depth']}")
                print(f"Functions called: {result['functions_called']}")
                print(f"Global variables: {result['global_variables']}")

    #     except NoodleRuntimeError as e:
    print(f"Error: {e}", file = sys.stderr)
            sys.exit(1)
    #     except KeyboardInterrupt:
    print("\nExecution interrupted by user", file = sys.stderr)
            sys.exit(1)


if __name__ == "__main__"
        main()