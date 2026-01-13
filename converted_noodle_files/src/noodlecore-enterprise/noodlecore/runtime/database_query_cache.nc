# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Database Query Cache for NoodleCore Runtime
# ------------------------------------------
# This module provides database query caching functionality for the NoodleCore runtime.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import typing.Any,


class DatabaseQueryCache
    #     """
    #     Database query cache for NoodleCore runtime

    #     This class provides caching functionality for database queries to improve
    #     performance by avoiding repeated execution of the same queries.
    #     """

    #     def __init__(self, max_size: int = 1000):
    #         """Initialize the database query cache"""
    self.max_size = max_size
    self._cache: Dict[str, Any] = {}
    self._access_order: List[str] = []

    #     def get(self, query: str) -> Optional[Any]:
    #         """Get cached result for a query"""
    #         if query in self._cache:
    #             # Update access order for LRU
                self._access_order.remove(query)
                self._access_order.append(query)
    #             return self._cache[query]
    #         return None

    #     def set(self, query: str, result: Any) -> None:
    #         """Set cached result for a query"""
    #         # If cache is full, remove oldest entry
    #         if len(self._cache) >= self.max_size and query not in self._cache:
    oldest = self._access_order.pop(0)
    #             del self._cache[oldest]

    #         # Add or update entry
    #         if query in self._cache:
                self._access_order.remove(query)

    self._cache[query] = result
            self._access_order.append(query)

    #     def clear(self) -> None:
    #         """Clear the cache"""
            self._cache.clear()
            self._access_order.clear()

    #     def size(self) -> int:
    #         """Get the current cache size"""
            return len(self._cache)