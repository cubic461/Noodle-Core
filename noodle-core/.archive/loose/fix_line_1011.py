#!/usr/bin/env python3
"""
Noodle Core::Fix Line 1011 - fix_line_1011.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""Fix unterminated string literal on line 1011 in native_gui_ide.py"""

import os

# Path to the file
file_path = os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'desktop', 'ide', 'native_gui_ide.py')

# Read the file
with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Fix line 1011 - replace the broken string with proper one
if len(lines) > 1010:
    lines[1010] = '        self.terminal_output.insert(\'end\', "=" * 50 + "\\n")\n'

# Write the file back
with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(lines)

print("Fixed unterminated string literal on line 1011")

