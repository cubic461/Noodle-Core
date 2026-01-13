"""
Noodle Core::Simple Syntax Fix Final - simple_syntax_fix_final.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

import re

def fix_syntax_errors(file_path):
    """Fix critical syntax errors in the file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 1. Fix broken string literals that end with elp."""
    content = re.sub(r'(\w+)elp\."""', r'\1:\n    """', content)
    
    # 2. Fix broken except blocks
    content = re.sub(r'except\s+Exception\s+as\s+e:\s*except\s+Exception\s+as\s+e:', 
                   r'except Exception as e:\n        ', content)
    
    # 3. Fix broken return statements
    content = re.sub(r'return\s+(\d+)([^;\n])', r'return \1\n\2', content)
    
    # 4. Fix broken method definitions
    content = re.sub(r'def\s+(\w+)\s*\([^)]*\)([^:\n])', r'def \1(...):\n    \2', content)
    
    # 5. Fix broken class definitions
    content = re.sub(r'class\s+(\w+)([^:\n])', r'class \1:\n    \2', content)
    
    # 6. Fix broken if/for/while statements
    content = re.sub(r'\b(if|for|while|try|except|finally|with)\s+([^:\n])([^:\n]*?)\s*([a-zA-Z_])', 
                   r'\1 \2\3:\n    \4', content)
    
    # 7. Fix broken try-except blocks
    content = re.sub(r'try:\s*([a-zA-Z_])', r'try:\n    \1', content)
    content = re.sub(r'except\s+Exception\s+as\s+e:\s*([a-zA-Z_])', r'except Exception as e:\n    \1', content)
    
    # 8. Fix broken if-else blocks
    content = re.sub(r'if\s+([^:]*?):\s*([a-zA-Z_])', r'if \1:\n    \2', content)
    content = re.sub(r'else:\s*([a-zA-Z_])', r'else:\n    \1', content)
    
    # 9. Fix broken for loops
    content = re.sub(r'for\s+([^:]*?):\s*([a-zA-Z_])', r'for \1:\n    \2', content)
    
    # 10. Fix broken while loops
    content = re.sub(r'while\s+([^:]*?):\s*([a-zA-Z_])', r'while \1:\n    \2', content)
    
    # 11. Fix broken with statements
    content = re.sub(r'with\s+([^:]*?):\s*([a-zA-Z_])', r'with \1:\n    \2', content)
    
    # 12. Fix broken return statements
    content = re.sub(r'return\s+([^;\n]*?)\s*([a-zA-Z_])', r'return \1\n\2', content)
    
    # 13. Fix broken import statements
    content = re.sub(r'import\s+([^;\n]*?)\s*([a-zA-Z_])', r'import \1\n\2', content)
    content = re.sub(r'from\s+([^;\n]*?)\s*([a-zA-Z_])', r'from \1\n\2', content)
    
    # Write fixed content back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed syntax errors in {file_path}")

if __name__ == "__main__":
    fix_syntax_errors("noodle-core/src/noodlecore/desktop/ide/native_gui_ide.py")

