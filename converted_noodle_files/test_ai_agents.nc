# Converted from Python to NoodleCore
# Original file: noodle-core

# NoodleCore converted from Python
# """Test script for AI agent infrastructure"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

function test_ai_agents()
        print("🔍 TESTING AI AGENT INFRASTRUCTURE")
    print(" = " * 40)

    #     # Test 1: Basic agent imports
        print("\n📦 Testing AI agent imports...")
    #     try:
    #         from noodlecore.ai_agents.base_agent import BaseAIAgent, AIAgentManager
            print("✅ BaseAIAgent import: SUCCESS")

    #         from noodlecore.ai_agents.agent_registry import AgentRegistry, get_agent_registry
            print("✅ AgentRegistry import: SUCCESS")

    #         from noodlecore.ai_agents.code_review_agent import CodeReviewAgent
            print("✅ CodeReviewAgent import: SUCCESS")

    #         from noodlecore.ai_agents.debugger_agent import DebuggerAgent
            print("✅ DebuggerAgent import: SUCCESS")

    #         from noodlecore.ai_agents.testing_agent import TestingAgent
            print("✅ TestingAgent import: SUCCESS")

    #         from noodlecore.ai_agents.documentation_agent import DocumentationAgent
            print("✅ DocumentationAgent import: SUCCESS")

    #         from noodlecore.ai_agents.refactoring_agent import RefactoringAgent
            print("✅ RefactoringAgent import: SUCCESS")

    #         from noodlecore.ai_agents.noodlecore_writer_agent import NoodleCoreWriterAgent
            print("✅ NoodleCoreWriterAgent import: SUCCESS")

    #         from noodlecore.ai_agents import create_agent_manager, list_available_agents
            print("✅ AI agents module functions: SUCCESS")

            print("✅ All AI agent imports successful")

    #     except Exception as e:
            print(f"❌ AI agent imports failed: {e}")
    #         import traceback
            print(f"❌ Traceback: {traceback.format_exc()}")

    #     # Test 2: Agent instantiation
        print("\n🧪 Testing AI agent instantiation...")
    #     try:
    #         # Test agent creation
    code_review_agent = CodeReviewAgent()
            print("✅ CodeReviewAgent instantiation: SUCCESS")

    debugger_agent = DebuggerAgent()
            print("✅ DebuggerAgent instantiation: SUCCESS")

    testing_agent = TestingAgent()
            print("✅ TestingAgent instantiation: SUCCESS")

    documentation_agent = DocumentationAgent()
            print("✅ DocumentationAgent instantiation: SUCCESS")

    refactoring_agent = RefactoringAgent()
            print("✅ RefactoringAgent instantiation: SUCCESS")

    noodlecore_writer_agent = NoodleCoreWriterAgent()
            print("✅ NoodleCoreWriterAgent instantiation: SUCCESS")

    #         # Test agent manager
    manager = create_agent_manager()
            print("✅ Agent manager creation: SUCCESS")

    agents_list = list_available_agents(manager)
            print(f"✅ Available agents: {len(agents_list)}")

            print("✅ All AI agent instantiation tests passed")

    #     except Exception as e:
            print(f"❌ AI agent instantiation failed: {e}")
    #         import traceback
            print(f"❌ Traceback: {traceback.format_exc()}")

    #     # Test 3: Agent registry
        print("\n🗂️ Testing agent registry...")
    #     try:
    registry = get_agent_registry()
            print("✅ Agent registry creation: SUCCESS")

    #         # Test listing
    agents = registry.list_agents()
            print(f"✅ Agent listing: {len(agents)} agents")

    #         # Test stats
    stats = registry.get_registry_stats()
            print(f"✅ Registry stats: {stats['total_agents']} total agents")

            print("✅ All agent registry tests passed")

    #     except Exception as e:
            print(f"❌ Agent registry tests failed: {e}")
    #         import traceback
            print(f"❌ Traceback: {traceback.format_exc()}")

    #     # Test 4: Role manager
        print("\n👥 Testing role manager...")
    #     try:
    #         from noodlecore.ai.role_manager import get_role_manager, AIRoleManager
            print("✅ Role manager import: SUCCESS")

    role_manager = get_role_manager()
            print("✅ Role manager instantiation: SUCCESS")

    #         # Test role creation
    roles = role_manager.get_all_roles()
            print(f"✅ Role listing: {len(roles)} roles")

    #         # Test role categories
    categories = role_manager.get_role_categories()
            print(f"✅ Role categories: {len(categories)} categories")

            print("✅ All role manager tests passed")

    #     except Exception as e:
            print(f"❌ Role manager tests failed: {e}")
    #         import traceback
            print(f"❌ Traceback: {traceback.format_exc()}")

        print("\n🎯 AI AGENT INFRASTRUCTURE TEST COMPLETE")
    print(" = " * 40)

if __name__ == "__main__"
        test_ai_agents()