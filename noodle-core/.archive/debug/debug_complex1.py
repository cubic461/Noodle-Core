#!/usr/bin/env python3
"""
Noodle Core::Debug Complex1 - debug_complex1.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Debug script for first complex feature test case.
"""

import sys
import os

# Add noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.compiler.enhanced_parser import parse_source

# Test 1: Generic class with async method using pattern matching
test_code = """
class Container<T> {
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

try:
    ast = parse_source(test_code)
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
    if hasattr(ast, 'errors') and ast.errors:
        print(f"  Errors: {len(ast.errors)}")
        for error in ast.errors[:3]:  # Show first 3 errors
            print(f"    - {error}")
    
    # Debug: Print parser errors directly
    if hasattr(ast, 'errors') and ast.errors:
        print(f"  Parser errors: {len(ast.errors)}")
        for error in ast.errors:
            print(f"    - {error}")
except Exception as e:
    print(f"âœ— Parsing failed: {str(e)}")
    import traceback
    traceback.print_exc()

