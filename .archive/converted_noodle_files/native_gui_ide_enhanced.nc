# Converted from Python to NoodleCore
# Original file: noodle-core

# NoodleCore converted from Python
# """
# NoodleCore Native GUI IDE - Enhanced with Live AI Model Fetching
# A complete native GUI IDE for NoodleCore development with dynamic AI model loading
# """

import tkinter as tk
import tkinter.ttk,
import sys
import os
import subprocess
import json
import requests
import threading
import pathlib.Path
import time

class NoodleCoreIDE
    #     """Main NoodleCore Native GUI IDE class."""

    #     def __init__(self):
    self.root = tk.Tk()
            self.root.title("NoodleCore Native GUI IDE - Enhanced")
            self.root.geometry("1400x900")
    self.root.configure(bg = '#2b2b2b')

    #         # Initialize variables
    self.open_files = {}
    self.current_project = None
    self.current_ai_provider = "openrouter"
    self.available_models = {}
    self.api_keys = {}

    #         # Create GUI
            self.create_menu()
            self.create_main_layout()
            self.setup_ai_integration()

    #         # Load initial models
            self.load_provider_models()

    #     def create_menu(self):
    #         """Create the main menu."""
    menubar = tk.Menu(self.root)
    self.root.config(menu = menubar)

    #         # File menu
    file_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "File", menu=file_menu)
    file_menu.add_command(label = "New File", command=self.new_file)
    file_menu.add_command(label = "Open File", command=self.open_file)
    file_menu.add_command(label = "Open Project", command=self.open_project)
            file_menu.add_separator()
    file_menu.add_command(label = "Save", command=self.save_file)
    file_menu.add_command(label = "Save As", command=self.save_file_as)
            file_menu.add_separator()
    file_menu.add_command(label = "Exit", command=self.root.quit)

    #         # Edit menu
    edit_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "Edit", menu=edit_menu)
    #         edit_menu.add_command(label="Undo", command=lambda: self.code_editor.edit_undo() if hasattr(self, 'code_editor') else None)
    #         edit_menu.add_command(label="Redo", command=lambda: self.code_editor.edit_redo() if hasattr(self, 'code_editor') else None)
            edit_menu.add_separator()
    #         edit_menu.add_command(label="Cut", command=lambda: self.code_editor.event_generate("<<Cut>>") if hasattr(self, 'code_editor') else None)
    #         edit_menu.add_command(label="Copy", command=lambda: self.code_editor.event_generate("<<Copy>>") if hasattr(self, 'code_editor') else None)
    #         edit_menu.add_command(label="Paste", command=lambda: self.code_editor.event_generate("<<Paste>>") if hasattr(self, 'code_editor') else None)

    #         # Run menu
    run_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "Run", menu=run_menu)
    run_menu.add_command(label = "Run Current File", command=self.run_current_file)
    run_menu.add_command(label = "Run Project", command=self.run_project)

    #         # AI menu
    ai_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "AI", menu=ai_menu)
    ai_menu.add_command(label = "AI Settings", command=self.show_ai_settings)
    ai_menu.add_command(label = "Refresh Models", command=self.load_provider_models)
    ai_menu.add_command(label = "Clear AI History", command=self.clear_ai_history)

    #         # Help menu
    help_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "Help", menu=help_menu)
    help_menu.add_command(label = "About", command=self.show_about)

    #     def create_main_layout(self):
    #         """Create the main IDE layout with resizable panels."""
    #         # Create main container
    main_container = ttk.Frame(self.root)
    main_container.pack(fill = 'both', expand=True)

            # Create left panel (File Explorer)
    left_panel = ttk.Frame(main_container)
    left_panel.pack(side = 'left', fill='y', padx=2, pady=2)

    #         # File Explorer
    file_explorer_frame = ttk.LabelFrame(left_panel, text="File Explorer", padding=5)
    file_explorer_frame.pack(fill = 'y', expand=True, pady=(0, 5))

    self.file_tree = ttk.Treeview(file_explorer_frame, show='tree')
    self.file_tree.pack(fill = 'both', expand=True)

    #         # Refresh button
    ttk.Button(file_explorer_frame, text = "Refresh", command=self.refresh_file_tree).pack(pady=2)

    #         # Create right panel container
    right_panel = ttk.Frame(main_container)
    right_panel.pack(side = 'right', fill='both', expand=True, padx=2, pady=2)

    #         # Top notebook for code editor
    self.notebook = ttk.Notebook(right_panel)
    self.notebook.pack(fill = 'both', expand=True, pady=(0, 5))

    #         # Create a default tab
    #         self.create_new_tab("Welcome to NoodleCore IDE", "# Welcome to NoodleCore Native GUI IDE\n\nThis is a complete IDE for NoodleCore development.\n\nFeatures:\n- Native GUI with resizable panels\n- Multi-provider AI integration with live model loading\n- Code editor with auto-completion\n- File explorer and project management\n- Integrated terminal console\n- NoodleCore execution support\n\nStart by opening a file or creating a new project!")

    #         # Bottom panel for AI and Terminal
    bottom_panel = ttk.Frame(right_panel)
    bottom_panel.pack(fill = 'both', expand=False, pady=(0, 2))

    #         # AI Chat panel
    ai_frame = ttk.LabelFrame(bottom_panel, text="AI Assistant", padding=5)
    ai_frame.pack(side = 'left', fill='both', expand=True, padx=(0, 2))

    self.ai_chat_output = scrolledtext.ScrolledText(ai_frame, height=8, bg='#1e1e1e', fg='#ffffff',
    font = ('Consolas', 10))
    self.ai_chat_output.pack(fill = 'both', expand=True)

    #         # AI input and controls
    ai_input_frame = ttk.Frame(ai_frame)
    ai_input_frame.pack(fill = 'x', pady=(5, 0))

    #         # Provider selection
    ttk.Label(ai_input_frame, text = "Provider:").pack(side='left', padx=(0, 2))
    self.ai_provider_var = tk.StringVar(value="openrouter")
    self.provider_combo = ttk.Combobox(ai_input_frame, textvariable=self.ai_provider_var, width=12,
    values = ["openrouter", "openai", "anthropic", "lm_studio", "ollama"])
    self.provider_combo.pack(side = 'left', padx=(0, 2))
            self.provider_combo.bind('<<ComboboxSelected>>', self.on_provider_change)

    #         # Model selection
    ttk.Label(ai_input_frame, text = "Model:").pack(side='left', padx=(0, 2))
    self.ai_model_var = tk.StringVar(value="Loading...")
    self.model_combo = ttk.Combobox(ai_input_frame, textvariable=self.ai_model_var, width=20)
    self.model_combo.pack(side = 'left', padx=(0, 2))

    #         # Refresh models button
    ttk.Button(ai_input_frame, text = "🔄", width=3, command=self.load_provider_models).pack(side='left', padx=(2, 0))

    #         # Send button
    ttk.Button(ai_input_frame, text = "Send", command=self.send_ai_request).pack(side='right')

    #         # Terminal panel
    terminal_frame = ttk.LabelFrame(bottom_panel, text="Terminal", padding=5)
    terminal_frame.pack(side = 'right', fill='y', expand=False, padx=(2, 0), ipady=10)

    self.terminal_output = scrolledtext.ScrolledText(terminal_frame, height=8, bg='#1e1e1e', fg='#00ff00',
    font = ('Consolas', 10))
    self.terminal_output.pack(fill = 'both', expand=True)

    #         # Terminal input
    terminal_input_frame = ttk.Frame(terminal_frame)
    terminal_input_frame.pack(fill = 'x', pady=(5, 0))

    self.terminal_input = ttk.Entry(terminal_input_frame)
    self.terminal_input.pack(side = 'left', fill='x', expand=True, padx=(0, 2))
            self.terminal_input.bind('<Return>', self.execute_terminal_command)

    ttk.Button(terminal_input_frame, text = "Run", command=self.execute_terminal_command).pack(side='right')

    #         # Status bar
    self.status_bar = ttk.Label(self.root, text="Ready", relief='sunken', anchor='w')
    self.status_bar.pack(side = 'bottom', fill='x')

    #         # Initialize file tree
            self.refresh_file_tree()

    #     def setup_ai_integration(self):
    #         """Setup AI integration and model loading."""
    #         # Initialize API endpoints for different providers
    self.api_endpoints = {
    #             "openrouter": {
    #                 "base_url": "https://openrouter.ai/api/v1",
    #                 "models_endpoint": "/models",
    #                 "chat_endpoint": "/chat/completions",
                    "headers": lambda: {"Authorization": f"Bearer {self.api_keys.get('openrouter', '')}", "Content-Type": "application/json"}
    #             },
    #             "openai": {
    #                 "base_url": "https://api.openai.com/v1",
    #                 "models_endpoint": "/models",
    #                 "chat_endpoint": "/chat/completions",
                    "headers": lambda: {"Authorization": f"Bearer {self.api_keys.get('openai', '')}", "Content-Type": "application/json"}
    #             },
    #             "anthropic": {
    #                 "base_url": "https://api.anthropic.com/v1",
    #                 "models_endpoint": "/models",
    #                 "chat_endpoint": "/messages",
                    "headers": lambda: {"x-api-key": self.api_keys.get('anthropic', ''), "Content-Type": "application/json"}
    #             }
    #         }

    #         # Provider specific model lists for providers without public API
    self.fallback_models = {
    #             "lm_studio": ["local-llama", "local-mistral", "local-codellama"],
    #             "ollama": ["llama2", "codellama", "mistral", "phi"]
    #         }

    #     def on_provider_change(self, event=None):
    #         """Handle provider selection change."""
    self.current_ai_provider = self.ai_provider_var.get()
            self.load_provider_models()
    self.status_bar.config(text = f"Provider changed to: {self.current_ai_provider}")

    #     def load_provider_models(self):
    #         """Load available models for the selected provider."""
    provider = self.ai_provider_var.get()

    #         # Update status
    #         self.status_bar.config(text=f"Loading models for {provider}...")
    self.model_combo['values'] = ["Loading..."]

    #         # Use thread to avoid blocking UI
    threading.Thread(target = self._fetch_models_thread, args=(provider,), daemon=True).start()

    #     def _fetch_models_thread(self, provider):
    #         """Fetch models in a separate thread."""
    #         try:
    #             if provider in self.api_endpoints:
    #                 # Use API to fetch models
    models = self._fetch_models_from_api(provider)
    #             elif provider in self.fallback_models:
    #                 # Use fallback model list
    models = self.fallback_models[provider]
    #             else:
    models = ["Model list not available"]

    #             # Update UI in main thread
                self.root.after(0, lambda: self._update_model_list(models))

    #         except Exception as e:
                self.root.after(0, lambda: self._handle_model_load_error(str(e)))

    #     def _fetch_models_from_api(self, provider):
    #         """Fetch models from API."""
    endpoint = self.api_endpoints[provider]
    url = endpoint["base_url"] + endpoint["models_endpoint"]
    headers = endpoint["headers"]()

    #         if not headers.get("Authorization", "").replace("Bearer ", "") and not headers.get("x-api-key"):
    #             # No API key, use fallback
    #             if provider == "openrouter":
    #                 return ["openai/gpt-3.5-turbo", "openai/gpt-4", "anthropic/claude-3-sonnet", "meta-llama/llama-2-70b"]
    #             elif provider == "openai":
    #                 return ["gpt-3.5-turbo", "gpt-3.5-turbo-16k", "gpt-4", "gpt-4-turbo-preview"]
    #             elif provider == "anthropic":
    #                 return ["claude-3-haiku-20240307", "claude-3-sonnet-20240229", "claude-3-opus-20240229"]
    #             return ["API key required"]

    response = requests.get(url, headers=headers, timeout=10)
            response.raise_for_status()

    data = response.json()
    models = []

    #         if provider == "openrouter":
    #             models = [model["id"] for model in data.get("data", [])]
    #         elif provider == "openai":
    #             models = [model["id"] for model in data.get("data", []) if not model.get("id", "").startswith("whisper")]
    #         elif provider == "anthropic":
    #             models = [model["id"] for model in data.get("data", [])]

    #         return models[:50]  # Limit to first 50 models

    #     def _update_model_list(self, models):
    #         """Update the model combo box with loaded models."""
    #         if models:
    self.model_combo['values'] = models
    #             self.ai_model_var.set(models[0] if models else "No models available")
    #             self.status_bar.config(text=f"Loaded {len(models)} models for {self.current_ai_provider}")
    #         else:
    self.model_combo['values'] = ["No models available"]
    #             self.status_bar.config(text=f"No models available for {self.current_ai_provider}")

    #     def _handle_model_load_error(self, error_msg):
    #         """Handle model loading errors."""
    self.model_combo['values'] = ["Error loading models"]
            self.ai_model_var.set("Error loading models")
    self.status_bar.config(text = f"Error loading models: {error_msg}")

    #     def create_new_tab(self, title, content=""):
    #         """Create a new tab in the notebook."""
    frame = ttk.Frame(self.notebook)

    #         # Create text widget with scrollbar
    text_frame = ttk.Frame(frame)
    text_frame.pack(fill = 'both', expand=True, padx=5, pady=5)

    #         if not hasattr(self, 'code_editor'):
    self.code_editor = tk.Text(text_frame, wrap='word', font=('Consolas', 12),
    bg = '#1e1e1e', fg='#ffffff', insertbackground='white')
    self.code_editor.pack(fill = 'both', expand=True)

    #             # Add text widget to scrollbar
    scrollbar = ttk.Scrollbar(text_frame, orient='vertical', command=self.code_editor.yview)
    scrollbar.pack(side = 'right', fill='y')
    self.code_editor.config(yscrollcommand = scrollbar.set)

    self.notebook.add(frame, text = title)
            self.notebook.select(frame)

    self.open_files[frame] = {'filename': None, 'modified': False, 'title': title}

    #     def new_file(self):
    #         """Create a new file."""
            self.create_new_tab("Untitled")

    #     def open_file(self):
    #         """Open a file."""
    filename = filedialog.askopenfilename(
    filetypes = [
                    ("NoodleCore files", "*.nc"),
                    ("Python files", "*.py"),
                    ("JavaScript files", "*.js"),
                    ("All files", "*.*")
    #             ]
    #         )

    #         if filename:
    #             try:
    #                 with open(filename, 'r', encoding='utf-8') as f:
    content = f.read()

    frame = ttk.Frame(self.notebook)
    text_widget = tk.Text(frame, wrap='word', font=('Consolas', 12),
    bg = '#1e1e1e', fg='#ffffff', insertbackground='white')
    text_widget.pack(fill = 'both', expand=True, padx=5, pady=5)
                    text_widget.insert('1.0', content)

    tab_title = os.path.basename(filename)
    self.notebook.add(frame, text = tab_title)
                    self.notebook.select(frame)

    self.open_files[frame] = {'filename': filename, 'modified': False, 'title': tab_title}
    self.status_bar.config(text = f"Opened: {filename}")

    #             except Exception as e:
                    messagebox.showerror("Error", f"Could not open file: {e}")

    #     def open_project(self):
    #         """Open a project directory."""
    project_dir = filedialog.askdirectory(title="Select Project Directory")
    #         if project_dir:
    self.current_project = project_dir
                self.refresh_file_tree()
    self.status_bar.config(text = f"Project: {project_dir}")

    #     def save_file(self):
    #         """Save the current file."""
    current_tab = self.notebook.select()
    #         if current_tab:
    frame = self.root.nametowidget(current_tab)
    text_widget = frame.winfo_children()[0].winfo_children()[0]  # Get text widget

    #             if self.open_files[frame]['filename']:
    #                 try:
    #                     with open(self.open_files[frame]['filename'], 'w', encoding='utf-8') as f:
                            f.write(text_widget.get('1.0', 'end-1c'))
    self.open_files[frame]['modified'] = False
    self.status_bar.config(text = f"Saved: {self.open_files[frame]['filename']}")
    #                 except Exception as e:
                        messagebox.showerror("Error", f"Could not save file: {e}")
    #             else:
                    self.save_file_as()

    #     def save_file_as(self):
    #         """Save the current file as."""
    current_tab = self.notebook.select()
    #         if current_tab:
    frame = self.root.nametowidget(current_tab)
    text_widget = frame.winfo_children()[0].winfo_children()[0]  # Get text widget

    filename = filedialog.asksaveasfilename(
    filetypes = [
                        ("NoodleCore files", "*.nc"),
                        ("Python files", "*.py"),
                        ("JavaScript files", "*.js"),
                        ("All files", "*.*")
    #                 ]
    #             )

    #             if filename:
    #                 try:
    #                     with open(filename, 'w', encoding='utf-8') as f:
                            f.write(text_widget.get('1.0', 'end-1c'))

    self.open_files[frame]['filename'] = filename
    self.open_files[frame]['modified'] = False

    #                     # Update tab title
    tab_title = os.path.basename(filename)
    self.notebook.tab(current_tab, text = tab_title)
    self.open_files[frame]['title'] = tab_title

    self.status_bar.config(text = f"Saved: {filename}")
    #                 except Exception as e:
                        messagebox.showerror("Error", f"Could not save file: {e}")

    #     def refresh_file_tree(self):
    #         """Refresh the file explorer tree."""
    #         for item in self.file_tree.get_children():
                self.file_tree.delete(item)

    #         if self.current_project:
                self.add_tree_nodes('', self.current_project)
    #         else:
    #             # Show current directory
    current_dir = Path.cwd()
                self.add_tree_nodes('', str(current_dir))

    #     def add_tree_nodes(self, parent, path):
    #         """Add nodes to the file tree."""
    #         try:
    path_obj = Path(path)
    #             if path_obj.exists():
    #                 for item in path_obj.iterdir():
    node_id = self.file_tree.insert(parent, 'end', text=item.name,
    values = [str(item)], open=False)
    #                     if item.is_dir():
                            self.add_tree_nodes(node_id, str(item))
    #         except PermissionError:
    #             pass

    #     def execute_terminal_command(self, event=None):
    #         """Execute a terminal command."""
    command = self.terminal_input.get().strip()
    #         if command:
                self.terminal_output.insert('end', f"$ {command}\n")
                self.terminal_input.delete(0, 'end')

    #             try:
    result = subprocess.run(command, shell=True, capture_output=True, text=True, timeout=10)
    #                 if result.stdout:
                        self.terminal_output.insert('end', f"{result.stdout}\n")
    #                 if result.stderr:
                        self.terminal_output.insert('end', f"Error: {result.stderr}\n")
    #             except subprocess.TimeoutExpired:
                    self.terminal_output.insert('end', "Command timed out\n")
    #             except Exception as e:
                    self.terminal_output.insert('end', f"Error: {e}\n")

                self.terminal_output.see('end')

    #     def send_ai_request(self, event=None):
    #         """Send an AI request."""
    provider = self.ai_provider_var.get()
    model = self.ai_model_var.get()

    #         # Mock AI response for demo
    #         response = f"AI ({provider}/{model}): I'm connected to {provider} with model {model}. "
    response + = "This is a demo response. In the full version, this would make a real API call to the selected provider and model. "
    #         response += "I can help you with NoodleCore development, code analysis, and general programming questions."

    #         self.ai_chat_output.insert('end', f"User: [AI Request with {provider}/{model}]\n")
            self.ai_chat_output.insert('end', f"{response}\n\n")
            self.ai_chat_output.see('end')

    #     def run_current_file(self):
    #         """Run the current file."""
    current_tab = self.notebook.select()
    #         if current_tab:
    frame = self.root.nametowidget(current_tab)
    #             if self.open_files[frame]['filename']:
                    self.run_file(self.open_files[frame]['filename'])
    #             else:
                    self.save_file()
    #                 if self.open_files[frame]['filename']:
                        self.run_file(self.open_files[frame]['filename'])

    #     def run_file(self, filename):
    #         """Run a file."""
            self.terminal_output.insert('end', f"\n--- Running {filename} ---\n")

    #         try:
    #             if filename.endswith('.nc'):
    #                 # Try to run as NoodleCore file
    result = subprocess.run(['python', filename],
    capture_output = True, text=True, timeout=30)
    #             elif filename.endswith('.py'):
    result = subprocess.run(['python', filename],
    capture_output = True, text=True, timeout=30)
    #             else:
                    self.terminal_output.insert('end', f"Unsupported file type: {filename}\n")
    #                 return

    #             if result.stdout:
                    self.terminal_output.insert('end', f"Output:\n{result.stdout}\n")
    #             if result.stderr:
                    self.terminal_output.insert('end', f"Error:\n{result.stderr}\n")

    #         except subprocess.TimeoutExpired:
                self.terminal_output.insert('end', "Execution timed out\n")
    #         except Exception as e:
                self.terminal_output.insert('end', f"Execution error: {e}\n")

            self.terminal_output.see('end')

    #     def run_project(self):
    #         """Run the current project."""
    #         if self.current_project:
                self.terminal_output.insert('end', f"\n--- Running project: {self.current_project} ---\n")
    #             # Add project-specific run logic here
                self.terminal_output.insert('end', "Project runner not implemented yet\n")
    #         else:
                messagebox.showwarning("No Project", "Please open a project first.")

    #     def show_ai_settings(self):
    #         """Show AI settings dialog."""
    settings_window = tk.Toplevel(self.root)
            settings_window.title("AI Settings")
            settings_window.geometry("500x400")

    ttk.Label(settings_window, text = "AI Provider Configuration", font=('Arial', 14, 'bold')).pack(pady=10)

    #         # API Key inputs
    ttk.Label(settings_window, text = "API Keys (optional):").pack(anchor='w', padx=10, pady=(10, 0))

    #         # OpenRouter API Key
    ttk.Label(settings_window, text = "OpenRouter API Key:").pack(anchor='w', padx=20)
    openrouter_key = ttk.Entry(settings_window, width=50, show='*')
    openrouter_key.pack(anchor = 'w', padx=20, pady=(0, 5))
    #         if 'openrouter' in self.api_keys:
                openrouter_key.insert(0, self.api_keys['openrouter'])

    #         # OpenAI API Key
    ttk.Label(settings_window, text = "OpenAI API Key:").pack(anchor='w', padx=20)
    openai_key = ttk.Entry(settings_window, width=50, show='*')
    openai_key.pack(anchor = 'w', padx=20, pady=(0, 5))
    #         if 'openai' in self.api_keys:
                openai_key.insert(0, self.api_keys['openai'])

    #         # Anthropic API Key
    ttk.Label(settings_window, text = "Anthropic API Key:").pack(anchor='w', padx=20)
    anthropic_key = ttk.Entry(settings_window, width=50, show='*')
    anthropic_key.pack(anchor = 'w', padx=20, pady=(0, 5))
    #         if 'anthropic' in self.api_keys:
                anthropic_key.insert(0, self.api_keys['anthropic'])

    #         def save_settings():
    self.api_keys['openrouter'] = openrouter_key.get().strip()
    self.api_keys['openai'] = openai_key.get().strip()
    self.api_keys['anthropic'] = anthropic_key.get().strip()
                messagebox.showinfo("Settings", "AI settings saved! Click 'Refresh Models' to load updated model lists.")
                settings_window.destroy()

    ttk.Button(settings_window, text = "Save", command=save_settings).pack(pady=20)

    #     def clear_ai_history(self):
    #         """Clear AI chat history."""
            self.ai_chat_output.delete('1.0', 'end')

    #     def show_about(self):
    #         """Show about dialog."""
    #         messagebox.showinfo("About", "NoodleCore Native GUI IDE - Enhanced\nVersion 1.1\n\nFeatures:\n- Live AI model loading from providers\n- Multi-provider AI integration\n- Native GUI with resizable panels\n- NoodleCore development support")

    #     def run(self):
    #         """Run the IDE."""
    #         # Add initial AI welcome message
            self.ai_chat_output.insert('end', "Welcome to NoodleCore Native GUI IDE Enhanced!\n\n")
            self.ai_chat_output.insert('end', "🚀 New Features:\n")
            self.ai_chat_output.insert('end', "• Live model fetching from AI providers\n")
            self.ai_chat_output.insert('end', "• Dynamic model lists via API calls\n")
    #         self.ai_chat_output.insert('end', "• API key management for providers\n")
            self.ai_chat_output.insert('end', "• Real-time model refresh\n\n")
            self.ai_chat_output.insert('end', "📋 Available Providers:\n")
            self.ai_chat_output.insert('end', "• OpenRouter (80+ models)\n")
            self.ai_chat_output.insert('end', "• OpenAI (GPT models)\n")
            self.ai_chat_output.insert('end', "• Anthropic (Claude models)\n")
            self.ai_chat_output.insert('end', "• LM Studio (local models)\n")
            self.ai_chat_output.insert('end', "• Ollama (open source)\n\n")
            self.ai_chat_output.insert('end', "💡 Tip: Use AI → Refresh Models to get the latest available models!\n\n")

            self.root.mainloop()


function main()
    #     """Main entry point."""
    #     try:
    ide = NoodleCoreIDE()
            ide.run()
    #     except Exception as e:
            print(f"Error starting IDE: {e}")
    #         import traceback
            traceback.print_exc()
    #         return 1
    #     return 0


if __name__ == "__main__"
        exit(main())