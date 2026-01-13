# NoodleCore TRM & AERE Enhanced Implementation Guide

## Overview

This guide provides comprehensive documentation for the enhanced Task Reasoning Manager (TRM) and AI Error Resolution Engine (AERE) implementations in NoodleCore. These components provide advanced AI-powered reasoning, error analysis, and resolution capabilities with full orchestration, monitoring, and backward compatibility.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Task Reasoning Manager (TRM)](#task-reasoning-manager-trm)
3. [AI Error Resolution Engine (AERE)](#ai-error-resolution-engine-aere)
4. [Agent Orchestration](#agent-orchestration)
5. [Integration Guide](#integration-guide)
6. [Usage Examples](#usage-examples)
7. [Configuration](#configuration)
8. [Performance Monitoring](#performance-monitoring)
9. [Troubleshooting](#troubleshooting)
10. [API Reference](#api-reference)

## Architecture Overview

The enhanced TRM and AERE system consists of several interconnected components:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   TRM Agent     │    │   AERE Engine   │    │ Agent Orchestrator │
│                 │    │                 │    │                 │
│ • Reasoning     │◄──►│ • Error Analysis│◄──►│ • Coordination  │
│ • Task Decomp.  │    │ • Resolution    │    │ • Load Balancing│
│ • Knowledge Graph│   │ • Multi-Provider│    │ • Failover      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │ Lifecycle Mgr   │
                    │                 │
                    │ • Health Mgmt   │
                    │ • Resource Alloc│
                    │ • Auto-Restart  │
                    └─────────────────┘
```

### Key Features

- **Recursive Problem Solving**: Complex tasks are automatically decomposed into manageable subtasks
- **Context-Aware Decision Making**: Decisions are based on rich contextual information including project structure, error patterns, and historical data
- **Knowledge Graph Integration**: Complex relationships between code elements, errors, and solutions are maintained and utilized
- **Multi-Provider AI Support**: Integration with OpenAI, OpenRouter, LM Studio, and Z.ai for diverse AI capabilities
- **Guardrail System**: Safety mechanisms ensure AI decisions are appropriate and secure
- **Explainable AI**: Full traceability of AI decisions with detailed explanations
- **Agent Orchestration**: Centralized coordination of multiple AI agents with load balancing and failover
- **Performance Monitoring**: Comprehensive metrics and monitoring for all AI operations
- **Backward Compatibility**: Seamless integration with existing NoodleCore components

## Task Reasoning Manager (TRM)

The TRM provides advanced reasoning capabilities for complex problem-solving tasks.

### Core Components

#### 1. Reasoning Engine

The reasoning engine supports multiple reasoning strategies:

- **Deductive Reasoning**: From general principles to specific conclusions
- **Inductive Reasoning**: From specific observations to general principles
- **Abductive Reasoning**: Finding the best explanation for observations
- **Analogical Reasoning**: Drawing parallels between similar situations
- **Causal Reasoning**: Understanding cause-and-effect relationships
- **Hybrid Reasoning**: Combining multiple strategies for optimal results

#### 2. Task Decomposition

Complex tasks are recursively broken down into simpler subtasks:

```python
# Example of task decomposition
task = {
    "description": "Fix complex syntax error in nested function",
    "complexity": "critical",
    "context": {
        "file_path": "/project/src/main.nc",
        "error_line": 42,
        "error_type": "syntax_error"
    }
}

# TRM automatically decomposes into:
# 1. Analyze error context
# 2. Identify root cause
# 3. Generate potential solutions
# 4. Validate solutions
# 5. Apply best solution
```

#### 3. Knowledge Graph Integration

The knowledge graph maintains relationships between:

- Code elements (functions, classes, variables)
- Error patterns and their solutions
- Project structure and dependencies
- Historical fixes and their outcomes

### Usage Examples

#### Basic TRM Usage

```python
from src.noodlecore.noodlecore_trm_agent import TRMAgent

# Initialize TRM agent
trm = TRMAgent({
    "reasoning_engine": "enhanced",
    "max_recursion_depth": 10,
    "reasoning_timeout": 60,
    "cache_size": 1000,
    "knowledge_graph_enabled": True
})

# Start the agent
trm.start()

# Reason about a task
result = trm.reason_about_task(
    "Fix syntax error in function",
    {
        "file_path": "/project/src/utils.nc",
        "line_number": 15,
        "error_message": "Missing semicolon",
        "code_snippet": "def helper_function():\n    return True"
    }
)

print(f"Reasoning result: {result}")
print(f"Task complexity: {result['task_complexity']}")
print(f"Recommendations: {result['recommendations']}")
```

#### Advanced TRM with Knowledge Graph

```python
# Add knowledge to the graph
trm.knowledge_graph.add_node(
    "syntax_error_001", 
    "error_pattern",
    {
        "pattern": "missing_semicolon",
        "common_fix": "add_semicolon",
        "confidence": 0.95
    }
)

# Add relationships
trm.knowledge_graph.add_relationship(
    "syntax_error_001", 
    "function_definition", 
    "occurs_in"
)

# Query related knowledge
related = trm.knowledge_graph.query_related_nodes(
    "syntax_error_001", 
    max_depth=2
)

# Find similar problems
similar = trm.knowledge_graph.find_similar_problems(
    "missing_semicolon_pattern", 
    similarity_threshold=0.7
)
```

## AI Error Resolution Engine (AERE)

The AERE provides comprehensive error analysis and resolution capabilities with multi-provider AI support.

### Core Components

#### 1. Error Analysis Pipeline

The error analysis pipeline processes errors through multiple stages:

1. **Error Classification**: Categorize errors by type, severity, and complexity
2. **Context Analysis**: Analyze surrounding code and project structure
3. **Pattern Recognition**: Identify known error patterns and their solutions
4. **Root Cause Analysis**: Determine the underlying cause of errors
5. **Impact Assessment**: Evaluate the potential impact of errors and fixes

#### 2. Multi-Provider AI Integration

AERE integrates with multiple AI providers:

- **OpenAI**: GPT-4 and other OpenAI models
- **OpenRouter**: Access to various models through OpenRouter
- **LM Studio**: Local model hosting and inference
- **Z.ai**: Specialized AI models for code analysis

#### 3. Guardrail System

The guardrail system ensures safe and appropriate AI decisions:

- **Content Safety**: Blocks harmful or inappropriate content
- **Code Safety**: Validates generated code for security issues
- **Decision Validation**: Ensures AI decisions are logical and appropriate
- **Compliance Checking**: Verifies compliance with coding standards and policies

#### 4. Explainable AI

Full traceability of AI decisions with:

- **Decision Process**: Step-by-step explanation of how decisions were made
- **Confidence Analysis**: Detailed breakdown of confidence scores
- **Alternative Options**: Explanation of why other options were not chosen
- **Traceability**: Complete audit trail of the resolution process

### Usage Examples

#### Basic AERE Usage

```python
from src.noodlecore.ai.aere_engine import AEREngine, ErrorContext

# Initialize AERE engine
aere = AEREngine({
    "timeout": 120,
    "max_retries": 3,
    "cache_size": 500,
    "guardrails_enabled": True,
    "explainability_enabled": True
})

# Start the engine
aere.start()

# Create error context
error_context = ErrorContext(
    error_id="error_001",
    error_type="syntax_error",
    error_message="Unexpected token in function definition",
    file_path="/project/src/main.nc",
    line_number=25,
    code_snippet="def calculate_sum(a, b)\n    return a + b"
)

# Analyze the error
analysis = aere.analyze_error({
    "error_info": error_context.__dict__
})

print(f"Error analysis: {analysis}")
print(f"Error type: {analysis['analysis']['error_type']}")
print(f"Severity: {analysis['analysis']['severity']}")
```

#### Multi-Provider Resolution

```python
# Generate resolution using multiple providers
resolution = aere.generate_resolution(error_context)

print(f"Resolution: {resolution}")
print(f"Provider used: {resolution['provider']}")
print(f"Confidence: {resolution['confidence']}")

# Apply the resolution
result = aere.apply_resolution(resolution)

print(f"Application result: {result}")
print(f"Changes applied: {result['successful_changes']}")
```

#### Guardrail and Explainability

```python
# Check guardrails
test_data = {"content": "Generated code content", "test": True}
violations = aere.guardrail_system.check_guardrails(test_data, error_context)

if violations:
    print(f"Guardrail violations: {violations}")
else:
    print("No guardrail violations")

# Generate explanation
trace = aere.explainability_system.create_trace(error_context, resolution)
explanation = aere.explainability_system.generate_explanation(trace)

print(f"Explanation: {explanation}")
print(f"Decision process: {explanation['decision_process']}")
print(f"Confidence breakdown: {explanation['confidence_breakdown']}")
```

## Agent Orchestration

The agent orchestrator provides centralized coordination of multiple AI agents with load balancing and failover capabilities.

### Core Components

#### 1. Agent Registry

Maintains information about available agents including:

- Agent capabilities and specializations
- Current status and health
- Performance metrics
- Resource utilization

#### 2. Load Balancing

Supports multiple load balancing strategies:

- **Round Robin**: Distribute tasks evenly across agents
- **Least Connections**: Route to agent with fewest active tasks
- **Fastest Response**: Route to agent with best response time
- **Weighted**: Distribute based on agent weights and capabilities

#### 3. Failover System

Automatic failover when agents become unavailable:

- Health monitoring and detection
- Automatic task reassignment
- Graceful degradation of capabilities
- Recovery and reintroduction

### Usage Examples

#### Basic Orchestration

```python
from src.noodlecore.ai_agents.agent_orchestrator import AgentOrchestrator

# Initialize orchestrator
orchestrator = AgentOrchestrator({
    "max_concurrent": 10,
    "timeout": 300,
    "load_balance_strategy": "round_robin",
    "failover_enabled": True
})

# Register agents
agent_info = {
    "agent_id": "syntax_fixer_001",
    "agent_type": "syntax_fixer",
    "name": "Primary Syntax Fixer",
    "capabilities": ["syntax_fix", "error_analysis"],
    "health_score": 1.0,
    "max_concurrent_tasks": 5,
    "endpoint": "http://localhost:8081"
}

orchestrator.register_agent(agent_info)

# Submit task
task_id = orchestrator.submit_task(
    "fix_syntax_error",
    {
        "description": "Fix missing semicolon",
        "file_path": "/project/src/utils.nc",
        "line_number": 15
    },
    priority="high"
)

# Check task status
status = orchestrator.get_task_status(task_id)
print(f"Task status: {status}")
```

#### Load Balancing Strategies

```python
# Configure different load balancing strategies
strategies = ["round_robin", "least_connections", "fastest_response", "weighted"]

for strategy in strategies:
    orchestrator.configure({"load_balance_strategy": strategy})
    
    # Submit test tasks
    task_ids = []
    for i in range(10):
        task_id = orchestrator.submit_task(
            f"test_task_{i}",
            {"description": f"Load balance test {i}"},
            priority="medium"
        )
        task_ids.append(task_id)
    
    # Monitor distribution
    time.sleep(1)  # Allow time for assignment
    metrics = orchestrator.get_orchestrator_status()
    print(f"Strategy: {strategy}")
    print(f"Load balance efficiency: {metrics['load_balance_efficiency']}")
```

## Integration Guide

### Enhanced AI Integration

The enhanced AI integration component combines TRM and AERE capabilities with existing NoodleCore components.

```python
from src.noodlecore.ai_agents.enhanced_ai_integration import EnhancedAIIntegration

# Initialize enhanced integration
integration = EnhancedAIIntegration({
    "mode": "hybrid",  # trm_only, aere_only, or hybrid
    "trm_enabled": True,
    "aere_enabled": True,
    "performance_monitoring": True,
    "caching_enabled": True,
    "load_balancing": True,
    "failover_enabled": True
})

# Process syntax task
result = integration.process_syntax_task(
    "Fix complex syntax error",
    {
        "file_path": "/project/src/main.nc",
        "error_message": "Unexpected token",
        "code_snippet": "def function()\n    pass"
    }
)

print(f"Integration result: {result}")
print(f"Success: {result['success']}")
print(f"TRM analysis: {result['trm_analysis']}")
print(f"AERE analysis: {result['aere_analysis']}")
```

### Integration with Existing Syntax Fixer

```python
from src.noodlecore.ai_agents.syntax_fixer_agent import SyntaxFixerAgent
from src.noodlecore.ai_agents.enhanced_ai_integration import EnhancedAIIntegration

# Create enhanced syntax fixer
class EnhancedSyntaxFixer:
    def __init__(self):
        self.base_fixer = SyntaxFixerAgent()
        self.enhanced_integration = EnhancedAIIntegration({
            "mode": "hybrid"
        })
    
    def fix_syntax(self, file_path, error_info):
        # Use enhanced analysis
        enhanced_result = self.enhanced_integration.process_syntax_task(
            f"Fix syntax in {file_path}",
            {
                "file_path": file_path,
                "error_info": error_info
            }
        )
        
        # Apply base fixer with enhanced insights
        if enhanced_result['success']:
            return self.base_fixer.fix_syntax(
                file_path,
                enhanced_result['combined_result']['recommended_fix']
            )
        
        return {"success": False, "error": "Enhanced analysis failed"}

# Usage
enhanced_fixer = EnhancedSyntaxFixer()
result = enhanced_fixer.fix_syntax(
    "/project/src/main.nc",
    {"error": "Missing semicolon", "line": 15}
)
```

## Configuration

### TRM Configuration

```python
trm_config = {
    "reasoning_engine": "enhanced",
    "max_recursion_depth": 10,  # Maximum depth for recursive problem solving
    "reasoning_timeout": 60,    # Timeout for reasoning operations (seconds)
    "cache_size": 1000,         # Size of reasoning cache
    "knowledge_graph_enabled": True,
    "knowledge_graph_config": {
        "max_nodes": 10000,
        "max_relationships": 50000,
        "similarity_threshold": 0.7
    },
    "reasoning_strategies": [
        "deductive",
        "inductive", 
        "abductive",
        "analogical",
        "causal",
        "hybrid"
    ]
}
```

### AERE Configuration

```python
aere_config = {
    "timeout": 120,              # General timeout for operations
    "max_retries": 3,            # Maximum retry attempts
    "cache_size": 500,           # Size of resolution cache
    "guardrails_enabled": True,
    "explainability_enabled": True,
    "providers": {
        "openai": {
            "enabled": True,
            "api_key": "your_openai_key",
            "model": "gpt-4",
            "max_tokens": 2000
        },
        "openrouter": {
            "enabled": True,
            "api_key": "your_openrouter_key",
            "model": "anthropic/claude-2"
        },
        "lm_studio": {
            "enabled": True,
            "endpoint": "http://localhost:1234",
            "model": "local-model"
        },
        "z_ai": {
            "enabled": True,
            "api_key": "your_z_ai_key",
            "model": "code-analyzer"
        }
    },
    "guardrail_config": {
        "content_safety": True,
        "code_safety": True,
        "decision_validation": True,
        "compliance_checking": True
    }
}
```

### Orchestrator Configuration

```python
orchestrator_config = {
    "max_concurrent": 10,           # Maximum concurrent tasks
    "timeout": 300,                  # Task timeout (seconds)
    "load_balance_strategy": "round_robin",
    "failover_enabled": True,
    "health_check_interval": 30,     # Health check interval (seconds)
    "agent_timeout": 60,             # Agent response timeout
    "retry_attempts": 3,             # Retry attempts for failed tasks
    "load_balancing": {
        "strategy": "round_robin",
        "weights": {},               # Agent weights for weighted balancing
        "health_threshold": 0.7      # Minimum health score for agent selection
    }
}
```

## Performance Monitoring

### Metrics Collection

The enhanced system provides comprehensive metrics for all components:

```python
# Get TRM metrics
trm_metrics = trm.get_metrics()
print(f"TRM Success Rate: {trm_metrics['success_rate']}")
print(f"Average Reasoning Time: {trm_metrics['average_reasoning_time']}")
print(f"Cache Hit Rate: {trm_metrics['cache_hit_rate']}")

# Get AERE metrics
aere_metrics = aere.get_metrics()
print(f"AERE Success Rate: {aere_metrics['success_rate']}")
print(f"Provider Usage: {aere_metrics['provider_usage']}")
print(f"Guardrail Violations: {aere_metrics['guardrail_violations']}")

# Get orchestrator metrics
orchestrator_metrics = orchestrator.get_orchestrator_status()
print(f"Registered Agents: {orchestrator_metrics['registered_agents']}")
print(f"Active Tasks: {orchestrator_metrics['active_tasks']}")
print(f"Load Balance Efficiency: {orchestrator_metrics['load_balance_efficiency']}")

# Get integration metrics
integration_metrics = integration.get_metrics()
print(f"Total Tasks: {integration_metrics['total_tasks']}")
print(f"Successful Tasks: {integration_metrics['successful_tasks']}")
print(f"Performance Score: {integration_metrics['performance_score']}")
```

### Performance Optimization

```python
# Configure caching
trm.configure({"cache_size": 2000})
aere.configure({"cache_size": 1000})

# Configure timeouts
trm.configure({"reasoning_timeout": 30})
aere.configure({"timeout": 60})

# Configure load balancing
orchestrator.configure({
    "load_balance_strategy": "fastest_response",
    "health_threshold": 0.8
})

# Configure performance monitoring
integration.configure({
    "performance_monitoring": True,
    "metrics_collection_interval": 60
})
```

## Troubleshooting

### Common Issues and Solutions

#### 1. TRM Reasoning Timeout

**Problem**: TRM reasoning operations are timing out.

**Solution**:

```python
# Increase timeout
trm.configure({"reasoning_timeout": 120})

# Reduce recursion depth
trm.configure({"max_recursion_depth": 5})

# Enable caching
trm.configure({"cache_size": 2000})
```

#### 2. AERE Provider Connection Issues

**Problem**: Unable to connect to AI providers.

**Solution**:

```python
# Check provider status
provider_status = aere.get_provider_status()
print(provider_status)

# Disable problematic providers
aere.configure({
    "providers": {
        "openai": {"enabled": False},
        "openrouter": {"enabled": True}
    }
})

# Update API keys
aere.configure({
    "providers": {
        "openai": {"api_key": "new_api_key"}
    }
})
```

#### 3. Orchestrator Load Balancing Issues

**Problem**: Tasks not being distributed evenly.

**Solution**:

```python
# Check agent health
agent_status = orchestrator.get_agent_status("agent_id")
print(agent_status)

# Change load balancing strategy
orchestrator.configure({"load_balance_strategy": "least_connections"})

# Adjust agent weights
orchestrator.configure({
    "load_balancing": {
        "weights": {
            "agent_1": 1.5,
            "agent_2": 1.0
        }
    }
})
```

#### 4. Integration Performance Issues

**Problem**: Overall integration performance is slow.

**Solution**:

```python
# Enable caching
integration.configure({"caching_enabled": True})

# Optimize mode
integration.configure({"mode": "trm_only"})  # or "aere_only"

# Reduce concurrent operations
integration.configure({"max_concurrent": 5})
```

## API Reference

### TRM Agent API

#### Methods

- `start()`: Start the TRM agent
- `stop()`: Stop the TRM agent
- `reason_about_task(description, context)`: Analyze and reason about a task
- `execute_task(task)`: Execute a task based on reasoning
- `get_status()`: Get agent status
- `get_metrics()`: Get performance metrics
- `configure(config)`: Update configuration
- `get_knowledge_graph_status()`: Get knowledge graph status

#### Returns

```python
# reason_about_task return format
{
    "status": True,
    "reasoning": "Detailed reasoning explanation",
    "task_complexity": "medium|high|critical",
    "recommendations": [
        {
            "action": "recommended_action",
            "confidence": 0.85,
            "explanation": "Why this action is recommended"
        }
    ],
    "subtasks": [...],  # For complex tasks
    "confidence": 0.85
}
```

### AERE Engine API

#### Methods

- `start()`: Start the AERE engine
- `stop()`: Stop the AERE engine
- `analyze_error(error_info)`: Analyze an error
- `generate_resolution(error_context)`: Generate a resolution
- `apply_resolution(resolution)`: Apply a resolution
- `get_status()`: Get engine status
- `get_provider_status()`: Get provider status
- `get_metrics()`: Get performance metrics
- `configure(config)`: Update configuration

#### Returns

```python
# analyze_error return format
{
    "status": True,
    "analysis": {
        "error_type": "syntax_error",
        "severity": "medium",
        "root_cause": "missing_semicolon",
        "affected_components": ["function_definition"],
        "impact_assessment": "low"
    }
}

# generate_resolution return format
{
    "status": True,
    "resolution": {
        "steps": [
            {
                "action": "add_semicolon",
                "line": 15,
                "explanation": "Add semicolon to complete statement"
            }
        ],
        "code_changes": [...],
        "confidence": 0.9
    },
    "provider": "openai",
    "trace": {...}
}
```

### Orchestrator API

#### Methods

- `register_agent(agent_info)`: Register a new agent
- `unregister_agent(agent_id)`: Unregister an agent
- `submit_task(task_type, task_data, priority)`: Submit a task
- `get_task_status(task_id)`: Get task status
- `get_agent_status(agent_id)`: Get agent status
- `get_orchestrator_status()`: Get orchestrator status
- `configure(config)`: Update configuration

#### Returns

```python
# get_task_status return format
{
    "task_id": "task_123",
    "status": "pending|assigned|running|completed|failed",
    "assigned_agent": "agent_456",
    "progress": 0.75,
    "result": {...},  # For completed tasks
    "error": null     # For failed tasks
}
```

### Enhanced Integration API

#### Methods

- `process_syntax_task(description, context)`: Process a syntax task
- `get_integration_status()`: Get integration status
- `get_metrics()`: Get performance metrics
- `configure(config)`: Update configuration

#### Returns

```python
# process_syntax_task return format
{
    "success": True,
    "integration_mode": "hybrid",
    "trm_analysis": {...},
    "aere_analysis": {...},
    "combined_result": {
        "recommended_fix": "add_semicolon",
        "confidence": 0.92,
        "explanation": "Combined analysis result"
    },
    "performance": {
        "trm_time": 1.2,
        "aere_time": 2.1,
        "total_time": 3.3
    }
}
```

## Conclusion

The enhanced TRM and AERE implementation provides powerful AI capabilities for NoodleCore with comprehensive orchestration, monitoring, and backward compatibility. The modular design allows for flexible configuration and integration with existing systems while maintaining high performance and reliability.

For more information and examples, refer to the unit tests in `test_enhanced_trm_aere_integration.py` and the implementation files in the `src/noodlecore/` directory.
