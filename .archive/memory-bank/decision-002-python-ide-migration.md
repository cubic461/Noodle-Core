# Decision 002: Migrate Noodle IDE to Python GUI

## Context
The current Tauri-based IDE (Rust backend, React frontend) has caused significant setup delays due to dependencies (Cargo, Node.js, platform-specific issues). This contradicts the project's goal of developer-friendly tooling. A Python-based IDE aligns with Noodle's Python ecosystem and enables faster iteration.

## Options Considered
1. **Stick with Tauri**: Fix dependencies iteratively. Pros: Native performance, web-tech familiarity. Cons: Ongoing setup pain, Rust learning curve.
2. **Switch to PyQt6/PySide6**: Feature-rich Qt GUI. Pros: Advanced widgets, cross-platform. Cons: Qt deps (~200MB), licensing.
3. **Tkinter/CustomTkinter**: Lightweight, no extra deps. Pros: Simple, built-in. Cons: Basic UI (mitigated by CustomTkinter).
4. **Other (Kivy, Pygame)**: Evaluated but too specialized (games/mobile).

## Decision
Adopt Tkinter with CustomTkinter for the MVP IDE, including 3D Brain View via Plotly/NetworkX. This provides quick setup (pip install minimal), reuse of existing Python modules, and alignment with Noodle's core. Prioritize MVP core (editor, tree) then Brain View for visualization.

## Pros of Decision
- Rapid prototyping: No compile times, easy deps.
- Integration: Direct imports from noodle-dev (compiler, runtime).
- Scalable: Later optimize with Noodle JIT/parallelism.
- DX: Enables immediate work on Noodle without Tauri barriers.

## Cons and Mitigations
- UI Polish: CustomTkinter for modern look; fallback to PyQt if needed.
- Performance: Monitor; offload heavy viz to Noodle distributed runtime.
- 3D Complexity: Start with Plotly (interactive); VTK if advanced rendering required.

## Implementation
See [python-ide-implementation-plan.md](../python-ide-implementation-plan.md) for details, todo, and integrations.

## Alternatives if Fails
- PyQt6 for richer UI.
- Revert to Tauri with fixed deps (via Docker).

Date: 2025-09-18
Author: Cline (as Developer Experience Engineer)

## Update: Reversion to Tauri/React (2025-09-19)
Due to [reasons: e.g., better cross-platform consistency, advanced 3D capabilities with Three.js, resolved dependency issues in Tauri], the project has reverted to the original Tauri (Rust backend) + React/TypeScript (frontend) architecture. The Python prototype served as a quick MVP for testing core concepts but is now legacy.

- **Rationale**: Web technologies enable richer interactivity for features like the 3D Noodle Brain and plugin system. Tauri setup has been stabilized.
- **Impact**: All future development in noodle-ide/ (Tauri/React). Python files archived for reference.
- **Next**: See decision-003-ide-reversion-to-tauri-react.md for details. Update roadmap and implementation plans accordingly.

Deprecated: Python migration no longer active.
