#!/usr/bin/env python3
"""
Test Suite::Noodle Core - debug_simple_test.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple debug script for the parser.
"""

import sys
import os

# Add noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.compiler.enhanced_parser import EnhancedParser

# Test 1: Simple generic class
test_code = """
class Container<T> {
    items: T[];
}
"""

print("Testing: Simple generic class")
print(f"Code: {test_code}")

# Create parser and tokenize first
parser = EnhancedParser(test_code)
print(f"Tokens: {len(parser.tokens)}")

# Print first 15 tokens
for i, token in enumerate(parser.tokens[:15]):
    print(f"  {i+1}. {token.type.value:15} '{token.value}' at {token.location}")

# Try to parse with detailed error tracking
try:
    ast = parser.parse()
    print("âœ“ Parsing successful!")
except Exception as e:
    print(f"âœ— Parsing failed: {str(e)}")
    import traceback
    traceback.print_exc()

