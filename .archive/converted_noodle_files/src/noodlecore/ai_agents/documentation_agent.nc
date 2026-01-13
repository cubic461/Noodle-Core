# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Documentation AI Agent
# Specialized in creating clear documentation, comments, and code explanations
# """

import typing.Dict,
import .base_agent.BaseAIAgent


class DocumentationAgent(BaseAIAgent)
    #     """AI Agent specialized in documentation and code explanations."""

    #     def __init__(self):
            super().__init__(
    name = "documentation",
    description = "Expert in creating clear documentation, comments, and code explanations",
    capabilities = [
    #                 "Generate code documentation",
    #                 "Create API documentation",
    #                 "Write inline comments",
    #                 "Explain complex code",
    #                 "Create user guides and tutorials"
    #             ]
    #         )

    #     def get_system_prompt(self) -> str:
    #         return """You are a specialized documentation AI agent. Your expertise includes:

## CORE RESPONSIBILITIES:
# - Generate comprehensive code documentation
# - Create clear inline comments and docstrings
# - Write API documentation and user guides
# - Explain complex code logic and algorithms
# - Create tutorials and getting-started guides

## DOCUMENTATION PRINCIPLES:
# 1. **Clarity**: Use simple, clear language that anyone can understand
# 2. **Completeness**: Document purpose, parameters, return values, and examples
# 3. **Consistency**: Follow consistent documentation patterns and formatting
# 4. **Accessibility**: Write for both technical and non-technical audiences
# 5. **Actionability**: Include practical examples and use cases

## DOCUMENTATION TYPES:
# - **Code Comments**: Inline explanations for complex logic
# - **Docstrings**: Function/class documentation (Google, NumPy, or Sphinx style)
# - **API Documentation**: Endpoint specifications, parameters, responses
# - **README Files**: Project overviews, installation, usage examples
# - **User Guides**: Step-by-step instructions for end users
# - **Technical Specs**: Architecture and design documentation

## DOCUMENTATION FORMATS:
# - **Markdown**: For README files, guides, and documentation
# - **Docstrings**: For Python functions and classes
# - **Inline Comments**: For complex business logic
# - **API Specs**: OpenAPI/Swagger format for REST APIs
# - **JSDoc**: For JavaScript code documentation

## SPECIALIZATIONS:
# - NoodleCore-specific documentation patterns
# - Code explanation for complex algorithms
# - Migration guides and changelogs
# - Architecture documentation
# - Integration guides and examples

# Always provide complete, well-formatted documentation that follows industry standards and best practices."""

#     def enhance_message(self, message: str, context: Dict[str, Any]) -> str:
enhanced_parts = [message]

#         # Add code context for documentation
#         if context.get('current_file') and context.get('file_content'):
content = context['file_content'][:1000]  # Limit content
            enhanced_parts.insert(0, f"CODE TO DOCUMENT:\nFile: {context['current_file']}\n```\n{content}\n```\n\n")

#         if context.get('function_signatures'):
            enhanced_parts.insert(0, f"FUNCTIONS TO DOCUMENT:\n{context['function_signatures']}\n\n")

        return "".join(enhanced_parts)

#     def get_quick_actions(self) -> List[Dict[str, str]]:
#         return [
#             {
#                 'text': 'Add Comments',
#                 'command': 'Add clear inline comments to explain complex code',
#                 'color': '#4CAF50'
#             },
#             {
#                 'text': 'Generate Docstring',
#                 'command': 'Create comprehensive docstrings for functions and classes',
#                 'color': '#2196F3'
#             },
#             {
#                 'text': 'Explain Code',
#                 'command': 'Provide detailed explanation of how the code works',
#                 'color': '#FF9800'
#             },
#             {
#                 'text': 'Create Guide',
#                 'command': 'Create a user guide or tutorial for the current code',
#                 'color': '#9C27B0'
#             }
#         ]