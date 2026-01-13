# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Fault Tolerance Module for NoodleCore
# Implements fault tolerance mechanisms for distributed execution
# """

import logging
import time
import uuid
import threading
import typing.Any,
import dataclasses.dataclass,
import enum.Enum

# Optional imports with fallbacks
try
    #     from ..noodlenet.integration.orchestrator import NoodleNetOrchestrator
    _NOODLENET_AVAILABLE = True
except ImportError
    _NOODLENET_AVAILABLE = False
    NoodleNetOrchestrator = None

logger = logging.getLogger(__name__)


class NodeStatus(Enum)
    #     """Status of a node"""
    ACTIVE = "active"
    INACTIVE = "inactive"
    FAILED = "failed"
    RECOVERING = "recovering"
    MAINTENANCE = "maintenance"


class FailureType(Enum)
    #     """Type of failure"""
    NODE_UNREACHABLE = "node_unreachable"
    TASK_TIMEOUT = "task_timeout"
    MEMORY_ERROR = "memory_error"
    NETWORK_ERROR = "network_error"
    SYSTEM_ERROR = "system_error"
    UNKNOWN = "unknown"


# @dataclass
class NodeHealth
    #     """Health information for a node"""
    #     node_id: str
    status: NodeStatus = NodeStatus.ACTIVE
    last_heartbeat: float = field(default_factory=time.time)
    consecutive_failures: int = 0
    total_failures: int = 0
    last_failure_time: float = 0.0
    last_failure_type: Optional[FailureType] = None
    recovery_attempts: int = 0
    max_recovery_attempts: int = 3
    recovery_backoff_seconds: float = 5.0
    uptime_percentage: float = 100.0
    metrics: Dict[str, Any] = field(default_factory=dict)

    #     def update_heartbeat(self):
    #         """Update heartbeat time"""
    self.last_heartbeat = time.time()

    #     def register_failure(self, failure_type: FailureType):
    #         """Register a failure for this node"""
    self.last_failure_time = time.time()
    self.last_failure_type = failure_type
    self.consecutive_failures + = 1
    self.total_failures + = 1

    #         # Update status based on consecutive failures
    #         if self.consecutive_failures >= 3:
    self.status = NodeStatus.FAILED
    #         elif self.consecutive_failures >= 1:
    self.status = NodeStatus.INACTIVE

    #     def register_recovery(self):
    #         """Register a successful recovery"""
    self.consecutive_failures = 0
    self.status = NodeStatus.ACTIVE
    self.recovery_attempts = 0

    #     def should_attempt_recovery(self) -> bool:
    #         """Check if recovery should be attempted"""
    return (self.status = = NodeStatus.FAILED and
    #                 self.recovery_attempts < self.max_recovery_attempts)

    #     def get_recovery_delay(self) -> float:
    #         """Get delay before next recovery attempt"""
    #         # Exponential backoff
            return self.recovery_backoff_seconds * (2 ** self.recovery_attempts)

    #     def is_healthy(self, heartbeat_timeout: float = 30.0) -> bool:
    #         """Check if node is healthy"""
    #         if self.status == NodeStatus.FAILED:
    #             return False

    #         # Check heartbeat
            return time.time() - self.last_heartbeat < heartbeat_timeout


# @dataclass
class TaskFailureInfo
    #     """Information about a task failure"""
    #     task_id: str
    #     node_id: str
    #     failure_type: FailureType
    failure_time: float = field(default_factory=time.time)
    error_message: str = ""
    retry_count: int = 0
    max_retries: int = 3
    next_retry_time: float = 0.0

    #     def should_retry(self) -> bool:
    #         """Check if task should be retried"""
            return (self.retry_count < self.max_retries and
    time.time() > = self.next_retry_time)

    #     def schedule_retry(self, delay: float = None):
    #         """Schedule next retry"""
    self.retry_count + = 1
    #         if delay is None:
    #             # Exponential backoff with jitter
    #             import random
    base_delay = math.multiply(2.0, * self.retry_count)
    jitter = math.multiply(random.uniform(0, 0.1), base_delay)
    self.next_retry_time = math.add(time.time(), base_delay + jitter)
    #         else:
    self.next_retry_time = math.add(time.time(), delay)


class FaultToleranceManager
    #     """Manager for fault tolerance in distributed environment"""

    #     def __init__(self, noodlenet_orchestrator: Optional[NoodleNetOrchestrator] = None,
    heartbeat_interval: float = 10.0, heartbeat_timeout: float = 30.0,
    max_node_failures: int = 5, task_retry_enabled: bool = True):
    #         """
    #         Initialize fault tolerance manager

    #         Args:
    #             noodlenet_orchestrator: NoodleNet orchestrator instance
    #             heartbeat_interval: Interval for heartbeats in seconds
    #             heartbeat_timeout: Timeout for heartbeats in seconds
    #             max_node_failures: Maximum failures before marking node as failed
    #             task_retry_enabled: Whether to enable automatic task retry
    #         """
    self.noodlenet_orchestrator = noodlenet_orchestrator
    self.heartbeat_interval = heartbeat_interval
    self.heartbeat_timeout = heartbeat_timeout
    self.max_node_failures = max_node_failures
    self.task_retry_enabled = task_retry_enabled
    self.local_node_id = ""

    #         # Node health tracking
    self.node_health: Dict[str, NodeHealth] = {}

    #         # Task failure tracking
    self.failed_tasks: Dict[str, TaskFailureInfo] = {}
    self.task_retry_callbacks: Dict[str, Callable] = {}

    #         # Statistics
    self.statistics = {
    #             'total_nodes': 0,
    #             'healthy_nodes': 0,
    #             'unhealthy_nodes': 0,
    #             'failed_nodes': 0,
    #             'recovering_nodes': 0,
    #             'total_failures': 0,
    #             'total_recoveries': 0,
    #             'tasks_timed_out': 0,
    #             'tasks_retried': 0,
    #             'tasks_failed_permanently': 0
    #         }

    #         # Background threads
    self.heartbeat_thread = None
    self.health_check_thread = None
    self.failure_recovery_thread = None
    self.task_retry_thread = None
    self.threads_running = False

    #         # Recovery strategies
    self.recovery_strategies = {
    #             FailureType.NODE_UNREACHABLE: self._recover_node_unreachable,
    #             FailureType.TASK_TIMEOUT: self._recover_task_timeout,
    #             FailureType.MEMORY_ERROR: self._recover_memory_error,
    #             FailureType.NETWORK_ERROR: self._recover_network_error,
    #             FailureType.SYSTEM_ERROR: self._recover_system_error
    #         }

    #         # Get local node ID
            self._get_local_node_id()

    #         # Set up message handlers
    #         if self.noodlenet_orchestrator:
                self._setup_message_handlers()

    #     def _get_local_node_id(self):
    #         """Get local node ID from NoodleNet"""
    #         if self.noodlenet_orchestrator and hasattr(self.noodlenet_orchestrator, 'identity_manager'):
    self.local_node_id = self.noodlenet_orchestrator.identity_manager.local_node_id
    #         else:
    self.local_node_id = f"node_{uuid.uuid4().hex[:8]}"

    #     def _setup_message_handlers(self):
    #         """Set up message handlers for fault tolerance"""
    #         if not self.noodlenet_orchestrator or not self.noodlenet_orchestrator.link:
    #             return

    #         # Register heartbeat handler
            self.noodlenet_orchestrator.link.register_message_handler(
    #             "heartbeat", self._handle_heartbeat
    #         )

    #         # Register failure notification handler
            self.noodlenet_orchestrator.link.register_message_handler(
    #             "failure_notification", self._handle_failure_notification
    #         )

    #         # Register recovery notification handler
            self.noodlenet_orchestrator.link.register_message_handler(
    #             "recovery_notification", self._handle_recovery_notification
    #         )

    #     def start_monitoring(self):
    #         """Start background monitoring threads"""
    #         if self.threads_running:
    #             return

    self.threads_running = True

    #         # Start heartbeat thread
    self.heartbeat_thread = threading.Thread(target=self._heartbeat_worker)
    self.heartbeat_thread.daemon = True
            self.heartbeat_thread.start()

    #         # Start health check thread
    self.health_check_thread = threading.Thread(target=self._health_check_worker)
    self.health_check_thread.daemon = True
            self.health_check_thread.start()

    #         # Start failure recovery thread
    self.failure_recovery_thread = threading.Thread(target=self._failure_recovery_worker)
    self.failure_recovery_thread.daemon = True
            self.failure_recovery_thread.start()

    #         # Start task retry thread
    self.task_retry_thread = threading.Thread(target=self._task_retry_worker)
    self.task_retry_thread.daemon = True
            self.task_retry_thread.start()

            logger.info("Fault tolerance monitoring started")

    #     def stop_monitoring(self):
    #         """Stop background monitoring threads"""
    #         if not self.threads_running:
    #             return

    self.threads_running = False

    #         # Wait for threads to stop
    #         for thread in [self.heartbeat_thread, self.health_check_thread,
    #                       self.failure_recovery_thread, self.task_retry_thread]:
    #             if thread and thread.is_alive():
    thread.join(timeout = 5.0)
    #                 if thread.is_alive():
                        logger.warning("Thread did not stop gracefully")

            logger.info("Fault tolerance monitoring stopped")

    #     def _heartbeat_worker(self):
    #         """Background worker for sending heartbeats"""
    #         while self.threads_running:
    #             try:
    current_time = time.time()

    #                 # Update local node heartbeat
    #                 if self.local_node_id not in self.node_health:
    self.node_health[self.local_node_id] = NodeHealth(node_id=self.local_node_id)

                    self.node_health[self.local_node_id].update_heartbeat()

    #                 # Send heartbeat to other nodes
    #                 if self.noodlenet_orchestrator and _NOODLENET_AVAILABLE:
    #                     for node_id, node in self.noodlenet_orchestrator.mesh.nodes.items():
    #                         if node.is_active and node_id != self.local_node_id:
    #                             try:
                                    self.noodlenet_orchestrator.link.send(
    #                                     node_id,
    #                                     {
    #                                         'type': 'heartbeat',
    #                                         'data': {
    #                                             'node_id': self.local_node_id,
    #                                             'timestamp': current_time,
    #                                             'status': self.node_health[self.local_node_id].status.value
    #                                         }
    #                                     }
    #                                 )
    #                             except Exception as e:
                                    logger.error(f"Failed to send heartbeat to {node_id}: {e}")

    #                 # Sleep until next heartbeat
                    time.sleep(self.heartbeat_interval)
    #             except Exception as e:
                    logger.error(f"Error in heartbeat worker: {e}")
                    time.sleep(1.0)  # Sleep longer on error

    #     def _health_check_worker(self):
    #         """Background worker for checking node health"""
    #         while self.threads_running:
    #             try:
    current_time = time.time()
    healthy_count = 0
    unhealthy_count = 0
    failed_count = 0
    recovering_count = 0

    #                 # Check health of all nodes
    #                 for node_id, health in self.node_health.items():
    #                     if health.is_healthy(self.heartbeat_timeout):
    healthy_count + = 1
    #                     else:
    unhealthy_count + = 1

    #                         # Check if node should be marked as failed
    #                         if current_time - health.last_heartbeat > self.heartbeat_timeout * 2:
    #                             if health.status != NodeStatus.FAILED:
                                    health.register_failure(FailureType.NODE_UNREACHABLE)
                                    self._notify_node_failure(node_id, FailureType.NODE_UNREACHABLE)

    #                         # Update status
    #                         if health.status == NodeStatus.FAILED:
    failed_count + = 1
    #                         elif health.status == NodeStatus.RECOVERING:
    recovering_count + = 1

    #                 # Update statistics
    self.statistics['total_nodes'] = len(self.node_health)
    self.statistics['healthy_nodes'] = healthy_count
    self.statistics['unhealthy_nodes'] = unhealthy_count
    self.statistics['failed_nodes'] = failed_count
    self.statistics['recovering_nodes'] = recovering_count

    #                 # Sleep for a short interval
                    time.sleep(5.0)
    #             except Exception as e:
                    logger.error(f"Error in health check worker: {e}")
                    time.sleep(5.0)  # Sleep longer on error

    #     def _failure_recovery_worker(self):
    #         """Background worker for recovering from failures"""
    #         while self.threads_running:
    #             try:
    current_time = time.time()

    #                 # Check for nodes that need recovery
    #                 for node_id, health in self.node_health.items():
    #                     if health.should_attempt_recovery():
    #                         # Check if enough time has passed for recovery attempt
    recovery_delay = health.get_recovery_delay()
    #                         if current_time - health.last_failure_time >= recovery_delay:
                                self._attempt_node_recovery(node_id)

    #                 # Sleep for a short interval
                    time.sleep(10.0)
    #             except Exception as e:
                    logger.error(f"Error in failure recovery worker: {e}")
                    time.sleep(10.0)  # Sleep longer on error

    #     def _task_retry_worker(self):
    #         """Background worker for retrying failed tasks"""
    #         while self.threads_running:
    #             try:
    #                 # Check for tasks that need retry
    tasks_to_retry = []

    #                 for task_id, failure_info in self.failed_tasks.items():
    #                     if failure_info.should_retry():
                            tasks_to_retry.append(task_id)

    #                 # Retry tasks
    #                 for task_id in tasks_to_retry:
    failure_info = self.failed_tasks[task_id]

    #                     # Call retry callback if available
    #                     if task_id in self.task_retry_callbacks:
    callback = self.task_retry_callbacks[task_id]
    #                         try:
                                callback(task_id, failure_info.node_id, failure_info.retry_count)
    self.statistics['tasks_retried'] + = 1
    #                         except Exception as e:
                                logger.error(f"Task retry callback failed: {e}")

    #                     # Schedule next retry
                        failure_info.schedule_retry()

    #                 # Clean up tasks that have exceeded max retries
    tasks_to_remove = []
    #                 for task_id, failure_info in self.failed_tasks.items():
    #                     if failure_info.retry_count >= failure_info.max_retries:
                            tasks_to_remove.append(task_id)
    self.statistics['tasks_failed_permanently'] + = 1
                            logger.warning(f"Task {task_id} failed permanently after {failure_info.max_retries} retries")

    #                 for task_id in tasks_to_remove:
    #                     del self.failed_tasks[task_id]
    #                     if task_id in self.task_retry_callbacks:
    #                         del self.task_retry_callbacks[task_id]

    #                 # Sleep for a short interval
                    time.sleep(1.0)
    #             except Exception as e:
                    logger.error(f"Error in task retry worker: {e}")
                    time.sleep(1.0)  # Sleep longer on error

    #     def _handle_heartbeat(self, message: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    #         """Handle heartbeat from another node"""
    #         try:
    #             # Extract heartbeat data
    data = message.get('data', {})
    node_id = data.get('node_id', '')
    timestamp = data.get('timestamp', 0.0)
    status = data.get('status', 'active')

    #             if not node_id:
    #                 return None

    #             # Update node health
    #             if node_id not in self.node_health:
    self.node_health[node_id] = NodeHealth(node_id=node_id)

    health = self.node_health[node_id]
    health.last_heartbeat = timestamp

    #             # Update status
    #             try:
    health.status = NodeStatus(status)
    #             except ValueError:
    health.status = NodeStatus.ACTIVE

    #             # Return heartbeat response
    #             return {
    #                 'type': 'heartbeat_response',
    #                 'data': {
    #                     'node_id': self.local_node_id,
                        'timestamp': time.time(),
    #                     'status': self.node_health[self.local_node_id].status.value
    #                 }
    #             }
    #         except Exception as e:
                logger.error(f"Error handling heartbeat: {e}")
    #             return None

    #     def _handle_failure_notification(self, message: Dict[str, Any]):
    #         """Handle failure notification from another node"""
    #         try:
    #             # Extract failure data
    data = message.get('data', {})
    node_id = data.get('node_id', '')
    failure_type = data.get('failure_type', 'unknown')
    error_message = data.get('error_message', '')

    #             if not node_id:
    #                 return

    #             # Update node health
    #             if node_id not in self.node_health:
    self.node_health[node_id] = NodeHealth(node_id=node_id)

    #             try:
    failure_enum = FailureType(failure_type)
                    self.node_health[node_id].register_failure(failure_enum)
    self.statistics['total_failures'] + = 1
                    logger.warning(f"Node {node_id} reported failure: {failure_type} - {error_message}")
    #             except ValueError:
                    logger.warning(f"Unknown failure type: {failure_type}")
    #         except Exception as e:
                logger.error(f"Error handling failure notification: {e}")

    #     def _handle_recovery_notification(self, message: Dict[str, Any]):
    #         """Handle recovery notification from another node"""
    #         try:
    #             # Extract recovery data
    data = message.get('data', {})
    node_id = data.get('node_id', '')

    #             if not node_id:
    #                 return

    #             # Update node health
    #             if node_id not in self.node_health:
    self.node_health[node_id] = NodeHealth(node_id=node_id)

                self.node_health[node_id].register_recovery()
    self.statistics['total_recoveries'] + = 1
                logger.info(f"Node {node_id} reported recovery")
    #         except Exception as e:
                logger.error(f"Error handling recovery notification: {e}")

    #     def register_node(self, node_id: str, initial_status: NodeStatus = NodeStatus.ACTIVE):
    #         """
    #         Register a node for monitoring

    #         Args:
    #             node_id: ID of the node
    #             initial_status: Initial status of the node
    #         """
    #         if node_id not in self.node_health:
    self.node_health[node_id] = NodeHealth(node_id=node_id, status=initial_status)
    #             logger.info(f"Registered node {node_id} with status {initial_status.value}")

    #     def unregister_node(self, node_id: str):
    #         """
    #         Unregister a node from monitoring

    #         Args:
    #             node_id: ID of the node
    #         """
    #         if node_id in self.node_health:
    #             del self.node_health[node_id]
                logger.info(f"Unregistered node {node_id}")

    #     def report_node_failure(self, node_id: str, failure_type: FailureType, error_message: str = ""):
    #         """
    #         Report a node failure

    #         Args:
    #             node_id: ID of the node
    #             failure_type: Type of failure
    #             error_message: Error message
    #         """
    #         # Update local node health
    #         if node_id not in self.node_health:
    self.node_health[node_id] = NodeHealth(node_id=node_id)

            self.node_health[node_id].register_failure(failure_type)

    #         # Notify other nodes
            self._notify_node_failure(node_id, failure_type, error_message)

    #         # Update statistics
    self.statistics['total_failures'] + = 1
            logger.error(f"Reported node failure: {node_id} - {failure_type.value} - {error_message}")

    #     def _notify_node_failure(self, node_id: str, failure_type: FailureType, error_message: str = ""):
    #         """Notify other nodes about a node failure"""
    #         if not self.noodlenet_orchestrator or not _NOODLENET_AVAILABLE:
    #             return

    #         try:
    #             # Get all active nodes except the failed node
    target_nodes = [
    #                 node_id for node_id, node in self.noodlenet_orchestrator.mesh.nodes.items()
    #                 if node.is_active and node_id != node_id
    #             ]

    #             # Send failure notification to all target nodes
    #             for target_node_id in target_nodes:
                    self.noodlenet_orchestrator.link.send(
    #                     target_node_id,
    #                     {
    #                         'type': 'failure_notification',
    #                         'data': {
    #                             'node_id': node_id,
    #                             'failure_type': failure_type.value,
    #                             'error_message': error_message,
                                'timestamp': time.time()
    #                         }
    #                     }
    #                 )
    #         except Exception as e:
                logger.error(f"Failed to notify about node failure: {e}")

    #     def report_node_recovery(self, node_id: str):
    #         """
    #         Report a node recovery

    #         Args:
    #             node_id: ID of the node
    #         """
    #         # Update local node health
    #         if node_id not in self.node_health:
    self.node_health[node_id] = NodeHealth(node_id=node_id)

            self.node_health[node_id].register_recovery()

    #         # Notify other nodes
            self._notify_node_recovery(node_id)

    #         # Update statistics
    self.statistics['total_recoveries'] + = 1
            logger.info(f"Reported node recovery: {node_id}")

    #     def _notify_node_recovery(self, node_id: str):
    #         """Notify other nodes about a node recovery"""
    #         if not self.noodlenet_orchestrator or not _NOODLENET_AVAILABLE:
    #             return

    #         try:
    #             # Get all active nodes
    target_nodes = [
    #                 node_id for node_id, node in self.noodlenet_orchestrator.mesh.nodes.items()
    #                 if node.is_active
    #             ]

    #             # Send recovery notification to all target nodes
    #             for target_node_id in target_nodes:
    #                 if target_node_id != node_id:  # Don't send to self
                        self.noodlenet_orchestrator.link.send(
    #                         target_node_id,
    #                         {
    #                             'type': 'recovery_notification',
    #                             'data': {
    #                                 'node_id': node_id,
                                    'timestamp': time.time()
    #                             }
    #                         }
    #                     )
    #         except Exception as e:
                logger.error(f"Failed to notify about node recovery: {e}")

    #     def _attempt_node_recovery(self, node_id: str):
    #         """Attempt to recover a failed node"""
    #         if node_id not in self.node_health:
    #             return

    health = self.node_health[node_id]
    health.recovery_attempts + = 1
    health.status = NodeStatus.RECOVERING

    #         logger.info(f"Attempting recovery for node {node_id} (attempt {health.recovery_attempts})")

    #         # Apply recovery strategy based on last failure type
    #         if health.last_failure_type in self.recovery_strategies:
                self.recovery_strategies[health.last_failure_type](node_id, health)
    #         else:
    #             # Default recovery strategy
                self._recover_default(node_id, health)

    #     def _recover_node_unreachable(self, node_id: str, health: NodeHealth):
    #         """Recover from node unreachable failure"""
    #         # Try to re-establish connection
    #         if self.noodlenet_orchestrator and _NOODLENET_AVAILABLE:
    #             try:
    #                 # Check if node is back in the mesh
    #                 if node_id in self.noodlenet_orchestrator.mesh.nodes:
    node = self.noodlenet_orchestrator.mesh.nodes[node_id]
    #                     if node.is_active:
                            self.report_node_recovery(node_id)
    #                         return
    #             except Exception as e:
                    logger.error(f"Error checking node {node_id}: {e}")

    #         # Schedule next recovery attempt
            logger.warning(f"Node {node_id} still unreachable, will retry later")

    #     def _recover_task_timeout(self, node_id: str, health: NodeHealth):
    #         """Recover from task timeout failure"""
    #         # Check if node is responsive
            self._send_ping(node_id)

    #     def _recover_memory_error(self, node_id: str, health: NodeHealth):
    #         """Recover from memory error"""
    #         # Request memory cleanup
    #         if self.noodlenet_orchestrator and _NOODLENET_AVAILABLE:
    #             try:
                    self.noodlenet_orchestrator.link.send(
    #                     node_id,
    #                     {
    #                         'type': 'memory_cleanup_request',
    #                         'data': {
                                'request_id': str(uuid.uuid4()),
                                'timestamp': time.time()
    #                         }
    #                     }
    #                 )
    #             except Exception as e:
                    logger.error(f"Failed to send memory cleanup request to {node_id}: {e}")

    #     def _recover_network_error(self, node_id: str, health: NodeHealth):
    #         """Recover from network error"""
    #         # Try to re-establish network connection
            self._send_ping(node_id)

    #     def _recover_system_error(self, node_id: str, health: NodeHealth):
    #         """Recover from system error"""
    #         # Request system restart
    #         if self.noodlenet_orchestrator and _NOODLENET_AVAILABLE:
    #             try:
                    self.noodlenet_orchestrator.link.send(
    #                     node_id,
    #                     {
    #                         'type': 'system_restart_request',
    #                         'data': {
                                'request_id': str(uuid.uuid4()),
                                'timestamp': time.time()
    #                         }
    #                     }
    #                 )
    #             except Exception as e:
                    logger.error(f"Failed to send system restart request to {node_id}: {e}")

    #     def _recover_default(self, node_id: str, health: NodeHealth):
    #         """Default recovery strategy"""
    #         # Just send a ping to check if node is responsive
            self._send_ping(node_id)

    #     def _send_ping(self, node_id: str):
    #         """Send ping to a node"""
    #         if not self.noodlenet_orchestrator or not _NOODLENET_AVAILABLE:
    #             return

    #         try:
                self.noodlenet_orchestrator.link.send(
    #                 node_id,
    #                 {
    #                     'type': 'ping',
    #                     'data': {
                            'request_id': str(uuid.uuid4()),
                            'timestamp': time.time()
    #                     }
    #                 }
    #             )
    #         except Exception as e:
                logger.error(f"Failed to send ping to {node_id}: {e}")

    #     def report_task_failure(self, task_id: str, node_id: str, failure_type: FailureType,
    error_message: str = "", retry_callback: Callable = None):
    #         """
    #         Report a task failure

    #         Args:
    #             task_id: ID of the task
    #             node_id: ID of the node that was executing the task
    #             failure_type: Type of failure
    #             error_message: Error message
    #             retry_callback: Callback to retry the task
    #         """
    #         if not self.task_retry_enabled:
                logger.warning(f"Task retry disabled, not retrying task {task_id}")
    #             return

    #         # Create task failure info
    failure_info = TaskFailureInfo(
    task_id = task_id,
    node_id = node_id,
    failure_type = failure_type,
    error_message = error_message
    #         )

    #         # Store failure info
    self.failed_tasks[task_id] = failure_info

    #         # Store retry callback
    #         if retry_callback:
    self.task_retry_callbacks[task_id] = retry_callback

    #         # Update statistics
    #         if failure_type == FailureType.TASK_TIMEOUT:
    self.statistics['tasks_timed_out'] + = 1

            logger.error(f"Reported task failure: {task_id} on {node_id} - {failure_type.value} - {error_message}")

    #     def get_node_health(self, node_id: str) -> Optional[NodeHealth]:
    #         """
    #         Get health information for a node

    #         Args:
    #             node_id: ID of the node

    #         Returns:
    #             Node health information or None if node not found
    #         """
            return self.node_health.get(node_id)

    #     def get_all_node_health(self) -> Dict[str, NodeHealth]:
    #         """
    #         Get health information for all nodes

    #         Returns:
    #             Dictionary of node health information
    #         """
            return self.node_health.copy()

    #     def get_statistics(self) -> Dict[str, Any]:
    #         """
    #         Get fault tolerance statistics

    #         Returns:
    #             Statistics dictionary
    #         """
    stats = self.statistics.copy()
            stats.update({
    #             'monitoring_threads_running': self.threads_running,
                'failed_tasks_count': len(self.failed_tasks),
                'task_retry_callbacks_count': len(self.task_retry_callbacks)
    #         })
    #         return stats