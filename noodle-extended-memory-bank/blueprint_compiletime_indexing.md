# Noodle Blueprint: Compile-time Metaprogramming + Indexing

## 🎯 Doel
Lay the fundamental architecture and concepts for:
1. Compile-time metaprogramming in Noodle.
2. Indexing as core mechanism for performance, scalability, and AI-first design.

---

## 🔹 Deel 1: Compile-time Metaprogramming

### Doel
- Optimization and validation before runtime.
- Automatically adapt AI modules and kernels to hardware.
- Reduce developer boilerplate.

### Mogelijkheden
- Shape- and type-checks (e.g., matrix dimensions).
- Loop-unrolling and parallelization at compile-time.
- Hardware-specific optimization (CPU, GPU, NPU, TPU).
- Semantic macros (intelligent rewriting).

### Syntax Voorstellen
Noodle syntax extends Python-like structure with compile-time decorators inspired by Mojo but unique to Noodle's NBC integration. Use `@compile_time` for optional metaprogramming blocks, executed during semantic analysis.

Examples:

```noodle
# Shape-check at compile-time
@compile_time
def check_matrix_shape(A: matrix[float, (m, n)], B: matrix[float, (n, p)]):
    if A.shape[1] != B.shape[0]:
        compile_error("Matrix dimensions incompatible for multiplication")
    return True  # Always true if passes

# Usage
check_matrix_shape(A, B)  # Enforced at compile-time
C = A @ B  # Safe multiplication

# Loop parallelization
@compile_time
def parallelize_loop(iterable_size: int) -> str:
    if iterable_size > 1000:
        return "parallel_for"  # Inject NBC parallel opcodes
    return "sequential_for"

# Usage
loop_type = parallelize_loop(data.size)
for i in 0..data.size:  # Becomes parallel if large
    compute(i)

# Semantic macro for hardware selection
@compile_time
def select_kernel(op: str, hardware: str = "auto") -> str:
    if op == "matrix_inversion" and hardware == "gpu":
        return "gpu_invert_kernel"  # Emit GPU-specific NBC
    return "cpu_fallback"  # Default

invert = select_kernel("matrix_inversion")
```

Tradeoffs:
- Option 1: Decorator-based (simple, Python-like) vs. Keyword-based (e.g., `compile_time fn` like Mojo) – Decorator wins for optional use, less syntax pollution.
- Benefits: Zero runtime cost; integrates with semantic analyzer for early errors.
- Drawbacks: Increases compile time; requires careful error reporting.

### Proof-of-Concept
Simulate in Python using AST processing to mimic compile-time execution.

```python
# POC: Shape-check and loop parallelization
import ast
import astunparse

class CompileTimeVisitor(ast.NodeTransformer):
    def visit_Call(self, node):
        if isinstance(node.func, ast.Attribute) and node.func.attr == 'compile_time':
            # Simulate execution: for shape-check, analyze args
            if 'check_matrix_shape' in astunparse.unparse(node.func).lower():
                # Mock shape analysis
                print("Compile-time: Performing shape check")
                # If fail: raise CompileError
            # For parallelize: inject parallel pragma
            elif 'parallelize_loop' in astunparse.unparse(node.func).lower():
                print("Compile-time: Injecting parallelization")
                # Transform loop node later
            return None  # Remove compile-time call from AST
        self.generic_visit(node)
        return node

# Example usage simulation
code = """
@compile_time
def check_matrix_shape(A, B):
    pass

check_matrix_shape(A, B)
for i in range(10000):
    compute(i)
"""
tree = ast.parse(code)
visitor = CompileTimeVisitor()
new_tree = visitor.visit(tree)
print(astunparse.unparse(new_tree))  # Output without compile-time calls, with transforms
```

This POC demonstrates removal of compile-time nodes post-execution and injection of optimizations.

---

## 🔹 Deel 2: Indexing

### 1. Symbol Index
- Datastructuur: Hashmap + Trie
- Functie: Fast lookup of variables, functions, modules.

Extend existing: Add compile-time query for validation.

```python
class SymbolIndex:
    def __init__(self):
        self.hashmap = {}  # name -> Symbol
        self.trie = Trie()  # namespace hierarchy

    def compile_time_resolve(self, name: str) -> Optional[Symbol]:
        """Resolve at compile-time for checks"""
        return self.hashmap.get(name)
```

### 2. Task Index
- Datastructuur: Task Table + Scheduler
- Functie: Manages active tasks and distributes across threads/cores.

Extend: Compile-time task reordering.

```python
class TaskIndex:
    def __init__(self):
        self.task_table = {}  # id -> TaskEntry
        self.scheduler = LocalScheduler()

    def compile_time_optimize(self, tasks: List[Task]):
        """Reorder/parallelize at compile-time"""
        # Analyze dependencies, inject parallel NBC ops
        return self.scheduler.optimize(tasks)
```

### 3. Data Index
- Datastructuur: Object Index + Cache Index + Garbage Map
- Functie: Memory and storage management across RAM, VRAM, disk.

Extend: Compile-time data layout optimization.

```python
class DataIndex:
    def __init__(self):
        self.object_index = {}  # id -> Location
        self.cache_index = CacheIndex()

    def compile_time_layout(self, obj: Object) -> Placement:
        """Optimize placement at compile-time"""
        # Based on size/type, suggest GPU if tensor > threshold
        return Placement.GPU if isinstance(obj, Tensor) and obj.size > 1e6 else Placement.CPU
```

### 4. Distributed Index
- Datastructuur: DHT + Consensus Layer (Raft/Paxos)
- Functie: Multiple PCs collaborate as one system.

Extend: Compile-time code optimization for cluster distribution.

```python
class DistributedIndex:
    def __init__(self):
        self.dht = DHT()
        self.consensus = Raft()

    def compile_time_distribute(self, code: AST) -> DistributedCode:
        """Partition code/data at compile-time"""
        # Analyze for sharding, emit network transfer NBC
        return self.dht.plan_distribution(code)
```

### 5. Knowledge Index
- Datastructuur: Model Catalogus + Semantic Index
- Functie: Make AI modules and libraries semantically accessible.

Extend: Compile-time selection of optimal AI implementation.

```python
class KnowledgeIndex:
    def __init__(self):
        self.catalog = ModelCatalog()
        self.semantic_index = SemanticIndex()

    def compile_time_select(self, query: str) -> Implementation:
        """Select best impl at compile-time, e.g., 'matrix inversion' -> GPU kernel"""
        matches = self.semantic_index.search(query)
        return max(matches, key=lambda m: m.score)  # Emit selected NBC
```

---

## 🔹 Deel 3: Integratie Compile-time ↔ Indexing

### Symbol Index
- Compile-time checks validity and references using resolve().

### Task Index
- Compile-time plans tasks in parallel using optimize().

### Data Index
- Compile-time optimizes data-layout using layout().

### Distributed Index
- Compile-time chooses best distribution using distribute().

### Knowledge Index
- Compile-time rewrites code to optimal AI-impl using select().

Tradeoffs: Tight integration enables deep optimizations but increases compiler complexity; loose coupling (e.g., optional passes) maintains simplicity at cost of missed opportunities.

---

## 🚀 Roadmap

### Fase 1: Basis
- Compile-time syntax + proof-of-concept.
- Symbol Index + Task Index.

### Fase 2: Memory & Data
- Data Index toevoegen.
- Compile-time memory optimalisaties.

### Fase 3: Distributed
- Distributed Index.
- Compile-time clusteroptimalisaties.

### Fase 4: AI-First
- Knowledge Index + semantic macros.
- Compile-time AI-optimalisaties.

Actionable tasks for Code mode:
- Implement CompileTimeVisitor in compiler/semantic_analyzer.py.
- Extend existing indices in runtime with compile_time methods.
- Add tests in tests/unit/test_compile_time.py.

---

## 📌 Samenvatting
Noodle combines compile-time metaprogramming and indexing:
- Compile-time makes Noodle **faster, safer, and hardware-aware**.
- Indexing makes Noodle **scalable, distributed, and AI-native**.
- Together they form the core of a **future-proof AI-first programming language**.
