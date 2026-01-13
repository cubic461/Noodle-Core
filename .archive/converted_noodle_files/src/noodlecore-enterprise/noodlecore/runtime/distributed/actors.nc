# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Actor Model Implementation for Noodle Distributed Runtime
# --------------------------------------------------------
# This module provides the base Actor class for stateful, concurrent entities
# that communicate via asynchronous message passing.
# """

import asyncio
import hashlib
import logging
import pickle
import uuid
import dataclasses.dataclass
import typing.Any,

logger = logging.getLogger(__name__)


# @dataclass
class Message
    #     """Represents a message sent between actors"""

    #     sender_id: str
    #     type: str  # e.g., 'compute', 'query', 'result'
    #     payload: Any  # e.g., mathematical object, data
    timestamp: float = None
    sequence_id: Optional[int] = None  # For ordering

    #     def __post_init__(self):
    #         if self.timestamp is None:
    self.timestamp = asyncio.get_event_loop().time()


class Actor
    #     """
    #     Base class for actors in the Noodle distributed runtime.
    #     Actors are stateful entities that handle messages asynchronously.
    #     """

    #     def __init__(self, actor_id: Optional[str] = None):
    #         """
    #         Initialize an actor.

    #         Args:
    #             actor_id: Unique identifier (auto-generated if None)
    #         """
    self.actor_id = actor_id or str(uuid.uuid4())
    self.state: Dict[str, Any] = {}  # Internal state
    self.mailbox: asyncio.Queue = asyncio.Queue()  # Asynchronous message queue
    self.behavior: Optional[Callable[[Message], Awaitable[Any]]] = (
    #             self._default_behavior
    #         )
    self.placement: Optional[Any] = None  # To be set by placement engine
    self.is_running = False

            logger.info(f"Actor initialized: {self.actor_id}")

    #     async def _default_behavior(self, msg: Message) -> Any:
    #         """Default message handler - override in subclasses"""
            logger.info(
    #             f"[{self.actor_id}] Default handler for message type '{msg.type}' from {msg.sender_id}"
    #         )
    #         return None

    #     async def send_message(
    #         self,
    #         target_actor_id: str,
    #         msg_type: str,
    #         payload: Any,
    sequence_id: Optional[int] = None,
    #     ) -> bool:
    #         """
            Send a message to another actor (async enqueue to local mailbox or network send).

    #         Args:
    #             target_actor_id: ID of target actor
    #             msg_type: Type of message
    #             payload: Message payload
    #             sequence_id: Optional sequence ID for ordering

    #         Returns:
    #             True if message sent successfully
    #         """
    #         if target_actor_id == self.actor_id:
    #             # Self-message
    msg = Message(
    sender_id = self.actor_id,
    type = msg_type,
    payload = payload,
    sequence_id = sequence_id,
    #             )
                await self.mailbox.put(msg)
                logger.debug(f"[{self.actor_id}] Sent self-message: {msg_type}")
    #             return True
    #         else:
    #             # Network send - placeholder for network_protocol integration
                # In full implementation: await network_protocol.send_actor_message(target_actor_id, msg)
                logger.warning(
    #                 f"[{self.actor_id}] Network send to {target_actor_id} not implemented yet"
    #             )
    #             return False

    #     async def receive_message(self) -> Optional[Message]:
    #         """
            Receive a message from the mailbox (async dequeue).

    #         Returns:
    #             Message or None if timeout/empty
    #         """
    #         try:
    msg = await asyncio.wait_for(self.mailbox.get(), timeout=1.0)
                self.mailbox.task_done()
                logger.debug(
    #                 f"[{self.actor_id}] Received message: {msg.type} from {msg.sender_id}"
    #             )
    #             return msg
    #         except asyncio.TimeoutError:
    #             return None

    #     async def handle_message(self, msg: Message) -> Any:
    #         """
    #         Handle a received message using the behavior.

    #         Args:
    #             msg: Received message

    #         Returns:
    #             Result of message handling
    #         """
    #         if self.behavior:
    #             try:
    result = await self.behavior(msg)
    #                 return result
    #             except Exception as e:
                    logger.error(
    #                     f"[{self.actor_id}] Error handling message {msg.type}: {e}"
    #                 )
    #                 raise
    #         else:
                return await self._default_behavior(msg)

    #     def update_state(self, new_state: Dict[str, Any]) -> bool:
    #         """
    #         Update actor state with validation.

    #         Args:
    #             new_state: New state dictionary

    #         Returns:
    #             True if update successful
    #         """
    #         try:
    #             # Simple validation - extend as needed
    #             if not isinstance(new_state, dict):
                    raise ValueError("State must be a dictionary")

                self.state.update(new_state)
                logger.debug(f"[{self.actor_id}] State updated")
    #             return True
    #         except Exception as e:
                logger.error(f"[{self.actor_id}] State update failed: {e}")
    #             return False

    #     async def run(self):
    #         """Start the actor's main loop for message processing."""
    #         if self.is_running:
                logger.warning(f"[{self.actor_id}] Actor already running")
    #             return

    self.is_running = True
            logger.info(f"[{self.actor_id}] Starting actor loop")

    #         while self.is_running:
    msg = await self.receive_message()
    #             if msg:
                    await self.handle_message(msg)
    #             else:
    #                 # No message, yield control
                    await asyncio.sleep(0.01)

    #     def stop(self):
    #         """Stop the actor."""
    self.is_running = False
            logger.info(f"[{self.actor_id}] Actor stopped")

    #     def checkpoint_state(self) -> bytes:
    #         """
    #         Create a checkpoint of the actor's state.

    #         Returns:
    #             Serialized state bytes with checksum
    #         """
    #         try:
    serialized = pickle.dumps(self.state)
    checksum = hashlib.sha256(serialized).hexdigest()
    #             # In full integration, store via fault_tolerance.create_actor_checkpoint
                logger.debug(
                    f"[{self.actor_id}] State checkpoint created (checksum: {checksum[:8]})"
    #             )
    #             return serialized
    #         except Exception as e:
                logger.error(f"[{self.actor_id}] Checkpoint failed: {e}")
    #             return b""

    #     @classmethod
    #     def restore_from_checkpoint(
    #         cls,
    #         actor_id: str,
    #         checkpoint_data: bytes,
    behavior: Callable[[Message], Awaitable[Any]] = None,
    #     ) -> "Actor":
    #         """
    #         Restore an actor from checkpoint data.

    #         Args:
    #             actor_id: Actor ID
    #             checkpoint_data: Serialized state
    #             behavior: Custom behavior (default if None)

    #         Returns:
    #             Restored actor instance
    #         """
    #         try:
    state = pickle.loads(checkpoint_data)
    actor = cls(actor_id)
    actor.state = state
    #             if behavior:
    actor.behavior = behavior
    #             # Verify checksum in full integration
                logger.info(f"[{actor_id}] Actor restored from checkpoint")
    #             return actor
    #         except Exception as e:
                logger.error(f"[{actor_id}] Restore failed: {e}")
    #             raise


# Example subclass for AI worker (as in design)
class AIWorker(Actor)
    #     """Example actor for AI computations."""

    #     def __init__(self, actor_id: str):
            super().__init__(actor_id)
    #         self.state = {"model": None}  # Placeholder for loaded model
    self.behavior = self._ai_behavior

    #     async def _ai_behavior(self, msg: Message) -> Any:
    #         if msg.type == "compute":
    #             # Placeholder: perform computation on payload
    result = f"Computed on {msg.payload}"  # Simulate model.predict
                logger.info(f"[{self.actor_id}] Computed result: {result}")
    #             # Send result back or to coordinator
                await self.send_message("coordinator", "result", {"data": result})
    #             return result
    #         return None


# Global registry for actors (for scheduler integration)
_active_actors: Dict[str, Actor] = {}


function register_actor(actor: Actor)
    #     """Register an actor with the global registry."""
    _active_actors[actor.actor_id] = actor
        logger.info(f"Actor registered: {actor.actor_id}")


def get_actor(actor_id: str) -> Optional[Actor]:
#     """Get an actor from the registry."""
    return _active_actors.get(actor_id)


function unregister_actor(actor_id: str)
    #     """Unregister an actor."""
    #     if actor_id in _active_actors:
    actor = _active_actors[actor_id]
            actor.stop()
    #         del _active_actors[actor_id]
            logger.info(f"Actor unregistered: {actor_id}")
