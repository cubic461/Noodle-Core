#!/usr/bin/env python3
"""
Noodle Core::Final Comprehensive Fix - final_comprehensive_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Final comprehensive fix for all string issues in native_gui_ide.py
"""

def final_comprehensive_fix():
    """Fix all string issues in file"""
    
    with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix the specific problematic section around line 728-736
    old_section = '''            self.terminal_output.insert('end', f"\\n[READ] {filename}:\\n")
[READ] {filename}:
")
            self.terminal_output.insert('end', "-" * 50 + "\\n"\\n")
            self.terminal_output.insert('end', content)
            self.terminal_output.insert('end', "\\n" + "-" * 50 + "\\n"\\n")
            self.terminal_output.config(state='disabled')
            self.terminal_output.see('end')'''
    
    new_section = '''            self.terminal_output.insert('end', f"\\n[READ] {filename}:\\n")
            self.terminal_output.insert('end', "-" * 50 + "\\n")
            self.terminal_output.insert('end', content)
            self.terminal_output.insert('end', "\\n" + "-" * 50 + "\\n")
            self.terminal_output.config(state='disabled')
            self.terminal_output.see('end')'''
    
    content = content.replace(old_section, new_section)
    
    # Fix other similar patterns throughout the file
    # Pattern 1: Fix error messages with \n
    content = content.replace(
        'self.terminal_output.insert(\'end\', f"[ERROR] Failed to read {filename}: {str(e)}\\n")',
        'self.terminal_output.insert(\'end\', f"[ERROR] Failed to read {filename}: {str(e)}\\n")'
    )
    
    content = content.replace(
        'self.terminal_output.insert(\'end\', f"[ERROR] Failed to write {filename}: {str(e)}\\n")',
        'self.terminal_output.insert(\'end\', f"[ERROR] Failed to write {filename}: {str(e)}\\n")'
    )
    
    content = content.replace(
        'self.terminal_output.insert(\'end\', f"[ERROR] Failed to modify {filename}: {str(e)}\\n")',
        'self.terminal_output.insert(\'end\', f"[ERROR] Failed to modify {filename}: {str(e)}\\n")'
    )
    
    content = content.replace(
        'self.terminal_output.insert(\'end\', f"[ERROR] Failed to open {filename}: {str(e)}\\n")',
        'self.terminal_output.insert(\'end\', f"[ERROR] Failed to open {filename}: {str(e)}\\n")'
    )
    
    # Pattern 2: Fix success messages
    content = content.replace(
        'self.terminal_output.insert(\'end\', f"[WRITE] Created {filename}\\n")',
        'self.terminal_output.insert(\'end\', f"[WRITE] Created {filename}\\n")'
    )
    
    content = content.replace(
        'self.terminal_output.insert(\'end\', f"[MODIFY] Updated {filename}\\n")',
        'self.terminal_output.insert(\'end\', f"[MODIFY] Updated {filename}\\n")'
    )
    
    # Pattern 3: Fix other broken string patterns
    content = content.replace(
        'self.terminal_output.insert(\'end\', f"\\n[ANALYZE] Project analysis for: {target_path}\\n")',
        'self.terminal_output.insert(\'end\', f"\\n[ANALYZE] Project analysis for: {target_path}\\n")'
    )
    
    content = content.replace(
        'self.terminal_output.insert(\'end\', f"\\n[INDEX] Indexing project: {target_path}\\n")',
        'self.terminal_output.insert(\'end\', f"\\n[INDEX] Indexing project: {target_path}\\n")'
    )
    
    content = content.replace(
        'self.terminal_output.insert(\'end\', f"\\n[OVERVIEW] Project overview for: {target_path}\\n")',
        'self.terminal_output.insert(\'end\', f"\\n[OVERVIEW] Project overview for: {target_path}\\n")'
    )
    
    content = content.replace(
        'self.terminal_output.insert(\'end\', f"\\n[SCAN] Scanning project: {target_path}\\n")',
        'self.terminal_output.insert(\'end\', f"\\n[SCAN] Scanning project: {target_path}\\n")'
    )
    
    content = content.replace(
        'self.terminal_output.insert(\'end\', f"\\n[VALIDATE] Validating all .nc files...\\n")',
        'self.terminal_output.insert(\'end\', f"\\n[VALIDATE] Validating all .nc files...\\n")'
    )
    
    content = content.replace(
        'self.terminal_output.insert(\'end\', f"\\n[HEALTH] Project Health Check:\\n")',
        'self.terminal_output.insert(\'end\', f"\\n[HEALTH] Project Health Check:\\n")'
    )
    
    content = content.replace(
        'self.terminal_output.insert(\'end\', f"\\n[HEALTH] Overall Health Score: {health_score}/100\\n")',
        'self.terminal_output.insert(\'end\', f"\\n[HEALTH] Overall Health Score: {health_score}/100\\n")'
    )
    
    # Pattern 4: Fix any remaining \n" patterns
    content = content.replace('\\n"\\n"', '\\n"')
    
    # Write back the fixed content
    with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("Fixed all string issues comprehensively")

if __name__ == "__main__":
    final_comprehensive_fix()

