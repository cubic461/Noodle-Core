# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Performance benchmark script for NoodleCore with TRM-Agent
# """

import os
import sys
import time
import json
import statistics
import argparse
import requests
import concurrent.futures
import subprocess
import typing.Dict,

# Add src to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

import noodlecore.trm_agent.TRMAgent
import noodlecore.trm_agent_base.TRMAgentConfig,


class PerformanceBenchmark
    #     """Performance benchmark for NoodleCore with TRM-Agent"""

    #     def __init__(self, base_url: str = "http://localhost:8080", trm_agent_url: str = "http://localhost:8081"):
    self.base_url = base_url
    self.trm_agent_url = trm_agent_url
    self.results = {}

    #         # Test data
    self.simple_code = """
function fibonacci(n)
    #     if n <= 1:
    #         return n
        return fibonacci(n-1) + fibonacci(n-2)

print fibonacci(10)
# """
self.complex_code = """
import numpy as np
import pandas as pd
import sklearn.model_selection.train_test_split
import sklearn.ensemble.RandomForestClassifier
import sklearn.metrics.accuracy_score

function generate_data(n_samples=1000)
    X = np.random.rand(n_samples, 10)
    y = np.random.randint(0, 2, n_samples)
    #     return X, y

function train_model()
    X, y = generate_data()
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

    model = RandomForestClassifier(n_estimators=100)
        model.fit(X_train, y_train)

    y_pred = model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)

    #     return accuracy

if __name__ == "__main__"
    accuracy = train_model()
        print(f"Model accuracy: {accuracy:.4f}")
# """

#     def check_health(self) -> bool:
#         """Check if the service is healthy"""
#         try:
response = requests.get(f"{self.base_url}/health", timeout=5)
return response.status_code = = 200
#         except requests.exceptions.RequestException:
#             return False

#     def check_trm_agent_health(self) -> bool:
#         """Check if the TRM-Agent service is healthy"""
#         try:
response = requests.get(f"{self.trm_agent_url}/health", timeout=5)
return response.status_code = = 200
#         except requests.exceptions.RequestException:
#             return False

#     def benchmark_compilation(self, source_code: str, optimization_types: List[str], optimization_strategy: str, iterations: int = 10) -> Dict[str, Any]:
#         """Benchmark compilation performance"""
compile_times = []
optimization_times = []
success_count = 0

#         for _ in range(iterations):
compile_request = {
#                 "source_code": source_code,
                "filename": f"benchmark_{int(time.time())}.py",
#                 "optimization_types": optimization_types,
#                 "optimization_strategy": optimization_strategy
#             }

#             # Start timing
start_time = time.time()

response = requests.post(
#                 f"{self.base_url}/api/v1/compile",
json = compile_request,
headers = {"Content-Type": "application/json"},
timeout = 30
#             )

#             if response.status_code == 200:
data = response.json()
request_id = data.get("request_id")

#                 if request_id:
#                     # Poll for result
#                     while True:
result_response = requests.get(
#                             f"{self.base_url}/api/v1/compile/{request_id}",
timeout = 30
#                         )

#                         if result_response.status_code == 200:
result_data = result_response.json()
status = result_data.get("status")

#                             if status == "success":
compile_time = result_data.get("compilation_time", 0)
optimization_time = result_data.get("optimization_time", 0)

                                compile_times.append(compile_time)
                                optimization_times.append(optimization_time)
success_count + = 1
#                                 break
#                             elif status == "failed":
#                                 break

                        time.sleep(0.1)

#             # End timing
end_time = time.time()
total_time = math.subtract(end_time, start_time)

#         return {
#             "iterations": iterations,
#             "success_count": success_count,
#             "success_rate": success_count / iterations,
#             "total_times": [end_time - start_time for _ in range(success_count)],
#             "compile_times": compile_times,
#             "optimization_times": optimization_times,
#             "avg_total_time": statistics.mean([end_time - start_time for _ in range(success_count)]) if success_count > 0 else 0,
#             "avg_compile_time": statistics.mean(compile_times) if compile_times else 0,
#             "avg_optimization_time": statistics.mean(optimization_times) if optimization_times else 0,
#             "min_total_time": min([end_time - start_time for _ in range(success_count)]) if success_count > 0 else 0,
#             "max_total_time": max([end_time - start_time for _ in range(success_count)]) if success_count > 0 else 0,
#             "median_total_time": statistics.median([end_time - start_time for _ in range(success_count)]) if success_count > 0 else 0
#         }

#     def benchmark_trm_agent_optimization(self, ir: Dict[str, Any], optimization_type: str, strategy: str, iterations: int = 10) -> Dict[str, Any]:
#         """Benchmark TRM-Agent optimization performance"""
optimization_times = []
confidences = []
success_count = 0

#         for _ in range(iterations):
optimize_request = {
#                 "ir": ir,
#                 "optimization_type": optimization_type,
#                 "strategy": strategy
#             }

#             # Start timing
start_time = time.time()

response = requests.post(
#                 f"{self.trm_agent_url}/api/v1/trm-agent/optimize",
json = optimize_request,
headers = {"Content-Type": "application/json"},
timeout = 30
#             )

#             if response.status_code == 200:
data = response.json()
optimization_id = data.get("optimization_id")

#                 if optimization_id:
#                     # Poll for result
#                     while True:
result_response = requests.get(
#                             f"{self.trm_agent_url}/api/v1/trm-agent/optimize/{optimization_id}",
timeout = 30
#                         )

#                         if result_response.status_code == 200:
result_data = result_response.json()
status = result_data.get("status")

#                             if status == "success":
optimization_time = result_data.get("optimization_time", 0)
confidence = result_data.get("confidence", 0)

                                optimization_times.append(optimization_time)
                                confidences.append(confidence)
success_count + = 1
#                                 break
#                             elif status == "failed":
#                                 break

                        time.sleep(0.1)

#             # End timing
end_time = time.time()
total_time = math.subtract(end_time, start_time)

#         return {
#             "iterations": iterations,
#             "success_count": success_count,
#             "success_rate": success_count / iterations,
#             "total_times": [end_time - start_time for _ in range(success_count)],
#             "optimization_times": optimization_times,
#             "confidences": confidences,
#             "avg_total_time": statistics.mean([end_time - start_time for _ in range(success_count)]) if success_count > 0 else 0,
#             "avg_optimization_time": statistics.mean(optimization_times) if optimization_times else 0,
#             "avg_confidence": statistics.mean(confidences) if confidences else 0,
#             "min_total_time": min([end_time - start_time for _ in range(success_count)]) if success_count > 0 else 0,
#             "max_total_time": max([end_time - start_time for _ in range(success_count)]) if success_count > 0 else 0,
#             "median_total_time": statistics.median([end_time - start_time for _ in range(success_count)]) if success_count > 0 else 0
#         }

#     def benchmark_concurrent_requests(self, concurrent_users: int = 10, requests_per_user: int = 5) -> Dict[str, Any]:
#         """Benchmark concurrent request performance"""
total_times = []
success_count = 0

#         def make_request():
#             nonlocal success_count
compile_request = {
#                 "source_code": self.simple_code,
                "filename": f"concurrent_{int(time.time())}.py",
#                 "optimization_types": ["constant_folding"],
#                 "optimization_strategy": "balanced"
#             }

start_time = time.time()

#             try:
response = requests.post(
#                     f"{self.base_url}/api/v1/compile",
json = compile_request,
headers = {"Content-Type": "application/json"},
timeout = 30
#                 )

#                 if response.status_code == 200:
data = response.json()
request_id = data.get("request_id")

#                     if request_id:
#                         # Poll for result
#                         while True:
result_response = requests.get(
#                                 f"{self.base_url}/api/v1/compile/{request_id}",
timeout = 30
#                             )

#                             if result_response.status_code == 200:
result_data = result_response.json()
status = result_data.get("status")

#                                 if status in ["success", "failed"]:
#                                     if status == "success":
success_count + = 1

end_time = time.time()
                                    total_times.append(end_time - start_time)
#                                     break

                            time.sleep(0.1)
#             except requests.exceptions.RequestException:
end_time = time.time()
                total_times.append(end_time - start_time)

#         # Execute concurrent requests
#         with concurrent.futures.ThreadPoolExecutor(max_workers=concurrent_users) as executor:
futures = []
#             for _ in range(concurrent_users):
#                 for _ in range(requests_per_user):
                    futures.append(executor.submit(make_request))

#             # Wait for all requests to complete
            concurrent.futures.wait(futures)

total_requests = math.multiply(concurrent_users, requests_per_user)

#         return {
#             "concurrent_users": concurrent_users,
#             "requests_per_user": requests_per_user,
#             "total_requests": total_requests,
#             "success_count": success_count,
#             "success_rate": success_count / total_requests,
#             "total_times": total_times,
#             "avg_total_time": statistics.mean(total_times) if total_times else 0,
#             "min_total_time": min(total_times) if total_times else 0,
#             "max_total_time": max(total_times) if total_times else 0,
#             "median_total_time": statistics.median(total_times) if total_times else 0,
#             "requests_per_second": total_requests / (max(total_times) - min(total_times)) if total_times and max(total_times) > min(total_times) else 0
#         }

#     def run_benchmarks(self, iterations: int = 10, concurrent_users: int = 10, requests_per_user: int = 5) -> Dict[str, Any]:
#         """Run all benchmarks"""
        print("Starting NoodleCore performance benchmarks...")

#         # Check health
#         if not self.check_health():
            print("ERROR: NoodleCore service is not healthy")
#             return {}

#         if not self.check_trm_agent_health():
            print("WARNING: TRM-Agent service is not healthy")

#         # Benchmark compilation with simple code
#         print("Benchmarking compilation with simple code...")
self.results["simple_compilation"] = self.benchmark_compilation(
#             self.simple_code,
#             ["constant_folding"],
#             "balanced",
#             iterations
#         )

#         # Benchmark compilation with complex code
#         print("Benchmarking compilation with complex code...")
self.results["complex_compilation"] = self.benchmark_compilation(
#             self.complex_code,
#             ["constant_folding", "loop_optimization"],
#             "aggressive",
#             iterations
#         )

#         # Benchmark TRM-Agent optimization
#         if self.check_trm_agent_health():
            print("Benchmarking TRM-Agent optimization...")
ir = {
#                 "type": "ir",
#                 "operations": [
#                     {"type": "add", "operands": [1, 2]},
#                     {"type": "multiply", "operands": [3, 4]},
#                     {"type": "subtract", "operands": [5, 6]}
#                 ]
#             }

self.results["trm_agent_optimization"] = self.benchmark_trm_agent_optimization(
#                 ir,
#                 "constant_folding",
#                 "balanced",
#                 iterations
#             )

#         # Benchmark concurrent requests
        print("Benchmarking concurrent requests...")
self.results["concurrent_requests"] = self.benchmark_concurrent_requests(
#             concurrent_users,
#             requests_per_user
#         )

#         return self.results

#     def save_results(self, filename: str = "benchmark_results.json"):
#         """Save benchmark results to file"""
#         with open(filename, "w") as f:
json.dump(self.results, f, indent = 2)
        print(f"Benchmark results saved to {filename}")

#     def print_results(self):
#         """Print benchmark results"""
print("\n = == BENCHMARK RESULTS ===")

#         for benchmark_name, results in self.results.items():
            print(f"\n{benchmark_name.upper()}:")

#             if "success_rate" in results:
                print(f"  Success Rate: {results['success_rate']:.2%}")

#             if "avg_total_time" in results:
                print(f"  Average Total Time: {results['avg_total_time']:.4f}s")

#             if "avg_compile_time" in results:
                print(f"  Average Compile Time: {results['avg_compile_time']:.4f}s")

#             if "avg_optimization_time" in results:
                print(f"  Average Optimization Time: {results['avg_optimization_time']:.4f}s")

#             if "avg_confidence" in results:
                print(f"  Average Confidence: {results['avg_confidence']:.2f}")

#             if "requests_per_second" in results:
                print(f"  Requests Per Second: {results['requests_per_second']:.2f}")

#             if "min_total_time" in results and "max_total_time" in results:
                print(f"  Min/Max Time: {results['min_total_time']:.4f}s / {results['max_total_time']:.4f}s")


function main()
    #     """Main function"""
    parser = argparse.ArgumentParser(description="NoodleCore Performance Benchmark")
    parser.add_argument("--base-url", default = "http://localhost:8080", help="NoodleCore base URL")
    parser.add_argument("--trm-agent-url", default = "http://localhost:8081", help="TRM-Agent base URL")
    #     parser.add_argument("--iterations", type=int, default=10, help="Number of iterations for each benchmark")
    parser.add_argument("--concurrent-users", type = int, default=10, help="Number of concurrent users")
    parser.add_argument("--requests-per-user", type = int, default=5, help="Number of requests per user")
    #     parser.add_argument("--output", default="benchmark_results.json", help="Output file for results")
    parser.add_argument("--locust", action = "store_true", help="Run Locust performance test instead")
    parser.add_argument("--locust-users", type = int, default=10, help="Number of Locust users")
    parser.add_argument("--locust-hatch-rate", type = int, default=2, help="Locust hatch rate")
    parser.add_argument("--locust-run-time", default = "60s", help="Locust run time")

    args = parser.parse_args()

    #     if args.locust:
    #         # Run Locust performance test
    cmd = [
    #             "locust",
    #             "-f", "tests/performance/locustfile.py",
    #             "--host", args.base_url,
                "--users", str(args.locust_users),
                "--hatch-rate", str(args.locust_hatch_rate),
    #             "--run-time", args.locust_run_time,
    #             "--html", "locust_report.html"
    #         ]

            print(f"Running Locust performance test: {' '.join(cmd)}")
            subprocess.run(cmd)
    #     else:
    #         # Run benchmark script
    benchmark = PerformanceBenchmark(args.base_url, args.trm_agent_url)
    results = benchmark.run_benchmarks(args.iterations, args.concurrent_users, args.requests_per_user)

    #         if results:
                benchmark.print_results()
                benchmark.save_results(args.output)
    #         else:
                print("Benchmark failed")


if __name__ == "__main__"
        main()
