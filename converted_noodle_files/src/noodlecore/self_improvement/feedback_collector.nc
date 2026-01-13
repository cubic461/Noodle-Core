# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Feedback Collector for TRM-Agent Self-Improvement System

# This module implements the feedback collection mechanism that activates the existing
# feedback system in the component manager and stores optimization results for learning.
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

# Import TRM-Agent components
import ..trm.trm_agent.TRMAgent
import ..trm.trm_agent_base.OptimizationResult,

# Import bridge components
import bridge_modules.feature_flags.component_manager.ComponentManager,

# Configure logging
logger = logging.getLogger(__name__)

# Environment variables
NOODLE_DEBUG = os.environ.get("NOODLE_DEBUG", "0") == "1"
NOODLE_FEEDBACK_ENABLED = os.environ.get("NOODLE_FEEDBACK_ENABLED", "1") == "1"
NOODLE_FEEDBACK_STORAGE = os.environ.get("NOODLE_FEEDBACK_STORAGE", "feedback_data.json")
NOODLE_FEEDBACK_RETENTION = int(os.environ.get("NOODLE_FEEDBACK_RETENTION", "10000"))
NOODLE_AUTO_LEARNING = os.environ.get("NOODLE_AUTO_LEARNING", "1") == "1"


class FeedbackStatus(Enum)
    #     """Status of feedback entries."""
    PENDING = "pending"
    PROCESSED = "processed"
    LEARNED = "learned"
    ERROR = "error"


class FeedbackType(Enum)
    #     """Type of feedback being collected."""
    OPTIMIZATION_SUCCESS = "optimization_success"
    OPTIMIZATION_FAILURE = "optimization_failure"
    PERFORMANCE_COMPARISON = "performance_comparison"
    COMPONENT_SELECTION = "component_selection"
    ERROR_REPORT = "error_report"


# @dataclass
class FeedbackEntry
    #     """Entry in the feedback collection system."""
    #     feedback_id: str
    #     feedback_type: FeedbackType
    #     timestamp: float
    #     component_name: str
    #     implementation_type: ComponentType
    #     status: FeedbackStatus

    #     # Performance data
    original_metrics: Optional[Dict[str, float]] = None
    optimized_metrics: Optional[Dict[str, float]] = None
    performance_improvement: Optional[float] = None

    #     # Optimization data
    optimization_result: Optional[OptimizationResult] = None
    optimization_strategy: Optional[str] = None
    optimization_confidence: Optional[float] = None

    #     # Context data
    execution_context: Optional[Dict[str, Any]] = None
    error_details: Optional[str] = None
    metadata: Optional[Dict[str, Any]] = None


class FeedbackCollector
    #     """
    #     Feedback collector for TRM-Agent self-improvement system.

    #     This class activates the existing feedback mechanism in the component manager
    #     and provides automated collection of optimization success/failure metrics.
    #     """

    #     def __init__(self, component_manager: ComponentManager = None, trm_agent: TRMAgent = None):
    #         """Initialize feedback collector."""
    #         if NOODLE_DEBUG:
                logger.setLevel(logging.DEBUG)

    self.component_manager = component_manager
    self.trm_agent = trm_agent

    #         # Feedback storage
    self.feedback_entries: List[FeedbackEntry] = []
    self.processed_feedback: List[str] = []

    #         # Configuration
    self.config = {
    #             'enabled': NOODLE_FEEDBACK_ENABLED,
    #             'storage_file': NOODLE_FEEDBACK_STORAGE,
    #             'retention_count': NOODLE_FEEDBACK_RETENTION,
    #             'auto_learning': NOODLE_AUTO_LEARNING,
    #             'batch_size': 50,  # Process feedback in batches
    #             'learning_interval': 300  # 5 minutes
    #         }

    #         # Threading
    self._lock = threading.RLock()
    self._processing_thread = None
    self._running = False

    #         # Statistics
    self.statistics = {
    #             'total_feedback': 0,
    #             'successful_optimizations': 0,
    #             'failed_optimizations': 0,
    #             'performance_comparisons': 0,
    #             'learning_updates': 0,
    #             'last_processed': 0.0
    #         }

    #         # Load existing feedback
            self._load_feedback_data()

            logger.info("Feedback collector initialized")

    #     def activate(self) -> bool:
    #         """
    #         Activate the feedback collection system.

    #         Returns:
    #             True if activation successful, False otherwise.
    #         """
    #         with self._lock:
    #             if not self.config['enabled']:
                    logger.info("Feedback collection disabled by configuration")
    #                 return False

    #             try:
    #                 # Start background processing thread
                    self._start_processing_thread()

    #                 # Integrate with component manager
                    self._integrate_with_component_manager()

    #                 # Integrate with TRM-Agent
                    self._integrate_with_trm_agent()

                    logger.info("Feedback collection system activated")
    #                 return True

    #             except Exception as e:
                    logger.error(f"Failed to activate feedback collection: {str(e)}")
    #                 return False

    #     def _start_processing_thread(self):
    #         """Start the background feedback processing thread."""
    #         if self._processing_thread and self._processing_thread.is_alive():
    #             return

    self._running = True
    self._processing_thread = threading.Thread(
    target = self._processing_worker,
    daemon = True
    #         )
            self._processing_thread.start()

    #     def _integrate_with_component_manager(self):
    #         """Integrate with the component manager for feedback collection."""
    #         if not self.component_manager:
    #             logger.warning("No component manager provided for integration")
    #             return

    #         # Hook into component manager's decision history
    original_execute_component = self.component_manager.execute_component

    #         def wrapped_execute_component(component_name, *args, context=None, **kwargs):
    #             """Wrapper to collect feedback from component execution."""
    #             # Execute original method
    #             try:
    result = math.multiply(original_execute_component(component_name,, args, context=context, **kwargs))

    #                 # Collect feedback for successful execution
                    self._collect_execution_feedback(
    component_name, context, success = True, result=result
    #                 )

    #                 return result

    #             except Exception as e:
    #                 # Collect feedback for failed execution
                    self._collect_execution_feedback(
    component_name, context, success = False, error=str(e)
    #                 )
    #                 raise

    #         # Replace the method with our wrapper
    self.component_manager.execute_component = wrapped_execute_component

    #         logger.info("Integrated with component manager for feedback collection")

    #     def _integrate_with_trm_agent(self):
    #         """Integrate with the TRM-Agent for optimization feedback."""
    #         if not self.trm_agent:
    #             logger.warning("No TRM-Agent provided for integration")
    #             return

    #         # Hook into TRM-Agent's optimization results
    original_collect_feedback = self.trm_agent.collect_feedback

    #         def wrapped_collect_feedback(optimization_result, original_metrics, optimized_metrics):
    #             """Wrapper to collect TRM-Agent optimization feedback."""
    #             # Call original method
    feedback_id = original_collect_feedback(
    #                 optimization_result, original_metrics, optimized_metrics
    #             )

    #             # Collect our own feedback
                self._collect_optimization_feedback(
    #                 optimization_result, original_metrics, optimized_metrics
    #             )

    #             return feedback_id

    #         # Replace the method with our wrapper
    self.trm_agent.collect_feedback = wrapped_collect_feedback

    #         logger.info("Integrated with TRM-Agent for optimization feedback")

    #     def _collect_execution_feedback(self,
    #                                 component_name: str,
    #                                 context: Dict[str, Any],
    #                                 success: bool,
    result: Any = None,
    error: str = None):
    #         """Collect feedback from component execution."""
    #         try:
    #             # Get implementation type from context or decision history
    implementation_type = ComponentType.PYTHON
    #             if self.component_manager:
    decisions = self.component_manager.get_decision_history(limit=1)
    #                 if decisions and decisions[0].component_name == component_name:
    implementation_type = decisions[0].component_type

    #             # Create feedback entry
    feedback = FeedbackEntry(
    feedback_id = str(uuid.uuid4()),
    feedback_type = FeedbackType.COMPONENT_SELECTION,
    timestamp = time.time(),
    component_name = component_name,
    implementation_type = implementation_type,
    status = FeedbackStatus.PENDING,
    execution_context = context,
    error_details = error,
    #                 metadata={'result': str(result)[:100] if result else None}
    #             )

    #             with self._lock:
                    self.feedback_entries.append(feedback)
    self.statistics['total_feedback'] + = 1

    #             if NOODLE_DEBUG:
    #                 logger.debug(f"Collected execution feedback for {component_name}: {success}")

    #         except Exception as e:
                logger.error(f"Error collecting execution feedback: {str(e)}")

    #     def _collect_optimization_feedback(self,
    #                                   optimization_result: OptimizationResult,
    #                                   original_metrics: ExecutionMetrics,
    #                                   optimized_metrics: ExecutionMetrics):
    #         """Collect feedback from TRM-Agent optimization."""
    #         try:
    #             # Calculate performance improvement
    improvement = 0.0
    #             if (original_metrics.execution_time > 0 and
    #                 optimized_metrics.execution_time > 0):
    improvement = math.subtract((original_metrics.execution_time, optimized_metrics.execution_time) / original_metrics.execution_time)

    #             # Determine feedback type
    feedback_type = FeedbackType.OPTIMIZATION_SUCCESS
    #             if optimization_result.success is False:
    feedback_type = FeedbackType.OPTIMIZATION_FAILURE

    #             # Create feedback entry
    feedback = FeedbackEntry(
    feedback_id = str(uuid.uuid4()),
    feedback_type = feedback_type,
    timestamp = time.time(),
    component_name = optimization_result.component_name or "unknown",
    implementation_type = ComponentType.NOODLECORE,
    status = FeedbackStatus.PENDING,
    optimization_result = optimization_result,
    optimization_strategy = getattr(optimization_result, 'strategy', None),
    optimization_confidence = getattr(optimization_result, 'confidence', None),
    #                 original_metrics=asdict(original_metrics) if original_metrics else None,
    #                 optimized_metrics=asdict(optimized_metrics) if optimized_metrics else None,
    performance_improvement = improvement
    #             )

    #             with self._lock:
                    self.feedback_entries.append(feedback)
    self.statistics['total_feedback'] + = 1

    #                 if feedback_type == FeedbackType.OPTIMIZATION_SUCCESS:
    self.statistics['successful_optimizations'] + = 1
    #                 else:
    self.statistics['failed_optimizations'] + = 1

    #             if NOODLE_DEBUG:
                    logger.debug(f"Collected optimization feedback: {feedback_type.value}")

    #         except Exception as e:
                logger.error(f"Error collecting optimization feedback: {str(e)}")

    #     def collect_performance_comparison(self,
    #                                  component_name: str,
    #                                  comparison_results: Dict[str, Any]):
    #         """Collect feedback from performance comparison."""
    #         try:
    #             # Create feedback entry
    feedback = FeedbackEntry(
    feedback_id = str(uuid.uuid4()),
    feedback_type = FeedbackType.PERFORMANCE_COMPARISON,
    timestamp = time.time(),
    component_name = component_name,
    implementation_type = ComponentType.HYBRID,  # Comparison involves multiple types
    status = FeedbackStatus.PENDING,
    metadata = comparison_results
    #             )

    #             with self._lock:
                    self.feedback_entries.append(feedback)
    self.statistics['total_feedback'] + = 1
    self.statistics['performance_comparisons'] + = 1

    #             if NOODLE_DEBUG:
    #                 logger.debug(f"Collected performance comparison for {component_name}")

    #         except Exception as e:
                logger.error(f"Error collecting performance comparison: {str(e)}")

    #     def _processing_worker(self):
    #         """Background worker for processing feedback."""
            logger.info("Feedback processing worker started")

    #         while self._running:
    #             try:
    #                 # Process pending feedback
                    self._process_pending_feedback()

    #                 # Trigger learning if enabled
    #                 if self.config['auto_learning']:
                        self._trigger_learning()

    #                 # Sleep until next processing cycle
                    time.sleep(self.config['learning_interval'])

    #             except Exception as e:
                    logger.error(f"Error in feedback processing worker: {str(e)}")
                    time.sleep(30)  # Brief pause before retrying

            logger.info("Feedback processing worker stopped")

    #     def _process_pending_feedback(self):
    #         """Process pending feedback entries."""
    #         with self._lock:
    #             # Get pending feedback entries
    #             pending = [f for f in self.feedback_entries if f.status == FeedbackStatus.PENDING]

    #             if not pending:
    #                 return

    #             # Process in batches
    batch = pending[:self.config['batch_size']]

    #             for feedback in batch:
    #                 try:
    #                     # Process based on feedback type
    #                     if feedback.feedback_type == FeedbackType.OPTIMIZATION_SUCCESS:
                            self._process_optimization_success(feedback)
    #                     elif feedback.feedback_type == FeedbackType.OPTIMIZATION_FAILURE:
                            self._process_optimization_failure(feedback)
    #                     elif feedback.feedback_type == FeedbackType.PERFORMANCE_COMPARISON:
                            self._process_performance_comparison(feedback)
    #                     elif feedback.feedback_type == FeedbackType.COMPONENT_SELECTION:
                            self._process_component_selection(feedback)

    #                     # Mark as processed
    feedback.status = FeedbackStatus.PROCESSED
                        self.processed_feedback.append(feedback.feedback_id)

    #                 except Exception as e:
                        logger.error(f"Error processing feedback {feedback.feedback_id}: {str(e)}")
    feedback.status = FeedbackStatus.ERROR

    #         # Save processed feedback
            self._save_feedback_data()

    #     def _process_optimization_success(self, feedback: FeedbackEntry):
    #         """Process successful optimization feedback."""
    #         try:
    #             # Extract learning data
    #             if feedback.optimization_result and feedback.original_metrics and feedback.optimized_metrics:
    #                 # Calculate improvement metrics
    improvement_data = {
    #                     'component_name': feedback.component_name,
    #                     'strategy': feedback.optimization_strategy,
    #                     'confidence': feedback.optimization_confidence,
    #                     'execution_time_improvement': feedback.performance_improvement,
                        'memory_improvement': self._calculate_improvement(
                            feedback.original_metrics.get('memory_usage', 0),
                            feedback.optimized_metrics.get('memory_usage', 0)
    #                     ),
    #                     'timestamp': feedback.timestamp
    #                 }

    #                 # Store for learning
                    self._store_learning_data('optimization_success', improvement_data)

    #                 if NOODLE_DEBUG:
    #                     logger.debug(f"Processed optimization success for {feedback.component_name}")

    #         except Exception as e:
                logger.error(f"Error processing optimization success: {str(e)}")

    #     def _process_optimization_failure(self, feedback: FeedbackEntry):
    #         """Process failed optimization feedback."""
    #         try:
    #             # Extract failure analysis data
    #             if feedback.optimization_result:
    failure_data = {
    #                     'component_name': feedback.component_name,
    #                     'strategy': feedback.optimization_strategy,
    #                     'confidence': feedback.optimization_confidence,
                        'error_type': getattr(feedback.optimization_result, 'error_type', 'unknown'),
                        'error_message': getattr(feedback.optimization_result, 'error_message', ''),
    #                     'timestamp': feedback.timestamp
    #                 }

    #                 # Store for learning
                    self._store_learning_data('optimization_failure', failure_data)

    #                 if NOODLE_DEBUG:
    #                     logger.debug(f"Processed optimization failure for {feedback.component_name}")

    #         except Exception as e:
                logger.error(f"Error processing optimization failure: {str(e)}")

    #     def _process_performance_comparison(self, feedback: FeedbackEntry):
    #         """Process performance comparison feedback."""
    #         try:
    #             # Extract comparison data
    #             if feedback.metadata:
    comparison_data = {
    #                     'component_name': feedback.component_name,
    #                     'comparison_results': feedback.metadata,
    #                     'timestamp': feedback.timestamp
    #                 }

    #                 # Store for learning
                    self._store_learning_data('performance_comparison', comparison_data)

    #                 if NOODLE_DEBUG:
    #                     logger.debug(f"Processed performance comparison for {feedback.component_name}")

    #         except Exception as e:
                logger.error(f"Error processing performance comparison: {str(e)}")

    #     def _process_component_selection(self, feedback: FeedbackEntry):
    #         """Process component selection feedback."""
    #         try:
    #             # Extract selection data
    selection_data = {
    #                 'component_name': feedback.component_name,
    #                 'implementation_type': feedback.implementation_type.value,
    #                 'context': feedback.execution_context,
    #                 'success': feedback.error_details is None,
    #                 'timestamp': feedback.timestamp
    #             }

    #             # Store for learning
                self._store_learning_data('component_selection', selection_data)

    #             if NOODLE_DEBUG:
    #                 logger.debug(f"Processed component selection for {feedback.component_name}")

    #         except Exception as e:
                logger.error(f"Error processing component selection: {str(e)}")

    #     def _calculate_improvement(self, original: float, optimized: float) -> float:
    #         """Calculate percentage improvement between original and optimized values."""
    #         if original == 0:
    #             return 0.0
            return (original - optimized) / original

    #     def _store_learning_data(self, data_type: str, data: Dict[str, Any]):
    #         """Store data for learning system."""
    #         try:
    #             # In a real implementation, this would store to a database
    #             # For now, we'll store in memory and periodically save to file
    learning_file = self.config['storage_file'].replace('.json', '_learning.json')

    #             # Load existing learning data
    learning_data = {}
    #             if os.path.exists(learning_file):
    #                 try:
    #                     with open(learning_file, 'r') as f:
    learning_data = json.load(f)
    #                 except Exception:
    learning_data = {}

    #             # Add new data
    #             if data_type not in learning_data:
    learning_data[data_type] = []

                learning_data[data_type].append(data)

    #             # Keep only recent data
    #             if len(learning_data[data_type]) > self.config['retention_count']:
    learning_data[data_type] = learning_data[data_type][-self.config['retention_count']:]

    #             # Save to file
    #             with open(learning_file, 'w') as f:
    json.dump(learning_data, f, indent = 2, default=str)

    self.statistics['learning_updates'] + = 1

    #         except Exception as e:
                logger.error(f"Error storing learning data: {str(e)}")

    #     def _trigger_learning(self):
    #         """Trigger learning based on collected feedback."""
    #         if not self.trm_agent:
    #             return

    #         try:
    #             # Check if we have enough data for learning
    #             with self._lock:
    successful_count = self.statistics['successful_optimizations']
    failed_count = self.statistics['failed_optimizations']

    #             if successful_count + failed_count >= 10:  # Minimum threshold
    #                 # Trigger TRM-Agent model update
    success = self.trm_agent.update_model()

    #                 if success:
                        logger.info("Triggered TRM-Agent model update based on feedback")

    #                     # Mark feedback as learned
    #                     with self._lock:
    #                         for feedback in self.feedback_entries:
    #                             if feedback.status == FeedbackStatus.PROCESSED:
    feedback.status = FeedbackStatus.LEARNED

    self.statistics['learning_updates'] + = 1
    #                 else:
                        logger.warning("TRM-Agent model update failed")

    #         except Exception as e:
                logger.error(f"Error triggering learning: {str(e)}")

    #     def _load_feedback_data(self):
    #         """Load existing feedback data from storage."""
    #         try:
    #             if os.path.exists(self.config['storage_file']):
    #                 with open(self.config['storage_file'], 'r') as f:
    data = json.load(f)

    #                 # Load feedback entries
    #                 for feedback_data in data.get('feedback_entries', []):
    feedback = FeedbackEntry(
    feedback_id = feedback_data['feedback_id'],
    feedback_type = FeedbackType(feedback_data['feedback_type']),
    timestamp = feedback_data['timestamp'],
    component_name = feedback_data['component_name'],
    implementation_type = ComponentType(feedback_data['implementation_type']),
    status = FeedbackStatus(feedback_data['status']),
    original_metrics = feedback_data.get('original_metrics'),
    optimized_metrics = feedback_data.get('optimized_metrics'),
    performance_improvement = feedback_data.get('performance_improvement'),
    optimization_result = feedback_data.get('optimization_result'),
    optimization_strategy = feedback_data.get('optimization_strategy'),
    optimization_confidence = feedback_data.get('optimization_confidence'),
    execution_context = feedback_data.get('execution_context'),
    error_details = feedback_data.get('error_details'),
    metadata = feedback_data.get('metadata')
    #                     )
                        self.feedback_entries.append(feedback)

    #                 # Load statistics
                    self.statistics.update(data.get('statistics', {}))

                    logger.info(f"Loaded {len(self.feedback_entries)} feedback entries")

    #         except Exception as e:
                logger.warning(f"Could not load feedback data: {str(e)}")

    #     def _save_feedback_data(self):
    #         """Save feedback data to storage."""
    #         try:
    #             # Prepare data for saving
    data = {
    #                 'feedback_entries': [asdict(f) for f in self.feedback_entries],
    #                 'statistics': self.statistics,
                    'last_updated': time.time()
    #             }

    #             # Save to file
    #             with open(self.config['storage_file'], 'w') as f:
    json.dump(data, f, indent = 2, default=str)

    self.statistics['last_processed'] = time.time()

    #         except Exception as e:
                logger.error(f"Error saving feedback data: {str(e)}")

    #     def get_feedback_summary(self, limit: int = 100) -> Dict[str, Any]:
    #         """
    #         Get a summary of collected feedback.

    #         Args:
    #             limit: Maximum number of recent feedback entries to include.

    #         Returns:
    #             Feedback summary dictionary.
    #         """
    #         with self._lock:
    #             recent_feedback = self.feedback_entries[-limit:] if self.feedback_entries else []

    #             # Count by type
    type_counts = {}
    #             for feedback in recent_feedback:
    feedback_type = feedback.feedback_type.value
    type_counts[feedback_type] = math.add(type_counts.get(feedback_type, 0), 1)

    #             # Count by status
    status_counts = {}
    #             for feedback in recent_feedback:
    status = feedback.status.value
    status_counts[status] = math.add(status_counts.get(status, 0), 1)

    #             return {
                    'total_entries': len(self.feedback_entries),
                    'recent_entries': len(recent_feedback),
    #                 'type_counts': type_counts,
    #                 'status_counts': status_counts,
                    'statistics': self.statistics.copy(),
                    'config': self.config.copy()
    #             }

    #     def get_learning_data(self, data_type: str = None, limit: int = 100) -> List[Dict[str, Any]]:
    #         """
    #         Get learning data for analysis.

    #         Args:
    #             data_type: Specific type of learning data to get, or None for all.
    #             limit: Maximum number of entries to return.

    #         Returns:
    #             List of learning data entries.
    #         """
    #         try:
    learning_file = self.config['storage_file'].replace('.json', '_learning.json')

    #             if not os.path.exists(learning_file):
    #                 return []

    #             with open(learning_file, 'r') as f:
    learning_data = json.load(f)

    #             if data_type:
                    return learning_data.get(data_type, [])[-limit:]

    #             # Return all types combined
    all_data = []
    #             for type_data in learning_data.values():
                    all_data.extend(type_data)

    #             return all_data[-limit:]

    #         except Exception as e:
                logger.error(f"Error getting learning data: {str(e)}")
    #             return []

    #     def deactivate(self) -> bool:
    #         """
    #         Deactivate the feedback collection system.

    #         Returns:
    #             True if deactivation successful, False otherwise.
    #         """
    #         with self._lock:
    #             try:
    #                 # Stop processing thread
    self._running = False
    #                 if self._processing_thread and self._processing_thread.is_alive():
    self._processing_thread.join(timeout = 5.0)

    #                 # Save final data
                    self._save_feedback_data()

                    logger.info("Feedback collection system deactivated")
    #                 return True

    #             except Exception as e:
                    logger.error(f"Error deactivating feedback collection: {str(e)}")
    #                 return False


# Global instance for convenience
_global_feedback_collector_instance = None


def get_feedback_collector(component_manager: ComponentManager = None,
trm_agent: TRMAgent = math.subtract(None), > FeedbackCollector:)
#     """
#     Get a global feedback collector instance.

#     Args:
#         component_manager: Component manager instance to integrate with.
#         trm_agent: TRM-Agent instance to integrate with.

#     Returns:
#         A FeedbackCollector instance.
#     """
#     global _global_feedback_collector_instance

#     if _global_feedback_collector_instance is None:
_global_feedback_collector_instance = FeedbackCollector(component_manager, trm_agent)

#     return _global_feedback_collector_instance