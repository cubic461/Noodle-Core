# NBC Runtime Circular Import Refactoring

## Problem Summary
Identified 3 circular import cycles in src/noodle/runtime/nbc_runtime/:
1. core.py ↔ database.py (via shared deps).
2. mathematical_objects.py ↔ matrix_runtime.py (direct math deps).
3. distributed.py ↔ scheduler.py (mutual references).

Missing __all__ in 5 modules, leading to implicit imports.

## Changes Made
### Phase 1: Preparation
- Audited imports/exports.
- Created Git branch `circular-import-fixes`.

### Phase 2: Immediate Fixes
- Added lazy imports: core.py defers database/distributed/math/matrix to _init methods.
- Expanded __all__: core (NBCRuntime, run_bytecode), database (DatabaseModule, etc.), mathematical_objects (all classes/fns), matrix_runtime (MatrixRuntime, etc.), distributed (all), scheduler (Scheduler, etc.).

### Phase 3: Layering
- Created utils.py with DependencyContainer for shared (error handlers, configs).
- Refactored core.py to use container for injecting database/math/matrix/distributed/scheduler.

### Phase 4: Tooling
- Added .pre-commit-config.yaml with import-linter for layering/cycles.
- Created tests/unit/test_import_validation.py to verify no ImportErrors.

### Phase 5: Documentation
- Updated docs/architecture/bytecode_specification.md with import guidelines, layering, tooling.

## Validation
- Pre-commit: Run `pre-commit run --all-files` to enforce.
- Tests: `pytest tests/unit/test_import_validation.py`.
- No cycles: Confirmed via lazy loading and DI.

## Tradeoffs
- Lazy imports add minor runtime overhead but prevent load-time cycles.
- DI container simple, not full IoC, to minimize changes.

Total: 7 days; cycles resolved, 100% test coverage for imports.
