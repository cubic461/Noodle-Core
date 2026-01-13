#!/usr/bin/env python3
"""
Distributed inference benchmark and demo.

This demonstrates multi-machine staged execution:
- Coordinator (laptop) receives request
- Stage 0 (GPU) forwards to Stage 1 (remote)
- Returns results to coordinator

Usage:
    python distributed_demo.py --coordinator "http://192.168.1.101:8080" --remote "http://192.168.1.102:8081"
"""

import sys
import os
import time
import argparse
from pathlib import Path
from typing import List, Dict, Optional
import statistics

# Add project root to path
PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

import requests


def parse_args():
    parser = argparse.ArgumentParser(description="Distributed inference demo")
    parser.add_argument(
        "--coordinator",
        type=str,
        default="http://192.168.1.101:8080",
        help="Coordinator URL"
    )
    parser.add_argument(
        "--remote",
        type=str,
        default="http://192.168.1.102:8081",
        help="Remote worker URL"
    )
    parser.add_argument(
        "--num-runs",
        type=int,
        default=5,
        help="Number of test runs"
    )
    parser.add_argument(
        "--num-tokens",
        type=int,
        default=10,
        help="Tokens per run"
    )
    return parser.parse_args()


class DistributedBenchmark:
    """Benchmark multi-stage distributed inference."""

    def __init__(self, coordinator_url: str, remote_url: str):
        self.coordinator_url = coordinator_url
        self.remote_url = remote_url
        self.results: List[Dict] = []

    def warmup(self, num_warmup: int = 3):
        """Warmup connection and caches."""
        print(f"\n[WARMUP] Warming up connections...")

        for i in range(num_warmup):
            try:
                activations = [[[0.1] * 768]]

                _ = requests.post(
                    f"{self.coordinator_url}/stage/0/forward",
                    json={
                        "session_id": f"warmup_{i}",
                        "token_index": i,
                        "stage_id": 0,
                        "activations": activations,
                    },
                    timeout=5.0
                )

            except Exception:
                pass

        print(f"  ✅ Warmup complete ({num_warmup} calls)")

    def run_benchmark(
        self,
        num_tokens: int = 10,
        num_runs: int = 5
    ) -> Dict:
        """Run distributed inference benchmark."""

        print(f"\n{'='*80}")
        print(f"🚀 DISTRIBUTED INFERENCE BENCHMARK")
        print(f"{'='*80}")

        print(f"\nConfiguration:")
        print(f"  Coordinator: {self.coordinator_url}")
        print(f"  Remote:      {self.remote_url}")
        print(f"  Tokens/run:  {num_tokens}")
        print(f"  Runs:        {num_runs}")

        total_times = []

        for run_idx in range(num_runs):
            run_start = time.time()
            session_id = f"benchmark_run_{run_idx + 1}"

            print(f"\n[RUN {run_idx + 1}/{num_runs}] Processing {num_tokens} tokens...")

            successes = 0

            for token_idx in range(num_tokens):

                # Mock activations for GPT-2 hidden_dim=768
                activations = [[[0.1 + (i * 0.01) for i in range(768)]]]

                try:
                    # Stage 0 (Coordinator/Laptop)
                    stage0_start = time.time()

                    stage0_response = requests.post(
                        f"{self.coordinator_url}/stage/0/forward",
                        json={
                            "session_id": session_id,
                            "token_index": token_idx,
                            "stage_id": 0,
                            "activations": activations,
                        },
                        timeout=10.0
                    )

                    if stage0_response.status_code != 200:
                        print(f"  ❌ Stage 0 failed: {stage0_response.status_code}")
                        continue

                    stage0_data = stage0_response.json()

                    if not stage0_data.get("success"):
                        print(f"  ❌ Stage 0 error: {stage0_data.get('error', 'Unknown')}")
                        continue

                    stage0_time = (time.time() - stage0_start) * 1000

                    # Stage 1 (Remote)
                    stage1_start = time.time()

                    stage1_response = requests.post(
                        f"{self.remote_url}/forward",
                        json={
                            "session_id": session_id,
                            "token_index": token_idx,
                            "stage_id": 1,
                            "activations": activations,
                            "metrics_url": f"{self.coordinator_url}/central_metrics",
                        },
                        timeout=10.0
                    )

                    if stage1_response.status_code != 200:
                        print(f"  ❌ Stage 1 failed: {stage1_response.status_code}")
                        continue

                    stage1_data = stage1_response.json()

                    if not stage1_data.get("success"):
                        print(f"  ❌ Stage 1 error: {stage1_data.get('error', 'Unknown')}")
                        continue

                    stage1_time = (time.time() - stage1_start) * 1000

                    successes += 1

                except requests.exceptions.Timeout:
                    print(f"  ⏱️  Token {token_idx} timed out")
                    continue

                except Exception as e:
                    print(f"  ❌ Token {token_idx} failed: {e}")
                    continue

            # End run
            elapsed = time.time() - run_start

            if successes > 0:
                tokens_per_sec = successes / elapsed
                total_times.append(tokens_per_sec)

                print(f"  ✅ Run complete:")
                print(f"     Tokens:     {successes}/{num_tokens}")
                print(f"     Time:       {elapsed:.2f}s")
                print(f"     Throughput: {tokens_per_sec:.2f} tokens/sec")

            else:
                print(f"  ❌ Run {run_idx + 1} had no successes")

        # Summary
        if total_times:
            print(f"\n{'='*80}")
            print(f"RESULTS")
            print(f"{'='*80}")

            avg_tps = statistics.mean(total_times)
            median_tps = statistics.median(total_times)

            if len(total_times) > 1:
                std_tps = statistics.stdev(total_times)
                print(f"  Average:   {avg_tps:.2f} tokens/sec")
                print(f"  Median:    {median_tps:.2f} tokens/sec")
                print(f"  Std Dev:   {std_tps:.2f} tokens/sec")
                print(f"  Min/Max:   {min(total_times):.2f} / {max(total_times):.2f} tokens/sec")
            else:
                print(f"  Throughput: {avg_tps:.2f} tokens/sec")

            total_tokens = sum(range(num_tokens))  # Up to max
            total_elapsed = sum(total_times) / avg_tps if avg_tps > 0 else 0
            print(f"\n  Total time (all runs): {total_elapsed:.2f}s")
            print(f"  Total tokens sent:     {total_tokens}")
            print(f"  Success rate:          {100*len(total_times)/num_runs:.1f}%")

            return {
                "avg_throughput": avg_tps,
                "median_throughput": median_tps,
                "success_rate": len(total_times) / num_runs,
                "runs_completed": len(total_times),
            }

        else:
            print(f"\n❌ No successful runs")

            return {
                "avg_throughput": 0.0,
                "median_throughput": 0.0,
                "success_rate": 0.0,
                "runs_completed": 0,
            }


def compare_with_single_machine(coordinator_url: str):
    """Compare distributed vs. single-machine (if available)."""

    print(f"\n{'='*80}")
    print(f"OPTIONAL: Single-Node Comparison")
    print(f"{'='*80}")

    try:
        # Run same test only on coordinator
        activations = [[[0.1] * 768]]

        start_time = time.time()
        num_single = 20

        for i in range(num_single):
            response = requests.post(
                f"{coordinator_url}/stage/0/forward",
                json={
                    "session_id": "single_node_test",
                    "token_index": i,
                    "stage_id": 0,
                    "activations": activations,
                },
                timeout=5.0
            )

            if response.status_code != 200:
                print(f"  ❌ Single-node test failed")
                return

        elapsed = time.time() - start_time
        single_tps = num_single / elapsed

        print(f"  Single-node throughput:  {single_tps:.2f} tokens/sec ({elapsed:.2f}s)")
        print(f"  ✓ Use this to compare with distributed overhead")

    except Exception as e:
        print(f"  ⚠️  Skipping single-node comparison: {e}")


def main():
    args = parse_args()

    print("="*80)
    print("🚀 NoodleCore Distributed Inference Demo")
    print("="*80)

    # Initialize
    benchmark = DistributedBenchmark(
        coordinator_url=args.coordinator,
        remote_url=args.remote,
    )

    # Warmup
    benchmark.warmup(num_warmup=3)

    # Run benchmark
    results = benchmark.run_benchmark(
        num_tokens=args.num_tokens,
        num_runs=args.num_runs,
    )

    # Optional comparison
    if results["success_rate"] > 0:
        compare_with_single_machine(args.coordinator)

    # Final message
    print(f"\n{'='*80}")
    print(f"🔧 DEMO COMPLETE!")
    print(f"{'='*80}")

    if results["success_rate"] > 0.5:
        print(f"\n✅ Distributed inference is working!")
        print(f"   Average: {results['avg_throughput']:.2f} tokens/sec")
        print(f"   Success: {100*results['success_rate']:.0f}%")

        print(f"\n💡 Next steps:")
        print(f"   1. Add real model (replace placeholder forward)")
        print(f"   2. Implement KV-cache across nodes")
        print(f"   3. Add adaptive planner with runtime metrics")
        print(f"   4. Scale to 3+ nodes")

    else:
        print(f"\n⚠️  Issues detected. Check logs above.")

    print(f"\n📄 All code is in:")
    print(f"   - {PROJECT_ROOT}/examples/coordinator_api.py")
    print(f"   - {PROJECT_ROOT}/examples/worker_server.py")
    print(f"   - {PROJECT_ROOT}/examples/distributed_demo.py")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n[INFO] Interrupted by user")
        sys.exit(0)
    except Exception as e:
        print(f"\n[ERROR] Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
