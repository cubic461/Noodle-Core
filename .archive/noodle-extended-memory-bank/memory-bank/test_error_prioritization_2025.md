# Test Error Prioritization for Fixing Remaining 74 Pytest Errors

## Date: 2025-09-26

### Overview
This document outlines the prioritization of the 74 errors found when running `pytest noodle-dev/tests/ -v --tb=short`. The goal is to fix these systematically, starting with high-impact core modules to resolve cascading issues.

### Error Categories from Pytest Output (74 errors total)

#### Category 1: ImportError / ModuleNotFoundError (Approx. 45 errors - HIGH PRIORITY)
**Description**: Failures to import modules, often due to relative imports, missing modules, or incorrect paths. These often block entire test suites from running.
**Affected Areas**:
- Core runtime (NBC runtime, distributed systems)
- Database components (mappers, connection managers)
- Compiler and parser modules
- Utility modules (error handling, interop)

**Specific Errors**:
- `ImportError: cannot import name 'NoodleErrorHandler' from 'noodle.utils.error_handler'`
- `ImportError: attempted relative import with no known parent package` (in `mathematical_objects.py`, `compiler.py`)
- `ModuleNotFoundError: No module named 'noodle.lexer'`
- `ImportError: cannot import name 'MathematicalObjectMapperError' from 'noodle.database.mappers.mathematical_object_mapper'`
- `ImportError: cannot import name 'run_bytecode' from 'noodle.runtime.nbc_runtime'`
- `ModuleNotFoundError: No module named 'noodle.runtime.nbcl_runtime'`
- `ImportError: cannot import name 'CodeGenerationError' from 'noodle.compiler.code_generator'`
- `ImportError: cannot import name 'DatabaseBackend' from 'noodle.runtime.nbc_runtime.database'`

#### Category 2: AttributeError (Approx. 15 errors - HIGH PRIORITY)
**Description**: Missing attributes, classes, or methods on imported objects. Often follows import issues or incomplete definitions.
**Affected Areas**:
- Runtime configuration and distributed systems
- Code generation and compiler components
- Backend implementations

**Specific Errors**:
- `AttributeError: module 'scheduler' has no attribute 'SchedulingStrategy'`
- `NameError: name 'LazyLoader' is not defined`
- `AttributeError: 'NoodleCompiler' object has no attribute 'set_code_generator'`
- `AttributeError: module 'noodle.runtime.distributed.cluster_manager' has no attribute 'ClusterTopology'`

#### Category 3: SyntaxError (Approx. 10 errors - MEDIUM PRIORITY)
**Description**: Python syntax issues in test files or source code. These prevent proper parsing and test collection.
**Affected Areas**:
- Test files (e.g., `test_compiler_error_handling.py`, `test_serialization_deserialization_performance.py`)
- Source files (e.g., `execution_validation.py`)

**Specific Errors**:
- `SyntaxError: unterminated string literal (detected at line 542)` in `test_compiler_error_handling.py`
- `SyntaxError: invalid syntax. Maybe you meant '==' or ':=' instead of '='?` in `test_serialization_deserialization_performance.py`
- `SyntaxError: invalid syntax` in `src/noodle/validation/execution_validation.py` line 713

#### Category 4: Other (Approx. 4 errors - LOW/MEDIUM PRIORITY)
**Description**: Includes issues like missing base classes, deprecated features, or misconfigurations.
**Affected Areas**:
- Pydantic validators (deprecated V1 style)
- Backend registration errors
- Type hinting issues

**Specific Errors**:
- `PydanticDeprecatedSince20: Pydantic V1 style ' @validator ' validators are deprecated...`
- `Can't instantiate abstract class CuPyBackend without an implementation for abstract methods...`

### Prioritized Fixing Order

#### Phase 1: Core Import and Definition Fixes (Target ~25-30 errors)
*Focus: Resolve issues that block test collection or break core functionality.*
1.  **Fix relative imports in core modules:**
    *   `noodle-dev/src/noodle/runtime/mathematical_objects.py`
    *   `noodle-dev/src/noodle/compiler/compiler.py`
    *   `noodle-dev/src/noodle/ai_orchestrator/ai_orchestrator.py`
    *   *Action: Convert to absolute imports or ensure correct package structure.*
2.  **Define missing core classes/errors:**
    *   `NoodleErrorHandler` in `noodle-dev/src/noodle/utils/error_handler.py`
    *   `MathematicalObjectMapperError` and `SchemaValidationError` in `noodle-dev/src/noodle/database/mappers/mathematical_object_mapper.py`
    *   `CodeGenerationError` in `noodle-dev/src/noodle/compiler/code_generator.py`
    *   `SchedulingStrategy` enum in `noodle-dev/src/noodle/runtime/distributed/scheduler.py` (or import from correct module)
    *   `LazyLoader` utility (likely in `noodle-dev/src/noodle/runtime/interop/` or similar)
    *   `set_code_generator` method in `noodle-dev/src/noodle/compiler/compiler.py`
    *   `ClusterTopology` in `noodle-dev/src/noodle/runtime/nbc_runtime/distributed/cluster_manager.py`
3.  **Fix syntax errors:**
    *   `noodle-dev/tests/error_handling/test_compiler_error_handling.py` (line 542, unterminated string)
    *   `noodle-dev/tests/performance/test_serialization_deserialization_performance.py` (line 542, invalid assignment)
    *   `noodle-dev/src/noodle/validation/execution_validation.py` (line 713, invalid syntax)
4.  **Resolve missing module errors:**
    *   Ensure `noodle.lexer` is correctly defined/available (possibly from `noodle-dev/src/noodle/compiler/lexer.py`).
    *   Check `noodle.runtime.nbcl_runtime` path and existence.
    *   Ensure `noodle.runtime.nbc_runtime.database` exports `DatabaseBackend`.

#### Phase 2: Enhanced Import Management and Backend Fixes (Target ~20-25 errors)
*Focus: Use ImportManager for lazy loading, handle backend dependencies, and fix remaining imports.*
1.  **Integrate/Enhance ImportManager:**
    *   Ensure `noodle-dev/src/noodle/runtime/nbc_runtime/core/conditional_imports.py` is robust.
    *   Replace problematic static imports in core modules with `import_manager.lazy_import()` where appropriate (e.g., in `noodle-dev/src/noodle/runtime/nbc_runtime/core/merge_integration.py`, `noodle-dev/src/noodle/runtime/nbc_runtime/core/sandbox_integration.py`).
    *   Add logging to `ImportManager` for better debugging of import failures.
2.  **Address Backend Registration Issues:**
    *   For `CuPyBackend`, `PyTorchBackend`, `TensorFlowBackend`: Either implement abstract methods or mock them for testing purposes if full implementation is out of scope.
    *   Ensure graceful handling of missing backend dependencies.
3.  **Fix remaining ImportErrors/AttributeErrors:**
    *   `run_bytecode` in `noodle-dev/src/noodle/runtime/nbc_runtime/__init__.py`
    *   `OpCode` in `noodle-dev/src/noodle/runtime/nbc_runtime/__init__.py`
    *   `RuntimeConfig` in `noodle-dev/src/noodle/runtime/nbc_runtime/__init__.py`
    *   `DatabaseConnectionManager` in `noodle-dev/src/noodle/database/__init__.py`
    *   `ConnectionPool` in `noodle-dev/src/noodle/runtime/nbc_runtime/database/__init__.py`
    *   `AsyncRuntime` in `noodle-dev/src/noodle/runtime/nbc_runtime/core/async_runtime.py`

#### Phase 3: Test-Specific and Deprecation Fixes (Target ~15-20 errors)
*Focus: Fix test files, deprecation warnings, and peripheral modules.*
1.  **Fix test file imports and syntax:**
    *   Go through each failing test file identified in the pytest output and correct imports.
    *   Update relative imports within test files to use `import_manager` or absolute paths.
2.  **Migrate deprecated Pydantic V1 validators:**
    *   `noodle-dev/src/noodle/runtime/nbc_runtime/core/sandbox_integration.py` (lines 43, 51)
    *   Replace `@validator` with `@field_validator`.
3.  **Address other module-level issues:**
    *   `get_mathematical_object_type` in `noodle-dev/src/noodle/runtime/nbc_runtime/math/__init__.py`
    *   `optimize_mathematical_object_operations` in `noodle-dev/src/noodle/runtime/nbc_runtime/mathematical_objects.py`
    *   `ProfilingConfig` in `noodle-dev/src/noodle/runtime/resource_monitor.py`
    *   `parse_string` and various `NodeType`s in `noodle-dev/src/noodle/compiler/parser.py`
4.  **Handle missing examples or demo modules:**
    *   `ModuleNotFoundError: No module named 'examples'` in `noodle-dev/tests/integration/test_distributed_poc.py`
    *   Ensure `examples.distributed_poc.demo` is accessible or mock it.

#### Phase 4: Validation and Cleanup
*Focus: Ensure all errors are resolved and document changes.*
1.  **Run full test suite:** `pytest noodle-dev/tests/ -v --tb=short` and verify errors are resolved.
2.  **Address any remaining issues:** Tackle any last errors that surface.
3.  **Update documentation:**
    *   Log all fixes in `memory-bank/full_test_suite_fixes_changelog_2025.md`.
    *   Update `memory-bank/import_fixes_changelog_2025.md` with a summary of the broader fixes.
4.  **Consider pre-commit hooks:** Add or update linting rules (e.g., flake8, isort) to catch import issues early.

### Success Metrics
- **Short-term:** Reduce the 74 errors to <20 after Phase 1-2, and <5 after Phase 3.
- **Long-term:** Achieve a passing state for the entire test suite where feasible, or clearly identify and document out-of-scope items.

### Notes
- The ImportManager (`noodle-dev/src/noodle/runtime/nbc_runtime/core/conditional_imports.py`) will be a key tool, especially for Phase 2.
- Some errors might be interconnected; fixing one might resolve others.
- If an error seems too complex or requires a large implementation outside the scope of "fixing," it can be marked as a low-priority item or a future task.
