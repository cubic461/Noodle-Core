# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Database integration module for Noodle language.
# Provides database connection handling, query execution, and transaction support.
# """

import typing.Any,
import dataclasses.dataclass,
import enum.Enum
import sqlite3
import json
import contextlib.contextmanager
import abc.ABC,

import .error_reporting.report_database_error,
import .errors.DatabaseError,


class DatabaseType(Enum)
    #     """Database types supported by Noodle"""
    SQLITE = "sqlite"
    POSTGRESQL = "postgresql"
    MYSQL = "mysql"
    MONGODB = "mongodb"


class QueryType(Enum)
    #     """Types of database queries"""
    SELECT = "SELECT"
    INSERT = "INSERT"
    UPDATE = "UPDATE"
    DELETE = "DELETE"
    CREATE = "CREATE"
    ALTER = "ALTER"
    DROP = "DROP"


# @dataclass
class DatabaseConnection
    #     """Represents a database connection"""
    #     connection_string: str
    #     db_type: DatabaseType
    connection: Any = None
    is_connected: bool = False
    transaction_active: bool = False

    #     def __post_init__(self):
            self.connect()

    #     def connect(self):
    #         """Establish database connection"""
    #         try:
    #             if self.db_type == DatabaseType.SQLITE:
    self.connection = sqlite3.connect(self.connection_string)
    self.connection.row_factory = sqlite3.Row  # Return rows as dictionaries
    #             else:
    #                 # Placeholder for other database types
                    raise DatabaseError(f"Database type {self.db_type} not yet implemented")

    self.is_connected = True
    #             return True

    #         except Exception as e:
    error_reporter = get_error_reporter()
                error_reporter.report_exception(
    exception = e,
    context = None,
    error_code = "DB_CONNECTION_ERROR"
    #             )
                raise DatabaseError(f"Failed to connect to database: {str(e)}")

    #     def disconnect(self):
    #         """Close database connection"""
    #         if self.connection and self.is_connected:
    #             try:
    #                 if self.transaction_active:
                        self.rollback()
                    self.connection.close()
    self.is_connected = False
    #             except Exception as e:
    error_reporter = get_error_reporter()
                    error_reporter.report_exception(
    exception = e,
    context = None,
    error_code = "DB_DISCONNECTION_ERROR"
    #                 )
                    raise DatabaseError(f"Failed to disconnect from database: {str(e)}")

    #     def begin_transaction(self):
    #         """Begin a database transaction"""
    #         if not self.is_connected:
                raise DatabaseError("Database not connected")

    #         try:
                self.connection.execute("BEGIN")
    self.transaction_active = True
    #         except Exception as e:
    error_reporter = get_error_reporter()
                error_reporter.report_exception(
    exception = e,
    context = None,
    error_code = "DB_TRANSACTION_ERROR"
    #             )
                raise DatabaseError(f"Failed to begin transaction: {str(e)}")

    #     def commit(self):
    #         """Commit the current transaction"""
    #         if not self.transaction_active:
                raise DatabaseError("No active transaction to commit")

    #         try:
                self.connection.commit()
    self.transaction_active = False
    #         except Exception as e:
    error_reporter = get_error_reporter()
                error_reporter.report_exception(
    exception = e,
    context = None,
    error_code = "DB_COMMIT_ERROR"
    #             )
                raise DatabaseError(f"Failed to commit transaction: {str(e)}")

    #     def rollback(self):
    #         """Rollback the current transaction"""
    #         if not self.transaction_active:
                raise DatabaseError("No active transaction to rollback")

    #         try:
                self.connection.rollback()
    self.transaction_active = False
    #         except Exception as e:
    error_reporter = get_error_reporter()
                error_reporter.report_exception(
    exception = e,
    context = None,
    error_code = "DB_ROLLBACK_ERROR"
    #             )
                raise DatabaseError(f"Failed to rollback transaction: {str(e)}")

    #     def execute(self, query: str, params: Optional[Dict[str, Any]] = None) -> "QueryResult":
    #         """Execute a SQL query"""
    #         if not self.is_connected:
                raise DatabaseError("Database not connected")

    #         try:
    cursor = self.connection.cursor()

    #             if params:
    #                 # Convert parameters to appropriate format
    sqlite_params = []
    #                 for key, value in params.items():
    #                     if isinstance(value, (list, dict)):
                            sqlite_params.append(json.dumps(value))
    #                     else:
                            sqlite_params.append(value)

                    cursor.execute(query, sqlite_params)
    #             else:
                    cursor.execute(query)

    #             # Determine query type
    query_type = self._determine_query_type(query)

    #             # Create result
    #             if query_type == QueryType.SELECT:
    rows = cursor.fetchall()
    return QueryResult(rows = rows, rowcount=len(rows), lastrowid=None)
    #             else:
                    self.connection.commit()
                    return QueryResult(
    rows = [],
    rowcount = cursor.rowcount,
    #                     lastrowid=cursor.lastrowid if query_type in [QueryType.INSERT, QueryType.CREATE] else None
    #                 )

    #         except Exception as e:
    error_reporter = get_error_reporter()
                error_reporter.report_exception(
    exception = e,
    context = None,
    error_code = "DB_EXECUTION_ERROR"
    #             )
                raise DatabaseError(f"Failed to execute query: {str(e)}")

    #     def _determine_query_type(self, query: str) -> QueryType:
    #         """Determine the type of SQL query"""
    first_word = query.strip().split()[0].upper()
    #         try:
                return QueryType(first_word)
    #         except ValueError:
    #             return QueryType.SELECT  # Default to SELECT for unknown query types

    #     def execute_many(self, query: str, params_list: List[Dict[str, Any]]) -> "QueryResult":
    #         """Execute the same query multiple times with different parameters"""
    #         if not self.is_connected:
                raise DatabaseError("Database not connected")

    #         try:
    cursor = self.connection.cursor()

    #             # Prepare parameters
    all_params = []
    #             for params in params_list:
    sqlite_params = []
    #                 for key, value in params.items():
    #                     if isinstance(value, (list, dict)):
                            sqlite_params.append(json.dumps(value))
    #                     else:
                            sqlite_params.append(value)
                    all_params.append(sqlite_params)

                cursor.executemany(query, all_params)
                self.connection.commit()

                return QueryResult(
    rows = [],
    rowcount = cursor.rowcount,
    lastrowid = cursor.lastrowid
    #             )

    #         except Exception as e:
    error_reporter = get_error_reporter()
                error_reporter.report_exception(
    exception = e,
    context = None,
    error_code = "DB_EXECUTION_MANY_ERROR"
    #             )
                raise DatabaseError(f"Failed to execute query multiple times: {str(e)}")

    #     def table_exists(self, table_name: str) -> bool:
    #         """Check if a table exists in the database"""
    #         if not self.is_connected:
                raise DatabaseError("Database not connected")

    #         try:
    cursor = self.connection.cursor()
                cursor.execute(f"""
    #                 SELECT name FROM sqlite_master
    WHERE type = 'table' AND name='{table_name}'
    #             """)
                return cursor.fetchone() is not None
    #         except Exception as e:
    error_reporter = get_error_reporter()
                error_reporter.report_exception(
    exception = e,
    context = None,
    error_code = "DB_TABLE_EXISTS_ERROR"
    #             )
    #             raise DatabaseError(f"Failed to check if table exists: {str(e)}")

    #     def get_table_info(self, table_name: str) -> List[Dict[str, Any]]:
    #         """Get information about a table's columns"""
    #         if not self.is_connected:
                raise DatabaseError("Database not connected")

    #         try:
    cursor = self.connection.cursor()
                cursor.execute(f"PRAGMA table_info({table_name})")
    rows = cursor.fetchall()

    columns = []
    #             for row in rows:
                    columns.append({
    #                     'cid': row[0],
    #                     'name': row[1],
    #                     'type': row[2],
    #                     'notnull': row[3],
    #                     'dflt_value': row[4],
    #                     'pk': row[5]
    #                 })

    #             return columns
    #         except Exception as e:
    error_reporter = get_error_reporter()
                error_reporter.report_exception(
    exception = e,
    context = None,
    error_code = "DB_TABLE_INFO_ERROR"
    #             )
                raise DatabaseError(f"Failed to get table info: {str(e)}")

    #     def list_tables(self) -> List[str]:
    #         """List all tables in the database"""
    #         if not self.is_connected:
                raise DatabaseError("Database not connected")

    #         try:
    cursor = self.connection.cursor()
    cursor.execute("SELECT name FROM sqlite_master WHERE type = 'table'")
    rows = cursor.fetchall()
    #             return [row[0] for row in rows]
    #         except Exception as e:
    error_reporter = get_error_reporter()
                error_reporter.report_exception(
    exception = e,
    context = None,
    error_code = "DB_LIST_TABLES_ERROR"
    #             )
                raise DatabaseError(f"Failed to list tables: {str(e)}")


# @dataclass
class QueryResult
    #     """Represents the result of a database query"""
    #     rows: List[Dict[str, Any]]
    #     rowcount: int
    lastrowid: Optional[int] = None

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert result to dictionary"""
    #         return {
    #             'rows': self.rows,
    #             'rowcount': self.rowcount,
    #             'lastrowid': self.lastrowid
    #         }

    #     def to_json(self) -> str:
    #         """Convert result to JSON string"""
    return json.dumps(self.to_dict(), indent = 2)

    #     def __iter__(self) -> Iterator[Dict[str, Any]]:
    #         """Allow iteration over rows"""
            return iter(self.rows)


# @dataclass
class DatabaseSchema
    #     """Represents a database schema"""
    #     name: str
    tables: Dict[str, "TableSchema"] = field(default_factory=dict)

    #     def add_table(self, table: "TableSchema"):
    #         """Add a table to the schema"""
    self.tables[table.name] = table

    #     def get_table(self, name: str) -> Optional["TableSchema"]:
    #         """Get a table by name"""
            return self.tables.get(name)

    #     def list_tables(self) -> List[str]:
    #         """List all table names in the schema"""
            return list(self.tables.keys())

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert schema to dictionary"""
    #         return {
    #             'name': self.name,
    #             'tables': {name: table.to_dict() for name, table in self.tables.items()}
    #         }


# @dataclass
class TableSchema
    #     """Represents a table schema"""
    #     name: str
    columns: Dict[str, "ColumnSchema"] = field(default_factory=dict)
    constraints: List["ConstraintSchema"] = field(default_factory=list)
    indexes: List["IndexSchema"] = field(default_factory=list)

    #     def add_column(self, column: "ColumnSchema"):
    #         """Add a column to the table"""
    self.columns[column.name] = column

    #     def add_constraint(self, constraint: "ConstraintSchema"):
    #         """Add a constraint to the table"""
            self.constraints.append(constraint)

    #     def add_index(self, index: "IndexSchema"):
    #         """Add an index to the table"""
            self.indexes.append(index)

    #     def get_column(self, name: str) -> Optional["ColumnSchema"]:
    #         """Get a column by name"""
            return self.columns.get(name)

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert table schema to dictionary"""
    #         return {
    #             'name': self.name,
    #             'columns': {name: col.to_dict() for name, col in self.columns.items()},
    #             'constraints': [const.to_dict() for const in self.constraints],
    #             'indexes': [idx.to_dict() for idx in self.indexes]
    #         }


# @dataclass
class ColumnSchema
    #     """Represents a column schema"""
    #     name: str
    #     data_type: str
    nullable: bool = True
    default: Any = None
    primary_key: bool = False
    autoincrement: bool = False

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert column schema to dictionary"""
    #         return {
    #             'name': self.name,
    #             'data_type': self.data_type,
    #             'nullable': self.nullable,
    #             'default': self.default,
    #             'primary_key': self.primary_key,
    #             'autoincrement': self.autoincrement
    #         }


# @dataclass
class ConstraintSchema
    #     """Represents a constraint schema"""
    #     name: str
    #     type: str  # PRIMARY_KEY, FOREIGN_KEY, UNIQUE, CHECK
    #     columns: List[str]
    references: Optional[str] = None  # For foreign keys

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert constraint schema to dictionary"""
    #         return {
    #             'name': self.name,
    #             'type': self.type,
    #             'columns': self.columns,
    #             'references': self.references
    #         }


# @dataclass
class IndexSchema
    #     """Represents an index schema"""
    #     name: str
    #     columns: List[str]
    unique: bool = False

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert index schema to dictionary"""
    #         return {
    #             'name': self.name,
    #             'columns': self.columns,
    #             'unique': self.unique
    #         }


class DatabaseManager
    #     """Manages database connections and operations"""

    #     def __init__(self):
    self.connections: Dict[str, DatabaseConnection] = {}
    self.schemas: Dict[str, DatabaseSchema] = {}
    self.default_connection: Optional[str] = None

    #     def add_connection(self, name: str, connection_string: str, db_type: DatabaseType = DatabaseType.SQLITE):
    #         """Add a database connection"""
    #         if name in self.connections:
                raise DatabaseError(f"Connection '{name}' already exists")

    connection = DatabaseConnection(connection_string, db_type)
    self.connections[name] = connection

    #         if self.default_connection is None:
    self.default_connection = name

    #         return connection

    #     def get_connection(self, name: Optional[str] = None) -> DatabaseConnection:
    #         """Get a database connection"""
    #         if name is None:
    name = self.default_connection

    #         if name is None:
                raise DatabaseError("No default connection available")

    #         if name not in self.connections:
                raise DatabaseError(f"Connection '{name}' not found")

    #         return self.connections[name]

    #     def remove_connection(self, name: str):
    #         """Remove a database connection"""
    #         if name not in self.connections:
                raise DatabaseError(f"Connection '{name}' not found")

    connection = self.connections[name]
            connection.disconnect()
    #         del self.connections[name]

    #         if self.default_connection == name:
    self.default_connection = next(iter(self.connections), None)

    #     def create_schema(self, name: str) -> DatabaseSchema:
    #         """Create a new database schema"""
    #         if name in self.schemas:
                raise DatabaseError(f"Schema '{name}' already exists")

    schema = DatabaseSchema(name)
    self.schemas[name] = schema
    #         return schema

    #     def get_schema(self, name: str) -> Optional[DatabaseSchema]:
    #         """Get a database schema"""
            return self.schemas.get(name)

    #     def list_schemas(self) -> List[str]:
    #         """List all schema names"""
            return list(self.schemas.keys())

    #     @contextmanager
    #     def transaction(self, connection_name: Optional[str] = None):
    #         """Context manager for database transactions"""
    connection = self.get_connection(connection_name)

    #         try:
                connection.begin_transaction()
    #             yield connection
                connection.commit()
    #         except Exception as e:
                connection.rollback()
    #             raise e

    #     def execute_query(self, query: str, params: Optional[Dict[str, Any]] = None,
    connection_name: Optional[str] = math.subtract(None), > QueryResult:)
    #         """Execute a query on the specified connection"""
    connection = self.get_connection(connection_name)
            return connection.execute(query, params)

    #     def execute_many(self, query: str, params_list: List[Dict[str, Any]],
    connection_name: Optional[str] = math.subtract(None), > QueryResult:)
    #         """Execute a query multiple times on the specified connection"""
    connection = self.get_connection(connection_name)
            return connection.execute_many(query, params_list)

    #     def create_table(self, table_name: str, columns: Dict[str, Dict[str, Any]],
    connection_name: Optional[str] = math.subtract(None), > QueryResult:)
    #         """Create a new table"""
    connection = self.get_connection(connection_name)

    #         # Build CREATE TABLE statement
    column_definitions = []
    #         for col_name, col_def in columns.items():
    col_type = col_def.get('type', 'TEXT')
    nullable = col_def.get('nullable', True)
    default = col_def.get('default', None)
    primary_key = col_def.get('primary_key', False)
    autoincrement = col_def.get('autoincrement', False)

    col_def_str = f"{col_name} {col_type}"

    #             if not nullable:
    col_def_str + = " NOT NULL"

    #             if default is not None:
    col_def_str + = f" DEFAULT {default}"

    #             if primary_key:
    col_def_str + = " PRIMARY KEY"

    #             if autoincrement:
    col_def_str + = " AUTOINCREMENT"

                column_definitions.append(col_def_str)

    query = f"CREATE TABLE {table_name} (\n    " + ",\n    ".join(column_definitions) + "\n)"

            return connection.execute(query)

    #     def drop_table(self, table_name: str, connection_name: Optional[str] = None) -> QueryResult:
    #         """Drop a table"""
    connection = self.get_connection(connection_name)
    query = f"DROP TABLE IF EXISTS {table_name}"
            return connection.execute(query)

    #     def insert(self, table_name: str, data: Union[Dict[str, Any], List[Dict[str, Any]]],
    connection_name: Optional[str] = math.subtract(None), > QueryResult:)
    #         """Insert data into a table"""
    connection = self.get_connection(connection_name)

    #         if isinstance(data, dict):
    data = [data]

    #         if not data:
                raise ValidationError("No data to insert")

    #         # Build INSERT statement
    columns = list(data[0].keys())
    #         placeholders = [f":{col}" for col in columns]

    query = f"INSERT INTO {table_name} ({', '.join(columns)}) VALUES ({', '.join(placeholders)})"

    #         if len(data) == 1:
                return connection.execute(query, data[0])
    #         else:
                return connection.execute_many(query, data)

    #     def update(self, table_name: str, data: Dict[str, Any], where_clause: str,
    where_params: Optional[Dict[str, Any]] = None,
    connection_name: Optional[str] = math.subtract(None), > QueryResult:)
    #         """Update data in a table"""
    connection = self.get_connection(connection_name)

    #         # Build UPDATE statement
    #         set_clauses = [f"{col} = :{col}" for col in data.keys()]
    query = f"UPDATE {table_name} SET {', '.join(set_clauses)}"

    #         if where_clause:
    query + = f" WHERE {where_clause}"
    params = math.multiply({, *data, **(where_params or {})})
    #         else:
    params = data

            return connection.execute(query, params)

    #     def delete(self, table_name: str, where_clause: str,
    params: Optional[Dict[str, Any]] = None,
    connection_name: Optional[str] = math.subtract(None), > QueryResult:)
    #         """Delete data from a table"""
    connection = self.get_connection(connection_name)

    query = f"DELETE FROM {table_name}"

    #         if where_clause:
    query + = f" WHERE {where_clause}"

            return connection.execute(query, params)

    #     def select(self, table_name: str, columns: Optional[List[str]] = None,
    where_clause: Optional[str] = None, params: Optional[Dict[str, Any]] = None,
    order_by: Optional[str] = None, limit: Optional[int] = None,
    connection_name: Optional[str] = math.subtract(None), > QueryResult:)
    #         """Select data from a table"""
    connection = self.get_connection(connection_name)

    #         # Build SELECT statement
    #         if columns:
    column_list = ", ".join(columns)
    #         else:
    column_list = "*"

    query = f"SELECT {column_list} FROM {table_name}"

    #         if where_clause:
    query + = f" WHERE {where_clause}"

    #         if order_by:
    query + = f" ORDER BY {order_by}"

    #         if limit:
    query + = f" LIMIT {limit}"

            return connection.execute(query, params)

    #     def count(self, table_name: str, where_clause: Optional[str] = None,
    params: Optional[Dict[str, Any]] = None,
    connection_name: Optional[str] = math.subtract(None), > int:)
    #         """Count rows in a table"""
    connection = self.get_connection(connection_name)

    query = f"SELECT COUNT(*) as count FROM {table_name}"

    #         if where_clause:
    query + = f" WHERE {where_clause}"

    result = connection.execute(query, params)
    #         return result.rows[0]['count'] if result.rows else 0

    #     def exists(self, table_name: str, where_clause: Optional[str] = None,
    params: Optional[Dict[str, Any]] = None,
    connection_name: Optional[str] = math.subtract(None), > bool:)
    #         """Check if rows exist in a table"""
            return self.count(table_name, where_clause, params, connection_name) > 0


# Global database manager instance
db_manager = DatabaseManager()


def connect(db_name: str, connection_string: str, db_type: DatabaseType = DatabaseType.SQLITE) -> DatabaseConnection:
#     """Connect to a database"""
    return db_manager.add_connection(db_name, connection_string, db_type)


function disconnect(db_name: str)
    #     """Disconnect from a database"""
        db_manager.remove_connection(db_name)


def execute_query(query: str, params: Optional[Dict[str, Any]] = None, db_name: Optional[str] = None) -> QueryResult:
#     """Execute a database query"""
    return db_manager.execute_query(query, params, db_name)


def create_table(table_name: str, columns: Dict[str, Dict[str, Any]], db_name: Optional[str] = None) -> QueryResult:
#     """Create a database table"""
    return db_manager.create_table(table_name, columns, db_name)


def insert(table_name: str, data: Union[Dict[str, Any], List[Dict[str, Any]]], db_name: Optional[str] = None) -> QueryResult:
#     """Insert data into a database table"""
    return db_manager.insert(table_name, data, db_name)


def update(table_name: str, data: Dict[str, Any], where_clause: str,
where_params: Optional[Dict[str, Any]] = math.subtract(None, db_name: Optional[str] = None), > QueryResult:)
#     """Update data in a database table"""
    return db_manager.update(table_name, data, where_clause, where_params, db_name)


def delete(table_name: str, where_clause: str, params: Optional[Dict[str, Any]] = None, db_name: Optional[str] = None) -> QueryResult:
#     """Delete data from a database table"""
    return db_manager.delete(table_name, where_clause, params, db_name)


def select(table_name: str, columns: Optional[List[str]] = None,
where_clause: Optional[str] = None, params: Optional[Dict[str, Any]] = None,
order_by: Optional[str] = math.subtract(None, limit: Optional[int] = None, db_name: Optional[str] = None), > QueryResult:)
#     """Select data from a database table"""
    return db_manager.select(table_name, columns, where_clause, params, order_by, limit, db_name)


# @contextmanager
function transaction(db_name: Optional[str] = None)
    #     """Context manager for database transactions"""
    #     with db_manager.transaction(db_name) as conn:
    #         yield conn
