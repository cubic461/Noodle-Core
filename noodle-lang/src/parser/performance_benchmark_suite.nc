# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Performance Benchmark Suite for Noodle Core Components

# This script implements comprehensive performance benchmarks for Noodle's core components,
# including matrix operations, vision processing, runtime performance, and memory usage.
# Results are saved with detailed reports and visualizations.
# """

import time
import tracemalloc
import psutil
import json
import argparse
import logging
import datetime.datetime
import pathlib.Path
import typing.Dict
import numpy as np

# Import Noodle components
import sys
sys.path.append(str(Path(__file__).parent.parent / "noodle-core" / "src"))

try
    #     from noodlecore.mathematical_objects.matrix_ops import Matrix, Vector, Tensor, Scalar
    #     from noodlecore.runtime.core import Runtime
    #     from noodlecore.database.database_manager import DatabaseManager
    #     import noodlecore
except ImportError as e
        print(f"Warning: Could not import Noodle components: {e}")
        print("Running in limited mode without Noodle integration")

    #     # Create fallback implementations for testing
    #     class Matrix:
    #         def __init__(self, data):
    self.data = np.array(data, dtype=np.float64)

    #         def __mul__(self, other):
    #             if isinstance(other, Matrix):
                    return Matrix(np.dot(self.data, other.data))
                return Matrix(self.data * other)

    #         def __add__(self, other):
    #             if isinstance(other, Matrix):
                    return Matrix(self.data + other.data)
                return Matrix(self.data + other)

    #     class Vector:
    #         def __init__(self, data):
    self.data = np.array(data, dtype=np.float64)

    #     class Runtime:
    #         def __init__(self):
    #             pass

# Import visualization libraries if available
try
    #     import matplotlib.pyplot as plt
    #     import seaborn as sns
    VISUALIZATION_AVAILABLE = True
        plt.style.use('seaborn-v0_8')
        sns.set_palette("husl")
except ImportError
    VISUALIZATION_AVAILABLE = False
        print("Warning: Visualization libraries not available. Charts will be skipped.")

# Setup logging
logging.basicConfig(
level = logging.INFO,
format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
handlers = [
        logging.FileHandler('benchmark_suite.log'),
        logging.StreamHandler()
#     ]
# )
logger = logging.getLogger(__name__)

class BenchmarkSuite
    #     """Main benchmark suite for Noodle components."""

    #     def __init__(self, output_dir: Path = Path("benchmark_results")):
    self.output_dir = output_dir
    self.output_dir.mkdir(exist_ok = True)

    #         # Results storage
    self.results: Dict[str, List[Dict[str, Any]]] = {
    #             'matrix_operations': [],
    #             'runtime_performance': [],
    #             'memory_usage': [],
    #             'database_operations': [],
    #             'overall_metrics': []
    #         }

    #         # Performance tracking
    self.start_time = None
    self.end_time = None

    #         # Process monitoring
    self.process = psutil.Process()

    #         # Setup logging
    self.logger = logging.getLogger(f"{__name__}.{self.__class__.__name__}")

    #     def setup_environment(self):
    #         """Setup benchmark environment."""
            self.logger.info("Setting up benchmark environment...")

    #         # Start memory tracing
            tracemalloc.start()

    #         # Initialize test data
    self.test_matrices = {
                'small': Matrix(np.random.random((10, 10))),
                'medium': Matrix(np.random.random((100, 100))),
                'large': Matrix(np.random.random((500, 500))),
                'xlarge': Matrix(np.random.random((1000, 1000)))
    #         }

    self.test_vectors = {
                'small': Vector(np.random.random(10)),
                'medium': Vector(np.random.random(100)),
                'large': Vector(np.random.random(1000))
    #         }

    self.test_scalars = {
                'small': Scalar(1.5),
                'medium': Scalar(42.0),
                'large': Scalar(3.14159)
    #         }

    #         # Initialize runtime
    #         try:
    self.runtime = Runtime()
    #         except Exception as e:
                self.logger.warning(f"Failed to initialize Runtime: {e}")
    self.runtime = None

    #         # Initialize database
    #         try:
    self.db_path = self.output_dir / "test_benchmark.db"
    self.db = DatabaseManager(str(self.db_path))
    #         except Exception as e:
                self.logger.warning(f"Failed to initialize Database: {e}")
    self.db = None

            self.logger.info("Benchmark environment setup complete")

    #     def run_matrix_operations_benchmark(self):
    #         """Run comprehensive matrix operations benchmark."""
            self.logger.info("Running matrix operations benchmark...")

    operations = [
                ('multiplication', lambda m1, m2: m1 * m2),
                ('addition', lambda m1, m2: m1 + m2),
                ('scalar_multiplication', lambda m, s: m * s),
                ('scalar_addition', lambda m, s: m + s)
    #         ]

    #         for size_name, matrix in self.test_matrices.items():
    #             for op_name, operation in operations:
                    self.logger.info(f"Benchmarking {op_name} on {size_name} matrix...")

    #                 # Warm up
    #                 if size_name == 'small' and op_name in ['multiplication', 'addition']:
    _ = operation(matrix, matrix)
    #                 elif op_name in ['scalar_multiplication', 'scalar_addition']:
    _ = operation(matrix, self.test_scalars['small'])

    #                 # Benchmark
    times = []
    memory_before = math.divide(self.process.memory_info().rss, 1024 / 1024)

    #                 for _ in range(10):  # 10 iterations
    start_time = time.perf_counter()

    #                     if op_name in ['multiplication', 'addition']:
    result = operation(matrix, matrix)
    #                     else:  # scalar operations
    result = operation(matrix, self.test_scalars['small'])

    end_time = time.perf_counter()
                        times.append(end_time - start_time)

    memory_after = math.divide(self.process.memory_info().rss, 1024 / 1024)
    memory_used = memory_after - memory_before

    #                 # Store results
    result = {
    #                     'operation': op_name,
    #                     'matrix_size': size_name,
    #                     'matrix_dimensions': f"{matrix.data.shape[0]}x{matrix.data.shape[1]}",
                        'avg_time': sum(times) / len(times),
                        'min_time': min(times),
                        'max_time': max(times),
                        'std_time': np.std(times),
    #                     'memory_used': memory_used,
                        'timestamp': datetime.now().isoformat()
    #                 }

                    self.results['matrix_operations'].append(result)
                    self.logger.info(f"{op_name} on {size_name}: {result['avg_time']:.4f}s avg")

    #         # Vector operations
    vector_operations = [
                ('dot_product', lambda v1, v2: v1.dot(v2)),
                ('cross_product', lambda v1, v2: v1.cross(v2)),
                ('normalize', lambda v: v.normalize())
    #         ]

    #         for size_name, vector in self.test_vectors.items():
    #             for op_name, operation in vector_operations:
                    self.logger.info(f"Benchmarking vector {op_name} on {size_name} vector...")

    #                 # Warm up
    #                 if op_name == 'dot_product':
    _ = operation(vector, vector)
    #                 elif op_name == 'cross_product' and size_name == 'small':
    _ = operation(vector, vector)
    #                 elif op_name == 'normalize':
    _ = operation(vector)

    #                 # Benchmark
    times = []
    memory_before = math.divide(self.process.memory_info().rss, 1024 / 1024)

    #                 for _ in range(10):
    start_time = time.perf_counter()

    #                     if op_name == 'dot_product':
    result = operation(vector, vector)
    #                     elif op_name == 'cross_product':
    #                         # Create another vector for cross product
    other_vector = Vector(np.random.random(len(vector.data)))
    result = operation(vector, other_vector)
    #                     else:  # normalize
    result = operation(vector)

    end_time = time.perf_counter()
                        times.append(end_time - start_time)

    memory_after = math.divide(self.process.memory_info().rss, 1024 / 1024)
    memory_used = memory_after - memory_before

    #                 # Store results
    result = {
    #                     'operation': f"vector_{op_name}",
    #                     'vector_size': size_name,
                        'vector_length': len(vector.data),
                        'avg_time': sum(times) / len(times),
                        'min_time': min(times),
                        'max_time': max(times),
                        'std_time': np.std(times),
    #                     'memory_used': memory_used,
                        'timestamp': datetime.now().isoformat()
    #                 }

                    self.results['matrix_operations'].append(result)
                    self.logger.info(f"Vector {op_name} on {size_name}: {result['avg_time']:.4f}s avg")

    #     def run_runtime_performance_benchmark(self):
    #         """Run runtime performance benchmark."""
            self.logger.info("Running runtime performance benchmark...")

    #         if self.runtime is None:
                self.logger.warning("Runtime not available, skipping runtime benchmark")
    #             return

    #         # Test different runtime operations
    runtime_operations = [
                ('simple_calculation', lambda: sum(range(1000))),
                ('matrix_operation', lambda: self.test_matrices['small'] * self.test_matrices['small']),
                ('complex_calculation', lambda: np.sum(self.test_matrices['medium'].data ** 2)),
    #             ('loop_operation', lambda: [x**2 for x in range(1000)])
    #         ]

    #         for op_name, operation in runtime_operations:
                self.logger.info(f"Benchmarking runtime {op_name}...")

    #             # Warm up
    _ = operation()

    #             # Benchmark
    times = []
    memory_before = math.divide(self.process.memory_info().rss, 1024 / 1024)

    #             for _ in range(100):  # 100 iterations for runtime ops
    start_time = time.perf_counter()
    result = operation()
    end_time = time.perf_counter()
                    times.append(end_time - start_time)

    memory_after = math.divide(self.process.memory_info().rss, 1024 / 1024)
    memory_used = memory_after - memory_before

    #             # Store results
    result = {
    #                 'operation': f"runtime_{op_name}",
                    'avg_time': sum(times) / len(times),
                    'min_time': min(times),
                    'max_time': max(times),
                    'std_time': np.std(times),
    #                 'memory_used': memory_used,
                    'iterations': len(times),
                    'timestamp': datetime.now().isoformat()
    #             }

                self.results['runtime_performance'].append(result)
                self.logger.info(f"Runtime {op_name}: {result['avg_time']:.4f}s avg")

    #     def run_database_operations_benchmark(self):
    #         """Run database operations benchmark."""
            self.logger.info("Running database operations benchmark...")

    #         if self.db is None:
                self.logger.warning("Database not available, skipping database benchmark")
    #             return

    #         # Create test table
    #         try:
                self.db.create_table("benchmark_test", {
    #                 "id": "INTEGER PRIMARY KEY",
    #                 "name": "TEXT",
    #                 "value": "REAL",
    #                 "timestamp": "TEXT"
    #             })
    #         except Exception as e:
                self.logger.warning(f"Failed to create test table: {e}")
    #             return

    #         # Test different database operations
    test_data = [
                ("test_1", 3.14159, datetime.now().isoformat()),
                ("test_2", 2.71828, datetime.now().isoformat()),
                ("test_3", 1.61803, datetime.now().isoformat())
    #         ]

    #         # Insert benchmark
            self.logger.info("Benchmarking database insert operations...")
    times = []
    memory_before = math.divide(self.process.memory_info().rss, 1024 / 1024)

    #         for i, (name, value, timestamp) in enumerate(test_data * 10):  # 30 inserts
    start_time = time.perf_counter()
                self.db.insert("benchmark_test", {
    #                 "id": i + 1,
    #                 "name": name,
    #                 "value": value,
    #                 "timestamp": timestamp
    #             })
    end_time = time.perf_counter()
                times.append(end_time - start_time)

    memory_after = math.divide(self.process.memory_info().rss, 1024 / 1024)
    memory_used = memory_after - memory_before

    #         # Store insert results
    result = {
    #             'operation': 'database_insert',
                'avg_time': sum(times) / len(times),
                'min_time': min(times),
                'max_time': max(times),
                'std_time': np.std(times),
    #             'memory_used': memory_used,
                'records_inserted': len(times),
                'timestamp': datetime.now().isoformat()
    #         }

            self.results['database_operations'].append(result)
            self.logger.info(f"Database insert: {result['avg_time']:.4f}s avg")

    #         # Query benchmark
            self.logger.info("Benchmarking database query operations...")
    times = []
    memory_before = math.divide(self.process.memory_info().rss, 1024 / 1024)

    #         for _ in range(10):  # 10 queries
    start_time = time.perf_counter()
    results = self.db.query("benchmark_test", {})
    end_time = time.perf_counter()
                times.append(end_time - start_time)

    memory_after = math.divide(self.process.memory_info().rss, 1024 / 1024)
    memory_used = memory_after - memory_before

    #         # Store query results
    result = {
    #             'operation': 'database_query',
                'avg_time': sum(times) / len(times),
                'min_time': min(times),
                'max_time': max(times),
                'std_time': np.std(times),
    #             'memory_used': memory_used,
    #             'records_returned': len(results) if isinstance(results, list) else 0,
                'timestamp': datetime.now().isoformat()
    #         }

            self.results['database_operations'].append(result)
            self.logger.info(f"Database query: {result['avg_time']:.4f}s avg")

    #     def run_memory_usage_analysis(self):
    #         """Run comprehensive memory usage analysis."""
            self.logger.info("Running memory usage analysis...")

    #         # Test memory usage patterns
    test_cases = [
    #             ('small_matrices', lambda: [Matrix(np.random.random((10, 10))) for _ in range(100)]),
    #             ('medium_matrices', lambda: [Matrix(np.random.random((100, 100))) for _ in range(50)]),
    #             ('large_matrices', lambda: [Matrix(np.random.random((500, 500))) for _ in range(10)]),
                ('mixed_operations', lambda: self._create_mixed_operations())
    #         ]

    #         for test_name, test_func in test_cases:
    #             self.logger.info(f"Testing memory usage for {test_name}...")

    #             # Measure memory before
    mem_before = math.divide(self.process.memory_info().rss, 1024 / 1024)
    snapshot_before = tracemalloc.take_snapshot()

    #             # Execute test
    data = test_func()

    #             # Measure memory after
    mem_after = math.divide(self.process.memory_info().rss, 1024 / 1024)
    snapshot_after = tracemalloc.take_snapshot()

    memory_used = mem_after - mem_before

    #             # Analyze memory difference
    top_stats = snapshot_after.compare_to(snapshot_before, 'lineno')
    memory_allocations = []

    #             for stat in top_stats[:10]:  # Top 10 allocations
                    memory_allocations.append({
    #                     'file': stat.traceback.format()[-1] if stat.traceback else 'unknown',
    #                     'line': stat.traceback.format()[0].split(':')[1] if stat.traceback else 'unknown',
    #                     'size': stat.size / 1024 / 1024,  # MB
    #                     'count': stat.count
    #                 })

    #             # Store results
    result = {
    #                 'test_case': test_name,
    #                 'memory_used': memory_used,
    #                 'peak_memory': mem_after,
    #                 'objects_count': len(data) if hasattr(data, '__len__') else 1,
    #                 'top_allocations': memory_allocations,
                    'timestamp': datetime.now().isoformat()
    #             }

                self.results['memory_usage'].append(result)

    #             # Cleanup
    #             del data
                gc.collect()

                self.logger.info(f"{test_name}: {memory_used:.2f}MB used")

    #     def _create_mixed_operations(self):
    #         """Create mixed operations for memory benchmark."""
    operations = []

    #         # Create various matrices
    #         for size in [10, 50, 100]:
    matrix = Matrix(np.random.random((size, size)))
                operations.extend([
    #                 matrix + matrix,
    #                 matrix * 2,
    #                 matrix.transpose() if hasattr(matrix, 'transpose') else matrix,
    #                 matrix * matrix
    #             ])

    #         return operations

    #     def generate_reports(self):
    #         """Generate comprehensive benchmark reports."""
            self.logger.info("Generating benchmark reports...")

    #         # Generate JSON report
    json_report = {
    #             'benchmark_info': {
    #                 'start_time': self.start_time.isoformat() if self.start_time else None,
    #                 'end_time': self.end_time.isoformat() if self.end_time else None,
    #                 'total_duration': (self.end_time - self.start_time).total_seconds() if self.start_time and self.end_time else None,
                    'output_directory': str(self.output_dir),
                    'timestamp': datetime.now().isoformat()
    #             },
    #             'results': self.results,
    #             'system_info': {
                    'cpu_count': psutil.cpu_count(),
    #                 'cpu_freq': psutil.cpu_freq().current if psutil.cpu_freq() else None,
                    'total_memory': psutil.virtual_memory().total / 1024 / 1024 / 1024,  # GB
    #                 'python_version': sys.version,
    #                 'numpy_version': np.__version__
    #             }
    #         }

    #         # Save JSON report
    json_path = self.output_dir / "benchmark_report.json"
    #         with open(json_path, 'w') as f:
    json.dump(json_report, f, indent = 2)

            self.logger.info(f"JSON report saved to: {json_path}")

    #         # Generate Markdown report
            self._generate_markdown_report()

    #         # Generate visualizations if available
    #         if VISUALIZATION_AVAILABLE:
                self._generate_visualizations()

    #         # Save summary
            self._save_summary()

    #     def _generate_markdown_report(self):
    #         """Generate comprehensive Markdown report."""
            self.logger.info("Generating Markdown report...")

    report = []
            report.append("# Noodle Performance Benchmark Report")
            report.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
            report.append("")

    #         # System information
            report.append("## System Information")
            report.append(f"- **CPU Cores**: {psutil.cpu_count()}")
    #         report.append(f"- **CPU Frequency**: {psutil.cpu_freq().current:.2f} MHz" if psutil.cpu_freq() else "- **CPU Frequency**: Unknown")
            report.append(f"- **Total Memory**: {psutil.virtual_memory().total / 1024 / 1024 / 1024:.2f} GB")
            report.append(f"- **Python Version**: {sys.version.split()[0]}")
            report.append(f"- **NumPy Version**: {np.__version__}")
            report.append("")

    #         # Matrix operations summary
            report.append("## Matrix Operations")
    #         if self.results['matrix_operations']:
                report.append("### Performance Summary")
                report.append("| Operation | Size | Dimensions | Avg Time (s) | Min Time (s) | Max Time (s) | Std Dev | Memory Used (MB) |")
                report.append("|-----------|------|------------|--------------|--------------|--------------|---------|------------------|")

    #             for result in self.results['matrix_operations']:
    #                 size_display = result['matrix_size'] if 'matrix_size' in result else result['vector_size']
    dimensions = result.get('matrix_dimensions', result.get('vector_length', 'N/A'))
    op_name = result['operation'].replace('vector_', 'Vector ').title()

                    report.append(f"| {op_name} | {size_display} | {dimensions} | {result['avg_time']:.4f} | {result['min_time']:.4f} | {result['max_time']:.4f} | {result['std_time']:.4f} | {result['memory_used']:.2f} |")

    #         # Runtime performance summary
            report.append("## Runtime Performance")
    #         if self.results['runtime_performance']:
                report.append("### Performance Summary")
                report.append("| Operation | Avg Time (s) | Min Time (s) | Max Time (s) | Std Dev | Memory Used (MB) |")
                report.append("|-----------|--------------|--------------|--------------|---------|------------------|")

    #             for result in self.results['runtime_performance']:
    op_name = result['operation'].replace('runtime_', '').title().replace('_', ' ')
                    report.append(f"| {op_name} | {result['avg_time']:.4f} | {result['min_time']:.4f} | {result['max_time']:.4f} | {result['std_time']:.4f} | {result['memory_used']:.2f} |")

    #         # Database operations summary
            report.append("## Database Operations")
    #         if self.results['database_operations']:
                report.append("### Performance Summary")
                report.append("| Operation | Avg Time (s) | Min Time (s) | Max Time (s) | Std Dev | Memory Used (MB) | Records |")
                report.append("|-----------|--------------|--------------|--------------|---------|------------------|---------|")

    #             for result in self.results['database_operations']:
    op_name = result['operation'].replace('database_', '').title().replace('_', ' ')
    records = result.get('records_inserted', result.get('records_returned', 'N/A'))
                    report.append(f"| {op_name} | {result['avg_time']:.4f} | {result['min_time']:.4f} | {result['max_time']:.4f} | {result['std_time']:.4f} | {result['memory_used']:.2f} | {records} |")

    #         # Memory usage summary
            report.append("## Memory Usage")
    #         if self.results['memory_usage']:
                report.append("### Memory Usage Summary")
                report.append("| Test Case | Memory Used (MB) | Peak Memory (MB) | Objects Count |")
                report.append("|-----------|------------------|------------------|---------------|")

    #             for result in self.results['memory_usage']:
                    report.append(f"| {result['test_case']} | {result['memory_used']:.2f} | {result['peak_memory']:.2f} | {result['objects_count']} |")

    #         # Save Markdown report
    md_path = self.output_dir / "benchmark_report.md"
    #         with open(md_path, 'w') as f:
                f.write('\n'.join(report))

            self.logger.info(f"Markdown report saved to: {md_path}")

    #     def _generate_visualizations(self):
    #         """Generate performance visualization charts."""
            self.logger.info("Generating visualizations...")

    #         # Matrix operations performance chart
    #         if self.results['matrix_operations']:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))

    #             # Group by operation and size
    op_data = {}
    #             for result in self.results['matrix_operations']:
    op_key = f"{result['operation']}_{result.get('matrix_size', result.get('vector_size', 'unknown'))}"
    #                 if op_key not in op_data:
    op_data[op_key] = []
                    op_data[op_key].append(result['avg_time'])

    #             # Create bar chart
    operations = list(op_data.keys())
    #             times = [sum(times) / len(times) for times in op_data.values()]

                ax1.bar(range(len(operations)), times)
                ax1.set_xlabel('Operation')
                ax1.set_ylabel('Average Time (s)')
                ax1.set_title('Matrix Operations Performance')
                ax1.set_xticks(range(len(operations)))
    ax1.set_xticklabels(operations, rotation = 45, ha='right')

    #             # Memory usage chart
    memory_data = {}
    #             for result in self.results['matrix_operations']:
    op_key = f"{result['operation']}_{result.get('matrix_size', result.get('vector_size', 'unknown'))}"
    memory_data[op_key] = result['memory_used']

    operations = list(memory_data.keys())
    #             memory = [memory_data[op] for op in operations]

                ax2.bar(range(len(operations)), memory)
                ax2.set_xlabel('Operation')
                ax2.set_ylabel('Memory Used (MB)')
                ax2.set_title('Matrix Operations Memory Usage')
                ax2.set_xticks(range(len(operations)))
    ax2.set_xticklabels(operations, rotation = 45, ha='right')

                plt.tight_layout()

    #             # Save chart
    chart_path = self.output_dir / "matrix_operations_performance.png"
    plt.savefig(chart_path, dpi = 300, bbox_inches='tight')
                plt.close()

                self.logger.info(f"Matrix operations chart saved to: {chart_path}")

    #         # Runtime performance chart
    #         if self.results['runtime_performance']:
    fig, ax = plt.subplots(figsize=(12, 6))

    #             operations = [result['operation'].replace('runtime_', '').title().replace('_', ' ') for result in self.results['runtime_performance']]
    #             times = [result['avg_time'] for result in self.results['runtime_performance']]

                ax.bar(range(len(operations)), times)
                ax.set_xlabel('Operation')
                ax.set_ylabel('Average Time (s)')
                ax.set_title('Runtime Performance')
                ax.set_xticks(range(len(operations)))
    ax.set_xticklabels(operations, rotation = 45, ha='right')

                plt.tight_layout()

    #             # Save chart
    chart_path = self.output_dir / "runtime_performance.png"
    plt.savefig(chart_path, dpi = 300, bbox_inches='tight')
                plt.close()

                self.logger.info(f"Runtime performance chart saved to: {chart_path}")

    #     def _save_summary(self):
    #         """Save benchmark summary."""
            self.logger.info("Generating summary...")

    summary = []
            summary.append("Noodle Performance Benchmark Summary")
    summary.append(" = " * 50)
            summary.append("")

    #         total_tests = sum(len(results) for results in self.results.values())
            summary.append(f"Total Tests Run: {total_tests}")
            summary.append(f"Output Directory: {self.output_dir}")
            summary.append("")

    #         # Performance highlights
    #         if self.results['matrix_operations']:
    fastest_matrix = min(self.results['matrix_operations'], key=lambda x: x['avg_time'])
    slowest_matrix = max(self.results['matrix_operations'], key=lambda x: x['avg_time'])

                summary.append("Matrix Operations:")
                summary.append(f"  Fastest: {fastest_matrix['operation']} on {fastest_matrix.get('matrix_size', 'unknown')} - {fastest_matrix['avg_time']:.4f}s")
                summary.append(f"  Slowest: {slowest_matrix['operation']} on {slowest_matrix.get('matrix_size', 'unknown')} - {slowest_matrix['avg_time']:.4f}s")
                summary.append("")

    #         if self.results['runtime_performance']:
    fastest_runtime = min(self.results['runtime_performance'], key=lambda x: x['avg_time'])
    slowest_runtime = max(self.results['runtime_performance'], key=lambda x: x['avg_time'])

                summary.append("Runtime Performance:")
                summary.append(f"  Fastest: {fastest_runtime['operation'].replace('runtime_', '').title().replace('_', ' ')} - {fastest_runtime['avg_time']:.4f}s")
                summary.append(f"  Slowest: {slowest_runtime['operation'].replace('runtime_', '').title().replace('_', ' ')} - {slowest_runtime['avg_time']:.4f}s")
                summary.append("")

    #         # Memory highlights
    #         if self.results['memory_usage']:
    highest_memory = max(self.results['memory_usage'], key=lambda x: x['memory_used'])
                summary.append("Memory Usage:")
                summary.append(f"  Highest: {highest_memory['test_case']} - {highest_memory['memory_used']:.2f}MB")
                summary.append("")

    #         # Save summary
    summary_path = self.output_dir / "benchmark_summary.txt"
    #         with open(summary_path, 'w') as f:
                f.write('\n'.join(summary))

            self.logger.info(f"Summary saved to: {summary_path}")

    #     def cleanup(self):
    #         """Clean up benchmark environment."""
            self.logger.info("Cleaning up benchmark environment...")

    #         # Stop memory tracing
            tracemalloc.stop()

    #         # Clean up database
    #         if self.db and self.db_path.exists():
    #             try:
                    self.db.close()
                    self.db_path.unlink()
    #             except Exception as e:
                    self.logger.warning(f"Failed to clean up database: {e}")

    #         # Clean up test files
    test_files = [
    #             "benchmark_suite.log",
    #             "test_benchmark.db"
    #         ]

    #         for file in test_files:
    file_path = Path(file)
    #             if file_path.exists():
    #                 try:
                        file_path.unlink()
    #                 except Exception as e:
                        self.logger.warning(f"Failed to clean up {file}: {e}")

            self.logger.info("Cleanup complete")

    #     def run_full_benchmark(self):
    #         """Run complete benchmark suite."""
            self.logger.info("Starting full benchmark suite...")
    self.start_time = datetime.now()

    #         try:
    #             # Setup environment
                self.setup_environment()

    #             # Run benchmarks
                self.run_matrix_operations_benchmark()
                self.run_runtime_performance_benchmark()
                self.run_database_operations_benchmark()
                self.run_memory_usage_analysis()

    #             # Generate reports
                self.generate_reports()

    #         except Exception as e:
                self.logger.error(f"Benchmark failed: {e}")
    #             raise

    #         finally:
    self.end_time = datetime.now()
                self.cleanup()

    #             # Print final summary
    total_duration = (self.end_time - self.start_time.total_seconds())
                self.logger.info(f"Benchmark suite completed in {total_duration:.2f} seconds")
                self.logger.info(f"Results saved to: {self.output_dir}")

function main()
    #     """Main benchmark execution."""
    parser = argparse.ArgumentParser(description='Noodle Performance Benchmark Suite')
    parser.add_argument('--output', type = str, default='benchmark_results',
    #                        help='Output directory for benchmark results')
    parser.add_argument('--matrix-sizes', type = str, default='small,medium,large,xlarge',
    help = 'Comma-separated list of matrix sizes to test')
    parser.add_argument('--iterations', type = int, default=10,
    #                        help='Number of iterations for each benchmark')
    parser.add_argument('--verbose', action = 'store_true',
    help = 'Enable verbose logging')

    args = parser.parse_args()

    #     # Set up logging level
    #     if args.verbose:
            logging.getLogger().setLevel(logging.DEBUG)

    #     # Create benchmark suite
    output_dir = Path(args.output)
    benchmark = BenchmarkSuite(output_dir)

    #     # Run benchmarks
        benchmark.run_full_benchmark()

if __name__ == "__main__"
        main()
