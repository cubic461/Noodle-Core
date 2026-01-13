# WebSocket Communication Layer for NoodleCore IDE
# -------------------------------------------------

import .websocket.websocket_handler.WebSocketHandler
import .runtime.error_handler.ErrorHandler
import .self_improvement.ai_decision_engine.AIDecisionEngine
import .utils.common.CommonUtils

class IDEWebSocketManager:
    """
    WebSocket manager for real-time collaboration in NoodleCore IDE.
    
    Handles real-time file synchronization, collaborative editing,
    user presence tracking, and AI-powered suggestions distribution.
    """
    
    def __init__(self, websocket_handler, ai_engine, error_handler):
        """
        Initialize IDE WebSocket Manager.
        
        Args:
            websocket_handler: Base WebSocket handler
            ai_engine: AI decision engine for smart features
            error_handler: Error handling system
        """
        self.websocket_handler = websocket_handler
        self.ai_engine = ai_engine
        self.error_handler = error_handler
        
        # Session management
        self.ide_sessions = {}
        self.user_sessions = {}
        self.file_locks = {}
        
        # Collaboration settings
        self.collaboration_config = {
            'max_users_per_session': 10,
            'sync_interval': 100,  # milliseconds
            'conflict_resolution': 'last_writer_wins',
            'auto_save_interval': 30000,  # 30 seconds
            'cursor_sync_enabled': True,
            'selection_sync_enabled': True,
            'real_time_analysis': True,
            'ai_suggestions_broadcast': True
        }
        
        # AI integration settings
        self.ai_integration = {
            'analysis_debounce_time': 2000,  # milliseconds
            'suggestion_confidence_threshold': 0.7,
            'max_suggestions_per_user': 5,
            'learning_mode_enabled': True,
            'context_awareness': True
        }
        
        # Performance monitoring
        self.performance_metrics = {
            'active_connections': 0,
            'total_messages_sent': 0,
            'total_messages_received': 0,
            'average_response_time': 0,
            'error_rate': 0,
            'collaboration_sessions': 0
        }
        
        self.setup_event_handlers()
    
    def setup_event_handlers(self):
        """Setup WebSocket event handlers for IDE functionality."""
        
        # Register IDE-specific event handlers
        self.websocket_handler.register_event_handler('ide_join_session', self.handle_join_session)
        self.websocket_handler.register_event_handler('ide_leave_session', self.handle_leave_session)
        self.websocket_handler.register_event_handler('ide_file_open', self.handle_file_open)
        self.websocket_handler.register_event_handler('ide_file_close', self.handle_file_close)
        self.websocket_handler.register_event_handler('ide_code_change', self.handle_code_change)
        self.websocket_handler.register_event_handler('ide_cursor_move', self.handle_cursor_move)
        self.websocket_handler.register_event_handler('ide_selection_change', self.handle_selection_change)
        self.websocket_handler.register_event_handler('ide_save_file', self.handle_save_file)
        self.websocket_handler.register_event_handler('ide_execute_code', self.handle_execute_code)
        self.websocket_handler.register_event_handler('ide_ai_request', self.handle_ai_request)
        self.websocket_handler.register_event_handler('ide_search_request', self.handle_search_request)
        self.websocket_handler.register_event_handler('ide_collaboration_invite', self.handle_collaboration_invite)
    
    async def handle_join_session(self, data, target=None):
        """
        Handle user joining an IDE session.
        
        Args:
            data: Session join data
            target: Optional target client
        """
        try:
            session_id = data.get('session_id')
            user_id = data.get('user_id')
            username = data.get('username')
            
            if not all([session_id, user_id, username]):
                return await self.send_error(target, 'Missing required session data', '1003')
            
            # Check if session exists
            if session_id not in self.ide_sessions:
                self.ide_sessions[session_id] = {
                    'users': {},
                    'files': {},
                    'created_at': self.get_current_timestamp(),
                    'ai_analysis_enabled': True
                }
            
            session = self.ide_sessions[session_id]
            
            # Check user limit
            if len(session['users']) >= self.collaboration_config['max_users_per_session']:
                return await self.send_error(target, 'Session full', '1004')
            
            # Add user to session
            session['users'][user_id] = {
                'username': username,
                'joined_at': self.get_current_timestamp(),
                'is_active': True,
                'current_file': None,
                'cursor_position': None,
                'selection': None
            }
            
            # Track user session
            self.user_sessions[user_id] = session_id
            
            # Send session info to user
            await self.send_to_client(target, 'ide_session_joined', {
                'session_id': session_id,
                'users': list(session['users'].keys()),
                'files': list(session['files'].keys()),
                'ai_status': 'enabled'
            })
            
            # Notify other users
            await self.broadcast_to_session(session_id, 'user_joined', {
                'user_id': user_id,
                'username': username,
                'timestamp': self.get_current_timestamp()
            }, exclude_user=user_id)
            
            # Update performance metrics
            self.performance_metrics['collaboration_sessions'] = len(self.ide_sessions)
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to handle join session: {str(e)}')
            await self.send_error(target, 'Failed to join session', '1005')
    
    async def handle_leave_session(self, data, target=None):
        """
        Handle user leaving an IDE session.
        
        Args:
            data: Session leave data
            target: Optional target client
        """
        try:
            user_id = data.get('user_id')
            
            if user_id not in self.user_sessions:
                return
            
            session_id = self.user_sessions[user_id]
            session = self.ide_sessions.get(session_id)
            
            if session and user_id in session['users']:
                # Remove user from session
                del session['users'][user_id]
                del self.user_sessions[user_id]
                
                # Notify other users
                await self.broadcast_to_session(session_id, 'user_left', {
                    'user_id': user_id,
                    'timestamp': self.get_current_timestamp()
                })
                
                # Clean up empty sessions
                if not session['users']:
                    del self.ide_sessions[session_id]
                
                await self.send_to_client(target, 'ide_session_left', {
                    'session_id': session_id,
                    'message': 'Successfully left session'
                })
                
        except Exception as e:
            self.error_handler.handle_error(f'Failed to handle leave session: {str(e)}')
    
    async def handle_file_open(self, data, target=None):
        """
        Handle file opening event.
        
        Args:
            data: File open data
            target: Optional target client
        """
        try:
            user_id = data.get('user_id')
            session_id = data.get('session_id')
            filename = data.get('filename')
            language = data.get('language')
            
            if not all([user_id, session_id, filename]):
                return await self.send_error(target, 'Missing file open data', '1006')
            
            session = self.ide_sessions.get(session_id)
            if not session:
                return await self.send_error(target, 'Invalid session', '1007')
            
            # Add file to session if not exists
            if filename not in session['files']:
                session['files'][filename] = {
                    'language': language,
                    'content': '',
                    'last_modified': self.get_current_timestamp(),
                    'open_users': []
                }
            
            # Add user to file viewers
            file_data = session['files'][filename]
            if user_id not in file_data['open_users']:
                file_data['open_users'].append(user_id)
            
            # Update user session
            session['users'][user_id]['current_file'] = filename
            
            # Broadcast file open to session
            await self.broadcast_to_session(session_id, 'file_opened', {
                'filename': filename,
                'language': language,
                'user_id': user_id,
                'open_users': file_data['open_users']
            })
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to handle file open: {str(e)}')
    
    async def handle_code_change(self, data, target=None):
        """
        Handle real-time code changes.
        
        Args:
            data: Code change data
            target: Optional target client
        """
        try:
            user_id = data.get('user_id')
            session_id = data.get('session_id')
            filename = data.get('filename')
            content = data.get('content')
            change_type = data.get('change_type', 'full')
            version = data.get('version', 1)
            
            if not all([user_id, session_id, filename, content]):
                return await self.send_error(target, 'Missing code change data', '1008')
            
            session = self.ide_sessions.get(session_id)
            if not session or filename not in session['files']:
                return await self.send_error(target, 'Invalid file', '1009')
            
            file_data = session['files'][filename]
            
            # Update file content
            file_data['content'] = content
            file_data['last_modified'] = self.get_current_timestamp()
            file_data['last_editor'] = user_id
            
            # Handle different change types
            if change_type == 'incremental':
                # Send incremental changes to other users
                await self.broadcast_to_session(session_id, 'code_incremental_change', {
                    'filename': filename,
                    'user_id': user_id,
                    'content': content,
                    'version': version
                }, exclude_user=user_id)
            else:
                # Send full content update
                await self.broadcast_to_session(session_id, 'code_full_change', {
                    'filename': filename,
                    'user_id': user_id,
                    'content': content,
                    'version': version
                }, exclude_user=user_id)
            
            # Trigger AI analysis if enabled
            if self.collaboration_config['real_time_analysis'] and self.ai_integration['learning_mode_enabled']:
                await self.trigger_ai_analysis(session_id, filename, content, user_id)
            
            # Auto-save if interval reached
            await self.check_auto_save(session_id, filename)
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to handle code change: {str(e)}')
    
    async def handle_cursor_move(self, data, target=None):
        """
        Handle cursor position changes.
        
        Args:
            data: Cursor move data
            target: Optional target client
        """
        try:
            user_id = data.get('user_id')
            session_id = data.get('session_id')
            filename = data.get('filename')
            position = data.get('position')
            
            if not all([user_id, session_id, filename, position]):
                return
            
            if not self.collaboration_config['cursor_sync_enabled']:
                return
            
            session = self.ide_sessions.get(session_id)
            if not session or filename not in session['files']:
                return
            
            # Update user cursor position
            session['users'][user_id]['cursor_position'] = position
            
            # Broadcast cursor position to other users
            await self.broadcast_to_session(session_id, 'cursor_moved', {
                'filename': filename,
                'user_id': user_id,
                'position': position,
                'username': session['users'][user_id]['username']
            }, exclude_user=user_id)
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to handle cursor move: {str(e)}')
    
    async def handle_selection_change(self, data, target=None):
        """
        Handle text selection changes.
        
        Args:
            data: Selection change data
            target: Optional target client
        """
        try:
            user_id = data.get('user_id')
            session_id = data.get('session_id')
            filename = data.get('filename')
            selection = data.get('selection')
            
            if not all([user_id, session_id, filename, selection]):
                return
            
            if not self.collaboration_config['selection_sync_enabled']:
                return
            
            session = self.ide_sessions.get(session_id)
            if not session or filename not in session['files']:
                return
            
            # Update user selection
            session['users'][user_id]['selection'] = selection
            
            # Broadcast selection to other users
            await self.broadcast_to_session(session_id, 'selection_changed', {
                'filename': filename,
                'user_id': user_id,
                'selection': selection,
                'username': session['users'][user_id]['username']
            }, exclude_user=user_id)
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to handle selection change: {str(e)}')
    
    async def handle_save_file(self, data, target=None):
        """
        Handle file save events.
        
        Args:
            data: Save file data
            target: Optional target client
        """
        try:
            user_id = data.get('user_id')
            session_id = data.get('session_id')
            filename = data.get('filename')
            content = data.get('content')
            language = data.get('language')
            
            if not all([user_id, session_id, filename, content]):
                return await self.send_error(target, 'Missing save data', '1010')
            
            # Save file via API endpoint
            save_result = await self.save_file_to_server(filename, content, language)
            
            if save_result['success']:
                # Notify all users in session
                await self.broadcast_to_session(session_id, 'file_saved', {
                    'filename': filename,
                    'user_id': user_id,
                    'timestamp': self.get_current_timestamp(),
                    'version': save_result.get('version', 1)
                })
                
                await self.send_to_client(target, 'save_completed', {
                    'filename': filename,
                    'message': 'File saved successfully'
                })
            else:
                await self.send_error(target, f'Failed to save file: {save_result.get("error")}', '1011')
                
        except Exception as e:
            self.error_handler.handle_error(f'Failed to handle save file: {str(e)}')
    
    async def handle_execute_code(self, data, target=None):
        """
        Handle code execution requests.
        
        Args:
            data: Execute code data
            target: Optional target client
        """
        try:
            user_id = data.get('user_id')
            session_id = data.get('session_id')
            filename = data.get('filename')
            content = data.get('content')
            language = data.get('language')
            
            if not all([user_id, session_id, filename, content]):
                return await self.send_error(target, 'Missing execution data', '1012')
            
            # Execute code via API endpoint
            execution_result = await self.execute_code_on_server(content, language, filename)
            
            # Send result to requesting user
            await self.send_to_client(target, 'execution_result', {
                'filename': filename,
                'result': execution_result,
                'timestamp': self.get_current_timestamp()
            })
            
            # Broadcast execution status to session
            await self.broadcast_to_session(session_id, 'code_executed', {
                'filename': filename,
                'user_id': user_id,
                'status': 'completed' if execution_result.get('success') else 'failed',
                'timestamp': self.get_current_timestamp()
            }, exclude_user=user_id)
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to handle execute code: {str(e)}')
            await self.send_error(target, 'Code execution failed', '1013')
    
    async def handle_ai_request(self, data, target=None):
        """
        Handle AI analysis requests.
        
        Args:
            data: AI request data
            target: Optional target client
        """
        try:
            user_id = data.get('user_id')
            session_id = data.get('session_id')
            filename = data.get('filename')
            content = data.get('content')
            language = data.get('language')
            request_type = data.get('request_type', 'analysis')
            
            if not all([user_id, session_id, filename, content]):
                return await self.send_error(target, 'Missing AI request data', '1014')
            
            # Perform AI analysis
            ai_result = await self.ai_engine.analyze_code(content, language, filename)
            
            if ai_result.get('success'):
                suggestions = ai_result.get('suggestions', [])
                
                # Send suggestions to requesting user
                await self.send_to_client(target, 'ai_suggestions', {
                    'filename': filename,
                    'request_type': request_type,
                    'suggestions': suggestions,
                    'confidence_scores': [s.get('confidence', 0) for s in suggestions],
                    'timestamp': self.get_current_timestamp()
                })
                
                # Broadcast to session if configured
                if self.collaboration_config['ai_suggestions_broadcast']:
                    await self.broadcast_to_session(session_id, 'ai_analysis_complete', {
                        'filename': filename,
                        'user_id': user_id,
                        'suggestion_count': len(suggestions),
                        'timestamp': self.get_current_timestamp()
                    }, exclude_user=user_id)
            else:
                await self.send_error(target, f'AI analysis failed: {ai_result.get("error")}', '1015')
                
        except Exception as e:
            self.error_handler.handle_error(f'Failed to handle AI request: {str(e)}')
    
    async def handle_search_request(self, data, target=None):
        """
        Handle search requests.
        
        Args:
            data: Search request data
            target: Optional target client
        """
        try:
            user_id = data.get('user_id')
            session_id = data.get('session_id')
            query = data.get('query')
            search_type = data.get('search_type', 'filename')
            filters = data.get('filters', {})
            
            if not all([user_id, session_id, query]):
                return await self.send_error(target, 'Missing search data', '1016')
            
            # Perform search
            search_results = await self.perform_search(query, search_type, filters)
            
            # Send results to requesting user
            await self.send_to_client(target, 'search_results', {
                'query': query,
                'search_type': search_type,
                'results': search_results,
                'timestamp': self.get_current_timestamp()
            })
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to handle search request: {str(e)}')
    
    async def handle_collaboration_invite(self, data, target=None):
        """
        Handle collaboration invitations.
        
        Args:
            data: Invite data
            target: Optional target client
        """
        try:
            inviter_id = data.get('inviter_id')
            session_id = data.get('session_id')
            invitee_id = data.get('invitee_id')
            message = data.get('message', 'You are invited to collaborate')
            
            if not all([inviter_id, session_id, invitee_id]):
                return await self.send_error(target, 'Missing invite data', '1017')
            
            session = self.ide_sessions.get(session_id)
            if not session or inviter_id not in session['users']:
                return await self.send_error(target, 'Invalid session or inviter', '1018')
            
            # Send invitation to invitee
            await self.send_to_user(invitee_id, 'collaboration_invite', {
                'session_id': session_id,
                'inviter_id': inviter_id,
                'inviter_name': session['users'][inviter_id]['username'],
                'message': message,
                'timestamp': self.get_current_timestamp()
            })
            
            await self.send_to_client(target, 'invite_sent', {
                'invitee_id': invitee_id,
                'session_id': session_id,
                'message': 'Invitation sent successfully'
            })
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to handle collaboration invite: {str(e)}')
    
    async def trigger_ai_analysis(self, session_id, filename, content, user_id):
        """
        Trigger AI analysis for code changes.
        
        Args:
            session_id: Session identifier
            filename: File being analyzed
            content: Code content
            user_id: User who made changes
        """
        try:
            session = self.ide_sessions.get(session_id)
            if not session:
                return
            
            # Get file language
            language = session['files'].get(filename, {}).get('language', 'plaintext')
            
            # Trigger AI analysis
            ai_result = await self.ai_engine.analyze_code(content, language, filename)
            
            if ai_result.get('success'):
                suggestions = ai_result.get('suggestions', [])
                
                # Filter suggestions by confidence
                high_confidence_suggestions = [
                    s for s in suggestions 
                    if s.get('confidence', 0) >= self.ai_integration['suggestion_confidence_threshold']
                ]
                
                if high_confidence_suggestions:
                    # Send suggestions to user who made changes
                    await self.send_to_user(user_id, 'ai_suggestions', {
                        'filename': filename,
                        'trigger': 'auto_analysis',
                        'suggestions': high_confidence_suggestions[:self.ai_integration['max_suggestions_per_user']],
                        'timestamp': self.get_current_timestamp()
                    })
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to trigger AI analysis: {str(e)}')
    
    async def check_auto_save(self, session_id, filename):
        """
        Check if file should be auto-saved.
        
        Args:
            session_id: Session identifier
            filename: File to check
        """
        try:
            session = self.ide_sessions.get(session_id)
            if not session:
                return
            
            file_data = session['files'].get(filename)
            if not file_data:
                return
            
            last_save = file_data.get('last_save_timestamp', 0)
            current_time = self.get_current_timestamp()
            
            if current_time - last_save >= self.collaboration_config['auto_save_interval']:
                # Auto-save file
                save_result = await self.save_file_to_server(
                    filename, 
                    file_data['content'], 
                    file_data.get('language', 'plaintext')
                )
                
                if save_result['success']:
                    file_data['last_save_timestamp'] = current_time
                    file_data['last_saved_by'] = 'auto_save'
                    
                    # Notify session
                    await self.broadcast_to_session(session_id, 'file_auto_saved', {
                        'filename': filename,
                        'timestamp': current_time
                    })
                    
        except Exception as e:
            self.error_handler.handle_error(f'Failed to check auto save: {str(e)}')
    
    async def save_file_to_server(self, filename, content, language):
        """
        Save file to server via API.
        
        Args:
            filename: File name
            content: File content
            language: Programming language
            
        Returns:
            dict: Save result
        """
        try:
            # This would make an actual API call to the IDE file save endpoint
            # For now, return a mock success response
            return {
                'success': True,
                'version': 1,
                'message': 'File saved successfully'
            }
        except Exception as e:
            self.error_handler.handle_error(f'Failed to save file to server: {str(e)}')
            return {'success': False, 'error': str(e)}
    
    async def execute_code_on_server(self, content, language, filename):
        """
        Execute code on server via API.
        
        Args:
            content: Code content
            language: Programming language
            filename: File name
            
        Returns:
            dict: Execution result
        """
        try:
            # This would make an actual API call to the IDE code execution endpoint
            # For now, return a mock success response
            return {
                'success': True,
                'output': f'Code execution successful for {filename}',
                'execution_time': 0.25,
                'memory_usage': 15.2
            }
        except Exception as e:
            self.error_handler.handle_error(f'Failed to execute code on server: {str(e)}')
            return {'success': False, 'error': str(e)}
    
    async def perform_search(self, query, search_type, filters):
        """
        Perform search across files.
        
        Args:
            query: Search query
            search_type: Type of search (filename, content, semantic)
            filters: Search filters
            
        Returns:
            list: Search results
        """
        try:
            # This would make an actual API call to the search endpoint
            # For now, return mock search results
            return [
                {
                    'filename': 'example.py',
                    'path': '/src/example.py',
                    'match_type': 'content',
                    'match_text': f'Matched query: {query}',
                    'relevance_score': 0.95
                }
            ]
        except Exception as e:
            self.error_handler.handle_error(f'Failed to perform search: {str(e)}')
            return []
    
    async def broadcast_to_session(self, session_id, event, data, exclude_user=None):
        """
        Broadcast event to all users in a session.
        
        Args:
            session_id: Session identifier
            event: Event name
            data: Event data
            exclude_user: Optional user ID to exclude
        """
        try:
            session = self.ide_sessions.get(session_id)
            if not session:
                return
            
            for user_id in session['users'].keys():
                if user_id != exclude_user:
                    await self.send_to_user(user_id, event, data)
                    
        except Exception as e:
            self.error_handler.handle_error(f'Failed to broadcast to session: {str(e)}')
    
    async def send_to_user(self, user_id, event, data):
        """
        Send event to specific user.
        
        Args:
            user_id: Target user ID
            event: Event name
            data: Event data
        """
        try:
            # This would use the WebSocket handler to send to specific user
            # For now, this is a placeholder implementation
            pass
        except Exception as e:
            self.error_handler.handle_error(f'Failed to send to user: {str(e)}')
    
    async def send_to_client(self, target, event, data):
        """
        Send event to specific client connection.
        
        Args:
            target: Target client connection
            event: Event name
            data: Event data
        """
        try:
            # This would use the WebSocket handler to send to specific client
            # For now, this is a placeholder implementation
            pass
        except Exception as e:
            self.error_handler.handle_error(f'Failed to send to client: {str(e)}')
    
    async def send_error(self, target, message, error_code):
        """
        Send error message to client.
        
        Args:
            target: Target client connection
            message: Error message
            error_code: Error code
        """
        await self.send_to_client(target, 'error', {
            'message': message,
            'error_code': error_code,
            'timestamp': self.get_current_timestamp()
        })
    
    def get_current_timestamp(self):
        """Get current timestamp in milliseconds."""
        import time
        return int(time.time() * 1000)
    
    def get_performance_metrics(self):
        """
        Get performance metrics for monitoring.
        
        Returns:
            dict: Performance metrics
        """
        return self.performance_metrics.copy()
    
    def get_active_sessions(self):
        """
        Get information about active collaboration sessions.
        
        Returns:
            dict: Active sessions information
        """
        sessions_info = {}
        for session_id, session in self.ide_sessions.items():
            sessions_info[session_id] = {
                'user_count': len(session['users']),
                'file_count': len(session['files']),
                'created_at': session['created_at'],
                'users': list(session['users'].keys())
            }
        return sessions_info