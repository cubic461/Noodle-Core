# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Debugger AI Agent
# Specialized in error diagnosis, troubleshooting, and debugging assistance
# """

import typing.Dict,
import .base_agent.BaseAIAgent


class DebuggerAgent(BaseAIAgent)
    #     """AI Agent specialized in debugging and troubleshooting."""

    #     def __init__(self):
            super().__init__(
    name = "debugger",
    description = "Expert in error diagnosis, debugging, and troubleshooting code issues",
    capabilities = [
    #                 "Debug runtime errors",
    #                 "Analyze error messages and stack traces",
    #                 "Identify code smells and potential issues",
    #                 "Suggest debugging strategies",
    #                 "Performance debugging and optimization"
    #             ]
    #         )

    #     def get_system_prompt(self) -> str:
    #         return """You are a specialized debugging AI agent. Your expertise includes:

## CORE RESPONSIBILITIES:
# - Diagnose runtime errors and exceptions
# - Analyze error messages, stack traces, and logs
# - Identify bugs, code smells, and potential issues
# - Provide step-by-step debugging strategies
# - Suggest performance optimization opportunities

## DEBUGGING APPROACH:
# 1. **Error Analysis**: Examine error messages, stack traces, and context
# 2. **Root Cause Identification**: Find the underlying cause, not just symptoms
# 3. **Solution Strategy**: Provide clear, actionable debugging steps
# 4. **Prevention**: Suggest how to avoid similar issues in the future
# 5. **Testing**: Recommend test cases to verify fixes

## SPECIALIZATIONS:
# - Runtime exceptions and error handling
# - Logic errors and edge cases
# - Performance bottlenecks and optimization
# - Memory leaks and resource management
# - Multi-threading and concurrency issues
# - Database query optimization
# - API integration debugging
# - Environment and configuration issues

## DEBUGGING TECHNIQUES:
# - Systematic error reproduction
# - Log analysis and pattern recognition
# - Code inspection and static analysis
# - Performance profiling and measurement
# - Unit test design for bug isolation
# - Interactive debugging techniques

# Always provide specific, actionable debugging advice with clear steps to reproduce and fix issues. When asking about errors, include relevant code context and error messages."""

#     def enhance_message(self, message: str, context: Dict[str, Any]) -> str:
enhanced_parts = [message]

#         # Add error context if available
#         if context.get('error_message'):
            enhanced_parts.insert(0, f"ERROR CONTEXT:\n{context['error_message']}\n\n")

#         if context.get('stack_trace'):
            enhanced_parts.insert(0, f"STACK TRACE:\n{context['stack_trace']}\n\n")

#         if context.get('current_file') and context.get('file_content'):
content = context['file_content'][:800]  # Limit content
            enhanced_parts.insert(0, f"CODE CONTEXT:\nFile: {context['current_file']}\n```\n{content}\n```\n\n")

        return "".join(enhanced_parts)

#     def get_quick_actions(self) -> List[Dict[str, str]]:
#         return [
#             {
#                 'text': 'Debug Error',
#                 'command': 'Debug the current error with detailed analysis',
#                 'color': '#f44336'
#             },
#             {
#                 'text': 'Analyze Performance',
#                 'command': 'Analyze code performance and suggest optimizations',
#                 'color': '#FF9800'
#             },
#             {
#                 'text': 'Find Bugs',
#                 'command': 'Scan code for potential bugs and issues',
#                 'color': '#9C27B0'
#             },
#             {
#                 'text': 'Test Strategy',
#                 'command': 'Create a testing strategy to isolate the issue',
#                 'color': '#2196F3'
#             }
#         ]