# Converted from Python to NoodleCore
# Original file: src

# """
# Database Error Classes
# ---------------------
# Provides a hierarchy of error classes for database operations.

# DEPRECATED: This module is deprecated. All error classes are now imported from
# error_handler.py to maintain a unified error hierarchy under NoodleError.

# Please update your imports to use error_handler.py directly.
# This module will be removed in a future version.
# """

import warnings

# Import all database error classes from the unified error_handler module
import ..error.(
#     AuthenticationError,
#     AuthorizationError,
#     BackendError,
#     BackendNotImplementedError,
#     CacheError,
#     ConfigurationError,
#     ConnectionError,
#     DatabaseError,
#     InvalidConnectionError,
#     MemoryBackendError,
#     MQLError,
#     OptimizationError,
#     ParseError,
#     PerformanceError,
#     PoolExhaustedError,
#     PostgreSQLBackendError,
#     QueryError,
#     QueryPlanningError,
#     QueryRewriteError,
#     SchemaError,
#     SemanticError,
#     SQLiteBackendError,
#     TimeoutError,
#     TransactionError,
# )

# For backward compatibility, re-export all errors
__all__ = [
#     "DatabaseError",
#     "ConnectionError",
#     "QueryError",
#     "QueryPlanningError",
#     "TransactionError",
#     "OptimizationError",
#     "CacheError",
#     "QueryRewriteError",
#     "SchemaError",
#     "TimeoutError",
#     "BackendError",
#     "BackendNotImplementedError",
#     "MemoryBackendError",
#     "SQLiteBackendError",
#     "PoolExhaustedError",
#     "InvalidConnectionError",
#     "ConfigurationError",
#     "AuthenticationError",
#     "AuthorizationError",
#     "PerformanceError",
#     "MQLError",
#     "ParseError",
#     "SemanticError",
#     "PostgreSQLBackendError",
# ]

# Add deprecation warnings to each class
# DISABLED TEMPORARILY TO FIX RECURSION ISSUES
# for error_name in __all__:
#     error_class = globals()[error_name]
#     if isinstance(error_class, type) and issubclass(error_class, Exception):
#         original_init = error_class.__init__

#         def __init_with_warning__(self, *args, **kwargs):
#             warnings.warn(
#                 f"{error_class.__name__} is deprecated. "
#                 f"Please use error_handler.py directly. "
#                 f"This module will be removed in a future version.",
#                 DeprecationWarning,
#                 stacklevel=2
#             )
#             original_init(self, *args, **kwargs)

#         # Bind the function to the class to avoid recursion
#         error_class.__init__ = __init_with_warning__

# Module-level deprecation warning
warnings.warn(
#     "noodle.database.errors is deprecated. "
#     "Please import error classes directly from error_handler.py. "
#     "This module will be removed in a future version.",
#     DeprecationWarning,
stacklevel = 2,
# )
