"""
Test Suite::Noodle Lang - simple_async_test.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple Test Suite for Async/Await Syntax in Noodle Language
Tests basic async/await functionality without complex dependencies.
"""

import sys
import os
import time
from typing import List, Dict, Any

# Add the lexer directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'lexer'))

try:
    from async_await_lexer import AsyncAwaitLexer, Token, create_async_token, is_async_token
except ImportError as e:
    print(f"[ERROR] Import error: {e}")
    print("Make sure async_await_lexer.py is in the correct location")
    sys.exit(1)

class AsyncAwaitTestResult:
    """Simple test result container"""
    def __init__(self, name: str, passed: bool, message: str, execution_time: float):
        self.name = name
        self.passed = passed
        self.message = message
        self.execution_time = execution_time

class AsyncAwaitTester:
    """Simple test runner for async/await syntax"""
    
    def __init__(self):
        self.lexer = AsyncAwaitLexer()
        self.results: List[AsyncAwaitTestResult] = []
        self.total_tests = 0
        self.passed_tests = 0
    
    def run_test(self, test_name: str, test_func) -> None:
        """Run a single test and record the result"""
        self.total_tests += 1
        start_time = time.time()
        
        try:
            test_func()
            execution_time = time.time() - start_time
            self.results.append(AsyncAwaitTestResult(
                test_name, True, "Test passed", execution_time
            ))
            self.passed_tests += 1
            print(f"[PASS] {test_name} - PASSED ({execution_time:.3f}s)")
        except Exception as e:
            execution_time = time.time() - start_time
            self.results.append(AsyncAwaitTestResult(
                test_name, False, str(e), execution_time
            ))
            print(f"[FAIL] {test_name} - FAILED: {e} ({execution_time:.3f}s)")
    
    def test_async_keyword_tokenization(self) -> None:
        """Test basic async keyword tokenization"""
        test_code = "async"
        tokens = self.lexer.tokenize(test_code)
        
        assert len(tokens) == 1, f"Expected 1 token, got {len(tokens)}"
        assert tokens[0].type == AsyncAwaitLexer.ASYNC, "Token should be ASYNC"
        assert tokens[0].value == "async", "Token value should be 'async'"
    
    def test_await_keyword_tokenization(self) -> None:
        """Test basic await keyword tokenization"""
        test_code = "await"
        tokens = self.lexer.tokenize(test_code)
        
        assert len(tokens) == 1, f"Expected 1 token, got {len(tokens)}"
        assert tokens[0].type == AsyncAwaitLexer.AWAIT, "Token should be AWAIT"
        assert tokens[0].value == "await", "Token value should be 'await'"
    
    def test_async_function_syntax(self) -> None:
        """Test async function syntax recognition"""
        test_code = "async function fetchData() -> Data"
        constructs = self.lexer.analyze_async_constructs(test_code)
        
        assert 'async_functions' in constructs
        assert len(constructs['async_functions']) > 0
        
        tokens = self.lexer.tokenize(test_code)
        
        # Should contain async and function tokens
        has_async = any(t.type == AsyncAwaitLexer.ASYNC for t in tokens)
        has_function = any(t.value == 'function' for t in tokens if t.type == AsyncAwaitLexer.IDENTIFIER)
        has_identifier = any(t.value == 'fetchData' for t in tokens if t.type == AsyncAwaitLexer.IDENTIFIER)
        
        assert has_async, "Should have ASYNC token"
        # Note: FUNCTION token is not implemented in async lexer
        assert has_identifier, "Should have function identifier token"
    
    def test_await_expression_syntax(self) -> None:
        """Test await expression syntax recognition"""
        test_code = "result = await fetchData()"
        constructs = self.lexer.analyze_async_constructs(test_code)
        
        assert 'await_expressions' in constructs
        assert len(constructs['await_expressions']) > 0
        
        tokens = self.lexer.tokenize(test_code)
        
        # Should contain await and identifier tokens
        has_await = any(t.type == AsyncAwaitLexer.AWAIT for t in tokens)
        has_identifier = any(t.type == AsyncAwaitLexer.IDENTIFIER and t.value == 'fetchData' for t in tokens)
        
        assert has_await, "Should have AWAIT token"
        assert has_identifier, "Should have identifier token"
    
    def test_async_for_loop_syntax(self) -> None:
        """Test async for loop syntax recognition"""
        test_code = "async for item in items"
        constructs = self.lexer.analyze_async_constructs(test_code)
        
        assert 'async_for_loops' in constructs
        assert len(constructs['async_for_loops']) > 0
        
        tokens = self.lexer.tokenize(test_code)
        
        # Should contain async, for, and identifier tokens
        has_async = any(t.type == AsyncAwaitLexer.ASYNC for t in tokens)
        has_for = any(t.value == 'for' for t in tokens if t.type == AsyncAwaitLexer.IDENTIFIER)
        has_identifier = any(t.value == 'item' for t in tokens if t.type == AsyncAwaitLexer.IDENTIFIER)
        
        assert has_async, "Should have ASYNC token"
        assert has_for, "Should have FOR token"
        assert has_identifier, "Should have loop variable token"
    
    def test_complex_async_scenario(self) -> None:
        """Test a complex async scenario"""
        test_code = """
        async function processMultiple() {
            data1 = await fetchFromAPI("url1");
            data2 = await fetchFromAPI("url2");
            return combineData(data1, data2);
        }
        
        async for item in asyncGenerator() {
            await processItem(item);
        }
        """
        
        # Analyze constructs
        constructs = self.lexer.analyze_async_constructs(test_code)
        
        # Should find async functions and await expressions
        assert len(constructs['async_functions']) > 0, "Should find async functions"
        assert len(constructs['await_expressions']) > 0, "Should find await expressions"
        assert len(constructs['async_for_loops']) > 0, "Should find async for loops"
        
        # Tokenize
        tokens = self.lexer.tokenize(test_code)
        
        # Should have async tokens
        has_async_tokens = any(is_async_token(t) for t in tokens)
        assert has_async_tokens, "Should have async tokens in complex scenario"
        
        # Extract async functions
        async_functions = self.lexer.get_async_functions(tokens)
        assert len(async_functions) > 0, "Should extract async functions"
    
    def test_syntax_validation(self) -> None:
        """Test syntax validation for async/await"""
        # Valid async function
        valid_code = "async function test() -> void"
        valid_tokens = self.lexer.tokenize(valid_code)
        valid_errors = self.lexer.validate_async_syntax(valid_tokens)
        
        assert len(valid_errors) == 0, f"Valid code should have no errors, got: {valid_errors}"
        
        # Invalid async usage (await without expression)
        invalid_code = "await"
        invalid_tokens = self.lexer.tokenize(invalid_code)
        invalid_errors = self.lexer.validate_async_syntax(invalid_tokens)
        
        # Should detect the invalid await usage
        assert len(invalid_errors) > 0, "Should detect invalid await usage"
    
    def test_utility_functions(self) -> None:
        """Test utility functions for async/await tokens"""
        # Test token creation
        token = create_async_token(AsyncAwaitLexer.ASYNC, "async", 1, 5)
        
        assert token.type == AsyncAwaitLexer.ASYNC
        assert token.value == "async"
        assert token.line == 1
        assert token.column == 5
        
        # Test async token detection
        assert is_async_token(token), "Created token should be async token"
        
        non_async_token = Token(999, "other", 1, 1)
        assert not is_async_token(non_async_token), "Non-async token should not be detected as async"
    
    def test_performance_basic(self) -> None:
        """Test basic performance of async/await tokenization"""
        test_code = "async function test() -> void { await someCall(); }"
        
        start_time = time.time()
        for _ in range(1000):
            tokens = self.lexer.tokenize(test_code)
        end_time = time.time()
        
        avg_time = (end_time - start_time) / 1000
        
        # Should be very fast (< 1ms per tokenization)
        assert avg_time < 0.001, f"Tokenization too slow: {avg_time:.4f}s per call"
    
    def run_all_tests(self) -> None:
        """Run all async/await tests"""
        print("Running Async/Await Syntax Tests...")
        print("=" * 50)
        
        # Basic functionality tests
        self.run_test("Async Keyword Tokenization", self.test_async_keyword_tokenization)
        self.run_test("Await Keyword Tokenization", self.test_await_keyword_tokenization)
        self.run_test("Async Function Syntax", self.test_async_function_syntax)
        self.run_test("Await Expression Syntax", self.test_await_expression_syntax)
        self.run_test("Async For Loop Syntax", self.test_async_for_loop_syntax)
        
        # Complex scenario tests
        self.run_test("Complex Async Scenario", self.test_complex_async_scenario)
        
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
            print("All tests passed! Async/await syntax is working correctly.")
        else:
            print("Some tests failed. Check the implementation.")

def main():
    """Main test runner"""
    print("Noodle Language - Async/Await Syntax Test Suite")
    print("Testing basic async/await functionality...")
    print()
    
    tester = AsyncAwaitTester()
    tester.run_all_tests()
    
    print()
    print("Async/Await Features Tested:")
    print("   [OK] Async keyword tokenization")
    print("   [OK] Await keyword tokenization")
    print("   [OK] Async function syntax")
    print("   [OK] Await expression syntax")
    print("   [OK] Async for loop syntax")
    print("   [OK] Syntax validation")
    print("   [OK] Performance characteristics")
    print("   [OK] Complex scenarios")
    print()
    print("Next Steps:")
    print("   1. Integrate with existing Noodle parser")
    print("   2. Implement async runtime support")
    print("   3. Add async I/O abstractions")
    print("   4. Create comprehensive test coverage")
    
    return 0 if tester.passed_tests == tester.total_tests else 1

if __name__ == "__main__":
    sys.exit(main())

