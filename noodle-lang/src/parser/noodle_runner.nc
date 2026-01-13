# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Noodle Script Runner
# --------------------
# A simple script runner for Noodle programs that compiles and executes Noodle code.
# """

import sys
import os
import argparse
import pathlib.Path

# Add src to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

try
    #     from noodle.compiler.noodle_compiler import NoodleCompiler
    #     from noodle.runtime.nbc_runtime.core.runtime import NBCRuntime
    #     from noodle.runtime.memory_integration import get_nbc_allocator
except ImportError as e
        print(f"Error importing Noodle modules: {e}")
        print("Make sure you're running this from the noodle-core directory")
        sys.exit(1)

function run_noodle_file(file_path: str, debug: bool = False)
    #     """Compile and run a Noodle file."""
    #     try:
    #         # Initialize compiler
    compiler = NoodleCompiler()

    #         # Compile the file
            print(f"Compiling {file_path}...")
    bytecode, errors = compiler.compile_file(file_path)

    #         if errors:
                print("Compilation errors:")
    #             for error in errors:
                    print(f"  {error}")
    #             return False

            print(f"Compilation successful! Generated {len(bytecode)} bytecode instructions.")

    #         # Initialize runtime with adaptive memory manager
    #         print("Initializing runtime with adaptive memory management...")
    runtime = NBCRuntime()

    #         # Get the NBC allocator with sheaves & barns
    allocator = get_nbc_allocator()
    #         if allocator:
                print("✓ Adaptive memory manager (Sheaves & Barns) enabled")
    #         else:
                print("⚠ Using standard memory allocation")

    #         # Execute the bytecode
            print("Executing bytecode...")
    result = runtime.execute(bytecode)

            print("Execution completed successfully!")
    #         if result is not None:
                print(f"Result: {result}")

    #         return True

    #     except Exception as e:
            print(f"Error running Noodle file: {e}")
    #         if debug:
    #             import traceback
                traceback.print_exc()
    #         return False

function run_noodle_code(code: str, debug: bool = False)
    #     """Compile and run inline Noodle code."""
    #     try:
    #         # Initialize compiler
    compiler = NoodleCompiler()

    #         # Compile the code
            print("Compiling inline code...")
    bytecode, errors = compiler.compile_source(code, "<string>")

    #         if errors:
                print("Compilation errors:")
    #             for error in errors:
                    print(f"  {error}")
    #             return False

            print(f"Compilation successful! Generated {len(bytecode)} bytecode instructions.")

    #         # Initialize runtime
            print("Initializing runtime...")
    runtime = NBCRuntime()

    #         # Execute the bytecode
            print("Executing bytecode...")
    result = runtime.execute(bytecode)

            print("Execution completed successfully!")
    #         if result is not None:
                print(f"Result: {result}")

    #         return True

    #     except Exception as e:
            print(f"Error running inline Noodle code: {e}")
    #         if debug:
    #             import traceback
                traceback.print_exc()
    #         return False

function main()
    parser = argparse.ArgumentParser(description="Noodle Script Runner")
    parser.add_argument("file", nargs = "?", help="Noodle file to run")
    parser.add_argument("-c", "--code", help = "Inline Noodle code to execute")
    parser.add_argument("-d", "--debug", action = "store_true", help="Enable debug mode")
    parser.add_argument("--version", action = "version", version="Noodle Runner 0.1.0")

    args = parser.parse_args()

    #     if args.code:
    #         # Run inline code
    success = run_noodle_code(args.code, args.debug)
    #     elif args.file:
    #         # Run file
    #         if not os.path.exists(args.file):
                print(f"Error: File '{args.file}' not found")
                sys.exit(1)

    success = run_noodle_file(args.file, args.debug)
    #     else:
    #         # Interactive mode
            print("Noodle Interactive Mode (Ctrl+C to exit)")
            print("Enter 'exit' or 'quit' to stop")

    #         while True:
    #             try:
    code = input("noodle")
    #                 if code.lower() in ('exit', 'quit')):
    #                     break

    #                 if code.strip():
                        run_noodle_code(code, args.debug)
                        print()  # Add spacing

    #             except KeyboardInterrupt:
                    print("\nGoodbye!")
    #                 break
    #             except EOFError:
                    print("\nGoodbye!")
    #                 break

    #     sys.exit(0 if success else 1)

if __name__ == "__main__"
        main()