#!/usr/bin/env python3
"""
Complete Phase 2 Integration Test

Runs the full Phase 2 pipeline:
1. Load Fase 1 metrics
2. Generate partition plan
3. Run staged simulation
4. Compare with native execution

Usage:
    python test_integration.py --metrics path/to/metrics.jsonl --plan balanced
"""

import argparse
import sys
import json
from pathlib import Path
import torch

sys.path.insert(0, str(Path(__file__).parent.parent))

from src.planner import ExecutionPlanner, PartitionStrategy
from src.plan import VirtualNode, DeviceType
from src.simulator import StagedSimulator, compare_staged_vs_native


def create_heterogeneous_nodes():
    """Create a realistic heterogeneous node setup."""
    return [
        # High-end GPU (primary)
        VirtualNode(
            node_id="rtx_4090",
            device_type=DeviceType.GPU,
            device_name="NVIDIA GeForce RTX 4090",
            vram_gb=24.0,
            ram_gb=64.0,
            compute_score=10.0,
            network_latency_ms=1.0,
            bandwidth_mbps=5000.0,
            supports_fp16=True,
            supports_int8=True,
            priority=10,
            labels={"tier": "high", "vram": "24GB"}
        ),
        
        # Mid-range GPU (secondary)
        VirtualNode(
            node_id="rtx_3070",
            device_type=DeviceType.GPU,
            device_name="NVIDIA GeForce RTX 3070",
            vram_gb=8.0,
            ram_gb=32.0,
            compute_score=6.0,
            network_latency_ms=1.0,
            bandwidth_mbps=5000.0,
            supports_fp16=True,
            supports_int8=False,
            priority=8,
            labels={"tier": "medium", "vram": "8GB"}
        ),
        
        # CPU with large RAM
        VirtualNode(
            node_id="cpu_workstation",
            device_type=DeviceType.CPU,
            device_name="Intel Core i9-12900K",
            vram_gb=0.0,
            ram_gb=128.0,
            compute_score=1.5,
            network_latency_ms=2.0,
            bandwidth_mbps=1000.0,
            supports_fp16=False,
            supports_int8=True,
            priority=5,
            labels={"tier": "compute", "ram": "128GB"}
        ),
        
        # Laptop iGPU
        VirtualNode(
            node_id="laptop_igpu",
            device_type=DeviceType.IGPU,
            device_name="Intel Iris Xe",
            vram_gb=0.0,  # Shared memory
            ram_gb=16.0,
            compute_score=2.0,
            network_latency_ms=5.0,  # Higher latency (WiFi)
            bandwidth_mbps=500.0,
            supports_fp16=True,
            supports_int8=False,
            priority=3,
            labels={"tier": "mobile", "shared": "16GB"}
        ),
    ]


def load_metrics(metrics_file: Path):
    """Load metrics from JSONL and create layer metrics map."""
    from src.metrics import MetricsCollector, LayerMetrics
    
    collector = MetricsCollector()
    
    print(f"📂 Loading metrics: {metrics_file}")
    
    with open(metrics_file, 'r') as f:
        for line in f:
            data = json.loads(line)
            
            metrics = LayerMetrics(
                layer_name=data['layer_name'],
                layer_type=data.get('layer_type', 'Unknown'),
                layer_index=data.get('layer_index', 0),
                forward_latency_ms=data.get('forward_latency_ms', 50.0),
                p50_latency_ms=data.get('p50_latency_ms', 0.0),
                p95_latency_ms=data.get('p95_latency_ms', 0.0),
                p99_latency_ms=data.get('p99_latency_ms', 0.0),
                peak_vram_before=data.get('peak_vram_before', 0),
                peak_vram_after=data.get('peak_vram_after', 100 * 1024 * 1024),
                peak_ram_before=data.get('peak_ram_before', 0),
                peak_ram_after=data.get('peak_ram_after', 100 * 1024 * 1024),
                vram_increase=data.get('vram_increase', 0),
                ram_increase=data.get('ram_increase', 0),
                num_parameters=data.get('num_parameters', 1000000),
                device=data.get('device', 'cpu'),
                input_shapes=data.get('input_shapes', []),
                output_shapes=data.get('output_shapes', []),
                input_dtypes=data.get('input_dtypes', []),
                output_dtypes=data.get('output_dtypes', []),
            )
            
            collector.metrics_history[metrics.layer_name] = [metrics]
    
    print(f"✅ Loaded {len(collector.metrics_history)} layers")
    
    # Create metrics map for simulator
    metrics_map = {}
    for layer_name, runs in collector.metrics_history.items():
        if runs:
            metrics_map[layer_name] = runs[-1]
    
    return collector, metrics_map


def run_integration_test(
    metrics_file: Path,
    strategy: str,
    num_nodes: int,
    num_simulation_runs: int = 20,
):
    """Run complete Phase 2 integration test."""
    
    print("=" * 80)
    print("🧪 PHASE 2 INTEGRATION TEST")
    print("=" * 80)
    
    # Step 1: Load metrics
    try:
        collector, metrics_map = load_metrics(metrics_file)
    except FileNotFoundError:
        print(f"❌ Metrics file not found: {metrics_file}")
        print("\nPlease run Fase 1 profiling first:")
        print("  python examples/profile_gpt2.py --model gpt2 --num-samples 50")
        return
    
    # Step 2: Create nodes
    available_nodes = create_heterogeneous_nodes()
    if num_nodes < len(available_nodes):
        available_nodes = available_nodes[:num_nodes]
    
    print(f"\n🖥️  Available Nodes ({len(available_nodes)}):")
    for node in available_nodes:
        print(f"   - {node.node_id:20s} {node.device_type.value:6s} "
              f"(vram={node.vram_gb:.0f}GB, score={node.compute_score:.1f})")
    
    # Step 3: Generate partition plan
    print(f"\n📋 Generating {strategy.upper()} partition plan...")
    planner = ExecutionPlanner(collector, PartitionStrategy(strategy))
    
    try:
        plan = planner.generate_plan(available_nodes, model_name="gpt2")
        print("\n" + plan.visualize())
    except Exception as e:
        print(f"❌ Error generating plan: {e}")
        import traceback
        traceback.print_exc()
        return
    
    # Step 4: Run staged simulation
    print(f"\n🧪 Running staged simulation ({num_simulation_runs} runs)...")
    
    try:
        simulator = StagedSimulator(plan, metrics_map)
        sample_input = torch.randn(1, 128, 768)  # Typical GPT-2 input shape
        
        staged_stats = simulator.simulate_inference(
            sample_input,
            num_runs=num_simulation_runs,
            warmup_runs=5
        )
        
        print("\n" + simulator.get_stage_summary())
        
    except Exception as e:
        print(f"❌ Error in simulation: {e}")
        import traceback
        traceback.print_exc()
        return
    
    # Step 5: Compare with native execution
    print(f"\n📊 Comparison Analysis")
    
    # Estimate native latency (sum of all layer latencies)
    native_latency = sum(m.forward_latency_ms for m in metrics_map.values())
    
    try:
        comparison = compare_staged_vs_native(
            plan=plan,
            layer_metrics=metrics_map,
            native_latency_ms=native_latency,
            num_comparison_runs=num_simulation_runs,
        )
        
    except Exception as e:
        print(f"❌ Error in comparison: {e}")
        import traceback
        traceback.print_exc()
        return
    
    # Step 6: Generate final report
    print("\n" + "=" * 80)
    print("📝 INTEGRATION TEST REPORT")
    print("=" * 80)
    
    report = {
        "test_config": {
            "strategy": strategy,
            "num_nodes": num_nodes,
            "num_simulation_runs": num_simulation_runs,
        },
        "plan": plan.get_summary(),
        "simulation": staged_stats,
        "comparison": comparison,
    }
    
    # Save report
    report_file = f"data/reports/integration_test_{strategy}.json"
    Path(report_file).parent.mkdir(parents=True, exist_ok=True)
    
    with open(report_file, 'w') as f:
        json.dump(report, f, indent=2)
    
    print(f"✅ Report saved: {report_file}")
    
    # Summary
    print("\n" + "=" * 80)
    print("✅ INTEGRATION TEST COMPLETE")
    print("=" * 80)
    
    if comparison["overhead_pct"] < 10:
        print("🎉 Excellent! Staged execution overhead <10%")
    elif comparison["overhead_pct"] < 30:
        print("✅ Good! Staged execution overhead <30%")
    else:
        print("⚠️  High overhead detected - consider optimizing the plan")
    
    print("\nNext steps:")
    print("1. Review detailed report:", report_file)
    print("2. Analyze bottleneck stage for optimization")
    print("3. Test with real distributed execution (Phase 3)")
    print("4. Consider different planning strategies")


def main():
    parser = argparse.ArgumentParser(description="Phase 2 Integration Test")
    
    parser.add_argument(
        '--metrics',
        type=str,
        default='data/metrics/gpt2_profile_metrics.jsonl',
        help='Path to metrics JSONL file'
    )
    parser.add_argument(
        '--plan',
        type=str,
        default='balanced',
        choices=['balanced', 'bottleneck_first', 'memory_aware', 'latency_optimized'],
        help='Planning strategy'
    )
    parser.add_argument(
        '--num-nodes',
        type=int,
        default=3,
        help='Number of nodes to use'
    )
    parser.add_argument(
        '--runs',
        type=int,
        default=20,
        help='Number of simulation runs'
    )
    
    args = parser.parse_args()
    
    try:
        run_integration_test(
            Path(args.metrics),
            args.plan,
            args.num_nodes,
            args.runs,
        )
    except KeyboardInterrupt:
        print("\n\n⚠️  Test interrupted by user")
    except Exception as e:
        print(f"\n\n❌ Test failed: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == '__main__':
    main()
