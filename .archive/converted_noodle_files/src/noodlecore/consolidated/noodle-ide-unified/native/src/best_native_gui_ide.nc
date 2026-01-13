# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# NoodleCore Native GUI IDE - Enhanced Canonical Implementation

# This file defines the canonical NativeNoodleCoreIDE used by launch_native_ide.py.
# Enhanced with AI integration, Git features, and advanced functionality while maintaining stability.

# Key requirements:
# - Expose class NativeNoodleCoreIDE as the main IDE class.
# - Be importable as noodlecore.desktop.ide.native_gui_ide.
# - Include AI provider integration, Git tools, and progress tracking
# - Maintain stability with proper error handling.
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
import webbrowser
import queue
import concurrent.futures.ThreadPoolExecutor
import logging
import inspect
import pathlib.Path
import datetime.datetime
import uuid

# Optional: syntax highlighting support via Pygments
try
    #     from pygments import highlight
    #     from pygments.lexers import get_lexer_by_name, guess_lexer
    #     from pygments.formatters import HtmlFormatter
    PYGMENTS_AVAILABLE = True
except Exception
    PYGMENTS_AVAILABLE = False
        print("Pygments not available - syntax highlighting disabled")

# Import progress manager
try
    #     from .progress_manager import ProgressManager
    PROGRESS_MANAGER_AVAILABLE = True
        print("Progress Manager loaded successfully")
except ImportError as e
    PROGRESS_MANAGER_AVAILABLE = False
        print(f"Progress Manager not available: {e}")

# AI Provider Classes for Real AI Integration
class AIProvider
    #     """Base class for AI providers."""
    #     def __init__(self, name, base_url, api_key_required=False):
    self.name = name
    self.base_url = base_url
    self.api_key_required = api_key_required

    #     async def chat_completion(self, messages, api_key=None, model="gpt-3.5-turbo"):
    #         raise NotImplementedError

    #     async def get_available_models(self, api_key=None):
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

    #     async def get_available_models(self, api_key=None):
    #         """Get available models from OpenAI API."""
    #         if not api_key:
    #             return ["gpt-3.5-turbo", "gpt-4", "gpt-4-turbo", "gpt-4o"]

    headers = {
    #             "Authorization": f"Bearer {api_key}",
    #             "Content-Type": "application/json"
    #         }

    #         try:
    #             async with aiohttp.ClientSession() as session:
    #                 async with session.get(f"{self.base_url}/models", headers=headers) as response:
    #                     if response.status == 200:
    result = await response.json()
    #                         models = [model['id'] for model in result['data']
    #                                   if model['id'].startswith(('gpt-', 'text-', 'davinci'))]
                            return sorted(models)
    #                     else:
    #                         return ["gpt-3.5-turbo", "gpt-4", "gpt-4-turbo", "gpt-4o"]
    #         except Exception as e:
                print(f"Failed to fetch OpenAI models: {e}")
    #             return ["gpt-3.5-turbo", "gpt-4", "gpt-4-turbo", "gpt-4o"]

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

    #     async def get_available_models(self, api_key=None):
    #         """Get available models from OpenRouter API."""
    #         if not api_key:
    #             return ["openai/gpt-3.5-turbo", "openai/gpt-4", "openai/gpt-4-turbo", "anthropic/claude-3-opus"]

    headers = {
    #             "Authorization": f"Bearer {api_key}",
    #             "Content-Type": "application/json"
    #         }

    #         try:
    #             async with aiohttp.ClientSession() as session:
    #                 async with session.get(f"https://openrouter.ai/api/v1/models", headers=headers) as response:
    #                     if response.status == 200:
    result = await response.json()
    #                         models = [model['id'] for model in result['data']]
                            return sorted(models)
    #                     else:
    #                         return ["openai/gpt-3.5-turbo", "openai/gpt-4", "openai/gpt-4-turbo", "anthropic/claude-3-opus"]
    #         except Exception as e:
                print(f"Failed to fetch OpenRouter models: {e}")
    #             return ["openai/gpt-3.5-turbo", "openai/gpt-4", "openai/gpt-4-turbo", "anthropic/claude-3-opus"]

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

    #     async def get_available_models(self, api_key=None):
    #         """Get available models from LM Studio."""
    #         try:
    #             async with aiohttp.ClientSession() as session:
    #                 async with session.get(f"{self.base_url}/models") as response:
    #                     if response.status == 200:
    result = await response.json()
    #                         models = [model['id'] for model in result.get('data', [])]
    #                         return models if models else ["local-model"]
    #                     else:
    #                         return ["local-model"]
    #         except Exception as e:
                print(f"Failed to fetch LM Studio models: {e}")
    #             return ["local-model"]

class AIRole
    #     """AI role configuration for advanced interactions."""
    #     def __init__(self, name, description, system_prompt, capabilities):
    self.name = name
    self.description = description
    self.system_prompt = system_prompt
    self.capabilities = capabilities

# Ensure repository root on sys.path for imports when launched directly
CURRENT_DIR = Path(__file__).parent
REPO_ROOT = math.subtract(CURRENT_DIR.parent.parent.parent  # .../noodle, core)
SRC_DIR = REPO_ROOT / "src"

for p in (str(REPO_ROOT), str(SRC_DIR), str(CURRENT_DIR))
    #     if p not in sys.path:
            sys.path.insert(0, p)

# Optional NoodleCore integrations
try
    #     from noodlecore.ide_noodle.runtime import NoodleCommandRuntime
    NOODLE_RUNTIME_AVAILABLE = True
        print("NoodleCore Command Runtime loaded successfully")
except Exception as e
    NOODLE_RUNTIME_AVAILABLE = False
    NoodleCommandRuntime = None  # type: ignore
        print(f"NoodleCore Command Runtime not available: {e}")

try
    #     from noodlecore.ide_noodle.git_tools import NoodleCoreGitTools
    NOODLE_GIT_TOOLS_AVAILABLE = True
        print("NoodleCore Git tools loaded successfully")
except Exception as e
    NOODLE_GIT_TOOLS_AVAILABLE = False
    NoodleCoreGitTools = None  # type: ignore
        print(f"NoodleCore Git tools not available: {e}")

try
    #     from noodlecore.ide_noodle.quality import NoodleCoreQualityTools
    NOODLE_QUALITY_TOOLS_AVAILABLE = True
        print("NoodleCore Quality tools loaded successfully")
except Exception as e
    NOODLE_QUALITY_TOOLS_AVAILABLE = False
    NoodleCoreQualityTools = None  # type: ignore
        print(f"NoodleCore Quality tools not available: {e}")


class NativeNoodleCoreIDE
    #     """
    #     Enhanced NoodleCore GUI IDE with AI integration and advanced features.

    #     Goals:
    #     - Stable, resizable Tkinter-based layout
    #     - File explorer, multi-tab code editor, advanced terminal
    #     - AI integration with multiple providers and role management
    #     - Git integration and progress tracking
    #     - Python to NoodleCore conversion
    #     - Auto-complete functionality
    #     """

    #     def __init__(self) -> None:
    #         # Root window
    self.root = tk.Tk()
            self.root.title("NoodleCore Native GUI IDE - Enhanced")
            self.root.geometry("1400x900")
    self.root.configure(bg = "#2b2b2b")
            self.root.resizable(True, True)
            self.root.minsize(800, 600)

    #         # State
    self.current_project_path: Path = Path("C:/Users/micha/Noodle")
    self.file_tree_paths: dict = {}
    self.open_files: dict = {}
    self.unsaved_changes: dict = {}
    self.current_file: str | None = None
    self.code_errors = []

    #         # Initialize project index for AI context
    self.project_index = {}

    self.workspace_state = {
    #             "recent_files": [],
    #             "project_history": [],
    #             "search_history": [],
    #             "active_tab": 0,
    #         }

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

    #         # Load AI configuration from file
            self.load_ai_config()

    #         # AI roles - integrate with role manager for centralized management
    #         try:
    #             from noodlecore.ai.role_manager import get_role_manager
    self.role_manager = get_role_manager(str(self.current_project_path))

    #             # Try to get Manager AI role as default
    manager_role = self.role_manager.get_role_by_name("NoodleCore Manager")
    #             if manager_role:
    #                 # Create AIRole object from manager role
    #                 from noodlecore.ai.role_manager import AIRole
    manager_ai_role = AIRole(
    name = manager_role.name,
    description = manager_role.description,
    system_prompt = manager_role.document_path,  # Will be read from file
    capabilities = manager_role.tags
    #                 )
    self.current_ai_role = manager_ai_role
    #             else:
    #                 # Fallback to legacy roles if manager not found
    self.ai_roles = self.load_ai_roles()
    #                 self.current_ai_role = self.ai_roles[0] if self.ai_roles else None
    #         except Exception as e:
                print(f"Failed to initialize role manager: {e}")
    #             # Fallback to legacy roles
    self.ai_roles = self.load_ai_roles()
    #             self.current_ai_role = self.ai_roles[0] if self.ai_roles else None

    #         # AI Chat interface elements
    self.ai_chat = None
    self.ai_input = None
    self.ai_output = None

    #         # File tracking
    self.tab_text_widgets = []

    #         # Optional integrations
    self.noodle_runtime = None
    self.noodle_git_tools = None
    self.noodle_quality_tools = None

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

    #         # Initialize Self-Improvement Integration if available
    #         try:
    #             from .self_improvement_integration import SelfImprovementIntegration
    self.self_improvement_integration = SelfImprovementIntegration(self)
                print("Self-Improvement Integration initialized successfully")
    #         except Exception as e:
                print(f"Failed to initialize Self-Improvement Integration: {e}")
    self.self_improvement_integration = None

            self._init_integrations()
            self.load_ai_config()

            # Initialize AERE (AI Error Resolution Engine) integration
            self._init_aere_integration()

    #         # Build UI
            self._create_menu_bar()
            self._create_toolbar()
            self._create_layout()
            self._create_status_bar()

    #         # Initialize content
            self._populate_file_tree()
            self._create_welcome_tab()

    #     # ---------------------------
    #     # Initialization helpers
    #     # ---------------------------

    #     def _init_integrations(self) -> None:
    #         # Noodle runtime
    #         if NOODLE_RUNTIME_AVAILABLE and NoodleCommandRuntime:
    #             try:
    self.noodle_runtime = NoodleCommandRuntime()
                    self.noodle_runtime.load_specs()
                    print("NoodleCore Command Runtime initialized")
    #             except Exception as e:
                    print(f"Failed to initialize NoodleCore Command Runtime: {e}")
    self.noodle_runtime = None

    #         # Git tools
    #         if NOODLE_GIT_TOOLS_AVAILABLE and NoodleCoreGitTools:
    #             try:
    self.noodle_git_tools = NoodleCoreGitTools({})
                    print("NoodleCore Git tools initialized")
    #             except Exception as e:
                    print(f"Failed to initialize NoodleCore Git tools: {e}")
    self.noodle_git_tools = None

    #         # Quality tools
    #         if NOODLE_QUALITY_TOOLS_AVAILABLE and NoodleCoreQualityTools:
    #             try:
    self.noodle_quality_tools = NoodleCoreQualityTools({})
                    print("NoodleCore Quality tools initialized")
    #             except Exception as e:
                    print(f"Failed to initialize NoodleCore Quality tools: {e}")
    self.noodle_quality_tools = None

    #     # ---------------------------
    #     # UI construction
    #     # ---------------------------

    #     def _create_menu_bar(self) -> None:
    menubar = tk.Menu(self.root)
    self.root.config(menu = menubar)

    #         # File menu
    file_menu = tk.Menu(menubar, tearoff=0, bg="#2b2b2b", fg="white")
    file_menu.add_command(label = "New File", command=self.new_file)
    file_menu.add_command(label = "Open File", command=self.open_file)
    file_menu.add_command(label = "Save", command=self.save_file)
    file_menu.add_command(label = "Save As", command=self.save_file_as)
            file_menu.add_separator()
    file_menu.add_command(label = "Exit", command=self._on_exit)
    menubar.add_cascade(label = "File", menu=file_menu)

    #         # Run menu
    run_menu = tk.Menu(menubar, tearoff=0, bg="#2b2b2b", fg="white")
    run_menu.add_command(label = "Run Current File", command=self.run_current_file)
    menubar.add_cascade(label = "Run", menu=run_menu)

            # AI menu (Enhanced)
    ai_menu = tk.Menu(menubar, tearoff=0, bg="#2b2b2b", fg="white")
    ai_menu.add_command(label = "AI Settings", command=self.show_ai_settings)
            ai_menu.add_separator()
    ai_menu.add_command(label = "AI Role Selector", command=self.show_enhanced_ai_role_selector)
    ai_menu.add_command(label = "Add New AI Role", command=self.add_new_ai_role)
    ai_menu.add_command(label = "Edit AI Roles", command=self.edit_ai_roles)
            ai_menu.add_separator()
    ai_menu.add_command(label = "Convert Python to NoodleCore", command=self.convert_python_to_nc)
    ai_menu.add_command(label = "Auto-fix Code Errors", command=self.auto_fix_code_errors)
    ai_menu.add_command(label = "Code Review", command=self.ai_code_review)
    ai_menu.add_command(label = "Explain Code", command=self.ai_explain_code)
    ai_menu.add_command(label = "AI Chat", command=self.show_ai_chat)
    menubar.add_cascade(label = "AI", menu=ai_menu)

    #         # Git menu
    git_menu = tk.Menu(menubar, tearoff=0, bg="#2b2b2b", fg="white")
    git_menu.add_command(label = "Git Status", command=self.show_git_status)
    git_menu.add_command(label = "Git Commits", command=self.show_git_commits)
    git_menu.add_command(label = "Git Diff", command=self.show_git_diff)
            git_menu.add_separator()
    git_menu.add_command(label = "Project Health Check", command=self.project_health_check_workflow)
    menubar.add_cascade(label = "Git", menu=git_menu)

    #         # View menu
    view_menu = tk.Menu(menubar, tearoff=0, bg="#2b2b2b", fg="white")
    #         view_menu.add_command(label="Refresh File Tree", command=self.refresh_file_tree if hasattr(self, 'refresh_file_tree') else lambda: None)
            view_menu.add_separator()
    view_menu.add_command(label = "Toggle File Explorer", command=lambda: self.toggle_panel('file_explorer'))
    view_menu.add_command(label = "Toggle Terminal", command=lambda: self.toggle_panel('terminal'))
    view_menu.add_command(label = "Toggle AI Chat", command=lambda: self.toggle_panel('ai_chat'))
    menubar.add_cascade(label = "View", menu=view_menu)

            # Progress menu (NEW)
    #         if PROGRESS_MANAGER_AVAILABLE:
    progress_menu = tk.Menu(menubar, tearoff=0, bg="#2b2b2b", fg="white")
    progress_menu.add_command(label = "Progress Manager & Analytics", command=self.show_progress_manager)
    progress_menu.add_command(label = "Export Progress Report", command=self.export_progress_report)
                progress_menu.add_separator()
    progress_menu.add_command(label = "Start Monitoring", command=self.start_progress_monitoring)
    progress_menu.add_command(label = "Stop Monitoring", command=self.stop_progress_monitoring)
    menubar.add_cascade(label = "Progress", menu=progress_menu)

            # Self-Improvement menu (NEW)
    self_improvement_menu = tk.Menu(menubar, tearoff=0, bg="#2b2b2b", fg="white")
    self_improvement_menu.add_command(label = "Self-Improvement Panel", command=self.show_self_improvement_panel)
    self_improvement_menu.add_command(label = "Start Self-Improvement", command=self.start_self_improvement)
    self_improvement_menu.add_command(label = "Stop Self-Improvement", command=self.stop_self_improvement)
            self_improvement_menu.add_separator()
    self_improvement_menu.add_command(label = "Self-Improvement Settings", command=self.show_self_improvement_settings)
    menubar.add_cascade(label = "Self-Improvement", menu=self_improvement_menu)

    #         # Help menu
    help_menu = tk.Menu(menubar, tearoff=0, bg="#2b2b2b", fg="white")
    help_menu.add_command(label = "About", command=self.show_about)
    menubar.add_cascade(label = "Help", menu=help_menu)

    #     def _create_toolbar(self) -> None:
    toolbar = tk.Frame(self.root, bg="#3c3c3c", height=40)
    toolbar.pack(side = "top", fill="x")

    #         def add_btn(text, cmd, bg_color="#4a4a4a"):
    b = tk.Button(
    #                 toolbar,
    text = text,
    command = cmd,
    bg = bg_color,
    fg = "white",
    relief = "flat",
    padx = 8,
    pady = 4,
    #             )
    b.pack(side = "left", padx=2, pady=2)

    #         # File operations
            add_btn("New", self.new_file, "#4CAF50")
            add_btn("Open", self.open_file, "#2196F3")
            add_btn("Save", self.save_file, "#FF9800")

    toolbar.separator = tk.Frame(toolbar, width=2, bg='gray')
    toolbar.separator.pack(side = 'left', padx=10, fill='y', pady=2)

    #         # AI operations
            add_btn("AI Chat", self.show_ai_chat, "#9C27B0")
            add_btn("Code Review", self.ai_code_review, "#00BCD4")
            add_btn("Convert Py→NC", self.convert_python_to_nc, "#00BCD4")

    toolbar.separator2 = tk.Frame(toolbar, width=2, bg='gray')
    toolbar.separator2.pack(side = 'left', padx=10, fill='y', pady=2)

    #         # Git operations
            add_btn("Git Status", self.show_git_status, "#FF5722")
            add_btn("Health Check", self.project_health_check_workflow, "#FF5722")

    toolbar.separator3 = tk.Frame(toolbar, width=2, bg='gray')
    toolbar.separator3.pack(side = 'left', padx=10, fill='y', pady=2)

    #         # Progress operations
    #         if PROGRESS_MANAGER_AVAILABLE:
                add_btn("Progress", self.show_progress_manager, "#673AB7")

    #         # Self-Improvement operations
            add_btn("Self-Improve", self.show_self_improvement_panel, "#E91E63")

    #     def _create_layout(self) -> None:
    #         # Use enhanced layout with AI chat panel
            self._create_enhanced_layout()

    #     def _create_status_bar(self) -> None:
    self.status_bar = tk.Label(
    #             self.root,
    text = "Ready",
    anchor = "w",
    bg = "#333333",
    fg = "white",
    #         )
    self.status_bar.pack(side = "bottom", fill="x")

    #     def _create_welcome_tab(self) -> None:
    frame = tk.Frame(self.notebook, bg="#1e1e1e")
    text = scrolledtext.ScrolledText(
    #             frame,
    wrap = tk.WORD,
    bg = "#1e1e1e",
    fg = "#ffffff",
    insertbackground = "white",
    #         )
    text.pack(fill = "both", expand=True, padx=4, pady=4)

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
# - **Context-aware AI Chat** with file analysis

### 💻 **Working Terminal**
# - Built-in command execution
- File execution (Python, JavaScript, HTML)
# - Git integration in terminal

### 🗂️ **Git Integration**
# - Git status, commits, diff, history
# - Git operations from menu and toolbar
# - Project health check workflow

### 🔧 **Resizable Windows**
# - Professional IDE layout with draggable panel borders
# - Multiple resizable panels
# - Enhanced workspace management

### 🆕 **NEW AI FEATURES:**
- **Convert Python to NoodleCore** (AI menu → "Convert Python to NoodleCore")
- **Auto-fix Code Errors** (AI menu → "Auto-fix Code Errors")
- **AI Role Selection** (AI menu → "AI Role Selector")
# - **Enhanced Code Review** with AI
# - **Real-time Code Review** and explanations
# - **Real AI Integration** with OpenAI and OpenRouter APIs

## 🛠️ **How to Use:**

# 1. **File Operations**: File menu or double-click in explorer
2. **Run Code**: Run menu or toolbar button (F5)
3. **AI Features**: AI menu (new conversion, analysis, and auto-fix tools)
# 4. **Real AI**: Configure in AI Settings, then use conversion/analysis features
# 5. **Git Operations**: Git menu for version control
# 6. **Resize Windows**: Drag panel borders to resize

# Ready to code with **real AI assistance**? **Create a new file and start!** 🎉"""

        text.insert("1.0", welcome_text)
text.config(state = "disabled")
self.notebook.add(frame, text = "Welcome")

#     def _get_current_text_widget(self):
#         """Get the currently active text widget with enhanced support."""
#         try:
tab_id = self.notebook.select()
#         except Exception:
#             return None
info = self.open_files.get(tab_id)
#         if not info:
#             return None
        return info.get("text")

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

tk.Label(find_frame, text = "Find:", bg='#2b2b2b', fg='white').pack(anchor='w')
find_entry = tk.Entry(find_frame, bg='#1e1e1e', fg='white')
find_entry.pack(fill = 'x', padx=5, pady=5)

#         # Replace frame
replace_frame = tk.Frame(dialog, bg='#2b2b2b')
replace_frame.pack(fill = 'x', padx=10, pady=5)

tk.Label(replace_frame, text = "Replace:", bg='#2b2b2b', fg='white').pack(anchor='w')
replace_entry = tk.Entry(replace_frame, bg='#1e1e1e', fg='white')
replace_entry.pack(fill = 'x', padx=5, pady=5)

#         # Buttons
button_frame = tk.Frame(dialog, bg='#2b2b2b')
button_frame.pack(fill = 'x', padx=10, pady=10)

tk.Button(button_frame, text = "Find Next", bg='#2196F3', fg='white').pack(side='left', padx=5)
tk.Button(button_frame, text = "Replace", bg='#FF9800', fg='white').pack(side='left', padx=5)
tk.Button(button_frame, text = "Replace All", bg='#4CAF50', fg='white').pack(side='left', padx=5)
tk.Button(button_frame, text = "Close", command=dialog.destroy, bg='#f44336', fg='white').pack(side='right', padx=5)

#     # ---------------------------
#     # File explorer
#     # ---------------------------

#     def _populate_file_tree(self) -> None:
        self.file_tree.delete(*self.file_tree.get_children())
root_id = self.file_tree.insert("", "end", text=str(self.current_project_path))
self.file_tree_paths[root_id] = self.current_project_path
        self._add_directory_children(root_id, self.current_project_path)

#     def _add_directory_children(self, parent_id, directory: Path) -> None:
#         try:
items = sorted(directory.iterdir(), key=lambda p: (not p.is_dir(), p.name.lower()))
#         except Exception:
#             return

#         for item in items:
#             try:
#                 if item.is_dir():
node_id = self.file_tree.insert(parent_id, "end", text=f"[D] {item.name}")
self.file_tree_paths[node_id] = item
#                 else:
node_id = self.file_tree.insert(parent_id, "end", text=item.name)
self.file_tree_paths[node_id] = item
#             except Exception:
#                 continue

#     def _on_tree_expand(self, event) -> None:
item_id = self.file_tree.focus()
path = self.file_tree_paths.get(item_id)
#         if not isinstance(path, Path) or not path.is_dir():
#             return
#         # Clear and repopulate
        self.file_tree.delete(*self.file_tree.get_children(item_id))
        self._add_directory_children(item_id, path)

#     def _on_tree_double_click(self, event) -> None:
item_id = self.file_tree.focus()
path = self.file_tree_paths.get(item_id)
#         if isinstance(path, Path) and path.is_file():
            self._open_file_in_tab(str(path))

#     # ---------------------------
#     # Editor operations
#     # ---------------------------

#     def new_file(self) -> None:
frame = tk.Frame(self.notebook, bg="#1e1e1e")
text = self._create_text_widget(frame)
self.notebook.add(frame, text = "Untitled")
        self.notebook.select(frame)
self.open_files[id(frame)] = {"path": None, "text": text}
self.status_bar.config(text = "New file created")

#     def open_file(self) -> None:
file_path = filedialog.askopenfilename()
#         if file_path:
            self._open_file_in_tab(file_path)

#     def _open_file_in_explorer(self, file_path: str) -> None:
#         # Reuse existing tab if open
#         for tab_id in self.notebook.tabs():
info = self.open_files.get(tab_id)
#             if info and info.get("path") == file_path:
                self.notebook.select(tab_id)
self.current_file = file_path
                self._update_status_bar()
#                 return

frame = tk.Frame(self.notebook, bg="#1e1e1e")
text = self._create_text_widget(frame)

#         try:
#             with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
content = f.read()
            text.insert("1.0", content)
#         except Exception as e:
            messagebox.showerror("Error", f"Failed to open file: {e}")
#             return

tab_text = Path(file_path).name
self.notebook.add(frame, text = tab_text)
        self.notebook.select(frame)

tab_id = math.subtract(self.notebook.tabs()[, 1])
self.open_files[tab_id] = {"path": file_path, "text": text}
self.unsaved_changes[file_path] = False
self.current_file = file_path
        self._update_status_bar()

#     def _create_text_widget(self, parent) -> scrolledtext.ScrolledText:
text = scrolledtext.ScrolledText(
#             parent,
wrap = tk.NONE,
bg = "#1e1e1e",
fg = "#ffffff",
insertbackground = "white",
undo = True,
#         )
text.pack(fill = "both", expand=True, padx=4, pady=4)
        text.bind("<<Modified>>", self._on_text_modified)
#         return text

#     def _get_current_text_widget(self):
#         try:
tab_id = self.notebook.select()
#         except Exception:
#             return None
info = self.open_files.get(tab_id)
#         if not info:
#             return None
        return info.get("text")

#     def _on_text_modified(self, event) -> None:
widget = event.widget
        widget.edit_modified(False)
#         for tab_id, info in self.open_files.items():
#             if info.get("text") is widget:
path = info.get("path")
#                 if path:
self.unsaved_changes[path] = True
name = Path(path).name + "*"
self.notebook.tab(tab_id, text = name)
        self._update_status_bar()

#     def save_file(self) -> None:
text = self._get_current_text_widget()
#         if not text:
#             return
tab_id = self.notebook.select()
info = self.open_files.get(tab_id)
#         if not info:
#             return

path = info.get("path")
#         if not path:
            self.save_file_as()
#             return

#         try:
content = text.get("1.0", "end-1c")
#             with open(path, "w", encoding="utf-8") as f:
                f.write(content)
self.unsaved_changes[path] = False
self.notebook.tab(tab_id, text = Path(path).name)
self.status_bar.config(text = f"Saved: {path}")
#         except Exception as e:
            messagebox.showerror("Error", f"Failed to save: {e}")

#     def save_file_as(self) -> None:
text = self._get_current_text_widget()
#         if not text:
#             return
file_path = filedialog.asksaveasfilename()
#         if not file_path:
#             return

#         try:
content = text.get("1.0", "end-1c")
#             with open(file_path, "w", encoding="utf-8") as f:
                f.write(content)
tab_id = self.notebook.select()
self.open_files[tab_id]["path"] = file_path
self.unsaved_changes[file_path] = False
self.notebook.tab(tab_id, text = Path(file_path).name)
self.current_file = file_path
self.status_bar.config(text = f"Saved As: {file_path}")
#         except Exception as e:
            messagebox.showerror("Error", f"Failed to save as: {e}")

#     # ---------------------------
#     # Terminal / Run
#     # ---------------------------

#     def _on_terminal_enter(self, event) -> None:
command = self.terminal_input.get().strip()
        self.terminal_input.delete(0, "end")
#         if not command:
#             return

#         def worker():
#             try:
result = subprocess.run(
#                     command,
shell = True,
capture_output = True,
text = True,
cwd = str(self.current_project_path),
#                 )
out = result.stdout or ""
err = result.stderr or ""
#             except Exception as e:
out = ""
err = str(e)

            self._append_terminal_output(f"$ {command}\n")
#             if out:
                self._append_terminal_output(out)
#             if err:
                self._append_terminal_output(err)

threading.Thread(target = worker, daemon=True).start()

#     def _append_terminal_output(self, text: str) -> None:
self.terminal_output.config(state = "normal")
        self.terminal_output.insert("end", text)
        self.terminal_output.see("end")
self.terminal_output.config(state = "disabled")

#     def run_current_file(self) -> None:
#         if not self.current_file:
            messagebox.showinfo("Run", "No active file to run")
#             return

path = self.current_file

#         def worker():
#             try:
result = subprocess.run(
#                     [sys.executable, path],
capture_output = True,
text = True,
cwd = str(Path(path).parent),
#                 )
out = result.stdout or ""
err = result.stderr or ""
#             except Exception as e:
out = ""
err = str(e)

            self._append_terminal_output(f"\n[Run] {path}\n")
#             if out:
                self._append_terminal_output(out)
#             if err:
                self._append_terminal_output(err)

threading.Thread(target = worker, daemon=True).start()

#     # ---------------------------
#     # Misc / UX
#     # ---------------------------

#     def _update_status_bar(self) -> None:
#         if self.current_file:
self.status_bar.config(text = f"Editing: {self.current_file}")
#         else:
self.status_bar.config(text = "Ready")

#     def show_about(self) -> None:
msg = (
#             "NoodleCore Native GUI IDE\n"
#             "Canonical, stable implementation.\n"
#             "Uses launch_native_ide.py as entrypoint."
#         )
        messagebox.showinfo("About NoodleCore IDE", msg)

#     # ---------------------------
#     # AI Role Management
#     # ---------------------------

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

#     def show_enhanced_ai_role_selector(self):
#         """Show enhanced AI role selector with descriptions and capabilities."""
#         if not self.ai_roles:
self.ai_roles = self.load_ai_roles()

#         # Ensure Manager AI is first in the list if available
#         if self.ai_roles:
#             manager_role = next((r for r in self.ai_roles if r.name == "NoodleCore Manager"), None)
#             if manager_role:
                self.ai_roles.remove(manager_role)
                self.ai_roles.insert(0, manager_role)

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
current_role_label.pack(anchor = 'w', padx=10, pady=(0, 10))

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

#             # Special styling for Manager role
#             if role.name == "NoodleCore Manager":
#                 role_name.config(fg='#FFD700', font=('Arial', 12, 'bold'))  # Gold color for Manager
#                 role_card.config(bg='#2E2E2E', relief='raised', bd=2)  # Special background for Manager

#             # Select button
select_btn = tk.Button(
#                 header_frame,
#                 text="Select" if (self.current_ai_role != role) else "Selected",
command = lambda r=role: self.select_ai_role(r, current_role_label, top),
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
cap_frame.pack(fill = 'x', padx=10, pady=(0, 5))

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
cap_label.pack(anchor = 'w', padx=10, pady=(0, 10))

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
pady = 10
#         )
close_btn.pack(pady = 10)

#     def select_ai_role(self, role, current_role_label, dialog):
#         """Select an AI role."""
self.current_ai_role = role
current_role_label.config(text = role.name)
self.status_bar.config(text = f"AI role changed to: {role.name}")

#         # Update AI role indicator in the interface
#         if hasattr(self, 'ai_role_label'):
self.ai_role_label.config(text = f"Role: {role.name}")

#         # Refresh dialog to update button states
        self.show_enhanced_ai_role_selector()  # Refresh dialog
#         # Close the old dialog
#         for widget in dialog.winfo_children():
#             if isinstance(widget, tk.Toplevel) and widget.title() == "AI Role Selection":
                widget.destroy()

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
name_entry = tk.Entry(form_frame, font=('Arial', 10), bg='#1e1e1e', fg='white')
name_entry.pack(fill = 'x', pady=(0, 10))

#         # Description
tk.Label(form_frame, text = "Description:", bg='#2b2b2b', fg='white').pack(anchor='w')
desc_text = scrolledtext.ScrolledText(form_frame, height=3, font=('Arial', 10), bg='#1e1e1e', fg='white')
desc_text.pack(fill = 'x', pady=(0, 10))

#         # System prompt
tk.Label(form_frame, text = "System Prompt:", bg='#2b2b2b', fg='white').pack(anchor='w')
prompt_text = scrolledtext.ScrolledText(form_frame, height=5, font=('Arial', 10), bg='#1e1e1e', fg='white')
prompt_text.pack(fill = 'x', pady=(0, 10))

#         # Capabilities
tk.Label(form_frame, text = "Capabilities (comma-separated):", bg='#2b2b2b', fg='white').pack(anchor='w')
cap_entry = tk.Entry(form_frame, font=('Arial', 10), bg='#1e1e1e', fg='white')
cap_entry.pack(fill = 'x', pady=(0, 10))

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
new_role = AIRole(name, description, system_prompt, capabilities)
            self.ai_roles.append(new_role)
self.current_ai_role = math.subtract(new_role  # Auto, select new role)

#             # Save to config
            self.save_ai_roles()

            messagebox.showinfo("Success", f"AI role '{name}' added and selected!")
self.status_bar.config(text = f"New AI role added: {name}")
            top.destroy()

tk.Button(top, text = "Save Role", command=save_role, bg='#4CAF50', fg='white').pack(pady=20)

#     def edit_ai_roles(self):
#         """Edit existing AI roles."""
        messagebox.showinfo("Edit AI Roles", "Use 'Add New AI Role' to create or modify roles through AI interface.")

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

#     # ---------------------------
#     # AI Integration Methods
#     # ---------------------------

#     def parse_ai_command(self, message):
#         """Parse AI commands for file operations."""
#         import re

#         # File read commands
read_patterns = [
            r'lees\s+(?:bestand\s+)?["\']?([^"\']+)["\']?',
            r'open\s+(?:bestand\s+)?["\']?([^"\']+)["\']?',
            r'read\s+(?:file\s+)?["\']?([^"\']+)["\']?',
            r'toon\s+(?:bestand\s+)?["\']?([^"\']+)["\']?'
#         ]

#         # File write commands
write_patterns = [
            r'schrijf\s+(?:naar\s+)?["\']?([^"\']+)["\']?\s*:\s*(.+)',
            r'write\s+(?:to\s+)?["\']?([^"\']+)["\']?\s*:\s*(.+)',
            'save\\s+(?:as\\s+)?["\']?([^"\']+)["\']?\\s*:\\s*(.+)',
            'bewaar\\s+(?:als\\s+)?["\']?([^"\']+)["\']?\\s*:\\s*(.+)'
#         ]

#         # File modify commands
modify_patterns = [
            r'pas\s+(?:bestand\s+)?["\']?([^"\']+)["\']?\s+(?:aan|bij)\s*:\s*(.+)',
            r'modify\s+(?:file\s+)?["\']?([^"\']+)["\']?\s*:\s*(.+)',
            r'wijzig\s+(?:bestand\s+)?["\']?([^"\']+)["\']?\s*:\s*(.+)'
#         ]

#         # Project analysis commands
analysis_patterns = [
            r'analyseer\s+(?:project\s+)?["\']?([^"\']*)["\']?',
            r'index\s+(?:project\s+)?["\']?([^"\']*)["\']?',
            r'overzicht\s+(?:project\s+)?["\']?([^"\']*)["\']?',
            r'scan\s+(?:project\s+)?["\']?([^"\']*)["\']?'
#         ]

#         # Check read commands
#         for pattern in read_patterns:
match = re.search(pattern, message, re.IGNORECASE)
#             if match:
                return {'type': 'read', 'file': match.group(1).strip()}

#         # Check write commands
#         for pattern in write_patterns:
match = re.search(pattern, message, re.IGNORECASE | re.DOTALL)
#             if match:
                return {'type': 'write', 'file': match.group(1).strip(), 'content': match.group(2).strip()}

#         # Check modify commands
#         for pattern in modify_patterns:
match = re.search(pattern, message, re.IGNORECASE | re.DOTALL)
#             if match:
                return {'type': 'modify', 'file': match.group(1).strip(), 'content': match.group(2).strip()}

#         # Check analysis commands
#         for pattern in analysis_patterns:
match = re.search(pattern, message, re.IGNORECASE)
#             if match:
#                 return {'type': 'analyze', 'path': match.group(1).strip() if match.group(1) else '.'}

#         return None

#     def execute_ai_file_command(self, command):
#         """Execute AI file operations."""
#         try:
#             if command['type'] == 'read':
                return self.ai_read_file(command['file'])
#             elif command['type'] == 'write':
                return self.ai_write_file(command['file'], command['content'])
#             elif command['type'] == 'modify':
                return self.ai_modify_file(command['file'], command['content'])
#             elif command['type'] == 'analyze':
                return self.ai_analyze_project(command['path'])
#         except Exception as e:
            return f"❌ Bestandsoperatie mislukt: {str(e)}"

#     def ai_read_file(self, file_path):
#         """AI file read operation."""
#         try:
#             # Resolve relative paths
#             if not os.path.isabs(file_path):
file_path = os.path.join(self.current_project_path, file_path)

#             if not os.path.exists(file_path):
#                 return f"❌ Bestand niet gevonden: {file_path}"

#             with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
content = f.read()

#             # Open file in IDE if not already open
            self._open_file_in_tab(file_path)

#             # Also open in file explorer
            self._open_file_in_explorer(file_path)

#             return f"✅ Bestand gelezen: {file_path}\n\n```\n{content[:1000]}{'...' if len(content) > 1000 else ''}\n```"

#         except Exception as e:
            return f"❌ Fout bij lezen bestand: {str(e)}"

#     def ai_write_file(self, file_path, content):
#         """AI file write operation."""
#         try:
#             # Resolve relative paths
#             if not os.path.isabs(file_path):
file_path = os.path.join(self.current_project_path, file_path)

#             # Create directories if they don't exist
os.makedirs(os.path.dirname(file_path), exist_ok = True)

#             with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)

#             # Open file in IDE
            self._open_file_in_tab(file_path)

#             return f"✅ Bestand geschreven: {file_path}"

#         except Exception as e:
            return f"❌ Fout bij schrijven bestand: {str(e)}"

#     def ai_modify_file(self, file_path, modifications):
#         """AI file modify operation."""
#         try:
#             # Resolve relative paths
#             if not os.path.isabs(file_path):
file_path = os.path.join(self.current_project_path, file_path)

#             if not os.path.exists(file_path):
                return self.ai_write_file(file_path, modifications)

#             # Open file in IDE first
            self._open_file_in_tab(file_path)

#             # Find the text widget for this file
text_widget = None
#             for tab_id, info in self.open_files.items():
#                 if info.get("path") == file_path:
text_widget = info.get("text")
#                     break

#             if text_widget:
#                 # Replace entire content
                text_widget.delete('1.0', 'end')
                text_widget.insert('1.0', modifications)

#                 # Mark as unsaved
self.unsaved_changes[file_path] = True
tab_id = self.notebook.select()
self.notebook.tab(tab_id, text = Path(file_path).name + "*")

#                 return f"✅ Bestand gewijzigd: {file_path}"
#             else:
#                 return f"❌ Kon bestand niet openen in editor: {file_path}"

#         except Exception as e:
            return f"❌ Fout bij wijzigen bestand: {str(e)}"

#     def ai_analyze_project(self, path):
#         """AI project analysis using NoodleCore indexing when available."""
#         try:
#             # Resolve relative paths
#             if not os.path.isabs(path):
path = os.path.join(self.current_project_path, path)

#             if not os.path.exists(path):
#                 return f"❌ Pad niet gevonden: {path}"

#             # Try to use NoodleCore indexing if available
#             if NOODLE_RUNTIME_AVAILABLE and self.noodle_runtime:
#                 try:
#                     # Use NoodleCore to analyze the project
analysis_result = self.noodle_runtime.analyze_project(path)

result = f"✅ Projectanalyse met NoodleCore: {path}\n\n"
result + = f"**Projectstructuur:**\n{analysis_result.get('structure', 'Niet beschikbaar')}\n\n"
result + = f"**Bestanden:** {analysis_result.get('file_count', 0)}\n"
result + = f"**Modules:** {analysis_result.get('module_count', 0)}\n"
result + = f"**Functies:** {analysis_result.get('function_count', 0)}\n\n"

#                     if analysis_result.get('dependencies'):
result + = f"**Afhankelijkheden:**\n{analysis_result['dependencies']}\n\n"

#                     if analysis_result.get('issues'):
result + = f"**Potentiële problemen:**\n{analysis_result['issues']}\n\n"

#                     return result
#                 except Exception as e:
                    print(f"NoodleCore analysis failed: {e}")
#                     # Fallback to basic analysis

#             # Fallback: Basic file system analysis
result = f"✅ Projectanalyse (basis): {path}\n\n"

#             # Count files by type
file_counts = {}
total_files = 0

#             for root, dirs, files in os.walk(path):
#                 # Skip hidden directories
#                 dirs[:] = [d for d in dirs if not d.startswith('.')]

#                 for file in files:
#                     if not file.startswith('.'):
ext = os.path.splitext(file)[1].lower()
file_counts[ext] = math.add(file_counts.get(ext, 0), 1)
total_files + = 1

result + = f"**Totaal bestanden:** {total_files}\n\n"
result + = "**Bestandstypen:**\n"
#             for ext, count in sorted(file_counts.items()):
#                 ext_name = ext if ext else "[geen extensie]"
result + = f"- {ext_name}: {count}\n"

#             # Look for important project files
important_files = []
#             for root, dirs, files in os.walk(path):
#                 for file in files:
#                     if file in ['README.md', 'requirements.txt', 'setup.py', 'pyproject.toml', '.gitignore']:
rel_path = os.path.relpath(os.path.join(root, file), path)
                        important_files.append(rel_path)

#             if important_files:
result + = f"\n**Belangrijke projectbestanden:**\n"
#                 for file in sorted(important_files):
result + = f"- {file}\n"

#             return result

#         except Exception as e:
            return f"❌ Fout bij analyseren project: {str(e)}"

#     async def send_real_ai_message(self, message):
#         """Send real AI message using configured provider."""
#         if not self.current_ai_provider or not self.current_ai_model:
            messagebox.showwarning("AI Not Configured", "Please configure AI provider and model first.")
#             return

#         # Check for AI file commands first
ai_command = self.parse_ai_command(message)
#         if ai_command:
result = self.execute_ai_file_command(ai_command)
self.ai_chat.config(state = 'normal')
            self.ai_chat.insert('end', f"👤 You: {message}\n")
            self.ai_chat.insert('end', f"🤖 AI: {result}\n\n")
self.ai_chat.config(state = 'disabled')
            self.ai_chat.see('end')

#             # Store file operation result in conversation history for context
#             if not hasattr(self, 'ai_conversation_history'):
self.ai_conversation_history = []

#             # Add the file operation to conversation history
            self.ai_conversation_history.append({
#                 "role": "assistant",
#                 "content": f"Bestandsoperatie uitgevoerd: {result}"
#             })

#             # Continue with AI processing instead of returning
message = f"Geef feedback op deze operatie en onthoud de inhoud voor vervolgvragen."

#             # Store file content in project index for AI context
            self._update_project_index(ai_command)

#             # Continue with normal AI processing for follow-up questions
#             def continue_ai_processing():
loop = asyncio.new_event_loop()
                asyncio.set_event_loop(loop)
#                 try:
                    loop.run_until_complete(self._process_normal_ai_message(message))
#                 finally:
                    loop.close()

#             # Start AI processing in background thread
threading.Thread(target = continue_ai_processing, daemon=True).start()
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

#             # Build enhanced system prompt with file operation capabilities
enhanced_system_prompt = """Je bent een AI assistent voor de NoodleCore IDE. Je kunt bestandsbewerkingen uitvoeren met de volgende commando's:

# Bestandsbewerkingen:
# - "lees [bestandsnaam]" - Lees een bestand
# - "schrijf [bestandsnaam]: [inhoud]" - Maak een nieuw bestand met inhoud
# - "pas [bestandsnaam] aan: [inhoud]" - Wijzig een bestaand bestand
# - "open [bestandsnaam]" - Open een bestand in de editor

# Voorbeeld:
# - "lees main.py"
- "schrijf test.py: print('hello world')"
# - "pas main.py aan: voeg een nieuwe functie toe"
# - "analyseer src/"
# - "index ."

# Toegestane mappen voor bestandsbewerkingen:
# - Standaard: huidige projectmap en submappen
# - Alle bestanden in projectmap kunnen gelezen worden
# - Gebruik absolute paden voor bestanden buiten project

# Beschikbare projectindex:
# - Je hebt toegang tot een geïndexeerde projectindex met bestandsinhoud
# - Gebruik "toon index" of "lijst bestanden" om de geïndexeerde bestanden te zien
# - De index wordt automatisch bijgewerkt bij bestandsbewerkingen

# Je kunt ook reguliere vragen stellen over code en programmering."""

#             # Build context-aware messages
messages = []
#             if self.current_ai_role:
#                 # Use Manager AI system prompt if available
system_prompt = self.current_ai_role.system_prompt
#                 if hasattr(self.current_ai_role, 'name') and self.current_ai_role.name == "NoodleCore Manager":
#                     # For Manager AI, read the actual system prompt from role document
#                     try:
#                         if hasattr(self, 'role_manager') and self.role_manager:
manager_role = self.role_manager.get_role_by_name("NoodleCore Manager")
#                             if manager_role:
system_prompt = self.role_manager.read_role_document(manager_role.id)
#                     except Exception as e:
                        print(f"Failed to read Manager AI prompt: {e}")

                messages.append({
#                     "role": "system",
#                     "content": f"{system_prompt}\n\n{enhanced_system_prompt}"
#                 })
#             else:
                messages.append({
#                     "role": "system",
#                     "content": enhanced_system_prompt
#                 })

#             # Add conversation history if available
#             if hasattr(self, 'ai_conversation_history') and self.ai_conversation_history:
                # Add recent conversation history (last 10 messages to avoid token limits)
recent_history = math.subtract(self.ai_conversation_history[, 10:])
                messages.extend(recent_history)

#             # Add file context if available
#             if self.current_file:
#                 try:
#                     # Find the text widget for the current file
text_widget = None
#                     for tab_id, info in self.open_files.items():
#                         if info.get("path") == self.current_file:
text_widget = info.get("text")
#                             break

#                     if text_widget:
content = text_widget.get('1.0', 'end-1c')
                        messages.append({
#                             "role": "user",
#                             "content": f"Huidig bestand: {self.current_file}\n```\n{content[:2000]}\n```"
#                         })
#                 except Exception as e:
                    print(f"Failed to add file context: {e}")

#             # Add project index context for AI
#             if hasattr(self, 'project_index') and self.project_index:
#                 try:
#                     # Create a summary of indexed files for context
index_summary = "Project index beschikbaar:\n"
#                     for file_path, file_info in list(self.project_index.items())[:10]:  # Limit to 10 most recent files
file_size = file_info.get('size', 0)
#                         if file_size > 0:
size_kb = math.divide(file_size, 1024)
size_str = f" ({size_kb:.1f} KB)"
#                         else:
size_str = ""

index_summary + = f"- {file_path}{size_str}\n"

                    messages.append({
#                         "role": "user",
#                         "content": index_summary
#                     })
#                 except Exception as e:
                    print(f"Failed to add project index context: {e}")

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

#             # Store AI response in conversation history
#             if not hasattr(self, 'ai_conversation_history'):
self.ai_conversation_history = []

            self.ai_conversation_history.append({
#                 "role": "assistant",
#                 "content": response
#             })

            # Keep history manageable (last 20 messages)
#             if len(self.ai_conversation_history) > 20:
self.ai_conversation_history = math.subtract(self.ai_conversation_history[, 20:])

#         except Exception as e:
self.ai_chat.config(state = 'normal')
            self.ai_chat.delete('end-2l', 'end-1l')
            self.ai_chat.insert('end', f"❌ AI Error: {str(e)}\n\n")
self.ai_chat.config(state = 'disabled')
            self.ai_chat.see('end')

#     def send_ai_message(self, event=None):
#         """Send AI message (wrapper for async call)."""
message = self.ai_input.get().strip()
#         if not message:
#             return

#         # Check if AI is configured
#         if not self.ai_api_key:
#             # Show error in chat instead of messagebox to avoid popup spam
self.ai_chat.config(state = 'normal')
            self.ai_chat.insert('end', f"👤 You: {message}\n")
#             self.ai_chat.insert('end', "❌ AI Error: Please configure AI Settings with an API key first.\n")
            self.ai_chat.insert('end', "   Go to AI menu → AI Settings to set up your AI provider.\n\n")
self.ai_chat.config(state = 'disabled')
            self.ai_chat.see('end')
            self.ai_input.delete(0, 'end')
#             return

#         # Add user message to chat
self.ai_chat.config(state = 'normal')
        self.ai_chat.insert('end', f"👤 You: {message}\n")
        self.ai_input.delete(0, 'end')
self.ai_chat.config(state = 'disabled')
        self.ai_chat.see('end')

#         # Store user message in conversation history
#         if not hasattr(self, 'ai_conversation_history'):
self.ai_conversation_history = []

        self.ai_conversation_history.append({
#             "role": "user",
#             "content": message
#         })

#         # Send to AI in background
#         def run_async():
loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
#             try:
                loop.run_until_complete(self.send_real_ai_message(message))
#             finally:
                loop.close()

threading.Thread(target = run_async, daemon=True).start()

#     def ai_code_review(self):
#         """AI code review for current file."""
#         if not self.current_file:
            messagebox.showwarning("No File", "No file is currently open")
#             return

#         # Check if AI is configured
#         if not self.ai_api_key:
#             messagebox.showwarning("AI Not Configured", "Please configure AI Settings with an API key first.\nGo to AI menu → AI Settings")
            self.show_ai_settings()
#             return

#         # Add review request to AI chat and send it
#         review_message = f"Please review the code in {self.current_file} and provide feedback on code quality, potential issues, and suggestions for improvement. Focus on:\n- Code style and best practices\n- Potential bugs or issues\n- Performance considerations\n- Security concerns\n- Suggestions for improvement"

#         # Add user message to chat
self.ai_chat.config(state = 'normal')
#         self.ai_chat.insert('end', f"👤 You: Code Review Request for {self.current_file}\n")
self.ai_chat.config(state = 'disabled')
        self.ai_chat.see('end')

#         # Send to AI in background
#         def run_async():
loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
#             try:
                loop.run_until_complete(self.send_real_ai_message(review_message))
#             finally:
                loop.close()

threading.Thread(target = run_async, daemon=True).start()

#     def ai_explain_code(self):
#         """AI explain code functionality."""
#         if not self.current_file:
            messagebox.showwarning("No File", "No file is currently open")
#             return

#         # Check if AI is configured
#         if not self.ai_api_key:
#             messagebox.showwarning("AI Not Configured", "Please configure AI Settings with an API key first.\nGo to AI menu → AI Settings")
            self.show_ai_settings()
#             return

#         # Add explanation request to AI chat and send it
explain_message = f"Please explain the code in {self.current_file} in detail, including:\n- What the code does\n- How it works\n- Key functions and their purpose\n- Important concepts and patterns used\n- Any potential improvements or alternatives"

#         # Add user message to chat
self.ai_chat.config(state = 'normal')
#         self.ai_chat.insert('end', f"👤 You: Code Explanation Request for {self.current_file}\n")
self.ai_chat.config(state = 'disabled')
        self.ai_chat.see('end')

#         # Send to AI in background
#         def run_async():
loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
#             try:
                loop.run_until_complete(self.send_real_ai_message(explain_message))
#             finally:
                loop.close()

threading.Thread(target = run_async, daemon=True).start()

#     async def convert_python_to_nc(self):
#         """Convert Python code to NoodleCore using AI."""
#         if not self.current_file or not self.current_file.endswith('.py'):
            messagebox.showwarning("Not Python", "Please open a Python file first")
#             return

#         try:
#             # Get current file content
text_widget = self.open_files.get(self.current_file)
#             if not text_widget:
                raise Exception("Could not get file content")

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
            self._open_file_in_tab(nc_file_path)
            messagebox.showinfo("Conversion Complete", f"Python code converted to NoodleCore and saved as:\n{nc_file_path}")

#         except Exception as e:
            messagebox.showerror("Conversion Error", f"Failed to convert Python to NoodleCore: {str(e)}")

#     def auto_fix_code_errors(self):
#         """Automatically fix code errors using AI."""
#         if not self.current_file:
            messagebox.showwarning("No File", "No file is currently open")
#             return

#         # Check if AI is configured
#         if not self.ai_api_key:
#             messagebox.showwarning("AI Not Configured", "Please configure AI Settings with an API key first.\nGo to AI menu → AI Settings")
            self.show_ai_settings()
#             return

#         # Add auto-fix request to AI chat and send it
#         fix_message = f"Please analyze the code in {self.current_file} and identify any issues or errors. Provide:\n- List of any errors found\n- Corrected code with explanations\n- What was fixed and why\n- Any additional suggestions for improvement"

#         # Add user message to chat
self.ai_chat.config(state = 'normal')
#         self.ai_chat.insert('end', f"👤 You: Auto-fix Request for {self.current_file}\n")
self.ai_chat.config(state = 'disabled')
        self.ai_chat.see('end')

#         # Send to AI in background
#         def run_async():
loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
#             try:
                loop.run_until_complete(self.send_real_ai_message(fix_message))
#             finally:
                loop.close()

threading.Thread(target = run_async, daemon=True).start()

#     def load_ai_config(self):
#         """Load AI configuration from file."""
#         try:
config_dir = Path.home() / '.noodlecore'
config_file = config_dir / 'ai_config.json'

#             if config_file.exists():
#                 with open(config_file, 'r') as f:
config = json.load(f)
self.current_ai_provider = config.get('provider', 'OpenRouter')
self.current_ai_model = config.get('model', 'gpt-3.5-turbo')
self.ai_api_key = config.get('api_key', '')
                    print(f"AI config loaded: {self.current_ai_provider}, {self.current_ai_model}")
#         except Exception as e:
            print(f"Could not load AI config: {e}")

#     def save_ai_config(self):
#         """Save AI configuration to file."""
#         try:
config_dir = Path.home() / '.noodlecore'
config_dir.mkdir(exist_ok = True)
config_file = config_dir / 'ai_config.json'

#             with open(config_file, 'w') as f:
                json.dump({
#                     'provider': self.current_ai_provider,
#                     'model': self.current_ai_model,
#                     'api_key': self.ai_api_key
}, f, indent = 2)

            print(f"AI config saved: {self.current_ai_provider}, {self.current_ai_model}")
#         except Exception as e:
            print(f"Could not save AI config: {e}")

#     async def fetch_models_for_provider(self, provider_name):
#         """Fetch available models for selected provider."""
provider = self.ai_providers.get(provider_name)
#         if not provider:
#             return []

#         try:
models = await provider.get_available_models(self.ai_api_key)
#             return models
#         except Exception as e:
#             print(f"Failed to fetch models for {provider_name}: {e}")
#             return []

#     def show_ai_settings(self):
#         """Show enhanced AI settings dialog with live model fetching."""
dialog = tk.Toplevel(self.root)
        dialog.title("AI Settings")
        dialog.geometry("500x400")
dialog.configure(bg = '#2b2b2b')
        dialog.transient(self.root)
        dialog.grab_set()

#         # AI Provider selection
tk.Label(dialog, text = "AI Provider:", bg='#2b2b2b', fg='white').pack(anchor='w', padx=10, pady=(20, 5))
provider_var = tk.StringVar(value=self.current_ai_provider)
provider_combo = ttk.Combobox(dialog, textvariable=provider_var, state='readonly')
provider_combo['values'] = list(self.ai_providers.keys())
provider_combo.pack(fill = 'x', padx=10, pady=5)

#         # Model selection with live fetching
tk.Label(dialog, text = "Model:", bg='#2b2b2b', fg='white').pack(anchor='w', padx=10, pady=5)
model_var = tk.StringVar(value=self.current_ai_model)
model_combo = ttk.Combobox(dialog, textvariable=model_var)
model_combo.pack(fill = 'x', padx=10, pady=5)

#         # Custom model entry
custom_model_frame = tk.Frame(dialog, bg='#2b2b2b')
custom_model_frame.pack(fill = 'x', padx=10, pady=5)

tk.Label(custom_model_frame, text = "Or enter custom model:", bg='#2b2b2b', fg='white').pack(anchor='w')
custom_model_var = tk.StringVar()
custom_model_entry = tk.Entry(custom_model_frame, textvariable=custom_model_var, bg='#1e1e1e', fg='white')
custom_model_entry.pack(fill = 'x', pady=5)

#         # API Key
tk.Label(dialog, text = "API Key:", bg='#2b2b2b', fg='white').pack(anchor='w', padx=10, pady=5)
api_key_var = tk.StringVar(value=self.ai_api_key)
api_key_entry = tk.Entry(dialog, textvariable=api_key_var, show='*', bg='#1e1e1e', fg='white')
api_key_entry.pack(fill = 'x', padx=10, pady=5)

#         # Status label
status_label = tk.Label(dialog, text="", bg='#2b2b2b', fg='#00ff00')
status_label.pack(anchor = 'w', padx=10, pady=5)

#         # Function to update models when provider changes
#         def on_provider_change(*args):
provider_name = provider_var.get()
status_label.config(text = "Fetching models...")
            dialog.update()

#             def fetch_models():
loop = asyncio.new_event_loop()
                asyncio.set_event_loop(loop)
#                 try:
models = loop.run_until_complete(self.fetch_models_for_provider(provider_name))
model_combo['values'] = models
status_label.config(text = f"Found {len(models)} models")
#                 except Exception as e:
status_label.config(text = f"Error: {str(e)}")
#                 finally:
                    loop.close()

threading.Thread(target = fetch_models, daemon=True).start()

        provider_var.trace('w', on_provider_change)

#         # Initial model fetch
        on_provider_change()

#         def save_settings():
self.current_ai_provider = provider_var.get()

#             # Use custom model if entered, otherwise use selected model
selected_model = custom_model_var.get().strip()
#             if not selected_model:
selected_model = model_var.get()

self.current_ai_model = selected_model
self.ai_api_key = api_key_var.get()

#             # Save to config file
            self.save_ai_config()

            messagebox.showinfo("Settings Saved", "AI settings saved successfully!")
            dialog.destroy()

#         # Buttons
button_frame = tk.Frame(dialog, bg='#2b2b2b')
button_frame.pack(fill = 'x', padx=10, pady=20)

tk.Button(button_frame, text = "Save Settings", command=save_settings, bg='#4CAF50', fg='white').pack(side='left', padx=5)
tk.Button(button_frame, text = "Cancel", command=dialog.destroy, bg='#f44336', fg='white').pack(side='right', padx=5)

#     def show_ai_chat(self):
#         """Show AI chat interface with help."""
#         # AI chat is always visible in our layout
help_text = """🤖 AI Bestandscommando's:

# Bestandsbewerkingen:
# • lees [bestandsnaam] - Lees een bestand
# • schrijf [bestandsnaam]: [inhoud] - Maak nieuw bestand
# • pas [bestandsnaam] aan: [inhoud] - Wijzig bestaand bestand
# • open [bestandsnaam] - Open bestand in editor

# Projectanalyse:
# • analyseer [pad] - Analyseer projectstructuur en bestanden
# • index [pad] - Indexeer project met NoodleCore
# • overzicht [pad] - Toon projectoverzicht
# • scan [pad] - Scan project op bestanden en mappen

# Voorbeelden:
# • "lees main.py"
• "schrijf test.py: print('hello world')"
# • "pas config.json aan: {'debug': true}"
# • "analyseer src/"
# • "index ."

# De AI chat bevindt zich in het linkerpaneel."""

        messagebox.showinfo("AI Chat Help", help_text)

#     # ---------------------------
#     # Git Integration Methods
#     # ---------------------------

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
#         except Exception as e:
            self.terminal_output.insert('end', f"❌ Git Error: {str(e)}\n")
health_score - = 5

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

#     # ---------------------------
#     # Progress Manager Integration
#     # ---------------------------

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

#     # ---------------------------
#     # Panel Management
#     # ---------------------------

#     def toggle_panel(self, panel_name):
#         """Toggle panel visibility."""
#         # This is a simplified implementation - panels are always visible in this version
#         pass

#     # ---------------------------
#     # Self-Improvement Methods
#     # ---------------------------

#     def show_self_improvement_panel(self):
#         """Show self-improvement panel."""
#         # Panel is already visible in the left notebook
#         # Switch to the Self-Improve tab
#         if hasattr(self, 'left_notebook'):
#             try:
#                 # Find the Self-Improve tab index
#                 for i in range(self.left_notebook.index("end")):
#                     if self.left_notebook.tab(i, "text") == "Self-Improve":
                        self.left_notebook.select(i)
self.status_bar.config(text = "Switched to Self-Improvement panel")
#                         return
                messagebox.showinfo("Self-Improvement", "Self-Improvement panel is available in the left sidebar")
#             except Exception as e:
                print(f"Error switching to Self-Improvement panel: {e}")
                messagebox.showerror("Error", f"Failed to switch to Self-Improvement panel: {e}")
#         else:
            messagebox.showinfo("Self-Improvement", "Self-Improvement panel not available")

#     def start_self_improvement(self):
#         """Start self-improvement monitoring."""
#         if hasattr(self, 'self_improvement_integration') and self.self_improvement_integration:
#             try:
                self.self_improvement_integration.start_monitoring()
self.status_bar.config(text = "Self-Improvement monitoring started")
                messagebox.showinfo("Self-Improvement", "Self-Improvement monitoring started")
#             except Exception as e:
                print(f"Error starting self-improvement: {e}")
                messagebox.showerror("Error", f"Failed to start Self-Improvement: {e}")
#         else:
            messagebox.showwarning("Not Available", "Self-Improvement system not available")

#     def stop_self_improvement(self):
#         """Stop self-improvement monitoring."""
#         if hasattr(self, 'self_improvement_integration') and self.self_improvement_integration:
#             try:
                self.self_improvement_integration.stop_monitoring()
self.status_bar.config(text = "Self-Improvement monitoring stopped")
                messagebox.showinfo("Self-Improvement", "Self-Improvement monitoring stopped")
#             except Exception as e:
                print(f"Error stopping self-improvement: {e}")
                messagebox.showerror("Error", f"Failed to stop Self-Improvement: {e}")
#         else:
            messagebox.showwarning("Not Available", "Self-Improvement system not available")

#     def show_self_improvement_settings(self):
#         """Show self-improvement settings dialog."""
#         if not hasattr(self, 'self_improvement_integration') or not self.self_improvement_integration:
            messagebox.showwarning("Not Available", "Self-Improvement system not available")
#             return

#         # Create settings dialog
settings_dialog = tk.Toplevel(self.root)
        settings_dialog.title("Self-Improvement Settings")
        settings_dialog.geometry("500x400")
settings_dialog.configure(bg = '#2b2b2b')
        settings_dialog.transient(self.root)
        settings_dialog.grab_set()

#         # Title
        tk.Label(
#             settings_dialog,
text = "⚙️ Self-Improvement Settings",
bg = '#2b2b2b',
fg = 'white',
font = ('Arial', 14, 'bold')
).pack(pady = 10)

#         # Settings frame
settings_frame = tk.Frame(settings_dialog, bg='#2b2b2b')
settings_frame.pack(fill = 'both', expand=True, padx=20, pady=10)

#         # Monitoring interval
        tk.Label(
#             settings_frame,
text = "Monitoring Interval (seconds):",
bg = '#2b2b2b',
fg = 'white'
).pack(anchor = 'w', pady=(5, 0))

interval_var = tk.IntVar(value=30)
interval_entry = tk.Entry(settings_frame, textvariable=interval_var, bg='#1e1e1e', fg='white')
interval_entry.pack(fill = 'x', pady=(0, 10))

#         # Enable auto-improvement
auto_var = tk.BooleanVar(value=True)
auto_check = tk.Checkbutton(
#             settings_frame,
text = "Enable automatic improvements",
variable = auto_var,
bg = '#2b2b2b',
fg = 'white',
selectcolor = '#2b2b2b'
#         )
auto_check.pack(anchor = 'w', pady=5)

#         # Log level
        tk.Label(
#             settings_frame,
text = "Log Level:",
bg = '#2b2b2b',
fg = 'white'
).pack(anchor = 'w', pady=(5, 0))

log_var = tk.StringVar(value="INFO")
log_combo = ttk.Combobox(settings_frame, textvariable=log_var, state='readonly')
log_combo['values'] = ['DEBUG', 'INFO', 'WARNING', 'ERROR']
log_combo.pack(fill = 'x', pady=(0, 10))

#         # Buttons
button_frame = tk.Frame(settings_dialog, bg='#2b2b2b')
button_frame.pack(fill = 'x', padx=20, pady=10)

#         def save_settings():
#             try:
#                 # Apply settings to the integration
#                 if hasattr(self.self_improvement_integration, 'set_monitoring_interval'):
                    self.self_improvement_integration.set_monitoring_interval(interval_var.get())
#                 if hasattr(self.self_improvement_integration, 'set_auto_improvement'):
                    self.self_improvement_integration.set_auto_improvement(auto_var.get())
#                 if hasattr(self.self_improvement_integration, 'set_log_level'):
                    self.self_improvement_integration.set_log_level(log_var.get())

                messagebox.showinfo("Settings Saved", "Self-Improvement settings saved successfully")
                settings_dialog.destroy()
#             except Exception as e:
                messagebox.showerror("Error", f"Failed to save settings: {e}")

        tk.Button(
#             button_frame,
text = "Save Settings",
command = save_settings,
bg = '#4CAF50',
fg = 'white'
).pack(side = 'left', padx=5)

        tk.Button(
#             button_frame,
text = "Cancel",
command = settings_dialog.destroy,
bg = '#f44336',
fg = 'white'
).pack(side = 'right', padx=5)

#     # ---------------------------
#     # Auto-complete System
#     # ---------------------------

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
#             'open', 'range', 'enumerate', 'zip', 'map', 'filter', 'sorted', 'sum', 'min', 'max'
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
#         text_widget = event.widget if event else self._get_current_text_widget()
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
        return self.show_auto_complete(event)

#     # ---------------------------
#     # Enhanced Layout Methods
#     # ---------------------------

#     def _create_enhanced_layout(self):
#         """Create enhanced layout with AI chat and self-improvement panels."""
#         # Main container
main_container = tk.Frame(self.root, bg='#2b2b2b')
main_container.pack(fill = 'both', expand=True, padx=5, pady=5)

#         # Top split: Left panels and Code Editor
top_frame = tk.Frame(main_container, bg='#2b2b2b')
top_frame.pack(fill = 'both', expand=True)

        # Left panel container (File Explorer, AI Chat, Self-Improvement)
left_container = tk.Frame(top_frame, bg='#2b2b2b', width=400)
left_container.pack(side = 'left', fill='y')
        left_container.pack_propagate(False)

#         # Create notebook for left panels
left_notebook = ttk.Notebook(left_container)
left_notebook.pack(fill = 'both', expand=True, padx=5, pady=5)

#         # File Explorer Tab
file_explorer_frame = tk.Frame(left_notebook, bg='#2b2b2b')
left_notebook.add(file_explorer_frame, text = "Files")

file_explorer_label = tk.Label(file_explorer_frame, text="File Explorer", bg='#2b2b2b', fg='white', font=('Arial', 10, 'bold'))
file_explorer_label.pack(anchor = 'w', padx=5, pady=2)

self.file_tree = ttk.Treeview(file_explorer_frame, show='tree')
self.file_tree.pack(fill = 'both', expand=True, padx=5, pady=5)
        self.file_tree.bind('<<TreeviewOpen>>', self._on_tree_expand)
        self.file_tree.bind('<Double-1>', self._on_tree_double_click)

#         # AI Chat Tab
ai_chat_frame = tk.Frame(left_notebook, bg='#2b2b2b')
left_notebook.add(ai_chat_frame, text = "AI Chat")

ai_label = tk.Label(ai_chat_frame, text="🤖 AI Assistant", bg='#2b2b2b', fg='white', font=('Arial', 10, 'bold'))
ai_label.pack(anchor = 'w', padx=5, pady=2)

self.ai_chat = scrolledtext.ScrolledText(
#             ai_chat_frame,
height = 10,
bg = '#1e1e1e',
fg = '#00ff00',
font = ('Consolas', 10),
wrap = tk.WORD
#         )
self.ai_chat.pack(fill = 'both', expand=True, padx=5, pady=5)
self.ai_chat.config(state = 'disabled')

#         # AI input with role indicator
ai_input_frame = tk.Frame(ai_chat_frame, bg='#2b2b2b')
ai_input_frame.pack(fill = 'x', padx=5, pady=2)

self.ai_input = tk.Entry(ai_input_frame, bg='#1e1e1e', fg='white', font=('Consolas', 10))
self.ai_input.pack(fill = 'x', padx=5, pady=2)
        self.ai_input.bind('<Return>', self.send_ai_message)

#         # AI role indicator
#         self.ai_role_label = tk.Label(ai_input_frame, text=f"Role: {self.current_ai_role.name if self.current_ai_role else 'None'}", bg='#2b2b2b', fg='#00BCD4', font=('Arial', 8))
self.ai_role_label.pack(anchor = 'w', padx=5)

#         # Self-Improvement Tab
self_improvement_frame = tk.Frame(left_notebook, bg='#2b2b2b')
left_notebook.add(self_improvement_frame, text = "Self-Improve")

#         # Initialize self-improvement panel if available
self.self_improvement_panel = None
#         if hasattr(self, 'self_improvement_integration') and self.self_improvement_integration:
#             try:
#                 from .self_improvement_panel import SelfImprovementPanel
self.self_improvement_panel = SelfImprovementPanel(self_improvement_frame, self.self_improvement_integration)
panel = self.self_improvement_panel.get_panel()
panel.pack(fill = 'both', expand=True, padx=5, pady=5)
                print("Self-Improvement Panel added to layout")
#             except Exception as e:
                print(f"Failed to create Self-Improvement Panel: {e}")
#                 # Add placeholder label
tk.Label(self_improvement_frame, text = "Self-Improvement not available", bg='#2b2b2b', fg='white').pack(pady=20)

        # Right panel (Code Editor and Terminal)
right_frame = tk.Frame(top_frame, bg='#2b2b2b')
right_frame.pack(side = 'right', fill='both', expand=True)

#         # Editor and terminal paned window
editor_panes = ttk.PanedWindow(right_frame, orient='vertical')
editor_panes.pack(fill = 'both', expand=True)

#         # Code Editor
editor_frame = tk.Frame(editor_panes, bg='#1e1e1e')
self.notebook = ttk.Notebook(editor_frame)
self.notebook.pack(fill = 'both', expand=True, padx=5, pady=5)
editor_panes.add(editor_frame, weight = 4)

#         # Terminal
terminal_frame = tk.Frame(editor_panes, bg='#1e1e1e', height=200)
self.terminal_output = scrolledtext.ScrolledText(
#             terminal_frame,
bg = '#1e1e1e',
fg = '#00ff00',
font = ('Consolas', 10),
wrap = tk.WORD
#         )
self.terminal_output.pack(fill = 'both', expand=True, padx=5, pady=5)

self.terminal_input = tk.Entry(terminal_frame, bg='#252526', fg='white', font=('Consolas', 10))
self.terminal_input.pack(fill = 'x', padx=5, pady=2)
        self.terminal_input.bind('<Return>', self._on_terminal_enter)

editor_panes.add(terminal_frame, weight = 1)

#     def _on_exit(self) -> None:
#         # Simple unsaved check
#         dirty = [p for p, changed in self.unsaved_changes.items() if changed]
#         if dirty:
#             if not messagebox.askyesno(
#                 "Unsaved Changes",
#                 "You have unsaved changes. Exit anyway?",
#             ):
#                 return

#         # Shutdown self-improvement integration if available
#         if hasattr(self, 'self_improvement_integration') and self.self_improvement_integration:
            self.self_improvement_integration.shutdown()
            print("Self-Improvement integration shutdown")

#         # Shutdown self-improvement panel if available
#         if hasattr(self, 'self_improvement_panel') and self.self_improvement_panel:
            self.self_improvement_panel.shutdown()
            print("Self-Improvement panel shutdown")

        self.root.destroy()

#     # ---------------------------
#     # Main loop
#     # ---------------------------

#     def run(self) -> int:
#         try:
            self.setup_auto_complete()

#             # Start self-improvement integration if available
#             if hasattr(self, 'self_improvement_integration') and self.self_improvement_integration:
                self.self_improvement_integration.start_monitoring()
                print("Self-Improvement monitoring started")

            self.root.protocol("WM_DELETE_WINDOW", self._on_exit)
            self.root.mainloop()
#             return 0
#         except Exception as e:
            print(f"Failed to start IDE: {e}")
#             return 1


#     def _init_aere_integration(self):
        """Initialize AERE (AI Error Resolution Engine) integration."""
#         try:
#             # Import AERE components
#             from ..ai.aere_collector import get_collector
#             from ..ai.aere_analyzer import AEREAnalyzer
#             from ..ai.aere_router import get_router

#             # Initialize AERE components
self.aere_collector = get_collector()
#             self.aere_analyzer = AEREAnalyzer(self.role_manager if hasattr(self, 'role_manager') else None)
self.aere_router = get_router()

#             # Register for patch proposals
            self.aere_router.register_suggestion_callback(self._on_aere_suggestion)

#             # Start processing
self.aere_router.start_processing(interval = 10.0)

            print("AERE integration initialized successfully")

#         except Exception as e:
            print(f"Failed to initialize AERE integration: {e}")
self.aere_collector = None
self.aere_analyzer = None
self.aere_router = None

#     def _on_aere_suggestion(self, proposal):
#         """Handle AERE patch proposal suggestions."""
#         try:
#             # Add suggestion to AI chat if available
#             if hasattr(self, 'ai_chat') and self.ai_chat:
self.ai_chat.config(state = 'normal')
                self.ai_chat.insert('end', f"🔧 AERE Suggestion: {proposal.description}\n")
                self.ai_chat.insert('end', f"   File: {proposal.file_path}\n")
                self.ai_chat.insert('end', f"   Type: {proposal.patch_type.value}\n")
                self.ai_chat.insert('end', f"   Confidence: {proposal.confidence:.2f}\n")
                self.ai_chat.insert('end', f"   Rationale: {proposal.rationale}\n\n")
self.ai_chat.config(state = 'disabled')
                self.ai_chat.see('end')

#             # Update status bar
#             if hasattr(self, 'status_bar'):
self.status_bar.config(text = f"AERE suggestion: {proposal.patch_type.value}")

#         except Exception as e:
            print(f"Error handling AERE suggestion: {e}")

#     def emit_ide_diagnostic(self, file_path, line, message, severity="medium", category="syntax"):
#         """Emit an IDE diagnostic error event to AERE."""
#         if self.aere_collector:
            self.aere_collector.collect_ide_diagnostic(
file_path = file_path,
line = line,
message = message,
severity = severity,
category = category
#             )

#     def emit_runtime_error(self, file_path, message, stack=None, severity="high", category="runtime"):
#         """Emit a runtime error event to AERE."""
#         if self.aere_collector:
            self.aere_collector.collect_runtime_error(
file_path = file_path,
message = message,
stack = stack,
severity = severity,
category = category
#             )

#     def emit_test_failure(self, test_name, file_path, message, severity="medium"):
#         """Emit a test failure event to AERE."""
#         if self.aere_collector:
            self.aere_collector.collect_test_failure(
test_name = test_name,
file_path = file_path,
message = message,
severity = severity
#             )

#     def get_aere_suggestions(self):
#         """Get current AERE patch proposals."""
#         if self.aere_router:
            return self.aere_router.get_pending_proposals()
#         return []

#     def get_aere_status(self):
#         """Get AERE router status."""
#         if self.aere_router:
            return self.aere_router.get_router_status()
#         return {}

#     def record_aere_resolution(self, proposal_id, status, applied=False, details="", error=None):
#         """Record the outcome of applying an AERE patch proposal."""
#         if self.aere_router:
#             from ..ai.aere_event_models import ResolutionStatus
#             status_enum = ResolutionStatus(status) if isinstance(status, str) else status
            self.aere_router.record_resolution_outcome(
proposal_id = proposal_id,
status = status_enum,
applied = applied,
details = details,
error = error
#             )


def main() -> int:
#     """Main entrypoint used by launch_native_ide.py."""
ide = NativeNoodleCoreIDE()
    return ide.run()


#     async def _process_normal_ai_message(self, message):
#         """Continue AI processing after file command execution."""
#         try:
#             # Get current AI provider
provider = self.ai_providers.get(self.current_ai_provider)
#             if not provider:
                print(f"AI provider {self.current_ai_provider} not found")
#                 return

#             # Build enhanced system prompt with file operation capabilities
enhanced_system_prompt = """Je bent een AI assistent voor de NoodleCore IDE. Je kunt bestandsbewerkingen uitvoeren met de volgende commando's:

# Bestandsbewerkingen:
# - "lees [bestandsnaam]" - Lees een bestand
# - "schrijf [bestandsnaam]: [inhoud]" - Maak een nieuw bestand met inhoud
# - "pas [bestandsnaam] aan: [inhoud]" - Wijzig een bestaand bestand
# - "open [bestandsnaam]" - Open een bestand in de editor

# Voorbeeld:
# - "lees main.py"
- "schrijf test.py: print('hello world')"
# - "pas main.py aan: voeg een nieuwe functie toe"
# - "analyseer src/"
# - "index ."

# Toegestane mappen voor bestandsbewerkingen:
# - Standaard: huidige projectmap en submappen
# - Alle bestanden in projectmap kunnen gelezen worden
# - Gebruik absolute paden voor bestanden buiten project

# Beschikbare projectindex:
# - Je hebt toegang tot een geïndexeerde projectindex met bestandsinhoud
# - Gebruik "toon index" of "lijst bestanden" om de geïndexeerde bestanden te zien
# - De index wordt automatisch bijgewerkt bij bestandsbewerkingen

# Je kunt ook reguliere vragen stellen over code en programmering."""

#             # Build context-aware messages
messages = []
#             if self.current_ai_role:
#                 # Use Manager AI system prompt if available
system_prompt = self.current_ai_role.system_prompt
#                 if hasattr(self.current_ai_role, 'name') and self.current_ai_role.name == "NoodleCore Manager":
#                     # For Manager AI, read actual system prompt from role document
#                     try:
#                         if hasattr(self, 'role_manager') and self.role_manager:
manager_role = self.role_manager.get_role_by_name("NoodleCore Manager")
#                             if manager_role:
system_prompt = self.role_manager.read_role_document(manager_role.id)
#                     except Exception as e:
                        print(f"Failed to read Manager AI prompt: {e}")

                messages.append({
#                     "role": "system",
#                     "content": f"{system_prompt}\n\n{enhanced_system_prompt}"
#                 })
#             else:
                messages.append({
#                     "role": "system",
#                     "content": enhanced_system_prompt
#                 })

#             # Add conversation history if available
#             if hasattr(self, 'ai_conversation_history') and self.ai_conversation_history:
                # Add recent conversation history (last 10 messages to avoid token limits)
recent_history = math.subtract(self.ai_conversation_history[, 10:])
                messages.extend(recent_history)

#             # Add file context if available
#             if self.current_file:
#                 try:
#                     # Find text widget for current file
text_widget = None
#                     for tab_id, info in self.open_files.items():
#                         if info.get("path") == self.current_file:
text_widget = info.get("text")
#                             break

#                     if text_widget:
content = text_widget.get('1.0', 'end-1c')
                        messages.append({
#                             "role": "user",
#                             "content": f"Huidig bestand: {self.current_file}\n```\n{content[:2000]}\n```"
#                         })
#                 except Exception as e:
                    print(f"Failed to add file context: {e}")

#             # Add project index context for AI
#             if hasattr(self, 'project_index') and self.project_index:
#                 try:
#                     # Create a summary of indexed files for context
index_summary = "Project index beschikbaar:\n"
#                     for file_path, file_info in list(self.project_index.items())[:10]:  # Limit to 10 most recent files
file_size = file_info.get('size', 0)
#                         if file_size > 0:
size_kb = math.divide(file_size, 1024)
size_str = f" ({size_kb:.1f} KB)"
#                         else:
size_str = ""

index_summary + = f"- {file_path}{size_str}\n"

                    messages.append({
#                         "role": "user",
#                         "content": index_summary
#                     })
#                 except Exception as e:
                    print(f"Failed to add project index context: {e}")

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

#             # Store AI response in conversation history
#             if not hasattr(self, 'ai_conversation_history'):
self.ai_conversation_history = []

            self.ai_conversation_history.append({
#                 "role": "assistant",
#                 "content": response
#             })

            # Keep history manageable (last 20 messages)
#             if len(self.ai_conversation_history) > 20:
self.ai_conversation_history = math.subtract(self.ai_conversation_history[, 20:])

#         except Exception as e:
self.ai_chat.config(state = 'normal')
            self.ai_chat.delete('end-2l', 'end-1l')
            self.ai_chat.insert('end', f"❌ AI Error: {str(e)}\n\n")
self.ai_chat.config(state = 'disabled')
            self.ai_chat.see('end')

#     def _update_project_index(self, ai_command):
#         """Update project index with file content for AI context."""
#         try:
#             if ai_command['type'] == 'read':
file_path = ai_command['file']
#                 if not os.path.isabs(file_path):
file_path = os.path.join(self.current_project_path, file_path)

#                 if os.path.exists(file_path):
#                     with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
content = f.read()

#                     # Store in project index
rel_path = os.path.relpath(file_path, self.current_project_path)
self.project_index[rel_path] = {
#                         'content': content,
                        'last_modified': os.path.getmtime(file_path),
                        'size': os.path.getsize(file_path)
#                     }

                    print(f"Indexed file: {rel_path}")
#             elif ai_command['type'] == 'write':
file_path = ai_command['file']
#                 if not os.path.isabs(file_path):
file_path = os.path.join(self.current_project_path, file_path)

#                 # Store written content in index
rel_path = os.path.relpath(file_path, self.current_project_path)
self.project_index[rel_path] = {
#                     'content': ai_command['content'],
                    'last_modified': time.time(),
                    'size': len(ai_command['content'])
#                 }

                print(f"Indexed written file: {rel_path}")
#             elif ai_command['type'] == 'modify':
file_path = ai_command['file']
#                 if not os.path.isabs(file_path):
file_path = os.path.join(self.current_project_path, file_path)

#                 # Update content in index
rel_path = os.path.relpath(file_path, self.current_project_path)
self.project_index[rel_path] = {
#                     'content': ai_command['content'],
                    'last_modified': time.time(),
                    'size': len(ai_command['content'])
#                 }

                print(f"Indexed modified file: {rel_path}")

#         except Exception as e:
            print(f"Error updating project index: {e}")


if __name__ == "__main__"
        sys.exit(main())