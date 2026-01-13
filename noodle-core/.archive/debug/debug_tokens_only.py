#!/usr/bin/env python3
"""
Noodle Core::Debug Tokens Only - debug_tokens_only.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Debug only the token stream for underscore pattern matching
"""

import sys
import os

# Add noodle-core directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from simple_lexer import SimpleLexer, TokenType

def debug_tokens():
    """Debug token stream for underscore pattern matching"""
    
    # Test case 2: Multiple patterns with underscore
    code = """match x {
    1 => "one",
    _ => "default"
}"""
    
    print("=== Debug Tokens ===")
    print(f"Code: {code}")
    
    # Test lexer only
    lexer = SimpleLexer(code, "test2.nc")
    tokens = lexer.tokenize()
    
    print("\n=== Tokens ===")
    for i, token in enumerate(tokens):
        print(f"{i}: {token.type.value} = '{token.value}' at {token.location}")
    
    # Check if underscore token is present
    underscore_tokens = [t for t in tokens if t.type == TokenType.UNDERSCORE]
    print(f"\nFound {len(underscore_tokens)} underscore tokens in lexer")
    
    # Find the position of the underscore token
    for i, token in enumerate(tokens):
        if token.type == TokenType.UNDERSCORE:
            print(f"Underscore token at position {i}: {token.type.value} = '{token.value}' at {token.location}")
            # Show tokens around it
            print("Tokens around underscore:")
            for j in range(max(0, i-3), min(len(tokens), i+4)):
                t = tokens[j]
                marker = " <-- UNDERSCORE" if j == i else ""
                print(f"  {j}: {t.type.value} = '{t.value}' at {t.location}{marker}")

if __name__ == "__main__":
    debug_tokens()

