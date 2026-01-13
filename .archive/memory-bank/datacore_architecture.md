# Noodle DataCore Architecture Plan

## 1. Summary of Objectives

Build Noodle DataCore, an intent-based, matrix-first database layer that:

- Semantically understands queries in various languages/forms (SQL, MongoDB, GraphQL, Vector API, natural language) via intent extraction.
- Translates intents to a unified matrix-oriented Noodle Intermediate Representation (NIR).
- Optimizes execution using GPU, SIMD, JIT/AOT, and distribution.
- Continuously improves execution plans and kernels via existing ALE (Adaptive Library Evolution) and memory-database.
- Provides secure fallbacks to original DB engines/implementations when needed.

This leverages Noodle's strengths in matrix operations, NBC runtime, and distributed systems, integrating with existing semantic intent translation for code transpilation to unify query/code intents.

## 2. High-Level Architecture (Text Diagram)

```
Client (IDE / API / App)
  └─ Query (SQL / Mongo / GraphQL / Vector / NL)
       ├─ Parser/Front-End (lang-specific, extend transpiler/python/parser.py for SQL/Mongo)
       ├─ Intent Extractor (reuse/extend transpiler/python/intent_mapper.py + ML/LLM)
       │    └─ Unified Intent IR (semantic, JSON schema in intent_schema.py)
       ├─ Planner/Optimizer (extend database/query_planner.py + cost_based_optimizer.py)
       │    └─ Optimized Matrix Plan (NIR, DAG of matrix ops)
       ├─ Executor (extend runtime/nbc_runtime/executor.py)
       │     ├─ Local CPU/GPU kernels (SIMD/CUDA via mathematical_objects/matrix_ops.py)
       │     ├─ Distributed workers (runtime/distributed/scheduler.py + placement_engine.py)
       │     └─ Fallback (database/backends/ + FFI via interop/)
       ├─ Result Merger & Postproc (extend database/data_mapper.py)
       └─ Telemetry → Memory-DB / ALE (extend runtime/performance/monitor.py + transpiler_ai.py)
```

Tradeoffs:
- **Reuse vs. New Components**: 70% reuse from existing database/runtime/transpiler reduces dev time (MVP 2-4 weeks vs. 4-8) but requires schema unification (query intents extend code intents like matrix_multiplication)—mitigate with modular intent_catalog.json to avoid bloat.
- **Matrix-First Approach**: Excels for OLAP/ML workloads (5-50x speedup via GPU/SIMD synergy with nbc_runtime/math/enhanced_matrix_ops.py) but less optimal for OLTP (non-numerical)—fallback to backends/ (e.g., sqlite.py) adds ~10% overhead; heuristics in cost_model.py select based on shapes.
- **Distributed vs. Local**: Resilience/scalability for large data but network latency (start local/GPU, add distributed in M1); use existing fault_tolerance.py for consistency.
- **Intent Extraction**: Rules+ML accurate (≥90%) for structured queries but NL needs LLM (higher cost/latency)—optional, fallback to mql_parser.py.

## 3. Core Components & Locations (Repo Structure)

Place under `noodle-dev/src/noodle/datacore/` (new dir); IDE dashboard under `noodle-ide/plugins/datacore-dashboard/`.

- **datacore/frontend/**
  - `sql_parser.py`: SQL → AST → intent (extend transpiler/python/parser.py).
  - `mongo_parser.py`: Mongo queries → intent (new, AST via pymongo or similar).
  - `graphql_parser.py`: GraphQL → intent (new, using graphql-core).
  - `nl_parser.py`: Natural language → intent (optional, LLM-assisted via ai_orchestrator/).

- **datacore/intent/**
  - `intent_extractor.py`: Generic extractor (rules + ML, extend transpiler/python/intent_mapper.py for query patterns).
  - `intent_catalog.json`: Unified mapping (pattern → intent, merge code/query e.g., "groupby+agg" → "group_by_agg").
  - `intent_schema.py`: Intent IR definition (JSON schema, include name, operands, dtype, shapes, estimates).

- **datacore/planner/**
  - `plan_generator.py`: Intent IR → NIR (matrix ops DAG, extend compiler/nir/builder.py).
  - `cost_model.py`: Cost estimation (extend database/cost_based_optimizer.py, inputs: shapes, hardware from resource_monitor.py).
  - `reoptimizer.py`: Dynamic replanning (telemetry-based, integrate with runtime/optimization/).

- **datacore/executor/**
  - `executor.py`: Runtime dispatch (local/GPU/distributed/fallback, extend runtime/nbc_runtime/core/runtime.py).
  - `kernel_registry.py`: Versioned kernels (C/CUDA/NBC, tie to lib_store/).
  - `distributed_adapter.py`: Worker discovery/DHT (extend runtime/distributed/cluster_manager.py).

- **datacore/telemetry/**
  - `collector.py`: Log events (shapes, runtimes, errors; extend runtime/performance/enhanced_monitor.py).
  - `memory_db_schema.sql` / ORM: Telemetry storage (extend database/mathematical_cache.py).
  - `analytics.py`: Hot query detection (heavy-hitters, trigger ALE).

- **datacore/ale_integration/**
  - `ale_connector.py`: ALE pipeline hook (candidate gen/promote, extend runtime/interop/transpiler_ai.py).
  - `lib_store_adapter.py`: Store/reload promoted kernels (via lib_store/).

- **noodle-ide/plugins/datacore-dashboard/**
  - UI: Query visualizer, plan inspector, canary monitor, promote/rollback (extend lsp/ for VS Code integration).

## 4. Detailed Dataflow

1. **Incoming Query (e.g., SQL)**: Client → lang-specific parser (e.g., sql_parser.py) → syntactic AST.
2. **Intent Extraction**: AST + heuristics/ML (intent_extractor.py) → Intent IR (e.g., {"intent": "filter_mask", "predicate": "age > 30", "table": "users"}).
3. **Plan Generation (NIR)**: plan_generator.py translates to matrix ops (e.g., filter → sparse mask, group_by → indexed reduction, join → batched matmul). cost_model.py selects variant (CPU/GPU/distributed) based on shapes/hardware (from resource_monitor.py) and history (memory-db).
4. **Execution Selection**: executor.py loads kernels from kernel_registry.py (NBC/CUDA; if missing, route to ALE as candidate).
5. **Run**: Local exec via nbc_runtime/math/matrix_ops.py or dispatch to workers (distributed_adapter.py). Merge partials (data_mapper.py), postprocess.
6. **Telemetry & Learning**: collector.py logs to memory-db; analytics.py detects hots → ale_connector.py triggers ALE (transpile/optimize kernels).
7. **Continuous Optimization**: ALE generates candidates; sandbox (runtime/sandbox.py) validates; promote → kernel_registry update (canary via distributed/); IDE shows hints (lsp/completion.py).

Pseudocode for Core Flow (for Code mode):
```python
# filepath: noodle-dev/src/noodle/datacore/executor.py
from .intent.intent_extractor import extract_intent
from .planner.plan_generator import generate_nir
from runtime.nbc_runtime.core.runtime import NBCExecutor

def execute_query(query: str, lang: str) -> Result:
    ast = parse_query(query, lang)  # e.g., sql_parser
    intent_ir = extract_intent(ast)  # Unified with code intents
    nir_plan = generate_nir(intent_ir)  # Matrix DAG
    optimized_plan = optimize_plan(nir_plan)  # cost_model
    if has_kernel(optimized_plan):
        result = NBCExecutor.run(optimized_plan)  # Local/GPU
    else:
        result = fallback_execute(query)  # Original DB
        submit_to_ale(optimized_plan, result)  # For learning
    log_telemetry(result)  # collector
    return result
```

## 5. Intent Model: Examples & Canonical Intents

Extend existing code intents (from semantic plan) with query-specific. Startset (JSON in intent_catalog.json):

- `table_scan`: Simple filter ({"intent": "table_scan", "table": "users", "filter": null}).
- `filter_mask`: Predicate filter ({"intent": "filter_mask", "predicate": "age > 30", "selectivity": 0.2}).
- `project_columns`: Select ({"intent": "project_columns", "cols": ["name", "age"]}).
- `group_by_agg`: Group & aggregate ({"intent": "group_by_agg", "group": "dept", "agg": "mean(salary)"} → reductions).
- `join_hash`: Equi-join ({"intent": "join_hash", "tables": ["users", "depts"], "on": "dept_id"}).
- `join_matmul`: Matmul-representable join (star schema, reuse matrix_multiplication).
- `topk`: Top-k ({"intent": "topk", "k": 10, "order": "salary desc"} → partial-sort).
- `vector_search`: NN search ({"intent": "vector_search", "metric": "cosine", "embeddings": Matrix}).
- `matrix_multiplication`: GEMM (reuse from mathematical_objects/).
- `convolution_2d`: Image conv (extend math/enhanced_matrix_ops.py).
- `reduce_sum/product`: Reductions (reuse math/matrix_ops.py).

IR includes: intent name, operands (vars/Matrices), dtype, shapes, cardinalities, selectivity estimates (from query_rewriter.py).

## 6. Planner / Cost Model & Matrix Solution Selection

**Cost Model Inputs** (extend cost_based_optimizer.py):
- Data shapes (rows/cols/sparsity from data_mapper.py).
- Hardware (GPU VRAM/cores from resource_monitor.py).
- Network (latency/bandwidth from distributed/network_protocol.py).
- Historical (memory-db via mathematical_cache.py).

**Heuristics**:
- Dense numerical → GPU matrix kernels (e.g., agg → reduce_sum on GPU).
- High sparsity → Sparse ops/indexed (extend math/objects.py).
- Joins: Small tables/one fits GPU → hash/GPU; large dense → matmul via factorization (reuse enhanced_matrix_ops.py).
- Output: Executable NIR DAG (compiler/nir/ir.py) with data-movement ops.

Pseudocode:
```python
# filepath: noodle-dev/src/noodle/datacore/planner/cost_model.py
def estimate_cost(plan_variant: NIR, shapes: Dict, hardware: Dict) -> float:
    if 'gpu' in hardware and is_dense(shapes):
        return gpu_time(plan_variant) + data_transfer_cost  # Low for local
    elif distributed:
        return network_cost + worker_time(plan_variant)
    else:
        return cpu_time(plan_variant)  # Fallback
    return min_variant(plan_variants, estimate_cost)
```

## 7. Distributed Execution Model

Master (IDE/laptop) as scheduler (extend runtime/distributed/scheduler.py or cluster_manager.py service).

Workers: Lightweight `noodle_worker` (expose resource profile via resource_monitor.py; secure auth with crypto_acceleration.py).

- Actor-style tasks + all-reduce for ML ops (extend distributed/actors.py).
- Chunked partitions for OLAP (placement_engine.py).
- Canary nodes for new kernels (fault_tolerance.py for rollout).

## 8. Integration with ALE & Memory-Database

Telemetry (collector.py) feeds ALE training (hot functions/shapes/edges from performance/enhanced_monitor.py).

ALE Flow (extend transpiler_ai.py):
- Extract inputs/tests (numerical tolerance via math/category_theory.py).
- Candidate gen (LLM/codegen/templates + specialization).
- Sandbox validate (runtime/sandbox.py).
- Promote → kernel_registry (lib_store_adapter.py); metadata for provenance/rollback.

## 9. Safety, Correctness & Fallback

- Numeric tolerance per op (configurable in error_handler.py).
- Determinism: Reproducibility checks/unit tests (extend tests/unit/test_math.py).
- Policy: Manual approval for community store; local auto-promote optional (IDE controls).
- Fallback: Always to original (database/backends/ or Python engines via interop/python_bridge.py).

## 10. Milestones & Deliverables (MVP → Production)

**MVP (2-4 weeks, reuse-focused)**:
- SQL parser + intent_extractor for subset (filter/project/group_by/agg; accuracy ≥90% on dev set).
- intent_catalog.json (minimal, unified with code).
- plan_generator.py (NIR for intents, extend nir/builder.py).
- executor.py (local CPU vectorized, NumPy fallback via bindings/pandas_integration.py).
- collector.py (logs to memory-db, extend database_query_cache.py).
- IDE plugin (basic visualizer via lsp/).
- Tests: `tests/datacore/test_intent_extraction.py`, `test_execution_correctness.py` (95% coverage, equal to baseline).
- Doc: This MD + examples.

**M1 (4-8 weeks)**:
- GPU kernels for group_by/reductions (NCCL/CUDA or CuPy via gpu/kernel.py).
- Baseline cost_model.py.
- ALE connector for 2 intents (matmul, group_by_mean; extend replacement_manager.py).

**M2 (8-12 weeks)**:
- Distributed exec with worker (extend distributed_demo.py).
- Canary rollout/promote/rollback (fault_tolerance.py).
- More parsers (Mongo/GraphQL) + NL→intent (ai_orchestrator/).

**M3+ (Ongoing)**:
- Vector search/sparse support (extend math/gpu_memory_manager.py).
- Query planner enhancements (rewriter.py integration).
- Community kernel store + CI (validation_quality_assurance_procedures.md).

## 11. Measurable Gains: Performance & Adaptivity

**Performance**:
- Matrix-first: GPU/SIMD for analytics (agg/joins/vector → 5-50x vs. naive Python/DB; benchmark via performance_benchmark.py).
- Less movement: Internal matrix (mathematical_objects/) reduces IO/Python overhead.
- Fused kernels: Planner fuses ops (filter+reduce → 20-30% less memory traffic).

**Adaptivity**:
- Cost model + telemetry: Runtime selects best (shapes/hardware).
- ALE: Auto-experiments/improves kernels (canary rollout).
- Intent abstraction: Tolerant to lang/version changes (translate semantics).

Expected: OLAP 5-50x speedup; vector 10-100x (batched dots); latency-sensitive 5-30x local GPU.

## 12. Risks & Mitigations

- Faulty intent recognition: Fallback + safe-mode/IDE confirmation (lsp/diagnostics.py).
- Numerical drift: Tolerance checks/regression tests (tests/regression/).
- Security/privacy: Telemetry PII redaction (security.py) + opt-in.
- Distributed consistency: Start single-node, add via M2 (ACID via transaction_manager.py).
- Complexity: Modular design, 95% coverage enforcement.

## 13. Metrics & Observability

- Query latency (p50/p95/p99 pre/post-opt, via real_time_monitor.py).
- Throughput (queries/sec).
- Kernel promotion success (pass/fail >80%).
- Memory/VRAM util (memory_profiler.py).
- Error/regression rate post-promotion.
- Cost/query (CPU/energy, later via metrics_analysis.py).

## 14. Concrete Rocode/Cline Prompt (Copy-Paste)

Implement Noodle DataCore MVP per this plan. Focus on minimal subset: SQL → intent (filter/project/group_by/agg) → NIR → executor (vectorized local CPU kernels) → telemetry → ALE stub.

Deliverables:
- `noodle-dev/src/noodle/datacore/frontend/sql_parser.py`
- `noodle-dev/src/noodle/datacore/intent/intent_extractor.py` + `intent_catalog.json`
- `noodle-dev/src/noodle/datacore/planner/plan_generator.py`
- `noodle-dev/src/noodle/datacore/executor/executor.py` (local fallback)
- `noodle-dev/src/noodle/datacore/telemetry/collector.py`
- `noodle-ide/plugins/datacore-dashboard/` (basic UI)
- Tests: `noodle-dev/tests/datacore/test_intent_extraction.py`, `test_execution_correctness.py`

KPIs: Intent accuracy ≥90% (sample SQL dev set). Correct results = baseline. Telemetry logged.

Extra: Update `memory-bank/datacore_architecture.md` with API/examples.

## 15. Strategic Power

Unified semantic layer: Future-proof (new langs/DBs as frontends). Matrix-first: Synergy with Noodle AI/kernels (converge DB-analytics/ML paths, reuse hardware accel). Self-learning ALE+telemetry: Continuous improvement without manual opt.

Version: 1.0 | Linked to semantic_intent_translation_plan.md | Validated per AGENTS.md (Phase 1-3).
