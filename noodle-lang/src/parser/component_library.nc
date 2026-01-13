# """
# Component Library for NoodleCore Desktop GUI Framework
# 
# This module provides reusable UI components including buttons, labels, panels,
# tree views, tabs, and other interactive elements for the desktop IDE.
# """

import typing
import dataclasses
import enum
import logging
import uuid
import time

from ...desktop import GUIError
from ..rendering.rendering_engine import Color, Font, Rectangle, Point, Size


class ComponentType(Enum):
    # """Component type enumeration."""
    BUTTON = "button"
    LABEL = "label"
    PANEL = "panel"
    WINDOW = "window"
    MENU_BAR = "menu_bar"
    TOOL_BAR = "tool_bar"
    STATUS_BAR = "status_bar"
    TAB_CONTROL = "tab_control"
    TREE_VIEW = "tree_view"
    LIST_VIEW = "list_view"
    TEXT_EDIT = "text_edit"
    SCROLL_BAR = "scroll_bar"
    PROGRESS_BAR = "progress_bar"
    DIALOG = "dialog"
    MENU = "menu"
    MENU_ITEM = "menu_item"


class ComponentState(Enum):
    # """Component state enumeration."""
    NORMAL = "normal"
    HOVER = "hover"
    ACTIVE = "active"
    DISABLED = "disabled"
    FOCUSED = "focused"


class LayoutType(Enum):
    # """Layout type enumeration."""
    ABSOLUTE = "absolute"
    FLOW = "flow"
    GRID = "grid"
    BORDER = "border"
    BOX = "box"


@dataclasses.dataclass
class ComponentProperties:
    # """Base component properties."""
    component_id: str
    component_type: ComponentType
    window_id: str
    x: float = 0.0
    y: float = 0.0
    width: float = 100.0
    height: float = 30.0
    visible: bool = True
    enabled: bool = True
    z_order: int = 0
    
    # Style properties
    background_color: Color = None
    foreground_color: Color = None
    border_color: Color = None
    border_width: float = 0.0
    corner_radius: float = 0.0
    font: Font = None
    opacity: float = 1.0
    
    # State
    state: ComponentState = ComponentState.NORMAL
    
    # Events
    on_click: typing.Callable = None
    on_hover: typing.Callable = None
    on_focus: typing.Callable = None
    on_blur: typing.Callable = None
    
    # Layout
    layout_type: LayoutType = LayoutType.ABSOLUTE
    layout_data: typing.Dict[str, typing.Any] = None
    
    # Custom data
    user_data: typing.Dict[str, typing.Any] = None
    
    def __post_init__(self):
        if self.background_color is None:
            self.background_color = Color(0.2, 0.2, 0.2, 0.8)  # Dark gray
        if self.foreground_color is None:
            self.foreground_color = Color(1.0, 1.0, 1.0, 1.0)  # White
        if self.border_color is None:
            self.border_color = Color(0.3, 0.3, 0.3, 1.0)  # Dark gray
        if self.font is None:
            self.font = Font("Arial", 12, False, False, False)
        if self.layout_data is None:
            self.layout_data = {}
        if self.user_data is None:
            self.user_data = {}


@dataclasses.dataclass
class ButtonProperties(ComponentProperties):
    # """Button-specific properties."""
    text: str = "Button"
    icon: str = None
    icon_position: str = "left"  # left, right, top, bottom
    text_alignment: str = "center"  # left, center, right
    image: str = None
    checkable: bool = False
    checked: bool = False
    pressed: bool = False
    
    # Button states
    normal_color: Color = None
    hover_color: Color = None
    active_color: Color = None
    disabled_color: Color = None
    checked_color: Color = None
    
    def __post_init__(self):
        super().__post_init__()
        self.component_type = ComponentType.BUTTON
        
        if self.normal_color is None:
            self.normal_color = Color(0.3, 0.3, 0.3, 1.0)
        if self.hover_color is None:
            self.hover_color = Color(0.4, 0.4, 0.4, 1.0)
        if self.active_color is None:
            self.active_color = Color(0.2, 0.2, 0.2, 1.0)
        if self.disabled_color is None:
            self.disabled_color = Color(0.1, 0.1, 0.1, 0.5)
        if self.checked_color is None:
            self.checked_color = Color(0.5, 0.5, 0.8, 1.0)


@dataclasses.dataclass
class LabelProperties(ComponentProperties):
    # """Label-specific properties."""
    text: str = "Label"
    text_alignment: str = "left"  # left, center, right
    word_wrap: bool = False
    ellipsis: bool = False
    multi_line: bool = False
    icon: str = None
    icon_spacing: float = 4.0
    
    def __post_init__(self):
        super().__post_init__()
        self.component_type = ComponentType.LABEL


@dataclasses.dataclass
class PanelProperties(ComponentProperties):
    # """Panel-specific properties."""
    title: str = "Panel"
    title_bar: bool = True
    resizable: bool = True
    closable: bool = True
    minimizable: bool = True
    maximizable: bool = True
    collapsible: bool = False
    collapsed: bool = False
    show_border: bool = True
    padding: float = 8.0
    margin: float = 4.0
    
    def __post_init__(self):
        super().__post_init__()
        self.component_type = ComponentType.PANEL


@dataclasses.dataclass
class TabProperties(ComponentProperties):
    # """Tab control properties."""
    tabs: typing.List[str] = None
    active_tab_index: int = 0
    show_icons: bool = True
    tab_position: str = "top"  # top, bottom, left, right
    tab_style: str = "default"  # default, flat, minimal
    closable_tabs: bool = True
    
    def __post_init__(self):
        super().__post_init__()
        self.component_type = ComponentType.TAB_CONTROL
        if self.tabs is None:
            self.tabs = ["Tab 1", "Tab 2", "Tab 3"]


@dataclasses.dataclass
class TreeNode:
    # """Tree view node."""
    node_id: str
    text: str
    icon: str = None
    expanded: bool = True
    checked: bool = False
    disabled: bool = False
    parent: "TreeNode" = None
    children: typing.List["TreeNode"] = None
    user_data: typing.Dict[str, typing.Any] = None
    
    def __post_init__(self):
        if self.children is None:
            self.children = []
        if self.user_data is None:
            self.user_data = {}


@dataclasses.dataclass
class TreeViewProperties(ComponentProperties):
    # """Tree view properties."""
    root_node: TreeNode = None
    show_icons: bool = True
    show_checkboxes: bool = False
    show_lines: bool = True
    allow_multi_select: bool = False
    single_click_expand: bool = False
    auto_scroll: bool = True
    indent_width: float = 16.0
    
    def __post_init__(self):
        super().__post_init__()
        self.component_type = ComponentType.TREE_VIEW


@dataclasses.dataclass
class MenuItemProperties(ComponentProperties):
    # """Menu item properties."""
    text: str = "Menu Item"
    icon: str = None
    shortcut: str = None
    checkable: bool = False
    checked: bool = False
    separator: bool = False
    enabled: bool = True
    submenu: typing.List["MenuItemProperties"] = None
    
    def __post_init__(self):
        super().__post_init__()
        self.component_type = ComponentType.MENU_ITEM
        if self.submenu is None:
            self.submenu = []


class ComponentLibraryError(GUIError):
    # """Exception raised for component library operations."""
    
    def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
        super().__init__(message, "5001", details)


class ComponentCreationError(ComponentLibraryError):
    # """Raised when component creation fails."""
    
    def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
        super().__init__(message, "5002", details)


class ComponentNotFoundError(ComponentLibraryError):
    # """Raised when component is not found."""
    
    def __init__(self, component_id: str):
        super().__init__(f"Component {component_id} not found", {"component_id": component_id})


class ComponentLibrary:
    # """
    # Component Library for Desktop GUI Framework.
    # 
    # This class provides a comprehensive library of reusable UI components
    # for building the NoodleCore IDE interface with zero external dependencies.
    # """
    
    def __init__(self):
        # """Initialize the component library."""
        self.logger = logging.getLogger(__name__)
        self._components: typing.Dict[str, ComponentProperties] = {}
        self._component_factories: typing.Dict[ComponentType, typing.Callable] = {}
        
        # Initialize component factories
        self._initialize_component_factories()
        
        # Component metrics
        self._metrics = {
            "total_components_created": 0,
            "components_by_type": {},
            "active_components": 0
        }
    
    def _initialize_component_factories(self):
        # """Initialize component factory functions."""
        self._component_factories = {
            ComponentType.BUTTON: self._create_button,
            ComponentType.LABEL: self._create_label,
            ComponentType.PANEL: self._create_panel,
            ComponentType.TAB_CONTROL: self._create_tab_control,
            ComponentType.TREE_VIEW: self._create_tree_view,
            ComponentType.MENU_ITEM: self._create_menu_item,
        }
    
    def initialize(self):
        # """Initialize the component library."""
        self.logger.info("Component library initialized")
    
    def create_component(self, component_type: str, window_id: str, **kwargs) -> str:
        # """
        # Create a new UI component.
        
        Args:
            component_type: Type of component to create
            window_id: Window to add component to
            **kwargs: Component properties
        
        Returns:
            Component ID
        """
        try:
            # Parse component type
            try:
                comp_type = ComponentType(component_type)
            except ValueError:
                raise ComponentCreationError(f"Unknown component type: {component_type}")
            
            # Generate component ID
            component_id = str(uuid.uuid4())
            
            # Create component properties
            if comp_type in self._component_factories:
                properties = self._component_factories[comp_type](component_id, window_id, **kwargs)
            else:
                # Create generic component properties
                properties = ComponentProperties(
                    component_id=component_id,
                    component_type=comp_type,
                    window_id=window_id,
                    **kwargs
                )
            
            # Register component
            self._components[component_id] = properties
            
            # Update metrics
            self._metrics["total_components_created"] += 1
            self._metrics["active_components"] += 1
            
            type_name = comp_type.value
            if type_name not in self._metrics["components_by_type"]:
                self._metrics["components_by_type"][type_name] = 0
            self._metrics["components_by_type"][type_name] += 1
            
            self.logger.info(f"Created {component_type} component with ID: {component_id}")
            return component_id
            
        except Exception as e:
            self.logger.error(f"Failed to create component: {str(e)}")
            raise ComponentCreationError(f"Component creation failed: {str(e)}", {"error": str(e)})
    
    def get_component(self, component_id: str) -> typing.Optional[ComponentProperties]:
        # """
        # Get component properties.
        
        Args:
            component_id: Component ID
        
        Returns:
            Component properties or None if not found
        """
        return self._components.get(component_id)
    
    def update_component(self, component_id: str, **kwargs) -> bool:
        # """
        # Update component properties.
        
        Args:
            component_id: Component ID to update
            **kwargs: Properties to update
        
        Returns:
            True if successful
        """
        try:
            if component_id not in self._components:
                return False
            
            properties = self._components[component_id]
            
            # Update properties
            for key, value in kwargs.items():
                if hasattr(properties, key):
                    setattr(properties, key, value)
                else:
                    self.logger.warning(f"Unknown property: {key}")
            
            self.logger.info(f"Updated component: {component_id}")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to update component {component_id}: {str(e)}")
            return False
    
    def remove_component(self, component_id: str) -> bool:
        # """
        # Remove a component.
        
        Args:
            component_id: Component ID to remove
        
        Returns:
            True if successful
        """
        try:
            if component_id not in self._components:
                return False
            
            component = self._components[component_id]
            type_name = component.component_type.value
            
            # Remove component
            del self._components[component_id]
            
            # Update metrics
            self._metrics["active_components"] -= 1
            if type_name in self._metrics["components_by_type"]:
                self._metrics["components_by_type"][type_name] -= 1
            
            self.logger.info(f"Removed component: {component_id}")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to remove component {component_id}: {str(e)}")
            return False
    
    def get_components_by_window(self, window_id: str) -> typing.List[ComponentProperties]:
        # """
        # Get all components for a window.
        
        Args:
            window_id: Window ID
        
        Returns:
            List of component properties
        """
        return [comp for comp in self._components.values() if comp.window_id == window_id]
    
    def get_components_by_type(self, component_type: ComponentType) -> typing.List[ComponentProperties]:
        # """
        # Get all components of a specific type.
        
        Args:
            component_type: Component type
        
        Returns:
            List of component properties
        """
        return [comp for comp in self._components.values() if comp.component_type == component_type]
    
    def set_component_visibility(self, component_id: str, visible: bool) -> bool:
        # """
        # Set component visibility.
        
        Args:
            component_id: Component ID
            visible: Visibility state
        
        Returns:
            True if successful
        """
        return self.update_component(component_id, visible=visible)
    
    def set_component_enabled(self, component_id: str, enabled: bool) -> bool:
        # """
        # Set component enabled state.
        
        Args:
            component_id: Component ID
            enabled: Enabled state
        
        Returns:
            True if successful
        """
        return self.update_component(component_id, enabled=enabled)
    
    def set_component_position(self, component_id: str, x: float, y: float) -> bool:
        # """
        # Set component position.
        
        Args:
            component_id: Component ID
            x: X coordinate
            y: Y coordinate
        
        Returns:
            True if successful
        """
        return self.update_component(component_id, x=x, y=y)
    
    def set_component_size(self, component_id: str, width: float, height: float) -> bool:
        # """
        # Set component size.
        
        Args:
            component_id: Component ID
            width: Width
            height: Height
        
        Returns:
            True if successful
        """
        return self.update_component(component_id, width=width, height=height)
    
    def set_component_text(self, component_id: str, text: str) -> bool:
        # """
        # Set component text (for text-based components).
        
        Args:
            component_id: Component ID
            text: Text content
        
        Returns:
            True if successful
        """
        return self.update_component(component_id, text=text)
    
    def get_component_metrics(self) -> typing.Dict[str, typing.Any]:
        # """Get component library metrics."""
        return self._metrics.copy()
    
    # Component factory methods
    
    def _create_button(self, component_id: str, window_id: str, **kwargs) -> ButtonProperties:
        # """Create button component."""
        return ButtonProperties(
            component_id=component_id,
            component_type=ComponentType.BUTTON,
            window_id=window_id,
            **kwargs
        )
    
    def _create_label(self, component_id: str, window_id: str, **kwargs) -> LabelProperties:
        # """Create label component."""
        return LabelProperties(
            component_id=component_id,
            component_type=ComponentType.LABEL,
            window_id=window_id,
            **kwargs
        )
    
    def _create_panel(self, component_id: str, window_id: str, **kwargs) -> PanelProperties:
        # """Create panel component."""
        return PanelProperties(
            component_id=component_id,
            component_type=ComponentType.PANEL,
            window_id=window_id,
            **kwargs
        )
    
    def _create_tab_control(self, component_id: str, window_id: str, **kwargs) -> TabProperties:
        # """Create tab control component."""
        return TabProperties(
            component_id=component_id,
            component_type=ComponentType.TAB_CONTROL,
            window_id=window_id,
            **kwargs
        )
    
    def _create_tree_view(self, component_id: str, window_id: str, **kwargs) -> TreeViewProperties:
        # """Create tree view component."""
        return TreeViewProperties(
            component_id=component_id,
            component_type=ComponentType.TREE_VIEW,
            window_id=window_id,
            **kwargs
        )
    
    def _create_menu_item(self, component_id: str, window_id: str, **kwargs) -> MenuItemProperties:
        # """Create menu item component."""
        return MenuItemProperties(
            component_id=component_id,
            component_type=ComponentType.MENU_ITEM,
            window_id=window_id,
            **kwargs
        )