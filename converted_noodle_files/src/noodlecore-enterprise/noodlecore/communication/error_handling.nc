# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Error handling and recovery for NoodleCore communication.

# This module provides error handling and recovery mechanisms for the
# communication system, including retry logic, circuit breakers, and
# error reporting.
# """

import asyncio
import logging
import time
import typing.Dict,
import dataclasses.dataclass,
import enum.Enum

import .message.Message,
import .exceptions.(
#     CommunicationError,
#     MessageTimeoutError,
#     ComponentNotAvailableError,
#     MessageDeliveryError,
#     ConnectionError,
# )

logger = logging.getLogger(__name__)


class ErrorSeverity(Enum)
    #     """Severity levels for errors."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class CircuitBreakerState(Enum)
    #     """States of a circuit breaker."""
    CLOSED = "closed"  # Normal operation
    OPEN = "open"      # Failing, reject requests
    #     HALF_OPEN = "half_open"  # Testing if failures are resolved


# @dataclass
class ErrorReport
    #     """Report of an error that occurred."""
    #     error_code: int
    #     message: str
    #     severity: ErrorSeverity
    #     timestamp: float
    component: Optional[ComponentType] = None
    message_id: Optional[str] = None
    request_id: Optional[str] = None
    details: Optional[Dict[str, Any]] = None
    stack_trace: Optional[str] = None


# @dataclass
class RetryConfig
    #     """Configuration for retry logic."""
    max_retries: int = 3
    initial_delay: float = 1.0
    max_delay: float = 30.0
    backoff_factor: float = 2.0
    jitter: bool = True


# @dataclass
class CircuitBreakerConfig
    #     """Configuration for circuit breaker."""
    failure_threshold: int = 5
    recovery_timeout: float = 60.0
    expected_exception: type = CommunicationError
    success_threshold: int = math.subtract(3  # For half, open state)


class CircuitBreaker
    #     """
    #     Circuit breaker for handling component failures.

    #     This class implements the circuit breaker pattern to prevent cascading
    #     failures when a component is consistently failing.
    #     """

    #     def __init__(self, name: str, config: CircuitBreakerConfig):
    self.name = name
    self.config = config
    self.state = CircuitBreakerState.CLOSED
    self.failure_count = 0
    self.success_count = 0
    self.last_failure_time = 0.0
    self._lock = asyncio.Lock()

    #     async def call(self, func: Callable, *args, **kwargs) -> Any:
    #         """
    #         Call a function through the circuit breaker.

    #         Args:
    #             func: The function to call
    #             *args: Function arguments
    #             **kwargs: Function keyword arguments

    #         Returns:
    #             The result of the function call

    #         Raises:
    #             CommunicationError: If the circuit is open
    #         """
    #         async with self._lock:
    #             if self.state == CircuitBreakerState.OPEN:
    #                 if time.time() - self.last_failure_time > self.config.recovery_timeout:
    self.state = CircuitBreakerState.HALF_OPEN
    self.success_count = 0
                        logger.info(f"Circuit breaker {self.name} transitioning to HALF_OPEN")
    #                 else:
                        raise CommunicationError(
    #                         1007,
    #                         f"Circuit breaker {self.name} is OPEN"
    #                     )

    #         try:
    #             # Call the function
    #             if asyncio.iscoroutinefunction(func):
    result = math.multiply(await func(, args, **kwargs))
    #             else:
    result = math.multiply(func(, args, **kwargs))

    #             # Record success
                await self._record_success()
    #             return result

    #         except self.config.expected_exception as e:
    #             # Record failure
                await self._record_failure()
    #             raise

    #     async def _record_success(self) -> None:
    #         """Record a successful operation."""
    #         async with self._lock:
    #             if self.state == CircuitBreakerState.HALF_OPEN:
    self.success_count + = 1
    #                 if self.success_count >= self.config.success_threshold:
    self.state = CircuitBreakerState.CLOSED
    self.failure_count = 0
                        logger.info(f"Circuit breaker {self.name} transitioning to CLOSED")
    #             elif self.state == CircuitBreakerState.CLOSED:
    self.failure_count = 0

    #     async def _record_failure(self) -> None:
    #         """Record a failed operation."""
    #         async with self._lock:
    self.failure_count + = 1
    self.last_failure_time = time.time()

    #             if self.state == CircuitBreakerState.CLOSED:
    #                 if self.failure_count >= self.config.failure_threshold:
    self.state = CircuitBreakerState.OPEN
                        logger.warning(f"Circuit breaker {self.name} transitioning to OPEN")
    #             elif self.state == CircuitBreakerState.HALF_OPEN:
    self.state = CircuitBreakerState.OPEN
                    logger.warning(f"Circuit breaker {self.name} transitioning back to OPEN")

    #     def get_state(self) -> Dict[str, Any]:
    #         """Get the current state of the circuit breaker."""
    #         return {
    #             "name": self.name,
    #             "state": self.state.value,
    #             "failure_count": self.failure_count,
    #             "success_count": self.success_count,
    #             "last_failure_time": self.last_failure_time,
    #         }


class RetryHandler
    #     """
    #     Handler for retry logic with exponential backoff.

    #     This class provides retry logic for operations that may fail temporarily.
    #     """

    #     def __init__(self, config: RetryConfig):
    self.config = config

    #     async def retry(self, func: Callable, *args, **kwargs) -> Any:
    #         """
    #         Retry a function call with exponential backoff.

    #         Args:
    #             func: The function to call
    #             *args: Function arguments
    #             **kwargs: Function keyword arguments

    #         Returns:
    #             The result of the function call

    #         Raises:
    #             The last exception if all retries fail
    #         """
    last_exception = None

    #         for attempt in range(self.config.max_retries + 1):
    #             try:
    #                 # Call the function
    #                 if asyncio.iscoroutinefunction(func):
                        return await func(*args, **kwargs)
    #                 else:
                        return func(*args, **kwargs)

    #             except Exception as e:
    last_exception = e

    #                 if attempt == self.config.max_retries:
                        logger.error(f"Operation failed after {self.config.max_retries} retries: {str(e)}")
    #                     raise

    #                 # Calculate delay
    delay = min(
                        self.config.initial_delay * (self.config.backoff_factor ** attempt),
    #                     self.config.max_delay
    #                 )

    #                 # Add jitter if enabled
    #                 if self.config.jitter:
    #                     import random
    delay * = math.add((0.5, random.random() * 0.5))

                    logger.warning(
                        f"Operation failed (attempt {attempt + 1}/{self.config.max_retries + 1}), "
                        f"retrying in {delay:.2f}s: {str(e)}"
    #                 )

                    await asyncio.sleep(delay)

    #         # This should never be reached
    #         raise last_exception


class ErrorHandler
    #     """
    #     Handles errors in the communication system.

    #     This class provides centralized error handling, reporting, and recovery
    #     mechanisms for the communication system.
    #     """

    #     def __init__(self):
    self.error_reports: List[ErrorReport] = []
    self.circuit_breakers: Dict[str, CircuitBreaker] = {}
    self.retry_handlers: Dict[str, RetryHandler] = {}
    self.error_handlers: Dict[int, List[Callable]] = {}
    self._lock = asyncio.Lock()

    #     def register_circuit_breaker(
    #         self,
    #         name: str,
    config: Optional[CircuitBreakerConfig] = None
    #     ) -> CircuitBreaker:
    #         """
    #         Register a circuit breaker.

    #         Args:
    #             name: The name of the circuit breaker
    #             config: Optional configuration for the circuit breaker

    #         Returns:
    #             The created circuit breaker
    #         """
    #         if config is None:
    config = CircuitBreakerConfig()

    circuit_breaker = CircuitBreaker(name, config)
    self.circuit_breakers[name] = circuit_breaker

            logger.info(f"Registered circuit breaker {name}")
    #         return circuit_breaker

    #     def get_circuit_breaker(self, name: str) -> Optional[CircuitBreaker]:
    #         """Get a circuit breaker by name."""
            return self.circuit_breakers.get(name)

    #     def register_retry_handler(
    #         self,
    #         name: str,
    config: Optional[RetryConfig] = None
    #     ) -> RetryHandler:
    #         """
    #         Register a retry handler.

    #         Args:
    #             name: The name of the retry handler
    #             config: Optional configuration for the retry handler

    #         Returns:
    #             The created retry handler
    #         """
    #         if config is None:
    config = RetryConfig()

    retry_handler = RetryHandler(config)
    self.retry_handlers[name] = retry_handler

            logger.info(f"Registered retry handler {name}")
    #         return retry_handler

    #     def get_retry_handler(self, name: str) -> Optional[RetryHandler]:
    #         """Get a retry handler by name."""
            return self.retry_handlers.get(name)

    #     def register_error_handler(
    #         self,
    #         error_code: int,
    #         handler: Callable[[ErrorReport], None]
    #     ) -> None:
    #         """
    #         Register a handler for a specific error code.

    #         Args:
    #             error_code: The error code to handle
    #             handler: The handler function
    #         """
    #         if error_code not in self.error_handlers:
    self.error_handlers[error_code] = []

            self.error_handlers[error_code].append(handler)
    #         logger.debug(f"Registered error handler for error code {error_code}")

    #     async def handle_error(
    #         self,
    #         error: Exception,
    component: Optional[ComponentType] = None,
    message: Optional[Message] = None,
    severity: ErrorSeverity = ErrorSeverity.MEDIUM
    #     ) -> None:
    #         """
    #         Handle an error that occurred in the communication system.

    #         Args:
    #             error: The exception that occurred
    #             component: The component where the error occurred
    #             message: The message being processed when the error occurred
    #             severity: The severity of the error
    #         """
    #         # Extract error code if it's a CommunicationError
    error_code = 9999  # Default error code
    #         if isinstance(error, CommunicationError):
    error_code = error.error_code

    #         # Create error report
    error_report = ErrorReport(
    error_code = error_code,
    message = str(error),
    severity = severity,
    timestamp = time.time(),
    component = component,
    #             message_id=message.id if message else None,
    #             request_id=message.request_id if message else None,
    #             details=error.details if isinstance(error, CommunicationError) else None,
    #             stack_trace=logger.exception if severity in [ErrorSeverity.HIGH, ErrorSeverity.CRITICAL] else None,
    #         )

    #         # Store the error report
    #         async with self._lock:
                self.error_reports.append(error_report)

    #             # Keep only the last 1000 error reports
    #             if len(self.error_reports) > 1000:
    self.error_reports = math.subtract(self.error_reports[, 1000:])

    #         # Log the error
    #         log_message = f"Error {error_code} in {component.value if component else 'unknown'}: {error_report.message}"

    #         if severity == ErrorSeverity.CRITICAL:
                logger.critical(log_message)
    #         elif severity == ErrorSeverity.HIGH:
                logger.error(log_message)
    #         elif severity == ErrorSeverity.MEDIUM:
                logger.warning(log_message)
    #         else:
                logger.info(log_message)

    #         # Call registered error handlers
    #         if error_code in self.error_handlers:
    #             for handler in self.error_handlers[error_code]:
    #                 try:
    #                     if asyncio.iscoroutinefunction(handler):
                            await handler(error_report)
    #                     else:
                            handler(error_report)
    #                 except Exception as e:
                        logger.error(f"Error in error handler: {str(e)}")

    #         # Handle specific error types
    #         if isinstance(error, ComponentNotAvailableError):
                await self._handle_component_not_available(error, component)
    #         elif isinstance(error, MessageTimeoutError):
                await self._handle_message_timeout(error, message)
    #         elif isinstance(error, ConnectionError):
                await self._handle_connection_error(error, component)

    #     async def _handle_component_not_available(
    #         self,
    #         error: ComponentNotAvailableError,
    #         component: Optional[ComponentType]
    #     ) -> None:
    #         """Handle a component not available error."""
    #         # This could trigger circuit breakers or other recovery mechanisms
    #         logger.warning(f"Component {component.value if component else 'unknown'} is not available")

    #     async def _handle_message_timeout(
    #         self,
    #         error: MessageTimeoutError,
    #         message: Optional[Message]
    #     ) -> None:
    #         """Handle a message timeout error."""
    #         # This could trigger retry mechanisms or other recovery actions
    #         logger.warning(f"Message {message.id if message else 'unknown'} timed out")

    #     async def _handle_connection_error(
    #         self,
    #         error: ConnectionError,
    #         component: Optional[ComponentType]
    #     ) -> None:
    #         """Handle a connection error."""
    #         # This could trigger circuit breakers or other recovery mechanisms
    #         logger.warning(f"Connection error with {component.value if component else 'unknown'}")

    #     def get_error_reports(
    #         self,
    error_code: Optional[int] = None,
    component: Optional[ComponentType] = None,
    severity: Optional[ErrorSeverity] = None,
    since: Optional[float] = None
    #     ) -> List[ErrorReport]:
    #         """
    #         Get error reports matching the specified criteria.

    #         Args:
    #             error_code: Optional error code to filter by
    #             component: Optional component to filter by
    #             severity: Optional severity to filter by
    #             since: Optional timestamp to filter by

    #         Returns:
    #             List of matching error reports
    #         """
    reports = self.error_reports

    #         if error_code is not None:
    #             reports = [r for r in reports if r.error_code == error_code]

    #         if component is not None:
    #             reports = [r for r in reports if r.component == component]

    #         if severity is not None:
    #             reports = [r for r in reports if r.severity == severity]

    #         if since is not None:
    #             reports = [r for r in reports if r.timestamp >= since]

    #         return reports

    #     def get_error_statistics(self) -> Dict[str, Any]:
    #         """Get statistics about errors."""
    #         if not self.error_reports:
    #             return {
    #                 "total_errors": 0,
    #                 "by_error_code": {},
    #                 "by_component": {},
    #                 "by_severity": {},
    #             }

    #         # Count errors by code
    by_error_code = {}
    #         for report in self.error_reports:
    code = report.error_code
    by_error_code[code] = math.add(by_error_code.get(code, 0), 1)

    #         # Count errors by component
    by_component = {}
    #         for report in self.error_reports:
    #             component = report.component.value if report.component else "unknown"
    by_component[component] = math.add(by_component.get(component, 0), 1)

    #         # Count errors by severity
    by_severity = {}
    #         for report in self.error_reports:
    severity = report.severity.value
    by_severity[severity] = math.add(by_severity.get(severity, 0), 1)

    #         return {
                "total_errors": len(self.error_reports),
    #             "by_error_code": by_error_code,
    #             "by_component": by_component,
    #             "by_severity": by_severity,
    #         }

    #     def get_circuit_breaker_states(self) -> Dict[str, Dict[str, Any]]:
    #         """Get the states of all circuit breakers."""
    #         return {name: cb.get_state() for name, cb in self.circuit_breakers.items()}