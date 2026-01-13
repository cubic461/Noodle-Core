# NoodleCore Distributed Inference - Implementation Guide

## 📚 Overzicht

Deze guide beschrijft de implementatie van het **NoodleCore Distributed Inference** project, gefaseerd opgebouwd van observability tot volledige distributed execution.

## 🎯 Doel

Bouw een **meta-orchestrator** die bovenop bestaande frameworks (PyTorch, Transformers) zit en gebruikmaakt van **runtime metrische data** om intelligente sharding beslissingen te nemen voor LLM inference over heterogene hardware (GPU/iGPU/CPU/mixed nodes).

---

## 🏗️ Architectuur

### High-Level Design

```
┌─────────────────────────────────────────────────────────────┐
│                      Client Applications                     │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│                     Coordinator                             │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐  │
│  │   Registry   │  │   Planner    │  │    Metrics      │  │
│  │   (Nodes)    │  │  (Sharding)  │  │  (Aggregation)  │  │
│  └──────────────┘  └──────────────┘  └─────────────────┘  │
└───────────────────────────┬─────────────────────────────────┘
                            │ PartitionPlan
        ┌───────────────────┼───────────────────┐
        │                   │                   │
┌───────▼────────┐  ┌───────▼────────┐  ┌──────▼────────┐
│   Worker A     │  │   Worker B     │  │   Worker C    │
│   (Stage 0)    │  │   (Stage 1)    │  │   (Stage 2)   │
│                │  │                │  │               │
│  ┌─────────┐   │  │  ┌─────────┐   │  │  ┌─────────┐  │
│  │ Layers  │   │  │  │ Layers  │   │  │  │ Layers  │  │
│  │ 0-9     │   │  │  │ 10-19   │   │  │  │ 20-31+h │  │
│  └─────────┘   │  │  └─────────┘   │  │  └─────────┘  │
│       │        │  │       │        │  │       │       │
│  ┌────▼────┐   │  │  ┌────▼────┐   │  │  ┌────▼────┐  │
│  │KV-Cache │   │  │  │KV-Cache │   │  │  │KV-Cache │  │
│  └─────────┘   │  │  └─────────┘   │  │  └─────────┘  │
└────────────────┘  └────────────────┘  └───────────────┘
```

### Data Flow

1.  **Client** stuurt inference request naar **Coordinator**
2.  **Coordinator** gebruikt **Planner** om sharding plan te genereren
3.  Plan bepaalt welke layers op welke nodes draaien (Pipeline Model Parallelism)
4.  **Workers** ontvangen hun assigned stage en voeren forward pass uit
5.  Activations stromen sequentieel door de stages
6.  **Metrics** worden verzameld voor latere optimalisatie

---

## 📊 Fase 1: Observability Engine

**Doel**: Bewijs dat we het gedrag van een LLM kunnen observeren en metrische data kunnen verzamelen voor intelligente planning.

### Componenten

#### 1. Metrics Collector (`src/metrics.py`)

Verzamelt gedetailleerde metrics per layer:

```python
@dataclass
class LayerMetrics:
    layer_name: str
    layer_type: str
    forward_latency_ms: float
    p95_latency_ms: float
    peak_vram_after: int
    num_parameters: int
    input_shapes: List[List[int]]
    output_shapes: List[List[int]]
    # ... etc
```

**Key features**:
-   Timing via `time.time()` en CUDA events
-   Memory tracking via `torch.cuda.memory_allocated()`
-   Tensor shape registratie
-   Percentiel berekening (p50, p95, p99)

#### 2. PyTorch Hooks (`src/hooks.py`)

Registreert hooks op alle relevante layers:

```python
class LayerHook:
    def pre_forward_hook(self, module, inputs):
        # Start timing & memory snapshot
        pass
    
    def post_forward_hook(self, module, inputs, outputs):
        # Finalize metrics
        pass
```

**Strategieën**:
-   **Generic**: Voor alle named modules in het model
-   **Specialized**: Voor Transformer blocks (sneller, minder overhead)

#### 3. Structured Logger (`src/logger.py`)

Output naar JSONL formaat:

```json
{"layer_name": "transformer.h.5", "forward_latency_ms": 12.5, "peak_vram_after": 1073741824, ...}
{"layer_name": "transformer.h.6", "forward_latency_ms": 13.1, "peak_vram_after": 1073741824, ...}
```

**Benefits**:
-   Machine-readable voor analyse
-   Ondersteunt aggregatie over multiple runs
-   Eenvoudig te importeren in pandas/Visualisatie tools

#### 4. Dashboard Generator (`src/dashboard.py`)

Genereert interactieve HTML met Plotly:

**Charts**:
-   Latency overview (bar chart)
-   Memory timeline (line chart)
-   Parameter vs latency scatter
-   Layer type comparison
-   Bottleneck analysis table

#### 5. Main Engine (`src/observability_engine.py`)

Hoofd-API die alles coördineert:

```python
engine = ObservabilityEngine(model, log_dir, config)
engine.instrument()          # Register hooks
engine.warmup(inputs, 10)    # Stabilize measurements
report = engine.profile(inputs, 100)  # Collect metrics
engine.save_dashboard("gpt2_profile")  # Generate HTML
```

### Gebruik

```bash
cd noodle-poc-fase1

# Option 1: Met voorbeeldscript
python examples/profile_gpt2.py --model gpt2 --num-samples 100

# Option 2: Programmatisch
python your_custom_script.py
```

### Output

```
data/metrics/
├── gpt2_profile_metrics.jsonl       # Raw metrics data
├── gpt2_profile_dashboard.html      # Interactive visualization
├── gpt2_profile_summary.json        # Aggregated report
└── logs/
    ├── config_*.json                # Configuration used
    └── system_info_*.json           # Hardware info
```

---

## 📐 Fase 2: Execution Planner & Staged Simulation

**Doel**: Bewijs dat we een statisch partition plan kunnen genereren en staged execution lokaal kunnen simuleren.

### Componenten (te bouwen)

#### 1. Execution Planner (`src/planner.py`)

```python
class ExecutionPlanner:
    def __init__(self, metrics: MetricsCollector):
        self.metrics = metrics

    def generate_plan(self, nodes: List[VirtualNode]) -> PartitionPlan:
        # Gebruik metrics om beslissingen te nemen:
        # - Identificeer bottlenecks (bv. lm_head: 17% latency)
        # - Verdeel layers voor balans
        # - Houd rekening met memory constraints
        # - Optimaliseer voor minimale end-to-end latency
        pass
```

**Heuristieken**:
1.  **Bottleneck first**: Plaats langzaamste layers op snelste device
2.  **Memory-aware**: Houd VRAM/CPU RAM limieten in de gaten
3.  **Latency balancing**: Streef naar gelijke stage latency (<100ms verschil)
4.  **Cache locality**: Groepeer layers die data delen

#### 2. Partition Plan (`src/plan.py`)

```python
@dataclass
class PartitionPlan:
    stages: List[Stage]
    
@dataclass
class Stage:
    stage_id: int
    device: str
    layers: List[str]
    expected_latency_ms: float
    memory_required_mb: float
    rationale: str  # Waarom deze verdeling?
```

#### 3. Virtual Node (`src/virtual_node.py`)

Simuleert hardware capabilities:

```python
class VirtualNode:
    def __init__(self, node_id, device_type, specs):
        self.node_id = node_id
        self.device_type = device_type  # "gpu", "igpu", "cpu"
        self.vram_gb = specs.vram_gb
        self.ram_gb = specs.ram_gb
        self.compute_score = specs.compute_score
```

#### 4. Staged Runner (`src/staged_runner.py`)

Simuleert staged execution:

```python
class StagedRunner:
    def __init__(self, plan: PartitionPlan, nodes: List[VirtualNode]):
        self.plan = plan
        self.nodes = nodes
    
    def run(self, inputs) -> Outputs:
        # Voor elke stage in het plan:
        #   1. Verplaats activations naar stage device
        #   2. Voer forward pass uit voor assigned layers
        #   3. Sla resultaat op in local KV-cache
        #   4. Geef activations door aan volgende stage
        pass
```

#### 5. Benchmarker (`src/benchmarker.py`)

Vergelijkt native vs staged execution:

```python
class Benchmarker:
    def compare(self, model, plan: PartitionPlan):
        # Run native
        native_time = time_model(model, inputs)
        
        # Run staged
        runner = StagedRunner(plan, nodes)
        staged_time = time_staged(runner, inputs)
        
        # Report
        return {
            "native_ms": native_time,
            "staged_ms": staged_time,
            "overhead_pct": (staged_time - native_time) / native_time * 100
        }
```

---

## 🌐 Fase 3: Distributed Network Layer

**Doel**: Bewijs dat we echt gedistribueerde inference kunnen draaien over meerdere machines.

### Componenten (te bouwen)

#### 1. Protocol Buffers (`protos/stage_service.proto`)

Definieert gRPC service:

```protobuf
service StageService {
  rpc CreateSession(SessionConfig) returns (SessionId);
  rpc Forward(ForwardRequest) returns (ForwardResponse);
  rpc CloseSession(SessionId) returns (Ack);
}

message ForwardRequest {
  string session_id = 1;
  int32 token_index = 2;
  bytes activations = 3;  // Serialized tensors
}
```

#### 2. Coordinator (`src/network/coordinator.py`)

Managet het volledige cluster:

```python
class Coordinator:
    def __init__(self, planner: ExecutionPlanner):
        self.planner = planner
        self.registry = NodeRegistry()
        self.sessions = SessionManager()
    
    def submit_request(self, request: InferenceRequest):
        # 1. Kies een plan op basis van beschikbare nodes
        # 2. Start sessie op alle workers
        # 3. Route request naar eerste stage
        # 4. Wacht op resultaat en stream terug
        pass
    
    def register_node(self, node: WorkerNode):
        self.registry.add(node)
    
    def health_check(self):
        # Monitor worker health
        pass
```

#### 3. Worker (`src/network/worker.py`)

Draait op elke node:

```python
class WorkerService(StageServiceServicer):
    def __init__(self, model_weights):
        self.stage = None
        self.kv_cache = {}
    
    def CreateSession(self, request, context):
        # Laad weights voor assigned stage
        # Initialiseer local KV-cache
        pass
    
    def Forward(self, request, context):
        # Deserializeer activations
        # Voer forward pass uit voor assigned layers
        # Serializeer output
        # Bewaar in KV-cache
        pass
    
    def CloseSession(self, request, context):
        # Cleanup KV-cache
        pass
```

#### 4. Utilities (`src/network/utils.py`)

-   Tensor serializatie/deserializatie
-   Node registry management
-   Session state tracking
-   Network metrics

---

## 🚀 Fase 4: Advanced Features

**Doel**: Bouw adaptieve, heterogene planning met runtime optimalisatie.

### Features (toekomst)

1.  **Adaptive Planning**
    ```python
    class AdaptivePlanner(ExecutionPlanner):
        def adapt_plan(self, runtime_metrics):
            # Monitor actual vs expected latency
            # Als error > 15%: replan
            # Herverdeel stages voor balans
            pass
    ```

2.  **Heterogeneous Hardware Matching**
    ```python
    class HardwareMatcher:
        def match(self, layer_requirements, available_nodes):
            # Kies beste device op basis van:
            # - Compute capabilities
            # - Memory availability
            # - Network latency
            # - Cost (power/performance)
            pass
    ```

3.  **Automatic Quantization**
    ```python
    class QuantizationOptimizer:
        def quantize_stage(self, stage: Stage, target_dtype):
            # Pas int8/4bit quantization toe
            # Zorg voor device-compatibele kernels
            pass
    ```

4.  **Token Chunking**
    ```python
    class TokenChunker:
        def chunk(self, tokens, chunk_size=4):
            # Verwerk meerdere tokens per netwerk hop
            # Reduceer latency overhead
            pass
    ```

---

## 🧪 Testing Strategy

### Unit Tests

```bash
# Test individuele componenten
pytest tests/test_metrics.py
pytest tests/test_hooks.py
pytest tests/test_logger.py
```

### Integration Tests

```bash
# Test volledige workflow
pytest tests/test_observability_engine.py
pytest tests/test_planner.py
```

### End-to-End Tests

```bash
# Test distributed execution
pytest tests/test_distributed_inference.py
```

---

## 📈 Performance Monitoring

### Key Metrics

1.  **End-to-End Latency**: Totale inference tijd van prompt tot completion
2.  **Stage Balance**: Verschil in latency tussen stages (doel: <100ms)
3.  **Memory Utilization**: VRAM/CPU RAM gebruik per stage
4.  **Network Overhead**: Serializatie + RTT tussen nodes
5.  **Throughput**: Tokens/sec voor multi-request scenario's

### Monitoring Tools

-   **Dashboard**: Real-time metrics tijdens profiling
-   **JSONL Logs**: Persistente data voor post-processing
-   **System Metrics**: CPU/GPU utilization, network bandwidth
-   **Bottleneck Analysis**: Automatische identificatie van problemen

---

## 🎯 Success Criteria

### Fase 1 ✅
-   [x] Verzamel ≥90% van alle layer metrics
-   [x] Genereer werkend dashboard
-   [x] Identificeer 3+ bottlenecks in GPT-2

### Fase 2 (In Progress)
-   [ ] Genereer partition plan met <15% latency error
-   [ ] Staged runner matched native output (correctness)
-   [ ] Overhead <30% vs native (local simulation)

### Fase 3 (Planned)
-   [ ] End-to-end distributed inference werkt op 2+ machines
-   [ ] Fault tolerance: auto-retry bij failures
-   [ ] Network metrics verzameld

### Fase 4 (Future)
-   [ ] Adaptive planner: <10% latency error na 10 runs
-   [ ] Ondersteun 3+ verschillende hardware types
-   [ ] Quantization: 2x speedup zonder accuracy verlies

---

## 📚 Documentatie

### Core Documents

1.  **README.md**: Project overview en quick start
2.  **IMPLEMENTATION_GUIDE.md** (dit document): Architectuur en implementatie details
3.  **QUICK_START.md**: Stap-voor-stap setup guide
4.  **API_REFERENCE.md**: Gedetailleerde API documentatie
5.  **TROUBLESHOOTING.md**: Veelvoorkomende problemen en oplossingen

### Voorbeelden

1.  **examples/profile_gpt2.py**: Volledige profiling workflow
2.  **examples/custom_model.py**: Hoe je eigen model te profilen
3.  **examples/distributed_demo.py**: Distributed inference demo
4.  **examples/adaptive_planning.py**: Runtime-adaptive planning

---

## 🛠️ Development Workflow

### Voor nieuwe features

1.  **Documenteer eerst**: Schrijf design doc in `docs/designs/`
2.  **Implementeer**: Bouw component met unit tests
3.  **Integreer**: Voeg toe aan main engine
4.  **Test**: Run integration tests
5.  **Benchmark**: Meet performance impact
6.  **Documenteer**: Update guides met voorbeelden

### Code Conventies

-   **Type hints**: Gebruik `typing` module voor alle public APIs
-   **Docstrings**: Google-style voor classes/functions
-   **Testing**: ≥80% coverage voor nieuwe code
-   **Logging**: Gebruik `StructuredLogger` voor consistente output

---

## 🔜 Roadmap

### Q1 2026: Basis Distributed Inference
-   Fase 1: Observability ✅
-   Fase 2: Staged Simulation 🔄
-   Fase 3: Network Layer 🟡

### Q2 2026: Production Features
-   Fase 4: Adaptive Planning 🟡
-   Quantization support 🟡
-   Kubernetes integration 🟡

### Q3 2026: Advanced Capabilities
-   Multi-model serving 🟡
-   Dynamic batching 🟡
-   Heterogeneous clusters 🟡

---

## 🤝 Contributing

Zie `CONTRIBUTING.md` voor gedetailleerde richtlijnen.

**Korte samenvatting**:
1.  Fork de repository
2.  Maak feature branch
3.  Implementeer met tests
4.  Run `black`, `flake8`
5.  Open pull request
6.  Voeg benchmark results toe

---

## 📞 Support

-   **Issues**: <https://github.com/your-org/noodle-poc/issues>
-   **Discord**: <https://discord.gg/noodlecore>
-   **Documentatie**: <https://docs.noodlecore.dev>

---

## 📄 Licentie

Apache 2.0 License - zie `LICENSE` voor details
