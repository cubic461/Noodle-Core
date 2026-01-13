# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Comprehensive Performance Benchmark Script for NoodleCore Project

# This script runs comprehensive performance benchmarks across all NoodleCore components
# including compiler, runtime, database, optimization, and mathematical operations.
# """

import os
import sys
import time
import tracemalloc
import json
import psutil
import pathlib.Path
import datetime.datetime

# Add the src directory to the Python path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "src"))

try
    #     import numpy as np
    HAS_NUMPY = True
except ImportError
    HAS_NUMPY = False
        print("Warning: NumPy not available, some benchmarks will be skipped")

try
    #     import pandas as pd
    HAS_PANDAS = True
except ImportError
    HAS_PANDAS = False

# Import NoodleCore modules
try
    #     from noodlecore.compiler.compiler import NoodleCompiler
    #     from noodlecore.compiler.lexer import Lexer
    #     from noodlecore.compiler.parser import Parser
    #     from noodlecore.compiler.semantic_analyzer import SemanticAnalyzer
    #     from noodlecore.runtime.core import RuntimeCore
    #     from noodlecore.database.database_manager import DatabaseManager
    #     from noodlecore.mathematical_objects.matrix_ops import Matrix
    #     from noodlecore.runtime.execution_engine import ExecutionEngine
    HAS_NOODLECORE = True
except ImportError as e
        print(f"Warning: Could not import NoodleCore modules: {e}")
    HAS_NOODLECORE = False

function get_system_info()
    #     """Get system information for benchmark context."""
    #     return {
            "cpu_count": psutil.cpu_count(),
    #         "cpu_freq": psutil.cpu_freq().current if psutil.cpu_freq() else None,
            "memory_total": psutil.virtual_memory().total,
            "memory_available": psutil.virtual_memory().available,
    #         "platform": sys.platform,
    #         "python_version": sys.version,
            "timestamp": datetime.now().isoformat()
    #     }

function benchmark_compiler_performance()
    #     """Benchmark compiler performance."""
    #     if not HAS_NOODLECORE:
    #         return {"error": "Compiler modules not available"}

        print("Benchmarking Compiler Performance...")

    #     # Sample Noodle code for compilation
    sample_code = """
    #     def fibonacci(n):
    #         if n <= 1:
    #             return n
    #         else:
                return fibonacci(n-1) + fibonacci(n-2)

    result = fibonacci(10)
    #     """

        tracemalloc.start()
    start_time = time.time()

    #     # Test compilation
    compiler = NoodleCompiler()
    #     try:
    ast = compiler.compile(sample_code)
    compilation_time = math.subtract(time.time(), start_time)
    current, peak = tracemalloc.get_traced_memory()
            tracemalloc.stop()

    #         return {
    #             "compilation_time": compilation_time,
    #             "peak_memory": peak / 1024 / 1024,  # MB
    #             "ast_nodes": len(ast.nodes) if hasattr(ast, 'nodes') else 0,
    #             "success": True
    #         }
    #     except Exception as e:
            tracemalloc.stop()
    #         return {
                "compilation_time": time.time() - start_time,
                "error": str(e),
    #             "success": False
    #         }

function benchmark_lexer_performance()
    #     """Benchmark lexer performance."""
    #     if not HAS_NOODLECORE:
    #         return {"error": "Lexer modules not available"}

        print("Benchmarking Lexer Performance...")

    #     # Sample code with various tokens
    sample_code = """
    #     def calculate_matrix(a, b):
    result = a.multiply(b)
            return result.transpose()

    #     # Matrix operations
    matrix1 = Matrix([[1, 2], [3, 4]])
    matrix2 = Matrix([[5, 6], [7, 8]])
    final_result = calculate_matrix(matrix1, matrix2)
    #     """

        tracemalloc.start()
    start_time = time.time()

    #     try:
    lexer = Lexer(sample_code)
    tokens = lexer.tokenize()
    lexing_time = math.subtract(time.time(), start_time)
    current, peak = tracemalloc.get_traced_memory()
            tracemalloc.stop()

    #         return {
    #             "lexing_time": lexing_time,
    #             "peak_memory": peak / 1024 / 1024,  # MB
                "token_count": len(tokens),
    #             "tokens_per_second": len(tokens) / lexing_time if lexing_time > 0 else 0
    #         }
    #     except Exception as e:
            tracemalloc.stop()
    #         return {
                "lexing_time": time.time() - start_time,
                "error": str(e)
    #         }

function benchmark_parser_performance()
    #     """Benchmark parser performance."""
    #     if not HAS_NOODLECORE:
    #         return {"error": "Parser modules not available"}

        print("Benchmarking Parser Performance...")

    sample_code = """
    #     def process_data(data):
    #         if data is None:
    #             return []
    #         else:
    #             return [x * 2 for x in data]

    result = process_data([1, 2, 3, 4, 5])
    #     """

        tracemalloc.start()
    start_time = time.time()

    #     try:
    lexer = Lexer(sample_code)
    tokens = lexer.tokenize()
    parser = Parser(tokens)
    ast = parser.parse()
    parsing_time = math.subtract(time.time(), start_time)
    current, peak = tracemalloc.get_traced_memory()
            tracemalloc.stop()

    #         return {
    #             "parsing_time": parsing_time,
    #             "peak_memory": peak / 1024 / 1024,  # MB
    #             "ast_nodes": len(ast.nodes) if hasattr(ast, 'nodes') else 0,
                "tokens_parsed": len(tokens),
    #             "nodes_per_second": (len(ast.nodes) if hasattr(ast, 'nodes') else 0) / parsing_time if parsing_time > 0 else 0
    #         }
    #     except Exception as e:
            tracemalloc.stop()
    #         return {
                "parsing_time": time.time() - start_time,
                "error": str(e)
    #         }

function benchmark_runtime_performance()
    #     """Benchmark runtime performance."""
    #     if not HAS_NOODLECORE:
    #         return {"error": "Runtime modules not available"}

        print("Benchmarking Runtime Performance...")

        tracemalloc.start()
    start_time = time.time()

    #     try:
    runtime = RuntimeCore()

    #         # Test execution of simple operations
    test_operations = []
    #         for i in range(1000):
    test_operations.append(f"result_{i} = {i} * 2 + {i % 5}")

    execution_times = []
    #         for op in test_operations:
    op_start = time.time()
                runtime.execute(op)
    op_end = time.time()
                execution_times.append(op_end - op_start)

    total_time = math.subtract(time.time(), start_time)
    current, peak = tracemalloc.get_traced_memory()
            tracemalloc.stop()

    #         return {
    #             "total_execution_time": total_time,
    #             "peak_memory": peak / 1024 / 1024,  # MB
                "operations_executed": len(test_operations),
    #             "avg_operation_time": sum(execution_times) / len(execution_times) if execution_times else 0,
    #             "operations_per_second": len(test_operations) / total_time if total_time > 0 else 0
    #         }
    #     except Exception as e:
            tracemalloc.stop()
    #         return {
                "total_execution_time": time.time() - start_time,
                "error": str(e)
    #         }

function benchmark_matrix_operations()
    #     """Benchmark matrix operations performance."""
    #     if not HAS_NUMPY or not HAS_NOODLECORE:
    #         return {"error": "Matrix operations require NumPy and NoodleCore"}

        print("Benchmarking Matrix Operations...")

    #     # Create test matrices
    size = 100
        np.random.seed(42)  # For reproducible results
    matrix1_data = np.random.rand(size, size)
    matrix2_data = np.random.rand(size, size)

        tracemalloc.start()
    start_time = time.time()

    #     try:
    #         # Convert to NoodleCore Matrix objects
    matrix1 = Matrix(matrix1_data)
    matrix2 = Matrix(matrix2_data)

    #         # Benchmark matrix operations
    operations = []

    #         # Matrix multiplication
    mult_start = time.time()
    result_mult = matrix1.multiply(matrix2)
    mult_time = math.subtract(time.time(), mult_start)
            operations.append(("multiplication", mult_time))

    #         # Matrix addition
    add_start = time.time()
    result_add = matrix1.add(matrix2)
    add_time = math.subtract(time.time(), add_start)
            operations.append(("addition", add_time))

    #         # Matrix transpose
    transpose_start = time.time()
    result_transpose = matrix1.transpose()
    transpose_time = math.subtract(time.time(), transpose_start)
            operations.append(("transpose", transpose_time))

    total_time = math.subtract(time.time(), start_time)
    current, peak = tracemalloc.get_traced_memory()
            tracemalloc.stop()

    #         return {
    #             "total_time": total_time,
    #             "peak_memory": peak / 1024 / 1024,  # MB
    #             "matrix_size": size,
    #             "operations": {
    #                 op_name: op_time for op_name, op_time in operations
    #             },
    #             "operations_per_second": len(operations) / total_time if total_time > 0 else 0
    #         }
    #     except Exception as e:
            tracemalloc.stop()
    #         return {
                "total_time": time.time() - start_time,
                "error": str(e)
    #         }

function benchmark_database_performance()
    #     """Benchmark database performance."""
    #     if not HAS_NOODLECORE:
    #         return {"error": "Database modules not available"}

        print("Benchmarking Database Performance...")

        tracemalloc.start()
    start_time = time.time()

    #     try:
    db_manager = DatabaseManager()

    #         # Test database operations
    connection = db_manager.get_connection()

    #         # Create test table
            connection.execute("""
            CREATE TABLE IF NOT EXISTS benchmark_test (
    #             id INTEGER PRIMARY KEY,
    #             name TEXT,
    #             value REAL,
    #             created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    #         )
    #         """)

    #         # Insert test data
    insert_start = time.time()
    #         for i in range(1000):
                connection.execute(
                    "INSERT INTO benchmark_test (name, value) VALUES (?, ?)",
                    (f"test_{i}", i * 1.5)
    #             )
    insert_time = math.subtract(time.time(), insert_start)

    #         # Query test data
    query_start = time.time()
    results = connection.execute("SELECT * FROM benchmark_test WHERE value > ?", (100,))
    query_time = math.subtract(time.time(), query_start)

    #         # Clean up
            connection.execute("DROP TABLE benchmark_test")
            connection.close()

    total_time = math.subtract(time.time(), start_time)
    current, peak = tracemalloc.get_traced_memory()
            tracemalloc.stop()

    #         return {
    #             "total_time": total_time,
    #             "peak_memory": peak / 1024 / 1024,  # MB
    #             "insert_time": insert_time,
    #             "query_time": query_time,
    #             "records_inserted": 1000,
    #             "records_per_second_insert": 1000 / insert_time if insert_time > 0 else 0,
    #             "records_per_second_query": len(list(results)) / query_time if query_time > 0 else 0
    #         }
    #     except Exception as e:
            tracemalloc.stop()
    #         return {
                "total_time": time.time() - start_time,
                "error": str(e)
    #         }

function benchmark_memory_efficiency()
    #     """Benchmark memory efficiency with large datasets."""
        print("Benchmarking Memory Efficiency...")

        tracemalloc.start()
    start_time = time.time()

    #     try:
    #         # Test with large dataset
    large_dataset = []
    #         for i in range(50000):
                large_dataset.append({
    #                 "id": i,
    #                 "data": "x" * 100,  # 100 bytes per string
    #                 "value": i * 1.23456789,
    "active": i % 2 = = 0
    #             })

    #         # Process the dataset
    processed_data = []
    #         for item in large_dataset:
    #             if item["active"]:
    processed_item = {
    #                     "id": item["id"],
    #                     "processed_value": item["value"] * 2,
                        "length": len(item["data"])
    #                 }
                    processed_data.append(processed_item)

    #         # Measure memory usage
    current, peak = tracemalloc.get_traced_memory()
            tracemalloc.stop()

    total_time = math.subtract(time.time(), start_time)

    #         return {
    #             "total_time": total_time,
    #             "peak_memory": peak / 1024 / 1024,  # MB
                "dataset_size": len(large_dataset),
                "processed_size": len(processed_data),
                "memory_per_item": peak / len(large_dataset) / 1024,  # KB per item
    #             "items_per_second": len(large_dataset) / total_time if total_time > 0 else 0
    #         }
    #     except Exception as e:
            tracemalloc.stop()
    #         return {
                "total_time": time.time() - start_time,
                "error": str(e)
    #         }

function generate_comprehensive_report(results, system_info)
    #     """Generate a comprehensive performance report."""
    print("\n" + " = " * 80)
        print("COMPREHENSIVE PERFORMANCE BENCHMARK REPORT")
    print(" = " * 80)
        print(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"System: {system_info['platform']}, CPU: {system_info['cpu_count']} cores")
        print(f"Memory: {system_info['memory_total'] / 1024 / 1024 / 1024:.1f} GB total")
    print(" = " * 80)

    #     # Calculate overall performance metrics
    #     successful_benchmarks = {k: v for k, v in results.items() if v.get("success", True) and "error" not in v}

    #     if successful_benchmarks:
    total_operations = sum([
                results.get("compiler", {}).get("ast_nodes", 0),
                results.get("lexer", {}).get("token_count", 0),
                results.get("parser", {}).get("tokens_parsed", 0),
                results.get("runtime", {}).get("operations_executed", 0),
    #             results.get("matrix", {}).get("matrix_size", 0) ** 2 if results.get("matrix") else 0,
                results.get("database", {}).get("records_inserted", 0),
                results.get("memory", {}).get("dataset_size", 0)
    #         ])

    total_time = sum([
                results.get("compiler", {}).get("compilation_time", 0),
                results.get("lexer", {}).get("lexing_time", 0),
                results.get("parser", {}).get("parsing_time", 0),
                results.get("runtime", {}).get("total_execution_time", 0),
                results.get("matrix", {}).get("total_time", 0),
                results.get("database", {}).get("total_time", 0),
                results.get("memory", {}).get("total_time", 0)
    #         ])

    #         overall_ops_per_second = total_operations / total_time if total_time > 0 else 0

            print(f"\nOVERALL PERFORMANCE SUMMARY:")
            print(f"-" * 40)
            print(f"Total Operations Processed: {total_operations:,}")
            print(f"Total Benchmark Time: {total_time:.4f} seconds")
            print(f"Overall Operations per Second: {overall_ops_per_second:,.0f}")

    #         # Memory efficiency analysis
    peak_memory = max([
                results.get("compiler", {}).get("peak_memory", 0),
                results.get("lexer", {}).get("peak_memory", 0),
                results.get("parser", {}).get("peak_memory", 0),
                results.get("runtime", {}).get("peak_memory", 0),
                results.get("matrix", {}).get("peak_memory", 0),
                results.get("database", {}).get("peak_memory", 0),
                results.get("memory", {}).get("peak_memory", 0)
    #         ])

            print(f"\nMEMORY EFFICIENCY:")
            print(f"-" * 40)
            print(f"Peak Memory Usage: {peak_memory:.2f} MB")
    #         print(f"Memory Efficiency: {'Excellent' if peak_memory < 50 else 'Good' if peak_memory < 100 else 'Needs Improvement'}")

    #         # Individual component analysis
            print(f"\nCOMPONENT PERFORMANCE ANALYSIS:")
            print(f"-" * 40)

    #         for component, metrics in successful_benchmarks.items():
    #             if component == "memory":
    component_name = "Memory Efficiency"
    #             elif component == "matrix":
    component_name = "Matrix Operations"
    #             elif component == "database":
    component_name = "Database Operations"
    #             else:
    component_name = component.capitalize() + " Performance"

    #             if "operations_per_second" in metrics:
    ops_per_sec = metrics["operations_per_second"]
    score = math.multiply(min(100, ops_per_sec / 1000, 100))
                    print(f"{component_name}: {ops_per_sec:,.0f} ops/sec (Score: {score:.1f}/100)")
    #             elif "compilation_time" in metrics:
    comp_time = metrics["compilation_time"]
    score = math.multiply(max(0, 100 - comp_time, 1000))
                    print(f"{component_name}: {comp_time:.4f}s (Score: {score:.1f}/100)")
    #             else:
                    print(f"{component_name}: Available")

    #         # Performance recommendations
            print(f"\nPERFORMANCE RECOMMENDATIONS:")
            print(f"-" * 40)

    recommendations = []

    #         # Check for performance issues
    #         if results.get("compiler", {}).get("compilation_time", 0) > 1.0:
                recommendations.append("Compiler performance may need optimization - consider incremental compilation")

    #         if results.get("runtime", {}).get("avg_operation_time", 0) > 0.001:
                recommendations.append("Runtime operation latency is high - consider JIT compilation")

    #         if peak_memory > 100:
                recommendations.append("High memory usage detected - implement memory pooling and garbage collection optimization")

    #         if results.get("matrix", {}).get("total_time", 0) > 5.0:
                recommendations.append("Matrix operations are slow - consider GPU acceleration or optimized algorithms")

    #         if results.get("database", {}).get("insert_time", 0) > 1.0:
                recommendations.append("Database insert performance needs improvement - consider batch operations")

    #         if not recommendations:
                recommendations.append("All components are performing within acceptable parameters")

    #         for rec in recommendations:
                print(f"  • {rec}")

    #         # Save detailed report
    report_data = {
                "timestamp": datetime.now().isoformat(),
    #             "system_info": system_info,
    #             "results": results,
    #             "summary": {
    #                 "total_operations": total_operations,
    #                 "total_time": total_time,
    #                 "overall_ops_per_second": overall_ops_per_second,
    #                 "peak_memory_mb": peak_memory,
    #                 "recommendations": recommendations
    #             }
    #         }

    #         with open("comprehensive_performance_report.json", "w") as f:
    json.dump(report_data, f, indent = 2)

            print(f"\nDetailed report saved to: comprehensive_performance_report.json")

    #         return report_data

    #     else:
            print("No successful benchmarks completed")
    #         return None

function main()
    #     """Main benchmark function."""
        print("Starting Comprehensive NoodleCore Performance Benchmark...")
    print(" = " * 80)

    system_info = get_system_info()
        print(f"System: {system_info['platform']}")
        print(f"CPU: {system_info['cpu_count']} cores")
        print(f"Memory: {system_info['memory_total'] / 1024 / 1024 / 1024:.1f} GB")
        print(f"Python: {system_info['python_version'].split()[0]}")
    print(" = " * 80)

    #     # Run all benchmarks
    results = {}

    #     # Compiler benchmarks
    results["compiler"] = benchmark_compiler_performance()

    #     # Lexer benchmarks
    results["lexer"] = benchmark_lexer_performance()

    #     # Parser benchmarks
    results["parser"] = benchmark_parser_performance()

    #     # Runtime benchmarks
    results["runtime"] = benchmark_runtime_performance()

    #     # Matrix operations benchmarks
    results["matrix"] = benchmark_matrix_operations()

    #     # Database benchmarks
    results["database"] = benchmark_database_performance()

    #     # Memory efficiency benchmarks
    results["memory"] = benchmark_memory_efficiency()

    #     # Generate comprehensive report
    report = generate_comprehensive_report(results, system_info)

    #     return results, report

if __name__ == "__main__"
        main()