# Changelog - Noodle Improvement Pipeline (NIP) v1

## [1.0.0] - 2026-01-17

### Added

#### Core Implementation (noodle-core)
- **Noodle Improvement Pipeline (NIP)** - Shadow-mode self-improvement system
  - Data models: TaskSpec, Candidate, Evidence, PromotionRecord
  - File-based storage adapter with JSON persistence
  - Workspace snapshot functionality with zip-based storage
  - Sandbox execution with allowlist-based security
  - Policy gates: command success, LOC delta (with TODO hooks for deps/API)
  - Diff application and LOC counting utilities
  - Task runner orchestrator for full pipeline execution
  - JSON Schema specifications for all data contracts

- **New directories:**
  - `noodle-core/src/noodlecore/improve/` - Core NIP modules
  - `noodle-core/src/noodlecore/improve/spec/` - JSON schemas
  - `noodle-core/src/noodlecore/sandbox/` - Sandbox execution
  - `.noodle/improve/` - Storage structure
  - `examples/improve/` - Example task specifications
  - `tests/improve/` - Unit tests

#### CLI Implementation (noodle-cli-typescript)
- **Improve command group** with 8 subcommands:
  - `noodle improve task create` - Create improvement tasks
  - `noodle improve task list` - List all tasks
  - `noodle improve run` - Execute a task
  - `noodle improve candidate list` - List candidates for a task
  - `noodle improve candidate show` - Show candidate details
  - `noodle improve candidate evidence` - View test evidence
  - `noodle improve candidate promote` - Manually promote candidates
  - `noodle improve config show` - Display NIP configuration

#### Configuration
- **noodle.json** - Added `improve` section:
  - `rootDir` - Storage directory (default: `.noodle/improve`)
  - `snapshotDir` - Snapshot storage location
  - `allowedCommands` - Allowlist for sandbox execution
  - `networkEnabled` - Network access control (default: false)
  - `maxLocChangedDefault` - Default LOC limit (default: 200)
  - `snapshotRetention` - Snapshot cleanup policy

#### Documentation
- **docs/improve.md** - Comprehensive NIP documentation
  - Architecture overview
  - Quick start guide
  - Task specification reference
  - CLI reference
  - Security model
  - Examples and limitations

- **README.md** - Added NIP section with quick start

#### Examples
- `examples/improve/task_parser_optimization.json` - Performance improvement task
- `examples/improve/task_memory_leak_fix.json` - Bug fix task
- `examples/improve/task_lsp_feature.json` - Feature addition task

#### Tests
- **tests/improve/test_models.py** - Unit tests for data models
  - TaskSpec serialization/deserialization
  - Candidate serialization/deserialization
  - Evidence serialization/deserialization
  - PromotionRecord serialization/deserialization
  - Model validation and enum testing

### Changed

- Updated TypeScript CLI to import and register improve commands
- Modified project structure to support self-improvement workflows

### Security

- Sandbox execution with allowlist-based command filtering
- Network access disabled by default in sandbox
- Workspace snapshots for safe experimentation
- Manual promotion only - no automatic deployment
- No filesystem writes outside sandbox directory

### Limitations (v1)

**NOT implemented:**
- Automatic promotion to production
- Parallel worktree support
- LLM-based code generation within pipeline
- Network access in sandbox (intentionally disabled)
- Dependency gate detection (placeholder only)
- API break detection (placeholder only)
- Automatic merging of promoted candidates

**What v1 provides:**
- Shadow-mode execution with manual promotion
- Workspace snapshots and rollback
- Sandbox execution with allowlist security
- Evidence collection (logs, metrics)
- Basic policy gates (command success, LOC)
- File-based storage and CLI interface

### Migration Notes

No migration required. NIP is fully additive and does not modify existing functionality.

### Future Enhancements (v2+)

- Planner integration (noodle-brain)
- Patch agent integration (noodle-agents-trm)
- LSP facts extraction for API break detection
- Parallel worktree execution
- Automatic patch generation via LLM
- Performance regression detection
- Multi-candidate comparison
- A/B testing framework

---

## Summary

NIP v1 provides a **safe, shadow-mode self-improvement system** for Noodle-Core. It enables controlled experimentation with code changes through:

1. **Task-based workflow** - Define improvement goals with constraints
2. **Sandboxed execution** - Test changes in isolated snapshots
3. **Policy gates** - Automated validation (tests, LOC limits)
4. **Manual promotion** - Human approval required for deployment
5. **Full audit trail** - Evidence storage and promotion records

All changes are tracked, logged, and require explicit human approval before any deployment.
