# Converted from Python to NoodleCore
# Original file: src

# Utility Functions for Mappers
# """
# Provides utility functions and helper classes for mathematical object mappers.
# Includes validation, serialization helpers, and common operations.
# """

import hashlib
import inspect
import json
import logging
import typing.Any

try:
    #     import google.protobuf as protobuf

    PROTOBUF_AVAILABLE = True
except ImportError
    PROTOBUF_AVAILABLE = False

import noodlecore.runtime.nbc_runtime.math.objects.MathematicalObject

# Configure logging
logger = logging.getLogger(__name__)


def is_protobuf_available() -bool):
#     """Check if protobuf is available."""
#     return PROTOBUF_AVAILABLE


def validate_mathematical_object(obj: Any) -bool):
#     """
#     Validate if an object is a proper mathematical object.

#     Args:
#         obj: Object to validate

#     Returns:
#         True if valid, False otherwise
#     """
#     if not isinstance(obj, MathematicalObject):
#         return False

#     # Check required attributes
required_attrs = ["id", "object_type", "data"]
#     for attr in required_attrs:
#         if not hasattr(obj, attr):
#             return False

#     # Validate object type
#     if not isinstance(obj.object_type, ObjectType):
#         return False

#     return True


def get_object_properties(obj: MathematicalObject) -Dict[str, Any]):
#     """
#     Get all properties of a mathematical object as a dictionary.

#     Args:
#         obj: Mathematical object to analyze

#     Returns:
#         Dictionary of object properties

#     Raises:
#         ValueError: If object is invalid
#     """
#     if not validate_mathematical_object(obj):
        raise ValueError("Invalid mathematical object")

properties = {
#         "id": obj.id,
#         "object_type": obj.object_type.value,
#         "data": obj.data,
#     }

#     # Add type-specific properties
#     if hasattr(obj, "shape"):
properties["shape"] = obj.shape
#     if hasattr(obj, "rows"):
properties["rows"] = obj.rows
#     if hasattr(obj, "cols"):
properties["cols"] = obj.cols
#     if hasattr(obj, "dtype"):
properties["dtype"] = obj.dtype

#     return properties


def calculate_hash(obj: Any) -str):
#     """
#     Calculate a hash for any object.

#     Args:
#         obj: Object to hash

#     Returns:
#         SHA-256 hash string
#     """
#     if isinstance(obj, dict):
obj_str = json.dumps(obj, sort_keys=True)
#     elif isinstance(obj, (list, tuple)):
obj_str = json.dumps(obj)
#     else:
obj_str = str(obj)

    return hashlib.sha256(obj_str.encode()).hexdigest()


def safe_deepcopy(obj: Any) -Any):
#     """
#     Create a deep copy of an object with error handling.

#     Args:
#         obj: Object to copy

#     Returns:
#         Deep copy of the object

#     Raises:
#         ValueError: If copying fails
#     """
#     try:
#         import copy

        return copy.deepcopy(obj)
#     except Exception as e:
        logger.error(f"Deep copy failed: {e}")
        raise ValueError(f"Failed to copy object: {e}")


def validate_query_structure(query: Dict[str, Any]) -None):
#     """
#     Validate the structure of a query dictionary.

#     Args:
#         query: Query to validate

#     Raises:
#         ValueError: If query structure is invalid
#     """
#     if not isinstance(query, dict):
        raise ValueError("Query must be a dictionary")

#     if "type" not in query:
        raise ValueError("Query must specify a type")

valid_types = ["select", "insert", "update", "delete", "aggregate"]
#     if query["type"] not in valid_types:
        raise ValueError(f"Invalid query type: {query['type']}")


def parse_filter_expression(expression: str) -Dict[str, Any]):
#     """
#     Parse a filter expression into structured format.

#     Args:
#         expression: Filter expression string

#     Returns:
#         Parsed filter dictionary

#     Raises:
#         ValueError: If expression is invalid
#     """
#     if not expression:
        raise ValueError("Expression cannot be empty")

    # Basic parsing (simplified)
expression = expression.strip()

#     if "=" in expression:
field, value = expression.split("=", 1)
#         return {
            "field": field.strip(),
#             "operator": "eq",
            "value": value.strip().strip("\"'"),
#         }
#     elif ">=" in expression:
field, value = expression.split(">=", 1)
#         return {
            "field": field.strip(),
#             "operator": "gte",
            "value": value.strip().strip("\"'"),
#         }
#     elif "<=" in expression:
field, value = expression.split("<=", 1)
#         return {
            "field": field.strip(),
#             "operator": "lte",
            "value": value.strip().strip("\"'"),
#         }
#     elif ">" in expression:
field, value = expression.split(">", 1)
#         return {
            "field": field.strip(),
#             "operator": "gt",
            "value": value.strip().strip("\"'"),
#         }
#     elif "<" in expression:
field, value = expression.split("<", 1)
#         return {
            "field": field.strip(),
#             "operator": "lt",
            "value": value.strip().strip("\"'"),
#         }
#     else:
        raise ValueError(f"Invalid expression: {expression}")


def apply_filters(
#     objects: List[MathematicalObject], filters: List[Dict[str, Any]]
# ) -List[MathematicalObject]):
#     """
#     Apply filters to a list of mathematical objects.

#     Args:
#         objects: List of objects to filter
#         filters: List of filter conditions

#     Returns:
#         Filtered list of objects
#     """
#     if not filters:
        return objects.copy()

filtered_objects = []

#     for obj in objects:
matches_all = True

#         for filter_item in filters:
field = filter_item["field"]
operator = filter_item["operator"]
value = filter_item["value"]

#             # Get field value from object
obj_value = get_nested_attribute(obj, field)

#             # Apply filter
#             if not compare_values(obj_value, operator, value):
matches_all = False
#                 break

#         if matches_all:
            filtered_objects.append(obj)

#     return filtered_objects


def get_nested_attribute(obj: Any, attr_path: str) -Any):
#     """
#     Get a nested attribute from an object using dot notation.

#     Args:
#         obj: Object to get attribute from
#         attr_path: Dot-separated path to attribute

#     Returns:
#         Attribute value

#     Raises:
#         AttributeError: If attribute not found
#     """
parts = attr_path.split(".")
value = obj

#     for part in parts:
#         if hasattr(value, part):
value = getattr(value, part)
#         else:
            raise AttributeError(f"Attribute '{part}' not found in '{attr_path}'")

#     return value


def compare_values(a: Any, operator: str, b: Any) -bool):
#     """
#     Compare two values with specified operator.

#     Args:
#         a: First value
#         operator: Comparison operator
#         b: Second value

#     Returns:
#         True if comparison succeeds, False otherwise
#     """
#     try:
#         if operator == "eq":
return a == b
#         elif operator == "ne":
return a != b
#         elif operator == "gt":
#             return a b
#         elif operator == "gte"):
return a = b
#         elif operator == "lt"):
#             return a < b
#         elif operator == "lte":
return a < = b
#         elif operator == "in":
#             return a in b
#         elif operator == "contains":
#             return b in a
#         else:
            raise ValueError(f"Unknown operator: {operator}")
#     except Exception:
#         return False


def format_error_message(error: Exception, context: Optional[str] = None) -str):
#     """
#     Format an error message with optional context.

#     Args:
#         error: Exception to format
#         context: Optional context information

#     Returns:
#         Formatted error message
#     """
error_msg = str(error)

#     if context:
error_msg = f"{context}: {error_msg}"

#     return error_msg


def benchmark_function(func: callable, *args, **kwargs) -Dict[str, Any]):
#     """
#     Benchmark a function execution.

#     Args:
#         func: Function to benchmark
#         *args: Function arguments
#         **kwargs: Function keyword arguments

#     Returns:
#         Benchmark results
#     """
#     import time

start_time = time.time()

#     try:
result = func( * args, **kwargs)
success = True
#     except Exception as e:
result = None
success = False
error = str(e)

end_time = time.time()
execution_time = end_time - start_time

#     return {
#         "execution_time": execution_time,
#         "success": success,
#         "result": result,
#         "error": error if not success else None,
#     }


def detect_circular_dependency(
objects: List[MathematicalObject], reference_field: str = "references"
# ) -List[List[MathematicalObject]]):
#     """
#     Detect circular dependencies in a list of objects.

#     Args:
#         objects: List of objects to check
#         reference_field: Field that contains references

#     Returns:
#         List of circular dependency chains
#     """
#     # Build reference map
ref_map = {}
#     for obj in objects:
ref_map[obj.id] = obj

#     # Track visited nodes
visited = set()
recursion_stack = set()
cycles = []

#     def dfs(node_id, path):
#         if node_id in recursion_stack:
#             # Found cycle
cycle_start = path.index(node_id)
cycle = path[cycle_start:] + [node_id]
            cycles.append(cycle)
#             return

#         if node_id in visited:
#             return

        visited.add(node_id)
        recursion_stack.add(node_id)

obj = ref_map.get(node_id)
#         if obj and hasattr(obj, reference_field):
references = getattr(obj, reference_field, [])
#             for ref_id in references:
#                 if ref_id in ref_map:
                    dfs(ref_id, path + [node_id])

        recursion_stack.remove(node_id)

#     # Check each object
#     for obj in objects:
#         if obj.id not in visited:
            dfs(obj.id, [])

#     # Convert cycles to object chains
object_cycles = []
#     for cycle in cycles:
#         object_cycle = [ref_map[node_id] for node_id in cycle]
        object_cycles.append(object_cycle)

#     return object_cycles


def validate_object_relationship(
#     source: MathematicalObject, target: MathematicalObject, relationship_type: str
# ) -bool):
#     """
#     Validate a relationship between two mathematical objects.

#     Args:
#         source: Source object
#         target: Target object
#         relationship_type: Type of relationship to validate

#     Returns:
#         True if relationship is valid, False otherwise
#     """
#     # Define relationship validation rules
relationship_rules = {
        "parent": lambda s, t: s.id in getattr(t, "parents", []),
        "child": lambda s, t: t.id in getattr(s, "children", []),
        "reference": lambda s, t: t.id in getattr(s, "references", []),
        "dependency": lambda s, t: t.id in getattr(s, "dependencies", []),
#     }

validator = relationship_rules.get(relationship_type)
#     if validator is None:
        raise ValueError(f"Unknown relationship type: {relationship_type}")

#     try:
        return validator(source, target)
#     except Exception:
#         return False


class ObjectComparator
    #     """Utility class for comparing mathematical objects."""

    #     @staticmethod
    #     def exact_match(obj1: MathematicalObject, obj2: MathematicalObject) -bool):
    #         """Check if two objects are exactly the same."""
    return obj1.id == obj2.id and obj1.data == obj2.data

    #     @staticmethod
    #     def structural_match(obj1: MathematicalObject, obj2: MathematicalObject) -bool):
    #         """Check if two objects have the same structure."""
    return obj1.object_type == obj2.object_type and obj1.shape == obj2.shape

    #     @staticmethod
    #     def data_match(
    obj1: MathematicalObject, obj2: MathematicalObject, tolerance: float = 1e - 10
    #     ) -bool):
    #         """Check if two objects have similar data within tolerance."""
    #         if not hasattr(obj1, "data") or not hasattr(obj2, "data"):
    #             return False

    #         try:
    #             import numpy as np

    data1 = np.array(obj1.data)
    data2 = np.array(obj2.data)

    #             if data1.shape != data2.shape:
    #                 return False

    return np.allclose(data1, data2, atol = tolerance)
    #         except ImportError:
    #             # Fallback to direct comparison if numpy not available
    return obj1.data == obj2.data


class PerformanceMonitor
    #     """Utility class for monitoring performance."""

    #     def __init__(self):""Initialize performance monitor."""
    self.metrics = {}
    self.start_time = None
    self.end_time = None

    #     def start_operation(self, operation_name: str) -None):
    #         """Start monitoring an operation."""
    self.start_time = time.time()
    #         if operation_name not in self.metrics:
    self.metrics[operation_name] = {
    #                 "count": 0,
    #                 "total_time": 0.0,
                    "min_time": float("inf"),
                    "max_time": float("-inf"),
    #             }

    #     def end_operation(self, operation_name: str) -None):
    #         """End monitoring an operation."""
    #         if self.start_time is None:
    #             return

    self.end_time = time.time()
    duration = self.end_time - self.start_time

    #         if operation_name in self.metrics:
    metrics = self.metrics[operation_name]
    metrics["count"] + = 1
    metrics["total_time"] + = duration
    metrics["min_time"] = min(metrics["min_time"], duration)
    metrics["max_time"] = max(metrics["max_time"], duration)

    self.start_time = None

    #     def get_metrics(self, operation_name: Optional[str] = None) -Dict[str, Any]):
    #         """Get performance metrics."""
    #         if operation_name:
                return self.metrics.get(operation_name, {})

            return self.metrics.copy()

    #     def clear_metrics(self) -None):
    #         """Clear all metrics."""
            self.metrics.clear()
    self.start_time = None
    self.end_time = None


# Create global performance monitor instance
performance_monitor = PerformanceMonitor()


# Protobuf compatibility layer for handling version differences
class ProtobufCompatibility
    #     """Compatibility layer for handling protobuf version differences."""

    #     @staticmethod
    #     def serialize_message(message):""
    #         Serialize a protobuf message.

    #         Args:
    #             message: Protobuf message to serialize

    #         Returns:
    #             Serialized message as bytes
    #         """
    #         try:
                # Try to use SerializeToString (protobuf 3.x)
                return message.SerializeToString()
    #         except AttributeError:
                # Fallback to SerializeToString (protobuf 4.x)
                return message.SerializeToString()

    #     @staticmethod
    #     def deserialize_message(message_class, data):
    #         """
    #         Deserialize protobuf data into a message.

    #         Args:
    #             message_class: Message class to instantiate
    #             data: Serialized data

    #         Returns:
    #             Deserialized message instance
    #         """
    #         try:
                # Try to use ParseFromString (protobuf 3.x)
    message = message_class()
                message.ParseFromString(data)
    #             return message
    #         except AttributeError:
                # Fallback to ParseFromString (protobuf 4.x)
    message = message_class()
                message.ParseFromString(data)
    #             return message


class LazyMathematicalObject
    #     """Lazy mathematical object that loads data on demand."""

    #     def __init__(self, object_id, object_type, data_loader):""
    #         Initialize lazy mathematical object.

    #         Args:
    #             object_id: ID of the object
    #             object_type: Type of the object
    #             data_loader: Function to load object data
    #         """
    self.id = object_id
    self.object_type = object_type
    self._data_loader = data_loader
    self._data = None
    self._loaded = False

    #     @property
    #     def data(self):
    #         """Get object data, loading it if necessary."""
    #         if not self._loaded:
    self._data = self._data_loader()
    self._loaded = True
    #         return self._data

    #     def __repr__(self):
    #         """String representation of the lazy object."""
    return f"LazyMathematicalObject(id = {self.id}, type={self.object_type}, loaded={self._loaded})"
