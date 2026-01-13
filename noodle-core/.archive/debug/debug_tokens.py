#!/usr/bin/env python3
"""
Noodle Core::Debug Tokens - debug_tokens.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Debug script to see the tokens for the test input
"""

import sys
import os

# Add noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'compiler'))

# Import directly from the modules
from simple_lexer import SimpleLexer, TokenType

def debug_tokens():
    """Debug the tokens for the test input"""
    source = """
def identity<T: Comparable>(value: T): T {
    return value;
}
"""
    
    lexer = SimpleLexer(source, "test")
    tokens = lexer.tokenize()
    
    print(f"Tokens ({len(tokens)}):")
    for i, token in enumerate(tokens):
        print(f"  {i}: {token.type.value}('{token.value}') at {token.location}")
    
    print(f"\nLexer errors: {len(lexer.errors)}")
    for error in lexer.errors:
        print(f"  - {error}")

if __name__ == "__main__":
    debug_tokens()

