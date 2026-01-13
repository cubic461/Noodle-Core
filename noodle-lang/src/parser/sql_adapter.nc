# Converted from Python to NoodleCore
# Original file: src

# """
# SQL Adapter for Noodle DataCore Hybrid Intent System.
Translates hybrid IR to SQL queries, executes via SQLiteBackend (or PostgreSQL stub), returns DataFrame.
# Supports filter/project/group_by/agg subset.
# """

import typing.Any

import pandas as pd

import ....database.backends.sqlite.SQLiteBackend
import ..hybrid_intent_translator.HybridIntentTranslator


class SQLAdapter:
    #     def __init__(self, backend_config: Optional[Dict[str, Any]] = None):
    self.translator = HybridIntentTranslator()
    self.backend_config = backend_config or {"database_path": ":memory:"}
    self.backend = SQLiteBackend(self.backend_config)
            self.backend.connect()

    #     def translate_and_execute(
    self, query: str, table: Optional[str] = None
    #     ) -pd.DataFrame):
    #         """
    #         Translate query to IR, generate SQL if SQL-compatible, execute, return DataFrame.

    #         Sample 1: Simple filter/project
    query = "SELECT name FROM users WHERE age 30"
    IR = [{"table"): "users"}, {"intent": "project", "params": {"columns": ["name"]}, "backend_hint": "sql_or_matrix"}, {"intent": "filter_mask", "params": {"column": "age", "operator": ">", "value": 30}, "backend_hint": "sql_or_matrix"}]
    SQL = "SELECT name FROM users WHERE age 30"
    #         Result DataFrame): name
    #                           Alice  (assuming data where age>30 for Bob, but sample: empty or Bob)

    #         Sample 2: With aggregation
    query = "SELECT COUNT(name) FROM users GROUP BY age"
    IR = [{"table": "users"}, {"intent": "agg", "params": {"function": "count", "columns": ["name"]}, "backend_hint": "sql_or_matrix"}, {"intent": "group_by", "params": {"group_columns": ["age"]}, "backend_hint": "sql"}]
    SQL = "SELECT COUNT(name) FROM users GROUP BY age"
            Result DataFrame: COUNT(name)
    #                           age
    #                           25    1
    #                           35    1

    #         Sample 3: Project + filter + group
    query = "SELECT age, SUM(salary) FROM employees WHERE dept = 'IT' GROUP BY age"
    IR = [{"table": "employees"}, {"intent": "project", "params": {"columns": ["age", "SUM(salary)"]}, "backend_hint": "sql_or_matrix"}, {"intent": "filter_mask", "params": {"column": "dept", "operator": "=", "value": "IT"}, "backend_hint": "sql_or_matrix"}, {"intent": "group_by", "params": {"group_columns": ["age"]}, "backend_hint": "sql"}, {"intent": "agg", "params": {"function": "sum", "columns": ["salary"]}, "backend_hint": "sql_or_matrix"}]
    SQL = "SELECT age, SUM(salary) FROM employees WHERE dept = 'IT' GROUP BY age"
            Result DataFrame: age  SUM(salary)
    #                           30         75000
    #                           40         120000
    #         """
    ir = self.translator.parse_query(query, table)

    #         # Check if SQL compatible
    #         sql_hints = any("sql" in item.get("backend_hint", "") for item in ir)
    #         if not sql_hints:
    #             raise ValueError("IR not compatible with SQL backend")

    #         # Build SQL from IR
    sql_parts = ["SELECT"]
    table_name = None
    where_conditions = []
    params = []
    group_by = []

    #         for item in ir:
    #             if "table" in item:
    table_name = item["table"]
    #             elif item["intent"] == "project":
    columns = item["params"]["columns"]
    #                 # Handle agg in columns
    select_cols = []
    #                 for col in columns:
    #                     if re.match(
                            r"^(SUM|COUNT|AVG|MIN|MAX)\s*\(\s*(\w+)\s*\)$", col.upper()
    #                     ):
    func, c = re.match(
                                r"^(SUM|COUNT|AVG|MIN|MAX)\s*\(\s*(\w+)\s*\)$", col.upper()
                            ).groups()
                            select_cols.append(f"{func}({c})")
    #                     else:
                            select_cols.append(col)
                    sql_parts.append(", ".join(select_cols))
    #             elif item["intent"] == "filter_mask":
    params_dict = item["params"]
    col = params_dict["column"]
    op = params_dict["operator"]
    val = params_dict["value"]
                    where_conditions.append(f"{col} {op} ?")
                    params.append(val)
    #             elif item["intent"] == "group_by":
    group_by = item["params"]["group_columns"]
    #             elif item["intent"] == "agg":
    #                 # Agg handled in project for simplicity
    #                 pass

    sql = " ".join(sql_parts) + f" FROM {table_name}"
    #         if where_conditions:
    sql + = " WHERE " + " AND ".join(where_conditions)
    #         if group_by:
    sql + = " GROUP BY " + ", ".join(group_by)

    #         # Execute
    results = self.backend.execute_query(sql, params)

    #         # PostgreSQL stub
    #         # if self.backend_config.get('dialect') == 'postgresql':
    #         #     # Use psycopg2 or similar
    #         #     pass

            return pd.DataFrame(results)

    #     def close(self):
            self.backend.disconnect()
