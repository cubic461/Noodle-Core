#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_simple_import.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple test script to check if enhanced_native_ide_complete.py can be imported
"""

import sys
import os
from pathlib import Path

# Add the noodle-core/src directory to Python path
project_root = Path(__file__).parent
src_path = project_root / "src"
sys.path.insert(0, str(src_path))

def test_import():
    """Test importing the enhanced_native_ide_complete module"""
    print("Testing import of enhanced_native_ide_complete.py...")
    
    try:
        # Try to import the module directly
        import noodlecore.desktop.ide.enhanced_native_ide_complete as ide_module
        print("âœ“ SUCCESS: Module imported successfully!")
        
        # Check if the main class exists
        if hasattr(ide_module, 'EnhancedNativeNoodleCoreIDE'):
            print("âœ“ EnhancedNativeNoodleCoreIDE class found")
        else:
            print("âš  EnhancedNativeNoodleCoreIDE class not found")
            
        if hasattr(ide_module, 'NativeNoodleCoreIDE'):
            print("âœ“ NativeNoodleCoreIDE class found")
        else:
            print("âš  NativeNoodleCoreIDE class not found")
        
        return True
        
    except ImportError as e:
        print(f"âœ— IMPORT ERROR: {e}")
        return False
    except SyntaxError as e:
        print(f"âœ— SYNTAX ERROR: {e}")
        return False
    except Exception as e:
        print(f"âœ— UNEXPECTED ERROR: {e}")
        return False

if __name__ == "__main__":
    print("NoodleCore Enhanced IDE Import Test")
    print("=" * 50)
    
    success = test_import()
    
    print("=" * 50)
    if success:
        print("âœ“ SUCCESS: enhanced_native_ide_complete.py imports correctly!")
        print("The IDE should be ready to run.")
    else:
        print("âœ— FAILURE: Import test failed")
        print("Please check the errors above and fix them before running the IDE.")
    
    sys.exit(0 if success else 1)

