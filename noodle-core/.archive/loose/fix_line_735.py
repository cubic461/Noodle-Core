#!/usr/bin/env python3
"""
Noodle Core::Fix Line 735 - fix_line_735.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Fix the broken string literal on line 735 in native_gui_ide.py
"""

with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'r') as f:
    lines = f.readlines()

# Fix the broken string literal on line 735 (index 734)
if len(lines) > 734:
    lines[734] = '            self.terminal_output.insert(\'end\', "\\n" + "-" * 50 + "\\n")\n'

with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'w') as f:
    f.writelines(lines)

print("Fixed broken string literal on line 735")

