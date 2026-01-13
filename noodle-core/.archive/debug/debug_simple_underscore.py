#!/usr/bin/env python3
"""
Noodle Core::Debug Simple Underscore - debug_simple_underscore.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple debug test for underscore pattern matching
"""

import sys
import os

# Add noodle-core directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

try:
    from noodlecore.compiler.enhanced_parser import EnhancedParser
    from simple_lexer import SimpleLexer, TokenType
except ImportError as e:
    print(f"Import error: {e}")
    sys.exit(1)

def test_simple_underscore():
    """Test simple underscore pattern matching"""
    
    # Test case 2: Multiple patterns with underscore
    code = """match x {
    1 => "one",
    _ => "default"
}"""
    
    print("=== Test Case 2 ===")
    print(f"Code: {code}")
    
    # Test lexer first
    lexer = SimpleLexer(code, "test2.nc")
    tokens = lexer.tokenize()
    
    print("\n=== Tokens ===")
    for i, token in enumerate(tokens):
        print(f"{i}: {token.type.value} = '{token.value}' at {token.location}")
    
    # Check if underscore token is present
    underscore_tokens = [t for t in tokens if t.type == TokenType.UNDERSCORE]
    print(f"\nFound {len(underscore_tokens)} underscore tokens in lexer")
    
    # Test parser
    parser = EnhancedParser(code, "test2.nc")
    
    try:
        ast = parser.parse()
        
        if parser.errors:
            print(f"\nâœ— Parse errors ({len(parser.errors)}):")
            for error in parser.errors:
                print(f"  - {error}")
        else:
            print("\nâœ“ Parse successful!")
            
            # Check AST for wildcard patterns
            wildcard_count = count_wildcard_patterns(ast)
            print(f"Found {wildcard_count} wildcard patterns in AST")
            
    except Exception as e:
        print(f"\nâœ— Parse failed with exception: {e}")

def count_wildcard_patterns(node):
    """Recursively count wildcard patterns in AST"""
    if hasattr(node, 'to_dict'):
        node_dict = node.to_dict()
        if node_dict.get('type') == 'wildcard_pattern':
            return 1
        elif node_dict.get('type') == 'match_expression':
            count = 0
            for case in node_dict.get('cases', []):
                count += count_wildcard_patterns(case.get('pattern'))
            return count
        elif node_dict.get('type') == 'match_case':
            return count_wildcard_patterns(node_dict.get('pattern'))
        else:
            # For other node types, check all child nodes
            count = 0
            for key, value in node_dict.items():
                if isinstance(value, dict):
                    count += count_wildcard_patterns(value)
                elif isinstance(value, list):
                    for item in value:
                        if isinstance(item, dict):
                            count += count_wildcard_patterns(item)
            return count
    else:
        # For non-AST nodes or nodes without to_dict method
        return 0

if __name__ == "__main__":
    test_simple_underscore()

