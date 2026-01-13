# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# NoodleCore Code Writer Agent
# Specialized in writing NoodleCore-specific code with patterns and best practices
# """

import typing.Dict,
import .base_agent.BaseAIAgent


class NoodleCoreWriterAgent(BaseAIAgent)
    #     """AI Agent specialized in writing NoodleCore code."""

    #     def __init__(self):
            super().__init__(
    name = "noodlecore_writer",
    #             description="Specialized in writing NoodleCore code with proper patterns and best practices",
    capabilities = [
    #                 "Generate NoodleCore code",
    #                 "Apply NoodleCore coding standards",
    #                 "Create NoodleCore modules",
    #                 "Implement NoodleCore patterns",
    #                 "Code conversion to NoodleCore"
    #             ]
    #         )

    #     def get_system_prompt(self) -> str:
    #         return """You are a specialized NoodleCore code writer AI agent. Your expertise includes:

## CORE RESPONSIBILITIES:
# - Write high-quality NoodleCore code following NoodleCore standards
# - Generate NoodleCore modules, functions, and classes
# - Apply NoodleCore-specific patterns and best practices
# - Convert code between NoodleCore and other languages
# - Ensure NoodleCore coding conventions are followed

## NOODLECORE CODING STANDARDS:
# - Use snake_case for function and variable names
# - Use PascalCase for class names
# - Use UPPER_SNAKE_CASE for constants
- Follow NoodleCore file organization (core modules in noodle-core/src/noodlecore/)
# - Use proper error handling with try-catch blocks
# - Implement logging with DEBUG, INFO, ERROR, WARNING levels
# - Use environment variables with NOODLE_ prefix
- Follow NoodleCore API patterns (port 8080, requestId UUID format)

## CODE PATTERNS:
# - Database operations: Use psycopg2-binary 2.9.0, max 20 connections, 30s timeout
# - API development: HTTP server on 0.0.0.0:8080, RESTful paths, 30s request timeout
# - Performance: API response < 500ms, database query < 3s, memory < 2GB
# - Security: HTML escaping, encrypted storage, environment variables for secrets
# - Testing: pytest 7.0+, 80% coverage, test_*.py naming

## SPECIALIZATIONS:
# - NoodleCore compiler and parser development
# - NoodleCore runtime integration
# - NoodleCore module system
# - NoodleCore deployment and configuration
# - Cross-language code conversion to NoodleCore

# Always prioritize NoodleCore-specific solutions and patterns. When asked to write code, generate production-ready NoodleCore code that follows all established standards."""

#     def enhance_message(self, message: str, context: Dict[str, Any]) -> str:
enhanced_parts = [message]

#         # Add NoodleCore context if available
#         if context.get('current_file'):
file_path = context['current_file']
#             if file_path and str(file_path).endswith('.nc'):
                enhanced_parts.insert(0, f"Context: I'm working on a NoodleCore file called '{file_path}'. ")

#         if context.get('file_content'):
content = context['file_content'][:1000]  # Limit content
            enhanced_parts.insert(0, f"NoodleCore file content:\n```nc\n{content}\n```\n\n")

#         if context.get('project_path'):
            enhanced_parts.insert(0, f"Project context: Working in NoodleCore project at {context['project_path']}. ")

        return "".join(enhanced_parts)

#     def get_quick_actions(self) -> List[Dict[str, str]]:
#         return [
#             {
#                 'text': 'Generate Function',
#                 'command': 'Create a NoodleCore function following best practices',
#                 'color': '#4CAF50'
#             },
#             {
#                 'text': 'Create Module',
#                 'command': 'Generate a new NoodleCore module with proper structure',
#                 'color': '#2196F3'
#             },
#             {
#                 'text': 'Apply Patterns',
#                 'command': 'Apply NoodleCore design patterns to the current code',
#                 'color': '#FF9800'
#             },
#             {
#                 'text': 'Convert Code',
#                 'command': 'Convert code from other languages to NoodleCore',
#                 'color': '#9C27B0'
#             }
#         ]