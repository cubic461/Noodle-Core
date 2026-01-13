#!/usr/bin/env python3
"""
Noodle Core::Fix All Syntax Errors - fix_all_syntax_errors.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""


import re
import os

def fix_native_gui_ide_syntax():
    """Fix all syntax errors in native_gui_ide.py"""
    file_path = "noodle-core/src/noodlecore/desktop/ide/native_gui_ide.py"
    
    # Read the file
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix 1: Add newline after shebang
    content = re.sub(r'^(#!/usr/bin/env python3)([^"\n])', r'\1\n\2', content)
    
    # Fix 2: Fix indentation errors in exception handlers
    # Fix the duplicate except block around line 3743
    content = re.sub(
        r'except Exception as e:\s*\n\s*except Exception as e:\s*\n\s*safe_print\(f"Error during IDE exit: \{e\}"\)\s*\n\s*self\.root\.quit\(\)\s*\n\s*self\.root\.destroy\(\)',
        'except Exception as e:\n            safe_print(f"Error during IDE exit: {e}")\n            self.root.quit()\n            self.root.destroy()',
        content
    )
    
    # Fix 3: Fix the broken run() method
    content = re.sub(
        r'def run\(\):\s*"""Run the IDE main loop\."""\s*try:\s*# Start the Tkinter main loop\s*self\.root\.mainloop\(\)\s*return 0  # Success exit code\s*return 0  # Success exit code\s*except KeyboardInterrupt:\s*safe_print\("IDE interrupted by user"\)\s*return 1\s*safe_print\(f"IDE error: \{e\}"\)\s*return 1',
        '''def run(self):
        """Run the IDE main loop."""
        try:
            # Start the Tkinter main loop
            self.root.mainloop()
            return 0  # Success exit code
        except KeyboardInterrupt:
            safe_print("IDE interrupted by user")
            return 1
        except Exception as e:
            safe_print(f"IDE error: {e}")
            return 1''',
        content
    )
    
    # Fix 4: Fix the broken _update_project_index method
    content = re.sub(
        r'except Exception as e:\s*except Exception as e:\s*safe_print\(f"Failed to index \{rel_path\}: \{e\}"\)\s*else:',
        '''except Exception as e:
                    safe_print(f"Failed to index {rel_path}: {e}")
            else:''',
        content
    )
    
    # Fix 5: Fix the broken execute_ai_file_command method
    content = re.sub(
        r'if Command\[\'type\'\] == \'read\':',
        "if command['type'] == 'read':",
        content
    )
    
    content = re.sub(
        r'elif Command\[\'type\'\] == \'write\':',
        "elif command['type'] == 'write':",
        content
    )
    
    content = re.sub(
        r'elif Command\[\'type\'\] == \'modify\':',
        "elif command['type'] == 'modify':",
        content
    )
    
    content = re.sub(
        r'elif Command\[\'type\'\] == \'analyze\':',
        "elif command['type'] == 'analyze':",
        content
    )
    
    # Write the fixed content back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Fixed syntax errors in {file_path}")

if __name__ == "__main__":
    fix_native_gui_ide_syntax()

