# Converted from Python to NoodleCore
# Original file: src

# """
# Request/response handling for NoodleCore communication.

# This module provides the request/response handling functionality for
# synchronous communication between components.
# """

import asyncio
import logging
import time
import typing.Dict
from dataclasses import dataclass

import .message.Message
import .exceptions.(
#     CommunicationError,
#     MessageTimeoutError,
#     ResponseError,
#     MessageValidationError,
# )

logger = logging.getLogger(__name__)


dataclass
class RequestContext
    #     """Context for a request being processed."""
    #     request: Message
    #     start_time: float
    #     timeout: float
    callback: Optional[Callable] = None
    metadata: Optional[Dict[str, Any]] = None


class RequestResponseHandler
    #     """
    #     Handles request/response communication between components.

    #     This class manages the lifecycle of requests and responses, including
    #     correlation, timeout handling, and callback management.
    #     """

    #     def __init__(self):
    self.pending_requests: Dict[str, RequestContext] = {}
    self.request_handlers: Dict[MessageType, List[Callable]] = {}
    self.response_handlers: Dict[str, Callable] = {}
    self._lock = asyncio.Lock()

    #     def register_request_handler(
    #         self,
    #         message_type: MessageType,
    #         handler: Callable[[Message], Message]
    #     ) -None):
    #         """
    #         Register a handler for a specific request type.

    #         Args:
    #             message_type: The type of message to handle
    #             handler: The handler function that takes a request and returns a response
    #         """
    #         if message_type not in self.request_handlers:
    self.request_handlers[message_type] = []

            self.request_handlers[message_type].append(handler)
    #         logger.debug(f"Registered request handler for {message_type.value}")

    #     def unregister_request_handler(
    #         self,
    #         message_type: MessageType,
    #         handler: Callable[[Message], Message]
    #     ) -None):
    #         """
    #         Unregister a handler for a specific request type.

    #         Args:
    #             message_type: The type of message
    #             handler: The handler function to remove
    #         """
    #         if message_type in self.request_handlers:
    #             try:
                    self.request_handlers[message_type].remove(handler)
    #                 logger.debug(f"Unregistered request handler for {message_type.value}")
    #             except ValueError:
    #                 logger.warning(f"Handler not found for {message_type.value}")

    #     async def send_request(
    #         self,
    #         request: Message,
    timeout: float = 30.0,
    callback: Optional[Callable] = None
    #     ) -Message):
    #         """
    #         Send a request and wait for a response.

    #         Args:
    #             request: The request message
    #             timeout: Timeout in seconds
    #             callback: Optional callback function to handle the response

    #         Returns:
    #             The response message

    #         Raises:
    #             MessageTimeoutError: If the request times out
    #             MessageValidationError: If the request is invalid
    #         """
    #         # Validate the request
    #         if request.type != MessageType.REQUEST:
                raise MessageValidationError(
    #                 f"Message type must be REQUEST, got {request.type.value}"
    #             )

    #         # Create request context
    context = RequestContext(
    request = request,
    start_time = time.time(),
    timeout = timeout,
    callback = callback,
    #         )

    #         # Store the request context
    #         async with self._lock:
    self.pending_requests[request.request_id] = context

    #         try:
    #             # Wait for the response
    response = await self._wait_for_response(request.request_id, timeout)
    #             return response
    #         finally:
    #             # Clean up the request context
    #             async with self._lock:
                    self.pending_requests.pop(request.request_id, None)

    #     async def _wait_for_response(self, request_id: str, timeout: float) -Message):
    #         """
    #         Wait for a response to a specific request.

    #         Args:
    #             request_id: The ID of the request
    #             timeout: Timeout in seconds

    #         Returns:
    #             The response message

    #         Raises:
    #             MessageTimeoutError: If the request times out
    #         """
    start_time = time.time()

    #         while time.time() - start_time < timeout:
    #             async with self._lock:
    #                 if request_id in self.response_handlers:
    handler = self.response_handlers.pop(request_id)
    response = await handler()
    #                     return response

                await asyncio.sleep(0.1)  # Prevent busy waiting

            raise MessageTimeoutError(
    #             f"Request {request_id} timed out after {timeout} seconds"
    #         )

    #     async def handle_request(self, request: Message) -None):
    #         """
    #         Handle an incoming request.

    #         Args:
    #             request: The request message
    #         """
    #         if request.type != MessageType.REQUEST:
                logger.warning(f"Received non-request message in handle_request: {request.type.value}")
    #             return

    message_type = request.type

    #         if message_type not in self.request_handlers:
    #             logger.warning(f"No handler registered for request type {message_type.value}")
    #             return

    #         # Process the request with all registered handlers
    #         for handler in self.request_handlers[message_type]:
    #             try:
    #                 # Call the handler
    #                 if asyncio.iscoroutinefunction(handler):
    response = await handler(request)
    #                 else:
    response = handler(request)

    #                 # Ensure the response is a Message
    #                 if not isinstance(response, Message):
                        logger.error(f"Handler returned non-Message response: {type(response)}")
    #                     continue

    #                 # Send the response
                    await self.send_response(request, response)

    #             except Exception as e:
                    logger.error(f"Error in request handler: {str(e)}")

    #                 # Send an error response
    error_response = request.create_response(
    error = {
    #                         "error_code": 1006,
                            "message": f"Error handling request: {str(e)}",
    #                     }
    #                 )
                    await self.send_response(request, error_response)

    #     async def send_response(self, request: Message, response: Message) -None):
    #         """
    #         Send a response to a request.

    #         Args:
    #             request: The original request
    #             response: The response message
    #         """
    #         # Ensure the response is correlated with the request
    response.request_id = request.request_id

    #         # Register a handler for the response
    #         async def response_handler():
    #             return response

    #         async with self._lock:
    self.response_handlers[request.request_id] = response_handler

    #         logger.debug(f"Sent response for request {request.request_id}")

    #     async def handle_response(self, response: Message) -None):
    #         """
    #         Handle an incoming response.

    #         Args:
    #             response: The response message
    #         """
    #         if response.type not in [MessageType.RESPONSE, MessageType.ERROR]:
                logger.warning(f"Received non-response message in handle_response: {response.type.value}")
    #             return

    request_id = response.request_id

    #         async with self._lock:
    #             if request_id in self.pending_requests:
    context = self.pending_requests[request_id]

    #                 # Call the callback if provided
    #                 if context.callback:
    #                     try:
    #                         if asyncio.iscoroutinefunction(context.callback):
                                await context.callback(response)
    #                         else:
                                context.callback(response)
    #                     except Exception as e:
                            logger.error(f"Error in response callback: {str(e)}")
    #             else:
    #                 logger.warning(f"Received response for unknown request ID: {request_id}")

    #     def get_pending_requests(self) -List[Dict[str, Any]]):
    #         """
    #         Get information about pending requests.

    #         Returns:
    #             A list of dictionaries with information about pending requests
    #         """
    pending = []

    #         for request_id, context in self.pending_requests.items():
                pending.append({
    #                 "request_id": request_id,
    #                 "message_id": context.request.id,
    #                 "source": context.request.source.value,
    #                 "destination": context.request.destination.value,
                    "elapsed": time.time() - context.start_time,
    #                 "timeout": context.timeout,
    #             })

    #         return pending

    #     async def cleanup_expired_requests(self) -int):
    #         """
    #         Clean up expired requests.

    #         Returns:
    #             The number of expired requests that were cleaned up
    #         """
    current_time = time.time()
    expired_requests = []

    #         async with self._lock:
    #             for request_id, context in self.pending_requests.items():
    #                 if current_time - context.start_time context.timeout):
                        expired_requests.append(request_id)

    #             for request_id in expired_requests:
    #                 del self.pending_requests[request_id]
                    logger.warning(f"Cleaned up expired request: {request_id}")

            return len(expired_requests)


class RequestTimeoutMonitor
    #     """
    #     Monitors request timeouts and handles cleanup.

    #     This class periodically checks for expired requests and performs
    #     cleanup operations to prevent resource leaks.
    #     """

    #     def __init__(self, handler: RequestResponseHandler, check_interval: float = 10.0):
    self.handler = handler
    self.check_interval = check_interval
    self._running = False
    self._task: Optional[asyncio.Task] = None

    #     async def start(self) -None):
    #         """Start the timeout monitor."""
    #         if self._running:
                logger.warning("Timeout monitor is already running")
    #             return

    self._running = True
    self._task = asyncio.create_task(self._monitor_loop())
            logger.info("Request timeout monitor started")

    #     async def stop(self) -None):
    #         """Stop the timeout monitor."""
    #         if not self._running:
    #             return

    self._running = False

    #         if self._task:
                self._task.cancel()
    #             try:
    #                 await self._task
    #             except asyncio.CancelledError:
    #                 pass

            logger.info("Request timeout monitor stopped")

    #     async def _monitor_loop(self) -None):
    #         """Main monitoring loop."""
    #         while self._running:
    #             try:
    #                 # Clean up expired requests
    expired_count = await self.handler.cleanup_expired_requests()

    #                 if expired_count 0):
                        logger.info(f"Cleaned up {expired_count} expired requests")

    #                 # Wait for the next check
                    await asyncio.sleep(self.check_interval)

    #             except asyncio.CancelledError:
    #                 break
    #             except Exception as e:
                    logger.error(f"Error in timeout monitor: {str(e)}")
                    await asyncio.sleep(self.check_interval)