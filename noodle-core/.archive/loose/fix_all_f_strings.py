#!/usr/bin/env python3
"""
Noodle Core::Fix All F Strings - fix_all_f_strings.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Fix all unterminated f-strings in native_gui_ide.py
"""

import re

def fix_f_strings():
    """Fix all unterminated f-strings in the file"""
    
    with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix all unterminated f-strings by adding missing \n at the end
    # Pattern: f"[ERROR] ... {variable}" -> f"[ERROR] ... {variable}\n"
    # Pattern: f"[READ] ... {variable}" -> f"[READ] ... {variable}\n"
    # etc.
    
    # List of patterns to fix
    patterns = [
        (r'f"\[ERROR\] Unknown command: ({[^}]+)}"', r'f"[ERROR] Unknown command: {\1}\n"'),
        (r'f"\[ERROR\] Failed to execute command: ({[^}]+)}"', r'f"[ERROR] Failed to execute command: {\1}\n"'),
        (r'f"\[READ\] ({[^}]+)}:"', r'f"[READ] {\1}:\n"'),
        (r'f"\[WRITE\] Created ({[^}]+)}"', r'f"[WRITE] Created {\1}\n"'),
        (r'f"\[MODIFY\] Updated ({[^}]+)}"', r'f"[MODIFY] Updated {\1}\n"'),
        (r'f"\[ERROR\] Failed to read ({[^}]+)}:"', r'f"[ERROR] Failed to read {\1}:\n"'),
        (r'f"\[ERROR\] Failed to write ({[^}]+)}:"', r'f"[ERROR] Failed to write {\1}:\n"'),
        (r'f"\[ERROR\] Failed to modify ({[^}]+)}:"', r'f"[ERROR] Failed to modify {\1}:\n"'),
        (r'f"\[ERROR\] Failed to open ({[^}]+)}:"', r'f"[ERROR] Failed to open {\1}:\n"'),
        (r'f"\[ANALYZE\] Project analysis for: ({[^}]+)}"', r'f"[ANALYZE] Project analysis for: {\1}\n"'),
        (r'f"\[INDEX\] Indexing project: ({[^}]+)}"', r'f"[INDEX] Indexing project: {\1}\n"'),
        (r'f"\[OVERVIEW\] Project overview for: ({[^}]+)}"', r'f"[OVERVIEW] Project overview for: {\1}\n"'),
        (r'f"\[SCAN\] Scanning project: ({[^}]+)}"', r'f"[SCAN] Scanning project: {\1}\n"'),
        (r'f"\[VALIDATE\] Validating all \.nc files\.\.\.\."', r'f"[VALIDATE] Validating all .nc files...\n"'),
        (r'f"\[HEALTH\] Project Health Check:\.\.\.\."', r'f"[HEALTH] Project Health Check:\n"'),
        (r'f"\[HEALTH\] Overall Health Score: ({[^}]+)}/100"', r'f"[HEALTH] Overall Health Score: {\1}/100\n"'),
        (r'f"Read file: ({[^}]+)}"', r'f"Read file: {\1}"'),
        (r'f"Created file: ({[^}]+)}"', r'f"Created file: {\1}"'),
        (r'f"Modified file: ({[^}]+)}"', r'f"Modified file: {\1}"'),
        (r'f"Opened: ({[^}]+)}"', r'f"Opened: {\1}"'),
        (r'f"Analyzed: ({[^}]+)}"', r'f"Analyzed: {\1}"'),
        (r'f"Indexed: ({[^}]+)}"', r'f"Indexed: {\1}"'),
        (r'f"Overview: ({[^}]+)}"', r'f"Overview: {\1}"'),
        (r'f"Scanned: ({[^}]+)}"', r'f"Scanned: {\1}"'),
        (r'f"Validated ({[^}]+)} \.nc files"', r'f"Validated {\1} .nc files"'),
        (r'f"Project health score: ({[^}]+)}/100"', r'f"Project health score: {\1}/100"'),
        (r'f"Loaded workspace: ({[^}]+)}"', r'f"Loaded workspace: {\1}"'),
        (r'f"File already open: ({[^}]+)}"', r'f"File already open: {\1}"'),
        (r'f"Saved: ({[^}]+)}"', r'f"Saved: {\1}"'),
        (r'f"New file created"', r'f"New file created"'),
        (r'f"Found matches for: ({[^}]+)}"', r'f"Found matches for: {\1}"'),
        (r'f"No matches found for: ({[^}]+)}"', r'f"No matches found for: {\1}"'),
        (r'f"Replaced ({[^}]+)} occurrences of: ({[^}]+)}"', r'f"Replaced {\1} occurrences of: {\2}"'),
        (r'f"No occurrences found for: ({[^}]+)}"', r'f"No occurrences found for: {\1}"'),
        (r'f"Ready to configure\.\.\."', r'f"Ready to configure..."'),
        (r'f"Fetching models for ({[^}]+)}\.\.\."', r'f"Fetching models for {\1}..."'),
        (r'f"Found ({[^}]+)} models - Selected: ({[^}]+)}"', r'f"Found {\1} models - Selected: {\2}"'),
        (r'f"Total files: ({[^}]+)}"', r'f"Total files: {\1}"'),
        (r'f"File types:\.\.\."', r'f"File types:\n"'),
        (r'f"  ({[^}]+)}: ({[^}]+)}"', r'f"  {\1}: {\2}\n"'),
        (r'f"Directories \(({[^}]+)}\):"', r'f"Directories ({\1}):\n"'),
        (r'f"  ({[^}]+)/"', r'f"  {\1}/\n"'),
        (r'f"Files \(({[^}]+)}\):"', r'f"Files ({\1}):\n"'),
        (r'f"  ({[^}]+) ((\{[^}]+\}) bytes)"', r'f"  {\1} ({\2} bytes)"'),
        (r'f"  ({[^}]+) ((\{[^}]+\}) KB)"', r'f"  {\1} ({\2} KB)"'),
        (r'f"Directory structure:\.\.\."', r'f"Directory structure:\n"'),
        (r'f"  ({[^}]+) \.\.\."', r'f"  {\1}.\n"'),
        (r'f"  ({[^}]+) and ({[^}]+)} more files"', r'f"  {\1} and {\2} more files\n"'),
        (r'f"Indexed ({[^}]+)} files"', r'f"Indexed {\1} files\n"'),
        (r'f"No \.nc files found in project\.\.\."', r'f"No .nc files found in project.\n"'),
        (r'f"Found ({[^}]+)} \.nc files:\.\.\."', r'f"Found {\1} .nc files:\n"'),
        (r'f"  ({[^}]+)}"', r'f"  {\1}\n"'),
        (r'f"\[OK\] Git Repository: Healthy\.\.\."', r'f"[OK] Git Repository: Healthy\n"'),
        (r'f"\[ERROR\] Git Repository: Not initialized\.\.\."', r'f"[ERROR] Git Repository: Not initialized\n"'),
        (r'f"\[ERROR\] Git: Not installed\.\.\."', r'f"[ERROR] Git: Not installed\n"'),
        (r'f"\[ERROR\] Git Error: ({[^}]+)}"', r'f"[ERROR] Git Error: {\1}\n"'),
        (r'f"\[OK\] Python Files: ({[^}]+)} found\.\.\."', r'f"[OK] Python Files: {\1} found\n"'),
        (r'f"\[WARNING\] Python Files: None found\.\.\."', r'f"[WARNING] Python Files: None found\n"'),
        (r'f"\[OK\] Dependencies: ({[^}]+)} files found\.\.\."', r'f"[OK] Dependencies: {\1} files found\n"'),
        (r'f"\[WARNING\] Dependencies: No requirements file found\.\.\."', r'f"[WARNING] Dependencies: No requirements file found\n"'),
        (r'f"Failed to load workspace state: ({[^}]+)}"', r'f"Failed to load workspace state: {\1}"'),
        (r'f"Failed to save workspace state: ({[^}]+)}"', r'f"Failed to save workspace state: {\1}"'),
        (r'f"Failed to setup IDE logging: ({[^}]+)}"', r'f"Failed to setup IDE logging: {\1}"'),
        (r'f"[WARNING\] AERE integration not available: ({[^}]+)}"', r'f"[WARNING] AERE integration not available: {\1}"'),
        (r'f"[ERROR\] Failed to initialize AERE integration: ({[^}]+)}"', r'f"[ERROR] Failed to initialize AERE integration: {\1}"'),
        (r'f"[OK\] AERE integration initialized successfully"', r'f"[OK] AERE integration initialized successfully"'),
        (r'f"Error during IDE exit: ({[^}]+)}"', r'f"Error during IDE exit: {\1}"'),
        (r'f"IDE error: ({[^}]+)}"', r'f"IDE error: {\1}"'),
        (r'f"IDE interrupted by user"', r'f"IDE interrupted by user"'),
    ]
    
    # Apply all patterns
    for pattern, replacement in patterns:
        content = re.sub(pattern, replacement, content)
    
    # Fix specific line continuation issues
    content = re.sub(r'f"([^"]*)"\n\s*"', r'f"\1"', content)
    
    # Write the fixed content back
    with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("Fixed all unterminated f-strings in native_gui_ide.py")

if __name__ == "__main__":
    fix_f_strings()

