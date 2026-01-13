# Self-Learning Integration UI Controls for NoodleCore IDE
# ------------------------------------------------------

import .self_improvement.trigger_system.TriggerSystem
import .self_improvement.learning_loop_integration.LearningLoopIntegration
import .runtime.error_handler.ErrorHandler
import .utils.common.CommonUtils

class SelfLearningUI:
    """
    Self-Learning Integration UI Controls for NoodleCore IDE.
    
    Provides interactive UI controls for triggering self-improvement cycles,
    monitoring learning progress, adjusting learning parameters, and visualizing
    system adaptation and optimization capabilities.
    """
    
    def __init__(self, trigger_system, learning_loop, error_handler):
        """
        Initialize Self-Learning UI Controls.
        
        Args:
            trigger_system: Self-improvement trigger system
            learning_loop: Learning loop integration system
            error_handler: Error handling system
        """
        self.trigger_system = trigger_system
        self.learning_loop = learning_loop
        self.error_handler = error_handler
        
        # Self-learning configuration
        self.learning_config = {
            'auto_learning_enabled': True,
            'learning_frequency_hours': 24,
            'learning_threshold_improvement': 0.1,
            'learning_intensity': 'medium',
            'learning_areas': [
                'code_quality',
                'performance_optimization',
                'security_enhancement',
                'user_experience',
                'system_efficiency'
            ],
            'triggers': {
                'performance_degradation': True,
                'user_feedback_negative': True,
                'error_rate_increase': True,
                'usage_pattern_changes': True,
                'manual_trigger': True
            }
        }
        
        # UI control configurations
        self.ui_config = {
            'learning_control_panel': {
                'position': 'right',
                'width': '320px',
                'height': '100%',
                'z_index': 1001,
                'collapsible': True,
                'default_expanded': False
            },
            'learning_visualization': {
                'position': 'bottom',
                'height': '300px',
                'chart_types': ['line', 'bar', 'radar', 'heatmap'],
                'auto_refresh_interval': 5000
            },
            'trigger_controls': {
                'position': 'top',
                'style': 'toggle_buttons',
                'show_confirmation': True
            },
            'learning_status': {
                'position': 'top_right',
                'style': 'status_indicator',
                'show_progress': True,
                'show_metrics': True
            }
        }
        
        # Learning state tracking
        self.learning_state = {
            'current_cycle': None,
            'cycle_history': [],
            'learning_progress': {},
            'improvement_metrics': {},
            'trigger_history': [],
            'adaptive_parameters': {},
            'learning_effectiveness': {}
        }
        
        self.initialize_learning_system()
    
    def initialize_learning_system(self):
        """Initialize self-learning system components."""
        try:
            # Setup learning loop integration
            if self.learning_loop:
                self.setup_learning_loop()
            
            # Setup trigger system
            if self.trigger_system:
                self.setup_trigger_system()
            
            # Initialize learning state
            self.initialize_learning_state()
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to initialize learning system: {str(e)}')
    
    def setup_learning_loop(self):
        """Setup learning loop integration."""
        try:
            # Configure learning parameters
            learning_params = {
                'auto_enabled': self.learning_config['auto_learning_enabled'],
                'frequency_hours': self.learning_config['learning_frequency_hours'],
                'improvement_threshold': self.learning_config['learning_threshold_improvement'],
                'learning_areas': self.learning_config['learning_areas'],
                'intensity': self.learning_config['learning_intensity']
            }
            
            # Register with learning loop system
            if hasattr(self.learning_loop, 'register_learning_system'):
                self.learning_loop.register_learning_system('IDE_UI', learning_params)
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to setup learning loop: {str(e)}')
    
    def setup_trigger_system(self):
        """Setup trigger system for self-improvement."""
        try:
            # Configure trigger parameters
            trigger_configs = {
                'performance_degradation': {
                    'threshold': 0.2,
                    'measurement_period': '1h',
                    'severity_levels': ['low', 'medium', 'high', 'critical'],
                    'auto_trigger': True
                },
                'user_feedback_negative': {
                    'threshold': 0.3,
                    'measurement_period': '24h',
                    'severity_levels': ['low', 'medium', 'high'],
                    'auto_trigger': True
                }
            }
            
            for trigger_name, config in trigger_configs.items():
                if hasattr(self.trigger_system, 'register_trigger'):
                    self.trigger_system.register_trigger(trigger_name, config)
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to setup trigger system: {str(e)}')
    
    def initialize_learning_state(self):
        """Initialize learning state tracking."""
        try:
            self.learning_state.update({
                'learning_progress': {area: 0.0 for area in self.learning_config['learning_areas']},
                'improvement_metrics': {area: {} for area in self.learning_config['learning_areas']},
                'adaptive_parameters': self._get_adaptive_parameters(),
                'learning_effectiveness': {area: 0.0 for area in self.learning_config['learning_areas']}
            })
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to initialize learning state: {str(e)}')
    
    def get_ui_configuration(self):
        """
        Get self-learning UI configuration for frontend.
        
        Returns:
            dict: UI configuration and component settings
        """
        try:
            return {
                'success': True,
                'request_id': self._generate_request_id(),
                'data': {
                    'learning_config': self.learning_config,
                    'ui_config': self.ui_config,
                    'learning_state': self.learning_state,
                    'component_definitions': self._get_component_definitions(),
                    'event_handlers': self._get_event_handlers(),
                    'api_endpoints': self._get_api_endpoints()
                }
            }
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to get UI configuration: {str(e)}')
            return self._error_response('Failed to get self-learning UI configuration', '11001')
    
    def _get_component_definitions(self):
        """Get component definitions for frontend implementation."""
        try:
            return {
                'learning_control_panel': {
                    'id': 'self-learning-panel',
                    'type': 'component',
                    'props': {
                        'position': self.ui_config['learning_control_panel']['position'],
                        'width': self.ui_config['learning_control_panel']['width'],
                        'height': self.ui_config['learning_control_panel']['height'],
                        'className': 'self-learning-panel',
                        'collapsible': self.ui_config['learning_control_panel']['collapsible']
                    },
                    'children': [
                        {
                            'id': 'learning-header',
                            'type': 'div',
                            'props': {'className': 'learning-header'},
                            'children': [
                                {
                                    'id': 'learning-title',
                                    'type': 'h3',
                                    'props': {'className': 'learning-title'},
                                    'text': 'Self-Learning System'
                                },
                                {
                                    'id': 'learning-toggle',
                                    'type': 'button',
                                    'props': {'className': 'toggle-button', 'onClick': 'toggleLearningPanel'},
                                    'text': '−'
                                }
                            ]
                        },
                        {
                            'id': 'learning-content',
                            'type': 'div',
                            'props': {'className': 'learning-content'},
                            'children': [
                                self._get_auto_learning_section(),
                                self._get_learning_areas_section()
                            ]
                        },
                        {
                            'id': 'learning-footer',
                            'type': 'div',
                            'props': {'className': 'learning-footer'},
                            'children': [
                                {
                                    'id': 'manual-trigger-btn',
                                    'type': 'button',
                                    'props': {'className': 'btn btn-primary', 'onClick': 'triggerManualLearning'},
                                    'text': 'Start Learning Cycle'
                                }
                            ]
                        }
                    ]
                },
                'learning_visualization': {
                    'id': 'learning-visualization',
                    'type': 'component',
                    'props': {
                        'position': self.ui_config['learning_visualization']['position'],
                        'height': self.ui_config['learning_visualization']['height'],
                        'autoRefreshInterval': self.ui_config['learning_visualization']['auto_refresh_interval']
                    },
                    'children': [
                        {
                            'id': 'viz-header',
                            'type': 'div',
                            'props': {'className': 'viz-header'},
                            'text': 'Learning Progress'
                        },
                        {
                            'id': 'progress-chart',
                            'type': 'canvas',
                            'props': {'id': 'learning-progress-chart', 'width': 600, 'height': 300}
                        }
                    ]
                },
                'learning_status': {
                    'id': 'learning-status-indicator',
                    'type': 'component',
                    'props': {
                        'position': self.ui_config['learning_status']['position'],
                        'style': self.ui_config['learning_status']['style'],
                        'showProgress': self.ui_config['learning_status']['show_progress'],
                        'showMetrics': self.ui_config['learning_status']['show_metrics']
                    },
                    'children': [
                        {
                            'id': 'status-dot',
                            'type': 'div',
                            'props': {'className': 'status-dot', 'id': 'learning-status-dot'}
                        },
                        {
                            'id': 'status-text',
                            'type': 'span',
                            'props': {'className': 'status-text', 'id': 'learning-status-text'},
                            'text': 'Learning Inactive'
                        }
                    ]
                }
            }
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to get component definitions: {str(e)}')
            return {}
    
    def _get_auto_learning_section(self):
        """Get auto-learning control section."""
        return {
            'id': 'auto-learning-section',
            'type': 'div',
            'props': {'className': 'control-section'},
            'children': [
                {
                    'id': 'auto-learning-title',
                    'type': 'h4',
                    'props': {'className': 'section-title'},
                    'text': 'Auto Learning'
                },
                {
                    'id': 'auto-learning-toggle',
                    'type': 'label',
                    'props': {'className': 'toggle-switch'},
                    'children': [
                        {
                            'id': 'auto-learning-checkbox',
                            'type': 'input',
                            'props': {'type': 'checkbox', 'id': 'autoLearningEnabled', 'onChange': 'toggleAutoLearning'}
                        },
                        {
                            'id': 'auto-learning-slider',
                            'type': 'span',
                            'props': {'className': 'slider'}
                        }
                    ]
                }
            ]
        }
    
    def _get_learning_areas_section(self):
        """Get learning areas control section."""
        area_controls = []
        
        for area in self.learning_config['learning_areas']:
            area_controls.append({
                'id': f'{area}-progress',
                'type': 'div',
                'props': {'className': 'area-progress'},
                'children': [
                    {
                        'id': f'{area}-label',
                        'type': 'label',
                        'props': {'className': 'area-label'},
                        'text': area.replace('_', ' ').title()
                    },
                    {
                        'id': f'{area}-progress-bar',
                        'type': 'progress',
                        'props': {'className': 'progress-bar', 'value': self.learning_state['learning_progress'].get(area, 0), 'max': 100}
                    },
                    {
                        'id': f'{area}-progress-text',
                        'type': 'span',
                        'props': {'className': 'progress-text'},
                        'text': f"{self.learning_state['learning_progress'].get(area, 0):.1f}%"
                    }
                ]
            })
        
        return {
            'id': 'learning-areas-section',
            'type': 'div',
            'props': {'className': 'control-section'},
            'children': [
                {
                    'id': 'learning-areas-title',
                    'type': 'h4',
                    'props': {'className': 'section-title'},
                    'text': 'Learning Areas'
                },
                {
                    'id': 'learning-areas-list',
                    'type': 'div',
                    'props': {'className': 'learning-areas-list'},
                    'children': area_controls
                }
            ]
        }
    
    def _get_event_handlers(self):
        """Get event handlers for self-learning integration."""
        return {
            'toggleLearningPanel': 'toggleLearningPanel',
            'toggleAutoLearning': 'toggleAutoLearning',
            'triggerManualLearning': 'triggerManualLearning',
            'resetLearningState': 'resetLearningState',
            'updateLearningFrequency': 'updateLearningFrequency',
            'updateLearningIntensity': 'updateLearningIntensity',
            'showProgressChart': 'showProgressChart',
            'onLearningProgressUpdate': 'handleLearningProgressUpdate',
            'onLearningCycleComplete': 'handleLearningCycleComplete'
        }
    
    def _get_api_endpoints(self):
        """Get API endpoints for self-learning integration."""
        return {
            'get_learning_status': '/api/v1/learning/status',
            'trigger_learning_cycle': '/api/v1/learning/trigger',
            'get_learning_progress': '/api/v1/learning/progress',
            'update_learning_config': '/api/v1/learning/config',
            'get_learning_history': '/api/v1/learning/history',
            'trigger_improvement': '/api/v1/improvement/trigger',
            'get_improvement_areas': '/api/v1/improvement/areas'
        }
    
    async def trigger_learning_cycle_ui(self, trigger_type='manual', parameters=None):
        """
        Trigger learning cycle with UI response.
        
        Args:
            trigger_type: Type of trigger (manual, automatic, performance, etc.)
            parameters: Additional parameters for learning cycle
            
        Returns:
            dict: Learning cycle trigger result
        """
        try:
            parameters = parameters or {}
            
            # Prepare learning parameters
            learning_params = {
                'trigger_type': trigger_type,
                'parameters': parameters,
                'learning_config': self.learning_config,
                'current_state': self.learning_state,
                'ui_context': {
                    'requested_by': 'ide_ui',
                    'user_interface': True,
                    'response_format': 'ui_ready'
                }
            }
            
            # Trigger learning cycle
            if self.learning_loop:
                cycle_result = await self.learning_loop.trigger_learning_cycle(learning_params)
            else:
                # Mock learning cycle result
                cycle_result = self._mock_learning_cycle_result(trigger_type)
            
            if cycle_result.get('success'):
                # Update learning state
                self._update_learning_state(cycle_result)
                
                # Create UI-ready response
                return {
                    'success': True,
                    'request_id': self._generate_request_id(),
                    'data': {
                        'cycle_id': cycle_result.get('cycle_id'),
                        'trigger_type': trigger_type,
                        'status': cycle_result.get('status', 'initiated'),
                        'estimated_completion': cycle_result.get('estimated_completion'),
                        'learning_areas': cycle_result.get('learning_areas', []),
                        'ui_updates': self._prepare_ui_updates(cycle_result),
                        'progress_tracking': {
                            'current_phase': cycle_result.get('current_phase', 'initialization'),
                            'progress_percentage': cycle_result.get('progress_percentage', 0),
                            'estimated_remaining_time': cycle_result.get('estimated_remaining_time')
                        }
                    }
                }
            else:
                return self._error_response(cycle_result.get('error', 'Learning cycle failed'), '11002')
            
        except Exception as e:
            self.error_handler.handle_error(f'Learning cycle trigger UI failed: {str(e)}')
            return self._error_response('Failed to trigger learning cycle', '11003')
    
    def _mock_learning_cycle_result(self, trigger_type):
        """Mock learning cycle result for testing."""
        return {
            'success': True,
            'cycle_id': self._generate_cycle_id(),
            'status': 'in_progress',
            'trigger_type': trigger_type,
            'learning_areas': self.learning_config['learning_areas'][:3],
            'current_phase': 'analysis',
            'progress_percentage': 25,
            'estimated_completion': self._get_timestamp() + 300000,  # 5 minutes
            'improvements_identified': [
                {
                    'area': 'code_quality',
                    'improvement_type': 'syntax_optimization',
                    'confidence': 0.85,
                    'impact_score': 0.7
                },
                {
                    'area': 'performance_optimization',
                    'improvement_type': 'algorithm_efficiency',
                    'confidence': 0.92,
                    'impact_score': 0.8
                }
            ]
        }
    
    def _update_learning_state(self, cycle_result):
        """Update learning state with new cycle results."""
        try:
            self.learning_state.update({
                'current_cycle': {
                    'cycle_id': cycle_result.get('cycle_id'),
                    'trigger_type': cycle_result.get('trigger_type'),
                    'status': cycle_result.get('status'),
                    'started_at': self._get_timestamp(),
                    'progress': cycle_result.get('progress_percentage', 0),
                    'learning_areas': cycle_result.get('learning_areas', [])
                }
            })
            
            # Add to cycle history
            self.learning_state['cycle_history'].append({
                'cycle_id': cycle_result.get('cycle_id'),
                'trigger_type': cycle_result.get('trigger_type'),
                'status': cycle_result.get('status'),
                'completed_at': self._get_timestamp(),
                'improvements_count': len(cycle_result.get('improvements_identified', []))
            })
            
            # Keep only recent cycles
            if len(self.learning_state['cycle_history']) > 100:
                self.learning_state['cycle_history'] = self.learning_state['cycle_history'][-50:]
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to update learning state: {str(e)}')
    
    def _prepare_ui_updates(self, cycle_result):
        """Prepare UI updates for learning cycle."""
        try:
            updates = {
                'status_indicator': {
                    'status': cycle_result.get('status', 'unknown'),
                    'progress': cycle_result.get('progress_percentage', 0),
                    'message': f"Learning cycle: {cycle_result.get('trigger_type', 'unknown')}"
                },
                'progress_bars': {},
                'notifications': [],
                'charts_refresh': True
            }
            
            # Update progress bars for learning areas
            for area in cycle_result.get('learning_areas', []):
                current_progress = self.learning_state['learning_progress'].get(area, 0)
                updates['progress_bars'][area] = min(100, current_progress + 10)
            
            return updates
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to prepare UI updates: {str(e)}')
            return {}
    
    def _get_adaptive_parameters(self):
        """Get adaptive learning parameters."""
        return {
            'learning_rate': 0.01,
            'exploration_rate': 0.1,
            'convergence_threshold': 0.001,
            'max_iterations': 1000,
            'momentum': 0.9
        }
    
    def _generate_cycle_id(self):
        """Generate unique learning cycle ID."""
        import uuid
        return f"learning_cycle_{uuid.uuid4().hex[:8]}"
    
    def _generate_request_id(self):
        """Generate unique request ID."""
        import uuid
        return str(uuid.uuid4())
    
    def _get_timestamp(self):
        """Get current timestamp."""
        import time
        return int(time.time() * 1000)
    
    def _error_response(self, message, error_code):
        """Create standardized error response."""
        return {
            'success': False,
            'request_id': self._generate_request_id(),
            'error': {
                'message': message,
                'code': error_code,
                'timestamp': self._get_timestamp()
            }
        }