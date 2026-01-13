# """
# AI Provider Manager UI for NoodleCore Desktop IDE
# 
# This module provides a native GUI for managing AI providers,
# dropdown selection, API key configuration, and model selection.
# """

import typing
import dataclasses
import enum
import logging
import time
import json
import threading
import asyncio
from pathlib import Path

from ...desktop import GUIError
from ..core.events.event_system import EventSystem, EventType, MouseEvent, KeyboardEvent
from ..core.rendering.rendering_engine import RenderingEngine, Color, Font, Rectangle, Point
from ..core.components.component_library import ComponentLibrary

from .ai_providers import (
    AIProviderType, AIProviderManager, AIProviderConfig,
    AIModel, AIProviderError, AIProviderConfigError
)


@dataclasses.dataclass
class ProviderUIState:
    """UI state for provider management."""
    selected_provider: typing.Optional[AIProviderType] = None
    selected_model: typing.Optional[str] = None
    api_key: str = ""
    base_url: str = ""
    is_configured: bool = False
    models_loaded: bool = False
    connection_status: str = "disconnected"


@dataclasses.dataclass
class ProviderSelection:
    """Provider selection information."""
    provider_type: AIProviderType
    model_id: str
    display_name: str


class AIProviderManagerUIError(GUIError):
    """Exception raised for AI provider manager UI operations."""
    
    def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
        super().__init__(message, "9101", details)


class AIProviderManagerUI:
    """
    AI Provider Manager UI for NoodleCore IDE.
    
    Provides native GUI for managing AI providers with dropdown selection,
    API key configuration, model selection, and connection testing.
    """
    
    def __init__(self):
        """Initialize AI Provider Manager UI."""
        self.logger = logging.getLogger(__name__)
        
        # Core GUI systems
        self._event_system = None
        self._rendering_engine = None
        self._component_library = None
        
        # Window and component references
        self._window_id = None
        self._main_panel_component_id = None
        self._provider_dropdown_id = None
        self._model_dropdown_id = None
        self._api_key_input_id = None
        self._base_url_input_id = None
        self._test_connection_button_id = None
        self._save_config_button_id = None
        self._status_label_id = None
        
        # AI Provider Manager
        self._ai_provider_manager = AIProviderManager()
        
        # UI State
        self._ui_state = ProviderUIState()
        self._available_providers: typing.List[AIProviderType] = []
        self._available_models: typing.Dict[AIProviderType, typing.List[AIModel]] = {}
        
        # Callbacks
        self._on_provider_changed: typing.Callable = None
        self._on_model_changed: typing.Callable = None
        self._on_config_saved: typing.Callable = None
        self._on_connection_tested: typing.Callable = None
        
        # Configuration file path
        self._config_path = Path.home() / ".noodlecore" / "ai_provider_ui.json"
        
        # Lock for thread safety
        self._lock = threading.Lock()
    
    def initialize(self, window_id: str, event_system: EventSystem,
                   rendering_engine: RenderingEngine, component_library: ComponentLibrary):
        """
        Initialize the AI Provider Manager UI.
        
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
            
            # Load configuration
            self._load_ui_configuration()
            
            # Register event handlers
            self._register_event_handlers()
            
            # Load initial data
            self._load_initial_data()
            
            self.logger.info("AI Provider Manager UI initialized")
            
        except Exception as e:
            self.logger.error(f"Failed to initialize AI Provider Manager UI: {str(e)}")
            raise AIProviderManagerUIError(f"UI initialization failed: {str(e)}")
    
    def _create_ui_components(self):
        """Create the AI provider manager UI components."""
        try:
            # Create main panel
            self._main_panel_component_id = self._component_library.create_component(
                component_type="panel",
                window_id=self._window_id,
                title="AI Provider Management",
                x=20,
                y=20,
                width=400,
                height=350,
                show_border=True
            )
            
            # Provider dropdown
            self._provider_dropdown_id = self._component_library.create_component(
                component_type="dropdown",
                window_id=self._window_id,
                title="AI Provider:",
                x=30,
                y=60,
                width=200,
                height=25,
                options=[]  # Will be populated later
            )
            
            # Model dropdown
            self._model_dropdown_id = self._component_library.create_component(
                component_type="dropdown",
                window_id=self._window_id,
                title="Model:",
                x=30,
                y=100,
                width=200,
                height=25,
                options=["Select a provider first"]
            )
            
            # API Key input
            self._api_key_input_id = self._component_library.create_component(
                component_type="text_input",
                window_id=self._window_id,
                title="API Key:",
                x=30,
                y=140,
                width=250,
                height=25,
                is_password=True
            )
            
            # Base URL input
            self._base_url_input_id = self._component_library.create_component(
                component_type="text_input",
                window_id=self._window_id,
                title="Base URL:",
                x=30,
                y=180,
                width=250,
                height=25
            )
            
            # Test Connection button
            self._test_connection_button_id = self._component_library.create_component(
                component_type="button",
                window_id=self._window_id,
                title="Test Connection",
                x=30,
                y=220,
                width=120,
                height=30
            )
            
            # Save Configuration button
            self._save_config_button_id = self._component_library.create_component(
                component_type="button",
                window_id=self._window_id,
                title="Save Configuration",
                x=160,
                y=220,
                width=120,
                height=30
            )
            
            # Status label
            self._status_label_id = self._component_library.create_component(
                component_type="label",
                window_id=self._window_id,
                title="Status: Not configured",
                x=30,
                y=260,
                width=250,
                height=20
            )
            
            # Help text
            help_label_id = self._component_library.create_component(
                component_type="label",
                window_id=self._window_id,
                title="Configure your AI provider and click Test Connection",
                x=30,
                y=290,
                width=300,
                height=20
            )
            
            self.logger.info("AI Provider Manager UI components created")
            
        except Exception as e:
            self.logger.error(f"Failed to create UI components: {str(e)}")
            raise AIProviderManagerUIError(f"UI component creation failed: {str(e)}")
    
    def _register_event_handlers(self):
        """Register event handlers for UI interactions."""
        try:
            # Provider dropdown selection
            self._event_system.register_handler(
                EventType.MOUSE_CLICK,
                self._handle_provider_selection,
                window_id=self._window_id,
                component_id=self._provider_dropdown_id
            )
            
            # Model dropdown selection
            self._event_system.register_handler(
                EventType.MOUSE_CLICK,
                self._handle_model_selection,
                window_id=self._window_id,
                component_id=self._model_dropdown_id
            )
            
            # Test Connection button
            self._event_system.register_handler(
                EventType.MOUSE_CLICK,
                self._handle_test_connection,
                window_id=self._window_id,
                component_id=self._test_connection_button_id
            )
            
            # Save Configuration button
            self._event_system.register_handler(
                EventType.MOUSE_CLICK,
                self._handle_save_configuration,
                window_id=self._window_id,
                component_id=self._save_config_button_id
            )
            
            # API Key input changes
            self._event_system.register_handler(
                EventType.KEY_PRESS,
                self._handle_api_key_change,
                window_id=self._window_id,
                component_id=self._api_key_input_id
            )
            
            # Base URL input changes
            self._event_system.register_handler(
                EventType.KEY_PRESS,
                self._handle_base_url_change,
                window_id=self._window_id,
                component_id=self._base_url_input_id
            )
            
        except Exception as e:
            self.logger.error(f"Failed to register event handlers: {str(e)}")
            raise AIProviderManagerUIError(f"Event handler registration failed: {str(e)}")
    
    def _load_initial_data(self):
        """Load initial data and populate UI."""
        try:
            # Get available providers
            self._available_providers = self._ai_provider_manager.get_available_providers()
            
            # Update provider dropdown
            provider_options = []
            for provider_type in self._available_providers:
                display_name = self._get_provider_display_name(provider_type)
                provider_options.append(display_name)
            
            self._component_library.update_component_options(
                self._provider_dropdown_id,
                provider_options
            )
            
            # Load current provider selection
            current_provider, current_model = self._ai_provider_manager.get_current_provider()
            if current_provider:
                self._set_selected_provider(current_provider)
                if current_model:
                    self._set_selected_model(current_model)
            
            self.logger.info("Initial data loaded")
            
        except Exception as e:
            self.logger.error(f"Failed to load initial data: {str(e)}")
    
    def _load_ui_configuration(self):
        """Load UI configuration from file."""
        try:
            if self._config_path.exists():
                with open(self._config_path, 'r') as f:
                    config_data = json.load(f)
                
                # Load UI state
                if "ui_state" in config_data:
                    ui_state_data = config_data["ui_state"]
                    self._ui_state.selected_provider = AIProviderType(ui_state_data.get("selected_provider"))
                    self._ui_state.selected_model = ui_state_data.get("selected_model")
                    self._ui_state.api_key = ui_state_data.get("api_key", "")
                    self._ui_state.base_url = ui_state_data.get("base_url", "")
                
                self.logger.info("UI configuration loaded")
            
        except Exception as e:
            self.logger.warning(f"Failed to load UI configuration: {e}")
    
    def _save_ui_configuration(self):
        """Save UI configuration to file."""
        try:
            config_data = {
                "ui_state": {
                    "selected_provider": self._ui_state.selected_provider.value if self._ui_state.selected_provider else None,
                    "selected_model": self._ui_state.selected_model,
                    "api_key": self._ui_state.api_key,
                    "base_url": self._ui_state.base_url
                }
            }
            
            # Ensure directory exists
            self._config_path.parent.mkdir(exist_ok=True)
            
            with open(self._config_path, 'w') as f:
                json.dump(config_data, f, indent=2)
            
            self.logger.info("UI configuration saved")
            
        except Exception as e:
            self.logger.error(f"Failed to save UI configuration: {e}")
    
    def _get_provider_display_name(self, provider_type: AIProviderType) -> str:
        """Get display name for provider type."""
        provider_names = {
            AIProviderType.OPENROUTER: "OpenRouter",
            AIProviderType.OLLAMA: "Ollama (Local)",
            AIProviderType.OPENAI: "OpenAI",
            AIProviderType.Z_AI: "Z.ai",
            AIProviderType.LM_STUDIO: "LM Studio (Local)",
            AIProviderType.ANTHROPIC: "Anthropic",
            AIProviderType.CUSTOM: "Custom Provider"
        }
        return provider_names.get(provider_type, provider_type.value)
    
    def _get_provider_type_from_display_name(self, display_name: str) -> typing.Optional[AIProviderType]:
        """Get provider type from display name."""
        for provider_type in self._available_providers:
            if self._get_provider_display_name(provider_type) == display_name:
                return provider_type
        return None
    
    def _set_selected_provider(self, provider_type: AIProviderType):
        """Set selected provider and update UI."""
        try:
            self._ui_state.selected_provider = provider_type
            
            # Update provider dropdown selection
            display_name = self._get_provider_display_name(provider_type)
            # Note: In real implementation, would set dropdown selection
            
            # Load models for this provider
            asyncio.create_task(self._load_provider_models(provider_type))
            
            # Update form fields with provider config
            asyncio.create_task(self._load_provider_config_to_ui(provider_type))
            
            self.logger.info(f"Selected provider: {provider_type}")
            
        except Exception as e:
            self.logger.error(f"Failed to set selected provider: {e}")
    
    def _set_selected_model(self, model_id: str):
        """Set selected model and update UI."""
        try:
            self._ui_state.selected_model = model_id
            
            # Update model dropdown selection
            # Note: In real implementation, would set dropdown selection
            
            self.logger.info(f"Selected model: {model_id}")
            
        except Exception as e:
            self.logger.error(f"Failed to set selected model: {e}")
    
    async def _load_provider_models(self, provider_type: AIProviderType):
        """Load models for a provider."""
        try:
            models = self._ai_provider_manager.get_provider_models(provider_type)
            self._available_models[provider_type] = models
            
            # Update model dropdown
            model_options = [model.name for model in models] if models else ["No models available"]
            
            # Update UI on main thread
            threading.Thread(
                target=lambda: self._component_library.update_component_options(
                    self._model_dropdown_id,
                    model_options
                ),
                daemon=True
            ).start()
            
            self.logger.info(f"Loaded {len(models)} models for {provider_type}")
            
        except Exception as e:
            self.logger.error(f"Failed to load models for {provider_type}: {e}")
    
    async def _load_provider_config_to_ui(self, provider_type: AIProviderType):
        """Load provider configuration to UI form."""
        try:
            # This would load from the AI provider manager
            # For now, just update the base URL field with defaults
            
            default_urls = {
                AIProviderType.OPENROUTER: "https://openrouter.ai/api/v1",
                AIProviderType.OLLAMA: "http://localhost:11434",
                AIProviderType.OPENAI: "https://api.openai.com/v1",
                AIProviderType.Z_AI: "https://api.z.ai/v1",
                AIProviderType.LM_STUDIO: "http://localhost:1234"
            }
            
            default_url = default_urls.get(provider_type, "")
            
            # Update UI on main thread
            threading.Thread(
                target=lambda: self._component_library.set_component_text(
                    self._base_url_input_id,
                    default_url
                ),
                daemon=True
            ).start()
            
        except Exception as e:
            self.logger.error(f"Failed to load provider config to UI: {e}")
    
    def _handle_provider_selection(self, event: MouseEvent):
        """Handle provider dropdown selection."""
        try:
            # Get selected provider from dropdown
            # In real implementation, would get selected index and map to provider type
            
            # For now, just log the event
            self.logger.debug(f"Provider selection event at ({event.x}, {event.y})")
            
            # TODO: Implement actual dropdown selection handling
            
        except Exception as e:
            self.logger.error(f"Error handling provider selection: {e}")
    
    def _handle_model_selection(self, event: MouseEvent):
        """Handle model dropdown selection."""
        try:
            # Get selected model from dropdown
            # In real implementation, would get selected model
            
            self.logger.debug(f"Model selection event at ({event.x}, {event.y})")
            
            # TODO: Implement actual dropdown selection handling
            
        except Exception as e:
            self.logger.error(f"Error handling model selection: {e}")
    
    def _handle_api_key_change(self, event: KeyboardEvent):
        """Handle API key input changes."""
        try:
            # Update API key in state
            # In real implementation, would get text from input component
            
            self._ui_state.api_key = "dummy_api_key"  # Placeholder
            
            self.logger.debug("API key changed")
            
        except Exception as e:
            self.logger.error(f"Error handling API key change: {e}")
    
    def _handle_base_url_change(self, event: KeyboardEvent):
        """Handle base URL input changes."""
        try:
            # Update base URL in state
            # In real implementation, would get text from input component
            
            self._ui_state.base_url = "dummy_base_url"  # Placeholder
            
            self.logger.debug("Base URL changed")
            
        except Exception as e:
            self.logger.error(f"Error handling base URL change: {e}")
    
    def _handle_test_connection(self, event: MouseEvent):
        """Handle test connection button click."""
        try:
            asyncio.create_task(self._test_provider_connection())
            
        except Exception as e:
            self.logger.error(f"Error handling test connection: {e}")
    
    def _handle_save_configuration(self, event: MouseEvent):
        """Handle save configuration button click."""
        try:
            asyncio.create_task(self._save_provider_configuration())
            
        except Exception as e:
            self.logger.error(f"Error handling save configuration: {e}")
    
    async def _test_provider_connection(self):
        """Test connection to current provider."""
        try:
            self._update_status("Testing connection...", "warning")
            
            if not self._ui_state.selected_provider:
                self._update_status("No provider selected", "error")
                return
            
            # Create test request
            from .ai_providers import AIRequest
            test_request = AIRequest(
                provider_type=self._ui_state.selected_provider,
                model="test",
                prompt="Hello",
                max_tokens=10
            )
            
            # Send test request
            response = await self._ai_provider_manager.send_request(test_request)
            
            if response.success:
                self._update_status("Connection successful!", "success")
                self._ui_state.is_configured = True
            else:
                self._update_status(f"Connection failed: {response.error}", "error")
                self._ui_state.is_configured = False
            
            # Notify callback
            if self._on_connection_tested:
                self._on_connection_tested(response.success, response.error)
            
        except Exception as e:
            self.logger.error(f"Error testing connection: {e}")
            self._update_status(f"Test failed: {str(e)}", "error")
    
    async def _save_provider_configuration(self):
        """Save current provider configuration."""
        try:
            if not self._ui_state.selected_provider:
                self._update_status("No provider selected", "error")
                return
            
            # Validate configuration
            if not self._ui_state.api_key:
                self._update_status("API key required", "error")
                return
            
            # Save configuration to AI provider manager
            self._ai_provider_manager.set_provider_config(
                provider_type=self._ui_state.selected_provider,
                api_key=self._ui_state.api_key,
                base_url=self._ui_state.base_url,
                default_model=self._ui_state.selected_model
            )
            
            # Set as current provider
            self._ai_provider_manager.set_current_provider(
                provider_type=self._ui_state.selected_provider,
                model=self._ui_state.selected_model
            )
            
            # Save UI configuration
            self._save_ui_configuration()
            
            self._update_status("Configuration saved!", "success")
            
            # Notify callback
            if self._on_config_saved:
                self._on_config_saved(self._ui_state.selected_provider, self._ui_state.selected_model)
            
        except AIProviderConfigError as e:
            self.logger.error(f"Configuration error: {e}")
            self._update_status(f"Configuration error: {str(e)}", "error")
        except Exception as e:
            self.logger.error(f"Error saving configuration: {e}")
            self._update_status(f"Save failed: {str(e)}", "error")
    
    def _update_status(self, message: str, status_type: str = "info"):
        """Update status label."""
        try:
            # Determine color based on status type
            colors = {
                "info": Color(0.8, 0.8, 0.8, 1.0),
                "success": Color(0.2, 0.8, 0.2, 1.0),
                "warning": Color(0.8, 0.8, 0.2, 1.0),
                "error": Color(0.8, 0.2, 0.2, 1.0)
            }
            
            color = colors.get(status_type, colors["info"])
            
            # Update status label
            # In real implementation, would set label text and color
            self.logger.info(f"Status: {message}")
            
        except Exception as e:
            self.logger.error(f"Error updating status: {e}")
    
    # Public API
    
    def set_provider_changed_callback(self, callback: typing.Callable[[AIProviderType], None]):
        """Set callback for when provider changes."""
        self._on_provider_changed = callback
    
    def set_model_changed_callback(self, callback: typing.Callable[[str], None]):
        """Set callback for when model changes."""
        self._on_model_changed = callback
    
    def set_config_saved_callback(self, callback: typing.Callable[[AIProviderType, str], None]):
        """Set callback for when configuration is saved."""
        self._on_config_saved = callback
    
    def set_connection_tested_callback(self, callback: typing.Callable[[bool, str], None]):
        """Set callback for when connection is tested."""
        self._on_connection_tested = callback
    
    def get_current_provider(self) -> typing.Tuple[typing.Optional[AIProviderType], typing.Optional[str]]:
        """Get current provider and model selection."""
        return self._ui_state.selected_provider, self._ui_state.selected_model
    
    async def shutdown(self):
        """Shutdown AI Provider Manager UI."""
        try:
            await self._ai_provider_manager.shutdown()
            self._save_ui_configuration()
            self.logger.info("AI Provider Manager UI shutdown complete")
            
        except Exception as e:
            self.logger.error(f"Error during UI shutdown: {e}")