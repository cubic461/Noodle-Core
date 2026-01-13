# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# NoodleCore AI Agent Registry
 = ==========================

# Centralized registry for managing AI agents with role-based access control,
# memory management, and agent lifecycle management.
# """

import json
import os
import uuid
import datetime.datetime
import pathlib.Path
import typing.Dict,
import dataclasses.dataclass,
import enum.Enum

import .base_agent.BaseAIAgent,


class AgentStatus(Enum)
    #     """Agent status enumeration."""
    ACTIVE = "active"
    INACTIVE = "inactive"
    ERROR = "error"
    LOADING = "loading"


class AgentRole(Enum)
    #     """Agent role enumeration for access control."""
    DEVELOPER = "developer"
    DEBUGGER = "debugger"
    TESTER = "tester"
    DOCUMENTER = "documenter"
    REFACTORER = "refactorer"
    CODE_REVIEWER = "code_reviewer"
    WRITER = "writer"
    GENERAL = "general"


# @dataclass
class AgentMetadata
    #     """Metadata for AI agent registration."""
    #     agent_id: str
    #     name: str
    #     description: str
    #     role: AgentRole
    #     capabilities: List[str]
    #     status: AgentStatus
    #     created_at: datetime
    last_used: Optional[datetime] = None
    usage_count: int = 0
    error_count: int = 0
    config: Dict[str, Any] = None

    #     def __post_init__(self):
    #         if self.config is None:
    self.config = {}


# @dataclass
class AgentConfig
    #     """Configuration for AI agent behavior."""
    max_conversation_length: int = 20
    enable_memory: bool = True
    enable_persistence: bool = True
    timeout_seconds: int = 30
    max_retries: int = 3
    temperature: float = 0.7
    max_tokens: int = 2048
    custom_settings: Dict[str, Any] = None

    #     def __post_init__(self):
    #         if self.custom_settings is None:
    self.custom_settings = {}


class AgentRegistry
    #     """Centralized registry for managing AI agents."""

    #     def __init__(self, registry_path: Optional[Path] = None):
    self.registry_path = registry_path or Path.home() / ".noodlecore" / "agent_registry.json"
    self.agents: Dict[str, BaseAIAgent] = {}
    self.metadata: Dict[str, AgentMetadata] = {}
    self.configs: Dict[str, AgentConfig] = {}
    self.role_mapping: Dict[AgentRole, List[str]] = {}
            self._initialize_registry()

    #     def _initialize_registry(self):
    #         """Initialize the agent registry."""
    #         # Ensure registry directory exists
    self.registry_path.parent.mkdir(parents = True, exist_ok=True)

    #         # Load existing registry if it exists
    #         if self.registry_path.exists():
                self._load_registry()
    #         else:
                self._create_default_registry()

    #     def _create_default_registry(self):
    #         """Create default registry configuration."""
    #         # Initialize role mappings
    #         for role in AgentRole:
    self.role_mapping[role] = []

    #         # Save empty registry
            self._save_registry()

    #     def _load_registry(self):
    #         """Load registry from file."""
    #         try:
    #             with open(self.registry_path, 'r') as f:
    data = json.load(f)

    #             # Load metadata
    #             for agent_id, metadata_data in data.get('metadata', {}).items():
    metadata = AgentMetadata(
    agent_id = metadata_data['agent_id'],
    name = metadata_data['name'],
    description = metadata_data['description'],
    role = AgentRole(metadata_data['role']),
    capabilities = metadata_data['capabilities'],
    status = AgentStatus(metadata_data['status']),
    created_at = datetime.fromisoformat(metadata_data['created_at']),
    #                     last_used=datetime.fromisoformat(metadata_data['last_used']) if metadata_data.get('last_used') else None,
    usage_count = metadata_data.get('usage_count', 0),
    error_count = metadata_data.get('error_count', 0),
    config = metadata_data.get('config', {})
    #                 )
    self.metadata[agent_id] = metadata

    #             # Load configs
    #             for agent_id, config_data in data.get('configs', {}).items():
    config = AgentConfig(
    max_conversation_length = config_data.get('max_conversation_length', 20),
    enable_memory = config_data.get('enable_memory', True),
    enable_persistence = config_data.get('enable_persistence', True),
    timeout_seconds = config_data.get('timeout_seconds', 30),
    max_retries = config_data.get('max_retries', 3),
    temperature = config_data.get('temperature', 0.7),
    max_tokens = config_data.get('max_tokens', 2048),
    custom_settings = config_data.get('custom_settings', {})
    #                 )
    self.configs[agent_id] = config

    #             # Load role mappings
    #             for role_str, agent_ids in data.get('role_mapping', {}).items():
    role = AgentRole(role_str)
    self.role_mapping[role] = agent_ids

    #         except Exception as e:
                print(f"Error loading agent registry: {e}")
                self._create_default_registry()

    #     def _save_registry(self):
    #         """Save registry to file."""
    #         try:
    data = {
    #                 'metadata': {},
    #                 'configs': {},
    #                 'role_mapping': {}
    #             }

    #             # Save metadata
    #             for agent_id, metadata in self.metadata.items():
    #                 if agent_id in self.metadata and isinstance(self.metadata[agent_id], AgentMetadata):
    data['metadata'][agent_id] = {
    #                         'agent_id': metadata.agent_id,
    #                         'name': metadata.name,
    #                         'description': metadata.description,
    #                         'role': metadata.role.value,
    #                         'capabilities': metadata.capabilities,
    #                         'status': metadata.status.value,
                            'created_at': metadata.created_at.isoformat(),
    #                         'last_used': metadata.last_used.isoformat() if metadata.last_used else None,
    #                         'usage_count': metadata.usage_count,
    #                         'error_count': metadata.error_count,
    #                         'config': metadata.config
    #                     }

    #             # Save configs
    #             for agent_id, config in self.configs.items():
    data['configs'][agent_id] = asdict(config)

    #             # Save role mappings
    #             for role, agent_ids in self.role_mapping.items():
    data['role_mapping'][role.value] = agent_ids

    #             with open(self.registry_path, 'w') as f:
    json.dump(data, f, indent = 2)

    #         except Exception as e:
                print(f"Error saving agent registry: {e}")

    #     def register_agent(self, agent: BaseAIAgent, role: AgentRole, config: Optional[AgentConfig] = None) -> str:
    #         """Register an AI agent with the registry."""
    agent_id = str(uuid.uuid4())

    #         # Store agent instance
    self.agents[agent_id] = agent

    #         # Create metadata
    metadata = AgentMetadata(
    agent_id = agent_id,
    name = agent.name,
    description = agent.description,
    role = role,
    capabilities = agent.capabilities,
    status = AgentStatus.ACTIVE,
    created_at = datetime.now()
    #         )
    self.metadata[agent_id] = metadata

    #         # Set default config if not provided
    #         if config is None:
    config = AgentConfig()
    self.configs[agent_id] = config

    #         # Update role mapping
    #         if role not in self.role_mapping:
    self.role_mapping[role] = []
            self.role_mapping[role].append(agent_id)

    #         # Save registry
            self._save_registry()

    #         return agent_id

    #     def unregister_agent(self, agent_id: str) -> bool:
    #         """Unregister an AI agent from the registry."""
    #         if agent_id not in self.agents:
    #             return False

    #         # Get agent metadata
    metadata = self.metadata.get(agent_id)
    #         if metadata:
    #             # Remove from role mapping
    #             if metadata.role in self.role_mapping:
    #                 if agent_id in self.role_mapping[metadata.role]:
                        self.role_mapping[metadata.role].remove(agent_id)

    #         # Remove from all collections
            self.agents.pop(agent_id, None)
            self.metadata.pop(agent_id, None)
            self.configs.pop(agent_id, None)

    #         # Save registry
            self._save_registry()

    #         return True

    #     def get_agent(self, agent_id: str) -> Optional[BaseAIAgent]:
    #         """Get an AI agent by ID."""
            return self.agents.get(agent_id)

    #     def get_agents_by_role(self, role: AgentRole) -> List[BaseAIAgent]:
    #         """Get all agents for a specific role."""
    agent_ids = self.role_mapping.get(role, [])
    #         return [self.agents[agent_id] for agent_id in agent_ids if agent_id in self.agents]

    #     def get_agent_metadata(self, agent_id: str) -> Optional[AgentMetadata]:
    #         """Get agent metadata by ID."""
            return self.metadata.get(agent_id)

    #     def get_agent_config(self, agent_id: str) -> Optional[AgentConfig]:
    #         """Get agent configuration by ID."""
            return self.configs.get(agent_id)

    #     def update_agent_status(self, agent_id: str, status: AgentStatus) -> bool:
    #         """Update agent status."""
    #         if agent_id not in self.metadata:
    #             return False

    self.metadata[agent_id].status = status
            self._save_registry()
    #         return True

    #     def update_agent_usage(self, agent_id: str, success: bool = True) -> bool:
    #         """Update agent usage statistics."""
    #         if agent_id not in self.metadata:
    #             return False

    metadata = self.metadata[agent_id]
    metadata.last_used = datetime.now()
    metadata.usage_count + = 1

    #         if not success:
    metadata.error_count + = 1

            self._save_registry()
    #         return True

    #     def update_agent_config(self, agent_id: str, config: AgentConfig) -> bool:
    #         """Update agent configuration."""
    #         if agent_id not in self.agents:
    #             return False

    self.configs[agent_id] = config
            self._save_registry()
    #         return True

    #     def list_agents(self, role: Optional[AgentRole] = None, status: Optional[AgentStatus] = None) -> List[Dict[str, Any]]:
    #         """List all agents with optional filtering."""
    agents = []

    #         for agent_id, metadata in self.metadata.items():
    #             # Apply role filter
    #             if role and metadata.role != role:
    #                 continue

    #             # Apply status filter
    #             if status and metadata.status != status:
    #                 continue

                agents.append({
    #                 'agent_id': agent_id,
    #                 'name': metadata.name,
    #                 'description': metadata.description,
    #                 'role': metadata.role.value,
    #                 'capabilities': metadata.capabilities,
    #                 'status': metadata.status.value,
                    'created_at': metadata.created_at.isoformat(),
    #                 'last_used': metadata.last_used.isoformat() if metadata.last_used else None,
    #                 'usage_count': metadata.usage_count,
    #                 'error_count': metadata.error_count
    #             })

    #         return agents

    #     def get_registry_stats(self) -> Dict[str, Any]:
    #         """Get registry statistics."""
    total_agents = len(self.agents)
    #         active_agents = sum(1 for metadata in self.metadata.values() if metadata.status == AgentStatus.ACTIVE)
    #         total_usage = sum(metadata.usage_count for metadata in self.metadata.values())
    #         total_errors = sum(metadata.error_count for metadata in self.metadata.values())

    role_stats = {}
    #         for role, agent_ids in self.role_mapping.items():
    role_stats[role.value] = len(agent_ids)

    #         return {
    #             'total_agents': total_agents,
    #             'active_agents': active_agents,
    #             'inactive_agents': total_agents - active_agents,
    #             'total_usage': total_usage,
    #             'total_errors': total_errors,
    #             'role_distribution': role_stats,
                'registry_path': str(self.registry_path)
    #         }


# Global registry instance
_global_registry: Optional[AgentRegistry] = None


def get_agent_registry() -> AgentRegistry:
#     """Get the global agent registry instance."""
#     global _global_registry
#     if _global_registry is None:
_global_registry = AgentRegistry()
#     return _global_registry


def create_agent_manager_from_registry() -> AIAgentManager:
#     """Create an AI agent manager populated from the registry."""
registry = get_agent_registry()
manager = AIAgentManager()

#     # Register all active agents
#     for agent_id, agent in registry.agents.items():
metadata = registry.get_agent_metadata(agent_id)
#         if metadata and metadata.status == AgentStatus.ACTIVE:
            manager.register_agent(agent)

#     return manager