# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Real Native Windows Window Manager for NoodleCore Desktop GUI Framework
#
# This replaces the mock WindowManager with actual Windows API functionality
# for creating, managing, and controlling native Windows windows.
# """

import typing
import dataclasses
import enum
import logging
import uuid
import time
import threading
import platform

# Import Windows API integration
import .windows_api.(
#     user32, kernel32, gdi32,
#     WNDCLASS, MSG, POINT, RECT, PAINTSTRUCT,
#     WS_OVERLAPPEDWINDOW, WS_CAPTION, WS_SYSMENU, WS_THICKFRAME,
#     WS_MINIMIZEBOX, WS_MAXIMIZEBOX, WS_EX_WINDOWEDGE, WS_EX_APPWINDOW,
#     WM_CREATE, WM_DESTROY, WM_MOVE, WM_SIZE, WM_SETFOCUS, WM_KILLFOCUS,
#     WM_PAINT, WM_CLOSE, WM_QUIT, WM_KEYDOWN, WM_KEYUP, WM_CHAR,
#     WM_LBUTTONDOWN, WM_LBUTTONUP, WM_LBUTTONDBLCLK,
#     WM_RBUTTONDOWN, WM_RBUTTONUP, WM_RBUTTONDBLCLK, WM_MOUSEMOVE,
#     MK_LBUTTON, MK_RBUTTON, MK_MBUTTON,
#     GetModuleHandle, GetWindowLongPtr, SetWindowLongPtr,
#     RGB, window_proc_wrapper, safe_api_call
# )

import ...desktop.GUIConfig,


class WindowState(Enum)
    #     # """Window state enumeration."""
    NORMAL = "normal"
    MINIMIZED = "minimized"
    MAXIMIZED = "maximized"
    FULLSCREEN = "fullscreen"
    CLOSED = "closed"


class WindowStyle(Enum)
    #     # """Window style options."""
    DEFAULT = "default"
    BORDERLESS = "borderless"
    TOOL_WINDOW = "tool_window"
    MODAL = "modal"


# @dataclasses.dataclass
class WindowGeometry
    #     # """Window geometry information."""
    #     x: int
    #     y: int
    #     width: int
    #     height: int
    z_order: int = 0


# @dataclasses.dataclass
class WindowStyleInfo
    #     # """Window style information."""
    #     style: WindowStyle
    resizable: bool = True
    closable: bool = True
    minimizable: bool = True
    maximizable: bool = True
    has_title_bar: bool = True
    has_border: bool = True


# @dataclasses.dataclass
class WindowCreationOptions
    #     # """Options for window creation."""
    #     title: str
    #     width: int
    #     height: int
    x: int = 0
    y: int = 0
    state: WindowState = WindowState.NORMAL
    style: WindowStyle = WindowStyle.DEFAULT
    parent: str = None
    modal: bool = False
    always_on_top: bool = False
    center_on_screen: bool = True
    minimize_to_tray: bool = False


class WindowManagerError(GUIError)
    #     # """Exception raised for window manager operations."""

    #     def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
            super().__init__(message, "2001", details)


class WindowNotFoundError(WindowManagerError)
    #     # """Raised when a window is not found."""

    #     def __init__(self, window_id: str):
            super().__init__(f"Window {window_id} not found", {"window_id": window_id})


class WindowCreationFailedError(WindowManagerError)
    #     # """Raised when window creation fails."""

    #     def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
            super().__init__(f"Window creation failed: {message}", details)


# @dataclasses.dataclass
class NativeWindow
    #     # """Real native window representation using Windows API."""
    #     window_id: str
    #     handle: int  # Windows HWND
    #     geometry: WindowGeometry
    #     style_info: WindowStyleInfo
    #     creation_options: WindowCreationOptions
    is_visible: bool = True
    is_focused: bool = False
    z_order: int = 0
    created_at: float = None
    last_update: float = None
    window_class: str = None

    #     def __post_init__(self):
    #         if self.created_at is None:
    self.created_at = time.time()
    #         if self.last_update is None:
    self.last_update = time.time()


class NativeWindowManager
    #     # """
    #     # Real Native Windows Window Manager for Desktop GUI Framework.
    #     #
    #     # This class provides comprehensive window management functionality using
    #     # actual Windows API calls for window creation, positioning, state management,
    #     # and event handling.
    #     # """

    #     def __init__(self):
    #         # """Initialize the window manager."""
    self.logger = logging.getLogger(__name__)
    self._config = None
    self._windows: typing.Dict[str, NativeWindow] = {}
    self._next_z_order = 1000
    self._active_window_id = None
    self._window_registry_file = "window_registry.json"
    self._max_windows = 20

    #         # Windows API specific
    self._h_instance = None
    self._window_classes: typing.Dict[str, int] = {}  # Registered window classes
    self._window_procedures: typing.Dict[int, typing.Callable] = {}  # Window procedure callbacks
    self._message_loop_running = False
    self._message_thread = None

    #         # Event callbacks
    self._event_handlers: typing.Dict[str, typing.Callable] = {}

            self.logger.info("Native Windows Window Manager initialized")

    #     def initialize(self, config: GUIConfig):
    #         # """
    #         # Initialize the window manager with configuration.

    #         Args:
    #             config: GUI configuration
    #         """
    #         if platform.system() != "Windows":
                raise WindowManagerError("Native Windows Window Manager requires Windows platform")

    self._config = config

    #         # Get application instance handle
    self._h_instance = GetModuleHandle(None)
    #         if not self._h_instance:
                raise WindowManagerError("Failed to get application instance handle")

    #         # Start message loop in background thread
            self._start_message_loop()

            self.logger.info("Native Windows Window Manager initialized successfully")

    #     def _start_message_loop(self):
    #         # """Start the Windows message loop in a background thread."""
    #         if self._message_loop_running:
    #             return

    self._message_loop_running = True
    self._message_thread = threading.Thread(target=self._message_loop_worker, daemon=True)
            self._message_thread.start()
            self.logger.info("Windows message loop started")

    #     def _message_loop_worker(self):
    #         # """Worker function for Windows message loop."""
    #         try:
    #             from .windows_api import message_loop
    #             while self._message_loop_running:
                    message_loop()
    #         except Exception as e:
                self.logger.error(f"Message loop error: {str(e)}")
    #         finally:
    self._message_loop_running = False
                self.logger.info("Windows message loop stopped")

    #     def create_window(self, title: str, width: int, height: int,
    options: WindowCreationOptions = math.subtract(None), > str:)
    #         # """
    #         # Create a new native Windows window.

    #         Args:
    #             title: Window title
    #             width: Window width
    #             height: Window height
    #             options: Window creation options

    #         Returns:
    #             Window ID
    #         """
    #         if len(self._windows) >= self._max_windows:
                raise WindowCreationFailedError("Maximum number of windows reached")

    #         try:
    #             # Generate unique window ID and class name
    window_id = str(uuid.uuid4())
    class_name = f"NoodleCore_{window_id.replace('-', '_')}"

    #             # Create default options if not provided
    #             if options is None:
    options = WindowCreationOptions(
    title = title,
    width = width,
    height = height
    #                 )

    #             # Center window if requested
    #             if options.center_on_screen:
    screen_x, screen_y = self._get_screen_center(width, height)
    options.x = screen_x
    options.y = screen_y

    #             # Register window class
    atom = self._register_window_class(class_name, options)
    #             if not atom:
                    raise WindowCreationFailedError(f"Failed to register window class: {class_name}")

    #             # Create window
    hwnd = self._create_native_window(class_name, options)
    #             if not hwnd:
                    raise WindowCreationFailedError(f"Failed to create native window: {title}")

    #             # Create window geometry
    geometry = WindowGeometry(
    x = options.x,
    y = options.y,
    width = width,
    height = height,
    z_order = self._next_z_order
    #             )

    #             # Create window style info
    style_info = WindowStyleInfo(
    style = options.style,
    resizable = True,
    closable = True,
    minimizable = True,
    maximizable = True,
    has_title_bar = True,
    has_border = True
    #             )

    #             # Create native window object
    native_window = NativeWindow(
    window_id = window_id,
    handle = hwnd,
    geometry = geometry,
    style_info = style_info,
    creation_options = options,
    z_order = self._next_z_order,
    window_class = class_name
    #             )

    #             # Register window procedure
                self._register_window_procedure(hwnd, window_id)

    #             # Set initial window state
    #             if options.state == WindowState.MINIMIZED:
                    self.show_window(window_id)
                    self.set_window_state(window_id, WindowState.MINIMIZED)
    #             elif options.state == WindowState.MAXIMIZED:
                    self.show_window(window_id)
                    self.set_window_state(window_id, WindowState.MAXIMIZED)
    #             else:
                    self.show_window(window_id)

    #             # Register window
    self._windows[window_id] = native_window
    self._next_z_order + = 1

    #             # Save window registry
                self._save_window_registry()

    #             self.logger.info(f"Created native window '{title}' with ID: {window_id}, HWND: {hwnd}")
    #             return window_id

    #         except Exception as e:
                self.logger.error(f"Failed to create window: {str(e)}")
                raise WindowCreationFailedError(f"Window creation failed: {str(e)}", {"error": str(e)})

    #     def _register_window_class(self, class_name: str, options: WindowCreationOptions) -> int:
    #         # """Register a window class for creating windows."""
    #         try:
    #             # Define window procedure
    #             @window_proc_wrapper
    #             def window_proc(hwnd, msg, wParam, lParam):
                    return self._window_procedure_handler(hwnd, msg, wParam, lParam)

    #             # Create window class structure
    #             wnd_class = WNDCLASS()
    wnd_class.style = 0  # Default style
    wnd_class.lpfnWndProc = window_proc
    wnd_class.cbClsExtra = 0
    wnd_class.cbWndExtra = 0
    wnd_class.hInstance = self._h_instance
    wnd_class.hIcon = None  # Default icon
    wnd_class.hCursor = None  # Default cursor
    wnd_class.hbrBackground = math.add(gdi32.GetStockObject(5)  # COLOR_WINDOW, 1)
    wnd_class.lpszMenuName = None
    wnd_class.lpszClassName = class_name

    #             # Register class
    atom = user32.RegisterClassEx(ctypes.byref(wnd_class))
    #             if atom:
    self._window_classes[class_name] = atom
                    self.logger.debug(f"Registered window class: {class_name}")

    #             return atom

    #         except Exception as e:
    #             self.logger.error(f"Failed to register window class {class_name}: {str(e)}")
    #             return 0

    #     def _create_native_window(self, class_name: str, options: WindowCreationOptions) -> int:
    #         # """Create actual Windows window using CreateWindowEx."""
    #         try:
    #             # Set window styles
    style = WS_OVERLAPPEDWINDOW
    #             if not options.modal:
    style | = WS_SYSMENU

    #             # Set extended window styles
    ex_style = WS_EX_WINDOWEDGE | WS_EX_APPWINDOW
    #             if options.always_on_top:
    ex_style | = 0x00000008  # WS_EX_TOPMOST

    #             # Convert title to Unicode
    title_w = ctypes.c_wchar_p(options.title)

    #             # Create window
    hwnd = user32.CreateWindowEx(
    #                 ex_style,           # dwExStyle
    #                 class_name,         # lpClassName
    #                 title_w,            # lpWindowName
    #                 style,              # dwStyle
    #                 options.x,          # x
    #                 options.y,          # y
    #                 options.width,      # nWidth
    #                 options.height,     # nHeight
                    None,              # hWndParent (could be parent window)
    #                 None,              # hMenu
    #                 self._h_instance,   # hInstance
                    ctypes.c_void_p(0) # lpParam
    #             )

    #             if hwnd:
    #                 self.logger.debug(f"Created native window with HWND: {hwnd}")

    #             return hwnd

    #         except Exception as e:
                self.logger.error(f"Failed to create native window: {str(e)}")
    #             return 0

    #     def _register_window_procedure(self, hwnd: int, window_id: str):
    #         # """Register window procedure callback for a window."""
    #         # Store the mapping for message handling
    self._window_procedures[hwnd] = window_id

    #     def _window_procedure_handler(self, hwnd: int, msg: int, wParam: int, lParam: int) -> int:
    #         # """Main window procedure handler for all windows."""
    #         try:
    #             # Get window ID from handle
    window_id = self._window_procedures.get(hwnd)
    #             if not window_id or window_id not in self._windows:
                    return user32.DefWindowProcW(hwnd, msg, wParam, lParam)

    native_window = self._windows[window_id]

    #             # Handle different message types
    #             if msg == WM_CREATE:
                    self._on_create(native_window)
    #                 return 0
    #             elif msg == WM_DESTROY:
                    self._on_destroy(native_window)
    #                 return 0
    #             elif msg == WM_MOVE:
                    self._on_move(native_window, wParam, lParam)
    #                 return 0
    #             elif msg == WM_SIZE:
                    self._on_size(native_window, wParam, lParam)
    #                 return 0
    #             elif msg == WM_SETFOCUS:
                    self._on_set_focus(native_window)
    #                 return 0
    #             elif msg == WM_KILLFOCUS:
                    self._on_kill_focus(native_window)
    #                 return 0
    #             elif msg == WM_PAINT:
                    self._on_paint(native_window)
    #                 return 0
    #             elif msg == WM_CLOSE:
                    self._on_close(native_window)
    #                 return 0
    #             elif msg == WM_KEYDOWN:
                    self._on_key_down(native_window, wParam, lParam)
    #                 return 0
    #             elif msg == WM_KEYUP:
                    self._on_key_up(native_window, wParam, lParam)
    #                 return 0
    #             elif msg == WM_CHAR:
                    self._on_char(native_window, wParam, lParam)
    #                 return 0
    #             elif msg == WM_LBUTTONDOWN:
                    self._on_lbutton_down(native_window, wParam, lParam)
    #                 return 0
    #             elif msg == WM_LBUTTONUP:
                    self._on_lbutton_up(native_window, wParam, lParam)
    #                 return 0
    #             elif msg == WM_LBUTTONDBLCLK:
                    self._on_lbutton_double_click(native_window, wParam, lParam)
    #                 return 0
    #             elif msg == WM_RBUTTONDOWN:
                    self._on_rbutton_down(native_window, wParam, lParam)
    #                 return 0
    #             elif msg == WM_RBUTTONUP:
                    self._on_rbutton_up(native_window, wParam, lParam)
    #                 return 0
    #             elif msg == WM_MOUSEMOVE:
                    self._on_mouse_move(native_window, wParam, lParam)
    #                 return 0

    #             # Default message handling
                return user32.DefWindowProcW(hwnd, msg, wParam, lParam)

    #         except Exception as e:
    #             self.logger.error(f"Window procedure error for HWND {hwnd}: {str(e)}")
                return user32.DefWindowProcW(hwnd, msg, wParam, lParam)

    #     # Event handlers
    #     def _on_create(self, native_window: NativeWindow):
    #         # """Handle WM_CREATE message."""
            self.logger.debug(f"Window created: {native_window.window_id}")
    native_window.is_visible = True
            self._trigger_event("window_created", native_window.window_id)

    #     def _on_destroy(self, native_window: NativeWindow):
    #         # """Handle WM_DESTROY message."""
            self.logger.debug(f"Window destroyed: {native_window.window_id}")
    #         if native_window.window_id in self._windows:
    #             del self._windows[native_window.window_id]
    #         if native_window.window_class in self._window_classes:
    #             del self._window_classes[native_window.window_class]
    #         if native_window.handle in self._window_procedures:
    #             del self._window_procedures[native_window.handle]

    #         if native_window.window_id == self._active_window_id:
    self._active_window_id = None

            self._trigger_event("window_destroyed", native_window.window_id)

    #     def _on_move(self, native_window: NativeWindow, wParam: int, lParam: int):
    #         # """Handle WM_MOVE message."""
    x = lParam & 0xFFFF
    y = (lParam >> 16) & 0xFFFF
    native_window.geometry.x = x
    native_window.geometry.y = y
    native_window.last_update = time.time()
            self._trigger_event("window_moved", native_window.window_id, x, y)

    #     def _on_size(self, native_window: NativeWindow, wParam: int, lParam: int):
    #         # """Handle WM_SIZE message."""
    width = lParam & 0xFFFF
    height = (lParam >> 16) & 0xFFFF
    native_window.geometry.width = width
    native_window.geometry.height = height
    native_window.last_update = time.time()
            self._trigger_event("window_resized", native_window.window_id, width, height)

    #     def _on_set_focus(self, native_window: NativeWindow):
    #         # """Handle WM_SETFOCUS message."""
    native_window.is_focused = True
    self._active_window_id = native_window.window_id
            self._trigger_event("window_focused", native_window.window_id)

    #     def _on_kill_focus(self, native_window: NativeWindow):
    #         # """Handle WM_KILLFOCUS message."""
    native_window.is_focused = False
            self._trigger_event("window_blurred", native_window.window_id)

    #     def _on_paint(self, native_window: NativeWindow):
    #         # """Handle WM_PAINT message."""
            self._trigger_event("window_paint", native_window.window_id)

    #     def _on_close(self, native_window: NativeWindow):
    #         # """Handle WM_CLOSE message."""
            self._trigger_event("window_close", native_window.window_id)
    #         # Default behavior is to destroy the window
            self.close_window(native_window.window_id)

    #     def _on_key_down(self, native_window: NativeWindow, wParam: int, lParam: int):
    #         # """Handle WM_KEYDOWN message."""
            self._trigger_event("key_down", native_window.window_id, wParam)

    #     def _on_key_up(self, native_window: NativeWindow, wParam: int, lParam: int):
    #         # """Handle WM_KEYUP message."""
            self._trigger_event("key_up", native_window.window_id, wParam)

    #     def _on_char(self, native_window: NativeWindow, wParam: int, lParam: int):
    #         # """Handle WM_CHAR message."""
            self._trigger_event("char", native_window.window_id, chr(wParam))

    #     def _on_lbutton_down(self, native_window: NativeWindow, wParam: int, lParam: int):
    #         # """Handle WM_LBUTTONDOWN message."""
    x = lParam & 0xFFFF
    y = (lParam >> 16) & 0xFFFF
            self._trigger_event("mouse_left_down", native_window.window_id, x, y)

    #     def _on_lbutton_up(self, native_window: NativeWindow, wParam: int, lParam: int):
    #         # """Handle WM_LBUTTONUP message."""
    x = lParam & 0xFFFF
    y = (lParam >> 16) & 0xFFFF
            self._trigger_event("mouse_left_up", native_window.window_id, x, y)

    #     def _on_lbutton_double_click(self, native_window: NativeWindow, wParam: int, lParam: int):
    #         # """Handle WM_LBUTTONDBLCLK message."""
    x = lParam & 0xFFFF
    y = (lParam >> 16) & 0xFFFF
            self._trigger_event("mouse_left_double_click", native_window.window_id, x, y)

    #     def _on_rbutton_down(self, native_window: NativeWindow, wParam: int, lParam: int):
    #         # """Handle WM_RBUTTONDOWN message."""
    x = lParam & 0xFFFF
    y = (lParam >> 16) & 0xFFFF
            self._trigger_event("mouse_right_down", native_window.window_id, x, y)

    #     def _on_rbutton_up(self, native_window: NativeWindow, wParam: int, lParam: int):
    #         # """Handle WM_RBUTTONUP message."""
    x = lParam & 0xFFFF
    y = (lParam >> 16) & 0xFFFF
            self._trigger_event("mouse_right_up", native_window.window_id, x, y)

    #     def _on_mouse_move(self, native_window: NativeWindow, wParam: int, lParam: int):
    #         # """Handle WM_MOUSEMOVE message."""
    x = lParam & 0xFFFF
    y = (lParam >> 16) & 0xFFFF
            self._trigger_event("mouse_move", native_window.window_id, x, y)

    #     def _trigger_event(self, event_type: str, window_id: str, *args):
    #         # """Trigger event handlers for window events."""
    event_name = f"on_{event_type}"
    handler = self._event_handlers.get(event_name)
    #         if handler:
    #             try:
                    handler(window_id, *args)
    #             except Exception as e:
    #                 self.logger.error(f"Event handler error for {event_name}: {str(e)}")

    #     def close_window(self, window_id: str):
    #         # """
    #         # Close a window.

    #         Args:
    #             window_id: Window ID to close
    #         """
    #         if window_id not in self._windows:
                raise WindowNotFoundError(window_id)

    #         try:
    native_window = self._windows[window_id]
    hwnd = native_window.handle

    #             # Send WM_CLOSE message
                safe_api_call(
    #                 user32.SendMessageW,
    #                 hwnd, WM_CLOSE, 0, 0,
    operation = f"send WM_CLOSE to window {window_id}"
    #             )

                self.logger.info(f"Closed window: {window_id}")

    #         except Exception as e:
                self.logger.error(f"Failed to close window {window_id}: {str(e)}")
                raise WindowManagerError(f"Failed to close window: {str(e)}", {"window_id": window_id})

    #     def show_window(self, window_id: str):
    #         # """Show a window."""
    #         if window_id not in self._windows:
                raise WindowNotFoundError(window_id)

    #         try:
    native_window = self._windows[window_id]
    hwnd = native_window.handle
    native_window.is_visible = True
    native_window.last_update = time.time()

    #             # Show window using Windows API
                safe_api_call(
    #                 user32.ShowWindow,
    #                 hwnd, 1,  # SW_SHOWNORMAL
    operation = f"show window {window_id}"
    #             )

    #             # Force window update
                safe_api_call(
    #                 user32.UpdateWindow,
    #                 hwnd,
    operation = f"update window {window_id}"
    #             )

                self.logger.debug(f"Showed window: {window_id}")

    #         except Exception as e:
                self.logger.error(f"Failed to show window {window_id}: {str(e)}")
                raise WindowManagerError(f"Failed to show window: {str(e)}", {"window_id": window_id})

    #     def hide_window(self, window_id: str):
    #         # """Hide a window."""
    #         if window_id not in self._windows:
                raise WindowNotFoundError(window_id)

    #         try:
    native_window = self._windows[window_id]
    hwnd = native_window.handle
    native_window.is_visible = False
    native_window.last_update = time.time()

    #             # Hide window using Windows API
                safe_api_call(
    #                 user32.ShowWindow,
    #                 hwnd, 0,  # SW_HIDE
    operation = f"hide window {window_id}"
    #             )

                self.logger.debug(f"Hid window: {window_id}")

    #         except Exception as e:
                self.logger.error(f"Failed to hide window {window_id}: {str(e)}")
                raise WindowManagerError(f"Failed to hide window: {str(e)}", {"window_id": window_id})

    #     def set_focus(self, window_id: str):
    #         # """Set focus to a window."""
    #         if window_id not in self._windows:
                raise WindowNotFoundError(window_id)

    #         try:
    native_window = self._windows[window_id]
    hwnd = native_window.handle

    #             # Update focus state for all windows
    #             for wid, win in self._windows.items():
    win.is_focused = (wid == window_id)

    self._active_window_id = window_id
    native_window.is_focused = True
    native_window.last_update = time.time()

    #             # Set focus using Windows API
                safe_api_call(
    #                 user32.SetFocus,
    #                 hwnd,
    operation = f"set focus to window {window_id}"
    #             )

    #             # Bring to front
                safe_api_call(
    #                 user32.SetForegroundWindow,
    #                 hwnd,
    operation = f"bring to front window {window_id}"
    #             )

                self.logger.debug(f"Set focus to window: {window_id}")

    #         except Exception as e:
                self.logger.error(f"Failed to set focus to window {window_id}: {str(e)}")
                raise WindowManagerError(f"Failed to set focus: {str(e)}", {"window_id": window_id})

    #     def move_window(self, window_id: str, x: int, y: int):
    #         # """Move a window to new position."""
    #         if window_id not in self._windows:
                raise WindowNotFoundError(window_id)

    #         try:
    native_window = self._windows[window_id]
    hwnd = native_window.handle
    native_window.geometry.x = x
    native_window.geometry.y = y
    native_window.last_update = time.time()

    #             # Move window using SetWindowPos
                safe_api_call(
    #                 user32.SetWindowPos,
    #                 hwnd, None, x, y, 0, 0,
    #                 0x0001 | 0x0010,  # SWP_NOSIZE | SWP_NOZORDER
    operation = f"move window {window_id}"
    #             )

                self.logger.debug(f"Moved window {window_id} to ({x}, {y})")

    #         except Exception as e:
                self.logger.error(f"Failed to move window {window_id}: {str(e)}")
                raise WindowManagerError(f"Failed to move window: {str(e)}", {"window_id": window_id})

    #     def resize_window(self, window_id: str, width: int, height: int):
    #         # """Resize a window."""
    #         if window_id not in self._windows:
                raise WindowNotFoundError(window_id)

    #         try:
    native_window = self._windows[window_id]
    hwnd = native_window.handle
    native_window.geometry.width = width
    native_window.geometry.height = height
    native_window.last_update = time.time()

    #             # Resize window using SetWindowPos
                safe_api_call(
    #                 user32.SetWindowPos,
    #                 hwnd, None, 0, 0, width, height,
    #                 0x0002 | 0x0010,  # SWP_NOMOVE | SWP_NOZORDER
    operation = f"resize window {window_id}"
    #             )

                self.logger.debug(f"Resized window {window_id} to {width}x{height}")

    #         except Exception as e:
                self.logger.error(f"Failed to resize window {window_id}: {str(e)}")
                raise WindowManagerError(f"Failed to resize window: {str(e)}", {"window_id": window_id})

    #     def set_window_state(self, window_id: str, state: WindowState):
            # """Set window state (minimized, maximized, etc.)."""
    #         if window_id not in self._windows:
                raise WindowNotFoundError(window_id)

    #         try:
    native_window = self._windows[window_id]
    hwnd = native_window.handle
    native_window.creation_options.state = state
    native_window.last_update = time.time()

    #             # Map state to Windows API constants
    show_cmd = {
    #                 WindowState.NORMAL: 1,     # SW_SHOWNORMAL
    #                 WindowState.MINIMIZED: 2,  # SW_SHOWMINIMIZED
    #                 WindowState.MAXIMIZED: 3,  # SW_SHOWMAXIMIZED
                    WindowState.FULLSCREEN: 8, # SW_RESTORE (closest to fullscreen)
    #                 WindowState.CLOSED: 0      # SW_HIDE
    #             }

    #             if state == WindowState.CLOSED:
                    self.hide_window(window_id)
    #             else:
                    safe_api_call(
    #                     user32.ShowWindow,
    #                     hwnd, show_cmd[state],
    #                     operation=f"set window state {state.value} for {window_id}"
    #                 )

                self.logger.debug(f"Set window {window_id} state to {state.value}")

    #         except Exception as e:
    #             self.logger.error(f"Failed to set window state for {window_id}: {str(e)}")
                raise WindowManagerError(f"Failed to set window state: {str(e)}", {"window_id": window_id})

    #     def get_window_geometry(self, window_id: str) -> WindowGeometry:
    #         # """Get window geometry."""
    #         if window_id not in self._windows:
                raise WindowNotFoundError(window_id)

    native_window = self._windows[window_id]

    #         # Get actual window rect from Windows API
    #         try:
    rect = RECT()
                safe_api_call(
    #                 user32.GetWindowRect,
                    native_window.handle, ctypes.byref(rect),
    #                 operation=f"get window rect for {window_id}"
    #             )

    #             # Update geometry with actual values
    native_window.geometry.x = rect.left
    native_window.geometry.y = rect.top
    native_window.geometry.width = math.subtract(rect.right, rect.left)
    native_window.geometry.height = math.subtract(rect.bottom, rect.top)

    #         except Exception as e:
    #             self.logger.warning(f"Failed to get window rect for {window_id}: {str(e)}")

    #         return native_window.geometry

    #     def get_window_state(self, window_id: str) -> WindowState:
    #         # """Get window state."""
    #         if window_id not in self._windows:
                raise WindowNotFoundError(window_id)

    #         return self._windows[window_id].creation_options.state

    #     def is_window_visible(self, window_id: str) -> bool:
    #         # """Check if window is visible."""
    #         if window_id not in self._windows:
                raise WindowNotFoundError(window_id)

    native_window = self._windows[window_id]

    #         # Check visibility using Windows API
    #         try:
                return bool(user32.IsWindowVisible(native_window.handle))
    #         except Exception as e:
    #             self.logger.warning(f"Failed to check window visibility for {window_id}: {str(e)}")
    #             return native_window.is_visible

    #     def is_window_focused(self, window_id: str) -> bool:
    #         # """Check if window is focused."""
    #         if window_id not in self._windows:
                raise WindowNotFoundError(window_id)

    #         return self._windows[window_id].is_focused

    #     def get_active_window_id(self) -> typing.Optional[str]:
    #         # """Get the currently active window ID."""
    #         return self._active_window_id

    #     def get_all_window_ids(self) -> typing.List[str]:
    #         # """Get all window IDs."""
            return list(self._windows.keys())

    #     def get_window_count(self) -> int:
    #         # """Get the number of windows."""
            return len(self._windows)

    #     def set_event_handler(self, event_type: str, handler: typing.Callable):
    #         # """
    #         # Set event handler for window events.

    #         Args:
                event_type: Type of event (e.g., 'window_created', 'mouse_click')
    #             handler: Event handler function
    #         """
    self._event_handlers[f"on_{event_type}"] = handler
            self.logger.debug(f"Set event handler for: {event_type}")

    #     async def update_window(self, window_id: str, delta_time: float):
    #         # """
    #         # Update window state.

    #         Args:
    #             window_id: Window ID to update
    #             delta_time: Time since last update
    #         """
    #         if window_id not in self._windows:
    #             return

    #         try:
    #             # Update native window (could be used for animations, etc.)
    native_window = self._windows[window_id]
    native_window.last_update = time.time()

    #             # Trigger update event
                self._trigger_event("window_update", window_id, delta_time)

    #         except Exception as e:
                self.logger.error(f"Failed to update window {window_id}: {str(e)}")

    #     def _get_screen_center(self, width: int, height: int) -> typing.Tuple[int, int]:
    #         # """Get screen center coordinates for a window of given size."""
    #         try:
    #             # Get primary monitor dimensions
    user32.GetSystemMetrics.restype = wintypes.INT
    screen_width = user32.GetSystemMetrics(0)   # SM_CXSCREEN
    screen_height = user32.GetSystemMetrics(1)  # SM_CYSCREEN

    x = math.subtract(max(0, (screen_width, width) // 2))
    y = math.subtract(max(0, (screen_height, height) // 2))

    #             return x, y
    #         except Exception as e:
                self.logger.warning(f"Failed to get screen center: {str(e)}")
    #             return 100, 100  # Default fallback

    #     def _load_window_registry(self):
    #         # """Load saved window registry."""
    #         try:
    #             # In a real implementation, would load from file
    #             pass
    #         except Exception as e:
                self.logger.warning(f"Failed to load window registry: {str(e)}")

    #     def _save_window_registry(self):
    #         # """Save window registry."""
    #         try:
    #             # In a real implementation, would save to file
    registry_data = {
    #                 "windows": {
    #                     window_id: {
                            "creation_options": dataclasses.asdict(win.creation_options),
                            "geometry": dataclasses.asdict(win.geometry),
                            "style_info": dataclasses.asdict(win.style_info)
    #                     }
    #                     for window_id, win in self._windows.items()
    #                 },
    #                 "active_window_id": self._active_window_id,
    #                 "next_z_order": self._next_z_order
    #             }

                # Save to file (mock)
    #             with open(self._window_registry_file, 'w') as f:
    json.dump(registry_data, f, indent = 2)

    #         except Exception as e:
                self.logger.warning(f"Failed to save window registry: {str(e)}")

    #     def shutdown(self):
    #         # """Shutdown the window manager and clean up resources."""
            self.logger.info("Shutting down Native Window Manager...")

    #         # Stop message loop
    self._message_loop_running = False

    #         # Close all windows
    window_ids = list(self._windows.keys())
    #         for window_id in window_ids:
    #             try:
                    self.close_window(window_id)
    #             except Exception as e:
                    self.logger.error(f"Error closing window {window_id}: {str(e)}")

    #         # Wait for message thread to finish
    #         if self._message_thread and self._message_thread.is_alive():
    self._message_thread.join(timeout = 2.0)

    #         # Clear registries
            self._windows.clear()
            self._window_classes.clear()
            self._window_procedures.clear()
            self._event_handlers.clear()

            self.logger.info("Native Window Manager shutdown complete")