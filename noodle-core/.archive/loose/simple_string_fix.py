#!/usr/bin/env python3
"""
Noodle Core::Simple String Fix - simple_string_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple fix for the unterminated string literal at line 44.
"""

def simple_fix():
    """Simple fix for the unterminated string literal."""
    
    with open('noodle-core/src/noodlecore/desktop/ide/native_gui_ide.py', 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Find and fix the problematic help_text section
    # We need to find the line with the unterminated string and close it properly
    for i, line in enumerate(lines):
        if 'help_text = """[UNICODE] AI Bestandscommando\'s:' in line:
            # Found the problematic line, now we need to find where to close it
            # Look for the messagebox line that should come after the string
            for j in range(i, len(lines)):
                if 'messagebox.showinfo("AI Chat Help", help_text)' in lines[j]:
                    # Replace the section with properly formatted code
                    lines[i] = '        help_text = """[UNICODE] AI Bestandscommando\'s:\n'
                    lines[i+1] = '    Bestandsbewerkingen:\n'
                    lines[i+2] = '    [UNICODE] lees [bestandsnaam] - Lees een bestand\n'
                    lines[i+3] = '    [UNICODE] schrijf [bestandsnaam]: [inhoud] - Maak een nieuw bestand met inhoud\n'
                    lines[i+4] = '    [UNICODE] pas [bestandsnaam] aan: [inhoud] - Wijzig een bestaand bestand\n'
                    lines[i+5] = '    [UNICODE] open [bestandsnaam] - Open bestand in editor\n'
                    lines[i+6] = '    \n'
                    lines[i+7] = '    Projectanalyse:\n'
                    lines[i+8] = '    [UNICODE] analyseer [pad] - Analyseer projectstructuur en bestanden\n'
                    lines[i+9] = '    [UNICODE] index [pad] - Indexeer project met NoodleCore\n'
                    lines[i+10] = '    [UNICODE] overzicht [pad] - Toon projectoverzicht\n'
                    lines[i+11] = '    [UNICODE] scan [pad] - Scan project op bestanden en mappen\n'
                    lines[i+12] = '    \n'
                    lines[i+13] = '    Voorbeelden:\n'
                    lines[i+14] = '    [UNICODE] "lees main.py"\n'
                    lines[i+15] = '    [UNICODE] "schrijf test.py: print(\'hello world\')"\n'
                    lines[i+16] = '    [UNICODE] "pas config.json aan: {\'debug\': true}"\n'
                    lines[i+17] = '    [UNICODE] "analyseer src/"\n'
                    lines[i+18] = '    [UNICODE] "index ."\n'
                    lines[i+19] = '    \n'
                    lines[i+20] = '    De AI chat bevindt zich in het linkerpaneel."""\n'
                    lines[i+21] = '        messagebox.showinfo("AI Chat Help", help_text)\n'
                    break
            break
    
    # Write the fixed content back to the file
    with open('noodle-core/src/noodlecore/desktop/ide/native_gui_ide.py', 'w', encoding='utf-8') as f:
        f.writelines(lines)
    
    print("Fixed unterminated string literal in help_text definition")

if __name__ == "__main__":
    simple_fix()

