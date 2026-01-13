#!/usr/bin/env python3
"""
Noodle Core::Fix Line 1077 - fix_line_1077.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""Fix unterminated string literal on line 1077 in native_gui_ide.py"""

import os

# Path to the file
file_path = os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'desktop', 'ide', 'native_gui_ide.py')

# Read the file
with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Fix line 1077 - missing closing quote
if len(lines) > 1076:
    lines[1076] = '            "Python Integration settings are not available in this simplified version.\\n"\n'

# Write the file back
with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(lines)

print("Fixed unterminated string literal on line 1077")

