"""
TRM Parser Component
Parses Python code to Abstract Syntax Trees (AST)
Copyright (c) 2025 Michael van Erp. All rights reserved.
"""

import ast
import logging
import time
from typing import Optional, Any
from dataclasses import dataclass

logger = logging.getLogger(__name__)


@dataclass
class ParseResult:
    """Result of a parse operation"""

    module_name: str
    ast: dict[str, Any]
    success: bool
    error: Optional[str] = None
    parse_time: float = 0.0


class TRMParser:
    """
    TRM Parser Component

    Responsible for parsing Python code to Abstract Syntax Trees (AST)
    and preparing for translation to intermediate representation.
    """

    def __init__(self, cache_size: int = 1000):
        """
        Initialize the parser

        Args:
            cache_size: Maximum number of parsed ASTs to cache
        """
        self.parse_cache: dict[str, ParseResult] = {}
        self.cache_size = cache_size
        self.stats = {
            'total_parses': 0,
            'cache_hits': 0,
            'successful_parses': 0,
            'failed_parses': 0
        }
        logger.info(f"TRM Parser initialized with cache size {cache_size}")

    async def parse_async(self, code: str, module_name: str = "module") -> ParseResult:
        """
        Parse Python code to AST asynchronously

        Args:
            code: Python source code
            module_name: Name of the module being parsed

        Returns:
            ParseResult containing AST and metadata
        """
        self.stats['total_parses'] += 1
        start_time = time.time()

        # Check cache
        code_hash = hash(code)
        if code_hash in self.parse_cache:
            self.stats['cache_hits'] += 1
            result = self.parse_cache[code_hash]
            logger.debug(f"Cache hit for {module_name}")
            return result

        try:
            # Parse code to AST
            tree = ast.parse(code)
            ast_dict = self._ast_to_dict(tree)

            parse_time = time.time() - start_time
            result = ParseResult(
                module_name=module_name,
                ast=ast_dict,
                success=True,
                parse_time=parse_time
            )

            # Cache result
            self._cache_result(code_hash, result)
            self.stats['successful_parses'] += 1

            logger.info(f"Parsed {module_name} in {parse_time:.3f}s")
            return result

        except SyntaxError as e:
            parse_time = time.time() - start_time
            self.stats['failed_parses'] += 1
            error_msg = f"Syntax error at line {e.lineno}: {e.msg}"
            logger.error(error_msg)

            return ParseResult(
                module_name=module_name,
                ast={},
                success=False,
                error=error_msg,
                parse_time=parse_time
            )

    def _ast_to_dict(self, node: ast.AST) -> dict[str, Any]:
        """Convert AST node to dictionary"""
        return {
            'type': node.__class__.__name__,
            'fields': {
                field: getattr(node, field)
                for field in node._fields
                if hasattr(node, field)
            }
        }

    def _cache_result(self, code_hash: int, result: ParseResult):
        """Cache parse result"""
        if len(self.parse_cache) >= self.cache_size:
            # Remove oldest entry
            oldest_key = next(iter(self.parse_cache))
            del self.parse_cache[oldest_key]

        self.parse_cache[code_hash] = result

    def clear_cache(self):
        """Clear the parse cache"""
        self.parse_cache.clear()
        logger.info("Parse cache cleared")

    def get_stats(self) -> dict[str, int]:
        """Get parser statistics"""
        return self.stats.copy()

    def __str__(self) -> str:
        """String representation"""
        return f"TRMParser(cache={len(self.parse_cache)}, successful={self.stats['successful_parses']})"

    def __repr__(self) -> str:
        """Debug representation"""
        return f"TRMParser(cache_size={len(self.parse_cache)}, stats={self.stats})"
