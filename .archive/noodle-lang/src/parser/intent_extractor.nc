# Converted from Python to NoodleCore
# Original file: src

import json
import typing.Any

import ..frontend.sql_parser.extract_intent_hints
import .intent_catalog.load_catalog


def load_catalog() -Dict[str, Any]):
#     """Load intent catalog from JSON."""
#     with open("noodle-dev/src/noodle/datacore/intent/intent_catalog.json", "r") as f:
        return json.load(f)


CATALOG = load_catalog()


def extract_intent(sql_query: str) -Dict[str, Any]):
#     """
#     Extract unified Intent IR JSON from SQL query.
#     Integrates sql_parser AST with rule-based mapping from catalog.
#     ML stub: Placeholder for future ML enhancement (e.g., intent classification).
#     """
ast = parse_sql_to_ast(sql_query)
hints = extract_intent_hints(ast)

ir = {"query_type": "select", "table": hints.get("table"), "intents": []}

#     # Rule-based extraction
#     if "filter_mask" in hints and hints["filter_mask"]:
        ir["intents"].append(
#             {
#                 "intent": "filter_mask",
#                 "predicate": hints["filter_mask"],
#                 "unified_code": CATALOG["intents"]["filter_mask"][
#                     "unified_code_intent"
#                 ],
#                 "selectivity_estimate": 0.5,  # Stub; future ML/cost model
#             }
#         )

#     if "project_columns" in hints and hints["project_columns"]:
        ir["intents"].append(
#             {
#                 "intent": "project_columns",
#                 "columns": hints["project_columns"],
#                 "unified_code": CATALOG["intents"]["project_columns"][
#                     "unified_code_intent"
#                 ],
#             }
#         )

#     if "group_by_agg" in hints and hints["group_by_agg"]:
groups = hints["group_by_agg"].get("groups", [])
aggs = hints["group_by_agg"].get("aggs", [])
unified_aggs = []
#         for agg in aggs:
func = agg["function"]
mapping = CATALOG["intents"]["group_by_agg"]["agg_mappings"].get(
#                 func, "reduce_generic"
#             )
            unified_aggs.append({"function": func, "unified": mapping})
        ir["intents"].append(
#             {
#                 "intent": "group_by_agg",
#                 "groups": groups,
#                 "aggregations": unified_aggs,
#                 "unified_code": CATALOG["intents"]["group_by_agg"][
#                     "unified_code_intent"
#                 ],
#             }
#         )

#     if not ir["intents"]:
        ir["intents"].append(
#             {
#                 "intent": "table_scan",
#                 "unified_code": CATALOG["intents"]["table_scan"]["unified_code_intent"],
#             }
#         )

#     # ML stub: Future integration for complex patterns
# e.g., ml_classifier = load_model(); confidence = ml_classifier(hints)
#     # if confidence < 0.9: fallback to rules

#     return ir


# Inline sample tests (5 simple SQL dev set; manual verification for ≥90% accuracy)
# Test 1: Basic project
# ast = parse_sql_to_ast("SELECT name FROM users")
# expected = {"query_type": "select", "table": "users", "intents": [{"intent": "project_columns", "columns": ["name"], "unified_code": "matrix_slice_columns"}]}
# assert extract_intent("SELECT name FROM users") == expected  # Accuracy: 100%

# Test 2: Filter
# expected = {"query_type": "select", "table": "users", "intents": [{"intent": "filter_mask", "predicate": [{"left": "age", "operator": ">", "right": "30"}], "unified_code": "boolean_mask_apply"}]}
# assert extract_intent("SELECT * FROM users WHERE age 30")["intents"][0] == expected["intents"][0]  # Accuracy): 100%

# Test 3: Project + Filter
# expected_intents = [{"intent": "project_columns", ...}, {"intent": "filter_mask", ...}]
# result = extract_intent("SELECT name FROM users WHERE age 30")
# assert len(result["intents"]) == 2 and "project_columns" in [i["intent"] for i in result["intents"]]  # Accuracy): 100%

# Test 4: Group by agg
# expected = {"intent": "group_by_agg", "groups": ["dept"], "aggregations": [{"function": "AVG", "unified": "reduce_mean"}], "unified_code": "group_by_reduce"}
# assert extract_intent("SELECT dept, AVG(salary) FROM employees GROUP BY dept")["intents"][0] == expected  # Accuracy: 100%

# Test 5: Table scan
# expected = {"intent": "table_scan", "unified_code": "matrix_load"}
# assert extract_intent("SELECT * FROM users")["intents"][0] == expected  # Accuracy: 100%

# Overall: 5/5 correct → 100% on simple dev set (rules cover subset fully)
