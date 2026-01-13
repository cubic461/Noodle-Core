# Converted from Python to NoodleCore
# Original file: noodle-core

# """NoodleCore AI Agent Lifecycle Manager
 = ==========================================

# Lifecycle management utilities for AI agents with health monitoring,
# state recovery, and graceful shutdown capabilities.

# Implements AI agent standards:
# - Agent lifecycle state management
# - Health monitoring and recovery
# - Graceful shutdown procedures
# - Proper error handling with 4-digit error codes
# """

import os
import time
import threading
import logging
import uuid
import signal
import traceback
import typing.Dict,
import dataclasses.dataclass,
import datetime.datetime,
import enum.Enum
import contextlib.contextmanager

import .base_agent.BaseAIAgent
import .agent_registry.AgentMetadata
import .agent_performance_monitor.AgentPerformanceMonitor,
import .errors.DatabaseError,


class LifecycleState(Enum)
    #     """Agent lifecycle states."""
    INITIALIZING = "initializing"
    STARTING = "starting"
    RUNNING = "running"
    PAUSING = "pausing"
    PAUSED = "paused"
    RESUMING = "resuming"
    STOPPING = "stopping"
    STOPPED = "stopped"
    ERROR = "error"
    RECOVERING = "recovering"
    TERMINATING = "terminating"


class AgentStatus(Enum)
    #     """Agent status enumeration."""
    ACTIVE = "active"
    INACTIVE = "inactive"
    ERROR = "error"
    LOADING = "loading"


class HealthStatus(Enum)
    #     """Agent health status."""
    HEALTHY = "healthy"
    DEGRADED = "degraded"
    UNHEALTHY = "unhealthy"
    UNKNOWN = "unknown"


# @dataclass
class AgentLifecycleInfo
    #     """Lifecycle information for an agent."""
    #     agent_id: str
    #     agent: BaseAIAgent
    #     state: LifecycleState
    #     health_status: HealthStatus
    created_at: datetime = field(default_factory=datetime.now)
    started_at: Optional[datetime] = None
    last_health_check: Optional[datetime] = None
    last_state_change: Optional[datetime] = None
    error_count: int = 0
    recovery_count: int = 0
    max_restarts: int = 3
    restart_delay: float = 5.0  # seconds
    health_check_interval: float = 30.0  # seconds
    metadata: Dict[str, Any] = field(default_factory=dict)


# @dataclass
class LifecycleEvent
    #     """Lifecycle event for an agent."""
    #     event_id: str
    #     agent_id: str
    #     event_type: str
    #     from_state: Optional[LifecycleState]
    #     to_state: LifecycleState
    timestamp: datetime = field(default_factory=datetime.now)
    message: str = ""
    metadata: Dict[str, Any] = field(default_factory=dict)


class AgentLifecycleManager
    #     """
    #     Lifecycle manager for AI agents.

    #     Features:
    #     - Agent lifecycle state management
    #     - Health monitoring and recovery
    #     - Graceful shutdown procedures
    #     - Automatic restart on failure
    #     - Proper error handling with 4-digit error codes
    #     """

    #     def __init__(self, health_check_interval: float = 30.0):
    #         """
    #         Initialize lifecycle manager.

    #         Args:
    #             health_check_interval: Interval for health checks in seconds
    #         """
    self.health_check_interval = health_check_interval
    self.logger = logging.getLogger('noodlecore.ai_agents.lifecycle_manager')

    #         # Agent lifecycle tracking
    self._agents: Dict[str, AgentLifecycleInfo] = {}
    self._lifecycle_events: List[LifecycleEvent] = []

    #         # Monitoring state
    self._monitoring_active = False
    self._monitoring_thread: Optional[threading.Thread] = None
    self._stop_event = threading.Event()

    #         # Shutdown handling
    self._shutdown_handlers: List[Callable[[], None]] = []
    self._shutdown_requested = False

    #         # Performance monitor integration
    self._performance_monitor = get_agent_performance_monitor()

    #         # Signal handlers for graceful shutdown
            self._setup_signal_handlers()

            self.logger.info("Agent lifecycle manager initialized")

    #     def register_agent(
    #         self,
    #         agent_id: str,
    #         agent: BaseAIAgent,
    max_restarts: int = 3,
    restart_delay: float = 5.0,
    health_check_interval: Optional[float] = None
    #     ) -> bool:
    #         """
    #         Register an agent for lifecycle management.

    #         Args:
    #             agent_id: Unique ID for the agent
    #             agent: The agent instance
    #             max_restarts: Maximum number of automatic restarts
    #             restart_delay: Delay between restart attempts in seconds
    #             health_check_interval: Custom health check interval

    #         Returns:
    #             True if registered successfully
    #         """
    #         try:
    #             if agent_id in self._agents:
                    self.logger.warning(f"Agent {agent_id} is already registered")
    #                 return False

    #             # Create lifecycle info
    lifecycle_info = AgentLifecycleInfo(
    agent_id = agent_id,
    agent = agent,
    state = LifecycleState.INITIALIZING,
    health_status = HealthStatus.UNKNOWN,
    max_restarts = max_restarts,
    restart_delay = restart_delay,
    health_check_interval = health_check_interval or self.health_check_interval
    #             )

    self._agents[agent_id] = lifecycle_info

    #             # Record lifecycle event
                self._record_lifecycle_event(
    agent_id = agent_id,
    event_type = "registered",
    to_state = LifecycleState.INITIALIZING,
    #                 message=f"Agent {agent_id} registered for lifecycle management"
    #             )

    #             # Initialize agent
                self._initialize_agent(agent_id)

    #             self.logger.info(f"Agent {agent_id} registered for lifecycle management")
    #             return True
    #         except Exception as e:
    error_msg = f"Failed to register agent {agent_id}: {str(e)}"
                self.logger.error(error_msg)
    #             return False

    #     def unregister_agent(self, agent_id: str) -> bool:
    #         """
    #         Unregister an agent from lifecycle management.

    #         Args:
    #             agent_id: ID of the agent to unregister

    #         Returns:
    #             True if unregistered successfully
    #         """
    #         try:
    #             if agent_id not in self._agents:
                    self.logger.warning(f"Agent {agent_id} is not registered")
    #                 return False

    #             # Stop agent if running
    #             if self._agents[agent_id].state in [LifecycleState.RUNNING, LifecycleState.PAUSED]:
                    self.stop_agent(agent_id)

    #             # Remove from tracking
    #             del self._agents[agent_id]

    #             # Record lifecycle event
                self._record_lifecycle_event(
    agent_id = agent_id,
    event_type = "unregistered",
    to_state = LifecycleState.TERMINATING,
    message = f"Agent {agent_id} unregistered from lifecycle management"
    #             )

                self.logger.info(f"Agent {agent_id} unregistered from lifecycle management")
    #             return True
    #         except Exception as e:
    error_msg = f"Failed to unregister agent {agent_id}: {str(e)}"
                self.logger.error(error_msg)
    #             return False

    #     def start_agent(self, agent_id: str) -> bool:
    #         """
    #         Start an agent.

    #         Args:
    #             agent_id: ID of the agent to start

    #         Returns:
    #             True if started successfully
    #         """
    #         try:
    #             if agent_id not in self._agents:
                    self.logger.error(f"Agent {agent_id} is not registered")
    #                 return False

    lifecycle_info = self._agents[agent_id]

    #             if lifecycle_info.state == LifecycleState.RUNNING:
                    self.logger.warning(f"Agent {agent_id} is already running")
    #                 return True

    #             # Change state to starting
                self._change_agent_state(
    agent_id = agent_id,
    new_state = LifecycleState.STARTING,
    message = "Starting agent"
    #             )

    #             # Start the agent
    success = self._start_agent_internal(agent_id)

    #             if success:
                    self._change_agent_state(
    agent_id = agent_id,
    new_state = LifecycleState.RUNNING,
    message = "Agent started successfully"
    #                 )
    lifecycle_info.started_at = datetime.now()
    #             else:
                    self._change_agent_state(
    agent_id = agent_id,
    new_state = LifecycleState.ERROR,
    message = "Failed to start agent"
    #                 )

    #             return success
    #         except Exception as e:
    error_msg = f"Failed to start agent {agent_id}: {str(e)}"
                self.logger.error(error_msg)
                self._change_agent_state(
    agent_id = agent_id,
    new_state = LifecycleState.ERROR,
    message = error_msg
    #             )
    #             return False

    #     def stop_agent(self, agent_id: str, graceful: bool = True) -> bool:
    #         """
    #         Stop an agent.

    #         Args:
    #             agent_id: ID of the agent to stop
    #             graceful: Whether to perform graceful shutdown

    #         Returns:
    #             True if stopped successfully
    #         """
    #         try:
    #             if agent_id not in self._agents:
                    self.logger.error(f"Agent {agent_id} is not registered")
    #                 return False

    lifecycle_info = self._agents[agent_id]

    #             if lifecycle_info.state in [LifecycleState.STOPPED, LifecycleState.TERMINATING]:
                    self.logger.warning(f"Agent {agent_id} is already stopped")
    #                 return True

    #             # Change state to stopping
                self._change_agent_state(
    agent_id = agent_id,
    new_state = LifecycleState.STOPPING,
    message = "Stopping agent"
    #             )

    #             # Stop the agent
    success = self._stop_agent_internal(agent_id, graceful)

    #             if success:
                    self._change_agent_state(
    agent_id = agent_id,
    new_state = LifecycleState.STOPPED,
    message = "Agent stopped successfully"
    #                 )
    #             else:
                    self._change_agent_state(
    agent_id = agent_id,
    new_state = LifecycleState.ERROR,
    message = "Failed to stop agent"
    #                 )

    #             return success
    #         except Exception as e:
    error_msg = f"Failed to stop agent {agent_id}: {str(e)}"
                self.logger.error(error_msg)
                self._change_agent_state(
    agent_id = agent_id,
    new_state = LifecycleState.ERROR,
    message = error_msg
    #             )
    #             return False

    #     def pause_agent(self, agent_id: str) -> bool:
    #         """
    #         Pause an agent.

    #         Args:
    #             agent_id: ID of the agent to pause

    #         Returns:
    #             True if paused successfully
    #         """
    #         try:
    #             if agent_id not in self._agents:
                    self.logger.error(f"Agent {agent_id} is not registered")
    #                 return False

    lifecycle_info = self._agents[agent_id]

    #             if lifecycle_info.state != LifecycleState.RUNNING:
                    self.logger.warning(f"Agent {agent_id} is not running, cannot pause")
    #                 return False

    #             # Change state to pausing
                self._change_agent_state(
    agent_id = agent_id,
    new_state = LifecycleState.PAUSING,
    message = "Pausing agent"
    #             )

    #             # Pause the agent
    success = self._pause_agent_internal(agent_id)

    #             if success:
                    self._change_agent_state(
    agent_id = agent_id,
    new_state = LifecycleState.PAUSED,
    message = "Agent paused successfully"
    #                 )
    #             else:
                    self._change_agent_state(
    agent_id = agent_id,
    new_state = LifecycleState.ERROR,
    message = "Failed to pause agent"
    #                 )

    #             return success
    #         except Exception as e:
    error_msg = f"Failed to pause agent {agent_id}: {str(e)}"
                self.logger.error(error_msg)
                self._change_agent_state(
    agent_id = agent_id,
    new_state = LifecycleState.ERROR,
    message = error_msg
    #             )
    #             return False

    #     def resume_agent(self, agent_id: str) -> bool:
    #         """
    #         Resume a paused agent.

    #         Args:
    #             agent_id: ID of the agent to resume

    #         Returns:
    #             True if resumed successfully
    #         """
    #         try:
    #             if agent_id not in self._agents:
                    self.logger.error(f"Agent {agent_id} is not registered")
    #                 return False

    lifecycle_info = self._agents[agent_id]

    #             if lifecycle_info.state != LifecycleState.PAUSED:
                    self.logger.warning(f"Agent {agent_id} is not paused, cannot resume")
    #                 return False

    #             # Change state to resuming
                self._change_agent_state(
    agent_id = agent_id,
    new_state = LifecycleState.RESUMING,
    message = "Resuming agent"
    #             )

    #             # Resume the agent
    success = self._resume_agent_internal(agent_id)

    #             if success:
                    self._change_agent_state(
    agent_id = agent_id,
    new_state = LifecycleState.RUNNING,
    message = "Agent resumed successfully"
    #                 )
    #             else:
                    self._change_agent_state(
    agent_id = agent_id,
    new_state = LifecycleState.ERROR,
    message = "Failed to resume agent"
    #                 )

    #             return success
    #         except Exception as e:
    error_msg = f"Failed to resume agent {agent_id}: {str(e)}"
                self.logger.error(error_msg)
                self._change_agent_state(
    agent_id = agent_id,
    new_state = LifecycleState.ERROR,
    message = error_msg
    #             )
    #             return False

    #     def restart_agent(self, agent_id: str) -> bool:
    #         """
    #         Restart an agent.

    #         Args:
    #             agent_id: ID of the agent to restart

    #         Returns:
    #             True if restarted successfully
    #         """
    #         try:
    #             if agent_id not in self._agents:
                    self.logger.error(f"Agent {agent_id} is not registered")
    #                 return False

    lifecycle_info = self._agents[agent_id]

    #             if lifecycle_info.recovery_count >= lifecycle_info.max_restarts:
                    self.logger.error(f"Agent {agent_id} has reached maximum restart limit")
    #                 return False

    #             # Change state to recovering
                self._change_agent_state(
    agent_id = agent_id,
    new_state = LifecycleState.RECOVERING,
    message = f"Restarting agent (attempt {lifecycle_info.recovery_count + 1})"
    #             )

    #             # Stop agent if running
    #             if lifecycle_info.state in [LifecycleState.RUNNING, LifecycleState.PAUSED]:
    self._stop_agent_internal(agent_id, graceful = True)

    #             # Wait before restart
                time.sleep(lifecycle_info.restart_delay)

    #             # Start agent again
    success = self._start_agent_internal(agent_id)

    #             if success:
    lifecycle_info.recovery_count + = 1
                    self._change_agent_state(
    agent_id = agent_id,
    new_state = LifecycleState.RUNNING,
    message = "Agent restarted successfully"
    #                 )
    #             else:
                    self._change_agent_state(
    agent_id = agent_id,
    new_state = LifecycleState.ERROR,
    message = "Failed to restart agent"
    #                 )

    #             return success
    #         except Exception as e:
    error_msg = f"Failed to restart agent {agent_id}: {str(e)}"
                self.logger.error(error_msg)
                self._change_agent_state(
    agent_id = agent_id,
    new_state = LifecycleState.ERROR,
    message = error_msg
    #             )
    #             return False

    #     def get_agent_state(self, agent_id: str) -> Optional[LifecycleState]:
    #         """
    #         Get the current state of an agent.

    #         Args:
    #             agent_id: ID of the agent

    #         Returns:
    #             Current lifecycle state or None if not found
    #         """
    #         if agent_id in self._agents:
    #             return self._agents[agent_id].state
    #         return None

    #     def get_agent_health(self, agent_id: str) -> Optional[HealthStatus]:
    #         """
    #         Get the current health status of an agent.

    #         Args:
    #             agent_id: ID of the agent

    #         Returns:
    #             Current health status or None if not found
    #         """
    #         if agent_id in self._agents:
    #             return self._agents[agent_id].health_status
    #         return None

    #     def get_agent_lifecycle_info(self, agent_id: str) -> Optional[AgentLifecycleInfo]:
    #         """
    #         Get lifecycle information for an agent.

    #         Args:
    #             agent_id: ID of the agent

    #         Returns:
    #             Agent lifecycle information or None if not found
    #         """
            return self._agents.get(agent_id)

    #     def get_all_agents_info(self) -> Dict[str, AgentLifecycleInfo]:
    #         """
    #         Get lifecycle information for all agents.

    #         Returns:
    #             Dictionary mapping agent IDs to their lifecycle information
    #         """
    #         return {k: v for k, v in self._agents.items()}

    #     def get_lifecycle_events(
    #         self,
    agent_id: Optional[str] = None,
    event_type: Optional[str] = None,
    start_time: Optional[datetime] = None,
    end_time: Optional[datetime] = None
    #     ) -> List[LifecycleEvent]:
    #         """
    #         Get lifecycle events.

    #         Args:
    #             agent_id: Optional filter by agent ID
    #             event_type: Optional filter by event type
    #             start_time: Optional start time filter
    #             end_time: Optional end time filter

    #         Returns:
    #             List of lifecycle events
    #         """
    events = self._lifecycle_events.copy()

    #         # Apply filters
    #         if agent_id:
    #             events = [e for e in events if e.agent_id == agent_id]

    #         if event_type:
    #             events = [e for e in events if e.event_type == event_type]

    #         if start_time:
    #             events = [e for e in events if e.timestamp >= start_time]

    #         if end_time:
    #             events = [e for e in events if e.timestamp <= end_time]

            # Sort by timestamp (newest first)
    events.sort(key = lambda e: e.timestamp, reverse=True)

    #         return events

    #     def start_monitoring(self) -> None:
    #         """
    #         Start lifecycle monitoring for all registered agents.

    #         Raises:
    #             DatabaseError: If monitoring cannot be started
    #         """
    #         try:
    #             if self._monitoring_active:
    raise DatabaseError("Lifecycle monitoring is already active", error_code = 9101)

    self._monitoring_active = True
                self._stop_event.clear()

    #             # Start monitoring thread
    self._monitoring_thread = threading.Thread(
    target = self._monitoring_loop,
    daemon = True
    #             )
                self._monitoring_thread.start()

                self.logger.info("Started lifecycle monitoring")
    #         except Exception as e:
    error_msg = f"Failed to start lifecycle monitoring: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 9102)

    #     def stop_monitoring(self) -> None:
    #         """
    #         Stop lifecycle monitoring.

    #         Raises:
    #             DatabaseError: If monitoring cannot be stopped
    #         """
    #         try:
    #             if not self._monitoring_active:
    #                 return

    #             # Signal stop
                self._stop_event.set()
    self._monitoring_active = False

    #             # Stop all agents
    #             for agent_id in list(self._agents.keys()):
    self.stop_agent(agent_id, graceful = True)

    #             # Wait for thread to finish
    #             if self._monitoring_thread and self._monitoring_thread.is_alive():
    self._monitoring_thread.join(timeout = 10)

                self.logger.info("Stopped lifecycle monitoring")
    #         except Exception as e:
    error_msg = f"Failed to stop lifecycle monitoring: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 9103)

    #     def add_shutdown_handler(self, handler: Callable[[], None]) -> None:
    #         """
    #         Add a shutdown handler function.

    #         Args:
    #             handler: Function to call during shutdown
    #         """
            self._shutdown_handlers.append(handler)

    #     def shutdown_all_agents(self, graceful: bool = True) -> None:
    #         """
    #         Shutdown all registered agents.

    #         Args:
    #             graceful: Whether to perform graceful shutdown
    #         """
    #         try:
    self._shutdown_requested = True

    #             # Call shutdown handlers
    #             for handler in self._shutdown_handlers:
    #                 try:
                        handler()
    #                 except Exception as e:
                        self.logger.error(f"Shutdown handler failed: {str(e)}")

    #             # Stop all agents
    #             for agent_id in list(self._agents.keys()):
                    self.stop_agent(agent_id, graceful)

                self.logger.info("All agents shutdown complete")
    #         except Exception as e:
    error_msg = f"Failed to shutdown all agents: {str(e)}"
                self.logger.error(error_msg)

    #     def _initialize_agent(self, agent_id: str) -> None:
    #         """Initialize an agent."""
    #         try:
    lifecycle_info = self._agents[agent_id]

    #             # Initialize agent
    #             if hasattr(lifecycle_info.agent, 'initialize'):
                    lifecycle_info.agent.initialize()

    #             # Change state to initialized
                self._change_agent_state(
    agent_id = agent_id,
    new_state = LifecycleState.INITIALIZING,
    message = "Initializing agent"
    #             )
    #         except Exception as e:
                self.logger.error(f"Failed to initialize agent {agent_id}: {str(e)}")
                self._change_agent_state(
    agent_id = agent_id,
    new_state = LifecycleState.ERROR,
    message = f"Initialization failed: {str(e)}"
    #             )

    #     def _start_agent_internal(self, agent_id: str) -> bool:
    #         """Internal method to start an agent."""
    #         try:
    lifecycle_info = self._agents[agent_id]

    #             # Start agent
    #             if hasattr(lifecycle_info.agent, 'start'):
                    lifecycle_info.agent.start()

    #             # Record performance metric
                self._performance_monitor.record_metric(
    agent_id = agent_id,
    metric_type = self._performance_monitor.MetricType.REQUEST_COUNT,
    value = 1,
    unit = "count",
    tags = {"operation": "start"}
    #             )

    #             return True
    #         except Exception as e:
                self.logger.error(f"Failed to start agent {agent_id}: {str(e)}")
    #             return False

    #     def _stop_agent_internal(self, agent_id: str, graceful: bool = True) -> bool:
    #         """Internal method to stop an agent."""
    #         try:
    lifecycle_info = self._agents[agent_id]

    #             # Stop agent
    #             if hasattr(lifecycle_info.agent, 'stop'):
                    lifecycle_info.agent.stop(graceful)

    #             # Record performance metric
                self._performance_monitor.record_metric(
    agent_id = agent_id,
    metric_type = self._performance_monitor.MetricType.REQUEST_COUNT,
    value = 1,
    unit = "count",
    tags = {"operation": "stop", "graceful": str(graceful)}
    #             )

    #             return True
    #         except Exception as e:
                self.logger.error(f"Failed to stop agent {agent_id}: {str(e)}")
    #             return False

    #     def _pause_agent_internal(self, agent_id: str) -> bool:
    #         """Internal method to pause an agent."""
    #         try:
    lifecycle_info = self._agents[agent_id]

    #             # Pause agent
    #             if hasattr(lifecycle_info.agent, 'pause'):
                    lifecycle_info.agent.pause()

    #             # Record performance metric
                self._performance_monitor.record_metric(
    agent_id = agent_id,
    metric_type = self._performance_monitor.MetricType.REQUEST_COUNT,
    value = 1,
    unit = "count",
    tags = {"operation": "pause"}
    #             )

    #             return True
    #         except Exception as e:
                self.logger.error(f"Failed to pause agent {agent_id}: {str(e)}")
    #             return False

    #     def _resume_agent_internal(self, agent_id: str) -> bool:
    #         """Internal method to resume an agent."""
    #         try:
    lifecycle_info = self._agents[agent_id]

    #             # Resume agent
    #             if hasattr(lifecycle_info.agent, 'resume'):
                    lifecycle_info.agent.resume()

    #             # Record performance metric
                self._performance_monitor.record_metric(
    agent_id = agent_id,
    metric_type = self._performance_monitor.MetricType.REQUEST_COUNT,
    value = 1,
    unit = "count",
    tags = {"operation": "resume"}
    #             )

    #             return True
    #         except Exception as e:
                self.logger.error(f"Failed to resume agent {agent_id}: {str(e)}")
    #             return False

    #     def _change_agent_state(
    #         self,
    #         agent_id: str,
    #         new_state: LifecycleState,
    message: str = ""
    #     ) -> None:
    #         """Change the state of an agent and record the event."""
    #         if agent_id not in self._agents:
    #             return

    lifecycle_info = self._agents[agent_id]
    old_state = lifecycle_info.state
    lifecycle_info.state = new_state
    lifecycle_info.last_state_change = datetime.now()

    #         # Record lifecycle event
            self._record_lifecycle_event(
    agent_id = agent_id,
    event_type = "state_change",
    from_state = old_state,
    to_state = new_state,
    message = message
    #         )

            self.logger.debug(f"Agent {agent_id} state changed: {old_state.value} -> {new_state.value}")

    #     def _record_lifecycle_event(
    #         self,
    #         agent_id: str,
    #         event_type: str,
    from_state: Optional[LifecycleState] = None,
    to_state: Optional[LifecycleState] = None,
    message: str = "",
    metadata: Optional[Dict[str, Any]] = None
    #     ) -> None:
    #         """Record a lifecycle event."""
    event = LifecycleEvent(
    event_id = str(uuid.uuid4()),
    agent_id = agent_id,
    event_type = event_type,
    from_state = from_state,
    to_state = to_state or (from_state or LifecycleState.INITIALIZING),
    message = message,
    metadata = metadata or {}
    #         )

            self._lifecycle_events.append(event)

            # Keep only recent events (limit to 1000)
    #         if len(self._lifecycle_events) > 1000:
    self._lifecycle_events = math.subtract(self._lifecycle_events[, 1000:])

    #     def _monitoring_loop(self) -> None:
    #         """Main monitoring loop for agent health checks."""
    #         while not self._stop_event.wait(self.health_check_interval):
    #             try:
    #                 # Check health of all agents
    #                 for agent_id, lifecycle_info in self._agents.items():
                        self._check_agent_health(agent_id, lifecycle_info)

    #                 # Cleanup old events
                    self._cleanup_old_events()
    #             except Exception as e:
                    self.logger.error(f"Error in monitoring loop: {str(e)}")

    #     def _check_agent_health(self, agent_id: str, lifecycle_info: AgentLifecycleInfo) -> None:
    #         """Check the health of an agent."""
    #         try:
    old_health = lifecycle_info.health_status
    new_health = HealthStatus.HEALTHY

    #             # Perform health check based on agent state
    #             if lifecycle_info.state == LifecycleState.ERROR:
    new_health = HealthStatus.UNHEALTHY
    #             elif lifecycle_info.state == LifecycleState.RECOVERING:
    new_health = HealthStatus.DEGRADED
    #             elif lifecycle_info.state in [LifecycleState.RUNNING, LifecycleState.PAUSED]:
    #                 # Check if agent is responsive
    #                 if hasattr(lifecycle_info.agent, 'is_healthy'):
    #                     if not lifecycle_info.agent.is_healthy():
    new_health = HealthStatus.DEGRADED
    #                 else:
    #                     # Fallback health check - check if agent has recent activity
    #                     if (lifecycle_info.last_state_change and
    datetime.now() - lifecycle_info.last_state_change > timedelta(minutes = 5)):
    new_health = HealthStatus.DEGRADED

    #             # Update health status if changed
    #             if old_health != new_health:
    lifecycle_info.health_status = new_health
    lifecycle_info.last_health_check = datetime.now()

    #                 # Record health change event
                    self._record_lifecycle_event(
    agent_id = agent_id,
    event_type = "health_change",
    to_state = lifecycle_info.state,
    message = f"Health status changed: {old_health.value} -> {new_health.value}"
    #                 )

    #                 # Record performance metric
                    self._performance_monitor.record_metric(
    agent_id = agent_id,
    metric_type = self._performance_monitor.MetricType.MEMORY_USAGE,
    #                     value=1 if new_health == HealthStatus.HEALTHY else 0,
    unit = "status",
    tags = {"health": new_health.value}
    #                 )
    #         except Exception as e:
    #             self.logger.error(f"Failed to check health for agent {agent_id}: {str(e)}")

    #     def _cleanup_old_events(self) -> None:
    #         """Clean up old lifecycle events."""
    #         try:
    #             cutoff_time = datetime.now() - timedelta(days=7)  # Keep events for 7 days

    #             # Remove old events
    self._lifecycle_events = [
    #                 event for event in self._lifecycle_events
    #                 if event.timestamp >= cutoff_time
    #             ]
    #         except Exception as e:
                self.logger.warning(f"Failed to cleanup old events: {str(e)}")

    #     def _setup_signal_handlers(self) -> None:
    #         """Setup signal handlers for graceful shutdown."""
    #         try:
    #             # Handle SIGTERM and SIGINT for graceful shutdown
    #             def signal_handler(signum, frame):
                    self.logger.info(f"Received signal {signum}, initiating graceful shutdown")
    self.shutdown_all_agents(graceful = True)

                signal.signal(signal.SIGTERM, signal_handler)
                signal.signal(signal.SIGINT, signal_handler)
    #         except Exception as e:
                self.logger.warning(f"Failed to setup signal handlers: {str(e)}")


# Global lifecycle manager instance
_global_lifecycle_manager: Optional[AgentLifecycleManager] = None


def get_agent_lifecycle_manager() -> AgentLifecycleManager:
#     """
#     Get the global agent lifecycle manager instance.

#     Returns:
#         AgentLifecycleManager instance
#     """
#     global _global_lifecycle_manager
#     if _global_lifecycle_manager is None:
_global_lifecycle_manager = AgentLifecycleManager()
#     return _global_lifecycle_manager


# @contextmanager
function managed_agent_lifecycle(agent_id: str, agent: BaseAIAgent)
    #     """
    #     Context manager for automatic agent lifecycle management.

    #     Args:
    #         agent_id: ID of the agent
    #         agent: The agent instance

    #     Yields:
    #         Agent lifecycle manager context
    #     """
    lifecycle_manager = get_agent_lifecycle_manager()

    #     try:
    #         # Register agent
            lifecycle_manager.register_agent(agent_id, agent)

    #         # Start agent
            lifecycle_manager.start_agent(agent_id)

    #         yield lifecycle_manager
    #     finally:
    #         # Unregister agent
            lifecycle_manager.unregister_agent(agent_id)