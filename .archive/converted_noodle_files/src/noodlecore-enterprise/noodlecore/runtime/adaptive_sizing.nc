# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Adaptive Sizing Algorithms for Sheaf Buffers

# This module implements intelligent sizing algorithms that adapt sheaf buffer
# sizes based on workload patterns, memory pressure, and performance characteristics.
# """

import time
import threading
import math
import logging
import collections.deque,
import dataclasses.dataclass,
import typing.Dict,
import enum.Enum

logger = logging.getLogger(__name__)


class SizingStrategy(Enum)
    #     """Strategies for adaptive sheaf sizing"""
    FIXED = "fixed"                    # Fixed size regardless of workload
    ADAPTIVE_DYNAMIC = "adaptive_dynamic"  # Dynamic adaptation based on usage
    PREDICTIVE = "predictive"          # Predict future needs based on patterns
    WORKLOAD_AWARE = "workload_aware"  # Size based on workload characteristics
    HYBRID = "hybrid"                  # Combination of multiple strategies


# @dataclass
class SizingMetrics
    #     """Metrics used for adaptive sizing decisions"""
    timestamp: float = field(default_factory=time.time)

    #     # Usage metrics
    utilization_rate: float = 0.0      # How much of sheaf is used
    allocation_rate: float = 0.0       # Allocations per second
    deallocation_rate: float = 0.0     # Deallocations per second
    fragmentation_rate: float = 0.0    # Memory fragmentation level

    #     # Performance metrics
    #     avg_allocation_time: float = 0.0   # Average time for allocation
    allocation_variance: float = 0.0   # Variance in allocation times
    miss_rate: float = 0.0             # Rate of allocation misses

    #     # Workload metrics
    object_size_avg: float = 0.0       # Average object size
    object_size_variance: float = 0.0  # Variance in object sizes
    peak_concurrent_allocations: int = 0  # Peak concurrent allocations

    #     # Memory pressure
    system_memory_pressure: float = 0.0  # Overall system memory pressure
    gc_pressure: float = 0.0           # Garbage collector pressure


# @dataclass
class SizingRecommendation
    #     """Recommendation for sheaf size adjustment"""
    #     current_size: int
    #     recommended_size: int
    #     strategy: SizingStrategy
    #     confidence: float  # 0.0 to 1.0
    reasoning: List[str] = field(default_factory=list)
    expected_benefit: str = ""
    risk_level: str = "low"  # low, medium, high

    #     # Adjustment parameters
    adjustment_factor: float = 1.0
    min_size: int = math.multiply(256, 1024      # 256KB)
    max_size: int = math.multiply(64, 1024 * 1024  # 64MB)


class AdaptiveSizingEngine
    #     """Engine for adaptive sheaf sizing based on multiple factors"""

    #     def __init__(self,
    base_size: int = math.multiply(4, 1024 * 1024,  # 4MB default)
    min_size: int = math.multiply(256, 1024,        # 256KB)
    max_size: int = math.multiply(64, 1024 * 1024,  # 64MB)
    strategy: SizingStrategy = SizingStrategy.HYBRID,
    adaptation_interval: float = 30.0,  # seconds
    history_size: int = 1000):

    self.base_size = base_size
    self.min_size = min_size
    self.max_size = max_size
    self.strategy = strategy
    self.adaptation_interval = adaptation_interval
    self.history_size = history_size

    #         # Metrics collection
    self.metrics_history = deque(maxlen=history_size)
    self.sizing_decisions = deque(maxlen=100)

    #         # Adaptive parameters
    self.utilization_target = 0.7    # Target 70% utilization
    self.utilization_tolerance = 0.1  # ±10% tolerance
    self.performance_threshold = 0.01  # 10ms allocation time threshold

    #         # Prediction models
    self.usage_patterns = defaultdict(list)
    self.size_predictions = deque(maxlen=100)

    #         # Background adaptation
    self._adaptation_thread = None
    self._running = False
    self._lock = threading.RLock()

    #         # Start adaptation
            self._start_adaptation()

    #     def _start_adaptation(self):
    #         """Start background adaptation thread"""
    self._running = True
    self._adaptation_thread = threading.Thread(
    target = self._adaptation_loop,
    daemon = True
    #         )
            self._adaptation_thread.start()
            logger.info("Adaptive sizing engine started")

    #     def _adaptation_loop(self):
    #         """Main adaptation loop"""
    #         while self._running:
    #             try:
    #                 # Analyze current metrics
    metrics = self._analyze_current_metrics()

    #                 # Generate sizing recommendation
    recommendation = self._generate_sizing_recommendation(metrics)

    #                 # Apply recommendation if confident
    #                 if recommendation.confidence > 0.7:
                        self._apply_sizing_recommendation(recommendation)

    #                 # Store decision
    #                 with self._lock:
                        self.sizing_decisions.append({
                            'timestamp': time.time(),
    #                         'recommendation': recommendation,
    #                         'metrics': metrics
    #                     })

    #                 # Sleep until next adaptation
                    time.sleep(self.adaptation_interval)

    #             except Exception as e:
                    logger.error(f"Adaptive sizing error: {e}")
                    time.sleep(self.adaptation_interval)

    #     def _analyze_current_metrics(self) -> SizingMetrics:
    #         """Analyze current performance metrics"""
    #         if len(self.metrics_history) < 10:
                return SizingMetrics()

    #         # Analyze recent metrics
    recent_metrics = math.subtract(list(self.metrics_history)[, 10:])

    #         # Calculate aggregate metrics
    #         avg_utilization = sum(m.utilization_rate for m in recent_metrics) / len(recent_metrics)
    #         avg_allocation_time = sum(m.avg_allocation_time for m in recent_metrics) / len(recent_metrics)
    #         avg_miss_rate = sum(m.miss_rate for m in recent_metrics) / len(recent_metrics)

    #         # Calculate variance
    utilization_variance = math.multiply(sum((m.utilization_rate - avg_utilization), * 2)
    #                                  for m in recent_metrics) / len(recent_metrics)
    allocation_variance = math.multiply(sum((m.avg_allocation_time - avg_allocation_time), * 2)
    #                                  for m in recent_metrics) / len(recent_metrics)

    #         # Analyze object sizes
    #         object_sizes = [m.object_size_avg for m in recent_metrics if m.object_size_avg > 0]
    #         avg_object_size = sum(object_sizes) / len(object_sizes) if object_sizes else 0
    #         object_size_variance = (sum((x - avg_object_size) ** 2 for x in object_sizes) /
    #                                len(object_sizes)) if object_sizes else 0

            return SizingMetrics(
    timestamp = time.time(),
    utilization_rate = avg_utilization,
    avg_allocation_time = avg_allocation_time,
    allocation_variance = allocation_variance,
    miss_rate = avg_miss_rate,
    object_size_avg = avg_object_size,
    object_size_variance = object_size_variance,
    system_memory_pressure = math.subtract(recent_metrics[, 1].system_memory_pressure,)
    gc_pressure = math.subtract(recent_metrics[, 1].gc_pressure)
    #         )

    #     def _generate_sizing_recommendation(self, metrics: SizingMetrics) -> SizingRecommendation:
    #         """Generate sizing recommendation based on analysis"""
    current_size = self.base_size
    reasoning = []
    confidence = 0.0

    #         # Strategy-specific recommendations
    #         if self.strategy == SizingStrategy.FIXED:
                return SizingRecommendation(
    current_size = current_size,
    recommended_size = current_size,
    strategy = SizingStrategy.FIXED,
    confidence = 1.0,
    reasoning = ["Fixed size strategy - no adaptation needed"]
    #             )

    #         elif self.strategy == SizingStrategy.ADAPTIVE_DYNAMIC:
    recommendation = self._dynamic_sizing_recommendation(metrics, reasoning)
    confidence = 0.8

    #         elif self.strategy == SizingStrategy.PREDICTIVE:
    recommendation = self._predictive_sizing_recommendation(metrics, reasoning)
    confidence = 0.7

    #         elif self.strategy == SizingStrategy.WORKLOAD_AWARE:
    recommendation = self._workload_aware_sizing_recommendation(metrics, reasoning)
    confidence = 0.75

    #         else:  # HYBRID
    recommendation = self._hybrid_sizing_recommendation(metrics, reasoning)
    confidence = 0.85

    #         # Apply size constraints
    recommendation.recommended_size = max(
    #             self.min_size,
                min(self.max_size, recommendation.recommended_size)
    #         )

    recommendation.confidence = confidence
    recommendation.reasoning = reasoning

    #         return recommendation

    #     def _dynamic_sizing_recommendation(self, metrics: SizingMetrics,
    #                                      reasoning: List[str]) -> SizingRecommendation:
    #         """Dynamic sizing based on current utilization"""
    current_size = self.base_size

    #         # Adjust based on utilization
    #         if metrics.utilization_rate > self.utilization_target + self.utilization_tolerance:
    #             # Underutilized - reduce size
    new_size = math.multiply(int(current_size, 0.8)  # Reduce by 20%)
                reasoning.append(f"High utilization ({metrics.utilization_rate:.2f}) - reducing size")
    expected_benefit = "Reduced memory overhead"
    risk_level = "low"

    #         elif metrics.utilization_rate < self.utilization_target - self.utilization_tolerance:
    #             # Overutilized - increase size
    new_size = math.multiply(int(current_size, 1.2)  # Increase by 20%)
                reasoning.append(f"Low utilization ({metrics.utilization_rate:.2f}) - increasing size")
    expected_benefit = "Better allocation performance"
    risk_level = "medium"

    #         else:
    #             # Good utilization - maintain size
    new_size = current_size
                reasoning.append(f"Optimal utilization ({metrics.utilization_rate:.2f}) - maintaining size")
    expected_benefit = "Stable performance"
    risk_level = "low"

            return SizingRecommendation(
    current_size = current_size,
    recommended_size = new_size,
    strategy = SizingStrategy.ADAPTIVE_DYNAMIC,
    confidence = 0.8,
    reasoning = reasoning,
    expected_benefit = expected_benefit,
    risk_level = risk_level
    #         )

    #     def _predictive_sizing_recommendation(self, metrics: SizingMetrics,
    #                                         reasoning: List[str]) -> SizingRecommendation:
    #         """Predictive sizing based on historical patterns"""
    current_size = self.base_size

    #         # Analyze trends in utilization
    #         if len(self.metrics_history) >= 20:
    #             recent_utilization = [m.utilization_rate for m in list(self.metrics_history)[-10:]]
    #             older_utilization = [m.utilization_rate for m in list(self.metrics_history)[-20:-10]]

    recent_avg = math.divide(sum(recent_utilization), len(recent_utilization))
    older_avg = math.divide(sum(older_utilization), len(older_utilization))

    #             # Predict future needs based on trend
    #             if recent_avg > older_avg + 0.1:  # Increasing trend
    new_size = math.multiply(int(current_size, 1.3)  # Increase by 30%)
                    reasoning.append(f"Increasing utilization trend ({recent_avg:.2f} vs {older_avg:.2f}) - anticipating growth")
    expected_benefit = "Prevent future allocation bottlenecks"
    risk_level = "medium"

    #             elif recent_avg < older_avg - 0.1:  # Decreasing trend
    new_size = math.multiply(int(current_size, 0.7)  # Reduce by 30%)
                    reasoning.append(f"Decreasing utilization trend ({recent_avg:.2f} vs {older_avg:.2f}) - conserving memory")
    expected_benefit = "Reduce unnecessary memory usage"
    risk_level = "low"

    #             else:
    new_size = current_size
                    reasoning.append(f"Stable utilization trend - maintaining current size")
    expected_benefit = "Conservative approach"
    risk_level = "low"
    #         else:
    new_size = current_size
    #             reasoning.append("Insufficient history for prediction - using current size")
    expected_benefit = "Stable performance"
    risk_level = "low"

            return SizingRecommendation(
    current_size = current_size,
    recommended_size = new_size,
    strategy = SizingStrategy.PREDICTIVE,
    confidence = 0.7,
    reasoning = reasoning,
    expected_benefit = expected_benefit,
    risk_level = risk_level
    #         )

    #     def _workload_aware_sizing_recommendation(self, metrics: SizingMetrics,
    #                                             reasoning: List[str]) -> SizingRecommendation:
    #         """Sizing based on workload characteristics"""
    current_size = self.base_size

    #         # Consider object size distribution
    #         if metrics.object_size_avg > 0:
    #             # Adjust based on average object size
    objects_per_sheaf = math.divide(current_size, max(1, metrics.object_size_avg))

    #             if objects_per_sheaf < 100:  # Too few objects per sheaf
    new_size = math.multiply(int(current_size, 1.5))
                    reasoning.append(f"Large objects ({metrics.object_size_avg:.0f} bytes avg) - increasing sheaf size")
    #                 expected_benefit = "Better space utilization for large objects"
    risk_level = "medium"

    #             elif objects_per_sheaf > 1000:  # Too many small objects
    new_size = math.multiply(int(current_size, 0.6))
                    reasoning.append(f"Small objects ({metrics.object_size_avg:.0f} bytes avg) - reducing sheaf size")
    #                 expected_benefit = "Reduce fragmentation for small objects"
    risk_level = "low"

    #             else:
    new_size = current_size
                    reasoning.append(f"Optimal object count ({objects_per_sheaf:.0f} objects/sheaf) - maintaining size")
    expected_benefit = "Balanced object distribution"
    risk_level = "low"

    #         # Consider allocation performance
    #         if metrics.avg_allocation_time > self.performance_threshold:
    #             new_size = int(new_size * 1.2) if 'new_size' in locals() else int(current_size * 1.2)
                reasoning.append(f"Slow allocation ({metrics.avg_allocation_time:.3f}s) - increasing sheaf size")
    expected_benefit = "Reduce allocation contention"
    risk_level = "medium"

            return SizingRecommendation(
    current_size = current_size,
    #             recommended_size=new_size if 'new_size' in locals() else current_size,
    strategy = SizingStrategy.WORKLOAD_AWARE,
    confidence = 0.75,
    reasoning = reasoning,
    #             expected_benefit=expected_benefit if 'expected_benefit' in locals() else "Stable performance",
    #             risk_level=risk_level if 'risk_level' in locals() else "low"
    #         )

    #     def _hybrid_sizing_recommendation(self, metrics: SizingMetrics,
    #                                     reasoning: List[str]) -> SizingRecommendation:
    #         """Hybrid sizing combining multiple strategies"""
    current_size = self.base_size

    #         # Get recommendations from all strategies
    dynamic_rec = self._dynamic_sizing_recommendation(metrics, [])
    predictive_rec = self._predictive_sizing_recommendation(metrics, [])
    workload_rec = self._workload_aware_sizing_recommendation(metrics, [])

    #         # Weighted combination
    weights = {
    #             SizingStrategy.ADAPTIVE_DYNAMIC: 0.4,
    #             SizingStrategy.PREDICTIVE: 0.3,
    #             SizingStrategy.WORKLOAD_AWARE: 0.3
    #         }

    #         # Calculate weighted recommendation
    weighted_size = (
    #             weights[SizingStrategy.ADAPTIVE_DYNAMIC] * dynamic_rec.recommended_size +
    #             weights[SizingStrategy.PREDICTIVE] * predictive_rec.recommended_size +
    #             weights[SizingStrategy.WORKLOAD_AWARE] * workload_rec.recommended_size
    #         )

    new_size = int(weighted_size)

    #         # Combine reasoning
            reasoning.extend(dynamic_rec.reasoning)
            reasoning.extend(predictive_rec.reasoning)
            reasoning.extend(workload_rec.reasoning)

    #         # Determine confidence based on agreement
    sizes = [dynamic_rec.recommended_size, predictive_rec.recommended_size, workload_rec.recommended_size]
    #         size_variance = sum((x - weighted_size) ** 2 for x in sizes) / len(sizes)
    confidence = math.multiply(max(0.5, 1.0 - (size_variance / (current_size, * 2))))

    expected_benefit = "Balanced approach considering multiple factors"
    #         risk_level = "low" if confidence > 0.8 else "medium"

            return SizingRecommendation(
    current_size = current_size,
    recommended_size = new_size,
    strategy = SizingStrategy.HYBRID,
    confidence = confidence,
    reasoning = reasoning,
    expected_benefit = expected_benefit,
    risk_level = risk_level
    #         )

    #     def _apply_sizing_recommendation(self, recommendation: SizingRecommendation):
    #         """Apply sizing recommendation"""
    old_size = self.base_size
    new_size = recommendation.recommended_size

    #         if old_size != new_size:
    self.base_size = new_size
                logger.info(f"Applied sizing recommendation: {old_size / 1024 / 1024:.1f}MB -> {new_size / 1024 / 1024:.1f}MB "
                           f"(confidence: {recommendation.confidence:.2f})")

    #     def record_metrics(self, metrics: SizingMetrics):
    #         """Record performance metrics for analysis"""
    #         with self._lock:
                self.metrics_history.append(metrics)

    #     def get_current_size(self) -> int:
    #         """Get current sheaf size"""
    #         return self.base_size

    #     def get_sizing_insights(self) -> Dict[str, Any]:
    #         """Get insights about sizing decisions"""
    #         if not self.sizing_decisions:
    #             return {"message": "No sizing decisions yet"}

    latest_decision = self.sizing_decisions[-1]['recommendation']

    insights = {
    #             "current_size": self.base_size,
    #             "current_strategy": self.strategy.value,
    #             "latest_recommendation": {
    #                 "recommended_size": latest_decision.recommended_size,
    #                 "confidence": latest_decision.confidence,
    #                 "reasoning": latest_decision.reasoning,
    #                 "expected_benefit": latest_decision.expected_benefit,
    #                 "risk_level": latest_decision.risk_level
    #             },
    #             "sizing_history": [
    #                 {
    #                     "timestamp": decision['timestamp'],
    #                     "old_size": decision['recommendation'].current_size,
    #                     "new_size": decision['recommendation'].recommended_size,
    #                     "confidence": decision['recommendation'].confidence
    #                 }
    #                 for decision in list(self.sizing_decisions)[-10:]  # Last 10 decisions
    #             ],
                "performance_summary": self._get_performance_summary()
    #         }

    #         return insights

    #     def _get_performance_summary(self) -> Dict[str, Any]:
    #         """Get performance summary"""
    #         if len(self.metrics_history) < 10:
    #             return {}

    recent_metrics = math.subtract(list(self.metrics_history)[, 10:])

    #         return {
    #             "avg_utilization": sum(m.utilization_rate for m in recent_metrics) / len(recent_metrics),
    #             "avg_allocation_time": sum(m.avg_allocation_time for m in recent_metrics) / len(recent_metrics),
    #             "avg_miss_rate": sum(m.miss_rate for m in recent_metrics) / len(recent_metrics),
    #             "avg_object_size": sum(m.object_size_avg for m in recent_metrics) / len(recent_metrics),
    #             "system_memory_pressure": sum(m.system_memory_pressure for m in recent_metrics) / len(recent_metrics),
    #             "gc_pressure": sum(m.gc_pressure for m in recent_metrics) / len(recent_metrics)
    #         }

    #     def set_strategy(self, strategy: SizingStrategy):
    #         """Change sizing strategy"""
    self.strategy = strategy
            logger.info(f"Changed sizing strategy to: {strategy.value}")

    #     def set_size_constraints(self, min_size: int, max_size: int):
    #         """Set size constraints"""
    self.min_size = min_size
    self.max_size = max_size
            logger.info(f"Updated size constraints: {min_size / 1024 / 1024:.1f}MB - {max_size / 1024 / 1024:.1f}MB")

    #     def cleanup(self):
    #         """Clean up resources"""
    self._running = False
    #         if self._adaptation_thread and self._adaptation_thread.is_alive():
    self._adaptation_thread.join(timeout = 5)
            logger.info("Adaptive sizing engine cleaned up")


class SheafSizingManager
    #     """Manager for individual sheaf sizing with per-actor adaptation"""

    #     def __init__(self, global_engine: AdaptiveSizingEngine):
    self.global_engine = global_engine
    self.actor_sizing: Dict[str, AdaptiveSizingEngine] = {}
    self.actor_configs: Dict[str, Dict[str, Any]] = {}
    self._lock = threading.RLock()

    #     def register_actor(self, actor_id: str, initial_config: Dict[str, Any] = None):
    #         """Register a new actor with custom sizing configuration"""
    #         with self._lock:
    #             if actor_id not in self.actor_sizing:
    #                 # Create actor-specific sizing engine
    config = initial_config or {}
    actor_engine = AdaptiveSizingEngine(
    base_size = config.get('base_size', self.global_engine.base_size),
    min_size = config.get('min_size', self.global_engine.min_size),
    max_size = config.get('max_size', self.global_engine.max_size),
    strategy = config.get('strategy', self.global_engine.strategy),
    adaptation_interval = config.get('adaptation_interval', self.global_engine.adaptation_interval)
    #                 )

    self.actor_sizing[actor_id] = actor_engine
    self.actor_configs[actor_id] = config
    #                 logger.debug(f"Registered actor {actor_id} with adaptive sizing")

    #     def get_actor_size(self, actor_id: str) -> int:
    #         """Get current sheaf size for actor"""
    #         with self._lock:
    #             if actor_id in self.actor_sizing:
                    return self.actor_sizing[actor_id].get_current_size()
    #             else:
                    return self.global_engine.get_current_size()

    #     def update_actor_metrics(self, actor_id: str, metrics: SizingMetrics):
    #         """Update metrics for specific actor"""
    #         with self._lock:
    #             if actor_id in self.actor_sizing:
                    self.actor_sizing[actor_id].record_metrics(metrics)

    #     def get_actor_insights(self, actor_id: str) -> Dict[str, Any]:
    #         """Get sizing insights for specific actor"""
    #         with self._lock:
    #             if actor_id in self.actor_sizing:
                    return self.actor_sizing[actor_id].get_sizing_insights()
    #             else:
    #                 return {"error": f"Actor {actor_id} not found"}

    #     def sync_with_global(self):
    #         """Sync all actor sizing engines with global engine"""
    #         with self._lock:
    #             for actor_id, engine in self.actor_sizing.items():
    #                 # Update base configuration from global engine
    engine.base_size = self.global_engine.base_size
    engine.min_size = self.global_engine.min_size
    engine.max_size = self.global_engine.max_size
    engine.strategy = self.global_engine.strategy

    #             logger.debug("Synced all actor sizing engines with global engine")

    #     def unregister_actor(self, actor_id: str):
    #         """Unregister an actor"""
    #         with self._lock:
    #             if actor_id in self.actor_sizing:
                    self.actor_sizing[actor_id].cleanup()
    #                 del self.actor_sizing[actor_id]
    #                 del self.actor_configs[actor_id]
                    logger.debug(f"Unregistered actor {actor_id} from adaptive sizing")

    #     def cleanup(self):
    #         """Clean up all actor sizing engines"""
    #         with self._lock:
    #             for engine in self.actor_sizing.values():
                    engine.cleanup()
                self.actor_sizing.clear()
                self.actor_configs.clear()
