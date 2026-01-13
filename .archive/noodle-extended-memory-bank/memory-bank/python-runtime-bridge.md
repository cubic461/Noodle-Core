# Python Runtime Bridge Implementation

## Overview
This document details the implementation of Fase 1: Python Bridge in Stap 10 of the Noodle roadmap. The bridge enables FFI for Python objects to NBC, allowing dynamic imports like `import python; numpy = python.import("numpy")`.

## Key Features
- **Dynamic Module Loading**: Uses `importlib` via `PythonBridge.load_module()` for on-demand imports.
- **Function Calls**: `call_external()` handles introspection, execution, and logging via UsageCollector for ALE.
- **Object Mapping**:
  - Python -> Noodle: numpy arrays to `Matrix`, scalars to `SimpleMathematicalObject`, lists to vectors.
  - Noodle -> Python: `Matrix` to numpy array, scalars to native types.
- **NBC Integration**: Opcodes `PYTHON_IMPORT` and `PYTHON_CALL` now use the bridge, with auto-conversion on stack push.
- **Security**: Limited to allowed modules (math, numpy, pandas, etc.); forbidden modules prevented.

## Usage Example
In Noodle bytecode:
- Import: `PYTHON_IMPORT "numpy"` loads module, pushes to stack.
- Call: `PYTHON_CALL "numpy.array" (1 arg: list)` returns `Matrix` object.

In Python:
```python
from noodle.runtime.interop.python_bridge import call_python
result = call_python('numpy', 'zeros', (2, 2), noodle_runtime=runtime)  # Returns Matrix
```

## Testing
Integration tests in `tests/integration/test_python_bridge_integration.py` verify imports, calls, and conversions (numpy array to Matrix, math.sqrt to SimpleMathematicalObject).

## Future Extensions (Fase 2+)
- JS/TS bridges.
- AST-based transpilation.
- Extended type mappings (e.g., pandas to TableObject).

## Status
✅ Implemented and integrated. Ready for Fase 2.

Last updated: 2025-09-25
