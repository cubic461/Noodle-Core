"""
Noodlenet::Security - security.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Capability-based security for NoodleNet distributed systems.

This module implements a zero-trust security model with capability-based
access control, encryption, and audit logging.
"""

import asyncio
import time
import hashlib
import hmac
import json
import logging
from typing import Dict, Set, List, Optional, Any, Callable, Tuple
from dataclasses import dataclass, field
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from cryptography.hazmat.backends import default_backend
from .config import NoodleNetConfig
from .identity import NodeIdentity

logger = logging.getLogger(__name__)


@dataclass
class Capability:
    """Represents a security capability"""
    
    name: str
    permissions: Set[str]
    resources: Set[str]
    expires_at: Optional[float] = None
    delegated_from: Optional[str] = None
    constraints: Dict[str, Any] = field(default_factory=dict)
    
    def __post_init__(self):
        """Validate capability after initialization"""
        if not self.name:
            raise ValueError("Capability name cannot be empty")
        
        if not self.permissions:
            raise ValueError("Capability must have at least one permission")
    
    def is_expired(self) -> bool:
        """Check if capability has expired"""
        if self.expires_at is None:
            return False
        return time.time() > self.expires_at
    
    def has_permission(self, permission: str) -> bool:
        """Check if capability grants a specific permission"""
        return permission in self.permissions
    
    def can_access_resource(self, resource: str) -> bool:
        """Check if capability can access a specific resource"""
        return resource in self.resources
    
    def can_perform_action(self, action: str, resource: str = None) -> bool:
        """
        Check if capability can perform a specific action
        
        Args:
            action: Action to perform
            resource: Optional resource to access
            
        Returns:
            True if action is permitted
        """
        # Check if action is in permissions
        if not self.has_permission(action):
            return False
        
        # Check resource constraints if specified
        if resource and not self.can_access_resource(resource):
            return False
        
        # Check additional constraints
        if 'actions' in self.constraints:
            allowed_actions = self.constraints['actions'].get(resource, set())
            if action not in allowed_actions:
                return False
        
        return True
    
    def serialize(self) -> str:
        """Serialize capability to string"""
        capability_data = {
            'name': self.name,
            'permissions': list(self.permissions),
            'resources': list(self.resources),
            'expires_at': self.expires_at,
            'delegated_from': self.delegated_from,
            'constraints': self.constraints
        }
        return json.dumps(capability_data)
    
    @classmethod
    def deserialize(cls, data: str) -> "Capability":
        """Deserialize capability from string"""
        try:
            capability_data = json.loads(data)
            return cls(
                name=capability_data['name'],
                permissions=set(capability_data['permissions']),
                resources=set(capability_data['resources']),
                expires_at=capability_data.get('expires_at'),
                delegated_from=capability_data.get('delegated_from'),
                constraints=capability_data.get('constraints', {})
            )
        except (json.JSONDecodeError, KeyError) as e:
            logger.error(f"Failed to deserialize capability: {e}")
            raise ValueError(f"Invalid capability data: {e}")
    
    def __str__(self) -> str:
        """String representation"""
        return f"Capability({self.name}, permissions={len(self.permissions)}, resources={len(self.resources)})"
    
    def __repr__(self) -> str:
        """Debug representation"""
        return (f"Capability(name='{self.name}', "
                f"permissions={list(self.permissions)}, "
                f"resources={list(self.resources)}, "
                f"expires_at={self.expires_at})")


@dataclass
class SecurityContext:
    """Security context for a message or operation"""
    
    requester_id: str
    capabilities: List[Capability]
    timestamp: float = field(default_factory=time.time)
    message_id: Optional[str] = None
    action: str
    resource: Optional[str] = None
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def validate(self) -> bool:
        """Validate the security context"""
        if not self.requester_id:
            return False
        
        if not self.capabilities:
            return False
        
        if not self.action:
            return False
        
        # Check if any capability is expired
        if any(cap.is_expired() for cap in self.capabilities):
            return False
        
        return True
    
    def can_perform_action(self, action: str, resource: str = None) -> bool:
        """
        Check if the context allows performing an action
        
        Args:
            action: Action to perform
            resource: Optional resource to access
            
        Returns:
            True if action is permitted
        """
        # Check if any capability allows the action
        return any(cap.can_perform_action(action, resource) for cap in self.capabilities)


class CapabilityManager:
    """Manages capabilities and security contexts"""
    
    def __init__(self, local_node_id: str, config: Optional[NoodleNetConfig] = None):
        """
        Initialize capability manager
        
        Args:
            local_node_id: ID of the local node
            config: NoodleNet configuration
        """
        self.local_node_id = local_node_id
        self.config = config or NoodleNetConfig()
        
        # Capability storage
        self.issued_capabilities: Dict[str, Capability] = {}  # capability_id -> Capability
        self.active_contexts: Dict[str, SecurityContext] = {}  # context_id -> SecurityContext
        
        # Security policies
        self.policies: Dict[str, Dict[str, Any]] = {}
        self.default_policies: Dict[str, Dict[str, Any]] = {
            'node_management': {
                'max_capabilities_per_node': 10,
                'max_delegation_depth': 3,
                'capability_lifetime': 3600  # 1 hour
            },
            'data_access': {
                'require_encryption': True,
                'audit_access': True,
                'max_access_duration': 300  # 5 minutes
            },
            'system_operations': {
                'require_multi_factor': True,
                'require_admin_approval': True,
                'audit_all_operations': True
            }
        }
        
        # Encryption
        self.encryption_key: Optional[bytes] = None
        self.cipher: Optional[Fernet] = None
        
        # Audit logging
        self.audit_log: List[Dict[str, Any]] = []
        
        # Statistics
        self._stats = {
            'capabilities_issued': 0,
            'capabilities_revoked': 0,
            'contexts_created': 0,
            'contexts_validated': 0,
            'access_denied': 0,
            'access_granted': 0,
            'security_violations': 0
        }
        
        # Initialize encryption
        self._initialize_encryption()
    
    def _initialize_encryption(self):
        """Initialize encryption capabilities"""
        try:
            if self.config.encryption_key:
                # Use provided key
                self.encryption_key = self.config.encryption_key.encode()
            else:
                # Generate new key
                self.encryption_key = Fernet.generate_key()
            
            self.cipher = Fernet(self.encryption_key)
            logger.info("Encryption initialized successfully")
            
        except Exception as e:
            logger.error(f"Failed to initialize encryption: {e}")
            self.encryption_key = None
            self.cipher = None
    
    def issue_capability(self, requester_id: str, capability_name: str,
                      permissions: Set[str], resources: Set[str],
                      expires_at: Optional[float] = None,
                      delegated_from: Optional[str] = None,
                      constraints: Optional[Dict[str, Any]] = None) -> str:
        """
        Issue a new capability
        
        Args:
            requester_id: ID of the requesting node
            capability_name: Name of the capability
            permissions: Set of permissions granted
            resources: Set of resources accessible
            expires_at: Optional expiration time
            delegated_from: Optional delegating node ID
            constraints: Optional additional constraints
            
        Returns:
            Capability ID
        """
        # Check policy constraints
        policy = self.policies.get(capability_name, self.default_policies.get('node_management', {}))
        
        # Check maximum capabilities per node
        if 'max_capabilities_per_node' in policy:
            requester_capabilities = [
                cap_id for cap_id, cap in self.issued_capabilities.items()
                if cap.name == capability_name and cap.delegated_from == requester_id
            ]
            if len(requester_capabilities) >= policy['max_capabilities_per_node']:
                raise PermissionError(f"Maximum capabilities exceeded for {capability_name}")
        
        # Set default expiration if not provided
        if expires_at is None:
            expires_at = time.time() + policy.get('capability_lifetime', 3600)
        
        # Create capability
        capability = Capability(
            name=capability_name,
            permissions=permissions,
            resources=resources,
            expires_at=expires_at,
            delegated_from=delegated_from,
            constraints=constraints or {}
        )
        
        # Generate capability ID
        capability_id = self._generate_capability_id(requester_id, capability_name)
        
        # Store capability
        self.issued_capabilities[capability_id] = capability
        
        # Log issuance
        self._log_security_event('capability_issued', {
            'capability_id': capability_id,
            'requester_id': requester_id,
            'capability_name': capability_name,
            'permissions': list(permissions),
            'resources': list(resources),
            'expires_at': expires_at,
            'delegated_from': delegated_from
        })
        
        self._stats['capabilities_issued'] += 1
        
        return capability_id
    
    def revoke_capability(self, capability_id: str, revoker_id: str) -> bool:
        """
        Revoke a capability
        
        Args:
            capability_id: ID of capability to revoke
            revoker_id: ID of the revoking node
            
        Returns:
            True if successfully revoked
        """
        if capability_id not in self.issued_capabilities:
            logger.warning(f"Capability {capability_id} not found for revocation")
            return False
        
        capability = self.issued_capabilities[capability_id]
        
        # Check if revoker has authority
        if not self._can_revoke_capability(revoker_id, capability):
            logger.warning(f"Node {revoker_id} not authorized to revoke capability {capability_id}")
            return False
        
        # Remove capability
        del self.issued_capabilities[capability_id]
        
        # Log revocation
        self._log_security_event('capability_revoked', {
            'capability_id': capability_id,
            'revoker_id': revoker_id,
            'capability_name': capability.name,
            'original_requester': capability.delegated_from
        })
        
        self._stats['capabilities_revoked'] += 1
        
        return True
    
    def create_security_context(self, requester_id: str, capability_ids: List[str],
                           action: str, resource: Optional[str] = None,
                           message_id: Optional[str] = None,
                           metadata: Optional[Dict[str, Any]] = None) -> Optional[str]:
        """
        Create a security context for an operation
        
        Args:
            requester_id: ID of the requesting node
            capability_ids: List of capability IDs to use
            action: Action to perform
            resource: Optional resource to access
            message_id: Optional message ID
            metadata: Optional metadata
            
        Returns:
            Context ID if successful, None otherwise
        """
        # Get capabilities
        capabilities = []
        for cap_id in capability_ids:
            if cap_id not in self.issued_capabilities:
                logger.warning(f"Capability {cap_id} not found")
                return None
            capabilities.append(self.issued_capabilities[cap_id])
        
        # Create security context
        context = SecurityContext(
            requester_id=requester_id,
            capabilities=capabilities,
            action=action,
            resource=resource,
            message_id=message_id,
            metadata=metadata or {}
        )
        
        # Validate context
        if not context.validate():
            self._stats['access_denied'] += 1
            self._log_security_event('access_denied', {
                'requester_id': requester_id,
                'capability_ids': capability_ids,
                'action': action,
                'resource': resource,
                'reason': 'Invalid security context'
            })
            return None
        
        # Generate context ID
        context_id = self._generate_context_id(requester_id, action)
        
        # Store context
        self.active_contexts[context_id] = context
        
        # Log context creation
        self._log_security_event('context_created', {
            'context_id': context_id,
            'requester_id': requester_id,
            'capability_ids': capability_ids,
            'action': action,
            'resource': resource
        })
        
        self._stats['contexts_created'] += 1
        
        return context_id
    
    def validate_operation(self, context_id: str, action: str, 
                        resource: Optional[str] = None) -> bool:
        """
        Validate an operation against a security context
        
        Args:
            context_id: ID of security context
            action: Action to perform
            resource: Optional resource to access
            
        Returns:
            True if operation is permitted
        """
        if context_id not in self.active_contexts:
            self._stats['access_denied'] += 1
            self._log_security_event('access_denied', {
                'context_id': context_id,
                'action': action,
                'resource': resource,
                'reason': 'Invalid context ID'
            })
            return False
        
        context = self.active_contexts[context_id]
        
        # Validate operation
        if not context.can_perform_action(action, resource):
            self._stats['access_denied'] += 1
            self._log_security_event('access_denied', {
                'context_id': context_id,
                'requester_id': context.requester_id,
                'action': action,
                'resource': resource,
                'reason': 'Insufficient capabilities'
            })
            return False
        
        self._stats['access_granted'] += 1
        self._stats['contexts_validated'] += 1
        
        return True
    
    def encrypt_message(self, message: str, context_id: Optional[str] = None) -> Optional[bytes]:
        """
        Encrypt a message
        
        Args:
            message: Message to encrypt
            context_id: Optional security context ID
            
        Returns:
            Encrypted message or None if encryption failed
        """
        if not self.cipher:
            logger.warning("Encryption not available")
            return None
        
        try:
            # Add security metadata to message
            security_metadata = {
                'encrypted_at': time.time(),
                'context_id': context_id,
                'node_id': self.local_node_id
            }
            
            # Combine message with metadata
            message_data = {
                'content': message,
                'security': security_metadata
            }
            
            # Encrypt
            encrypted_data = self.cipher.encrypt(json.dumps(message_data).encode())
            
            self._log_security_event('message_encrypted', {
                'context_id': context_id,
                'message_length': len(message)
            })
            
            return encrypted_data
            
        except Exception as e:
            logger.error(f"Failed to encrypt message: {e}")
            return None
    
    def decrypt_message(self, encrypted_data: bytes) -> Optional[Dict[str, Any]]:
        """
        Decrypt a message
        
        Args:
            encrypted_data: Encrypted message data
            
        Returns:
            Decrypted message data or None if decryption failed
        """
        if not self.cipher:
            logger.warning("Decryption not available")
            return None
        
        try:
            # Decrypt
            decrypted_data = self.cipher.decrypt(encrypted_data).decode()
            message_data = json.loads(decrypted_data)
            
            # Validate security metadata
            if 'security' not in message_data:
                logger.warning("No security metadata in decrypted message")
                return None
            
            security_metadata = message_data['security']
            
            # Validate timestamp (prevent replay attacks)
            current_time = time.time()
            encrypted_at = security_metadata.get('encrypted_at', 0)
            if current_time - encrypted_at > 300:  # 5 minutes
                logger.warning("Message timestamp too old")
                return None
            
            self._log_security_event('message_decrypted', {
                'encrypted_by': security_metadata.get('node_id'),
                'encrypted_at': encrypted_at,
                'decrypted_at': current_time
            })
            
            return message_data
            
        except Exception as e:
            logger.error(f"Failed to decrypt message: {e}")
            return None
    
    def _can_revoke_capability(self, revoker_id: str, capability: Capability) -> bool:
        """
        Check if a node can revoke a capability
        
        Args:
            revoker_id: ID of the revoking node
            capability: Capability to check
            
        Returns:
            True if revocation is allowed
        """
        # Owner can always revoke
        if capability.delegated_from == revoker_id:
            return True
        
        # Admin capabilities can revoke any capability
        admin_context = self.active_contexts.get(revoker_id)
        if admin_context and any(cap.name == 'admin' for cap in admin_context.capabilities):
            return True
        
        # Check for revoke permission
        for context_id, context in self.active_contexts.items():
            if context.requester_id == revoker_id:
                if any(cap.has_permission('revoke') for cap in context.capabilities):
                    return True
        
        return False
    
    def _generate_capability_id(self, requester_id: str, capability_name: str) -> str:
        """Generate a unique capability ID"""
        timestamp = str(int(time.time()))
        data = f"{requester_id}:{capability_name}:{timestamp}"
        return hashlib.sha256(data.encode()).hexdigest()[:32]
    
    def _generate_context_id(self, requester_id: str, action: str) -> str:
        """Generate a unique context ID"""
        timestamp = str(int(time.time()))
        data = f"{requester_id}:{action}:{timestamp}"
        return hashlib.sha256(data.encode()).hexdigest()[:32]
    
    def _log_security_event(self, event_type: str, details: Dict[str, Any]):
        """
        Log a security event
        
        Args:
            event_type: Type of security event
            details: Event details
        """
        event = {
            'timestamp': time.time(),
            'node_id': self.local_node_id,
            'event_type': event_type,
            'details': details
        }
        
        self.audit_log.append(event)
        
        # Keep audit log size manageable
        if len(self.audit_log) > 10000:
            self.audit_log = self.audit_log[-5000:]
        
        logger.info(f"Security event: {event_type} - {details}")
    
    def cleanup_expired_capabilities(self):
        """Clean up expired capabilities and contexts"""
        current_time = time.time()
        
        # Clean up expired capabilities
        expired_capabilities = [
            cap_id for cap_id, cap in self.issued_capabilities.items()
            if cap.is_expired()
        ]
        
        for cap_id in expired_capabilities:
            del self.issued_capabilities[cap_id]
            logger.debug(f"Cleaned up expired capability: {cap_id}")
        
        # Clean up expired contexts
        expired_contexts = [
            ctx_id for ctx_id, ctx in self.active_contexts.items()
            if any(cap.is_expired() for cap in ctx.capabilities)
        ]
        
        for ctx_id in expired_contexts:
            del self.active_contexts[ctx_id]
            logger.debug(f"Cleaned up expired context: {ctx_id}")
        
        if expired_capabilities or expired_contexts:
            self._log_security_event('cleanup_expired', {
                'expired_capabilities': len(expired_capabilities),
                'expired_contexts': len(expired_contexts)
            })
    
    def get_security_statistics(self) -> Dict[str, Any]:
        """
        Get comprehensive security statistics
        
        Returns:
            Dictionary with security statistics
        """
        stats = self._stats.copy()
        stats['active_capabilities'] = len(self.issued_capabilities)
        stats['active_contexts'] = len(self.active_contexts)
        stats['audit_log_size'] = len(self.audit_log)
        stats['encryption_enabled'] = self.cipher is not None
        
        # Calculate security metrics
        if stats['contexts_validated'] > 0:
            stats['access_grant_rate'] = stats['access_granted'] / stats['contexts_validated']
        else:
            stats['access_grant_rate'] = 0.0
        
        return stats
    
    def get_audit_log(self, limit: int = 100) -> List[Dict[str, Any]]:
        """
        Get recent audit log entries
        
        Args:
            limit: Maximum number of entries to return
            
        Returns:
            List of audit log entries
        """
        return self.audit_log[-limit:]
    
    def set_policy(self, policy_name: str, policy: Dict[str, Any]):
        """
        Set a security policy
        
        Args:
            policy_name: Name of the policy
            policy: Policy configuration
        """
        self.policies[policy_name] = policy
        logger.info(f"Security policy updated: {policy_name}")
    
    def reset_statistics(self):
        """Reset all security statistics"""
        self._stats = {
            'capabilities_issued': 0,
            'capabilities_revoked': 0,
            'contexts_created': 0,
            'contexts_validated': 0,
            'access_denied': 0,
            'access_granted': 0,
            'security_violations': 0
        }
    
    def __str__(self) -> str:
        """String representation"""
        return f"CapabilityManager(capabilities={len(self.issued_capabilities)}, contexts={len(self.active_contexts)})"
    
    def __repr__(self) -> str:
        """Debug representation"""
        return (f"CapabilityManager(node_id='{self.local_node_id}', "
                f"capabilities={len(self.issued_capabilities)}, "
                f"contexts={len(self.active_contexts)}, "
                f"encryption_enabled={self.cipher is not None})")

