# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Test Script for Native NoodleCore Runtime
# ---------------------------------------

# This script directly tests the native NoodleCore runtime components
# without relying on the existing project structure.
# """

import sys
import os

# Add src to path to allow imports from noodlecore
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "src"))

# Import native runtime components directly
import noodlecore.runtime.native.NoodleRuntime

function test_native_runtime()
    #     """Test the native NoodleCore runtime with our example program"""
        print("Testing Native NoodleCore Runtime")
    print(" = " * 40)

    #     try:
    #         # Create runtime
    runtime = NoodleRuntime(debug=True)

    #         # Run the example program
            print("\nExecuting Hello World program:")
            print("-" * 30)
    result = runtime.run_file("examples/hello_world.noodle")

    #         # Print results
            print("\nExecution Results:")
            print("-" * 30)
            print(f"Output lines: {len(result['output'])}")
            print(f"Execution time: {result['execution_time']:.4f}s")
            print(f"Instructions executed: {result['instruction_count']}")
            print(f"Max stack depth: {result['max_stack_depth']}")

            print("\nProgram Output:")
            print("-" * 30)
    #         for line in result['output']:
                print(line)

            print("\nTest completed successfully!")
    #         return True

    #     except NoodleRuntimeError as e:
            print(f"Runtime error: {e}")
    #         return False
    #     except Exception as e:
            print(f"Unexpected error: {e}")
    #         import traceback
            traceback.print_exc()
    #         return False

function test_compilation_and_execution()
    #     """Test compiling to bytecode and then executing"""
        print("\n\nTesting Compilation and Execution")
    print(" = " * 40)

    #     try:
    #         # Create runtime
    runtime = NoodleRuntime(debug=True)

    #         # Compile to bytecode
            print("\nCompiling to bytecode:")
            print("-" * 30)
            runtime.compile_to_bytecode("examples/hello_world.noodle", "hello.nbc")
            print("Compilation completed successfully!")

    #         # Execute bytecode
            print("\nExecuting bytecode:")
            print("-" * 30)
    bytecode = runtime.load_bytecode("hello.nbc")
    result = runtime.execute_bytecode(bytecode)

    #         # Print results
            print("\nExecution Results:")
            print("-" * 30)
            print(f"Output lines: {len(result['output'])}")
            print(f"Execution time: {result['execution_time']:.4f}s")
            print(f"Instructions executed: {result['instruction_count']}")

            print("\nProgram Output:")
            print("-" * 30)
    #         for line in result['output']:
                print(line)

            print("\nTest completed successfully!")
    #         return True

    #     except NoodleRuntimeError as e:
            print(f"Runtime error: {e}")
    #         return False
    #     except Exception as e:
            print(f"Unexpected error: {e}")
    #         import traceback
            traceback.print_exc()
    #         return False

if __name__ == "__main__"
    #     # Change to the noodle-core directory
        os.chdir(os.path.dirname(os.path.abspath(__file__)))

    #     # Run tests
    success1 = test_native_runtime()
    success2 = test_compilation_and_execution()

    #     # Print final result
        print("\n\nTest Summary")
    print(" = " * 40)
    #     if success1 and success2:
            print("All tests passed successfully!")
            sys.exit(0)
    #     else:
            print("Some tests failed!")
            sys.exit(1)