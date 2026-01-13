# Converted from Python to NoodleCore
# Original file: src

# """
# Noodle Compiler Main Class
# --------------------------
# Main compiler class that provides a simplified interface to the compiler pipeline.
# """

# Local imports
import .compiler_pipeline.CompilerPipeline


class NoodleCompiler
    #     """
    #     Simplified compiler interface for Noodle language.
    #     Uses the CompilerPipeline to handle the actual compilation process.
    #     """

    #     def __init__(self):
    self.pipeline = CompilerPipeline()

    #     def compile(self, source_code: str, filename: str = "<string>", target_format: str = "nbc"):
    #         """
    #         Compile Noodle source code through the pipeline.

    #         Args:
                source_code (str): The source code to compile.
    #             filename (str): Optional filename for error reporting.
    #             target_format (str): Target output format ('nbc' for bytecode).

    #         Returns:
    #             Compiled bytecode.

    #         Raises:
    #             CompilationError: If any compilation phase fails.
    #         """
            return self.pipeline.compile(source_code, filename, target_format)

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
            return self.pipeline.compile_to_file(source_code, output_file, filename, target_format)

    #     def get_errors(self) -list):
    #         """Get compilation errors from all phases."""
            return self.pipeline.get_compilation_errors()

    #     def has_errors(self) -bool):
    #         """Check if compilation encountered any errors."""
            return self.pipeline.has_errors()


class CompilationError(Exception)
    #     """Exception raised during compilation phases."""

    #     def __init__(self, message: str, errors: list = None):
    self.message = message
    self.errors = errors or []
            super().__init__(message)
