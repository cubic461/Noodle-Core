# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Enhanced AI Role Document Manager for NoodleCore IDE
# Integrates the role document editor with the existing IDE interface.
# """

import tkinter as tk
import tkinter.ttk
import os
import sys

# Add src directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

try
    #     from src.noodlecore.ide.ai_role_integration import AIRoleIDEIntegration
    #     from src.noodlecore.ai.role_manager import AIRoleManager
except ImportError as e
        print(f"Warning: Could not import AI role components: {e}")
    AIRoleIDEIntegration = None
    AIRoleManager = None


class EnhancedAIRoleManager
    #     """
    #     Enhanced AI Role Manager that integrates with the existing IDE.
    #     Provides seamless role document editing capabilities.
    #     """

    #     def __init__(self, parent_ide=None, workspace_root=None):
    #         """Initialize the enhanced AI role manager.

    #         Args:
    #             parent_ide: Reference to the parent IDE instance
    #             workspace_root: Path to workspace directory
    #         """
    self.parent_ide = parent_ide
    self.workspace_root = workspace_root or os.getcwd()

    #         # Initialize role manager
    self.role_manager = None
    #         if AIRoleManager:
    #             try:
    self.role_manager = AIRoleManager(self.workspace_root)
    #                 print(f"✅ Enhanced AI Role Manager initialized with {len(self.role_manager.get_all_roles())} roles")
    #             except Exception as e:
                    print(f"❌ Failed to initialize Enhanced AI Role Manager: {e}")

    #         # Current integration window
    self.integration_window = None
    self.role_integration = None

    #     def open_role_document_manager(self):
    #         """Open the AI role document manager interface."""
    #         if not AIRoleIDEIntegration:
    #             # Fallback message if integration module is not available
    message = """
# AI Role Document Management

# Since the AI role integration module is not available,
# here are the available roles and their document paths:

# """
#             try:
#                 if self.role_manager:
roles = self.role_manager.get_all_roles()
#                     for role in roles:
message + = f"📝 {role.name} ({role.category})\n"
message + = f"   Document: {role.document_path}\n"
message + = f"   Description: {role.description}\n\n"
#                 else:
message + = "❌ Role manager not available"

#                 # Show in a simple window
                self.show_simple_role_info(message)
#             except Exception as e:
                print(f"Error showing role info: {e}")
#             return

#         # Create integration window
self.integration_window = tk.Toplevel()
        self.integration_window.title("🤖 AI Role Document Manager")
        self.integration_window.geometry("900x700")
self.integration_window.configure(bg = '#1e1e1e')

#         # Center the window
        self.integration_window.geometry("+%d+%d" % (
            self.parent_ide.root.winfo_rootx() + 50,
            self.parent_ide.root.winfo_rooty() + 50
#         ))

#         # Create the role integration interface
self.role_integration = AIRoleIDEIntegration(self.integration_window, self.workspace_root)

#         # Set up callback for chat integration
#         def chat_callback(role_data):
#             if self.parent_ide:
#                 # Update the parent IDE with the selected role
self.parent_ide.current_ai_role = self.find_role_by_name(role_data['name'])
#                 if self.parent_ide.current_ai_role:
                    self.parent_ide.role_var.set(role_data['name'])
                    self.parent_ide.on_role_change()

#                 # Show notification
#                 if hasattr(self.parent_ide, 'show_toast'):
                    self.parent_ide.show_toast(
#                         f"🤖 Role '{role_data['name']}' is now active for chat!",
#                         self.parent_ide.ToastType.SUCCESS
#                     )

        self.role_integration.set_chat_callback(chat_callback)

#         # Add close button
close_frame = tk.Frame(self.integration_window, bg='#2d2d30')
close_frame.pack(fill = 'x', padx=10, pady=(0, 10))

close_btn = tk.Button(close_frame, text="Close",
command = self.close_integration_window,
bg = '#f48771', fg='white',
font = ('Segoe UI', 10, 'bold'))
close_btn.pack(side = 'right', padx=10, pady=5)

#         # Add status label
status_label = tk.Label(close_frame,
#                                text="Manage AI role documents and configure them for chat",
bg = '#2d2d30', fg='#cccccc',
font = ('Segoe UI', 9))
status_label.pack(side = 'left', padx=10, pady=8)

#     def close_integration_window(self):
#         """Close the role integration window."""
#         if self.integration_window:
            self.integration_window.destroy()
self.integration_window = None
self.role_integration = None

#     def show_simple_role_info(self, message):
#         """Show role information in a simple window."""
window = tk.Toplevel()
        window.title("AI Role Information")
        window.geometry("600x400")
window.configure(bg = '#252526')

#         # Center the window
        window.geometry("+%d+%d" % (
            self.parent_ide.root.winfo_rootx() + 100,
            self.parent_ide.root.winfo_rooty() + 100
#         ))

#         # Text widget to display information
text_widget = tk.Text(window, bg='#1e1e1e', fg='#d4d4d4',
font = ('Consolas', 10), wrap=tk.WORD,
padx = 10, pady=10)
text_widget.pack(fill = 'both', expand=True, padx=10, pady=10)
        text_widget.insert('1.0', message)
text_widget.config(state = 'disabled')

#         # Close button
close_btn = tk.Button(window, text="Close", command=window.destroy,
bg = '#007acc', fg='white',
font = ('Segoe UI', 10, 'bold'))
close_btn.pack(pady = 10)

#     def find_role_by_name(self, role_name):
#         """Find a role by name.

#         Args:
#             role_name: Name of the role to find

#         Returns:
#             Role object or None if not found
#         """
#         if not self.role_manager:
#             return None

#         try:
roles = self.role_manager.get_all_roles()
#             for role in roles:
#                 if role.name == role_name:
#                     return role
#         except Exception as e:
            print(f"Error finding role by name: {e}")

#         return None

#     def get_role_document_content(self, role_name):
#         """Get the document content for a specific role.

#         Args:
#             role_name: Name of the role

#         Returns:
#             Document content string or None if not found
#         """
role = self.find_role_by_name(role_name)
#         if not role or not self.role_manager:
#             return None

#         try:
            return self.role_manager.read_role_document(role.id)
#         except Exception as e:
            print(f"Error reading role document: {e}")
#             return None

#     def update_role_document(self, role_name, content):
#         """Update the document content for a specific role.

#         Args:
#             role_name: Name of the role
#             content: New document content

#         Returns:
#             True if successful, False otherwise
#         """
role = self.find_role_by_name(role_name)
#         if not role or not self.role_manager:
#             return False

#         try:
            return self.role_manager.write_role_document(role.id, content)
#         except Exception as e:
            print(f"Error updating role document: {e}")
#             return False

#     def get_all_roles_summary(self):
#         """Get a summary of all available roles.

#         Returns:
#             Dictionary with role summaries
#         """
#         if not self.role_manager:
#             return {"error": "Role manager not available"}

#         try:
roles = self.role_manager.get_all_roles()
summary = {
                "total_roles": len(roles),
#                 "roles": []
#             }

#             for role in roles:
role_info = {
#                     "name": role.name,
#                     "category": role.category,
#                     "description": role.description,
                    "document_exists": os.path.exists(role.document_path),
#                     "tags": role.tags,
#                     "created_at": role.created_at
#                 }
                summary["roles"].append(role_info)

#             return summary

#         except Exception as e:
#             return {"error": f"Error getting roles summary: {e}"}


function create_demo_integration()
    #     """Create a demo showing the enhanced AI role management."""

    #     # Create main demo window
    root = tk.Tk()
        root.title("🎯 NoodleCore AI Role Document Management Demo")
        root.geometry("800x600")
    root.configure(bg = '#1e1e1e')

    #     # Demo header
    header = tk.Label(root, text="🤖 AI Role Document Management System",
    bg = '#1e1e1e', fg='#d4d4d4',
    font = ('Segoe UI', 16, 'bold'))
    header.pack(pady = 20)

    description = tk.Label(root,
    #                           text="Manage AI roles with editable text documents\n"
    #                                "that can be selected and used during AI chats",
    bg = '#1e1e1e', fg='#999999',
    font = ('Segoe UI', 11),
    justify = 'center')
    description.pack(pady = (0, 30))

    #     # Features showcase
    features_frame = tk.LabelFrame(root, text="✨ Features",
    bg = '#252526', fg='#d4d4d4',
    font = ('Segoe UI', 12, 'bold'))
    features_frame.pack(fill = 'x', padx=20, pady=10)

    features = [
    #         "📝 Editable text documents for each AI role",
    #         "🎯 Role selection dropdown in IDE",
    #         "💬 Document content used during AI chats",
    #         "📂 Role documents stored as separate .md files",
    #         "🔄 Real-time document editing and updates",
    #         "📋 Role categorization and tagging",
    #         "🔍 Role search and management",
    #         "📤 Export/import role configurations"
    #     ]

    #     for feature in features:
    feature_label = tk.Label(features_frame, text=feature,
    bg = '#252526', fg='#cccccc',
    font = ('Segoe UI', 10),
    anchor = 'w')
    feature_label.pack(fill = 'x', padx=10, pady=2)

    #     # Demo buttons
    demo_frame = tk.LabelFrame(root, text="🚀 Demo Actions",
    bg = '#252526', fg='#d4d4d4',
    font = ('Segoe UI', 12, 'bold'))
    demo_frame.pack(fill = 'x', padx=20, pady=20)

    #     # Initialize enhanced role manager
    enhanced_manager = EnhancedAIRoleManager(workspace_root='.')

    #     def demo_role_management():
    #         """Demonstrate role management functionality."""
            enhanced_manager.open_role_document_manager()

    #     def demo_role_summary():
    #         """Show role summary information."""
    summary = enhanced_manager.get_all_roles_summary()

    summary_window = tk.Toplevel(root)
            summary_window.title("📊 AI Roles Summary")
            summary_window.geometry("600x400")
    summary_window.configure(bg = '#252526')

    #         # Center the window
            summary_window.geometry("+%d+%d" % (
                root.winfo_rootx() + 100,
                root.winfo_rooty() + 100
    #         ))

    #         # Display summary
    text_widget = tk.Text(summary_window, bg='#1e1e1e', fg='#d4d4d4',
    font = ('Consolas', 10), wrap=tk.WORD,
    padx = 10, pady=10)
    text_widget.pack(fill = 'both', expand=True, padx=10, pady=10)

    #         if "error" in summary:
                text_widget.insert('1.0', f"Error: {summary['error']}")
    #         else:
    content = f"📊 AI Roles Summary\n"
    content + = f"Total Roles: {summary['total_roles']}\n\n"

    #             for role in summary['roles']:
    content + = f"📝 {role['name']} ({role['category']})\n"
    content + = f"   Description: {role['description']}\n"
    #                 content += f"   Tags: {', '.join(role['tags']) if role['tags'] else 'None'}\n"
    #                 content += f"   Document: {'✅' if role['document_exists'] else '❌'}\n"
    content + = f"   Created: {role['created_at']}\n\n"

                text_widget.insert('1.0', content)

    text_widget.config(state = 'disabled')

    #         # Close button
    close_btn = tk.Button(summary_window, text="Close", command=summary_window.destroy,
    bg = '#007acc', fg='white',
    font = ('Segoe UI', 10, 'bold'))
    close_btn.pack(pady = 10)

    #     # Buttons
    button_frame = tk.Frame(demo_frame, bg='#252526')
    button_frame.pack(fill = 'x', padx=10, pady=10)

    tk.Button(button_frame, text = "🎯 Manage Role Documents",
    command = demo_role_management,
    bg = '#007acc', fg='white',
    font = ('Segoe UI', 11, 'bold')).pack(side='left', padx=5)

    tk.Button(button_frame, text = "📊 Show Role Summary",
    command = demo_role_summary,
    bg = '#4ec9b0', fg='white',
    font = ('Segoe UI', 11, 'bold')).pack(side='left', padx=5)

    #     # Integration info
    info_frame = tk.LabelFrame(root, text="ℹ️ Integration Information",
    bg = '#252526', fg='#d4d4d4',
    font = ('Segoe UI', 12, 'bold'))
    info_frame.pack(fill = 'x', padx=20, pady=20)

    info_text = """
# This enhanced AI role management system integrates with the NoodleCore IDE to provide:

# • Role document editing interface with real-time text editing
# • Integration with the existing IDE role selection dropdown
# • Document content automatically passed to AI chat sessions
# • Role categories and tags for better organization
# • Search functionality to find specific roles
# • Export/import capabilities for role sharing

# The role documents are stored as individual .md files and can be edited
# directly through the IDE interface or opened in external editors.
#     """

info_label = tk.Label(info_frame, text=info_text.strip(),
bg = '#252526', fg='#999999',
font = ('Segoe UI', 9),
justify = 'left',
wraplength = 700)
info_label.pack(padx = 10, pady=10)

#     # Start the demo
    root.mainloop()


if __name__ == "__main__"
        create_demo_integration()