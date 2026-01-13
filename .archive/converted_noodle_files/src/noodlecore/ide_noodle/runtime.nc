# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# NoodleCore Command Runtime
# Thin Python runtime that loads .nc specs and dispatches IDE features
# """

import sys
import typing.Dict,

def execute_file(file_path: str) -> Dict[str, Any]:
#     """
#     Execute a NoodleCore file and return results.

#     Args:
#         file_path: Path to NoodleCore file to execute

#     Returns:
#         Dict with execution results
#     """
#     try:
#         # Read the NoodleCore file
#         with open(file_path, 'r', encoding='utf-8') as f:
nc_code = f.read()

#         # Simple execution - in a real implementation, this would
#         # use the full NoodleCore runtime engine
        print(f"Executing NoodleCore file: {file_path}")
print(" = == NoodleCore Output ===")

        # Execute the code (simplified)
#         try:
            exec(nc_code, {'__name__': '__main__'})
#         except SyntaxError as e:
#             return {
#                 "ok": False,
#                 "data": None,
                "error": f"Syntax error: {str(e)}"
#             }

#         return {
#             "ok": True,
#             "data": "NoodleCore file executed successfully",
#             "error": None
#         }

#     except Exception as e:
#         return {
#             "ok": False,
#             "data": None,
            "error": str(e)
#         }

# Add this function to the module level for easy import
__all__ = ['execute_file']

import os
import re
import logging
import typing.Dict,
import pathlib.Path

# Setup logging
logger = logging.getLogger(__name__)

class _NoodleCoreRuntimeAdapter
    #     """
    #     Internal adapter that delegates to existing NoodleCore runtime primitives.
    #     This provides a thin facade over the core NoodleCore execution engine.
    #     """

    #     def __init__(self):
    self._core_runtime = None
            self._initialize_core_runtime()

    #     def _initialize_core_runtime(self):
    #         """Initialize the core NoodleCore runtime if available."""
    #         try:
    #             # Import the core runtime entry point
    #             from ..runtime.runtime_entry import get_default_runtime
    self._core_runtime = get_default_runtime()
    #             logger.info("NoodleCore runtime adapter initialized with core runtime")
    #         except ImportError as e:
                logger.warning(f"Could not import core NoodleCore runtime: {e}")
    self._core_runtime = None
    #         except Exception as e:
                logger.error(f"Error initializing core NoodleCore runtime: {e}")
    self._core_runtime = None

    #     def is_available(self) -> bool:
    #         """Check if core runtime is available."""
    #         return self._core_runtime is not None

    #     def execute_noodle_code(self, code: str, context: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    #         """
    #         Execute NoodleCore code using the core runtime.

    #         Args:
    #             code: NoodleCore code to execute
    #             context: Optional execution context

    #         Returns:
    #             Dict with execution results
    #         """
    #         if not self.is_available():
    #             return {
    #                 "ok": False,
    #                 "error": "Core NoodleCore runtime not available",
    #                 "data": None
    #             }

    #         try:
    result = self._core_runtime.execute_code(code, context)
    #             return {
    #                 "ok": True,
    #                 "data": result,
    #                 "error": None
    #             }
    #         except Exception as e:
                logger.error(f"Error executing NoodleCore code: {e}")
    #             return {
    #                 "ok": False,
                    "error": str(e),
    #                 "data": None
    #             }

    #     def execute_noodle_file(self, file_path: str, context: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    #         """
    #         Execute a NoodleCore file using the core runtime.

    #         Args:
    #             file_path: Path to NoodleCore file
    #             context: Optional execution context

    #         Returns:
    #             Dict with execution results
    #         """
    #         if not self.is_available():
    #             return {
    #                 "ok": False,
    #                 "error": "Core NoodleCore runtime not available",
    #                 "data": None
    #             }

    #         try:
    result = self._core_runtime.execute_file(file_path, context)
    #             return {
    #                 "ok": True,
    #                 "data": result,
    #                 "error": None
    #             }
    #         except Exception as e:
                logger.error(f"Error executing NoodleCore file: {e}")
    #             return {
    #                 "ok": False,
                    "error": str(e),
    #                 "data": None
    #             }

class NoodleCommandRuntime
    #     """Runtime for loading .nc specs and dispatching IDE commands"""

    #     def __init__(self, spec_dir: Optional[str] = None, validate_on_load: bool = False):
    self.spec_dir = spec_dir or os.path.dirname(__file__)
    self.attributes: Dict[str, Any] = {}
    self.commands: Dict[str, Any] = {}
    self.sequences: Dict[str, Any] = {}
    self.providers: Dict[str, Any] = {}
    self.roles: Dict[str, Any] = {}
    self.handlers: Dict[str, Any] = {}
    self.ai_client = None
    self._loaded = False
    self.validate_on_load = validate_on_load

    #         # Initialize the core runtime adapter
    self._core_adapter = _NoodleCoreRuntimeAdapter()

    #     def load_specs(self) -> bool:
    #         """Load all .nc specification files"""
    #         try:
                self._load_attributes()
                self._load_commands()
                self._load_sequences()
                self._load_providers()
                self._register_handlers()

    #             # Validate specs if enabled
    #             if self.validate_on_load:
                    self._validate_loaded_specs()

    self._loaded = True
                logger.info("NoodleCore specs loaded successfully")
    #             return True
    #         except Exception as e:
                logger.error(f"Failed to load NoodleCore specs: {e}")
    #             return False

    #     def _load_attributes(self):
    #         """Parse attributes.nc file"""
    attributes_path = os.path.join(self.spec_dir, "attributes.nc")
    #         if not os.path.exists(attributes_path):
                logger.warning(f"attributes.nc not found at {attributes_path}")
    #             return

    #         with open(attributes_path, 'r', encoding='utf-8') as f:
    content = f.read()

    #         # Parse attribute blocks
    attribute_pattern = r'attribute\s+(\w+)\s*\{([^}]+)\}'
    matches = re.findall(attribute_pattern, content, re.DOTALL)

    #         for attr_name, attr_content in matches:
    attr_data = self._parse_block_content(attr_content)
    attr_data['id'] = attr_name
    self.attributes[attr_name] = attr_data

    #     def _load_commands(self):
    #         """Parse commands.nc file"""
    commands_path = os.path.join(self.spec_dir, "commands.nc")
    #         if not os.path.exists(commands_path):
                logger.warning(f"commands.nc not found at {commands_path}")
    #             return

    #         with open(commands_path, 'r', encoding='utf-8') as f:
    content = f.read()

    #         # Parse command blocks
    command_pattern = r'command\s+(\w+)\s*\{([^}]+)\}'
    matches = re.findall(command_pattern, content, re.DOTALL)

    #         for cmd_name, cmd_content in matches:
    cmd_data = self._parse_block_content(cmd_content)
    #             # Use the id field from the command, fallback to parsed name
    cmd_id = cmd_data.get('id', f"{cmd_name.replace('_', '.')}")
    cmd_data['name'] = cmd_name
    self.commands[cmd_id] = cmd_data

    #     def _load_sequences(self):
    #         """Parse scenarios.nc file"""
    scenarios_path = os.path.join(self.spec_dir, "scenarios.nc")
    #         if not os.path.exists(scenarios_path):
                logger.warning(f"scenarios.nc not found at {scenarios_path}")
    #             return

    #         with open(scenarios_path, 'r', encoding='utf-8') as f:
    content = f.read()

    #         # Parse sequence blocks
    sequence_pattern = r'sequence\s+(\w+)\s*\{([^}]+)\}'
    matches = re.findall(sequence_pattern, content, re.DOTALL)

    #         for seq_name, seq_content in matches:
    seq_data = self._parse_block_content(seq_content)
    #             # Use the id field from the sequence, fallback to parsed name
    seq_id = seq_data.get('id', f"{seq_name.replace('_', '.')}")
    seq_data['name'] = seq_name
    self.sequences[seq_id] = seq_data

    #     def _load_providers(self):
    #         """Parse providers.nc file"""
    providers_path = os.path.join(self.spec_dir, "providers.nc")
    #         if not os.path.exists(providers_path):
                logger.warning(f"providers.nc not found at {providers_path}")
    #             return

    #         with open(providers_path, 'r', encoding='utf-8') as f:
    content = f.read()

    #         # Parse provider blocks
    provider_pattern = r'provider\s+(\w+)\s*\{([^}]+)\}'
    provider_matches = re.findall(provider_pattern, content, re.DOTALL)

    #         for provider_name, provider_content in provider_matches:
    provider_data = self._parse_block_content(provider_content)
    provider_data['id'] = provider_data.get('id', provider_name)
    self.providers[provider_data['id']] = provider_data

    #         # Parse role blocks
    role_pattern = r'role\s+(\w+)\s*\{([^}]+)\}'
    role_matches = re.findall(role_pattern, content, re.DOTALL)

    #         for role_name, role_content in role_matches:
    role_data = self._parse_block_content(role_content)
    role_data['id'] = role_data.get('id', role_name)
    self.roles[role_data['id']] = role_data

    #     def _parse_block_content(self, content: str) -> Dict[str, Any]:
    #         """Parse key-value content from .nc blocks"""
    data = {}

    #         # Parse simple key: value pairs
    simple_pattern = r'(\w+):\s*"([^"]+)"'
    #         for key, value in re.findall(simple_pattern, content):
    data[key] = value

    #         # Parse boolean values
    bool_pattern = r'(\w+):\s*(true|false)'
    #         for key, value in re.findall(bool_pattern, content):
    data[key] = value == 'true'

    #         # Parse number values
    number_pattern = r'(\w+):\s*(\d+)'
    #         for key, value in re.findall(number_pattern, content):
    data[key] = int(value)

            # Parse nested blocks (inputs, outputs, capabilities)
    nested_pattern = r'(\w+)\s*\{([^}]+)\}'
    #         for key, nested_content in re.findall(nested_pattern, content, re.DOTALL):
    data[key] = self._parse_block_content(nested_content)

    #         return data

    #     def _register_handlers(self):
    #         """Register Python handler functions for commands"""
    #         # Import handler modules
    #         try:
    #             from . import engine
    #             from . import git_tools
    #             from . import quality
    #             from . import ai_client

    #             # Initialize AI client if providers are available
    #             if self.providers:
    self.ai_client = ai_client.NoodleCoreAIClient(self.providers, self.roles)

    #             # Register handlers mapping
    self.handlers = {
    #                 "intellisense_suggest_handler": engine.handle_intellisense_suggest,
    #                 "debug_suggest_breakpoints_handler": engine.handle_debug_suggest_breakpoints,
    #                 "git_status_handler": git_tools.get_git_status,
    #                 "git_recent_commits_handler": git_tools.get_recent_commits,
    #                 "git_diff_summary_handler": git_tools.get_diff_summary,
    #                 "quality_lint_current_file_handler": quality.lint_current_file,
    #                 "quality_discover_tests_handler": quality.discover_tests,
    #                 "ai_explain_current_file_handler": self._handle_ai_explain_current_file,
    #                 "ai_code_review_handler": self._handle_ai_code_review,
    #                 "ai_generate_test_handler": self._handle_ai_generate_test,
    #                 "ai_optimize_code_handler": self._handle_ai_optimize_code
    #             }
    #         except ImportError as e:
                logger.error(f"Failed to import handler modules: {e}")

    #     def get_command(self, command_id: str) -> Optional[Dict[str, Any]]:
    #         """Get command definition by ID"""
            return self.commands.get(command_id)

    #     def get_sequence(self, sequence_id: str) -> Optional[Dict[str, Any]]:
    #         """Get sequence definition by ID"""
            return self.sequences.get(sequence_id)

    #     def is_feature_enabled(self, feature_id: str) -> bool:
    #         """Check if a feature attribute is enabled"""
    attribute = self.attributes.get(feature_id)
    #         if not attribute:
    #             return False
            return attribute.get('enabled', False)

    #     def execute(self, command_id: str, context: Dict[str, Any]) -> Dict[str, Any]:
    #         """Execute a command with given context"""
    #         if not self._loaded:
    #             return {
    #                 "ok": False,
    #                 "error": "NoodleCore runtime not loaded",
    #                 "data": None
    #             }

    #         # Get command definition
    command = self.get_command(command_id)
    #         if not command:
    #             return {
    #                 "ok": False,
    #                 "error": f"Command '{command_id}' not found",
    #                 "data": None
    #             }

    #         # Check if feature is enabled
    feature_id = command.get('feature')
    #         if feature_id and not self.is_feature_enabled(feature_id):
    #             return {
    #                 "ok": False,
    #                 "error": f"Feature '{feature_id}' is disabled",
    #                 "data": None
    #             }

    #         # Check if this is an AI command
    command_type = command.get('type')
    #         if command_type == 'ai':
                return self._execute_ai_command(command_id, command, context)

    #         # Get handler
    handler_name = command.get('handler')
    #         if not handler_name or handler_name not in self.handlers:
    #             return {
    #                 "ok": False,
    #                 "error": f"Handler '{handler_name}' not found",
    #                 "data": None
    #             }

    #         try:
    #             # Execute handler
    handler = self.handlers[handler_name]
    result = handler(context)

    #             return {
    #                 "ok": True,
    #                 "data": result,
    #                 "error": None
    #             }
    #         except Exception as e:
                logger.error(f"Error executing command '{command_id}': {e}")
    #             return {
    #                 "ok": False,
                    "error": str(e),
    #                 "data": None
    #             }

    #     def _execute_ai_command(self, command_id: str, command: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
    #         """Execute AI command using AI client"""
    #         if not self.ai_client:
    #             return {
    #                 "ok": False,
    #                 "error": "AI client not initialized - no providers configured",
    #                 "data": None
    #             }

    #         try:
    #             # Get provider and role from context or use defaults
    provider_id = context.get('provider_id')
    role_id = context.get('role_id')

    #             # Call AI client
    ai_result = self.ai_client.invoke(command_id, context, provider_id, role_id)

    #             if ai_result.get('ok', False):
    #                 # Parse AI response based on command type
    parsed_result = self._parse_ai_response(command_id, ai_result.get('content', ''))
    #                 return {
    #                     "ok": True,
    #                     "data": parsed_result,
    #                     "error": None
    #                 }
    #             else:
    #                 return {
    #                     "ok": False,
                        "error": ai_result.get('error', 'Unknown AI error'),
    #                     "data": None
    #                 }

    #         except Exception as e:
                logger.error(f"Error executing AI command '{command_id}': {e}")
    #             return {
    #                 "ok": False,
                    "error": str(e),
    #                 "data": None
    #             }

    #     def _parse_ai_response(self, command_id: str, content: str) -> Dict[str, Any]:
    #         """Parse AI response based on command type"""
    #         if command_id == "ai.explain_current_file":
    #             return {
    #                 "explanation": content,
    #                 "suggestions": []
    #             }
    #         elif command_id == "ai.code_review":
    #             return {
    #                 "review": content,
    #                 "issues": [],
    #                 "suggestions": []
    #             }
    #         elif command_id == "ai.generate_test":
    #             return {
    #                 "test_code": content,
    #                 "explanation": ""
    #             }
    #         elif command_id == "ai.optimize_code":
    #             return {
    #                 "optimized_code": content,
    #                 "explanation": ""
    #             }
    #         else:
    #             return {
    #                 "content": content
    #             }

    #     def _handle_ai_explain_current_file(self, context: Dict[str, Any]) -> Dict[str, Any]:
    #         """Handler for AI explain current file command"""
            return self._execute_ai_command("ai.explain_current_file", self.get_command("ai.explain_current_file"), context)

    #     def _handle_ai_code_review(self, context: Dict[str, Any]) -> Dict[str, Any]:
    #         """Handler for AI code review command"""
            return self._execute_ai_command("ai.code_review", self.get_command("ai.code_review"), context)

    #     def _handle_ai_generate_test(self, context: Dict[str, Any]) -> Dict[str, Any]:
    #         """Handler for AI generate test command"""
            return self._execute_ai_command("ai.generate_test", self.get_command("ai.generate_test"), context)

    #     def _handle_ai_optimize_code(self, context: Dict[str, Any]) -> Dict[str, Any]:
    #         """Handler for AI optimize code command"""
            return self._execute_ai_command("ai.optimize_code", self.get_command("ai.optimize_code"), context)

    #     def execute_sequence(self, sequence_id: str, context: Dict[str, Any]) -> Dict[str, Any]:
    #         """Execute a sequence of commands with given context"""
    #         if not self._loaded:
    #             return {
    #                 "ok": False,
    #                 "error": "NoodleCore runtime not loaded",
    #                 "results": []
    #             }

    #         # Get sequence definition
    sequence = self.get_sequence(sequence_id)
    #         if not sequence:
    #             return {
    #                 "ok": False,
    #                 "error": f"Sequence '{sequence_id}' not found",
    #                 "results": []
    #             }

    #         # Get command list
    commands = sequence.get('commands', [])
    #         if not commands:
    #             return {
    #                 "ok": False,
    #                 "error": f"Sequence '{sequence_id}' has no commands defined",
    #                 "results": []
    #             }

    results = []
    sequence_ok = True

    #         # Execute each command in sequence
    #         for command_id in commands:
    #             try:
    result = self.execute(command_id, context)
    step_result = {
    #                     "command": command_id,
                        "ok": result.get("ok", False),
                        "data": result.get("data"),
                        "error": result.get("error")
    #                 }
                    results.append(step_result)

    #                 # If any step fails, mark sequence as failed but continue
    #                 if not result.get("ok", False):
    sequence_ok = False

    #             except Exception as e:
                    logger.error(f"Error executing command '{command_id}' in sequence '{sequence_id}': {e}")
    step_result = {
    #                     "command": command_id,
    #                     "ok": False,
    #                     "data": None,
                        "error": str(e)
    #                 }
                    results.append(step_result)
    sequence_ok = False

    #         return {
    #             "ok": sequence_ok,
    #             "results": results,
    #             "error": None if sequence_ok else f"One or more commands in sequence '{sequence_id}' failed"
    #         }

    #     def _validate_loaded_specs(self):
            """Validate loaded specs and log errors/warnings (fail-soft)"""
    #         try:
    #             from . import spec_validator

    #             # Prepare specs data for validation
    specs = {
    #                 'attributes': self.attributes,
    #                 'commands': self.commands,
    #                 'sequences': self.sequences,
    #                 'providers': self.providers,
    #                 'roles': self.roles
    #             }

    result = spec_validator.validate_specs(specs)

    #             if not result['ok']:
                    logger.error("NoodleCore spec validation failed:")
    #                 for error in result['errors']:
                        logger.error(f"  - {error}")

    #             if result['warnings']:
                    logger.warning("NoodleCore spec validation warnings:")
    #                 for warning in result['warnings']:
                        logger.warning(f"  - {warning}")

    #         except ImportError:
                logger.warning("spec_validator module not available - skipping validation")
    #         except Exception as e:
                logger.error(f"Error during spec validation: {e}")