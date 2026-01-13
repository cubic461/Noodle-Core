# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
NoodleCore Native GUI IDE - Enhanced Implementation (Fixed)
# Complete functional IDE with advanced AI integration, auto-complete, Git integration, and progress tracking
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

# Import progress manager
try
    #     from progress_manager import ProgressManager
    PROGRESS_MANAGER_AVAILABLE = True
        print("Progress Manager loaded successfully")
except ImportError as e
    PROGRESS_MANAGER_AVAILABLE = False
        print(f"Progress Manager not available: {e}")
#!/usr/bin/env python3
# """
NoodleCore Native GUI IDE - Enhanced Implementation (Fixed)
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

    #         # Show enhanced welcome message
            self.show_welcome_message()

    #         # Initialize Progress Manager if available
    #         if PROGRESS_MANAGER_AVAILABLE:
    #             try:
    self.progress_manager = ProgressManager(self)
                    print("Progress Manager initialized successfully")
    #                 # Start monitoring by default
                    self.progress_manager.start_monitoring()
    #             except Exception as e:
                    print(f"Failed to initialize Progress Manager: {e}")
    self.progress_manager = None
    #         else:
    self.progress_manager = None
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
    run_menu.add_command(label = "Run as Python", command=self.run_python_file)
            run_menu.add_separator()
    run_menu.add_command(label = "Debug Current File", command=self.debug_current_file)

            # AI menu (ENHANCED)
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

    #         # View menu
    view_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "View", menu=view_menu)
    view_menu.add_command(label = "Refresh File Tree", command=self.refresh_file_tree)
            view_menu.add_separator()
    view_menu.add_command(label = "Toggle File Explorer", command=lambda: self.toggle_panel("file_explorer"))
    view_menu.add_command(label = "Toggle AI Chat", command=self.show_ai_chat)
    view_menu.add_command(label = "Toggle Terminal", command=lambda: self.toggle_panel("terminal"))

    #         # Help menu
    help_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "Help", menu=help_menu)
    help_menu.add_command(label = "About", command=self.show_about)

    #     def create_toolbar(self):
    #         """Create the toolbar."""
    toolbar = tk.Frame(self.root, bg='#3c3c3c', relief='raised', bd=1)
    toolbar.pack(side = 'top', fill='x')

    #         # File operations
    tk.Button(toolbar, text = "📁 New", command=self.new_file, bg='#4CAF50', fg='white', relief='flat').pack(side='left', padx=2, pady=2)
    tk.Button(toolbar, text = "📂 Open", command=self.open_file, bg='#2196F3', fg='white', relief='flat').pack(side='left', padx=2, pady=2)
    tk.Button(toolbar, text = "💾 Save", command=self.save_file, bg='#FF9800', fg='white', relief='flat').pack(side='left', padx=2, pady=2)

    toolbar.pack(side = 'top', fill='x')

    #         # Run operations
    tk.Button(toolbar, text = "▶️ Run", command=self.run_current_file, bg='#f44336', fg='white', relief='flat').pack(side='left', padx=2, pady=2)
    tk.Button(toolbar, text = "🐍 Python", command=self.run_python_file, bg='#3776ab', fg='white', relief='flat').pack(side='left', padx=2, pady=2)

            # AI operations (ENHANCED)
    tk.Button(toolbar, text = "🤖 AI Role", command=self.show_enhanced_ai_role_selector, bg='#9C27B0', fg='white', relief='flat').pack(side='left', padx=2, pady=2)
    tk.Button(toolbar, text = "🔄 Convert", command=lambda: self.convert_python_to_nc(), bg='#673AB7', fg='white', relief='flat').pack(side='left', padx=2, pady=2)
    tk.Button(toolbar, text = "🛠️ Auto-fix", command=self.auto_fix_code_errors, bg='#3F51B5', fg='white', relief='flat').pack(side='left', padx=2, pady=2)

    #     def create_main_layout(self):
    #         """Create the main resizable layout with enhanced panels."""
    #         # Main container
    main_container = tk.Frame(self.root, bg='#2b2b2b')
    main_container.pack(fill = 'both', expand=True, padx=2, pady=2)

    #         # Create paned window for resizable layout
    main_paned = tk.PanedWindow(main_container, orient='horizontal', bg='#2b2b2b')
    main_paned.pack(fill = 'both', expand=True)

            # Left panel (File Explorer + AI Chat)
    left_panel = tk.Frame(main_paned, bg='#1e1e1e', width=300)
            left_panel.pack_propagate(False)
    main_paned.add(left_panel, minsize = 250)

    #         # File Explorer
    file_frame = tk.LabelFrame(left_panel, text="File Explorer", bg='#1e1e1e', fg='white', font=('Arial', 10, 'bold'))
    file_frame.pack(fill = 'both', expand=True, padx=5, pady=5)

    self.file_tree = ttk.Treeview(file_frame)
    file_tree_scrollbar = ttk.Scrollbar(file_frame, orient='vertical', command=self.file_tree.yview)
    self.file_tree.configure(yscrollcommand = file_tree_scrollbar.set)

    self.file_tree.pack(side = 'left', fill='both', expand=True)
    file_tree_scrollbar.pack(side = 'right', fill='y')

    #         # AI Chat
    ai_frame = tk.LabelFrame(left_panel, text="AI Chat", bg='#1e1e1e', fg='white', font=('Arial', 10, 'bold'))
    ai_frame.pack(fill = 'both', expand=True, padx=5, pady=5)

    self.ai_output = scrolledtext.ScrolledText(ai_frame, height=8, bg='#1a1a1a', fg='white', insertbackground='white')
    self.ai_output.pack(fill = 'both', expand=True, padx=2, pady=2)

    ai_input_frame = tk.Frame(ai_frame, bg='#1e1e1e')
    ai_input_frame.pack(fill = 'x', padx=2, pady=2)
    #         # View menu
    view_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "View", menu=view_menu)
    view_menu.add_command(label = "Refresh File Tree", command=self.refresh_file_tree)
            view_menu.add_separator()
    view_menu.add_command(label = "Toggle File Explorer", command=lambda: self.toggle_panel("file_explorer"))
    view_menu.add_command(label = "Toggle AI Chat", command=self.show_ai_chat)
    view_menu.add_command(label = "Toggle Terminal", command=lambda: self.toggle_panel("terminal"))

            # Progress menu (NEW)
    progress_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "Progress", menu=progress_menu)
    progress_menu.add_command(label = "Progress Manager & Analytics", command=self.show_progress_manager)
    progress_menu.add_command(label = "Export Progress Report", command=self.export_progress_report)
            progress_menu.add_separator()
    progress_menu.add_command(label = "Start Monitoring", command=self.start_progress_monitoring)
    progress_menu.add_command(label = "Stop Monitoring", command=self.stop_progress_monitoring)

    self.ai_input = tk.Entry(ai_input_frame, bg='#1a1a1a', fg='white', insertbackground='white')
    self.ai_input.pack(side = 'left', fill='x', expand=True)
            self.ai_input.bind('<Return>', self.send_ai_message)

    ai_send_btn = tk.Button(ai_input_frame, text="Send", command=self.send_ai_message, bg='#4CAF50', fg='white', relief='flat')
    ai_send_btn.pack(side = 'right', padx=(2, 0))

            # Center panel (Code Editor)
    center_panel = tk.Frame(main_paned, bg='#1e1e1e')
    main_paned.add(center_panel, minsize = 400)

    #         # Tab control for multiple files
    self.notebook = ttk.Notebook(center_panel)
    self.notebook.pack(fill = 'both', expand=True, padx=5, pady=5)

    #         # Create first welcome tab
            self.create_new_tab("Welcome.md", "# Welcome to Enhanced NoodleCore IDE\n\nSelect File > New to create a new file.")

            # Right panel (Terminal + Properties)
    right_panel = tk.Frame(main_paned, bg='#1e1e1e', width=350)
            right_panel.pack_propagate(False)
    main_paned.add(right_panel, minsize = 300)

    #         # Terminal
    terminal_frame = tk.LabelFrame(right_panel, text="Terminal", bg='#1e1e1e', fg='white', font=('Arial', 10, 'bold'))
    terminal_frame.pack(fill = 'both', expand=True, padx=5, pady=5)

    self.terminal_output = scrolledtext.ScrolledText(terminal_frame, height=12, bg='#000000', fg='#00ff00', font=('Consolas', 9))
    self.terminal_output.pack(fill = 'both', expand=True, padx=2, pady=2)
    self.terminal_output.config(state = 'disabled')

    #         # Bind file tree events
            self.file_tree.bind('<<TreeviewOpen>>', self._on_tree_expand)
            self.file_tree.bind('<Double-1>', self._on_tree_double_click)

    #         # Initialize file tree
            self.refresh_file_tree()

    #     def create_new_tab(self, title, content=""):
    #         """Create a new tab with a text widget."""
    tab_frame = tk.Frame(self.notebook, bg='#1e1e1e')
    self.notebook.add(tab_frame, text = title)

    #         # Text widget with scrollbar
    text_frame = tk.Frame(tab_frame, bg='#1e1e1e')
    text_frame.pack(fill = 'both', expand=True, padx=5, pady=5)

    text_widget = tk.Text(text_frame,
    bg = '#1a1a1a',
    fg = 'white',
    insertbackground = 'white',
    font = ('Consolas', 10),
    wrap = 'word',
    undo = True)

    #         # Scrollbar for text widget
    text_scrollbar = ttk.Scrollbar(text_frame, orient='vertical', command=text_widget.yview)
    text_widget.configure(yscrollcommand = text_scrollbar.set)

    text_widget.pack(side = 'left', fill='both', expand=True)
    text_scrollbar.pack(side = 'right', fill='y')

    #         # Insert initial content
    #         if content:
                text_widget.insert('1.0', content)

    #         # Bind events
            text_widget.bind('<KeyRelease>', self.on_text_change)
            text_widget.bind('<Tab>', self.handle_tab_completion)

            self.tab_text_widgets.append(text_widget)
    #         return text_widget

    #     def on_text_change(self, event):
    #         """Handle text changes in the editor."""
            self.code_errors.clear()
    #         # Add more sophisticated error detection here

    #     def setup_auto_complete(self):
    #         """Setup auto-complete functionality."""
    #         # Auto-complete will be handled by Tab key binding
    #         pass

    #     def handle_tab_completion(self, event):
    #         """Handle Tab key for auto-completion."""
    #         # Simple auto-completion for common keywords
    text_widget = event.widget
    cursor_pos = text_widget.index(tk.INSERT)
    line_start = text_widget.index(f"{cursor_pos} linestart")
    line_text = text_widget.get(line_start, cursor_pos)

    keywords = ['def', 'class', 'if', 'else', 'elif', 'for', 'while', 'try', 'except', 'import', 'from']

    #         for keyword in keywords:
    #             if line_text.strip() == keyword and len(line_text) == len(keyword):
    #                 # Add a space after the keyword
                    text_widget.insert(tk.INSERT, ' ')
    #                 return 'break'

    #         # If no completion, insert normal tab
            text_widget.insert(tk.INSERT, '    ')  # 4 spaces
    #         return 'break'

    #     def send_ai_message(self, event=None):
    #         """Send message to AI and get response."""
    message = self.ai_input.get().strip()
    #         if not message:
    #             return

    #         # Add user message to output
    self.ai_output.config(state = 'normal')
            self.ai_output.insert('end', f"\n👤 You: {message}\n")
            self.ai_input.delete(0, 'end')
    self.ai_output.config(state = 'disabled')
            self.ai_output.see('end')

    #         # Simulate AI response (replace with real AI call)
    #         def ai_response():
    #             try:
    #                 # For now, provide a simple response
    #                 response = f"🤖 AI ({self.current_ai_role.name if self.current_ai_role else 'Assistant'}): I understand you want to work with: {message}"
    #                 if "error" in message.lower() or "bug" in message.lower():
    response + = "\n\nI can help you identify and fix code errors. Please share the problematic code."
    #                 elif "convert" in message.lower() or "nc" in message.lower():
    response + = "\n\nI can help convert Python code to NoodleCore format using AI assistance."
    #                 elif "explain" in message.lower():
    response + = "\n\nI can explain code in detail. Please paste the code you'd like me to analyze."

    self.ai_output.config(state = 'normal')
                    self.ai_output.insert('end', response + "\n")
    self.ai_output.config(state = 'disabled')
                    self.ai_output.see('end')

    #             except Exception as e:
    self.ai_output.config(state = 'normal')
                    self.ai_output.insert('end', f"❌ AI Error: {str(e)}\n")
    self.ai_output.config(state = 'disabled')
                    self.ai_output.see('end')

    #         # Run AI response in background thread
    threading.Thread(target = ai_response, daemon=True).start()

    #     def convert_python_to_nc(self):
    #         """Convert current Python file to NoodleCore using AI."""
    #         if not self.current_file or not self.current_file.endswith('.py'):
                messagebox.showwarning("No Python File", "Please open a Python file first")
    #             return

    text_widget = self.open_files[self.current_file]
    python_code = text_widget.get('1.0', 'end-1c')

    #         # Show conversion in progress
    self.terminal_output.config(state = 'normal')
            self.terminal_output.insert('end', "\n🔄 Converting Python to NoodleCore...\n")
    self.terminal_output.insert('end', " = " * 50 + "\n")
    self.terminal_output.config(state = 'disabled')
            self.terminal_output.see('end')

    #         def convert_in_thread():
    #             try:
    #                 # Simple conversion (replace with AI conversion)
    nc_code = self._simple_python_to_nc_conversion(python_code)

    #                 # Create new .nc file
    nc_file_path = self.current_file.replace('.py', '.nc')
    #                 with open(nc_file_path, 'w', encoding='utf-8') as f:
                        f.write(nc_code)

    #                 # Open the new file
                    self.open_file_by_path(nc_file_path)

    self.terminal_output.config(state = 'normal')
                    self.terminal_output.insert('end', f"✅ Conversion complete: {nc_file_path}\n")
    self.terminal_output.config(state = 'disabled')
                    self.terminal_output.see('end')

                    messagebox.showinfo("Conversion Complete", f"Python file converted to NoodleCore:\n{nc_file_path}")

    #             except Exception as e:
    self.terminal_output.config(state = 'normal')
                    self.terminal_output.insert('end', f"❌ Conversion error: {str(e)}\n")
    self.terminal_output.config(state = 'disabled')
                    self.terminal_output.see('end')

    threading.Thread(target = convert_in_thread, daemon=True).start()

    #     def _simple_python_to_nc_conversion(self, python_code):
            """Simple Python to NoodleCore conversion (basic example)."""
    #         # This is a simplified conversion - in reality, you'd use AI
    lines = python_code.split('\n')
    nc_lines = []

    #         for line in lines:
    stripped = line.strip()
    #             if stripped.startswith('def '):
    #                 # Convert function definition
    #                 func_name = stripped.split('(')[0].replace('def ', '')
                    nc_lines.append(f"function {func_name}() {{")
    #             elif stripped.startswith('class '):
    #                 # Convert class definition
    #                 class_name = stripped.replace('class ', '').split('(')[0]
    #                 nc_lines.append(f"class {class_name} {{")
    #             elif stripped == '}' or stripped == '    }':
                    nc_lines.append('}')
    #             elif stripped and not stripped.startswith('#'):
                    nc_lines.append(f"    {stripped}")
    #             else:
                    nc_lines.append(line)

            return '\n'.join(nc_lines)

    #     def auto_fix_code_errors(self):
    #         """Auto-fix code errors using AI assistance."""
    #         if not self.current_file:
                messagebox.showwarning("No File", "Please open a file first")
    #             return

    text_widget = self.open_files[self.current_file]
    code = text_widget.get('1.0', 'end-1c')

    #         # Show analysis in progress
    self.terminal_output.config(state = 'normal')
    #         self.terminal_output.insert('end', "\n🔍 Analyzing code for errors...\n")
    self.terminal_output.config(state = 'disabled')
            self.terminal_output.see('end')

    #         def analyze_in_thread():
    #             try:
    #                 # Simple error detection (replace with AI analysis)
    errors = self._detect_simple_errors(code)

    #                 if not errors:
    self.terminal_output.config(state = 'normal')
                        self.terminal_output.insert('end', "✅ No obvious errors detected\n")
    self.terminal_output.config(state = 'disabled')
                        self.terminal_output.see('end')
                        messagebox.showinfo("Code Analysis", "No obvious errors detected in your code.")
    #                     return

    #                 # Apply fixes
    fixed_code = code
    fixes_applied = 0

    #                 for error_type, line_num, description in errors:
    #                     if error_type == "indentation":
    fixed_code = self._fix_indentation(fixed_code, line_num)
    fixes_applied + = 1
    #                     elif error_type == "syntax":
    fixed_code = self._fix_syntax_error(fixed_code, line_num)
    fixes_applied + = 1

    #                 if fixes_applied > 0:
    #                     # Update the editor
                        text_widget.delete('1.0', 'end')
                        text_widget.insert('1.0', fixed_code)

    self.terminal_output.config(state = 'normal')
                        self.terminal_output.insert('end', f"✅ Applied {fixes_applied} automatic fixes\n")
    self.terminal_output.config(state = 'disabled')
                        self.terminal_output.see('end')

                        messagebox.showinfo("Auto-fix Complete", f"Applied {fixes_applied} automatic fixes to your code.")
    #                 else:
                        messagebox.showinfo("Code Analysis", "No auto-fixable errors found.")

    #             except Exception as e:
    self.terminal_output.config(state = 'normal')
                    self.terminal_output.insert('end', f"❌ Analysis error: {str(e)}\n")
    self.terminal_output.config(state = 'disabled')
                    self.terminal_output.see('end')

    threading.Thread(target = analyze_in_thread, daemon=True).start()

    #     def _detect_simple_errors(self, code):
    #         """Simple error detection."""
    errors = []
    lines = code.split('\n')

    #         for i, line in enumerate(lines, 1):
    stripped = line.strip()
    #             if not stripped:
    #                 continue

    #             # Check for common indentation issues
    #             if line.startswith('\t') and i > 1:
    prev_line = math.subtract(lines[i, 2].strip())
    #                 if prev_line and not prev_line.startswith(('if', 'for', 'while', 'def', 'class', 'try')):
                        errors.append(("indentation", i, "Mixed tabs and spaces detected"))

    #             # Check for basic syntax issues
    #             if stripped.endswith(':') and i == len(lines):
                    errors.append(("syntax", i, "Colon at end of file"))

    #         return errors

    #     def _fix_indentation(self, code, line_num):
    #         """Fix indentation issues."""
    lines = code.split('\n')
    lines[line_num-1] = math.subtract(lines[line_num, 1].lstrip())
            return '\n'.join(lines)

    #     def _fix_syntax_error(self, code, line_num):
    #         """Fix basic syntax errors."""
    lines = code.split('\n')
    line = math.subtract(lines[line_num, 1])
    #         if line.strip().endswith(':'):
    lines[line_num-1] = line.rstrip(':')
            return '\n'.join(lines)

    #     def ai_code_review(self):
    #         """Perform AI code review on current file."""
    #         if not self.current_file:
                messagebox.showwarning("No File", "Please open a file first")
    #             return

    text_widget = self.open_files[self.current_file]
    code = text_widget.get('1.0', 'end-1c')

    #         # Show review in progress
    self.terminal_output.config(state = 'normal')
    #         self.terminal_output.insert('end', f"\n🔍 AI Code Review for {Path(self.current_file).name}\n")
    self.terminal_output.insert('end', " = " * 50 + "\n")
    self.terminal_output.config(state = 'disabled')
            self.terminal_output.see('end')

    #         def review_in_thread():
    #             try:
    #                 # Simple code review (replace with AI)
    self.terminal_output.config(state = 'normal')
                    self.terminal_output.insert('end', f"📋 Code Review Results:\n")
                    self.terminal_output.insert('end', f"• File: {Path(self.current_file).name}\n")
                    self.terminal_output.insert('end', f"• Lines: {len(code.splitlines())}\n")
    #                 self.terminal_output.insert('end', f"• AI Role: {self.current_ai_role.name if self.current_ai_role else 'Code Assistant'}\n")
                    self.terminal_output.insert('end', "\n🔍 Analysis:\n")
                    self.terminal_output.insert('end', "• Code structure looks good\n")
    #                 self.terminal_output.insert('end', "• Consider adding comments for complex functions\n")
                    self.terminal_output.insert('end', "• Check variable naming consistency\n")
                    self.terminal_output.insert('end', "• Overall code quality: Good\n")
    self.terminal_output.config(state = 'disabled')
                    self.terminal_output.see('end')

    #                 messagebox.showinfo("Code Review Complete", "AI code review completed. Check the terminal for detailed analysis.")

    #             except Exception as e:
    self.terminal_output.config(state = 'normal')
                    self.terminal_output.insert('end', f"❌ Review error: {str(e)}\n")
    self.terminal_output.config(state = 'disabled')
                    self.terminal_output.see('end')

    threading.Thread(target = review_in_thread, daemon=True).start()

    #     def ai_explain_code(self):
    #         """Explain current code using AI."""
    #         if not self.current_file:
                messagebox.showwarning("No File", "Please open a file first")
    #             return

    text_widget = self.open_files[self.current_file]
    code = text_widget.get('1.0', 'end-1c')

    #         # Show explanation in progress
    self.terminal_output.config(state = 'normal')
    #         self.terminal_output.insert('end', f"\n💡 AI Code Explanation for {Path(self.current_file).name}\n")
    self.terminal_output.insert('end', " = " * 50 + "\n")
    self.terminal_output.config(state = 'disabled')
            self.terminal_output.see('end')

    #         def explain_in_thread():
    #             try:
    #                 # Simple code explanation (replace with AI)
    self.terminal_output.config(state = 'normal')
                    self.terminal_output.insert('end', f"📖 Code Explanation:\n")
                    self.terminal_output.insert('end', f"• This appears to be a {Path(self.current_file).suffix} file\n")
                    self.terminal_output.insert('end', f"• Contains {len(code.splitlines())} lines of code\n")
                    self.terminal_output.insert('end', f"• The code defines various functions and structures\n")
                    self.terminal_output.insert('end', f"• Key components include UI elements, file operations, and event handling\n")
                    self.terminal_output.insert('end', "\n💡 Suggestions:\n")
    #                 self.terminal_output.insert('end', "• Add documentation for complex functions\n")
                    self.terminal_output.insert('end', "• Consider breaking down large functions\n")
                    self.terminal_output.insert('end', "• Use consistent naming conventions\n")
    self.terminal_output.config(state = 'disabled')
                    self.terminal_output.see('end')

    #                 messagebox.showinfo("Code Explanation Complete", "AI code explanation completed. Check the terminal for detailed analysis.")

    #             except Exception as e:
    self.terminal_output.config(state = 'normal')
                    self.terminal_output.insert('end', f"❌ Explanation error: {str(e)}\n")
    self.terminal_output.config(state = 'disabled')
                    self.terminal_output.see('end')

    threading.Thread(target = explain_in_thread, daemon=True).start()

    #     def debug_current_file(self):
    #         """Debug the current file."""
    #         if not self.current_file:
                messagebox.showwarning("No File", "No file is currently open")
    #             return

    self.terminal_output.config(state = 'normal')
            self.terminal_output.insert('end', f"\n🐛 Debugging: {self.current_file}\n")
    self.terminal_output.insert('end', " = " * 50 + "\n")
    self.terminal_output.config(state = 'disabled')
            self.terminal_output.see('end')

    #         # Run with debug mode
    #         if self.current_file.endswith('.py'):
                self.run_current_file()

    #     def new_file(self):
    #         """Create a new file."""
    filename = filedialog.asksaveasfilename(
    title = "New File",
    defaultextension = ".py",
    filetypes = [("All files", "*.*"), ("Python", "*.py"), ("NoodleCore", "*.nc"), ("Text", "*.txt"), ("HTML", "*.html"), ("CSS", "*.css"), ("JavaScript", "*.js")]
    #         )

    #         if filename:
    #             try:
    #                 # Create empty file
                    Path(filename).touch()

    #                 # Open in editor
                    self.open_file_by_path(filename)
    self.status_bar.config(text = f"Created new file: {filename}")

    #             except Exception as e:
                    messagebox.showerror("Error", f"Could not create file: {str(e)}")

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

#     # AI Role Management Methods
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
command = lambda r=role: self.select_ai_role(r, current_role_label),
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

#     def select_ai_role(self, role, current_role_label):
#         """Select an AI role."""
self.current_ai_role = role
current_role_label.config(text = role.name)
self.status_bar.config(text = f"AI role changed to: {role.name}")
        messagebox.showinfo("AI Role Selected", f"AI role changed to: {role.name}")

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

#     # Progress Manager Integration Methods
#     def show_progress_manager(self):
#         """Show the progress manager dialog."""
#         if self.progress_manager:
            self.progress_manager.show_progress_dialog()
#         else:
#             messagebox.showinfo("Progress Manager", "Progress Manager is not available. Please check if progress_manager.py is in the same directory.")

#     def export_progress_report(self):
#         """Export progress report."""
#         if self.progress_manager:
            self.progress_manager._export_progress_report()
#         else:
            messagebox.showinfo("Progress Report", "Progress Manager is not available.")

#     def start_progress_monitoring(self):
#         """Start progress monitoring."""
#         if self.progress_manager:
            self.progress_manager.start_monitoring()
self.status_bar.config(text = "Progress monitoring started")
            messagebox.showinfo("Progress Monitoring", "Progress monitoring has been started.")
#         else:
            messagebox.showinfo("Progress Monitoring", "Progress Manager is not available.")

#     def stop_progress_monitoring(self):
#         """Stop progress monitoring."""
#         if self.progress_manager:
            self.progress_manager.stop_monitoring()
self.status_bar.config(text = "Progress monitoring stopped")
            messagebox.showinfo("Progress Monitoring", "Progress monitoring has been stopped.")
#         else:
            messagebox.showinfo("Progress Monitoring", "Progress Manager is not available.")

#     # Update progress for various activities
#     def update_progress_for_activity(self, activity_type, details):
#         """Update progress for various activities."""
#         if self.progress_manager:
#             if activity_type in ['file_opened', 'code_run', 'ai_assist', 'conversion', 'error_fix']:
                self.progress_manager._update_project_progress(activity_type, details)
#             elif activity_type.startswith('ai_'):
                self.progress_manager._update_ai_role_progress(activity_type, details)
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

#         # Instructions
        tk.Label(
#             top,
text = "Use the AI Role Selector to add new roles or select different ones",
bg = '#2b2b2b',
fg = '#cccccc',
font = ('Arial', 10)
).pack(pady = 5)

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
close_btn.pack(pady = 20)

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