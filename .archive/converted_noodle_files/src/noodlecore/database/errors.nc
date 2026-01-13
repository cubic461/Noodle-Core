# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# NoodleCore Database Errors
 = ==========================

# Database-specific exception classes with 4-digit error codes
# following the project's error handling standards.

# Error Codes:
# - 4001-4999: Connection errors
# - 5001-5999: Query errors
# - 6001-6999: Transaction errors
# - 7001-7999: Backend errors
# - 8001-8999: Database operation errors
# """

import logging
import typing.Optional,


class DatabaseError(Exception)
    #     """Base database error class."""

    #     def __init__(self, message: str, error_code: int = 1000):
    #         """
    #         Initialize database error.

    #         Args:
    #             message: Error message
    #             error_code: 4-digit error code
    #         """
            super().__init__(message)
    self.error_code = error_code
    self.logger = logging.getLogger('noodlecore.database.errors')
            self.logger.error(f"DatabaseError [{error_code}]: {message}")


class ConnectionError(DatabaseError)
    #     """Database connection related errors."""

    #     def __init__(self, message: str, error_code: int = 4001):
            super().__init__(message, error_code)


class TimeoutError(DatabaseError)
    #     """Database timeout related errors."""

    #     def __init__(self, message: str, error_code: int = 4002):
            super().__init__(message, error_code)


class QueryError(DatabaseError)
    #     """Database query related errors."""

    #     def __init__(self, message: str, error_code: int = 5001):
            super().__init__(message, error_code)


class TransactionError(DatabaseError)
    #     """Database transaction related errors."""

    #     def __init__(self, message: str, error_code: int = 6001):
            super().__init__(message, error_code)


class BackendError(DatabaseError)
    #     """Database backend related errors."""

    #     def __init__(self, message: str, error_code: int = 7001):
            super().__init__(message, error_code)


class SchemaError(DatabaseError)
    #     """Database schema related errors."""

    #     def __init__(self, message: str, error_code: int = 8001):
            super().__init__(message, error_code)


class OptimizationError(DatabaseError)
    #     """Database optimization related errors."""

    #     def __init__(self, message: str, error_code: int = 9001):
            super().__init__(message, error_code)


class ConfigurationError(DatabaseError)
    #     """Database configuration related errors."""

    #     def __init__(self, message: str, error_code: int = 3001):
            super().__init__(message, error_code)


class ValidationError(DatabaseError)
    #     """Database validation related errors."""

    #     def __init__(self, message: str, error_code: int = 3002):
            super().__init__(message, error_code)


# Connection Error Codes (4001-4999)
CONNECTION_FAILED = 4001
CONNECTION_TIMEOUT = 4002
CONNECTION_LOST = 4003
CONNECTION_INVALID = 4004
CONNECTION_ALREADY_EXISTS = 4005
CONNECTION_NOT_CONNECTED = 4006
CONNECTION_DISCONNECT_FAILED = 4007

# Query Error Codes (5001-5999)
QUERY_VALIDATION_FAILED = 5001
QUERY_EXECUTION_FAILED = 5002
QUERY_TIMEOUT = 5003
QUERY_SYNTAX_ERROR = 5004
QUERY_PARAMETER_ERROR = 5005
INSERT_FAILED = 5010
UPDATE_FAILED = 5011
DELETE_FAILED = 5012
SELECT_FAILED = 5013
TABLE_NOT_FOUND = 5014
TABLE_ALREADY_EXISTS = 5015
TABLE_CREATION_FAILED = 5016
TABLE_DROP_FAILED = 5017
SCHEMA_RETRIEVAL_FAILED = 5018

# Transaction Error Codes (6001-6999)
TRANSACTION_FAILED = 6001
TRANSACTION_ROLLBACK_FAILED = 6002
TRANSACTION_BEGIN_FAILED = 6003
TRANSACTION_COMMIT_FAILED = 6004
TRANSACTION_ALREADY_IN_PROGRESS = 6005

# Backend Error Codes (7001-7999)
BACKEND_NOT_SUPPORTED = 7001
BACKEND_INITIALIZATION_FAILED = 7002
BACKEND_CONFIGURATION_ERROR = 7003
BACKEND_CONNECTION_FAILED = 7004

# Database Operation Error Codes (8001-8999)
BACKUP_FAILED = 8001
RESTORE_FAILED = 8002
OPTIMIZATION_FAILED = 8003
STATS_RETRIEVAL_FAILED = 8004
HEALTH_CHECK_FAILED = 8005


def format_error(
#     error_type: str,
#     operation: str,
details: Optional[Dict[str, Any]] = None,
cause: Optional[str] = None,
context: Optional[Dict[str, Any]] = None
# ) -> str:
#     """
#     Format error message with context information.

#     Args:
#         error_type: Type of error
#         operation: Operation that failed
#         details: Optional error details
#         cause: Optional root cause
#         context: Optional context information

#     Returns:
#         Formatted error message
#     """
error_parts = [error_type]

#     if operation:
        error_parts.append(f"Operation: {operation}")

#     if details:
#         for key, value in details.items():
            error_parts.append(f"{key}: {value}")

#     if cause:
        error_parts.append(f"Cause: {cause}")

#     if context:
#         for key, value in context.items():
            error_parts.append(f"{key}: {value}")

    return " | ".join(error_parts)


def create_database_error(
#     operation: str,
#     message: str,
#     error_code: int,
details: Optional[Dict[str, Any]] = None
# ) -> DatabaseError:
#     """
#     Create a standardized database error.

#     Args:
#         operation: Operation that failed
#         message: Error message
#         error_code: 4-digit error code
#         details: Optional error details

#     Returns:
#         DatabaseError instance
#     """
    return DatabaseError(
message = format_error("DatabaseError", operation, details),
error_code = error_code
#     )


def create_connection_error(
#     operation: str,
#     message: str,
#     error_code: int,
details: Optional[Dict[str, Any]] = None
# ) -> ConnectionError:
#     """
#     Create a standardized connection error.

#     Args:
#         operation: Operation that failed
#         message: Error message
#         error_code: 4-digit error code
#         details: Optional error details

#     Returns:
#         ConnectionError instance
#     """
    return ConnectionError(
message = format_error("ConnectionError", operation, details),
error_code = error_code
#     )


def create_query_error(
#     operation: str,
#     message: str,
#     error_code: int,
details: Optional[Dict[str, Any]] = None
# ) -> QueryError:
#     """
#     Create a standardized query error.

#     Args:
#         operation: Operation that failed
#         message: Error message
#         error_code: 4-digit error code
#         details: Optional error details

#     Returns:
#         QueryError instance
#     """
    return QueryError(
message = format_error("QueryError", operation, details),
error_code = error_code
#     )


def create_transaction_error(
#     operation: str,
#     message: str,
#     error_code: int,
details: Optional[Dict[str, Any]] = None
# ) -> TransactionError:
#     """
#     Create a standardized transaction error.

#     Args:
#         operation: Operation that failed
#         message: Error message
#         error_code: 4-digit error code
#         details: Optional error details

#     Returns:
#         TransactionError instance
#     """
    return TransactionError(
message = format_error("TransactionError", operation, details),
error_code = error_code
#     )


def create_backend_error(
#     operation: str,
#     message: str,
#     error_code: int,
details: Optional[Dict[str, Any]] = None
# ) -> BackendError:
#     """
#     Create a standardized backend error.

#     Args:
#         operation: Operation that failed
#         message: Error message
#         error_code: 4-digit error code
#         details: Optional error details

#     Returns:
#         BackendError instance
#     """
    return BackendError(
message = format_error("BackendError", operation, details),
error_code = error_code
#     )


def create_schema_error(
#     operation: str,
#     message: str,
#     error_code: int,
details: Optional[Dict[str, Any]] = None
# ) -> SchemaError:
#     """
#     Create a standardized schema error.

#     Args:
#         operation: Operation that failed
#         message: Error message
#         error_code: 4-digit error code
#         details: Optional error details

#     Returns:
#         SchemaError instance
#     """
    return SchemaError(
message = format_error("SchemaError", operation, details),
error_code = error_code
#     )


def create_optimization_error(
#     operation: str,
#     message: str,
#     error_code: int,
details: Optional[Dict[str, Any]] = None
# ) -> OptimizationError:
#     """
#     Create a standardized optimization error.

#     Args:
#         operation: Operation that failed
#         message: Error message
#         error_code: 4-digit error code
#         details: Optional error details

#     Returns:
#         OptimizationError instance
#     """
    return OptimizationError(
message = format_error("OptimizationError", operation, details),
error_code = error_code
#     )