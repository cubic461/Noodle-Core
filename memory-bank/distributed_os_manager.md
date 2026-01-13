# Distributed OS Manager for Noodle IDE

## Architecture Overview

The Distributed OS Manager enables multi-node resource management in the Noodle runtime, supporting actor model via Ray, AI-driven task placement, and fault tolerance. Key components in `src/noodle/distributed_os/`:

- **node_manager.py**: Handles node registration/discovery (gRPC/heartbeat), health checks. Integrates with `cluster_manager.py` for fault detection.
- **resource_allocator.py**: AI-driven placement using `workflow_engine` suggestions; load balancing via `placement_engine.py`. Monitors node loads, selects based on thresholds.
- **os_scheduler.py**: Schedules tasks across nodes with Ray actors for workers; supports hot-swap FFI libs (dynamic reload). Handles failover by re-allocating via allocator.

### Integrations
- **Ray**: Actor model for distributed execution; node affinity via placement groups.
- **cluster_manager.py**: Fault tolerance (rescheduling on failure).
- **workflow_engine**: AI suggestions for optimal placement.
- **placement_engine.py**: Load balancing algorithms.

Text-based diagram:
```
Master (Laptop) --> node_manager (register/discover) --> resource_allocator (AI/load balance) --> os_scheduler (Ray actors, hot-swap)
                  |
                  v
Workers (PC) <--> gRPC/Heartbeat <--> cluster_manager (failover)
```

## Usage

1. **Setup**:
   - Install Ray: `pip install ray`.
   - Start master: Initialize `NodeManager`, `ResourceAllocator`, `OSScheduler`.
   - Register workers: On PCs, run node server (gRPC port 50051); master registers via IP/port.
   - Enable heartbeats for health monitoring.

2. **Run Example** (`examples/distributed_os/multi_node_matrix_compute.noodle`):
   - On master: `python -m noodle run multi_node_matrix_compute.noodle`.
   - Distributes matrix multiply sub-tasks to workers (e.g., PC1/PC2).
   - Aggregates results; requires NumPy FFI.

3. **Hot-Swap FFI**: Scheduler reloads libs dynamically for runtime updates.

## Testing

- **Directory**: `tests/distributed_os/test_distributed_os.py`.
- **Coverage**: Targets 90%+ (unit: registration/health; integration: allocation/scheduling; docker sim for multi-node).
- **Key Tests**:
  - Node registration/health checks.
  - Failover: Re-allocates on unhealthy nodes.
  - Allocation accuracy: Selects low-load nodes, prefers AI suggestions.
  - Ray integration: Mocks actor scheduling.
  - Docker: Simulates master/worker containers.
- Run: `pytest tests/distributed_os/ --cov=src/noodle/distributed_os --cov-report=html` (aims 90%+ line/branch coverage).

## Readiness
Components ready for IDE integration (laptop master/PC workers). Future: Full gRPC protos, real AI models.

## Documentation Links
- [Distributed Runtime](../docs/features/distributed_runtime.md): AI/OS feature overview with comprehensive architecture details.
- [ALE Phase 3 FFI](../docs/features/ale_phase3_ffi.md): FFI for distributed computations with production deployment examples.
- [Security Hardening Guide](../docs/guides/deployment/security_hardening.md): JWT authentication and input sanitization.
- [Production Setup Guide](../docs/guides/deployment/production_setup.md): Docker and Kubernetes deployment.
- [Scaling Guide](../docs/guides/deployment/scaling.md): Ray integration and AI-driven resource allocation.
- [Distributed Deployment](distributed_deployment.md): Production guides.
- [ALE FFI Integration](ale_ffi_integration.md): Knowledge for FFI in OS contexts.
