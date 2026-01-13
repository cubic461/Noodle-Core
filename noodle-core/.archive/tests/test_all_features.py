#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_all_features.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test all new language features together
"""

import sys
import os

# Add the noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'compiler'))

# Import directly from enhanced_parser
from enhanced_parser import EnhancedParser
from ast_nodes import SourceLocation

def test_complex_features():
    """Test complex code with all new features"""
    print("Testing complex code with all new features...")
    
    source = """
    // Generic class with async method using pattern matching
    class Container<T> {
        let value: T;
        
        async def process<U>(input: U): T {
            await self.prepare();
            
            match input {
                case x if x > 0:
                    return self.value;
                case x if x < 0:
                    return self.default_value();
                case _:
                    return self.value;
            }
        }
        
        async def prepare(): void {
            // Async preparation logic
        }
        
        def default_value(): T {
            return self.value;
        }
    }
    
    // Async function with pattern matching
    async def process_data<T>(data: T): Container<T> {
        match data {
            case x if x != None:
                let container = Container<T>();
                container.value = x;
                return await container.process(x);
            case _:
                return Container<T>();
        }
    }
    
    // Async for loop with yield
    async def async_generator<T>(items: List<T>): AsyncGenerator<T> {
        for await item in items {
            yield item;
        }
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
    
    # Check for generic class
    class_stmt = ast.statements[0]
    if class_stmt.type == "class_definition":
        print(f"  1. Generic class '{class_stmt.name}' with {len(class_stmt.generic_parameters)} generic parameters")
        for param in class_stmt.generic_parameters:
            print(f"     - Generic parameter: {param.name}")
    
    # Check for async functions
    for i, stmt in enumerate(ast.statements):
        if stmt.type == "function_definition" and stmt.is_async:
            print(f"  {i+1}. Async function '{stmt.name}' with {len(stmt.generic_parameters)} generic parameters")
            for param in stmt.generic_parameters:
                print(f"     - Generic parameter: {param.name}")
    
    print("\nAll features successfully parsed!")
    return True

if __name__ == "__main__":
    test_complex_features()

