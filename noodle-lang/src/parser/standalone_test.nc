# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Standalone Test for Native NoodleCore Runtime
# --------------------------------------------

# This script directly tests the native NoodleCore runtime components
# without relying on the existing project structure.
# """

import sys
import os

# Add the native runtime directory directly to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "src", "noodlecore", "runtime", "native"))

# Import native runtime components directly
import noodle_bytecode.BytecodeFile
import noodle_parser.parse_noodle_source
import noodle_interpreter.NoodleCoreInterpreter
import noodle_runtime.NoodleRuntime

function test_basic_interpreter()
    #     """Test the basic interpreter with manually created bytecode"""
        print("Testing Basic Interpreter")
    print(" = " * 30)

    #     try:
    #         # Create a simple bytecode file manually
    bytecode = BytecodeFile()

    #         # Create a simple program that prints "Hello, World!"
    instructions = [
    #             # Push "Hello, World!" to stack
    #             {"opcode": "PUSH", "operands": ["Hello, World!"]},
    #             # Print the value
    #             {"opcode": "PRINT", "operands": []},
    #             # Halt
    #             {"opcode": "HALT", "operands": []}
    #         ]

    #         # Convert to instruction objects
    #         from noodle_bytecode import Instruction, OpCode
    bytecode.functions["main"] = []

    #         for instr in instructions:
    opcode = OpCode[instr["opcode"]]
                bytecode.functions["main"].append(Instruction(opcode, instr["operands"]))

    #         # Execute the bytecode
    interpreter = NoodleCoreInterpreter(debug=True)
            interpreter.load_bytecode(bytecode)
    result = interpreter.execute_function("main")

    #         # Get output
    output = interpreter.get_output()
            print("Output:", output)

            print("Basic interpreter test passed!")
    #         return True

    #     except Exception as e:
            print(f"Error in basic interpreter test: {e}")
    #         import traceback
            traceback.print_exc()
    #         return False

function test_parser()
    #     """Test the parser with a simple program"""
        print("\nTesting Parser")
    print(" = " * 30)

    #     try:
    #         # Simple Noodle program
    source = """
            print("Hello from parser!");
    x = 10;
    y = 20;
    z = x + y;
            print("The sum is:");
            print(z);
    #         """

    #         # Parse the source
    bytecode = parse_noodle_source(source)

            print(f"Parsed {len(bytecode.functions)} functions")
    #         for name, instructions in bytecode.functions.items():
                print(f"  Function '{name}': {len(instructions)} instructions")

    #         # Execute the bytecode
    interpreter = NoodleCoreInterpreter(debug=True)
            interpreter.load_bytecode(bytecode)
    result = interpreter.execute_function("main")

    #         # Get output
    output = interpreter.get_output()
            print("Output:", output)

            print("Parser test passed!")
    #         return True

    #     except Exception as e:
            print(f"Error in parser test: {e}")
    #         import traceback
            traceback.print_exc()
    #         return False

function test_file_parsing()
    #     """Test parsing a file"""
        print("\nTesting File Parsing")
    print(" = " * 30)

    #     try:
    #         # Check if the example file exists
    #         if not os.path.exists("examples/hello_world.noodle"):
                print("Example file not found, skipping file parsing test")
    #             return True

    #         # Create runtime
    runtime = NoodleRuntime(debug=True)

    #         # Parse the file
    bytecode = runtime.parse_file("examples/hello_world.noodle")

            print(f"Parsed {len(bytecode.functions)} functions")
    #         for name, instructions in bytecode.functions.items():
                print(f"  Function '{name}': {len(instructions)} instructions")

    #         # Execute the bytecode
    result = runtime.execute_bytecode(bytecode)

    #         # Get output
    output = result['output']
            print("Output:", output)

            print("File parsing test passed!")
    #         return True

    #     except Exception as e:
            print(f"Error in file parsing test: {e}")
    #         import traceback
            traceback.print_exc()
    #         return False

function test_complete_runtime()
    #     """Test the complete runtime"""
        print("\nTesting Complete Runtime")
    print(" = " * 30)

    #     try:
    #         # Check if the example file exists
    #         if not os.path.exists("examples/hello_world.noodle"):
                print("Example file not found, skipping complete runtime test")
    #             return True

    #         # Create runtime
    runtime = NoodleRuntime(debug=True)

    #         # Run the file
    result = runtime.run_file("examples/hello_world.noodle")

    #         # Print results
            print(f"Execution time: {result['execution_time']:.4f}s")
            print(f"Instructions executed: {result['instruction_count']}")
            print(f"Max stack depth: {result['max_stack_depth']}")

    #         # Get output
    output = result['output']
            print("Output:", output)

            print("Complete runtime test passed!")
    #         return True

    #     except Exception as e:
            print(f"Error in complete runtime test: {e}")
    #         import traceback
            traceback.print_exc()
    #         return False

if __name__ == "__main__"
    #     # Change to the noodle-core directory
        os.chdir(os.path.dirname(os.path.abspath(__file__)))

    #     # Run tests
    success1 = test_basic_interpreter()
    success2 = test_parser()
    success3 = test_file_parsing()
    success4 = test_complete_runtime()

    #     # Print final result
        print("\n\nTest Summary")
    print(" = " * 30)
    #     if success1 and success2 and success3 and success4:
            print("All tests passed successfully!")
            sys.exit(0)
    #     else:
            print("Some tests failed!")
            sys.exit(1)