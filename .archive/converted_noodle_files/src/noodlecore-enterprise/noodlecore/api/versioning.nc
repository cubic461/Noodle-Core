# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Versioning decorators for Noodle API
# """

import warnings
import functools.wraps
import inspect.Parameter,
import typing.Callable,


def versioned(
version: str, deprecated_in: Optional[str] = None, replaces: Optional[str] = None
# ) -> Callable:
#     """
#     Decorator to mark functions with version information.

#     Args:
#         version: The current version of this function
#         deprecated_in: The version in which this function will be deprecated
        replaces: The function this one replaces (in format "func@version")

#     Returns:
#         The wrapped function
#     """

#     def decorator(func: Callable) -> Callable:
        @wraps(func)
#         def wrapper(*args, **kwargs):
#             if deprecated_in:
                warnings.warn(
#                     f"Function {func.__name__} is deprecated in version {deprecated_in}. "
#                     f"Use the replacement in {replaces} instead.",
#                     DeprecationWarning,
stacklevel = 2,
#                 )

            return func(*args, **kwargs)

#         # Add version info as attributes
wrapper.version = version
wrapper.deprecated_in = deprecated_in
wrapper.replaces = replaces

#         return wrapper

#     return decorator


def deprecated(message: str = "This function is deprecated") -> Callable:
#     """
#     Decorator to mark functions as deprecated.

#     Args:
#         message: Custom deprecation message

#     Returns:
#         The wrapped function
#     """

#     def decorator(func: Callable) -> Callable:
        @wraps(func)
#         def wrapper(*args, **kwargs):
warnings.warn(message, DeprecationWarning, stacklevel = 2)
            return func(*args, **kwargs)

#         return wrapper

#     return decorator


# Global registry for versioned functions
VERSIONED_FUNCTIONS = {}


def register_versioned_function(func: Callable) -> Callable:
#     """
#     Register a versioned function in the global registry.
#     """
VERSIONED_FUNCTIONS[func.__name__] = func
#     return func


# Decorator to register versioned function
def versioned_register(
version: str, deprecated_in: Optional[str] = None, replaces: Optional[str] = None
# ):
#     """
#     Decorator that marks function with version and registers it.
#     """

#     def decorator(func: Callable) -> Callable:
wrapped = versioned(version, deprecated_in, replaces)(func)
VERSIONED_FUNCTIONS[func.__name__] = wrapped
#         return wrapped

#     return decorator
