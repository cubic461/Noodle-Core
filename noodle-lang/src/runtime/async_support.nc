# Converted from Python to NoodleCore
# Original file: src

# """
# Async/Await Support for Python Interoperability
# ----------------------------------------------
# Provides async/await support for Noodle database operations.
# """

import asyncio
import time
from contextlib import asynccontextmanager
import typing.Any

import ..connection_pool.get_connection_pool_manager
import ...error.DatabaseError


class AsyncDatabaseSupport
    #     """Async/await support for database operations."""

    #     def __init__(self, pool_manager=None):
    self.pool_manager = pool_manager or get_connection_pool_manager()

    #     @asynccontextmanager
    #     async def get_async_connection(self, backend_type: str):
    #         """Async context manager for database connections."""
    conn = self.pool_manager.get_connection(backend_type)
    #         try:
    #             yield conn
    #         finally:
                self.pool_manager.release_connection(backend_type, conn)

    #     async def execute_async_query(
    self, backend_type: str, query: str, params: Optional[Dict[str, Any]] = None
    #     ) -Any):
    #         """Execute query asynchronously.

    #         Args:
    #             backend_type: Database backend type
    #             query: SQL query
    #             params: Query parameters

    #         Returns:
    #             Query result
    #         """
    #         async with self.get_async_connection(backend_type) as conn:
                return await asyncio.get_event_loop().run_in_executor(
    #                 None,
    #                 self.pool_manager.execute_optimized_query,
    #                 backend_type,
    #                 query,
    #                 params,
    #             )

    #     async def batch_insert_async(
    #         self, backend_type: str, table_name: str, data: List[Dict[str, Any]]
    #     ) -bool):
    #         """Perform batch insert asynchronously."""
    #         async with self.get_async_connection(backend_type) as conn:
                return await asyncio.get_event_loop().run_in_executor(
    #                 None, self.pool_manager.backend_execute, backend_type, table_name, data
    #             )

    #     async def query_async(
    #         self,
    #         backend_type: str,
    #         table_name: str,
    columns: Optional[List[str]] = None,
    where: Optional[Dict[str, Any]] = None,
    limit: Optional[int] = None,
    #     ) -List[Dict[str, Any]]):
    #         """Perform async query."""
    #         async with self.get_async_connection(backend_type) as conn:
                return await asyncio.get_event_loop().run_in_executor(
    #                 None,
    #                 self.pool_manager.backend_select,
    #                 backend_type,
    #                 table_name,
    #                 columns,
    #                 where,
    #                 limit,
    #             )

    #     async def transaction_async(
    #         self, backend_type: str, operations: List[Dict[str, Any]]
    #     ) -bool):
    #         """Execute transaction asynchronously."""
    #         async with self.get_async_connection(backend_type) as conn:
                return await asyncio.get_event_loop().run_in_executor(
    #                 None, self.pool_manager.backend_transaction, backend_type, operations
    #             )


# Global async support instance
async_support = AsyncDatabaseSupport()
