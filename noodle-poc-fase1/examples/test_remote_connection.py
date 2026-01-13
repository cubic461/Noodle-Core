#!/usr/bin/env python3
"""
Test script to verify multi-machine communication.

Run this to check if:
1. Coordinator is accessible (laptop)
2. Remote worker is accessible (other PC)
3. Basic stage forwarding works
4. Metrics can be sent and collected

Usage:
    python test_remote_connection.py --coordinator "http://192.168.1.101:8080" --remote "http://192.168.1.102:8081"
"""

import sys
import os
import argparse
import time
from pathlib import Path

# Add project to path
PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

import requests
from typing import Optional


def parse_args():
    parser = argparse.ArgumentParser(description="Test distributed connectivity")
    parser.add_argument(
        "--coordinator",
        type=str,
        default="http://192.168.1.101:8080",
        help="Coordinator URL (laptop)"
    )
    parser.add_argument(
        "--remote",
        type=str,
        default="http://192.168.1.102:8081",
        help="Remote worker URL (other PC)"
    )
    parser.add_argument(
        "--timeout",
        type=float,
        default=5.0,
        help="Connection timeout in seconds"
    )
    return parser.parse_args()


def health_check(url: str, name: str) -> bool:
    """Check if service is healthy."""
    try:
        response = requests.get(f"{url}/health", timeout=3.0)

        if response.status_code == 200:
            print(f"  ✅ {name} is healthy")
            data = response.json()

            if "gpu_name" in data:
                print(f"     GPU: {data['gpu_name']} ({data.get('vram_gb', 0):.1f}GB)")
            if "device" in data:
                print(f"     Device: {data['device']}")

            return True
        else:
            print(f"  ❌ {name} returned status {response.status_code}")
            return False

    except requests.exceptions.ConnectionError:
        print(f"  ❌ {name} - Connection failed")
        return False

    except Exception as e:
        print(f"  ❌ {name} - Error: {e}")
        return False


def test_ping(url: str, name: str) -> bool:
    """Basic ping (root endpoint)."""
    try:
        response = requests.get(url, timeout=3.0)

        if response.status_code == 200:
            print(f"  ✅ {name} root endpoint reachable")
            return True
        else:
            print(f"  ❌ {name} returned status {response.status_code}")
            return False

    except requests.exceptions.ConnectionError:
        print(f"  ❌ {name} - Cannot connect to {url}")
        return False


def test_stage_forward(
    coordinator_url: str,
    remote_url: str,
    session_id: str = "test_run_001"
) -> bool:
    """Test forwarding activations through stages."""

    print(f"\n{'='*80}")
    print("TEST: Multi-Stage Forward Pass")
    print(f"{'='*80}")

    # Mock activations (batch=1, seq_len=1, hidden=768 for GPT-2)
    activations = [[[0.1] * 768]]

    try:
        # Stage 0 (coordinator)
        stage0_response = requests.post(
            f"{coordinator_url}/stage/0/forward",
            json={
                "session_id": session_id,
                "token_index": 0,
                "stage_id": 0,
                "activations": activations,
                "return_logits": False,
            },
            timeout=10.0
        )

        if stage0_response.status_code != 200:
            print(f"  ❌ Stage 0 failed: {stage0_response.status_code}")
            return False

        stage0_data = stage0_response.json()

        if not stage0_data.get("success"):
            print(f"  ❌ Stage 0 returned error: {stage0_data.get('error', 'Unknown')}")
            return False

        print(f"  ✅ Stage 0 completed")
        print(f"     Output shape: {stage0_data.get('output', {}).get('shape', 'N/A')}")

        # Stage 1 (remote worker)
        stage1_response = requests.post(
            f"{remote_url}/forward",
            json={
                "session_id": session_id,
                "token_index": 0,
                "stage_id": 1,
                "activations": [[[0.1] * 768]],  # Mock
                "metrics_url": f"{coordinator_url}/central_metrics",
            },
            timeout=10.0
        )

        if stage1_response.status_code != 200:
            print(f"  ❌ Stage 1 failed: {stage1_response.status_code}")
            return False

        stage1_data = stage1_response.json()

        if not stage1_data.get("success"):
            print(f"  ❌ Stage 1 returned error: {stage1_data.get('error', 'Unknown')}")
            return False

        print(f"  ✅ Stage 1 completed")
        print(f"     Output shape: {stage1_data.get('shape', 'N/A')}")

        # Metrics
        performance = stage1_data.get("performance", {}).get("forward_latency_ms", 0)
        memory = stage1_data.get("performance", {}).get("peak_memory_mb", 0)
        print(f"     Latency: {performance:.2f}ms")
        print(f"     Memory: {memory:.1f}MB")

        return True

    except Exception as e:
        print(f"  ❌ Forward test failed: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_planning(coordinator_url: str) -> bool:
    """Test generation of partition plan."""
    print(f"\n{'='*80}")
    print("TEST: Execution Plan Generation")
    print(f"{'='*80}")

    try:
        request_data = {
            "model_name": "gpt2",
            "strategy": "balanced",
            "available_nodes": [
                {
                    "node_id": "laptop_gpu",
                    "device_type": "gpu",
                    "compute_score": 25.0,
                    "vram_gb": 4.0,
                    "ram_gb": 0.0,
                    "network_latency_ms": 0.1,
                    "address": "http://192.168.1.101:8080",
                },
                {
                    "node_id": "remote_cpu",
                    "device_type": "cpu",
                    "compute_score": 5.0,
                    "ram_gb": 16.0,
                    "network_latency_ms": 0.5,
                    "address": "http://192.168.1.102:8081",
                },
            ]
        }

        response = requests.post(
            f"{coordinator_url}/plan/generate",
            json=request_data,
            timeout=15.0
        )

        if response.status_code != 200:
            print(f"  ❌ Plan generation failed: {response.status_code}")
            print(f"     {response.text}")
            return False

        plan_data = response.json()

        if not plan_data.get("success"):
            print(f"  ❌ Plan generation failed: {plan_data}")
            return False

        print(f"  ✅ Plan generated successfully")
        print(f"     Strategy: {request_data['strategy']}")
        print(f"     Total stages: {len(plan_data.get('plan', {}).get('stages', []))}")
        print(f"     Total latency: {plan_data.get('plan', {}).get('total_expected_latency_ms', 0):.1f}ms")
        print(f"     Load balance: {plan_data.get('plan', {}).get('load_balance_score', 0):.2f}")

        if "bottleneck" in plan_data:
            bottleneck = plan_data["bottleneck"]
            print(f"     Bottleneck: Stage {bottleneck.get('stage_id', 'N/A')} "
                  f"({bottleneck.get('latency_ms', 0):.1f}ms)")

        return True

    except Exception as e:
        print(f"  ❌ Plan test failed: {e}")
        import traceback
        traceback.print_exc()
        return False


def collect_metrics(coordinator_url: str) -> bool:
    """Check if metrics collection is working."""
    print(f"\n{'='*80}")
    print("TEST: Centralized Metrics Collection")
    print(f"{'='*80}")

    try:
        response = requests.get(f"{coordinator_url}/metrics", timeout=5.0)

        if response.status_code != 200:
            print(f"  ❌ Metrics fetch failed: {response.status_code}")
            return False

        metrics_data = response.json()

        print(f"  ✅ Metrics accessible")
        print(f"     Total records: {metrics_data.get('total_records', 0)}")
        print(f"     Average latency: {metrics_data.get('average_latency_ms', 0):.2f}ms")

        if "by_source" in metrics_data:
            print(f"     Breakdown by source:")
            for source, count in metrics_data["by_source"].items():
                print(f"       - {source}: {count} records")

        if "recent" in metrics_data:
            num_recent = len(metrics_data["recent"])
            print(f"     Recent entries: {num_recent}")

        return True

    except Exception as e:
        print(f"  ❌ Metrics test failed: {e}")
        return False


def main():
    args = parse_args()

    print("="*80)
    print("🧪 NoodleCore Multi-Machine Connection Test")
    print("="*80)

    print(f"\nConfiguration:")
    print(f"  Coordinator: {args.coordinator}")
    print(f"  Remote:      {args.remote}")
    print(f"  Timeout:     {args.timeout}s")

    # Test sequence
    tests = {
        "Basic connectivity": [
            lambda: test_ping(args.coordinator, "Coordinator"),
            lambda: test_ping(args.remote, "Remote Worker"),
        ],
        "Health checks": [
            lambda: health_check(args.coordinator, "Coordinator"),
            lambda: health_check(args.remote, "Remote Worker"),
        ],
        "Planning": [
            lambda: test_planning(args.coordinator),
        ],
        "Stage forwarding": [
            lambda: test_stage_forward(args.coordinator, args.remote),
        ],
        "Metrics": [
            lambda: collect_metrics(args.coordinator),
        ],
    }

    results = {}

    for test_category, test_funcs in tests.items():
        print(f"\n{'='*80}")
        print(f"CATEGORY: {test_category.upper()}")
        print(f"{'='*80}")

        for test_func in test_funcs:
            test_name = test_func.__name__

            try:
                result = test_func()
                results[test_name] = result

                if result:
                    print_colored("✓", "green")
                else:
                    print_colored("✗", "red")

            except Exception as e:
                print(f"  ❌ Test failed with exception: {e}")
                results[test_name] = False

    # Summary
    print(f"\n{'='*80}")
    print(f"SUMMARY")
    print(f"{'='*80}")

    passed = sum(results.values())
    total = len(results)

    print(f"Tests passed: {passed}/{total}")
    print(f"Success rate: {100*passed/total:.1f}%")

    if all(results.values()):
        print(f"\n✅ All tests passed! Multi-machine setup is working correctly.")
        return 0
    else:
        print(f"\n⚠️  Some tests failed. Check logs above for details.")
        return 1


def print_colored(text: str, color: str):
    """Print colored text (simple fallback, no external libs)."""
    color_map = {
        "green": "\033[92m",
        "red": "\033[91m",
        "reset": "\033[0m",
    }

    color_code = color_map.get(color, "")
    reset_code = color_map.get("reset", "")

    print(f"  {color_code}{text}{reset_code}")


if __name__ == "__main__":
    try:
        exit_code = main()
        sys.exit(exit_code)
    except KeyboardInterrupt:
        print(f"\n[INFO] Interrupted by user")
        sys.exit(0)
    except Exception as e:
        print(f"\n[ERROR] Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
