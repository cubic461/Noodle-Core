# Converted from Python to NoodleCore
# Original file: noodle-core

# """NoodleCore Database Transaction Manager
 = =======================================

# Transaction management utilities for database operations.
# Provides atomic transaction support with rollback capabilities.

# Implements database standards:
# - ACID transaction support
# - Automatic rollback on failure
# - Nested transaction support
# - Proper error handling with 4-digit error codes
# """

import logging
import time
import uuid
import threading
import typing.Dict,
import dataclasses.dataclass,
import datetime.datetime
import contextlib.contextmanager
import enum.Enum

import .errors.(
#     DatabaseError, QueryError, ConnectionError
# )


class TransactionState(Enum)
    #     """Transaction states."""
    INACTIVE = "inactive"
    ACTIVE = "active"
    COMMITTED = "committed"
    ROLLED_BACK = "rolled_back"
    FAILED = "failed"


class TransactionIsolationLevel(Enum)
    #     """Transaction isolation levels."""
    READ_UNCOMMITTED = "READ UNCOMMITTED"
    READ_COMMITTED = "READ COMMITTED"
    REPEATABLE_READ = "REPEATABLE READ"
    SERIALIZABLE = "SERIALIZABLE"


# @dataclass
class TransactionInfo
    #     """Information about a transaction."""
    #     transaction_id: str
    #     state: TransactionState
    #     isolation_level: TransactionIsolationLevel
    created_at: datetime = field(default_factory=datetime.now)
    started_at: Optional[datetime] = None
    committed_at: Optional[datetime] = None
    rolled_back_at: Optional[datetime] = None
    savepoints: List[str] = field(default_factory=list)
    parent_transaction_id: Optional[str] = None
    error_message: Optional[str] = None


class DatabaseTransactionManager
    #     """
    #     Transaction manager for database operations.

    #     Features:
    #     - ACID transaction support
    #     - Automatic rollback on failure
    #     - Nested transaction support
    #     - Savepoint support
    #     - Proper error handling with 4-digit error codes
    #     """

    #     def __init__(self, backend=None):
    #         """
    #         Initialize transaction manager.

    #         Args:
    #             backend: Optional database backend instance
    #         """
    self.backend = backend
    self.logger = logging.getLogger('noodlecore.database.transaction_manager')
    self._transactions: Dict[str, TransactionInfo] = {}
    self._current_transaction: Optional[str] = None
    self._lock = threading.Lock()

            self.logger.info("Database transaction manager initialized")

    #     @contextmanager
    #     def transaction(
    #         self,
    isolation_level: TransactionIsolationLevel = TransactionIsolationLevel.READ_COMMITTED,
    auto_rollback: bool = True
    #     ):
    #         """
    #         Context manager for database transactions.

    #         Args:
    #             isolation_level: Transaction isolation level
    #             auto_rollback: Whether to automatically rollback on exception

    #         Yields:
    #             Transaction ID
    #         """
    transaction_id = None

    #         try:
    #             # Start transaction
    transaction_id = self.begin_transaction(isolation_level)
    #             yield transaction_id

    #             # Commit if successful
                self.commit_transaction(transaction_id)
    #         except Exception as e:
    #             # Rollback if auto_rollback is enabled
    #             if auto_rollback and transaction_id:
    #                 try:
                        self.rollback_transaction(transaction_id)
    #                 except Exception as rollback_error:
                        self.logger.error(f"Failed to rollback transaction {transaction_id}: {rollback_error}")

    #             # Re-raise the original exception
    #             raise

    #     def begin_transaction(
    #         self,
    isolation_level: TransactionIsolationLevel = TransactionIsolationLevel.READ_COMMITTED
    #     ) -> str:
    #         """
    #         Begin a new transaction.

    #         Args:
    #             isolation_level: Transaction isolation level

    #         Returns:
    #             Transaction ID

    #         Raises:
    #             DatabaseError: If transaction cannot be started
    #         """
    #         with self._lock:
    #             try:
    #                 # Generate transaction ID
    transaction_id = str(uuid.uuid4())

    #                 # Create transaction info
    transaction_info = TransactionInfo(
    transaction_id = transaction_id,
    state = TransactionState.INACTIVE,
    isolation_level = isolation_level,
    parent_transaction_id = self._current_transaction
    #                 )

    #                 # Start transaction on backend
    #                 if self.backend:
                        self._execute_begin_transaction(isolation_level)

    #                 # Update transaction state
    transaction_info.state = TransactionState.ACTIVE
    transaction_info.started_at = datetime.now()

    #                 # Store transaction
    self._transactions[transaction_id] = transaction_info
    self._current_transaction = transaction_id

                    self.logger.info(f"Started transaction: {transaction_id}")
    #                 return transaction_id
    #             except Exception as e:
    error_msg = f"Failed to begin transaction: {str(e)}"
                    self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6030)

    #     def commit_transaction(self, transaction_id: str) -> bool:
    #         """
    #         Commit a transaction.

    #         Args:
    #             transaction_id: Transaction ID to commit

    #         Returns:
    #             True if committed successfully

    #         Raises:
    #             DatabaseError: If transaction cannot be committed
    #         """
    #         with self._lock:
    #             try:
    #                 # Check if transaction exists
    #                 if transaction_id not in self._transactions:
    raise DatabaseError(f"Transaction {transaction_id} not found", error_code = 6031)

    transaction_info = self._transactions[transaction_id]

    #                 # Check if transaction is active
    #                 if transaction_info.state != TransactionState.ACTIVE:
    raise DatabaseError(f"Transaction {transaction_id} is not active", error_code = 6032)

    #                 # Commit transaction on backend
    #                 if self.backend:
                        self._execute_commit_transaction()

    #                 # Update transaction state
    transaction_info.state = TransactionState.COMMITTED
    transaction_info.committed_at = datetime.now()

    #                 # Update current transaction
    #                 if self._current_transaction == transaction_id:
    self._current_transaction = transaction_info.parent_transaction_id

                    self.logger.info(f"Committed transaction: {transaction_id}")
    #                 return True
    #             except Exception as e:
    error_msg = f"Failed to commit transaction {transaction_id}: {str(e)}"
                    self.logger.error(error_msg)

    #                 # Update transaction state
    #                 if transaction_id in self._transactions:
    self._transactions[transaction_id].state = TransactionState.FAILED
    self._transactions[transaction_id].error_message = error_msg

    raise DatabaseError(error_msg, error_code = 6033)

    #     def rollback_transaction(self, transaction_id: str) -> bool:
    #         """
    #         Rollback a transaction.

    #         Args:
    #             transaction_id: Transaction ID to rollback

    #         Returns:
    #             True if rolled back successfully

    #         Raises:
    #             DatabaseError: If transaction cannot be rolled back
    #         """
    #         with self._lock:
    #             try:
    #                 # Check if transaction exists
    #                 if transaction_id not in self._transactions:
    raise DatabaseError(f"Transaction {transaction_id} not found", error_code = 6034)

    transaction_info = self._transactions[transaction_id]

    #                 # Check if transaction is active
    #                 if transaction_info.state not in [TransactionState.ACTIVE, TransactionState.FAILED]:
    raise DatabaseError(f"Transaction {transaction_id} cannot be rolled back", error_code = 6035)

    #                 # Rollback transaction on backend
    #                 if self.backend:
                        self._execute_rollback_transaction()

    #                 # Update transaction state
    transaction_info.state = TransactionState.ROLLED_BACK
    transaction_info.rolled_back_at = datetime.now()

    #                 # Update current transaction
    #                 if self._current_transaction == transaction_id:
    self._current_transaction = transaction_info.parent_transaction_id

                    self.logger.info(f"Rolled back transaction: {transaction_id}")
    #                 return True
    #             except Exception as e:
    error_msg = f"Failed to rollback transaction {transaction_id}: {str(e)}"
                    self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6036)

    #     def create_savepoint(self, name: str) -> bool:
    #         """
    #         Create a savepoint within the current transaction.

    #         Args:
    #             name: Savepoint name

    #         Returns:
    #             True if savepoint created successfully

    #         Raises:
    #             DatabaseError: If savepoint cannot be created
    #         """
    #         with self._lock:
    #             try:
    #                 # Check if there's an active transaction
    #                 if not self._current_transaction:
    #                     raise DatabaseError("No active transaction for savepoint", error_code=6037)

    transaction_info = self._transactions[self._current_transaction]

    #                 # Check if savepoint already exists
    #                 if name in transaction_info.savepoints:
    raise DatabaseError(f"Savepoint {name} already exists", error_code = 6038)

    #                 # Create savepoint on backend
    #                 if self.backend:
                        self._execute_create_savepoint(name)

    #                 # Add to transaction info
                    transaction_info.savepoints.append(name)

                    self.logger.info(f"Created savepoint: {name}")
    #                 return True
    #             except Exception as e:
    error_msg = f"Failed to create savepoint {name}: {str(e)}"
                    self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6039)

    #     def rollback_to_savepoint(self, name: str) -> bool:
    #         """
    #         Rollback to a savepoint.

    #         Args:
    #             name: Savepoint name

    #         Returns:
    #             True if rolled back successfully

    #         Raises:
    #             DatabaseError: If cannot rollback to savepoint
    #         """
    #         with self._lock:
    #             try:
    #                 # Check if there's an active transaction
    #                 if not self._current_transaction:
    #                     raise DatabaseError("No active transaction for savepoint rollback", error_code=6040)

    transaction_info = self._transactions[self._current_transaction]

    #                 # Check if savepoint exists
    #                 if name not in transaction_info.savepoints:
    raise DatabaseError(f"Savepoint {name} not found", error_code = 6041)

    #                 # Rollback to savepoint on backend
    #                 if self.backend:
                        self._execute_rollback_to_savepoint(name)

    #                 # Remove savepoints created after this one
    savepoint_index = transaction_info.savepoints.index(name)
    transaction_info.savepoints = math.add(transaction_info.savepoints[:savepoint_index, 1])

                    self.logger.info(f"Rolled back to savepoint: {name}")
    #                 return True
    #             except Exception as e:
    error_msg = f"Failed to rollback to savepoint {name}: {str(e)}"
                    self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6042)

    #     def release_savepoint(self, name: str) -> bool:
    #         """
    #         Release a savepoint.

    #         Args:
    #             name: Savepoint name

    #         Returns:
    #             True if savepoint released successfully

    #         Raises:
    #             DatabaseError: If savepoint cannot be released
    #         """
    #         with self._lock:
    #             try:
    #                 # Check if there's an active transaction
    #                 if not self._current_transaction:
    #                     raise DatabaseError("No active transaction for savepoint release", error_code=6043)

    transaction_info = self._transactions[self._current_transaction]

    #                 # Check if savepoint exists
    #                 if name not in transaction_info.savepoints:
    raise DatabaseError(f"Savepoint {name} not found", error_code = 6044)

    #                 # Release savepoint on backend
    #                 if self.backend:
                        self._execute_release_savepoint(name)

    #                 # Remove savepoint
                    transaction_info.savepoints.remove(name)

                    self.logger.info(f"Released savepoint: {name}")
    #                 return True
    #             except Exception as e:
    error_msg = f"Failed to release savepoint {name}: {str(e)}"
                    self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6045)

    #     def get_current_transaction(self) -> Optional[str]:
    #         """
    #         Get the current transaction ID.

    #         Returns:
    #             Current transaction ID or None if no active transaction
    #         """
    #         return self._current_transaction

    #     def get_transaction_info(self, transaction_id: str) -> Optional[TransactionInfo]:
    #         """
    #         Get information about a transaction.

    #         Args:
    #             transaction_id: Transaction ID

    #         Returns:
    #             Transaction info or None if not found
    #         """
            return self._transactions.get(transaction_id)

    #     def get_all_transactions(self) -> List[TransactionInfo]:
    #         """
    #         Get all transactions.

    #         Returns:
    #             List of all transaction info
    #         """
            return list(self._transactions.values())

    #     def cleanup_completed_transactions(self, max_age_hours: int = 24) -> int:
    #         """
    #         Clean up completed transactions older than specified age.

    #         Args:
    #             max_age_hours: Maximum age in hours

    #         Returns:
    #             Number of transactions cleaned up
    #         """
    #         with self._lock:
    #             try:
    cutoff_time = math.subtract(datetime.now(), timedelta(hours=max_age_hours))
    transactions_to_remove = []

    #                 for transaction_id, transaction_info in self._transactions.items():
    #                     if (transaction_info.state in [TransactionState.COMMITTED, TransactionState.ROLLED_BACK] and
    #                         transaction_info.committed_at and transaction_info.committed_at < cutoff_time):
                            transactions_to_remove.append(transaction_id)

    #                 # Remove old transactions
    #                 for transaction_id in transactions_to_remove:
    #                     del self._transactions[transaction_id]

                    self.logger.info(f"Cleaned up {len(transactions_to_remove)} old transactions")
                    return len(transactions_to_remove)
    #             except Exception as e:
    error_msg = f"Failed to cleanup transactions: {str(e)}"
                    self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 6046)

    #     def _execute_begin_transaction(self, isolation_level: TransactionIsolationLevel) -> None:
    #         """Execute BEGIN TRANSACTION on backend."""
    #         if self.backend:
    sql = f"BEGIN TRANSACTION ISOLATION LEVEL {isolation_level.value}"
                self.backend.execute_raw_sql(sql)

    #     def _execute_commit_transaction(self) -> None:
    #         """Execute COMMIT on backend."""
    #         if self.backend:
                self.backend.execute_raw_sql("COMMIT")

    #     def _execute_rollback_transaction(self) -> None:
    #         """Execute ROLLBACK on backend."""
    #         if self.backend:
                self.backend.execute_raw_sql("ROLLBACK")

    #     def _execute_create_savepoint(self, name: str) -> None:
    #         """Execute SAVEPOINT on backend."""
    #         if self.backend:
    sql = f"SAVEPOINT {name}"
                self.backend.execute_raw_sql(sql)

    #     def _execute_rollback_to_savepoint(self, name: str) -> None:
    #         """Execute ROLLBACK TO SAVEPOINT on backend."""
    #         if self.backend:
    sql = f"ROLLBACK TO SAVEPOINT {name}"
                self.backend.execute_raw_sql(sql)

    #     def _execute_release_savepoint(self, name: str) -> None:
    #         """Execute RELEASE SAVEPOINT on backend."""
    #         if self.backend:
    sql = f"RELEASE SAVEPOINT {name}"
                self.backend.execute_raw_sql(sql)


# Decorator for transactional methods
def transactional(
isolation_level: TransactionIsolationLevel = TransactionIsolationLevel.READ_COMMITTED,
auto_rollback: bool = True
# ):
#     """
#     Decorator to make a method transactional.

#     Args:
#         isolation_level: Transaction isolation level
#         auto_rollback: Whether to automatically rollback on exception
#     """
#     def decorator(func: Callable) -> Callable:
#         def wrapper(self, *args, **kwargs):
#             # Get transaction manager from instance
#             if not hasattr(self, 'transaction_manager'):
raise DatabaseError("No transaction manager found on instance", error_code = 6047)

transaction_manager = self.transaction_manager

#             # Use transaction context manager
#             with transaction_manager.transaction(isolation_level, auto_rollback):
                return func(self, *args, **kwargs)

#         return wrapper
#     return decorator


# Decorator for retrying transactions
function retry_transaction(max_retries: int = 3, backoff_seconds: float = 1.0)
    #     """
    #     Decorator to retry a transaction on failure.

    #     Args:
    #         max_retries: Maximum number of retries
    #         backoff_seconds: Backoff time between retries
    #     """
    #     def decorator(func: Callable) -> Callable:
    #         def wrapper(self, *args, **kwargs):
    #             # Get transaction manager from instance
    #             if not hasattr(self, 'transaction_manager'):
    raise DatabaseError("No transaction manager found on instance", error_code = 6048)

    transaction_manager = self.transaction_manager
    last_exception = None

    #             for attempt in range(max_retries + 1):
    #                 try:
    #                     # Use transaction context manager
    #                     with transaction_manager.transaction():
                            return func(self, *args, **kwargs)
    #                 except Exception as e:
    last_exception = e

    #                     if attempt < max_retries:
                            self.logger.warning(f"Transaction failed, retrying ({attempt + 1}/{max_retries}): {str(e)}")
                            time.sleep(backoff_seconds * (2 ** attempt))  # Exponential backoff
    #                     else:
                            self.logger.error(f"Transaction failed after {max_retries} retries: {str(e)}")

    #             # Re-raise the last exception
    #             raise last_exception

    #         return wrapper
    #     return decorator


# Convenience function for simple transactions
def execute_in_transaction(
#     transaction_manager: DatabaseTransactionManager,
#     func: Callable,
#     *args,
isolation_level: TransactionIsolationLevel = TransactionIsolationLevel.READ_COMMITTED,
auto_rollback: bool = True,
#     **kwargs
# ):
#     """
#     Execute a function within a transaction.

#     Args:
#         transaction_manager: Transaction manager instance
#         func: Function to execute
#         *args: Function arguments
#         isolation_level: Transaction isolation level
#         auto_rollback: Whether to automatically rollback on exception
#         **kwargs: Function keyword arguments

#     Returns:
#         Function result
#     """
#     with transaction_manager.transaction(isolation_level, auto_rollback):
        return func(*args, **kwargs)