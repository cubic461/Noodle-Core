#!/usr/bin/env python3
"""
Fase 2 Complete Integration Test

Tests the entire Fase 2 pipeline:
1. Load Fase 1 metrics
2. Create virtual nodes
3. Generate plans with all strategies
4. Compare and validate results
"""

import pytest
import json
import tempfile
from pathlib import Path

import sys
sys.path.insert(0, str(Path(__file__).parent.parent))

from src.metrics import MetricsCollector, LayerMetrics
from src.planner import ExecutionPlanner, PlanningConstraints, PartitionStrategy
from src.plan import VirtualNode, DeviceType, PartitionPlan


class TestPhase2Planning:
    """Test suite for Fase 2 execution planning."""
    
    @pytest.fixture
    def sample_metrics(self):
        """Create sample layer metrics for testing."""
        collector = MetricsCollector()
        
        # Simulate a small model with 5 layers
        sample_layers = [
            {
                "layer_name": "embeddings",
                "layer_type": "Embedding",
                "forward_latency_ms": 10.0,
                "num_parameters": 1000000,
                "peak_vram_after": 4 * 1024 * 1024,  # 4MB
            },
            {
                "layer_name": "layer_0",
                "layer_type": "TransformerBlock",
                "forward_latency_ms": 50.0,
                "num_parameters": 85000000,
                "peak_vram_after": 800 * 1024 * 1024,  # 800MB
            },
            {
                "layer_name": "layer_1",
                "layer_type": "TransformerBlock",
                "forward_latency_ms": 48.0,
                "num_parameters": 85000000,
                "peak_vram_after": 800 * 1024 * 1024,
            },
            {
                "layer_name": "layer_2",
                "layer_type": "TransformerBlock",
                "forward_latency_ms": 52.0,
                "num_parameters": 85000000,
                "peak_vram_after": 800 * 1024 * 1024,
            },
            {
                "layer_name": "lm_head",
                "layer_type": "Linear",
                "forward_latency_ms": 150.0,  # Bottleneck!
                "num_parameters": 50000000,
                "peak_vram_after": 400 * 1024 * 1024,
            },
        ]
        
        for layer_data in sample_layers:
            metrics = LayerMetrics(
                layer_name=layer_data["layer_name"],
                layer_type=layer_data["layer_type"],
                forward_latency_ms=layer_data["forward_latency_ms"],
                num_parameters=layer_data["num_parameters"],
                peak_vram_after=layer_data["peak_vram_after"],
            )
            collector.metrics_history[layer_data["layer_name"]] = [metrics]
        
        return collector
    
    @pytest.fixture
    def sample_nodes(self):
        """Create sample virtual nodes for testing."""
        return [
            VirtualNode(
                node_id="gpu_0",
                device_type=DeviceType.GPU,
                vram_gb=24.0,
                ram_gb=64.0,
                compute_score=10.0,
            ),
            VirtualNode(
                node_id="cpu_0",
                device_type=DeviceType.CPU,
                ram_gb=32.0,
                compute_score=1.0,
            ),
        ]
    
    def test_load_metrics_from_jsonl(self, tmp_path):
        """Test loading metrics from JSONL file."""
        # Create temporary JSONL file
        jsonl_file = tmp_path / "test_metrics.jsonl"
        
        sample_data = [
            {
                "layer_name": "layer_0",
                "layer_type": "Linear",
                "forward_latency_ms": 50.0,
                "num_parameters": 1000000,
            },
            {
                "layer_name": "layer_1",
                "layer_type": "Linear",
                "forward_latency_ms": 55.0,
                "num_parameters": 1000000,
            },
        ]
        
        # Write JSONL
        with open(jsonl_file, 'w') as f:
            for item in sample_data:
                f.write(json.dumps(item) + '\n')
        
        # Load using utility function
        from examples.simulate_staged import load_metrics_from_jsonl
        collector = load_metrics_from_jsonl(jsonl_file)
        
        # Assertions
        assert len(collector.metrics_history) == 2
        assert "layer_0" in collector.metrics_history
        assert "layer_1" in collector.metrics_history
    
    def test_balanced_planning(self, sample_metrics, sample_nodes):
        """Test balanced partition planning."""
        planner = ExecutionPlanner(sample_metrics, PartitionStrategy.BALANCED)
        plan = planner.generate_plan(sample_nodes, "test_model")
        
        # Assertions
        assert len(plan.stages) > 0
        assert plan.total_expected_latency_ms > 0
        assert plan.load_balance_score >= 0.0
        assert plan.load_balance_score <= 1.0
        assert plan.bottleneck_stage_id is not None
    
    def test_bottleneck_first_planning(self, sample_metrics, sample_nodes):
        """Test bottleneck-first partition planning."""
        planner = ExecutionPlanner(sample_metrics, PartitionStrategy.BOTTLENECK_FIRST)
        plan = planner.generate_plan(sample_nodes, "test_model")
        
        # Assertions
        assert len(plan.stages) > 0
        
        # Bottleneck strategy should identify lm_head as bottleneck
        lm_head_in_fast_node = any(
            "lm_head" in stage.layers and stage.node.device_type == DeviceType.GPU
            for stage in plan.stages
        )
        assert lm_head_in_fast_node or len(plan.stages) == 1  # Either lm_head on GPU, or single node
    
    def test_node_sorting(self, sample_metrics):
        """Test node sorting by capability."""
        nodes = [
            VirtualNode("cpu", DeviceType.CPU, compute_score=1.0),
            VirtualNode("igpu", DeviceType.IGPU, compute_score=3.0),
            VirtualNode("gpu", DeviceType.GPU, compute_score=10.0),
        ]
        
        planner = ExecutionPlanner(sample_metrics)
        sorted_nodes = planner._sort_nodes_by_capability(nodes)
        
        # GPU should be first
        assert sorted_nodes[0].device_type == DeviceType.GPU
        # CPU should be last
        assert sorted_nodes[-1].device_type == DeviceType.CPU
    
    def test_plan_serialization(self, sample_metrics, sample_nodes):
        """Test plan serialization to/from JSON."""
        planner = ExecutionPlanner(sample_metrics, PartitionStrategy.BALANCED)
        original_plan = planner.generate_plan(sample_nodes, "test_model")
        
        # Serialize to JSON
        json_str = original_plan.to_json()
        assert isinstance(json_str, str)
        assert len(json_str) > 0
        
        # Deserialize from JSON
        restored_plan = PartitionPlan.from_json(json_str)
        
        # Assertions
        assert len(restored_plan.stages) == len(original_plan.stages)
        assert restored_plan.total_expected_latency_ms == original_plan.total_expected_latency_ms
        assert restored_plan.strategy == original_plan.strategy
        
        # Check stage details
        for orig_stage, restored_stage in zip(original_plan.stages, restored_plan.stages):
            assert orig_stage.stage_id == restored_stage.stage_id
            assert orig_stage.layers == restored_stage.layers
            assert orig_stage.node.node_id == restored_stage.node.node_id
    
    def test_memory_constraints(self, sample_metrics, sample_nodes):
        """Test memory-aware planning respects constraints."""
        constraints = PlanningConstraints(
            max_vram_per_stage_gb=1.0,  # Very restrictive
            max_ram_per_stage_gb=2.0,
        )
        
        planner = ExecutionPlanner(
            sample_metrics,
            PartitionStrategy.MEMORY_AWARE,
            constraints
        )
        
        plan = planner.generate_plan(sample_nodes, "test_model")
        
        # Assert that all stages respect memory constraints
        for stage in plan.stages:
            assert stage.memory_required_mb <= constraints.max_vram_per_stage_gb * 1024 * 1.1
    
    def test_plan_visualization(self, sample_metrics, sample_nodes):
        """Test plan visualization generation."""
        planner = ExecutionPlanner(sample_metrics)
        plan = planner.generate_plan(sample_nodes, "test_model")
        
        vis = plan.visualize()
        
        assert isinstance(vis, str)
        assert "PARTITION PLAN" in vis
        assert "Stage" in vis
        assert "Node" in vis
        assert len(vis) > 0
    
    def test_empty_metrics_error(self, sample_nodes):
        """Test planner handles empty metrics gracefully."""
        empty_metrics = MetricsCollector()
        planner = ExecutionPlanner(empty_metrics)
        
        with pytest.raises(ValueError, match="No layer metrics available"):
            planner.generate_plan(sample_nodes, "test_model")
    
    def test_no_nodes_error(self, sample_metrics):
        """Test planner handles empty node list gracefully."""
        planner = ExecutionPlanner(sample_metrics)
        
        with pytest.raises(ValueError, match="No available nodes"):
            planner.generate_plan([], "test_model")
    
    def test_plan_summary(self, sample_metrics, sample_nodes):
        """Test plan summary generation."""
        planner = ExecutionPlanner(sample_metrics)
        plan = planner.generate_plan(sample_nodes, "test_model")
        
        summary = plan.get_summary()
        
        assert isinstance(summary, dict)
        assert "plan_name" in summary
        assert "num_stages" in summary
        assert "total_latency_ms" in summary
        assert "bottleneck" in summary
        assert "stages" in summary
        assert len(summary["stages"]) == len(plan.stages)


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
