# Quick Start Guide - Observability Engine

Get started with the NoodleCore Observability Engine in 5 minutes.

## Prerequisites

- Python 3.9 or higher
- PyTorch 2.0+ (with CUDA support recommended)
- 4GB+ RAM (8GB+ for larger models)
- Git (optional)

## Installation

### Step 1: Clone or Navigate to Project

```bash
cd C:/Users/micha/Noodle/noodle-poc-fase1
```

### Step 2: Install Dependencies

```bash
# Core dependencies
pip install -e .

# For development (includes tests, linting, etc.)
pip install -e ".[dev]"

# For dashboard visualizations
pip install -e ".[dashboard]"
```

### Step 3: Verify Installation

```python
python -c "from src.observability_engine import ObservabilityEngine; print('✅ Installation successful!')"
```

## Your First Profiling Session

### Option 1: Using the Example Script (Recommended)

The easiest way to get started:

```bash
python examples/profile_gpt2.py --model gpt2 --num-samples 50
```

**What this does:**
1.  Loads GPT-2 model (small, fast for testing)
2.  Instruments all layers with profiling hooks
3.  Runs 10 warmup iterations
4.  Profiles for 50 runs with detailed metrics
5.  Generates interactive dashboard

**Expected output:**
```
🚀 NoodleCore Observability Engine - GPT-2 Profiling
======================================================
Model: gpt2
Device: cuda:0
Warmup runs: 10
Profile runs: 50

🔄 Loading model: gpt2
✅ Model loaded successfully (cuda:0)

📝 Sample input created: torch.Size([1, 128])

🔧 Initializing Observability Engine...
🔧 Instrumenting model with hooks...
🔥 Running 10 warmup iterations...
🔍 Profiling with 50 iterations...
✅ Profiling complete in 12.5s
📊 Generating dashboard...
✅ Dashboard saved: data/metrics/gpt2_profile_dashboard.html

🎉 PROFILING COMPLETE!
```

### Option 2: Programmatic Usage

Want more control? Use the API directly:

```python
from transformers import AutoModelForCausalLM, AutoTokenizer
from src.observability_engine import ObservabilityEngine
import torch

# 1. Load your model
model_name = "gpt2"
model = AutoModelForCausalLM.from_pretrained(model_name)
tokenizer = AutoTokenizer.from_pretrained(model_name)

# Move to GPU if available
device = "cuda:0" if torch.cuda.is_available() else "cpu"
model = model.to(device)

# 2. Create sample inputs
prompt = "Once upon a time in a distant land"
inputs = tokenizer(prompt, return_tensors="pt").to(device)

# 3. Initialize engine
engine = ObservabilityEngine(
    model=model,
    log_dir="data/metrics",
    config={"model_name": model_name}
)

# 4. Instrument model (registers hooks)
engine.instrument()

# 5. Warmup (stabilizes measurements)
engine.warmup(inputs, num_warmup_runs=10)

# 6. Profile (collects detailed metrics)
report = engine.profile(inputs, num_runs=50)

# 7. Generate dashboard
engine.save_dashboard("my_first_profile")

# 8. Cleanup
engine.finalize()

print("✅ Done! Check data/metrics/my_first_profile_dashboard.html")
```

## Viewing Results

### 1. Open the Dashboard

```bash
# On Windows
start data/metrics/gpt2_profile_dashboard.html

# On macOS
open data/metrics/gpt2_profile_dashboard.html

# On Linux
xdg-open data/metrics/gpt2_profile_dashboard.html
```

You'll see:
-   **Latency Overview**: Bar chart showing which layers are slowest
-   **Memory Timeline**: Line chart of VRAM usage over time
-   **Parameter vs Latency**: Scatter plot identifying outliers
-   **Layer Type Comparison**: Breakdown by layer categories
-   **Bottleneck Analysis**: Top 5 problematic layers

### 2. Check Raw Data

```bash
# View metrics JSONL (one JSON object per line)
cat data/metrics/gpt2_profile_metrics.jsonl | head -5

# Import into pandas for analysis
python -c "
import pandas as pd
df = pd.read_json('data/metrics/gpt2_profile_metrics.jsonl', lines=True)
print(df.groupby('layer_name')['forward_latency_ms'].mean().sort_values(ascending=False).head())
"
```

### 3. Review Summary Report

```bash
cat data/metrics/gpt2_profile_summary.json
```

Sample output:
```json
{
  "profile_name": "gpt2_profile",
  "num_runs": 50,
  "total_layers": 14,
  "end_to_end_latency": {
    "mean_ms": 145.2,
    "total_ms": 7260.0
  },
  "bottlenecks": [
    {"layer_name": "transformer.h.11", "latency_ms": 25.1, "pct": 17.3},
    {"layer_name": "lm_head", "latency_ms": 22.5, "pct": 15.5}
  ]
}
```

## Profiling Different Models

### GPT-2 Variants

```bash
# Small (124M params) - Fast, good for testing
python examples/profile_gpt2.py --model gpt2 --num-samples 50

# Medium (355M params)
python examples/profile_gpt2.py --model gpt2-medium --num-samples 30

# Large (774M params) - Slower, more details
python examples/profile_gpt2.py --model gpt2-large --num-samples 20

# XL (1.5B params) - Requires more VRAM
python examples/profile_gpt2.py --model gpt2-xl --num-samples 10
```

### BERT Models

```bash
python examples/profile_gpt2.py --model bert-base-uncased --num-samples 50
python examples/profile_gpt2.py --model bert-large-uncased --num-samples 30
```

### Custom Configuration

1.  Edit `config/gpt2_config.yaml`
2.  Change parameters (device, batch_size, num_runs, etc.)
3.  Run with custom config:

```bash
python examples/profile_gpt2.py --config config/my_custom_config.yaml
```

## Understanding the Output

### Key Metrics Explained

| Metric | Description | Why it Matters |
|--------|-------------|----------------|
| `forward_latency_ms` | Time for one forward pass | Identifies slow layers |
| `p95_latency_ms` | 95th percentile latency | Captures tail latency |
| `peak_vram_after` | Maximum GPU memory used | Prevents OOM errors |
| `num_parameters` | Number of parameters | Memory footprint indicator |
| `input_shapes` | Tensor dimensions | Understanding data flow |

### Bottleneck Analysis

The dashboard automatically identifies bottlenecks:

```
🔴 Top Bottlenecks:
  1. transformer.h.11: 17.3% (25.1ms)
  2. lm_head: 15.5% (22.5ms)
  3. transformer.h.10: 12.1% (17.6ms)
```

**What this means:**
-   `transformer.h.11` (layer 11) is the slowest
-   Accounts for 17.3% of total inference time
-   **Action**: Consider placing this layer on the fastest device in Phase 2

## Common Issues & Solutions

### Issue 1: CUDA Out of Memory

**Symptom:** `RuntimeError: CUDA out of memory`

**Solutions:**
```python
# Option 1: Use smaller model
python examples/profile_gpt2.py --model gpt2

# Option 2: Switch to CPU
python examples/profile_gpt2.py --model gpt2 --device cpu

# Option 3: Reduce sequence length in config
# Edit config/gpt2_config.yaml: sequence_length: 64
```

### Issue 2: Unicode Error on Windows

**Symptom:** `UnicodeEncodeError: 'charmap' codec can't encode character`

**Solution:**
```bash
# Set environment variable before running
set PYTHONUTF8=1
python examples/profile_gpt2.py --model gpt2
```

### Issue 3: Dashboard Won't Open

**Symptom:** Dashboard file is empty or corrupted

**Solutions:**
```bash
# 1. Check if dashboard was generated
ls -lh data/metrics/gpt2_profile_dashboard.html

# 2. Reinstall plotly if needed
pip install --upgrade plotly

# 3. Check logs
cat data/metrics/logs/*.log | grep -i error
```

### Issue 4: Slow Profiling

**Symptom:** Profiling takes too long

**Solutions:**
```bash
# Reduce number of runs
python examples/profile_gpt2.py --num-samples 10

# Use smaller model
python examples/profile_gpt2.py --model distilgpt2

# Profile on CPU (no VRAM overhead)
python examples/profile_gpt2.py --device cpu
```

## Next Steps

### For Development

1.  **Read the Implementation Guide**: Understand the architecture
    ```bash
    cat docs/IMPLEMENTATION_GUIDE.md
    ```

2.  **Explore the Code**: Start with `src/observability_engine.py`
    ```python
    # See what methods are available
    python -c "from src.observability_engine import ObservabilityEngine; help(ObservabilityEngine)"
    ```

3.  **Run Tests**: Verify everything works
    ```bash
    pytest tests/ -v
    ```

### For Phase 2 (Execution Planning)

Once you have collected metrics:

1.  **Identify Bottlenecks**: Use dashboard to find slow layers
2.  **Plan Sharding**: Decide which layers go on which devices
3.  **Simulate**: Build staged runner to test partitioning

Example code for Phase 2:

```python
# Use collected metrics to plan sharding
from src.planner import ExecutionPlanner

# Load previous profiling data
planner = ExecutionPlanner(metrics_collector)

# Generate partition plan
plan = planner.generate_plan(available_nodes=[
    VirtualNode("node_a", "gpu", vram_gb=24),
    VirtualNode("node_b", "cpu", ram_gb=64)
])

print(plan)
# Output: PartitionPlan with stages optimized for your hardware
```

## Getting Help

-   **Full Documentation**: `docs/IMPLEMENTATION_GUIDE.md`
-   **API Reference**: `docs/API_REFERENCE.md` (coming soon)
-   **Examples**: `examples/` directory
-   **Issues**: Report bugs or ask questions

## What's Next?

After completing Phase 1 (Observability), you'll have:
-   ✅ Detailed metrics for any model
-   ✅ Interactive dashboards
-   ✅ Bottleneck identification
-   ✅ Baseline performance data

**Ready for Phase 2**: Execution Planning with the collected metrics!

Check `docs/IMPLEMENTATION_GUIDE.md` for the complete roadmap.
