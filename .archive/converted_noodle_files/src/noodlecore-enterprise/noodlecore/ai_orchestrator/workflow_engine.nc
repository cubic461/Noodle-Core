# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Workflow Engine: Integrates role assignment, endpoints to agents-server.js, fault-tolerant with cluster_manager.py.
Processes tasks, auto-triggers workflows (e.g., code gen -> test).
# """

import asyncio
import logging
import datetime.datetime
import typing.Any,

import aiohttp

import ..runtime.distributed.cluster_manager.get_cluster_manager
import ..utils.error_handler.ErrorHandler
import .ffi_ai_bridge.FFIAIBridge
import .task_queue.TaskQueue

logger = logging.getLogger(__name__)

# Role assignment matrix from role_assignment_system.md
ROLE_MATRIX = {
#     "architecture_design": ["architect", "research_specialist"],
#     "code_implementation": ["code_specialist", "quality_assurance_specialist"],
#     "testing": ["quality_assurance_specialist", "code_specialist"],
#     "documentation": ["documentation_specialist", "architect"],
#     "security_implementation": ["security_specialist", "code_specialist"],
#     "performance_optimization": [
#         "performance_optimization_specialist",
#         "code_specialist",
#     ],
#     "database_design": ["database_specialist", "code_specialist"],
#     "integration": ["integration_specialist", "code_specialist"],
#     "deployment": ["devops_specialist", "integration_specialist"],
#     "research": ["research_specialist", "architect"],
# }


class WorkflowEngine
    #     def __init__(self, config: Dict[str, Any] = None):
    self.config = config or {}
    self.error_handler = ErrorHandler()
    self.cluster_manager = get_cluster_manager()
    self.task_queue = TaskQueue()  # Assumes shared instance
    self.ffi_bridge = FFIAIBridge()
    self.session = None
    self.running = False

    #         # Agents-server endpoints
    self.server_url = self.config.get("server_url", "http://localhost:3000")
    self.role_assign_endpoint = f"{self.server_url}/api/role-assign"

    #     async def start(self):
    #         """Start the workflow engine."""
    #         if self.running:
    #             return

    self.running = True
    self.session = aiohttp.ClientSession()

    #         # Register cluster events for fault tolerance
            self.cluster_manager.register_event_handler(
    #             self.cluster_manager.ClusterEventType.NODE_FAILED, self._handle_node_failure
    #         )

            logger.info("WorkflowEngine started")

    #     async def stop(self):
    #         """Stop the workflow engine."""
    self.running = False
    #         if self.session:
                await self.session.close()
            logger.info("WorkflowEngine stopped")

    #     def assign_role(self, task_data: Dict[str, Any]) -> str:
    #         """
    #         Assign role based on task type and suggestions.

    #         Args:
    #             task_data: Task with type, suggestions.

    #         Returns:
    #             Assigned role
    #         """
    task_type = task_data.get("type", "general")
    suggestions = task_data.get("suggestions", [])

    #         # Use matrix
    possible_roles = ROLE_MATRIX.get(task_type, ["code_specialist"])

    #         # Prioritize by suggestion scores
    role_scores = {}
    #         for sug in suggestions:
    #             if "role" in sug:
    role_scores[sug["role"]] = sug.get("score", 0) + role_scores.get(
    #                     sug["role"], 0
    #                 )

    #         # Select top role in possible_roles
    assigned_role = max(possible_roles, key=lambda r: role_scores.get(r, 0))

    #         # Call agents-server /api/role-assign for validation
            asyncio.create_task(self._validate_role_with_server(assigned_role, task_data))

    #         logger.info(f"Assigned role {assigned_role} for task {task_data.get('id')}")
    #         return assigned_role

    #     async def process_task(self, task_id: str):
    #         """
    #         Process a task: assign role, get suggestions, execute workflow steps.
    #         """
    task = await self.task_queue.get_status(task_id)
    #         if not task:
    #             return

    #         # Assign role
    role = self.assign_role(task)
    task["assigned_role"] = role

    #         # Get AI suggestions
    suggestions = await self.ffi_bridge.get_suggestions(task)
    task["suggestions"] = suggestions

            # Workflow steps based on role/type (placeholder auto-trigger)
    #         if task["type"] == "code_implementation":
    #             # Trigger validation after code gen
                await self._trigger_followup(task_id, "testing")

    #         # Update status
            await self.task_queue.complete_task(
    #             task_id, {"role": role, "suggestions": suggestions}
    #         )

    #         logger.info(f"Processed task {task_id} with role {role}")

    #     async def get_workflow_status(self, task_id: str) -> Dict[str, Any]:
    #         """Get workflow status for task."""
    status = await self.task_queue.get_status(task_id)
    #         if status:
    status["workflow_steps"] = [
    #                 "assigned",
    #                 "suggestions_generated",
    #                 "executed",
    #             ]  # Placeholder
    #         return status or {"error": "Task not found"}

    #     async def _validate_role_with_server(self, role: str, task_data: Dict[str, Any]):
    #         """Validate role assignment via agents-server.js endpoint."""
    #         try:
    #             async with self.session.post(
    self.role_assign_endpoint, json = {"role": role, "task": task_data}
    #             ) as resp:
    #                 if resp.status == 200:
    validation = await resp.json()
                        logger.info(f"Role {role} validated by server: {validation}")
    #                 else:
                        logger.warning(f"Role validation failed: {resp.status}")
    #         except Exception as e:
                self.error_handler.handle_error("_validate_role_with_server", e)

    #     async def _trigger_followup(self, task_id: str, followup_type: str):
            """Trigger followup workflow (e.g., test after code)."""
    followup_task = {
    #             "id": f"{task_id}_followup",
    #             "type": followup_type,
    #             "parent_id": task_id,
    #             "description": f"Followup {followup_type} for {task_id}",
    #         }
            await self.task_queue.enqueue(followup_task)
    #         logger.info(f"Triggered followup {followup_type} for {task_id}")

    #     def _handle_node_failure(self, event):
    #         """Handle node failure: reassign tasks."""
            logger.warning(f"Node failure {event.node_id}: reassigning workflows")
            asyncio.create_task(self._reassign_workflows(event.node_id))

    #     async def _reassign_workflows(self, failed_node_id: str):
    #         """Reassign workflows affected by node failure."""
    #         # Use cluster_manager to find and requeue tasks
    active_nodes = self.cluster_manager.get_active_nodes()
    #         if not active_nodes:
    #             return

    #         # Placeholder: requeue all pending tasks to new node
    #         # In production: query tasks on failed node
    pending_tasks = [
    #             t
    #             for t in self.task_queue.task_status.values()
    #             if t["status"] == "processing"
    #         ]
    #         for task in pending_tasks:
    task["status"] = "reassigned"
                await self.task_queue.enqueue(task)

            logger.info(f"Reassigned {len(pending_tasks)} workflows")
