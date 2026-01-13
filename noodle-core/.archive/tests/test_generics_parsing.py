#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_generics_parsing.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script for generics parsing in enhanced_parser.py
"""

import sys
import os
import json

# Add the noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'compiler'))

# Import directly from the modules
from enhanced_parser import EnhancedParser
from ast_nodes import SourceLocation
from simple_lexer import SimpleLexer, TokenType, Token

def test_generic_parameters():
    """Test parsing generic parameters"""
    print("Testing generic parameters...")
    
    source = """
    def identity<T: Comparable>(value: T): T {
        return value;
    }
    """
    
    parser = EnhancedParser(source, "test")
    ast = parser.parse()
    
    print(f"Errors: {len(parser.errors)}")
    if parser.errors:
        for error in parser.errors:
            print(f"  - {error.message}")
    
    print("AST:")
    print(json.dumps(ast.to_dict(), indent=2))
    print()

def test_generic_type():
    """Test parsing generic types"""
    print("Testing generic types...")
    
    source = """
    let container: Container<String, Integer> = Container<String, Integer>();
    """
    
    parser = EnhancedParser(source, "test")
    ast = parser.parse()
    
    print(f"Errors: {len(parser.errors)}")
    if parser.errors:
        for error in parser.errors:
            print(f"  - {error.message}")
    
    print("AST:")
    print(json.dumps(ast.to_dict(), indent=2))
    print()

def test_type_alias():
    """Test parsing type aliases"""
    print("Testing type aliases...")
    
    source = """
    type StringOrNumber = String | Number;
    type Optional<T> = T | None;
    type KeyValuePair<K, V> = { key: K, value: V };
    """
    
    parser = EnhancedParser(source, "test")
    ast = parser.parse()
    
    print(f"Errors: {len(parser.errors)}")
    if parser.errors:
        for error in parser.errors:
            print(f"  - {error.message}")
    
    print("AST:")
    print(json.dumps(ast.to_dict(), indent=2))
    print()

def test_union_intersection_types():
    """Test parsing union and intersection types"""
    print("Testing union and intersection types...")
    
    source = """
    let value: String | Number | Boolean = "hello";
    let merged: Comparable & Serializable = obj;
    """
    
    parser = EnhancedParser(source, "test")
    ast = parser.parse()
    
    print(f"Errors: {len(parser.errors)}")
    if parser.errors:
        for error in parser.errors:
            print(f"  - {error.message}")
    
    print("AST:")
    print(json.dumps(ast.to_dict(), indent=2))
    print()

def test_function_type():
    """Test parsing function types"""
    print("Testing function types...")
    
    source = """
    let callback: (String, Number) -> Boolean = func(s, n) { return true; };
    """
    
    parser = EnhancedParser(source, "test")
    ast = parser.parse()
    
    print(f"Errors: {len(parser.errors)}")
    if parser.errors:
        for error in parser.errors:
            print(f"  - {error.message}")
    
    print("AST:")
    print(json.dumps(ast.to_dict(), indent=2))
    print()

def test_tuple_array_types():
    """Test parsing tuple and array types"""
    print("Testing tuple and array types...")
    
    source = """
    let tuple: [String, Number, Boolean] = ["hello", 42, true];
    let array: [String] = ["a", "b", "c"];
    """
    
    parser = EnhancedParser(source, "test")
    ast = parser.parse()
    
    print(f"Errors: {len(parser.errors)}")
    if parser.errors:
        for error in parser.errors:
            print(f"  - {error.message}")
    
    print("AST:")
    print(json.dumps(ast.to_dict(), indent=2))
    print()

def test_computed_type():
    """Test parsing computed types"""
    print("Testing computed types...")
    
    source = """
    let computed: {typeof(obj)} = value;
    """
    
    parser = EnhancedParser(source, "test")
    ast = parser.parse()
    
    print(f"Errors: {len(parser.errors)}")
    if parser.errors:
        for error in parser.errors:
            print(f"  - {error.message}")
    
    print("AST:")
    print(json.dumps(ast.to_dict(), indent=2))
    print()

if __name__ == "__main__":
    print("Running generics parsing tests...\n")
    
    test_generic_parameters()
    test_generic_type()
    test_type_alias()
    test_union_intersection_types()
    test_function_type()
    test_tuple_array_types()
    test_computed_type()
    
    print("All tests completed.")

