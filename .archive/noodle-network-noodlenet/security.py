"""
Noodle Network Noodlenet::Security - security.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Capability-based security model voor NoodleNet - Distributed authorization
"""

import asyncio
import time
import hashlib
import json
import logging
from typing import Dict, List, Optional, Set, Any, Callable, Tuple
from dataclasses import dataclass, field
from enum import Enum
from .config import NoodleNetConfig
from .identity import NodeIdentity, NoodleIdentityManager

logger = logging.getLogger(__name__)


class Permission(Enum):
    """Permissions in het systeem"""
    READ = "read"
    WRITE = "write"
    EXECUTE = "execute"
    ADMIN = "admin"
    NETWORK = "network"
    SCHEDULE = "schedule"
    MONITOR = "monitor"


class SecurityLevel(Enum):
    """Security levels voor capabilities"""
    PUBLIC = 0
    INTERNAL = 1
    RESTRICTED = 2
    CONFIDENTIAL = 3
    CRITICAL = 4


@dataclass
class Capability:
    """Representatie van een capability"""
    
    name: str
    permissions: Set[Permission]
    security_level: SecurityLevel
    resource: Optional[str] = None
    conditions: Dict[str, Any] = field(default_factory=dict)
    expires_at: Optional[float] = None
    created_at: float = field(default_factory=time.time)
    
    def is_valid(self) -> bool:
        """Controleer of capability nog geldig is"""
        if self.expires_at and time.time() > self.expires_at:
            return False
        return True
    
    def has_permission(self, permission: Permission) -> bool:
        """Controleer of capability een permissie heeft"""
        return permission in self.permissions
    
    def to_dict(self) -> Dict[str, Any]:
        """Converteer naar dictionary"""
        return {
            'name': self.name,
            'permissions': [p.value for p in self.permissions],
            'security_level': self.security_level.value,
            'resource': self.resource,
            'conditions': self.conditions,
            'expires_at': self.expires_at,
            'created_at': self.created_at
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "Capability":
        """Maak Capability vanaf dictionary"""
        return cls(
            name=data['name'],
            permissions={Permission(p) for p in data['permissions']},
            security_level=SecurityLevel(data['security_level']),
            resource=data.get('resource'),
            conditions=data.get('conditions', {}),
            expires_at=data.get('expires_at'),
            created_at=data.get('created_at', time.time())
        )


@dataclass
class SecurityContext:
    """Security context voor een operatie"""
    
    requester_id: str
    target_id: Optional[str]
    operation: str
    resource: Optional[str]
    timestamp: float = field(default_factory=time.time)
    metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass
class SecurityPolicy:
    """Security policy rule"""
    
    name: str
    description: str
    conditions: Dict[str, Any]
    actions: List[str]
    priority: int = 0
    enabled: bool = True


@dataclass
class SecurityToken:
    """Security token voor authenticated communicatie"""
    
    token_id: str
    issuer_id: str
    subject_id: str
    capabilities: List[Capability]
    issued_at: float
    expires_at: float
    signature: Optional[str] = None
    
    def is_valid(self) -> bool:
        """Controleer of token geldig is"""
        current_time = time.time()
        return current_time < self.expires_at and current_time >= self.issued_at
    
    def has_capability(self, capability_name: str, permission: Permission) -> bool:
        """Controleer of token een capability heeft"""
        for capability in self.capabilities:
            if capability.name == capability_name and capability.has_permission(permission):
                return capability.is_valid()
        return False
    
    def to_dict(self) -> Dict[str, Any]:
        """Converteer naar dictionary"""
        return {
            'token_id': self.token_id,
            'issuer_id': self.issuer_id,
            'subject_id': self.subject_id,
            'capabilities': [cap.to_dict() for cap in self.capabilities],
            'issued_at': self.issued_at,
            'expires_at': self.expires_at
        }


class CapabilitySecurityManager:
    """Manager voor capability-based security in NoodleNet"""
    
    def __init__(self, identity_manager: NoodleIdentityManager,
                 config: Optional[NoodleNetConfig] = None):
        """
        Initialiseer security manager
        
        Args:
            identity_manager: NoodleIdentityManager instance
            config: NoodleNet configuratie
        """
        self.identity_manager = identity_manager
        self.config = config or NoodleNetConfig()
        
        # Security state
        self._running = False
        self._node_capabilities: Dict[str, List[Capability]] = {}
        self._security_tokens: Dict[str, SecurityToken] = {}
        self._security_policies: List[SecurityPolicy] = []
        
        # Audit logging
        self._audit_log: List[Dict[str, Any]] = []
        
        # Event handlers
        self._security_violation_handlers: List[Callable] = []
        self._access_granted_handlers: List[Callable] = []
        self._access_denied_handlers: List[Callable] = []
        
        # Background tasks
        self._cleanup_task: Optional[asyncio.Task] = None
        
        # Statistics
        self._stats = {
            'access_requests': 0,
            'access_granted': 0,
            'access_denied': 0,
            'security_violations': 0,
            'tokens_issued': 0,
            'tokens_expired': 0,
        }
    
    async def start(self):
        """Start de security manager"""
        if self._running:
            logger.warning("Security manager is already running")
            return
        
        self._running = True
        
        # Laad standaard policies
        self._load_default_policies()
        
        # Start cleanup task
        self._cleanup_task = asyncio.create_task(self._cleanup_loop())
        
        logger.info("Capability security manager started")
    
    async def stop(self):
        """Stop de security manager"""
        if not self._running:
            return
        
        self._running = False
        
        # Stop cleanup task
        if self._cleanup_task:
            self._cleanup_task.cancel()
            try:
                await self._cleanup_task
            except asyncio.CancelledError:
                pass
        
        logger.info("Capability security manager stopped")
    
    def grant_capability(self, node_id: str, capability: Capability):
        """
        Verleen een capability aan een node
        
        Args:
            node_id: ID van de node
            capability: Capability om te verlenen
        """
        if node_id not in self._node_capabilities:
            self._node_capabilities[node_id] = []
        
        # Controleer of capability al bestaat
        existing_caps = [cap for cap in self._node_capabilities[node_id] 
                       if cap.name == capability.name]
        
        if existing_caps:
            # Update bestaande capability
            for existing_cap in existing_caps:
                self._node_capabilities[node_id].remove(existing_cap)
        
        # Voeg nieuwe capability toe
        self._node_capabilities[node_id].append(capability)
        
        # Log audit
        self._log_audit_event("capability_granted", {
            'node_id': node_id,
            'capability': capability.name,
            'permissions': [p.value for p in capability.permissions],
            'security_level': capability.security_level.value
        })
        
        logger.info(f"Granted capability '{capability.name}' to node {node_id}")
    
    def revoke_capability(self, node_id: str, capability_name: str):
        """
        Trek een capability van een node in
        
        Args:
            node_id: ID van de node
            capability_name: Naam van de capability
        """
        if node_id not in self._node_capabilities:
            return
        
        # Verwijder capability
        original_count = len(self._node_capabilities[node_id])
        self._node_capabilities[node_id] = [
            cap for cap in self._node_capabilities[node_id]
            if cap.name != capability_name
        ]
        
        # Controleer of verwijderd
        if len(self._node_capabilities[node_id]) < original_count:
            # Log audit
            self._log_audit_event("capability_revoked", {
                'node_id': node_id,
                'capability': capability_name
            })
            
            logger.info(f"Revoked capability '{capability_name}' from node {node_id}")
    
    def check_permission(self, context: SecurityContext) -> Tuple[bool, str]:
        """
        Controleer permissies voor een operatie
        
        Args:
            context: Security context voor de operatie
            
        Returns:
            Tuple van (toegestaan, reden)
        """
        self._stats['access_requests'] += 1
        
        # Controleer of requester bekend is
        requester_identity = self.identity_manager.get_node(context.requester_id)
        if not requester_identity:
            self._stats['access_denied'] += 1
            return False, "Unknown requester"
        
        # Controleer capabilities van requester
        requester_caps = self._node_capabilities.get(context.requester_id, [])
        
        # Vind relevante capability
        relevant_cap = None
        for cap in requester_caps:
            if cap.resource == context.resource or cap.resource is None:
                if cap.is_valid():
                    relevant_cap = cap
                    break
        
        if not relevant_cap:
            self._stats['access_denied'] += 1
            self._log_audit_event("access_denied", {
                'requester_id': context.requester_id,
                'operation': context.operation,
                'resource': context.resource,
                'reason': 'No valid capability'
            })
            return False, "No valid capability"
        
        # Controleer permissie
        required_permission = self._get_permission_for_operation(context.operation)
        if not relevant_cap.has_permission(required_permission):
            self._stats['access_denied'] += 1
            self._log_audit_event("access_denied", {
                'requester_id': context.requester_id,
                'operation': context.operation,
                'resource': context.resource,
                'reason': f'Permission {required_permission.value} not granted'
            })
            return False, f"Permission {required_permission.value} not granted"
        
        # Controleer security level
        if not self._check_security_level(relevant_cap, context):
            self._stats['access_denied'] += 1
            self._log_audit_event("access_denied", {
                'requester_id': context.requester_id,
                'operation': context.operation,
                'resource': context.resource,
                'reason': 'Security level insufficient'
            })
            return False, "Security level insufficient"
        
        # Controleer policies
        policy_result = self._check_policies(context, relevant_cap)
        if not policy_result[0]:
            self._stats['access_denied'] += 1
            self._log_audit_event("access_denied", {
                'requester_id': context.requester_id,
                'operation': context.operation,
                'resource': context.resource,
                'reason': policy_result[1]
            })
            return False, policy_result[1]
        
        # Toegang toegestaan
        self._stats['access_granted'] += 1
        self._log_audit_event("access_granted", {
            'requester_id': context.requester_id,
            'operation': context.operation,
            'resource': context.resource,
            'capability': relevant_cap.name
        })
        
        # Roep handlers aan
        for handler in self._access_granted_handlers:
            try:
                await handler(context, relevant_cap)
            except Exception as e:
                logger.error(f"Error in access granted handler: {e}")
        
        return True, "Access granted"
    
    def issue_security_token(self, issuer_id: str, subject_id: str,
                           capabilities: List[Capability],
                           validity_hours: float = 24.0) -> Optional[SecurityToken]:
        """
        Geef een security token uit
        
        Args:
            issuer_id: ID van de uitgever
            subject_id: ID van de ontvanger
            capabilities: Lijst van capabilities
            validity_hours: Geldigheidsduur in uren
            
        Returns:
            SecurityToken of None bij fout
        """
        # Controleer rechten van issuer
        issuer_context = SecurityContext(
            requester_id=issuer_id,
            operation="issue_token",
            resource="security"
        )
        
        has_permission, reason = self.check_permission(issuer_context)
        if not has_permission:
            logger.error(f"Token issuance denied: {reason}")
            return None
        
        # Maak token
        current_time = time.time()
        token = SecurityToken(
            token_id=self._generate_token_id(),
            issuer_id=issuer_id,
            subject_id=subject_id,
            capabilities=capabilities,
            issued_at=current_time,
            expires_at=current_time + (validity_hours * 3600)
        )
        
        # Teken token
        token.signature = self._sign_token(token)
        
        # Sla token op
        self._security_tokens[token.token_id] = token
        
        # Update statistieken
        self._stats['tokens_issued'] += 1
        
        # Log audit
        self._log_audit_event("token_issued", {
            'token_id': token.token_id,
            'issuer_id': issuer_id,
            'subject_id': subject_id,
            'capabilities': [cap.name for cap in capabilities],
            'expires_at': token.expires_at
        })
        
        logger.info(f"Security token issued: {token.token_id} for {subject_id}")
        return token
    
    def validate_token(self, token_id: str, operation: str,
                     resource: Optional[str] = None) -> Tuple[bool, str]:
        """
        Valideer een security token
        
        Args:
            token_id: ID van het token
            operation: Operatie om uit te voeren
            resource: Resource voor de operatie
            
        Returns:
            Tuple van (geldig, reden)
        """
        # Controleer of token bestaat
        token = self._security_tokens.get(token_id)
        if not token:
            return False, "Token not found"
        
        # Controleer geldigheid
        if not token.is_valid():
            self._stats['tokens_expired'] += 1
            return False, "Token expired"
        
        # Controleer permissie
        required_permission = self._get_permission_for_operation(operation)
        if not token.has_capability(resource or "any", required_permission):
            return False, f"Permission {required_permission.value} not granted"
        
        return True, "Token valid"
    
    def revoke_token(self, token_id: str):
        """
        Trek een token in
        
        Args:
            token_id: ID van het token
        """
        if token_id in self._security_tokens:
            del self._security_tokens[token_id]
            
            # Log audit
            self._log_audit_event("token_revoked", {
                'token_id': token_id
            })
            
            logger.info(f"Security token revoked: {token_id}")
    
    def add_security_policy(self, policy: SecurityPolicy):
        """
        Voeg een security policy toe
        
        Args:
            policy: Security policy om toe te voegen
        """
        self._security_policies.append(policy)
        
        # Sorteer op prioriteit
        self._security_policies.sort(key=lambda p: p.priority, reverse=True)
        
        logger.info(f"Security policy added: {policy.name}")
    
    def remove_security_policy(self, policy_name: str):
        """
        Verwijder een security policy
        
        Args:
            policy_name: Naam van de policy
        """
        original_count = len(self._security_policies)
        self._security_policies = [
            policy for policy in self._security_policies
            if policy.name != policy_name
        ]
        
        if len(self._security_policies) < original_count:
            logger.info(f"Security policy removed: {policy_name}")
    
    def get_node_capabilities(self, node_id: str) -> List[Capability]:
        """
        Krijg capabilities van een node
        
        Args:
            node_id: ID van de node
            
        Returns:
            Lijst met capabilities
        """
        return self._node_capabilities.get(node_id, [])
    
    def get_audit_log(self, limit: int = 100) -> List[Dict[str, Any]]:
        """
        Krijg audit log entries
        
        Args:
            limit: Maximum aantal entries
            
        Returns:
            Lijst met audit log entries
        """
        return self._audit_log[-limit:]
    
    def get_statistics(self) -> Dict[str, Any]:
        """
        Krijg security statistieken
        
        Returns:
            Dictionary met statistieken
        """
        stats = self._stats.copy()
        stats['running'] = self._running
        stats['nodes_with_capabilities'] = len(self._node_capabilities)
        stats['active_tokens'] = len(self._security_tokens)
        stats['security_policies'] = len(self._security_policies)
        return stats
    
    def _get_permission_for_operation(self, operation: str) -> Permission:
        """
        Bepaal benodigde permissie voor een operatie
        
        Args:
            operation: Naam van de operatie
            
        Returns:
            Benodigde permissie
        """
        operation_permissions = {
            'read': Permission.READ,
            'write': Permission.WRITE,
            'execute': Permission.EXECUTE,
            'admin': Permission.ADMIN,
            'network': Permission.NETWORK,
            'schedule': Permission.SCHEDULE,
            'monitor': Permission.MONITOR,
            'issue_token': Permission.ADMIN,
            'revoke_token': Permission.ADMIN
        }
        
        return operation_permissions.get(operation, Permission.READ)
    
    def _check_security_level(self, capability: Capability, context: SecurityContext) -> bool:
        """
        Controleer security level requirements
        
        Args:
            capability: Capability om te controleren
            context: Security context
            
        Returns:
            True als security level voldoet
        """
        # Haal security level van target resource op
        target_level = self._get_resource_security_level(context.resource)
        
        # Controleer of capability voldoet
        return capability.security_level.value >= target_level
    
    def _get_resource_security_level(self, resource: Optional[str]) -> int:
        """
        Krijg security level van een resource
        
        Args:
            resource: Resource naam
            
        Returns:
            Security level waarde
        """
        if not resource:
            return SecurityLevel.PUBLIC.value
        
        # Resource security levels
        resource_levels = {
            'public_data': SecurityLevel.PUBLIC.value,
            'internal_data': SecurityLevel.INTERNAL.value,
            'restricted_data': SecurityLevel.RESTRICTED.value,
            'confidential_data': SecurityLevel.CONFIDENTIAL.value,
            'critical_data': SecurityLevel.CRITICAL.value,
            'admin_functions': SecurityLevel.CRITICAL.value,
            'security_config': SecurityLevel.CRITICAL.value
        }
        
        return resource_levels.get(resource, SecurityLevel.INTERNAL.value)
    
    def _check_policies(self, context: SecurityContext, capability: Capability) -> Tuple[bool, str]:
        """
        Controleer security policies
        
        Args:
            context: Security context
            capability: Gebruikte capability
            
        Returns:
            Tuple van (toegestaan, reden)
        """
        for policy in self._security_policies:
            if not policy.enabled:
                continue
            
            # Controleer of policy van toepassing is
            if self._policy_matches(policy, context, capability):
                # Controleer acties
                if "deny" in policy.actions:
                    return False, f"Denied by policy: {policy.name}"
                elif "allow" in policy.actions:
                    return True, f"Allowed by policy: {policy.name}"
        
        # Default: toestaan als geen policy matched
        return True, "No matching policies"
    
    def _policy_matches(self, policy: SecurityPolicy, context: SecurityContext,
                       capability: Capability) -> bool:
        """
        Controleer of een policy van toepassing is
        
        Args:
            policy: Security policy
            context: Security context
            capability: Gebruikte capability
            
        Returns:
            True als policy van toepassing is
        """
        conditions = policy.conditions
        
        # Controleer requester
        if 'requester' in conditions:
            if context.requester_id not in conditions['requester']:
                return False
        
        # Controleer operation
        if 'operation' in conditions:
            if context.operation not in conditions['operation']:
                return False
        
        # Controleer resource
        if 'resource' in conditions:
            if context.resource not in conditions['resource']:
                return False
        
        # Controleer capability
        if 'capability' in conditions:
            if capability.name not in conditions['capability']:
                return False
        
        # Controleer security level
        if 'min_security_level' in conditions:
            if capability.security_level.value < conditions['min_security_level']:
                return False
        
        return True
    
    def _generate_token_id(self) -> str:
        """Genereer unieke token ID"""
        import uuid
        return str(uuid.uuid4())
    
    def _sign_token(self, token: SecurityToken) -> str:
        """
        Teken een token met digitale handtekening
        
        Args:
            token: Token om te tekenen
            
        Returns:
            Digitale handtekening
        """
        # Simuleer digitale handtekening
        # In echte implementatie: RSA/ECDSA handtekening
        token_data = json.dumps(token.to_dict(), sort_keys=True)
        return hashlib.sha256(token_data.encode()).hexdigest()
    
    def _load_default_policies(self):
        """Laad standaard security policies"""
        # Admin policy
        self.add_security_policy(SecurityPolicy(
            name="admin_access",
            description="Admin access to critical functions",
            conditions={
                'resource': ['admin_functions', 'security_config'],
                'min_security_level': SecurityLevel.CRITICAL.value
            },
            actions=["allow"],
            priority=100
        ))
        
        # Network policy
        self.add_security_policy(SecurityPolicy(
            name="network_access",
            description="Network communication access",
            conditions={
                'operation': ['network'],
                'min_security_level': SecurityLevel.INTERNAL.value
            },
            actions=["allow"],
            priority=50
        ))
        
        # Data access policy
        self.add_security_policy(SecurityPolicy(
            name="data_access",
            description="Data access based on classification",
            conditions={
                'resource': ['confidential_data', 'critical_data'],
                'min_security_level': SecurityLevel.CONFIDENTIAL.value
            },
            actions=["allow"],
            priority=75
        ))
        
        # Deny policy voor onbekende operaties
        self.add_security_policy(SecurityPolicy(
            name="default_deny",
            description="Default deny for unknown operations",
            conditions={},
            actions=["deny"],
            priority=0
        ))
    
    def _log_audit_event(self, event_type: str, data: Dict[str, Any]):
        """
        Log een audit event
        
        Args:
            event_type: Type van het event
            data: Event data
        """
        audit_entry = {
            'timestamp': time.time(),
            'event_type': event_type,
            'data': data
        }
        
        self._audit_log.append(audit_entry)
        
        # Houd audit log beperkt
        if len(self._audit_log) > 10000:
            self._audit_log = self._audit_log[-5000:]
    
    async def _cleanup_loop(self):
        """Loop voor opruimen van verlopen data"""
        while self._running:
            try:
                current_time = time.time()
                
                # Verwijder verlopen capabilities
                for node_id, capabilities in self._node_capabilities.items():
                    original_count = len(capabilities)
                    self._node_capabilities[node_id] = [
                        cap for cap in capabilities
                        if cap.is_valid()
                    ]
                    
                    if len(self._node_capabilities[node_id]) < original_count:
                        logger.info(f"Cleaned expired capabilities for node {node_id}")
                
                # Verwijder verlopen tokens
                expired_tokens = [
                    token_id for token_id, token in self._security_tokens.items()
                    if not token.is_valid()
                ]
                
                for token_id in expired_tokens:
                    del self._security_tokens[token_id]
                    self._stats['tokens_expired'] += 1
                
                if expired_tokens:
                    logger.info(f"Cleaned {len(expired_tokens)} expired tokens")
                
                # Wacht voor volgende cleanup
                await asyncio.sleep(300)  # 5 minuten
                
            except Exception as e:
                logger.error(f"Error in cleanup loop: {e}")
                await asyncio.sleep(60)
    
    def register_security_violation_handler(self, handler: Callable):
        """Registreer handler voor security violations"""
        self._security_violation_handlers.append(handler)
    
    def register_access_granted_handler(self, handler: Callable):
        """Registreer handler voor access granted events"""
        self._access_granted_handlers.append(handler)
    
    def register_access_denied_handler(self, handler: Callable):
        """Registreer handler voor access denied events"""
        self._access_denied_handlers.append(handler)
    
    def is_running(self) -> bool:
        """Controleer of security manager actief is"""
        return self._running
    
    def __str__(self) -> str:
        """String representatie"""
        return f"CapabilitySecurityManager(nodes={len(self._node_capabilities)}, running={self._running})"
    
    def __repr__(self) -> str:
        """Debug representatie"""
        return (f"CapabilitySecurityManager(nodes={len(self._node_capabilities)}, "
                f"tokens={len(self._security_tokens)}, "
                f"policies={len(self._security_policies)}, "
                f"running={self._running})")

