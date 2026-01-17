"""
TRM Translator Component
Translates AST representations to NoodleCore IR
Copyright (c) 2025 Michael van Erp. All rights reserved.
"""

import logging
import time
from typing import Optional, Any
from dataclasses import dataclass, field

logger = logging.getLogger(__name__)


@dataclass
class TranslationResult:
    """Result of a translation operation"""

    ir: dict[str, Any]
    success: bool
    error: Optional[str] = None
    metadata: dict[str, Any] = field(default_factory=dict)


class TRMTranslator:
    """
    TRM Translator Component

    Translates AST representations to NoodleCore intermediate representation (IR).
    """

    def __init__(self):
        """Initialize the translator"""
        self.translation_cache = {}
        self.stats = {
            'total_translations': 0,
            'successful_translations': 0,
            'failed_translations': 0
        }
        logger.info("TRM Translator initialized")

    async def translate_async(self, ast_data: dict[str, Any]) -> TranslationResult:
        """
        Translate AST to NoodleCore IR asynchronously

        Args:
            ast_data: Abstract Syntax Tree as dictionary

        Returns:
            TranslationResult containing IR and metadata
        """
        self.stats['total_translations'] += 1

        try:
            # Extract AST type
            node_type = ast_data.get('type', 'Module')

            # Build IR
            ir = {
                'type': 'IRModule',
                'name': 'translated_module',
                'nodes': self._translate_node(ast_data),
                'metadata': {
                    'source_type': node_type,
                    'translation_time': time.time()
                }
            }

            self.stats['successful_translations'] += 1

            return TranslationResult(
                ir=ir,
                success=True,
                metadata=ir['metadata']
            )

        except Exception as e:
            self.stats['failed_translations'] += 1
            error_msg = f"Translation error: {str(e)}"
            logger.error(error_msg)

            return TranslationResult(
                ir={},
                success=False,
                error=error_msg
            )

    def _translate_node(self, node: dict[str, Any]) -> list[dict[str, Any]]:
        """Translate AST node to IR nodes"""
        nodes = []

        # Extract fields from AST node
        fields = node.get('fields', {})

        # Process based on node type
        node_type = node.get('type', 'Unknown')

        if node_type == 'Module':
            # Module body
            body = fields.get('body', [])
            for stmt in body:
                nodes.extend(self._translate_node(stmt))

        elif node_type == 'FunctionDef':
            # Function definition
            func_ir = {
                'type': 'IRFunction',
                'name': fields.get('name', 'unknown'),
                'args': [arg.arg for arg in fields.get('args', {}).get('args', [])],
                'body': []
            }
            nodes.append(func_ir)

        return nodes

    def get_stats(self) -> dict[str, int]:
        """Get translator statistics"""
        return self.stats.copy()
