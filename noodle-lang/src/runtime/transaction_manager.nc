# Converted from Python to NoodleCore
# Original file: src

# """
# Database Transaction Manager
# ----------------------------
# Manages database transactions with proper isolation levels.
# """

import logging
import threading
import time
import uuid
import contextlib.contextmanager
from dataclasses import dataclass
import enum.Enum
import typing.Any

import noodlecore.database.backends.memory.MemoryBackend
import noodlecore.database.connection_manager.ConnectionInfo
import noodlecore.database.errors.BackendError


class IsolationLevel(Enum)
    #     """Database transaction isolation levels."""

    READ_UNCOMMITTED = "READ_UNCOMMITTED"
    READ_COMMITTED = "READ_COMMITTED"
    REPEATABLE_READ = "REPEATABLE_READ"
    SERIALIZABLE = "SERIALIZABLE"


class TransactionManagerError(Exception)
    #     """Base exception for transaction manager errors."""

    #     pass


dataclass
class TransactionConfig
    #     """Configuration for database transactions."""

    isolation_level: str = "READ_COMMITTED"
    timeout: float = 30.0
    auto_commit: bool = False
    auto_rollback: bool = True
    readonly: bool = False

    #     def validate(self) -bool):
    #         """Validate the transaction configuration.

    #         Returns:
    #             True if configuration is valid, False otherwise
    #         """
    valid_isolation_levels = [
    #             "READ_UNCOMMITTED",
    #             "READ_COMMITTED",
    #             "REPEATABLE_READ",
    #             "SERIALIZABLE",
    #         ]

    #         if self.isolation_level not in valid_isolation_levels:
    #             return False

    #         if self.timeout <= 0:
    #             return False

    #         return True


class DatabaseTransaction
    #     """Represents a database transaction."""

    #     def __init__(
    #         self,
    #         transaction_id: str,
    #         connection_info: ConnectionInfo,
    #         config: TransactionConfig,
    #         transaction_manager: "DatabaseTransactionManager",
    #     ):""Initialize the transaction.

    #         Args:
    #             transaction_id: Unique transaction ID
    #             connection_info: Database connection information
    #             config: Transaction configuration
    #             transaction_manager: Transaction manager instance
    #         """
    self.transaction_id = transaction_id
    self.connection_info = connection_info
    self.config = config
    self.transaction_manager = transaction_manager
    self.backend_instance = connection_info.backend_instance
    self.created_at = time.time()
    self.last_used = time.time()
    self.is_active = False
    self.operations: List[Dict[str, Any]] = []
    self.rollback_only = False
    self.logger = logging.getLogger(__name__)

    #     def begin(self) -bool):
    #         """Begin the transaction.

    #         Returns:
    #             True if transaction started successfully, False otherwise
    #         """
    #         try:
    #             # Use the connection-specific backend for all backends
                self.backend_instance.begin_transaction(self.transaction_id)

    self.is_active = True
    self.last_used = time.time()

                self.logger.debug(f"Transaction {self.transaction_id} started")
    #             return True

    #         except Exception as e:
                raise TransactionError(
    #                 f"Failed to begin transaction {self.transaction_id}: {e}"
    #             )

    #     def commit(self) -bool):
    #         """Commit the transaction.

    #         Returns:
    #             True if transaction committed successfully, False otherwise
    #         """
    #         if not self.is_active:
                raise TransactionError(
    #                 f"Cannot commit inactive transaction {self.transaction_id}"
    #             )

    #         try:
    #             # Use the connection-specific backend for all backends
                self.backend_instance.commit_transaction(self.transaction_id)

    self.is_active = False

                self.logger.debug(f"Transaction {self.transaction_id} committed")
    #             return True

    #         except Exception as e:
                raise TransactionError(
    #                 f"Failed to commit transaction {self.transaction_id}: {e}"
    #             )

    #     def rollback(self) -bool):
    #         """Rollback the transaction.

    #         Returns:
    #             True if transaction rolled back successfully, False otherwise
    #         """
    #         if not self.is_active:
                raise TransactionError(
    #                 f"Cannot rollback inactive transaction {self.transaction_id}"
    #             )

    #         try:
    #             # Use the connection-specific backend for all backends
                self.backend_instance.rollback_transaction(self.transaction_id)

    self.is_active = False

                self.logger.debug(f"Transaction {self.transaction_id} rolled back")
    #             return True

    #         except Exception as e:
                raise TransactionError(
    #                 f"Failed to rollback transaction {self.transaction_id}: {e}"
    #             )

    #     def execute(
    self, operation: str, query: str, params: Optional[Dict[str, Any]] = None
    #     ) -List[Dict[str, Any]]):
    #         """Execute an operation within the transaction.

    #         Args:
                operation: Type of operation (select, insert, update, delete)
    #             query: SQL query string
    #             params: Optional parameters for query

    #         Returns:
    #             Query results
    #         """
    #         if not self.is_active:
                raise TransactionError(
    #                 f"Cannot execute operation on inactive transaction {self.transaction_id}"
    #             )

    #         try:
    #             # Use the connection-specific backend for all backends
    result = self.backend_instance.execute_query(
    #                 query, params, {"transaction_id": self.transaction_id}
    #             )

    #             # Record operation
                self.operations.append(
    #                 {
    #                     "operation": operation,
    #                     "query": query,
    #                     "params": params,
                        "timestamp": time.time(),
                        "result_count": len(result),
    #                 }
    #             )

    self.last_used = time.time()
    #             return result

    #         except Exception as e:
    #             # Mark for rollback if operation fails
    self.rollback_only = True
                raise TransactionError(
    #                 f"Failed to execute operation in transaction {self.transaction_id}: {e}"
    #             )

    #     def is_expired(self) -bool):
    #         """Check if transaction has expired.

    #         Returns:
    #             True if transaction has expired, False otherwise
    #         """
            return time.time() - self.last_used self.config.timeout

    #     def get_stats(self):
    """Dict[str, Any])"""
    #         """Get transaction statistics.

    #         Returns:
    #             Transaction statistics
    #         """
    #         return {
    #             "transaction_id": self.transaction_id,
    #             "backend": self.connection_info.backend,
    #             "isolation_level": self.config.isolation_level,
    #             "created_at": self.created_at,
    #             "last_used": self.last_used,
    #             "is_active": self.is_active,
                "operation_count": len(self.operations),
    #             "operations": self.operations,
    #             "rollback_only": self.rollback_only,
    #         }


class DatabaseTransactionManager
    #     """Manages database transactions."""

    #     def __init__(self, connection_manager: DatabaseConnectionManager):""Initialize the transaction manager.

    #         Args:
    #             connection_manager: Database connection manager
    #         """
    self.connection_manager = connection_manager
    self.active_transactions: Dict[str, DatabaseTransaction] = {}
    self.lock = threading.Lock()
    self.logger = logging.getLogger(__name__)

    #     def begin_transaction(
    self, backend: Optional[str] = None, config: Optional[TransactionConfig] = None
    #     ) -str):
    #         """Begin a new transaction.

    #         Args:
                backend: Backend name (optional)
                config: Transaction configuration (optional)

    #         Returns:
    #             Transaction ID
    #         """
    #         # Use default config if not provided
    #         if config is None:
    config = TransactionConfig()

    #         # Validate configuration
    #         if not config.validate():
                raise TransactionError(f"Invalid transaction configuration: {config}")

    #         # Get connection
    connection_id = self.connection_manager.get_connection(backend)
    connection_info = None

    #         # Find connection info
    #         for pool in self.connection_manager.pools.values():
    #             for conn_info in pool.active_connections.values():
    #                 if conn_info.connection_id == connection_id:
    connection_info = conn_info
    #                     break

    #         if connection_info is None:
                raise ConnectionError(f"Connection {connection_id} not found")

    #         # Create transaction
    transaction_id = str(uuid.uuid4())
    transaction = DatabaseTransaction(
    transaction_id = transaction_id,
    connection_info = connection_info,
    config = config,
    transaction_manager = self,
    #         )

    #         # Begin transaction
    #         if not transaction.begin():
                raise TransactionError(f"Failed to begin transaction {transaction_id}")

    #         # Register transaction
    #         with self.lock:
    self.active_transactions[transaction_id] = transaction

            self.logger.info(
    #             f"Started transaction {transaction_id} on backend {connection_info.backend}"
    #         )
    #         return transaction_id

    #     def commit_transaction(self, transaction_id: str) -bool):
    #         """Commit a transaction.

    #         Args:
    #             transaction_id: Transaction ID to commit

    #         Returns:
    #             True if transaction committed successfully, False otherwise
    #         """
    #         with self.lock:
    #             if transaction_id not in self.active_transactions:
                    raise TransactionError(f"Transaction {transaction_id} not found")

    transaction = self.active_transactions[transaction_id]

    #         try:
    #             # Check if transaction is marked for rollback only
    #             if transaction.rollback_only:
                    self.logger.warning(
    #                     f"Transaction {transaction_id} is marked for rollback only"
    #                 )
                    return transaction.rollback()

    #             # Commit transaction
    success = transaction.commit()

    #             # Remove from active transactions
    #             with self.lock:
    #                 if transaction_id in self.active_transactions:
    #                     del self.active_transactions[transaction_id]

    #             # Release connection
                self.connection_manager.release_connection(
    #                 transaction.connection_info.connection_id
    #             )

    #             return success

    #         except Exception as e:
                raise TransactionError(
    #                 f"Failed to commit transaction {transaction_id}: {e}"
    #             )

    #     def rollback_transaction(self, transaction_id: str) -bool):
    #         """Rollback a transaction.

    #         Args:
    #             transaction_id: Transaction ID to rollback

    #         Returns:
    #             True if transaction rolled back successfully, False otherwise
    #         """
    #         with self.lock:
    #             if transaction_id not in self.active_transactions:
                    raise TransactionError(f"Transaction {transaction_id} not found")

    transaction = self.active_transactions[transaction_id]

    #         try:
    #             # Rollback transaction
    success = transaction.rollback()

    #             # Remove from active transactions
    #             with self.lock:
    #                 if transaction_id in self.active_transactions:
    #                     del self.active_transactions[transaction_id]

    #             # Release connection
                self.connection_manager.release_connection(
    #                 transaction.connection_info.connection_id
    #             )

    #             return success

    #         except Exception as e:
                raise TransactionError(
    #                 f"Failed to rollback transaction {transaction_id}: {e}"
    #             )

    #     def get_transaction(self, transaction_id: str) -Optional[DatabaseTransaction]):
    #         """Get an active transaction by ID.

    #         Args:
    #             transaction_id: Transaction ID

    #         Returns:
    #             Transaction instance or None if not found
    #         """
    #         with self.lock:
                return self.active_transactions.get(transaction_id)

    #     def execute_in_transaction(
    #         self,
    #         transaction_id: str,
    #         operation: str,
    #         query: str,
    params: Optional[Dict[str, Any]] = None,
    #     ) -List[Dict[str, Any]]):
    #         """Execute an operation within a transaction.

    #         Args:
    #             transaction_id: Transaction ID
    #             operation: Type of operation
    #             query: SQL query string
    #             params: Optional parameters for query

    #         Returns:
    #             Query results
    #         """
    transaction = self.get_transaction(transaction_id)
    #         if transaction is None:
                raise TransactionError(f"Transaction {transaction_id} not found")

            return transaction.execute(operation, query, params)

    #     def cleanup_expired_transactions(self):
    #         """Clean up expired transactions.

    #         This method should be called periodically to clean up expired transactions.
    #         """
    current_time = time.time()
    expired_transactions = []

    #         with self.lock:
    #             for transaction_id, transaction in self.active_transactions.items():
    #                 if transaction.is_expired():
                        expired_transactions.append(transaction_id)

    #         # Rollback expired transactions
    #         for transaction_id in expired_transactions:
    #             try:
                    self.logger.warning(f"Rollback expired transaction {transaction_id}")
                    self.rollback_transaction(transaction_id)
    #             except Exception as e:
                    self.logger.error(
    #                     f"Failed to rollback expired transaction {transaction_id}: {e}"
    #                 )

    #     def get_transaction_stats(self) -Dict[str, Any]):
    #         """Get transaction statistics.

    #         Returns:
    #             Transaction statistics
    #         """
    #         with self.lock:
    stats = {
                    "active_transactions": len(self.active_transactions),
    #                 "transactions": [],
    #             }

    #             for transaction_id, transaction in self.active_transactions.items():
                    stats["transactions"].append(transaction.get_stats())

    #             return stats

    #     def health_check(self) -Dict[str, Any]):
    #         """Perform health check on transactions.

    #         Returns:
    #             Health check results
    #         """
    stats = self.get_transaction_stats()

    #         # Check for any issues
    issues = []
    #         if (
    #             stats["active_transactions"] 100
    #         )):  # Threshold for too many active transactions
                issues.append(
    #                 f"Too many active transactions: {stats['active_transactions']}"
    #             )

    #         # Check for expired transactions
    expired_count = 0
    #         for transaction in stats["transactions"]:
    #             if (
    #                 transaction["is_active"]
                    and (time.time() - transaction["last_used"]) 300
    #             )):  # 5 minutes
    expired_count + = 1

    #         if expired_count 0):
                issues.append(f"Found {expired_count} potentially expired transactions")

    #         return {
    #             "status": "healthy" if not issues else "warning",
    #             "issues": issues,
    #             "stats": stats,
    #         }

    #     @contextmanager
    #     def transaction(
    self, backend: Optional[str] = None, config: Optional[TransactionConfig] = None
    #     ):
    #         """Context manager for database transactions.

    #         Args:
                backend: Backend name (optional)
                config: Transaction configuration (optional)

    #         Yields:
    #             Transaction ID
    #         """
    transaction_id = None
    #         try:
    transaction_id = self.begin_transaction(backend, config)
    #             yield transaction_id
    #         except Exception as e:
    #             # If any error occurs, rollback the transaction
    #             if transaction_id:
    #                 try:
                        self.rollback_transaction(transaction_id)
    #                 except Exception:
    #                     pass  # Ignore rollback errors
    #             raise e
    #         finally:
    #             # Commit the transaction if no errors occurred
    #             if transaction_id and not any(
                    isinstance(e, TransactionError) and "rollback" in str(e).lower()
    #                 for e in [e for e in [locals().get("e")] if e]
    #             ):
    #                 try:
                        self.commit_transaction(transaction_id)
    #                 except Exception as e:
    #                     # If commit fails, rollback
    #                     try:
                            self.rollback_transaction(transaction_id)
    #                     except Exception:
    #                         pass  # Ignore rollback errors
    #                     raise e

    #     def __enter__(self):
    #         """Context manager entry."""
    #         return self

    #     def __exit__(self, exc_type, exc_val, exc_tb):
    #         """Context manager exit."""
    #         # Clean up any remaining transactions
            self.cleanup_expired_transactions()


# Export DatabaseTransactionManager for backward compatibility
TransactionManager = DatabaseTransactionManager

# Export DatabaseTransactionManager for backward compatibility
TransactionManager == DatabaseTransactionManager