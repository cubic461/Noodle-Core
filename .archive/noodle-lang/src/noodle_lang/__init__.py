"""
Noodle Lang::  Init   - __init__.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Noodle Language Implementation

This package provides a complete implementation of the Noodle programming language,
including lexical analysis, parsing, semantic analysis, optimization, and code generation.

Components:
- Lexer: Tokenizes Noodle source code
- Parser: Builds Abstract Syntax Trees (ASTs)
- Semantic Analyzer: Performs type checking and semantic validation
- Optimizer: Applies optimization passes to the AST
- Code Generator: Generates NBC bytecode from optimized ASTs
- Compiler: Main compiler interface coordinating all phases

The Noodle language features:
- Modern syntax with type annotations
- Functions, classes, and modules
- Control flow (if/else, for, while)
- Arrays and objects
- Import system
- Error handling
- AI-native features integration

Usage:
    from noodle_lang import NoodleCompiler
    
    compiler = NoodleCompiler()
    result = compiler.compile_file("example.nc")
    
    if result.success:
        print("Compilation successful!")
        print(f"Generated {len(result.instructions)} bytecode instructions")
    else:
        print("Compilation failed:")
        for error in result.errors:
            print(f"  {error.location}: {error.message}")
"""

from .lexer import NoodleLexer, Token, TokenType, SourceLocation, tokenize_source, tokenize_file
from .parser import NoodleParser, parse_source, parse_file
from .compiler import NoodleCompiler, CompilationResult, CompilationPhase

__version__ = "1.0.0"
__author__ = "Noodle Language Team"
__email__ = "team@noodle-lang.org"

# Export main classes and functions
__all__ = [
    # Main components
    'NoodleCompiler',
    'NoodleLexer',
    'NoodleParser',
    
    # Result types
    'CompilationResult',
    'CompilationPhase',
    'Token',
    'TokenType',
    'SourceLocation',
    
    # Convenience functions
    'compile_source',
    'compile_file',
    'tokenize_source',
    'tokenize_file',
    'parse_source',
    'parse_file',
]


def compile_source(source: str, filename: str = "<source>", optimize: bool = True, debug: bool = False) -> 'CompilationResult':
    """
    Compile Noodle source code from string.
    
    Args:
        source: Noodle source code as string
        filename: Filename for error reporting
        optimize: Whether to apply optimizations
        debug: Enable debug mode
        
    Returns:
        CompilationResult with success status, bytecode, errors, and warnings
    """
    compiler = NoodleCompiler(optimize=optimize, debug=debug)
    return compiler.compile_source(source, filename)


def compile_file(filepath: str, optimize: bool = True, debug: bool = False) -> 'CompilationResult':
    """
    Compile a Noodle file.
    
    Args:
        filepath: Path to the Noodle file to compile
        optimize: Whether to apply optimizations
        debug: Enable debug mode
        
    Returns:
        CompilationResult with success status, bytecode, errors, and warnings
    """
    compiler = NoodleCompiler(optimize=optimize, debug=debug)
    return compiler.compile_file(filepath)


def get_language_info() -> dict:
    """
    Get information about the Noodle language implementation.
    
    Returns:
        Dictionary with language version, features, and capabilities
    """
    compiler = NoodleCompiler()
    return {
        'name': 'Noodle',
        'version': __version__,
        'description': 'AI-native programming language for distributed systems',
        'features': compiler.get_supported_features(),
        'language_version': compiler.get_language_version(),
        'file_extensions': ['.nc'],
        'mime_types': ['text/x-noodle'],
        'keywords': list(NoodleLexer.KEYWORDS.keys()),
        'operators': list(NoodleLexer.MULTI_CHAR_OPERATORS.keys()) + list(NoodleLexer.SINGLE_CHAR_TOKENS.keys()),
    }


# Initialize logging
import logging
logger = logging.getLogger(__name__)
logger.info(f"Noodle Language v{__version__} initialized")

