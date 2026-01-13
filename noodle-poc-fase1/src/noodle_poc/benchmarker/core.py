"""
Benchmarking system for comparing staged execution against native PyTorch.
Provides detailed performance analysis and bottleneck identification.
"""

from dataclasses import dataclass, field
from typing import Dict, List, Optional, Any, Tuple
import torch
import time
from pathlib import Path
import json

from ..simulator.core import StagedSimulator, ExecutionTrace


@dataclass
class BenchmarkResults:
    """Results from execution benchmarking."""
    
    # Timing data
    native_latency_ms: float = 0.0
    staged_latency_ms: float = 0.0
    overhead_ms: float = 0.0
    overhead_pct: float = 0.0
    
    # Breakdown
    stage_breakdown: Dict[str, float] = field(default_factory=dict)
    transfer_breakdown: List[Dict[str, Any]] = field(default_factory=list)
    
    # Performance metrics
    pipeline_throughput_rps: float = 0.0
    native_throughput_rps: float = 0.0
    speedup_factor: float = 0.0
    
    # Resource utilization
    resource_utilization: Dict[str, Dict[str, float]] = field(default_factory=dict)
    
    # Bottleneck analysis
    bottleneck_stage: Optional[str] = None
    bottleneck_latency_ms: float = 0.0
    
    def is_staged_faster(self, threshold: float = 0.0) -> bool:
        """Check if staged execution is faster than native."""
        return (self.native_latency_ms - self.staged_latency_ms) > threshold
    
    def get_summary(self) -> str:
        """Generate summary string."""
        lines = [
            "=" * 70,
            "BENCHMARK RESULTS SUMMARY",
            "=" * 70,
            f"Native Latency:     {self.native_latency_ms:.2f} ms",
            f"Staged Latency:     {self.staged_latency_ms:.2f} ms",
            f"Overhead:           {self.overhead_ms:.2f} ms ({self.overhead_pct:.1f}%)",
            "",
            f"Native Throughput:  {self.native_throughput_rps:.2f} req/s",
            f"Staged Throughput:  {self.pipeline_throughput_rps:.2f} req/s",
            f"Speedup Factor:     {self.speedup_factor:.2f}x",
            "",
        ]
        
        if self.bottleneck_stage:
            lines.extend([
                "BOTTLENECK ANALYSIS",
                "-" * 70,
                f"Bottleneck Stage:  {self.bottleneck_stage}",
                f"Bottleneck Latency: {self.bottleneck_latency_ms:.2f} ms",
                "",
            ])
        
        lines.append("=" * 70)
        return "\n".join(lines)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for JSON serialization."""
        return {
            'timing': {
                'native_latency_ms': self.native_latency_ms,
                'staged_latency_ms': self.staged_latency_ms,
                'overhead_ms': self.overhead_ms,
                'overhead_pct': self.overhead_pct,
            },
            'performance': {
                'native_throughput_rps': self.native_throughput_rps,
                'pipeline_throughput_rps': self.pipeline_throughput_rps,
                'speedup_factor': self.speedup_factor,
            },
            'breakdown': {
                'stage_breakdown': self.stage_breakdown,
                'transfer_breakdown': self.transfer_breakdown,
            },
            'resource_utilization': self.resource_utilization,
            'bottleneck': {
                'stage': self.bottleneck_stage,
                'latency_ms': self.bottleneck_latency_ms,
            },
        }
    
    def save(self, output_path: Path):
        """Save results to JSON file."""
        with open(output_path, 'w') as f:
            json.dump(self.to_dict(), f, indent=2)


class ExecutionBenchmarker:
    """
    Comprehensive benchmarker for execution strategies.
    
    Compares:
    - Native PyTorch execution
    - Staged execution simulation
    - Multiple partition plans
    """
    
    def __init__(self, num_warmup_runs: int = 5, num_benchmark_runs: int = 20):
        """
        Initialize benchmarker.
        
        Args:
            num_warmup_runs: Number of warmup runs before measurement
            num_benchmark_runs: Number of benchmark runs for averaging
        """
        self.num_warmup_runs = num_warmup_runs
        self.num_benchmark_runs = num_benchmark_runs
        self.results_history: List[BenchmarkResults] = []
    
    def benchmark(
        self,
        model,
        inputs: Dict[str, torch.Tensor],
        simulator: StagedSimulator,
        batch_size: int = 1
    ) -> BenchmarkResults:
        """
        Run complete benchmark comparing native vs staged execution.
        
        Args:
            model: PyTorch model
            inputs: Input tensors
            simulator: StagedSimulator instance
            batch_size: Batch size for throughput calculation
            
        Returns:
            BenchmarkResults with comprehensive comparison
        """
        # Warmup runs
        self._warmup(model, inputs)
        
        # Native PyTorch benchmark
        native_times = []
        for _ in range(self.num_benchmark_runs):
            native_time = self._benchmark_native(model, inputs)
            native_times.append(native_time)
        
        avg_native_time = sum(native_times) / len(native_times)
        
        # Staged execution benchmark
        staged_times = []
        all_traces = []
        
        for _ in range(self.num_benchmark_runs):
            # Need to reset model to avoid side effects
            staged_time, trace = self._benchmark_staged(simulator, model, inputs)
            staged_times.append(staged_time)
            if trace:
                all_traces.append(trace)
        
        avg_staged_time = sum(staged_times) / len(staged_times)
        
        # Calculate overhead
        overhead = avg_staged_time - avg_native_time
        overhead_pct = (overhead / avg_native_time) * 100 if avg_native_time > 0 else 0.0
        
        # Extract detailed breakdown from traces
        if all_traces:
            stage_breakdown = self._aggregate_stage_timings(all_traces)
            transfer_breakdown = self._aggregate_transfer_timings(all_traces)
            resource_utilization = self._aggregate_resource_utilization(all_traces)
            
            # Find bottleneck
            bottleneck_stage = max(stage_breakdown.items(), key=lambda x: x[1])[0]
            bottleneck_latency = stage_breakdown[bottleneck_stage]
        else:
            stage_breakdown = {}
            transfer_breakdown = []
            resource_utilization = {}
            bottleneck_stage = None
            bottleneck_latency = 0.0
        
        # Calculate throughput
        native_throughput = (1000 / avg_native_time) * batch_size if avg_native_time > 0 else 0
        staged_throughput = (1000 / bottleneck_latency) * batch_size if bottleneck_latency > 0 else 0
        speedup = native_throughput / staged_throughput if staged_throughput > 0 else 0
        
        # Create results
        results = BenchmarkResults(
            native_latency_ms=avg_native_time,
            staged_latency_ms=avg_staged_time,
            overhead_ms=overhead,
            overhead_pct=overhead_pct,
            stage_breakdown=stage_breakdown,
            transfer_breakdown=transfer_breakdown,
            pipeline_throughput_rps=staged_throughput,
            native_throughput_rps=native_throughput,
            speedup_factor=speedup,
            resource_utilization=resource_utilization,
            bottleneck_stage=bottleneck_stage,
            bottleneck_latency_ms=bottleneck_latency,
        )
        
        self.results_history.append(results)
        return results
    
    def _warmup(self, model, inputs: Dict[str, torch.Tensor]):
        """Perform warmup runs."""
        model.eval()
        with torch.no_grad():
            for _ in range(self.num_warmup_runs):
                _ = model(**inputs)
                
                if torch.cuda.is_available():
                    torch.cuda.synchronize()
    
    def _benchmark_native(self, model, inputs: Dict[str, torch.Tensor]) -> float:
        """Benchmark native PyTorch execution."""
        model.eval()
        
        if torch.cuda.is_available():
            torch.cuda.synchronize()
            start = torch.cuda.Event(enable_timing=True)
            end = torch.cuda.Event(enable_timing=True)
            
            start.record()
            with torch.no_grad():
                _ = model(**inputs)
            end.record()
            
            torch.cuda.synchronize()
            elapsed_time_ms = start.elapsed_time(end)
        else:
            start_time = time.time()
            with torch.no_grad():
                _ = model(**inputs)
            elapsed_time_ms = (time.time() - start_time) * 1000
        
        return elapsed_time_ms
    
    def _benchmark_staged(
        self,
        simulator: StagedSimulator,
        model,
        inputs: Dict[str, torch.Tensor]
    ) -> Tuple[float, Optional[ExecutionTrace]]:
        """Benchmark staged execution."""
        # Reset profiling
        simulator.trace = ExecutionTrace()
        
        # Run simulation
        output, trace = simulator.simulate(model, inputs)
        
        # Calculate total latency from trace
        total_latency = trace.get_total_latency() if trace else 0.0
        
        return total_latency, trace
    
    def _aggregate_stage_timings(self, traces: List[ExecutionTrace]) -> Dict[str, float]:
        """Aggregate stage timings across multiple runs."""
        all_timings = {}
        
        for trace in traces:
            timings = trace.get_stage_timings()
            
            for stage_id, timing in timings.items():
                if stage_id not in all_timings:
                    all_timings[stage_id] = []
                
                all_timings[stage_id].append(timing)
        
        # Average timings
        return {
            stage_id: sum(times) / len(times)
            for stage_id, times in all_timings.items()
        }
    
    def _aggregate_transfer_timings(self, traces: List[ExecutionTrace]) -> List[Dict[str, Any]]:
        """Aggregate transfer timings across runs."""
        transfers = []
        
        for trace in traces:
            transfer_timings = trace.get_transfer_timings()
            transfers.extend(transfer_timings)
        
        # Average transfers between same stages
        aggregated = {}
        for tf in transfers:
            key = (tf['from'], tf['to'])
            
            if key not in aggregated:
                aggregated[key] = {
                    'from': tf['from'],
                    'to': tf['to'],
                    'durations': [],
                    'sizes': [],
                }
            
            aggregated[key]['durations'].append(tf['duration_ms'])
            aggregated[key]['sizes'].append(tf.get('size_mb', 0))
        
        return [
            {
                'from': data['from'],
                'to': data['to'],
                'avg_duration_ms': sum(data['durations']) / len(data['durations']),
                'avg_size_mb': sum(data['sizes']) / len(data['sizes']) if data['sizes'] else 0,
                'count': len(data['durations']),
            }
            for data in aggregated.values()
        ]
    
    def _aggregate_resource_utilization(self, traces: List[ExecutionTrace]) -> Dict[str, Dict[str, float]]:
        """Aggregate resource utilization across runs."""
        # Simplified - in real implementation, would aggregate all node utilizations
        # For now, return utilization from first trace
        if traces and hasattr(traces[0], 'simulator'):
            return traces[0].simulator.get_resource_utilization()
        return {}
    
    def compare_plans(
        self,
        model,
        inputs: Dict[str, torch.Tensor],
        simulators: Dict[str, StagedSimulator]
    ) -> Dict[str, BenchmarkResults]:
        """
        Compare multiple partition plans.
        
        Args:
            model: PyTorch model
            inputs: Input tensors  
            simulators: Dictionary of plan_name -> StagedSimulator
            
        Returns:
            Dictionary of results for each plan
        """
        results = {}
        
        for plan_name, simulator in simulators.items():
            print(f"Benchmarking plan: {plan_name}")
            results[plan_name] = self.benchmark(model, inputs, simulator)
        
        return results
    
    def find_optimal_plan(
        self,
        plan_results: Dict[str, BenchmarkResults]
    ) -> Tuple[str, BenchmarkResults]:
        """
        Find the optimal partition plan.
        
        Args:
            plan_results: Dictionary of plan_name -> results
            
        Returns:
            (optimal_plan_name, optimal_results) tuple
        """
        # Optimize for highest throughput (could be adjusted)
        optimal_plan = max(
            plan_results.items(),
            key=lambda x: x[1].pipeline_throughput_rps
        )
        
        return optimal_plan
    
    def generate_comparison_report(
        self,
        plan_results: Dict[str, BenchmarkResults],
        output_path: Optional[Path] = None
    ) -> str:
        """
        Generate comparison report for multiple plans.
        
        Args:
            plan_results: Results for each plan
            output_path: Optional file path to save report
            
        Returns:
            Report as string
        """
        lines = [
            "=" * 80,
            "PARTITION PLAN COMPARISON REPORT",
            "=" * 80,
            ""
        ]
        
        # Table header
        lines.append(f"{'Plan Name':<20} {'Latency (ms)':<15} {'Throughput':<15} {'Speedup':<12}")
        lines.append("-" * 80)
        
        # Results for each plan
        for plan_name, results in plan_results.items():
            lines.append(
                f"{plan_name:<20} "
                f"{results.staged_latency_ms:<15.2f} "
                f"{results.pipeline_throughput_rps:<15.2f} "
                f"{results.speedup_factor:<12.2f}"
            )
        
        # Find optimal
        optimal_name, optimal_results = self.find_optimal_plan(plan_results)
        
        lines.append("")
        lines.append("=" * 80)
        lines.append(f"OPTIMAL PLAN: {optimal_name}")
        lines.append("=" * 80)
        lines.append(optimal_results.get_summary())
        
        report = "\n".join(lines)
        
        if output_path:
            with open(output_path, 'w') as f:
                f.write(report)
        
        return report
