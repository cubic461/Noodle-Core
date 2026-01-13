#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_minimal_import.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Minimal test to check if enhanced_native_ide_complete.py exists and can be imported
"""

import sys
import os
from pathlib import Path

def test_minimal():
    """Test if the file exists and can be imported"""
    file_path = Path("src/noodlecore/desktop/ide/enhanced_native_ide_complete.py")
    
    if not file_path.exists():
        print("âœ— ERROR: File does not exist")
        return False
    
    try:
        # Just try to import without parsing
        import noodlecore.desktop.ide.enhanced_native_ide_complete as ide_module
        print("âœ“ SUCCESS: Module imported successfully!")
        return True
    except ImportError as e:
        print(f"âœ— IMPORT ERROR: {e}")
        return False
    except Exception as e:
        print(f"âœ— UNEXPECTED ERROR: {e}")
        return False

if __name__ == "__main__":
    print("NoodleCore Enhanced IDE Minimal Import Test")
    print("=" * 50)
    
    success = test_minimal()
    
    print("=" * 50)
    if success:
        print("âœ“ SUCCESS: enhanced_native_ide_complete.py imports correctly!")
        print("The IDE should be ready to run.")
    else:
        print("âœ— FAILURE: Import test failed")
        print("Please check the errors above and fix them before running the IDE.")
    
    sys.exit(0 if success else 1)

