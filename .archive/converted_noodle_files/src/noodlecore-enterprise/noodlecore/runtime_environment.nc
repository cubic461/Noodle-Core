# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Runtime Environment for Noodle Language
# ---------------------------------------
# Provides the main runtime execution environment for Noodle programs.
# """

import typing.Any,
import .runtime_types.Value,
import .runtime_stack.StackFrame,
import .runtime_values.ValueOperations
import .runtime_execution.StatementExecutor


class RuntimeEnvironment
    #     """Main runtime execution environment"""

    #     def __init__(self):
    self.call_stack = CallStack()
    self.modules: Dict[str, Any] = {}
    self.built_ins: Dict[str, Function] = {}
    self.executor = StatementExecutor(self)

    #         # Initialize built-in functions
            self._init_built_ins()

    #     def _init_built_ins(self):
    #         """Initialize built-in functions"""
    #         # Print function
    #         def print_func(*args):
    #             print(" ".join(str(arg) for arg in args))

    self.built_ins['print'] = Function(
    name = 'print',
    parameters = ['*args'],
    body = None,
    closure = {},
    built_in = True,
    native_func = print_func
    #         )

    #         # Input function
    #         def input_func(prompt: str = ""):
                return input(prompt)

    self.built_ins['input'] = Function(
    name = 'input',
    parameters = ['prompt'],
    body = None,
    closure = {},
    built_in = True,
    native_func = input_func
    #         )

    #         # Len function
    #         def len_func(obj):
    #             if isinstance(obj, list):
                    return len(obj)
    #             elif isinstance(obj, dict):
                    return len(obj)
    #             elif isinstance(obj, str):
                    return len(obj)
    #             else:
                    raise ExecutionError(f"Object of type {type(obj).__name__} has no len()")

    self.built_ins['len'] = Function(
    name = 'len',
    parameters = ['obj'],
    body = None,
    closure = {},
    built_in = True,
    native_func = len_func
    #         )

    #         # Type function
    #         def type_func(obj):
                return type(obj).__name__

    self.built_ins['type'] = Function(
    name = 'type',
    parameters = ['obj'],
    body = None,
    closure = {},
    built_in = True,
    native_func = type_func
    #         )

    #         # Range function
    #         def range_func(start, stop=None, step=1):
    #             if stop is None:
                    return list(range(start))
    #             else:
                    return list(range(start, stop, step))

    self.built_ins['range'] = Function(
    name = 'range',
    parameters = ['start', 'stop', 'step'],
    body = None,
    closure = {},
    built_in = True,
    native_func = range_func
    #         )

    #         # Str function
    #         def str_func(obj):
                return str(obj)

    self.built_ins['str'] = Function(
    name = 'str',
    parameters = ['obj'],
    body = None,
    closure = {},
    built_in = True,
    native_func = str_func
    #         )

    #         # Int function
    #         def int_func(obj):
                return int(obj)

    self.built_ins['int'] = Function(
    name = 'int',
    parameters = ['obj'],
    body = None,
    closure = {},
    built_in = True,
    native_func = int_func
    #         )

    #         # Float function
    #         def float_func(obj):
                return float(obj)

    self.built_ins['float'] = Function(
    name = 'float',
    parameters = ['obj'],
    body = None,
    closure = {},
    built_in = True,
    native_func = float_func
    #         )

    #         # Bool function
    #         def bool_func(obj):
                return bool(obj)

    self.built_ins['bool'] = Function(
    name = 'bool',
    parameters = ['obj'],
    body = None,
    closure = {},
    built_in = True,
    native_func = bool_func
    #         )

    #         # List function
    #         def list_func(iterable):
                return list(iterable)

    self.built_ins['list'] = Function(
    name = 'list',
    parameters = ['iterable'],
    body = None,
    closure = {},
    built_in = True,
    native_func = list_func
    #         )

    #         # Dict function
    #         def dict_func(**kwargs):
    #             return kwargs

    self.built_ins['dict'] = Function(
    name = 'dict',
    parameters = ['**kwargs'],
    body = None,
    closure = {},
    built_in = True,
    native_func = dict_func
    #         )

    #         # Add built-ins to global frame
    global_frame = self.call_stack.get_global_frame()
    #         for name, func in self.built_ins.items():
                global_frame.set_variable(name, Value(RuntimeType.FUNCTION, func))

    #     def create_frame(self, name: str, closure: Dict[str, Value]) -> StackFrame:
    #         """Create a new stack frame"""
    frame = StackFrame(name, closure, self.call_stack.get_current_frame())
            self.call_stack.push_frame(frame)
    #         return frame

    #     def pop_frame(self):
    #         """Pop the current frame from the stack"""
            self.call_stack.pop_frame()

    #     @property
    #     def current_frame(self) -> StackFrame:
    #         """Get the current frame"""
            return self.call_stack.get_current_frame()

    #     def get_variable(self, name: str) -> Value:
    #         """Get variable value"""
            return self.current_frame.get_variable(name)

    #     def set_variable(self, name: str, value: Value) -> None:
    #         """Set variable value"""
            self.current_frame.set_variable(name, value)

    #     def execute_statement(self, statement: Any, frame: Optional[StackFrame] = None) -> Optional[Value]:
    #         """Execute a single statement"""
    #         if frame is None:
    frame = self.current_frame

    #         try:
                return self.executor.execute_statement(statement, frame)
    #         except ExecutionError as e:
    #             if str(e) in ["Return", "Break", "Continue"]:
    #                 # Handle control flow exceptions
                    return Value(RuntimeType.NONE, None)
    #             else:
    #                 # Re-raise other execution errors
    #                 raise

    #     def execute_program(self, program: Any) -> Optional[Value]:
    #         """Execute a complete program"""
    #         try:
                return self.execute_statement(program)
    #         except ExecutionError as e:
    #             if str(e) in ["Return", "Break", "Continue"]:
    #                 # Handle control flow exceptions
    #                 pass
    #             else:
    #                 # Re-raise other execution errors
    #                 raise
