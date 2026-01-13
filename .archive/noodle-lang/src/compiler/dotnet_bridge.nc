# Converted from Python to NoodleCore
# Original file: src

# """
# .NET FFI Bridge using pythonnet.
# Assumes SimpleMath.dll with class SimpleMath containing static double add(double a, double b).
# User needs to compile C# class and place DLL in path.
# """

try
    #     import clr

    DOTNET_AVAILABLE = True
except ImportError
    DOTNET_AVAILABLE = False
    clr = None

import typing.Any

import ...runtime.mathematical_objects.MathematicalObject


class DotNetBridge
    #     """.NET FFI Bridge using pythonnet."""

    #     def __init__(self):
    #         if not DOTNET_AVAILABLE:
                raise ImportError(
    #                 "pythonnet not installed. Install with: pip install pythonnet"
    #             )

    #         # Lazy initialization of .NET runtime
    #         try:
                # Add reference to SimpleMath.dll (placeholder; user to provide)
                clr.AddReference("examples/interop/SimpleMath.dll")
    #             from SimpleMath import SimpleMath

    self.SimpleMath = SimpleMath
    #         except Exception:
                raise ImportError(
    #                 ".NET class not found. Compile SimpleMath.cs to DLL at examples/interop/SimpleMath.dll"
    #             )

    #     def call_external(self, module: str, func: str, args: List[Any]) -Any):
    #         """Call .NET function."""
    #         if func == "add":
    #             if len(args) != 2:
                    raise ValueError("add requires 2 arguments")
    a, b = float(args[0]), float(args[1])
                return self.SimpleMath.Add(a, b)
    #         else:
                raise ValueError(f"Unknown .NET function: {func}")

    #     def serialize_args(
    #         self, args: List[Any], mapper: MathematicalObjectMapper
    #     ) -List[Any]):
    #         """Serialize args for .NET (primitives)."""
    #         return [float(arg) if isinstance(arg, (int, float)) else arg for arg in args]

    #     def deserialize_result(
    self, result: Any, mapper: MathematicalObjectMapper, expected_type: str = None
    #     ) -Any):
    #         """Deserialize result from .NET."""
    #         return float(result) if expected_type == "scalar" else result
