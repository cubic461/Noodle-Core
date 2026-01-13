# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Core components for NoodleCore Desktop GUI Framework
#
# This module provides the base classes and structures used by all desktop GUI components.
# """

import typing
import dataclasses
import enum


# ===== GUI Error Classes =====

class GUIError(Exception)
    #     """Base exception class for GUI operations."""

    #     def __init__(self, message: str, error_code: str = None, details: typing.Dict[str, typing.Any] = None):
            super().__init__(message)
    self.message = message
    self.error_code = error_code or "0000"
    self.details = details or {}

    #     def __str__(self):
    #         return f"[{self.error_code}] {self.message}"


class ComponentCreationError(GUIError)
    #     """Exception raised when component creation fails."""

    #     def __init__(self, message: str, component_type: str = None, details: typing.Dict[str, typing.Any] = None):
            super().__init__(message, "1001", details)
    self.component_type = component_type


class EventHandlingError(GUIError)
    #     """Exception raised when event handling fails."""

    #     def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
            super().__init__(message, "1002", details)


class RenderingEngineError(GUIError)
    #     """Exception raised for rendering engine operations."""

    #     def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
            super().__init__(message, "2001", details)


class WindowError(GUIError)
    #     """Exception raised for window manager operations."""

    #     def __init__(self, message: str, window_id: str = None, details: typing.Dict[str, typing.Any] = None):
            super().__init__(message, "4001", details)
    self.window_id = window_id


# ===== Event System Classes =====

class EventType(enum.Enum)
    #     """Types of GUI events."""
    MOUSE_CLICK = "mouse_click"
    MOUSE_MOVE = "mouse_move"
    MOUSE_DOWN = "mouse_down"
    MOUSE_UP = "mouse_up"
    KEY_PRESS = "key_press"
    KEY_DOWN = "key_down"
    KEY_UP = "key_up"
    WINDOW_RESIZE = "window_resize"
    WINDOW_MOVE = "window_move"
    WINDOW_CLOSE = "window_close"
    WINDOW_ACTIVATE = "window_activate"
    COMPONENT_FOCUS = "component_focus"
    COMPONENT_BLUR = "component_blur"
    TIMER = "timer"


# @dataclasses.dataclass
class MouseEvent
    #     """Mouse event data."""
    x: float = 0.0
    y: float = 0.0
    button: int = 0
    clicks: int = 1
    timestamp: float = None

    #     def __post_init__(self):
    #         import time
    #         if self.timestamp is None:
    self.timestamp = time.time()


# @dataclasses.dataclass
class KeyboardEvent
    #     """Keyboard event data."""
    key: str = ""
    key_code: int = 0
    modifiers: typing.List[str] = None
    timestamp: float = None

    #     def __post_init__(self):
    #         import time
    #         if self.timestamp is None:
    self.timestamp = time.time()
    #         if self.modifiers is None:
    self.modifiers = []


# ===== Graphics Classes =====

# @dataclasses.dataclass
class Color
    #     """RGBA color representation."""
    r: float = 0.0
    g: float = 0.0
    b: float = 0.0
    a: float = 1.0

    #     def __post_init__(self):
    #         # Clamp values to 0.0-1.0 range
    self.r = max(0.0, min(1.0, self.r))
    self.g = max(0.0, min(1.0, self.g))
    self.b = max(0.0, min(1.0, self.b))
    self.a = max(0.0, min(1.0, self.a))


# @dataclasses.dataclass
class Font
    #     """Font representation."""
    name: str = "Arial"
    size: int = 12
    bold: bool = False
    italic: bool = False
    underline: bool = False


# @dataclasses.dataclass
class Rectangle
    #     """Rectangle representation."""
    x: float = 0.0
    y: float = 0.0
    width: float = 0.0
    height: float = 0.0

    #     def contains_point(self, px: float, py: float) -> bool:
    #         """Check if a point is inside this rectangle."""
    return (self.x < = math.add(px <= self.x, self.width and)
    self.y < = math.add(py <= self.y, self.height))

    #     def intersects_with(self, other: 'Rectangle') -> bool:
    #         """Check if this rectangle intersects with another."""
            return not (self.x + self.width < other.x or
    #                    other.x + other.width < self.x or
    #                    self.y + self.height < other.y or
    #                    other.y + other.height < self.y)


# @dataclasses.dataclass
class Point
    #     """Point representation."""
    x: float = 0.0
    y: float = 0.0

    #     def distance_to(self, other: 'Point') -> float:
    #         """Calculate distance to another point."""
    #         import math
            return math.sqrt((self.x - other.x)**2 + (self.y - other.y)**2)


# ===== Export all classes =====

__all__ = [
#     # Error classes
#     'GUIError', 'ComponentCreationError', 'EventHandlingError',
#     'RenderingEngineError', 'WindowError',

#     # Event classes
#     'EventType', 'MouseEvent', 'KeyboardEvent',

#     # Graphics classes
#     'Color', 'Font', 'Rectangle', 'Point'
# ]