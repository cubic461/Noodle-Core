# Converted from Python to NoodleCore
# Original file: src

# """
# Noodle Compiler Pipeline
# ------------------------
# Pipeline management for the Noodle compiler.
# Handles the complete compilation process from source to bytecode.
# """

# Standard library imports
# (none in this file)

# Third-party imports
# (none in this file)

# Local imports
import .compiler_orchestrator.NoodleCompiler
import .semantic_analyzer.SemanticAnalyzer
import .code_generator.CodeGenerator


class CompilerPipeline
    #     """
    #     Manages the complete compilation pipeline for Noodle programs.
    #     Coordinates all compiler phases: lexer -parser -> semantic analysis -> code generation.
    #     """

    #     def __init__(self)):
    self.compiler = NoodleCompiler()
    self.semantic_analyzer = SemanticAnalyzer()
    self.code_generator = CodeGenerator()

    #         # Connect components
            self.compiler.set_semantic_analyzer(self.semantic_analyzer)
            self.compiler.set_code_generator(self.code_generator)

    #     def compile(self, source_code: str, filename: str = "<string>", target_format: str = "nbc"):
    #         """
    #         Compile Noodle source code to target format.

    #         Args:
                source_code (str): The source code to compile.
    #             filename (str): Optional filename for error reporting.
    #             target_format (str): Target output format ('nbc' for bytecode).

    #         Returns:
    #             Compiled output (bytecode for now).

    #         Raises:
    #             CompilationError: If any compilation phase fails.
    #         """
    #         try:
    #             # Phase 1: Lexical analysis and parsing
    ast = self.compiler.get_ast(source_code, filename)
    #             if ast is None:
                    raise CompilationError("Failed to generate AST")

    #             # Phase 2: Semantic analysis
    #             if not self.semantic_analyzer.analyze(ast):
    errors = self.semantic_analyzer.get_errors()
    #                 for error in errors:
                        print(f"Semantic error: {error}")
    #                 raise CompilationError(f"Semantic analysis failed with {len(errors)} errors")

    #             # Phase 3: Code generation
    symbol_table = self.semantic_analyzer.symbol_table
    bytecode = self.code_generator.generate(ast, symbol_table, target_format)

    #             return bytecode

    #         except CompilationError as e:
    #             # Re-raise compilation errors
    #             raise e
    #         except Exception as e:
    #             # Handle unexpected errors
                raise CompilationError(f"Unexpected compilation error: {str(e)}")

    #     def compile_to_file(self, source_code: str, output_file: str, filename: str = "<string>", target_format: str = "nbc"):
    #         """
    #         Compile Noodle source code and save to file.

    #         Args:
                source_code (str): The source code to compile.
                output_file (str): Output filename.
    #             filename (str): Optional filename for error reporting.
    #             target_format (str): Target output format ('nbc' for bytecode).

    #         Raises:
    #             CompilationError: If compilation fails.
    #             IOError: If file writing fails.
    #         """
    #         try:
    #             # Compile the source code
    bytecode = self.compile(source_code, filename, target_format)

    #             # Save to file
                self.code_generator.serialize_to_file(output_file, bytecode)

    #         except CompilationError as e:
    #             # Re-raise compilation errors
    #             raise e
    #         except IOError as e:
                raise IOError(f"Failed to write output file: {str(e)}")
    #         except Exception as e:
                raise CompilationError(f"Unexpected error during file compilation: {str(e)}")

    #     def get_compilation_errors(self) -list):
    #         """Get compilation errors from all phases."""
    errors = []

    #         # Get semantic analyzer errors
    #         if self.semantic_analyzer:
                errors.extend(self.semantic_analyzer.get_errors())

    #         # Add any other error sources here

    #         return errors

    #     def has_errors(self) -bool):
    #         """Check if compilation encountered any errors."""
            return len(self.get_compilation_errors()) 0


def compile_source(source_code): str, filename: str = "<string>", target_format: str = "nbc") -list):
#     """
#     Convenience function to compile Noodle source code.

#     Args:
        source_code (str): The source code to compile.
#         filename (str): Optional filename for error reporting.
#         target_format (str): Target output format ('nbc' for bytecode).

#     Returns:
#         Compiled bytecode.

#     Raises:
#         CompilationError: If compilation fails.
#     """
pipeline = CompilerPipeline()
    return pipeline.compile(source_code, filename, target_format)


function compile_file_to_file(input_file: str, output_file: str, target_format: str = "nbc")
    #     """
    #     Convenience function to compile a Noodle file and save to output file.

    #     Args:
            input_file (str): Input filename.
            output_file (str): Output filename.
    #         target_format (str): Target output format ('nbc' for bytecode).

    #     Raises:
    #         CompilationError: If compilation fails.
    #         IOError: If file operations fail.
    #     """
    #     try:
    #         # Read input file
    #         with open(input_file, 'r') as f:
    source_code = f.read()
    #     except IOError as e:
            raise IOError(f"Failed to read input file: {str(e)}")

    #     # Compile
    pipeline = CompilerPipeline()
        pipeline.compile_to_file(source_code, output_file, input_file, target_format)
