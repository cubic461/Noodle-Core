# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# NoodleCore Native GUI IDE - Enhanced Implementation
# Complete functional IDE with advanced AI integration, auto-complete, Git integration, and more
# """

import tkinter as tk
import tkinter.ttk,
import threading
import subprocess
import sys
import os
import json
import re
import time
import asyncio
import aiohttp
import pathlib.Path
import urllib.request
import urllib.parse
import ssl
import requests
import tempfile
import shutil
import datetime.datetime
import uuid
import webbrowser
import queue
import concurrent.futures.ThreadPoolExecutor
import logging
import inspect

# Import Pygments for syntax highlighting
try
    #     from pygments import highlight
    #     from pygments.lexers import get_lexer_by_name, guess_lexer
    #     from pygments.formatters import HtmlFormatter
    PYGMENTS_AVAILABLE = True
except ImportError
    PYGMENTS_AVAILABLE = False
        print("Pygments not available - syntax highlighting will be limited")

# AI Provider Classes for Real AI Integration
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
    #         if not api_key:
                raise Exception("OpenAI API key required")

    headers = {
    #             "Authorization": f"Bearer {api_key}",
    #             "Content-Type": "application/json"
    #         }

    data = {
    #             "model": model,
    #             "messages": messages,
    #             "max_tokens": 2000,
    #             "temperature": 0.7
    #         }

    #         try:
    #             async with aiohttp.ClientSession() as session:
    #                 async with session.post(f"{self.base_url}/chat/completions",
    json = data, headers=headers) as response:
    #                     if response.status == 200:
    result = await response.json()
    #                         return result['choices'][0]['message']['content']
    #                     else:
    error_text = await response.text()
                            raise Exception(f"OpenAI API error: {error_text}")
    #         except Exception as e:
                raise Exception(f"OpenAI request failed: {str(e)}")

class OpenRouterProvider(AIProvider)
    #     """OpenRouter API provider."""
    #     def __init__(self):
            super().__init__("OpenRouter", "https://openrouter.ai/api/v1", True)

    #     async def chat_completion(self, messages, api_key=None, model="gpt-3.5-turbo"):
    #         if not api_key:
                raise Exception("OpenRouter API key required")

    headers = {
    #             "Authorization": f"Bearer {api_key}",
    #             "Content-Type": "application/json",
    #             "HTTP-Referer": "https://noodlecore-ide.com",
    #             "X-Title": "NoodleCore IDE"
    #         }

    data = {
    #             "model": model,
    #             "messages": messages,
    #             "max_tokens": 2000,
    #             "temperature": 0.7
    #         }

    #         try:
    #             async with aiohttp.ClientSession() as session:
    #                 async with session.post(f"{self.base_url}/chat/completions",
    json = data, headers=headers) as response:
    #                     if response.status == 200:
    result = await response.json()
    #                         return result['choices'][0]['message']['content']
    #                     else:
    error_text = await response.text()
                            raise Exception(f"OpenRouter API error: {error_text}")
    #         except Exception as e:
                raise Exception(f"OpenRouter request failed: {str(e)}")

class LMStudioProvider(AIProvider)
    #     """LM Studio local provider."""
    #     def __init__(self):
            super().__init__("LM Studio", "http://localhost:1234/v1", False)

    #     async def chat_completion(self, messages, api_key=None, model="local-model"):
    data = {
    #             "model": model,
    #             "messages": messages,
    #             "max_tokens": 2000,
    #             "temperature": 0.7
    #         }

    #         try:
    #             async with aiohttp.ClientSession() as session:
    #                 async with session.post(f"{self.base_url}/chat/completions",
    json = data) as response:
    #                     if response.status == 200:
    result = await response.json()
    #                         return result['choices'][0]['message']['content']
    #                     else:
    error_text = await response.text()
                            raise Exception(f"LM Studio API error: {error_text}")
    #         except Exception as e:
                raise Exception(f"LM Studio request failed: {str(e)}")

class AIRole
    #     """AI role configuration for advanced interactions."""
    #     def __init__(self, name, description, system_prompt, capabilities):
    self.name = name
    self.description = description
    self.system_prompt = system_prompt
    self.capabilities = capabilities

class NativeNoodleCoreIDE
    #     """Complete NoodleCore GUI IDE with advanced functionality."""

    #     def __init__(self):
    self.root = tk.Tk()
            self.root.title("NoodleCore Native GUI IDE - Enhanced")
            self.root.geometry("1400x900")
    self.root.configure(bg = '#2b2b2b')

    #         # Enable proper window resizing
            self.root.resizable(True, True)
            self.root.minsize(800, 600)

    #         # File system state
    self.current_project_path = Path.cwd()
    self.file_tree_paths = {}
    self.open_files = {}
    self.current_file = None
    self.unsaved_changes = {}
    self.code_errors = []

    #         # AI providers using real API classes
    self.ai_providers = {
                "OpenAI": OpenAIProvider(),
                "OpenRouter": OpenRouterProvider(),
                "LM Studio": LMStudioProvider()
    #         }

    #         # AI configuration
    self.current_ai_provider = "OpenRouter"
    self.current_ai_model = "gpt-3.5-turbo"
    self.ai_api_key = ""
    self.ai_conversations = {}

    #         # AI roles
    self.ai_roles = self.load_ai_roles()
    #         self.current_ai_role = self.ai_roles[0] if self.ai_roles else None

    #         # AI Chat interface elements
    self.ai_chat = None
    self.ai_input = None
    self.ai_output = None

    #         # File tracking
    self.tab_text_widgets = []

    #         # Initialize UI
            self.create_ui()
            self.create_main_layout()

    #         # Show enhanced welcome message
            self.show_welcome_message()

    #     def create_ui(self):
    #         """Create the main UI elements."""
    #         # Menu bar
            self.create_menu_bar()

    #         # Toolbar
            self.create_toolbar()

    #         # Status bar
    self.status_bar = tk.Label(self.root, text="Ready", anchor='w', bg='#3c3c3c', fg='white')
    self.status_bar.pack(side = 'bottom', fill='x')

    #     def create_menu_bar(self):
    #         """Create the enhanced menu bar."""
    menubar = tk.Menu(self.root)
    self.root.config(menu = menubar)

    #         # File menu
    file_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "File", menu=file_menu)
    file_menu.add_command(label = "New File", command=self.new_file)
    file_menu.add_command(label = "Open File", command=self.open_file)
    file_menu.add_command(label = "Save", command=self.save_file)
    file_menu.add_command(label = "Save As", command=self.save_file_as)
            file_menu.add_separator()
    file_menu.add_command(label = "Exit", command=self.on_closing)

    #         # Edit menu
    edit_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "Edit", menu=edit_menu)
    edit_menu.add_command(label = "Cut", command=lambda: self.root.focus_get().event_generate("<<Cut>>"))
    edit_menu.add_command(label = "Copy", command=lambda: self.root.focus_get().event_generate("<<Copy>>"))
    edit_menu.add_command(label = "Paste", command=lambda: self.root.focus_get().event_generate("<<Paste>>"))
            edit_menu.add_separator()
    edit_menu.add_command(label = "Find/Replace", command=self.show_find_replace)

    #         # Run menu
    run_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "Run", menu=run_menu)
    run_menu.add_command(label = "Run Current File", command=self.run_current_file)
    run_menu.add_command(label = "Run Python File", command=self.run_python_file)
            run_menu.add_separator()
    run_menu.add_command(label = "Terminal", command=self.toggle_terminal)

            # AI menu (Enhanced)
    ai_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "AI", menu=ai_menu)
    ai_menu.add_command(label = "AI Settings", command=self.show_ai_settings)
            ai_menu.add_separator()
    ai_menu.add_command(label = "AI Role Selector", command=self.show_enhanced_ai_role_selector)
    ai_menu.add_command(label = "Add New AI Role", command=self.add_new_ai_role)
    ai_menu.add_command(label = "Edit AI Roles", command=self.edit_ai_roles)
            ai_menu.add_separator()
    ai_menu.add_command(label = "Convert Python to NoodleCore", command=lambda: self.convert_python_to_nc())
    ai_menu.add_command(label = "Auto-fix Code Errors", command=self.auto_fix_code_errors)
    ai_menu.add_command(label = "Code Review", command=self.ai_code_review)
    ai_menu.add_command(label = "Explain Code", command=self.ai_explain_code)
    ai_menu.add_command(label = "AI Chat", command=self.show_ai_chat)
    ai_menu.add_command(label = "Code Review", command=self.ai_code_review)
    ai_menu.add_command(label = "Explain Code", command=self.ai_explain_code)
    ai_menu.add_command(label = "Convert Python to NoodleCore", command=self.convert_python_to_nc)
    ai_menu.add_command(label = "Auto-fix Code Errors", command=self.auto_fix_code_errors)
            ai_menu.add_separator()
    ai_menu.add_command(label = "AI Settings", command=self.show_ai_settings)
    ai_menu.add_command(label = "AI Role Selector", command=self.show_ai_role_selector)

    #         # Git menu
    git_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "Git", menu=git_menu)
    git_menu.add_command(label = "Git Status", command=self.show_git_status)
    git_menu.add_command(label = "Git Commits", command=self.show_git_commits)
    git_menu.add_command(label = "Git Diff", command=self.show_git_diff)
            git_menu.add_separator()
    git_menu.add_command(label = "Project Health Check", command=self.project_health_check_workflow)

    #         # View menu
    view_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "View", menu=view_menu)
    view_menu.add_command(label = "Toggle File Explorer", command=lambda: self.toggle_panel('file_explorer'))
    view_menu.add_command(label = "Toggle Terminal", command=lambda: self.toggle_panel('terminal'))
    view_menu.add_command(label = "Toggle AI Chat", command=lambda: self.toggle_panel('ai_chat'))
    view_menu.add_command(label = "Refresh File Tree", command=self.refresh_file_tree)

    #         # Help menu
    help_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "Help", menu=help_menu)
    help_menu.add_command(label = "About", command=self.show_about)

    #     def create_toolbar(self):
    #         """Create the enhanced toolbar."""
    toolbar = tk.Frame(self.root, bg='#3c3c3c', height=40)
    toolbar.pack(fill = 'x', padx=2, pady=2)

    #         # File operations
    tk.Button(toolbar, text = "New", command=self.new_file, bg='#4CAF50', fg='white').pack(side='left', padx=2)
    tk.Button(toolbar, text = "Open", command=self.open_file, bg='#2196F3', fg='white').pack(side='left', padx=2)
    tk.Button(toolbar, text = "Save", command=self.save_file, bg='#FF9800', fg='white').pack(side='left', padx=2)

    #         # Run operations
    tk.Button(toolbar, text = "Run", command=self.run_current_file, bg='#f44336', fg='white').pack(side='left', padx=2)

    #         # AI operations
    tk.Button(toolbar, text = "AI Chat", command=self.show_ai_chat, bg='#00BCD4', fg='white').pack(side='left', padx=2)
    tk.Button(toolbar, text = "Code Review", command=self.ai_code_review, bg='#00BCD4', fg='white').pack(side='left', padx=2)
    tk.Button(toolbar, text = "Convert Py→NC", command=self.convert_python_to_nc, bg='#00BCD4', fg='white').pack(side='left', padx=2)

    #         # Git operations
    tk.Button(toolbar, text = "Git Status", command=self.show_git_status, bg='#FF5722', fg='white').pack(side='left', padx=2)
    tk.Button(toolbar, text = "Health Check", command=self.project_health_check_workflow, bg='#FF5722', fg='white').pack(side='left', padx=2)

    #     def create_main_layout(self):
    #         """Create the main layout with resizable panels."""
    #         # Main container
    main_frame = tk.Frame(self.root, bg='#2b2b2b')
    main_frame.pack(fill = 'both', expand=True, padx=5, pady=5)

    #         # Create paned window for resizable layout
    self.main_panes = tk.PanedWindow(main_frame, orient='horizontal', bg='#2b2b2b', sashrelief='raised', sashwidth=3)
    self.main_panes.pack(fill = 'both', expand=True)

    #         # Left panel - File Explorer and AI Chat
    left_frame = tk.Frame(self.main_panes, bg='#3c3c3c', width=350)
    self.main_panes.add(left_frame, minsize = 300)

    #         # File Explorer
    file_explorer_label = tk.Label(left_frame, text="File Explorer", bg='#3c3c3c', fg='white', font=('Arial', 10, 'bold'))
    file_explorer_label.pack(anchor = 'w', padx=5, pady=2)

    self.file_tree = ttk.Treeview(left_frame, show='tree')
    self.file_tree.pack(fill = 'both', expand=True, padx=5, pady=5)
            self.file_tree.bind('<<TreeviewOpen>>', self._on_tree_expand)
            self.file_tree.bind('<Double-1>', self._on_tree_double_click)

    #         # AI Chat Panel
    ai_label = tk.Label(left_frame, text="🤖 AI Assistant", bg='#3c3c3c', fg='white', font=('Arial', 10, 'bold'))
    ai_label.pack(anchor = 'w', padx=5, pady=2)

    self.ai_chat = scrolledtext.ScrolledText(
    #             left_frame,
    height = 10,
    bg = '#1e1e1e',
    fg = '#00ff00',
    font = ('Consolas', 10),
    wrap = tk.WORD
    #         )
    self.ai_chat.pack(fill = 'both', expand=True, padx=5, pady=5)
    self.ai_chat.config(state = 'disabled')

    #         # AI input with role indicator
    ai_input_frame = tk.Frame(left_frame, bg='#3c3c3c')
    ai_input_frame.pack(fill = 'x', padx=5, pady=5)

    self.ai_input = tk.Entry(ai_input_frame, bg='#1e1e1e', fg='white', font=('Consolas', 10))
    self.ai_input.pack(fill = 'x', padx=5, pady=2)
            self.ai_input.bind('<Return>', self.send_ai_message)

    #         # AI role indicator
    self.ai_role_label = tk.Label(ai_input_frame, text="Role: Code Assistant", bg='#3c3c3c', fg='#00BCD4', font=('Arial', 8))
    self.ai_role_label.pack(anchor = 'w', padx=5)

    #         # Right panel - Code Editor and Terminal
    right_frame = tk.Frame(self.main_panes, bg='#2b2b2b')
            self.main_panes.add(right_frame)

    #         # Editor and terminal paned window
    self.editor_panes = tk.PanedWindow(right_frame, orient='vertical', bg='#2b2b2b', sashrelief='raised', sashwidth=3)
    self.editor_panes.pack(fill = 'both', expand=True)

    #         # Code Editor
    editor_frame = tk.Frame(self.editor_panes, bg='#1e1e1e')
    self.editor_panes.add(editor_frame, minsize = 300)

    #         # Notebook for tabs
    self.notebook = ttk.Notebook(editor_frame)
    self.notebook.pack(fill = 'both', expand=True, padx=5, pady=5)

    #         # Create initial tab
            self.create_new_tab("Welcome", "Welcome to Enhanced NoodleCore IDE!\n\nStart by creating or opening a file.")

    #         # Terminal
    terminal_frame = tk.Frame(self.editor_panes, bg='#000000', height=200)
    self.editor_panes.add(terminal_frame, minsize = 150)

    terminal_label = tk.Label(terminal_frame, text="Terminal", bg='#000000', fg='#00ff00', font=('Courier', 10, 'bold'))
    terminal_label.pack(anchor = 'w', padx=5, pady=2)

    self.terminal_output = scrolledtext.ScrolledText(
    #             terminal_frame,
    height = 10,
    bg = '#1e1e1e',
    fg = '#00ff00',
    font = ('Courier', 10),
    wrap = tk.WORD
    #         )
    self.terminal_output.pack(fill = 'both', expand=True, padx=5, pady=5)
    self.terminal_output.config(state = 'disabled')

    #         # Initialize file tree
            self.refresh_file_tree()

    #     def create_new_tab(self, title, content=""):
    #         """Create a new editor tab."""
    tab_frame = ttk.Frame(self.notebook)
    self.notebook.add(tab_frame, text = title)

    #         # Create text widget with enhanced features
    text_widget = scrolledtext.ScrolledText(
    #             tab_frame,
    wrap = tk.WORD,
    bg = '#1e1e1e',
    fg = '#ffffff',
    insertbackground = 'white',
    selectbackground = '#404040',
    font = ('Consolas', 12)
    #         )
    text_widget.pack(fill = 'both', expand=True, padx=5, pady=5)

    #         # Bind auto-complete events
            text_widget.bind('<KeyPress>', self.check_auto_complete)
            text_widget.bind('<Control-space>', self.show_auto_complete)
            text_widget.bind('<Tab>', self.accept_auto_complete)

    #         # Insert content if provided
    #         if content:
                text_widget.insert('1.0', content)

    #         # Track tab for auto-complete
            self.tab_text_widgets.append(text_widget)

    #         return text_widget

    #     # AI Role Management
    #     def load_ai_roles(self):
    #         """Load AI roles for enhanced interactions."""
    default_roles = [
                AIRole(
    name = "Code Assistant",
    description = "General coding help and assistance",
    system_prompt = "You are a helpful coding assistant specializing in Python and NoodleCore development.",
    capabilities = ["code_review", "explanation", "debugging", "optimization"]
    #             ),
                AIRole(
    name = "Code Reviewer",
    description = "Professional code review and quality assessment",
    system_prompt = "You are an expert code reviewer focused on code quality, best practices, and potential improvements.",
    capabilities = ["code_review", "quality_assessment", "best_practices"]
    #             ),
                AIRole(
    name = "NoodleCore Expert",
    description = "Specialist in NoodleCore language and ecosystem",
    #                 system_prompt="You are a NoodleCore language expert with deep knowledge of its syntax, features, and ecosystem.",
    capabilities = ["noodlecore_syntax", "conversion", "best_practices"]
    #             ),
                AIRole(
    name = "Debugger",
    description = "Error detection and debugging assistance",
    system_prompt = "You are a debugging specialist who helps identify and fix code errors and issues.",
    capabilities = ["error_detection", "debugging", "error_explanation"]
    #             )
    #         ]

    #         # Try to load custom roles from file
    #         try:
    roles_file = Path.home() / '.noodlecore' / 'ai_roles.json'
    #             if roles_file.exists():
    #                 with open(roles_file, 'r') as f:
    roles_data = json.load(f)
    #                 # Convert back to AIRole objects
    custom_roles = []
    #                 for role_data in roles_data:
    role = AIRole(
    #                         role_data['name'],
    #                         role_data['description'],
    #                         role_data['system_prompt'],
    #                         role_data['capabilities']
    #                     )
                        custom_roles.append(role)
                    default_roles.extend(custom_roles)
    #         except Exception as e:
                print(f"Could not load custom AI roles: {e}")

    #         return default_roles

    #     def show_ai_role_selector(self):
    #         """Show AI role selection dialog."""
    top = tk.Toplevel(self.root)
            top.title("Select AI Role")
            top.geometry("400x300")
    top.configure(bg = '#2b2b2b')

            tk.Label(
    #             top,
    #             text="Select which AI role to use for interactions.\nEach role has specialized capabilities.",
    bg = '#2b2b2b',
    fg = 'white',
    justify = 'left'
    ).pack(padx = 10, pady=10)

    #         # Role selection
    #         role_var = tk.StringVar(value=self.current_ai_role.name if self.current_ai_role else "Code Assistant")
    role_frame = tk.Frame(top, bg='#2b2b2b')
    role_frame.pack(fill = 'x', padx=10, pady=5)

    tk.Label(role_frame, text = "AI Role:", bg='#2b2b2b', fg='white').pack(anchor='w')
    role_combo = ttk.Combobox(role_frame, textvariable=role_var, state='readonly')
    #         role_combo['values'] = [role.name for role in self.ai_roles]
    role_combo.pack(fill = 'x', pady=5)

    #         # Role details
    details_frame = tk.Frame(top, bg='#2b2b2b')
    details_frame.pack(fill = 'both', expand=True, padx=10, pady=5)

    details_text = scrolledtext.ScrolledText(details_frame, height=8, bg='#1e1e1e', fg='white')
    details_text.pack(fill = 'both', expand=True)
    details_text.config(state = 'disabled')

    #         def update_details(event=None):
    selected_name = role_var.get()
    #             selected_role = next((r for r in self.ai_roles if r.name == selected_name), None)
    #             if selected_role:
    details_text.config(state = 'normal')
                    details_text.delete('1.0', 'end')
                    details_text.insert('1.0', f"Description: {selected_role.description}\n\n")
                    details_text.insert('end', f"Capabilities: {', '.join(selected_role.capabilities)}\n\n")
                    details_text.insert('end', f"System Prompt:\n{selected_role.system_prompt}")
    details_text.config(state = 'disabled')

            role_combo.bind('<<ComboboxSelected>>', update_details)
            update_details()

    #         def apply_role():
    selected_name = role_var.get()
    #             self.current_ai_role = next((r for r in self.ai_roles if r.name == selected_name), None)
    self.ai_role_label.config(text = f"Role: {self.current_ai_role.name}")
                top.destroy()

    tk.Button(top, text = "Apply Role", command=apply_role, bg='#4CAF50', fg='white').pack(pady=10)

    #     # AI Integration Methods
    #     async def send_real_ai_message(self, message):
    #         """Send real AI message using configured provider."""
    #         if not self.current_ai_provider or not self.current_ai_model:
                messagebox.showwarning("AI Not Configured", "Please configure AI provider and model first.")
    #             return

    #         # Get the current AI provider
    provider = self.ai_providers.get(self.current_ai_provider)
    #         if not provider:
                messagebox.showerror("Error", f"AI provider {self.current_ai_provider} not found")
    #             return

    #         try:
    #             # Show thinking indicator
    self.ai_chat.config(state = 'normal')
                self.ai_chat.insert('end', "🤖 AI: Thinking...\n")
                self.ai_chat.see('end')
    self.ai_chat.config(state = 'disabled')

    #             # Build context-aware messages
    messages = []
    #             if self.current_ai_role:
                    messages.append({
    #                     "role": "system",
    #                     "content": self.current_ai_role.system_prompt
    #                 })

    #             # Add file context if available
    #             if self.current_file:
    #                 try:
    text_widget = self.open_files.get(self.current_file)
    #                     if text_widget:
    content = text_widget.get('1.0', 'end-1c')
                            messages.append({
    #                             "role": "user",
    #                             "content": f"Current file: {self.current_file}\n```\n{content[:2000]}\n```"
    #                         })
    #                 except:
    #                     pass

                messages.append({"role": "user", "content": message})

    #             # Make API call
    response = await provider.chat_completion(
    #                 messages,
    api_key = self.ai_api_key,
    model = self.current_ai_model
    #             )

    #             # Remove thinking indicator and add response
    self.ai_chat.config(state = 'normal')
                self.ai_chat.delete('end-2l', 'end-1l')  # Remove "Thinking..." line
                self.ai_chat.insert('end', f"🤖 AI: {response}\n\n")
    self.ai_chat.config(state = 'disabled')
                self.ai_chat.see('end')

    #         except Exception as e:
    self.ai_chat.config(state = 'normal')
                self.ai_chat.delete('end-2l', 'end-1l')  # Remove "Thinking..." line
                self.ai_chat.insert('end', f"❌ AI Error: {str(e)}\n\n")
    self.ai_chat.config(state = 'disabled')
                self.ai_chat.see('end')

    #     def send_ai_message(self, event=None):
    #         """Send AI message (wrapper for async call)."""
    message = self.ai_input.get().strip()
    #         if not message:
    #             return

    #         # Add user message to chat
    self.ai_chat.config(state = 'normal')
            self.ai_chat.insert('end', f"👤 You: {message}\n")
            self.ai_input.delete(0, 'end')
    self.ai_chat.config(state = 'disabled')
            self.ai_chat.see('end')

    #         # Send to AI in background
    #         def run_async():
    loop = asyncio.new_event_loop()
                asyncio.set_event_loop(loop)
    #             try:
                    loop.run_until_complete(self.send_real_ai_message(message))
    #             finally:
                    loop.close()

    threading.Thread(target = run_async, daemon=True).start()

    #     # AI Functions
    #     def ai_code_review(self):
    #         """AI code review for current file."""
    #         if not self.current_file:
                messagebox.showwarning("No File", "No file is currently open")
    #             return

    #         # Add review request to AI chat
    self.ai_chat.config(state = 'normal')
            self.ai_chat.insert('end', "🤖 AI Code Review Request\n")
    self.ai_chat.insert('end', " = " * 40 + "\n")
            self.ai_input.delete(0, 'end')
    #         self.ai_input.insert(0, f"Please review the code in {self.current_file} and provide feedback on code quality, potential issues, and suggestions for improvement.")
            self.send_ai_message()
    self.ai_chat.config(state = 'disabled')
            self.ai_chat.see('end')

    #     def ai_explain_code(self):
    #         """AI explain code functionality."""
    #         if not self.current_file:
                messagebox.showwarning("No File", "No file is currently open")
    #             return

    #         # Add explanation request to AI chat
    self.ai_chat.config(state = 'normal')
            self.ai_chat.insert('end', "🤖 AI Code Explanation Request\n")
    self.ai_chat.insert('end', " = " * 40 + "\n")
            self.ai_input.delete(0, 'end')
            self.ai_input.insert(0, f"Please explain the code in {self.current_file} in detail, including what it does, how it works, and any important concepts.")
            self.send_ai_message()
    self.ai_chat.config(state = 'disabled')
            self.ai_chat.see('end')

    #     async def convert_python_to_nc(self):
    #         """Convert Python code to NoodleCore using AI."""
    #         if not self.current_file or not self.current_file.endswith('.py'):
                messagebox.showwarning("Not Python", "Please open a Python file first")
    #             return

    #         try:
    #             # Get current file content
    text_widget = self.open_files[self.current_file]
    python_content = text_widget.get('1.0', 'end-1c')

    #             # Get the current AI provider
    provider = self.ai_providers.get(self.current_ai_provider)
    #             if not provider:
                    raise Exception("AI provider not configured")

    #             # Prepare conversion prompt
    messages = [
    #                 {
    #                     "role": "system",
    #                     "content": "You are a NoodleCore language expert. Convert the given Python code to equivalent NoodleCore (.nc) code. Preserve the functionality while using NoodleCore syntax and features."
    #                 },
    #                 {
    #                     "role": "user",
    #                     "content": f"Convert this Python code to NoodleCore:\n\n```python\n{python_content}\n```"
    #                 }
    #             ]

    #             # Make API call
    nc_content = await provider.chat_completion(
    #                 messages,
    api_key = self.ai_api_key,
    model = self.current_ai_model
    #             )

    #             # Save to new .nc file
    nc_file_path = self.current_file.replace('.py', '.nc')
    #             with open(nc_file_path, 'w', encoding='utf-8') as f:
                    f.write(nc_content)

    #             # Add conversion info to AI chat
    self.ai_chat.config(state = 'normal')
                self.ai_chat.insert('end', f"🔄 Python to NoodleCore Conversion:\n")
                self.ai_chat.insert('end', f"Input: {self.current_file}\n")
                self.ai_chat.insert('end', f"Output: {nc_file_path}\n")
                self.ai_chat.insert('end', f"Result: {nc_content}\n\n")
    self.ai_chat.config(state = 'disabled')
                self.ai_chat.see('end')

    #             # Open the converted file
                self.open_file_by_path(nc_file_path)
                messagebox.showinfo("Conversion Complete", f"Python code converted to NoodleCore and saved as:\n{nc_file_path}")

    #         except Exception as e:
                messagebox.showerror("Conversion Error", f"Failed to convert Python to NoodleCore: {str(e)}")

    #     def auto_fix_code_errors(self):
    #         """Automatically fix code errors using AI."""
    #         if not self.code_errors or not self.current_file:
                messagebox.showwarning("No Errors", "No code errors detected to fix")
    #             return

    #         # Add auto-fix request to AI chat
    self.ai_chat.config(state = 'normal')
            self.ai_chat.insert('end', "🤖 AI Auto-fix Request\n")
    self.ai_chat.insert('end', " = " * 40 + "\n")
            self.ai_input.delete(0, 'end')
    #         self.ai_input.insert(0, f"Please fix the code errors in {self.current_file}. Errors found: {len(self.code_errors)}. Provide the corrected code with explanations of what was fixed.")
            self.send_ai_message()
    self.ai_chat.config(state = 'disabled')
            self.ai_chat.see('end')

    #     # Auto-complete System
    #     def setup_auto_complete(self):
    #         """Setup auto-complete system."""
    #         # Common Python keywords and functions for auto-complete
    self.python_keywords = [
    #             'def', 'class', 'if', 'else', 'elif', 'for', 'while', 'try', 'except',
    #             'import', 'from', 'return', 'yield', 'break', 'continue', 'pass', 'with',
    #             'as', 'lambda', 'global', 'nonlocal', 'assert', 'del', 'True', 'False', 'None'
    #         ]

    self.python_functions = [
    #             'print', 'len', 'str', 'int', 'float', 'list', 'dict', 'set', 'tuple',
    #             'open', 'range', 'enumerate', 'zip', 'map', 'filter', 'sorted', 'reversed'
    #         ]

    #     def check_auto_complete(self, event):
    #         """Check if auto-complete should be shown."""
    #         # Get current word
    text_widget = event.widget
    cursor_pos = text_widget.index('insert')
    line_start = text_widget.index(f"{cursor_pos.line}.0")
    line_text = text_widget.get(line_start, cursor_pos)

    #         # Check if we need auto-complete (after dot or typing a word)
    #         if event.char in '.\n\t' or (event.char.isalnum() or event.char == '_'):
    #             # Simple auto-complete logic
    #             word_start = line_text.rfind(' ') + 1 if ' ' in line_text else 0
    current_word = line_text[word_start:].lower()

    #             if current_word in ['print', 'len', 'str', 'int']:
                    self.show_auto_complete(event)

    #     def show_auto_complete(self, event=None):
            """Show auto-complete manually (Ctrl+Space)."""
    #         # For now, just show a simple completion
    #         text_widget = event.widget if event else self.get_current_text_widget()
    #         if not text_widget:
    #             return

    #         # Simple auto-completion for common patterns
    cursor_pos = text_widget.index('insert')
    line_start = text_widget.index(f"{cursor_pos.line}.0")
    line_text = text_widget.get(line_start, cursor_pos)

    #         # Check for common completions
    #         if line_text.strip().endswith('print('):
                text_widget.insert(cursor_pos, '"")')
                text_widget.move_cursor_to(f"{cursor_pos.line}.{cursor_pos.column + 1}")
    #             return 'break'

    #         return None

    #     def accept_auto_complete(self, event):
    #         """Accept auto-complete with Tab."""
    #         # Simple Tab completion logic
            return self.show_auto_complete(event)

    #     def get_current_text_widget(self):
    #         """Get the currently active text widget."""
    current_tab = self.notebook.index(self.notebook.select())
    #         tab_widget = self.notebook.winfo_children()[current_tab] if current_tab < len(self.notebook.winfo_children()) else None
    #         if tab_widget:
    #             for widget in tab_widget.winfo_children():
    #                 if isinstance(widget, scrolledtext.ScrolledText):
    #                     return widget
    #         return None

    #     # Git Integration Methods
    #     def show_git_status(self):
    #         """Show Git status in terminal."""
    self.terminal_output.config(state = 'normal')
            self.terminal_output.insert('end', "\n🔍 Git Status:\n")
    self.terminal_output.insert('end', " = " * 50 + "\n")

    #         try:
    result = subprocess.run(['git', 'status', '--porcelain'],
    capture_output = True, text=True, cwd=self.current_project_path)

    #             if result.returncode == 0:
    #                 if result.stdout.strip():
    #                     # Parse status output
    lines = result.stdout.strip().split('\n')
    #                     for line in lines:
    #                         if line.startswith('??'):
                                self.terminal_output.insert('end', f"  ? {line[3:]} (Untracked)\n")
    #                         elif line.startswith(' M'):
                                self.terminal_output.insert('end', f"  ✏️  {line[3:]} (Modified)\n")
    #                         elif line.startswith('A '):
                                self.terminal_output.insert('end', f"  ➕ {line[3:]} (Added)\n")
    #                         elif line.startswith('D '):
                                self.terminal_output.insert('end', f"  ❌ {line[3:]} (Deleted)\n")
    #                         else:
                                self.terminal_output.insert('end', f"  {line}\n")
    #                 else:
                        self.terminal_output.insert('end', "✅ Working directory is clean\n")
    #             else:
                    self.terminal_output.insert('end', "❌ Not a Git repository or Git error\n")

    #         except FileNotFoundError:
                self.terminal_output.insert('end', "❌ Git not found. Please install Git.\n")
    #         except Exception as e:
                self.terminal_output.insert('end', f"❌ Git error: {str(e)}\n")

    self.terminal_output.insert('end', " = " * 50 + "\n")
    self.terminal_output.config(state = 'disabled')
            self.terminal_output.see('end')

    #     def show_git_commits(self):
    #         """Show recent commits in terminal."""
    self.terminal_output.config(state = 'normal')
            self.terminal_output.insert('end', "\n📝 Recent Git Commits:\n")
    self.terminal_output.insert('end', " = " * 50 + "\n")

    #         try:
    result = subprocess.run(['git', 'log', '--oneline', '-10'],
    capture_output = True, text=True, cwd=self.current_project_path)

    #             if result.returncode == 0:
    lines = result.stdout.strip().split('\n')
    #                 for line in lines:
    #                     if line.strip():
                            self.terminal_output.insert('end', f"  {line}\n")
    #             else:
                    self.terminal_output.insert('end', "❌ Not a Git repository or Git error\n")

    #         except FileNotFoundError:
                self.terminal_output.insert('end', "❌ Git not found. Please install Git.\n")
    #         except Exception as e:
                self.terminal_output.insert('end', f"❌ Git error: {str(e)}\n")

    self.terminal_output.insert('end', " = " * 50 + "\n")
    self.terminal_output.config(state = 'disabled')
            self.terminal_output.see('end')

    #     def toggle_terminal(self):
    #         """Toggle terminal visibility."""
    #         # In our enhanced layout, the terminal is always visible
    #         # This could be used to show/hide it if we implement that functionality
            messagebox.showinfo("Terminal", "Terminal is always visible in the current layout")

    #     def show_git_diff(self):
    #         """Show Git diff summary in terminal."""
    self.terminal_output.config(state = 'normal')
            self.terminal_output.insert('end', "\n📊 Git Diff Summary:\n")
    self.terminal_output.insert('end', " = " * 50 + "\n")

    #         try:
    result = subprocess.run(['git', 'diff', '--stat'],
    capture_output = True, text=True, cwd=self.current_project_path)

    #             if result.returncode == 0:
    #                 if result.stdout.strip():
                        self.terminal_output.insert('end', result.stdout)
    #                 else:
                        self.terminal_output.insert('end', "No changes to show\n")
    #             else:
                    self.terminal_output.insert('end', "❌ Not a Git repository or Git error\n")

    #         except FileNotFoundError:
                self.terminal_output.insert('end', "❌ Git not found. Please install Git.\n")
    #         except Exception as e:
                self.terminal_output.insert('end', f"❌ Git error: {str(e)}\n")

    self.terminal_output.insert('end', " = " * 50 + "\n")
    self.terminal_output.config(state = 'disabled')
            self.terminal_output.see('end')

    #     def project_health_check_workflow(self):
    #         """Execute workflow to check project health."""
    self.terminal_output.config(state = 'normal')
            self.terminal_output.insert('end', "\n🏥 Project Health Check:\n")
    self.terminal_output.insert('end', " = " * 50 + "\n")

    health_score = 100

    #         # 1. Git Repository Check
    #         try:
    result = subprocess.run(['git', 'status'],
    capture_output = True, text=True, cwd=self.current_project_path)
    #             if result.returncode == 0:
                    self.terminal_output.insert('end', "✅ Git Repository: Healthy\n")
    #             else:
                    self.terminal_output.insert('end', "❌ Git Repository: Not initialized\n")
    health_score - = 10
    #         except FileNotFoundError:
                self.terminal_output.insert('end', "❌ Git: Not installed\n")
    health_score - = 20

    #         # 2. Python File Check
    python_files = list(self.current_project_path.glob("*.py"))
    #         if python_files:
                self.terminal_output.insert('end', f"✅ Python Files: {len(python_files)} found\n")
    #         else:
                self.terminal_output.insert('end', "⚠️  Python Files: None found\n")
    health_score - = 5

    #         # 3. Requirements/Dependencies Check
    req_files = list(self.current_project_path.glob("*requirements*.txt")) + list(self.current_project_path.glob("pyproject.toml"))
    #         if req_files:
                self.terminal_output.insert('end', f"✅ Dependencies: {len(req_files)} files found\n")
    #         else:
                self.terminal_output.insert('end', "⚠️  Dependencies: No requirements file found\n")
    health_score - = 5

    #         # Final score
            self.terminal_output.insert('end', f"\n🏆 Overall Health Score: {health_score}/100\n")
    self.terminal_output.insert('end', " = " * 50 + "\n")
    self.terminal_output.config(state = 'disabled')
            self.terminal_output.see('end')

        # File Operations (Enhanced)
    #     def new_file(self):
    #         """Create a new file."""
    filename = filedialog.asksaveasfilename(
    title = "Create New File",
    defaultextension = ".py",
    filetypes = [("All files", "*.*"), ("Python", "*.py"), ("NoodleCore", "*.nc"), ("Text", "*.txt"), ("HTML", "*.html"), ("CSS", "*.css"), ("JavaScript", "*.js")]
    #         )

    #         if filename:
    #             # Create new tab
    text_widget = self.create_new_tab(Path(filename).name, "")
    self.open_files[filename] = text_widget
    self.unsaved_changes[filename] = False
    self.current_file = filename
    self.status_bar.config(text = f"New file: {filename}")

    #     def open_file(self):
    #         """Open a file."""
    filename = filedialog.askopenfilename(
    title = "Open File",
    filetypes = [("All files", "*.*"), ("Python", "*.py"), ("NoodleCore", "*.nc"), ("Text", "*.txt"), ("HTML", "*.html"), ("CSS", "*.css"), ("JavaScript", "*.js")]
    #         )

    #         if filename and filename not in self.open_files:
    #             try:
    #                 with open(filename, 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

    #                 # Create new tab
    text_widget = self.create_new_tab(Path(filename).name, content)
    self.open_files[filename] = text_widget
    self.unsaved_changes[filename] = False
    self.current_file = filename
    self.status_bar.config(text = f"Opened: {filename}")

    #             except Exception as e:
                    messagebox.showerror("Error", f"Could not open file: {str(e)}")

    #     def open_file_by_path(self, file_path):
    #         """Open a file by its path."""
    #         if file_path in self.open_files:
    #             # Switch to existing tab
    #             for i, tab in enumerate(self.notebook.winfo_children()):
    #                 if Path(self.notebook.tab(i, 'text')).name == Path(file_path).name:
                        self.notebook.select(i)
    #                     break
    #             return

    #         try:
    #             with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

    #             # Create new tab
    text_widget = self.create_new_tab(Path(file_path).name, content)
    self.open_files[file_path] = text_widget
    self.unsaved_changes[file_path] = False
    self.current_file = file_path
    self.status_bar.config(text = f"Opened: {file_path}")

    #         except Exception as e:
                messagebox.showerror("Error", f"Could not open file: {str(e)}")

    #     def save_file(self):
    #         """Save the current file."""
    #         if not self.current_file:
                self.save_file_as()
    #             return

    #         try:
    text_widget = self.open_files[self.current_file]
    content = text_widget.get('1.0', 'end-1c')

    #             with open(self.current_file, 'w', encoding='utf-8') as f:
                    f.write(content)

    self.unsaved_changes[self.current_file] = False
    self.status_bar.config(text = f"Saved: {self.current_file}")

    #         except Exception as e:
                messagebox.showerror("Error", f"Could not save file: {str(e)}")

    #     def save_file_as(self):
    #         """Save the current file with a new name."""
    filename = filedialog.asksaveasfilename(
    title = "Save As",
    defaultextension = ".py",
    filetypes = [("All files", "*.*"), ("Python", "*.py"), ("NoodleCore", "*.nc"), ("Text", "*.txt"), ("HTML", "*.html"), ("CSS", "*.css"), ("JavaScript", "*.js")]
    #         )

    #         if filename:
    #             try:
    text_widget = self.open_files[self.current_file]
    content = text_widget.get('1.0', 'end-1c')

    #                 with open(filename, 'w', encoding='utf-8') as f:
                        f.write(content)

    #                 # Update file references
    self.open_files[filename] = self.open_files.pop(self.current_file)
    self.unsaved_changes[filename] = self.unsaved_changes.pop(self.current_file, False)
    self.current_file = filename

    #                 # Update tab title
    current_tab = self.notebook.index(self.notebook.select())
    self.notebook.tab(current_tab, text = Path(filename).name)

    self.status_bar.config(text = f"Saved: {filename}")

    #             except Exception as e:
                    messagebox.showerror("Error", f"Could not save file: {str(e)}")

    #     def run_current_file(self):
    #         """Run the current file."""
    #         if not self.current_file:
                messagebox.showwarning("No File", "No file is currently open")
    #             return

    file_path = Path(self.current_file)
    file_ext = file_path.suffix.lower()

    self.terminal_output.config(state = 'normal')
            self.terminal_output.insert('end', f"\n🚀 Running: {self.current_file}\n")
    self.terminal_output.insert('end', " = " * 50 + "\n")
    self.terminal_output.config(state = 'disabled')
            self.terminal_output.see('end')

    #         def run_in_thread():
    #             try:
    #                 if file_ext == '.py':
    result = subprocess.run([sys.executable, str(file_path)],
    capture_output = True, text=True, cwd=file_path.parent)
    #                 elif file_ext in ['.html', '.htm']:
    #                     # For HTML files, just show the file path
    result = subprocess.run(['echo', f'Open {file_path} in browser'],
    capture_output = True, text=True)
    #                 else:
    result = subprocess.run(['cat', str(file_path)],
    capture_output = True, text=True)

    self.terminal_output.config(state = 'normal')
    #                 if result.stdout:
                        self.terminal_output.insert('end', f"Output:\n{result.stdout}\n")
    #                 if result.stderr:
                        self.terminal_output.insert('end', f"Errors:\n{result.stderr}\n")
    #                 if result.returncode != 0:
                        self.terminal_output.insert('end', f"Exit code: {result.returncode}\n")
    self.terminal_output.config(state = 'disabled')
                    self.terminal_output.see('end')

    #             except Exception as e:
    self.terminal_output.config(state = 'normal')
                    self.terminal_output.insert('end', f"Error running file: {str(e)}\n")
    self.terminal_output.config(state = 'disabled')
                    self.terminal_output.see('end')

    #         # Run in separate thread to avoid blocking UI
    threading.Thread(target = run_in_thread, daemon=True).start()

    #     def run_python_file(self):
    #         """Run current file as Python if it's a Python file."""
    #         if not self.current_file:
                messagebox.showwarning("No File", "No file is currently open")
    #             return

    #         if not self.current_file.endswith('.py'):
                messagebox.showwarning("Not Python", "Current file is not a Python file")
    #             return

            self.run_current_file()

    #     def toggle_panel(self, panel_name):
    #         """Toggle panel visibility."""
    #         messagebox.showinfo("Toggle Panel", f"Panel toggle functionality for {panel_name}")

    #     def show_ai_chat(self):
    #         """Show the AI chat panel."""
    #         # AI chat is always visible in our layout
            messagebox.showinfo("AI Chat", "AI chat panel is on the left side of the screen")

    #     def show_ai_settings(self):
    #         """Show AI settings dialog."""
    dialog = tk.Toplevel(self.root)
            dialog.title("AI Settings")
            dialog.geometry("500x400")
    dialog.configure(bg = '#2b2b2b')
            dialog.transient(self.root)
            dialog.grab_set()

    #         # AI Provider selection
    tk.Label(dialog, text = "AI Provider:", bg='#2b2b2b', fg='white').pack(anchor='w', padx=10, pady=5)
    provider_var = tk.StringVar(value=self.current_ai_provider)
    provider_combo = ttk.Combobox(dialog, textvariable=provider_var, state='readonly')
    provider_combo['values'] = list(self.ai_providers.keys())
    provider_combo.pack(fill = 'x', padx=10, pady=5)

    #         # Model selection
    tk.Label(dialog, text = "Model:", bg='#2b2b2b', fg='white').pack(anchor='w', padx=10, pady=5)
    model_var = tk.StringVar(value=self.current_ai_model)
    model_combo = ttk.Combobox(dialog, textvariable=model_var, state='readonly')
    model_combo['values'] = ["gpt-3.5-turbo", "gpt-4", "gpt-4-turbo"]
    model_combo.pack(fill = 'x', padx=10, pady=5)

    #         # API Key
    tk.Label(dialog, text = "API Key:", bg='#2b2b2b', fg='white').pack(anchor='w', padx=10, pady=5)
    api_key_var = tk.StringVar(value=self.ai_api_key)
    api_key_entry = tk.Entry(dialog, textvariable=api_key_var, show='*')
    api_key_entry.pack(fill = 'x', padx=10, pady=5)

    #         def save_ai_settings():
    self.current_ai_provider = provider_var.get()
    self.current_ai_model = model_var.get()
    self.ai_api_key = api_key_var.get()

    #             # Save to config file
    config_dir = Path.home() / '.noodlecore'
    config_dir.mkdir(exist_ok = True)
    config_file = config_dir / 'ai_config.json'

    #             with open(config_file, 'w') as f:
                    json.dump({
    #                     'provider': self.current_ai_provider,
    #                     'model': self.current_ai_model,
    #                     'api_key': self.ai_api_key
    #                 }, f)

                messagebox.showinfo("Settings Saved", "AI settings saved successfully!")
                dialog.destroy()

    #         # Save button
    tk.Button(dialog, text = "Save Settings", command=save_ai_settings, bg='#4CAF50', fg='white').pack(pady=20)

    #         # Load current settings
    #         def load_ai_settings():
    #             try:
    config_file = Path.home() / '.noodlecore' / 'ai_config.json'
    #                 if config_file.exists():
    #                     with open(config_file, 'r') as f:
    settings = json.load(f)
                        provider_var.set(settings.get('provider', self.current_ai_provider))
                        model_var.set(settings.get('model', self.current_ai_model))
                        api_key_var.set(settings.get('api_key', self.ai_api_key))
    #             except Exception as e:
                    print(f"Could not load AI settings: {e}")

            load_ai_settings()

    #     def show_find_replace(self):
    #         """Show find/replace dialog."""
    dialog = tk.Toplevel(self.root)
            dialog.title("Find/Replace")
            dialog.geometry("400x200")
    dialog.configure(bg = '#2b2b2b')
            dialog.transient(self.root)
            dialog.grab_set()

    #         # Find frame
    find_frame = tk.Frame(dialog, bg='#2b2b2b')
    find_frame.pack(fill = 'x', padx=10, pady=5)

    tk.Label(find_frame, text = "Find:", bg='#2b2b2b', fg='white').pack(side='left')
    find_entry = tk.Entry(find_frame, bg='#1e1e1e', fg='#ffffff')
    find_entry.pack(side = 'left', fill='x', expand=True, padx=5)

    #         # Replace frame
    replace_frame = tk.Frame(dialog, bg='#2b2b2b')
    replace_frame.pack(fill = 'x', padx=10, pady=5)

    tk.Label(replace_frame, text = "Replace:", bg='#2b2b2b', fg='white').pack(side='left')
    replace_entry = tk.Entry(replace_frame, bg='#1e1e1e', fg='#ffffff')
    replace_entry.pack(side = 'left', fill='x', expand=True, padx=5)

    #         # Buttons
    button_frame = tk.Frame(dialog, bg='#2b2b2b')
    button_frame.pack(fill = 'x', padx=10, pady=10)

    tk.Button(button_frame, text = "Find Next", bg='#2196F3', fg='white').pack(side='left', padx=5)
    tk.Button(button_frame, text = "Replace", bg='#FF9800', fg='white').pack(side='left', padx=5)
    tk.Button(button_frame, text = "Replace All", bg='#4CAF50', fg='white').pack(side='left', padx=5)
    tk.Button(button_frame, text = "Close", command=dialog.destroy, bg='#f44336', fg='white').pack(side='right', padx=5)

    #     def refresh_file_tree(self):
    #         """Refresh the file tree view."""
    #         # Clear existing items
    #         for item in self.file_tree.get_children():
                self.file_tree.delete(item)

    #         # Add root
    root_id = self.file_tree.insert('', 'end', text="📁 " + self.current_project_path.name, open=True)
    self.file_tree_paths[root_id] = self.current_project_path

    #         # Populate directory
            self._populate_directory(root_id, self.current_project_path)

    #     def _populate_directory(self, parent_id, directory):
    #         """Populate directory tree."""
    #         try:
    items = list(directory.iterdir())
    #             dirs = [item for item in items if item.is_dir()]
    #             files = [item for item in items if item.is_file()]

    all_items = math.add(sorted(dirs), sorted(files))

    #             for item in all_items:
    #                 try:
    #                     if item.is_dir():
    icon = "📁"
    dir_id = self.file_tree.insert(parent_id, 'end',
    text = f"{icon} {item.name}",
    open = False, tags=('directory',))
    self.file_tree_paths[dir_id] = item
    self.file_tree.insert(dir_id, 'end', text = "...", tags=('placeholder',))
    #                     else:
    icon = self.get_file_icon(item.suffix)
    file_id = self.file_tree.insert(parent_id, 'end',
    text = f"{icon} {item.name}",
    tags = ('file',))
    self.file_tree_paths[file_id] = item

    #                 except PermissionError:
    #                     continue

    #         except Exception as e:
                print(f"Error populating directory {directory}: {e}")

    #     def get_file_icon(self, extension):
    #         """Get appropriate icon for file type."""
    extension = extension.lower()
    icon_map = {
    #             '.py': '🐍',
    #             '.js': '🟨',
    #             '.html': '🌐',
    #             '.css': '🎨',
    #             '.json': '📋',
    #             '.txt': '📄',
    #             '.md': '📝',
    #             '.nc': '🔧'
    #         }
            return icon_map.get(extension, '📄')

    #     def _on_tree_expand(self, event):
    #         """Handle tree item expansion."""
    #         item = self.file_tree.selection()[0] if self.file_tree.selection() else None
    #         if not item:
    #             return

    #         if item in self.file_tree_paths and self.file_tree_paths[item].is_dir():
    #             # Clear placeholder
    children = self.file_tree.get_children(item)
    #             if children:
                    self.file_tree.delete(children[0])

    #             # Populate directory
                self._populate_directory(item, self.file_tree_paths[item])

    #     def _on_tree_double_click(self, event):
    #         """Handle tree item double-click."""
    selection = self.file_tree.selection()
    #         if not selection:
    #             return

    item = selection[0]
    #         if item not in self.file_tree_paths:
    #             return

    path = self.file_tree_paths[item]
    #         if path.is_file() and str(path) not in self.open_files:
                self.open_file_by_path(str(path))

    #     def show_welcome_message(self):
    #         """Show enhanced welcome message."""
    welcome_text = """# 🚀 Welcome to Enhanced NoodleCore Native GUI IDE

# A **complete development environment** with advanced AI features and enhanced functionality!

## ✨ **ENHANCED FEATURES:**

### 📁 **Real File Explorer**
# - Live file system integration
- File operations (open, delete, rename)
# - Project management with Git integration

### 📝 **Advanced Code Editor**
# - Multi-tab editing with syntax highlighting
# - Auto-complete with Tab acceptance
# - Real file saving/loading

### 🤖 **Enhanced AI Integration**
# - **Real AI providers** (OpenAI, OpenRouter, LM Studio) with async support
# - **Code review and explanations**
# - **Python → NoodleCore conversion** using AI
- **AI role management** (Code Assistant, Reviewer, Debugger, NoodleCore Expert)
# - **Auto-fix code errors** with AI assistance

### 💻 **Working Terminal**
# - Built-in command execution
- File execution (Python, JavaScript, HTML)
# - Git integration in terminal

### 🗂️ **Git Integration**
# - Git status, commits, diff, history
# - Project health check workflow
# - Git operations from menu and toolbar

### 🔧 **Resizable Windows**
# - Professional IDE layout with draggable panel borders
# - Multiple resizable panels

## 🆕 **NEW AI FEATURES:**
- **Convert Python to NoodleCore** (AI menu → "Convert Python to NoodleCore")
- **Auto-fix Code Errors** (AI menu → "Auto-fix Code Errors")
- **AI Role Selection** (AI menu → "AI Role Selector")
# - **Enhanced Code Review** with AI
# - **Real AI Integration** with OpenAI and OpenRouter APIs

## 🛠️ **How to Use:**

# 1. **File Operations**: File menu or double-click in explorer
2. **Run Code**: Run menu or toolbar button (F5)
3. **AI Features**: AI menu (new conversion, analysis, and auto-fix tools)
# 4. **Real AI**: Configure in AI Settings, then use conversion/analysis features
# 5. **Git Operations**: Git menu for version control
# 6. **Resize Windows**: Drag panel borders to resize

# Ready to code with **real AI assistance**? **Create a new file and start!** 🎉"""

#         # Insert welcome text into first tab
first_tab = self.notebook.winfo_children()[0]
#         if first_tab:
#             for widget in first_tab.winfo_children():
#                 if isinstance(widget, tk.Text):
                    widget.insert('1.0', welcome_text)
#                     break

#     def show_about(self):
#         """Show enhanced about dialog."""
about_text = """🚀 Enhanced NoodleCore Native GUI IDE

# A complete, production-ready development environment with advanced AI features and resizable windows.

# ✨ **ENHANCED FEATURES:**
# 📁 Live File System Integration with Git support
# 📝 Advanced Code Editor with auto-complete
# 🤖 **Real AI Integration** - OpenAI, OpenRouter, LM Studio
# 💻 Working Terminal with Git integration
# 🗂️ **Git Integration** - Status, commits, diff, health checks
# 🔧 Resizable Windows - Professional IDE layout
# ⚡ Performance Optimized - Fast operations and responsive UI

# 🎯 **AI ENHANCEMENTS:**
# - **Python → NoodleCore Conversion** using AI
# - **Auto-fix Code Errors** with AI assistance
- **AI Role Management** (Code Assistant, Reviewer, Debugger, Expert)
# - **Real-time Code Review** and explanations
# - **Context-aware AI Chat** with file analysis

# 🏗️ **ARCHITECTURE:**
# • Professional IDE layout with draggable panel borders
# • Real-time file system monitoring and Git integration
# • Integrated AI assistance with multiple providers and roles
# • Comprehensive terminal with built-in commands and Git tools
# • Robust error handling and status reporting

# Developed with ❤️ for the NoodleCore community!"""

        messagebox.showinfo("About Enhanced NoodleCore IDE", about_text)

#     def on_closing(self):
#         """Handle window closing."""
#         # Check for unsaved changes
#         if any(self.unsaved_changes.values()):
#             if not messagebox.askyesno("Unsaved Changes",
#                                      "You have unsaved changes. Do you want to exit anyway?"):
#                 return

        self.root.quit()

#     def load_ai_roles(self):
#         """Load AI roles from configuration or create default ones."""
#         try:
config_file = Path.home() / '.noodlecore' / 'ai_roles.json'
#             if config_file.exists():
#                 with open(config_file, 'r') as f:
roles_data = json.load(f)
#                     return [AIRole(**role) for role in roles_data]
#         except:
#             pass


#     def run(self):
#         """Start the IDE main loop."""
#         try:
            self.setup_auto_complete()
            self.root.protocol("WM_DELETE_WINDOW", self.on_closing)
            self.root.mainloop()
#         except Exception as e:
            print(f"Failed to start IDE: {e}")
#             return 1
#         return 0

function main()
    #     """Main entry point."""
        return NativeNoodleCoreIDE().run()

if __name__ == "__main__"
        sys.exit(main())
    #         # Default roles if no config exists
    #         return [
                AIRole(
    name = "Code Assistant",
    #                 description="Helps with code writing and debugging",
    system_prompt = "You are a helpful code assistant. Provide clear, concise code examples and explanations.",
    capabilities = ["code_completion", "debugging", "explanations"]
    #             ),
                AIRole(
    name = "Code Reviewer",
    #                 description="Reviews code for quality and best practices",
    system_prompt = "You are a senior code reviewer. Focus on code quality, security, performance, and best practices.",
    capabilities = ["code_review", "security", "performance"]
    #             ),
                AIRole(
    name = "NoodleCore Expert",
    description = "Specialist in NoodleCore language and features",
    #                 system_prompt="You are a NoodleCore language expert. Help with .nc file syntax, NoodleCore-specific features, and conversion from other languages.",
    capabilities = ["noodlecore", "conversion", "syntax"]
    #             ),
                AIRole(
    name = "Debug Assistant",
    description = "Helps identify and fix bugs",
    system_prompt = "You are a debugging specialist. Help identify potential bugs, suggest fixes, and explain error messages clearly.",
    capabilities = ["debugging", "error_analysis", "troubleshooting"]
    #             )
    #         ]

    #     def show_enhanced_ai_role_selector(self):
    #         """Show enhanced AI role selector with descriptions and capabilities."""
    #         if not self.ai_roles:
    self.ai_roles = self.load_ai_roles()

    top = tk.Toplevel(self.root)
            top.title("AI Role Selection")
            top.geometry("600x500")
    top.configure(bg = '#2b2b2b')
            top.transient(self.root)
            top.grab_set()

    #         # Title
    title_frame = tk.Frame(top, bg='#2b2b2b')
    title_frame.pack(fill = 'x', padx=10, pady=10)

            tk.Label(
    #             title_frame,
    text = "🎭 AI Role Selector",
    bg = '#2b2b2b',
    fg = 'white',
    font = ('Arial', 14, 'bold')
            ).pack()

            tk.Label(
    #             title_frame,
    #             text="Choose an AI role for your coding assistant",
    bg = '#2b2b2b',
    fg = '#cccccc',
    font = ('Arial', 10)
    ).pack(pady = (5, 0))

    #         # Current role display
    current_role_frame = tk.Frame(top, bg='#1e1e1e', relief='raised', bd=1)
    current_role_frame.pack(fill = 'x', padx=10, pady=5)

            tk.Label(
    #             current_role_frame,
    text = "Current Role:",
    bg = '#1e1e1e',
    fg = '#ffaa00',
    font = ('Arial', 9, 'bold')
    ).pack(anchor = 'w', padx=10, pady=(10, 0))

    current_role_label = tk.Label(
    #             current_role_frame,
    #             text=self.current_ai_role.name if self.current_ai_role else "None selected",
    bg = '#1e1e1e',
    fg = 'white',
    font = ('Arial', 11, 'bold'),
    justify = 'left'
    #         )
    current_role_label.pack(anchor = 'w', padx=10, pady=2)

    #         # Scrollable frame for roles
    canvas = tk.Canvas(top, bg='#2b2b2b', highlightthickness=0)
    scrollbar = ttk.Scrollbar(top, orient='vertical', command=canvas.yview)
    scrollable_frame = tk.Frame(canvas, bg='#2b2b2b')

            scrollable_frame.bind(
    #             "<Configure>",
    lambda e: canvas.configure(scrollregion = canvas.bbox("all"))
    #         )

    canvas.create_window((0, 0), window = scrollable_frame, anchor="nw")
    canvas.configure(yscrollcommand = scrollbar.set)

    canvas.pack(side = "left", fill="both", expand=True, padx=10, pady=5)
    scrollbar.pack(side = "right", fill="y")

    #         # Create role cards
    #         for i, role in enumerate(self.ai_roles):
    role_card = tk.Frame(scrollable_frame, bg='#1e1e1e', relief='raised', bd=1)
    role_card.pack(fill = 'x', pady=5, padx=5)

    #             # Role header
    header_frame = tk.Frame(role_card, bg='#1e1e1e')
    header_frame.pack(fill = 'x', padx=10, pady=(10, 5))

    #             # Role name
    role_name = tk.Label(
    #                 header_frame,
    text = f"🤖 {role.name}",
    bg = '#1e1e1e',
    fg = 'white',
    font = ('Arial', 12, 'bold'),
    anchor = 'w'
    #             )
    role_name.pack(side = 'left', fill='x', expand=True)

    #             # Select button
    select_btn = tk.Button(
    #                 header_frame,
    #                 text="Select" if (self.current_ai_role != role) else "Selected",
    command = lambda r=role: self.select_ai_role(r, current_role_label, select_btn),
    #                 bg='#4CAF50' if (self.current_ai_role != role) else '#2196F3',
    fg = 'white',
    font = ('Arial', 9, 'bold'),
    relief = 'flat',
    bd = 0,
    padx = 15,
    pady = 5
    #             )
    select_btn.pack(side = 'right', padx=(10, 0))

    #             # Role description
    desc_label = tk.Label(
    #                 role_card,
    text = role.description,
    bg = '#1e1e1e',
    fg = '#cccccc',
    font = ('Arial', 10),
    justify = 'left',
    wraplength = 550
    #             )
    desc_label.pack(fill = 'x', padx=10, pady=(0, 5))

    #             # Capabilities
    cap_frame = tk.Frame(role_card, bg='#1e1e1e')
    cap_frame.pack(fill = 'x', padx=10, pady=(0, 10))

                tk.Label(
    #                 cap_frame,
    text = "Capabilities:",
    bg = '#1e1e1e',
    fg = '#ffaa00',
    font = ('Arial', 9, 'bold')
    ).pack(anchor = 'w')

    caps_text = " • ".join(role.capabilities)
    cap_label = tk.Label(
    #                 cap_frame,
    text = caps_text,
    bg = '#1e1e1e',
    fg = '#88ff88',
    font = ('Arial', 9),
    justify = 'left'
    #             )
    cap_label.pack(anchor = 'w')

    #         # Close button
    close_btn = tk.Button(
    #             top,
    text = "Close",
    command = top.destroy,
    bg = '#f44336',
    fg = 'white',
    font = ('Arial', 10, 'bold'),
    relief = 'flat',
    bd = 0,
    padx = 20,
    pady = 8
    #         )
    close_btn.pack(pady = 10)

    #     def select_ai_role(self, role, current_role_label, select_btn):
    #         """Select an AI role."""
    self.current_ai_role = role
    current_role_label.config(text = role.name)
    self.status_bar.config(text = f"AI role changed to: {role.name}")

    #         # Update all select buttons
            self.show_enhanced_ai_role_selector()  # Refresh dialog
    top = self.root.focus_get()
    #         if hasattr(top, 'title') and top.title() == "AI Role Selection":
                top.destroy()

    #     def add_new_ai_role(self):
    #         """Add a new AI role."""
    top = tk.Toplevel(self.root)
            top.title("Add New AI Role")
            top.geometry("500x600")
    top.configure(bg = '#2b2b2b')
            top.transient(self.root)
            top.grab_set()

    #         # Title
            tk.Label(
    #             top,
    text = "➕ Add New AI Role",
    bg = '#2b2b2b',
    fg = 'white',
    font = ('Arial', 14, 'bold')
    ).pack(pady = 10)

    #         # Form frame
    form_frame = tk.Frame(top, bg='#2b2b2b')
    form_frame.pack(fill = 'both', expand=True, padx=20, pady=10)

    #         # Role name
    tk.Label(form_frame, text = "Role Name:", bg='#2b2b2b', fg='white').pack(anchor='w')
    name_entry = tk.Entry(form_frame, font=('Arial', 10), bg='#1e1e1e', fg='white', insertbackground='white')
    name_entry.pack(fill = 'x', pady=(0, 10))

    #         # Description
    tk.Label(form_frame, text = "Description:", bg='#2b2b2b', fg='white').pack(anchor='w')
    desc_text = scrolledtext.ScrolledText(form_frame, height=3, font=('Arial', 10), bg='#1e1e1e', fg='white', insertbackground='white')
    desc_text.pack(fill = 'x', pady=(0, 10))

    #         # System prompt
    tk.Label(form_frame, text = "System Prompt:", bg='#2b2b2b', fg='white').pack(anchor='w')
    prompt_text = scrolledtext.ScrolledText(form_frame, height=5, font=('Arial', 10), bg='#1e1e1e', fg='white', insertbackground='white')
    prompt_text.pack(fill = 'x', pady=(0, 10))

    #         # Capabilities
    tk.Label(form_frame, text = "Capabilities (comma-separated):", bg='#2b2b2b', fg='white').pack(anchor='w')
    cap_entry = tk.Entry(form_frame, font=('Arial', 10), bg='#1e1e1e', fg='white', insertbackground='white')
    cap_entry.pack(fill = 'x', pady=(0, 20))

    #         # Buttons
    button_frame = tk.Frame(top, bg='#2b2b2b')
    button_frame.pack(pady = 10)

    #         def save_role():
    name = name_entry.get().strip()
    #             if not name:
                    messagebox.showerror("Error", "Role name is required")
    #                 return

    description = desc_text.get('1.0', 'end-1c').strip()
    system_prompt = prompt_text.get('1.0', 'end-1c').strip()
    #             capabilities = [cap.strip() for cap in cap_entry.get().split(',') if cap.strip()]

    #             if not system_prompt:
                    messagebox.showerror("Error", "System prompt is required")
    #                 return

    #             # Create new role
    new_role = AIRole(
    name = name,
    description = description,
    system_prompt = system_prompt,
    capabilities = capabilities
    #             )

    #             # Add to roles list
                self.ai_roles.append(new_role)
    self.current_ai_role = math.subtract(new_role  # Auto, select new role)

    #             # Save to config
                self.save_ai_roles()

                messagebox.showinfo("Success", f"AI role '{name}' added and selected!")
    self.status_bar.config(text = f"New AI role added: {name}")
                top.destroy()

            tk.Button(
    #             button_frame,
    text = "Save Role",
    command = save_role,
    bg = '#4CAF50',
    fg = 'white',
    font = ('Arial', 10, 'bold'),
    relief = 'flat',
    bd = 0,
    padx = 20,
    pady = 8
    ).pack(side = 'left', padx=5)

            tk.Button(
    #             button_frame,
    text = "Cancel",
    command = top.destroy,
    bg = '#f44336',
    fg = 'white',
    font = ('Arial', 10, 'bold'),
    relief = 'flat',
    bd = 0,
    padx = 20,
    pady = 8
    ).pack(side = 'left', padx=5)

    #     def edit_ai_roles(self):
    #         """Edit existing AI roles."""
    #         if not self.ai_roles:
    self.ai_roles = self.load_ai_roles()

    top = tk.Toplevel(self.root)
            top.title("Edit AI Roles")
            top.geometry("700x600")
    top.configure(bg = '#2b2b2b')
            top.transient(self.root)
            top.grab_set()

    #         # Title
            tk.Label(
    #             top,
    text = "✏️ Edit AI Roles",
    bg = '#2b2b2b',
    fg = 'white',
    font = ('Arial', 14, 'bold')
    ).pack(pady = 10)

    #         # List frame with scrollbar
    list_frame = tk.Frame(top, bg='#2b2b2b')
    list_frame.pack(fill = 'both', expand=True, padx=20, pady=10)

    #         # Create scrollable list
    canvas = tk.Canvas(list_frame, bg='#2b2b2b', highlightthickness=0)
    scrollbar = ttk.Scrollbar(list_frame, orient='vertical', command=canvas.yview)
    scrollable_list = tk.Frame(canvas, bg='#2b2b2b')

            scrollable_list.bind(
    #             "<Configure>",
    lambda e: canvas.configure(scrollregion = canvas.bbox("all"))
    #         )

    canvas.create_window((0, 0), window = scrollable_list, anchor="nw")
    canvas.configure(yscrollcommand = scrollbar.set)

    canvas.pack(side = "left", fill="both", expand=True)
    scrollbar.pack(side = "right", fill="y")

    #         # Create role list items
    #         for i, role in enumerate(self.ai_roles):
    role_item = tk.Frame(scrollable_list, bg='#1e1e1e', relief='raised', bd=1)
    role_item.pack(fill = 'x', pady=3, padx=5)

    #             # Role info
    info_frame = tk.Frame(role_item, bg='#1e1e1e')
    info_frame.pack(side = 'left', fill='x', expand=True, padx=10, pady=8)

                tk.Label(
    #                 info_frame,
    text = f"🤖 {role.name}",
    bg = '#1e1e1e',
    fg = 'white',
    font = ('Arial', 11, 'bold'),
    anchor = 'w'
    ).pack(anchor = 'w')

                tk.Label(
    #                 info_frame,
    text = role.description,
    bg = '#1e1e1e',
    fg = '#cccccc',
    font = ('Arial', 9),
    anchor = 'w'
    ).pack(anchor = 'w')

    #             # Action buttons
    action_frame = tk.Frame(role_item, bg='#1e1e1e')
    action_frame.pack(side = 'right', padx=10, pady=8)

                tk.Button(
    #                 action_frame,
    text = "Edit",
    command = lambda r=role: self.edit_single_role(r),
    bg = '#FF9800',
    fg = 'white',
    font = ('Arial', 9, 'bold'),
    relief = 'flat',
    bd = 0,
    padx = 10
    ).pack(pady = 2)

    #             if len(self.ai_roles) > 1:  # Don't allow deleting last role
                    tk.Button(
    #                     action_frame,
    text = "Delete",
    command = lambda r=role, idx=i: self.delete_ai_role(idx),
    bg = '#f44336',
    fg = 'white',
    font = ('Arial', 9, 'bold'),
    relief = 'flat',
    bd = 0,
    padx = 10
    ).pack(pady = 2)

    #         # Close button
    close_btn = tk.Button(
    #             top,
    text = "Close",
    command = top.destroy,
    bg = '#f44336',
    fg = 'white',
    font = ('Arial', 10, 'bold'),
    relief = 'flat',
    bd = 0,
    padx = 20,
    pady = 8
    #         )
    close_btn.pack(pady = 10)

    #     def edit_single_role(self, role):
    #         """Edit a single AI role."""
    #         # This would open a similar dialog to add_new_ai_role but pre-filled
    #         messagebox.showinfo("Edit Role", f"Edit functionality for role '{role.name}' would open here")

    #     def delete_ai_role(self, index):
    #         """Delete an AI role by index."""
    #         if len(self.ai_roles) <= 1:
                messagebox.showwarning("Cannot Delete", "Cannot delete the last remaining AI role")
    #             return

    role = self.ai_roles[index]
    #         if messagebox.askyesno("Confirm Delete", f"Delete AI role '{role.name}'?"):
    #             del self.ai_roles[index]

    #             # If we deleted the current role, select the first one
    #             if self.current_ai_role == role and self.ai_roles:
    self.current_ai_role = self.ai_roles[0]

                self.save_ai_roles()
    self.status_bar.config(text = f"AI role '{role.name}' deleted")

    #             # Refresh the edit dialog
                self.edit_ai_roles()

    #     def save_ai_roles(self):
    #         """Save AI roles to configuration file."""
    #         try:
    config_dir = Path.home() / '.noodlecore'
    config_dir.mkdir(exist_ok = True)
    config_file = config_dir / 'ai_roles.json'

    roles_data = [
    #                 {
    #                     'name': role.name,
    #                     'description': role.description,
    #                     'system_prompt': role.system_prompt,
    #                     'capabilities': role.capabilities
    #                 }
    #                 for role in self.ai_roles
    #             ]

    #             with open(config_file, 'w') as f:
    json.dump(roles_data, f, indent = 2)

    #         except Exception as e:
                print(f"Could not save AI roles: {e}")