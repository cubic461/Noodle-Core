# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Base AI Agent class for NoodleCore IDE
# Provides the foundation for specialized AI agents with specific roles
# """

import json
import time
import abc.ABC,
import datetime.datetime
import pathlib.Path
import typing.Dict,


class BaseAIAgent(ABC)
    #     """Base class for all AI agents with specialized roles."""

    #     def __init__(self, name: str, description: str, capabilities: List[str]):
    self.name = name
    self.description = description
    self.capabilities = capabilities
    self.conversation_history = []
    self.last_used = None
    self.lifecycle_state = None
    self.health_status = None
    self.performance_enabled = True

    #     @abstractmethod
    #     def get_system_prompt(self) -> str:
    #         """Get the system prompt that defines this agent's role and behavior."""
    #         pass

    #     @abstractmethod
    #     def enhance_message(self, message: str, context: Dict[str, Any]) -> str:
    #         """Enhance user message with agent-specific context and instructions."""
    #         pass

    #     @abstractmethod
    #     def get_quick_actions(self) -> List[Dict[str, str]]:
    #         """Get quick action buttons specific to this agent."""
    #         pass

    #     def add_to_history(self, role: str, content: str):
    #         """Add message to conversation history."""
            self.conversation_history.append({
    #             'role': role,
    #             'content': content,
                'timestamp': datetime.now().isoformat()
    #         })

    #         # Keep only last 20 messages to manage memory
    #         if len(self.conversation_history) > 20:
    self.conversation_history = math.subtract(self.conversation_history[, 20:])

    #     def get_history_for_api(self) -> List[Dict[str, str]]:
    #         """Get conversation history in format expected by AI APIs."""
    #         return [
                {"role": "system", "content": self.get_system_prompt()},
    #             *[
    #                 {"role": msg["role"], "content": msg["content"]}
    #                 for msg in self.conversation_history
    #             ]
    #         ]

    #     def update_last_used(self):
    #         """Update the last used timestamp."""
    self.last_used = datetime.now()

    #     def get_agent_info(self) -> Dict[str, Any]:
    #         """Get agent information for UI display."""
    #         return {
    #             'name': self.name,
    #             'description': self.description,
    #             'capabilities': self.capabilities,
    #             'last_used': self.last_used.isoformat() if self.last_used else None,
                'conversation_count': len(self.conversation_history)
    #         }

    #     def get_capabilities(self) -> List[str]:
    #         """Get the list of agent capabilities."""
            return self.capabilities.copy()

    #     def enhance_prompt(self, prompt: str) -> str:
    #         """Enhance a prompt with agent-specific context."""
    #         return f"{self.description}\n\n{prompt}"

    #     def is_healthy(self) -> bool:
    #         """Check if the agent is healthy."""
    #         return True

    #     def initialize(self) -> None:
    #         """Initialize the agent."""
    #         pass

    #     def start(self) -> None:
    #         """Start the agent."""
    #         pass

    #     def stop(self, graceful: bool = True) -> None:
    #         """Stop the agent."""
    #         pass

    #     def pause(self) -> None:
    #         """Pause the agent."""
    #         pass

    #     def resume(self) -> None:
    #         """Resume the agent."""
    #         pass

    #     def get_lifecycle_state(self) -> Optional[str]:
    #         """Get the current lifecycle state."""
    #         return self.lifecycle_state

    #     def get_health_status(self) -> Optional[str]:
    #         """Get the current health status."""
    #         return self.health_status

    #     def set_lifecycle_state(self, state: str) -> None:
    #         """Set the lifecycle state."""
    self.lifecycle_state = state

    #     def set_health_status(self, status: str) -> None:
    #         """Set the health status."""
    self.health_status = status


class AIAgentManager
    #     """Manager for all AI agents in the IDE."""

    #     def __init__(self):
    self.agents = {}
    self.current_agent = None
    self.agent_configs = {}

    #     def register_agent(self, agent_name: str = None, agent: BaseAIAgent = None):
    #         """Register an AI agent."""
            # Handle both calling patterns: register_agent(agent) and register_agent(name, agent)
    #         if agent is None and agent_name is not None:
    agent = agent_name
    agent_name = agent.name
    #         elif agent_name is None:
    agent_name = agent.name

    self.agents[agent_name] = agent
    #         if self.current_agent is None:
    self.current_agent = agent

    #     def set_current_agent(self, agent_name: str) -> bool:
    #         """Set the current active agent."""
    #         if agent_name in self.agents:
    self.current_agent = self.agents[agent_name]
    #             return True
    #         return False

    #     def get_agent(self, agent_name: str) -> Optional[BaseAIAgent]:
    #         """Get a specific agent by name."""
            return self.agents.get(agent_name)

    #     def get_current_agent(self) -> Optional[BaseAIAgent]:
    #         """Get the currently active agent."""
    #         return self.current_agent

    #     def get_all_agents(self) -> Dict[str, BaseAIAgent]:
    #         """Get all registered agents."""
    #         return self.agents

    #     def list_agents(self) -> List[str]:
    #         """Get list of all agent names."""
            return list(self.agents.keys())

    #     def get_agent_info_list(self) -> List[Dict[str, Any]]:
    #         """Get information about all agents for UI display."""
    #         return [agent.get_agent_info() for agent in self.agents.values()]

    #     def save_agent_states(self, config_path: Path):
    #         """Save agent states to configuration file."""
    #         try:
    config = {}
    #             for name, agent in self.agents.items():
    config[name] = {
    #                     'conversation_history': agent.conversation_history,
    #                     'last_used': agent.last_used.isoformat() if agent.last_used else None
    #                 }

    #             with open(config_path, 'w') as f:
    json.dump(config, f, indent = 2)
    #         except Exception as e:
                print(f"Error saving agent states: {e}")

    #     def load_agent_states(self, config_path: Path):
    #         """Load agent states from configuration file."""
    #         try:
    #             if not config_path.exists():
    #                 return

    #             with open(config_path, 'r') as f:
    config = json.load(f)

    #             for name, agent_config in config.items():
    #                 if name in self.agents:
    agent = self.agents[name]
    agent.conversation_history = agent_config.get('conversation_history', [])

    #                     if agent_config.get('last_used'):
    agent.last_used = datetime.fromisoformat(agent_config['last_used'])

    #         except Exception as e:
                print(f"Error loading agent states: {e}")