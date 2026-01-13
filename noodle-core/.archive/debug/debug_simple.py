#!/usr/bin/env python3
"""
Noodle Core::Debug Simple - debug_simple.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Debug script for simple parsing test.
"""

import sys
import os

# Add noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.compiler.enhanced_parser import parse_source

# Simple test case
test_code = """
let x: number = 42;
"""

print("Testing simple let statement...")
print(f"Code: {test_code}")

try:
    ast = parse_source(test_code)
    print("âœ“ Parsing successful!")
    
    # Print some basic info about AST
    if hasattr(ast, 'statements'):
        print(f"  Parsed {len(ast.statements)} statements")
        for i, stmt in enumerate(ast.statements):
            stmt_type = getattr(stmt, 'type', 'unknown')
            print(f"    {i+1}. {stmt_type}")
    
    # Check for errors
    if hasattr(ast, 'errors') and ast.errors:
        print(f"  Errors: {len(ast.errors)}")
        for error in ast.errors:
            print(f"    - {error}")
except Exception as e:
    print(f"âœ— Parsing failed: {str(e)}")
    import traceback
    traceback.print_exc()

