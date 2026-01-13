# Converted from Python to NoodleCore
# Original file: src

# """
# Event propagation for NoodleCore communication.

# This module provides the event propagation functionality for asynchronous
# communication between components.
# """

import asyncio
import logging
import time
import typing.Dict
from dataclasses import dataclass
import enum.Enum

import .message.Message
import .exceptions.(
#     CommunicationError,
#     MessageValidationError,
# )

logger = logging.getLogger(__name__)


class EventDeliveryMode(Enum)
    #     """Modes for event delivery."""
    FIRE_AND_FORGET = "fire_and_forget"
    ACKNOWLEDGED = "acknowledged"
    GUARANTEED = "guaranteed"


dataclass
class EventSubscription
    #     """Represents a subscription to an event type."""
    #     event_type: str
    #     handler: Callable
    component_filter: Optional[ComponentType] = None
    delivery_mode: EventDeliveryMode = EventDeliveryMode.FIRE_AND_FORGET
    metadata: Optional[Dict[str, Any]] = None


dataclass
class EventDeliveryStatus
    #     """Status of an event delivery."""
    #     event_id: str
    #     subscription_id: str
    #     status: str  # "pending", "delivered", "failed"
    #     timestamp: float
    error: Optional[str] = None


class EventRegistry
    #     """
    #     Registry for managing event subscriptions.

    #     This class maintains a registry of all event subscriptions and provides
    #     methods to add, remove, and query subscriptions.
    #     """

    #     def __init__(self):
    self.subscriptions: Dict[str, List[EventSubscription]] = {}
    self.subscription_handlers: Dict[str, EventSubscription] = {}
    self._subscription_id_counter = 0
    self._lock = asyncio.Lock()

    #     async def subscribe(
    #         self,
    #         event_type: str,
    #         handler: Callable,
    component_filter: Optional[ComponentType] = None,
    delivery_mode: EventDeliveryMode = EventDeliveryMode.FIRE_AND_FORGET,
    metadata: Optional[Dict[str, Any]] = None
    #     ) -str):
    #         """
    #         Subscribe to an event type.

    #         Args:
    #             event_type: The type of event to subscribe to
    #             handler: The handler function for the event
    #             component_filter: Optional component to filter events by
    #             delivery_mode: The delivery mode for events
    #             metadata: Additional metadata for the subscription

    #         Returns:
    #             The subscription ID
    #         """
    #         async with self._lock:
    #             # Generate a unique subscription ID
    self._subscription_id_counter + = 1
    subscription_id = f"sub_{self._subscription_id_counter}"

    #             # Create the subscription
    subscription = EventSubscription(
    event_type = event_type,
    handler = handler,
    component_filter = component_filter,
    delivery_mode = delivery_mode,
    metadata = metadata,
    #             )

    #             # Store the subscription
    #             if event_type not in self.subscriptions:
    self.subscriptions[event_type] = []

                self.subscriptions[event_type].append(subscription)
    self.subscription_handlers[subscription_id] = subscription

    #             logger.debug(f"Created subscription {subscription_id} for event {event_type}")
    #             return subscription_id

    #     async def unsubscribe(self, subscription_id: str) -bool):
    #         """
    #         Unsubscribe from an event.

    #         Args:
    #             subscription_id: The subscription ID

    #         Returns:
    #             True if the subscription was removed, False if not found
    #         """
    #         async with self._lock:
    #             if subscription_id not in self.subscription_handlers:
    #                 return False

    subscription = self.subscription_handlers[subscription_id]

    #             # Remove from the event type list
    #             if subscription.event_type in self.subscriptions:
    #                 try:
                        self.subscriptions[subscription.event_type].remove(subscription)
    #                 except ValueError:
    #                     pass

    #             # Remove from the handlers dict
    #             del self.subscription_handlers[subscription_id]

                logger.debug(f"Removed subscription {subscription_id}")
    #             return True

    #     def get_subscriptions(self, event_type: str) -List[EventSubscription]):
    #         """
    #         Get all subscriptions for an event type.

    #         Args:
    #             event_type: The event type

    #         Returns:
    #             List of subscriptions for the event type
    #         """
            return self.subscriptions.get(event_type, [])

    #     def get_subscription(self, subscription_id: str) -Optional[EventSubscription]):
    #         """
    #         Get a subscription by ID.

    #         Args:
    #             subscription_id: The subscription ID

    #         Returns:
    #             The subscription if found, None otherwise
    #         """
            return self.subscription_handlers.get(subscription_id)

    #     def get_all_subscriptions(self) -Dict[str, List[EventSubscription]]):
    #         """Get all subscriptions."""
            return self.subscriptions.copy()


class EventPropagator
    #     """
    #     Propagates events to subscribers.

    #     This class handles the propagation of events to all relevant subscribers
    #     based on their subscriptions and filters.
    #     """

    #     def __init__(self, registry: EventRegistry):
    self.registry = registry
    self.delivery_status: Dict[str, List[EventDeliveryStatus]] = {}
    self._event_id_counter = 0
    self._lock = asyncio.Lock()

    #     async def propagate_event(
    #         self,
    #         message: Message,
    #         event_type: str
    #     ) -List[str]):
    #         """
    #         Propagate an event to all relevant subscribers.

    #         Args:
    #             message: The event message
    #             event_type: The type of event

    #         Returns:
    #             List of subscription IDs that the event was delivered to
    #         """
    #         if message.type != MessageType.EVENT:
                raise MessageValidationError(
    #                 f"Message type must be EVENT, got {message.type.value}"
    #             )

    #         # Get all subscriptions for this event type
    subscriptions = self.registry.get_subscriptions(event_type)

    #         # Filter subscriptions based on component filter
    relevant_subscriptions = []
    #         for subscription in subscriptions:
    #             if (subscription.component_filter is None or
    subscription.component_filter == message.destination):
                    relevant_subscriptions.append(subscription)

    #         # Generate a unique event ID
    #         async with self._lock:
    self._event_id_counter + = 1
    event_id = f"event_{self._event_id_counter}"

    #         # Initialize delivery status for this event
    self.delivery_status[event_id] = []

    #         # Deliver the event to all relevant subscriptions
    delivered_subscriptions = []

    #         for subscription in relevant_subscriptions:
    #             try:
    #                 # Create delivery status
    delivery_status = EventDeliveryStatus(
    event_id = event_id,
    subscription_id = id(subscription),  # Use object ID as subscription ID
    status = "pending",
    timestamp = time.time(),
    #                 )

    #                 # Handle the event based on delivery mode
    #                 if subscription.delivery_mode == EventDeliveryMode.FIRE_AND_FORGET:
                        await self._deliver_fire_and_forget(subscription, message)
    delivery_status.status = "delivered"
    #                 elif subscription.delivery_mode == EventDeliveryMode.ACKNOWLEDGED:
                        await self._deliver_acknowledged(subscription, message)
    delivery_status.status = "delivered"
    #                 elif subscription.delivery_mode == EventDeliveryMode.GUARANTEED:
                        await self._deliver_guaranteed(subscription, message)
    delivery_status.status = "delivered"

                    delivered_subscriptions.append(id(subscription))

    #             except Exception as e:
    delivery_status.status = "failed"
    delivery_status.error = str(e)
                    logger.error(f"Error delivering event to subscription: {str(e)}")

    #             # Store delivery status
                self.delivery_status[event_id].append(delivery_status)

            logger.debug(f"Propagated event {event_id} to {len(delivered_subscriptions)} subscriptions")
    #         return delivered_subscriptions

    #     async def _deliver_fire_and_forget(
    #         self,
    #         subscription: EventSubscription,
    #         message: Message
    #     ) -None):
    #         """Deliver an event in fire-and-forget mode."""
    #         if asyncio.iscoroutinefunction(subscription.handler):
    #             # Don't await for fire-and-forget
                asyncio.create_task(subscription.handler(message))
    #         else:
                subscription.handler(message)

    #     async def _deliver_acknowledged(
    #         self,
    #         subscription: EventSubscription,
    #         message: Message
    #     ) -None):
    #         """Deliver an event and wait for acknowledgment."""
    #         if asyncio.iscoroutinefunction(subscription.handler):
                await subscription.handler(message)
    #         else:
                subscription.handler(message)

    #     async def _deliver_guaranteed(
    #         self,
    #         subscription: EventSubscription,
    #         message: Message
    #     ) -None):
    #         """Deliver an event with guaranteed delivery."""
    max_retries = 3
    retry_delay = 1.0

    #         for attempt in range(max_retries):
    #             try:
    #                 if asyncio.iscoroutinefunction(subscription.handler):
                        await subscription.handler(message)
    #                 else:
                        subscription.handler(message)
    #                 break  # Success, exit the retry loop
    #             except Exception as e:
    #                 if attempt == max_retries - 1:
    #                     raise  # Re-raise on last attempt
                    logger.warning(f"Event delivery failed, retrying ({attempt + 1}/{max_retries}): {str(e)}")
                    await asyncio.sleep(retry_delay * (2 ** attempt))  # Exponential backoff

    #     def get_event_status(self, event_id: str) -List[EventDeliveryStatus]):
    #         """
    #         Get the delivery status for an event.

    #         Args:
    #             event_id: The event ID

    #         Returns:
    #             List of delivery status for the event
    #         """
            return self.delivery_status.get(event_id, [])

    #     def cleanup_old_events(self, max_age: float = 3600.0) -int):
    #         """
    #         Clean up old event status records.

    #         Args:
    #             max_age: Maximum age in seconds

    #         Returns:
    #             Number of events cleaned up
    #         """
    current_time = time.time()
    events_to_remove = []

    #         for event_id, status_list in self.delivery_status.items():
    #             if status_list and current_time - status_list[0].timestamp max_age):
                    events_to_remove.append(event_id)

    #         for event_id in events_to_remove:
    #             del self.delivery_status[event_id]

            return len(events_to_remove)


class EventManager
    #     """
    #     High-level manager for event propagation.

    #     This class provides a high-level interface for managing events,
    #     subscriptions, and propagation.
    #     """

    #     def __init__(self):
    self.registry = EventRegistry()
    self.propagator = EventPropagator(self.registry)
    self._running = False
    self._cleanup_task: Optional[asyncio.Task] = None

    #     async def start(self) -None):
    #         """Start the event manager."""
    #         if self._running:
                logger.warning("Event manager is already running")
    #             return

    self._running = True

    #         # Start the cleanup task
    self._cleanup_task = asyncio.create_task(self._cleanup_loop())

            logger.info("Event manager started")

    #     async def stop(self) -None):
    #         """Stop the event manager."""
    #         if not self._running:
    #             return

    self._running = False

    #         # Cancel the cleanup task
    #         if self._cleanup_task:
                self._cleanup_task.cancel()
    #             try:
    #                 await self._cleanup_task
    #             except asyncio.CancelledError:
    #                 pass

            logger.info("Event manager stopped")

    #     async def subscribe(
    #         self,
    #         event_type: str,
    #         handler: Callable,
    component_filter: Optional[ComponentType] = None,
    delivery_mode: EventDeliveryMode = EventDeliveryMode.FIRE_AND_FORGET,
    metadata: Optional[Dict[str, Any]] = None
    #     ) -str):
    #         """Subscribe to an event type."""
            return await self.registry.subscribe(
    event_type = event_type,
    handler = handler,
    component_filter = component_filter,
    delivery_mode = delivery_mode,
    metadata = metadata,
    #         )

    #     async def unsubscribe(self, subscription_id: str) -bool):
    #         """Unsubscribe from an event."""
            return await self.registry.unsubscribe(subscription_id)

    #     async def publish_event(self, message: Message) -List[str]):
    #         """Publish an event to all subscribers."""
    event_type = message.payload.get("event_type", "unknown")
            return await self.propagator.propagate_event(message, event_type)

    #     def get_subscription_info(self, subscription_id: str) -Optional[Dict[str, Any]]):
    #         """Get information about a subscription."""
    subscription = self.registry.get_subscription(subscription_id)
    #         if not subscription:
    #             return None

    #         return {
    #             "event_type": subscription.event_type,
    #             "component_filter": subscription.component_filter.value if subscription.component_filter else None,
    #             "delivery_mode": subscription.delivery_mode.value,
    #             "metadata": subscription.metadata,
    #         }

    #     def get_all_subscriptions(self) -Dict[str, List[Dict[str, Any]]]):
    #         """Get information about all subscriptions."""
    all_subscriptions = self.registry.get_all_subscriptions()
    result = {}

    #         for event_type, subscriptions in all_subscriptions.items():
    result[event_type] = []
    #             for subscription in subscriptions:
                    result[event_type].append({
                        "subscription_id": id(subscription),
    #                     "component_filter": subscription.component_filter.value if subscription.component_filter else None,
    #                     "delivery_mode": subscription.delivery_mode.value,
    #                     "metadata": subscription.metadata,
    #                 })

    #         return result

    #     async def _cleanup_loop(self) -None):
    #         """Cleanup loop for old event status records."""
    #         while self._running:
    #             try:
    #                 # Clean up old events
    cleaned_count = self.propagator.cleanup_old_events()

    #                 if cleaned_count 0):
                        logger.debug(f"Cleaned up {cleaned_count} old event records")

    #                 # Wait for the next cleanup
                    await asyncio.sleep(300)  # Clean up every 5 minutes

    #             except asyncio.CancelledError:
    #                 break
    #             except Exception as e:
                    logger.error(f"Error in cleanup loop: {str(e)}")
                    await asyncio.sleep(60)  # Wait 1 minute on error