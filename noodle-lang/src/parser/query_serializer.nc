# Converted from Python to NoodleCore
# Original file: src

# Query Result Serializer
# """
# Provides serialization of query results in various formats.
# Supports JSON, Pickle, and XML serialization with proper error handling.
# """

import json
import logging
import pickle
import xml.etree.ElementTree as ET
import datetime.datetime
import typing.Any

import noodlecore.runtime.nbc_runtime.math.objects.MathematicalObject

# Configure logging
logger = logging.getLogger(__name__)


class QueryResultSerializer
    #     """
    #     Serializes query results to various formats with proper error handling.

    #     Supports:
    #     - JSON: Human-readable, widely compatible
    #     - Pickle: Python-specific, preserves all object details
    #     - XML: Structured, platform-independent
    #     """

    #     def __init__(self):
    #         """Initialize serializer with default settings."""
    self._logger = logging.getLogger(__name__)
    self._indent = 2  # For JSON and XML pretty printing

    #         # Serialization formats
    self._supported_formats = ["json", "pickle", "xml"]

    #     def serialize(self, data: Any, format: str = "json", **kwargs) -str):
    #         """
    #         Serialize data to specified format.

    #         Args:
    #             data: Data to serialize
                format: Serialization format ('json', 'pickle', 'xml')
    #             **kwargs: Format-specific options

    #         Returns:
    #             Serialized data as string

    #         Raises:
    #             ValueError: If format is not supported
    #             SerializationError: If serialization fails
    #         """
    format = format.lower()

    #         if format not in self._supported_formats:
                raise ValueError(f"Unsupported format: {format}")

    #         try:
    #             if format == "json":
                    return self._serialize_json(data, **kwargs)
    #             elif format == "pickle":
                    return self._serialize_pickle(data, **kwargs)
    #             elif format == "xml":
                    return self._serialize_xml(data, **kwargs)
    #         except Exception as e:
                self._logger.error(f"Serialization failed: {e}")
                raise SerializationError(f"Failed to serialize as {format}: {e}")

    #     def deserialize(self, data: str, format: str = "json", **kwargs) -Any):
    #         """
    #         Deserialize data from specified format.

    #         Args:
    #             data: Serialized data string
                format: Serialization format ('json', 'pickle', 'xml')
    #             **kwargs: Format-specific options

    #         Returns:
    #             Deserialized data

    #         Raises:
    #             ValueError: If format is not supported
    #             DeserializationError: If deserialization fails
    #         """
    format = format.lower()

    #         if format not in self._supported_formats:
                raise ValueError(f"Unsupported format: {format}")

    #         try:
    #             if format == "json":
                    return self._deserialize_json(data, **kwargs)
    #             elif format == "pickle":
                    return self._deserialize_pickle(data, **kwargs)
    #             elif format == "xml":
                    return self._deserialize_xml(data, **kwargs)
    #         except Exception as e:
                self._logger.error(f"Deserialization failed: {e}")
                raise DeserializationError(f"Failed to deserialize from {format}: {e}")

    #     def _serialize_json(
    #         self,
    #         data: Any,
    indent: Optional[int] = None,
    ensure_ascii: bool = False,
    #         **kwargs,
    #     ) -str):
    #         """Serialize data to JSON format."""
    #         if indent is None:
    indent = self._indent

    #         # Handle mathematical objects specially
    #         if isinstance(data, MathematicalObject):
                return json.dumps(
                    self._convert_mathematical_object_to_dict(data),
    indent = indent,
    ensure_ascii = ensure_ascii,
    default = self._json_serializer_default,
    #             )

    #         # Handle lists of mathematical objects
    #         if isinstance(data, list) and data and isinstance(data[0], MathematicalObject):
    converted_data = [
    #                 self._convert_mathematical_object_to_dict(obj) for obj in data
    #             ]
                return json.dumps(
    #                 converted_data,
    indent = indent,
    ensure_ascii = ensure_ascii,
    default = self._json_serializer_default,
    #             )

    #         # Handle dictionaries with mathematical objects
    #         if isinstance(data, dict):
    converted_data = {}
    #             for key, value in data.items():
    #                 if isinstance(value, MathematicalObject):
    converted_data[key] = self._convert_mathematical_object_to_dict(
    #                         value
    #                     )
    #                 else:
    converted_data[key] = value
                return json.dumps(
    #                 converted_data,
    indent = indent,
    ensure_ascii = ensure_ascii,
    default = self._json_serializer_default,
    #             )

    #         # Default case
            return json.dumps(
    #             data,
    indent = indent,
    ensure_ascii = ensure_ascii,
    default = self._json_serializer_default,
    #         )

    #     def _deserialize_json(
    self, data: str, object_hook: Optional[callable] = None * , *kwargs
    #     ) -Any):
    #         """Deserialize data from JSON format."""
    parsed_data = json.loads(data, object_hook=object_hook)

    #         # Convert dictionaries back to mathematical objects if needed
    #         if isinstance(parsed_data, dict) and "object_type" in parsed_data:
                return self._convert_dict_to_mathematical_object(parsed_data)

    #         # Handle lists of mathematical objects
    #         if isinstance(parsed_data, list):
    #             return [
                    (
                        self._convert_dict_to_mathematical_object(obj)
    #                     if isinstance(obj, dict) and "object_type" in obj
    #                     else obj
    #                 )
    #                 for obj in parsed_data
    #             ]

    #         return parsed_data

    #     def _serialize_pickle(
    self, data: Any, protocol: Optional[int] = None * , *kwargs
    #     ) -str):
    #         """Serialize data to pickle format."""
    #         if protocol is None:
    protocol = pickle.HIGHEST_PROTOCOL

    return pickle.dumps(data, protocol = protocol)

    #     def _deserialize_pickle(self, data: str, encoding: str = "bytes", **kwargs) -Any):
    #         """Deserialize data from pickle format."""
    return pickle.loads(data, encoding = encoding)

    #     def _serialize_xml(
    self, data: Any, root_tag: str = "data", pretty_print: bool = True, **kwargs
    #     ) -str):
    #         """Serialize data to XML format."""
    root = ET.Element(root_tag)

    #         # Add timestamp
    timestamp = ET.SubElement(root, "timestamp")
    timestamp.text = datetime.now().isoformat()

    #         # Add data
            self._convert_to_xml_element(data, root)

    #         # Convert to string
    xml_str = ET.tostring(root, encoding="unicode")

    #         if pretty_print:
    #             # Pretty print XML
    #             try:
    #                 from xml.dom import minidom

    dom = minidom.parseString(xml_str)
    xml_str = dom.toprettyxml(indent="  ")
    #             except ImportError:
    #                 # Fallback to simple string
    #                 pass

    #         return xml_str

    #     def _deserialize_xml(self, data: str, **kwargs) -Any):
    #         """Deserialize data from XML format."""
    #         try:
    root = ET.fromstring(data)

    #             # Remove timestamp if present
    timestamp_elem = root.find("timestamp")
    #             if timestamp_elem is not None:
                    root.remove(timestamp_elem)

    #             # Convert XML elements back to Python objects
                return self._convert_from_xml_element(root)
    #         except ET.ParseError as e:
                raise DeserializationError(f"Invalid XML: {e}")

    #     def _convert_mathematical_object_to_dict(
    #         self, obj: MathematicalObject
    #     ) -Dict[str, Any]):
    #         """Convert a mathematical object to a dictionary for JSON serialization."""
    #         if not hasattr(obj, "to_dict"):
    #             # Fallback for objects without to_dict method
    #             return {
    #                 "object_type": obj.object_type.value,
                    "data": str(obj),
                    "id": getattr(obj, "id", None),
    #             }

            return obj.to_dict()

    #     def _convert_dict_to_mathematical_object(
    #         self, data: Dict[str, Any]
    #     ) -MathematicalObject):
    #         """Convert a dictionary back to a mathematical object."""
    #         if "object_type" not in data:
                raise ValueError("Dictionary missing 'object_type' key")

    #         try:
                from noodlecore.runtime.nbc_runtime.math.objects import (
    #                 create_mathematical_object,
    #             )

    object_type = ObjectType(data["object_type"])
    obj_data = data.get("data", {})

                return create_mathematical_object(object_type, obj_data)
    #         except Exception as e:
                self._logger.error(f"Failed to create mathematical object: {e}")
    #             raise

    #     def _convert_to_xml_element(self, data: Any, parent: ET.Element) -None):
    #         """Convert Python data to XML elements."""
    #         if isinstance(data, dict):
    #             for key, value in data.items():
    elem = ET.SubElement(parent, str(key))
                    self._convert_to_xml_element(value, elem)
    #         elif isinstance(data, list):
    #             for i, item in enumerate(data):
    elem = ET.SubElement(parent, f"item_{i}")
                    self._convert_to_xml_element(item, elem)
    #         elif isinstance(data, (int, float, str, bool)):
    parent.text = str(data)
    #         elif data is None:
    parent.text = "null"
    #         else:
    #             # For custom objects, convert to string representation
    parent.text = str(data)

    #     def _convert_from_xml_element(self, elem: ET.Element) -Any):
    #         """Convert XML elements back to Python objects."""
    #         # If element has children, it's a container
    #         if len(elem):
    #             # Check if it's a dictionary (all keys are strings)
    #             keys = [child.tag for child in elem]
    #             if all(key.replace("_", "").replace("-", "").isalnum() for key in keys):
    #                 # Dictionary
    result = {}
    #                 for child in elem:
    result[child.tag] = self._convert_from_xml_element(child)
    #                 return result
    #             else:
    #                 # List
    result = []
    #                 for child in elem:
                        result.append(self._convert_from_xml_element(child))
    #                 return result
    #         else:
    #             # Leaf node
    text = elem.text or ""

    #             # Try to convert to appropriate type
    #             if text == "null":
    #                 return None
    #             elif text.lower() == "true":
    #                 return True
    #             elif text.lower() == "false":
    #                 return False
    #             elif text.isdigit():
                    return int(text)
    #             elif "." in text and all(c.isdigit() or c == "." for c in text):
                    return float(text)
    #             else:
    #                 return text

    #     def _json_serializer_default(self, obj: Any) -Any):
    #         """Default JSON serializer for non-standard types."""
    #         if isinstance(obj, (datetime, set)):
                return str(obj)
    #         elif hasattr(obj, "__dict__"):
    #             return obj.__dict__
    #         else:
                return str(obj)

    #     def get_supported_formats(self) -List[str]):
    #         """Get list of supported serialization formats."""
            return self._supported_formats.copy()

    #     def register_custom_serializer(
    #         self, format: str, serialize_func: callable, deserialize_func: callable
    #     ) -None):
    #         """
    #         Register a custom serialization format.

    #         Args:
    #             format: Name of the format
    #             serialize_func: Function to serialize data
    #             deserialize_func: Function to deserialize data
    #         """
    #         if not callable(serialize_func) or not callable(deserialize_func):
                raise ValueError("Serializer and deserializer must be callable")

            self._supported_formats.append(format)

    #         # Create methods dynamically
            setattr(self, f"_serialize_{format}", serialize_func)
            setattr(self, f"_deserialize_{format}", deserialize_func)

            self._logger.info(f"Registered custom serialization format: {format}")
