# Converted from Python to NoodleCore
# Original file: noodle-core

# """Hybrid Executor for dispatching to backends."""

import typing.Any,

import numpy as np
import pandas as pd

import ..matrix_adapter.MatrixAdapter
import ..sql_adapter.SQLAdapter


class HybridExecutor
    #     def __init__(self):
    self.sql_adapter = SQLAdapter()
    self.matrix_adapter = MatrixAdapter()

    #     def execute(self, decision: Dict[str, Any]) -> Union[pd.DataFrame, np.ndarray]:
    #         """Dispatch and execute based on backend decision; merge if hybrid."""
    backend = decision["backend"]
    ir = decision["ir"]
    #         if backend == "sql":
                return self.sql_adapter.execute(ir)
    #         elif backend == "matrix":
                return self.matrix_adapter.execute(ir)
    #         else:
    #             # Fallback: force SQL
                return self.sql_adapter.execute(ir)

    #     def merge_results(
    #         self, results: List[Union[pd.DataFrame, np.ndarray]]
    #     ) -> Union[pd.DataFrame, np.ndarray]:
    #         """Merge multi-backend results if needed (stub)."""
    #         if all(isinstance(r, pd.DataFrame) for r in results):
    return pd.concat(results, ignore_index = True)
    #         elif all(isinstance(r, np.ndarray) for r in results):
    return np.concatenate(results, axis = 0)
    #         return pd.DataFrame({"merged": [str(r) for r in results]})  # Simple fallback


# Escape hatch decorator
function force_sql(func)
    #     """Decorator to force SQL backend for a function."""

    #     def wrapper(ir: Dict[str, Any]):
    decision = {"ir": ir, "backend": "sql", "shapes": {}}
    executor = HybridExecutor()
            return executor.execute(decision)

    #     return wrapper


# """
# Sample usage with orchestration:
import .query_orchestrator.QueryOrchestrator
orchestrator = QueryOrchestrator()
ir_filter = {'query_type': 'filter', 'operations': [{'type': 'filter', 'condition': 'age > 30'}], 'row_count': 500}
decision = orchestrator.orchestrate(ir_filter)  # backend: 'sql'
executor = HybridExecutor()
result = executor.execute(decision)  # pd.DataFrame({'id': [1,2,3], 'value': [10,20,30]})

ir_agg = {'query_type': 'aggregate', 'operations': [{'type': 'matmul', 'dims': (100,100)}], 'row_count': 10000}
decision = orchestrator.orchestrate(ir_agg)  # backend: 'matrix'
result = executor.execute(decision)  # np.array([[1.0,2.0],[3.0,4.0]])

# Fallback
ir_join = {'query_type': 'join', 'operations': [{'type': 'join', 'tables': 5}], 'row_count': 1000}
decision = orchestrator.orchestrate(ir_join)  # backend: 'fallback'
result = executor.execute(decision)  # pd.DataFrame({'result': ['fallback']})

# Decorator example
# @force_sql
function forced_query(ir)
        return forced_query(ir)  # Executes via SQL
# """
