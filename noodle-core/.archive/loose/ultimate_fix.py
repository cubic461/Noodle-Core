"""
Noodle Core::Ultimate Fix - ultimate_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

import re

def fix_file(file_path):
    """Comprehensive fix for all syntax and formatting issues."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 1. Fix broken method definitions and class definitions
    content = re.sub(r'(\w+)\("""[^"]*""")', r'\1:\n    """', content)
    
    # 2. Fix broken string literals
    content = re.sub(r'(\w+)\."""', r'\1:\n    """', content)
    
    # 3. Fix broken method calls
    content = re.sub(r'(\w+)\.(\w+)([^.\n])', r'\1.\2(\3)', content)
    
    # 4. Fix broken if/for/while statements
    content = re.sub(r'\b(if|for|while|try|except|finally|with)\s+([^:\n])([^:\n]*?)\s*([a-zA-Z_])', 
                   r'\1 \2\3:\n    \4', content)
    
    # 5. Fix broken except blocks
    content = re.sub(r'except\s+Exception\s+as\s+e:\s*except\s+Exception\s+as\s+e:', 
                   r'except Exception as e:', content)
    
    # 6. Fix broken return statements
    content = re.sub(r'return\s+(\d+)([^;\n])', r'return \1\n\2', content)
    
    # 7. Fix broken method definitions
    content = re.sub(r'def\s+(\w+)\s*\([^)]*\)([^:\n])', r'def \1(...):\n    \2', content)
    
    # 8. Fix broken class definitions
    content = re.sub(r'class\s+(\w+)([^:\n])', r'class \1:\n    \2', content)
    
    # 9. Fix broken indentation
    lines = content.split('\n')
    fixed_lines = []
    for line in lines:
        # Fix lines that start with a word but should be indented
        if re.match(r'^\s*[a-zA-Z_][a-zA-Z0-9_]*\s*[=:]', line) and not line.strip().startswith(('def ', 'class ', 'if ', 'for ', 'while ', 'try:', 'except', 'finally:', 'with ', 'import ', 'from ')):
            # Check if previous line ended with a colon
            if fixed_lines and fixed_lines[-1].strip().endswith(':'):
                # This line should be indented
                line = '    ' + line
        fixed_lines.append(line)
    
    content = '\n'.join(fixed_lines)
    
    # 10. Fix broken string literals with quotes
    content = re.sub(r'("""[^"]*?""")', r'"""\1"""', content)
    
    # 11. Fix broken print statements
    content = re.sub(r'print\s*\(\s*([^)]*?)\s*\)\s*([a-zA-Z_])', r'print(\1)\n\2', content)
    
    # 12. Fix broken function calls
    content = re.sub(r'(\w+)\s*\(\s*([^)]*?)\s*\)\s*([a-zA-Z_])', r'\1(\2)\n\3', content)
    
    # 13. Fix broken assignments
    content = re.sub(r'(\w+)\s*=\s*([^;\n]*?)\s*([a-zA-Z_])', r'\1 = \2\n\3', content)
    
    # 14. Fix broken try-except blocks
    content = re.sub(r'try:\s*([a-zA-Z_])', r'try:\n    \1', content)
    content = re.sub(r'except\s+Exception\s+as\s+e:\s*([a-zA-Z_])', r'except Exception as e:\n    \1', content)
    
    # 15. Fix broken if-else blocks
    content = re.sub(r'if\s+([^:]*?):\s*([a-zA-Z_])', r'if \1:\n    \2', content)
    content = re.sub(r'else:\s*([a-zA-Z_])', r'else:\n    \1', content)
    
    # 16. Fix broken for loops
    content = re.sub(r'for\s+([^:]*?):\s*([a-zA-Z_])', r'for \1:\n    \2', content)
    
    # 17. Fix broken while loops
    content = re.sub(r'while\s+([^:]*?):\s*([a-zA-Z_])', r'while \1:\n    \2', content)
    
    # 18. Fix broken with statements
    content = re.sub(r'with\s+([^:]*?):\s*([a-zA-Z_])', r'with \1:\n    \2', content)
    
    # 19. Fix broken return statements
    content = re.sub(r'return\s+([^;\n]*?)\s*([a-zA-Z_])', r'return \1\n\2', content)
    
    # 20. Fix broken import statements
    content = re.sub(r'import\s+([^;\n]*?)\s*([a-zA-Z_])', r'import \1\n\2', content)
    content = re.sub(r'from\s+([^;\n]*?)\s*([a-zA-Z_])', r'from \1\n\2', content)
    
    # Write fixed content back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Applied comprehensive fix to {file_path}")

if __name__ == "__main__":
    fix_file("noodle-core/src/noodlecore/desktop/ide/native_gui_ide.py")

