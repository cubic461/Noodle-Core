# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Java FFI Bridge using JPype.
# Assumes SimpleMath.jar with class SimpleMath containing static double add(double a, double b).
# User needs to compile Java class and place JAR in path.
# """

try
    #     import jpype

    JPYPE_AVAILABLE = True
except ImportError
    JPYPE_AVAILABLE = False
    jpype = None

import typing.Any,

import ...runtime.mathematical_objects.MathematicalObject,


class JavaBridge
    #     """Java FFI Bridge using JPype."""

    #     def __init__(self):
    #         if not JPYPE_AVAILABLE:
                raise ImportError("JPype not installed. Install with: pip install JPype1")

    #         # Lazy initialization of JVM
    #         if not jpype.isJVMStarted():
    #             try:
                    jpype.startJVM()
                    jpype.addDefaultXMLTransform()
    #             except Exception as e:
                    raise ImportError(f"Failed to start JVM: {e}")

    #         # Assume SimpleMath.jar is available
    jar_path = "examples/interop/SimpleMath.jar"  # Placeholder; user to provide
    #         try:
                jpype.JClass("java.lang.System").loadLibrary(jar_path)
    self.SimpleMath = jpype.JClass("SimpleMath")
    #         except Exception:
                raise ImportError(
    #                 f"Java class not found. Compile SimpleMath.java to JAR at {jar_path}."
    #             )

    #     def call_external(self, module: str, func: str, args: List[Any]) -> Any:
    #         """Call Java function."""
    #         if func == "add":
    #             if len(args) != 2:
                    raise ValueError("add requires 2 arguments")
    a, b = float(args[0]), float(args[1])
                return self.SimpleMath.add(a, b)
    #         else:
                raise ValueError(f"Unknown Java function: {func}")

    #     def serialize_args(
    #         self, args: List[Any], mapper: MathematicalObjectMapper
    #     ) -> List[Any]:
    #         """Serialize args for Java (primitives)."""
    #         return [float(arg) if isinstance(arg, (int, float)) else arg for arg in args]

    #     def deserialize_result(
    self, result: Any, mapper: MathematicalObjectMapper, expected_type: str = None
    #     ) -> Any:
    #         """Deserialize result from Java."""
    #         return float(result) if expected_type == "scalar" else result
