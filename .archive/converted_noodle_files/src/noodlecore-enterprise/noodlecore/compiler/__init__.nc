# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Compiler module for the Noodle project.

# This module provides compilation functionality including:
# - Lexical analysis
# - Parsing
# - Semantic analysis
# - Code generation
# - Bytecode processing
# """

import .bytecode_processor.BytecodeProcessor
import .code_generator.CodeGenerator
import .compile_time_visitor.CompileTimeVisitor
import .noodle_compiler.NoodleCompiler
import .deployment_parser.DeploymentDSLParser
import .frontend.(
#     CompilerFrontend, FrontendConfig, FrontendError, ParseRequest, ParseResult,
#     ParsingMode, CacheStrategy, get_frontend, parse_code, parse_file, parse_snippet
# )
import .lexer_main.Lexer
import .matrix_backends.MatrixBackendManager
import .mlir_integration.JITCompiler
import .parser_ast_nodes.ProgramNode
import .parser_expression_parsing.ExpressionParser,
import .parser_statement_parsing.StatementParser
import .semantic_analyzer_visitor_pattern.SemanticVisitor
import .types.Type

__all__ = [
#     "Lexer",
#     "ExpressionParser",
#     "StatementParser",
#     "SemanticVisitor",
#     "CodeGenerator",
#     "BytecodeProcessor",
#     "NoodleCompiler",
#     "NoodleCompiler.set_semantic_analyzer",
#     "CompileTimeVisitor",
#     "DeploymentParser",
#     "MatrixBackends",
#     "MLIRIntegration",
#     "Type",
#     # Frontend module exports
#     "CompilerFrontend",
#     "FrontendConfig",
#     "FrontendError",
#     "ParseRequest",
#     "ParseResult",
#     "ParsingMode",
#     "CacheStrategy",
#     "get_frontend",
#     "parse_code",
#     "parse_file",
#     "parse_snippet",
# ]
