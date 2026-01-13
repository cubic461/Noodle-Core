#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_pattern_matching_implementation.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script for pattern matching parsing implementation
"""

import sys
import os

# Add the noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'noodlecore'))

from src.noodlecore.compiler.enhanced_parser import EnhancedParser

def test_pattern_matching():
    """Test pattern matching parsing"""
    
    # Test cases for different pattern types
    test_cases = [
        # Match expression with wildcard pattern
        """
        match x {
            case _:
                return 0;
        }
        """,
        
        # Match expression with literal patterns
        """
        match x {
            case 1:
                return "one";
            case "hello":
                return "greeting";
            case true:
                return "boolean";
        }
        """,
        
        # Match expression with identifier pattern
        """
        match x {
            case y:
                return y;
        }
        """,
        
        # Match expression with tuple pattern
        """
        match x {
            case (a, b):
                return a + b;
        }
        """,
        
        # Match expression with array pattern
        """
        match x {
            case [a, b, c]:
                return a + b + c;
        }
        """,
        
        # Match expression with object pattern
        """
        match x {
            case {name: n, age: a}:
                return n + " is " + a;
        }
        """,
        
        # Match expression with OR pattern
        """
        match x {
            case 1 | 2 | 3:
                return "small";
        }
        """,
        
        # Match expression with AND pattern
        """
        match x {
            case y & z:
                return y + z;
        }
        """,
        
        # Match expression with guard pattern
        """
        match x {
            case y if y > 0:
                return "positive";
        }
        """,
        
        # Match expression with range pattern
        """
        match x {
            case 1..10:
                return "in range";
        }
        """,
        
        # Match expression with default case
        """
        match x {
            case 1:
                return "one";
            default:
                return "other";
        }
        """
    ]
    
    for i, test_case in enumerate(test_cases):
        print(f"\n--- Test Case {i+1} ---")
        print(f"Source code:\n{test_case}")
        
        try:
            parser = EnhancedParser(test_case, f"test_case_{i+1}.noodle")
            ast = parser.parse()
            
            if parser.errors:
                print("Parse errors:")
                for error in parser.errors:
                    print(f"  - {error}")
            
            if parser.warnings:
                print("Parse warnings:")
                for warning in parser.warnings:
                    print(f"  - {warning}")
            
            if ast and not parser.errors:
                print("Parse successful!")
                print(f"AST: {ast.to_dict()}")
            else:
                print("Parse failed!")
        
        except Exception as e:
            print(f"Exception during parsing: {e}")
            import traceback
            traceback.print_exc()

if __name__ == "__main__":
    test_pattern_matching()

