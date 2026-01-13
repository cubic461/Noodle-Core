# Converted from Python to NoodleCore
# Original file: src

# """Cost model for backend selection in hybrid orchestration."""

import typing.Any

import numpy as np

import noodlecore.ai_orchestrator.profiler.AIProfiler


class CostModel
    #     def __init__(self, memory_db=None):
    #         self.profiler = AIProfiler(memory_db) if memory_db else AIProfiler()
    self.historical_profiles = {}  # Dict of query shapes to profiles

    #     def estimate_cost(
    #         self, ir: Dict[str, Any], shapes: Dict[str, Tuple[int, ...]]
    #     ) -Dict[str, float]):
    #         """Estimate costs for SQL and matrix backends."""
    sql_cost = self._sql_cost(ir, shapes)
    matrix_cost = self._matrix_cost(ir, shapes)
    #         return {"sql": sql_cost, "matrix": matrix_cost}

    #     def _sql_cost(
    #         self, ir: Dict[str, Any], shapes: Dict[str, Tuple[int, ...]]
    #     ) -float):
    #         """Basic SQL cost: rows * operations."""
    rows = shapes.get("data_size", (1000,))[0]
    ops = len(ir.get("operations", []))
    #         return rows * ops * 0.01  # Placeholder

    #     def _matrix_cost(
    #         self, ir: Dict[str, Any], shapes: Dict[str, Tuple[int, ...]]
    #     ) -float):
    #         """Basic matrix cost: tensor ops complexity."""
    dims = np.prod(shapes.get("tensor_shape", (10, 10)))
    ops = len(
    #             [op for op in ir.get("operations", []) if op["type"] in ["matmul", "conv"]]
    #         )
    #         return dims * ops * 0.001  # Placeholder, lower for tensors

    #     def select_backend(
    #         self, ir: Dict[str, Any], shapes: Dict[str, Tuple[int, ...]]
    #     ) -str):
    #         """Select backend using cost model and AI profiler stub."""
    costs = self.estimate_cost(ir, shapes)
    profiles = self.profiler.get_historical_profiles(ir["query_type"], shapes)
    #         # Basic ML stub: weighted decision
    sql_score = costs["sql"] + profiles.get("sql_latency", 1.0)
    matrix_score = costs["matrix"] + profiles.get("matrix_latency", 0.5)
    #         if sql_score < matrix_score:
    #             return "sql"
    #         elif matrix_score < sql_score:
    #             return "matrix"
    #         else:
    #             return "fallback"  # Escape for unfit
