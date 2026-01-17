# Noodle Improvement Pipeline (NIP) v1

## Overview

The Noodle Improvement Pipeline (NIP) is a **shadow-mode self-improvement system** that enables safe, controlled experimentation with code changes. It provides a structured workflow for proposing, testing, and promoting improvements to the Noodle codebase without automatic deployment.

### Key Principles

1. **Shadow Mode Only** - No automatic production deployment in v1
2. **Manual Promotion** - All promotions require explicit human approval
3. **Evidence-Based** - All decisions backed by test results and metrics
4. **Safe Sandboxing** - Workspace snapshots and isolated execution
5. **Policy Gates** - Configurable validation rules

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     NIP v1 Architecture                      │
└─────────────────────────────────────────────────────────────┘

┌──────────────┐
│ Task Spec    │  JSON definition of improvement goal
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Task Runner  │  Creates snapshot, generates candidate
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Sandbox      │  Applies patch, runs verification
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Policy Gates │  Validates results (tests, LOC, etc.)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Evidence     │  Stores logs, metrics, outcomes
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Manual Promote│ Human reviews and promotes
└──────────────┘
```

## Quick Start

### 1. Create a Task

Create a task specification JSON file:

```json
{
  "id": "my-task-1",
  "title": "Optimize Parser Performance",
  "goal": {
    "type": "performance",
    "metric": "parsing_speed",
    "target_delta": "+20%",
    "description": "Improve parser by 20%"
  },
  "scope": {
    "repo_paths": ["noodle-lang/src/parser"],
    "selectors": ["*.py"]
  },
  "constraints": {
    "max_loc_changed": 150,
    "no_new_deps": true,
    "no_public_api_break": true
  },
  "verification": {
    "commands": ["make test", "make bench:parser"],
    "required_green": true
  },
  "risk": "medium",
  "mode": "shadow"
}
```

### 2. Create and Run the Task

```bash
# Create task from file
noodle improve task create --file examples/improve/task_parser_optimization.json

# Or create via CLI
noodle improve task create --title "Fix bug" --goal "Fix memory leak" --risk low

# List all tasks
noodle improve task list

# Run a task
noodle improve run --task my-task-1

# Dry run to see what would happen
noodle improve run --task my-task-1 --dry-run
```

### 3. Review Candidates

```bash
# List candidates for a task
noodle improve candidate list --task my-task-1

# Show candidate details
noodle improve candidate show --id candidate-123

# View evidence (test results, logs)
noodle improve candidate evidence --id candidate-123
```

### 4. Promote a Candidate

```bash
# Promote a verified candidate (manual only)
noodle improve candidate promote --id candidate-123 --reason "Passes all tests and shows 25% improvement"
```

## Task Specification

### Required Fields

- **id** (string): Unique task identifier
- **title** (string): Human-readable title
- **goal** (object): Improvement objective
  - **type** (string): "performance", "bugfix", "feature", "refactor"
  - **metric** (string): What's being measured
  - **target_delta** (string): Expected change (e.g., "+20%", "-30%")
  - **description** (string): Detailed description

### Optional Fields

- **scope** (object): What files to affect
  - **repo_paths** (string[]): Paths to include
  - **selectors** (string[]): File patterns (glob)

- **constraints** (object): Limitations
  - **max_loc_changed** (number): Max lines of code changed
  - **no_new_deps** (boolean): Disallow new dependencies
  - **no_public_api_break** (boolean): Disallow breaking changes

- **verification** (object): How to verify
  - **commands** (string[]): Commands to run
  - **required_green** (boolean): All commands must succeed

- **risk** (string): "low", "medium", "high"
- **mode** (string): Must be "shadow" (v1)
- **patchFile** (string|null): Path to patch file (optional)

## Storage Structure

```
.noodle/improve/
├── tasks/              # Task specifications
│   └── <taskId>.json
├── candidates/         # Candidate data
│   └── <candidateId>.json
├── evidence/           # Test results, logs
│   └── <candidateId>/
│       └── evidence.json
├── promotions/         # Promotion records
│   └── <candidateId>.json
├── snapshots/          # Workspace snapshots
│   └── <snapshotId>/
│       └── snapshot.zip
└── runs/               # Run metadata
    └── <runId>.json
```

## Configuration

Add to `noodle.json`:

```json
{
  "improve": {
    "rootDir": ".noodle/improve",
    "snapshotDir": ".noodle/improve/snapshots",
    "allowedCommands": [
      "make test",
      "make lint",
      "pytest",
      "npm test"
    ],
    "networkEnabled": false,
    "maxLocChangedDefault": 200,
    "snapshotRetention": {
      "maxSnapshots": 10,
      "maxAgeDays": 7
    }
  }
}
```

View current config:

```bash
noodle improve config show
```

## Policy Gates (v1)

NIP v1 implements these validation gates:

1. **Command Success Gate** - All verification commands must exit with code 0
2. **LOC Delta Gate** - Changes must not exceed `max_loc_changed` limit
3. **Dependency Gate** (TODO) - Detect new dependencies via lockfile changes
4. **API Break Gate** (TODO) - Validate no breaking public API changes

## Security

### Sandbox Execution

- Commands run in isolated snapshot directory
- Network access disabled by default
- Allowlist-based command filtering
- No automatic filesystem writes outside snapshot

### Allowlist

Only allowlisted commands can run in verification:

```json
"allowedCommands": [
  "make test",
  "make lint",
  "pytest",
  "npm test",
  "npm run build"
]
```

To add new commands, update the `allowedCommands` array in `noodle.json`.

## CLI Reference

### Task Commands

```bash
noodle improve task create --file <task.json>
noodle improve task create --title <title> --goal <goal> [--risk <level>]
noodle improve task list [--status <status>]
```

### Run Commands

```bash
noodle improve run --task <taskId> [--dry-run]
```

### Candidate Commands

```bash
noodle improve candidate list --task <taskId>
noodle improve candidate show --id <candidateId>
noodle improve candidate evidence --id <candidateId>
noodle improve candidate promote --id <candidateId> [--reason <reason>]
```

### Config Commands

```bash
noodle improve config show
```

## Examples

See `examples/improve/` for example task specifications:

- `task_parser_optimization.json` - Performance improvement
- `task_memory_leak_fix.json` - Bug fix
- `task_lsp_feature.json` - New feature

## Limitations (v1)

**NOT implemented in v1:**

- ❌ Automatic promotion to production
- ❌ Parallel worktree support
- ❌ LLM-based code generation within pipeline
- ❌ Network access in sandbox (default off)
- ❌ Dependency gate (placeholder only)
- ❌ API break gate (placeholder only)
- ❌ Automatic merging of promoted candidates

**What v1 DOES provide:**

- ✅ Shadow-mode execution
- ✅ Manual promotion workflow
- ✅ Workspace snapshots
- ✅ Sandbox execution with allowlist
- ✅ Evidence collection (logs, metrics)
- ✅ Policy gates (command success, LOC)
- ✅ File-based storage
- ✅ CLI interface

## Future Enhancements (v2+)

- Planner integration (noodle-brain)
- Patch agent integration (noodle-agents-trm)
- LSP facts extraction for API break detection
- Parallel worktree execution
- Automatic patch generation via LLM
- Performance regression detection
- Multi-candidate comparison
- A/B testing framework

## Contributing

When adding new features to NIP:

1. Update JSON schemas in `noodle-core/src/noodlecore/improve/spec/`
2. Add tests in `noodle-core/tests/improve/`
3. Update CLI commands in `noodle-cli-typescript/src/improve.ts`
4. Document changes in this file

## License

MIT License - See main LICENSE file.
