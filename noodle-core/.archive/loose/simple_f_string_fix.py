#!/usr/bin/env python3
"""
Noodle Core::Simple F String Fix - simple_f_string_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple fix for unterminated f-strings in native_gui_ide.py
"""

def fix_f_strings():
    """Fix all unterminated f-strings in file"""
    
    with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix specific unterminated f-strings
    content = content.replace(
        'f"[ERROR] Unknown command: {command_text}"',
        'f"[ERROR] Unknown command: {command_text}\\n"'
    )
    
    content = content.replace(
        'f"[ERROR] Failed to execute command: {str(e)}"',
        'f"[ERROR] Failed to execute command: {str(e)}\\n"'
    )
    
    content = content.replace(
        'f"[READ] {filename}:"',
        'f"[READ] {filename}:\\n"'
    )
    
    content = content.replace(
        'f"[WRITE] Created {filename}"',
        'f"[WRITE] Created {filename}\\n"'
    )
    
    content = content.replace(
        'f"[MODIFY] Updated {filename}"',
        'f"[MODIFY] Updated {filename}\\n"'
    )
    
    content = content.replace(
        'f"[ERROR] Failed to read {filename}: {str(e)}"',
        'f"[ERROR] Failed to read {filename}: {str(e)}\\n"'
    )
    
    content = content.replace(
        'f"[ERROR] Failed to write {filename}: {str(e)}"',
        'f"[ERROR] Failed to write {filename}: {str(e)}\\n"'
    )
    
    content = content.replace(
        'f"[ERROR] Failed to modify {filename}: {str(e)}"',
        'f"[ERROR] Failed to modify {filename}: {str(e)}\\n"'
    )
    
    content = content.replace(
        'f"[ERROR] Failed to open {filename}: {str(e)}"',
        'f"[ERROR] Failed to open {filename}: {str(e)}\\n"'
    )
    
    content = content.replace(
        'f"[ANALYZE] Project analysis for: {target_path}"',
        'f"[ANALYZE] Project analysis for: {target_path}\\n"'
    )
    
    content = content.replace(
        'f"[INDEX] Indexing project: {target_path}"',
        'f"[INDEX] Indexing project: {target_path}\\n"'
    )
    
    content = content.replace(
        'f"[OVERVIEW] Project overview for: {target_path}"',
        'f"[OVERVIEW] Project overview for: {target_path}\\n"'
    )
    
    content = content.replace(
        'f"[SCAN] Scanning project: {target_path}"',
        'f"[SCAN] Scanning project: {target_path}\\n"'
    )
    
    content = content.replace(
        'f"[VALIDATE] Validating all .nc files..."',
        'f"[VALIDATE] Validating all .nc files...\\n"'
    )
    
    content = content.replace(
        'f"[HEALTH] Project Health Check:"',
        'f"[HEALTH] Project Health Check:\\n"'
    )
    
    content = content.replace(
        'f"[HEALTH] Overall Health Score: {health_score}/100"',
        'f"[HEALTH] Overall Health Score: {health_score}/100\\n"'
    )
    
    with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("Fixed f-string terminations")

if __name__ == "__main__":
    fix_f_strings()

