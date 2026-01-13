# Converted from Python to NoodleCore
# Original file: noodle-core


# """
# Adaptive Sizing Algorithms for Sheaf & Barn Memory Management

# This module implements intelligent algorithms for dynamically adjusting sheaf buffer sizes
# based on usage patterns, workload characteristics, and system metrics. The algorithms
# aim to optimize memory usage while minimizing allocation overhead and maximizing
# locality of reference.

# Key Features:
# - Dynamic sheaf size adjustment based on allocation patterns
# - Workload-aware sizing strategies
# - Memory pressure detection and response
# - Performance monitoring and optimization
# - Integration with context detection system
# """

import asyncio
import logging
import math
import time
import collections.deque
import dataclasses.dataclass
import enum.Enum
import typing.Dict,

import ..context_detector.ContextDetector,
import .region_allocator.RegionAllocator,

logger = logging.getLogger(__name__)


class SizingStrategy(Enum)
    #     """Enumeration of available sizing strategies"""
    CONSERVATIVE = "conservative"  # Small buffers, low memory usage
    BALANCED = "balanced"         # Medium buffers, balanced performance
    AGGRESSIVE = "aggressive"     # Large buffers, maximum performance
    ADAPTIVE = "adaptive"         # Dynamic adjustment based on usage
    PREDICTIVE = "predictive"     # ML-based prediction of optimal sizes


# @dataclass
class AllocationPattern
    #     """Represents allocation patterns for analysis"""
    #     size: int
    #     frequency: int
    #     locality: float  # 0.0 to 1.0, how often allocated in same region
        lifetime: float  # Average time object stays in memory (seconds)
    burstiness: float  # How bursty the allocation pattern is (0.0 = uniform, 1.0 = bursty)


# @dataclass
class SizingRecommendation
    #     """Recommendation for sheaf buffer sizing"""
    #     current_size: int
    #     recommended_size: int
    #     confidence: float  # 0.0 to 1.0
    #     reasoning: str
    #     strategy: SizingStrategy
    #     expected_performance_gain: float  # Estimated performance improvement


class AdaptiveSizingEngine
    #     """
    #     Intelligent engine for dynamically adjusting sheaf buffer sizes.

    #     This engine analyzes allocation patterns, system metrics, and workload
    #     characteristics to recommend optimal sheaf sizes for different contexts.
    #     """

    #     def __init__(self, memory_allocator: RegionAllocator, context_detector: ContextDetector):
    self.memory_allocator = memory_allocator
    self.context_detector = context_detector

    #         # Configuration parameters
    self.min_sheaf_size = 1024  # 1KB minimum
    self.max_sheaf_size = math.multiply(64, 1024 * 1024  # 64MB maximum)
    self.base_sheaf_size = math.multiply(1024, 1024  # 1MB default)
    self.size_adjustment_threshold = 0.2  # 20% change needed to adjust
    #         self.confidence_threshold = 0.7  # 70% confidence needed for changes

    #         # History tracking
    self.size_history: Dict[str, List[int]] = math.subtract({}  # actor_id, > size_history)
    self.allocation_patterns: Dict[str, List[AllocationPattern]] = {}
    self.performance_metrics: Dict[str, List[float]] = {}

    #         # Adaptive parameters
    self.learning_rate = 0.1
    self.decay_factor = 0.95  # For exponential moving averages
    #         self.prediction_window = 100  # Number of samples for prediction

    #         # Strategy state
    self.current_strategy = SizingStrategy.ADAPTIVE
    self.strategy_performance: Dict[SizingStrategy, float] = {}

    #         # Initialize strategy performance tracking
    #         for strategy in SizingStrategy:
    self.strategy_performance[strategy] = 0.5  # Neutral starting point

    #     async def analyze_allocation_patterns(self, actor_id: str) -> AllocationPattern:
    #         """
    #         Analyze allocation patterns for a specific actor.

    #         Args:
    #             actor_id: Identifier for the actor/thread

    #         Returns:
    #             Analysis of allocation patterns
    #         """
    #         if actor_id not in self.allocation_patterns:
    self.allocation_patterns[actor_id] = []

    #         # Get recent allocations from memory allocator
    #         recent_allocations = []  # Placeholder for region allocator integration

    #         if not recent_allocations:
                return AllocationPattern(
    size = self.base_sheaf_size,
    frequency = 1,
    locality = 0.5,
    lifetime = 1.0,
    burstiness = 0.0
    #             )

    #         # Calculate pattern metrics
    #         sizes = [alloc.size for alloc in recent_allocations]
    frequencies = self._calculate_frequencies(sizes)
    locality = self._calculate_locality(recent_allocations)
    lifetime = self._calculate_average_lifetime(recent_allocations)
    burstiness = self._calculate_burstiness(sizes)

    #         # Find most common allocation size
    most_common_size = max(frequencies.keys(), key=lambda k: frequencies[k])
    frequency = frequencies[most_common_size]

    pattern = AllocationPattern(
    size = most_common_size,
    frequency = frequency,
    locality = locality,
    lifetime = lifetime,
    burstiness = burstiness
    #         )

            self.allocation_patterns[actor_id].append(pattern)

    #         # Keep only recent patterns
    #         if len(self.allocation_patterns[actor_id]) > 100:
    self.allocation_patterns[actor_id] = math.subtract(self.allocation_patterns[actor_id][, 100:])

    #         return pattern

    #     def _calculate_frequencies(self, sizes: List[int]) -> Dict[int, int]:
    #         """Calculate frequency distribution of allocation sizes"""
    freq = {}
    #         for size in sizes:
    #             # Round to nearest power of 2 for bucketing
    #             bucket = 2 ** int(math.log2(size)) if size > 0 else 1
    freq[bucket] = math.add(freq.get(bucket, 0), 1)
    #         return freq

    #     def _calculate_locality(self, allocations: List) -> float:
            """Calculate locality of reference (how often allocations are in same region)"""
    #         if len(allocations) < 2:
    #             return 0.5

    same_region = 0
    total_pairs = 0

    #         for i in range(len(allocations) - 1):
    #             for j in range(i + 1, min(i + 10, len(allocations))):  # Look at next 10 allocations
    #                 if hasattr(allocations[i], 'region') and hasattr(allocations[j], 'region'):
    #                     if allocations[i].region == allocations[j].region:
    same_region + = 1
    total_pairs + = 1

    #         return same_region / total_pairs if total_pairs > 0 else 0.5

    #     def _calculate_average_lifetime(self, allocations: List) -> float:
    #         """Calculate average lifetime of allocated objects"""
    #         if not allocations:
    #             return 1.0

    lifetimes = []
    #         for alloc in allocations:
    #             if hasattr(alloc, 'allocation_time') and hasattr(alloc, 'free_time'):
    lifetime = math.subtract(alloc.free_time, alloc.allocation_time)
                    lifetimes.append(lifetime)

    #         return sum(lifetimes) / len(lifetimes) if lifetimes else 1.0

    #     def _calculate_burstiness(self, sizes: List[int]) -> float:
    #         """Calculate how bursty the allocation pattern is"""
    #         if len(sizes) < 2:
    #             return 0.0

    #         # Calculate coefficient of variation
    mean = math.divide(sum(sizes), len(sizes))
    #         variance = sum((x - mean) ** 2 for x in sizes) / len(sizes)
    std_dev = math.sqrt(variance)

    #         # Normalize to 0-1 range
    #         cv = std_dev / mean if mean > 0 else 0
            return min(1.0, cv)

    #     async def recommend_sheaf_size(self, actor_id: str) -> SizingRecommendation:
    #         """
    #         Recommend optimal sheaf size for an actor based on current conditions.

    #         Args:
    #             actor_id: Identifier for the actor/thread

    #         Returns:
    #             Sizing recommendation with reasoning and confidence
    #         """
    #         # Get current context
    context = self.context_detector.get_current_context()
    current_metrics = self.context_detector.get_current_metrics()

    #         # Analyze allocation patterns
    pattern = await self.analyze_allocation_patterns(actor_id)

            # Get current sheaf size (using allocator config as proxy)
    current_size = self.memory_allocator.config.REGION_SIZE

    #         # Calculate recommended size based on strategy
    #         if self.current_strategy == SizingStrategy.CONSERVATIVE:
    recommended_size = self._conservative_sizing(pattern, current_metrics)
    #         elif self.current_strategy == SizingStrategy.BALANCED:
    recommended_size = self._balanced_sizing(pattern, current_metrics)
    #         elif self.current_strategy == SizingStrategy.AGGRESSIVE:
    recommended_size = self._aggressive_sizing(pattern, current_metrics)
    #         elif self.current_strategy == SizingStrategy.ADAPTIVE:
    recommended_size = self._adaptive_sizing(pattern, current_metrics, context)
    #         elif self.current_strategy == SizingStrategy.PREDICTIVE:
    recommended_size = await self._predictive_sizing(actor_id, pattern, current_metrics)
    #         else:
    recommended_size = current_size

    #         # Calculate confidence
    confidence = self._calculate_confidence(actor_id, pattern, recommended_size)

    #         # Generate reasoning
    reasoning = self._generate_reasoning(pattern, context, current_metrics, recommended_size)

    #         # Calculate expected performance gain
    expected_gain = self._estimate_performance_gain(current_size, recommended_size, pattern)

            return SizingRecommendation(
    current_size = current_size,
    recommended_size = recommended_size,
    confidence = confidence,
    reasoning = reasoning,
    strategy = self.current_strategy,
    expected_performance_gain = expected_gain
    #         )

    #     def _conservative_sizing(self, pattern: AllocationPattern, metrics: ContextMetrics) -> int:
    #         """Conservative sizing strategy - small buffers, low memory usage"""
    base_size = math.multiply(max(pattern.size, 2, self.min_sheaf_size))

    #         # Reduce size under memory pressure
    #         if metrics.memory_usage > 80:
    base_size = math.multiply(int(base_size, 0.5))
    #         elif metrics.memory_usage > 60:
    base_size = math.multiply(int(base_size, 0.75))

            return min(base_size, self.max_sheaf_size)

    #     def _balanced_sizing(self, pattern: AllocationPattern, metrics: ContextMetrics) -> int:
    #         """Balanced sizing strategy - medium buffers, balanced performance"""
    base_size = math.multiply(pattern.size, 8  # 8x most common allocation size)

    #         # Adjust based on memory pressure
    #         if metrics.memory_usage > 80:
    base_size = math.multiply(int(base_size, 0.6))
    #         elif metrics.memory_usage > 60:
    base_size = math.multiply(int(base_size, 0.8))
    #         elif metrics.memory_usage < 30:
    base_size = math.multiply(int(base_size, 1.2)  # Can afford larger buffers)

            return min(max(base_size, self.min_sheaf_size), self.max_sheaf_size)

    #     def _aggressive_sizing(self, pattern: AllocationPattern, metrics: ContextMetrics) -> int:
    #         """Aggressive sizing strategy - large buffers, maximum performance"""
    base_size = math.multiply(pattern.size, 32  # 32x most common allocation size)

    #         # Only reduce under extreme memory pressure
    #         if metrics.memory_usage > 90:
    base_size = math.multiply(int(base_size, 0.4))
    #         elif metrics.memory_usage > 80:
    base_size = math.multiply(int(base_size, 0.7))

            return min(max(base_size, self.min_sheaf_size), self.max_sheaf_size)

    #     def _adaptive_sizing(self, pattern: AllocationPattern, metrics: ContextMetrics, context: dict) -> int:
    #         """Adaptive sizing strategy - dynamic adjustment based on usage"""
    #         # Base size on allocation pattern
    base_size = math.multiply(pattern.size, 16)

    #         # Adjust based on workload type
    workload_type = context.get('workload_type', WorkloadType.LOCAL)
    #         if workload_type == WorkloadType.BATCH:
    #             base_size = int(base_size * 1.2)  # Larger buffers for batch processing
    #         elif workload_type == WorkloadType.STREAMING:
    #             base_size = int(base_size * 0.8)  # Smaller buffers for streaming
    #         elif workload_type == WorkloadType.COMPUTE_INTENSIVE:
    #             base_size = int(base_size * 1.5)  # Larger buffers for compute
    #         elif workload_type == WorkloadType.MEMORY_INTENSIVE:
    #             base_size = int(base_size * 0.6)  # Smaller buffers for memory work

    #         # Adjust based on locality
    #         if pattern.locality > 0.7:  # High locality
    base_size = math.multiply(int(base_size, 1.3))
    #         elif pattern.locality < 0.3:  # Low locality
    base_size = math.multiply(int(base_size, 0.7))

    #         # Adjust based on burstiness
    #         if pattern.burstiness > 0.7:  # High burstiness
    base_size = math.multiply(int(base_size, 1.5))

    #         # Memory pressure adjustment
    #         if metrics.memory_usage > 85:
    base_size = math.multiply(int(base_size, 0.5))
    #         elif metrics.memory_usage > 70:
    base_size = math.multiply(int(base_size, 0.75))
    #         elif metrics.memory_usage < 20:
    base_size = math.multiply(int(base_size, 1.3))

            return min(max(base_size, self.min_sheaf_size), self.max_sheaf_size)

    #     async def _predictive_sizing(self, actor_id: str, pattern: AllocationPattern, metrics: ContextMetrics) -> int:
    #         """Predictive sizing strategy - ML-based prediction of optimal sizes"""
    #         # For now, use enhanced adaptive sizing with prediction elements
    #         # In a full implementation, this would use ML models

    #         # Get historical data for prediction
    #         if actor_id in self.size_history and len(self.size_history[actor_id]) > 10:
    historical_sizes = self.size_history[actor_id]

    #             # Simple trend analysis
    recent_sizes = math.subtract(historical_sizes[, 10:])
    trend = self._calculate_trend(recent_sizes)

    #             # Predict based on trend
    #             if trend > 0:  # Increasing trend
    predicted_size = math.add(int(pattern.size * 20 * (1, trend)))
    #             elif trend < 0:  # Decreasing trend
    predicted_size = math.add(int(pattern.size * 12 * (1, trend)))
    #             else:  # Stable trend
    predicted_size = math.multiply(pattern.size, 16)
    #         else:
    predicted_size = math.multiply(pattern.size, 16)

    #         # Apply same adjustments as adaptive sizing
    workload_type = self.context_detector.get_current_context().get('workload_type', WorkloadType.LOCAL)

    #         if workload_type == WorkloadType.BATCH:
    predicted_size = math.multiply(int(predicted_size, 1.2))
    #         elif workload_type == WorkloadType.STREAMING:
    predicted_size = math.multiply(int(predicted_size, 0.8))

    #         # Memory pressure adjustment
    #         if metrics.memory_usage > 85:
    predicted_size = math.multiply(int(predicted_size, 0.5))
    #         elif metrics.memory_usage > 70:
    predicted_size = math.multiply(int(predicted_size, 0.75))

            return min(max(predicted_size, self.min_sheaf_size), self.max_sheaf_size)

    #     def _calculate_trend(self, values: List[float]) -> float:
    #         """Calculate trend from a list of values"""
    #         if len(values) < 2:
    #             return 0.0

    #         # Simple linear regression
    n = len(values)
    x_sum = sum(range(n))
    y_sum = sum(values)
    #         xy_sum = sum(i * values[i] for i in range(n))
    #         x2_sum = sum(i * i for i in range(n))

    numerator = math.multiply(n, xy_sum - x_sum * y_sum)
    denominator = math.multiply(n, x2_sum - x_sum * x_sum)

    #         if denominator == 0:
    #             return 0.0

    slope = math.divide(numerator, denominator)
    #         # Normalize to -1 to 1 range
            return max(-1.0, min(1.0, slope / (max(values) - min(values) + 1e-9)))

    #     def _calculate_confidence(self, actor_id: str, pattern: AllocationPattern, recommended_size: int) -> float:
    #         """Calculate confidence in the size recommendation"""
    confidence = 0.5  # Base confidence

    #         # Increase confidence if we have good historical data
    #         if actor_id in self.size_history and len(self.size_history[actor_id]) > 20:
    confidence + = 0.2

    #         # Increase confidence if pattern is stable
    #         if actor_id in self.allocation_patterns and len(self.allocation_patterns[actor_id]) > 10:
    recent_patterns = math.subtract(self.allocation_patterns[actor_id][, 10:])
    #             size_variance = sum(p.size for p in recent_patterns) / len(recent_patterns)
    #             if size_variance < pattern.size * 0.1:  # Low variance
    confidence + = 0.2

    #         # Increase confidence if recommendation is within reasonable bounds
    #         if self.min_sheaf_size <= recommended_size <= self.max_sheaf_size:
    confidence + = 0.1

            return min(1.0, confidence)

    #     def _generate_reasoning(self, pattern: AllocationPattern, context: dict, metrics: ContextMetrics, recommended_size: int) -> str:
    #         """Generate human-readable reasoning for size recommendation"""
    reasoning = []

    #         # Base reasoning
            reasoning.append(f"Based on allocation pattern (size: {pattern.size}, freq: {pattern.frequency})")

    #         # Context reasoning
    workload_type = context.get('workload_type', WorkloadType.LOCAL)
            reasoning.append(f"Workload type: {workload_type.value}")

    #         # Memory pressure reasoning
    #         if metrics.memory_usage > 80:
                reasoning.append("High memory pressure detected - reducing size")
    #         elif metrics.memory_usage < 30:
    #             reasoning.append("Low memory pressure - increasing size for performance")

    #         # Pattern reasoning
    #         if pattern.locality > 0.7:
                reasoning.append("High locality detected - increasing buffer size")
    #         elif pattern.locality < 0.3:
                reasoning.append("Low locality detected - reducing buffer size")

    #         if pattern.burstiness > 0.7:
                reasoning.append("High burstiness detected - increasing buffer size")

    #         # Strategy reasoning
            reasoning.append(f"Strategy: {self.current_strategy.value}")

            return "; ".join(reasoning)

    #     def _estimate_performance_gain(self, current_size: int, recommended_size: int, pattern: AllocationPattern) -> float:
    #         """Estimate performance improvement from size change"""
    #         if current_size == recommended_size:
    #             return 0.0

    #         # Simple heuristic: larger buffers reduce allocation frequency
    size_ratio = math.divide(recommended_size, current_size)

    #         if size_ratio > 1.0:  # Increasing size
    #             # Estimate reduction in allocation frequency
    reduction = math.multiply(min(0.5, (size_ratio - 1.0), 0.3))
    #             return reduction
    #         else:  # Decreasing size
    #             # Estimate increase in allocation frequency but save memory
    memory_saving = math.subtract((current_size, recommended_size) / current_size)
    #             return -memory_saving * 0.5  # Trade memory for performance

    #     async def apply_sizing_recommendation(self, actor_id: str, recommendation: SizingRecommendation) -> bool:
    #         """
    #         Apply a sizing recommendation to an actor's sheaf.

    #         Args:
    #             actor_id: Identifier for the actor/thread
    #             recommendation: Sizing recommendation to apply

    #         Returns:
    #             True if successfully applied, False otherwise
    #         """
    #         if recommendation.confidence < self.confidence_threshold:
    #             logger.warning(f"Low confidence ({recommendation.confidence:.2f}) for size recommendation on {actor_id}")
    #             return False

    #         if abs(recommendation.recommended_size - recommendation.current_size) / recommendation.current_size < self.size_adjustment_threshold:
    #             logger.debug(f"Size change too small ({recommendation.recommended_size} vs {recommendation.current_size}) for {actor_id}")
    #             return False

    #         try:
                # Apply the new size (update allocator config)
    old_size = self.memory_allocator.config.REGION_SIZE
    self.memory_allocator.config.REGION_SIZE = recommendation.recommended_size
    #             success = True  # Assume success for testing

    #             if success:
    #                 # Record the change
    #                 if actor_id not in self.size_history:
    self.size_history[actor_id] = []

                    self.size_history[actor_id].append(recommendation.recommended_size)

    #                 # Keep history manageable
    #                 if len(self.size_history[actor_id]) > 1000:
    self.size_history[actor_id] = math.subtract(self.size_history[actor_id][, 1000:])

                    logger.info(f"Applied sheaf size {recommendation.recommended_size} to {actor_id} (was {recommendation.current_size})")
    #                 return True
    #             else:
    #                 logger.error(f"Failed to resize sheaf for {actor_id}")
    #                 return False

    #         except Exception as e:
                logger.error(f"Error applying sizing recommendation to {actor_id}: {e}")
    #             return False

    #     async def monitor_and_adjust(self, interval: float = 5.0):
    #         """
    #         Continuously monitor and adjust sheaf sizes.

    #         Args:
    #             interval: Monitoring interval in seconds
    #         """
            logger.info("Starting adaptive sizing monitor")

    #         while True:
    #             try:
                    # Get all active actors (using allocator regions as proxy)
    #                 active_actors = [f"actor_{i}" for i in range(len(self.memory_allocator.regions))]

    #                 # Process each actor
    #                 for actor_id in active_actors:
    #                     try:
    #                         # Get recommendation
    recommendation = await self.recommend_sheaf_size(actor_id)

    #                         # Apply if confident
    #                         if recommendation.confidence >= self.confidence_threshold:
                                await self.apply_sizing_recommendation(actor_id, recommendation)

    #                     except Exception as e:
                            logger.error(f"Error processing actor {actor_id}: {e}")
    #                         continue

    #                 # Update strategy performance
                    await self._update_strategy_performance()

    #                 # Wait for next interval
                    await asyncio.sleep(interval)

    #             except Exception as e:
                    logger.error(f"Error in adaptive sizing monitor: {e}")
                    await asyncio.sleep(interval)

    #     async def _update_strategy_performance(self):
    #         """Update performance metrics for different sizing strategies"""
    #         # This would analyze actual performance data
    #         # For now, use a simple simulation

    #         # Get current system metrics
    metrics = self.context_detector.get_current_metrics()

    #         # Calculate strategy scores based on current conditions
    #         for strategy in SizingStrategy:
    score = 0.5  # Base score

    #             # Adjust based on memory usage
    #             if strategy == SizingStrategy.CONSERVATIVE:
    score + = math.multiply((100 - metrics.memory_usage) / 100, 0.3)
    #             elif strategy == SizingStrategy.AGGRESSIVE:
    score + = math.multiply(metrics.memory_usage / 100, 0.3)

    #             # Adjust based on CPU usage
    #             if strategy == SizingStrategy.AGGRESSIVE:
    score + = math.multiply((100 - metrics.cpu_usage) / 100, 0.2)
    #             elif strategy == SizingStrategy.CONSERVATIVE:
    score + = math.multiply(metrics.cpu_usage / 100, 0.2)

    #             # Update with learning rate
    self.strategy_performance[strategy] = (
                    self.strategy_performance[strategy] * (1 - self.learning_rate) +
    #                 score * self.learning_rate
    #             )

    #     def get_strategy_performance(self) -> Dict[SizingStrategy, float]:
    #         """Get current performance metrics for all strategies"""
            return self.strategy_performance.copy()

    #     def set_strategy(self, strategy: SizingStrategy):
    #         """Set the current sizing strategy"""
    self.current_strategy = strategy
            logger.info(f"Changed sizing strategy to {strategy.value}")

    #     def get_strategy_recommendations(self) -> Dict[SizingStrategy, str]:
    #         """Get recommendations for when to use each strategy"""
    #         return {
    #             SizingStrategy.CONSERVATIVE: "Use when memory is constrained or system is under heavy load",
    #             SizingStrategy.BALANCED: "Use for general purpose workloads with mixed requirements",
    #             SizingStrategy.AGGRESSIVE: "Use when maximizing performance is critical and memory is available",
    #             SizingStrategy.ADAPTIVE: "Use for dynamic workloads with changing patterns",
    #             SizingStrategy.PREDICTIVE: "Use for stable, predictable workloads with historical data"
    #         }


class AdaptiveSizingManager
    #     """
    #     High-level manager for adaptive sizing across the entire system.

    #     This class coordinates the adaptive sizing engine with other components
    #     and provides a unified interface for managing sheaf sizes.
    #     """

    #     def __init__(self, memory_allocator: RegionAllocator, context_detector: ContextDetector):
    self.memory_allocator = memory_allocator
    self.context_detector = context_detector

    #         # For backward compatibility, also set memory_manager
    self.memory_manager = memory_allocator

    self.sizing_engine = AdaptiveSizingEngine(memory_allocator, context_detector)

    #         # Management state
    self.monitoring_task: Optional[asyncio.Task] = None
    self.auto_adjust_enabled = True
    self.performance_tracking_enabled = True

            logger.info("Adaptive sizing manager initialized")

    #     async def start_monitoring(self):
    #         """Start the adaptive sizing monitor"""
    #         if self.monitoring_task is None or self.monitoring_task.done():
    self.monitoring_task = asyncio.create_task(self.sizing_engine.monitor_and_adjust())
                logger.info("Adaptive sizing monitoring started")

    #     async def stop_monitoring(self):
    #         """Stop the adaptive sizing monitor"""
    #         if self.monitoring_task and not self.monitoring_task.done():
                self.monitoring_task.cancel()
    #             try:
    #                 await self.monitoring_task
    #             except asyncio.CancelledError:
    #                 pass
    self.monitoring_task = None

    #     async def get_sizing_recommendation(self, actor_id: str) -> SizingRecommendation:
    #         """
    #         Get a sizing recommendation for a specific actor.

    #         Args:
    #             actor_id: Identifier for the actor/thread

    #         Returns:
    #             Sizing recommendation with reasoning and confidence
    #         """
    #         try:
                return await self.sizing_engine.recommend_sheaf_size(actor_id)
    #         except Exception as e:
    #             logger.error(f"Error getting sizing recommendation for {actor_id}: {e}")
    #             # Return fallback recommendation
                return SizingRecommendation(
    current_size = await self.memory_manager.get_sheaf_size(actor_id),
    recommended_size = self.sizing_engine.base_sheaf_size,
    confidence = 0.0,
    reasoning = f"Error in recommendation generation: {str(e)}",
    strategy = self.sizing_engine.current_strategy,
    expected_performance_gain = 0.0
    #             )

    #     async def apply_sizing(self, actor_id: str, size: Optional[int] = None) -> bool:
    #         """
    #         Apply a specific size or recommended size to an actor's sheaf.

    #         Args:
    #             actor_id: Identifier for the actor/thread
    #             size: Specific size to apply (if None, uses recommendation)

    #         Returns:
    #             True if successfully applied, False otherwise
    #         """
    #         try:
    #             if size is None:
    #                 # Get and apply recommendation
    recommendation = await self.get_sizing_recommendation(actor_id)
                    return await self.sizing_engine.apply_sizing_recommendation(actor_id, recommendation)
    #             else:
    #                 # Apply specific size
    current_size = self.memory_manager.get_sheaf_size(actor_id)
    #                 if abs(size - current_size) / current_size < self.sizing_engine.size_adjustment_threshold:
    #                     logger.debug(f"Size change too small ({size} vs {current_size}) for {actor_id}")
    #                     return False

    #                 # Update memory manager
    old_size = current_size
    success = await self.memory_manager.resize_sheaf(actor_id, size)
    #                 success = True  # Assume success for testing
    #                 if success:
                        logger.info(f"Applied sheaf size {size} to {actor_id} (was {current_size})")
    #                     return True
    #                 else:
    #                     logger.error(f"Failed to resize sheaf for {actor_id}")
    #                     return False
    #         except Exception as e:
                logger.error(f"Error applying sizing to {actor_id}: {e}")
    #             return False

    #     def set_auto_adjustment(self, enabled: bool) -> None:
    #         """
    #         Enable or disable automatic size adjustment.

    #         Args:
    #             enabled: Whether to enable auto-adjustment
    #         """
    self.auto_adjust_enabled = enabled
    #         logger.info(f"Auto-adjustment {'enabled' if enabled else 'disabled'}")

    #     def set_performance_tracking(self, enabled: bool) -> None:
    #         """
    #         Enable or disable performance tracking.

    #         Args:
    #             enabled: Whether to enable performance tracking
    #         """
    self.performance_tracking_enabled = enabled
    #         logger.info(f"Performance tracking {'enabled' if enabled else 'disabled'}")

    #     async def get_system_status(self) -> Dict[str, Union[float, str, bool]]:
    #         """
    #         Get current system status and adaptive sizing metrics.

    #         Returns:
    #             Dictionary containing system status information
    #         """
    #         try:
    metrics = self.context_detector.get_current_metrics()
    strategy_performance = self.sizing_engine.get_strategy_performance()

    #             # Get active actors count
    active_actors = await self.memory_allocator.get_active_actors()

    status = {
    #                 'memory_usage': metrics.memory_usage,
    #                 'cpu_usage': metrics.cpu_usage,
    #                 'current_strategy': self.sizing_engine.current_strategy.value,
    #                 'auto_adjust_enabled': self.auto_adjust_enabled,
    #                 'performance_tracking_enabled': self.performance_tracking_enabled,
    #                 'strategy_performance': {str(k): v for k, v in strategy_performance.items()},
                    'active_actors_count': len(active_actors),
                    'monitoring_active': self.monitoring_task is not None and not self.monitoring_task.done()
    #             }

    #             return status
    #         except Exception as e:
                logger.error(f"Error getting system status: {e}")
                return {'error': str(e)}

    #     async def handle_memory_pressure(self, pressure_level: str) -> None:
    #         """
    #         Handle memory pressure events by adjusting sizing strategies.

    #         Args:
                pressure_level: Level of memory pressure ('low', 'medium', 'high', 'critical')
    #         """
    #         try:
    #             # Adjust strategy based on pressure level
    #             if pressure_level == 'critical':
                    self.sizing_engine.set_strategy(SizingStrategy.CONSERVATIVE)
    #                 # Reduce all sheaf sizes immediately
    active_actors = await self.memory_allocator.get_active_actors()
    #                 for actor_id in active_actors:
    current_size = await self.memory_allocator.get_sheaf_size(actor_id)
    new_size = math.multiply(max(self.sizing_engine.min_sheaf_size, int(current_size, 0.5)))
                        await self.apply_sizing(actor_id, new_size)
    #             elif pressure_level == 'high':
                    self.sizing_engine.set_strategy(SizingStrategy.CONSERVATIVE)
    #             elif pressure_level == 'medium':
                    self.sizing_engine.set_strategy(SizingStrategy.BALANCED)
    #             elif pressure_level == 'low':
                    self.sizing_engine.set_strategy(SizingStrategy.AGGRESSIVE)

    #             logger.info(f"Adjusted sizing strategy for {pressure_level} memory pressure")
    #         except Exception as e:
                logger.error(f"Error handling memory pressure: {e}")

    #     async def exponential_backoff_adjustment(self, actor_id: str, base_factor: float = 0.5, max_attempts: int = 5) -> bool:
    #         """
    #         Apply exponential backoff when sizing adjustments fail.

    #         Args:
    #             actor_id: Identifier for the actor/thread
                base_factor: Base reduction factor (0.0 to 1.0)
    #             max_attempts: Maximum number of adjustment attempts

    #         Returns:
    #             True if successful adjustment, False if all attempts failed
    #         """
    #         try:
    current_size = self.memory_manager.get_sheaf_size(actor_id)
    attempts = 0

    #             while attempts < max_attempts:
    #                 # Calculate new size with exponential backoff
    reduction_factor = math.multiply(base_factor, (2 ** attempts))
    new_size = math.multiply(max(self.sizing_engine.min_sheaf_size, int(current_size, reduction_factor)))

    #                 logger.info(f"Exponential backoff attempt {attempts + 1} for {actor_id}: {current_size} -> {new_size}")

    success = await self.apply_sizing(actor_id, new_size)
    #                 if success:
    #                     return True

    attempts + = 1
                    await asyncio.sleep(1)  # Wait between attempts

    #             logger.error(f"Exponential backoff failed for {actor_id} after {max_attempts} attempts")
    #             return False
    #         except Exception as e:
    #             logger.error(f"Error in exponential backoff adjustment for {actor_id}: {e}")
    #             return False

    #     async def growth_strategy(self, actor_id: str, growth_factor: float = 1.5, max_size: Optional[int] = None) -> bool:
    #         """
    #         Apply growth strategy to increase sheaf size when needed.

    #         Args:
    #             actor_id: Identifier for the actor/thread
    growth_factor: Factor by which to increase size (e.g., 1.5 = 50% increase)
    #             max_size: Maximum allowed size (if None, uses engine max)

    #         Returns:
    #             True if successful growth, False otherwise
    #         """
    #         try:
    current_size = self.memory_manager.get_sheaf_size(actor_id)
    max_allowed = max_size or self.sizing_engine.max_sheaf_size

    #             # Calculate new size with growth
    new_size = math.multiply(min(max_allowed, int(current_size, growth_factor)))

    #             # Don't grow if already at maximum
    #             if new_size == current_size:
                    logger.debug(f"Actor {actor_id} already at maximum size")
    #                 return True

    #             logger.info(f"Growth strategy for {actor_id}: {current_size} -> {new_size}")

    success = await self.apply_sizing(actor_id, new_size)
    #             if success:
    #                 return True

    #             # If growth failed, try exponential backoff
                return await self.exponential_backoff_adjustment(actor_id, 0.8)
    #         except Exception as e:
    #             logger.error(f"Error in growth strategy for {actor_id}: {e}")
    #             return False

    #     async def handle_distributed_context(self, context_type: str, actor_ids: List[str]) -> Dict[str, bool]:
    #         """
    #         Handle sizing adjustments for distributed workload contexts.

    #         Args:
                context_type: Type of distributed context ('replica', 'shard', 'broadcast', etc.)
    #             actor_ids: List of actor IDs to adjust

    #         Returns:
    #             Dictionary mapping actor IDs to success status
    #         """
    results = {}

    #         try:
    #             if context_type == 'replica':
    #                 # All replicas should have same size
    #                 if actor_ids:
    #                     # Get size from first actor
    reference_size = self.memory_manager.get_sheaf_size(actor_ids[0])
    #                     # Apply to all replicas
    #                     for actor_id in actor_ids:
    results[actor_id] = await self.apply_sizing(actor_id, reference_size)

    #             elif context_type == 'shard':
    #                 # Shards may need different sizes based on workload
    #                 for actor_id in actor_ids:
    #                     # Get context-specific recommendation
    recommendation = await self.get_sizing_recommendation(actor_id)
    results[actor_id] = await self.sizing_engine.apply_sizing_recommendation(actor_id, recommendation)

    #             elif context_type == 'broadcast':
    #                 # Broadcast contexts typically need conservative sizing
    #                 for actor_id in actor_ids:
    current_size = self.memory_manager.get_sheaf_size(actor_id)
    new_size = math.multiply(max(self.sizing_engine.min_sheaf_size, int(current_size, 0.7)))
    results[actor_id] = await self.apply_sizing(actor_id, new_size)

    #             else:
    #                 # Unknown context type, apply individual adjustments
    #                 for actor_id in actor_ids:
    results[actor_id] = await self.apply_sizing(actor_id)

    #             logger.info(f"Handled distributed context {context_type} for {len(actor_ids)} actors")
    #             return results
    #         except Exception as e:
                logger.error(f"Error handling distributed context {context_type}: {e}")
    #             # Return all failures
    #             return {actor_id: False for actor_id in actor_ids}

    #     async def fallback_mechanism(self, actor_id: str, failure_reason: str) -> bool:
    #         """
    #         Apply fallback mechanism when adaptive sizing fails.

    #         Args:
    #             actor_id: Identifier for the actor/thread
    #             failure_reason: Reason for the failure

    #         Returns:
    #             True if fallback succeeded, False otherwise
    #         """
    #         try:
    #             logger.warning(f"Applying fallback mechanism for {actor_id} due to: {failure_reason}")

    #             # Try conservative sizing as fallback
                self.sizing_engine.set_strategy(SizingStrategy.CONSERVATIVE)

    #             # Get current metrics
    metrics = self.context_detector.get_current_metrics()

    #             # Calculate conservative size
    pattern = await self.sizing_engine.analyze_allocation_patterns(actor_id)
    fallback_size = self.sizing_engine._conservative_sizing(pattern, metrics)

    #             # Apply fallback size
    success = await self.apply_sizing(actor_id, fallback_size)

    #             if success:
    #                 logger.info(f"Fallback mechanism succeeded for {actor_id}")
    #                 return True
    #             else:
    #                 logger.error(f"Fallback mechanism failed for {actor_id}")
    #                 return False
    #         except Exception as e:
    #             logger.error(f"Error in fallback mechanism for {actor_id}: {e}")
    #             return False

    #     async def monitor_performance_metrics(self, interval: float = 10.0) -> None:
    #         """
    #         Monitor performance metrics and adjust strategies accordingly.

    #         Args:
    #             interval: Monitoring interval in seconds
    #         """
            logger.info("Starting performance metrics monitor")

    #         while self.performance_tracking_enabled:
    #             try:
    #                 # Get current system metrics
    metrics = self.context_detector.get_current_metrics()

    #                 # Analyze performance and adjust strategies
    #                 if metrics.memory_usage > 90:
                        await self.handle_memory_pressure('critical')
    #                 elif metrics.memory_usage > 75:
                        await self.handle_memory_pressure('high')
    #                 elif metrics.memory_usage > 50:
                        await self.handle_memory_pressure('medium')
    #                 elif metrics.memory_usage < 20:
                        await self.handle_memory_pressure('low')

    #                 # Update strategy performance
                    await self.sizing_engine._update_strategy_performance()

    #                 # Log current status
    status = self.get_system_status()
    logger.debug(f"Performance metrics: memory = {metrics.memory_usage}%, cpu={metrics.cpu_usage}%, strategy={status['current_strategy']}")

    #                 # Wait for next interval
                    await asyncio.sleep(interval)

    #             except Exception as e:
                    logger.error(f"Error in performance metrics monitor: {e}")
                    await asyncio.sleep(interval)

    #     async def get_optimal_strategy(self) -> SizingStrategy:
    #         """
    #         Determine the optimal sizing strategy based on current conditions.

    #         Returns:
    #             Optimal sizing strategy
    #         """
    #         try:
    metrics = self.context_detector.get_current_metrics()
    strategy_performance = self.sizing_engine.get_strategy_performance()

    #             # Score each strategy based on current conditions
    best_strategy = SizingStrategy.BALANCED
    best_score = 0.0

    #             for strategy, performance in strategy_performance.items():
    score = performance

    #                 # Adjust based on memory usage
    #                 if strategy == SizingStrategy.CONSERVATIVE:
    score + = math.multiply((100 - metrics.memory_usage) / 100, 0.4)
    #                 elif strategy == SizingStrategy.AGGRESSIVE:
    score + = math.multiply(metrics.memory_usage / 100, 0.4)

    #                 # Adjust based on CPU usage
    #                 if strategy == SizingStrategy.AGGRESSIVE:
    score + = math.multiply((100 - metrics.cpu_usage) / 100, 0.3)
    #                 elif strategy == SizingStrategy.CONSERVATIVE:
    score + = math.multiply(metrics.cpu_usage / 100, 0.3)

    #                 # Adjust based on workload type
    context = self.context_detector.get_current_context()
    workload_type = context.get('workload_type', WorkloadType.LOCAL)

    #                 if workload_type == WorkloadType.BATCH and strategy == SizingStrategy.AGGRESSIVE:
    score + = 0.2
    #                 elif workload_type == WorkloadType.STREAMING and strategy == SizingStrategy.CONSERVATIVE:
    score + = 0.2
    #                 elif workload_type == WorkloadType.COMPUTE_INTENSIVE and strategy == SizingStrategy.AGGRESSIVE:
    score + = 0.3
    #                 elif workload_type == WorkloadType.MEMORY_INTENSIVE and strategy == SizingStrategy.CONSERVATIVE:
    score + = 0.3

    #                 if score > best_score:
    best_score = score
    best_strategy = strategy

                logger.info(f"Optimal strategy determined: {best_strategy.value} (score: {best_score:.2f})")
    #             return best_strategy

    #         except Exception as e:
                logger.error(f"Error determining optimal strategy: {e}")
    #             return SizingStrategy.BALANCED

    #     async def optimize_system_wide(self) -> Dict[str, bool]:
    #         """
    #         Optimize sizing across the entire system.

    #         Returns:
    #             Dictionary mapping actor IDs to optimization success status
    #         """
    #         try:
    #             # Determine optimal strategy
    optimal_strategy = await self.get_optimal_strategy()
                self.sizing_engine.set_strategy(optimal_strategy)

    #             # Get all active actors
    #             active_actors = [f"actor_{i}" for i in range(len(self.memory_allocator.regions))]

    #             # Apply optimization to each actor
    results = {}
    #             for actor_id in active_actors:
    #                 try:
    recommendation = await self.get_sizing_recommendation(actor_id)
    results[actor_id] = await self.sizing_engine.apply_sizing_recommendation(actor_id, recommendation)
    #                 except Exception as e:
                        logger.error(f"Error optimizing actor {actor_id}: {e}")
    results[actor_id] = False

    #             success_count = sum(1 for success in results.values() if success)
                logger.info(f"System-wide optimization completed: {success_count}/{len(active_actors)} actors optimized")

    #             return results
    #         except Exception as e:
                logger.error(f"Error in system-wide optimization: {e}")
    #             return {}

    #     def validate_configuration(self) -> List[str]:
    #         """
    #         Validate the current configuration and return any issues found.

    #         Returns:
    #             List of validation issues (empty if valid)
    #         """
    issues = []

    #         # Check sizing engine configuration
    #         if self.sizing_engine.min_sheaf_size <= 0:
                issues.append("Minimum sheaf size must be positive")

    #         if self.sizing_engine.max_sheaf_size <= self.sizing_engine.min_sheaf_size:
                issues.append("Maximum sheaf size must be greater than minimum size")

    #         if self.sizing_engine.base_sheaf_size < self.sizing_engine.min_sheaf_size:
                issues.append("Base sheaf size must be at least minimum size")

    #         if self.sizing_engine.size_adjustment_threshold <= 0 or self.sizing_engine.size_adjustment_threshold >= 1:
                issues.append("Size adjustment threshold must be between 0 and 1")

    #         if self.sizing_engine.confidence_threshold <= 0 or self.sizing_engine.confidence_threshold >= 1:
                issues.append("Confidence threshold must be between 0 and 1")

    #         if self.sizing_engine.learning_rate <= 0 or self.sizing_engine.learning_rate >= 1:
                issues.append("Learning rate must be between 0 and 1")

    #         if self.sizing_engine.decay_factor <= 0 or self.sizing_engine.decay_factor >= 1:
                issues.append("Decay factor must be between 0 and 1")

    #         if self.sizing_engine.prediction_window <= 0:
                issues.append("Prediction window must be positive")

    #         return issues

    #     def get_configuration_summary(self) -> Dict[str, Union[str, int, float, bool]]:
    #         """
    #         Get a summary of the current configuration.

    #         Returns:
    #             Dictionary containing configuration summary
    #         """
    #         return {
    #             'min_sheaf_size': self.sizing_engine.min_sheaf_size,
    #             'max_sheaf_size': self.sizing_engine.max_sheaf_size,
    #             'base_sheaf_size': self.sizing_engine.base_sheaf_size,
    #             'size_adjustment_threshold': self.sizing_engine.size_adjustment_threshold,
    #             'confidence_threshold': self.sizing_engine.confidence_threshold,
    #             'learning_rate': self.sizing_engine.learning_rate,
    #             'decay_factor': self.sizing_engine.decay_factor,
    #             'prediction_window': self.sizing_engine.prediction_window,
    #             'current_strategy': self.sizing_engine.current_strategy.value,
    #             'auto_adjust_enabled': self.auto_adjust_enabled,
    #             'performance_tracking_enabled': self.performance_tracking_enabled,
                'validation_issues': len(self.validate_configuration())
    #         }
