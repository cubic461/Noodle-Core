# Converted from Python to NoodleCore
# Original file: noodle-core

# NoodleCore converted from Python
# """
# NoodleCore Native GUI IDE - Persistent Settings
# Enhanced with intelligent context, real AI integration, and persistent settings
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
import urllib.request
import urllib.parse
import urllib.error.URLError
import re
import ast
import platform
import base64

class SettingsManager
    #     """Manage persistent IDE settings."""

    #     def __init__(self):
    self.config_dir = self._get_config_dir()
    self.config_file = self.config_dir / "noodlecore_ide_settings.json"
    self.settings = self._load_settings()

    #     def _get_config_dir(self):
    #         """Get the configuration directory for the OS."""
    #         if platform.system() == "Windows":
    config_dir = Path(os.environ.get('APPDATA', 'C:/')) / "NoodleCore" / "IDE"
    #         elif platform.system() == "Darwin":  # macOS
    config_dir = Path.home() / "Library" / "Application Support" / "NoodleCore" / "IDE"
    #         else:  # Linux and other Unix-like
    config_dir = Path.home() / ".config" / "noodlecore" / "ide"

    #         # Create directory if it doesn't exist
    config_dir.mkdir(parents = True, exist_ok=True)
    #         return config_dir

    #     def _load_settings(self):
    #         """Load settings from file."""
    default_settings = {
    #             "ai_provider": "openrouter",
    #             "ai_model": "openai/gpt-3.5-turbo",
    #             "ai_context": "Smart",
    #             "api_keys": {},
    #             "last_opened_files": [],
    #             "last_project": None,
    #             "window_geometry": "1400x900",
    #             "recent_models": {}
    #         }

    #         try:
    #             if self.config_file.exists():
    #                 with open(self.config_file, 'r', encoding='utf-8') as f:
    settings = json.load(f)
    #                     # Merge with defaults
    #                     for key, value in default_settings.items():
    #                         if key not in settings:
    settings[key] = value
    #                     return settings
    #             else:
    #                 return default_settings
    #         except Exception as e:
                print(f"Error loading settings: {e}")
    #             return default_settings

    #     def save_settings(self):
    #         """Save settings to file."""
    #         try:
    #             with open(self.config_file, 'w', encoding='utf-8') as f:
    json.dump(self.settings, f, indent = 2, ensure_ascii=False)
    #         except Exception as e:
                print(f"Error saving settings: {e}")

    #     def set(self, key, value):
    #         """Set a setting value."""
    self.settings[key] = value

    #     def get(self, key, default=None):
    #         """Get a setting value."""
            return self.settings.get(key, default)

    #     def set_api_key(self, provider, key_value):
    #         """Set API key for a provider (with basic encoding)."""
    #         # Basic encoding to prevent casual reading, not security
    #         if key_value:
    encoded = base64.b64encode(key_value.encode()).decode()
    self.settings["api_keys"][provider] = encoded
    #         else:
                self.settings["api_keys"].pop(provider, None)

    #     def get_api_key(self, provider):
    #         """Get API key for a provider."""
    encoded = self.settings["api_keys"].get(provider)
    #         if encoded:
    #             try:
                    return base64.b64decode(encoded).decode()
    #             except:
    #                 return ""
    #         return ""

    #     def add_recent_model(self, provider, model):
    #         """Add a model to recent list."""
    #         if "recent_models" not in self.settings:
    self.settings["recent_models"] = {}

    #         if provider not in self.settings["recent_models"]:
    self.settings["recent_models"][provider] = []

    #         # Remove if already exists
    #         if model in self.settings["recent_models"][provider]:
                self.settings["recent_models"][provider].remove(model)

    #         # Add to beginning
            self.settings["recent_models"][provider].insert(0, model)

    #         # Keep only last 10
    self.settings["recent_models"][provider] = self.settings["recent_models"][provider][:10]

    #     def get_recent_models(self, provider):
    #         """Get recent models for a provider."""
            return self.settings.get("recent_models", {}).get(provider, [])

class NoodleCoreIDE
    #     """Main NoodleCore Native GUI IDE class with persistent smart AI integration."""

    #     def __init__(self):
    self.root = tk.Tk()
            self.root.title("NoodleCore Native GUI IDE - Persistent Settings")
            self.root.geometry("1400x900")
    self.root.configure(bg = '#2b2b2b')

    #         # Initialize settings manager
    self.settings = SettingsManager()

    #         # Initialize variables
    self.open_files = {}
    self.current_project = None
    self.current_ai_provider = self.settings.get("ai_provider", "openrouter")
    self.available_models = {}
    self.api_keys = {}
    self.models_loaded = False
    self.current_file_content = ""
    self.last_analysis = {}

    #         # Load API keys from settings
    #         for provider in ["openrouter", "openai", "anthropic"]:
    key = self.settings.get_api_key(provider)
    #             if key:
    self.api_keys[provider] = key

    #         # Create GUI
            self.create_menu()
            self.create_main_layout()
            self.setup_ai_integration()

    #         # Load initial models with saved settings
            self.load_provider_models()

    #         # Apply saved UI state
            self._apply_saved_ui_state()

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
    file_menu.add_command(label = "Exit", command=self.on_exit)

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
            run_menu.add_separator()
    #         run_menu.add_command(label="Analyze Code with AI", command=self.analyze_code_with_ai)
    run_menu.add_command(label = "AI Code Review", command=self.ai_code_review)

    #         # AI menu
    ai_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "AI", menu=ai_menu)
    ai_menu.add_command(label = "AI Settings", command=self.show_ai_settings)
    ai_menu.add_command(label = "Refresh Models", command=self.load_provider_models)
    ai_menu.add_command(label = "Test Connection", command=self.test_ai_connection)
    ai_menu.add_command(label = "Smart Chat", command=self.smart_ai_chat)
    ai_menu.add_command(label = "Clear AI History", command=self.clear_ai_history)
            ai_menu.add_separator()
    ai_menu.add_command(label = "Save Current Settings", command=self.save_current_settings)

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

    #         # Project info
    self.project_info_label = ttk.Label(file_explorer_frame, text="No project loaded", font=('Arial', 9), foreground='gray')
    self.project_info_label.pack(pady = 2)

    #         # Create right panel container
    right_panel = ttk.Frame(main_container)
    right_panel.pack(side = 'right', fill='both', expand=True, padx=2, pady=2)

    #         # Top notebook for code editor
    self.notebook = ttk.Notebook(right_panel)
    self.notebook.pack(fill = 'both', expand=True, pady=(0, 5))

    #         # Bottom panel for AI and Terminal
    bottom_panel = ttk.Frame(right_panel)
    bottom_panel.pack(fill = 'both', expand=False, pady=(0, 2))

    #         # AI Chat panel
    ai_frame = ttk.LabelFrame(bottom_panel, text="Smart AI Assistant (Context-Aware + Persistent)", padding=5)
    ai_frame.pack(side = 'left', fill='both', expand=True, padx=(0, 2))

    self.ai_chat_output = scrolledtext.ScrolledText(ai_frame, height=8, bg='#1e1e1e', fg='#ffffff',
    font = ('Consolas', 10), wrap='word')
    self.ai_chat_output.pack(fill = 'both', expand=True)

    #         # AI input and controls
    ai_input_frame = ttk.Frame(ai_frame)
    ai_input_frame.pack(fill = 'x', pady=(5, 0))

    #         # Provider selection with recent models
    ttk.Label(ai_input_frame, text = "Provider:").pack(side='left', padx=(0, 2))
    self.ai_provider_var = tk.StringVar(value=self.current_ai_provider)
    self.provider_combo = ttk.Combobox(ai_input_frame, textvariable=self.ai_provider_var, width=12,
    values = ["openrouter", "openai", "anthropic", "lm_studio", "ollama"])
    self.provider_combo.pack(side = 'left', padx=(0, 2))
            self.provider_combo.bind('<<ComboboxSelected>>', self.on_provider_change)
            self.provider_combo.bind('<<FocusOut>>', self.on_provider_change)

    #         # Model selection with recent models
    ttk.Label(ai_input_frame, text = "Model:").pack(side='left', padx=(0, 2))
    self.ai_model_var = tk.StringVar(value=self.settings.get("ai_model", "Loading models..."))
    self.model_combo = ttk.Combobox(ai_input_frame, textvariable=self.ai_model_var, width=20)
    self.model_combo.pack(side = 'left', padx=(0, 2))
            self.model_combo.bind('<<FocusOut>>', self.on_model_change)

    #         # AI context mode
    ttk.Label(ai_input_frame, text = "Context:").pack(side='left', padx=(10, 2))
    self.ai_context_var = tk.StringVar(value=self.settings.get("ai_context", "Smart"))
    self.context_combo = ttk.Combobox(ai_input_frame, textvariable=self.ai_context_var, width=12,
    values = ["Smart", "Current File", "Project", "General"])
    self.context_combo.pack(side = 'left', padx=(0, 2))
            self.context_combo.bind('<<FocusOut>>', self.on_context_change)

    #         # Status indicator with stored connection status
    self.model_status_label = ttk.Label(ai_input_frame, text="✅", font=('Arial', 10))
    self.model_status_label.pack(side = 'left', padx=(2, 0))

    #         # Send button
    ttk.Button(ai_input_frame, text = "Send", command=self.send_smart_ai_request).pack(side='right')

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
    self.status_bar = ttk.Label(self.root, text="Initializing Persistent Smart AI IDE...", relief='sunken', anchor='w')
    self.status_bar.pack(side = 'bottom', fill='x')

    #         # Initialize file tree
            self.refresh_file_tree()

    #         # Create welcome tab after status bar exists
    #         self.create_new_tab("Welcome to NoodleCore IDE", "# Welcome to NoodleCore Native GUI IDE - Persistent Smart AI\n\nThis IDE now has intelligent AI integration with **persistent settings**!\n\n✅ **Smart AI Features with Memory:**\n- Context-aware AI conversations\n- Current file analysis and insights\n- Project-aware suggestions\n- NoodleCore-specific help\n- Code review and optimization\n- **Settings are automatically saved and remembered!**\n\n🚀 **How to Use Persistent Smart AI:**\n1. Open a NoodleCore file (.nc)\n2. Use Run → Analyze Code with AI\n3. Or use AI → Smart Chat for general help\n4. **Your AI provider, model, and context mode are remembered!**\n5. **API keys are securely stored and auto-loaded!**\n\n**Current Status:** Loading AI models with your saved settings...")

    #     def setup_ai_integration(self):
    #         """Setup AI integration with smart context."""
    #         # Provider configurations with real API endpoints
    self.api_endpoints = {
    #             "openrouter": {
    #                 "name": "OpenRouter",
    #                 "base_url": "https://openrouter.ai/api/v1",
    #                 "models_endpoint": "/models",
    #                 "chat_endpoint": "/chat/completions",
    #                 "headers": lambda api_key: {
    #                     "Authorization": f"Bearer {api_key}",
    #                     "Content-Type": "application/json",
    #                     "HTTP-Referer": "https://noodlecore-ide.com",
    #                     "X-Title": "NoodleCore Smart IDE"
    #                 } if api_key else {
    #                     "Content-Type": "application/json"
    #                 },
    #                 "fallback_models": [
    #                     "openai/gpt-3.5-turbo",
    #                     "openai/gpt-4",
    #                     "anthropic/claude-3-sonnet-20240229",
    #                     "anthropic/claude-3-haiku-20240307",
    #                     "meta-llama/llama-2-70b-chat",
    #                     "mistralai/mixtral-8x7b-instruct",
    #                     "google/gemini-pro"
    #                 ]
    #             },
    #             "openai": {
    #                 "name": "OpenAI",
    #                 "base_url": "https://api.openai.com/v1",
    #                 "models_endpoint": "/models",
    #                 "chat_endpoint": "/chat/completions",
    #                 "headers": lambda api_key: {
    #                     "Authorization": f"Bearer {api_key}",
    #                     "Content-Type": "application/json"
    #                 } if api_key else {},
    #                 "fallback_models": [
    #                     "gpt-3.5-turbo",
    #                     "gpt-3.5-turbo-16k",
    #                     "gpt-4",
    #                     "gpt-4-turbo-preview",
    #                     "gpt-4-0125-preview"
    #                 ]
    #             },
    #             "anthropic": {
    #                 "name": "Anthropic",
    #                 "base_url": "https://api.anthropic.com/v1",
    #                 "models_endpoint": "/messages",
    #                 "chat_endpoint": "/messages",
    #                 "headers": lambda api_key: {
    #                     "x-api-key": api_key,
    #                     "Content-Type": "application/json",
    #                     "anthropic-version": "2023-06-01"
    #                 } if api_key else {},
    #                 "fallback_models": [
    #                     "claude-3-haiku-20240307",
    #                     "claude-3-sonnet-20240229",
    #                     "claude-3-opus-20240229"
    #                 ]
    #             }
    #         }

    #     def _apply_saved_ui_state(self):
    #         """Apply saved UI state on startup."""
    #         # Set window geometry
    geometry = self.settings.get("window_geometry")
    #         if geometry:
    #             try:
                    self.root.geometry(geometry)
    #             except:
    #                 pass

    #         # Load last project if exists
    last_project = self.settings.get("last_project")
    #         if last_project and Path(last_project).exists():
    self.current_project = last_project
                self.refresh_file_tree()
                self.update_project_info()

    #         # Load recent models in the model combobox
    provider = self.ai_provider_var.get()
    recent_models = self.settings.get_recent_models(provider)
    #         if recent_models:
    #             all_models = recent_models + [m for m in self.settings.get("available_models", {}).get(provider, []) if m not in recent_models]
    self.model_combo['values'] = all_models[:20]  # Show max 20
    #         else:
    #             # Try to load saved available models
    saved_models = self.settings.get("available_models", {}).get(provider, [])
    #             if saved_models:
    self.model_combo['values'] = saved_models

    #     def on_provider_change(self, event=None):
    #         """Handle provider selection change with persistence."""
    new_provider = self.ai_provider_var.get()
    #         if new_provider != self.current_ai_provider:
    self.current_ai_provider = new_provider
                self.settings.set("ai_provider", new_provider)
                self.update_status(f"Provider changed to: {new_provider}")
                self.load_provider_models()

    #     def on_model_change(self, event=None):
    #         """Handle model selection change with persistence."""
    new_model = self.ai_model_var.get()
    #         if new_model and new_model != self.settings.get("ai_model"):
                self.settings.set("ai_model", new_model)
                self.settings.add_recent_model(self.current_ai_provider, new_model)
                self.settings.set("available_models", {**self.settings.get("available_models", {}),
                                                      self.current_ai_provider: self.available_models.get(self.current_ai_provider, [])})
                self.settings.save_settings()

    #     def on_context_change(self, event=None):
    #         """Handle context selection change with persistence."""
    new_context = self.ai_context_var.get()
            self.settings.set("ai_context", new_context)
            self.settings.save_settings()

    #     def load_provider_models(self):
    #         """Load available models for the selected provider."""
    provider = self.ai_provider_var.get()

    #         # Update status and UI
    self.model_status_label.config(text = "🔄")
    #         self.update_status(f"Loading models for {provider}...")

    #         # Combine recent models and API models
    recent_models = self.settings.get_recent_models(provider)
    self.model_combo['values'] = recent_models + ["Loading models from API..."]
    #         self.ai_model_var.set(self.settings.get("ai_model", recent_models[0] if recent_models else "Loading..."))

    #         # Clear current models
    #         if provider in self.available_models:
    #             del self.available_models[provider]

    #         # Start async model loading
    threading.Thread(target = self._load_models_async, args=(provider,), daemon=True).start()

    #     def _load_models_async(self, provider):
    #         """Load models asynchronously."""
    #         try:
    models = self._fetch_models_from_provider(provider)

    #             # Update UI in main thread
                self.root.after(0, lambda: self._update_models_ui(provider, models, True))

    #         except Exception as e:
    error_msg = f"Failed to load models: {str(e)}"
                self.root.after(0, lambda: self._update_models_ui(provider, [], False, error_msg))

    #     def _fetch_models_from_provider(self, provider):
    #         """Fetch models from a specific provider."""
    #         if provider not in self.api_endpoints:
    #             return []

    config = self.api_endpoints[provider]
    api_key = self.api_keys.get(provider, "")

    #         # If no API key, use fallback models
    #         if not api_key:
    #             self.update_status(f"No API key for {config['name']}, using fallback models")
    #             return config["fallback_models"]

    #         try:
    #             # Make API call to fetch models
    url = config["base_url"] + config["models_endpoint"]
    headers = config["headers"](api_key)

                self.update_status(f"Fetching models from {config['name']}...")
    response = requests.get(url, headers=headers, timeout=15)

    #             if response.status_code == 200:
    data = response.json()
    models = []

    #                 if provider == "openrouter":
    #                     models = [model.get("id", "") for model in data.get("data", []) if model.get("id")]
    #                 elif provider == "openai":
    #                     models = [model.get("id", "") for model in data.get("data", [])
    #                              if not model.get("id", "").startswith("whisper") and model.get("id")]
    #                 elif provider == "anthropic":
    #                     # Anthropic uses a different endpoint structure
    models = config["fallback_models"]

    #                 # Clean and limit models
    #                 models = [m for m in models if m][:50]  # First 50 models
                    self.update_status(f"Successfully loaded {len(models)} models from {config['name']}")
    #                 return models
    #             else:
                    self.update_status(f"API returned status {response.status_code}, using fallback")
    #                 return config["fallback_models"]

    #         except requests.exceptions.Timeout:
                self.update_status(f"Timeout fetching models from {config['name']}")
    #             return config["fallback_models"]
    #         except requests.exceptions.RequestException as e:
                self.update_status(f"Network error fetching models: {str(e)[:50]}")
    #             return config["fallback_models"]
    #         except Exception as e:
                self.update_status(f"Error fetching models: {str(e)[:50]}")
    #             return config["fallback_models"]

    #     def _update_models_ui(self, provider, models, success, error_msg=""):
    #         """Update the UI with loaded models."""
    #         if success and models:
    self.available_models[provider] = models

    #             # Combine recent models and new models
    recent_models = self.settings.get_recent_models(provider)
    #             all_models = recent_models + [m for m in models if m not in recent_models]

    self.model_combo['values'] = all_models[:20]  # Show max 20

    #             # Set the saved model if available
    saved_model = self.settings.get("ai_model")
    #             if saved_model in all_models:
                    self.ai_model_var.set(saved_model)
    #             else:
                    self.ai_model_var.set(all_models[0])

    self.model_status_label.config(text = "✅")
    self.models_loaded = True
    #         else:
    #             error_text = error_msg if error_msg else "No models available"
    self.model_combo['values'] = [error_text]
                self.ai_model_var.set(error_text)
    self.model_status_label.config(text = "❌")
    self.models_loaded = False

    #         self.update_status(f"Models ready for {self.api_endpoints[provider]['name']}")
            self.settings.save_settings()

    #     def update_status(self, message):
    #         """Update the status bar."""
    self.status_bar.config(text = message)

    #     def test_ai_connection(self):
    #         """Test the AI connection for the current provider."""
    provider = self.ai_provider_var.get()
    model = self.ai_model_var.get()
    api_key = self.api_keys.get(provider, "")

    #         if not api_key:
    #             messagebox.showwarning("No API Key", f"No API key configured for {provider}")
    #             return

            self.update_status(f"Testing connection to {provider}...")

    #         def test_connection():
    #             try:
    #                 if provider == "openrouter":
    response = self._test_openrouter_connection(api_key, model)
    #                 elif provider == "openai":
    response = self._test_openai_connection(api_key, model)
    #                 elif provider == "anthropic":
    response = self._test_anthropic_connection(api_key, model)
    #                 else:
    response = "Provider test not implemented"

                    self.root.after(0, lambda: self._test_completed(response))

    #             except Exception as e:
    error_msg = f"Connection test failed: {str(e)}"
                    self.root.after(0, lambda: self._test_completed(error_msg))

    threading.Thread(target = test_connection, daemon=True).start()

    #     def _test_openrouter_connection(self, api_key, model):
    #         """Test OpenRouter connection."""
    config = self.api_endpoints["openrouter"]
    url = config["base_url"] + config["chat_endpoint"]
    headers = config["headers"](api_key)

    payload = {
    #             "model": model,
    #             "messages": [{"role": "user", "content": "Hello, this is a connection test."}],
    #             "max_tokens": 50
    #         }

    response = requests.post(url, headers=headers, json=payload, timeout=10)
    #         return f"OpenRouter connection successful! Model: {model}"

    #     def _test_openai_connection(self, api_key, model):
    #         """Test OpenAI connection."""
    config = self.api_endpoints["openai"]
    url = config["base_url"] + config["chat_endpoint"]
    headers = config["headers"](api_key)

    payload = {
    #             "model": model,
    #             "messages": [{"role": "user", "content": "Hello, this is a connection test."}],
    #             "max_tokens": 50
    #         }

    response = requests.post(url, headers=headers, json=payload, timeout=10)
    #         return f"OpenAI connection successful! Model: {model}"

    #     def _test_anthropic_connection(self, api_key, model):
    #         """Test Anthropic connection."""
    config = self.api_endpoints["anthropic"]
    url = config["base_url"] + config["chat_endpoint"]
    headers = config["headers"](api_key)

    payload = {
    #             "model": model,
    #             "max_tokens": 50,
    #             "messages": [{"role": "user", "content": "Hello, this is a connection test."}]
    #         }

    response = requests.post(url, headers=headers, json=payload, timeout=10)
    #         return f"Anthropic connection successful! Model: {model}"

    #     def _test_completed(self, result):
    #         """Handle connection test completion."""
            self.update_status("Connection test completed")
            messagebox.showinfo("Connection Test", result)

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

    #             # Bind text changes to update context
                self.code_editor.bind('<KeyRelease>', self.on_text_change)
                self.code_editor.bind('<Button-1>', self.on_text_change)

    #             # Add text widget to scrollbar
    scrollbar = ttk.Scrollbar(text_frame, orient='vertical', command=self.code_editor.yview)
    scrollbar.pack(side = 'right', fill='y')
    self.code_editor.config(yscrollcommand = scrollbar.set)

    self.notebook.add(frame, text = title)
            self.notebook.select(frame)

    self.open_files[frame] = {'filename': None, 'modified': False, 'title': title, 'content': content}

    #         # Update context when creating new tab
            self.update_current_context()

    #     def on_text_change(self, event=None):
    #         """Handle text changes to update AI context."""
            self.update_current_context()

    #     def update_current_context(self):
    #         """Update current file context for AI."""
    current_tab = self.notebook.select()
    #         if current_tab:
    frame = self.root.nametowidget(current_tab)
    text_widget = frame.winfo_children()[0].winfo_children()[0]  # Get text widget

    #             # Update current file content
    self.current_file_content = text_widget.get('1.0', 'end-1c')
    self.open_files[frame]['content'] = self.current_file_content

    #             # Update status
    filename = self.open_files[frame]['filename']
    #             if filename:
                    self.update_status(f"Editing: {filename} ({len(self.current_file_content)} chars)")
    #             else:
                    self.update_status(f"Editing: {self.open_files[frame]['title']} ({len(self.current_file_content)} chars)")

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

    #                 # Bind text changes
                    text_widget.bind('<KeyRelease>', self.on_text_change)
                    text_widget.bind('<Button-1>', self.on_text_change)

    tab_title = os.path.basename(filename)
    self.notebook.add(frame, text = tab_title)
                    self.notebook.select(frame)

    self.open_files[frame] = {'filename': filename, 'modified': False, 'title': tab_title, 'content': content}
                    self.update_status(f"Opened: {filename}")
                    self.update_current_context()

    #                 # Add to recent files
    recent_files = self.settings.get("last_opened_files", [])
    #                 if filename not in recent_files:
                        recent_files.insert(0, filename)
    #                     recent_files[:10]  # Keep only last 10
                        self.settings.set("last_opened_files", recent_files)
                        self.settings.save_settings()

    #             except Exception as e:
                    messagebox.showerror("Error", f"Could not open file: {e}")

    #     def open_project(self):
    #         """Open a project directory."""
    project_dir = filedialog.askdirectory(title="Select Project Directory")
    #         if project_dir:
    self.current_project = project_dir
                self.settings.set("last_project", project_dir)
                self.settings.save_settings()
                self.refresh_file_tree()
                self.update_status(f"Project: {project_dir}")

    #             # Update project info
                self.update_project_info()

    #     def update_project_info(self):
    #         """Update project information display."""
    #         if self.current_project:
    #             try:
    project_path = Path(self.current_project)
    #                 if project_path.exists():
    #                     # Count files
    #                     total_files = sum(1 for _ in project_path.rglob('*') if _.is_file())
    #                     nc_files = sum(1 for _ in project_path.rglob('*.nc') if _.is_file())
    #                     py_files = sum(1 for _ in project_path.rglob('*.py') if _.is_file())

    info_text = f"Project: {project_path.name}\n"
    info_text + = f"Files: {total_files} total\n"
    info_text + = f".nc: {nc_files}, .py: {py_files}"

    self.project_info_label.config(text = info_text, foreground='white')
    #                 else:
    self.project_info_label.config(text = "Project not found", foreground='red')
    #             except Exception as e:
    self.project_info_label.config(text = f"Error: {str(e)}", foreground='red')
    #         else:
    self.project_info_label.config(text = "No project loaded", foreground='gray')

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
                        self.update_status(f"Saved: {self.open_files[frame]['filename']}")
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

                        self.update_status(f"Saved: {filename}")
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

    #     def analyze_code_with_ai(self):
    #         """Analyze current code with AI and show insights."""
    #         if not self.current_file_content:
                messagebox.showwarning("No Content", "Please open or create a file first.")
    #             return

    provider = self.ai_provider_var.get()
    model = self.ai_model_var.get()
    api_key = self.api_keys.get(provider, "")

    #         if not api_key:
    #             self.ai_chat_output.insert('end', f"❌ Please configure API key for {provider} in AI → AI Settings\n\n")
                self.ai_chat_output.see('end')
    #             return

            self.ai_chat_output.insert('end', "🤖 **AI Code Analysis Starting...**\n")
            self.ai_chat_output.see('end')

    #         # Generate analysis prompt
    prompt = self._generate_code_analysis_prompt()

    #         def analyze_code():
    #             try:
    response = self._make_ai_request(provider, model, prompt)
                    self.root.after(0, lambda: self._show_code_analysis(response))
    #             except Exception as e:
    error_msg = f"Code analysis failed: {str(e)}"
    self.root.after(0, lambda: self._show_code_analysis(error_msg, is_error = True))

    threading.Thread(target = analyze_code, daemon=True).start()

    #     def ai_code_review(self):
    #         """Perform AI code review of current file."""
    #         if not self.current_file_content:
                messagebox.showwarning("No Content", "Please open or create a file first.")
    #             return

    provider = self.ai_provider_var.get()
    model = self.ai_model_var.get()
    api_key = self.api_keys.get(provider, "")

    #         if not api_key:
    #             self.ai_chat_output.insert('end', f"❌ Please configure API key for {provider} in AI → AI Settings\n\n")
                self.ai_chat_output.see('end')
    #             return

            self.ai_chat_output.insert('end', "🔍 **AI Code Review Starting...**\n")
            self.ai_chat_output.see('end')

    #         # Generate review prompt
    prompt = self._generate_code_review_prompt()

    #         def review_code():
    #             try:
    response = self._make_ai_request(provider, model, prompt)
                    self.root.after(0, lambda: self._show_code_review(response))
    #             except Exception as e:
    error_msg = f"Code review failed: {str(e)}"
    self.root.after(0, lambda: self._show_code_review(error_msg, is_error = True))

    threading.Thread(target = review_code, daemon=True).start()

    #     def smart_ai_chat(self):
    #         """Start a smart AI chat with context."""
            self.send_smart_ai_request()

    #     def send_smart_ai_request(self, event=None):
    #         """Send a smart AI request with context."""
    provider = self.ai_provider_var.get()
    model = self.ai_model_var.get()
    context_mode = self.ai_context_var.get()
    api_key = self.api_keys.get(provider, "")

    #         if not api_key:
    #             self.ai_chat_output.insert('end', f"❌ Please configure API key for {provider} in AI → AI Settings\n\n")
                self.ai_chat_output.see('end')
    #             return

    #         # Get user input - for now use a smart default
    #         user_message = "Can you help me with this NoodleCore development?"

    #         if context_mode == "Current File":
    #             if not self.current_file_content:
    #                 user_message = "I'm working on a new file. Can you help me get started with NoodleCore development?"
    #             else:
    user_message = f"I'm working on this code. Can you review and help improve it?\n\nCurrent file has {len(self.current_file_content)} characters."
    #         elif context_mode == "Project":
    #             if self.current_project:
    #                 user_message = f"I'm working on a NoodleCore project at {self.current_project}. Can you help me with the overall structure and best practices?"
    #             else:
    user_message = "I'm starting a new NoodleCore project. Can you guide me on the project structure and best practices?"
    #         elif context_mode == "Smart":
    #             # Generate smart context-based message
    user_message = self._generate_smart_prompt()

    #         self.ai_chat_output.insert('end', f"👤 User: {user_message[:100]}{'...' if len(user_message) > 100 else ''}\n")

    #         # Show typing indicator
    #         self.ai_chat_output.insert('end', f"🤖 {provider}/{model}: Thinking with context...")
            self.ai_chat_output.see('end')

    #         # Add context to the message
    full_prompt = self._add_context_to_prompt(user_message)

    #         # Send request in background
    #         def send_request():
    #             try:
    response = self._make_ai_request(provider, model, full_prompt)
                    self.root.after(0, lambda: self._update_ai_response(provider, model, response))
    #             except Exception as e:
    error_msg = f"Error: {str(e)}"
    self.root.after(0, lambda: self._update_ai_response(provider, model, error_msg, is_error = True))

    threading.Thread(target = send_request, daemon=True).start()

    #     def _generate_smart_prompt(self):
    #         """Generate a smart context-aware prompt."""
    prompts = []

    #         # Add file context
    #         if self.current_file_content:
    #             if self.current_file_content.strip():
    #                 prompts.append(f"I'm currently editing a file with {len(self.current_file_content)} characters.")
    #                 if self.current_file_content.startswith('#'):
                        prompts.append("This appears to be a NoodleCore file (.nc).")
    #                 elif self.current_file_content.startswith('import ') or self.current_file_content.startswith('from '):
                        prompts.append("This appears to be a Python file.")
    #             else:
                    prompts.append("I'm working on an empty file.")

    #         # Add project context
    #         if self.current_project:
                prompts.append(f"My current project is at: {self.current_project}")

    #         # Add recent activity context
    #         if self.current_file_content:
    #             if 'def ' in self.current_file_content or 'class ' in self.current_file_content:
                    prompts.append("I can see there are functions or classes in the code.")
    #             if 'error' in self.current_file_content.lower() or 'exception' in self.current_file_content.lower():
                    prompts.append("I notice there might be some error handling in the code.")

    #         base_prompt = "Can you help me with my current development work?"

    #         if prompts:
    #             return f"{base_prompt}\n\nContext:\n" + "\n".join(f"• {p}" for p in prompts)
    #         else:
    #             return base_prompt

    #     def _generate_code_analysis_prompt(self):
    #         """Generate a prompt for code analysis."""
    context = self._get_development_context()

    #         return f"""Please analyze the following code and provide insights:

# {context}

# Current code:
# ```
# {self.current_file_content}
# ```

# Please provide:
# 1. Code structure and organization analysis
# 2. Potential improvements or optimizations
# 3. Best practices compliance
# 4. NoodleCore-specific recommendations (if applicable)
# 5. Any errors or issues you notice
# 6. Suggestions for enhancement

# Be specific and actionable in your recommendations."""

#     def _generate_code_review_prompt(self):
#         """Generate a prompt for code review."""
context = self._get_development_context()

#         return f"""Please perform a comprehensive code review of the following:

# {context}

# Code to review:
# ```
# {self.current_file_content}
# ```

# Please provide:
# 1. Code quality assessment
# 2. Security considerations
# 3. Performance implications
# 4. Maintainability concerns
# 5. Compliance with coding standards
# 6. Specific improvement suggestions with examples
# 7. Overall rating and summary

# Be thorough and constructive in your review."""

#     def _get_development_context(self):
#         """Get current development context."""
context_parts = []

#         # File context
#         if self.current_file_content:
file_type = "Unknown"
#             if self.current_file_content.strip().startswith('#'):
file_type = "NoodleCore (.nc)"
#             elif self.current_file_content.strip().startswith('import ') or 'def ' in self.current_file_content:
file_type = "Python"

            context_parts.append(f"File Type: {file_type}")
            context_parts.append(f"Content Length: {len(self.current_file_content)} characters")

#         # Project context
#         if self.current_project:
            context_parts.append(f"Project Path: {self.current_project}")

#         # Current file info
current_tab = self.notebook.select()
#         if current_tab:
frame = self.root.nametowidget(current_tab)
filename = self.open_files[frame]['filename']
#             if filename:
                context_parts.append(f"Filename: {os.path.basename(filename)}")

#         return "\n".join(f"• {part}" for part in context_parts) if context_parts else "• No specific context available"

#     def _add_context_to_prompt(self, user_message):
#         """Add development context to user prompt."""
context = self._get_development_context()

#         return f"""You are an expert NoodleCore development assistant. Please help the user with their current development work.

# Development Context:
# {context}

# User Question: {user_message}

# Please provide helpful, specific, and actionable assistance based on the context above. If relevant, suggest code improvements, best practices, or NoodleCore-specific solutions."""

#     def _make_ai_request(self, provider, model, prompt):
#         """Make a real AI API request with enhanced context."""
#         if provider == "openrouter":
            return self._make_openrouter_request(model, prompt)
#         elif provider == "openai":
            return self._make_openai_request(model, prompt)
#         elif provider == "anthropic":
            return self._make_anthropic_request(model, prompt)
#         else:
#             return f"Provider {provider} not yet supported for live requests"

#     def _make_openrouter_request(self, model, message):
#         """Make OpenRouter API request."""
config = self.api_endpoints["openrouter"]
url = config["base_url"] + config["chat_endpoint"]
headers = config["headers"](self.api_keys["openrouter"])

payload = {
#             "model": model,
#             "messages": [{"role": "user", "content": message}],
#             "max_tokens": 1000
#         }

response = requests.post(url, headers=headers, json=payload, timeout=30)
        response.raise_for_status()

data = response.json()
#         return data["choices"][0]["message"]["content"]

#     def _make_openai_request(self, model, message):
#         """Make OpenAI API request."""
config = self.api_endpoints["openai"]
url = config["base_url"] + config["chat_endpoint"]
headers = config["headers"](self.api_keys["openai"])

payload = {
#             "model": model,
#             "messages": [{"role": "user", "content": message}],
#             "max_tokens": 1000
#         }

response = requests.post(url, headers=headers, json=payload, timeout=30)
        response.raise_for_status()

data = response.json()
#         return data["choices"][0]["message"]["content"]

#     def _make_anthropic_request(self, model, message):
#         """Make Anthropic API request."""
config = self.api_endpoints["anthropic"]
url = config["base_url"] + config["chat_endpoint"]
headers = config["headers"](self.api_keys["anthropic"])

payload = {
#             "model": model,
#             "max_tokens": 1000,
#             "messages": [{"role": "user", "content": message}]
#         }

response = requests.post(url, headers=headers, json=payload, timeout=30)
        response.raise_for_status()

data = response.json()
#         return data["content"][0]["text"]

#     def _show_code_analysis(self, response, is_error=False):
#         """Show code analysis results."""
#         # Remove typing indicator
content = self.ai_chat_output.get("1.0", tk.END)
#         if "AI Code Analysis Starting..." in content:
lines = content.split('\n')
#             for i, line in enumerate(lines):
#                 if "AI Code Analysis Starting..." in line:
lines[i] = ""
#                     break
            self.ai_chat_output.delete("1.0", tk.END)
            self.ai_chat_output.insert("1.0", '\n'.join(lines))

#         # Add analysis
#         if is_error:
            self.ai_chat_output.insert('end', f"❌ {response}\n\n")
#         else:
            self.ai_chat_output.insert('end', f"🔍 **AI Code Analysis:**\n{response}\n\n")

        self.ai_chat_output.see('end')

#     def _show_code_review(self, response, is_error=False):
#         """Show code review results."""
#         # Remove typing indicator
content = self.ai_chat_output.get("1.0", tk.END)
#         if "AI Code Review Starting..." in content:
lines = content.split('\n')
#             for i, line in enumerate(lines):
#                 if "AI Code Review Starting..." in line:
lines[i] = ""
#                     break
            self.ai_chat_output.delete("1.0", tk.END)
            self.ai_chat_output.insert("1.0", '\n'.join(lines))

#         # Add review
#         if is_error:
            self.ai_chat_output.insert('end', f"❌ {response}\n\n")
#         else:
            self.ai_chat_output.insert('end', f"📋 **AI Code Review:**\n{response}\n\n")

        self.ai_chat_output.see('end')

#     def _update_ai_response(self, provider, model, response, is_error=False):
#         """Update the AI chat with the response."""
#         # Remove typing indicator
content = self.ai_chat_output.get("1.0", tk.END)
#         if "Thinking with context..." in content:
lines = content.split('\n')
#             # Find and remove the thinking line
#             for i, line in enumerate(lines):
#                 if "Thinking with context..." in line:
lines[i] = ""
#                     break
            self.ai_chat_output.delete("1.0", tk.END)
            self.ai_chat_output.insert("1.0", '\n'.join(lines))

#         # Add response
#         if is_error:
            self.ai_chat_output.insert('end', f"❌ {response}\n\n")
#         else:
            self.ai_chat_output.insert('end', f"🤖 {provider}/{model}: {response}\n\n")

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
#         """Show AI settings dialog with persistent values."""
settings_window = tk.Toplevel(self.root)
        settings_window.title("AI Settings (Persistent)")
        settings_window.geometry("600x500")

ttk.Label(settings_window, text = "AI Provider Configuration", font=('Arial', 14, 'bold')).pack(pady=10)

#         # API Key inputs
#         ttk.Label(settings_window, text="Configure your API keys for live AI access:", font=('Arial', 10)).pack(pady=5)

keys_frame = ttk.Frame(settings_window)
keys_frame.pack(fill = 'both', expand=True, padx=20, pady=10)

#         # OpenRouter API Key
ttk.Label(keys_frame, text = "🔑 OpenRouter API Key:", font=('Arial', 10, 'bold')).pack(anchor='w', pady=(10, 0))
ttk.Label(keys_frame, text = "Get from: https://openrouter.ai/keys", font=('Arial', 8), foreground='blue').pack(anchor='w')
openrouter_key = ttk.Entry(keys_frame, width=60, show='*')
openrouter_key.pack(anchor = 'w', pady=(0, 5), fill='x')
        openrouter_key.insert(0, self.settings.get_api_key('openrouter'))

#         # OpenAI API Key
ttk.Label(keys_frame, text = "🔑 OpenAI API Key:", font=('Arial', 10, 'bold')).pack(anchor='w', pady=(10, 0))
ttk.Label(keys_frame, text = "Get from: https://platform.openai.com/api-keys", font=('Arial', 8), foreground='blue').pack(anchor='w')
openai_key = ttk.Entry(keys_frame, width=60, show='*')
openai_key.pack(anchor = 'w', pady=(0, 5), fill='x')
        openai_key.insert(0, self.settings.get_api_key('openai'))

#         # Anthropic API Key
ttk.Label(keys_frame, text = "🔑 Anthropic API Key:", font=('Arial', 10, 'bold')).pack(anchor='w', pady=(10, 0))
ttk.Label(keys_frame, text = "Get from: https://console.anthropic.com/", font=('Arial', 8), foreground='blue').pack(anchor='w')
anthropic_key = ttk.Entry(keys_frame, width=60, show='*')
anthropic_key.pack(anchor = 'w', pady=(0, 5), fill='x')
        anthropic_key.insert(0, self.settings.get_api_key('anthropic'))

#         def save_settings():
#             # Save API keys
            self.settings.set_api_key('openrouter', openrouter_key.get().strip())
            self.settings.set_api_key('openai', openai_key.get().strip())
            self.settings.set_api_key('anthropic', anthropic_key.get().strip())

#             # Update in-memory keys
self.api_keys['openrouter'] = self.settings.get_api_key('openrouter')
self.api_keys['openai'] = self.settings.get_api_key('openai')
self.api_keys['anthropic'] = self.settings.get_api_key('anthropic')

#             # Save settings
            self.settings.save_settings()

#             messagebox.showinfo("Settings", "AI settings saved persistently! \n\n✅ Your API keys are now remembered and will auto-load next time.\n✅ Click 'AI → Refresh Models' to load models with your API keys.")
            settings_window.destroy()
#             self.load_provider_models()  # Reload models with new keys

ttk.Button(settings_window, text = "Save & Refresh Models", command=save_settings).pack(pady=20)

#     def save_current_settings(self):
#         """Manually save current settings."""
        self.on_model_change()  # Save current model
        self.on_context_change()  # Save current context
        self.settings.save_settings()
        messagebox.showinfo("Settings Saved", "Current AI settings have been saved persistently!")

#     def clear_ai_history(self):
#         """Clear AI chat history."""
        self.ai_chat_output.delete('1.0', 'end')

#     def show_about(self):
#         """Show about dialog."""
about_text = """NoodleCore Native GUI IDE - Persistent Settings Version
# Version 4.0 - Smart AI with Persistent Memory

# 🚀 Persistent Features:
# • AI provider and model are remembered
# • API keys are securely stored and auto-loaded
# • Recent models are tracked and shown first
# • Context mode preference is saved
# • Project directory is remembered
# • Window geometry is remembered
# • Recent files list is maintained

# 💡 Smart Features:
# • Context-aware AI conversations
# • Current file analysis and insights
# • Project-aware suggestions
# • NoodleCore-specific help
# • Code review and optimization

# Your settings are automatically saved and will be restored next time you start the IDE!
# """
        messagebox.showinfo("About", about_text)

#     def on_exit(self):
#         """Handle IDE exit with settings save."""
#         # Save current window geometry
        self.settings.set("window_geometry", self.root.geometry())
        self.settings.save_settings()
        self.root.quit()

#     def run(self):
#         """Run the IDE."""
#         # Add initial welcome message
        self.ai_chat_output.insert('end', "💾 NoodleCore IDE Persistent Settings - Never Re-enter Again!\n\n")
        self.ai_chat_output.insert('end', "✅ **What's New - Persistent Settings:**\n")
        self.ai_chat_output.insert('end', "• AI provider and model are remembered\n")
        self.ai_chat_output.insert('end', "• API keys are securely stored and auto-loaded\n")
        self.ai_chat_output.insert('end', "• Recent models are tracked and shown first\n")
        self.ai_chat_output.insert('end', "• Context mode preference is saved\n")
        self.ai_chat_output.insert('end', "• Project directory is remembered\n")
        self.ai_chat_output.insert('end', "• Window geometry is remembered\n\n")
        self.ai_chat_output.insert('end', "🚀 **No More Re-entering:**\n")
        self.ai_chat_output.insert('end', "1. Add your API keys once in AI Settings\n")
        self.ai_chat_output.insert('end', "2. Select your preferred provider and model\n")
        self.ai_chat_output.insert('end', "3. Everything is remembered automatically!\n")
        self.ai_chat_output.insert('end', "4. Next time you start - everything is ready!\n\n")
        self.ai_chat_output.insert('end', f"📁 Settings location: {self.settings.config_dir}\n")
        self.ai_chat_output.insert('end', "Loading your saved models...\n\n")

#         # Handle window close
        self.root.protocol("WM_DELETE_WINDOW", self.on_exit)

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