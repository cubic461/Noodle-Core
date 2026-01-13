#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_import_enhanced_native_ide_complete_v2.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to verify that the enhanced_native_ide_complete module can be imported successfully
after all the fixes we've made.
"""

import sys
import os

def test_import():
    """Test importing the enhanced_native_ide_complete module"""
    try:
        # Add the src directory to the Python path
        sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))
        
        # Try to import the module from the correct path
        from noodlecore.desktop.ide import enhanced_native_ide_complete
        print("SUCCESS: enhanced_native_ide_complete module imported successfully")
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

