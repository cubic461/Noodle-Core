#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_pattern_matching.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script for pattern matching parsing functionality
"""

import sys
import os

# Add the noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.compiler.enhanced_parser import EnhancedParser

def test_basic_patterns():
    """Test basic pattern matching functionality"""
    test_code = """
    let x = 42;
    
    match x {
        case 1:
            return "one";
        case 2:
            return "two";
        case 3 | 4:
            return "three or four";
        case 5..10:
            return "five to ten";
        case _:
            return "wildcard";
        case n if n > 10:
            return "greater than ten";
        default:
            return "default";
    }
    """
    
    try:
        parser = EnhancedParser(test_code, "test_pattern_matching")
        ast = parser.parse()
        
        print("Parse successful!")
        print(f"Number of statements: {len(ast.statements)}")
        print(f"Number of errors: {len(parser.errors)}")
        
        if parser.errors:
            print("Errors:")
            for error in parser.errors:
                print(f"  - {error.message}")
        else:
            print("AST:")
            print(ast.to_dict())
        
        return True
    except Exception as e:
        print(f"Error: {str(e)}")
        return False

def test_complex_patterns():
    """Test more complex pattern matching with tuples, arrays, and objects"""
    test_code = """
    let point = { x: 10, y: 20 };
    let numbers = [1, 2, 3, 4, 5];
    let person = { name: "Alice", age: 30 };
    
    match point {
        case { x: 1, y: 2 }:
            return "point (1, 2)";
        case { x, y }:
            return f"point ({x}, {y})";
        case { x: px, y: py }:
            return "pattern with variables";
    }
    
    match numbers {
        case [1, 2, 3]:
            return "first three";
        case [1, 2, 3, 4]:
            return "first four";
        case [1, 2, 3, 4, 5]:
            return "first five";
        case []:
            return "empty list";
    }
    
    match person {
        case { name: "Alice", age }:
            return f"Alice is {age} years old";
        case { name, age: 30 }:
            return f"30-year-old {name}";
        case { name: "Bob", age: 25 }:
            return f"25-year-old Bob";
    }
    """
    
    try:
        parser = EnhancedParser(test_code, "test_pattern_matching")
        ast = parser.parse()
        
        print("Parse successful!")
        print(f"Number of statements: {len(ast.statements)}")
        print(f"Number of errors: {len(parser.errors)}")
        
        if parser.errors:
            print("Errors:")
            for error in parser.errors:
                print(f"  - {error.message}")
        else:
            print("AST:")
            print(ast.to_dict())
        
        return True
    except Exception as e:
        print(f"Error: {str(e)}")
        return False

if __name__ == "__main__":
    print("Testing basic pattern matching...")
    test_basic_patterns()
    
    print("\nTesting complex pattern matching...")
    test_complex_patterns()

