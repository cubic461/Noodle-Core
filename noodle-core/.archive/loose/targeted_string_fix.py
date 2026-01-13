"""
Noodle Core::Targeted String Fix - targeted_string_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

import re

def fix_string_literals(file_path):
    """Fix broken string literals in the file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix the specific issue with elp."""
    content = re.sub(r'(\w+)elp\."""', r'\1:\n    """', content)
    
    # Fix other broken string literals
    content = re.sub(r'(\w+)"""', r'\1:\n    """', content)
    
    # Fix broken method definitions
    content = re.sub(r'def\s+(\w+)\s*\([^)]*\)([^:\n])', r'def \1(...):\n    \2', content)
    
    # Fix broken except blocks
    content = re.sub(r'except\s+Exception\s+as\s+e:\s*except\s+Exception\s+as\s+e:', 
                   r'except Exception as e:\n        ', content)
    
    # Write fixed content back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed string literals in {file_path}")

if __name__ == "__main__":
    fix_string_literals("noodle-core/src/noodlecore/desktop/ide/native_gui_ide.py")

