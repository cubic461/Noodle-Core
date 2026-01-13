# JS/TS Runtime Bridge Implementation

## Overview
This document details the implementation of Fase 2: JS/TS Bridge in Stap 10 of the Noodle roadmap. The bridge provides Node.js FFI for web/IDE integration, using subprocess with JSON communication for dynamic JS/TS execution.

## Key Features
- **Secure Execution**: Node.js subprocess with vm sandbox, whitelisted modules (math, crypto, etc.) to prevent malicious code.
- **Dynamic Calls and Eval**: `call_function()` for module.func calls, `evaluate_expression()` for code snippets.
- **Object Mapping**:
  - JS -> Noodle: Arrays to `Matrix` (2D/1D), numbers to `SimpleMathematicalObject`.
  - Supports JSON serialization to handle complex structures.
- **NBC Integration**: New opcodes `JS_IMPORT` (load/eval JS code/module) and `JS_CALL` (call functions), with auto-conversion on stack push.
- **Communication**: JSON over stdin/stdout; handles errors, serialization.

## Usage Example
In Noodle bytecode:
- Import/Eval: `JS_IMPORT "Math.sqrt(25)"` evaluates and pushes result (SimpleMathematicalObject with 5.0).
- Call: `JS_CALL "math.sqrt" (1 arg: 16)` calls and pushes converted result.

In Python:
```python
from noodle.runtime.interop.js_bridge import call_js
result = call_js(None, 'Math.sqrt', [25])  # Evaluates as SimpleMathematicalObject(5.0)
print(result.value)  # 5.0
```

For modules: `call_js('crypto', 'randomBytes', [16])` (if whitelisted).

## Testing
Integration tests in `tests/integration/test_js_bridge_integration.py` verify eval (e.g., "2 + 3" → 5), expressions (Math.sqrt), arrays to Matrix, and NBC opcode integration.

## Limitations and Security
- Limited to whitelisted modules; no filesystem/network access in sandbox.
- Subprocess overhead; suitable for occasional web/IDE calls.
- TS support via transpilation not implemented (Fase 3).

## Future Extensions (Fase 3+)
- Direct Node.js embedding (e.g., via pyv8 if available).
- TypeScript transpilation and AST intent translation.
- Bi-directional calls (JS calling Noodle via FFI).

## Status
✅ Implemented and integrated. Ready for Fase 3.

Last updated: 2025-09-25
