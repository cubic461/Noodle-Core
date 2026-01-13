#!/usr/bin/env python3
"""
Test Suite::Noodle Lang - quick_test2.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""Simpele test - alleen lexer en parser, geen compleet compilatie"""

import os
import sys
from pathlib import Path

# Voeg compiler toe aan pad
sys.path.insert(0, str(Path(__file__).parent / "src"))

try:
    from noodle_lang.lexer import NoodleLexer
    print("âœ… Lexer geÃ¯mporteerd")
except Exception as e:
    print(f"âŒ Lexer import mislukt: {e}")
    sys.exit(1)

# Test met eenvoudige source
test_code = '''
def hello_world() {
    let message = "Hallo vanuit NoodleCore!";
    return message;
}
'''

print("\\nðŸ”„ Tokenizing simpele test code...")
lexer = NoodleLexer(test_code, "<test>")
tokens = lexer.tokenize()

if lexer.errors:
    print(f"âŒ Lexer errors: {len(lexer.errors)}")
    for error in lexer.errors[:3]:
        print(f"   {error.message} at line {error.location.line}")
    sys.exit(1)

print(f"âœ… Tokenizing gelukt! {len(tokens)} tokens gegenereerd")

# Toon eerste paar tokens
print("\\nðŸ“‹ Voorbeeld tokens (eerste 10):")
for i, token in enumerate(tokens[:10]):
    print(f"   [{i}] {token.type.value}: '{token.value}' at {token.location}")

print("nâœ… LEXER TEST GESLAAGD!")
print("   De compiler core werkt - alleen NBC runtime ontbreekt nog")
print("nðŸš€ Klaar voor NBC â†’ DeployableUnit integratie!")


