#!/usr/bin/env python3
"""
Noodle Core::Fix Shebang - fix_shebang.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""


def fix_shebang():
    """Fix the missing newline after shebang in native_gui_ide.py"""
    file_path = "noodle-core/src/noodlecore/desktop/ide/native_gui_ide.py"
    
    # Read the file
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix the shebang line by adding a newline after it
    if content.startswith('#!/usr/bin/env python3"""'):
        content = content.replace('#!/usr/bin/env python3"""', '#!/usr/bin/env python3\n"""')
    
    # Write the fixed content back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("Fixed shebang line in native_gui_ide.py")

if __name__ == "__main__":
    fix_shebang()

