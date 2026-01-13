#!/usr/bin/env python3
"""
Simplified test for balanced planning strategy.
Fixed import path structure.
"""

import sys
import os
from pathlib import Path

# Set UTF-8 encoding for Windows console
os.environ['PYTHONUTF8'] = '1'

# Add project to path
PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT))
sys.path.insert(0, str(PROJECT_ROOT / 'src'))

# Import using correct path
try:
    from plan import VirtualNode, DeviceType, create_fake_metrics_for_demo
    from noodle_poc.metrics import MetricsCollector
    from planner import ExecutionPlanner, PartitionStrategy
except ImportError as e:
    print(f"Import failed: {e}")
    print("Available files in src/:")
    for f in os.listdir(PROJECT_ROOT / 'src'):
        print(f"  - {f}")
    raise

def test_balanced_planning():
    """Test basic balanced partitioning strategy."""
    print("=" * 80)
    print("BALANCED PLANNING TEST - SIMPLIFIED")
    print("=" * 80)

    # Create test hardware nodes
    nodes = [
        VirtualNode(
            node_id="gpu_0",
            device_type=DeviceType.GPU,
            compute_score=100.0,
            vram_gb=24.0,
            memory_bandwidth_gbs=900.0,
        ),
        VirtualNode(
            node_id="cpu_1",
            device_type=DeviceType.CPU,
            compute_score=10.0,
            ram_gb=128.0,
            memory_bandwidth_gbs=50.0,
        ),
    ]

    # Load fake metrics
    fake_metrics = create_fake_metrics_for_demo()

    # Create metrics collector mock
    collector = MetricsCollector()
    collector.metrics_history = {name: [metric] for name, metric in fake_metrics.items()}

    # Generate plan
    planner = ExecutionPlanner(
        metrics_collector=collector,
        strategy=PartitionStrategy.BALANCED,
    )

    plan = planner.generate_plan(available_nodes=nodes, model_name="gpt2_fake")

    # Print results
    print("\n" + plan.visualize())
    print("\nPLAN GENERATED SUCCESSFULLY!")
    print(f"   Total stages: {len(plan.stages)}")
    print(f"   Expected latency: {plan.total_expected_latency_ms:.1f}ms")
    print(f"   Load balance score: {plan.load_balance_score:.2f}")
    print("=" * 80)

    return True

if __name__ == '__main__':
    try:
        success = test_balanced_planning()
        sys.exit(0 if success else 1)
    except Exception as e:
        print(f"Test failed: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
