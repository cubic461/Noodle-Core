# Converted from Python to NoodleCore
# Original file: noodle-core

# NoodleCore converted from Python
# """
# Test script to verify Python to NoodleCore conversion functionality
# """

import sys
import os
sys.path.append('src')

import noodlecore.desktop.ide.self_improvement_integration.SelfImprovementIntegration

function test_conversion()
    #     """Test the Python to NoodleCore conversion"""
    print(" = == Testing Python to NoodleCore Conversion ===")

    #     # Initialize the integration
    integration = SelfImprovementIntegration()

    #     # Test Python code
    #     python_code = '''def hello_world():
        print("Hello from Python!")
    #     return "Hello World"

function calculate_sum(a, b)
    result = math.add(a, b)
        print(f"Sum of {a} and {b} is {result}")
    #     return result'''

    print("\n = == Original Python Code ===")
        print(python_code)

    #     # Convert to NoodleCore
    nc_code = integration._convert_python_to_nc(python_code)

    print("\n = == Converted NoodleCore Code ===")
        print(nc_code)

    #     # Test conversion improvement application
    print("\n = == Testing Conversion Improvement ===")

    #     # Create a test improvement
    test_improvement = {
    #         'type': 'python_conversion',
    #         'file': 'test_python_to_nc.py',
    #         'description': 'Test conversion'
    #     }

    #     # Test the conversion improvement
    success = integration._apply_python_conversion_improvement(test_improvement)

    #     if success:
            print("[OK] Conversion improvement applied successfully")

    #         # Check if .nc file was created
    nc_file = 'test_python_to_nc.nc'
    #         if os.path.exists(nc_file):
                print(f"[OK] NoodleCore file created: {nc_file}")

    #             # Read and display the converted file
    #             with open(nc_file, 'r') as f:
    content = f.read()
    print(f"\n = == Content of {nc_file} ===")
                print(content)
    #         else:
                print(f"[ERROR] NoodleCore file not found: {nc_file}")
    #     else:
            print("[ERROR] Conversion improvement failed")

    print("\n = == Test Complete ===")

if __name__ == "__main__"
        test_conversion()