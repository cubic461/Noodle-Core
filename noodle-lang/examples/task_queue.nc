# Converted from Python to NoodleCore
# Original file: src

# """
# Task Queue: Async MQL-based queue with pub-sub for agent tasks.
# Uses asyncio.Queue for core queuing, WebSocket for pub-sub to agents-server.js.
# """

import asyncio
import json
import logging
import datetime.datetime
import typing.Any

import aiohttp

import ..runtime.distributed.cluster_manager.get_cluster_manager

logger = logging.getLogger(__name__)


class TaskQueue
    #     def __init__(self, config: Dict[str, Any] = None):
    self.config = config or {}
    self.queue = asyncio.Queue()
    self.task_status: Dict[str, Dict[str, Any]] = {}
    self.ws_client: Optional[aiohttp.ClientSession] = None
    self.ws: Optional[aiohttp.ClientWebSocketResponse] = None
    self.running = False
    self.cluster_manager = get_cluster_manager()

    #         # Pub-sub config
    self.pubsub_url = self.config.get("pubsub_url", "ws://localhost:3000/ws")
    self.mql_format = self.config.get("mql_format", "json")  # MQL as JSON dicts

    #     async def start(self):
    #         """Start the queue and WebSocket pub-sub."""
    #         if self.running:
    #             return

    self.running = True
    self.ws_client = aiohttp.ClientSession()
            await self._connect_pubsub()

    #         # Register cluster events for distributed queuing
            self.cluster_manager.register_event_handler(
    #             self.cluster_manager.ClusterEventType.NODE_FAILED, self._handle_node_failure
    #         )

    #         logger.info("TaskQueue started with pub-sub")

    #     async def stop(self):
    #         """Stop the queue and pub-sub."""
    self.running = False
    #         if self.ws:
                await self.ws.close()
    #         if self.ws_client:
                await self.ws_client.close()
            logger.info("TaskQueue stopped")

    #     async def _connect_pubsub(self):
    #         """Connect to WebSocket for pub-sub."""
    #         try:
    self.ws = await self.ws_client.ws_connect(self.pubsub_url)
                logger.info(f"Connected to pub-sub at {self.pubsub_url}")
    #         except Exception as e:
                logger.error(f"Failed to connect to pub-sub: {e}")
    #             # Retry logic
                asyncio.create_task(self._retry_connect())

    #     async def _retry_connect(self, delay: float = 5.0):
    #         """Retry WebSocket connection."""
            await asyncio.sleep(delay)
    #         if self.running:
                await self._connect_pubsub()

    #     async def enqueue(self, task_data: Dict[str, Any]) -str):
    #         """
    #         Enqueue a task and publish event.

    #         Args:
    #             task_data: MQL task dict with id, type, description, role, etc.

    #         Returns:
    #             Task ID
    #         """
    #         if "id" not in task_data:
    task_data["id"] = str(hash(f"{task_data['type']}-{datetime.now()}"))

    task_id = task_data["id"]
    task_data["status"] = "queued"
    task_data["timestamp"] = datetime.now().isoformat()

            await self.queue.put(task_data)
    self.task_status[task_id] = task_data

    #         # Publish to pub-sub
            await self._publish_event("task_queued", task_data)

            logger.info(f"Task {task_id} enqueued")
    #         return task_id

    #     async def dequeue(self) -Optional[Dict[str, Any]]):
    #         """Dequeue a task and update status."""
    #         if self.queue.empty():
    #             return None

    task = await self.queue.get()
    task_id = task["id"]
    task["status"] = "processing"
    self.task_status[task_id] = task

            await self._publish_event("task_started", task)

            logger.info(f"Task {task_id} dequeued")
    #         return task

    #     async def get_status(self, task_id: str) -Optional[Dict[str, Any]]):
    #         """Get task status."""
            return self.task_status.get(task_id)

    #     async def complete_task(self, task_id: str, result: Any):
    #         """Mark task as completed."""
    #         if task_id in self.task_status:
    self.task_status[task_id]["status"] = "completed"
    self.task_status[task_id]["result"] = result
    self.task_status[task_id]["completed_at"] = datetime.now().isoformat()

                await self._publish_event("task_completed", self.task_status[task_id])
                logger.info(f"Task {task_id} completed")

    #     async def _publish_event(self, event_type: str, data: Dict[str, Any]):
    #         """Publish event via WebSocket."""
    #         if not self.ws or self.ws.closed:
    #             return

    #         try:
    message = json.dumps(
    #                 {
    #                     "type": event_type,
    #                     "data": data,
                        "timestamp": datetime.now().isoformat(),
    #                 }
    #             )
                await self.ws.send_str(message)
    #         except Exception as e:
                logger.error(f"Failed to publish {event_type}: {e}")

    #     def _handle_node_failure(self, event):
    #         """Handle node failure: requeue tasks."""
    #         # Placeholder: requeue tasks assigned to failed node
            logger.warning(f"Requeuing tasks from failed node {event.node_id}")
            asyncio.create_task(self._requeue_node_tasks(event.node_id))

    #     async def _requeue_node_tasks(self, node_id: str):
    #         """Requeue tasks from failed node using cluster info."""
    #         # Integrate with cluster_manager to find affected tasks
    #         pass
