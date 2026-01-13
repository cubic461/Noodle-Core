#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_syntax_check.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""Test script to verify the native IDE syntax is correct."""

import sys
import ast

def test_syntax(file_path):
    """Test if a Python file has valid syntax."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Try to parse the file
        ast.parse(content)
        print(f"âœ… Syntax check passed for {file_path}")
        return True
        
    except SyntaxError as e:
        print(f"âŒ Syntax error in {file_path}:")
        print(f"   Line {e.lineno}: {e.msg}")
        print(f"   Text: {e.text}")
        return False
    except Exception as e:
        print(f"âŒ Error reading {file_path}: {e}")
        return False

if __name__ == "__main__":
    ide_file = "src/noodlecore/desktop/ide/native_ide_complete.py"
    
    print("Testing NoodleCore IDE syntax...")
    if test_syntax(ide_file):
        print("\nðŸŽ‰ The IDE file has valid syntax and should run without errors!")
        print("\nTo launch the IDE, run:")
        print("   python src/noodlecore/desktop/ide/native_ide_complete.py")
    else:
        print("\nðŸ’¥ Syntax errors found. Please fix before running.")
        sys.exit(1)

