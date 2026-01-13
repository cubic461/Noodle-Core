# Converted from Python to NoodleCore
# Original file: noodle-core

# """NoodleCore Database Failover Manager
 = =========================================

# Automatic failover management for database connections.
# Provides high availability and automatic recovery from database failures.

# Implements database standards:
# - Automatic failover on connection failures
# - Health monitoring of primary and backup connections
# - Proper error handling with 4-digit error codes
# - Configurable failover policies
# """

import os
import time
import logging
import threading
import uuid
import typing.Dict,
import dataclasses.dataclass,
import datetime.datetime,
import enum.Enum
import contextlib.contextmanager

import .connection_pool.DatabaseConnectionPool,
import .errors.DatabaseError,


class FailoverMode(Enum)
    #     """Failover operation modes."""
    MANUAL = "manual"
    AUTOMATIC = "automatic"
    SEMI_AUTOMATIC = "semi_automatic"


class FailoverPolicy(Enum)
    #     """Failover decision policies."""
    FAILURE_COUNT = "failure_count"
    RESPONSE_TIME = "response_time"
    HEALTH_CHECK = "health_check"
    COMBINED = "combined"


class FailoverState(Enum)
    #     """Failover state machine states."""
    PRIMARY = "primary"
    FAILING_OVER = "failing_over"
    SECONDARY = "secondary"
    FAILING_BACK = "failing_back"
    RECOVERING = "recovering"


# @dataclass
class FailoverConfig
    #     """Configuration for failover behavior."""
    mode: FailoverMode = FailoverMode.AUTOMATIC
    policy: FailoverPolicy = FailoverPolicy.COMBINED
    max_failure_count: int = 3
    failure_timeout: int = 30  # seconds
    response_time_threshold: float = 2.0  # seconds
    health_check_interval: int = 10  # seconds
    failover_timeout: int = 60  # seconds
    recovery_check_interval: int = 30  # seconds
    max_recovery_attempts: int = 5
    enable_connection_pooling: bool = True
    pool_max_connections: int = 20
    pool_timeout: int = 30


# @dataclass
class DatabaseEndpoint
    #     """Database endpoint configuration."""
    #     id: str
    #     name: str
    #     connection_string: str
    priority: int = 1  # 1 = highest priority
    is_primary: bool = False
    is_available: bool = True
    last_health_check: Optional[datetime] = None
    failure_count: int = 0
    last_failure: Optional[datetime] = None
    response_time: float = 0.0
    metadata: Dict[str, Any] = field(default_factory=dict)


# @dataclass
class FailoverEvent
    #     """Record of a failover event."""
    #     event_id: str
    #     from_endpoint: str
    #     to_endpoint: str
    #     reason: str
    timestamp: datetime = field(default_factory=datetime.now)
    duration: Optional[float] = None
    success: bool = False
    metadata: Dict[str, Any] = field(default_factory=dict)


class DatabaseFailoverManager
    #     """
    #     Automatic failover manager for database connections.

    #     Features:
    #     - Automatic failover on connection failures
    #     - Health monitoring of multiple database endpoints
    #     - Configurable failover policies and thresholds
    #     - Connection pooling with failover support
    #     - Proper error handling with 4-digit error codes
    #     """

    #     def __init__(
    #         self,
    #         endpoints: List[DatabaseEndpoint],
    #         backend_factory: Callable,
    config: Optional[FailoverConfig] = None
    #     ):
    #         """
    #         Initialize failover manager.

    #         Args:
    #             endpoints: List of database endpoints
    #             backend_factory: Factory function to create backend instances
    #             config: Optional failover configuration
    #         """
    #         self.endpoints = {ep.id: ep for ep in endpoints}
    self.backend_factory = backend_factory
    self.config = config or FailoverConfig()
    self.logger = logging.getLogger('noodlecore.database.failover_manager')

    #         # Failover state
    self._current_state = FailoverState.PRIMARY
    self._current_endpoint_id = self._get_primary_endpoint_id()
    self._failover_events: List[FailoverEvent] = []
    self._lock = threading.RLock()

    #         # Connection pools for each endpoint
    self._connection_pools: Dict[str, DatabaseConnectionPool] = {}

    #         # Background monitoring
    self._monitoring_active = False
    self._monitoring_thread: Optional[threading.Thread] = None
    self._stop_event = threading.Event()

    #         # Statistics
    self._stats = {
    #             "total_failovers": 0,
    #             "successful_failovers": 0,
    #             "failed_failovers": 0,
    #             "total_recoveries": 0,
    #             "successful_recoveries": 0,
    #             "failed_recoveries": 0,
    #             "average_failover_time": 0.0
    #         }

    #         # Initialize connection pools
    #         if self.config.enable_connection_pooling:
                self._initialize_connection_pools()

    #         self.logger.info(f"Failover manager initialized with {len(endpoints)} endpoints")

    #     def start_monitoring(self) -> None:
    #         """Start background health monitoring."""
    #         try:
    #             if self._monitoring_active:
    #                 return

    self._monitoring_active = True
                self._stop_event.clear()

    self._monitoring_thread = threading.Thread(
    target = self._monitoring_loop,
    daemon = True
    #             )
                self._monitoring_thread.start()

                self.logger.info("Failover monitoring started")
    #         except Exception as e:
    error_msg = f"Failed to start failover monitoring: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 4010)

    #     def stop_monitoring(self) -> None:
    #         """Stop background health monitoring."""
    #         try:
    #             if not self._monitoring_active:
    #                 return

    self._monitoring_active = False
                self._stop_event.set()

    #             if self._monitoring_thread and self._monitoring_thread.is_alive():
    self._monitoring_thread.join(timeout = 10)

                self.logger.info("Failover monitoring stopped")
    #         except Exception as e:
    error_msg = f"Failed to stop failover monitoring: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 4011)

    #     @contextmanager
    #     def get_connection(self):
    #         """
    #         Get a database connection with automatic failover.

    #         Yields:
    #             Database connection with failover support
    #         """
    connection = None
    endpoint_id = None

    #         try:
    #             # Get current endpoint
    #             with self._lock:
    endpoint_id = self._current_endpoint_id
    endpoint = self.endpoints[endpoint_id]

    #             # Get connection from pool or create new one
    #             if self.config.enable_connection_pooling and endpoint_id in self._connection_pools:
    pool = self._connection_pools[endpoint_id]
    connection = pool.get_connection()
    #             else:
    #                 # Create direct connection
    backend = self.backend_factory(endpoint.connection_string)
    connection = self._wrap_direct_connection(backend, endpoint_id)

    #             yield connection

    #         except Exception as e:
    #             # Handle connection failure
                self.logger.error(f"Connection failure on endpoint {endpoint_id}: {str(e)}")

    #             # Check if failover should be triggered
    #             if self.config.mode == FailoverMode.AUTOMATIC:
                    self._handle_connection_failure(endpoint_id, str(e))

    #             raise
    #         finally:
    #             # Return connection to pool if applicable
    #             if connection and hasattr(connection, 'close'):
                    connection.close()

    #     def trigger_failover(self, reason: str = "Manual failover") -> bool:
    #         """
    #         Manually trigger a failover.

    #         Args:
    #             reason: Reason for the failover

    #         Returns:
    #             True if failover was successful
    #         """
    #         try:
    #             with self._lock:
                    return self._perform_failover(reason)
    #         except Exception as e:
    error_msg = f"Manual failover failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 4012)

    #     def trigger_recovery(self) -> bool:
    #         """
    #         Manually trigger recovery to primary endpoint.

    #         Returns:
    #             True if recovery was successful
    #         """
    #         try:
    #             with self._lock:
                    return self._perform_recovery()
    #         except Exception as e:
    error_msg = f"Manual recovery failed: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_code = 4013)

    #     def get_status(self) -> Dict[str, Any]:
    #         """
    #         Get current failover status and statistics.

    #         Returns:
    #             Status dictionary with current state and statistics
    #         """
    #         with self._lock:
    #             return {
    #                 "current_state": self._current_state.value,
    #                 "current_endpoint": self._current_endpoint_id,
    #                 "endpoints": {
    #                     ep_id: {
    #                         "name": ep.name,
    #                         "priority": ep.priority,
    #                         "is_primary": ep.is_primary,
    #                         "is_available": ep.is_available,
    #                         "failure_count": ep.failure_count,
    #                         "last_failure": ep.last_failure.isoformat() if ep.last_failure else None,
    #                         "response_time": ep.response_time,
    #                         "last_health_check": ep.last_health_check.isoformat() if ep.last_health_check else None
    #                     }
    #                     for ep_id, ep in self.endpoints.items()
    #                 },
                    "statistics": self._stats.copy(),
    #                 "recent_failovers": [
    #                     {
    #                         "event_id": event.event_id,
    #                         "from_endpoint": event.from_endpoint,
    #                         "to_endpoint": event.to_endpoint,
    #                         "reason": event.reason,
                            "timestamp": event.timestamp.isoformat(),
    #                         "duration": event.duration,
    #                         "success": event.success
    #                     }
    #                     for event in self._failover_events[-10:]  # Last 10 events
    #                 ]
    #             }

    #     def _get_primary_endpoint_id(self) -> Optional[str]:
    #         """Get the primary endpoint ID."""
    #         for endpoint_id, endpoint in self.endpoints.items():
    #             if endpoint.is_primary:
    #                 return endpoint_id

    #         # Fallback to highest priority endpoint
    #         if self.endpoints:
    return min(self.endpoints.keys(), key = lambda k: self.endpoints[k].priority)

    #         return None

    #     def _initialize_connection_pools(self) -> None:
    #         """Initialize connection pools for all endpoints."""
    #         for endpoint_id, endpoint in self.endpoints.items():
    #             try:
    pool_config = {
    #                     "max_connections": self.config.pool_max_connections,
    #                     "timeout": self.config.pool_timeout,
    #                     "validate_connections": True,
    #                     "validation_interval": self.config.health_check_interval
    #                 }

    #                 # Create endpoint-specific backend factory
    #                 def endpoint_backend_factory():
                        return self.backend_factory(endpoint.connection_string)

    pool = DatabaseConnectionPool(endpoint_backend_factory, pool_config)
    self._connection_pools[endpoint_id] = pool

    #                 self.logger.debug(f"Initialized connection pool for endpoint {endpoint_id}")
    #             except Exception as e:
    #                 self.logger.error(f"Failed to initialize pool for endpoint {endpoint_id}: {e}")

    #     def _monitoring_loop(self) -> None:
    #         """Main monitoring loop for health checks."""
    #         while not self._stop_event.wait(self.config.health_check_interval):
    #             try:
                    self._perform_health_checks()
                    self._check_failover_conditions()
                    self._check_recovery_conditions()
    #             except Exception as e:
                    self.logger.error(f"Error in monitoring loop: {e}")

    #     def _perform_health_checks(self) -> None:
    #         """Perform health checks on all endpoints."""
    current_time = datetime.now()

    #         for endpoint_id, endpoint in self.endpoints.items():
    #             try:
    #                 # Check if health check is needed
    #                 if (endpoint.last_health_check and
    current_time - endpoint.last_health_check < timedelta(seconds = self.config.health_check_interval)):
    #                     continue

    #                 # Perform health check
    start_time = time.time()
    is_healthy = self._check_endpoint_health(endpoint)
    response_time = math.subtract(time.time(), start_time)

    #                 # Update endpoint status
    endpoint.last_health_check = current_time
    endpoint.response_time = response_time
    endpoint.is_available = is_healthy

    #                 if not is_healthy:
    endpoint.failure_count + = 1
    endpoint.last_failure = current_time
    #                 else:
    #                     # Reset failure count on successful health check
    #                     if endpoint.failure_count > 0:
                            self.logger.info(f"Endpoint {endpoint_id} recovered after {endpoint.failure_count} failures")
    endpoint.failure_count = 0

    #                 self.logger.debug(f"Health check for {endpoint_id}: {'healthy' if is_healthy else 'unhealthy'} ({response_time:.3f}s)")

    #             except Exception as e:
    #                 self.logger.error(f"Health check failed for endpoint {endpoint_id}: {e}")
    endpoint.is_available = False
    endpoint.failure_count + = 1
    endpoint.last_failure = current_time

    #     def _check_endpoint_health(self, endpoint: DatabaseEndpoint) -> bool:
    #         """Check if an endpoint is healthy."""
    #         try:
    #             if self.config.enable_connection_pooling and endpoint.id in self._connection_pools:
    #                 # Use connection pool for health check
    pool = self._connection_pools[endpoint.id]
    #                 with pool.get_connection() as conn:
                        conn.execute_query("SELECT 1", {})
    #                     return True
    #             else:
    #                 # Direct health check
    backend = self.backend_factory(endpoint.connection_string)
    #                 if hasattr(backend, 'ping'):
                        return backend.ping()
    #                 elif hasattr(backend, 'execute_query'):
                        backend.execute_query("SELECT 1", {})
    #                     return True
    #                 else:
    #                     return False
    #         except Exception as e:
    #             self.logger.debug(f"Health check failed for {endpoint.id}: {e}")
    #             return False

    #     def _check_failover_conditions(self) -> None:
    #         """Check if failover conditions are met."""
    #         if self._current_state not in [FailoverState.PRIMARY, FailoverState.RECOVERING]:
    #             return

    current_endpoint = self.endpoints.get(self._current_endpoint_id)
    #         if not current_endpoint:
    #             return

    should_failover = False
    reason = ""

    #         if self.config.policy in [FailoverPolicy.FAILURE_COUNT, FailoverPolicy.COMBINED]:
    #             if current_endpoint.failure_count >= self.config.max_failure_count:
    should_failover = True
    reason = f"Failure count threshold reached: {current_endpoint.failure_count}"

    #         if self.config.policy in [FailoverPolicy.RESPONSE_TIME, FailoverPolicy.COMBINED]:
    #             if current_endpoint.response_time > self.config.response_time_threshold:
    should_failover = True
    reason = f"Response time threshold exceeded: {current_endpoint.response_time:.3f}s"

    #         if self.config.policy in [FailoverPolicy.HEALTH_CHECK, FailoverPolicy.COMBINED]:
    #             if not current_endpoint.is_available:
    should_failover = True
    reason = "Health check failed"

    #         if should_failover and self.config.mode == FailoverMode.AUTOMATIC:
                self._perform_failover(reason)

    #     def _check_recovery_conditions(self) -> None:
    #         """Check if recovery conditions are met."""
    #         if self._current_state != FailoverState.SECONDARY:
    #             return

    primary_endpoint_id = self._get_primary_endpoint_id()
    #         if not primary_endpoint_id:
    #             return

    primary_endpoint = self.endpoints.get(primary_endpoint_id)
    #         if not primary_endpoint:
    #             return

    #         # Check if primary endpoint is healthy
    #         if (primary_endpoint.is_available and
    primary_endpoint.response_time < = self.config.response_time_threshold and
    primary_endpoint.failure_count = = 0):

                self._perform_recovery()

    #     def _handle_connection_failure(self, endpoint_id: str, error: str) -> None:
    #         """Handle a connection failure."""
    #         with self._lock:
    endpoint = self.endpoints.get(endpoint_id)
    #             if endpoint:
    endpoint.failure_count + = 1
    endpoint.last_failure = datetime.now()
    endpoint.is_available = False

                    self.logger.error(f"Connection failure on {endpoint_id}: {error} (failure count: {endpoint.failure_count})")

    #                 # Trigger failover if threshold reached
    #                 if (self.config.mode == FailoverMode.AUTOMATIC and
    endpoint.failure_count > = self.config.max_failure_count):
                        self._perform_failover(f"Connection failure threshold reached: {error}")

    #     def _perform_failover(self, reason: str) -> bool:
    #         """Perform failover to next available endpoint."""
    #         if self._current_state == FailoverState.FAILING_OVER:
    #             return False

    start_time = time.time()
    event_id = str(uuid.uuid4())
    from_endpoint = self._current_endpoint_id

    #         try:
    self._current_state = FailoverState.FAILING_OVER
                self.logger.info(f"Starting failover from {from_endpoint}: {reason}")

    #             # Find next available endpoint
    next_endpoint_id = self._find_next_endpoint()
    #             if not next_endpoint_id:
    #                 self.logger.error("No available endpoints for failover")
    self._current_state = FailoverState.PRIMARY
    #                 return False

    #             # Test connection to new endpoint
    next_endpoint = self.endpoints[next_endpoint_id]
    #             if not self._check_endpoint_health(next_endpoint):
                    self.logger.error(f"Failover target {next_endpoint_id} is not healthy")
    self._current_state = FailoverState.PRIMARY
    #                 return False

    #             # Switch to new endpoint
    self._current_endpoint_id = next_endpoint_id
    self._current_state = FailoverState.SECONDARY

    duration = math.subtract(time.time(), start_time)

    #             # Record failover event
    event = FailoverEvent(
    event_id = event_id,
    from_endpoint = from_endpoint,
    to_endpoint = next_endpoint_id,
    reason = reason,
    duration = duration,
    success = True
    #             )
                self._failover_events.append(event)

    #             # Update statistics
    self._stats["total_failovers"] + = 1
    self._stats["successful_failovers"] + = 1
    self._stats["average_failover_time"] = (
                    (self._stats["average_failover_time"] * (self._stats["total_failovers"] - 1) + duration) /
    #                 self._stats["total_failovers"]
    #             )

                self.logger.info(f"Failover completed to {next_endpoint_id} in {duration:.3f}s")
    #             return True

    #         except Exception as e:
    duration = math.subtract(time.time(), start_time)
    error_msg = f"Failover failed: {str(e)}"
                self.logger.error(error_msg)

    #             # Record failed failover
    event = FailoverEvent(
    event_id = event_id,
    from_endpoint = from_endpoint,
    to_endpoint = "unknown",
    reason = reason,
    duration = duration,
    success = False,
    metadata = {"error": error_msg}
    #             )
                self._failover_events.append(event)

    #             # Update statistics
    self._stats["total_failovers"] + = 1
    self._stats["failed_failovers"] + = 1

    self._current_state = FailoverState.PRIMARY
    #             return False

    #     def _perform_recovery(self) -> bool:
    #         """Perform recovery to primary endpoint."""
    #         if self._current_state not in [FailoverState.SECONDARY, FailoverState.RECOVERING]:
    #             return False

    start_time = time.time()
    from_endpoint = self._current_endpoint_id
    primary_endpoint_id = self._get_primary_endpoint_id()

    #         if not primary_endpoint_id:
    #             return False

    #         try:
    self._current_state = FailoverState.RECOVERING
                self.logger.info(f"Starting recovery to primary endpoint {primary_endpoint_id}")

    #             # Test connection to primary endpoint
    primary_endpoint = self.endpoints[primary_endpoint_id]
    #             if not self._check_endpoint_health(primary_endpoint):
                    self.logger.error(f"Primary endpoint {primary_endpoint_id} is not healthy")
    self._current_state = FailoverState.SECONDARY
    #                 return False

    #             # Switch to primary endpoint
    self._current_endpoint_id = primary_endpoint_id
    self._current_state = FailoverState.PRIMARY

    duration = math.subtract(time.time(), start_time)

    #             # Record recovery event
    event = FailoverEvent(
    event_id = str(uuid.uuid4()),
    from_endpoint = from_endpoint,
    to_endpoint = primary_endpoint_id,
    reason = "Recovery to primary endpoint",
    duration = duration,
    success = True
    #             )
                self._failover_events.append(event)

    #             # Update statistics
    self._stats["total_recoveries"] + = 1
    self._stats["successful_recoveries"] + = 1

                self.logger.info(f"Recovery completed to {primary_endpoint_id} in {duration:.3f}s")
    #             return True

    #         except Exception as e:
    error_msg = f"Recovery failed: {str(e)}"
                self.logger.error(error_msg)

    #             # Update statistics
    self._stats["total_recoveries"] + = 1
    self._stats["failed_recoveries"] + = 1

    self._current_state = FailoverState.SECONDARY
    #             return False

    #     def _find_next_endpoint(self) -> Optional[str]:
    #         """Find the next available endpoint for failover."""
    available_endpoints = [
    #             (ep_id, ep) for ep_id, ep in self.endpoints.items()
    #             if ep.is_available and ep_id != self._current_endpoint_id
    #         ]

    #         if not available_endpoints:
    #             return None

    # Sort by priority (lower number = higher priority)
    available_endpoints.sort(key = lambda x: x[1].priority)

    #         return available_endpoints[0][0]

    #     def _wrap_direct_connection(self, backend, endpoint_id: str):
    #         """Wrap a direct connection with failover support."""
    #         class FailoverConnectionWrapper:
    #             def __init__(self, backend, endpoint_id, failover_manager):
    self.backend = backend
    self.endpoint_id = endpoint_id
    self.failover_manager = failover_manager

    #             def execute_query(self, query: str, params: Optional[Dict[str, Any]] = None):
    #                 try:
                        return self.backend.execute_query(query, params)
    #                 except Exception as e:
    #                     # Notify failover manager of connection failure
                        self.failover_manager._handle_connection_failure(self.endpoint_id, str(e))
    #                     raise

    #             def close(self):
    #                 if hasattr(self.backend, 'close'):
                        self.backend.close()
    #                 elif hasattr(self.backend, 'disconnect'):
                        self.backend.disconnect()

            return FailoverConnectionWrapper(backend, endpoint_id, self)

    #     def shutdown(self) -> None:
    #         """Shutdown failover manager and cleanup resources."""
    #         try:
                self.stop_monitoring()

    #             # Shutdown connection pools
    #             for pool in self._connection_pools.values():
                    pool.shutdown()

                self._connection_pools.clear()
                self.logger.info("Failover manager shutdown complete")
    #         except Exception as e:
    error_msg = f"Error during failover manager shutdown: {str(e)}"
                self.logger.error(error_msg)
    raise DatabaseError(error_msg, error_code = 4014)