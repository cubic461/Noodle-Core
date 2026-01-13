# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Learning Feedback Processor - User feedback collection and processing for NoodleCore Learning System

# This module handles collecting, processing, and analyzing user feedback about AI performance
# and learning outcomes. It integrates with existing feedback systems and provides mechanisms
# for incorporating user insights into the learning process.

# Features:
- Multi-modal feedback collection (rating, comments, explicit feedback)
# - Feedback processing and analysis
# - Sentiment analysis and categorization
# - Integration with learning controller for adaptive learning
# - Feedback-based learning adjustments
# - User preference learning and adaptation
# - Feedback trend analysis and reporting
# """

import os
import json
import logging
import time
import threading
import uuid
import re
import typing.Any,
import dataclasses.dataclass,
import enum.Enum
import collections.defaultdict,
import datetime.datetime,

# Configure logging
logger = logging.getLogger(__name__)

# Environment variables
NOODLE_DEBUG = os.environ.get("NOODLE_DEBUG", "0") == "1"
NOODLE_FEEDBACK_RETENTION_DAYS = int(os.environ.get("NOODLE_FEEDBACK_RETENTION_DAYS", "30"))


class FeedbackType(Enum)
    #     """Types of feedback."""
    RATING = "rating"
    COMMENT = "comment"
    LIKE_DISLIKE = "like_dislike"
    USABILITY = "usability"
    PERFORMANCE = "performance"
    SUGGESTION = "suggestion"
    BUG_REPORT = "bug_report"
    FEATURE_REQUEST = "feature_request"
    LEARNING_OUTCOME = "learning_outcome"


class FeedbackCategory(Enum)
    #     """Categories for feedback classification."""
    POSITIVE = "positive"
    NEGATIVE = "negative"
    NEUTRAL = "neutral"
    IMPROVEMENT = "improvement"
    BUG = "bug"
    FEATURE = "feature"
    PERFORMANCE = "performance"
    USABILITY = "usability"
    LEARNING = "learning"
    GENERAL = "general"


class SentimentType(Enum)
    #     """Sentiment classification."""
    VERY_POSITIVE = "very_positive"
    POSITIVE = "positive"
    NEUTRAL = "neutral"
    NEGATIVE = "negative"
    VERY_NEGATIVE = "very_negative"


class FeedbackPriority(Enum)
    #     """Feedback priority levels."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


# @dataclass
class FeedbackItem
    #     """Represents a single feedback item."""
    #     feedback_id: str
    #     user_id: Optional[str]
    #     feedback_type: FeedbackType
    #     content: str
    rating: Optional[int] = math.subtract(None  # 1, 5 scale)
    context: Dict[str, Any] = None
    timestamp: float = None
    category: Optional[FeedbackCategory] = None
    sentiment: Optional[SentimentType] = None
    priority: FeedbackPriority = FeedbackPriority.MEDIUM
    processed: bool = False
    action_taken: bool = False
    metadata: Dict[str, Any] = None

    #     def __post_init__(self):
    #         if self.timestamp is None:
    self.timestamp = time.time()
    #         if self.context is None:
    self.context = {}
    #         if self.metadata is None:
    self.metadata = {}


# @dataclass
class FeedbackAnalytics
    #     """Analytics for feedback data."""
    #     total_feedback: int
    #     average_rating: float
    #     sentiment_distribution: Dict[SentimentType, int]
    #     category_distribution: Dict[FeedbackCategory, int]
    #     feedback_trends: Dict[str, Any]
    #     top_issues: List[Dict[str, Any]]
    #     improvement_suggestions: List[str]
    #     user_satisfaction_score: float


class FeedbackProcessor
    #     """
    #     Learning feedback processor for NoodleCore Learning System.

    #     This class handles collecting, processing, and analyzing user feedback
    #     to improve the learning system and user experience.
    #     """

    #     def __init__(self):
    #         """Initialize the feedback processor."""
    #         if NOODLE_DEBUG:
                logger.setLevel(logging.DEBUG)

    #         # Feedback storage
    self.feedback_items: List[FeedbackItem] = []
    self.feedback_lock = threading.RLock()

    #         # Processing queues
    self.pending_feedback: List[FeedbackItem] = []
    self.processed_feedback: List[FeedbackItem] = []
    self.processing_lock = threading.RLock()

    #         # Analytics
    self.feedback_analytics_cache = None
    self.analytics_lock = threading.RLock()
    self.last_analytics_update = 0

    #         # Configuration
    self.processor_config = {
    #             'feedback_retention_days': NOODLE_FEEDBACK_RETENTION_DAYS,
    #             'enable_sentiment_analysis': True,
    #             'enable_auto_categorization': True,
    #             'enable_trend_analysis': True,
    #             'min_feedback_for_analysis': 10,
    #             'sentiment_keywords': {
    #                 'positive': ['good', 'great', 'excellent', 'amazing', 'love', 'perfect', 'awesome', 'fantastic'],
    #                 'negative': ['bad', 'terrible', 'awful', 'hate', 'horrible', 'worst', 'broken', 'useless'],
    #                 'improvement': ['improve', 'better', 'enhance', 'upgrade', 'optimize', 'fix', 'faster', 'smoother']
    #             },
    #             'auto_action_triggers': {
    #                 'critical_feedback': ['broken', 'crash', 'error', 'urgent', 'immediate'],
    #                 'feature_requests': ['feature', 'add', 'implement', 'new', 'support'],
    #                 'performance_issues': ['slow', 'lag', 'performance', 'speed', 'fast']
    #             }
    #         }

    #         # Load configuration from file
            self._load_processor_configuration()

            logger.info("Learning Feedback Processor initialized")

    #     def _load_processor_configuration(self):
    #         """Load processor configuration from file."""
    #         try:
    config_path = "feedback_processor_config.json"
    #             if os.path.exists(config_path):
    #                 with open(config_path, 'r') as f:
    config_data = json.load(f)

                    self.processor_config.update(config_data.get('global_config', {}))

    #                 # Load sentiment keywords
    #                 if 'sentiment_keywords' in config_data:
                        self.processor_config['sentiment_keywords'].update(
    #                         config_data['sentiment_keywords']
    #                     )

                    logger.info("Loaded feedback processor configuration from file")
    #             else:
                    logger.info("No feedback processor configuration file found, using defaults")

    #         except Exception as e:
                logger.error(f"Failed to load feedback processor configuration: {str(e)}")

    #     def _save_processor_configuration(self):
    #         """Save processor configuration to file."""
    #         try:
    config_data = {
    #                 'global_config': {
    #                     k: v for k, v in self.processor_config.items()
    #                     if k not in ['sentiment_keywords', 'auto_action_triggers']
    #                 },
    #                 'sentiment_keywords': self.processor_config['sentiment_keywords'],
    #                 'auto_action_triggers': self.processor_config['auto_action_triggers']
    #             }

    #             with open("feedback_processor_config.json", 'w') as f:
    json.dump(config_data, f, indent = 2)

                logger.info("Saved feedback processor configuration to file")

    #         except Exception as e:
                logger.error(f"Failed to save feedback processor configuration: {str(e)}")

    #     def collect_feedback(self,
    #                         feedback_type: FeedbackType,
    #                         content: str,
    user_id: Optional[str] = None,
    rating: Optional[int] = None,
    context: Dict[str, Any] = math.subtract(None), > str:)
    #         """
    #         Collect feedback from users.

    #         Args:
    #             feedback_type: Type of feedback
    #             content: Feedback content
    #             user_id: Optional user ID
                rating: Optional rating (1-5)
    #             context: Additional context

    #         Returns:
    #             str: Feedback ID
    #         """
    feedback_id = str(uuid.uuid4())

    feedback_item = FeedbackItem(
    feedback_id = feedback_id,
    user_id = user_id,
    feedback_type = feedback_type,
    content = content,
    rating = rating,
    context = context or {}
    #         )

    #         with self.feedback_lock:
                self.feedback_items.append(feedback_item)
                self.pending_feedback.append(feedback_item)

    #         # Process feedback asynchronously
    threading.Thread(target = self._process_feedback_item, args=(feedback_item,), daemon=True).start()

            logger.info(f"Collected feedback {feedback_id} of type {feedback_type.value}")
    #         return feedback_id

    #     def _process_feedback_item(self, feedback_item: FeedbackItem):
    #         """Process a single feedback item."""
    #         try:
    #             # Analyze sentiment
    #             if self.processor_config['enable_sentiment_analysis']:
    sentiment = self._analyze_sentiment(feedback_item.content)
    feedback_item.sentiment = sentiment

    #             # Auto-categorize
    #             if self.processor_config['enable_auto_categorization']:
    category = self._categorize_feedback(feedback_item)
    feedback_item.category = category

    #             # Determine priority
    priority = self._determine_priority(feedback_item)
    feedback_item.priority = priority

    #             # Mark as processed
    feedback_item.processed = True

    #             # Move to processed queue
    #             with self.processing_lock:
    #                 if feedback_item in self.pending_feedback:
                        self.pending_feedback.remove(feedback_item)
                    self.processed_feedback.append(feedback_item)

    #             # Check for automatic actions
                self._check_auto_actions(feedback_item)

    #             # Invalidate analytics cache
    #             with self.analytics_lock:
    self.feedback_analytics_cache = None

                logger.debug(f"Processed feedback {feedback_item.feedback_id}")

    #         except Exception as e:
                logger.error(f"Failed to process feedback {feedback_item.feedback_id}: {str(e)}")

    #     def _analyze_sentiment(self, content: str) -> SentimentType:
    #         """Analyze sentiment of feedback content."""
    content_lower = content.lower()

    #         # Count positive and negative keywords
    #         positive_count = sum(1 for keyword in self.processor_config['sentiment_keywords']['positive']
    #                            if keyword in content_lower)
    #         negative_count = sum(1 for keyword in self.processor_config['sentiment_keywords']['negative']
    #                            if keyword in content_lower)
    #         improvement_count = sum(1 for keyword in self.processor_config['sentiment_keywords']['improvement']
    #                               if keyword in content_lower)

    #         # Determine sentiment based on keyword counts and content analysis
    #         if positive_count > negative_count + improvement_count:
    #             if positive_count >= 3:
    #                 return SentimentType.VERY_POSITIVE
    #             else:
    #                 return SentimentType.POSITIVE
    #         elif negative_count > positive_count + improvement_count:
    #             if negative_count >= 3:
    #                 return SentimentType.VERY_NEGATIVE
    #             else:
    #                 return SentimentType.NEGATIVE
    #         elif improvement_count > 0:
    #             return SentimentType.NEUTRAL  # Improvement suggestions are often neutral
    #         else:
    #             # Use additional heuristics
    #             if any(word in content_lower for word in ['love', 'perfect', 'amazing']):
    #                 return SentimentType.VERY_POSITIVE
    #             elif any(word in content_lower for word in ['hate', 'worst', 'terrible']):
    #                 return SentimentType.VERY_NEGATIVE
    #             else:
    #                 return SentimentType.NEUTRAL

    #     def _categorize_feedback(self, feedback_item: FeedbackItem) -> FeedbackCategory:
    #         """Categorize feedback automatically."""
    content_lower = feedback_item.content.lower()

    #         # Check for bug indicators
    #         if any(keyword in content_lower for keyword in ['bug', 'error', 'crash', 'broken', 'not working']):
    #             return FeedbackCategory.BUG

    #         # Check for feature requests
    #         if any(keyword in content_lower for keyword in ['feature', 'add', 'implement', 'new', 'support']):
    #             return FeedbackCategory.FEATURE

    #         # Check for performance issues
    #         if any(keyword in content_lower for keyword in ['slow', 'lag', 'performance', 'speed', 'fast']):
    #             return FeedbackCategory.PERFORMANCE

    #         # Check for usability issues
    #         if any(keyword in content_lower for keyword in ['confusing', 'hard', 'difficult', 'interface', 'ui']):
    #             return FeedbackCategory.USABILITY

    #         # Check for learning-related feedback
    #         if any(keyword in content_lower for keyword in ['learn', 'improve', 'better', 'accuracy', 'suggestion']):
    #             return FeedbackCategory.LEARNING

    #         # Use sentiment to categorize
    #         if feedback_item.sentiment in [SentimentType.VERY_POSITIVE, SentimentType.POSITIVE]:
    #             return FeedbackCategory.POSITIVE
    #         elif feedback_item.sentiment in [SentimentType.VERY_NEGATIVE, SentimentType.NEGATIVE]:
    #             return FeedbackCategory.NEGATIVE
    #         elif 'improve' in content_lower or 'better' in content_lower:
    #             return FeedbackCategory.IMPROVEMENT
    #         else:
    #             return FeedbackCategory.GENERAL

    #     def _determine_priority(self, feedback_item: FeedbackItem) -> FeedbackPriority:
    #         """Determine priority of feedback."""
    content_lower = feedback_item.content.lower()

    #         # Check for critical keywords
    critical_keywords = ['critical', 'urgent', 'immediate', 'crash', 'broken']
    #         if any(keyword in content_lower for keyword in critical_keywords):
    #             return FeedbackPriority.CRITICAL

    #         # High priority for negative sentiment
    #         if feedback_item.sentiment in [SentimentType.VERY_NEGATIVE, SentimentType.NEGATIVE]:
    #             return FeedbackPriority.HIGH

    #         # Check for high rating negative feedback (strong complaints)
    #         if feedback_item.rating and feedback_item.rating <= 2:
    #             return FeedbackPriority.HIGH

    #         # Check for bug reports
    #         if feedback_item.category == FeedbackCategory.BUG:
    #             return FeedbackPriority.HIGH

    #         # Medium priority for improvement suggestions
    #         if feedback_item.category == FeedbackCategory.IMPROVEMENT:
    #             return FeedbackPriority.MEDIUM

    #         # Default to medium priority
    #         return FeedbackPriority.MEDIUM

    #     def _check_auto_actions(self, feedback_item: FeedbackItem):
    #         """Check if feedback triggers automatic actions."""
    content_lower = feedback_item.content.lower()

    #         # Check for critical feedback that needs immediate attention
    #         if feedback_item.priority == FeedbackPriority.CRITICAL:
                logger.warning(f"Critical feedback received: {feedback_item.content[:100]}...")
    #             # Could trigger alerts, notifications, or immediate investigation

    #         # Check for auto-categorized actions
    #         if feedback_item.category == FeedbackCategory.BUG:
                logger.info(f"Bug report detected: {feedback_item.feedback_id}")
    #             # Could automatically create bug tickets or notifications

    #         elif feedback_item.category == FeedbackCategory.FEATURE:
                logger.info(f"Feature request detected: {feedback_item.feedback_id}")
    #             # Could automatically add to feature backlog

    #         elif feedback_item.category == FeedbackCategory.PERFORMANCE:
                logger.info(f"Performance issue detected: {feedback_item.feedback_id}")
    #             # Could trigger performance monitoring or optimization

    #     def get_feedback_analytics(self, time_window_days: int = 7) -> FeedbackAnalytics:
    #         """Get comprehensive feedback analytics."""
    current_time = time.time()
    cutoff_time = math.multiply(current_time - (time_window_days, 24 * 3600))

    #         with self.feedback_lock:
    #             # Filter feedback within time window
    #             recent_feedback = [f for f in self.feedback_items if f.timestamp >= cutoff_time]

    #         if not recent_feedback:
                return FeedbackAnalytics(
    total_feedback = 0,
    average_rating = 0.0,
    sentiment_distribution = {},
    category_distribution = {},
    feedback_trends = {},
    top_issues = [],
    improvement_suggestions = [],
    user_satisfaction_score = 0.0
    #             )

    #         # Calculate basic statistics
    total_feedback = len(recent_feedback)

    #         # Average rating
    #         ratings = [f.rating for f in recent_feedback if f.rating is not None]
    #         average_rating = sum(ratings) / len(ratings) if ratings else 0.0

    #         # Sentiment distribution
    #         sentiment_counts = Counter(f.sentiment for f in recent_feedback if f.sentiment)
    sentiment_distribution = dict(sentiment_counts)

    #         # Category distribution
    #         category_counts = Counter(f.category for f in recent_feedback if f.category)
    category_distribution = dict(category_counts)

            # User satisfaction score (based on ratings and sentiment)
    user_satisfaction_score = self._calculate_satisfaction_score(recent_feedback)

            # Feedback trends (simplified analysis)
    feedback_trends = self._analyze_feedback_trends(recent_feedback)

            # Top issues (most mentioned problems)
    top_issues = self._extract_top_issues(recent_feedback)

    #         # Improvement suggestions
    improvement_suggestions = self._extract_improvement_suggestions(recent_feedback)

            return FeedbackAnalytics(
    total_feedback = total_feedback,
    average_rating = average_rating,
    sentiment_distribution = sentiment_distribution,
    category_distribution = category_distribution,
    feedback_trends = feedback_trends,
    top_issues = top_issues,
    improvement_suggestions = improvement_suggestions,
    user_satisfaction_score = user_satisfaction_score
    #         )

    #     def _calculate_satisfaction_score(self, feedback_items: List[FeedbackItem]) -> float:
    #         """Calculate user satisfaction score based on feedback."""
    #         if not feedback_items:
    #             return 0.0

    #         # Weight different types of feedback
    positive_weight = 1.0
    negative_weight = 1.5  # Negative feedback weighs more
    neutral_weight = 0.5

    total_score = 0.0
    total_weight = 0.0

    #         for feedback in feedback_items:
    weight = neutral_weight
    score = 0.5  # Neutral baseline

    #             if feedback.sentiment == SentimentType.VERY_POSITIVE:
    weight = positive_weight
    score = 1.0
    #             elif feedback.sentiment == SentimentType.POSITIVE:
    weight = positive_weight
    score = 0.8
    #             elif feedback.sentiment == SentimentType.NEGATIVE:
    weight = negative_weight
    score = 0.2
    #             elif feedback.sentiment == SentimentType.VERY_NEGATIVE:
    weight = negative_weight
    score = 0.0

    #             # Factor in ratings if available
    #             if feedback.rating:
    rating_score = math.subtract((feedback.rating, 1) / 4.0  # Convert 1-5 to 0-1)
    score = math.add((score, rating_score) / 2.0  # Average sentiment and rating)

    total_score + = math.multiply(score, weight)
    total_weight + = weight

    #         return total_score / total_weight if total_weight > 0 else 0.0

    #     def _analyze_feedback_trends(self, feedback_items: List[FeedbackItem]) -> Dict[str, Any]:
    #         """Analyze feedback trends over time."""
    #         if len(feedback_items) < 2:
    #             return {"trend": "insufficient_data"}

    #         # Sort by timestamp
    sorted_feedback = sorted(feedback_items, key=lambda f: f.timestamp)

    #         # Calculate daily feedback counts
    daily_counts = defaultdict(int)
    daily_sentiment_scores = defaultdict(list)

    #         for feedback in sorted_feedback:
    day = datetime.fromtimestamp(feedback.timestamp).strftime('%Y-%m-%d')
    daily_counts[day] + = 1
    #             if feedback.sentiment:
    sentiment_score = {
    #                     SentimentType.VERY_POSITIVE: 2,
    #                     SentimentType.POSITIVE: 1,
    #                     SentimentType.NEUTRAL: 0,
    #                     SentimentType.NEGATIVE: -1,
    #                     SentimentType.VERY_NEGATIVE: -2
                    }.get(feedback.sentiment, 0)
                    daily_sentiment_scores[day].append(sentiment_score)

    #         # Determine overall trend
    #         if len(daily_counts) >= 3:
    counts = list(daily_counts.values())
    #             if counts[-1] > counts[0] * 1.2:
    trend = "increasing"
    #             elif counts[-1] < counts[0] * 0.8:
    trend = "decreasing"
    #             else:
    trend = "stable"
    #         else:
    trend = "insufficient_data"

    #         return {
    #             "trend": trend,
                "daily_distribution": dict(daily_counts),
                "total_days": len(daily_counts)
    #         }

    #     def _extract_top_issues(self, feedback_items: List[FeedbackItem]) -> List[Dict[str, Any]]:
    #         """Extract top issues from feedback."""
    issues = []

    #         # Focus on negative feedback
    #         negative_feedback = [f for f in feedback_items
    #                            if f.sentiment in [SentimentType.NEGATIVE, SentimentType.VERY_NEGATIVE]
                               or (f.category in [FeedbackCategory.BUG, FeedbackCategory.PERFORMANCE])]

    #         # Extract common problem keywords
    problem_keywords = ['bug', 'error', 'slow', 'crash', 'broken', 'confusing', 'difficult', 'problem']
    keyword_counts = Counter()

    #         for feedback in negative_feedback:
    content_lower = feedback.content.lower()
    #             for keyword in problem_keywords:
    #                 if keyword in content_lower:
    keyword_counts[keyword] + = 1

    #         # Return top issues
    #         for keyword, count in keyword_counts.most_common(5):
                issues.append({
    #                 "issue": keyword,
    #                 "frequency": count,
    #                 "percentage": (count / len(negative_feedback)) * 100 if negative_feedback else 0
    #             })

    #         return issues

    #     def _extract_improvement_suggestions(self, feedback_items: List[FeedbackItem]) -> List[str]:
    #         """Extract improvement suggestions from feedback."""
    suggestions = []

    #         # Focus on improvement and feature feedback
    #         improvement_feedback = [f for f in feedback_items
    #                               if f.category == FeedbackCategory.IMPROVEMENT
    or f.category = = FeedbackCategory.FEATURE
                                  or 'improve' in f.content.lower()
                                  or 'better' in f.content.lower()]

    #         # Extract suggestion patterns
    suggestion_patterns = [
                r'should (add|implement|include)',
    #             r'would like to see',
    #             r'it would be great if',
    #             r'consider adding',
    #             r'could you add',
                r'need(s)? to add'
    #         ]

    #         for feedback in improvement_feedback:
    #             for pattern in suggestion_patterns:
    matches = re.findall(pattern, feedback.content, re.IGNORECASE)
    #                 if matches:
    #                     # Extract the suggestion content
    sentences = feedback.content.split('.')
    #                     for sentence in sentences:
    #                         if any(word in sentence.lower() for word in ['add', 'implement', 'feature', 'improve']):
                                suggestions.append(sentence.strip())
    #                             break

    #         # Remove duplicates and return top suggestions
    unique_suggestions = list(set(suggestions))[:10]
    #         return unique_suggestions

    #     def get_feedback_by_category(self, category: FeedbackCategory) -> List[FeedbackItem]:
    #         """Get feedback items by category."""
    #         with self.feedback_lock:
    #             return [f for f in self.feedback_items if f.category == category]

    #     def get_feedback_by_priority(self, priority: FeedbackPriority) -> List[FeedbackItem]:
    #         """Get feedback items by priority."""
    #         with self.feedback_lock:
    #             return [f for f in self.feedback_items if f.priority == priority]

    #     def mark_action_taken(self, feedback_id: str) -> bool:
    #         """Mark that action has been taken on feedback."""
    #         with self.feedback_lock:
    #             for feedback in self.feedback_items:
    #                 if feedback.feedback_id == feedback_id:
    feedback.action_taken = True
    #                     return True
    #             return False

    #     def get_pending_feedback_count(self) -> int:
            """Get count of pending (unprocessed) feedback."""
    #         with self.processing_lock:
                return len(self.pending_feedback)

    #     def get_feedback_statistics(self) -> Dict[str, Any]:
    #         """Get overall feedback statistics."""
    #         with self.feedback_lock, self.processing_lock:
    total_feedback = len(self.feedback_items)
    processed_feedback = len(self.processed_feedback)
    pending_feedback = len(self.pending_feedback)

    #             # Calculate processing rate
    processing_rate = math.multiply(processed_feedback / max(total_feedback, 1), 100)

    #             return {
    #                 'total_feedback': total_feedback,
    #                 'processed_feedback': processed_feedback,
    #                 'pending_feedback': pending_feedback,
    #                 'processing_rate_percent': processing_rate,
    #                 'retention_days': self.processor_config['feedback_retention_days'],
                    'configuration': self.processor_config.copy()
    #             }

    #     def cleanup_old_feedback(self):
    #         """Clean up old feedback beyond retention period."""
    cutoff_time = time.time() - (self.processor_config['feedback_retention_days'] * 24 * 3600)

    #         with self.feedback_lock:
    #             # Keep only recent feedback
    old_count = len(self.feedback_items)
    #             self.feedback_items = [f for f in self.feedback_items if f.timestamp >= cutoff_time]
    removed_count = math.subtract(old_count, len(self.feedback_items))

    #             if removed_count > 0:
                    logger.info(f"Cleaned up {removed_count} old feedback items")

    #     def shutdown(self):
    #         """Shutdown the feedback processor."""
            logger.info("Shutting down learning feedback processor")

    #         # Save configuration
            self._save_processor_configuration()

    #         # Cleanup old feedback
            self.cleanup_old_feedback()

            logger.info("Learning feedback processor shutdown complete")


# Global instance for convenience
_global_feedback_processor = None


def get_feedback_processor() -> FeedbackProcessor:
#     """
#     Get a global feedback processor instance.

#     Returns:
#         FeedbackProcessor: A feedback processor instance
#     """
#     global _global_feedback_processor

#     if _global_feedback_processor is None:
_global_feedback_processor = FeedbackProcessor()

#     return _global_feedback_processor