#!/usr/bin/env python3
"""
Noodle Core::Fix Line 961 - fix_line_961.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Fix the duplicate line at line 961 in native_gui_ide.py
"""

with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'r') as f:
    lines = f.readlines()

# Remove the duplicate line at line 961 (index 960)
if len(lines) > 960:
    del lines[960]

with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'w') as f:
    f.writelines(lines)

print("Removed duplicate line at line 961")

