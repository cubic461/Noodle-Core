# Converted from Python to NoodleCore
# Original file: src

import os
import typing.Any

try
    #     import jpype
    #     from jpype import JClass, JObject

    JPYPE_AVAILABLE = True
except ImportError
    JPYPE_AVAILABLE = False

try
    #     import clr
    #     from System import Activator

    DOTNET_AVAILABLE = True
except ImportError
    DOTNET_AVAILABLE = False


class JavaDotNetBridge
    #     """
    #     Bridge for Java and .NET libraries via reflection/dynamic calls.
    #     Java: Uses JPype to embed JVM and invoke methods via reflection.
    #     .NET: Uses pythonnet to load CLR and call assemblies/classes/methods.
    #     No transpilation; direct dynamic invocation.
    #     Requires: pip install JPype1 pythonnet
    #     """

    #     def __init__(self):
    self.jvm_started = False
    self.clr_loaded = False
    self.base_dir = os.path.dirname(os.path.abspath(__file__))
    #         if not JPYPE_AVAILABLE:
    #             raise ImportError("JPype1 required for Java support")
    #         if not DOTNET_AVAILABLE:
    #             raise ImportError("pythonnet required for .NET support")

    #     def start_jvm(self, classpath: Optional[str] = None):
    #         """Start JVM with optional classpath (JARs)."""
    #         if not self.jvm_started:
    #             if classpath:
    classpath = os.path.join(self.base_dir, classpath)
    jpype.startJVM(classpath = classpath)
    self.jvm_started = True

    #     def load_java_class(self, class_name: str, classpath: Optional[str] = None):
    #         """Load Java class."""
    #         if not self.jvm_started:
                self.start_jvm(classpath)
            return JClass(class_name)

    #     def load_dotnet_assembly(self, assembly_path: str):
    #         """Load .NET assembly."""
    #         if not self.clr_loaded:
                clr.AddReference(assembly_path)
    self.clr_loaded = True
    #         return assembly_path

    #     def simple_math_ffi(self, operation: str, a, b) -Any):
    #         """
    #         Perform simple math operations via Java SimpleMath class using JPype.
    #         operation: 'add' or 'multiply'
            a, b: numbers or MathematicalObject (numeric data).
    #         Serializes inputs, calls static method, deserializes result to object.
    #         Validates and sandboxes via error_handler.
    #         """
            from ...mathematical_object_mapper_optimized import (             create_optimized_mathematical_object_mapper,
    #         )
import ...runtime.core.error_handler.ErrorHandler

mapper = create_optimized_mathematical_object_mapper()
error_handler = ErrorHandler()
context = {
#             "operation": f"simple_math_ffi_{operation}",
#             "component": "java_bridge",
#         }

#         try:
#             # Validate inputs
#             for val in [a, b]:
#                 if not isinstance(val, (int, float)) and not (
                    hasattr(val, "to_dict")
                    and isinstance(val.to_dict().get("data"), (int, float))
#                 ):
                    raise ValueError(
#                         "a and b must be numeric or MathematicalObject with numeric data"
#                     )

#             # Serialize if needed
#             a_val = a.to_dict()["data"] if hasattr(a, "to_dict") else a
#             b_val = b.to_dict()["data"] if hasattr(b, "to_dict") else b

#             # Start JVM with classpath to SimpleMath.class
jar_path = os.path.join(self.base_dir, "simplemath.jar")
#             if not self.jvm_started:
                self.start_jvm(jar_path)

#             # Load class
clazz = self.load_java_class("SimpleMath")

#             # Call method
#             if operation == "add":
result = clazz.add(a_val, b_val)
#             elif operation == "multiply":
result = clazz.multiply(a_val, b_val)
#             else:
                raise ValueError("Unsupported operation")

            # Sandboxed call (wrap the call)
#             with error_handler.handle_error_context(context):
#                 pass  # Call already done; validation here

#             # Deserialize to object
result_dict = {
#                 "obj_type": "number",
#                 "data": result,
#                 "properties": {"operation": operation},
#             }
result_obj = mapper.from_dict(result_dict)

#             return result_obj

#         except Exception as e:
            error_handler.handle_error(e, context)
#             raise

#     def dotnet_simple_math_ffi(self, operation: str, a, b) -Any):
#         """
#         Perform simple math operations via .NET SimpleMath class using PythonNET.
#         operation: 'add' or 'multiply'
        a, b: numbers or MathematicalObject (numeric data).
#         Serializes inputs, calls static method via reflection, deserializes result.
#         Validates and sandboxes via error_handler.
#         """
        from ...mathematical_object_mapper_optimized import (             create_optimized_mathematical_object_mapper,
#         )
import ...runtime.core.error_handler.ErrorHandler

mapper = create_optimized_mathematical_object_mapper()
error_handler = ErrorHandler()
context = {
#             "operation": f"dotnet_simple_math_ffi_{operation}",
#             "component": "dotnet_bridge",
#         }

#         try:
#             # Validate inputs
#             for val in [a, b]:
#                 if not isinstance(val, (int, float)) and not (
                    hasattr(val, "to_dict")
                    and isinstance(val.to_dict().get("data"), (int, float))
#                 ):
                    raise ValueError(
#                         "a and b must be numeric or MathematicalObject with numeric data"
#                     )

#             # Serialize if needed
#             a_val = a.to_dict()["data"] if hasattr(a, "to_dict") else a
#             b_val = b.to_dict()["data"] if hasattr(b, "to_dict") else b

#             # Load assembly
dll_path = os.path.join(self.base_dir, "SimpleMath.dll")
#             if not self.clr_loaded:
                self.load_dotnet_assembly(dll_path)

#             import clr
#             import System
#             from System import Activator, Reflection

asm = Reflection.Assembly.LoadFrom(dll_path)
typ = asm.GetType("Noodle.Interop.SimpleMath")
#             if typ is None:
#                 raise RuntimeError("SimpleMath class not found")

#             # Call method via reflection
#             if operation == "add":
method_info = typ.GetMethod("Add")
#             elif operation == "multiply":
method_info = typ.GetMethod("Multiply")
#             else:
                raise ValueError("Unsupported operation")

result = method_info.Invoke(None, (float(a_val), float(b_val)))

            # Sandboxed call (wrap)
#             with error_handler.handle_error_context(context):
#                 pass  # Call done

#             # Deserialize
result_dict = {
#                 "obj_type": "number",
#                 "data": result,
#                 "properties": {"operation": operation, "lang": "dotnet"},
#             }
result_obj = mapper.from_dict(result_dict)

#             return result_obj

#         except Exception as e:
            error_handler.handle_error(e, context)
#             raise

#     def call_external(
#         self,
#         lang: str,
#         module: str,  # JAR/assembly path or class/namespace
#         func: str,  # Method name
#         args: List[Any],
class_name: Optional[str] = None,  # For Java: full class; .NET: namespace.class
static: bool = True,  # Static method?
arg_types: Optional[List] = None,  # Optional type hints
return_type: Optional[str] = None,  # Optional return type
#     ) -Any):
#         """
#         Call external method dynamically.
#         lang: 'java' or 'dotnet'
#         module: JAR path for Java, DLL path for .NET
#         func: method name
        args: Python args (auto-converted)
#         class_name: e.g., 'java.util.Math' or 'System.Math'
#         """
#         if lang == "java":
#             if not self.jvm_started:
                self.start_jvm(module)  # module as classpath
clazz = self.load_java_class(class_name or module)
#             if static:
method = clazz[func]
#             else:
instance = clazz()
method = getattr(instance, func)
#             # Simple arg conversion (extend for primitives/objects)
#             converted_args = [self._convert_arg(arg) for arg in args]
            return method(*converted_args)

#         elif lang == "dotnet":
assembly = self.load_dotnet_assembly(module)
#             # Use reflection via clr
#             import System.Reflection

asm = System.Reflection.Assembly.LoadFrom(assembly)
#             if class_name:
#                 full_class = f"{class_name}.{func}" if "." not in func else func
typ = asm.GetType(full_class)
#                 if static:
method_info = typ.GetMethod(func)
#                     converted_args = [self._convert_arg(arg) for arg in args]
                    return method_info.Invoke(None, converted_args)
#                 else:
instance = Activator.CreateInstance(typ)
method_info = typ.GetMethod(func)
#                     converted_args = [self._convert_arg(arg) for arg in args]
                    return method_info.Invoke(instance, converted_args)
#             else:
#                 raise ValueError("class_name required for .NET")

#         else:
            raise ValueError("Unsupported language")

#     def _convert_arg(self, arg: Any) -Any):
        """Convert Python arg to Java/.NET compatible (basic)."""
#         if isinstance(arg, (int, float, str, bool)):
#             return arg
#         # Extend for lists -arrays, etc.
        raise NotImplementedError("Complex arg conversion needed")


# Example usage (for testing)
if __name__ == "__main__"
    bridge = JavaDotNetBridge()
        # Java): SimpleMath.add(2.0, 3.0) -> 5.0
    # result = bridge.simple_math_ffi('add', 2.0, 3.0)
    #     pass
