# Noodle Improvement Pipeline (NIP) v2

## What's New in v2

NIP v2 builds upon the solid foundation of v1 with powerful new capabilities for automated improvement, intelligent planning, and API safety.

### 🎯 Key Enhancements

1. **🧠 Intelligent Planning (noodle-brain)**
   - Task prioritization based on impact and risk
   - Dependency resolution between tasks
   - Multi-task coordination and execution plans
   - Cycle detection and validation

2. **🤖 Automated Patch Generation (noodle-agents-trm)**
   - LLM-based code patch generation
   - Patch validation and refinement
   - Confidence scoring
   - Multiple generation strategies (bugfix, refactoring, hybrid)

3. **🔍 API Break Detection (LSP Integration)**
   - Automatic detection of breaking API changes
   - Symbol extraction and signature analysis
   - Public API validation
   - Change severity assessment

## Architecture v2

```
┌─────────────────────────────────────────────────────────────┐
│                     NIP v2 Architecture                      │
└─────────────────────────────────────────────────────────────┘

┌──────────────┐
│ Task Request │
└──────┬───────┘
       │
       ▼
┌──────────────┐     ┌──────────────┐
│   Planner    │────▶│ Patch Agent  │  v2: Intelligent planning
│              │     │              │     and automated generation
└──────┬───────┘     └──────┬───────┘
       │                    │
       ▼                    ▼
┌──────────────┐     ┌──────────────┐
│ Task Runner  │────▶│  LSP Gate    │  v2: API break detection
│              │     │              │     and validation
└──────┬───────┘     └──────┬───────┘
       │                    │
       ▼                    │
┌──────────────┐             │
│ Sandbox      │◀────────────┘
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Policy Gates │  v2: Enhanced with LSP
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Evidence     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Manual Promote│
└──────────────┘
```

## Feature Comparison

| Feature | v1 | v2 |
|---------|----|----|
| Shadow-mode execution | ✅ | ✅ |
| Manual promotion | ✅ | ✅ |
| Workspace snapshots | ✅ | ✅ |
| Sandbox execution | ✅ | ✅ |
| Basic policy gates | ✅ | ✅ |
| **Task planning** | ❌ | ✅ |
| **Dependency resolution** | ❌ | ✅ |
| **Automated patch generation** | ❌ | ✅ |
| **LLM integration** | ❌ | ✅ |
| **API break detection** | ❌ | ✅ |
| **LSP integration** | ❌ | ✅ |
| Patch refinement | ❌ | ✅ |
| Multi-task coordination | ❌ | ✅ |

## v2 Components

### 1. Planner (noodle-brain)

The Planner analyzes improvement requests and creates optimized execution plans.

```python
from noodlebrain.core.planner import create_planner

# Create planner
planner = create_planner("simple")

# Create execution plan
tasks = [
    {
        "id": "task-1",
        "title": "Optimize parser",
        "goal": {"type": "performance", "description": "20% faster"},
        "risk": "high",
        "scope": {"repo_paths": ["noodle-lang/src/parser"]}
    },
    {
        "id": "task-2", 
        "title": "Fix memory leak",
        "goal": {"type": "bugfix", "description": "Fix leak in compiler"},
        "risk": "critical",
        "scope": {"repo_paths": ["noodle-core/src/compiler"]}
    }
]

plan = planner.plan_improvement(tasks)

print(f"Plan ID: {plan.plan_id}")
print(f"Execution order: {plan.tasks}")
print(f"Dependencies: {plan.dependencies}")
print(f"Estimated duration: {plan.estimated_duration} minutes")
```

**Key Features:**
- Automatic task prioritization
- Dependency detection (based on overlapping scope)
- Cycle detection in dependencies
- Impact and risk assessment

### 2. Patch Agent (noodle-agents-trm)

The PatchAgent automatically generates code patches to address improvement tasks.

```python
from noodle_agents_trm.patch_agent import create_patch_agent, PatchRequest

# Create patch agent
agent = create_patch_agent("simple")

# Create patch request
request = PatchRequest(
    task_id="task-1",
    goal={
        "type": "bugfix",
        "description": "Fix memory leak in allocator"
    },
    files=["noodle-core/src/memory/allocator.py"],
    context={"current_issue": "Memory not freed on error"}
)

# Generate patch
result = agent.generate_patch(request)

print(f"Patch:\n{result.patch}")
print(f"Strategy: {result.strategy}")
print(f"Confidence: {result.confidence}")
print(f"Validation: {result.status}")
```

**Patch Generation Strategies:**
- `LLM_BASED`: Use LLM for intelligent patch generation
- `BUGFIX`: Focused on fixing specific bugs
- `REFACTORING`: Code restructuring without behavior change
- `HYBRID`: Combination of approaches

**Patch Refinement:**
```python
# Refine patch based on feedback
feedback = ["Add error handling", "Include docstring"]
refined = agent.refine_patch(result, feedback)

print(f"Refined confidence: {refined.confidence}")
print(f"Refinement count: {refined.metadata['refinement_count']}")
```

### 3. LSP Facts Gate (noodle-core)

The LSP Facts Gate detects breaking API changes using Language Server Protocol.

```python
from noodlecore.improve.lsp_facts_gate import validate_no_api_break

# Old code (before changes)
old_files = {
    "noodle-core/src/api.py": """
def public_function(x: int) -> str:
    return str(x)

class PublicClass:
    def method(self):
        pass
"""
}

# New code (after changes)
new_files = {
    "noodle-core/src/api.py": """
def public_function(x: int, y: int = 0) -> str:  # Signature changed!
    return str(x + y)

class PublicClass:
    def method(self, param: str = ""):  # Signature changed!
        pass
    
    def new_method(self):  # New addition
        pass
"""
}

# Validate
result = validate_no_api_break(old_files, new_files)

print(f"Passed: {result.passed}")
print(f"Breaking changes: {len(result.breaking_changes)}")
print(f"Symbols added: {result.public_symbols_added}")
print(f"Symbols removed: {result.public_symbols_removed}")

for change in result.breaking_changes:
    print(f"  - {change.description}")
```

**Detection Capabilities:**
- Public function/class extraction
- Signature change detection
- Breaking change identification
- Severity assessment (BREAKING, MAJOR, MINOR, PATCH)

### 4. Enhanced Policy Gates

v2 includes enhanced policy gates that integrate LSP validation.

```python
from noodlecore.improve.policy_v2 import create_enhanced_policy_gate

# Create enhanced gate with LSP validation
gate = create_enhanced_policy_gate(
    name="my_gate",
    strict_mode=True,  # Fail on breaking changes
    enable_lsp=True    # Enable LSP validation
)

# Validate candidate
result = gate.validate_with_lsp(
    old_files=old_content,
    new_files=new_content,
    additional_context={"candidate_id": "candidate-123"}
)

print(f"Passed: {result.passed}")
print(f"Score: {result.score}")
print(f"Details:\n{result.details}")
```

## v2 Workflow Examples

### Example 1: Automated Improvement with Planning

```bash
# 1. Create multiple improvement tasks
noodle improve task create --file examples/improve/task_parser_optimization.json
noodle improve task create --file examples/improve/task_memory_leak_fix.json

# 2. Plan the improvements (v2)
noodle improve plan --tasks task-1,task-2

# Output:
# Plan ID: plan-0
# Execution order:
#   1. task-2 (Fix memory leak) - CRITICAL priority
#   2. task-1 (Optimize parser) - HIGH priority
# Dependencies:
#   - task-1 has soft dependency on task-2 (overlapping scope)
# Estimated duration: 45 minutes
# Risk assessment: high

# 3. Execute the plan
noodle improve run-plan --plan plan-0

# 4. Review results
noodle improve candidate evidence --id <generated-id>
```

### Example 2: Automated Patch Generation

```python
from noodle_agents_trm.patch_agent import generate_patch

# Generate patch automatically
result = generate_patch(
    task_id="task-1",
    goal={
        "type": "performance",
        "description": "Optimize hot loop in parser"
    },
    files=["noodle-lang/src/parser/lexer.py"],
    agent_type="llm"  # Use LLM for generation
)

# Review patch
print(result.patch)
print(f"Confidence: {result.confidence * 100}%")

# Apply and test
if result.confidence > 0.7:
    # Apply patch
    # Run tests
    # Promote if successful
    pass
```

### Example 3: API Safety Validation

```python
from noodlecore.improve.policy_v2 import validate_no_api_break

# Before deploying candidate, validate no API breaks
result = validate_no_api_break(
    old_files=snapshot_content,
    new_files=patched_content,
    strict_mode=True
)

if result.passed:
    print("✓ Safe to promote - no breaking API changes")
else:
    print(f"✗ Breaking changes detected:")
    for change in result.breaking_changes:
        print(f"  - {change.description}")
    # Do not promote
```

## Configuration v2

Update `noodle.json` to enable v2 features:

```json
{
  "improve": {
    "rootDir": ".noodle/improve",
    "v2": {
      "enablePlanner": true,
      "enablePatchAgent": true,
      "enableLSPGate": true,
      "plannerType": "simple",
      "patchAgentType": "llm",
      "lspStrictMode": true
    }
  }
}
```

## API Reference

### Planner API

```python
class Planner:
    def plan_improvement(tasks, constraints) -> ExecutionPlan
    def prioritize_tasks(tasks) -> List[TaskPriority]
    def resolve_dependencies(tasks) -> List[Dependency]
    def validate_plan(plan) -> bool
```

### PatchAgent API

```python
class PatchAgent:
    def generate_patch(request) -> PatchResult
    def validate_patch(patch, context) -> Tuple[bool, List[str]]
    def refine_patch(patch, feedback) -> PatchResult
    def estimate_confidence(patch, context) -> float
```

### LspFactsGate API

```python
class LspFactsGate:
    def extract_symbols(file_path, content) -> List[SymbolInfo]
    def compare_symbols(old, new) -> List[APIChange]
    def detect_breaking_changes(changes) -> List[APIChange]
    def validate_no_api_break(old, new) -> LSPAnalysisResult
```

## Migration from v1 to v2

v2 is fully backward compatible with v1. All v1 features continue to work unchanged.

To enable v2 features:

1. **Enable v2 components** in `noodle.json`
2. **Import v2 modules** in your code
3. **Use new APIs** for planning, patch generation, and LSP validation

No breaking changes - opt-in adoption!

## Limitations (v2)

**Still TODO in v2:**
- Parallel worktree execution
- Performance regression detection
- Multi-candidate comparison
- A/B testing framework
- Full LLM integration (hooks are in place)

**What v2 adds:**
- ✅ Intelligent task planning
- ✅ Automated patch generation (with LLM hooks)
- ✅ API break detection via LSP
- ✅ Enhanced policy gates
- ✅ Dependency resolution
- ✅ Patch refinement workflow

## Future v3 Enhancements

- Full LLM integration for patch generation
- Parallel execution across worktrees
- Performance benchmarking and regression detection
- Multi-candidate comparison and ranking
- A/B testing framework
- Automatic rollback on failure

## Contributing

See main CONTRIBUTING.md guidelines.

v2 contributions should:
1. Extend planner algorithms
2. Add new patch generation strategies
3. Enhance LSP symbol extraction
4. Improve policy gate rules
5. Add integration tests

## License

MIT License - See main LICENSE file.
