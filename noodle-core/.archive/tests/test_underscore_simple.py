#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_underscore_simple.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple test script to verify underscore token fix in match expressions.
"""

import sys
import os

# Add noodle-core directory to path
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
    
    # Check if we got expected structure
    if not ast.statements:
        print("No statements in AST")
        return False
    
    # Get match expression
    stmt = ast.statements[0]
    if not hasattr(stmt, 'expression') or not hasattr(stmt.expression, 'cases'):
        print("Invalid AST structure")
        return False
    
    match_expr = stmt.expression
    
    # Check if we have expected number of cases
    if len(match_expr.cases) != 3:
        print(f"Expected 3 cases, got {len(match_expr.cases)}")
        return False
    
    # Check if first case is a wildcard pattern
    first_case = match_expr.cases[0]
    if not hasattr(first_case, 'pattern') or not hasattr(first_case.pattern, 'pattern_type'):
        print("Invalid case structure")
        return False
    
    if first_case.pattern.pattern_type != 'WildcardPattern':
        print(f"Expected WildcardPattern, got {first_case.pattern.pattern_type}")
        return False
    
    print("Underscore pattern test passed!")
    return True

def main():
    """Run the test"""
    print("Testing underscore pattern fix...")
    
    if test_underscore_pattern():
        print("Test passed! The underscore token fix is working correctly.")
        return True
    else:
        print("Test failed. The fix needs more work.")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)

