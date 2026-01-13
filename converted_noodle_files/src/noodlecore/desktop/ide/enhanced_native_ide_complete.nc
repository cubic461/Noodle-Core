# Converted from Python to NoodleCore
# Original file: noodle-core


#!/usr/bin/env python3
# """
# Enhanced NoodleCore Native GUI IDE - Complete Implementation
# All requested features: real AI, auto-complete, roles, sandbox, Python→NoodleCore conversion
# """

import tkinter as tk
import tkinter.ttk,
import threading
import subprocess
import sys
import os
import json
import asyncio
import aiohttp
import pathlib.Path
import urllib.request
import urllib.parse
import re
import time
import uuid
import datetime.datetime
import hashlib
import tempfile
import shutil
import ast

class AIRole
    #     """AI role configuration for Cline/RooCode/Costrict style interactions."""
    #     def __init__(self, name, description, system_prompt, capabilities):
    self.id = str(uuid.uuid4())
    self.name = name
    self.description = description
    self.system_prompt = system_prompt
    self.capabilities = capabilities

class Suggestion
    #     """Code suggestion with accept/reject functionality."""
    #     def __init__(self, text, start_pos, end_pos, suggestion_type, confidence=1.0):
    self.id = str(uuid.uuid4())
    self.text = text
    self.start_pos = start_pos
    self.end_pos = end_pos
    self.type = suggestion_type
    self.confidence = confidence
    self.accepted = False
    self.timestamp = datetime.now()

class AIProvider
    #     """Base class for AI providers."""
    #     def __init__(self, name, base_url, api_key_required=False):
    self.name = name
    self.base_url = base_url
    self.api_key_required = api_key_required

    #     async def chat_completion(self, messages, api_key=None, model="gpt-3.5-turbo"):
    #         raise NotImplementedError

    #     def get_available_models(self):
    #         raise NotImplementedError

class OpenAIProvider(AIProvider)
    #     """OpenAI API provider."""
    #     def __init__(self):
            super().__init__("OpenAI", "https://api.openai.com/v1", True)

    #     async def chat_completion(self, messages, api_key=None, model="gpt-3.5-turbo"):
    headers = {
    #             "Authorization": f"Bearer {api_key}",
    #             "Content-Type": "application/json"
    #         }

    data = {
    #             "model": model,
    #             "messages": messages,
    #             "max_tokens": 4000,
    #             "temperature": 0.7
    #         }

    #         try:
    #             async with aiohttp.ClientSession() as session:
    #                 async with session.post(
    #                     f"{self.base_url}/chat/completions",
    headers = headers,
    json = data,
    timeout = aiohttp.ClientTimeout(total=30)
    #                 ) as response:
    #                     if response.status == 200:
    result = await response.json()
    #                         return result['choices'][0]['message']['content']
    #                     else:
    error_text = await response.text()
                            raise Exception(f"OpenAI API error {response.status}: {error_text}")
    #         except Exception as e:
                raise Exception(f"OpenAI request failed: {str(e)}")

    #     def get_available_models(self):
    #         return ["gpt-3.5-turbo", "gpt-4", "gpt-4-turbo"]

class OpenRouterProvider(AIProvider)
    #     """OpenRouter API provider."""
    #     def __init__(self):
            super().__init__("OpenRouter", "https://openrouter.ai/api/v1", True)

    #     async def chat_completion(self, messages, api_key=None, model="gpt-3.5-turbo"):
    headers = {
    #             "Authorization": f"Bearer {api_key}",
    #             "Content-Type": "application/json",
    #             "HTTP-Referer": "noodlecore-ide",
    #             "X-Title": "NoodleCore IDE"
    #         }

    data = {
    #             "model": model,
    #             "messages": messages,
    #             "max_tokens": 4000,
    #             "temperature": 0.7
    #         }

    #         try:
    #             async with aiohttp.ClientSession() as session:
    #                 async with session.post(
    #                     f"{self.base_url}/chat/completions",
    headers = headers,
    json = data,
    timeout = aiohttp.ClientTimeout(total=30)
    #                 ) as response:
    #                     if response.status == 200:
    result = await response.json()
    #                         return result['choices'][0]['message']['content']
    #                     else:
    error_text = await response.text()
                            raise Exception(f"OpenRouter API error {response.status}: {error_text}")
    #         except Exception as e:
                raise Exception(f"OpenRouter request failed: {str(e)}")

    #     def get_available_models(self):
    #         return ["gpt-3.5-turbo", "gpt-4", "claude-3-haiku", "claude-3-sonnet", "llama-2-70b"]

class LMStudioProvider(AIProvider)
    #     """LM Studio local provider."""
    #     def __init__(self):
            super().__init__("LM Studio", "http://localhost:1234/v1", False)

    #     async def chat_completion(self, messages, api_key=None, model="local-model"):
    headers = {"Content-Type": "application/json"}

    data = {
    #             "model": model,
    #             "messages": messages,
    #             "max_tokens": 4000,
    #             "temperature": 0.7
    #         }

    #         try:
    #             async with aiohttp.ClientSession() as session:
    #                 async with session.post(
    #                     f"{self.base_url}/chat/completions",
    headers = headers,
    json = data,
    timeout = aiohttp.ClientTimeout(total=60)
    #                 ) as response:
    #                     if response.status == 200:
    result = await response.json()
    #                         return result['choices'][0]['message']['content']
    #                     else:
    error_text = await response.text()
                            raise Exception(f"LM Studio API error {response.status}: {error_text}")
    #         except Exception as e:
                raise Exception(f"LM Studio connection failed: {str(e)}")

    #     def get_available_models(self):
    #         return ["local-7b", "local-13b", "local-70b"]

class EnhancedNativeNoodleCoreIDE
    #     """Enhanced NoodleCore GUI IDE with all requested features."""

    #     def __init__(self):
    self.root = tk.Tk()
            self.root.title("Enhanced NoodleCore Native GUI IDE v2.0")
            self.root.geometry("1400x900")
    self.root.configure(bg = '#2b2b2b')

    #         # AI providers
    self.ai_providers = {
                "OpenAI": OpenAIProvider(),
                "OpenRouter": OpenRouterProvider(),
                "LM Studio": LMStudioProvider()
    #         }

    #         # AI configuration
    self.current_ai_provider = "OpenRouter"
    self.current_ai_model = "gpt-3.5-turbo"
    self.ai_api_key = ""
    self.ai_roles = self.load_ai_roles()
    self.current_role = None

    #         # File tracking
    self.open_files = {}
    self.current_file = None
    self.file_tabs = {}

    #         # Auto-complete system
    self.suggestions = []
    self.current_suggestion_index = math.subtract(, 1)
    self.suggestion_window = None

    #         # Code analysis
    self.code_errors = []
    self.highlight_tags = {}

    #         # Sandboxed execution
    self.sandbox_processes = {}

    #         # AI Chat sessions
    self.ai_conversations = {}
    self.current_conversation_id = None

    #         # Setup UI
            self.setup_ui()
            self.setup_file_operations()
            self.setup_ai_interface()
            self.setup_auto_complete()
            self.setup_code_analysis()

    #         # Welcome message
            self.show_welcome_message()

    #         # Start background tasks
            self.start_background_tasks()

    #     def run(self):
    #         """Start the IDE main loop."""
            self.root.mainloop()

    #     def setup_ui(self):
    #         """Setup the enhanced UI components."""
    #         # Create main layout
    self.root.grid_rowconfigure(0, weight = 1)
    self.root.grid_columnconfigure(1, weight = 1)

    #         # Menu bar
            self.create_enhanced_menu_bar()

            # Left panel (File Explorer + AI Settings)
            self.create_enhanced_left_panel()

    #         # Center panel (Code Editor with tabs)
            self.create_enhanced_code_editor()

            # Right panel (Terminal + AI Chat
            # Right panel (Terminal + AI Chat + Suggestions)
            self.create_enhanced_right_panel()

            # Bottom panel (Problems/Output)
            self.create_bottom_panel()

    #         # Status bar
            self.create_status_bar()

    #     def create_enhanced_menu_bar(self):
    #         """Create enhanced menu bar with all IDE features."""
    menubar = tk.Menu(self.root)
    self.root.config(menu = menubar)

    #         # File menu
    file_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "File", menu=file_menu)
    file_menu.add_command(label = "New File", command=self.new_file, accelerator="Ctrl+N")
    file_menu.add_command(label = "Open File", command=self.open_file, accelerator="Ctrl+O")
    file_menu.add_command(label = "Save", command=self.save_file, accelerator="Ctrl+S")
    file_menu.add_command(label = "Save As", command=self.save_file_as, accelerator="Ctrl+Shift+S")
            file_menu.add_separator()
    file_menu.add_command(label = "New Project", command=self.new_project)
    file_menu.add_command(label = "Open Project", command=self.open_project)

    #         # AI menu
    ai_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "AI", menu=ai_menu)
    ai_menu.add_command(label = "Code Review", command=self.ai_code_review)
    ai_menu.add_command(label = "Explain Code", command=self.ai_explain_code)
    ai_menu.add_command(label = "Generate Tests", command=self.ai_generate_tests)
    ai_menu.add_command(label = "Optimize Code", command=self.ai_optimize_code)
            ai_menu.add_separator()
    ai_menu.add_command(label = "Convert Python to NoodleCore", command=self.convert_python_to_nc)
    ai_menu.add_command(label = "AI Settings", command=self.show_ai_settings)

    #         # Run menu
    run_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "Run", menu=run_menu)
    run_menu.add_command(label = "Run Current File", command=self.run_current_file, accelerator="F5")
    run_menu.add_command(label = "Run in Sandbox", command=self.run_in_sandbox)
    run_menu.add_command(label = "Debug File", command=self.debug_file, accelerator="F9")

    #         # Help menu
    help_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "Help", menu=help_menu)
    help_menu.add_command(label = "About", command=self.show_about)

    #         # Bind keyboard shortcuts
            self.root.bind('<Control-n>', lambda e: self.new_file())
            self.root.bind('<Control-o>', lambda e: self.open_file())
            self.root.bind('<Control-s>', lambda e: self.save_file())
            self.root.bind('<Control-S>', lambda e: self.save_file_as())
            self.root.bind('<F5>', lambda e: self.run_current_file())
            self.root.bind('<F9>', lambda e: self.debug_file())
            self.root.bind('<Control-space>', lambda e: self.show_auto_complete())
            self.root.bind('<Tab>', lambda e: self.accept_suggestion())

    #     def create_enhanced_left_panel(self):
    #         """Create enhanced left panel with file explorer and AI settings."""
    left_frame = tk.Frame(self.root, width=300, bg='#2b2b2b')
    left_frame.grid(row = 0, column=0, sticky='nsew')
    left_frame.grid_rowconfigure(0, weight = 1)
    left_frame.grid_rowconfigure(1, weight = 1)

    #         # File Explorer
    explorer_frame = tk.LabelFrame(left_frame, text="File Explorer", bg='#2b2b2b', fg='white')
    explorer_frame.grid(row = 0, column=0, sticky='nsew', padx=5, pady=5)

    #         # Tree view with proper file tracking
    self.file_tree = ttk.Treeview(explorer_frame, show='tree')
    self.file_tree.pack(fill = 'both', expand=True, padx=5, pady=5)

    #         # Fix: Store full file paths in tree
            self.file_tree.bind('<Double-1>', self.on_file_double_click)
            self.file_tree.bind('<Button-3>', self.show_context_menu)

    #         # Context menu for file operations
    self.context_menu = tk.Menu(self.root, tearoff=0)
    self.context_menu.add_command(label = "Open", command=self.open_file_from_context)
    self.context_menu.add_command(label = "Edit", command=self.edit_file_from_context)
    self.context_menu.add_command(label = "Delete", command=self.delete_file_from_context)
            self.context_menu.add_separator()
    self.context_menu.add_command(label = "Run", command=self.run_file_from_context)

    #         # Populate file tree with proper file paths
            self.refresh_file_tree()

    #         # AI Settings
    ai_frame = tk.LabelFrame(left_frame, text="AI Configuration", bg='#2b2b2b', fg='white')
    ai_frame.grid(row = 1, column=0, sticky='nsew', padx=5, pady=5)

    #         # Provider selection
    tk.Label(ai_frame, text = "Provider:", bg='#2b2b2b', fg='white').pack(anchor='w')
    self.provider_var = tk.StringVar(value=self.current_ai_provider)
    provider_combo = ttk.Combobox(ai_frame, textvariable=self.provider_var,
    values = list(self.ai_providers.keys()))
    provider_combo.pack(fill = 'x', padx=5, pady=2)
            provider_combo.bind('<<ComboboxSelected>>', self.on_provider_change)

    #         # Model selection
    tk.Label(ai_frame, text = "Model:", bg='#2b2b2b', fg='white').pack(anchor='w', pady=(10,0))
    self.model_var = tk.StringVar(value=self.current_ai_model)
    self.model_combo = ttk.Combobox(ai_frame, textvariable=self.model_var)
    self.model_combo.pack(fill = 'x', padx=5, pady=2)

    #         # API Key
    tk.Label(ai_frame, text = "API Key:", bg='#2b2b2b', fg='white').pack(anchor='w', pady=(10,0))
    self.api_key_var = tk.StringVar(value=self.ai_api_key)
    api_key_entry = tk.Entry(ai_frame, textvariable=self.api_key_var, show='*')
    api_key_entry.pack(fill = 'x', padx=5, pady=2)

    #         # AI Role selection
    tk.Label(ai_frame, text = "AI Role:", bg='#2b2b2b', fg='white').pack(anchor='w', pady=(10,0))
    self.role_var = tk.StringVar(value="Code Assistant")
    role_combo = ttk.Combobox(ai_frame, textvariable=self.role_var)
    role_combo.pack(fill = 'x', padx=5, pady=2)
            role_combo.bind('<<ComboboxSelected>>', self.on_role_change)

    #         # Save button
    save_btn = tk.Button(ai_frame, text="Save Settings", command=self.save_ai_settings,
    bg = '#4CAF50', fg='white')
    save_btn.pack(fill = 'x', padx=5, pady=5)

    #     def create_enhanced_code_editor(self):
    #         """Create enhanced code editor with syntax highlighting."""
    center_frame = tk.Frame(self.root, bg='#2b2b2b')
    center_frame.grid(row = 0, column=1, sticky='nsew')
    center_frame.grid_rowconfigure(0, weight = 1)
    center_frame.grid_columnconfigure(0, weight = 1)

    #         # Tab control for multiple files
    self.notebook = ttk.Notebook(center_frame)
    self.notebook.grid(row = 0, column=0, sticky='nsew', padx=5, pady=5)
            self.notebook.bind('<<NotebookTabChanged>>', self.on_tab_changed)

    #         # Create initial tab
            self.create_new_tab("Welcome to Enhanced NoodleCore IDE")

    #     def create_enhanced_right_panel(self):
    #         """Create enhanced right panel with terminal, AI chat, and suggestions."""
    right_frame = tk.Frame(self.root, width=350, bg='#2b2b2b')
    right_frame.grid(row = 0, column=2, sticky='nsew')
    right_frame.grid_rowconfigure(0, weight = 1)
    right_frame.grid_rowconfigure(1, weight = 1)
    right_frame.grid_rowconfigure(2, weight = 1)

    #         # Terminal
    terminal_frame = tk.LabelFrame(right_frame, text="Terminal", bg='#2b2b2b', fg='white')
    #         terminal
    terminal_frame.grid(row = 0, column=0, sticky='nsew', padx=5, pady=5)

    self.terminal_output = scrolledtext.ScrolledText(terminal_frame,
    bg = '#1e1e1e', fg='#ffffff',
    font = ('Consolas', 10))
    self.terminal_output.pack(fill = 'both', expand=True, padx=5, pady=5)

    #         # Terminal input
    input_frame = tk.Frame(terminal_frame, bg='#2b2b2b')
    input_frame.pack(fill = 'x', padx=5, pady=(0, 5))

    tk.Label(input_frame, text = "$ ", bg='#2b2b2b', fg='white').pack(side='left')
    self.terminal_input = tk.Entry(input_frame, bg='#1e1e1e', fg='white',
    font = ('Consolas', 10), insertbackground='white')
    self.terminal_input.pack(side = 'left', fill='x', expand=True)
            self.terminal_input.bind('<Return>', self.execute_terminal_command)

    #         # AI Chat
    ai_frame = tk.LabelFrame(right_frame, text="AI Assistant", bg='#2b2b2b', fg='white')
    ai_frame.grid(row = 1, column=0, sticky='nsew', padx=5, pady=5)

    self.ai_chat = scrolledtext.ScrolledText(ai_frame, bg='#1e1e1e', fg='#ffffff',
    font = ('Consolas', 10))
    self.ai_chat.pack(fill = 'both', expand=True, padx=5, pady=5)

    #         # AI input with role indicator
    ai_input_frame = tk.Frame(ai_frame, bg='#2b2b2b')
    ai_input_frame.pack(fill = 'x', padx=5, pady=(0, 5))

    #         # Role indicator
    self.role_indicator = tk.Label(ai_input_frame, text="🤖 Code Assistant",
    bg = '#2b2b2b', fg='#4CAF50', font=('Consolas', 8))
    self.role_indicator.pack(side = 'left', padx=(0, 5))

    self.ai_input = tk.Entry(ai_input_frame, bg='#1e1e1e', fg='white',
    font = ('Consolas', 10), insertbackground='white')
    self.ai_input.pack(side = 'left', fill='x', expand=True)
            self.ai_input.bind('<Return>', self.send_ai_message)

    ai_send_btn = tk.Button(ai_input_frame, text="Send", command=self.send_ai_message,
    bg = '#4CAF50', fg='white')
    ai_send_btn.pack(side = 'right', padx=(5, 0))

    #         # Suggestions Panel
    suggestions_frame = tk.LabelFrame(right_frame, text="AI Suggestions", bg='#2b2b2b', fg='white')
    suggestions_frame.grid(row = 2, column=0, sticky='nsew', padx=5, pady=5)

    self.suggestions_list = tk.Listbox(suggestions_frame, bg='#1e1e1e', fg='white',
    font = ('Consolas', 9), selectmode=tk.SINGLE)
    self.suggestions_list.pack(fill = 'both', expand=True, padx=5, pady=5)
            self.suggestions_list.bind('<Double-1>', self.accept_selected_suggestion)

    #         # Suggestion actions
    suggestion_actions = tk.Frame(suggestions_frame, bg='#2b2b2b')
    suggestion_actions.pack(fill = 'x', padx=5, pady=(0, 5))

    accept_btn = tk.Button(suggestion_actions, text="Accept", command=self.accept_selected_suggestion,
    bg = '#4CAF50', fg='white')
    accept_btn.pack(side = 'left', padx=(0, 5))

    reject_btn = tk.Button(suggestion_actions, text="Reject", command=self.reject_selected_suggestion,
    bg = '#f44336', fg='white')
    reject_btn.pack(side = 'left', padx=(0, 5))

    #         improve_btn = tk.Button(suggestion_actions, text="Improve with AI", command=self.improve_code_with_ai,
    bg = '#2196F3', fg='white')
    improve_btn.pack(side = 'right')

    #     def create_bottom_panel(self):
    #         """Create bottom panel for problems and output."""
    bottom_frame = tk.Frame(self.root, height=150, bg='#2b2b2b')
    bottom_frame.grid(row = 1, column=0, columnspan=3, sticky='ew')
    bottom_frame.grid_rowconfigure(0, weight = 1)
    bottom_frame.grid_columnconfigure(0, weight = 1)

    #         # Problems panel
    problems_frame = tk.LabelFrame(bottom_frame, text="Problems", bg='#2b2b2b', fg='white')
    problems_frame.grid(row = 0, column=0, sticky='nsew', padx=5, pady=5)

    self.problems_list = tk.Listbox(problems_frame, bg='#1e1e1e', fg='#ff6b6b',
    font = ('Consolas', 9))
    self.problems_list.pack(fill = 'both', expand=True, padx=5, pady=5)

    #     def create_status_bar(self):
    #         """Create status bar."""
    self.status_bar = tk.Label(self.root, text="Ready", relief='sunken',
    anchor = 'w', bg='#2b2b2b', fg='white')
    self.status_bar.grid(row = 2, column=0, columnspan=3, sticky='ew')

        # File Operations (FIXED double-click functionality)
    #     def refresh_file_tree(self):
    #         """Refresh the file tree with proper file path tracking."""
    #         # Clear existing items
    #         for item in self.file_tree.get_children():
                self.file_tree.delete(item)

    #         # Add current directory
    current_dir = Path.cwd()
    root_id = self.file_tree.insert('', 'end', text=str(current_dir), open=True, tags=('dir',))

    #         # Store full paths in tree items
    self.file_tree.item(root_id, open = True)
            self._populate_directory(root_id, current_dir)

    #     def _populate_directory(self, parent_id, directory):
    #         """Populate directory tree with full file paths."""
    #         try:
    #             for item in sorted(directory.iterdir()):
    #                 if item.is_dir():
    dir_id = self.file_tree.insert(parent_id, 'end', text=f"📁 {item.name}",
    tags = ('dir',), open=False)
    #                     # Store full path in item data
                        self.file_tree.set(dir_id, 'full_path', str(item))
                        self._populate_directory(dir_id, item)
    #                 else:
    #                     # Store full path in item data
    file_id = self.file_tree.insert(parent_id, 'end', text=f"📄 {item.name}",
    tags = ('file',))
                        self.file_tree.set(file_id, 'full_path', str(item))
    #         except PermissionError:
    #             pass

    #     def on_file_double_click(self, event):
    #         """Handle double-click on file tree - FIXED implementation."""
    selection = self.file_tree.selection()
    #         if selection:
    item = selection[0]
    item_tags = self.file_tree.item(item, 'tags')

    #             if 'file' in item_tags:
    #                 # Get full file path from tree item data
    file_path = self.file_tree.set(item, 'full_path')
    #                 if file_path:
                        self.open_file_helper(file_path)

    #     def show_context_menu(self, event):
    #         """Show context menu for file operations."""
    item = self.file_tree.identify_row(event.y)
    #         if item:
                self.file_tree.selection_set(item)
                self.context_menu.post(event.x_root, event.y_root)

    #     def open_file_from_context(self):
    #         """Open file from context menu."""
    selection = self.file_tree.selection()
    #         if selection:
    item = selection[0]
    file_path = self.file_tree.set(item, 'full_path')
    #             if file_path and Path(file_path).is_file():
                    self.open_file_helper(file_path)

    #     def edit_file_from_context(self):
    #         """Edit file from context menu."""
            self.open_file_from_context()

    #     def delete_file_from_context(self):
    #         """Delete file from context menu."""
    selection = self.file_tree.selection()
    #         if selection:
    item = selection[0]
    file_path = self.file_tree.set(item, 'full_path')
    #             if file_path and Path(file_path).is_file():
    #                 if messagebox.askyesno("Delete File", f"Delete {file_path}?"):
    #                     try:
                            Path(file_path).unlink()
                            self.refresh_file_tree()
    self.status_bar.config(text = f"Deleted: {file_path}")
    #                     except Exception as e:
                            messagebox.showerror("Error", f"Could not delete file: {str(e)}")

    #     def run_file_from_context(self):
    #         """Run file from context menu."""
            self.open_file_from_context()
    #         if self.current_file:
                self.run_current_file()

    #     def open_file_helper(self, file_path):
    #         """Helper to open a file - FIXED implementation."""
    #         try:
    #             with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

    tab_title = os.path.basename(file_path)
    text_widget = self.create_new_tab(tab_title)
                text_widget.insert('1.0', content)

    self.open_files[file_path] = text_widget
    self.current_file = file_path

    #             # Store reverse mapping
    self.file_tabs[text_widget] = file_path

    #             # Analyze code for errors
                self.analyze_code(file_path, content)

    self.status_bar.config(text = f"Opened: {file_path}")

    #         except Exception as e:
                messagebox.showerror("Error", f"Could not open file: {str(e)}")

    #     def create_new_tab(self, title):
    #         """Create a new editor tab with enhanced features."""
    frame = tk.Frame(self.notebook)
    self.notebook.add(frame, text = title)

    #         # Text widget with syntax highlighting support
    text_widget = tk.Text(frame, bg='#1e1e1e', fg='#ffffff',
    font = ('Consolas', 12), wrap='none', undo=True)
    text_widget.pack(fill = 'both', expand=True, padx=
    5, pady = 5)

    #         # Add scrollbars
    v_scrollbar = tk.Scrollbar(frame, orient='vertical', command=text_widget.yview)
    h_scrollbar = tk.Scrollbar(frame, orient='horizontal', command=text_widget.xview)
    text_widget.configure(yscrollcommand = v_scrollbar.set, xscrollcommand=h_scrollbar.set)

    #         # Bind keyboard events for auto-complete
            text_widget.bind('<KeyPress>', self.on_key_press)
            text_widget.bind('<KeyRelease>', self.on_key_release)

    #         return text_widget

    #     # AI Role Management System
    #     def load_ai_roles(self):
            """Load AI roles (Cline/RooCode/Costrict style)."""
    default_roles = [
                AIRole(
    name = "Code Assistant",
    description = "General code assistance and explanation",
    system_prompt = "You are a helpful code assistant. Provide clear explanations and suggestions.",
    capabilities = ["explain", "suggest", "review"]
    #             ),
                AIRole(
    name = "Code Reviewer",
    #                 description="Professional code review with best practices",
    system_prompt = "You are an expert code reviewer. Focus on security, performance, and maintainability.",
    capabilities = ["review", "security", "performance", "style"]
    #             ),
                AIRole(
    name = "Debugger",
    description = "Debug and fix code issues",
    #                 system_prompt="You are an expert debugger. Help identify and fix bugs with detailed explanations.",
    capabilities = ["debug", "fix", "trace"]
    #             ),
                AIRole(
    name = "Architecture Advisor",
    description = "System design and architecture guidance",
    system_prompt = "You are a software architect. Provide guidance on system design and best practices.",
    capabilities = ["architecture", "design", "scalability"]
    #             ),
                AIRole(
    name = "NoodleCore Expert",
    description = "NoodleCore-specific development assistance",
    #                 system_prompt="You are an expert in NoodleCore development. Help with .nc files and NoodleCore features.",
    capabilities = ["noodlecore", "conversion", "optimization"]
    #             )
    #         ]

    #         # Try to load from config file
    #         try:
    config_path = Path.home() / '.noodlecore' / 'ai_roles.json'
    #             if config_path.exists():
    #                 with open(config_path, 'r') as f:
    roles_data = json.load(f)
    #                     # Convert back to AIRole objects
    roles = []
    #                     for role_data in roles_data:
    role = AIRole(
    #                             role_data['name'],
    #                             role_data['description'],
    #                             role_data['system_prompt'],
    #                             role_data['capabilities']
    #                         )
    role.id = role_data['id']
                            roles.append(role)
    #                     return roles
    #         except Exception:
    #             pass

    #         return default_roles

    #     def on_role_change(self, event=None):
    #         """Handle AI role change."""
    role_name = self.role_var.get()
    #         for role in self.ai_roles:
    #             if role.name == role_name:
    self.current_role = role
    self.role_indicator.config(text = f"🤖 {role.name}")
    #                 break

    #     # Enhanced AI Integration
    #     async def send_real_ai_message(self, message):
    #         """Send real AI message using configured provider."""
    #         if not self.current_ai_provider or not self.current_ai_model:
                messagebox.showwarning("AI Not Configured", "Please configure AI provider and model first.")
    #             return

    #         try:
    #             # Add user message to chat
                self.ai_chat.insert(tk.END, f"User: {message}\n")
                self.ai_input.delete(0, tk.END)

    #             # Show thinking indicator
                self.ai_chat.insert(tk.END, "🤖 AI: Thinking...\n")
                self.ai_chat.see(tk.END)

    #             # Prepare messages
    messages = []
    #             if self.current_role:
                    messages.append({"role": "system", "content": self.current_role.system_prompt})

    #             # Add context from current file
    #             if self.current_file:
    text_widget = self.open_files.get(self.current_file)
    #                 if text_widget:
    content = text_widget.get('1.0', tk.END)
    #                     if content:
                            messages.append({
    #                             "role": "system",
    #                             "content": f"Current file content:\n```\n{content}\n```"
    #                         })

                messages.append({"role": "user", "content": message})

    #             # Get provider and make API call
    provider = self.ai_providers.get(self.current_ai_provider)
    #             if not provider:
                    raise Exception("AI provider not found")

    #             # Make async call
    response = await provider.chat_completion(
    messages = messages,
    #                 api_key=self.ai_api_key if provider.api_key_required else None,
    model = self.current_ai_model
    #             )

    #             # Remove thinking indicator and add response
                self.ai_chat.delete('end-2l', 'end-1l')  # Remove "Thinking..." line
                self.ai_chat.insert(tk.END, f"🤖 AI: {response}\n\n")
                self.ai_chat.see(tk.END)

    #         except Exception as e:
    #             # Remove thinking indicator
                self.ai_chat.delete('end-2l', 'end-1l')
                self.ai_chat.insert(tk.END, f"❌ AI Error: {str(e)}\n\n")
                self.ai_chat.see(tk.END)

    #     def send_ai_message(self, event=None):
    #         """Send AI message (wrapper for async call)."""
    message = self.ai_input.get().strip()
    #         if not message:
    #             return

    #         # Run async function in thread
    #         def run_async():
    loop = asyncio.new_event_loop()
                asyncio.set_event_loop(loop)
    #             try:
                    loop.run_until_complete(self.send_real_ai_message(message))
    #             finally:
                    loop.close()

    threading.Thread(target = run_async, daemon=True).start()

    #     # Auto-complete System
    #     def setup_auto_complete(self):
    #         """Setup auto-complete system."""
    self.python_keywords = [
    #             'def', 'class', 'if', 'elif', 'else', 'for', 'while', 'try', 'except', 'finally',
    #             'import', 'from', 'as', 'return', 'yield', 'break', 'continue', 'pass', 'with',
    #             'and', 'or', 'not', 'in', 'is', 'lambda', 'global', 'nonlocal', 'assert',
    #             'del', 'True', 'False', 'None'
    #         ]

    self.noodlecore_keywords = [
    #             'define', 'function', 'class', 'if', 'else', 'loop', 'for', 'while', 'try',
    #             'catch', 'return', 'yield', 'break', 'continue', 'import', 'from', 'as',
    #             'and', 'or', 'not', 'in', 'is', 'lambda', 'var', 'let', 'const', 'module'
    #         ]

    #     def on_key_press(self, event):
    #         """Handle key press for auto-complete."""
    #         if event.keysym == 'Tab' and self.suggestions:
                self.accept_suggestion()
    #             return 'break'

    #     def on_key_release(self, event):
    #         """Handle key release for auto-complete triggers."""
    #         if event.keysym in ['period', 'space'] or len(event.char) == 1 and event.char.isalnum():
                self.check_auto_complete()

    #     def check_auto_complete(self):
    #         """Check if auto-complete should be shown."""
    text_widget = self.get_current_text_widget()
    #         if not text_widget:
    #             return

    #         # Get current cursor position and context
    cursor_pos = text_widget.index(tk.INSERT)
    line_start = f"{cursor_pos.split('.')[0]}.0"

    #         # Get text before cursor
    text_before = text_widget.get(line_start, cursor_pos)

    #         # Simple completion triggers
    #         if text_before.endswith('.') or text_before.endswith(' ') or len(text_before) > 2:
                self.generate_suggestions(text_before)

    #     def generate_suggestions(self, context):
    #         """Generate auto-complete suggestions."""
            self.suggestions.clear()
            self.suggestions_list.delete(0, tk.END)

    #         # Get current file type
    #         file_ext = Path(self.current_file).suffix if self.current_file else ''

    #         # Generate keyword suggestions
    #         keywords = self.python_keywords if file_ext == '.py' else self.noodlecore_keywords
    last_word = math.subtract(context.split()[, 1].lower())

    #         for keyword in keywords:

    #             if keyword.startswith(last_word):
    suggestion = Suggestion(
    text = keyword,
    start_pos = None,  # Will be set when accepted
    end_pos = None,
    suggestion_type = "keyword",
    confidence = 0.8
    #                 )
                    self.suggestions.append(suggestion)
                    self.suggestions_list.insert(tk.END, f"💡 {keyword}")

    #         # If we have suggestions, show them
    #         if self.suggestions:
                self.suggestions_list.selection_set(0)

    #     def accept_suggestion(self):
    #         """Accept selected suggestion with Tab key."""
    #         if not self.suggestions:
    #             return

    selected = self.suggestions_list.curselection()
    #         if selected:
    index = selected[0]
    suggestion = self.suggestions[index]

    text_widget = self.get_current_text_widget()
    #             if text_widget:
    #                 # Insert suggestion at cursor position
                    text_widget.insert(tk.INSERT, suggestion.text)

    #                 # Mark as accepted
    suggestion.accepted = True

    #                 # Clear suggestions
                    self.clear_suggestions()

    #     def show_auto_complete(self):
            """Show auto-complete manually (Ctrl+Space)."""
    text_widget = self.get_current_text_widget()
    #         if text_widget:
    #             # Get text before cursor
    cursor_pos = text_widget.index(tk.INSERT)
    line_start = f"{cursor_pos.split('.')[0]}.0"
    context = text_widget.get(line_start, cursor_pos)

                self.generate_suggestions(context)

    #     def clear_suggestions(self):
    #         """Clear all suggestions."""
            self.suggestions.clear()
            self.suggestions_list.delete(0, tk.END)

    #     def get_current_text_widget(self):
    #         """Get the currently active text widget."""
    current_tab = self.notebook.select()
    #         if current_tab:
    frame = self.root.nametowidget(current_tab)
    #             for widget in frame.winfo_children():
    #                 if isinstance(widget, tk.Text):
    #                     return widget
    #         return None

    #     # Python to NoodleCore Conversion
    #     async def convert_python_to_nc(self):
    #         """Convert Python code to NoodleCore using AI."""
    #         if not self.current_file or not self.current_file.endswith('.py'):
                messagebox.showwarning("Wrong File", "Please open a Python file (.py) first.")
    #             return

    #         # Get Python code
    text_widget = self.open_files.get(self.current_file)
    #         if not text_widget:
                messagebox.showwarning("No Code", "No code found in current file.")
    #             return

    python_code = text_widget.get('1.0', tk.END)

    #         if not python_code.strip():
                messagebox.showwarning("Empty File", "The Python file is empty.")
    #             return

    #         try:
    self.status_bar.config(text = "Converting Python to NoodleCore...")

    #             # Prepare conversion request
    conversion_prompt = f"""Convert the following Python code to NoodleCore (.nc) format:

# ```python
# {python_code}
# ```

# Please provide:
# 1. The converted NoodleCore code
# 2. A brief explanation of the conversion
# 3. Any important notes about the NoodleCore syntax used

# NoodleCore syntax uses:
# - 'define' instead of 'def'
# - 'function' for function declarations
# - 'class' for class declarations
# - 'var'/'let' for variable declarations
# - '#' for comments instead of '#'
# - Different control flow syntax

# Return the response in this format:
 = == NODLECORE CODE ===
# [converted code here]
 = == EXPLANATION ===
# [explanation here]
 = == NOTES ===
# [notes here]"""

#             # Use current AI provider
provider = self.ai_providers.get(self.current_ai_provider)
#             if not provider:
                raise Exception("AI provider not configured")

#             # Make conversion request
response = await provider.chat_completion(
messages = [{"role": "user", "content": conversion_prompt}],
#                 api_key=self.ai_api_key if provider.api_key_required else None,
model = self.current_ai_model
#             )

#             # Parse response
parts = response.split("=== NODLECORE CODE ===")
#             if len(parts) < 2:
                raise Exception("Invalid AI response format")

rest = parts[1]
code_part = rest.split("=== EXPLANATION ===")[0].strip()
#             explanation_part = rest.split("=== EXPLANATION ===")[1] if len(rest.split("=== EXPLANATION ===")) > 1 else ""
#             notes_part = rest.split("=== NOTES ===")[1] if "=== NOTES ===" in rest else ""

#             # Create new tab with NoodleCore code
nc_file_path = self.current_file.replace('.py', '.nc')
nc_title = f"{Path(nc_file_path).name}"

nc_text_widget = self.create_new_tab(nc_title)
            nc_text_widget.insert('1.0', code_part)

#             # Store mapping
self.open_files[nc_file_path] = nc_text_widget

#             # Add conversion info to AI chat
            self.ai_chat.insert(tk.END, f"🔄 Python to NoodleCore Conversion:\n")
            self.ai_chat.insert(tk.END, f"File: {self.current_file}\n")
            self.ai_chat.insert(tk.END, f"Result: {nc_file_path}\n")
            self.ai_chat.insert(tk.END, f"Explanation: {explanation_part}\n")
#             if notes_part:
                self.ai_chat.insert(tk.END, f"Notes: {notes_part}\n")
            self.ai_chat.insert(tk.END, "\n")

self.status_bar.config(text = f"Converted {self.current_file} to {nc_file_path}")

#         except Exception as e:
            messagebox.showerror("Conversion Error", f"Failed to convert Python to NoodleCore: {str(e)}")
self.status_bar.config(text = "Conversion failed")

#     def convert_python_to_nc_sync(self):
#         """Sync wrapper for Python to NoodleCore conversion."""
#         def run_conversion():
loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
#             try:
                loop.run_until_complete(self.convert_python_to_nc())
#             finally:
                loop.close()

threading.Thread(target = run_conversion, daemon=True).start()

#     # Code Analysis System
#     def setup_code_analysis(self):
#         """Setup code analysis for error detection."""
#         pass

#     def analyze_code(self, file_path, content):
#         """Analyze code for errors and suggestions."""
        self.code_errors.clear()
        self.problems_list.delete(0, tk.END)

#         try:
#             if file_path.endswith('.py'):
                self.analyze_python_code(content)
#             elif file_path.endswith('.nc'):
                self.analyze_noodlecore_code(content)

#         except Exception as e:
            self.problems_list.insert(tk.END, f"Analysis error: {str(e)}")

#     def analyze_python_code(self, content):
#         """Analyze Python code for syntax errors."""
#         try:
            ast.parse(content)
#         except SyntaxError as e:
error_msg = f"Syntax Error: {e.msg} at line {e.lineno}"
            self.code_errors.append(error_msg)
            self.problems_list.insert(tk.END, f"❌ {error_msg}")

#         except Exception as e:
error_msg = f"Analysis Error: {str(e)}"
            self.code_errors.append(error_msg)
            self.problems_list.insert(tk.END, f"⚠️ {error_msg}")

#     def analyze_noodlecore_code(self, content):
        """Analyze NoodleCore code (basic validation)."""
#         # Basic NoodleCore syntax checking
#         if content.count('define') != content.count('function'):
error_msg = "Unmatched define/function pairs"
            self.code_errors.append(error_msg)
            self.problems_list.insert(tk.END, f"⚠️ {error_msg}")

#     # Sandbox Execution System
#     async def run_in_sandbox(self):
#         """Run current file in sandboxed environment."""
#         if not self.current_file:
            messagebox.showwarning("No File", "Please open a file first.")
#             return

#         try:
self.status_bar.config(text = "Running in sandbox...")

#             # Create temporary directory for sandbox
sandbox_dir = Path.home() / '.noodlecore' / 'sandboxes' / str(uuid.uuid4())
sandbox_dir.mkdir(parents = True, exist_ok=True)

#             # Copy file to sandbox
source_file = Path(self.current_file)
sandbox_file = math.divide(sandbox_dir, source_file.name)
            shutil.copy2(source_file, sandbox_file)

#             # Run in isolated process
#             if self.current_file.endswith('.py'):
cmd = [sys.executable, str(sandbox_file)]
#             elif self.current_file.endswith('.nc'):
#                 # For NoodleCore files, you would integrate with NoodleCore runtime
cmd = ["noodlecore", str(sandbox_file)]
#             else:
#                 raise Exception("Unsupported file type for sandbox execution")

#             # Execute with resource limits (basic implementation)
process = await asyncio.create_subprocess_exec(
#                 *cmd,
stdout = asyncio.subprocess.PIPE,
stderr = asyncio.subprocess.PIPE,
cwd = str(sandbox_dir)
#             )

self.sandbox_processes[str(sandbox_dir)] = process

#             # Run
#             # Show output in terminal
stdout, stderr = await process.communicate()

self.terminal_output.insert(tk.END, f"\n = == Sandbox Execution Results ===\n")
#             if stdout:
                self.terminal_output.insert(tk.END, f"Output:\n{stdout.decode()}\n")
#             if stderr:
                self.terminal_output.insert(tk.END, f"Errors:\n{stderr.decode()}\n")
            self.terminal_output.insert(tk.END, f"Exit code: {process.returncode}\n")
            self.terminal_output.see(tk.END)

#             # Clean up sandbox
shutil.rmtree(sandbox_dir, ignore_errors = True)

self.status_bar.config(text = "Sandbox execution completed")

#         except Exception as e:
            self.terminal_output.insert(tk.END, f"\n❌ Sandbox execution failed: {str(e)}\n")
self.status_bar.config(text = "Sandbox execution failed")

#     def run_in_sandbox_sync(self):
#         """Sync wrapper for sandbox execution."""
#         def run_async():
loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
#             try:
                loop.run_until_complete(self.run_in_sandbox())
#             finally:
                loop.close()

threading.Thread(target = run_async, daemon=True).start()

#     # File Operations
#     def new_file(self):
#         """Create new file."""
title = f"Untitled-{len(self.open_files) + 1}"
text_widget = self.create_new_tab(title)

#     def open_file(self):
#         """Open file dialog."""
file_path = filedialog.askopenfilename(
title = "Open File",
filetypes = [
                ("Python files", "*.py"),
                ("NoodleCore files", "*.nc"),
                ("All files", "*.*")
#             ]
#         )

#         if file_path:
            self.open_file_helper(file_path)

#     def save_file(self):
#         """Save current file."""
#         if not self.current_file:
            self.save_file_as()
#             return

#         try:
text_widget = self.get_current_text_widget()
#             if text_widget:
content = text_widget.get('1.0', tk.END)
#                 with open(self.current_file, 'w', encoding='utf-8') as f:
                    f.write(content)
self.status_bar.config(text = f"Saved: {self.current_file}")
#         except Exception as e:
            messagebox.showerror("Error", f"Could not save file: {str(e)}")

#     def save_file_as(self):
#         """Save file as."""
#         if not self.current_file:
#             # Create temporary file path for new file
new_file = filedialog.asksaveasfilename(
title = "Save As",
defaultextension = ".py",
filetypes = [
                    ("Python files", "*.py"),
                    ("NoodleCore files", "*.nc"),
                    ("All files", "*.*")
#                 ]
#             )
#             if new_file:
self.current_file = new_file
tab_title = os.path.basename(new_file)
current_tab = self.notebook.select()
self.notebook.tab(current_tab, text = tab_title)
#         else:
#             # Save as for existing file
new_path = filedialog.asksaveasfilename(
title = "Save As",
initialdir = os.path.dirname(self.current_file),
initialfile = os.path.basename(self.current_file)
#             )
#             if new_path:
self.current_file = new_path

        self.save_file()

#     def new_project(self):
#         """Create new project."""
project_dir = filedialog.askdirectory(title="Select Project Directory")
#         if project_dir:
#             # Create project structure
project_name = os.path.basename(project_dir)
os.makedirs(project_dir, exist_ok = True)

#             # Add to file tree
            self.refresh_file_tree()
self.status_bar.config(text = f"Created project: {project_name}")

#     def open_project(self):
#         """Open project."""
project_dir = filedialog.askdirectory(title="Select Project Directory")
#         if project_dir:
#             # Set as current working directory
            os.chdir(project_dir)
            self.refresh_file_tree()
self.status_bar.config(text = f"Opened project: {os.path.basename(project_dir)}")

#     # AI Functions
#     def ai_code_review(self):
#         """AI code review for current file."""
#         if not self.current_file:
            messagebox.showwarning("No File", "Please open a file first.")
#             return

#         # Add current file to AI chat
text_widget = self.get_current_text_widget()
#         if text_widget:
content = text_widget.get('1.0', tk.END)
            self.ai_input.delete(0, tk.END)
#             self.ai_input.insert(0, f"Please review this {Path(self.current_file).suffix} code for issues, style, and improvements:")

#     def ai_explain_code(self):
#         """AI explain code functionality."""
#         if not self.current_file:
            messagebox.showwarning("No File", "Please open a file first.")
#             return

text_widget = self.get_current_text_widget()
#         if text_widget:
content = text_widget.get('1.0', tk.END)
            self.ai_input.delete(0, tk.END)
            self.ai_input.insert(0, "Please explain what this code does:")

#     def ai_generate_tests(self):
#         """AI generate tests for current code."""
#         if not self.current_file:
            messagebox.showwarning("No File", "Please open a file first.")
#             return

text_widget = self.get_current_text_widget()
#         if text_widget:
content = text_widget.get('1.0', tk.END)
            self.ai_input.delete(0, tk.END)
#             self.ai_input.insert(0, "Please generate test cases for this code:")

#     def ai_optimize_code(self):
#         """AI optimize current code."""
#         if not self.current_file:
            messagebox.showwarning("No File", "Please open a file first.")
#             return

text_widget = self.get_current_text_widget()
#         if text_widget:
content = text_widget.get('1.0', tk.END)
            self.ai_input.delete(0, tk.END)
#             self.ai_input.insert(0, "Please optimize this code for better performance:")

#     def show_ai_settings(self):
#         """Show AI settings dialog."""
#         # For now, just focus on the AI settings panel
#         pass

#     # Terminal Functions
#     def execute_terminal_command(self, event=None):
#         """Execute terminal command."""
command = self.terminal_input.get().strip()
#         if not command:
#             return

        self.terminal_input.delete(0, tk.END)
        self.terminal_output.insert(tk.END, f"$ {command}\n")
        self.terminal_output.see(tk.END)

#         # Execute command in background
#         def run_command():
#             try:
process = subprocess.Popen(
#                     command,
shell = True,
stdout = subprocess.PIPE,
stderr = subprocess.PIPE,
text = True
#                 )

#                 # Show output
stdout, stderr = process.communicate()

#                 if stdout:
                    self.terminal_output.insert(tk.END, stdout)
#                 if stderr:
                    self.terminal_output.insert(tk.END, stderr)

                self.terminal_output.see(tk.END)

#             except Exception as e:
                self.terminal_output.insert(tk.END, f"Error: {str(e)}\n")
                self.terminal_output.see(tk.END)

threading.Thread(target = run_command, daemon=True).start()

#     def run_current_file(self):
#         """Run current file."""
#         if not self.current_file:
            messagebox.showwarning("No File", "Please open a file first.")
#             return

#         # Run in normal environment or sandbox based on user choice
#         result = messagebox.askyesno("Run Options", "Run in sandbox for security?")
#         if result:
            self.run_in_sandbox_sync()
#         else:
            self.run_file_normally()

#     def run_file_normally(self):
#         """Run file normally."""
#         try:
#             if self.current_file.endswith('.py'):
#                 # Run Python file
process = subprocess.Popen(
#                     [sys.executable, self.current_file],
stdout = subprocess.PIPE,
stderr = subprocess.PIPE,
text = True
#                 )

self.terminal_output.insert(tk.END, f"\n = == Running {self.current_file} ===\n")
stdout, stderr = process.communicate()

#                 if stdout:
                    self.terminal_output.insert(tk.END, stdout)
#                 if stderr:
                    self.terminal_output.insert(tk.END, stderr)

                self.terminal_output.insert(tk.END, f"Exit code: {process.returncode}\n")
                self.terminal_output.see(tk.END)

#             else:
#                 messagebox.showinfo("Unsupported", "Running is only supported for Python files.")

#         except Exception as e:
            self.terminal_output.insert(tk.END, f"❌ Run failed: {str(e)}\n")
            self.terminal_output.see(tk.END)

#     def debug_file(self):
#         """Debug current file."""
#         if not self.current_file:
            messagebox.showwarning("No File", "Please open a file first.")
#             return

#         if not self.current_file.endswith('.py'):
#             messagebox.showwarning("Wrong Type", "Debugging is only supported for Python files.")
#             return

#         # Simple debug - run with pdb
#         try:
process = subprocess.Popen(
#                 [sys.executable, "-m", "pdb", self.current_file],
stdin = subprocess.PIPE,
stdout = subprocess.PIPE,
stderr = subprocess.PIPE,
text = True
#             )

self.terminal_output.insert(tk.END, f"\n = == Debugging {self.current_file} ===\n")
            self.terminal_output.see(tk.END)

#         except Exception as e:
            self.terminal_output.insert(tk.END, f"❌ Debug failed: {str(e)}\n")
            self.terminal_output.see(tk.END)

#     # Suggestion System
#     def accept_selected_suggestion(self,
#     def accept_selected_suggestion(self, event=None):
#         """Accept selected suggestion from suggestions panel."""
selection = self.suggestions_list.curselection()
#         if selection and selection[0] < len(self.suggestions):
suggestion = self.suggestions[selection[0]]
suggestion.accepted = True

#             # Insert into editor
text_widget = self.get_current_text_widget()
#             if text_widget:
                text_widget.insert(tk.INSERT, suggestion.text)

#             # Remove from list
            self.suggestions_list.delete(selection[0])
            self.suggestions.pop(selection[0])

#     def reject_selected_suggestion(self):
#         """Reject selected suggestion."""
selection = self.suggestions_list.curselection()
#         if selection and selection[0] < len(self.suggestions):
            self.suggestions_list.delete(selection[0])
            self.suggestions.pop(selection[0])

#     def improve_code_with_ai(self):
#         """Improve selected code with AI."""
text_widget = self.get_current_text_widget()
#         if not text_widget:
            messagebox.showwarning("No Editor", "Please open an editor tab first.")
#             return

#         # Get selected text or entire content
#         try:
selected_text = text_widget.get(tk.SEL_FIRST, tk.SEL_LAST)
prompt = f"Please improve this code:\n\n{selected_text}"
#         except tk.TclError:
#             # No selection, use entire content
selected_text = text_widget.get('1.0', tk.END)
prompt = f"Please improve this entire code:\n\n{selected_text}"

#         # Add to AI chat
        self.ai_input.delete(0, tk.END)
        self.ai_input.insert(0, prompt)

#     # AI Provider Configuration
#     def on_provider_change(self, event=None):
#         """Handle AI provider change."""
provider_name = self.provider_var.get()
self.current_ai_provider = provider_name

#         # Update model list
provider = self.ai_providers.get(provider_name)
#         if provider:
#             # Update model list with custom models
            self.update_provider_models()

#     def update_provider_models(self):
#         """Update provider model list with custom models."""
provider = self.ai_providers.get(self.current_ai_provider)
#         if provider:
#             # Get default models
default_models = provider.get_available_models()

#             # Load custom models from config
#             try:
config_path = Path.home() / '.noodlecore' / 'ai_config.json'
#                 if config_path.exists():
#                     with open(config_path, 'r') as f:
config = json.load(f)

custom_models = []
#                     if 'custom_models' in config and self.current_ai_provider in config['custom_models']:
custom_models = config['custom_models'][self.current_ai_provider]

#                     # Combine default and custom models
#                     all_models = default_models + [m for m in custom_models if m not in default_models]
self.model_combo['values'] = all_models

#                     # Set current model if it exists
#                     if self.current_ai_model and self.current_ai_model in all_models:
                        self.model_var.set(self.current_ai_model)
#                     else:
#                         self.model_var.set(all_models[0] if all_models else "")
#                 else:
self.model_combo['values'] = default_models
#                     self.model_var.set(default_models[0] if default_models else "")

#             except Exception:
#                 # Fallback to default models
self.model_combo['values'] = default_models
#                 self.model_var.set(default_models[0] if default_models else "")

#     def save_ai_settings(self):
#         """Save AI settings."""
self.current_ai_provider = self.provider_var.get()
self.current_ai_model = self.model_var.get()
self.ai_api_key = self.api_key_var.get()

#         # Save to config file
#         try:
config_dir = Path.home() / '.noodlecore'
config_dir.mkdir(exist_ok = True)

#             # Load existing config to preserve custom models
config_path = config_dir / 'ai_config.json'
#             if config_path.exists():
#                 with open(config_path, 'r') as f:
config = json.load(f)
#             else:
config = {}

#             # Update config with current settings
            config.update({
#                 'provider': self.current_ai_provider,
#                 'model': self.current_ai_model,
#                 'api_key': self.ai_api_key,
                'role': self.role_var.get()
#             })

#             # Add custom models if model was manually entered
provider = self.ai_providers.get(self.current_ai_provider)
#             if provider:
default_models = set(provider.get_available_models())
custom_models = set()

#                 # Load existing custom models
#                 if 'custom_models' in config and self.current_ai_provider in config['custom_models']:
custom_models = set(config['custom_models'][self.current_ai_provider])

#                 # Add current model if it's not in default models
#                 if self.current_ai_model and self.current_ai_model not in default_models:
                    custom_models.add(self.current_ai_model)

#                 # Update custom models
#                 if 'custom_models' not in config:
config['custom_models'] = {}
config['custom_models'][self.current_ai_provider] = list(custom_models)

#             with open(config_path, 'w') as f:
json.dump(config, f, indent = 2)

#             # Update provider's available models with custom models
            self.update_provider_models()

            messagebox.showinfo("Success", "AI settings saved successfully!")

#         except Exception as e:
            messagebox.showerror("Error", f"Failed to save settings: {str(e)}")

#     # Auto-improvement feature - AI fixes errors automatically
#     async def auto_fix_code_errors(self):
#         """Automatically fix code errors using AI."""
#         if not self.code_errors or not self.current_file:
#             return

#         try:
#             self.status_bar.config(text="Fixing errors with AI...")

text_widget = self.open_files.get(self.current_file)
#             if not text_widget:
#                 return

current_code = text_widget.get('1.0', tk.END)

#             # Prepare error fixing request
error_text = "\n".join(self.code_errors)
fix_prompt = f"""Fix the following errors in this code:

# ```python
# {current_code}
# ```

# Errors to fix:
# {error_text}

# Please provide:
# 1. The corrected code
# 2. A brief explanation of what was fixed
# 3. Why these fixes resolve the errors

# Return the response in this format:
 = == FIXED CODE ===
# [corrected code here]
 = == EXPLANATION ===
# [explanation here]
 = == WHAT WAS FIXED ===
# [list of specific fixes]"""

#             # Use current AI provider
provider = self.ai_providers.get(self.current_ai_provider)
#             if not provider:
                raise Exception("AI provider not configured")

#             # Make fix request
response = await provider.chat_completion(
messages = [{"role": "user", "content": fix_prompt}],
#                 api_key=self.ai_api_key if provider.api_key_required else None,
model = self.current_ai_model
#             )

#             # Parse response
parts = response.split("=== FIXED CODE ===")
#             if len(parts) < 2:
                raise Exception("Invalid AI response format")

rest = parts[1]
code_part = rest.split("=== EXPLANATION ===")[0].strip()
#             explanation_part = rest.split("=== EXPLANATION ===")[1] if len(rest.split("=== EXPLANATION ===")) > 1 else ""
#             fixes_part = rest.split("=== WHAT WAS FIXED ===")[1] if "=== WHAT WAS FIXED ===" in rest else ""

#             # Ask user if they want to apply the fixes
#             message = f"AI found fixes for your code:\n\n{explanation_part}\n\nWhat was fixed:\n{fixes_part}\n\nApply these fixes automatically?"

result = messagebox.askyesno("Apply AI Fixes", message)
#             if result:
#                 # Apply the fixes
                text_widget.delete('1.0', tk.END)
                text_widget.insert('1.0', code_part)

#                 # Clear errors
                self.code_errors.clear()
                self.problems_list.delete(0, tk.END)
                self.problems_list.insert(tk.END, "✅ All errors fixed by AI!")

#                 # Add info to AI chat
                self.ai_chat.insert(tk.END, f"🔧 Auto-fix applied:\n")
                self.ai_chat.insert(tk.END, f"File: {self.current_file}\n")
                self.ai_chat.insert(tk.END, f"Fixes: {fixes_part}\n\n")

self.status_bar.config(text = "Error fixing completed")

#         except Exception as e:
            messagebox.showerror("Auto-fix Error", f"Failed to auto-fix errors: {str(e)}")
self.status_bar.config(text = "Auto-fix failed")

#     def auto_fix_code_errors_sync(self):
#         """Sync wrapper for auto-fix function."""
#         def run_fix():
loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
#             try:
                loop.run_until_complete(self.auto_fix_code_errors())
#             finally:
                loop.close()

threading.Thread(target = run_fix, daemon=True).start()

#     # Event Handlers
#     def on_tab_changed(self, event=None):
#         """Handle tab change."""
current_tab = self.notebook.select()
#         if current_tab:
frame = self.root.nametowidget(current_tab)
#             for widget in frame.winfo_children():
#                 if isinstance(widget, tk.Text):
#                     # Find file path for this text widget
#                     for file_path, text_widget in self.open_files.items():
#                         if text_widget == widget:
self.current_file = file_path
#                             break
#                     break

#     def show_welcome_message(self):
#         """Show welcome message in AI chat."""
welcome_msg = """🚀 Welcome to Enhanced NoodleCore IDE!

# This enhanced IDE includes:
✅ Real AI integration (OpenAI, OpenRouter, LM Studio)
# ✅ Auto-complete with Tab acceptance
# ✅ Python → NoodleCore conversion
✅ AI role management (Cline/RooCode/Costrict style)
# ✅ Sandboxed script execution
# ✅ Code improvement with AI
# ✅ Real-time code analysis
# ✅ Syntax highlighting
# ✅ Project management

# To get started:
# 1. Configure AI in the left panel
# 2. Open a Python or NoodleCore file
# 3. Use AI assistant for code help
4. Try the auto-complete (Ctrl+Space or Tab)
# 5. Convert Python to NoodleCore via AI menu

# Enjoy coding! 🎉"""

        self.ai_chat.insert(tk.END, welcome_msg)
        self.ai_chat.see(tk.END)

#     def start_background_tasks(self):
#         """Start background tasks."""
#         # Load saved AI settings
        self.load_saved_settings()

#         # Periodic code analysis
#         def periodic_analysis():
#             while True:
#                 try:
                    time.sleep(5)  # Analyze every 5 seconds
#                     if self.current_file and self.current_file in self.open_files:
text_widget = self.open_files[self.current_file]
content = text_widget.get('1.0', tk.END)
                        self.analyze_code(self.current_file, content)
#                 except Exception:
#                     pass
self.current_file = file_path

#             # Analyze code for errors
            self.analyze_code(file_path, content)

self.status_bar.config(text = f"Opened: {file_path}")

#         except Exception as e:
            messagebox.showerror("Error", f"Could not open file: {str(e)}")

if __name__ == "__main__"
    #     try:
    #         # Check for required dependencies
    #         import aiohttp

            print("🚀 Starting Enhanced NoodleCore Native GUI IDE...")
            print("✅ All dependencies found")

    #         # Create and run IDE
    ide = EnhancedNativeNoodleCoreIDE()
            ide.run()

    #     except ImportError as e:
            print(f"❌ Missing dependency: {e}")
            print("Please install required dependencies:")
            print("pip install aiohttp")

    #     except Exception as e:
            print(f"❌ Failed to start IDE: {e}")

    #         # Fallback: show simple error dialog
    #         import tkinter as tk
    root = tk.Tk()
            root.withdraw()
    #         from tkinter import messagebox
            messagebox.showerror("IDE Error", f"Failed to start Enhanced NoodleCore IDE:\n\n{str(e)}")
            root.destroy()

    threading.Thread(target = periodic_analysis, daemon=True).start()

    #     def load_saved_settings(self):
    #         """Load saved AI settings."""
    #         try:
    config_path = Path.home() / '.noodlecore' / 'ai_config.json'
    #             if config_path.exists():
    #                 with open(config_path, 'r') as f:
    config = json.load(f)

    #                 # Apply settings
    #                 if 'provider' in config:
                        self.provider_var.set(config['provider'])
                        self.on_provider_change()

    #                 if 'model' in config:
                        self.model_var.set(config['model'])

    #                 if 'api_key' in config:
                        self.api_key_var.set(config['api_key'])

    #                 if 'role' in config:
                        self.role_var.set(config['role'])
                        self.on_role_change()

    #         except Exception:
    #             pass  # Ignore errors loading settings

    #     def setup_file_operations(self):
    #         """Setup file operations."""
    #         pass  # Already handled in other methods

    #     def setup_ai_interface(self):
    #         """Setup AI interface."""
    #         # Set default role
    self.current_role = self.ai_roles[0]  # Code Assistant
            self.on_role_change()

    #     def setup_file_operations(self):
    #         """Setup file operations."""
    #         pass  # File operations are handled in individual methods

    #     # Menu Commands
    #     def new_file(self):
    #         """Create new file (override for enhanced functionality)."""
    title = f"Untitled-{len(self.open_files) + 1}"
    text_widget = self.create_new_tab(title)

    #         # Create new file path
    new_file = os.path.join(os.getcwd(), f"Untitled-{len(self.open_files) + 1}.py")
    self.current_file = new_file
    self.open_files[new_file] = text_widget

    #     def show_about(self):
    #         """Show about dialog."""
    about_msg = """Enhanced NoodleCore Native GUI IDE v2.0

# A complete development environment with:
# • Real AI integration
# • Auto-complete and Tab acceptance
# • Python to NoodleCore conversion
# • Sandboxed execution
# • Code analysis and suggestions

# Built with ❤️ for NoodleCore development"""

        messagebox.showinfo("About", about_msg)

#     def convert_python_to_nc(self):
        """Convert Python to NoodleCore (wrapper)."""
        self.convert_python_to_nc_sync()

#     def run_in_sandbox(self):
        """Run in sandbox (wrapper)."""
        self.run_in_sandbox_sync()

#     # Utility Methods
#     def get_current_text_widget(self):
#         """Get currently active text widget."""
current_tab = self.notebook.select()
#         if current_tab:
frame = self.root.nametowidget(current_tab)
#             for widget in frame.winfo_children():
#                 if isinstance(widget, tk.Text):
#                     return widget
#         return None

#     def open_file_helper(self, file_path):
#         """Open file helper (override with better file path handling)."""
#         try:
#             with open(file_path, 'r', encoding='utf-8') as f:
content = f.read()

#             # Create or update tab
tab_title = os.path.basename(file_path)

#             # Check if file is already open
#             if file_path in self.open_files:
#                 # Switch to existing tab
#                 for i in range(self.notebook.index('end')):
#                     if self.notebook.tab(i)['text'] == tab_title:
                        self.notebook.select(i)
#                         break
#             else:
#                 # Create new tab
text_widget = self.create_new_tab(tab_title)
                text_widget.insert('1.0', content)
self.open_files[file_path] = 