# Converted from Python to NoodleCore
# Original file: noodle-core


#!/usr/bin/env python3
# """
LEGACY/EXPERIMENTAL IDE IMPLEMENTATION (DEPRECATED)

# This file is kept ONLY for historical/reference purposes.

# Canonical desktop IDE:
# - Implementation: native_gui_ide.py::NativeNoodleCoreIDE
# - Launcher: launch_native_ide.py → NativeNoodleCoreIDE

# Do NOT import or use this module in new code.
# All launch scripts MUST delegate to launch_native_ide.py.
# """

# Minimal shim kept to avoid accidental runtime usage.
# If executed directly, redirect to canonical launcher.
import sys
import os
import pathlib.Path

function main()
    root = Path(__file__).resolve().parents[3]
    launcher = root / "src" / "noodlecore" / "desktop" / "ide" / "launch_native_ide.py"
    #     if launcher.exists():
            os.execv(sys.executable, [sys.executable, str(launcher)])
    #     else:
            sys.stderr.write(
    #             "ERROR: Canonical launcher 'launch_native_ide.py' not found.\n"
    #             "This legacy script is deprecated. Please update your setup to use the canonical IDE.\n"
    #         )
            sys.exit(1)

if __name__ == "__main__"
        main()

    #     def __init__(self):
    self.root = tk.Tk()
            self.root.title("NoodleCore Native GUI IDE")
            self.root.geometry("1200x800")
    self.root.configure(bg = '#2b2b2b')

    #         # AI configuration
    self.ai_providers = {
    #             "OpenRouter": {
    #                 "models": ["gpt-3.5-turbo", "gpt-4", "claude-3-haiku", "claude-3-sonnet"],
    #                 "api_key_required": True,
    #                 "base_url": "https://openrouter.ai/api/v1"
    #             },
    #             "OpenAI": {
    #                 "models": ["gpt-3.5-turbo", "gpt-4", "gpt-4-turbo"],
    #                 "api_key_required": True,
    #                 "base_url": "https://api.openai.com/v1"
    #             },
    #             "Z.ai": {
    #                 "models": ["z-ai-model-1", "z-ai-model-2"],
    #                 "api_key_required": True,
    #                 "base_url": "https://z.ai/api/v1"
    #             },
    #             "LM Studio": {
    #                 "models": ["llama-2-7b", "llama-2-13b", "codellama-7b"],
    #                 "api_key_required": False,
    #                 "base_url": "http://localhost:1234/v1"
    #             },
    #             "Ollama": {
    #                 "models": ["llama2", "codellama", "mistral"],
    #                 "api_key_required": False,
    #                 "base_url": "http://localhost:11434"
    #             }
    #         }

    self.current_ai_provider = "OpenRouter"
    self.current_ai_model = "gpt-3.5-turbo"
    self.ai_api_key = ""

    #         # Open files tracking
    self.open_files = {}

            self.setup_ui()
            self.setup_file_operations()
            self.setup_ai_interface()

    #     def setup_ui(self):
    #         """Setup the main UI components."""
    #         # Create main layout
    self.root.grid_rowconfigure(0, weight = 1)
    self.root.grid_columnconfigure(1, weight = 1)

    #         # Menu bar
            self.create_menu_bar()

            # Left panel (File Explorer + AI Settings)
            self.create_left_panel()

            # Center panel (Code Editor)
            self.create_code_editor()

            # Right panel (Terminal + AI Chat)
            self.create_right_panel()

    #         # Status bar
            self.create_status_bar()

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
    file_menu.add_command(label = "Exit", command=self.root.quit)

    #         # Run menu
    run_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "Run", menu=run_menu)
    run_menu.add_command(label = "Run Current File", command=self.run_current_file)

    #         # AI menu
    ai_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "AI", menu=ai_menu)
    ai_menu.add_command(label = "AI Settings", command=self.show_ai_settings)

    #         # Help menu
    help_menu = tk.Menu(menubar, tearoff=0)
    menubar.add_cascade(label = "Help", menu=help_menu)
    help_menu.add_command(label = "About", command=self.show_about)

    #     def create_left_panel(self):
    #         """Create the left panel with file explorer and AI settings."""
    left_frame = tk.Frame(self.root, width=300, bg='#2b2b2b')
    left_frame.grid(row = 0, column=0, sticky='nsew')
    left_frame.grid_rowconfigure(0, weight = 1)
    left_frame.grid_rowconfigure(1, weight = 1)

    #         # File Explorer
    explorer_frame = tk.LabelFrame(left_frame, text="File Explorer", bg='#2b2b2b', fg='white')
    explorer_frame.grid(row = 0, column=0, sticky='nsew', padx=5, pady=5)

    self.file_tree = ttk.Treeview(explorer_frame, show='tree')
    self.file_tree.pack(fill = 'both', expand=True, padx=5, pady=5)

    #         # Populate file tree with current directory
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

    #         # Save button
    save_btn = tk.Button(ai_frame, text="Save Settings", command=self.save_ai_settings,
    bg = '#4CAF50', fg='white')
    save_btn.pack(fill = 'x', padx=5, pady=5)

    #     def create_code_editor(self):
    #         """Create the main code editor area."""
    center_frame = tk.Frame(self.root, bg='#2b2b2b')
    center_frame.grid(row = 0, column=1, sticky='nsew')
    center_frame.grid_rowconfigure(0, weight = 1)
    center_frame.grid_columnconfigure(0, weight = 1)

    #         # Tab control for multiple files
    self.notebook = ttk.Notebook(center_frame)
    self.notebook.grid(row = 0, column=0, sticky='nsew', padx=5, pady=5)

    #         # Create initial tab
            self.create_new_tab("Untitled")

    #     def create_right_panel(self):
    #         """Create the right panel with terminal and AI chat."""
    right_frame = tk.Frame(self.root, width=350, bg='#2b2b2b')
    right_frame.grid(row = 0, column=2, sticky='nsew')
    right_frame.grid_rowconfigure(0, weight = 1)
    right_frame.grid_rowconfigure(1, weight = 1)

    #         # Terminal
    terminal_frame = tk.LabelFrame(right_frame, text="Terminal", bg='#2b2b2b', fg='white')
    terminal_frame.grid(row = 0, column=0, sticky='nsew', padx=5, pady=5)

    self.terminal_output = scrolledtext.ScrolledText(terminal_frame,
    bg = '#1e1e1e', fg='#ffffff',
    font = ('Consolas', 10))
    self.terminal_output.pack(fill = 'both', expand=True, padx=5, pady=5)

    #         # Terminal input
    input_frame = tk.Frame(terminal_frame, bg='#2b2b2b')
    input_frame.pack(fill = 'x', padx=5, pady=(0, 5))

    tk.Label(input_frame, text = "$ ", bg='#2b2b2b', fg='white').pack(side='left')

    self.terminal_input = tk.Entry(input_frame, bg='#1e1e1e', fg='#ffffff',
    font = ('Consolas', 10), relief='flat')
    self.terminal_input.pack(side = 'left', fill='x', expand=True)
            self.terminal_input.bind('<Return>', self.execute_terminal_command)

    #         # Execute button
    exec_btn = tk.Button(input_frame, text="Execute", command=self.execute_terminal_command,
    bg = '#4CAF50', fg='white')
    exec_btn.pack(side = 'right', padx=(5, 0))

    #         # AI Chat
    ai_chat_frame = tk.LabelFrame(right_frame, text="AI Assistant", bg='#2b2b2b', fg='white')
    ai_chat_frame.grid(row = 1, column=0, sticky='nsew', padx=5, pady=5)

    self.ai_chat_output = scrolledtext.ScrolledText(ai_chat_frame,
    bg = '#1e1e1e', fg='#ffffff',
    font = ('Consolas', 10))
    self.ai_chat_output.pack(fill = 'both', expand=True, padx=5, pady=5)

    #         # AI input
    ai_input_frame = tk.Frame(ai_chat_frame, bg='#2b2b2b')
    ai_input_frame.pack(fill = 'x', padx=5, pady=(0, 5))

    self.ai_input = tk.Entry(ai_input_frame, bg='#1e1e1e', fg='#ffffff',
    font = ('Consolas', 10), relief='flat')
    self.ai_input.pack(side = 'left', fill='x', expand=True)

 = ('left', fill='x', expand=True)
        self.ai_input.bind('<Return>', self.send_ai_request)

send_btn = tk.Button(ai_input_frame, text="Send", command=self.send_ai_request, bg='#2196F3', fg='white')
send_btn.pack(side = 'right', padx=(5, 0))

#     def create_status_bar(self):
#         """Create the status bar."""
self.status_bar = tk.Label(self.root, text="Ready", relief='sunken', anchor='w',
bg = '#3c3c3c', fg='white')
self.status_bar.grid(row = 1, column=0, columnspan=3, sticky='ew')

#     def setup_file_operations(self):
#         """Setup file operation handlers."""
        self.file_tree.bind('<Double-1>', self.on_file_double_click)

#     def setup_ai_interface(self):
#         """Setup AI interface."""
        self.on_provider_change()

#     def refresh_file_tree(self):
#         """Refresh the file explorer tree."""
#         for item in self.file_tree.get_children():
            self.file_tree.delete(item)

current_dir = Path.cwd()
self.file_tree.insert('', 'end', text = str(current_dir), open=True)

#         for item in current_dir.iterdir():
#             if item.is_dir():
self.file_tree.insert('', 'end', text = f"📁 {item.name}")
#             else:
self.file_tree.insert('', 'end', text = f"📄 {item.name}")

#     def on_file_double_click(self, event):
#         """Handle double-click on file tree items."""
#         selection = self.file_tree.selection()[0] if self.file_tree.selection() else None
#         if selection:
file_text = self.file_tree.item(selection)['text']
#             if not file_text.startswith('📁'):
#                 filename = file_text[2:] if file_text.startswith('📄 ') else file_text
                self.open_file(filename)

#     def new_file(self):
#         """Create a new file."""
        self.create_new_tab("Untitled")

#     def open_file(self, filename=None):
#         """Open a file."""
#         if filename is None:
filename = filedialog.askopenfilename(
filetypes = [("NoodleCore files", "*.nc"), ("Python files", "*.py"), ("All files", "*.*")]
#             )

#         if filename:
#             try:
#                 with open(filename, 'r', encoding='utf-8') as f:
content = f.read()

                self.create_new_tab(filename, content)
self.status_bar.config(text = f"Opened: {filename}")

#             except Exception as e:
                messagebox.showerror("Error", f"Could not open file: {e}")

#     def save_file(self):
#         """Save current file."""
current_tab = self.notebook.select()
#         if current_tab:
tab_frame = self.notebook.nametowidget(current_tab)
text_widget = tab_frame.winfo_children()[0]

content = text_widget.get('1.0', 'end-1c')
tab_info = self.open_files.get(current_tab, {})

#             if tab_info.get('filename'):
#                 try:
#                     with open(tab_info['filename'], 'w', encoding='utf-8') as f:
                        f.write(content)
self.status_bar.config(text = f"Saved: {tab_info['filename']}")
self.notebook.tab(current_tab, text = Path(tab_info['filename']).name)
self.open_files[current_tab]['modified'] = False
#                 except Exception as e:
                    messagebox.showerror("Error", f"Could not save file: {e}")
#             else:
                self.save_file_as()

#     def save_file_as(self):
#         """Save current file as new file."""
filename = filedialog.asksaveasfilename(
defaultextension = ".nc",
filetypes = [("NoodleCore files", "*.nc"), ("Python files", "*.py"), ("All files", "*.*")]
#         )

#         if filename:
current_tab = self.notebook.select()
#             if current_tab:
tab_frame = self.notebook.nametowidget(current_tab)
text_widget = tab_frame.winfo_children()[0]

content = text_widget.get('1.0', 'end-1c')

#                 try:
#                     with open(filename, 'w', encoding='utf-8') as f:
                        f.write(content)

self.status_bar.config(text = f"Saved: {filename}")
self.notebook.tab(current_tab, text = Path(filename).name)
self.open_files[current_tab] = {'filename': filename, 'modified': False}

#                 except Exception as e:
                    messagebox.showerror("Error", f"Could not save file: {e}")

#     def create_new_tab(self, title, content=""):
#         """Create a new tab with text editor."""
frame = tk.Frame(self.notebook, bg='#2b2b2b')

text_widget = scrolledtext.ScrolledText(frame, bg='#1e1e1e', fg='#ffffff',
font = ('Consolas', 12), wrap='word')
text_widget.pack(fill = 'both', expand=True, padx=5, pady=5)
        text_widget.insert('1.0', content)

tab_id = self.notebook.add(frame, text=title)
        self.notebook.select(tab_id)

#         self.open_files[tab_id] = {'filename': None if title == "Untitled" else title, 'modified': False}

#         return tab_id

#     def run_current_file(self):
#         """Run the current file."""
current_tab = self.notebook.select()
#         if current_tab:
tab_info = self.open_files.get(current_tab, {})
#             if tab_info.get('filename'):
                self.run_file(tab_info['filename'])
#             else:
                messagebox.showwarning("Save Required", "Please save the file before running.")

#     def run_file(self, filename):
#         """Run a file."""
        self.terminal_output.insert('end', f"\n$ Running {filename}...\n")
        self.terminal_output.see('end')

#         try:
#             if filename.endswith('.nc'):
result = subprocess.run(['python', filename],
capture_output = True, text=True, cwd=Path(filename).parent)
                self.terminal_output.insert('end', f"Output:\n{result.stdout}\n")
#                 if result.stderr:
                    self.terminal_output.insert('end', f"Error:\n{result.stderr}\n")
#             elif filename.endswith('.py'):
result = subprocess.run(['python', filename],
capture_output = True, text=True, cwd=Path(filename).parent)
                self.terminal_output.insert('end', f"Output:\n{result.stdout}\n")
#                 if result.stderr:
                    self.terminal_output.insert('end', f"Error:\n{result.stderr}\n")
#             else:
                self.terminal_output.insert('end', f"Unsupported file type: {filename}\n")
#         except Exception as e:
            self.terminal_output.insert('end', f"Error running file: {e}\n")

        self.terminal_output.see('end')

#     def execute_terminal_command(self, event=None):
#         """Execute a terminal command."""
command = self.terminal_input.get().strip()
#         if command:
            self.terminal_output.insert('end', f"$ {command}\n")
            self.terminal_input.delete(0, 'end')

#             try:
result = subprocess.run(command, shell=True, capture_output=True, text=True)
#                 if result.stdout:
                    self.terminal_output.insert('end', f"{result.stdout}\n")
#                 if result.stderr:
                    self.terminal_output.insert('end', f"Error: {result.stderr}\n")
#             except Exception as e:
                self.terminal_output.insert('end', f"Error executing command: {e}\n")

            self.terminal_output.see('end')

#     def send_ai_request(self, event=None):
#         """Send an AI request."""
message = self.ai_input.get().strip()
#         if message:
            self.ai_chat_output.insert('end', f"User: {message}\n")
            self.ai_input.delete(0, 'end')

#             response = "I can help you with your NoodleCore code. What would you like to do?"
            self.ai_chat_output.insert('end', f"AI: {response}\n\n")
            self.ai_chat_output.see('end')

#     def on_provider_change(self, event=None):
#         """Handle AI provider change."""
provider = self.provider_var.get()
#         if provider in self.ai_providers:
models = self.ai_providers[provider]['models']
self.model_combo['values'] = models
#             self.model_var.set(models[0] if models else "")

#     def save_ai_settings(self):
#         """Save AI settings."""
self.current_ai_provider = self.provider_var.get()
self.current_ai_model = self.model_var.get()
self.ai_api_key = self.api_key_var.get()

        messagebox.showinfo("Settings Saved", f"AI settings saved:\nProvider: {self.current_ai_provider}\nModel: {self.current_ai_model}")

#     def show_ai_settings(self):
#         """Show AI settings dialog."""
#         settings
_window = tk.Toplevel(self.root)
        settings_window.title("AI Settings")
        settings_window.geometry("400x300")
settings_window.configure(bg = '#2b2b2b')

tk.Label(settings_window, text = "Current Settings", bg='#2b2b2b', fg='white', font=('Arial', 12, 'bold')).pack(pady=10)

settings_text = f"Provider: {self.current_ai_provider}\nModel: {self.current_ai_model}\nAPI Key: {'*' * len(self.ai_api_key)}"
tk.Label(settings_window, text = settings_text, bg='#2b2b2b', fg='white', justify='left').pack(pady=10)

tk.Button(settings_window, text = "Close", command=settings_window.destroy, bg='#f44336', fg='white').pack(pady=20)

#     def show_about(self):
#         """Show about dialog."""
#         messagebox.showinfo("About", "NoodleCore Native GUI IDE\nVersion 1.0\n\nA complete IDE for NoodleCore development with AI integration.")

#     def run(self):
#         """Run the IDE."""
        self.root.mainloop()


# Additional classes for testing
class AIProviderManager
    #     """Mock AI provider manager for testing."""

    #     def __init__(self):
    self.providers = [
                type('Provider', (), {
    #                 'name': 'openai',
    #                 'models': ['gpt-4', 'gpt-3.5-turbo']
                })(),
                type('Provider', (), {
    #                 'name': 'anthropic',
    #                 'models': ['claude-3-sonnet', 'claude-3-haiku']
                })(),
                type('Provider', (), {
    #                 'name': 'openrouter',
    #                 'models': ['gpt-3.5-turbo', 'gpt-4', 'claude-3-haiku']
                })(),
                type('Provider', (), {
    #                 'name': 'lm_studio',
    #                 'models': ['llama-2-7b', 'codellama-7b']
                })(),
                type('Provider', (), {
    #                 'name': 'ollama',
    #                 'models': ['llama2', 'codellama', 'mistral']
                })()
    #         ]

    #     def get_available_providers(self):
    #         return self.providers


class NoodleCoreCodeEditor
    #     """Mock code editor for testing."""

    #     def analyze_code(self, code):
    #         return {
    #             "issues": [],
                "metrics": {"lines_of_code": len(code.split('\n'))},
    #             "ai_analysis": {"summary": "Code analysis complete"}
    #         }


class ProjectExplorer
    #     """Mock project explorer for testing."""

    #     def __init__(self):
    self.current_project = None

    #     def open_project(self, project_path):
    self.current_project = project_path
    #         return True


class TerminalConsole
    #     """Mock terminal console for testing."""

    #     def execute_command(self, command):
    #         return {
    #             "success": True,
    #             "output": f"Mock output for: {command}",
    #             "error": None
    #         }


class NativeGUIFramework
    #     """Mock GUI framework for testing."""

    #     def __init__(self):
    self.panel_sizes = {}

    #     def initialize_layout(self, width, height):
    self.panel_sizes = {
                "file_explorer": (300, height),
                "code_editor": (width - 600, height),
                "ai_panel": (300, height // 2),
                "terminal": (300, height // 2)
    #         }
    #         return True


class NativeNoodleCoreIDE
    #     """Mock integrated IDE for testing."""

    #     def __init__(self):
    self.initialized = False
    self.active_ai_provider = None
    self.open_files = []
    self.current_project = None

    #     def initialize(self):
    self.initialized = True
    #         return True

    #     def get_ai_providers(self):
    #         return ["openai", "anthropic", "openrouter", "lm_studio", "ollama"]


function main()
    #     """Main entry point for the IDE."""
    #     try:
    ide = NoodleCoreIDE()
            ide.run()
    #     except Exception as e:
            print(f"Error starting IDE: {e}")
            sys.exit(1)


if __name__ == "__main__"
        main()