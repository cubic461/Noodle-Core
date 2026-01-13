# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# AI Role Manager for NoodleCore
# Manages AI role descriptions in editable text documents that can be selected and used during AI chats.
# """

import os
import json
import logging
import uuid
import datetime.datetime
import pathlib.Path
import typing.Dict,

logger = logging.getLogger(__name__)

# Error codes for role management
ROLE_ERROR_CODES = {
#     "ROLE_NOT_FOUND": 6301,
#     "ROLE_CREATE_FAILED": 6302,
#     "ROLE_UPDATE_FAILED": 6303,
#     "ROLE_DELETE_FAILED": 6304,
#     "ROLE_DOCUMENT_READ_FAILED": 6305,
#     "ROLE_DOCUMENT_WRITE_FAILED": 6306,
#     "ROLE_VALIDATION_FAILED": 6307
# }

class AIRoleError(Exception)
    #     """Custom exception for AI role management errors."""
    #     def __init__(self, message: str, error_code: int = 6301, data: Optional[Dict] = None):
            super().__init__(message)
    self.error_code = error_code
    self.data = data or {}

class AIRole
    #     """Represents an AI role with its description document."""

    #     def __init__(self, role_id: str, name: str, description: str, document_path: str,
    category: str = "general", tags: List[str] = None,
    is_default: bool = False, created_at: str = None, updated_at: str = None):
    self.id = role_id
    self.name = name
    self.description = description
    self.document_path = document_path
    self.category = category
    self.tags = tags or []
    self.is_default = is_default
    self.created_at = created_at or datetime.now().isoformat()
    self.updated_at = updated_at or datetime.now().isoformat()

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert role to dictionary."""
    #         return {
    #             "id": self.id,
    #             "name": self.name,
    #             "description": self.description,
    #             "document_path": self.document_path,
    #             "category": self.category,
    #             "tags": self.tags,
    #             "is_default": self.is_default,
    #             "created_at": self.created_at,
    #             "updated_at": self.updated_at
    #         }

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -> 'AIRole':
    #         """Create role from dictionary."""
            return cls(
    role_id = data["id"],
    name = data["name"],
    description = data["description"],
    document_path = data["document_path"],
    category = data.get("category", "general"),
    tags = data.get("tags", []),
    is_default = data.get("is_default", False),
    created_at = data.get("created_at"),
    updated_at = data.get("updated_at")
    #         )

class AIRoleManager
    #     """Manages AI roles and their document files."""

    #     def __init__(self, workspace_root: str = None):
    #         """Initialize the AI role manager.

    #         Args:
    #             workspace_root: Path to the workspace directory
    #         """
    self.workspace_path = workspace_root or os.getcwd()
    self.roles_dir = Path(self.workspace_path) / ".noodlecore" / "ai_roles"
    self.config_file = self.roles_dir / "roles_config.json"

    #         # Ensure roles directory exists
    self.roles_dir.mkdir(parents = True, exist_ok=True)

    #         # Load existing roles
    self.roles: Dict[str, AIRole] = {}
            self._load_roles()

    #         # Create default roles if none exist
    #         if not self.roles:
                self._create_default_roles()

    #     def _load_roles(self) -> None:
    #         """Load roles from configuration file."""
    #         try:
    #             if self.config_file.exists():
    #                 with open(self.config_file, 'r', encoding='utf-8') as f:
    config_data = json.load(f)

    #                 for role_data in config_data.get("roles", []):
    role = AIRole.from_dict(role_data)
    self.roles[role.id] = role

                    logger.info(f"Loaded {len(self.roles)} AI roles")
    #             else:
                    logger.info("No existing role configuration found")

    #         except Exception as e:
                logger.error(f"Failed to load roles: {e}")
                raise AIRoleError(f"Failed to load roles: {str(e)}",
    #                             ROLE_ERROR_CODES["ROLE_DOCUMENT_READ_FAILED"])

    #     def _save_roles(self) -> None:
    #         """Save roles to configuration file."""
    #         try:
    config_data = {
    #                 "version": "1.0",
                    "last_updated": datetime.now().isoformat(),
    #                 "roles": [role.to_dict() for role in self.roles.values()]
    #             }

    #             with open(self.config_file, 'w', encoding='utf-8') as f:
    json.dump(config_data, f, indent = 2, ensure_ascii=False)

                logger.info(f"Saved {len(self.roles)} AI roles to configuration")

    #         except Exception as e:
                logger.error(f"Failed to save roles: {e}")
                raise AIRoleError(f"Failed to save roles: {str(e)}",
    #                             ROLE_ERROR_CODES["ROLE_DOCUMENT_WRITE_FAILED"])

    #     def _create_role_document(self, role_name: str, initial_content: str = "") -> str:
    #         """Create a role document file.

    #         Args:
    #             role_name: Name for the role
    #             initial_content: Initial content for the document

    #         Returns:
    #             Path to the created document
    #         """
    #         # Sanitize filename
    #         safe_name = "".join(c for c in role_name if c.isalnum() or c in (' ', '-', '_')).rstrip()
    safe_name = safe_name.replace(' ', '_').lower()

    document_path = self.roles_dir / f"{safe_name}.md"

    #         # If file exists, add timestamp
    counter = 1
    original_path = document_path
    #         while document_path.exists():
    document_path = self.roles_dir / f"{safe_name}_{counter}.md"
    counter + = 1

    #         # Create document with initial content
    #         try:
    #             with open(document_path, 'w', encoding='utf-8') as f:
    #                 if not initial_content.strip():
    #                     # Generate default content
    initial_content = self._generate_default_role_content(role_name)

                    f.write(initial_content)

                logger.info(f"Created role document: {document_path}")
                return str(document_path)

    #         except Exception as e:
                logger.error(f"Failed to create role document: {e}")
                raise AIRoleError(f"Failed to create role document: {str(e)}",
    #                             ROLE_ERROR_CODES["ROLE_DOCUMENT_WRITE_FAILED"])

    #     def _generate_default_role_content(self, role_name: str) -> str:
    #         """Generate default content for a role document.

    #         Args:
    #             role_name: Name of the role

    #         Returns:
    #             Default content for the role document
    #         """
    #         # Special content for the Manager role
    #         if role_name == "NoodleCore Manager":
    #             return """# NoodleCore Manager

## Role Description
# You are the NoodleCore Manager AI, the central orchestrator for all IDE operations. Your primary responsibility is to coordinate tasks across the NoodleCore ecosystem and ensure alignment with the NoodleCore-native vision.

## Key Responsibilities
# 1. **Hierarchical Understanding**: Always read and understand the complete NoodleCore documentation structure before delegating tasks.
# 2. **Task Routing**: Analyze user requests and route them to specialized AI roles with precise context and constraints.
# 3. **NoodleCore-Native Vision**: Understand and enforce the roadmap to move towards native NoodleCore language + NBC runtime, multi-language hosting on NBC, and self-improvement based on real metrics.
# 4. **Validation**: Review results from specialized roles to ensure they maintain alignment with NoodleCore-native trajectory.

## Key Constraints
- All code generation MUST prioritize NoodleCore (.nc) constructs over other languages
# - Multi-language support MUST be implemented through NBC runtime hosting
# - Self-improvement MUST be based on real metrics, not simulated progress
# - Strict adherence to AGENTS.md, .roo/rules/generated_rules.md, and architecture docs
# - Always reference the memory-bank hierarchy for context

## Task Delegation Protocol
# 1. Analyze the request and identify required expertise
# 2. Read relevant documentation from the hierarchical structure
# 3. Select appropriate specialized role with specific constraints
# 4. Provide clear context including file paths and NoodleCore requirements
# 5. Validate results against NoodleCore-native principles

## Decision Making
# - Prioritize NoodleCore-native solutions over workarounds
# - Consider the progressive migration strategy from existing codebases
# - Ensure all suggestions are implementable within the current NoodleCore ecosystem
# - Maintain consistency with the real AI implementation plan

# When delegating, always include:
# - Specific file paths and context
# - NoodleCore attribute references where applicable
# - Constraints from .roo/rules and architecture docs
# - Expected outcome aligned with NoodleCore vision

# You are the guardian of NoodleCore's architectural integrity and the facilitator of its evolution toward a fully native ecosystem.

# ---
# *This Manager AI role serves as the central orchestrator for NoodleCore IDE operations*
# """

#         # Default content for other roles
content = f"""# {role_name}

## Role Description
# Provide a detailed description of this AI role's responsibilities, expertise areas, and how it should behave during conversations.

## Key Responsibilities
# - Responsibility 1
# - Responsibility 2
# - Responsibility 3

## Communication Style
# - Tone: [professional/friendly/technical/etc.]
# - Level of detail: [concise/detailed/comprehensive]
# - Response format: [bullet points/paragraphs/code examples/etc.]

## Areas of Expertise
# - Expertise area 1
# - Expertise area 2
# - Expertise area 3

## Interaction Guidelines
# - How to handle questions outside expertise
# - Preferred approach to problem-solving
# - When to ask clarifying questions

## Example Scenarios
# Describe how this role would handle typical scenarios or provide example interactions.

# ---
# *This role description document was automatically generated for {role_name}*
# """
#         return content

#     def _create_default_roles(self) -> None:
#         """Create default AI roles."""
default_roles = [
#             {
#                 "name": "NoodleCore Manager",
#                 "description": "Central orchestrator for all IDE operations and task coordination",
#                 "category": "orchestration",
#                 "tags": ["orchestration", "coordination", "management", "noodlecore-vision"],
#                 "is_default": True
#             },
#             {
#                 "name": "Code Architect",
#                 "description": "System design and architectural guidance for NoodleCore development",
#                 "category": "architecture",
#                 "tags": ["design", "architecture", "system", "planning"]
#             },
#             {
#                 "name": "NoodleCore Developer",
#                 "description": "Expert in NoodleCore language development and implementation",
#                 "category": "development",
#                 "tags": ["development", "coding", "noodlecore", "implementation"]
#             },
#             {
#                 "name": "Code Reviewer",
#                 "description": "Quality assurance and code review specialist",
#                 "category": "review",
#                 "tags": ["review", "quality", "testing", "best-practices"]
#             },
#             {
#                 "name": "Debugging Expert",
#                 "description": "Specialized in debugging, error analysis, and problem resolution",
#                 "category": "debugging",
#                 "tags": ["debugging", "troubleshooting", "error-analysis", "problem-solving"]
#             },
#             {
#                 "name": "Documentation Specialist",
#                 "description": "Expert in creating clear, comprehensive documentation",
#                 "category": "documentation",
#                 "tags": ["documentation", "writing", "guides", "api-documentation"]
#             },
#             {
#                 "name": "Test Engineer",
#                 "description": "Specialized in testing strategies and quality assurance",
#                 "category": "testing",
#                 "tags": ["testing", "quality", "test-strategy", "automation"]
#             },
#             {
#                 "name": "Performance Optimizer",
#                 "description": "Expert in performance analysis and optimization techniques",
#                 "category": "optimization",
#                 "tags": ["performance", "optimization", "profiling", "efficiency"]
#             },
#             {
#                 "name": "Security Analyst",
#                 "description": "Security-focused role for code review and security analysis",
#                 "category": "security",
#                 "tags": ["security", "vulnerabilities", "compliance", "safety"]
#             }
#         ]

#         for role_data in default_roles:
            self.create_role(
name = role_data["name"],
description = role_data["description"],
category = role_data["category"],
tags = role_data["tags"]
#             )

        logger.info(f"Created {len(default_roles)} default AI roles")

#     def create_role(self, name: str, description: str, category: str = "general",
tags: List[str] = None, document_content: str = "") -> Dict[str, Any]:
#         """Create a new AI role.

#         Args:
#             name: Name of the role
#             description: Description of the role
#             category: Category of the role
#             tags: Tags associated with the role
#             document_content: Optional content for the role document

#         Returns:
#             Dictionary representing the created role
#         """
#         try:
role_id = str(uuid.uuid4())

#             # Create role document
document_path = self._create_role_document(name, document_content)

#             # Create role
role = AIRole(
role_id = role_id,
name = name,
description = description,
document_path = document_path,
category = category,
tags = tags or []
#             )

self.roles[role_id] = role
            self._save_roles()

#             logger.info(f"Created AI role '{name}' with ID {role_id}")
            return role.to_dict()

#         except Exception as e:
            logger.error(f"Failed to create role '{name}': {e}")
            raise AIRoleError(f"Failed to create role '{name}': {str(e)}",
#                             ROLE_ERROR_CODES["ROLE_CREATE_FAILED"])

#     def get_role(self, role_id: str) -> Optional[AIRole]:
#         """Get a role by ID.

#         Args:
#             role_id: ID of the role

#         Returns:
#             Role instance or None if not found
#         """
        return self.roles.get(role_id)

#     def get_role_by_name(self, name: str) -> Optional[AIRole]:
#         """Get a role by name.

#         Args:
#             name: Name of the role

#         Returns:
#             Role instance or None if not found
#         """
#         for role in self.roles.values():
#             if role.name == name:
#                 return role
#         return None

#     def get_all_roles(self) -> List[AIRole]:
#         """Get all roles.

#         Returns:
#             List of all roles
#         """
        return list(self.roles.values())

#     def get_roles_by_category(self, category: str) -> List[AIRole]:
#         """Get roles by category.

#         Args:
#             category: Category to filter by

#         Returns:
#             List of roles in the specified category
#         """
#         return [role for role in self.roles.values() if role.category == category]

#     def update_role(self, role_id: str, name: str = None, description: str = None,
category: str = math.subtract(None, tags: List[str] = None), > bool:)
#         """Update a role.

#         Args:
#             role_id: ID of the role to update
            name: New name (optional)
            description: New description (optional)
            category: New category (optional)
            tags: New tags (optional)

#         Returns:
#             True if role was updated successfully
#         """
#         try:
role = self.roles.get(role_id)
#             if not role:
#                 raise AIRoleError(f"Role with ID {role_id} not found",
#                                 ROLE_ERROR_CODES["ROLE_NOT_FOUND"])

#             # Update fields if provided
#             if name is not None:
role.name = name
#             if description is not None:
role.description = description
#             if category is not None:
role.category = category
#             if tags is not None:
role.tags = tags

role.updated_at = datetime.now().isoformat()

            self._save_roles()
            logger.info(f"Updated AI role '{role.name}'")
#             return True

#         except Exception as e:
            logger.error(f"Failed to update role: {e}")
            raise AIRoleError(f"Failed to update role: {str(e)}",
#                             ROLE_ERROR_CODES["ROLE_UPDATE_FAILED"])

#     def delete_role(self, role_id: str) -> bool:
#         """Delete a role.

#         Args:
#             role_id: ID of the role to delete

#         Returns:
#             True if role was deleted successfully
#         """
#         try:
role = self.roles.get(role_id)
#             if not role:
#                 raise AIRoleError(f"Role with ID {role_id} not found",
#                                 ROLE_ERROR_CODES["ROLE_NOT_FOUND"])

#             # Delete role document file
#             try:
#                 if os.path.exists(role.document_path):
                    os.remove(role.document_path)
                    logger.info(f"Deleted role document: {role.document_path}")
#             except Exception as e:
                logger.warning(f"Failed to delete role document: {e}")

#             # Remove role
#             del self.roles[role_id]
            self._save_roles()

            logger.info(f"Deleted AI role '{role.name}'")
#             return True

#         except Exception as e:
            logger.error(f"Failed to delete role: {e}")
            raise AIRoleError(f"Failed to delete role: {str(e)}",
#                             ROLE_ERROR_CODES["ROLE_DELETE_FAILED"])

#     def read_role_document(self, role_id: str) -> Optional[str]:
#         """Read the content of a role's document.

#         Args:
#             role_id: ID of the role

#         Returns:
#             Content of the role document or None if not found
#         """
#         try:
role = self.roles.get(role_id)
#             if not role:
#                 raise AIRoleError(f"Role with ID {role_id} not found",
#                                 ROLE_ERROR_CODES["ROLE_NOT_FOUND"])

#             with open(role.document_path, 'r', encoding='utf-8') as f:
content = f.read()

#             logger.info(f"Read role document for '{role.name}'")
#             return content

#         except Exception as e:
            logger.error(f"Failed to read role document: {e}")
            raise AIRoleError(f"Failed to read role document: {str(e)}",
#                             ROLE_ERROR_CODES["ROLE_DOCUMENT_READ_FAILED"])

#     def write_role_document(self, role_id: str, content: str) -> bool:
#         """Write content to a role's document.

#         Args:
#             role_id: ID of the role
#             content: Content to write

#         Returns:
#             True if document was written successfully
#         """
#         try:
role = self.roles.get(role_id)
#             if not role:
#                 raise AIRoleError(f"Role with ID {role_id} not found",
#                                 ROLE_ERROR_CODES["ROLE_NOT_FOUND"])

#             with open(role.document_path, 'w', encoding='utf-8') as f:
                f.write(content)

role.updated_at = datetime.now().isoformat()
            self._save_roles()

#             logger.info(f"Wrote role document for '{role.name}'")
#             return True

#         except Exception as e:
            logger.error(f"Failed to write role document: {e}")
            raise AIRoleError(f"Failed to write role document: {str(e)}",
#                             ROLE_ERROR_CODES["ROLE_DOCUMENT_WRITE_FAILED"])

#     def search_roles(self, query: str) -> List[AIRole]:
#         """Search roles by name, description, or tags.

#         Args:
#             query: Search query

#         Returns:
#             List of matching roles
#         """
query = query.lower()
matches = []

#         for role in self.roles.values():
#             # Check name
#             if query in role.name.lower():
                matches.append(role)
#                 continue

#             # Check description
#             if query in role.description.lower():
                matches.append(role)
#                 continue

#             # Check tags
#             if any(query in tag.lower() for tag in role.tags):
                matches.append(role)
#                 continue

#         return matches

#     def get_role_categories(self) -> List[str]:
#         """Get all available role categories.

#         Returns:
#             List of category names
#         """
#         categories = set(role.category for role in self.roles.values())
        return sorted(list(categories))

#     def export_role(self, role_id: str, export_path: str) -> bool:
#         """Export a role to a file.

#         Args:
#             role_id: ID of the role to export
#             export_path: Path to export the role

#         Returns:
#             True if role was exported successfully
#         """
#         try:
role = self.roles.get(role_id)
#             if not role:
#                 raise AIRoleError(f"Role with ID {role_id} not found",
#                                 ROLE_ERROR_CODES["ROLE_NOT_FOUND"])

#             # Read document content
document_content = self.read_role_document(role_id)

#             # Create export data
export_data = {
                "role": role.to_dict(),
#                 "document_content": document_content,
                "exported_at": datetime.now().isoformat(),
#                 "version": "1.0"
#             }

#             # Write to file
#             with open(export_path, 'w', encoding='utf-8') as f:
json.dump(export_data, f, indent = 2, ensure_ascii=False)

            logger.info(f"Exported role '{role.name}' to {export_path}")
#             return True

#         except Exception as e:
            logger.error(f"Failed to export role: {e}")
#             return False

#     def import_role(self, import_path: str) -> str:
#         """Import a role from a file.

#         Args:
#             import_path: Path to the role export file

#         Returns:
#             ID of the imported role
#         """
#         try:
#             with open(import_path, 'r', encoding='utf-8') as f:
import_data = json.load(f)

role_data = import_data["role"]
document_content = import_data["document_content"]

#             # Generate new ID to avoid conflicts
new_id = str(uuid.uuid4())
role_data["id"] = new_id
role_data["created_at"] = datetime.now().isoformat()
role_data["updated_at"] = datetime.now().isoformat()

#             # Create role document
document_path = self._create_role_document(role_data["name"], document_content)
role_data["document_path"] = document_path

#             # Create role
role = AIRole.from_dict(role_data)
self.roles[new_id] = role
            self._save_roles()

#             logger.info(f"Imported role '{role.name}' with ID {new_id}")
#             return new_id

#         except Exception as e:
            logger.error(f"Failed to import role: {e}")
            raise AIRoleError(f"Failed to import role: {str(e)}",
#                             ROLE_ERROR_CODES["ROLE_CREATE_FAILED"])

# Global role manager instance
_global_role_manager = None

def get_role_manager(workspace_path: str = None) -> AIRoleManager:
#     """Get the global AI role manager instance.

#     Args:
#         workspace_path: Path to the workspace directory

#     Returns:
#         AI role manager instance
#     """
#     global _global_role_manager

#     if _global_role_manager is None:
_global_role_manager = AIRoleManager(workspace_path)

#     return _global_role_manager

def set_role_manager(role_manager: AIRoleManager) -> None:
#     """Set the global AI role manager instance.

#     Args:
#         role_manager: Role manager instance to set
#     """
#     global _global_role_manager
_global_role_manager = role_manager