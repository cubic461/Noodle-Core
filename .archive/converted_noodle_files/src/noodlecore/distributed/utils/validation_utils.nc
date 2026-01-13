# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Validation utilities for NoodleCore Distributed System.

# This module provides data validation and type checking utilities
# for the distributed AI task management system.
# """

import re
import uuid
import typing.Any,
import datetime.datetime


class ValidationError(Exception)
    #     """Custom validation error exception."""
    #     pass


class Validator
    #     """
    #     Validation utilities for system data validation.

    #     This class provides validation methods for various data types
    #     used throughout the NoodleCore distributed system.
    #     """

    #     # Role name pattern: alphanumeric, underscore, hyphen, max 50 chars
    ROLE_NAME_PATTERN = re.compile(r'^[a-zA-Z0-9_-]{1,50}$')

    #     # Task ID pattern: UUID format
    TASK_ID_PATTERN = re.compile(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')

    #     # File path pattern: safe file system paths
    FILE_PATH_PATTERN = re.compile(r'^[a-zA-Z0-9._/-]{1,255}$')

    #     @staticmethod
    #     def role_name(role_name: str) -> str:
    #         """
    #         Validate and return role name.

    #         Args:
    #             role_name: Role name to validate

    #         Returns:
    #             str: Validated role name

    #         Raises:
    #             ValidationError: If role name is invalid
    #         """
    #         if not role_name or not isinstance(role_name, str):
                raise ValidationError("Role name must be a non-empty string")

    role_name = role_name.strip()

    #         if len(role_name) > 50:
                raise ValidationError("Role name must be 50 characters or less")

    #         if not Validator.ROLE_NAME_PATTERN.match(role_name):
                raise ValidationError("Role name must contain only alphanumeric characters, underscores, and hyphens")

    #         return role_name

    #     @staticmethod
    #     def task_id(task_id: str) -> str:
    #         """
    #         Validate and return task ID.

    #         Args:
    #             task_id: Task ID to validate

    #         Returns:
    #             str: Validated task ID

    #         Raises:
    #             ValidationError: If task ID is invalid
    #         """
    #         if not task_id or not isinstance(task_id, str):
                raise ValidationError("Task ID must be a non-empty string")

    task_id = task_id.strip()

    #         if not Validator.TASK_ID_PATTERN.match(task_id):
    #             # If it's not a UUID, check if it's a valid string identifier
    #             if not re.match(r'^[a-zA-Z0-9_-]{1,100}$', task_id):
                    raise ValidationError("Task ID must be a valid UUID or alphanumeric identifier")

    #         return task_id

    #     @staticmethod
    #     def priority(priority: int) -> int:
    #         """
    #         Validate task priority.

    #         Args:
                priority: Priority level (1-5)

    #         Returns:
    #             int: Validated priority

    #         Raises:
    #             ValidationError: If priority is invalid
    #         """
    #         if not isinstance(priority, int):
                raise ValidationError("Priority must be an integer")

    #         if priority < 1 or priority > 5:
                raise ValidationError("Priority must be between 1 and 5")

    #         return priority

    #     @staticmethod
    #     def duration(duration: int) -> int:
    #         """
    #         Validate task duration.

    #         Args:
    #             duration: Duration in minutes

    #         Returns:
    #             int: Validated duration

    #         Raises:
    #             ValidationError: If duration is invalid
    #         """
    #         if not isinstance(duration, int):
                raise ValidationError("Duration must be an integer")

    #         if duration < 1:
                raise ValidationError("Duration must be at least 1 minute")

    #         if duration > 24 * 60:  # 24 hours max
                raise ValidationError("Duration cannot exceed 24 hours")

    #         return duration

    #     @staticmethod
    #     def capabilities(capabilities: List[str]) -> List[str]:
    #         """
    #         Validate capabilities list.

    #         Args:
    #             capabilities: List of capabilities

    #         Returns:
    #             List[str]: Validated capabilities

    #         Raises:
    #             ValidationError: If capabilities are invalid
    #         """
    #         if not isinstance(capabilities, list):
                raise ValidationError("Capabilities must be a list")

    #         if len(capabilities) > 20:
                raise ValidationError("Cannot have more than 20 capabilities")

    validated_capabilities = []
    #         for capability in capabilities:
    #             if not capability or not isinstance(capability, str):
                    raise ValidationError("Each capability must be a non-empty string")

    capability = capability.strip().lower()
    #             if len(capability) > 30:
                    raise ValidationError("Each capability must be 30 characters or less")

    #             if not re.match(r'^[a-z0-9_-]+$', capability):
                    raise ValidationError("Capabilities must contain only lowercase alphanumeric characters, underscores, and hyphens")

                validated_capabilities.append(capability)

    #         # Remove duplicates while preserving order
    seen = set()
    unique_capabilities = []
    #         for cap in validated_capabilities:
    #             if cap not in seen:
                    seen.add(cap)
                    unique_capabilities.append(cap)

    #         return unique_capabilities

    #     @staticmethod
    #     def metadata(metadata: Dict[str, Any]) -> Dict[str, Any]:
    #         """
    #         Validate metadata dictionary.

    #         Args:
    #             metadata: Metadata dictionary

    #         Returns:
    #             Dict[str, Any]: Validated metadata

    #         Raises:
    #             ValidationError: If metadata is invalid
    #         """
    #         if not isinstance(metadata, dict):
                raise ValidationError("Metadata must be a dictionary")

    #         if len(metadata) > 50:
                raise ValidationError("Cannot have more than 50 metadata entries")

    validated_metadata = {}
    #         for key, value in metadata.items():
    #             if not key or not isinstance(key, str):
                    raise ValidationError("Metadata keys must be non-empty strings")

    key = key.strip()
    #             if len(key) > 50:
                    raise ValidationError("Metadata keys must be 50 characters or less")

    #             # Validate key pattern
    #             if not re.match(r'^[a-zA-Z0-9_-]+$', key):
                    raise ValidationError("Metadata keys must contain only alphanumeric characters, underscores, and hyphens")

                # Validate value (basic types only)
    #             if isinstance(value, (str, int, float, bool)):
    validated_metadata[key] = value
    #             elif value is None:
    validated_metadata[key] = value
    #             else:
    #                 # Convert complex types to strings for storage
    validated_metadata[key] = str(value)

    #         return validated_metadata

    #     @staticmethod
    #     def description(description: str) -> str:
    #         """
    #         Validate description text.

    #         Args:
    #             description: Description to validate

    #         Returns:
    #             str: Validated description

    #         Raises:
    #             ValidationError: If description is invalid
    #         """
    #         if not description or not isinstance(description, str):
                raise ValidationError("Description must be a non-empty string")

    description = description.strip()

    #         if len(description) > 1000:
                raise ValidationError("Description must be 1000 characters or less")

    #         return description

    #     @staticmethod
    #     def file_path(file_path: str) -> str:
    #         """
    #         Validate file path.

    #         Args:
    #             file_path: File path to validate

    #         Returns:
    #             str: Validated file path

    #         Raises:
    #             ValidationError: If file path is invalid
    #         """
    #         if not file_path or not isinstance(file_path, str):
                raise ValidationError("File path must be a non-empty string")

    file_path = file_path.strip()

    #         if len(file_path) > 255:
                raise ValidationError("File path must be 255 characters or less")

    #         if not Validator.FILE_PATH_PATTERN.match(file_path):
                raise ValidationError("File path contains invalid characters")

    #         # Check for path traversal attempts
    #         if '..' in file_path:
                raise ValidationError("File path cannot contain parent directory references")

    #         return file_path

    #     @staticmethod
    #     def workspace_path(workspace_path: str) -> str:
    #         """
    #         Validate workspace path.

    #         Args:
    #             workspace_path: Workspace path to validate

    #         Returns:
    #             str: Validated workspace path

    #         Raises:
    #             ValidationError: If workspace path is invalid
    #         """
    #         if not workspace_path or not isinstance(workspace_path, str):
                raise ValidationError("Workspace path must be a non-empty string")

    workspace_path = workspace_path.strip()

    #         if len(workspace_path) > 500:
                raise ValidationError("Workspace path must be 500 characters or less")

    #         # Basic validation for path components
    components = workspace_path.replace('\\', '/').split('/')
    #         for component in components:
    #             if component and not re.match(r'^[a-zA-Z0-9._-]+$', component):
                    raise ValidationError("Workspace path contains invalid characters")

    #         return workspace_path

    #     @staticmethod
    #     def timestamp(timestamp: Any) -> datetime:
    #         """
    #         Validate timestamp.

    #         Args:
    #             timestamp: Timestamp to validate

    #         Returns:
    #             datetime: Validated timestamp

    #         Raises:
    #             ValidationError: If timestamp is invalid
    #         """
    #         if isinstance(timestamp, datetime):
    #             return timestamp
    #         elif isinstance(timestamp, str):
    #             try:
                    return datetime.fromisoformat(timestamp)
    #             except ValueError:
                    raise ValidationError("Timestamp must be in ISO format")
    #         else:
                raise ValidationError("Timestamp must be a datetime object or ISO format string")

    #     @staticmethod
    #     def role_config(config: Dict[str, Any]) -> Dict[str, Any]:
    #         """
    #         Validate role configuration.

    #         Args:
    #             config: Role configuration to validate

    #         Returns:
    #             Dict[str, Any]: Validated configuration

    #         Raises:
    #             ValidationError: If configuration is invalid
    #         """
    #         if not isinstance(config, dict):
                raise ValidationError("Role configuration must be a dictionary")

    validated_config = {}

    #         # Validate required fields
    #         if "description" not in config:
                raise ValidationError("Role configuration must include 'description'")

    #         # Validate description
    validated_config["description"] = Validator.description(config["description"])

    #         # Validate optional fields
    #         if "capabilities" in config:
    validated_config["capabilities"] = Validator.capabilities(config["capabilities"])
    #         else:
    validated_config["capabilities"] = []

    #         if "tools" in config:
    #             if not isinstance(config["tools"], list):
                    raise ValidationError("Tools must be a list")
    #             validated_config["tools"] = [str(tool) for tool in config["tools"][:20]]  # Max 20 tools
    #         else:
    validated_config["tools"] = []

    #         if "priority" in config:
    validated_config["priority"] = Validator.priority(config["priority"])
    #         else:
    validated_config["priority"] = 3  # Default medium priority

    #         if "metadata" in config:
    validated_config["metadata"] = Validator.metadata(config["metadata"])
    #         else:
    validated_config["metadata"] = {}

    #         return validated_config

    #     @staticmethod
    #     def task_info(task_info: Dict[str, Any]) -> Dict[str, Any]:
    #         """
    #         Validate task information.

    #         Args:
    #             task_info: Task information to validate

    #         Returns:
    #             Dict[str, Any]: Validated task information

    #         Raises:
    #             ValidationError: If task information is invalid
    #         """
    #         if not isinstance(task_info, dict):
                raise ValidationError("Task information must be a dictionary")

    validated_info = {}

    #         # Validate required fields
    #         if "description" not in task_info:
                raise ValidationError("Task information must include 'description'")

    #         # Validate description
    validated_info["description"] = Validator.description(task_info["description"])

    #         # Validate optional fields
    #         if "priority" in task_info:
    validated_info["priority"] = Validator.priority(task_info["priority"])
    #         else:
    validated_info["priority"] = 3  # Default medium priority

    #         if "estimated_duration" in task_info:
    validated_info["estimated_duration"] = Validator.duration(task_info["estimated_duration"])
    #         else:
    validated_info["estimated_duration"] = 60  # Default 1 hour

    #         if "dependencies" in task_info:
    #             if not isinstance(task_info["dependencies"], list):
                    raise ValidationError("Dependencies must be a list")
    #             validated_info["dependencies"] = [Validator.task_id(dep) for dep in task_info["dependencies"][:10]]  # Max 10 dependencies
    #         else:
    validated_info["dependencies"] = []

    #         if "required_capabilities" in task_info:
    validated_info["required_capabilities"] = Validator.capabilities(task_info["required_capabilities"])
    #         else:
    validated_info["required_capabilities"] = []

    #         if "metadata" in task_info:
    validated_info["metadata"] = Validator.metadata(task_info["metadata"])
    #         else:
    validated_info["metadata"] = {}

    #         return validated_info


# Utility functions for common validation patterns
def validate_and_return(value: Any, validator_func, error_message: str = "Validation failed") -> Any:
#     """
#     Validate a value using the provided validator function.

#     Args:
#         value: Value to validate
#         validator_func: Validation function
#         error_message: Custom error message

#     Returns:
#         Any: Validated value

#     Raises:
#         ValidationError: If validation fails
#     """
#     try:
        return validator_func(value)
#     except ValidationError:
#         raise
#     except Exception as e:
        raise ValidationError(f"{error_message}: {e}")


def safe_validate(value: Any, validator_func, default_value: Any = None) -> Any:
#     """
#     Safely validate a value, returning default on failure.

#     Args:
#         value: Value to validate
#         validator_func: Validation function
#         default_value: Default value to return on validation failure

#     Returns:
#         Any: Validated value or default
#     """
#     try:
        return validator_func(value)
#     except Exception:
#         return default_value