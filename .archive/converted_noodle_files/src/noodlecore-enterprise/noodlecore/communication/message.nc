# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Message formats and types for NoodleCore communication.

# This module defines the standardized message formats used for communication
# between different components in the NoodleCore system.
# """

import uuid
import json
import time
import enum.Enum
import typing.Dict,
import dataclasses.dataclass,


class MessageType(Enum)
    #     """Types of messages that can be sent between components."""
    REQUEST = "request"
    RESPONSE = "response"
    EVENT = "event"
    ERROR = "error"
    VALIDATION = "validation"
    AST_VERIFICATION = "ast_verification"
    COMPILATION = "compilation"
    EXECUTION = "execution"


class MessagePriority(Enum)
    #     """Priority levels for messages."""
    LOW = 1
    NORMAL = 2
    HIGH = 3
    CRITICAL = 4


class ComponentType(Enum)
    #     """Types of components in the NoodleCore system."""
    AI_AGENT = "ai_agent"
    AI_GUARD = "ai_guard"
    LINTER = "linter"
    COMPILER_FRONTEND = "compiler_frontend"
    IDE_RUNTIME = "ide_runtime"
    EXECUTOR = "executor"
    SANDBOX = "sandbox"
    NOODLENET_NODE = "noodlenet_node"


# @dataclass
class Message
    #     """
    #     Standard message format for communication between components.

    #     Attributes:
    #         id: Unique identifier for the message
    #         type: Type of the message
    #         source: Source component
    #         destination: Destination component
    #         priority: Priority level of the message
    #         timestamp: Timestamp when the message was created
    #         request_id: ID to correlate request/response pairs
    #         payload: Message content
    #         metadata: Additional metadata about the message
    #     """
    #     id: str
    #     type: MessageType
    #     source: ComponentType
    #     destination: ComponentType
    #     priority: MessagePriority
    #     timestamp: float
    request_id: Optional[str] = None
    payload: Optional[Dict[str, Any]] = None
    metadata: Optional[Dict[str, Any]] = None

    #     def __init__(
    #         self,
    #         type: MessageType,
    #         source: ComponentType,
    #         destination: ComponentType,
    priority: MessagePriority = MessagePriority.NORMAL,
    request_id: Optional[str] = None,
    payload: Optional[Dict[str, Any]] = None,
    metadata: Optional[Dict[str, Any]] = None,
    #     ):
    self.id = str(uuid.uuid4())
    self.type = type
    self.source = source
    self.destination = destination
    self.priority = priority
    self.timestamp = time.time()
    self.request_id = request_id or str(uuid.uuid4())
    self.payload = payload or {}
    self.metadata = metadata or {}

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert message to dictionary."""
    #         return {
    #             "id": self.id,
    #             "type": self.type.value,
    #             "source": self.source.value,
    #             "destination": self.destination.value,
    #             "priority": self.priority.value,
    #             "timestamp": self.timestamp,
    #             "request_id": self.request_id,
    #             "payload": self.payload,
    #             "metadata": self.metadata,
    #         }

    #     def to_json(self) -> str:
    #         """Convert message to JSON string."""
            return json.dumps(self.to_dict())

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -> "Message":
    #         """Create message from dictionary."""
    message = cls(
    type = MessageType(data["type"]),
    source = ComponentType(data["source"]),
    destination = ComponentType(data["destination"]),
    priority = MessagePriority(data["priority"]),
    request_id = data.get("request_id"),
    payload = data.get("payload"),
    metadata = data.get("metadata"),
    #         )
    message.id = data["id"]
    message.timestamp = data["timestamp"]
    #         return message

    #     @classmethod
    #     def from_json(cls, json_str: str) -> "Message":
    #         """Create message from JSON string."""
    data = json.loads(json_str)
            return cls.from_dict(data)

    #     def create_response(
    #         self,
    payload: Optional[Dict[str, Any]] = None,
    error: Optional[Dict[str, Any]] = None,
    #     ) -> "Message":
    #         """Create a response message for this message."""
    response_type = MessageType.RESPONSE
    #         if error:
    response_type = MessageType.ERROR

    response = Message(
    type = response_type,
    source = self.destination,
    destination = self.source,
    priority = self.priority,
    request_id = self.request_id,
    payload = payload,
    metadata = {"in_response_to": self.id},
    #         )

    #         if error:
    response.payload = {"error": error}

    #         return response


class MessageFactory
    #     """Factory for creating standardized messages."""

    #     @staticmethod
    #     def create_validation_request(
    #         source: ComponentType,
    #         destination: ComponentType,
    #         code: str,
    metadata: Optional[Dict[str, Any]] = None,
    #     ) -> Message:
    #         """Create a validation request message."""
            return Message(
    type = MessageType.VALIDATION,
    source = source,
    destination = destination,
    priority = MessagePriority.HIGH,
    payload = {"code": code},
    metadata = metadata,
    #         )

    #     @staticmethod
    #     def create_ast_verification_request(
    #         source: ComponentType,
    #         destination: ComponentType,
    #         ast_data: Dict[str, Any],
    metadata: Optional[Dict[str, Any]] = None,
    #     ) -> Message:
    #         """Create an AST verification request message."""
            return Message(
    type = MessageType.AST_VERIFICATION,
    source = source,
    destination = destination,
    priority = MessagePriority.HIGH,
    payload = {"ast": ast_data},
    metadata = metadata,
    #         )

    #     @staticmethod
    #     def create_compilation_request(
    #         source: ComponentType,
    #         destination: ComponentType,
    #         code: str,
    options: Optional[Dict[str, Any]] = None,
    metadata: Optional[Dict[str, Any]] = None,
    #     ) -> Message:
    #         """Create a compilation request message."""
            return Message(
    type = MessageType.COMPILATION,
    source = source,
    destination = destination,
    priority = MessagePriority.NORMAL,
    payload = {"code": code, "options": options or {}},
    metadata = metadata,
    #         )

    #     @staticmethod
    #     def create_execution_request(
    #         source: ComponentType,
    #         destination: ComponentType,
    #         compiled_code: str,
    environment: Optional[Dict[str, Any]] = None,
    metadata: Optional[Dict[str, Any]] = None,
    #     ) -> Message:
    #         """Create an execution request message."""
            return Message(
    type = MessageType.EXECUTION,
    source = source,
    destination = destination,
    priority = MessagePriority.NORMAL,
    payload = {
    #                 "compiled_code": compiled_code,
    #                 "environment": environment or {},
    #             },
    metadata = metadata,
    #         )

    #     @staticmethod
    #     def create_event_notification(
    #         source: ComponentType,
    #         destination: ComponentType,
    #         event_type: str,
    #         event_data: Dict[str, Any],
    metadata: Optional[Dict[str, Any]] = None,
    #     ) -> Message:
    #         """Create an event notification message."""
            return Message(
    type = MessageType.EVENT,
    source = source,
    destination = destination,
    priority = MessagePriority.LOW,
    payload = {
    #                 "event_type": event_type,
    #                 "event_data": event_data,
    #             },
    metadata = metadata,
    #         )