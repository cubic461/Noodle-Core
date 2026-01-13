#!/usr/bin/env python3
"""
Noodle Core::Fix Line 990 - fix_line_990.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Fix the duplicate line at line 990 in native_gui_ide.py
"""

with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'r') as f:
    lines = f.readlines()

# Remove the duplicate line at line 990 (index 989)
if len(lines) > 989:
    del lines[989]

with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'w') as f:
    f.writelines(lines)

print("Removed duplicate line at line 990")

