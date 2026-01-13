#!/usr/bin/env python3
"""
Test Suite::Tests - test_compiler.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Tests for Noodle Language Compiler

This module contains comprehensive tests for the Noodle language compiler,
including lexical analysis, parsing, semantic analysis, optimization, and code generation.
"""

import pytest
import tempfile
import os
from pathlib import Path

# Import the Noodle language components
from noodle_lang import (
    NoodleCompiler, NoodleLexer, NoodleParser, 
    compile_source, compile_file,
    TokenType, SourceLocation, CompilationResult
)


class TestNoodleLexer:
    """Test cases for the Noodle lexer"""
    
    def test_keywords(self):
        """Test keyword recognition"""
        source = "let def return if else for in while break continue import from as class struct interface implements extends type enum match case default async await yield true false none"
        lexer = NoodleLexer(source)
        tokens = lexer.tokenize()
        
        expected_keywords = [
            'let', 'def', 'return', 'if', 'else', 'for', 'in', 'while',
            'break', 'continue', 'import', 'from', 'as', 'class', 'struct',
            'interface', 'implements', 'extends', 'type', 'enum', 'match',
            'case', 'default', 'async', 'await', 'yield', 'true', 'false', 'none'
        ]
        
        for i, keyword in enumerate(expected_keywords):
            assert tokens[i].type.value == keyword.upper()
            assert tokens[i].value == keyword
    
    def test_identifiers(self):
        """Test identifier recognition"""
        source = "variable_name _private __magic123 camelCase PascalCase"
        lexer = NoodleLexer(source)
        tokens = lexer.tokenize()
        
        expected_identifiers = ['variable_name', '_private', '__magic123', 'camelCase', 'PascalCase']
        
        for i, identifier in enumerate(expected_identifiers):
            assert tokens[i].type == TokenType.IDENTIFIER
            assert tokens[i].value == identifier
    
    def test_numbers(self):
        """Test number literal recognition"""
        source = "42 3.14 0.5 123e-4 1.23e+4"
        lexer = NoodleLexer(source)
        tokens = lexer.tokenize()
        
        expected_numbers = ['42', '3.14', '0.5', '123e-4', '1.23e+4']
        
        for i, number in enumerate(expected_numbers):
            assert tokens[i].type == TokenType.NUMBER
            assert tokens[i].value == number
    
    def test_strings(self):
        """Test string literal recognition"""
        source = '"hello world" \'single quotes\' "escape\\nsequence"'
        lexer = NoodleLexer(source)
        tokens = lexer.tokenize()
        
        assert len(tokens) >= 3
        assert tokens[0].type == TokenType.STRING
        assert tokens[0].value == "hello world"
        assert tokens[1].type == TokenType.STRING
        assert tokens[1].value == "single quotes"
        assert tokens[2].type == TokenType.STRING
        assert tokens[2].value == "escape\nsequence"
    
    def test_operators(self):
        """Test operator recognition"""
        source = "+ - * / % = == != < > <= >= && || ! -> ::"
        lexer = NoodleLexer(source)
        tokens = lexer.tokenize()
        
        expected_operators = ['+', '-', '*', '/', '%', '=', '==', '!=', '<', '>', '<=', '>=', '&&', '||', '!', '->', '::']
        
        for i, operator in enumerate(expected_operators):
            assert tokens[i].value == operator
    
    def test_delimiters(self):
        """Test delimiter recognition"""
        source = "( ) { } [ ] , . : ;"
        lexer = NoodleLexer(source)
        tokens = lexer.tokenize()
        
        expected_delimiters = ['(', ')', '{', '}', '[', ']', ',', '.', ':', ';']
        
        for i, delimiter in enumerate(expected_delimiters):
            assert tokens[i].value == delimiter
    
    def test_comments(self):
        """Test comment handling"""
        source = "let x = 5; # This is a comment\nlet y = 10;"
        lexer = NoodleLexer(source)
        tokens = lexer.tokenize()
        
        # Should ignore comment
        expected_values = ['let', 'x', '=', '5', ';', 'let', 'y', '=', '10', ';']
        actual_values = [token.value for token in tokens if token.type != TokenType.EOF]
        
        assert actual_values == expected_values
    
    def test_source_location(self):
        """Test source location tracking"""
        source = "let x = 5;\nlet y = 10;"
        lexer = NoodleLexer(source)
        tokens = lexer.tokenize()
        
        # First line
        assert tokens[0].location.line == 1
        assert tokens[0].location.column == 1
        assert tokens[1].location.line == 1
        assert tokens[1].location.column == 5
        
        # Second line
        newline_token = next(t for t in tokens if t.type == TokenType.NEWLINE)
        let_token_index = tokens.index(newline_token) + 1
        assert tokens[let_token_index].location.line == 2
        assert tokens[let_token_index].location.column == 1
    
    def test_error_handling(self):
        """Test error handling for invalid characters"""
        source = "let x = @5;"
        lexer = NoodleLexer(source)
        tokens = lexer.tokenize()
        
        assert len(lexer.errors) > 0
        assert "Unexpected character" in lexer.errors[0].message


class TestNoodleParser:
    """Test cases for the Noodle parser"""
    
    def test_let_statement(self):
        """Test let statement parsing"""
        source = "let x = 42;"
        parser = NoodleParser(source)
        ast = parser.parse()
        
        assert len(ast.statements) == 1
        stmt = ast.statements[0]
        assert stmt.type.value == "let_statement"
        assert stmt.name == "x"
        assert stmt.initializer is not None
        assert stmt.initializer.type.value == "number_literal"
        assert stmt.initializer.value == 42
    
    def test_let_with_type(self):
        """Test let statement with type annotation"""
        source = "let x: int = 42;"
        parser = NoodleParser(source)
        ast = parser.parse()
        
        stmt = ast.statements[0]
        assert stmt.type_annotation == "int"
    
    def test_function_definition(self):
        """Test function definition parsing"""
        source = "def add(a: int, b: int) -> int { return a + b; }"
        parser = NoodleParser(source)
        ast = parser.parse()
        
        assert len(ast.statements) == 1
        stmt = ast.statements[0]
        assert stmt.type.value == "function_definition"
        assert stmt.name == "add"
        assert len(stmt.parameters) == 2
        assert stmt.parameters[0].name == "a"
        assert stmt.parameters[0].type_annotation == "int"
        assert stmt.return_type == "int"
        assert len(stmt.body) == 1
    
    def test_if_statement(self):
        """Test if statement parsing"""
        source = "if (x > 0) { return true; } else { return false; }"
        parser = NoodleParser(source)
        ast = parser.parse()
        
        stmt = ast.statements[0]
        assert stmt.type.value == "if_statement"
        assert stmt.condition is not None
        assert len(stmt.then_branch) == 1
        assert stmt.else_branch is not None
    
    def test_for_statement(self):
        """Test for statement parsing"""
        source = "for item in items { print(item); }"
        parser = NoodleParser(source)
        ast = parser.parse()
        
        stmt = ast.statements[0]
        assert stmt.type.value == "for_statement"
        assert stmt.variable == "item"
        assert stmt.iterable is not None
        assert len(stmt.body) == 1
    
    def test_while_statement(self):
        """Test while statement parsing"""
        source = "while (x < 10) { x = x + 1; }"
        parser = NoodleParser(source)
        ast = parser.parse()
        
        stmt = ast.statements[0]
        assert stmt.type.value == "while_statement"
        assert stmt.condition is not None
        assert len(stmt.body) == 1
    
    def test_binary_expressions(self):
        """Test binary expression parsing"""
        source = "let x = a + b * c;"
        parser = NoodleParser(source)
        ast = parser.parse()
        
        stmt = ast.statements[0]
        assert stmt.initializer.type.value == "binary_expression"
        assert stmt.initializer.operator == "+"
        assert stmt.initializer.left.type.value == "identifier"
        assert stmt.initializer.left.name == "a"
        assert stmt.initializer.right.type.value == "binary_expression"
        assert stmt.initializer.right.operator == "*"
    
    def test_function_call(self):
        """Test function call parsing"""
        source = "print(\"hello\");"
        parser = NoodleParser(source)
        ast = parser.parse()
        
        stmt = ast.statements[0]
        assert stmt.expression.type.value == "function_call"
        assert stmt.expression.function == "print"
        assert len(stmt.expression.arguments) == 1
        assert stmt.expression.arguments[0].type.value == "string_literal"
    
    def test_array_literal(self):
        """Test array literal parsing"""
        source = "let arr = [1, 2, 3];"
        parser = NoodleParser(source)
        ast = parser.parse()
        
        stmt = ast.statements[0]
        assert stmt.initializer.type.value == "array_literal"
        assert len(stmt.initializer.elements) == 3
        assert stmt.initializer.elements[0].value == 1
    
    def test_object_literal(self):
        """Test object literal parsing"""
        source = "let obj = {\"name\": \"John\", \"age\": 30};"
        parser = NoodleParser(source)
        ast = parser.parse()
        
        stmt = ast.statements[0]
        assert stmt.initializer.type.value == "object_literal"
        assert len(stmt.initializer.properties) == 2
        assert stmt.initializer.properties[0].key == "name"
        assert stmt.initializer.properties[0].value.value == "John"


class TestNoodleCompiler:
    """Test cases for the Noodle compiler"""
    
    def test_simple_compilation(self):
        """Test simple compilation"""
        source = "let x = 42;"
        compiler = NoodleCompiler()
        result = compiler.compile_source(source)
        
        assert result.success
        assert len(result.errors) == 0
        assert result.bytecode is not None
        assert result.compilation_time > 0
    
    def test_compilation_with_errors(self):
        """Test compilation with errors"""
        source = "let x = ;"  # Missing expression
        compiler = NoodleCompiler()
        result = compiler.compile_source(source)
        
        assert not result.success
        assert len(result.errors) > 0
    
    def test_optimization(self):
        """Test optimization"""
        source = "let x = 1 + 2 * 3;"  # Can be optimized to 7
        compiler = NoodleCompiler(optimize=True)
        result = compiler.compile_source(source)
        
        assert result.success
        assert result.statistics['optimizations'] > 0
        
        # Test without optimization
        compiler_no_opt = NoodleCompiler(optimize=False)
        result_no_opt = compiler_no_opt.compile_source(source)
        
        assert result_no_opt.success
        assert result_no_opt.statistics['optimizations'] == 0
    
    def test_function_compilation(self):
        """Test function compilation"""
        source = """
        def add(a, b) {
            return a + b;
        }
        
        let result = add(5, 3);
        """
        compiler = NoodleCompiler()
        result = compiler.compile_source(source)
        
        assert result.success
        assert len(result.errors) == 0
        assert result.statistics['instructions'] > 0
    
    def test_control_flow_compilation(self):
        """Test control flow compilation"""
        source = """
        let x = 10;
        if (x > 5) {
            print("greater");
        } else {
            print("less or equal");
        }
        """
        compiler = NoodleCompiler()
        result = compiler.compile_source(source)
        
        assert result.success
        assert len(result.errors) == 0
    
    def test_loop_compilation(self):
        """Test loop compilation"""
        source = """
        for i in 0..10 {
            print(i);
        }
        """
        compiler = NoodleCompiler()
        result = compiler.compile_source(source)
        
        assert result.success
        assert len(result.errors) == 0
    
    def test_class_compilation(self):
        """Test class compilation"""
        source = """
        class Person {
            let name: string;
            let age: int;
            
            def greet() {
                return "Hello, " + this.name;
            }
        }
        """
        compiler = NoodleCompiler()
        result = compiler.compile_source(source)
        
        assert result.success
        assert len(result.errors) == 0
    
    def test_import_compilation(self):
        """Test import compilation"""
        source = """
        import "std.io";
        import "std.math" as math;
        
        print("Hello");
        let result = math.sqrt(16);
        """
        compiler = NoodleCompiler()
        result = compiler.compile_source(source)
        
        assert result.success
        assert len(result.errors) == 0
    
    def test_type_annotations(self):
        """Test type annotations"""
        source = """
        let x: int = 42;
        let y: float = 3.14;
        let name: string = "John";
        let flag: bool = true;
        
        def calculate(a: int, b: int) -> int {
            return a * b;
        }
        """
        compiler = NoodleCompiler()
        result = compiler.compile_source(source)
        
        assert result.success
        assert len(result.errors) == 0
    
    def test_error_reporting(self):
        """Test error reporting"""
        source = """
        let x = 42
        let y = ;  # Error: missing expression
        def undefined_func() {
            return unknown_var;  # Error: undefined variable
        }
        """
        compiler = NoodleCompiler()
        result = compiler.compile_source(source)
        
        assert not result.success
        assert len(result.errors) >= 2
        
        # Check error locations
        for error in result.errors:
            assert error.location.file != ""
            assert error.location.line > 0
            assert error.location.column > 0
            assert error.message != ""
    
    def test_warning_reporting(self):
        """Test warning reporting"""
        source = """
        def func() -> int {  # Declares return type but returns nothing
            let x = 42;
            # No return statement
        }
        """
        compiler = NoodleCompiler()
        result = compiler.compile_source(source)
        
        # Should generate warning about missing return
        assert len(result.warnings) >= 1
    
    def test_source_map_generation(self):
        """Test source map generation"""
        source = """
        let x = 42;
        def test() {
            return x;
        }
        """
        compiler = NoodleCompiler()
        result = compiler.compile_source(source)
        
        assert result.success
        assert result.source_map is not None
        assert len(result.source_map) > 0
    
    def test_statistics_collection(self):
        """Test statistics collection"""
        source = """
        let x = 1 + 2;
        def test(a, b) {
            return a * b;
        }
        """
        compiler = NoodleCompiler()
        result = compiler.compile_source(source)
        
        assert result.success
        assert 'tokens' in result.statistics
        assert 'ast_nodes' in result.statistics
        assert 'instructions' in result.statistics
        assert 'constants' in result.statistics
        assert 'compilation_time' in result.statistics
        assert result.statistics['tokens'] > 0
        assert result.statistics['ast_nodes'] > 0
        assert result.statistics['instructions'] > 0


class TestCompilerIntegration:
    """Integration tests for the compiler"""
    
    def test_file_compilation(self):
        """Test file compilation"""
        source = """
        let message = "Hello from file!";
        print(message);
        """
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.nc', delete=False) as f:
            f.write(source)
            f.flush()
            
            try:
                result = compile_file(f.name)
                assert result.success
                assert len(result.errors) == 0
            finally:
                os.unlink(f.name)
    
    def test_convenience_functions(self):
        """Test convenience functions"""
        source = "let x = 42;"
        
        # Test compile_source function
        result = compile_source(source)
        assert result.success
        assert len(result.errors) == 0
        
        # Test with options
        result_debug = compile_source(source, debug=True)
        assert result_debug.success
        
        result_no_opt = compile_source(source, optimize=False)
        assert result_no_opt.success
    
    def test_complex_program(self):
        """Test compilation of a complex program"""
        source = """
        import "std.io";
        import "std.math" as math;
        
        class Calculator {
            let result: float;
            
            def __init__() {
                this.result = 0.0;
            }
            
            def add(value: float) {
                this.result = this.result + value;
            }
            
            def multiply(value: float) {
                this.result = this.result * value;
            }
            
            def get_result() -> float {
                return this.result;
            }
        }
        
        def factorial(n: int) -> int {
            if (n <= 1) {
                return 1;
            } else {
                return n * factorial(n - 1);
            }
        }
        
        def main() {
            let calc = Calculator();
            calc.add(5.0);
            calc.multiply(3.0);
            
            print("Calculator result: " + calc.get_result());
            print("Factorial of 5: " + factorial(5));
            
            for i in 1..10 {
                print("Square of " + i + ": " + (i * i));
            }
            
            return 0;
        }
        
        let exit_code = main();
        """
        
        compiler = NoodleCompiler(optimize=True)
        result = compiler.compile_source(source)
        
        assert result.success
        assert len(result.errors) == 0
        assert result.statistics['instructions'] > 50
        assert result.statistics['optimizations'] > 0
    
    def test_error_recovery(self):
        """Test error recovery"""
        source = """
        let x = 42;
        let y = ;  # Error 1
        let z = 100;
        
        def broken_func() {
            return undefined_var;  # Error 2
        }
        
        let result = broken_func() + 5;  # Should still try to compile despite errors
        """
        
        compiler = NoodleCompiler(debug=True)  # Enable debug to continue on errors
        result = compiler.compile_source(source)
        
        assert not result.success
        assert len(result.errors) >= 2
        
        # Check that we still get some output despite errors
        assert result.statistics['tokens'] > 0


if __name__ == '__main__':
    pytest.main([__file__])

