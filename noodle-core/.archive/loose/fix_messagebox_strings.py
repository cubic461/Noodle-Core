#!/usr/bin/env python3
"""
Noodle Core::Fix Messagebox Strings - fix_messagebox_strings.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""Fix unterminated string literals in messagebox functions in native_gui_ide.py"""

import os

# Path to the file
file_path = os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'desktop', 'ide', 'native_gui_ide.py')

# Read the file
with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Fix the fix_noodlecore_syntax method (lines 1066-1073)
if len(lines) > 1073:
    lines[1066] = '    def fix_noodlecore_syntax(self):\n'
    lines[1067] = '        """Fix NoodleCore syntax issues in current file or all .nc files."""\n'
    lines[1068] = '        messagebox.showinfo(\n'
    lines[1069] = '            "Syntax Fixer",\n'
    lines[1070] = '            "NoodleCore Syntax Fixer is not available in this simplified version.\\n"\n'
    lines[1071] = '            "Please use the full NoodleCore IDE for syntax fixing capabilities."\n'
    lines[1072] = '        )\n'
    lines[1073] = '\n'

# Fix the show_python_integration_settings method (lines 1075-1082)
if len(lines) > 1082:
    lines[1075] = '    def show_python_integration_settings(self):\n'
    lines[1076] = '        """Show Python Integration Settings dialog."""\n'
    lines[1077] = '        messagebox.showinfo(\n'
    lines[1078] = '            "Python Integration",\n'
    lines[1079] = '            "Python Integration settings are not available in this simplified version.\\n"\n'
    lines[1080] = '            "Please use the full NoodleCore IDE for Python integration capabilities."\n'
    lines[1081] = '        )\n'
    lines[1082] = '\n'

# Write the file back
with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(lines)

print("Fixed messagebox string literals")

