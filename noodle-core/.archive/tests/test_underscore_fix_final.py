#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_underscore_fix_final.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to verify the underscore token fix in match expressions.
This tests that the parser now correctly handles underscore patterns with comma separators.
"""

import sys
import os

# Add noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'compiler'))

from enhanced_parser import EnhancedParser

def test_underscore_pattern():
    """Test underscore pattern with comma separator"""
    code = """
    match x {
        _ => "wildcard",
        1 => "one",
        2 => "two"
    }
    """
    
    parser = EnhancedParser(code, "<test>")
    ast = parser.parse()
    
    # Check if parsing succeeded
    if parser.errors:
        print(f"Parse errors: {parser.errors}")
        return False
    
    # Check if we got the expected structure
    if not ast.statements:
        print("No statements in AST")
        return False
    
    # Get the match expression
    stmt = ast.statements[0]
    if not hasattr(stmt, 'expression') or not hasattr(stmt.expression, 'cases'):
        print("Invalid AST structure")
        return False
    
    match_expr = stmt.expression
    
    # Check if we have the expected number of cases
    if len(match_expr.cases) != 3:
        print(f"Expected 3 cases, got {len(match_expr.cases)}")
        return False
    
    # Check if the first case is a wildcard pattern
    first_case = match_expr.cases[0]
    if not hasattr(first_case, 'pattern') or not hasattr(first_case.pattern, 'pattern_type'):
        print("Invalid case structure")
        return False
    
    if first_case.pattern.pattern_type != 'WildcardPattern':
        print(f"Expected WildcardPattern, got {first_case.pattern.pattern_type}")
        return False
    
    print("Underscore pattern test passed!")
    return True

def test_multiple_underscore_patterns():
    """Test multiple underscore patterns with comma separators"""
    code = """
    match x {
        _ => "first",
        _ => "second",
        1 => "one"
    }
    """
    
    parser = EnhancedParser(code, "<test>")
    ast = parser.parse()
    
    # Check if parsing succeeded
    if parser.errors:
        print(f"Parse errors: {parser.errors}")
        return False
    
    # Check if we got the expected structure
    if not ast.statements:
        print("No statements in AST")
        return False
    
    # Get the match expression
    stmt = ast.statements[0]
    match_expr = stmt.expression
    
    # Check if we have the expected number of cases
    if len(match_expr.cases) != 3:
        print(f"Expected 3 cases, got {len(match_expr.cases)}")
        return False
    
    # Check if the first two cases are wildcard patterns
    for i in range(2):
        case = match_expr.cases[i]
        if case.pattern.pattern_type != 'WildcardPattern':
            print(f"Case {i+1} expected WildcardPattern, got {case.pattern.pattern_type}")
            return False
    
    print("Multiple underscore patterns test passed!")
    return True

def test_mixed_patterns():
    """Test mixed patterns with underscore"""
    code = """
    match x {
        1 => "one",
        _ => "wildcard",
        "hello" => "greeting"
    }
    """
    
    parser = EnhancedParser(code, "<test>")
    ast = parser.parse()
    
    # Check if parsing succeeded
    if parser.errors:
        print(f"Parse errors: {parser.errors}")
        return False
    
    # Check if we got the expected structure
    if not ast.statements:
        print("No statements in AST")
        return False
    
    # Get the match expression
    stmt = ast.statements[0]
    match_expr = stmt.expression
    
    # Check if we have the expected number of cases
    if len(match_expr.cases) != 3:
        print(f"Expected 3 cases, got {len(match_expr.cases)}")
        return False
    
    # Check if the second case is a wildcard pattern
    second_case = match_expr.cases[1]
    if second_case.pattern.pattern_type != 'WildcardPattern':
        print(f"Expected WildcardPattern for second case, got {second_case.pattern.pattern_type}")
        return False
    
    print("Mixed patterns test passed!")
    return True

def main():
    """Run all tests"""
    print("Testing underscore pattern fix...")
    
    tests = [
        test_underscore_pattern,
        test_multiple_underscore_patterns,
        test_mixed_patterns
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        if test():
            passed += 1
    
    print(f"\nResults: {passed}/{total} tests passed")
    
    if passed == total:
        print("All tests passed! The underscore token fix is working correctly.")
        return True
    else:
        print("Some tests failed. The fix needs more work.")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)

