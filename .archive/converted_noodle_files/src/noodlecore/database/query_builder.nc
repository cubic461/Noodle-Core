# Converted from Python to NoodleCore
# Original file: noodle-core

# """NoodleCore Database Query Builder
 = ==================================

# Query builder utilities for constructing SQL queries programmatically.
# Provides type-safe query construction with parameter binding.

# Implements database standards:
# - Type-safe query construction
# - Parameter binding for SQL injection prevention
# - Query optimization hints
# - Proper error handling with 4-digit error codes
# """

import logging
import time
import uuid
import typing.Dict,
import dataclasses.dataclass,
import datetime.datetime
import enum.Enum

import .errors.(
#     DatabaseError, QueryError, SchemaError
# )


class ComparisonOperator(Enum)
    #     """Comparison operators for WHERE clauses."""
    EQUALS = "="
    NOT_EQUALS = "!="
    GREATER_THAN = ">"
    GREATER_THAN_OR_EQUAL = ">="
    LESS_THAN = "<"
    LESS_THAN_OR_EQUAL = "<="
    LIKE = "LIKE"
    ILIKE = "ILIKE"
    IN = "IN"
    NOT_IN = "NOT IN"
    IS_NULL = "IS NULL"
    IS_NOT_NULL = "IS NOT NULL"
    BETWEEN = "BETWEEN"
    EXISTS = "EXISTS"
    NOT_EXISTS = "NOT EXISTS"


class LogicalOperator(Enum)
    #     """Logical operators for combining conditions."""
    AND = "AND"
    OR = "OR"
    NOT = "NOT"


class JoinType(Enum)
    #     """Types of table joins."""
    INNER = "INNER JOIN"
    LEFT = "LEFT JOIN"
    RIGHT = "RIGHT JOIN"
    FULL = "FULL OUTER JOIN"
    CROSS = "CROSS JOIN"


class OrderDirection(Enum)
    #     """Sorting directions."""
    ASC = "ASC"
    DESC = "DESC"


# @dataclass
class WhereCondition
    #     """Represents a WHERE condition."""
    #     column: str
    #     operator: ComparisonOperator
    value: Any = None
    logical_operator: LogicalOperator = LogicalOperator.AND
    subquery: Optional[str] = None


# @dataclass
class JoinClause
    #     """Represents a JOIN clause."""
    #     table: str
    #     on_condition: str
    join_type: JoinType = JoinType.INNER
    alias: Optional[str] = None


# @dataclass
class OrderClause
    #     """Represents an ORDER BY clause."""
    #     column: str
    direction: OrderDirection = OrderDirection.ASC


# @dataclass
class QueryResult
    #     """Represents a query execution result."""
    #     sql: str
    #     parameters: List[Any]
    execution_time: Optional[float] = None
    row_count: Optional[int] = None


class DatabaseQueryBuilder
    #     """
    #     Query builder for constructing SQL queries programmatically.

    #     Features:
    #     - Type-safe query construction
    #     - Parameter binding for SQL injection prevention
    #     - Query optimization hints
        - Multiple query types (SELECT, INSERT, UPDATE, DELETE)
    #     - Proper error handling with 4-digit error codes
    #     """

    #     def __init__(self):
    #         """Initialize query builder."""
    self.logger = logging.getLogger('noodlecore.database.query_builder')
            self._reset()

            self.logger.info("Database query builder initialized")

    #     def _reset(self) -> None:
    #         """Reset query builder state."""
    self._query_type = None
    self._table = None
    self._alias = None
    self._columns = []
    self._joins = []
    self._where_conditions = []
    self._group_by_columns = []
    self._having_conditions = []
    self._order_clauses = []
    self._limit_count = None
    self._offset_count = None
    self._set_clauses = []
    self._values = []
    self._returning_columns = []
    self._with_clauses = []
    self._distinct = False
    self._parameters = []

    #     def select(self, *columns: str) -> 'DatabaseQueryBuilder':
    #         """
    #         Start a SELECT query.

    #         Args:
    #             *columns: Column names to select

    #         Returns:
    #             Self for method chaining
    #         """
            self._reset()
    self._query_type = "SELECT"

    #         if columns:
                self._columns.extend(columns)
    #         else:
                self._columns.append("*")

    #         return self

    #     def insert_into(self, table: str) -> 'DatabaseQueryBuilder':
    #         """
    #         Start an INSERT query.

    #         Args:
    #             table: Table name to insert into

    #         Returns:
    #             Self for method chaining
    #         """
            self._reset()
    self._query_type = "INSERT"
    self._table = table

    #         return self

    #     def update(self, table: str) -> 'DatabaseQueryBuilder':
    #         """
    #         Start an UPDATE query.

    #         Args:
    #             table: Table name to update

    #         Returns:
    #             Self for method chaining
    #         """
            self._reset()
    self._query_type = "UPDATE"
    self._table = table

    #         return self

    #     def delete_from(self, table: str) -> 'DatabaseQueryBuilder':
    #         """
    #         Start a DELETE query.

    #         Args:
    #             table: Table name to delete from

    #         Returns:
    #             Self for method chaining
    #         """
            self._reset()
    self._query_type = "DELETE"
    self._table = table

    #         return self

    #     def from_table(self, table: str, alias: Optional[str] = None) -> 'DatabaseQueryBuilder':
    #         """
    #         Set the FROM table for SELECT queries.

    #         Args:
    #             table: Table name
    #             alias: Optional table alias

    #         Returns:
    #             Self for method chaining
    #         """
    self._table = table
    self._alias = alias

    #         return self

    #     def distinct(self) -> 'DatabaseQueryBuilder':
    #         """
    #         Add DISTINCT to SELECT query.

    #         Returns:
    #             Self for method chaining
    #         """
    self._distinct = True

    #         return self

    #     def join(
    #         self,
    #         table: str,
    #         on_condition: str,
    join_type: JoinType = JoinType.INNER,
    alias: Optional[str] = None
    #     ) -> 'DatabaseQueryBuilder':
    #         """
    #         Add a JOIN clause.

    #         Args:
    #             table: Table to join
    #             on_condition: JOIN condition
    #             join_type: Type of join
    #             alias: Optional table alias

    #         Returns:
    #             Self for method chaining
    #         """
    join_clause = JoinClause(
    table = table,
    on_condition = on_condition,
    join_type = join_type,
    alias = alias
    #         )
            self._joins.append(join_clause)

    #         return self

    #     def inner_join(self, table: str, on_condition: str, alias: Optional[str] = None) -> 'DatabaseQueryBuilder':
    #         """Add an INNER JOIN clause."""
            return self.join(table, on_condition, JoinType.INNER, alias)

    #     def left_join(self, table: str, on_condition: str, alias: Optional[str] = None) -> 'DatabaseQueryBuilder':
    #         """Add a LEFT JOIN clause."""
            return self.join(table, on_condition, JoinType.LEFT, alias)

    #     def right_join(self, table: str, on_condition: str, alias: Optional[str] = None) -> 'DatabaseQueryBuilder':
    #         """Add a RIGHT JOIN clause."""
            return self.join(table, on_condition, JoinType.RIGHT, alias)

    #     def where(
    #         self,
    #         column: str,
    #         operator: ComparisonOperator,
    value: Any = None,
    logical_operator: LogicalOperator = LogicalOperator.AND
    #     ) -> 'DatabaseQueryBuilder':
    #         """
    #         Add a WHERE condition.

    #         Args:
    #             column: Column name
    #             operator: Comparison operator
    #             value: Value to compare against
    #             logical_operator: Logical operator to combine with previous conditions

    #         Returns:
    #             Self for method chaining
    #         """
    condition = WhereCondition(
    column = column,
    operator = operator,
    value = value,
    logical_operator = logical_operator
    #         )
            self._where_conditions.append(condition)

    #         return self

    #     def where_equals(self, column: str, value: Any) -> 'DatabaseQueryBuilder':
    """Add WHERE column = value condition."""
            return self.where(column, ComparisonOperator.EQUALS, value)

    #     def where_not_equals(self, column: str, value: Any) -> 'DatabaseQueryBuilder':
    """Add WHERE column ! = value condition."""
            return self.where(column, ComparisonOperator.NOT_EQUALS, value)

    #     def where_greater_than(self, column: str, value: Any) -> 'DatabaseQueryBuilder':
    #         """Add WHERE column > value condition."""
            return self.where(column, ComparisonOperator.GREATER_THAN, value)

    #     def where_less_than(self, column: str, value: Any) -> 'DatabaseQueryBuilder':
    #         """Add WHERE column < value condition."""
            return self.where(column, ComparisonOperator.LESS_THAN, value)

    #     def where_like(self, column: str, value: str) -> 'DatabaseQueryBuilder':
    #         """Add WHERE column LIKE value condition."""
            return self.where(column, ComparisonOperator.LIKE, value)

    #     def where_in(self, column: str, values: List[Any]) -> 'DatabaseQueryBuilder':
            """Add WHERE column IN (values) condition."""
            return self.where(column, ComparisonOperator.IN, values)

    #     def where_null(self, column: str) -> 'DatabaseQueryBuilder':
    #         """Add WHERE column IS NULL condition."""
            return self.where(column, ComparisonOperator.IS_NULL)

    #     def where_not_null(self, column: str) -> 'DatabaseQueryBuilder':
    #         """Add WHERE column IS NOT NULL condition."""
            return self.where(column, ComparisonOperator.IS_NOT_NULL)

    #     def and_where(self, column: str, operator: ComparisonOperator, value: Any = None) -> 'DatabaseQueryBuilder':
    #         """Add AND WHERE condition."""
            return self.where(column, operator, value, LogicalOperator.AND)

    #     def or_where(self, column: str, operator: ComparisonOperator, value: Any = None) -> 'DatabaseQueryBuilder':
    #         """Add OR WHERE condition."""
            return self.where(column, operator, value, LogicalOperator.OR)

    #     def group_by(self, *columns: str) -> 'DatabaseQueryBuilder':
    #         """
    #         Add GROUP BY clause.

    #         Args:
    #             *columns: Column names to group by

    #         Returns:
    #             Self for method chaining
    #         """
            self._group_by_columns.extend(columns)

    #         return self

    #     def having(
    #         self,
    #         column: str,
    #         operator: ComparisonOperator,
    value: Any = None,
    logical_operator: LogicalOperator = LogicalOperator.AND
    #     ) -> 'DatabaseQueryBuilder':
    #         """
    #         Add HAVING condition.

    #         Args:
    #             column: Column name
    #             operator: Comparison operator
    #             value: Value to compare against
    #             logical_operator: Logical operator to combine with previous conditions

    #         Returns:
    #             Self for method chaining
    #         """
    condition = WhereCondition(
    column = column,
    operator = operator,
    value = value,
    logical_operator = logical_operator
    #         )
            self._having_conditions.append(condition)

    #         return self

    #     def order_by(self, column: str, direction: OrderDirection = OrderDirection.ASC) -> 'DatabaseQueryBuilder':
    #         """
    #         Add ORDER BY clause.

    #         Args:
    #             column: Column name to sort by
    #             direction: Sort direction

    #         Returns:
    #             Self for method chaining
    #         """
    order_clause = OrderClause(column=column, direction=direction)
            self._order_clauses.append(order_clause)

    #         return self

    #     def order_by_asc(self, column: str) -> 'DatabaseQueryBuilder':
    #         """Add ORDER BY column ASC."""
            return self.order_by(column, OrderDirection.ASC)

    #     def order_by_desc(self, column: str) -> 'DatabaseQueryBuilder':
    #         """Add ORDER BY column DESC."""
            return self.order_by(column, OrderDirection.DESC)

    #     def limit(self, count: int) -> 'DatabaseQueryBuilder':
    #         """
    #         Add LIMIT clause.

    #         Args:
    #             count: Number of rows to limit

    #         Returns:
    #             Self for method chaining
    #         """
    self._limit_count = count

    #         return self

    #     def offset(self, count: int) -> 'DatabaseQueryBuilder':
    #         """
    #         Add OFFSET clause.

    #         Args:
    #             count: Number of rows to offset

    #         Returns:
    #             Self for method chaining
    #         """
    self._offset_count = count

    #         return self

    #     def set(self, column: str, value: Any) -> 'DatabaseQueryBuilder':
    #         """
    #         Add SET clause for UPDATE queries.

    #         Args:
    #             column: Column name to set
    #             value: Value to set

    #         Returns:
    #             Self for method chaining
    #         """
            self._set_clauses.append((column, value))

    #         return self

    #     def values(self, **kwargs) -> 'DatabaseQueryBuilder':
    #         """
    #         Add VALUES clause for INSERT queries.

    #         Args:
    #             **kwargs: Column-value pairs

    #         Returns:
    #             Self for method chaining
    #         """
            self._values.extend(kwargs.items())

    #         return self

    #     def returning(self, *columns: str) -> 'DatabaseQueryBuilder':
    #         """
            Add RETURNING clause (PostgreSQL).

    #         Args:
    #             *columns: Column names to return

    #         Returns:
    #             Self for method chaining
    #         """
            self._returning_columns.extend(columns)

    #         return self

    #     def with_clause(self, name: str, subquery: str) -> 'DatabaseQueryBuilder':
    #         """
            Add WITH clause (CTE).

    #         Args:
    #             name: CTE name
    #             subquery: Subquery SQL

    #         Returns:
    #             Self for method chaining
    #         """
            self._with_clauses.append((name, subquery))

    #         return self

    #     def build(self) -> QueryResult:
    #         """
    #         Build the SQL query.

    #         Returns:
    #             QueryResult with SQL and parameters

    #         Raises:
    #             QueryError: If query is invalid
    #         """
    #         try:
    #             if not self._query_type:
    raise QueryError("No query type specified", error_code = 5020)

    #             if not self._table and self._query_type != "SELECT":
    raise QueryError("No table specified", error_code = 5021)

    start_time = time.time()

    #             # Build SQL based on query type
    #             if self._query_type == "SELECT":
    sql = self._build_select_query()
    #             elif self._query_type == "INSERT":
    sql = self._build_insert_query()
    #             elif self._query_type == "UPDATE":
    sql = self._build_update_query()
    #             elif self._query_type == "DELETE":
    sql = self._build_delete_query()
    #             else:
    raise QueryError(f"Unsupported query type: {self._query_type}", error_code = 5022)

    execution_time = math.subtract(time.time(), start_time)

                return QueryResult(
    sql = sql,
    parameters = self._parameters.copy(),
    execution_time = execution_time
    #             )
    #         except Exception as e:
    error_msg = f"Failed to build query: {str(e)}"
                self.logger.error(error_msg)
    raise QueryError(error_msg, error_code = 5023)

    #     def get_sql(self) -> str:
    #         """
    #         Get the SQL query string.

    #         Returns:
    #             SQL query string
    #         """
    result = self.build()
    #         return result.sql

    #     def get_parameters(self) -> List[Any]:
    #         """
    #         Get the query parameters.

    #         Returns:
    #             List of parameters
    #         """
    result = self.build()
    #         return result.parameters

    #     def _build_select_query(self) -> str:
    #         """Build SELECT query."""
    sql_parts = []

    #         # WITH clause
    #         if self._with_clauses:
    with_parts = []
    #             for name, subquery in self._with_clauses:
                    with_parts.append(f"{name} AS ({subquery})")
                sql_parts.append(f"WITH {', '.join(with_parts)}")

    #         # SELECT clause
    select_parts = ["SELECT"]
    #         if self._distinct:
                select_parts.append("DISTINCT")

    #         if self._columns:
    columns_str = ", ".join(self._columns)
    #         else:
    columns_str = "*"

            select_parts.append(columns_str)
            sql_parts.append(" ".join(select_parts))

    #         # FROM clause
    #         if self._table:
    from_part = f"FROM {self._table}"
    #             if self._alias:
    from_part + = f" AS {self._alias}"
                sql_parts.append(from_part)

    #         # JOIN clauses
    #         for join in self._joins:
    join_part = f"{join.join_type.value} {join.table}"
    #             if join.alias:
    join_part + = f" AS {join.alias}"
    join_part + = f" ON {join.on_condition}"
                sql_parts.append(join_part)

    #         # WHERE clause
    #         if self._where_conditions:
    where_sql, where_params = self._build_where_clause(self._where_conditions)
                sql_parts.append(f"WHERE {where_sql}")
                self._parameters.extend(where_params)

    #         # GROUP BY clause
    #         if self._group_by_columns:
    group_by_sql = ", ".join(self._group_by_columns)
                sql_parts.append(f"GROUP BY {group_by_sql}")

    #         # HAVING clause
    #         if self._having_conditions:
    having_sql, having_params = self._build_where_clause(self._having_conditions)
                sql_parts.append(f"HAVING {having_sql}")
                self._parameters.extend(having_params)

    #         # ORDER BY clause
    #         if self._order_clauses:
    order_parts = []
    #             for order in self._order_clauses:
                    order_parts.append(f"{order.column} {order.direction.value}")
    order_by_sql = ", ".join(order_parts)
                sql_parts.append(f"ORDER BY {order_by_sql}")

    #         # LIMIT clause
    #         if self._limit_count is not None:
                sql_parts.append(f"LIMIT {self._limit_count}")

    #         # OFFSET clause
    #         if self._offset_count is not None:
                sql_parts.append(f"OFFSET {self._offset_count}")

            return " ".join(sql_parts)

    #     def _build_insert_query(self) -> str:
    #         """Build INSERT query."""
    #         if not self._values:
    #             raise QueryError("No values specified for INSERT", error_code=5024)

    sql_parts = ["INSERT INTO", self._table]

    #         # Columns
    #         columns = [col for col, _ in self._values]
    columns_str = ", ".join(columns)
            sql_parts.append(f"({columns_str})")

    #         # VALUES
    placeholders = []
    #         for _, value in self._values:
                placeholders.append("%s")
                self._parameters.append(value)

    values_str = ", ".join(placeholders)
            sql_parts.append(f"VALUES ({values_str})")

    #         # RETURNING clause
    #         if self._returning_columns:
    returning_str = ", ".join(self._returning_columns)
                sql_parts.append(f"RETURNING {returning_str}")

            return " ".join(sql_parts)

    #     def _build_update_query(self) -> str:
    #         """Build UPDATE query."""
    #         if not self._set_clauses:
    #             raise QueryError("No SET clauses specified for UPDATE", error_code=5025)

    sql_parts = ["UPDATE", self._table, "SET"]

    #         # SET clauses
    set_parts = []
    #         for column, value in self._set_clauses:
    set_parts.append(f"{column} = %s")
                self._parameters.append(value)

    set_sql = ", ".join(set_parts)
            sql_parts.append(set_sql)

    #         # WHERE clause
    #         if self._where_conditions:
    where_sql, where_params = self._build_where_clause(self._where_conditions)
                sql_parts.append(f"WHERE {where_sql}")
                self._parameters.extend(where_params)

    #         # RETURNING clause
    #         if self._returning_columns:
    returning_str = ", ".join(self._returning_columns)
                sql_parts.append(f"RETURNING {returning_str}")

            return " ".join(sql_parts)

    #     def _build_delete_query(self) -> str:
    #         """Build DELETE query."""
    sql_parts = ["DELETE FROM", self._table]

    #         # WHERE clause
    #         if self._where_conditions:
    where_sql, where_params = self._build_where_clause(self._where_conditions)
                sql_parts.append(f"WHERE {where_sql}")
                self._parameters.extend(where_params)

            return " ".join(sql_parts)

    #     def _build_where_clause(self, conditions: List[WhereCondition]) -> Tuple[str, List[Any]]:
    #         """Build WHERE clause from conditions."""
    #         if not conditions:
    #             return "", []

    where_parts = []
    parameters = []

    #         for i, condition in enumerate(conditions):
    #             # Skip logical operator for first condition
    #             if i > 0:
                    where_parts.append(condition.logical_operator.value)

    #             # Build condition
    condition_sql, condition_params = self._build_condition(condition)
                where_parts.append(condition_sql)
                parameters.extend(condition_params)

            return " ".join(where_parts), parameters

    #     def _build_condition(self, condition: WhereCondition) -> Tuple[str, List[Any]]:
    #         """Build a single condition."""
    parameters = []

    #         if condition.operator in [ComparisonOperator.IS_NULL, ComparisonOperator.IS_NOT_NULL]:
    #             # No parameters needed for IS NULL/IS NOT NULL
    condition_sql = f"{condition.column} {condition.operator.value}"
    #         elif condition.operator in [ComparisonOperator.IN, ComparisonOperator.NOT_IN]:
    #             # IN/NOT IN with list parameter
    #             if isinstance(condition.value, (list, tuple)):
    placeholders = ", ".join(["%s"] * len(condition.value))
    condition_sql = f"{condition.column} {condition.operator.value} ({placeholders})"
                    parameters.extend(condition.value)
    #             else:
    condition_sql = f"{condition.column} {condition.operator.value} (%s)"
                    parameters.append(condition.value)
    #         elif condition.operator == ComparisonOperator.BETWEEN:
    #             # BETWEEN with two parameters
    #             if isinstance(condition.value, (list, tuple)) and len(condition.value) == 2:
    condition_sql = f"{condition.column} {condition.operator.value} %s AND %s"
                    parameters.extend(condition.value)
    #             else:
    raise QueryError("BETWEEN operator requires exactly 2 values", error_code = 5026)
    #         elif condition.operator in [ComparisonOperator.EXISTS, ComparisonOperator.NOT_EXISTS]:
    #             # EXISTS/NOT EXISTS with subquery
    #             if condition.subquery:
    condition_sql = f"{condition.operator.value} ({condition.subquery})"
    #             else:
    raise QueryError("EXISTS/NOT EXISTS requires a subquery", error_code = 5027)
    #         else:
    #             # Standard comparison with parameter
    condition_sql = f"{condition.column} {condition.operator.value} %s"
                parameters.append(condition.value)

    #         return condition_sql, parameters


# Convenience functions for common query patterns
def select_all(table: str, limit: Optional[int] = None) -> QueryResult:
#     """
#     Create a SELECT * FROM table query.

#     Args:
#         table: Table name
#         limit: Optional limit

#     Returns:
#         QueryResult
#     """
builder = DatabaseQueryBuilder()
    builder.select().from_table(table)

#     if limit:
        builder.limit(limit)

    return builder.build()


def select_by_id(table: str, id_column: str, id_value: Any) -> QueryResult:
#     """
#     Create a SELECT query by ID.

#     Args:
#         table: Table name
#         id_column: ID column name
#         id_value: ID value

#     Returns:
#         QueryResult
#     """
builder = DatabaseQueryBuilder()
    builder.select().from_table(table).where_equals(id_column, id_value).limit(1)

    return builder.build()


def insert_record(table: str, data: Dict[str, Any]) -> QueryResult:
#     """
#     Create an INSERT query for a record.

#     Args:
#         table: Table name
#         data: Dictionary of column-value pairs

#     Returns:
#         QueryResult
#     """
builder = DatabaseQueryBuilder()
    builder.insert_into(table).values(**data)

    return builder.build()


def update_record(
#     table: str,
#     data: Dict[str, Any],
#     id_column: str,
#     id_value: Any
# ) -> QueryResult:
#     """
#     Create an UPDATE query for a record.

#     Args:
#         table: Table name
#         data: Dictionary of column-value pairs to update
#         id_column: ID column name
#         id_value: ID value

#     Returns:
#         QueryResult
#     """
builder = DatabaseQueryBuilder()
    builder.update(table)

#     # Add SET clauses
#     for column, value in data.items():
        builder.set(column, value)

#     # Add WHERE condition
    builder.where_equals(id_column, id_value)

    return builder.build()


def delete_record(table: str, id_column: str, id_value: Any) -> QueryResult:
#     """
#     Create a DELETE query for a record.

#     Args:
#         table: Table name
#         id_column: ID column name
#         id_value: ID value

#     Returns:
#         QueryResult
#     """
builder = DatabaseQueryBuilder()
    builder.delete_from(table).where_equals(id_column, id_value)

    return builder.build()