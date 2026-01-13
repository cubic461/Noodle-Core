# Roadmap

## Stappen Plan

### Stap 1: Language Prototype ✅ **COMPLETED**
- Noodle syntax prototype (Python-like).
- Interpreter in Python.
- Basis: variabelen, functies, simpele datastructuren.
- Python FFI voor libraries.

### Stap 2: Tooling ✅ **COMPLETED**
- VS Code plugin (syntax highlighting, AI-assist).
- Memory Bank integratie.

### Stap 3: Distributed Runtime Prototype ✅ **COMPLETED**
- **Documentation completion** ✅ **COMPLETED**
  - Installation guide ✅
  - User guide ✅
  - Examples ✅
  - API documentation ✅
  - Contributing guide ✅
  - Matrix/FFI documentation ✅
  - Troubleshooting guide ✅
- Scheduler voor taken.
- Resource awareness (CPU load, netwerk load).
- Proof-of-concept cluster demo.
- **Matrix backend architecture** voor geavanceerde AI-berekeningen ✅ **COMPLETED**
- **Matrix runtime tests** voor betrouwbaarheidsborging ✅ **COMPLETED**
- **Database integratie** met uitbreidbare backends ✅ **COMPLETED**
- **Category theory implementation** ✅ **COMPLETED**
  - 7 new opcodes (FUNCTOR_APPLY, NATURAL_TRANS, COMPOSE, ID_MORPH, FUNCTOR_MAP, COALGEBRA, COALGEBRA_MAP) ✅
  - Full runtime support ✅
  - Comprehensive test coverage ✅
  - Type handling enhancements for SimpleMathematicalObject ✅
  - Integration with existing mathematical object system ✅

### Stap 4: Optimization Layer ✅ **COMPLETED**
- **NBC (Noodle Bytecode) ontwerpen** ✅ **COMPLETED**
  - Basis bytecode system geïmplementeerd met parsing, compilation, execution pipeline.
  - Instruction set met arithmetic, logical, control flow, matrix operations.
  - BytecodeProcessor met validators, optimizers, dispatchers, en metrics.
- **Mogelijke MLIR integratie** ✅ **COMPLETED**
  - MLIRIntegration geïmplementeerd met NBC to MLIR translation, optimization passes, LLVM conversion, en compilation to executable.
  - Supported dialects: std, llvm, scf, affine, tosa, linalg, vector, math, complex.
  - Pass application, validation, statistics, en benchmarking tools.
- **Crypto acceleration** met matrix- en tensoralgebra ✅ **COMPLETED**
  - MatrixRuntime enhanced met crypto operations (AES matrix encryption, RSA modular arithmetic, hash functions using matrix algebra).
  - GPU acceleration for crypto operations via CuPy integration.
  - Integration with NBC for compiled crypto instructions.
  - All tests passed successfully, including AES, RSA, hashing, Hill cipher, and obfuscation methods.

### Stap 4.5: TRM-Agent AI-Powered Optimization 🔄 **IMPLEMENTATION READY**
- **TRM-Agent Implementation**: AI-driven compiler agent that parses Python code, translates to NoodleCore-IR, optimizes using Tiny Recursive Models, and learns from feedback for continuous improvement.
  - **Status**: Complete documentatie en implementatieplan klaar
  - **Volgende Stappen**: Implementatie na infrastructuuropserving (Stap 1)

## Database Integration Focus

### Next Steps for Database Integration

- **Backend Selection**: Evaluate and select database backends (PostgreSQL, SQLite, MongoDB) ✅
- **Connection Management**: Implement connection pooling and resource management ✅
- **Query Interface**: Design Noodle-native query syntax for database operations ✅
- **Transaction Support**: Add transaction handling and ACID compliance ✅
- **Data Mapping**: Create seamless mapping between Noodle data types and database schemas ✅
- **Performance Optimization**: Implement query optimization and caching strategies ✅
- **Testing Framework**: Develop comprehensive database integration tests ✅
- **Documentation**: Create database integration guides and API reference ✅

### Stap 5: Full System 🔄 **IN PROGRESS**

- Stabiele Noodle release v1.
- Distributed AI runtime v1.
- Ecosysteem: documentatie, standaard libraries.
- **NoodleVision Extension**: Native multimedia tensor support voor video, audio en sensordata zonder externe afhankelijkheden.

### NoodleVision Implementation Details

#### Doel
Breid NoodleCore uit met native ondersteuning voor video-, audio- en sensor-data, volledig geïntegreerd in de bestaande NBC-runtime en NoodleNet-distributielaag.

#### Technische Modules
1. **noodle.media.io** - Input/output van multimediabronnen
   - Abstracte `MediaStream` interface met async iteratie
   - FFmpeg-backend (optioneel) met system-native fallbacks
   - Ondersteuning voor camera, video files, audio, sensordata

2. **noodle.tensor_ops** - Beeld- en signaalbewerkingen
   - Convolutie, pooling, kleurconversies (RGB ↔ YUV)
   - FFT, normalisatie, batching, type casting
   - GPU-kernels via bestaande NBC JIT compiler

3. **noodle.stream.optim** - Streaming workload optimalisatie
   - Dynamische batching op GPU-niveau
   - Adaptive memory management (RAM vs disk)
   - Distributed stream-pipelining via NoodleNet
   - Real-time backpressure control

#### Integratiepunten
- **Matrix API**: Uitbreiding van bestaande `Tensor` klasse in `mathematical_objects/matrix_ops.py`
- **Async Runtime**: Gebruik bestaande async runtime voor non-blocking I/O
- **Distributed System**: Integratie met cluster manager voor workload distributie
- **NBC Runtime**: Gebruik bestaande placement engine voor GPU-optimalisatie

#### API Voorbeelden
```python
# Media streaming
stream = MediaStream("camera0")
for frame in stream:
    process(frame)

# Tensor operations
gray = TensorOps.to_gray(frame)
edges = TensorOps.convolve(gray, kernel="sobel")

# Distributed streaming
with StreamOptim(auto_batch=True):
    Stream("camera0") | Transform(gray) | Display()
```

#### Verwachte Voordelen
- **AI & ML**: Directe training en inferentie op visuele/audio data binnen Noodle
- **Performance**: GPU batching + streaming tot 40x sneller dan Python pipelines
- **Gebruiksgemak**: Geen externe dependencies in userland
- **Distributie**: Real-time video-analyse over meerdere nodes mogelijk
- **Architectuur**: Één uniforme runtime voor code, data, beeld en AI

#### Implementatie Roadmap
1. Maak noodle/media/io.py met abstracte MediaStream interface
2. Voeg GPU kernels toe aan noodle/tensor/ops.py
3. Breid NBC-runtime uit met StreamOptim scheduler
4. Koppel distributielogica via noodle.net.cluster_manager
5. Test met real-time webcam feed en video file
6. Documenteer in memory-bank/docs/NoodleVision.md

### Stap 6: Advanced Parallelism & Concurrency 🔄 **PLANNED**

- **Actor Model Integration**: Native actor-based concurrency for distributed AI workloads, integrated with placement_engine.py and fault_tolerance.py for stateful actors and automatic recovery.
- **Async/Await Native Syntax**: Built-in async syntax for non-blocking I/O in database queries and distributed operations, optimized with scheduler.py for efficient task distribution.

### Stap 7: Performance & Optimization Enhancements 🔄 **PLANNED**

- **JIT Compilation with MLIR**: Extend mlir_integration.py with just-in-time compilation for hot code paths in matrix_ops.py and category_theory.py, targeting 2-5x speedup for AI computations with GPU offloading.
- **Region-Based Memory Management**: Implement region-based allocation for mathematical objects to reduce memory footprint by 50%, integrated with resource_manager.py for automatic cleanup.

### Stap 8: Security & Extensibility Features 🔄 **PLANNED**

- **Homomorphic Encryption Primitives**: Native support for homomorphic encryption in crypto-acceleration, enabling computations on encrypted data for privacy in distributed AI (federated learning via collective_operations.py).
- **Zero-Knowledge Proofs Support**: Integrate ZKP libraries for verifiable computations, coupled with error_handler.py for secure validation in trustless environments.
- **Plugin System for Backends**: Extensible architecture for database backends (sqlite.py, postgresql.py) with plugin loading via FFI, following lessons_from_python.md.
- **Metaprogramming Features**: Add macros for code generation in the compiler (code_generator.py) to reduce boilerplate in matrix operations.

### Stap 9: AI-Specific & Future Extensions 🔄 **PLANNED**

- **Native Tensor Types**: Typed tensors with automatic differentiation for ML workflows, integrated with distributed scheduler.py for model training across nodes.

- **Semantic Intent Translation Layer (ALE Enhancement)**: Semantische vertaal-laag voor externe code (Python/JS/TS) die intent herkent en omzet naar Noodle-native constructen voor robuustheid en performance.

  **Context**: Het Noodle-project wil een semantische vertaal-laag ontwikkelen die externe code (bijvoorbeeld Python, JavaScript, TypeScript) niet letterlijk vertaalt, maar de bedoeling (intent) van functies/methodes herkent en omzet naar Noodle-native constructen. Dit maakt Noodle robuuster, sneller en toekomstbestendig.

  **Doelen**:
  - Interpreterlaag bouwen (ALE uitbreiding): Scripts in Python/JS/TS analyseren. Niet de syntaxis 1-op-1 omzetten, maar de semantiek (wat bedoelt de code?).
  - Herkennen van patronen zoals numpy.dot, pandas.groupby().sum(), math.sqrt.
  - Intent-mapping tabel: Elke externe functie → een intent (abstracte betekenis).
  - Voorbeeld: numpy.dot → matrix_multiplication; pandas.groupby+sum → dataframe_group_sum; math.sqrt → square_root.
  - Intent → Noodle-kern mapping: Elke intent moet worden gemapt op een Noodle-native primitive. Als die nog niet bestaat → maak een tijdelijke wrapper. Als intent vaak voorkomt → optimaliseer en vervang wrapper met native kernel.
  - Zelfverbeterend systeem: Logging van intent usage. Monitor prestaties. Automatisch genereren en uitwisselen van snellere Noodle-native optimalisaties.

  **Optimal Execution Extension**: Uitbreiding van intent-herkenning naar runtime-optimalisatie. Herken programmeur's intent (bijv. loop → aggregate_sum) en schakel automatisch naar meest efficiënte implementatie (SIMD/GPU/distributed).

    **Werking**:
    - Intent Recognizer in compiler/parser.py: Extract intent trees (abstracte representatie, bijv. naïeve loop → "aggregate_sum(numbers)").
    - Optimal Execution Engine (OEE): Vertaal intent naar beste variant (CPU, GPU via NBC opcodes; fallback naar originele code).
    - Modes: Safe (exact execution + IDE hints), Optimized (auto-optimalisatie), Explicit (no-optimize via @no_optimize of !raw blocks).
    - IDE Feedback: LSP-hints in VS Code voor optimalisaties (bijv. "Je loop is vervangen door parallel_sum (18x sneller)").

    **Benefits**: Programmeurs schrijven simpele code; Noodle optimaliseert onderwater. Zelflerend via usage logs in PerformanceMonitor.

  **Implementatiestappen**:
  - Proof of Concept (Python focus): Maak een intent_mapper.py die Python AST doorloopt en intents genereert. Bouw een kleine mapping-tabel voor NumPy en Pandas. Genereer Noodle IR (intermediate representation) op basis van intents.
  - Noodle-native implementaties: Voor matrix_multiplication, square_root, dataframe_group_sum implementaties in NBC-runtime maken. Benchmarks draaien om snelheidsverschillen te tonen.
  - ALE Integratie: Intent layer koppelen aan de bestaande Adaptive Library Engine. Zorgen dat wrappers automatisch native kernels vervangen als er optimalisaties beschikbaar zijn.
  - Cross-language uitbreidingen: Na Python ook intent mappers maken voor JavaScript en TypeScript. Andere talen als optionele uitbreiding.

  **Voorbeeld**:
  Python input:
  ```
  import numpy as np
  A = np.random.rand(1000, 1000)
  B = np.random.rand(1000, 1000)
  C = np.dot(A, B)
  ```

  Intent IR:
  ```
  [
    { "intent": "matrix_random", "args": [1000, 1000], "var": "A" },
    { "intent": "matrix_random", "args": [1000, 1000], "var": "B" },
    { "intent": "matrix_multiplication", "args": ["A", "B"], "var": "C" }
  ]
  ```

  Noodle output:
  ```
  A = Matrix.random(1000, 1000)
  B = Matrix.random(1000, 1000)
  C = A ⨯ B
  ```

  **Verwachte Resultaten**:
  - ✅ Robuust systeem dat versieverschillen in externe libs negeert.
  - ✅ Noodle groeit dynamisch: elke keer dat een intent wordt gebruikt, kan er een optimalisatie bijkomen.
  - ✅ Snellere prestaties zichtbaar via benchmarks.
  - ✅ Basis voor universele multi-language ondersteuning (Python → JS → TS → …).

- **Quantum Computing Primitives**: Support for quantum gates via category_theory.py with runtime simulation for hybrid classical-quantum AI.

### Stap 10: Multilingual Bridges & Excel Module 🔄 **IN PROGRESS**
- **Runtime Bridges**:
  - Fase 1: Python Bridge – FFI for Python objects to NBC; e.g., `import python; numpy = python.import("numpy")`. ✅ **COMPLETED**
    - Dynamic imports/calls via `PythonBridge`.
    - Object mapping: numpy to Matrix, scalars to SimpleMathematicalObject.
    - Integrated with NBC opcodes; tests added.
    - Documentation: [python-runtime-bridge.md](python-runtime-bridge.md)
  - Fase 2: JS/TS Bridge – Node.js FFI for web/IDE integration. ✅ **COMPLETED**
    - Secure subprocess Node.js with vm sandbox, whitelisted modules (math, crypto).
    - Eval/calls with JSON comm; mapping: JS arrays to Matrix, numbers to SimpleMathematicalObject.
    - Integrated with new opcodes JS_IMPORT/JS_CALL; tests added.
    - Documentation: [js-ts-runtime-bridge.md](js-ts-runtime-bridge.md)
  - Fase 3: Transpilation Subset – Intent-based (AST to Noodle IR for loops/functions/classes). 🔄 **PLANNED**
  - Fase 4: Other Languages – Rust/C/Java/C# bridges with intent translation. 🔄 **PLANNED**
- **Excel Standard Module**:
  - Fase 1: Simple API via Python bridge (openpyxl/pandas); e.g., `import excel; sheet = excel.open("data.xlsx")`. 🔄 **PLANNED**
  - Fase 2: Native NBC Implementation – xlsx parser to matrix; AI pattern recognition (tables/time series). 🔄 **PLANNED**
- **Linter Enforcement**: All contributions must pass pre-commit hooks (black, isort, mypy, bandit). Run `pre-commit install` on setup; enforce in CI.

### Stap 11: Noodle-Native Vector Database 🔄 **PLANNED**
- **Module Structure**:
  - `noodle-core/vector-db/` : Runtime implementation using Noodle's matrix-first architecture for embeddings storage, indexing, and similarity search (cosine, dot product, Euclidean).
  - `noodle-ide/extensions/vector-search/` : IDE extension for automatic project file indexing, semantic search UI, and integration with AI conversation panel.
- **MVP Features**:
  - Embeddings storage in Noodle matrices with persistent backend support (SQLite/DuckDB/PostgreSQL).
  - Basic cosine similarity search API.
  - Manual indexing via CLI/IDE button.
- **Advanced Features**:
  - Real-time reindexing on code changes.
  - Distributed sharding and parallel search across nodes.
  - ALE integration for API mapping to Qdrant/Pinecone with on-the-fly optimization.
  - Semantic search in IDE with code knowledge graph visualization.
- **Vector Memory Manager (IDE Extension)**:
  - `noodle-ide/extensions/vector-memory-manager/` : Monitors RAM usage, manages hot/cold data (RAM for recent embeddings, disk for cold).
  - Features: LRU eviction, configurable thresholds (e.g., 70% RAM), prefetching based on query patterns.
  - Integration: Works with vector-search plugin; uses Noodle DB backends for persistence; memory-mapped files for efficiency.
  - MVP: Simple monitoring + LRU; later: Multiple policies, smart prefetching.
- **Integration**:
  - Leverage existing matrix runtime for vector operations.
  - Use plugin architecture in IDE for extensibility.
  - Ensure privacy: All data local or in user-controlled cluster.
- **Challenges & Mitigations**:
  - Memory usage: Implement sharding, compression, and Vector Memory Manager for balancing.
  - Embedding generation: Support local/small models initially, extensible to external.
  - Performance: Optimize with NBC opcodes for vector math; monitor via resource_monitor.py.
- **Documentation**: New section in technical_specifications.md for vector DB APIs; update testing_strategy.md for coverage targets (95% line coverage for vector operations and memory management).


## Noodle IDE Project

Naast de Noodle Core ontwikkeling wordt gestart met een **tweede project: Noodle IDE**, een gescheiden repository dat fungeert als de ontwikkelomgeving voor Noodle. Voor details over de fases en deliverables, zie: [`noodle-ide-roadmap.md`](./noodle-ide-roadmap.md).

- **Doel**: UI (Tauri/Electron + Monaco) gekoppeld aan Noodle Core, AI-assistentie, en regiemogelijkheden.
- **Relatie met Core**: Gescheiden repo, maar met API-integratie voor bestandsbeheer, workers en logging.
- **Roadmap**: Zie [`noodle-ide-roadmap.md`](./noodle-ide-roadmap.md) voor een volledige gefaseerde aanpak.
