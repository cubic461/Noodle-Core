# Converted from Python to NoodleCore
# Original file: src

# """
# Runtime environment for the Noodle project.

# This module provides environment management functionality including:
# - Environment creation and configuration
# - Variable scope management
# - Module loading and unloading
# - Execution context management
# """

import os
import sys
import typing.Any


class Environment
    #     """
    #     Manages the execution environment for Noodle programs.
    #     """

    #     def __init__(self, name: str = "default", parent: Optional["Environment"] = None):""
    #         Initialize a new environment.

    #         Args:
    #             name: Environment name
    #             parent: Parent environment for scope chaining
    #         """
    self.name = name
    self.parent = parent
    self.variables: Dict[str, Any] = {}
    self.modules: Dict[str, Any] = {}
    self.functions: Dict[str, Any] = {}
    self.classes: Dict[str, Any] = {}

    #     def set_variable(self, name: str, value: Any) -None):
    #         """
    #         Set a variable in the current environment.

    #         Args:
    #             name: Variable name
    #             value: Variable value
    #         """
    self.variables[name] = value

    #     def get_variable(self, name: str) -Any):
    #         """
    #         Get a variable value from the environment hierarchy.

    #         Args:
    #             name: Variable name

    #         Returns:
    #             Variable value

    #         Raises:
    #             NameError: If variable is not found
    #         """
    #         # Check current environment
    #         if name in self.variables:
    #             return self.variables[name]

    #         # Check parent environments
    env = self.parent
    #         while env is not None:
    #             if name in env.variables:
    #                 return env.variables[name]
    env = env.parent

            raise NameError(f"Variable '{name}' not found in environment hierarchy")

    #     def has_variable(self, name: str) -bool):
    #         """
    #         Check if a variable exists in the environment hierarchy.

    #         Args:
    #             name: Variable name

    #         Returns:
    #             True if variable exists, False otherwise
    #         """
    #         # Check current environment
    #         if name in self.variables:
    #             return True

    #         # Check parent environments
    env = self.parent
    #         while env is not None:
    #             if name in env.variables:
    #                 return True
    env = env.parent

    #         return False

    #     def delete_variable(self, name: str) -None):
    #         """
    #         Delete a variable from the current environment.

    #         Args:
    #             name: Variable name

    #         Raises:
    #             NameError: If variable is not found in current environment
    #         """
    #         if name in self.variables:
    #             del self.variables[name]
    #         else:
                raise NameError(f"Variable '{name}' not found in current environment")

    #     def set_module(self, name: str, module: Any) -None):
    #         """
    #         Set a module in the environment.

    #         Args:
    #             name: Module name
    #             module: Module object
    #         """
    self.modules[name] = module

    #     def get_module(self, name: str) -Any):
    #         """
    #         Get a module from the environment.

    #         Args:
    #             name: Module name

    #         Returns:
    #             Module object

    #         Raises:
    #             ImportError: If module is not found
    #         """
    #         if name in self.modules:
    #             return self.modules[name]
    #         else:
                raise ImportError(f"Module '{name}' not found in environment")

    #     def has_module(self, name: str) -bool):
    #         """
    #         Check if a module exists in the environment.

    #         Args:
    #             name: Module name

    #         Returns:
    #             True if module exists, False otherwise
    #         """
    #         return name in self.modules

    #     def delete_module(self, name: str) -None):
    #         """
    #         Delete a module from the environment.

    #         Args:
    #             name: Module name

    #         Raises:
    #             ImportError: If module is not found
    #         """
    #         if name in self.modules:
    #             del self.modules[name]
    #         else:
                raise ImportError(f"Module '{name}' not found in environment")

    #     def set_function(self, name: str, func: Any) -None):
    #         """
    #         Set a function in the environment.

    #         Args:
    #             name: Function name
    #             func: Function object
    #         """
    self.functions[name] = func

    #     def get_function(self, name: str) -Any):
    #         """
    #         Get a function from the environment.

    #         Args:
    #             name: Function name

    #         Returns:
    #             Function object

    #         Raises:
    #             NameError: If function is not found
    #         """
    #         if name in self.functions:
    #             return self.functions[name]
    #         else:
                raise NameError(f"Function '{name}' not found in environment")

    #     def has_function(self, name: str) -bool):
    #         """
    #         Check if a function exists in the environment.

    #         Args:
    #             name: Function name

    #         Returns:
    #             True if function exists, False otherwise
    #         """
    #         return name in self.functions

    #     def delete_function(self, name: str) -None):
    #         """
    #         Delete a function from the environment.

    #         Args:
    #             name: Function name

    #         Raises:
    #             NameError: If function is not found
    #         """
    #         if name in self.functions:
    #             del self.functions[name]
    #         else:
                raise NameError(f"Function '{name}' not found in environment")

    #     def set_class(self, name: str, cls: Any) -None):
    #         """
    #         Set a class in the environment.

    #         Args:
    #             name: Class name
    #             cls: Class object
    #         """
    self.classes[name] = cls

    #     def get_class(self, name: str) -Any):
    #         """
    #         Get a class from the environment.

    #         Args:
    #             name: Class name

    #         Returns:
    #             Class object

    #         Raises:
    #             NameError: If class is not found
    #         """
    #         if name in self.classes:
    #             return self.classes[name]
    #         else:
                raise NameError(f"Class '{name}' not found in environment")

    #     def has_class(self, name: str) -bool):
    #         """
    #         Check if a class exists in the environment.

    #         Args:
    #             name: Class name

    #         Returns:
    #             True if class exists, False otherwise
    #         """
    #         return name in self.classes

    #     def delete_class(self, name: str) -None):
    #         """
    #         Delete a class from the environment.

    #         Args:
    #             name: Class name

    #         Raises:
    #             NameError: If class is not found
    #         """
    #         if name in self.classes:
    #             del self.classes[name]
    #         else:
                raise NameError(f"Class '{name}' not found in environment")

    #     def create_child(self, name: str) -"Environment"):
    #         """
    #         Create a child environment.

    #         Args:
    #             name: Child environment name

    #         Returns:
    #             New child environment
    #         """
            return Environment(name, self)

    #     def get_all_variables(self) -Dict[str, Any]):
    #         """
    #         Get all variables in the current environment.

    #         Returns:
    #             Dictionary of variables
    #         """
            return self.variables.copy()

    #     def get_all_modules(self) -Dict[str, Any]):
    #         """
    #         Get all modules in the current environment.

    #         Returns:
    #             Dictionary of modules
    #         """
            return self.modules.copy()

    #     def get_all_functions(self) -Dict[str, Any]):
    #         """
    #         Get all functions in the current environment.

    #         Returns:
    #             Dictionary of functions
    #         """
            return self.functions.copy()

    #     def get_all_classes(self) -Dict[str, Any]):
    #         """
    #         Get all classes in the current environment.

    #         Returns:
    #             Dictionary of classes
    #         """
            return self.classes.copy()

    #     def clear(self) -None):
    #         """Clear all contents of the current environment."""
            self.variables.clear()
            self.modules.clear()
            self.functions.clear()
            self.classes.clear()

    #     def copy(self) -"Environment"):
    #         """
    #         Create a copy of the environment.

    #         Returns:
    #             New environment with copied contents
    #         """
    new_env = Environment(self.name, self.parent)
    new_env.variables = self.variables.copy()
    new_env.modules = self.modules.copy()
    new_env.functions = self.functions.copy()
    new_env.classes = self.classes.copy()
    #         return new_env

    #     def __str__(self) -str):
    #         """String representation of the environment."""
    return f"Environment(name = '{self.name}', variables={len(self.variables)}, modules={len(self.modules)}, functions={len(self.functions)}, classes={len(self.classes)})"

    #     def __repr__(self) -str):
    #         """Detailed string representation."""
    #         return f"Environment(name='{self.name}', parent={self.parent.name if self.parent else 'None'}, variables={len(self.variables)}, modules={len(self.modules)}, functions={len(self.functions)}, classes={len(self.classes)})"


# Global environment instance
_global_environment = Environment("global")


def get_global_environment() -Environment):
#     """
#     Get the global environment instance.

#     Returns:
#         Global environment
#     """
#     return _global_environment


def create_environment(name: str, parent: Optional[Environment] = None) -Environment):
#     """
#     Create a new environment.

#     Args:
#         name: Environment name
#         parent: Parent environment

#     Returns:
#         New environment
#     """
    return Environment(name, parent or _global_environment)


def set_global_variable(name: str, value: Any) -None):
#     """
#     Set a variable in the global environment.

#     Args:
#         name: Variable name
#         value: Variable value
#     """
    _global_environment.set_variable(name, value)


def get_global_variable(name: str) -Any):
#     """
#     Get a variable from the global environment.

#     Args:
#         name: Variable name

#     Returns:
#         Variable value
#     """
    return _global_environment.get_variable(name)


def has_global_variable(name: str) -bool):
#     """
#     Check if a variable exists in the global environment.

#     Args:
#         name: Variable name

#     Returns:
#         True if variable exists, False otherwise
#     """
    return _global_environment.has_variable(name)
