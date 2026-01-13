# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Stub module for noodle.runtime.compiler - redirects to noodle.compiler

# This module is created to resolve import errors during the naming convention standardization.
# The actual compiler functionality is in noodle.compiler.
# """

import ..compiler.CodeGenerator,
import ..compiler.code_generator.generate_bytecode
import ..compiler.parser.parse
import ..compiler.semantic_analyzer.analyze_semantics

# Redirect all imports to the correct module
__all__ = [
#     "Parser",
#     "CodeGenerator",
#     "SemanticAnalyzer",
#     "NoodleCompiler",
#     "parse",
#     "analyze_semantics",
#     "generate_bytecode",
# ]

# Add deprecation warning
import warnings

warnings.warn(
#     "noodle.runtime.compiler is deprecated. Use noodle.compiler instead.",
#     DeprecationWarning,
# )
