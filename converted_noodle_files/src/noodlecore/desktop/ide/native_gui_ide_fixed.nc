# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Native NoodleCore GUI IDE Implementation - Fixed Version
# Complete resizable window implementation with dynamic layout
# """

import tkinter as tk
import tkinter.ttk,
import subprocess
import sys
import os
import json
import pathlib.Path
import threading.Timer

# Import NoodleCore modules
import .layout_manager.LayoutManager
import .resize_event_handler.ResizeEventHandler
import .ide_config.get_global_config
import .logging_config.setup_gui_logging
import ..layout_errors.(
#     LayoutInitializationError, handle_layout_error
# )


class NoodleCoreIDE
    #     """Main NoodleCore GUI IDE implementation with resizable windows."""

    #     def __init__(self):
    #         """Initialize the IDE with configuration and layout management."""
    #         try:
    #             # Setup logging
    self.logger = setup_gui_logging()
                self.logger.info("Initializing NoodleCore IDE")

    #             # Load configuration
    self.config = get_global_config()

    #             # Create main window
    self.root = tk.Tk()
                self._setup_main_window()

    #             # Initialize layout and resize management
                self._initialize_layout_system()

    #             # Initialize IDE components
                self._initialize_ide_components()

    #             # Setup window event handling
                self._setup_window_events()

                self.logger.info("NoodleCore IDE initialization completed")

    #         except Exception as e:
                self.logger.error(f"Failed to initialize IDE: {e}")
                messagebox.showerror("Initialization Error", f"Failed to start IDE: {e}")
                raise LayoutInitializationError(f"IDE initialization failed: {e}")

    #     def _setup_main_window(self) -> None:
    #         """Setup the main window with configuration."""
    #         try:
    #             # Get window configuration
    window_config = self.config.get_window_config()

    #             # Configure main window
                self.root.title("NoodleCore Native GUI IDE")
                self.root.geometry(f"{window_config['width']}x{window_config['height']}+{window_config['x']}+{window_config['y']}")
                self.root.minsize(window_config['min_width'], window_config['min_height'])
    self.root.configure(bg = '#2b2b2b')

    #             if window_config['maximized']:
                    self.root.state('zoomed')

    #             # Configure grid layout
    self.root.grid_rowconfigure(0, weight = 1)
    self.root.grid_columnconfigure(1, weight = 1)

                self.logger.debug(f"Main window configured: {window_config}")

    #         except Exception as e:
                handle_layout_error(e, "NoodleCoreIDE._setup_main_window")
    #             raise

    #     def _initialize_layout_system(self) -> None:
    #         """Initialize layout management system."""
    #         try:
    #             # Initialize layout manager
    self.layout_manager = LayoutManager(self.root)

    #             # Initialize resize event handler
    self.resize_handler = ResizeEventHandler(self.root)

    #             # Register layout callback with resize handler
                self.resize_handler.register_resize_callback(
    #                 "layout_manager",
    #                 self._on_window_resize
    #             )

    #             # Enable resize handling
                self.resize_handler.enable_resize_handling()

                self.logger.info("Layout system initialized")

    #         except Exception as e:
                handle_layout_error(e, "NoodleCoreIDE._initialize_layout_system")
    #             raise

    #     def _initialize_ide_components(self) -> None:
    #         """Initialize IDE components and UI."""
    #         try:
    #             # AI configuration
    self.ai_providers = {
    #                 "OpenRouter": {
    #                     "models": ["gpt-3.5-turbo", "gpt-4", "claude-3-haiku", "claude-3-sonnet"],
    #                     "api_key_required": True,
    #                     "base_url": "https://openrouter.ai/api/v1"
    #                 },
    #                 "OpenAI": {
    #                     "models": ["gpt-3.5-turbo", "gpt-4", "gpt-4-turbo"],
    #                     "api_key_required": True,
    #                     "base_url": "https://api.openai.com/v1"
    #                 },
    #                 "Z.ai": {
    #                     "models": ["z-ai-model-1", "z-ai-model-2"],
    #                     "api_key_required": True,
    #                     "base_url": "https://z.ai/api/v1"
    #                 },
    #                 "LM Studio": {
    #                     "models": ["llama-2-7b", "llama-2-13b", "codellama-7b"],
    #                     "api_key_required": False,
    #                     "base_url": "http://localhost:1234/v1"
    #                 },
    #                 "Ollama": {
    #                     "models": ["llama2", "codellama", "mistral"],
    #                     "api_key_required": False,
    #                     "base_url": "http://localhost:11434"
    #                 }
    #             }

    #             # Load AI settings from config
    ai_settings = self.config.get_ai_settings()
    self.current_ai_provider = ai_settings.get('provider', 'OpenRouter')
    self.current_ai_model = ai_settings.get('model', 'gpt-3.5-turbo')
    self.ai_api_key = ai_settings.get('api_key', '')

    #             # File tracking
    self.open_files = {}

    #             # Create main UI
                self._create_ui()

                self.logger.info("IDE components initialized")

    #         except Exception as e:
                handle_layout_error(e, "NoodleCoreIDE._initialize_ide_components")
    #             raise

    #     def _setup_window_events(self) -> None:
    #         """Setup window event handlers."""
    #         try:
    #             # Handle window close
                self.root.protocol("WM_DELETE_WINDOW", self._on_window_close)

    #             # Handle window state changes
                self.root.bind('<Map>', self._on_window_map)
                self.root.bind('<Unmap>', self._on_window_unmap)

                self.logger.debug("Window event handlers configured")

    #         except Exception as e:
                self.logger.error(f"Error setting up window events: {e}")

    #     def _on_window_resize(self, width: int, height: int) -> None:
    #         """Handle window resize events."""
    #         try:
                self.logger.debug(f"Window resized to: {width}x{height}")

    #             # Update layout
    #             if hasattr(self, 'layout_manager'):
                    self.layout_manager.schedule_responsive_update()

    #             # Update window configuration
    #             if hasattr(self, 'config'):
    window_config = self.config.get_window_config()
                    self.config.update_window_config(
    width = width,
    height = height,
    x = self.root.winfo_x(),
    y = self.root.winfo_y(),
    maximized = self.root.state() == 'zoomed'
    #                 )

    #         except Exception as e:
                self.logger.error(f"Error handling window resize: {e}")

    #     def _on_window_close(self) -> None:
    #         """Handle window close event."""
    #         try:
                self.logger.info("Window close requested")

    #             # Save configuration
    #             if hasattr(self, 'config'):
                    self.config.save_config()

    #             # Cleanup resources
                self._cleanup()

    #             # Close window
                self.root.quit()
                self.root.destroy()

    #         except Exception as e:
                self.logger.error(f"Error during window close: {e}")

    #     def _on_window_map(self, event) -> None:
    #         """Handle window map event."""
            self.logger.debug("Window mapped")

    #     def _on_window_unmap(self, event) -> None:
    #         """Handle window unmap event."""
            self.logger.debug("Window unmapped")

    #     def _create_ui(self) -> None:
    #         """Create the user interface."""
    #         try:
    #             # Create main container for layout
    main_container = tk.Frame(self.root, bg='#2b2b2b')
    main_container.grid(row = 0, column=0, columnspan=3, sticky='nsew')

    #             # Initialize layout with main container
                self.layout_manager.initialize_layout(main_container)

    #             # Create menu bar
                self._create_menu_bar()

    #             # Create panels
                self._create_left_panel()
                self._create_code_editor()
                self._create_right_panel()

    #             # Create status bar
                self._create_status_bar()

                self.logger.info("User interface created")

    #         except Exception as e:
                handle_layout_error(e, "NoodleCoreIDE._create_ui")
    #             raise

    #     def _create_menu_bar(self) -> None:
    #         """Create the menu bar."""
    #         try:
    menubar = tk.Menu(self.root)
    self.root.config(menu = menubar)

    #             # File menu
    file_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "File", menu=file_menu)
    file_menu.add_command(label = "New File", command=self.new_file)
    file_menu.add_command(label = "Open File", command=self.open_file)
    file_menu.add_command(label = "Save", command=self.save_file)
    file_menu.add_command(label = "Save As", command=self.save_file_as)
                file_menu.add_separator()
    file_menu.add_command(label = "Exit", command=self._on_window_close)

    #             # Run menu
    run_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "Run", menu=run_menu)
    run_menu.add_command(label = "Run Current File", command=self.run_current_file)

    #             # AI menu
    ai_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "AI", menu=ai_menu)
    ai_menu.add_command(label = "AI Settings", command=self.show_ai_settings)

    #             # Help menu
    help_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "Help", menu=help_menu)
    help_menu.add_command(label = "About", command=self.show_about)

    #         except Exception as e:
                self.logger.error(f"Error creating menu bar: {e}")

    #     def _create_left_panel(self) -> None:
    #         """Create the left panel with file explorer and AI settings."""
    #         try:
    left_panel = self.layout_manager.panels.get("left_panel")
    #             if not left_panel:
    #                 return

    #             # Clear panel content
    #             for widget in left_panel.container.winfo_children():
                    widget.destroy()

    #             # File Explorer
    explorer_frame = tk.LabelFrame(left_panel.container, text="File Explorer",
    bg = '#2b2b2b', fg='white')
    explorer_frame.pack(fill = 'both', expand=True, padx=5, pady=5)

    self.file_tree = ttk.Treeview(explorer_frame, show='tree')
    self.file_tree.pack(fill = 'both', expand=True, padx=5, pady=5)

    #             # Refresh file tree
                self._refresh_file_tree()

    #             # AI Settings
    ai_frame = tk.LabelFrame(left_panel.container, text="AI Configuration",
    bg = '#2b2b2b', fg='white')
    ai_frame.pack(fill = 'x', padx=5, pady=(0, 5))

    #             # Provider selection
    tk.Label(ai_frame, text = "Provider:", bg='#2b2b2b', fg='white').pack(anchor='w')
    self.provider_var = tk.StringVar(value=self.current_ai_provider)
    provider_combo = ttk.Combobox(ai_frame, textvariable=self.provider_var,
    values = list(self.ai_providers.keys()))
    provider_combo.pack(fill = 'x', padx=5, pady=2)
                provider_combo.bind('<<ComboboxSelected>>', self._on_provider_change)

    #             # Model selection
    tk.Label(ai_frame, text = "Model:", bg='#2b2b2b', fg='white').pack(anchor='w', pady=(10,0))
    self.model_var = tk.StringVar(value=self.current_ai_model)
    self.model_combo = ttk.Combobox(ai_frame, textvariable=self.model_var)
    self.model_combo.pack(fill = 'x', padx=5, pady=2)

    #             # API Key
    tk.Label(ai_frame, text = "API Key:", bg='#2b2b2b', fg='white').pack(anchor='w', pady=(10,0))
    self.api_key_var = tk.StringVar(value=self.ai_api_key)
    api_key_entry = tk.Entry(ai_frame, textvariable=self.api_key_var, show='*')
    api_key_entry.pack(fill = 'x', padx=5, pady=2)

    #             # Save button
    save_btn = tk.Button(ai_frame, text="Save Settings", command=self._save_ai_settings,
    bg = '#4CAF50', fg='white')
    save_btn.pack(fill = 'x', padx=5, pady=5)

    #         except Exception as e:
                handle_layout_error(e, "NoodleCoreIDE._create_left_panel")

    #     def _create_code_editor(self) -> None:
    #         """Create the main code editor area."""
    #         try:
    center_panel = self.layout_manager.panels.get("center_panel")
    #             if not center_panel:
    #                 return

    #             # Clear panel content
    #             for widget in center_panel.container.winfo_children():
                    widget.destroy()

    #             # Tab control for multiple files
    self.notebook = ttk.Notebook(center_panel.container)
    self.notebook.pack(fill = 'both', expand=True, padx=5, pady=5)

    #             # Create initial tab
                self.create_new_tab("Untitled")

    #         except Exception as e:
                handle_layout_error(e, "NoodleCoreIDE._create_code_editor")

    #     def _create_right_panel(self) -> None:
    #         """Create the right panel with terminal and AI chat."""
    #         try:
    right_panel = self.layout_manager.panels.get("right_panel")
    #             if not right_panel:
    #                 return

    #             # Clear panel content
    #             for widget in right_panel.container.winfo_children():
                    widget.destroy()

    right_panel.container.grid_rowconfigure(0, weight = 1)
    right_panel.container.grid_rowconfigure(1, weight = 1)

    #             # Terminal
    terminal_frame = tk.LabelFrame(right_panel.container, text="Terminal",
    bg = '#2b2b2b', fg='white')
    terminal_frame.grid(row = 0, column=0, sticky='nsew', padx=5, pady=5)

    self.terminal_output = scrolledtext.ScrolledText(terminal_frame,
    bg = '#1e1e1e', fg='#ffffff',
    font = ('Consolas', 10))
    self.terminal_output.pack(fill = 'both', expand=True, padx=5, pady=5)

    #             # Terminal input
    input_frame = tk.Frame(terminal_frame, bg='#2b2b2b')
    input_frame.pack(fill = 'x', padx=5, pady=(0, 5))

    tk.Label(input_frame, text = "$ ", bg='#2b2b2b', fg='white').pack(side='left')
    self.terminal_input = tk.Entry(input_frame, bg='#1e1e1e', fg='#ffffff',
    font = ('Consolas', 10), relief='flat')
    self.terminal_input.pack(side = 'left', fill='x', expand=True)
                self.terminal_input.bind('<Return>', self.execute_terminal_command)

    #             # Execute button
    exec_btn = tk.Button(input_frame, text="Execute", command=self.execute_terminal_command,
    bg = '#4CAF50', fg='white')
    exec_btn.pack(side = 'right', padx=(5, 0))

    #             # AI Chat
    ai_chat_frame = tk.LabelFrame(right_panel.container, text="AI Assistant",
    bg = '#2b2b2b', fg='white')
    ai_chat_frame.grid(row = 1, column=0, sticky='nsew', padx=5, pady=5)

    self.ai_chat_output = scrolledtext.ScrolledText(ai_chat_frame,
    bg = '#1e1e1e', fg='#ffffff',
    font = ('Consolas', 10))
    self.ai_chat_output.pack(fill = 'both', expand=True, padx=5, pady=5)

    #             # AI input
    ai_input_frame = tk.Frame(ai_chat_frame, bg='#2b2b2b')
    ai_input_frame.pack(fill = 'x', padx=5, pady=(0, 5))

    self.ai_input = tk.Entry(ai_input_frame, bg='#1e1e1e', fg='#ffffff',
    font = ('Consolas', 10), relief='flat')
    self.ai_input.pack(side = 'left', fill='x', expand=True)
                self.ai_input.bind('<Return>', self.send_ai_request)

    send_btn = tk.Button(ai_input_frame, text="Send", command=self.send_ai_request,
    bg = '#2196F3', fg='white')
    send_btn.pack(side = 'right', padx=(5, 0))

    #         except Exception as e:
                handle_layout_error(e, "NoodleCoreIDE._create_right_panel")

    #     def _create_status_bar(self) -> None:
    #         """Create the status bar."""
    #         try:
    self.status_bar = tk.Label(self.root, text="Ready", relief='sunken', anchor='w',
    bg = '#3c3c3c', fg='white')
    self.status_bar.grid(row = 1, column=0, columnspan=3, sticky='ew')

    #         except Exception as e:
                self.logger.error(f"Error creating status bar: {e}")

    #     def _refresh_file_tree(self) -> None:
    #         """Refresh the file explorer tree."""
    #         try:
    #             for item in self.file_tree.get_children():
                    self.file_tree.delete(item)

    current_dir = Path.cwd()
    self.file_tree.insert('', 'end', text = str(current_dir), open=True)

    #             for item in current_dir.iterdir():
    #                 if item.is_dir():
    self.file_tree.insert('', 'end', text = f"📁 {item.name}")
    #                 else:
    self.file_tree.insert('', 'end', text = f"📄 {item.name}")

    #             # Bind double-click event
                self.file_tree.bind('<Double-1>', self._on_file_double_click)

    #         except Exception as e:
                self.logger.error(f"Error refreshing file tree: {e}")

    #     def _on_file_double_click(self, event) -> None:
    #         """Handle double-click on file tree items."""
    #         try:
    #             selection = self.file_tree.selection()[0] if self.file_tree.selection() else None
    #             if selection:
    file_text = self.file_tree.item(selection)['text']
    #                 if not file_text.startswith('📁'):
    #                     filename = file_text[2:] if file_text.startswith('📄 ') else file_text
                        self.open_file(filename)
    #         except Exception as e:
                self.logger.error(f"Error handling file double-click: {e}")

    #     def _on_provider_change(self, event=None) -> None:
    #         """Handle AI provider change."""
    #         try:
    provider = self.provider_var.get()
    #             if provider in self.ai_providers:
    models = self.ai_providers[provider]['models']
    self.model_combo['values'] = models
    #                 self.model_var.set(models[0] if models else "")
    #         except Exception as e:
                self.logger.error(f"Error handling provider change: {e}")

    #     def _save_ai_settings(self) -> None:
    #         """Save AI settings."""
    #         try:
    provider = self.provider_var.get()
    model = self.model_var.get()
    api_key = self.api_key_var.get()

    #             # Update configuration
                self.config.set_ai_settings(provider, model, api_key)

    #             # Update current settings
    self.current_ai_provider = provider
    self.current_ai_model = model
    self.ai_api_key = api_key

                messagebox.showinfo("Settings Saved",
    #                               f"AI settings saved:\nProvider: {provider}\nModel: {model}")

    #         except Exception as e:
                self.logger.error(f"Error saving AI settings: {e}")

    #     def new_file(self) -> None:
    #         """Create a new file."""
            self.create_new_tab("Untitled")

    #     def open_file(self, filename=None) -> None:
    #         """Open a file."""
    #         try:
    #             if filename is None:
    filename = filedialog.askopenfilename(
    filetypes = [("NoodleCore files", "*.nc"), ("Python files", "*.py"), ("All files", "*.*")]
    #                 )

    #             if filename:
    #                 with open(filename, 'r', encoding='utf-8') as f:
    content = f.read()

                    self.create_new_tab(filename, content)
                    self._update_status(f"Opened: {filename}")
    #         except Exception as e:
                self.logger.error(f"Error opening file: {e}")
                messagebox.showerror("Error", f"Could not open file: {e}")

    #     def save_file(self) -> None:
    #         """Save current file."""
    #         try:
    current_tab = self.notebook.select()
    #             if current_tab:
    tab_frame = self.notebook.nametowidget(current_tab)
    text_widget = tab_frame.winfo_children()[0]

    content = text_widget.get('1.0', 'end-1c')
    tab_info = self.open_files.get(current_tab, {})

    #                 if tab_info.get('filename'):
    #                     with open(tab_info['filename'], 'w', encoding='utf-8') as f:
                            f.write(content)

                        self._update_status(f"Saved: {tab_info['filename']}")
    self.notebook.tab(current_tab, text = Path(tab_info['filename']).name)
    self.open_files[current_tab]['modified'] = False
    #                 else:
                        self.save_file_as()
    #         except Exception as e:
                self.logger.error(f"Error saving file: {e}")
                messagebox.showerror("Error", f"Could not save file: {e}")

    #     def save_file_as(self) -> None:
    #         """Save current file as new file."""
    #         try:
    filename = filedialog.asksaveasfilename(
    defaultextension = ".nc",
    filetypes = [("NoodleCore files", "*.nc"), ("Python files", "*.py"), ("All files", "*.*")]
    #                 )

    #             if filename:
    current_tab = self.notebook.select()
    #                 if current_tab:
    tab_frame = self.notebook.nametowidget(current_tab)
    text_widget = tab_frame.winfo_children()[0]

    content = text_widget.get('1.0', 'end-1c')

    #                     with open(filename, 'w', encoding='utf-8') as f:
                            f.write(content)

                        self._update_status(f"Saved as: {filename}")
    self.notebook.tab(current_tab, text = Path(filename).name)

    #                     # Update file tracking
    self.open_files[current_tab] = {'filename': filename, 'modified': False}
    #         except Exception as e:
                self.logger.error(f"Error saving file as: {e}")
                messagebox.showerror("Error", f"Could not save file as: {e}")

    #     def create_new_tab(self, title, content="") -> None:
    #         """Create a new tab with text editor."""
    #         try:
    frame = tk.Frame(self.notebook, bg='#2b2b2b')
    self.notebook.add(frame, text = title)
                self.notebook.select(frame)

    text_widget = scrolledtext.ScrolledText(frame, bg='#1e1e1e', fg='#ffffff',
    font = ('Consolas', 12), wrap='word')
    text_widget.pack(fill = 'both', expand=True, padx=5, pady=5)
                text_widget.insert('1.0', content)

    #             # Store tab reference
    #             self.open_files[frame] = {'filename': None if title == "Untitled" else title, 'modified': False}

    #         except Exception as e:
                self.logger.error(f"Error creating new tab: {e}")

    #     def run_current_file(self) -> None:
    #         """Run the current file."""
    #         try:
    current_tab = self.notebook.select()
    #             if current_tab:
    tab_info = self.open_files.get(current_tab, {})
    #                 if tab_info.get('filename'):
                        self.run_file(tab_info['filename'])
    #                 else:
                        messagebox.showwarning("Save Required", "Please save the file before running.")
    #         except Exception as e:
                self.logger.error(f"Error running current file: {e}")

    #     def run_file(self, filename) -> None:
    #         """Run a file."""
    #         try:
                self.terminal_output.insert('end', f"\n$ Running {filename}...\n")
                self.terminal_output.see('end')

    #             if filename.endswith('.nc'):
    result = subprocess.run(['python', filename],
    capture_output = True, text=True, cwd=Path(filename).parent)
                    self.terminal_output.insert('end', f"Output:\n{result.stdout}\n")
    #                 if result.stderr:
                        self.terminal_output.insert('end', f"Error:\n{result.stderr}\n")
    #                 if result.returncode == 0:
                        self.terminal_output.insert('end', "Execution completed successfully.\n")
    #                 else:
    #                     self.terminal_output.insert('end', f"Execution failed with return code {result.returncode}\n")
    #             elif filename.endswith('.py'):
    result = subprocess.run(['python', filename],
    capture_output = True, text=True, cwd=Path(filename).parent)
                    self.terminal_output.insert('end', f"Output:\n{result.stdout}\n")
    #                 if result.stderr:
                        self.terminal_output.insert('end', f"Error:\n{result.stderr}\n")
    #                 if result.returncode == 0:
                        self.terminal_output.insert('end', "Execution completed successfully.\n")
    #                 else:
    #                     self.terminal_output.insert('end', f"Execution failed with return code {result.returncode}\n")
    #             else:
                    self.terminal_output.insert('end', f"Unsupported file type: {filename}\n")

                self.terminal_output.see('end')

    #         except Exception as e:
                self.logger.error(f"Error running file: {e}")
                self.terminal_output.insert('end', f"Error running file: {e}\n")

    #     def execute_terminal_command(self, event=None) -> None:
    #         """Execute a terminal command."""
    #         try:
    command = self.terminal_input.get().strip()
    #             if command:
                    self.terminal_output.insert('end', f"$ {command}\n")
                    self.terminal_input.delete(0, 'end')
                    self.terminal_output.see('end')

    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    #                 if result.stdout:
                        self.terminal_output.insert('end', result.stdout)
    #                 if result.stderr:
                        self.terminal_output.insert('end', result.stderr)

                    self.terminal_output.see('end')
    #         except Exception as e:
                self.logger.error(f"Error executing terminal command: {e}")

    #     def send_ai_request(self, event=None) -> None:
    #         """Send an AI request."""
    #         try:
    message = self.ai_input.get().strip()
    #             if message:
                    self.ai_chat_output.insert('end', f"User: {message}\n")
                    self.ai_input.delete(0, 'end')

    #                 response = f"AI: I can help you with NoodleCore development using {self.current_ai_provider} - {self.current_ai_model}. What would you like to do?"
                    self.ai_chat_output.insert('end', f"{response}\n\n")
                    self.ai_chat_output.see('end')
    #         except Exception as e:
                self.logger.error(f"Error sending AI request: {e}")

    #     def show_ai_settings(self) -> None:
    #         """Show AI settings dialog."""
    #         try:
    settings_window = tk.Toplevel(self.root)
                settings_window.title("AI Settings")
                settings_window.geometry("400x300")
    settings_window.configure(bg = '#2b2b2b')

    tk.Label(settings_window, text = "Current Settings", bg='#2b2b2b', fg='white',
    font = ('Arial', 12, 'bold')).pack(pady=10)

    #             settings_text = f"Provider: {self.current_ai_provider}\nModel: {self.current_ai_model}\nAPI Key: {'*' * len(self.ai_api_key) if self.ai_api_key else 'Not set'}"
    tk.Label(settings_window, text = settings_text, bg='#2b2b2b', fg='white',
    justify = 'left').pack(padx=20, pady=10)

    tk.Button(settings_window, text = "Close", command=settings_window.destroy,
    bg = '#f44336', fg='white').pack(pady=20)

    #         except Exception as e:
                self.logger.error(f"Error showing AI settings: {e}")

    #     def show_about(self) -> None:
    #         """Show about dialog."""
    #         try:
    #             messagebox.showinfo("About", "NoodleCore Native GUI IDE\nVersion 2.0\n\nA complete IDE for NoodleCore development with AI integration and resizable windows.")
    #         except Exception as e:
                self.logger.error(f"Error showing about dialog: {e}")

    #     def _update_status(self, message: str) -> None:
    #         """Update status bar message."""
    #         try:
    #             if hasattr(self, 'status_bar'):
    self.status_bar.config(text = message)
    #         except Exception as e:
                self.logger.error(f"Error updating status: {e}")

    #     def _cleanup(self) -> None:
    #         """Cleanup resources."""
    #         try:
    #             # Cleanup layout manager
    #             if hasattr(self, 'layout_manager'):
                    self.layout_manager.cleanup()

    #             # Cleanup resize handler
    #             if hasattr(self, 'resize_handler'):
                    self.resize_handler.cleanup()

                self.logger.info("IDE cleanup completed")
    #         except Exception as e:
                self.logger.error(f"Error during cleanup: {e}")

    #     def run(self) -> None:
    #         """Run the IDE."""
    #         try:
                self.logger.info("Starting NoodleCore IDE")
                self.root.mainloop()
    #         except Exception as e:
                self.logger.error(f"Error running IDE: {e}")


# Additional classes for testing compatibility
class AIProviderManager
    #     """Mock AI provider manager for testing."""

    #     def __init__(self):
    self.providers = [
                type('Provider', (), {
    #                 'name': 'openai',
    #                 'models': ['gpt-4', 'gpt-3.5-turbo']
                })(),
                type('Provider', (), {
    #                 'name': 'anthropic',
    #                 'models': ['claude-3-sonnet', 'claude-3-haiku']
                })(),
                type('Provider', (), {
    #                 'name': 'openrouter',
    #                 'models': ['gpt-3.5-turbo', 'gpt-4', 'claude-3-haiku']
                })(),
                type('Provider', (), {
    #                 'name': 'lm_studio',
    #                 'models': ['llama-2-7b', 'codellama-7b']
                })(),
                type('Provider', (), {
    #                 'name': 'ollama',
    #                 'models': ['llama2', 'codellama', 'mistral']
                })()
    #         ]

    #     def get_available_providers(self):
    #         return self.providers


class NoodleCoreCodeEditor
    #     """Mock code editor for testing."""

    #     def analyze_code(self, code):
    #         return {
    #             "issues": [],
                "metrics": {"lines_of_code": len(code.split('\n'))},
    #             "ai_analysis": {"summary": "Code analysis complete"}
    #         }


class ProjectExplorer
    #     """Mock project explorer for testing."""

    #     def __init__(self):
    self.current_project = None

    #     def open_project(self, project_path):
    self.current_project = project_path
    #         return True


class TerminalConsole
    #     """Mock terminal console for testing."""

    #     def execute_command(self, command):
    #         return {
    #             "success": True,
    #             "output": f"Mock output for: {command}",
    #             "error": None
    #         }


class NativeGUIFramework
    #     """Mock GUI framework for testing."""

    #     def __init__(self):
    self.panel_sizes = {}

    #     def initialize_layout(self, width, height):
    self.panel_sizes = {
                "file_explorer": (300, height),
                "code_editor": (width - 600, height),
                "ai_panel": (300, height // 2),
                "terminal": (300, height // 2)
    #         }
    #         return True


class NativeNoodleCoreIDE
    #     """Mock integrated IDE for testing."""

    #     def __init__(self):
    self.initialized = False
    self.active_ai_provider = None
    self.open_files = []
    self.current_project = None

    #     def initialize(self):
    self.initialized = True
    #         return True

    #     def get_ai_providers(self):
    #         return ["openai", "anthropic", "openrouter", "lm_studio", "ollama"]


function main()
    #     """Main entry point for the IDE."""
    #     try:
    ide = NoodleCoreIDE()
            ide.run()
    #     except Exception as e:
            print(f"Error starting IDE: {e}")
    #         return 1


if __name__ == "__main__"
        exit(main())