#!/usr/bin/env python3
"""
Noodle Core::Debug Step By Step - debug_step_by_step.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Step-by-step debug script for underscore token handling in match expressions.
"""

import sys
import os

# Add noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'compiler'))

from enhanced_parser import EnhancedParser

def debug_step_by_step():
    """Debug underscore pattern step by step"""
    
    # Test case: Simple underscore pattern
    test_code = 'match x { _ => "wildcard", 1 => "one" }'
    
    print("Testing step by step...")
    print("Code:", repr(test_code))
    
    # Create parser
    parser = EnhancedParser(test_code, "<test>")
    
    # Step 1: Check initial position
    print(f"\nStep 1: Initial position = {parser.position}")
    print(f"Current token: {parser._current_token().type.value} = {repr(parser._current_token().value)}")
    
    # Step 2: Parse match expression
    print("\nStep 2: Parsing match expression...")
    match_expr = parser._parse_match_expression()
    if match_expr:
        print(f"Match expression parsed successfully")
    else:
        print(f"Match expression parsing failed")
    
    # Step 3: Check position after parsing match expression
    print(f"\nStep 3: Position after parsing match expression = {parser.position}")
    print(f"Current token: {parser._current_token().type.value} = {repr(parser._current_token().value)}")
    
    # Step 4: Check errors
    print("\nStep 4: Checking errors...")
    if parser.errors:
        print("Parser errors:")
        for error in parser.errors:
            print(f"  - {error}")
    else:
        print("No parser errors")

if __name__ == "__main__":
    debug_step_by_step()

