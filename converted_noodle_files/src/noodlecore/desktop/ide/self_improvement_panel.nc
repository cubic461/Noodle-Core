# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# NoodleCore Self-Improvement UI Panel

# This module provides a UI panel for displaying and managing
# self-improvement suggestions and system status.
# """

import tkinter as tk
import tkinter.ttk,
import json
import pathlib.Path
import typing.Dict,
import datetime.datetime
import threading

class SelfImprovementPanel
    #     """
    #     UI panel for self-improvement system integration.

    #     Provides:
    #     - Real-time status display
    #     - Improvement suggestion management
    #     - Configuration interface
    #     - Historical view of improvements
    #     """

    #     def __init__(self, parent, integration_instance):
    self.parent = parent
    self.integration = integration_instance
    self.panel_frame = None

    #         # Check if integration is available
    #         if not self.integration:
                print("Self-Improvement Integration not available, creating placeholder panel")
                self._create_placeholder_panel()
    #             return

    #         # Create the panel
            self._create_panel()

    #         # Start UI update thread
    self.update_thread = None
    self.is_updating = False
            self._start_ui_updates()

    #     def _create_panel(self):
    #         """Create the self-improvement UI panel."""
    #         # Main panel frame
    self.panel_frame = tk.Frame(self.parent, bg='#2b2b2b')

    #         # Title section
    title_frame = tk.Frame(self.panel_frame, bg='#2b2b2b')
    title_frame.pack(fill = 'x', padx=5, pady=5)

            tk.Label(
    #             title_frame,
    text = "🔧 Self-Improvement System",
    bg = '#2b2b2b',
    fg = 'white',
    font = ('Arial', 12, 'bold')
    ).pack(side = 'left')

    #         # Status section
    status_frame = tk.Frame(self.panel_frame, bg='#1e1e1e', relief='raised', bd=1)
    status_frame.pack(fill = 'x', padx=5, pady=5)

            tk.Label(
    #             status_frame,
    text = "System Status",
    bg = '#1e1e1e',
    fg = '#ffaa00',
    font = ('Arial', 10, 'bold')
    ).pack(anchor = 'w', padx=10, pady=(10, 5))

    self.status_label = tk.Label(
    #             status_frame,
    text = "Initializing...",
    bg = '#1e1e1e',
    fg = 'white',
    font = ('Arial', 9)
    #         )
    self.status_label.pack(anchor = 'w', padx=10, pady=(0, 10))

    #         # Control buttons
    control_frame = tk.Frame(self.panel_frame, bg='#2b2b2b')
    control_frame.pack(fill = 'x', padx=5, pady=5)

    self.start_btn = tk.Button(
    #             control_frame,
    text = "Start Monitoring",
    command = self.start_monitoring,
    bg = '#4CAF50',
    fg = 'white',
    font = ('Arial', 9, 'bold'),
    relief = 'flat',
    padx = 10,
    pady = 5
    #         )
    self.start_btn.pack(side = 'left', padx=5)

    self.stop_btn = tk.Button(
    #             control_frame,
    text = "Stop Monitoring",
    command = self.stop_monitoring,
    bg = '#f44336',
    fg = 'white',
    font = ('Arial', 9, 'bold'),
    relief = 'flat',
    padx = 10,
    pady = 5,
    state = 'disabled'
    #         )
    self.stop_btn.pack(side = 'left', padx=5)

            tk.Button(
    #             control_frame,
    text = "Settings",
    command = self.show_settings,
    bg = '#2196F3',
    fg = 'white',
    font = ('Arial', 9, 'bold'),
    relief = 'flat',
    padx = 10,
    pady = 5
    ).pack(side = 'left', padx=5)

    #         # Improvements section
    improvements_frame = tk.Frame(self.panel_frame, bg='#2b2b2b')
    improvements_frame.pack(fill = 'both', expand=True, padx=5, pady=5)

            tk.Label(
    #             improvements_frame,
    text = "Active Improvements",
    bg = '#2b2b2b',
    fg = 'white',
    font = ('Arial', 10, 'bold')
    ).pack(anchor = 'w')

    #         # Improvements list with scrollbar
    list_frame = tk.Frame(improvements_frame, bg='#2b2b2b')
    list_frame.pack(fill = 'both', expand=True, pady=5)

    scrollbar = ttk.Scrollbar(list_frame)
    scrollbar.pack(side = 'right', fill='y')

    self.improvements_listbox = tk.Listbox(
    #             list_frame,
    bg = '#1e1e1e',
    fg = 'white',
    font = ('Consolas', 9),
    yscrollcommand = scrollbar.set,
    selectmode = 'single'
    #         )
    self.improvements_listbox.pack(side = 'left', fill='both', expand=True)
    scrollbar.config(command = self.improvements_listbox.yview)

    #         # Improvement action buttons
    action_frame = tk.Frame(improvements_frame, bg='#2b2b2b')
    action_frame.pack(fill = 'x', pady=5)

            tk.Button(
    #             action_frame,
    text = "Approve",
    command = self.approve_improvement,
    bg = '#4CAF50',
    fg = 'white',
    font = ('Arial', 9, 'bold'),
    relief = 'flat',
    padx = 10,
    pady = 5
    ).pack(side = 'left', padx=5)

            tk.Button(
    #             action_frame,
    text = "Reject",
    command = self.reject_improvement,
    bg = '#f44336',
    fg = 'white',
    font = ('Arial', 9, 'bold'),
    relief = 'flat',
    padx = 10,
    pady = 5
    ).pack(side = 'left', padx=5)

            tk.Button(
    #             action_frame,
    text = "Details",
    command = self.show_improvement_details,
    bg = '#FF9800',
    fg = 'white',
    font = ('Arial', 9, 'bold'),
    relief = 'flat',
    padx = 10,
    pady = 5
    ).pack(side = 'left', padx=5)

    #         # Metrics section
    metrics_frame = tk.Frame(self.panel_frame, bg='#1e1e1e', relief='raised', bd=1)
    metrics_frame.pack(fill = 'x', padx=5, pady=5)

            tk.Label(
    #             metrics_frame,
    text = "Performance Metrics",
    bg = '#1e1e1e',
    fg = '#ffaa00',
    font = ('Arial', 10, 'bold')
    ).pack(anchor = 'w', padx=10, pady=(10, 5))

    self.metrics_label = tk.Label(
    #             metrics_frame,
    text = "CPU: --%, Memory: --%, Improvements: 0",
    bg = '#1e1e1e',
    fg = 'white',
    font = ('Arial', 9)
    #         )
    self.metrics_label.pack(anchor = 'w', padx=10, pady=(0, 10))

    #     def _start_ui_updates(self):
    #         """Start the UI update thread."""
    #         if self.is_updating:
    #             return

    self.is_updating = True
    self.update_thread = threading.Thread(target=self._update_ui_loop, daemon=True)
            self.update_thread.start()

    #     def _update_ui_loop(self):
    #         """Main UI update loop."""
    #         while self.is_updating:
    #             try:
    #                 # Update status
                    self._update_status()

    #                 # Update improvements list
                    self._update_improvements_list()

    #                 # Update metrics
                    self._update_metrics()

    #                 # Sleep for update interval
                    threading.Event().wait(2.0)

    #             except Exception as e:
                    print(f"Error in UI update loop: {e}")
                    threading.Event().wait(1.0)

    #     def _update_status(self):
    #         """Update the status display."""
    #         try:
    #             if self.integration:
    status = self.integration.get_improvement_status()

    #                 status_text = f"Monitoring: {'Active' if status['is_monitoring'] else 'Inactive'}\n"
    status_text + = f"Active Improvements: {status['active_improvements']}\n"
    status_text + = f"Total Applied: {status['total_improvements']}"

    #                 # Update label in main thread
    #                 if hasattr(self, 'status_label') and self.status_label:
    self.parent.after(0, lambda: self.status_label.config(text = status_text))

    #                 # Update button states
    #                 if hasattr(self, 'start_btn') and hasattr(self, 'stop_btn'):
    #                     if status['is_monitoring']:
    self.parent.after(0, lambda: self.start_btn.config(state = 'disabled'))
    self.parent.after(0, lambda: self.stop_btn.config(state = 'normal'))
    #                     else:
    self.parent.after(0, lambda: self.start_btn.config(state = 'normal'))
    self.parent.after(0, lambda: self.stop_btn.config(state = 'disabled'))
    #             else:
    #                 # Set default status when integration is not available
    #                 if hasattr(self, 'status_label') and self.status_label:
    self.parent.after(0, lambda: self.status_label.config(text = "Self-Improvement System Not Available"))

    #         except Exception as e:
                print(f"Error updating status: {e}")

    #     def _update_improvements_list(self):
    #         """Update the improvements list."""
    #         try:
    #             if self.integration:
    improvements = self.integration.get_active_improvements()

    #                 # Clear current list
    #                 if hasattr(self, 'improvements_listbox') and self.improvements_listbox:
                        self.parent.after(0, lambda: self.improvements_listbox.delete(0, tk.END))

    #                 # Add improvements to list
    #                 for improvement in improvements:
    text = f"{improvement.get('type', 'unknown')} - {improvement.get('description', 'No description')[:50]}..."
    #                     if hasattr(self, 'improvements_listbox') and self.improvements_listbox:
    self.parent.after(0, lambda t = text: self.improvements_listbox.insert(tk.END, t))
    #             else:
    #                 # Set default message when integration is not available
    #                 if hasattr(self, 'improvements_listbox') and self.improvements_listbox:
                        self.parent.after(0, lambda: self.improvements_listbox.delete(0, tk.END))
                        self.parent.after(0, lambda: self.improvements_listbox.insert(tk.END, "Self-Improvement system not available"))

    #         except Exception as e:
                print(f"Error updating improvements list: {e}")

    #     def _update_metrics(self):
    #         """Update performance metrics display."""
    #         try:
    #             if self.integration and hasattr(self.integration, 'performance_monitor') and self.integration.performance_monitor:
    #                 # Try to get metrics with fallback
    #                 try:
    metrics = self.integration.performance_monitor.collect_system_metrics()
    #                 except Exception:
    metrics = {"cpu": {"percent": 0}, "memory": {"used_percent": 0}}

    #                 if metrics:
    cpu = metrics.get('cpu', {}).get('percent', 0)
    memory = metrics.get('memory', {}).get('used_percent', 0)
    #                     improvements = len(self.integration.get_active_improvements()) if self.integration else 0

    metrics_text = f"CPU: {cpu}%, Memory: {memory}%, Active: {improvements}"
    #                     if hasattr(self, 'metrics_label') and self.metrics_label:
    self.parent.after(0, lambda: self.metrics_label.config(text = metrics_text))
    #             else:
    #                 # Set default metrics when integration is not available
    #                 if hasattr(self, 'metrics_label') and self.metrics_label:
    self.parent.after(0, lambda: self.metrics_label.config(text = "CPU: --%, Memory: --%, Active: 0"))

    #         except Exception as e:
                print(f"Error updating metrics: {e}")

    #     def start_monitoring(self):
    #         """Start self-improvement monitoring."""
    #         try:
    #             if self.integration:
                    self.integration.start_monitoring()
    #             else:
                    messagebox.showinfo("Not Available", "Self-Improvement system not available")
    #         except Exception as e:
                messagebox.showerror("Error", f"Failed to start monitoring: {str(e)}")

    #     def stop_monitoring(self):
    #         """Stop self-improvement monitoring."""
    #         try:
    #             if self.integration:
                    self.integration.stop_monitoring()
    #             else:
                    messagebox.showinfo("Not Available", "Self-Improvement system not available")
    #         except Exception as e:
                messagebox.showerror("Error", f"Failed to stop monitoring: {str(e)}")

    #     def approve_improvement(self):
    #         """Approve selected improvement."""
    #         try:
    #             if not self.improvements_listbox:
                    messagebox.showinfo("Not Available", "Self-Improvement system not available")
    #                 return

    selection = self.improvements_listbox.curselection()
    #             if selection:
    index = selection[0]
    #                 if self.integration:
                        self.integration.approve_improvement(index)
    #                 else:
                        messagebox.showinfo("Not Available", "Self-Improvement system not available")
    #         except Exception as e:
                messagebox.showerror("Error", f"Failed to approve improvement: {str(e)}")

    #     def reject_improvement(self):
    #         """Reject selected improvement."""
    #         try:
    #             if not self.improvements_listbox:
                    messagebox.showinfo("Not Available", "Self-Improvement system not available")
    #                 return

    selection = self.improvements_listbox.curselection()
    #             if selection:
    index = selection[0]
    #                 if self.integration:
                        self.integration.reject_improvement(index)
    #                 else:
                        messagebox.showinfo("Not Available", "Self-Improvement system not available")
    #         except Exception as e:
                messagebox.showerror("Error", f"Failed to reject improvement: {str(e)}")

    #     def show_improvement_details(self):
    #         """Show details of selected improvement."""
    #         try:
    #             if not self.improvements_listbox:
                    messagebox.showinfo("Not Available", "Self-Improvement system not available")
    #                 return

    selection = self.improvements_listbox.curselection()
    #             if not selection:
                    messagebox.showinfo("No Selection", "Please select an improvement first")
    #                 return

    index = selection[0]
    #             if self.integration:
    improvements = self.integration.get_active_improvements()
    #                 if index < len(improvements):
    improvement = improvements[index]
                        self._show_details_dialog(improvement)
    #                 else:
                        messagebox.showinfo("Invalid Selection", "Improvement index out of range")
    #             else:
                    messagebox.showinfo("Not Available", "Self-Improvement system not available")

    #         except Exception as e:
                messagebox.showerror("Error", f"Failed to show improvement details: {str(e)}")

    #     def _show_details_dialog(self, improvement: Dict[str, Any]):
    #         """Show detailed improvement information."""
    dialog = tk.Toplevel(self.parent)
            dialog.title("Improvement Details")
            dialog.geometry("500x400")
    dialog.configure(bg = '#2b2b2b')
            dialog.transient(self.parent)
            dialog.grab_set()

    #         # Title
            tk.Label(
    #             dialog,
    text = f"🔧 {improvement.get('type', 'Unknown')} Improvement",
    bg = '#2b2b2b',
    fg = 'white',
    font = ('Arial', 12, 'bold')
    ).pack(pady = 10)

    #         # Details
    details_frame = tk.Frame(dialog, bg='#2b2b2b')
    details_frame.pack(fill = 'both', expand=True, padx=20, pady=10)

    #         # Description
            tk.Label(
    #             details_frame,
    text = "Description:",
    bg = '#2b2b2b',
    fg = '#ffaa00',
    font = ('Arial', 10, 'bold')
    ).pack(anchor = 'w')

    desc_text = scrolledtext.ScrolledText(
    #             details_frame,
    height = 5,
    bg = '#1e1e1e',
    fg = 'white',
    font = ('Arial', 9),
    wrap = tk.WORD
    #         )
    desc_text.pack(fill = 'x', pady=(0, 10))
            desc_text.insert('1.0', improvement.get('description', 'No description'))
    desc_text.config(state = 'disabled')

    #         # Priority
            tk.Label(
    #             details_frame,
    text = f"Priority: {improvement.get('priority', 'unknown')}",
    bg = '#2b2b2b',
    fg = 'white',
    font = ('Arial', 10)
    ).pack(anchor = 'w', pady=(0, 5))

    #         # Source
            tk.Label(
    #             details_frame,
    text = f"Source: {improvement.get('source', 'unknown')}",
    bg = '#2b2b2b',
    fg = 'white',
    font = ('Arial', 10)
    ).pack(anchor = 'w', pady=(0, 5))

    #         # Timestamp
    timestamp = improvement.get('timestamp', 'unknown')
            tk.Label(
    #             details_frame,
    text = f"Detected: {timestamp}",
    bg = '#2b2b2b',
    fg = 'white',
    font = ('Arial', 10)
    ).pack(anchor = 'w', pady=(0, 5))

    #         # Status
            tk.Label(
    #             details_frame,
    text = f"Status: {improvement.get('status', 'unknown')}",
    bg = '#2b2b2b',
    fg = 'white',
    font = ('Arial', 10)
    ).pack(anchor = 'w', pady=(0, 10))

    #         # Close button
            tk.Button(
    #             dialog,
    text = "Close",
    command = dialog.destroy,
    bg = '#2196F3',
    fg = 'white',
    font = ('Arial', 10, 'bold'),
    relief = 'flat',
    padx = 20,
    pady = 10
    ).pack(pady = 10)

    #     def show_settings(self):
    #         """Show settings dialog."""
    dialog = tk.Toplevel(self.parent)
            dialog.title("Self-Improvement Settings")
            dialog.geometry("400x300")
    dialog.configure(bg = '#2b2b2b')
            dialog.transient(self.parent)
            dialog.grab_set()

    #         # Title
            tk.Label(
    #             dialog,
    text = "⚙️ Self-Improvement Settings",
    bg = '#2b2b2b',
    fg = 'white',
    font = ('Arial', 12, 'bold')
    ).pack(pady = 10)

    #         # Settings frame
    settings_frame = tk.Frame(dialog, bg='#2b2b2b')
    settings_frame.pack(fill = 'both', expand=True, padx=20, pady=10)

    #         # Get current settings
    current_settings = {}
    #         if self.integration:
    current_settings = self.integration.config

    #         # Auto-apply improvements
    auto_apply_var = tk.BooleanVar(value=current_settings.get('auto_apply_improvements', False))
            tk.Checkbutton(
    #             settings_frame,
    text = "Auto-apply improvements",
    variable = auto_apply_var,
    bg = '#2b2b2b',
    fg = 'white',
    selectcolor = '#2b2b2b'
    ).pack(anchor = 'w', pady=5)

    #         # Enable AI suggestions
    ai_suggestions_var = tk.BooleanVar(value=current_settings.get('enable_ai_suggestions', True))
            tk.Checkbutton(
    #             settings_frame,
    text = "Enable AI suggestions",
    variable = ai_suggestions_var,
    bg = '#2b2b2b',
    fg = 'white',
    selectcolor = '#2b2b2b'
    ).pack(anchor = 'w', pady=5)

    #         # Enable performance monitoring
    perf_monitoring_var = tk.BooleanVar(value=current_settings.get('enable_performance_monitoring', True))
            tk.Checkbutton(
    #             settings_frame,
    text = "Enable performance monitoring",
    variable = perf_monitoring_var,
    bg = '#2b2b2b',
    fg = 'white',
    selectcolor = '#2b2b2b'
    ).pack(anchor = 'w', pady=5)

    #         # Enable learning loop
    learning_loop_var = tk.BooleanVar(value=current_settings.get('enable_learning_loop', True))
            tk.Checkbutton(
    #             settings_frame,
    text = "Enable learning loop",
    variable = learning_loop_var,
    bg = '#2b2b2b',
    fg = 'white',
    selectcolor = '#2b2b2b'
    ).pack(anchor = 'w', pady=5)

    #         # Monitoring interval
            tk.Label(
    #             settings_frame,
    text = "Monitoring interval (seconds):",
    bg = '#2b2b2b',
    fg = 'white'
    ).pack(anchor = 'w', pady=(10, 0))

    interval_var = tk.IntVar(value=current_settings.get('monitoring_interval', 5))
    interval_spinbox = tk.Spinbox(
    #             settings_frame,
    from_ = 1,
    to = 60,
    textvariable = interval_var,
    bg = '#1e1e1e',
    fg = 'white'
    #         )
    interval_spinbox.pack(anchor = 'w', pady=5)

    #         def save_settings():
    new_settings = {
                    'auto_apply_improvements': auto_apply_var.get(),
                    'enable_ai_suggestions': ai_suggestions_var.get(),
                    'enable_performance_monitoring': perf_monitoring_var.get(),
                    'enable_learning_loop': learning_loop_var.get(),
                    'monitoring_interval': interval_var.get()
    #             }

    #             if self.integration:
                    self.integration.configure_settings(new_settings)

                messagebox.showinfo("Settings Saved", "Self-improvement settings have been saved.")
                dialog.destroy()

    #         # Buttons
    button_frame = tk.Frame(dialog, bg='#2b2b2b')
    button_frame.pack(fill = 'x', padx=20, pady=10)

            tk.Button(
    #             button_frame,
    text = "Save",
    command = save_settings,
    bg = '#4CAF50',
    fg = 'white',
    font = ('Arial', 10, 'bold'),
    relief = 'flat',
    padx = 20,
    pady = 5
    ).pack(side = 'left', padx=5)

            tk.Button(
    #             button_frame,
    text = "Cancel",
    command = dialog.destroy,
    bg = '#f44336',
    fg = 'white',
    font = ('Arial', 10, 'bold'),
    relief = 'flat',
    padx = 20,
    pady = 5
    ).pack(side = 'right', padx=5)

    #     def get_panel(self):
    #         """Get the panel frame for embedding in IDE."""
    #         return self.panel_frame

    #     def _create_placeholder_panel(self):
    #         """Create a placeholder panel when integration is not available."""
    #         # Main panel frame
    placeholder_frame = tk.Frame(self.parent, bg='#2b2b2b')
    placeholder_frame.pack(fill = 'both', expand=True, padx=5, pady=5)

    #         # Title
    title_frame = tk.Frame(placeholder_frame, bg='#2b2b2b')
    title_frame.pack(fill = 'x', padx=5, pady=5)

            tk.Label(
    #             title_frame,
    text = "🔧 Self-Improvement System",
    bg = '#2b2b2b',
    fg = 'white',
    font = ('Arial', 12, 'bold')
    ).pack(side = 'left')

    #         # Status
    status_frame = tk.Frame(placeholder_frame, bg='#1e1e1e', relief='raised', bd=1)
    status_frame.pack(fill = 'x', padx=5, pady=5)

            tk.Label(
    #             status_frame,
    text = "System Status: Not Available",
    bg = '#1e1e1e',
    fg = '#ffaa00',
    font = ('Arial', 10, 'bold')
    ).pack(anchor = 'w', padx=10, pady=(10, 5))

            tk.Label(
    #             status_frame,
    text = "The self-improvement system is not available.",
    bg = '#1e1e1e',
    fg = 'white',
    font = ('Arial', 9)
    ).pack(anchor = 'w', padx=10, pady=(0, 10))

    #         # Information
    info_frame = tk.Frame(placeholder_frame, bg='#2b2b2b')
    info_frame.pack(fill = 'both', expand=True, padx=5, pady=5)

    info_text = """
# The self-improvement system could not be initialized.

# This may be due to:
• Missing dependencies (noodlecore_self_improvement_system)
• Missing components (performance_monitor, learning_loop, trm_agent)
# • Configuration issues

# Please check the system logs for more details.
#         """

info_label = tk.Label(
#             info_frame,
text = info_text,
bg = '#2b2b2b',
fg = 'white',
font = ('Arial', 9),
justify = 'left',
wraplength = 50
#         )
info_label.pack(fill = 'both', expand=True, padx=10, pady=5)

#     def shutdown(self):
#         """Shutdown the panel and cleanup resources."""
self.is_updating = False
#         if self.update_thread:
self.update_thread.join(timeout = 2.0)