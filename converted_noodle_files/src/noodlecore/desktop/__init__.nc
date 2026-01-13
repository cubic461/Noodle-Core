# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# NoodleCore Desktop GUI Framework
#
# This module provides the desktop GUI framework for NoodleCore applications.
# """

import typing
import dataclasses
import enum
import logging


class GUIError(Exception)
    #     """
    #     Base exception for all GUI-related errors.

    #     This class provides a consistent error handling mechanism for all desktop
    #     GUI components in the NoodleCore system.
    #     """

    #     def __init__(self, message: str, error_code: str = "9999", details: typing.Dict[str, typing.Any] = None):
    self.message = message
    self.error_code = error_code
    self.details = details or {}
            super().__init__(self.message)

    #     def __str__(self):
    #         return f"[GUI-{self.error_code}] {self.message}"

    #     def get_details(self) -> typing.Dict[str, typing.Any]:
    #         """Get additional error details."""
            return self.details.copy()


class ComponentCreationError(GUIError)
    #     """Exception raised when component creation fails."""

    #     def __init__(self, message: str, component_type: str = None, details: typing.Dict[str, typing.Any] = None):
            super().__init__(message, "1001", details)
    self.component_type = component_type


class EventHandlingError(GUIError)
    #     """Exception raised when event handling fails."""

    #     def __init__(self, message: str, event_type: str = None, details: typing.Dict[str, typing.Any] = None):
            super().__init__(message, "1002", details)
    self.event_type = event_type


class RenderingError(GUIError)
    #     """Exception raised when rendering operations fail."""

    #     def __init__(self, message: str, component_id: str = None, details: typing.Dict[str, typing.Any] = None):
            super().__init__(message, "1003", details)
    self.component_id = component_id


class WindowError(GUIError)
    #     """Exception raised when window operations fail."""

    #     def __init__(self, message: str, window_id: str = None, details: typing.Dict[str, typing.Any] = None):
            super().__init__(message, "1004", details)
    self.window_id = window_id


class ComponentNotFoundError(GUIError)
    #     """Exception raised when a component is not found."""

    #     def __init__(self, component_id: str, details: typing.Dict[str, typing.Any] = None):
            super().__init__(f"Component not found: {component_id}", "1005", details)
    self.component_id = component_id


class InvalidComponentStateError(GUIError)
    #     """Exception raised when component state is invalid."""

    #     def __init__(self, component_id: str, expected_state: str = None, details: typing.Dict[str, typing.Any] = None):
    #         message = f"Invalid component state for {component_id}"
    #         if expected_state:
    message + = f" (expected: {expected_state})"
            super().__init__(message, "1006", details)
    self.component_id = component_id
    self.expected_state = expected_state


# Basic desktop framework constants
DESKTOP_FRAMEWORK_VERSION = "1.0.0"
DEFAULT_WINDOW_WIDTH = 800
DEFAULT_WINDOW_HEIGHT = 600
DEFAULT_FONT_FAMILY = "Arial"
DEFAULT_FONT_SIZE = 12

# Color constants for themes
class Color
    #     """Basic color representation."""

    #     def __init__(self, r: float, g: float, b: float, a: float = 1.0):
    self.r = math.subtract(max(0.0, min(1.0, r))  # Clamp to 0, 1)
    self.g = max(0.0, min(1.0, g))
    self.b = max(0.0, min(1.0, b))
    self.a = max(0.0, min(1.0, a))

    #     def to_hex(self) -> str:
    #         """Convert to hex color string."""
    r_hex = f"{int(self.r * 255):02x}"
    g_hex = f"{int(self.g * 255):02x}"
    b_hex = f"{int(self.b * 255):02x}"
    #         return f"#{r_hex}{g_hex}{b_hex}"

    #     def __str__(self):
    return f"Color(r = {self.r:.2f}, g={self.g:.2f}, b={self.b:.2f}, a={self.a:.2f})"


# Common color presets
class ColorPresets
    #     """Preset colors for common UI elements."""

    #     # Theme colors
    DARK_THEME_BG = Color(0.13, 0.14, 0.17, 1.0)
    DARK_THEME_FG = Color(0.86, 0.88, 0.91, 1.0)
    LIGHT_THEME_BG = Color(1.0, 1.0, 1.0, 1.0)
    LIGHT_THEME_FG = Color(0.0, 0.0, 0.0, 1.0)

    #     # Status colors
    SUCCESS_GREEN = Color(0.2, 0.8, 0.2, 1.0)
    WARNING_YELLOW = Color(1.0, 0.8, 0.2, 1.0)
    ERROR_RED = Color(1.0, 0.2, 0.2, 1.0)
    INFO_BLUE = Color(0.2, 0.6, 1.0, 1.0)

    #     # UI element colors
    SELECTION_COLOR = Color(0.31, 0.72, 1.0, 0.3)
    BORDER_COLOR = Color(0.4, 0.4, 0.4, 1.0)
    HOVER_COLOR = Color(0.8, 0.8, 0.8, 1.0)
    DISABLED_COLOR = Color(0.6, 0.6, 0.6, 1.0)


# Basic font representation
class Font
    #     """Basic font representation."""

    #     def __init__(self, family: str = DEFAULT_FONT_FAMILY, size: int = DEFAULT_FONT_SIZE, weight: str = "normal"):
    self.family = family
    self.size = size
    self.weight = weight  # normal, bold, light

    #     def __str__(self):
    return f"Font(family = {self.family}, size={self.size}, weight={self.weight})"


# Basic geometric shapes
# @dataclasses.dataclass
class Rectangle
    #     """Rectangle geometry."""
    x: float = 0.0
    y: float = 0.0
    width: float = 0.0
    height: float = 0.0

    #     def contains_point(self, px: float, py: float) -> bool:
    #         """Check if point is inside rectangle."""
    return (self.x < = math.add(px <= self.x, self.width and)
    self.y < = math.add(py <= self.y, self.height))


# @dataclasses.dataclass
class Point
    #     """Point geometry."""
    x: float = 0.0
    y: float = 0.0

    #     def distance_to(self, other: 'Point') -> float:
    #         """Calculate distance to another point."""
    #         import math
            return math.sqrt((self.x - other.x)**2 + (self.y - other.y)**2)


# Event system basics
class EventType(enum.Enum)
    #     """Event types for the GUI system."""
    MOUSE_CLICK = "mouse_click"
    MOUSE_DOUBLE_CLICK = "mouse_double_click"
    MOUSE_MOVE = "mouse_move"
    MOUSE_DOWN = "mouse_down"
    MOUSE_UP = "mouse_up"
    KEY_PRESS = "key_press"
    KEY_RELEASE = "key_release"
    WINDOW_RESIZE = "window_resize"
    WINDOW_CLOSE = "window_close"
    COMPONENT_UPDATE = "component_update"


# Mouse event data
# @dataclasses.dataclass
class MouseEvent
    #     """Mouse event data."""
    x: float = 0.0
    y: float = 0.0
    button: int = 0
    clicks: int = 1
    timestamp: float = 0.0


# Keyboard event data
# @dataclasses.dataclass
class KeyboardEvent
    #     """Keyboard event data."""
    key: str = ""
    key_code: int = 0
    modifiers: typing.List[str] = None
    timestamp: float = 0.0

    #     def __post_init__(self):
    #         if self.modifiers is None:
    self.modifiers = []


# Export main classes for easy importing
__all__ = [
#     'GUIError',
#     'ComponentCreationError',
#     'EventHandlingError',
#     'RenderingError',
#     'WindowError',
#     'ComponentNotFoundError',
#     'InvalidComponentStateError',
#     'Color',
#     'ColorPresets',
#     'Font',
#     'Rectangle',
#     'Point',
#     'EventType',
#     'MouseEvent',
#     'KeyboardEvent'
# ]