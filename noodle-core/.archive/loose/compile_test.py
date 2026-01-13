#!/usr/bin/env python3
"""
Test Suite::Noodle Core - compile_test.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""Test compilation of native_gui_ide.py without importing it"""

import py_compile
import sys
import os

# Path to the file
file_path = os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'desktop', 'ide', 'native_gui_ide.py')

try:
    # Try to compile the file
    result = py_compile.compile(file_path)
    if result.returncode == 0:
        print("SUCCESS: File compiles without errors")
    else:
        print(f"FAILED: Compilation error - {result.returncode}")
        # Print the first error
        if result.errors:
            error = result.errors[0]
            print(f"Error details: {error.msg} at line {error.lineno}")
            print(f"Error text: {error.text}")
except Exception as e:
    print(f"FAILED: Unexpected error - {str(e)}")

