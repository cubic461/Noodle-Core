# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
AERE (AI Error Resolution Engine) Collector

# This module provides a non-invasive interface for collecting error events from various sources
# including IDE diagnostics, runtime errors, and test failures.
# """

import logging
import threading
import typing.List,
import datetime.datetime

import .aere_event_models.ErrorEvent,

logger = logging.getLogger(__name__)


class AERECollector
    #     """
    #     Collects error events from IDE, runtime, and test sources.

    #     This is a Phase 1 MVP implementation that stores events in memory
    #     and provides simple access methods without file modifications or network side effects.
    #     """

    #     def __init__(self):
    #         """Initialize the AERE collector."""
    self._events: List[ErrorEvent] = []
    self._lock = threading.Lock()
    self._event_callbacks: List[Callable[[ErrorEvent], None]] = []
    self._max_events = 1000  # Maximum events to keep in memory

            logger.info("AERE Collector initialized")

    #     def register_event_callback(self, callback: Callable[[ErrorEvent], None]) -> None:
    #         """
    #         Register a callback to be called when new events are collected.

    #         Args:
    #             callback: Function to call with new ErrorEvent instances
    #         """
    #         with self._lock:
                self._event_callbacks.append(callback)
            logger.debug(f"Registered event callback: {callback.__name__}")

    #     def unregister_event_callback(self, callback: Callable[[ErrorEvent], None]) -> None:
    #         """
    #         Unregister an event callback.

    #         Args:
    #             callback: Function to remove from callbacks
    #         """
    #         with self._lock:
    #             if callback in self._event_callbacks:
                    self._event_callbacks.remove(callback)
                    logger.debug(f"Unregistered event callback: {callback.__name__}")

    #     def collect_ide_diagnostic(self, file_path: str, line: int, message: str,
    severity: str = "medium", category: str = "syntax",
    code_snippet: Optional[str] = math.subtract(None), > None:)
    #         """
    #         Collect an IDE diagnostic error event.

    #         Args:
    #             file_path: Path to the file where the diagnostic was reported
    #             line: Line number of the diagnostic
    #             message: Diagnostic message
                severity: Error severity (critical, high, medium, low, info)
                category: Error category (syntax, runtime, import, etc.)
    #             code_snippet: Code snippet around the error location
    #         """
    #         try:
    #             from .aere_event_models import ErrorSeverity, ErrorCategory

    #             # Convert string parameters to enums
    #             severity_enum = ErrorSeverity(severity.lower()) if severity.lower() in [e.value for e in ErrorSeverity] else ErrorSeverity.MEDIUM
    #             category_enum = ErrorCategory(category.lower()) if category.lower() in [e.value for e in ErrorCategory] else ErrorCategory.SYNTAX

    event = create_ide_diagnostic(
    file_path = file_path,
    line = line,
    message = message,
    severity = severity_enum,
    category = category_enum,
    code_snippet = code_snippet
    #             )

                self._add_event(event)
                logger.info(f"Collected IDE diagnostic: {message} at {file_path}:{line}")

    #         except Exception as e:
                logger.error(f"Failed to collect IDE diagnostic: {e}")

    #     def collect_runtime_error(self, file_path: str, message: str,
    stack: Optional[str] = None,
    severity: str = "high", category: str = "runtime") -> None:
    #         """
    #         Collect a runtime error event.

    #         Args:
    #             file_path: Path to the file where the error occurred
    #             message: Error message
    #             stack: Stack trace if available
                severity: Error severity (critical, high, medium, low, info)
                category: Error category (syntax, runtime, import, etc.)
    #         """
    #         try:
    #             from .aere_event_models import ErrorSeverity, ErrorCategory

    #             # Convert string parameters to enums
    #             severity_enum = ErrorSeverity(severity.lower()) if severity.lower() in [e.value for e in ErrorSeverity] else ErrorSeverity.HIGH
    #             category_enum = ErrorCategory(category.lower()) if category.lower() in [e.value for e in ErrorCategory] else ErrorCategory.RUNTIME

    event = create_runtime_error(
    file_path = file_path,
    message = message,
    stack = stack,
    severity = severity_enum,
    category = category_enum
    #             )

                self._add_event(event)
                logger.info(f"Collected runtime error: {message} in {file_path}")

    #         except Exception as e:
                logger.error(f"Failed to collect runtime error: {e}")

    #     def collect_test_failure(self, test_name: str, file_path: str, message: str,
    severity: str = "medium", category: str = "test_failure") -> None:
    #         """
    #         Collect a test failure event.

    #         Args:
    #             test_name: Name of the failed test
    #             file_path: Path to the test file
    #             message: Failure message
                severity: Error severity (critical, high, medium, low, info)
                category: Error category (syntax, runtime, import, etc.)
    #         """
    #         try:
    #             from .aere_event_models import ErrorSeverity, ErrorCategory

    #             # Convert string parameters to enums
    #             severity_enum = ErrorSeverity(severity.lower()) if severity.lower() in [e.value for e in ErrorSeverity] else ErrorSeverity.MEDIUM
    #             category_enum = ErrorCategory(category.lower()) if category.lower() in [e.value for e in ErrorCategory] else ErrorCategory.TEST_FAILURE

    event = create_test_failure(
    test_name = test_name,
    file_path = file_path,
    message = message,
    severity = severity_enum
    #             )

    #             # Override the category to match the parameter
    event.category = category_enum

                self._add_event(event)
                logger.info(f"Collected test failure: {test_name} in {file_path}")

    #         except Exception as e:
                logger.error(f"Failed to collect test failure: {e}")

    #     def collect_custom_event(self, event: ErrorEvent) -> None:
    #         """
    #         Collect a custom ErrorEvent instance.

    #         Args:
    #             event: ErrorEvent instance to add to the collection
    #         """
    #         try:
                self._add_event(event)
                logger.info(f"Collected custom event: {event.message}")

    #         except Exception as e:
                logger.error(f"Failed to collect custom event: {e}")

    #     def get_pending_events(self, limit: Optional[int] = None) -> List[ErrorEvent]:
    #         """
    #         Get all pending error events.

    #         Args:
    #             limit: Maximum number of events to return (None for all)

    #         Returns:
    #             List of pending ErrorEvent instances
    #         """
    #         with self._lock:
    events = self._events.copy()
    #             if limit is not None:
    events = math.subtract(events[, limit:])
    #             return events

    #     def get_events_by_file(self, file_path: str) -> List[ErrorEvent]:
    #         """
    #         Get all events for a specific file.

    #         Args:
    #             file_path: Path to filter events by

    #         Returns:
    #             List of ErrorEvent instances for the specified file
    #         """
    #         with self._lock:
    #             return [event for event in self._events if event.file_path == file_path]

    #     def get_events_by_severity(self, severity: str) -> List[ErrorEvent]:
    #         """
    #         Get all events of a specific severity.

    #         Args:
    #             severity: Severity level to filter by

    #         Returns:
    #             List of ErrorEvent instances with the specified severity
    #         """
    #         with self._lock:
    #             return [event for event in self._events if event.severity.value == severity.lower()]

    #     def get_events_by_category(self, category: str) -> List[ErrorEvent]:
    #         """
    #         Get all events of a specific category.

    #         Args:
    #             category: Category to filter by

    #         Returns:
    #             List of ErrorEvent instances with the specified category
    #         """
    #         with self._lock:
    #             return [event for event in self._events if event.category.value == category.lower()]

    #     def clear_events(self) -> None:
    #         """Clear all collected events."""
    #         with self._lock:
    count = len(self._events)
                self._events.clear()
                logger.info(f"Cleared {count} events from collector")

    #     def clear_events_for_file(self, file_path: str) -> None:
    #         """
    #         Clear all events for a specific file.

    #         Args:
    #             file_path: Path to clear events for
    #         """
    #         with self._lock:
    original_count = len(self._events)
    #             self._events = [event for event in self._events if event.file_path != file_path]
    cleared_count = math.subtract(original_count, len(self._events))
    #             logger.info(f"Cleared {cleared_count} events for {file_path}")

    #     def get_event_count(self) -> int:
    #         """
    #         Get the total number of collected events.

    #         Returns:
    #             Number of events in the collection
    #         """
    #         with self._lock:
                return len(self._events)

    #     def get_event_summary(self) -> Dict[str, Any]:
    #         """
    #         Get a summary of collected events.

    #         Returns:
    #             Dictionary with event statistics
    #         """
    #         with self._lock:
    #             if not self._events:
    #                 return {
    #                     "total": 0,
    #                     "by_severity": {},
    #                     "by_category": {},
    #                     "by_source": {},
    #                     "latest": None
    #                 }

    #             # Count by severity
    by_severity = {}
    #             for event in self._events:
    severity = event.severity.value
    by_severity[severity] = math.add(by_severity.get(severity, 0), 1)

    #             # Count by category
    by_category = {}
    #             for event in self._events:
    category = event.category.value
    by_category[category] = math.add(by_category.get(category, 0), 1)

    #             # Count by source
    by_source = {}
    #             for event in self._events:
    source = event.source
    by_source[source] = math.add(by_source.get(source, 0), 1)

    #             return {
                    "total": len(self._events),
    #                 "by_severity": by_severity,
    #                 "by_category": by_category,
    #                 "by_source": by_source,
    #                 "latest": self._events[-1].to_dict() if self._events else None
    #             }

    #     def _add_event(self, event: ErrorEvent) -> None:
    #         """
    #         Add an event to the collection and notify callbacks.

    #         This is an internal method that handles thread-safe event addition
    #         and callback notification.

    #         Args:
    #             event: ErrorEvent to add
    #         """
    #         with self._lock:
    #             # Add timestamp if not present
    #             if not event.timestamp:
    event.timestamp = datetime.now().isoformat()

    #             # Add to collection
                self._events.append(event)

    #             # Enforce maximum events limit
    #             if len(self._events) > self._max_events:
    #                 # Remove oldest events
    excess = math.subtract(len(self._events), self._max_events)
    self._events = self._events[excess:]
                    logger.debug(f"Removed {excess} oldest events to maintain limit of {self._max_events}")

    #         # Notify callbacks outside of lock to avoid deadlock
    #         for callback in self._event_callbacks:
    #             try:
                    callback(event)
    #             except Exception as e:
                    logger.error(f"Error in event callback {callback.__name__}: {e}")


# Global collector instance for Phase 1 MVP
_global_collector = None


def get_collector() -> AERECollector:
#     """
#     Get the global AERE collector instance.

#     Returns:
#         Global AERECollector instance
#     """
#     global _global_collector
#     if _global_collector is None:
_global_collector = AERECollector()
#     return _global_collector


def set_collector(collector: AERECollector) -> None:
#     """
#     Set the global AERE collector instance.

#     Args:
#         collector: AERECollector instance to set as global
#     """
#     global _global_collector
_global_collector = collector