# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Noodle Project Manager
# -----------------------
# Provides project management capabilities including task assignment,
# coordination between different roles, and merge decision-making.
# """

import difflib
import filecmp
import json
import logging
import os
import shutil
import uuid
import dataclasses.dataclass,
import datetime.datetime
import enum.Enum
import pathlib.Path
import typing.Any,

import ..versioning.versioned,
import .merge.MergeStrategy
import .project_context.ProjectContext
import .sandbox.SandboxManager

# Try to import asdict for Change dataclass, fallback to manual dict creation
try
    #     from dataclasses import asdict
except ImportError

    #     def asdict(obj):
    #         return {field.name: getattr(obj, field.name) for field in fields(obj)}


# Configure logging
logging.basicConfig(level = logging.INFO)
logger = logging.getLogger(__name__)


class TaskStatus(Enum)
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    FAILED = "failed"
    REJECTED = "rejected"


class MergeDecision(Enum)
    AUTO_ACCEPT = "auto_accept"
    AUTO_REJECT = "auto_reject"
    MANUAL_REVIEW = "manual_review"
    AI_REVIEW = "ai_review"


# @dataclass
class AgentTask
    id: str = field(default_factory=lambda: str(uuid.uuid4()))
    agent_id: str = ""
    role: str = ""
    description: str = ""
    status: TaskStatus = TaskStatus.PENDING
    assigned_at: datetime = field(default_factory=datetime.now)
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    sandbox_id: Optional[str] = None
    result: Optional[Any] = None
    error_message: Optional[str] = None


# @dataclass
class SandboxSession
    id: str = field(default_factory=lambda: str(uuid.uuid4()))
    sandbox_id: str = ""
    agent_id: str = ""
    task_id: Optional[str] = None
    created_at: datetime = field(default_factory=datetime.now)
    last_activity: datetime = field(default_factory=datetime.now)
    changes_count: int = 0
    merge_decision: MergeDecision = MergeDecision.MANUAL_REVIEW


# @dataclass
class Project
    id: str = field(default_factory=lambda: str(uuid.uuid4()))
    name: str = ""
    base_path: Path = field(default_factory=Path)
    description: str = ""
    created_at: datetime = field(default_factory=datetime.now)
    last_updated: datetime = field(default_factory=datetime.now)
    agents: Dict[str, AgentTask] = field(default_factory=dict)
    sandboxes: Dict[str, SandboxSession] = field(default_factory=dict)
    task_queue: List[AgentTask] = field(default_factory=list)


@versioned_class("1.0.0")
class ProjectManager
    #     """
    #     Manages project state, agent tasks, coordinates work between agents,
    #     and decides on merge strategies for sandbox changes.
    #     """

    #     def __init__(self, base_path: Union[Path, str], config_path: Optional[str] = None):
    #         """
    #         Initialize the ProjectManager.

    #         Args:
    #             base_path: Base directory for the project
    #             config_path: Optional path to configuration file
    #         """
    self.base_path = Path(base_path)
    self.projects: Dict[str, Project] = {}
    self.default_project: Optional[Project] = None

    #         # Integration with sandbox and merge systems
    self.sandbox_manager = SandboxManager(base_project_path=self.base_path)
    self.diff_merge_api = DiffMergeAPI(base_path=self.base_path)

    #         # Configuration
    self.config: Dict[str, Any] = {
    #             "default_merge_strategy": MergeStrategy.AUTO,
    #             "auto_merge_threshold": 0.8,  # Confidence threshold for auto-merge
    #             "enable_ai_review": True,
    #             "sandbox_retention_period": 3600,  # seconds
    #             "merge_conflict_handling": "manual",
    #             "agent_timeout": 1800,  # seconds
    #         }

    #         if config_path and os.path.exists(config_path):
                self.load_config(config_path)

    #     def load_config(self, config_path: str):
    #         """Load configuration from JSON file."""
    #         try:
    #             with open(config_path, "r") as f:
                    self.config.update(json.load(f))
                logger.info(f"Loaded configuration from {config_path}")
    #         except Exception as e:
                logger.error(f"Failed to load configuration: {e}")

    #     def create_project(self, name: str, description: str = "") -> Project:
    #         """
    #         Create a new project.

    #         Args:
    #             name: Project name
    #             description: Project description

    #         Returns:
    #             The created Project instance
    #         """
    project_id = str(uuid.uuid4())
    project = Project(
    id = project_id,
    name = name,
    base_path = math.divide(self.base_path, name,)
    description = description,
    #         )

    self.projects[project_id] = project

    #         # Create project directory
    project.base_path.mkdir(parents = True, exist_ok=True)

    #         # Set as default if this is the first project
    #         if self.default_project is None:
    self.default_project = project

            logger.info(f"Created project: {name} ({project_id})")
    #         return project

    #     def get_project(self, project_id: str) -> Optional[Project]:
    #         """
    #         Get a project by ID.

    #         Args:
    #             project_id: Project ID

    #         Returns:
    #             The Project instance or None if not found
    #         """
            return self.projects.get(project_id)

    #     def get_default_project(self) -> Project:
    #         """
    #         Get the default project.

    #         Returns:
    #             The default Project instance

    #         Raises:
    #             ValueError: If no default project is set
    #         """
    #         if self.default_project is None:
                raise ValueError("No default project set")
    #         return self.default_project

    #     def assign_task(
    #         self,
    #         agent_id: str,
    #         role: str,
    #         description: str,
    sandbox_id: Optional[str] = None,
    #     ) -> AgentTask:
    #         """
    #         Assign a task to an agent.

    #         Args:
    #             agent_id: Agent identifier
                role: Role of the agent (e.g., coder, tester, writer)
    #             description: Task description
    #             sandbox_id: Optional existing sandbox ID

    #         Returns:
    #             The created AgentTask instance
    #         """
    project = self.get_default_project()

    #         # Create the task
    task = AgentTask(agent_id=agent_id, role=role, description=description)

    #         # Create sandbox if not provided
    #         if sandbox_id is None:
    sandbox_id = f"{agent_id}_{task.id}"
    #             try:
    #                 # Update to match SandboxManager API: agent_id first, sandbox_id second
    sandbox_path = self.sandbox_manager.create_sandbox(
    agent_id = agent_id, sandbox_id=sandbox_id
    #                 )
    task.sandbox_id = sandbox_id
    #                 logger.info(f"Created sandbox {sandbox_id} for task {task.id}")
    #             except Exception as e:
                    logger.error(f"Failed to create sandbox: {e}")
    task.status = TaskStatus.FAILED
    task.error_message = str(e)
    #                 return task
    #         else:
    task.sandbox_id = sandbox_id

    #         # Update project state
    project.agents[task.id] = task
            project.task_queue.append(task)

    #         # Mark task as in progress
            self.start_task(task.id)

            logger.info(f"Assigned task {task.id} to agent {agent_id}")
    #         return task

    #     def start_task(self, task_id: str):
    #         """
    #         Mark a task as started.

    #         Args:
    #             task_id: Task ID
    #         """
    project = self.get_default_project()
    task = project.agents.get(task_id)

    #         if task and task.status == TaskStatus.PENDING:
    task.status = TaskStatus.IN_PROGRESS
    task.started_at = datetime.now()

    #             # Create sandbox session
    #             if task.sandbox_id:
    session = SandboxSession(
    sandbox_id = task.sandbox_id, agent_id=task.agent_id, task_id=task.id
    #                 )
    project.sandboxes[task.sandbox_id] = session

    #     def complete_task(
    #         self,
    #         task_id: str,
    result: Optional[Any] = None,
    error_message: Optional[str] = None,
    #     ):
    #         """
    #         Mark a task as completed.

    #         Args:
    #             task_id: Task ID
    #             result: Optional task result
    #             error_message: Optional error message if failed
    #         """
    project = self.get_default_project()
    task = project.agents.get(task_id)

    #         if not task:
                logger.warning(f"Task {task_id} not found")
    #             return

    task.completed_at = datetime.now()

    #         if error_message:
    task.status = TaskStatus.FAILED
    task.error_message = error_message
                logger.error(f"Task {task_id} failed: {error_message}")
    #         else:
    task.status = TaskStatus.COMPLETED
    task.result = result
                logger.info(f"Task {task_id} completed successfully")

    #     def review_merge(
    self, sandbox_id: str, confidence_score: float = 0.0
    #     ) -> MergeDecision:
    #         """
    #         Review and decide on merging changes from a sandbox.

    #         Args:
    #             sandbox_id: Sandbox ID
                confidence_score: Optional confidence score (0.0 to 1.0)

    #         Returns:
    #             MergeDecision enum
    #         """
    project = self.get_default_project()
    session = project.sandboxes.get(sandbox_id)

    #         if not session:
                logger.warning(f"Sandbox {sandbox_id} not found")
    #             return MergeDecision.MANUAL_REVIEW

    #         # Update session
    session.last_activity = datetime.now()

    #         # Apply configuration logic
    #         if confidence_score >= self.config.get("auto_merge_threshold", 0.8):
    decision = MergeDecision.AUTO_ACCEPT
    #         elif self.config.get("enable_ai_review", True):
    decision = MergeDecision.AI_REVIEW
    #         else:
    decision = MergeDecision.MANUAL_REVIEW

    session.merge_decision = decision

    #         logger.info(f"Decision for sandbox {sandbox_id}: {decision.value}")
    #         return decision

    #     def merge_changes(
    self, sandbox_id: str, strategy: Optional[MergeStrategy] = None
    #     ) -> bool:
    #         """
    #         Merge changes from a sandbox to the main project.

    #         Args:
    #             sandbox_id: Sandbox ID
    #             strategy: Optional merge strategy overrides configuration

    #         Returns:
    #             True if merge successful, False otherwise
    #         """
    project = self.get_default_project()
    session = project.sandboxes.get(sandbox_id)

    #         if not session:
                logger.warning(f"Sandbox {sandbox_id} not found")
    #             return False

    #         # Get sandbox path using the agent_id
    sandbox_path = self.sandbox_manager.get_sandbox_path(session.agent_id)
    #         if not sandbox_path:
    #             logger.error(f"Sandbox path not found for agent {session.agent_id}")
    #             return False

    #         # Determine merge strategy
    merge_strategy = strategy or self.config.get(
    #             "default_merge_strategy", MergeStrategy.AUTO
    #         )

    #         # Apply decision review if needed
    #         if session.merge_decision == MergeDecision.AUTO_ACCEPT:
    #             # Proceed with auto merge
    #             pass
    #         elif session.merge_decision == MergeDecision.AI_REVIEW:
    #             # In a real implementation, this would use AI to review
    #             # For now, we'll simulate the AI review result
    #             logger.info(f"AI review for sandbox {sandbox_id}")
    #         elif session.merge_decision == MergeDecision.MANUAL_REVIEW:
    #             logger.info(f"Manual review required for sandbox {sandbox_id}")
    #             return False
    #         elif session.merge_decision == MergeDecision.AUTO_REJECT:
                logger.info(f"Auto-rejecting changes from sandbox {sandbox_id}")
    #             return False

    #         # Get diff
    #         try:
    diff = self.diff_merge_api.get_diff(sandbox_path)
    #         except Exception as e:
    #             logger.error(f"Failed to get diff for sandbox {sandbox_id}: {e}")
    #             return False

    #         # Apply merge
    #         try:
    #             # Use the correct merge_changes method from DiffMergeAPI
    merge_strategy = merge_strategy or self.config.get(
    #                 "default_merge_strategy", MergeStrategy.AUTO
    #             )
    result = self.diff_merge_api.merge_changes(
    sandbox_path = sandbox_path,
    target_path = project.base_path,
    strategy = merge_strategy,
    #             )

    #             if result.success:
    #                 # Update session
    session.last_activity = datetime.now()
    session.changes_count + = result.changes_applied

    #                 # Remove sandbox
                    self.sandbox_manager.destroy_sandbox(sandbox_id)

                    logger.info(f"Successfully merged changes from sandbox {sandbox_id}")
    #                 return True
    #             else:
    #                 logger.error(f"Merge failed for sandbox {sandbox_id}: {result.message}")
    #                 return False

    #         except Exception as e:
                logger.error(f"Error during merge process: {e}")
    #             return False

    #     def list_active_sandboxes(
    self, project_id: Optional[str] = None
    #     ) -> List[SandboxSession]:
    #         """
    #         List all active sandbox sessions.

    #         Args:
    #             project_id: Optional project ID. If None, uses default project.

    #         Returns:
    #             List of active SandboxSession instances
    #         """
    #         if project_id:
    project = self.get_project(project_id)
    #         else:
    project = self.get_default_project()

    #         if not project:
    #             return []

    active_sessions = []
    current_time = datetime.now()

    #         for session in project.sandboxes.values():
    elapsed = math.subtract((current_time, session.last_activity).total_seconds())
    #             if elapsed < self.config.get("sandbox_retention_period", 3600):
                    active_sessions.append(session)
    #             else:
    #                 # Clean up expired sandbox
                    self.sandbox_manager.destroy_sandbox(session.sandbox_id)
    #                 del project.sandboxes[session.sandbox_id]

    #         return active_sessions

    #     def get_task_status_summary(
    self, project_id: Optional[str] = None
    #     ) -> Dict[str, int]:
    #         """
    #         Get a summary of task statuses.

    #         Args:
    #             project_id: Optional project ID. If None, uses default project.

    #         Returns:
    #             Dictionary with status counts
    #         """
    #         if project_id:
    project = self.get_project(project_id)
    #         else:
    project = self.get_default_project()

    #         if not project:
    #             return {}

    #         summary = {status.value: 0 for status in TaskStatus}

    #         for task in project.agents.values():
    summary[task.status.value] + = 1

    #         return summary

    #     def get_sandbox_status_summary(
    self, project_id: Optional[str] = None
    #     ) -> Dict[str, int]:
    #         """
    #         Get a summary of sandbox decision statuses.

    #         Args:
    #             project_id: Optional project ID. If None, uses default project.

    #         Returns:
    #             Dictionary with decision counts
    #         """
    #         if project_id:
    project = self.get_project(project_id)
    #         else:
    project = self.get_default_project()

    #         if not project:
    #             return {}

    #         summary = {decision.value: 0 for decision in MergeDecision}

    #         for session in project.sandboxes.values():
    summary[session.merge_decision.value] + = 1

    #         return summary

    #     def get_agent_tasks(
    self, agent_id: str, project_id: Optional[str] = None
    #     ) -> List[AgentTask]:
    #         """
    #         Get all tasks for a specific agent.

    #         Args:
    #             agent_id: Agent identifier
    #             project_id: Optional project ID. If None, uses default project.

    #         Returns:
    #             List of AgentTask instances for the agent
    #         """
    #         if project_id:
    project = self.get_project(project_id)
    #         else:
    project = self.get_default_project()

    #         if not project:
    #             return []

    #         return [task for task in project.agents.values() if task.agent_id == agent_id]

    #     def get_project_stats(self, project_id: Optional[str] = None) -> Dict[str, Any]:
    #         """
    #         Get comprehensive project statistics.

    #         Args:
    #             project_id: Optional project ID. If None, uses default project.

    #         Returns:
    #             Dictionary with project statistics
    #         """
    #         if project_id:
    project = self.get_project(project_id)
    #         else:
    project = self.get_default_project()

    #         if not project:
    #             return {}

    stats = {
    #             "name": project.name,
    #             "description": project.description,
                "created_at": project.created_at.isoformat(),
                "last_updated": project.last_updated.isoformat(),
                "total_tasks": len(project.agents),
                "total_sandboxes": len(project.sandboxes),
                "active_sandboxes": len(
    #                 [
    #                     s
    #                     for s in project.sandboxes.values()
    #                     if (datetime.now() - s.last_activity).total_seconds()
                        < self.config.get("sandbox_retention_period", 3600)
    #                 ]
    #             ),
                "task_status_summary": self.get_task_status_summary(project.id),
                "sandbox_status_summary": self.get_sandbox_status_summary(project.id),
                "task_queue_length": len(project.task_queue),
    #         }

    #         # Update last modified time
    project.last_updated = datetime.now()

    #         return stats


import .merge.Change,
