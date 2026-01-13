# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# NoodleCore Validator Package
# ----------------------------
# This package provides comprehensive validation for NoodleCore code to ensure
# 100% compliance with the NoodleCore language specification.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

# Import main validator
import .validator.(
#     NoodleCoreValidator,
#     ValidatorConfig,
#     ValidationMode,
#     get_validator,
#     validate_code,
#     validate_file,
#     is_valid_noodlecore
# )

# Import validation components
import .foreign_syntax_detector.(
#     ForeignSyntaxDetector,
#     ValidationIssue,
#     ValidationSeverity,
#     ForeignSyntaxType,
#     ForeignSyntaxPattern
# )

import .ast_verifier.(
#     ASTVerifier,
#     ASTValidationContext,
#     ASTValidationErrorCode
# )

import .auto_corrector.(
#     AutoCorrector,
#     AutoCorrectionResult,
#     Correction,
#     CorrectionResult
# )

import .result_reporter.(
#     ValidationResultReporter,
#     ValidationReport,
#     ReportFormat,
#     ReportLevel
# )

# Import exceptions
import .exceptions.(
#     ValidationError,
#     ValidatorInitializationError,
#     FileAccessError,
#     ParsingError,
#     ASTVerificationError,
#     ForeignSyntaxError,
#     AutoCorrectionError,
#     ReportGenerationError,
#     ConfigurationError,
#     TimeoutError,
#     MemoryLimitError,
#     CircularReferenceError,
#     TypeMismatchError,
#     InvalidNodeStructureError,
#     InvalidOperatorError,
#     InvalidIdentifierError,
#     InvalidControlFlowError,
#     InvalidImportError,
#     InvalidFunctionDefinitionError,
#     InvalidClassDefinitionError,
#     InvalidVariableUsageError,
#     InvalidAsyncUsageError,
#     InvalidExceptionHandlingError,
#     InvalidDecoratorError,
#     UnreachableCodeError,
#     DeadCodeError,
#     ERROR_CODE_MAP,
#     create_validation_error,
#     is_validation_error_code
# )

# Version information
__version__ = "1.0.0"
__author__ = "Michael van Erp"
# __description__ = "NoodleCore validator for 100% language specification compliance"

# Export all public components
__all__ = [
#     # Main validator
#     "NoodleCoreValidator",
#     "ValidatorConfig",
#     "ValidationMode",
#     "get_validator",
#     "validate_code",
#     "validate_file",
#     "is_valid_noodlecore",

#     # Foreign syntax detection
#     "ForeignSyntaxDetector",
#     "ValidationIssue",
#     "ValidationSeverity",
#     "ForeignSyntaxType",
#     "ForeignSyntaxPattern",

#     # AST verification
#     "ASTVerifier",
#     "ASTValidationContext",
#     "ASTValidationErrorCode",

#     # Auto-correction
#     "AutoCorrector",
#     "AutoCorrectionResult",
#     "Correction",
#     "CorrectionResult",

#     # Result reporting
#     "ValidationResultReporter",
#     "ValidationReport",
#     "ReportFormat",
#     "ReportLevel",

#     # Exceptions
#     "ValidationError",
#     "ValidatorInitializationError",
#     "FileAccessError",
#     "ParsingError",
#     "ASTVerificationError",
#     "ForeignSyntaxError",
#     "AutoCorrectionError",
#     "ReportGenerationError",
#     "ConfigurationError",
#     "TimeoutError",
#     "MemoryLimitError",
#     "CircularReferenceError",
#     "TypeMismatchError",
#     "InvalidNodeStructureError",
#     "InvalidOperatorError",
#     "InvalidIdentifierError",
#     "InvalidControlFlowError",
#     "InvalidImportError",
#     "InvalidFunctionDefinitionError",
#     "InvalidClassDefinitionError",
#     "InvalidVariableUsageError",
#     "InvalidAsyncUsageError",
#     "InvalidExceptionHandlingError",
#     "InvalidDecoratorError",
#     "UnreachableCodeError",
#     "DeadCodeError",
#     "ERROR_CODE_MAP",
#     "create_validation_error",
#     "is_validation_error_code",

#     # Metadata
#     "__version__",
#     "__author__",
#     "__description__"
# ]