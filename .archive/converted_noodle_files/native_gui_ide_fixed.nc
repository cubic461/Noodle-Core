# Converted from Python to NoodleCore
# Original file: noodle-core

# NoodleCore converted from Python
# """
# NoodleCore Native GUI IDE - Fixed Version
# A complete native GUI IDE for NoodleCore development
# """

import tkinter as tk
import tkinter.ttk,
import sys
import os
import subprocess
import pathlib.Path
import time

class NoodleCoreIDE
    #     """Main NoodleCore Native GUI IDE class."""

    #     def __init__(self):
    self.root = tk.Tk()
            self.root.title("NoodleCore Native GUI IDE")
            self.root.geometry("1400x900")
    self.root.configure(bg = '#2b2b2b')

    #         # Initialize variables
    self.open_files = {}
    self.current_project = None

    #         # Create GUI
            self.create_menu()
            self.create_main_layout()

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
    #         self.create_new_tab("Welcome to NoodleCore IDE", "# Welcome to NoodleCore Native GUI IDE\n\nThis is a complete IDE for NoodleCore development.\n\nFeatures:\n- Native GUI with resizable panels\n- Multi-provider AI integration\n- Code editor with auto-completion\n- File explorer and project management\n- Integrated terminal console\n- NoodleCore execution support\n\nStart by opening a file or creating a new project!")

    #         # Bottom panel for AI and Terminal
    bottom_panel = ttk.Frame(right_panel)
    bottom_panel.pack(fill = 'both', expand=False, pady=(0, 2))

    #         # AI Chat panel
    ai_frame = ttk.LabelFrame(bottom_panel, text="AI Assistant", padding=5)
    ai_frame.pack(side = 'left', fill='both', expand=True, padx=(0, 2))

    self.ai_chat_output = scrolledtext.ScrolledText(ai_frame, height=8, bg='#1e1e1e', fg='#ffffff',
    font = ('Consolas', 10))
    self.ai_chat_output.pack(fill = 'both', expand=True)

    #         # AI input
    ai_input_frame = ttk.Frame(ai_frame)
    ai_input_frame.pack(fill = 'x', pady=(5, 0))

    self.ai_provider_var = tk.StringVar(value="openai")
    provider_combo = ttk.Combobox(ai_input_frame, textvariable=self.ai_provider_var, width=12,
    values = ["openai", "anthropic", "openrouter", "lm_studio", "ollama"])
    provider_combo.pack(side = 'left', padx=(0, 2))

    self.ai_model_var = tk.StringVar(value="gpt-3.5-turbo")
    model_combo = ttk.Combobox(ai_input_frame, textvariable=self.ai_model_var, width=15,
    values = ["gpt-3.5-turbo", "gpt-4", "claude-3-sonnet", "claude-3-haiku"])
    model_combo.pack(side = 'left', padx=(0, 2))

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

    #         response = f"AI ({provider}/{model}): I'm the NoodleCore AI assistant. I can help you with NoodleCore development, code analysis, and general programming questions. What would you like to do?"
            self.ai_chat_output.insert('end', f"User: [AI Request]\n")
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
            messagebox.showinfo("AI Settings", "AI Configuration:\n\nProvider: {}\nModel: {}\n\nConfigure your AI provider settings here.".format(
                self.ai_provider_var.get(), self.ai_model_var.get()))

    #     def clear_ai_history(self):
    #         """Clear AI chat history."""
            self.ai_chat_output.delete('1.0', 'end')

    #     def show_about(self):
    #         """Show about dialog."""
    #         messagebox.showinfo("About", "NoodleCore Native GUI IDE\nVersion 1.0\n\nA complete IDE for NoodleCore development with AI integration.")

    #     def run(self):
    #         """Run the IDE."""
    #         # Add initial AI welcome message
            self.ai_chat_output.insert('end', "Welcome to NoodleCore Native GUI IDE!\n\n")
            self.ai_chat_output.insert('end', "This IDE provides:\n")
    #         self.ai_chat_output.insert('end', "• Native GUI with resizable panels\n")
            self.ai_chat_output.insert('end', "• Multi-provider AI integration\n")
    #         self.ai_chat_output.insert('end', "• Code editor with auto-completion\n")
            self.ai_chat_output.insert('end', "• File explorer and project management\n")
            self.ai_chat_output.insert('end', "• Integrated terminal console\n")
            self.ai_chat_output.insert('end', "• NoodleCore execution support\n\n")
            self.ai_chat_output.insert('end', "Start by opening a file or creating a new project!\n\n")

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