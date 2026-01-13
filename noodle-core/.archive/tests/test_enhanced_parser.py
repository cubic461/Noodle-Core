#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_enhanced_parser.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script for the enhanced Noodle parser
"""

import sys
import os
from pathlib import Path

# Add the noodle-core path to sys.path
sys.path.insert(0, str(Path(__file__).parent.parent))

from src.noodlecore.compiler.enhanced_parser import parse_source

def test_basic_parsing():
    """Test basic parsing functionality"""
    print("Testing basic parsing...")
    
    # Test simple program
    test_code = """
let x: int = 42;
let y = "hello";
let z = true;
let result = x + y;

def add(a: int, b: int) -> int {
    return a + b;
}

print(result);
"""
    
    try:
        # Write test code to temporary file
        test_file = "test_basic.nc"
        with open(test_file, 'w') as f:
            f.write(test_code)
        
        # Parse the file
        ast = parse_source(test_code, test_file)
        
        print(f"Successfully parsed {len(ast.statements)} statements")
        print(f"AST: {ast.to_dict()}")
        
        # Clean up
        os.remove(test_file)
        return True
    except Exception as e:
        print(f"Error in basic parsing: {e}")
        return False

def test_pattern_matching():
    """Test pattern matching parsing"""
    print("\nTesting pattern matching...")
    
    test_code = """
match value {
    case 42:
        print("Number 42");
    case "hello":
        print("String hello");
    case _:
        print("Default case");
}
"""
    
    try:
        # Write test code to temporary file
        test_file = "test_pattern.nc"
        with open(test_file, 'w') as f:
            f.write(test_code)
        
        # Parse the file
        ast = parse_source(test_code, test_file)
        
        print(f"Successfully parsed pattern matching")
        print(f"AST: {ast.to_dict()}")
        
        # Clean up
        os.remove(test_file)
        return True
    except Exception as e:
        print(f"Error in pattern matching parsing: {e}")
        return False

def test_generics():
    """Test generics parsing"""
    print("\nTesting generics...")
    
    test_code = """
def generic_function<T>(value: T) -> T {
    return value;
}

let result: str = generic_function("hello");
"""
    
    try:
        # Write test code to temporary file
        test_file = "test_generics.nc"
        with open(test_file, 'w') as f:
            f.write(test_code)
        
        # Parse the file
        ast = parse_source(test_code, test_file)
        
        print(f"Successfully parsed generics")
        print(f"AST: {ast.to_dict()}")
        
        # Clean up
        os.remove(test_file)
        return True
    except Exception as e:
        print(f"Error in generics parsing: {e}")
        return False

def test_async_await():
    """Test async/await parsing"""
    print("\nTesting async/await...")
    
    test_code = """
async def fetch_data() -> str {
    await some_async_operation();
    return "data";
}

async def main() {
    let result = await fetch_data();
    print(result);
}
"""
    
    try:
        # Write test code to temporary file
        test_file = "test_async.nc"
        with open(test_file, 'w') as f:
            f.write(test_code)
        
        # Parse the file
        ast = parse_source(test_code, test_file)
        
        print(f"Successfully parsed async/await")
        print(f"AST: {ast.to_dict()}")
        
        # Clean up
        os.remove(test_file)
        return True
    except Exception as e:
        print(f"Error in async/await parsing: {e}")
        return False

def main():
    """Run all tests"""
    print("Testing Enhanced Noodle Parser")
    print("=" * 50)
    
    tests = [
        test_basic_parsing,
        test_pattern_matching,
        test_generics,
        test_async_await
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        if test():
            passed += 1
        else:
            print(f"Test failed!")
    
    print("=" * 50)
    print(f"Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("All tests passed! Enhanced parser is working correctly.")
        return 0
    else:
        print("Some tests failed. Please check the implementation.")
        return 1

if __name__ == '__main__':
    sys.exit(main())

