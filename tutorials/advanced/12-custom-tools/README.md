# 🔧 Tutorial 12: Custom Tool Development

**NIP v3.0.0 - Advanced Tutorial Series**

Learn how to create, test, and publish custom tools that extend NIP's capabilities. This comprehensive guide covers tool architecture, async patterns, composition strategies, and best practices.

## 📋 Table of Contents

- [Introduction](#introduction)
- [Tool Architecture](#tool-architecture)
- [Building Your First Tool](#building-your-first-tool)
- [Async Tool Development](#async-tool-development)
- [Tool Composition & Chaining](#tool-composition--chaining)
- [Error Handling Patterns](#error-handling-patterns)
- [Tool Validation](#tool-validation)
- [Testing Strategies](#testing-strategies)
- [Documentation](#documentation)
- [Publishing Tools](#publishing-tools)
- [Best Practices](#best-practices)
- [Exercises](#exercises)

---

## Introduction

Custom tools are the primary way to extend NIP's functionality. Tools are async functions that accept structured parameters and return structured results, enabling everything from simple data transformations to complex multi-step workflows.

### Why Create Custom Tools?

- **Reusability**: Encapsulate common operations
- **Composition**: Build complex workflows from simple tools
- **Sharing**: Distribute functionality across teams
- **Testing**: Isolated units are easier to test
- **Documentation**: Self-documenting through schemas

---

## Tool Architecture

### Core Components

```python
from typing import Any, Dict, Optional
from pydantic import BaseModel, Field
from enum import Enum

class ToolParameter(BaseModel):
    """Defines a tool parameter with validation"""
    name: str
    type: str  # "string", "number", "boolean", "array", "object"
    description: str
    required: bool = True
    default: Optional[Any] = None
    
class ToolSchema(BaseModel):
    """Complete tool interface definition"""
    name: str
    description: str
    parameters: list[ToolParameter]
    returns: Dict[str, Any]
    
class ToolContext(BaseModel):
    """Context passed to tools during execution"""
    agent_id: str
    session_id: str
    user_context: Dict[str, Any]
    metadata: Dict[str, Any]
```

### Tool Interface Contract

```python
from abc import ABC, abstractmethod

class ToolInterface(ABC):
    """Base interface all tools must implement"""
    
    @abstractmethod
    async def execute(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Main execution method"""
        pass
    
    @abstractmethod
    def get_schema(self) -> ToolSchema:
        """Return tool's interface definition"""
        pass
    
    @abstractmethod
    async def validate(self, parameters: Dict[str, Any]) -> bool:
        """Validate parameters before execution"""
        pass
```

---

## Building Your First Tool

### Step 1: Define the Schema

```python
from pydantic import BaseModel, Field, validator

class WeatherQueryParams(BaseModel):
    """Parameters for weather query tool"""
    location: str = Field(
        ...,
        description="City name or zip code",
        min_length=2,
        max_length=100
    )
    units: str = Field(
        "metric",
        description="Temperature units (metric/imperial)"
    )
    include_forecast: bool = Field(
        False,
        description="Include 7-day forecast"
    )
    
    @validator('units')
    def validate_units(cls, v):
        if v not in ['metric', 'imperial']:
            raise ValueError("units must be 'metric' or 'imperial'")
        return v
```

### Step 2: Implement the Tool

```python
import httpx
from typing import Dict, Any

class WeatherQueryTool:
    """Fetch weather data for a location"""
    
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://api.openweathermap.org/data/2.5"
    
    async def execute(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Execute the weather query"""
        # Validate and parse parameters
        params = WeatherQueryParams(**parameters)
        
        # Make API call
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{self.base_url}/weather",
                params={
                    "q": params.location,
                    "units": params.units,
                    "appid": self.api_key
                }
            )
            response.raise_for_status()
            data = response.json()
        
        # Format response
        result = {
            "location": data["name"],
            "temperature": data["main"]["temp"],
            "description": data["weather"][0]["description"],
            "humidity": data["main"]["humidity"],
            "units": params.units
        }
        
        # Add forecast if requested
        if params.include_forecast:
            result["forecast"] = await self._get_forecast(
                params.location, 
                params.units
            )
        
        return result
    
    def get_schema(self) -> ToolSchema:
        """Return tool schema"""
        return ToolSchema(
            name="weather_query",
            description="Fetch current weather and optional forecast",
            parameters=[
                ToolParameter(
                    name="location",
                    type="string",
                    description="City name or zip code",
                    required=True
                ),
                ToolParameter(
                    name="units",
                    type="string",
                    description="Temperature units",
                    required=False,
                    default="metric"
                ),
                ToolParameter(
                    name="include_forecast",
                    type="boolean",
                    description="Include 7-day forecast",
                    required=False,
                    default=False
                )
            ],
            returns={
                "type": "object",
                "properties": {
                    "location": {"type": "string"},
                    "temperature": {"type": "number"},
                    "description": {"type": "string"},
                    "humidity": {"type": "number"},
                    "units": {"type": "string"},
                    "forecast": {"type": "array"}
                }
            }
        )
```

### Step 3: Register the Tool

```python
from nip.core import Agent

# Create agent
agent = Agent()

# Register tool
agent.register_tool(
    name="weather_query",
    tool=WeatherQueryTool(api_key="your-api-key"),
    description="Fetch weather data for any location"
)

# Use the tool
result = await agent.run(
    "What's the weather in Tokyo with forecast?"
)
```

---

## Async Tool Development

### Understanding Async Context

```python
import asyncio
from typing import List, Dict, Any

class DataAggregatorTool:
    """Aggregate data from multiple sources concurrently"""
    
    async def execute(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        sources = parameters.get("sources", [])
        
        # Fetch all sources concurrently
        tasks = [self._fetch_source(source) for source in sources]
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # Process results
        successful = [r for r in results if not isinstance(r, Exception)]
        errors = [r for r in results if isinstance(r, Exception)]
        
        return {
            "data": successful,
            "errors": [str(e) for e in errors],
            "total_fetched": len(successful)
        }
    
    async def _fetch_source(self, source: str) -> Dict[str, Any]:
        """Fetch data from a single source"""
        # Simulate async I/O
        await asyncio.sleep(0.1)
        return {"source": source, "data": f"data from {source}"}
```

### Timeout Handling

```python
import asyncio
from asyncio import TimeoutError

class TimeoutAwareTool:
    """Tool with configurable timeout"""
    
    async def execute(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        timeout = parameters.get("timeout", 30)
        
        try:
            result = await asyncio.wait_for(
                self._long_running_operation(),
                timeout=timeout
            )
            return {"status": "success", "data": result}
        
        except TimeoutError:
            return {
                "status": "timeout",
                "error": f"Operation exceeded {timeout}s timeout"
            }
    
    async def _long_running_operation(self) -> Dict[str, Any]:
        """Simulate long operation"""
        await asyncio.sleep(35)  # Exceeds default timeout
        return {"result": "completed"}
```

### Caching Strategy

```python
from functools import lru_cache
from typing import Optional
import hashlib
import json

class CachedTool:
    """Tool with intelligent caching"""
    
    def __init__(self, cache_ttl: int = 300):
        self.cache_ttl = cache_ttl
        self._cache: Dict[str, tuple[Any, float]] = {}
    
    async def execute(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        # Generate cache key
        cache_key = self._generate_cache_key(parameters)
        
        # Check cache
        if cached := self._get_from_cache(cache_key):
            return {"status": "cached", "data": cached}
        
        # Execute and cache
        result = await self._compute(parameters)
        self._store_in_cache(cache_key, result)
        
        return {"status": "computed", "data": result}
    
    def _generate_cache_key(self, parameters: Dict[str, Any]) -> str:
        """Generate deterministic cache key"""
        param_str = json.dumps(parameters, sort_keys=True)
        return hashlib.md5(param_str.encode()).hexdigest()
    
    def _get_from_cache(self, key: str) -> Optional[Any]:
        """Retrieve from cache if not expired"""
        if key in self._cache:
            value, timestamp = self._cache[key]
            # Check TTL
            if asyncio.get_event_loop().time() - timestamp < self.cache_ttl:
                return value
            else:
                del self._cache[key]
        return None
```

---

## Tool Composition & Chaining

### Sequential Chaining

```python
class ChainedToolExecutor:
    """Execute multiple tools in sequence"""
    
    def __init__(self, tools: Dict[str, Any]):
        self.tools = tools
    
    async def execute_chain(
        self, 
        chain: List[Dict[str, Any]],
        initial_context: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Execute a chain of tools, passing outputs to inputs"""
        context = initial_context.copy()
        
        for step in chain:
            tool_name = step["tool"]
            tool = self.tools[tool_name]
            
            # Resolve parameters from context
            parameters = self._resolve_parameters(
                step["parameters"], 
                context
            )
            
            # Execute tool
            result = await tool.execute(parameters)
            
            # Update context
            output_key = step.get("output", f"{tool_name}_output")
            context[output_key] = result
        
        return context
    
    def _resolve_parameters(
        self, 
        parameters: Dict[str, Any], 
        context: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Resolve parameter references from context"""
        resolved = {}
        for key, value in parameters.items():
            if isinstance(value, str) and value.startswith("$"):
                # Reference to context variable
                ref = value[1:]
                resolved[key] = context.get(ref)
            else:
                resolved[key] = value
        return resolved
```

### Parallel Execution

```python
class ParallelToolExecutor:
    """Execute multiple tools in parallel"""
    
    async def execute_parallel(
        self, 
        tools: List[Dict[str, Any]],
        context: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Execute tools concurrently and collect results"""
        tasks = []
        task_names = []
        
        for tool_config in tools:
            tool = self._get_tool(tool_config["name"])
            parameters = tool_config["parameters"]
            task_names.append(tool_config["name"])
            tasks.append(tool.execute(parameters))
        
        # Execute all concurrently
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # Format results
        return {
            name: result if not isinstance(result, Exception) else {"error": str(result)}
            for name, result in zip(task_names, results)
        }
```

### Conditional Execution

```python
class ConditionalToolExecutor:
    """Execute tools based on conditions"""
    
    async def execute_conditional(
        self,
        workflow: Dict[str, Any],
        context: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Execute workflow with conditional branching"""
        
        # Evaluate condition
        if self._evaluate_condition(workflow["condition"], context):
            # Execute true branch
            return await self._execute_branch(
                workflow["true_branch"],
                context
            )
        else:
            # Execute false branch
            return await self._execute_branch(
                workflow.get("false_branch", []),
                context
            )
    
    def _evaluate_condition(
        self, 
        condition: Dict[str, Any], 
        context: Dict[str, Any]
    ) -> bool:
        """Evaluate conditional expression"""
        var_name = condition["variable"]
        operator = condition["operator"]
        value = condition["value"]
        
        context_value = context.get(var_name)
        
        if operator == "equals":
            return context_value == value
        elif operator == "greater_than":
            return context_value > value
        elif operator == "contains":
            return value in context_value
        else:
            raise ValueError(f"Unknown operator: {operator}")
```

---

## Error Handling Patterns

### Graceful Degradation

```python
class ResilientTool:
    """Tool with fallback strategies"""
    
    async def execute(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        primary_result = None
        fallback_result = None
        
        try:
            # Try primary method
            primary_result = await self._primary_method(parameters)
            return {
                "status": "success",
                "method": "primary",
                "data": primary_result
            }
        except Exception as e:
            # Try fallback
            try:
                fallback_result = await self._fallback_method(parameters)
                return {
                    "status": "fallback",
                    "method": "fallback",
                    "data": fallback_result,
                    "warning": f"Primary method failed: {str(e)}"
                }
            except Exception as fallback_error:
                return {
                    "status": "failed",
                    "error": str(fallback_error),
                    "primary_error": str(e)
                }
```

### Retry Logic

```python
import asyncio
from typing import Callable, Any

class RetryableTool:
    """Tool with automatic retry on failure"""
    
    async def execute_with_retry(
        self,
        operation: Callable,
        max_retries: int = 3,
        base_delay: float = 1.0,
        backoff_factor: float = 2.0
    ) -> Dict[str, Any]:
        """Execute operation with exponential backoff"""
        last_exception = None
        
        for attempt in range(max_retries):
            try:
                result = await operation()
                return {
                    "status": "success",
                    "data": result,
                    "attempts": attempt + 1
                }
            except Exception as e:
                last_exception = e
                if attempt < max_retries - 1:
                    delay = base_delay * (backoff_factor ** attempt)
                    await asyncio.sleep(delay)
        
        return {
            "status": "failed",
            "error": str(last_exception),
            "attempts": max_retries
        }
```

### Circuit Breaker Pattern

```python
from enum import Enum
from datetime import datetime, timedelta

class CircuitState(Enum):
    CLOSED = "closed"  # Normal operation
    OPEN = "open"      # Failing, reject requests
    HALF_OPEN = "half_open"  # Testing recovery

class CircuitBreakerTool:
    """Tool with circuit breaker for fault tolerance"""
    
    def __init__(
        self, 
        failure_threshold: int = 5,
        timeout_seconds: int = 60
    ):
        self.failure_count = 0
        self.failure_threshold = failure_threshold
        self.timeout = timedelta(seconds=timeout_seconds)
        self.state = CircuitState.CLOSED
        self.last_failure_time: Optional[datetime] = None
    
    async def execute(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        # Check circuit state
        if self.state == CircuitState.OPEN:
            if self._should_attempt_reset():
                self.state = CircuitState.HALF_OPEN
            else:
                return {
                    "status": "rejected",
                    "error": "Circuit breaker is OPEN"
                }
        
        try:
            result = await self._protected_operation(parameters)
            self._on_success()
            return {"status": "success", "data": result}
        
        except Exception as e:
            self._on_failure()
            return {"status": "failed", "error": str(e)}
    
    def _should_attempt_reset(self) -> bool:
        """Check if timeout has elapsed"""
        if self.last_failure_time is None:
            return True
        return datetime.now() - self.last_failure_time > self.timeout
    
    def _on_success(self):
        """Handle successful operation"""
        self.failure_count = 0
        if self.state == CircuitState.HALF_OPEN:
            self.state = CircuitState.CLOSED
    
    def _on_failure(self):
        """Handle failed operation"""
        self.failure_count += 1
        self.last_failure_time = datetime.now()
        
        if self.failure_count >= self.failure_threshold:
            self.state = CircuitState.OPEN
```

---

## Tool Validation

### Parameter Validation

```python
from pydantic import BaseModel, Field, validator
from typing import List, Optional

class ToolParameters(BaseModel):
    """Comprehensive parameter validation"""
    
    email: str = Field(..., regex=r"^[^@]+@[^@]+\.[^@]+$")
    age: int = Field(..., ge=0, le=150)
    tags: List[str] = Field(default_factory=list, max_items=10)
    priority: Optional[int] = Field(None, ge=1, le=5)
    
    @validator('tags')
    def validate_tags(cls, v):
        """Ensure tags are lowercase"""
        return [tag.lower() for tag in v]
    
    @validator('email')
    def email_must_contain_domain(cls, v):
        """Custom email validation"""
        if 'example.com' in v:
            raise ValueError('example.com emails are not allowed')
        return v

# Use in tool
class ValidatedTool:
    async def execute(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        try:
            # Validate parameters
            params = ToolParameters(**parameters)
            # Proceed with execution
            return {"status": "validated", "data": params.dict()}
        except ValidationError as e:
            return {
                "status": "validation_failed",
                "errors": e.errors()
            }
```

### Output Validation

```python
class ToolOutput(BaseModel):
    """Validate tool output structure"""
    success: bool
    data: Optional[Dict[str, Any]] = None
    error: Optional[str] = None
    metadata: Dict[str, Any] = Field(default_factory=dict)
    
    @validator('error')
    def error_only_on_failure(cls, v, values):
        """Ensure error only present when success is False"""
        if v is not None and values.get('success', True):
            raise ValueError('error must be null when success is true')
        return v

class OutputValidatedTool:
    """Tool that validates its own output"""
    
    async def execute(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        result = await self._compute(parameters)
        
        # Validate output before returning
        try:
            validated = ToolOutput(**result)
            return validated.dict()
        except ValidationError as e:
            # Return validation error as tool error
            return ToolOutput(
                success=False,
                error=f"Internal output validation failed: {str(e)}"
            ).dict()
```

---

## Testing Strategies

### Unit Testing Tools

```python
import pytest
from unittest.mock import AsyncMock, patch

class TestWeatherQueryTool:
    """Unit tests for weather query tool"""
    
    @pytest.fixture
    def tool(self):
        return WeatherQueryTool(api_key="test-key")
    
    @pytest.mark.asyncio
    async def test_successful_query(self, tool):
        """Test successful weather query"""
        with patch('httpx.AsyncClient.get') as mock_get:
            mock_response = AsyncMock()
            mock_response.json.return_value = {
                "name": "Tokyo",
                "main": {"temp": 20, "humidity": 65},
                "weather": [{"description": "clear sky"}]
            }
            mock_response.raise_for_status = AsyncMock()
            mock_get.return_value = mock_response
            
            result = await tool.execute({
                "location": "Tokyo",
                "units": "metric"
            })
            
            assert result["location"] == "Tokyo"
            assert result["temperature"] == 20
            assert result["units"] == "metric"
    
    @pytest.mark.asyncio
    async def test_invalid_location(self, tool):
        """Test handling of invalid location"""
        with patch('httpx.AsyncClient.get') as mock_get:
            mock_get.side_effect = httpx.HTTPStatusError(
                "Not Found",
                request=AsyncMock(),
                response=AsyncMock(status_code=404)
            )
            
            with pytest.raises(httpx.HTTPStatusError):
                await tool.execute({"location": "InvalidCity"})
```

### Integration Testing

```python
class TestToolIntegration:
    """Integration tests for tool workflows"""
    
    @pytest.mark.asyncio
    async def test_tool_chain_execution(self):
        """Test chain of tools executing correctly"""
        executor = ChainedToolExecutor(tools={
            "fetch": FetchDataTool(),
            "process": ProcessDataTool(),
            "save": SaveDataTool()
        })
        
        chain = [
            {
                "tool": "fetch",
                "parameters": {"url": "https://api.example.com/data"},
                "output": "raw_data"
            },
            {
                "tool": "process",
                "parameters": {"data": "$raw_data"},
                "output": "processed_data"
            },
            {
                "tool": "save",
                "parameters": {"data": "$processed_data", "path": "output.json"},
                "output": "save_result"
            }
        ]
        
        result = await executor.execute_chain(chain, {})
        
        assert "processed_data" in result
        assert "save_result" in result
        assert result["save_result"]["status"] == "success"
```

### Mocking External Dependencies

```python
from unittest.mock import MagicMock, AsyncMock

class TestToolWithMocks:
    """Test tools with mocked dependencies"""
    
    @pytest.mark.asyncio
    async def test_database_tool(self):
        """Test database tool with mocked DB"""
        # Create mock database
        mock_db = AsyncMock()
        mock_db.query.return_value = [
            {"id": 1, "name": "Item 1"},
            {"id": 2, "name": "Item 2"}
        ]
        
        # Create tool with mock
        tool = DatabaseTool(db=mock_db)
        
        # Execute
        result = await tool.execute({"query": "SELECT * FROM items"})
        
        # Verify
        assert len(result["data"]) == 2
        mock_db.query.assert_called_once()
```

---

## Documentation

### Tool Documentation Template

```python
"""
DataProcessorTool - Process and transform structured data

This tool provides data processing capabilities including filtering,
aggregation, and transformation operations.

Examples:
    >>> tool = DataProcessorTool()
    >>> result = await tool.execute({
    ...     "operation": "filter",
    ...     "data": [{"age": 25}, {"age": 30}],
    ...     "condition": "age > 28"
    ... })
    >>> print(result)
    {"data": [{"age": 30}], "count": 1}

Parameters:
    operation (str): Processing operation type
        - "filter": Filter data by condition
        - "aggregate": Aggregate data by field
        - "transform": Transform data structure
    
    data (list): Input data array
    condition (str, optional): Filter condition expression
    field (str, optional): Field to aggregate by

Returns:
    dict: Result object containing:
        - data (list): Processed data
        - count (int): Number of items
        - metadata (dict): Processing metadata

Raises:
    ValueError: If operation is invalid
    ValidationError: If parameters don't match schema
"""

class DataProcessorTool:
    """Implementation as shown in previous sections"""
    pass
```

### Auto-Documentation Generator

```python
def generate_tool_docs(tool_class) -> str:
    """Generate markdown documentation from tool schema"""
    schema = tool_class().get_schema()
    
    docs = f"# {schema.name}\n\n"
    docs += f"{schema.description}\n\n"
    docs += "## Parameters\n\n"
    
    for param in schema.parameters:
        required = "Required" if param.required else "Optional"
        docs += f"- **{param.name}** ({param.type}, {required})\n"
        docs += f"  - {param.description}\n"
        if param.default:
            docs += f"  - Default: `{param.default}`\n"
    
    docs += "\n## Returns\n\n"
    docs += f"```json\n{json.dumps(schema.returns, indent=2)}\n```\n"
    
    return docs
```

---

## Publishing Tools

### Tool Package Structure

```
my-custom-tools/
├── pyproject.toml
├── README.md
├── my_custom_tools/
│   ├── __init__.py
│   ├── tools/
│   │   ├── __init__.py
│   │   ├── data_processor.py
│   │   ├── api_connector.py
│   │   └── file_handler.py
│   └── schemas/
│       ├── __init__.py
│       └── definitions.py
└── tests/
    ├── test_data_processor.py
    ├── test_api_connector.py
    └── test_file_handler.py
```

### pyproject.toml Template

```toml
[tool.poetry]
name = "my-custom-tools"
version = "1.0.0"
description = "Custom tools for NIP"
authors = ["Your Name <you@example.com>"]
readme = "README.md"

[tool.poetry.dependencies]
python = "^3.10"
nip = ">=3.0.0"
pydantic = "^2.0.0"
httpx = "^0.24.0"

[tool.poetry.group.dev.dependencies]
pytest = "^7.4.0"
pytest-asyncio = "^0.21.0"
black = "^23.0.0"
mypy = "^1.0.0"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
```

### Publishing to PyPI

```bash
# Build the package
poetry build

# Publish to PyPI (test first)
poetry publish

# Or publish to test PyPI first
poetry publish --repository testpypi

# Install in another project
pip install my-custom-tools
```

---

## Best Practices

### 1. Keep Tools Focused

```python
# ❌ Bad: Too many responsibilities
class SuperTool:
    async def execute(self, params):
        if params["type"] == "fetch":
            return await self._fetch()
        elif params["type"] == "process":
            return await self._process()
        elif params["type"] == "save":
            return await self._save()

# ✅ Good: Single responsibility
class FetchDataTool:
    async def execute(self, params):
        return await self._fetch()

class ProcessDataTool:
    async def execute(self, params):
        return await self._process()
```

### 2. Use Clear Naming

```python
# ❌ Bad: Vague names
class Tool1:
    pass

def do_stuff(data):
    pass

# ✅ Good: Descriptive names
class CustomerDataFetcherTool:
    pass

async def fetch_customer_orders(customer_id: str) -> List[Order]:
    pass
```

### 3. Handle Errors Gracefully

```python
# ✅ Good: Comprehensive error handling
async def execute(self, params):
    try:
        self._validate_params(params)
        result = await self._perform_operation(params)
        return {"success": True, "data": result}
    except ValidationError as e:
        return {"success": False, "error": f"Validation failed: {e}"}
    except IOError as e:
        return {"success": False, "error": f"I/O error: {e}"}
    except Exception as e:
        logger.error(f"Unexpected error in {self.__class__.__name__}: {e}")
        return {"success": False, "error": "Internal error occurred"}
```

### 4. Log Important Events

```python
import logging

logger = logging.getLogger(__name__)

class LoggedTool:
    async def execute(self, params):
        logger.info(f"Executing {self.__class__.__name__} with params: {params}")
        
        try:
            result = await self._compute(params)
            logger.info(f"Successfully completed {self.__class__.__name__}")
            return result
        except Exception as e:
            logger.error(f"Error in {self.__class__.__name__}: {e}")
            raise
```

### 5. Write Comprehensive Tests

```python
# ✅ Good: Test coverage for all scenarios
class TestRobustTool:
    def test_valid_parameters(self): ...
    def test_missing_required_param(self): ...
    def test_invalid_type(self): ...
    def test_boundary_values(self): ...
    def test_concurrent_execution(self): ...
    def test_error_handling(self): ...
    def test_timeout_behavior(self): ...
```

---

## Exercises

### Exercise 1: Create a Data Validation Tool

Build a tool that validates data against a schema:

```python
class DataValidationTool:
    """
    Validate data against JSON Schema
    
    Parameters:
        data (dict): Data to validate
        schema (dict): JSON Schema definition
        strict (bool): Whether to use strict validation
    
    Returns:
        dict: {
            "valid": bool,
            "errors": list[str],
            "warnings": list[str]
        }
    """
    
    async def execute(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        # Your implementation here
        pass
```

Requirements:
- Support basic JSON Schema validation
- Return detailed error messages
- Handle nested objects and arrays
- Include optional strict mode

### Exercise 2: Build a Batch Processing Tool

Create a tool that processes items in batches:

```python
class BatchProcessorTool:
    """
    Process items in configurable batches
    
    Parameters:
        items (list): Items to process
        batch_size (int): Number of items per batch
        processor (str): Name of processing function
        parallel (bool): Process batches in parallel
    
    Returns:
        dict: {
            "results": list,
            "batches_processed": int,
            "total_items": int,
            "failed_items": int
        }
    """
    
    async def execute(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        # Your implementation here
        pass
```

Requirements:
- Split items into batches
- Support parallel batch processing
- Track failures per batch
- Return comprehensive statistics

### Exercise 3: Implement a Rate-Limited API Caller

Build a tool with rate limiting:

```python
class RateLimitedCallerTool:
    """
    Make API calls with rate limiting
    
    Parameters:
        urls (list): URLs to call
        rate_limit (int): Max calls per minute
        timeout (int): Request timeout in seconds
        retry_count (int): Number of retries on failure
    
    Returns:
        dict: {
            "responses": list,
            "failed": list,
            "rate_limit_stats": dict
        }
    """
    
    async def execute(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        # Your implementation here
        pass
```

Requirements:
- Respect rate limits
- Retry failed requests
- Track rate limit statistics
- Handle timeouts gracefully

---

## Next Steps

- Explore [Tutorial 13: Advanced Prompting Patterns](../13-advanced-prompting/) for prompt engineering
- Learn about [Performance Optimization](../14-optimization/) in the next tutorial
- Review [Testing & Debugging](../15-testing-debugging/) for comprehensive testing strategies

## Resources

- [NIP Tool Reference](https://docs.nip.ai/tools)
- [Pydantic Documentation](https://docs.pydantic.dev/)
- [Python Async/Await](https://docs.python.org/3/library/asyncio.html)
- [JSON Schema Specification](https://json-schema.org/)

---

**Tutorial 12: Custom Tool Development | NIP v3.0.0 | Advanced Series**
