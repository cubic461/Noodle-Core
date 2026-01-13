# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Core communication flow for NoodleCore.

# This module implements the validation communication flow between modules
# to ensure proper data exchange and coordination.

# The communication flow is:
[AI Agent] → [noodlecore.ai.guard] → (validation) → [noodlecore.linter] →
(AST verification) → [noodlecore.compiler.frontend] → [noodlecore.ide.runtime] →
# [Executor / Sandbox / NoodleNet Node]
# """

import asyncio
import logging
import time
import typing.Dict,
import dataclasses.dataclass

import .message.(
#     Message, MessageType, ComponentType, MessagePriority, MessageFactory
# )
import .message_passing.MessageRouter
import .request_response.RequestResponseHandler,
import .event_propagation.EventManager
import .error_handling.ErrorHandler,
import .exceptions.(
#     CommunicationError,
#     CommunicationFlowError,
#     ComponentNotAvailableError,
# )

logger = logging.getLogger(__name__)


# @dataclass
class FlowStep
    #     """Represents a step in the communication flow."""
    #     name: str
    #     source: ComponentType
    #     destination: ComponentType
    #     message_type: MessageType
    timeout: float = 30.0
    retry_count: int = 3
    required: bool = True


class CommunicationFlow
    #     """
    #     Implements the validation communication flow between modules.

    #     This class manages the flow of messages through the validation pipeline,
    #     ensuring proper data exchange and coordination between components.
    #     """

    #     def __init__(self):
    self.message_router = MessageRouter()
    self.request_handler = RequestResponseHandler()
    self.event_manager = EventManager()
    self.error_handler = ErrorHandler()
    self.timeout_monitor = RequestTimeoutMonitor(self.request_handler)

    self._running = False
    self._flow_steps: List[FlowStep] = []
    self._flow_handlers: Dict[str, Callable] = {}

    #         # Initialize the standard flow steps
            self._initialize_flow_steps()

    #         # Register circuit breakers for critical components
            self._initialize_circuit_breakers()

    #         # Register error handlers
            self._initialize_error_handlers()

    #     def _initialize_flow_steps(self) -> None:
    #         """Initialize the standard communication flow steps."""
    self._flow_steps = [
                FlowStep(
    name = "ai_agent_to_guard",
    source = ComponentType.AI_AGENT,
    destination = ComponentType.AI_GUARD,
    message_type = MessageType.VALIDATION,
    timeout = 30.0,
    retry_count = 3,
    required = True,
    #             ),
                FlowStep(
    name = "guard_to_linter",
    source = ComponentType.AI_GUARD,
    destination = ComponentType.LINTER,
    message_type = MessageType.AST_VERIFICATION,
    timeout = 30.0,
    retry_count = 3,
    required = True,
    #             ),
                FlowStep(
    name = "linter_to_compiler",
    source = ComponentType.LINTER,
    destination = ComponentType.COMPILER_FRONTEND,
    message_type = MessageType.COMPILATION,
    timeout = 30.0,
    retry_count = 3,
    required = True,
    #             ),
                FlowStep(
    name = "compiler_to_ide",
    source = ComponentType.COMPILER_FRONTEND,
    destination = ComponentType.IDE_RUNTIME,
    message_type = MessageType.EXECUTION,
    timeout = 30.0,
    retry_count = 3,
    required = True,
    #             ),
                FlowStep(
    name = "ide_to_executor",
    source = ComponentType.IDE_RUNTIME,
    destination = ComponentType.EXECUTOR,
    message_type = MessageType.EXECUTION,
    timeout = 30.0,
    retry_count = 3,
    required = False,  # Optional step
    #             ),
    #         ]

    #     def _initialize_circuit_breakers(self) -> None:
    #         """Initialize circuit breakers for critical components."""
    #         # Create circuit breaker configurations
    critical_config = CircuitBreakerConfig(
    failure_threshold = 5,
    recovery_timeout = 60.0,
    success_threshold = 3,
    #         )

    #         # Register circuit breakers for each component
    #         for component in ComponentType:
                self.error_handler.register_circuit_breaker(
    name = component.value,
    config = critical_config,
    #             )

    #     def _initialize_error_handlers(self) -> None:
    #         """Initialize error handlers for common error codes."""
    #         # Handler for component not available errors
            self.error_handler.register_error_handler(
    error_code = 1003,  # ComponentNotAvailableError
    handler = self._handle_component_not_available,
    #         )

    #         # Handler for message timeout errors
            self.error_handler.register_error_handler(
    error_code = 1002,  # MessageTimeoutError
    handler = self._handle_message_timeout,
    #         )

    #         # Handler for communication flow errors
            self.error_handler.register_error_handler(
    error_code = 1013,  # CommunicationFlowError
    handler = self._handle_flow_error,
    #         )

    #     async def start(self) -> None:
    #         """Start the communication flow system."""
    #         if self._running:
                logger.warning("Communication flow is already running")
    #             return

    self._running = True

    #         # Start all subsystems
            await self.message_router.start()
            await self.event_manager.start()
            await self.timeout_monitor.start()

    #         # Register message handlers for each component
            self._register_message_handlers()

            logger.info("Communication flow system started")

    #     async def stop(self) -> None:
    #         """Stop the communication flow system."""
    #         if not self._running:
    #             return

    self._running = False

    #         # Stop all subsystems
            await self.message_router.stop()
            await self.event_manager.stop()
            await self.timeout_monitor.stop()

            logger.info("Communication flow system stopped")

    #     def _register_message_handlers(self) -> None:
    #         """Register message handlers for each component."""
    #         for component in ComponentType:
                self.message_router.register_component(
    component = component,
    handler = self._create_component_handler(component),
    #             )

    #     def _create_component_handler(self, component: ComponentType) -> Callable:
    #         """Create a message handler for a specific component."""
    #         async def handler(message: Message) -> None:
    #             try:
    #                 # Get the circuit breaker for this component
    circuit_breaker = self.error_handler.get_circuit_breaker(component.value)

    #                 if circuit_breaker:
    #                     # Call the handler through the circuit breaker
                        await circuit_breaker.call(
    #                         self._process_component_message,
    #                         component,
    #                         message,
    #                     )
    #                 else:
    #                     # Call the handler directly
                        await self._process_component_message(component, message)

    #             except Exception as e:
                    await self.error_handler.handle_error(
    error = e,
    component = component,
    message = message,
    severity = ErrorSeverity.HIGH,
    #                 )

    #         return handler

    #     async def _process_component_message(
    #         self,
    #         component: ComponentType,
    #         message: Message
    #     ) -> None:
    #         """Process a message for a specific component."""
    #         # Handle different message types
    #         if message.type == MessageType.REQUEST:
                await self.request_handler.handle_request(message)
    #         elif message.type in [MessageType.RESPONSE, MessageType.ERROR]:
                await self.request_handler.handle_response(message)
    #         elif message.type == MessageType.EVENT:
                await self.event_manager.publish_event(message)
    #         else:
    #             # Handle other message types based on the component
                await self._handle_component_specific_message(component, message)

    #     async def _handle_component_specific_message(
    #         self,
    #         component: ComponentType,
    #         message: Message
    #     ) -> None:
    #         """Handle component-specific message types."""
    #         # Find the flow step for this message
    flow_step = None
    #         for step in self._flow_steps:
    #             if (step.source == component and
    step.destination = = message.destination and
    step.message_type = = message.type):
    flow_step = step
    #                 break

    #         if flow_step and flow_step.name in self._flow_handlers:
    #             # Call the registered flow handler
    handler = self._flow_handlers[flow_step.name]
    #             try:
    #                 if asyncio.iscoroutinefunction(handler):
    response = await handler(message)
    #                 else:
    response = handler(message)

    #                 # Send the response if it's a request
    #                 if message.type == MessageType.REQUEST and response:
                        await self.message_router.send_message(response)

    #             except Exception as e:
    #                 logger.error(f"Error in flow handler for {flow_step.name}: {str(e)}")
    #                 raise
    #         else:
    #             # No specific handler, forward to the next component
                await self.message_router.send_message(message)

    #     def register_flow_handler(
    #         self,
    #         step_name: str,
    #         handler: Callable[[Message], Optional[Message]]
    #     ) -> None:
    #         """
    #         Register a handler for a specific flow step.

    #         Args:
    #             step_name: The name of the flow step
    #             handler: The handler function
    #         """
    self._flow_handlers[step_name] = handler
    #         logger.info(f"Registered flow handler for {step_name}")

    #     async def execute_flow(
    #         self,
    #         initial_data: Dict[str, Any],
    flow_steps: Optional[List[FlowStep]] = None
    #     ) -> Dict[str, Any]:
    #         """
    #         Execute the communication flow with the given initial data.

    #         Args:
    #             initial_data: Initial data for the flow
    #             flow_steps: Optional custom flow steps

    #         Returns:
    #             The result of the flow execution

    #         Raises:
    #             CommunicationFlowError: If the flow execution fails
    #         """
    #         if not self._running:
                raise CommunicationFlowError(
    #                 1013,
    #                 "Communication flow system is not running"
    #             )

    #         # Use custom flow steps if provided, otherwise use the standard ones
    steps = flow_steps or self._flow_steps

    #         # Initialize the context
    context = {
    #             "initial_data": initial_data,
    #             "current_step": 0,
    #             "results": {},
    #             "errors": [],
                "start_time": time.time(),
    #         }

    #         # Execute each step in the flow
    #         for i, step in enumerate(steps):
    #             try:
    context["current_step"] = i

    #                 # Execute the step
    step_result = await self._execute_flow_step(step, context)
    context["results"][step.name] = step_result

                    logger.info(f"Completed flow step {step.name}")

    #             except Exception as e:
    error_msg = f"Error in flow step {step.name}: {str(e)}"
                    logger.error(error_msg)
                    context["errors"].append(error_msg)

    #                 # Handle the error
                    await self.error_handler.handle_error(
    error = e,
    component = step.source,
    severity = ErrorSeverity.HIGH,
    #                 )

    #                 # If this step is required, fail the entire flow
    #                 if step.required:
                        raise CommunicationFlowError(
    #                         1013,
                            f"Required flow step {step.name} failed: {str(e)}"
    #                     )

    #         # Calculate execution time
    context["execution_time"] = time.time() - context["start_time"]

    #         return context

    #     async def _execute_flow_step(
    #         self,
    #         step: FlowStep,
    #         context: Dict[str, Any]
    #     ) -> Dict[str, Any]:
    #         """
    #         Execute a single flow step.

    #         Args:
    #             step: The flow step to execute
    #             context: The flow context

    #         Returns:
    #             The result of the step execution
    #         """
    #         # Get the circuit breaker for the source component
    circuit_breaker = self.error_handler.get_circuit_breaker(step.source.value)

    #         # Create the message for this step
    message = self._create_step_message(step, context)

    #         # Execute the step with retry logic
    retry_handler = self.error_handler.get_retry_handler(step.name)
    #         if not retry_handler:
    #             # Create a default retry handler
    #             from .error_handling import RetryConfig
    retry_handler = self.error_handler.register_retry_handler(
    name = step.name,
    config = RetryConfig(max_retries=step.retry_count),
    #             )

    #         # Execute the step with retry and circuit breaker
    #         async def execute_step():
    #             if circuit_breaker:
                    return await circuit_breaker.call(
    #                     self._send_and_receive_message,
    #                     message,
    #                     step.timeout,
    #                 )
    #             else:
                    return await self._send_and_receive_message(message, step.timeout)

    #         try:
    response = await retry_handler.retry(execute_step)
    #             return response.payload if response else {}

    #         except Exception as e:
                raise CommunicationFlowError(
    #                 1013,
                    f"Failed to execute flow step {step.name}: {str(e)}"
    #             )

    #     def _create_step_message(
    #         self,
    #         step: FlowStep,
    #         context: Dict[str, Any]
    #     ) -> Message:
    #         """Create a message for a flow step."""
    #         # Get the appropriate message factory method
    #         if step.message_type == MessageType.VALIDATION:
                return MessageFactory.create_validation_request(
    source = step.source,
    destination = step.destination,
    code = context["initial_data"].get("code", ""),
    metadata = {"flow_step": step.name},
    #             )
    #         elif step.message_type == MessageType.AST_VERIFICATION:
                return MessageFactory.create_ast_verification_request(
    source = step.source,
    destination = step.destination,
    ast_data = context["results"].get("ai_agent_to_guard", {}),
    metadata = {"flow_step": step.name},
    #             )
    #         elif step.message_type == MessageType.COMPILATION:
                return MessageFactory.create_compilation_request(
    source = step.source,
    destination = step.destination,
    code = context["initial_data"].get("code", ""),
    metadata = {"flow_step": step.name},
    #             )
    #         elif step.message_type == MessageType.EXECUTION:
                return MessageFactory.create_execution_request(
    source = step.source,
    destination = step.destination,
    compiled_code = context["results"].get("linter_to_compiler", {}).get("compiled_code", ""),
    metadata = {"flow_step": step.name},
    #             )
    #         else:
    #             # Default message creation
                return Message(
    type = step.message_type,
    source = step.source,
    destination = step.destination,
    priority = MessagePriority.NORMAL,
    payload = context["initial_data"],
    metadata = {"flow_step": step.name},
    #             )

    #     async def _send_and_receive_message(
    #         self,
    #         message: Message,
    #         timeout: float
    #     ) -> Optional[Message]:
    #         """Send a message and wait for a response."""
    #         try:
    response = await self.message_router.send_request(message, timeout)
    #             return response
    #         except Exception as e:
                raise CommunicationError(
    #                 1005,
                    f"Failed to send and receive message: {str(e)}"
    #             )

    #     async def _handle_component_not_available(self, error_report) -> None:
    #         """Handle component not available errors."""
    component = error_report.component
    #         if component:
                logger.warning(f"Component {component.value} is not available")

    #             # Could implement recovery logic here, such as:
    #             # - Attempting to restart the component
    #             # - Redirecting to a backup component
    #             # - Notifying administrators

    #     async def _handle_message_timeout(self, error_report) -> None:
    #         """Handle message timeout errors."""
            logger.warning(f"Message {error_report.message_id} timed out")

    #         # Could implement recovery logic here, such as:
    #         # - Retrying with a longer timeout
    #         # - Breaking the message into smaller parts
    #         # - Notifying the sender

    #     async def _handle_flow_error(self, error_report) -> None:
    #         """Handle communication flow errors."""
            logger.error(f"Communication flow error: {error_report.message}")

    #         # Could implement recovery logic here, such as:
    #         # - Attempting to resume the flow from the last successful step
    #         # - Rolling back partial changes
    #         # - Notifying administrators

    #     def get_flow_status(self) -> Dict[str, Any]:
    #         """Get the status of the communication flow system."""
    #         return {
    #             "running": self._running,
    #             "flow_steps": [
    #                 {
    #                     "name": step.name,
    #                     "source": step.source.value,
    #                     "destination": step.destination.value,
    #                     "message_type": step.message_type.value,
    #                     "timeout": step.timeout,
    #                     "retry_count": step.retry_count,
    #                     "required": step.required,
    #                 }
    #                 for step in self._flow_steps
    #             ],
                "registered_handlers": list(self._flow_handlers.keys()),
                "component_status": self.message_router.get_component_status(),
                "queue_status": self.message_router.get_queue_status(),
                "circuit_breaker_status": self.error_handler.get_circuit_breaker_states(),
                "error_statistics": self.error_handler.get_error_statistics(),
    #         }