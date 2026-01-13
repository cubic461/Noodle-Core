# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# TRM-Agent Recursive Reasoning Engine
 = ==================================

# This module provides the recursive reasoning engine for TRM-Agent,
# implementing intelligent optimization decisions through pattern recognition,
# strategic planning, and recursive decision-making.

# Key Features:
# - Pattern recognition for code optimization
# - Strategic optimization planning
# - Recursive decision-making with confidence scoring
# - Multi-objective optimization
# """

import logging
import time
import typing.Any,
import dataclasses.dataclass,
import enum.Enum
import abc.ABC,

import .trm_agent_base.OptimizationType,

# Configure logging
logger = logging.getLogger(__name__)


class ReasoningStrategy(Enum)
    #     """Reasoning strategies for optimization decisions."""
    PATTERN_BASED = "pattern_based"
    PERFORMANCE_DRIVEN = "performance_driven"
    MEMORY_OPTIMIZED = "memory_optimized"
    BALANCED = "balanced"
    AGGRESSIVE = "aggressive"
    CONSERVATIVE = "conservative"


class OptimizationPattern(Enum)
    #     """Common optimization patterns recognized by the reasoning engine."""
    LOOP_OPTIMIZATION = "loop_optimization"
    MEMORY_ALLOCATION = "memory_allocation"
    FUNCTION_INLINING = "function_inlining"
    DEAD_CODE_ELIMINATION = "dead_code_elimination"
    CONSTANT_PROPAGATION = "constant_propagation"
    TAIL_CALL_OPTIMIZATION = "tail_call_optimization"
    VECTORIZATION = "vectorization"
    PARALLELIZATION = "parallelization"


# @dataclass
class ReasoningContext
    #     """Context for reasoning decisions."""
    #     code_complexity: float
    #     execution_frequency: float
    #     memory_pressure: float
    #     cpu_usage: float
    historical_performance: Dict[str, float] = field(default_factory=dict)
    optimization_history: List[str] = field(default_factory=list)
    target_metrics: List[str] = field(default_factory=list)


# @dataclass
class ReasoningResult
    #     """Result of reasoning process."""
    #     strategy: ReasoningStrategy
    #     confidence: float
    #     optimization_patterns: List[OptimizationPattern]
    #     expected_improvement: Dict[str, float]
    #     reasoning_steps: List[str]
    #     execution_time: float
    metadata: Dict[str, Any] = field(default_factory=dict)


class PatternRecognizer(ABC)
    #     """Abstract base class for pattern recognition."""

    #     @abstractmethod
    #     def recognize_patterns(self, code_ir: Any, context: ReasoningContext) -> List[OptimizationPattern]:
    #         """Recognize optimization patterns in code."""
    #         pass


class OptimizationStrategist(ABC)
    #     """Abstract base class for optimization strategy development."""

    #     @abstractmethod
    #     def develop_strategy(self, patterns: List[OptimizationPattern],
    #                       context: ReasoningContext) -> ReasoningStrategy:
    #         """Develop optimization strategy based on patterns."""
    #         pass


class DecisionMaker(ABC)
    #     """Abstract base class for decision making."""

    #     @abstractmethod
    #     def make_decision(self, strategy: ReasoningStrategy,
    #                     patterns: List[OptimizationPattern],
    #                     context: ReasoningContext) -> ReasoningResult:
    #         """Make optimization decision based on strategy and patterns."""
    #         pass


class DefaultPatternRecognizer(PatternRecognizer)
    #     """Default implementation of pattern recognizer."""

    #     def __init__(self):
    self.logger = logging.getLogger(f"{__name__}.DefaultPatternRecognizer")
    self.pattern_weights = {
    #             OptimizationPattern.LOOP_OPTIMIZATION: 0.9,
    #             OptimizationPattern.MEMORY_ALLOCATION: 0.8,
    #             OptimizationPattern.FUNCTION_INLINING: 0.7,
    #             OptimizationPattern.DEAD_CODE_ELIMINATION: 0.6,
    #             OptimizationPattern.CONSTANT_PROPAGATION: 0.5,
    #             OptimizationPattern.TAIL_CALL_OPTIMIZATION: 0.4,
    #             OptimizationPattern.VECTORIZATION: 0.8,
    #             OptimizationPattern.PARALLELIZATION: 0.7
    #         }

    #     def recognize_patterns(self, code_ir: Any, context: ReasoningContext) -> List[OptimizationPattern]:
    #         """Recognize optimization patterns in code IR."""
    patterns = []

    #         try:
    #             # Analyze code complexity for pattern recognition
    #             if context.code_complexity > 7.0:
                    patterns.append(OptimizationPattern.LOOP_OPTIMIZATION)
                    patterns.append(OptimizationPattern.FUNCTION_INLINING)

    #             # Memory pressure analysis
    #             if context.memory_pressure > 80.0:
                    patterns.append(OptimizationPattern.MEMORY_ALLOCATION)
                    patterns.append(OptimizationPattern.DEAD_CODE_ELIMINATION)

    #             # Execution frequency analysis
    #             if context.execution_frequency > 100.0:
                    patterns.append(OptimizationPattern.VECTORIZATION)
                    patterns.append(OptimizationPattern.PARALLELIZATION)

    #             # CPU usage analysis
    #             if context.cpu_usage > 85.0:
                    patterns.append(OptimizationPattern.CONSTANT_PROPAGATION)
                    patterns.append(OptimizationPattern.TAIL_CALL_OPTIMIZATION)

    #             # Historical performance analysis
    #             if context.historical_performance.get('execution_time', 0) > 1.0:
                    patterns.append(OptimizationPattern.LOOP_OPTIMIZATION)
                    patterns.append(OptimizationPattern.VECTORIZATION)

                # Sort patterns by weight (importance)
    patterns.sort(key = lambda p: self.pattern_weights.get(p, 0.5), reverse=True)

                self.logger.debug(f"Recognized {len(patterns)} optimization patterns")
    #             return patterns

    #         except Exception as e:
                self.logger.error(f"Error recognizing patterns: {str(e)}")
    #             return []


class DefaultOptimizationStrategist(OptimizationStrategist)
    #     """Default implementation of optimization strategist."""

    #     def __init__(self):
    self.logger = logging.getLogger(f"{__name__}.DefaultOptimizationStrategist")
    self.strategy_rules = {
    #             ReasoningStrategy.PATTERN_BASED: self._pattern_based_strategy,
    #             ReasoningStrategy.PERFORMANCE_DRIVEN: self._performance_driven_strategy,
    #             ReasoningStrategy.MEMORY_OPTIMIZED: self._memory_optimized_strategy,
    #             ReasoningStrategy.BALANCED: self._balanced_strategy,
    #             ReasoningStrategy.AGGRESSIVE: self._aggressive_strategy,
    #             ReasoningStrategy.CONSERVATIVE: self._conservative_strategy
    #         }

    #     def develop_strategy(self, patterns: List[OptimizationPattern],
    #                       context: ReasoningContext) -> ReasoningStrategy:
    #         """Develop optimization strategy based on patterns and context."""
    #         try:
    #             # Analyze context to determine optimal strategy
    #             if context.memory_pressure > 90.0:
    #                 return ReasoningStrategy.MEMORY_OPTIMIZED
    #             elif context.cpu_usage > 90.0:
    #                 return ReasoningStrategy.PERFORMANCE_DRIVEN
    #             elif context.code_complexity > 8.0:
    #                 return ReasoningStrategy.AGGRESSIVE
    #             elif context.code_complexity < 3.0:
    #                 return ReasoningStrategy.CONSERVATIVE
    #             else:
    #                 return ReasoningStrategy.BALANCED

    #         except Exception as e:
                self.logger.error(f"Error developing strategy: {str(e)}")
    #             return ReasoningStrategy.BALANCED

    #     def _pattern_based_strategy(self, patterns: List[OptimizationPattern],
    #                               context: ReasoningContext) -> Dict[str, Any]:
    #         """Pattern-based strategy implementation."""
    #         return {
    #             'focus': 'pattern_recognition',
    #             'weight': 0.8,
    #             'patterns': patterns
    #         }

    #     def _performance_driven_strategy(self, patterns: List[OptimizationPattern],
    #                                  context: ReasoningContext) -> Dict[str, Any]:
    #         """Performance-driven strategy implementation."""
    #         return {
    #             'focus': 'execution_speed',
    #             'weight': 0.9,
    #             'patterns': [p for p in patterns if p in [
    #                 OptimizationPattern.VECTORIZATION,
    #                 OptimizationPattern.PARALLELIZATION,
    #                 OptimizationPattern.LOOP_OPTIMIZATION
    #             ]]
    #         }

    #     def _memory_optimized_strategy(self, patterns: List[OptimizationPattern],
    #                                context: ReasoningContext) -> Dict[str, Any]:
    #         """Memory-optimized strategy implementation."""
    #         return {
    #             'focus': 'memory_efficiency',
    #             'weight': 0.9,
    #             'patterns': [p for p in patterns if p in [
    #                 OptimizationPattern.MEMORY_ALLOCATION,
    #                 OptimizationPattern.DEAD_CODE_ELIMINATION,
    #                 OptimizationPattern.CONSTANT_PROPAGATION
    #             ]]
    #         }

    #     def _balanced_strategy(self, patterns: List[OptimizationPattern],
    #                          context: ReasoningContext) -> Dict[str, Any]:
    #         """Balanced strategy implementation."""
    #         return {
    #             'focus': 'balanced_optimization',
    #             'weight': 0.7,
    #             'patterns': patterns
    #         }

    #     def _aggressive_strategy(self, patterns: List[OptimizationPattern],
    #                            context: ReasoningContext) -> Dict[str, Any]:
    #         """Aggressive strategy implementation."""
    #         return {
    #             'focus': 'maximum_optimization',
    #             'weight': 1.0,
    #             'patterns': patterns * 2  # Duplicate patterns for aggressive optimization
    #         }

    #     def _conservative_strategy(self, patterns: List[OptimizationPattern],
    #                              context: ReasoningContext) -> Dict[str, Any]:
    #         """Conservative strategy implementation."""
    #         return {
    #             'focus': 'safe_optimization',
    #             'weight': 0.5,
    #             'patterns': patterns[:2]  # Limit to first 2 patterns
    #         }


class DefaultDecisionMaker(DecisionMaker)
    #     """Default implementation of decision maker."""

    #     def __init__(self):
    self.logger = logging.getLogger(f"{__name__}.DefaultDecisionMaker")
    self.confidence_thresholds = {
    #             ReasoningStrategy.PATTERN_BASED: 0.7,
    #             ReasoningStrategy.PERFORMANCE_DRIVEN: 0.8,
    #             ReasoningStrategy.MEMORY_OPTIMIZED: 0.8,
    #             ReasoningStrategy.BALANCED: 0.6,
    #             ReasoningStrategy.AGGRESSIVE: 0.5,
    #             ReasoningStrategy.CONSERVATIVE: 0.9
    #         }

    #     def make_decision(self, strategy: ReasoningStrategy,
    #                     patterns: List[OptimizationPattern],
    #                     context: ReasoningContext) -> ReasoningResult:
    #         """Make optimization decision based on strategy and patterns."""
    start_time = time.time()

    #         try:
    #             # Calculate confidence based on strategy and context
    confidence = self._calculate_confidence(strategy, patterns, context)

    #             # Generate reasoning steps
    reasoning_steps = self._generate_reasoning_steps(strategy, patterns, context)

    #             # Predict expected improvements
    expected_improvement = self._predict_improvement(strategy, patterns, context)

    execution_time = math.subtract(time.time(), start_time)

    result = ReasoningResult(
    strategy = strategy,
    confidence = confidence,
    optimization_patterns = patterns,
    expected_improvement = expected_improvement,
    reasoning_steps = reasoning_steps,
    execution_time = execution_time,
    metadata = {
    #                     'context_complexity': context.code_complexity,
                        'pattern_count': len(patterns),
                        'strategy_weight': self.confidence_thresholds.get(strategy, 0.7)
    #                 }
    #             )

    #             self.logger.debug(f"Decision made: {strategy.value} with confidence {confidence:.2f}")
    #             return result

    #         except Exception as e:
    execution_time = math.subtract(time.time(), start_time)
                self.logger.error(f"Error making decision: {str(e)}")

                return ReasoningResult(
    strategy = ReasoningStrategy.CONSERVATIVE,
    confidence = 0.3,
    optimization_patterns = [],
    expected_improvement = {},
    reasoning_steps = [f"Error in decision making: {str(e)}", "Using conservative fallback"],
    execution_time = execution_time,
    metadata = {'error': str(e)}
    #             )

    #     def _calculate_confidence(self, strategy: ReasoningStrategy,
    #                            patterns: List[OptimizationPattern],
    #                            context: ReasoningContext) -> float:
    #         """Calculate confidence score for decision."""
    base_confidence = self.confidence_thresholds.get(strategy, 0.7)

    #         # Adjust confidence based on pattern count
    pattern_factor = math.divide(min(len(patterns), 5.0, 1.0))

    #         # Adjust confidence based on context
    context_factor = 1.0
    #         if context.code_complexity > 8.0:
    #             context_factor *= 0.9  # Lower confidence for complex code
    #         if context.memory_pressure > 90.0:
    context_factor * = 0.8  # Lower confidence under memory pressure

    #         # Adjust confidence based on historical performance
    history_factor = 1.0
    #         if context.historical_performance:
    avg_performance = math.divide(sum(context.historical_performance.values()), len(context.historical_performance))
    #             if avg_performance > 2.0:  # Poor historical performance
    history_factor * = 0.8

    confidence = math.multiply(base_confidence, pattern_factor * context_factor * history_factor)
            return max(0.1, min(1.0, confidence))

    #     def _generate_reasoning_steps(self, strategy: ReasoningStrategy,
    #                                 patterns: List[OptimizationPattern],
    #                                 context: ReasoningContext) -> List[str]:
    #         """Generate reasoning steps for decision."""
    steps = []

    #         # Strategy-based reasoning
            steps.append(f"Selected strategy: {strategy.value}")

    #         # Pattern-based reasoning
    #         if patterns:
                steps.append(f"Identified {len(patterns)} optimization patterns")
    #             for pattern in patterns[:3]:  # Limit to top 3 patterns
                    steps.append(f"Pattern: {pattern.value}")

    #         # Context-based reasoning
    #         if context.code_complexity > 7.0:
                steps.append("High complexity detected - aggressive optimization recommended")
    #         elif context.code_complexity < 3.0:
                steps.append("Low complexity detected - conservative optimization sufficient")

    #         if context.memory_pressure > 80.0:
                steps.append("High memory pressure - memory optimization prioritized")

    #         if context.cpu_usage > 85.0:
                steps.append("High CPU usage - performance optimization prioritized")

    #         # Historical reasoning
    #         if context.historical_performance:
                steps.append("Historical performance data considered")

    #         return steps

    #     def _predict_improvement(self, strategy: ReasoningStrategy,
    #                            patterns: List[OptimizationPattern],
    #                            context: ReasoningContext) -> Dict[str, float]:
    #         """Predict expected improvements from optimization."""
    improvements = {}

    #         # Base improvements by strategy
    strategy_improvements = {
    #             ReasoningStrategy.PATTERN_BASED: {'execution_time': 0.15, 'memory_usage': 0.10},
    #             ReasoningStrategy.PERFORMANCE_DRIVEN: {'execution_time': 0.25, 'memory_usage': 0.05},
    #             ReasoningStrategy.MEMORY_OPTIMIZED: {'execution_time': 0.10, 'memory_usage': 0.20},
    #             ReasoningStrategy.BALANCED: {'execution_time': 0.15, 'memory_usage': 0.15},
    #             ReasoningStrategy.AGGRESSIVE: {'execution_time': 0.30, 'memory_usage': 0.25},
    #             ReasoningStrategy.CONSERVATIVE: {'execution_time': 0.08, 'memory_usage': 0.08}
    #         }

            improvements.update(strategy_improvements.get(strategy, {}))

    #         # Adjust based on patterns
    pattern_multiplier = math.add(1.0, (len(patterns) * 0.05))
    #         for key in improvements:
    improvements[key] * = pattern_multiplier

    #         # Adjust based on context
    #         if context.code_complexity > 8.0:
    #             improvements['execution_time'] *= 1.2  # More improvement for complex code

    #         if context.memory_pressure > 90.0:
    #             improvements['memory_usage'] *= 1.3  # More improvement for memory pressure

    #         return improvements


class RecursiveReasoningEngine
    #     """
    #     Main recursive reasoning engine for TRM-Agent.

    #     This class coordinates pattern recognition, strategy development,
    #     and decision making to provide intelligent optimization recommendations.
    #     """

    #     def __init__(self,
    pattern_recognizer: Optional[PatternRecognizer] = None,
    optimization_strategist: Optional[OptimizationStrategist] = None,
    decision_maker: Optional[DecisionMaker] = None):
    #         """Initialize recursive reasoning engine."""
    self.logger = logging.getLogger(__name__)

    #         # Initialize components
    self.pattern_recognizer = pattern_recognizer or DefaultPatternRecognizer()
    self.optimization_strategist = optimization_strategist or DefaultOptimizationStrategist()
    self.decision_maker = decision_maker or DefaultDecisionMaker()

    #         # Reasoning statistics
    self.reasoning_count = 0
    self.successful_reasoning = 0
    self.average_confidence = 0.0
    self.reasoning_history = []

            self.logger.info("Recursive Reasoning Engine initialized")

    #     def reason_about_optimization(self,
    #                                code_ir: Any,
    #                                context: ReasoningContext,
    max_recursion_depth: int = math.subtract(3), > ReasoningResult:)
    #         """
    #         Perform recursive reasoning about optimization.

    #         Args:
    #             code_ir: Intermediate representation of code
    #             context: Reasoning context
    #             max_recursion_depth: Maximum recursion depth

    #         Returns:
    #             ReasoningResult with optimization recommendations
    #         """
    start_time = time.time()

    #         try:
    #             self.logger.debug(f"Starting recursive reasoning with depth {max_recursion_depth}")

    #             # Base case: no more recursion
    #             if max_recursion_depth <= 0:
                    return self._create_fallback_result(code_ir, context)

    #             # Step 1: Recognize patterns
    patterns = self.pattern_recognizer.recognize_patterns(code_ir, context)

    #             # Step 2: Develop strategy
    strategy = self.optimization_strategist.develop_strategy(patterns, context)

    #             # Step 3: Make decision
    result = self.decision_maker.make_decision(strategy, patterns, context)

    #             # Step 4: Recursive refinement (if confidence is low)
    #             if result.confidence < 0.7 and max_recursion_depth > 1:
                    self.logger.debug(f"Low confidence ({result.confidence:.2f}), recursing")

    #                 # Refine context for recursive reasoning
    refined_context = self._refine_context(context, result)

    #                 # Recursive call
    recursive_result = self.reason_about_optimization(
    #                     code_ir, refined_context, max_recursion_depth - 1
    #                 )

    #                 # Combine results
    result = self._combine_results(result, recursive_result)

    #             # Update statistics
                self._update_statistics(result)

    execution_time = math.subtract(time.time(), start_time)
    result.execution_time + = execution_time

    #             self.logger.info(f"Reasoning completed in {execution_time:.3f}s with confidence {result.confidence:.2f}")
    #             return result

    #         except Exception as e:
    execution_time = math.subtract(time.time(), start_time)
                self.logger.error(f"Error in recursive reasoning: {str(e)}")

                return self._create_error_result(code_ir, context, str(e), execution_time)

    #     def _create_fallback_result(self, code_ir: Any, context: ReasoningContext) -> ReasoningResult:
    #         """Create fallback reasoning result."""
            return ReasoningResult(
    strategy = ReasoningStrategy.CONSERVATIVE,
    confidence = 0.5,
    optimization_patterns = [OptimizationPattern.DEAD_CODE_ELIMINATION],
    expected_improvement = {'execution_time': 0.05, 'memory_usage': 0.05},
    reasoning_steps = ["Using fallback conservative strategy"],
    execution_time = 0.001,
    metadata = {'fallback': True}
    #         )

    #     def _refine_context(self, context: ReasoningContext, result: ReasoningResult) -> ReasoningContext:
    #         """Refine context based on reasoning result."""
    refined_context = ReasoningContext(
    code_complexity = context.code_complexity,
    execution_frequency = context.execution_frequency,
    memory_pressure = context.memory_pressure,
    cpu_usage = context.cpu_usage,
    historical_performance = context.historical_performance.copy(),
    optimization_history = context.optimization_history.copy(),
    target_metrics = context.target_metrics.copy()
    #         )

    #         # Add reasoning result to history
            refined_context.optimization_history.append(result.strategy.value)

    #         # Adjust based on expected improvements
    #         for metric, improvement in result.expected_improvement.items():
    #             if metric in refined_context.historical_performance:
    refined_context.historical_performance[metric] * = math.subtract((1.0, improvement))

    #         return refined_context

    #     def _combine_results(self, primary: ReasoningResult, secondary: ReasoningResult) -> ReasoningResult:
    #         """Combine two reasoning results."""
    #         # Weighted average of confidences
    combined_confidence = math.add((primary.confidence * 0.7, secondary.confidence * 0.3))

    #         # Combine patterns
    combined_patterns = math.add(list(set(primary.optimization_patterns, secondary.optimization_patterns)))

    #         # Combine expected improvements
    combined_improvement = {}
    #         for key in set(primary.expected_improvement.keys() | secondary.expected_improvement.keys()):
    primary_val = primary.expected_improvement.get(key, 0.0)
    secondary_val = secondary.expected_improvement.get(key, 0.0)
    combined_improvement[key] = math.add((primary_val * 0.7, secondary_val * 0.3))

    #         # Combine reasoning steps
    combined_reasoning = primary.reasoning_steps + ["Recursive refinement applied"] + secondary.reasoning_steps

            return ReasoningResult(
    strategy = primary.strategy,  # Keep primary strategy
    confidence = combined_confidence,
    optimization_patterns = combined_patterns,
    expected_improvement = combined_improvement,
    reasoning_steps = combined_reasoning,
    execution_time = math.add(primary.execution_time, secondary.execution_time,)
    metadata = {
    #                 'combined': True,
    #                 'primary_strategy': primary.strategy.value,
    #                 'secondary_strategy': secondary.strategy.value
    #             }
    #         )

    #     def _create_error_result(self, code_ir: Any, context: ReasoningContext,
    #                            error: str, execution_time: float) -> ReasoningResult:
    #         """Create error reasoning result."""
            return ReasoningResult(
    strategy = ReasoningStrategy.CONSERVATIVE,
    confidence = 0.1,
    optimization_patterns = [],
    expected_improvement = {},
    reasoning_steps = [f"Error in reasoning: {error}", "Using minimal conservative approach"],
    execution_time = execution_time,
    metadata = {'error': error}
    #         )

    #     def _update_statistics(self, result: ReasoningResult):
    #         """Update reasoning statistics."""
    self.reasoning_count + = 1

    #         if result.confidence > 0.6:
    self.successful_reasoning + = 1

    #         # Update average confidence
    total_confidence = math.add(self.average_confidence * (self.reasoning_count - 1), result.confidence)
    self.average_confidence = math.divide(total_confidence, self.reasoning_count)

    #         # Store in history
            self.reasoning_history.append({
                'timestamp': time.time(),
    #             'strategy': result.strategy.value,
    #             'confidence': result.confidence,
                'pattern_count': len(result.optimization_patterns),
    #             'execution_time': result.execution_time
    #         })

    #         # Keep history manageable
    #         if len(self.reasoning_history) > 1000:
    self.reasoning_history = math.subtract(self.reasoning_history[, 1000:])

    #     def get_statistics(self) -> Dict[str, Any]:
    #         """Get reasoning engine statistics."""
    #         return {
    #             'reasoning_count': self.reasoning_count,
    #             'successful_reasoning': self.successful_reasoning,
                'success_rate': self.successful_reasoning / max(self.reasoning_count, 1),
    #             'average_confidence': self.average_confidence,
    #             'recent_reasonings': self.reasoning_history[-10:],
    #             'component_status': {
                    'pattern_recognizer': type(self.pattern_recognizer).__name__,
                    'optimization_strategist': type(self.optimization_strategist).__name__,
                    'decision_maker': type(self.decision_maker).__name__
    #             }
    #         }

    #     def reset_statistics(self):
    #         """Reset reasoning statistics."""
    self.reasoning_count = 0
    self.successful_reasoning = 0
    self.average_confidence = 0.0
    self.reasoning_history = []
            self.logger.info("Reasoning statistics reset")


# Global reasoning engine instance
_global_reasoning_engine: Optional[RecursiveReasoningEngine] = None


def get_recursive_reasoning_engine() -> RecursiveReasoningEngine:
#     """
#     Get the global recursive reasoning engine instance.

#     Returns:
#         RecursiveReasoningEngine instance
#     """
#     global _global_reasoning_engine
#     if _global_reasoning_engine is None:
_global_reasoning_engine = RecursiveReasoningEngine()
#     return _global_reasoning_engine