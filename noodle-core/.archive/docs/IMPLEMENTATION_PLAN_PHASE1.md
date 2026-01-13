# Noodle Language Implementation Plan

## Phase 1: Foundation Stabilization - Detailed Implementation Plan

This document provides detailed implementation plans for the critical Phase 1 features that will stabilize the Noodle language foundation.

## 1. Parser Integration Fix Plan

### 1.1 Pattern Matching Parser Integration

**Current Issue**: Pattern matching AST nodes exist but parser doesn't properly handle them.

**Implementation Steps**:

1. **Token Recognition Enhancement**

```python
# In lexer.py - Add pattern matching tokens
PATTERN_TOKENS = {
    'UNDERSCORE': '_',      # Wildcard pattern
    'PIPE': '|',            # Or pattern
    'AMPERSAND': '&',       # And pattern
    'DOUBLE_DOT': '..',     # Range pattern
    'COLON_COLON': '::',    # Type annotation in patterns
}
```

2. **Grammar Rule Completion**

```python
# In enhanced_parser.py - Complete pattern parsing
def _parse_pattern(self) -> Pattern:
    """Complete pattern parsing implementation"""
    if self._match(TokenType.UNDERSCORE):
        return self._parse_wildcard_pattern()
    elif self._match(TokenType.STRING, TokenType.NUMBER):
        return self._parse_literal_pattern()
    elif self._match(TokenType.IDENTIFIER):
        return self._parse_identifier_pattern()
    elif self._match(TokenType.LPAREN):
        return self._parse_tuple_pattern()
    elif self._match(TokenType.LBRACKET):
        return self._parse_array_pattern()
    elif self._match(TokenType.LBRACE):
        return self._parse_object_pattern()
    else:
        raise ParseError("Expected pattern", self._current_token().location)
```

3. **Match Expression Integration**

```python
# Complete match expression parsing
def _parse_match_expression(self) -> MatchExpressionNode:
    """Parse match expression with full pattern support"""
    match_token = self._advance()  # 'match'
    
    expression = self._parse_expression()
    
    self._expect(TokenType.LBRACE, "Expected '{' after match expression")
    
    cases = []
    while not self._match(TokenType.RBRACE) and not self._match(TokenType.EOF):
        case = self._parse_match_case()
        cases.append(case)
    
    self._expect(TokenType.RBRACE, "Expected '}' to end match expression")
    
    return self.factory.create_match_expression_node(expression, cases, match_token.location)
```

**Testing Strategy**:

```python
# Test cases to implement
test_cases = [
    # Basic patterns
    "match x { _ => 'default' }",
    "match x { 42 => 'number' }",
    "match x { name => name }",
    
    # Complex patterns
    "match x { (a, b) => a + b }",
    "match x { [head, ...tail] => head }",
    "match x { {name, age} => name }",
    
    # Advanced patterns
    "match x { a | b => a }",
    "match x { a & b => a }",
    "match x { a..b => a }",
]
```

### 1.2 Generics Parser Integration

**Current Issue**: Generics AST nodes exist but parser doesn't handle generic syntax.

**Implementation Steps**:

1. **Generic Parameter Parsing**

```python
def _parse_generic_parameters(self) -> List[GenericParameterNode]:
    """Parse generic type parameters with constraints"""
    self._advance()  # '<'
    
    parameters = []
    while not self._match(TokenType.GT) and not self._match(TokenType.EOF):
        param = self._parse_generic_parameter()
        parameters.append(param)
        
        if self._match(TokenType.COMMA):
            self._advance()  # ','
        else:
            break
    
    self._expect(TokenType.GT, "Expected '>' after generic parameters")
    return parameters

def _parse_generic_parameter(self) -> GenericParameterNode:
    """Parse single generic parameter with constraints"""
    name_token = self._expect(TokenType.IDENTIFIER, "Expected generic parameter name")
    name = name_token.value
    
    # Parse constraints
    constraint = None
    if self._match(TokenType.COLON):
        self._advance()  # ':'
        constraint = self._parse_type_constraint()
    
    # Parse default type
    default_type = None
    if self._match(TokenType.EQ):
        self._advance()  # '='
        default_type = self._parse_type_annotation()
    
    return self.factory.create_generic_parameter_node(name, constraint, default_type, name_token.location)
```

2. **Generic Type Parsing**

```python
def _parse_generic_type(self, base_type: str) -> GenericTypeAnnotationNode:
    """Parse generic type with type arguments"""
    self._advance()  # '<'
    
    type_arguments = []
    while not self._match(TokenType.GT) and not self._match(TokenType.EOF):
        type_arg = self._parse_type_annotation()
        type_arguments.append(type_arg)
        
        if self._match(TokenType.COMMA):
            self._advance()  # ','
        else:
            break
    
    self._expect(TokenType.GT, "Expected '>' after type arguments")
    
    return self.factory.create_generic_type_annotation(base_type, type_arguments, self._current_token().location)
```

**Testing Strategy**:

```python
# Test cases
test_cases = [
    # Generic functions
    "def identity<T>(x: T): T",
    "def compare<T: Comparable>(a: T, b: T): bool",
    "def with_default<T = String>(x: T): T",
    
    # Generic classes
    "class Container<T> { value: T }",
    "class Pair<T, U> { first: T, second: U }",
    
    # Generic types
    "List<String>",
    "Map<String, Int>",
    "Optional<T>",
]
```

### 1.3 Async/Await Parser Integration

**Current Issue**: Async/await syntax not fully supported in parser.

**Implementation Steps**:

1. **Async Function Parsing**

```python
def _parse_async_function_definition(self) -> AsyncFunctionDefinitionNode:
    """Parse async function definition"""
    async_token = self._advance()  # 'async'
    
    # Check for generator
    is_generator = False
    if self._match(TokenType.ASYNC):
        self._advance()  # Second 'async' for generators
        is_generator = True
    
    self._expect(TokenType.DEF, "Expected 'def' after 'async'")
    
    # Parse function definition
    func_def = self._parse_function_definition()
    
    # Convert to async function
    return self.factory.create_async_function_definition_node(
        func_def.name,
        func_def.parameters,
        func_def.return_type,
        func_def.body,
        is_generator,
        async_token.location
    )
```

2. **Await Expression Parsing**

```python
def _parse_await_expression(self) -> AwaitExpressionNode:
    """Parse await expression"""
    await_token = self._advance()  # 'await'
    
    expression = self._parse_expression()
    
    return self.factory.create_await_expression_node(expression, await_token.location)
```

**Testing Strategy**:

```python
# Test cases
test_cases = [
    # Async functions
    "async def fetch_data(): await http.get(url)",
    "async def process_stream(): async for item in stream: yield item",
    
    # Await expressions
    "result = await fetch_data()",
    "data = await process_async(value)",
    
    # Async generators
    "async def async_generator(): yield await get_value()",
]
```

## 2. Compiler Pipeline Fix Plan

### 2.1 AST Node Factory Refactoring

**Current Issue**: Inconsistent AST node creation and validation.

**Implementation Steps**:

1. **Enhanced Factory with Validation**

```python
class EnhancedASTNodeFactory:
    """Enhanced factory with validation and caching"""
    
    def __init__(self):
        self.node_cache = {}
        self.validation_rules = self._load_validation_rules()
    
    def create_program(self, statements: List[ASTNode], location: SourceLocation) -> EnhancedProgramNode:
        """Create program node with validation"""
        # Validate statements
        for stmt in statements:
            self._validate_statement(stmt)
        
        # Create node
        node = EnhancedProgramNode(statements, location)
        
        # Cache node
        self._cache_node(node)
        
        return node
    
    def _validate_statement(self, stmt: ASTNode):
        """Validate statement structure"""
        if stmt.type not in [NodeType.LET_STATEMENT, NodeType.FUNCTION_DEFINITION, 
                           NodeType.IF_STATEMENT, NodeType.FOR_STATEMENT,
                           NodeType.WHILE_STATEMENT, NodeType.RETURN_STATEMENT,
                           NodeType.IMPORT_STATEMENT, NodeType.CLASS_DEFINITION,
                           NodeType.EXPRESSION_STATEMENT, NodeType.MATCH_EXPRESSION]:
            raise ValueError(f"Invalid statement type: {stmt.type}")
    
    def _cache_node(self, node: ASTNode):
        """Cache node for reuse"""
        node_id = self._generate_node_id(node)
        self.node_cache[node_id] = node
    
    def _generate_node_id(self, node: ASTNode) -> str:
        """Generate unique ID for node caching"""
        import hashlib
        content = str(node.to_dict())
        return hashlib.md5(content.encode()).hexdigest()
```

2. **Node Validation System**

```python
class ASTValidator:
    """Comprehensive AST validation system"""
    
    def validate_program(self, program: EnhancedProgramNode) -> List[str]:
        """Validate entire program"""
        errors = []
        
        # Check for duplicate declarations
        errors.extend(self._check_duplicate_declarations(program))
        
        # Validate each statement
        for i, stmt in enumerate(program.statements):
            stmt_errors = self._validate_statement(stmt, i)
            errors.extend(stmt_errors)
        
        return errors
    
    def _check_duplicate_declarations(self, program: EnhancedProgramNode) -> List[str]:
        """Check for duplicate function/class declarations"""
        errors = []
        declarations = {}
        
        for stmt in program.statements:
            if isinstance(stmt, (EnhancedFunctionDefinitionNode, EnhancedClassDefinitionNode)):
                name = stmt.name
                if name in declarations:
                    errors.append(f"Duplicate declaration: {name}")
                else:
                    declarations[name] = stmt
        
        return errors
    
    def _validate_statement(self, stmt: ASTNode, index: int) -> List[str]:
        """Validate individual statement"""
        errors = []
        
        if isinstance(stmt, EnhancedLetStatementNode):
            errors.extend(self._validate_let_statement(stmt))
        elif isinstance(stmt, EnhancedFunctionDefinitionNode):
            errors.extend(self._validate_function_definition(stmt))
        elif isinstance(stmt, EnhancedClassDefinitionNode):
            errors.extend(self._validate_class_definition(stmt))
        
        return errors
```

### 2.2 Type Inference Integration

**Current Issue**: Type inference system not fully integrated with compiler pipeline.

**Implementation Steps**:

1. **Pipeline Integration**

```python
class TypeInferencePipeline:
    """Type inference integration in compiler pipeline"""
    
    def __init__(self, context: TypeInferenceContext):
        self.context = context
        self.engine = TypeInferenceEngine()
    
    def infer_types(self, ast: EnhancedProgramNode) -> TypeInferenceResult:
        """Infer types for entire AST"""
        start_time = time.perf_counter()
        
        # Infer types for each statement
        for stmt in ast.statements:
            self._infer_statement_types(stmt)
        
        # Resolve type variables
        self._resolve_type_variables()
        
        # Validate type consistency
        errors = self._validate_type_consistency()
        
        end_time = time.perf_counter()
        
        return TypeInferenceResult(
            context=self.context,
            errors=errors,
            time_taken=end_time - start_time
        )
    
    def _infer_statement_types(self, stmt: ASTNode):
        """Infer types for statement"""
        if isinstance(stmt, EnhancedLetStatementNode):
            self._infer_let_statement_types(stmt)
        elif isinstance(stmt, EnhancedFunctionDefinitionNode):
            self._infer_function_types(stmt)
        elif isinstance(stmt, EnhancedReturnStatementNode):
            self._infer_return_types(stmt)
    
    def _infer_let_statement_types(self, stmt: EnhancedLetStatementNode):
        """Infer types for let statement"""
        if stmt.initializer:
            inferred_type = self.engine.infer_type(stmt.initializer, self.context)
            
            # Check type annotation compatibility
            if stmt.type_annotation:
                annotated_type = self._parse_type_annotation(stmt.type_annotation)
                if not inferred_type.is_subtype_of(annotated_type):
                    raise TypeError(f"Type mismatch: expected {annotated_type}, got {inferred_type}")
            
            # Store variable type
            self.context.set_variable_type(stmt.name, inferred_type)
```

2. **Error Recovery**

```python
class TypeInferenceErrorRecovery:
    """Error recovery for type inference"""
    
    def recover_from_error(self, error: TypeError, context: TypeInferenceContext) -> Type:
        """Recover from type inference error"""
        # Try to infer a reasonable type
        if "expected" in str(error) and "got" in str(error):
            # Extract expected type from error message
            expected_type = self._extract_expected_type(str(error))
            if expected_type:
                return expected_type
        
        # Fall back to unknown type
        return UnknownType("unknown", SourceLocation("<recovered>", 1, 1, 0))
    
    def _extract_expected_type(self, error_message: str) -> Optional[Type]:
        """Extract expected type from error message"""
        # Parse error message to extract type
        # Implementation depends on error message format
        pass
```

## 3. Runtime System Stabilization

### 3.1 Memory Management Optimization

**Current Issue**: Memory management needs optimization for production use.

**Implementation Steps**:

1. **Memory Pool Implementation**

```python
class MemoryPool:
    """Memory pool for efficient allocation"""
    
    def __init__(self, initial_size: int = 1024):
        self.pool = []
        self.free_list = []
        self.lock = threading.Lock()
    
    def allocate(self, size: int) -> MemoryBlock:
        """Allocate memory block"""
        with self.lock:
            # Try to reuse freed block
            if self.free_list:
                block = self.free_list.pop()
                if block.size >= size:
                    return block
            
            # Allocate new block
            block = MemoryBlock(size)
            self.pool.append(block)
            return block
    
    def deallocate(self, block: MemoryBlock):
        """Deallocate memory block"""
        with self.lock:
            self.free_list.append(block)
    
    def get_usage_stats(self) -> Dict[str, int]:
        """Get memory usage statistics"""
        with self.lock:
            return {
                'total_blocks': len(self.pool),
                'free_blocks': len(self.free_list),
                'used_blocks': len(self.pool) - len(self.free_list)
            }
```

2. **Garbage Collection Enhancement**

```python
class GenerationalGC:
    """Generational garbage collector"""
    
    def __init__(self):
        self.young_generation = []
        self.old_generation = []
        self.tenure_threshold = 3
    
    def allocate(self, obj: Any) -> int:
        """Allocate object in young generation"""
        obj_id = id(obj)
        self.young_generation.append((obj_id, obj, 0))
        return obj_id
    
    def collect_young(self):
        """Collect young generation"""
        # Mark reachable objects
        reachable = self._mark_reachable(self.young_generation)
        
        # Move survivors to old generation or keep in young
        survivors = []
        for obj_id, obj, age in self.young_generation:
            if obj_id in reachable:
                if age >= self.tenure_threshold:
                    self.old_generation.append((obj_id, obj, 0))
                else:
                    survivors.append((obj_id, obj, age + 1))
        
        self.young_generation = survivors
    
    def collect_old(self):
        """Collect old generation"""
        reachable = self._mark_reachable(self.old_generation)
        
        survivors = []
        for obj_id, obj, age in self.old_generation:
            if obj_id in reachable:
                survivors.append((obj_id, obj, age + 1))
        
        self.old_generation = survivors
```

### 3.2 Error Handling Consistency

**Current Issue**: Error handling is inconsistent across runtime systems.

**Implementation Steps**:

1. **Unified Error System**

```python
class NoodleError(Exception):
    """Base error class for Noodle runtime"""
    
    def __init__(self, message: str, error_type: str, location: Optional[SourceLocation] = None):
        super().__init__(message)
        self.error_type = error_type
        self.location = location
        self.timestamp = time.time()
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert error to dictionary"""
        return {
            'type': self.error_type,
            'message': self.message,
            'location': {
                'file': self.location.file if self.location else None,
                'line': self.location.line if self.location else None,
                'column': self.location.column if self.location else None
            } if self.location else None,
            'timestamp': self.timestamp
        }

class ErrorRecoveryStrategy:
    """Strategy for error recovery"""
    
    def __init__(self, strategy_type: str):
        self.strategy_type = strategy_type
    
    def recover(self, error: NoodleError, context: Dict[str, Any]) -> RecoveryResult:
        """Attempt to recover from error"""
        if self.strategy_type == 'graceful':
            return self._graceful_recovery(error, context)
        elif self.strategy_type == 'rollback':
            return self._rollback_recovery(error, context)
        elif self.strategy_type == 'continue':
            return self._continue_recovery(error, context)
        else:
            return RecoveryResult(success=False, error=error)
    
    def _graceful_recovery(self, error: NoodleError, context: Dict[str, Any]) -> RecoveryResult:
        """Graceful degradation recovery"""
        # Log error and continue with safe defaults
        logger.warning(f"Graceful recovery from {error.error_type}: {error.message}")
        
        return RecoveryResult(
            success=True,
            recovered_value=self._get_safe_default(error.error_type),
            recovery_strategy='graceful'
        )
```

2. **Error Reporting System**

```python
class ErrorReporter:
    """Centralized error reporting"""
    
    def __init__(self):
        self.error_log = []
        self.error_handlers = []
    
    def report_error(self, error: NoodleError):
        """Report error to all handlers"""
        # Add to log
        self.error_log.append(error)
        
        # Notify handlers
        for handler in self.error_handlers:
            try:
                handler(error)
            except Exception as e:
                logger.error(f"Error handler failed: {e}")
    
    def add_error_handler(self, handler: Callable[[NoodleError], None]):
        """Add error handler"""
        self.error_handlers.append(handler)
    
    def get_error_summary(self) -> Dict[str, Any]:
        """Get error summary statistics"""
        error_counts = {}
        for error in self.error_log:
            error_type = error.error_type
            error_counts[error_type] = error_counts.get(error_type, 0) + 1
        
        return {
            'total_errors': len(self.error_log),
            'error_types': error_counts,
            'recent_errors': self.error_log[-10:]  # Last 10 errors
        }
```

## Testing and Validation

### Unit Tests

```python
class TestParserIntegration(unittest.TestCase):
    """Test parser integration for advanced features"""
    
    def setUp(self):
        self.parser = EnhancedParser()
    
    def test_pattern_matching_parsing(self):
        """Test pattern matching parsing"""
        source = """
        match x {
            42 => "number",
            "hello" => "string",
            _ => "default"
        }
        """
        ast = self.parser.parse(source)
        
        # Validate AST structure
        self.assertIsInstance(ast, EnhancedProgramNode)
        self.assertEqual(len(ast.statements), 1)
        
        match_expr = ast.statements[0]
        self.assertIsInstance(match_expr, MatchExpressionNode)
        self.assertEqual(len(match_expr.cases), 3)
    
    def test_generics_parsing(self):
        """Test generics parsing"""
        source = """
        def identity<T>(x: T): T {
            return x
        }
        """
        ast = self.parser.parse(source)
        
        # Validate function definition
        func_def = ast.statements[0]
        self.assertIsInstance(func_def, GenericFunctionDefinitionNode)
        self.assertEqual(len(func_def.generic_parameters), 1)
    
    def test_async_await_parsing(self):
        """Test async/await parsing"""
        source = """
        async def fetch_data(): String {
            return await http.get("url")
        }
        """
        ast = self.parser.parse(source)
        
        # Validate async function
        func_def = ast.statements[0]
        self.assertIsInstance(func_def, AsyncFunctionDefinitionNode)
        self.assertTrue(func_def.is_async)
```

### Integration Tests

```python
class TestCompilerPipeline(unittest.TestCase):
    """Test complete compiler pipeline"""
    
    def setUp(self):
        self.pipeline = CompilerPipeline()
    
    def test_complete_compilation(self):
        """Test complete compilation pipeline"""
        source = """
        def add<T>(a: T, b: T): T {
            return a + b
        }
        
        let result = add(1, 2)
        """
        
        result = self.pipeline.compile_source(source)
        
        self.assertTrue(result.success)
        self.assertIsNotNone(result.bytecode)
        self.assertEqual(len(result.errors), 0)
    
    def test_error_recovery(self):
        """Test error recovery in compilation"""
        source = """
        def broken_function(  # Missing closing parenthesis
            return "incomplete"
        }
        """
        
        result = self.pipeline.compile_source(source)
        
        self.assertFalse(result.success)
        self.assertGreater(len(result.errors), 0)
        # Should still produce partial results
        self.assertIsNotNone(result.statistics)
```

## Implementation Timeline

### Week 1-2: Parser Integration

- [ ] Complete pattern matching parser
- [ ] Implement generics parser
- [ ] Finish async/await parser
- [ ] Add comprehensive parser tests

### Week 3-4: Compiler Pipeline

- [ ] Refactor AST node factory
- [ ] Implement validation system
- [ ] Integrate type inference
- [ ] Add error recovery

### Week 5-6: Runtime Stabilization

- [ ] Implement memory pool
- [ ] Enhance garbage collection
- [ ] Unify error handling
- [ ] Add performance monitoring

### Week 7-8: Testing & Polish

- [ ] Comprehensive testing
- [ ] Performance optimization
- [ ] Documentation updates
- [ ] Final validation

## Success Criteria

### Parser Integration

- [ ] All advanced features parse correctly
- [ ] Error recovery works for syntax errors
- [ ] Performance within 10% of baseline
- [ ] 100% test coverage for parser

### Compiler Pipeline

- [ ] Type inference works for all features
- [ ] Validation catches common errors
- [ ] Error messages are helpful
- [ ] Pipeline is stable under load

### Runtime Systems

- [ ] Memory usage is predictable
- [ ] Error handling is consistent
- [ ] Performance meets targets
- [ ] No memory leaks

This implementation plan provides a detailed roadmap for stabilizing the Noodle language foundation. Each section includes specific code examples, testing strategies, and success criteria to ensure successful implementation.
