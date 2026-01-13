#!/usr/bin/env python3
"""
Noodle Core::Fix String Termination - fix_string_termination.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Fix the unterminated string literal at line 44 in native_gui_ide.py.
"""

import re

def fix_string_termination():
    """Fix the unterminated string literal at line 44."""
    
    with open('noodle-core/src/noodlecore/desktop/ide/native_gui_ide.py', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find the problematic help_text string and fix it
    # The issue is that the string starts with """ but doesn't have a matching closing """
    
    # Replace the broken help_text section with a properly formatted one
    pattern = r'(\s+help_text = """\[UNICODE\] AI Bestandscommando\'s:.*?)(\s+messagebox\.showinfo\("AI Chat Help", help_text))'
    
    replacement = r'''        help_text = """[UNICODE] AI Bestandscommando's:
    Bestandsbewerkingen:
    [UNICODE] lees [bestandsnaam] - Lees een bestand
    [UNICODE] schrijf [bestandsnaam]: [inhoud] - Maak een nieuw bestand met inhoud
    [UNICODE] pas [bestandsnaam] aan: [inhoud] - Wijzig een bestaand bestand
    [UNICODE] open [bestandsnaam] - Open bestand in editor
    
    Projectanalyse:
    [UNICODE] analyseer [pad] - Analyseer projectstructuur en bestanden
    [UNICODE] index [pad] - Indexeer project met NoodleCore
    [UNICODE] overzicht [pad] - Toon projectoverzicht
    [UNICODE] scan [pad] - Scan project op bestanden en mappen
    
    Voorbeelden:
    [UNICODE] "lees main.py"
    [UNICODE] "schrijf test.py: print('hello world')"
    [UNICODE] "pas config.json aan: {'debug': true}"
    [UNICODE] "analyseer src/"
    [UNICODE] "index ."
    
    De AI chat bevindt zich in het linkerpaneel."""
        messagebox.showinfo("AI Chat Help", help_text)'''
    
    # Apply the fix
    content = re.sub(pattern, replacement, content, flags=re.DOTALL)
    
    # Write the fixed content back to the file
    with open('noodle-core/src/noodlecore/desktop/ide/native_gui_ide.py', 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("Fixed unterminated string literal in help_text definition")

if __name__ == "__main__":
    fix_string_termination()

