#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_direct_parser.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Direct test of enhanced_parser without importing from other modules
"""

import sys
import os

# Add the noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'compiler'))

# Import directly from enhanced_parser
from enhanced_parser import EnhancedParser
from ast_nodes import SourceLocation

def test_simple():
    """Test simple code with colon"""
    print("Testing simple code with colon...")
    
    source = """
    let x: number = 10;
    """
    
    parser = EnhancedParser(source, "test")
    ast = parser.parse()
    
    print(f"Errors: {len(parser.errors)}")
    if parser.errors:
        for error in parser.errors:
            print(f"  - {error.message}")
    
    print("AST:")
    print(ast.to_dict())
    print()

if __name__ == "__main__":
    test_simple()

