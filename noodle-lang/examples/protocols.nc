# Converted from Python to NoodleCore
# Original file: src

# """
# Communication protocols for NoodleCore.

# This module defines the communication protocols used between components
# in the NoodleCore system.
# """

import asyncio
import logging
import abc.ABC
import typing.Dict
import concurrent.futures.Future

import .message.Message
import .exceptions.(
#     CommunicationError,
#     MessageTimeoutError,
#     ComponentNotAvailableError,
#     ProtocolError,
# )

logger = logging.getLogger(__name__)


class CommunicationProtocol(ABC)
    #     """Abstract base class for communication protocols."""

    #     @abstractmethod
    #     async def send_message(self, message: Message) -None):
    #         """Send a message to the destination component."""
    #         pass

    #     @abstractmethod
    #     async def receive_message(self, timeout: float = 30.0) -Optional[Message]):
    #         """Receive a message from the queue."""
    #         pass

    #     @abstractmethod
    #     def is_component_available(self, component: ComponentType) -bool):
    #         """Check if a component is available for communication."""
    #         pass


class RequestResponseProtocol(CommunicationProtocol)
    #     """
    #     Protocol for request/response communication patterns.

    #     This protocol handles synchronous request/response communication
    #     between components with timeout and correlation support.
    #     """

    #     def __init__(self):
    self.pending_requests: Dict[str, Future] = {}
    self.message_handlers: Dict[MessageType, List[Callable]] = {}
    self.component_status: Dict[ComponentType, bool] = {}

    #         # Initialize all components as unavailable
    #         for component in ComponentType:
    self.component_status[component] = False

    #     def register_component(self, component: ComponentType) -None):
    #         """Register a component as available."""
    self.component_status[component] = True
            logger.info(f"Component {component.value} registered and available")

    #     def unregister_component(self, component: ComponentType) -None):
    #         """Unregister a component, marking it as unavailable."""
    self.component_status[component] = False
            logger.info(f"Component {component.value} unregistered and unavailable")

    #     def is_component_available(self, component: ComponentType) -bool):
    #         """Check if a component is available for communication."""
            return self.component_status.get(component, False)

    #     def register_handler(self, message_type: MessageType, handler: Callable) -None):
    #         """Register a handler for a specific message type."""
    #         if message_type not in self.message_handlers:
    self.message_handlers[message_type] = []
            self.message_handlers[message_type].append(handler)
    #         logger.debug(f"Registered handler for {message_type.value}")

    #     async def send_message(self, message: Message) -None):
    #         """Send a message to the destination component."""
    #         if not self.is_component_available(message.destination):
                raise ComponentNotAvailableError(
    #                 f"Destination component {message.destination.value} is not available"
    #             )

    #         # Validate message
            self._validate_message(message)

    #         # Log the message
            logger.debug(f"Sending message {message.id} from {message.source.value} to {message.destination.value}")

    #         # Handle the message based on its type
            await self._handle_message(message)

    #     async def _handle_message(self, message: Message) -None):
    #         """Handle an incoming message."""
    message_type = message.type

    #         if message_type in self.message_handlers:
    #             for handler in self.message_handlers[message_type]:
    #                 try:
                        await handler(message)
    #                 except Exception as e:
                        logger.error(f"Error in message handler: {str(e)}")
                        raise CommunicationError(
    #                         1005,
                            f"Error handling message {message.id}: {str(e)}"
    #                     )
    #         else:
    #             logger.warning(f"No handler registered for message type {message_type.value}")

    #     def _validate_message(self, message: Message) -None):
    #         """Validate a message before sending."""
    #         if not message.id:
                raise MessageValidationError("Message ID is required")

    #         if not message.source:
                raise MessageValidationError("Message source is required")

    #         if not message.destination:
                raise MessageValidationError("Message destination is required")

    #         if not message.type:
                raise MessageValidationError("Message type is required")

    #     async def send_request(
    #         self,
    #         message: Message,
    timeout: float = 30.0
    #     ) -Message):
    #         """
    #         Send a request and wait for a response.

    #         Args:
    #             message: The request message
    #             timeout: Timeout in seconds

    #         Returns:
    #             The response message

    #         Raises:
    #             MessageTimeoutError: If the request times out
    #         """
    #         # Create a future for the response
    future = asyncio.get_event_loop().create_future()
    self.pending_requests[message.request_id] = future

    #         try:
    #             # Send the request
                await self.send_message(message)

    #             # Wait for the response
    #             try:
    response = await asyncio.wait_for(future, timeout=timeout)
    #                 return response
    #             except asyncio.TimeoutError:
                    raise MessageTimeoutError(
    #                     f"Request {message.request_id} timed out after {timeout} seconds"
    #                 )
    #         finally:
    #             # Clean up the pending request
                self.pending_requests.pop(message.request_id, None)

    #     async def send_response(self, request: Message, response: Message) -None):
    #         """Send a response to a request."""
    #         # Ensure the response is correlated with the request
    response.request_id = request.request_id

    #         # Send the response
            await self.send_message(response)

    #     async def receive_message(self, timeout: float = 30.0) -Optional[Message]):
    #         """
    #         Receive a message from the queue.

    #         This method is not used in this implementation as messages are
    #         handled asynchronously through handlers.
    #         """
            await asyncio.sleep(timeout)
    #         return None

    #     def handle_response(self, response: Message) -None):
    #         """Handle an incoming response message."""
    request_id = response.request_id

    #         if request_id in self.pending_requests:
    future = self.pending_requests[request_id]
    #             if not future.done():
                    future.set_result(response)
    #         else:
    #             logger.warning(f"Received response for unknown request ID: {request_id}")


class EventProtocol(CommunicationProtocol)
    #     """
    #     Protocol for event-based communication patterns.

    #     This protocol handles asynchronous event propagation between components.
    #     """

    #     def __init__(self):
    self.event_subscribers: Dict[str, List[Callable]] = {}
    self.component_status: Dict[ComponentType, bool] = {}

    #         # Initialize all components as unavailable
    #         for component in ComponentType:
    self.component_status[component] = False

    #     def register_component(self, component: ComponentType) -None):
    #         """Register a component as available."""
    self.component_status[component] = True
            logger.info(f"Component {component.value} registered and available")

    #     def unregister_component(self, component: ComponentType) -None):
    #         """Unregister a component, marking it as unavailable."""
    self.component_status[component] = False
            logger.info(f"Component {component.value} unregistered and unavailable")

    #     def is_component_available(self, component: ComponentType) -bool):
    #         """Check if a component is available for communication."""
            return self.component_status.get(component, False)

    #     def subscribe_to_event(
    #         self,
    #         event_type: str,
    #         handler: Callable,
    component: Optional[ComponentType] = None
    #     ) -None):
    #         """
    #         Subscribe to an event type.

    #         Args:
    #             event_type: The type of event to subscribe to
    #             handler: The handler function for the event
    #             component: Optional component filter
    #         """
    #         key = f"{event_type}:{component.value if component else '*'}"

    #         if key not in self.event_subscribers:
    self.event_subscribers[key] = []

            self.event_subscribers[key].append(handler)
            logger.debug(f"Subscribed to event {key}")

    #     async def publish_event(self, message: Message) -None):
    #         """
    #         Publish an event to all subscribers.

    #         Args:
    #             message: The event message
    #         """
    #         if message.type != MessageType.EVENT:
                raise ProtocolError(
    #                 f"Message type must be EVENT, got {message.type.value}"
    #             )

    #         # Validate message
            self._validate_message(message)

    #         # Get event type from payload
    event_type = message.payload.get("event_type", "unknown")

    #         # Find all subscribers
    subscribers = []

    #         # Add subscribers for all components
    all_key = f"{event_type}:*"
    #         if all_key in self.event_subscribers:
                subscribers.extend(self.event_subscribers[all_key])

    #         # Add subscribers for specific component
    component_key = f"{event_type}:{message.destination.value}"
    #         if component_key in self.event_subscribers:
                subscribers.extend(self.event_subscribers[component_key])

    #         # Notify all subscribers
    #         for handler in subscribers:
    #             try:
                    await handler(message)
    #             except Exception as e:
                    logger.error(f"Error in event handler: {str(e)}")

    #     async def send_message(self, message: Message) -None):
    #         """Send an event message."""
            await self.publish_event(message)

    #     async def receive_message(self, timeout: float = 30.0) -Optional[Message]):
            """Receive a message (not used in event protocol)."""
            await asyncio.sleep(timeout)
    #         return None

    #     def _validate_message(self, message: Message) -None):
    #         """Validate an event message."""
    #         if not message.payload or "event_type" not in message.payload:
                raise MessageValidationError("Event message must contain event_type in payload")