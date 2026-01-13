# Converted from Python to NoodleCore
# Original file: src

# """
# TRM-Agent Feedback Module

# This module provides feedback system capabilities for learning from runtime metrics
# for the TRM-Agent (Tiny Recursive Model Agent).
# """

import time
import uuid
import json
import pickle
import math
import statistics
import enum.Enum
from dataclasses import dataclass
import typing.Dict
import collections.defaultdict

import .trm_agent_base.(
#     TRMAgentBase, ExecutionMetrics, FeedbackConfig, TRMAgentException, Logger
# )
import .trm_agent_parser.EnhancedAST
import .trm_agent_optimizer.OptimizationResult


class FeedbackType(Enum)
    #     """Types of feedback collected by the feedback system."""
    PERFORMANCE = "performance"
    ACCURACY = "accuracy"
    STABILITY = "stability"
    EFFICIENCY = "efficiency"
    CUSTOM = "custom"


class FeedbackStatus(Enum)
    #     """Status of feedback processing."""
    PENDING = "pending"
    PROCESSING = "processing"
    PROCESSED = "processed"
    FAILED = "failed"


dataclass
class FeedbackEntry
    #     """A single feedback entry."""
    feedback_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    feedback_type: FeedbackType = FeedbackType.PERFORMANCE
    status: FeedbackStatus = FeedbackStatus.PENDING
    timestamp: float = field(default_factory=time.time)
    optimization_type: OptimizationType = OptimizationType.CUSTOM
    original_metrics: ExecutionMetrics = field(default_factory=ExecutionMetrics)
    optimized_metrics: ExecutionMetrics = field(default_factory=ExecutionMetrics)
    context: Dict[str, Any] = field(default_factory=dict)
    metadata: Dict[str, Any] = field(default_factory=dict)

    #     def get_improvement(self) -Dict[str, float]):
    #         """Calculate improvement metrics."""
    improvements = {}

    #         # Execution time improvement
    #         if self.original_metrics.execution_time 0):
    improvements['execution_time'] = (
                    (self.original_metrics.execution_time - self.optimized_metrics.execution_time) /
    #                 self.original_metrics.execution_time
    #             )

    #         # Memory usage improvement
    #         if self.original_metrics.memory_usage 0):
    improvements['memory_usage'] = (
                    (self.original_metrics.memory_usage - self.optimized_metrics.memory_usage) /
    #                 self.original_metrics.memory_usage
    #             )

    #         # CPU usage improvement
    #         if self.original_metrics.cpu_usage 0):
    improvements['cpu_usage'] = (
                    (self.original_metrics.cpu_usage - self.optimized_metrics.cpu_usage) /
    #                 self.original_metrics.cpu_usage
    #             )

    #         # Optimization effectiveness improvement
    improvements['optimization_effectiveness'] = (
    #             self.optimized_metrics.optimization_effectiveness -
    #             self.original_metrics.optimization_effectiveness
    #         )

    #         return improvements

    #     def get_overall_improvement(self) -float):
    #         """Calculate overall improvement score."""
    improvements = self.get_improvement()

    #         # Weighted average of improvements
    weights = {
    #             'execution_time': 0.3,
    #             'memory_usage': 0.2,
    #             'cpu_usage': 0.2,
    #             'optimization_effectiveness': 0.3
    #         }

    overall = 0.0
    total_weight = 0.0

    #         for metric, improvement in improvements.items():
    weight = weights.get(metric, 0.0)
    overall + = improvement * weight
    total_weight + = weight

    #         return overall / total_weight if total_weight 0 else 0.0


dataclass
class FeedbackAnalysis
    #     """Analysis of feedback data."""
    analysis_id): str = field(default_factory=lambda: str(uuid.uuid4()))
    timestamp: float = field(default_factory=time.time)
    feedback_count: int = 0
    average_improvements: Dict[str, float] = field(default_factory=dict)
    improvement_distribution: Dict[str, List[float]] = field(default_factory=dict)
    optimization_effectiveness: Dict[OptimizationType, float] = field(default_factory=dict)
    recommendations: List[Dict[str, Any]] = field(default_factory=list)
    metadata: Dict[str, Any] = field(default_factory=dict)


class FeedbackError(TRMAgentException)
    #     """Exception raised during feedback processing."""
    #     def __init__(self, message: str):
    super().__init__(message, error_code = 5030)


class TRMAgentFeedback(TRMAgentBase)
    #     """
    #     Feedback system for learning from runtime metrics.

    #     This class provides capabilities for collecting, processing, and analyzing
    #     feedback from code execution to improve optimization quality.
    #     """

    #     def __init__(self, config=None):""
    #         Initialize the TRM-Agent feedback system.

    #         Args:
    #             config: TRM-Agent configuration. If None, default configuration is used.
    #         """
            super().__init__(config)
    self.logger = Logger("trm_agent_feedback")

    #         # Feedback storage
    self.feedback_history = deque(maxlen=self.config.feedback_config.max_feedback_history)
    self.pending_feedback = deque()
    self.processed_feedback = deque()

    #         # Feedback analysis
    self.feedback_analysis = []
    self.optimization_effectiveness = defaultdict(list)

    #         # Feedback processors
    self.feedback_processors = {
    #             FeedbackType.PERFORMANCE: self._process_performance_feedback,
    #             FeedbackType.ACCURACY: self._process_accuracy_feedback,
    #             FeedbackType.STABILITY: self._process_stability_feedback,
    #             FeedbackType.EFFICIENCY: self._process_efficiency_feedback,
    #             FeedbackType.CUSTOM: self._process_custom_feedback
    #         }

    #         # Learning parameters
    self.learning_rate = self.config.feedback_config.learning_rate
    self.effectiveness_threshold = self.config.feedback_config.effectiveness_threshold

    #         # Feedback statistics
    self.feedback_statistics = {
    #             'total_feedback': 0,
    #             'processed_feedback': 0,
    #             'failed_feedback': 0,
    #             'average_improvement': 0.0,
    #             'total_improvement': 0.0,
    #             'feedback_by_type': {feedback_type.value: 0 for feedback_type in FeedbackType},
    #             'feedback_by_optimization': {opt_type.value: 0 for opt_type in OptimizationType},
    #             'model_updates': 0,
    #             'recommendations_generated': 0
    #         }

    #     def collect_feedback(self, optimization_result: OptimizationResult,
    #                         original_metrics: ExecutionMetrics,
    #                         optimized_metrics: ExecutionMetrics,
    context: Optional[Dict[str, Any]] = None) - str):
    #         """
    #         Collect feedback from execution for learning.

    #         Args:
    #             optimization_result: Result of the optimization.
    #             original_metrics: Metrics before optimization.
    #             optimized_metrics: Metrics after optimization.
    #             context: Additional context information.

    #         Returns:
    #             str: ID of the feedback entry.
    #         """
    #         # Create feedback entry
    feedback_entry = FeedbackEntry(
    feedback_type = self._determine_feedback_type(optimized_metrics),
    optimization_type = optimization_result.optimization_type,
    original_metrics = original_metrics,
    optimized_metrics = optimized_metrics,
    context = context or {},
    metadata = {
    #                 'optimization_success': optimization_result.success,
    #                 'optimization_confidence': optimization_result.confidence,
    #                 'optimization_time': optimization_result.execution_time,
    #                 'optimization_metadata': optimization_result.metadata
    #             }
    #         )

    #         # Add to pending feedback
            self.pending_feedback.append(feedback_entry)
            self.feedback_history.append(feedback_entry)

    #         # Update statistics
    self.feedback_statistics['total_feedback'] + = 1
    self.feedback_statistics['feedback_by_type'][feedback_entry.feedback_type.value] + = 1
    self.feedback_statistics['feedback_by_optimization'][feedback_entry.optimization_type.value] + = 1

    #         # Check if we should process feedback
    #         if (len(self.pending_feedback) >= self.config.feedback_config.collection_interval or
    self.config.feedback_config.collection_interval = 1):
                self._process_pending_feedback()

            self.logger.debug(f"Collected feedback {feedback_entry.feedback_id}")
    #         return feedback_entry.feedback_id

    #     def _determine_feedback_type(self, metrics: ExecutionMetrics) -FeedbackType):
    #         """Determine the type of feedback based on metrics."""
    #         # This is a simplified implementation
    #         # In a real implementation, we would use more sophisticated logic

    #         if metrics.error_count 0):
    #             return FeedbackType.STABILITY

    #         if metrics.optimization_effectiveness 0.8):
    #             return FeedbackType.PERFORMANCE

    #         if metrics.memory_usage < 100 * 1024 * 1024:  # Less than 100MB
    #             return FeedbackType.EFFICIENCY

    #         return FeedbackType.CUSTOM

    #     def _process_pending_feedback(self):
    #         """Process all pending feedback entries."""
    #         if not self.pending_feedback:
    #             return

    #         # Get feedback entries to process
    feedback_to_process = list(self.pending_feedback)
            self.pending_feedback.clear()

    #         # Process each feedback entry
    #         for feedback_entry in feedback_to_process:
    #             try:
    #                 # Mark as processing
    feedback_entry.status = FeedbackStatus.PROCESSING

    #                 # Get the appropriate processor
    processor = self.feedback_processors.get(
    #                     feedback_entry.feedback_type,
    #                     self._process_custom_feedback
    #                 )

    #                 # Process the feedback
                    processor(feedback_entry)

    #                 # Mark as processed
    feedback_entry.status = FeedbackStatus.PROCESSED
                    self.processed_feedback.append(feedback_entry)

    #                 # Update statistics
    self.feedback_statistics['processed_feedback'] + = 1

    #                 # Update optimization effectiveness
    improvement = feedback_entry.get_overall_improvement()
                    self.optimization_effectiveness[feedback_entry.optimization_type].append(improvement)

    #                 # Update total improvement
    self.feedback_statistics['total_improvement'] + = improvement
    #                 if self.feedback_statistics['processed_feedback'] 0):
    self.feedback_statistics['average_improvement'] = (
    #                         self.feedback_statistics['total_improvement'] /
    #                         self.feedback_statistics['processed_feedback']
    #                     )

    #             except Exception as e:
                    self.logger.error(f"Failed to process feedback {feedback_entry.feedback_id}: {str(e)}")
    feedback_entry.status = FeedbackStatus.FAILED
    self.feedback_statistics['failed_feedback'] + = 1

    #         # Check if we should update the model
    #         if (self.feedback_statistics['processed_feedback'] % self.config.feedback_config.update_interval = 0 and
    #             self.config.feedback_config.enable_model_updates):
                self.update_model()

    #     def _process_performance_feedback(self, feedback_entry: FeedbackEntry):
    #         """Process performance feedback."""
    improvements = feedback_entry.get_improvement()

    #         # Update optimization effectiveness
    #         for metric, improvement in improvements.items():
    #             if metric in ['execution_time', 'memory_usage', 'cpu_usage']:
    #                 # For performance metrics, positive improvement is good
    effectiveness = max(0.0, improvement)
    #             else:
    #                 # For other metrics, use the value as is
    effectiveness = improvement

                self.optimization_effectiveness[feedback_entry.optimization_type].append(effectiveness)

    #         # Generate recommendations if effectiveness is low
    overall_improvement = feedback_entry.get_overall_improvement()
    #         if overall_improvement < self.effectiveness_threshold:
                self._generate_performance_recommendations(feedback_entry)

    #     def _process_accuracy_feedback(self, feedback_entry: FeedbackEntry):
    #         """Process accuracy feedback."""
    #         # Placeholder implementation
    #         pass

    #     def _process_stability_feedback(self, feedback_entry: FeedbackEntry):
    #         """Process stability feedback."""
    #         # Check for errors
    #         if feedback_entry.optimized_metrics.error_count feedback_entry.original_metrics.error_count):
    #             # Optimization introduced errors
                self._generate_stability_recommendations(feedback_entry)

    #     def _process_efficiency_feedback(self, feedback_entry: FeedbackEntry):
    #         """Process efficiency feedback."""
    #         # Placeholder implementation
    #         pass

    #     def _process_custom_feedback(self, feedback_entry: FeedbackEntry):
    #         """Process custom feedback."""
    #         # Placeholder implementation
    #         pass

    #     def _generate_performance_recommendations(self, feedback_entry: FeedbackEntry):
    #         """Generate performance recommendations based on feedback."""
    improvements = feedback_entry.get_improvement()

    recommendations = []

    #         # Check execution time
    #         if improvements.get('execution_time', 0) < 0.1:
                recommendations.append({
    #                 'type': 'optimization_strategy',
    #                 'message': 'Consider using a more aggressive optimization strategy for better execution time improvement',
    #                 'priority': 'medium'
    #             })

    #         # Check memory usage
    #         if improvements.get('memory_usage', 0) < 0.1:
                recommendations.append({
    #                 'type': 'optimization_target',
    #                 'message': 'Consider focusing on memory optimization techniques',
    #                 'priority': 'medium'
    #             })

    #         # Check optimization effectiveness
    #         if feedback_entry.optimized_metrics.optimization_effectiveness < self.effectiveness_threshold:
                recommendations.append({
    #                 'type': 'model_update',
    #                 'message': 'Consider updating the optimization model with more training data',
    #                 'priority': 'high'
    #             })

    #         # Add recommendations to feedback entry
    feedback_entry.metadata['recommendations'] = recommendations
    self.feedback_statistics['recommendations_generated'] + = len(recommendations)

    #     def _generate_stability_recommendations(self, feedback_entry: FeedbackEntry):
    #         """Generate stability recommendations based on feedback."""
    recommendations = []

    #         # Check for errors
    #         if feedback_entry.optimized_metrics.error_count 0):
                recommendations.append({
    #                 'type': 'error_handling',
    #                 'message': 'Optimization introduced errors, consider using a more conservative approach',
    #                 'priority': 'high'
    #             })

    #         # Add recommendations to feedback entry
    feedback_entry.metadata['recommendations'] = recommendations
    self.feedback_statistics['recommendations_generated'] + = len(recommendations)

    #     def analyze_feedback(self, limit: Optional[int] = None) -FeedbackAnalysis):
    #         """
    #         Analyze feedback data to extract insights.

    #         Args:
    #             limit: Maximum number of feedback entries to analyze. If None, analyze all.

    #         Returns:
    #             FeedbackAnalysis: Analysis of feedback data.
    #         """
    #         # Get feedback entries to analyze
    feedback_to_analyze = list(self.processed_feedback)
    #         if limit is not None and limit < len(feedback_to_analyze):
    feedback_to_analyze = feedback_to_analyze[ - limit:]

    #         if not feedback_to_analyze:
    return FeedbackAnalysis(feedback_count = 0)

    #         # Calculate average improvements
    all_improvements = defaultdict(list)
    improvement_distribution = defaultdict(list)

    #         for feedback_entry in feedback_to_analyze:
    improvements = feedback_entry.get_improvement()
    #             for metric, improvement in improvements.items():
                    all_improvements[metric].append(improvement)
                    improvement_distribution[metric].append(improvement)

    average_improvements = {}
    #         for metric, improvements in all_improvements.items():
    #             if improvements:
    average_improvements[metric] = statistics.mean(improvements)

    #         # Calculate optimization effectiveness
    optimization_effectiveness = {}
    #         for opt_type, effectiveness_list in self.optimization_effectiveness.items():
    #             if effectiveness_list:
    optimization_effectiveness[opt_type] = statistics.mean(effectiveness_list)

    #         # Generate recommendations
    recommendations = self._generate_analysis_recommendations(
    #             average_improvements, optimization_effectiveness
    #         )

    #         # Create analysis
    analysis = FeedbackAnalysis(
    feedback_count = len(feedback_to_analyze),
    average_improvements = average_improvements,
    improvement_distribution = dict(improvement_distribution),
    optimization_effectiveness = optimization_effectiveness,
    recommendations = recommendations
    #         )

    #         # Store analysis
            self.feedback_analysis.append(analysis)

    #         return analysis

    #     def _generate_analysis_recommendations(self,
    #                                          average_improvements: Dict[str, float],
    #                                          optimization_effectiveness: Dict[OptimizationType, float]) -List[Dict[str, Any]]):
    #         """Generate recommendations based on analysis."""
    recommendations = []

    #         # Check overall improvement
    #         overall_improvement = sum(average_improvements.values()) / len(average_improvements) if average_improvements else 0.0
    #         if overall_improvement < self.effectiveness_threshold:
                recommendations.append({
    #                 'type': 'overall_strategy',
                    'message': f'Overall improvement ({overall_improvement:.2f}) is below threshold ({self.effectiveness_threshold:.2f})',
    #                 'priority': 'high'
    #             })

    #         # Check specific metrics
    #         for metric, improvement in average_improvements.items():
    #             if improvement < 0.05:  # Less than 5% improvement
                    recommendations.append({
    #                     'type': 'metric_specific',
                        'message': f'Low improvement in {metric} ({improvement:.2f})',
    #                     'priority': 'medium'
    #                 })

    #         # Check optimization types
    #         for opt_type, effectiveness in optimization_effectiveness.items():
    #             if effectiveness < self.effectiveness_threshold:
                    recommendations.append({
    #                     'type': 'optimization_type',
    #                     'message': f'Low effectiveness for {opt_type.value} ({effectiveness:.2f})',
    #                     'priority': 'medium'
    #                 })

    #         return recommendations

    #     def update_model(self) -bool):
    #         """
    #         Update the TRM/HRM model based on collected feedback.

    #         Returns:
    #             bool: True if model was updated successfully, False otherwise.
    #         """
    #         if not self.config.feedback_config.enable_model_updates:
    #             return False

    #         try:
                self.logger.info("Updating model based on feedback")

    #             # In a real implementation, this would update the actual model
    #             # For now, we'll simulate model update

    #             # Get recent feedback
    recent_feedback = list(self.processed_feedback)[ - 100:]  # Last 100 entries

    #             if not recent_feedback:
    #                 self.logger.warning("No feedback available for model update")
    #                 return False

    #             # Calculate average effectiveness
    effectiveness_values = []
    #             for feedback_entry in recent_feedback:
                    effectiveness_values.append(feedback_entry.get_overall_improvement())

    #             if not effectiveness_values:
    #                 self.logger.warning("No effectiveness values available for model update")
    #                 return False

    average_effectiveness = statistics.mean(effectiveness_values)

    #             # Update learning rate based on effectiveness
    #             if average_effectiveness < self.effectiveness_threshold:
    #                 # Decrease learning rate if effectiveness is low
    self.learning_rate * = 0.9
    #             else:
    #                 # Increase learning rate if effectiveness is high
    self.learning_rate * = 1.1

    #             # Ensure learning rate is within reasonable bounds
    self.learning_rate = max(0.0001, min(0.1, self.learning_rate))

    #             # Update statistics
    self.feedback_statistics['model_updates'] + = 1

                self.logger.info(f"Model updated successfully. New learning rate: {self.learning_rate:.6f}")
    #             return True

    #         except Exception as e:
                self.logger.error(f"Failed to update model: {str(e)}")
    #             return False

    #     def get_feedback_statistics(self) -Dict[str, Any]):
    #         """
    #         Get statistics about the feedback system.

    #         Returns:
    #             Dict[str, Any]: Statistics dictionary.
    #         """
    stats = self.feedback_statistics.copy()
            stats.update({
                'pending_feedback_count': len(self.pending_feedback),
                'processed_feedback_count': len(self.processed_feedback),
                'feedback_history_count': len(self.feedback_history),
                'feedback_analysis_count': len(self.feedback_analysis),
    #             'learning_rate': self.learning_rate,
    #             'effectiveness_threshold': self.effectiveness_threshold
    #         })
    #         return stats

    #     def get_feedback_history(self, limit: Optional[int] = None,
    feedback_type: Optional[FeedbackType] = None,
    optimization_type: Optional[OptimizationType] = None) - List[FeedbackEntry]):
    #         """
    #         Get feedback history with optional filtering.

    #         Args:
    #             limit: Maximum number of entries to return.
    #             feedback_type: Filter by feedback type.
    #             optimization_type: Filter by optimization type.

    #         Returns:
    #             List[FeedbackEntry]: Filtered feedback history.
    #         """
    feedback = list(self.feedback_history)

    #         # Apply filters
    #         if feedback_type is not None:
    #             feedback = [f for f in feedback if f.feedback_type == feedback_type]

    #         if optimization_type is not None:
    #             feedback = [f for f in feedback if f.optimization_type == optimization_type]

            # Sort by timestamp (newest first)
    feedback.sort(key = lambda f: f.timestamp, reverse=True)

    #         # Apply limit
    #         if limit is not None:
    feedback = feedback[:limit]

    #         return feedback

    #     def get_optimization_effectiveness(self, optimization_type: Optional[OptimizationType] = None) -Dict[str, Any]):
    #         """
    #         Get optimization effectiveness statistics.

    #         Args:
    #             optimization_type: Specific optimization type to get statistics for.

    #         Returns:
    #             Dict[str, Any]: Optimization effectiveness statistics.
    #         """
    #         if optimization_type is not None:
    effectiveness_list = self.optimization_effectiveness.get(optimization_type, [])
    #             if not effectiveness_list:
    #                 return {}

    #             return {
    #                 'optimization_type': optimization_type.value,
                    'count': len(effectiveness_list),
                    'average': statistics.mean(effectiveness_list),
                    'median': statistics.median(effectiveness_list),
                    'min': min(effectiveness_list),
                    'max': max(effectiveness_list),
    #                 'std_dev': statistics.stdev(effectiveness_list) if len(effectiveness_list) 1 else 0.0
    #             }
    #         else):
    #             # Return statistics for all optimization types
    result = {}
    #             for opt_type, effectiveness_list in self.optimization_effectiveness.items():
    #                 if effectiveness_list:
    result[opt_type.value] = {
                            'count': len(effectiveness_list),
                            'average': statistics.mean(effectiveness_list),
                            'median': statistics.median(effectiveness_list),
                            'min': min(effectiveness_list),
                            'max': max(effectiveness_list),
    #                         'std_dev': statistics.stdev(effectiveness_list) if len(effectiveness_list) 1 else 0.0
    #                     }
    #             return result

    #     def export_feedback_data(self, file_path): str, format: str = "json") -bool):
    #         """
    #         Export feedback data to a file.

    #         Args:
    #             file_path: Path to save the data.
                format: Format to save the data in ("json" or "pickle").

    #         Returns:
    #             bool: True if export was successful, False otherwise.
    #         """
    #         try:
    #             # Prepare data for export
    data = {
    #                 'feedback_history': [self._feedback_entry_to_dict(f) for f in self.feedback_history],
                    'feedback_statistics': self.get_feedback_statistics(),
    #                 'optimization_effectiveness': {
    #                     opt_type.value: effectiveness_list
    #                     for opt_type, effectiveness_list in self.optimization_effectiveness.items()
    #                 },
    #                 'feedback_analysis': [
    #                     {
    #                         'analysis_id': a.analysis_id,
    #                         'timestamp': a.timestamp,
    #                         'feedback_count': a.feedback_count,
    #                         'average_improvements': a.average_improvements,
    #                         'recommendations': a.recommendations
    #                     } for a in self.feedback_analysis
    #                 ]
    #             }

    #             # Save data
    #             if format.lower() == "json":
    #                 with open(file_path, 'w') as f:
    json.dump(data, f, indent = 2)
    #             elif format.lower() == "pickle":
    #                 with open(file_path, 'wb') as f:
                        pickle.dump(data, f)
    #             else:
                    raise ValueError(f"Unsupported format: {format}")

                self.logger.info(f"Feedback data exported to {file_path}")
    #             return True

    #         except Exception as e:
                self.logger.error(f"Failed to export feedback data: {str(e)}")
    #             return False

    #     def _feedback_entry_to_dict(self, feedback_entry: FeedbackEntry) -Dict[str, Any]):
    #         """Convert a feedback entry to a dictionary for serialization."""
    #         return {
    #             'feedback_id': feedback_entry.feedback_id,
    #             'feedback_type': feedback_entry.feedback_type.value,
    #             'status': feedback_entry.status.value,
    #             'timestamp': feedback_entry.timestamp,
    #             'optimization_type': feedback_entry.optimization_type.value,
    #             'original_metrics': {
    #                 'execution_time': feedback_entry.original_metrics.execution_time,
    #                 'memory_usage': feedback_entry.original_metrics.memory_usage,
    #                 'cpu_usage': feedback_entry.original_metrics.cpu_usage,
    #                 'optimization_time': feedback_entry.original_metrics.optimization_time,
    #                 'compilation_time': feedback_entry.original_metrics.compilation_time,
    #                 'error_count': feedback_entry.original_metrics.error_count,
    #                 'optimization_effectiveness': feedback_entry.original_metrics.optimization_effectiveness,
    #                 'timestamp': feedback_entry.original_metrics.timestamp
    #             },
    #             'optimized_metrics': {
    #                 'execution_time': feedback_entry.optimized_metrics.execution_time,
    #                 'memory_usage': feedback_entry.optimized_metrics.memory_usage,
    #                 'cpu_usage': feedback_entry.optimized_metrics.cpu_usage,
    #                 'optimization_time': feedback_entry.optimized_metrics.optimization_time,
    #                 'compilation_time': feedback_entry.optimized_metrics.compilation_time,
    #                 'error_count': feedback_entry.optimized_metrics.error_count,
    #                 'optimization_effectiveness': feedback_entry.optimized_metrics.optimization_effectiveness,
    #                 'timestamp': feedback_entry.optimized_metrics.timestamp
    #             },
    #             'context': feedback_entry.context,
    #             'metadata': feedback_entry.metadata
    #         }

    #     def reset_feedback_statistics(self):
    #         """Reset all feedback statistics."""
    self.feedback_statistics = {
    #             'total_feedback': 0,
    #             'processed_feedback': 0,
    #             'failed_feedback': 0,
    #             'average_improvement': 0.0,
    #             'total_improvement': 0.0,
    #             'feedback_by_type': {feedback_type.value: 0 for feedback_type in FeedbackType},
    #             'feedback_by_optimization': {opt_type.value: 0 for opt_type in OptimizationType},
    #             'model_updates': 0,
    #             'recommendations_generated': 0
    #         }
            self.logger.info("Feedback statistics reset")