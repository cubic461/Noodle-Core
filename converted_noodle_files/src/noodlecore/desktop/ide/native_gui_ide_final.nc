# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# NoodleCore Native GUI IDE - Final Working Version
# Complete functional IDE with AI integration and progress tracking
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
import pathlib.Path
import tempfile
import shutil
import datetime.datetime
import webbrowser

# Import Pygments for syntax highlighting
try
    #     from pygments import highlight
    #     from pygments.lexers import get_lexer_by_name, guess_lexer
    #     from pygments.formatters import HtmlFormatter
    PYGMENTS_AVAILABLE = True
except ImportError
    PYGMENTS_AVAILABLE = False
        print("Pygments not available - syntax highlighting will be limited")

# Import progress manager
try
    #     from progress_manager import ProgressManager
    PROGRESS_MANAGER_AVAILABLE = True
        print("Progress Manager loaded successfully")
except ImportError as e
    PROGRESS_MANAGER_AVAILABLE = False
        print(f"Progress Manager not available: {e}")

# Simple AI Role Management
class AIRole
    #     def __init__(self, name, description, system_prompt, capabilities):
    self.name = name
    self.description = description
    self.system_prompt = system_prompt
    self.capabilities = capabilities

class NativeNoodleCoreIDE
    #     """Complete NoodleCore GUI IDE with enhanced features."""

    #     def __init__(self):
    self.root = tk.Tk()
            self.root.title("NoodleCore Native GUI IDE - Final Version")
            self.root.geometry("1200x800")
    self.root.configure(bg = '#2b2b2b')

    #         # Enable proper window resizing
            self.root.resizable(True, True)
            self.root.minsize(800, 600)

    #         # Panel visibility management
    self.panel_states = {
    #             'file_explorer': True,
    #             'code_editor': True,
    #             'terminal': True,
    #             'ai_chat': True,
    #             'properties': False
    #         }

    #         # File system state
    self.current_project_path = Path.cwd()
    self.file_tree_paths = {}
    self.workspace_state = {
    #             'recent_files': [],
    #             'project_history': [],
    #             'search_history': [],
    #             'active_tab': 0
    #         }

    #         # AI configuration
    self.ai_providers = {
    #             "OpenAI": {
    #                 "models": ["gpt-3.5-turbo", "gpt-4", "gpt-4-turbo"],
    #                 "api_key_required": True,
    #                 "base_url": "https://api.openai.com/v1"
    #             },
    #             "OpenRouter": {
    #                 "models": ["gpt-3.5-turbo", "llama-2-70b-chat", "claude-2"],
    #                 "api_key_required": True,
    #                 "base_url": "https://openrouter.ai/api/v1"
    #             },
    #             "LM Studio": {
    #                 "models": ["local-model"],
    #                 "api_key_required": False,
    #                 "base_url": "http://localhost:1234"
    #             }
    #         }

    #         # Load persisted AI config
    self.current_ai_provider = "OpenRouter"
    self.current_ai_model = "gpt-3.5-turbo"
    self.ai_api_key = ""

    #         # AI Roles
    self.ai_roles = self.load_ai_roles()
    #         self.current_ai_role = self.ai_roles[0] if self.ai_roles else None

    #         # File tracking
    self.open_files = {}
    self.current_file = None
    self.unsaved_changes = {}
    self.tab_text_widgets = []

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

    #         # Create UI
            self.create_ui()
            self.create_main_layout()

    #         # Show welcome message
            self.show_welcome_message()

    #         # Load saved state
            self.load_workspace_state()
            self.apply_panel_visibility()

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
    #         """Create the menu bar."""
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

    #         # AI menu
    ai_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "AI", menu=ai_menu)
    ai_menu.add_command(label = "AI Role Selector", command=self.show_ai_role_selector)
    ai_menu.add_command(label = "Add New AI Role", command=self.add_new_ai_role)
    ai_menu.add_command(label = "Edit AI Roles", command=self.edit_ai_roles)
    ai_menu.add_command(label = "Configure AI Provider", command=self.configure_ai_provider)

    #         # View menu
    view_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "View", menu=view_menu)
    view_menu.add_command(label = "Refresh File Tree", command=self.refresh_file_tree)
            view_menu.add_separator()
    view_menu.add_command(label = "Toggle File Explorer", command=lambda: self.toggle_panel("file_explorer"))
    view_menu.add_command(label = "Toggle AI Chat", command=self.show_ai_chat)
    view_menu.add_command(label = "Toggle Terminal", command=lambda: self.toggle_panel("terminal"))

            # Progress menu (NEW)
    #         if PROGRESS_MANAGER_AVAILABLE:
    progress_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "Progress", menu=progress_menu)
    progress_menu.add_command(label = "Progress Manager & Analytics", command=self.show_progress_manager)
    progress_menu.add_command(label = "Export Progress Report", command=self.export_progress_report)
                progress_menu.add_separator()
    progress_menu.add_command(label = "Start Monitoring", command=self.start_progress_monitoring)
    progress_menu.add_command(label = "Stop Monitoring", command=self.stop_progress_monitoring)

    #         # Help menu
    help_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "Help", menu=help_menu)
    help_menu.add_command(label = "About", command=self.show_about)

    #     def create_toolbar(self):
    #         """Create the toolbar."""
    toolbar = tk.Frame(self.root, bg='#1e1e1e', relief='raised', bd=1)
    toolbar.pack(side = 'top', fill='x')

    #         # File operations
    tk.Button(toolbar, text = "New", command=self.new_file,
    bg = '#4CAF50', fg='white').pack(side='left', padx=2, pady=2)
    tk.Button(toolbar, text = "Open", command=self.open_file,
    bg = '#2196F3', fg='white').pack(side='left', padx=2, pady=2)
    tk.Button(toolbar, text = "Save", command=self.save_file,
    bg = '#FF9800', fg='white').pack(side='left', padx=2, pady=2)

    toolbar.separator = tk.Frame(toolbar, width=2, bg='gray')
    toolbar.separator.pack(side = 'left', padx=10, fill='y', pady=2)

    #         # AI operations
    tk.Button(toolbar, text = "AI Chat", command=self.show_ai_chat,
    bg = '#9C27B0', fg='white').pack(side='left', padx=2, pady=2)
    tk.Button(toolbar, text = "Code Review", command=self.request_ai_review,
    bg = '#E91E63', fg='white').pack(side='left', padx=2, pady=2)

    #         # Progress operations
    #         if PROGRESS_MANAGER_AVAILABLE:
    tk.Button(toolbar, text = "Progress", command=self.show_progress_manager,
    bg = '#673AB7', fg='white').pack(side='left', padx=2, pady=2)

    #     def create_main_layout(self):
    #         """Create the main layout with resizable panels."""
    #         # Main container
    main_container = tk.Frame(self.root, bg='#2b2b2b')
    main_container.pack(fill = 'both', expand=True, padx=5, pady=5)

    #         # Top split: File Explorer and Code Editor
    top_frame = tk.Frame(main_container, bg='#2b2b2b')
    top_frame.pack(fill = 'both', expand=True)

            # Left panel (File Explorer)
    left_frame = tk.Frame(top_frame, bg='#2b2b2b', width=300)
    left_frame.pack(side = 'left', fill='y')
            left_frame.pack_propagate(False)

    #         # File tree
    self.file_tree = ttk.Treeview(left_frame)
    self.file_tree.pack(fill = 'both', expand=True, padx=5, pady=5)
            self.file_tree.bind('<<TreeviewSelect>>', self.on_file_select)
            self.file_tree.bind('<Double-1>', self.on_file_double_click)

    #         # Context menu for file tree
    self.file_tree_context = tk.Menu(self.root, tearoff=0)
    self.file_tree_context.add_command(label = "Open", command=self.open_selected_file)
    self.file_tree_context.add_command(label = "Refresh", command=self.refresh_file_tree)
            self.file_tree.bind('<Button-3>', self.show_file_context_menu)

            # Right panel (Code Editor)
    right_frame = tk.Frame(top_frame, bg='#2b2b2b')
    right_frame.pack(side = 'right', fill='both', expand=True)

    #         # Code editor area
    self.notebook = ttk.Notebook(right_frame)
    self.notebook.pack(fill = 'both', expand=True, padx=5, pady=5)

    #         # Create initial tab
            self.create_new_tab("Welcome", "welcome")

            # Bottom panel (Terminal and AI Chat)
    bottom_frame = tk.Frame(main_container, bg='#2b2b2b', height=200)
    bottom_frame.pack(fill = 'x', pady=5)
            bottom_frame.pack_propagate(False)

    #         # Split bottom panel
    bottom_paned = tk.PanedWindow(bottom_frame, orient='horizontal', bg='#2b2b2b')
    bottom_paned.pack(fill = 'both', expand=True)

    #         # Terminal panel
    terminal_frame = tk.Frame(bottom_paned, bg='#2b2b2b')
    bottom_paned.add(terminal_frame, minsize = 400)

    tk.Label(terminal_frame, text = "Terminal", bg='#2b2b2b', fg='white',
    font = ('Arial', 10, 'bold')).pack(anchor='w', padx=5, pady=2)

    self.terminal_output = scrolledtext.ScrolledText(
    terminal_frame, bg = '#1e1e1e', fg='#00ff00',
    font = ('Consolas', 10), state='disabled'
    #         )
    self.terminal_output.pack(fill = 'both', expand=True, padx=5, pady=5)

    #         # AI Chat panel
    ai_frame = tk.Frame(bottom_paned, bg='#2b2b2b')
    bottom_paned.add(ai_frame, minsize = 300)

    tk.Label(ai_frame, text = "AI Assistant", bg='#2b2b2b', fg='white',
    font = ('Arial', 10, 'bold')).pack(anchor='w', padx=5, pady=2)

    self.ai_chat_output = scrolledtext.ScrolledText(
    ai_frame, bg = '#1e1e1e', fg='#ffffff',
    font = ('Arial', 10), state='disabled'
    #         )
    self.ai_chat_output.pack(fill = 'both', expand=True, padx=5, pady=5)

    #         # AI input
    ai_input_frame = tk.Frame(ai_frame, bg='#2b2b2b')
    ai_input_frame.pack(fill = 'x', padx=5, pady=2)

    self.ai_input = tk.Entry(ai_input_frame, bg='#1e1e1e', fg='white',
    font = ('Arial', 10))
    self.ai_input.pack(side = 'left', fill='x', expand=True, padx=(0, 5))
            self.ai_input.bind('<Return>', self.send_ai_message)

    tk.Button(ai_input_frame, text = "Send", command=self.send_ai_message,
    bg = '#4CAF50', fg='white').pack(side='right')

    #         # Initialize file tree
            self.refresh_file_tree()

    #     def create_new_tab(self, title, content_type="text"):
    #         """Create a new code editor tab."""
    tab_frame = tk.Frame(self.notebook, bg='#1e1e1e')
    tab_index = self.notebook.index('end')
    self.notebook.add(tab_frame, text = title)

    #         if content_type == "welcome":
    #             # Welcome text for initial tab
    text_widget = scrolledtext.ScrolledText(
    tab_frame, bg = '#1e1e1e', fg='#ffffff',
    font = ('Consolas', 11)
    #             )
    text_widget.pack(fill = 'both', expand=True, padx=5, pady=5)
                text_widget.insert('1.0', self.get_welcome_text())
    text_widget.config(state = 'disabled')
    #         else:
    #             # Code editor for new files
    text_widget = scrolledtext.ScrolledText(
    tab_frame, bg = '#1e1e1e', fg='#ffffff',
    font = ('Consolas', 11), wrap='none'
    #             )
    text_widget.pack(fill = 'both', expand=True, padx=5, pady=5)
                text_widget.bind('<KeyRelease>', self.on_text_change)

    #             # Line numbers
    line_numbers = tk.Canvas(
    tab_frame, width = 50, bg='#2d2d2d', highlightthickness=0
    #             )
    line_numbers.pack(side = 'left', fill='y')
    text_widget.window_create('1.0', window = line_numbers)

            self.tab_text_widgets.append(text_widget)
    #         return tab_frame

    #     def get_welcome_text(self):
    #         """Get welcome text for the IDE."""
    #         return """# 🚀 Welcome to NoodleCore Native GUI IDE!

## ✨ Features:

### 📁 **File Management**
# - Real file system integration
# - Multi-tab editing
# - Syntax highlighting

### 🤖 **AI Integration**
- Multiple AI providers (OpenAI, OpenRouter, LM Studio)
# - AI role management
# - Real-time code assistance

### 📊 **Progress Tracking** (NEW!)
# - Development progress monitoring
# - AI learning analytics
# - Achievement system
# - Project milestones

### 🛠️ **How to Use:**

# 1. **Open Files**: File → Open File or double-click in explorer
# 2. **AI Chat**: Use the AI panel at the bottom
# 3. **Progress**: Check Progress menu for analytics
# 4. **Run Code**: Use toolbar or File menu

# Ready to code? **Create a new file and start!** 🎉

# **Recent Updates:**
# - ✅ Enhanced AI role system
# - ✅ Progress manager with analytics
# - ✅ Achievement tracking
# - ✅ Improved UI and functionality"""

#     def on_file_select(self, event):
#         """Handle file tree selection."""
#         pass

#     def on_file_double_click(self, event):
#         """Handle double-click on file tree."""
selection = self.file_tree.selection()
#         if selection:
            self.open_selected_file()

#     def show_file_context_menu(self, event):
#         """Show context menu for file tree."""
        self.file_tree_context.post(event.x_root, event.y_root)

#     def open_selected_file(self):
#         """Open the currently selected file."""
selection = self.file_tree.selection()
#         if not selection:
#             return

item = selection[0]
#         if item not in self.file_tree_paths:
#             return

file_path = self.file_tree_paths[item]
#         if file_path.is_file():
            self.open_file_path(str(file_path))

#     def open_file_path(self, file_path):
#         """Open a file by path."""
#         try:
#             if file_path in self.open_files:
#                 # File is already open, switch to its tab
#                 for i, (path, _) in enumerate(self.open_files.items()):
#                     if path == file_path:
                        self.notebook.select(i)
#                         return

#             # Open new file
#             with open(file_path, 'r', encoding='utf-8') as f:
content = f.read()

file_name = Path(file_path).name
tab_frame = self.create_new_tab(file_name)

text_widget = math.subtract(self.tab_text_widgets[, 1])
text_widget.config(state = 'normal')
            text_widget.delete('1.0', 'end')
            text_widget.insert('1.0', content)
text_widget.config(state = 'disabled')

self.open_files[file_path] = text_widget
self.current_file = file_path

self.status_bar.config(text = f"Opened: {file_name}")

#         except Exception as e:
            messagebox.showerror("Error", f"Could not open file: {str(e)}")

#     def refresh_file_tree(self):
#         """Refresh the file tree."""
        self.file_tree.delete(*self.file_tree.get_children())

root_id = self.file_tree.insert('', 'end', text="📁 " + str(self.current_project_path), open=True)
self.file_tree_paths[root_id] = self.current_project_path
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

#     def new_file(self):
#         """Create a new file."""
        self.create_new_tab("Untitled")
self.status_bar.config(text = "New file created")

#     def open_file(self):
#         """Open a file dialog."""
file_path = filedialog.askopenfilename(
title = "Open File",
filetypes = [("All files", "*.*"), ("Python files", "*.py"), ("Text files", "*.txt"), ("NC files", "*.nc")]
#         )
#         if file_path:
            self.open_file_path(file_path)

#     def save_file(self):
#         """Save the current file."""
#         if not self.current_file:
            self.save_file_as()
#             return

#         try:
current_tab = self.notebook.winfo_children()[self.notebook.index('current')]
#             for widget in current_tab.winfo_children():
#                 if isinstance(widget, scrolledtext.ScrolledText):
content = widget.get('1.0', 'end-1c')
#                     break
#             else:
#                 return

#             with open(self.current_file, 'w', encoding='utf-8') as f:
                f.write(content)

#             if self.current_file in self.unsaved_changes:
#                 del self.unsaved_changes[self.current_file]

self.status_bar.config(text = f"Saved: {Path(self.current_file).name}")

#         except Exception as e:
            messagebox.showerror("Error", f"Could not save file: {str(e)}")

#     def save_file_as(self):
#         """Save the current file as."""
file_path = filedialog.asksaveasfilename(
title = "Save As",
defaultextension = ".py",
filetypes = [("Python files", "*.py"), ("Text files", "*.txt"), ("NC files", "*.nc"), ("All files", "*.*")]
#         )
#         if file_path:
self.current_file = file_path
            self.save_file()

#     def on_text_change(self, event):
#         """Handle text changes in editor."""
#         if self.current_file:
self.unsaved_changes[self.current_file] = True

#     def show_ai_chat(self):
#         """Show AI chat interface."""
#         # AI chat is always visible in the bottom panel
#         pass

#     def send_ai_message(self, event=None):
#         """Send message to AI."""
message = self.ai_input.get().strip()
#         if not message:
#             return

        self.ai_input.delete(0, 'end')

#         # Add user message to chat
self.ai_chat_output.config(state = 'normal')
        self.ai_chat_output.insert('end', f"You: {message}\n\n")
self.ai_chat_output.config(state = 'disabled')
        self.ai_chat_output.see('end')

        # Simulate AI response (in a real implementation, this would call an AI API)
        self.root.after(1000, lambda: self.simulate_ai_response(message))

#     def simulate_ai_response(self, user_message):
#         """Simulate AI response (placeholder for real AI integration)."""
responses = [
#             "I understand you're working on your project. How can I help?",
#             "That's an interesting approach! Have you considered using AI roles?",
#             "I can help you with code reviews, explanations, and development guidance.",
#             "The progress manager can help track your development journey!",
#             "Let me know if you need assistance with NoodleCore syntax or features."
#         ]

#         import random
response = random.choice(responses)

self.ai_chat_output.config(state = 'normal')
        self.ai_chat_output.insert('end', f"AI: {response}\n\n")
self.ai_chat_output.config(state = 'disabled')
        self.ai_chat_output.see('end')

#     def show_ai_role_selector(self):
#         """Show AI role selector dialog."""
#         if not self.ai_roles:
self.ai_roles = self.load_ai_roles()

top = tk.Toplevel(self.root)
        top.title("Select AI Role")
        top.geometry("400x300")
top.configure(bg = '#2b2b2b')
        top.transient(self.root)
        top.grab_set()

#         # Title
tk.Label(top, text = "🤖 AI Role Selector", bg='#2b2b2b', fg='white',
font = ('Arial', 14, 'bold')).pack(pady=10)

#         # Role list
listbox = tk.Listbox(top, bg='#1e1e1e', fg='white', font=('Arial', 10))
listbox.pack(fill = 'both', expand=True, padx=20, pady=10)

#         for role in self.ai_roles:
            listbox.insert('end', f"{role.name} - {role.description}")

#         # Buttons
button_frame = tk.Frame(top, bg='#2b2b2b')
button_frame.pack(fill = 'x', padx=20, pady=10)

tk.Button(button_frame, text = "Select", command=lambda: self.select_ai_role(listbox, top),
bg = '#4CAF50', fg='white').pack(side='left', padx=5)
tk.Button(button_frame, text = "Cancel", command=top.destroy,
bg = '#f44336', fg='white').pack(side='right', padx=5)

#     def select_ai_role(self, listbox, dialog):
#         """Select an AI role."""
selection = listbox.curselection()
#         if selection:
index = selection[0]
self.current_ai_role = self.ai_roles[index]
self.status_bar.config(text = f"AI Role: {self.current_ai_role.name}")
            dialog.destroy()

#     def add_new_ai_role(self):
#         """Add a new AI role."""
top = tk.Toplevel(self.root)
        top.title("Add New AI Role")
        top.geometry("500x400")
top.configure(bg = '#2b2b2b')
        top.transient(self.root)
        top.grab_set()

#         # Name
tk.Label(top, text = "Role Name:", bg='#2b2b2b', fg='white').pack(anchor='w', padx=20, pady=(20, 5))
name_entry = tk.Entry(top, bg='#1e1e1e', fg='white')
name_entry.pack(fill = 'x', padx=20, pady=(0, 10))

#         # Description
tk.Label(top, text = "Description:", bg='#2b2b2b', fg='white').pack(anchor='w', padx=20, pady=5)
desc_entry = tk.Entry(top, bg='#1e1e1e', fg='white')
desc_entry.pack(fill = 'x', padx=20, pady=(0, 10))

#         # System Prompt
tk.Label(top, text = "System Prompt:", bg='#2b2b2b', fg='white').pack(anchor='w', padx=20, pady=5)
prompt_text = scrolledtext.ScrolledText(top, height=8, bg='#1e1e1e', fg='white')
prompt_text.pack(fill = 'both', expand=True, padx=20, pady=5)

#         def save_role():
name = name_entry.get().strip()
description = desc_entry.get().strip()
system_prompt = prompt_text.get('1.0', 'end-1c').strip()

#             if not name:
                messagebox.showerror("Error", "Role name is required")
#                 return

new_role = AIRole(name, description, system_prompt, [])
            self.ai_roles.append(new_role)
            self.save_ai_roles()
            messagebox.showinfo("Success", f"AI role '{name}' added!")
            top.destroy()

tk.Button(top, text = "Save Role", command=save_role, bg='#4CAF50', fg='white').pack(pady=20)

#     def edit_ai_roles(self):
#         """Edit AI roles."""
        messagebox.showinfo("Edit AI Roles", "Use 'Add New AI Role' to create or modify roles through the AI interface.")

#     def configure_ai_provider(self):
#         """Configure AI provider settings."""
top = tk.Toplevel(self.root)
        top.title("Configure AI Provider")
        top.geometry("400x300")
top.configure(bg = '#2b2b2b')
        top.transient(self.root)
        top.grab_set()

#         # Provider selection
tk.Label(top, text = "Provider:", bg='#2b2b2b', fg='white').pack(anchor='w', padx=20, pady=(20, 5))
provider_var = tk.StringVar(value=self.current_ai_provider)
provider_combo = ttk.Combobox(top, textvariable=provider_var, values=list(self.ai_providers.keys()))
provider_combo.pack(fill = 'x', padx=20, pady=(0, 10))

#         # Model selection
tk.Label(top, text = "Model:", bg='#2b2b2b', fg='white').pack(anchor='w', padx=20, pady=5)
model_var = tk.StringVar(value=self.current_ai_model)
model_combo = ttk.Combobox(top, textvariable=model_var)
model_combo.pack(fill = 'x', padx=20, pady=(0, 10))

#         # API Key (if required)
api_frame = tk.Frame(top, bg='#2b2b2b')
api_frame.pack(fill = 'x', padx=20, pady=10)

tk.Label(api_frame, text = "API Key:", bg='#2b2b2b', fg='white').pack(anchor='w')
api_key_entry = tk.Entry(api_frame, bg='#1e1e1e', fg='white', show='*')
api_key_entry.pack(fill = 'x', pady=(0, 10))

#         def update_config():
self.current_ai_provider = provider_var.get()
self.current_ai_model = model_var.get()
self.ai_api_key = api_key_entry.get()
            messagebox.showinfo("Success", "AI provider configuration updated!")
            top.destroy()

tk.Button(top, text = "Save", command=update_config, bg='#4CAF50', fg='white').pack(pady=20)

#     def request_ai_review(self):
#         """Request AI code review."""
#         if not self.current_file:
            messagebox.showwarning("No File", "Please open a file first")
#             return

self.ai_chat_output.config(state = 'normal')
#         self.ai_chat_output.insert('end', "\nAI: I'll review your current file for improvements and suggestions.\n\n")
self.ai_chat_output.config(state = 'disabled')
        self.ai_chat_output.see('end')

#     def toggle_panel(self, panel_name):
#         """Toggle panel visibility."""
#         # This is a simplified implementation
#         pass

#     def show_progress_manager(self):
#         """Show progress manager dialog."""
#         if self.progress_manager:
            self.progress_manager.show_progress_dialog()
#         else:
            messagebox.showinfo("Progress Manager", "Progress Manager is not available.")

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
#         else:
            messagebox.showinfo("Progress Monitoring", "Progress Manager is not available.")

#     def stop_progress_monitoring(self):
#         """Stop progress monitoring."""
#         if self.progress_manager:
            self.progress_manager.stop_monitoring()
self.status_bar.config(text = "Progress monitoring stopped")
#         else:
            messagebox.showinfo("Progress Monitoring", "Progress Manager is not available.")

#     def load_ai_roles(self):
#         """Load AI roles from configuration."""
#         try:
config_dir = Path.home() / '.noodlecore'
config_dir.mkdir(exist_ok = True)
config_file = config_dir / 'ai_roles.json'

#             if config_file.exists():
#                 with open(config_file, 'r') as f:
roles_data = json.load(f)
#                     return [
                        AIRole(
#                             role['name'],
#                             role['description'],
#                             role['system_prompt'],
#                             role['capabilities']
#                         )
#                         for role in roles_data
#                     ]
#         except Exception as e:
            print(f"Could not load AI roles: {e}")

#         # Return default roles
#         return [
#             AIRole("Code Reviewer", "Reviews code for quality and best practices",
#                    "You are a code reviewer. Focus on code quality, security, and best practices.", []),
            AIRole("NoodleCore Expert", "Specialist in NoodleCore development",
#                    "You are a NoodleCore development expert. Help with .nc files and NoodleCore features.", []),
            AIRole("General Assistant", "General programming assistance",
#                    "You are a helpful programming assistant. Provide clear and accurate guidance.", [])
#         ]

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

#     def show_about(self):
#         """Show about dialog."""
about_text = """🚀 NoodleCore Native GUI IDE

# A complete, enhanced development environment with:

# ✨ **Core Features:**
# • Real file system integration
# • Multi-tab code editing
# • Syntax highlighting
# • AI role management

# 🆕 **New Features:**
# • Progress tracking & analytics
# • AI learning monitoring
# • Achievement system
# • Project milestones

# 🤖 **AI Integration:**
• Multiple providers (OpenAI, OpenRouter, LM Studio)
# • Custom AI roles
# • Real-time assistance

# 📊 **Progress Manager:**
# • Development analytics
# • Learning progress tracking
# • Performance metrics
# • Export reports

# Developed with ❤️ for the NoodleCore community!"""

        messagebox.showinfo("About NoodleCore IDE", about_text)

#     def show_welcome_message(self):
#         """Show welcome message in the first tab."""
#     def apply_panel_visibility(self):
#         """Apply panel visibility settings."""
#         # This is a simplified implementation - panels are always visible in this version
#         pass
#         # The welcome message is already shown in the first tab during creation
#         pass

#     def load_workspace_state(self):
#         """Load workspace state."""
#         try:
config_path = Path.home() / '.noodlecore' / 'workspace_state.json'
#             if config_path.exists():
#                 with open(config_path, 'r') as f:
                    self.workspace_state.update(json.load(f))
#         except:
#             pass

#     def on_closing(self):
#         """Handle window closing."""
        self.save_workspace_state()

#         # Check for unsaved changes
#         if any(self.unsaved_changes.values()):
#             if not messagebox.askyesno("Unsaved Changes",
#                                      "You have unsaved changes. Do you want to exit anyway?"):
#                 return

#         # Stop progress monitoring
#         if self.progress_manager:
            self.progress_manager.stop_monitoring()

        self.root.quit()

#     def save_workspace_state(self):
#         """Save workspace state."""
#         try:
config_path = Path.home() / '.noodlecore' / 'workspace_state.json'
config_path.parent.mkdir(exist_ok = True)

#             with open(config_path, 'w') as f:
json.dump(self.workspace_state, f, indent = 2)

#         except Exception as e:
            print(f"Could not save workspace state: {e}")

#     def run(self):
#         """Start the IDE main loop."""
#         try:
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