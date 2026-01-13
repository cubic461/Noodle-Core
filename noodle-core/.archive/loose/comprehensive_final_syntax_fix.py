#!/usr/bin/env python3
"""
Noodle Core::Comprehensive Final Syntax Fix - comprehensive_final_syntax_fix.py
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

# Fix all syntax errors in one go
# 1. Fix line 4 - docstring
content = re.sub(
    r'This is the main IDE implementation for NoodleCore with enhanced features',
    'This is the main IDE implementation for NoodleCore with enhanced features',
    content
)

# 2. Fix line 728-738 - duplicate terminal output code
content = re.sub(
    r'(\s+)self\.terminal_output\.insert\(\'end\', content\)\s*self\.terminal_output\.insert\(\'end\', "\\n" \+ "-" \* 50 \+ "\\n"\)\s*self\.terminal_output\.config\(\'disabled\'\)\s*self\.terminal_output\.see\(\'end\'\)\s*self\.terminal_output\.insert\(\'end\', "\\n" \+ "-" \* 50 \+ "\\n"\)\s*self\.terminal_output\.config\(\'disabled\'\)\s*self\.terminal_output\.see\(\'end\'\)',
    r'\1self.terminal_output.insert(\'end\', content)\n            self.terminal_output.insert(\'end\', "\\n" + "-" * 50 + "\\n")\n            self.terminal_output.config(\'disabled\')\n            self.terminal_output.see(\'end\')',
    content
)

# 3. Fix line 971 - duplicate line
content = re.sub(
    r'(\s+)self\.terminal_output\.insert\(\'end\', f"\\n  \{d\.name\}/\\n"\)\s*self\.terminal_output\.insert\(\'end\', f"\\n  \{d\.name\}/\\n"\)',
    r'\2for f in sorted(files):',
    content
)

# 4. Fix line 1012-1014 - broken comment
content = re.sub(
    r'self\.terminal_output\.insert\(\'end\', "\\n\[HEALTH\] Project Health Check:\\n"\)\s*# 1\. Git Repository Check\\n"\)',
    r'self.terminal_output.insert(\'end\', "\\n[HEALTH] Project Health Check:\\n")\n        # 1. Git Repository Check',
    content
)

# 5. Fix line 1057-1059 - duplicate lines and broken f-string
content = re.sub(
    r'self\.terminal_output\.insert\(\'end\', f"\[WARNING\] Dependencies: No requirements file found\\n"\)\s*self\.terminal_output\.insert\(\'end\', f"\[WARNING\] Dependencies: No requirements file found\\n"\)\s*self\.terminal_output\.insert\(\'end\', f"\[WARNING\] Dependencies: No requirements file found\\n"\)',
    r'self.terminal_output.insert\(\'end\', f"\[HEALTH\] Overall Health Score: \{health_score\}/100\\n"\)',
    r'\4self.terminal_output.insert(\'end\', f"[HEALTH] Overall Health Score: {health_score}/100\\n")',
    content
)

# 6. Fix messagebox functions with proper string handling
content = re.sub(
    r'def fix_noodlecore_syntax\(self\):\s*"""Fix NoodleCore syntax issues.*?"""\s*messagebox\.showinfo\(\s*"Syntax Fixer",\s*("NoodleCore Syntax Fixer is not available.*?"""\s*\n\s*"Please use the full NoodleCore IDE for syntax fixing capabilities."\s*\)\s*\)',
    r'''def fix_noodlecore_syntax(self):
        """Fix NoodleCore syntax issues in current file or all .nc files."""
        messagebox.showinfo(
            "Syntax Fixer",
            "NoodleCore Syntax Fixer is not available in this simplified version.\\n"
            "Please use the full NoodleCore IDE for syntax fixing capabilities."
        )''',
    content
)

content = re.sub(
    r'def show_python_integration_settings\(self\):\s*"""Show Python Integration Settings dialog\."""\s*messagebox\.showinfo\(\s*"Python Integration",\s*("Python Integration settings are not available.*?"""\s*\n\s*"Please use the full NoodleCore IDE for Python integration capabilities."\s*\)\s*\)',
    r'''def show_python_integration_settings(self):
        """Show Python Integration Settings dialog."""
        messagebox.showinfo(
            "Python Integration",
            "Python Integration settings are not available in this simplified version.\\n"
            "Please use the full NoodleCore IDE for Python integration capabilities."
        )''',
    content
)

# Write the fixed content back to the file
with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Applied comprehensive syntax fixes to native_gui_ide.py")

