# Converted from Python to NoodleCore
# Original file: src

# """
# Authorization Module for NoodleCore with TRM-Agent
# """

import os
import time
import json
import logging
import typing.Dict
from dataclasses import dataclass
import enum.Enum
from functools import wraps

import .authentication.get_authentication_manager
import .structured_logging.get_logger

logger = get_logger(__name__)


class Permission(Enum)
    #     """Permission enumeration"""
    READ = "read"
    WRITE = "write"
    EXECUTE = "execute"
    DELETE = "delete"
    ADMIN = "admin"


class ResourceType(Enum)
    #     """Resource type enumeration"""
    API = "api"
    COMPILATION = "compilation"
    TRM_AGENT = "trm_agent"
    DISTRIBUTED = "distributed"
    USER = "user"
    ROLE = "role"
    SYSTEM = "system"


dataclass
class Role
    #     """Role model"""
    #     id: str
    #     name: str
    #     description: str
    permissions: List[str] = field(default_factory=list)
    is_system: bool = False
    created_at: float = field(default_factory=time.time)

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary"""
    #         return {
    #             "id": self.id,
    #             "name": self.name,
    #             "description": self.description,
    #             "permissions": self.permissions,
    #             "is_system": self.is_system,
    #             "created_at": self.created_at
    #         }

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -"Role"):
    #         """Create from dictionary"""
            return cls(
    id = data["id"],
    name = data["name"],
    description = data["description"],
    permissions = data.get("permissions", []),
    is_system = data.get("is_system", False),
    created_at = data.get("created_at", time.time())
    #         )


dataclass
class Policy
    #     """Policy model for ABAC"""
    #     id: str
    #     name: str
    #     description: str
    #     effect: str  # allow, deny
    #     principal: Dict[str, Any]  # Who
    #     action: str  # What
    #     resource: Dict[str, Any]  # Where
    condition: Dict[str, Any] = field(default_factory=dict)  # When
    priority: int = 0
    is_system: bool = False
    created_at: float = field(default_factory=time.time)

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary"""
    #         return {
    #             "id": self.id,
    #             "name": self.name,
    #             "description": self.description,
    #             "effect": self.effect,
    #             "principal": self.principal,
    #             "action": self.action,
    #             "resource": self.resource,
    #             "condition": self.condition,
    #             "priority": self.priority,
    #             "is_system": self.is_system,
    #             "created_at": self.created_at
    #         }

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -"Policy"):
    #         """Create from dictionary"""
            return cls(
    id = data["id"],
    name = data["name"],
    description = data["description"],
    effect = data["effect"],
    principal = data["principal"],
    action = data["action"],
    resource = data["resource"],
    condition = data.get("condition", {}),
    priority = data.get("priority", 0),
    is_system = data.get("is_system", False),
    created_at = data.get("created_at", time.time())
    #         )


class AuthorizationManager
    #     """Authorization manager for NoodleCore with TRM-Agent"""

    #     def __init__(self):
    #         # Roles
    self.roles = {}

    #         # Policies
    self.policies = {}

    #         # Authentication manager
    self.auth_manager = get_authentication_manager()

    #         # Initialize
            self._initialize()

    #     def _initialize(self):
    #         """Initialize the authorization manager"""
    #         # Create default roles
            self._create_default_roles()

    #         # Create default policies
            self._create_default_policies()

    #     def _create_default_roles(self):
    #         """Create default roles"""
    #         # Admin role
    admin_role = Role(
    id = "admin",
    name = "Administrator",
    description = "Full access to all resources",
    permissions = [
    #                 "api:read", "api:write", "api:execute", "api:delete", "api:admin",
    #                 "compilation:read", "compilation:write", "compilation:execute", "compilation:delete", "compilation:admin",
    #                 "trm_agent:read", "trm_agent:write", "trm_agent:execute", "trm_agent:delete", "trm_agent:admin",
    #                 "distributed:read", "distributed:write", "distributed:execute", "distributed:delete", "distributed:admin",
    #                 "user:read", "user:write", "user:execute", "user:delete", "user:admin",
    #                 "role:read", "role:write", "role:execute", "role:delete", "role:admin",
    #                 "system:read", "system:write", "system:execute", "system:delete", "system:admin"
    #             ],
    is_system = True
    #         )
    self.roles[admin_role.id] = admin_role

    #         # Developer role
    developer_role = Role(
    id = "developer",
    name = "Developer",
    description = "Access to development resources",
    permissions = [
    #                 "api:read", "api:write", "api:execute",
    #                 "compilation:read", "compilation:write", "compilation:execute",
    #                 "trm_agent:read", "trm_agent:write", "trm_agent:execute",
    #                 "distributed:read", "distributed:write", "distributed:execute"
    #             ],
    is_system = True
    #         )
    self.roles[developer_role.id] = developer_role

    #         # User role
    user_role = Role(
    id = "user",
    name = "User",
    description = "Basic access to resources",
    permissions = [
    #                 "api:read",
    #                 "compilation:read", "compilation:write", "compilation:execute",
    #                 "trm_agent:read", "trm_agent:execute"
    #             ],
    is_system = True
    #         )
    self.roles[user_role.id] = user_role

    #         # Readonly role
    readonly_role = Role(
    id = "readonly",
    name = "Readonly",
    description = "Read-only access to resources",
    permissions = [
    #                 "api:read",
    #                 "compilation:read",
    #                 "trm_agent:read",
    #                 "distributed:read"
    #             ],
    is_system = True
    #         )
    self.roles[readonly_role.id] = readonly_role

    #     def _create_default_policies(self):
    #         """Create default policies"""
    #         # Admin policy
    admin_policy = Policy(
    id = "admin_policy",
    name = "Administrator Policy",
    #             description="Full access for administrators",
    effect = "allow",
    principal = {"role": "admin"},
    action = "*",
    resource = "*",
    is_system = True,
    priority = 1000
    #         )
    self.policies[admin_policy.id] = admin_policy

    #         # Owner policy
    owner_policy = Policy(
    id = "owner_policy",
    name = "Owner Policy",
    #             description="Full access for resource owners",
    effect = "allow",
    principal = {"id": "${resource.owner_id}"},
    action = "*",
    resource = {"*": "*"},
    is_system = True,
    priority = 900
    #         )
    self.policies[owner_policy.id] = owner_policy

    #         # Deny policy for inactive users
    inactive_policy = Policy(
    id = "inactive_policy",
    name = "Inactive User Policy",
    #             description="Deny access for inactive users",
    effect = "deny",
    principal = {"active": False},
    action = "*",
    resource = "*",
    is_system = True,
    priority = 100
    #         )
    self.policies[inactive_policy.id] = inactive_policy

    #     def create_role(self, name: str, description: str, permissions: List[str],
    is_system: bool = False) - Role):
    #         """Create a new role"""
    #         # Check if role already exists
    #         if any(role.name == name for role in self.roles.values()):
                raise ValueError(f"Role already exists: {name}")

    #         # Create role
    role_id = str(uuid.uuid4())
    role = Role(
    id = role_id,
    name = name,
    description = description,
    permissions = permissions,
    is_system = is_system
    #         )

    #         # Store role
    self.roles[role_id] = role

            logger.info(f"Created role: {name} ({role_id})")
    #         return role

    #     def get_role(self, role_id: str) -Optional[Role]):
    #         """Get a role by ID"""
            return self.roles.get(role_id)

    #     def get_role_by_name(self, name: str) -Optional[Role]):
    #         """Get a role by name"""
    #         for role in self.roles.values():
    #             if role.name == name:
    #                 return role
    #         return None

    #     def update_role(self, role_id: str, **kwargs) -Optional[Role]):
    #         """Update a role"""
    role = self.roles.get(role_id)
    #         if not role:
    #             return None

    #         # Check if system role
    #         if role.is_system:
                raise ValueError("Cannot update system role")

    #         # Update role
    #         for key, value in kwargs.items():
    #             if hasattr(role, key):
                    setattr(role, key, value)

            logger.info(f"Updated role: {role.name}")
    #         return role

    #     def delete_role(self, role_id: str) -bool):
    #         """Delete a role"""
    role = self.roles.get(role_id)
    #         if not role:
    #             return False

    #         # Check if system role
    #         if role.is_system:
                raise ValueError("Cannot delete system role")

    #         # Check if role is in use
    #         for user in self.auth_manager.users.values():
    #             if role_id in user.roles:
                    raise ValueError(f"Role is in use by user: {user.username}")

    #         # Delete role
    #         del self.roles[role_id]

            logger.info(f"Deleted role: {role.name}")
    #         return True

    #     def assign_role_to_user(self, user_id: str, role_id: str) -bool):
    #         """Assign a role to a user"""
    user = self.auth_manager.get_user(user_id)
    #         if not user:
    #             return False

    role = self.roles.get(role_id)
    #         if not role:
    #             return False

    #         # Check if role already assigned
    #         if role_id in user.roles:
    #             return True

    #         # Assign role
            user.roles.append(role_id)

            logger.info(f"Assigned role {role.name} to user {user.username}")
    #         return True

    #     def remove_role_from_user(self, user_id: str, role_id: str) -bool):
    #         """Remove a role from a user"""
    user = self.auth_manager.get_user(user_id)
    #         if not user:
    #             return False

    #         # Check if role assigned
    #         if role_id not in user.roles:
    #             return True

    #         # Remove role
            user.roles.remove(role_id)

            logger.info(f"Removed role {role_id} from user {user.username}")
    #         return True

    #     def create_policy(self, name: str, description: str, effect: str,
    #                      principal: Dict[str, Any], action: str, resource: Dict[str, Any],
    condition: Dict[str, Any] = None, priority: int = 0,
    is_system: bool = False) - Policy):
    #         """Create a new policy"""
    #         # Create policy
    policy_id = str(uuid.uuid4())
    policy = Policy(
    id = policy_id,
    name = name,
    description = description,
    effect = effect,
    principal = principal,
    action = action,
    resource = resource,
    condition = condition or {},
    priority = priority,
    is_system = is_system
    #         )

    #         # Store policy
    self.policies[policy_id] = policy

            logger.info(f"Created policy: {name} ({policy_id})")
    #         return policy

    #     def get_policy(self, policy_id: str) -Optional[Policy]):
    #         """Get a policy by ID"""
            return self.policies.get(policy_id)

    #     def update_policy(self, policy_id: str, **kwargs) -Optional[Policy]):
    #         """Update a policy"""
    policy = self.policies.get(policy_id)
    #         if not policy:
    #             return None

    #         # Check if system policy
    #         if policy.is_system:
                raise ValueError("Cannot update system policy")

    #         # Update policy
    #         for key, value in kwargs.items():
    #             if hasattr(policy, key):
                    setattr(policy, key, value)

            logger.info(f"Updated policy: {policy.name}")
    #         return policy

    #     def delete_policy(self, policy_id: str) -bool):
    #         """Delete a policy"""
    policy = self.policies.get(policy_id)
    #         if not policy:
    #             return False

    #         # Check if system policy
    #         if policy.is_system:
                raise ValueError("Cannot delete system policy")

    #         # Delete policy
    #         del self.policies[policy_id]

            logger.info(f"Deleted policy: {policy.name}")
    #         return True

    #     def _evaluate_condition(self, condition: Dict[str, Any],
    #                            context: Dict[str, Any]) -bool):
    #         """Evaluate a policy condition"""
    #         if not condition:
    #             return True

    #         # Simple condition evaluation
    #         for key, expected_value in condition.items():
    #             # Get actual value from context
    actual_value = context.get(key)
    #             if actual_value is None:
    #                 return False

    #             # Handle different types of conditions
    #             if isinstance(expected_value, dict):
    #                 # Operator-based condition
    operator = expected_value.get("op", "eq")
    value = expected_value.get("value")

    #                 if operator == "eq":
    #                     if actual_value != value:
    #                         return False
    #                 elif operator == "ne":
    #                     if actual_value == value:
    #                         return False
    #                 elif operator == "gt":
    #                     if not isinstance(actual_value, (int, float)) or actual_value <= value:
    #                         return False
    #                 elif operator == "lt":
    #                     if not isinstance(actual_value, (int, float)) or actual_value >= value:
    #                         return False
    #                 elif operator == "gte":
    #                     if not isinstance(actual_value, (int, float)) or actual_value < value:
    #                         return False
    #                 elif operator == "lte":
    #                     if not isinstance(actual_value, (int, float)) or actual_value value):
    #                         return False
    #                 elif operator == "in":
    #                     if actual_value not in value:
    #                         return False
    #                 elif operator == "contains":
    #                     if value not in actual_value:
    #                         return False
    #                 else:
                        logger.warning(f"Unknown condition operator: {operator}")
    #                     return False
    #             else:
    #                 # Simple equality
    #                 if actual_value != expected_value:
    #                     return False

    #         return True

    #     def _match_principal(self, principal: Dict[str, Any],
    #                         user: User) -bool):
    #         """Check if a user matches a principal"""
    #         for key, expected_value in principal.items():
    #             # Handle variable substitution
    #             if isinstance(expected_value, str) and expected_value.startswith("${") and expected_value.endswith("}"):
    #                 # Variable substitution
    var_name = expected_value[2: - 1]
    #                 if var_name == "user.id":
    actual_value = user.id
    #                 elif var_name == "user.username":
    actual_value = user.username
    #                 elif var_name == "user.email":
    actual_value = user.email
    #                 else:
                        logger.warning(f"Unknown variable: {var_name}")
    #                     return False
    #             else:
    #                 # Direct value
    #                 if key == "id":
    actual_value = user.id
    #                 elif key == "username":
    actual_value = user.username
    #                 elif key == "email":
    actual_value = user.email
    #                 elif key == "role":
    #                     # Check if user has any of the specified roles
    #                     if isinstance(expected_value, list):
    #                         actual_value = any(role in user.roles for role in expected_value)
    #                     else:
    actual_value = expected_value in user.roles
    #                 elif key == "active":
    actual_value = user.is_active
    #                 elif key == "verified":
    actual_value = user.is_verified
    #                 else:
                        logger.warning(f"Unknown principal attribute: {key}")
    #                     return False

    #             # Check match
    #             if actual_value != expected_value:
    #                 return False

    #         return True

    #     def _match_action(self, action: str, required_action: str) -bool):
    #         """Check if an action matches a required action"""
    #         # Wildcard match
    #         if action == "*":
    #             return True

    #         # Exact match
    #         if action == required_action:
    #             return True

            # Hierarchical match (e.g., "read" matches "compilation:read")
    #         if ":" in required_action:
    resource_type, permission = required_action.split(":", 1)
    #             if action == permission:
    #                 return True

    #         return False

    #     def _match_resource(self, resource: Dict[str, Any],
    resource_type: str, resource_id: str = None,
    resource_attributes: Dict[str, Any] = None) - bool):
    #         """Check if a resource matches a resource definition"""
    #         for key, expected_value in resource.items():
    #             # Handle variable substitution
    #             if isinstance(expected_value, str) and expected_value.startswith("${") and expected_value.endswith("}"):
    #                 # Variable substitution
    var_name = expected_value[2: - 1]
    #                 if var_name == "resource.type":
    actual_value = resource_type
    #                 elif var_name == "resource.id":
    actual_value = resource_id
    #                 elif var_name.startswith("resource."):
    attr_name = var_name[9:]
    #                     actual_value = resource_attributes.get(attr_name) if resource_attributes else None
    #                 else:
                        logger.warning(f"Unknown variable: {var_name}")
    #                     return False
    #             else:
    #                 # Direct value
    #                 if key == "type":
    actual_value = resource_type
    #                 elif key == "id":
    actual_value = resource_id
    #                 elif key.startswith("attr."):
    attr_name = key[5:]
    #                     actual_value = resource_attributes.get(attr_name) if resource_attributes else None
    #                 else:
                        logger.warning(f"Unknown resource attribute: {key}")
    #                     return False

    #             # Check match
    #             if actual_value == "*" or actual_value == expected_value:
    #                 continue

    #             if actual_value != expected_value:
    #                 return False

    #         return True

    #     def _has_permission_from_roles(self, user: User, resource_type: str,
    #                                  permission: str) -bool):
    #         """Check if a user has permission from roles"""
    #         # Get all user roles
    user_roles = []
    #         for role_id in user.roles:
    role = self.roles.get(role_id)
    #             if role:
                    user_roles.append(role)

    #         # Check permissions
    required_permission = f"{resource_type}:{permission}"
    #         for role in user_roles:
    #             if required_permission in role.permissions:
    #                 return True

    #             # Check for admin permission
    admin_permission = f"{resource_type}:admin"
    #             if admin_permission in role.permissions:
    #                 return True

    #         return False

    #     def check_permission(self, user: User, resource_type: str,
    permission: str, resource_id: str = None,
    resource_attributes: Dict[str, Any] = None,
    context: Dict[str, Any] = None) - bool):
    #         """Check if a user has permission for a resource"""
    #         # Prepare context
    context = context or {}
            context.update({
                "user": user.to_dict(),
    #             "resource_type": resource_type,
    #             "permission": permission,
    #             "resource_id": resource_id,
    #             "resource_attributes": resource_attributes or {}
    #         })

    #         # Get applicable policies
    applicable_policies = []
    #         for policy in self.policies.values():
    #             # Check if user matches principal
    #             if self._match_principal(policy.principal, user):
    #                 # Check if action matches
    #                 if self._match_action(policy.action, permission):
    #                     # Check if resource matches
    #                     if self._match_resource(policy.resource, resource_type, resource_id, resource_attributes):
    #                         # Check condition
    #                         if self._evaluate_condition(policy.condition, context):
                                applicable_policies.append(policy)

            # Sort policies by priority (descending)
    applicable_policies.sort(key = lambda p: p.priority, reverse=True)

    #         # Evaluate policies
    #         for policy in applicable_policies:
    #             if policy.effect == "deny":
    #                 return False
    #             elif policy.effect == "allow":
    #                 return True

    #         # Default: check roles
            return self._has_permission_from_roles(user, resource_type, permission)

    #     def check_permissions(self, user: User, permissions: List[Tuple[str, str]],
    resource_ids: List[str] = None,
    resource_attributes_list: List[Dict[str, Any]] = None,
    context: Dict[str, Any] = None) - Dict[Tuple[str, str], bool]):
    #         """Check multiple permissions for a user"""
    results = {}

    #         for i, (resource_type, permission) in enumerate(permissions):
    #             resource_id = resource_ids[i] if resource_ids and i < len(resource_ids) else None
    #             resource_attributes = resource_attributes_list[i] if resource_attributes_list and i < len(resource_attributes_list) else None

    results[(resource_type, permission)] = self.check_permission(
    #                 user, resource_type, permission, resource_id, resource_attributes, context
    #             )

    #         return results

    #     def require_permission(self, resource_type: str, permission: str,
    resource_id: str = None,
    resource_attributes: Dict[str, Any] = None,
    context: Dict[str, Any] = None):
    #         """Decorator to require permission for a function"""
    #         def decorator(func):
                wraps(func)
    #             def wrapper(self, *args, **kwargs):
    #                 # Get user from kwargs or self
    user = kwargs.get("user")
    #                 if not user and hasattr(self, "user"):
    user = self.user

    #                 if not user:
                        raise PermissionError("Authentication required")

    #                 # Check permission
    #                 if not self.check_permission(
    #                     user, resource_type, permission, resource_id, resource_attributes, context
    #                 ):
                        raise PermissionError(f"Permission denied: {resource_type}:{permission}")

                    return func(self, *args, **kwargs)

    #             return wrapper
    #         return decorator

    #     def require_permission_async(self, resource_type: str, permission: str,
    resource_id: str = None,
    resource_attributes: Dict[str, Any] = None,
    context: Dict[str, Any] = None):
    #         """Decorator to require permission for an async function"""
    #         def decorator(func):
                wraps(func)
    #             async def wrapper(self, *args, **kwargs):
    #                 # Get user from kwargs or self
    user = kwargs.get("user")
    #                 if not user and hasattr(self, "user"):
    user = self.user

    #                 if not user:
                        raise PermissionError("Authentication required")

    #                 # Check permission
    #                 if not self.check_permission(
    #                     user, resource_type, permission, resource_id, resource_attributes, context
    #                 ):
                        raise PermissionError(f"Permission denied: {resource_type}:{permission}")

                    return await func(self, *args, **kwargs)

    #             return wrapper
    #         return decorator


class PermissionError(Exception)
    #     """Permission error"""
    #     pass


# Global authorization manager instance
_authorization_manager = None


def get_authorization_manager() -AuthorizationManager):
#     """Get the global authorization manager instance"""
#     global _authorization_manager

#     if _authorization_manager is None:
_authorization_manager = AuthorizationManager()

#     return _authorization_manager


function initialize_authorization_manager()
    #     """Initialize the global authorization manager"""
    #     global _authorization_manager

    #     if _authorization_manager is not None:
            logger.warning("Authorization manager already initialized")
    #         return

    _authorization_manager = AuthorizationManager()

        logger.info("Authorization manager initialized")


function shutdown_authorization_manager()
    #     """Shutdown the global authorization manager"""
    #     global _authorization_manager

    #     if _authorization_manager is not None:
    _authorization_manager = None

        logger.info("Authorization manager shutdown")


# Decorators for easy use
def require_permission(resource_type: str, permission: str,
resource_id: str = None,
resource_attributes: Dict[str, Any] = None,
context: Dict[str, Any] = None):
#     """Decorator to require permission for a function"""
auth_manager = get_authorization_manager()
    return auth_manager.require_permission(
#         resource_type, permission, resource_id, resource_attributes, context
#     )


def require_permission_async(resource_type: str, permission: str,
resource_id: str = None,
resource_attributes: Dict[str, Any] = None,
context: Dict[str, Any] = None):
#     """Decorator to require permission for an async function"""
auth_manager = get_authorization_manager()
    return auth_manager.require_permission_async(
#         resource_type, permission, resource_id, resource_attributes, context
#     )