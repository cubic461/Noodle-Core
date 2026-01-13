#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_file_syntax.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to check if enhanced_native_ide_complete.py has valid Python syntax
"""

import ast
import sys
from pathlib import Path

def test_syntax():
    """Test if the enhanced_native_ide_complete.py file has valid syntax"""
    file_path = Path("src/noodlecore/desktop/ide/enhanced_native_ide_complete.py")
    
    if not file_path.exists():
        print("âœ— ERROR: File does not exist")
        return False
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Try to parse the file
        try:
            ast.parse(content)
            print("âœ“ SUCCESS: File has valid Python syntax")
            return True
        except SyntaxError as e:
            print(f"[ERROR] SYNTAX ERROR: {e}")
            print(f"Line {e.lineno}: {e.text}")
            return False
        except Exception as e:
            print(f"âœ— UNEXPECTED ERROR: {e}")
            return False
    except Exception as e:
        print(f"âœ— UNEXPECTED ERROR: {e}")
        return False
        
        print("âœ“ SUCCESS: File has valid Python syntax")
        return True
        
    except SyntaxError as e:
        print(f"âœ— SYNTAX ERROR: {e}")
        print(f"  Line {e.lineno}: {e.text}")
        return False
    except Exception as e:
        print(f"âœ— UNEXPECTED ERROR: {e}")
        return False

if __name__ == "__main__":
    print("NoodleCore Enhanced IDE Syntax Test")
    print("=" * 50)
    
    success = test_syntax()
    
    print("=" * 50)
    if success:
        print("âœ“ SUCCESS: enhanced_native_ide_complete.py has valid syntax!")
        print("The file should be ready to import.")
    else:
        print("âœ— FAILURE: Syntax check failed")
        print("Please check the errors above and fix them before running the IDE.")
    
    sys.exit(0 if success else 1)

