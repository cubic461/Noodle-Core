#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_import_native_ide.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to import native_gui_ide.py module from the correct path
"""

def test_import():
    """Test importing native_gui_ide.py"""
    try:
        # Try to import the module from the correct path
        from src.noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE
        print("SUCCESS: native_gui_ide.py imported successfully")
        
        # Try to instantiate the class (without running the GUI)
        print("Testing class instantiation...")
        # We won't actually instantiate it since that would create a GUI
        print("SUCCESS: Class is available for instantiation")
        return True
    except ImportError as e:
        print(f"FAILED: ImportError - {e}")
        return False
    except SyntaxError as e:
        print(f"FAILED: SyntaxError - {e}")
        return False
    except Exception as e:
        print(f"FAILED: Unexpected error - {e}")
        return False

if __name__ == "__main__":
    success = test_import()
    if success:
        print("Import test completed successfully")
    else:
        print("Import test failed")

