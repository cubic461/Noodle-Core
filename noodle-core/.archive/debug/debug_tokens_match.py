#!/usr/bin/env python3
"""
Noodle Core::Debug Tokens Match - debug_tokens_match.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Debug tokens for match expression
"""

import sys
import os

# Add noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from simple_lexer import SimpleLexer, TokenType

# Test with match expression
test_code = """
match x {
    case 1 => "one";
    case 2 => "two";
    case _ => "other";
}
"""

print("Tokenizing match expression...")
lexer = SimpleLexer(test_code)
tokens = lexer.tokenize()

for token in tokens:
    print(f"{token.type.value}: '{token.value}' at {token.location}")

