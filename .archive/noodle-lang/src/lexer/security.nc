# Converted from Python to NoodleCore
# Original file: src

# """
# Database Security Manager
# -------------------------
# Implements security features for database operations including authentication,
# authorization, encryption, and audit logging.
# """

import base64
import hashlib
import json
import logging
import os
import threading
import time
from dataclasses import dataclass
import datetime.datetime
import enum.Enum
import pathlib.Path
import typing.Any

import cryptography.fernet.Fernet
import cryptography.hazmat.primitives.hashes
import cryptography.hazmat.primitives.kdf.pbkdf2.PBKDF2HMAC

import ..backends.base.DatabaseBackend
import ...error.DatabaseError


class AuthenticationMethod(Enum)
    #     """Authentication methods supported."""

    PASSWORD = "password"
    TOKEN = "token"
    CERTIFICATE = "certificate"


dataclass
class User
    #     """Database user representation."""

    #     username: str
    #     password_hash: str  # Hashed password
    role: str = "user"
    permissions: Dict[str, List[str]] = field(
    default_factory = dict
    #     )  # Resource -operations
    last_login): Optional[datetime] = None
    failed_attempts: int = 0
    account_locked: bool = False
    created_at: datetime = field(default_factory=datetime.now)


class AuditLogEntry
    #     """Entry for audit logging."""

    #     def __init__(
    #         self,
    #         user: str,
    #         operation: str,
    #         resource: str,
    #         success: bool,
    #         timestamp: datetime,
    details: Dict[str, Any] = None,
    #     ):
    self.user = user
    self.operation = operation
    self.resource = resource
    self.success = success
    self.timestamp = timestamp
    self.details = details or {}


class DatabaseSecurityManager
    #     """Manages database security aspects including authentication, authorization, and auditing."""

    #     def __init__(
    #         self,
    users_file: str = "database_users.json",
    encryption_key_file: str = "security.key",
    audit_log_file: str = "audit.log",
    #     ):""Initialize the database security manager.

    #         Args:
    #             users_file: File to store user data
    #             encryption_key_file: File to store encryption keys
    #             audit_log_file: File for audit logging
    #         """
    self.users_file = Path(users_file)
    self.encryption_key_file = Path(encryption_key_file)
    self.audit_log_file = Path(audit_log_file)

    #         # Load or create encryption keys
    self.encryption_keys = self._load_or_generate_keys()

    #         # Load or initialize users
    self.users = self._load_users()

    #         # Audit log
    self.audit_log = []
    self.audit_lock = threading.RLock()

    #         # Authenticator and authorizer
    self.authenticator = self._create_authenticator()
    self.authorizer = self._create_authorizer()

    #         # Cache for authentication decisions
    self.auth_cache = {}
    self.auth_cache_lock = threading.RLock()

    self.logger = logging.getLogger(__name__)

    #     def _load_or_generate_keys(self) -Dict[str, str]):
    #         """Load encryption keys or generate new ones."""
    #         if self.encryption_key_file.exists():
    #             with open(self.encryption_key_file, "rb") as f:
    key_data = json.load(f)
    #                 return key_data
    #         else:
    #             # Generate new key
    salt = os.urandom(16)
    kdf = PBKDF2HMAC(
    algorithm = hashes.SHA256(),
    length = 32,
    salt = salt,
    iterations = 100000,
    #             )
    key = base64.urlsafe_b64encode(kdf.derive(b"master_password"))
    fernet_key = Fernet(key)

    keys = {
                    "fernet_key": key.decode("utf-8"),
                    "salt": base64.b64encode(salt).decode("utf-8"),
    #             }

    #             # Save keys
    #             with open(self.encryption_key_file, "w") as f:
                    json.dump(keys, f)

    #             return keys

    #     def _load_users(self) -Dict[str, User]):
    #         """Load users from file or create default admin."""
    #         if self.users_file.exists():
    #             with open(self.users_file, "r") as f:
    users_data = json.load(f)
    users = {}
    #                 for user_data in users_data:
    user = User( * *user_data)
    users[user.username] = user
    #                 return users
    #         else:
    #             # Create default admin user
    password = hashlib.pbkdf2_hmac("sha256", b"admin", b"salt", 100000).hex()
    default_user = User(
    username = "admin",
    password_hash = password,
    role = "admin",
    permissions = {
    #                     "*": ["SELECT", "INSERT", "UPDATE", "DELETE", "CREATE", "DROP"]
    #                 },
    #             )
    users = {"admin": default_user}

    #             # Save users
                self._save_users(users)
    #             return users

    #     def _save_users(self, users: Dict[str, User]):
    #         """Save users to file."""
    users_data = []
    #         for user in users.values():
    user_data = {
    #                 "username": user.username,
    #                 "password_hash": user.password_hash,
    #                 "role": user.role,
    #                 "permissions": user.permissions,
    #                 "last_login": user.last_login.isoformat() if user.last_login else None,
    #                 "failed_attempts": user.failed_attempts,
    #                 "account_locked": user.account_locked,
                    "created_at": user.created_at.isoformat(),
    #             }
                users_data.append(user_data)

    #         with open(self.users_file, "w") as f:
                json.dump(users_data, f)

    #     def _create_authenticator(self):
    #         """Create authentication handler."""
    #         return self  # Self-contained for now

    #     def _create_authorizer(self):
    #         """Create authorization handler."""
    #         return self  # Self-contained for now

    #     def authenticate_user(
    self, username: str, password: str, backend: str = None
    #     ) -bool):
    #         """Authenticate user for database access.

    #         Args:
    #             username: Username to authenticate
    #             password: Password to verify
    #             backend: Specific backend (for backend-specific auth)

    #         Returns:
    #             True if authentication successful, False otherwise
    #         """
    #         with self.auth_cache_lock:
    cache_key = f"{username}_{backend or 'default'}"
    #             if cache_key in self.auth_cache:
    cached = self.auth_cache[cache_key]
    #                 if time.time() - cached["timestamp"] < 300:  # 5 minute cache
    #                     return cached["success"]

    #         if username not in self.users:
                self._log_audit(
    #                 username, "AUTHENTICATE", "USER", False, {"reason": "user_not_found"}
    #             )
    #             return False

    user = self.users[username]
    #         if user.account_locked:
                self._log_audit(
    #                 username, "AUTHENTICATE", "USER", False, {"reason": "account_locked"}
    #             )
    #             return False

    #         # Verify password
    password_hash = hashlib.pbkdf2_hmac(
                "sha256", password.encode(), b"salt", 100000
            ).hex()
    success = password_hash == user.password_hash

    #         if success:
    user.last_login = datetime.now()
    user.failed_attempts = 0
    #         else:
    user.failed_attempts + = 1
    #             if user.failed_attempts >= 5:
    user.account_locked = True

            self._save_users(self.users)

    #         # Cache result
    #         with self.auth_cache_lock:
    self.auth_cache[cache_key] = {"success": success, "timestamp": time.time()}

            self._log_audit(username, "AUTHENTICATE", "USER", success, {"backend": backend})
    #         return success

    #     def authorize_operation(self, user: str, operation: str, resource: str) -bool):
    #         """Authorize user operation on resource.

    #         Args:
    #             user: Username
                operation: Operation to authorize (SELECT, INSERT, etc.)
                resource: Resource to access (table name, '*', etc.)

    #         Returns:
    #             True if operation is authorized, False otherwise
    #         """
    #         if user not in self.users:
    #             return False

    user = self.users[user]

    #         # Check if user has wildcard permissions
    #         if "*" in user.permissions and operation in user.permissions["*"]:
    #             return True

    #         # Check role-based permissions
    #         if user.role == "admin":
    #             return True

    #         # Check specific resource permissions
    #         if resource in user.permissions and operation in user.permissions[resource]:
    #             return True

    #         # Deny by default
    #         return False

    #     def encrypt_connection(self, connection: DatabaseBackend) -bool):
    #         """Enable encryption for database connection.

    #         Args:
    #             connection: Database connection object

    #         Returns:
    #             True if encryption enabled, False otherwise
    #         """
    #         try:
    #             # This would be backend-specific, for now return True if SSL is configured
    #             if hasattr(connection, "_pool") and hasattr(
    #                 connection._pool, "_ssl_context"
    #             ):
    #                 return True
    #             return False
    #         except Exception as e:
                self.logger.error(f"Failed to encrypt connection: {e}")
    #             return False

    #     def encrypt_data(self, data: Any) -bytes):
    #         """Encrypt sensitive data before storage.

    #         Args:
    #             data: Data to encrypt

    #         Returns:
    #             Encrypted data as bytes
    #         """
    #         try:
    fernet_key = self.encryption_keys["fernet_key"].encode("utf-8")
    fernet = Fernet(fernet_key)
    data_str = json.dumps(data)
    encrypted = fernet.encrypt(data_str.encode())
    #             return encrypted
    #         except Exception as e:
                raise SecurityError(f"Failed to encrypt data: {e}")

    #     def decrypt_data(self, encrypted_data: bytes) -Any):
    #         """Decrypt data retrieved from storage.

    #         Args:
    #             encrypted_data: Encrypted data bytes

    #         Returns:
    #             Original data
    #         """
    #         try:
    fernet_key = self.encryption_keys["fernet_key"].encode("utf-")
    fernet = Fernet(fernet_key)
    decrypted = fernet.decrypt(encrypted_data)
                return json.loads(decrypted.decode())
    #         except Exception as e:
                raise SecurityError(f"Failed to decrypt data: {e}")

    #     def audit_operation(
    #         self,
    #         user: str,
    #         operation: str,
    #         resource: str,
    #         success: bool,
    details: Dict[str, Any] = None,
    #     ):
    #         """Log operation for audit purposes.

    #         Args:
    #             user: Username performing operation
    #             operation: Operation performed
    #             resource: Resource affected
    #             success: Whether operation was successful
    #             details: Additional details about operation
    #         """
    #         with self.audit_lock:
    entry = AuditLogEntry(
    user = user,
    operation = operation,
    resource = resource,
    success = success,
    timestamp = datetime.now(),
    details = details or {},
    #             )
                self.audit_log.append(entry)

    #             # Save to file
                self._save_audit_log()

    #     def _save_audit_log(self):
    #         """Save audit log to file."""
    #         try:
    log_data = []
    #             for entry in self.audit_log:
    log_entry = {
    #                     "user": entry.user,
    #                     "operation": entry.operation,
    #                     "resource": entry.resource,
    #                     "success": entry.success,
                        "timestamp": entry.timestamp.isoformat(),
    #                     "details": entry.details,
    #                 }
                    log_data.append(log_entry)

    #             with open(self.audit_log_file, "w") as f:
    json.dump(log_data, f, indent = 2)
    #         except Exception as e:
                self.logger.error(f"Failed to save audit log: {e}")

    #     def get_audit_log(
    self, since: Optional[datetime] = None, limit: int = 1000
    #     ) -List[AuditLogEntry]):
    #         """Get audit log entries.

    #         Args:
    #             since: Only return entries since this time
    #             limit: Maximum number of entries to return

    #         Returns:
    #             List of audit log entries
    #         """
    #         with self.audit_lock:
    filtered_log = []
    #             for entry in self.audit_log:
    #                 if since and entry.timestamp < since:
    #                     continue
                    filtered_log.append(entry)
    #                 if len(filtered_log) >= limit:
    #                     break
    #             return filtered_log

    #     def clear_audit_log(self):
    #         """Clear the audit log."""
    #         with self.audit_lock:
                self.audit_log.clear()
                self._save_audit_log()

    #     def _log_audit(
    #         self,
    #         user: str,
    #         operation: str,
    #         resource: str,
    #         success: bool,
    details: Dict[str, Any] = None,
    #     ):
    #         """Internal method to log audit events."""
            self.audit_operation(user, operation, resource, success, details)
