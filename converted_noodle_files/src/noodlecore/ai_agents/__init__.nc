# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# NoodleCore AI Agents Module
# Provides specialized AI agents for different development tasks
# """

import .base_agent.BaseAIAgent,
import .agent_registry.(
#     AgentRegistry, AgentStatus, AgentRole, AgentMetadata,
#     AgentConfig, get_agent_registry, create_agent_manager_from_registry
# )
import .noodlecore_writer_agent.NoodleCoreWriterAgent
import .debugger_agent.DebuggerAgent
import .testing_agent.TestingAgent
import .documentation_agent.DocumentationAgent
import .refactoring_agent.RefactoringAgent
import .code_review_agent.CodeReviewAgent


function create_agent_manager()
    #     """Create and populate an AI agent manager with all available agents."""
    manager = AIAgentManager()

    #     # Register all available agents
    agents = [
            NoodleCoreWriterAgent(),
            DebuggerAgent(),
            TestingAgent(),
            DocumentationAgent(),
            RefactoringAgent(),
            CodeReviewAgent()
    #     ]

    #     for agent in agents:
            manager.register_agent(agent)

    #     return manager


function get_agent_by_name(manager: AIAgentManager, name: str)
    #     """Get a specific agent by name from the manager."""
        return manager.agents.get(name)


function list_available_agents(manager: AIAgentManager)
    #     """List all available agents with their descriptions."""
    #     return [
    #         {
    #             'name': agent.name,
    #             'description': agent.description,
    #             'capabilities': agent.capabilities
    #         }
    #         for agent in manager.agents.values()
    #     ]