#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_comprehensive_underscore.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Comprehensive test for underscore pattern matching fix
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

def test_comprehensive_underscore():
    """Test various underscore pattern matching scenarios"""
    
    test_cases = [
        # Test 1: Simple underscore pattern
        """
        match x {
            _ => "default"
        }
        """,
        
        # Test 2: Multiple patterns with underscore
        """
        match x {
            1 => "one",
            _ => "default"
        }
        """,
        
        # Test 3: Underscore in tuple pattern
        """
        match x {
            (_, y) => "tuple"
        }
        """,
        
        # Test 4: Underscore in array pattern
        """
        match x {
            [_, _] => "array"
        }
        """,
        
        # Test 5: Complex nested patterns with underscore
        """
        match x {
            Some(_, _) => "some",
            None => "none",
            _ => "default"
        }
        """,
        
        # Test 6: OR pattern with underscore
        """
        match x {
            _ | 0 => "zero_or_default"
        }
        """,
        
        # Test 7: AND pattern with underscore
        """
        match x {
            _ & true => "true_and_default"
        }
        """,
        
        # Test 8: Guard pattern with underscore
        """
        match x {
            _ if x > 0 => "positive_default"
        }
        """
    ]
    
    for i, code in enumerate(test_cases, 1):
        print(f"\n=== Test {i} ====")
        print(f"Code: {code.strip()}")
        
        # Test lexer first
        lexer = SimpleLexer(code, f"test{i}.nc")
        tokens = lexer.tokenize()
        
        # Check if underscore token is present
        underscore_tokens = [t for t in tokens if t.type == TokenType.UNDERSCORE]
        print(f"Found {len(underscore_tokens)} underscore tokens in lexer")
        
        # Test parser
        parser = EnhancedParser(code, f"test{i}.nc")
        
        try:
            ast = parser.parse()
            
            if parser.errors:
                print(f"âœ— Parse errors ({len(parser.errors)}):")
                for error in parser.errors:
                    print(f"  - {error}")
            else:
                print("âœ“ Parse successful!")
                
                # Check AST for wildcard patterns
                wildcard_count = count_wildcard_patterns(ast)
                print(f"Found {wildcard_count} wildcard patterns in AST")
                
        except Exception as e:
            print(f"âœ— Parse failed with exception: {e}")

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
    test_comprehensive_underscore()

