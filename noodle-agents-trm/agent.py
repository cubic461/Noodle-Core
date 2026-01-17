"""
Main TRM-Agent implementation
Copyright (c) 2025 Michael van Erp. All rights reserved.
"""

import logging
from typing import Optional, Any
from dataclasses import dataclass
from enum import Enum

from .parser import TRMParser
from .translator import TRMTranslator
from .optimizer import TRMOptimizer
from .feedback import TRMFeedback

logger = logging.getLogger(__name__)


class AgentMode(Enum):
    """Agent execution modes"""
    TRAINING = "training"
    INFERENCE = "inference"
    HYBRID = "hybrid"


@dataclass
class AgentConfig:
    """Configuration for TRM Agent"""
    bit_precision: int = 16
    learning_rate: float = 0.001
    cache_size: int = 1000
    max_iterations: int = 100
    optimization_threshold: float = 0.95


class TRMAgent:
    """
    Main TRM-Agent class that translates Python code to NoodleCore-IR
    and optimizes based on feedback.
    """

    def __init__(self,
                 mode: AgentMode = AgentMode.HYBRID,
                 model_path: Optional[str] = None,
                 bit_precision: int = 16,
                 learning_rate: float = 0.001,
                 config: Optional[dict[str, Any]] = None):
        """
        Initialize the TRM-Agent

        Args:
            mode: Execution mode (training, inference, hybrid)
            model_path: Path to pretrained model (optional)
            bit_precision: Bits for quantization (16, 8, 4, 1)
            learning_rate: Learning rate for training
            config: Extra configuration options
        """
        self.mode = mode
        self.config = config or {}

        # Initialize components
        self.parser = TRMParser()
        self.translator = TRMTranslator()
        self.optimizer = TRMOptimizer(learning_rate=learning_rate)
        self.feedback = TRMFeedback()

        # Statistics
        self.stats = {
            'total_parses': 0,
            'successful_parses': 0,
            'optimizations': 0,
            'feedback_loops': 0
        }

        logger.info(f"TRM Agent initialized in {mode.value} mode")

    async def process_code(self,
                          code: str,
                          optimize: bool = True,
                          collect_feedback: bool = True) -> dict[str, Any]:
        """
        Process Python code through the complete pipeline

        Args:
            code: Python source code
            optimize: Whether to optimize the IR
            collect_feedback: Whether to collect performance feedback

        Returns:
            Dictionary containing parsed AST, translated IR, and metrics
        """
        self.stats['total_parses'] += 1

        try:
            # Parse code to AST
            parse_result = await self.parser.parse_async(code)
            if not parse_result.success:
                return {
                    'success': False,
                    'error': parse_result.error,
                    'ast': None,
                    'ir': None
                }

            # Translate AST to IR
            ir_result = await self.translator.translate_async(parse_result.ast)

            # Optimize if requested
            if optimize and ir_result.success:
                ir_result = await self.optimizer.optimize_async(ir_result.ir)
                self.stats['optimizations'] += 1

            # Collect feedback if requested
            if collect_feedback and ir_result.success:
                await self.feedback.record_performance(
                    code_hash=hash(code),
                    ast_size=len(str(parse_result.ast)),
                    ir_size=len(str(ir_result.ir)),
                    optimization_gain=ir_result.metadata.get('improvement', 0)
                )
                self.stats['feedback_loops'] += 1

            self.stats['successful_parses'] += 1

            return {
                'success': True,
                'ast': parse_result.ast,
                'ir': ir_result.ir if ir_result.success else None,
                'metadata': ir_result.metadata if ir_result.success else {},
                'stats': self.stats.copy()
            }

        except Exception as e:
            logger.error(f"Error processing code: {e}")
            return {
                'success': False,
                'error': str(e),
                'ast': None,
                'ir': None
            }

    async def learn_from_feedback(self,
                                 min_samples: int = 100,
                                 epochs: int = 10) -> dict[str, Any]:
        """
        Learn from collected feedback data

        Args:
            min_samples: Minimum samples required for training
            epochs: Number of training epochs

        Returns:
            Training metrics and improvements
        """
        feedback_data = await self.feedback.get_feedback_data()

        if len(feedback_data) < min_samples:
            logger.warning(f"Insufficient feedback data: {len(feedback_data)} < {min_samples}")
            return {
                'success': False,
                'error': 'Insufficient feedback data',
                'samples_collected': len(feedback_data)
            }

        # Train optimizer on feedback
        training_result = await self.optimizer.train_async(
            feedback_data=feedback_data,
            epochs=epochs
        )

        return {
            'success': True,
            'epochs_completed': training_result['epochs'],
            'improvement': training_result['improvement'],
            'samples_used': len(feedback_data)
        }

    def get_stats(self) -> dict[str, Any]:
        """Get agent statistics"""
        return self.stats.copy()

    def reset_stats(self):
        """Reset agent statistics"""
        self.stats = {
            'total_parses': 0,
            'successful_parses': 0,
            'optimizations': 0,
            'feedback_loops': 0
        }
        logger.info("Agent statistics reset")

    async def cleanup(self):
        """Cleanup resources"""
        await self.parser.cleanup()
        await self.optimizer.cleanup()
        await self.feedback.cleanup()
        logger.info("TRM Agent cleanup completed")
