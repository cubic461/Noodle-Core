# Converted from Python to NoodleCore
# Original file: src

# """
# Type Marshalling System for Noodle
# ----------------------------------
# Handles efficient type conversion between Noodle and Python.
# Optimized for performance with caching and validation.
# """

import time
import sys
import threading
import weakref
import typing.Any
from dataclasses import dataclass
import .python_capi_wrapper.get_python_capi_wrapper
import ..runtime_types.RuntimeType


dataclass
class ConversionProfile
    #     """Profile for type conversion operations"""
    #     python_type: Type
    #     noodle_type: RuntimeType
    #     converter: Callable[[Any], Value]
    #     reverse_converter: Callable[[Value], Any]
    #     cost: float  # Estimated cost in milliseconds
    cacheable: bool = True


class TypeMarshaller
    #     """Handles efficient type conversion between Noodle and Python"""

    #     def __init__(self):
    #         # API wrapper instance
    self._capi_wrapper = get_python_capi_wrapper()

    #         # Conversion profiles
    self._conversion_profiles: Dict[Type, ConversionProfile] = {}
    self._reverse_profiles: Dict[RuntimeType, ConversionProfile] = {}

    #         # Cache for converted values
    self._conversion_cache: Dict[int, Value] = {}
    self._reverse_cache: Dict[int, Any] = {}
    self._cache_hits = 0
    self._cache_misses = 0

    #         # Performance metrics
    self._total_conversion_time = 0.0
    self._total_reverse_time = 0.0
    self._conversion_count = 0
    self._reverse_count = 0

    #         # Initialize conversion profiles
            self._init_conversion_profiles()

    #         # Type validators
    self._validators: Dict[RuntimeType, Callable[[Any], bool]] = {
                RuntimeType.INTEGER: lambda x: isinstance(x, int),
                RuntimeType.FLOAT: lambda x: isinstance(x, (int, float)),
                RuntimeType.STRING: lambda x: isinstance(x, str),
                RuntimeType.BOOLEAN: lambda x: isinstance(x, bool),
                RuntimeType.LIST: lambda x: isinstance(x, list),
                RuntimeType.DICT: lambda x: isinstance(x, dict),
    #             RuntimeType.NONE: lambda x: x is None,
    #         }

    #         # Thread safety
    self._lock = threading.RLock()

    #         # Cache management
    self._cache_size_limit = 10000
    self._cache_cleanup_threshold = 0.9  # 90% of limit

    #         # Type registry for custom types
    self._custom_types: Dict[Type, RuntimeType] = {}

    #         # Type conversion hints
    self._conversion_hints: Dict[Type, Set[RuntimeType]] = {}

    #         # Error tracking
    self._conversion_errors: List[Exception] = []
    self._error_count = 0

    #         # Memory optimization
    self._weak_cache = weakref.WeakValueDictionary()

    #         # Batch processing support
    self._batch_size = 1000
    self._batch_cache: Dict[int, Value] = {}

    #         # Type inference engine
    self._type_inference_enabled = True
    self._inference_cache: Dict[Type, RuntimeType] = {}

    #         # Security features
    self._allowed_types: Set[RuntimeType] = set()
    self._forbidden_types: Set[RuntimeType] = set()

    #         # Performance optimization flags
    self._optimize_for_memory = False
    self._optimize_for_speed = True
    self._enable_caching = True

    #     def _init_conversion_profiles(self):
    #         """Initialize type conversion profiles"""
    #         # Integer conversion
    #         def int_to_noodle(x: int) -Value):
                return Value(RuntimeType.INTEGER, int(x))

    #         def noodle_to_int(v: Value) -int):
                return int(v.data)

    int_profile = ConversionProfile(
    python_type = int,
    noodle_type = RuntimeType.INTEGER,
    converter = int_to_noodle,
    reverse_converter = noodle_to_int,
    cost = 0.001,
    cacheable = True
    #         )
    self._conversion_profiles[int] = int_profile
    self._reverse_profiles[RuntimeType.INTEGER] = int_profile

    #         # Float conversion
    #         def float_to_noodle(x: float) -Value):
                return Value(RuntimeType.FLOAT, float(x))

    #         def noodle_to_float(v: Value) -float):
                return float(v.data)

    float_profile = ConversionProfile(
    python_type = float,
    noodle_type = RuntimeType.FLOAT,
    converter = float_to_noodle,
    reverse_converter = noodle_to_float,
    cost = 0.001,
    cacheable = True
    #         )
    self._conversion_profiles[float] = float_profile
    self._reverse_profiles[RuntimeType.FLOAT] = float_profile

    #         # String conversion
    #         def str_to_noodle(x: str) -Value):
                return Value(RuntimeType.STRING, str(x))

    #         def noodle_to_str(v: Value) -str):
                return str(v.data)

    str_profile = ConversionProfile(
    python_type = str,
    noodle_type = RuntimeType.STRING,
    converter = str_to_noodle,
    reverse_converter = noodle_to_str,
    cost = 0.01,
    cacheable = True
    #         )
    self._conversion_profiles[str] = str_profile
    self._reverse_profiles[RuntimeType.STRING] = str_profile

    #         # Boolean conversion
    #         def bool_to_noodle(x: bool) -Value):
                return Value(RuntimeType.BOOLEAN, bool(x))

    #         def noodle_to_bool(v: Value) -bool):
                return bool(v.data)

    bool_profile = ConversionProfile(
    python_type = bool,
    noodle_type = RuntimeType.BOOLEAN,
    converter = bool_to_noodle,
    reverse_converter = noodle_to_bool,
    cost = 0.001,
    cacheable = True
    #         )
    self._conversion_profiles[bool] = bool_profile
    self._reverse_profiles[RuntimeType.BOOLEAN] = bool_profile

            # List conversion (complex - not cached)
    #         def list_to_noodle(x: List) -Value):
    #             elements = [self.python_to_noodle(item) for item in x]
                return Value(RuntimeType.LIST, elements)

    #         def noodle_to_list(v: Value) -List):
    #             return [self.noodle_to_python(item) for item in v.data]

    list_profile = ConversionProfile(
    python_type = list,
    noodle_type = RuntimeType.LIST,
    converter = list_to_noodle,
    reverse_converter = noodle_to_list,
    cost = 0.1,  # Higher cost due to recursive conversion
    cacheable = False
    #         )
    self._conversion_profiles[list] = list_profile
    self._reverse_profiles[RuntimeType.LIST] = list_profile

            # Dict conversion (complex - not cached)
    #         def dict_to_noodle(x: Dict) -Value):
    converted_dict = {}
    #             for k, v in x.items():
    #                 # Only string keys supported for now
    #                 if isinstance(k, str):
    converted_dict[k] = self.python_to_noodle(v)
                return Value(RuntimeType.DICT, converted_dict)

    #         def noodle_to_dict(v: Value) -Dict):
    result = {}
    #             for k, item_v in v.data.items():
    result[k] = self.noodle_to_python(item_v)
    #             return result

    dict_profile = ConversionProfile(
    python_type = dict,
    noodle_type = RuntimeType.DICT,
    converter = dict_to_noodle,
    reverse_converter = noodle_to_dict,
    cost = 0.1,  # Higher cost due to recursive conversion
    cacheable = False
    #         )
    self._conversion_profiles[dict] = dict_profile
    self._reverse_profiles[RuntimeType.DICT] = dict_profile

    #         # None conversion
    #         def none_to_noodle(x: None) -Value):
                return Value(RuntimeType.NONE, None)

    #         def noodle_to_none(v: Value) -None):
    #             return None

    none_profile = ConversionProfile(
    python_type = type(None),
    noodle_type = RuntimeType.NONE,
    converter = none_to_noodle,
    reverse_converter = noodle_to_none,
    cost = 0.001,
    cacheable = True
    #         )
    self._conversion_profiles[type(None)] = none_profile
    self._reverse_profiles[RuntimeType.NONE] = none_profile

    #     def python_to_noodle(self, python_obj: Any) -Value):
    #         """
    #         Convert Python object to Noodle Value with optimization

    #         Args:
    #             python_obj: Python object to convert

    #         Returns:
    #             Converted Noodle Value
    #         """
    start_time = time.perf_counter()

    #         # Handle None
    #         if python_obj is None:
    result = Value(RuntimeType.NONE, None)
    self._cache_misses + = 1
    self._conversion_count + = 1
    self._total_conversion_time + = time.perf_counter() - start_time
    #             return result

    #         # Check cache
    python_id = id(python_obj)
    #         if python_id in self._conversion_cache:
    self._cache_hits + = 1
    self._conversion_count + = 1
    self._total_conversion_time + = time.perf_counter() - start_time
    #             return self._conversion_cache[python_id]

    #         # Get conversion profile
    python_type = type(python_obj)
    profile = self._conversion_profiles.get(python_type)

    #         if profile is None:
    #             # No specific profile - use generic conversion
    result = self._capi_wrapper.python_to_noodle(python_obj)
    #         else:
    #             # Use optimized conversion
    result = profile.converter(python_obj)

    #             # Cache if cacheable
    #             if profile.cacheable:
    self._conversion_cache[python_id] = result

    self._cache_misses + = 1
    self._conversion_count + = 1
    self._total_conversion_time + = time.perf_counter() - start_time
    #         return result

    #     def noodle_to_python(self, noodle_value: Value) -Any):
    #         """
    #         Convert Noodle Value to Python object with optimization

    #         Args:
    #             noodle_value: Noodle Value to convert

    #         Returns:
    #             Converted Python object
    #         """
    start_time = time.perf_counter()

    #         # Handle None
    #         if noodle_value.type == RuntimeType.NONE:
    result = None
    self._cache_misses + = 1
    self._reverse_count + = 1
    self._total_reverse_time + = time.perf_counter() - start_time
    #             return result

    #         # Check cache
    value_id = id(noodle_value)
    #         if value_id in self._reverse_cache:
    self._cache_hits + = 1
    self._reverse_count + = 1
    self._total_reverse_time + = time.perf_counter() - start_time
    #             return self._reverse_cache[value_id]

    #         # Get conversion profile
    profile = self._reverse_profiles.get(noodle_value.type)

    #         if profile is None:
    #             # No specific profile - use generic conversion
    result = self._capi_wrapper.noodle_to_python(noodle_value)
    #         else:
    #             # Use optimized conversion
    result = profile.reverse_converter(noodle_value)

    #             # Cache if cacheable
    #             if profile.cacheable:
    self._reverse_cache[value_id] = result

    self._cache_misses + = 1
    self._reverse_count + = 1
    self._total_reverse_time + = time.perf_counter() - start_time
    #         return result

    #     def validate_type(self, value: Any, expected_type: RuntimeType) -bool):
    #         """
    #         Validate that a value matches the expected type

    #         Args:
    #             value: Value to validate
    #             expected_type: Expected Noodle type

    #         Returns:
    #             True if valid, False otherwise
    #         """
    validator = self._validators.get(expected_type)
    #         if validator is None:
    #             return False  # Unknown type

    #         # For complex types, we need to handle the validation differently
    #         if expected_type == RuntimeType.LIST:
                return isinstance(value, list) and all(
    #                 self.validate_type(item, RuntimeType.OBJECT) for item in value
    #             )
    #         elif expected_type == RuntimeType.DICT:
                return (isinstance(value, dict) and
    #                     all(isinstance(k, str) for k in value.keys()) and
    #                     all(self.validate_type(v, RuntimeType.OBJECT) for v in value.values()))

            return validator(value)

    #     def get_conversion_stats(self) -Dict[str, Any]):
    #         """
    #         Get performance statistics for type conversions

    #         Returns:
    #             Dictionary with conversion statistics
    #         """
    total_time = self._total_conversion_time + self._total_reverse_time
    total_conversions = self._conversion_count + self._reverse_count

    #         return {
    #             'total_conversions': total_conversions,
    #             'cache_hits': self._cache_hits,
    #             'cache_misses': self._cache_misses,
                'cache_hit_rate': self._cache_hits / max(total_conversions, 1),
    #             'total_time_ms': total_time * 1000,
                'avg_time_ms_per_conversion': (total_time / max(total_conversions, 1)) * 1000,
    #             'python_to_noodle_time_ms': self._total_conversion_time * 1000,
    #             'noodle_to_python_time_ms': self._total_reverse_time * 1000,
    #         }

    #     def reset_stats(self):
    #         """Reset performance statistics"""
    self._cache_hits = 0
    self._cache_misses = 0
    self._total_conversion_time = 0.0
    self._total_reverse_time = 0.0
    self._conversion_count = 0
    self._reverse_count = 0

    #     def clear_cache(self):
    #         """Clear conversion cache"""
            self._conversion_cache.clear()
            self._reverse_cache.clear()

    #     def add_custom_converter(self,
    #                            python_type: Type,
    #                            noodle_type: RuntimeType,
    #                            converter: Callable[[Any], Value],
    #                            reverse_converter: Callable[[Value], Any],
    cost: float = 0.01,
    cacheable: bool = True):
    #         """
    #         Add a custom type converter

    #         Args:
    #             python_type: Python type to convert from
    #             noodle_type: Noodle type to convert to
    #             converter: Function to convert Python to Noodle
    #             reverse_converter: Function to convert Noodle to Python
    #             cost: Estimated conversion cost in milliseconds
    #             cacheable: Whether conversions can be cached
    #         """
    #         with self._lock:
    profile = ConversionProfile(
    python_type = python_type,
    noodle_type = noodle_type,
    converter = converter,
    reverse_converter = reverse_converter,
    cost = cost,
    cacheable = cacheable
    #             )
    self._conversion_profiles[python_type] = profile
    self._reverse_profiles[noodle_type] = profile

    #     def register_custom_type(self, python_type: Type, noodle_type: RuntimeType):
    #         """Register a custom type for conversion"""
    #         with self._lock:
    self._custom_types[python_type] = noodle_type
    self._inference_cache[python_type] = noodle_type

    #     def infer_runtime_type(self, python_obj: Any) -RuntimeType):
    #         """Infer the Noodle type from a Python object"""
    #         if self._type_inference_enabled:
    python_type = type(python_obj)
    #             # Check cache first
    #             if python_type in self._inference_cache:
    #                 return self._inference_cache[python_type]

    #             # Check custom types
    #             if python_type in self._custom_types:
    #                 return self._custom_types[python_type]

    #             # Default inference
    #             if python_obj is None:
    #                 return RuntimeType.NONE
    #             elif isinstance(python_obj, bool):
    #                 return RuntimeType.BOOLEAN
    #             elif isinstance(python_obj, int):
    #                 return RuntimeType.INTEGER
    #             elif isinstance(python_obj, float):
    #                 return RuntimeType.FLOAT
    #             elif isinstance(python_obj, str):
    #                 return RuntimeType.STRING
    #             elif isinstance(python_obj, list):
    #                 return RuntimeType.LIST
    #             elif isinstance(python_obj, dict):
    #                 return RuntimeType.DICT
    #             else:
    #                 return RuntimeType.OBJECT
    #         else:
    #             return RuntimeType.OBJECT

    #     def batch_convert(self, python_objects: List[Any]) -List[Value]):
    #         """Convert multiple Python objects to Noodle Values efficiently"""
    results = []
    batch_start = time.perf_counter()

    #         for i, obj in enumerate(python_objects):
    #             # Use batch cache if available
    obj_id = id(obj)
    #             if obj_id in self._batch_cache:
                    results.append(self._batch_cache[obj_id])
    #             else:
    result = self.python_to_noodle(obj)
                    results.append(result)

    #                 # Add to batch cache if under limit
    #                 if len(self._batch_cache) < self._batch_size:
    self._batch_cache[obj_id] = result

    #             # Clean up batch cache if it gets too large
    #             if len(self._batch_cache) self._batch_size):
                    self._cleanup_batch_cache()

    batch_time = time.perf_counter() - batch_start
    #         return results

    #     def cleanup_cache(self):
    #         """Clean up caches to manage memory"""
    #         with self._lock:
    #             # Regular cache cleanup
    cache_size = len(self._conversion_cache) + len(self._reverse_cache)
    #             if cache_size self._cache_size_limit * self._cache_cleanup_threshold):
    #                 # Remove oldest entries
    items_to_remove = int(cache_size - self._cache_size_limit * 0.8)
    #                 if items_to_remove 0):
    keys_to_remove = math.divide(list(self._conversion_cache.keys())[:items_to_remove, /2])
    #                     for key in keys_to_remove:
                            self._conversion_cache.pop(key, None)

    keys_to_remove = math.divide(list(self._reverse_cache.keys())[:items_to_remove, /2])
    #                     for key in keys_to_remove:
                            self._reverse_cache.pop(key, None)

    #             # Batch cache cleanup
                self._cleanup_batch_cache()

    #     def _cleanup_batch_cache(self):
    #         """Clean up batch cache"""
    #         if len(self._batch_cache) self._batch_size):
    #             # Remove oldest entries
    items_to_remove = len(self._batch_cache) - self._batch_size
    keys_to_remove = list(self._batch_cache.keys())[:items_to_remove]
    #             for key in keys_to_remove:
                    self._batch_cache.pop(key, None)

    #     def set_cache_limits(self, size_limit: int, cleanup_threshold: float):
    #         """Set cache size limits"""
    #         with self._lock:
    self._cache_size_limit = size_limit
    self._cache_cleanup_threshold = cleanup_threshold
                self._cleanup_cache()

    #     def get_cache_stats(self) -Dict[str, Any]):
    #         """Get cache statistics"""
    #         return {
                'conversion_cache_size': len(self._conversion_cache),
                'reverse_cache_size': len(self._reverse_cache),
                'batch_cache_size': len(self._batch_cache),
                'weak_cache_size': len(self._weak_cache),
    #             'cache_size_limit': self._cache_size_limit,
    #             'cache_cleanup_threshold': self._cache_cleanup_threshold,
                'cache_hit_rate': self._cache_hits / max(self._cache_hits + self._cache_misses, 1),
    #         }

    #     def set_type_inference(self, enabled: bool):
    #         """Enable or disable type inference"""
    self._type_inference_enabled = enabled

    #     def set_performance_mode(self, mode: str):
    #         """Set performance optimization mode"""
    #         if mode == 'memory':
    self._optimize_for_memory = True
    self._optimize_for_speed = False
    self._enable_caching = False
    #         elif mode == 'speed':
    self._optimize_for_memory = False
    self._optimize_for_speed = True
    self._enable_caching = True
    #         elif mode == 'balanced':
    self._optimize_for_memory = False
    self._optimize_for_speed = True
    self._enable_caching = True

    #     def set_allowed_types(self, types: Set[RuntimeType]):
    #         """Set allowed types for security"""
    self._allowed_types = set(types)

    #     def set_forbidden_types(self, types: Set[RuntimeType]):
    #         """Set forbidden types for security"""
    self._forbidden_types = set(types)

    #     def is_type_allowed(self, runtime_type: RuntimeType) -bool):
    #         """Check if a type is allowed based on security rules"""
    #         # Check forbidden first
    #         if runtime_type in self._forbidden_types:
    #             return False

    #         # Check allowed if set
    #         if self._allowed_types:
    #             return runtime_type in self._allowed_types

    #         # Default to allowed if no restrictions
    #         return True

    #     def get_conversion_errors(self) -List[Exception]):
    #         """Get list of conversion errors"""
            return self._conversion_errors.copy()

    #     def clear_errors(self):
    #         """Clear error list"""
            self._conversion_errors.clear()
    self._error_count = 0

    #     def add_conversion_hint(self, python_type: Type, noodle_types: Set[RuntimeType]):
    #         """Add conversion hints for a Python type"""
    #         with self._lock:
    self._conversion_hints[python_type] = noodle_types

    #     def get_conversion_hints(self, python_type: Type) -Set[RuntimeType]):
    #         """Get conversion hints for a Python type"""
            return self._conversion_hints.get(python_type, set())

    #     def optimize_cache(self):
    #         """Optimize cache based on usage patterns"""
    #         # Remove least recently used items
    #         # This is a simple implementation - could be enhanced with LRU cache
    #         if len(self._conversion_cache) self._cache_size_limit):
    items_to_remove = len(self._conversion_cache) - int(self._cache_size_limit * 0.8)
    keys = list(self._conversion_cache.keys())
    #             for key in keys[:items_to_remove]:
                    self._conversion_cache.pop(key, None)

    #         if len(self._reverse_cache) self._cache_size_limit):
    items_to_remove = len(self._reverse_cache) - int(self._cache_size_limit * 0.8)
    keys = list(self._reverse_cache.keys())
    #             for key in keys[:items_to_remove]:
                    self._reverse_cache.pop(key, None)

    #     def get_memory_usage(self) -Dict[str, Any]):
    #         """Get memory usage statistics"""
    #         import sys as _sys

    #         return {
                'conversion_cache_memory': _sys.getsizeof(self._conversion_cache),
                'reverse_cache_memory': _sys.getsizeof(self._reverse_cache),
                'batch_cache_memory': _sys.getsizeof(self._batch_cache),
                'weak_cache_memory': _sys.getsizeof(self._weak_cache),
                'conversion_profiles_memory': _sys.getsizeof(self._conversion_profiles),
                'reverse_profiles_memory': _sys.getsizeof(self._reverse_profiles),
                'custom_types_memory': _sys.getsizeof(self._custom_types),
                'conversion_hints_memory': _sys.getsizeof(self._conversion_hints),
                'total_memory': _sys.getsizeof(self),
    #         }

    #     def get_detailed_stats(self) -Dict[str, Any]):
    #         """Get detailed performance and memory statistics"""
    #         return {
                'performance': self.get_conversion_stats(),
                'cache': self.get_cache_stats(),
                'memory': self.get_memory_usage(),
    #             'errors': {
    #                 'error_count': self._error_count,
                    'recent_errors': len(self._conversion_errors),
    #             },
    #             'configuration': {
    #                 'type_inference_enabled': self._type_inference_enabled,
    #                 'optimize_for_memory': self._optimize_for_memory,
    #                 'optimize_for_speed': self._optimize_for_speed,
    #                 'enable_caching': self._enable_caching,
    #                 'cache_size_limit': self._cache_size_limit,
    #                 'cache_cleanup_threshold': self._cache_cleanup_threshold,
    #                 'batch_size': self._batch_size,
    #             },
    #             'type_registry': {
                    'custom_types_count': len(self._custom_types),
                    'conversion_profiles_count': len(self._conversion_profiles),
                    'reverse_profiles_count': len(self._reverse_profiles),
    #             },
    #         }


# Global instance
_type_marshaller = None

def get_type_marshaller() -TypeMarshaller):
#     """Get the global type marshaller instance"""
#     global _type_marshaller
#     if _type_marshaller is None:
_type_marshaller = TypeMarshaller()
#     return _type_marshaller
