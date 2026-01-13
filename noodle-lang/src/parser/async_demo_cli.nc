# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Noodle Core Async Operations CLI Demo
 = ====================================

# Demonstrates the enhanced async operations in NBC bytecode for Noodle Core.
# Shows how to use async operations in parallel AI agent workflows.

# Usage:
#     python async_demo_cli.py [options]

# Options:
#     --debug          Enable debug output
#     --timeout SEC    Timeout for async operations [default: 10]
#     --count N        Number of parallel operations [default: 3]
#     --matrix-size N  Matrix size for computations [default: 100]
#     --help           Show this help message
# """

import argparse
import asyncio
import sys
import time
import pathlib.Path
import typing.Any

# Add src to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

import noodle.compiler.code_generator.CodeGenerator
import noodle.runtime.merge.MergeManager
import noodle.runtime.nbc_runtime.core.async_runtime.AsyncRuntime
import noodle.runtime.nbc_runtime.core.runtime.Runtime
import noodle.runtime.project_manager.ProjectManager
import noodle.runtime.sandbox.Sandbox


class AsyncDemoCLI
    #     """CLI demo for async operations in Noodle Core"""

    #     def __init__(self, debug=False, timeout=10, count=3, matrix_size=100):
    self.debug = debug
    self.timeout = timeout
    self.count = count
    self.matrix_size = matrix_size
    self.runtime = AsyncRuntime(debug=debug)
    self.project_manager = ProjectManager()

    #         # Performance tracking
    self.start_time = None
    self.operations = []

    #     def generate_async_matrix_script(self, script_name: str, matrix_size: int) -str):
    #         """Generate a script that performs matrix operations asynchronously"""
    script_content = f"""
# Matrix computation script for async demo
import numpy as np
import time

# Create random matrix
matrix = np.random.rand({matrix_size}, {matrix_size})
result = np.dot(matrix, matrix.T)

# Simulate some computation
time.sleep(0.5)

print "Matrix computation completed"
print f"Matrix size: {{matrix_size}}x{{matrix_size}}"
print f"Result shape: {{result.shape}}"
print f"Result norm: {{np.linalg.norm(result)}}"
# """
#         return script_content

#     def create_async_bytecode_sequence(self, operation_id: str) -List):
#         """Create bytecode sequence for async operation"""
code_gen = CodeGenerator(debug=self.debug)

#         # Start async operation
        code_gen._emit(OpCode.ASYNC_HANDLE, [f"handle_{operation_id}"])
        code_gen._emit(OpCode.ASYNC_EXECUTE, [f"matrix_op_{operation_id}.nbc"])

#         # Wait for completion
        code_gen._emit(OpCode.ASYNC_AWAIT, [f"handle_{operation_id}"])

#         # Poll status
        code_gen._emit(OpCode.ASYNC_POLL, [f"handle_{operation_id}"])

#         # Get result
        code_gen._emit(OpCode.ASYNC_COMPLETE, [f"handle_{operation_id}"])

#         return code_gen.bytecode

#     async def run_single_async_operation(self, operation_id: str) -Dict[str, Any]):
#         """Run a single async operation"""
#         if self.debug:
            print(f"Starting async operation {operation_id}")

#         # Generate matrix operation script
script_content = self.generate_async_matrix_script(
#             operation_id, self.matrix_size
#         )

#         # Create temporary script file
script_path = f"matrix_op_{operation_id}.nbc"
#         with open(script_path, "w") as f:
            f.write(script_content)

#         # Run async operation
start_time = time.time()
handle = await self.runtime.execute_async_script(script_path)

#         if self.debug:
#             print(f"Operation {operation_id} started with handle: {handle}")

#         # Wait for completion
result = await self.runtime.wait_for_async(handle, timeout=self.timeout)

#         # Record metrics
end_time = time.time()
metrics = {
#             "operation_id": operation_id,
#             "handle": handle,
#             "start_time": start_time,
#             "end_time": end_time,
#             "duration": end_time - start_time,
#             "result": result,
#             "status": "completed",
#         }

#         # Clean up
Path(script_path).unlink(missing_ok = True)

#         if self.debug:
            print(f"Operation {operation_id} completed in {metrics['duration']:.2f}s")

#         return metrics

#     async def run_parallel_async_operations(self) -List[Dict[str, Any]]):
#         """Run multiple async operations in parallel"""
#         if self.debug:
            print(f"Starting {self.count} parallel async operations")

#         # Create tasks for parallel execution
tasks = []
#         for i in range(self.count):
task = asyncio.create_task(self.run_single_async_operation(f"op_{i}"))
            tasks.append(task)

#         # Wait for all tasks to complete
results = await asyncio.gather( * tasks, return_exceptions=True)

#         # Process results
processed_results = []
#         for i, result in enumerate(results):
#             if isinstance(result, Exception):
error_result = {
#                     "operation_id": f"op_{i}",
                    "error": str(result),
#                     "status": "failed",
#                 }
                processed_results.append(error_result)
#                 if self.debug:
                    print(f"Operation {i} failed: {result}")
#             else:
                processed_results.append(result)

#         return processed_results

#     async def run_async_batch_operations(self) -Dict[str, Any]):
#         """Run async batch operations"""
#         if self.debug:
#             print(f"Running async batch operations for {self.count} tasks")

#         # Create batch of scripts
script_paths = []
#         for i in range(self.count):
script_content = self.generate_async_matrix_script(
#                 f"batch_op_{i}", self.matrix_size
#             )
script_path = f"batch_op_{i}.nbc"
#             with open(script_path, "w") as f:
                f.write(script_content)
            script_paths.append(script_path)

#         # Run batch operation
start_time = time.time()
handles = await self.runtime.execute_async_batch(script_paths)

#         if self.debug:
#             print(f"Batch operation started with {len(handles)} handles")

#         # Wait for all batch operations
results = await self.runtime.join_async(handles)

#         # Record metrics
end_time = time.time()
metrics = {
#             "operation_type": "batch",
            "count": len(script_paths),
#             "start_time": start_time,
#             "end_time": end_time,
#             "duration": end_time - start_time,
#             "handles": handles,
#             "results": results,
#             "status": "completed",
#         }

#         # Clean up
#         for path in script_paths:
Path(path).unlink(missing_ok = True)

#         if self.debug:
            print(f"Batch operation completed in {metrics['duration']:.2f}s")

#         return metrics

#     async def run_async_error_handling_demo(self) -Dict[str, Any]):
#         """Demonstrate async error handling"""
#         if self.debug:
            print("Running async error handling demo")

#         # Create a script that will fail
failing_script = """
# This script is designed to fail
import time
time.sleep(0.5)
# raise Exception("Intentional failure for demo")
# """

script_path = "failing_script.nbc"
#         with open(script_path, "w") as f:
            f.write(failing_script)

#         # Try to run the failing script
#         try:
handle = await self.runtime.execute_async_script(script_path)
result = await self.runtime.wait_for_async(handle, timeout=self.timeout)
#         except Exception as e:
error_result = {
#                 "operation_id": "failing_operation",
                "error": str(e),
#                 "status": "failed",
#                 "handled": True,
#             }
#             if self.debug:
                print(f"Failing operation caught error: {e}")
#             return error_result
#         finally:
Path(script_path).unlink(missing_ok = True)

#         return {"error": "Expected operation to fail", "status": "unexpected_success"}

#     async def run_async_callback_demo(self) -Dict[str, Any]):
#         """Demonstrate async callback functionality"""
#         if self.debug:
            print("Running async callback demo")

callback_results = {"called": False, "result": None}

#         def demo_callback(result):
#             if self.debug:
#                 print(f"Callback called with result: {result}")
callback_results["called"] = True
callback_results["result"] = result

#         # Create successful script
successful_script = """
import time
time.sleep(0.5)
print "Operation completed successfully"
# """

script_path = "callback_script.nbc"
#         with open(script_path, "w") as f:
            f.write(successful_script)

#         try:
#             # Run with callback
handle = await self.runtime.execute_async_script(script_path)
            await self.runtime.register_async_callback(handle, demo_callback)

#             # Wait for completion
await self.runtime.wait_for_async(handle, timeout = self.timeout)

#             if callback_results["called"]:
#                 return {
#                     "operation_id": "callback_operation",
#                     "callback_called": True,
#                     "result": callback_results["result"],
#                     "status": "completed",
#                 }
#             else:
#                 return {
#                     "operation_id": "callback_operation",
#                     "callback_called": False,
#                     "status": "callback_failed",
#                 }
#         finally:
Path(script_path).unlink(missing_ok = True)

#     async def run_sandbox_async_demo(self) -Dict[str, Any]):
#         """Demonstrate async operations in sandboxes"""
#         if self.debug:
            print("Running sandbox async demo")

#         # Create sandbox
sandbox = Sandbox.create("async_demo_sandbox")

#         # Create script in sandbox
script_content = self.generate_async_matrix_script(
#             "sandbox_op", self.matrix_size
#         )
sandbox_path = Path(sandbox.path) / "sandbox_operation.nbc"

#         with open(sandbox_path, "w") as f:
            f.write(script_content)

#         # Run async operation in sandbox
start_time = time.time()
#         try:
handle = await self.runtime.execute_async_script(str(sandbox_path))
result = await self.runtime.wait_for_async(handle, timeout=self.timeout)

end_time = time.time()

#             return {
#                 "operation_type": "sandbox_async",
#                 "sandbox_id": sandbox.id,
#                 "handle": handle,
#                 "duration": end_time - start_time,
#                 "result": result,
#                 "status": "completed",
#             }
#         finally:
#             # Clean up sandbox
            sandbox.destroy()

#     async def run_concurrent_limit_demo(self) -Dict[str, Any]):
#         """Demonstrate concurrent operation limits"""
#         if self.debug:
            print("Running concurrent limit demo")

#         # Set low concurrency limit
original_limit = self.runtime.max_concurrent
self.runtime.max_concurrent = 2  # Limit to 2 concurrent operations

#         try:
#             # Start more operations than the limit
start_time = time.time()
handles = []

#             for i in range(5):
script_content = self.generate_async_matrix_script(
#                     f"limit_op_{i}", self.matrix_size
#                 )
script_path = f"limit_op_{i}.nbc"

#                 with open(script_path, "w") as f:
                    f.write(script_content)

handle = await self.runtime.execute_async_script(script_path)
                handles.append((handle, script_path))

#                 # Small delay to ensure operations don't all start exactly at once
                await asyncio.sleep(0.1)

#             # Wait for all operations
results = []
#             for handle, script_path in handles:
#                 try:
result = await self.runtime.wait_for_async(
handle, timeout = self.timeout
#                     )
                    results.append({"status": "completed"})
#                 except Exception as e:
                    results.append({"status": "failed", "error": str(e)})
#                 finally:
Path(script_path).unlink(missing_ok = True)

end_time = time.time()

#             return {
#                 "operation_type": "concurrent_limit",
#                 "limit": self.runtime.max_concurrent,
                "requested": len(handles),
#                 "results": results,
#                 "duration": end_time - start_time,
#                 "status": "completed",
#             }

#         finally:
#             # Restore original limit
self.runtime.max_concurrent = original_limit

#     async def run_performance_metrics_demo(self) -Dict[str, Any]):
#         """Collect and display performance metrics"""
#         if self.debug:
            print("Running performance metrics demo")

#         # Run some operations
        await self.run_parallel_async_operations()

#         # Get metrics
metrics = self.runtime.get_performance_metrics()

#         return {
#             "operation_type": "performance_metrics",
#             "metrics": metrics,
#             "status": "collected",
#         }

#     def print_results(self, results: List[Dict[str, Any]]):
#         """Print operation results"""
print("\n" + " = " * 50)
        print("ASYNC OPERATIONS RESULTS")
print(" = " * 50)

#         for result in results:
operation_id = result.get("operation_id", "unknown")
status = result.get("status", "unknown")
duration = result.get("duration", 0)

            print(f"\nOperation: {operation_id}")
            print(f"  Status: {status}")
            print(f"  Duration: {duration:.2f}s")

#             if "error" in result:
                print(f"  Error: {result['error']}")
#             elif "result" in result and result["result"]:
                print(f"  Result: {result['result'][:100]}...")

print("\n" + " = " * 50)

#     async def run_all_demos(self):
#         """Run all demo operations"""
        print("Starting Noodle Core Async Operations Demo")
        print(
f"Configuration: debug = {self.debug}, timeout={self.timeout}s, "
f"count = {self.count}, matrix_size={self.matrix_size}x{self.matrix_size}"
#         )

self.start_time = time.time()

demos = [
            ("Parallel Operations", self.run_parallel_async_operations),
            ("Batch Operations", self.run_async_batch_operations),
            ("Error Handling", self.run_async_error_handling_demo),
            ("Callback Demo", self.run_async_callback_demo),
            ("Sandbox Async", self.run_sandbox_async_demo),
            ("Concurrent Limits", self.run_concurrent_limit_demo),
            ("Performance Metrics", self.run_performance_metrics_demo),
#         ]

all_results = []

#         for demo_name, demo_func in demos:
            print(f"\nRunning {demo_name}...")
#             try:
result = await demo_func()
                all_results.append(result)

#                 if self.debug:
                    print(f"{demo_name} completed successfully")

#             except Exception as e:
error_result = {
#                     "demo_name": demo_name,
                    "error": str(e),
#                     "status": "failed",
#                 }
                all_results.append(error_result)
                print(f"{demo_name} failed: {e}")

#         # Print summary
total_time = time.time() - self.start_time
        print(f"\nTotal demo time: {total_time:.2f}s")

#         # Print detailed results
        self.print_results(all_results)

#         # Print performance summary
#         if self.debug:
metrics = self.runtime.get_performance_metrics()
            print(f"\nPerformance Summary:")
            print(f"  Total Operations: {metrics.get('operations_completed', 0)}")
            print(f"  Average Latency: {metrics.get('average_latency', 0):.2f}s")
            print(f"  Cache Hits: {metrics.get('cache_hits', 0)}")

#         return all_results


# async def main():
#     """Main entry point"""
parser = argparse.ArgumentParser(
description = "Noodle Core Async Operations CLI Demo"
#     )
parser.add_argument("--debug", action = "store_true", help="Enable debug output")
    parser.add_argument(
#         "--timeout", type=int, default=10, help="Timeout for async operations"
#     )
    parser.add_argument(
"--count", type = int, default=3, help="Number of parallel operations"
#     )
    parser.add_argument(
#         "--matrix-size", type=int, default=100, help="Matrix size for computations"
#     )
    parser.add_argument(
#         "--demo",
choices = [
#             "all",
#             "parallel",
#             "batch",
#             "error",
#             "callback",
#             "sandbox",
#             "limits",
#             "metrics",
#         ],
default = "all",
help = "Specific demo to run",
#     )

args = parser.parse_args()

#     # Create demo instance
demo = AsyncDemoCLI(
debug = args.debug,
timeout = args.timeout,
count = args.count,
matrix_size = args.matrix_size,
#     )

#     # Run selected demo
#     if args.demo == "all":
        await demo.run_all_demos()
#     else:
#         # Run specific demo
demo_map = {
#             "parallel": demo.run_parallel_async_operations,
#             "batch": demo.run_async_batch_operations,
#             "error": demo.run_async_error_handling_demo,
#             "callback": demo.run_async_callback_demo,
#             "sandbox": demo.run_sandbox_async_demo,
#             "limits": demo.run_concurrent_limit_demo,
#             "metrics": demo.run_performance_metrics_demo,
#         }

#         if args.demo in demo_map:
result = await demo_map[args.demo]()
            (
                demo.print_results([result])
#                 if isinstance(result, dict)
                else demo.print_results(result)
#             )
#         else:
            print(f"Unknown demo: {args.demo}")
#             return 1

#     return 0


if __name__ == "__main__"
    exit_code = asyncio.run(main())
        sys.exit(exit_code)
