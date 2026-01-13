#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_enhanced_ide_import.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to import enhanced_native_ide_complete.py module
"""

def test_import():
    """Test importing enhanced_native_ide_complete.py"""
    try:
        # Try to import the module from correct path
        from src.noodlecore.desktop.ide.enhanced_native_ide_complete import EnhancedNativeNoodleCoreIDE
        print("SUCCESS: enhanced_native_ide_complete.py imported successfully")
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

