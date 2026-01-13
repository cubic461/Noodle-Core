# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# JavaScript FFI Module for NBC Runtime
# ------------------------------------
This module handles JavaScript Foreign Function Interface (FFI) operations.
# It provides functionality to load JavaScript modules and call JavaScript functions.
# """

import json
import traceback
import typing.Any,

import ...compiler.code_generator.BytecodeInstruction
import .config.NBCConfig
import .error_handler.ErrorHandler
import .errors.NBCRuntimeError,


class JavaScriptFFI
    #     """
    #     JavaScript Foreign Function Interface for NBC runtime.
    #     Handles loading JavaScript modules and calling JavaScript functions.
    #     """

    #     def __init__(self, config: NBCConfig = None):
    #         """
    #         Initialize JavaScript FFI.

    #         Args:
    #             config: Runtime configuration
    #         """
    self.config = config or NBCConfig()
    self.is_debug = getattr(self.config, 'debug_mode', False)

    #         # JavaScript modules dictionary
    self.js_modules: Dict[str, Any] = {}

    #         # JavaScript functions dictionary
    self.js_functions: Dict[str, Any] = {}

    #         # Constants pool
    self.constants_pool: Dict[str, str] = {}

    #         # Allowed JS modules for security
    self.allowed_js_modules = {
    #             "math", "crypto", "console", "setTimeout", "clearTimeout",
    #             "setInterval", "clearInterval", "fetch", "URL", "JSON"
    #         }

    #         # Error handler
    self.error_handler = ErrorHandler()

    #         # Initialize JavaScript FFI environment
            self.init_js_ffi()

    #     def init_js_ffi(self):
    #         """Initialize JavaScript FFI environment."""
    #         # Initialize JavaScript modules dictionary
    self.js_modules = {}

    #         # Initialize JavaScript functions dictionary
    self.js_functions = {}

    #         # Initialize constants pool
    self.constants_pool = {}

    #         # Pre-load allowed JS modules
            self._preload_allowed_js_modules()

    #     def _preload_allowed_js_modules(self):
    #         """Pre-load allowed JavaScript modules."""
    #         for module_name in self.allowed_js_modules:
    #             try:
    module = self._load_js_module(module_name)
    #                 if module:
    self.js_modules[module_name] = module

    #                     # Cache functions
                        self._cache_js_functions(module_name, module)

    #                     if self.is_debug:
                            print(f"Pre-loaded JavaScript module: {module_name}")
    #             except Exception as e:
    #                 if self.is_debug:
                        print(f"Warning: Could not preload JavaScript module {module_name}: {e}")

    #     def _load_js_module(self, module_name: str) -> Optional[Any]:
    #         """
    #         Load a JavaScript module.

    #         Args:
    #             module_name: Name of the module to load

    #         Returns:
    #             Loaded module or None if failed
    #         """
    #         try:
    #             # This would typically interface with a JavaScript runtime
    #             # For now, we'll return a placeholder
    #             if self.is_debug:
                    print(f"Loading JavaScript module: {module_name}")

    #             # Placeholder implementation
    #             # In a real implementation, this would interface with Node.js, browser, or other JS runtime
    #             return {"name": module_name, "loaded": True}

    #         except Exception as e:
    #             if self.is_debug:
                    print(f"Failed to load JS module {module_name}: {e}")
    #             return None

    #     def _cache_js_functions(self, module_name: str, module: Any):
    #         """
    #         Cache functions from a JavaScript module.

    #         Args:
    #             module_name: Name of the module
    #             module: The module object
    #         """
    #         try:
    #             # This would introspect the JS module for functions
    #             # For now, we'll use placeholder functions
    #             if module_name == "math":
    self.js_functions[f"{module_name}.sqrt"] = math.multiply(lambda x: x, * 0.5)
    self.js_functions[f"{module_name}.pow"] = math.multiply(lambda x, y: x, * y)
    #             elif module_name == "console":
    self.js_functions[f"{module_name}.log"] = print
    #             elif module_name == "json":
    self.js_functions[f"{module_name}.parse"] = json.loads
    self.js_functions[f"{module_name}.stringify"] = json.dumps

    #             if self.is_debug:
                    print(f"Cached functions from JS module: {module_name}")

    #         except Exception as e:
    #             if self.is_debug:
                    print(f"Warning: Could not cache JS functions from {module_name}: {e}")

    #     def js_import(self, operands: List) -> Any:
    #         """
    #         Execute JavaScript import/eval operation.

    #         Args:
    #             operands: List of operands, first should be code or module name

    #         Returns:
    #             Evaluated result or loaded module
    #         """
    #         if not operands or not isinstance(operands[0], str):
                raise JSFFIError("JavaScript import requires code or module name operand")

    code_or_module = operands[0]

    #         try:
    #             # Check if it's a module name (ends with .js or contains .)
    #             if code_or_module.endswith(".js") or "." in code_or_module:
    #                 # Assume module name
                    return self._load_js_module(code_or_module)
    #             else:
    #                 # Evaluate as JavaScript code
                    return self._evaluate_js_code(code_or_module)

    #         except Exception as e:
    #             if self.is_debug:
                    print(f"JavaScript import/eval failed: {e}")
                    print(f"Stack trace: {traceback.format_exc()}")
                raise JSFFIError(f"JavaScript import/eval failed: {e}")

    #     def _evaluate_js_code(self, code: str) -> Any:
    #         """
    #         Evaluate JavaScript code.

    #         Args:
    #             code: JavaScript code to evaluate

    #         Returns:
    #             Evaluation result
    #         """
    #         try:
    #             # This would interface with a JavaScript runtime
    #             # For now, we'll provide a basic evaluator for simple expressions

                # Basic expression evaluator (limited support)
    #             if code.strip().startswith("{") and code.strip().endswith("}"):
    #                 # JSON object
                    return json.loads(code)
    #             elif code.strip().startswith("[") and code.strip().endswith("]"):
    #                 # JSON array
                    return json.loads(code)
    #             elif code.strip().startswith('"') and code.strip().endswith('"'):
    #                 # String
                    return code.strip('"')
    #             elif code.strip().startswith("'") and code.strip().endswith("'"):
    #                 # String
                    return code.strip("'")
    #             elif code.strip().isdigit():
    #                 # Integer
                    return int(code.strip())
    #             elif code.replace(".", "", 1).isdigit():
    #                 # Float
                    return float(code.strip())
    #             elif code.lower() in ["true", "false"]:
    #                 # Boolean
    return code.lower() = = "true"
    #             elif code.lower() == "null":
    #                 # Null
    #                 return None
    #             elif code.lower() == "undefined":
    #                 # Undefined
    #                 return None
    #             else:
    #                 # Try to evaluate as expression
                    return self._evaluate_js_expression(code)

    #         except Exception as e:
    #             if self.is_debug:
                    print(f"Failed to evaluate JS code: {e}")
                raise JSFFIError(f"Failed to evaluate JS code: {e}")

    #     def _evaluate_js_expression(self, expression: str) -> Any:
    #         """
    #         Evaluate a JavaScript expression.

    #         Args:
    #             expression: JavaScript expression to evaluate

    #         Returns:
    #             Evaluation result
    #         """
    #         try:
    #             # This would interface with a JavaScript runtime
    #             # For now, we'll provide a very limited expression evaluator

    #             # Basic math operations
    #             if "+" in expression and not expression.startswith("+"):
    parts = expression.split("+")
    #                 if len(parts) == 2:
    left = self._evaluate_js_code(parts[0].strip())
    right = self._evaluate_js_code(parts[1].strip())
    #                     return left + right
    #             elif "-" in expression and not expression.startswith("-"):
    parts = expression.split("-")
    #                 if len(parts) == 2:
    left = self._evaluate_js_code(parts[0].strip())
    right = self._evaluate_js_code(parts[1].strip())
    #                     return left - right
    #             elif "*" in expression:
    parts = expression.split("*")
    #                 if len(parts) == 2:
    left = self._evaluate_js_code(parts[0].strip())
    right = self._evaluate_js_code(parts[1].strip())
    #                     return left * right
    #             elif "/" in expression:
    parts = expression.split("/")
    #                 if len(parts) == 2:
    left = self._evaluate_js_code(parts[0].strip())
    right = self._evaluate_js_code(parts[1].strip())
    #                     if right == 0:
                            raise JSFFIError("Division by zero")
    #                     return left / right

    #             # If we can't evaluate, return the expression as string
    #             return expression

    #         except Exception as e:
    #             if self.is_debug:
                    print(f"Failed to evaluate JS expression: {e}")
                raise JSFFIError(f"Failed to evaluate JS expression: {e}")

    #     def js_call(self, operands: List) -> Any:
    #         """
    #         Execute JavaScript function call operation.

    #         Args:
    #             operands: List of operands, first should be function name

    #         Returns:
    #             Function result or None
    #         """
    #         if not operands or not isinstance(operands[0], str):
                raise JSFFIError("JavaScript call requires function name operand")

    func_name = operands[0]

    #         # Parse function name as module.func
    #         if "." in func_name:
    module_name, actual_func_name = func_name.rsplit(".", 1)
    #         else:
    module_name = None
    actual_func_name = func_name

    #         # Extract arguments from operands
    args = []
    kwargs = {}

    #         if len(operands) > 1:
    #             num_args = operands[1] if isinstance(operands[1], int) else 0

                # Extract arguments from stack (this would be handled by the runtime)
    #             # For now, we'll assume args are provided in operands
    arg_start = 2
    #             for i in range(num_args):
    #                 if arg_start + i < len(operands):
                        args.append(operands[arg_start + i])

    #         try:
    #             # Get function reference
    #             if module_name:
    #                 # Call function from module
    #                 if module_name in self.js_modules:
    module = self.js_modules[module_name]
    #                     if actual_func_name in self.js_functions:
    func = self.js_functions[f"{module_name}.{actual_func_name}"]
    result = math.multiply(func(, args, **kwargs))

    #                         if self.is_debug:
                                print(f"Successfully called JavaScript function: {func_name}")

    #                         return result
    #                     else:
                            raise JSFFIError(f"Function {actual_func_name} not found in module {module_name}")
    #                 else:
                        raise JSFFIError(f"Module {module_name} not loaded")
    #             else:
    #                 # Call cached function
    #                 if func_name in self.js_functions:
    func = self.js_functions[func_name]
    result = math.multiply(func(, args, **kwargs))

    #                     if self.is_debug:
                            print(f"Successfully called JavaScript function: {func_name}")

    #                     return result
    #                 else:
                        raise JSFFIError(f"JavaScript function not found: {func_name}")

    #         except Exception as e:
    #             if self.is_debug:
    #                 print(f"JavaScript function call failed for {func_name}: {e}")
                    print(f"Stack trace: {traceback.format_exc()}")
    #             raise JSFFIError(f"JavaScript function call failed for {func_name}: {e}")

    #     def get_module_info(self, module_name: str) -> Dict[str, Any]:
    #         """
    #         Get information about a loaded module.

    #         Args:
    #             module_name: Name of the module

    #         Returns:
    #             Dictionary with module information
    #         """
    #         if module_name not in self.js_modules:
    #             return {"error": f"Module {module_name} not loaded"}

    module = self.js_modules[module_name]

    #         # Get module attributes
    attributes = []
    functions = []

    #         if module_name in self.js_functions:
    #             for func_name in self.js_functions:
    #                 if func_name.startswith(f"{module_name}."):
                        functions.append(func_name.split(".")[-1])

    #         return {
    #             "name": module_name,
    #             "loaded": True,
    #             "attributes": attributes,
    #             "functions": functions,
    #             "module_object": module
    #         }

    #     def get_function_info(self, func_name: str) -> Dict[str, Any]:
    #         """
    #         Get information about a cached function.

    #         Args:
    #             func_name: Name of the function

    #         Returns:
    #             Dictionary with function information
    #         """
    #         if func_name not in self.js_functions:
    #             return {"error": f"Function {func_name} not found"}

    func = self.js_functions[func_name]

    #         return {
    #             "name": func_name,
    #             "callable": True,
    #             "function_object": func,
                "type": type(func).__name__
    #         }

    #     def add_allowed_js_module(self, module_name: str):
    #         """
    #         Add a module to the allowed JavaScript modules list.

    #         Args:
    #             module_name: Name of the module to allow
    #         """
    #         if module_name not in self.allowed_js_modules:
                self.allowed_js_modules.add(module_name)

    #             # Try to load the module
    #             try:
    module = self._load_js_module(module_name)
    #                 if module:
    self.js_modules[module_name] = module
                        self._cache_js_functions(module_name, module)

    #                     if self.is_debug:
                            print(f"Successfully added and loaded JS module: {module_name}")
    #                 else:
    #                     # Module added but not loaded
    #                     if self.is_debug:
                            print(f"JS module {module_name} allowed but not loaded")
    #             except Exception as e:
    #                 if self.is_debug:
                        print(f"Warning: Could not load allowed JS module {module_name}: {e}")

    #     def remove_allowed_js_module(self, module_name: str):
    #         """
    #         Remove a module from the allowed JavaScript modules list.

    #         Args:
    #             module_name: Name of the module to disallow
    #         """
    #         if module_name in self.allowed_js_modules:
                self.allowed_js_modules.remove(module_name)

    #             # Remove from cache if loaded
    #             if module_name in self.js_modules:
    #                 del self.js_modules[module_name]

    #                 # Remove cached functions
    #                 functions_to_remove = [f"{module_name}.{func}" for func in dir(self.js_modules.get(module_name, {}))
    #                                      if callable(getattr(self.js_modules.get(module_name), func, None))]

    #                 for func_name in functions_to_remove:
    #                     if func_name in self.js_functions:
    #                         del self.js_functions[func_name]

    #                 if self.is_debug:
                        print(f"Removed JS module from cache: {module_name}")

    #     def get_allowed_js_modules(self) -> List[str]:
    #         """Get list of allowed JavaScript modules."""
            return list(self.allowed_js_modules)

    #     def get_loaded_js_modules(self) -> List[str]:
    #         """Get list of loaded JavaScript modules."""
            return list(self.js_modules.keys())

    #     def get_cached_js_functions(self) -> List[str]:
    #         """Get list of cached JavaScript functions."""
            return list(self.js_functions.keys())

    #     def reset(self):
    #         """Reset JavaScript FFI state."""
            self.js_modules.clear()
            self.js_functions.clear()
            self.constants_pool.clear()

    #         # Re-initialize
            self.init_js_ffi()


def create_javascript_ffi(config: NBCConfig = None) -> JavaScriptFFI:
#     """
#     Create a new JavaScript FFI instance.

#     Args:
#         config: Runtime configuration

#     Returns:
#         JavaScriptFFI instance
#     """
    return JavaScriptFFI(config)


__all__ = ["JavaScriptFFI", "create_javascript_ffi", "JSFFIError"]
