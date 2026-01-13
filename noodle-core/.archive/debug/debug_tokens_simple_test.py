#!/usr/bin/env python3
"""
Test Suite::Noodle Core - debug_tokens_simple_test.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Token debug script for the simple test case.
"""

import sys
import os

# Add noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.compiler.enhanced_parser import EnhancedParser

# Test 1: Simple generic class
test_code = """
generic class Container<T> {
    items: T[];
}
"""

print("Testing tokens for: Simple generic class")
print(f"Code: {test_code}")

# Create parser and tokenize
parser = EnhancedParser(test_code)
print(f"Tokens: {len(parser.tokens)}")

# Print all tokens
for i, token in enumerate(parser.tokens):
    print(f"  {i+1}. {token.type.value:15} '{token.value}' at {token.location}")

