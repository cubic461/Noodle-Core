"""
TRM Feedback Component
Collects and analyzes feedback for continuous improvement
Copyright (c) 2025 Michael van Erp. All rights reserved.
"""

import logging
import json
from typing import Optional, Any
from dataclasses import dataclass
from pathlib import Path

logger = logging.getLogger(__name__)


@dataclass
class FeedbackEntry:
    """Single feedback entry"""
    code_hash: int
    ast_size: int
    ir_size: int
    optimization_gain: float
    timestamp: float


class TRMFeedback:
    """
    TRM Feedback Component

    Collects and analyzes performance feedback for continuous improvement.
    """

    def __init__(self, storage_path: Optional[str] = None):
        """
        Initialize the feedback component

        Args:
            storage_path: Path to store feedback data (optional)
        """
        self.storage_path = storage_path
        self.feedback_data: list[FeedbackEntry] = []
        self.stats = {
            'total_feedback_entries': 0,
            'average_optimization_gain': 0.0
        }
        logger.info("TRM Feedback component initialized")

    async def record_performance(self,
                                code_hash: int,
                                ast_size: int,
                                ir_size: int,
                                optimization_gain: float):
        """
        Record performance feedback

        Args:
            code_hash: Hash of the code
            ast_size: Size of AST
            ir_size: Size of IR
            optimization_gain: Optimization improvement achieved
        """
        import time

        entry = FeedbackEntry(
            code_hash=code_hash,
            ast_size=ast_size,
            ir_size=ir_size,
            optimization_gain=optimization_gain,
            timestamp=time.time()
        )

        self.feedback_data.append(entry)
        self.stats['total_feedback_entries'] += 1

        # Update average
        total_gain = sum(e.optimization_gain for e in self.feedback_data)
        self.stats['average_optimization_gain'] = total_gain / len(self.feedback_data)

        logger.debug(f"Recorded feedback: gain={optimization_gain:.3f}")

    async def get_feedback_data(self) -> list[dict[str, Any]]:
        """Get all feedback data as dictionaries"""
        return [
            {
                'code_hash': entry.code_hash,
                'ast_size': entry.ast_size,
                'ir_size': entry.ir_size,
                'optimization_gain': entry.optimization_gain,
                'timestamp': entry.timestamp
            }
            for entry in self.feedback_data
        ]

    async def cleanup(self):
        """Cleanup resources"""
        if self.storage_path and self.feedback_data:
            # Save to disk
            Path(self.storage_path).write_text(
                json.dumps([entry.__dict__ for entry in self.feedback_data]),
                encoding='utf-8'
            )
            logger.info(f"Saved {len(self.feedback_data)} feedback entries")

    def get_stats(self) -> dict[str, Any]:
        """Get feedback statistics"""
        return self.stats.copy()
