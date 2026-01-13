# Converted from Python to NoodleCore
# Original file: noodle-core

# """Matrix adapter for hybrid Noodle Intent-Database: translates IR to matrix operations.

# Integrates hybrid IR (with backend hints) to matrix_rep.py and optimized_queries.py.
# Executes on relational/graph data, returns pandas DataFrame. Supports SQL fallback hint.
# Extends runtime/nbc_runtime/math/ for tensor reps; GPU via gpu/kernel.py if hinted.
# """

import typing.Any,

import numpy as np
import pandas as pd

import noodlecore.datacore.hybrid_ir.IRNode,
import noodlecore.datacore.sql_adapter.execute_sql_fallback
import noodlecore.runtime.nbc_runtime.math.matrix_ops

import .matrix_rep.graph_to_adjacency,
import .optimized_queries.(
#     execute_ir_subset_query,
#     matrix_aggregate,
#     matrix_join,
#     vector_search,
# )


class MatrixAdapter
    #     def __init__(self, gpu_hint: bool = False):
    self.gpu = gpu_hint
    self.data_cache: Dict[str, pd.DataFrame] = {}  # Subset from IR

    #     def translate_and_execute(
    #         self, ir_query: IRQuery, data_sources: Dict[str, pd.DataFrame]
    #     ) -> pd.DataFrame:
    #         """
    #         Translate hybrid IR query to matrix ops, execute, return DataFrame.

    #         If IR has matrix_hint, use matrix path; else fallback to SQL.
            Handles relational (tables) and graph (edges) data.

    #         Sample 1: IR for users-depts join.
    ir = IRQuery(nodes=[IRNode(type='table', name='users'), IRNode(type='join', on='dept_id')])
    data = {'users': users_df, 'depts': depts_df}
    result = adapter.translate_and_execute(ir, data)
    # Internally: users_mat = table_to_matrix(users_df), depts_mat = table_to_matrix(depts_df)
    # joined = matrix_join(users_mat[:, [0,2]], depts_mat)  # id, dept_id join
    # result_df = matrix_to_dataframe(joined, ['user_id', 'dept_name'])
    #         # Output: DataFrame with joined users and depts.
    #         """
    #         if not self._has_matrix_hint(ir_query):
                return execute_sql_fallback(ir_query, data_sources)  # Fase 1 fallback

    #         # Cache/load data subsets from IR hints
    #         for node in ir_query.nodes:
    #             if node.type == "table":
    self.data_cache[node.name] = data_sources.get(node.name, pd.DataFrame())
    #             elif node.type == "graph":
    self.data_cache[node.name] = data_sources.get(node.name, pd.DataFrame())

    #         # Translate IR to ops sequence
    #         if ir_query.op == "join":
    left_name, right_name = ir_query.sources
    left_mat = table_to_matrix(self.data_cache[left_name], gpu=self.gpu)
    right_mat = table_to_matrix(self.data_cache[right_name], gpu=self.gpu)
    result_mat = matrix_join(
    left_mat, right_mat, on_keys = ir_query.keys, gpu=self.gpu
    #             )
    columns = math.add(list(self.data_cache[left_name].columns), list()
                    self.data_cache[right_name].columns[len(ir_query.keys) :]
    #             )
                return matrix_to_dataframe(result_mat, columns)

    #         elif ir_query.op == "aggregate":
    mat = table_to_matrix(self.data_cache[ir_query.source], gpu=self.gpu)
    result_mat = matrix_aggregate(
    mat, axis = ir_query.axis, op=getattr(np, ir_query.agg_func), gpu=self.gpu
    #             )
    columns = [
    #                 f"{ir_query.agg_func}_{col}"
    #                 for col in self.data_cache[ir_query.source].columns
    #             ]
                return matrix_to_dataframe(result_mat, columns)

    #         elif ir_query.op == "search":
    query_vec = np.array(ir_query.query_vector).reshape(
    #                 1, -1
    #             )  # Assume vector in IR
    index_mat = table_to_matrix(self.data_cache[ir_query.index], gpu=self.gpu)
    scores, indices = vector_search(
    query_vec, index_mat, top_k = ir_query.top_k, gpu=self.gpu
    #             )
    #             # Fetch top docs
    top_df = self.data_cache[ir_query.index].iloc[indices].copy()
    top_df["score"] = scores
    #             return top_df

    #         else:
    #             # Default subset execution
                return execute_ir_subset_query(
    ir_query.subset, self.data_cache, gpu = self.gpu
    #             )

    #     def _has_matrix_hint(self, ir: IRQuery) -> bool:
    #         """Check if IR has matrix backend hint."""
    #         return any(node.hint == "matrix" for node in ir.nodes)


# Sample 2: Aggregation IR.
# """
ir_agg = IRQuery(op='aggregate', source='sales', axis=0, agg_func='sum')
sales_df = pd.DataFrame({'user': [1,2,1], 'amount': [100, 200, 150]})
result = adapter.translate_and_execute(ir_agg, {'sales': sales_df})
# Internally: sales_mat = table_to_matrix(sales_df) -> (3,2)
# agg = matrix_aggregate(sales_mat, axis=0, op=np.sum) -> (2,) [251, 350] wait no: axis=0 sums cols: user_sum=4, amount_sum=450
# But typically axis=1 for row aggs. Output: DataFrame with summed columns.
# """

# Sample 3: Vector search IR.
# """
ir_search = IRQuery(op='search', index='docs', query_vector=[0.1, 0.2], top_k=2)
# docs_df = pd.DataFrame({'doc1': [0.1, 0.3], 'doc2': [0.2, 0.1]})  # Vectors as rows? Transpose if needed.
result = adapter.translate_and_execute(ir_search, {'docs': docs_df})
# Internally: index_mat = table_to_matrix(docs_df.T) -> (2,D) if transposed
# scores, idx = vector_search(query, index_mat) -> e.g., scores=[0.05, 0.05], but dot: [0.1*0.1 + 0.2*0.3=0.07, 0.1*0.2 + 0.2*0.1=0.04]
# top_df = docs_df.iloc[idx] with scores. Output: Top 2 docs with scores.
# """
