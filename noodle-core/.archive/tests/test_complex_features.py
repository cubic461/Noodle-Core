#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_complex_features.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script for complex language features integration in the enhanced parser.

This script tests the parser with complex code examples that use multiple
new language features together (pattern matching, generics, and async/await).
"""

import sys
import os
import json

# Add the noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.compiler.enhanced_parser import parse_source

def test_complex_features():
    """Test parser with complex code using multiple new features"""
    
    # Test 1: Generic class with async method using pattern matching
    test_code_1 = """
    generic class Container<T> {
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
    
    # Test 2: Async function with generic parameters and await expressions
    test_code_2 = """
    async def map_async<T, R>(
        items: T[], 
        transform: (item: T) -> R
    ): R[] {
        let result: R[] = [];
        for item in items {
            let mapped = await transform(item);
            result.append(mapped);
        }
        return result;
    }
    """
    
    # Test 3: Pattern matching with generic types
    test_code_3 = """
    def process_option<T>(option: T | null): string {
        match option {
            case null => "None";
            case value: T => format_value(value);
        }
    }
    
    def format_value<T>(value: T): string {
        match value {
            case s: string => s;
            case n: number => n.toString();
            case b: boolean => b ? "true" : "false";
            case _ => "unknown";
        }
    }
    """
    
    # Test 4: Async with statement and yield expression
    test_code_4 = """
    async def process_stream<T>(stream: AsyncStream<T>): T[] {
        let results: T[] = [];
        
        async with resource_manager.acquire(stream) {
            try {
                while await stream.has_next() {
                    let item = await stream.next();
                    yield process_item(item);
                }
            } catch (e: Error) {
                log_error(e);
            }
        }
        
        return results;
    }
    """
    
    # Test 5: Complex generic class with inheritance
    test_code_5 = """
    class Result<T, E> extends ErrorContainer<E> {
        value: T;
        
        def __init__(value: T): void {
            self.value = value;
        }
        
        def map<R>(transform: (value: T) -> R): Result<R, E> {
            match self.is_error() {
                case true => ErrorResult<R, E>(self.error);
                case false => SuccessResult<R, E>(transform(self.value));
            }
        }
    }
    """
    
    test_cases = [
        ("Generic class with async method using pattern matching", test_code_1),
        ("Async function with generic parameters and await expressions", test_code_2),
        ("Pattern matching with generic types", test_code_3),
        ("Async with statement and yield expression", test_code_4),
        ("Complex generic class with inheritance", test_code_5)
    ]
    
    for name, code in test_cases:
        print(f"\nTesting: {name}")
        print("=" * 50)
        try:
            ast = parse_source(code)
            print("âœ“ Parsing successful!")
            
            # Print some basic info about the AST
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
        except Exception as e:
            print(f"âœ— Parsing failed: {str(e)}")
        
        print("=" * 50)

if __name__ == "__main__":
    test_complex_features()

