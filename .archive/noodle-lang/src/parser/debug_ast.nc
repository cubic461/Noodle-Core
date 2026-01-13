# Converted from Python to NoodleCore
# Original file: src

import ast
import sys
import os

function debug_ast_structure()
    #     """Debug the exact AST structure for async comprehensions"""
    code = """
# async def process_data():
#     async for item in async_iterable:
#         result = [x async for x in async_generator if x 0]
#         return result
# """
print(" = == Debugging AST Structure ===")
    print("Code to analyze):")
    print(code)

tree = ast.parse(code)
    print(f"\nFull AST dump:")
print(ast.dump(tree, indent = 2))

#     print("\n=== Looking for async comprehensions specifically ===")
#     for node in ast.walk(tree):
        print(f"Node type: {type(node).__name__}")
#         if hasattr(node, 'lineno'):
            print(f"  Line: {node.lineno}")
#         if hasattr(node, 'async_') and node.async_:
            print(f"  ASYNC: {node.async_}")
#         if isinstance(node, ast.comprehension):
            print(f"  comprehension - async: {getattr(node, 'async_', False)}")
#         if isinstance(node, ast.AsyncFor):
            print(f"  AsyncFor target: {ast.dump(node.target)}")
            print(f"  AsyncFor iter: {ast.dump(node.iter)}")
        print()

if __name__ == "__main__"
        debug_ast_structure()