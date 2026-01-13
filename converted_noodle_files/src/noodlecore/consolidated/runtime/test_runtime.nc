# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Test NoodleCore Runtime Environment
 = =================================

# This module tests the NoodleCore runtime environment
# with the sample converted code.
# """

import sys
import os
import pathlib.Path

# Add the noodle-core/src directory to Python path
noodle_core_path = Path(__file__).parent.parent.parent
if str(noodle_core_path) not in sys.path
        sys.path.insert(0, str(noodle_core_path))

try
    #     # Import NoodleCore runtime
    #     import noodlecore

    #     # Test basic functionality
        print("Testing NoodleCore Runtime Environment")
    print(" = " * 50)

    #     # Test 1: Basic runtime initialization
        print("\n1. Testing runtime initialization...")
    runtime = noodlecore.get_runtime()
        print(f"✓ Runtime initialized successfully")
        print(f"  - Version: {noodlecore.__version__}")
        print(f"  - Built-in functions: {len(runtime.builtins.get_all_builtins())}")

    #     # Test 2: Error handling
        print("\n2. Testing error handling...")
    #     try:
    #         from noodlecore.runtime.errors import NoodleError, NoodleTypeError
    error = NoodleError("Test error", error_code="1001")
            print(f"✓ Error handling works: {error}")

    type_error = NoodleTypeError("Test type error", expected_type="string", actual_type="int")
            print(f"✓ Type error handling works: {type_error}")
    #     except Exception as e:
            print(f"✗ Error handling test failed: {e}")

    #     # Test 3: Language constructs
        print("\n3. Testing language constructs...")
    #     try:
            from noodlecore.runtime.language_constructs import (
    #             NoodleFunction, NoodleModule, NoodleClass, NoodleObject, NoodleType
    #         )

    #         # Test function creation
    func = NoodleFunction(
    name = "test_func",
    params = ["a", "b"],
    body = "return a + b",
    closure = {},
    is_builtin = False
    #         )
            print(f"✓ Function creation works: {func}")

    #         # Test module creation
    module = NoodleModule(
    name = "test_module",
    path = None,
    globals = {},
    functions = {},
    classes = {},
    imports = []
    #         )
            print(f"✓ Module creation works: {module}")

    #         # Test type checking
    type_name = NoodleType.get_type("test")
            print(f"✓ Type checking works: {type_name}")

    #     except Exception as e:
            print(f"✗ Language constructs test failed: {e}")

    #     # Test 4: Built-in functions
        print("\n4. Testing built-in functions...")
    #     try:
    #         from noodlecore.runtime.builtins import NoodleBuiltins

    builtins = NoodleBuiltins()
    print_func = builtins.get_builtin("print")
    #         if print_func:
                print("✓ Built-in function access works")
                print_func("✓ Built-in function execution works")
    #         else:
                print("✗ Built-in function access failed")

    #     except Exception as e:
            print(f"✗ Built-in functions test failed: {e}")

    #     # Test 5: Module loading
        print("\n5. Testing module loading...")
    #     try:
    #         from noodlecore.runtime.module_loader import NoodleModuleLoader

    loader = NoodleModuleLoader()
            print(f"✓ Module loader initialized")
            print(f"  - Search paths: {len(loader.search_paths)}")

    #     except Exception as e:
            print(f"✗ Module loading test failed: {e}")

    #     # Test 6: Code execution
        print("\n6. Testing code execution...")
    #     try:
    #         from noodlecore.runtime.interpreter import NoodleInterpreter

    interpreter = NoodleInterpreter(builtins.get_all_builtins())
    result = interpreter.execute_code("2 + 3")
    print(f"✓ Code execution works: 2 + 3 = {result}")

    #     except Exception as e:
            print(f"✗ Code execution test failed: {e}")

    #     # Test 7: Sample converted code execution
        print("\n7. Testing sample converted code...")
    #     try:
    #         # Try to execute the sample converted code
    sample_path = Path(__file__).parent.parent.parent / "sample_converted.nc"
    #         if sample_path.exists():
                print(f"✓ Sample file found: {sample_path}")

    #             # Try to load and execute the module
    module = runtime.load_module("sample_converted", str(sample_path))
                print(f"✓ Sample module loaded: {module}")

    #             # Try to execute a function from the module
    #             if "calculate_sum" in module.globals:
    calc_func = module.globals["calculate_sum"]
                    print(f"✓ Found calculate_sum function: {calc_func}")
    #             else:
                    print("! calculate_sum function not found in module")
    #         else:
                print(f"! Sample file not found: {sample_path}")

    #     except Exception as e:
            print(f"✗ Sample code execution failed: {e}")

    print("\n" + " = " * 50)
        print("NoodleCore Runtime Environment Test Complete")
    print(" = " * 50)

except ImportError as e
        print(f"Failed to import NoodleCore: {e}")
        print("Make sure the noodle-core/src directory is in the Python path")
except Exception as e
        print(f"Unexpected error during testing: {e}")