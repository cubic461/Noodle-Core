# Event System for Noodle IDE
# Provides language-independent event handling
# Manages all IDE events through NoodleCore APIs

import asyncio
import time
import logging
from typing import Dict, List, Optional, Any, Callable, Union
from dataclasses import dataclass, field
from enum import Enum
from collections import defaultdict, deque

class EventType(Enum)
    """IDE event types"""
    # File events
    FILE_OPENED = "file_opened"
    FILE_SAVED = "file_saved"
    FILE_CLOSED = "file_closed"
    FILE_MODIFIED = "file_modified"
    FILE_DELETED = "file_deleted"
    FILE_CREATED = "file_created"
    FILE_RENAMED = "file_renamed"
    
    # Project events
    PROJECT_OPENED = "project_opened"
    PROJECT_CLOSED = "project_closed"
    PROJECT_SAVED = "project_saved"
    PROJECT_MODIFIED = "project_modified"
    
    # Editor events
    EDITOR_CONTENT_CHANGED = "editor_content_changed"
    EDITOR_CURSOR_CHANGED = "editor_cursor_changed"
    EDITOR_SELECTION_CHANGED = "editor_selection_changed"
    EDITOR_SCROLLED = "editor_scrolled"
    EDITOR_SAVE_REQUESTED = "editor_save_requested"
    EDITOR_CLOSE_REQUESTED = "editor_close_requested"
    
    # IDE events
    IDE_STARTED = "ide_started"
    IDE_STOPPED = "ide_stopped"
    IDE_FOCUS_LOST = "ide_focus_lost"
    IDE_FOCUS_GAINED = "ide_focus_gained"
    IDE_MINIMIZED = "ide_minimized"
    IDE_RESTORED = "ide_restored"
    
    # Theme events
    THEME_CHANGED = "theme_changed"
    THEME_LOADED = "theme_loaded"
    THEME_APPLIED = "theme_applied"
    
    # Settings events
    SETTINGS_CHANGED = "settings_changed"
    SETTINGS_SAVED = "settings_saved"
    SETTINGS_LOADED = "settings_loaded"
    
    # Execution events
    CODE_EXECUTION_STARTED = "code_execution_started"
    CODE_EXECUTION_COMPLETED = "code_execution_completed"
    CODE_EXECUTION_ERROR = "code_execution_error"
    DEBUG_SESSION_STARTED = "debug_session_started"
    DEBUG_SESSION_STOPPED = "debug_session_stopped"
    
    # Error events
    ERROR_OCCURRED = "error_occurred"
    WARNING_OCCURRED = "warning_occurred"
    SYNTAX_ERROR = "syntax_error"
    RUNTIME_ERROR = "runtime_error"
    
    # UI events
    UI_COMPONENT_SHOWN = "ui_component_shown"
    UI_COMPONENT_HIDDEN = "ui_component_hidden"
    UI_DIALOG_OPENED = "ui_dialog_opened"
    UI_DIALOG_CLOSED = "ui_dialog_closed"
    UI_NOTIFICATION_SHOWN = "ui_notification_shown"

@dataclass
class IDEEvent
    """IDE event data structure"""
    event_type: EventType
    data: Dict[str, Any] = field(default_factory=dict)
    timestamp: str = field(default_factory=lambda: time.time())
    source: str = "unknown"
    id: str = field(default_factory=lambda: str(time.time()))
    priority: int = 0
    handlers_called: int = 0
    propagation_stopped: bool = False

@dataclass
class EventHandler
    """Event handler definition"""
    callback: Callable
    event_types: List[EventType]
    priority: int = 0
    once: bool = False
    enabled: bool = True
    id: str = field(default_factory=lambda: f"handler_{time.time()}")
    created_at: float = field(default_factory=time.time)

class NOODLE_EVENT_SYSTEM
    """Noodle IDE Event System
    
    Provides comprehensive event handling for the IDE.
    Supports event subscription, emission, filtering, and processing.
    All operations are handled through NoodleCore APIs.
    """

    def __init__(self):
        """Initialize the event system"""
        self.logger = logging.getLogger(__name__)
        
        # Event storage
        self.event_handlers: Dict[str, List[EventHandler]] = defaultdict(list)
        self.event_history: deque = deque(maxlen=1000)
        self.event_queue: deque = deque()
        self.pending_events: Dict[str, IDEEvent] = {}
        
        # Event system state
        self.is_running = False
        self.event_loop_task = None
        self.max_handlers_per_event = 50
        self.event_timeout = 30.0  # 30 seconds
        self.process_delay = 0.01  # 10ms delay between events
        
        # Statistics
        self.total_events_emitted = 0
        self.total_handlers_called = 0
        self.total_events_processed = 0
        self.error_count = 0
        
        # Event filtering and priorities
        self.event_filters: Dict[str, Callable] = {}
        self.default_priority = 0

    async def start(self):
        """Start the event system"""
        if self.is_running:
            return
        
        self.is_running = True
        self.event_loop_task = asyncio.create_task(self._event_processing_loop())
        
        # Emit system started event
        await self.emit(IDEEvent(
            event_type=EventType.IDE_STARTED,
            source="event_system",
            data={"system": "NoodleEventSystem", "version": "1.0"}
        ))
        
        self.logger.info("Noodle Event System started")

    async def stop(self):
        """Stop the event system"""
        if not self.is_running:
            return
        
        self.is_running = False
        
        # Cancel event loop task
        if self.event_loop_task:
            self.event_loop_task.cancel()
            try:
                await self.event_loop_task
            except asyncio.CancelledError:
                pass
        
        # Emit system stopped event
        await self.emit(IDEEvent(
            event_type=EventType.IDE_STOPPED,
            source="event_system",
            data={"system": "NoodleEventSystem"}
        ))
        
        self.logger.info("Noodle Event System stopped")

    def on(self, event_type: Union[EventType, str], callback: Callable, priority: int = 0, once: bool = False) -> str:
        """Subscribe to an event
        
        Args:
            event_type: Event type to subscribe to
            callback: Function to call when event is emitted
            priority: Handler priority (higher = called first)
            once: If True, handler is called only once
            
        Returns:
            Handler ID for unsubscription
        """
        try:
            if isinstance(event_type, str):
                event_type = EventType(event_type)
            
            handler = EventHandler(
                callback=callback,
                event_types=[event_type],
                priority=priority,
                once=once
            )
            
            self.event_handlers[event_type.value].append(handler)
            
            # Sort handlers by priority (highest first)
            self.event_handlers[event_type.value].sort(key=lambda h: h.priority, reverse=True)
            
            self.logger.debug(f"Event handler registered for {event_type.value}")
            return handler.id
            
        except Exception as e:
            self.logger.error(f"Error registering event handler: {e}")
            raise

    def on_multiple(self, event_types: List[Union[EventType, str]], callback: Callable, priority: int = 0, once: bool = False) -> str:
        """Subscribe to multiple events
        
        Args:
            event_types: Event types to subscribe to
            callback: Function to call when any event is emitted
            priority: Handler priority
            once: If True, handler is called only once
            
        Returns:
            Handler ID for unsubscription
        """
        try:
            resolved_types = []
            for event_type in event_types:
                if isinstance(event_type, str):
                    resolved_types.append(EventType(event_type))
                else:
                    resolved_types.append(event_type)
            
            handler = EventHandler(
                callback=callback,
                event_types=resolved_types,
                priority=priority,
                once=once
            )
            
            for event_type in resolved_types:
                self.event_handlers[event_type.value].append(handler)
                
                # Sort handlers by priority
                self.event_handlers[event_type.value].sort(key=lambda h: h.priority, reverse=True)
            
            self.logger.debug(f"Event handler registered for {len(resolved_types)} events")
            return handler.id
            
        except Exception as e:
            self.logger.error(f"Error registering multi-event handler: {e}")
            raise

    def off(self, handler_id: str) -> bool:
        """Unsubscribe from events
        
        Args:
            handler_id: Handler ID returned from on()
            
        Returns:
            True if handler was found and removed
        """
        try:
            removed = False
            
            for event_type, handlers in self.event_handlers.items():
                for handler in handlers:
                    if handler.id == handler_id:
                        handlers.remove(handler)
                        removed = True
                        self.logger.debug(f"Event handler removed: {handler_id}")
                        break
                
                if removed:
                    break
            
            return removed
            
        except Exception as e:
            self.logger.error(f"Error removing event handler: {e}")
            return False

    async def emit(self, event: IDEEvent) -> bool:
        """Emit an event
        
        Args:
            event: Event to emit
            
        Returns:
            True if event was successfully emitted
        """
        try:
            self.total_events_emitted += 1
            event.timestamp = time.time()
            
            # Add to history
            self.event_history.append(event)
            
            # Add to queue for processing
            self.event_queue.append(event)
            
            # Log event
            self.logger.debug(f"Event emitted: {event.event_type.value}")
            
            return True
            
        except Exception as e:
            self.error_count += 1
            self.logger.error(f"Error emitting event: {e}")
            return False

    async def emit_simple(self, event_type: EventType, data: Dict[str, Any] = None, source: str = "unknown") -> bool:
        """Emit a simple event
        
        Args:
            event_type: Event type
            data: Event data
            source: Event source
            
        Returns:
            True if event was successfully emitted
        """
        event = IDEEvent(
            event_type=event_type,
            data=data or {},
            source=source
        )
        
        return await self.emit(event)

    async def _event_processing_loop(self):
        """Main event processing loop"""
        while self.is_running:
            try:
                # Process events from queue
                while self.event_queue and self.is_running:
                    event = self.event_queue.popleft()
                    await self._process_event(event)
                
                # Small delay to prevent busy waiting
                await asyncio.sleep(self.process_delay)
                
            except asyncio.CancelledError:
                break
            except Exception as e:
                self.error_count += 1
                self.logger.error(f"Error in event processing loop: {e}")
                await asyncio.sleep(1)  # Wait before retrying

    async def _process_event(self, event: IDEEvent):
        """Process a single event"""
        try:
            self.total_events_processed += 1
            
            # Get handlers for this event type
            handlers = self.event_handlers.get(event.event_type.value, [])
            
            # Limit number of handlers called
            handlers_to_call = handlers[:self.max_handlers_per_event]
            
            event.handlers_called = len(handlers_to_call)
            
            # Call handlers
            for handler in handlers_to_call:
                if not handler.enabled:
                    continue
                
                try:
                    # Call handler
                    if asyncio.iscoroutinefunction(handler.callback):
                        await handler.callback(event)
                    else:
                        handler.callback(event)
                    
                    self.total_handlers_called += 1
                    
                    # Remove one-time handlers
                    if handler.once:
                        handler.enabled = False
                    
                    # Check if propagation was stopped
                    if event.propagation_stopped:
                        break
                        
                except Exception as e:
                    self.error_count += 1
                    self.logger.error(f"Error in event handler {handler.id}: {e}")
                    
                    # Emit error event
                    error_event = IDEEvent(
                        event_type=EventType.ERROR_OCCURRED,
                        data={
                            "original_event": event.event_type.value,
                            "handler_id": handler.id,
                            "error": str(e)
                        },
                        source="event_system",
                        priority=100  # High priority for errors
                    )
                    await self.emit(error_event)
            
            # Update event status
            event.id = f"{event.event_type.value}_{event.timestamp}_{self.total_events_processed}"
            
        except Exception as e:
            self.error_count += 1
            self.logger.error(f"Error processing event {event.event_type.value}: {e}")

    def filter_events(self, event_type: EventType, filter_func: Callable) -> str:
        """Add a filter for events of a specific type
        
        Args:
            event_type: Event type to filter
            filter_func: Filter function that takes an event and returns True/False
            
        Returns:
            Filter ID for removal
        """
        filter_id = f"{event_type.value}_filter_{time.time()}"
        self.event_filters[filter_id] = {
            "event_type": event_type,
            "filter_func": filter_func
        }
        
        return filter_id

    def remove_filter(self, filter_id: str) -> bool:
        """Remove an event filter
        
        Args:
            filter_id: Filter ID returned from filter_events
            
        Returns:
            True if filter was found and removed
        """
        if filter_id in self.event_filters:
            del self.event_filters[filter_id]
            return True
        return False

    def get_event_history(self, limit: int = 100, event_type: EventType = None) -> List[IDEEvent]:
        """Get event history
        
        Args:
            limit: Maximum number of events to return
            event_type: Filter by event type (optional)
            
        Returns:
            List of events
        """
        events = list(self.event_history)
        
        # Filter by type if specified
        if event_type:
            events = [e for e in events if e.event_type == event_type]
        
        # Return most recent events
        return events[-limit:]

    def get_event_statistics(self) -> Dict[str, Any]:
        """Get event system statistics"""
        return {
            "total_events_emitted": self.total_events_emitted,
            "total_events_processed": self.total_events_processed,
            "total_handlers_called": self.total_handlers_called,
            "error_count": self.error_count,
            "success_rate": (self.total_events_processed - self.error_count) / max(1, self.total_events_processed),
            "active_handlers": sum(len(handlers) for handlers in self.event_handlers.values()),
            "event_types_registered": len(self.event_handlers),
            "active_filters": len(self.event_filters),
            "queue_size": len(self.event_queue),
            "history_size": len(self.event_history),
            "is_running": self.is_running
        }

    def get_registered_handlers(self) -> Dict[str, List[Dict[str, Any]]]:
        """Get all registered event handlers"""
        handlers_info = {}
        
        for event_type, handlers in self.event_handlers.items():
            handlers_info[event_type] = []
            
            for handler in handlers:
                handler_info = {
                    "id": handler.id,
                    "callback": str(handler.callback),
                    "priority": handler.priority,
                    "once": handler.once,
                    "enabled": handler.enabled,
                    "created_at": handler.created_at
                }
                handlers_info[event_type].append(handler_info)
        
        return handlers_info

    def clear_handlers(self, event_type: EventType = None) -> int:
        """Clear all event handlers
        
        Args:
            event_type: Specific event type to clear (None for all)
            
        Returns:
            Number of handlers cleared
        """
        if event_type:
            cleared = len(self.event_handlers.get(event_type.value, []))
            if event_type.value in self.event_handlers:
                del self.event_handlers[event_type.value]
        else:
            cleared = sum(len(handlers) for handlers in self.event_handlers.values())
            self.event_handlers.clear()
        
        return cleared

    def clear_history(self):
        """Clear event history"""
        self.event_history.clear()

    def clear_queue(self):
        """Clear pending events from queue"""
        self.event_queue.clear()
        self.pending_events.clear()

    async def wait_for_event(self, event_type: EventType, timeout: float = None, filter_func: Callable = None) -> Optional[IDEEvent]:
        """Wait for a specific event to occur
        
        Args:
            event_type: Event type to wait for
            timeout: Maximum time to wait
            filter_func: Optional filter function
            
        Returns:
            Event if it occurred, None if timeout
        """
        timeout = timeout or self.event_timeout
        start_time = time.time()
        
        # Check existing events in history
        for event in reversed(self.event_history):
            if event.event_type == event_type:
                if filter_func is None or filter_func(event):
                    return event
                if time.time() - start_time > timeout:
                    break
        
        # Create a future for the event
        future = asyncio.Future()
        handler_id = None
        
        try:
            async def event_handler(event):
                if event.event_type == event_type:
                    if filter_func is None or filter_func(event):
                        future.set_result(event)
            
            # Register handler
            handler_id = self.on(event_type, event_handler, priority=1000)
            
            # Wait for event or timeout
            event = await asyncio.wait_for(future, timeout=timeout)
            return event
            
        except asyncio.TimeoutError:
            return None
        finally:
            # Clean up handler
            if handler_id:
                self.off(handler_id)

    def __str__(self):
        return f"NoodleEventSystem(events={self.total_events_emitted}, handlers={len(self.event_handlers)})"

    def __repr__(self):
        return f"NoodleEventSystem(processed={self.total_events_processed}, errors={self.error_count})"