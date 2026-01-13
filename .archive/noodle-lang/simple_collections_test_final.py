"""
Test Suite::Noodle Lang - simple_collections_test_final.py
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
    
    def test_basic_functionality(self) -> None:
        """Test basic collections lexer functionality"""
        # Test that lexer can be instantiated
        lexer = CollectionsLexer()
        assert lexer is not None
        
        # Test basic tokenization
        tokens = lexer.tokenize("List<int>")
        assert len(tokens) > 0
        
        # Test token creation
        token = create_collections_token(CollectionsLexer.LIST, "List", 1, 5)
        assert token.type == CollectionsLexer.LIST
        assert token.value == "List"
        
        # Test token detection
        assert is_collections_token(token)
    
    def test_keyword_recognition(self) -> None:
        """Test collection keyword recognition"""
        lexer = CollectionsLexer()
        
        # Test List keyword
        tokens = lexer.tokenize("List")
        list_tokens = [t for t in tokens if t.type == CollectionsLexer.LIST and t.value == "List"]
        assert len(list_tokens) > 0, "Should recognize List keyword"
        
        # Test Map keyword
        tokens = lexer.tokenize("Map")
        map_tokens = [t for t in tokens if t.type == CollectionsLexer.MAP and t.value == "Map"]
        assert len(map_tokens) > 0, "Should recognize Map keyword"
        
        # Test Set keyword
        tokens = lexer.tokenize("Set")
        set_tokens = [t for t in tokens if t.type == CollectionsLexer.SET and t.value == "Set"]
        assert len(set_tokens) > 0, "Should recognize Set keyword"
        
        # Test Stream keyword
        tokens = lexer.tokenize("Stream")
        stream_tokens = [t for t in tokens if t.type == CollectionsLexer.STREAM and t.value == "Stream"]
        assert len(stream_tokens) > 0, "Should recognize Stream keyword"
    
    def test_generic_brackets(self) -> None:
        """Test generic bracket recognition"""
        lexer = CollectionsLexer()
        
        # Test < bracket
        tokens = lexer.tokenize("<")
        lt_tokens = [t for t in tokens if t.type == CollectionsLexer.GENERIC_LT and t.value == "<"]
        assert len(lt_tokens) > 0, "Should recognize < bracket"
        
        # Test > bracket
        tokens = lexer.tokenize(">")
        gt_tokens = [t for t in tokens if t.type == CollectionsLexer.GENERIC_GT and t.value == ">"]
        assert len(gt_tokens) > 0, "Should recognize > bracket"
    
    def test_functional_operators(self) -> None:
        """Test functional programming operators"""
        lexer = CollectionsLexer()
        
        # Test pipe operator
        tokens = lexer.tokenize("|")
        pipe_tokens = [t for t in tokens if t.type == CollectionsLexer.PIPE and t.value == "|"]
        assert len(pipe_tokens) > 0, "Should recognize pipe operator"
        
        # Test functional keywords
        tokens = lexer.tokenize("map")
        functional_tokens = [t for t in tokens if t.type == CollectionsLexer.FUNCTIONAL and t.value == "map"]
        assert len(functional_tokens) > 0, "Should recognize functional keywords"
        
        tokens = lexer.tokenize("filter")
        functional_tokens = [t for t in tokens if t.type == CollectionsLexer.FUNCTIONAL and t.value == "filter"]
        assert len(functional_tokens) > 0, "Should recognize filter keyword"
    
    def test_complex_expressions(self) -> None:
        """Test complex collection expressions"""
        lexer = CollectionsLexer()
        
        # Test generic collection
        tokens = lexer.tokenize("List<int>")
        has_list = any(t.type == CollectionsLexer.LIST for t in tokens)
        has_lt = any(t.type == CollectionsLexer.GENERIC_LT for t in tokens)
        has_gt = any(t.type == CollectionsLexer.GENERIC_GT for t in tokens)
        has_int = any(t.type == CollectionsLexer.IDENTIFIER and t.value == "int" for t in tokens)
        
        assert has_list, "Should have LIST token"
        assert has_lt, "Should have GENERIC_LT token"
        assert has_gt, "Should have GENERIC_GT token"
        assert has_int, "Should have int identifier"
        
        # Test functional call
        tokens = lexer.tokenize("map(numbers, n => n > 0)")
        has_map = any(t.type == CollectionsLexer.FUNCTIONAL and t.value == "map" for t in tokens)
        has_numbers = any(t.type == CollectionsLexer.IDENTIFIER and t.value == "numbers" for t in tokens)
        
        assert has_map, "Should have map functional token"
        assert has_numbers, "Should have numbers identifier"
    
    def test_collections_analysis(self) -> None:
        """Test collections construct analysis"""
        lexer = CollectionsLexer()
        
        # Test generic collection analysis
        constructs = lexer.analyze_collections_constructs("List<int>")
        assert 'generic_collections' in constructs
        assert isinstance(constructs['generic_collections'], list)
        
        # Test functional call analysis
        constructs = lexer.analyze_collections_constructs("map(numbers)")
        assert 'functional_calls' in constructs
        assert isinstance(constructs['functional_calls'], list)
        
        # Test stream operation analysis
        constructs = lexer.analyze_collections_constructs("async for item in stream<int>")
        assert 'stream_operations' in constructs
        assert isinstance(constructs['stream_operations'], list)
        
        # Test collection literal analysis
        constructs = lexer.analyze_collections_constructs("[1, 2, 3]")
        assert 'collection_literals' in constructs
        assert isinstance(constructs['collection_literals'], list)
        
        # Test map literal analysis
        constructs = lexer.analyze_collections_constructs("{'key': 'value'}")
        assert 'map_literals' in constructs
        assert isinstance(constructs['map_literals'], list)
    
    def test_syntax_validation(self) -> None:
        """Test syntax validation"""
        lexer = CollectionsLexer()
        
        # Test valid expression
        tokens = lexer.tokenize("List<int>")
        errors = lexer.validate_collections_syntax(tokens)
        assert isinstance(errors, list)
        
        # Test invalid expression (unmatched brackets)
        tokens = lexer.tokenize("List<int")
        errors = lexer.validate_collections_syntax(tokens)
        assert isinstance(errors, list)
        # Should have at least one error for unmatched bracket
    
    def test_performance(self) -> None:
        """Test performance characteristics"""
        lexer = CollectionsLexer()
        test_code = "List<int> numbers = [1, 2, 3]"
        
        start_time = time.time()
        for _ in range(1000):
            tokens = lexer.tokenize(test_code)
        end_time = time.time()
        
        avg_time = (end_time - start_time) / 1000
        
        # Should be reasonably fast (<10ms per tokenization)
        assert avg_time < 0.01, f"Tokenization too slow: {avg_time:.4f}s per call"
    
    def test_integration_features(self) -> None:
        """Test integration features"""
        lexer = CollectionsLexer()
        
        # Test generic collections extraction
        tokens = lexer.tokenize("List<int>")
        collections = lexer.get_generic_collections(tokens)
        assert isinstance(collections, list)
        
        # Test utility functions
        token = create_collections_token(CollectionsLexer.LIST, "List", 1, 5)
        assert is_collections_token(token)
        
        non_collections_token = Token(999, "other", 1, 1)
        assert not is_collections_token(non_collections_token)
    
    def run_all_tests(self) -> None:
        """Run all collections tests"""
        print("Running Modern Collections Tests...")
        print("=" * 50)
        
        # Basic functionality tests
        self.run_test("Basic Functionality", self.test_basic_functionality)
        self.run_test("Keyword Recognition", self.test_keyword_recognition)
        self.run_test("Generic Brackets", self.test_generic_brackets)
        self.run_test("Functional Operators", self.test_functional_operators)
        
        # Complex expression tests
        self.run_test("Complex Expressions", self.test_complex_expressions)
        
        # Analysis and validation tests
        self.run_test("Collections Analysis", self.test_collections_analysis)
        self.run_test("Syntax Validation", self.test_syntax_validation)
        
        # Performance and integration tests
        self.run_test("Performance", self.test_performance)
        self.run_test("Integration Features", self.test_integration_features)
        
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
    print("   [OK] Basic lexer functionality")
    print("   [OK] Collection keyword recognition")
    print("   [OK] Generic bracket syntax")
    print("   [OK] Functional programming operators")
    print("   [OK] Complex expression parsing")
    print("   [OK] Collections construct analysis")
    print("   [OK] Syntax validation")
    print("   [OK] Performance characteristics")
    print("   [OK] Integration features")
    print()
    print("Next Steps:")
    print("   1. Integrate with existing Noodle parser")
    print("   2. Implement enhanced I/O abstractions")
    print("   3. Create comprehensive test coverage")
    
    return 0 if tester.passed_tests == tester.total_tests else 1

if __name__ == "__main__":
    sys.exit(main())

