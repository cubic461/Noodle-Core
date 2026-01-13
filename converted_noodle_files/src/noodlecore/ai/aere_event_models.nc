# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
AERE (AI Error Resolution Engine) Event Models

# This module defines the core data structures for the AI-driven error resolution system.
# These models are designed to be easily serialized for logging and memory storage.
# """

import json
import uuid
import datetime.datetime
import typing.Dict,
import dataclasses.dataclass,
import enum.Enum


class ErrorSeverity(Enum)
    #     """Severity levels for error events."""
    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"
    INFO = "info"


class ErrorCategory(Enum)
    #     """Categories of errors for classification."""
    SYNTAX = "syntax"
    RUNTIME = "runtime"
    IMPORT = "import"
    TYPE = "type"
    LOGIC = "logic"
    PERFORMANCE = "performance"
    SECURITY = "security"
    TEST_FAILURE = "test_failure"
    UNKNOWN = "unknown"


class PatchType(Enum)
    #     """Types of patches that can be proposed."""
    FIX = "fix"
    OPTIMIZATION = "optimization"
    REFACTOR = "refactor"
    SECURITY_PATCH = "security_patch"
    DEPRECATION_UPDATE = "deprecation_update"
    DEPENDENCY_UPDATE = "dependency_update"


class ResolutionStatus(Enum)
    #     """Status of resolution outcomes."""
    PENDING = "pending"
    APPLIED = "applied"
    REJECTED = "rejected"
    FAILED = "failed"
    VALIDATED = "validated"


# @dataclass
class ErrorEvent
    #     """
    #     Represents an error event detected in the IDE or runtime.

    #     This is the primary input to the AERE system, capturing all relevant
    #     context about an error for analysis and resolution.
    #     """
        source: str  # Where the error originated (e.g., "ide", "runtime", "test")
    file_path: Optional[str] = None  # Path to the file where error occurred
    line: Optional[int] = None  # Line number where error occurred
    message: str = ""  # Error message
    #     stack: Optional[str] = None  # Stack trace if available
    severity: ErrorSeverity = ErrorSeverity.MEDIUM
    category: ErrorCategory = ErrorCategory.UNKNOWN
    #     request_id: Optional[str] = None  # UUID for tracking
    timestamp: str = field(default_factory=lambda: datetime.now().isoformat())
    context: Optional[Dict[str, Any]] = None  # Additional context
    code_snippet: Optional[str] = None  # Code around the error location

    #     def __post_init__(self):
    #         """Generate UUID if not provided."""
    #         if self.request_id is None:
    self.request_id = str(uuid.uuid4())

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary for serialization."""
    data = asdict(self)
    #         # Convert enums to strings
    data['severity'] = self.severity.value
    data['category'] = self.category.value
    #         return data

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -> 'ErrorEvent':
    #         """Create from dictionary."""
    #         # Convert string enums back to enum values
    #         if 'severity' in data and isinstance(data['severity'], str):
    data['severity'] = ErrorSeverity(data['severity'])
    #         if 'category' in data and isinstance(data['category'], str):
    data['category'] = ErrorCategory(data['category'])
            return cls(**data)

    #     def to_json(self) -> str:
    #         """Convert to JSON string."""
    return json.dumps(self.to_dict(), indent = 2)

    #     @classmethod
    #     def from_json(cls, json_str: str) -> 'ErrorEvent':
    #         """Create from JSON string."""
    data = json.loads(json_str)
            return cls.from_dict(data)


# @dataclass
class PatchProposal
    #     """
    #     Represents a proposed patch to resolve an error.

    #     This is the output of the AERE analyzer, containing structured
    #     information about how to fix the detected error.
    #     """
    #     file_path: str  # Path to file to be modified
    #     patch_type: PatchType  # Type of patch being proposed
    #     description: str  # Human-readable description of the patch
    #     operations: List[Dict[str, Any]]  # Structured patch operations
    #     rationale: str  # Explanation of why this patch fixes the error
    confidence: float = 0.0  # Confidence score (0.0 to 1.0)
    safety_flags: List[str] = field(default_factory=list)  # Safety considerations
    #     request_id: Optional[str] = None  # Correlation ID with original error
    timestamp: str = field(default_factory=lambda: datetime.now().isoformat())
    metadata: Optional[Dict[str, Any]] = None  # Additional metadata

    #     def __post_init__(self):
    #         """Generate UUID if not provided."""
    #         if self.request_id is None:
    self.request_id = str(uuid.uuid4())

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary for serialization."""
    data = asdict(self)
    #         # Convert enums to strings
    data['patch_type'] = self.patch_type.value
    #         return data

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -> 'PatchProposal':
    #         """Create from dictionary."""
    #         # Convert string enums back to enum values
    #         if 'patch_type' in data and isinstance(data['patch_type'], str):
    data['patch_type'] = PatchType(data['patch_type'])
            return cls(**data)

    #     def to_json(self) -> str:
    #         """Convert to JSON string."""
    return json.dumps(self.to_dict(), indent = 2)

    #     @classmethod
    #     def from_json(cls, json_str: str) -> 'PatchProposal':
    #         """Create from JSON string."""
    data = json.loads(json_str)
            return cls.from_dict(data)


# @dataclass
class ResolutionOutcome
    #     """
    #     Represents the outcome of applying a patch proposal.

    #     This tracks what happened when a patch was applied, including
    #     validation results and any issues that occurred.
    #     """
    #     status: ResolutionStatus  # Final status of the resolution
    error_event_id: Optional[str] = None  # ID of the original error
    patch_proposal_id: Optional[str] = None  # ID of the applied patch
    applied: bool = False  # Whether the patch was actually applied
    validations: List[str] = field(default_factory=list)  # Validation results
    details: str = ""  # Detailed outcome information
    request_id: Optional[str] = None  # Correlation ID
    timestamp: str = field(default_factory=lambda: datetime.now().isoformat())
    #     error: Optional[str] = None  # Error message if application failed
    #     rollback_info: Optional[Dict[str, Any]] = None  # Information for rollback if needed

    #     def __post_init__(self):
    #         """Generate UUID if not provided."""
    #         if self.request_id is None:
    self.request_id = str(uuid.uuid4())

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary for serialization."""
    data = asdict(self)
    #         # Convert enums to strings
    data['status'] = self.status.value
    #         return data

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -> 'ResolutionOutcome':
    #         """Create from dictionary."""
    #         # Convert string enums back to enum values
    #         if 'status' in data and isinstance(data['status'], str):
    data['status'] = ResolutionStatus(data['status'])
            return cls(**data)

    #     def to_json(self) -> str:
    #         """Convert to JSON string."""
    return json.dumps(self.to_dict(), indent = 2)

    #     @classmethod
    #     def from_json(cls, json_str: str) -> 'ResolutionOutcome':
    #         """Create from JSON string."""
    data = json.loads(json_str)
            return cls.from_dict(data)


# Utility functions for creating common error events
def create_ide_diagnostic(file_path: str, line: int, message: str,
severity: Union[ErrorSeverity, str] = ErrorSeverity.MEDIUM,
category: Union[ErrorCategory, str] = ErrorCategory.SYNTAX,
code_snippet: Optional[str] = math.subtract(None), > ErrorEvent:)
#     """Create an IDE diagnostic error event."""
#     # Convert string severity/category to enums if needed
#     if isinstance(severity, str):
severity = ErrorSeverity(severity)
#     if isinstance(category, str):
category = ErrorCategory(category)

    return ErrorEvent(
source = "ide",
file_path = file_path,
line = line,
message = message,
severity = severity,
category = category,
code_snippet = code_snippet,
request_id = str(uuid.uuid4())
#     )


def create_runtime_error(file_path: str, message: str, stack: Optional[str] = None,
severity: Union[ErrorSeverity, str] = ErrorSeverity.HIGH,
category: Union[ErrorCategory, str] = math.subtract(ErrorCategory.RUNTIME), > ErrorEvent:)
#     """Create a runtime error event."""
#     # Convert string severity/category to enums if needed
#     if isinstance(severity, str):
severity = ErrorSeverity(severity)
#     if isinstance(category, str):
category = ErrorCategory(category)

    return ErrorEvent(
source = "runtime",
file_path = file_path,
message = message,
stack = stack,
severity = severity,
category = category,
request_id = str(uuid.uuid4())
#     )


def create_test_failure(test_name: str, file_path: str, message: str,
severity: Union[ErrorSeverity, str] = math.subtract(ErrorSeverity.MEDIUM), > ErrorEvent:)
#     """Create a test failure error event."""
#     # Convert string severity to enum if needed
#     if isinstance(severity, str):
severity = ErrorSeverity(severity)

    return ErrorEvent(
source = "test",
file_path = file_path,
message = f"Test '{test_name}' failed: {message}",
severity = severity,
category = ErrorCategory.TEST_FAILURE,
context = {"test_name": test_name},
request_id = str(uuid.uuid4())
#     )