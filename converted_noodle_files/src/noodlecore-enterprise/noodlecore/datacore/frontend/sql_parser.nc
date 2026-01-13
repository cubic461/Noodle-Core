# Converted from Python to NoodleCore
# Original file: noodle-core

import json
import typing.Any,

import sqlparse
import sqlparse.sql.(
#     Comparison,
#     Function,
#     GroupBy,
#     Identifier,
#     IdentifierList,
#     Where,
# )
import sqlparse.tokens.CTE,


def parse_sql_to_ast(sql: str) -> Dict[str, Any]:
#     """
#     Parse SQL query to a structured AST-like dictionary.
#     Handles basic SELECT with projections, filters, group by, and aggregations.
#     """
parsed = sqlparse.parse(sql)[0]
ast = {
#         "type": "select",
#         "projections": [],
#         "from_table": None,
#         "where_conditions": [],
#         "group_by": [],
#         "aggregates": [],
#         "order_by": [],
#     }

#     # Extract FROM
#     for token in parsed.tokens:
#         if token.ttype is Keyword and token.value.upper() == "FROM":
next_token = parsed.token_next(token)[1]
#             if next_token and isinstance(next_token, Identifier):
ast["from_table"] = next_token.get_name()

#     # Extract SELECT projections
select_token = None
#     for token in parsed.tokens:
#         if token.ttype is DML and token.value.upper() == "SELECT":
select_token = token
#             break
#     if select_token:
select_items = select_token.get_sublists()
#         for sublist in select_items:
#             for item in sublist.flatten():
#                 if isinstance(item, Identifier):
col = item.get_name()
#                     if "." in col:
col = col.split(".")[-1]
                    ast["projections"].append(col)
#                 elif isinstance(item, Function):
func_name = item.get_name().upper()
args = [
                        arg.get_name()
#                         for arg in item.get_parameters()
#                         if isinstance(arg, Identifier)
#                     ]
                    ast["aggregates"].append({"function": func_name, "columns": args})

#     # Extract WHERE
where_token = parsed.token_matching(Where)
#     if where_token:
conditions = []
#         for token in where_token.tokens:
#             if isinstance(token, Comparison):
#                 left = token.left.get_name() if token.left else None
#                 right = token.right.get_name() if token.right else None
op = token.get_operator()
                conditions.append({"left": left, "operator": op, "right": right})
ast["where_conditions"] = conditions

#     # Extract GROUP BY
group_token = parsed.token_matching(GroupBy)
#     if group_token:
#         for token in group_token.tokens:
#             if isinstance(token, Identifier):
                ast["group_by"].append(token.get_name())

#     return ast


def extract_intent_hints(ast: Dict[str, Any]) -> Dict[str, Any]:
#     """
#     Extract basic intent hints from AST.
#     """
hints = {
#         "project_columns": ast["projections"],
#         "filter_mask": ast["where_conditions"],
#         "group_by_agg": {"groups": ast["group_by"], "aggs": ast["aggregates"]},
#         "table": ast["from_table"],
#     }
#     return {k: v for k, v in hints.items() if v}  # Remove empty
