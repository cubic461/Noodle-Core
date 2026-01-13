# Python to Noodle Transpiler Roadmap

## Overview
The transpiler enables translating Python code to Noodle syntax, allowing seamless migration of libraries and scripts. Initial prototype handles basic structures (functions, loops, assigns) and simple library mappings.

## Phase 1: Basic Prototype (Completed)
- **Parser**: PythonToNoodle class handles Module, FunctionDef, Assign, For, Return, Expr (BinOp, Num, Name, Call).
- **Translator**: Applies syntax mapping and library stubs (NumPy -> noodle.math, Pandas -> noodle.dataframe).
- **Generator**: Writes translated code to .ndl files.
- **Adapters**: Basic stubs for NumPy (dot, array, fft) and Pandas (DataFrame, groupby, merge).
- **Tests**: Unit tests for basic function, loop, and library translation.
- **Files**: `transpiler/python/parser.py`, `translator.py`, `generator.py`, `adapters/`, `tests/test_transpiler.py`.

## Phase 2: Advanced Translation
- Handle imports and more AST nodes (if/else, classes, conditionals).
- Deep library integration: Use AST inspection voor meer accurate replacements; integreer semantische intent-herkenning via intent_mapper.py om patronen te identificeren (bijv. numpy.dot → matrix_multiplication intent).
- Intent-based mapping: Bouw een mapping-tabel voor NumPy/Pandas intents; genereer Intent IR als brug tussen Python AST en Noodle code.
- Error handling for unsupported constructs; fallback naar letterlijke syntax-vertaling als intent niet herkend wordt.
- CLI tool: `noodle transpile input.py -o output.ndl`; voeg optie toe voor semantic_mode.

## Phase 3: Optimization and Integration
- Integrate with Noodle runtime voor execution benchmarking; test intent-gebaseerde vs. template-vertalingen op performance.
- IDE plugin: Full "Convert to Noodle" with diff preview, inclusief intent-IR visualisatie.
- Support for additional libraries from user prompt (Fase 2: Scikit-learn, etc.); uitbreiden intent-mappings.

## Phase 4: Self-Improving Semantic Layer
- Logging van intent usage en prestaties via PerformanceMonitor.
- Automatische optimalisatie: Vervang wrappers met native kernels op basis van frequentie en benchmarks.
- Cross-language extensie: Intent mappers voor JS/TS integreren met JS Bridge.
- Global Registry integratie: Deel intent-mappings en optimalisaties across projects/clusters.

## Dependencies
- Python AST module (standard library).
- Extend for Pandas (already stubbed).

## Next Deliverables
- Extend parser for classes, conditionals.
- Add more comprehensive tests.
- Integrate with benchmarks: Auto-generate Noodle code and run vs Python.
- IDE enhancements: Button in VS Code to run transpiler on open file.

Status: Prototype operational; ready for extension.
