# Python IDE Implementation Plan for Noodle

## DEPRECATED - Legacy Implementation (2025-09-19)
This plan for the Python-based Noodle IDE (using Tkinter/CustomTkinter and Plotly) is now legacy. The project has reverted to the Tauri (Rust backend) + React/TypeScript (frontend) architecture for better performance, cross-platform support, and advanced 3D capabilities.

- **Rationale**: Python prototype was a quick MVP for testing concepts, but web technologies better suit the 3D Noodle Brain and plugin ecosystem. Tauri dependencies have been resolved.
- **Current Focus**: See noodle-ide/IMPLEMENTATION_PLAN.md for the active Tauri/React plan, including phases for core setup, 3D visualization, and plugins.
- **Archive Status**: Retain for historical reference; no further development here. Files in noodle-ide-python/ are prototypes.

For ongoing GUI improvements, refer to the updated roadmap in memory-bank/noodle-ide-roadmap.md and decision-003-ide-reversion-to-tauri-react.md.

## Introduction
This document outlines the implementation of a Python-based IDE for the Noodle project, replacing the current Rust/React/Tauri stack to address dependency and setup issues. The focus is on a Minimum Viable Product (MVP) with core editing and project management features, prioritized integration of the "Noodle Brain" 3D visualization for dependency and performance analysis. This plan aligns with the project's principles of transparency, iterative development, and quality.

The Python IDE will enable rapid development on Noodle itself, with future optimizations using Noodle's runtime (e.g., parallel graph computations). Fallback to alternatives (e.g., PyQt or reverting to Tauri) is noted if needed.

**Rationale**: Tauri setup causes prolonged issues (hours of dependency resolution). Python leverages the project's Python-centric ecosystem (noodle-dev/src), reducing barriers. See [decision-002-python-ide-migration.md](decision-002-python-ide-migration.md) for details.

**Timeline Estimate**: 1 week for MVP + Brain View (3 days core, 4 days Brain).

## Architecture Overview
- **Directory Structure**: New `noodle-ide-python/` alongside `noodle-ide/` (Tauri as legacy).
  - `main.py`: Entry point with CustomTkinter window.
  - `components/`: Widgets (editor.py, tree_view.py, brain_view.py).
  - `core/`: Reuse/adapt from `noodle-ide/core/` (event_bus.py, plugin_manager.py).
  - `integrations/`: Hooks to noodle-dev (compiler, runtime, distributed_os).
  - `viz/`: Brain View logic (graph_model.py, plotly_embed.py).
- **Framework**: CustomTkinter (modern Tkinter) for UI shell; Plotly for 3D Brain embedding.
- **Data Flow**:
  - Project load: Scan via project_manager.py → Build graph with NetworkX.
  - Execution: Hook into runtime (event_bus) for real-time updates.
  - Brain View: 3D render with interactions → Trigger actions (rebuild/optimize via ai_orchestrator.py).
- **Integration with Noodle**:
  - Static analysis: Use compiler/parser.py and indexing/symbol_index.py.
  - Dynamic: Subscribe to distributed_runtime.py and performance_profiler.py for metrics.
  - Optimization: Offload to Noodle bytecode (e.g., via interop/python_bridge.py).

## Key Features
### MVP Core (Priority 1)
- Editor: Syntax-highlighted text widget for .noodle files (load/save, basic keywords like `def`, `matrix`).
- Tree View: File/project browser integrated with enhanced_project_manager.py.
- Core Integrations: Event bus for communication; buttons for compile (noodle.compiler) / run (subprocess on cli).
- Panels: Console for output/errors.

### Noodle Brain View (Priority 2 - Integrated Early)
- **Visualization**: 3D graph of scripts as nodes (size: LOC/runtime load), edges (dependencies/comms, color: intensity/latency).
  - Distributed nodes: Visible as sub-clusters (local/remote via cluster_manager.py), with performance overlays (heatmaps for CPU/network).
- **Data Model**:
  - Nodes: Scripts + remote nodes; attributes: size (centrality/load), color (status: green=low load, red=high).
  - Edges: Imports/calls (static) + data-flow (dynamic from network_protocol.py); color gradient (blue=low intensity, red=high).
  - Metrics: From memory_profiler.py, real_time_monitor.py (update on execution).
- **Rendering**: Plotly 3D scatter (embedded in Tkinter frame via webbrowser); force-directed layout (nx.spring_layout(dim=3)) for "brain" effect. Transparency via alpha blending.
- **Interactivity**:
  - Hover: Tooltips with details (name, metrics, bottlenecks).
  - Click on node/edge: Popup menu (CustomTkinter Toplevel) with options:
    - "Bouw na met Noodle": Rebuild via deployment_cli.py.
    - "Optimaliseer": Run memory_optimization_manager.py or ai_orchestrator.py for auto-fixes.
    - Additional: "Profile" (launch profiler), "Debug", "Deploy Distributed".
  - Navigation: Zoom/rotate; click node → Open in editor.
- **Updates**: Real-time via event_bus subscriptions (post-execution refresh).

### Extensions (Post-MVP)
- Plugins: BrainView as plugin (via plugin_manager.py).
- Advanced Panels: Deployment manager, AI autocomplete.
- Optimization: Wrap hot paths (e.g., graph layout) in Noodle for parallel execution.

## Dependencies
- Python stdlib: tkinter, webbrowser.
- External (pip install): customtkinter (UI), plotly (3D viz), networkx (graphs).
- Noodle internals: Import from noodle-dev/src (compiler, runtime, distributed_os).
- Total size: ~50MB; package with PyInstaller for standalone exe.

## Todo List
- [ ] Setup: Create `noodle-ide-python/` and basic main.py with CustomTkinter window.
- [ ] Implement Editor: Text widget with load/save .noodle files and simple syntax highlighting.
- [ ] Implement Tree View: File browser with integration to project_manager.py.
- [ ] Add core integrations: Event bus for component communication, buttons for compile/run via noodle-dev.
- [ ] Basic panels: Console output and error display.
- [ ] Brain View - Data: Implement graph-model with NetworkX for nodes/edges (static deps + distributed nodes).
- [ ] Brain View - Rendering: Embed 3D Plotly visualization in panel with sizes/colors for performance.
- [ ] Brain View - Interactivity: Add click/hover handling with popup menu (rebuild/optimize options).
- [ ] Test MVP + Brain: Load project, run execution, check updates and interaction.
- [ ] Optimization prep: Identify hot paths and plan Noodle-wrappers.
- [ ] Extension: Add plugins and advanced panels (e.g., deployment manager).
- [ ] Packaging: Create executable with PyInstaller and test on multiple platforms.

## Integration with Existing Plans
- **Roadmaps**: Fits in noodle-ide-roadmap.md as "Phase 1: Python MVP" (Week 1 milestone). Updates phased_implementation_plan.md for IDE → Runtime flow.
- **Architecture**: Builds on noodle-ide-tree-graph-view-architecture.md (evolves 2D to 3D Brain). Hooks into runtime_enhancement_plan.md for performance viz.
- **Workflow/Roles**: Assign to Developer Experience Engineer (GUI) and Performance Engineer (Brain metrics). See role_assignment_system.md.
- **Quality/Testing**: Add Brain tests to testing_and_coverage_requirements.md (e.g., interaction mocks, render perf <1s).
- **DX Improvements**: Listed in developer_experience_improvements.md as bottleneck tool.
- **Decisions**: decision-002-python-ide-migration.md rationalizes switch.
- **Solution DB**: Entry in solution_database.md for "Tauri dependency resolution" → Python GUI (rated 5/5).
- **Changelog**: Logged in changelog.md under "IDE Migration".

## Risks and Fallbacks
- **Risks**: Embedding issues (Plotly in Tkinter); real-time perf (mitigate with caching via database_query_cache.py); data accuracy (validate with unit tests).
- **Fallbacks**: If CustomTkinter limited → PyQt6. If Plotly slow → 2D Matplotlib first, then VTK. Revert to Tauri if Python perf bottlenecks (post-Noodle optimization).
- **Metrics for Success**: MVP runnable in <5min setup; Brain identifies a bottleneck in test project (e.g., distributed_poc).

## Next Steps
1. Create this doc and update linked files (Act Mode start).
2. Implement MVP core.
3. Integrate Brain View.
4. Test with noodle-dev examples.
5. Review/iterate based on usage.

Last Updated: 2025-09-18
