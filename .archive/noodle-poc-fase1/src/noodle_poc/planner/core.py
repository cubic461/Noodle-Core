"""
Core Execution Planner implementation.
Analyzes observability metrics and generates optimal partition plans.
"""

from dataclasses import dataclass, field
from typing import Dict, List, Optional, Any
from pathlib import Path
import pandas as pd
import json

from ..planner.optimizer import PartitionOptimizer


@dataclass
class PartitionPlan:
    """Defines how a model is partitioned across multiple stages/nodes."""

    stages: Dict[str, List[str]] = field(default_factory=dict)
    stage_metadata: Dict[str, Dict[str, Any]] = field(default_factory=dict)

    def add_stage(self, stage_id: str, layers: List[str], metadata: Optional[Dict[str, Any]] = None):
        """Add a stage to the partition plan."""
        self.stages[stage_id] = layers
        if metadata:
            self.stage_metadata[stage_id] = metadata

    def get_stage_layers(self, stage_id: str) -> List[str]:
        """Get all layer names for a specific stage."""
        return self.stages.get(stage_id, [])

    def get_metadata(self, stage_id: str) -> Dict[str, Any]:
        """Get metadata for a specific stage."""
        return self.stage_metadata.get(stage_id, {})

    def total_stages(self) -> int:
        """Get total number of stages."""
        return len(self.stages)

    def all_layers(self) -> List[str]:
        """Get all layers across all stages."""
        return [layer for layers in self.stages.values() for layer in layers]

    def to_dict(self) -> Dict[str, Any]:
        """Convert plan to dictionary for serialization."""
        return {
            'stages': self.stages,
            'metadata': self.stage_metadata,
            'total_stages': self.total_stages(),
        }


class ExecutionPlanner:
    """
    Execution Planner using real observability metrics to generate partition plans.

    Uses PartitionOptimizer with advanced heuristics to balance:
    - Latency distribution
    - Memory constraints
    - Network transfer overhead
    - Node capabilities
    """

    def __init__(self, metrics_data: pd.DataFrame):
        """
        Initialize planner with observability metrics.

        Args:
            metrics_data: DataFrame with layer metrics (latency, memory, etc.)
        """
        self.metrics = metrics_data
        self.optimizer = PartitionOptimizer(metrics_data)
        self.plans: List[PartitionPlan] = []

    @classmethod
    def from_observability_engine(cls, engine) -> 'ExecutionPlanner':
        """
        Create planner from existing ObservabilityEngine.

        Args:
            engine: ObservabilityEngine instance with profiling data

        Returns:
            ExecutionPlanner instance
        """
        # Export metrics to DataFrame
        metrics_data = []

        for layer_name, runs in engine.metrics_collector.metrics_history.items():
            if not runs:
                continue

            latest_run = runs[-1]
            metrics_data.append({
                'layer_name': layer_name,
                'layer_type': latest_run.layer_type,
                'forward_latency_ms': latest_run.forward_latency_ms,
                'p95_latency_ms': latest_run.p95_latency_ms,
                'peak_vram_after': latest_run.peak_vram_after,
                'vram_increase': latest_run.vram_increase,
                'num_parameters': latest_run.num_parameters,
                'parameter_size_mb': latest_run.parameter_size_mb,
            })

        return cls(pd.DataFrame(metrics_data))

    @classmethod
    def from_jsonl(cls, metrics_file: Path) -> 'ExecutionPlanner':
        """
        Load planner from Fase 1 JSONL metrics file.

        Args:
            metrics_file: Path to metrics JSONL file

        Returns:
            ExecutionPlanner instance
        """
        if not metrics_file.exists():
            raise FileNotFoundError(f"Metrics file not found: {metrics_file}")

        # Read JSONL manually for compatibility
        data = []
        try:
            with open(metrics_file, 'r') as f:
                for line in f:
                    if line.strip():
                        data.append(json.loads(line))
        except Exception as e:
            raise ValueError(f"Error reading metrics file: {e}") from e

        # Convert to DataFrame
        df = pd.DataFrame(data)

        # Calculate summary stats per layer
        layer_summary = df.groupby('layer_name').agg({
            'forward_latency_ms': 'mean',
            'p95_latency_ms': 'mean',
            'peak_vram_after': 'max',
            'num_parameters': 'first',
            'parameter_size_mb': 'first',
        }).reset_index()

        return cls(layer_summary)

    def create_plan(self, constraints: Optional[Dict[str, Any]] = None) -> PartitionPlan:
        """
        Create an optimized partition plan based on metrics and constraints.

        Args:
            constraints: Optional constraints dictionary:
                - num_stages: Number of stages (default: 3)
                - max_memory_per_stage_mb: Max memory per stage (default: 8000)
                - min_layers_per_stage: Min layers per stage (default: 1)
                - target_stages: Specific number of stages to create
                - latency_balance_threshold: Max variance in stage latency (default: 0.3)

        Returns:
            PartitionPlan with optimized stage assignments
        """
        constraints = constraints or {}

        # Extract constraints
        num_stages = constraints.get('num_stages', 3)
        max_memory_mb = constraints.get('max_memory_per_stage_mb', 8000)
        balance_threshold = constraints.get('latency_balance_threshold', 0.3)

        # Step 1: Filter layers by memory constraint
        valid_layers = self.metrics[
            (self.metrics['parameter_size_mb'] <= max_memory_mb) |
            (self.metrics['parameter_size_mb'].isna())
        ]

        # Step 2: Group layers using optimizer
        stage_assignments = self.optimizer.optimize(
            valid_layers,
            num_stages=num_stages,
            balance_threshold=balance_threshold
        )

        # Step 3: Create partition plan
        plan = PartitionPlan()

        for stage_id, layers in stage_assignments.items():
            if not layers:
                continue

            # Calculate stage metadata
            stage_metrics = self.metrics[self.metrics['layer_name'].isin(layers)]

            # Aggregate metadata
            metadata = {
                'total_layers': len(layers),
                'total_latency_ms': stage_metrics['forward_latency_ms'].sum(),
                'avg_latency_ms': stage_metrics['forward_latency_ms'].mean(),
                'total_memory_mb': stage_metrics['peak_vram_after'].max() / (1024**2),
                'parameters': stage_metrics['num_parameters'].sum(),
            }

            plan.add_stage(stage_id, layers, metadata)

        self.plans.append(plan)
        return plan

    def compare_plans(self, plans: List[PartitionPlan]) -> Dict[str, Any]:
        """
        Compare multiple partition plans to find optimal one.

        Args:
            plans: List of PartitionPlan instances

        Returns:
            Dictionary with comparison metrics
        """
        comparisons = []

        for plan in plans:
            stage_latencies = [
                plan.get_metadata(sid).get('total_latency_ms', 0)
                for sid in plan.stages.keys()
            ]

            if not stage_latencies:
                continue

            comparisons.append({
                'plan': plan,
                'max_stage_latency': max(stage_latencies),
                'avg_stage_latency': sum(stage_latencies) / len(stage_latencies),
                'total_latency': sum(stage_latencies),
                'latency_variance': self._calculate_variance(stage_latencies),
            })

        # Find optimal plan (minimum bottleneck latency)
        optimal = min(comparisons, key=lambda x: x['max_stage_latency'])

        return {
            'comparisons': comparisons,
            'optimal_plan': optimal['plan'],
            'optimal_metrics': {
                'bottleneck_latency_ms': optimal['max_stage_latency'],
                'avg_latency_ms': optimal['avg_stage_latency'],
                'latency_variance': optimal['latency_variance'],
            }
        }

    def _calculate_variance(self, values: List[float]) -> float:
        """Calculate variance of a list of values."""
        if len(values) <= 1:
            return 0.0

        mean = sum(values) / len(values)
        variance = sum((x - mean) ** 2 for x in values) / len(values)
        return variance

    def generate_report(self, plan: PartitionPlan, output_file: Optional[Path] = None) -> str:
        """
        Generate human-readable report for a partition plan.

        Args:
            plan: PartitionPlan instance
            output_file: Optional file path to save report

        Returns:
            Report as string
        """
        report_lines = []

        report_lines.append("=" * 70)
        report_lines.append("NOODLE PARTITION PLAN REPORT")
        report_lines.append("=" * 70)
        report_lines.append(f"Total Stages: {plan.total_stages()}")
        report_lines.append(f"Total Layers: {len(plan.all_layers())}")
        report_lines.append("")

        for stage_id in sorted(plan.stages.keys()):
            layers = plan.get_stage_layers(stage_id)
            metadata = plan.get_metadata(stage_id)

            report_lines.append(f"Stage: {stage_id}")
            report_lines.append("-" * 70)
            report_lines.append(f"  Layers: {metadata['total_layers']}")
            report_lines.append(f"  Total Latency: {metadata['total_latency_ms']:.2f} ms")
            report_lines.append(f"  Avg Latency: {metadata['avg_latency_ms']:.2f} ms")
            report_lines.append(f"  Memory: {metadata['total_memory_mb']:.2f} MB")
            report_lines.append(f"  Parameters: {metadata['parameters']:,}")

            # Show first few layer names
            show_layers = layers[:5] if len(layers) > 5 else layers
            report_lines.append(f"  Layer Names: {', '.join(show_layers)}")
            if len(layers) > 5:
                report_lines.append(f"  ... and {len(layers) - 5} more")

            report_lines.append("")

        # Summary statistics
        stage_latencies = [
            plan.get_metadata(sid)['total_latency_ms']
            for sid in plan.stages.keys()
        ]

        report_lines.append("=" * 70)
        report_lines.append("SUMMARY")
        report_lines.append("=" * 70)
        report_lines.append(f"Bottleneck Stage: {max(stage_latencies):.2f} ms")
        report_lines.append(f"Pipeline Throughput: {1.0 / (max(stage_latencies) / 1000):.2f} req/s")
        report_lines.append("=" * 70)

        report = "\n".join(report_lines)

        if output_file:
            with open(output_file, 'w') as f:
                f.write(report)

        return report
