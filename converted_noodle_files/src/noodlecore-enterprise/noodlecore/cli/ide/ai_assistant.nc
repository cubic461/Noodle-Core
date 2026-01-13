# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# AI Assistant Integration Module

# This module implements AI-powered code assistance within IDE for NoodleCore.
# """

import asyncio
import json
import os
import uuid
import hashlib
import typing.Dict,
import pathlib.Path
import datetime.datetime,

# Import logging
import ..logs.get_logger
import ..adapters.get_adapter_manager

# AI Assistant error codes (6201-6299)
AI_ASSISTANT_ERROR_CODES = {
#     "AI_MODEL_NOT_FOUND": 6201,
#     "AI_REQUEST_FAILED": 6202,
#     "AI_RESPONSE_TIMEOUT": 6203,
#     "AI_QUOTA_EXCEEDED": 6204,
#     "AI_SUGGESTION_FAILED": 6205,
#     "AI_CODE_GENERATION_FAILED": 6206,
#     "AI_REFACTORING_FAILED": 6207,
#     "AI_REVIEW_FAILED": 6208,
#     "AI_DEBUG_ASSISTANT_FAILED": 6209,
#     "AI_CHAT_FAILED": 6210,
#     "AI_CACHE_ERROR": 6211,
#     "AI_CONFIGURATION_ERROR": 6212,
# }


class AiAssistantError(Exception)
    #     """Custom exception for AI assistant errors with error codes."""

    #     def __init__(self, code: int, message: str, data: Optional[Dict[str, Any]] = None):
    self.code = code
    self.message = message
    self.data = data
            super().__init__(message)


class AiAssistant
    #     """AI Assistant for NoodleCore IDE integration."""

    #     def __init__(self, workspace_dir: Optional[str] = None):
    #         """
    #         Initialize the AI Assistant.

    #         Args:
    #             workspace_dir: Workspace directory
    #         """
    self.name = "AiAssistant"
    self.workspace_dir = Path(workspace_dir or os.getcwd())
    self.cache_dir = self.workspace_dir / ".noodlecore" / "ai_cache"
    self.config_file = self.workspace_dir / ".noodlecore" / "ai_config.json"
    self.history_file = self.workspace_dir / ".noodlecore" / "ai_history.json"

    #         # Initialize logger
    self.logger = get_logger(f"{__name__}.{self.name}")

    #         # Ensure directories exist
    self.cache_dir.mkdir(parents = True, exist_ok=True)

    #         # AI adapter manager
    self.adapter_manager = get_adapter_manager()

    #         # Default configuration
    self.default_config = {
    #             'enabled': True,
    #             'inline_suggestions': True,
    #             'model': 'zai_glm',
    #             'max_tokens': 1000,
    #             'temperature': 0.7,
    #             'timeout': 5000,
    #             'cache_enabled': True,
    #             'cache_ttl': 3600,
    #             'cache_size': 100,
    #             'auto_approve_safe': True,
    #             'context_window': 4000,
    #             'max_suggestions': 5,
    #             'suggestion_delay': 500,
    #             'code_generation': {
    #                 'enabled': True,
    #                 'max_length': 500,
    #                 'include_comments': True,
    #                 'include_types': True
    #             },
    #             'refactoring': {
    #                 'enabled': True,
    #                 'safe_mode': True,
    #                 'backup_original': True
    #             },
    #             'code_review': {
    #                 'enabled': True,
    #                 'severity_levels': ['error', 'warning', 'info'],
    #                 'categories': ['security', 'performance', 'style', 'logic']
    #             },
    #             'debugging': {
    #                 'enabled': True,
    #                 'auto_analyze_errors': True,
    #                 'suggest_fixes': True
    #             },
    #             'chat': {
    #                 'enabled': True,
    #                 'context_aware': True,
    #                 'include_code': True,
    #                 'max_history': 50
    #             }
    #         }

    #         # Configuration
    self.config = {}

    #         # Cache
    self.cache = {}
    self.cache_timestamps = {}

    #         # Chat history
    self.chat_history = []

    #         # Performance tracking
    self.performance_stats = {
    #             'total_requests': 0,
    #             'successful_requests': 0,
    #             'failed_requests': 0,
    #             'cache_hits': 0,
    #             'cache_misses': 0,
    #             'average_response_time': 0,
    #             'total_response_time': 0,
                'last_reset': datetime.now()
    #         }

    #         # Feature usage tracking
    self.feature_usage = {
    #             'inline_suggestions': 0,
    #             'code_generation': 0,
    #             'refactoring': 0,
    #             'code_review': 0,
    #             'debugging': 0,
    #             'chat': 0
    #         }

    #     async def initialize(self) -> Dict[str, Any]:
    #         """
    #         Initialize the AI Assistant.

    #         Returns:
    #             Dictionary containing initialization result
    #         """
    #         try:
                self.logger.info("Initializing AI Assistant")

    #             # Load configuration
    self.config = await self._load_config()

    #             # Initialize AI adapter
    adapter_result = await self._initialize_adapter()
    #             if not adapter_result['success']:
                    raise AiAssistantError(
    #                     AI_ASSISTANT_ERROR_CODES["AI_CONFIGURATION_ERROR"],
                        f"Failed to initialize AI adapter: {adapter_result.get('error', 'Unknown error')}"
    #                 )

    #             # Load cache
                await self._load_cache()

    #             # Load chat history
                await self._load_chat_history()

    #             # Start cache cleanup task
                asyncio.create_task(self._cache_cleanup_loop())

    #             self.logger.info(f"AI Assistant initialized with model: {self.config['model']}")

    #             return {
    #                 'success': True,
    #                 'message': f"AI Assistant initialized successfully with model: {self.config['model']}",
    #                 'model': self.config['model'],
    #                 'features': {
    #                     'inline_suggestions': self.config['inline_suggestions'],
    #                     'code_generation': self.config['code_generation']['enabled'],
    #                     'refactoring': self.config['refactoring']['enabled'],
    #                     'code_review': self.config['code_review']['enabled'],
    #                     'debugging': self.config['debugging']['enabled'],
    #                     'chat': self.config['chat']['enabled']
    #                 },
                    'request_id': str(uuid.uuid4())
    #             }

    #         except AiAssistantError:
    #             raise
    #         except Exception as e:
    error_code = AI_ASSISTANT_ERROR_CODES["AI_CONFIGURATION_ERROR"]
    self.logger.error(f"Failed to initialize AI Assistant: {str(e)}", exc_info = True)

    #             return {
    #                 'success': False,
                    'error': f"Failed to initialize AI Assistant: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def shutdown(self) -> Dict[str, Any]:
    #         """
    #         Shutdown the AI Assistant.

    #         Returns:
    #             Dictionary containing shutdown result
    #         """
    #         try:
                self.logger.info("Shutting down AI Assistant")

    #             # Save cache
                await self._save_cache()

    #             # Save chat history
                await self._save_chat_history()

    #             # Shutdown AI adapter
                await self._shutdown_adapter()

                self.logger.info("AI Assistant shutdown successfully")

    #             return {
    #                 'success': True,
    #                 'message': "AI Assistant shutdown successfully",
    #                 'performance_stats': self.performance_stats,
    #                 'feature_usage': self.feature_usage,
                    'request_id': str(uuid.uuid4())
    #             }

    #         except Exception as e:
    error_code = AI_ASSISTANT_ERROR_CODES["AI_CONFIGURATION_ERROR"]
    self.logger.error(f"Failed to shutdown AI Assistant: {str(e)}", exc_info = True)

    #             return {
    #                 'success': False,
                    'error': f"Failed to shutdown AI Assistant: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def get_inline_suggestion(self, file_path: str, line: int, character: int, context: str) -> Dict[str, Any]:
    #         """
    #         Get inline AI suggestion for code completion.

    #         Args:
    #             file_path: Path to the file
    #             line: Line number
    #             character: Character position
    #             context: Code context around the cursor

    #         Returns:
    #             Dictionary containing suggestion result
    #         """
    #         try:
    start_time = datetime.now()

    #             if not self.config.get('inline_suggestions', False):
    #                 return {
    #                     'success': False,
    #                     'error': "Inline suggestions are disabled",
    #                     'error_code': AI_ASSISTANT_ERROR_CODES["AI_CONFIGURATION_ERROR"],
                        'request_id': str(uuid.uuid4())
    #                 }

    #             # Check cache first
    cache_key = f"inline:{hashlib.md5(f'{file_path}:{line}:{character}:{context}'.encode()).hexdigest()}"
    cached_result = await self._get_from_cache(cache_key)
    #             if cached_result:
    self.performance_stats['cache_hits'] + = 1
    #                 return cached_result

    self.performance_stats['cache_misses'] + = 1

    #             # Prepare prompt
    prompt = self._prepare_inline_suggestion_prompt(file_path, line, character, context)

    #             # Get AI response
    response = await self._get_ai_response(prompt, max_tokens=self.config.get('max_tokens', 500))

    #             if not response['success']:
    #                 return response

    #             # Parse suggestion
    suggestion = self._parse_inline_suggestion(response['content'])

    result = {
    #                 'success': True,
    #                 'suggestion': suggestion,
    #                 'file_path': file_path,
    #                 'position': {'line': line, 'character': character},
    #                 'model': self.config['model'],
                    'request_id': str(uuid.uuid4())
    #             }

    #             # Cache result
                await self._save_to_cache(cache_key, result)

    #             # Update performance stats
    end_time = datetime.now()
    response_time = math.subtract((end_time, start_time).total_seconds())
                self._update_performance_stats(response_time, True)

    #             # Update feature usage
    self.feature_usage['inline_suggestions'] + = 1

    #             return result

    #         except Exception as e:
    error_code = AI_ASSISTANT_ERROR_CODES["AI_SUGGESTION_FAILED"]
    self.logger.error(f"Error getting inline suggestion: {str(e)}", exc_info = True)
                self._update_performance_stats(0, False)

    #             return {
    #                 'success': False,
                    'error': f"Error getting inline suggestion: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def generate_code(self, prompt: str, context: Optional[str] = None, file_type: str = 'nc') -> Dict[str, Any]:
    #         """
    #         Generate code using AI.

    #         Args:
    #             prompt: Natural language prompt describing what to generate
    #             context: Optional code context
                file_type: Type of file to generate (nc, noodle, config)

    #         Returns:
    #             Dictionary containing generation result
    #         """
    #         try:
    start_time = datetime.now()

    #             if not self.config.get('code_generation', {}).get('enabled', False):
    #                 return {
    #                     'success': False,
    #                     'error': "Code generation is disabled",
    #                     'error_code': AI_ASSISTANT_ERROR_CODES["AI_CONFIGURATION_ERROR"],
                        'request_id': str(uuid.uuid4())
    #                 }

    #             # Check cache first
    cache_key = f"generate:{hashlib.md5(f'{prompt}:{context}:{file_type}'.encode()).hexdigest()}"
    cached_result = await self._get_from_cache(cache_key)
    #             if cached_result:
    self.performance_stats['cache_hits'] + = 1
    #                 return cached_result

    self.performance_stats['cache_misses'] + = 1

    #             # Prepare prompt
    full_prompt = self._prepare_code_generation_prompt(prompt, context, file_type)

    #             # Get AI response
    response = await self._get_ai_response(
    #                 full_prompt,
    max_tokens = self.config['code_generation'].get('max_length', 500)
    #             )

    #             if not response['success']:
    #                 return response

    #             # Parse generated code
    generated_code = self._parse_generated_code(response['content'], file_type)

    result = {
    #                 'success': True,
    #                 'generated_code': generated_code,
    #                 'prompt': prompt,
    #                 'context': context,
    #                 'file_type': file_type,
    #                 'model': self.config['model'],
                    'request_id': str(uuid.uuid4())
    #             }

    #             # Cache result
                await self._save_to_cache(cache_key, result)

    #             # Update performance stats
    end_time = datetime.now()
    response_time = math.subtract((end_time, start_time).total_seconds())
                self._update_performance_stats(response_time, True)

    #             # Update feature usage
    self.feature_usage['code_generation'] + = 1

    #             return result

    #         except Exception as e:
    error_code = AI_ASSISTANT_ERROR_CODES["AI_CODE_GENERATION_FAILED"]
    self.logger.error(f"Error generating code: {str(e)}", exc_info = True)
                self._update_performance_stats(0, False)

    #             return {
    #                 'success': False,
                    'error': f"Error generating code: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def refactor_code(self, file_path: str, code: str, refactor_type: str) -> Dict[str, Any]:
    #         """
    #         Refactor code using AI.

    #         Args:
    #             file_path: Path to the file
    #             code: Code to refactor
                refactor_type: Type of refactoring (extract, inline, rename, optimize)

    #         Returns:
    #             Dictionary containing refactoring result
    #         """
    #         try:
    start_time = datetime.now()

    #             if not self.config.get('refactoring', {}).get('enabled', False):
    #                 return {
    #                     'success': False,
    #                     'error': "Code refactoring is disabled",
    #                     'error_code': AI_ASSISTANT_ERROR_CODES["AI_CONFIGURATION_ERROR"],
                        'request_id': str(uuid.uuid4())
    #                 }

    #             # Check cache first
    cache_key = f"refactor:{hashlib.md5(f'{file_path}:{code}:{refactor_type}'.encode()).hexdigest()}"
    cached_result = await self._get_from_cache(cache_key)
    #             if cached_result:
    self.performance_stats['cache_hits'] + = 1
    #                 return cached_result

    self.performance_stats['cache_misses'] + = 1

    #             # Prepare prompt
    prompt = self._prepare_refactoring_prompt(code, refactor_type)

    #             # Get AI response
    response = await self._get_ai_response(
    #                 prompt,
    max_tokens = self.config.get('max_tokens', 1000)
    #             )

    #             if not response['success']:
    #                 return response

    #             # Parse refactored code
    refactored_code = self._parse_refactored_code(response['content'])

    #             # Create backup if enabled
    backup_path = None
    #             if self.config['refactoring'].get('backup_original', True):
    backup_path = await self._create_backup(file_path, code)

    result = {
    #                 'success': True,
    #                 'original_code': code,
    #                 'refactored_code': refactored_code,
    #                 'refactor_type': refactor_type,
    #                 'file_path': file_path,
    #                 'backup_path': backup_path,
    #                 'model': self.config['model'],
                    'request_id': str(uuid.uuid4())
    #             }

    #             # Cache result
                await self._save_to_cache(cache_key, result)

    #             # Update performance stats
    end_time = datetime.now()
    response_time = math.subtract((end_time, start_time).total_seconds())
                self._update_performance_stats(response_time, True)

    #             # Update feature usage
    self.feature_usage['refactoring'] + = 1

    #             return result

    #         except Exception as e:
    error_code = AI_ASSISTANT_ERROR_CODES["AI_REFACTORING_FAILED"]
    self.logger.error(f"Error refactoring code: {str(e)}", exc_info = True)
                self._update_performance_stats(0, False)

    #             return {
    #                 'success': False,
                    'error': f"Error refactoring code: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def review_code(self, file_path: str, code: str) -> Dict[str, Any]:
    #         """
    #         Review code using AI.

    #         Args:
    #             file_path: Path to the file
    #             code: Code to review

    #         Returns:
    #             Dictionary containing review result
    #         """
    #         try:
    start_time = datetime.now()

    #             if not self.config.get('code_review', {}).get('enabled', False):
    #                 return {
    #                     'success': False,
    #                     'error': "Code review is disabled",
    #                     'error_code': AI_ASSISTANT_ERROR_CODES["AI_CONFIGURATION_ERROR"],
                        'request_id': str(uuid.uuid4())
    #                 }

    #             # Check cache first
    cache_key = f"review:{hashlib.md5(f'{file_path}:{code}'.encode()).hexdigest()}"
    cached_result = await self._get_from_cache(cache_key)
    #             if cached_result:
    self.performance_stats['cache_hits'] + = 1
    #                 return cached_result

    self.performance_stats['cache_misses'] + = 1

    #             # Prepare prompt
    prompt = self._prepare_code_review_prompt(code)

    #             # Get AI response
    response = await self._get_ai_response(
    #                 prompt,
    max_tokens = self.config.get('max_tokens', 1000)
    #             )

    #             if not response['success']:
    #                 return response

    #             # Parse review results
    review_results = self._parse_code_review(response['content'])

    result = {
    #                 'success': True,
    #                 'file_path': file_path,
    #                 'review_results': review_results,
    #                 'model': self.config['model'],
                    'request_id': str(uuid.uuid4())
    #             }

    #             # Cache result
                await self._save_to_cache(cache_key, result)

    #             # Update performance stats
    end_time = datetime.now()
    response_time = math.subtract((end_time, start_time).total_seconds())
                self._update_performance_stats(response_time, True)

    #             # Update feature usage
    self.feature_usage['code_review'] + = 1

    #             return result

    #         except Exception as e:
    error_code = AI_ASSISTANT_ERROR_CODES["AI_REVIEW_FAILED"]
    self.logger.error(f"Error reviewing code: {str(e)}", exc_info = True)
                self._update_performance_stats(0, False)

    #             return {
    #                 'success': False,
                    'error': f"Error reviewing code: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def debug_assistance(self, file_path: str, code: str, error_message: str, stack_trace: Optional[str] = None) -> Dict[str, Any]:
    #         """
    #         Get debugging assistance from AI.

    #         Args:
    #             file_path: Path to the file
    #             code: Code with error
    #             error_message: Error message
    #             stack_trace: Optional stack trace

    #         Returns:
    #             Dictionary containing debugging assistance result
    #         """
    #         try:
    start_time = datetime.now()

    #             if not self.config.get('debugging', {}).get('enabled', False):
    #                 return {
    #                     'success': False,
    #                     'error': "Debugging assistance is disabled",
    #                     'error_code': AI_ASSISTANT_ERROR_CODES["AI_CONFIGURATION_ERROR"],
                        'request_id': str(uuid.uuid4())
    #                 }

    #             # Check cache first
    cache_key = f"debug:{hashlib.md5(f'{file_path}:{code}:{error_message}'.encode()).hexdigest()}"
    cached_result = await self._get_from_cache(cache_key)
    #             if cached_result:
    self.performance_stats['cache_hits'] + = 1
    #                 return cached_result

    self.performance_stats['cache_misses'] + = 1

    #             # Prepare prompt
    prompt = self._prepare_debug_prompt(code, error_message, stack_trace)

    #             # Get AI response
    response = await self._get_ai_response(
    #                 prompt,
    max_tokens = self.config.get('max_tokens', 1000)
    #             )

    #             if not response['success']:
    #                 return response

    #             # Parse debugging assistance
    debug_assistance = self._parse_debug_assistance(response['content'])

    result = {
    #                 'success': True,
    #                 'file_path': file_path,
    #                 'error_message': error_message,
    #                 'debug_assistance': debug_assistance,
    #                 'model': self.config['model'],
                    'request_id': str(uuid.uuid4())
    #             }

    #             # Cache result
                await self._save_to_cache(cache_key, result)

    #             # Update performance stats
    end_time = datetime.now()
    response_time = math.subtract((end_time, start_time).total_seconds())
                self._update_performance_stats(response_time, True)

    #             # Update feature usage
    self.feature_usage['debugging'] + = 1

    #             return result

    #         except Exception as e:
    error_code = AI_ASSISTANT_ERROR_CODES["AI_DEBUG_ASSISTANT_FAILED"]
    self.logger.error(f"Error providing debugging assistance: {str(e)}", exc_info = True)
                self._update_performance_stats(0, False)

    #             return {
    #                 'success': False,
                    'error': f"Error providing debugging assistance: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def chat_with_ai(self, message: str, context: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    #         """
    #         Chat with AI assistant.

    #         Args:
    #             message: User message
                context: Optional context (file_path, code, etc.)

    #         Returns:
    #             Dictionary containing chat result
    #         """
    #         try:
    start_time = datetime.now()

    #             if not self.config.get('chat', {}).get('enabled', False):
    #                 return {
    #                     'success': False,
    #                     'error': "AI chat is disabled",
    #                     'error_code': AI_ASSISTANT_ERROR_CODES["AI_CONFIGURATION_ERROR"],
                        'request_id': str(uuid.uuid4())
    #                 }

    #             # Add user message to history
    user_message = {
    #                 'role': 'user',
    #                 'content': message,
                    'timestamp': datetime.now().isoformat(),
    #                 'context': context
    #             }
                self.chat_history.append(user_message)

    #             # Prepare prompt with history
    prompt = self._prepare_chat_prompt(message, context)

    #             # Get AI response
    response = await self._get_ai_response(
    #                 prompt,
    max_tokens = self.config.get('max_tokens', 1000)
    #             )

    #             if not response['success']:
    #                 return response

    #             # Add AI response to history
    ai_message = {
    #                 'role': 'assistant',
    #                 'content': response['content'],
                    'timestamp': datetime.now().isoformat(),
    #                 'model': self.config['model']
    #             }
                self.chat_history.append(ai_message)

    #             # Trim history if needed
    max_history = self.config['chat'].get('max_history', 50)
    #             if len(self.chat_history) > max_history * 2:  # *2 for user + assistant pairs
    self.chat_history = math.multiply(self.chat_history[-max_history, 2:])

    result = {
    #                 'success': True,
    #                 'message': message,
    #                 'response': response['content'],
    #                 'context': context,
    #                 'model': self.config['model'],
                    'request_id': str(uuid.uuid4())
    #             }

    #             # Update performance stats
    end_time = datetime.now()
    response_time = math.subtract((end_time, start_time).total_seconds())
                self._update_performance_stats(response_time, True)

    #             # Update feature usage
    self.feature_usage['chat'] + = 1

    #             return result

    #         except Exception as e:
    error_code = AI_ASSISTANT_ERROR_CODES["AI_CHAT_FAILED"]
    self.logger.error(f"Error in AI chat: {str(e)}", exc_info = True)
                self._update_performance_stats(0, False)

    #             return {
    #                 'success': False,
                    'error': f"Error in AI chat: {str(e)}",
    #                 'error_code': error_code,
                    'request_id': str(uuid.uuid4())
    #             }

    #     async def _load_config(self) -> Dict[str, Any]:
    #         """Load AI configuration."""
    #         try:
    #             if self.config_file.exists():
    #                 with open(self.config_file, 'r', encoding='utf-8') as f:
    config = json.load(f)

    #                 # Merge with default config
    merged_config = self._merge_configs(self.default_config, config)
    #                 return merged_config
    #             else:
    #                 # Create default config file
                    await self._save_config(self.default_config)
                    return self.default_config.copy()

            except (json.JSONDecodeError, IOError) as e:
    self.logger.error(f"Error loading AI config: {str(e)}", exc_info = True)
                return self.default_config.copy()

    #     async def _save_config(self, config: Dict[str, Any]) -> None:
    #         """Save AI configuration."""
    #         try:
    #             with open(self.config_file, 'w', encoding='utf-8') as f:
    json.dump(config, f, indent = 2)
    #         except IOError as e:
    self.logger.error(f"Error saving AI config: {str(e)}", exc_info = True)

    #     def _merge_configs(self, default: Dict[str, Any], custom: Dict[str, Any]) -> Dict[str, Any]:
    #         """Merge custom config with default config."""
    result = default.copy()

    #         for key, value in custom.items():
    #             if key in result and isinstance(result[key], dict) and isinstance(value, dict):
    result[key] = self._merge_configs(result[key], value)
    #             else:
    result[key] = value

    #         return result

    #     async def _initialize_adapter(self) -> Dict[str, Any]:
    #         """Initialize AI adapter."""
    #         try:
    model = self.config.get('model', 'zai_glm')

    #             # Initialize adapter with model
    result = await self.adapter_manager.initialize_adapter(model)

    #             return result

    #         except Exception as e:
    self.logger.error(f"Error initializing AI adapter: {str(e)}", exc_info = True)
    #             return {
    #                 'success': False,
                    'error': f"Error initializing AI adapter: {str(e)}"
    #             }

    #     async def _shutdown_adapter(self) -> None:
    #         """Shutdown AI adapter."""
    #         try:
                await self.adapter_manager.shutdown()
    #         except Exception as e:
    self.logger.error(f"Error shutting down AI adapter: {str(e)}", exc_info = True)

    #     async def _get_ai_response(self, prompt: str, max_tokens: int = 1000) -> Dict[str, Any]:
    #         """Get response from AI adapter."""
    #         try:
    #             # Get current adapter
    adapter = await self.adapter_manager.get_adapter(self.config.get('model', 'zai_glm'))

    #             if not adapter:
    #                 return {
    #                     'success': False,
    #                     'error': f"AI adapter not found for model: {self.config.get('model')}",
    #                     'error_code': AI_ASSISTANT_ERROR_CODES["AI_MODEL_NOT_FOUND"]
    #                 }

    #             # Prepare request
    request_data = {
    #                 'prompt': prompt,
    #                 'max_tokens': max_tokens,
                    'temperature': self.config.get('temperature', 0.7),
                    'timeout': self.config.get('timeout', 5000)
    #             }

    #             # Get response
    response = await adapter.generate(request_data)

    #             return response

    #         except asyncio.TimeoutError:
    #             return {
    #                 'success': False,
    #                 'error': "AI request timed out",
    #                 'error_code': AI_ASSISTANT_ERROR_CODES["AI_RESPONSE_TIMEOUT"]
    #             }
    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': f"AI request failed: {str(e)}",
    #                 'error_code': AI_ASSISTANT_ERROR_CODES["AI_REQUEST_FAILED"]
    #             }

    #     def _prepare_inline_suggestion_prompt(self, file_path: str, line: int, character: int, context: str) -> str:
    #         """Prepare prompt for inline suggestion."""
    #         return f"""You are a NoodleCore code completion assistant. Based on the following code context, provide a single, concise completion suggestion.

# File: {file_path}
# Line: {line}, Character: {character}
# Context:
# {context}

# Provide only the code completion, without any explanation or formatting. The suggestion should be syntactically correct NoodleCore code that completes the current line or statement."""

#     def _prepare_code_generation_prompt(self, prompt: str, context: Optional[str], file_type: str) -> str:
#         """Prepare prompt for code generation."""
#         context_part = f"\nContext:\n{context}" if context else ""

#         return f"""You are a NoodleCore code generation assistant. Generate NoodleCore code based on the following description.

# File type: {file_type}
# Description: {prompt}{context_part}

# Generate syntactically correct NoodleCore code that fulfills the description. Include appropriate comments and follow NoodleCore best practices."""

#     def _prepare_refactoring_prompt(self, code: str, refactor_type: str) -> str:
#         """Prepare prompt for code refactoring."""
#         return f"""You are a NoodleCore code refactoring assistant. Refactor the following NoodleCore code to {refactor_type} it.

# Code:
# {code}

# Provide the refactored code that maintains the same functionality but improves the code according to the {refactor_type} refactoring type. Ensure the refactored code is syntactically correct and follows NoodleCore best practices."""

#     def _prepare_code_review_prompt(self, code: str) -> str:
#         """Prepare prompt for code review."""
categories = ', '.join(self.config.get('code_review', {}).get('categories', ['security', 'performance', 'style', 'logic']))

#         return f"""You are a NoodleCore code review assistant. Review the following NoodleCore code and provide feedback on: {categories}.

# Code:
# {code}

# Provide a structured review with:
# 1. Issues found (if any) with severity levels (error, warning, info)
# 2. Suggestions for improvement
# 3. Positive aspects of the code

# Format your response as JSON with the following structure:
# {{
#   "issues": [
#     {{
#       "type": "security|performance|style|logic",
#       "severity": "error|warning|info",
#       "line": <line_number>,
#       "message": "<description>",
#       "suggestion": "<fix_suggestion>"
#     }}
#   ],
#   "suggestions": [
#     {{
#       "type": "<suggestion_type>",
#       "message": "<description>",
#       "code": "<example_code>"
#     }}
#   ],
#   "positives": [
#     "<positive_aspect>"
#   ]
# }}"""

#     def _prepare_debug_prompt(self, code: str, error_message: str, stack_trace: Optional[str]) -> str:
#         """Prepare prompt for debugging assistance."""
#         stack_trace_part = f"\nStack Trace:\n{stack_trace}" if stack_trace else ""

#         return f"""You are a NoodleCore debugging assistant. Help debug the following error in NoodleCore code.

# Error Message:
# {error_message}{stack_trace_part}

# Code:
# {code}

# Provide:
# 1. Analysis of what might be causing the error
# 2. Specific suggestions to fix the issue
# 3. Explanation of why the error occurs
# 4. Best practices to avoid similar errors in the future

# Format your response as JSON with the following structure:
# {{
#   "analysis": "<detailed_analysis>",
#   "cause": "<likely_cause>",
#   "suggestions": [
#     {{
#       "description": "<suggestion_description>",
#       "code": "<code_example>",
#       "explanation": "<why_this_helps>"
#     }}
#   ],
#   "best_practices": [
#     "<best_practice>"
#   ]
# }}"""

#     def _prepare_chat_prompt(self, message: str, context: Optional[Dict[str, Any]]) -> str:
#         """Prepare prompt for AI chat."""
context_part = ""
#         if context and self.config.get('chat', {}).get('context_aware', True):
#             if 'file_path' in context:
context_part + = f"\nCurrent file: {context['file_path']}"
#             if 'code' in context and self.config.get('chat', {}).get('include_code', True):
context_part + = f"\nCurrent code:\n{context['code']}"

#         # Build conversation history
history_part = ""
max_history = self.config.get('chat', {}).get('max_history', 50)
recent_history = math.subtract(self.chat_history[, max_history:])

#         for msg in recent_history:
history_part + = f"\n{msg['role'].title()}: {msg['content']}"

#         return f"""You are a helpful NoodleCore programming assistant. You are chatting with a developer who needs help with NoodleCore code.{context_part}

# Recent conversation history:{history_part}

# User: {message}

# Assistant:"""

#     def _parse_inline_suggestion(self, response: str) -> str:
#         """Parse inline suggestion from AI response."""
#         # Clean up response
suggestion = response.strip()

#         # Remove any markdown code blocks
#         if suggestion.startswith('```'):
lines = suggestion.split('\n')
#             if len(lines) > 2:
suggestion = '\n'.join(lines[1:-1])

#         return suggestion

#     def _parse_generated_code(self, response: str, file_type: str) -> str:
#         """Parse generated code from AI response."""
#         # Clean up response
code = response.strip()

#         # Remove any markdown code blocks
#         if code.startswith('```'):
lines = code.split('\n')
#             if len(lines) > 2:
code = '\n'.join(lines[1:-1])

#         return code

#     def _parse_refactored_code(self, response: str) -> str:
#         """Parse refactored code from AI response."""
#         # Clean up response
code = response.strip()

#         # Remove any markdown code blocks
#         if code.startswith('```'):
lines = code.split('\n')
#             if len(lines) > 2:
code = '\n'.join(lines[1:-1])

#         return code

#     def _parse_code_review(self, response: str) -> Dict[str, Any]:
#         """Parse code review from AI response."""
#         try:
#             # Try to parse as JSON
#             if response.strip().startswith('{'):
                return json.loads(response)
#         except json.JSONDecodeError:
#             pass

#         # Fallback to structured text parsing
#         return {
#             'issues': [],
#             'suggestions': [],
#             'positives': [response],
#             'raw_response': response
#         }

#     def _parse_debug_assistance(self, response: str) -> Dict[str, Any]:
#         """Parse debugging assistance from AI response."""
#         try:
#             # Try to parse as JSON
#             if response.strip().startswith('{'):
                return json.loads(response)
#         except json.JSONDecodeError:
#             pass

#         # Fallback to structured text parsing
#         return {
#             'analysis': response,
#             'cause': "Unknown",
#             'suggestions': [],
#             'best_practices': [],
#             'raw_response': response
#         }

#     async def _create_backup(self, file_path: str, code: str) -> str:
#         """Create backup of original code."""
#         try:
backup_dir = self.workspace_dir / ".noodlecore" / "backups"
backup_dir.mkdir(exist_ok = True)

timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
file_name = Path(file_path).stem
backup_path = backup_dir / f"{file_name}_{timestamp}.nc"

#             with open(backup_path, 'w', encoding='utf-8') as f:
                f.write(code)

            return str(backup_path)

#         except Exception as e:
self.logger.error(f"Error creating backup: {str(e)}", exc_info = True)
#             return None

#     async def _load_cache(self) -> None:
#         """Load AI cache."""
#         try:
cache_file = self.cache_dir / "ai_cache.json"

#             if cache_file.exists():
#                 with open(cache_file, 'r') as f:
cache_data = json.load(f)

self.cache = cache_data.get('data', {})
self.cache_timestamps = cache_data.get('timestamps', {})

#                 # Check TTL and remove expired entries
                await self._cleanup_cache()

#         except Exception as e:
self.logger.error(f"Error loading AI cache: {str(e)}", exc_info = True)
self.cache = {}
self.cache_timestamps = {}

#     async def _save_cache(self) -> None:
#         """Save AI cache."""
#         try:
cache_file = self.cache_dir / "ai_cache.json"

cache_data = {
#                 'data': self.cache,
#                 'timestamps': self.cache_timestamps
#             }

#             with open(cache_file, 'w') as f:
json.dump(cache_data, f, indent = 2, default=str)

#         except Exception as e:
self.logger.error(f"Error saving AI cache: {str(e)}", exc_info = True)

#     async def _get_from_cache(self, key: str) -> Optional[Dict[str, Any]]:
#         """Get data from cache."""
#         try:
#             if not self.config.get('cache_enabled', True):
#                 return None

#             if key in self.cache:
#                 # Check TTL
#                 if key in self.cache_timestamps:
timestamp = datetime.fromisoformat(self.cache_timestamps[key])
ttl = self.config.get('cache_ttl', 3600)

#                     if (datetime.now() - timestamp).total_seconds() < ttl:
#                         return self.cache[key]
#                     else:
#                         # Expired, remove from cache
#                         del self.cache[key]
#                         del self.cache_timestamps[key]

#             return None

#         except Exception as e:
self.logger.error(f"Error getting from AI cache: {str(e)}", exc_info = True)
#             return None

#     async def _save_to_cache(self, key: str, data: Dict[str, Any]) -> None:
#         """Save data to cache."""
#         try:
#             if not self.config.get('cache_enabled', True):
#                 return

#             # Check cache size
max_size = self.config.get('cache_size', 100)
#             if len(self.cache) >= max_size:
#                 # Remove oldest entry
oldest_key = min(self.cache_timestamps.keys(),
key = lambda k: datetime.fromisoformat(self.cache_timestamps[k]))
#                 del self.cache[oldest_key]
#                 del self.cache_timestamps[oldest_key]

#             # Save to cache
self.cache[key] = data
self.cache_timestamps[key] = datetime.now().isoformat()

#         except Exception as e:
self.logger.error(f"Error saving to AI cache: {str(e)}", exc_info = True)

#     async def _cleanup_cache(self) -> None:
#         """Clean up expired cache entries."""
#         try:
ttl = self.config.get('cache_ttl', 3600)
current_time = datetime.now()

expired_keys = []
#             for key, timestamp_str in self.cache_timestamps.items():
timestamp = datetime.fromisoformat(timestamp_str)
#                 if (current_time - timestamp).total_seconds() >= ttl:
                    expired_keys.append(key)

#             for key in expired_keys:
#                 if key in self.cache:
#                     del self.cache[key]
#                 del self.cache_timestamps[key]

#         except Exception as e:
self.logger.error(f"Error cleaning up AI cache: {str(e)}", exc_info = True)

#     async def _cache_cleanup_loop(self) -> None:
#         """Periodic cache cleanup loop."""
#         try:
#             while True:
                await asyncio.sleep(300)  # 5 minutes
                await self._cleanup_cache()
                await self._save_cache()
#         except asyncio.CancelledError:
#             pass
#         except Exception as e:
self.logger.error(f"Error in cache cleanup loop: {str(e)}", exc_info = True)

#     async def _load_chat_history(self) -> None:
#         """Load chat history."""
#         try:
#             if self.history_file.exists():
#                 with open(self.history_file, 'r', encoding='utf-8') as f:
self.chat_history = json.load(f)
#         except Exception as e:
self.logger.error(f"Error loading chat history: {str(e)}", exc_info = True)
self.chat_history = []

#     async def _save_chat_history(self) -> None:
#         """Save chat history."""
#         try:
#             with open(self.history_file, 'w', encoding='utf-8') as f:
json.dump(self.chat_history, f, indent = 2, default=str)
#         except Exception as e:
self.logger.error(f"Error saving chat history: {str(e)}", exc_info = True)

#     def _update_performance_stats(self, response_time: float, success: bool) -> None:
#         """Update performance statistics."""
self.performance_stats['total_requests'] + = 1

#         if success:
self.performance_stats['successful_requests'] + = 1
self.performance_stats['total_response_time'] + = response_time
self.performance_stats['average_response_time'] = (
#                 self.performance_stats['total_response_time'] /
#                 self.performance_stats['successful_requests']
#             )
#         else:
self.performance_stats['failed_requests'] + = 1

#     async def get_assistant_info(self) -> Dict[str, Any]:
#         """
#         Get information about the AI Assistant.

#         Returns:
#             Dictionary containing AI Assistant information
#         """
#         try:
#             return {
#                 'name': self.name,
#                 'version': '1.0.0',
                'model': self.config.get('model', 'zai_glm'),
                'enabled': self.config.get('enabled', True),
#                 'features': {
                    'inline_suggestions': self.config.get('inline_suggestions', False),
                    'code_generation': self.config.get('code_generation', {}).get('enabled', False),
                    'refactoring': self.config.get('refactoring', {}).get('enabled', False),
                    'code_review': self.config.get('code_review', {}).get('enabled', False),
                    'debugging': self.config.get('debugging', {}).get('enabled', False),
                    'chat': self.config.get('chat', {}).get('enabled', False)
#                 },
#                 'performance_stats': self.performance_stats,
#                 'feature_usage': self.feature_usage,
#                 'cache_stats': {
                    'enabled': self.config.get('cache_enabled', True),
                    'size': len(self.cache),
                    'max_size': self.config.get('cache_size', 100),
                    'ttl': self.config.get('cache_ttl', 3600)
#                 },
                'chat_history_size': len(self.chat_history),
                'request_id': str(uuid.uuid4())
#             }

#         except Exception as e:
error_code = AI_ASSISTANT_ERROR_CODES["AI_CONFIGURATION_ERROR"]
self.logger.error(f"Error getting assistant info: {str(e)}", exc_info = True)

#             return {
#                 'success': False,
                'error': f"Error getting assistant info: {str(e)}",
#                 'error_code': error_code,
                'request_id': str(uuid.uuid4())
#             }