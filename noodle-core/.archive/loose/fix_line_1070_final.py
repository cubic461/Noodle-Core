#!/usr/bin/env python3
"""
Noodle Core::Fix Line 1070 Final - fix_line_1070_final.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""Fix unterminated string literals on lines 1070 and 1079 in native_gui_ide.py"""

import os

# Path to the file
file_path = os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'desktop', 'ide', 'native_gui_ide.py')

# Read the file
with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Fix line 1070 (unterminated string in messagebox)
if len(lines) > 1070:
    lines[1069] = '            "NoodleCore Syntax Fixer is not available in this simplified version.\\n"\n'

# Fix line 1079 (unterminated string in messagebox)
if len(lines) > 1079:
    lines[1078] = '            "Python Integration settings are not available in this simplified version.\\n"\n'

# Write the file back
with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(lines)

print("Fixed unterminated string literals on lines 1070 and 1079")

