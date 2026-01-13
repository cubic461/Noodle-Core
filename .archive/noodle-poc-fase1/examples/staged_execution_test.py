"""
NoodleCore Fase 2: Staged Execution Test Script
Demonstrates the complete Fase 2 workflow:
1. Load Fase 1 metrics (or profile if needed)
2. Create optimized partition plan
3. Simulate staged execution
4. Benchmark vs native PyTorch
"""

import sys
import os
import argparse
from pathlib import Path
import torch
import pandas as pd
from transformers import GPT2LMHeadModel, GPT2Tokenizer

# Add src to path for imports
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(project_root, 'src'))

from noodle_poc.observability_engine import ObservabilityEngine
from noodle_poc.planner import ExecutionPlanner, PartitionPlan
from noodle_poc.simulator import StagedSimulator, VirtualNode
from noodle_poc.benchmarker import ExecutionBenchmarker


def load_gpt2_model(model_name: str = "gpt2", device: str = "cpu", dtype: str = "fp32"):
    """Load GPT-2 model and tokenizer."""
    print(f"[LOAD] Loading model: {model_name} (device: {device})")
    
    tokenizer = GPT2Tokenizer.from_pretrained(model_name)
    if tokenizer.pad_token is None:
        tokenizer.pad_token = tokenizer.eos_token
    
    model = GPT2LMHeadModel.from_pretrained(model_name)
    model.eval()
    
    if dtype == "fp16":
        model = model.half()
    elif dtype == "bf16":
        model = model.bfloat16()
    
    model = model.to(torch.device(device))
    
    param_count = sum(p.numel() for p in model.parameters())
    print(f"[SUCCESS] Loaded {param_count:,} parameters")
    
    return model, tokenizer


def create_sample_inputs(tokenizer, prompts: list = None, max_length: int = 128, device: str = "cpu"):
    """Create tokenized inputs from text prompts."""
    if prompts is None:
        prompts = ["The quick brown fox jumps over the lazy dog"]
    
    encoded = tokenizer(
        prompts,
        padding="max_length",
        truncation=True,
        max_length=max_length,
        return_tensors="pt",
    )
    
    inputs = {k: v.to(torch.device(device)) for k, v in encoded.items()}
    return inputs


def main_fase2_demo():
    """Main Fase 2 demonstration workflow."""
    print("="*80)
    print("NOODLECORE FASE 2: STAGED EXECUTION DEMO")
    print("="*80)
    print("")
    
    # Step 1: Load or create metrics from Fase 1
    print("[STEP 1] Loading observability metrics from Fase 1")
    print("-" * 80)
    
    metrics_file = Path("data/metrics/gpt2_metrics.jsonl")
    if metrics_file.exists():
        print(f"[FOUND] Found metrics file: {metrics_file}")
        planner = ExecutionPlanner.from_jsonl(metrics_file)
        print(f"[LOADED] Loaded {len(planner.metrics)} layer metrics")
    else:
        print("✗ No Fase 1 metrics found. Running quick profile...")
        
        device = "cpu"
        model, tokenizer = load_gpt2_model("gpt2", device=device)
        inputs = create_sample_inputs(tokenizer, device=device)
        
        engine = ObservabilityEngine(model, log_dir=Path("data/metrics"))
        engine.instrument()
        engine.warmup(inputs, num_warmup_runs=3)
        
        results = engine.profile(inputs, num_runs=5, profile_name="gpt2_demo")
        planner = ExecutionPlanner.from_observability_engine(engine)
        
        print(f"✓ Profiled {results['total_layers']} layers")
    
    # Step 2: Create optimized partition plan
    print("")
    print("[STEP 2] Creating optimized partition plan")
    print("-" * 80)
    
    constraints = {
        'num_stages': 3,
        'max_memory_per_stage_mb': 8000,
        'latency_balance_threshold': 0.3,
    }
    
    print(f"Constraints: {constraints}")
    
    partition_plan = planner.create_plan(constraints)
    
    print(f"✓ Created {partition_plan.total_stages()} stage partition plan")
    print("")
    
    # Display plan details
    print("PARTITION PLAN SUMMARY:")
    print("-" * 80)
    for stage_id in sorted(partition_plan.stages.keys()):
        metadata = partition_plan.get_metadata(stage_id)
        layers = partition_plan.get_stage_layers(stage_id)
        
        print(f"{stage_id}:")
        print(f"  Layers: {metadata['total_layers']}")
        print(f"  Latency: {metadata['total_latency_ms']:.2f} ms")
        print(f"  Parameters: {metadata['parameters']:,}")
        print(f"  Layer names: {', '.join(layers[:3])}{'...' if len(layers) > 3 else ''}")
    
    # Save plan report
    report_file = Path("data/partition_plan_report.txt")
    report = planner.generate_report(partition_plan, output_file=report_file)
    
    print("")
    print(f"✓ Detailed report saved: {report_file}")
    
    # Step 3: Simulate staged execution
    print("")
    print("[STEP 3] Simulating staged execution")
    print("-" * 80)
    
    # Configure virtual nodes
    virtual_nodes = {
        'stage_0': VirtualNode(
            node_id='gpu_node_0',
            device='cpu',  # Using CPU for compatibility
            bandwidth_mbps=32000,
            compute_factor=1.0
        ),
        'stage_1': VirtualNode(
            node_id='cpu_node',
            device='cpu',
            bandwidth_mbps=16000,
            compute_factor=0.5
        ),
        'stage_2': VirtualNode(
            node_id='gpu_node_1',
            device='cpu',
            bandwidth_mbps=32000,
            compute_factor=1.0
        ),
    }
    
    print("Virtual nodes configured:")
    for stage_id, node in virtual_nodes.items():
        print(f"  {stage_id}: {node.node_id} ({node.device}, {node.bandwidth_mbps} Mbps)")
    
    # Create simulator
    simulator = StagedSimulator(
        partition_plan=partition_plan,
        virtual_nodes=virtual_nodes,
        enable_profiling=True
    )
    
    print("")
    print("Running simulation...")
    
    # Load model and inputs
    model, tokenizer = load_gpt2_model("gpt2", device="cpu")
    inputs = create_sample_inputs(tokenizer, device="cpu")
    
    # Run simulation
    try:
        output, trace = simulator.simulate(model, inputs)
        
        if trace:
            print("✓ Simulation completed successfully")
            print("")
            print(trace.generate_report())
        else:
            print("✗ No trace data available")
    except Exception as e:
        print(f"✗ Simulation error: {e}")
        import traceback
        traceback.print_exc()
    
    # Step 4: Benchmark comparison
    print("")
    print("[STEP 4] Benchmarking staged vs native execution")
    print("-" * 80)
    
    benchmarker = ExecutionBenchmarker(
        num_warmup_runs=3,
        num_benchmark_runs=5
    )
    
    try:
        results = benchmarker.benchmark(model, inputs, simulator)
        
        print("")
        print(results.get_summary())
        
        # Save benchmark results
        benchmark_file = Path("data/benchmark_results.json")
        results.save(benchmark_file)
        print(f"✓ Benchmark results saved: {benchmark_file}")
        
    except Exception as e:
        print(f"✗ Benchmarking error: {e}")
        import traceback
        traceback.print_exc()
    
    # Step 5: Summary
    print("")
    print("="*80)
    print("FASE 2 STAGED EXECUTION DEMO COMPLETE!")
    print("="*80)
    print("")
    print("Deliverables:")
    print(f"  ✓ Partition plan: {report_file}")
    print(f"  ✓ Benchmark results: {benchmark_file if Path('data/benchmark_results.json').exists() else 'data/benchmark_results.json'}")
    print(f"  ✓ Execution trace: Included in simulation output")
    print("")
    print("Next steps:")
    print("  - Review partition plan for optimization opportunities")
    print("  - Analyze bottleneck stages for further splitting")
    print("  - Move to Fase 3: Network distributed execution")
    print("")


def main():
    """CLI entry point."""
    parser = argparse.ArgumentParser(
        description="NoodleCore Fase 2: Staged Execution Demo"
    )
    parser.add_argument(
        '--model',
        type=str,
        default='gpt2',
        help='Hugging Face model name'
    )
    parser.add_argument(
        '--device',
        type=str,
        default='cpu',
        help='Device for execution'
    )
    parser.add_argument(
        '--num-stages',
        type=int,
        default=3,
        help='Number of pipeline stages'
    )
    parser.add_argument(
        '--output-dir',
        type=str,
        default='data',
        help='Output directory for results'
    )
    
    args = parser.parse_args()
    
    # Run demo
    try:
        main_fase2_demo()
    except KeyboardInterrupt:
        print("\n\nDemo interrupted by user")
    except Exception as e:
        print(f"\n\n✗ Demo error: {e}")
        import traceback
        traceback.print_exc()


if __name__ == '__main__':
    main()
