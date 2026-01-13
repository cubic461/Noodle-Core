#!/usr/bin/env python3
"""
Noodle Core::Complete String Fix - complete_string_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Complete fix for all string issues in native_gui_ide.py
"""

def complete_string_fix():
    """Fix all string issues in file"""
    
    with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix all instances of broken string patterns
    # Pattern 1: Fix unterminated f-strings with newlines
    content = content.replace(
        '            self.terminal_output.insert(\'end\', f"',
        '            self.terminal_output.insert(\'end\', f"\\n'
    )
    
    # Pattern 2: Fix broken string continuations
    content = content.replace(
        '            self.terminal_output.insert(\'end\', "-" * 50 + "',
        '            self.terminal_output.insert(\'end\', "-" * 50 + "\\n"'
    )
    
    # Pattern 3: Fix standalone string quotes
    content = content.replace(
        '            self.terminal_output.insert(\'end\', content',
        '            self.terminal_output.insert(\'end\', content'
    )
    
    # Pattern 4: Fix broken string with quote at beginning
    content = content.replace(
        '            self.terminal_output.insert(\'end\', "\\n" + "-" * 50 + "',
        '            self.terminal_output.insert(\'end\', "\\n" + "-" * 50 + "\\n"'
    )
    
    # Pattern 5: Fix all standalone quote lines
    lines = content.split('\n')
    fixed_lines = []
    
    for line in lines:
        # Skip standalone quote lines
        if line.strip() == '")':
            continue
        # Fix lines that end with unterminated strings
        if line.endswith('"\n') and 'self.terminal_output.insert' in line and not line.endswith('\\n")'):
            line = line.replace('"\n', '\\n")\n')
        fixed_lines.append(line)
    
    # Rejoin the content
    content = '\n'.join(fixed_lines)
    
    # Write back the fixed content
    with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("Fixed all string issues")

if __name__ == "__main__":
    complete_string_fix()

