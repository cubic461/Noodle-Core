# Converted from Python to NoodleCore
# Original file: noodle-core

# """Noodle Error Handler and Input Validation Module

# This module provides centralized error handling, input sanitization, and security validation
# for the Noodle runtime. It mitigates injection attacks, deserialization risks, and DoS
# vulnerabilities identified in the security audit.

# Key features:
# - Input sanitization against SQL/NoSQL injection, command injection, XSS
# - Safe deserialization with type checking
# - Rate limiting for API endpoints and message handling
# - Secure error logging without sensitive data exposure
# - Custom exceptions for security violations
# - Error metrics tracking and alerting
# """

import hashlib
import json
import logging
import re
import secrets
import time
import collections.defaultdict
import datetime.datetime,
import functools.wraps
import threading.Lock
import typing.Any,

# Security constants
# MAX_STRING_LENGTH = 1024 * 1024  # 1MB max for strings
# MAX_JSON_SIZE = 10 * 1024 * 1024  # 10MB for JSON payloads
ALLOWED_METHODS = ["GET", "POST", "PUT", "DELETE"]
SANITIZE_PATTERN = re.compile(
    r"<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>", re.IGNORECASE | re.DOTALL
# )
SQL_INJECTION_PATTERN = re.compile(
    r"(?i)(union|select|insert|delete|drop|alter|create|exec|execute|script|javascript)"
# )
COMMAND_INJECTION_PATTERN = re.compile(
    r"(?i)(;|\||&&|\||\$\(|\`|\||cmd|bash|sh|python|perl)"
# )

logger = logging.getLogger(__name__)


# Error monitoring metrics
class ErrorMetrics
    #     """Tracks error frequency and severity metrics"""

    #     def __init__(self):
    self.error_counts = defaultdict(int)
    self.error_severity = defaultdict(int)
    self.error_timestamps = defaultdict(list)
    self.lock = Lock()
    self.alert_thresholds = {
    #             "CRITICAL": {"count": 10, "time_window": 300},  # 10 errors in 5 minutes
    #             "HIGH": {"count": 20, "time_window": 300},
    #             "MEDIUM": {"count": 50, "time_window": 300},
    #             "LOW": {"count": 100, "time_window": 300},
    #         }

    #     def record_error(self, error_type: str, severity: str = "LOW"):
    #         """Record an error occurrence"""
    #         with self.lock:
    self.error_counts[error_type] + = 1
    self.error_severity[severity] + = 1
                self.error_timestamps[error_type].append(time.time())

    #     def get_error_frequency(self, error_type: str, time_window: int = 3600) -> int:
            """Get error frequency within time window (default: 1 hour)"""
    now = time.time()
    #         with self.lock:
    timestamps = [
    #                 ts
    #                 for ts in self.error_timestamps.get(error_type, [])
    #                 if now - ts <= time_window
    #             ]
                return len(timestamps)

    #     def check_alert_thresholds(self, error_type: str) -> Optional[str]:
    #         """Check if error type exceeds alert thresholds"""
    now = time.time()
    #         with self.lock:
    timestamps = self.error_timestamps.get(error_type, [])

    #             for severity, threshold in self.alert_thresholds.items():
    recent_errors = [
    #                     ts for ts in timestamps if now - ts <= threshold["time_window"]
    #                 ]
    #                 if len(recent_errors) >= threshold["count"]:
    #                     return severity
    #         return None

    #     def get_metrics_summary(self) -> Dict[str, Any]:
    #         """Get summary of all error metrics"""
    #         with self.lock:
    #             return {
                    "error_counts": dict(self.error_counts),
                    "error_severity": dict(self.error_severity),
    #                 "alert_status": {
                        error_type: self.check_alert_thresholds(error_type)
    #                     for error_type in self.error_counts
    #                 },
    #             }


# Global error metrics instance
error_metrics = ErrorMetrics()


class NoodleError(Exception)
    #     """Base exception class for Noodle runtime"""

    #     def __init__(self, message: str, ctx: Optional[str] = None):
            super().__init__(message)
    self.message = message
    self.ctx = ctx
            error_metrics.record_error(self.__class__.__name__, "LOW")


class ExecutionError(NoodleError)
    #     """Error during execution"""

    #     def __init__(self, message: str, **kwargs):
            super().__init__(message, **kwargs)
    self.error_code = "EXECUTION_ERROR"


class TypeError(NoodleError)
    #     """Type-related errors"""

    #     def __init__(self, message: str, **kwargs):
            super().__init__(message, **kwargs)
    self.error_code = "TYPE_ERROR"


class CompilationError(NoodleError)
    #     """Error during compilation process"""

    #     def __init__(
    #         self,
    #         message: str,
    line_number: Optional[int] = None,
    column_number: Optional[int] = None,
    #         **kwargs,
    #     ):
    #         """
    #         Initialize a CompilationError.

    #         Args:
    #             message: Error message
    #             line_number: Optional line number where error occurred
    #             column_number: Optional column number where error occurred
    #             **kwargs: Additional arguments passed to NoodleError
    #         """
            super().__init__(message, **kwargs)
    self.error_code = "COMPILATION_ERROR"
    self.line_number = line_number
    self.column_number = column_number

    #     def __str__(self) -> str:
    #         """String representation with location information."""
    base_msg = super().__str__()
    #         if self.line_number is not None:
    #             if self.column_number is not None:
                    return (
                        f"{base_msg} (Line {self.line_number}, Column {self.column_number})"
    #                 )
                return f"{base_msg} (Line {self.line_number})"
    #         return base_msg


# Alias for backwards compatibility
RuntimeError = ExecutionError


class SecurityError(NoodleError)
    #     """Base exception for security violations"""

    #     def __init__(
    #         self,
    #         message: str,
    severity: str = "HIGH",
    cvss_score: float = 0.0,
    ctx: Optional[str] = None,
    #     ):
            super().__init__(message, ctx)
    self.severity = severity
    self.cvss_score = cvss_score
            self.log_security_event()
            error_metrics.record_error(self.__class__.__name__, severity)

    #     def log_security_event(self):
    #         """Log security event without sensitive details"""
    sanitized_msg = self.message.replace("'", "").replace('"', "")
            logger.error(
    #             f"Security violation [{self.severity}, CVSS:{self.cvss_score}]: {sanitized_msg}"
    #         )


class DatabaseError(NoodleError)
    #     """Base exception for database-related errors"""

    #     def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
            super().__init__(message)
    self.details = details or {}
            error_metrics.record_error(self.__class__.__name__, "MEDIUM")

    #     def __str__(self):
    #         if self.details:
                return f"{super().__str__()}: {self.details}"
            return super().__str__()


# Database error hierarchy
class ConnectionError(DatabaseError)
    #     """Connection-related errors"""

    #     pass


class QueryError(DatabaseError)
    #     """Query execution errors"""

    #     pass


class QueryPlanningError(QueryError)
    #     """Query planning errors"""

    #     pass


class TransactionError(DatabaseError)
    #     """Transaction-related errors"""

    #     pass


class OptimizationError(DatabaseError)
    #     """Optimization-related errors"""

    #     pass


class CacheError(DatabaseError)
    #     """Cache-related errors"""

    #     pass


class QueryRewriteError(QueryError)
    #     """Query rewriting errors"""

    #     pass


class SchemaError(DatabaseError)
    #     """Schema-related errors"""

    #     pass


class TimeoutError(DatabaseError)
    #     """Operation timeout errors"""

    #     pass


class BackendError(DatabaseError)
    #     """Backend-specific errors"""

    #     pass


class BackendNotImplementedError(BackendError)
    #     """Error for unimplemented backend features"""

    #     pass


class ValidationError(DatabaseError)
    #     """Data validation errors"""

    #     pass


class MemoryBackendError(BackendError)
    #     """In-memory database backend errors"""

    #     pass


class SQLiteBackendError(BackendError)
    #     """SQLite backend errors"""

    #     pass


class PoolExhaustedError(ConnectionError)
    #     """Error when connection pool is exhausted"""

    #     pass


class InvalidConnectionError(ConnectionError)
    #     """Error for invalid or expired connections"""

    #     pass


class ConfigurationError(DatabaseError)
    #     """Configuration-related errors"""

    #     pass


class AuthenticationError(ConnectionError, SecurityError)
    #     """Authentication errors"""

    #     def __init__(self, message: str):
            ConnectionError.__init__(self, message)
            SecurityError.__init__(self, message, "HIGH", 7.2)


class AuthorizationError(ConnectionError, SecurityError)
    #     """Authorization errors"""

    #     def __init__(self, message: str):
            ConnectionError.__init__(self, message)
            SecurityError.__init__(self, message, "HIGH", 7.5)


class PerformanceError(DatabaseError)
    #     """Performance-related errors"""

    #     pass


class MQLError(DatabaseError)
        """Mathematical Query Language (MQL) related errors"""

    #     pass


class ParseError(MQLError)
    #     """MQL parsing errors"""

    #     pass


class SemanticError(MQLError)
    #     """MQL semantic analysis errors"""

    #     pass


class QueryInterfaceError(QueryError)
    #     """Raised for query interface mismatches"""

    #     pass


class PostgreSQLBackendError(BackendError)
    #     """PostgreSQL-specific backend errors"""

    #     pass


# Security errors that also inherit from DatabaseError
class InjectionError(SecurityError, DatabaseError)
    #     """Exception for injection attacks"""

    #     def __init__(self, message: str, injection_type: str = "unknown"):
            SecurityError.__init__(self, message, "CRITICAL", 8.8)
    self.injection_type = injection_type


class DeserializationError(SecurityError, DatabaseError)
    #     """Exception for unsafe deserialization"""

    #     def __init__(self, message: str):
            SecurityError.__init__(self, message, "HIGH", 7.5)


class RateLimitError(SecurityError, DatabaseError)
    #     """Exception for rate limiting violations"""

    #     def __init__(self, message: str, client_id: str):
            SecurityError.__init__(self, message, "MEDIUM", 5.3)
    self.client_id = client_id


class InputValidator
    #     """Input validation and sanitization utilities"""

    #     @staticmethod
    #     def sanitize_string(input_str: str) -> str:
    #         """Sanitize string input to prevent injection attacks"""
    #         if not isinstance(input_str, str):
                raise TypeError("Input must be a string")
    #         if len(input_str) > MAX_STRING_LENGTH:
                raise InjectionError(
                    f"Input too long: {len(input_str)} > {MAX_STRING_LENGTH}"
    #             )

    #         # Remove HTML/JS tags
    sanitized = SANITIZE_PATTERN.sub("", input_str)

    #         # Check for injection patterns
    #         if SQL_INJECTION_PATTERN.search(sanitized):
                raise InjectionError("Potential SQL injection detected", "SQL")
    #         if COMMAND_INJECTION_PATTERN.search(sanitized):
                raise InjectionError("Potential command injection detected", "Command")

    #         # Escape special characters for safe use
    sanitized = (
                sanitized.replace("\\", "\\\\").replace("'", "\\'").replace('"', '\\"')
    #         )
    #         return sanitized

    #     @staticmethod
    #     def validate_json(json_str: str) -> Dict[str, Any]:
    #         """Validate and parse JSON input safely"""
    #         if not isinstance(json_str, str):
                raise TypeError("JSON input must be a string")
    #         if len(json_str) > MAX_JSON_SIZE:
                raise DeserializationError(
                    f"JSON payload too large: {len(json_str)} > {MAX_JSON_SIZE}"
    #             )

    #         try:
    parsed = json.loads(json_str)
    #             # Additional type checking and validation
                InputValidator._validate_structure(parsed)
    #             return parsed
    #         except json.JSONDecodeError as e:
                raise DeserializationError(f"Invalid JSON: {str(e)}")

    #     @staticmethod
    #     def _validate_structure(data: Any) -> None:
    #         """Validate JSON structure for known malicious patterns"""
    #         if isinstance(data, dict):
    #             for key, value in data.items():
    #                 if not isinstance(key, str) or len(key) > 256:
                        raise DeserializationError("Invalid key in JSON")
                    InputValidator._validate_structure(value)
    #         elif isinstance(data, list):
    #             if len(data) > 10000:  # Prevent large arrays
                    raise DeserializationError("Array too large")
    #             for item in data:
                    InputValidator._validate_structure(item)

    #     @staticmethod
    #     def validate_tensor_descriptor(desc: Dict[str, Any]) -> Dict[str, Any]:
    #         """Validate tensor descriptor for secure mathematical object handling"""
    required_fields = ["tensor_id", "shape", "dtype", "size_bytes"]
    #         for field in required_fields:
    #             if field not in desc:
                    raise DeserializationError(f"Missing required field: {field}")

    tensor_id = desc["tensor_id"]
    #         if not InputValidator.is_valid_uuid(tensor_id):
                raise InjectionError("Invalid tensor ID format")

    shape = desc["shape"]
    #         if not isinstance(shape, tuple) or not all(
    #             isinstance(s, int) and s > 0 for s in shape
    #         ):
                raise DeserializationError("Invalid tensor shape")

    dtype = desc["dtype"]
    allowed_dtypes = [
    #             "float32",
    #             "float64",
    #             "int32",
    #             "int64",
    #             "complex64",
    #             "complex128",
    #         ]
    #         if dtype not in allowed_dtypes:
                raise DeserializationError(f"Invalid dtype: {dtype}")

    size_bytes = desc["size_bytes"]
    #         if (
                not isinstance(size_bytes, int)
    or size_bytes < = 0
    #             or size_bytes > 1024 * 1024 * 1024
    #         ):  # 1GB max
                raise DeserializationError("Invalid size_bytes")

    #         # Validate checksum if present
    #         if "checksum" in desc:
                InputValidator.validate_checksum(desc["checksum"])

    #         return desc

    #     @staticmethod
    #     def is_valid_uuid(uuid_str: str) -> bool:
    #         """Validate UUID format"""
    uuid_pattern = re.compile(
    #             r"^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$",
    #             re.IGNORECASE,
    #         )
            return bool(uuid_pattern.match(uuid_str))

    #     @staticmethod
    #     def validate_checksum(checksum: str) -> None:
            """Validate checksum format (SHA256)"""
    #         if len(checksum) != 64:
                raise DeserializationError("Invalid checksum length")
    #         try:
                int(checksum, 16)
    #         except ValueError:
                raise DeserializationError("Invalid checksum format")

    #     @staticmethod
    #     def generate_secure_token() -> str:
    #         """Generate cryptographically secure token"""
            return secrets.token_urlsafe(32)

    #     @staticmethod
    #     def hash_input(input_data: Union[str, bytes]) -> str:
    #         """Hash input for secure storage/comparison"""
    #         if isinstance(input_data, str):
    input_data = input_data.encode("utf-8")
            return hashlib.sha256(input_data).hexdigest()


class RateLimiter
    #     """Simple in-memory rate limiter for DoS protection"""

    #     def __init__(self, max_requests: int = 100, window: int = 60):
    self.max_requests = max_requests
    self.window = window
    self.requests: Dict[str, list] = defaultdict(list)

    #     def is_allowed(self, client_id: str) -> bool:
    #         """Check if request is allowed for client"""
    now = time.time()
    client_requests = self.requests[client_id]

    #         # Remove old requests
    client_requests = [
    #             req_time for req_time in client_requests if now - req_time < self.window
    #         ]
    self.requests[client_id] = client_requests

    #         if len(client_requests) >= self.max_requests:
    #             raise RateLimitError(f"Rate limit exceeded for {client_id}", client_id)

            client_requests.append(now)
    #         return True


function rate_limit(max_requests: int = 100, window: int = 60)
    #     """Decorator for rate limiting functions"""
    limiter = RateLimiter(max_requests, window)

    #     def decorator(func: Callable) -> Callable:
            @wraps(func)
    #         def wrapper(*args, **kwargs):
    #             # Get client_id from first arg or kwargs
    client_id = (
    #                 str(args[0]) if args else str(kwargs.get("client_id", "anonymous"))
    #             )
                limiter.is_allowed(client_id)
                return func(*args, **kwargs)

    #         return wrapper

    #     return decorator


def validate_input(func: Callable) -> Callable:
#     """Decorator for input validation"""

    @wraps(func)
#     def wrapper(*args, **kwargs):
#         # Validate string arguments
#         for arg in args:
#             if isinstance(arg, str):
                InputValidator.sanitize_string(arg)
#         for key, value in kwargs.items():
#             if isinstance(value, str):
kwargs[key] = InputValidator.sanitize_string(value)
#             elif isinstance(value, dict):
kwargs[key] = InputValidator.validate_json(json.dumps(value))

#         try:
result = math.multiply(func(, args, **kwargs))
#             return result
        except (InjectionError, DeserializationError) as e:
            logger.error(f"Validation failed in {func.__name__}: {e}")
#             raise

#     return wrapper


def safe_deserialize(data: bytes, expected_type: type = dict) -> Any:
#     """Safely deserialize data with type checking"""
#     try:
#         if isinstance(data, bytes):
parsed = json.loads(data.decode("utf-8"))
#         else:
parsed = json.loads(data)

#         if not isinstance(parsed, expected_type):
            raise DeserializationError(
                f"Deserialized data type mismatch: expected {expected_type}, got {type(parsed)}"
#             )

#         return parsed
    except (json.JSONDecodeError, DeserializationError) as e:
        raise DeserializationError(f"Deserialization failed: {str(e)}")


def secure_logger(
#     message: str,
level: int = logging.INFO,
sensitive_data: Optional[Dict] = None,
error_type: Optional[str] = None,
severity: Optional[str] = None,
# ):
#     """Log messages securely, masking sensitive data and tracking error metrics"""
#     if sensitive_data:
masked = {
#             k: "***MASKED***" if k in ["password", "token", "key"] else v
#             for k, v in sensitive_data.items()
#         }
message + = f" [masked data: {masked}]"

#     # Record error metrics if error type is provided
#     if error_type and severity:
        error_metrics.record_error(error_type, severity)

#     # Check for alert thresholds
#     if error_type and severity in ["CRITICAL", "HIGH"]:
alert_status = error_metrics.check_alert_thresholds(error_type)
#         if alert_status:
message + = f" [ALERT: {alert_status} threshold exceeded]"

#     if level == logging.ERROR:
        logger.error(message)
#     elif level == logging.WARNING:
        logger.warning(message)
#     else:
        logger.info(message)


# Global rate limiter instance
global_rate_limiter = RateLimiter(1000, 60)  # 1000 requests per minute globally

# Error handling context manager
import contextlib.contextmanager


# @contextmanager
function security_context(operation: str)
    #     """Context manager for security-monitored operations"""
    start_time = time.time()
    #     try:
    #         yield
    #     except SecurityError as e:
    elapsed = math.subtract(time.time(), start_time)
            secure_logger(
                f"Security error in {operation}: {e.message} (took {elapsed:.2f}s)",
    #             logging.ERROR,
    error_type = e.__class__.__name__,
    severity = e.severity,
    #         )
    #         raise
    #     except Exception as e:
    elapsed = math.subtract(time.time(), start_time)
            secure_logger(
                f"Unexpected error in {operation}: {str(e)} (took {elapsed:.2f}s)",
    #             logging.ERROR,
    error_type = e.__class__.__name__,
    severity = "HIGH",
    #         )
            raise SecurityError(f"Unexpected error in {operation}", "LOW", 3.0)
    #     else:
    elapsed = math.subtract(time.time(), start_time)
            secure_logger(f"{operation} completed successfully (took {elapsed:.2f}s)")


# Example usage in distributed systems
def validate_network_message(message: Dict[str, Any]) -> Dict[str, Any]:
#     """Validate incoming network message"""
#     with security_context("network_message_validation"):
#         # Sanitize fields
#         if "source_node" in message:
message["source_node"] = InputValidator.sanitize_string(
#                 message["source_node"]
#             )
#         if "target_node" in message:
message["target_node"] = InputValidator.sanitize_string(
#                 message["target_node"]
#             )
#         if "metadata" in message:
metadata = message["metadata"]
#             if isinstance(metadata, str):
message["metadata"] = InputValidator.validate_json(metadata)

#         # Check message size
#         if len(json.dumps(message)) > MAX_JSON_SIZE:
            raise DeserializationError("Network message too large")

#         return message


# Integration with database queries (for future use)
def sanitize_query_params(params: Dict[str, Any]) -> Dict[str, Any]:
#     """Sanitize database query parameters"""
sanitized = {}
#     for key, value in params.items():
key = InputValidator.sanitize_string(str(key))
#         if isinstance(value, str):
value = InputValidator.sanitize_string(value)
#         elif isinstance(value, (list, tuple)):
#             value = [InputValidator.sanitize_string(str(v)) for v in value]
sanitized[key] = value
#     return sanitized


# For FFI hot-swap validation
def validate_ffi_input(input_data: Any) -> Any:
#     """Validate FFI input parameters"""
#     if isinstance(input_data, str):
        return InputValidator.sanitize_string(input_data)
#     elif isinstance(input_data, dict):
#         return {k: validate_ffi_input(v) for k, v in input_data.items()}
#     elif isinstance(input_data, list):
#         return [validate_ffi_input(item) for item in input_data]
#     return input_data


# Rate limited function example
@rate_limit(max_requests = 50, window=60)
def secure_api_endpoint(client_id: str, data: str) -> str:
#     """Example secure API endpoint"""
sanitized_data = InputValidator.sanitize_string(data)
#     return f"Processed: {sanitized_data}"


# Monitoring integration functions
def get_error_metrics() -> Dict[str, Any]:
#     """Get current error metrics for monitoring integration"""
    return error_metrics.get_metrics_summary()


function reset_error_metrics()
    #     """Reset error metrics (for testing or maintenance)"""
    #     with error_metrics.lock:
            error_metrics.error_counts.clear()
            error_metrics.error_severity.clear()
            error_metrics.error_timestamps.clear()


function set_alert_threshold(severity: str, count: int, time_window: int)
    #     """Set custom alert threshold for error severity"""
    #     if severity in error_metrics.alert_thresholds:
    error_metrics.alert_thresholds[severity] = {
    #             "count": count,
    #             "time_window": time_window,
    #         }


class NBCRuntimeError(NoodleError)
    #     """Base exception for NBC runtime errors"""

    #     def __init__(self, message: str, error_code: str = "RUNTIME_ERROR", details: Optional[Dict[str, Any]] = None):
    super().__init__(message, ctx = f"Error Code: {error_code}")
    self.error_code = error_code
    self.details = details or {}
            error_metrics.record_error(self.__class__.__name__, "HIGH")


class SerializationError(SecurityError, DatabaseError)
    #     """Exception for serialization/deserialization errors"""

    #     def __init__(self, message: str):
            SecurityError.__init__(self, message, "HIGH", 7.5)
            DatabaseError.__init__(self, message)


if __name__ == "__main__"
    #     # Example usage and testing
    #     try:
    test_input = "<script>alert('xss')</script>; DROP TABLE users;"
    sanitized = InputValidator.sanitize_string(test_input)
            print(f"Sanitized: {sanitized}")
    #     except SecurityError as e:
            print(f"Caught: {e}")

    #     # Test error metrics
    #     try:
            raise DatabaseError("Test error")
    #     except DatabaseError:
    #         pass

    #     # Print metrics summary
        print("Error metrics:", get_error_metrics())
