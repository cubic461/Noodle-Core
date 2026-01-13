# Converted from Python to NoodleCore
# Original file: src

# """
# NoodleNet Integration for NoodleCore Runtime

# This module provides integration with NoodleNet for distributed execution
# of NoodleCore programs across multiple nodes in a network.
# """

import json
import time
import uuid
import logging
import asyncio
import typing.Any
from dataclasses import dataclass
import enum.Enum

import .errors.NoodleError


class NodeStatus(Enum)
    #     """Status of a NoodleNet node."""
    IDLE = "idle"
    BUSY = "busy"
    OFFLINE = "offline"
    ERROR = "error"


class TaskStatus(Enum)
    #     """Status of a distributed task."""
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"


class NoodleNetConnectionError(NoodleError)
    #     """Raised when connection to NoodleNet fails."""

    #     def __init__(self, message: str, details: Dict[str, Any] = None):
            super().__init__(message, "3301", details)


class DistributedExecutionError(NoodleError)
    #     """Raised when distributed execution fails."""

    #     def __init__(self, message: str, details: Dict[str, Any] = None):
            super().__init__(message, "3302", details)


dataclass
class NoodleNetNode
    #     """Represents a node in the NoodleNet."""
    #     node_id: str
    #     address: str
    #     port: int
    status: NodeStatus = NodeStatus.IDLE
    capabilities: Optional[List[str]] = None
    load: float = 0.0
    last_heartbeat: float = 0.0

    #     def __post_init__(self):
    #         if self.capabilities is None:
    self.capabilities = ["bytecode", "ast", "sandbox"]


dataclass
class DistributedTask
    #     """Represents a distributed task."""
    #     task_id: str
    #     code: str
    #     execution_mode: str
    context: Optional[Dict[str, Any]] = None
    assigned_node: Optional[str] = None
    status: TaskStatus = TaskStatus.PENDING
    result: Optional[Any] = None
    error: Optional[str] = None
    created_at: float = 0.0
    started_at: Optional[float] = None
    completed_at: Optional[float] = None

    #     def __post_init__(self):
    #         if self.created_at = 0.0:
    self.created_at = time.time()


dataclass
class NoodleNetConfig
    #     """Configuration for NoodleNet integration."""
    #     node_id: str
    #     address: str
    #     port: int
    max_connections: int = 20
    heartbeat_interval: float = 5.0
    task_timeout: float = 30.0
    retry_attempts: int = 3
    enable_discovery: bool = True
    discovery_interval: float = 10.0
    security_enabled: bool = True
    trusted_nodes: Optional[List[str]] = None

    #     def __post_init__(self):
    #         if self.trusted_nodes is None:
    self.trusted_nodes = []


class NoodleNetIntegration
    #     """
    #     Integration layer for NoodleNet distributed execution.

    #     This class provides functionality to execute NoodleCore programs
    #     across multiple nodes in a NoodleNet network.
    #     """

    #     def __init__(self, config: NoodleNetConfig):""
    #         Initialize NoodleNet integration.

    #         Args:
    #             config: NoodleNet configuration
    #         """
    self.config = config
    self.logger = logging.getLogger(__name__)
    self._nodes: Dict[str, NoodleNetNode] = {}
    self._tasks: Dict[str, DistributedTask] = {}
    self._running = False
    self._heartbeat_task = None
    self._discovery_task = None
    self._event_handlers = {
    #             "node_connected": [],
    #             "node_disconnected": [],
    #             "task_completed": [],
    #             "task_failed": []
    #         }

    #     def start(self) -None):
    #         """Start NoodleNet integration."""
    #         if self._running:
    #             return

            self.logger.info(f"Starting NoodleNet integration on {self.config.address}:{self.config.port}")
    self._running = True

    #         # Start heartbeat task
    self._heartbeat_task = asyncio.create_task(self._heartbeat_loop())

    #         # Start discovery task if enabled
    #         if self.config.enable_discovery:
    self._discovery_task = asyncio.create_task(self._discovery_loop())

    #         # Register this node
    self_node = NoodleNetNode(
    node_id = self.config.node_id,
    address = self.config.address,
    port = self.config.port,
    status = NodeStatus.IDLE,
    last_heartbeat = time.time()
    #         )
    self._nodes[self.config.node_id] = self_node

    #     def stop(self) -None):
    #         """Stop NoodleNet integration."""
    #         if not self._running:
    #             return

            self.logger.info("Stopping NoodleNet integration")
    self._running = False

    #         # Cancel background tasks
    #         if self._heartbeat_task:
                self._heartbeat_task.cancel()
    #         if self._discovery_task:
                self._discovery_task.cancel()

    #     def add_node(self, node: NoodleNetNode) -None):
    #         """
    #         Add a node to the network.

    #         Args:
    #             node: Node to add
    #         """
    #         if node.node_id in self._nodes:
                self.logger.warning(f"Node {node.node_id} already exists, updating")

    self._nodes[node.node_id] = node
            self.logger.info(f"Added node {node.node_id} at {node.address}:{node.port}")

    #         # Trigger event
            self._trigger_event("node_connected", node)

    #     def remove_node(self, node_id: str) -None):
    #         """
    #         Remove a node from the network.

    #         Args:
    #             node_id: ID of node to remove
    #         """
    #         if node_id not in self._nodes:
    #             return

    node = self._nodes[node_id]
    #         del self._nodes[node_id]
            self.logger.info(f"Removed node {node_id}")

    #         # Trigger event
            self._trigger_event("node_disconnected", node)

    #     def get_available_nodes(self, capabilities: Optional[List[str]] = None) -List[NoodleNetNode]):
    #         """
    #         Get available nodes with specific capabilities.

    #         Args:
    #             capabilities: Required capabilities

    #         Returns:
    #             List of available nodes
    #         """
    available_nodes = []

    #         for node in self._nodes.values():
    #             if node.status != NodeStatus.IDLE:
    #                 continue

    #             if capabilities:
    #                 if not all(cap in node.capabilities for cap in capabilities):
    #                     continue

                available_nodes.append(node)

            # Sort by load (lowest first)
    return sorted(available_nodes, key = lambda n: n.load)

    #     def submit_task(self, task: DistributedTask) -str):
    #         """
    #         Submit a task for distributed execution.

    #         Args:
    #             task: Task to submit

    #         Returns:
    #             Task ID

    #         Raises:
    #             DistributedExecutionError: If no suitable node is available
    #         """
    #         # Find suitable node
    required_capabilities = [task.execution_mode]
    available_nodes = self.get_available_nodes(required_capabilities)

    #         if not available_nodes:
    #             raise DistributedExecutionError("No suitable nodes available for execution")

    #         # Assign to least loaded node
    node = available_nodes[0]
    task.assigned_node = node.node_id
    task.status = TaskStatus.PENDING

    #         # Store task
    self._tasks[task.task_id] = task

    #         # Send task to node
            asyncio.create_task(self._send_task_to_node(node, task))

    #         return task.task_id

    #     def get_task_status(self, task_id: str) -Optional[TaskStatus]):
    #         """
    #         Get the status of a task.

    #         Args:
    #             task_id: ID of the task

    #         Returns:
    #             Task status or None if not found
    #         """
    task = self._tasks.get(task_id)
    #         return task.status if task else None

    #     def get_task_result(self, task_id: str) -Optional[Any]):
    #         """
    #         Get the result of a completed task.

    #         Args:
    #             task_id: ID of the task

    #         Returns:
    #             Task result or None if not completed
    #         """
    task = self._tasks.get(task_id)
    #         if task and task.status == TaskStatus.COMPLETED:
    #             return task.result
    #         return None

    #     def cancel_task(self, task_id: str) -bool):
    #         """
    #         Cancel a task.

    #         Args:
    #             task_id: ID of the task to cancel

    #         Returns:
    #             True if cancelled, False if not found or already completed
    #         """
    task = self._tasks.get(task_id)
    #         if not task:
    #             return False

    #         if task.status in [TaskStatus.COMPLETED, TaskStatus.FAILED, TaskStatus.CANCELLED]:
    #             return False

    task.status = TaskStatus.CANCELLED

    #         # Send cancellation to node if running
    #         if task.assigned_node and task.status == TaskStatus.RUNNING:
    node = self._nodes.get(task.assigned_node)
    #             if node:
                    asyncio.create_task(self._send_cancel_to_node(node, task_id))

    #         return True

    #     def add_event_handler(self, event: str, handler: Callable) -None):
    #         """
    #         Add an event handler.

    #         Args:
    #             event: Event name
    #             handler: Handler function
    #         """
    #         if event in self._event_handlers:
                self._event_handlers[event].append(handler)

    #     def remove_event_handler(self, event: str, handler: Callable) -None):
    #         """
    #         Remove an event handler.

    #         Args:
    #             event: Event name
    #             handler: Handler function
    #         """
    #         if event in self._event_handlers and handler in self._event_handlers[event]:
                self._event_handlers[event].remove(handler)

    #     async def _heartbeat_loop(self) -None):
    #         """Heartbeat loop to maintain node connections."""
    #         while self._running:
    #             try:
                    await asyncio.sleep(self.config.heartbeat_interval)

    #                 # Update our own heartbeat
    #                 if self.config.node_id in self._nodes:
    self._nodes[self.config.node_id].last_heartbeat = time.time()

    #                 # Check other nodes
    current_time = time.time()
    timeout = self.config.heartbeat_interval * 3

    nodes_to_remove = []
    #                 for node_id, node in self._nodes.items():
    #                     if node_id == self.config.node_id:
    #                         continue

    #                     if current_time - node.last_heartbeat timeout):
                            self.logger.warning(f"Node {node_id} heartbeat timeout")
                            nodes_to_remove.append(node_id)

    #                 for node_id in nodes_to_remove:
                        self.remove_node(node_id)

    #             except asyncio.CancelledError:
    #                 break
    #             except Exception as e:
                    self.logger.error(f"Error in heartbeat loop: {str(e)}")

    #     async def _discovery_loop(self) -None):
    #         """Discovery loop to find new nodes."""
    #         while self._running:
    #             try:
                    await asyncio.sleep(self.config.discovery_interval)

    #                 # In a real implementation, this would discover nodes
    #                 # For now, we'll just log
                    self.logger.debug("Running node discovery")

    #             except asyncio.CancelledError:
    #                 break
    #             except Exception as e:
                    self.logger.error(f"Error in discovery loop: {str(e)}")

    #     async def _send_task_to_node(self, node: NoodleNetNode, task: DistributedTask) -None):
    #         """
    #         Send a task to a node for execution.

    #         Args:
    #             node: Target node
    #             task: Task to send
    #         """
    #         try:
    #             # Update node status
    node.status = NodeStatus.BUSY

    #             # Update task status
    task.status = TaskStatus.RUNNING
    task.started_at = time.time()

    #             # In a real implementation, this would send the task over the network
    #             # For now, we'll simulate execution
                self.logger.info(f"Sending task {task.task_id} to node {node.node_id}")

    #             # Simulate execution
                await asyncio.sleep(1.0)

    #             # Simulate result
    task.result = f"Result from {node.node_id}"
    task.status = TaskStatus.COMPLETED
    task.completed_at = time.time()

    #             # Update node status
    node.status = NodeStatus.IDLE

    #             # Trigger event
                self._trigger_event("task_completed", task)

    #         except Exception as e:
                self.logger.error(f"Error executing task {task.task_id} on node {node.node_id}: {str(e)}")

    #             # Update task status
    task.status = TaskStatus.FAILED
    task.error = str(e)
    task.completed_at = time.time()

    #             # Update node status
    node.status = NodeStatus.ERROR

    #             # Trigger event
                self._trigger_event("task_failed", task)

    #     async def _send_cancel_to_node(self, node: NoodleNetNode, task_id: str) -None):
    #         """
    #         Send a cancellation request to a node.

    #         Args:
    #             node: Target node
    #             task_id: ID of task to cancel
    #         """
    #         try:
    #             # In a real implementation, this would send the cancellation over the network
                self.logger.info(f"Cancelling task {task_id} on node {node.node_id}")

    #         except Exception as e:
                self.logger.error(f"Error cancelling task {task_id} on node {node.node_id}: {str(e)}")

    #     def _trigger_event(self, event: str, data: Any) -None):
    #         """
    #         Trigger an event.

    #         Args:
    #             event: Event name
    #             data: Event data
    #         """
    #         if event in self._event_handlers:
    #             for handler in self._event_handlers[event]:
    #                 try:
                        handler(data)
    #                 except Exception as e:
    #                     self.logger.error(f"Error in event handler for {event}: {str(e)}")

    #     def get_network_stats(self) -Dict[str, Any]):
    #         """
    #         Get network statistics.

    #         Returns:
    #             Network statistics
    #         """
    total_nodes = len(self._nodes)
    #         idle_nodes = sum(1 for n in self._nodes.values() if n.status == NodeStatus.IDLE)
    #         busy_nodes = sum(1 for n in self._nodes.values() if n.status == NodeStatus.BUSY)
    #         error_nodes = sum(1 for n in self._nodes.values() if n.status == NodeStatus.ERROR)

    total_tasks = len(self._tasks)
    #         pending_tasks = sum(1 for t in self._tasks.values() if t.status == TaskStatus.PENDING)
    #         running_tasks = sum(1 for t in self._tasks.values() if t.status == TaskStatus.RUNNING)
    #         completed_tasks = sum(1 for t in self._tasks.values() if t.status == TaskStatus.COMPLETED)
    #         failed_tasks = sum(1 for t in self._tasks.values() if t.status == TaskStatus.FAILED)

    #         return {
    #             "nodes": {
    #                 "total": total_nodes,
    #                 "idle": idle_nodes,
    #                 "busy": busy_nodes,
    #                 "error": error_nodes
    #             },
    #             "tasks": {
    #                 "total": total_tasks,
    #                 "pending": pending_tasks,
    #                 "running": running_tasks,
    #                 "completed": completed_tasks,
    #                 "failed": failed_tasks
    #             }
    #         }