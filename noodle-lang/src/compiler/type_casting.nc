# Converted from Python to NoodleCore
# Original file: src

# """
# Type casting and conversion utilities for Noodle compiler.
# Provides safe type conversions and casting mechanisms.
# """

import typing.Any
from dataclasses import dataclass
import enum.Enum
import abc
import abc.ABC

import .error_reporting.get_error_reporter
import .errors.TypeError
import .generic_types.(
#     TypeVariable, GenericType, FunctionType, GenericTypeConstructor,
#     Variance, BoundConstraint, TypeScheme
# )


class CastDirection(Enum)
    #     """Direction of type casting"""
    UPCAST = "upcast"      # Safe conversion to supertype
    DOWNCAST = "downcast"  # Potentially unsafe conversion to subtype
    COERCION = "coercion"  # Implicit type conversion
    EXPLICIT = "explicit"  # Explicit casting


dataclass
class CastResult
    #     """Result of a type cast operation"""
    #     success: bool
    cast_value: Any = None
    error_message: Optional[str] = None
    warnings: List[str] = field(default_factory=list)
    cast_direction: Optional[CastDirection] = None
    conversion_cost: float = 0.0


class TypeCastRule
    #     """Represents a type casting rule"""

    #     def __init__(self, from_type: Type, to_type: Type,
    #                  direction: CastDirection,
    converter: Optional[Callable] = None,
    cost: float = 1.0,
    is_safe: bool = True):
    self.from_type = from_type
    self.to_type = to_type
    self.direction = direction
    self.converter = converter
    self.cost = cost
    self.is_safe = is_safe
    self.preconditions: List[Callable] = []
    self.postconditions: List[Callable] = []

    #     def add_precondition(self, condition: Callable[[Any], bool]):
    #         """Add a precondition for the cast"""
            self.preconditions.append(condition)

    #     def add_postcondition(self, condition: Callable[[Any], bool]):
    #         """Add a postcondition for the cast"""
            self.postconditions.append(condition)

    #     def can_cast(self, value: Any) -bool):
    #         """Check if the value can be cast according to this rule"""
    #         # Check preconditions
    #         for condition in self.preconditions:
    #             if not condition(value):
    #                 return False

    #         return True

    #     def cast(self, value: Any) -CastResult):
    #         """Attempt to cast a value according to this rule"""
    #         try:
    #             # Check if we can cast
    #             if not self.can_cast(value):
                    return CastResult(
    success = False,
    #                     error_message=f"Precondition failed for cast from {self.from_type} to {self.to_type}"
    #                 )

    #             # Apply converter if available
    #             if self.converter:
    cast_value = self.converter(value)
    #             else:
    cast_value = value

    #             # Check postconditions
    #             for condition in self.postconditions:
    #                 if not condition(cast_value):
                        return CastResult(
    success = False,
    #                         error_message=f"Postcondition failed for cast from {self.from_type} to {self.to_type}"
    #                     )

                return CastResult(
    success = True,
    cast_value = cast_value,
    cast_direction = self.direction,
    conversion_cost = self.cost
    #             )

    #         except Exception as e:
                return CastResult(
    success = False,
    error_message = f"Cast failed: {str(e)}"
    #             )


class TypeCastingEngine
    #     """Main type casting engine"""

    #     def __init__(self):
    self.error_reporter = get_error_reporter()
    self.cast_rules: Dict[Tuple[Type, Type], List[TypeCastRule]] = {}
    self.type_hierarchy: Dict[Type, Set[Type]] = {}
    self.coercion_rules: Dict[Tuple[Type, Type], Callable] = {}
    self.safe_upcasts: Set[Tuple[Type, Type]] = set()
    self.unsafe_downcasts: Set[Tuple[Type, Type]] = set()

            self._initialize_built_in_rules()
            self._initialize_numeric_casts()
            self._initialize_string_casts()
            self._initialize_collection_casts()
            self._initialize_hierarchy()

    #     def _initialize_built_in_rules(self):
    #         """Initialize built-in casting rules"""
    #         # Identity cast
    identity_rule = TypeCastRule(
    from_type = object,
    to_type = object,
    direction = CastDirection.UPCAST,
    cost = 0.0,
    is_safe = True
    #         )
            self.add_cast_rule(identity_rule)

    #         # Void to any (for functions returning None)
    void_rule = TypeCastRule(
    from_type = type(None),
    to_type = object,
    direction = CastDirection.UPCAST,
    cost = 0.5,
    is_safe = True
    #         )
            self.add_cast_rule(void_rule)

    #     def _initialize_numeric_casts(self):
    #         """Initialize numeric type casting rules"""
    #         # Safe numeric upcasts
    numeric_upcasts = [
                (int, float),
                (int, complex),
                (float, complex),
    #             # Add more as needed
    #         ]

    #         for from_type, to_type in numeric_upcasts:
    rule = TypeCastRule(
    from_type = from_type,
    to_type = to_type,
    direction = CastDirection.UPCAST,
    cost = 1.0,
    is_safe = True,
    converter = lambda x: to_type(x)
    #             )
                self.add_cast_rule(rule)
                self.safe_upcasts.add((from_type, to_type))

    #         # Potentially unsafe numeric downcasts
    numeric_downcasts = [
                (float, int),
                (complex, float),
                (complex, int),
    #         ]

    #         for from_type, to_type in numeric_downcasts:
    rule = TypeCastRule(
    from_type = from_type,
    to_type = to_type,
    direction = CastDirection.DOWNCAST,
    cost = 2.0,
    is_safe = False,
    converter = lambda x: to_type(x)
    #             )
    #             # Add preconditions for safe downcasts
                rule.add_precondition(lambda x: not (isinstance(x, float) and x.is_integer())
    #                                if to_type == int else True)
                self.add_cast_rule(rule)
                self.unsafe_downcasts.add((from_type, to_type))

    #         # Numeric coercions
    numeric_coercions = [
                (bool, int),  # True -1, False -> 0
                (int, bool),  # 0 -> False, non-zero -> True
                (float, bool),  # 0.0 -> False, non-zero -> True
    #         ]

    #         for from_type, to_type in numeric_coercions):
    rule = TypeCastRule(
    from_type = from_type,
    to_type = to_type,
    direction = CastDirection.COERCION,
    cost = 1.5,
    is_safe = True,
    converter = self._get_numeric_coercion(from_type, to_type)
    #             )
                self.add_cast_rule(rule)

    #     def _initialize_string_casts(self):
    #         """Initialize string type casting rules"""
    #         # String to numeric
    string_to_numeric = [
                (str, int),
                (str, float),
                (str, complex),
    #         ]

    #         for from_type, to_type in string_to_numeric:
    rule = TypeCastRule(
    from_type = from_type,
    to_type = to_type,
    direction = CastDirection.EXPLICIT,
    cost = 2.0,
    is_safe = False,  # Could raise ValueError
    converter = self._get_string_to_numeric_converter(to_type)
    #             )
                self.add_cast_rule(rule)

    #         # Numeric to string
    numeric_to_string = [
                (int, str),
                (float, str),
                (complex, str),
                (bool, str),
    #         ]

    #         for from_type, to_type in numeric_to_string:
    rule = TypeCastRule(
    from_type = from_type,
    to_type = to_type,
    direction = CastDirection.UPCAST,
    cost = 1.0,
    is_safe = True,
    converter = str
    #             )
                self.add_cast_rule(rule)

    #         # Boolean conversions
    bool_conversions = [
                (str, bool),
                (int, bool),
                (float, bool),
    #         ]

    #         for from_type, to_type in bool_conversions:
    rule = TypeCastRule(
    from_type = from_type,
    to_type = to_type,
    direction = CastDirection.COERCION,
    cost = 1.5,
    is_safe = True,
    converter = self._get_to_bool_converter(from_type)
    #             )
                self.add_cast_rule(rule)

    #     def _initialize_collection_casts(self):
    #         """Initialize collection type casting rules"""
    #         # List covariance (if element types are compatible)
    list_rule = TypeCastRule(
    from_type = GenericType,
    to_type = GenericType,
    direction = CastDirection.UPCAST,
    cost = 1.5,
    is_safe = True,
    converter = self._get_list_converter()
    #         )
            list_rule.add_precondition(self._is_list_covariant)
            self.add_cast_rule(list_rule)

    #         # Dictionary covariance
    dict_rule = TypeCastRule(
    from_type = GenericType,
    to_type = GenericType,
    direction = CastDirection.UPCAST,
    cost = 2.0,
    is_safe = True,
    converter = self._get_dict_converter()
    #         )
            dict_rule.add_precondition(self._is_dict_covariant)
            self.add_cast_rule(dict_rule)

    #     def _initialize_hierarchy(self):
    #         """Initialize type hierarchy for upcast/downcast determination"""
    #         # Basic object hierarchy
    self.type_hierarchy[object] = set()

    #         # Numeric hierarchy
    self.type_hierarchy[int] = {object}
    self.type_hierarchy[float] = {object, int}
    self.type_hierarchy[complex] = {object, int, float}

    #         # Boolean hierarchy
    self.type_hierarchy[bool] = {object, int}

    #         # String hierarchy
    self.type_hierarchy[str] = {object}

    #         # Collection hierarchy
    self.type_hierarchy[list] = {object}
    self.type_hierarchy[dict] = {object}

    #     def add_cast_rule(self, rule: TypeCastRule):
    #         """Add a casting rule"""
    key = (rule.from_type, rule.to_type)
    #         if key not in self.cast_rules:
    self.cast_rules[key] = []
            self.cast_rules[key].append(rule)

    #     def find_best_cast(self, value: Any, target_type: Type,
    context: Optional[Dict[str, Any]] = None) - CastResult):
    #         """Find the best cast for a value to a target type"""
    context = context or {}

    #         # Find all possible cast rules
    possible_rules = []
    #         for rule in self.cast_rules.get((type(value), target_type), []):
    #             if rule.can_cast(value):
                    possible_rules.append(rule)

    #         if not possible_rules:
                return CastResult(
    success = False,
    error_message = f"No cast rule found from {type(value)} to {target_type}"
    #             )

            # Sort rules by cost (lower is better)
    possible_rules.sort(key = lambda r: r.cost)

    #         # Try the best rule
    best_rule = possible_rules[0]
    result = best_rule.cast(value)

    #         # Add warnings for unsafe casts
    #         if not best_rule.is_safe:
                result.warnings.append(f"Unsafe cast from {best_rule.from_type} to {best_rule.to_type}")

    #         return result

    #     def can_implicitly_cast(self, value: Any, target_type: Type) -bool):
    #         """Check if a value can be implicitly cast to a target type"""
    #         # Check for safe upcasts
    #         if (type(value), target_type) in self.safe_upcasts:
    #             return True

    #         # Check for coercions
    #         if (type(value), target_type) in self.coercion_rules:
    #             return True

    #         # Check for explicit rules that are safe
    #         for rule in self.cast_rules.get((type(value), target_type), []):
    #             if rule.is_safe and rule.can_cast(value):
    #                 return True

    #         return False

    #     def is_subtype(self, subtype: Type, supertype: Type) -bool):
    #         """Check if one type is a subtype of another"""
    #         # Direct subtype check
    #         if subtype == supertype:
    #             return True

    #         # Check type hierarchy
    #         if subtype in self.type_hierarchy:
    #             return supertype in self.type_hierarchy[subtype]

    #         # Handle generic types
    #         if isinstance(subtype, GenericType) and isinstance(supertype, GenericType):
    #             if subtype.type_constructor == supertype.type_constructor:
                    return all(self.is_subtype(sub_arg, super_arg)
    #                          for sub_arg, super_arg in zip(subtype.type_arguments, supertype.type_arguments))

    #         return False

    #     def _get_numeric_coercion(self, from_type: Type, to_type: Type) -Callable):
    #         """Get numeric coercion function"""
    #         if from_type == bool and to_type == int:
    #             return lambda x: 1 if x else 0
    #         elif from_type == bool and to_type == float:
    #             return lambda x: 1.0 if x else 0.0
    #         elif from_type == bool and to_type == complex:
    #             return lambda x: complex(1, 0) if x else complex(0, 0)
    #         elif from_type == int and to_type == bool:
                return lambda x: bool(x)
    #         elif from_type == float and to_type == bool:
                return lambda x: bool(x)
    #         else:
                return lambda x: to_type(x)

    #     def _get_string_to_numeric_converter(self, to_type: Type) -Callable):
    #         """Get string to numeric converter"""
    #         def converter(value: str) -Any):
    #             try:
    #                 if to_type == int:
                        return int(value)
    #                 elif to_type == float:
                        return float(value)
    #                 elif to_type == complex:
                        return complex(value)
    #                 else:
                        return to_type(value)
    #             except ValueError as e:
                    raise TypeError(f"Cannot convert string '{value}' to {to_type.__name__}")

    #         return converter

    #     def _get_to_bool_converter(self, from_type: Type) -Callable):
    #         """Get to boolean converter"""
    #         if from_type == str:
                return lambda x: bool(x.strip())
    #         else:
    #             return bool

    #     def _get_list_converter(self) -Callable):
    #         """Get list converter for covariance"""
    #         def converter(value: GenericType) -GenericType):
    #             # This is a simplified converter
    #             # In practice, you'd need to handle element type conversion
    #             return value
    #         return converter

    #     def _get_dict_converter(self) -Callable):
    #         """Get dict converter for covariance"""
    #         def converter(value: GenericType) -GenericType):
    #             # This is a simplified converter
    #             # In practice, you'd need to handle key/value type conversion
    #             return value
    #         return converter

    #     def _is_list_covariant(self, value: Any) -bool):
    #         """Check if list conversion is covariant"""
    #         # Simplified check
    return isinstance(value, GenericType) and value.type_constructor.name = = "List"

    #     def _is_dict_covariant(self, value: Any) -bool):
    #         """Check if dict conversion is covariant"""
    #         # Simplified check
    return isinstance(value, GenericType) and value.type_constructor.name = = "Dict"


class TypeCaster
    #     """High-level type caster with context awareness"""

    #     def __init__(self, casting_engine: TypeCastingEngine):
    self.casting_engine = casting_engine
    self.error_reporter = get_error_reporter()
    self.cast_log: List[Dict[str, Any]] = []

    #     def cast(self, value: Any, target_type: Type,
    context: Optional[Dict[str, Any]] = None) - CastResult):
    #         """Cast a value to a target type with logging"""
    result = self.casting_engine.find_best_cast(value, target_type, context)

    #         # Log the cast
    log_entry = {
                'value': str(value),
                'from_type': str(type(value)),
                'to_type': str(target_type),
    #             'success': result.success,
    #             'direction': result.cast_direction.value if result.cast_direction else None,
    #             'cost': result.conversion_cost,
    #             'warnings': result.warnings,
    #             'error': result.error_message,
    #             'context': context
    #         }

            self.cast_log.append(log_entry)

    #         # Report errors
    #         if not result.success:
                self.error_reporter.report_error(
    message = f"Type cast failed: {result.error_message}",
    context = log_entry,
    error_code = "TYPE_CAST_FAILED"
    #             )

    #         return result

    #     def safe_cast(self, value: Any, target_type: Type,
    context: Optional[Dict[str, Any]] = None) - Any):
    #         """Perform a safe cast, raising an exception if it fails"""
    result = self.cast(value, target_type, context)

    #         if not result.success:
                raise TypeError(f"Cannot cast {value} from {type(value)} to {target_type}: {result.error_message}")

    #         return result.cast_value

    #     def implicit_cast(self, value: Any, target_type: Type,
    context: Optional[Dict[str, Any]] = None) - Optional[Any]):
    #         """Attempt implicit cast, returning None if not possible"""
    #         if self.casting_engine.can_implicitly_cast(value, target_type):
    result = self.cast(value, target_type, context)
    #             if result.success:
    #                 return result.cast_value
    #         return None

    #     def get_cast_log(self) -List[Dict[str, Any]]):
    #         """Get the cast log"""
    #         return self.cast_log

    #     def clear_log(self):
    #         """Clear the cast log"""
            self.cast_log.clear()


# Global instances
casting_engine = TypeCastingEngine()
type_caster = TypeCaster(casting_engine)


def get_casting_engine() -TypeCastingEngine):
#     """Get the global casting engine"""
#     return casting_engine


def get_type_caster() -TypeCaster):
#     """Get the global type caster"""
#     return type_caster


def safe_cast(value: Any, target_type: Type,
context: Optional[Dict[str, Any]] = None) - Any):
#     """Safely cast a value to a target type"""
    return type_caster.safe_cast(value, target_type, context)


def implicit_cast(value: Any, target_type: Type,
context: Optional[Dict[str, Any]] = None) - Optional[Any]):
#     """Attempt implicit cast of a value to a target type"""
    return type_caster.implicit_cast(value, target_type, context)


def can_implicitly_cast(value: Any, target_type: Type) -bool):
#     """Check if a value can be implicitly cast to a target type"""
    return casting_engine.can_implicitly_cast(value, target_type)


# Custom cast rule creation
def create_numeric_cast_rule(from_type: Type, to_type: Type,
is_safe: bool = True - cost: float = 1.0, TypeCastRule):)
#     """Create a numeric casting rule"""
    return TypeCastRule(
from_type = from_type,
to_type = to_type,
#         direction=CastDirection.UPCAST if is_safe else CastDirection.DOWNCAST,
cost = cost,
is_safe = is_safe,
converter = lambda x: to_type(x)
#     )


def create_string_cast_rule(from_type: Type, to_type: Type,
is_safe: bool = True - cost: float = 2.0, TypeCastRule):)
#     """Create a string casting rule"""
#     if to_type in (int, float, complex):
converter = casting_engine._get_string_to_numeric_converter(to_type)
#     else:
converter = str

    return TypeCastRule(
from_type = from_type,
to_type = to_type,
direction = CastDirection.EXPLICIT,
cost = cost,
is_safe = is_safe,
converter = converter
#     )


def create_coercion_rule(from_type: Type, to_type: Type,
converter: Optional[Callable] = None,
cost: float = 1.5) - TypeCastRule):
#     """Create a type coercion rule"""
    return TypeCastRule(
from_type = from_type,
to_type = to_type,
direction = CastDirection.COERCION,
cost = cost,
is_safe = True,
converter = converter
#     )


# Example usage and tests
function test_type_casting()
    #     """Test type casting functionality"""
    caster = get_type_caster()

    #     # Test numeric casts
    int_val = 42
    float_result = caster.cast(int_val, float)
        print(f"Int to float: {float_result.success}, value: {float_result.cast_value}")

    #     # Test string casts
    str_val = "123"
    int_result = caster.cast(str_val, int)
        print(f"String to int: {int_result.success}, value: {int_result.cast_value}")

    #     # Test coercion
    bool_val = True
    int_result = caster.cast(bool_val, int)
        print(f"Bool to int: {int_result.success}, value: {int_result.cast_value}")

    #     # Test implicit cast
    can_cast = can_implicitly_cast(42, float)
        print(f"Can implicitly cast int to float: {can_cast}")

    #     # Test safe cast
    #     try:
    safe_result = safe_cast(42, float)
            print(f"Safe cast result: {safe_result}")
    #     except Exception as e:
            print(f"Safe cast failed: {e}")


# Register additional cast rules
function register_common_casts()
    #     """Register common casting rules"""
    engine = get_casting_engine()

    #     # Add more numeric conversions
        engine.add_cast_rule(create_numeric_cast_rule(int, complex))
        engine.add_cast_rule(create_numeric_cast_rule(float, complex))

    #     # Add string conversions
        engine.add_cast_rule(create_string_cast_rule(str, bool))

    #     # Add coercions
        engine.add_cast_rule(create_coercion_rule(int, bool, lambda x: bool(x)))
        engine.add_cast_rule(create_coercion_rule(float, bool, lambda x: bool(x)))


# Initialize common casts
register_common_casts()


if __name__ == "__main__"
        test_type_casting()
