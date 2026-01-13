#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_match.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test match expression parsing
"""

import sys
import os

# Add noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.compiler.enhanced_parser import parse_source

# Test with match expression
test_code = """
match x {
    case 1 => "one";
    case 2 => "two";
    case _ => "other";
}
"""

print("Testing match expression...")
try:
    ast = parse_source(test_code)
    print("âœ“ Parsing successful!")
    if hasattr(ast, 'errors') and ast.errors:
        print(f"  Errors: {len(ast.errors)}")
        for error in ast.errors:
            print(f"    - {error}")
except Exception as e:
    print(f"âœ— Parsing failed: {str(e)}")

