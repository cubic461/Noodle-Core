# Changelog - Noodle Improvement Pipeline (NIP) v2

## [2.0.0] - 2026-01-17

### 🎉 Major Release - Intelligent Self-Improvement

NIP v2 represents a significant leap forward from v1, adding **intelligent planning**, **automated patch generation**, and **API safety validation** to the solid foundation of shadow-mode self-improvement.

### Added - Core Components

#### 1. Planner Interface (noodle-brain/src/core/planner.py)
**~450 lines** - Intelligent task planning and coordination

**Features:**
- Task prioritization based on risk and impact
- Automatic dependency resolution between tasks
- Multi-task execution planning
- Cycle detection in dependencies
- Impact and risk assessment
- Execution plan validation

**Classes:**
- `Planner` - Abstract base class for planners
- `SimplePlanner` - Basic implementation with heuristic prioritization
- `ExecutionPlan` - Structured execution plan with dependencies
- `Dependency` - Task dependency representation
- `TaskPriority` - Priority levels (CRITICAL, HIGH, MEDIUM, LOW)

**Usage:**
```python
from noodlebrain.core.planner import create_planner, plan_improvements

planner = create_planner("simple")
plan = planner.plan_improvement(tasks)
```

#### 2. PatchAgent Interface (noodle-agents-trm/patch_agent.py)
**~550 lines** - Automated patch generation with LLM integration

**Features:**
- Automated patch generation from improvement goals
- Multiple generation strategies (LLM-based, bugfix, refactoring, hybrid)
- Patch validation and format checking
- Confidence scoring for generated patches
- Patch refinement based on feedback
- LLM integration hooks (ready for production)

**Classes:**
- `PatchAgent` - Abstract base class for patch agents
- `SimplePatchAgent` - Template-based patch generation
- `LLMPatchAgent` - LLM-based generation (stub for production)
- `PatchResult` - Generated patch with metadata
- `PatchRequest` - Patch generation request
- `PatchStrategy` - Generation strategy types

**Usage:**
```python
from noodle_agents_trm.patch_agent import create_patch_agent, PatchRequest

agent = create_patch_agent("simple")
result = agent.generate_patch(request)
```

#### 3. LSP Facts Gate (noodle-core/src/noodlecore/improve/lsp_facts_gate.py)
**~650 lines** - API break detection using Language Server Protocol

**Features:**
- Symbol extraction from code (functions, classes, methods)
- Public API identification
- Signature change detection
- Breaking change identification
- Change severity assessment (BREAKING, MAJOR, MINOR, PATCH)
- Multi-language support (extensible via LSP)

**Classes:**
- `LspFactsGate` - Abstract base class for LSP validation
- `SimpleLspFactsGate` - Regex-based implementation (production: use actual LSP)
- `SymbolInfo` - Extracted symbol information
- `APIChange` - Detected API change
- `LSPAnalysisResult` - Complete analysis results

**Usage:**
```python
from noodlecore.improve.lsp_facts_gate import validate_no_api_break

result = validate_no_api_break(old_files, new_files)
```

#### 4. Enhanced Policy Gates (noodle-core/src/noodlecore/improve/policy_v2.py)
**~250 lines** - Policy gates with LSP integration

**Features:**
- LSP-based API break detection rule
- Enhanced validation workflows
- Integration with v1 policy gates
- Strict and lenient modes

**Classes:**
- `LSPAPIBreakRule` - Policy rule for API break detection
- `EnhancedPolicyGate` - Extended policy gate with v2 features

**Usage:**
```python
from noodlecore.improve.policy_v2 import create_enhanced_policy_gate

gate = create_enhanced_policy_gate(strict_mode=True, enable_lsp=True)
result = gate.validate_with_lsp(old_files, new_files)
```

### Added - Documentation

#### docs/improve_v2.md
Comprehensive v2 documentation including:
- Architecture overview with diagrams
- Feature comparison (v1 vs v2)
- Component API references
- Workflow examples
- Configuration guide
- Migration guide

**Sections:**
- What's New in v2
- Architecture v2
- Feature Comparison Table
- Component Documentation
- Usage Examples
- API Reference
- Migration Guide
- Limitations and Future Enhancements

### Added - Examples

#### Examples in v2 Documentation
- Automated improvement with planning
- Automated patch generation
- API safety validation
- Multi-task coordination

### Changed

#### Enhanced noodle.json Structure
Added `v2` configuration section:

```json
{
  "improve": {
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

### Security Enhancements

**v2 Security Features:**
- ✅ API break detection prevents accidental breaking changes
- ✅ Confidence scoring for automated patches
- ✅ Signature validation for public APIs
- ✅ Dependency resolution prevents conflicting changes
- ✅ All v1 security features maintained (sandbox, allowlist, manual promotion)

### Backward Compatibility

**✅ Fully Backward Compatible with v1**
- All v1 features continue to work unchanged
- v2 features are opt-in via configuration
- No breaking changes to existing APIs
- Gradual migration path from v1 to v2

### Performance

**Performance Improvements:**
- Optimized symbol extraction algorithms
- Efficient dependency resolution (O(n²) worst case)
- Cached validation results
- Parallel-ready architecture (for v3)

### Developer Experience

**New Developer Capabilities:**
- Programmatic task planning API
- Automated patch generation workflow
- API safety validation before deployment
- Enhanced debugging with detailed analysis results

### Code Quality

**Statistics:**
- **~1,900 lines** of new production code
- **4 new modules** across 3 packages
- **Full type hints** throughout
- **Comprehensive docstrings** for all classes and methods
- **Abstract base classes** for extensibility

### Testing

**Test Coverage:**
- Unit tests for all v1 core (existing)
- Integration tests for v2 components (TODO in Phase 6)
- Example-based documentation testing

### Limitations (v2)

**NOT implemented in v2:**
- ❌ Parallel worktree execution (planned for v3)
- ❌ Performance regression detection (planned for v3)
- ❌ Multi-candidate comparison (planned for v3)
- ❌ A/B testing framework (planned for v3)
- ❌ Full LLM integration (hooks in place, needs API keys)
- ❌ Real LSP server integration (using regex-based extraction)

**What v2 DOES provide:**
- ✅ Complete planning infrastructure
- ✅ Patch generation framework (ready for LLM)
- ✅ API break detection (regex-based, extensible to LSP)
- ✅ Enhanced policy gates with LSP validation
- ✅ Dependency resolution
- ✅ Patch refinement workflow

### Migration Notes

**From v1 to v2:**
1. Review `docs/improve_v2.md` for new features
2. Enable v2 features in `noodle.json` (optional)
3. Import new modules as needed
4. No code changes required - v2 is opt-in

**No Breaking Changes:**
- All v1 APIs unchanged
- All v1 CLI commands unchanged
- All v1 storage formats unchanged
- v2 features are additive only

### Future Enhancements (v3)

**Planned for v3:**
- Full LLM integration for patch generation
- Real LSP server integration (pyls, typescript-language-server, etc.)
- Parallel worktree execution
- Performance benchmarking and regression detection
- Multi-candidate comparison and ranking
- A/B testing framework
- Automatic rollback on failure
- Enhanced analytics and metrics

### Dependencies

**New Dependencies:**
- No new external dependencies required
- All v2 features use standard library
- LLM integration hooks ready for providers (OpenAI, Anthropic, etc.)

### Contributors

This release was built with:
- Intelligent planning algorithms
- Automated code generation frameworks
- Language Server Protocol concepts
- Industry best practices for API safety

### Summary

NIP v2 transforms the Noodle Improvement Pipeline from a **manual, shadow-mode testing system** into an **intelligent, semi-automated self-improvement platform**.

**Key Achievements:**
- 🧠 **Intelligent Planning** - Automatic task prioritization and coordination
- 🤖 **Automated Patch Generation** - LLM-ready code generation framework
- 🔍 **API Safety** - Automatic detection of breaking API changes
- 🔄 **Enhanced Workflows** - Patch refinement and validation
- 🎯 **Production-Ready Foundation** - Ready for full LLM and LSP integration

**From v1 to v2:**
- v1: Manual patch creation → v2: Automated generation
- v1: Single-task execution → v2: Multi-task planning
- v1: Basic validation → v2: LSP-based API safety
- v1: No dependency tracking → v2: Automatic resolution

**Next Steps:**
- Integrate LLM providers for patch generation
- Connect real LSP servers for accurate symbol extraction
- Add parallel execution for faster improvements
- Implement performance regression detection

---

## Migration Path

```
v1 (Manual)
    ↓
v2 (Semi-Automated) ← We are here
    ↓
v3 (Fully Automated)
```

**v2 represents the critical bridge** between manual testing and fully automated self-improvement, providing:
- Safety through validation
- Intelligence through planning
- Automation through generation
- Confidence through API safety checks

Ready for production use with manual oversight, paving the way for v3's full automation! 🚀
