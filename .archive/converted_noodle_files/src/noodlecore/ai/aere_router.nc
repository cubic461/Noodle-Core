# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
AERE (AI Error Resolution Engine) Router

# This module orchestrates the flow from error collection to analysis
# to suggestion delivery, acting as the central coordinator for the AERE system.
# """

import logging
import threading
import time
import typing.List,
import datetime.datetime

import .aere_event_models.ErrorEvent,
import .aere_collector.AERECollector,
import .aere_analyzer.AEREAnalyzer

logger = logging.getLogger(__name__)


class AERERouter
    #     """
    #     Orchestrates the AERE pipeline: collector → analyzer → suggestions.

    #     This is a Phase 1 MVP implementation that coordinates
    #     between components and delivers suggestions to registered callbacks
    #     without automatic patch application.
    #     """

    #     def __init__(self, collector: Optional[AERECollector] = None, analyzer: Optional[AEREAnalyzer] = None):
    #         """
    #         Initialize AERE router.

    #         Args:
    #             collector: AERECollector instance (uses global if None)
    #             analyzer: AEREAnalyzer instance (creates default if None)
    #         """
    self.collector = collector or get_collector()
    self.analyzer = analyzer or AEREAnalyzer()

    #         # Callbacks for delivering suggestions
    self._suggestion_callbacks: List[Callable[[PatchProposal], None]] = []
    self._resolution_callbacks: List[Callable[[ResolutionOutcome], None]] = []

    #         # Processing state
    self._is_processing = False
    self._processing_thread: Optional[threading.Thread] = None
    self._stop_event = threading.Event()

    #         # Statistics
    self._stats = {
    #             "events_processed": 0,
    #             "proposals_generated": 0,
    #             "suggestions_delivered": 0,
    #             "last_processing": None,
    #             "processing_errors": 0
    #         }

    #         # Register collector callback to automatically process new events
            self.collector.register_event_callback(self._on_error_event)

            logger.info("AERE Router initialized")

    #     def register_suggestion_callback(self, callback: Callable[[PatchProposal], None]) -> None:
    #         """
    #         Register a callback to receive patch proposals.

    #         Args:
    #             callback: Function to call with PatchProposal instances
    #         """
            self._suggestion_callbacks.append(callback)
    callback_name = getattr(callback, '__name__', str(callback))
            logger.debug(f"Registered suggestion callback: {callback_name}")

    #     def unregister_suggestion_callback(self, callback: Callable[[PatchProposal], None]) -> None:
    #         """
    #         Unregister a suggestion callback.

    #         Args:
    #             callback: Function to remove from callbacks
    #         """
    #         if callback in self._suggestion_callbacks:
                self._suggestion_callbacks.remove(callback)
    callback_name = getattr(callback, '__name__', str(callback))
                logger.debug(f"Unregistered suggestion callback: {callback_name}")

    #     def register_resolution_callback(self, callback: Callable[[ResolutionOutcome], None]) -> None:
    #         """
    #         Register a callback to receive resolution outcomes.

    #         Args:
    #             callback: Function to call with ResolutionOutcome instances
    #         """
            self._resolution_callbacks.append(callback)
    callback_name = getattr(callback, '__name__', str(callback))
            logger.debug(f"Registered resolution callback: {callback_name}")

    #     def unregister_resolution_callback(self, callback: Callable[[ResolutionOutcome], None]) -> None:
    #         """
    #         Unregister a resolution callback.

    #         Args:
    #             callback: Function to remove from callbacks
    #         """
    #         if callback in self._resolution_callbacks:
                self._resolution_callbacks.remove(callback)
    callback_name = getattr(callback, '__name__', str(callback))
                logger.debug(f"Unregistered resolution callback: {callback_name}")

    #     def start_processing(self, interval: float = 5.0) -> None:
    #         """
    #         Start automatic processing of collected events.

    #         Args:
    #             interval: Processing interval in seconds
    #         """
    #         if self._is_processing:
                logger.warning("Processing already started")
    #             return

    self._is_processing = True
            self._stop_event.clear()

    #         def processing_loop():
    #             while self._is_processing and not self._stop_event.wait(interval):
    #                 try:
                        self._process_pending_events()
    #                 except Exception as e:
                        logger.error(f"Error in processing loop: {e}")
    self._stats["processing_errors"] + = 1

    self._processing_thread = threading.Thread(target=processing_loop, daemon=True)
            self._processing_thread.start()

    #         logger.info(f"Started AERE processing with {interval}s interval")

    #     def stop_processing(self) -> None:
    #         """Stop automatic processing of events."""
    #         if not self._is_processing:
    #             return

    self._is_processing = False
            self._stop_event.set()

    #         if self._processing_thread and self._processing_thread.is_alive():
    self._processing_thread.join(timeout = 2.0)

            logger.info("Stopped AERE processing")

    #     def process_events_now(self) -> Dict[str, Any]:
    #         """
    #         Immediately process all pending events.

    #         Returns:
    #             Dictionary with processing results
    #         """
            return self._process_pending_events()

    #     def get_pending_proposals(self) -> List[PatchProposal]:
    #         """
    #         Get all generated patch proposals that haven't been delivered.

    #         Returns:
    #             List of pending PatchProposal instances
    #         """
    #         # In Phase 1 MVP, we don't track delivered proposals separately
    #         # All proposals are considered "pending" until delivered
    all_proposals = []

    #         # Get all events and generate proposals
    events = self.collector.get_pending_events()
    #         for event in events:
    proposals = self.analyzer.analyze_error(event)
                all_proposals.extend(proposals)

    #         return all_proposals

    #     def get_router_status(self) -> Dict[str, Any]:
    #         """
    #         Get the current status of the router.

    #         Returns:
    #             Dictionary with router status information
    #         """
    #         return {
    #             "is_processing": self._is_processing,
                "collector_events": self.collector.get_event_count(),
                "stats": self._stats.copy(),
                "suggestion_callbacks": len(self._suggestion_callbacks),
                "resolution_callbacks": len(self._resolution_callbacks)
    #         }

    #     def record_resolution_outcome(self, proposal_id: str, status: ResolutionStatus,
    applied: bool = False, details: str = "",
    error: Optional[str] = math.subtract(None), > None:)
    #         """
    #         Record the outcome of applying a patch proposal.

    #         Args:
    #             proposal_id: ID of the patch proposal
    #             status: Final resolution status
    #             applied: Whether the patch was actually applied
    #             details: Detailed outcome information
    #             error: Error message if application failed
    #         """
    outcome = ResolutionOutcome(
    status = status,
    patch_proposal_id = proposal_id,
    applied = applied,
    details = details,
    error = error
    #         )

    #         # Notify resolution callbacks
    #         for callback in self._resolution_callbacks:
    #             try:
                    callback(outcome)
    #             except Exception as e:
                    logger.error(f"Error in resolution callback: {e}")

    #         # Handle both enum and string status
    #         status_value = status.value if hasattr(status, 'value') else status
    #         logger.info(f"Recorded resolution outcome: {status_value} for proposal {proposal_id}")

    #     def _on_error_event(self, event: ErrorEvent) -> None:
    #         """
    #         Callback for when new error events are collected.

    #         Args:
    #             event: New ErrorEvent instance
    #         """
    #         # In Phase 1 MVP, we don't automatically process events
    #         # Processing is done on-demand or via the processing loop
            logger.debug(f"Received error event: {event.message}")

    #     def _process_pending_events(self) -> Dict[str, Any]:
    #         """
    #         Process all pending error events and generate suggestions.

    #         Returns:
    #             Dictionary with processing results
    #         """
    #         try:
    #             # Get pending events
    events = self.collector.get_pending_events()

    #             if not events:
    #                 return {
    #                     "events_processed": 0,
    #                     "proposals_generated": 0,
    #                     "suggestions_delivered": 0
    #                 }

    events_processed = 0
    proposals_generated = 0
    suggestions_delivered = 0

    #             # Process each event
    #             for event in events:
    #                 # Analyze error
    proposals = self.analyzer.analyze_error(event)
    proposals_generated + = len(proposals)

    #                 # Deliver suggestions
    #                 for proposal in proposals:
                        self._deliver_suggestion(proposal)
    suggestions_delivered + = 1

    events_processed + = 1

    #             # Update statistics
    self._stats["events_processed"] + = events_processed
    self._stats["proposals_generated"] + = proposals_generated
    self._stats["suggestions_delivered"] + = suggestions_delivered
    self._stats["last_processing"] = datetime.now().isoformat()

    #             # Clear processed events
                self.collector.clear_events()

                logger.info(f"Processed {events_processed} events, generated {proposals_generated} proposals, delivered {suggestions_delivered} suggestions")

    #             return {
    #                 "events_processed": events_processed,
    #                 "proposals_generated": proposals_generated,
    #                 "suggestions_delivered": suggestions_delivered
    #             }

    #         except Exception as e:
                logger.error(f"Error processing pending events: {e}")
    self._stats["processing_errors"] + = 1
    #             return {
    #                 "events_processed": 0,
    #                 "proposals_generated": 0,
    #                 "suggestions_delivered": 0,
                    "error": str(e)
    #             }

    #     def _deliver_suggestion(self, proposal: PatchProposal) -> None:
    #         """
    #         Deliver a patch proposal to all registered callbacks.

    #         Args:
    #             proposal: PatchProposal to deliver
    #         """
    #         for callback in self._suggestion_callbacks:
    #             try:
                    callback(proposal)
    #             except Exception as e:
    callback_name = getattr(callback, '__name__', str(callback))
                    logger.error(f"Error delivering suggestion to callback {callback_name}: {e}")

    #     def set_analyzer(self, analyzer: AEREAnalyzer) -> None:
    #         """
    #         Set the analyzer instance.

    #         Args:
    #             analyzer: AEREAnalyzer instance to use
    #         """
    self.analyzer = analyzer
            logger.info("Updated analyzer in AERE router")

    #     def set_collector(self, collector: AERECollector) -> None:
    #         """
    #         Set the collector instance.

    #         Args:
    #             collector: AERECollector instance to use
    #         """
    #         # Unregister from old collector
    #         if self.collector:
                self.collector.unregister_event_callback(self._on_error_event)

    #         # Set new collector and register callback
    self.collector = collector
            self.collector.register_event_callback(self._on_error_event)

            logger.info("Updated collector in AERE router")

    #     def get_processing_statistics(self) -> Dict[str, Any]:
    #         """
    #         Get detailed processing statistics.

    #         Returns:
    #             Dictionary with processing statistics
    #         """
    stats = self._stats.copy()
    stats["collector_summary"] = self.collector.get_event_summary()
    #         return stats


# Global router instance for Phase 1 MVP
_global_router = None


def get_router() -> AERERouter:
#     """
#     Get the global AERE router instance.

#     Returns:
#         Global AERERouter instance
#     """
#     global _global_router
#     if _global_router is None:
_global_router = AERERouter()
#     return _global_router


def set_router(router: AERERouter) -> None:
#     """
#     Set the global AERE router instance.

#     Args:
#         router: AERERouter instance to set as global
#     """
#     global _global_router
_global_router = router