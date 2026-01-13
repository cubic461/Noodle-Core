# AGENTS.md

This file provides guidance to agents when working with code in this repository.

- Canonical desktop IDE is [`native_gui_ide.py`](noodle-core/src/noodlecore/desktop/ide/native_gui_ide.py:45)::NativeNoodleCoreIDE.
- All IDE launch scripts (batch/PowerShell/anywhere) MUST delegate to [`launch_native_ide.py`](noodle-core/src/noodlecore/desktop/ide/launch_native_ide.py:1) → `NativeNoodleCoreIDE` as the single source of truth; other IDE scripts are considered legacy/experimental and should not introduce alternate entrypoints.
- Core NoodleCore logic must live under `noodle-core/src/noodlecore` (including CLI, DB, AI agents, utilities); placing core code elsewhere breaks discovery and conventions.
- Environment/config variables must use the `NOODLE_` prefix (e.g. NOODLE_ENV, NOODLE_PORT); never hard-code secrets or unprefixed credentials.
- HTTP APIs must bind to `0.0.0.0:8080` and include a `requestId` (UUID v4) in responses to stay compatible with existing infrastructure and docs.
- Database access must go through pooled, parameterized helpers under `noodle-core/src/noodlecore/database` (max 20 connections, ~30s timeout); do not create ad-hoc connection logic.
- Prefer existing AI/agent and role management infrastructure (`noodle-core/src/noodlecore/ai_agents`, `noodle-core/src/noodlecore/ai/role_manager.py`) instead of introducing parallel frameworks.
- All new vector/memory features must integrate with the unified memory/role/agent architecture defined in `docs/` and related specs; avoid one-off per-agent memory stores.
