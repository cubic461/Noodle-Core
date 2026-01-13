#!/usr/bin/env python3
"""
Noodle Core::Fix Indentation 973 - fix_indentation_973.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""Fix indentation error at line 973 in native_gui_ide.py"""

import os

def fix_indentation_973():
    file_path = os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'desktop', 'ide', 'native_gui_ide.py')
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Fix the indentation issue around line 973
    # The problem is that the 'for' loop is not properly indented
    # and the 'files' variable is not defined
    
    # Replace the problematic section (lines 969-977)
    start_line = 968  # 0-based index
    end_line = 976    # 0-based index
    
    # New content with proper indentation and missing files variable
    new_lines = [
        "            # Files\n",
        "            files = [f for f in target_path.iterdir() if f.is_file() and not f.name.startswith('.')]\n",
        "            self.terminal_output.insert('end', f\"\\nFiles ({len(files)}):\\n\")\n",
        "            for f in sorted(files):\n",
        "                size_str = f\"({f.stat().st_size} bytes)\" if f.stat().st_size < 1024 else f\"({f.stat().st_size // 1024} KB)\"\n",
        "                self.terminal_output.insert('end', f\"\\n  {f.name} {size_str}\\n\")\n",
        "            \n",
        "            self.terminal_output.insert('end', \"=\" * 50 + \"\\n\")\n",
        "            self.terminal_output.config(state='disabled')\n",
        "            self.terminal_output.see('end')\n",
        "            \n",
        "            self.status_bar.config(text=f\"Scanned: {path if path else 'current project'}\")\n"
    ]
    
    # Replace the lines
    lines[start_line:end_line+1] = new_lines
    
    # Write back to file
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    
    print(f"Fixed indentation error at line 973 in {file_path}")

if __name__ == "__main__":
    fix_indentation_973()

