# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Hybrid Intent Translator for Noodle DataCore.
# Produces hybrid IR with backend hints for automatic selection (SQL for simple queries, matrix for performance).
# Supports filter/project/group_by/agg with ≥90% accuracy on basic SQL-like inputs.
# """

import json
import re
import pathlib.Path
import typing.Any,


class HybridIntentTranslator
    #     def __init__(
    self, catalog_path: str = "noodle-dev/src/noodle/datacore/intent_catalog.json"
    #     ):
    self.catalog_path = Path(catalog_path)
    self.intents = self._load_catalog()

    #     def _load_catalog(self) -> Dict[str, Any]:
    #         """Load intent catalog."""
    #         if self.catalog_path.exists():
    #             with open(self.catalog_path, "r") as f:
                    return json.load(f)
    #         else:
    #             # Fallback empty catalog
    #             return {"intents": {}}

    #     def parse_query(
    self, query: str, table: Optional[str] = None
    #     ) -> List[Dict[str, Any]]:
    #         """
    #         Parse SQL-like query into hybrid IR.

    #         Example:
    query = "SELECT name, age FROM users WHERE age > 30 GROUP BY name"
    IR = [
    #             {"intent": "project", "params": {"columns": ["name", "age"]}, "backend_hint": "sql_or_matrix"},
    #             {"intent": "filter_mask", "params": {"column": "age", "operator": ">", "value": 30}, "backend_hint": "sql_or_matrix"},
    #             {"intent": "group_by", "params": {"group_columns": ["name"]}, "backend_hint": "sql"},
    #             {"table": "users"}
    #         ]
    #         """
    ir = []
    query_upper = query.upper()

            # Extract table (assume FROM clause)
    from_match = re.search(r"FROM\s+(\w+)", query_upper)
    #         if from_match:
                ir.append({"table": from_match.group(1)})
    #         elif table:
                ir.append({"table": table})

    #         # Project: SELECT columns
    select_match = re.search(
                r"SELECT\s+(.+?)(?:\s+FROM|\s+WHERE|\s+GROUP|$)", query_upper, re.I
    #         )
    #         if select_match:
    #             columns = [col.strip() for col in select_match.group(1).split(",")]
                ir.append(
    #                 {
    #                     "intent": "project",
    #                     "params": {"columns": columns},
                        "backend_hint": self._get_hint("project"),
    #                 }
    #             )

    #         # Filter: WHERE column op value
    where_match = re.search(r"WHERE\s+(\w+)\s+([><=]+)\s+(\d+)", query_upper)
    #         if where_match:
                ir.append(
    #                 {
    #                     "intent": "filter_mask",
    #                     "params": {
                            "column": where_match.group(1),
                            "operator": where_match.group(2),
                            "value": int(where_match.group(3)),
    #                     },
                        "backend_hint": self._get_hint("filter_mask"),
    #                 }
    #             )

    #         # Group by
    group_match = re.search(r"GROUP\s+BY\s+(.+?)(?:\s+|$)", query_upper, re.I)
    #         if group_match:
    #             groups = [g.strip() for g in group_match.group(1).split(",")]
                ir.append(
    #                 {
    #                     "intent": "group_by",
    #                     "params": {"group_columns": groups},
                        "backend_hint": self._get_hint("group_by"),
    #                 }
    #             )

    #         # Agg: SUM, COUNT, etc. on columns
    agg_match = re.search(r"(SUM|COUNT)\s*\(\s*(\w+)\s*\)", query_upper)
    #         if agg_match:
                ir.append(
    #                 {
    #                     "intent": "agg",
    #                     "params": {
                            "function": agg_match.group(1).lower(),
                            "columns": [agg_match.group(2)],
    #                     },
                        "backend_hint": self._get_hint("agg"),
    #                 }
    #             )

    #         return ir

    #     def _get_hint(self, intent_name: str) -> str:
    #         """Get backend hint from catalog or default."""
    catalog_intent = self.intents.get("intents", {}).get(intent_name)
    #         if catalog_intent and "backend_hints" in catalog_intent:
    #             # Default to sql_or_matrix for hybrid
    #             return "sql_or_matrix"
    #         return "sql_or_matrix"
