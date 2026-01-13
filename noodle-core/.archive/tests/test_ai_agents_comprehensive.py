#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_ai_agents_comprehensive.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Comprehensive AI Agent Infrastructure Test
Tests all components of the AI agent infrastructure to ensure proper integration.
"""

import sys
import traceback
from pathlib import Path

# Add the src directory to the path
sys.path.insert(0, str(Path(__file__).parent / "src"))

def test_ai_agent_infrastructure():
    """Test all components of the AI agent infrastructure."""
    print("ðŸ” COMPREHENSIVE AI AGENT INFRASTRUCTURE TEST")
    print("=" * 60)
    
    test_results = {
        'imports': {'passed': 0, 'failed': 0, 'errors': []},
        'base_agent': {'passed': 0, 'failed': 0, 'errors': []},
        'agent_registry': {'passed': 0, 'failed': 0, 'errors': []},
        'code_review_agent': {'passed': 0, 'failed': 0, 'errors': []},
        'debugger_agent': {'passed': 0, 'failed': 0, 'errors': []},
        'testing_agent': {'passed': 0, 'failed': 0, 'errors': []},
        'documentation_agent': {'passed': 0, 'failed': 0, 'errors': []},
        'refactoring_agent': {'passed': 0, 'failed': 0, 'errors': []},
        'noodlecore_writer_agent': {'passed': 0, 'failed': 0, 'errors': []},
        'agent_manager': {'passed': 0, 'failed': 0, 'errors': []},
        'role_manager': {'passed': 0, 'failed': 0, 'errors': []},
        'integration': {'passed': 0, 'failed': 0, 'errors': []}
    }
    
    # Test 1: Basic imports
    print("\nðŸ“¦ Testing AI Agent Imports...")
    try:
        from noodlecore.ai_agents.base_agent import BaseAIAgent, AIAgentManager
        print("âœ… BaseAIAgent import: SUCCESS")
        test_results['imports']['passed'] += 1
        
        from noodlecore.ai_agents.agent_registry import AgentRegistry, get_agent_registry
        print("âœ… AgentRegistry import: SUCCESS")
        test_results['imports']['passed'] += 1
        
        from noodlecore.ai_agents.code_review_agent import CodeReviewAgent
        print("âœ… CodeReviewAgent import: SUCCESS")
        test_results['imports']['passed'] += 1
        
        from noodlecore.ai_agents.debugger_agent import DebuggerAgent
        print("âœ… DebuggerAgent import: SUCCESS")
        test_results['imports']['passed'] += 1
        
        from noodlecore.ai_agents.testing_agent import TestingAgent
        print("âœ… TestingAgent import: SUCCESS")
        test_results['imports']['passed'] += 1
        
        from noodlecore.ai_agents.documentation_agent import DocumentationAgent
        print("âœ… DocumentationAgent import: SUCCESS")
        test_results['imports']['passed'] += 1
        
        from noodlecore.ai_agents.refactoring_agent import RefactoringAgent
        print("âœ… RefactoringAgent import: SUCCESS")
        test_results['imports']['passed'] += 1
        
        from noodlecore.ai_agents.noodlecore_writer_agent import NoodleCoreWriterAgent
        print("âœ… NoodleCoreWriterAgent import: SUCCESS")
        test_results['imports']['passed'] += 1
        
        from noodlecore.ai_agents import create_agent_manager, list_available_agents
        print("âœ… AI agents module functions: SUCCESS")
        test_results['imports']['passed'] += 1
        
        print(f"âœ… All AI agent imports successful ({test_results['imports']['passed']} components)")
        
    except Exception as e:
        print(f"âŒ AI agent imports failed: {e}")
        test_results['imports']['failed'] += 1
        test_results['imports']['errors'].append(str(e))
        traceback.print_exc()
    
    # Test 2: Agent instantiation
    print("\nðŸ§ª Testing AI Agent Instantiation...")
    try:
        code_review_agent = CodeReviewAgent()
        print("âœ… CodeReviewAgent instantiation: SUCCESS")
        test_results['code_review_agent']['passed'] += 1
        
        debugger_agent = DebuggerAgent()
        print("âœ… DebuggerAgent instantiation: SUCCESS")
        test_results['debugger_agent']['passed'] += 1
        
        testing_agent = TestingAgent()
        print("âœ… TestingAgent instantiation: SUCCESS")
        test_results['testing_agent']['passed'] += 1
        
        documentation_agent = DocumentationAgent()
        print("âœ… DocumentationAgent instantiation: SUCCESS")
        test_results['documentation_agent']['passed'] += 1
        
        refactoring_agent = RefactoringAgent()
        print("âœ… RefactoringAgent instantiation: SUCCESS")
        test_results['refactoring_agent']['passed'] += 1
        
        noodlecore_writer_agent = NoodleCoreWriterAgent()
        print("âœ… NoodleCoreWriterAgent instantiation: SUCCESS")
        test_results['noodlecore_writer_agent']['passed'] += 1
        
        manager = create_agent_manager()
        print("âœ… Agent manager creation: SUCCESS")
        test_results['agent_manager']['passed'] += 1
        
        agents_list = list_available_agents(manager)
        print(f"âœ… Available agents: {len(agents_list)}")
        test_results['agent_manager']['passed'] += 1
        
        print(f"âœ… All AI agent instantiation tests passed ({test_results['agent_manager']['passed']} components)")
        
    except Exception as e:
        print(f"âŒ AI agent instantiation failed: {e}")
        test_results['agent_manager']['failed'] += 1
        test_results['agent_manager']['errors'].append(str(e))
        traceback.print_exc()
    
    # Test 3: Agent registry
    print("\nðŸ—‚ï¸ Testing Agent Registry...")
    try:
        registry = get_agent_registry()
        print("âœ… Agent registry creation: SUCCESS")
        test_results['agent_registry']['passed'] += 1
        
        # Test registration
        agent_id = registry.register_agent(code_review_agent, registry.role_mapping.CODE_REVIEWER)
        print(f"âœ… Agent registration: SUCCESS (ID: {agent_id[:8]}...)")
        test_results['agent_registry']['passed'] += 1
        
        # Test listing
        agents = registry.list_agents()
        print(f"âœ… Agent listing: {len(agents)} agents")
        test_results['agent_registry']['passed'] += 1
        
        # Test stats
        stats = registry.get_registry_stats()
        print(f"âœ… Registry stats: {stats['total_agents']} total agents")
        test_results['agent_registry']['passed'] += 1
        
        print(f"âœ… All agent registry tests passed ({test_results['agent_registry']['passed']} components)")
        
    except Exception as e:
        print(f"âŒ Agent registry tests failed: {e}")
        test_results['agent_registry']['failed'] += 1
        test_results['agent_registry']['errors'].append(str(e))
        traceback.print_exc()
    
    # Test 4: Role manager
    print("\nðŸ‘¥ Testing Role Manager...")
    try:
        from noodlecore.ai.role_manager import get_role_manager, AIRoleManager
        print("âœ… Role manager import: SUCCESS")
        test_results['role_manager']['passed'] += 1
        
        role_manager = get_role_manager()
        print("âœ… Role manager instantiation: SUCCESS")
        test_results['role_manager']['passed'] += 1
        
        # Test role creation
        roles = role_manager.get_all_roles()
        print(f"âœ… Role listing: {len(roles)} roles")
        test_results['role_manager']['passed'] += 1
        
        # Test role categories
        categories = role_manager.get_role_categories()
        print(f"âœ… Role categories: {len(categories)} categories")
        test_results['role_manager']['passed'] += 1
        
        print(f"âœ… All role manager tests passed ({test_results['role_manager']['passed']} components)")
        
    except Exception as e:
        print(f"âŒ Role manager tests failed: {e}")
        test_results['role_manager']['failed'] += 1
        test_results['role_manager']['errors'].append(str(e))
        traceback.print_exc()
    
    # Test 5: Integration test
    print("\nðŸ”— Testing AI Agent Integration...")
    try:
        # Test agent manager with registry
        registry = get_agent_registry()
        manager = create_agent_manager()
        
        # Register an agent
        agent_id = registry.register_agent(code_review_agent, registry.role_mapping.CODE_REVIEWER)
        
        # Test agent functionality
        agent = manager.get_agent("Code Reviewer")
        if agent:
            print("âœ… Agent retrieval from manager: SUCCESS")
            test_results['integration']['passed'] += 1
            
            # Test agent capabilities
            capabilities = agent.get_capabilities()
            if capabilities:
                print(f"âœ… Agent capabilities: {len(capabilities)} capabilities")
                test_results['integration']['passed'] += 1
            
            # Test agent info
            info = agent.get_agent_info()
            if info:
                print("âœ… Agent info retrieval: SUCCESS")
                test_results['integration']['passed'] += 1
        else:
            print("âŒ Agent retrieval from manager: FAILED")
            test_results['integration']['failed'] += 1
            test_results['integration']['errors'].append("Agent retrieval failed")
        
        print(f"âœ… All AI agent integration tests passed ({test_results['integration']['passed']} components)")
        
    except Exception as e:
        print(f"âŒ AI agent integration tests failed: {e}")
        test_results['integration']['failed'] += 1
        test_results['integration']['errors'].append(str(e))
        traceback.print_exc()
    
    # Summary
    print("\nðŸŽ¯ AI AGENT INFRASTRUCTURE TEST SUMMARY")
    print("=" * 60)
    
    total_passed = sum(result['passed'] for result in test_results.values())
    total_failed = sum(result['failed'] for result in test_results.values())
    total_errors = sum(len(result['errors']) for result in test_results.values())
    
    print(f"Total tests passed: {total_passed}")
    print(f"Total tests failed: {total_failed}")
    print(f"Total errors: {total_errors}")
    
    if total_failed == 0 and total_errors == 0:
        print("ðŸŽ‰ ALL TESTS PASSED - AI Agent Infrastructure is fully functional!")
        return True
    else:
        print("âš ï¸ SOME TESTS FAILED - Check errors above for details")
        return False

if __name__ == "__main__":
    success = test_ai_agent_infrastructure()
    sys.exit(0 if success else 1)

