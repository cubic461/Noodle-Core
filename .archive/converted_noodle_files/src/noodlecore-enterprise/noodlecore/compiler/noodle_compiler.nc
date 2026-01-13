# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Noodle Compiler Orchestrator
# -----------------------------
# Main class that orchestrates the full compilation pipeline: lexer → parser → semantic analyzer → code generator.
# Supports single/multi-file compilation, error handling, statistics, CLI, and modes.
# """

import argparse
import hashlib
import os
import time
import pathlib.Path
import typing.Dict,

import ..compiler.code_generator.BytecodeInstruction,
import ..compiler.lexer.Lexer,
import ..compiler.parser_ast_nodes.ProgramNode
import ..compiler.parser_expression_parsing.ExpressionParser
import ..compiler.parser_statement_parsing.StatementParser
import ..compiler.semantic_analyzer_visitor_pattern.SemanticVisitor
import ..runtime.error_handler.ErrorHandler

try
    #     from .nir.builder import NIRBuilder
    #     from .nir.passes import ConstantFoldingPass, DeadCodeElimPass

    NIR_AVAILABLE = True
except ImportError
    NIR_AVAILABLE = False


class CompilationError(Exception)
    #     """Base exception for compilation errors."""

    #     def __init__(
    self, message: str, phase: str, position: Optional[Tuple[int, int]] = None
    #     ):
    self.message = message
    self.phase = phase
    self.position = position
            super().__init__(
    #             f"[{phase}] {message} at {position}" if position else f"[{phase}] {message}"
    #         )


class CompilationStats
    #     """Holds compilation statistics and metrics."""

    #     def __init__(self):
    self.phases: Dict[str, Dict[str, float]] = math.divide({}  # phase: {time, nodes, instrs})
    self.errors: int = 0
    self.warnings: int = 0
    self.instructions: int = 0
    self.total_time: float = 0.0
    self.mode: str = "release"
    self.files_compiled: int = 0

    #     def start_phase(self, phase: str):
    self.phases[phase] = {"start": time.time(), "count": 0}

    #     def end_phase(self, phase: str, count: int = 0):
    #         if phase in self.phases:
    duration = time.time() - self.phases[phase]["start"]
    self.phases[phase]["time"] = duration
    self.phases[phase]["count"] = count
    self.total_time + = duration

    #     def to_dict(self) -> Dict:
    #         return {
    #             "total_time": self.total_time,
    #             "phases": {
    #                 k: {kk: vv for kk, vv in v.items() if kk != "start"}
    #                 for k, v in self.phases.items()
    #             },
    #             "errors": self.errors,
    #             "warnings": self.warnings,
    #             "instructions": self.instructions,
    #             "mode": self.mode,
    #             "files_compiled": self.files_compiled,
    #         }

    #     def print_summary(self):
    print("\n = == Compilation Statistics ===")
            print(f"Mode: {self.mode}")
            print(f"Files compiled: {self.files_compiled}")
            print(f"Total time: {self.total_time:.2f}s")
            print(f"Errors: {self.errors}, Warnings: {self.warnings}")
            print(f"Generated instructions: {self.instructions}")
    #         for phase, data in self.phases.items():
    count = data.get("count", 0)
    time_str = f"{data.get('time', 0):.2f}s"
                print(f"{phase}: {count} items, {time_str}")


class NoodleCompiler
    #     def __init__(self, mode: str = "release", cache_dir: Optional[str] = None):
    self.mode = mode
    #         self.cache_dir = Path(cache_dir) if cache_dir else None
    self.bytecode: List[str] = []
    self.global_ast: ProgramNode = ProgramNode([])
    self.global_symbol_table = {}
    self.errors: List[CompilationError] = []
    self.warnings: List[str] = []
    self.stats = CompilationStats()
    self.stats.mode = mode
    self._components: Dict[str, object] = {}
    self._cache: Dict[str, str] = {}  # file_hash: bytecode

    #     def register_component(self, name: str, component):
    #         """Register a compiler component."""
    self._components[name] = component

    #     def get_component(self, name: str):
    #         """Get a registered component, creating default if needed."""
    #         if name not in self._components:
    #             if name == "lexer":
    #                 # Create lexer with empty content that will be set later
    self._components[name] = Lexer()
    #             elif name == "parser":
    lexer = self.get_component("lexer")
    self._components[name] = StatementParser(lexer)
    #             elif name == "semantic_analyzer":
    self._components[name] = SemanticVisitor()
    #             elif name == "code_generator":
    self._components[name] = CodeGenerator()
    #             else:
                    raise ValueError(f"Unknown component: {name}")
    #         return self._components[name]

    #     def _get_file_hash(self, file_path: str) -> str:
    #         """Compute file hash for caching."""
    #         with open(file_path, "rb") as f:
                return hashlib.sha256(f.read()).hexdigest()

    #     def _check_cache(self, file_path: str) -> Optional[str]:
    #         """Check if bytecode is cached."""
    #         if not self.cache_dir:
    #             return None
    file_hash = self._get_file_hash(file_path)
    cache_file = self.cache_dir / f"{Path(file_path).stem}_{file_hash}.nbc"
    #         if cache_file.exists():
    #             with open(cache_file, "r") as f:
                    return f.read()
    #         return None

    #     def _cache_bytecode(self, file_path: str, bytecode: List[str]):
    #         """Cache bytecode."""
    #         if not self.cache_dir:
    #             return
    file_hash = self._get_file_hash(file_path)
    cache_file = self.cache_dir / f"{Path(file_path).stem}_{file_hash}.nbc"
    cache_file.parent.mkdir(parents = True, exist_ok=True)
    #         with open(cache_file, "w") as f:
                f.write("\n".join(bytecode))

    #     def _compile_single_file(
    self, source: str, file_path: Optional[str] = None
    #     ) -> List[str]:
    #         """Compile a single file/source."""
    self.stats.files_compiled + = 1
    cached = file_path and self._check_cache(file_path)
    #         if cached:
    #             self.warnings.append(f"Using cache for {file_path}")
                return cached.split("\n")

    lexer = self.get_component("lexer")
    parser = self.get_component("parser")
    semantic_analyzer = self.get_component("semantic_analyzer")
    code_generator = self.get_component("code_generator")

    self.errors = []
    self.warnings = []

    #         # Phase 1: Lexing
            self.stats.start_phase("lexing")
    #         # Create a new lexer with the actual content to avoid None issues
    #         print(f"DEBUG: Creating new lexer with content length: {len(source)}")
    lexer = Lexer(file_path or "<string>", source)
            print(f"DEBUG: Lexer created, self.content: {repr(lexer.content[:50])}")
    tokens = lexer.tokenize(source, file_path or "<string>")
            print(f"DEBUG: Tokenize called, tokens: {len(tokens)}")
            self.stats.end_phase("lexing", len(tokens))

    #         if self.errors:
                raise CompilationError("Lexing failed", "lexing")

    #         # Phase 2: Parsing
            self.stats.start_phase("parsing")
    ast = parser.parse_program()
    #         # Check for parsing errors
    #         if hasattr(parser, 'errors') and parser.errors:
    #             for err in parser.errors:
                    self.errors.append(
                        CompilationError(
                            str(err),
    #                         "parsing",
                            getattr(err, 'position', None),
    #                     )
    #                 )
    #         self.stats.end_phase("parsing", len(ast.children) if ast else 0)

    #         if self.errors:
                raise CompilationError("Parsing failed", "parsing")

    #         # Phase 3: Semantic Analysis
            self.stats.start_phase("semantic_analysis")
    #         try:
                semantic_analyzer.visit(ast)
    #             # TODO: Extract errors from semantic analyzer
    #         except Exception as e:
                self.errors.append(
                    CompilationError(f"Semantic analysis failed: {e}", "semantic_analysis")
    #             )
            self.stats.end_phase("semantic_analysis", len(self.global_symbol_table))

    #         if self.errors:
                raise CompilationError("Semantic analysis failed", "semantic_analysis")

    #         # Phase 4: Code Generation (with optional NIR)
            self.stats.start_phase("code_generation")
    #         try:
    #             if NIR_AVAILABLE and self.mode == "release":
    nir = NIRBuilder(semantic_analyzer.symbol_table).build_from_ast(
    #                     ast, semantic_analyzer.symbol_table
    #                 )
    nir = ConstantFoldingPass().run(nir)
    #                 if self.mode != "debug":
    nir = DeadCodeElimPass().run(nir)
    bytecode_instructions = code_generator.generate_from_nir(nir)
    #             else:
    bytecode_instructions = code_generator.generate(
    #                     ast, semantic_analyzer.symbol_table
    #                 )
    #             self.bytecode = [str(instr) for instr in bytecode_instructions]
    self.stats.instructions + = len(self.bytecode)
    #         except Exception as e:
                self.errors.append(
                    CompilationError(f"Code generation failed: {e}", "code_generation")
    #             )
            self.stats.end_phase("code_generation", len(self.bytecode))

    self.stats.errors = len(self.errors)
    #         if file_path:
                self._cache_bytecode(file_path, self.bytecode)
    #         return self.bytecode

    #     def compile_source(
    self, source: str, file_path: Optional[str] = None
    #     ) -> Tuple[List[str], List[CompilationError]]:
    #         """Compile single source string."""
    #         try:
    bytecode = self._compile_single_file(source, file_path)
    #             return bytecode, self.errors
    #         except CompilationError as e:
                self.errors.append(e)
    #             return [], self.errors

    #     def compile_file(self, file_path: str) -> Tuple[List[str], List[CompilationError]]:
    #         """Compile single file."""
            print(f"DEBUG: Reading file: {file_path}")
    #         with open(file_path, "r") as f:
    source = f.read()
            print(f"DEBUG: File content length: {len(source)}")
            print(f"DEBUG: File content preview: {repr(source[:100])}")
            return self.compile_source(source, file_path)

    #     def compile_files(
    #         self, file_paths: List[str]
    #     ) -> Tuple[List[str], List[CompilationError]]:
    #         """Compile multiple files, building global AST/symbols."""
    all_bytecode = []
    self.global_ast = ProgramNode([])
    self.global_symbol_table = {}
    self.errors = []
    self.warnings = []

    #         for path in file_paths:
    #             try:
    bc, errs = self.compile_file(path)
                    all_bytecode.extend(bc)
    #                 # Merge ASTs if needed
    #                 pass  # TODO: Implement proper AST merging
                    self.errors.extend(errs)
    #             except Exception as e:
                    self.errors.append(
                        CompilationError(f"File {path} failed: {e}", "orchestration")
    #                 )

    #         # Final global semantic pass if multi-file
    #         if len(file_paths) > 1 and not self.errors:
    semantic_analyzer = self.get_component("semantic_analyzer")
    #             try:
                    semantic_analyzer.visit(self.global_ast)
    #                 # TODO: Extract errors from semantic analyzer
    #             except Exception as e:
                    self.errors.append(
                        CompilationError(
    #                         f"Global analysis failed: {e}", "semantic_analysis"
    #                     )
    #                 )

    #         # Global code gen if needed
    #         if not self.errors and len(file_paths) > 1:
    code_generator = self.get_component("code_generator")
    global_bc = code_generator.generate(
    #                 self.global_ast, self.global_symbol_table
    #             )
    #             all_bytecode = [str(instr) for instr in global_bc]

    self.stats.errors = len(self.errors)
    self.stats.instructions = len(all_bytecode)
    #         return all_bytecode, self.errors

    #     def get_stats(self) -> Dict:
    #         """Get compilation statistics."""
            return self.stats.to_dict()

    #     def print_errors(self):
    #         """Print all errors."""
    #         for err in self.errors:
                print(err)

    #     def save_bytecode(self, output_path: str):
    #         """Save bytecode to file."""
    #         with open(output_path, "w") as f:
                f.write("\n".join(self.bytecode))

    #     def set_semantic_analyzer(self, analyzer):
    #         """Set the semantic analyzer, with fallback from error handler."""
    #         if analyzer is None:
    self._analyzer = SemanticVisitor()
    #         else:
    self._analyzer = analyzer
    #         # Update component if needed
            self.register_component("semantic_analyzer", self._analyzer)


