# Converted from Python to NoodleCore
# Original file: src

# """
# Database Transaction Management for NBC Runtime

# This module provides advanced transaction management with support for
# savepoints, isolation levels, deadlock detection, and distributed transactions.
# """

import logging
import threading
import time
import uuid
import weakref
import contextlib.contextmanager
from dataclasses import dataclass
import datetime.datetime
import enum.Enum
import typing.Any

import .connection.ConnectionState

logger = logging.getLogger(__name__)


class TransactionStatus(Enum)
    #     """Transaction states."""

    ACTIVE = "active"
    COMMITTED = "committed"
    ROLLED_BACK = "rolled_back"
    FAILED = "failed"
    TIMEOUT = "timeout"
    DEADLOCK = "deadlock"


class TransactionState(Enum)
    #     """Transaction state machine states."""

    INITIAL = "initial"
    STARTED = "started"
    IN_PROGRESS = "in_progress"
    PREPARED = "prepared"
    COMMITTED = "committed"
    ROLLED_BACK = "rolled_back"
    FAILED = "failed"
    TERMINATED = "terminated"


class IsolationLevel(Enum)
    #     """Transaction isolation levels."""

    READ_UNCOMMITTED = "read_uncommitted"
    READ_COMMITTED = "read_committed"
    REPEATABLE_READ = "repeatable_read"
    SERIALIZABLE = "serializable"


class LockType(Enum)
    #     """Lock types."""

    SHARED = "shared"
    EXCLUSIVE = "exclusive"
    INTENTION_SHARED = "intention_shared"
    INTENTION_EXCLUSIVE = "intention_exclusive"
    SHARED_INTENTION_EXCLUSIVE = "shared_intention_exclusive"


dataclass
class LockRequest
    #     """Lock request information."""

    #     transaction_id: str
    #     resource_id: str
    #     lock_type: LockType
    #     timestamp: datetime
    timeout: float = 30.0

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary."""
    #         return {
    #             "transaction_id": self.transaction_id,
    #             "resource_id": self.resource_id,
    #             "lock_type": self.lock_type.value,
                "timestamp": self.timestamp.isoformat(),
    #             "timeout": self.timeout,
    #         }


dataclass
class Lock
    #     """Lock information."""

    #     resource_id: str
    #     lock_type: LockType
    #     transaction_id: str
    #     granted_at: datetime
    timeout: float = 30.0

    #     def is_expired(self) -bool):
    #         """Check if lock has expired."""
            return (datetime.now() - self.granted_at).total_seconds() self.timeout

    #     def to_dict(self):
    """Dict[str, Any])"""
    #         """Convert to dictionary."""
    #         return {
    #             "resource_id": self.resource_id,
    #             "lock_type": self.lock_type.value,
    #             "transaction_id": self.transaction_id,
                "granted_at": self.granted_at.isoformat(),
    #             "timeout": self.timeout,
    #         }


dataclass
class Savepoint
    #     """Transaction savepoint."""

    #     name: str
    #     transaction_id: str
    #     created_at: datetime
    data: Dict[str, Any] = field(default_factory=dict)

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary."""
    #         return {
    #             "name": self.name,
    #             "transaction_id": self.transaction_id,
                "created_at": self.created_at.isoformat(),
    #             "data": self.data,
    #         }


dataclass
class TransactionMetrics
    #     """Transaction metrics."""

    #     transaction_id: str
    #     started_at: datetime
    committed_at: Optional[datetime] = None
    rolled_back_at: Optional[datetime] = None
    status: TransactionStatus = TransactionStatus.ACTIVE
    isolation_level: IsolationLevel = IsolationLevel.READ_COMMITTED
    savepoint_count: int = 0
    lock_count: int = 0
    execution_time: float = 0.0
    rollback_count: int = 0
    deadlock_count: int = 0

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary."""
    #         return {
    #             "transaction_id": self.transaction_id,
                "started_at": self.started_at.isoformat(),
                "committed_at": (
    #                 self.committed_at.isoformat() if self.committed_at else None
    #             ),
                "rolled_back_at": (
    #                 self.rolled_back_at.isoformat() if self.rolled_back_at else None
    #             ),
    #             "status": self.status.value,
    #             "isolation_level": self.isolation_level.value,
    #             "savepoint_count": self.savepoint_count,
    #             "lock_count": self.lock_count,
    #             "execution_time": self.execution_time,
    #             "rollback_count": self.rollback_count,
    #             "deadlock_count": self.deadlock_count,
    #         }


class DeadlockDetector
    #     """Deadlock detection using wait-for graph analysis."""

    #     def __init__(self, check_interval: float = 5.0):""
    #         Initialize deadlock detector.

    #         Args:
    #             check_interval: Interval between deadlock checks in seconds
    #         """
    self.check_interval = check_interval
    self._lock_graph: Dict[str, Set[str]] = {}
    self._lock = threading.Lock()
    self._stop_event = threading.Event()
    self._detector_thread = None

    #     def start(self):
    #         """Start deadlock detection thread."""
    #         if self._detector_thread is None:
                self._stop_event.clear()
    self._detector_thread = threading.Thread(target=self._detection_loop)
    self._detector_thread.daemon = True
                self._detector_thread.start()
                logger.info("Started deadlock detector")

    #     def stop(self):
    #         """Stop deadlock detection thread."""
    #         if self._detector_thread is not None:
                self._stop_event.set()
                self._detector_thread.join()
    self._detector_thread = None
                logger.info("Stopped deadlock detector")

    #     def _detection_loop(self):
    #         """Deadlock detection loop."""
    #         while not self._stop_event.is_set():
    #             try:
                    self._check_deadlocks()
                    time.sleep(self.check_interval)
    #             except Exception as e:
                    logger.error(f"Deadlock detection error: {e}")
                    time.sleep(self.check_interval)

    #     def _check_deadlocks(self):
    #         """Check for deadlocks in the wait-for graph."""
    #         with self._lock:
    #             if not self._lock_graph:
    #                 return

    #             # Find cycles in the wait-for graph
    cycles = self._find_cycles(self._lock_graph)

    #             if cycles:
                    logger.warning(f"Detected {len(cycles)} deadlock(s)")
    #                 for cycle in cycles:
                        logger.warning(f"Deadlock cycle: {' -'.join(cycle)}")

    #     def _find_cycles(self, graph): Dict[str, Set[str]]) -List[List[str]]):
    #         """Find cycles in a directed graph."""
    cycles = []
    visited = set()
    rec_stack = set()

    #         def dfs(node, path):
                visited.add(node)
                rec_stack.add(node)
                path.append(node)

    #             for neighbor in graph.get(node, set()):
    #                 if neighbor not in visited:
    #                     if dfs(neighbor, path):
    #                         return True
    #                 elif neighbor in rec_stack:
    #                     # Found a cycle
    cycle_start = path.index(neighbor)
    cycle = path[cycle_start:] + [neighbor]
                        cycles.append(cycle)
    #                     return True

                path.pop()
                rec_stack.remove(node)
    #             return False

    #         for node in graph:
    #             if node not in visited:
                    dfs(node, [])

    #         return cycles

    #     def add_wait_edge(self, transaction_id: str, waits_for: str):
    #         """Add wait edge to wait-for graph."""
    #         with self._lock:
    #             if transaction_id not in self._lock_graph:
    self._lock_graph[transaction_id] = set()
                self._lock_graph[transaction_id].add(waits_for)

    #     def remove_wait_edge(self, transaction_id: str, waits_for: str):
    #         """Remove wait edge from wait-for graph."""
    #         with self._lock:
    #             if transaction_id in self._lock_graph:
                    self._lock_graph[transaction_id].discard(waits_for)
    #                 if not self._lock_graph[transaction_id]:
    #                     del self._lock_graph[transaction_id]

    #     def clear_transaction(self, transaction_id: str):
    #         """Clear all edges for a transaction."""
    #         with self._lock:
    #             # Remove edges where this transaction is waiting
    #             for trans in list(self._lock_graph.keys()):
    #                 if transaction_id in self._lock_graph[trans]:
                        self._lock_graph[trans].discard(transaction_id)
    #                     if not self._lock_graph[trans]:
    #                         del self._lock_graph[trans]

    #             # Remove edges where other transactions are waiting for this one
    #             if transaction_id in self._lock_graph:
    #                 del self._lock_graph[transaction_id]


class LockManager
    #     """Lock manager for transaction isolation."""

    #     def __init__(self, deadlock_detector: Optional[DeadlockDetector] = None):""
    #         Initialize lock manager.

    #         Args:
    #             deadlock_detector: Deadlock detector instance
    #         """
    self._locks: Dict[str, List[Lock]] = {}
    self._lock_requests: Dict[str, List[LockRequest]] = {}
    self._lock = threading.Lock()
    self.deadlock_detector = deadlock_detector or DeadlockDetector()

    #     def acquire_lock(
    #         self,
    #         transaction_id: str,
    #         resource_id: str,
    #         lock_type: LockType,
    timeout: float = 30.0,
    #     ) -bool):
    #         """
    #         Acquire a lock on a resource.

    #         Args:
    #             transaction_id: Transaction requesting the lock
    #             resource_id: Resource to lock
    #             lock_type: Type of lock to acquire
    #             timeout: Timeout for lock acquisition

    #         Returns:
    #             True if lock was acquired, False otherwise
    #         """
    start_time = time.time()

    #         with self._lock:
    #             # Check if transaction already holds a compatible lock
    existing_locks = self._locks.get(resource_id, [])
    #             for lock in existing_locks:
    #                 if lock.transaction_id == transaction_id:
    #                     # Check if existing lock is compatible with requested lock
    #                     if self._is_compatible(lock.lock_type, lock_type):
    #                         return True
    #                     else:
    #                         # Need to upgrade lock
                            return self._upgrade_lock(
    #                             transaction_id, resource_id, lock_type
    #                         )

    #             # Check for conflicts with other transactions
    conflicting_locks = [
    #                 lock
    #                 for lock in existing_locks
    #                 if not self._is_compatible(lock.lock_type, lock_type)
    #             ]

    #             if conflicting_locks:
    #                 # Add to wait queue
    request = LockRequest(
    transaction_id = transaction_id,
    resource_id = resource_id,
    lock_type = lock_type,
    timestamp = datetime.now(),
    timeout = timeout,
    #                 )

    #                 if resource_id not in self._lock_requests:
    self._lock_requests[resource_id] = []
                    self._lock_requests[resource_id].append(request)

    #                 # Add wait edge to deadlock detector
    #                 for conflicting_lock in conflicting_locks:
                        self.deadlock_detector.add_wait_edge(
    #                         transaction_id, conflicting_lock.transaction_id
    #                     )

    #                 # Wait for lock to become available
                    return self._wait_for_lock(transaction_id, resource_id, timeout)
    #             else:
    #                 # No conflicts, acquire lock immediately
    lock = Lock(
    resource_id = resource_id,
    lock_type = lock_type,
    transaction_id = transaction_id,
    granted_at = datetime.now(),
    timeout = timeout,
    #                 )

    #                 if resource_id not in self._locks:
    self._locks[resource_id] = []
                    self._locks[resource_id].append(lock)

                    logger.debug(
    #                     f"Acquired {lock_type.value} lock on {resource_id} for transaction {transaction_id}"
    #                 )
    #                 return True

    #     def release_lock(self, transaction_id: str, resource_id: str) -bool):
    #         """
    #         Release a lock on a resource.

    #         Args:
    #             transaction_id: Transaction releasing the lock
    #             resource_id: Resource to unlock

    #         Returns:
    #             True if lock was released, False otherwise
    #         """
    #         with self._lock:
    #             if resource_id not in self._locks:
    #                 return False

    #             # Remove locks held by this transaction
    locks = self._locks[resource_id]
    locks_held = [
    #                 lock for lock in locks if lock.transaction_id == transaction_id
    #             ]

    #             if not locks_held:
    #                 return False

    #             # Remove locks
    #             for lock in locks_held:
                    locks.remove(lock)

    #             # Remove empty lock list
    #             if not locks:
    #                 del self._locks[resource_id]

    #             # Notify waiting transactions
                self._notify_waiting_transactions(resource_id)

    #             # Remove wait edges from deadlock detector
                self.deadlock_detector.clear_transaction(transaction_id)

                logger.debug(
    #                 f"Released locks on {resource_id} for transaction {transaction_id}"
    #             )
    #             return True

    #     def _is_compatible(
    #         self, existing_lock_type: LockType, requested_lock_type: LockType
    #     ) -bool):
    #         """Check if two lock types are compatible."""
    #         # Shared locks are compatible with other shared locks
    #         if (
    existing_lock_type == LockType.SHARED
    and requested_lock_type == LockType.SHARED
    #         ):
    #             return True

    #         # Exclusive locks are not compatible with any other locks
    #         if requested_lock_type == LockType.EXCLUSIVE:
    #             return False

    #         # Intention locks are compatible with shared locks
    #         if existing_lock_type in [
    #             LockType.INTENTION_SHARED,
    #             LockType.SHARED_INTENTION_EXCLUSIVE,
    #         ]:
    #             return requested_lock_type in [LockType.SHARED, LockType.INTENTION_SHARED]

    #         return False

    #     def _upgrade_lock(
    #         self, transaction_id: str, resource_id: str, new_lock_type: LockType
    #     ) -bool):
    #         """Upgrade a lock to a more restrictive type."""
    #         with self._lock:
    #             if resource_id not in self._locks:
    #                 return False

    locks = self._locks[resource_id]
    transaction_locks = [
    #                 lock for lock in locks if lock.transaction_id == transaction_id
    #             ]

    #             if not transaction_locks:
    #                 return False

    #             # Check if upgrade is possible
    #             for lock in transaction_locks:
    #                 if not self._is_compatible(lock.lock_type, new_lock_type):
    #                     return False

    #             # Upgrade locks
    #             for lock in transaction_locks:
    lock.lock_type = new_lock_type

                logger.debug(
    #                 f"Upgraded locks on {resource_id} to {new_lock_type.value} for transaction {transaction_id}"
    #             )
    #             return True

    #     def _wait_for_lock(
    #         self, transaction_id: str, resource_id: str, timeout: float
    #     ) -bool):
    #         """Wait for a lock to become available."""
    start_time = time.time()

    #         while time.time() - start_time < timeout:
    #             with self._lock:
    #                 # Check if lock is now available
    existing_locks = self._locks.get(resource_id, [])
    conflicting_locks = [
    #                     lock
    #                     for lock in existing_locks
    #                     if not self._is_compatible(
    #                         lock.lock_type, self._lock_requests[resource_id][0].lock_type
    #                     )
    #                 ]

    #                 if not conflicting_locks:
    #                     # Lock is available, acquire it
    request = self._lock_requests[resource_id].pop(0)
    lock = Lock(
    resource_id = resource_id,
    lock_type = request.lock_type,
    transaction_id = transaction_id,
    granted_at = datetime.now(),
    timeout = request.timeout,
    #                     )

                        existing_locks.append(lock)

    #                     # Notify next waiting transaction
                        self._notify_waiting_transactions(resource_id)

                        logger.debug(
    #                         f"Acquired {request.lock_type.value} lock on {resource_id} for transaction {transaction_id}"
    #                     )
    #                     return True

    #                 # Check for deadlocks
    #                 if self.deadlock_detector._lock_graph:
    cycles = self.deadlock_detector._find_cycles(
    #                         self.deadlock_detector._lock_graph
    #                     )
    #                     if cycles:
    #                         # Deadlock detected, abort this transaction
                            logger.error(
    #                             f"Deadlock detected for transaction {transaction_id}"
    #                         )
    #                         return False

                time.sleep(0.1)  # Small delay before checking again

    #         # Timeout reached
            logger.warning(
    #             f"Lock timeout for transaction {transaction_id} on resource {resource_id}"
    #         )
    #         return False

    #     def _notify_waiting_transactions(self, resource_id: str):
    #         """Notify waiting transactions that a lock is available."""
    #         if resource_id not in self._lock_requests:
    #             return

    #         # Check if any waiting transactions can now acquire the lock
    #         while self._lock_requests[resource_id]:
    request = self._lock_requests[resource_id][0]

    existing_locks = self._locks.get(resource_id, [])
    conflicting_locks = [
    #                 lock
    #                 for lock in existing_locks
    #                 if not self._is_compatible(lock.lock_type, request.lock_type)
    #             ]

    #             if not conflicting_locks:
    #                 # Transaction can acquire lock
    request = self._lock_requests[resource_id].pop(0)
    lock = Lock(
    resource_id = resource_id,
    lock_type = request.lock_type,
    transaction_id = request.transaction_id,
    granted_at = datetime.now(),
    timeout = request.timeout,
    #                 )

                    existing_locks.append(lock)

                    logger.debug(
    #                     f"Notified transaction {request.transaction_id} about available lock on {resource_id}"
    #                 )
    #             else:
    #                 break

    #     def get_locks(self, transaction_id: str) -List[Lock]):
    #         """Get all locks held by a transaction."""
    #         with self._lock:
    locks = []
    #             for resource_locks in self._locks.values():
    #                 for lock in resource_locks:
    #                     if lock.transaction_id == transaction_id:
                            locks.append(lock)
    #             return locks

    #     def get_lock_conflicts(self, transaction_id: str) -List[Lock]):
    #         """Get locks that conflict with a transaction's requested locks."""
    #         with self._lock:
    conflicts = []
    #             for resource_locks in self._locks.values():
    #                 for lock in resource_locks:
    #                     if lock.transaction_id != transaction_id:
                            conflicts.append(lock)
    #             return conflicts

    #     def cleanup_expired_locks(self):
    #         """Clean up expired locks."""
    #         with self._lock:
    #             for resource_id, locks in list(self._locks.items()):
    #                 expired_locks = [lock for lock in locks if lock.is_expired()]
    #                 for lock in expired_locks:
                        locks.remove(lock)
                        logger.warning(f"Expired lock removed: {lock}")

    #                 if not locks:
    #                     del self._locks[resource_id]


class TransactionManager
    #     """Advanced transaction manager with savepoints and deadlock detection."""

    #     def __init__(
    #         self,
    #         connection_pool: DatabaseConnection,
    isolation_level: IsolationLevel = IsolationLevel.READ_COMMITTED,
    #     ):""
    #         Initialize transaction manager.

    #         Args:
    #             connection_pool: Database connection pool
    #             isolation_level: Default isolation level
    #         """
    self.connection_pool = connection_pool
    self.isolation_level = isolation_level
    self._transactions: Dict[str, "Transaction"] = {}
    self._lock = threading.Lock()
    self.lock_manager = LockManager()
    self.deadlock_detector = DeadlockDetector()

    #         # Start deadlock detection
            self.deadlock_detector.start()
    self.lock_manager.deadlock_detector = self.deadlock_detector

            logger.info(
    #             f"Initialized transaction manager with isolation level: {isolation_level.value}"
    #         )

    #     def begin_transaction(
    self, isolation_level: Optional[IsolationLevel] = None
    #     ) -str):
    #         """
    #         Begin a new transaction.

    #         Args:
    #             isolation_level: Transaction isolation level

    #         Returns:
    #             Transaction ID
    #         """
    transaction_id = str(uuid.uuid4())
    isolation_level = isolation_level or self.isolation_level

    #         with self._lock:
    #             if transaction_id in self._transactions:
                    raise ValueError(f"Transaction {transaction_id} already exists")

    transaction = Transaction(
    transaction_id = transaction_id,
    isolation_level = isolation_level,
    connection_pool = self.connection_pool,
    lock_manager = self.lock_manager,
    deadlock_detector = self.deadlock_detector,
    #             )

    self._transactions[transaction_id] = transaction
                transaction.begin()

                logger.info(
    #                 f"Started transaction {transaction_id} with isolation level {isolation_level.value}"
    #             )
    #             return transaction_id

    #     def commit_transaction(self, transaction_id: str) -bool):
    #         """
    #         Commit a transaction.

    #         Args:
    #             transaction_id: Transaction ID

    #         Returns:
    #             True if transaction was committed, False otherwise
    #         """
    #         with self._lock:
    #             if transaction_id not in self._transactions:
                    raise ValueError(f"Transaction {transaction_id} not found")

    transaction = self._transactions[transaction_id]
    result = transaction.commit()

    #             if result:
    #                 del self._transactions[transaction_id]
                    logger.info(f"Committed transaction {transaction_id}")

    #             return result

    #     def rollback_transaction(self, transaction_id: str) -bool):
    #         """
    #         Rollback a transaction.

    #         Args:
    #             transaction_id: Transaction ID

    #         Returns:
    #             True if transaction was rolled back, False otherwise
    #         """
    #         with self._lock:
    #             if transaction_id not in self._transactions:
                    raise ValueError(f"Transaction {transaction_id} not found")

    transaction = self._transactions[transaction_id]
    result = transaction.rollback()

    #             if result:
    #                 del self._transactions[transaction_id]
                    logger.info(f"Rolled back transaction {transaction_id}")

    #             return result

    #     def create_savepoint(self, transaction_id: str, name: str) -bool):
    #         """
    #         Create a savepoint in a transaction.

    #         Args:
    #             transaction_id: Transaction ID
    #             name: Savepoint name

    #         Returns:
    #             True if savepoint was created, False otherwise
    #         """
    #         with self._lock:
    #             if transaction_id not in self._transactions:
                    raise ValueError(f"Transaction {transaction_id} not found")

    transaction = self._transactions[transaction_id]
                return transaction.create_savepoint(name)

    #     def rollback_to_savepoint(self, transaction_id: str, name: str) -bool):
    #         """
    #         Rollback to a savepoint.

    #         Args:
    #             transaction_id: Transaction ID
    #             name: Savepoint name

    #         Returns:
    #             True if rollback was successful, False otherwise
    #         """
    #         with self._lock:
    #             if transaction_id not in self._transactions:
                    raise ValueError(f"Transaction {transaction_id} not found")

    transaction = self._transactions[transaction_id]
                return transaction.rollback_to_savepoint(name)

    #     def release_savepoint(self, transaction_id: str, name: str) -bool):
    #         """
    #         Release a savepoint.

    #         Args:
    #             transaction_id: Transaction ID
    #             name: Savepoint name

    #         Returns:
    #             True if savepoint was released, False otherwise
    #         """
    #         with self._lock:
    #             if transaction_id not in self._transactions:
                    raise ValueError(f"Transaction {transaction_id} not found")

    transaction = self._transactions[transaction_id]
                return transaction.release_savepoint(name)

    #     def get_transaction(self, transaction_id: str) -Optional["Transaction"]):
    #         """Get a transaction by ID."""
    #         with self._lock:
                return self._transactions.get(transaction_id)

    #     def get_active_transactions(self) -List["Transaction"]):
    #         """Get all active transactions."""
    #         with self._lock:
                return list(self._transactions.values())

    #     def get_transaction_stats(self) -Dict[str, Any]):
    #         """Get transaction statistics."""
    #         with self._lock:
    stats = {
                    "total_transactions": len(self._transactions),
    #                 "isolation_level": self.isolation_level.value,
                    "lock_manager_stats": self.lock_manager.get_locks_stats(),
                    "deadlock_detector_stats": self.deadlock_detector.get_stats(),
    #             }

    #             # Add transaction metrics
    #             for transaction in self._transactions.values():
                    stats.setdefault("transactions", []).append(
                        transaction.get_metrics().to_dict()
    #                 )

    #             return stats

    #     def cleanup_expired_transactions(self):
    #         """Clean up expired transactions."""
    #         with self._lock:
    current_time = datetime.now()
    expired_transactions = []

    #             for transaction_id, transaction in self._transactions.items():
    #                 if transaction.is_expired():
                        expired_transactions.append(transaction_id)

    #             for transaction_id in expired_transactions:
    #                 try:
                        self.rollback_transaction(transaction_id)
                        logger.warning(f"Cleaned up expired transaction {transaction_id}")
    #                 except Exception as e:
                        logger.error(
    #                         f"Failed to cleanup expired transaction {transaction_id}: {e}"
    #                     )

    #     def shutdown(self):
    #         """Shutdown transaction manager."""
    #         # Rollback all active transactions
    #         with self._lock:
    #             for transaction_id in list(self._transactions.keys()):
    #                 try:
                        self.rollback_transaction(transaction_id)
    #                 except Exception as e:
                        logger.error(
    #                         f"Failed to rollback transaction {transaction_id}: {e}"
    #                     )

    #         # Stop deadlock detector
            self.deadlock_detector.stop()

            logger.info("Transaction manager shutdown complete")


class Transaction
    #     """Individual transaction with savepoint support."""

    #     def __init__(
    #         self,
    #         transaction_id: str,
    #         isolation_level: IsolationLevel,
    #         connection_pool: DatabaseConnection,
    #         lock_manager: LockManager,
    #         deadlock_detector: DeadlockDetector,
    #     ):""
    #         Initialize transaction.

    #         Args:
    #             transaction_id: Transaction ID
    #             isolation_level: Transaction isolation level
    #             connection_pool: Database connection pool
    #             lock_manager: Lock manager
    #             deadlock_detector: Deadlock detector
    #         """
    self.transaction_id = transaction_id
    self.isolation_level = isolation_level
    self.connection_pool = connection_pool
    self.lock_manager = lock_manager
    self.deadlock_detector = deadlock_detector

    self.connection: Optional[Any] = None
    self.status = TransactionStatus.ACTIVE
    self.savepoints: Dict[str, Savepoint] = {}
    self.metrics = TransactionMetrics(
    transaction_id = transaction_id,
    started_at = datetime.now(),
    isolation_level = isolation_level,
    #         )
    self._lock = threading.Lock()
    self._timeout = 300.0  # 5 minutes default timeout

    #     def begin(self):
    #         """Begin the transaction."""
    self.connection = self.connection_pool.get_connection()
            self.connection.begin_transaction()
            logger.debug(f"Transaction {self.transaction_id} started")

    #     def commit(self) -bool):
    #         """Commit the transaction."""
    #         with self._lock:
    #             if self.status != TransactionStatus.ACTIVE:
    #                 return False

    #             try:
                    self.connection.commit_transaction()
    self.status = TransactionStatus.COMMITTED
    self.metrics.committed_at = datetime.now()
    self.metrics.execution_time = (
    #                     self.metrics.committed_at - self.metrics.started_at
                    ).total_seconds()

    #                 # Release all locks
                    self._release_all_locks()

                    logger.info(f"Transaction {self.transaction_id} committed")
    #                 return True
    #             except Exception as e:
                    logger.error(f"Failed to commit transaction {self.transaction_id}: {e}")
    self.status = TransactionStatus.FAILED
    #                 return False
    #             finally:
    #                 if self.connection:
                        self.connection_pool.release_connection(self.connection)

    #     def rollback(self) -bool):
    #         """Rollback the transaction."""
    #         with self._lock:
    #             if self.status not in [TransactionStatus.ACTIVE, TransactionStatus.FAILED]:
    #                 return False

    #             try:
                    self.connection.rollback_transaction()
    self.status = TransactionStatus.ROLLED_BACK
    self.metrics.rolled_back_at = datetime.now()
    self.metrics.execution_time = (
    #                     self.metrics.rolled_back_at - self.metrics.started_at
                    ).total_seconds()
    self.metrics.rollback_count + = 1

    #                 # Release all locks
                    self._release_all_locks()

                    logger.info(f"Transaction {self.transaction_id} rolled back")
    #                 return True
    #             except Exception as e:
                    logger.error(
    #                     f"Failed to rollback transaction {self.transaction_id}: {e}"
    #                 )
    self.status = TransactionStatus.FAILED
    #                 return False
    #             finally:
    #                 if self.connection:
                        self.connection_pool.release_connection(self.connection)

    #     def create_savepoint(self, name: str) -bool):
    #         """
    #         Create a savepoint.

    #         Args:
    #             name: Savepoint name

    #         Returns:
    #             True if savepoint was created, False otherwise
    #         """
    #         with self._lock:
    #             if self.status != TransactionStatus.ACTIVE:
    #                 return False

    #             if name in self.savepoints:
                    raise ValueError(f"Savepoint {name} already exists")

    savepoint = Savepoint(
    name = name, transaction_id=self.transaction_id, created_at=datetime.now()
    #             )

    self.savepoints[name] = savepoint
    self.metrics.savepoint_count + = 1

                logger.debug(
    #                 f"Created savepoint {name} in transaction {self.transaction_id}"
    #             )
    #             return True

    #     def rollback_to_savepoint(self, name: str) -bool):
    #         """
    #         Rollback to a savepoint.

    #         Args:
    #             name: Savepoint name

    #         Returns:
    #             True if rollback was successful, False otherwise
    #         """
    #         with self._lock:
    #             if self.status != TransactionStatus.ACTIVE:
    #                 return False

    #             if name not in self.savepoints:
                    raise ValueError(f"Savepoint {name} not found")

    #             try:
    #                 # Rollback database to savepoint
                    self.connection.rollback_transaction()
                    self.connection.begin_transaction()

    #                 # Remove savepoints after the specified one
    savepoint_names = list(self.savepoints.keys())
    savepoint_index = savepoint_names.index(name)

    #                 for sp_name in savepoint_names[savepoint_index + 1 :]:
    #                     del self.savepoints[sp_name]

    self.metrics.rollback_count + = 1

                    logger.debug(
    #                     f"Rolled back to savepoint {name} in transaction {self.transaction_id}"
    #                 )
    #                 return True
    #             except Exception as e:
                    logger.error(f"Failed to rollback to savepoint {name}: {e}")
    #                 return False

    #     def release_savepoint(self, name: str) -bool):
    #         """
    #         Release a savepoint.

    #         Args:
    #             name: Savepoint name

    #         Returns:
    #             True if savepoint was released, False otherwise
    #         """
    #         with self._lock:
    #             if self.status != TransactionStatus.ACTIVE:
    #                 return False

    #             if name not in self.savepoints:
    #                 return False

    #             del self.savepoints[name]

                logger.debug(
    #                 f"Released savepoint {name} in transaction {self.transaction_id}"
    #             )
    #             return True

    #     def acquire_lock(
    self, resource_id: str, lock_type: LockType, timeout: float = 30.0
    #     ) -bool):
    #         """
    #         Acquire a lock on a resource.

    #         Args:
    #             resource_id: Resource to lock
    #             lock_type: Type of lock to acquire
    #             timeout: Timeout for lock acquisition

    #         Returns:
    #             True if lock was acquired, False otherwise
    #         """
    #         if self.status != TransactionStatus.ACTIVE:
    #             return False

    result = self.lock_manager.acquire_lock(
    #             self.transaction_id, resource_id, lock_type, timeout
    #         )

    #         if result:
    self.metrics.lock_count + = 1

    #         return result

    #     def release_lock(self, resource_id: str) -bool):
    #         """
    #         Release a lock on a resource.

    #         Args:
    #             resource_id: Resource to unlock

    #         Returns:
    #             True if lock was released, False otherwise
    #         """
            return self.lock_manager.release_lock(self.transaction_id, resource_id)

    #     def get_held_locks(self) -List[Lock]):
    #         """Get all locks held by this transaction."""
            return self.lock_manager.get_locks(self.transaction_id)

    #     def get_conflicting_locks(self) -List[Lock]):
    #         """Get locks that conflict with this transaction."""
            return self.lock_manager.get_lock_conflicts(self.transaction_id)

    #     def get_savepoints(self) -List[Savepoint]):
    #         """Get all savepoints in this transaction."""
            return list(self.savepoints.values())

    #     def get_metrics(self) -TransactionMetrics):
    #         """Get transaction metrics."""
    #         # Update execution time if transaction is still active
    #         if self.status == TransactionStatus.ACTIVE:
    self.metrics.execution_time = (
                    datetime.now() - self.metrics.started_at
                ).total_seconds()

    #         return self.metrics

    #     def is_expired(self) -bool):
    #         """Check if transaction has expired."""
    #         if self.status != TransactionStatus.ACTIVE:
    #             return False

            return (
                datetime.now() - self.metrics.started_at
            ).total_seconds() self._timeout

    #     def _release_all_locks(self)):
    #         """Release all locks held by this transaction."""
    locks = self.lock_manager.get_locks(self.transaction_id)
    #         for lock in locks:
                self.lock_manager.release_lock(self.transaction_id, lock.resource_id)

    #     def __str__(self) -str):
    #         """String representation."""
    return f"Transaction(id = {self.transaction_id}, status={self.status.value})"


# Context managers


# @contextmanager
def transaction_manager(
manager: TransactionManager, isolation_level: Optional[IsolationLevel] = None
# ):
#     """Context manager for transaction manager."""
#     try:
#         yield manager
#     except Exception as e:
        logger.error(f"Transaction manager error: {e}")
#         raise


# @contextmanager
def transaction(
manager: TransactionManager, isolation_level: Optional[IsolationLevel] = None
# ):
#     """Context manager for transactions."""
transaction_id = None
#     try:
transaction_id = manager.begin_transaction(isolation_level)
#         yield transaction_id
        manager.commit_transaction(transaction_id)
#     except Exception as e:
        logger.error(f"Transaction error: {e}")
#         if transaction_id:
            manager.rollback_transaction(transaction_id)
#         raise


# @contextmanager
function savepoint(manager: TransactionManager, transaction_id: str, name: str)
    #     """Context manager for savepoints."""
    #     try:
            manager.create_savepoint(transaction_id, name)
    #         yield
    #     except Exception as e:
            logger.error(f"Savepoint error: {e}")
            manager.rollback_to_savepoint(transaction_id, name)
    #         raise
