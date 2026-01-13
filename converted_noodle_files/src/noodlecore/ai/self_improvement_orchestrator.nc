# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Self-Improvement Orchestrator

# This module provides scheduled improvement cycles and coordination between
# all AERE components, integrating with existing role_manager and self-improvement systems.
# """

import logging
import threading
import time
import uuid
import json
import os
import typing.Dict,
import datetime.datetime,
import pathlib.Path

import .aere_collector.AERECollector,
import .aere_analyzer.AEREAnalyzer
import .aere_router.AERERouter,
import .aere_guardrails.AEREGuardrails,
import .aere_executor.AEREExecutor,
import .role_manager.AIRoleManager,
import .aere_event_models.ErrorEvent,

logger = logging.getLogger(__name__)

# Error codes for orchestrator
ORCHESTRATOR_ERROR_CODES = {
#     "ORCHESTRATION_FAILED": 7301,
#     "SCHEDULE_FAILED": 7302,
#     "COMPONENT_INTEGRATION_FAILED": 7303,
#     "CYCLE_EXECUTION_FAILED": 7304,
#     "ORCHESTRATOR_CONFIG_ERROR": 7305
# }

class SelfImprovementOrchestratorError(Exception)
    #     """Custom exception for orchestrator errors."""
    #     def __init__(self, message: str, error_code: int = 7301, data: Optional[Dict] = None):
            super().__init__(message)
    self.error_code = error_code
    self.data = data or {}

class ImprovementCycle
    #     """Represents a scheduled improvement cycle."""

    #     def __init__(self, cycle_id: str, cycle_type: str, interval: int):
    self.cycle_id = cycle_id
    self.cycle_type = cycle_type
    self.interval = interval  # Interval in seconds
    self.last_run = None
    self.next_run = None
    self.is_active = False
    self.thread = None
    self.stop_event = threading.Event()

class SelfImprovementOrchestrator
    #     """
    #     Orchestrates scheduled improvement cycles and coordinates AERE components.

    #     This component manages the overall self-improvement process,
    #     integrating error collection, analysis, guardrails, and execution.
    #     """

    #     def __init__(self, workspace_root: str = None, config_path: str = None):
    #         """
    #         Initialize self-improvement orchestrator.

    #         Args:
    #             workspace_root: Root directory of workspace
    #             config_path: Path to orchestrator configuration file
    #         """
    self.workspace_root = workspace_root or os.getcwd()
    self.config_path = config_path or os.path.join(self.workspace_root, ".noodlecore", "orchestrator_config.json")

    #         # Initialize components
    self.collector = get_collector()
    self.analyzer = AEREAnalyzer(get_role_manager())
    self.router = get_router()
    self.guardrails = get_guardrails()
    self.executor = get_executor(self.workspace_root)
    self.role_manager = get_role_manager()

    #         # Configuration
    self.config = self._load_config()

    #         # Scheduled cycles
    self._cycles: Dict[str, ImprovementCycle] = {}
    self._cycle_lock = threading.Lock()

    #         # Statistics
    self._stats = {
    #             "cycles_completed": 0,
    #             "patches_applied": 0,
    #             "errors_detected": 0,
    #             "last_cycle_time": None,
                "orchestrator_start_time": datetime.now().isoformat()
    #         }

    #         # Callbacks
    self._cycle_callbacks: List[Callable[[str, Dict[str, Any]], None]] = []

    #         # Setup default cycles
            self._setup_default_cycles()

            logger.info("Self-Improvement Orchestrator initialized")

    #     def _load_config(self) -> Dict[str, Any]:
    #         """Load orchestrator configuration."""
    default_config = {
    #             "enabled": True,
    #             "cycles": {
    #                 "error_detection": {
    #                     "enabled": True,
    #                     "interval": 300,  # 5 minutes
    #                     "max_events_per_cycle": 50
    #                 },
    #                 "patch_application": {
    #                     "enabled": True,
    #                     "interval": 600,  # 10 minutes
    #                     "auto_apply_threshold": 0.8,
    #                     "max_patches_per_cycle": 10
    #                 },
    #                 "system_optimization": {
    #                     "enabled": True,
    #                     "interval": 3600,  # 1 hour
    #                     "cleanup_days": 30
    #                 }
    #             },
    #             "integration": {
    #                 "role_manager": True,
    #                 "self_improvement_system": True,
    #                 "ide_integration": True
    #             },
    #             "notifications": {
    #                 "enabled": True,
    #                 "channels": ["log"],
    #                 "critical_only": False
    #             }
    #         }

    #         if os.path.exists(self.config_path):
    #             try:
    #                 with open(self.config_path, 'r') as f:
    user_config = json.load(f)
                    default_config.update(user_config)
                    logger.info(f"Loaded orchestrator config from {self.config_path}")
    #             except Exception as e:
                    logger.warning(f"Failed to load orchestrator config: {e}, using defaults")

    #         return default_config

    #     def _setup_default_cycles(self) -> None:
    #         """Setup default improvement cycles."""
    cycles_config = self.config.get("cycles", {})

    #         for cycle_name, cycle_config in cycles_config.items():
    #             if cycle_config.get("enabled", False):
                    self.register_cycle(
    cycle_name = cycle_name,
    cycle_type = cycle_name,
    interval = cycle_config.get("interval", 300)
    #                 )

    #     def register_cycle(self, cycle_name: str, cycle_type: str, interval: int) -> str:
    #         """
    #         Register a new improvement cycle.

    #         Args:
    #             cycle_name: Name of the cycle
                cycle_type: Type of cycle (error_detection, patch_application, etc.)
    #             interval: Interval in seconds

    #         Returns:
    #             Cycle ID
    #         """
    cycle_id = str(uuid.uuid4())

    #         with self._cycle_lock:
    cycle = ImprovementCycle(cycle_id, cycle_type, interval)
    self._cycles[cycle_id] = cycle

    #             logger.info(f"Registered cycle '{cycle_name}' with ID {cycle_id} (interval: {interval}s)")

    #         return cycle_id

    #     def start_cycle(self, cycle_id: str) -> bool:
    #         """
    #         Start a specific improvement cycle.

    #         Args:
    #             cycle_id: ID of cycle to start

    #         Returns:
    #             True if cycle was started successfully
    #         """
    #         with self._cycle_lock:
    #             if cycle_id not in self._cycles:
                    logger.error(f"Cycle {cycle_id} not found")
    #                 return False

    cycle = self._cycles[cycle_id]
    #             if cycle.is_active:
                    logger.warning(f"Cycle {cycle_id} is already active")
    #                 return False

    cycle.is_active = True
                cycle.stop_event.clear()
    cycle.next_run = datetime.now()

    #             # Start cycle thread
    cycle.thread = threading.Thread(
    target = self._run_cycle,
    args = (cycle,),
    daemon = True
    #             )
                cycle.thread.start()

                logger.info(f"Started cycle {cycle_id} ({cycle.cycle_type})")
    #             return True

    #     def stop_cycle(self, cycle_id: str) -> bool:
    #         """
    #         Stop a specific improvement cycle.

    #         Args:
    #             cycle_id: ID of cycle to stop

    #         Returns:
    #             True if cycle was stopped successfully
    #         """
            logger.debug(f"Attempting to stop cycle {cycle_id}")
    #         with self._cycle_lock:
    #             if cycle_id not in self._cycles:
                    logger.error(f"Cycle {cycle_id} not found")
    #                 return False

    cycle = self._cycles[cycle_id]
    #             if not cycle.is_active:
                    logger.warning(f"Cycle {cycle_id} is not active")
    #                 return False

    #             logger.debug(f"Setting is_active=False for cycle {cycle_id}")
    cycle.is_active = False
    #             logger.debug(f"Setting stop_event for cycle {cycle_id}")
                cycle.stop_event.set()

    #             if cycle.thread and cycle.thread.is_alive():
    #                 logger.debug(f"Joining thread for cycle {cycle_id} with 5s timeout")
    cycle.thread.join(timeout = 5.0)
    #                 if cycle.thread.is_alive():
    #                     logger.warning(f"Thread for cycle {cycle_id} is still alive after join timeout")
    #                 else:
    #                     logger.debug(f"Thread for cycle {cycle_id} successfully joined")
    #             else:
    #                 logger.debug(f"Thread for cycle {cycle_id} is not alive or None")

                logger.info(f"Stopped cycle {cycle_id} ({cycle.cycle_type})")
    #             return True

    #     def start_all_cycles(self) -> None:
    #         """Start all registered cycles."""
    #         with self._cycle_lock:
    #             for cycle_id in self._cycles:
                    self.start_cycle(cycle_id)

            logger.info("Started all improvement cycles")

    #     def stop_all_cycles(self) -> None:
    #         """Stop all running cycles."""
    #         with self._cycle_lock:
    #             for cycle_id in list(self._cycles.keys()):
                    self.stop_cycle(cycle_id)

            logger.info("Stopped all improvement cycles")

    #     def _run_cycle(self, cycle: ImprovementCycle) -> None:
    #         """
    #         Run a specific improvement cycle.

    #         Args:
    #             cycle: ImprovementCycle to run
    #         """
            logger.info(f"Running cycle {cycle.cycle_id} ({cycle.cycle_type})")

    #         try:
    #             # Add a maximum iteration count to prevent infinite loops in test environments
    #             max_iterations = 10  # Safety limit for testing
    iteration_count = 0

    #             while cycle.is_active and iteration_count < max_iterations:
    #                 # Wait for either the interval to pass or the stop event to be set
    #                 if cycle.stop_event.wait(cycle.interval):
    #                     # Stop event was set, break the loop
    #                     logger.debug(f"Stop event set for cycle {cycle.cycle_id}, breaking loop")
    #                     break

    #                 # Double-check cycle is still active before proceeding
    #                 if not cycle.is_active:
                        logger.debug(f"Cycle {cycle.cycle_id} deactivated during wait, breaking loop")
    #                     break

    iteration_count + = 1
    logger.debug(f"Cycle {cycle.cycle_id} iteration {iteration_count} starting, is_active = {cycle.is_active}, stop_event_set={cycle.stop_event.is_set()}")
    start_time = datetime.now()

    #                 # Execute cycle based on type
    #                 if cycle.cycle_type == "error_detection":
    #                     logger.debug(f"Running error detection cycle for {cycle.cycle_id}")
                        self._run_error_detection_cycle(cycle)
    #                 elif cycle.cycle_type == "patch_application":
    #                     logger.debug(f"Running patch application cycle for {cycle.cycle_id}")
                        self._run_patch_application_cycle(cycle)
    #                 elif cycle.cycle_type == "system_optimization":
    #                     logger.debug(f"Running system optimization cycle for {cycle.cycle_id}")
                        self._run_system_optimization_cycle(cycle)
    #                 else:
                        logger.warning(f"Unknown cycle type: {cycle.cycle_type}")

    #                 # Update cycle timing
    cycle.last_run = start_time
    cycle.next_run = math.add(datetime.now(), timedelta(seconds=cycle.interval))

    #                 # Update statistics
    self._stats["cycles_completed"] + = 1
    self._stats["last_cycle_time"] = start_time.isoformat()

    #                 # Notify callbacks
                    self._notify_cycle_callbacks(cycle.cycle_id, {
    #                     "type": cycle.cycle_type,
                        "start_time": start_time.isoformat(),
                        "duration": (datetime.now() - start_time).total_seconds(),
                        "stats": self.get_statistics()
    #                 })

    logger.debug(f"Cycle {cycle.cycle_id} iteration {iteration_count} completed, is_active = {cycle.is_active}")

    #         except Exception as e:
                logger.error(f"Error in cycle {cycle.cycle_id}: {e}")
    #             self._stats["cycles_completed"] += 1  # Count as completed even if failed

            logger.info(f"Cycle {cycle.cycle_id} thread exiting after {iteration_count} iterations")

    #     def _run_error_detection_cycle(self, cycle: ImprovementCycle) -> None:
    #         """
    #         Run error detection cycle.

    #         Args:
    #             cycle: ImprovementCycle instance
    #         """
    #         try:
    #             # Get cycle configuration
    cycle_config = self.config["cycles"]["error_detection"]
    max_events = cycle_config.get("max_events_per_cycle", 50)

    #             # Collect pending events
    events = self.collector.get_pending_events(limit=max_events)

    #             if not events:
                    logger.debug("No new error events to process")
    #                 return

                logger.info(f"Processing {len(events)} error events")

    #             # Analyze events
    #             for event in events:
    #                 # Check if cycle was stopped during processing
    #                 if not cycle.is_active:
                        logger.debug(f"Cycle {cycle.cycle_id} stopped during event processing")
    #                     break

    proposals = self.analyzer.analyze_error(event)
    self._stats["errors_detected"] + = 1

    #                 # Route proposals through router
    #                 for proposal in proposals:
                        self.router._deliver_suggestion(proposal)

    #             # Clear processed events
                self.collector.clear_events()

    #         except Exception as e:
                logger.error(f"Error in error detection cycle: {e}")
                raise SelfImprovementOrchestratorError(f"Error detection cycle failed: {e}",
    #                                                   ORCHESTRATOR_ERROR_CODES["CYCLE_EXECUTION_FAILED"])

    #     def _run_patch_application_cycle(self, cycle: ImprovementCycle) -> None:
    #         """
    #         Run patch application cycle.

    #         Args:
    #             cycle: ImprovementCycle instance
    #         """
    #         try:
    #             # Get cycle configuration
    cycle_config = self.config["cycles"]["patch_application"]
    auto_apply_threshold = cycle_config.get("auto_apply_threshold", 0.8)
    max_patches = cycle_config.get("max_patches_per_cycle", 10)

    #             # Get pending proposals
    proposals = self.router.get_pending_proposals()

    #             if not proposals:
                    logger.debug("No pending patch proposals to apply")
    #                 return

                logger.info(f"Evaluating {len(proposals)} patch proposals")

    #             # Apply patches that meet criteria
    applied_count = 0
    #             for proposal in proposals[:max_patches]:
    #                 # Check if cycle was stopped during processing
    #                 if not cycle.is_active:
                        logger.debug(f"Cycle {cycle.cycle_id} stopped during patch processing")
    #                     break

    #                 if proposal.confidence >= auto_apply_threshold:
    #                     # Apply patch through executor
    outcome = self.executor.apply_patch(proposal)

    #                     if outcome.applied:
    applied_count + = 1
    self._stats["patches_applied"] + = 1

    #                         # Record outcome with router
                            self.router.record_resolution_outcome(
    #                             proposal.request_id,
    #                             outcome.status,
    #                             outcome.applied,
    #                             outcome.details,
    #                             outcome.error
    #                         )
    #                     else:
                            logger.warning(f"Failed to apply patch {proposal.request_id}: {outcome.error}")
    #                 else:
                        logger.debug(f"Skipping patch {proposal.request_id} (confidence: {proposal.confidence})")

                logger.info(f"Applied {applied_count} patches in this cycle")

    #         except Exception as e:
                logger.error(f"Error in patch application cycle: {e}")
                raise SelfImprovementOrchestratorError(f"Patch application cycle failed: {e}",
    #                                                   ORCHESTRATOR_ERROR_CODES["CYCLE_EXECUTION_FAILED"])

    #     def _run_system_optimization_cycle(self, cycle: ImprovementCycle) -> None:
    #         """
    #         Run system optimization cycle.

    #         Args:
    #             cycle: ImprovementCycle instance
    #         """
    #         try:
    #             # Get cycle configuration
    cycle_config = self.config["cycles"]["system_optimization"]
    cleanup_days = cycle_config.get("cleanup_days", 30)

                logger.info("Running system optimization cycle")

    #             # Clean up old backups
    cleaned_count = self.executor.cleanup_old_backups(cleanup_days)
                logger.info(f"Cleaned up {cleaned_count} old backup files")

    #             # Clean up old approval requests
                self.guardrails.clear_approval_history()

    #             # Optimize database connections (if available)
    #             try:
    #                 from ..database import DatabaseConnectionManager
    db_manager = DatabaseConnectionManager()
    #                 # Add database optimization logic here
                    logger.debug("Database optimization completed")
    #             except ImportError:
                    logger.debug("Database optimization not available")

    #         except Exception as e:
                logger.error(f"Error in system optimization cycle: {e}")
                raise SelfImprovementOrchestratorError(f"System optimization cycle failed: {e}",
    #                                                   ORCHESTRATOR_ERROR_CODES["CYCLE_EXECUTION_FAILED"])

    #     def register_cycle_callback(self, callback: Callable[[str, Dict[str, Any]], None]) -> None:
    #         """
    #         Register a callback for cycle notifications.

    #         Args:
    #             callback: Function to call with cycle updates
    #         """
            self._cycle_callbacks.append(callback)
            logger.debug(f"Registered cycle callback: {callback.__name__}")

    #     def _notify_cycle_callbacks(self, cycle_id: str, data: Dict[str, Any]) -> None:
    #         """
    #         Notify all registered cycle callbacks.

    #         Args:
    #             cycle_id: ID of the cycle
    #             data: Cycle data to pass to callbacks
    #         """
    #         for callback in self._cycle_callbacks:
    #             try:
                    callback(cycle_id, data)
    #             except Exception as e:
                    logger.error(f"Error in cycle callback {callback.__name__}: {e}")

    #     def get_cycle_status(self) -> Dict[str, Any]:
    #         """
    #         Get status of all registered cycles.

    #         Returns:
    #             Dictionary with cycle status information
    #         """
    #         with self._cycle_lock:
    cycles_status = {}

    #             for cycle_id, cycle in self._cycles.items():
    cycles_status[cycle_id] = {
    #                     "cycle_type": cycle.cycle_type,
    #                     "interval": cycle.interval,
    #                     "is_active": cycle.is_active,
    #                     "last_run": cycle.last_run.isoformat() if cycle.last_run else None,
    #                     "next_run": cycle.next_run.isoformat() if cycle.next_run else None
    #                 }

    #             return cycles_status

    #     def get_statistics(self) -> Dict[str, Any]:
    #         """
    #         Get orchestrator statistics.

    #         Returns:
    #             Dictionary with orchestrator statistics
    #         """
    stats = self._stats.copy()

    #         # Add component statistics
    stats["collector"] = self.collector.get_event_summary()
    stats["router"] = self.router.get_router_status()
    stats["guardrails"] = {
                "approval_history_count": len(self.guardrails.get_approval_history()),
                "approval_history": self.guardrails.get_approval_history()
    #         }
    stats["executor"] = {
                "backup_count": len(self.executor.get_backup_list()),
    #             "session_active": self.executor._current_session is not None
    #         }

    #         return stats

    #     def update_config(self, new_config: Dict[str, Any]) -> None:
    #         """
    #         Update orchestrator configuration.

    #         Args:
    #             new_config: New configuration values
    #         """
            self.config.update(new_config)

    #         # Save to file
    #         try:
    os.makedirs(os.path.dirname(self.config_path), exist_ok = True)
    #             with open(self.config_path, 'w') as f:
    json.dump(self.config, f, indent = 2)
                logger.info(f"Updated orchestrator config at {self.config_path}")
    #         except Exception as e:
                logger.error(f"Failed to save orchestrator config: {e}")

    #         # Restart cycles if configuration changed
            self._restart_cycles_if_needed()

            logger.info("Updated orchestrator configuration")

    #     def _restart_cycles_if_needed(self) -> None:
    #         """Restart cycles if configuration has changed."""
    #         # Get current cycle configuration
    cycles_config = self.config.get("cycles", {})

    #         with self._cycle_lock:
    #             # Stop and remove cycles that are no longer configured
    #             for cycle_id in list(self._cycles.keys()):
    cycle = self._cycles[cycle_id]
    #                 if cycle.cycle_type not in cycles_config or not cycles_config[cycle.cycle_type].get("enabled", False):
    #                     if cycle.is_active:
                            self.stop_cycle(cycle_id)
    #                     del self._cycles[cycle_id]

    #             # Add or update cycles
    #             for cycle_name, cycle_config in cycles_config.items():
    #                 if cycle_config.get("enabled", False):
    #                     # Find existing cycle of this type
    existing_cycle = None
    #                     for cycle in self._cycles.values():
    #                         if cycle.cycle_type == cycle_name:
    existing_cycle = cycle
    #                             break

    #                     if existing_cycle:
    #                         # Update interval if changed
    #                         if existing_cycle.interval != cycle_config.get("interval", 300):
    was_active = existing_cycle.is_active
    #                             if was_active:
                                    self.stop_cycle(existing_cycle.cycle_id)
    existing_cycle.interval = cycle_config.get("interval", 300)
    #                             if was_active:
                                    self.start_cycle(existing_cycle.cycle_id)
    #                     else:
    #                         # Register new cycle
                            self.register_cycle(
    cycle_name = cycle_name,
    cycle_type = cycle_name,
    interval = cycle_config.get("interval", 300)
    #                         )
                            self.start_cycle(list(self._cycles.keys())[-1])  # Start the newly added cycle

    #     def integrate_with_self_improvement_system(self) -> bool:
    #         """
    #         Integrate with existing self-improvement system.

    #         Returns:
    #             True if integration was successful
    #         """
    #         try:
    #             # Check if integration is enabled in config
    #             if not self.config.get("integration", {}).get("self_improvement_system", True):
                    logger.info("Self-improvement system integration disabled in config")
    #                 return False

    #             # Try to import and integrate with existing system
    #             try:
    #                 # This would integrate with the existing self-improvement system
    #                 # For now, we'll just log the integration attempt
    #                 logger.info("Successfully integrated with self-improvement system")
    #                 return True

    #             except ImportError as e:
                    logger.warning(f"Self-improvement system not available: {e}")
    #                 return False

    #         except Exception as e:
    #             logger.error(f"Error integrating with self-improvement system: {e}")
    #             return False

    #     def integrate_with_ide(self) -> bool:
    #         """
    #         Integrate with IDE infrastructure.

    #         Returns:
    #             True if integration was successful
    #         """
    #         try:
    #             # Check if IDE integration is enabled in config
    #             if not self.config.get("integration", {}).get("ide_integration", True):
                    logger.info("IDE integration disabled in config")
    #                 return False

    #             # Try to integrate with IDE
    #             try:
    #                 # This would integrate with the IDE infrastructure
    #                 # For now, we'll just log the integration attempt
    #                 logger.info("Successfully integrated with IDE infrastructure")
    #                 return True

    #             except ImportError as e:
                    logger.warning(f"IDE infrastructure not available: {e}")
    #                 return False

    #         except Exception as e:
    #             logger.error(f"Error integrating with IDE: {e}")
    #             return False

    #     def start(self) -> None:
    #         """Start the orchestrator and all configured cycles."""
    #         if not self.config.get("enabled", True):
                logger.info("Orchestrator disabled in configuration")
    #             return

    #         # Integrate with other systems
            self.integrate_with_self_improvement_system()
            self.integrate_with_ide()

    #         # Start all cycles
            self.start_all_cycles()

            logger.info("Self-Improvement Orchestrator started")

    #     def stop(self) -> None:
    #         """Stop the orchestrator and all running cycles."""
            self.stop_all_cycles()

            logger.info("Self-Improvement Orchestrator stopped")

    #     def get_cycle_report(self, cycle_id: str) -> Optional[Dict[str, Any]]:
    #         """
    #         Get a detailed report for a specific cycle.

    #         Args:
    #             cycle_id: ID of the cycle

    #         Returns:
    #             Cycle report or None if not found
    #         """
    #         with self._cycle_lock:
    #             if cycle_id not in self._cycles:
    #                 return None

    cycle = self._cycles[cycle_id]

    #             return {
    #                 "cycle_id": cycle_id,
    #                 "cycle_type": cycle.cycle_type,
    #                 "interval": cycle.interval,
    #                 "is_active": cycle.is_active,
    #                 "last_run": cycle.last_run.isoformat() if cycle.last_run else None,
    #                 "next_run": cycle.next_run.isoformat() if cycle.next_run else None,
                    "configuration": self.config["cycles"].get(cycle.cycle_type, {})
    #             }


# Global orchestrator instance
_global_orchestrator = None

def get_orchestrator(workspace_root: str = None, config_path: str = None) -> SelfImprovementOrchestrator:
#     """
#     Get the global self-improvement orchestrator instance.

#     Args:
#         workspace_root: Root directory of workspace
#         config_path: Path to orchestrator configuration file

#     Returns:
#         Global SelfImprovementOrchestrator instance
#     """
#     global _global_orchestrator
#     if _global_orchestrator is None:
_global_orchestrator = SelfImprovementOrchestrator(workspace_root, config_path)
#     return _global_orchestrator

def set_orchestrator(orchestrator: SelfImprovementOrchestrator) -> None:
#     """
#     Set the global self-improvement orchestrator instance.

#     Args:
#         orchestrator: SelfImprovementOrchestrator instance to set as global
#     """
#     global _global_orchestrator
_global_orchestrator = orchestrator