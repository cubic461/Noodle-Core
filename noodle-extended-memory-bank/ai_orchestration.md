# AI Orchestration System for Noodle

## Overview
The AI orchestration system coordinates multi-agent workflows using role-based task routing from role_assignment_system.md, FFI for AI decisions (Torch/ML suggestions from solution_database.md), and secure pub-sub messaging. It extends agents-server.js for JS/Python integration and integrates with cluster_manager.py for distributed execution. Security uses JWT auth; errors handled via error_handler.py.

## Architecture
- **Agents Server (agents-server.js)**: Express.js with WebSocket pub-sub, JWT middleware, task routing endpoints (/api/task-route, /api/tasks/:role, /api/role-assign), role matrix for assignment.
- **AI Orchestrator (noodle-dev/src/noodle/ai_orchestrator/ai_orchestrator.py)**: Main class integrating queue, FFI, workflow, error handler; methods: submit_task, get_task_status.
- **Task Queue (task_queue.py)**: Async deque with pub-sub to server (HTTP/WS publish on events like queued/updated); MQL-based (JSON dicts).
- **FFI AI Bridge (ffi_ai_bridge.py)**: Extends CRustBridge/JSBridge for validation; Torch placeholder for ML inference; caches suggestions with hash integrity; queries solution_database.md ratings.
- **Workflow Engine (workflow_engine.py)**: Processes tasks, auto-triggers workflows (e.g., code gen -> test), role assignment from matrix, endpoints to agents-server.js, fault-tolerant with cluster_manager.py events.
- **Error Handler (noodle-dev/src/noodle/utils/error_handler.py)**: Logs errors with JWT handling, recovery suggestions, history tracking.

## Usage
Initialize: `orchestrator = AIOrchestrator(config); await orchestrator.start()`

Submit task:
```python
task_data = {'type': 'code_implementation', 'description': 'Gen matrix func'}
task_id = await orchestrator.submit_task(task_data)
status = await orchestrator.get_task_status(task_id)
```

Example workflow (code gen + test) in noodle-dev/examples/ai_orchestration/ai_orchestration_example.py.

## FFI Integration
- Uses existing C/Rust for crypto/math in AI validation.
- Torch placeholder for ML role/suggestion; extend with model loading for production (requires torch).

## Security & Validation
- JWT in JS for auth; Python error handler catches token errors.
- Pub-sub channels role-specific; error events published.
- All tasks validated with AI suggestions before delegation.

## Tests
noodle-dev/tests/ai_orchestration/test_ai_orchestration.py: Covers task submission, AI suggestions, error handling, workflow flow (90%+ line/branch coverage via pytest-asyncio, mocks).

## Readiness for Distributed OS Manager
Integrates with cluster_manager.py: Tasks scheduled via load balancer; FFI/NBC dispatch for distributed AI calls. Ready for scaling; add node registration for agents.

## Documentation Links
- [ALE Phase 3 FFI](../docs/features/ale_phase3_ffi.md): FFI integration with AI orchestration including distributed examples.
- [Distributed Runtime](../docs/features/distributed_runtime.md): Comprehensive AI/OS feature coverage with architecture details.
- [Security Hardening Guide](../docs/guides/deployment/security_hardening.md): JWT authentication and input sanitization.
- [Production Setup Guide](../docs/guides/deployment/production_setup.md): Docker and Kubernetes deployment.
- [Scaling Guide](../docs/guides/deployment/scaling.md): Ray integration and AI-driven resource allocation.
- [ALE FFI Integration](ale_ffi_integration.md): Knowledge entry for FFI patterns.
- [Distributed Deployment](distributed_deployment.md): Production setup linking to guides.

## Files Added/Updated
- noodle-dev/src/noodle/ai_orchestrator/__init__.py
- noodle-dev/src/noodle/ai_orchestrator/ai_orchestrator.py
- noodle-dev/src/noodle/ai_orchestrator/task_queue.py
- noodle-dev/src/noodle/ai_orchestrator/ffi_ai_bridge.py
- noodle-dev/src/noodle/ai_orchestrator/workflow_engine.py
- noodle-dev/examples/ai_orchestration/ai_orchestration_example.py
- noodle-dev/tests/ai_orchestration/test_ai_orchestration.py
- agents-server.js (endpoints/WebSocket for integration)
