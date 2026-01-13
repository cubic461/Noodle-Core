#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_ai_agents.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""Test script for AI agent infrastructure"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

def test_ai_agents():
    print("ðŸ” TESTING AI AGENT INFRASTRUCTURE")
    print("=" * 40)
    
    # Test 1: Basic agent imports
    print("\nðŸ“¦ Testing AI agent imports...")
    try:
        from noodlecore.ai_agents.base_agent import BaseAIAgent, AIAgentManager
        print("âœ… BaseAIAgent import: SUCCESS")
        
        from noodlecore.ai_agents.agent_registry import AgentRegistry, get_agent_registry
        print("âœ… AgentRegistry import: SUCCESS")
        
        from noodlecore.ai_agents.code_review_agent import CodeReviewAgent
        print("âœ… CodeReviewAgent import: SUCCESS")
        
        from noodlecore.ai_agents.debugger_agent import DebuggerAgent
        print("âœ… DebuggerAgent import: SUCCESS")
        
        from noodlecore.ai_agents.testing_agent import TestingAgent
        print("âœ… TestingAgent import: SUCCESS")
        
        from noodlecore.ai_agents.documentation_agent import DocumentationAgent
        print("âœ… DocumentationAgent import: SUCCESS")
        
        from noodlecore.ai_agents.refactoring_agent import RefactoringAgent
        print("âœ… RefactoringAgent import: SUCCESS")
        
        from noodlecore.ai_agents.noodlecore_writer_agent import NoodleCoreWriterAgent
        print("âœ… NoodleCoreWriterAgent import: SUCCESS")
        
        from noodlecore.ai_agents import create_agent_manager, list_available_agents
        print("âœ… AI agents module functions: SUCCESS")
        
        print("âœ… All AI agent imports successful")
        
    except Exception as e:
        print(f"âŒ AI agent imports failed: {e}")
        import traceback
        print(f"âŒ Traceback: {traceback.format_exc()}")
    
    # Test 2: Agent instantiation
    print("\nðŸ§ª Testing AI agent instantiation...")
    try:
        # Test agent creation
        code_review_agent = CodeReviewAgent()
        print("âœ… CodeReviewAgent instantiation: SUCCESS")
        
        debugger_agent = DebuggerAgent()
        print("âœ… DebuggerAgent instantiation: SUCCESS")
        
        testing_agent = TestingAgent()
        print("âœ… TestingAgent instantiation: SUCCESS")
        
        documentation_agent = DocumentationAgent()
        print("âœ… DocumentationAgent instantiation: SUCCESS")
        
        refactoring_agent = RefactoringAgent()
        print("âœ… RefactoringAgent instantiation: SUCCESS")
        
        noodlecore_writer_agent = NoodleCoreWriterAgent()
        print("âœ… NoodleCoreWriterAgent instantiation: SUCCESS")
        
        # Test agent manager
        manager = create_agent_manager()
        print("âœ… Agent manager creation: SUCCESS")
        
        agents_list = list_available_agents(manager)
        print(f"âœ… Available agents: {len(agents_list)}")
        
        print("âœ… All AI agent instantiation tests passed")
        
    except Exception as e:
        print(f"âŒ AI agent instantiation failed: {e}")
        import traceback
        print(f"âŒ Traceback: {traceback.format_exc()}")
    
    # Test 3: Agent registry
    print("\nðŸ—‚ï¸ Testing agent registry...")
    try:
        registry = get_agent_registry()
        print("âœ… Agent registry creation: SUCCESS")
        
        # Test listing
        agents = registry.list_agents()
        print(f"âœ… Agent listing: {len(agents)} agents")
        
        # Test stats
        stats = registry.get_registry_stats()
        print(f"âœ… Registry stats: {stats['total_agents']} total agents")
        
        print("âœ… All agent registry tests passed")
        
    except Exception as e:
        print(f"âŒ Agent registry tests failed: {e}")
        import traceback
        print(f"âŒ Traceback: {traceback.format_exc()}")
    
    # Test 4: Role manager
    print("\nðŸ‘¥ Testing role manager...")
    try:
        from noodlecore.ai.role_manager import get_role_manager, AIRoleManager
        print("âœ… Role manager import: SUCCESS")
        
        role_manager = get_role_manager()
        print("âœ… Role manager instantiation: SUCCESS")
        
        # Test role creation
        roles = role_manager.get_all_roles()
        print(f"âœ… Role listing: {len(roles)} roles")
        
        # Test role categories
        categories = role_manager.get_role_categories()
        print(f"âœ… Role categories: {len(categories)} categories")
        
        print("âœ… All role manager tests passed")
        
    except Exception as e:
        print(f"âŒ Role manager tests failed: {e}")
        import traceback
        print(f"âŒ Traceback: {traceback.format_exc()}")

    print("\nðŸŽ¯ AI AGENT INFRASTRUCTURE TEST COMPLETE")
    print("=" * 40)

if __name__ == "__main__":
    test_ai_agents()

