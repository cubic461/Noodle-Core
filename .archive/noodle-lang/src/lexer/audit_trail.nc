# Converted from Python to NoodleCore
# Original file: src

# """
# Audit Trail Module

# This module implements the comprehensive audit trail system for NoodleCore CLI.
# It includes cryptographic signatures, AI interaction tracking, and tamper-evident logging.
# """

import asyncio
import hashlib
import hmac
import json
import os
import time
import datetime.datetime
import enum.Enum
import pathlib.Path
import typing.Dict
import cryptography.hazmat.primitives.hashes
import cryptography.hazmat.primitives.asymmetric.padding
import cryptography.hazmat.primitives.kdf.pbkdf2.PBKDF2HMAC
import cryptography.hazmat.backends.default_backend
import cryptography.fernet.Fernet
import base64

import ..cli_config.get_cli_config


# Error codes for audit trail system (5101-5200)
class AuditErrorCodes
    AUDIT_INIT_FAILED = 5101
    SIGNATURE_FAILED = 5102
    VERIFICATION_FAILED = 5103
    STORAGE_ERROR = 5104
    ENCRYPTION_FAILED = 5105
    TAMPER_DETECTED = 5106
    ARCHIVE_FAILED = 5107
    EXPORT_FAILED = 5108
    RETENTION_POLICY_ERROR = 5109
    AI_TRACKING_ERROR = 5110


class AuditEventType(Enum)
    #     """Audit event types."""
    COMMAND_EXECUTION = "command_execution"
    AI_INTERACTION = "ai_interaction"
    FILE_OPERATION = "file_operation"
    CONFIG_CHANGE = "config_change"
    VALIDATION_RESULT = "validation_result"
    SECURITY_EVENT = "security_event"
    SYSTEM_EVENT = "system_event"
    ERROR_EVENT = "error_event"
    PERFORMANCE_EVENT = "performance_event"


class AuditLevel(Enum)
    #     """Audit levels for severity classification."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class AuditException(Exception)
    #     """Base exception for audit trail errors."""

    #     def __init__(self, message: str, error_code: int):
    self.error_code = error_code
            super().__init__(message)


class CryptographicSigner
    #     """Handles cryptographic signing and verification of audit entries."""

    #     def __init__(self, key_path: Optional[Path] = None):""Initialize the cryptographic signer."""
    self.key_path = key_path or Path('.project/.noodle/keys/audit_key.pem')
    self.key_path.parent.mkdir(parents = True, exist_ok=True)
    self.private_key = None
    self.public_key = None
            self._load_or_generate_keys()

    #     def _load_or_generate_keys(self):
    #         """Load existing keys or generate new ones."""
    #         try:
    #             if self.key_path.exists():
    #                 with open(self.key_path, 'rb') as f:
    self.private_key = serialization.load_pem_private_key(
                            f.read(),
    password = None,
    backend = default_backend()
    #                     )
    self.public_key = self.private_key.public_key()
    #             else:
    #                 # Generate new RSA key pair
    self.private_key = rsa.generate_private_key(
    public_exponent = 65537,
    key_size = 2048,
    backend = default_backend()
    #                 )
    self.public_key = self.private_key.public_key()

    #                 # Save private key
    #                 with open(self.key_path, 'wb') as f:
                        f.write(self.private_key.private_bytes(
    encoding = serialization.Encoding.PEM,
    format = serialization.PrivateFormat.PKCS8,
    encryption_algorithm = serialization.NoEncryption()
    #                     ))
    #         except Exception as e:
                raise AuditException(
                    f"Failed to initialize cryptographic keys: {str(e)}",
    #                 AuditErrorCodes.SIGNATURE_FAILED
    #             )

    #     def sign_entry(self, entry_data: str) -str):
    #         """Sign an audit entry."""
    #         try:
    signature = self.private_key.sign(
                    entry_data.encode('utf-8'),
                    padding.PSS(
    mgf = padding.MGF1(hashes.SHA256()),
    salt_length = padding.PSS.MAX_LENGTH
    #                 ),
                    hashes.SHA256()
    #             )
                return base64.b64encode(signature).decode('utf-8')
    #         except Exception as e:
                raise AuditException(
                    f"Failed to sign audit entry: {str(e)}",
    #                 AuditErrorCodes.SIGNATURE_FAILED
    #             )

    #     def verify_entry(self, entry_data: str, signature: str) -bool):
    #         """Verify an audit entry signature."""
    #         try:
    signature_bytes = base64.b64decode(signature.encode('utf-8'))
                self.public_key.verify(
    #                 signature_bytes,
                    entry_data.encode('utf-8'),
                    padding.PSS(
    mgf = padding.MGF1(hashes.SHA256()),
    salt_length = padding.PSS.MAX_LENGTH
    #                 ),
                    hashes.SHA256()
    #             )
    #             return True
    #         except Exception:
    #             return False

    #     def get_public_key_pem(self) -str):
    #         """Get the public key in PEM format."""
            return self.public_key.public_bytes(
    encoding = serialization.Encoding.PEM,
    format = serialization.PublicFormat.SubjectPublicKeyInfo
            ).decode('utf-8')


class AuditTrail
    #     """Comprehensive audit trail for NoodleCore CLI."""

    #     def __init__(self, audit_dir: Optional[str] = None):""
    #         Initialize the audit trail.

    #         Args:
    #             audit_dir: Directory to store audit files
    #         """
    self.config = get_cli_config()
    self.audit_dir = Path(audit_dir or '.project/.noodle/logs')
    self.audit_dir.mkdir(parents = True, exist_ok=True)

    #         # Initialize cryptographic signer
    self.signer = CryptographicSigner()

    #         # Audit files
    self.audit_file = self.audit_dir / 'audit.log'
    self.signature_file = self.audit_dir / 'audit.signatures'
    self.ai_audit_file = self.audit_dir / 'ai_audit.log'

    #         # In-memory audit entries for recent access
    self.audit_entries: List[Dict[str, Any]] = []
    self.max_memory_entries = 1000

    #         # Retention settings
    self.retention_days = self.config.get_int('NOODLE_AUDIT_RETENTION_DAYS', 90)

    #         # Encryption key for sensitive data
    self.encryption_key = self._get_or_create_encryption_key()

    #         # Initialize audit files
            self._initialize_audit_files()

    #     def _get_or_create_encryption_key(self) -Fernet):
    #         """Get or create encryption key for sensitive audit data."""
    key_file = self.audit_dir / '.audit_key'
    #         try:
    #             if key_file.exists():
    #                 with open(key_file, 'rb') as f:
    key = f.read()
    #             else:
    key = Fernet.generate_key()
    #                 with open(key_file, 'wb') as f:
                        f.write(key)
    #                 # Set restrictive permissions
                    os.chmod(key_file, 0o600)

                return Fernet(key)
    #         except Exception as e:
                raise AuditException(
                    f"Failed to initialize encryption key: {str(e)}",
    #                 AuditErrorCodes.ENCRYPTION_FAILED
    #             )

    #     def _initialize_audit_files(self):
    #         """Initialize audit files with headers."""
    #         try:
    #             # Create main audit file if it doesn't exist
    #             if not self.audit_file.exists():
    #                 with open(self.audit_file, 'w', encoding='utf-8') as f:
                        f.write("# NoodleCore Audit Trail\n")
                        f.write(f"# Started: {datetime.now().isoformat()}\n")
                        f.write(f"# Public Key: {self.signer.get_public_key_pem()}\n\n")

    #             # Create signature file if it doesn't exist
    #             if not self.signature_file.exists():
    #                 with open(self.signature_file, 'w', encoding='utf-8') as f:
                        f.write("# Audit Entry Signatures\n\n")

    #             # Create AI audit file if it doesn't exist
    #             if not self.ai_audit_file.exists():
    #                 with open(self.ai_audit_file, 'w', encoding='utf-8') as f:
                        f.write("# AI Interaction Audit Trail\n")
                        f.write(f"# Started: {datetime.now().isoformat()}\n\n")

    #         except Exception as e:
                raise AuditException(
                    f"Failed to initialize audit files: {str(e)}",
    #                 AuditErrorCodes.STORAGE_ERROR
    #             )

    #     async def log_event(
    #         self,
    #         event_type: Union[AuditEventType, str],
    user: Optional[str] = None,
    request_id: Optional[str] = None,
    component: Optional[str] = None,
    action: Optional[str] = None,
    resource: Optional[str] = None,
    details: Optional[Dict[str, Any]] = None,
    result: Optional[str] = None,
    error: Optional[str] = None,
    level: AuditLevel = AuditLevel.MEDIUM,
    sensitive_data: Optional[Dict[str, Any]] = None
    #     ) -Dict[str, Any]):
    #         """
    #         Log an audit event with cryptographic signature.

    #         Args:
    #             event_type: Type of event
    #             user: User who performed the action
    #             request_id: Request ID for tracking
    #             component: Component that performed the action
    #             action: Action performed
    #             resource: Resource acted upon
    #             details: Additional event details
    #             result: Result of the action
    #             error: Error message if action failed
    #             level: Audit level for severity
    #             sensitive_data: Sensitive data to encrypt

    #         Returns:
    #             Dictionary containing log result
    #         """
    #         try:
    #             # Convert event_type to string if it's an enum
    #             if isinstance(event_type, AuditEventType):
    event_type = event_type.value

    #             # Create audit entry
    audit_entry = {
                    'timestamp': datetime.now().isoformat(),
    #                 'event_type': event_type,
                    'user': user or os.environ.get('USER', 'unknown'),
    #                 'request_id': request_id,
    #                 'component': component,
    #                 'action': action,
    #                 'resource': resource,
    #                 'details': details or {},
    #                 'result': result,
    #                 'error': error,
    #                 'success': error is None,
    #                 'level': level.value,
                    'entry_id': self._generate_entry_id()
    #             }

    #             # Encrypt sensitive data if provided
    #             if sensitive_data:
    encrypted_data = self._encrypt_sensitive_data(sensitive_data)
    audit_entry['encrypted_data'] = encrypted_data

    #             # Create entry data for signing
    entry_data = json.dumps(audit_entry, sort_keys=True, separators=(',', ':'))

    #             # Sign the entry
    signature = self.signer.sign_entry(entry_data)

    #             # Add to in-memory entries
                self.audit_entries.append(audit_entry)
    #             if len(self.audit_entries) self.max_memory_entries):
                    self.audit_entries.pop(0)

    #             # Save to files
                await self._save_audit_entry(audit_entry, signature)

    #             # Special handling for AI events
    #             if event_type == AuditEventType.AI_INTERACTION.value:
                    await self._save_ai_audit_entry(audit_entry, signature)

    #             return {
    #                 'success': True,
    #                 'message': "Audit event logged successfully",
    #                 'entry_id': audit_entry['entry_id'],
    #                 'timestamp': audit_entry['timestamp']
    #             }

    #         except Exception as e:
                raise AuditException(
                    f"Failed to log audit event: {str(e)}",
    #                 AuditErrorCodes.STORAGE_ERROR
    #             )

    #     async def log_ai_interaction(
    #         self,
    #         request_id: str,
    #         model: str,
    #         prompt: str,
    #         response: str,
    #         tokens_used: int,
    #         latency: float,
    user: Optional[str] = None,
    component: str = 'ai_adapter',
    success: bool = True,
    error: Optional[str] = None
    #     ) -Dict[str, Any]):
    #         """
    #         Log AI interaction with detailed tracking.

    #         Args:
    #             request_id: Request ID for tracking
    #             model: AI model used
    #             prompt: Prompt sent to AI
    #             response: Response from AI
    #             tokens_used: Number of tokens used
    #             latency: Response latency in seconds
    #             user: User who made the request
    #             component: Component handling the interaction
    #             success: Whether the interaction was successful
    #             error: Error message if failed

    #         Returns:
    #             Dictionary containing log result
    #         """
    #         try:
    details = {
    #                 'model': model,
                    'prompt_length': len(prompt),
                    'response_length': len(response),
    #                 'tokens_used': tokens_used,
    #                 'latency_seconds': latency,
                    'cost_estimate': self._estimate_cost(model, tokens_used)
    #             }

    #             # Store full prompt and response as encrypted sensitive data
    sensitive_data = {
    #                 'full_prompt': prompt,
    #                 'full_response': response
    #             }

                return await self.log_event(
    event_type = AuditEventType.AI_INTERACTION,
    user = user,
    request_id = request_id,
    component = component,
    action = 'ai_request',
    resource = model,
    details = details,
    #                 result='success' if success else 'failed',
    error = error,
    #                 level=AuditLevel.MEDIUM if success else AuditLevel.HIGH,
    sensitive_data = sensitive_data
    #             )

    #         except Exception as e:
                raise AuditException(
                    f"Failed to log AI interaction: {str(e)}",
    #                 AuditErrorCodes.AI_TRACKING_ERROR
    #             )

    #     async def log_file_operation(
    #         self,
    #         operation: str,
    #         file_path: str,
    user: Optional[str] = None,
    request_id: Optional[str] = None,
    component: str = 'sandbox',
    details: Optional[Dict[str, Any]] = None,
    success: bool = True,
    error: Optional[str] = None
    #     ) -Dict[str, Any]):
    #         """
    #         Log file operation in sandbox.

    #         Args:
                operation: Type of operation (create, modify, delete, move)
    #             file_path: Path to the file
    #             user: User performing the operation
    #             request_id: Request ID for tracking
    #             component: Component performing the operation
    #             details: Additional details
    #             success: Whether operation was successful
    #             error: Error message if failed

    #         Returns:
    #             Dictionary containing log result
    #         """
    #         try:
    file_details = {}
    #             if details:
                    file_details.update(details)

    #             # Add file metadata if file exists
    #             if operation in ['modify', 'read'] and success:
    #                 try:
    file_stat = Path(file_path).stat()
                        file_details.update({
    #                         'file_size': file_stat.st_size,
                            'file_modified': datetime.fromtimestamp(file_stat.st_mtime).isoformat(),
                            'file_permissions': oct(file_stat.st_mode)[-3:]
    #                     })
    #                 except:
    #                     pass

                return await self.log_event(
    event_type = AuditEventType.FILE_OPERATION,
    user = user,
    request_id = request_id,
    component = component,
    action = operation,
    resource = file_path,
    details = file_details,
    #                 result='success' if success else 'failed',
    error = error,
    #                 level=AuditLevel.LOW if operation == 'read' else AuditLevel.MEDIUM
    #             )

    #         except Exception as e:
                raise AuditException(
                    f"Failed to log file operation: {str(e)}",
    #                 AuditErrorCodes.STORAGE_ERROR
    #             )

    #     async def log_config_change(
    #         self,
    #         config_key: str,
    #         old_value: Any,
    #         new_value: Any,
    user: Optional[str] = None,
    request_id: Optional[str] = None,
    component: str = 'config_manager',
    reason: Optional[str] = None
    #     ) -Dict[str, Any]):
    #         """
    #         Log configuration changes.

    #         Args:
    #             config_key: Configuration key that changed
    #             old_value: Previous value
    #             new_value: New value
    #             user: User making the change
    #             request_id: Request ID for tracking
    #             component: Component making the change
    #             reason: Reason for the change

    #         Returns:
    #             Dictionary containing log result
    #         """
    #         try:
    details = {
    #                 'config_key': config_key,
                    'old_value': str(old_value),
                    'new_value': str(new_value),
    #                 'reason': reason or 'unspecified'
    #             }

    #             # Mark as sensitive if key contains sensitive patterns
    sensitive_patterns = ['password', 'key', 'token', 'secret', 'credential']
    #             is_sensitive = any(pattern in config_key.lower() for pattern in sensitive_patterns)

    sensitive_data = None
    #             if is_sensitive:
    sensitive_data = {
    #                     'old_value': old_value,
    #                     'new_value': new_value
    #                 }
    #                 # Remove actual values from details
    details['old_value'] = '[REDACTED]'
    details['new_value'] = '[REDACTED]'

                return await self.log_event(
    event_type = AuditEventType.CONFIG_CHANGE,
    user = user,
    request_id = request_id,
    component = component,
    action = 'config_update',
    resource = config_key,
    details = details,
    result = 'success',
    #                 level=AuditLevel.HIGH if is_sensitive else AuditLevel.MEDIUM,
    sensitive_data = sensitive_data
    #             )

    #         except Exception as e:
                raise AuditException(
                    f"Failed to log config change: {str(e)}",
    #                 AuditErrorCodes.STORAGE_ERROR
    #             )

    #     async def _save_audit_entry(self, audit_entry: Dict[str, Any], signature: str) -None):
    #         """Save audit entry and signature to files."""
    #         try:
    #             # Save to main audit file
    #             with open(self.audit_file, 'a', encoding='utf-8') as f:
    f.write(json.dumps(audit_entry, default = str) + '\n')

    #             # Save signature
    signature_entry = {
    #                 'entry_id': audit_entry['entry_id'],
    #                 'timestamp': audit_entry['timestamp'],
    #                 'signature': signature
    #             }
    #             with open(self.signature_file, 'a', encoding='utf-8') as f:
                    f.write(json.dumps(signature_entry) + '\n')

    #         except IOError as e:
                raise AuditException(
                    f"Failed to save audit entry: {str(e)}",
    #                 AuditErrorCodes.STORAGE_ERROR
    #             )

    #     async def _save_ai_audit_entry(self, audit_entry: Dict[str, Any], signature: str) -None):
    #         """Save AI-specific audit entry."""
    #         try:
    ai_entry = {
    #                 **audit_entry,
    #                 'signature': signature
    #             }
    #             with open(self.ai_audit_file, 'a', encoding='utf-8') as f:
    f.write(json.dumps(ai_entry, default = str) + '\n')
    #         except IOError as e:
                raise AuditException(
                    f"Failed to save AI audit entry: {str(e)}",
    #                 AuditErrorCodes.STORAGE_ERROR
    #             )

    #     def _generate_entry_id(self) -str):
    #         """Generate unique entry ID."""
            return f"{int(time.time() * 1000)}-{os.getpid()}-{len(self.audit_entries)}"

    #     def _encrypt_sensitive_data(self, data: Dict[str, Any]) -str):
    #         """Encrypt sensitive data."""
    #         try:
    json_data = json.dumps(data, default=str)
    encrypted = self.encryption_key.encrypt(json_data.encode())
                return base64.b64encode(encrypted).decode('utf-8')
    #         except Exception as e:
                raise AuditException(
                    f"Failed to encrypt sensitive data: {str(e)}",
    #                 AuditErrorCodes.ENCRYPTION_FAILED
    #             )

    #     def _decrypt_sensitive_data(self, encrypted_data: str) -Dict[str, Any]):
    #         """Decrypt sensitive data."""
    #         try:
    encrypted_bytes = base64.b64decode(encrypted_data.encode())
    decrypted = self.encryption_key.decrypt(encrypted_bytes)
                return json.loads(decrypted.decode())
    #         except Exception as e:
                raise AuditException(
                    f"Failed to decrypt sensitive data: {str(e)}",
    #                 AuditErrorCodes.ENCRYPTION_FAILED
    #             )

    #     def _estimate_cost(self, model: str, tokens: int) -float):
    #         """Estimate cost for AI interaction."""
            # Rough cost estimates (per 1000 tokens)
    cost_per_1k = {
    #             'gpt-4': 0.03,
    #             'gpt-3.5-turbo': 0.002,
    #             'claude-3': 0.015,
    #             'glm-4': 0.01,
    #             'default': 0.01
    #         }

    cost = cost_per_1k.get(model.lower(), cost_per_1k['default'])
            return (tokens / 1000) * cost

    #     async def verify_audit_integrity(self) -Dict[str, Any]):
    #         """
    #         Verify the integrity of audit entries.

    #         Returns:
    #             Dictionary containing verification results
    #         """
    #         try:
    #             # Read audit entries and signatures
    audit_entries = []
    signatures = {}

    #             # Read audit file
    #             if self.audit_file.exists():
    #                 with open(self.audit_file, 'r', encoding='utf-8') as f:
    #                     for line in f:
    line = line.strip()
    #                         if line and not line.startswith('#'):
    #                             try:
    entry = json.loads(line)
                                    audit_entries.append(entry)
    #                             except:
    #                                 continue

    #             # Read signature file
    #             if self.signature_file.exists():
    #                 with open(self.signature_file, 'r', encoding='utf-8') as f:
    #                     for line in f:
    line = line.strip()
    #                         if line and not line.startswith('#'):
    #                             try:
    sig_entry = json.loads(line)
    signatures[sig_entry['entry_id']] = sig_entry['signature']
    #                             except:
    #                                 continue

    #             # Verify entries
    verified_count = 0
    failed_count = 0
    missing_signatures = 0

    #             for entry in audit_entries:
    entry_id = entry.get('entry_id')
    #                 if entry_id in signatures:
    entry_data = json.dumps(entry, sort_keys=True, separators=(',', ':'))
    #                     if self.signer.verify_entry(entry_data, signatures[entry_id]):
    verified_count + = 1
    #                     else:
    failed_count + = 1
    #                 else:
    missing_signatures + = 1

    total_entries = len(audit_entries)
    #             integrity_score = (verified_count / total_entries) if total_entries 0 else 0

    #             return {
    #                 'success'): True,
    #                 'total_entries': total_entries,
    #                 'verified_entries': verified_count,
    #                 'failed_entries': failed_count,
    #                 'missing_signatures': missing_signatures,
    #                 'integrity_score': integrity_score,
    #                 'tamper_detected': failed_count 0,
                    'verification_time'): datetime.now().isoformat()
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': str(e),
    #                 'error_code': AuditErrorCodes.VERIFICATION_FAILED
    #             }

    #     async def get_audit_events(
    #         self,
    event_type: Optional[str] = None,
    user: Optional[str] = None,
    since: Optional[str] = None,
    until: Optional[str] = None,
    request_id: Optional[str] = None,
    component: Optional[str] = None,
    action: Optional[str] = None,
    resource: Optional[str] = None,
    level: Optional[AuditLevel] = None,
    limit: int = 100,
    include_sensitive: bool = False
    #     ) -Dict[str, Any]):
    #         """
    #         Get audit events with filtering.

    #         Args:
    #             event_type: Filter by event type
    #             user: Filter by user
                since: Filter by timestamp (ISO format)
                until: Filter by timestamp (ISO format)
    #             request_id: Filter by request ID
    #             component: Filter by component
    #             action: Filter by action
    #             resource: Filter by resource
    #             level: Filter by audit level
    #             limit: Maximum number of events
    #             include_sensitive: Include decrypted sensitive data

    #         Returns:
    #             Dictionary containing filtered audit events
    #         """
    #         try:
    #             # Start with in-memory entries (recent)
    events = self.audit_entries.copy()

    #             # Read from file if we need more events
    #             if len(events) < limit and self.audit_file.exists():
    #                 with open(self.audit_file, 'r', encoding='utf-8') as f:
    #                     for line in f:
    line = line.strip()
    #                         if line and not line.startswith('#'):
    #                             try:
    entry = json.loads(line)
    #                                 if entry not in events:  # Avoid duplicates
                                        events.append(entry)
    #                             except:
    #                                 continue

    #             # Apply filters
    filtered_events = []
    #             for event in events:
    #                 if event_type and event.get('event_type') != event_type:
    #                     continue
    #                 if user and event.get('user') != user:
    #                     continue
    #                 if request_id and event.get('request_id') != request_id:
    #                     continue
    #                 if component and event.get('component') != component:
    #                     continue
    #                 if action and event.get('action') != action:
    #                     continue
    #                 if resource and event.get('resource') != resource:
    #                     continue
    #                 if level and event.get('level') != level.value:
    #                     continue

    #                 # Date filtering
    event_time = datetime.fromisoformat(event.get('timestamp', ''))
    #                 if since:
    since_time = datetime.fromisoformat(since)
    #                     if event_time < since_time:
    #                         continue
    #                 if until:
    until_time = datetime.fromisoformat(until)
    #                     if event_time until_time):
    #                         continue

    #                 # Decrypt sensitive data if requested
    #                 if include_sensitive and 'encrypted_data' in event:
    #                     try:
    sensitive_data = self._decrypt_sensitive_data(event['encrypted_data'])
    event['sensitive_data'] = sensitive_data
    #                     except:
    #                         pass  # Keep encrypted if decryption fails

                    filtered_events.append(event)

                # Sort by timestamp (newest first) and apply limit
    filtered_events.sort(key = lambda x: x.get('timestamp', ''), reverse=True)
    filtered_events = filtered_events[:limit]

    #             return {
    #                 'success': True,
    #                 'events': filtered_events,
                    'count': len(filtered_events),
    #                 'filters': {
    #                     'event_type': event_type,
    #                     'user': user,
    #                     'since': since,
    #                     'until': until,
    #                     'request_id': request_id,
    #                     'component': component,
    #                     'action': action,
    #                     'resource': resource,
    #                     'level': level.value if level else None,
    #                     'limit': limit
    #                 }
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': str(e),
    #                 'error_code': AuditErrorCodes.STORAGE_ERROR
    #             }

    #     async def export_audit_events(
    #         self,
    #         file_path: str,
    format_type: str = 'json',
    filters: Optional[Dict[str, Any]] = None,
    include_signatures: bool = False
    #     ) -Dict[str, Any]):
    #         """
    #         Export audit events to a file.

    #         Args:
    #             file_path: Path to export file
                format_type: Export format ('json', 'csv')
    #             filters: Filters to apply
    #             include_signatures: Include signature verification

    #         Returns:
    #             Dictionary containing export result
    #         """
    #         try:
    #             # Get events with filters
    filter_params = filters or {}
    events_result = await self.get_audit_events( * *filter_params, limit=10000)

    #             if not events_result['success']:
    #                 return events_result

    events = events_result['events']

    #             # Add signature verification if requested
    #             if include_signatures:
    integrity_result = await self.verify_audit_integrity()
    events_result['integrity_check'] = integrity_result

    #             # Export based on format
    #             if format_type == 'json':
    export_data = {
    #                     'export_info': {
                            'timestamp': datetime.now().isoformat(),
                            'total_events': len(events),
    #                         'filters': filter_params,
                            'integrity_check': events_result.get('integrity_check')
    #                     },
    #                     'events': events
    #                 }

    #                 with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(export_data, f, indent = 2, default=str)

    #             elif format_type == 'csv':
    #                 import csv

    #                 # Flatten events for CSV
    #                 if events:
    fieldnames = ['timestamp', 'event_type', 'user', 'request_id',
    #                                 'component', 'action', 'resource', 'result', 'level']

    #                     with open(file_path, 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
                            writer.writeheader()

    #                         for event in events:
    #                             row = {field: event.get(field, '') for field in fieldnames}
                                writer.writerow(row)
    #             else:
    #                 return {
    #                     'success': False,
    #                     'error': f"Unsupported format: {format_type}",
    #                     'error_code': AuditErrorCodes.EXPORT_FAILED
    #                 }

    #             return {
    #                 'success': True,
    #                 'message': f"Audit events exported to {file_path}",
    #                 'format': format_type,
                    'count': len(events),
    #                 'file_path': file_path
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': f"Error exporting audit events: {str(e)}",
    #                 'error_code': AuditErrorCodes.EXPORT_FAILED
    #             }

    #     async def apply_retention_policy(self) -Dict[str, Any]):
    #         """
    #         Apply retention policy to old audit entries.

    #         Returns:
    #             Dictionary containing retention results
    #         """
    #         try:
    cutoff_date = datetime.now() - timedelta(days=self.retention_days)
    archived_count = 0
    deleted_count = 0

    #             # Archive old entries
    archive_dir = self.audit_dir / 'archive'
    archive_dir.mkdir(exist_ok = True)

    archive_file = archive_dir / f'audit_{cutoff_date.strftime("%Y%m")}.log'

    #             if self.audit_file.exists():
    current_events = []
    archived_events = []

    #                 with open(self.audit_file, 'r', encoding='utf-8') as f:
    #                     for line in f:
    line = line.strip()
    #                         if line and not line.startswith('#'):
    #                             try:
    event = json.loads(line)
    event_time = datetime.fromisoformat(event.get('timestamp', ''))

    #                                 if event_time < cutoff_date:
                                        archived_events.append(line)
    archived_count + = 1
    #                                 else:
                                        current_events.append(line)
    #                             except:
                                    current_events.append(line)  # Keep malformed lines

    #                 # Write current events back
    #                 with open(self.audit_file, 'w', encoding='utf-8') as f:
                        f.write("# NoodleCore Audit Trail\n")
                        f.write(f"# Archived entries older than {cutoff_date.isoformat()}\n")
                        f.write(f"# Public Key: {self.signer.get_public_key_pem()}\n\n")
    #                     for event in current_events:
                            f.write(event + '\n')

    #                 # Archive old events
    #                 if archived_events:
    #                     with open(archive_file, 'a', encoding='utf-8') as f:
    #                         for event in archived_events:
                                f.write(event + '\n')

    #             # Clean up memory entries
    self.audit_entries = [
    #                 entry for entry in self.audit_entries
    #                 if datetime.fromisoformat(entry.get('timestamp', '')) >= cutoff_date
    #             ]

    #             return {
    #                 'success': True,
    #                 'message': f"Retention policy applied",
    #                 'archived_count': archived_count,
    #                 'deleted_count': deleted_count,
                    'cutoff_date': cutoff_date.isoformat(),
    #                 'retention_days': self.retention_days
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': f"Error applying retention policy: {str(e)}",
    #                 'error_code': AuditErrorCodes.RETENTION_POLICY_ERROR
    #             }

    #     async def get_audit_statistics(self) -Dict[str, Any]):
    #         """
    #         Get comprehensive audit statistics.

    #         Returns:
    #             Dictionary containing audit statistics
    #         """
    #         try:
    #             # Get all events for statistics
    events_result = await self.get_audit_events(limit=10000)

    #             if not events_result['success']:
    #                 return events_result

    events = events_result['events']

    #             # Calculate statistics
    total_events = len(events)

    #             # Events by type
    events_by_type = {}
    #             for event in events:
    event_type = event.get('event_type', 'unknown')
    events_by_type[event_type] = events_by_type.get(event_type + 0, 1)

    #             # Events by component
    events_by_component = {}
    #             for event in events:
    component = event.get('component', 'unknown')
    events_by_component[component] = events_by_component.get(component + 0, 1)

    #             # Events by user
    events_by_user = {}
    #             for event in events:
    user = event.get('user', 'unknown')
    events_by_user[user] = events_by_user.get(user + 0, 1)

    #             # Events by level
    events_by_level = {}
    #             for event in events:
    level = event.get('level', 'unknown')
    events_by_level[level] = events_by_level.get(level + 0, 1)

    #             # Success rate
    #             successful_events = sum(1 for event in events if event.get('success', False))
    #             success_rate = successful_events / total_events if total_events 0 else 0

    #             # AI interaction stats
    #             ai_events = [e for e in events if e.get('event_type') == 'ai_interaction']
    ai_stats = {}
    #             if ai_events):
    #                 total_tokens = sum(e.get('details', {}).get('tokens_used', 0) for e in ai_events)
    #                 avg_latency = sum(e.get('details', {}).get('latency_seconds', 0) for e in ai_events) / len(ai_events)
    #                 total_cost = sum(e.get('details', {}).get('cost_estimate', 0) for e in ai_events)

    ai_stats = {
                        'total_interactions': len(ai_events),
    #                     'total_tokens': total_tokens,
    #                     'average_latency': avg_latency,
    #                     'total_cost_estimate': total_cost
    #                 }

    #             # Date range
    #             if events:
    #                 timestamps = [datetime.fromisoformat(e.get('timestamp', '')) for e in events]
    date_range = {
                        'start': min(timestamps).isoformat(),
                        'end': max(timestamps).isoformat()
    #                 }
    #             else:
    date_range = {'start': None, 'end': None}

    #             return {
    #                 'success': True,
    #                 'total_events': total_events,
    #                 'events_by_type': events_by_type,
    #                 'events_by_component': events_by_component,
    #                 'events_by_user': events_by_user,
    #                 'events_by_level': events_by_level,
    #                 'success_rate': success_rate,
    #                 'ai_statistics': ai_stats,
    #                 'date_range': date_range,
    #                 'retention_days': self.retention_days,
                    'memory_entries': len(self.audit_entries)
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': str(e),
    #                 'error_code': AuditErrorCodes.STORAGE_ERROR
    #             }