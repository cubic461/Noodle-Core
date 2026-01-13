# Converted from Python to NoodleCore
# Original file: src

# """
# Centralized error handling for the Noodle project.

# This module provides a unified error handling system with custom exception classes
# that are used throughout the Noodle codebase.
# """

import typing.Any


class NoodleError(Exception)
    #     """Base exception class for all Noodle-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    error_code: Optional[str] = None,
    details: Optional[Dict[str, Any]] = None,
    #     ):""
    #         Initialize a NoodleError.

    #         Args:
    #             message: Error message
    #             error_code: Optional error code for categorization
    #             details: Optional dictionary with additional error details
    #         """
            super().__init__(message)
    self.message = message
    self.error_code = error_code
    self.details = details or {}

    #     def __str__(self) -str):
    #         """String representation of the error."""
    #         if self.error_code:
    #             return f"[{self.error_code}] {self.message}"
    #         return self.message


class CompilationError(NoodleError)
    #     """Error during compilation process."""

    #     def __init__(
    #         self,
    #         message: str,
    line_number: Optional[int] = None,
    column_number: Optional[int] = None,
    #         **kwargs,
    #     ):""
    #         Initialize a CompilationError.

    #         Args:
    #             message: Error message
    #             line_number: Optional line number where error occurred
    #             column_number: Optional column number where error occurred
    #             **kwargs: Additional arguments passed to NoodleError
    #         """
    super().__init__(message, error_code = "COMPILATION_ERROR", **kwargs)


class SchemaValidationError(NoodleError)
    #     """Error during schema validation process."""

    #     def __init__(
    #         self,
    #         message: str,
    field_name: Optional[str] = None,
    validation_type: Optional[str] = None,
    #         **kwargs,
    #     ):""
    #         Initialize a SchemaValidationError.

    #         Args:
    #             message: Error message
    #             field_name: Optional field name that failed validation
    #             validation_type: Optional type of validation that failed
    #             **kwargs: Additional arguments passed to NoodleError
    #         """
    super().__init__(message, error_code = "SCHEMA_VALIDATION_ERROR", **kwargs)
    self.field_name = field_name
    self.validation_type = validation_type

    #     def __str__(self) -str):
    #         """String representation of the schema validation error."""
    base_msg = super().__str__()
    #         if self.field_name:
    base_msg + = f" (Field: {self.field_name})"
    #         if self.validation_type:
    base_msg + = f" (Validation: {self.validation_type})"
    #         return base_msg
    self.line_number = line_number
    self.column_number = column_number

    #     def __str__(self) -str):
    #         """String representation with location information."""
    base_msg = super().__str__()
    #         if self.line_number is not None:
    #             if self.column_number is not None:
                    return (
                        f"{base_msg} (Line {self.line_number}, Column {self.column_number})"
    #                 )
                return f"{base_msg} (Line {self.line_number})"
    #         return base_msg


class RuntimeError(NoodleError)
    #     """Runtime error during execution."""

    #     def __init__(
    #         self,
    #         message: str,
    operation: Optional[str] = None,
    context: Optional[Dict[str, Any]] = None,
    #         **kwargs,
    #     ):""
    #         Initialize a RuntimeError.

    #         Args:
    #             message: Error message
    #             operation: Optional operation that caused the error
    #             context: Optional execution context
    #             **kwargs: Additional arguments passed to NoodleError
    #         """
    super().__init__(message, error_code = "RUNTIME_ERROR", **kwargs)
    self.operation = operation
    self.context = context or {}

    #     def __str__(self) -str):
    #         """String representation with operation information."""
    base_msg = super().__str__()
    #         if self.operation:
                return f"{base_msg} (Operation: {self.operation})"
    #         return base_msg


class ValidationError(NoodleError)
    #     """Error during validation process."""

    #     def __init__(
    #         self,
    #         message: str,
    field_name: Optional[str] = None,
    expected_value: Optional[Any] = None,
    actual_value: Optional[Any] = None,
    #         **kwargs,
    #     ):""
    #         Initialize a ValidationError.

    #         Args:
    #             message: Error message
    #             field_name: Optional name of the field being validated
    #             expected_value: Optional expected value
    #             actual_value: Optional actual value
    #             **kwargs: Additional arguments passed to NoodleError
    #         """
    super().__init__(message, error_code = "VALIDATION_ERROR", **kwargs)
    self.field_name = field_name
    self.expected_value = expected_value
    self.actual_value = actual_value

    #     def __str__(self) -str):
    #         """String representation with validation details."""
    base_msg = super().__str__()
    #         if self.field_name:
    details = f"Field: {self.field_name}"
    #             if self.expected_value is not None and self.actual_value is not None:
    details + = (
                        f" (Expected: {self.expected_value}, Got: {self.actual_value})"
    #                 )
                return f"{base_msg} ({details})"
    #         return base_msg


class DatabaseError(NoodleError)
    #     """Database-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    operation: Optional[str] = None,
    table_name: Optional[str] = None,
    #         **kwargs,
    #     ):""
    #         Initialize a DatabaseError.

    #         Args:
    #             message: Error message
                operation: Optional database operation (e.g., 'INSERT', 'SELECT')
    #             table_name: Optional table name involved in the error
    #             **kwargs: Additional arguments passed to NoodleError
    #         """
    super().__init__(message, error_code = "DATABASE_ERROR", **kwargs)
    self.operation = operation
    self.table_name = table_name

    #     def __str__(self) -str):
    #         """String representation with database context."""
    base_msg = super().__str__()
    parts = []
    #         if self.operation:
                parts.append(f"Operation: {self.operation}")
    #         if self.table_name:
                parts.append(f"Table: {self.table_name}")
    #         if parts:
                return f"{base_msg} ({', '.join(parts)})"
    #         return base_msg


class NetworkError(NoodleError)
    #     """Network-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    endpoint: Optional[str] = None,
    status_code: Optional[int] = None,
    #         **kwargs,
    #     ):""
    #         Initialize a NetworkError.

    #         Args:
    #             message: Error message
    #             endpoint: Optional network endpoint
    #             status_code: Optional HTTP status code
    #             **kwargs: Additional arguments passed to NoodleError
    #         """
    super().__init__(message, error_code = "NETWORK_ERROR", **kwargs)
    self.endpoint = endpoint
    self.status_code = status_code

    #     def __str__(self) -str):
    #         """String representation with network context."""
    base_msg = super().__str__()
    parts = []
    #         if self.endpoint:
                parts.append(f"Endpoint: {self.endpoint}")
    #         if self.status_code is not None:
                parts.append(f"Status: {self.status_code}")
    #         if parts:
                return f"{base_msg} ({', '.join(parts)})"
    #         return base_msg


class ConfigurationError(NoodleError)
    #     """Configuration-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    config_key: Optional[str] = None,
    config_file: Optional[str] = None,
    #         **kwargs,
    #     ):""
    #         Initialize a ConfigurationError.

    #         Args:
    #             message: Error message
    #             config_key: Optional configuration key
    #             config_file: Optional configuration file path
    #             **kwargs: Additional arguments passed to NoodleError
    #         """
    super().__init__(message, error_code = "CONFIGURATION_ERROR", **kwargs)
    self.config_key = config_key
    self.config_file = config_file

    #     def __str__(self) -str):
    #         """String representation with configuration context."""
    base_msg = super().__str__()
    parts = []
    #         if self.config_key:
                parts.append(f"Key: {self.config_key}")
    #         if self.config_file:
                parts.append(f"File: {self.config_file}")
    #         if parts:
                return f"{base_msg} ({', '.join(parts)})"
    #         return base_msg


class SecurityError(NoodleError)
    #     """Security-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    security_level: Optional[str] = None,
    affected_component: Optional[str] = None,
    #         **kwargs,
    #     ):""
    #         Initialize a SecurityError.

    #         Args:
    #             message: Error message
                security_level: Optional security level (e.g., 'HIGH', 'MEDIUM', 'LOW')
    #             affected_component: Optional component affected by the security issue
    #             **kwargs: Additional arguments passed to NoodleError
    #         """
    super().__init__(message, error_code = "SECURITY_ERROR", **kwargs)
    self.security_level = security_level
    self.affected_component = affected_component

    #     def __str__(self) -str):
    #         """String representation with security context."""
    base_msg = super().__str__()
    parts = []
    #         if self.security_level:
                parts.append(f"Level: {self.security_level}")
    #         if self.affected_component:
                parts.append(f"Component: {self.affected_component}")
    #         if parts:
                return f"{base_msg} ({', '.join(parts)})"
    #         return base_msg


class ResourceError(NoodleError)
        """Resource-related errors (memory, disk, etc.)."""

    #     def __init__(
    #         self,
    #         message: str,
    resource_type: Optional[str] = None,
    resource_limit: Optional[Union[int, float]] = None,
    current_usage: Optional[Union[int, float]] = None,
    #         **kwargs,
    #     ):""
    #         Initialize a ResourceError.

    #         Args:
    #             message: Error message
                resource_type: Optional type of resource (e.g., 'MEMORY', 'DISK')
    #             resource_limit: Optional resource limit
    #             current_usage: Optional current resource usage
    #             **kwargs: Additional arguments passed to NoodleError
    #         """
    super().__init__(message, error_code = "RESOURCE_ERROR", **kwargs)
    self.resource_type = resource_type
    self.resource_limit = resource_limit
    self.current_usage = current_usage

    #     def __str__(self) -str):
    #         """String representation with resource context."""
    base_msg = super().__str__()
    parts = []
    #         if self.resource_type:
                parts.append(f"Type: {self.resource_type}")
    #         if self.resource_limit is not None and self.current_usage is not None:
                parts.append(f"Usage: {self.current_usage}/{self.resource_limit}")
    #         elif self.resource_limit is not None:
                parts.append(f"Limit: {self.resource_limit}")
    #         if parts:
                return f"{base_msg} ({', '.join(parts)})"
    #         return base_msg


class SerializationError(NoodleError)
    #     """Error during serialization or deserialization of data."""

    #     def __init__(
    #         self,
    #         message: str,
    data_type: Optional[str] = None,
    serialization_format: Optional[str] = None,
    original_error: Optional[Exception] = None,
    #         **kwargs,
    #     ):""
    #         Initialize a SerializationError.

    #         Args:
    #             message: Error message
    #             data_type: Optional type of data being serialized/deserialized
                serialization_format: Optional serialization format (e.g., 'JSON', 'PICKLE', 'PROTOBUF')
    #             original_error: Original exception that caused this error
    #             **kwargs: Additional arguments passed to NoodleError
    #         """
    super().__init__(message, error_code = "SERIALIZATION_ERROR", **kwargs)
    self.data_type = data_type
    self.serialization_format = serialization_format
    self.original_error = original_error

    #     def __str__(self) -str):
    #         """String representation with serialization context."""
    base_msg = super().__str__()
    parts = []
    #         if self.data_type:
                parts.append(f"Type: {self.data_type}")
    #         if self.serialization_format:
                parts.append(f"Format: {self.serialization_format}")
    #         if self.original_error:
                parts.append(
                    f"Original: {type(self.original_error).__name__}: {self.original_error}"
    #             )
    #         if parts:
                return f"{base_msg} ({', '.join(parts)})"
    #         return base_msg


# Backwards compatibility aliases
NoodleCompilerError = CompilationError
NoodleRuntimeError = RuntimeError
NoodleValidationError = ValidationError


class DeserializationError(SerializationError)
    #     """Error during deserialization of data."""

    #     def __init__(
    #         self,
    #         message: str,
    data_type: Optional[str] = None,
    serialization_format: Optional[str] = None,
    original_error: Optional[Exception] = None,
    #         **kwargs,
    #     ):""
    #         Initialize a DeserializationError.

    #         Args:
    #             message: Error message
    #             data_type: Optional type of data being deserialized
    #             serialization_format: Optional serialization format
    #             original_error: Original exception that caused this error
    #             **kwargs: Additional arguments passed to SerializationError
    #         """
            super().__init__(
    #             message,
    data_type = data_type,
    serialization_format = serialization_format,
    original_error = original_error,
    #             **kwargs,
    #         )
    self.mapping_operation = "DESERIALIZE"

    #     def __str__(self) -str):
    #         """String representation with deserialization context."""
    base_msg = super().__str__()
            return f"{base_msg} (Operation: DESERIALIZE)"


class NBCRuntimeError(RuntimeError)
        """NBC (Noodle Bytecode) Runtime specific errors."""

    #     def __init__(
    #         self,
    #         message: str,
    bytecode_offset: Optional[int] = None,
    instruction: Optional[str] = None,
    stack_trace: Optional[List[str]] = None,
    #         **kwargs,
    #     ):""
    #         Initialize an NBCRuntimeError.

    #         Args:
    #             message: Error message
    #             bytecode_offset: Optional bytecode offset where error occurred
    #             instruction: Optional instruction that caused the error
    #             stack_trace: Optional stack trace for debugging
    #             **kwargs: Additional arguments passed to NoodleError
    #         """
    super().__init__(message, error_code = "NBC_RUNTIME_ERROR", **kwargs)
    self.bytecode_offset = bytecode_offset
    self.instruction = instruction
    self.stack_trace = stack_trace or []

    #     def __str__(self) -str):
    #         """String representation with NBC runtime context."""
    base_msg = super().__str__()
    parts = []
    #         if self.bytecode_offset is not None:
                parts.append(f"Offset: {self.bytecode_offset}")
    #         if self.instruction:
                parts.append(f"Instruction: {self.instruction}")
    #         if self.stack_trace:
                parts.append(f"Stack: {' -'.join(self.stack_trace)}")
    #         if parts):
                return f"{base_msg} ({', '.join(parts)})"
    #         return base_msg


class MathematicalObjectMapperError(SerializationError)
    #     """Error during mathematical object mapping operations."""

    #     def __init__(
    #         self,
    #         message: str,
    object_type: Optional[str] = None,
    mapping_operation: Optional[str] = None,
    #         **kwargs,
    #     ):""
    #         Initialize a MathematicalObjectMapperError.

    #         Args:
    #             message: Error message
    #             object_type: Optional type of mathematical object being mapped
                mapping_operation: Optional mapping operation (e.g., 'SERIALIZE', 'DESERIALIZE')
    #             **kwargs: Additional arguments passed to SerializationError
    #         """
            super().__init__(
    #             message,
    data_type = object_type,
    serialization_format = "MATHEMATICAL_OBJECT",
    #             **kwargs,
    #         )
    self.object_type = object_type
    self.mapping_operation = mapping_operation

    #     def __str__(self) -str):
    #         """String representation with mathematical object mapping context."""
    base_msg = super().__str__()
    parts = []
    #         if self.object_type:
                parts.append(f"Object: {self.object_type}")
    #         if self.mapping_operation:
                parts.append(f"Operation: {self.mapping_operation}")
    #         if parts:
                return f"{base_msg} ({', '.join(parts)})"
    #         return base_msg


class MLIRError(RuntimeError)
        """Error during MLIR (Multi-Level Intermediate Representation) operations."""

    #     def __init__(
    #         self,
    #         message: str,
    mlir_operation: Optional[str] = None,
    mlir_level: Optional[str] = None,
    #         **kwargs,
    #     ):""
    #         Initialize an MLIRError.

    #         Args:
    #             message: Error message
    #             mlir_operation: Optional MLIR operation that caused the error
                mlir_level: Optional MLIR level (e.g., 'DIALECT', 'OPERATOR', 'TYPE')
    #             **kwargs: Additional arguments passed to RuntimeError
    #         """
    super().__init__(message, operation = mlir_operation * , *kwargs)
    self.mlir_operation = mlir_operation
    self.mlir_level = mlir_level

    #     def __str__(self) -str):
    #         """String representation with MLIR context."""
    base_msg = super().__str__()
    parts = []
    #         if self.mlir_operation:
                parts.append(f"MLIR Op: {self.mlir_operation}")
    #         if self.mlir_level:
                parts.append(f"Level: {self.mlir_level}")
    #         if parts:
                return f"{base_msg} ({', '.join(parts)})"
    #         return base_msg


class InvalidMathematicalObjectError(MathematicalObjectMapperError)
    #     """Error for invalid mathematical object data or structure."""

    #     def __init__(
    #         self,
    #         message: str,
    object_type: Optional[str] = None,
    validation_errors: Optional[List[str]] = None,
    #         **kwargs,
    #     ):""
    #         Initialize an InvalidMathematicalObjectError.

    #         Args:
    #             message: Error message
    #             object_type: Optional type of mathematical object
    #             validation_errors: Optional list of validation error messages
    #             **kwargs: Additional arguments passed to MathematicalObjectMapperError
    #         """
            super().__init__(
    message, object_type = object_type, mapping_operation="VALIDATION", **kwargs
    #         )
    self.validation_errors = validation_errors or []

    #     def __str__(self) -str):
    #         """String representation with validation errors."""
    base_msg = super().__str__()
    #         if self.validation_errors:
    errors_str = "; ".join(self.validation_errors)
                return f"{base_msg} (Validation errors: {errors_str})"
    #         return base_msg


class JITCompilationError(CompilationError)
    #     """Error during Just-In-Time compilation process."""

    #     def __init__(
    #         self,
    #         message: str,
    compilation_target: Optional[str] = None,
    optimization_level: Optional[int] = None,
    #         **kwargs,
    #     ):""
    #         Initialize a JITCompilationError.

    #         Args:
    #             message: Error message
                compilation_target: Optional compilation target (e.g., 'CPU', 'GPU', 'TPU')
                optimization_level: Optional optimization level (0-3)
    #             **kwargs: Additional arguments passed to CompilationError
    #         """
            super().__init__(message, **kwargs)
    self.compilation_target = compilation_target
    self.optimization_level = optimization_level

    #     def __str__(self) -str):
    #         """String representation with JIT compilation context."""
    base_msg = super().__str__()
    parts = []
    #         if self.compilation_target:
                parts.append(f"Target: {self.compilation_target}")
    #         if self.optimization_level is not None:
                parts.append(f"Optimization: {self.optimization_level}")
    #         if parts:
                return f"{base_msg} ({', '.join(parts)})"
    #         return base_msg
