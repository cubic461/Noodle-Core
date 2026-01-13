"""
Adaptive planner with runtime monitoring and dynamic partitioning.
Uses real-time metrics to update execution plans on-the-fly.
"""

import logging
from typing import Dict, List, Optional, Tuple, Any
from dataclasses import dataclass, field
from datetime import datetime, timedelta
import json
from pathlib import Path
import pandas as pd

from ...planner.core import ExecutionPlanner, PartitionPlan
from ...capability_matcher import HardwareCapability, LayerRequirements, CapabilityMatcher


@dataclass
class RuntimeMetrics:
    """Runtime performance metrics for adaptive planning."""

    # Layer-level metrics
    layer_name: str
    actual_latency_ms: float = 0.0  # Measured actual latency
    expected_latency_ms: float = 0.0  # Expected from planning
    actual_memory_mb: float = 0.0  # Measured peak memory
    expected_memory_mb: float = 0.0  # Expected memory

    # Network metrics
    transfer_latency_ms: float = 0.0  # Data transfer time
    transfer_size_mb: float = 0.0  # Amount of data transferred

    # Quality metrics
    accuracy_drift: float = 0.0  # Output accuracy drift (if measurable)
    variance: float = 0.0  # Latency variance across runs

    # Timestamp
    timestamp: datetime = field(default_factory=datetime.now)

    # Derived metrics
    @property
    def latency_delta_ms(self) -> float:
        """Difference between actual and expected latency."""
        return self.actual_latency_ms - self.expected_latency_ms

    @property
    def latency_error_pct(self) -> float:
        """Percentage error in latency estimation."""
        if self.expected_latency_ms == 0:
            return 0.0
        return (self.latency_delta_ms / self.expected_latency_ms) * 100.0


@dataclass
class AdaptationTrigger:
    """Conditions that trigger plan adaptation."""

    # Latency triggers
    latency_error_threshold_pct: float = 15.0  # 15% error threshold
    latency_imbalance_threshold_ms: float = 100.0  # 100ms imbalance

    # Memory triggers
    memory_error_threshold_pct: float = 20.0  # 20% memory error

    # Frequency controls
    min_adaptation_interval_sec: float = 60.0  # Minimum 1 minute between adaptations
    max_adaptations_per_hour: int = 10  # Max 10 adaptations per hour

    def should_adapt(
        self,
        metrics: List[RuntimeMetrics],
        current_plan: PartitionPlan,
        last_adaptation_time: Optional[datetime]
    ) -> Tuple[bool, str]:
        """
        Determine if adaptation should be triggered.

        Returns:
            (should_adapt, reason)
        """
        if not metrics:
            return False, "No metrics available"

        # Check adaptation frequency
        if last_adaptation_time:
            time_since_last = (datetime.now() - last_adaptation_time).total_seconds()
            if time_since_last < self.min_adaptation_interval_sec:
                return False, f"Too soon since last adaptation ({time_since_last:.1f}s < {self.min_adaptation_interval_sec}s)"

        # Check latency errors
        high_error_layers = [
            m for m in metrics
            if abs(m.latency_error_pct) > self.latency_error_threshold_pct
        ]

        if high_error_layers:
            return True, f"High latency errors: {len(high_error_layers)} layers exceed {self.latency_error_threshold_pct}% threshold"

        # Check latency imbalance across stages
        stage_latencies = current_plan.get_stage_latencies()
        if len(stage_latencies) > 1:
            max_latency = max(stage_latencies.values())
            min_latency = min(stage_latencies.values())
            imbalance = max_latency - min_latency

            if imbalance > self.latency_imbalance_threshold_ms:
                return True, f"Stage imbalance: {imbalance:.1f}ms exceeds threshold"

        # Check memory usage errors
        memory_errors = [
            m for m in metrics
            if abs(m.actual_memory_mb - m.expected_memory_mb) / max(m.expected_memory_mb, 1.0) > self.memory_error_threshold_pct / 100.0
        ]

        if memory_errors:
            return True, f"Memory usage errors: {len(memory_errors)} layers exceed threshold"

        # No trigger
        return False, "No adaptation needed"


class AdaptivePlanner(ExecutionPlanner):
    """
    Adaptive execution planner that updates partitions based on runtime metrics.

    Extends the base ExecutionPlanner with:
    - Runtime monitoring and metrics collection
    - Automatic plan adaptation
    - Dynamic hardware capability matching
    - Performance optimization feedback loop
    """

    def __init__(self, metrics_data=None, capability_matcher=None):
        """
        Initialize adaptive planner with metrics data.

        Args:
            metrics_data: Path to Fase 1 metrics JSONL file OR DataFrame
            capability_matcher: Hardware capability matcher
        """
        # Handle both DataFrame and Path/str objects properly
        if metrics_data is None:
            # Create empty DataFrame
            metrics_df = pd.DataFrame()
        elif isinstance(metrics_data, pd.DataFrame):
            # Already a DataFrame
            metrics_df = metrics_data
        elif isinstance(metrics_data, (str, Path)):
            # Load from JSONL file via parent class method
            from ...planner.core import ExecutionPlanner
            temp_planner_obj = ExecutionPlanner.from_jsonl(Path(metrics_data))
            metrics_df = temp_planner_obj.metrics
        else:
            raise ValueError(f"Unsupported metrics_data type: {type(metrics_data)}")

        # Initialize parent class with DataFrame
        super().__init__(metrics_df)

        self.capability_matcher = capability_matcher or CapabilityMatcher()
        self.adaptation_trigger = AdaptationTrigger()

        # Runtime state
        self.runtime_metrics: List[RuntimeMetrics] = []
        self.current_plan: Optional[PartitionPlan] = None
        self.plan_history: List[Tuple[datetime, PartitionPlan, Dict[str, Any]]] = []
        self.last_adaptation: Optional[datetime] = None
        self.adaptation_count = 0

        self.logger = logging.getLogger("AdaptivePlanner")

    def update_with_runtime_metrics(self, metrics: RuntimeMetrics):
        """Update planner with runtime measurements."""
        self.runtime_metrics.append(metrics)

        # Keep only recent metrics (last hour)
        cutoff_time = datetime.now() - timedelta(hours=1)
        self.runtime_metrics = [
            m for m in self.runtime_metrics
            if m.timestamp > cutoff_time
        ]

    def evaluate_current_plan(self) -> Dict[str, Any]:
        """Evaluate current plan against runtime metrics."""
        if not self.current_plan:
            return {"error": "No current plan"}

        evaluation = {
            "plan_id": id(self.current_plan),
            "evaluation_time": datetime.now().isoformat(),
            "num_metrics": len(self.runtime_metrics),
            "stage_evaluation": {},
            "recommendations": [],
        }

        # Evaluate each stage
        for stage_id, layer_names in self.current_plan.stages.items():
            stage_metrics = [
                m for m in self.runtime_metrics
                if any(m.layer_name.startswith(layer) for layer in layer_names)
            ]

            if not stage_metrics:
                continue

            # Calculate stage performance
            expected_total = sum(m.expected_latency_ms for m in stage_metrics)
            actual_total = sum(m.actual_latency_ms for m in stage_metrics)
            error_pct = ((actual_total - expected_total) / expected_total * 100.0) if expected_total > 0 else 0.0

            evaluation["stage_evaluation"][stage_id] = {
                "num_layers": len(stage_metrics),
                "expected_latency_ms": expected_total,
                "actual_latency_ms": actual_total,
                "error_pct": error_pct,
                "avg_variance": sum(m.variance for m in stage_metrics) / len(stage_metrics),
            }

            # Generate recommendations
            if abs(error_pct) > self.adaptation_trigger.latency_error_threshold_pct:
                evaluation["recommendations"].append(
                    f"Stage {stage_id}: High latency error ({error_pct:.1f}%)"
                )

        # Check for stage imbalance
        if len(evaluation["stage_evaluation"]) > 1:
            latencies = [s["actual_latency_ms"] for s in evaluation["stage_evaluation"].values()]
            imbalance = max(latencies) - min(latencies)

            if imbalance > self.adaptation_trigger.latency_imbalance_threshold_ms:
                evaluation["recommendations"].append(
                    f"Stage imbalance detected: {imbalance:.1f}ms difference"
                )

        return evaluation

    def should_adapt_plan(self) -> Tuple[bool, str, Dict[str, Any]]:
        """Determine if plan should be adapted."""
        if not self.current_plan or not self.runtime_metrics:
            return False, "No plan or metrics available", {}

        evaluation = self.evaluate_current_plan()
        should_adapt, reason = self.adaptation_trigger.should_adapt(
            self.runtime_metrics,
            self.current_plan,
            self.last_adaptation
        )

        return should_adapt, reason, evaluation

    def adapt_plan(self, new_constraints: Optional[Dict[str, Any]] = None) -> PartitionPlan:
        """Create new adapted plan based on runtime metrics."""
        self.logger.info("Adapting execution plan based on runtime metrics")

        # Determine if adaptation is needed
        should_adapt, reason, evaluation = self.should_adapt_plan()

        if not should_adapt:
            self.logger.info(f"No adaptation needed: {reason}")
            return self.current_plan

        self.logger.info(f"Adaptation triggered: {reason}")

        # Store current plan in history
        self.plan_history.append((
            datetime.now(),
            self.current_plan,
            evaluation
        ))

        # Update constraints based on runtime observations
        effective_constraints = new_constraints or {}

        # If latency errors are high, adjust expected latencies
        if self.runtime_metrics:
            avg_error = sum(m.latency_error_pct for m in self.runtime_metrics) / len(self.runtime_metrics)

            # Adjust balance threshold if observing systematic errors
            if abs(avg_error) > 10.0:
                current_threshold = effective_constraints.get('latency_balance_threshold', 0.3)
                effective_constraints['latency_balance_threshold'] = min(current_threshold * 1.5, 1.0)

        # Adjust number of stages if memory errors are common
        memory_errors = sum(
            1 for m in self.runtime_metrics
            if abs(m.actual_memory_mb - m.expected_memory_mb) > m.expected_memory_mb * 0.2
        )

        if memory_errors > len(self.runtime_metrics) * 0.3:  # 30%+ memory errors
            effective_constraints['max_memory_per_stage_mb'] = effective_constraints.get(
                'max_memory_per_stage_mb',
                8000
            ) * 0.85  # Reduce memory per stage

        # Create new plan with updated constraints
        new_plan = self.create_plan(effective_constraints)

        # Compare with old plan
        if self.current_plan:
            self.logger.info(f"Plan comparison:")

        # Update state
        self.current_plan = new_plan
        self.last_adaptation = datetime.now()
        self.adaptation_count += 1
        self.runtime_metrics.clear()  # Reset for next evaluation period

        self.logger.info(f"Plan adapted (count: {self.adaptation_count})")
        return new_plan

    def create_heterogeneous_plan(
        self,
        hardware_capabilities: Dict[str, HardwareCapability],
        strategy: str = "balanced"
    ) -> PartitionPlan:
        """Create partition plan optimized for heterogeneous hardware."""
        self.logger.info(f"Creating heterogeneous plan with {len(hardware_capabilities)} devices")

        # Register all hardware capabilities
        for device_id, cap in hardware_capabilities.items():
            self.capability_matcher.register_device(cap)

        # Create layer requirements from metrics
        layer_requirements = []
        # Fix: Use the correct attribute name (self.metrics not self.layer_metrics)
        for _, row in self.metrics.iterrows():
            layer_name = row["layer_name"]
            layer_type = row.get("layer_type", "unknown")
            req = LayerRequirements(
                layer_name=layer_name,
                layer_type=layer_type,
                memory_gb=row.get("parameter_size_mb", 100) / 1024,  # Convert MB to GB
                compute_millions=row.get("forward_latency_ms", 10.0) * 100.0,  # Estimate compute
                is_latency_sensitive=row.get("forward_latency_ms", 0) > 100.0,
            )
            layer_requirements.append(req)

        # Find optimal device assignment
        placement = {}
        for req in layer_requirements:
            device_id, score = self.capability_matcher.find_optimal_device(req, strategy=strategy)

            if device_id:
                placement[req.layer_name] = device_id
                self.logger.debug(f"Assigned {req.layer_name} -> {device_id} (score: {score:.2f})")
            else:
                self.logger.warning(f"No suitable device found for {req.layer_name}")
                placement[req.layer_name] = list(hardware_capabilities.keys())[0]  # Fallback

        # Create plan
        constraints = {
            'num_stages': min(len(hardware_capabilities), 5),
            'max_memory_per_stage_mb': min(cap.memory_gb * 1024 for cap in hardware_capabilities.values()),
        }

        plan = self.create_plan(constraints)
        plan.stage_metadata['plan_type'] = 'heterogeneous'
        plan.stage_metadata['hardware_assignment'] = placement
        plan.stage_metadata['strategy'] = strategy

        return plan

    def get_adaptation_history(self) -> List[Dict[str, Any]]:
        """Get history of all plan adaptations."""
        history = []

        for timestamp, plan, evaluation in self.plan_history:
            history.append({
                'timestamp': timestamp.isoformat(),
                'plan_id': id(plan),
                'evaluation': evaluation,
                'stage_count': len(plan.stages),
                # 'total_latency_ms': plan.total_latency_estimate(),  # Commented - method may not exist
            })

        return history

    def export_adaptation_report(self, output_path: Path):
        """Export complete adaptation report."""
        report = {
            'created_at': datetime.now().isoformat(),
            'plan_history': self.get_adaptation_history(),
            'total_adaptations': self.adaptation_count,
            'current_plan': self.current_plan.to_dict() if self.current_plan else None,
            'capability_summary': self.capability_matcher.get_device_summary(),
        }

        with open(output_path, 'w') as f:
            json.dump(report, f, indent=2)

        self.logger.info(f"Adaptation report exported: {output_path}")
