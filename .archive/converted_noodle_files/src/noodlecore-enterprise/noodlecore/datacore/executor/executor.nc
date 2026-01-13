# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# DataCore Executor for Noodle MVP.
# Executes optimized NIR plans locally on CPU with NumPy kernels.
# Fallback to SQLite SQL execution.
# Integrates with NBC runtime for dispatch.
# """

import logging
import typing.Any,

import numpy as np
import pandas as pd

import ....database.backends.sqlite.SQLiteBackend
import ....runtime.nbc_runtime.core.runtime.NBCRuntime
import ..intent.intent_schema.IntentIR
import .kernel_registry.KernelRegistry

logger = logging.getLogger(__name__)


class DataCoreExecutor
    #     def __init__(self, db_path: str = ":memory:"):
    self.registry = KernelRegistry()
    self.runtime = NBCRuntime()
    self.db = SQLiteBackend({"database_path": db_path})
    #         # Assume sample table 'users' with columns: id, name, age, dept, salary
            self._init_sample_db()

    #     def _init_sample_db(self):
    #         """Initialize sample data for examples."""
    schema = {
    #             "id": "INTEGER",
    #             "name": "TEXT",
    #             "age": "INTEGER",
    #             "dept": "TEXT",
    #             "salary": "REAL",
    #         }
            self.db.create_table("users", schema)
    sample_data = [
    #             {"id": 1, "name": "Alice", "age": 30, "dept": "Eng", "salary": 70000},
    #             {"id": 2, "name": "Bob", "age": 25, "dept": "HR", "salary": 50000},
    #             {"id": 3, "name": "Charlie", "age": 35, "dept": "Eng", "salary": 80000},
    #             {"id": 4, "name": "Diana", "age": 28, "dept": "HR", "salary": 55000},
    #             {"id": 5, "name": "Eve", "age": 40, "dept": "Eng", "salary": 90000},
    #         ]
            self.db.insert("users", sample_data)

    #     def execute_nir(self, nir_plan: Dict[str, Any]) -> pd.DataFrame:
    #         """
    #         Execute NIR plan: DAG of nodes with ops like filter/project/group_by/agg.
    #         Process sequentially (assume linear for MVP); use kernels or fallback.
    #         Returns result as DataFrame.

    #         Example 1: Filter NIR
    filter_nir = {"nodes": [{"op": "boolean_mask_apply", "predicate": "age > 30", "input": "users", "shape": [5, 5]}]}
    #         result = execute_nir(filter_nir)  # Output: DataFrame with rows where age > 30 (Alice, Charlie, Eve)

    #         Example 2: Project NIR
    project_nir = {"nodes": [{"op": "project_columns", "columns": ["name", "salary"], "input": "users", "shape": [5, 2]}]}
    #         result = execute_nir(project_nir)  # Output: DataFrame with name and salary columns

    #         Example 3: GroupBy Agg NIR
    group_nir = {"nodes": [{"op": "group_by_agg", "group_cols": ["dept"], "agg_col": "salary", "agg_func": "mean", "input": "users", "shape": [3, 2]}]}
    #         result = execute_nir(group_nir)  # Output: DataFrame with dept and mean(salary) (Eng: 80000, HR: 52500)
    #         """
    #         if "nodes" not in nir_plan:
                raise ValueError("Invalid NIR: missing nodes")

    current_data = self._load_input_data(nir_plan.get("input", "users"))
    #         for node in nir_plan["nodes"]:
    op = node["op"]
    kernel = self.registry.get_kernel(op)
    #             if kernel:
    #                 try:
                        # Execute kernel (adapt inputs based on op)
    #                     if op == "boolean_mask_apply":
    mask = self._create_mask(current_data, node["predicate"])
    current_data = kernel(
    #                             current_data.values, mask
                            ).to_dataframe()  # Assume returns structured
    #                     elif op == "project_columns":
    current_data = kernel(current_data, node["columns"])
    #                     elif op == "group_by_agg":
    current_data = kernel(
    #                             current_data,
    #                             node["group_cols"],
    #                             node["agg_col"],
    #                             node["agg_func"],
    #                         )
    #                     else:
                            logger.warning(f"Unsupported kernel op: {op}")
    current_data = self._sql_fallback(nir_plan, current_data)
    #                 except Exception as e:
                        logger.error(f"Kernel execution failed: {e}")
    current_data = self._sql_fallback(nir_plan, current_data)
    #             else:
    current_data = self._sql_fallback(nir_plan, current_data)

    #         return current_data

    #     def _load_input_data(self, table: str) -> pd.DataFrame:
    #         """Load input data from DB as DataFrame."""
    result = self.db.execute_query(f"SELECT * FROM {table}")
            return pd.DataFrame(result)

    #     def _create_mask(self, df: pd.DataFrame, predicate: str) -> np.ndarray:
            """Simple predicate to boolean mask (MVP: basic >/<)."""
    #         if " > " in predicate:
    col, val = predicate.split(" > ")
    val = float(val)
                return df[col].gt(val).values
    #         # Add more predicates
            raise ValueError(f"Unsupported predicate: {predicate}")

    #     def _sql_fallback(
    self, nir_plan: Dict[str, Any], current_data: Optional[pd.DataFrame] = None
    #     ) -> pd.DataFrame:
    #         """Fallback to SQL execution: generate simple SQL from NIR."""
    #         # MVP: simplistic SQL gen for single node; assume input table
    input_table = nir_plan.get("input", "users")
    sql = f"SELECT * FROM {input_table}"
    #         for node in nir_plan["nodes"]:
    op = node["op"]
    #             if op == "boolean_mask_apply":
    col, op_str, val = node["predicate"].partition(" ")
    sql + = f" WHERE {col} {op_str} {val}"
    #             elif op == "project_columns":
    cols = ", ".join(node["columns"])
    sql = sql.replace("*", cols)
    #             elif op == "group_by_agg":
    group = ", ".join(node["group_cols"])
    agg = f"{node['agg_func']}({node['agg_col']})"
    sql = f"SELECT {group}, {agg} FROM {input_table} GROUP BY {group}"
    result = self.db.execute_query(sql)
            return pd.DataFrame(result)

    #     def dispatch_to_runtime(self, nir_plan: Dict[str, Any]) -> Any:
    #         """Dispatch NIR to NBC runtime for execution."""
    #         # Convert NIR to Instructions (simple linear conversion for MVP)
    instructions = []
    #         for node in nir_plan["nodes"]:
    #             # Assume Instruction from runtime
                from ....runtime.nbc_runtime.core.runtime import (
    #                 Instruction,
    #                 InstructionType,
    #             )

    instr = Instruction(
    instruction_type = InstructionType.MATRIX,
    operation = node["op"],
    operands = [node.get("shape", []), node.get("input", None)],
    #             )
                instructions.append(instr)
            self.runtime.load_program(instructions)
            return self.runtime.execute_program()
