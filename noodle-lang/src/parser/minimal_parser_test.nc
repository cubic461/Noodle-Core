# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Minimal test script for the NoodleCore parser with C-like syntax
# This script directly imports the required modules without going through the package hierarchy
# """

import sys
import os

# Add the src directory to the path
src_path = os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'compiler')
sys.path.insert(0, src_path)

# Direct imports to avoid dependency issues
import lexer_main.Lexer
import parser.Parser

function test_simple_code()
    #     """Test the parser with a simple NoodleCore code snippet"""

    #     # Simple test with variable declaration and if statement
    test_code = """
    name: string = "NoodleCore"
    age: int = 25

    #     if age 18 {
            print("Adult")
    #     } else {
            print("Child")
    #     }
    #     """

    #     print("Testing NoodleCore parser with simple code...")
        print(f"Code):\n{test_code}")

    #     try:
    #         # Create lexer and parser
    lexer = Lexer(test_code, "<test>")
    parser = Parser(lexer)

    #         # Parse the code
    ast = parser.parse()

    #         # Check for errors
    errors = parser.get_errors()
    #         if errors:
                print(f"Parser errors: {errors}")
    #         else:
                print("✓ Parsing successful!")

                # Print AST structure (simplified)
                print(f"AST: {ast}")
    #             print(f"Number of statements: {len(ast.children) if hasattr(ast, 'children') else 0}")

    #             # Print individual statements
    #             if hasattr(ast, 'children'):
    #                 for i, stmt in enumerate(ast.children):
                        print(f"  Statement {i+1}: {type(stmt).__name__}")
    #                     if hasattr(stmt, 'name'):
                            print(f"    Name: {stmt.name}")
    #                     if hasattr(stmt, 'condition'):
                            print(f"    Condition: {stmt.condition}")
    #                     if hasattr(stmt, 'then_branch'):
                            print(f"    Then branch: {type(stmt.then_branch).__name__}")
    #                     if hasattr(stmt, 'else_branch') and stmt.else_branch:
                            print(f"    Else branch: {type(stmt.else_branch).__name__}")

    #     except Exception as e:
            print(f"✗ Error during parsing: {e}")
    #         import traceback
            traceback.print_exc()

if __name__ == "__main__"
        test_simple_code()