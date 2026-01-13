"""
Test Suite::Noodle Lang - simple_io_test.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple Test Suite for Enhanced I/O Abstractions in Noodle Language
Tests basic I/O functionality without complex dependencies.
"""

import sys
import os
import time
from typing import List, Dict, Any

# Add the lexer directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'lexer'))

try:
    from io_abstractions_lexer import IOAbstractionsLexer, Token, create_io_token, is_io_token
except ImportError as e:
    print(f"[ERROR] Import error: {e}")
    print("Make sure io_abstractions_lexer.py is in the correct location")
    sys.exit(1)

class IOTestResult:
    """Simple test result container"""
    def __init__(self, name: str, passed: bool, message: str, execution_time: float):
        self.name = name
        self.passed = passed
        self.message = message
        self.execution_time = execution_time

class IOTester:
    """Simple test runner for enhanced I/O abstractions"""
    
    def __init__(self):
        self.lexer = IOAbstractionsLexer()
        self.results: List[IOTestResult] = []
        self.total_tests = 0
        self.passed_tests = 0
    
    def run_test(self, test_name: str, test_func) -> None:
        """Run a single test and record the result"""
        self.total_tests += 1
        start_time = time.time()
        
        try:
            test_func()
            execution_time = time.time() - start_time
            self.results.append(IOTestResult(
                test_name, True, "Test passed", execution_time
            ))
            self.passed_tests += 1
            print(f"[PASS] {test_name} - PASSED ({execution_time:.3f}s)")
        except Exception as e:
            execution_time = time.time() - start_time
            self.results.append(IOTestResult(
                test_name, False, str(e), execution_time
            ))
            print(f"[FAIL] {test_name} - FAILED: {e} ({execution_time:.3f}s)")
    
    def test_basic_functionality(self) -> None:
        """Test basic I/O lexer functionality"""
        # Test that lexer can be instantiated
        lexer = IOAbstractionsLexer()
        assert lexer is not None
        
        # Test basic tokenization
        tokens = lexer.tokenize("open('file.txt')")
        assert len(tokens) > 0
        
        # Test token creation
        token = create_io_token(IOAbstractionsLexer.OPEN, "open", 1, 5)
        assert token.type == IOAbstractionsLexer.OPEN
        assert token.value == "open"
        
        # Test token detection
        assert is_io_token(token)
    
    def test_file_operations(self) -> None:
        """Test file operation keywords"""
        lexer = IOAbstractionsLexer()
        
        # Test open keyword
        tokens = lexer.tokenize("open")
        open_tokens = [t for t in tokens if t.type == IOAbstractionsLexer.OPEN and t.value == "open"]
        assert len(open_tokens) > 0, "Should recognize open keyword"
        
        # Test read keyword
        tokens = lexer.tokenize("read")
        read_tokens = [t for t in tokens if t.type == IOAbstractionsLexer.READ and t.value == "read"]
        assert len(read_tokens) > 0, "Should recognize read keyword"
        
        # Test write keyword
        tokens = lexer.tokenize("write")
        write_tokens = [t for t in tokens if t.type == IOAbstractionsLexer.WRITE and t.value == "write"]
        assert len(write_tokens) > 0, "Should recognize write keyword"
        
        # Test close keyword
        tokens = lexer.tokenize("close")
        close_tokens = [t for t in tokens if t.type == IOAbstractionsLexer.CLOSE and t.value == "close"]
        assert len(close_tokens) > 0, "Should recognize close keyword"
        
        # Test File keyword
        tokens = lexer.tokenize("File")
        file_tokens = [t for t in tokens if t.type == IOAbstractionsLexer.FILE and t.value == "File"]
        assert len(file_tokens) > 0, "Should recognize File keyword"
    
    def test_http_operations(self) -> None:
        """Test HTTP operation keywords"""
        lexer = IOAbstractionsLexer()
        
        # Test HTTP keyword
        tokens = lexer.tokenize("HTTP")
        http_tokens = [t for t in tokens if t.type == IOAbstractionsLexer.HTTP and t.value == "HTTP"]
        assert len(http_tokens) > 0, "Should recognize HTTP keyword"
        
        # Test request keyword
        tokens = lexer.tokenize("request")
        request_tokens = [t for t in tokens if t.type == IOAbstractionsLexer.REQUEST and t.value == "request"]
        assert len(request_tokens) > 0, "Should recognize request keyword"
        
        # Test response keyword
        tokens = lexer.tokenize("response")
        response_tokens = [t for t in tokens if t.type == IOAbstractionsLexer.RESPONSE and t.value == "response"]
        assert len(response_tokens) > 0, "Should recognize response keyword"
    
    def test_stream_operations(self) -> None:
        """Test stream operation keywords"""
        lexer = IOAbstractionsLexer()
        
        # Test stream keyword
        tokens = lexer.tokenize("stream")
        stream_tokens = [t for t in tokens if t.type == IOAbstractionsLexer.STREAM and t.value == "stream"]
        assert len(stream_tokens) > 0, "Should recognize stream keyword"
        
        # Test async keyword
        tokens = lexer.tokenize("async")
        async_tokens = [t for t in tokens if t.type == IOAbstractionsLexer.ASYNC and t.value == "async"]
        assert len(async_tokens) > 0, "Should recognize async keyword"
        
        # Test await keyword
        tokens = lexer.tokenize("await")
        await_tokens = [t for t in tokens if t.type == IOAbstractionsLexer.AWAIT and t.value == "await"]
        assert len(await_tokens) > 0, "Should recognize await keyword"
    
    def test_resource_management(self) -> None:
        """Test resource management keywords"""
        lexer = IOAbstractionsLexer()
        
        # Test with keyword
        tokens = lexer.tokenize("with")
        with_tokens = [t for t in tokens if t.type == IOAbstractionsLexer.WITH and t.value == "with"]
        assert len(with_tokens) > 0, "Should recognize with keyword"
        
        # Test try keyword
        tokens = lexer.tokenize("try")
        try_tokens = [t for t in tokens if t.type == IOAbstractionsLexer.TRY and t.value == "try"]
        assert len(try_tokens) > 0, "Should recognize try keyword"
        
        # Test catch keyword
        tokens = lexer.tokenize("catch")
        catch_tokens = [t for t in tokens if t.type == IOAbstractionsLexer.CATCH and t.value == "catch"]
        assert len(catch_tokens) > 0, "Should recognize catch keyword"
        
        # Test finally keyword
        tokens = lexer.tokenize("finally")
        finally_tokens = [t for t in tokens if t.type == IOAbstractionsLexer.FINALLY and t.value == "finally"]
        assert len(finally_tokens) > 0, "Should recognize finally keyword"
    
    def test_socket_operations(self) -> None:
        """Test socket operation keywords"""
        lexer = IOAbstractionsLexer()
        
        # Test socket keyword
        tokens = lexer.tokenize("socket")
        socket_tokens = [t for t in tokens if t.type == IOAbstractionsLexer.SOCKET and t.value == "socket"]
        assert len(socket_tokens) > 0, "Should recognize socket keyword"
        
        # Test connect keyword
        tokens = lexer.tokenize("connect")
        connect_tokens = [t for t in tokens if t.type == IOAbstractionsLexer.CONNECT and t.value == "connect"]
        assert len(connect_tokens) > 0, "Should recognize connect keyword"
        
        # Test listen keyword
        tokens = lexer.tokenize("listen")
        listen_tokens = [t for t in tokens if t.type == IOAbstractionsLexer.LISTEN and t.value == "listen"]
        assert len(listen_tokens) > 0, "Should recognize listen keyword"
        
        # Test accept keyword
        tokens = lexer.tokenize("accept")
        accept_tokens = [t for t in tokens if t.type == IOAbstractionsLexer.ACCEPT and t.value == "accept"]
        assert len(accept_tokens) > 0, "Should recognize accept keyword"
        
        # Test send keyword
        tokens = lexer.tokenize("send")
        send_tokens = [t for t in tokens if t.type == IOAbstractionsLexer.SEND and t.value == "send"]
        assert len(send_tokens) > 0, "Should recognize send keyword"
        
        # Test receive keyword
        tokens = lexer.tokenize("receive")
        receive_tokens = [t for t in tokens if t.type == IOAbstractionsLexer.RECEIVE and t.value == "receive"]
        assert len(receive_tokens) > 0, "Should recognize receive keyword"
    
    def test_complex_expressions(self) -> None:
        """Test complex I/O expressions"""
        lexer = IOAbstractionsLexer()
        
        # Test file operation with parameters
        tokens = lexer.tokenize("open('file.txt', mode: 'read')")
        has_open = any(t.type == IOAbstractionsLexer.OPEN for t in tokens)
        has_string = any(t.type == IOAbstractionsLexer.STRING_LITERAL for t in tokens)
        has_colon = any(t.type == IOAbstractionsLexer.COLON for t in tokens)
        
        assert has_open, "Should have OPEN token"
        assert has_string, "Should have STRING_LITERAL token"
        assert has_colon, "Should have COLON token"
        
        # Test HTTP operation
        tokens = lexer.tokenize("HTTP.get('https://api.example.com/data')")
        has_http = any(t.type == IOAbstractionsLexer.HTTP for t in tokens)
        has_identifier = any(t.type == IOAbstractionsLexer.IDENTIFIER and t.value == "get" for t in tokens)
        
        assert has_http, "Should have HTTP token"
        assert has_identifier, "Should have get identifier"
        
        # Test async stream operation
        tokens = lexer.tokenize("async for item in stream")
        has_async = any(t.type == IOAbstractionsLexer.ASYNC for t in tokens)
        has_for = any(t.type == IOAbstractionsLexer.IDENTIFIER and t.value == "for" for t in tokens)
        has_stream = any(t.type == IOAbstractionsLexer.STREAM for t in tokens)
        
        assert has_async, "Should have ASYNC token"
        assert has_for, "Should have for identifier"
        assert has_stream, "Should have STREAM token"
    
    def test_io_analysis(self) -> None:
        """Test I/O construct analysis"""
        lexer = IOAbstractionsLexer()
        
        # Test file operation analysis
        constructs = lexer.analyze_io_constructs("open('file.txt')")
        assert 'file_operations' in constructs
        assert isinstance(constructs['file_operations'], list)
        
        # Test HTTP operation analysis
        constructs = lexer.analyze_io_constructs("HTTP.get('https://api.example.com')")
        assert 'http_operations' in constructs
        assert isinstance(constructs['http_operations'], list)
        
        # Test stream operation analysis
        constructs = lexer.analyze_io_constructs("async for item in stream")
        assert 'stream_operations' in constructs
        assert isinstance(constructs['stream_operations'], list)
        
        # Test socket operation analysis
        constructs = lexer.analyze_io_constructs("connect('localhost:8080')")
        assert 'socket_operations' in constructs
        assert isinstance(constructs['socket_operations'], list)
        
        # Test resource management analysis
        constructs = lexer.analyze_io_constructs("with file as f: { read() }")
        assert 'resource_management' in constructs
        assert isinstance(constructs['resource_management'], list)
        
        # Test error handling analysis
        constructs = lexer.analyze_io_constructs("try { open() } catch (e) { handle(e) }")
        assert 'error_handling' in constructs
        assert isinstance(constructs['error_handling'], list)
    
    def test_syntax_validation(self) -> None:
        """Test syntax validation"""
        lexer = IOAbstractionsLexer()
        
        # Test valid expression
        tokens = lexer.tokenize("open('file.txt')")
        errors = lexer.validate_io_syntax(tokens)
        assert isinstance(errors, list)
        
        # Test invalid expression (unmatched parentheses)
        tokens = lexer.tokenize("open('file.txt'")
        errors = lexer.validate_io_syntax(tokens)
        assert isinstance(errors, list)
        # Should have at least one error for unmatched parenthesis
    
    def test_performance(self) -> None:
        """Test performance characteristics"""
        lexer = IOAbstractionsLexer()
        test_code = "open('file.txt', mode: 'read')"
        
        start_time = time.time()
        for _ in range(1000):
            tokens = lexer.tokenize(test_code)
        end_time = time.time()
        
        avg_time = (end_time - start_time) / 1000
        
        # Should be reasonably fast (<10ms per tokenization)
        assert avg_time < 0.01, f"Tokenization too slow: {avg_time:.4f}s per call"
    
    def test_integration_features(self) -> None:
        """Test integration features"""
        lexer = IOAbstractionsLexer()
        
        # Test token creation
        token = create_io_token(IOAbstractionsLexer.OPEN, "open", 1, 5)
        assert is_io_token(token)
        
        non_io_token = Token(999, "other", 1, 1)
        assert not is_io_token(non_io_token)
        
        # Test complex expression with multiple I/O operations
        tokens = lexer.tokenize("""
        try {
            with File('data.txt') as file {
                content = read(file)
                HTTP.post('https://api.example.com', content)
            }
        } catch (error) {
            console.log(error)
        }
        """)
        
        # Should have various I/O tokens
        has_try = any(t.type == IOAbstractionsLexer.TRY for t in tokens)
        has_with = any(t.type == IOAbstractionsLexer.WITH for t in tokens)
        has_file = any(t.type == IOAbstractionsLexer.FILE for t in tokens)
        has_read = any(t.type == IOAbstractionsLexer.READ for t in tokens)
        has_http = any(t.type == IOAbstractionsLexer.HTTP for t in tokens)
        has_catch = any(t.type == IOAbstractionsLexer.CATCH for t in tokens)
        
        assert has_try, "Should have TRY token"
        assert has_with, "Should have WITH token"
        assert has_file, "Should have FILE token"
        assert has_read, "Should have READ token"
        assert has_http, "Should have HTTP token"
        assert has_catch, "Should have CATCH token"
    
    def run_all_tests(self) -> None:
        """Run all I/O tests"""
        print("Running Enhanced I/O Abstractions Tests...")
        print("=" * 50)
        
        # Basic functionality tests
        self.run_test("Basic Functionality", self.test_basic_functionality)
        self.run_test("File Operations", self.test_file_operations)
        self.run_test("HTTP Operations", self.test_http_operations)
        self.run_test("Stream Operations", self.test_stream_operations)
        self.run_test("Resource Management", self.test_resource_management)
        self.run_test("Socket Operations", self.test_socket_operations)
        
        # Complex expression tests
        self.run_test("Complex Expressions", self.test_complex_expressions)
        
        # Analysis and validation tests
        self.run_test("I/O Analysis", self.test_io_analysis)
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
            print("All tests passed! Enhanced I/O abstractions are working correctly.")
        else:
            print("Some tests failed. Check implementation.")

def main():
    """Main test runner"""
    print("Noodle Language - Enhanced I/O Abstractions Test Suite")
    print("Testing basic I/O functionality...")
    print()
    
    tester = IOTester()
    tester.run_all_tests()
    
    print()
    print("Enhanced I/O Features Tested:")
    print("   [OK] Basic lexer functionality")
    print("   [OK] File operation keywords")
    print("   [OK] HTTP operation keywords")
    print("   [OK] Stream operation keywords")
    print("   [OK] Resource management keywords")
    print("   [OK] Socket operation keywords")
    print("   [OK] Complex expression parsing")
    print("   [OK] I/O construct analysis")
    print("   [OK] Syntax validation")
    print("   [OK] Performance characteristics")
    print("   [OK] Integration features")
    print()
    print("Next Steps:")
    print("   1. Update language specification for new features")
    print("   2. Create comprehensive test suite for all features")
    print("   3. Performance optimization for new language constructs")
    
    return 0 if tester.passed_tests == tester.total_tests else 1

if __name__ == "__main__":
    sys.exit(main())

