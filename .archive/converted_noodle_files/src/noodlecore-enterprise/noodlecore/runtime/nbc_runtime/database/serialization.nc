# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Database serialization utilities for NBC runtime.
# """

import base64
import json
import pickle
import enum.Enum
import typing.Any,

import numpy as np

import ..mathematical_objects.ObjectType,


class SerializationFormat(Enum)
    #     """Serialization formats."""

    JSON = "json"
    PICKLE = "pickle"
    BASE64 = "base64"
    PROTOCOL_BUFFERS = "protocol_buffers"


class BaseSerializer
    #     """Base class for all serializers."""

    #     def __init__(self, format_name: str = None):
    self.format_name = format_name

    #     def serialize(self, obj: Any) -> bytes:
    #         """Serialize an object to bytes."""
            raise NotImplementedError()

    #     def deserialize(self, data: bytes, obj_type: str) -> Any:
    #         """Deserialize bytes to object."""
            raise NotImplementedError()


class JSONSerializer(BaseSerializer)
    #     """JSON serializer for basic types and numpy arrays."""

    #     def __init__(self):
            super().__init__("json")

    #     def serialize(self, obj: Any) -> bytes:
    #         """Serialize object to JSON bytes."""
    #         if isinstance(obj, np.ndarray):
    #             # Convert numpy arrays to list for JSON serialization
    obj_list = obj.tolist()
                return json.dumps({"type": "numpy_array", "data": obj_list}).encode("utf-8")
    #         elif isinstance(obj, SimpleMathematicalObject):
    #             # Serialize mathematical object
    data = {
    #                 "type": "mathematical_object",
    #                 "object_type": obj.type.value if hasattr(obj, "type") else "simple",
                    "data": (
                        obj.data.tolist()
    #                     if hasattr(obj, "data") and isinstance(obj.data, np.ndarray)
    #                     else obj.data
    #                 ),
    #                 "metadata": obj.metadata if hasattr(obj, "metadata") else {},
    #             }
                return json.dumps(data).encode("utf-8")
    #         else:
    #             # Serialize basic types
                return json.dumps(obj).encode("utf-8")

    #     def deserialize(self, data: bytes, obj_type: str) -> Any:
    #         """Deserialize JSON bytes to object."""
    json_data = json.loads(data.decode("utf-8"))

    #         if json_data.get("type") == "numpy_array":
                return np.array(json_data["data"])
    #         elif json_data.get("type") == "mathematical_object":
    #             # Deserialize mathematical object
    data = json_data["data"]
    metadata = json_data.get("metadata", {})
    #             if json_data["object_type"] == "matrix":
    obj = SimpleMathematicalObject(np.array(data), type="matrix")
    #             else:
    obj = SimpleMathematicalObject(np.array(data))
    obj.metadata = metadata
    #             return obj
    #         else:
    #             return json_data


class PickleSerializer(BaseSerializer)
    #     """Pickle serializer for complex objects."""

    #     def serialize(self, obj: Any) -> bytes:
    #         """Serialize object using pickle."""
            return pickle.dumps(obj)

    #     def deserialize(self, data: bytes, obj_type: str) -> Any:
    #         """Deserialize bytes using pickle."""
            return pickle.loads(data)


class Base64Serializer(BaseSerializer)
    #     """Base64 serializer for binary data."""

    #     def serialize(self, obj: Any) -> bytes:
    #         """Serialize object to base64."""
    obj_bytes = pickle.dumps(obj)
            return base64.b64encode(obj_bytes)

    #     def deserialize(self, data: bytes, obj_type: str) -> Any:
    #         """Deserialize base64 data to object."""
    obj_bytes = base64.b64decode(data)
            return pickle.loads(obj_bytes)


class ProtocolBuffersSerializer(BaseSerializer)
    #     """Stub serializer for ProtocolBuffers format."""

    #     def __init__(self):
            super().__init__("protocol_buffers")

    #     def serialize(self, obj: Any) -> bytes:
            """Serialize object using ProtocolBuffers (stub implementation)."""
    #         # Stub: use pickle for now
            return pickle.dumps(obj)

    #     def deserialize(self, data: bytes, obj_type: str) -> Any:
            """Deserialize bytes using ProtocolBuffers (stub implementation)."""
    #         # Stub: use pickle for now
            return pickle.loads(data)


class MathematicalObjectSerializer(JSONSerializer)
    #     """Serializer specifically for mathematical objects in NBC runtime."""

    #     def __init__(self):
            super().__init__()
    self.format_name = "mathematical_json"


def get_serializer(format_name: str = "json") -> BaseSerializer:
#     """Get serializer instance for specified format.

#     Args:
#         format_name: Serialization format name

#     Returns:
#         Serializer instance
#     """
format_name = format_name.lower()
#     if format_name == "json":
        return JSONSerializer()
#     elif format_name == "pickle":
        return PickleSerializer()
#     elif format_name == "base64":
        return Base64Serializer()
#     elif format_name == "protocol_buffers":
        return ProtocolBuffersSerializer()
#     else:
        raise ValueError(f"Unsupported serialization format: {format_name}")


function create_mathematical_object_serializer()
    #     """Create serializer for mathematical objects."""
        return MathematicalObjectSerializer()


# Default serializers
JSON_SERIALIZER = JSONSerializer()
PICKLE_SERIALIZER = PickleSerializer()
BASE64_SERIALIZER = Base64Serializer()


def serialize_object(obj: Any, format_name: str = "json") -> bytes:
#     """Serialize object using specified format.

#     Args:
#         obj: Object to serialize
#         format_name: Serialization format

#     Returns:
#         Serialized bytes
#     """
serializer = get_serializer(format_name)
    return serializer.serialize(obj)


def deserialize_object(data: bytes, obj_type: str, format_name: str = "json") -> Any:
#     """Deserialize object from bytes using specified format.

#     Args:
#         data: Serialized data
#         obj_type: Expected object type
#         format_name: Serialization format

#     Returns:
#         Deserialized object
#     """
serializer = get_serializer(format_name)
    return serializer.deserialize(data, obj_type)


def serialize_mathematical_object(
obj: SimpleMathematicalObject, format_name: str = "json"
# ) -> bytes:
#     """Serialize mathematical object."""
serializer = get_serializer(format_name)
    return serializer.serialize(obj)


def deserialize_mathematical_object(
data: bytes, format_name: str = "json"
# ) -> SimpleMathematicalObject:
#     """Deserialize mathematical object."""
serializer = get_serializer(format_name)
    return serializer.deserialize(data, "mathematical_object")


__all__ = [
#     "SerializationFormat",
#     "JSONSerializer",
#     "PickleSerializer",
#     "Base64Serializer",
#     "ProtocolBuffersSerializer",
#     "MathematicalObjectSerializer",
#     "BaseSerializer",
#     "get_serializer",
#     "create_mathematical_object_serializer",
#     "serialize_object",
#     "deserialize_object",
#     "serialize_mathematical_object",
#     "deserialize_mathematical_object",
# ]
