# Actor Model Design for Noodle Distributed Runtime

## Overview
The actor model provides native concurrency for distributed AI workloads in Noodle. Actors are lightweight, stateful entities that communicate via asynchronous message passing, enabling scalable parallelism without shared state. This integrates with existing distributed components for placement, scheduling, and fault tolerance.

Key Goals:
- Support stateful actors with automatic placement and recovery.
- Enable efficient message passing across nodes.
- Integrate with scheduler for task distribution.
- Provide automatic recovery via checkpointing and migration.
- Optimize for AI workloads (e.g., matrix operations, database I/O).

## Architecture

### Actor Representation
- **Actor Class**: Base class in `noodle-dev/src/noodle/runtime/distributed/actors.py`.
  - Attributes: `actor_id` (unique UUID), `state` (dict for internal state), `mailbox` (queue for messages), `behavior` (callable handling messages), `placement` (TensorPlacement-like for actor location).
  - Methods: `send_message(msg)` (async enqueue to mailbox), `receive_message()` (async dequeue), `update_state(new_state)` (with validation), `handle_message(msg)` (behavior execution).
- **State Management**: Actors maintain state in memory; periodic checkpointing to database backend for recovery.
- **Message Format**: Dict with `sender_id`, `type` (e.g., 'compute', 'query'), `payload` (e.g., mathematical object), `timestamp`.

### Integration Points

#### 1. Placement Engine (`placement_engine.py`)
- Extend `ConstraintType` with `ACTOR_STATEFUL` for actors requiring persistent state (e.g., memory >= state_size, replication for high availability).
- New placement strategy `ACTOR_AFFINITY` to co-locate communicating actors (data locality score based on message patterns).
- `place_actor(actor_id, state_size, constraints)`: Returns `ActorPlacement` (extends TensorPlacement) with target_nodes for actor deployment.
- Automatic re-placement on node failure, preserving state via checkpoint.

#### 2. Fault Tolerance (`fault_tolerance.py`)
- Extend `FailureEvent` with `actor_id` field.
- New `RecoveryStrategy.ACTOR_RESTART`: Checkpoint actor state, migrate to new node, restore and resume.
- `create_actor_checkpoint(actor_id, state)`: Serialize state (pickle + checksum), store in database.
- `recover_actor(actor_id)`: Restore state, recreate mailbox, notify connected actors of relocation.
- Integration: On `NODE_FAILURE`, trigger actor migration if actors are placed there; use `migrate_task` for actor tasks.

#### 3. Scheduler (`scheduler.py`)
- Actors treated as persistent tasks: `Task` with `is_actor=True`, infinite duration until shutdown.
- Extend `SchedulingStrategy` with `ACTOR_BALANCED` for even distribution of actor workloads.
- Async task optimization: Schedule actor messages as non-blocking futures in `executor`.
- `schedule_actor_messages(actor_id)`: Poll mailbox and dispatch messages concurrently.

#### 4. Network Protocol (`network_protocol.py`)
- Extend for actor messaging: `send_actor_message(target_actor_id, msg)` over gRPC/QUIC with serialization.
- Support for batched messages and zero-copy for large payloads (e.g., matrices).

#### 5. Compiler Integration (for Async/Await)
- Syntax: `async def func(): await db_query()` parsed in `parser.py`, analyzed in `semantic_analyzer.py`.
- Code Generation: `code_generator.py` emits NBC opcodes `ASYNC_BEGIN`, `AWAIT`, `ASYNC_END`; runtime translates to non-blocking calls.
- Runtime: In `nbc_runtime`, `await` yields control to scheduler for I/O (database, network).

### Implementation Phases
1. **Core Actor Module**: Create `actors.py` with base Actor class and mailbox.
2. **Placement Integration**: Add actor-specific constraints and placement methods.
3. **Fault Tolerance Integration**: Extend recovery for actors with state checkpointing.
4. **Scheduler Optimization**: Add actor task handling and async message dispatch.
5. **Messaging Protocol**: Implement cross-node message passing.
6. **Compiler Extensions**: Add async/await syntax support.
7. **Testing**: Unit/integration tests for actor creation, messaging, recovery.
8. **Documentation**: Update docs/architecture/distributed_runtime_system.md and features/async_actors.md.

### Example Usage
```python
from noodle.runtime.distributed.actors import Actor

class AIWorker(Actor):
    def __init__(self, actor_id):
        super().__init__(actor_id)
        self.state = {"model": load_model()}

    async def handle_message(self, msg):
        if msg["type"] == "compute":
            result = self.state["model"].predict(msg["payload"])
            await self.send_message("coordinator", {"type": "result", "data": result})

# Creation and placement
worker = AIWorker("worker_1")
placement = placement_engine.place_actor("worker_1", state_size=1024*1024, constraints=[PlacementConstraint(ACTOR_STATEFUL)])
scheduler.register_actor(worker, placement)
```

### Risks and Mitigations
- **State Consistency**: Use transactions in database for checkpointing; mitigate races with actor locks.
- **Message Ordering**: Implement sequence numbers in messages; use fault_tolerance for retries.
- **Performance Overhead**: Async I/O via asyncio; benchmark with performance tests.
- **Complexity**: Iterative implementation with tests; log decisions in memory-bank.

### Next Steps
- Implement core Actor class.
- Integrate with placement and fault tolerance.
- Update roadmap to mark Step 6 progress.
