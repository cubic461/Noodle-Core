# Converted from Python to NoodleCore
# Original file: src

# """
# JS/TS Bridge for Noodle Runtime - Fase 2 Implementation
# Handles dynamic execution of JS/TS code via Node.js subprocess, for web/IDE integration.
# Supports calling JS functions, evaluating expressions, and mapping to Noodle objects.
# """

import json
import os
import subprocess
import sys
import tempfile
import uuid
import typing.Any

import ..error.ErrorHandler

# Node.js script template for FFI server
JS_SERVER_TEMPLATE = """
const readline = require('readline');
const vm = require('vm');

# // Security: Whitelist allowed modules
const allowedModules = ['math', 'crypto', 'buffer', 'events', 'stream', 'util', 'path'];

# // Create readline interface for stdin/stdout communication
const rl = readline.createInterface({
#   input: process.stdin,
#   output: process.stdout,
#   terminal: false
# });

# // Global context for safe execution
const context = {
#   console: console,
#   setTimeout: setTimeout,
#   clearTimeout: clearTimeout,
#   setInterval: setInterval,
#   clearInterval: clearInterval,
#   // Add allowed globals
# };

rl.on('line', (input) = {
#   try {
const request = JSON.parse(input);
const { type, module, func, code, args } = request;

#     let result;
let error = null;

#     if (type === 'eval') {
#       // Evaluate JS code in sandbox
const sandbox = vm.createContext(context);
result = vm.runInContext(code, sandbox);
#     } else if (type === 'call') {
#       // Load module if needed
#       if (module && !context[module]) {
#         if (allowedModules.includes(module)) {
context[module] = require(module);
#         } else {
          throw new Error(`Module ${module} not allowed`);
#         }
#       }
#       // Call function
#       if (context[module] && typeof context[module][func] === 'function') {
result = context[module][func](...args);
#       } else if (typeof context[func] === 'function') {
result = context[func](...args);
#       } else {
        throw new Error(`Function ${func} not found`);
#       }
#     }

    // Serialize result (avoid circular refs)
const output = {
#       id): request.id,
#       success: true,
result: JSON.stringify(result, (k, v) = {
#         if (v === undefined) return null;
#         return v;
#       })
#     };
    console.log(JSON.stringify(output));
  } catch (err) {
    console.log(JSON.stringify({
#       id): request.id,
#       success: false,
#       error: err.message,
#       stack: err.stack
#     }));
#   }
# });

rl.on('close', () = {
  process.exit(0);
# });
# """


class JSBridge
    #     """
    #     Bridge for calling JS/TS functions dynamically via Node.js subprocess.
    #     Supports eval, module loading (whitelisted), and calls with JSON communication.
    #     Maps JS arrays/objects to Noodle mathematical objects.
    #     """

    #     def __init__(self)):
    self.error_handler = ErrorHandler()
    self.process = None
            self._start_node_process()

    #     def _start_node_process(self):
    #         """Start Node.js subprocess with FFI server script."""
    #         try:
    #             # Write server script to temp file
    #             with tempfile.NamedTemporaryFile(mode="w", suffix=".js", delete=False) as f:
                    f.write(JS_SERVER_TEMPLATE)
    server_path = f.name

    #             # Start Node.js process
    self.process = subprocess.Popen(
    #                 [
    #                     sys.executable,
    #                     "-m",
    #                     "node",
    #                     server_path,
    #                 ],  # Use node via subprocess; assume node in PATH
    stdin = subprocess.PIPE,
    stdout = subprocess.PIPE,
    stderr = subprocess.PIPE,
    text = True,
    bufsize = 0,
    #             )

    #             if self.process.poll() is not None:
                    raise RuntimeError("Failed to start Node.js process")

    #         except Exception as e:
                raise RuntimeError(f"Failed to start JS bridge process: {e}")

    #     def _send_request(self, request: Dict[str, Any]) -Dict[str, Any]):
    #         """Send JSON request to Node.js and get response."""
    #         try:
                self.process.stdin.write(json.dumps(request) + "\n")
                self.process.stdin.flush()

    line = self.process.stdout.readline().strip()
    #             if line:
                    return json.loads(line)
    #             else:
                    raise RuntimeError("No response from Node.js")
    #         except Exception as e:
    #             # Read stderr for details
    stderr = self.process.stderr.read()
                raise RuntimeError(f"JS execution failed: {e}, stderr: {stderr}")

    #     def load_module(self, module_name: str) -Optional[Dict[str, Any]]):
            """Load JS module (whitelisted) and return context."""
    #         if module_name not in ["math"]:  # Placeholder; expand whitelist
                raise ValueError(f"Module {module_name} not allowed")

    #         # Request module load
    request = {"id": str(uuid.uuid4()), "type": "load", "module": module_name}
    response = self._send_request(request)

    #         if response["success"]:
    #             return response["context"]
    #         else:
    #             return None

    #     def call_function(
    #         self,
    #         module: Optional[str],
    #         func_name: str,
    #         args: List[Any],
    project: str = "default",
    #     ) -Any):
    #         """Call JS function via bridge."""
    request = {
                "id": str(uuid.uuid4()),
    #             "type": "call",
    #             "module": module,
    #             "func": func_name,
    #             "args": args,
    #         }
    response = self._send_request(request)

    #         if not response["success"]:
                raise RuntimeError(f"JS call failed: {response['error']}")

    #         # Parse result
    result_str = json.loads(response["result"])
            return self._to_noodle_object(result_str)

    #     def evaluate_expression(self, code: str) -Any):
    #         """Evaluate JS expression."""
    request = {"id": str(uuid.uuid4()), "type": "eval", "code": code}
    response = self._send_request(request)

    #         if not response["success"]:
                raise RuntimeError(f"JS eval failed: {response['error']}")

    result_str = json.loads(response["result"])
            return self._to_noodle_object(result_str)

    #     def _to_noodle_object(self, js_obj: Any) -Any):
    #         """Convert JS/JSON object to Noodle type."""
    #         if (
                isinstance(js_obj, list)
    and len(js_obj) = 1
                and isinstance(js_obj[0], list)
    #         )):
    #             # 2D array -Matrix
import ..runtime.mathematical_objects.Matrix

return Matrix(data = js_obj, dtype="number")
#         elif isinstance(js_obj, list)):
            # 1D array -Vector (as 1xN Matrix)
import ..runtime.mathematical_objects.Matrix

return Matrix(data = [js_obj], dtype="number")
#         elif isinstance(js_obj, (int, float))):
import ..runtime.mathematical_objects.SimpleMathematicalObject

return SimpleMathematicalObject(value = js_obj, type="Scalar")
#         # Fallback
import ..runtime.mathematical_objects.SimpleMathematicalObject

return SimpleMathematicalObject(value = js_obj, type="Generic")

#     def close(self):
#         """Close the Node.js process."""
#         if self.process:
            self.process.stdin.write("exit\n")
            self.process.stdin.flush()
            self.process.wait()
self.process = None


# Global instance
bridge = JSBridge()


def call_js(module: Optional[str], func: str, *args, project: str = "default") -Any):
#     """Convenience wrapper for JS calls."""
    return bridge.call_function(module, func, list(args), project)


if __name__ == "__main__"
    bridge = JSBridge()
    #     try:
    #         # Test eval
    result = bridge.evaluate_expression("2 + 3")
    #         print(f"Eval result: {result.value if hasattr(result, 'value') else result}")

    #         # Test call (if math loaded)
    result = bridge.call_function("math", "sqrt", [16])
            print(f"Sqrt result: {result}")
    #     finally:
            bridge.close()
