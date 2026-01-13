# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Test script for the NoodleCore parser with C-like syntax
# This script tests the parser's ability to handle the new syntax as specified in NoodleCore_Language_Specification.md
# """

import sys
import os

# Add the src directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

import noodlecore.compiler.lexer_main.Lexer
import noodlecore.compiler.parser.Parser

function test_parser_with_simple_code()
    #     """Test the parser with simple NoodleCore code snippets"""

    #     # Test 1: Variable declarations with type annotations
    test_code1 = """
    name: string = "NoodleCore"
    age: int = 25
    pi: float = 3.14159
    is_active: bool = true
    #     """

    #     # Test 2: If-elif-else statements with curly braces
    test_code2 = """
    #     if age 18 {
            print("Adult")
    #     } elif age > 12 {
            print("Teenager")
    #     } else {
            print("Child")
    #     }
    #     """

    #     # Test 3): For loop with range
    test_code3 = """
    #     for i in 0..10 {
            print(i)
    #     }
    #     """

    #     # Test 4: While loop with curly braces
    test_code4 = """
    #     while condition {
    #         # loop body
    #     }
    #     """

    #     # Test 5: Function definition with type annotations
    test_code5 = """
        func add(a: int, b: int) -int {
    #         return a + b
    #     }

        func greet(name): string) {
            print("Hello, " + name)
    #     }
    #     """

    #     # Test 6: Try-catch with curly braces
    test_code6 = """
    #     try {
    result = risky_operation()
        } catch (error) {
            print("Error occurred: " + error.message)
    #     }
    #     """

    #     # Test 7: Array and map declarations
    test_code7 = """
    numbers: array[int] = [1, 2, 3, 4, 5]
    names: array[string] = ["Alice", "Bob", "Charlie"]

    scores: map[string, int] = {
    #         "Alice": 95,
    #         "Bob": 87,
    #         "Charlie": 92
    #     }
    #     """

    #     # Run tests
    test_cases = [
            ("Variable declarations", test_code1),
            ("If-elif-else statements", test_code2),
    #         ("For loop with range", test_code3),
            ("While loop", test_code4),
            ("Function definitions", test_code5),
            ("Try-catch statements", test_code6),
            ("Array and map declarations", test_code7)
    #     ]

    #     for test_name, code in test_cases:
    print(f"\n = == Testing {test_name} ===")
            print(f"Code:\n{code}")

    #         try:
    #             # Create lexer and parser
    lexer = Lexer(code, f"<test_{test_name.lower().replace(' ', '_')}>")
    parser = Parser(lexer)

    #             # Parse the code
    ast = parser.parse()

    #             # Check for errors
    errors = parser.get_errors()
    #             if errors:
                    print(f"Parser errors: {errors}")
    #             else:
                    print("✓ Parsing successful!")

                    # Print AST structure (simplified)
                    print(f"AST: {ast}")
    #                 print(f"Number of statements: {len(ast.children) if hasattr(ast, 'children') else 0}")

    #         except Exception as e:
                print(f"✗ Error during parsing: {e}")
    #             import traceback
                traceback.print_exc()

if __name__ == "__main__"
    #     print("Testing NoodleCore parser with C-like syntax...")
        test_parser_with_simple_code()
        print("\nTesting complete.")