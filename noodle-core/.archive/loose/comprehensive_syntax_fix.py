#!/usr/bin/env python3
"""
Noodle Core::Comprehensive Syntax Fix - comprehensive_syntax_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Comprehensive syntax fix for native_gui_ide.py
This script will fix all syntax issues in the file.
"""

import re

def fix_syntax_issues():
    """Fix all syntax issues in native_gui_ide.py"""
    
    with open('noodle-core/src/noodlecore/desktop/ide/native_gui_ide.py', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix 1: Add proper newline after shebang
    if content.startswith('#!/usr/bin/env python3"""'):
        content = content.replace('#!/usr/bin/env python3"""', '#!/usr/bin/env python3\n"""')
    
    # Fix 2: Fix the unterminated string at line 50
    content = re.sub(r'elp\."\s*# AI chat is always visible', 'elp."""\n        # AI chat is always visible', content)
    
    # Fix 3: Fix broken method definitions and indentation
    # Fix show_ai_chat method
    content = re.sub(r'def show_ai_chat\(\.\.\.\):\s*"""Show AI chat interface with h:\s*elp\."""', 
                   'def show_ai_chat(self):\n        """Show AI chat interface with help."""', content)
    
    # Fix 4: Fix broken string literals with line breaks
    content = re.sub(r'\[UNICODE\] AI Bestandscommando\'s:\s*Bestandsbewerkingen:\[UNICODE\] lees \[bestandsnaam\] - Lees een bestand\[UNICODE\] schrijf \[bestandsnaam\]: \[inhoud\] - Maak een nieuw bestand met inhoud\[UNICODE\] pas \[bestandsnaam\] aan: \[inhoud\] - Wijzig een bestaand bestand\[UNICODE\] open \[bestandsnaam\] - Open bestand in editorProjectanalyse:\[UNICODE\] analyseer \[pad\] - Analyseer projectstructuur en bestanden\[UNICODE\] index \[pad\] - Indexeer project met NoodleCore\[UNICODE\] overzicht \[pad\] - Toon projectoverzicht\[UNICODE\] scan \[pad\] - Scan project op bestanden en mappenVoorbeelden:\[UNICODE\] "lees main\.py"\[UNICODE\] "schrijf test\.py:\s*print\(\'hello world\'\)"\[UNICODE\] "pas config\.json aan: \{\'debug\':\s*true\}"\[UNICODE\] "analyseer src/"\[UNICODE\] "index \."\s*De AI chat bevindt zich in het linkerpaneel\."""', 
                   '''help_text = """[UNICODE] AI Bestandscommando's:
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
    
    De AI chat bevindt zich in het linkerpaneel."""''', content, flags=re.MULTILINE | re.DOTALL)
    
    # Fix 5: Fix broken method signatures with ... instead of self
    content = re.sub(r'def (\w+)\(\.\.\.\):', r'def \1(self):', content)
    
    # Fix 6: Fix broken if statements with line breaks in the middle
    content = re.sub(r'if n:\s*ot', 'if not', content)
    content = re.sub(r'if s:\s*elf', 'if self', content)
    content = re.sub(r'if h:\s*asattr', 'if hasattr', content)
    content = re.sub(r'if r:\s*esult', 'if result', content)
    content = re.sub(r'if l:\s*en', 'if len', content)
    content = re.sub(r'if d:\s*irs', 'if dirs', content)
    content = re.sub(r'if f:\s*ile', 'if file', content)
    content = re.sub(r'if t:\s*ext', 'if text', content)
    content = re.sub(r'if a:\s*i_', 'if ai_', content)
    content = re.sub(r'if m:\s*odels', 'if models', content)
    content = re.sub(r'if F:\s*EEDBACK', 'if FEEDBACK', content)
    
    # Fix 7: Fix broken exception handling
    content = re.sub(r'except E:\s*xception', 'except Exception', content)
    content = re.sub(r'except F:\s*ileNotFoundError', 'except FileNotFoundError', content)
    content = re.sub(r'except K:\s*eyboardInterrupt', 'except KeyboardInterrupt', content)
    
    # Fix 8: Fix broken import statements
    content = re.sub(r'import \s*t', 'import t', content)
    content = re.sub(r'import \s*o', 'import o', content)
    content = re.sub(r'from \s*\.', 'from .', content)
    
    # Fix 9: Fix broken with statements
    content = re.sub(r'with o:\s*pen', 'with open', content)
    content = re.sub(r'with t:\s*empfile', 'with tempfile', content)
    
    # Fix 10: Fix broken for loops
    content = re.sub(r'for r:\s*oot', 'for root', content)
    content = re.sub(r'for d:\s*irs', 'for dirs', content)
    content = re.sub(r'for f:\s*ile', 'for file', content)
    content = re.sub(r'for t:\s*ab', 'for tab', content)
    content = re.sub(r'for i:\s*n', 'for in', content)
    content = re.sub(r'for l:\s*ine', 'for line', content)
    content = re.sub(r'for s:\s*ystem', 'for system', content)
    content = re.sub(r'for o:\s*p', 'for op', content)
    content = re.sub(r'for c:\s*all', 'for call', content)
    content = re.sub(r'for d:\s*ep', 'for dep', content)
    content = re.sub(r'for r:\s*ec', 'for rec', content)
    content = re.sub(r'for m:\s*etric', 'for metric', content)
    content = re.sub(r'for l:\s*ib', 'for lib', content)
    
    # Fix 11: Fix broken return statements
    content = re.sub(r'return \s*m', 'return m', content)
    content = re.sub(r'return \s*r', 'return r', content)
    
    # Fix 12: Fix broken variable references
    content = re.sub(r's:\s*tatus', 'status', content)
    content = re.sub(r'p:\s*rogress', 'progress', content)
    content = re.sub(r'c:\s*ontent', 'content', content)
    content = re.sub(r'f:\s*ile_path', 'file_path', content)
    content = re.sub(r'm:\s*essage', 'message', content)
    content = re.sub(r'e:\s*rror', 'error', content)
    
    # Fix 13: Fix broken string literals with [UNICODE] in the middle
    content = re.sub(r'\[UNICODE\]\s*:', '[UNICODE]:', content)
    
    # Fix 14: Fix broken method calls
    content = re.sub(r's:\s*et', 'set', content)
    content = re.sub(r'c:\s*onfig', 'config', content)
    content = re.sub(r'g:\s*et', 'get', content)
    content = re.sub(r'a:\s*ppend', 'append', content)
    content = re.sub(r'i:\s*nsert', 'insert', content)
    content = re.sub(r'd:\s*elete', 'delete', content)
    content = re.sub(r'p:\s*ack', 'pack', content)
    content = re.sub(r'p:\s*adx', 'padx', content)
    content = re.sub(r'p:\s*ady', 'pady', content)
    
    # Write the fixed content back to the file
    with open('noodle-core/src/noodlecore/desktop/ide/native_gui_ide.py', 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("Fixed syntax issues in native_gui_ide.py")

if __name__ == "__main__":
    fix_syntax_issues()

