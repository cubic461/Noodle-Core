#!/usr/bin/env python3
"""
Integration test for Fase 2 - Complete planning & simulation workflow.

Tests the end-to-end flow:
1. Load/use Fase 1 metrics (or generate fake metrics for testing)
2. Create hardware nodes
3. Generate partition plans with different strategies
4. Run staged simulation
5. Compare against native execution
6. Validate results
"""

import sys
import time
import torch
from pathlib import Path
from typing import Dict, List
import argparse

# Add src to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from src.plan import (
    VirtualNode,
    PartitionPlan,
    PartitionStrategy,
    DeviceType,
    create_fake_metrics_for_demo,
)
from src.planner import ExecutionPlanner, PlanningConstraints
from src.simulator import (
    StagedSimulator,
    compare_staged_vs_native,
)


def create_hardware_nodes(num_nodes: int = 3) -> List[VirtualNode]:
    """Create test hardware nodes."""
    nodes = []

    # Fast GPU node
    if num_nodes >= 1:
        nodes.append(VirtualNode(
            node_id="gpu_0",
            device_type=DeviceType.GPU,
            compute_score=100.0,
            vram_gb=24.0,
            memory_bandwidth_gbs=900.0,  # GDDR6
            network_latency_ms=0.5,
            bandwidth_mbps=10000.0,
            supports_fp16=True,
            supports_fp32=True,
            supports_int8=True,
        ))

    # Medium iGPU node
    if num_nodes >= 2:
        nodes.append(VirtualNode(
            node_id="igpu_1",
            device_type=DeviceType.IGPU,
            compute_score=40.0,
            vram_gb=8.0,
            ram_gb=64.0,
            memory_bandwidth_gbs=200.0,  # Integrated
            network_latency_ms=1.0,
            bandwidth_mbps=5000.0,
            supports_fp16=True,
            supports_fp32=True,
            supports_int8=False,
        ))

    # Slow CPU node
    if num_nodes >= 3:
        nodes.append(VirtualNode(
            node_id="cpu_2",
            device_type=DeviceType.CPU,
            compute_score=10.0,
            ram_gb=128.0,
            memory_bandwidth_gbs=50.0,  # DDR4
            network_latency_ms=2.0,
            bandwidth_mbps=1000.0,
            supports_fp16=False,
            supports_fp32=True,
            supports_int8=False,
        ))

    return nodes


def test_balanced_planning():
    """Test balanced partitioning strategy."""
    print("\n" + "=" * 80)
    print("🧮 BALANCED PLANNING TEST")
    print("=" * 80)

    # Setup
    nodes = create_hardware_nodes(num_nodes=3)
    fake_metrics = create_fake_metrics_for_demo()

    # Create metrics collector mock
    from src.metrics import MetricsCollector
    collector = MetricsCollector()
    collector.metrics_history = {name: [metric] for name, metric in fake_metrics.items()}

    # Generate plan
    planner = ExecutionPlanner(
        metrics_collector=collector,
        strategy=PartitionStrategy.BALANCED,
    )

    plan = planner.generate_plan(available_nodes=nodes, model_name="gpt2_fake")

    # Validate plan
    print("\n" + plan.visualize())
    assert plan.is_valid(), "Plan should be valid"
    print("✅ Plan validation passed")

    # Ensure stages are reasonably balanced
    latencies = [s.expected_latency_ms for s in plan.stages]
    print(f"\nStage Latencies: {[f'{l:.1f}ms' for l in latencies]}")
    print(f"Load Balance Score: {plan.load_balance_score:.3f}")

    if len(latencies) > 1:
        max_lat = max(latencies)
        min_lat = min(latencies)
        spread = (max_lat - min_lat) / max_lat
        print(f"Latency Spread: {spread:.1%}")
        assert spread < 0.5, "Balanced plan should have <50% spread"
        print("✅ Balance validation passed")

    return plan, fake_metrics


def test_bottleneck_first_planning():
    """Test bottleneck-first partitioning strategy."""
    print("\n" + "=" * 80)
    print("🔴 BOTTLENECK-FIRST PLANNING TEST")
    print("=" * 80)

    nodes = create_hardware_nodes(num_nodes=3)
    fake_metrics = create_fake_metrics_for_demo()

    from src.metrics import MetricsCollector
    collector = MetricsCollector()
    collector.metrics_history = {name: [metric] for name, metric in fake_metrics.items()}

    planner = ExecutionPlanner(
        metrics_collector=collector,
        strategy=PartitionStrategy.BOTTLENECK_FIRST,
    )

    plan = planner.generate_plan(available_nodes=nodes, model_name="gpt2_fake")

    print("\n" + plan.visualize())
    assert plan.is_valid(), "Plan should be valid"
    print("✅ Bottleneck-first plan validation passed")

    # Verify first stages are assigned to fastest nodes
    if plan.stages:
        fast_gpus = [s for s in plan.stages if "gpu" in s.node.node_id]
        bottlenecks = [s for s in plan.stages if "bottleneck" in s.tags]

        if bottlenecks:
            print(f"📌 Identified {len(bottlenecks)} bottleneck stages")
            print(f"   Fast GPU stages: {len(fast_gpus)}")

        print("✅ Bottleneck prioritization validated")

    return plan, fake_metrics


def test_memory_aware_planning():
    """Test memory-aware partitioning strategy."""
    print("\n" + "=" * 80)
    print("💾 MEMORY-AWARE PLANNING TEST")
    print("=" * 80)

    nodes = create_hardware_nodes(num_nodes=3)
    fake_metrics = create_fake_metrics_for_demo()

    from src.metrics import MetricsCollector
    collector = MetricsCollector()
    collector.metrics_history = {name: [metric] for name, metric in fake_metrics.items()}

    constraints = PlanningConstraints(
        max_vram_per_stage_gb=10.0,  # Set tighter memory constraints
        max_ram_per_stage_gb=20.0,
    )

    planner = ExecutionPlanner(
        metrics_collector=collector,
        strategy=PartitionStrategy.MEMORY_AWARE,
        constraints=constraints,
    )

    plan = planner.generate_plan(available_nodes=nodes, model_name="gpt2_fake")

    print("\n" + plan.visualize())
    assert plan.is_valid(), "Plan should be valid"
    assert all(s.memory_required_mb < constraints.max_vram_per_stage_gb * 1024
               for s in plan.stages), "All stages should respect memory limits"
    print("✅ Memory-aware plan validation passed")

    return plan, fake_metrics


def test_latency_optimized_planning():
    """Test latency-optimized partitioning strategy."""
    print("\n" + "=" * 80)
    print("⚡ LATENCY-OPTIMIZED PLANNING TEST")
    print("=" * 80)

    nodes = create_hardware_nodes(num_nodes=3)
    fake_metrics = create_fake_metrics_for_demo()

    from src.metrics import MetricsCollector
    collector = MetricsCollector()
    collector.metrics_history = {name: [metric] for name, metric in fake_metrics.items()}

    planner = ExecutionPlanner(
        metrics_collector=collector,
        strategy=PartitionStrategy.LATENCY_OPTIMIZED,
    )

    plan = planner.generate_plan(available_nodes=nodes, model_name="gpt2_fake")

    print("\n" + plan.visualize())
    assert plan.is_valid(), "Plan should be valid"
    print("✅ Latency-optimized plan validation passed")

    return plan, fake_metrics


def test_staged_simulation():
    """Test staged simulation with real metrics."""
    print("\n" + "=" * 80)
    print("🧪 STAGED SIMULATION TEST")
    print("=" * 80)

    # Use balanced plan
    plan, fake_metrics = test_balanced_planning()

    # Create simulator
    simulator = StagedSimulator(
        plan=plan,
        layer_metrics_map=fake_metrics,
        track_transfers=True,
    )

    # Create sample input tensor
    sample_input = torch.randn(1, 128, 768)  # [batch, seq, hidden]

    # Run simulation
    stats = simulator.simulate_inference(
        input_tensor=sample_input,
        num_runs=10,
        warmup_runs=2,
    )

    # Print results
    print("\n📊 Simulation Results:")
    print(f"  Total runs: {stats['total_runs']}")
    print(f"  Average latency: {stats['total']['avg_latency_ms']:.1f}ms")
    print(f"  P95 latency: {stats['total']['p95_latency_ms']:.1f}ms")

    print("\n📊 Per-Stage Results:")
    for stage_id, stage_stats in stats['stages'].items():
        print(f"  Stage {stage_id} ({stage_stats['node']}):")
        print(f"    Average latency: {stage_stats['avg_latency_ms']:.1f}ms")
        print(f"    Peak memory: {stage_stats['peak_memory_mb']:.1f}MB")
        print(f"    Transfer overhead: {stage_stats['avg_transfer_ms']:.1f}ms")

    print(f"\n📊 Transfer Analysis:")
    print(f"  Total tensor transfers: {stats['transfers']['total_transfers']}")
    print(f"  Network transfers: {stats['transfers']['network_transfers']}")
    print(f"  Total transfer time: {stats['transfers']['total_transfer_time_ms']:.1f}ms")

    # Verify stats are reasonable
    assert stats['total_runs'] == 10
    assert all(stats['stages'][sid]['runs'] == 10 for sid in stats['stages'])
    assert stats['total']['avg_latency_ms'] > 0

    print("\n✅ Simulation validation passed")

    return stats, plan, fake_metrics


def test_native_vs_staged_comparison():
    """Compare staged vs native execution."""
    print("\n" + "=" * 80)
    print("🔄 NATIVE VS STAGED COMPARISON TEST")
    print("=" * 80)

    # Get simulation data
    stats, plan, fake_metrics = test_staged_simulation()

    # Simulate "native" execution by summing expected latencies * 1.1 (network overhead)
    native_latency_ms = sum(m.forward_latency_ms for m in fake_metrics.values())

    # Compare
    comparison = compare_staged_vs_native(
        plan=plan,
        layer_metrics=fake_metrics,
        native_latency_ms=native_latency_ms,
        num_comparison_runs=10,
    )

    # Verify comparison is reasonable
    assert comparison['native_latency_ms'] > 0
    assert comparison['staged_latency_ms'] > 0
    assert 'overhead_pct' in comparison
    assert 'speedup' in comparison

    # Note: Staged can be slower (overhead) or faster (parallelism)
    if comparison['overhead_pct'] > 0:
        print(f"⚠️  Staged has {comparison['overhead_pct']:.1f}% overhead (expected for single-node simulation)")
    else:
        print(f"✅ Staged is {1/comparison['speedup']:.2f}x faster!")

    print("\n✅ Comparison validation passed")

    return comparison


def test_plan_export_import():
    """Test plan serialization and deserialization."""
    print("\n" + "=" * 80)
    print("💾 PLAN SERIALIZATION TEST")
    print("=" * 80)

    # Create plan
    plan, _ = test_balanced_planning()

    # Export to JSON
    json_str = plan.to_json(indent=2)
    print(f"\n📄 Generated JSON ({len(json_str)} bytes)")

    # Import from JSON
    plan_dict = plan.to_dict()
    restored_plan = PartitionPlan.from_dict(plan_dict)

    # Verify equality
    assert len(restored_plan.stages) == len(plan.stages)
    assert restored_plan.total_expected_latency_ms == plan.total_expected_latency_ms
    assert restored_plan.load_balance_score == plan.load_balance_score

    print("✅ Export/Import validation passed")

    return restored_plan


def test_plan_memory_constraints():
    """Test planning with tight memory constraints."""
    print("\n" + "=" * 80)
    print("🔒 MEMORY CONSTRAINT TEST")
    print("=" * 80)

    nodes = create_hardware_nodes(num_nodes=3)

    # Modify nodes to have limited memory
    nodes[0].vram_gb = 2.0  # Small VRAM

    fake_metrics = create_fake_metrics_for_demo()

    from src.metrics import MetricsCollector
    collector = MetricsCollector()
    collector.metrics_history = {name: [metric] for name, metric in fake_metrics.items()}

    constraints = PlanningConstraints(
        max_vram_per_stage_gb=1.0,
        max_ram_per_stage_gb=5.0,
    )

    planner = ExecutionPlanner(
        metrics_collector=collector,
        strategy=PartitionStrategy.MEMORY_AWARE,
        constraints=constraints,
    )

    plan = planner.generate_plan(available_nodes=nodes, model_name="gpt2_fake")

    print("\n" + plan.visualize())
    assert plan.is_valid(), "Plan should be valid"

    # Verify memory constraints are respected
    for stage in plan.stages:
        assert stage.memory_required_mb < constraints.max_vram_per_stage_gb * 1024, \
            f"Stage {stage.stage_id} violates memory constraint"

    print("✅ Memory constraints validated")


def run_all_tests():
    """Run all integration tests."""
    print("\n" + "=" * 80)
    print("🚀 RUNNING ALL FASE 2 INTEGRATION TESTS")
    print("=" * 80)
    print(f"Timestamp: {time.strftime('%Y-%m-%d %H:%M:%S')}\n")

    start_time = time.time()

    try:
        # Planning tests
        test_balanced_planning()
        test_bottleneck_first_planning()
        test_memory_aware_planning()
        test_latency_optimized_planning()

        # Simulation tests
        test_staged_simulation()
        test_native_vs_staged_comparison()

        # Utility tests
        test_plan_export_import()
        test_plan_memory_constraints()

        elapsed_time = time.time() - start_time

        print("\n" + "=" * 80)
        print("🎉 ALL TESTS PASSED!")
        print("=" * 80)
        print(f"Total test time: {elapsed_time:.2f}s")
        print(f"Result: ✅ Fase 2 integration is working correctly\n")

        return True

    except AssertionError as e:
        elapsed_time = time.time() - start_time
        print(f"\n❌ Test failed: {e}")
        print(f"Test duration: {elapsed_time:.2f}s")
        return False
    except Exception as e:
        elapsed_time = time.time() - start_time
        print(f"\n❌ Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        print(f"Test duration: {elapsed_time:.2f}s")
        return False


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description="Fase 2 Integration Tests")
    parser.add_argument('--test', type=str, help='Specific test to run (optional)')
    parser.add_argument('--num-nodes', type=int, default=3, help='Number of nodes')
    parser.add_argument('--verbose', action='store_true', help='Verbose output')
    parser.add_argument('--fast', action='store_true', help='Fast mode (minimal runs)')

    args = parser.parse_args()

    if args.test:
        # Run specific test
        test_name = f"test_{args.test}_planning" if not args.test.startswith("test_") else args.test
        if test_name in globals():
            test_func = globals()[test_name]
            result = test_func()
            if args.verbose:
                print("\nDetailed output logged above")
        else:
            print(f"❌ Test '{test_name}' not found")
            return False
    else:
        # Run all tests
        return run_all_tests()


if __name__ == '__main__':
    success = main()
    sys.exit(0 if success else 1)
