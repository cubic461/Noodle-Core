"""
Test Suite::Noodle Lang - simple_collections_test.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple Test Suite for Modern Collections in Noodle Language
Tests basic collections functionality without complex dependencies.
"""

import sys
import os
import time
from typing import List, Dict, Any

# Add the lexer directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'lexer'))

try:
    from collections_lexer import CollectionsLexer, Token, create_collections_token, is_collections_token
except ImportError as e:
    print(f"[ERROR] Import error: {e}")
    print("Make sure collections_lexer.py is in the correct location")
    sys.exit(1)

class CollectionsTestResult:
    """Simple test result container"""
    def __init__(self, name: str, passed: bool, message: str, execution_time: float):
        self.name = name
        self.passed = passed
        self.message = message
        self.execution_time = execution_time

class CollectionsTester:
    """Simple test runner for modern collections"""
    
    def __init__(self):
        self.lexer = CollectionsLexer()
        self.results: List[CollectionsTestResult] = []
        self.total_tests = 0
        self.passed_tests = 0
    
    def run_test(self, test_name: str, test_func) -> None:
        """Run a single test and record the result"""
        self.total_tests += 1
        start_time = time.time()
        
        try:
            test_func()
            execution_time = time.time() - start_time
            self.results.append(CollectionsTestResult(
                test_name, True, "Test passed", execution_time
            ))
            self.passed_tests += 1
            print(f"[PASS] {test_name} - PASSED ({execution_time:.3f}s)")
        except Exception as e:
            execution_time = time.time() - start_time
            self.results.append(CollectionsTestResult(
                test_name, False, str(e), execution_time
            ))
            print(f"[FAIL] {test_name} - FAILED: {e} ({execution_time:.3f}s)")
    
    def test_generic_collection_syntax(self) -> None:
        """Test generic collection syntax recognition"""
        test_code = "List<int>"
        constructs = self.lexer.analyze_collections_constructs(test_code)
        
        assert 'generic_collections' in constructs
        assert len(constructs['generic_collections']) > 0
        
        tokens = self.lexer.tokenize(test_code)
        
        # Should contain List and generic tokens
        has_list = any(t.type == CollectionsLexer.LIST for t in tokens)
        has_generic_lt = any(t.type == CollectionsLexer.GENERIC_LT for t in tokens)
        has_generic_gt = any(t.type == CollectionsLexer.GENERIC_GT for t in tokens)
        has_identifier = any(t.type == CollectionsLexer.IDENTIFIER and t.value == 'int' for t in tokens)
        
        assert has_list, "Should have LIST token"
        assert has_generic_lt, "Should have GENERIC_LT token"
        assert has_generic_gt, "Should have GENERIC_GT token"
        assert has_identifier, "Should have int identifier token"
    
    def test_functional_programming_syntax(self) -> None:
        """Test functional programming helpers syntax"""
        test_code = "map(numbers, n => n > 0)"
        constructs = self.lexer.analyze_collections_constructs(test_code)
        
        assert 'functional_calls' in constructs
        assert len(constructs['functional_calls']) > 0
        
        tokens = self.lexer.tokenize(test_code)
        
        # Should contain map and function tokens
        has_map = any(t.type == CollectionsLexer.MAP for t in tokens)
        has_function = any(t.type == CollectionsLexer.FUNCTIONAL and t.value == 'map' for t in tokens)
        has_identifier = any(t.type == CollectionsLexer.IDENTIFIER and t.value == 'numbers' for t in tokens)
        
        assert has_map, "Should have MAP token"
        assert has_function, "Should have FUNCTION token"
        assert has_identifier, "Should have numbers identifier token"
    
    def test_stream_processing_syntax(self) -> None:
        """Test stream processing syntax"""
        test_code = "async for item in stream<int>"
        constructs = self.lexer.analyze_collections_constructs(test_code)
        
        assert 'stream_operations' in constructs
        assert len(constructs['stream_operations']) > 0
        
        tokens = self.lexer.tokenize(test_code)
        
        # Should contain async, for, stream, and identifier tokens
        has_async = any(t.type == CollectionsLexer.STREAM for t in tokens)
        has_for = any(t.type == CollectionsLexer.FUNCTIONAL and t.value == 'for' for t in tokens)
        has_stream = any(t.type == CollectionsLexer.STREAM for t in tokens)
        has_identifier = any(t.type == CollectionsLexer.IDENTIFIER and t.value == 'item' for t in tokens)
        
        assert has_async, "Should have STREAM token"
        assert has_for, "Should have FOR token"
        assert has_stream, "Should have STREAM token"
        assert has_identifier, "Should have item identifier token"
    
    def test_collection_literals_syntax(self) -> None:
        """Test collection literal syntax"""
        test_code = "[1, 2, 3, 4, 5]"
        constructs = self.lexer.analyze_collections_constructs(test_code)
        
        assert 'collection_literals' in constructs
        assert len(constructs['collection_literals']) > 0
        
        tokens = self.lexer.tokenize(test_code)
        
        # Should contain collection literal tokens
        has_collection_literal = any(t.type == CollectionsLexer.IDENTIFIER and t.value.startswith('[') for t in tokens)
        
        assert has_collection_literal, "Should have collection literal token"
    
    def test_map_literals_syntax(self) -> None:
        """Test map literal syntax"""
        test_code = "{'key': 'value', 'numbers': [1, 2, 3]}"
        constructs = self.lexer.analyze_collections_constructs(test_code)
        
        assert 'map_literals' in constructs
        assert len(constructs['map_literals']) > 0
        
        tokens = self.lexer.tokenize(test_code)
        
        # Should contain map literal tokens
        has_map_literal = any(t.type == CollectionsLexer.IDENTIFIER and t.value.startswith('{') for t in tokens)
        
        assert has_map_literal, "Should have map literal token"
    
    def test_complex_collections_scenario(self) -> None:
        """Test complex collections scenario"""
        test_code = """
        numbers: List<int> = [1, 2, 3, 4, 5];
        names: List<string> = ["Alice", "Bob", "Charlie"];
        
        // Functional programming
        filtered = filter(numbers, n => n > 0);
        summed = reduce(numbers, 0, (a, b) => a + b);
        
        // Stream processing
        async for item in stream<int> {
            await process_item(item);
        }
        """
        
        # Analyze constructs
        constructs = self.lexer.analyze_collections_constructs(test_code)
        
        # Should find all collection types
        assert len(constructs['generic_collections']) > 0, "Should find generic collections"
        assert len(constructs['functional_calls']) > 0, "Should find functional calls"
        assert len(constructs['stream_operations']) > 0, "Should find stream operations"
        assert len(constructs['collection_literals']) > 0, "Should find collection literals"
        assert len(constructs['map_literals']) > 0, "Should find map literals"
        
        # Tokenize
        tokens = self.lexer.tokenize(test_code)
        
        # Should have collections tokens
        has_collections_tokens = any(is_collections_token(t) for t in tokens)
        assert has_collections_tokens, "Should have collections tokens in complex scenario"
        
        # Extract generic collections
        collections = self.lexer.get_generic_collections(tokens)
        assert len(collections) > 0, "Should extract generic collections"
    
    def test_syntax_validation(self) -> None:
        """Test syntax validation for collections"""
        # Valid generic collection
        valid_code = "List<int>"
        valid_tokens = self.lexer.tokenize(valid_code)
        valid_errors = self.lexer.validate_collections_syntax(valid_tokens)
        
        assert len(valid_errors) == 0, f"Valid code should have no errors, got: {valid_errors}"
        
        # Invalid generic collection (unmatched brackets)
        invalid_code = "List<int"
        invalid_tokens = self.lexer.tokenize(invalid_code)
        invalid_errors = self.lexer.validate_collections_syntax(invalid_tokens)
        
        # Should detect unmatched brackets
        assert len(invalid_errors) > 0, "Should detect invalid collection syntax"
    
    def test_utility_functions(self) -> None:
        """Test utility functions for collections tokens"""
        # Test token creation
        token = create_collections_token(CollectionsLexer.LIST, "List", 1, 5)
        
        assert token.type == CollectionsLexer.LIST
        assert token.value == "List"
        assert token.line == 1
        assert token.column == 5
        
        # Test collections token detection
        assert is_collections_token(token), "Created token should be collections token"
        
        non_collections_token = Token(999, "other", 1, 1)
        assert not is_collections_token(non_collections_token), "Non-collections token should not be detected as collections token"
    
    def test_performance_basic(self) -> None:
        """Test basic performance of collections tokenization"""
        test_code = "List<int> numbers = [1, 2, 3]"
        
        start_time = time.time()
        for _ in range(1000):
            tokens = self.lexer.tokenize(test_code)
        end_time = time.time()
        
        avg_time = (end_time - start_time) / 1000
        
        # Should be very fast (<1ms per tokenization)
        assert avg_time < 0.001, f"Tokenization too slow: {avg_time:.4f}s per call"
    
    def run_all_tests(self) -> None:
        """Run all collections tests"""
        print("Running Modern Collections Tests...")
        print("=" * 50)
        
        # Basic functionality tests
        self.run_test("Generic Collection Syntax", self.test_generic_collection_syntax)
        self.run_test("Functional Programming Syntax", self.test_functional_programming_syntax)
        self.run_test("Stream Processing Syntax", self.test_stream_processing_syntax)
        self.run_test("Collection Literals Syntax", self.test_collection_literals_syntax)
        self.run_test("Map Literals Syntax", self.test_map_literals_syntax)
        
        # Complex scenario tests
        self.run_test("Complex Collections Scenario", self.test_complex_collections_scenario)
        
        # Validation and utility tests
        self.run_test("Syntax Validation", self.test_syntax_validation)
        self.run_test("Utility Functions", self.test_utility_functions)
        
        # Performance tests
        self.run_test("Performance Basic", self.test_performance_basic)
        
        self.print_summary()
    
    def print_summary(self) -> None:
        """Print test summary"""
        print("=" * 50)
        print("Test Summary:")
        print(f"   Total Tests: {self.total_tests}")
        print(f"   Passed: {self.passed_tests}")
        print(f"   Failed: {self.total_tests - self.passed_tests}")
        print(f"   Success Rate: {(self.passed_tests / self.total_tests * 100):.1f}%")
        
        total_time = sum(r.execution_time for r in self.results)
        print(f"   Total Execution Time: {total_time:.3f}s")
        print(f"   Average Test Time: {total_time / self.total_tests:.3f}s")
        
        if self.passed_tests == self.total_tests:
            print("All tests passed! Modern collections are working correctly.")
        else:
            print("Some tests failed. Check implementation.")

def main():
    """Main test runner"""
    print("Noodle Language - Modern Collections Test Suite")
    print("Testing basic collections functionality...")
    print()
    
    tester = CollectionsTester()
    tester.run_all_tests()
    
    print()
    print("Modern Collections Features Tested:")
    print("   [OK] Generic collection syntax")
    print("   [OK] Functional programming helpers")
    print("   [OK] Stream processing syntax")
    print("   [OK] Collection literals")
    print("   [OK] Map literals")
    print("   [OK] Syntax validation")
    print("   [OK] Performance characteristics")
    print("   [OK] Complex scenarios")
    print()
    print("Next Steps:")
    print("   1. Integrate with existing Noodle parser")
    print("   2. Implement enhanced I/O abstractions")
    print("   3. Create comprehensive test coverage")
    
    return 0 if tester.passed_tests == tester.total_tests else 1

if __name__ == "__main__":
    sys.exit(main())

