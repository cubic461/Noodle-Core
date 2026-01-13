#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_lexer_only.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to check lexer output for underscore
"""

import sys
import os

# Add noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from simple_lexer import SimpleLexer, TokenType

def test_underscore_lexer():
    """Test underscore tokenization"""
    
    # Test underscore in pattern context
    code = """
    match x {
        _ => "default"
    }
    """
    
    print("Code:")
    print(code.strip())
    
    # Test lexer
    lexer = SimpleLexer(code, "test.nc")
    tokens = lexer.tokenize()
    
    print("\nTokens:")
    for i, token in enumerate(tokens):
        print(f"  {i}: {token.type.value} = '{token.value}' at line {token.location.line}, col {token.location.column}")

if __name__ == "__main__":
    test_underscore_lexer()

