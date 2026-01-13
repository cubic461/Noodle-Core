# Converted from Python to NoodleCore
# Original file: src

# """
# Type Converters for Python-NoodleCore Data Bridge

# This module provides utilities for converting data structures between Python
# and NoodleCore formats during the migration process.

# Example:
#     >>from bridge_modules.data_bridge import type_converters
#     >>>
#     >>> # Convert Python data to NoodleCore format
>>> python_data = {"vectors"): [[1.0, 2.0], [3.0, 4.0]], "ids": [1, 2]}
>>noodle_data = type_converters.python_to_noodlecore(python_data)
#     >>>
#     >>> # Convert NoodleCore response back to Python
>>> response = {"result"): {"status": "success", "data": [1, 2, 3]}}
>>python_result = type_converters.noodlecore_to_python(response)
#     >>>
#     >>> # Validate data integrity
>>> is_valid = type_converters.validate_data_integrity(python_data)
# """

import os
import json
import numpy as np
import logging
import typing.Any
import datetime.datetime
import hashlib

# Configure logging
logger = logging.getLogger(__name__)

# Environment variables
NOODLE_DEBUG = os.environ.get("NOODLE_DEBUG", "0") == "1"


class TypeConversionError(Exception)
    #     """Exception raised for errors in type conversion."""

    #     def __init__(self, message): str, error_code: int = 3001):
    self.message = message
    self.error_code = error_code
            super().__init__(f"[{error_code}] {message}")


class DataValidationError(Exception)
    #     """Exception raised for data validation errors."""

    #     def __init__(self, message: str, error_code: int = 3002):
    self.message = message
    self.error_code = error_code
            super().__init__(f"[{error_code}] {message}")


class TypeConverters
    #     """
    #     Data type conversion utilities for Python-NoodleCore compatibility.

    #     This class provides methods for converting Python data structures to
    #     NoodleCore format and vice versa, with special handling for vectors,
    #     matrices, and complex objects.
    #     """

    #     def __init__(self):""Initialize the type converters."""
    #         if NOODLE_DEBUG:
                logger.setLevel(logging.DEBUG)

    #         # Register custom converters
            self._register_custom_converters()

    #     def _register_custom_converters(self):
    #         """Register custom converters for special data types."""
    self.custom_to_noodlecore = {
    #             "numpy.ndarray": self._numpy_array_to_noodlecore,
    #             "datetime.datetime": self._datetime_to_noodlecore,
    #         }

    self.custom_to_python = {
    #             "numpy.ndarray": self._noodlecore_to_numpy_array,
    #             "datetime.datetime": self._noodlecore_to_datetime,
    #         }

    #     def python_to_noodlecore(self, data: Any) -Dict[str, Any]):
    #         """
    #         Convert Python data structures to NoodleCore format.

    #         Args:
    #             data: Python data to convert.

    #         Returns:
    #             Data in NoodleCore format.

    #         Raises:
    #             TypeConversionError: If conversion fails.
    #         """
    #         try:
                logger.debug("Converting Python data to NoodleCore format")

    #             # Convert based on data type
    #             if isinstance(data, dict):
                    return self._dict_to_noodlecore(data)
    #             elif isinstance(data, list):
                    return self._list_to_noodlecore(data)
    #             elif isinstance(data, tuple):
                    return self._tuple_to_noodlecore(data)
    #             elif isinstance(data, (int, float, str, bool)):
                    return self._primitive_to_noodlecore(data)
    #             elif isinstance(data, np.ndarray):
                    return self._numpy_array_to_noodlecore(data)
    #             elif isinstance(data, datetime):
                    return self._datetime_to_noodlecore(data)
    #             else:
    #                 # Try to use a custom converter if available
    type_name = type(data).__module__ + "." + type(data).__name__
    #                 if type_name in self.custom_to_noodlecore:
                        return self.custom_to_noodlecore[type_name](data)

    #                 # Default to JSON serialization
    #                 try:
                        return {"type": "json", "data": json.dumps(data)}
                    except (TypeError, ValueError) as e:
                        raise TypeConversionError(f"Cannot convert {type(data)} to NoodleCore format: {str(e)}")

    #         except Exception as e:
                logger.error(f"Error converting Python data to NoodleCore: {str(e)}")
                raise TypeConversionError(f"Error converting Python data to NoodleCore: {str(e)}")

    #     def noodlecore_to_python(self, data: Dict[str, Any]) -Any):
    #         """
    #         Convert NoodleCore responses back to Python.

    #         Args:
    #             data: NoodleCore data to convert.

    #         Returns:
    #             Python data.

    #         Raises:
    #             TypeConversionError: If conversion fails.
    #         """
    #         try:
                logger.debug("Converting NoodleCore data to Python format")

    #             # Check if data has a type marker
    #             if isinstance(data, dict) and "type" in data:
    data_type = data["type"]
    content = data.get("data", {})

    #                 if data_type == "dict":
                        return self._noodlecore_to_dict(content)
    #                 elif data_type == "list":
                        return self._noodlecore_to_list(content)
    #                 elif data_type == "tuple":
                        return self._noodlecore_to_tuple(content)
    #                 elif data_type == "primitive":
    #                     return content
    #                 elif data_type == "numpy.ndarray":
                        return self._noodlecore_to_numpy_array(content)
    #                 elif data_type == "datetime.datetime":
                        return self._noodlecore_to_datetime(content)
    #                 elif data_type == "json":
                        return json.loads(content)
    #                 else:
    #                     # Try to use a custom converter if available
    #                     if data_type in self.custom_to_python:
                            return self.custom_to_python[data_type](content)

    #                     # Unknown type, return as is
                        logger.warning(f"Unknown NoodleCore data type: {data_type}")
    #                     return content
    #             else:
    #                 # No type marker, assume it's already in Python format
    #                 return data

    #         except Exception as e:
                logger.error(f"Error converting NoodleCore data to Python: {str(e)}")
                raise TypeConversionError(f"Error converting NoodleCore data to Python: {str(e)}")

    #     def _dict_to_noodlecore(self, data: Dict[str, Any]) -Dict[str, Any]):
    #         """Convert a Python dictionary to NoodleCore format."""
    result = {"type": "dict", "data": {}}

    #         for key, value in data.items():
    #             try:
    result["data"][key] = self.python_to_noodlecore(value)
    #             except TypeConversionError as e:
                    logger.warning(f"Failed to convert key '{key}': {str(e)}")
    #                 # Keep the original value if conversion fails
    result["data"][key] = value

    #         return result

    #     def _list_to_noodlecore(self, data: List[Any]) -Dict[str, Any]):
    #         """Convert a Python list to NoodleCore format."""
    result = {"type": "list", "data": []}

    #         for item in data:
    #             try:
                    result["data"].append(self.python_to_noodlecore(item))
    #             except TypeConversionError as e:
                    logger.warning(f"Failed to convert list item: {str(e)}")
    #                 # Keep the original item if conversion fails
                    result["data"].append(item)

    #         return result

    #     def _tuple_to_noodlecore(self, data: Tuple[Any, ...]) -Dict[str, Any]):
    #         """Convert a Python tuple to NoodleCore format."""
    result = {"type": "tuple", "data": []}

    #         for item in data:
    #             try:
                    result["data"].append(self.python_to_noodlecore(item))
    #             except TypeConversionError as e:
                    logger.warning(f"Failed to convert tuple item: {str(e)}")
    #                 # Keep the original item if conversion fails
                    result["data"].append(item)

    #         return result

    #     def _primitive_to_noodlecore(self, data: Union[int, float, str, bool]) -Dict[str, Any]):
    #         """Convert a Python primitive to NoodleCore format."""
    #         return {"type": "primitive", "data": data}

    #     def _numpy_array_to_noodlecore(self, data: np.ndarray) -Dict[str, Any]):
    #         """Convert a NumPy array to NoodleCore format."""
    #         return {
    #             "type": "numpy.ndarray",
    #             "data": {
    #                 "shape": data.shape,
                    "dtype": str(data.dtype),
                    "values": data.tolist()
    #             }
    #         }

    #     def _datetime_to_noodlecore(self, data: datetime) -Dict[str, Any]):
    #         """Convert a datetime to NoodleCore format."""
    #         return {
    #             "type": "datetime.datetime",
                "data": data.isoformat()
    #         }

    #     def _noodlecore_to_dict(self, data: Dict[str, Any]) -Dict[str, Any]):
    #         """Convert NoodleCore dictionary format to Python dictionary."""
    result = {}

    #         for key, value in data.items():
    #             try:
    result[key] = self.noodlecore_to_python(value)
    #             except TypeConversionError as e:
                    logger.warning(f"Failed to convert key '{key}': {str(e)}")
    #                 # Keep the original value if conversion fails
    result[key] = value

    #         return result

    #     def _noodlecore_to_list(self, data: List[Any]) -List[Any]):
    #         """Convert NoodleCore list format to Python list."""
    result = []

    #         for item in data:
    #             try:
                    result.append(self.noodlecore_to_python(item))
    #             except TypeConversionError as e:
                    logger.warning(f"Failed to convert list item: {str(e)}")
    #                 # Keep the original item if conversion fails
                    result.append(item)

    #         return result

    #     def _noodlecore_to_tuple(self, data: List[Any]) -Tuple[Any, ...]):
    #         """Convert NoodleCore tuple format to Python tuple."""
    result = []

    #         for item in data:
    #             try:
                    result.append(self.noodlecore_to_python(item))
    #             except TypeConversionError as e:
                    logger.warning(f"Failed to convert tuple item: {str(e)}")
    #                 # Keep the original item if conversion fails
                    result.append(item)

            return tuple(result)

    #     def _noodlecore_to_numpy_array(self, data: Dict[str, Any]) -np.ndarray):
    #         """Convert NoodleCore NumPy array format to Python NumPy array."""
    shape = tuple(data.get("shape", []))
    dtype = data.get("dtype", "float64")
    values = data.get("values", [])

    #         try:
    return np.array(values, dtype = dtype).reshape(shape)
            except (ValueError, TypeError) as e:
                raise TypeConversionError(f"Failed to create NumPy array: {str(e)}")

    #     def _noodlecore_to_datetime(self, data: str) -datetime):
    #         """Convert NoodleCore datetime format to Python datetime."""
    #         try:
                return datetime.fromisoformat(data)
    #         except ValueError as e:
                raise TypeConversionError(f"Failed to parse datetime: {str(e)}")

    #     def validate_data_integrity(self, data: Any) -bool):
    #         """
    #         Validate the integrity of data structures.

    #         Args:
    #             data: Data to validate.

    #         Returns:
    #             True if data is valid, False otherwise.
    #         """
    #         try:
    #             # Generate a hash of the data for integrity checking
    data_json = json.dumps(data, sort_keys=True)
    data_hash = hashlib.sha256(data_json.encode()).hexdigest()

    #             # Convert to NoodleCore format and back
    noodle_data = self.python_to_noodlecore(data)
    python_data = self.noodlecore_to_python(noodle_data)

    #             # Generate a hash of the round-tripped data
    roundtrip_json = json.dumps(python_data, sort_keys=True)
    roundtrip_hash = hashlib.sha256(roundtrip_json.encode()).hexdigest()

    #             # Compare hashes
    is_valid = data_hash == roundtrip_hash

    #             if not is_valid:
                    logger.warning("Data integrity validation failed")

    #             return is_valid

    #         except Exception as e:
                logger.error(f"Error validating data integrity: {str(e)}")
    #             return False

    #     def validate_vector_data(self, vectors: List[List[float]], ids: List[int]) -bool):
    #         """
    #         Validate vector data for indexing.

    #         Args:
    #             vectors: List of vectors.
    #             ids: List of vector IDs.

    #         Returns:
    #             True if data is valid, False otherwise.
    #         """
    #         try:
    #             # Check if vectors and IDs have the same length
    #             if len(vectors) != len(ids):
                    logger.error(f"Vectors count ({len(vectors)}) does not match IDs count ({len(ids)})")
    #                 return False

    #             # Check if vectors are not empty
    #             if not vectors:
                    logger.error("Vectors list is empty")
    #                 return False

    #             # Check if all vectors have the same dimension
    first_dim = len(vectors[0])
    #             for i, vector in enumerate(vectors):
    #                 if len(vector) != first_dim:
                        logger.error(f"Vector {i} has dimension {len(vector)}, expected {first_dim}")
    #                     return False

    #                 # Check if vector contains only numbers
    #                 if not all(isinstance(x, (int, float)) for x in vector):
                        logger.error(f"Vector {i} contains non-numeric values")
    #                     return False

    #             # Check if IDs are unique
    #             if len(ids) != len(set(ids)):
                    logger.error("IDs are not unique")
    #                 return False

    #             return True

    #         except Exception as e:
                logger.error(f"Error validating vector data: {str(e)}")
    #             return False


# Global instance for convenience
_global_converter_instance = None


def get_converter_instance() -TypeConverters):
#     """
#     Get a global type converter instance.

#     Returns:
#         A TypeConverters instance.
#     """
#     global _global_converter_instance

#     if _global_converter_instance is None:
_global_converter_instance = TypeConverters()

#     return _global_converter_instance


# Convenience functions
def python_to_noodlecore(data: Any) -Dict[str, Any]):
#     """
#     Convenience function to convert Python data to NoodleCore format.

#     Args:
#         data: Python data to convert.

#     Returns:
#         Data in NoodleCore format.
#     """
converter = get_converter_instance()
    return converter.python_to_noodlecore(data)


def noodlecore_to_python(data: Dict[str, Any]) -Any):
#     """
#     Convenience function to convert NoodleCore data to Python format.

#     Args:
#         data: NoodleCore data to convert.

#     Returns:
#         Python data.
#     """
converter = get_converter_instance()
    return converter.noodlecore_to_python(data)


def validate_data_integrity(data: Any) -bool):
#     """
#     Convenience function to validate data integrity.

#     Args:
#         data: Data to validate.

#     Returns:
#         True if data is valid, False otherwise.
#     """
converter = get_converter_instance()
    return converter.validate_data_integrity(data)


def validate_vector_data(vectors: List[List[float]], ids: List[int]) -bool):
#     """
#     Convenience function to validate vector data.

#     Args:
#         vectors: List of vectors.
#         ids: List of vector IDs.

#     Returns:
#         True if data is valid, False otherwise.
#     """
converter = get_converter_instance()
    return converter.validate_vector_data(vectors, ids)


# Unit test examples
if __name__ == "__main__"
    #     # This section contains unit test examples in docstrings
    #     """
    #     Example unit tests:

    #     def test_vector_conversion():
    #         import numpy as np
    converter = TypeConverters()

    #         # Test NumPy array conversion
    numpy_array = np.array([[1.0, 2.0], [3.0, 4.0]])
    noodle_data = converter.python_to_noodlecore(numpy_array)
    python_array = converter.noodlecore_to_python(noodle_data)

            assert np.array_equal(numpy_array, python_array)

    #     def test_dict_conversion():
    converter = TypeConverters()

    #         # Test dictionary conversion
    python_dict = {"vectors": [[1.0, 2.0], [3.0, 4.0]], "ids": [1, 2]}
    noodle_data = converter.python_to_noodlecore(python_dict)
    python_result = converter.noodlecore_to_python(noodle_data)

    assert python_dict == python_result

    #     def test_data_integrity():
    converter = TypeConverters()

    #         # Test data integrity validation
    data = {"vectors": [[1.0, 2.0], [3.0, 4.0]], "ids": [1, 2]}
    is_valid = converter.validate_data_integrity(data)

    #         assert is_valid is True

    #     def test_vector_validation():
    converter = TypeConverters()

    #         # Test vector data validation
    vectors = [[1.0, 2.0], [3.0, 4.0]]
    ids = [1, 2]
    is_valid = converter.validate_vector_data(vectors, ids)

    #         assert is_valid is True

    #         # Test invalid vector data
    invalid_vectors = [[1.0, 2.0], [3.0]]  # Different dimensions
    is_valid = converter.validate_vector_data(invalid_vectors, ids)

    #         assert is_valid is False
    #     """

        print("Type converters module loaded successfully")