# Converted from Python to NoodleCore
# Original file: src

# """
# Optimization Module Errors
# --------------------------
# Custom exceptions for the optimization module.
# """


class OptimizationError(Exception)
    #     """Base exception for optimization module errors."""

    #     pass


class JITCompilationError(OptimizationError):""Exception raised when JIT compilation fails."""

    #     def __init__(
    self, message: str, function_name: str = None, bytecode_hash: str = None
    #     ):
    self.message = message
    self.function_name = function_name
    self.bytecode_hash = bytecode_hash
            super().__init__(self.message)

    #     def __str__(self):
    #         if self.function_name and self.bytecode_hash:
    #             return f"JIT compilation failed for {self.function_name} ({self.bytecode_hash[:8]}...): {self.message}"
    #         return self.message


class MLIRError(OptimizationError)
    #     """Exception raised when MLIR operations fail."""

    #     def __init__(self, message: str, mlir_code: str = None, error_details: str = None):
    self.message = message
    self.mlir_code = mlir_code
    self.error_details = error_details
            super().__init__(self.message)

    #     def __str__(self):
    result = f"MLIR error: {self.message}"
    #         if self.error_details:
    result + = f" - Details: {self.error_details}"
    #         return result


class CacheError(OptimizationError)
    #     """Exception raised when cache operations fail."""

    #     def __init__(self, message: str, cache_key: str = None):
    self.message = message
    self.cache_key = cache_key
            super().__init__(self.message)

    #     def __str__(self):
    #         if self.cache_key:
    #             return f"Cache error for {self.cache_key}: {self.message}"
    #         return self.message


class ProfilerError(OptimizationError)
    #     """Exception raised when profiling operations fail."""

    #     def __init__(self, message: str, function_name: str = None):
    self.message = message
    self.function_name = function_name
            super().__init__(self.message)

    #     def __str__(self):
    #         if self.function_name:
    #             return f"Profiler error for {self.function_name}: {self.message}"
    #         return self.message


class OptimizationTimeoutError(OptimizationError)
    #     """Exception raised when optimization operations time out."""

    #     def __init__(
    self, message: str, operation: str = None, timeout_seconds: float = None
    #     ):
    self.message = message
    self.operation = operation
    self.timeout_seconds = timeout_seconds
            super().__init__(self.message)

    #     def __str__(self):
    result = f"Optimization timeout: {self.message}"
    #         if self.operation:
    result + = f" (Operation: {self.operation})"
    #         if self.timeout_seconds:
    result + = f" (Timeout: {self.timeout_seconds}s)"
    #         return result


class ConfigurationError(OptimizationError)
    #     """Exception raised when configuration is invalid."""

    #     def __init__(
    self, message: str, config_field: str = None, expected_value: str = None
    #     ):
    self.message = message
    self.config_field = config_field
    self.expected_value = expected_value
            super().__init__(self.message)

    #     def __str__(self):
    result = f"Configuration error: {self.message}"
    #         if self.config_field:
    result + = f" (Field: {self.config_field})"
    #         if self.expected_value:
    result + = f" (Expected: {self.expected_value})"
    #         return result


class ResourceError(OptimizationError)
    #     """Exception raised when resource limits are exceeded."""

    #     def __init__(
    #         self,
    #         message: str,
    resource_type: str = None,
    limit: int = None,
    current: int = None,
    #     ):
    self.message = message
    self.resource_type = resource_type
    self.limit = limit
    self.current = current
            super().__init__(self.message)

    #     def __str__(self):
    result = f"Resource error: {self.message}"
    #         if self.resource_type:
    result + = f" (Resource: {self.resource_type})"
    #         if self.limit is not None and self.current is not None:
    result + = f" (Limit: {self.limit}, Current: {self.current})"
    #         return result


class MemoryError(OptimizationError)
    #     """Exception raised when memory operations fail."""

    #     def __init__(self, message: str, memory_address: int = None, size: int = None):
    self.message = message
    self.memory_address = memory_address
    self.size = size
            super().__init__(self.message)

    #     def __str__(self):
    result = f"Memory error: {self.message}"
    #         if self.memory_address is not None:
    result + = f" (Address: 0x{self.memory_address:x})"
    #         if self.size is not None:
    result + = f" (Size: {self.size} bytes)"
    #         return result


class ThreadError(OptimizationError)
    #     """Exception raised when thread operations fail."""

    #     def __init__(self, message: str, thread_id: int = None, operation: str = None):
    self.message = message
    self.thread_id = thread_id
    self.operation = operation
            super().__init__(self.message)

    #     def __str__(self):
    result = f"Thread error: {self.message}"
    #         if self.thread_id is not None:
    result + = f" (Thread ID: {self.thread_id})"
    #         if self.operation:
    result + = f" (Operation: {self.operation})"
    #         return result


class ValidationError(OptimizationError)
    #     """Exception raised when validation fails."""

    #     def __init__(self, message: str, validation_type: str = None, value: str = None):
    self.message = message
    self.validation_type = validation_type
    self.value = value
            super().__init__(self.message)

    #     def __str__(self):
    result = f"Validation error: {self.message}"
    #         if self.validation_type:
    result + = f" (Type: {self.validation_type})"
    #         if self.value:
    result + = f" (Value: {self.value})"
    #         return result


class IntegrationError(OptimizationError)
    #     """Exception raised when external integration fails."""

    #     def __init__(
    self, message: str, integration_target: str = None, error_code: str = None
    #     ):
    self.message = message
    self.integration_target = integration_target
    self.error_code = error_code
            super().__init__(self.message)

    #     def __str__(self):
    result = f"Integration error: {self.message}"
    #         if self.integration_target:
    result + = f" (Target: {self.integration_target})"
    #         if self.error_code:
    result + = f" (Error Code: {self.error_code})"
    #         return result
