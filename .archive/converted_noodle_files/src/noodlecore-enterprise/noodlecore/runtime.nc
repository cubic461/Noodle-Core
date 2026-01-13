# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Runtime execution environment for Noodle language.
# Provides execution context, variable management, and control flow.

# This module provides a simplified interface to the runtime components.
# """

# Local imports
import .runtime_environment.RuntimeEnvironment
import .runtime_types.Value,


class RuntimeEnvironment(DefaultRuntimeEnvironment)
    #     """
    #     Simplified runtime interface for Noodle language.
    #     Uses the DefaultRuntimeEnvironment to handle the actual runtime execution.
    #     """

    #     def __init__(self):
            super().__init__()

    #     def run_program(self, program: Any) -> Optional[Value]:
    #         """
    #         Run a complete program.

    #         Args:
                program: The program to run (AST or equivalent)

    #         Returns:
    #             The result of the program execution
    #         """
            return self.execute_program(program)

    #     def create_runtime_value(self, python_value: Any) -> Value:
    #         """
    #         Create a runtime value from a Python value.

    #         Args:
    #             python_value: The Python value to convert

    #         Returns:
    #             The corresponding Noodle Value
    #         """
    #         from .runtime_values import ValueOperations
            return ValueOperations.python_to_value(python_value)

    #     def get_runtime_value(self, name: str) -> Value:
    #         """
    #         Get a runtime value by name.

    #         Args:
    #             name: The name of the value

    #         Returns:
    #             The corresponding Noodle Value
    #         """
            return self.get_variable(name)

    #     def set_runtime_value(self, name: str, value: Value) -> None:
    #         """
    #         Set a runtime value by name.

    #         Args:
    #             name: The name of the value
    #             value: The Noodle Value to set
    #         """
            self.set_variable(name, value)
