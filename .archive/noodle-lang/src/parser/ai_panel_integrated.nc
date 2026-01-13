# """
# Enhanced AI Panel with Real Provider Integration for NoodleCore Desktop IDE
# 
# This module replaces the mock AI panel with real AI provider integration
# for code completion, error detection, and analysis.
# """

import typing
import dataclasses
import enum
import logging
import time
import json
import asyncio
from pathlib import Path

from ...desktop import GUIError
from ..core.events.event_system import EventSystem, EventType, MouseEvent, KeyboardEvent
from ..core.rendering.rendering_engine import RenderingEngine, Color, Font, Rectangle, Point
from ..core.components.component_library import ComponentLibrary

from .ai_providers import (
    AIProviderType, AIProviderManager, AIRequest, AIResponse,
    AIProviderError, AIProviderConfigError
)
from .ai_chat_interface import ChatMessage, MessageRole, AIRole


class AnalysisType(enum.Enum):
    """AI analysis types."""
    SYNTAX_ANALYSIS = "syntax_analysis"
    CODE_OPTIMIZATION = "code_optimization"
    SECURITY_SCAN = "security_scan"
    PERFORMANCE_ANALYSIS = "performance_analysis"
    REFACTORING_SUGGESTIONS = "refactoring_suggestions"
    DOCUMENTATION_GENERATION = "documentation_generation"
    LEARNING_ANALYSIS = "learning_analysis"
    ERROR_DETECTION = "error_detection"
    TYPE_CHECKING = "type_checking"
    DEPENDENCY_ANALYSIS = "dependency_analysis"


@dataclasses.dataclass
class LearningProgress:
    """AI learning progress information."""
    current_phase: str = "ready"
    total_phases: int = 5
    completed_phases: int = 0
    progress_percentage: float = 0.0
    learning_rate: float = 0.0
    knowledge_base_size: float = 0.0
    performance_score: float = 0.0
    time_elapsed: float = 0.0
    estimated_completion: float = 0.0


@dataclasses.dataclass
class AIAnalysisResult:
    """AI analysis result with real provider data."""
    analysis_id: str
    analysis_type: AnalysisType
    file_path: str
    timestamp: float
    duration: float
    confidence_score: float
    provider: AIProviderType
    model: str
    issues_found: typing.List[typing.Dict[str, typing.Any]] = None
    suggestions: typing.List[typing.Dict[str, typing.Any]] = None
    code_metrics: typing.Dict[str, float] = None
    learning_insights: typing.Dict[str, typing.Any] = None
    tokens_used: int = 0
    cost: float = 0.0
    
    def __post_init__(self):
        if self.issues_found is None:
            self.issues_found = []
        if self.suggestions is None:
            self.suggestions = []
        if self.code_metrics is None:
            self.code_metrics = {}
        if self.learning_insights is None:
            self.learning_insights = {}


@dataclasses.dataclass
class AISuggestion:
    """AI-powered suggestion with real provider data."""
    suggestion_id: str
    type: str
    title: str
    description: str
    confidence: float
    priority: int  # 1-5, with 1 being highest
    code_change: typing.Dict[str, typing.Any] = None
    impact_score: float = 0.0
    is_accepted: bool = False
    timestamp: float = None
    provider: AIProviderType = None
    model: str = None
    original_code: str = ""
    suggested_code: str = ""
    
    def __post_init__(self):
        if self.code_change is None:
            self.code_change = {}
        if self.timestamp is None:
            self.timestamp = time.time()


@dataclasses.dataclass
class AIInsight:
    """AI-generated insight with real provider data."""
    insight_id: str
    title: str
    description: str
    category: str
    importance: float  # 0.0-1.0
    data_points: typing.List[typing.Dict[str, typing.Any]] = None
    generated_at: float = None
    provider: AIProviderType = None
    model: str = None
    confidence: float = 0.0
    
    def __post_init__(self):
        if self.data_points is None:
            self.data_points = []
        if self.generated_at is None:
            self.generated_at = time.time()


@dataclasses.dataclass
class AIStatus:
    """AI system status information with real provider data."""
    is_analyzing: bool = False
    is_learning: bool = False
    current_task: str = "Ready"
    completed_analyses: int = 0
    active_suggestions: int = 0
    learning_sessions: int = 0
    knowledge_base_version: str = "1.0"
    current_provider: typing.Optional[AIProviderType] = None
    current_model: typing.Optional[str] = None
    connection_status: str = "disconnected"
    performance_metrics: typing.Dict[str, float] = None
    
    def __post_init__(self):
        if self.performance_metrics is None:
            self.performance_metrics = {}


class EnhancedAIPanelError(GUIError):
    """Exception raised for enhanced AI panel operations."""
    
    def __init__(self, message: str, details: typing.Dict[str, typing.Any] = None):
        super().__init__(message, "9301", details)


class EnhancedAIPanel:
    """
    Enhanced AI Panel with Real Provider Integration.
    
    This panel replaces the mock AI implementation with real AI providers
    for actual code analysis, completion, and error detection.
    """
    
    def __init__(self):
        """Initialize Enhanced AI Panel."""
        self.logger = logging.getLogger(__name__)
        
        # Core GUI systems
        self._event_system = None
        self._rendering_engine = None
        self._component_library = None
        
        # Window and component references
        self._window_id = None
        self._main_panel_component_id = None
        self._tabs_component_id = None
        self._analysis_tab_component_id = None
        self._learning_tab_component_id = None
        self._suggestions_tab_component_id = None
        self._insights_tab_component_id = None
        self._provider_status_label_id = None
        
        # AI Provider Manager
        self._ai_provider_manager = AIProviderManager()
        
        # AI data with real integration
        self._current_analysis: typing.Optional[AIAnalysisResult] = None
        self._analysis_history: typing.List[AIAnalysisResult] = []
        self._active_suggestions: typing.List[AISuggestion] = []
        self._learning_progress: typing.Optional[LearningProgress] = None
        self._ai_insights: typing.List[AIInsight] = []
        
        # Real AI status
        self._ai_status = AIStatus(
            is_analyzing=False,
            is_learning=False,
            current_task="Ready",
            completed_analyses=0,
            active_suggestions=0,
            learning_sessions=0,
            knowledge_base_version="1.0"
        )
        
        # Configuration
        self._auto_analyze_enabled = True
        self._real_time_suggestions = True
        self._learning_enabled = True
        self._analysis_interval = 30  # seconds
        
        # Metrics
        self._metrics = {
            "analyses_performed": 0,
            "suggestions_generated": 0,
            "suggestions_accepted": 0,
            "learning_sessions": 0,
            "insights_generated": 0,
            "files_analyzed": 0,
            "tokens_used": 0,
            "total_cost": 0.0
        }
        
        # Code context for analysis
        self._current_code_context = ""
        self._current_file_path = ""
    
    def initialize(self, window_id: str, event_system: EventSystem,
                   rendering_engine: RenderingEngine, component_library: ComponentLibrary):
        """
        Initialize the Enhanced AI Panel.
        
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
            
            # Create panel components
            self._create_panel_structure()
            
            # Register event handlers
            self._register_event_handlers()
            
            # Start AI systems
            self._initialize_ai_systems()
            
            self.logger.info("Enhanced AI panel initialized")
            
        except Exception as e:
            self.logger.error(f"Failed to initialize Enhanced AI panel: {str(e)}")
            raise EnhancedAIPanelError(f"Enhanced panel initialization failed: {str(e)}")
    
    def _create_panel_structure(self):
        """Create the enhanced AI panel structure with tabs."""
        try:
            # Create main panel
            self._main_panel_component_id = self._component_library.create_component(
                component_type="panel",
                window_id=self._window_id,
                title="Enhanced AI Panel",
                x=0,
                y=0,
                width=300,
                height=500,
                show_border=True
            )
            
            # Provider status indicator
            self._provider_status_label_id = self._component_library.create_component(
                component_type="label",
                window_id=self._window_id,
                title="Provider: Not connected",
                x=10,
                y=25,
                width=280,
                height=20
            )
            
            # Create tab control
            self._tabs_component_id = self._component_library.create_component(
                component_type="tab_control",
                window_id=self._window_id,
                tabs=["Analysis", "Suggestions", "Learning", "Insights"],
                x=10,
                y=50,
                width=280,
                height=440,
                show_icons=True
            )
            
            # Create tab content areas
            self._create_analysis_tab()
            self._create_suggestions_tab()
            self._create_learning_tab()
            self._create_insights_tab()
            
            self.logger.info("Enhanced AI panel structure created")
            
        except Exception as e:
            self.logger.error(f"Failed to create panel structure: {str(e)}")
            raise EnhancedAIPanelError(f"Panel structure creation failed: {str(e)}")
    
    def _create_analysis_tab(self):
        """Create analysis tab content."""
        try:
            # Analysis status
            status_label_id = self._component_library.create_component(
                component_type="label",
                window_id=self._window_id,
                title="Analysis Status: Ready",
                x=20,
                y=80,
                width=200,
                height=20
            )
            
            # Analysis results area
            results_area_id = self._component_library.create_component(
                component_type="text_area",
                window_id=self._window_id,
                title="",
                x=20,
                y=110,
                width=260,
                height=200,
                readonly=True,
                scrollable=True
            )
            
            # Analysis controls
            analyze_button_id = self._component_library.create_component(
                component_type="button",
                window_id=self._window_id,
                title="Analyze Code",
                x=20,
                y=320,
                width=80,
                height=25
            )
            
            # Analysis type checkboxes would go here in real implementation
            
        except Exception as e:
            self.logger.error(f"Failed to create analysis tab: {e}")
    
    def _create_suggestions_tab(self):
        """Create suggestions tab content."""
        try:
            # Suggestions list
            suggestions_list_id = self._component_library.create_component(
                component_type="list",
                window_id=self._window_id,
                title="Active Suggestions",
                x=20,
                y=80,
                width=260,
                height=150,
                multi_select=False
            )
            
            # Suggestion details
            suggestion_details_id = self._component_library.create_component(
                component_type="text_area",
                window_id=self._window_id,
                title="",
                x=20,
                y=240,
                width=260,
                height=80,
                readonly=True
            )
            
            # Action buttons
            accept_button_id = self._component_library.create_component(
                component_type="button",
                window_id=self._window_id,
                title="Accept",
                x=20,
                y=330,
                width=60,
                height=25
            )
            
            reject_button_id = self._component_library.create_component(
                component_type="button",
                window_id=self._window_id,
                title="Reject",
                x=90,
                y=330,
                width=60,
                height=25
            )
            
            refresh_button_id = self._component_library.create_component(
                component_type="button",
                window_id=self._window_id,
                title="Refresh",
                x=160,
                y=330,
                width=60,
                height=25
            )
            
        except Exception as e:
            self.logger.error(f"Failed to create suggestions tab: {e}")
    
    def _create_learning_tab(self):
        """Create learning tab content."""
        try:
            # Learning progress
            progress_label_id = self._component_library.create_component(
                component_type="label",
                window_id=self._window_id,
                title="Learning Progress: Not active",
                x=20,
                y=80,
                width=200,
                height=20
            )
            
            # Learning metrics
            metrics_area_id = self._component_library.create_component(
                component_type="text_area",
                window_id=self._window_id,
                title="Learning metrics will appear here",
                x=20,
                y=110,
                width=260,
                height=150,
                readonly=True
            )
            
            # Learning controls
            start_learning_button_id = self._component_library.create_component(
                component_type="button",
                window_id=self._window_id,
                title="Start Learning",
                x=20,
                y=270,
                width=80,
                height=25
            )
            
            stop_learning_button_id = self._component_library.create_component(
                component_type="button",
                window_id=self._window_id,
                title="Stop Learning",
                x=110,
                y=270,
                width=80,
                height=25
            )
            
        except Exception as e:
            self.logger.error(f"Failed to create learning tab: {e}")
    
    def _create_insights_tab(self):
        """Create insights tab content."""
        try:
            # Insights list
            insights_list_id = self._component_library.create_component(
                component_type="list",
                window_id=self._window_id,
                title="AI Insights",
                x=20,
                y=80,
                width=260,
                height=150,
                multi_select=False
            )
            
            # Insight details
            insight_details_id = self._component_library.create_component(
                component_type="text_area",
                window_id=self._window_id,
                title="",
                x=20,
                y=240,
                width=260,
                height=100,
                readonly=True
            )
            
            # Export insights button
            export_button_id = self._component_library.create_component(
                component_type="button",
                window_id=self._window_id,
                title="Export",
                x=20,
                y=350,
                width=60,
                height=25
            )
            
        except Exception as e:
            self.logger.error(f"Failed to create insights tab: {e}")
    
    def _register_event_handlers(self):
        """Register event handlers."""
        try:
            # Tab switching
            self._event_system.register_handler(
                EventType.MOUSE_CLICK,
                self._handle_tab_click,
                window_id=self._window_id
            )
            
            # Suggestion actions
            self._event_system.register_handler(
                EventType.MOUSE_CLICK,
                self._handle_suggestion_action,
                window_id=self._window_id
            )
            
        except Exception as e:
            self.logger.error(f"Failed to register event handlers: {str(e)}")
    
    def _initialize_ai_systems(self):
        """Initialize AI systems and start background processes."""
        try:
            # Update provider status
            self._update_provider_status()
            
            # Start analysis simulation with real AI
            self._start_real_ai_operations()
            
        except Exception as e:
            self.logger.error(f"Failed to initialize AI systems: {str(e)}")
            raise EnhancedAIPanelError(f"AI systems initialization failed: {str(e)}")
    
    def _update_provider_status(self):
        """Update provider status display."""
        try:
            current_provider, current_model = self._ai_provider_manager.get_current_provider()
            
            if current_provider:
                status_text = f"Provider: {current_provider.value} ({current_model})"
                status_color = Color(0.2, 0.8, 0.2, 1.0)  # Green
                self._ai_status.current_provider = current_provider
                self._ai_status.current_model = current_model
                self._ai_status.connection_status = "connected"
            else:
                status_text = "Provider: Not configured"
                status_color = Color(0.8, 0.2, 0.2, 1.0)  # Red
                self._ai_status.connection_status = "disconnected"
            
            # Update status label
            self.logger.info(status_text)
            
        except Exception as e:
            self.logger.error(f"Failed to update provider status: {e}")
    
    def analyze_code(self, file_path: str, code_content: str = None, analysis_types: typing.List[AnalysisType] = None) -> bool:
        """
        Perform real AI analysis on code.
        
        Args:
            file_path: Path to file to analyze
            code_content: Code content to analyze (optional)
            analysis_types: Types of analysis to perform
            
        Returns:
            True if successful
        """
        try:
            if not self._ai_status.current_provider:
                self.logger.warning("No AI provider configured")
                return False
            
            if analysis_types is None:
                analysis_types = [AnalysisType.SYNTAX_ANALYSIS, AnalysisType.ERROR_DETECTION]
            
            # Set analysis status
            self._ai_status.is_analyzing = True
            self._ai_status.current_task = f"Analyzing {file_path}"
            
            # Get code content if not provided
            if code_content is None:
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        code_content = f.read()
                except Exception as e:
                    self.logger.error(f"Failed to read file {file_path}: {e}")
                    return False
            
            # Store current context
            self._current_code_context = code_content
            self._current_file_path = file_path
            
            # Perform real AI analysis
            asyncio.create_task(self._perform_real_ai_analysis(file_path, code_content, analysis_types))
            
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to analyze code {file_path}: {e}")
            self._ai_status.is_analyzing = False
            return False
    
    async def _perform_real_ai_analysis(self, file_path: str, code_content: str, analysis_types: typing.List[AnalysisType]):
        """Perform real AI analysis using provider."""
        try:
            # Build analysis prompt
            analysis_prompt = self._build_analysis_prompt(code_content, analysis_types)
            
            # Create AI request
            request = AIRequest(
                provider_type=self._ai_status.current_provider,
                model=self._ai_status.current_model,
                prompt=analysis_prompt,
                max_tokens=1000,
                temperature=0.3
            )
            
            # Send request
            response = await self._ai_provider_manager.send_request(request)
            
            # Create analysis result
            analysis_result = AIAnalysisResult(
                analysis_id=str(uuid.uuid4()),
                analysis_type=analysis_types[0] if analysis_types else AnalysisType.SYNTAX_ANALYSIS,
                file_path=file_path,
                timestamp=time.time(),
                duration=time.time() - time.time(),  # Would calculate actual duration
                confidence_score=0.85,
                provider=self._ai_status.current_provider,
                model=self._ai_status.current_model
            )
            
            # Parse AI response
            if response.success:
                self._parse_analysis_response(response.content, analysis_result)
                analysis_result.confidence_score = 0.9
            else:
                analysis_result.issues_found.append({
                    "type": "analysis_error",
                    "message": f"Analysis failed: {response.error}",
                    "severity": "error",
                    "line": 0,
                    "column": 0
                })
                analysis_result.confidence_score = 0.0
            
            # Store result
            self._current_analysis = analysis_result
            self._analysis_history.append(analysis_result)
            
            # Update status
            self._ai_status.is_analyzing = False
            self._ai_status.current_task = "Ready"
            self._ai_status.completed_analyses += 1
            
            # Update metrics
            self._metrics["analyses_performed"] += 1
            self._metrics["files_analyzed"] += 1
            if response.usage:
                self._metrics["tokens_used"] += response.usage.get("total_tokens", 0)
            if response.cost:
                self._metrics["total_cost"] += response.cost
            
            # Update suggestions based on analysis
            self._update_suggestions_from_analysis(analysis_result)
            
            self.logger.info(f"Completed real AI analysis for {file_path}")
            
        except Exception as e:
            self.logger.error(f"Failed to perform real AI analysis: {e}")
            self._ai_status.is_analyzing = False
            self._ai_status.current_task = "Analysis failed"
    
    def _build_analysis_prompt(self, code_content: str, analysis_types: typing.List[AnalysisType]) -> str:
        """Build analysis prompt for AI provider."""
        try:
            # Get analysis type descriptions
            type_descriptions = {
                AnalysisType.SYNTAX_ANALYSIS: "syntax errors, parsing issues, and code structure",
                AnalysisType.ERROR_DETECTION: "runtime errors, logic errors, and potential bugs",
                AnalysisType.SECURITY_SCAN: "security vulnerabilities and unsafe practices",
                AnalysisType.PERFORMANCE_ANALYSIS: "performance issues and optimization opportunities",
                AnalysisType.CODE_OPTIMIZATION: "code quality improvements and best practices",
                AnalysisType.REFACTORING_SUGGESTIONS: "code refactoring and restructuring suggestions",
                AnalysisType.DOCUMENTATION_GENERATION: "missing documentation and docstring suggestions",
                AnalysisType.TYPE_CHECKING: "type-related issues and type hints",
                AnalysisType.DEPENDENCY_ANALYSIS: "dependency issues and imports"
            }
            
            # Build analysis request
            analysis_list = []
            for analysis_type in analysis_types:
                description = type_descriptions.get(analysis_type, str(analysis_type))
                analysis_list.append(f"- {description}")
            
            analysis_request = "\n".join(analysis_list)
            
            # Create comprehensive prompt
            prompt = f"""Please analyze the following code for the following aspects:

{analysis_request}

Code to analyze:
```{code_content}```

Please provide your analysis in JSON format with the following structure:
{{
  "issues": [
    {{
      "type": "error_type",
      "message": "detailed description",
      "severity": "error/warning/info",
      "line": line_number,
      "column": column_number,
      "suggestion": "how to fix"
    }}
  ],
  "suggestions": [
    {{
      "type": "suggestion_type",
      "title": "brief title",
      "description": "detailed description",
      "confidence": 0.95,
      "priority": 1,
      "impact": "performance/security/maintainability",
      "estimated_improvement": "description of improvement"
    }}
  ],
  "metrics": {{
    "complexity_score": 7.5,
    "maintainability_score": 8.0,
    "test_coverage_suggestion": "percentage",
    "documentation_score": 6.0
  }},
  "insights": [
    {{
      "category": "performance/security/architecture",
      "insight": "specific insight",
      "importance": 0.8
    }}
  ]
}}

Be thorough but concise. Focus on actionable recommendations."""
            
            return prompt
            
        except Exception as e:
            self.logger.error(f"Failed to build analysis prompt: {e}")
            return f"Please analyze this code for issues and improvements:\n\n{code_content}"
    
    def _parse_analysis_response(self, response_content: str, analysis_result: AIAnalysisResult):
        """Parse AI response and populate analysis result."""
        try:
            import json
            
            # Try to parse as JSON
            try:
                analysis_data = json.loads(response_content)
                
                # Parse issues
                for issue in analysis_data.get("issues", []):
                    analysis_result.issues_found.append({
                        "type": issue.get("type", "unknown"),
                        "message": issue.get("message", ""),
                        "severity": issue.get("severity", "info"),
                        "line": issue.get("line", 0),
                        "column": issue.get("column", 0),
                        "suggestion": issue.get("suggestion", "")
                    })
                
                # Parse suggestions
                for suggestion in analysis_data.get("suggestions", []):
                    analysis_result.suggestions.append({
                        "type": suggestion.get("type", "general"),
                        "title": suggestion.get("title", ""),
                        "description": suggestion.get("description", ""),
                        "confidence": suggestion.get("confidence", 0.5),
                        "priority": suggestion.get("priority", 3),
                        "impact": suggestion.get("impact", "general"),
                        "estimated_improvement": suggestion.get("estimated_improvement", "")
                    })
                
                # Parse metrics
                analysis_result.code_metrics.update(analysis_data.get("metrics", {}))
                
                # Parse insights
                for insight in analysis_data.get("insights", []):
                    ai_insight = AIInsight(
                        insight_id=str(uuid.uuid4()),
                        title=insight.get("insight", ""),
                        description=insight.get("insight", ""),
                        category=insight.get("category", "general"),
                        importance=insight.get("importance", 0.5),
                        provider=self._ai_status.current_provider,
                        model=self._ai_status.current_model,
                        confidence=analysis_result.confidence_score
                    )
                    self._ai_insights.append(ai_insight)
                
            except json.JSONDecodeError:
                # Fallback to text parsing
                self.logger.warning("Failed to parse AI response as JSON, using text parsing")
                self._parse_text_response(response_content, analysis_result)
            
        except Exception as e:
            self.logger.error(f"Failed to parse analysis response: {e}")
            analysis_result.issues_found.append({
                "type": "parse_error",
                "message": f"Failed to parse AI response: {str(e)}",
                "severity": "warning",
                "line": 0,
                "column": 0,
                "suggestion": "Check AI provider configuration"
            })
    
    def _parse_text_response(self, response_content: str, analysis_result: AIAnalysisResult):
        """Parse text response when JSON parsing fails."""
        try:
            # Simple text parsing for common patterns
            lines = response_content.split('\n')
            
            for line in lines:
                line = line.strip()
                if not line:
                    continue
                
                # Look for error indicators
                if any(keyword in line.lower() for keyword in ['error', 'error:', 'error -']):
                    analysis_result.issues_found.append({
                        "type": "text_error",
                        "message": line,
                        "severity": "error",
                        "line": 0,
                        "column": 0,
                        "suggestion": "Review AI response for details"
                    })
                
                # Look for suggestion indicators
                elif any(keyword in line.lower() for keyword in ['suggest', 'recommend', 'consider']):
                    analysis_result.suggestions.append({
                        "type": "text_suggestion",
                        "title": line[:50] + "..." if len(line) > 50 else line,
                        "description": line,
                        "confidence": 0.6,
                        "priority": 3,
                        "impact": "general",
                        "estimated_improvement": "General improvement"
                    })
            
            # Create insight from full response
            ai_insight = AIInsight(
                insight_id=str(uuid.uuid4()),
                title="AI Analysis Complete",
                description=response_content[:200] + "..." if len(response_content) > 200 else response_content,
                category="analysis",
                importance=0.7,
                provider=self._ai_status.current_provider,
                model=self._ai_status.current_model,
                confidence=analysis_result.confidence_score
            )
            self._ai_insights.append(ai_insight)
            
        except Exception as e:
            self.logger.error(f"Failed to parse text response: {e}")
    
    def _update_suggestions_from_analysis(self, analysis_result: AIAnalysisResult):
        """Update active suggestions based on analysis result."""
        try:
            # Clear existing suggestions for this file
            self._active_suggestions = [
                s for s in self._active_suggestions 
                if s.suggestion_id != analysis_result.analysis_id
            ]
            
            # Add new suggestions from analysis
            for suggestion_data in analysis_result.suggestions:
                suggestion = AISuggestion(
                    suggestion_id=str(uuid.uuid4()),
                    type=suggestion_data.get("type", "general"),
                    title=suggestion_data.get("title", ""),
                    description=suggestion_data.get("description", ""),
                    confidence=suggestion_data.get("confidence", 0.5),
                    priority=suggestion_data.get("priority", 3),
                    provider=self._ai_status.current_provider,
                    model=self._ai_status.current_model,
                    original_code=self._current_code_context
                )
                self._active_suggestions.append(suggestion)
            
            # Update metrics
            self._metrics["suggestions_generated"] += len(analysis_result.suggestions)
            self._ai_status.active_suggestions = len(self._active_suggestions)
            
        except Exception as e:
            self.logger.error(f"Failed to update suggestions: {e}")
    
    async def _start_real_ai_operations(self):
        """Start real AI operations and background processes."""
        try:
            # Update provider status
            self._update_provider_status()
            
            # If provider is configured, generate initial insights
            if self._ai_status.current_provider:
                await self._generate_initial_insights()
            
        except Exception as e:
            self.logger.error(f"Failed to start real AI operations: {e}")
    
    async def _generate_initial_insights(self):
        """Generate initial insights using AI."""
        try:
            prompt = "Provide 2-3 general insights about software development best practices and common code patterns that developers should be aware of."
            
            request = AIRequest(
                provider_type=self._ai_status.current_provider,
                model=self._ai_status.current_model,
                prompt=prompt,
                max_tokens=500,
                temperature=0.7
            )
            
            response = await self._ai_provider_manager.send_request(request)
            
            if response.success:
                # Create insight from response
                insight = AIInsight(
                    insight_id=str(uuid.uuid4()),
                    title="Development Insights",
                    description=response.content,
                    category="best-practices",
                    importance=0.6,
                    provider=self._ai_status.current_provider,
                    model=self._ai_status.current_model,
                    confidence=0.8
                )
                self._ai_insights.append(insight)
                self._metrics["insights_generated"] += 1
            
        except Exception as e:
            self.logger.error(f"Failed to generate initial insights: {e}")
    
    def get_code_suggestions(self, file_path: str, cursor_position: typing.Tuple[int, int] = None) -> typing.List[AISuggestion]:
        """Get AI-powered code suggestions using real provider."""
        try:
            if not self._ai_status.current_provider:
                return []
            
            # Use existing suggestions if available
            if self._active_suggestions:
                return [s for s in self._active_suggestions if not s.is_accepted]
            
            # Generate new suggestions if none exist
            if self._current_code_context:
                asyncio.create_task(self.analyze_code(file_path, self._current_code_context))
            
            return []
            
        except Exception as e:
            self.logger.error(f"Failed to get code suggestions: {e}")
            return []
    
    def accept_suggestion(self, suggestion_id: str) -> bool:
        """Accept an AI suggestion."""
        try:
            for suggestion in self._active_suggestions:
                if suggestion.suggestion_id == suggestion_id:
                    suggestion.is_accepted = True
                    self._metrics["suggestions_accepted"] += 1
                    self._ai_status.active_suggestions = len([s for s in self._active_suggestions if not s.is_accepted])
                    
                    # In real implementation, would apply code change
                    self.logger.info(f"Accepted suggestion: {suggestion.title}")
                    return True
            
            return False
            
        except Exception as e:
            self.logger.error(f"Failed to accept suggestion: {e}")
            return False
    
    def reject_suggestion(self, suggestion_id: str) -> bool:
        """Reject an AI suggestion."""
        try:
            for suggestion in self._active_suggestions:
                if suggestion.suggestion_id == suggestion_id:
                    self._active_suggestions.remove(suggestion)
                    self._ai_status.active_suggestions = len(self._active_suggestions)
                    self.logger.info(f"Rejected suggestion: {suggestion.title}")
                    return True
            
            return False
            
        except Exception as e:
            self.logger.error(f"Failed to reject suggestion: {e}")
            return False
    
    # Event handlers
    
    def _handle_tab_click(self, event: MouseEvent):
        """Handle tab switching."""
        try:
            self.logger.debug(f"Tab clicked at ({event.x}, {event.y})")
            # In real implementation, would handle tab selection
        except Exception as e:
            self.logger.error(f"Error handling tab click: {e}")
    
    def _handle_suggestion_action(self, event: MouseEvent):
        """Handle suggestion action clicks."""
        try:
            self.logger.debug(f"Suggestion action at ({event.x}, {event.y})")
            # In real implementation, would handle accept/reject buttons
        except Exception as e:
            self.logger.error(f"Error handling suggestion action: {e}")
    
    # Public API
    
    def set_code_context(self, code_content: str, file_path: str = ""):
        """Set current code context for analysis."""
        self._current_code_context = code_content
        self._current_file_path = file_path
    
    def get_ai_status(self) -> AIStatus:
        """Get current AI system status."""
        return self._ai_status
    
    def get_metrics(self) -> typing.Dict[str, typing.Any]:
        """Get AI panel metrics."""
        return self._metrics.copy()
    
    def get_analysis_history(self, limit: int = 10) -> typing.List[AIAnalysisResult]:
        """Get analysis history."""
        return self._analysis_history[-limit:] if self._analysis_history else []
    
    def get_insights(self, category: str = None) -> typing.List[AIInsight]:
        """Get AI insights."""
        if category:
            return [insight for insight in self._ai_insights if insight.category == category]
        return self._ai_insights.copy()
    
    def get_active_suggestions(self) -> typing.List[AISuggestion]:
        """Get active suggestions."""
        return [s for s in self._active_suggestions if not s.is_accepted]
    
    async def shutdown(self):
        """Shutdown Enhanced AI Panel."""
        try:
            await self._ai_provider_manager.shutdown()
            self.logger.info("Enhanced AI Panel shutdown complete")
            
        except Exception as e:
            self.logger.error(f"Error during panel shutdown: {e}")