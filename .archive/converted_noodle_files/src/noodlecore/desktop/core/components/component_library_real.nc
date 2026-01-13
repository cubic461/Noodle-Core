# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Real Native Windows Component Library for NoodleCore Desktop GUI Framework
#
# This replaces the mock ComponentLibrary with actual Windows GDI-based
# GUI components like buttons, labels, text boxes, and panels.
# """

import typing
import dataclasses
import enum
import logging
import time
import platform
import typing.Dict,

# Import Windows API integration
import .windows_api.(
#     user32, kernel32, gdi32,
#     RECT, PAINTSTRUCT, POINT,
#     WM_PAINT, WM_LBUTTONDOWN, WM_LBUTTONUP, WM_MOUSEMOVE, WM_KEYDOWN, WM_KEYUP, WM_CHAR,
#     WM_SETFOCUS, WM_KILLFOCUS,
#     WS_VISIBLE, WS_DISABLED, WS_CHILD, WS_BORDER, ES_LEFT, ES_AUTOHSCROLL,
#     ES_AUTOVSCROLL, ES_MULTILINE, ES_PASSWORD, ES_READONLY,
#     safe_api_call
# )

import ...desktop.GUIConfig,


class ComponentError(GUIError)
    #     # """Exception raised for component operations."""

    #     def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
            super().__init__(message, "5001", details)


class ComponentType(enum.Enum)
    #     # """Component types enumeration."""
    BUTTON = "button"
    LABEL = "label"
    TEXTBOX = "textbox"
    PANEL = "panel"
    SCROLLBAR = "scrollbar"
    LISTBOX = "listbox"
    COMBOBOX = "combobox"
    MENU = "menu"
    WINDOW = "window"


class ComponentState(enum.Enum)
    #     # """Component state enumeration."""
    NORMAL = "normal"
    HOVER = "hover"
    ACTIVE = "active"
    DISABLED = "disabled"
    FOCUSED = "focused"
    SELECTED = "selected"


# @dataclasses.dataclass
class ComponentStyle
    #     # """Component styling information."""
    background_color: str = "white"
    text_color: str = "black"
    border_color: str = "black"
    border_width: float = 1.0
    font_name: str = "Arial"
    font_size: int = 12
    padding: float = 4.0
    margin: float = 2.0
    border_radius: float = 0.0
    enabled: bool = True
    visible: bool = True
    focusable: bool = False


# @dataclasses.dataclass
class ComponentGeometry
    #     # """Component geometry information."""
    x: float = 0.0
    y: float = 0.0
    width: float = 100.0
    height: float = 30.0
    z_index: int = 0
    #     parent_bounds: Any = None  # Rectangle for parent bounds


class NativeComponent
    #     # """
    #     # Base class for all native Windows components.
    #     #
    #     # This class provides common functionality for Windows-based GUI components
    #     # using actual Windows controls and GDI rendering.
    #     # """

    #     def __init__(self, component_id: str, component_type: ComponentType,
    geometry: ComponentGeometry, style: ComponentStyle = None):
    #         # """Initialize the component."""
    self.component_id = component_id
    self.component_type = component_type
    self.geometry = geometry
    self.style = style or ComponentStyle()

    #         # Component state
    self.state = ComponentState.NORMAL
    self.enabled = True
    self.visible = True
    self.focused = False
    self.selected = False

    #         # Windows control information
    self.window_handle = None
    self.parent_handle = None
    self.control_id = None

    #         # Event callbacks
    self._event_handlers: Dict[str, Callable] = {}

    #         # Rendering state
    self._needs_repaint = True
    self._last_paint_time = 0.0

    #         # Visual feedback
    self._hover_animation = 0.0  # 0.0 to 1.0
    self._click_animation = 0.0  # 0.0 to 1.0

    #     def create_control(self, parent_handle: int) -> bool:
    #         # """
    #         # Create the Windows control for this component.

    #         Args:
    #             parent_handle: Parent window handle

    #         Returns:
    #             True if control creation was successful
    #         """
    #         try:
    self.parent_handle = parent_handle

    #             # Create the Windows control based on component type
    #             if self.component_type == ComponentType.BUTTON:
                    return self._create_button_control()
    #             elif self.component_type == ComponentType.LABEL:
                    return self._create_label_control()
    #             elif self.component_type == ComponentType.TEXTBOX:
                    return self._create_textbox_control()
    #             elif self.component_type == ComponentType.PANEL:
                    return self._create_panel_control()
    #             elif self.component_type == ComponentType.WINDOW:
                    return self._create_window_control()
    #             else:
    #                 # Create generic control for other types
                    return self._create_generic_control()

    #         except Exception as e:
    #             logging.error(f"Failed to create control for component {self.component_id}: {str(e)}")
    #             return False

    #     def _create_button_control(self) -> bool:
    #         # """Create a Windows button control."""
    #         try:
    #             # Generate unique control ID
    self.control_id = math.subtract(user32.GetWindowLongW(self.parent_handle,, 12)  # GWL_ID)
    #             if self.control_id < 1000:
    self.control_id = 1000
    self.control_id + = 1

    #             # Create button control
    button_text = getattr(self, 'text', 'Button')
    text_w = ctypes.c_wchar_p(button_text)

    self.window_handle = user32.CreateWindowW(
    #                 "BUTTON",              # Class name
    #                 text_w,               # Window text
    #                 WS_VISIBLE | WS_CHILD | WS_TABSTOP,  # Style
                    int(self.geometry.x), # X position
                    int(self.geometry.y), # Y position
                    int(self.geometry.width),   # Width
                    int(self.geometry.height),  # Height
    #                 self.parent_handle,  # Parent
    #                 self.control_id,     # ID
                    user32.GetModuleHandleW(None),  # Instance
    #                 None                 # Param
    #             )

    #             if self.window_handle:
    #                 logging.debug(f"Created button control {self.component_id} with HWND: {self.window_handle}")
    #                 return True

    #             return False

    #         except Exception as e:
                logging.error(f"Failed to create button control: {str(e)}")
    #             return False

    #     def _create_label_control(self) -> bool:
    #         # """Create a Windows static text control."""
    #         try:
    #             # Generate unique control ID
    self.control_id = math.subtract(user32.GetWindowLongW(self.parent_handle,, 12))
    #             if self.control_id < 2000:
    self.control_id = 2000
    self.control_id + = 1

    #             # Create static control
    label_text = getattr(self, 'text', 'Label')
    text_w = ctypes.c_wchar_p(label_text)

    self.window_handle = user32.CreateWindowW(
    #                 "STATIC",              # Class name
    #                 text_w,               # Window text
    #                 WS_VISIBLE | WS_CHILD | SS_LEFT,  # Style
                    int(self.geometry.x), # X position
                    int(self.geometry.y), # Y position
                    int(self.geometry.width),   # Width
                    int(self.geometry.height),  # Height
    #                 self.parent_handle,  # Parent
    #                 self.control_id,     # ID
                    user32.GetModuleHandleW(None),  # Instance
    #                 None                 # Param
    #             )

    #             if self.window_handle:
    #                 logging.debug(f"Created label control {self.component_id} with HWND: {self.window_handle}")
    #                 return True

    #             return False

    #         except Exception as e:
                logging.error(f"Failed to create label control: {str(e)}")
    #             return False

    #     def _create_textbox_control(self) -> bool:
    #         # """Create a Windows edit control."""
    #         try:
    #             # Generate unique control ID
    self.control_id = math.subtract(user32.GetWindowLongW(self.parent_handle,, 12))
    #             if self.control_id < 3000:
    self.control_id = 3000
    self.control_id + = 1

    #             # Create edit control
    style = WS_VISIBLE | WS_CHILD | WS_TABSTOP | ES_LEFT | ES_AUTOHSCROLL
    #             if hasattr(self, 'multiline') and self.multiline:
    style | = ES_MULTILINE | ES_AUTOVSCROLL

    self.window_handle = user32.CreateWindowW(
    #                 "EDIT",                # Class name
    #                 None,                 # Window text
    #                 style,                # Style
                    int(self.geometry.x), # X position
                    int(self.geometry.y), # Y position
                    int(self.geometry.width),   # Width
                    int(self.geometry.height),  # Height
    #                 self.parent_handle,  # Parent
    #                 self.control_id,     # ID
                    user32.GetModuleHandleW(None),  # Instance
    #                 None                 # Param
    #             )

    #             if self.window_handle:
    #                 # Set initial text if provided
    #                 if hasattr(self, 'text') and self.text:
    text_w = ctypes.c_wchar_p(self.text)
                        user32.SetWindowTextW(self.window_handle, text_w)

    #                 logging.debug(f"Created textbox control {self.component_id} with HWND: {self.window_handle}")
    #                 return True

    #             return False

    #         except Exception as e:
                logging.error(f"Failed to create textbox control: {str(e)}")
    #             return False

    #     def _create_panel_control(self) -> bool:
    #         # """Create a Windows group box control."""
    #         try:
    #             # Generate unique control ID
    self.control_id = math.subtract(user32.GetWindowLongW(self.parent_handle,, 12))
    #             if self.control_id < 4000:
    self.control_id = 4000
    self.control_id + = 1

    #             # Create group box control
    panel_text = getattr(self, 'title', 'Panel')
    text_w = ctypes.c_wchar_p(panel_text)

    self.window_handle = user32.CreateWindowW(
                    "BUTTON",              # Class name (group box uses BUTTON)
    #                 text_w,               # Window text
    #                 WS_VISIBLE | WS_CHILD | BS_GROUPBOX,  # Style
                    int(self.geometry.x), # X position
                    int(self.geometry.y), # Y position
                    int(self.geometry.width),   # Width
                    int(self.geometry.height),  # Height
    #                 self.parent_handle,  # Parent
    #                 self.control_id,     # ID
                    user32.GetModuleHandleW(None),  # Instance
    #                 None                 # Param
    #             )

    #             if self.window_handle:
    #                 logging.debug(f"Created panel control {self.component_id} with HWND: {self.window_handle}")
    #                 return True

    #             return False

    #         except Exception as e:
                logging.error(f"Failed to create panel control: {str(e)}")
    #             return False

    #     def _create_window_control(self) -> bool:
    #         # """Create a window control (for top-level windows)."""
    #         # Window controls don't have a parent, so this is handled differently
    #         return True

    #     def _create_generic_control(self) -> bool:
    #         # """Create a generic control."""
    #         try:
    #             # Generate unique control ID
    self.control_id = math.subtract(user32.GetWindowLongW(self.parent_handle,, 12))
    #             if self.control_id < 5000:
    self.control_id = 5000
    self.control_id + = 1

    #             # Create static control as generic
    self.window_handle = user32.CreateWindowW(
    #                 "STATIC",              # Class name
    #                 None,                 # Window text
    #                 WS_VISIBLE | WS_CHILD,  # Style
                    int(self.geometry.x), # X position
                    int(self.geometry.y), # Y position
                    int(self.geometry.width),   # Width
                    int(self.geometry.height),  # Height
    #                 self.parent_handle,  # Parent
    #                 self.control_id,     # ID
                    user32.GetModuleHandleW(None),  # Instance
    #                 None                 # Param
    #             )

    #             if self.window_handle:
    #                 logging.debug(f"Created generic control {self.component_id} with HWND: {self.window_handle}")
    #                 return True

    #             return False

    #         except Exception as e:
                logging.error(f"Failed to create generic control: {str(e)}")
    #             return False

    #     def destroy_control(self):
    #         # """Destroy the Windows control."""
    #         try:
    #             if self.window_handle:
                    user32.DestroyWindow(self.window_handle)
    self.window_handle = None
                    logging.debug(f"Destroyed control {self.component_id}")
    #         except Exception as e:
                logging.error(f"Failed to destroy control {self.component_id}: {str(e)}")

    #     def update_control(self):
    #         # """Update the Windows control state."""
    #         try:
    #             if not self.window_handle:
    #                 return

    #             # Update position and size
    #             if hasattr(self.geometry, 'x') and hasattr(self.geometry, 'y'):
                    user32.SetWindowPos(
    #                     self.window_handle, None,
                        int(self.geometry.x), int(self.geometry.y),
                        int(self.geometry.width), int(self.geometry.height),
    #                     0x0004 | 0x0010  # SWP_NOSIZE | SWP_NOZORDER
    #                 )

    #             # Update visibility
    #             if self.visible:
                    user32.ShowWindow(self.window_handle, 5)  # SW_SHOW
    #             else:
                    user32.ShowWindow(self.window_handle, 0)  # SW_HIDE

    #             # Update enabled state
    #             user32.EnableWindow(self.window_handle, 1 if self.enabled else 0)

    #             # Update text for controls that have text
    #             if hasattr(self, 'text') and self.component_type in [ComponentType.BUTTON, ComponentType.LABEL, ComponentType.PANEL]:
    text_w = ctypes.c_wchar_p(str(self.text))
                    user32.SetWindowTextW(self.window_handle, text_w)

    self._needs_repaint = False

    #         except Exception as e:
                logging.error(f"Failed to update control {self.component_id}: {str(e)}")

    #     def paint(self, context):
    #         # """Paint the component using the rendering context."""
    #         try:
    #             if not self.visible:
    #                 return

    #             # Update animation states
                self._update_animations()

    #             # Draw based on component type
    #             if self.component_type == ComponentType.BUTTON:
                    self._paint_button(context)
    #             elif self.component_type == ComponentType.LABEL:
                    self._paint_label(context)
    #             elif self.component_type == ComponentType.TEXTBOX:
                    self._paint_textbox(context)
    #             elif self.component_type == ComponentType.PANEL:
                    self._paint_panel(context)
    #             else:
                    self._paint_generic(context)

    self._last_paint_time = time.time()
    self._needs_repaint = False

    #         except Exception as e:
                logging.error(f"Failed to paint component {self.component_id}: {str(e)}")

    #     def _paint_button(self, context):
    #         # """Paint a button component."""
    #         from .rendering.rendering_engine_real import Rectangle, Color, Font, TextAlign

    rect = Rectangle(self.geometry.x, self.geometry.y, self.geometry.width, self.geometry.height)

    #         # Determine colors based on state
    #         if not self.enabled:
    bg_color = Color(200, 200, 200)
    text_color = Color(128, 128, 128)
    #         elif self.state == ComponentState.ACTIVE:
    bg_color = Color(100, 100, 200)
    text_color = Color(255, 255, 255)
    #         elif self.state == ComponentState.HOVER:
    bg_color = Color(150, 150, 220)
    text_color = Color(255, 255, 255)
    #         else:
    bg_color = Color(120, 120, 200)
    text_color = Color(255, 255, 255)

    #         # Draw button background
    context.draw_rectangle(rect, bg_color, fill = True)

    #         # Draw button border
    border_color = Color(80, 80, 160)
    context.draw_rectangle(rect, border_color, fill = False, border_width=2.0)

    #         # Draw button text
    font = Font(self.style.font_name, self.style.font_size, bold=True)
    text_rect = Rectangle(
    #             rect.x + self.style.padding,
    #             rect.y + self.style.padding,
    #             rect.width - self.style.padding * 2,
    #             rect.height - self.style.padding * 2
    #         )

    button_text = getattr(self, 'text', 'Button')
            context.draw_text(button_text, text_rect, font, TextAlign.CENTER, text_color)

    #     def _paint_label(self, context):
    #         # """Paint a label component."""
    #         from .rendering.rendering_engine_real import Rectangle, Color, Font, TextAlign

    rect = Rectangle(self.geometry.x, self.geometry.y, self.geometry.width, self.geometry.height)

    #         # Draw label text
    font = Font(self.style.font_name, self.style.font_size)
    text_color = Color(0, 0, 0)  # Black text

    label_text = getattr(self, 'text', 'Label')
            context.draw_text(label_text, rect, font, TextAlign.LEFT, text_color)

    #     def _paint_textbox(self, context):
    #         # """Paint a textbox component."""
    #         from .rendering.rendering_engine_real import Rectangle, Color, Font, TextAlign

    rect = Rectangle(self.geometry.x, self.geometry.y, self.geometry.width, self.geometry.height)

    #         # Draw textbox background
    #         if self.focused:
    bg_color = Color(255, 255, 255)  # White when focused
    #         else:
    bg_color = Color(248, 248, 248)  # Light gray when not focused

    context.draw_rectangle(rect, bg_color, fill = True)

    #         # Draw border
    #         if self.focused:
    border_color = Color(0, 120, 215)  # Blue when focused
    #         else:
    border_color = Color(128, 128, 128)  # Gray when not focused

    context.draw_rectangle(rect, border_color, fill = False, border_width=1.0)

    #         # Draw text content (if any)
    #         if hasattr(self, 'text') and self.text:
    font = Font(self.style.font_name, self.style.font_size)
    text_color = Color(0, 0, 0)  # Black text

    text_rect = Rectangle(
    #                 rect.x + self.style.padding,
    #                 rect.y + self.style.padding,
    #                 rect.width - self.style.padding * 2,
    #                 rect.height - self.style.padding * 2
    #             )

                context.draw_text(self.text, text_rect, font, TextAlign.LEFT, text_color)

    #     def _paint_panel(self, context):
    #         # """Paint a panel component."""
    #         from .rendering.rendering_engine_real import Rectangle, Color, Font, TextAlign

    rect = Rectangle(self.geometry.x, self.geometry.y, self.geometry.width, self.geometry.height)

    #         # Draw panel background
    bg_color = Color(240, 240, 240)  # Light gray background
    context.draw_rectangle(rect, bg_color, fill = True)

    #         # Draw border
    border_color = Color(128, 128, 128)
    context.draw_rectangle(rect, border_color, fill = False, border_width=1.0)

    #         # Draw title if provided
    #         if hasattr(self, 'title') and self.title:
    font = Font(self.style.font_name, self.style.font_size, bold=True)
    text_color = Color(64, 64, 64)  # Dark gray text

    #             # Title is typically drawn above the border
    title_rect = Rectangle(
    #                 rect.x + 8,
    #                 rect.y + 2,
    #                 rect.width - 16,
    #                 16
    #             )

                context.draw_text(self.title, title_rect, font, TextAlign.LEFT, text_color)

    #     def _paint_generic(self, context):
    #         # """Paint a generic component."""
    #         from .rendering.rendering_engine_real import Rectangle, Color

    rect = Rectangle(self.geometry.x, self.geometry.y, self.geometry.width, self.geometry.height)

    #         # Draw generic background
    bg_color = Color(200, 200, 200)  # Default gray
    context.draw_rectangle(rect, bg_color, fill = True)

    #         # Draw border
    border_color = Color(128, 128, 128)
    context.draw_rectangle(rect, border_color, fill = False, border_width=1.0)

    #     def _update_animations(self):
    #         # """Update animation states."""
    #         try:
    #             # Simple animation for hover and click effects
    #             if self.state == ComponentState.HOVER:
    self._hover_animation = math.add(min(1.0, self._hover_animation, 0.1))
    #             else:
    self._hover_animation = math.subtract(max(0.0, self._hover_animation, 0.1))

    #             if self.state == ComponentState.ACTIVE:
    self._click_animation = math.add(min(1.0, self._click_animation, 0.2))
    #             else:
    self._click_animation = math.subtract(max(0.0, self._click_animation, 0.2))

    #         except Exception as e:
    #             logging.error(f"Failed to update animations for {self.component_id}: {str(e)}")

    #     def handle_event(self, event_type: str, event_data: Dict[str, Any]):
    #         # """Handle events for this component."""
    #         try:
    #             # Update component state based on events
    #             if event_type == "mouse_enter":
    self.state = ComponentState.HOVER
    self._needs_repaint = True
    #             elif event_type == "mouse_leave":
    self.state = ComponentState.NORMAL
    self._needs_repaint = True
    #             elif event_type == "mouse_down":
    self.state = ComponentState.ACTIVE
    self._needs_repaint = True
    #             elif event_type == "mouse_up":
    #                 if self.state == ComponentState.ACTIVE:
    self.state = ComponentState.NORMAL
    self._needs_repaint = True
    #             elif event_type == "focus":
    self.focused = True
    self.state = ComponentState.FOCUSED
    self._needs_repaint = True
    #             elif event_type == "blur":
    self.focused = False
    self.state = ComponentState.NORMAL
    self._needs_repaint = True

    #             # Call custom event handlers
    handler = self._event_handlers.get(event_type)
    #             if handler:
                    handler(event_data)

    #         except Exception as e:
    #             logging.error(f"Failed to handle event {event_type} for {self.component_id}: {str(e)}")

    #     def set_event_handler(self, event_type: str, handler: Callable):
    #         # """Set a custom event handler."""
    self._event_handlers[event_type] = handler
    #         logging.debug(f"Set event handler {event_type} for component {self.component_id}")

    #     def get_bounds(self) -> Dict[str, float]:
    #         # """Get component bounds."""
    #         return {
    #             "x": self.geometry.x,
    #             "y": self.geometry.y,
    #             "width": self.geometry.width,
    #             "height": self.geometry.height
    #         }

    #     def set_bounds(self, x: float, y: float, width: float, height: float):
    #         # """Set component bounds."""
    self.geometry.x = x
    self.geometry.y = y
    self.geometry.width = width
    self.geometry.height = height
    self._needs_repaint = True

    #     def set_visible(self, visible: bool):
    #         # """Set component visibility."""
    self.visible = visible
    self._needs_repaint = True

    #     def set_enabled(self, enabled: bool):
    #         # """Set component enabled state."""
    self.enabled = enabled
    #         if self.window_handle:
    #             user32.EnableWindow(self.window_handle, 1 if enabled else 0)

    #     def set_text(self, text: str):
    #         # """Set component text (for text-based components)."""
            setattr(self, 'text', text)
    #         if self.window_handle and self.component_type in [ComponentType.BUTTON, ComponentType.LABEL, ComponentType.PANEL]:
    text_w = ctypes.c_wchar_p(text)
                user32.SetWindowTextW(self.window_handle, text_w)
    self._needs_repaint = True


class NativeComponentLibrary
    #     # """
    #     # Real Native Windows Component Library.
    #     #
    #     # This class provides a comprehensive library of native Windows GUI components
    #     # that replace all mock implementations with actual Windows controls and GDI rendering.
    #     # """

    #     def __init__(self):
    #         # """Initialize the component library."""
    self.logger = logging.getLogger(__name__)
    self._config = None

    #         # Component registry
    self._components: Dict[str, NativeComponent] = {}
    self._component_counter = 0

    #         # Default component styles
    self._default_styles = {
                ComponentType.BUTTON: ComponentStyle(
    background_color = "#4A90E2",
    text_color = "#FFFFFF",
    border_color = "#2E5BBA",
    border_width = 1.0,
    font_size = 12
    #             ),
                ComponentType.LABEL: ComponentStyle(
    text_color = "#000000",
    font_size = 12
    #             ),
                ComponentType.TEXTBOX: ComponentStyle(
    background_color = "#FFFFFF",
    text_color = "#000000",
    border_color = "#CCCCCC",
    border_width = 1.0,
    font_size = 12
    #             ),
                ComponentType.PANEL: ComponentStyle(
    background_color = "#F0F0F0",
    border_color = "#CCCCCC",
    border_width = 1.0,
    font_size = 12
    #             )
    #         }

            self.logger.info("Native Windows Component Library initialized")

    #     def initialize(self, config: GUIConfig):
    #         # """
    #         # Initialize the component library with configuration.

    #         Args:
    #             config: GUI configuration
    #         """
    #         if platform.system() != "Windows":
                raise ComponentError("Native Windows Component Library requires Windows platform")

    self._config = config

    #         # Initialize component styles
            self._initialize_default_styles()

            self.logger.info("Native Windows Component Library initialized successfully")

    #     def _initialize_default_styles(self):
    #         # """Initialize default component styles."""
    #         try:
                self.logger.debug("Initializing default component styles")
    #             # Styles are already initialized in __init__

    #         except Exception as e:
                self.logger.error(f"Failed to initialize default styles: {str(e)}")

    #     def create_component(self, component_type: ComponentType, geometry: ComponentGeometry,
    style: ComponentStyle = math.multiply(None,, *kwargs) -> str:)
    #         # """
    #         # Create a new component.

    #         Args:
    #             component_type: Type of component to create
    #             geometry: Component geometry
    #             style: Component style (uses default if None)
    #             **kwargs: Additional component-specific properties

    #         Returns:
    #             Component ID
    #         """
    #         try:
    #             # Generate unique component ID
    self._component_counter + = 1
    component_id = f"{component_type.value}_{self._component_counter}"

    #             # Use default style if none provided
    #             if style is None:
    style = self._default_styles.get(component_type, ComponentStyle())

    #             # Create component
    component = NativeComponent(component_id, component_type, geometry, style)

    #             # Set additional properties from kwargs
    #             for key, value in kwargs.items():
                    setattr(component, key, value)

    #             # Register component
    self._components[component_id] = component

                self.logger.debug(f"Created component {component_id} of type {component_type.value}")
    #             return component_id

    #         except Exception as e:
                self.logger.error(f"Failed to create component: {str(e)}")
                raise ComponentError(f"Failed to create component: {str(e)}")

    #     def create_button(self, x: float, y: float, width: float, height: float,
    text: str = "Button", style: ComponentStyle = None) -> str:
    #         # """
    #         # Create a button component.

    #         Args:
    #             x: X position
    #             y: Y position
    #             width: Width
    #             height: Height
    #             text: Button text
    #             style: Button style

    #         Returns:
    #             Component ID
    #         """
    geometry = ComponentGeometry(x, y, width, height)
    return self.create_component(ComponentType.BUTTON, geometry, style, text = text)

    #     def create_label(self, x: float, y: float, width: float, height: float,
    text: str = "Label", style: ComponentStyle = None) -> str:
    #         # """
    #         # Create a label component.

    #         Args:
    #             x: X position
    #             y: Y position
    #             width: Width
    #             height: Height
    #             text: Label text
    #             style: Label style

    #         Returns:
    #             Component ID
    #         """
    geometry = ComponentGeometry(x, y, width, height)
    return self.create_component(ComponentType.LABEL, geometry, style, text = text)

    #     def create_textbox(self, x: float, y: float, width: float, height: float,
    text: str = "", multiline: bool = False, style: ComponentStyle = None) -> str:
    #         # """
    #         # Create a textbox component.

    #         Args:
    #             x: X position
    #             y: Y position
    #             width: Width
    #             height: Height
    #             text: Initial text
    #             multiline: Whether it's multiline
    #             style: Textbox style

    #         Returns:
    #             Component ID
    #         """
    geometry = ComponentGeometry(x, y, width, height)
    return self.create_component(ComponentType.TEXTBOX, geometry, style, text = text, multiline=multiline)

    #     def create_panel(self, x: float, y: float, width: float, height: float,
    title: str = "Panel", style: ComponentStyle = None) -> str:
    #         # """
    #         # Create a panel component.

    #         Args:
    #             x: X position
    #             y: Y position
    #             width: Width
    #             height: Height
    #             title: Panel title
    #             style: Panel style

    #         Returns:
    #             Component ID
    #         """
    geometry = ComponentGeometry(x, y, width, height)
    return self.create_component(ComponentType.PANEL, geometry, style, title = title)

    #     def get_component(self, component_id: str) -> Optional[NativeComponent]:
    #         # """
    #         # Get a component by ID.

    #         Args:
    #             component_id: Component ID

    #         Returns:
    #             Component or None if not found
    #         """
            return self._components.get(component_id)

    #     def remove_component(self, component_id: str):
    #         # """
    #         # Remove a component.

    #         Args:
    #             component_id: Component ID to remove
    #         """
    #         try:
    #             if component_id in self._components:
    component = self._components[component_id]
                    component.destroy_control()
    #                 del self._components[component_id]
                    self.logger.debug(f"Removed component {component_id}")
    #             else:
    #                 self.logger.warning(f"Component {component_id} not found for removal")

    #         except Exception as e:
                self.logger.error(f"Failed to remove component {component_id}: {str(e)}")

    #     def get_all_components(self) -> List[str]:
    #         # """Get all component IDs."""
            return list(self._components.keys())

    #     def get_components_by_type(self, component_type: ComponentType) -> List[str]:
    #         # """Get all components of a specific type."""
    #         return [cid for cid, comp in self._components.items() if comp.component_type == component_type]

    #     def create_controls_for_window(self, window_handle: int) -> int:
    #         # """
    #         # Create Windows controls for all components associated with a window.

    #         Args:
    #             window_handle: Window handle

    #         Returns:
    #             Number of controls created
    #         """
    created_count = 0
    #         try:
    #             for component in self._components.values():
    #                 if component.parent_handle == window_handle or component.component_type == ComponentType.WINDOW:
    #                     continue

    #                 if component.create_control(window_handle):
    created_count + = 1

    #             self.logger.debug(f"Created {created_count} controls for window {window_handle}")

    #         except Exception as e:
    #             self.logger.error(f"Failed to create controls for window {window_handle}: {str(e)}")

    #         return created_count

    #     def update_all_controls(self):
    #         # """Update all component controls."""
    #         for component in self._components.values():
                component.update_control()

    #     def paint_all_components(self, context):
    #         # """Paint all visible components."""
    #         # Sort components by z-index for proper painting order
    sorted_components = sorted(
                self._components.values(),
    key = lambda c: c.geometry.z_index
    #         )

    #         for component in sorted_components:
    #             if component.visible:
                    component.paint(context)

    #     def shutdown(self):
    #         # """Shutdown the component library and clean up resources."""
            self.logger.info("Shutting down Native Windows Component Library...")

    #         # Destroy all components
    #         for component in list(self._components.values()):
    #             try:
                    component.destroy_control()
    #             except Exception as e:
                    self.logger.error(f"Error destroying component {component.component_id}: {str(e)}")

    #         # Clear registry
            self._components.clear()

            self.logger.info("Native Windows Component Library shutdown complete")