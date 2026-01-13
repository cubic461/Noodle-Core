# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Message passing implementation for NoodleCore communication.

# This module provides the core message passing functionality between components
# in the NoodleCore system.
# """

import asyncio
import logging
import time
import typing.Dict,
import collections.deque
import dataclasses.dataclass

import .message.Message,
import .protocols.CommunicationProtocol,
import .exceptions.(
#     CommunicationError,
#     MessageTimeoutError,
#     ComponentNotAvailableError,
#     MessageDeliveryError,
# )

logger = logging.getLogger(__name__)


# @dataclass
class MessageQueue
    #     """A queue for messages with priority support."""

    #     def __init__(self, max_size: int = 1000):
    self.max_size = max_size
    self.queues = {
                MessagePriority.CRITICAL: deque(),
                MessagePriority.HIGH: deque(),
                MessagePriority.NORMAL: deque(),
                MessagePriority.LOW: deque(),
    #         }
    self._lock = asyncio.Lock()

    #     async def put(self, message: Message) -> None:
    #         """Add a message to the queue based on its priority."""
    #         async with self._lock:
    #             if self.size() >= self.max_size:
                    raise MessageDeliveryError("Message queue is full")

                self.queues[message.priority].append(message)
    #             logger.debug(f"Added message {message.id} to queue with priority {message.priority.name}")

    #     async def get(self) -> Optional[Message]:
    #         """Get the next message from the queue based on priority."""
    #         async with self._lock:
    #             for priority in [
    #                 MessagePriority.CRITICAL,
    #                 MessagePriority.HIGH,
    #                 MessagePriority.NORMAL,
    #                 MessagePriority.LOW,
    #             ]:
    #                 if self.queues[priority]:
    message = self.queues[priority].popleft()
                        logger.debug(f"Retrieved message {message.id} from queue")
    #                     return message
    #             return None

    #     def size(self) -> int:
    #         """Get the total number of messages in the queue."""
    #         return sum(len(queue) for queue in self.queues.values())

    #     def empty(self) -> bool:
    #         """Check if the queue is empty."""
    return self.size() = = 0


class MessageRouter
    #     """
    #     Routes messages between components based on their destination.

    #     This class manages the routing of messages to the appropriate components
    #     and handles the communication flow between different parts of the system.
    #     """

    #     def __init__(self):
    self.request_response_protocol = RequestResponseProtocol()
    self.event_protocol = EventProtocol()
    self.message_queues: Dict[ComponentType, MessageQueue] = {}
    self.component_handlers: Dict[ComponentType, Callable] = {}
    self._running = False
    self._tasks: List[asyncio.Task] = []

    #         # Initialize message queues for all component types
    #         for component in ComponentType:
    self.message_queues[component] = MessageQueue()

    #     def register_component(
    #         self,
    #         component: ComponentType,
    #         handler: Callable[[Message], Any]
    #     ) -> None:
    #         """
    #         Register a component with its message handler.

    #         Args:
    #             component: The component type
    #             handler: The handler function for incoming messages
    #         """
    self.component_handlers[component] = handler
            self.request_response_protocol.register_component(component)
            self.event_protocol.register_component(component)

    #         logger.info(f"Registered component {component.value} with message handler")

    #     def unregister_component(self, component: ComponentType) -> None:
    #         """Unregister a component."""
    #         if component in self.component_handlers:
    #             del self.component_handlers[component]

            self.request_response_protocol.unregister_component(component)
            self.event_protocol.unregister_component(component)

            logger.info(f"Unregistered component {component.value}")

    #     async def start(self) -> None:
    #         """Start the message router and begin processing messages."""
    #         if self._running:
                logger.warning("Message router is already running")
    #             return

    self._running = True

    #         # Start a task for each component queue
    #         for component in ComponentType:
    task = asyncio.create_task(self._process_queue(component))
                self._tasks.append(task)

            logger.info("Message router started")

    #     async def stop(self) -> None:
    #         """Stop the message router and clean up resources."""
    #         if not self._running:
    #             return

    self._running = False

    #         # Cancel all tasks
    #         for task in self._tasks:
                task.cancel()

    #         # Wait for tasks to complete
    #         if self._tasks:
    await asyncio.gather(*self._tasks, return_exceptions = True)

            self._tasks.clear()
            logger.info("Message router stopped")

    #     async def _process_queue(self, component: ComponentType) -> None:
    #         """Process messages for a specific component."""
    queue = self.message_queues[component]

    #         while self._running:
    #             try:
    #                 # Get a message from the queue
    message = await queue.get()

    #                 if message is None:
                        await asyncio.sleep(0.1)
    #                     continue

    #                 # Process the message
                    await self._handle_message(message)

    #             except asyncio.CancelledError:
    #                 break
    #             except Exception as e:
    #                 logger.error(f"Error processing message for {component.value}: {str(e)}")
                    await asyncio.sleep(1)  # Prevent tight loop on error

    #     async def _handle_message(self, message: Message) -> None:
    #         """Handle an incoming message."""
    destination = message.destination

    #         if destination not in self.component_handlers:
    #             logger.warning(f"No handler registered for component {destination.value}")
    #             return

    handler = self.component_handlers[destination]

    #         try:
    #             # Call the handler
    #             if asyncio.iscoroutinefunction(handler):
                    await handler(message)
    #             else:
                    handler(message)
    #         except Exception as e:
    #             logger.error(f"Error in message handler for {destination.value}: {str(e)}")

    #             # Send an error response if this was a request
    #             if message.type == MessageType.REQUEST:
    error_response = message.create_response(
    error = {
    #                         "error_code": 1005,
                            "message": f"Error handling message: {str(e)}",
    #                     }
    #                 )
                    await self.send_message(error_response)

    #     async def send_message(self, message: Message) -> None:
    #         """
    #         Send a message to its destination component.

    #         Args:
    #             message: The message to send
    #         """
    destination = message.destination

    #         # Check if the destination component is available
    #         if not self.request_response_protocol.is_component_available(destination):
                raise ComponentNotAvailableError(
    #                 f"Destination component {destination.value} is not available"
    #             )

    #         # Add the message to the appropriate queue
    queue = self.message_queues[destination]
            await queue.put(message)

    #         logger.debug(f"Queued message {message.id} for {destination.value}")

    #     async def send_request(
    #         self,
    #         message: Message,
    timeout: float = 30.0
    #     ) -> Message:
    #         """
    #         Send a request and wait for a response.

    #         Args:
    #             message: The request message
    #             timeout: Timeout in seconds

    #         Returns:
    #             The response message
    #         """
    #         # Register a temporary handler for the response
    response_future = asyncio.get_event_loop().create_future()

    #         def response_handler(response: Message) -> None:
    #             if response.request_id == message.request_id and not response_future.done():
                    response_future.set_result(response)

    #         # Register the handler
    source = message.source
    original_handler = self.component_handlers.get(source)
    self.component_handlers[source] = response_handler

    #         try:
    #             # Send the request
                await self.send_message(message)

    #             # Wait for the response
    #             try:
    response = await asyncio.wait_for(response_future, timeout=timeout)
    #                 return response
    #             except asyncio.TimeoutError:
                    raise MessageTimeoutError(
    #                     f"Request {message.request_id} timed out after {timeout} seconds"
    #                 )
    #         finally:
    #             # Restore the original handler
    #             if original_handler:
    self.component_handlers[source] = original_handler
    #             else:
                    self.component_handlers.pop(source, None)

    #     async def publish_event(self, message: Message) -> None:
    #         """
    #         Publish an event to all subscribers.

    #         Args:
    #             message: The event message
    #         """
    #         if message.type != MessageType.EVENT:
                raise CommunicationError(
    #                 1004,
    #                 f"Message type must be EVENT, got {message.type.value}"
    #             )

    #         # Send the event to all registered components
    #         for component in ComponentType:
    #             if self.request_response_protocol.is_component_available(component):
    #                 # Create a copy of the message for each component
    event_copy = Message(
    type = message.type,
    source = message.source,
    destination = component,
    priority = message.priority,
    payload = message.payload,
    metadata = message.metadata,
    #                 )
    event_copy.request_id = message.request_id

                    await self.send_message(event_copy)

    #     def get_queue_status(self) -> Dict[str, Dict[str, int]]:
    #         """Get the status of all message queues."""
    status = {}

    #         for component, queue in self.message_queues.items():
    component_name = component.value
    status[component_name] = {
                    "total": queue.size(),
                    "critical": len(queue.queues[MessagePriority.CRITICAL]),
                    "high": len(queue.queues[MessagePriority.HIGH]),
                    "normal": len(queue.queues[MessagePriority.NORMAL]),
                    "low": len(queue.queues[MessagePriority.LOW]),
    #             }

    #         return status

    #     def get_component_status(self) -> Dict[str, bool]:
    #         """Get the status of all registered components."""
    status = {}

    #         for component in ComponentType:
    component_name = component.value
    status[component_name] = self.request_response_protocol.is_component_available(component)

    #         return status