#!/usr/bin/env python3
"""
Test Suite::Noodle Core - simple_import_test.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""Simple test to import the enhanced_native_ide_complete module"""

import sys
import os

# Add the noodle-core directory to the Python path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

try:
    # Try to import the module directly
    import noodlecore.desktop.ide.native_gui_ide
    print("SUCCESS: Module imported successfully")
    
    # Try to instantiate the class
    ide = noodlecore.desktop.ide.native_gui_ide.NativeNoodleCoreIDE()
    print("SUCCESS: Class instantiated successfully")
    
except ImportError as e:
    print(f"FAILED: ImportError - {str(e)}")
except SyntaxError as e:
    print(f"FAILED: SyntaxError - {str(e)}")
except Exception as e:
    print(f"FAILED: Unexpected error - {str(e)}")

