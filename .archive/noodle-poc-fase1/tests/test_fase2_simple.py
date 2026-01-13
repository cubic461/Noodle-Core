#!/usr/bin/env python3
"""
Simplified test voor Fase 2 - Staged Execution Simulation
Test de planning + simulatie functionaliteit met ASCII art output.
"""

import sys
import os
from pathlib import Path

# Set UTF-8 voor Windows console (ondanks Unicode problemen, toch proberen)
os.environ['PYTHONUTF8'] = '1'

# Add project to path
PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT))
sys.path.insert(0, str(PROJECT_ROOT / 'src'))

try:
    from plan import VirtualNode, DeviceType, create_fake_metrics_for_demo, PartitionPlan
    from noodle_poc.metrics import MetricsCollector, LayerMetrics
    from planner import ExecutionPlanner, PartitionStrategy
except ImportError as e:
    print(f"Import failed: {e}")
    raise


def test_fase2_simulation():
    """End-to-end test voor Fase 2 components."""
    print("="*80)
    print("FASE 2 TEST - SIMULATED EXECUTION")
    print("="*80)

    # Stap 1: Hardware setup (simulate mixed hardware)
    print("\n[STEP 1] Hardware Nodes Setup")
    print("-" * 40)
    nodes = [
        VirtualNode(
            node_id="dGPU_RTX3090",
            device_type=DeviceType.GPU,
            compute_score=100.0,
            vram_gb=24.0,
            memory_bandwidth_gbs=900.0,
        ),
        VirtualNode(
            node_id="iGPU_Intel",
            device_type=DeviceType.IGPU,
            compute_score=25.0,
            vram_gb=6.0,
            memory_bandwidth_gbs=200.0,
        ),
        VirtualNode(
            node_id="CPU_Ryzen9",
            device_type=DeviceType.CPU,
            compute_score=10.0,
            ram_gb=64.0,
            memory_bandwidth_gbs=50.0,
        ),
    ]

    for node in nodes:
        print(node)

    # Stap 2: Load metrics (from Fase 1 or fake demo)
    print("\n[STEP 2] Generating Fake Metrics (26 layers)")
    print("-" * 40)

    fake_metrics = create_fake_metrics_for_demo()

    # Create metrics collector
    collector = MetricsCollector()
    collector.metrics_history = {name: [metric] for name, metric in fake_metrics.items()}

    print(f"Layers loaded: {len(collector.metrics_history)}")

    # Stap 3: Generate planning met BALANCED strategy
    print("\n[STEP 3] Generate Balanced Plan")
    print("-" * 40)

    planner = ExecutionPlanner(
        metrics_collector=collector,
        strategy=PartitionStrategy.BALANCED,
    )

    plan = planner.generate_plan(available_nodes=nodes, model_name="gpt2_fake")

    # Print plan visualization
    print("\n[PLAN RESULT]")
    print("-" * 40)
    print(plan.visualize())

    # Stap 4: Analyse optimalisatie notities
    print("\n[STEP 4] Optimization Analysis")
    print("-" * 40)
    for note in plan.optimization_notes:
        print(f"  {note}")

    # Stap 5: Simpele bottleneck identificatie
    print("\n[STEP 5] Bottleneck Detection")
    print("-" * 40)
    if plan.bottleneck_stage_id is not None:
        bottleneck = plan.stages[plan.bottleneck_stage_id]
        print(f"[WARN] Bottleneck detected:")
        print(f"  Stage ID: {plan.bottleneck_stage_id}")
        print(f"  Latency: {plan.bottleneck_latency_ms:.1f}ms")
        print(f"  Node: {bottleneck.node.node_id}")
        print(f"  Reason: {plan.bottleneck_reason}")

        # Identificeer de top 5 langzaamste lagen
        print("\n  Top 5 Slowest Layers:")
        sorted_layers = sorted(
            plan.stages[plan.bottleneck_stage_id].layers,
            key=lambda name: collector.metrics_history[name][0].forward_latency_ms,
            reverse=True,
        )[:5]

        for layer_name in sorted_layers:
            lat = collector.metrics_history[layer_name][0].forward_latency_ms
            pct = (lat / plan.total_expected_latency_ms) * 100
            print(f"    - {layer_name}: {lat:.1f}ms ({pct:.1f}%)")

    # Stap 6: Simpeel geheugen analyse
    print("\n[STEP 6] Memory Footprint")
    print("-" * 40)
    for i, stage in enumerate(plan.stages):
        mem_gb = stage.memory_required_mb / 1024
        print(f"Stage {i} ({stage.node.node_id}): {mem_gb:.2f}GB")
    print(f"Total model: {sum(s.memory_required_mb for s in plan.stages) / 1024:.2f}GB")

    # Stap 7: Key metrics samenvatting
    print("\n[STEP 7] Key Metrics Summary")
    print("-" * 40)
    print(f"Total stages: {len(plan.stages)}")
    print(f"Expected latency: {plan.total_expected_latency_ms:.1f}ms")
    print(f"Load balance score: {plan.load_balance_score:.2f} / 1.0")
    print(f"Total layers partitioned: {len(collector.metrics_history)}")

    print("\n" + "=" * 80)
    print("[OK] Test successful!")
    print("=" * 80)

    return True


if __name__ == '__main__':
    try:
        success = test_fase2_simulation()
        sys.exit(0 if success else 1)
    except Exception as e:
        print(f"\n[ERROR] Test failed: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
