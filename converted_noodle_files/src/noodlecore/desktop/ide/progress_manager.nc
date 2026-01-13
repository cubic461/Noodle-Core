# Converted from Python to NoodleCore
# Original file: noodle-core

import tkinter as tk
import tkinter.ttk,
import json
import time
import pathlib.Path
import datetime.datetime,
import typing.Dict,
import threading

class ProgressManager
    #     """Central progress tracking and monitoring system for the IDE."""

    #     def __init__(self, ide_instance):
    self.ide = ide_instance
    self.progress_data = {
    #             'project_progress': {},
    #             'ai_role_progress': {},
    #             'development_metrics': {},
    #             'learning_analytics': {},
    #             'quality_metrics': {},
    #             'milestones': [],
    #             'tasks': [],
    #             'achievements': []
    #         }
    self.monitoring_active = False
    self.config_path = Path.home() / '.noodlecore' / 'progress_config.json'
            self.load_progress_data()

    #     def load_progress_data(self):
    #         """Load existing progress data from file."""
    #         try:
    #             if self.config_path.exists():
    #                 with open(self.config_path, 'r') as f:
    saved_data = json.load(f)
                        self.progress_data.update(saved_data)
    #         except Exception as e:
                print(f"Could not load progress data: {e}")

    #     def save_progress_data(self):
    #         """Save progress data to file."""
    #         try:
    self.config_path.parent.mkdir(exist_ok = True)
    #             with open(self.config_path, 'w') as f:
    json.dump(self.progress_data, f, indent = 2, default=str)
    #         except Exception as e:
                print(f"Could not save progress data: {e}")

    #     def start_monitoring(self):
    #         """Start comprehensive progress monitoring."""
    #         if self.monitoring_active:
    #             return

    self.monitoring_active = True

    #         # Start different monitoring threads
    threading.Thread(target = self._monitor_file_changes, daemon=True).start()
    threading.Thread(target = self._monitor_ai_usage, daemon=True).start()
    threading.Thread(target = self._monitor_project_metrics, daemon=True).start()
    threading.Thread(target = self._monitor_quality_indicators, daemon=True).start()

            self._log_progress_event("monitoring_started", {"timestamp": datetime.now()})

    #     def stop_monitoring(self):
    #         """Stop progress monitoring."""
    self.monitoring_active = False
            self._log_progress_event("monitoring_stopped", {"timestamp": datetime.now()})
            self.save_progress_data()

    #     def _monitor_file_changes(self):
    #         """Monitor file changes and project activity."""
    previous_file_state = {}

    #         while self.monitoring_active:
    #             try:
    current_files = set()
    #                 for open_file in self.ide.open_files.keys():
                        current_files.add(open_file)

    #                 # Detect new files opened
    new_files = math.subtract(current_files, set(previous_file_state.keys()))
    #                 for file_path in new_files:
                        self._update_project_progress("file_opened", {"file": file_path})

    #                 # Detect files that were closed
    closed_files = math.subtract(set(previous_file_state.keys()), current_files)
    #                 for file_path in closed_files:
                        self._update_project_progress("file_closed", {"file": file_path})

    #                 previous_file_state = {file: time.time() for file in current_files}
                    time.sleep(5)  # Check every 5 seconds

    #             except Exception as e:
                    print(f"File monitoring error: {e}")
                    time.sleep(10)

    #     def _monitor_ai_usage(self):
    #         """Monitor AI role usage and effectiveness."""
    ai_interaction_count = 0

    #         while self.monitoring_active:
    #             try:
    #                 # Check for recent AI interactions (simplified)
    #                 if hasattr(self.ide, 'ai_conversations'):
    recent_interactions = len(self.ide.ai_conversations.get('recent', []))
    #                     if recent_interactions > ai_interaction_count:
                            self._update_ai_role_progress("ai_interaction", {
    #                             "interaction_count": recent_interactions,
                                "current_role": getattr(self.ide, 'current_ai_role', {}).get('name', 'None')
    #                         })
    ai_interaction_count = recent_interactions

                    time.sleep(10)  # Check every 10 seconds

    #             except Exception as e:
                    print(f"AI monitoring error: {e}")
                    time.sleep(15)

    #     def _monitor_project_metrics(self):
    #         """Monitor overall project development metrics."""
    #         while self.monitoring_active:
    #             try:
    #                 # Calculate project metrics
    project_metrics = self._calculate_project_metrics()
    self.progress_data['development_metrics'] = project_metrics
                    self.save_progress_data()

                    time.sleep(30)  # Check every 30 seconds

    #             except Exception as e:
                    print(f"Project metrics monitoring error: {e}")
                    time.sleep(60)

    #     def _monitor_quality_indicators(self):
    #         """Monitor code quality and development quality indicators."""
    #         while self.monitoring_active:
    #             try:
    #                 # Check for code quality improvements
    quality_metrics = self._assess_quality_metrics()
    self.progress_data['quality_metrics'] = quality_metrics

    #                 # Check for milestones achieved
                    self._check_milestone_progress()

                    time.sleep(60)  # Check every minute

    #             except Exception as e:
                    print(f"Quality monitoring error: {e}")
                    time.sleep(120)

    #     def _update_project_progress(self, activity_type, details):
    #         """Update project progress based on activities."""
    timestamp = datetime.now()

    #         if activity_type not in self.progress_data['project_progress']:
    self.progress_data['project_progress'][activity_type] = []

            self.progress_data['project_progress'][activity_type].append({
    #             "timestamp": timestamp,
    #             "details": details
    #         })

    #         # Keep only last 100 entries per activity type
    #         if len(self.progress_data['project_progress'][activity_type]) > 100:
    self.progress_data['project_progress'][activity_type] = \
    #                 self.progress_data['project_progress'][activity_type][-100:]

            self._check_progress_achievements()

    #     def _update_ai_role_progress(self, activity_type, details):
    #         """Update AI role learning and usage progress."""
    timestamp = datetime.now()

    role_name = details.get('current_role', 'default')
    #         if role_name not in self.progress_data['ai_role_progress']:
    self.progress_data['ai_role_progress'][role_name] = {
    #                 'usage_count': 0,
    #                 'interactions': [],
    #                 'effectiveness_score': 0.0,
    #                 'learning_events': []
    #             }

    role_progress = self.progress_data['ai_role_progress'][role_name]
    role_progress['usage_count'] + = 1
            role_progress['interactions'].append({
    #             "timestamp": timestamp,
    #             "activity": activity_type,
    #             "details": details
    #         })

    #         # Update effectiveness score
            self._update_role_effectiveness(role_name)

    #     def _calculate_project_metrics(self):
    #         """Calculate comprehensive project development metrics."""
    metrics = {
                "session_start": time.time(),
    #             "files_edited": 0,
    #             "lines_written": 0,
    #             "ai_assist_requests": 0,
    #             "code_runs": 0,
    #             "conversions_made": 0,
    #             "errors_fixed": 0,
    #             "productivity_score": 0.0,
    #             "current_streak": 0
    #         }

    #         # Count recent file activities
    recent_time = math.subtract(time.time(), 3600  # Last hour)

    #         for activity_type, activities in self.progress_data['project_progress'].items():
    #             for activity in activities:
    #                 if isinstance(activity['timestamp'], str):
    activity_time = datetime.fromisoformat(activity['timestamp']).timestamp()
    #                 else:
    activity_time = activity['timestamp'].timestamp()

    #                 if activity_time > recent_time:
    #                     if activity_type == "file_opened":
    metrics["files_edited"] + = 1
    #                     elif activity_type == "code_run":
    metrics["code_runs"] + = 1
    #                     elif activity_type == "ai_assist":
    metrics["ai_assist_requests"] + = 1
    #                     elif activity_type == "conversion":
    metrics["conversions_made"] + = 1
    #                     elif activity_type == "error_fix":
    metrics["errors_fixed"] + = 1

    #         # Calculate productivity score
    metrics["productivity_score"] = min(100, (
    #             metrics["files_edited"] * 5 +
    #             metrics["code_runs"] * 10 +
    #             metrics["ai_assist_requests"] * 8 +
    #             metrics["conversions_made"] * 15 +
    #             metrics["errors_fixed"] * 12
    #         ))

    #         return metrics

    #     def _assess_quality_metrics(self):
    #         """Assess code quality and development quality indicators."""
    quality = {
    #             "code_completion_rate": 0.0,
    #             "error_reduction_rate": 0.0,
    #             "ai_reliability_score": 0.0,
    #             "efficiency_improvement": 0.0,
    #             "learning_curve": 0.0
    #         }

    #         # Calculate error reduction rate
    recent_errors = self.progress_data['project_progress'].get('error_fix', [])
    #         if len(recent_errors) > 5:
    #             # Simple calculation - can be made more sophisticated
    quality["error_reduction_rate"] = math.multiply(min(100, len(recent_errors), 10))

    #         # Calculate AI reliability
    ai_progress = self.progress_data['ai_role_progress']
    #         if ai_progress:
    #             total_interactions = sum(role.get('usage_count', 0) for role in ai_progress.values())
    successful_interactions = sum(
    #                 len(role.get('interactions', [])) for role in ai_progress.values()
    #             )
    #             if total_interactions > 0:
    quality["ai_reliability_score"] = math.multiply((successful_interactions / total_interactions), 100)

    #         return quality

    #     def _update_role_effectiveness(self, role_name):
    #         """Update effectiveness score for an AI role."""
    role_data = self.progress_data['ai_role_progress'][role_name]
    interactions = role_data.get('interactions', [])

    #         if len(interactions) < 3:
    #             return

    #         # Simple effectiveness calculation based on interaction patterns
    recent_interactions = math.subtract(interactions[, 10:]  # Last 10 interactions)
    #         successful_interactions = sum(1 for i in recent_interactions
    #                                     if 'success' in i.get('details', {}))

    effectiveness = math.multiply((successful_interactions / len(recent_interactions)), 100)
    role_data['effectiveness_score'] = effectiveness

    #     def _check_progress_achievements(self):
    #         """Check and award progress achievements."""
    achievements = [
    #             {
    #                 "id": "first_file",
    #                 "name": "First Steps",
    #                 "description": "Opened your first file",
    "condition": lambda: self.progress_data['project_progress'].get('file_opened', []) ! = []
    #             },
    #             {
    #                 "id": "code_runner",
    #                 "name": "Code Runner",
    #                 "description": "Executed your first code file",
    "condition": lambda: self.progress_data['project_progress'].get('code_run', []) ! = []
    #             },
    #             {
    #                 "id": "ai_user",
    #                 "name": "AI Assistant",
    #                 "description": "Used AI for the first time",
    #                 "condition": lambda: any(role.get('usage_count', 0) > 0 for role in self.progress_data['ai_role_progress'].values())
    #             },
    #             {
    #                 "id": "converter",
    #                 "name": "Code Converter",
    #                 "description": "Converted your first file",
    "condition": lambda: self.progress_data['project_progress'].get('conversion', []) ! = []
    #             },
    #             {
    #                 "id": "error_fixer",
    #                 "name": "Bug Hunter",
    #                 "description": "Fixed your first error",
    "condition": lambda: self.progress_data['project_progress'].get('error_fix', []) ! = []
    #             },
    #             {
    #                 "id": "power_user",
    #                 "name": "Power User",
    #                 "description": "50 AI interactions",
    #                 "condition": lambda: sum(role.get('usage_count', 0) for role in self.progress_data['ai_role_progress'].values()) >= 50
    #             }
    #         ]

    #         for achievement in achievements:
    #             if achievement["id"] not in [a.get("id") for a in self.progress_data['achievements']]:
    #                 if achievement["condition"]():
                        self.progress_data['achievements'].append({
    #                         "id": achievement["id"],
    #                         "name": achievement["name"],
    #                         "description": achievement["description"],
                            "timestamp": datetime.now(),
    #                         "progress_category": "achievement"
    #                     })
                        self._log_progress_event("achievement_earned", {
    #                         "achievement": achievement["name"]
    #                     })

    #     def _check_milestone_progress(self):
    #         """Check progress towards project milestones."""
    #         # This would be more sophisticated in a real implementation
    #         # For now, we'll create some example milestones
    milestones = [
    #             {
    #                 "id": "first_project",
    #                 "name": "Complete First Project",
    #                 "description": "Create and run your first complete project",
    #                 "progress": 0.0,
    #                 "category": "project_completion"
    #             },
    #             {
    #                 "id": "ai_mastery",
    #                 "name": "AI Mastery",
    #                 "description": "Reach expert level with AI roles",
    #                 "progress": 0.0,
    #                 "category": "ai_skills"
    #             },
    #             {
    #                 "id": "quality_focus",
    #                 "name": "Quality Champion",
    #                 "description": "Maintain high code quality",
    #                 "progress": 0.0,
    #                 "category": "code_quality"
    #             }
    #         ]

    #         for milestone in milestones:
    #             if milestone["id"] not in [m.get("id") for m in self.progress_data['milestones']]:
    #                 # Calculate progress
    #                 if milestone["id"] == "first_project":
    files_opened = len(self.progress_data['project_progress'].get('file_opened', []))
    code_runs = len(self.progress_data['project_progress'].get('code_run', []))
    milestone["progress"] = math.add(min(100, (files_opened * 10, code_runs * 20)))
    #                 elif milestone["id"] == "ai_mastery":
    #                     total_ai_usage = sum(role.get('usage_count', 0) for role in self.progress_data['ai_role_progress'].values())
    milestone["progress"] = math.multiply(min(100, total_ai_usage, 2))
    #                 elif milestone["id"] == "quality_focus":
    errors_fixed = len(self.progress_data['project_progress'].get('error_fix', []))
    milestone["progress"] = math.multiply(min(100, errors_fixed, 25))

                    self.progress_data['milestones'].append(milestone)

    #     def _log_progress_event(self, event_type, details):
    #         """Log a progress event."""
    #         # This could integrate with the IDE's logging system
            print(f"[PROGRESS] {event_type}: {details}")

    #     def get_progress_summary(self):
    #         """Get a comprehensive progress summary."""
    summary = {
    #             "overview": {
                    "session_duration": time.time() - self.progress_data['development_metrics'].get('session_start', time.time()),
                    "current_productivity_score": self.progress_data['development_metrics'].get('productivity_score', 0),
                    "active_ai_role": (getattr(self.ide, 'current_ai_role', None).name
    #                                  if hasattr(self.ide, 'current_ai_role') and self.ide.current_ai_role and hasattr(self.ide.current_ai_role, 'name')
                                     else getattr(self.ide, 'current_ai_role', {}).get('name', 'None')
    #                                  if hasattr(self.ide, 'current_ai_role') and isinstance(getattr(self.ide, 'current_ai_role', {}), dict)
                                     else str(getattr(self.ide, 'current_ai_role', 'None'))
    #                                  if hasattr(self.ide, 'current_ai_role')
    #                                  else 'None')
    #             },
    #             "project_activity": {
                    "files_opened": len(self.progress_data['project_progress'].get('file_opened', [])),
                    "code_runs": len(self.progress_data['project_progress'].get('code_run', [])),
                    "ai_assist_requests": len(self.progress_data['project_progress'].get('ai_assist', [])),
                    "conversions_made": len(self.progress_data['project_progress'].get('conversion', [])),
                    "errors_fixed": len(self.progress_data['project_progress'].get('error_fix', []))
    #             },
    #             "ai_learning": {
    #                 "total_interactions": sum(role.get('usage_count', 0) for role in self.progress_data['ai_role_progress'].values()),
    #                 "role_effectiveness": {
                        name: role.get('effectiveness_score', 0)
    #                     for name, role in self.progress_data['ai_role_progress'].items()
    #                 }
    #             },
    #             "achievements": self.progress_data['achievements'],
    #             "milestones": self.progress_data['milestones'],
    #             "quality_metrics": self.progress_data['quality_metrics']
    #         }
    #         return summary

    #     def show_progress_dialog(self):
    #         """Show progress monitoring dialog in the IDE."""
    dialog = tk.Toplevel(self.ide.root)
            dialog.title("📊 Progress Manager & Analytics")
            dialog.geometry("800x600")
    dialog.configure(bg = '#2b2b2b')
            dialog.transient(self.ide.root)
            dialog.grab_set()

    #         # Create notebook for different progress views
    notebook = ttk.Notebook(dialog)
    notebook.pack(fill = 'both', expand=True, padx=10, pady=10)

    #         # Overview tab
    overview_frame = tk.Frame(notebook, bg='#2b2b2b')
    notebook.add(overview_frame, text = "📈 Overview")
            self._create_overview_tab(overview_frame)

    #         # AI Learning tab
    ai_frame = tk.Frame(notebook, bg='#2b2b2b')
    notebook.add(ai_frame, text = "🤖 AI Learning")
            self._create_ai_learning_tab(ai_frame)

    #         # Achievements tab
    achievements_frame = tk.Frame(notebook, bg='#2b2b2b')
    notebook.add(achievements_frame, text = "🏆 Achievements")
            self._create_achievements_tab(achievements_frame)

    #         # Milestones tab
    milestones_frame = tk.Frame(notebook, bg='#2b2b2b')
    notebook.add(milestones_frame, text = "🎯 Milestones")
            self._create_milestones_tab(milestones_frame)

    #         # Quality tab
    quality_frame = tk.Frame(notebook, bg='#2b2b2b')
    notebook.add(quality_frame, text = "🔍 Quality")
            self._create_quality_tab(quality_frame)

    #         # Control buttons
    button_frame = tk.Frame(dialog, bg='#2b2b2b')
    button_frame.pack(fill = 'x', padx=10, pady=5)

    tk.Button(button_frame, text = "Start Monitoring", command=self.start_monitoring,
    bg = '#4CAF50', fg='white').pack(side='left', padx=5)
    tk.Button(button_frame, text = "Stop Monitoring", command=self.stop_monitoring,
    bg = '#f44336', fg='white').pack(side='left', padx=5)
    tk.Button(button_frame, text = "Export Report", command=self._export_progress_report,
    bg = '#2196F3', fg='white').pack(side='left', padx=5)
    tk.Button(button_frame, text = "Close", command=dialog.destroy,
    bg = '#666666', fg='white').pack(side='right', padx=5)

    #     def _create_overview_tab(self, parent):
    #         """Create the overview progress tab."""
    summary = self.get_progress_summary()

    #         # Title
    tk.Label(parent, text = "📊 Development Progress Overview",
    bg = '#2b2b2b', fg='white', font=('Arial', 16, 'bold')).pack(pady=10)

    #         # Current status
    status_frame = tk.LabelFrame(parent, text="Current Status", bg='#2b2b2b', fg='white')
    status_frame.pack(fill = 'x', padx=10, pady=5)

    tk.Label(status_frame, text = f"Productivity Score: {summary['overview']['current_productivity_score']:.1f}/100",
    bg = '#2b2b2b', fg='#4CAF50', font=('Arial', 12, 'bold')).pack(anchor='w', padx=10, pady=2)
    tk.Label(status_frame, text = f"Active AI Role: {summary['overview']['active_ai_role']}",
    bg = '#2b2b2b', fg='white').pack(anchor='w', padx=10, pady=2)

    #         # Project activity
    activity_frame = tk.LabelFrame(parent, text="Project Activity", bg='#2b2b2b', fg='white')
    activity_frame.pack(fill = 'x', padx=10, pady=5)

    #         for key, value in summary['project_activity'].items():
    display_key = key.replace('_', ' ').title()
    tk.Label(activity_frame, text = f"{display_key}: {value}",
    bg = '#2b2b2b', fg='white').pack(anchor='w', padx=10, pady=1)

    #     def _create_ai_learning_tab(self, parent):
    #         """Create the AI learning progress tab."""
    summary = self.get_progress_summary()

    tk.Label(parent, text = "🤖 AI Role Learning Analytics",
    bg = '#2b2b2b', fg='white', font=('Arial', 16, 'bold')).pack(pady=10)

    #         # Total interactions
    total_frame = tk.LabelFrame(parent, text="Learning Statistics", bg='#2b2b2b', fg='white')
    total_frame.pack(fill = 'x', padx=10, pady=5)

    tk.Label(total_frame, text = f"Total AI Interactions: {summary['ai_learning']['total_interactions']}",
    bg = '#2b2b2b', fg='white', font=('Arial', 12, 'bold')).pack(anchor='w', padx=10, pady=2)

    #         # Role effectiveness
    #         if summary['ai_learning']['role_effectiveness']:
    effectiveness_frame = tk.LabelFrame(parent, text="Role Effectiveness", bg='#2b2b2b', fg='white')
    effectiveness_frame.pack(fill = 'both', expand=True, padx=10, pady=5)

    #             for role_name, score in summary['ai_learning']['role_effectiveness'].items():
    tk.Label(effectiveness_frame, text = f"{role_name}: {score:.1f}% effectiveness",
    bg = '#2b2b2b', fg='#FF9800').pack(anchor='w', padx=10, pady=2)
    #         else:
    tk.Label(parent, text = "No AI role usage data available yet",
    bg = '#2b2b2b', fg='#666666').pack(pady=20)

    #     def _create_achievements_tab(self, parent):
    #         """Create the achievements tab."""
    tk.Label(parent, text = "🏆 Your Achievements",
    bg = '#2b2b2b', fg='white', font=('Arial', 16, 'bold')).pack(pady=10)

    achievements = self.progress_data['achievements']

    #         if not achievements:
    tk.Label(parent, text = "No achievements earned yet. Keep coding!",
    bg = '#2b2b2b', fg='#666666').pack(pady=20)
    #             return

    #         for achievement in achievements:
    ach_frame = tk.Frame(parent, bg='#1e1e1e', relief='raised', bd=1)
    ach_frame.pack(fill = 'x', padx=10, pady=5)

    tk.Label(ach_frame, text = f"🏆 {achievement['name']}",
    bg = '#1e1e1e', fg='#FFD700', font=('Arial', 12, 'bold')).pack(anchor='w', padx=10, pady=(5, 0))
    tk.Label(ach_frame, text = achievement['description'],
    bg = '#1e1e1e', fg='white').pack(anchor='w', padx=10, pady=(0, 5))

    #     def _create_milestones_tab(self, parent):
    #         """Create the milestones progress tab."""
    tk.Label(parent, text = "🎯 Project Milestones",
    bg = '#2b2b2b', fg='white', font=('Arial', 16, 'bold')).pack(pady=10)

    milestones = self.progress_data['milestones']

    #         if not milestones:
    tk.Label(parent, text = "No milestones set yet.",
    bg = '#2b2b2b', fg='#666666').pack(pady=20)
    #             return

    #         for milestone in milestones:
    ms_frame = tk.LabelFrame(parent, text=milestone['name'], bg='#2b2b2b', fg='white')
    ms_frame.pack(fill = 'x', padx=10, pady=5)

    tk.Label(ms_frame, text = milestone['description'],
    bg = '#2b2b2b', fg='white').pack(anchor='w', padx=10, pady=2)

                # Progress bar (simplified)
    progress_width = int(milestone['progress'] * 4)  # Scale to visual width
    progress_text = "█" * progress_width + "░" * (40 - progress_width)
    tk.Label(ms_frame, text = f"[{progress_text}] {milestone['progress']:.1f}%",
    bg = '#2b2b2b', fg='#4CAF50', font=('Consolas', 10)).pack(anchor='w', padx=10, pady=2)

    #     def _create_quality_tab(self, parent):
    #         """Create the quality metrics tab."""
    tk.Label(parent, text = "🔍 Code Quality Analytics",
    bg = '#2b2b2b', fg='white', font=('Arial', 16, 'bold')).pack(pady=10)

    quality = self.progress_data['quality_metrics']

    #         if not quality or all(v == 0.0 for v in quality.values()):
    tk.Label(parent, text = "No quality data available yet.",
    bg = '#2b2b2b', fg='#666666').pack(pady=20)
    #             return

    #         for metric, value in quality.items():
    #             if value > 0:
    metric_name = metric.replace('_', ' ').title()
    tk.Label(parent, text = f"{metric_name}: {value:.1f}/100",
    bg = '#2b2b2b', fg='#FF9800').pack(anchor='w', padx=20, pady=2)

    #     def _export_progress_report(self):
    #         """Export progress report to file."""
    #         from tkinter import filedialog

    filename = filedialog.asksaveasfilename(
    title = "Export Progress Report",
    defaultextension = ".json",
    filetypes = [("JSON files", "*.json"), ("Text files", "*.txt"), ("All files", "*.*")]
    #         )

    #         if filename:
    #             try:
    #                 with open(filename, 'w') as f:
    #                     if filename.endswith('.json'):
    json.dump(self.get_progress_summary(), f, indent = 2, default=str)
    #                     else:
    summary = self.get_progress_summary()
                            f.write("NOODLECORE IDE PROGRESS REPORT\n")
    f.write(" = " * 40 + "\n\n")
                            f.write(f"Productivity Score: {summary['overview']['current_productivity_score']:.1f}/100\n")
                            f.write(f"Total AI Interactions: {summary['ai_learning']['total_interactions']}\n")
                            f.write(f"Files Opened: {summary['project_activity']['files_opened']}\n")
                            f.write(f"Code Runs: {summary['project_activity']['code_runs']}\n")
                            f.write(f"AI Assist Requests: {summary['project_activity']['ai_assist_requests']}\n")
                            f.write(f"Conversions Made: {summary['project_activity']['conversions_made']}\n")
                            f.write(f"Errors Fixed: {summary['project_activity']['errors_fixed']}\n")

                    self._log_progress_event("progress_report_exported", {"filename": filename})

    #             except Exception as e:
                    print(f"Could not export progress report: {e}")