# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Secure Storage Module

# This module implements encrypted storage for sensitive configuration data with AES-256 encryption,
# HSM support, key rotation, and comprehensive security features.
# """

import os
import json
import logging
import asyncio
import hashlib
import secrets
import typing.Dict,
import pathlib.Path
import dataclasses.dataclass,
import datetime.datetime,
import enum.Enum
import cryptography.fernet.Fernet
import cryptography.hazmat.primitives.hashes,
import cryptography.hazmat.primitives.kdf.pbkdf2.PBKDF2HMAC
import cryptography.hazmat.primitives.ciphers.Cipher,
import cryptography.hazmat.backends.default_backend
import base64
import struct


class EncryptionAlgorithm(Enum)
    #     """Supported encryption algorithms."""
    AES_256_GCM = "aes-256-gcm"
    AES_256_CBC = "aes-256-cbc"
    FERNET = "fernet"


class KeySourceType(Enum)
    #     """Key source types."""
    PASSWORD = "password"
    ENVIRONMENT = "environment"
    HSM = "hsm"
    FILE = "file"
    GENERATED = "generated"


# @dataclass
class EncryptionKey
    #     """Encryption key metadata."""
    #     key_id: str
    #     algorithm: EncryptionAlgorithm
    #     source_type: KeySourceType
    #     created_at: datetime
    expires_at: Optional[datetime] = None
    last_rotated: Optional[datetime] = None
    rotation_interval_days: int = 90
    is_active: bool = True
    metadata: Dict[str, Any] = field(default_factory=dict)


# @dataclass
class SecureEntry
    #     """Secure storage entry."""
    #     entry_id: str
    #     key_id: str
    #     encrypted_data: bytes
    iv: Optional[bytes] = None
    tag: Optional[bytes] = None
    checksum: str = ""
    created_at: datetime = field(default_factory=datetime.now)
    updated_at: datetime = field(default_factory=datetime.now)
    access_count: int = 0
    last_accessed: Optional[datetime] = None
    metadata: Dict[str, Any] = field(default_factory=dict)


class SecureStorageError(Exception)
    #     """Secure storage error with 4-digit error code."""

    #     def __init__(self, message: str, error_code: int = 4501):
    self.error_code = error_code
            super().__init__(message)


class SecureStorage
    #     """Enhanced secure storage for sensitive configuration data."""

    DEFAULT_ALGORITHM = EncryptionAlgorithm.AES_256_GCM
    DEFAULT_KEY_SIZE = 32  # 256 bits
    #     DEFAULT_IV_SIZE = 12   # 96 bits for GCM
    #     DEFAULT_TAG_SIZE = 16  # 128 bits for GCM
    DEFAULT_SALT_SIZE = 32
    DEFAULT_ITERATIONS = 100000

    #     def __init__(self, storage_dir: Optional[str] = None, master_password: Optional[str] = None,
    hsm_enabled: bool = False, auto_rotate: bool = True):
    #         """
    #         Initialize the secure storage.

    #         Args:
    #             storage_dir: Directory for secure storage files
    #             master_password: Master password for encryption
    #             hsm_enabled: Enable HSM support if available
    #             auto_rotate: Enable automatic key rotation
    #         """
    self.name = "SecureStorage"
    self.logger = logging.getLogger(__name__)
    self.storage_dir = Path(storage_dir or "~/.noodle/secure").expanduser()
    self.storage_dir.mkdir(parents = True, exist_ok=True)

    #         # Security settings
    self.hsm_enabled = hsm_enabled
    self.auto_rotate = auto_rotate

    #         # Storage files
    self.keys_file = self.storage_dir / "keys.json"
    self.entries_file = self.storage_dir / "entries.enc"
    self.audit_file = self.storage_dir / "audit.log"
    self.key_rotation_file = self.storage_dir / "key_rotation.json"

    #         # In-memory storage
    self._keys: Dict[str, EncryptionKey] = {}
    self._entries: Dict[str, SecureEntry] = {}
    self._master_key: Optional[bytes] = None

    #         # Initialize HSM if available
    self._hsm = None
    #         if hsm_enabled:
                self._initialize_hsm()

    #         # Initialize storage
            self._initialize_storage(master_password)

    #         # Check for key rotation
    #         if auto_rotate:
                asyncio.create_task(self._check_key_rotation())

    #     def _initialize_hsm(self):
    #         """Initialize Hardware Security Module if available."""
    #         try:
    #             # Try to import and initialize HSM
    #             # This is a placeholder for actual HSM implementation
    #             # In a real implementation, this would interface with TPM, HSM, etc.
                self.logger.info("HSM support requested but not implemented - using software fallback")
    self.hsm_enabled = False
    #         except Exception as e:
                self.logger.warning(f"HSM initialization failed: {str(e)}")
    self.hsm_enabled = False

    #     def _initialize_storage(self, master_password: Optional[str] = None):
    #         """Initialize secure storage."""
    #         try:
    #             # Load or create master key
    #             if master_password:
    self._master_key = self._derive_key_from_password(master_password)
    #             else:
    self._master_key = self._load_or_create_master_key()

    #             # Load existing keys and entries
                self._load_keys()
                self._load_entries()

    #             # Ensure we have at least one active key
    #             if not self._get_active_key():
                    self._create_new_key()

    #         except Exception as e:
                self.logger.error(f"Failed to initialize secure storage: {str(e)}")
                raise SecureStorageError(f"Storage initialization failed: {str(e)}", 4502)

    #     def _derive_key_from_password(self, password: str, salt: Optional[bytes] = None) -> bytes:
    #         """Derive encryption key from password using PBKDF2."""
    #         if salt is None:
    salt = os.urandom(self.DEFAULT_SALT_SIZE)

    kdf = PBKDF2HMAC(
    algorithm = hashes.SHA256(),
    length = self.DEFAULT_KEY_SIZE,
    salt = salt,
    iterations = self.DEFAULT_ITERATIONS,
    backend = default_backend()
    #         )

    key = kdf.derive(password.encode())
    #         return key

    #     def _load_or_create_master_key(self) -> bytes:
    #         """Load existing master key or create new one."""
    master_key_file = self.storage_dir / ".master_key"

    #         if master_key_file.exists():
    #             try:
    #                 with open(master_key_file, 'rb') as f:
    key_data = f.read()
    #                 return key_data
    #             except Exception as e:
                    self.logger.warning(f"Failed to load master key: {str(e)}")

    #         # Create new master key
    master_key = os.urandom(self.DEFAULT_KEY_SIZE)
    #         try:
    #             with open(master_key_file, 'wb') as f:
                    f.write(master_key)

                # Set restrictive permissions (Unix-like systems)
    #             try:
                    os.chmod(master_key_file, 0o600)
    #             except AttributeError:
    #                 pass  # Windows doesn't support chmod

    #             return master_key

    #         except Exception as e:
                raise SecureStorageError(f"Failed to create master key: {str(e)}", 4503)

    #     def _create_new_key(self, algorithm: Optional[EncryptionAlgorithm] = None,
    source_type: KeySourceType = math.subtract(KeySourceType.GENERATED), > EncryptionKey:)
    #         """Create a new encryption key."""
    algorithm = algorithm or self.DEFAULT_ALGORITHM
    key_id = secrets.token_hex(16)

    #         # Generate key material
    #         if algorithm == EncryptionAlgorithm.FERNET:
    key = Fernet.generate_key()
    #         else:
    key = os.urandom(self.DEFAULT_KEY_SIZE)

    #         # Encrypt key with master key
    encrypted_key = self._encrypt_with_master_key(key)

    #         # Create key metadata
    encryption_key = EncryptionKey(
    key_id = key_id,
    algorithm = algorithm,
    source_type = source_type,
    created_at = datetime.now(),
    last_rotated = datetime.now(),
    metadata = {'encrypted_key': base64.b64encode(encrypted_key).decode()}
    #         )

    #         # Store key
    self._keys[key_id] = encryption_key
            self._save_keys()

            self.logger.info(f"Created new encryption key: {key_id}")
    #         return encryption_key

    #     def _encrypt_with_master_key(self, data: bytes) -> bytes:
    #         """Encrypt data with master key."""
    #         if not self._master_key:
                raise SecureStorageError("Master key not available", 4504)

    #         if self.hsm_enabled and self._hsm:
                return self._hsm.encrypt(data)

    #         # Use AES-256-GCM for master key encryption
    iv = os.urandom(self.DEFAULT_IV_SIZE)
    cipher = Cipher(
                algorithms.AES(self._master_key),
                modes.GCM(iv),
    backend = default_backend()
    #         )
    encryptor = cipher.encryptor()
    ciphertext = math.add(encryptor.update(data), encryptor.finalize())

    #         # Return IV + ciphertext + tag
    #         return iv + ciphertext + encryptor.tag

    #     def _decrypt_with_master_key(self, encrypted_data: bytes) -> bytes:
    #         """Decrypt data with master key."""
    #         if not self._master_key:
                raise SecureStorageError("Master key not available", 4504)

    #         if self.hsm_enabled and self._hsm:
                return self._hsm.decrypt(encrypted_data)

    #         # Extract IV, ciphertext, and tag
    iv = encrypted_data[:self.DEFAULT_IV_SIZE]
    tag = math.subtract(encrypted_data[, self.DEFAULT_TAG_SIZE:])
    ciphertext = math.subtract(encrypted_data[self.DEFAULT_IV_SIZE:, self.DEFAULT_TAG_SIZE])

    cipher = Cipher(
                algorithms.AES(self._master_key),
                modes.GCM(iv, tag),
    backend = default_backend()
    #         )
    decryptor = cipher.decryptor()
            return decryptor.update(ciphertext) + decryptor.finalize()

    #     def _get_active_key(self) -> Optional[EncryptionKey]:
    #         """Get the currently active encryption key."""
    #         for key in self._keys.values():
    #             if key.is_active:
    #                 return key
    #         return None

    #     def _load_keys(self):
    #         """Load encryption keys from storage."""
    #         if self.keys_file.exists():
    #             try:
    #                 with open(self.keys_file, 'r', encoding='utf-8') as f:
    keys_data = json.load(f)

    #                 for key_data in keys_data:
    key = EncryptionKey(
    key_id = key_data['key_id'],
    algorithm = EncryptionAlgorithm(key_data['algorithm']),
    source_type = KeySourceType(key_data['source_type']),
    created_at = datetime.fromisoformat(key_data['created_at']),
    #                         expires_at=datetime.fromisoformat(key_data['expires_at']) if key_data.get('expires_at') else None,
    #                         last_rotated=datetime.fromisoformat(key_data['last_rotated']) if key_data.get('last_rotated') else None,
    rotation_interval_days = key_data.get('rotation_interval_days', 90),
    is_active = key_data.get('is_active', True),
    metadata = key_data.get('metadata', {})
    #                     )
    self._keys[key.key_id] = key

    #             except Exception as e:
                    self.logger.warning(f"Failed to load keys: {str(e)}")

    #     def _save_keys(self):
    #         """Save encryption keys to storage."""
    #         try:
    keys_data = []
    #             for key in self._keys.values():
    key_dict = {
    #                     'key_id': key.key_id,
    #                     'algorithm': key.algorithm.value,
    #                     'source_type': key.source_type.value,
                        'created_at': key.created_at.isoformat(),
    #                     'expires_at': key.expires_at.isoformat() if key.expires_at else None,
    #                     'last_rotated': key.last_rotated.isoformat() if key.last_rotated else None,
    #                     'rotation_interval_days': key.rotation_interval_days,
    #                     'is_active': key.is_active,
    #                     'metadata': key.metadata
    #                 }
                    keys_data.append(key_dict)

    #             with open(self.keys_file, 'w', encoding='utf-8') as f:
    json.dump(keys_data, f, indent = 2)

    #         except Exception as e:
                self.logger.error(f"Failed to save keys: {str(e)}")
                raise SecureStorageError(f"Failed to save keys: {str(e)}", 4505)

    #     def _load_entries(self):
    #         """Load secure entries from storage."""
    #         if self.entries_file.exists():
    #             try:
    #                 with open(self.entries_file, 'rb') as f:
    encrypted_entries = f.read()

    #                 # Decrypt entries with master key
    entries_json = self._decrypt_with_master_key(encrypted_entries)
    entries_data = json.loads(entries_json.decode('utf-8'))

    #                 for entry_data in entries_data:
    entry = SecureEntry(
    entry_id = entry_data['entry_id'],
    key_id = entry_data['key_id'],
    encrypted_data = base64.b64decode(entry_data['encrypted_data']),
    #                         iv=base64.b64decode(entry_data['iv']) if entry_data.get('iv') else None,
    #                         tag=base64.b64decode(entry_data['tag']) if entry_data.get('tag') else None,
    checksum = entry_data.get('checksum', ''),
    created_at = datetime.fromisoformat(entry_data['created_at']),
    updated_at = datetime.fromisoformat(entry_data['updated_at']),
    access_count = entry_data.get('access_count', 0),
    #                         last_accessed=datetime.fromisoformat(entry_data['last_accessed']) if entry_data.get('last_accessed') else None,
    metadata = entry_data.get('metadata', {})
    #                     )
    self._entries[entry.entry_id] = entry

    #             except Exception as e:
                    self.logger.warning(f"Failed to load entries: {str(e)}")

    #     def _save_entries(self):
    #         """Save secure entries to storage."""
    #         try:
    entries_data = []
    #             for entry in self._entries.values():
    entry_dict = {
    #                     'entry_id': entry.entry_id,
    #                     'key_id': entry.key_id,
                        'encrypted_data': base64.b64encode(entry.encrypted_data).decode(),
    #                     'iv': base64.b64encode(entry.iv).decode() if entry.iv else None,
    #                     'tag': base64.b64encode(entry.tag).decode() if entry.tag else None,
    #                     'checksum': entry.checksum,
                        'created_at': entry.created_at.isoformat(),
                        'updated_at': entry.updated_at.isoformat(),
    #                     'access_count': entry.access_count,
    #                     'last_accessed': entry.last_accessed.isoformat() if entry.last_accessed else None,
    #                     'metadata': entry.metadata
    #                 }
                    entries_data.append(entry_dict)

    entries_json = json.dumps(entries_data, indent=2).encode('utf-8')
    encrypted_entries = self._encrypt_with_master_key(entries_json)

    #             with open(self.entries_file, 'wb') as f:
                    f.write(encrypted_entries)

    #         except Exception as e:
                self.logger.error(f"Failed to save entries: {str(e)}")
                raise SecureStorageError(f"Failed to save entries: {str(e)}", 4506)

    #     def _log_audit_event(self, event_type: str, entry_id: Optional[str] = None,
    details: Optional[Dict[str, Any]] = None):
    #         """Log security audit event."""
    #         try:
    audit_entry = {
                    'timestamp': datetime.now().isoformat(),
    #                 'event_type': event_type,
    #                 'entry_id': entry_id,
    #                 'details': details or {}
    #             }

    #             with open(self.audit_file, 'a', encoding='utf-8') as f:
                    f.write(json.dumps(audit_entry) + '\n')

    #         except Exception as e:
                self.logger.error(f"Failed to log audit event: {str(e)}")

    #     async def store(self, key: str, data: Union[str, bytes, Dict[str, Any]],
    key_id: Optional[str] = math.subtract(None, metadata: Optional[Dict[str, Any]] = None), > Dict[str, Any]:)
    #         """
    #         Store sensitive data securely.

    #         Args:
    #             key: Storage key
    #             data: Data to encrypt and store
                key_id: Specific key ID to use (default: active key)
    #             metadata: Additional metadata

    #         Returns:
    #             Storage result
    #         """
    #         try:
    #             # Get encryption key
    #             if key_id:
    #                 if key_id not in self._keys:
    #                     return {
    #                         'success': False,
    #                         'error': f"Encryption key '{key_id}' not found",
    #                         'error_code': 4507
    #                     }
    encryption_key = self._keys[key_id]
    #             else:
    encryption_key = self._get_active_key()
    #                 if not encryption_key:
    #                     return {
    #                         'success': False,
    #                         'error': "No active encryption key available",
    #                         'error_code': 4508
    #                     }

    #             # Prepare data
    #             if isinstance(data, dict):
    data_str = json.dumps(data)
    #             elif isinstance(data, str):
    data_str = data
    #             else:
    data_str = data.decode('utf-8')

    data_bytes = data_str.encode('utf-8')

    #             # Encrypt data
    encrypted_data, iv, tag = await self._encrypt_data(data_bytes, encryption_key)

    #             # Calculate checksum
    checksum = hashlib.sha256(data_bytes).hexdigest()

    #             # Create secure entry
    entry_id = secrets.token_hex(16)
    entry = SecureEntry(
    entry_id = entry_id,
    key_id = encryption_key.key_id,
    encrypted_data = encrypted_data,
    iv = iv,
    tag = tag,
    checksum = checksum,
    metadata = metadata or {}
    #             )

    #             # Store entry
    self._entries[key] = entry
                self._save_entries()

    #             # Log audit event
                self._log_audit_event('store', entry_id, {'key': key, 'key_id': encryption_key.key_id})

    #             return {
    #                 'success': True,
    #                 'message': f"Data stored securely with key '{key}'",
    #                 'entry_id': entry_id,
    #                 'key_id': encryption_key.key_id,
    #                 'algorithm': encryption_key.algorithm.value
    #             }

    #         except Exception as e:
                self.logger.error(f"Failed to store data: {str(e)}")
    #             return {
    #                 'success': False,
                    'error': f"Failed to store data: {str(e)}",
    #                 'error_code': 4509
    #             }

    #     async def _encrypt_data(self, data: bytes, encryption_key: EncryptionKey) -> Tuple[bytes, Optional[bytes], Optional[bytes]]:
    #         """Encrypt data with specified key."""
    #         # Get actual key material
    #         if 'encrypted_key' in encryption_key.metadata:
    key_material = base64.b64decode(encryption_key.metadata['encrypted_key'])
    key_material = self._decrypt_with_master_key(key_material)
    #         else:
    #             # Fallback for backward compatibility
    key_material = self._derive_key_from_password(encryption_key.key_id)

    #         if encryption_key.algorithm == EncryptionAlgorithm.FERNET:
    fernet = Fernet(base64.urlsafe_b64encode(key_material))
    encrypted_data = fernet.encrypt(data)
    #             return encrypted_data, None, None

    #         elif encryption_key.algorithm == EncryptionAlgorithm.AES_256_GCM:
    iv = os.urandom(self.DEFAULT_IV_SIZE)
    cipher = Cipher(
                    algorithms.AES(key_material),
                    modes.GCM(iv),
    backend = default_backend()
    #             )
    encryptor = cipher.encryptor()
    ciphertext = math.add(encryptor.update(data), encryptor.finalize())
    #             return ciphertext, iv, encryptor.tag

    #         elif encryption_key.algorithm == EncryptionAlgorithm.AES_256_CBC:
    iv = os.urandom(16)  # AES block size
    cipher = Cipher(
                    algorithms.AES(key_material),
                    modes.CBC(iv),
    backend = default_backend()
    #             )
    encryptor = cipher.encryptor()

    #             # Pad data to block size
    pad_length = math.subtract(16, (len(data) % 16))
    padded_data = math.add(data, bytes([pad_length] * pad_length))

    ciphertext = math.add(encryptor.update(padded_data), encryptor.finalize())
    #             return ciphertext, iv, None

    #         else:
                raise SecureStorageError(f"Unsupported algorithm: {encryption_key.algorithm}", 4510)

    #     async def retrieve(self, key: str) -> Dict[str, Any]:
    #         """
    #         Retrieve and decrypt sensitive data.

    #         Args:
    #             key: Storage key

    #         Returns:
    #             Retrieval result
    #         """
    #         try:
    #             if key not in self._entries:
    #                 return {
    #                     'success': False,
    #                     'error': f"Entry with key '{key}' not found",
    #                     'error_code': 4511
    #                 }

    entry = self._entries[key]

    #             # Get encryption key
    #             if entry.key_id not in self._keys:
    #                 return {
    #                     'success': False,
    #                     'error': f"Encryption key '{entry.key_id}' not found",
    #                     'error_code': 4507
    #                 }

    encryption_key = self._keys[entry.key_id]

    #             # Decrypt data
    decrypted_data = await self._decrypt_data(entry, encryption_key)

    #             # Verify checksum
    calculated_checksum = hashlib.sha256(decrypted_data).hexdigest()
    #             if calculated_checksum != entry.checksum:
                    self._log_audit_event('checksum_mismatch', entry.entry_id)
    #                 return {
    #                     'success': False,
    #                     'error': "Data integrity check failed",
    #                     'error_code': 4512
    #                 }

    #             # Update access statistics
    entry.access_count + = 1
    entry.last_accessed = datetime.now()
                self._save_entries()

    #             # Parse data
    #             try:
    data = json.loads(decrypted_data.decode('utf-8'))
    data_type = 'json'
                except (json.JSONDecodeError, UnicodeDecodeError):
    data = decrypted_data.decode('utf-8')
    data_type = 'string'

    #             # Log audit event
                self._log_audit_event('retrieve', entry.entry_id, {'key': key})

    #             return {
    #                 'success': True,
    #                 'data': data,
    #                 'data_type': data_type,
    #                 'entry_id': entry.entry_id,
    #                 'key_id': entry.key_id,
    #                 'access_count': entry.access_count,
                    'last_accessed': entry.last_accessed.isoformat()
    #             }

    #         except Exception as e:
                self.logger.error(f"Failed to retrieve data: {str(e)}")
    #             return {
    #                 'success': False,
                    'error': f"Failed to retrieve data: {str(e)}",
    #                 'error_code': 4513
    #             }

    #     async def _decrypt_data(self, entry: SecureEntry, encryption_key: EncryptionKey) -> bytes:
    #         """Decrypt data with specified key."""
    #         # Get actual key material
    #         if 'encrypted_key' in encryption_key.metadata:
    key_material = base64.b64decode(encryption_key.metadata['encrypted_key'])
    key_material = self._decrypt_with_master_key(key_material)
    #         else:
    #             # Fallback for backward compatibility
    key_material = self._derive_key_from_password(encryption_key.key_id)

    #         if encryption_key.algorithm == EncryptionAlgorithm.FERNET:
    fernet = Fernet(base64.urlsafe_b64encode(key_material))
                return fernet.decrypt(entry.encrypted_data)

    #         elif encryption_key.algorithm == EncryptionAlgorithm.AES_256_GCM:
    #             if not entry.iv or not entry.tag:
    #                 raise SecureStorageError("Missing IV or tag for AES-256-GCM", 4514)

    cipher = Cipher(
                    algorithms.AES(key_material),
                    modes.GCM(entry.iv, entry.tag),
    backend = default_backend()
    #             )
    decryptor = cipher.decryptor()
                return decryptor.update(entry.encrypted_data) + decryptor.finalize()

    #         elif encryption_key.algorithm == EncryptionAlgorithm.AES_256_CBC:
    #             if not entry.iv:
    #                 raise SecureStorageError("Missing IV for AES-256-CBC", 4515)

    cipher = Cipher(
                    algorithms.AES(key_material),
                    modes.CBC(entry.iv),
    backend = default_backend()
    #             )
    decryptor = cipher.decryptor()
    padded_data = math.add(decryptor.update(entry.encrypted_data), decryptor.finalize())

    #             # Remove padding
    pad_length = math.subtract(padded_data[, 1])
    #             return padded_data[:-pad_length]

    #         else:
                raise SecureStorageError(f"Unsupported algorithm: {encryption_key.algorithm}", 4510)

    #     async def delete(self, key: str) -> Dict[str, Any]:
    #         """
    #         Delete sensitive data.

    #         Args:
    #             key: Storage key

    #         Returns:
    #             Deletion result
    #         """
    #         try:
    #             if key not in self._entries:
    #                 return {
    #                     'success': False,
    #                     'error': f"Entry with key '{key}' not found",
    #                     'error_code': 4511
    #                 }

    entry = self._entries[key]
    entry_id = entry.entry_id

    #             # Remove entry
    #             del self._entries[key]
                self._save_entries()

    #             # Log audit event
                self._log_audit_event('delete', entry_id, {'key': key})

    #             return {
    #                 'success': True,
    #                 'message': f"Entry with key '{key}' deleted successfully",
    #                 'entry_id': entry_id
    #             }

    #         except Exception as e:
                self.logger.error(f"Failed to delete data: {str(e)}")
    #             return {
    #                 'success': False,
                    'error': f"Failed to delete data: {str(e)}",
    #                 'error_code': 4516
    #             }

    #     async def rotate_keys(self, force: bool = False) -> Dict[str, Any]:
    #         """
    #         Rotate encryption keys.

    #         Args:
    #             force: Force rotation even if not due

    #         Returns:
    #             Rotation result
    #         """
    #         try:
    rotated_keys = []

    #             for key in self._keys.values():
    should_rotate = force or self._should_rotate_key(key)

    #                 if should_rotate:
    #                     # Create new key
    new_key = self._create_new_key(key.algorithm, key.source_type)
    new_key.rotation_interval_days = key.rotation_interval_days

    #                     # Re-encrypt entries that use the old key
    #                     for entry in self._entries.values():
    #                         if entry.key_id == key.key_id:
    #                             # Decrypt with old key
    decrypted_data = await self._decrypt_data(entry, key)

    #                             # Encrypt with new key
    encrypted_data, iv, tag = await self._encrypt_data(decrypted_data, new_key)

    #                             # Update entry
    entry.key_id = new_key.key_id
    entry.encrypted_data = encrypted_data
    entry.iv = iv
    entry.tag = tag
    entry.updated_at = datetime.now()

    #                     # Deactivate old key
    key.is_active = False

                        rotated_keys.append({
    #                         'old_key_id': key.key_id,
    #                         'new_key_id': new_key.key_id,
    #                         'entries_migrated': len([e for e in self._entries.values() if e.key_id == new_key.key_id])
    #                     })

    #             if rotated_keys:
                    self._save_keys()
                    self._save_entries()

    #                 # Log audit event
    self._log_audit_event('key_rotation', details = {'rotated_keys': rotated_keys})

    #                 return {
    #                     'success': True,
                        'message': f"Rotated {len(rotated_keys)} encryption keys",
    #                     'rotated_keys': rotated_keys
    #                 }
    #             else:
    #                 return {
    #                     'success': True,
    #                     'message': "No keys required rotation"
    #                 }

    #         except Exception as e:
                self.logger.error(f"Key rotation failed: {str(e)}")
    #             return {
    #                 'success': False,
                    'error': f"Key rotation failed: {str(e)}",
    #                 'error_code': 4517
    #             }

    #     def _should_rotate_key(self, key: EncryptionKey) -> bool:
    #         """Check if key should be rotated."""
    #         if not key.last_rotated:
    #             return True

    rotation_date = math.add(key.last_rotated, timedelta(days=key.rotation_interval_days))
    return datetime.now() > = rotation_date

    #     async def _check_key_rotation(self):
    #         """Periodically check for key rotation."""
    #         while True:
    #             try:
                    await asyncio.sleep(3600)  # Check every hour
                    await self.rotate_keys()
    #             except Exception as e:
                    self.logger.error(f"Key rotation check failed: {str(e)}")

    #     async def list_entries(self) -> Dict[str, Any]:
    #         """
            List all stored entries (metadata only).

    #         Returns:
    #             List of entries
    #         """
    #         try:
    entries = []
    #             for key, entry in self._entries.items():
                    entries.append({
    #                     'key': key,
    #                     'entry_id': entry.entry_id,
    #                     'key_id': entry.key_id,
                        'created_at': entry.created_at.isoformat(),
                        'updated_at': entry.updated_at.isoformat(),
    #                     'access_count': entry.access_count,
    #                     'last_accessed': entry.last_accessed.isoformat() if entry.last_accessed else None,
    #                     'metadata': entry.metadata
    #                 })

    #             return {
    #                 'success': True,
    #                 'entries': entries,
                    'count': len(entries)
    #             }

    #         except Exception as e:
                self.logger.error(f"Failed to list entries: {str(e)}")
    #             return {
    #                 'success': False,
                    'error': f"Failed to list entries: {str(e)}",
    #                 'error_code': 4518
    #             }

    #     async def get_storage_info(self) -> Dict[str, Any]:
    #         """
    #         Get information about the secure storage.

    #         Returns:
    #             Storage information
    #         """
    #         try:
    key_counts = {}
    #             for key in self._keys.values():
    algorithm = key.algorithm.value
    key_counts[algorithm] = math.add(key_counts.get(algorithm, 0), 1)

    #             return {
    #                 'name': self.name,
    #                 'version': '2.0.0',
                    'storage_dir': str(self.storage_dir),
                    'total_keys': len(self._keys),
    #                 'active_keys': len([k for k in self._keys.values() if k.is_active]),
                    'total_entries': len(self._entries),
    #                 'key_counts': key_counts,
    #                 'hsm_enabled': self.hsm_enabled,
    #                 'auto_rotate': self.auto_rotate,
    #                 'default_algorithm': self.DEFAULT_ALGORITHM.value,
    #                 'features': [
    #                     'aes_256_encryption',
    #                     'key_rotation',
    #                     'audit_logging',
    #                     'hsm_support',
    #                     'integrity_verification',
    #                     'access_tracking',
    #                     'multiple_algorithms'
    #                 ]
    #             }

    #         except Exception as e:
                self.logger.error(f"Failed to get storage info: {str(e)}")
    #             return {
    #                 'success': False,
                    'error': f"Failed to get storage info: {str(e)}",
    #                 'error_code': 4519
    #             }