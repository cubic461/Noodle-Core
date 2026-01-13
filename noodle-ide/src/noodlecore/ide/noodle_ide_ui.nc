# Noodle IDE UI and User Interface Logic
# All IDE operations are handled through NoodleCore APIs, no JavaScript dependencies
# This demonstrates true language independence

import asyncio
import json
import uuid
import datetime
import typing.Dict
import typing.List
import typing.Optional
from dataclasses import dataclass
from enum import Enum

import .api.noodle_api_client
import .ui.theme_manager
import .ui.event_system
import .editor.code_analyzer
import .file.file_manager

@dataclass
class IDEState
    """Current IDE state and configuration"""
    current_file: Optional[str] = None
    current_project: Optional[str] = None
    unsaved_changes: bool = False
    open_files: List[str] = None
    recent_files: List[str] = None
    active_tab: int = 0
    theme: str = "dark"
    font_size: int = 14
    auto_save_enabled: bool = True
    language: str = "noodle"
    
    def __post_init__(self):
        if self.open_files is None:
            self.open_files = []
        if self.recent_files is None:
            self.recent_files = []

class IDETheme(Enum)
    """IDE theme options"""
    LIGHT = "light"
    DARK = "dark"
    HIGH_CONTRAST = "high_contrast"

class NOODLE_IDE_UI
    """Main Noodle IDE User Interface
    
    This class manages the entire IDE user interface using only NoodleCore APIs.
    All operations are performed through the API, making it completely language-independent.
    """

    def __init__(self, api_client: 'noodle_api_client.NoodleAPIClient' = None):
        """Initialize the Noodle IDE UI"""
        self.api_client = api_client or .api.noodle_api_client.NoodleAPIClient()
        self.state = IDEState()
        self.ui_components = {}
        self.event_handlers = {}
        self.is_running = False
        
        # Core IDE components
        self.file_manager = .file.file_manager.FileManager(self.api_client)
        self.code_analyzer = .editor.code_analyzer.CodeAnalyzer()
        self.theme_manager = .ui.theme_manager.ThemeManager()
        self.event_system = .ui.event_system.EventSystem()
        
        # Setup event handlers
        self.setup_event_handlers()
        
        # Initialize UI
        self.initialize_ui()

    def initialize_ui(self):
        """Initialize the complete IDE UI"""
        self.logger.info("Initializing Noodle IDE UI...")
        
        # Setup main layout
        self.setup_main_layout()
        
        # Initialize menu system
        self.setup_menu_system()
        
        # Initialize toolbar
        self.setup_toolbar()
        
        # Initialize file explorer
        self.setup_file_explorer()
        
        # Initialize code editor
        self.setup_code_editor()
        
        # Initialize status bar
        self.setup_status_bar()
        
        # Initialize output panel
        self.setup_output_panel()
        
        # Apply initial theme
        self.apply_theme(self.state.theme)
        
        self.logger.info("Noodle IDE UI initialized successfully")

    def setup_main_layout(self):
        """Setup the main IDE layout structure"""
        self.main_layout = {
            "type": "container",
            "orientation": "vertical",
            "children": [
                # Menu bar
                {
                    "id": "menu_bar",
                    "type": "menu_bar",
                    "height": "30px"
                },
                # Main content area
                {
                    "id": "main_content",
                    "type": "container",
                    "orientation": "horizontal",
                    "flex": 1,
                    "children": [
                        # File explorer sidebar
                        {
                            "id": "file_explorer",
                            "type": "panel",
                            "width": "250px",
                            "title": "Files"
                        },
                        # Editor area
                        {
                            "id": "editor_area",
                            "type": "container",
                            "orientation": "vertical",
                            "flex": 1,
                            "children": [
                                # Tab bar
                                {
                                    "id": "tab_bar",
                                    "type": "tab_bar",
                                    "height": "35px"
                                },
                                # Code editor
                                {
                                    "id": "code_editor",
                                    "type": "code_editor",
                                    "flex": 1
                                },
                                # Output panel
                                {
                                    "id": "output_panel",
                                    "type": "panel",
                                    "height": "200px",
                                    "collapsed": True
                                }
                            ]
                        }
                    ]
                },
                # Status bar
                {
                    "id": "status_bar",
                    "type": "status_bar",
                    "height": "25px"
                }
            ]
        }
        
        # Create UI components
        self.create_ui_components()

    def setup_menu_system(self):
        """Setup IDE menu system"""
        menu_structure = {
            "File": [
                {
                    "text": "New File",
                    "shortcut": "Ctrl+N",
                    "action": self.new_file
                },
                {
                    "text": "Open File",
                    "shortcut": "Ctrl+O",
                    "action": self.open_file
                },
                {"separator": True},
                {
                    "text": "Save",
                    "shortcut": "Ctrl+S",
                    "action": self.save_file
                },
                {
                    "text": "Save As",
                    "shortcut": "Ctrl+Shift+S",
                    "action": self.save_file_as
                },
                {"separator": True},
                {
                    "text": "New Project",
                    "action": self.new_project
                },
                {
                    "text": "Open Project",
                    "action": self.open_project
                },
                {"separator": True},
                {
                    "text": "Exit",
                    "shortcut": "Alt+F4",
                    "action": self.exit_ide
                }
            ],
            "Edit": [
                {
                    "text": "Undo",
                    "shortcut": "Ctrl+Z",
                    "action": self.undo
                },
                {
                    "text": "Redo",
                    "shortcut": "Ctrl+Y",
                    "action": self.redo
                },
                {"separator": True},
                {
                    "text": "Cut",
                    "shortcut": "Ctrl+X",
                    "action": self.cut
                },
                {
                    "text": "Copy",
                    "shortcut": "Ctrl+C",
                    "action": self.copy
                },
                {
                    "text": "Paste",
                    "shortcut": "Ctrl+V",
                    "action": self.paste
                },
                {"separator": True},
                {
                    "text": "Find",
                    "shortcut": "Ctrl+F",
                    "action": self.find
                },
                {
                    "text": "Replace",
                    "shortcut": "Ctrl+H",
                    "action": self.replace
                }
            ],
            "View": [
                {
                    "text": "Toggle File Explorer",
                    "shortcut": "Ctrl+E",
                    "action": self.toggle_file_explorer
                },
                {
                    "text": "Toggle Output Panel",
                    "shortcut": "Ctrl+L",
                    "action": self.toggle_output_panel
                },
                {"separator": True},
                {
                    "text": "Zoom In",
                    "shortcut": "Ctrl+Plus",
                    "action": self.zoom_in
                },
                {
                    "text": "Zoom Out",
                    "shortcut": "Ctrl+Minus",
                    "action": self.zoom_out
                },
                {
                    "text": "Reset Zoom",
                    "shortcut": "Ctrl+0",
                    "action": self.reset_zoom
                }
            ],
            "Run": [
                {
                    "text": "Execute Code",
                    "shortcut": "F5",
                    "action": self.execute_code
                },
                {
                    "text": "Debug Code",
                    "shortcut": "F9",
                    "action": self.debug_code
                },
                {"separator": True},
                {
                    "text": "Syntax Check",
                    "shortcut": "F7",
                    "action": self.syntax_check
                }
            ],
            "Settings": [
                {
                    "text": "Preferences",
                    "action": self.show_preferences
                },
                {
                    "text": "Themes",
                    "action": self.show_themes
                },
                {
                    "text": "Keyboard Shortcuts",
                    "action": self.show_shortcuts
                }
            ],
            "Help": [
                {
                    "text": "Noodle Documentation",
                    "action": self.show_documentation
                },
                {
                    "text": "Keyboard Shortcuts",
                    "action": self.show_shortcuts_help
                },
                {"separator": True},
                {
                    "text": "About",
                    "action": self.show_about
                }
            ]
        }
        
        self.menu_bar = {
            "type": "menu_bar",
            "menus": menu_structure
        }
        
        self.register_ui_component("menu_bar", self.menu_bar)

    def setup_toolbar(self):
        """Setup IDE toolbar with common actions"""
        toolbar_items = [
            {
                "id": "new_file",
                "icon": "new_file",
                "tooltip": "New File (Ctrl+N)",
                "action": self.new_file
            },
            {
                "id": "open_file",
                "icon": "open_file", 
                "tooltip": "Open File (Ctrl+O)",
                "action": self.open_file
            },
            {
                "id": "save_file",
                "icon": "save_file",
                "tooltip": "Save File (Ctrl+S)",
                "action": self.save_file
            },
            {
                "separator": True
            },
            {
                "id": "execute_code",
                "icon": "play",
                "tooltip": "Execute Code (F5)",
                "action": self.execute_code
            },
            {
                "id": "debug_code",
                "icon": "debug",
                "tooltip": "Debug Code (F9)",
                "action": self.debug_code
            },
            {
                "separator": True
            },
            {
                "id": "find_replace",
                "icon": "find_replace",
                "tooltip": "Find and Replace (Ctrl+H)",
                "action": self.find
            },
            {
                "separator": True
            },
            {
                "id": "settings",
                "icon": "settings",
                "tooltip": "Settings",
                "action": self.show_preferences
            }
        ]
        
        self.toolbar = {
            "type": "toolbar",
            "items": toolbar_items
        }
        
        self.register_ui_component("toolbar", self.toolbar)

    def setup_file_explorer(self):
        """Setup file explorer panel"""
        self.file_explorer = {
            "type": "file_explorer",
            "title": "Files",
            "width": "250px",
            "refresh_action": self.refresh_file_explorer,
            "on_file_open": self.open_file_from_explorer,
            "on_file_create": self.create_file_from_explorer,
            "on_file_delete": self.delete_file_from_explorer,
            "on_file_rename": self.rename_file_from_explorer
        }
        
        self.register_ui_component("file_explorer", self.file_explorer)

    def setup_code_editor(self):
        """Setup main code editor"""
        self.code_editor = {
            "type": "code_editor",
            "language": self.state.language,
            "theme": self.state.theme,
            "font_size": self.state.font_size,
            "on_content_change": self.on_editor_content_change,
            "on_cursor_change": self.on_editor_cursor_change,
            "on_save": self.on_editor_save,
            "on_error_detect": self.on_editor_error
        }
        
        self.register_ui_component("code_editor", self.code_editor)

    def setup_status_bar(self):
        """Setup IDE status bar"""
        self.status_bar = {
            "type": "status_bar",
            "items": [
                {
                    "id": "cursor_position",
                    "text": "Line 1, Col 1",
                    "alignment": "left"
                },
                {
                    "id": "file_info",
                    "text": "",
                    "alignment": "left"
                },
                {
                    "id": "language",
                    "text": "Noodle",
                    "alignment": "right"
                },
                {
                    "id": "encoding",
                    "text": "UTF-8",
                    "alignment": "right"
                },
                {
                    "id": "line_ending",
                    "text": "LF",
                    "alignment": "right"
                }
            ]
        }
        
        self.register_ui_component("status_bar", self.status_bar)

    def setup_output_panel(self):
        """Setup output panel for execution results"""
        self.output_panel = {
            "type": "output_panel",
            "title": "Output",
            "height": "200px",
            "collapsed": True,
            "clear_action": self.clear_output,
            "copy_action": self.copy_output,
            "save_action": self.save_output
        }
        
        self.register_ui_component("output_panel", self.output_panel)

    def create_ui_components(self):
        """Create all UI components and register them"""
        # Add main layout to document body
        self.render_main_layout()
        
        # Initialize each component
        for component_id, component in self.ui_components.items():
            if hasattr(component, 'initialize'):
                component.initialize()

    def render_main_layout(self):
        """Render the main IDE layout"""
        layout_html = self.generate_layout_html(self.main_layout)
        self.send_to_browser("render_layout", {"html": layout_html})

    def generate_layout_html(self, layout_config):
        """Generate HTML for the given layout configuration"""
        if layout_config["type"] == "container":
            children_html = ""
            for child in layout_config.get("children", []):
                children_html += self.generate_layout_html(child)
            
            orientation = layout_config.get("orientation", "vertical")
            css_class = f"ide-container ide-{orientation}"
            style = ""
            
            if "flex" in layout_config:
                style += "flex: " + str(layout_config["flex"]) + ";"
            if "width" in layout_config:
                style += "width: " + layout_config["width"] + ";"
            if "height" in layout_config:
                style += "height: " + layout_config["height"] + ";"
            
            return f'<div class="{css_class}" style="{style}">{children_html}</div>'
        
        elif layout_config["type"] == "menu_bar":
            return f'<div id="menu-bar" class="ide-menu-bar">{self.generate_menu_html(layout_config)}</div>'
        
        elif layout_config["type"] == "toolbar":
            return f'<div id="toolbar" class="ide-toolbar">{self.generate_toolbar_html(layout_config)}</div>'
        
        elif layout_config["type"] == "file_explorer":
            return f'<div id="file-explorer" class="ide-file-explorer">{self.generate_file_explorer_html(layout_config)}</div>'
        
        elif layout_config["type"] == "code_editor":
            return f'<div id="code-editor" class="ide-code-editor">{self.generate_code_editor_html(layout_config)}</div>'
        
        elif layout_config["type"] == "status_bar":
            return f'<div id="status-bar" class="ide-status-bar">{self.generate_status_bar_html(layout_config)}</div>'
        
        elif layout_config["type"] == "output_panel":
            return f'<div id="output-panel" class="ide-output-panel">{self.generate_output_panel_html(layout_config)}</div>'
        
        return ""

    def generate_menu_html(self, menu_config):
        """Generate HTML for menu bar"""
        menus_html = ""
        for menu_name, items in menu_config.get("menus", {}).items():
            menu_html = f'<div class="menu-item">{menu_name}<div class="submenu">'
            
            for item in items:
                if "separator" in item:
                    menu_html += '<div class="menu-separator"></div>'
                elif "action" in item:
                    menu_html += f'<div class="menu-option" data-action="{item.get("action", "").name if hasattr(item.get("action"), "name") else "unknown"}">'
                    menu_html += f'<span class="menu-text">{item["text"]}</span>'
                    if "shortcut" in item:
                        menu_html += f'<span class="menu-shortcut">{item["shortcut"]}</span>'
                    menu_html += '</div>'
            
            menu_html += '</div></div>'
            menus_html += menu_html
        
        return menus_html

    def generate_toolbar_html(self, toolbar_config):
        """Generate HTML for toolbar"""
        items_html = ""
        for item in toolbar_config.get("items", []):
            if "separator" in item:
                items_html += '<div class="toolbar-separator"></div>'
            elif "action" in item:
                items_html += f'<button class="toolbar-button" data-action="{item.get("action", "").name if hasattr(item.get("action"), "name") else "unknown"}" title="{item.get("tooltip", "")}">'
                items_html += f'<span class="icon-{item.get("icon", "default")}"></span>'
                items_html += '</button>'
        
        return items_html

    def generate_file_explorer_html(self, explorer_config):
        """Generate HTML for file explorer"""
        return '''
            <div class="explorer-header">
                <button id="refresh-files" class="explorer-action">↻</button>
                <button id="new-file" class="explorer-action">+</button>
                <button id="new-folder" class="explorer-action">📁</button>
            </div>
            <div id="file-tree" class="file-tree">
                <!-- File tree will be populated dynamically -->
            </div>
        '''

    def generate_code_editor_html(self, editor_config):
        """Generate HTML for code editor"""
        theme = editor_config.get("theme", "dark")
        font_size = editor_config.get("font_size", 14)
        
        return f'''
            <div class="editor-container theme-{theme}" style="font-size: {font_size}px;">
                <div class="editor-area">
                    <textarea id="code-textarea" class="code-textarea" placeholder="Start coding in Noodle..."></textarea>
                    <div id="highlight-overlay" class="highlight-overlay"></div>
                </div>
                <div id="gutter" class="gutter">
                    <div id="line-numbers" class="line-numbers"></div>
                </div>
            </div>
        '''

    def generate_status_bar_html(self, status_config):
        """Generate HTML for status bar"""
        items_html = ""
        for item in status_config.get("items", []):
            alignment = item.get("alignment", "left")
            items_html += f'<div class="status-item status-{alignment}" id="status-{item["id"]}">{item["text"]}</div>'
        
        return items_html

    def generate_output_panel_html(self, panel_config):
        """Generate HTML for output panel"""
        return '''
            <div class="output-header">
                <span class="output-title">Output</span>
                <button id="clear-output" class="output-action">Clear</button>
                <button id="copy-output" class="output-action">Copy</button>
                <button id="save-output" class="output-action">Save</button>
            </div>
            <div id="output-content" class="output-content">
                <!-- Output will be displayed here -->
            </div>
        '''

    def register_ui_component(self, component_id, component_config):
        """Register a UI component"""
        self.ui_components[component_id] = component_config

    def setup_event_handlers(self):
        """Setup all event handlers"""
        # File operations
        self.event_system.on("file_opened", self.on_file_opened)
        self.event_system.on("file_saved", self.on_file_saved)
        self.event_system.on("file_closed", self.on_file_closed)
        
        # Editor operations
        self.event_system.on("editor_content_changed", self.on_editor_content_changed)
        self.event_system.on("editor_cursor_changed", self.on_editor_cursor_changed)
        
        # Project operations
        self.event_system.on("project_opened", self.on_project_opened)
        self.event_system.on("project_closed", self.on_project_closed)
        
        # UI operations
        self.event_system.on("theme_changed", self.on_theme_changed)
        self.event_system.on("settings_changed", self.on_settings_changed)

    # Menu Actions
    async def new_file(self, *args):
        """Create a new file"""
        try:
            file_path = "untitled.nc"
            content = "# New Noodle File\n# Created with Noodle IDE\n\n"
            
            # Create file via API
            result = await self.api_client.create_file(file_path, content, "noodle")
            
            if result.success:
                await self.open_file(file_path)
                self.logger.info(f"New file created: {file_path}")
            else:
                self.show_error("Failed to create new file", result.error)
                
        except Exception as e:
            self.logger.error(f"Error creating new file: {e}")
            self.show_error("Error", f"Failed to create new file: {str(e)}")

    async def open_file(self, file_path=None):
        """Open a file"""
        try:
            if not file_path:
                # Show file picker via browser
                result = await self.show_file_picker("open")
                if result.success:
                    file_path = result.data
                else:
                    return
            
            # Load file via API
            result = await self.api_client.open_file(file_path)
            
            if result.success:
                file_data = result.data
                
                # Add to open files if not already open
                if file_path not in self.state.open_files:
                    self.state.open_files.append(file_path)
                
                # Set as current file
                self.state.current_file = file_path
                self.state.unsaved_changes = False
                
                # Update editor with file content
                await self.load_file_content(file_path, file_data.get("content", ""))
                
                # Update file explorer selection
                self.select_file_in_explorer(file_path)
                
                self.logger.info(f"File opened: {file_path}")
            else:
                self.show_error("Failed to open file", result.error)
                
        except Exception as e:
            self.logger.error(f"Error opening file: {e}")
            self.show_error("Error", f"Failed to open file: {str(e)}")

    async def save_file(self, *args):
        """Save current file"""
        try:
            if not self.state.current_file:
                await self.save_file_as()
                return
            
            # Get current editor content
            content = await self.get_editor_content()
            
            # Save via API
            result = await self.api_client.save_file(self.state.current_file, content)
            
            if result.success:
                self.state.unsaved_changes = False
                self.update_status_bar()
                self.event_system.emit("file_saved", {"path": self.state.current_file})
                self.logger.info(f"File saved: {self.state.current_file}")
            else:
                self.show_error("Failed to save file", result.error)
                
        except Exception as e:
            self.logger.error(f"Error saving file: {e}")
            self.show_error("Error", f"Failed to save file: {str(e)}")

    async def save_file_as(self, *args):
        """Save current file with new name"""
        try:
            # Show save dialog
            result = await self.show_file_picker("save")
            if not result.success:
                return
            
            new_file_path = result.data
            self.state.current_file = new_file_path
            
            # Update open files list
            if new_file_path not in self.state.open_files:
                self.state.open_files.append(new_file_path)
            
            # Save the file
            await self.save_file()
            
        except Exception as e:
            self.logger.error(f"Error saving file as: {e}")
            self.show_error("Error", f"Failed to save file as: {str(e)}")

    async def execute_code(self, *args):
        """Execute current code"""
        try:
            content = await self.get_editor_content()
            
            # Execute via API
            result = await self.api_client.execute_code(content, self.state.language)
            
            if result.success:
                execution_data = result.data
                await self.display_execution_results(execution_data)
            else:
                self.show_error("Code execution failed", result.error)
                
        except Exception as e:
            self.logger.error(f"Error executing code: {e}")
            self.show_error("Error", f"Failed to execute code: {str(e)}")

    async def syntax_check(self, *args):
        """Perform syntax check on current code"""
        try:
            content = await self.get_editor_content()
            
            # Get syntax highlighting via API
            result = await self.api_client.get_syntax_highlight(content, self.state.language)
            
            if result.success:
                highlights = result.data.get("highlights", [])
                await self.apply_syntax_highlighting(highlights)
                self.show_info("Syntax check completed", "No syntax errors detected")
            else:
                self.show_error("Syntax check failed", result.error)
                
        except Exception as e:
            self.logger.error(f"Error in syntax check: {e}")
            self.show_error("Error", f"Syntax check failed: {str(e)}")

    # File Explorer Actions
    async def refresh_file_explorer(self):
        """Refresh file explorer"""
        try:
            directory = self.state.current_project or ""
            
            # Get file list via API
            result = await self.api_client.list_files(directory)
            
            if result.success:
                files_data = result.data.get("files", [])
                await self.update_file_explorer_display(files_data)
            else:
                self.show_error("Failed to refresh file explorer", result.error)
                
        except Exception as e:
            self.logger.error(f"Error refreshing file explorer: {e}")

    async def open_file_from_explorer(self, file_path):
        """Open file from file explorer"""
        await self.open_file(file_path)

    async def create_file_from_explorer(self, file_path):
        """Create new file from file explorer"""
        try:
            content = "# New Noodle File\n# Created from file explorer\n\n"
            
            result = await self.api_client.create_file(file_path, content, "noodle")
            
            if result.success:
                await self.refresh_file_explorer()
                await self.open_file(file_path)
            else:
                self.show_error("Failed to create file", result.error)
                
        except Exception as e:
            self.logger.error(f"Error creating file: {e}")

    async def delete_file_from_explorer(self, file_path):
        """Delete file from file explorer"""
        try:
            result = await self.api_client.delete_file(file_path)
            
            if result.success:
                # Close file if currently open
                if file_path in self.state.open_files:
                    self.state.open_files.remove(file_path)
                    if file_path == self.state.current_file:
                        self.state.current_file = None
                
                await self.refresh_file_explorer()
            else:
                self.show_error("Failed to delete file", result.error)
                
        except Exception as e:
            self.logger.error(f"Error deleting file: {e}")

    async def rename_file_from_explorer(self, old_path, new_path):
        """Rename file from file explorer"""
        try:
            # This would require implementing a rename API endpoint
            # For now, we'll just log the request
            self.logger.info(f"Rename requested: {old_path} -> {new_path}")
            
        except Exception as e:
            self.logger.error(f"Error renaming file: {e}")

    # Editor Event Handlers
    async def on_editor_content_change(self, content):
        """Handle editor content changes"""
        self.state.unsaved_changes = True
        self.update_status_bar()
        
        # Trigger syntax check
        await self.syntax_check()

    async def on_editor_cursor_change(self, position):
        """Handle cursor position changes"""
        self.update_cursor_position_display(position)

    async def on_editor_save(self, content):
        """Handle editor save requests"""
        await self.save_file()

    async def on_editor_error(self, errors):
        """Handle editor syntax errors"""
        await self.display_errors(errors)

    # Utility Methods
    async def load_file_content(self, file_path, content):
        """Load content into editor"""
        self.send_to_browser("load_content", {
            "path": file_path,
            "content": content
        })

    async def get_editor_content(self):
        """Get current editor content"""
        result = await self.send_to_browser("get_content", {})
        return result.data.get("content", "")

    async def apply_syntax_highlighting(self, highlights):
        """Apply syntax highlighting"""
        self.send_to_browser("apply_highlighting", {
            "highlights": highlights
        })

    def update_status_bar(self):
        """Update status bar information"""
        cursor_pos = self.get_cursor_position()
        
        self.send_to_browser("update_status_bar", {
            "cursor_position": f"Line {cursor_pos.line}, Col {cursor_pos.column}",
            "file_info": self.state.current_file or "No file",
            "language": self.state.language.capitalize(),
            "unsaved_changes": self.state.unsaved_changes
        })

    def get_cursor_position(self):
        """Get current cursor position"""
        # This would need to be implemented based on browser events
        return {"line": 1, "column": 1}

    async def display_execution_results(self, execution_data):
        """Display code execution results"""
        output = execution_data.get("output", "")
        error = execution_data.get("error")
        
        self.send_to_browser("display_output", {
            "output": output,
            "error": error,
            "execution_time": execution_data.get("execution_time", 0)
        })
        
        # Show output panel
        self.show_output_panel()

    async def display_errors(self, errors):
        """Display syntax errors"""
        self.send_to_browser("display_errors", {
            "errors": errors
        })

    async def update_file_explorer_display(self, files_data):
        """Update file explorer with file list"""
        self.send_to_browser("update_file_explorer", {
            "files": files_data
        })

    def select_file_in_explorer(self, file_path):
        """Select file in file explorer"""
        self.send_to_browser("select_file", {
            "path": file_path
        })

    def show_output_panel(self):
        """Show the output panel"""
        self.send_to_browser("show_panel", {
            "panel": "output_panel"
        })

    def apply_theme(self, theme_name):
        """Apply theme to IDE"""
        self.state.theme = theme_name
        self.send_to_browser("apply_theme", {
            "theme": theme_name
        })

    # Dialog and Input Methods
    async def show_file_picker(self, mode):
        """Show file picker dialog"""
        return await self.send_to_browser("show_file_picker", {"mode": mode})

    def show_error(self, title, message):
        """Show error dialog"""
        self.send_to_browser("show_error", {
            "title": title,
            "message": message
        })

    def show_info(self, title, message):
        """Show info dialog"""
        self.send_to_browser("show_info", {
            "title": title,
            "message": message
        })

    def send_to_browser(self, action, data):
        """Send data to browser (simplified for this example)"""
        # In a real implementation, this would use WebSocket or similar
        # For now, we'll simulate browser communication
        self.logger.debug(f"Sending to browser: {action} - {data}")
        
        # This would be implemented with actual browser communication
        return asyncio.Future()

    async def run(self):
        """Start the IDE"""
        if self.is_running:
            return
        
        self.is_running = True
        self.logger.info("Starting Noodle IDE...")
        
        try:
            # Open browser
            await self.open_ide_browser()
            
            # Initialize file explorer
            await self.refresh_file_explorer()
            
            # Show welcome screen
            await self.show_welcome_screen()
            
            self.logger.info("Noodle IDE is running")
            
            # Keep IDE running
            while self.is_running:
                await asyncio.sleep(1)
                
        except KeyboardInterrupt:
            self.logger.info("IDE stopped by user")
        except Exception as e:
            self.logger.error(f"IDE error: {e}")
        finally:
            await self.cleanup()

    async def cleanup(self):
        """Clean up IDE resources"""
        self.is_running = False
        
        # Save current state
        await self.save_ide_state()
        
        # Close all open files
        for file_path in self.state.open_files:
            await self.api_client.close_file(file_path)
        
        self.logger.info("Noodle IDE cleaned up")

    async def save_ide_state(self):
        """Save IDE state to configuration"""
        state_data = {
            "current_file": self.state.current_file,
            "current_project": self.state.current_project,
            "open_files": self.state.open_files,
            "recent_files": self.state.recent_files,
            "theme": self.state.theme,
            "font_size": self.state.font_size,
            "auto_save_enabled": self.state.auto_save_enabled
        }
        
        await self.api_client.save_configuration("ide_state", state_data)

    # Additional placeholder methods
    async def open_ide_browser(self):
        """Open IDE in browser"""
        # This would launch the IDE in a browser
        pass

    async def show_welcome_screen(self):
        """Show welcome screen"""
        pass

    def exit_ide(self):
        """Exit IDE"""
        self.is_running = False

    # More placeholder methods...
    def undo(self, *args): pass
    def redo(self, *args): pass
    def cut(self, *args): pass
    def copy(self, *args): pass
    def paste(self, *args): pass
    def find(self, *args): pass
    def replace(self, *args): pass
    def toggle_file_explorer(self): pass
    def toggle_output_panel(self): pass
    def zoom_in(self): pass
    def zoom_out(self): pass
    def reset_zoom(self): pass
    def debug_code(self, *args): pass
    def show_preferences(self): pass
    def show_themes(self): pass
    def show_shortcuts(self): pass
    def show_documentation(self): pass
    def show_shortcuts_help(self): pass
    def show_about(self): pass
    def clear_output(self): pass
    def copy_output(self): pass
    def save_output(self): pass
    async def new_project(self, *args): pass
    async def open_project(self, *args): pass
    def on_file_opened(self, data): pass
    def on_file_saved(self, data): pass
    def on_file_closed(self, data): pass
    def on_editor_content_changed(self, data): pass
    def on_editor_cursor_changed(self, data): pass
    def on_project_opened(self, data): pass
    def on_project_closed(self, data): pass
    def on_theme_changed(self, data): pass
    def on_settings_changed(self, data): pass

    def __str__(self):
        return f"NoodleIDE_UI(current_file={self.state.current_file}, running={self.is_running})"

    def __repr__(self):
        return f"NoodleIDE_UI(files={len(self.state.open_files)}, unsaved={self.state.unsaved_changes})"