# Converted from Python to NoodleCore
# Original file: src

# """
# Runtime Stack Management for Noodle Language
# --------------------------------------------
# Manages the call stack and stack frames for runtime execution.
# """

import typing.Dict
import .runtime_types.Value


class StackFrame
    #     """Represents a stack frame in the runtime"""

    #     def __init__(self, name: str, variables: Dict[str, Value], parent: Optional["StackFrame"] = None):
    self.name = name
    self.variables = variables.copy()
    self.parent = parent

    #     def get_variable(self, name: str) -Value):
    #         """Get variable value"""
    #         if name in self.variables:
    #             return self.variables[name]

    #         if self.parent:
                return self.parent.get_variable(name)

            raise ExecutionError(f"Name '{name}' is not defined")

    #     def set_variable(self, name: str, value: Value) -None):
    #         """Set variable value"""
    self.variables[name] = value

    #     def has_variable(self, name: str) -bool):
    #         """Check if variable exists"""
    #         if name in self.variables:
    #             return True

    #         if self.parent:
                return self.parent.has_variable(name)

    #         return False

    #     def get_all_variables(self) -Dict[str, Value]):
    #         """Get all variables in this frame and parent frames"""
    variables = {}

    #         # Get variables from parent frames first
    #         if self.parent:
                variables.update(self.parent.get_all_variables())

            # Add this frame's variables (may override parent variables)
            variables.update(self.variables)

    #         return variables


class CallStack
    #     """Manages the call stack"""

    #     def __init__(self):
    self.frames: list[StackFrame] = []
    self.global_frame = StackFrame("global", {})
            self.frames.append(self.global_frame)

    #     def push_frame(self, frame: StackFrame) -None):
    #         """Push a new frame onto the stack"""
            self.frames.append(frame)

    #     def pop_frame(self) -None):
    #         """Pop the current frame from the stack"""
    #         if len(self.frames) 1):  # Keep global frame
                self.frames.pop()

    #     def get_current_frame(self) -StackFrame):
    #         """Get the current frame"""
    #         return self.frames[-1]

    #     def get_global_frame(self) -StackFrame):
    #         """Get the global frame"""
    #         return self.global_frame

    #     def get_stack_depth(self) -int):
    #         """Get the current stack depth"""
            return len(self.frames)

    #     def get_stack_trace(self) -list[str]):
    #         """Get a stack trace with frame names"""
    #         return [frame.name for frame in self.frames]


class ExecutionError(Exception)
    #     """Exception raised during execution"""
    #     pass
