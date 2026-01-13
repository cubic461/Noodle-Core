#!/usr/bin/env python3
"""
Noodle Core::Fix Line 969 - fix_line_969.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""Fix missing except/finally block on line 969 in native_gui_ide.py"""

import os

# Path to the file
file_path = os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'desktop', 'ide', 'native_gui_ide.py')

# Read the file
with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Fix line 969 - add missing except block
if len(lines) > 968:
    lines[968] = '        except Exception as e:\n'

# Write the file back
with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(lines)

print("Fixed missing except block on line 969")

