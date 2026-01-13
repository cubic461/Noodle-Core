#!/usr/bin/env python3
"""
Noodle Core::Debug Lexer - debug_lexer.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Debug script to understand the tokenization of the test input
"""

import sys
import os

# Add the noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'compiler'))

from simple_lexer import SimpleLexer, TokenType

def debug_lexer():
    source = """
    def identity<T: Comparable>(value: T): T {
        return value;
    }
    """
    
    lexer = SimpleLexer(source, "test")
    tokens = lexer.tokenize()
    
    print(f"Tokens ({len(tokens)}):")
    for i, token in enumerate(tokens):
        print(f"{i:3d}: {token.type.value:15s} '{token.value}' at {token.location}")

if __name__ == "__main__":
    debug_lexer()

