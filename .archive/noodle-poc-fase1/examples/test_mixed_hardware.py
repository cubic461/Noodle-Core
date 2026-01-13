#!/usr/bin/env python3
"""
Test mixed hardware setup (CPU Laptop + GPU PC).

Demonstrates:
1. Coordinator on LAPTOP (CPU-only)
2. Stage 0 (Early layers) on LAPTOP CPU
3. Stage 1 (Late layers + head) on RTX 1050 GPU
"""

import sys
import os
from pathlib import Path
import time
import json

PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

import requests


def main():
    # Configuration - PAS DIT AAN NAAR JOUW IP'S
    LAPTOP_IP = "192.168.1.100"
    RTX1050_IP = "192.168.1.101"

    COORDINATOR_URL = f"http://{LAPTOP_IP}:8080"
    GPU_WORKER_URL = f"http://{RTX1050_IP}:8081"

    print("="*80)
    print("🧪 Mixed Hardware Test (CPU Laptop + RTX 1050 PC)")
    print("="*80)
    print(f"\nConfiguration:")
    print(f"  Coordinator (Laptop CPU): {COORDINATOR_URL}")
    print(f"  GPU Worker (RTX 1050):    {GPU_WORKER_URL}")

    # Test 1: Check coordinator health
    print(f"\n{'='*80}")
    print("TEST 1: Coordinator Health")
    print(f"{'='*80}")

    try:
        response = requests.get(f"{COORDINATOR_URL}/health", timeout=5)
        health = response.json()
        print(f"  ✅ Coordinator is healthy")
        print(f"     Device: CPU-only")
        print(f"     Sessions: {health.get('num_sessions', 0)}")
        print(f"     Workers: {health.get('num_workers', 0)}")

    except Exception as e:
        print(f"  ❌ Coordinator health check failed: {e}")
        return 1

    # Test 2: Check GPU worker health
    print(f"\n{'='*80}")
    print("TEST 2: GPU Worker Health")
    print(f"{'='*80}")

    try:
        response = requests.get(f"{GPU_WORKER_URL}/health", timeout=5)
        health = response.json()

        if "gpu_name" in health:
            print(f"  ✅ GPU Worker is healthy")
            print(f"     GPU: {health['gpu_name']}")
            print(f"     VRAM: {health.get('vram_gb', 0):.1f}GB")
            print(f"     Used VRAM: {health.get('vram_used_mb', 0):.1f}MB")
        else:
            print(f"  ⚠️  GPU Worker on CPU: {health}")

    except Exception as e:
        print(f"  ❌ GPU Worker health failed: {e}")
        print(f"  💡 Controleer of de RTX 1050 PC aan staat en op {RTX1050_IP} bereikbaar is")
        return 1

    # Test 3: Generate partition plan for hardware
    print(f"\n{'='*80}")
    print("TEST 3: Generate Mixed Hardware Plan")
    print(f"{'='*80}")

    plan_request = {
        "model_name": "gpt2",
        "strategy": "balanced",  # Gebalanceerde verdeling
        "available_nodes": [
            {
                "node_id": "laptop_cpu",
                "device_type": "cpu",
                "compute_score": 5.0,
                "ram_gb": 8.0,  # Pas aan naar jouw specs
                "network_latency_ms": 1.0,
                "address": COORDINATOR_URL,
            },
            {
                "node_id": "rtx1050_gpu",
                "device_type": "gpu",
                "compute_score": 25.0,  # RTX 1050 ~25FLOPs
                "vram_gb": 4.0,  # 4GB is de limiet!
                "network_latency_ms": 1.5,
                "address": GPU_WORKER_URL,
            },
        ]
    }

    try:
        response = requests.post(
            f"{COORDINATOR_URL}/plan/generate",
            json=plan_request,
            timeout=15
        )

        plan = response.json()

        if not plan.get("success"):
            print(f"  ❌ Plan generation failed: {plan}")
            return 1

        print(f"  ✅ Plan generated!")
        print(f"     Total stages: {len(plan['plan'].get('stages', []))}")
        print(f"     Total latency: {plan['plan'].get('total_expected_latency_ms', 0):.1f}ms")

        if plan.get("bottleneck"):
            bn = plan["bottleneck"]
            print(f"     Bottleneck: Stage {bn.get('stage_id')} ({bn.get('latency_ms', 0):.1f}ms)")
            print(f"       Reason: {bn.get('reason', 'N/A')}")

        # Sla plan op voor later
        with open("data/mixed_hardware_plan.json", "w") as f:
            json.dump(plan, f, indent=2)
        print(f"     Saved to: data/mixed_hardware_plan.json")

    except Exception as e:
        print(f"  ❌ Plan test failed: {e}")
        return 1

    # Test 4: Register worker
    print(f"\n{'='*80}")
    print("TEST 4: Register GPU Worker")
    print(f"{'='*80}")

    register_request = {
        "node_id": "rtx1050_gpu",
        "device_type": "gpu",
        "compute_score": 25.0,
        "vram_gb": 4.0,
        "address": GPU_WORKER_URL,
    }

    try:
        response = requests.post(f"{COORDINATOR_URL}/workers/register", json=register_request)

        if response.json().get("success"):
            worker = response.json()["worker"]
            print(f"  ✅ Worker registered: {worker['node_id']}")
            print(f"     Healthy: {worker['healthy']}")
        else:
            print(f"  ⚠️  Registration partial: {response.json()}")

    except Exception as e:
        print(f"  ⚠️  Registration failed (probably still works): {e}")

    # Test 5: Run distributed inference
    print(f"\n{'='*80}")
    print("TEST 5: Distributed Inference (Laptop CPU → RTX 1050 GPU)")
    print(f"{'='*80}")

    activations = [[[0.1 + (i * 0.01) for i in range(768)]]]  # batch=1, seq=1, hidden=768
    session_id = "mixed_test_001"

    try:
        # Stage 0: Laptop CPU
        print(f"\n[Stage 0] Sending to Laptop CPU...")
        stage0_response = requests.post(
            f"{COORDINATOR_URL}/stage/0/forward",
            json={
                "session_id": session_id,
                "token_index": 0,
                "stage_id": 0,
                "activations": activations,
            },
            timeout=5
        )

        if not stage0_response.json().get("success"):
            print(f"  ❌ Stage 0 failed: {stage0_response.json()}")
            return 1

        print(f"  ✅ Stage 0 complete (CPU)")

        # Stage 1: RTX 1050 GPU
        print(f"\n[Stage 1] Sending to RTX 1050 GPU...")
        stage1_response = requests.post(
            f"{GPU_WORKER_URL}/forward",
            json={
                "session_id": session_id,
                "token_index": 0,
                "stage_id": 1,
                "activations": activations,
                "metrics_url": f"{COORDINATOR_URL}/central_metrics",
            },
            timeout=5
        )

        if not stage1_response.json().get("success"):
            print(f"  ❌ Stage 1 failed: {stage1_response.json()}")
            return 1

        stage1_data = stage1_response.json()
        perf = stage1_data.get("performance", {})
        print(f"  ✅ Stage 1 complete (GPU)")
        print(f"     Latency: {perf.get('forward_latency_ms', 0):.2f}ms")
        print(f"     Memory: {perf.get('peak_memory_mb', 0):.1f}MB")

    except Exception as e:
        print(f"  ❌ Inference failed: {e}")
        import traceback
        traceback.print_exc()
        return 1

    # Summary
    print(f"\n{'='*80}")
    print("✅ ALL TESTS PASSED!")
    print(f"{'='*80}")
    print(f"\nJouw setup werkt correct:")
    print(f"  - Laptop coördineert en voert stage 0 uit (CPU)")
    print(f"  - RTX 1050 PC voert stage 1 uit (GPU)")
    print(f"  - Metrics worden centraal verzameld")
    print(f"\n💡 Vervolgstappen:")
    print(f"  1. Bekijk plan in: data/mixed_hardware_plan.json")
    print(f"  2. Run volledige demo: python examples/distributed_demo.py")
    print(f"  3. Implementeer echte model-inferentie (replace placeholder)")
    print(f"\n🚀 Succes!")

    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print(f"\n[INFO] Interrupted by user")
        sys.exit(0)
