# Decision 003: Revert Noodle IDE to Tauri/React Architecture

## Context
Following Decision 002 (2025-09-18), a temporary migration to Python/Tkinter was implemented to address Tauri setup dependencies and enable rapid prototyping. The Python prototype (noodle-ide-python/) successfully demonstrated core MVP features (editor, tree view, basic run integration) and tested 3D Brain concepts with Plotly/NetworkX. However, limitations emerged: restricted scalability for advanced web-based 3D visualization (e.g., Three.js interactivity), challenges in plugin ecosystem with hybrid Python/Rust, and suboptimal performance for real-time distributed Noodle features.

Recent resolutions to Tauri's dependency issues (e.g., via updated Cargo/Node setups and Docker fallbacks) make reverting feasible. This aligns with the original vision in noodle-ide/IMPLEMENTATION_PLAN.md for a native, web-tech-powered IDE.

## Decision
Revert to the Tauri (Rust backend for native performance and IPC) + React/TypeScript (frontend for flexible UI and Three.js integration) architecture. Deprecate the Python prototype as legacy/reference material. All future development occurs in the noodle-ide/ directory.

## Pros of Reversion
- **Advanced 3D Capabilities**: Three.js/React Three Fiber enables rich, GPU-accelerated Noodle Brain visualization (force-directed graphs, real-time updates, multi-user collab).
- **Plugin Ecosystem**: Web standards facilitate dynamic loading, hot-reload, and marketplace (aligned with Phase 2 in IMPLEMENTATION_PLAN.md).
- **Performance & Cross-Platform**: Tauri's native shell provides low-overhead desktop app; better integration with Noodle's Rust interop (e.g., FFI for distributed runtime).
- **Developer Experience**: Leverages familiar web tools (Vite, React hooks); resolves Python's embedding issues for complex viz.
- **Alignment**: Supports AI integration (e.g., via js_bridge.py) and self-updating features more seamlessly.

## Cons and Mitigations
- **Setup Complexity**: Initial Tauri deps may still challenge; mitigate with detailed setup guide in docs/getting-started.md and Docker compose for dev env.
- **Migration Overhead**: Port any useful Python concepts (e.g., event bus logic) to Rust/React; use as reference without full rewrite.
- **3D Learning Curve**: Three.js is powerful but complex; start with React Three Fiber templates from Phase 1 deliverables.

## Implementation
- **Immediate Steps**:
  - Archive noodle-ide-python/ (add README.md as legacy).
  - Update deprecated docs (completed: decision-002 and python-ide-implementation-plan.md).
  - Resume from Phase 1 in noodle-ide/IMPLEMENTATION_PLAN.md (core Tauri setup, 3D foundation).
- **Timeline**: 1-2 days for doc cleanup and setup validation; then proceed to GUI enhancements (theming, BrainView interactivity).
- **Resources**: Assign to Developer Experience Engineer (frontend) and Lead Architect (Tauri backend). Test with distributed_poc example.
- **Fallback**: If Tauri issues recur, hybrid approach (Tauri shell + embedded Python for specific plugins).

## Impact
- **Positive**: Enables full realization of Noodle IDE roadmap (3D Brain, AI agents, plugins). Improves long-term maintainability.
- **On Existing Work**: Python prototype insights (e.g., event bus patterns) ported to React equivalents. No code loss; files retained in memory-bank.
- **Metrics**: Track DX via setup time (<10min), Brain render perf (>60fps), plugin load time (<1s).

See updated [noodle-ide-roadmap.md](../noodle-ide-roadmap.md) for adjusted phases. Log progress in memory-bank/project_status_2025-09.md.

Date: 2025-09-19
Author: Cline (as Developer Experience Engineer)
