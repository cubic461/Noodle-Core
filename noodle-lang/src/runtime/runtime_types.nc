# Converted from Python to NoodleCore
# Original file: src

# """
# Runtime Types for Noodle Language
# ----------------------------------
# Defines the runtime types and data structures for Noodle.
# """

import typing.Any
from dataclasses import dataclass
import enum.Enum


class RuntimeType(Enum)
    #     """Types of runtime values"""
    INTEGER = "int"
    FLOAT = "float"
    STRING = "str"
    BOOLEAN = "bool"
    LIST = "list"
    DICT = "dict"
    FUNCTION = "function"
    CLASS = "class"
    INSTANCE = "instance"
    MODULE = "module"
    NONE = "none"


dataclass
class Value
    #     """Represents a runtime value with type and data"""
    #     type: RuntimeType
    #     data: Any
    type_info: Optional[Type] = None

    #     def __post_init__(self):
    #         # Validate data matches type
    #         if self.type == RuntimeType.INTEGER and not isinstance(self.data, int):
                raise ExecutionError(f"Expected integer, got {type(self.data).__name__}")
    #         elif self.type == RuntimeType.FLOAT and not isinstance(self.data, (int, float)):
                raise ExecutionError(f"Expected float, got {type(self.data).__name__}")
    #         elif self.type == RuntimeType.STRING and not isinstance(self.data, str):
                raise ExecutionError(f"Expected string, got {type(self.data).__name__}")
    #         elif self.type == RuntimeType.BOOLEAN and not isinstance(self.data, bool):
                raise ExecutionError(f"Expected boolean, got {type(self.data).__name__}")
    #         elif self.type == RuntimeType.LIST and not isinstance(self.data, list):
                raise ExecutionError(f"Expected list, got {type(self.data).__name__}")
    #         elif self.type == RuntimeType.DICT and not isinstance(self.data, dict):
                raise ExecutionError(f"Expected dict, got {type(self.data).__name__}")
    #         elif self.type == RuntimeType.NONE and self.data is not None:
                raise ExecutionError(f"Expected None, got {type(self.data).__name__}")

    #     def __str__(self) -str):
            return str(self.data)

    #     def __repr__(self) -str):
            return f"Value({self.type.name}, {repr(self.data)})"

    #     def __eq__(self, other: "Value") -bool):
    #         if self.type != other.type:
    #             return False
    return self.data == other.data

    #     def __hash__(self) -int):
            return hash((self.type, self.data))

    #     def truthy(self) -bool):
    #         """Return truth value of this value"""
    #         if self.type == RuntimeType.BOOLEAN:
    #             return self.data
    #         elif self.type == RuntimeType.INTEGER:
    return self.data != 0
    #         elif self.type == RuntimeType.FLOAT:
    return self.data != 0.0
    #         elif self.type == RuntimeType.STRING:
                return len(self.data) 0
    #         elif self.type == RuntimeType.LIST):
                return len(self.data) 0
    #         elif self.type == RuntimeType.DICT):
                return len(self.data) 0
    #         elif self.type == RuntimeType.NONE):
    #             return False
    #         else:
    #             return True  # Default to truthy for unknown types


dataclass
class Function
    #     """Represents a runtime function"""
    #     name: str
    #     parameters: List[str]
    #     body: Any
    #     closure: Dict[str, Value]
    built_in: bool = False
    native_func: Optional[Callable] = None
    return_type: Optional[RuntimeType] = None
    param_types: Optional[List[RuntimeType]] = None

    #     def call(self, arguments: List[Value], runtime: "RuntimeEnvironment") -Value):
    #         """Call this function with given arguments"""
    #         if self.built_in and self.native_func:
    #             # Call native Python function
    #             try:
    #                 # Convert values to Python types
    py_args = []
    #                 for arg in arguments:
    #                     if arg.type == RuntimeType.INTEGER:
                            py_args.append(int(arg.data))
    #                     elif arg.type == RuntimeType.FLOAT:
                            py_args.append(float(arg.data))
    #                     elif arg.type == RuntimeType.STRING:
                            py_args.append(str(arg.data))
    #                     elif arg.type == RuntimeType.BOOLEAN:
                            py_args.append(bool(arg.data))
    #                     elif arg.type == RuntimeType.LIST:
                            py_args.append(arg.data)
    #                     elif arg.type == RuntimeType.DICT:
                            py_args.append(arg.data)
    #                     else:
                            raise ExecutionError(f"Cannot convert {arg.type} to Python type")

    #                 # Call function
    result = self.native_func( * py_args)

    #                 # Convert result back to Value
                    return self._python_to_value(result)

    #             except Exception as e:
    error_reporter = get_error_reporter()
                    error_reporter.report_exception(
    exception = e,
    context = f"Built-in function {self.name}",
    error_code = "BUILTIN_FUNC_ERROR"
    #                 )
                    raise ExecutionError(f"Error in built-in function {self.name}: {str(e)}")

    #         else:
    #             # Call user-defined function
    #             if len(arguments) != len(self.parameters):
                    raise ExecutionError(f"Function {self.name} expected {len(self.parameters)} arguments, got {len(arguments)}")

    #             # Create new frame for this function call
    frame = runtime.create_frame(self.name, self.closure)

    #             # Bind arguments to parameters
    #             for param, arg in zip(self.parameters, arguments):
                    frame.set_variable(param, arg)

    #             # Execute function body
    #             try:
    #                 if isinstance(self.body, list):
    #                     # Multiple statements
    #                     for stmt in self.body[:-1]:
                            runtime.execute_statement(stmt, frame)

    #                     # Last statement is the return value
    result = runtime.execute_statement(self.body[ - 1], frame)
    #                     return result
    #                 else:
    #                     # Single expression
    result = runtime.execute_statement(self.body, frame)
    #                     return result

    #             finally:
    #                 # Pop frame from stack
                    runtime.pop_frame()

    #     def _python_to_value(self, python_value: Any) -Value):
    #         """Convert Python value to Noodle Value"""
    #         if python_value is None:
                return Value(RuntimeType.NONE, None)
    #         elif isinstance(python_value, bool):
                return Value(RuntimeType.BOOLEAN, python_value)
    #         elif isinstance(python_value, int):
                return Value(RuntimeType.INTEGER, python_value)
    #         elif isinstance(python_value, float):
                return Value(RuntimeType.FLOAT, python_value)
    #         elif isinstance(python_value, str):
                return Value(RuntimeType.STRING, python_value)
    #         elif isinstance(python_value, list):
                return Value(RuntimeType.LIST, python_value)
    #         elif isinstance(python_value, dict):
                return Value(RuntimeType.DICT, python_value)
    #         else:
                raise ExecutionError(f"Cannot convert Python type {type(python_value).__name__} to Noodle value")


dataclass
class Class
    #     """Represents a runtime class"""
    #     name: str
    #     bases: List["Class"]
    #     methods: Dict[str, Function]
    #     attributes: Dict[str, Value]
    #     class_attributes: Dict[str, Value]

    #     def __post_init__(self):
    #         # Build method resolution order
    self.mro = self._build_mro()

    #     def _build_mro(self) -List["Class"]):
    #         """Build method resolution order for inheritance"""
    #         if not self.bases:
    #             return [self]

    mro = [self]
    #         for base in self.bases:
    #             if base not in mro:
                    mro.append(base)

    #         # Add bases' MRO
    #         for base in self.bases:
    #             for cls in base.mro:
    #                 if cls not in mro:
                        mro.append(cls)

    #         return mro

    #     def get_method(self, name: str) -Optional[Function]):
    #         """Get method with given name"""
    #         for cls in self.mro:
    #             if name in cls.methods:
    #                 return cls.methods[name]
    #         return None

    #     def get_attribute(self, name: str) -Optional[Value]):
    #         """Get attribute with given name"""
    #         for cls in self.mro:
    #             if name in cls.attributes:
    #                 return cls.attributes[name]
    #         return None

    #     def set_attribute(self, name: str, value: Value) -None):
    #         """Set instance attribute"""
    self.attributes[name] = value


dataclass
class Instance
    #     """Represents an instance of a class"""
    #     cls: Class
    attributes: Dict[str, Value] = field(default_factory=dict)

    #     def get_attribute(self, name: str) -Value):
    #         """Get attribute with given name"""
    #         # Check instance attributes first
    #         if name in self.attributes:
    #             return self.attributes[name]

    #         # Then check class attributes
    value = self.cls.get_attribute(name)
    #         if value is not None:
    #             return value

    #         # Then check class methods
    method = self.cls.get_method(name)
    #         if method is not None:
                return Value(RuntimeType.FUNCTION, method)

            raise ExecutionError(f"'{self.cls.name}' object has no attribute '{name}'")

    #     def set_attribute(self, name: str, value: Value) -None):
    #         """Set instance attribute"""
    self.attributes[name] = value

    #     def call_method(self, name: str, arguments: List[Value], runtime: "RuntimeEnvironment") -Value):
    #         """Call method on this instance"""
    method = self.cls.get_method(name)
    #         if method is None:
                raise ExecutionError(f"'{self.cls.name}' object has no method '{name}'")

    #         # Create new frame for method call
    frame = runtime.create_frame(f"{self.cls.name}.{name}", {})

    #         # Bind 'self' parameter
            frame.set_variable('self', Value(RuntimeType.INSTANCE, self))

    #         # Bind arguments to parameters
    #         for param, arg in zip(method.parameters, arguments):
                frame.set_variable(param, arg)

    #         # Execute method body
    #         try:
    #             if isinstance(method.body, list):
    #                 # Multiple statements
    #                 for stmt in method.body[:-1]:
                        runtime.execute_statement(stmt, frame)

    #                 # Last statement is the return value
    result = runtime.execute_statement(method.body[ - 1], frame)
    #                 return result
    #             else:
    #                 # Single expression
    result = runtime.execute_statement(method.body, frame)
    #                 return result

    #         finally:
    #             # Pop frame from stack
                runtime.pop_frame()


class ExecutionError(Exception)
    #     """Exception raised during execution"""
    #     pass


function get_error_reporter()
        """Get error reporter (placeholder)"""
    #     class DummyReporter:
    #         def report_exception(self, **kwargs):
    #             pass
        return DummyReporter()
