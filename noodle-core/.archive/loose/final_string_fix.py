#!/usr/bin/env python3
"""
Noodle Core::Final String Fix - final_string_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Final string fix for native_gui_ide.py
This script will fix the specific string issue on line 42.
"""

import re

def fix_string_issue():
    """Fix the specific string issue on line 42"""
    
    with open('noodle-core/src/noodlecore/desktop/ide/native_gui_ide.py', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix the duplicate string definition on line 42
    # Replace: """Show AI chat interface with help."""        # AI chat is always visible in our layout        help_text = """help_text = """[UNICODE] AI Bestandscommando's:
    # With: """Show AI chat interface with help."""        # AI chat is always visible in our layout        help_text = """[UNICODE] AI Bestandscommando's:
    content = re.sub(
        r'"""Show AI chat interface with help\."""\s*# AI chat is always visible in our layout\s*help_text = """help_text = """\[UNICODE\] AI Bestandscommando\'s:',
        '"""Show AI chat interface with help."""\n        # AI chat is always visible in our layout\n        help_text = """[UNICODE] AI Bestandscommando\'s:',
        content
    )
    
    # Write the fixed content back to the file
    with open('noodle-core/src/noodlecore/desktop/ide/native_gui_ide.py', 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("Fixed string issue in native_gui_ide.py")

if __name__ == "__main__":
    fix_string_issue()

