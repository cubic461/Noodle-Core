#!/usr/bin/env python3
"""
Test Suite::Noodle Lang - test_pattern_matching.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Pattern Matching Feature Test
============================

This test demonstrates the new pattern matching lexer extension
for Phase 2 of Noodle language development.
"""

import sys
import os

# Add paths
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'lexer'))

from lexer import Lexer, Token, TokenType
from pattern_matching_lexer import PatternMatchingLexer

def test_pattern_matching_tokens():
    """Test pattern matching token recognition"""
    print("=== Pattern Matching Token Test ===")
    
    test_code = """
match value {
    case pattern when condition => result
    case alternative => default_result
}
"""
    
    print("Input code:")
    print(test_code)
    
    # Test with extended lexer
    lexer = PatternMatchingLexer(test_code, "pattern_test.nc")
    tokens = lexer.tokenize()
    
    print(f"\nGenerated {len(tokens)} tokens:")
    for i, token in enumerate(tokens):
        token_type = token.type.value
        value_preview = token.value[:20] + "..." if len(token.value) > 20 else token.value
        print(f"  {i+1:2d}. Type: {token_type:15s}, Value: '{value_preview}', Line: {token.line:2d}, Col: {token.column:2d}")
    
    # Check for specific pattern matching tokens
    pattern_tokens = [t for t in tokens if t.type.value in ['MATCH', 'CASE', 'WHEN', 'ARROW']]
    
    print(f"\nPattern matching tokens found: {len(pattern_tokens)}")
    for token in pattern_tokens:
        print(f"  - {token.type.value}: '{token.value}' at line {token.line}")
    
    # Verify expected tokens
    expected_patterns = {
        'MATCH': 1,  # match keyword
        'CASE': 1,   # case keyword  
        'WHEN': 1,   # when keyword
        'ARROW': 2,   # => operators (2 in test code)
    }
    
    success = True
    for pattern_type, expected_count in expected_patterns.items():
        actual_count = sum(1 for t in pattern_tokens if t.type.value == pattern_type)
        if actual_count != expected_count:
            print(f"  âŒ Expected {expected_count} {pattern_type} tokens, found {actual_count}")
            success = False
    
    if success:
        print("âœ… Pattern matching token recognition: SUCCESS")
    else:
        print("âŒ Pattern matching token recognition: FAILED")
    
    return success

def test_integration_with_base_lexer():
    """Test integration between pattern matching lexer and base lexer"""
    print("\n=== Integration Test ===")
    
    test_code = """
function process_data(data) {
    match data {
        case value when value > 0 => positive(value)
        case value when value < 0 => negative(value)
        case 0 => zero
    }
}
"""
    
    print("Testing pattern matching in function context...")
    
    # Test with base lexer (should work but not recognize pattern tokens)
    base_lexer = Lexer(test_code, "integration_test.nc")
    base_tokens = base_lexer.tokenize()
    
    # Test with pattern matching lexer (should recognize pattern tokens)
    pattern_lexer = PatternMatchingLexer(test_code, "integration_test.nc")
    pattern_tokens = pattern_lexer.tokenize()
    
    # Both should parse the basic structure correctly
    base_pattern_count = len([t for t in base_tokens if t.type in [TokenType.IDENTIFIER, TokenType.FUNCTION, TokenType.LEFT_BRACE, TokenType.RIGHT_BRACE]])
    pattern_pattern_count = len([t for t in pattern_tokens if t.type in [TokenType.IDENTIFIER, TokenType.FUNCTION, TokenType.LEFT_BRACE, TokenType.RIGHT_BRACE]])
    
    print(f"Base lexer tokens: {len(base_tokens)}")
    print(f"Pattern lexer tokens: {len(pattern_tokens)}")
    print(f"Structural tokens - Base: {base_pattern_count}, Pattern: {pattern_pattern_count}")
    
    # Check if pattern lexer found additional tokens
    additional_tokens = [t for t in pattern_tokens if t.type.value in ['MATCH', 'CASE', 'WHEN', 'ARROW']]
    
    if len(additional_tokens) > 0:
        print(f"\nâœ… Pattern matching extension detected {len(additional_tokens)} additional tokens:")
        for token in additional_tokens:
            print(f"  - {token.type.value}: '{token.value}'")
        print("âœ… Integration test: SUCCESS")
    else:
        print("\nâš ï¸  Pattern matching extension did not detect pattern tokens")
        print("âš ï¸  Integration test: PARTIAL")
    
    return len(additional_tokens) > 0

def test_performance():
    """Test performance of pattern matching lexer"""
    print("\n=== Performance Test ===")
    
    # Generate test code with pattern matching
    test_cases = [
        ("Small pattern matching", """
match x {
    case 1 => "one"
    case 2 => "two"
    case _ => "other"
}
"""),
        ("Medium pattern matching", """
match point {
    case Point(x, y) when x > 0 and y > 0 => "first quadrant"
    case Point(x, y) when x < 0 and y > 0 => "second quadrant"
    case Point(x, y) when x < 0 and y < 0 => "third quadrant"
    case Point(x, y) when x > 0 and y < 0 => "fourth quadrant"
    case _ => "origin"
}
"""),
        ("Large pattern matching", """
match value {
    case pattern when condition => result
    case alternative_pattern => alternative_result
    case _ => default_result
}

match nested {
    case outer when outer_condition {
        match inner {
            case inner_pattern => inner_result
            case _ => inner_default
        }
    }
    case _ => outer_default
}
""")
    ]
    
    for name, code in test_cases:
        print(f"\n{name}:")
        
        # Test performance
        import time
        start_time = time.time()
        
        lexer = PatternMatchingLexer(code, f"perf_test_{name}.nc")
        tokens = lexer.tokenize()
        
        end_time = time.time()
        parse_time = end_time - start_time
        
        print(f"  Tokens: {len(tokens)}, Time: {parse_time:.3f}s")
        
        # Performance target: <50ms for pattern matching code
        if parse_time < 0.05:
            print("  âœ… Meets performance target")
        else:
            print("  âš ï¸  Exceeds performance target")

def main():
    """Main test function"""
    print("Noodle Language Pattern Matching Feature Test")
    print("=" * 50)
    print("Testing Phase 2: Language Extensions implementation")
    print("=" * 50)
    
    try:
        # Run all tests
        test1_success = test_pattern_matching_tokens()
        test2_success = test_integration_with_base_lexer()
        test_performance()
        
        # Overall results
        print("\n" + "=" * 50)
        print("PATTERN MATCHING TEST SUMMARY")
        print("=" * 50)
        
        if test1_success and test2_success:
            print("âœ… Pattern matching tokens correctly recognized")
            print("âœ… Integration with base lexer successful")
            print("âœ… Pattern matching lexer extension working")
            print("\nðŸŽ‰ PATTERN MATCHING FEATURE: IMPLEMENTATION COMPLETE!")
            return 0
        else:
            print("âŒ Some tests failed")
            print("âŒ Pattern matching feature needs more work")
            return 1
            
    except Exception as e:
        print(f"\nâŒ Test failed with error: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)

