# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Homomorphic Encryption System for Noodle - Secure computation on encrypted data
# """

import asyncio
import logging
import time
import json
import base64
import typing.Dict,
import dataclasses.dataclass,
import enum.Enum
import abc.ABC,
import numpy as np
import cryptography.hazmat.primitives.hashes,
import cryptography.hazmat.primitives.asymmetric.rsa,
import cryptography.hazmat.primitives.kdf.pbkdf2.PBKDF2HMAC
import cryptography.hazmat.primitives.ciphers.Cipher,
import cryptography.hazmat.backends.default_backend

logger = logging.getLogger(__name__)


class EncryptionScheme(Enum)
    #     """Homomorphic encryption schemes"""
    PAILLIER = "paillier"
    BFV = "bfv"  # Brakerski-Fan-Vercauteren
    CKKS = "ckks"  # Cheon-Kim-Kim-Song
    ELGAMAL = "elgamal"
    RSA_PARTIAL = "rsa_partial"


class SecurityLevel(Enum)
    #     """Security levels for encryption"""
    LOW_128 = "low_128"      # 128-bit security
    MEDIUM_192 = "medium_192" # 192-bit security
    HIGH_256 = "high_256"     # 256-bit security
    VERY_HIGH_512 = "very_high_512"  # 512-bit security


# @dataclass
class EncryptionKey
    #     """Encryption key pair"""
    #     key_id: str
    #     scheme: EncryptionScheme
    #     security_level: SecurityLevel
    #     public_key: bytes
    private_key: Optional[bytes] = None
    key_size: int = 2048
    created_at: float = field(default_factory=time.time)
    expires_at: Optional[float] = None

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             'key_id': self.key_id,
    #             'scheme': self.scheme.value,
    #             'security_level': self.security_level.value,
                'public_key': base64.b64encode(self.public_key).decode('utf-8'),
    #             'private_key': base64.b64encode(self.private_key).decode('utf-8') if self.private_key else None,
    #             'key_size': self.key_size,
    #             'created_at': self.created_at,
    #             'expires_at': self.expires_at
    #         }

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -> 'EncryptionKey':
    #         """Create from dictionary"""
            return cls(
    key_id = data['key_id'],
    scheme = EncryptionScheme(data['scheme']),
    security_level = SecurityLevel(data['security_level']),
    public_key = base64.b64decode(data['public_key'].encode('utf-8')),
    #             private_key=base64.b64decode(data['private_key'].encode('utf-8')) if data['private_key'] else None,
    key_size = data['key_size'],
    created_at = data['created_at'],
    expires_at = data['expires_at']
    #         )


# @dataclass
class EncryptedData
    #     """Encrypted data container"""
    #     data_id: str
    #     key_id: str
    #     scheme: EncryptionScheme
    #     ciphertext: bytes
    metadata: Dict[str, Any] = field(default_factory=dict)
    created_at: float = field(default_factory=time.time)

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             'data_id': self.data_id,
    #             'key_id': self.key_id,
    #             'scheme': self.scheme.value,
                'ciphertext': base64.b64encode(self.ciphertext).decode('utf-8'),
    #             'metadata': self.metadata,
    #             'created_at': self.created_at
    #         }

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -> 'EncryptedData':
    #         """Create from dictionary"""
            return cls(
    data_id = data['data_id'],
    key_id = data['key_id'],
    scheme = EncryptionScheme(data['scheme']),
    ciphertext = base64.b64decode(data['ciphertext'].encode('utf-8')),
    metadata = data['metadata'],
    created_at = data['created_at']
    #         )


class HomomorphicEncryptor(ABC)
    #     """Abstract base class for homomorphic encryptors"""

    #     def __init__(self, scheme: EncryptionScheme, security_level: SecurityLevel):
    self.scheme = scheme
    self.security_level = security_level

    #     @abstractmethod
    #     async def generate_key_pair(self, key_id: str) -> EncryptionKey:
    #         """Generate encryption key pair"""
    #         pass

    #     @abstractmethod
    #     async def encrypt(self, plaintext: Union[str, int, float, bytes],
    #                       public_key: bytes) -> bytes:
    #         """Encrypt plaintext"""
    #         pass

    #     @abstractmethod
    #     async def decrypt(self, ciphertext: bytes,
    #                       private_key: bytes) -> Union[str, int, float, bytes]:
    #         """Decrypt ciphertext"""
    #         pass

    #     @abstractmethod
    #     async def add(self, ciphertext1: bytes, ciphertext2: bytes,
    #                   public_key: bytes) -> bytes:
    #         """Homomorphic addition"""
    #         pass

    #     @abstractmethod
    #     async def multiply(self, ciphertext1: bytes, ciphertext2: bytes,
    #                        public_key: bytes) -> bytes:
    #         """Homomorphic multiplication"""
    #         pass

    #     @abstractmethod
    #     async def scalar_multiply(self, ciphertext: bytes, scalar: Union[int, float],
    #                              public_key: bytes) -> bytes:
    #         """Scalar multiplication"""
    #         pass


class PaillierEncryptor(HomomorphicEncryptor)
    #     """Paillier homomorphic encryption implementation"""

    #     def __init__(self, security_level: SecurityLevel = SecurityLevel.HIGH_256):
            super().__init__(EncryptionScheme.PAILLIER, security_level)
    self.key_size = self._get_key_size()

    #     def _get_key_size(self) -> int:
    #         """Get key size based on security level"""
    sizes = {
    #             SecurityLevel.LOW_128: 1024,
    #             SecurityLevel.MEDIUM_192: 2048,
    #             SecurityLevel.HIGH_256: 4096,
    #             SecurityLevel.VERY_HIGH_512: 8192
    #         }
            return sizes.get(self.security_level, 2048)

    #     async def generate_key_pair(self, key_id: str) -> EncryptionKey:
    #         """Generate Paillier key pair"""
    #         # Generate RSA key pair (simplified for demonstration)
    #         # In production, use proper Paillier implementation
    private_key = rsa.generate_private_key(
    public_exponent = 65537,
    key_size = self.key_size,
    backend = default_backend()
    #         )

    public_key = private_key.public_key()

    #         # Serialize keys
    private_bytes = private_key.private_bytes(
    encoding = serialization.Encoding.PEM,
    format = serialization.PrivateFormat.PKCS8,
    encryption_algorithm = serialization.NoEncryption()
    #         )

    public_bytes = public_key.public_bytes(
    encoding = serialization.Encoding.PEM,
    format = serialization.PublicFormat.SubjectPublicKeyInfo
    #         )

            return EncryptionKey(
    key_id = key_id,
    scheme = self.scheme,
    security_level = self.security_level,
    public_key = public_bytes,
    private_key = private_bytes,
    key_size = self.key_size
    #         )

    #     async def encrypt(self, plaintext: Union[str, int, float, bytes],
    #                       public_key: bytes) -> bytes:
    #         """Encrypt plaintext using Paillier"""
            # Convert plaintext to integer (Paillier works on integers)
    #         if isinstance(plaintext, str):
    plaintext_int = int.from_bytes(plaintext.encode('utf-8'), 'big')
    #         elif isinstance(plaintext, (int, float)):
    #             plaintext_int = int(plaintext * 1000)  # Scale for floats
    #         elif isinstance(plaintext, bytes):
    plaintext_int = int.from_bytes(plaintext, 'big')
    #         else:
                raise ValueError(f"Unsupported plaintext type: {type(plaintext)}")

    #         # Load public key
    public_key_obj = serialization.load_pem_public_key(
    #             public_key,
    backend = default_backend()
    #         )

            # Simplified Paillier encryption (using RSA as placeholder)
    #         # In production, implement proper Paillier encryption
    plaintext_bytes = plaintext_int.to_bytes((plaintext_int.bit_length() + 7) // 8, 'big')

    ciphertext = public_key_obj.encrypt(
    #             plaintext_bytes,
                padding.OAEP(
    mgf = padding.MGF1(algorithm=hashes.SHA256()),
    algorithm = hashes.SHA256(),
    label = None
    #             )
    #         )

    #         return ciphertext

    #     async def decrypt(self, ciphertext: bytes,
    #                       private_key: bytes) -> Union[str, int, float, bytes]:
    #         """Decrypt ciphertext using Paillier"""
    #         # Load private key
    private_key_obj = serialization.load_pem_private_key(
    #             private_key,
    password = None,
    backend = default_backend()
    #         )

    #         # Decrypt
    plaintext_bytes = private_key_obj.decrypt(
    #             ciphertext,
                padding.OAEP(
    mgf = padding.MGF1(algorithm=hashes.SHA256()),
    algorithm = hashes.SHA256(),
    label = None
    #             )
    #         )

    #         # Convert back to integer
    plaintext_int = int.from_bytes(plaintext_bytes, 'big')

            # Try to determine original type (simplified)
    #         if plaintext_int < 2**32:
    #             return plaintext_int
    #         else:
    #             return plaintext_bytes

    #     async def add(self, ciphertext1: bytes, ciphertext2: bytes,
    #                   public_key: bytes) -> bytes:
            """Homomorphic addition (simplified)"""
    #         # In real Paillier: multiply ciphertexts
    #         # This is a simplified implementation
    #         return ciphertext1 + ciphertext2

    #     async def multiply(self, ciphertext1: bytes, ciphertext2: bytes,
    #                        public_key: bytes) -> bytes:
            """Homomorphic multiplication (simplified)"""
    #         # In real Paillier: exponentiate ciphertext1 by plaintext2
    #         # This is a simplified implementation
            return ciphertext1 * len(ciphertext2)

    #     async def scalar_multiply(self, ciphertext: bytes, scalar: Union[int, float],
    #                              public_key: bytes) -> bytes:
            """Scalar multiplication (simplified)"""
    #         # In real Paillier: exponentiate ciphertext by scalar
    #         # This is a simplified implementation
            return ciphertext * int(scalar)


class BFVEncryptor(HomomorphicEncryptor)
        """BFV (Brakerski-Fan-Vercauteren) homomorphic encryption"""

    #     def __init__(self, security_level: SecurityLevel = SecurityLevel.HIGH_256):
            super().__init__(EncryptionScheme.BFV, security_level)
    self.poly_degree = 1024
    self.plain_modulus = 1032193

    #     async def generate_key_pair(self, key_id: str) -> EncryptionKey:
    #         """Generate BFV key pair"""
    #         # Simplified BFV key generation
    #         # In production, use proper BFV implementation
    private_key = rsa.generate_private_key(
    public_exponent = 65537,
    key_size = 2048,
    backend = default_backend()
    #         )

    public_key = private_key.public_key()

    private_bytes = private_key.private_bytes(
    encoding = serialization.Encoding.PEM,
    format = serialization.PrivateFormat.PKCS8,
    encryption_algorithm = serialization.NoEncryption()
    #         )

    public_bytes = public_key.public_bytes(
    encoding = serialization.Encoding.PEM,
    format = serialization.PublicFormat.SubjectPublicKeyInfo
    #         )

            return EncryptionKey(
    key_id = key_id,
    scheme = self.scheme,
    security_level = self.security_level,
    public_key = public_bytes,
    private_key = private_bytes,
    key_size = 2048
    #         )

    #     async def encrypt(self, plaintext: Union[str, int, float, bytes],
    #                       public_key: bytes) -> bytes:
    #         """Encrypt plaintext using BFV"""
    #         # Simplified BFV encryption
    public_key_obj = serialization.load_pem_public_key(
    #             public_key,
    backend = default_backend()
    #         )

    #         # Convert to bytes
    #         if isinstance(plaintext, str):
    plaintext_bytes = plaintext.encode('utf-8')
    #         elif isinstance(plaintext, (int, float)):
    plaintext_bytes = str(plaintext).encode('utf-8')
    #         else:
    plaintext_bytes = plaintext

    ciphertext = public_key_obj.encrypt(
    #             plaintext_bytes,
                padding.OAEP(
    mgf = padding.MGF1(algorithm=hashes.SHA256()),
    algorithm = hashes.SHA256(),
    label = None
    #             )
    #         )

    #         return ciphertext

    #     async def decrypt(self, ciphertext: bytes,
    #                       private_key: bytes) -> Union[str, int, float, bytes]:
    #         """Decrypt ciphertext using BFV"""
    private_key_obj = serialization.load_pem_private_key(
    #             private_key,
    password = None,
    backend = default_backend()
    #         )

    plaintext_bytes = private_key_obj.decrypt(
    #             ciphertext,
                padding.OAEP(
    mgf = padding.MGF1(algorithm=hashes.SHA256()),
    algorithm = hashes.SHA256(),
    label = None
    #             )
    #         )

    #         return plaintext_bytes

    #     async def add(self, ciphertext1: bytes, ciphertext2: bytes,
    #                   public_key: bytes) -> bytes:
    #         """Homomorphic addition for BFV"""
    #         # Simplified BFV addition
    #         return ciphertext1 + ciphertext2

    #     async def multiply(self, ciphertext1: bytes, ciphertext2: bytes,
    #                        public_key: bytes) -> bytes:
    #         """Homomorphic multiplication for BFV"""
    #         # Simplified BFV multiplication
            return ciphertext1 * len(ciphertext2)

    #     async def scalar_multiply(self, ciphertext: bytes, scalar: Union[int, float],
    #                              public_key: bytes) -> bytes:
    #         """Scalar multiplication for BFV"""
            return ciphertext * int(scalar)


class CKKSEncryptor(HomomorphicEncryptor)
    #     """CKKS (Cheon-Kim-Kim-Song) homomorphic encryption for approximate arithmetic"""

    #     def __init__(self, security_level: SecurityLevel = SecurityLevel.HIGH_256):
            super().__init__(EncryptionScheme.CKKS, security_level)
    self.scale = math.multiply(2, *40)
    self.poly_degree = 8192

    #     async def generate_key_pair(self, key_id: str) -> EncryptionKey:
    #         """Generate CKKS key pair"""
    #         # Simplified CKKS key generation
    private_key = rsa.generate_private_key(
    public_exponent = 65537,
    key_size = 4096,
    backend = default_backend()
    #         )

    public_key = private_key.public_key()

    private_bytes = private_key.private_bytes(
    encoding = serialization.Encoding.PEM,
    format = serialization.PrivateFormat.PKCS8,
    encryption_algorithm = serialization.NoEncryption()
    #         )

    public_bytes = public_key.public_bytes(
    encoding = serialization.Encoding.PEM,
    format = serialization.PublicFormat.SubjectPublicKeyInfo
    #         )

            return EncryptionKey(
    key_id = key_id,
    scheme = self.scheme,
    security_level = self.security_level,
    public_key = public_bytes,
    private_key = private_bytes,
    key_size = 4096
    #         )

    #     async def encrypt(self, plaintext: Union[str, int, float, bytes],
    #                       public_key: bytes) -> bytes:
    #         """Encrypt plaintext using CKKS"""
    public_key_obj = serialization.load_pem_public_key(
    #             public_key,
    backend = default_backend()
    #         )

    #         # Convert to bytes and scale for approximate arithmetic
    #         if isinstance(plaintext, (int, float)):
    scaled_value = math.multiply(int(plaintext, self.scale))
    plaintext_bytes = scaled_value.to_bytes(8, 'big', signed=True)
    #         elif isinstance(plaintext, str):
    plaintext_bytes = plaintext.encode('utf-8')
    #         else:
    plaintext_bytes = plaintext

    ciphertext = public_key_obj.encrypt(
    #             plaintext_bytes,
                padding.OAEP(
    mgf = padding.MGF1(algorithm=hashes.SHA256()),
    algorithm = hashes.SHA256(),
    label = None
    #             )
    #         )

    #         return ciphertext

    #     async def decrypt(self, ciphertext: bytes,
    #                       private_key: bytes) -> Union[str, int, float, bytes]:
    #         """Decrypt ciphertext using CKKS"""
    private_key_obj = serialization.load_pem_private_key(
    #             private_key,
    password = None,
    backend = default_backend()
    #         )

    plaintext_bytes = private_key_obj.decrypt(
    #             ciphertext,
                padding.OAEP(
    mgf = padding.MGF1(algorithm=hashes.SHA256()),
    algorithm = hashes.SHA256(),
    label = None
    #             )
    #         )

    #         # Try to detect if it's a scaled float
    #         if len(plaintext_bytes) == 8:
    #             try:
    scaled_value = int.from_bytes(plaintext_bytes, 'big', signed=True)
    #                 return scaled_value / self.scale
    #             except:
    #                 pass

    #         return plaintext_bytes

    #     async def add(self, ciphertext1: bytes, ciphertext2: bytes,
    #                   public_key: bytes) -> bytes:
    #         """Homomorphic addition for CKKS"""
    #         return ciphertext1 + ciphertext2

    #     async def multiply(self, ciphertext1: bytes, ciphertext2: bytes,
    #                        public_key: bytes) -> bytes:
    #         """Homomorphic multiplication for CKKS"""
            return ciphertext1 * len(ciphertext2)

    #     async def scalar_multiply(self, ciphertext: bytes, scalar: Union[int, float],
    #                              public_key: bytes) -> bytes:
    #         """Scalar multiplication for CKKS"""
            return ciphertext * int(scalar)


class HomomorphicEncryptionManager
    #     """Manager for homomorphic encryption operations"""

    #     def __init__(self, config: Optional[Dict[str, Any]] = None):
    #         """
    #         Initialize homomorphic encryption manager

    #         Args:
    #             config: Configuration for encryption manager
    #         """
    self.config = config or {}
    self.encryptors: Dict[EncryptionScheme, HomomorphicEncryptor] = {}
    self.keys: Dict[str, EncryptionKey] = {}
    self.encrypted_data: Dict[str, EncryptedData] = {}

    #         # Initialize encryptors
            self._initialize_encryptors()

    #     def _initialize_encryptors(self):
    #         """Initialize encryptors for different schemes"""
    self.encryptors[EncryptionScheme.PAILLIER] = PaillierEncryptor()
    self.encryptors[EncryptionScheme.BFV] = BFVEncryptor()
    self.encryptors[EncryptionScheme.CKKS] = CKKSEncryptor()

    #     async def generate_key_pair(self, key_id: str, scheme: EncryptionScheme,
    security_level: SecurityLevel = math.subtract(SecurityLevel.HIGH_256), > EncryptionKey:)
    #         """
    #         Generate encryption key pair

    #         Args:
    #             key_id: Unique identifier for the key
    #             scheme: Encryption scheme to use
    #             security_level: Security level for the key

    #         Returns:
    #             Generated encryption key
    #         """
    #         if scheme not in self.encryptors:
                raise ValueError(f"Unsupported encryption scheme: {scheme}")

    encryptor = self.encryptors[scheme]

    #         # Update encryptor security level if needed
    #         if encryptor.security_level != security_level:
    #             if scheme == EncryptionScheme.PAILLIER:
    encryptor = PaillierEncryptor(security_level)
    #             elif scheme == EncryptionScheme.BFV:
    encryptor = BFVEncryptor(security_level)
    #             elif scheme == EncryptionScheme.CKKS:
    encryptor = CKKSEncryptor(security_level)

    self.encryptors[scheme] = encryptor

    key = await encryptor.generate_key_pair(key_id)
    self.keys[key_id] = key

    #         logger.info(f"Generated key pair for {key_id} using {scheme.value} scheme")

    #         return key

    #     async def encrypt_data(self, data_id: str, plaintext: Union[str, int, float, bytes],
    #                           key_id: str) -> EncryptedData:
    #         """
    #         Encrypt data using specified key

    #         Args:
    #             data_id: Unique identifier for the data
    #             plaintext: Data to encrypt
    #             key_id: Key to use for encryption

    #         Returns:
    #             Encrypted data container
    #         """
    #         if key_id not in self.keys:
                raise ValueError(f"Key not found: {key_id}")

    key = self.keys[key_id]
    encryptor = self.encryptors[key.scheme]

    ciphertext = await encryptor.encrypt(plaintext, key.public_key)

    encrypted_data = EncryptedData(
    data_id = data_id,
    key_id = key_id,
    scheme = key.scheme,
    ciphertext = ciphertext,
    metadata = {
                    'original_type': type(plaintext).__name__,
                    'encrypted_at': time.time()
    #             }
    #         )

    self.encrypted_data[data_id] = encrypted_data

            logger.info(f"Encrypted data {data_id} using key {key_id}")

    #         return encrypted_data

    #     async def decrypt_data(self, data_id: str) -> Union[str, int, float, bytes]:
    #         """
    #         Decrypt data

    #         Args:
    #             data_id: ID of data to decrypt

    #         Returns:
    #             Decrypted plaintext
    #         """
    #         if data_id not in self.encrypted_data:
                raise ValueError(f"Encrypted data not found: {data_id}")

    encrypted_data = self.encrypted_data[data_id]
    key = self.keys[encrypted_data.key_id]

    #         if key.private_key is None:
    #             raise ValueError(f"No private key available for {encrypted_data.key_id}")

    encryptor = self.encryptors[encrypted_data.scheme]
    plaintext = await encryptor.decrypt(encrypted_data.ciphertext, key.private_key)

            logger.info(f"Decrypted data {data_id}")

    #         return plaintext

    #     async def homomorphic_add(self, data_id1: str, data_id2: str,
    #                              result_id: str) -> EncryptedData:
    #         """
    #         Perform homomorphic addition on encrypted data

    #         Args:
    #             data_id1: First encrypted data
    #             data_id2: Second encrypted data
    #             result_id: ID for the result

    #         Returns:
    #             Encrypted result
    #         """
    #         if data_id1 not in self.encrypted_data or data_id2 not in self.encrypted_data:
                raise ValueError("Encrypted data not found")

    data1 = self.encrypted_data[data_id1]
    data2 = self.encrypted_data[data_id2]

    #         if data1.scheme != data2.scheme:
    #             raise ValueError("Cannot add data encrypted with different schemes")

    key = self.keys[data1.key_id]
    encryptor = self.encryptors[data1.scheme]

    result_ciphertext = await encryptor.add(
    #             data1.ciphertext, data2.ciphertext, key.public_key
    #         )

    result_data = EncryptedData(
    data_id = result_id,
    key_id = data1.key_id,
    scheme = data1.scheme,
    ciphertext = result_ciphertext,
    metadata = {
    #                 'operation': 'add',
    #                 'operands': [data_id1, data_id2],
                    'computed_at': time.time()
    #             }
    #         )

    self.encrypted_data[result_id] = result_data

    logger.info(f"Performed homomorphic addition: {data_id1} + {data_id2} = {result_id}")

    #         return result_data

    #     async def homomorphic_multiply(self, data_id1: str, data_id2: str,
    #                                   result_id: str) -> EncryptedData:
    #         """
    #         Perform homomorphic multiplication on encrypted data

    #         Args:
    #             data_id1: First encrypted data
    #             data_id2: Second encrypted data
    #             result_id: ID for the result

    #         Returns:
    #             Encrypted result
    #         """
    #         if data_id1 not in self.encrypted_data or data_id2 not in self.encrypted_data:
                raise ValueError("Encrypted data not found")

    data1 = self.encrypted_data[data_id1]
    data2 = self.encrypted_data[data_id2]

    #         if data1.scheme != data2.scheme:
    #             raise ValueError("Cannot multiply data encrypted with different schemes")

    key = self.keys[data1.key_id]
    encryptor = self.encryptors[data1.scheme]

    result_ciphertext = await encryptor.multiply(
    #             data1.ciphertext, data2.ciphertext, key.public_key
    #         )

    result_data = EncryptedData(
    data_id = result_id,
    key_id = data1.key_id,
    scheme = data1.scheme,
    ciphertext = result_ciphertext,
    metadata = {
    #                 'operation': 'multiply',
    #                 'operands': [data_id1, data_id2],
                    'computed_at': time.time()
    #             }
    #         )

    self.encrypted_data[result_id] = result_data

    logger.info(f"Performed homomorphic multiplication: {data_id1} * {data_id2} = {result_id}")

    #         return result_data

    #     async def scalar_multiply(self, data_id: str, scalar: Union[int, float],
    #                               result_id: str) -> EncryptedData:
    #         """
    #         Perform scalar multiplication on encrypted data

    #         Args:
    #             data_id: Encrypted data
    #             scalar: Scalar value
    #             result_id: ID for the result

    #         Returns:
    #             Encrypted result
    #         """
    #         if data_id not in self.encrypted_data:
                raise ValueError("Encrypted data not found")

    data = self.encrypted_data[data_id]
    key = self.keys[data.key_id]
    encryptor = self.encryptors[data.scheme]

    result_ciphertext = await encryptor.scalar_multiply(
    #             data.ciphertext, scalar, key.public_key
    #         )

    result_data = EncryptedData(
    data_id = result_id,
    key_id = data.key_id,
    scheme = data.scheme,
    ciphertext = result_ciphertext,
    metadata = {
    #                 'operation': 'scalar_multiply',
    #                 'operand': data_id,
    #                 'scalar': scalar,
                    'computed_at': time.time()
    #             }
    #         )

    self.encrypted_data[result_id] = result_data

    logger.info(f"Performed scalar multiplication: {scalar} * {data_id} = {result_id}")

    #         return result_data

    #     def get_key(self, key_id: str) -> Optional[EncryptionKey]:
    #         """Get encryption key by ID"""
            return self.keys.get(key_id)

    #     def get_encrypted_data(self, data_id: str) -> Optional[EncryptedData]:
    #         """Get encrypted data by ID"""
            return self.encrypted_data.get(data_id)

    #     def list_keys(self) -> List[str]:
    #         """List all key IDs"""
            return list(self.keys.keys())

    #     def list_encrypted_data(self) -> List[str]:
    #         """List all encrypted data IDs"""
            return list(self.encrypted_data.keys())

    #     async def revoke_key(self, key_id: str):
    #         """
    #         Revoke encryption key

    #         Args:
    #             key_id: ID of key to revoke
    #         """
    #         if key_id not in self.keys:
                raise ValueError(f"Key not found: {key_id}")

    #         # Mark key as expired
    self.keys[key_id].expires_at = time.time()

            logger.info(f"Revoked key: {key_id}")

    #     async def delete_data(self, data_id: str):
    #         """
    #         Delete encrypted data

    #         Args:
    #             data_id: ID of data to delete
    #         """
    #         if data_id not in self.encrypted_data:
                raise ValueError(f"Encrypted data not found: {data_id}")

    #         del self.encrypted_data[data_id]

            logger.info(f"Deleted encrypted data: {data_id}")

    #     async def export_keys(self, key_ids: Optional[List[str]] = None) -> Dict[str, Any]:
    #         """
    #         Export encryption keys

    #         Args:
    #             key_ids: List of key IDs to export (all if None)

    #         Returns:
    #             Dictionary with exported keys
    #         """
    #         if key_ids is None:
    key_ids = list(self.keys.keys())

    exported_keys = {}
    #         for key_id in key_ids:
    #             if key_id in self.keys:
    exported_keys[key_id] = self.keys[key_id].to_dict()

    #         return {
                'exported_at': time.time(),
    #             'keys': exported_keys
    #         }

    #     async def import_keys(self, keys_data: Dict[str, Any]):
    #         """
    #         Import encryption keys

    #         Args:
    #             keys_data: Dictionary with keys to import
    #         """
    #         for key_id, key_dict in keys_data.get('keys', {}).items():
    key = EncryptionKey.from_dict(key_dict)
    self.keys[key_id] = key

            logger.info(f"Imported {len(keys_data.get('keys', {}))} keys")

    #     async def get_performance_metrics(self) -> Dict[str, Any]:
    #         """
    #         Get performance metrics for encryption operations

    #         Returns:
    #             Performance metrics
    #         """
    #         return {
                'total_keys': len(self.keys),
                'total_encrypted_data': len(self.encrypted_data),
    #             'supported_schemes': [scheme.value for scheme in self.encryptors.keys()],
                'timestamp': time.time()
    #         }