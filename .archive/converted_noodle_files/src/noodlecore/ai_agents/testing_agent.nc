# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Testing AI Agent
# Specialized in test creation, code validation, and testing strategies
# """

import typing.Dict,
import .base_agent.BaseAIAgent


class TestingAgent(BaseAIAgent)
    #     """AI Agent specialized in testing and code validation."""

    #     def __init__(self):
            super().__init__(
    name = "tester",
    description = "Expert in test creation, code validation, and comprehensive testing strategies",
    capabilities = [
    #                 "Generate unit tests",
    #                 "Create integration tests",
    #                 "Design test strategies",
    #                 "Validate test coverage",
    #                 "Performance testing"
    #             ]
    #         )

    #     def get_system_prompt(self) -> str:
    #         return """You are a specialized testing AI agent. Your expertise includes:

## CORE RESPONSIBILITIES:
# - Generate comprehensive unit and integration tests
# - Design effective testing strategies and methodologies
# - Validate test coverage and identify gaps
# - Create test cases for edge cases and error conditions
# - Implement performance and load testing approaches

## TESTING PRINCIPLES:
# 1. **Test Coverage**: Aim for 80%+ code coverage for core business logic
# 2. **Test Isolation**: Each test should be independent and repeatable
# 3. **Test Clarity**: Tests should be readable and self-documenting
# 4. **Test Reliability**: Tests should consistently pass/fail appropriately
# 5. **Edge Cases**: Include boundary conditions and error scenarios

## TESTING FRAMEWORKS & TOOLS:
# - **Unit Testing**: pytest 7.0+, unittest, pytest-mock for mocking
# - **Integration Testing**: Test databases, API testing, end-to-end tests
# - **Performance Testing**: Load testing, memory profiling, benchmark tests
- **Test Data**: Factory patterns, fixtures, test databases (SQLite in-memory)
# - **Coverage Tools**: Coverage.py, pytest-cov for analysis

## TEST PATTERNS:
- Arrange-Act-Assert (AAA) pattern
- Given-When-Then (BDD) style
# - Mock and stub strategies
# - Test doubles and fixtures
# - Parameterized tests for multiple scenarios

## SPECIALIZATIONS:
# - NoodleCore-specific testing patterns
# - Database testing with proper cleanup
# - API endpoint testing
# - File I/O testing strategies
# - Multi-threaded code testing
# - Performance regression testing

# Always provide complete, runnable test code that follows testing best practices. Include both positive and negative test cases."""

#     def enhance_message(self, message: str, context: Dict[str, Any]) -> str:
enhanced_parts = [message]

#         # Add code context for testing
#         if context.get('current_file') and context.get('file_content'):
content = context['file_content'][:1000]  # Limit content
            enhanced_parts.insert(0, f"CODE TO TEST:\nFile: {context['current_file']}\n```\n{content}\n```\n\n")

#         if context.get('function_signature'):
            enhanced_parts.insert(0, f"TARGET FUNCTION: {context['function_signature']}\n\n")

        return "".join(enhanced_parts)

#     def get_quick_actions(self) -> List[Dict[str, str]]:
#         return [
#             {
#                 'text': 'Unit Tests',
#                 'command': 'Generate comprehensive unit tests for the current code',
#                 'color': '#4CAF50'
#             },
#             {
#                 'text': 'Integration Tests',
#                 'command': 'Create integration tests for system components',
#                 'color': '#2196F3'
#             },
#             {
#                 'text': 'Edge Cases',
#                 'command': 'Generate tests for edge cases and error conditions',
#                 'color': '#FF9800'
#             },
#             {
#                 'text': 'Test Strategy',
#                 'command': 'Design a comprehensive testing strategy',
#                 'color': '#9C27B0'
#             }
#         ]