# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Adaptive Optimizer for NoodleCore Self-Improvement System

# This module enables hybrid mode for critical components using the existing
# component manager and implements feature flags for controlled rollout.
# """

import os
import json
import logging
import time
import threading
import uuid
import typing.Any,
import dataclasses.dataclass,
import enum.Enum

# Import bridge components
import ...bridge_modules.feature_flags.component_manager.(
#     ComponentManager, ComponentType, FeatureFlag, FeatureFlagStatus
# )
import ...bridge_modules.performance_compare.performance_benchmark.(
#     PerformanceBenchmark, ImplementationType
# )

# Configure logging
logger = logging.getLogger(__name__)

# Environment variables
NOODLE_DEBUG = os.environ.get("NOODLE_DEBUG", "0") == "1"
NOODLE_ADAPTIVE_OPTIMIZATION = os.environ.get("NOODLE_ADAPTIVE_OPTIMIZATION", "1") == "1"
NOODLE_CRITICAL_COMPONENTS = os.environ.get("NOODLE_CRITICAL_COMPONENTS",
    "compiler,optimizer,runtime").split(",")
NOODLE_HYBRID_MODE_ENABLED = os.environ.get("NOODLE_HYBRID_MODE_ENABLED", "1") == "1"
NOODLE_ROLLOUT_PERCENTAGE = float(os.environ.get("NOODLE_ROLLOUT_PERCENTAGE", "10.0"))


class OptimizationStrategy(Enum)
    #     """Optimization strategies for adaptive system."""
    CONSERVATIVE = "conservative"
    BALANCED = "balanced"
    AGGRESSIVE = "aggressive"
    PERFORMANCE_DRIVEN = "performance_driven"
    SAFETY_FIRST = "safety_first"


class RolloutStatus(Enum)
    #     """Status of component rollout."""
    NOT_STARTED = "not_started"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    ROLLED_BACK = "rolled_back"
    PAUSED = "paused"


# @dataclass
class ComponentOptimizationState
    #     """State of optimization for a component."""
    #     component_name: str
    #     current_implementation: ComponentType
    #     optimization_strategy: OptimizationStrategy
    #     rollout_status: RolloutStatus
    #     rollout_percentage: float
    #     performance_score: float
    #     last_updated: float
    #     error_count: int
    #     success_count: int
    metadata: Optional[Dict[str, Any]] = None


# @dataclass
class OptimizationDecision
    #     """Decision made by the adaptive optimizer."""
    #     decision_id: str
    #     component_name: str
    #     timestamp: float
    #     strategy: OptimizationStrategy
    #     selected_implementation: ComponentType
    #     rollout_percentage: float
    #     confidence: float
    #     reason: str
    metadata: Optional[Dict[str, Any]] = None


class AdaptiveOptimizer
    #     """
    #     Adaptive optimizer for NoodleCore self-improvement system.

    #     This class enables hybrid mode for critical components using the existing
    #     component manager and implements feature flags for controlled rollout.
    #     """

    #     def __init__(self, component_manager: ComponentManager = None):
    #         """Initialize adaptive optimizer."""
    #         if NOODLE_DEBUG:
                logger.setLevel(logging.DEBUG)

    self.component_manager = component_manager

    #         # Optimization state
    self.component_states: Dict[str, ComponentOptimizationState] = {}
    self.optimization_decisions: List[OptimizationDecision] = []

    #         # Configuration
    self.config = {
    #             'enabled': NOODLE_ADAPTIVE_OPTIMIZATION,
    #             'critical_components': NOODLE_CRITICAL_COMPONENTS,
    #             'hybrid_mode_enabled': NOODLE_HYBRID_MODE_ENABLED,
    #             'default_rollout_percentage': NOODLE_ROLLOUT_PERCENTAGE,
    #             'performance_threshold': 0.1,  # 10% improvement threshold
    #             'error_threshold': 5,       # Max errors before rollback
    #             'evaluation_interval': 300,  # 5 minutes
    #             'max_rollout_percentage': 100.0,
    #             'rollout_increment': 10.0  # Increment rollout by 10%
    #         }

    #         # Threading
    self._lock = threading.RLock()
    self._optimization_thread = None
    self._running = False

    #         # Statistics
    self.statistics = {
    #             'total_optimizations': 0,
    #             'successful_rollouts': 0,
    #             'failed_rollouts': 0,
    #             'rollbacks_triggered': 0,
    #             'performance_improvements': 0,
    #             'hybrid_activations': 0
    #         }

            logger.info("Adaptive optimizer initialized")

    #     def activate(self) -> bool:
    #         """
    #         Activate the adaptive optimizer system.

    #         Returns:
    #             True if activation successful, False otherwise.
    #         """
    #         with self._lock:
    #             if not self.config['enabled']:
                    logger.info("Adaptive optimization disabled by configuration")
    #                 return False

    #             if not self.component_manager:
    #                 logger.error("No component manager provided for adaptive optimization")
    #                 return False

    #             try:
    #                 # Initialize critical components
                    self._initialize_critical_components()

    #                 # Set up feature flags for controlled rollout
                    self._setup_feature_flags()

    #                 # Start optimization thread
                    self._start_optimization_thread()

                    logger.info("Adaptive optimizer activated successfully")
    #                 return True

    #             except Exception as e:
                    logger.error(f"Failed to activate adaptive optimizer: {str(e)}")
    #                 return False

    #     def _initialize_critical_components(self):
    #         """Initialize optimization state for critical components."""
    #         for component_name in self.config['critical_components']:
    component_name = component_name.strip()

    #             # Get current implementation from component manager
    #             try:
    component = self.component_manager.get_component(component_name)
    #                 if component:
    current_impl = component.component_type
    #                 else:
    current_impl = ComponentType.PYTHON
    #             except Exception:
    current_impl = ComponentType.PYTHON

    #             # Initialize component state
    state = ComponentOptimizationState(
    component_name = component_name,
    current_implementation = current_impl,
    optimization_strategy = OptimizationStrategy.CONSERVATIVE,
    rollout_status = RolloutStatus.NOT_STARTED,
    rollout_percentage = 0.0,
    #                 performance_score=0.5,  # Start with neutral score
    last_updated = time.time(),
    error_count = 0,
    success_count = 0
    #             )

    self.component_states[component_name] = state

    #             # Register component for hybrid mode if enabled
    #             if self.config['hybrid_mode_enabled']:
                    self._register_hybrid_implementation(component_name)

                logger.info(f"Initialized critical component: {component_name}")

    #     def _register_hybrid_implementation(self, component_name: str):
    #         """Register a hybrid implementation for a component."""
    #         try:
    #             # Create hybrid implementation wrapper
    #             def hybrid_implementation(*args, **kwargs):
    #                 """Hybrid implementation that selects best approach at runtime."""
    #                 # Get current performance data
    performance_summary = self._get_component_performance_summary(component_name)

    #                 # Select implementation based on performance
    #                 if performance_summary:
    python_perf = performance_summary.get('python', {}).get('avg_execution_time', float('inf'))
    noodlecore_perf = performance_summary.get('noodlecore', {}).get('avg_execution_time', float('inf'))

    #                     # Use Python if NoodleCore performance is unknown or worse
    #                     if noodlecore_perf == float('inf') or python_perf < noodlecore_perf:
    #                         # Execute Python implementation
    python_component = self.component_manager.get_component(component_name)
    #                         if python_component and python_component.implementation:
                                return python_component.implementation(*args, **kwargs)

    #                 # Default to NoodleCore implementation
    noodlecore_name = f"{component_name}_noodlecore"
    noodlecore_component = self.component_manager.get_component(noodlecore_name)
    #                 if noodlecore_component and noodlecore_component.implementation:
                        return noodlecore_component.implementation(*args, **kwargs)

    #                 # Fallback to Python if nothing else works
    python_component = self.component_manager.get_component(component_name)
    #                 if python_component and python_component.implementation:
                        return python_component.implementation(*args, **kwargs)

    #                 raise Exception(f"No implementation available for {component_name}")

    #             # Register hybrid implementation
                self.component_manager.register_component(
    name = f"{component_name}_hybrid",
    component_type = ComponentType.HYBRID,
    implementation = hybrid_implementation,
    description = f"Hybrid implementation of {component_name}",
    aliases = [component_name]
    #             )

    self.statistics['hybrid_activations'] + = 1

    #             if NOODLE_DEBUG:
    #                 logger.debug(f"Registered hybrid implementation for {component_name}")

    #         except Exception as e:
    #             logger.error(f"Failed to register hybrid implementation for {component_name}: {str(e)}")

    #     def _setup_feature_flags(self):
    #         """Set up feature flags for controlled rollout."""
    #         try:
    #             # Enable NoodleCore implementation flag with controlled rollout
                self.component_manager.set_feature_flag(
    flag_name = "use_noodlecore_implementation",
    status = FeatureFlagStatus.CONDITIONAL,
    description = "Use NoodleCore implementation when performance criteria met",
    rollout_percentage = self.config['default_rollout_percentage'],
    conditions = {
    #                     'performance_threshold': self.config['performance_threshold'],
    #                     'error_threshold': self.config['error_threshold'],
    #                     'critical_components': self.config['critical_components']
    #                 }
    #             )

    #             # Enable hybrid mode flag if configured
    #             if self.config['hybrid_mode_enabled']:
                    self.component_manager.set_feature_flag(
    flag_name = "enable_hybrid_mode",
    status = FeatureFlagStatus.ENABLED,
    description = "Enable hybrid implementation combining Python and NoodleCore"
    #                 )

    #             # Enable performance monitoring flag
                self.component_manager.set_feature_flag(
    flag_name = "enable_performance_monitoring",
    status = FeatureFlagStatus.ENABLED,
    #                 description="Enable performance monitoring for component selection"
    #             )

    #             logger.info("Feature flags configured for controlled rollout")

    #         except Exception as e:
                logger.error(f"Failed to setup feature flags: {str(e)}")

    #     def _start_optimization_thread(self):
    #         """Start the background optimization thread."""
    #         if self._optimization_thread and self._optimization_thread.is_alive():
    #             return

    self._running = True
    self._optimization_thread = threading.Thread(
    target = self._optimization_worker,
    daemon = True
    #         )
            self._optimization_thread.start()

    #     def _optimization_worker(self):
    #         """Background worker for optimization tasks."""
            logger.info("Adaptive optimization worker started")

    #         while self._running:
    #             try:
    #                 # Evaluate all critical components
                    self._evaluate_critical_components()

    #                 # Make optimization decisions
                    self._make_optimization_decisions()

    #                 # Sleep until next evaluation
                    time.sleep(self.config['evaluation_interval'])

    #             except Exception as e:
                    logger.error(f"Error in optimization worker: {str(e)}")
                    time.sleep(30)  # Brief pause before retrying

            logger.info("Adaptive optimization worker stopped")

    #     def _evaluate_critical_components(self):
    #         """Evaluate critical components and update their state."""
    #         for component_name, state in self.component_states.items():
    #             try:
    #                 # Get performance data
    performance_summary = self._get_component_performance_summary(component_name)

    #                 if performance_summary:
    #                     # Update component state based on performance
                        self._update_component_state(component_name, state, performance_summary)

    #                 # Check if rollback is needed
    #                 if self._should_rollback(component_name, state):
                        self._trigger_rollback(component_name, state)

    #                 # Check if rollout should continue
    #                 elif self._should_continue_rollout(component_name, state):
                        self._continue_rollout(component_name, state)

    #             except Exception as e:
                    logger.error(f"Error evaluating component {component_name}: {str(e)}")

    #     def _get_component_performance_summary(self, component_name: str) -> Optional[Dict[str, Any]]:
    #         """Get performance summary for a component."""
    #         try:
    #             # Get performance data from component manager
    performance_metrics = self.component_manager.get_performance_metrics()

    #             # Look for metrics for this component
    component_metrics = performance_metrics.get(component_name, {})

    #             if not component_metrics:
    #                 return None

    #             # Calculate implementation-specific metrics
    summary = {}

    #             # Get execution counts and times
    python_executions = component_metrics.get('python_execution_count', 0)
    noodlecore_executions = component_metrics.get('noodlecore_execution_count', 0)
    hybrid_executions = component_metrics.get('hybrid_execution_count', 0)

    #             if python_executions > 0:
    summary['python'] = {
    #                     'execution_count': python_executions,
                        'avg_execution_time': component_metrics.get('python_avg_time', 0.0),
                        'success_rate': component_metrics.get('python_success_rate', 100.0),
                        'error_rate': component_metrics.get('python_error_rate', 0.0)
    #                 }

    #             if noodlecore_executions > 0:
    summary['noodlecore'] = {
    #                     'execution_count': noodlecore_executions,
                        'avg_execution_time': component_metrics.get('noodlecore_avg_time', 0.0),
                        'success_rate': component_metrics.get('noodlecore_success_rate', 100.0),
                        'error_rate': component_metrics.get('noodlecore_error_rate', 0.0)
    #                 }

    #             if hybrid_executions > 0:
    summary['hybrid'] = {
    #                     'execution_count': hybrid_executions,
                        'avg_execution_time': component_metrics.get('hybrid_avg_time', 0.0),
                        'success_rate': component_metrics.get('hybrid_success_rate', 100.0),
                        'error_rate': component_metrics.get('hybrid_error_rate', 0.0)
    #                 }

    #             return summary

    #         except Exception as e:
    #             logger.error(f"Error getting performance summary for {component_name}: {str(e)}")
    #             return None

    #     def _update_component_state(self,
    #                              component_name: str,
    #                              state: ComponentOptimizationState,
    #                              performance_summary: Dict[str, Any]):
    #         """Update component state based on performance data."""
    #         try:
    #             # Calculate performance score
    python_data = performance_summary.get('python', {})
    noodlecore_data = performance_summary.get('noodlecore', {})

    #             if noodlecore_data and python_data:
    python_time = python_data.get('avg_execution_time', float('inf'))
    noodlecore_time = noodlecore_data.get('avg_execution_time', float('inf'))

    #                 if python_time > 0 and noodlecore_time > 0:
    #                     # Calculate performance improvement
    improvement = math.subtract((python_time, noodlecore_time) / python_time)

                        # Update performance score (0.0 to 1.0)
    #                     if improvement > self.config['performance_threshold']:
    state.performance_score = math.add(min(1.0, state.performance_score, 0.1))
    #                     elif improvement < -self.config['performance_threshold']:
    state.performance_score = math.subtract(max(0.0, state.performance_score, 0.1))

    #             # Update error and success counts
    total_errors = sum(
                    data.get('error_rate', 0.0) * data.get('execution_count', 0) / 100.0
    #                 for data in performance_summary.values()
    #             )
    total_executions = sum(
    #                 data.get('execution_count', 0) for data in performance_summary.values()
    #             )

    state.error_count = int(total_errors)
    state.success_count = math.subtract(int(total_executions, total_errors))
    state.last_updated = time.time()

    #             if NOODLE_DEBUG:
    #                 logger.debug(f"Updated state for {component_name}: score={state.performance_score:.2f}")

    #         except Exception as e:
    #             logger.error(f"Error updating component state for {component_name}: {str(e)}")

    #     def _should_rollback(self, component_name: str, state: ComponentOptimizationState) -> bool:
    #         """Check if a component should be rolled back."""
    #         # Check error threshold
    #         if state.error_count >= self.config['error_threshold']:
    #             logger.warning(f"Error threshold exceeded for {component_name}")
    #             return True

    #         # Check performance score
    #         if state.performance_score < 0.2:  # Very low performance score
    #             logger.warning(f"Very low performance score for {component_name}: {state.performance_score}")
    #             return True

    #         return False

    #     def _should_continue_rollout(self, component_name: str, state: ComponentOptimizationState) -> bool:
    #         """Check if rollout should continue for a component."""
    #         # Don't continue if already at max rollout
    #         if state.rollout_percentage >= self.config['max_rollout_percentage']:
    #             return False

    #         # Continue if performance is good
    #         if state.performance_score >= 0.6:  # Good performance score
    #             return True

    #         # Continue if error rate is low
    #         if state.error_count == 0 and state.success_count >= 10:
    #             return True

    #         return False

    #     def _trigger_rollback(self, component_name: str, state: ComponentOptimizationState):
    #         """Trigger rollback for a component."""
    #         try:
    #             logger.warning(f"Triggering rollback for {component_name}")

    #             # Update rollout status
    state.rollout_status = RolloutStatus.ROLLED_BACK
    state.rollout_percentage = 0.0

    #             # Force Python implementation
                self.component_manager.set_feature_flag(
    flag_name = "use_noodlecore_implementation",
    status = FeatureFlagStatus.DISABLED,
    conditions = {'forced_rollback': True, 'component': component_name}
    #             )

    #             # Record rollback decision
    decision = OptimizationDecision(
    decision_id = str(uuid.uuid4()),
    component_name = component_name,
    timestamp = time.time(),
    strategy = OptimizationStrategy.SAFETY_FIRST,
    selected_implementation = ComponentType.PYTHON,
    rollout_percentage = 0.0,
    confidence = 1.0,
    reason = f"Rollback triggered: {state.error_count} errors, score={state.performance_score:.2f}"
    #             )

    #             with self._lock:
                    self.optimization_decisions.append(decision)
    self.statistics['rollbacks_triggered'] + = 1

    #             if NOODLE_DEBUG:
    #                 logger.debug(f"Rollback decision recorded for {component_name}")

    #         except Exception as e:
    #             logger.error(f"Error triggering rollback for {component_name}: {str(e)}")

    #     def _continue_rollout(self, component_name: str, state: ComponentOptimizationState):
    #         """Continue rollout for a component."""
    #         try:
    #             # Calculate new rollout percentage
    new_percentage = min(
    #                 self.config['max_rollout_percentage'],
    #                 state.rollout_percentage + self.config['rollout_increment']
    #             )

    #             logger.info(f"Continuing rollout for {component_name}: {state.rollout_percentage}% -> {new_percentage}%")

    #             # Update rollout status
    state.rollout_status = RolloutStatus.IN_PROGRESS
    state.rollout_percentage = new_percentage

    #             # Update feature flag with new rollout percentage
                self.component_manager.set_feature_flag(
    flag_name = "use_noodlecore_implementation",
    status = FeatureFlagStatus.CONDITIONAL,
    rollout_percentage = new_percentage,
    conditions = {
    #                     'performance_threshold': self.config['performance_threshold'],
    #                     'error_threshold': self.config['error_threshold'],
    #                     'critical_components': self.config['critical_components'],
    #                     'current_rollout': new_percentage
    #                 }
    #             )

    #             # Determine implementation based on rollout percentage
    #             if new_percentage >= 50.0:
    selected_impl = ComponentType.NOODLECORE
    strategy = OptimizationStrategy.AGGRESSIVE
    #             elif new_percentage >= 25.0:
    selected_impl = ComponentType.HYBRID
    strategy = OptimizationStrategy.BALANCED
    #             else:
    selected_impl = ComponentType.PYTHON
    strategy = OptimizationStrategy.CONSERVATIVE

    #             # Record rollout decision
    decision = OptimizationDecision(
    decision_id = str(uuid.uuid4()),
    component_name = component_name,
    timestamp = time.time(),
    strategy = strategy,
    selected_implementation = selected_impl,
    rollout_percentage = new_percentage,
    confidence = state.performance_score,
    reason = f"Rollout continued: performance_score={state.performance_score:.2f}"
    #             )

    #             with self._lock:
                    self.optimization_decisions.append(decision)
    self.statistics['total_optimizations'] + = 1

    #                 if new_percentage >= self.config['max_rollout_percentage']:
    state.rollout_status = RolloutStatus.COMPLETED
    self.statistics['successful_rollouts'] + = 1

    #             if NOODLE_DEBUG:
    #                 logger.debug(f"Rollout decision recorded for {component_name}")

    #         except Exception as e:
    #             logger.error(f"Error continuing rollout for {component_name}: {str(e)}")

    #     def _make_optimization_decisions(self):
    #         """Make optimization decisions based on component states."""
    #         for component_name, state in self.component_states.items():
    #             try:
    #                 # Skip if not in progress
    #                 if state.rollout_status not in [RolloutStatus.NOT_STARTED, RolloutStatus.IN_PROGRESS]:
    #                     continue

    #                 # Analyze component performance trends
    recent_decisions = [
    #                     d for d in self.optimization_decisions
    #                     if d.component_name == component_name and
                           time.time() - d.timestamp < 3600  # Last hour
    #                 ]

    #                 # Make strategic decision
    #                 if len(recent_decisions) >= 3:
    #                     # Too many recent decisions, wait for stability
    #                     continue

    #                 # Determine optimization strategy
    #                 if state.performance_score >= 0.8:
    strategy = OptimizationStrategy.AGGRESSIVE
    #                 elif state.performance_score >= 0.5:
    strategy = OptimizationStrategy.BALANCED
    #                 else:
    strategy = OptimizationStrategy.CONSERVATIVE

    #                 # Record strategic decision
    decision = OptimizationDecision(
    decision_id = str(uuid.uuid4()),
    component_name = component_name,
    timestamp = time.time(),
    strategy = strategy,
    selected_implementation = state.current_implementation,
    rollout_percentage = state.rollout_percentage,
    confidence = state.performance_score,
    reason = f"Strategic decision: score={state.performance_score:.2f}, errors={state.error_count}"
    #                 )

    #                 with self._lock:
                        self.optimization_decisions.append(decision)

    #                 if NOODLE_DEBUG:
    #                     logger.debug(f"Strategic decision for {component_name}: {strategy.value}")

    #             except Exception as e:
    #                 logger.error(f"Error making optimization decision for {component_name}: {str(e)}")

    #     def get_optimization_status(self, component_name: str = None) -> Dict[str, Any]:
    #         """
    #         Get optimization status for components.

    #         Args:
    #             component_name: Specific component to get status for, or None for all.

    #         Returns:
    #             Optimization status dictionary.
    #         """
    #         with self._lock:
    #             if component_name:
    #                 if component_name in self.component_states:
                        return asdict(self.component_states[component_name])
    #                 return {}

    #             # Return all components
    #             return {
    #                 'components': {name: asdict(state) for name, state in self.component_states.items()},
    #                 'recent_decisions': [asdict(d) for d in self.optimization_decisions[-10:]],
                    'statistics': self.statistics.copy(),
                    'config': self.config.copy()
    #             }

    #     def force_rollout(self, component_name: str, implementation: ComponentType, percentage: float = 100.0):
    #         """
    #         Force a specific rollout for a component.

    #         Args:
    #             component_name: Name of the component.
    #             implementation: Implementation type to force.
                percentage: Rollout percentage (0-100).
    #         """
    #         try:
    #             if component_name not in self.component_states:
                    logger.error(f"Component {component_name} not found in critical components")
    #                 return False

    state = self.component_states[component_name]

    #             logger.info(f"Forcing rollout for {component_name}: {implementation.value} at {percentage}%")

    #             # Update state
    state.current_implementation = implementation
    state.rollout_status = RolloutStatus.IN_PROGRESS
    state.rollout_percentage = percentage
    state.last_updated = time.time()

    #             # Update feature flags
    #             if implementation == ComponentType.NOODLECORE:
                    self.component_manager.set_feature_flag(
    flag_name = "use_noodlecore_implementation",
    status = FeatureFlagStatus.ENABLED,
    conditions = {'forced_rollout': True, 'component': component_name}
    #                 )
    #             elif implementation == ComponentType.HYBRID:
                    self.component_manager.set_feature_flag(
    flag_name = "enable_hybrid_mode",
    status = FeatureFlagStatus.ENABLED,
    conditions = {'forced_rollout': True, 'component': component_name}
    #                 )
    #             else:
                    self.component_manager.set_feature_flag(
    flag_name = "use_noodlecore_implementation",
    status = FeatureFlagStatus.DISABLED,
    conditions = {'forced_rollout': True, 'component': component_name}
    #                 )

    #             # Record forced decision
    decision = OptimizationDecision(
    decision_id = str(uuid.uuid4()),
    component_name = component_name,
    timestamp = time.time(),
    strategy = OptimizationStrategy.PERFORMANCE_DRIVEN,
    selected_implementation = implementation,
    rollout_percentage = percentage,
    confidence = 1.0,
    reason = "Forced rollout via API"
    #             )

    #             with self._lock:
                    self.optimization_decisions.append(decision)
    self.statistics['total_optimizations'] + = 1

    #             return True

    #         except Exception as e:
    #             logger.error(f"Error forcing rollout for {component_name}: {str(e)}")
    #             return False

    #     def deactivate(self) -> bool:
    #         """
    #         Deactivate the adaptive optimizer system.

    #         Returns:
    #             True if deactivation successful, False otherwise.
    #         """
    #         with self._lock:
    #             try:
    #                 # Stop optimization thread
    self._running = False
    #                 if self._optimization_thread and self._optimization_thread.is_alive():
    self._optimization_thread.join(timeout = 5.0)

                    logger.info("Adaptive optimizer deactivated")
    #                 return True

    #             except Exception as e:
                    logger.error(f"Error deactivating adaptive optimizer: {str(e)}")
    #                 return False


# Global instance for convenience
_global_adaptive_optimizer_instance = None


def get_adaptive_optimizer(component_manager: ComponentManager = None) -> AdaptiveOptimizer:
#     """
#     Get a global adaptive optimizer instance.

#     Args:
#         component_manager: Component manager instance to integrate with.

#     Returns:
#         An AdaptiveOptimizer instance.
#     """
#     global _global_adaptive_optimizer_instance

#     if _global_adaptive_optimizer_instance is None:
_global_adaptive_optimizer_instance = AdaptiveOptimizer(component_manager)

#     return _global_adaptive_optimizer_instance