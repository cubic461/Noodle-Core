# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Actor Model for NoodleCore Distributed AI Task Management.

# This module implements the actor model for reliable AI coordination
# and distributed communication using NoodleCore's message passing.
# """

import asyncio
import uuid
import logging
import typing.Dict,
import datetime.datetime
import dataclasses.dataclass
import enum.Enum

import ..utils.logging_utils.LoggingUtils


class MessageType(Enum)
    #     """Types of messages in the distributed system."""
    TASK_ASSIGNMENT = "task_assignment"
    TASK_STATUS = "task_status"
    COORDINATION_REQUEST = "coordination_request"
    HEARTBEAT = "heartbeat"
    SYSTEM_UPDATE = "system_update"
    ERROR = "error"


# @dataclass
class Message
    #     """Individual message in the actor system."""
    #     message_id: str
    #     message_type: MessageType
    #     sender_id: str
    #     receiver_id: str
    #     timestamp: datetime
    #     payload: Dict[str, Any]


class Actor
    #     """Base actor class for distributed communication."""

    #     def __init__(self, actor_id: str):
    self.actor_id = actor_id
    self.message_queue: asyncio.Queue = asyncio.Queue()
    self._message_handlers: Dict[MessageType, Callable] = {}
    self.logger = LoggingUtils.get_logger(f"noodlecore.distributed.actor.{actor_id}")

    #     def register_handler(self, message_type: MessageType, handler: Callable) -> None:
    #         """Register a message handler for a specific message type."""
    self._message_handlers[message_type] = handler

    #     async def receive_message(self, message: Message) -> None:
            """Receive a message (called by the ActorModel)."""
            await self.message_queue.put(message)

    #     async def handle_message(self, message: Message) -> None:
    #         """Handle an incoming message."""
    handler = self._message_handlers.get(message.message_type)
    #         if handler:
                await handler(message)
    #         else:
    #             self.logger.warning(f"No handler for message type {message.message_type}")


class ActorModel
    #     """Actor model implementation for distributed AI communication."""

    #     def __init__(self, workspace_root: str, config: Optional[Dict[str, Any]] = None):
    self.workspace_root = workspace_root
    self.config = config or {}
    self.logger = LoggingUtils.get_logger("noodlecore.distributed.communication")

    #         # Actor registry
    self.actors: Dict[str, Actor] = {}

    #         # Message routing
    self.message_router = asyncio.Queue()
    self._running = False
    self._router_task: Optional[asyncio.Task] = None

            self.logger.info("Actor Model initialized")

    #     async def initialize(self) -> None:
    #         """Initialize the actor model and start background processes."""
    #         try:
    self._running = True
    self._router_task = asyncio.create_task(self._message_router())
                self.logger.info("Actor model initialized successfully")
    #         except Exception as e:
                self.logger.error(f"Failed to initialize actor model: {e}")
    #             raise

    #     async def register_actor(self, actor: Actor) -> bool:
    #         """Register a new actor in the system."""
    #         try:
    #             if actor.actor_id in self.actors:
                    self.logger.warning(f"Actor {actor.actor_id} already registered")
    #                 return False

    self.actors[actor.actor_id] = actor
                self.logger.info(f"Registered actor {actor.actor_id}")
    #             return True
    #         except Exception as e:
                self.logger.error(f"Failed to register actor {actor.actor_id}: {e}")
    #             return False

    #     async def send_message(self, sender_id: str, receiver_id: str,
    #                           message_type: MessageType, payload: Dict[str, Any]) -> str:
    #         """Send a message between actors."""
    message = Message(
    message_id = str(uuid.uuid4()),
    message_type = message_type,
    sender_id = sender_id,
    receiver_id = receiver_id,
    timestamp = datetime.now(),
    payload = payload
    #         )

    #         # Route message
            await self.message_router.put(message)
    #         return message.message_id

    #     async def cleanup(self) -> None:
    #         """Cleanup resources and stop background processes."""
    #         try:
    self._running = False

    #             if self._router_task:
                    self._router_task.cancel()
    #                 try:
    #                     await self._router_task
    #                 except asyncio.CancelledError:
    #                     pass

                self.logger.info("Actor model cleaned up")
    #         except Exception as e:
                self.logger.error(f"Error during actor model cleanup: {e}")

    #     async def _message_router(self) -> None:
    #         """Route messages between actors."""
    #         while self._running:
    #             try:
    message = await asyncio.wait_for(self.message_router.get(), timeout=1.0)
                    await self._deliver_message(message)
    #             except asyncio.TimeoutError:
    #                 continue
    #             except asyncio.CancelledError:
    #                 break
    #             except Exception as e:
                    self.logger.error(f"Error in message router: {e}")

    #     async def _deliver_message(self, message: Message) -> None:
    #         """Deliver a message to the target actor."""
    #         try:
    #             if message.receiver_id not in self.actors:
                    self.logger.warning(f"Target actor {message.receiver_id} not found")
    #                 return

    target_actor = self.actors[message.receiver_id]
                await target_actor.handle_message(message)

    #         except Exception as e:
                self.logger.error(f"Failed to deliver message {message.message_id}: {e}")