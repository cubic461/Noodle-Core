# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# AI Role Management IDE Integration
# Provides role selection and document editing interface for the NoodleCore IDE.
# """

import tkinter as tk
import tkinter.ttk,
import os
import sys
import json
import pathlib.Path
import threading
import time

# Add src directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

try
    #     from src.noodlecore.ai.role_manager import AIRoleManager, AIRoleError
except ImportError as e
        print(f"Warning: Could not import AIRoleManager: {e}")
    AIRoleManager = None


class AIRoleIDEIntegration
    #     """
    #     IDE integration component for AI role management.

    #     This class provides the GUI interface for managing AI roles,
    #     including role selection, document editing, and chat integration.
    #     """

    #     def __init__(self, parent=None, workspace_root=None):
    #         """Initialize the AI role IDE integration.

    #         Args:
    #             parent: Parent tkinter widget
    #             workspace_root: Path to workspace directory
    #         """
    self.parent = parent or tk.Tk()
    self.workspace_root = workspace_root or os.getcwd()

    #         # Initialize role manager
    self.role_manager = None
    #         if AIRoleManager:
    #             try:
    self.role_manager = AIRoleManager(self.workspace_root)
    #                 print(f"✅ AI Role Manager initialized with {len(self.role_manager.get_all_roles())} roles")
    #             except Exception as e:
                    print(f"❌ Failed to initialize AI Role Manager: {e}")

    #         # Current selected role
    self.selected_role = None
    self.current_role_content = ""

    #         # GUI components
    self.role_frame = None
    self.role_listbox = None
    self.role_details_frame = None
    self.document_text = None
    self.status_label = None

    #         # Chat integration
    self.chat_callback = None

            self.setup_ui()

    #     def setup_ui(self):
    #         """Setup the user interface components."""
    #         # Main frame
    main_frame = ttk.Frame(self.parent, padding="10")
    main_frame.grid(row = 0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

    #         # Configure grid weights
    self.parent.columnconfigure(0, weight = 1)
    self.parent.rowconfigure(0, weight = 1)
    main_frame.columnconfigure(1, weight = 1)
    main_frame.rowconfigure(2, weight = 1)

    #         # Title
    title_label = ttk.Label(main_frame, text="🤖 AI Role Management",
    font = ('Arial', 14, 'bold'))
    title_label.grid(row = 0, column=0, columnspan=2, pady=(0, 10), sticky=tk.W)

    #         # Role selection section
            self.create_role_selection_ui(main_frame)

    #         # Role details and document editor
            self.create_role_details_ui(main_frame)

    #         # Action buttons
            self.create_action_buttons(main_frame)

    #         # Status bar
    self.status_label = ttk.Label(main_frame, text="Ready", relief=tk.SUNKEN, anchor=tk.W)
    self.status_label.grid(row = 4, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(10, 0))

    #         # Load initial roles
    #         if self.role_manager:
                self.refresh_role_list()

    #     def create_role_selection_ui(self, parent):
    #         """Create the role selection user interface.

    #         Args:
    #             parent: Parent widget
    #         """
    #         # Role selection frame
    selection_frame = ttk.LabelFrame(parent, text="Available AI Roles", padding="5")
    selection_frame.grid(row = 1, column=0, columnspan=2, sticky=(tk.W, tk.E, tk.N, tk.S), pady=(0, 10))
    selection_frame.columnconfigure(0, weight = 1)
    selection_frame.rowconfigure(0, weight = 1)

    #         # Role listbox with scrollbar
    list_frame = ttk.Frame(selection_frame)
    list_frame.grid(row = 0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
    list_frame.columnconfigure(0, weight = 1)
    list_frame.rowconfigure(0, weight = 1)

    #         # Create scrollable listbox
    self.role_listbox = tk.Listbox(list_frame, font=('Arial', 10))
    scrollbar = ttk.Scrollbar(list_frame, orient=tk.VERTICAL, command=self.role_listbox.yview)
    self.role_listbox.configure(yscrollcommand = scrollbar.set)

    self.role_listbox.grid(row = 0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
    scrollbar.grid(row = 0, column=1, sticky=(tk.N, tk.S))

    #         # Bind selection event
            self.role_listbox.bind('<<ListboxSelect>>', self.on_role_select)

    #         # Role management buttons
    button_frame = ttk.Frame(selection_frame)
    button_frame.grid(row = 1, column=0, pady=(5, 0), sticky=tk.W)

    ttk.Button(button_frame, text = "➕ Add Role",
    command = self.add_role).grid(row=0, column=0, padx=(0, 5))
    ttk.Button(button_frame, text = "✏️ Edit Role",
    command = self.edit_role).grid(row=0, column=1, padx=(0, 5))
    ttk.Button(button_frame, text = "🗑️ Delete Role",
    command = self.delete_role).grid(row=0, column=2, padx=(0, 5))
    ttk.Button(button_frame, text = "🔄 Refresh",
    command = self.refresh_role_list).grid(row=0, column=3)

    #     def create_role_details_ui(self, parent):
    #         """Create the role details and document editor interface.

    #         Args:
    #             parent: Parent widget
    #         """
    #         # Details frame
    details_frame = ttk.LabelFrame(parent, text="Role Document Editor", padding="5")
    details_frame.grid(row = 2, column=0, columnspan=2, sticky=(tk.W, tk.E, tk.N, tk.S))
    details_frame.columnconfigure(0, weight = 1)
    details_frame.rowconfigure(1, weight = 1)

    #         # Role information
    info_frame = ttk.Frame(details_frame)
    info_frame.grid(row = 0, column=0, sticky=(tk.W, tk.E), pady=(0, 5))
    info_frame.columnconfigure(1, weight = 1)

    ttk.Label(info_frame, text = "Role:").grid(row=0, column=0, sticky=tk.W, padx=(0, 5))
    self.role_name_label = ttk.Label(info_frame, text="No role selected",
    font = ('Arial', 10, 'bold'))
    self.role_name_label.grid(row = 0, column=1, sticky=tk.W)

    ttk.Label(info_frame, text = "Category:").grid(row=1, column=0, sticky=tk.W, padx=(0, 5))
    self.role_category_label = ttk.Label(info_frame, text="", foreground='gray')
    self.role_category_label.grid(row = 1, column=1, sticky=tk.W)

    #         # Document text editor
    editor_frame = ttk.Frame(details_frame)
    editor_frame.grid(row = 1, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
    editor_frame.columnconfigure(0, weight = 1)
    editor_frame.rowconfigure(0, weight = 1)

    #         # Text widget with scrollbar
    self.document_text = tk.Text(editor_frame, height=15, width=80,
    font = ('Consolas', 10), wrap=tk.WORD)
    text_scrollbar = ttk.Scrollbar(editor_frame, orient=tk.VERTICAL,
    command = self.document_text.yview)
    self.document_text.configure(yscrollcommand = text_scrollbar.set)

    self.document_text.grid(row = 0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
    text_scrollbar.grid(row = 0, column=1, sticky=(tk.N, tk.S))

    #         # Bind text changes
            self.document_text.bind('<KeyRelease>', self.on_text_changed)

    #         # Character count
    self.char_count_label = ttk.Label(editor_frame, text="0 characters",
    foreground = 'gray', font=('Arial', 8))
    self.char_count_label.grid(row = 1, column=0, sticky=tk.W, pady=(2, 0))

    #     def create_action_buttons(self, parent):
    #         """Create action buttons for the interface.

    #         Args:
    #             parent: Parent widget
    #         """
    action_frame = ttk.Frame(parent)
    action_frame.grid(row = 3, column=0, columnspan=2, pady=(10, 0), sticky=tk.W)

    ttk.Button(action_frame, text = "💾 Save Changes",
    command = self.save_role_document).grid(row=0, column=0, padx=(0, 5))
    ttk.Button(action_frame, text = "📁 Open Document",
    command = self.open_document_file).grid(row=0, column=1, padx=(0, 5))
    ttk.Button(action_frame, text = "🔗 Use in Chat",
    command = self.use_role_in_chat).grid(row=0, column=2, padx=(0, 5))
    ttk.Button(action_frame, text = "📋 Copy to Clipboard",
    command = self.copy_to_clipboard).grid(row=0, column=3, padx=(0, 5))
    ttk.Button(action_frame, text = "🔍 Search Roles",
    command = self.search_roles_dialog).grid(row=0, column=4)

    #     def refresh_role_list(self):
    #         """Refresh the list of available roles."""
    #         if not self.role_manager:
                self.status_message("Role manager not available", "warning")
    #             return

    #         try:
    #             # Clear existing items
                self.role_listbox.delete(0, tk.END)

    #             # Get all roles
    roles = self.role_manager.get_all_roles()

    #             # Add roles to listbox
    #             for role in roles:
    display_text = f"{role.name} ({role.category})"
                    self.role_listbox.insert(tk.END, display_text)

                self.status_message(f"Loaded {len(roles)} roles", "info")

    #         except Exception as e:
                self.status_message(f"Failed to refresh roles: {e}", "error")

    #     def on_role_select(self, event=None):
    #         """Handle role selection from the listbox.

    #         Args:
                event: Tkinter event (optional)
    #         """
    #         if not self.role_manager:
    #             return

    #         try:
    #             # Get selected index
    selection = self.role_listbox.curselection()
    #             if not selection:
    #                 return

    index = selection[0]
    roles = self.role_manager.get_all_roles()

    #             if index >= len(roles):
    #                 return

    #             # Get selected role
    self.selected_role = roles[index]

    #             # Update UI with role information
    self.role_name_label.config(text = self.selected_role.name)
    self.role_category_label.config(text = self.selected_role.category)

    #             # Load role document content
                self.load_role_document()

                self.status_message(f"Selected role: {self.selected_role.name}", "info")

    #         except Exception as e:
                self.status_message(f"Failed to select role: {e}", "error")

    #     def load_role_document(self):
    #         """Load the document content for the selected role."""
    #         if not self.selected_role or not self.role_manager:
    #             return

    #         try:
    #             # Read role document
    content = self.role_manager.read_role_document(self.selected_role.id)
    self.current_role_content = content or ""

    #             # Update text widget
                self.document_text.delete(1.0, tk.END)
                self.document_text.insert(1.0, self.current_role_content)

    #             # Update character count
                self.update_character_count()

    #         except Exception as e:
                self.status_message(f"Failed to load document: {e}", "error")

    #     def on_text_changed(self, event=None):
    #         """Handle changes in the document text.

    #         Args:
                event: Tkinter event (optional)
    #         """
            self.update_character_count()

    #     def update_character_count(self):
    #         """Update the character count display."""
    content = self.document_text.get(1.0, tk.END)
    char_count = math.subtract(len(content), 1  # subtract the final newline)
    self.char_count_label.config(text = f"{char_count} characters")

    #     def save_role_document(self):
    #         """Save the current document content to the role."""
    #         if not self.selected_role or not self.role_manager:
                messagebox.showwarning("Warning", "No role selected")
    #             return

    #         try:
    #             # Get current content
    content = self.document_text.get(1.0, tk.END)

    #             # Save to role
                self.role_manager.write_role_document(self.selected_role.id, content)

    #             # Update current content
    self.current_role_content = content

                self.status_message("Role document saved successfully", "info")
                messagebox.showinfo("Success", "Role document saved successfully!")

    #         except Exception as e:
    error_msg = f"Failed to save document: {e}"
                self.status_message(error_msg, "error")
                messagebox.showerror("Error", error_msg)

    #     def add_role(self):
    #         """Show dialog to add a new role."""
    #         if not self.role_manager:
                messagebox.showwarning("Warning", "Role manager not available")
    #             return

    dialog = RoleEditDialog(self.parent, "Add New Role")
    #         if dialog.result:
    #             try:
    name, description, category, tags = dialog.result
    #                 tags_list = [tag.strip() for tag in tags.split(',') if tag.strip()]

    role_data = self.role_manager.create_role(
    name = name,
    description = description,
    category = category,
    tags = tags_list
    #                 )

                    self.refresh_role_list()
                    self.status_message(f"Added role: {name}", "info")
                    messagebox.showinfo("Success", f"Role '{name}' added successfully!")

    #             except Exception as e:
    error_msg = f"Failed to add role: {e}"
                    self.status_message(error_msg, "error")
                    messagebox.showerror("Error", error_msg)

    #     def edit_role(self):
    #         """Show dialog to edit the selected role."""
    #         if not self.selected_role or not self.role_manager:
                messagebox.showwarning("Warning", "No role selected")
    #             return

    dialog = RoleEditDialog(self.parent, "Edit Role",
    #                                self.selected_role.name,
    #                                self.selected_role.description,
    #                                self.selected_role.category,
                                   ', '.join(self.selected_role.tags))
    #         if dialog.result:
    #             try:
    name, description, category, tags = dialog.result
    #                 tags_list = [tag.strip() for tag in tags.split(',') if tag.strip()]

                    self.role_manager.update_role(
    #                     self.selected_role.id,
    name = name,
    description = description,
    category = category,
    tags = tags_list
    #                 )

                    self.refresh_role_list()
                    self.on_role_select()  # Refresh current role display
                    self.status_message(f"Updated role: {name}", "info")
                    messagebox.showinfo("Success", f"Role '{name}' updated successfully!")

    #             except Exception as e:
    error_msg = f"Failed to update role: {e}"
                    self.status_message(error_msg, "error")
                    messagebox.showerror("Error", error_msg)

    #     def delete_role(self):
    #         """Delete the selected role."""
    #         if not self.selected_role or not self.role_manager:
                messagebox.showwarning("Warning", "No role selected")
    #             return

    #         # Confirm deletion
    result = messagebox.askyesno("Confirm Delete",
    #                                     f"Are you sure you want to delete the role '{self.selected_role.name}'?\n\n"
    #                                     f"This will permanently remove the role and its document file.")

    #         if result:
    #             try:
    role_name = self.selected_role.name
                    self.role_manager.delete_role(self.selected_role.id)

    self.selected_role = None
                    self.document_text.delete(1.0, tk.END)
    self.role_name_label.config(text = "No role selected")
    self.role_category_label.config(text = "")
                    self.refresh_role_list()

                    self.status_message(f"Deleted role: {role_name}", "info")
                    messagebox.showinfo("Success", f"Role '{role_name}' deleted successfully!")

    #             except Exception as e:
    error_msg = f"Failed to delete role: {e}"
                    self.status_message(error_msg, "error")
                    messagebox.showerror("Error", error_msg)

    #     def open_document_file(self):
    #         """Open the role document in the system's default editor."""
    #         if not self.selected_role or not self.role_manager:
                messagebox.showwarning("Warning", "No role selected")
    #             return

    #         try:
    document_path = self.selected_role.document_path
    #             if os.path.exists(document_path):
    #                 # Open with system default editor
                    os.startfile(document_path)  # Windows
    #                 # For other platforms, you might want to use:
                    # os.system(f'xdg-open "{document_path}"')  # Linux
                    # os.system(f'open "{document_path}"')      # macOS

                    self.status_message(f"Opened document: {document_path}", "info")
    #             else:
                    messagebox.showerror("Error", f"Document file not found: {document_path}")

    #         except Exception as e:
    error_msg = f"Failed to open document: {e}"
                self.status_message(error_msg, "error")
                messagebox.showerror("Error", error_msg)

    #     def use_role_in_chat(self):
    #         """Prepare the role content for use in chat."""
    #         if not self.selected_role:
                messagebox.showwarning("Warning", "No role selected")
    #             return

    #         try:
    content = self.document_text.get(1.0, tk.END)

    #             # Store role content for chat integration
    chat_role_data = {
    #                 'name': self.selected_role.name,
    #                 'content': content,
    #                 'category': self.selected_role.category
    #             }

    #             # Save to temporary file for chat system
    temp_file = Path(self.workspace_root) / ".noodlecore" / "current_chat_role.json"
    temp_file.parent.mkdir(parents = True, exist_ok=True)

    #             with open(temp_file, 'w', encoding='utf-8') as f:
    json.dump(chat_role_data, f, indent = 2, ensure_ascii=False)

    #             # Call chat callback if available
    #             if self.chat_callback:
                    self.chat_callback(chat_role_data)

    #             self.status_message(f"Role '{self.selected_role.name}' ready for chat", "info")
    #             messagebox.showinfo("Ready for Chat",
    #                               f"Role '{self.selected_role.name}' is now configured for chat sessions.\n\n"
    #                               f"The role content will be used as context for AI responses.")

    #         except Exception as e:
    #             error_msg = f"Failed to prepare role for chat: {e}"
                self.status_message(error_msg, "error")
                messagebox.showerror("Error", error_msg)

    #     def copy_to_clipboard(self):
    #         """Copy the role document content to clipboard."""
    #         if not self.selected_role:
                messagebox.showwarning("Warning", "No role selected")
    #             return

    #         try:
    content = self.document_text.get(1.0, tk.END)
                self.parent.clipboard_clear()
                self.parent.clipboard_append(content)
                self.status_message("Content copied to clipboard", "info")
                messagebox.showinfo("Copied", "Role content copied to clipboard!")

    #         except Exception as e:
    error_msg = f"Failed to copy to clipboard: {e}"
                self.status_message(error_msg, "error")
                messagebox.showerror("Error", error_msg)

    #     def search_roles_dialog(self):
    #         """Show search dialog for roles."""
    #         if not self.role_manager:
                messagebox.showwarning("Warning", "Role manager not available")
    #             return

    query = simpledialog.askstring("Search Roles", "Enter search query:")
    #         if query:
    #             try:
    matches = self.role_manager.search_roles(query)

    #                 if matches:
    #                     # Show results in a simple dialog
    result_text = f"Found {len(matches)} matching roles:\n\n"
    #                     for role in matches:
    result_text + = f"• {role.name} ({role.category})\n  {role.description}\n\n"

                        messagebox.showinfo("Search Results", result_text)
    #                 else:
                        messagebox.showinfo("Search Results", f"No roles found matching '{query}'")

                    self.status_message(f"Search completed: {len(matches)} matches", "info")

    #             except Exception as e:
    error_msg = f"Search failed: {e}"
                    self.status_message(error_msg, "error")
                    messagebox.showerror("Error", error_msg)

    #     def set_chat_callback(self, callback):
    #         """Set callback function for chat integration.

    #         Args:
    #             callback: Function to call when role is prepared for chat
    #         """
    self.chat_callback = callback

    #     def status_message(self, message, level="info"):
    #         """Display status message.

    #         Args:
    #             message: Status message text
                level: Message level (info, warning, error)
    #         """
    #         if self.status_label:
    self.status_label.config(text = message)

    #             # Set color based on level
    colors = {
    #                 "info": "black",
    #                 "warning": "orange",
    #                 "error": "red"
    #             }
    color = colors.get(level, "black")
    self.status_label.config(foreground = color)


class RoleEditDialog
    #     """Dialog for editing role information."""

    #     def __init__(self, parent, title, name="", description="", category="general", tags=""):
    #         """Initialize the role edit dialog.

    #         Args:
    #             parent: Parent widget
    #             title: Dialog title
    #             name: Initial name value
    #             description: Initial description value
    #             category: Initial category value
    #             tags: Initial tags value
    #         """
    self.result = None

    #         # Create dialog window
    self.dialog = tk.Toplevel(parent)
            self.dialog.title(title)
            self.dialog.geometry("400x350")
            self.dialog.resizable(False, False)
            self.dialog.transient(parent)
            self.dialog.grab_set()

    #         # Center the dialog
            self.dialog.geometry("+%d+%d" % (parent.winfo_rootx() + 50, parent.winfo_rooty() + 50))

    #         # Create form
            self.create_form(name, description, category, tags)

    #         # Wait for dialog to close
            self.dialog.wait_window()

    #     def create_form(self, name, description, category, tags):
    #         """Create the form widgets.

    #         Args:
    #             name: Initial name value
    #             description: Initial description value
    #             category: Initial category value
    #             tags: Initial tags value
    #         """
    main_frame = ttk.Frame(self.dialog, padding="20")
    main_frame.grid(row = 0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

    #         # Name
    ttk.Label(main_frame, text = "Role Name:").grid(row=0, column=0, sticky=tk.W, pady=(0, 5))
    self.name_var = tk.StringVar(value=name)
    name_entry = ttk.Entry(main_frame, textvariable=self.name_var, width=40)
    name_entry.grid(row = 1, column=0, sticky=(tk.W, tk.E), pady=(0, 10))

    #         # Description
    ttk.Label(main_frame, text = "Description:").grid(row=2, column=0, sticky=tk.W, pady=(0, 5))
    self.desc_text = tk.Text(main_frame, height=4, width=40)
    self.desc_text.grid(row = 3, column=0, sticky=(tk.W, tk.E), pady=(0, 10))
            self.desc_text.insert(1.0, description)

    #         # Category
    ttk.Label(main_frame, text = "Category:").grid(row=4, column=0, sticky=tk.W, pady=(0, 5))
    self.category_var = tk.StringVar(value=category)
    category_combo = ttk.Combobox(main_frame, textvariable=self.category_var,
    values = ["general", "development", "architecture", "review",
    #                                             "debugging", "documentation", "testing", "optimization", "security"],
    width = 37)
    category_combo.grid(row = 5, column=0, sticky=(tk.W, tk.E), pady=(0, 10))

    #         # Tags
    ttk.Label(main_frame, text = "Tags (comma-separated):").grid(row=6, column=0, sticky=tk.W, pady=(0, 5))
    self.tags_var = tk.StringVar(value=tags)
    tags_entry = ttk.Entry(main_frame, textvariable=self.tags_var, width=40)
    tags_entry.grid(row = 7, column=0, sticky=(tk.W, tk.E), pady=(0, 20))

    #         # Buttons
    button_frame = ttk.Frame(main_frame)
    button_frame.grid(row = 8, column=0, pady=(10, 0))

    ttk.Button(button_frame, text = "OK", command=self.ok_clicked).grid(row=0, column=0, padx=(0, 10))
    ttk.Button(button_frame, text = "Cancel", command=self.cancel_clicked).grid(row=0, column=1)

    #         # Configure grid weights
    main_frame.columnconfigure(0, weight = 1)
    self.dialog.columnconfigure(0, weight = 1)
    self.dialog.rowconfigure(0, weight = 1)

    #     def ok_clicked(self):
    #         """Handle OK button click."""
    name = self.name_var.get().strip()
    description = self.desc_text.get(1.0, tk.END).strip()
    category = self.category_var.get().strip() or "general"
    tags = self.tags_var.get().strip()

    #         if not name:
                messagebox.showerror("Error", "Role name is required")
    #             return

    #         if not description:
                messagebox.showerror("Error", "Role description is required")
    #             return

    self.result = (name, description, category, tags)
            self.dialog.destroy()

    #     def cancel_clicked(self):
    #         """Handle Cancel button click."""
            self.dialog.destroy()


function main()
    #     """Main function to test the AI Role IDE integration."""
    root = tk.Tk()
        root.title("NoodleCore AI Role Manager")
        root.geometry("800x600")

    #     # Create role integration
    role_integration = AIRoleIDEIntegration(root)

    #     # Example chat callback
    #     def chat_callback(role_data):
    #         print(f"Chat callback: Role '{role_data['name']}' prepared for chat")

        role_integration.set_chat_callback(chat_callback)

    #     # Start the GUI
        root.mainloop()


if __name__ == "__main__"
        main()