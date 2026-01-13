#!/usr/bin/env python3
"""
Noodle Core::Comprehensive Syntax Final Fix - comprehensive_syntax_final_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""Comprehensive fix for all syntax errors in native_gui_ide.py"""

import os
import re

# Path to the file
file_path = os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'desktop', 'ide', 'native_gui_ide.py')

# Read the file
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix 1: Replace broken docstring on line 4
content = re.sub(
    r'This is the main IDE implementation for NoodleCore with enhanced features',
    'This is the main IDE implementation for NoodleCore with enhanced features',
    content
)

# Fix 2: Fix line 1013 - remove broken comment
content = re.sub(
    r'        # 1\. Git Repository Check\\n"\)',
    '        # 1. Git Repository Check\\n")',
    content
)

# Fix 3: Fix duplicate line 971
content = re.sub(
    r'(\s+)self\.terminal_output\.insert\(\'end\', f"\\n  \{d\.name\}/\\n"\)\n(\s+)for f in sorted\(files\):',
    r'\2for f in sorted(files):',
    content
)

# Fix 4: Fix messagebox functions with proper indentation and string concatenation
content = re.sub(
    r'def fix_noodlecore_syntax\(self\):\s*"""Fix NoodleCore syntax issues.*?"""\s*messagebox\.showinfo\(\s*"Syntax Fixer",\s*"NoodleCore Syntax Fixer is not available.*?\s*\)',
    '''def fix_noodlecore_syntax(self):
        """Fix NoodleCore syntax issues in current file or all .nc files."""
        messagebox.showinfo(
            "Syntax Fixer",
            "NoodleCore Syntax Fixer is not available in this simplified version.\\n"
            "Please use the full NoodleCore IDE for syntax fixing capabilities."
        )''',
    content,
    flags=re.DOTALL
)

content = re.sub(
    r'def show_python_integration_settings\(self\):\s*"""Show Python Integration Settings dialog\."""\s*messagebox\.showinfo\(\s*"Python Integration",\s*"Python Integration settings are not available.*?\s*\)',
    '''def show_python_integration_settings(self):
        """Show Python Integration Settings dialog."""
        messagebox.showinfo(
            "Python Integration",
            "Python Integration settings are not available in this simplified version.\\n"
            "Please use the full NoodleCore IDE for Python integration capabilities."
        )''',
    content,
    flags=re.DOTALL
)

# Write the fixed content back to the file
with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Applied comprehensive syntax fixes to native_gui_ide.py")

