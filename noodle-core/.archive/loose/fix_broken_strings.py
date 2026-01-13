#!/usr/bin/env python3
"""
Noodle Core::Fix Broken Strings - fix_broken_strings.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Fix for broken multi-line strings in native_gui_ide.py
"""

def fix_broken_strings():
    """Fix all broken multi-line strings in file"""
    
    with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Fix the specific broken section starting at line 729
    # Lines 729-736 have broken string literals
    
    # Replace line 729: [READ] {filename}:
    if 728 < len(lines):
        lines[728] = '            self.terminal_output.insert(\'end\', f"[READ] {filename}:\\n")\n'
    
    # Replace line 730: ")
    if 729 < len(lines):
        lines[729] = '            self.terminal_output.insert(\'end\', "-" * 50 + "\\n")\n'
    
    # Replace line 731: ")
    if 730 < len(lines):
        lines[730] = '            self.terminal_output.insert(\'end\', content)\n'
    
    # Replace line 732: ")
    if 731 < len(lines):
        lines[731] = '            self.terminal_output.insert(\'end\', "\\n" + "-" * 50 + "\\n")\n'
    
    # Replace line 733: ")
    if 732 < len(lines):
        lines[732] = '            self.terminal_output.config(state=\'disabled\')\n'
    
    # Replace line 734: ")
    if 733 < len(lines):
        lines[733] = '            self.terminal_output.see(\'end\')\n'
    
    # Fix other similar patterns throughout the file
    for i, line in enumerate(lines):
        # Fix unterminated error messages
        if 'self.terminal_output.insert(\'end\', f"[ERROR] Failed to read {filename}: {str(e)}\n")' in line:
            lines[i] = line.replace('\n")', '\\n")')
        
        if 'self.terminal_output.insert(\'end\', f"[ERROR] Failed to write {filename}: {str(e)}\n")' in line:
            lines[i] = line.replace('\n")', '\\n")')
        
        if 'self.terminal_output.insert(\'end\', f"[ERROR] Failed to modify {filename}: {str(e)}\n")' in line:
            lines[i] = line.replace('\n")', '\\n")')
        
        if 'self.terminal_output.insert(\'end\', f"[ERROR] Failed to open {filename}: {str(e)}\n")' in line:
            lines[i] = line.replace('\n")', '\\n")')
        
        if 'self.terminal_output.insert(\'end\', f"[WRITE] Created {filename}\n")' in line:
            lines[i] = line.replace('\n")', '\\n")')
        
        if 'self.terminal_output.insert(\'end\', f"[MODIFY] Updated {filename}\n")' in line:
            lines[i] = line.replace('\n")', '\\n")')
        
        # Fix other broken string patterns
        if line.strip() == '")':
            # This is likely a broken string continuation
            if i > 0 and 'self.terminal_output.insert' in lines[i-1]:
                # Fix the previous line to properly terminate the string
                lines[i-1] = lines[i-1].rstrip() + '\\n")\n'
                # Remove this broken line
                lines[i] = ''
    
    # Write back the fixed content
    with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'w', encoding='utf-8') as f:
        f.writelines(lines)
    
    print("Fixed broken multi-line strings")

if __name__ == "__main__":
    fix_broken_strings()

