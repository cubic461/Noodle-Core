# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# NBC Runtime Errors
# ------------------
# Error classes and exceptions for NBC runtime.
# """

import typing.Optional


class NBCRuntimeError(Exception)
    #     """Base exception for NBC runtime errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
    self.message = message
    self.position = position
    self.error_code = error_code
            super().__init__(self.get_full_message())

    #     def get_full_message(self) -> str:
    #         """Get the full error message including position and error code."""
    parts = [self.message]
    #         if self.position:
                parts.append(f"at {self.position}")
    #         if self.error_code:
                parts.append(f"(code: {self.error_code})")
            return " ".join(parts)


class NBCCompilationError(NBCRuntimeError)
    #     """Exception raised during NBC compilation."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "COMPILATION_ERROR")


class NBCExecutionError(NBCRuntimeError)
    #     """Exception raised during NBC execution."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "EXECUTION_ERROR")


class NBCMemoryError(NBCRuntimeError)
    #     """Exception raised for memory-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "MEMORY_ERROR")


class NBCTypeError(NBCRuntimeError)
    #     """Exception raised for type-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "TYPE_ERROR")


class NBCValueError(NBCRuntimeError)
    #     """Exception raised for value-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "VALUE_ERROR")


class NBCIndexError(NBCRuntimeError)
    #     """Exception raised for index-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "INDEX_ERROR")


class NBCKeyError(NBCRuntimeError)
    #     """Exception raised for key-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "KEY_ERROR")


class NBCAttributeError(NBCRuntimeError)
    #     """Exception raised for attribute-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "ATTRIBUTE_ERROR")


class NBCImportError(NBCRuntimeError)
    #     """Exception raised for import-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "IMPORT_ERROR")


class NBCSecurityError(NBCRuntimeError)
    #     """Exception raised for security-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "SECURITY_ERROR")


class NBCNetworkError(NBCRuntimeError)
    #     """Exception raised for network-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NETWORK_ERROR")


class NBCDatabaseError(NBCRuntimeError)
    #     """Exception raised for database-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "DATABASE_ERROR")


class NBCDistributedError(NBCRuntimeError)
    #     """Exception raised for distributed system errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "DISTRIBUTED_ERROR")


class NBCResourceError(NBCRuntimeError)
    #     """Exception raised for resource-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "RESOURCE_ERROR")


class NBCTimeoutError(NBCRuntimeError)
    #     """Exception raised for timeout-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "TIMEOUT_ERROR")


class NBCConfigurationError(NBCRuntimeError)
    #     """Exception raised for configuration-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "CONFIGURATION_ERROR")


class NBCValidationError(NBCRuntimeError)
    #     """Exception raised for validation-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "VALIDATION_ERROR")


class NBCPermissionError(NBCRuntimeError)
    #     """Exception raised for permission-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PERMISSION_ERROR")


class NBCIOError(NBCRuntimeError)
    #     """Exception raised for I/O-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "IO_ERROR")


class NBCMathError(NBCRuntimeError)
    #     """Exception raised for mathematical operation errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "MATH_ERROR")


class NBCMatrixError(NBCRuntimeError)
    #     """Exception raised for matrix operation errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "MATRIX_ERROR")


class NBCTensorError(NBCRuntimeError)
    #     """Exception raised for tensor operation errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "TENSOR_ERROR")


class NBCGPUError(NBCRuntimeError)
    #     """Exception raised for GPU-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "GPU_ERROR")


class NBCParallelError(NBCRuntimeError)
    #     """Exception raised for parallel execution errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PARALLEL_ERROR")


class NBCAsyncError(NBCRuntimeError)
    #     """Exception raised for async operation errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "ASYNC_ERROR")


class NBCSerializationError(NBCRuntimeError)
    #     """Exception raised for serialization errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "SERIALIZATION_ERROR")


class NBCDeserializationError(NBCRuntimeError)
    #     """Exception raised for deserialization errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "DESERIALIZATION_ERROR")


class NBCCompressionError(NBCRuntimeError)
    #     """Exception raised for compression errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "COMPRESSION_ERROR")


class NBCDecompressionError(NBCRuntimeError)
    #     """Exception raised for decompression errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "DECOMPRESSION_ERROR")


class NBCEncryptionError(NBCRuntimeError)
    #     """Exception raised for encryption errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "ENCRYPTION_ERROR")


class NBCDecryptionError(NBCRuntimeError)
    #     """Exception raised for decryption errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "DECRYPTION_ERROR")


class NBCHashError(NBCRuntimeError)
    #     """Exception raised for hashing errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "HASH_ERROR")


class NBCSignatureError(NBCRuntimeError)
    #     """Exception raised for signature errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "SIGNATURE_ERROR")


class NBCCertificateError(NBCRuntimeError)
    #     """Exception raised for certificate errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "CERTIFICATE_ERROR")


class NBCSSLError(NBCRuntimeError)
    #     """Exception raised for SSL/TLS errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "SSL_ERROR")


class NBCWebSocketError(NBCRuntimeError)
    #     """Exception raised for WebSocket errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "WEBSOCKET_ERROR")


class NBCRESTError(NBCRuntimeError)
    #     """Exception raised for REST API errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "REST_ERROR")


class GraphQLError(NBCRuntimeError)
    #     """Exception raised for GraphQL errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "GRAPHQL_ERROR")


class NBCPluginError(NBCRuntimeError)
    #     """Exception raised for plugin-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PLUGIN_ERROR")


class NBCExtensionError(NBCRuntimeError)
    #     """Exception raised for extension-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "EXTENSION_ERROR")


class NBCModuleError(NBCRuntimeError)
    #     """Exception raised for module-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "MODULE_ERROR")


class NBCPackageError(NBCRuntimeError)
    #     """Exception raised for package-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PACKAGE_ERROR")


class NBCDependencyError(NBCRuntimeError)
    #     """Exception raised for dependency-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "DEPENDENCY_ERROR")


class NBCVersionError(NBCRuntimeError)
    #     """Exception raised for version-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "VERSION_ERROR")


class NBCCompatibilityError(NBCRuntimeError)
    #     """Exception raised for compatibility-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "COMPATIBILITY_ERROR")


class NBCPlatformError(NBCRuntimeError)
    #     """Exception raised for platform-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PLATFORM_ERROR")


class NBCArchitectureError(NBCRuntimeError)
    #     """Exception raised for architecture-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "ARCHITECTURE_ERROR")


class NBCSystemError(NBCRuntimeError)
    #     """Exception raised for system-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "SYSTEM_ERROR")


class NBCEnvironmentError(NBCRuntimeError)
    #     """Exception raised for environment-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "ENVIRONMENT_ERROR")


class NBCConfigurationFileError(NBCRuntimeError)
    #     """Exception raised for configuration file-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "CONFIG_FILE_ERROR")


class NBCLogFileError(NBCRuntimeError)
    #     """Exception raised for log file-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "LOG_FILE_ERROR")


class NBCCacheError(NBCRuntimeError)
    #     """Exception raised for cache-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "CACHE_ERROR")


class NBCSessionError(NBCRuntimeError)
    #     """Exception raised for session-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "SESSION_ERROR")


class NBCAuthenticationError(NBCRuntimeError)
    #     """Exception raised for authentication-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "AUTHENTICATION_ERROR")


class NBCAuthorizationError(NBCRuntimeError)
    #     """Exception raised for authorization-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "AUTHORIZATION_ERROR")


class NBCRateLimitError(NBCRuntimeError)
    #     """Exception raised for rate limit-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "RATE_LIMIT_ERROR")


class NBCQuotaError(NBCRuntimeError)
    #     """Exception raised for quota-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "QUOTA_ERROR")


class NBCBillingError(NBCRuntimeError)
    #     """Exception raised for billing-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "BILLING_ERROR")


class NBCSubscriptionError(NBCRuntimeError)
    #     """Exception raised for subscription-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "SUBSCRIPTION_ERROR")


class NBCPaymentError(NBCRuntimeError)
    #     """Exception raised for payment-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PAYMENT_ERROR")


class NBCRefundError(NBCRuntimeError)
    #     """Exception raised for refund-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "REFUND_ERROR")


class NBCInvoiceError(NBCRuntimeError)
    #     """Exception raised for invoice-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "INVOICE_ERROR")


class NBCReceiptError(NBCRuntimeError)
    #     """Exception raised for receipt-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "RECEIPT_ERROR")


class NBCTransactionError(NBCRuntimeError)
    #     """Exception raised for transaction-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "TRANSACTION_ERROR")


class NBCOrderError(NBCRuntimeError)
    #     """Exception raised for order-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "ORDER_ERROR")


class NBCProductError(NBCRuntimeError)
    #     """Exception raised for product-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PRODUCT_ERROR")


class NBCServiceError(NBCRuntimeError)
    #     """Exception raised for service-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "SERVICE_ERROR")


class NBCFeatureError(NBCRuntimeError)
    #     """Exception raised for feature-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "FEATURE_ERROR")


class NBCCapabilityError(NBCRuntimeError)
    #     """Exception raised for capability-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "CAPABILITY_ERROR")


class NBCFunctionalityError(NBCRuntimeError)
    #     """Exception raised for functionality-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "FUNCTIONALITY_ERROR")


class NBCOperationError(NBCRuntimeError)
    #     """Exception raised for operation-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "OPERATION_ERROR")


class NBCProcessError(NBCRuntimeError)
    #     """Exception raised for process-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PROCESS_ERROR")


class NBCThreadError(NBCRuntimeError)
    #     """Exception raised for thread-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "THREAD_ERROR")


class NBCTaskError(NBCRuntimeError)
    #     """Exception raised for task-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "TASK_ERROR")


class NBCJobError(NBCRuntimeError)
    #     """Exception raised for job-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "JOB_ERROR")


class NBCWorkflowError(NBCRuntimeError)
    #     """Exception raised for workflow-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "WORKFLOW_ERROR")


class NBCPipelineError(NBCRuntimeError)
    #     """Exception raised for pipeline-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_ERROR")


class NBCPipelineStageError(NBCRuntimeError)
    #     """Exception raised for pipeline stage-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_STAGE_ERROR")


class NBCPipelineStepError(NBCRuntimeError)
    #     """Exception raised for pipeline step-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_STEP_ERROR")


class NBCPipelineTaskError(NBCRuntimeError)
    #     """Exception raised for pipeline task-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_TASK_ERROR")


class NBCPipelineJobError(NBCRuntimeError)
    #     """Exception raised for pipeline job-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_JOB_ERROR")


class NBCPipelineWorkflowError(NBCRuntimeError)
    #     """Exception raised for pipeline workflow-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_WORKFLOW_ERROR")


class NBCPipelineProcessError(NBCRuntimeError)
    #     """Exception raised for pipeline process-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_PROCESS_ERROR")


class NBCPipelineThreadError(NBCRuntimeError)
    #     """Exception raised for pipeline thread-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_THREAD_ERROR")


class NBCPipelineOperationError(NBCRuntimeError)
    #     """Exception raised for pipeline operation-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_OPERATION_ERROR")


class NBCPipelineFunctionalityError(NBCRuntimeError)
    #     """Exception raised for pipeline functionality-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(
    #             message, position, error_code or "PIPELINE_FUNCTIONALITY_ERROR"
    #         )


class NBCPipelineCapabilityError(NBCRuntimeError)
    #     """Exception raised for pipeline capability-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_CAPABILITY_ERROR")


class NBCPipelineFeatureError(NBCRuntimeError)
    #     """Exception raised for pipeline feature-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_FEATURE_ERROR")


class NBCPipelineServiceError(NBCRuntimeError)
    #     """Exception raised for pipeline service-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_SERVICE_ERROR")


class NBCPipelineProductError(NBCRuntimeError)
    #     """Exception raised for pipeline product-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_PRODUCT_ERROR")


class NBCPipelineOrderError(NBCRuntimeError)
    #     """Exception raised for pipeline order-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_ORDER_ERROR")


class NBCPipelineTransactionError(NBCRuntimeError)
    #     """Exception raised for pipeline transaction-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_TRANSACTION_ERROR")


class NBCPipelineInvoiceError(NBCRuntimeError)
    #     """Exception raised for pipeline invoice-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_INVOICE_ERROR")


class NBCPipelineReceiptError(NBCRuntimeError)
    #     """Exception raised for pipeline receipt-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_RECEIPT_ERROR")


class NBCPipelinePaymentError(NBCRuntimeError)
    #     """Exception raised for pipeline payment-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_PAYMENT_ERROR")


class NBCPipelineRefundError(NBCRuntimeError)
    #     """Exception raised for pipeline refund-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_REFUND_ERROR")


class NBCPipelineSubscriptionError(NBCRuntimeError)
    #     """Exception raised for pipeline subscription-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_SUBSCRIPTION_ERROR")


class NBCPipelineBillingError(NBCRuntimeError)
    #     """Exception raised for pipeline billing-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_BILLING_ERROR")


class NBCPipelineQuotaError(NBCRuntimeError)
    #     """Exception raised for pipeline quota-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_QUOTA_ERROR")


class NBCPipelineRateLimitError(NBCRuntimeError)
    #     """Exception raised for pipeline rate limit-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_RATE_LIMIT_ERROR")


class NBCPipelineAuthorizationError(NBCRuntimeError)
    #     """Exception raised for pipeline authorization-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(
    #             message, position, error_code or "PIPELINE_AUTHORIZATION_ERROR"
    #         )


class NBCPipelineAuthenticationError(NBCRuntimeError)
    #     """Exception raised for pipeline authentication-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(
    #             message, position, error_code or "PIPELINE_AUTHENTICATION_ERROR"
    #         )


class NBCPipelineSessionError(NBCRuntimeError)
    #     """Exception raised for pipeline session-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_SESSION_ERROR")


class NBCPipelineCacheError(NBCRuntimeError)
    #     """Exception raised for pipeline cache-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_CACHE_ERROR")


class NBCLogFileError(NBCRuntimeError)
    #     """Exception raised for pipeline log file-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_LOG_FILE_ERROR")


class NBCConfigurationFileError(NBCRuntimeError)
    #     """Exception raised for pipeline configuration file-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_CONFIG_FILE_ERROR")


class NBCEnvironmentError(NBCRuntimeError)
    #     """Exception raised for pipeline environment-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_ENVIRONMENT_ERROR")


class NBCSystemError(NBCRuntimeError)
    #     """Exception raised for pipeline system-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_SYSTEM_ERROR")


class NBCArchitectureError(NBCRuntimeError)
    #     """Exception raised for pipeline architecture-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_ARCHITECTURE_ERROR")


class NBCPlatformError(NBCRuntimeError)
    #     """Exception raised for pipeline platform-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_PLATFORM_ERROR")


class NBCCompatibilityError(NBCRuntimeError)
    #     """Exception raised for pipeline compatibility-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(
    #             message, position, error_code or "PIPELINE_COMPATIBILITY_ERROR"
    #         )


class NBCVersionError(NBCRuntimeError)
    #     """Exception raised for pipeline version-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_VERSION_ERROR")


class NBCDependencyError(NBCRuntimeError)
    #     """Exception raised for pipeline dependency-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_DEPENDENCY_ERROR")


class NBCPackageError(NBCRuntimeError)
    #     """Exception raised for pipeline package-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_PACKAGE_ERROR")


class NBCModuleError(NBCRuntimeError)
    #     """Exception raised for pipeline module-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_MODULE_ERROR")


class NBCExtensionError(NBCRuntimeError)
    #     """Exception raised for pipeline extension-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_EXTENSION_ERROR")


class NBCPluginError(NBCRuntimeError)
    #     """Exception raised for pipeline plugin-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_PLUGIN_ERROR")


class NBCRESTError(NBCRuntimeError)
    #     """Exception raised for pipeline REST API errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_REST_ERROR")


class NBCWebSocketError(NBCRuntimeError)
    #     """Exception raised for pipeline WebSocket errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_WEBSOCKET_ERROR")


class NBCSSLError(NBCRuntimeError)
    #     """Exception raised for pipeline SSL/TLS errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_SSL_ERROR")


class NBCCertificateError(NBCRuntimeError)
    #     """Exception raised for pipeline certificate errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_CERTIFICATE_ERROR")


class NBCSignatureError(NBCRuntimeError)
    #     """Exception raised for pipeline signature errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_SIGNATURE_ERROR")


class NBCHashError(NBCRuntimeError)
    #     """Exception raised for pipeline hashing errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_HASH_ERROR")


class NBCEncryptionError(NBCRuntimeError)
    #     """Exception raised for pipeline encryption errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_ENCRYPTION_ERROR")


class NBCDecryptionError(NBCRuntimeError)
    #     """Exception raised for pipeline decryption errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_DECRYPTION_ERROR")


class NBCCompressionError(NBCRuntimeError)
    #     """Exception raised for pipeline compression errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_COMPRESSION_ERROR")


class NBCDecompressionError(NBCRuntimeError)
    #     """Exception raised for pipeline decompression errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(
    #             message, position, error_code or "PIPELINE_DECOMPRESSION_ERROR"
    #         )


class NBCSerializationError(NBCRuntimeError)
    #     """Exception raised for pipeline serialization errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(
    #             message, position, error_code or "PIPELINE_SERIALIZATION_ERROR"
    #         )


class NBCDeserializationError(NBCRuntimeError)
    #     """Exception raised for pipeline deserialization errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(
    #             message, position, error_code or "PIPELINE_DESERIALIZATION_ERROR"
    #         )


class NBCAsyncError(NBCRuntimeError)
    #     """Exception raised for pipeline async operation errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_ASYNC_ERROR")


class NBCParallelError(NBCRuntimeError)
    #     """Exception raised for pipeline parallel execution errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_PARALLEL_ERROR")


class NBCGPUError(NBCRuntimeError)
    #     """Exception raised for pipeline GPU-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_GPU_ERROR")


class NBCTensorError(NBCRuntimeError)
    #     """Exception raised for pipeline tensor operation errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_TENSOR_ERROR")


class NBCMatrixError(NBCRuntimeError)
    #     """Exception raised for pipeline matrix operation errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_MATRIX_ERROR")


class NBCMathError(NBCRuntimeError)
    #     """Exception raised for pipeline mathematical operation errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_MATH_ERROR")


class NBCIOError(NBCRuntimeError)
    #     """Exception raised for pipeline I/O-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_IO_ERROR")


class NBCPermissionError(NBCRuntimeError)
    #     """Exception raised for pipeline permission-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_PERMISSION_ERROR")


class NBCValidationError(NBCRuntimeError)
    #     """Exception raised for pipeline validation-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_VALIDATION_ERROR")


class NBCConfigurationError(NBCRuntimeError)
    #     """Exception raised for pipeline configuration-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(
    #             message, position, error_code or "PIPELINE_CONFIGURATION_ERROR"
    #         )


class NBCTimeoutError(NBCRuntimeError)
    #     """Exception raised for pipeline timeout-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_TIMEOUT_ERROR")


class NBCResourceError(NBCRuntimeError)
    #     """Exception raised for pipeline resource-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_RESOURCE_ERROR")


class NBCDistributedError(NBCRuntimeError)
    #     """Exception raised for pipeline distributed system errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_DISTRIBUTED_ERROR")


class NBCDatabaseError(NBCRuntimeError)
    #     """Exception raised for pipeline database-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_DATABASE_ERROR")


class NBCNetworkError(NBCRuntimeError)
    #     """Exception raised for pipeline network-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_NETWORK_ERROR")


class NBCSecurityError(NBCRuntimeError)
    #     """Exception raised for pipeline security-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_SECURITY_ERROR")


class NBCImportError(NBCRuntimeError)
    #     """Exception raised for pipeline import-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_IMPORT_ERROR")


class NBCAttributeError(NBCRuntimeError)
    #     """Exception raised for pipeline attribute-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_ATTRIBUTE_ERROR")


class NBCKeyError(NBCRuntimeError)
    #     """Exception raised for pipeline key-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_KEY_ERROR")


class NBCIndexError(NBCRuntimeError)
    #     """Exception raised for pipeline index-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_INDEX_ERROR")


class NBCValueError(NBCRuntimeError)
    #     """Exception raised for pipeline value-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_VALUE_ERROR")


class NBCTypeError(NBCRuntimeError)
    #     """Exception raised for pipeline type-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_TYPE_ERROR")


class NBCMemoryError(NBCRuntimeError)
    #     """Exception raised for pipeline memory-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_MEMORY_ERROR")


class NBCExecutionError(NBCRuntimeError)
    #     """Exception raised for pipeline execution errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_EXECUTION_ERROR")


class NBCCompilationError(NBCRuntimeError)
    #     """Exception raised for pipeline compilation errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_COMPILATION_ERROR")


class NBCRuntimeError(NBCRuntimeError)
    #     """Exception raised for pipeline runtime errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_RUNTIME_ERROR")


class NBCPipelineError(NBCRuntimeError)
    #     """Exception raised for pipeline errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PIPELINE_ERROR")


class NBCError(NBCRuntimeError)
    #     """Exception raised for NBC errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_ERROR")


class NBCException(NBCRuntimeError)
    #     """Exception raised for NBC exceptions."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_EXCEPTION")


class NBCFault(NBCRuntimeError)
    #     """Exception raised for NBC faults."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAULT")


class NBCFailure(NBCRuntimeError)
    #     """Exception raised for NBC failures."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAILURE")


class NBCError(NBCRuntimeError)
    #     """Exception raised for NBC errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_ERROR")


class NBCException(NBCRuntimeError)
    #     """Exception raised for NBC exceptions."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_EXCEPTION")


class NBCFault(NBCRuntimeError)
    #     """Exception raised for NBC faults."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAULT")


class NBCFailure(NBCRuntimeError)
    #     """Exception raised for NBC failures."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAILURE")


class NBCError(NBCRuntimeError)
    #     """Exception raised for NBC errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_ERROR")


class NBCException(NBCRuntimeError)
    #     """Exception raised for NBC exceptions."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_EXCEPTION")


class NBCFault(NBCRuntimeError)
    #     """Exception raised for NBC faults."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAULT")


class NBCFailure(NBCRuntimeError)
    #     """Exception raised for NBC failures."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAILURE")


class NBCError(NBCRuntimeError)
    #     """Exception raised for NBC errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_ERROR")


class NBCException(NBCRuntimeError)
    #     """Exception raised for NBC exceptions."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_EXCEPTION")


class NBCFault(NBCRuntimeError)
    #     """Exception raised for NBC faults."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAULT")


class NBCFailure(NBCRuntimeError)
    #     """Exception raised for NBC failures."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAILURE")


class NBCError(NBCRuntimeError)
    #     """Exception raised for NBC errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_ERROR")


class NBCException(NBCRuntimeError)
    #     """Exception raised for NBC exceptions."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_EXCEPTION")


class NBCFault(NBCRuntimeError)
    #     """Exception raised for NBC faults."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAULT")


class NBCFailure(NBCRuntimeError)
    #     """Exception raised for NBC failures."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAILURE")


class NBCError(NBCRuntimeError)
    #     """Exception raised for NBC errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_ERROR")


class NBCException(NBCRuntimeError)
    #     """Exception raised for NBC exceptions."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_EXCEPTION")


class NBCFault(NBCRuntimeError)
    #     """Exception raised for NBC faults."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAULT")


class NBCFailure(NBCRuntimeError)
    #     """Exception raised for NBC failures."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAILURE")


class NBCError(NBCRuntimeError)
    #     """Exception raised for NBC errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_ERROR")


class NBCException(NBCRuntimeError)
    #     """Exception raised for NBC exceptions."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_EXCEPTION")


class NBCFault(NBCRuntimeError)
    #     """Exception raised for NBC faults."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAULT")


class NBCFailure(NBCRuntimeError)
    #     """Exception raised for NBC failures."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAILURE")


class NBCError(NBCRuntimeError)
    #     """Exception raised for NBC errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_ERROR")


class NBCException(NBCRuntimeError)
    #     """Exception raised for NBC exceptions."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_EXCEPTION")


class NBCFault(NBCRuntimeError)
    #     """Exception raised for NBC faults."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAULT")


class NBCFailure(NBCRuntimeError)
    #     """Exception raised for NBC failures."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAILURE")


class NBCError(NBCRuntimeError)
    #     """Exception raised for NBC errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_ERROR")


class NBCException(NBCRuntimeError)
    #     """Exception raised for NBC exceptions."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_EXCEPTION")


class NBCFault(NBCRuntimeError)
    #     """Exception raised for NBC faults."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAULT")


class NBCFailure(NBCRuntimeError)
    #     """Exception raised for NBC failures."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAILURE")


class NBCError(NBCRuntimeError)
    #     """Exception raised for NBC errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_ERROR")


class NBCException(NBCRuntimeError)
    #     """Exception raised for NBC exceptions."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_EXCEPTION")


class NBCFault(NBCRuntimeError)
    #     """Exception raised for NBC faults."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAULT")


class NBCFailure(NBCRuntimeError)
    #     """Exception raised for NBC failures."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAILURE")


class NBCError(NBCRuntimeError)
    #     """Exception raised for NBC errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_ERROR")


class NBCException(NBCRuntimeError)
    #     """Exception raised for NBC exceptions."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_EXCEPTION")


class NBCFault(NBCRuntimeError)
    #     """Exception raised for NBC faults."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAULT")


class NBCFailure(NBCRuntimeError)
    #     """Exception raised for NBC failures."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAILURE")


class NBCError(NBCRuntimeError)
    #     """Exception raised for NBC errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_ERROR")


class NBCException(NBCRuntimeError)
    #     """Exception raised for NBC exceptions."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_EXCEPTION")


class NBCFault(NBCRuntimeError)
    #     """Exception raised for NBC faults."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAULT")


class NBCFailure(NBCRuntimeError)
    #     """Exception raised for NBC failures."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAILURE")


class NBCError(NBCRuntimeError)
    #     """Exception raised for NBC errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_ERROR")


class NBCException(NBCRuntimeError)
    #     """Exception raised for NBC exceptions."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_EXCEPTION")


class NBCFault(NBCRuntimeError)
    #     """Exception raised for NBC faults."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAULT")


class NBCFailure(NBCRuntimeError)
    #     """Exception raised for NBC failures."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAILURE")


class NBCError(NBCRuntimeError)
    #     """Exception raised for NBC errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_ERROR")


class NBCException(NBCRuntimeError)
    #     """Exception raised for NBC exceptions."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_EXCEPTION")


class NBCFault(NBCRuntimeError)
    #     """Exception raised for NBC faults."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAULT")


class NBCFailure(NBCRuntimeError)
    #     """Exception raised for NBC failures."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAILURE")


class NBCError(NBCRuntimeError)
    #     """Exception raised for NBC errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_ERROR")


class NBCException(NBCRuntimeError)
    #     """Exception raised for NBC exceptions."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_EXCEPTION")


class NBCFault(NBCRuntimeError)
    #     """Exception raised for NBC faults."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAULT")


class NBCFailure(NBCRuntimeError)
    #     """Exception raised for NBC failures."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAILURE")


class NBCError(NBCRuntimeError)
    #     """Exception raised for NBC errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_ERROR")


class NBCException(NBCRuntimeError)
    #     """Exception raised for NBC exceptions."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_EXCEPTION")


class NBCFault(NBCRuntimeError)
    #     """Exception raised for NBC faults."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAULT")


class NBCFailure(NBCRuntimeError)
    #     """Exception raised for NBC failures."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAILURE")


class NBCError(NBCRuntimeError)
    #     """Exception raised for NBC errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_ERROR")


class NBCException(NBCRuntimeError)
    #     """Exception raised for NBC exceptions."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_EXCEPTION")


class NBCFault(NBCRuntimeError)
    #     """Exception raised for NBC faults."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAULT")


class NBCFailure(NBCRuntimeError)
    #     """Exception raised for NBC failures."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAILURE")


class NBCError(NBCRuntimeError)
    #     """Exception raised for NBC errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_ERROR")


class NBCException(NBCRuntimeError)
    #     """Exception raised for NBC exceptions."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_EXCEPTION")


class NBCFault(NBCRuntimeError)
    #     """Exception raised for NBC faults."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAULT")


class NBCFailure(NBCRuntimeError)
    #     """Exception raised for NBC failures."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAILURE")


class NBCError(NBCRuntimeError)
    #     """Exception raised for NBC errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_ERROR")


class NBCException(NBCRuntimeError)
    #     """Exception raised for NBC exceptions."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_EXCEPTION")


class NBCFault(NBCRuntimeError)
    #     """Exception raised for NBC faults."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAULT")


class NBCFailure(NBCRuntimeError)
    #     """Exception raised for NBC failures."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "NBC_FAILURE")


class MLIRError(NBCRuntimeError)
    #     """Exception raised for MLIR-related errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "MLIR_ERROR")


class JITCompilationError(NBCRuntimeError)
    #     """Exception raised for JIT compilation errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "JIT_COMPILATION_ERROR")


class PythonFFIError(NBCRuntimeError)
    #     """Exception raised for Python FFI errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "PYTHON_FFI_ERROR")


class JSFFIError(NBCRuntimeError)
    #     """Exception raised for JavaScript FFI errors."""

    #     def __init__(
    #         self,
    #         message: str,
    position: Optional[str] = None,
    error_code: Optional[str] = None,
    #     ):
            super().__init__(message, position, error_code or "JS_FFI_ERROR")
