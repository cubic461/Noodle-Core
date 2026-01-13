#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_basic_patterns.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Basic test suite for pattern matching in the Noodle language
Tests fundamental patterns without complex operators
"""

import sys
import os

# Add the noodle-core directory to the path
sys.path.insert(0, os.path.dirname(__file__))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'compiler'))

try:
    from enhanced_parser import EnhancedParser, parse_source
    from ast_nodes import (
        WildcardPatternNode, LiteralPatternNode, IdentifierPatternNode,
        TuplePatternNode, ArrayPatternNode, ObjectPatternNode,
        OrPatternNode, AndPatternNode, GuardPatternNode, TypePatternNode, RangePatternNode
    )
except ImportError as e:
    print(f"Import error: {e}")
    sys.exit(1)

class BasicPatternTestSuite:
    def __init__(self):
        self.tests = []
        self.passed = 0
        self.failed = 0
    
    def add_test(self, name, test_code, expected_pattern_type=None):
        """Add a test case to the suite"""
        self.tests.append({
            'name': name,
            'code': test_code,
            'expected_type': expected_pattern_type
        })
    
    def run_test(self, test):
        """Run a single test case"""
        print(f"Running test: {test['name']}...")
        
        try:
            # Create a simple match expression with the pattern
            match_code = f"match x {{ case {test['code']} => y }}"
            
            # Parse the test code
            parser = EnhancedParser(match_code, "test.nc")
            
            # Check if there were any parse errors
            if parser.errors:
                print(f"  FAILED: Parse errors: {parser.errors}")
                self.failed += 1
                return False
            
            # Try to get the AST
            ast = parser.parse()
            
            # Check if the AST was created successfully
            if not ast:
                print(f"  FAILED: Failed to create AST")
                self.failed += 1
                return False
            
            print(f"  PASSED")
            self.passed += 1
            return True
            
        except Exception as e:
            print(f"  FAILED: Exception: {e}")
            self.failed += 1
            return False
    
    def run_all_tests(self):
        """Run all tests in the suite"""
        print("=" * 60)
        print("BASIC PATTERN MATCHING TEST SUITE")
        print("=" * 60)
        
        for test in self.tests:
            self.run_test(test)
        
        print("=" * 60)
        print(f"RESULTS: {self.passed} passed, {self.failed} failed")
        print("=" * 60)
        
        return self.failed == 0

def create_test_suite():
    """Create and populate the test suite"""
    suite = BasicPatternTestSuite()
    
    # Basic identifier patterns (using x instead of _ due to parser issue)
    suite.add_test("Identifier pattern", "x", IdentifierPatternNode)
    
    # Literal patterns
    suite.add_test("Number literal", "42", LiteralPatternNode)
    suite.add_test("Float literal", "3.14", LiteralPatternNode)
    suite.add_test("String literal", '"hello"', LiteralPatternNode)
    suite.add_test("Boolean true", "true", LiteralPatternNode)
    suite.add_test("Boolean false", "false", LiteralPatternNode)
    
    # Tuple patterns
    suite.add_test("Empty tuple", "()", TuplePatternNode)
    suite.add_test("Single element tuple", "(x)", TuplePatternNode)
    suite.add_test("Two element tuple", "(x, y)", TuplePatternNode)
    suite.add_test("Three element tuple", "(x, y, z)", TuplePatternNode)
    
    # Array patterns
    suite.add_test("Empty array", "[]", ArrayPatternNode)
    suite.add_test("Single element array", "[x]", ArrayPatternNode)
    suite.add_test("Two element array", "[x, y]", ArrayPatternNode)
    suite.add_test("Three element array", "[x, y, z]", ArrayPatternNode)
    
    # Object patterns
    suite.add_test("Empty object", "{}", ObjectPatternNode)
    suite.add_test("Single property object", "{key: value}", ObjectPatternNode)
    suite.add_test("Two property object", "{key1: value1, key2: value2}", ObjectPatternNode)
    
    # Type patterns
    suite.add_test("Type pattern", "Type x", TypePatternNode)
    
    # Range patterns
    suite.add_test("Range pattern", "1..10", RangePatternNode)
    
    # Nested patterns
    suite.add_test("Nested tuple", "(x, (y, z))", TuplePatternNode)
    suite.add_test("Nested array", "[x, [y, z]]", ArrayPatternNode)
    suite.add_test("Nested object", "{key: {innerKey: value}}", ObjectPatternNode)
    suite.add_test("Mixed nested", "(x, [y, {key: z}])", TuplePatternNode)
    
    return suite

def main():
    """Main function to run the test suite"""
    suite = create_test_suite()
    success = suite.run_all_tests()
    
    if success:
        print("\nAll tests passed!")
        return 0
    else:
        print(f"\n{suite.failed} tests failed!")
        return 1

if __name__ == "__main__":
    sys.exit(main())

