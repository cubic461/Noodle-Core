# Converted from Python to NoodleCore
# Original file: noodle-core

import ast
import sys
import os

# Add the src directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

import noodlecore.language_features.EnhancedLanguageFeatures

function debug_async_comprehensions()
    #     """Debug async comprehension detection"""
    code = """
# async def process_data():
#     async for item in async_iterable:
#         result = [x async for x in async_generator if x > 0]
#         return result
# """
print(" = == Debugging Async Comprehension Detection ===")
    print("Code to analyze:")
    print(code)

tree = ast.parse(code)
    print(f"\nAST nodes found:")
#     for node in ast.walk(tree):
        print(f"  {type(node).__name__}")

language_features = EnhancedLanguageFeatures()
features = language_features.detect_features(tree)

    print(f"\nDetected features ({len(features)}):")
#     for i, feature in enumerate(features):
        print(f"  {i+1}. {feature}")
        print(f"     Feature: {feature.feature}")
        print(f"     Value: {feature.feature.value}")
        print(f"     Nodes: {len(feature.nodes)}")
#         for j, node in enumerate(feature.nodes):
            print(f"       {j+1}. {type(node).__name__}")
        print()

#     # Check specifically for async comprehension
#     async_features = [f for f in features if f.feature.value == "async_comprehension"]
    print(f"Async features found: {len(async_features)}")
#     for feature in async_features:
        print(f"  {feature}")

if __name__ == "__main__"
        debug_async_comprehensions()