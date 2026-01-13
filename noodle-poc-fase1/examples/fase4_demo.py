r"""
Fase 4 Demo: Advanced Planning with Adaptive Capabilities
Demonstrates runtime adaptation and heterogeneous hardware support.
"""

import os
import sys
from pathlib import Path
import logging
from datetime import datetime

# Add src to path
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

# Disable utf mode for Windows
import os
os.environ['PYTHONUTF8'] = '1'

from noodle_poc.advanced.planner import AdaptivePlanner, RuntimeMetrics
from noodle_poc.capability_matcher import (
    CapabilityMatcher,
    HardwareCapability,
    DeviceType,
    LayerRequirements,
    auto_detect_capabilities,
)
from noodle_poc.planner.core import ExecutionPlanner
import torch


def setup_logging(level=logging.INFO):
    """Setup logging configuration."""
    logging.basicConfig(
        level=level,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )


def demo_hardware_capability_matching():
    """Demonstrate hardware capability matching."""
    print("\n" + "="*80)
    print("FASE 4A - HARDWARE CAPABILITY MATCHING")
    print("="*80)
    print()

    # Auto-detect hardware
    print("[Step 1] Auto-detecting hardware capabilities...")
    capabilities = auto_detect_capabilities()

    matcher = CapabilityMatcher()
    for device_id, cap in capabilities.items():
        matcher.register_device(cap)
        print(f"  ✓ {device_id}: {cap.device_name}")
        print(f"    Type: {cap.device_type.value}")
        print(f"    Memory: {cap.memory_gb:.1f} GB ({cap.available_memory_gb:.1f} GB available)")
        print(f"    Compute Score: {cap.compute_score:.2f}")
        print(f"    FP16: {cap.has_fp16}, INT8: {cap.has_int8}")

    print()

    # Create sample layer requirements
    print("[Step 2] Matching layers to hardware...")
    print()

    test_requirements = [
        LayerRequirements(
            layer_name="lm_head",
            layer_type="Linear",
            memory_gb=2.0,
            compute_millions=500.0,
            is_latency_sensitive=True,
            requires_fp16=True,
        ),
        LayerRequirements(
            layer_name="transformer.h.0",
            layer_type="GPT2Block",
            memory_gb=1.5,
            compute_millions=200.0,
            is_latency_sensitive=False,
        ),
        LayerRequirements(
            layer_name="embeddings",
            layer_type="Embedding",
            memory_gb=0.8,
            compute_millions=50.0,
            requires_fast_memory=False,
        ),
    ]

    for req in test_requirements:
        print(f"Layer: {req.layer_name} ({req.layer_type})")
        print(f"  Memory: {req.memory_gb:.1f} GB")
        print(f"  Latency-sensitive: {req.is_latency_sensitive}")

        # Find optimal device with different strategies
        device_id, score = matcher.find_optimal_device(req, strategy="latency")
        if device_id:
            print(f"  ✓ Latency strategy: {device_id} (score: {score:.2f})")

        device_id, score = matcher.find_optimal_device(req, strategy="memory")
        if device_id:
            print(f"  ✓ Memory strategy: {device_id} (score: {score:.2f})")

        device_id, score = matcher.find_optimal_device(req, strategy="balanced")
        if device_id:
            print(f"  ✓ Balanced strategy: {device_id} (score: {score:.2f})")

        print()

    # Check model accommodation
    print("[Step 3] Model accommodation check...")
    feasible, assignment = matcher.can_accommodate_model(test_requirements)

    print(f"  Model feasible: {feasible}")
    if feasible:
        for device_id, layers in assignment.items():
            if layers:
                print(f"  {device_id}: {len(layers)} layers")

    print()

    # Device summary
    print("[Step 4] Device summary...")
    summary = matcher.get_device_summary()
    print(f"  Total devices: {summary['total_devices']}")
    print(f"  Total memory: {summary['total_memory_gb']:.1f} GB")
    print(f"  Available: {summary['available_memory_gb']:.1f} GB")
    print(f"  Avg compute: {summary['avg_compute_score']:.2f}")

    print("\n" + "="*80)
    return matcher


def demo_adaptive_planning():
    """Demonstrate adaptive planning with runtime metrics."""
    print("\n" + "="*80)
    print("FASE 4A - ADAPTIVE PLANNING")
    print("="*80)
    print()

    # Try to load Fase 1 metrics
    metrics_file = Path("data/metrics/gpt2_metrics.jsonl")

    if not metrics_file.exists():
        print(f"⚠️  Metrics file not found: {metrics_file}")
        print("   Using synthetic planner...")
        planner = AdaptivePlanner()
    else:
        print(f"✓ Loading Fase 1 metrics: {metrics_file}")
        planner = AdaptivePlanner(metrics_data=metrics_file)

    print()

    # Create initial plan
    print("[Step 1] Creating initial plan...")
    constraints = {
        'num_stages': 3,
        'max_memory_per_stage_mb': 8000,
        'latency_balance_threshold': 0.3,
    }

    initial_plan = planner.create_plan(constraints)
    planner.current_plan = initial_plan

    print(f"  Initial plan: {initial_plan.total_stages()} stages")
    print(f"  Estimated latency: {initial_plan.total_latency_estimate():.1f}ms")

    for stage_id, stage_info in initial_plan.stages.items():
        latency = initial_plan.stage_latencies.get(stage_id, 0)
        print(f"    {stage_id}: {len(stage_info)} layers, {latency:.1f}ms")
    print()

    # Simulate runtime metrics collection
    print("[Step 2] Simulating runtime metrics...")
    print()

    simulated_metrics = [
        RuntimeMetrics(
            layer_name="lm_head",
            actual_latency_ms=700.0,  # Higher than expected
            expected_latency_ms=610.0,
            actual_memory_mb=2500.0,
            expected_memory_mb=2200.0,
            variance=50.0,
        ),
        RuntimeMetrics(
            layer_name="transformer.h.0",
            actual_latency_ms=15.0,
            expected_latency_ms=14.5,
            actual_memory_mb=800.0,
            expected_memory_mb=750.0,
            variance=5.0,
        ),
        RuntimeMetrics(
            layer_name="transformer.h.1",
            actual_latency_ms=14.0,
            expected_latency_ms=14.2,
            actual_memory_mb=780.0,
            expected_memory_mb=750.0,
            variance=3.0,
        ),
    ]

    for metric in simulated_metrics:
        planner.update_with_runtime_metrics(metric)
        print(f"  {metric.layer_name}:")
        print(f"    Latency error: {metric.latency_error_pct:+.1f}%")
        print(f"    Memory delta: {metric.actual_memory_mb - metric.expected_memory_mb:+.1f} MB")

    print()

    # Evaluate current plan
    print("[Step 3] Evaluating current plan...")
    evaluation = planner.evaluate_current_plan()

    if "stage_evaluation" in evaluation:
        print(f"  Total metrics: {evaluation['num_metrics']}")
        print()
        print("  Stage performance:")
        for stage_id, stage_eval in evaluation["stage_evaluation"].items():
            print(f"    {stage_id}: {stage_eval['actual_latency_ms']:.1f}ms "
                  f"(error: {stage_eval['error_pct']:+.1f}%)")

        if evaluation["recommendations"]:
            print()
            print("  Recommendations:")
            for rec in evaluation["recommendations"]:
                print(f"    - {rec}")

    print()

    # Check if adaptation is needed
    print("[Step 4] Checking adaptation trigger...")
    should_adapt, reason, _ = planner.should_adapt_plan()
    print(f"  Should adapt: {should_adapt}")
    print(f"  Reason: {reason}")
    print()

    # Try adaptation
    if should_adapt:
        print("[Step 5] Performing adaptation...")
        new_plan = planner.adapt_plan()

        print(f"  New plan: {new_plan.total_stages()} stages")
        print(f"  New latency: {new_plan.total_latency_estimate():.1f}ms")
        print(f"  Total adaptations: {planner.adaptation_count}")

    print()
    print("="*80)

    return planner


def demo_heterogeneous_planning(matcher: CapabilityMatcher):
    """Demonstrate heterogeneous hardware planning."""
    print("\n" + "="*80)
    print("FASE 4A - HETEROGENEOUS HARDWARE PLANNING")
    print("="*80)
    print()

    print("[Step 1] Creating heterogeneous plan...")
    print(f"  Available devices: {len(matcher.devices)}")

    for device_id in matcher.devices:
        device = matcher.devices[device_id]
        print(f"    {device_id}: {device.device_name} ({device.device_type.value})")

    print()

    # Create heterogeneous plan
    planner = AdaptivePlanner(capability_matcher=matcher)

    # Try to load metrics
    metrics_file = Path("data/metrics/gpt2_metrics.jsonl")
    if metrics_file.exists():
        planner.load_metrics(metrics_file)
        print(f"✓ Loaded {len(planner.layer_metrics)} layer metrics")
    else:
        print("⚠️  Using synthetic planner")

    print()

    # Create plan with heterogeneous hardware
    print("[Step 2] Creating heterogeneous plan...")

    hardware_capabilities = {did: matcher.devices[did] for did in matcher.devices}

    hetero_plan = planner.create_heterogeneous_plan(
        hardware_capabilities=hardware_capabilities,
        strategy="latency"
    )

    print(f"  Plan type: {hetero_plan.metadata.get('plan_type', 'unknown')}")
    print(f"  Strategy: {hetero_plan.metadata.get('strategy', 'unknown')}")
    print(f"  Stages: {hetero_plan.total_stages()}")
    print()

    print("  Hardware assignment:")
    if 'hardware_assignment' in hetero_plan.metadata:
        assignment = hetero_plan.metadata['hardware_assignment']
        by_device = {}

        for layer, device in assignment.items():
            if device not in by_device:
                by_device[device] = []
            by_device[device].append(layer)

        for device_id, layers in by_device.items():
            print(f"    {device_id}: {len(layers)} layers")
            if len(layers) <= 5:
                for layer in layers:
                    print(f"      - {layer}")
            else:
                print(f"      - {layers[0]} (and {len(layers)-1} more...)")

    print()
    print("="*80)

    return planner


def main():
    """Main demo function."""
    print("\n" + "="*80)
    print("FASE 4: ADVANCED PLANNING DEMO")
    print("="*80)
    print()
    print("Demonstrating:")
    print("  1. Hardware capability matching & auto-detection")
    print("  2. Adaptive planning with runtime metrics")
    print("  3. Heterogeneous hardware optimization")
    print()

    try:
        # Demo 1: Hardware capability matching
        matcher = demo_hardware_capability_matching()

        # Demo 2: Adaptive planning
        adaptive_planner = demo_adaptive_planning()

        # Demo 3: Heterogeneous planning
        demo_heterogeneous_planning(matcher)

        print("\n" + "="*80)
        print("FASE 4A DEMO COMPLETE!")
        print("="*80)
        print()
        print("Key achievements:")
        print("  ✅ Hardware capability matching with auto-detection")
        print("  ✅ Runtime metrics integration")
        print("  ✅ Automatic plan adaptation")
        print("  ✅ Heterogeneous hardware support")
        print()
        print("Next: Fase 4B - Performance optimization")
        print("  - Token chunking & quantization")
        print("  - Advanced KV-cache management")
        print("  - Batch processing")
        print()

    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return 1

    return 0


if __name__ == '__main__':
    exit(main())
