# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Event bus system for the Noodle-IDE plugin architecture.

# This module provides a centralized event system that allows plugins
# to communicate with each other through published events and event handlers.
# """

import asyncio
import json
import logging
import time
import collections.defaultdict,
import dataclasses.dataclass,
import enum.Enum
import typing.Any,
import uuid
import threading
import weakref

# Type variables for generic event handling
T = TypeVar('T')
EventHandler = Callable[['Event[T]'], None]
AsyncEventHandler = Callable[['Event[T]'], None]


class EventPriority(Enum)
    #     """Priority levels for event handlers."""
    LOW = 0
    NORMAL = 1
    HIGH = 2
    CRITICAL = 3


class EventType(Enum)
    #     """Standard event types for the plugin system."""
    PLUGIN_LOADED = "plugin.loaded"
    PLUGIN_UNLOADED = "plugin.unloaded"
    PLUGIN_STARTED = "plugin.started"
    PLUGIN_STOPPED = "plugin.stopped"
    PLUGIN_ERROR = "plugin.error"
    FILE_CHANGED = "file.changed"
    CONFIG_CHANGED = "config.changed"
    UI_ACTION = "ui.action"
    HOT_RELOAD = "hot.reload"
    SYSTEM_SHUTDOWN = "system.shutdown"


# @dataclass
class Event(Generic[T])
    #     """Represents an event being published."""

    #     event_type: str
    #     data: T
    source: Optional[str] = None
    timestamp: float = field(default_factory=time.time)
    topic: Optional[str] = None
    metadata: Dict[str, Any] = field(default_factory=dict)
    request_id: str = field(default_factory=lambda: str(uuid.uuid4()))

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert event to dictionary for serialization."""
    #         return {
    #             "event_type": self.event_type,
    #             "data": self.data,
    #             "source": self.source,
    #             "timestamp": self.timestamp,
    #             "topic": self.topic,
    #             "metadata": self.metadata,
    #             "request_id": self.request_id,
    #         }

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -> 'Event[T]':
    #         """Create event from dictionary."""
            return cls(
    event_type = data["event_type"],
    data = data["data"],
    source = data.get("source"),
    timestamp = data.get("timestamp", time.time()),
    topic = data.get("topic"),
    metadata = data.get("metadata", {}),
    request_id = data.get("request_id", str(uuid.uuid4())),
    #         )


# @dataclass
class EventHandlerInfo
    #     """Information about an event handler."""

    #     handler_id: str
    #     callback: Union[EventHandler, AsyncEventHandler]
    #     priority: EventPriority
    once: bool = False
    plugin_id: Optional[str] = None
    event_type: Optional[str] = None
    topic: Optional[str] = None
    filter_func: Optional[Callable[[Event], bool]] = None
    created_at: float = field(default_factory=time.time)
    call_count: int = 0
    last_called: Optional[float] = None
    execution_time: float = 0.0


class EventFilter
    #     """Filter condition for event handlers."""

    #     def __init__(
    #         self,
    event_type: Optional[str] = None,
    source: Optional[str] = None,
    topic: Optional[str] = None,
    metadata_filter: Optional[Dict[str, Any]] = None,
    custom_filter: Optional[Callable[[Event], bool]] = None,
    #     ):
    #         """
    #         Initialize event filter.

    #         Args:
    #             event_type: Specific event type to filter on
    #             source: Source plugin to filter on
    #             topic: Topic to filter on
    #             metadata_filter: Key-value pairs to match in metadata
    #             custom_filter: Custom filter function
    #         """
    self.event_type = event_type
    self.source = source
    self.topic = topic
    self.metadata_filter = metadata_filter or {}
    self.custom_filter = custom_filter

    #     def matches(self, event: Event) -> bool:
    #         """
    #         Check if an event matches this filter.

    #         Args:
    #             event: Event to check

    #         Returns:
    #             True if event matches filter
    #         """
    #         if self.event_type and event.event_type != self.event_type:
    #             return False

    #         if self.source and event.source != self.source:
    #             return False

    #         if self.topic and event.topic != self.topic:
    #             return False

    #         if self.metadata_filter:
    #             for key, value in self.metadata_filter.items():
    #                 if key not in event.metadata or event.metadata[key] != value:
    #                     return False

    #         if self.custom_filter and not self.custom_filter(event):
    #             return False

    #         return True


class EventHistory
    #     """Manages persistent event history for debugging."""

    #     def __init__(self, max_size: int = 1000):
    #         """
    #         Initialize event history.

    #         Args:
    #             max_size: Maximum number of events to keep in memory
    #         """
    self.max_size = max_size
    self._events: deque = deque(maxlen=max_size)
    self._lock = threading.Lock()
    self._logger = logging.getLogger(__name__)

    #     def add_event(self, event: Event) -> None:
    #         """Add an event to the history."""
    #         with self._lock:
                self._events.append(event)

    #     def get_events(
    #         self,
    event_type: Optional[str] = None,
    source: Optional[str] = None,
    topic: Optional[str] = None,
    since: Optional[float] = None,
    limit: Optional[int] = None,
    #     ) -> List[Event]:
    #         """
    #         Get events from history with optional filtering.

    #         Args:
    #             event_type: Filter by event type
    #             source: Filter by source
    #             topic: Filter by topic
    #             since: Get events since timestamp
    #             limit: Maximum number of events to return

    #         Returns:
    #             List of matching events
    #         """
    #         with self._lock:
    events = list(self._events)

    #         # Apply filters
    #         if event_type:
    #             events = [e for e in events if e.event_type == event_type]

    #         if source:
    #             events = [e for e in events if e.source == source]

    #         if topic:
    #             events = [e for e in events if e.topic == topic]

    #         if since:
    #             events = [e for e in events if e.timestamp >= since]

    #         # Apply limit
    #         if limit:
    events = events[:limit]

    #         return events

    #     def clear(self) -> None:
    #         """Clear all events from history."""
    #         with self._lock:
                self._events.clear()

    #     def get_statistics(self) -> Dict[str, Any]:
    #         """Get statistics about the event history."""
    #         with self._lock:
    events = list(self._events)

    #         if not events:
    #             return {
    #                 "total_events": 0,
    #                 "event_types": {},
    #                 "sources": {},
    #                 "topics": {},
    #                 "time_range": None,
    #             }

    event_types = defaultdict(int)
    sources = defaultdict(int)
    topics = defaultdict(int)

    #         for event in events:
    event_types[event.event_type] + = 1
    #             if event.source:
    sources[event.source] + = 1
    #             if event.topic:
    topics[event.topic] + = 1

    #         return {
                "total_events": len(events),
                "event_types": dict(event_types),
                "sources": dict(sources),
                "topics": dict(topics),
    #             "time_range": {
    #                 "earliest": min(e.timestamp for e in events),
    #                 "latest": max(e.timestamp for e in events),
    #             },
    #         }


class EventBus
    #     """
    #     Central event bus for plugin communication.

    #     This class manages event subscriptions, publishes events to handlers,
    #     and provides filtering and priority-based execution.
    #     """

    #     def __init__(self, max_queue_size: int = 1000, enable_history: bool = True):
    #         """
    #         Initialize the event bus.

    #         Args:
    #             max_queue_size: Maximum number of events to queue
    #             enable_history: Whether to enable event history
    #         """
    self._handlers: Dict[str, List[EventHandlerInfo]] = defaultdict(list)
    self._hierarchy_handlers: Dict[str, List[EventHandlerInfo]] = defaultdict(list)
    self._topic_handlers: Dict[str, List[EventHandlerInfo]] = defaultdict(list)
    self._event_queue: asyncio.Queue = asyncio.Queue(maxsize=max_queue_size)
    self._handler_count = 0
    self._processor_task: Optional[asyncio.Task] = None
    self._stop_event = asyncio.Event()
    self._logger = logging.getLogger(__name__)
    self._middlewares: List[Callable[[Event], Event]] = []
    self._event_stats: Dict[str, int] = defaultdict(int)
    self._error_count = 0
    self._lock = asyncio.Lock()

    #         # Event history
    #         self._history = EventHistory() if enable_history else None

    #         # Performance tracking
    self._performance_stats: Dict[str, Dict[str, float]] = defaultdict(
    #             lambda: {"total_time": 0.0, "call_count": 0, "avg_time": 0.0}
    #         )

    #     async def start(self) -> None:
    #         """Start the event bus processor."""
    #         if self._processor_task and not self._processor_task.done():
    #             return

            self._stop_event.clear()
    self._processor_task = asyncio.create_task(self._process_events())
            self._logger.info("Event bus started")

    #     async def stop(self) -> None:
    #         """Stop the event bus processor."""
    #         if not self._processor_task or self._processor_task.done():
    #             return

            self._stop_event.set()
            self._processor_task.cancel()
    #         try:
    #             await self._processor_task
    #         except asyncio.CancelledError:
    #             pass
            self._logger.info("Event bus stopped")

    #     def add_middleware(self, middleware: Callable[[Event], Event]) -> None:
    #         """
    #         Add an event middleware function.

    #         Args:
    #             middleware: Function that takes and returns an Event
    #         """
            self._middlewares.append(middleware)

    #     def remove_middleware(self, middleware: Callable[[Event], Event]) -> None:
    #         """
    #         Remove an event middleware function.

    #         Args:
    #             middleware: Function to remove
    #         """
    #         if middleware in self._middlewares:
                self._middlewares.remove(middleware)

    #     async def _process_events(self) -> None:
    #         """Process events from the queue."""
    #         while not self._stop_event.is_set():
    #             try:
    event = await asyncio.wait_for(self._event_queue.get(), timeout=1.0)
                    await self._dispatch_event(event)
    #             except asyncio.TimeoutError:
    #                 continue
    #             except asyncio.CancelledError:
    #                 break
    #             except Exception as e:
                    self._logger.error(f"Error processing event: {e}")
    self._error_count + = 1

    #     async def _dispatch_event(self, event: Event) -> None:
    #         """
    #         Dispatch an event to all matching handlers.

    #         Args:
    #             event: Event to dispatch
    #         """
    start_time = time.time()

    #         async with self._lock:
    #             # Apply middlewares
    #             for middleware in self._middlewares:
    #                 try:
    event = middleware(event)
    #                 except Exception as e:
                        self._logger.error(f"Error in middleware: {e}")
    #                     continue

    #         # Collect all matching handlers by priority
    matched_handlers: Dict[EventPriority, List[EventHandlerInfo]] = defaultdict(list)

    #         # Exact type matches
    #         if event.event_type in self._handlers:
    #             for handler in self._handlers[event.event_type]:
    #                 if self._handler_matches(handler, event):
                        matched_handlers[handler.priority].append(handler)

            # Wildcard matches (hierarchy-based)
    #         for event_type in self._hierarchy_handlers:
    #             if self._matches_hierarchy(event.event_type, event_type):
    #                 for handler in self._hierarchy_handlers[event_type]:
    #                     if self._handler_matches(handler, event):
                            matched_handlers[handler.priority].append(handler)

    #         # Topic-based matches
    #         if event.topic and event.topic in self._topic_handlers:
    #             for handler in self._topic_handlers[event.topic]:
    #                 if self._handler_matches(handler, event):
                        matched_handlers[handler.priority].append(handler)

    #         # Sort by priority and execute
    #         for priority in sorted(matched_handlers.keys(), reverse=True):
    #             for handler in matched_handlers[priority]:
    #                 try:
    handler_start = time.time()
                        await self._execute_handler(handler, event)

    #                     # Update handler statistics
    handler.call_count + = 1
    handler.last_called = time.time()
    handler.execution_time + = math.subtract(time.time(), handler_start)

    #                     # Update performance stats
    stats = self._performance_stats[handler.handler_id]
    stats["total_time"] + = math.subtract(time.time(), handler_start)
    stats["call_count"] + = 1
    stats["avg_time"] = stats["total_time"] / stats["call_count"]

    #                     # Remove one-time handlers
    #                     if handler.once:
                            self._remove_handler(handler)

    #                 except Exception as e:
                        self._logger.error(
    #                         f"Error executing handler {handler.handler_id}: {e}"
    #                     )
    self._error_count + = 1

    #         # Update event statistics
    self._event_stats[event.event_type] + = 1

    #         # Add to history
    #         if self._history:
                self._history.add_event(event)

    #         # Log performance if slow
    dispatch_time = math.subtract(time.time(), start_time)
    #         if dispatch_time > 0.1:  # 100ms threshold
                self._logger.warning(
    #                 f"Slow event dispatch for {event.event_type}: {dispatch_time:.3f}s"
    #             )

    #     def _matches_hierarchy(self, event_type: str, pattern: str) -> bool:
    #         """
    #         Check if an event type matches a hierarchy pattern.

    #         Args:
                event_type: Event type (e.g., "plugin.loaded")
                pattern: Pattern to match (e.g., "plugin.*")

    #         Returns:
    #             True if event type matches pattern
    #         """
    #         if not pattern.endswith("*"):
    return event_type = = pattern

    prefix = math.subtract(pattern[:, 1])
            return event_type.startswith(prefix)

    #     def _handler_matches(self, handler: EventHandlerInfo, event: Event) -> bool:
    #         """
    #         Check if a handler should receive an event.

    #         Args:
    #             handler: Handler to check
    #             event: Event to process

    #         Returns:
    #             True if handler should receive event
    #         """
    #         # Filter handlers
    #         if handler.event_type and handler.event_type != event.event_type:
    #             if not self._matches_hierarchy(event.event_type, handler.event_type):
    #                 return False

    #         # Apply custom filter if present
    #         if handler.filter_func and not handler.filter_func(event):
    #             return False

    #         return True

    #     async def _execute_handler(self, handler: EventHandlerInfo, event: Event) -> None:
    #         """
    #         Execute a handler with the given event.

    #         Args:
    #             handler: Handler to execute
    #             event: Event to pass to handler
    #         """
    #         # Prepare kwargs for handler
    kwargs = {"event": event}

    #         # Add data if handler expects it
    #         import inspect

    sig = inspect.signature(handler.callback)
    #         if "data" in sig.parameters:
    kwargs["data"] = event.data

    #         # Call the handler
    #         if asyncio.iscoroutinefunction(handler.callback):
                await handler.callback(**kwargs)
    #         else:
    #             # Run sync handlers in executor to avoid blocking
    loop = asyncio.get_event_loop()
                await loop.run_in_executor(None, lambda: handler.callback(**kwargs))

    #     def _generate_handler_id(self) -> str:
    #         """Generate a unique handler ID."""
    self._handler_count + = 1
            return f"handler_{self._handler_count}_{int(time.time())}"

    #     def _remove_handler(self, handler: EventHandlerInfo) -> None:
    #         """
    #         Remove a handler from all collections.

    #         Args:
    #             handler: Handler to remove
    #         """
    #         # Remove from exact type handlers
    #         if handler.event_type:
    self._handlers[handler.event_type] = [
    #                 h for h in self._handlers[handler.event_type]
    #                 if h.handler_id != handler.handler_id
    #             ]

    #         # Remove from hierarchy handlers
    #         for event_type, handlers in self._hierarchy_handlers.items():
    self._hierarchy_handlers[event_type] = [
    #                 h for h in handlers if h.handler_id != handler.handler_id
    #             ]

    #         # Remove from topic handlers
    #         if handler.topic:
    self._topic_handlers[handler.topic] = [
    #                 h for h in self._topic_handlers[handler.topic]
    #                 if h.handler_id != handler.handler_id
    #             ]

    #     def on(
    #         self,
    #         event_type: str,
    #         callback: Union[EventHandler, AsyncEventHandler],
    priority: EventPriority = EventPriority.NORMAL,
    once: bool = False,
    plugin_id: Optional[str] = None,
    filter_func: Optional[Callable[[Event], bool]] = None,
    #     ) -> str:
    #         """
    #         Subscribe to events of a specific type.

    #         Args:
    #             event_type: Type of event to handle
    #             callback: Function to call when event occurs
    #             priority: Handler priority
    #             once: Whether handler should be removed after first call
    #             plugin_id: Optional plugin ID owning this handler
    #             filter_func: Optional custom filter function

    #         Returns:
    #             Handler ID that can be used to unsubscribe
    #         """
    handler_id = self._generate_handler_id()
    handler = EventHandlerInfo(
    handler_id = handler_id,
    callback = callback,
    priority = priority,
    once = once,
    plugin_id = plugin_id,
    event_type = event_type,
    filter_func = filter_func,
    #         )

            self._handlers[event_type].append(handler)

    #         # Sort handlers by priority
    self._handlers[event_type].sort(key = lambda h: h.priority.value, reverse=True)

    #         return handler_id

    #     def on_any(
    #         self,
    #         callback: Union[EventHandler, AsyncEventHandler],
    priority: EventPriority = EventPriority.NORMAL,
    topic: Optional[str] = None,
    plugin_id: Optional[str] = None,
    filter_func: Optional[Callable[[Event], bool]] = None,
    #     ) -> str:
    #         """
    #         Subscribe to all events that match a filter.

    #         Args:
    #             callback: Function to call when event occurs
    #             priority: Handler priority
    #             topic: Topic filter
    #             plugin_id: Optional plugin ID owning this handler
    #             filter_func: Optional custom filter function

    #         Returns:
    #             Handler ID that can be used to unsubscribe
    #         """
    handler_id = self._generate_handler_id()
    event_type = f"any_{handler_id}"  # Unique event type

    handler = EventHandlerInfo(
    handler_id = handler_id,
    callback = callback,
    priority = priority,
    plugin_id = plugin_id,
    event_type = event_type,
    filter_func = filter_func,
    #         )

    #         if topic:
    handler.topic = topic
                self._topic_handlers[topic].append(handler)
                self._topic_handlers[topic].sort(
    key = lambda h: h.priority.value, reverse=True
    #             )
    #         else:
    #             # Special wildcard handler
                self._hierarchy_handlers[event_type].append(handler)

    #         return handler_id

    #     def off(self, handler_id: str) -> None:
    #         """
    #         Unsubscribe a handler.

    #         Args:
    #             handler_id: ID of handler to remove
    #         """
    #         async def _remove():
    #             async with self._lock:
    #                 # Find and remove handler
    #                 for event_type, handlers in self._handlers.items():
    #                     for handler in handlers:
    #                         if handler.handler_id == handler_id:
                                self._handlers[event_type].remove(handler)
    #                             return

    #                 # Check hierarchy handlers
    #                 for event_type, handlers in self._hierarchy_handlers.items():
    #                     for handler in handlers:
    #                         if handler.handler_id == handler_id:
                                self._hierarchy_handlers[event_type].remove(handler)
    #                             return

    #                 # Check topic handlers
    #                 for topic, handlers in self._topic_handlers.items():
    #                     for handler in handlers:
    #                         if handler.handler_id == handler_id:
                                self._topic_handlers[topic].remove(handler)
    #                             return

    #         # Run synchronously if we're not in an async context
    #         try:
    loop = asyncio.get_event_loop()
    #             if loop.is_running():
                    asyncio.create_task(_remove())
    #             else:
                    loop.run_until_complete(_remove())
    #         except RuntimeError:
    #             # No event loop, run synchronously
    #             pass

    #     async def emit(
    #         self,
    #         event_type: str,
    data: Any = None,
    source: Optional[str] = None,
    metadata: Optional[Dict[str, Any]] = None,
    topic: Optional[str] = None,
    #     ) -> None:
    #         """
    #         Publish an event to all handlers.

    #         Args:
    #             event_type: Type of event to publish
    #             data: Event data
    #             source: Optional source of event
    #             metadata: Optional metadata dictionary
    #             topic: Optional topic for event
    #         """
    event = Event(
    event_type = event_type,
    data = data,
    source = source,
    topic = topic,
    metadata = metadata or {},
    #         )

    #         async with self._lock:
    #             if self._event_queue.full():
                    self._logger.warning("Event queue is full, dropping event")
    #                 return

                await self._event_queue.put(event)

    #     def get_event_stats(self) -> Dict[str, int]:
    #         """
    #         Get statistics about events processed.

    #         Returns:
    #             Dictionary with event type counts
    #         """
            return dict(self._event_stats)

    #     def get_handler_count(self) -> int:
    #         """
    #         Get total number of active handlers.

    #         Returns:
    #             Number of handlers
    #         """
    total = 0
    #         for handlers in self._handlers.values():
    total + = len(handlers)
    #         return total

    #     def get_performance_stats(self) -> Dict[str, Dict[str, float]]:
    #         """
    #         Get performance statistics for handlers.

    #         Returns:
    #             Dictionary of handler ID to performance stats
    #         """
            return dict(self._performance_stats)

    #     def get_history(self) -> Optional[EventHistory]:
    #         """
    #         Get the event history instance.

    #         Returns:
    #             EventHistory instance or None if disabled
    #         """
    #         return self._history

    #     def clear_handlers(self) -> None:
    #         """Clear all event handlers."""
            self._handlers.clear()
            self._hierarchy_handlers.clear()
            self._topic_handlers.clear()
            self._performance_stats.clear()