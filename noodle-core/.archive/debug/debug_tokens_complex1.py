#!/usr/bin/env python3
"""
Noodle Core::Debug Tokens Complex1 - debug_tokens_complex1.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Debug script to see tokens for first complex feature test case.
"""

import sys
import os

# Add noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.compiler.enhanced_parser import SimpleLexer, TokenType

# Test 1: Generic class with async method using pattern matching
test_code = """class Container<T> {
    items: T[];
    
    async def find_first(predicate: (item: T) -> bool): T | null {
        for async item in self.items {
            match predicate(item) {
                case true => return item;
                case false => continue;
            }
        }
        return null;
    }
}"""

print("Testing tokens for: Generic class with async method using pattern matching")
print(f"Code: {test_code}")

# Create lexer and tokenize
lexer = SimpleLexer(test_code, "<test>")
tokens = lexer.tokenize()

print(f"\nTokens ({len(tokens)}):")
for i, token in enumerate(tokens):
    if i < 50:  # Show first 50 tokens
        print(f"  {i+1:2d}. {token.type.value:15s} '{token.value}' at {token.location}")
    elif i == 50:
        print(f"  ... and {len(tokens) - 50} more tokens")

# Check for errors
if lexer.errors:
    print(f"\nLexer errors: {len(lexer.errors)}")
    for error in lexer.errors:
        print(f"  - {error}")

# Find the problematic token around line 3, column 10
print("\nLooking for token around line 3, column 10:")
for i, token in enumerate(tokens):
    if token.location.line == 3 and abs(token.location.column - 10) < 5:
        print(f"  {i+1:2d}. {token.type.value:15s} '{token.value}' at {token.location}")

