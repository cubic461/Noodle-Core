#!/usr/bin/env python3
"""
Noodle Core::Debug Detailed - debug_detailed.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Detailed debug script for the parser.
"""

import sys
import os

# Add noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.compiler.enhanced_parser import EnhancedParser

# Test 1: Generic class with async method using pattern matching
test_code = """
generic class Container<T> {
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
}
"""

print("Testing: Generic class with async method using pattern matching")
print(f"Code: {test_code}")

# Create parser and tokenize first
parser = EnhancedParser(test_code)
print(f"Tokens: {len(parser.tokens)}")

# Print first 20 tokens
for i, token in enumerate(parser.tokens[:20]):
    print(f"  {i+1}. {token.type.value:15} '{token.value}' at {token.location}")

# Try to parse with detailed error tracking
try:
    ast = parser.parse()
    print("âœ“ Parsing successful!")
    
    # Print some basic info about AST
    if hasattr(ast, 'statements'):
        print(f"  Parsed {len(ast.statements)} statements")
        for i, stmt in enumerate(ast.statements[:3]):  # Show first 3 statements
            stmt_type = getattr(stmt, 'type', 'unknown')
            print(f"    {i+1}. {stmt_type}")
        if len(ast.statements) > 3:
            print(f"    ... and {len(ast.statements) - 3} more statements")
    
    # Check for errors
    if hasattr(parser, 'errors') and parser.errors:
        print(f"  Errors: {len(parser.errors)}")
        for error in parser.errors[:3]:  # Show first 3 errors
            print(f"    - {error}")
except Exception as e:
    print(f"âœ— Parsing failed: {str(e)}")
    import traceback
    traceback.print_exc()

