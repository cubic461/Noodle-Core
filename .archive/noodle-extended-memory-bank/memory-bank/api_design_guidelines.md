# Noodle API Design Guidelines and Naming Conventions

## Overview

This document defines the API design guidelines and naming conventions for the Noodle project. These guidelines ensure consistency, maintainability, and usability across all modules and components.

## Status
- **Status**: IN PROGRESS
- **Version**: 1.0
- **Last Updated**: 2025-09-23
- **Owner**: API Audit Team (Week 1, Stap 5)

## 1. Naming Conventions

### 1.1 General Principles
- **Clarity over brevity**: Use descriptive names that clearly express the purpose
- **Consistency**: Follow established patterns throughout the codebase
- **Readability**: Prioritize human readability over cleverness

### 1.2 Class Names
- **Format**: PascalCase (Capitalize first letter of each word)
- **Pattern**: `[Purpose][Component]` or `[Component]`
- **Examples**:
  - `NBCRuntime` (✓) - Good: Clear purpose and component
  - `MathematicalObjectMapper` (✓) - Good: Descriptive and follows pattern
  - `DatabaseModule` (✓) - Good: Clear component identification
  - `ErrorHandler` (✓) - Good: Clear purpose

### 1.3 Method Names
- **Format**: snake_case (lowercase with underscores)
- **Pattern**: `[action][object]` or `[verb][noun]`
- **Public Methods**:
  - `load_program()` (✓) - Good: Clear action + object
  - `execute_instruction()` (✓) - Good: Action + object
  - `connect_database()` (✓) - Good: Action + object
  - `query_mathematical_objects()` (✓) - Good: Action + object
- **Private Methods**:
  - `_validate_program()` (✓) - Good: Private with descriptive name
  - `_setup_logging()` (✓) - Good: Private setup action
  - `_generate_encryption_key()` (✓) - Good: Private generation action

### 1.4 Variable Names
- **Format**: snake_case (lowercase with underscores)
- **Local Variables**: Descriptive and specific to context
- **Instance Variables**: `self._variable_name` (private) or `self.variable_name` (protected)
- **Class Variables**: `CLASS_CONSTANT_NAME` (UPPER_SNAKE_CASE)
- **Examples**:
  - `current_program` (✓) - Good: Descriptive local variable
  - `max_stack_depth` (✓) - Good: Configuration variable
  - `_cache` (✓) - Good: Private instance variable
  - `INSTRUCTION_AVAILABLE` (✓) - Good: Class constant

### 1.5 Enum Names
- **Format**: PascalCase with descriptive names
- **Pattern**: `[State]` or `[Type]` or `[Status]`
- **Examples**:
  - `RuntimeState` (✓) - Good: Clear state enumeration
  - `DatabaseStatus` (✓) - Good: Clear status enumeration
  - `ObjectType` (✓) - Good: Clear type enumeration

### 1.6 Exception Names
- **Format**: PascalCase ending with "Error"
- **Pattern**: `[Context]Error` or `[Operation]Error`
- **Examples**:
  - `NBCRuntimeError` (✓) - Good: Context-specific error
  - `SerializationError` (✓) - Good: Operation-specific error
  - `InvalidMathematicalObjectError` (✓) - Good: Specific validation error

## 2. API Design Principles

### 2.1 Consistency
- **Follow established patterns**: Use existing naming and structure conventions
- **Module consistency**: Similar functionality should have similar interfaces
- **Parameter ordering**: Consistent parameter order across similar methods

### 2.2 Clarity
- **Descriptive names**: Use names that clearly express purpose and behavior
- **Explicit behavior**: Methods should do exactly what their names suggest
- **Clear documentation**: Comprehensive docstrings for all public APIs

### 2.3 Maintainability
- **Single responsibility**: Each method/class should have one clear purpose
- **Loose coupling**: Minimize dependencies between components
- **Extensibility**: Design for future extensions and modifications

### 2.4 Usability
- **Intuitive interfaces**: APIs should be easy to understand and use
- **Reasonable defaults**: Provide sensible default values where appropriate
- **Error handling**: Clear and informative error messages

## 3. Type Hints Standards

### 3.1 General Requirements
- **Complete coverage**: All public APIs must have complete type hints
- **Python 3.8+ compatibility**: Use modern typing features
- **Union types**: Use `Union[X, Y]` or `X | Y` (Python 3.10+)

### 3.2 Common Type Patterns
```python
# Method with return type
def execute_program(self, program: Optional[List[Instruction]] = None) -> Dict[str, Any]:
    pass

# Method with multiple parameter types
def query_mathematical_objects(self,
                              object_type: str,
                              operation: str,
                              filters: Optional[Dict[str, Any]] = None) -> List[MathematicalObject]:
    pass

# Async method
async def execute_instruction_async(self, instruction: Instruction) -> Any:
    pass

# Generic types
def register_mapping(self, mapping: TypeMapping) -> None:
    pass
```

### 3.3 Collection Types
- **Lists**: `List[Type]` or `type[]` (Python 3.9+)
- **Dictionaries**: `Dict[str, Type]` or `dict[str, Type]` (Python 3.9+)
- **Optional**: `Optional[Type]` or `Type | None` (Python 3.10+)

## 4. Documentation Standards

### 4.1 Docstring Format
- **Format**: Google-style docstrings
- **Required sections**: Description, Args, Returns, Raises
- **Optional sections**: Examples, Note, Warning

### 4.2 Docstring Template
```python
def method_name(self, param1: Type, param2: Optional[Type] = None) -> ReturnType:
    """
    Brief description of the method.

    Detailed description if needed. This can span multiple lines and provide
    comprehensive information about the method's behavior, usage, and any
    important considerations.

    Args:
        param1: Description of the first parameter.
        param2: Description of the second parameter. Optional, defaults to None.

    Returns:
        Description of the return value.

    Raises:
        ValueError: Description of when this exception is raised.
        TypeError: Description of when this exception is raised.

    Examples:
        >>> example_usage()
        expected_result

    Note:
        Any additional notes or important information.

    Warning:
        Any warnings about usage or potential issues.
    """
    pass
```

### 4.3 Module-Level Documentation
- **Purpose**: Clear description of module functionality
- **Dependencies**: List of key imports and their purposes
- **Usage**: Basic usage examples if applicable

## 5. Error Handling Patterns

### 5.1 Exception Hierarchy
```
Exception
├── NBCRuntimeError
│   ├── SerializationError
│   ├── DeserializationError
│   └── PythonFFIError
├── DatabaseError
│   ├── ConnectionError
│   ├── QueryError
│   └── TransactionError
└── ValidationError
    ├── InvalidMathematicalObjectError
    ├── SchemaValidationError
    └── ConfigurationError
```

### 5.2 Error Handling Best Practices
- **Specific exceptions**: Use specific exception types rather than generic ones
- **Descriptive messages**: Include context and actionable information in error messages
- **Consistent error codes**: Use standardized error codes for different error types
- **Logging**: Log errors with appropriate severity levels

### 5.3 Error Handling Example
```python
class NBCRuntimeError(Exception):
    """Base exception for NBC runtime errors."""

    def __init__(self, message: str, error_code: str = None, details: Dict[str, Any] = None):
        """
        Initialize NBC runtime error.

        Args:
            message: Human-readable error message
            error_code: Standardized error code for programmatic handling
            details: Additional context information about the error
        """
        super().__init__(message)
        self.message = message
        self.error_code = error_code
        self.details = details or {}

    def __str__(self):
        """String representation including error code if available."""
        if self.error_code:
            return f"[{self.error_code}] {self.message}"
        return self.message
```

## 6. Configuration and Settings

### 6.1 Configuration Objects
- **Dataclasses**: Use `@dataclass` for configuration objects
- **Type hints**: Complete type hints for all configuration fields
- **Default values**: Provide sensible defaults for all optional fields
- **Validation**: Include validation methods for configuration values

### 6.2 Configuration Example
```python
@dataclass
class RuntimeConfig:
    """Runtime configuration for NBC execution."""

    max_stack_depth: int = 1000
    max_execution_time: float = 3600.0  # 1 hour
    max_memory_usage: int = 1024 * 1024 * 1024  # 1GB
    enable_optimization: bool = True
    optimization_level: int = 2
    enable_profiling: bool = False
    enable_tracing: bool = False
    log_level: str = "INFO"
    database_config: Optional['DatabaseConfig'] = None
    matrix_backend: str = "numpy"

    def to_dict(self) -> Dict[str, Any]:
        """Convert configuration to dictionary for serialization."""
        return {
            'max_stack_depth': self.max_stack_depth,
            'max_execution_time': self.max_execution_time,
            'max_memory_usage': self.max_memory_usage,
            'enable_optimization': self.enable_optimization,
            'optimization_level': self.optimization_level,
            'enable_profiling': self.enable_profiling,
            'enable_tracing': self.enable_tracing,
            'log_level': self.log_level,
            'database_config': self.database_config.to_dict() if self.database_config else None,
            'matrix_backend': self.matrix_backend
        }
```

## 7. Interface Design Patterns

### 7.1 Manager Pattern
- **Purpose**: Centralized management of resources or operations
- **Structure**: Clear initialization, configuration, and execution methods
- **Example**: `NBCRuntime`, `DatabaseModule`, `ResourceManager`

### 7.2 Mapper Pattern
- **Purpose**: Conversion between different data representations
- **Structure**: Conversion methods with clear input/output types
- **Example**: `MathematicalObjectMapper`, `DataTypeMapper`

### 7.3 Strategy Pattern
- **Purpose**: Pluggable algorithms or behaviors
- **Structure**: Interface definition with multiple implementations
- **Example**: Different matrix operation backends

### 7.4 Factory Pattern
- **Purpose**: Object creation with encapsulated instantiation logic
- **Structure**: Factory methods that return appropriate object types
- **Example**: `create_mathematical_object()`, `create_mathematical_object_mapper()`

## 8. Performance Considerations

### 8.1 Method Design
- **Avoid unnecessary copying**: Use references where appropriate
- **Lazy initialization**: Initialize heavy objects on demand
- **Caching**: Implement caching for expensive operations
- **Batch operations**: Provide batch methods for bulk operations

### 8.2 Memory Management
- **Resource cleanup**: Implement proper cleanup methods
- **Context managers**: Use `@contextmanager` for resource management
- **Weak references**: Use `weakref` for circular reference prevention

### 8.3 Concurrency
- **Thread safety**: Use appropriate locking mechanisms
- **Async support**: Provide async alternatives for blocking operations
- **Immutable data**: Prefer immutable data structures for shared access

## 9. Testing Integration

### 9.1 Testable Design
- **Dependency injection**: Allow injection of dependencies for testing
- **Interface segregation**: Define clear interfaces for mocking
- **Pure functions**: Isolate pure business logic from side effects

### 9.2 Mock-Friendly Design
- **Abstract base classes**: Use ABC for defining interfaces
- **Configuration over convention**: Make behavior configurable for testing
- **Clear boundaries**: Define clear boundaries between components

## 10. Security Considerations

### 10.1 Input Validation
- **Type checking**: Validate input types before processing
- **Value validation**: Validate input values for security and correctness
- **Sanitization**: Sanitize inputs to prevent injection attacks

### 10.2 Error Information
- **No sensitive data**: Avoid exposing sensitive information in error messages
- **Generic errors**: Use generic error messages for external-facing APIs
- **Detailed logging**: Log detailed errors internally for debugging

## 11. Versioning and Deprecation

### 11.1 Version Compatibility
- **Semantic versioning**: Follow SemVer principles (MAJOR.MINOR.PATCH)
- **Backward compatibility**: Maintain backward compatibility within minor versions
- **Deprecation cycle**: Provide clear deprecation warnings before removal

### 11.2 Deprecation Handling
- **Warning decorators**: Use `@deprecated` decorator for deprecated methods
- **Documentation**: Mark deprecated methods in documentation
- **Migration path**: Provide migration guidance for deprecated APIs

## 12. Code Organization

### 12.1 Module Structure
- **Single responsibility**: Each module should have one clear purpose
- **Clear boundaries**: Define clear interfaces between modules
- **Dependency direction**: Dependencies should flow in one direction

### 12.2 Import Organization
- **Standard library first**: Import standard library modules first
- **Third-party next**: Import third-party modules second
- **Local imports last**: Import local modules last
- **Absolute imports**: Use absolute imports where possible

## 13. Validation Metrics

### 13.1 Consistency Score
- **Target**: >90% consistency in naming and patterns
- **Measurement**: Automated analysis of codebase against guidelines
- **Tools**: Static analysis tools and custom validators

### 13.2 Type Coverage
- **Target**: 100% type hint coverage for public APIs
- **Measurement**: Automated type checking with mypy
- **Enforcement**: CI/CD pipeline checks for type coverage

### 13.3 Documentation Quality
- **Target**: Complete docstrings for all public APIs
- **Measurement**: Automated documentation coverage analysis
- **Standards**: Google-style docstrings with required sections

## 14. Implementation Checklist

### 14.1 For New APIs
- [ ] Follow naming conventions (PascalCase for classes, snake_case for methods)
- [ ] Include complete type hints
- [ ] Write comprehensive docstrings
- [ ] Implement proper error handling
- [ ] Add appropriate validation
- [ ] Consider performance implications
- [ ] Design for testability
- [ ] Include security considerations

### 14.2 For Existing APIs
- [ ] Review against current guidelines
- [ ] Add missing type hints
- [ ] Improve documentation where needed
- [ ] Refactor to improve consistency
- [ ] Add deprecation warnings for non-compliant APIs

### 14.3 For API Reviews
- [ ] Check naming convention compliance
- [ ] Verify type hint completeness
- [ ] Review documentation quality
- [ ] Assess error handling adequacy
- [ ] Evaluate performance considerations
- [ ] Consider security implications
- [ ] Verify testability

## 15. References and Resources

### 15.1 Python Standards
- [PEP 8 - Style Guide for Python Code](https://peps.python.org/pep-0008/)
- [PEP 484 - Type Hints](https://peps.python.org/pep-0484/)
- [PEP 257 - Docstring Conventions](https://peps.python.org/pep-0257/)

### 15.2 Design Resources
- [Python Design Patterns](https://refactoring.guru/python-design-patterns)
- [Clean Code Python](https://github.com/coding-horror/clean-code-python)
- [Python API Design](https://github.com/django/django/blob/main/docs/internals/howto/api-design.txt)

### 15.3 Tools
- **mypy**: Static type checking
- **flake8**: Code style checking
- **black**: Code formatting
- **sphinx**: Documentation generation
- **pydoc-markdown**: Documentation validation

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-09-23 | API Audit Team | Initial version based on codebase analysis |
