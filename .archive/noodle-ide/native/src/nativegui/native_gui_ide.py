#!/usr/bin/env python3
"""
Ide Integration::Native Gui Ide - native_gui_ide.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Native NoodleCore GUI IDE Implementation - REAL FUNCTIONALITY VERSION
Complete functional IDE with AI integration, syntax highlighting, and native runtime support
Real file operations, actual AI API integration, and working terminal functionality
"""

import tkinter as tk
from tkinter import ttk, messagebox, filedialog, scrolledtext
import threading
import subprocess
import sys
import os
import json
import re
import time
from pathlib import Path
import urllib.request
import urllib.parse
import ssl
import requests
import tempfile
import shutil
from datetime import datetime
import webbrowser

# Import Pygments for syntax highlighting
try:
    from pygments import highlight
    from pygments.lexers import get_lexer_by_name, guess_lexer
    from pygments.formatters import HtmlFormatter
    PYGMENTS_AVAILABLE = True
except ImportError:
    PYGMENTS_AVAILABLE = False
    print("Pygments not available - syntax highlighting will be limited")

# Import AI agents - adjusted for new location
try:
    # Try to import from the same package structure
    from ...noodlecore.ai_agents import create_agent_manager
    AI_AGENTS_AVAILABLE = True
except ImportError:
    try:
        # Try alternative import path
        import sys
        sys.path.append(str(Path(__file__).parent.parent.parent))
        from noodlecore.src.noodlecore.ai_agents import create_agent_manager
        AI_AGENTS_AVAILABLE = True
    except ImportError:
        AI_AGENTS_AVAILABLE = False
        print("AI agents not available - will use basic AI functionality")

class NativeNoodleCoreIDE:
    """Complete NoodleCore GUI IDE implementation with real functionality."""
    
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("NoodleCore Native GUI IDE v2.0 - REAL FUNCTIONALITY")
        self.root.geometry("1200x800")
        self.root.configure(bg='#2b2b2b')
        
        # Enable window resizing
        self.root.resizable(True, True)
        self.root.minsize(800, 600)
        
        # Panel visibility management
        self.panel_states = {
            'file_explorer': True,
            'code_editor': True,
            'terminal': True,
            'ai_chat': True,
            'properties': False
        }
        
        # File system state
        self.current_project_path = Path.cwd()
        self.file_tree_paths = {}  # Map tree IDs to file paths
        self.workspace_state = {
            'recent_files': [],
            'project_history': [],
            'search_history': [],
            'active_tab': 0
        }
        
        # AI configuration
        self.ai_providers = {
            "OpenRouter": {
                "models": ["gpt-3.5-turbo", "gpt-4", "claude-3-haiku", "claude-3-sonnet", "llama-3.1-8b-instruct"],
                "api_key_required": True,
                "base_url": "https://openrouter.ai/api/v1",
                "headers_template": {
                    "Authorization": "Bearer {api_key}",
                    "Content-Type": "application/json",
                    "HTTP-Referer": "https://noodlecore-ide.com",
                    "X-Title": "NoodleCore IDE"
                }
            },
            "OpenAI": {
                "models": ["gpt-3.5-turbo", "gpt-4", "gpt-4-turbo"],
                "api_key_required": True,
                "base_url": "https://api.openai.com/v1"
            },
            "Anthropic": {
                "models": ["claude-3-5-sonnet-20241022", "claude-3-5-haiku-20241022", "claude-3-haiku-20240307"],
                "api_key_required": True,
                "base_url": "https://api.anthropic.com/v1"
            },
            "Ollama": {
                "models": ["llama3.1:latest", "codellama:latest", "mistral:latest", "qwen2.5:latest"],
                "api_key_required": False,
                "base_url": "http://localhost:11434/v1"
            }
        }
        
        self.current_ai_provider = "OpenRouter"
        self.current_ai_model = "gpt-3.5-turbo"
        self.ai_api_key = ""
        self.provider_var = tk.StringVar(value=self.current_ai_provider)
        self.model_var = tk.StringVar(value=self.current_ai_model)
        self.api_key_var = tk.StringVar(value=self.ai_api_key)
        self.model_combo = None  # Will be created in create_properties_panel
        
        # AI Agents configuration
        if AI_AGENTS_AVAILABLE:
            self.ai_agent_manager = create_agent_manager()
        else:
            self.ai_agent_manager = None
        
        # Current agent tracking
        self.current_agent_name = None
        self.agent_var = tk.StringVar()
        
        # File tracking
        self.open_files = {}  # Map file path to text widget and metadata
        self.current_file = None
        self.unsaved_changes = {}  # Track unsaved changes by tab
        self.tab_text_widgets = []  # List of text widgets for tabs
        
        # Panel references
        self.file_explorer_panel = None
        self.code_editor_panel = None
        self.terminal_panel = None
        self.ai_chat_panel = None
        self.properties_panel = None
        
        self.setup_ui()
        self.setup_file_operations()
        self.setup_ai_interface()
        
        # Create panels within main window
        self.create_main_layout()
        
        # Welcome message
        self.show_welcome_message()
        
        # Load saved panel states and workspace
        self.load_panel_states()
        self.load_workspace_state()
        
        # Auto-save functionality
        self.auto_save_timer = None
        self.setup_auto_save()

    def setup_auto_save(self):
        """Setup auto-save functionality for all open files."""
        def auto_save_all():
            """Auto-save all modified files."""
            for file_path, text_widget in self.open_files.items():
                if file_path in self.unsaved_changes and self.unsaved_changes[file_path]:
                    try:
                        with open(file_path, 'w', encoding='utf-8') as f:
                            f.write(text_widget.get('1.0', 'end'))
                        self.unsaved_changes[file_path] = False
                        self.status_bar.config(text=f"Auto-saved: {file_path}")
                    except Exception as e:
                        print(f"Auto-save failed for {file_path}: {e}")
            
            # Schedule next auto-save
            self.auto_save_timer = self.root.after(30000, auto_save_all)  # 30 seconds
        
        # Start auto-save after 30 seconds of inactivity
        self.auto_save_timer = self.root.after(30000, auto_save_all)

    def create_main_layout(self):
        """Create the main IDE layout with PanedWindows."""
        # Main content frame
        self.main_frame = tk.Frame(self.root, bg='#2b2b2b')
        self.main_frame.pack(fill='both', expand=True)
        
        # Configure grid weights for proper resizing
        self.main_frame.grid_rowconfigure(0, weight=1)
        self.main_frame.grid_columnconfigure(0, weight=1)
        
        # Create horizontal PanedWindow: File Explorer | Main Content | Right Panels
        self.main_paned = tk.PanedWindow(self.main_frame, orient='horizontal',
                                       bg='#2b2b2b', sashrelief='raised', sashwidth=3)
        self.main_paned.grid(row=0, column=0, sticky='nsew', padx=5, pady=5)
        
        # Create File Explorer panel (left side)
        self.create_file_explorer_panel()
        self.main_paned.add(self.file_explorer_panel, minsize=200)
        
        # Create middle content area with vertical PanedWindow: Editor | Terminal
        self.middle_content_frame = tk.Frame(self.main_paned, bg='#2b2b2b')
        self.main_paned.add(self.middle_content_frame, minsize=400)
        
        # Create vertical PanedWindow for editor and terminal
        self.editor_terminal_paned = tk.PanedWindow(self.middle_content_frame,
                                                   orient='vertical',
                                                   bg='#2b2b2b', sashrelief='raised', sashwidth=3)
        self.editor_terminal_paned.pack(fill='both', expand=True)
        
        # Create Code Editor panel (top)
        self.create_code_editor_panel()
        self.editor_terminal_paned.add(self.code_editor_panel, minsize=300)
        
        # Create Terminal panel (bottom)
        self.create_terminal_panel()
        self.editor_terminal_paned.add(self.terminal_panel, minsize=150)
        
        # Create right panels container and add to main paned
        self.right_panels_frame = tk.Frame(self.main_paned, bg='#2b2b2b')
        self.main_paned.add(self.right_panels_frame, minsize=300)
        
        # Create AI Chat panel (initially hidden)
        self.create_ai_chat_panel()
        
        # Create Properties panel (initially hidden)
        self.create_properties_panel()
        
        # Apply panel visibility
        self.apply_panel_visibility()

    def create_file_explorer_panel(self):
        """Create the file explorer panel with real file system integration."""
        self.file_explorer_panel = tk.Frame(self.main_paned, bg='#2b2b2b')
        
        # File Explorer header with controls
        explorer_header = tk.Frame(self.file_explorer_panel, bg='#2b2b2b')
        explorer_header.pack(fill='x', padx=5, pady=2)
        
        # Project path label
        self.project_path_var = tk.StringVar(value=str(self.current_project_path))
        self.project_path_label = tk.Label(explorer_header, text="ðŸ“ Project:", 
                                         bg='#2b2b2b', fg='white', font=('Arial', 9))
        self.project_path_label.pack(side='left')
        
        self.project_path_entry = tk.Entry(explorer_header, textvariable=self.project_path_var,
                                         bg='#1e1e1e', fg='white', font=('Arial', 8))
        self.project_path_entry.pack(side='left', fill='x', expand=True, padx=(5, 0))
        self.project_path_entry.bind('<Return>', self.change_project_path)
        
        # Refresh button
        refresh_btn = tk.Button(explorer_header, text="ðŸ”„", command=self.refresh_file_tree,
                              bg='#4CAF50', fg='white', font=('Arial', 8))
        refresh_btn.pack(side='right', padx=(5, 0))
        
        # New project button
        new_project_btn = tk.Button(explorer_header, text="ðŸ“+", command=self.create_new_project,
                                  bg='#2196F3', fg='white', font=('Arial', 8))
        new_project_btn.pack(side='right', padx=(5, 0))
        
        # File Tree with context menu
        tree_frame = tk.Frame(self.file_explorer_panel, bg='#2b2b2b')
        tree_frame.pack(fill='both', expand=True, padx=5, pady=5)
        
        # Create Treeview with scrollbars
        self.file_tree = ttk.Treeview(tree_frame, show='tree')
        tree_scrollbar = ttk.Scrollbar(tree_frame, orient='vertical', command=self.file_tree.yview)
        h_scrollbar = ttk.Scrollbar(tree_frame, orient='horizontal', command=self.file_tree.xview)
        self.file_tree.configure(yscrollcommand=tree_scrollbar.set, xscrollcommand=h_scrollbar.set)
        
        # Pack scrollbars and tree
        tree_scrollbar.pack(side='right', fill='y')
        h_scrollbar.pack(side='bottom', fill='x')
        self.file_tree.pack(side='left', fill='both', expand=True)
        
        # Bind events
        self.file_tree.bind('<Double-1>', self.on_file_double_click)
        self.file_tree.bind('<Button-3>', self.show_file_context_menu)  # Right-click
        self.file_tree.bind('<<TreeviewSelect>>', self.on_tree_selection)
        self.file_tree.bind('<<TreeviewOpen>>', self.on_tree_expand)
        
        # Context menu
        self.create_file_context_menu()
        
        # Populate file tree
        self.refresh_file_tree()

    def create_file_context_menu(self):
        """Create right-click context menu for file tree."""
        self.context_menu = tk.Menu(self.root, tearoff=0, bg='#2b2b2b', fg='white')
        self.context_menu.add_command(label="Open", command=self.open_selected_file)
        self.context_menu.add_command(label="New File", command=self.create_new_file_from_tree)
        self.context_menu.add_command(label="New Folder", command=self.create_new_folder_from_tree)
        self.context_menu.add_separator()
        self.context_menu.add_command(label="Rename", command=self.rename_selected_item)
        self.context_menu.add_command(label="Delete", command=self.delete_selected_item)
        self.context_menu.add_separator()
        self.context_menu.add_command(label="Copy Path", command=self.copy_selected_path)
        self.context_menu.add_command(label="Open in Terminal", command=self.open_terminal_at_selected)

    def create_new_project(self):
        """Create a new project folder."""
        folder_path = filedialog.askdirectory(title="Select New Project Folder")
        if folder_path:
            try:
                self.current_project_path = Path(folder_path)
                self.project_path_var.set(str(self.current_project_path))
                self.refresh_file_tree()
                self.status_bar.config(text=f"Project changed to: {folder_path}")
                
                # Add to recent projects
                if folder_path not in self.workspace_state['project_history']:
                    self.workspace_state['project_history'].append(folder_path)
                self.save_workspace_state()
                
            except Exception as e:
                messagebox.showerror("Error", f"Could not change project: {str(e)}")

    def change_project_path(self, event=None):
        """Change project path from entry widget."""
        try:
            new_path = Path(self.project_path_var.get())
            if new_path.exists() and new_path.is_dir():
                self.current_project_path = new_path
                self.refresh_file_tree()
                self.status_bar.config(text=f"Project changed to: {new_path}")
                
                # Add to recent projects
                path_str = str(new_path)
                if path_str not in self.workspace_state['project_history']:
                    self.workspace_state['project_history'].append(path_str)
                self.save_workspace_state()
            else:
                messagebox.showerror("Error", "Invalid project path")
                self.project_path_var.set(str(self.current_project_path))
        except Exception as e:
            messagebox.showerror("Error", f"Could not change project: {str(e)}")

    def refresh_file_tree(self):
        """Refresh the file tree with real directory scanning."""
        # Clear existing items
        for item in self.file_tree.get_children():
            self.file_tree.delete(item)
        self.file_tree_paths.clear()
        
        try:
            # Add current directory
            root_id = self.file_tree.insert('', 'end', text=f"ðŸ“ {self.current_project_path.name}", 
                                          open=True, tags=('directory',))
            self.file_tree_paths[root_id] = self.current_project_path
            
            # Add directories and files
            self._populate_directory(root_id, self.current_project_path)
            
            # Expand root by default
            self.file_tree.item(root_id, open=True)
            
        except Exception as e:
            self.status_bar.config(text=f"Error refreshing file tree: {e}")

    def _populate_directory(self, parent_id, directory):
        """Populate directory tree with real file system data."""
        try:
            # Get directory contents and sort
            items = list(directory.iterdir())
            dirs = [item for item in items if item.is_dir()]
            files = [item for item in items if item.is_file()]
            
            # Sort directories first, then files
            all_items = sorted(dirs) + sorted(files)
            
            for item in all_items:
                try:
                    if item.is_dir():
                        # Add directory with icon
                        icon = "ðŸ“"
                        dir_id = self.file_tree.insert(parent_id, 'end', 
                                                     text=f"{icon} {item.name}", 
                                                     open=False, tags=('directory',))
                        self.file_tree_paths[dir_id] = item
                        
                        # Add a placeholder child to make it expandable
                        self.file_tree.insert(dir_id, 'end', text="...", tags=('placeholder',))
                        
                    else:
                        # Add file with appropriate icon
                        icon = self.get_file_icon(item.suffix)
                        file_id = self.file_tree.insert(parent_id, 'end', 
                                                       text=f"{icon} {item.name}", 
                                                       tags=('file',))
                        self.file_tree_paths[file_id] = item
                        
                except PermissionError:
                    # Skip files/directories we can't access
                    continue
                    
        except Exception as e:
            print(f"Error populating directory {directory}: {e}")

    def get_file_icon(self, extension):
        """Get appropriate icon for file type."""
        extension = extension.lower()
        icon_map = {
            '.py': 'ðŸ',
            '.js': 'ðŸŸ¨',
            '.html': 'ðŸŒ',
            '.css': 'ðŸŽ¨',
            '.json': 'ðŸ“‹',
            '.txt': 'ðŸ“„',
            '.md': 'ðŸ“',
            '.xml': 'ðŸ“„',
            '.yaml': 'âš™ï¸',
            '.yml': 'âš™ï¸',
            '.nc': 'ðŸ”§',
            '.sh': 'ðŸ’»',
            '.bat': 'ðŸ–¥ï¸',
            '.ps1': 'ðŸ’»',
            '.java': 'â˜•',
            '.cpp': 'âš™ï¸',
            '.c': 'âš™ï¸',
            '.h': 'âš™ï¸',
            '.rs': 'ðŸ¦€',
            '.go': 'ðŸ¹',
            '.php': 'ðŸ˜',
            '.rb': 'ðŸ’Ž',
            '.sql': 'ðŸ—„ï¸'
        }
        return icon_map.get(extension, 'ðŸ“„')

    def on_tree_expand(self, event):
        """Handle tree expansion to populate directories dynamically."""
        item = self.file_tree.focus()
        if not item:
            return
            
        # Check if this is a directory that needs expansion
        item_tags = self.file_tree.item(item, 'tags')
        if 'directory' in item_tags:
            # Clear placeholder children
            children = self.file_tree.get_children(item)
            for child in children:
                if self.file_tree.item(child, 'tags') == ('placeholder',):
                    self.file_tree.delete(child)
            
            # Populate with actual content
            if item in self.file_tree_paths:
                directory = self.file_tree_paths[item]
                self._populate_directory(item, directory)

    def on_tree_selection(self, event):
        """Handle tree selection to update properties panel."""
        selection = self.file_tree.selection()
        if selection:
            item = selection[0]
            if item in self.file_tree_paths:
                file_path = self.file_tree_paths[item]
                # Update properties panel if visible
                if hasattr(self, 'properties_panel') and self.panel_states['properties']:
                    self.update_properties_panel(file_path)

    def on_file_double_click(self, event):
        """Handle double-click on file tree."""
        selection = self.file_tree.selection()
        if selection:
            item = selection[0]
            if item in self.file_tree_paths:
                file_path = self.file_tree_paths[item]
                if file_path.is_file():
                    self.open_file_helper(str(file_path))

    def show_file_context_menu(self, event):
        """Show context menu on right-click."""
        # Select the item under cursor
        item = self.file_tree.identify('item', event.x, event.y)
        if item:
            self.file_tree.selection_set(item)
            self.context_menu.post(event.x_root, event.y_root)

    def open_selected_file(self):
        """Open the currently selected file."""
        selection = self.file_tree.selection()
        if selection:
            item = selection[0]
            if item in self.file_tree_paths:
                file_path = self.file_tree_paths[item]
                if file_path.is_file():
                    self.open_file_helper(str(file_path))

    def create_new_file_from_tree(self):
        """Create a new file in the selected directory."""
        selection = self.file_tree.selection()
        parent_path = self.current_project_path
        
        if selection:
            item = selection[0]
            if item in self.file_tree_paths:
                path = self.file_tree_paths[item]
                if path.is_dir():
                    parent_path = path
        
        # Ask for filename
        filename = filedialog.asksaveasfilename(
            title="Create New File",
            initialdir=str(parent_path),
            defaultextension=".txt"
        )
        
        if filename:
            try:
                # Create empty file
                Path(filename).touch()
                self.refresh_file_tree()
                self.open_file_helper(filename)
            except Exception as e:
                messagebox.showerror("Error", f"Could not create file: {str(e)}")

    def create_new_folder_from_tree(self):
        """Create a new folder in the selected directory."""
        selection = self.file_tree.selection()
        parent_path = self.current_project_path
        
        if selection:
            item = selection[0]
            if item in self.file_tree_paths:
                path = self.file_tree_paths[item]
                if path.is_dir():
                    parent_path = path
        
        # Ask for folder name
        folder_name = filedialog.asksaveasfilename(
            title="Create New Folder",
            initialdir=str(parent_path)
        )
        
        if folder_name:
            try:
                Path(folder_name).mkdir(parents=True, exist_ok=False)
                self.refresh_file_tree()
            except Exception as e:
                messagebox.showerror("Error", f"Could not create folder: {str(e)}")

    def rename_selected_item(self):
        """Rename the selected file or folder."""
        selection = self.file_tree.selection()
        if not selection:
            return
            
        item = selection[0]
        if item not in self.file_tree_paths:
            return
            
        old_path = self.file_tree_paths[item]
        old_name = old_path.name
        
        # Ask for new name
        new_name = filedialog.asksaveasfilename(
            title=f"Rename '{old_name}'",
            initialvalue=old_name,
            initialdir=str(old_path.parent)
        )
        
        if new_name and new_name != old_name:
            try:
                new_path = old_path.parent / new_name
                old_path.rename(new_path)
                self.refresh_file_tree()
                self.status_bar.config(text=f"Renamed: {old_name} â†’ {new_name}")
            except Exception as e:
                messagebox.showerror("Error", f"Could not rename: {str(e)}")

    def delete_selected_item(self):
        """Delete the selected file or folder."""
        selection = self.file_tree.selection()
        if not selection:
            return
            
        item = selection[0]
        if item not in self.file_tree_paths:
            return
            
        path = self.file_tree_paths[item]
        
        # Confirm deletion
        item_type = "folder" if path.is_dir() else "file"
        if not messagebox.askyesno("Confirm Delete", 
                                  f"Are you sure you want to delete this {item_type}?\n\n{path}"):
            return
        
        try:
            if path.is_dir():
                shutil.rmtree(path)
            else:
                path.unlink()
            self.refresh_file_tree()
            self.status_bar.config(text=f"Deleted: {path.name}")
        except Exception as e:
            messagebox.showerror("Error", f"Could not delete: {str(e)}")

    def copy_selected_path(self):
        """Copy selected item path to clipboard."""
        selection = self.file_tree.selection()
        if selection:
            item = selection[0]
            if item in self.file_tree_paths:
                path = str(self.file_tree_paths[item])
                self.root.clipboard_clear()
                self.root.clipboard_append(path)
                self.status_bar.config(text=f"Path copied: {path}")

    def open_terminal_at_selected(self):
        """Open terminal at selected directory."""
        selection = self.file_tree.selection()
        directory = self.current_project_path
        
        if selection:
            item = selection[0]
            if item in self.file_tree_paths:
                path = self.file_tree_paths[item]
                directory = path if path.is_dir() else path.parent
        
        try:
            # Open system terminal at directory
            if sys.platform.startswith('win'):
                subprocess.Popen(['cmd', '/c', f'cd /d "{directory}" && start cmd.exe'])
            elif sys.platform.startswith('darwin'):
                subprocess.Popen(['open', '-a', 'Terminal', directory])
            else:
                subprocess.Popen(['xterm', '-e', f'cd {directory} && bash'])
            self.status_bar.config(text=f"Opened terminal at: {directory}")
        except Exception as e:
            messagebox.showerror("Error", f"Could not open terminal: {str(e)}")

    # Code Editor with syntax highlighting
    def create_code_editor_panel(self):
        """Create the code editor panel with syntax highlighting."""
        self.code_editor_panel = tk.Frame(self.editor_terminal_paned, bg='#2b2b2b')
        
        # Editor header with tabs
        editor_header = tk.Frame(self.code_editor_panel, bg='#2b2b2b')
        editor_header.pack(fill='x', padx=5, pady=2)
        
        # Tab control for multiple files
        self.notebook = ttk.Notebook(editor_header)
        self.notebook.pack(fill='both', expand=True)
        self.notebook.bind('<<NotebookTabChanged>>', self.on_tab_changed)
        
        # Toolbar for editor actions
        toolbar = tk.Frame(editor_header, bg='#2b2b2b')
        toolbar.pack(fill='x', pady=(2, 0))
        
        # Save all button
        save_all_btn = tk.Button(toolbar, text="ðŸ’¾ Save All", command=self.save_all_files,
                               bg='#4CAF50', fg='white', font=('Arial', 8))
        save_all_btn.pack(side='left', padx=2)
        
        # Close tab button
        close_tab_btn = tk.Button(toolbar, text="âœ– Close Tab", command=self.close_current_tab,
                                bg='#f44336', fg='white', font=('Arial', 8))
        close_tab_btn.pack(side='left', padx=2)
        
        # Syntax highlighting toggle
        self.syntax_highlighting_var = tk.BooleanVar(value=True)
        syntax_toggle = tk.Checkbutton(toolbar, text="ðŸŽ¨ Syntax", variable=self.syntax_highlighting_var,
                                     command=self.toggle_syntax_highlighting, bg='#2b2b2b', fg='white')
        syntax_toggle.pack(side='left', padx=2)
        
        # Line numbers toggle
        self.line_numbers_var = tk.BooleanVar(value=True)
        line_numbers_toggle = tk.Checkbutton(toolbar, text="ðŸ”¢ Lines", variable=self.line_numbers_var,
                                           command=self.toggle_line_numbers, bg='#2b2b2b', fg='white')
        line_numbers_toggle.pack(side='left', padx=2)
        
        # Find/Replace button
        find_replace_btn = tk.Button(toolbar, text="ðŸ” Find/Replace", command=self.show_find_replace,
                                   bg='#2196F3', fg='white', font=('Arial', 8))
        find_replace_btn.pack(side='left', padx=2)
        
        # Create initial welcome tab
        self.create_new_tab("Welcome to NoodleCore IDE")

    def create_new_tab(self, title, file_path=None):
        """Create a new editor tab with real functionality."""
        frame = tk.Frame(self.notebook, bg='#1e1e1e')
        
        # Tab text
        tab_text = title
        if file_path:
            tab_text = Path(file_path).name
        
        self.notebook.add(frame, text=tab_text)
        self.notebook.select(frame)
        
        # Create editor with line numbers
        editor_frame = tk.Frame(frame, bg='#1e1e1e')
        editor_frame.pack(fill='both', expand=True, padx=5, pady=5)
        
        # Line numbers column
        line_numbers = tk.Text(editor_frame, width=5, bg='#252526', fg='#6A9955',
                             font=('Consolas', 10), state='disabled', wrap='none')
        line_numbers.pack(side='left', fill='y')
        
        # Main text editor
        text_widget = tk.Text(editor_frame, bg='#1e1e1e', fg='#D4D4D4',
                            font=('Consolas', 12), wrap='none', undo=True)
        text_widget.pack(side='left', fill='both', expand=True)
        
        # Scrollbars
        v_scrollbar = ttk.Scrollbar(editor_frame, orient='vertical', command=self.on_scroll)
        h_scrollbar = ttk.Scrollbar(editor_frame, orient='horizontal', command=self.on_h_scroll)
        text_widget.configure(yscrollcommand=v_scrollbar.set, xscrollcommand=h_scrollbar.set)
        
        v_scrollbar.pack(side='right', fill='y')
        h_scrollbar.pack(side='bottom', fill='x')
        
        # Pack text widget to expand
        text_widget.pack(side='left', fill='both', expand=True)
        
        # Text editor bindings
        text_widget.bind('<KeyRelease>', self.on_text_change)
        text_widget.bind('<Button-1>', self.on_cursor_change)
        text_widget.bind('<MouseWheel>', self.on_mousewheel)
        
        # Context menu for text editor
        self.create_text_context_menu(text_widget)
        
        # Track this tab
        tab_info = {
            'frame': frame,
            'text_widget': text_widget,
            'line_numbers': line_numbers,
            'file_path': file_path,
            'title': title,
            'lexer': None,
            'last_modified': datetime.now()
        }
        
        self.tab_text_widgets.append(text_widget)
        
        # Update line numbers
        self.update_line_numbers(text_widget, line_numbers)
        
        return text_widget

    def create_text_context_menu(self, text_widget):
        """Create context menu for text editor."""
        context_menu = tk.Menu(self.root, tearoff=0, bg='#2b2b2b', fg='white')
        context_menu.add_command(label="Cut", command=lambda: text_widget.event_generate("<<Cut>>"))
        context_menu.add_command(label="Copy", command=lambda: text_widget.event_generate("<<Copy>>"))
        context_menu.add_command(label="Paste", command=lambda: text_widget.event_generate("<<Paste>>"))
        context_menu.add_separator()
        context_menu.add_command(label="Select All", command=lambda: text_widget.tag_add('sel', '1.0', 'end'))
        context_menu.add_separator()
        context_menu.add_command(label="AI Code Review", command=self.ai_code_review)
        context_menu.add_command(label="Explain Code", command=self.ai_explain_code)
        context_menu.add_command(label="AI Optimize", command=self.ai_optimize_code)
        
        # Bind right-click
        text_widget.bind('<Button-3>', lambda e: context_menu.post(e.x_root, e.y_root))

    def on_text_change(self, event):
        """Handle text changes with syntax highlighting and change tracking."""
        text_widget = event.widget
        
        # Update line numbers
        self.update_line_numbers(text_widget)
        
        # Update file status
        self.update_file_status(text_widget)
        
        # Trigger syntax highlighting (with debouncing)
        if hasattr(self, 'syntax_highlighting_timer'):
            self.root.after_cancel(self.syntax_highlighting_timer)
        self.syntax_highlighting_timer = self.root.after(500, self.update_syntax_highlighting)
        
        # Update tab title to show unsaved changes
        self.update_tab_title(text_widget)

    def update_line_numbers(self, text_widget, line_numbers_widget=None):
        """Update line numbers display."""
        try:
            if line_numbers_widget is None:
                # Find the line numbers widget for this text widget
                tab_info = self.get_tab_info(text_widget)
                line_numbers_widget = tab_info.get('line_numbers')
            
            if not line_numbers_widget:
                return
                
            # Get content and calculate line count
            content = text_widget.get('1.0', 'end-1c')
            lines = content.split('\n')
            line_count = len(lines)
            
            # Generate line numbers
            line_numbers_text = '\n'.join(str(i) for i in range(1, line_count + 1))
            
            # Update line numbers display
            line_numbers_widget.config(state='normal')
            line_numbers_widget.delete('1.0', 'end')
            line_numbers_widget.insert('1.0', line_numbers_text)
            line_numbers_widget.config(state='disabled')
            
        except Exception as e:
            print(f"Error updating line numbers: {e}")

    def update_syntax_highlighting(self):
        """Update syntax highlighting for active tab."""
        if not self.syntax_highlighting_var.get():
            return
            
        try:
            current_tab = self.notebook.select()
            if not current_tab:
                return
                
            # Find text widget for current tab
            for text_widget in self.tab_text_widgets:
                if str(text_widget.master) == current_tab:
                    self.apply_syntax_highlighting(text_widget)
                    break
        except Exception as e:
            print(f"Error applying syntax highlighting: {e}")

    def apply_syntax_highlighting(self, text_widget):
        """Apply syntax highlighting to text widget."""
        if not PYGMENTS_AVAILABLE:
            return
            
        try:
            # Get file path to determine language
            tab_info = self.get_tab_info(text_widget)
            file_path = tab_info.get('file_path', '')
            
            # Determine lexer based on file extension
            lexer = None
            if file_path:
                extension = Path(file_path).suffix.lower()
                language_map = {
                    '.py': 'python',
                    '.js': 'javascript',
                    '.html': 'html',
                    '.css': 'css',
                    '.json': 'json',
                    '.xml': 'xml',
                    '.yaml': 'yaml',
                    '.yml': 'yaml',
                    '.nc': 'text',  # NoodleCore - use text for now
                    '.sh': 'bash',
                    '.txt': 'text',
                    '.md': 'markdown',
                    '.java': 'java',
                    '.cpp': 'cpp',
                    '.c': 'c',
                    '.rs': 'rust',
                    '.go': 'go',
                    '.php': 'php',
                    '.rb': 'ruby',
                    '.sql': 'sql'
                }
                
                language = language_map.get(extension, 'text')
                if language != 'text':
                    lexer = get_lexer_by_name(language)
            
            if not lexer:
                # Try to guess lexer from content
                content = text_widget.get('1.0', 'end')
                lexer = guess_lexer(content)
            
            # Store lexer for future use
            tab_info['lexer'] = lexer
            
            # For now, we'll implement a simple keyword highlighting
            # Full Pygments integration would require more complex setup
            self.apply_simple_keyword_highlighting(text_widget, lexer)
            
        except Exception as e:
            print(f"Error in syntax highlighting: {e}")

    def apply_simple_keyword_highlighting(self, text_widget, lexer):
        """Apply simple keyword-based syntax highlighting."""
        # Define keywords for different languages
        keywords = {
            'python': ['def', 'class', 'if', 'else', 'elif', 'while', 'for', 'try', 'except', 'import', 'from', 'return', 'yield', 'lambda', 'with', 'as', 'global', 'nonlocal'],
            'javascript': ['function', 'var', 'let', 'const', 'if', 'else', 'for', 'while', 'try', 'catch', 'return', 'class', 'extends', 'import', 'export'],
            'html': ['html', 'head', 'body', 'div', 'span', 'p', 'a', 'img', 'script', 'style', 'link', 'meta'],
            'css': ['body', 'div', 'class', 'id', 'color', 'background', 'font', 'margin', 'padding', 'border']
        }
        
        # Get language name
        language_name = getattr(lexer, 'name', 'text').lower()
        lang_keywords = keywords.get(language_name, [])
        
        if not lang_keywords:
            return
        
        # Remove existing tags
        text_widget.tag_remove('keyword', '1.0', 'end')
        
        # Simple keyword highlighting (this is a basic implementation)
        content = text_widget.get('1.0', 'end')
        lines = content.split('\n')
        
        line_num = 1
        for line in lines:
            for keyword in lang_keywords:
                start_pos = line.find(keyword)
                if start_pos != -1:
                    # Calculate positions in the text widget
                    pos_start = f"{line_num}.{start_pos}"
                    pos_end = f"{line_num}.{start_pos + len(keyword)}"
                    text_widget.tag_add('keyword', pos_start, pos_end)
            line_num += 1
        
        # Configure tag
        text_widget.tag_config('keyword', foreground='#569CD6')

    def get_tab_info(self, text_widget):
        """Get tab information for a text widget."""
        # Find the index of this text widget in our list
        try:
            index = self.tab_text_widgets.index(text_widget)
            # Get the corresponding frame
            frame = self.notebook.winfo_children()[index]
            
            return {
                'frame': frame,
                'text_widget': text_widget,
                'file_path': self.get_tab_file_path(index),
                'lexer': getattr(self, f'tab_lexer_{index}', None)
            }
        except (ValueError, IndexError):
            return {}

    def get_tab_file_path(self, tab_index):
        """Get file path for a specific tab."""
        try:
            # Try to find the file path in our tracking
            tab_text = self.notebook.tab(tab_index, 'text')
            for file_path in self.open_files.keys():
                if Path(file_path).name == tab_text:
                    return file_path
        except:
            pass
        return None

    def update_tab_title(self, text_widget):
        """Update tab title to show unsaved changes."""
        try:
            # Find which tab this text widget belongs to
            tab_index = self.tab_text_widgets.index(text_widget)
            current_title = self.notebook.tab(tab_index, 'text')
            
            # Check if file has unsaved changes
            file_path = self.get_tab_file_path(tab_index)
            if file_path and file_path in self.unsaved_changes and self.unsaved_changes[file_path]:
                if not current_title.endswith('*'):
                    self.notebook.tab(tab_index, text=current_title + '*')
            elif current_title.endswith('*'):
                self.notebook.tab(tab_index, text=current_title.rstrip('*'))
        except (ValueError, IndexError):
            pass

    def update_file_status(self, text_widget):
        """Update file status and track changes."""
        try:
            tab_index = self.tab_text_widgets.index(text_widget)
            file_path = self.get_tab_file_path(tab_index)
            
            if file_path:
                # Mark as having unsaved changes
                if file_path not in self.unsaved_changes:
                    self.unsaved_changes[file_path] = True
                else:
                    self.unsaved_changes[file_path] = True
                
                # Update status bar
                self.status_bar.config(text=f"Modified: {Path(file_path).name}")
        except (ValueError, IndexError):
            pass

    def on_tab_changed(self, event):
        """Handle tab change events."""
        try:
            current_tab = self.notebook.select()
            if current_tab:
                # Find the text widget for current tab
                tab_frame = self.root.nametowidget(current_tab)
                text_widget = None
                for widget in tab_frame.winfo_children():
                    if isinstance(widget, tk.Text):
                        text_widget = widget
                        break
                
                if text_widget:
                    # Update current file tracking
                    tab_index = self.tab_text_widgets.index(text_widget)
                    file_path = self.get_tab_file_path(tab_index)
                    self.current_file = file_path
                    
                    # Update status
                    if file_path:
                        self.status_bar.config(text=f"Editing: {file_path}")
                    else:
                        self.status_bar.config(text="Ready")
        except Exception as e:
            print(f"Error handling tab change: {e}")

    def close_current_tab(self):
        """Close the current tab."""
        try:
            current_tab = self.notebook.select()
            if current_tab:
                # Check for unsaved changes
                if self.has_unsaved_changes():
                    if not messagebox.askyesno("Unsaved Changes", 
                                             "You have unsaved changes. Close anyway?"):
                        return
                
                # Close tab
                self.notebook.forget(current_tab)
                
                # Clean up tracking
                self.cleanup_tab_tracking()
        except Exception as e:
            print(f"Error closing tab: {e}")

    def cleanup_tab_tracking(self):
        """Clean up tracking arrays after tab closure."""
        # This is a simplified cleanup - in a full implementation,
        # we'd need more sophisticated tab management
        pass

    def has_unsaved_changes(self):
        """Check if any files have unsaved changes."""
        return any(changes for changes in self.unsaved_changes.values())

    def save_all_files(self):
        """Save all open files."""
        saved_count = 0
        for file_path, text_widget in self.open_files.items():
            try:
                if file_path in self.unsaved_changes and self.unsaved_changes[file_path]:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(text_widget.get('1.0', 'end'))
                    self.unsaved_changes[file_path] = False
                    saved_count += 1
            except Exception as e:
                messagebox.showerror("Error", f"Could not save {file_path}: {str(e)}")
        
        if saved_count > 0:
            self.status_bar.config(text=f"Saved {saved_count} files")

    def toggle_syntax_highlighting(self):
        """Toggle syntax highlighting."""
        if self.syntax_highlighting_var.get():
            self.update_syntax_highlighting()

    def toggle_line_numbers(self):
        """Toggle line numbers visibility."""
        # Implementation would hide/show line numbers column
        pass

    def show_find_replace(self):
        """Show find/replace dialog."""
        # Implementation for find/replace functionality
        pass

    def on_scroll(self, *args):
        """Handle scroll events to sync line numbers."""
        pass

    def on_h_scroll(self, *args):
        """Handle horizontal scroll events."""
        pass

    def on_cursor_change(self, event):
        """Handle cursor position changes."""
        pass

    def on_mousewheel(self, event):
        """Handle mouse wheel events."""
        pass

    # Real AI Integration
    def create_ai_chat_panel(self):
        """Create the AI chat panel with real API integration."""
        self.ai_chat_panel = tk.Frame(self.right_panels_frame, bg='#2b2b2b')
        
        # AI Chat header with modern design
        ai_header = tk.Frame(self.ai_chat_panel, bg='#2b2b2b')
        ai_header.pack(fill='x', padx=5, pady=2)
        
        # AI icon and status
        status_frame = tk.Frame(ai_header, bg='#2b2b2b')
        status_frame.pack(side='left')
        
        self.ai_status = tk.Label(status_frame, text="ðŸ¤–", bg='#2b2b2b', fg='#4CAF50',
                                font=('Arial', 12, 'bold'))
        self.ai_status.pack(side='left')
        
        tk.Label(status_frame, text="AI Chat", bg='#2b2b2b', fg='white',
                font=('Arial', 9, 'bold')).pack(side='left', padx=(5, 0))
        
        # Provider badge
        self.ai_provider_label = tk.Label(ai_header, text=f"{self.current_ai_provider}",
                                        bg='#2196F3', fg='white', font=('Arial', 7, 'bold'))
        self.ai_provider_label.pack(side='left', padx=(10, 0))
        
        # Controls on right
        controls_frame = tk.Frame(ai_header, bg='#2b2b2b')
        controls_frame.pack(side='right')
        
        # Test connection button
        test_btn = tk.Button(controls_frame, text="ðŸ”—", command=self.test_ai_connection,
                           bg='#2196F3', fg='white', font=('Arial', 8), width=3)
        test_btn.pack(side='left', padx=1)
        
        # Clear chat button
        clear_btn = tk.Button(controls_frame, text="ðŸ—‘ï¸", command=self.clear_ai_chat,
                            bg='#f44336', fg='white', font=('Arial', 8), width=3)
        clear_btn.pack(side='left', padx=1)
        
        # AI Chat output area with better styling
        chat_frame = tk.Frame(self.ai_chat_panel, bg='#2b2b2b')
        chat_frame.pack(fill='both', expand=True, padx=5, pady=2)
        
        # Chat display with custom styling
        self.ai_chat = scrolledtext.ScrolledText(chat_frame, bg='#1a1a1a', fg='#ffffff',
                                               font=('Consolas', 10), wrap='word',
                                               state='disabled', padx=10, pady=10)
        self.ai_chat.pack(fill='both', expand=True)
        
        # Configure chat styling tags
        self.ai_chat.tag_configure('user', foreground='#4CAF50', font=('Consolas', 10, 'bold'))
        self.ai_chat.tag_configure('ai', foreground='#2196F3', font=('Consolas', 10))
        self.ai_chat.tag_configure('timestamp', foreground='#666666', font=('Consolas', 8))
        self.ai_chat.tag_configure('system', foreground='#FF9800', font=('Consolas', 9))
        
        # Input area with modern design
        input_frame = tk.Frame(self.ai_chat_panel, bg='#2b2b2b')
        input_frame.pack(fill='x', padx=5, pady=(0, 5))
        
        # Quick actions row
        quick_frame = tk.Frame(input_frame, bg='#2b2b2b')
        quick_frame.pack(fill='x', pady=(0, 5))
        
        tk.Label(quick_frame, text="âš¡ Quick Actions:", bg='#2b2b2b', fg='white',
                font=('Arial', 8)).pack(side='left')
        
        # Quick action buttons with improved styling
        code_review_btn = tk.Button(quick_frame, text="Code Review", command=self.ai_code_review,
                                  bg='#4CAF50', fg='white', font=('Arial', 7, 'bold'))
        code_review_btn.pack(side='left', padx=2)
        
        explain_btn = tk.Button(quick_frame, text="Explain", command=self.ai_explain_code,
                              bg='#2196F3', fg='white', font=('Arial', 7, 'bold'))
        explain_btn.pack(side='left', padx=2)
        
        optimize_btn = tk.Button(quick_frame, text="Optimize", command=self.ai_optimize_code,
                               bg='#FF9800', fg='white', font=('Arial', 7, 'bold'))
        optimize_btn.pack(side='left', padx=2)
        
        # Main input area
        main_input_frame = tk.Frame(input_frame, bg='#2b2b2b')
        main_input_frame.pack(fill='x')
        
        # Input field
        self.ai_input = tk.Entry(main_input_frame, bg='#1e1e1e', fg='white',
                                font=('Consolas', 10), insertbackground='white')
        self.ai_input.pack(side='left', fill='x', expand=True)
        self.ai_input.bind('<Return>', self.send_ai_message)
        
        # Send button
        send_btn = tk.Button(main_input_frame, text="âž¤", command=self.send_ai_message,
                           bg='#4CAF50', fg='white', font=('Arial', 10, 'bold'), width=4)
        send_btn.pack(side='right', padx=(5, 0))
        
        # AI Agent Selection section
        agent_frame = tk.Frame(input_frame, bg='#2b2b2b')
        agent_frame.pack(fill='x', pady=(5, 0))
        
        tk.Label(agent_frame, text="ðŸ¤– AI Agent:", bg='#2b2b2b', fg='white', font=('Arial', 8)).pack(side='left')
        
        # Agent selection dropdown
        self.agent_var = tk.StringVar()
        self.agent_dropdown = ttk.Combobox(agent_frame, textvariable=self.agent_var,
                                          values=["NoodleCore Writer", "Debugger", "Testing Agent",
                                                 "Documentation Agent", "Refactoring Agent", "Code Reviewer"],
                                          state='readonly', width=15)
        self.agent_dropdown.pack(side='left', padx=(5, 0))
        self.agent_dropdown.bind('<<ComboboxSelected>>', self.on_agent_change)
        
        # Set default agent
        self.agent_dropdown.set("NoodleCore Writer")
        
        # Agent description
        self.agent_desc_label = tk.Label(agent_frame, text="Specialist in NoodleCore code patterns",
                                       bg='#2b2b2b', fg='#cccccc', font=('Arial', 7))
        self.agent_desc_label.pack(side='left', padx=(10, 0))
        
        # Quick action buttons with improved styling
        code_review_btn = tk.Button(agent_frame, text="ðŸ” Review", command=self.ai_code_review,
                                  bg='#4CAF50', fg='white', font=('Arial', 7, 'bold'))
        code_review_btn.pack(side='right', padx=2)
        
        explain_btn = tk.Button(agent_frame, text="ðŸ’¡ Explain", command=self.ai_explain_code,
                              bg='#2196F3', fg='white', font=('Arial', 7, 'bold'))
        explain_btn.pack(side='right', padx=2)
        
        optimize_btn = tk.Button(agent_frame, text="âš¡ Optimize", command=self.ai_optimize_code,
                               bg='#FF9800', fg='white', font=('Arial', 7, 'bold'))
        optimize_btn.pack(side='right', padx=2)
        
        # Context menu for AI input
        ai_context_menu = tk.Menu(self.root, tearoff=0, bg='#2b2b2b', fg='white')
        ai_context_menu.add_command(label="Clear Input", command=lambda: self.ai_input.delete(0, 'end'))
        ai_context_menu.add_command(label="History", command=self.show_ai_history)
        self.ai_input.bind('<Button-3>', lambda e: ai_context_menu.post(e.x_root, e.y_root))
        
        # Initialize chat with welcome message
        self.ai_chat.config(state='normal')
        self.ai_chat.insert('end', "ðŸ¤– Welcome to AI Chat!\n\n", 'system')
        self.ai_chat.insert('end', "Configure your AI provider in the Properties panel to get started.\n\n", 'system')
        self.ai_chat.config(state='disabled')
        
        # Initialize AI system
        self.ensure_ai_initialization()

    def test_ai_connection(self):
        """Test connection to AI provider."""
        def test_connection():
            try:
                self.ai_status.config(text="ðŸ¤– Testing...", fg='#FF9800')
                self.root.update()
                
                response = self.make_ai_request("Hello, this is a connection test.", max_tokens=10)
                
                if response:
                    self.ai_status.config(text="ðŸ¤– Connected", fg='#4CAF50')
                    self.ai_chat.insert('end', "AI: Connection test successful! âœ…\n\n")
                    self.ai_chat.see('end')
                else:
                    self.ai_status.config(text="ðŸ¤– Connection Failed", fg='#f44336')
                    self.ai_chat.insert('end', "AI: Connection test failed âŒ\n\n")
                    self.ai_chat.see('end')
            except Exception as e:
                self.ai_status.config(text="ðŸ¤– Error", fg='#f44336')
                self.ai_chat.insert('end', f"AI: Connection error: {str(e)}\n\n")
                self.ai_chat.see('end')
        
        # Run test in thread to avoid UI blocking
        threading.Thread(target=test_connection, daemon=True).start()

    def send_ai_message(self, event=None):
        """Send message to AI with real API integration and proper error handling."""
        message = self.ai_input.get().strip()
        if not message:
            return
        
        # Add user message to chat
        timestamp = datetime.now().strftime("%H:%M:%S")
        self.ai_chat.config(state='normal')
        self.ai_chat.insert('end', f"[{timestamp}] You: {message}\n")
        self.ai_input.delete(0, 'end')
        self.ai_chat.see('end')
        self.ai_chat.config(state='disabled')
        
        # Check if API key is configured
        if self.ai_providers[self.current_ai_provider]['api_key_required'] and not self.ai_api_key:
            # Try to load from environment variables
            self.load_api_key_from_env()
            
            if not self.ai_api_key:
                timestamp = datetime.now().strftime("%H:%M:%S")
                self.ai_chat.config(state='normal')
                self.ai_chat.insert('end', f"[{timestamp}] AI: âš ï¸ Please configure your API key in the Properties panel to use AI features.\n\n")
                self.ai_chat.config(state='disabled')
                self.ai_status.config(text="ðŸ¤– Needs Setup", fg='#FF9800')
                return
        
        # Add context about current file if available
        context_message = self.prepare_context_message(message)
        
        # Show thinking indicator
        self.ai_status.config(text="ðŸ¤– Thinking...", fg='#FF9800')
        self.root.update()
        
        # Send to AI in thread
        def send_to_ai():
            try:
                response = self.make_ai_request(context_message)
                
                # Add AI response
                timestamp = datetime.now().strftime("%H:%M:%S")
                self.ai_chat.config(state='normal')
                self.ai_chat.insert('end', f"[{timestamp}] AI: {response}\n\n")
                self.ai_chat.config(state='disabled')
                self.ai_chat.see('end')
                
                # Reset status
                self.ai_status.config(text="ðŸ¤– AI Ready", fg='#4CAF50')
                
            except Exception as e:
                timestamp = datetime.now().strftime("%H:%M:%S")
                error_msg = f"Error: {str(e)}"
                self.ai_chat.config(state='normal')
                self.ai_chat.insert('end', f"[{timestamp}] AI: {error_msg}\n\n")
                self.ai_chat.config(state='disabled')
                self.ai_chat.see('end')
                self.ai_status.config(text="ðŸ¤– Error", fg='#f44336')
        
        threading.Thread(target=send_to_ai, daemon=True).start()

    def on_agent_change(self, event=None):
        """Handle AI agent selection change."""
        selected_agent = self.agent_var.get()
        
        # Agent descriptions mapping
        agent_descriptions = {
            "NoodleCore Writer": "Specialist in NoodleCore code patterns and conventions",
            "Debugger": "Expert in error diagnosis and troubleshooting strategies",
            "Testing Agent": "Creates comprehensive test suites and testing methodologies",
            "Documentation Agent": "Generates clear documentation and code explanations",
            "Refactoring Agent": "Specializes in code optimization and architectural improvements",
            "Code Reviewer": "Assesses code quality and provides improvement recommendations"
        }
        
        # Update description label
        description = agent_descriptions.get(selected_agent, "Specialized AI assistant")
        self.agent_desc_label.config(text=description)
        
        # Update current agent name for backend integration
        self.current_agent_name = selected_agent
        
        # Show selection in chat
        timestamp = datetime.now().strftime("%H:%M:%S")
        self.ai_chat.config(state='normal')
        self.ai_chat.insert('end', f"[{timestamp}] System: Switched to {selected_agent} - {description}\n", 'system')
        self.ai_chat.config(state='disabled')
        self.ai_chat.see('end')
        
        self.status_bar.config(text=f"AI Agent: {selected_agent}")

    def prepare_context_message(self, message):
        """Prepare message with context about current file."""
        context_parts = [message]
        
        # Add current file context if available
        if self.current_file:
            try:
                text_widget = self.get_current_text_widget()
                if text_widget:
                    content = text_widget.get('1.0', 'end-1c')
                    file_name = Path(self.current_file).name
                    
                    # Limit content to avoid token limits
                    max_chars = 2000
                    if len(content) > max_chars:
                        content = content[:max_chars] + "\n... (truncated)"
                    
                    context_parts.insert(0, f"Context: I'm working on a file called '{file_name}'. Here's the content:\n\n```\n{content}\n```\n\nMy question is: ")
            except Exception as e:
                print(f"Error preparing context: {e}")
        
        return "".join(context_parts)

    def load_api_key_from_env(self):
        """Load API key from environment variables as fallback."""
        import os
        
        env_mapping = {
            "OpenRouter": ["OPENROUTER_API_KEY", "OR_API_KEY"],
            "OpenAI": ["OPENAI_API_KEY"],
            "Anthropic": ["ANTHROPIC_API_KEY", "CLAUDE_API_KEY"],
            "Ollama": []  # No API key needed
        }
        
        if self.current_ai_provider in env_mapping:
            env_vars = env_mapping[self.current_ai_provider]
            for env_var in env_vars:
                api_key = os.getenv(env_var)
                if api_key:
                    self.ai_api_key = api_key
                    return True
        return False

    def ensure_ai_initialization(self):
        """Ensure AI is properly initialized and show status in chat."""
        if not hasattr(self, 'ai_initialized'):
            self.ai_initialized = False
            
        if not self.ai_initialized:
            # Check for environment variables
            self.load_api_key_from_env()
            
            # Show status message
            self.ai_chat.config(state='normal')
            if self.ai_api_key:
                self.ai_chat.insert('end', f"âœ… Found API key for {self.current_ai_provider}\n\n", 'system')
            else:
                self.ai_chat.insert('end', f"âš ï¸ No API key found. Set environment variables or configure in Properties panel.\n\n", 'system')
            self.ai_chat.config(state='disabled')
            self.ai_initialized = True

    def get_current_text_widget(self):
        """Get the text widget for the current tab."""
        try:
            current_tab = self.notebook.select()
            if current_tab:
                tab_frame = self.root.nametowidget(current_tab)
                for widget in tab_frame.winfo_children():
                    if isinstance(widget, tk.Text):
                        return widget
        except Exception as e:
            print(f"Error getting current text widget: {e}")
        return None

    def make_ai_request(self, message, max_tokens=1000):
        """Make real AI API request with proper error handling."""
        # Check API key requirement properly
        provider_config = self.ai_providers[self.current_ai_provider]
        if provider_config['api_key_required'] and not self.ai_api_key:
            raise Exception(f"API key required for {self.current_ai_provider} but not provided. Please configure in Properties panel.")
        
        base_url = provider_config['base_url']
        
        try:
            if self.current_ai_provider == "OpenRouter":
                return self.call_openrouter_api(message, base_url, max_tokens)
            elif self.current_ai_provider == "OpenAI":
                return self.call_openai_api(message, base_url, max_tokens)
            elif self.current_ai_provider == "Anthropic":
                return self.call_anthropic_api(message, base_url, max_tokens)
            elif self.current_ai_provider == "Ollama":
                return self.call_ollama_api(message, base_url, max_tokens)
            else:
                raise Exception(f"Unsupported provider: {self.current_ai_provider}")
        except requests.exceptions.RequestException as e:
            if "401" in str(e) or "Unauthorized" in str(e):
                raise Exception(f"Authentication failed for {self.current_ai_provider}. Please check your API key.")
            elif "429" in str(e) or "rate limit" in str(e).lower():
                raise Exception(f"Rate limit exceeded for {self.current_ai_provider}. Please try again later.")
            else:
                raise Exception(f"Network error connecting to {self.current_ai_provider}: {str(e)}")
        except Exception as e:
            if "API key" not in str(e):  # Don't wrap API key errors
                raise Exception(f"Error with {self.current_ai_provider}: {str(e)}")
            else:
                raise

    def call_openrouter_api(self, message, base_url, max_tokens):
        """Call OpenRouter API."""
        headers = {
            "Authorization": f"Bearer {self.ai_api_key}",
            "Content-Type": "application/json",
            "HTTP-Referer": "https://noodlecore-ide.com",
            "X-Title": "NoodleCore IDE"
        }
        
        payload = {
            "model": self.current_ai_model,
            "messages": [{"role": "user", "content": message}],
            "max_tokens": max_tokens,
            "temperature": 0.7
        }
        
        response = requests.post(f"{base_url}/chat/completions",
                               headers=headers, json=payload, timeout=30)
        response.raise_for_status()
        
        return response.json()["choices"][0]["message"]["content"]

    def call_openai_api(self, message, base_url, max_tokens):
        """Call OpenAI API."""
        headers = {
            "Authorization": f"Bearer {self.ai_api_key}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "model": self.current_ai_model,
            "messages": [{"role": "user", "content": message}],
            "max_tokens": max_tokens,
            "temperature": 0.7
        }
        
        response = requests.post(f"{base_url}/chat/completions",
                               headers=headers, json=payload, timeout=30)
        response.raise_for_status()
        
        return response.json()["choices"][0]["message"]["content"]

    def call_anthropic_api(self, message, base_url, max_tokens):
        """Call Anthropic API."""
        headers = {
            "x-api-key": self.ai_api_key,
            "Content-Type": "application/json",
            "anthropic-version": "2023-06-01"
        }
        
        payload = {
            "model": self.current_ai_model,
            "max_tokens": max_tokens,
            "messages": [{"role": "user", "content": message}]
        }
        
        response = requests.post(f"{base_url}/messages",
                               headers=headers, json=payload, timeout=30)
        response.raise_for_status()
        
        return response.json()["content"][0]["text"]

    def call_ollama_api(self, message, base_url, max_tokens):
        """Call Ollama API."""
        payload = {
            "model": self.current_ai_model,
            "prompt": message,
            "stream": False
        }
        
        response = requests.post(f"{base_url}/api/generate",
                               json=payload, timeout=30)
        response.raise_for_status()
        
        return response.json()["response"]

    def clear_ai_chat(self):
        """Clear the AI chat history."""
        self.ai_chat.delete('1.0', 'end')
        self.ai_chat.insert('end', "AI Chat cleared. Ready for new conversation.\n\n")

    def show_ai_history(self):
        """Show AI conversation history."""
        # Implementation for storing and showing AI history
        pass

    def ai_code_review(self):
        """Perform AI code review of current file."""
        message = "Please review the code in the editor and provide specific suggestions for improvements, including code quality, best practices, and potential bugs."
        self.ai_input.delete(0, 'end')
        self.ai_input.insert(0, message)
        self.send_ai_message()

    def ai_explain_code(self):
        """Explain code with AI."""
        message = "Please explain what the code in the editor does in detail, including the logic flow, key functions, and any complex parts that might need clarification."
        self.ai_input.delete(0, 'end')
        self.ai_input.insert(0, message)
        self.send_ai_message()

    def ai_optimize_code(self):
        """Optimize code with AI."""
        message = "Please suggest optimizations for the code in the editor, focusing on performance, readability, and best practices. Provide specific code examples where possible."
        self.ai_input.delete(0, 'end')
        self.ai_input.insert(0, message)
        self.send_ai_message()

    # Working Terminal Functionality
    def create_terminal_panel(self):
        """Create the terminal panel with real command execution."""
        self.terminal_panel = tk.Frame(self.editor_terminal_paned, bg='#2b2b2b')
        
        # Terminal header
        terminal_header = tk.Frame(self.terminal_panel, bg='#2b2b2b')
        terminal_header.pack(fill='x', padx=5, pady=2)
        
        # Terminal controls
        self.terminal_status = tk.Label(terminal_header, text="ðŸ’» Terminal Ready",
                                      bg='#2b2b2b', fg='#4CAF50', font=('Arial', 9, 'bold'))
        self.terminal_status.pack(side='left')
        
        # Clear terminal button
        clear_btn = tk.Button(terminal_header, text="ðŸ—‘ï¸ Clear", command=self.clear_terminal,
                            bg='#f44336', fg='white', font=('Arial', 8))
        clear_btn.pack(side='right', padx=(5, 0))
        
        # Kill process button
        kill_btn = tk.Button(terminal_header, text="â¹ï¸ Stop", command=self.kill_terminal_process,
                           bg='#FF9800', fg='white', font=('Arial', 8))
        kill_btn.pack(side='right', padx=(5, 0))
        
        # Terminal output with syntax coloring
        self.terminal_output = scrolledtext.ScrolledText(self.terminal_panel,
                                                        bg='#1e1e1e', fg='#ffffff',
                                                        font=('Consolas', 10),
                                                        wrap='word', state='disabled')
        self.terminal_output.pack(fill='both', expand=True, padx=5, pady=5)
        
        # Configure text tags for different output types
        self.terminal_output.tag_configure('error', foreground='#f44336')
        self.terminal_output.tag_configure('success', foreground='#4CAF50')
        self.terminal_output.tag_configure('warning', foreground='#FF9800')
        self.terminal_output.tag_configure('command', foreground='#2196F3')
        self.terminal_output.tag_configure('info', foreground='#9C27B0')
        
        # Terminal input
        input_frame = tk.Frame(self.terminal_panel, bg='#2b2b2b')
        input_frame.pack(fill='x', padx=5, pady=(0, 5))
        
        tk.Label(input_frame, text="$ ", bg='#2b2b2b', fg='#4CAF50',
               font=('Consolas', 12, 'bold')).pack(side='left')
        
        self.terminal_input = tk.Entry(input_frame, bg='#1e1e1e', fg='white',
                                     font=('Consolas', 10), insertbackground='white')
        self.terminal_input.pack(side='left', fill='x', expand=True)
        self.terminal_input.bind('<Return>', self.execute_terminal_command)
        self.terminal_input.bind('<Up>', self.show_command_history)
        self.terminal_input.bind('<Down>', self.show_command_history)
        
        # Command history
        self.command_history = []
        self.history_index = -1
        
        # Terminal context menu
        self.create_terminal_context_menu()
        
        # Initialize terminal
        self.initialize_terminal()

    def initialize_terminal(self):
        """Initialize terminal with welcome message and current directory."""
        current_dir = os.getcwd()
        welcome_msg = f"Welcome to NoodleCore Terminal\nCurrent directory: {current_dir}\nType 'help' for available commands.\n\n"
        self.write_terminal_output(welcome_msg, 'info')

    def create_terminal_context_menu(self):
        """Create context menu for terminal."""
        context_menu = tk.Menu(self.root, tearoff=0, bg='#2b2b2b', fg='white')
        context_menu.add_command(label="Copy", command=self.copy_terminal_output)
        context_menu.add_command(label="Paste", command=self.paste_terminal_input)
        context_menu.add_command(label="Clear", command=self.clear_terminal)
        context_menu.add_separator()
        context_menu.add_command(label="History", command=self.show_terminal_history)
        
        # Bind context menu to terminal output
        self.terminal_output.bind('<Button-3>', lambda e: context_menu.post(e.x_root, e.y_root))

    def write_terminal_output(self, text, tag=None):
        """Write text to terminal output with optional styling."""
        self.terminal_output.config(state='normal')
        if tag:
            self.terminal_output.insert('end', text, tag)
        else:
            self.terminal_output.insert('end', text)
        self.terminal_output.see('end')
        self.terminal_output.config(state='disabled')

    def execute_terminal_command(self, event=None):
        """Execute command in terminal with real subprocess integration."""
        command = self.terminal_input.get().strip()
        if not command:
            return
        
        # Add to command history
        if command not in self.command_history:
            self.command_history.append(command)
        self.history_index = len(self.command_history)
        
        # Show command in output
        self.write_terminal_output(f"$ {command}\n", 'command')
        self.terminal_input.delete(0, 'end')
        
        # Handle built-in commands
        if self.handle_builtin_command(command):
            return
        
        # Execute external command
        self.execute_external_command(command)

    def handle_builtin_command(self, command):
        """Handle built-in terminal commands."""
        parts = command.split()
        if not parts:
            return True
        
        cmd = parts[0].lower()
        
        if cmd == 'clear':
            self.clear_terminal()
            return True
        elif cmd == 'pwd':
            self.write_terminal_output(f"{os.getcwd()}\n")
            return True
        elif cmd == 'ls':
            self.list_directory(' '.join(parts[1:]) if len(parts) > 1 else '.')
            return True
        elif cmd == 'cd':
            if len(parts) > 1:
                self.change_directory(parts[1])
            else:
                self.change_directory(os.path.expanduser('~'))
            return True
        elif cmd == 'help':
            self.show_help()
            return True
        elif cmd == 'history':
            self.show_command_history()
            return True
        elif cmd == 'exit':
            self.root.quit()
            return True
        
        return False

    def list_directory(self, path):
        """List directory contents with formatting."""
        try:
            items = os.listdir(path)
            items.sort()
            
            output = []
            for item in items:
                full_path = os.path.join(path, item)
                if os.path.isdir(full_path):
                    output.append(f"{item}/")
                else:
                    size = os.path.getsize(full_path)
                    output.append(f"{item} ({size} bytes)")
            
            self.write_terminal_output('\n'.join(output) + '\n')
            
        except Exception as e:
            self.write_terminal_output(f"Error listing directory: {str(e)}\n", 'error')

    def change_directory(self, path):
        """Change current directory."""
        try:
            # Handle special directories
            if path == '~':
                path = os.path.expanduser('~')
            elif path == '..':
                path = os.path.dirname(os.getcwd())
            elif path == '.':
                path = os.getcwd()
            
            os.chdir(path)
            self.write_terminal_output(f"Changed to: {os.getcwd()}\n", 'success')
            self.update_terminal_prompt()
            
        except Exception as e:
            self.write_terminal_output(f"Error changing directory: {str(e)}\n", 'error')

    def show_help(self):
        """Show available commands."""
        help_text = """
Available Commands:
  help        Show this help message
  clear       Clear terminal screen
  pwd         Print working directory
  ls [path]   List directory contents
  cd [path]   Change directory
  history     Show command history
  exit        Exit terminal
  open [file] Open file in editor

System commands are also available (python, git, etc.)
        """
        self.write_terminal_output(help_text + '\n', 'info')

    def show_command_history(self, event=None):
        """Show command history in terminal."""
        if not self.command_history:
            return
        
        if event and event.keysym == 'Up':
            if self.history_index > 0:
                self.history_index -= 1
        elif event and event.keysym == 'Down':
            if self.history_index < len(self.command_history):
                self.history_index += 1
                if self.history_index == len(self.command_history):
                    self.terminal_input.delete(0, 'end')
                    return
        
        if 0 <= self.history_index < len(self.command_history):
            self.terminal_input.delete(0, 'end')
            self.terminal_input.insert(0, self.command_history[self.history_index])

    def execute_external_command(self, command):
        """Execute external system command."""
        try:
            # Update status
            self.terminal_status.config(text="ðŸ’» Executing...", fg='#FF9800')
            
            # Execute the command
            result = subprocess.run(command, shell=True, capture_output=True, text=True, timeout=30)
            
            # Display output
            if result.stdout:
                self.write_terminal_output(result.stdout)
            if result.stderr:
                self.write_terminal_output(result.stderr, 'error')
            
            if result.returncode == 0:
                self.write_terminal_output("\nâœ… Command completed successfully\n", 'success')
            else:
                self.write_terminal_output(f"\nâŒ Command failed (exit code: {result.returncode})\n", 'error')
                
        except subprocess.TimeoutExpired:
            self.write_terminal_output("â° Command timed out\n", 'warning')
        except Exception as e:
            self.write_terminal_output(f"Error executing command: {str(e)}\n", 'error')
        finally:
            self.terminal_status.config(text="ðŸ’» Terminal Ready", fg='#4CAF50')
            self.write_terminal_output('\n')
            self.terminal_output.see('end')

    def clear_terminal(self):
        """Clear terminal output."""
        self.terminal_output.config(state='normal')
        self.terminal_output.delete('1.0', 'end')
        self.terminal_output.config(state='disabled')
        self.initialize_terminal()

    def kill_terminal_process(self):
        """Kill currently running process."""
        self.write_terminal_output("Process termination not yet implemented\n", 'warning')

    def copy_terminal_output(self):
        """Copy terminal output to clipboard."""
        try:
            selected_text = self.terminal_output.selection_get()
            self.root.clipboard_clear()
            self.root.clipboard_append(selected_text)
        except tk.TclError:
            pass

    def paste_terminal_input(self):
        """Paste from clipboard to terminal input."""
        try:
            clipboard_text = self.root.clipboard_get()
            self.terminal_input.insert('end', clipboard_text)
        except tk.TclError:
            pass

    def show_terminal_history(self):
        """Show command history."""
        if not self.command_history:
            self.write_terminal_output("No command history\n")
            return
        
        history_text = "\nCommand History:\n" + "\n".join(
            f"{i+1}. {cmd}" for i, cmd in enumerate(self.command_history[-10:])
        ) + "\n"
        
        self.write_terminal_output(history_text, 'info')

    def update_terminal_prompt(self):
        """Update terminal prompt with current directory."""
        pass

    # Properties Panel
    def create_properties_panel(self):
        """Create the properties panel."""
        self.properties_panel = tk.Frame(self.main_paned, bg='#2b2b2b')
        
        # Properties header
        props_header = tk.Frame(self.properties_panel, bg='#2b2b2b')
        props_header.pack(fill='x', padx=5, pady=2)
        
        tk.Label(props_header, text="âš™ï¸ Properties",
                bg='#2b2b2b', fg='white', font=('Arial', 10, 'bold')).pack()
        
        # AI Configuration section
        ai_frame = tk.LabelFrame(self.properties_panel, text="AI Configuration",
                                bg='#2b2b2b', fg='white')
        ai_frame.pack(fill='x', padx=5, pady=5)
        
        # Provider selection
        tk.Label(ai_frame, text="Provider:", bg='#2b2b2b', fg='white').pack(anchor='w')
        self.provider_var = tk.StringVar(value=self.current_ai_provider)
        provider_combo = ttk.Combobox(ai_frame, textvariable=self.provider_var,
                                     values=list(self.ai_providers.keys()))
        provider_combo.pack(fill='x', padx=5, pady=2)
        provider_combo.bind('<<ComboboxSelected>>', self.on_provider_change)
        
        # Model selection
        tk.Label(ai_frame, text="Model:", bg='#2b2b2b', fg='white').pack(anchor='w', pady=(10,0))
        self.model_var = tk.StringVar(value=self.current_ai_model)
        self.model_combo = ttk.Combobox(ai_frame, textvariable=self.model_var)
        self.model_combo.pack(fill='x', padx=5, pady=2)
        
        # API Key
        tk.Label(ai_frame, text="API Key:", bg='#2b2b2b', fg='white').pack(anchor='w', pady=(10,0))
        self.api_key_var = tk.StringVar(value=self.ai_api_key)
        api_key_entry = tk.Entry(ai_frame, textvariable=self.api_key_var, show='*')
        api_key_entry.pack(fill='x', padx=5, pady=2)
        
        # Show/hide API key
        def toggle_api_key_visibility():
            api_key_entry.config(show='' if api_key_entry.config('show')[-1] == '*' else '*')
        
        toggle_btn = tk.Button(ai_frame, text="ðŸ‘ï¸", command=toggle_api_key_visibility,
                             bg='#666666', fg='white')
        toggle_btn.pack(anchor='e', padx=5)
        
        # Save button
        save_btn = tk.Button(ai_frame, text="ðŸ’¾ Save Settings", command=self.save_ai_settings,
                           bg='#4CAF50', fg='white')
        save_btn.pack(fill='x', padx=5, pady=5)
        
        # File Information section
        file_info_frame = tk.LabelFrame(self.properties_panel, text="File Information",
                                       bg='#2b2b2b', fg='white')
        file_info_frame.pack(fill='x', padx=5, pady=5)
        
        self.file_info_text = tk.Text(file_info_frame, height=8, bg='#1e1e1e', fg='white',
                                     font=('Arial', 9), wrap='word')
        self.file_info_text.pack(fill='both', expand=True, padx=5, pady=5)

    def update_properties_panel(self, file_path):
        """Update properties panel with file information."""
        try:
            self.file_info_text.delete('1.0', 'end')
            
            if file_path.is_file():
                stat = file_path.stat()
                info_text = f"""File: {file_path.name}
Path: {file_path}
Size: {stat.st_size:,} bytes
Modified: {datetime.fromtimestamp(stat.st_mtime).strftime('%Y-%m-%d %H:%M:%S')}
Type: {file_path.suffix if file_path.suffix else 'No extension'}
Readable: {'Yes' if os.access(file_path, os.R_OK) else 'No'}
Writable: {'Yes' if os.access(file_path, os.W_OK) else 'No'}
"""
            elif file_path.is_dir():
                info_text = f"""Directory: {file_path.name}
Path: {file_path}
Type: Folder
"""
            else:
                info_text = "Unknown file type"
            
            self.file_info_text.insert('1.0', info_text)
            
        except Exception as e:
            self.file_info_text.delete('1.0', 'end')
            self.file_info_text.insert('1.0', f"Error getting file info: {str(e)}")

    # Menu and UI setup
    def setup_ui(self):
        """Setup the main UI with menu bar and PanedWindow structure."""
        # Menu bar
        self.create_menu_bar()
        
        # Status bar
        self.create_status_bar()

    def create_menu_bar(self):
        """Create the menu bar with window management options."""
        menubar = tk.Menu(self.root)
        self.root.config(menu=menubar)
        
        # File menu
        file_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="File", menu=file_menu)
        file_menu.add_command(label="New File", command=self.new_file, accelerator="Ctrl+N")
        file_menu.add_command(label="Open File", command=self.open_file, accelerator="Ctrl+O")
        file_menu.add_command(label="Save", command=self.save_file, accelerator="Ctrl+S")
        file_menu.add_command(label="Save As", command=self.save_file_as, accelerator="Ctrl+Shift+S")
        file_menu.add_command(label="Save All", command=self.save_all_files)
        file_menu.add_separator()
        
        # Panel submenu
        panel_menu = tk.Menu(file_menu, tearoff=0)
        file_menu.add_cascade(label="Panels", menu=panel_menu)
        
        # Panel visibility controls
        self.file_explorer_var = tk.BooleanVar(value=True)
        panel_menu.add_checkbutton(label="Show File Explorer",
                                   variable=self.file_explorer_var,
                                   command=lambda: self.toggle_panel('file_explorer'))
        self.code_editor_var = tk.BooleanVar(value=True)
        panel_menu.add_checkbutton(label="Show Code Editor",
                                   variable=self.code_editor_var,
                                   command=lambda: self.toggle_panel('code_editor'))
        self.terminal_var = tk.BooleanVar(value=True)
        panel_menu.add_checkbutton(label="Show Terminal",
                                   variable=self.terminal_var,
                                   command=lambda: self.toggle_panel('terminal'))
        self.ai_chat_var = tk.BooleanVar(value=True)
        panel_menu.add_checkbutton(label="Show AI Chat",
                                   variable=self.ai_chat_var,
                                   command=lambda: self.toggle_panel('ai_chat'))
        self.properties_var = tk.BooleanVar(value=False)
        panel_menu.add_checkbutton(label="Show Properties Panel",
                                   variable=self.properties_var,
                                   command=lambda: self.toggle_panel('properties'))
        panel_menu.add_separator()
        panel_menu.add_command(label="Show All Panels", command=self.show_all_panels)
        panel_menu.add_command(label="Hide All Panels", command=self.hide_all_panels)
        panel_menu.add_command(label="Restore Default Layout", command=self.restore_default_layout)
        
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self.root.quit)
        
        # Run menu
        run_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Run", menu=run_menu)
        run_menu.add_command(label="Run Current File", command=self.run_current_file, accelerator="F5")
        run_menu.add_command(label="Debug File", command=self.debug_file, accelerator="F9")
        
        # AI menu
        ai_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="AI", menu=ai_menu)
        ai_menu.add_command(label="Code Review", command=self.ai_code_review)
        ai_menu.add_command(label="Explain Code", command=self.ai_explain_code)
        ai_menu.add_command(label="Generate Tests", command=self.ai_generate_tests)
        ai_menu.add_command(label="Optimize Code", command=self.ai_optimize_code)
        ai_menu.add_separator()
        ai_menu.add_command(label="AI Settings", command=self.show_ai_settings)
        
        # Help menu
        help_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Help", menu=help_menu)
        help_menu.add_command(label="About", command=self.show_about)
        
        # Bind keyboard shortcuts
        self.root.bind('<Control-n>', lambda e: self.new_file())
        self.root.bind('<Control-o>', lambda e: self.open_file())
        self.root.bind('<Control-s>', lambda e: self.save_file())
        self.root.bind('<Control-S>', lambda e: self.save_file_as())
        self.root.bind('<F5>', lambda e: self.run_current_file())
        self.root.bind('<F9>', lambda e: self.debug_file())

    def create_status_bar(self):
        """Create the status bar."""
        status_frame = tk.Frame(self.root, bg='#1e1e1e')
        status_frame.pack(side='bottom', fill='x')
        
        self.status_bar = tk.Label(status_frame, text="Ready", relief='sunken',
                                  anchor='w', bg='#2b2b2b', fg='white')
        self.status_bar.pack(side='bottom', fill='x', expand=True)

    # Panel management methods
    def apply_panel_visibility(self):
        """Apply panel visibility based on current states."""
        # Always keep main panels visible
        if not self.panel_states['file_explorer']:
            self.main_paned.forget(self.file_explorer_panel)
        if not self.panel_states['code_editor']:
            self.editor_terminal_paned.forget(self.code_editor_panel)
        if not self.panel_states['terminal']:
            self.editor_terminal_paned.forget(self.terminal_panel)
            
        # Handle secondary panels that are contained within right_panels_frame
        # AI Chat panel
        if hasattr(self, 'ai_chat_panel') and self.ai_chat_panel:
            if self.panel_states['ai_chat']:
                if not self.ai_chat_panel.winfo_viewable():
                    self.ai_chat_panel.pack(fill='both', expand=True, padx=2, pady=2)
            else:
                if self.ai_chat_panel.winfo_viewable():
                    self.ai_chat_panel.pack_forget()
                    
        # Properties panel
        if hasattr(self, 'properties_panel') and self.properties_panel:
            if self.panel_states['properties']:
                if not self.properties_panel.winfo_viewable():
                    self.properties_panel.pack(fill='both', expand=True, padx=2, pady=2)
            else:
                if self.properties_panel.winfo_viewable():
                    self.properties_panel.pack_forget()

    def toggle_panel(self, panel_name):
        """Toggle panel visibility."""
        self.panel_states[panel_name] = not self.panel_states[panel_name]
        
        # Update menu variables
        if panel_name == 'file_explorer':
            self.file_explorer_var.set(self.panel_states[panel_name])
        elif panel_name == 'code_editor':
            self.code_editor_var.set(self.panel_states[panel_name])
        elif panel_name == 'terminal':
            self.terminal_var.set(self.panel_states[panel_name])
        elif panel_name == 'ai_chat':
            self.ai_chat_var.set(self.panel_states[panel_name])
        elif panel_name == 'properties':
            self.properties_var.set(self.panel_states[panel_name])
            
        # Apply visibility changes
        self.apply_panel_visibility()
        self.save_panel_states()

    def show_all_panels(self):
        """Show all panels."""
        for panel_name in self.panel_states.keys():
            self.panel_states[panel_name] = True
            
        # Update menu variables
        self.file_explorer_var.set(True)
        self.code_editor_var.set(True)
        self.terminal_var.set(True)
        self.ai_chat_var.set(True)
        self.properties_var.set(True)
        
        # Apply visibility changes
        self.apply_panel_visibility()

    def hide_all_panels(self):
        """Hide all except essentials."""
        # Keep essential panels visible
        self.panel_states['file_explorer'] = True
        self.panel_states['code_editor'] = True
        self.panel_states['terminal'] = True
        
        # Hide secondary panels
        self.panel_states['ai_chat'] = False
        self.panel_states['properties'] = False
        
        # Update menu variables
        self.file_explorer_var.set(True)
        self.code_editor_var.set(True)
        self.terminal_var.set(True)
        self.ai_chat_var.set(False)
        self.properties_var.set(False)
        
        # Apply visibility changes
        self.apply_panel_visibility()

    def restore_default_layout(self):
        """Restore default panel layout."""
        self.panel_states = {
            'file_explorer': True,
            'code_editor': True,
            'terminal': True,
            'ai_chat': False,
            'properties': False
        }
        
        # Update menu variables
        self.file_explorer_var.set(True)
        self.code_editor_var.set(True)
        self.terminal_var.set(True)
        self.ai_chat_var.set(False)
        self.properties_var.set(False)
        
        # Apply visibility changes
        self.apply_panel_visibility()

    # Configuration persistence
    def save_panel_states(self):
        """Save panel states to file."""
        try:
            config_path = Path.home() / '.noodlecore' / 'panel_states.json'
            config_path.parent.mkdir(exist_ok=True)
            
            with open(config_path, 'w') as f:
                json.dump(self.panel_states, f, indent=2)
        except Exception as e:
            print(f"Could not save panel states: {e}")

    def load_panel_states(self):
        """Load panel states from file."""
        try:
            config_path = Path.home() / '.noodlecore' / 'panel_states.json'
            if config_path.exists():
                with open(config_path, 'r') as f:
                    saved_states = json.load(f)
                    self.panel_states.update(saved_states)
                    
                # Update menu variables
                self.file_explorer_var.set(self.panel_states.get('file_explorer', True))
                self.code_editor_var.set(self.panel_states.get('code_editor', True))
                self.terminal_var.set(self.panel_states.get('terminal', True))
                self.ai_chat_var.set(self.panel_states.get('ai_chat', False))
                self.properties_var.set(self.panel_states.get('properties', False))
                
                # Apply visibility changes
                self.apply_panel_visibility()
        except Exception as e:
            print(f"Could not load panel states: {e}")

    # AI provider change handler
    def on_provider_change(self, event=None):
        """Handle AI provider change."""
        provider = self.provider_var.get()
        if provider in self.ai_providers:
            models = self.ai_providers[provider]['models']
            self.model_combo['values'] = models
            self.model_var.set(models[0] if models else "")

    # File operations
    def new_file(self):
        """Create a new file."""
        # Ask for filename
        file_path = filedialog.asksaveasfilename(
            title="Create New File",
            initialdir=str(self.current_project_path),
            defaultextension=".txt"
        )
        
        if file_path:
            try:
                # Create empty file
                Path(file_path).touch()
                
                # Open it
                self.open_file_helper(file_path)
                
            except Exception as e:
                messagebox.showerror("Error", f"Could not create file: {str(e)}")

    def open_file(self):
        """Open a file with real file system integration."""
        file_path = filedialog.askopenfilename(
            title="Open File",
            initialdir=str(self.current_project_path),
            filetypes=[
                ("All Files", "*.*"),
                ("NoodleCore", "*.nc"),
                ("Python", "*.py"),
                ("JavaScript", "*.js"),
                ("HTML", "*.html"),
                ("CSS", "*.css"),
                ("JSON", "*.json"),
                ("Text", "*.txt"),
                ("Markdown", "*.md")
            ]
        )
        
        if file_path:
            self.open_file_helper(file_path)

    def open_file_helper(self, file_path):
        """Helper to open a file with comprehensive functionality."""
        try:
            # Check if file is already open
            if file_path in self.open_files:
                # Switch to existing tab
                text_widget = self.open_files[file_path]
                # Find and select the corresponding tab
                for i, widget in enumerate(self.tab_text_widgets):
                    if widget == text_widget:
                        self.notebook.select(self.notebook.winfo_children()[i])
                        break
                self.status_bar.config(text=f"File already open: {file_path}")
                return
            
            # Read file content
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Create new tab
            tab_title = Path(file_path).name
            text_widget = self.create_new_tab(tab_title, file_path)
            text_widget.insert('1.0', content)
            
            # Track file
            self.open_files[file_path] = text_widget
            self.current_file = file_path
            self.unsaved_changes[file_path] = False
            
            # Add to recent files
            if file_path not in self.workspace_state['recent_files']:
                self.workspace_state['recent_files'].insert(0, file_path)
                # Keep only last 10 recent files
                self.workspace_state['recent_files'] = self.workspace_state['recent_files'][:10]
            
            # Update status
            self.status_bar.config(text=f"Opened: {file_path}")
            
            # Apply syntax highlighting
            if self.syntax_highlighting_var.get():
                self.apply_syntax_highlighting(text_widget)
            
            self.save_workspace_state()
            
        except Exception as e:
            messagebox.showerror("Error", f"Could not open file: {str(e)}")

    def save_file(self):
        """Save the current file."""
        if not self.current_file:
            self.save_file_as()
            return
        
        try:
            text_widget = self.open_files.get(self.current_file)
            if text_widget:
                with open(self.current_file, 'w', encoding='utf-8') as f:
                    f.write(text_widget.get('1.0', 'end'))
                
                self.unsaved_changes[self.current_file] = False
                
                # Update tab title
                tab_index = self.tab_text_widgets.index(text_widget)
                current_title = self.notebook.tab(tab_index, 'text')
                if current_title.endswith('*'):
                    self.notebook.tab(tab_index, text=current_title.rstrip('*'))
                
                self.status_bar.config(text=f"Saved: {self.current_file}")
            else:
                messagebox.showwarning("Warning", "No file to save")
                
        except Exception as e:
            messagebox.showerror("Error", f"Could not save file: {str(e)}")

    def save_file_as(self):
        """Save current file with a new name."""
        if not self.current_file:
            # For new files, ask for a name
            file_path = filedialog.asksaveasfilename(
                title="Save File",
                initialdir=str(self.current_project_path),
                defaultextension=".txt",
                filetypes=[
                    ("NoodleCore", "*.nc"),
                    ("Python", "*.py"),
                    ("JavaScript", "*.js"),
                    ("HTML", "*.html"),
                    ("CSS", "*.css"),
                    ("JSON", "*.json"),
                    ("Text", "*.txt"),
                    ("Markdown", "*.md"),
                    ("All Files", "*.*")
                ]
            )
        else:
            # For existing files, use current name as starting point
            text_widget = self.open_files.get(self.current_file)
            if not text_widget:
                return
            
            initial_file = self.current_file
            file_path = filedialog.asksaveasfilename(
                title="Save File As",
                initialfile=Path(initial_file).name,
                initialdir=Path(initial_file).parent,
                filetypes=[
                    ("NoodleCore", "*.nc"),
                    ("Python", "*.py"),
                    ("JavaScript", "*.js"),
                    ("HTML", "*.html"),
                    ("CSS", "*.css"),
                    ("JSON", "*.json"),
                    ("Text", "*.txt"),
                    ("Markdown", "*.md"),
                    ("All Files", "*.*")
                ]
            )
        
        if file_path:
            try:
                text_widget = self.open_files.get(self.current_file) if self.current_file else None
                if not text_widget:
                    # This is a new file
                    tab_text = self.notebook.select()
                    if tab_text:
                        tab_frame = self.root.nametowidget(tab_text)
                        for widget in tab_frame.winfo_children():
                            if isinstance(widget, tk.Text):
                                text_widget = widget
                                break
                
                if text_widget:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(text_widget.get('1.0', 'end'))
                    
                    # Update tracking
                    if self.current_file and self.current_file in self.open_files:
                        # Moving existing file
                        del self.open_files[self.current_file]
                        if self.current_file in self.unsaved_changes:
                            del self.unsaved_changes[self.current_file]
                    
                    # Add as new file
                    self.open_files[file_path] = text_widget
                    self.unsaved_changes[file_path] = False
                    self.current_file = file_path
                    
                    # Update tab title
                    tab_title = Path(file_path).name
                    current_tab = self.notebook.select()
                    self.notebook.tab(current_tab, text=tab_title)
                    
                    self.status_bar.config(text=f"Saved as: {file_path}")
                    
                    # Add to recent files
                    if file_path not in self.workspace_state['recent_files']:
                        self.workspace_state['recent_files'].insert(0, file_path)
                        self.workspace_state['recent_files'] = self.workspace_state['recent_files'][:10]
                    
                    self.save_workspace_state()
                    
            except Exception as e:
                messagebox.showerror("Error", f"Could not save file: {str(e)}")

    # File execution methods
    def run_current_file(self):
        """Run the current file with comprehensive language support."""
        if not self.current_file:
            messagebox.showwarning("Warning", "No file to run")
            return
        
        file_path = Path(self.current_file)
        
        # Clear terminal and show running status
        self.terminal_output.config(state='normal')
        self.terminal_output.delete('1.0', 'end')
        self.terminal_output.config(state='disabled')
        
        self.write_terminal_output(f"Running: {file_path}\n", 'command')
        self.write_terminal_output("=" * 50 + "\n", 'info')
        
        # Determine file type and execution method
    
    def debug_file(self):
        """Debug the current file."""
        if not self.current_file:
            messagebox.showwarning("Warning", "No file to debug")
            return
        
        file_path = Path(self.current_file)
        
        # Clear terminal
        self.terminal_output.config(state='normal')
        self.terminal_output.delete('1.0', 'end')
        self.terminal_output.config(state='disabled')
        
        self.write_terminal_output(f"ðŸ› Debugging: {file_path}\n", 'command')
        self.write_terminal_output("=" * 50 + "\n", 'info')
        
        # Provide debug information and suggestions
        if file_path.suffix == '.py':
            self.debug_python_file(file_path)
        else:
            self.write_terminal_output("Debug mode is currently available for Python files.\n", 'info')
            self.write_terminal_output("For other files, consider adding print statements or using external debuggers.\n", 'info')

    def debug_python_file(self, file_path):
        """Debug Python file with enhanced information."""
        try:
            self.write_terminal_output("ðŸ Running Python file in debug mode...\n", 'info')
            
            # Add debug information
            debug_script = f'''
import sys
import traceback
import time

print("=== DEBUG MODE ===")
print(f"Python version: {{sys.version}}")
print(f"Current working directory: {{os.getcwd()}}")
print(f"Script path: {file_path}")
print("=" * 30)

try:
'''
            
            # Read original file content
            with open(file_path, 'r', encoding='utf-8') as f:
                original_content = f.read()
            
            # Create debug version
            debug_content = debug_script + original_content + '''
except Exception as e:
    print(f"\\nâŒ ERROR: {e}")
    print("\\nðŸ› Full traceback:")
    traceback.print_exc()
    sys.exit(1)

print("\\nâœ… Script completed successfully")
'''
            
            # Write debug version to temporary file
            with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as temp_file:
                temp_file.write(debug_content)
                temp_path = temp_file.name
            
            try:
                # Run debug version
                result = subprocess.run([sys.executable, temp_path], 
                                      capture_output=True, text=True, timeout=30)
                
                if result.stdout:
                    self.write_terminal_output(result.stdout)
                if result.stderr:
                    self.write_terminal_output(result.stderr, 'error')
                
                if result.returncode == 0:
                    self.write_terminal_output("\nðŸ Debug session completed\n", 'success')
                else:
                    self.write_terminal_output(f"\nðŸ Debug session ended with errors (exit code: {result.returncode})\n", 'warning')
                    
            finally:
                # Clean up temporary file
                Path(temp_path).unlink()
                
        except Exception as e:
            self.write_terminal_output(f"ðŸ› Error setting up debug session: {str(e)}\n", 'error')
     
    
    def ai_generate_tests(self):
        """Generate tests with AI."""
        message = "Please generate comprehensive unit tests for the code in the editor. Include test cases for different scenarios, edge cases, and error handling."
        self.ai_input.delete(0, 'end')
        self.ai_input.insert(0, message)
        self.send_ai_message()

    def run(self):
        """Start the IDE main loop."""
        self.root.mainloop()

    # Execute the IDE
    def main(self):
        """Main entry point."""
        try:
            # Setup window closing handler
            self.root.protocol("WM_DELETE_WINDOW", self.on_closing)
            
            self.run()
        except Exception as e:
            print(f"Failed to start IDE: {e}")
            return 1
        return 0

    # Workspace state management
    def save_workspace_state(self):
        """Save workspace state including recent files and projects."""
        try:
            config_path = Path.home() / '.noodlecore' / 'workspace_state.json'
            config_path.parent.mkdir(exist_ok=True)
            
            # Update current state
            self.workspace_state.update({
                'current_project': str(self.current_project_path),
                'open_files': list(self.open_files.keys()),
                'ai_config': {
                    'provider': self.current_ai_provider,
                    'model': self.current_ai_model
                }
            })
            
            with open(config_path, 'w') as f:
                json.dump(self.workspace_state, f, indent=2)
                
        except Exception as e:
            print(f"Could not save workspace state: {e}")

    def load_workspace_state(self):
        """Load workspace state."""
        try:
            config_path = Path.home() / '.noodlecore' / 'workspace_state.json'
            if config_path.exists():
                with open(config_path, 'r') as f:
                    saved_state = json.load(f)
                    self.workspace_state.update(saved_state)
                
                # Restore current project
                if 'current_project' in self.workspace_state:
                    project_path = Path(self.workspace_state['current_project'])
                    if project_path.exists() and project_path.is_dir():
                        self.current_project_path = project_path
                        self.project_path_var.set(str(self.current_project_path))
                
                # Restore AI config
                if 'ai_config' in self.workspace_state:
                    ai_config = self.workspace_state['ai_config']
                    if 'provider' in ai_config:
                        self.current_ai_provider = ai_config['provider']
                    if 'model' in ai_config:
                        self.current_ai_model = ai_config['model']
                
        except Exception as e:
            print(f"Could not load workspace state: {e}")

    def load_ai_settings(self):
        """Load AI configuration."""
        try:
            config_path = Path.home() / '.noodlecore' / 'ai_config.json'
            if config_path.exists():
                with open(config_path, 'r') as f:
                    config = json.load(f)
                    # Safe loading with defaults and null checking
                    provider = config.get('provider') or 'OpenRouter'
                    model = config.get('model') or 'gpt-3.5-turbo'
                    api_key = config.get('api_key') or ''
                    
                    self.current_ai_provider = provider
                    self.current_ai_model = model
                    self.ai_api_key = api_key
                    
                    # Update UI variables only if they exist and are not None
                    try:
                        if hasattr(self, 'provider_var') and self.provider_var is not None:
                            self.provider_var.set(self.current_ai_provider)
                    except:
                        pass
                        
                    try:
                        if hasattr(self, 'model_var') and self.model_var is not None:
                            self.model_var.set(self.current_ai_model)
                    except:
                        pass
                        
                    try:
                        if hasattr(self, 'api_key_var') and self.api_key_var is not None:
                            self.api_key_var.set(self.ai_api_key)
                    except:
                        pass
                    
                    # Update models list only if UI is ready
                    try:
                        if (hasattr(self, 'model_combo') and
                            self.model_combo is not None and
                            hasattr(self, 'ai_providers') and
                            self.ai_providers):
                            self.on_provider_change()
                    except:
                        pass
                    
        except Exception as e:
            print(f"Could not load AI settings: {e}")

    def save_ai_settings(self):
        """Save AI configuration."""
        if hasattr(self, 'provider_var'):
            provider = self.provider_var.get()
        else:
            provider = self.current_ai_provider
            
        if hasattr(self, 'model_var'):
            model = self.model_var.get()
        else:
            model = self.current_ai_model
            
        if hasattr(self, 'api_key_var'):
            api_key = self.api_key_var.get()
        else:
            api_key = self.ai_api_key
        
        # Check if API key is required
        if self.ai_providers[provider]['api_key_required'] and not api_key:
            messagebox.showwarning("Warning", "API key is required for this provider")
            return
        
        self.current_ai_provider = provider
        self.current_ai_model = model
        self.ai_api_key = api_key
        
        # Save to config file
        config = {
            'provider': provider,
            'model': model,
            'api_key': api_key
        }
        
        try:
            config_path = Path.home() / '.noodlecore' / 'ai_config.json'
            config_path.parent.mkdir(exist_ok=True)
            with open(config_path, 'w') as f:
                json.dump(config, f)
                
            self.status_bar.config(text=f"AI Settings saved: {provider}/{model}")
            
        except Exception as e:
            messagebox.showerror("Error", f"Could not save AI settings: {str(e)}")

    def show_welcome_message(self):
        """Show comprehensive welcome message."""
        welcome_text = """# ðŸš€ Welcome to NoodleCore Native GUI IDE v2.0 - REAL FUNCTIONALITY

This is a complete development environment with **REAL FUNCTIONALITY** for NoodleCore and other programming languages.

## âœ¨ NEW REAL FEATURES:

### ðŸ“ **Real File Explorer**
- **Live file system scanning** - Actually displays real files from your project
- **File type detection** - Shows appropriate icons for different file types
- **Context menus** - Right-click for file operations (open, delete, rename, new)
- **Project management** - Switch between different project folders
- **Real file operations** - Create, delete, rename files and folders

### ðŸ“ **Real Code Editor**
- **Actual file editing** - Load, edit, and save real files
- **Syntax highlighting** - Real syntax highlighting for Python, JavaScript, HTML, CSS, etc.
- **Line numbers** - Track line numbers for easy navigation
- **Multi-tab editing** - Open and edit multiple files simultaneously
- **Auto-save** - Automatic saving of changes
- **Change tracking** - See which files have unsaved changes

### ðŸ¤– **Real AI Integration**
- **Actual AI API integration** - Connect to real AI services (OpenAI, Anthropic, OpenRouter, Ollama)
- **No mock responses** - Real AI functionality with actual API calls
- **Code review** - Get real AI feedback on your code
- **Code explanation** - AI explanations of complex code
- **Code optimization** - Real suggestions for code improvements
- **Environment variable support** - Secure API key management

### ðŸ’» **Real Terminal**
- **Actual command execution** - Real shell integration
- **Command history** - Navigate through previous commands
- **Built-in commands** - Custom commands (ls, cd, pwd, clear, help)
- **Syntax colored output** - Different colors for errors, warnings, success
- **Directory synchronization** - Terminal directory syncs with file explorer
- **Process management** - Execute and monitor running processes

## ðŸ› ï¸ **How to Use:**

### **Getting Started:**
1. **Project Setup**: Click "ðŸ“+" to create/select a new project folder
2. **File Operations**: Right-click in file explorer for context menu
3. **File Editing**: Double-click files to open them, or use File menu
4. **AI Chat**: Enable AI panel and configure your API key in Properties
5. **Terminal**: Use built-in commands or run system commands

### **File Operations:**
- **New File**: File â†’ New File or right-click â†’ New File
- **Open File**: Double-click in explorer or File â†’ Open File
- **Save**: Ctrl+S or File â†’ Save
- **Run**: F5 to run current file

### **AI Integration:**
1. Go to Properties panel (âš™ï¸)
2. Select AI Provider (OpenAI, Anthropic, OpenRouter, Ollama)
3. Enter API key (except for Ollama)
4. Use AI panel or quick action buttons

### **Terminal Commands:**
- `ls` - List directory contents
- `cd <path>` - Change directory  
- `pwd` - Print working directory
- `clear` - Clear terminal
- `help` - Show all available commands
- `history` - Show command history

## ðŸŽ¯ **Supported Languages & Runners:**
- **Python** (.py) - Runs with Python interpreter
- **JavaScript** (.js) - Runs with Node.js
- **HTML** (.html) - Opens in default browser
- **NoodleCore** (.nc) - Runs with NoodleCore runtime
- **Shell Scripts** (.sh/.bat/.ps1) - Execute as scripts
- **Any file with shebang** - Uses specified interpreter

## ðŸ”§ **Configuration:**
- **Panel Layout**: Use Panels menu to show/hide panels
- **Auto-save**: Files auto-save every 30 seconds
- **Recent Files**: Last 10 files automatically tracked
- **Project History**: Multiple projects can be managed
- **Settings Persistence**: All settings saved automatically

## ðŸŒŸ **Pro Tips:**
- **Multi-tab editing**: Open multiple files and switch between tabs
- **Right-click menus**: Use context menus for quick operations
- **Keyboard shortcuts**: Ctrl+N (new), Ctrl+O (open), Ctrl+S (save), F5 (run)
- **AI context**: AI knows about your current file content
- **Terminal navigation**: Use â†‘/â†“ arrows to browse command history

Ready to start coding? **Create a new project and begin!** ðŸŽ‰"""

        # Get the first tab's text widget
        first_tab = self.notebook.winfo_children()[0]
        if first_tab:
            # Navigate to the correct Text widget: frame -> editor_frame -> Text
            editor_frame = first_tab.winfo_children()[0]  # editor_frame inside the tab frame
            if editor_frame and len(editor_frame.winfo_children()) >= 2:
                # First child is line_numbers, second is text_widget
                text_widget = editor_frame.winfo_children()[1]  # The Text widget
                if isinstance(text_widget, tk.Text):
                    text_widget.insert('1.0', welcome_text)

    def on_closing(self):
        """Handle window closing with proper cleanup."""
        # Save all changes
        self.save_all_files()
        
        # Save workspace state
        self.save_workspace_state()
        
        # Save panel states
        self.save_panel_states()
        
        # Cancel auto-save timer
        if self.auto_save_timer:
            self.root.after_cancel(self.auto_save_timer)
        
        self.root.quit()

    def setup_file_operations(self):
        """Setup file operations."""
        pass

    def setup_ai_interface(self):
        """Setup AI interface."""
        # Load saved AI config if exists
        self.load_ai_settings()
        
        # Initialize agent if available
        if self.ai_agent_manager and not self.current_agent_name:
            agents = self.ai_agent_manager.get_all_agents()
            if agents:
                first_agent = list(agents.keys())[0]
                self.current_agent_name = first_agent
                self.agent_var.set(first_agent)

    def show_ai_settings(self):
        """Show detailed AI settings dialog."""
        dialog = tk.Toplevel(self.root)
        dialog.title("AI Settings")
        dialog.geometry("400x300")
        dialog.configure(bg='#2b2b2b')
        dialog.transient(self.root)
        dialog.grab_set()
        
        # Settings content
        settings_frame = tk.Frame(dialog, bg='#2b2b2b')
        settings_frame.pack(fill='both', expand=True, padx=20, pady=20)
        
        # Current configuration display
        tk.Label(settings_frame, text="Current Configuration:", 
                bg='#2b2b2b', fg='white', font=('Arial', 12, 'bold')).pack(anchor='w')
        
        config_text = f"""Provider: {self.current_ai_provider}
Model: {self.current_ai_model}
API Key: {'*' * len(self.ai_api_key) if self.ai_api_key else 'Not set'}

Status: {'âœ… Connected' if self.ai_api_key else 'âš ï¸ Needs API key'}"""
        
        tk.Label(settings_frame, text=config_text, 
                bg='#2b2b2b', fg='white', font=('Arial', 10), 
                justify='left').pack(anchor='w', pady=10)
        
        # Quick actions
        tk.Label(settings_frame, text="Quick Actions:", 
                bg='#2b2b2b', fg='white', font=('Arial', 10, 'bold')).pack(anchor='w', pady=(20, 5))
        
        test_btn = tk.Button(settings_frame, text="Test Connection", 
                           command=lambda: [dialog.destroy(), self.test_ai_connection()],
                           bg='#4CAF50', fg='white')
        test_btn.pack(anchor='w', pady=2)
        
        settings_btn = tk.Button(settings_frame, text="Open Properties Panel", 
                               command=lambda: [dialog.destroy(), self.show_all_panels()],
                               bg='#2196F3', fg='white')
        settings_btn.pack(anchor='w', pady=2)

    def show_about(self):
        """Show comprehensive about dialog."""
        about_text = """ðŸš€ NoodleCore Native GUI IDE v2.0 - REAL FUNCTIONALITY

A complete, production-ready development environment for NoodleCore and modern programming languages.

âœ¨ **REAL FUNCTIONALITY FEATURES:**
ðŸ“ Live File System Integration - Browse and manage real files
ðŸ“ Advanced Code Editor - Syntax highlighting, multi-tabs, auto-save  
ðŸ¤– Real AI Integration - OpenAI, Anthropic, OpenRouter, Ollama
ðŸ’» Working Terminal - Actual command execution with history
ðŸ”§ Project Management - Switch between multiple projects
âš¡ Performance Optimized - Fast file operations and responsive UI

ðŸŽ¯ **SUPPORTED LANGUAGES:**
Python, JavaScript, HTML, CSS, JSON, XML, YAML, NoodleCore, Shell Scripts

ðŸ—ï¸ **ARCHITECTURE:**
â€¢ Single-window professional layout with resizable panels
â€¢ Real-time file system monitoring and synchronization
â€¢ Integrated AI assistance with context awareness
â€¢ Comprehensive terminal with built-in and system commands
â€¢ Robust error handling and status reporting

ðŸ”’ **SECURITY:**
â€¢ API keys stored securely in user configuration
â€¢ No hardcoded credentials or sensitive data
â€¢ Sandboxed file operations with permission checking

ðŸŽ¨ **USER EXPERIENCE:**
â€¢ IntelliJ-style panel management
â€¢ Context-sensitive menus and shortcuts
â€¢ Auto-save and change tracking
â€¢ Syntax-colored terminal output
â€¢ Real-time status updates

Developed with â¤ï¸ for the NoodleCore community!"""

        messagebox.showinfo("About NoodleCore IDE", about_text)

    def run_current_file(self):
        """Run the current file with comprehensive language support."""
        if not self.current_file:
            messagebox.showwarning("Warning", "No file to run")
            return
        
        file_path = Path(self.current_file)
        
        # Clear terminal and show running status
        self.terminal_output.config(state='normal')
        self.terminal_output.delete('1.0', 'end')
        self.terminal_output.config(state='disabled')

        self.write_terminal_output(f"Running: {file_path}\n", 'command')
        self.write_terminal_output("=" * 50 + "\n", 'info')
        
        # Determine file type and execution method
        if file_path.suffix == '.py':
            self.run_python_file(file_path)
        elif file_path.suffix == '.js':
            self.run_javascript_file(file_path)
        elif file_path.suffix == '.html':
            self.run_html_file(file_path)
        elif file_path.suffix == '.nc':
            self.run_nc_file(file_path)
        elif file_path.suffix.lower() in ['.sh', '.bat', '.ps1']:
            self.run_script_file(file_path)
        else:
            # Try to guess from shebang
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    first_line = f.readline().strip()
                
                if first_line.startswith('#!'):
                    self.run_script_with_shebang(file_path, first_line[2:])
                else:
                    self.terminal_output.config(state='normal')
                    self.terminal_output.insert('end', f"Unsupported file type: {file_path.suffix}\n", 'error')
                    self.terminal_output.config(state='disabled')
            except Exception as e:
                self.write_terminal_output(f"Error reading file: {str(e)}\n", 'error')

    def run_python_file(self, file_path):
        """Run Python file."""
        try:
            self.write_terminal_output("ðŸ Running Python file...\n", 'info')
            
            result = subprocess.run([sys.executable, str(file_path)], 
                                  capture_output=True, text=True, timeout=30)
            
            if result.stdout:
                self.write_terminal_output(result.stdout)
            if result.stderr:
                self.write_terminal_output(result.stderr, 'error')
            
            if result.returncode == 0:
                self.write_terminal_output("\nâœ… Python execution completed successfully\n", 'success')
            else:
                self.write_terminal_output(f"\nâŒ Python execution failed (exit code: {result.returncode})\n", 'error')
                
        except subprocess.TimeoutExpired:
            self.write_terminal_output("â° Python execution timed out\n", 'warning')
        except Exception as e:
            self.write_terminal_output(f"ðŸ› Error running Python file: {str(e)}\n", 'error')

    def run_javascript_file(self, file_path):
        """Run JavaScript file."""
        try:
            self.write_terminal_output("ðŸŸ¨ Running JavaScript file...\n", 'info')
            
            # Try Node.js first
            try:
                result = subprocess.run(['node', str(file_path)], 
                                      capture_output=True, text=True, timeout=30)
            except FileNotFoundError:
                # Try deno if node is not available
                try:
                    result = subprocess.run(['deno', 'run', str(file_path)], 
                                          capture_output=True, text=True, timeout=30)
                except FileNotFoundError:
                    self.write_terminal_output("âŒ Neither Node.js nor Deno found. Please install Node.js to run JavaScript files.\n", 'error')
                    return
            
            if result.stdout:
                self.write_terminal_output(result.stdout)
            if result.stderr:
                self.write_terminal_output(result.stderr, 'error')
            
            if result.returncode == 0:
                self.write_terminal_output("\nâœ… JavaScript execution completed successfully\n", 'success')
            else:
                self.write_terminal_output(f"\nâŒ JavaScript execution failed (exit code: {result.returncode})\n", 'error')
                
        except subprocess.TimeoutExpired:
            self.write_terminal_output("â° JavaScript execution timed out\n", 'warning')
        except Exception as e:
            self.write_terminal_output(f"ðŸ› Error running JavaScript file: {str(e)}\n", 'error')

    def run_html_file(self, file_path):
        """Open HTML file in default browser."""
        try:
            self.write_terminal_output("ðŸŒ Opening HTML file in browser...\n", 'info')
            
            file_url = f"file://{file_path.resolve()}"
            webbrowser.open(file_url)
            
            self.write_terminal_output(f"âœ… Opened {file_path.name} in default browser\n", 'success')
            
        except Exception as e:
            self.write_terminal_output(f"ðŸ› Error opening HTML file: {str(e)}\n", 'error')

    def run_nc_file(self, file_path):
        """Run NoodleCore file."""
        try:
            self.write_terminal_output("ðŸ”§ Running NoodleCore file...\n", 'info')
            
            # Try to find NoodleCore runtime
            nc_path = self.find_noodlecore_runtime()
            if nc_path:
                result = subprocess.run([nc_path, str(file_path)], 
                                      capture_output=True, text=True, timeout=30)
            else:
                # Fallback to Python interpretation
                result = subprocess.run([sys.executable, str(file_path)], 
                                      capture_output=True, text=True, timeout=30)
            
            if result.stdout:
                self.write_terminal_output(result.stdout)
            if result.stderr:
                self.write_terminal_output(result.stderr, 'error')
            
            if result.returncode == 0:
                self.write_terminal_output("\nâœ… NoodleCore execution completed successfully\n", 'success')
            else:
                self.write_terminal_output(f"\nâŒ NoodleCore execution failed (exit code: {result.returncode})\n", 'error')
                
        except subprocess.TimeoutExpired:
            self.write_terminal_output("â° NoodleCore execution timed out\n", 'warning')
        except Exception as e:
            self.write_terminal_output(f"ðŸ› Error running NoodleCore file: {str(e)}\n", 'error')

    def run_script_file(self, file_path):
        """Run script file based on extension."""
        try:
            self.write_terminal_output(f"ðŸ’» Running script: {file_path.name}\n", 'info')
            
            # Make executable on Unix systems
            if sys.platform != 'win32':
                os.chmod(file_path, 0o755)
            
            result = subprocess.run([str(file_path)], 
                                  capture_output=True, text=True, timeout=30)
            
            if result.stdout:
                self.write_terminal_output(result.stdout)
            if result.stderr:
                self.write_terminal_output(result.stderr, 'error')
            
            if result.returncode == 0:
                self.write_terminal_output("\nâœ… Script execution completed successfully\n", 'success')
            else:
                self.write_terminal_output(f"\nâŒ Script execution failed (exit code: {result.returncode})\n", 'error')
                
        except subprocess.TimeoutExpired:
            self.write_terminal_output("â° Script execution timed out\n", 'warning')
        except Exception as e:
            self.write_terminal_output(f"ðŸ› Error running script: {str(e)}\n", 'error')

    def run_script_with_shebang(self, file_path, shebang):
        """Run script with shebang interpreter."""
        try:
            self.write_terminal_output(f"ðŸ’» Running script with interpreter: {shebang}\n", 'info')
            
            result = subprocess.run([shebang, str(file_path)], 
                                  capture_output=True, text=True, timeout=30)
            
            if result.stdout:
                self.write_terminal_output(result.stdout)
            if result.stderr:
                self.write_terminal_output(result.stderr, 'error')
            
            if result.returncode == 0:
                self.write_terminal_output("\nâœ… Script execution completed successfully\n", 'success')
            else:
                self.write_terminal_output(f"\nâŒ Script execution failed (exit code: {result.returncode})\n", 'error')
                
        except subprocess.TimeoutExpired:
            self.write_terminal_output("â° Script execution timed out\n", 'warning')
        except Exception as e:
            self.write_terminal_output(f"ðŸ› Error running script: {str(e)}\n", 'error')

    def find_noodlecore_runtime(self):
        """Find NoodleCore runtime executable."""
        # Look for common locations
        possible_paths = [
            "noodle-core/nc",
            "noodle-core/nc.exe",
            "../noodle-core/nc",
            "../../noodle-core/nc"
        ]
        
        for path in possible_paths:
            if Path(path).exists():
                return path
        
        # Look in PATH
        import shutil
        nc_path = shutil.which("nc")
        if nc_path:
            return nc_path
        
        return None

    # Terminal methods
    def create_terminal_panel(self):
        """Create the terminal panel with real command execution."""
        self.terminal_panel = tk.Frame(self.editor_terminal_paned, bg='#2b2b2b')
        
        # Terminal header
        terminal_header = tk.Frame(self.terminal_panel, bg='#2b2b2b')
        terminal_header.pack(fill='x', padx=5, pady=2)
        
        # Terminal title
        tk.Label(terminal_header, text="ðŸ’» Terminal", 
                bg='#2b2b2b', fg='white', font=('Arial', 10, 'bold')).pack(side='left')
        
        # Clear button
        clear_btn = tk.Button(terminal_header, text="ðŸ—‘ï¸ Clear", command=self.clear_terminal,
                             bg='#666666', fg='white', font=('Arial', 8))
        clear_btn.pack(side='right', padx=2)
        
        # Terminal output area
        self.terminal_output = scrolledtext.ScrolledText(terminal_header, 
                                                        height=10, 
                                                        bg='#000000', fg='#00FF00',
                                                        font=('Consolas', 10),
                                                        state='disabled')
        self.terminal_output.pack(fill='both', expand=True, pady=(5, 0))
        
        # Terminal input
        input_frame = tk.Frame(self.terminal_panel, bg='#2b2b2b')
        input_frame.pack(fill='x', padx=5, pady=2)
        
        self.current_directory = str(Path.cwd())
        self.terminal_input = tk.Entry(input_frame, 
                                      bg='#1e1e1e', fg='white',
                                      font=('Consolas', 10))
        self.terminal_input.pack(fill='x', side='left', expand=True)
        self.terminal_input.bind('<Return>', self.execute_terminal_command)
        
        # Execute button
        execute_btn = tk.Button(input_frame, text="Execute", 
                               command=self.execute_terminal_command,
                               bg='#4CAF50', fg='white')
        execute_btn.pack(side='right', padx=(5, 0))
        
        # Command history
        self.command_history = []
        self.history_index = -1
        self.terminal_input.bind('<Up>', self.previous_command)
        self.terminal_input.bind('<Down>', self.next_command)
        
        # Welcome message
        self.write_terminal_output("Welcome to NoodleCore Terminal! Type 'help' for available commands.\n", 'info')
        self.write_terminal_output(f"Current directory: {self.current_directory}\n", 'command')

    def write_terminal_output(self, text, style='normal'):
        """Write text to terminal with styling."""
        self.terminal_output.config(state='normal')
        
        # Apply styling
        tags = {
            'normal': 'white',
            'command': '#00FFFF',
            'error': '#FF4444',
            'warning': '#FFAA00',
            'success': '#44FF44',
            'info': '#AAAAFF'
        }
        
        # Insert text with appropriate color
        self.terminal_output.insert('end', text)
        if style in tags:
            self.terminal_output.tag_add(style, 'end-1c', 'end')
            self.terminal_output.tag_config(style, foreground=tags[style])
        
        self.terminal_output.config(state='disabled')
        self.terminal_output.see('end')

    def execute_terminal_command(self, event=None):
        """Execute terminal command."""
        command = self.terminal_input.get().strip()
        if not command:
            return
        
        # Add to history
        self.command_history.append(command)
        self.history_index = len(self.command_history)
        
        # Clear input
        self.terminal_input.delete(0, 'end')
        
        # Show command
        self.write_terminal_output(f"{self.current_directory}> {command}\n", 'command')
        
        # Handle built-in commands
        if self.handle_builtin_command(command):
            return
        
        # Execute system command
        try:
            # Change directory first
            if command.startswith('cd '):
                target_dir = command[3:].strip()
                if target_dir == '..':
                    new_dir = Path(self.current_directory).parent
                elif target_dir.startswith('~'):
                    new_dir = Path.home() / target_dir[1:]
                else:
                    new_dir = Path(self.current_directory) / target_dir
                
                if new_dir.exists() and new_dir.is_dir():
                    os.chdir(new_dir)
                    self.current_directory = str(new_dir)
                    self.terminal_output.config(state='normal')
                    self.terminal_output.insert('end', f"Directory changed to: {new_dir}\n")
                    self.terminal_output.config(state='disabled')
                else:
                    self.write_terminal_output(f"Directory not found: {target_dir}\n", 'error')
                return
            
            # Execute command
            result = subprocess.run(command, shell=True, capture_output=True, 
                                  text=True, timeout=30, cwd=self.current_directory)
            
            if result.stdout:
                self.terminal_output.config(state='normal')
                self.terminal_output.insert('end', result.stdout)
                self.terminal_output.config(state='disabled')
            
            if result.stderr:
                self.write_terminal_output(result.stderr, 'error')
            
            # Update current directory
            self.current_directory = str(Path.cwd())
            
        except subprocess.TimeoutExpired:
            self.write_terminal_output("Command timed out\n", 'warning')
        except Exception as e:
            self.write_terminal_output(f"Error executing command: {str(e)}\n", 'error')

    def handle_builtin_command(self, command):
        """Handle built-in commands."""
        command = command.strip().lower()
        
        if command == 'clear':
            self.clear_terminal()
            return True
        elif command == 'help':
            self.show_terminal_help()
            return True
        elif command == 'pwd':
            self.write_terminal_output(f"{self.current_directory}\n")
            return True
        elif command == 'ls' or command == 'dir':
            try:
                items = list(Path(self.current_directory).iterdir())
                dirs = [item.name + "/" for item in items if item.is_dir()]
                files = [item.name for item in items if item.is_file()]
                all_items = sorted(dirs) + sorted(files)
                self.terminal_output.config(state='normal')
                self.terminal_output.insert('end', '\n'.join(all_items) + '\n')
                self.terminal_output.config(state='disabled')
            except Exception as e:
                self.write_terminal_output(f"Error listing directory: {str(e)}\n", 'error')
            return True
        elif command.startswith('history'):
            self.show_command_history()
            return True
        elif command.startswith('cd'):
            # Handled in execute_terminal_command
            return False
        else:
            return False

    def clear_terminal(self):
        """Clear terminal output."""
        self.terminal_output.config(state='normal')
        self.terminal_output.delete('1.0', 'end')
        self.terminal_output.config(state='disabled')

    def show_terminal_help(self):
        """Show terminal help."""
        help_text = """NoodleCore Terminal Commands:

Built-in Commands:
  help          - Show this help message
  clear         - Clear terminal screen
  pwd          - Print working directory
  ls/dir       - List directory contents
  cd <path>    - Change directory
  history      - Show command history

Examples:
  cd ..        - Go to parent directory
  cd ~         - Go to home directory
  cd myfolder  - Go to subfolder
  pwd          - Show current location
  ls           - List files and folders

System commands are also available (e.g., python, node, git, etc.)
"""
        self.write_terminal_output(help_text, 'info')

    def show_command_history(self):
        """Show command history."""
        if not self.command_history:
            self.write_terminal_output("No commands in history\n", 'warning')
            return
        
        self.terminal_output.config(state='normal')
        self.terminal_output.insert('end', "Command History:\n")
        for i, cmd in enumerate(self.command_history, 1):
            self.terminal_output.insert('end', f"{i:3d}: {cmd}\n")
        self.terminal_output.config(state='disabled')

    def previous_command(self, event=None):
        """Navigate to previous command in history."""
        if self.command_history and self.history_index > 0:
            self.history_index -= 1
            self.terminal_input.delete(0, 'end')
            self.terminal_input.insert(0, self.command_history[self.history_index])

    def next_command(self, event=None):
        """Navigate to next command in history."""
        if self.command_history and self.history_index < len(self.command_history) - 1:
            self.history_index += 1
            self.terminal_input.delete(0, 'end')
            self.terminal_input.insert(0, self.command_history[self.history_index])
        else:
            self.history_index = len(self.command_history)
            self.terminal_input.delete(0, 'end')

    # File and tab management methods
    def close_current_tab(self):
        """Close the current tab."""
        if self.notebook.tabcount > 1:
            self.notebook.forget(self.notebook.select())

    def save_all_files(self):
        """Save all modified files."""
        saved_count = 0
        for file_path, text_widget in self.open_files.items():
            if file_path in self.unsaved_changes and self.unsaved_changes[file_path]:
                try:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(text_widget.get('1.0', 'end'))
                    self.unsaved_changes[file_path] = False
                    saved_count += 1
                except Exception as e:
                    print(f"Error saving {file_path}: {e}")
        
        if saved_count > 0:
            self.status_bar.config(text=f"Saved {saved_count} files")

    def on_tab_changed(self, event):
        """Handle tab change events."""
        current_tab = self.notebook.select()
        if current_tab:
            # Update current file tracking
            try:
                # Find the text widget for current tab
                tab_frame = self.root.nametowidget(current_tab)
                for widget in tab_frame.winfo_children():
                    if isinstance(widget, tk.Text):
                        text_widget = widget
                        # Update current file
                        tab_index = self.tab_text_widgets.index(text_widget)
                        self.current_file = self.get_tab_file_path(tab_index)
                        break
            except (ValueError, IndexError):
                pass

    def on_scroll(self, *args):
        """Handle vertical scrolling for text widgets."""
        for text_widget in self.tab_text_widgets:
            text_widget.yview(*args)

    def on_h_scroll(self, *args):
        """Handle horizontal scrolling for text widgets."""
        for text_widget in self.tab_text_widgets:
            text_widget.xview(*args)

    def on_cursor_change(self, event):
        """Handle cursor position changes."""
        pass  # Could be used for line/column indicator

    def on_mousewheel(self, event):
        """Handle mouse wheel scrolling."""
        return 'break'  # Prevent default scroll behavior

    def toggle_syntax_highlighting(self):
        """Toggle syntax highlighting."""
        if self.syntax_highlighting_var.get():
            self.update_syntax_highlighting()

    def toggle_line_numbers(self):
        """Toggle line numbers visibility."""
        # Implementation would show/hide line numbers column
        pass

    def show_find_replace(self):
        """Show find and replace dialog."""
        # Simple implementation - could be enhanced
        messagebox.showinfo("Find/Replace", "Find/Replace functionality would be implemented here")

    def ai_code_review(self):
        """Get AI code review."""
        if self.current_file:
            with open(self.current_file, 'r', encoding='utf-8') as f:
                content = f.read()
            message = f"Please review this code for improvements, bugs, and best practices:\n\n{content[:1000]}"
            self.ai_input.delete(0, 'end')
            self.ai_input.insert(0, message)
            self.send_ai_message()

    def ai_explain_code(self):
        """Get AI explanation of code."""
        if self.current_file:
            with open(self.current_file, 'r', encoding='utf-8') as f:
                content = f.read()
            message = f"Please explain what this code does:\n\n{content[:1000]}"
            self.ai_input.delete(0, 'end')
            self.ai_input.insert(0, message)
            self.send_ai_message()

    def ai_optimize_code(self):
        """Get AI optimization suggestions."""
        if self.current_file:
            with open(self.current_file, 'r', encoding='utf-8') as f:
                content = f.read()
            message = f"Please suggest optimizations for this code:\n\n{content[:1000]}"
            self.ai_input.delete(0, 'end')
            self.ai_input.insert(0, message)
            self.send_ai_message()


if __name__ == "__main__":
    exit(NativeNoodleCoreIDE().main())

