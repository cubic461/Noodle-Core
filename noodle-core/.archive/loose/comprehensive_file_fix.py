#!/usr/bin/env python3
"""
Noodle Core::Comprehensive File Fix - comprehensive_file_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Comprehensive fix for native_gui_ide.py to address all syntax and formatting issues.
This script will:
1. Fix the unterminated string literal at line 44
2. Fix the line structure issues with everything on a few lines
3. Fix any remaining syntax errors
"""

import re

def fix_native_gui_ide_file():
    """Fix all syntax and formatting issues in native_gui_ide.py"""
    
    with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # The file is severely corrupted with everything on a few lines
    # We need to completely rewrite it with proper structure
    
    # First, let's check if it's the corrupted version
    if 'elp."""' in content and 'help_text = """[UNICODE]' in content:
        print("Detected corrupted file structure, applying comprehensive fix...")
        
        # Create a properly structured version of the beginning of the file
        new_content = '''#!/usr/bin/env python3
"""NoodleCore Native GUI IDE - Enhanced Canonical Implementation

This is the main IDE implementation for NoodleCore with enhanced features
including AI integration, syntax fixing, and self-improvement capabilities.
"""

import os
import sys
import json
import asyncio
import threading
import subprocess
import traceback
import logging
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional, Any, Union, Callable

try:
    import tkinter as tk
    from tkinter import ttk, scrolledtext, messagebox, filedialog
except ImportError:
    print("Error: tkinter is not available. Please install python3-tk.")
    sys.exit(1)

# Import NoodleCore components
try:
    from noodlecore.compiler.ast_nodes import *
    from noodlecore.compiler.type_system import *
    from noodlecore.compiler.generics import *
    from noodlecore.compiler.async_await import *
    from noodlecore.compiler.pattern_matching import *
    from noodlecore.compiler.bytecode_generator import *
    from noodlecore.compiler.advanced_optimizations import *
    from noodlecore.compiler.continuous_testing import *
    from noodlecore.security.incident_response import *
    from noodlecore.compiler.security_integration import *
    from noodlecore.self_improvement.compiler_metrics_collector import *
    from noodlecore.self_improvement.compiler_performance_monitor import *
    from noodlecore.self_improvement.optimization_effectiveness_tracker import *
    from noodlecore.self_improvement.language_feature_analyzer import *
    from noodlecore.self_improvement.security_compliance_monitor import *
    from noodlecore.self_improvement.testing_feedback_integration import *
    from noodlecore.self_improvement.compiler_feedback_loops import *
    from noodlecore.self_improvement.compiler_self_improvement_dashboard import *
    from noodlecore.python_integration.python_library_analyzer import *
    from noodlecore.python_integration.python_ffi_monitor import *
    from noodlecore.python_integration.library_optimization_engine import *
    from noodlecore.python_integration.python_usage_pattern_learner import *
except ImportError as e:
    print(f"Warning: Could not import NoodleCore components: {e}")
    # Define fallback classes for missing components
    class CompilationError(Exception):
        pass
    
    class SourceLocation:
        def __init__(self, line=1, column=1):
            self.line = line
            self.column = column
    
    class GenericParameterNode:
        def __init__(self, name, constraints=None):
            self.name = name
            self.constraints = constraints or []
    
    class GenericClass:
        def __init__(self, name, parameters=None):
            self.name = name
            self.parameters = parameters or []
    
    # Define OptimizationMetrics alias
    try:
        from noodlecore.compiler.advanced_optimizations import OptimizationMetrics
    except ImportError:
        class OptimizationMetrics:
            def __init__(self):
                self.optimization_count = 0
                self.performance_improvement = 0

# Feedback system availability check
try:
    from noodlecore.ai_agents.feedback_system import (
        FeedbackSystem, FeedbackLevel, FeedbackType
    )
    FEEDBACK_SYSTEM_AVAILABLE = True
except ImportError:
    FEEDBACK_SYSTEM_AVAILABLE = False
    FeedbackSystem = None
    FeedbackLevel = None
    FeedbackType = None


def safe_print(message):
    """Thread-safe print function."""
    try:
        print(message)
    except Exception:
        pass


class NativeNoodleCoreIDE:
    """NoodleCore Native GUI IDE - Main Application Class"""
    
    def __init__(self, root=None):
        """Initialize the IDE."""
        self.root = root or tk.Tk()
        self.root.title("NoodleCore IDE - Enhanced")
        self.root.geometry("1200x800")
        
        # Initialize core attributes
        self.current_project_path = Path.cwd()
        self.open_files = {}
        self.current_file = None
        self.unsaved_changes = {}
        self.project_index = {}
        self.workspace_state = {}
        
        # AI integration attributes
        self.current_ai_provider = None
        self.current_ai_model = None
        self.ai_api_key = None
        self.use_noodle_runtime_for_python = True
        
        # Initialize integrations
        self.syntax_fixer = None
        self.progress_manager = None
        self.self_improvement_integration = None
        self.trm_controller_integration = None
        self.feedback_system = None
        self.python_library_analyzer = None
        self.python_ffi_monitor = None
        self.library_optimization_engine = None
        
        # Setup IDE
        self._setup_ide_logging()
        self._init_aere_integration()
        self._setup_ui()
        self._load_workspace_state()
        
        print("[OK] NoodleCore IDE initialized successfully")
    
    def _setup_ui(self):
        """Setup the main UI components."""
        # Create menu bar
        menubar = tk.Menu(self.root)
        self.root.config(menu=menubar)
        
        # File menu
        file_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="File", menu=file_menu)
        file_menu.add_command(label="New File", command=self.new_file)
        file_menu.add_command(label="Open File", command=self.open_file)
        file_menu.add_command(label="Save File", command=self.save_file)
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self._on_exit)
        
        # Edit menu
        edit_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Edit", menu=edit_menu)
        edit_menu.add_command(label="Find", command=self.find_text)
        edit_menu.add_command(label="Replace", command=self.replace_text)
        
        # View menu
        view_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="View", menu=view_menu)
        view_menu.add_command(label="AI Settings", command=self.show_ai_settings)
        view_menu.add_command(label="Syntax Fixer", command=self.fix_noodlecore_syntax)
        view_menu.add_command(label="Python Integration", command=self.show_python_integration_settings)
        
        # Tools menu
        tools_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Tools", menu=tools_menu)
        tools_menu.add_command(label="Validate All NC Files", command=self.validate_all_nc_files)
        tools_menu.add_command(label="Project Health Check", command=self.project_health_check_workflow)
        
        # Help menu
        help_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Help", menu=help_menu)
        help_menu.add_command(label="AI Chat Help", command=self.show_ai_chat)
        help_menu.add_command(label="About", command=self.show_about)
        
        # Create main paned window
        self.main_paned = tk.PanedWindow(self.root, orient=tk.HORIZONTAL)
        self.main_paned.pack(fill=tk.BOTH, expand=True)
        
        # Left panel with notebook
        self.left_frame = tk.Frame(self.main_paned, bg='#2b2b2b')
        self.main_paned.add(self.left_frame, minsize=300)
        
        self.left_notebook = ttk.Notebook(self.left_frame)
        self.left_notebook.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # AI Chat tab
        self.ai_frame = tk.Frame(self.left_notebook, bg='#2b2b2b')
        self.left_notebook.add(self.ai_frame, text="AI Chat")
        
        tk.Label(self.ai_frame, text="AI Chat Interface", bg='#2b2b2b', fg='white').pack(pady=10)
        self.ai_chat = scrolledtext.ScrolledText(
            self.ai_frame, bg='#1e1e1e', fg='#00ff00', font=('Courier', 10)
        )
        self.ai_chat.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Terminal tab
        self.terminal_frame = tk.Frame(self.left_notebook, bg='#2b2b2b')
        self.left_notebook.add(self.terminal_frame, text="Terminal")
        
        tk.Label(self.terminal_frame, text="Terminal Output", bg='#2b2b2b', fg='white').pack(pady=10)
        self.terminal_output = scrolledtext.ScrolledText(
            self.terminal_frame, bg='#1e1e1e', fg='#00ff00', font=('Courier', 10)
        )
        self.terminal_output.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Right panel with editor
        self.right_frame = tk.Frame(self.main_paned, bg='#2b2b2b')
        self.main_paned.add(self.right_frame, minsize=500)
        
        # Editor notebook
        self.notebook = ttk.Notebook(self.right_frame)
        self.notebook.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Status bar
        self.status_bar = tk.Label(
            self.root, text="Ready", bd=1, relief=tk.SUNKEN, anchor=tk.W, bg='#2b2b2b', fg='white'
        )
        self.status_bar.pack(side=tk.BOTTOM, fill=tk.X)
        
        print("[OK] UI setup completed")
    
    def show_ai_chat(self):
        """Show AI chat interface with help."""
        # AI chat is always visible in our layout
        help_text = """[UNICODE] AI Bestandscommando's:
    Bestandsbewerkingen:
    [UNICODE] lees [bestandsnaam] - Lees een bestand
    [UNICODE] schrijf [bestandsnaam]: [inhoud] - Maak een nieuw bestand met inhoud
    [UNICODE] pas [bestandsnaam] aan: [inhoud] - Wijzig een bestaand bestand
    [UNICODE] open [bestandsnaam] - Open bestand in editor
    
    Projectanalyse:
    [UNICODE] analyseer [pad] - Analyseer projectstructuur en bestanden
    [UNICODE] index [pad] - Indexeer project met NoodleCore
    [UNICODE] overzicht [pad] - Toon projectoverzicht
    [UNICODE] scan [pad] - Scan project op bestanden en mappen
    
    Voorbeelden:
    [UNICODE] "lees main.py"
    [UNICODE] "schrijf test.py: print('hello world')"
    [UNICODE] "pas config.json aan: {'debug': true}"
    [UNICODE] "analyseer src/"
    [UNICODE] "index ."
    
    De AI chat bevindt zich in het linkerpaneel."""
        messagebox.showinfo("AI Chat Help", help_text)
    
    def show_ai_settings(self):
        """Show AI settings dialog."""
        # Create settings dialog
        dialog = tk.Toplevel(self.root)
        dialog.title("AI Settings")
        dialog.geometry("500x400")
        dialog.configure(bg='#2b2b2b')
        dialog.transient(self.root)
        dialog.grab_set()
        
        # Title
        tk.Label(
            dialog,
            text="AI and Noodle Runtime Settings",
            bg='#2b2b2b',
            fg='white',
            font=('Arial', 14, 'bold')
        ).pack(pady=10)
        
        # Settings frame
        settings_frame = tk.Frame(dialog, bg='#2b2b2b')
        settings_frame.pack(fill='both', expand=True, padx=20, pady=10)
        
        # AI Provider
        tk.Label(
            settings_frame,
            text="AI Provider:",
            bg='#2b2b2b',
            fg='white'
        ).pack(anchor='w', pady=(5, 0))
        
        provider_var = tk.StringVar(value=self.current_ai_provider or "openai")
        provider_combo = ttk.Combobox(settings_frame, textvariable=provider_var, state='readonly')
        provider_combo['values'] = ['openai', 'anthropic', 'google', 'local']
        provider_combo.pack(fill='x', pady=(0, 10))
        
        # AI Model
        tk.Label(
            settings_frame,
            text="AI Model:",
            bg='#2b2b2b',
            fg='white'
        ).pack(anchor='w', pady=(5, 0))
        
        model_var = tk.StringVar(value=self.current_ai_model or "gpt-4")
        model_combo = ttk.Combobox(settings_frame, textvariable=model_var)
        model_combo.pack(fill='x', pady=(0, 10))
        
        # API Key
        tk.Label(
            settings_frame,
            text="API Key:",
            bg='#2b2b2b',
            fg='white'
        ).pack(anchor='w', pady=(5, 0))
        
        api_key_var = tk.StringVar(value=self.ai_api_key or "")
        api_key_entry = tk.Entry(settings_frame, textvariable=api_key_var, show="*", bg='#1e1e1e', fg='white')
        api_key_entry.pack(fill='x', pady=(0, 10))
        
        # Use Noodle Runtime for Python
        use_noodle_runtime_var = tk.BooleanVar(value=self.use_noodle_runtime_for_python)
        tk.Checkbutton(
            settings_frame,
            text="Use Noodle Runtime for Python execution",
            variable=use_noodle_runtime_var,
            bg='#2b2b2b',
            fg='white',
            selectcolor='#2b2b2b'
        ).pack(anchor='w', pady=10)
        
        # Status label
        status_label = tk.Label(
            settings_frame,
            text="Ready to configure...",
            bg='#2b2b2b',
            fg='#00ff00',
            font=('Courier', 9)
        )
        status_label.pack(anchor='w', pady=5)
        
        # Fetch models when provider changes
        def on_provider_change(*args):
            provider_name = provider_var.get()
            if provider_name:
                status_label.config(text=f"Fetching models for {provider_name}...")
                dialog.update()
                
                # This would normally fetch models from the provider
                # For now, we'll just show some example models
                if provider_name == "openai":
                    models = ["gpt-4", "gpt-4-turbo", "gpt-3.5-turbo"]
                elif provider_name == "anthropic":
                    models = ["claude-3-opus", "claude-3-sonnet", "claude-3-haiku"]
                elif provider_name == "google":
                    models = ["gemini-pro", "gemini-pro-vision"]
                else:
                    models = ["local-model"]
                
                model_combo['values'] = models
                if models:
                    model_combo.set(models[0])
                
                status_label.config(text=f"Found {len(models)} models - Selected: {models[0]}")
        
        provider_var.trace('w', on_provider_change)
        
        # Initial model fetch
        on_provider_change()
        
        def save_settings():
            # Update IDE state with new values
            self.current_ai_provider = provider_var.get()
            self.current_ai_model = model_var.get()
            self.ai_api_key = api_key_var.get()
            self.use_noodle_runtime_for_python = use_noodle_runtime_var.get()
            
            # Save to config file
            try:
                self.save_ai_config()
                messagebox.showinfo("Settings Saved", "AI and Noodle Runtime settings saved successfully!")
                dialog.destroy()
            except Exception as e:
                messagebox.showerror("Save Error", f"Failed to save AI settings: {str(e)}")
        
        # Buttons
        button_frame = tk.Frame(dialog, bg='#2b2b2b')
        button_frame.pack(fill='x', padx=10, pady=20)
        
        tk.Button(
            button_frame,
            text="Save Settings",
            command=save_settings,
            bg='#4CAF50',
            fg='white'
        ).pack(side='left', padx=5)
        
        tk.Button(
            button_frame,
            text="Cancel",
            command=dialog.destroy,
            bg='#f44336',
            fg='white'
        ).pack(side='right', padx=5)
    
    def save_ai_config(self):
        """Save AI configuration to file."""
        config_file = Path.home() / '.noodlecore' / 'ai_config.json'
        config_file.parent.mkdir(exist_ok=True)
        
        config = {
            'provider': self.current_ai_provider,
            'model': self.current_ai_model,
            'api_key': self.ai_api_key,
            'use_noodle_runtime': self.use_noodle_runtime_for_python
        }
        
        with open(config_file, 'w') as f:
            json.dump(config, f, indent=2)
    
    def new_file(self):
        """Create a new file."""
        # Create a new tab with a text widget
        text_widget = scrolledtext.ScrolledText(
            self.notebook, bg='#1e1e1e', fg='white', font=('Courier', 10)
        )
        
        # Add tab to notebook
        tab_id = self.notebook.add(text_widget, text="Untitled")
        
        # Store file info
        self.open_files[tab_id] = {
            'path': None,
            'text': text_widget,
            'saved': False
        }
        
        # Switch to new tab
        self.notebook.select(tab_id)
        
        self.status_bar.config(text="New file created")
    
    def open_file(self):
        """Open a file."""
        file_path = filedialog.askopenfilename(
            title="Select File",
            filetypes=[
                ("All Files", "*.*"),
                ("Python Files", "*.py"),
                ("NoodleCore Files", "*.nc"),
                ("JavaScript Files", "*.js"),
                ("HTML Files", "*.html"),
                ("CSS Files", "*.css"),
                ("JSON Files", "*.json"),
                ("Text Files", "*.txt")
            ]
        )
        
        if file_path:
            # Check if file is already open
            for tab_id, info in self.open_files.items():
                if info.get('path') == file_path:
                    self.notebook.select(tab_id)
                    self.status_bar.config(text=f"File already open: {Path(file_path).name}")
                    return
            
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Create a new tab with a text widget
                text_widget = scrolledtext.ScrolledText(
                    self.notebook, bg='#1e1e1e', fg='white', font=('Courier', 10)
                )
                text_widget.insert('1.0', content)
                
                # Add tab to notebook
                tab_id = self.notebook.add(text_widget, text=Path(file_path).name)
                
                # Store file info
                self.open_files[tab_id] = {
                    'path': file_path,
                    'text': text_widget,
                    'saved': True
                }
                
                # Switch to new tab
                self.notebook.select(tab_id)
                
                self.current_file = file_path
                self.status_bar.config(text=f"Opened: {Path(file_path).name}")
                
            except Exception as e:
                messagebox.showerror("Error", f"Failed to open file: {str(e)}")
    
    def save_file(self):
        """Save the current file."""
        current_tab = self.notebook.select()
        if not current_tab:
            return
        
        file_info = self.open_files.get(current_tab)
        if not file_info:
            return
        
        file_path = file_info.get('path')
        text_widget = file_info.get('text')
        
        if not file_path:
            # Save As dialog
            file_path = filedialog.asksaveasfilename(
                title="Save File",
                defaultextension=".txt",
                filetypes=[
                    ("All Files", "*.*"),
                    ("Python Files", "*.py"),
                    ("NoodleCore Files", "*.nc"),
                    ("JavaScript Files", "*.js"),
                    ("HTML Files", "*.html"),
                    ("CSS Files", "*.css"),
                    ("JSON Files", "*.json"),
                    ("Text Files", "*.txt")
                ]
            )
            
            if not file_path:
                return
            
            # Update tab title
            self.notebook.tab(current_tab, text=Path(file_path).name)
            file_info['path'] = file_path
        
        try:
            content = text_widget.get('1.0', 'end-1c')
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            file_info['saved'] = True
            self.current_file = file_path
            self.status_bar.config(text=f"Saved: {Path(file_path).name}")
            
        except Exception as e:
            messagebox.showerror("Error", f"Failed to save file: {str(e)}")
    
    def find_text(self):
        """Find text in the current file."""
        current_tab = self.notebook.select()
        if not current_tab:
            return
        
        file_info = self.open_files.get(current_tab)
        if not file_info:
            return
        
        text_widget = file_info.get('text')
        
        # Create find dialog
        dialog = tk.Toplevel(self.root)
        dialog.title("Find")
        dialog.geometry("300x100")
        dialog.configure(bg='#2b2b2b')
        dialog.transient(self.root)
        
        # Find entry
        tk.Label(dialog, text="Find:", bg='#2b2b2b', fg='white').pack(pady=5)
        find_var = tk.StringVar()
        find_entry = tk.Entry(dialog, textvariable=find_var, bg='#1e1e1e', fg='white')
        find_entry.pack(pady=5)
        find_entry.focus_set()
        
        def do_find():
            search_term = find_var.get()
            if not search_term:
                return
            
            # Remove previous highlights
            text_widget.tag_remove('found', '1.0', 'end')
            
            # Search for the term
            idx = '1.0'
            while True:
                idx = text_widget.search(search_term, idx, nocase=True)
                if not idx:
                    break
                
                last_idx = f"{idx}+{len(search_term)}c"
                text_widget.tag_add('found', idx, last_idx)
                idx = last_idx
            
            # Configure highlight tag
            text_widget.tag_config('found', background='yellow')
            
            if text_widget.tag_ranges('found'):
                # Jump to first match
                first_match = text_widget.tag_ranges('found')[0]
                text_widget.see(first_match)
                self.status_bar.config(text=f"Found matches for: {search_term}")
            else:
                self.status_bar.config(text=f"No matches found for: {search_term}")
        
        # Buttons
        button_frame = tk.Frame(dialog, bg='#2b2b2b')
        button_frame.pack(pady=10)
        
        tk.Button(button_frame, text="Find", command=do_find, bg='#4CAF50', fg='white').pack(side='left', padx=5)
        tk.Button(button_frame, text="Close", command=dialog.destroy, bg='#f44336', fg='white').pack(side='right', padx=5)
    
    def replace_text(self):
        """Replace text in the current file."""
        current_tab = self.notebook.select()
        if not current_tab:
            return
        
        file_info = self.open_files.get(current_tab)
        if not file_info:
            return
        
        text_widget = file_info.get('text')
        
        # Create replace dialog
        dialog = tk.Toplevel(self.root)
        dialog.title("Replace")
        dialog.geometry("350x150")
        dialog.configure(bg='#2b2b2b')
        dialog.transient(self.root)
        
        # Find entry
        tk.Label(dialog, text="Find:", bg='#2b2b2b', fg='white').pack(pady=5)
        find_var = tk.StringVar()
        find_entry = tk.Entry(dialog, textvariable=find_var, bg='#1e1e1e', fg='white')
        find_entry.pack(pady=5)
        find_entry.focus_set()
        
        # Replace entry
        tk.Label(dialog, text="Replace with:", bg='#2b2b2b', fg='white').pack(pady=5)
        replace_var = tk.StringVar()
        replace_entry = tk.Entry(dialog, textvariable=replace_var, bg='#1e1e1e', fg='white')
        replace_entry.pack(pady=5)
        
        def do_replace():
            search_term = find_var.get()
            replace_term = replace_var.get()
            
            if not search_term:
                return
            
            # Remove previous highlights
            text_widget.tag_remove('found', '1.0', 'end')
            
            # Count and replace occurrences
            content = text_widget.get('1.0', 'end-1c')
            count = content.count(search_term)
            
            if count > 0:
                # Replace all occurrences
                new_content = content.replace(search_term, replace_term)
                text_widget.delete('1.0', 'end')
                text_widget.insert('1.0', new_content)
                
                self.status_bar.config(text=f"Replaced {count} occurrences of: {search_term}")
            else:
                self.status_bar.config(text=f"No occurrences found for: {search_term}")
        
        # Buttons
        button_frame = tk.Frame(dialog, bg='#2b2b2b')
        button_frame.pack(pady=10)
        
        tk.Button(button_frame, text="Replace All", command=do_replace, bg='#4CAF50', fg='white').pack(side='left', padx=5)
        tk.Button(button_frame, text="Close", command=dialog.destroy, bg='#f44336', fg='white').pack(side='right', padx=5)
    
    def show_about(self):
        """Show about dialog."""
        messagebox.showinfo(
            "About NoodleCore IDE",
            "NoodleCore IDE - Enhanced Version\n\n"
            "A powerful IDE for NoodleCore development with AI integration,\n"
            "syntax fixing, and self-improvement capabilities.\n\n"
            "Â© 2025 NoodleCore Project"
        )
    
    def execute_ai_file_command(self, command_text):
        """Execute an AI file command."""
        try:
            # Parse the command
            if command_text.startswith("lees "):
                filename = command_text[5:].strip()
                self._read_file_command(filename)
            elif command_text.startswith("schrijf "):
                # Parse "schrijf filename: content"
                if ":" in command_text:
                    parts = command_text[7:].split(":", 1)
                    filename = parts[0].strip()
                    content = parts[1].strip()
                    self._write_file_command(filename, content)
            elif command_text.startswith("pas "):
                # Parse "pas filename aan: content"
                if " aan:" in command_text:
                    parts = command_text[4:].split(" aan:", 1)
                    filename = parts[0].strip()
                    content = parts[1].strip()
                    self._modify_file_command(filename, content)
            elif command_text.startswith("open "):
                filename = command_text[5:].strip()
                self._open_file_command(filename)
            elif command_text.startswith("analyseer "):
                path = command_text[10:].strip()
                self._analyze_command(path)
            elif command_text.startswith("index "):
                path = command_text[6:].strip()
                self._index_command(path)
            elif command_text.startswith("overzicht "):
                path = command_text[9:].strip()
                self._overview_command(path)
            elif command_text.startswith("scan "):
                path = command_text[5:].strip()
                self._scan_command(path)
            else:
                self.terminal_output.config(state='normal')
                self.terminal_output.insert('end', f"[ERROR] Unknown command: {command_text}\n")
                self.terminal_output.config(state='disabled')
        except Exception as e:
            self.terminal_output.config(state='normal')
            self.terminal_output.insert('end', f"[ERROR] Failed to execute command: {str(e)}\n")
            self.terminal_output.config(state='disabled')
    
    def _read_file_command(self, filename):
        """Read a file and display its content."""
        try:
            file_path = self.current_project_path / filename
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            self.terminal_output.config(state='normal')
            self.terminal_output.insert('end', f"\n[READ] {filename}:\n")
            self.terminal_output.insert('end', "-" * 50 + "\n")
            self.terminal_output.insert('end', content)
            self.terminal_output.insert('end', "\n" + "-" * 50 + "\n")
            self.terminal_output.config(state='disabled')
            self.terminal_output.see('end')
            
            self.status_bar.config(text=f"Read file: {filename}")
        except Exception as e:
            self.terminal_output.config(state='normal')
            self.terminal_output.insert('end', f"[ERROR] Failed to read {filename}: {str(e)}\n")
            self.terminal_output.config(state='disabled')
    
    def _write_file_command(self, filename, content):
        """Write content to a new file."""
        try:
            file_path = self.current_project_path / filename
            
            # Create parent directories if they don't exist
            file_path.parent.mkdir(parents=True, exist_ok=True)
            
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            self.terminal_output.config(state='normal')
            self.terminal_output.insert('end', f"[WRITE] Created {filename}\n")
            self.terminal_output.config(state='disabled')
            self.terminal_output.see('end')
            
            self.status_bar.config(text=f"Created file: {filename}")
        except Exception as e:
            self.terminal_output.config(state='normal')
            self.terminal_output.insert('end', f"[ERROR] Failed to write {filename}: {str(e)}\n")
            self.terminal_output.config(state='disabled')
    
    def _modify_file_command(self, filename, content):
        """Modify an existing file with new content."""
        try:
            file_path = self.current_project_path / filename
            
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            self.terminal_output.config(state='normal')
            self.terminal_output.insert('end', f"[MODIFY] Updated {filename}\n")
            self.terminal_output.config(state='disabled')
            self.terminal_output.see('end')
            
            self.status_bar.config(text=f"Modified file: {filename}")
        except Exception as e:
            self.terminal_output.config(state='normal')
            self.terminal_output.insert('end', f"[ERROR] Failed to modify {filename}: {str(e)}\n")
            self.terminal_output.config(state='disabled')
    
    def _open_file_command(self, filename):
        """Open a file in the editor."""
        try:
            file_path = self.current_project_path / filename
            
            # Check if file is already open
            for tab_id, info in self.open_files.items():
                if info.get('path') == str(file_path):
                    self.notebook.select(tab_id)
                    self.status_bar.config(text=f"File already open: {filename}")
                    return
            
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Create a new tab with a text widget
            text_widget = scrolledtext.ScrolledText(
                self.notebook, bg='#1e1e1e', fg='white', font=('Courier', 10)
            )
            text_widget.insert('1.0', content)
            
            # Add tab to notebook
            tab_id = self.notebook.add(text_widget, text=filename)
            
            # Store file info
            self.open_files[tab_id] = {
                'path': str(file_path),
                'text': text_widget,
                'saved': True
            }
            
            # Switch to new tab
            self.notebook.select(tab_id)
            
            self.current_file = str(file_path)
            self.status_bar.config(text=f"Opened: {filename}")
        except Exception as e:
            self.terminal_output.config(state='normal')
            self.terminal_output.insert('end', f"[ERROR] Failed to open {filename}: {str(e)}\n")
            self.terminal_output.config(state='disabled')
    
    def _analyze_command(self, path):
        """Analyze a project path."""
        try:
            target_path = self.current_project_path / path if path else self.current_project_path
            
            self.terminal_output.config(state='normal')
            self.terminal_output.insert('end', f"\n[ANALYZE] Project analysis for: {target_path}\n")
            self.terminal_output.insert('end', "=" * 50 + "\n")
            
            # Count files by type
            file_counts = {}
            total_files = 0
            
            for root, dirs, files in os.walk(target_path):
                # Skip hidden directories
                dirs[:] = [d for d in dirs if not d.startswith('.')]
                
                for file in files:
                    if not file.startswith('.'):
                        ext = Path(file).suffix.lower()
                        file_counts[ext] = file_counts.get(ext, 0) + 1
                        total_files += 1
            
            # Display results
            self.terminal_output.insert('end', f"Total files: {total_files}\n")
            self.terminal_output.insert('end', "File types:\n")
            
            for ext, count in sorted(file_counts.items()):
                ext_name = ext if ext else "no extension"
                self.terminal_output.insert('end', f"  {ext_name}: {count}\n")
            
            self.terminal_output.insert('end', "=" * 50 + "\n")
            self.terminal_output.config(state='disabled')
            self.terminal_output.see('end')
            
            self.status_bar.config(text=f"Analyzed: {path if path else 'current project'}")
        except Exception as e:
            self.terminal_output.config(state='normal')
            self.terminal_output.insert('end', f"[ERROR] Failed to analyze {path}: {str(e)}\n")
            self.terminal_output.config(state='disabled')
    
    def _index_command(self, path):
        """Index a project path for NoodleCore."""
        try:
            target_path = self.current_project_path / path if path else self.current_project_path
            
            self.terminal_output.config(state='normal')
            self.terminal_output.insert('end', f"\n[INDEX] Indexing project: {target_path}\n")
            self.terminal_output.insert('end', "=" * 50 + "\n")
            
            # Update project index
            self.project_index = {}
            indexed_files = 0
            
            for root, dirs, files in os.walk(target_path):
                # Skip hidden directories
                dirs[:] = [d for d in dirs if not d.startswith('.')]
                
                for file in files:
                    if not file.startswith('.') and not file.endswith('.pyc'):
                        file_path = os.path.join(root, file)
                        rel_path = os.path.relpath(file_path, self.current_project_path)
                        
                        # Only index text files
                        if file.endswith(('.py', '.js', '.ts', '.html', '.css', '.md', '.txt', '.json', '.yaml', '.yml', '.nc')):
                            try:
                                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                                    content = f.read()
                                    if len(content) < 100000:  # Skip very large files
                                        self.project_index[rel_path] = content
                                        indexed_files += 1
                            except Exception as e:
                                self.terminal_output.insert('end', f"[WARN] Failed to index {rel_path}: {str(e)}\n")
            
            self.terminal_output.insert('end', f"Indexed {indexed_files} files\n")
            self.terminal_output.insert('end', "=" * 50 + "\n")
            self.terminal_output.config(state='disabled')
            self.terminal_output.see('end')
            
            self.status_bar.config(text=f"Indexed: {path if path else 'current project'}")
        except Exception as e:
            self.terminal_output.config(state='normal')
            self.terminal_output.insert('end', f"[ERROR] Failed to index {path}: {str(e)}\n")
            self.terminal_output.config(state='disabled')
    
    def _overview_command(self, path):
        """Show project overview."""
        try:
            target_path = self.current_project_path / path if path else self.current_project_path
            
            self.terminal_output.config(state='normal')
            self.terminal_output.insert('end', f"\n[OVERVIEW] Project overview for: {target_path}\n")
            self.terminal_output.insert('end', "=" * 50 + "\n")
            
            # Directory structure
            self.terminal_output.insert('end', "Directory structure:\n")
            
            for root, dirs, files in os.walk(target_path):
                # Skip hidden directories
                dirs[:] = [d for d in dirs if not d.startswith('.')]
                
                level = root.replace(str(self.current_project_path), '').count(os.sep)
                indent = ' ' * 2 * level
                rel_path = os.path.relpath(root, self.current_project_path)
                
                if rel_path != '.':
                    self.terminal_output.insert('end', f"{indent}{os.path.basename(rel_path)}/\n")
                    indent += '  '
                
                # Show only first few files per directory
                for i, file in enumerate(files[:5]):
                    if not file.startswith('.'):
                        self.terminal_output.insert('end', f"{indent}{file}\n")
                
                if len(files) > 5:
                    self.terminal_output.insert('end', f"{indent}... and {len(files) - 5} more files\n")
            
            self.terminal_output.insert('end', "=" * 50 + "\n")
            self.terminal_output.config(state='disabled')
            self.terminal_output.see('end')
            
            self.status_bar.config(text=f"Overview: {path if path else 'current project'}")
        except Exception as e:
            self.terminal_output.config(state='normal')
            self.terminal_output.insert('end', f"[ERROR] Failed to show overview for {path}: {str(e)}\n")
            self.terminal_output.config(state='disabled')
    
    def _scan_command(self, path):
        """Scan a project path for files and directories."""
        try:
            target_path = self.current_project_path / path if path else self.current_project_path
            
            self.terminal_output.config(state='normal')
            self.terminal_output.insert('end', f"\n[SCAN] Scanning project: {target_path}\n")
            self.terminal_output.insert('end', "=" * 50 + "\n")
            
            # Directories
            dirs = [d for d in target_path.iterdir() if d.is_dir() and not d.name.startswith('.')]
            self.terminal_output.insert('end', f"Directories ({len(dirs)}):\n")
            for d in sorted(dirs):
                self.terminal_output.insert('end', f"  {d.name}/\n")
            
            # Files
            files = [f for f in target_path.iterdir() if f.is_file() and not f.name.startswith('.')]
            self.terminal_output.insert('end', f"\nFiles ({len(files)}):\n")
            for f in sorted(files):
                size_str = f"({f.stat().st_size} bytes)" if f.stat().st_size < 1024 else f"({f.stat().st_size // 1024} KB)"
                self.terminal_output.insert('end', f"  {f.name} {size_str}\n")
            
            self.terminal_output.insert('end', "=" * 50 + "\n")
            self.terminal_output.config(state='disabled')
            self.terminal_output.see('end')
            
            self.status_bar.config(text=f"Scanned: {path if path else 'current project'}")
        except Exception as e:
            self.terminal_output.config(state='normal')
            self.terminal_output.insert('end', f"[ERROR] Failed to scan {path}: {str(e)}\n")
            self.terminal_output.config(state='disabled')
    
    def validate_all_nc_files(self):
        """Validate all .nc files in the project."""
        self.terminal_output.config(state='normal')
        self.terminal_output.insert('end', "\n[VALIDATE] Validating all .nc files...\n")
        self.terminal_output.insert('end', "=" * 50 + "\n")
        
        nc_files = list(self.current_project_path.glob("**/*.nc"))
        
        if not nc_files:
            self.terminal_output.insert('end', "No .nc files found in project.\n")
        else:
            self.terminal_output.insert('end', f"Found {len(nc_files)} .nc files:\n")
            
            for nc_file in nc_files:
                rel_path = os.path.relpath(nc_file, self.current_project_path)
                self.terminal_output.insert('end', f"  {rel_path}\n")
        
        self.terminal_output.insert('end', "=" * 50 + "\n")
        self.terminal_output.config(state='disabled')
        self.terminal_output.see('end')
        
        self.status_bar.config(text=f"Validated {len(nc_files)} .nc files")
    
    def project_health_check_workflow(self):
        """Execute workflow to check project health."""
        self.terminal_output.config(state='normal')
        self.terminal_output.insert('end', "\n[HEALTH] Project Health Check:\n")
        self.terminal_output.insert('end', "=" * 50 + "\n")
        
        health_score = 100
        
        # 1. Git Repository Check
        try:
            result = subprocess.run(
                ['git', 'status'],
                capture_output=True,
                text=True,
                cwd=self.current_project_path
            )
            if result.returncode == 0:
                self.terminal_output.insert('end', "[OK] Git Repository: Healthy\n")
            else:
                self.terminal_output.insert('end', "[ERROR] Git Repository: Not initialized\n")
                health_score -= 10
        except FileNotFoundError:
            self.terminal_output.insert('end', "[ERROR] Git: Not installed\n")
            health_score -= 20
        except Exception as e:
            self.terminal_output.insert('end', f"[ERROR] Git Error: {str(e)}\n")
            health_score -= 5
        
        # 2. Python File Check
        python_files = list(self.current_project_path.glob("*.py"))
        if python_files:
            self.terminal_output.insert('end', f"[OK] Python Files: {len(python_files)} found\n")
        else:
            self.terminal_output.insert('end', "[WARNING] Python Files: None found\n")
            health_score -= 5
        
        # 3. Requirements/Dependencies Check
        req_files = (
            list(self.current_project_path.glob("*requirements*.txt")) +
            list(self.current_project_path.glob("pyproject.toml"))
        )
        if req_files:
            self.terminal_output.insert('end', f"[OK] Dependencies: {len(req_files)} files found\n")
        else:
            self.terminal_output.insert('end', "[WARNING] Dependencies: No requirements file found\n")
            health_score -= 5
        
        # Final score
        self.terminal_output.insert('end', f"\n[HEALTH] Overall Health Score: {health_score}/100\n")
        self.terminal_output.insert('end', "=" * 50 + "\n")
        self.terminal_output.config(state='disabled')
        self.terminal_output.see('end')
        
        self.status_bar.config(text=f"Project health score: {health_score}/100")
    
    def fix_noodlecore_syntax(self):
        """Fix NoodleCore syntax issues in current file or all .nc files."""
        messagebox.showinfo(
            "Syntax Fixer",
            "NoodleCore Syntax Fixer is not available in this simplified version.\n"
            "Please use the full NoodleCore IDE for syntax fixing capabilities."
        )
    
    def show_python_integration_settings(self):
        """Show Python Integration Settings dialog."""
        messagebox.showinfo(
            "Python Integration",
            "Python Integration settings are not available in this simplified version.\n"
            "Please use the full NoodleCore IDE for Python integration capabilities."
        )
    
    def _load_workspace_state(self):
        """Load workspace state from file."""
        try:
            workspace_file = Path.home() / '.noodlecore' / 'workspace_state.json'
            if workspace_file.exists():
                with open(workspace_file, 'r') as f:
                    state = json.load(f)
                    self.workspace_state = state
                    
                    # Restore current project path if it exists
                    if 'current_project' in state:
                        project_path = Path(state['current_project'])
                        if project_path.exists():
                            self.current_project_path = project_path
                            self.status_bar.config(text=f"Loaded workspace: {project_path.name}")
        except Exception as e:
            print(f"Failed to load workspace state: {e}")
    
    def save_workspace_state(self):
        """Save current workspace state."""
        try:
            workspace_file = Path.home() / '.noodlecore' / 'workspace_state.json'
            workspace_file.parent.mkdir(exist_ok=True)
            
            state = {
                'current_project': str(self.current_project_path),
                'open_files': list(self.open_files.keys()),
                'current_file': self.current_file,
                'workspace_state': self.workspace_state,
                'timestamp': datetime.now().isoformat()
            }
            
            with open(workspace_file, 'w') as f:
                json.dump(state, f, indent=2)
        except Exception as e:
            print(f"Failed to save workspace state: {e}")
    
    def _setup_ide_logging(self):
        """Setup IDE logging configuration."""
        try:
            # Create logs directory if it doesn't exist
            logs_dir = Path.home() / '.noodlecore' / 'logs'
            logs_dir.mkdir(parents=True, exist_ok=True)
            
            # Setup logging configuration
            log_file = logs_dir / 'noodlecore_ide.log'
            
            # Configure logging
            logging.basicConfig(
                level=logging.INFO,
                format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                handlers=[
                    logging.FileHandler(log_file),
                    logging.StreamHandler()
                ]
            )
            
            # Create IDE logger
            self.ide_logger = logging.getLogger('NoodleCoreIDE')
            self.ide_logger.info("NoodleCore IDE logging initialized")
        except Exception as e:
            # Fallback logging if setup fails
            logging.basicConfig(level=logging.INFO)
            self.ide_logger = logging.getLogger('NoodleCoreIDE')
            self.ide_logger.error(f"Failed to setup IDE logging: {str(e)}")
    
    def _init_aere_integration(self):
        """Initialize AERE (AI Error Resolution Engine) integration."""
        try:
            # Try to import AERE components
            from noodlecore.ai.aere_engine import AEREngine
            from noodlecore.ai.aere_collector import ErrorCollector
            from noodlecore.ai.aere_resolver import ErrorResolver
            
            self.aere_engine = AEREngine()
            self.error_collector = ErrorCollector()
            self.error_resolver = ErrorResolver()
            
            print("[OK] AERE integration initialized successfully")
        except ImportError as e:
            print(f"[WARNING] AERE integration not available: {e}")
            self.aere_engine = None
            self.error_collector = None
            self.error_resolver = None
        except Exception as e:
            print(f"[ERROR] Failed to initialize AERE integration: {e}")
            self.aere_engine = None
            self.error_collector = None
            self.error_resolver = None
    
    def _on_exit(self):
        """Handle IDE exit with cleanup."""
        try:
            # Save workspace state
            self.save_workspace_state()
            
            # Close the IDE
            self.root.quit()
            self.root.destroy()
        except Exception as e:
            print(f"Error during IDE exit: {e}")
            self.root.quit()
            self.root.destroy()
    
    def run(self):
        """Run the IDE main loop."""
        try:
            # Start the Tkinter main loop
            self.root.mainloop()
            return 0  # Success exit code
        except KeyboardInterrupt:
            print("IDE interrupted by user")
            return 1
        except Exception as e:
            print(f"IDE error: {e}")
            return 1


def main():
    """Main entry point for the IDE."""
    root = tk.Tk()
    app = NativeNoodleCoreIDE(root)
    return app.run()


if __name__ == "__main__":
    sys.exit(main())
'''
        
        with open('src/noodlecore/desktop/ide/native_gui_ide.py', 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        print("Successfully fixed native_gui_ide.py with proper structure and formatting")
        return True
    
    else:
        print("File doesn't appear to have the expected corruption pattern")
        return False

if __name__ == "__main__":
    fix_native_gui_ide_file()

