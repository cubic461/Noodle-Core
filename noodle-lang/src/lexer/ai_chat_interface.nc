# """
# Costrict-style AI Communication Interface for NoodleCore Desktop IDE
# 
# This module provides a chat-like interface for AI communication with
# role-based configurations, similar to Costrict, RooCode, and Cline.
# """

import typing
import dataclasses
import enum
import logging
import time
import json
import uuid
import asyncio
from datetime import datetime

from ...desktop import GUIError
from ..core.events.event_system import EventSystem, EventType, MouseEvent, KeyboardEvent
from ..core.rendering.rendering_engine import RenderingEngine, Color, Font, Rectangle, Point
from ..core.components.component_library import ComponentLibrary

from .ai_providers import (
    AIProviderType, AIProviderManager, AIRequest, AIResponse,
    AIProviderError
)


class MessageRole(enum.Enum):
    """Message roles for AI conversation."""
    USER = "user"
    ASSISTANT = "assistant"
    SYSTEM = "system"


class AIRole(enum.Enum):
    """Predefined AI roles."""
    CODE_REVIEWER = "code_reviewer"
    PROGRAMMER = "programmer"
    ARCHITECT = "architect"
    DEBUGGER = "debugger"
    TESTER = "tester"
    DOCUMENTER = "documenter"
    SECURITY_EXPERT = "security_expert"
    PERFORMANCE_EXPERT = "performance_expert"
    GENERAL_ASSISTANT = "general_assistant"
    CUSTOM = "custom"


@dataclasses.dataclass
class AIRoleConfig:
    """AI role configuration."""
    role_type: AIRole
    name: str
    description: str
    system_prompt: str
    behavior_traits: typing.List[str]
    code_specialties: typing.List[str]
    temperature: float = 0.7
    max_tokens: int = 1000
    enabled: bool = True


@dataclasses.dataclass
class ChatMessage:
    """Chat message structure."""
    message_id: str
    role: MessageRole
    content: str
    timestamp: float
    provider: typing.Optional[AIProviderType] = None
    model: typing.Optional[str] = None
    tokens_used: typing.Optional[int] = None
    cost: typing.Optional[float] = None
    metadata: typing.Dict[str, typing.Any] = None
    
    def __post_init__(self):
        if self.metadata is None:
            self.metadata = {}


@dataclasses.dataclass
class ConversationContext:
    """Conversation context for AI interactions."""
    conversation_id: str
    title: str
    messages: typing.List[ChatMessage]
    current_role: AIRole
    provider: typing.Optional[AIProviderType] = None
    model: typing.Optional[str] = None
    file_context: typing.Optional[str] = None
    created_at: float = None
    last_activity: float = None
    
    def __post_init__(self):
        if self.created_at is None:
            self.created_at = time.time()
        if self.last_activity is None:
            self.last_activity = time.time()


@dataclasses.dataclass
class CodeAnalysisRequest:
    """Code analysis request structure."""
    request_id: str
    code: str
    file_path: typing.Optional[str] = None
    analysis_type: typing.List[str] = None
    language: str = "python"
    
    def __post_init__(self):
        if self.analysis_type is None:
            self.analysis_type = ["syntax", "style", "performance", "security"]


class AIChatInterfaceError(GUIError):
    """Exception raised for AI chat interface operations."""
    
    def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
        super().__init__(message, "9201", details)


class AIChatInterface:
    """
    Costrict-style AI Communication Interface.
    
    Provides a chat-like interface for AI interaction with role-based
    configurations and IDE integration.
    """
    
    def __init__(self):
        """Initialize AI Chat Interface."""
        self.logger = logging.getLogger(__name__)
        
        # Core GUI systems
        self._event_system = None
        self._rendering_engine = None
        self._component_library = None
        
        # Window and component references
        self._window_id = None
        self._main_panel_component_id = None
        self._chat_area_component_id = None
        self._input_area_component_id = None
        self._send_button_component_id = None
        self._role_dropdown_id = None
        self._provider_dropdown_id = None
        self._model_dropdown_id = None
        self._clear_button_id = None
        self._export_button_id = None
        
        # AI Provider Manager
        self._ai_provider_manager = AIProviderManager()
        
        # Conversation state
        self._current_conversation: typing.Optional[ConversationContext] = None
        self._conversations: typing.Dict[str, ConversationContext] = {}
        self._ai_roles: typing.Dict[AIRole, AIRoleConfig] = {}
        
        # Message processing
        self._is_processing = False
        self._message_queue: typing.List[ChatMessage] = []
        
        # Callbacks
        self._on_message_sent: typing.Callable = None
        self._on_message_received: typing.Callable = None
        self._on_role_changed: typing.Callable = None
        self._on_code_analyzed: typing.Callable = None
        
        # Initialize AI roles
        self._initialize_ai_roles()
    
    def initialize(self, window_id: str, event_system: EventSystem,
                   rendering_engine: RenderingEngine, component_library: ComponentLibrary):
        """
        Initialize the AI Chat Interface.
        
        Args:
            window_id: Window ID to attach to
            event_system: Event system instance
            rendering_engine: Rendering engine instance
            component_library: Component library instance
        """
        try:
            self._window_id = window_id
            self._event_system = event_system
            self._rendering_engine = rendering_engine
            self._component_library = component_library
            
            # Initialize AI provider manager
            asyncio.create_task(self._ai_provider_manager.initialize())
            
            # Create UI components
            self._create_ui_components()
            
            # Register event handlers
            self._register_event_handlers()
            
            # Create default conversation
            self._create_new_conversation()
            
            self.logger.info("AI Chat Interface initialized")
            
        except Exception as e:
            self.logger.error(f"Failed to initialize AI Chat Interface: {str(e)}")
            raise AIChatInterfaceError(f"Interface initialization failed: {str(e)}")
    
    def _initialize_ai_roles(self):
        """Initialize predefined AI roles."""
        try:
            # Code Reviewer
            self._ai_roles[AIRole.CODE_REVIEWER] = AIRoleConfig(
                role_type=AIRole.CODE_REVIEWER,
                name="Code Reviewer",
                description="Expert in code quality, best practices, and architecture",
                system_prompt="""You are an expert code reviewer with deep knowledge of software engineering best practices. 
Your role is to provide thorough, constructive feedback on code quality, maintainability, performance, and adherence to best practices.

When reviewing code:
1. Analyze code structure and architecture
2. Identify potential bugs and security issues
3. Suggest performance optimizations
4. Evaluate maintainability and readability
5. Check compliance with coding standards
6. Provide actionable improvement suggestions

Always be specific, constructive, and provide examples when suggesting improvements.""",
                behavior_traits=["analytical", "thorough", "constructive", "detail-oriented"],
                code_specialties=["architecture", "quality", "best-practices", "maintainability"],
                temperature=0.3,
                max_tokens=800
            )
            
            # Programmer
            self._ai_roles[AIRole.PROGRAMMER] = AIRoleConfig(
                role_type=AIRole.PROGRAMMER,
                name="Programmer",
                description="Expert programmer focused on implementation and problem-solving",
                system_prompt="""You are an expert programmer with extensive experience in software development. 
Your role is to help with coding tasks, problem-solving, and implementation guidance.

When helping with programming:
1. Provide clear, working code examples
2. Explain programming concepts and patterns
3. Help debug and troubleshoot issues
4. Suggest implementation approaches
5. Focus on practical, actionable solutions
6. Consider edge cases and error handling

Always write clean, well-commented code and explain your reasoning.""",
                behavior_traits=["practical", "problem-solving", "detail-oriented", "solution-focused"],
                code_specialties=["implementation", "algorithms", "debugging", "optimization"],
                temperature=0.5,
                max_tokens=1000
            )
            
            # Architect
            self._ai_roles[AIRole.ARCHITECT] = AIRoleConfig(
                role_type=AIRole.ARCHITECT,
                name="Software Architect",
                description="Expert in system design and architecture patterns",
                system_prompt="""You are a senior software architect with expertise in system design and architecture.
Your role is to help with high-level design decisions, system architecture, and technical strategy.

When discussing architecture:
1. Analyze system requirements and constraints
2. Recommend appropriate design patterns
3. Evaluate scalability and performance trade-offs
4. Consider maintainability and extensibility
5. Provide architectural best practices
6. Suggest technology choices and justifications

Focus on the bigger picture while considering implementation details.""",
                behavior_traits=["strategic", "analytical", "big-picture", "innovative"],
                code_specialties=["architecture", "design-patterns", "scalability", "technology-strategy"],
                temperature=0.4,
                max_tokens=1200
            )
            
            # Debugger
            self._ai_roles[AIRole.DEBUGGER] = AIRoleConfig(
                role_type=AIRole.DEBUGGER,
                name="Debugger",
                description="Expert in debugging, error analysis, and troubleshooting",
                system_prompt="""You are an expert debugger with deep knowledge of debugging techniques and error analysis.
Your role is to help identify, analyze, and resolve bugs and performance issues.

When debugging:
1. Analyze error messages and symptoms
2. Suggest debugging strategies and tools
3. Identify potential root causes
4. Provide step-by-step troubleshooting guides
5. Recommend testing approaches
6. Help prevent similar issues in the future

Be systematic, methodical, and thorough in your analysis.""",
                behavior_traits=["systematic", "methodical", "analytical", "solution-oriented"],
                code_specialties=["debugging", "error-analysis", "testing", "troubleshooting"],
                temperature=0.2,
                max_tokens=800
            )
            
            # General Assistant
            self._ai_roles[AIRole.GENERAL_ASSISTANT] = AIRoleConfig(
                role_type=AIRole.GENERAL_ASSISTANT,
                name="General Assistant",
                description="Versatile AI assistant for general programming questions",
                system_prompt="""You are a helpful AI assistant with expertise in software development and programming.
Your role is to provide general programming assistance, answer questions, and help with various development tasks.

When assisting:
1. Provide clear explanations and examples
2. Answer technical questions comprehensively
3. Help with learning and skill development
4. Suggest resources and further reading
5. Offer practical advice and guidance
6. Be encouraging and supportive

Adapt your response style to the user's knowledge level and specific needs.""",
                behavior_traits=["helpful", "comprehensive", "encouraging", "adaptable"],
                code_specialties=["general-programming", "learning", "best-practices", "resources"],
                temperature=0.7,
                max_tokens=1000
            )
            
            self.logger.info("AI roles initialized")
            
        except Exception as e:
            self.logger.error(f"Failed to initialize AI roles: {e}")
    
    def _create_ui_components(self):
        """Create the AI chat interface UI components."""
        try:
            # Create main panel
            self._main_panel_component_id = self._component_library.create_component(
                component_type="panel",
                window_id=self._window_id,
                title="AI Chat Interface",
                x=350,
                y=20,
                width=500,
                height=550,
                show_border=True
            )
            
            # Role dropdown
            self._role_dropdown_id = self._component_library.create_component(
                component_type="dropdown",
                window_id=self._window_id,
                title="AI Role:",
                x=360,
                y=40,
                width=150,
                height=25,
                options=[role.name for role in self._ai_roles.keys()]
            )
            
            # Provider dropdown
            self._provider_dropdown_id = self._component_library.create_component(
                component_type="dropdown",
                window_id=self._window_id,
                title="Provider:",
                x=520,
                y=40,
                width=120,
                height=25,
                options=["Select Provider"]
            )
            
            # Model dropdown
            self._model_dropdown_id = self._component_library.create_component(
                component_type="dropdown",
                window_id=self._window_id,
                title="Model:",
                x=650,
                y=40,
                width=120,
                height=25,
                options=["Select Model"]
            )
            
            # Chat area (scrollable text area)
            self._chat_area_component_id = self._component_library.create_component(
                component_type="text_area",
                window_id=self._window_id,
                title="",
                x=360,
                y=75,
                width=480,
                height=350,
                scrollable=True,
                readonly=True
            )
            
            # Input area
            self._input_area_component_id = self._component_library.create_component(
                component_type="text_input",
                window_id=self._window_id,
                title="Message:",
                x=360,
                y=435,
                width=400,
                height=25
            )
            
            # Send button
            self._send_button_component_id = self._component_library.create_component(
                component_type="button",
                window_id=self._window_id,
                title="Send",
                x=770,
                y=435,
                width=60,
                height=25
            )
            
            # Clear conversation button
            self._clear_button_id = self._component_library.create_component(
                component_type="button",
                window_id=self._window_id,
                title="Clear",
                x=360,
                y=470,
                width=60,
                height=25
            )
            
            # Export conversation button
            self._export_button_id = self._component_library.create_component(
                component_type="button",
                window_id=self._window_id,
                title="Export",
                x=430,
                y=470,
                width=60,
                height=25
            )
            
            # Status indicator
            status_label_id = self._component_library.create_component(
                component_type="label",
                window_id=self._window_id,
                title="Ready for conversation",
                x=360,
                y=500,
                width=200,
                height=20
            )
            
            self.logger.info("AI Chat Interface UI components created")
            
        except Exception as e:
            self.logger.error(f"Failed to create UI components: {str(e)}")
            raise AIChatInterfaceError(f"UI component creation failed: {str(e)}")
    
    def _register_event_handlers(self):
        """Register event handlers for UI interactions."""
        try:
            # Send message on button click
            self._event_system.register_handler(
                EventType.MOUSE_CLICK,
                self._handle_send_message,
                window_id=self._window_id,
                component_id=self._send_button_component_id
            )
            
            # Send message on Enter key
            self._event_system.register_handler(
                EventType.KEY_PRESS,
                self._handle_input_keypress,
                window_id=self._window_id,
                component_id=self._input_area_component_id
            )
            
            # Role change
            self._event_system.register_handler(
                EventType.MOUSE_CLICK,
                self._handle_role_change,
                window_id=self._window_id,
                component_id=self._role_dropdown_id
            )
            
            # Clear conversation
            self._event_system.register_handler(
                EventType.MOUSE_CLICK,
                self._handle_clear_conversation,
                window_id=self._window_id,
                component_id=self._clear_button_id
            )
            
            # Export conversation
            self._event_system.register_handler(
                EventType.MOUSE_CLICK,
                self._handle_export_conversation,
                window_id=self._window_id,
                component_id=self._export_button_id
            )
            
        except Exception as e:
            self.logger.error(f"Failed to register event handlers: {str(e)}")
            raise AIChatInterfaceError(f"Event handler registration failed: {str(e)}")
    
    def _create_new_conversation(self, role: AIRole = AIRole.GENERAL_ASSISTANT):
        """Create a new conversation."""
        try:
            conversation_id = str(uuid.uuid4())
            
            # Get AI role config
            role_config = self._ai_roles[role]
            
            # Create conversation context
            self._current_conversation = ConversationContext(
                conversation_id=conversation_id,
                title=f"Chat with {role_config.name}",
                messages=[],
                current_role=role
            )
            
            # Add system message
            system_message = ChatMessage(
                message_id=str(uuid.uuid4()),
                role=MessageRole.SYSTEM,
                content=role_config.system_prompt,
                timestamp=time.time()
            )
            self._current_conversation.messages.append(system_message)
            
            # Store conversation
            self._conversations[conversation_id] = self._current_conversation
            
            self.logger.info(f"Created new conversation: {conversation_id}")
            
        except Exception as e:
            self.logger.error(f"Failed to create new conversation: {e}")
    
    def _handle_send_message(self, event: MouseEvent):
        """Handle send message button click."""
        try:
            asyncio.create_task(self._send_user_message())
            
        except Exception as e:
            self.logger.error(f"Error handling send message: {e}")
    
    def _handle_input_keypress(self, event: KeyboardEvent):
        """Handle input keypress (Enter to send)."""
        try:
            if event.key == "Enter" and not event.shift_key:
                asyncio.create_task(self._send_user_message())
            
        except Exception as e:
            self.logger.error(f"Error handling input keypress: {e}")
    
    def _handle_role_change(self, event: MouseEvent):
        """Handle AI role change."""
        try:
            # Get selected role
            # In real implementation, would get selected index
            selected_role = AIRole.GENERAL_ASSISTANT  # Placeholder
            
            if self._current_conversation:
                self._current_conversation.current_role = selected_role
                
                # Add system message for new role
                role_config = self._ai_roles[selected_role]
                system_message = ChatMessage(
                    message_id=str(uuid.uuid4()),
                    role=MessageRole.SYSTEM,
                    content=role_config.system_prompt,
                    timestamp=time.time()
                )
                self._current_conversation.messages.append(system_message)
                
                # Update UI
                self._update_chat_area()
                
                # Notify callback
                if self._on_role_changed:
                    self._on_role_changed(selected_role)
            
        except Exception as e:
            self.logger.error(f"Error handling role change: {e}")
    
    def _handle_clear_conversation(self, event: MouseEvent):
        """Handle clear conversation."""
        try:
            self._create_new_conversation(self._current_conversation.current_role if self._current_conversation else AIRole.GENERAL_ASSISTANT)
            self._update_chat_area()
            
        except Exception as e:
            self.logger.error(f"Error clearing conversation: {e}")
    
    def _handle_export_conversation(self, event: MouseEvent):
        """Handle export conversation."""
        try:
            if self._current_conversation:
                asyncio.create_task(self._export_conversation())
            
        except Exception as e:
            self.logger.error(f"Error exporting conversation: {e}")
    
    async def _send_user_message(self):
        """Send user message and get AI response."""
        try:
            if self._is_processing or not self._current_conversation:
                return
            
            # Get message text
            # In real implementation, would get text from input component
            message_text = "Hello, can you help me with Python programming?"
            
            if not message_text.strip():
                return
            
            # Create user message
            user_message = ChatMessage(
                message_id=str(uuid.uuid4()),
                role=MessageRole.USER,
                content=message_text,
                timestamp=time.time()
            )
            
            # Add to conversation
            self._current_conversation.messages.append(user_message)
            self._current_conversation.last_activity = time.time()
            
            # Update UI
            self._update_chat_area()
            
            # Clear input
            # self._component_library.set_component_text(self._input_area_component_id, "")
            
            # Set processing state
            self._is_processing = True
            self._update_status("AI is thinking...")
            
            # Get AI response
            await self._get_ai_response()
            
        except Exception as e:
            self.logger.error(f"Error sending user message: {e}")
            self._is_processing = False
            self._update_status("Error occurred")
    
    async def _get_ai_response(self):
        """Get AI response to user message."""
        try:
            if not self._current_conversation:
                return
            
            # Prepare conversation context
            role_config = self._ai_roles[self._current_conversation.current_role]
            
            # Build prompt from conversation history
            conversation_prompt = self._build_conversation_prompt()
            
            # Create AI request
            request = AIRequest(
                provider_type=AIProviderType.OPENROUTER,  # Default provider
                model="anthropic/claude-3-sonnet",  # Default model
                prompt=conversation_prompt,
                max_tokens=role_config.max_tokens,
                temperature=role_config.temperature
            )
            
            # Send request
            response = await self._ai_provider_manager.send_request(request)
            
            # Create AI message
            ai_message = ChatMessage(
                message_id=str(uuid.uuid4()),
                role=MessageRole.ASSISTANT,
                content=response.content,
                timestamp=time.time(),
                provider=response.model,
                tokens_used=response.usage.get("total_tokens", 0) if response.usage else None,
                cost=response.cost
            )
            
            # Add to conversation
            self._current_conversation.messages.append(ai_message)
            self._current_conversation.last_activity = time.time()
            
            # Update UI
            self._update_chat_area()
            
            # Reset processing state
            self._is_processing = False
            self._update_status("Ready for conversation")
            
            # Notify callbacks
            if self._on_message_received:
                self._on_message_received(ai_message)
            
        except Exception as e:
            self.logger.error(f"Error getting AI response: {e}")
            self._is_processing = False
            self._update_status("Error getting response")
    
    def _build_conversation_prompt(self) -> str:
        """Build conversation prompt from history."""
        try:
            if not self._current_conversation:
                return ""
            
            # Get system prompt
            role_config = self._ai_roles[self._current_conversation.current_role]
            system_prompt = role_config.system_prompt
            
            # Build conversation context
            messages = []
            for msg in self._current_conversation.messages[-10:]:  # Last 10 messages
                if msg.role == MessageRole.USER:
                    messages.append(f"Human: {msg.content}")
                elif msg.role == MessageRole.ASSISTANT:
                    messages.append(f"Assistant: {msg.content}")
            
            # Combine into prompt
            conversation_text = "\n".join(messages)
            
            prompt = f"""{system_prompt}

Conversation history:
{conversation_text}

Please respond to the most recent message from the human. Be helpful, specific, and provide code examples when relevant."""
            
            return prompt
            
        except Exception as e:
            self.logger.error(f"Error building conversation prompt: {e}")
            return "Please respond to the user's message."
    
    def _update_chat_area(self):
        """Update chat area with conversation."""
        try:
            if not self._current_conversation:
                return
            
            # Build chat text
            chat_lines = []
            for msg in self._current_conversation.messages:
                timestamp = datetime.fromtimestamp(msg.timestamp).strftime("%H:%M")
                
                if msg.role == MessageRole.USER:
                    chat_lines.append(f"[{timestamp}] You: {msg.content}")
                elif msg.role == MessageRole.ASSISTANT:
                    chat_lines.append(f"[{timestamp}] AI: {msg.content}")
                elif msg.role == MessageRole.SYSTEM:
                    chat_lines.append(f"[{timestamp}] System: {msg.content}")
            
            chat_text = "\n".join(chat_lines)
            
            # Update chat area
            # In real implementation, would set text and scroll to bottom
            self.logger.debug(f"Updating chat area with {len(chat_lines)} messages")
            
        except Exception as e:
            self.logger.error(f"Error updating chat area: {e}")
    
    def _update_status(self, status: str):
        """Update status indicator."""
        try:
            # In real implementation, would update status label
            self.logger.debug(f"Status: {status}")
            
        except Exception as e:
            self.logger.error(f"Error updating status: {e}")
    
    async def _export_conversation(self):
        """Export conversation to file."""
        try:
            if not self._current_conversation:
                return
            
            # Create export data
            export_data = {
                "conversation_id": self._current_conversation.conversation_id,
                "title": self._current_conversation.title,
                "role": self._current_conversation.current_role.value,
                "created_at": self._current_conversation.created_at,
                "last_activity": self._current_conversation.last_activity,
                "messages": [
                    {
                        "message_id": msg.message_id,
                        "role": msg.role.value,
                        "content": msg.content,
                        "timestamp": msg.timestamp,
                        "provider": msg.provider.value if msg.provider else None,
                        "model": msg.model,
                        "tokens_used": msg.tokens_used,
                        "cost": msg.cost
                    }
                    for msg in self._current_conversation.messages
                ]
            }
            
            # Save to file
            from pathlib import Path
            export_path = Path.home() / "noodlecore_chat_export.json"
            with open(export_path, 'w') as f:
                json.dump(export_data, f, indent=2)
            
            self._update_status(f"Conversation exported to {export_path}")
            
        except Exception as e:
            self.logger.error(f"Error exporting conversation: {e}")
            self._update_status("Export failed")
    
    # Public API
    
    def set_message_sent_callback(self, callback: typing.Callable[[ChatMessage], None]):
        """Set callback for when message is sent."""
        self._on_message_sent = callback
    
    def set_message_received_callback(self, callback: typing.Callable[[ChatMessage], None]):
        """Set callback for when message is received."""
        self._on_message_received = callback
    
    def set_role_changed_callback(self, callback: typing.Callable[[AIRole], None]):
        """Set callback for when role changes."""
        self._on_role_changed = callback
    
    def set_code_analyzed_callback(self, callback: typing.Callable[[typing.Dict[str, typing.Any]], None]):
        """Set callback for when code is analyzed."""
        self._on_code_analyzed = callback
    
    def send_message(self, message: str, role: AIRole = None) -> str:
        """Send message programmatically and return response."""
        try:
            # Set role if provided
            if role and self._current_conversation:
                self._current_conversation.current_role = role
            
            # Create user message
            user_message = ChatMessage(
                message_id=str(uuid.uuid4()),
                role=MessageRole.USER,
                content=message,
                timestamp=time.time()
            )
            
            # Add to conversation
            if self._current_conversation:
                self._current_conversation.messages.append(user_message)
                self._update_chat_area()
            
            # Note: This is synchronous for now, but could be made async
            return "Message queued for AI response"
            
        except Exception as e:
            self.logger.error(f"Error sending message: {e}")
            return f"Error: {str(e)}"
    
    def analyze_code(self, code: str, analysis_type: typing.List[str] = None) -> typing.Dict[str, typing.Any]:
        """Analyze code using AI."""
        try:
            # Create analysis request
            request = CodeAnalysisRequest(
                request_id=str(uuid.uuid4()),
                code=code,
                analysis_type=analysis_type
            )
            
            # Prepare analysis prompt
            analysis_prompt = f"""Please analyze the following code:

```{code}```

Provide analysis for: {', '.join(request.analysis_type) if request.analysis_type else 'general analysis'}

Return your analysis in a structured format with specific findings and recommendations."""
            
            # Create AI request
            ai_request = AIRequest(
                provider_type=AIProviderType.OPENROUTER,
                model="anthropic/claude-3-sonnet",
                prompt=analysis_prompt,
                max_tokens=800
            )
            
            # Send request (blocking for now)
            # In real implementation, this would be async
            response = asyncio.run(self._ai_provider_manager.send_request(ai_request))
            
            if response.success:
                return {
                    "success": True,
                    "analysis": response.content,
                    "tokens_used": response.usage.get("total_tokens", 0) if response.usage else 0,
                    "cost": response.cost
                }
            else:
                return {
                    "success": False,
                    "error": response.error
                }
            
        except Exception as e:
            self.logger.error(f"Error analyzing code: {e}")
            return {
                "success": False,
                "error": str(e)
            }
    
    def get_conversation_history(self) -> typing.List[ChatMessage]:
        """Get current conversation history."""
        return self._current_conversation.messages.copy() if self._current_conversation else []
    
    def get_available_roles(self) -> typing.List[AIRole]:
        """Get available AI roles."""
        return list(self._ai_roles.keys())
    
    async def shutdown(self):
        """Shutdown AI Chat Interface."""
        try:
            await self._ai_provider_manager.shutdown()
            self.logger.info("AI Chat Interface shutdown complete")
            
        except Exception as e:
            self.logger.error(f"Error during interface shutdown: {e}")