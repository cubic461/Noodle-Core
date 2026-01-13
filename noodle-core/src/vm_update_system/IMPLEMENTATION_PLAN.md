# VM Update System - Week 1 Implementation Plan

## 🎯 Goal for Week 1
**Build the foundation**: DeployableUnit + Basic UpdateManager + Simple Validation

### Daily Breakdown

#### Day 1 (Monday) - Scaffolding & Unit Tests
- [ ] Set up test infrastructure for vm_update_system
- [ ] Create `test_deployable_unit.py` with basic unit tests
- [ ] Test lifecycle states: BUILDING → VALIDATED → LOADED → ACTIVE
- [ ] Test error handling and state transitions
- [ ] Verify metadata serialization

#### Day 2 (Tuesday) - NBC Runtime Integration Hook
- [ ] Create a simple mock NBC runtime
- [ ] Test `DeployableUnit.load()` integration
- [ ] Implement basic bytecode loading
- [ ] Add module isolation (side-by-side loading)
- [ ] Test concurrent version loading

#### Day 3 (Wednesday) - Validation Pipeline (Core)
- [ ] Implement core validation gates:
  - Gate 1: Source compilation check
  - Gate 2: Contract extraction
  - Gate 3: Capability analysis
- [ ] Create `ValidationResult` aggregation
- [ ] Add comprehensive error messages
- [ ] Unit test each gate

#### Day 4 (Thursday) - UpdateManager Basic Flow
- [ ] Implement `submit_update()` workflow
- [ ] Add `UpdateHandle` tracking
- [ ] Create validation worker (background thread)
- [ ] Implement synchronous `wait_for_validation()`
- [ ] Add basic error propagation

#### Day 5 (Friday) - CLI & Developer Experience
- [ ] Create CLI entry points:
  - `noodle update <file>`
  - `noodle status <unit>`
- [ ] Implement status reporting
- [ ] Add serialization for handle persistence
- [ ] Create simple demo script

#### Weekend - Integration Testing
- [ ] End-to-end test with real Noodle source file
- [ ] Stress test with parallel updates
- [ ] Failure scenario testing
- [ ] Document lessons learned

---

## 🎯 Success Criteria (End of Week 1)

### Must Have
✅ DeployableUnit loads and runs in mock NBC runtime
✅ UpdateManager validates and tracks 10 concurrent updates
✅ Validation pipeline catches basic errors (compilation, contracts)
✅ CLI commands work for basic scenarios
✅ Unit tests cover 80%+ of core functionality

### Nice to Have
✅ Performance benchmarks (< 1 second validation)
✅ Integration with actual NoodleLang compiler
✅ Basic rollback mechanism (even if manual)
✅ Documentation with before/after examples

### Stretch Goals
🚀 Canary traffic switching (manual control)
🚀 Metrics collection hooks
🚀 Event stream for observability

---

## 🛠️ Implementation Tasks

### Task 1: Extend DeployableUnit

```python
def test_deployable_unit_basic():
    """Test basic unit lifecycle"""
    unit = DeployableUnit(
        unit_id="test-service",
        version="1.0.0",
        bytecode=b"mock_bytecode",
    )
    
    # Test state transitions
    assert unit.state == UnitState.BUILDING
    assert unit.is_healthy == True
    
    # Load into runtime
    mock_runtime = MockRuntime()
    success = unit.load(mock_runtime)
    assert success == True
    assert unit.state == UnitState.LOADED
    
    # Activate
    unit.activate()
    assert unit.is_active == True
```

### Task 2: Mock NBC Runtime

```python
class MockNBCRuntime:
    """Mock runtime for integration testing"""
    
    def __init__(self):
        self.modules = {}
        self.active_modules = {}
    
    def load_module(self, bytecode: bytes, module_id: str):
        """Simulate module loading"""
        module = MockModule(bytecode, module_id)
        self.modules[module_id] = module
        return module
    
    def unload_module(self, module_id: str):
        """Simulate module unloading"""
        if module_id in self.modules:
            del self.modules[module_id]
    
class MockModule:
    """Mock loaded module"""
    def __init__(self, bytecode, module_id):
        self.bytecode = bytecode
        self.module_id = module_id
        self.entrypoint = None
    
    def set_entrypoint(self, fn_name: str):
        self.entrypoint = fn_name
```

### Task 3: Validation Pipeline

```python
class ValidationEngine:
    """Core validation pipeline"""
    
    def validate(
        self, 
        source_path: Path, 
        existing_unit: Optional[DeployableUnit]
    ) -> ValidationResult:
        """
        Run all validation gates
        """
        result = ValidationResult(passed=False)
        
        # Gate 1: Compilation
        try:
            bytecode = self._compile_source(source_path)
        except CompilationError as e:
            result.errors.append(f"Compilation failed: {e}")
            return result
        
        # Gate 2: Contract extraction
        try:
            contract = self._extract_contract(source_path, bytecode)
        except Exception as e:
            result.errors.append(f"Contract extraction failed: {e}")
            return result
        
        # Gate 3: Compatibility check
        if existing_unit:
            if not contract.is_compatible_with(existing_unit.contract):
                result.errors.extend(contract.errors)
                return result
        
        # Gate 4: Capability analysis
        capabilities = self._extract_capabilities(source_path)
        result.passed = True
        return result
```

### Task 4: Basic CLI

```python
# noodle_update.py (CLI entry point)

def cmd_update(args):
    """Handle 'noodle update' command"""
    source_path = Path(args.source_file)
    unit_id = args.unit_id or source_path.stem
    
    # Initialize manager
    runtime = get_runtime()  # Get or create NBC runtime
    manager = UpdateManager(runtime)
    
    # Submit update
    handle = manager.submit_update(
        source_path=source_path,
        unit_id=unit_id,
        new_version=args.version or "1.0.0",
        submitted_by=getpass.getuser()
    )
    
    print(f"Update submitted: {handle.id}")
    print(f"Status: {handle.state.value}")
    print("\nFollow progress:")
    print(f"  noodle status {unit_id}")
    print(f"  noodle metrics {unit_id}")
    
    if args.wait:
        # Wait for completion
        handle = wait_for_completion(manager, handle)
        if handle.state == UpdateState.VALIDATION_FAILED:
            print(f"❌ Validation failed: {handle.error}")
            return 1
        print("✅ Validation passed - safe to activate")


def cmd_status(args):
    """Handle 'noodle status' command"""
    manager = UpdateManager(get_runtime())
    status = manager.get_status(args.unit_id)
    print(json.dumps(status, indent=2))
```

### Task 5: Integration Test

```python
# test_integration_basic_update.py

def test_basic_update_flow():
    """End-to-end test of update pipeline"""
    
    # Setup
    runtime = MockNBCRuntime()
    manager = UpdateManager(runtime)
    
    # Submit update
    source_file = write_test_source("""
        def hello():
            return "world"
    """)
    
    handle = manager.submit_update(
        source_path=source_file,
        unit_id="test-service",
        new_version="1.0.0"
    )
    
    # Wait for validation
    handle = wait_for_state(manager, handle, [UpdateState.VALIDATED, UpdateState.VALIDATION_FAILED])
    
    # Check results
    if handle.state == UpdateState.VALIDATED:
        print("✅ Basic update validation passed")
    else:
        print(f"❌ Validation failed: {handle.error}")
```

---

## 🧪 Testing Strategy

### Unit Tests (per file)
```bash
pytest noodle-core/src/vm_update_system/test_deployable_unit.py -v
pytest noodle-core/src/vm_update_system/test_update_manager.py -v
```

### Integration Tests
```bash
pytest tests/vm_update_system/test_integration_*.py -v
```

### End-to-End Test
```bash
python demo/demo_update_system.py
```

---

## 📚 Developer Workflow

### Getting Started

1. **Setup environment**:
```bash
cd noodle-core
pip install -e .
```

2. **Run tests**:
```bash
pytest src/vm_update_system/ -v
```

3. **Try basic update**:
```bash
# Create a simple Noodle source file
cat > test.nc << 'EOF'
def main():
    return "Hello, Noodle!"
EOF

# Submit update
python -m noodle_update test.nc

# Check status
python -m noodle_status test
```

---

## 🚀 Next Week (Week 2)

After Week 1 foundation:
- **Canary deployment** with traffic switching
- **Health monitoring** and metrics
- **Auto-rollback** on error thresholds
- **Dependency graph** management
- **State snapshot** infrastructure

---

## 📊 Progress Tracking

Update this section daily:

**Monday**: 🔲 Scaffolding complete
**Tuesday**: 🔲 NBC integration working
**Wednesday**: 🔲 Validation pipeline tested
**Thursday**: 🔲 UpdateManager functional
**Friday**: 🔲 CLI commands working
**Weekend**: 🔲 Integration tests passing

**Overall Progress**: 0/100 🛠️

---

**Ready to start Week 1! Let's build it.** 🚀
