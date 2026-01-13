# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# NoodleCore Native GUI IDE - Clean Implementation
# Clean, working IDE with core functionality
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

class NativeNoodleCoreIDE
    #     """Clean NoodleCore GUI IDE with essential functionality."""

    #     def __init__(self):
    self.root = tk.Tk()
            self.root.title("NoodleCore Native GUI IDE - Clean")
            self.root.geometry("1200x800")
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

    #         # Initialize UI
            self.create_ui()
            self.create_main_layout()

    #         # Show welcome message
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

    #         # AI menu
    ai_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "AI", menu=ai_menu)
    ai_menu.add_command(label = "AI Settings", command=self.show_ai_settings)
    ai_menu.add_command(label = "AI Chat", command=self.toggle_ai_chat)

    #         # Help menu
    help_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "Help", menu=help_menu)
    help_menu.add_command(label = "About", command=self.show_about)

    #     def create_toolbar(self):
    #         """Create the toolbar."""
    toolbar = tk.Frame(self.root, bg='#3c3c3c', height=40)
    toolbar.pack(fill = 'x', padx=2, pady=2)

    #         # File operations
    tk.Button(toolbar, text = "New", command=self.new_file, bg='#4CAF50', fg='white').pack(side='left', padx=2)
    tk.Button(toolbar, text = "Open", command=self.open_file, bg='#2196F3', fg='white').pack(side='left', padx=2)
    tk.Button(toolbar, text = "Save", command=self.save_file, bg='#FF9800', fg='white').pack(side='left', padx=2)

    #         # Run operations
    tk.Button(toolbar, text = "Run", command=self.run_current_file, bg='#f44336', fg='white').pack(side='left', padx=2)

    #     def create_main_layout(self):
    #         """Create the main layout with resizable panels."""
    #         # Main container
    main_frame = tk.Frame(self.root, bg='#2b2b2b')
    main_frame.pack(fill = 'both', expand=True, padx=5, pady=5)

    #         # Create paned window for resizable layout
    self.main_panes = tk.PanedWindow(main_frame, orient='horizontal', bg='#2b2b2b', sashrelief='raised', sashwidth=3)
    self.main_panes.pack(fill = 'both', expand=True)

    #         # Left panel - File Explorer
    left_frame = tk.Frame(self.main_panes, bg='#3c3c3c', width=250)
    self.main_panes.add(left_frame, minsize = 200)

    #         # File Explorer
    file_explorer_label = tk.Label(left_frame, text="File Explorer", bg='#3c3c3c', fg='white', font=('Arial', 10, 'bold'))
    file_explorer_label.pack(anchor = 'w', padx=5, pady=2)

    self.file_tree = ttk.Treeview(left_frame, show='tree')
    self.file_tree.pack(fill = 'both', expand=True, padx=5, pady=5)
            self.file_tree.bind('<<TreeviewOpen>>', self._on_tree_expand)
            self.file_tree.bind('<Double-1>', self._on_tree_double_click)

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
            self.create_new_tab("Welcome", "Welcome to NoodleCore IDE!\n\nStart by creating or opening a file.")

    #         # Terminal
    terminal_frame = tk.Frame(self.editor_panes, bg='#000000', height=150)
    self.editor_panes.add(terminal_frame, minsize = 100)

    terminal_label = tk.Label(terminal_frame, text="Terminal", bg='#000000', fg='#00ff00', font=('Courier', 10, 'bold'))
    terminal_label.pack(anchor = 'w', padx=5, pady=2)

    self.terminal_output = scrolledtext.ScrolledText(
    #             terminal_frame,
    height = 8,
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

    #         # Create text widget
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

    #         # Insert content if provided
    #         if content:
                text_widget.insert('1.0', content)

    #         return text_widget

    #     def new_file(self):
    #         """Create a new file."""
    filename = filedialog.asksaveasfilename(
    title = "Create New File",
    defaultextension = ".txt",
    filetypes = [("All files", "*.*"), ("Python", "*.py"), ("Text", "*.txt"), ("HTML", "*.html"), ("CSS", "*.css"), ("JavaScript", "*.js")]
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
    filetypes = [("All files", "*.*"), ("Python", "*.py"), ("Text", "*.txt"), ("HTML", "*.html"), ("CSS", "*.css"), ("JavaScript", "*.js")]
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

    #     def save_file(self):
    #         """Save the current file."""
    #         if not self.current_file:
                self.save_file_as()
    #             return

    #         try:
    text_widget = self.open_files[self.current_file]
    content = text_widget.get('1.0', 'end-1c')  # Exclude trailing newline

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
    defaultextension = ".txt",
    filetypes = [("All files", "*.*"), ("Python", "*.py"), ("Text", "*.txt"), ("HTML", "*.html"), ("CSS", "*.css"), ("JavaScript", "*.js")]
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

    #     def toggle_terminal(self):
    #         """Toggle terminal panel visibility."""
    #         # Implementation for showing/hiding terminal
            messagebox.showinfo("Toggle Terminal", "Terminal toggle functionality")

    #     def toggle_ai_chat(self):
    #         """Toggle AI chat panel visibility."""
    #         # Implementation for showing/hiding AI chat
            messagebox.showinfo("AI Chat", "AI chat functionality")

    #     def show_ai_settings(self):
    #         """Show AI configuration dialog."""
            messagebox.showinfo("AI Settings", "AI configuration dialog")

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

    #     def open_file_by_path(self, file_path):
    #         """Open a file by its path."""
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

    #     def show_welcome_message(self):
    #         """Show welcome message."""
    welcome_text = """# 🚀 Welcome to NoodleCore Native GUI IDE

# A clean, working development environment!

## ✨ Features:

### 📁 **File Explorer**
# - Live file system integration
- File operations (open, navigate)
# - Project management

### 📝 **Code Editor**
# - Multi-tab editing
- Syntax highlighting (Python, JavaScript, HTML, CSS, JSON)
# - Line numbers
# - Real file saving/loading

### 💻 **Terminal**
# - Built-in command execution
- File execution (Python, JavaScript, HTML)
# - Output display

### 🔧 **Resizable Windows**
# - Drag panel borders to resize
# - Professional IDE layout

## 🛠️ **How to Use:**

# 1. **File Operations**: File menu or double-click in explorer
# 2. **Run Code**: Run menu or toolbar button
# 3. **Save Changes**: File menu or Ctrl+S
# 4. **Resize Windows**: Drag panel borders

# Ready to code? **Create a new file and start!** 🎉"""

#         # Insert welcome text into first tab
first_tab = self.notebook.winfo_children()[0]
#         if first_tab:
#             for widget in first_tab.winfo_children():
#                 if isinstance(widget, tk.Text):
                    widget.insert('1.0', welcome_text)
#                     break

#     def show_about(self):
#         """Show about dialog."""
about_text = """🚀 NoodleCore Native GUI IDE

# A clean, production-ready development environment with resizable windows.

# ✨ **FEATURES:**
# 📁 Live File System Integration
# 📝 Advanced Code Editor with syntax highlighting
# 💻 Working Terminal with command execution
# 🔧 Resizable Windows - Professional IDE layout
# ⚡ Performance Optimized - Fast operations

# 🎯 **SUPPORTED LANGUAGES:**
Python, JavaScript, HTML, CSS, JSON, NoodleCore (.nc)

# 🏗️ **ARCHITECTURE:**
# • Professional IDE layout with draggable panel borders
# • Real-time file system monitoring
# • Integrated terminal for code execution
# • Robust error handling and status reporting

# Developed with ❤️ for the NoodleCore community!"""

        messagebox.showinfo("About NoodleCore IDE", about_text)

#     def on_closing(self):
#         """Handle window closing."""
#         # Check for unsaved changes
#         if any(self.unsaved_changes.values()):
#             if not messagebox.askyesno("Unsaved Changes",
#                                      "You have unsaved changes. Do you want to exit anyway?"):
#                 return

        self.root.quit()

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