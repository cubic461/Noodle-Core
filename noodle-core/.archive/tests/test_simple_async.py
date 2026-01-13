#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_simple_async.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test simple async function
"""

import sys
import os

# Add the noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'compiler'))

# Import directly from enhanced_parser
from enhanced_parser import EnhancedParser
from ast_nodes import SourceLocation

def test_simple_async():
    """Test simple async function"""
    print("Testing simple async function...")
    
    source = """
    async def test(): void {
        return;
    }
    """
    
    parser = EnhancedParser(source, "test")
    ast = parser.parse()
    
    print(f"Errors: {len(parser.errors)}")
    if parser.errors:
        for error in parser.errors:
            print(f"  - {error.message}")
    
    print("AST structure:")
    print(f"  Program with {len(ast.statements)} statements")
    
    if ast.statements:
        stmt = ast.statements[0]
        print(f"  1. {stmt.type} '{stmt.name}'")
        if hasattr(stmt, 'is_async'):
            print(f"     - Async: {stmt.is_async}")
    
    return True

if __name__ == "__main__":
    test_simple_async()

