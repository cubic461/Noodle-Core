"""
Noodle Core::Fix Line Structure - fix_line_structure.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

import re

def fix_line_structure(file_path):
    """Fix the line structure and formatting of the file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix common structural issues
    # 1. Add newlines after semicolons that should end lines
    content = re.sub(r';(\s*)([a-zA-Z_])', r';\n\2', content)
    
    # 2. Fix method definitions that are missing newlines
    content = re.sub(r'def\s+(\w+)\([^)]*\):([^#\n])', r'def \1(...):\n    \2', content)
    
    # 3. Fix class definitions that are missing newlines
    content = re.sub(r'class\s+(\w+)([^:\n])', r'class \1:\n    \2', content)
    
    # 4. Fix if/for/while statements that are missing newlines
    content = re.sub(r'\b(if|for|while|try|except|finally|with)\s+([^:\n])', r'\1 \2:\n    ', content)
    
    # 5. Fix return statements that are missing newlines
    content = re.sub(r'return\s+([^#\n])', r'return \1\n', content)
    
    # 6. Fix import statements that are missing newlines
    content = re.sub(r'import\s+([^#\n])', r'import \1\n', content)
    content = re.sub(r'from\s+([^#\n])', r'from \1\n', content)
    
    # 7. Fix multiple statements on one line (separate with newlines)
    content = re.sub(r'([a-zA-Z0-9_\[\]\)]+\s*=\s*[^;\n]+);(\s*[a-zA-Z])', r'\1\n\2', content)
    
    # 8. Fix indentation issues by adding proper indentation after control structures
    content = re.sub(r':\s*([a-zA-Z_])', r':\n    \1', content)
    
    # 9. Fix broken except blocks
    content = re.sub(r'except\s+Exception\s+as\s+e:\s*except\s+Exception\s+as\s+e:', 
                   r'except Exception as e:', content)
    
    # 10. Fix broken method definitions
    content = re.sub(r'def\s+(\w+)\([^)]*\)([^:\n])', r'def \1(...):\n    \2', content)
    
    # Write the fixed content back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed line structure in {file_path}")

if __name__ == "__main__":
    fix_line_structure("noodle-core/src/noodlecore/desktop/ide/native_gui_ide.py")

