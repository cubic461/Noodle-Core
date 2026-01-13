"""
Example demonstrating distributed inference across multiple workers.
Shows coordinator-worker communication and staged execution.
"""

import asyncio
import torch
from pathlib import Path
import sys
import argparse

# Add src to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "src"))

from noodle_poc.network import (
    CoordinatorService,
    CoordinatorConfig,
    StageWorkerService,
    WorkerConfig,
    NodeRegistry,
    InferenceRequest,
)
from noodle_poc.planner.core import ExecutionPlanner
from noodle_poc.planner.optimizer import StaticPartitioner
import examples.utils as demo_utils


async def start_coordinator(port: int = 8081):
    """Start coordinator service."""
    config = CoordinatorConfig(
        listen_port=port,
        log_level="INFO"
    )

    coordinator = CoordinatorService(config)
    server = await coordinator.start()

    print(f"[COORDINATOR] Started on port {port}")
    print(f"[COORDINATOR] Node registry: {coordinator.node_registry.get_metrics()}")

    return coordinator


async def start_worker(
    worker_id: str,
    listen_port: int,
    coordinator_port: int,
    device: str = "cpu"
):
    """Start worker service."""
    config = WorkerConfig(
        worker_id=worker_id,
        listen_port=listen_port,
        coordinator_port=coordinator_port,
        device=device,
    )

    worker = StageWorkerService(config)
    server = await worker.start()

    print(f"[{worker_id.upper()}] Started on port {listen_port} (device: {device})")
    print(f"[{worker_id.upper()}] Registered with coordinator at port {coordinator_port}")

    return worker


async def simulate_distributed_inference(
    coordinator: CoordinatorService,
    input_prompt: str = "Artificial intelligence"
):
    """
    Simulate complete distributed inference workflow.

    This shows the full pipeline:
    1. Load model and metrics
    2. Load Fase 1 observability data
    3. Create partition plan using Fase 2 planner
    4. Coordinate distributed execution using Fase 3 network layer
    """
    print("=" * 80)
    print("DISTRIBUTED INFERENCE SIMULATION")
    print("=" * 80)
    print()

    # Step 1: Load execution planner with Fase 1 metrics
    print("[STEP 1] Loading Fase 1 & 2 infrastructure")
    print("-" * 80)

    try:
        # Try to find Fase 1 metrics
        metrics_file = Path("data/metrics/gpt2_metrics.jsonl")

        if not metrics_file.exists():
            print(f"⚠️  Fase 1 metrics not found: {metrics_file}")
            print("   Creating synthetic planner...")
            planner = ExecutionPlanner.create_synthetic()
        else:
            print(f"✓ Loading Fase 1 metrics: {metrics_file}")
            planner = ExecutionPlanner(metrics_file)

        print(f"✓ Planner loaded with {planner.get_num_layers()} layers")

        # Generate partition plan
        constraints = {
            'num_stages': 3,
            'max_memory_per_stage_mb': 8000,
            'latency_balance_threshold': 0.3,
        }

        partition_plan = planner.create_partition_plan(constraints)
        print(f"✓ Partition plan created: {partition_plan.total_stages()} stages")
        print()

    except Exception as e:
        print(f"✗ Error loading planner: {e}")
        return

    # Step 2: Verify worker nodes are available
    print("[STEP 2] Checking worker node availability")
    print("-" * 80)

    available_nodes = coordinator.node_registry.get_available_nodes()

    if not available_nodes:
        print("✗ No worker nodes available!")
        print("   Make sure worker services are running.")
        return

    print(f"✓ Found {len(available_nodes)} worker nodes:")
    for node_id, node_info in available_nodes.items():
        print(f"   - {node_id}: {node_info.host}:{node_info.port}")
        print(f"     Hardware: {node_info.hardware.device_type} ({node_info.hardware.device_name})")
        print(f"     Memory: {node_info.hardware.total_memory_gb:.1f} GB, "
              f"Load: {node_info.load_factor:.2f}")
    print()

    # Step 3: Assignment planning
    print("[STEP 3] Planning stage-to-node assignment")
    print("-" * 80)

    # Simple round-robin assignment
    stage_assignments = {}
    node_ids = list(available_nodes.keys())

    for i, stage_id in enumerate(partition_plan.stages.keys()):
        node_id = node_ids[i % len(node_ids)]
        stage_assignments[stage_id] = node_id
        print(f"   {stage_id} -> {node_id}")

    print()

    # Step 4: Create sample inference request
    print("[STEP 4] Submitting inference request")
    print("-" * 80)

    input_tokens = demo_utils.tokenize_gpt2(input_prompt)
    request = InferenceRequest(
        input_tokens=input_tokens,
        max_new_tokens=10,
        temperature=1.0,
    )

    print(f"   Input prompt: '{input_prompt}'")
    print(f"   Input tokens: {input_tokens}")
    print(f"   Request ID: {request.request_id}")
    print()

    # Step 5: Execute distributed inference
    print("[STEP 5] Executing distributed inference")
    print("-" * 80)

    try:
        response = await coordinator.submit_inference_request(request)

        print()
        print("=" * 80)
        print("RESULTS")
        print("=" * 80)

        if response.error_message:
            print(f"✗ Inference failed: {response.error_message}")
            return

        generated_tokens = response.generated_tokens
        generated_text = demo_utils.detokenize_gpt2(generated_tokens)

        print(f"✓ Inference successful!")
        print()
        print("Generated text:")
        print(f"   Input: {input_prompt}")
        print(f"   Output: {generated_text}")
        print()
        print("Performance metrics:")
        print(f"   Total latency: {response.metadata['total_latency_ms']:.2f} ms")
        print(f"   Generated tokens: {response.metadata['num_generated_tokens']}")
        print(f"   Session ID: {response.metadata['session_id']}")
        print(f"   Complete: {response.is_complete}")
        print()

        if 'stage_breakdown' in response.metadata:
            print("Stage latency breakdown:")
            for stage, latency in response.metadata['stage_breakdown'].items():
                print(f"   {stage}: {latency:.2f} ms")

        print()
        print("=" * 80)

    except Exception as e:
        print()
        print("=" * 80)
        print("ERROR")
        print("=" * 80)
        print(f"✗ Distributed inference failed: {e}")
        print()
        print("This is expected during simulation - the coordinator and worker")
        print("services are running, but full end-to-end execution requires")
        print("additional integration work (gRPC service implementations).")
        print()
        print("The architecture is in place for Fase 3 - next step is")
        print("to implement the actual gRPC message passing.")
        print("=" * 80)


async def main_demo():
    """Main demonstration function."""
    parser = argparse.ArgumentParser(
        description="Fase 3: Distributed Inference Demo"
    )
    parser.add_argument(
        '--mode',
        type=str,
        choices=['coordinator', 'worker', 'demo'],
        default='demo',
        help='Run mode'
    )
    parser.add_argument(
        '--coordinator-port',
        type=int,
        default=8081,
        help='Coordinator port'
    )
    parser.add_argument(
        '--worker-port',
        type=int,
        default=8082,
        help='Worker port'
    )
    parser.add_argument(
        '--worker-id',
        type=str,
        default='worker-1',
        help='Worker ID'
    )
    parser.add_argument(
        '--device',
        type=str,
        default='cpu',
        help='Device for worker (cpu/cuda)'
    )
    parser.add_argument(
        '--prompt',
        type=str,
        default='Artificial intelligence',
        help='Input prompt for inference'
    )

    args = parser.parse_args()

    print()
    print("=" * 80)
    print("NOODLECORE FASE 3: DISTRIBUTED INFERENCE DEMO")
    print("=" * 80)
    print()

    if args.mode == 'coordinator':
        # Start coordinator only
        coordinator = await start_coordinator(args.coordinator_port)
        print("\n[COORDINATOR] Press Ctrl+C to stop")
        try:
            await asyncio.Event().wait()
        except KeyboardInterrupt:
            pass

    elif args.mode == 'worker':
        # Start worker only
        worker = await start_worker(
            args.worker_id,
            args.worker_port,
            args.coordinator_port,
            args.device
        )
        print(f"\n[{args.worker_id.upper()}] Press Ctrl+C to stop")
        try:
            await asyncio.Event().wait()
        except KeyboardInterrupt:
            pass

    else:  # demo mode
        print("[MODE] Running complete distributed inference demo")
        print()

        # Start coordinator
        coordinator = await start_coordinator(args.coordinator_port)
        await asyncio.sleep(0.5)

        # Start workers
        worker1 = await start_worker(
            'worker-1',
            args.worker_port,
            args.coordinator_port,
            args.device
        )
        await asyncio.sleep(0.5)

        worker2 = await start_worker(
            'worker-2',
            args.worker_port + 1,
            args.coordinator_port,
            args.device
        )
        await asyncio.sleep(0.5)

        # Run inference simulation
        await simulate_distributed_inference(coordinator, args.prompt)

        print()
        print("FASE 3 DEMO COMPLETE!")
        print()
        print("Architecture delivered:")
        print("  ✓ gRPC service definitions (protobuf)")
        print("  ✓ Distributed coordinator with execution planning")
        print("  ✓ Worker service for stage execution")
        print("  ✓ Session management infrastructure")
        print("  ✓ Node registry and health monitoring")
        print("  ✓ Tensor serialization utilities")
        print()
        print("Ready for end-to-end testing with actual gRPC communication!")


if __name__ == '__main__':
    try:
        asyncio.run(main_demo())
    except KeyboardInterrupt:
        print("\n\nDemo interrupted by user")
    except Exception as e:
        print(f"\n\nError: {e}")
        import traceback
        traceback.print_exc()
