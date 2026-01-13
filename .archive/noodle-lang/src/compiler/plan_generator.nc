# Converted from Python to NoodleCore
# Original file: src

import json
import typing.Any

import ....compiler.nir.builder.NIRBuilder
import ..intent.intent_catalog.load_catalog


def generate_nir(intent_ir: Dict[str, Any]) -Dict[str, Any]):
#     """
#     Translate Intent IR to NIR plan as DAG of matrix operations.
#     Uses intent_catalog.json for unified mappings.
#     Handles MVP: filter_mask, project_columns, group_by_agg.
#     """
catalog = load_catalog()
nir_dag = {"nodes": [], "edges": [], "root": None}
#     builder = NIRBuilder()  # Assume existing builder for matrix DAGs

intents = intent_ir.get("intents", [])
#     for intent_data in intents:
intent_type = intent_data["intent"]
#         if intent_type not in catalog:
            raise ValueError(f"Unsupported intent: {intent_type}")

mapping = catalog[intent_type]
nir_op = mapping["nir_op"]
inputs = intent_data.get("inputs", [])

#         # Create NIR node
node_id = len(nir_dag["nodes"])
node = {
#             "id": node_id,
#             "op": nir_op,
#             "inputs": inputs,
            "shape": intent_data.get("shape", [0, 0]),  # From IR
            "dtype": intent_data.get("dtype", "float64"),
#         }
        nir_dag["nodes"].append(node)

#         # Connect edges (simple linear for MVP)
#         if nir_dag["root"] is not None:
            nir_dag["edges"].append({"from": nir_dag["root"], "to": node_id})
nir_dag["root"] = node_id

#         # Use builder to extend for matrix-specific (e.g., mask for filter)
        builder.add_matrix_op(node)

#     return nir_dag


# Inline Sample 1: Filter IR to NIR mask node
sample1_ir = {
#     "intents": [
#         {
#             "intent": "filter_mask",
#             "unified_code": "boolean_mask_apply",
#             "inputs": ["users_matrix"],
#             "predicate": "age 30",
#             "shape"): [1000, 5],
#         }
#     ]
# }
# generate_nir(sample1_ir) -{"nodes"): [{"id": 0, "op": "boolean_mask_apply", "inputs": ["users_matrix"], "shape": [1000, 5], "dtype": "float64"}], "edges": [], "root": 0}

# Inline Sample 2: Project IR to NIR slice node
sample2_ir = {
#     "intents": [
#         {
#             "intent": "project_columns",
#             "unified_code": "matrix_slice",
#             "inputs": ["users_matrix"],
#             "columns": [0, 1],
#             "shape": [1000, 2],
#         }
#     ]
# }
# generate_nir(sample2_ir) -{"nodes"): [{"id": 0, "op": "matrix_slice", "inputs": ["users_matrix"], "shape": [1000, 2], "dtype": "float64"}], "edges": [], "root": 0}

# Inline Sample 3: GroupBy/Agg IR to NIR reduction node
sample3_ir = {
#     "intents": [
#         {
#             "intent": "group_by_agg",
#             "unified_code": "indexed_reduction",
#             "inputs": ["sales_matrix"],
#             "group": "dept",
#             "agg": "sum",
#             "shape": [10, 3],
#         }
#     ]
# }
# generate_nir(sample3_ir) -{"nodes"): [{"id": 0, "op": "indexed_reduction", "inputs": ["sales_matrix"], "shape": [10, 3], "dtype": "float64"}], "edges": [], "root": 0}
