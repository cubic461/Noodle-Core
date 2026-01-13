#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_underscore_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to verify the underscore token fix in match expressions.
"""

import sys
import os

# Add the noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'compiler'))

from enhanced_parser import EnhancedParser

def test_underscore_pattern():
    """Test underscore pattern in match expression"""
    
    # Test case 1: Simple underscore pattern
    code1 = """
    match x {
        _ => "wildcard",
        1 => "one",
        2 => "two"
    }
    """
    
    print("Test 1: Simple underscore pattern")
    print("Code:", code1.strip())
    
    try:
        parser1 = EnhancedParser(code1)
        ast1 = parser1.parse()
        
        if parser1.errors:
            print("Errors:", parser1.errors)
        else:
            print("âœ“ Parsed successfully")
            print("AST:", ast1.to_dict())
    except Exception as e:
        print(f"âœ— Failed with exception: {e}")
    
    print()
    
    # Test case 2: Multiple underscore patterns
    code2 = """
    match x {
        _ => "first",
        _ => "second",
        1 => "one"
    }
    """
    
    print("Test 2: Multiple underscore patterns")
    print("Code:", code2.strip())
    
    try:
        parser2 = EnhancedParser(code2)
        ast2 = parser2.parse()
        
        if parser2.errors:
            print("Errors:", parser2.errors)
        else:
            print("âœ“ Parsed successfully")
            print("AST:", ast2.to_dict())
    except Exception as e:
        print(f"âœ— Failed with exception: {e}")
    
    print()
    
    # Test case 3: Mixed patterns with commas
    code3 = """
    match x {
        _ => "wildcard",
        1 => "one",
        _ => "another wildcard",
        2 => "two"
    }
    """
    
    print("Test 3: Mixed patterns with commas")
    print("Code:", code3.strip())
    
    try:
        parser3 = EnhancedParser(code3)
        ast3 = parser3.parse()
        
        if parser3.errors:
            print("Errors:", parser3.errors)
        else:
            print("âœ“ Parsed successfully")
            print("AST:", ast3.to_dict())
    except Exception as e:
        print(f"âœ— Failed with exception: {e}")

if __name__ == "__main__":
    test_underscore_pattern()

