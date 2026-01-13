#!/usr/bin/env python3
"""
Noodle Core::Fix Line 834 - fix_line_834.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Fix the duplicate line at line 834 in native_gui_ide.py
"""

with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'r') as f:
    lines = f.readlines()

# Remove the duplicate line at line 834 (index 833)
if len(lines) > 833:
    del lines[833]

with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'w') as f:
    f.writelines(lines)

print("Removed duplicate line at line 834")

