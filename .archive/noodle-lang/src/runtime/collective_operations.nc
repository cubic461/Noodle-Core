# Converted from Python to NoodleCore
# Original file: src

# """
# Collective Operations for Distributed Runtime
# --------------------------------------------
This module implements efficient collective operations (all-reduce, all-gather, broadcast)
# for distributed tensor computations across multiple nodes.
# """

import asyncio
import concurrent.futures
import json
import logging
import struct
import threading
import time
from dataclasses import dataclass
import datetime.datetime
import enum.Enum
import typing.Any

import .cluster_manager.ClusterManager
import .network_protocol.NetworkMessage

# Import existing components
import .scheduler.Node

logger = logging.getLogger(__name__)


class CollectiveOperationType(Enum)
    #     """Types of collective operations"""

    ALL_REDUCE = "all_reduce"
    ALL_GATHER = "all_gather"
    BROADCAST = "broadcast"
    REDUCE_SCATTER = "reduce_scatter"
    ALL_TO_ALL = "all_to_all"
    BARRIER = "barrier"


class ReductionOperation(Enum)
    #     """Reduction operations for all-reduce"""

    SUM = "sum"
    PRODUCT = "product"
    MIN = "min"
    MAX = "max"
    MEAN = "mean"
    AND = "and"
    OR = "or"
    XOR = "xor"
    CUSTOM = "custom"


dataclass
class CollectiveOperation
    #     """Represents a collective operation"""

    #     operation_id: str
    #     operation_type: CollectiveOperationType
    #     participants: List[str]
    #     data: bytes
    reduction_op: ReductionOperation = ReductionOperation.SUM
    timeout: float = 30.0
    priority: int = 0
    metadata: Dict[str, Any] = field(default_factory=dict)
    created_at: datetime = field(default_factory=datetime.now)
    status: str = "pending"
    result: Optional[bytes] = None
    error_message: Optional[str] = None


dataclass
class CollectiveConfig
    #     """Configuration for collective operations"""

    max_concurrent_operations: int = 10
    operation_timeout: float = 30.0
    retry_attempts: int = 3
    retry_delay: float = 1.0
    enable_optimization: bool = True
    tree_arity: int = 2  # Binary tree by default
    use_ring_allreduce: bool = True
    use_segmented_reduce: bool = True
    segment_size: int = 1024 * 1024  # 1MB segments
    enable_compression: bool = True
    compression_threshold: int = 1024 * 1024  # 1MB
    enable_encryption: bool = False
    encryption_key: Optional[bytes] = None


class CollectiveOperationManager
    #     """
    #     Efficient implementation of collective operations for distributed tensor computations
    #     """

    #     def __init__(
    #         self,
    config: CollectiveConfig = None,
    cluster_manager: ClusterManager = None,
    network_protocol: NetworkProtocol = None,
    #     ):""
    #         Initialize the collective operation manager

    #         Args:
    #             config: Collective operation configuration
    #             cluster_manager: Cluster manager instance
    #             network_protocol: Network protocol instance
    #         """
    self.config = config or CollectiveConfig()
    self.cluster_manager = cluster_manager
    self.network_protocol = network_protocol

    #         # Operation state
    self.active_operations: Dict[str, CollectiveOperation] = {}
    self.operation_queue: List[CollectiveOperation] = []
    self.operation_lock = threading.Lock()

    #         # Threading
    self.worker_thread = None
    self.running = False

    #         # Statistics
    self.stats = {
    #             "operations_started": 0,
    #             "operations_completed": 0,
    #             "operations_failed": 0,
    #             "total_bytes_transferred": 0,
    #             "avg_operation_time": 0.0,
    #             "total_operation_time": 0.0,
    #             "concurrent_operations": 0,
    #         }

    #         # Callbacks
    self.operation_callbacks: Dict[str, Callable] = {}

            logger.info("Collective operation manager initialized")

    #     def start(self):
    #         """Start the collective operation manager"""
    #         if self.running:
                logger.warning("Collective operation manager is already running")
    #             return

    self.running = True
            logger.info("Starting collective operation manager...")

    #         try:
    #             # Start worker thread
    self.worker_thread = threading.Thread(target=self._worker_loop, daemon=True)
                self.worker_thread.start()

                logger.info("Collective operation manager started successfully")

    #         except Exception as e:
    self.running = False
                logger.error(f"Failed to start collective operation manager: {e}")
    #             raise

    #     def stop(self):
    #         """Stop the collective operation manager"""
    #         if not self.running:
                logger.warning("Collective operation manager is not running")
    #             return

    self.running = False
            logger.info("Stopping collective operation manager...")

    #         try:
    #             # Wait for worker thread to finish
    #             if self.worker_thread:
    self.worker_thread.join(timeout = 5.0)

                logger.info("Collective operation manager stopped successfully")

    #         except Exception as e:
                logger.error(f"Error stopping collective operation manager: {e}")
    #             raise

    #     def submit_operation(
    #         self,
    #         operation_type: CollectiveOperationType,
    #         participants: List[str],
    #         data: bytes,
    reduction_op: ReductionOperation = ReductionOperation.SUM,
    timeout: float = None,
    priority: int = 0,
    metadata: Dict[str, Any] = None,
    callback: Callable = None,
    #     ) -str):
    #         """
    #         Submit a collective operation for execution

    #         Args:
    #             operation_type: Type of collective operation
    #             participants: List of participant node IDs
    #             data: Input data for the operation
    #             reduction_op: Reduction operation (for all-reduce)
    #             timeout: Operation timeout
    #             priority: Operation priority
    #             metadata: Additional metadata
    #             callback: Callback function for operation completion

    #         Returns:
    #             Operation ID
    #         """
    #         if not self.running:
                raise RuntimeError("Collective operation manager is not running")

    #         # Generate operation ID
    operation_id = f"op_{time.time_ns()}_{len(self.active_operations)}"

    #         # Create operation
    operation = CollectiveOperation(
    operation_id = operation_id,
    operation_type = operation_type,
    participants = participants,
    data = data,
    reduction_op = reduction_op,
    timeout = timeout or self.config.operation_timeout,
    priority = priority,
    metadata = metadata or {},
    #         )

    #         # Store callback
    #         if callback:
    self.operation_callbacks[operation_id] = callback

    #         # Add to queue
    #         with self.operation_lock:
                self._insert_operation_by_priority(operation)
                self.operation_queue.append(operation)

    #         # Update stats
    self.stats["operations_started"] + = 1

            logger.info(
    #             f"Submitted collective operation {operation_id}: {operation_type.value} "
    #             f"with {len(participants)} participants"
    #         )

    #         return operation_id

    #     def get_operation_status(self, operation_id: str) -Optional[Dict[str, Any]]):
    #         """
    #         Get the status of a collective operation

    #         Args:
    #             operation_id: Operation ID

    #         Returns:
    #             Operation status or None if not found
    #         """
    #         with self.operation_lock:
    #             if operation_id in self.active_operations:
    operation = self.active_operations[operation_id]
    #                 return {
    #                     "operation_id": operation.operation_id,
    #                     "operation_type": operation.operation_type.value,
    #                     "status": operation.status,
    #                     "participants": operation.participants,
                        "created_at": operation.created_at.isoformat(),
                        "progress": self._calculate_operation_progress(operation),
    #                 }
    #             elif operation_id in [op.operation_id for op in self.operation_queue]:
    #                 return {
    #                     "operation_id": operation_id,
    #                     "status": "queued",
                        "position": self._get_operation_queue_position(operation_id),
    #                 }

    #         return None

    #     def get_operation_result(
    self, operation_id: str, timeout: float = None
    #     ) -Optional[bytes]):
    #         """
    #         Get the result of a completed collective operation

    #         Args:
    #             operation_id: Operation ID
    #             timeout: Maximum time to wait for result

    #         Returns:
    #             Operation result or None if operation not completed
    #         """
    #         with self.operation_lock:
    #             if operation_id in self.active_operations:
    operation = self.active_operations[operation_id]
    #                 if operation.status == "completed":
    #                     return operation.result
    #                 elif operation.status == "failed":
                        raise RuntimeError(f"Operation failed: {operation.error_message}")

    #         # Wait for completion if timeout specified
    #         if timeout:
    start_time = time.time()
    #             while time.time() - start_time < timeout:
    status = self.get_operation_status(operation_id)
    #                 if status and status["status"] == "completed":
    #                     with self.operation_lock:
    operation = self.active_operations[operation_id]
    #                         return operation.result
    #                 elif status and status["status"] == "failed":
    #                     with self.operation_lock:
    operation = self.active_operations[operation_id]
                        raise RuntimeError(f"Operation failed: {operation.error_message}")
                    time.sleep(0.1)

    #         return None

    #     def cancel_operation(self, operation_id: str) -bool):
    #         """
    #         Cancel a pending or running collective operation

    #         Args:
    #             operation_id: Operation ID

    #         Returns:
    #             True if operation cancelled, False otherwise
    #         """
    #         with self.operation_lock:
    #             # Check if operation is in queue
    #             for i, operation in enumerate(self.operation_queue):
    #                 if operation.operation_id == operation_id:
    #                     del self.operation_queue[i]
                        logger.info(f"Cancelled queued operation {operation_id}")
    #                     return True

    #             # Check if operation is active
    #             if operation_id in self.active_operations:
    operation = self.active_operations[operation_id]
    operation.status = "cancelled"
    operation.error_message = "Operation cancelled by user"
                    logger.info(f"Cancelled active operation {operation_id}")
    #                 return True

    #         return False

    #     def get_collective_stats(self) -Dict[str, Any]):
    #         """
    #         Get collective operation statistics

    #         Returns:
    #             Collective operation statistics
    #         """
    #         return {
    #             **self.stats,
    #             "running": self.running,
                "active_operations": len(self.active_operations),
                "queued_operations": len(self.operation_queue),
    #             "max_concurrent": self.config.max_concurrent_operations,
    #         }

    #     def _worker_loop(self):
    #         """Main worker loop for processing collective operations"""
    #         while self.running:
    #             try:
    #                 with self.operation_lock:
    #                     # Check if we can start more operations
    #                     if (
                            len(self.active_operations)
    = self.config.max_concurrent_operations
    #                         or not self.operation_queue
    #                     )):
                            time.sleep(0.1)
    #                         continue

    #                     # Get next operation from queue
    operation = self.operation_queue.pop(0)
    self.active_operations[operation.operation_id] = operation

    #                 # Execute operation
                    self._execute_operation(operation)

    #             except Exception as e:
                    logger.error(f"Error in worker loop: {e}")
                    time.sleep(1.0)

    #     def _execute_operation(self, operation: CollectiveOperation):
    #         """Execute a collective operation"""
    start_time = time.time()
    operation.status = "running"

    #         try:
    #             if operation.operation_type == CollectiveOperationType.ALL_REDUCE:
    result = self._execute_all_reduce(operation)
    #             elif operation.operation_type == CollectiveOperationType.ALL_GATHER:
    result = self._execute_all_gather(operation)
    #             elif operation.operation_type == CollectiveOperationType.BROADCAST:
    result = self._execute_broadcast(operation)
    #             elif operation.operation_type == CollectiveOperationType.REDUCE_SCATTER:
    result = self._execute_reduce_scatter(operation)
    #             elif operation.operation_type == CollectiveOperationType.ALL_TO_ALL:
    result = self._execute_all_to_all(operation)
    #             elif operation.operation_type == CollectiveOperationType.BARRIER:
    result = self._execute_barrier(operation)
    #             else:
                    raise ValueError(
    #                     f"Unsupported operation type: {operation.operation_type}"
    #                 )

    #             # Store result
    operation.result = result
    operation.status = "completed"

    #             # Update stats
    operation_time = time.time() - start_time
    self.stats["operations_completed"] + = 1
    self.stats["total_operation_time"] + = operation_time
    self.stats["avg_operation_time"] = (
    #                 self.stats["total_operation_time"] / self.stats["operations_completed"]
    #             )

                logger.info(
    #                 f"Completed collective operation {operation.operation_id} "
    #                 f"in {operation_time:.2f}s"
    #             )

    #             # Call callback if registered
    #             if operation.operation_id in self.operation_callbacks:
    #                 try:
                        self.operation_callbacks[operation.operation_id](operation)
    #                 except Exception as e:
                        logger.error(f"Error in operation callback: {e}")

    #         except Exception as e:
    operation.status = "failed"
    operation.error_message = str(e)

    #             # Update stats
    self.stats["operations_failed"] + = 1

                logger.error(f"Failed collective operation {operation.operation_id}: {e}")

    #             # Call callback if registered
    #             if operation.operation_id in self.operation_callbacks:
    #                 try:
                        self.operation_callbacks[operation.operation_id](operation)
    #                 except Exception as e:
                        logger.error(f"Error in operation callback: {e}")

    #         finally:
    #             # Remove from active operations
    #             with self.operation_lock:
    #                 if operation.operation_id in self.active_operations:
    #                     del self.active_operations[operation.operation_id]

    #     def _execute_all_reduce(self, operation: CollectiveOperation) -bytes):
    #         """Execute all-reduce operation"""
    participants = operation.participants
    data = operation.data
    reduction_op = operation.reduction_op

    #         if len(participants) == 1:
    #             return data  # Single node, no reduction needed

    #         # Choose algorithm based on data size and participant count
    #         if (
    #             self.config.use_segmented_reduce
                and len(data) self.config.segment_size
                and len(participants) > self.config.tree_arity
    #         )):
                return self._segmented_tree_allreduce(participants, data, reduction_op)
    #         elif self.config.use_ring_allreduce and len(participants) 2):
                return self._ring_allreduce(participants, data, reduction_op)
    #         else:
                return self._tree_allreduce(participants, data, reduction_op)

    #     def _execute_all_gather(self, operation: CollectiveOperation) -bytes):
    #         """Execute all-gather operation"""
    participants = operation.participants
    data = operation.data

    #         if len(participants) == 1:
    #             return data  # Single node, no gathering needed

    #         # Simple ring all-gather
            return self._ring_allgather(participants, data)

    #     def _execute_broadcast(self, operation: CollectiveOperation) -bytes):
    #         """Execute broadcast operation"""
    participants = operation.participants
    data = operation.data

    #         if len(participants) == 1:
    #             return data  # Single node, no broadcast needed

    #         # Tree broadcast
            return self._tree_broadcast(participants, data)

    #     def _execute_reduce_scatter(self, operation: CollectiveOperation) -bytes):
    #         """Execute reduce-scatter operation"""
    participants = operation.participants
    data = operation.data
    reduction_op = operation.reduction_op

    #         if len(participants) == 1:
    #             return data  # Single node, no reduce-scatter needed

    #         # Simple implementation - could be optimized
            return self._tree_reduce_scatter(participants, data, reduction_op)

    #     def _execute_all_to_all(self, operation: CollectiveOperation) -bytes):
    #         """Execute all-to-all operation"""
    participants = operation.participants
    data = operation.data

    #         if len(participants) == 1:
    #             return data  # Single node, no all-to-all needed

    #         # Simple ring all-to-all
            return self._ring_alltoall(participants, data)

    #     def _execute_barrier(self, operation: CollectiveOperation) -bytes):
    #         """Execute barrier operation"""
    participants = operation.participants

    #         if len(participants) == 1:
    #             return b""  # Single node, barrier is immediate

    #         # Simple barrier implementation
            return self._tree_barrier(participants)

    #     def _tree_allreduce(
    #         self, participants: List[str], data: bytes, reduction_op: ReductionOperation
    #     ) -bytes):
    #         """Tree-based all-reduce algorithm"""
    n = len(participants)
    #         if n = 1:
    #             return data

    #         # Build binary tree
    tree_depth = int(math.ceil(math.log2(n)))

            # Phase 1: Reduce (up the tree)
    reduced_data = data
    #         for level in range(tree_depth):
    #             # Group participants at current level
    level_size = 2 * *level
    #             for i in range(0, n, 2 * level_size):
    group = participants[i : i + 2 * level_size]
    #                 if len(group) level_size):
    #                     # Reduce data in this group
    group_data = [
                            self._send_receive_data(node, reduced_data)
    #                         for node in group[level_size:]
    #                     ]
    reduced_data = self._apply_reduction(group_data, reduction_op)

            # Phase 2: Broadcast (down the tree)
    result_data = reduced_data
    #         for level in reversed(range(tree_depth)):
    level_size = 2 * *level
    #             for i in range(0, n, 2 * level_size):
    group = participants[i : i + 2 * level_size]
    #                 if len(group) level_size):
    #                     # Broadcast data to this group
    #                     for node in group[:level_size]:
                            self._send_receive_data(node, result_data)

    #         return result_data

    #     def _ring_allreduce(
    #         self, participants: List[str], data: bytes, reduction_op: ReductionOperation
    #     ) -bytes):
    #         """Ring-based all-reduce algorithm"""
    n = len(participants)
    #         if n = 1:
    #             return data

    #         # Split data into chunks
    chunk_size = math.divide(len(data), / n)
    #         chunks = [data[i : i + chunk_size] for i in range(0, len(data), chunk_size)]

    #         # Phase 1: Reduce-scatter
    reduced_chunks = chunks.copy()
    #         for step in range(n - 1):
    #             for i in range(n):
    recv_chunk = self._send_receive_data(
                        participants[(i + step + 1) % n], reduced_chunks[(i + step) % n]
    #                 )
    reduced_chunks[(i + step) % n] = self._apply_reduction(
                        [reduced_chunks[(i + step) % n], recv_chunk], reduction_op
    #                 )

    #         # Phase 2: All-gather
    result_chunks = []
    #         for step in range(n):
    recv_chunk = self._send_receive_data(
                    participants[(step + 1) % n], reduced_chunks[step]
    #             )
                result_chunks.extend([recv_chunk] * n)

    #         # Combine chunks
    result = b"".join(result_chunks[:n])
    #         return result

    #     def _segmented_tree_allreduce(
    #         self, participants: List[str], data: bytes, reduction_op: ReductionOperation
    #     ) -bytes):
    #         """Segmented tree all-reduce for large data"""
    segment_size = self.config.segment_size
    segments = [
    #             data[i : i + segment_size] for i in range(0, len(data), segment_size)
    #         ]

    #         # Process each segment independently
    reduced_segments = []
    #         for segment in segments:
    reduced_segment = self._tree_allreduce(participants, segment, reduction_op)
                reduced_segments.append(reduced_segment)

            return b"".join(reduced_segments)

    #     def _ring_allgather(self, participants: List[str], data: bytes) -bytes):
    #         """Ring-based all-gather algorithm"""
    n = len(participants)
    #         if n = 1:
    #             return data

    #         # Split data into chunks
    chunk_size = math.divide(len(data), / n)
    #         chunks = [data[i : i + chunk_size] for i in range(0, len(data), chunk_size)]

    #         # Ring all-gather
    gathered_chunks = chunks.copy()
    #         for step in range(n - 1):
    #             for i in range(n):
    recv_chunk = self._send_receive_data(
                        participants[(i + step + 1) % n], gathered_chunks[(i + step) % n]
    #                 )
    gathered_chunks[(i + step) % n] = recv_chunk

    #         # Combine chunks
    result = b"".join(gathered_chunks)
    #         return result

    #     def _tree_broadcast(self, participants: List[str], data: bytes) -bytes):
    #         """Tree-based broadcast algorithm"""
    n = len(participants)
    #         if n = 1:
    #             return data

    #         # Build binary tree
    tree_depth = int(math.ceil(math.log2(n)))

    #         # Broadcast down the tree
    #         for level in range(tree_depth):
    level_size = 2 * *level
    #             for i in range(0, n, 2 * level_size):
    group = participants[i : i + 2 * level_size]
    #                 if len(group) level_size):
    #                     # Broadcast data to this group
    #                     for node in group[level_size:]:
                            self._send_receive_data(node, data)

    #         return data

    #     def _tree_reduce_scatter(
    #         self, participants: List[str], data: bytes, reduction_op: ReductionOperation
    #     ) -bytes):
    #         """Tree-based reduce-scatter algorithm"""
    n = len(participants)
    #         if n = 1:
    #             return data

    #         # Split data into chunks
    chunk_size = math.divide(len(data), / n)
    #         chunks = [data[i : i + chunk_size] for i in range(0, len(data), chunk_size)]

    #         # Reduce-scatter using tree structure
    reduced_chunks = chunks.copy()
    #         for level in range(int(math.ceil(math.log2(n)))):
    level_size = 2 * *level
    #             for i in range(0, n, 2 * level_size):
    group = participants[i : i + 2 * level_size]
    #                 if len(group) level_size):
    #                     # Reduce chunks in this group
    group_chunks = reduced_chunks[i : i + level_size]
    reduced_chunk = self._apply_reduction(group_chunks, reduction_op)
    reduced_chunks[i : i + level_size] = [reduced_chunk] * level_size

            return b"".join(reduced_chunks)

    #     def _ring_alltoall(self, participants: List[str], data: bytes) -bytes):
    #         """Ring-based all-to-all algorithm"""
    n = len(participants)
    #         if n = 1:
    #             return data

    #         # Split data into chunks
    chunk_size = math.divide(len(data), / n)
    #         chunks = [data[i : i + chunk_size] for i in range(0, len(data), chunk_size)]

    #         # All-to-all communication
    result_chunks = []
    #         for i in range(n):
    recv_chunk = self._send_receive_data(participants[i], chunks[i])
                result_chunks.append(recv_chunk)

            return b"".join(result_chunks)

    #     def _tree_barrier(self, participants: List[str]) -bytes):
    #         """Tree-based barrier algorithm"""
    n = len(participants)
    #         if n = 1:
    #             return b""

    #         # Simple barrier implementation
    #         for participant in participants[1:]:
                self._send_receive_data(participant, b"barrier")

    #         return b"barrier_complete"

    #     def _send_receive_data(self, target_node: str, data: bytes) -bytes):
    #         """Send data to target node and receive response"""
    #         if not self.network_protocol:
                raise RuntimeError("Network protocol not available")

    #         # Send data
    message_id = self.network_protocol.send_tensor(data, None, target_node)

    #         # Wait for response (simplified - would need proper response handling)
            time.sleep(0.1)  # Simulate network delay

    #         # Return dummy data for now
    #         return data

    #     def _apply_reduction(
    #         self, data_list: List[bytes], reduction_op: ReductionOperation
    #     ) -bytes):
    #         """Apply reduction operation to list of data"""
    #         if not data_list:
    #             return b""

    #         if reduction_op == ReductionOperation.SUM:
    #             # For sum, we need to handle binary data
    #             # This is a simplified implementation
    #             return data_list[0]  # Placeholder
    #         elif reduction_op == ReductionOperation.PRODUCT:
    #             return data_list[0]  # Placeholder
    #         elif reduction_op == ReductionOperation.MIN:
    #             return data_list[0]  # Placeholder
    #         elif reduction_op == ReductionOperation.MAX:
    #             return data_list[0]  # Placeholder
    #         elif reduction_op == ReductionOperation.MEAN:
    #             return data_list[0]  # Placeholder
    #         else:
    #             return data_list[0]  # Default

    #     def _insert_operation_by_priority(self, operation: CollectiveOperation):
    #         """Insert operation into queue by priority"""
    #         # Find position to insert based on priority
    insert_pos = 0
    #         for i, queued_op in enumerate(self.operation_queue):
    #             if queued_op.priority <= operation.priority:
    insert_pos = i + 1
    #             else:
    #                 break

            self.operation_queue.insert(insert_pos, operation)

    #     def _calculate_operation_progress(self, operation: CollectiveOperation) -float):
            """Calculate operation progress (0.0 to 1.0)"""
    #         # Simplified progress calculation
    #         if operation.status == "completed":
    #             return 1.0
    #         elif operation.status == "failed":
    #             return 0.0
    #         elif operation.status == "cancelled":
    #             return 0.0
    #         else:
    #             return 0.5  # Default progress for running operations

    #     def _get_operation_queue_position(self, operation_id: str) -int):
    #         """Get position of operation in queue"""
    #         for i, operation in enumerate(self.operation_queue):
    #             if operation.operation_id == operation_id:
    #                 return i
    #         return -1


# Global collective operation manager instance
_collective_manager = None


def get_collective_manager(
config: CollectiveConfig = None,
cluster_manager: ClusterManager = None,
network_protocol: NetworkProtocol = None,
# ) -CollectiveOperationManager):
#     """Get the global collective operation manager instance"""
#     global _collective_manager
#     if _collective_manager is None:
_collective_manager = CollectiveOperationManager(
#             config, cluster_manager, network_protocol
#         )
#     return _collective_manager


def start_collective_manager(
config: CollectiveConfig = None,
cluster_manager: ClusterManager = None,
network_protocol: NetworkProtocol = None,
# ):
#     """Start the global collective operation manager"""
manager = get_collective_manager(config, cluster_manager, network_protocol)
    manager.start()


function stop_collective_manager()
    #     """Stop the global collective operation manager"""
    #     global _collective_manager
    #     if _collective_manager:
            _collective_manager.stop()


dataclass
class CollectiveStats
    #     """Statistics for collective operations"""

    total_operations: int = 0
    successful_operations: int = 0
    failed_operations: int = 0
    total_bytes_transferred: int = 0
    average_operation_time: float = 0.0
    total_operation_time: float = 0.0
    concurrent_operations: int = 0

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary"""
    #         return {
    #             "total_operations": self.total_operations,
    #             "successful_operations": self.successful_operations,
    #             "failed_operations": self.failed_operations,
                "success_rate": self.successful_operations / max(self.total_operations, 1),
    #             "total_bytes_transferred": self.total_bytes_transferred,
    #             "average_operation_time": self.average_operation_time,
    #             "total_operation_time": self.total_operation_time,
    #             "concurrent_operations": self.concurrent_operations,
    #         }


# Global collective operation manager instance
_collective_manager == None