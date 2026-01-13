# """
# AI Integration System for NoodleCore Desktop IDE
# 
# This module provides unified AI functionality by integrating all AI components
# including provider management, chat interface, and enhanced AI panel.
# """

import typing
import dataclasses
import enum
import logging
import time
import json
import asyncio
import threading
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor

from ...desktop import GUIError
from ..core.events.event_system import EventSystem, EventType, MouseEvent, KeyboardEvent
from ..core.rendering.rendering_engine import RenderingEngine, Color, Font, Rectangle, Point
from ..core.components.component_library import ComponentLibrary

from .ai_providers import (
    AIProviderType, AIProviderManager, AIRequest, AIResponse,
    AIProviderError, AIProviderConfigError
)
from .ai_provider_manager import AIProviderManagerUI, ProviderUIState
from .ai_chat_interface import (
    AIChatInterface, ChatMessage, MessageRole, AIRole, ConversationContext
)
from .ai_panel_integrated import (
    EnhancedAIPanel, AIAnalysisResult, AISuggestion, AIInsight, AnalysisType
)


class AIComponentType(enum.Enum):
    """AI component types."""
    PROVIDER_MANAGER = "provider_manager"
    CHAT_INTERFACE = "chat_interface"
    ENHANCED_PANEL = "enhanced_panel"
    CODE_COMPLETION = "code_completion"
    ERROR_DETECTION = "error_detection"
    LEARNING_SYSTEM = "learning_system"


class AIIntegrationMode(enum.Enum):
    """AI integration modes."""
    DISABLED = "disabled"
    BASIC = "basic"
    ENHANCED = "enhanced"
    FULL = "full"


@dataclasses.dataclass
class AIIntegrationConfig:
    """AI integration configuration."""
    enabled: bool = True
    mode: AIIntegrationMode = AIIntegrationMode.ENHANCED
    auto_analysis: bool = True
    real_time_suggestions: bool = True
    learning_enabled: bool = True
    max_concurrent_requests: int = 5
    request_timeout: float = 30.0
    performance_monitoring: bool = True
    error_recovery: bool = True
    fallback_provider: typing.Optional[AIProviderType] = None


@dataclasses.dataclass
class AIContext:
    """AI context for operations."""
    file_path: str = ""
    code_content: str = ""
    cursor_position: typing.Tuple[int, int] = (1, 1)
    language: str = "python"
    project_context: str = ""
    user_intent: str = ""
    urgency: str = "normal"  # low, normal, high, critical
    timestamp: float = None
    
    def __post_init__(self):
        if self.timestamp is None:
            self.timestamp = time.time()


@dataclasses.dataclass
class AIRequestResult:
    """AI request result with integration data."""
    request_id: str
    component: AIComponentType
    provider: AIProviderType
    model: str
    success: bool
    content: typing.Any = None
    confidence: float = 0.0
    execution_time: float = 0.0
    tokens_used: int = 0
    cost: float = 0.0
    error: str = None
    metadata: typing.Dict[str, typing.Any] = None
    
    def __post_init__(self):
        if self.metadata is None:
            self.metadata = {}


class AIIntegrationError(GUIError):
    """Exception raised for AI integration operations."""
    
    def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
        super().__init__(message, "9401", details)


class AIIntegrationSystem:
    """
    AI Integration System for NoodleCore IDE.
    
    Provides unified AI functionality by coordinating all AI components
    including provider management, chat interface, and enhanced AI panel.
    """
    
    def __init__(self):
        """Initialize AI Integration System."""
        self.logger = logging.getLogger(__name__)
        
        # Core GUI systems
        self._event_system = None
        self._rendering_engine = None
        self._component_library = None
        
        # Window and component references
        self._window_id = None
        
        # AI Components
        self._ai_provider_manager: typing.Optional[AIProviderManager] = None
        self._ai_provider_manager_ui: typing.Optional[AIProviderManagerUI] = None
        self._ai_chat_interface: typing.Optional[AIChatInterface] = None
        self._enhanced_ai_panel: typing.Optional[EnhancedAIPanel] = None
        
        # Integration state
        self._config = AIIntegrationConfig()
        self._current_context = AIContext()
        self._request_queue: typing.List[typing.Tuple[str, typing.Callable]] = []
        self._active_requests: typing.Dict[str, AIRequestResult] = {}
        self._component_status: typing.Dict[AIComponentType, bool] = {}
        
        # Performance and monitoring
        self._request_history: typing.List[AIRequestResult] = []
        self._performance_metrics: typing.Dict[str, typing.Any] = {}
        self._error_counts: typing.Dict[str, int] = {}
        self._executor = ThreadPoolExecutor(max_workers=3)
        
        # Callbacks
        self._on_provider_changed: typing.Callable = None
        self._on_analysis_complete: typing.Callable = None
        self._on_suggestion_received: typing.Callable = None
        self._on_error_occurred: typing.Callable = None
        self._on_performance_alert: typing.Callable = None
        
        # Initialize component status
        for component_type in AIComponentType:
            self._component_status[component_type] = False
    
    def initialize(self, window_id: str, event_system: EventSystem,
                   rendering_engine: RenderingEngine, component_library: ComponentLibrary):
        """
        Initialize the AI Integration System.
        
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
            
            # Initialize AI components
            self._initialize_ai_components()
            
            # Setup integrations
            self._setup_component_integrations()
            
            # Load configuration
            self._load_integration_config()
            
            # Start monitoring
            self._start_performance_monitoring()
            
            self.logger.info("AI Integration System initialized")
            
        except Exception as e:
            self.logger.error(f"Failed to initialize AI Integration System: {str(e)}")
            raise AIIntegrationError(f"Integration system initialization failed: {str(e)}")
    
    def _initialize_ai_components(self):
        """Initialize all AI components."""
        try:
            # Initialize AI Provider Manager
            self._ai_provider_manager = AIProviderManager()
            asyncio.create_task(self._ai_provider_manager.initialize())
            self._component_status[AIComponentType.PROVIDER_MANAGER] = True
            
            # Initialize AI Provider Manager UI
            self._ai_provider_manager_ui = AIProviderManagerUI()
            self._ai_provider_manager_ui.initialize(
                window_id=self._window_id,
                event_system=self._event_system,
                rendering_engine=self._rendering_engine,
                component_library=self._component_library
            )
            
            # Initialize AI Chat Interface
            self._ai_chat_interface = AIChatInterface()
            self._ai_chat_interface.initialize(
                window_id=self._window_id,
                event_system=self._event_system,
                rendering_engine=self._rendering_engine,
                component_library=self._component_library
            )
            
            # Initialize Enhanced AI Panel
            self._enhanced_ai_panel = EnhancedAIPanel()
            self._enhanced_ai_panel.initialize(
                window_id=self._window_id,
                event_system=self._event_system,
                rendering_engine=self._rendering_engine,
                component_library=self._component_library
            )
            
            self.logger.info("AI components initialized")
            
        except Exception as e:
            self.logger.error(f"Failed to initialize AI components: {e}")
            raise AIIntegrationError(f"Component initialization failed: {str(e)}")
    
    def _setup_component_integrations(self):
        """Setup integrations between AI components."""
        try:
            # Provider Manager -> Chat Interface integration
            if self._ai_provider_manager_ui and self._ai_chat_interface:
                self._ai_provider_manager_ui.set_provider_changed_callback(self._handle_provider_change)
                self._ai_provider_manager_ui.set_config_saved_callback(self._handle_config_save)
            
            # Chat Interface -> Enhanced Panel integration
            if self._ai_chat_interface and self._enhanced_ai_panel:
                self._ai_chat_interface.set_code_analyzed_callback(self._handle_code_analyzed)
                self._ai_chat_interface.set_message_received_callback(self._handle_chat_message)
            
            # Enhanced Panel -> Chat Interface integration
            if self._enhanced_ai_panel and self._ai_chat_interface:
                # Setup callbacks for analysis results
                pass
            
            # Cross-component provider sharing
            self._share_provider_configuration()
            
            self.logger.info("Component integrations setup complete")
            
        except Exception as e:
            self.logger.error(f"Failed to setup component integrations: {e}")
            raise AIIntegrationError(f"Integration setup failed: {str(e)}")
    
    def _share_provider_configuration(self):
        """Share provider configuration between components."""
        try:
            # Get current provider from provider manager
            current_provider, current_model = self._ai_provider_manager.get_current_provider()
            
            if current_provider and self._enhanced_ai_panel:
                # Share provider configuration with enhanced panel
                # This would be done through the provider manager interface
                self.logger.debug(f"Sharing provider config: {current_provider.value}/{current_model}")
            
        except Exception as e:
            self.logger.error(f"Failed to share provider configuration: {e}")
    
    def _load_integration_config(self):
        """Load integration configuration from file."""
        try:
            config_path = Path.home() / ".noodlecore" / "ai_integration.json"
            if config_path.exists():
                with open(config_path, 'r') as f:
                    config_data = json.load(f)
                
                # Load integration settings
                if "integration_config" in config_data:
                    integration_data = config_data["integration_config"]
                    self._config.enabled = integration_data.get("enabled", True)
                    self._config.mode = AIIntegrationMode(integration_data.get("mode", "enhanced"))
                    self._config.auto_analysis = integration_data.get("auto_analysis", True)
                    self._config.real_time_suggestions = integration_data.get("real_time_suggestions", True)
                    self._config.learning_enabled = integration_data.get("learning_enabled", True)
                    self._config.max_concurrent_requests = integration_data.get("max_concurrent_requests", 5)
                    self._config.request_timeout = integration_data.get("request_timeout", 30.0)
                    self._config.performance_monitoring = integration_data.get("performance_monitoring", True)
                    self._config.error_recovery = integration_data.get("error_recovery", True)
                    
                    # Load fallback provider
                    fallback_provider = integration_data.get("fallback_provider")
                    if fallback_provider:
                        self._config.fallback_provider = AIProviderType(fallback_provider)
                
                self.logger.info("Integration configuration loaded")
            
        except Exception as e:
            self.logger.warning(f"Failed to load integration configuration: {e}")
    
    def _save_integration_config(self):
        """Save integration configuration to file."""
        try:
            config_path = Path.home() / ".noodlecore" / "ai_integration.json"
            config_data = {
                "integration_config": {
                    "enabled": self._config.enabled,
                    "mode": self._config.mode.value,
                    "auto_analysis": self._config.auto_analysis,
                    "real_time_suggestions": self._config.real_time_suggestions,
                    "learning_enabled": self._config.learning_enabled,
                    "max_concurrent_requests": self._config.max_concurrent_requests,
                    "request_timeout": self._config.request_timeout,
                    "performance_monitoring": self._config.performance_monitoring,
                    "error_recovery": self._config.error_recovery,
                    "fallback_provider": self._config.fallback_provider.value if self._config.fallback_provider else None
                }
            }
            
            # Ensure directory exists
            config_path.parent.mkdir(exist_ok=True)
            
            with open(config_path, 'w') as f:
                json.dump(config_data, f, indent=2)
            
            self.logger.info("Integration configuration saved")
            
        except Exception as e:
            self.logger.error(f"Failed to save integration configuration: {e}")
    
    def _start_performance_monitoring(self):
        """Start performance monitoring thread."""
        try:
            if self._config.performance_monitoring:
                monitoring_thread = threading.Thread(
                    target=self._performance_monitoring_loop,
                    daemon=True
                )
                monitoring_thread.start()
                
                self.logger.info("Performance monitoring started")
            
        except Exception as e:
            self.logger.error(f"Failed to start performance monitoring: {e}")
    
    def _performance_monitoring_loop(self):
        """Performance monitoring background loop."""
        try:
            while True:
                time.sleep(30)  # Monitor every 30 seconds
                
                # Calculate performance metrics
                self._update_performance_metrics()
                
                # Check for performance alerts
                self._check_performance_alerts()
                
                # Clean up old request history
                self._cleanup_old_requests()
                
        except Exception as e:
            self.logger.error(f"Performance monitoring error: {e}")
    
    def _update_performance_metrics(self):
        """Update performance metrics."""
        try:
            if not self._request_history:
                return
            
            # Calculate metrics for last 100 requests
            recent_requests = self._request_history[-100:]
            
            total_requests = len(recent_requests)
            successful_requests = sum(1 for r in recent_requests if r.success)
            failed_requests = total_requests - successful_requests
            
            avg_execution_time = sum(r.execution_time for r in recent_requests) / total_requests if total_requests > 0 else 0
            avg_tokens_used = sum(r.tokens_used for r in recent_requests) / total_requests if total_requests > 0 else 0
            total_cost = sum(r.cost for r in recent_requests)
            
            self._performance_metrics.update({
                "total_requests": total_requests,
                "successful_requests": successful_requests,
                "failed_requests": failed_requests,
                "success_rate": successful_requests / total_requests if total_requests > 0 else 0,
                "avg_execution_time": avg_execution_time,
                "avg_tokens_used": avg_tokens_used,
                "total_cost": total_cost,
                "timestamp": time.time()
            })
            
        except Exception as e:
            self.logger.error(f"Failed to update performance metrics: {e}")
    
    def _check_performance_alerts(self):
        """Check for performance alerts."""
        try:
            metrics = self._performance_metrics
            if not metrics:
                return
            
            # Check success rate
            if metrics.get("success_rate", 1.0) < 0.8:
                self._trigger_performance_alert("Low success rate", f"Success rate: {metrics['success_rate']:.2%}")
            
            # Check execution time
            if metrics.get("avg_execution_time", 0) > 10.0:
                self._trigger_performance_alert("High execution time", f"Avg time: {metrics['avg_execution_time']:.2f}s")
            
            # Check error rate
            if metrics.get("failed_requests", 0) > 20:
                self._trigger_performance_alert("High error rate", f"Failed requests: {metrics['failed_requests']}")
            
        except Exception as e:
            self.logger.error(f"Failed to check performance alerts: {e}")
    
    def _trigger_performance_alert(self, alert_type: str, message: str):
        """Trigger performance alert."""
        try:
            self.logger.warning(f"Performance Alert - {alert_type}: {message}")
            
            if self._on_performance_alert:
                self._on_performance_alert(alert_type, message)
            
        except Exception as e:
            self.logger.error(f"Failed to trigger performance alert: {e}")
    
    def _cleanup_old_requests(self):
        """Clean up old request history."""
        try:
            # Keep only last 1000 requests
            if len(self._request_history) > 1000:
                self._request_history = self._request_history[-1000:]
                
        except Exception as e:
            self.logger.error(f"Failed to cleanup old requests: {e}")
    
    # Event handlers
    
    def _handle_provider_change(self, provider_type: AIProviderType):
        """Handle provider change event."""
        try:
            self.logger.info(f"Provider changed to: {provider_type.value}")
            
            # Share new provider with other components
            self._share_provider_configuration()
            
            # Update context
            self._current_context.timestamp = time.time()
            
            # Notify callbacks
            if self._on_provider_changed:
                self._on_provider_changed(provider_type)
            
        except Exception as e:
            self.logger.error(f"Failed to handle provider change: {e}")
    
    def _handle_config_save(self, provider_type: AIProviderType, model: str):
        """Handle configuration save event."""
        try:
            self.logger.info(f"Configuration saved: {provider_type.value}/{model}")
            
            # Update performance metrics
            self._performance_metrics["last_config_save"] = time.time()
            
        except Exception as e:
            self.logger.error(f"Failed to handle config save: {e}")
    
    def _handle_code_analyzed(self, analysis_result: typing.Dict[str, typing.Any]):
        """Handle code analysis complete event."""
        try:
            self.logger.debug("Code analysis completed")
            
            if self._on_analysis_complete:
                self._on_analysis_complete(analysis_result)
            
        except Exception as e:
            self.logger.error(f"Failed to handle code analyzed: {e}")
    
    def _handle_chat_message(self, message: ChatMessage):
        """Handle chat message received event."""
        try:
            # Add to request history if it's an AI response
            if message.role == MessageRole.ASSISTANT:
                request_result = AIRequestResult(
                    request_id=message.message_id,
                    component=AIComponentType.CHAT_INTERFACE,
                    provider=message.provider,
                    model=message.model,
                    success=True,
                    content=message.content,
                    tokens_used=message.tokens_used,
                    cost=message.cost
                )
                self._request_history.append(request_result)
            
        except Exception as e:
            self.logger.error(f"Failed to handle chat message: {e}")
    
    # Public API
    
    async def analyze_code(self, context: AIContext, analysis_types: typing.List[AnalysisType] = None) -> typing.Optional[AIRequestResult]:
        """
        Analyze code using integrated AI system.
        
        Args:
            context: AI context for the analysis
            analysis_types: Types of analysis to perform
            
        Returns:
            AI request result
        """
        try:
            if not self._config.enabled or not self._enhanced_ai_panel:
                return None
            
            start_time = time.time()
            request_id = f"analyze_{int(start_time * 1000)}"
            
            # Update context
            self._current_context = context
            
            # Perform analysis using enhanced panel
            success = self._enhanced_ai_panel.analyze_code(
                file_path=context.file_path,
                code_content=context.code_content,
                analysis_types=analysis_types
            )
            
            # Create result
            provider, model = self._ai_provider_manager.get_current_provider() if self._ai_provider_manager else (None, None)
            
            result = AIRequestResult(
                request_id=request_id,
                component=AIComponentType.ENHANCED_PANEL,
                provider=provider,
                model=model,
                success=success,
                execution_time=time.time() - start_time
            )
            
            # Store result
            self._active_requests[request_id] = result
            self._request_history.append(result)
            
            return result
            
        except Exception as e:
            self.logger.error(f"Failed to analyze code: {e}")
            return None
    
    async def get_code_suggestions(self, context: AIContext) -> typing.List[AISuggestion]:
        """
        Get code suggestions using integrated AI system.
        
        Args:
            context: AI context for suggestions
            
        Returns:
            List of AI suggestions
        """
        try:
            if not self._config.enabled or not self._enhanced_ai_panel:
                return []
            
            # Update context
            self._current_context = context
            
            # Get suggestions from enhanced panel
            suggestions = self._enhanced_ai_panel.get_code_suggestions(
                file_path=context.file_path,
                cursor_position=context.cursor_position
            )
            
            return suggestions
            
        except Exception as e:
            self.logger.error(f"Failed to get code suggestions: {e}")
            return []
    
    async def send_chat_message(self, message: str, role: AIRole = None) -> typing.Optional[ChatMessage]:
        """
        Send message through integrated chat interface.
        
        Args:
            message: Message to send
            role: AI role to use
            
        Returns:
            Chat message response
        """
        try:
            if not self._config.enabled or not self._ai_chat_interface:
                return None
            
            # Send message through chat interface
            response_text = self._ai_chat_interface.send_message(message, role)
            
            # Create response message
            response_message = ChatMessage(
                message_id=str(time.time()),
                role=MessageRole.ASSISTANT,
                content=response_text,
                timestamp=time.time()
            )
            
            return response_message
            
        except Exception as e:
            self.logger.error(f"Failed to send chat message: {e}")
            return None
    
    async def request_code_completion(self, context: AIContext, partial_code: str) -> typing.Optional[str]:
        """
        Request code completion using AI providers.
        
        Args:
            context: AI context
            partial_code: Partial code to complete
            
        Returns:
            Completed code or None
        """
        try:
            if not self._config.enabled:
                return None
            
            # Use chat interface for code completion
            completion_request = f"Please complete the following code:\n\n{partial_code}"
            response = await self.send_chat_message(completion_request, AIRole.PROGRAMMER)
            
            return response.content if response else None
            
        except Exception as e:
            self.logger.error(f"Failed to request code completion: {e}")
            return None
    
    def set_integration_config(self, config: AIIntegrationConfig):
        """Set integration configuration."""
        try:
            self._config = config
            self._save_integration_config()
            
            # Apply configuration changes to components
            self._apply_config_to_components()
            
            self.logger.info("Integration configuration updated")
            
        except Exception as e:
            self.logger.error(f"Failed to set integration config: {e}")
    
    def _apply_config_to_components(self):
        """Apply configuration to AI components."""
        try:
            # Apply to enhanced panel
            if self._enhanced_ai_panel:
                self._enhanced_ai_panel.set_auto_analyze(self._config.auto_analysis)
                self._enhanced_ai_panel.set_real_time_suggestions(self._config.real_time_suggestions)
            
            # Apply to other components as needed
            
        except Exception as e:
            self.logger.error(f"Failed to apply config to components: {e}")
    
    def get_component_status(self) -> typing.Dict[AIComponentType, bool]:
        """Get status of all AI components."""
        return self._component_status.copy()
    
    def get_performance_metrics(self) -> typing.Dict[str, typing.Any]:
        """Get performance metrics."""
        return self._performance_metrics.copy()
    
    def get_request_history(self, limit: int = 50) -> typing.List[AIRequestResult]:
        """Get request history."""
        return self._request_history[-limit:] if self._request_history else []
    
    def get_current_context(self) -> AIContext:
        """Get current AI context."""
        return self._current_context
    
    def set_callbacks(self, 
                     on_provider_changed: typing.Callable = None,
                     on_analysis_complete: typing.Callable = None,
                     on_suggestion_received: typing.Callable = None,
                     on_error_occurred: typing.Callable = None,
                     on_performance_alert: typing.Callable = None):
        """Set integration callbacks."""
        self._on_provider_changed = on_provider_changed
        self._on_analysis_complete = on_analysis_complete
        self._on_suggestion_received = on_suggestion_received
        self._on_error_occurred = on_error_occurred
        self._on_performance_alert = on_performance_alert
    
    async def shutdown(self):
        """Shutdown AI Integration System."""
        try:
            # Shutdown all components
            components = [
                self._enhanced_ai_panel,
                self._ai_chat_interface,
                self._ai_provider_manager_ui,
                self._ai_provider_manager
            ]
            
            for component in components:
                if component:
                    try:
                        await component.shutdown()
                    except Exception as e:
                        self.logger.error(f"Error shutting down component: {e}")
            
            # Shutdown executor
            self._executor.shutdown(wait=True)
            
            # Save configuration
            self._save_integration_config()
            
            self.logger.info("AI Integration System shutdown complete")
            
        except Exception as e:
            self.logger.error(f"Error during integration system shutdown: {e}")