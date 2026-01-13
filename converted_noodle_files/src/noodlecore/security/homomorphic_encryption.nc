# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Homomorphic encryption implementation for Noodle.

# This module provides homomorphic encryption capabilities that allow
# computations on encrypted data without decrypting it first.
# """

import asyncio
import time
import logging
import json
import hashlib
import numpy as np
import typing.Dict,
import dataclasses.dataclass,
import enum.Enum
import collections.defaultdict,
import uuid
import abc.ABC,

logger = logging.getLogger(__name__)


class EncryptionScheme(Enum)
    #     """Types of homomorphic encryption schemes"""
    PAILLIER = "paillier"
    BFV = "bfv"  # Brakerski-Fan-Vercauteren
    CKKS = "ckks"  # Cheon-Kim-Kim-Song
    #     SIMPLE = "simple"  # Simplified for demonstration


class OperationType(Enum)
    #     """Types of operations supported"""
    ADDITION = "addition"
    MULTIPLICATION = "multiplication"
    SCALAR_ADD = "scalar_add"
    SCALAR_MUL = "scalar_mul"
    NEGATION = "negation"


class SecurityLevel(Enum)
    #     """Security levels for encryption"""
    LOW = math.subtract(128    # 128, bit security)
    MEDIUM = math.subtract(192   # 192, bit security)
    HIGH = math.subtract(256     # 256, bit security)
    VERY_HIGH = math.subtract(512 # 512, bit security)


# @dataclass
class EncryptionParams
    #     """Parameters for homomorphic encryption"""

    scheme: EncryptionScheme = EncryptionScheme.PAILLIER
    security_level: SecurityLevel = SecurityLevel.MEDIUM

    #     # Scheme-specific parameters
    key_size: int = 2048  # For Paillier
    poly_degree: int = math.divide(1024  # For BFV, CKKS)
    coeff_modulus: int = math.divide(0  # For BFV, CKKS)

    #     # Performance parameters
    max_depth: int = 10  # Maximum multiplication depth
    #     batch_size: int = 1   # Batch size for SIMD operations

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             'scheme': self.scheme.value,
    #             'security_level': self.security_level.value,
    #             'key_size': self.key_size,
    #             'poly_degree': self.poly_degree,
    #             'coeff_modulus': self.coeff_modulus,
    #             'max_depth': self.max_depth,
    #             'batch_size': self.batch_size
    #         }


# @dataclass
class Ciphertext
    #     """Represents encrypted data"""

    ciphertext_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    scheme: EncryptionScheme = EncryptionScheme.PAILLIER
    data: Any = None
    metadata: Dict[str, Any] = field(default_factory=dict)

    #     # Performance tracking
    encryption_time: float = 0.0
    size_bytes: int = 0

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             'ciphertext_id': self.ciphertext_id,
    #             'scheme': self.scheme.value,
    #             'data': self.data,
    #             'metadata': self.metadata,
    #             'encryption_time': self.encryption_time,
    #             'size_bytes': self.size_bytes
    #         }


# @dataclass
class EvaluationResult
    #     """Result of homomorphic evaluation"""

    result_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    ciphertext: Optional[Ciphertext] = None
    operation: OperationType = OperationType.ADDITION
    operands: List[str] = field(default_factory=list)

    #     # Performance metrics
    evaluation_time: float = 0.0
    noise_budget: float = 0.0

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             'result_id': self.result_id,
    #             'ciphertext': self.ciphertext.to_dict() if self.ciphertext else None,
    #             'operation': self.operation.value,
    #             'operands': self.operands,
    #             'evaluation_time': self.evaluation_time,
    #             'noise_budget': self.noise_budget
    #         }


class HomomorphicEncryptor(ABC)
    #     """Abstract base class for homomorphic encryption"""

    #     def __init__(self, params: EncryptionParams):
    #         """
    #         Initialize homomorphic encryptor

    #         Args:
    #             params: Encryption parameters
    #         """
    self.params = params
    self.public_key = None
    self.private_key = None

    #         # Performance tracking
    self._encryption_count = 0
    self._decryption_count = 0
    self._evaluation_count = 0
    self._total_encryption_time = 0.0
    self._total_decryption_time = 0.0
    self._total_evaluation_time = 0.0

    #     @abstractmethod
    #     async def generate_keys(self) -> bool:
    #         """Generate encryption keys"""
    #         pass

    #     @abstractmethod
    #     async def encrypt(self, plaintext: Any) -> Ciphertext:
    #         """
    #         Encrypt plaintext data

    #         Args:
    #             plaintext: Data to encrypt

    #         Returns:
    #             Encrypted ciphertext
    #         """
    #         pass

    #     @abstractmethod
    #     async def decrypt(self, ciphertext: Ciphertext) -> Any:
    #         """
    #         Decrypt ciphertext

    #         Args:
    #             ciphertext: Ciphertext to decrypt

    #         Returns:
    #             Decrypted plaintext
    #         """
    #         pass

    #     @abstractmethod
    #     async def evaluate(self, operation: OperationType,
    #                      operands: List[Ciphertext]) -> EvaluationResult:
    #         """
    #         Perform homomorphic operation

    #         Args:
    #             operation: Operation to perform
    #             operands: Encrypted operands

    #         Returns:
    #             Evaluation result
    #         """
    #         pass

    #     def get_performance_stats(self) -> Dict[str, Any]:
    #         """Get performance statistics"""
    stats = {
    #             'encryption_count': self._encryption_count,
    #             'decryption_count': self._decryption_count,
    #             'evaluation_count': self._evaluation_count,
                'avg_encryption_time': self._total_encryption_time / max(self._encryption_count, 1),
                'avg_decryption_time': self._total_decryption_time / max(self._decryption_count, 1),
                'avg_evaluation_time': self._total_evaluation_time / max(self._evaluation_count, 1)
    #         }

    #         return stats


class SimpleHomomorphicEncryptor(HomomorphicEncryptor)
    #     """Simplified homomorphic encryption for demonstration"""

    #     def __init__(self, params: EncryptionParams):
    #         """Initialize simple homomorphic encryptor"""
            super().__init__(params)

    #         # Simple parameters
    self.modulus = self._get_modulus()
    self.key = None

    #     def _get_modulus(self) -> int:
    #         """Get modulus based on security level"""
    #         if self.params.security_level == SecurityLevel.LOW:
    #             return 2**31 - 1  # Large prime
    #         elif self.params.security_level == SecurityLevel.MEDIUM:
    #             return 2**61 - 1  # Larger prime
    #         elif self.params.security_level == SecurityLevel.HIGH:
    #             return 2**89 - 1  # Even larger prime
    #         else:  # VERY_HIGH
    #             return 2**127 - 1  # Very large prime

    #     async def generate_keys(self) -> bool:
    #         """Generate simple encryption keys"""
    #         try:
    #             # Generate random key
    self.key = math.subtract(np.random.randint(1, self.modulus, 1))

                # Create public key (in this simple scheme, same as private)
    self.public_key = self.key
    self.private_key = self.key

    #             logger.info(f"Generated simple homomorphic keys with modulus {self.modulus}")
    #             return True

    #         except Exception as e:
                logger.error(f"Failed to generate keys: {e}")
    #             return False

    #     async def encrypt(self, plaintext: Any) -> Ciphertext:
    #         """Encrypt plaintext using simple scheme"""
    #         try:
    start_time = time.time()

    #             # Convert plaintext to integer
    #             if isinstance(plaintext, (int, np.integer)):
    plaintext_int = int(plaintext)
    #             elif isinstance(plaintext, float):
                    # Scale float to integer (simplified)
    plaintext_int = math.multiply(int(plaintext, 1000))
    #             elif isinstance(plaintext, (list, np.ndarray)):
    #                 # Encrypt each element
    encrypted_elements = []
    #                 for element in plaintext:
    encrypted_element = await self.encrypt(element)
                        encrypted_elements.append(encrypted_element)

    #                 # Create ciphertext for array
    ciphertext = Ciphertext(
    scheme = self.params.scheme,
    data = encrypted_elements,
    metadata = {'type': 'array', 'length': len(plaintext)}
    #                 )
    #             else:
                    raise ValueError(f"Unsupported plaintext type: {type(plaintext)}")

    #             if not isinstance(plaintext, (list, np.ndarray)):
    # Simple encryption: c = math.add((m, r * mod) mod mod)
    #                 # where r is random noise
    noise = np.random.randint(1, 100)
    encrypted_value = math.add((plaintext_int, noise * self.modulus) % self.modulus)

    ciphertext = Ciphertext(
    scheme = self.params.scheme,
    data = encrypted_value,
    metadata = {'type': 'scalar', 'noise': noise}
    #                 )

    #             # Update performance metrics
    encryption_time = math.subtract(time.time(), start_time)
    ciphertext.encryption_time = encryption_time
    ciphertext.size_bytes = len(str(ciphertext.data).encode()

    self._encryption_count + = 1
    self._total_encryption_time + = encryption_time

    #             return ciphertext

    #         except Exception as e:
                logger.error(f"Encryption failed: {e}")
    #             raise

    #     async def decrypt(self, ciphertext: Ciphertext) -> Any:
    #         """Decrypt ciphertext"""
    #         try:
    start_time = time.time()

    #             if ciphertext.metadata.get('type') == 'array':
    #                 # Decrypt array element by element
    decrypted_elements = []
    #                 for element_ciphertext in ciphertext.data:
    element = await self.decrypt(element_ciphertext)
                        decrypted_elements.append(element)

    result = decrypted_elements
    #             else:
    # Simple decryption: m = math.multiply((c - r, mod) mod mod)
    #                 # In this simplified scheme, we don't store the noise separately
    #                 # In a real implementation, noise would be handled properly

    #                 if isinstance(ciphertext.data, (int, np.integer)):
    decrypted_value = ciphertext.data % self.modulus

    #                     # Convert back to original type if needed
    #                     if ciphertext.metadata.get('original_type') == 'float':
    result = math.divide(decrypted_value, 1000.0)
    #                     else:
    result = decrypted_value
    #                 else:
    result = ciphertext.data

    #             # Update performance metrics
    decryption_time = math.subtract(time.time(), start_time)
    self._decryption_count + = 1
    self._total_decryption_time + = decryption_time

    #             return result

    #         except Exception as e:
                logger.error(f"Decryption failed: {e}")
    #             raise

    #     async def evaluate(self, operation: OperationType,
    #                      operands: List[Ciphertext]) -> EvaluationResult:
    #         """Perform homomorphic operation"""
    #         try:
    start_time = time.time()

    #             if len(operands) < 1:
                    raise ValueError("At least one operand required")

    #             # Handle array operations
    #             if operands[0].metadata.get('type') == 'array':
    result = await self._evaluate_array_operation(operation, operands)
    #             else:
    result = await self._evaluate_scalar_operation(operation, operands)

    #             # Update performance metrics
    evaluation_time = math.subtract(time.time(), start_time)
    self._evaluation_count + = 1
    self._total_evaluation_time + = evaluation_time

                return EvaluationResult(
    ciphertext = result,
    operation = operation,
    #                 operands=[c.ciphertext_id for c in operands],
    evaluation_time = evaluation_time,
    noise_budget = 0.5  # Simplified
    #             )

    #         except Exception as e:
                logger.error(f"Homomorphic evaluation failed: {e}")
    #             raise

    #     async def _evaluate_scalar_operation(self, operation: OperationType,
    #                                     operands: List[Ciphertext]) -> Ciphertext:
    #         """Evaluate operation on scalar operands"""
    #         if operation == OperationType.ADDITION:
                # Homomorphic addition: (c1 + c2) mod mod
    #             if len(operands) != 2:
                    raise ValueError("Addition requires exactly 2 operands")

    result_value = math.add((operands[0].data, operands[1].data) % self.modulus)

    #         elif operation == OperationType.MULTIPLICATION:
                # Homomorphic multiplication: (c1 * c2) mod mod
    #             if len(operands) != 2:
                    raise ValueError("Multiplication requires exactly 2 operands")

    result_value = math.multiply((operands[0].data, operands[1].data) % self.modulus)

    #         elif operation == OperationType.SCALAR_ADD:
                # Scalar addition: (c + k) mod mod
    #             if len(operands) != 2:
                    raise ValueError("Scalar addition requires exactly 2 operands")

    #             scalar = operands[1].data if not isinstance(operands[1], Ciphertext) else operands[1]
    result_value = math.add((operands[0].data, scalar) % self.modulus)

    #         elif operation == OperationType.SCALAR_MUL:
                # Scalar multiplication: (c * k) mod mod
    #             if len(operands) != 2:
                    raise ValueError("Scalar multiplication requires exactly 2 operands")

    #             scalar = operands[1].data if not isinstance(operands[1], Ciphertext) else operands[1]
    result_value = math.multiply((operands[0].data, scalar) % self.modulus)

    #         elif operation == OperationType.NEGATION:
                # Negation: (-c) mod mod
    #             if len(operands) != 1:
                    raise ValueError("Negation requires exactly 1 operand")

    result_value = math.subtract((, operands[0].data) % self.modulus)

    #         else:
                raise ValueError(f"Unsupported operation: {operation}")

            return Ciphertext(
    scheme = self.params.scheme,
    data = result_value,
    metadata = {'type': 'scalar', 'operation': operation.value}
    #         )

    #     async def _evaluate_array_operation(self, operation: OperationType,
    #                                    operands: List[Ciphertext]) -> Ciphertext:
    #         """Evaluate operation on array operands"""
    #         # Get array lengths
    #         lengths = [len(c.data) if isinstance(c.data, list) else 1 for c in operands]
    max_length = max(lengths)

    #         # Pad shorter arrays
    padded_operands = []
    #         for i, operand in enumerate(operands):
    #             if isinstance(operand.data, list):
    padded_data = math.add(operand.data, [operand.data[-1]] * (max_length - lengths[i]))
    #             else:
    padded_data = math.multiply([operand.data], max_length)

                padded_operands.append(Ciphertext(
    scheme = operand.scheme,
    data = padded_data,
    metadata = operand.metadata
    #             ))

    #         # Perform element-wise operation
    result_array = []
    #         for i in range(max_length):
    element_operands = [Ciphertext(
    scheme = op.scheme,
    #                 data=op.data[i] if isinstance(op.data, list) else op.data,
    metadata = op.metadata
    #             ) for op in padded_operands]

    element_result = await self._evaluate_scalar_operation(operation, element_operands)
                result_array.append(element_result.data)

            return Ciphertext(
    scheme = self.params.scheme,
    data = result_array,
    metadata = {'type': 'array', 'length': max_length, 'operation': operation.value}
    #         )


class PaillierEncryptor(HomomorphicEncryptor)
    #     """Paillier homomorphic encryption implementation"""

    #     def __init__(self, params: EncryptionParams):
    #         """Initialize Paillier encryptor"""
            super().__init__(params)

    #         # Paillier-specific parameters
    self.p = None
    self.q = None
    self.n = None
    self.lambda_n = None
    self.g = None
    self.mu = None

    #     async def generate_keys(self) -> bool:
    #         """Generate Paillier keys"""
    #         try:
    #             # Generate two large prime numbers
    #             # In a real implementation, use proper prime generation
    #             if self.params.security_level == SecurityLevel.LOW:
    bit_length = 512
    #             elif self.params.security_level == SecurityLevel.MEDIUM:
    bit_length = 768
    #             elif self.params.security_level == SecurityLevel.HIGH:
    bit_length = 1024
    #             else:  # VERY_HIGH
    bit_length = 1536

    #             # Simplified prime generation (use small primes for demo)
    #             self.p = 61  # Small prime for demo
    #             self.q = 53  # Small prime for demo

    #             # Calculate Paillier parameters
    self.n = math.multiply(self.p, self.q)
    self.lambda_n = math.multiply((self.p - 1), (self.q - 1))

    # Choose g (typically g = math.add(n, 1))
    self.g = math.add(self.n, 1)

    #             # Calculate μ
    self.mu = self._mod_inverse(self.lambda_n, self.n)

    #             # Set public and private keys
    self.public_key = (self.n, self.g)
    self.private_key = (self.lambda_n, self.mu)

    #             logger.info(f"Generated Paillier keys with n={self.n}")
    #             return True

    #         except Exception as e:
                logger.error(f"Failed to generate Paillier keys: {e}")
    #             return False

    #     def _mod_inverse(self, a: int, m: int) -> int:
    #         """Calculate modular inverse using extended Euclidean algorithm"""
    #         # Simplified implementation
    #         for x in range(1, m):
    #             if (a * x) % m == 1:
    #                 return x
    #         return 1  # Should not reach here for valid inputs

    #     async def encrypt(self, plaintext: Any) -> Ciphertext:
    #         """Encrypt using Paillier scheme"""
    #         try:
    start_time = time.time()

    #             # Convert plaintext to integer
    #             if isinstance(plaintext, (int, np.integer)):
    m = int(plaintext)
    #             elif isinstance(plaintext, float):
    m = math.multiply(int(plaintext, 1000)  # Scale float)
    #             else:
                    raise ValueError(f"Unsupported plaintext type: {type(plaintext)}")

    n, g = self.public_key

    #             # Generate random r
    r = math.subtract(np.random.randint(1, n, 1))

    # Paillier encryption: c = math.multiply(g^m, r^n mod n^2)
    n_squared = math.multiply(n, n)
    c = math.multiply((pow(g, m, n_squared), pow(r, n, n_squared)) % n_squared)

    ciphertext = Ciphertext(
    scheme = EncryptionScheme.PAILLIER,
    data = c,
    metadata = {
    #                     'type': 'scalar',
    #                     'n_squared': n_squared,
    #                     'r': r
    #                 }
    #             )

    #             # Update performance metrics
    encryption_time = math.subtract(time.time(), start_time)
    ciphertext.encryption_time = encryption_time
    ciphertext.size_bytes = len(str(c).encode()

    self._encryption_count + = 1
    self._total_encryption_time + = encryption_time

    #             return ciphertext

    #         except Exception as e:
                logger.error(f"Paillier encryption failed: {e}")
    #             raise

    #     async def decrypt(self, ciphertext: Ciphertext) -> Any:
    #         """Decrypt Paillier ciphertext"""
    #         try:
    start_time = time.time()

    lambda_n, mu = self.private_key
    n_squared = ciphertext.metadata.get('n_squared', self.n * self.n)
    c = ciphertext.data

    # Paillier decryption: m = math.multiply(L(c^λ mod n^2), μ mod n)
    # where L(x) = math.subtract((x, 1) / n)
    c_lambda = pow(c, lambda_n, n_squared)
    l = math.subtract((c_lambda, 1) // self.n)
    m = math.multiply((l, mu) % self.n)

    #             # Update performance metrics
    decryption_time = math.subtract(time.time(), start_time)
    self._decryption_count + = 1
    self._total_decryption_time + = decryption_time

    #             return m

    #         except Exception as e:
                logger.error(f"Paillier decryption failed: {e}")
    #             raise

    #     async def evaluate(self, operation: OperationType,
    #                      operands: List[Ciphertext]) -> EvaluationResult:
    #         """Perform Paillier homomorphic operation"""
    #         try:
    start_time = time.time()

    #             if operation == OperationType.ADDITION:
    #                 # Paillier supports homomorphic addition
    #                 if len(operands) != 2:
                        raise ValueError("Addition requires exactly 2 operands")

    n_squared = operands[0].metadata.get('n_squared', self.n * self.n)
    c1 = operands[0].data
    c2 = operands[1].data

    # Homomorphic addition: c_add = math.multiply(c1, c2 mod n^2)
    c_result = math.multiply((c1, c2) % n_squared)

    result = Ciphertext(
    scheme = EncryptionScheme.PAILLIER,
    data = c_result,
    metadata = {
    #                         'type': 'scalar',
    #                         'operation': 'addition',
    #                         'n_squared': n_squared
    #                     }
    #                 )

    #             elif operation == OperationType.SCALAR_ADD:
    # Scalar addition: c_add = math.multiply(c, g^k mod n^2)
    #                 if len(operands) != 2:
                        raise ValueError("Scalar addition requires exactly 2 operands")

    n_squared = operands[0].metadata.get('n_squared', self.n * self.n)
    c = operands[0].data
    #                 k = operands[1].data if not isinstance(operands[1], Ciphertext) else operands[1]
    n, g = self.public_key

    g_k = pow(g, k, n_squared)
    c_result = math.multiply((c, g_k) % n_squared)

    result = Ciphertext(
    scheme = EncryptionScheme.PAILLIER,
    data = c_result,
    metadata = {
    #                         'type': 'scalar',
    #                         'operation': 'scalar_add',
    #                         'n_squared': n_squared
    #                     }
    #                 )

    #             else:
    #                 raise ValueError(f"Unsupported operation for Paillier: {operation}")

    #             # Update performance metrics
    evaluation_time = math.subtract(time.time(), start_time)
    self._evaluation_count + = 1
    self._total_evaluation_time + = evaluation_time

                return EvaluationResult(
    ciphertext = result,
    operation = operation,
    #                 operands=[c.ciphertext_id for c in operands],
    evaluation_time = evaluation_time,
    noise_budget = 0.7  # Paillier noise estimate
    #             )

    #         except Exception as e:
                logger.error(f"Paillier evaluation failed: {e}")
    #             raise


class HomomorphicEncryptionManager
    #     """Manager for homomorphic encryption operations"""

    #     def __init__(self):
    #         """Initialize homomorphic encryption manager"""
    self.encryptors: Dict[str, HomomorphicEncryptor] = {}
    self.default_params = EncryptionParams()

    #         # Statistics
    self._stats = {
    #             'encryptors_created': 0,
    #             'encryptions_performed': 0,
    #             'decryptions_performed': 0,
    #             'evaluations_performed': 0,
    #             'total_encryption_time': 0.0,
    #             'total_decryption_time': 0.0,
    #             'total_evaluation_time': 0.0
    #         }

    #     def create_encryptor(self, encryptor_id: str,
    params: Optional[EncryptionParams] = math.subtract(None), > bool:)
    #         """
    #         Create a new homomorphic encryptor

    #         Args:
    #             encryptor_id: Unique identifier for the encryptor
    #             params: Encryption parameters

    #         Returns:
    #             True if successfully created
    #         """
    #         try:
    #             if params is None:
    params = self.default_params

    #             if params.scheme == EncryptionScheme.SIMPLE:
    encryptor = SimpleHomomorphicEncryptor(params)
    #             elif params.scheme == EncryptionScheme.PAILLIER:
    encryptor = PaillierEncryptor(params)
    #             else:
                    logger.error(f"Unsupported encryption scheme: {params.scheme}")
    #                 return False

    #             # Generate keys
                asyncio.create_task(encryptor.generate_keys())

    self.encryptors[encryptor_id] = encryptor
    self._stats['encryptors_created'] + = 1

                logger.info(f"Created homomorphic encryptor: {encryptor_id}")
    #             return True

    #         except Exception as e:
                logger.error(f"Failed to create encryptor {encryptor_id}: {e}")
    #             return False

    #     async def encrypt_data(self, encryptor_id: str, plaintext: Any) -> Optional[Ciphertext]:
    #         """
    #         Encrypt data using specified encryptor

    #         Args:
    #             encryptor_id: ID of encryptor to use
    #             plaintext: Data to encrypt

    #         Returns:
    #             Encrypted ciphertext
    #         """
    #         if encryptor_id not in self.encryptors:
                logger.error(f"Encryptor {encryptor_id} not found")
    #             return None

    encryptor = self.encryptors[encryptor_id]
    ciphertext = await encryptor.encrypt(plaintext)

    #         if ciphertext:
    self._stats['encryptions_performed'] + = 1
    self._stats['total_encryption_time'] + = ciphertext.encryption_time

    #         return ciphertext

    #     async def decrypt_data(self, encryptor_id: str, ciphertext: Ciphertext) -> Any:
    #         """
    #         Decrypt data using specified encryptor

    #         Args:
    #             encryptor_id: ID of encryptor to use
    #             ciphertext: Ciphertext to decrypt

    #         Returns:
    #             Decrypted plaintext
    #         """
    #         if encryptor_id not in self.encryptors:
                logger.error(f"Encryptor {encryptor_id} not found")
    #             return None

    encryptor = self.encryptors[encryptor_id]

    start_time = time.time()
    plaintext = await encryptor.decrypt(ciphertext)
    decryption_time = math.subtract(time.time(), start_time)

    #         if plaintext is not None:
    self._stats['decryptions_performed'] + = 1
    self._stats['total_decryption_time'] + = decryption_time

    #         return plaintext

    #     async def evaluate_operation(self, encryptor_id: str, operation: OperationType,
    #                             operands: List[Ciphertext]) -> Optional[EvaluationResult]:
    #         """
    #         Perform homomorphic operation

    #         Args:
    #             encryptor_id: ID of encryptor to use
    #             operation: Operation to perform
    #             operands: Encrypted operands

    #         Returns:
    #             Evaluation result
    #         """
    #         if encryptor_id not in self.encryptors:
                logger.error(f"Encryptor {encryptor_id} not found")
    #             return None

    encryptor = self.encryptors[encryptor_id]

    start_time = time.time()
    result = await encryptor.evaluate(operation, operands)
    evaluation_time = math.subtract(time.time(), start_time)

    #         if result:
    self._stats['evaluations_performed'] + = 1
    self._stats['total_evaluation_time'] + = evaluation_time

    #         return result

    #     def get_encryptor(self, encryptor_id: str) -> Optional[HomomorphicEncryptor]:
    #         """Get an encryptor by ID"""
            return self.encryptors.get(encryptor_id)

    #     def get_all_encryptors(self) -> Dict[str, HomomorphicEncryptor]:
    #         """Get all encryptors"""
            return self.encryptors.copy()

    #     def delete_encryptor(self, encryptor_id: str) -> bool:
    #         """Delete an encryptor"""
    #         if encryptor_id in self.encryptors:
    #             del self.encryptors[encryptor_id]
                logger.info(f"Deleted encryptor: {encryptor_id}")
    #             return True
    #         return False

    #     def get_statistics(self) -> Dict[str, Any]:
    #         """Get manager statistics"""
    stats = self._stats.copy()

    #         # Add encryptor statistics
    stats['total_encryptors'] = len(self.encryptors)
    stats['encryptors_by_scheme'] = {}

    #         for encryptor_id, encryptor in self.encryptors.items():
    scheme = encryptor.params.scheme.value
    stats['encryptors_by_scheme'][scheme] = stats['encryptors_by_scheme'].get(scheme, 0) + 1

    #         # Add average times
    #         if self._stats['encryptions_performed'] > 0:
    stats['avg_encryption_time'] = self._stats['total_encryption_time'] / self._stats['encryptions_performed']

    #         if self._stats['decryptions_performed'] > 0:
    stats['avg_decryption_time'] = self._stats['total_decryption_time'] / self._stats['decryptions_performed']

    #         if self._stats['evaluations_performed'] > 0:
    stats['avg_evaluation_time'] = self._stats['total_evaluation_time'] / self._stats['evaluations_performed']

    #         return stats


# Convenience functions for common operations
# async def homomorphic_add(manager: HomomorphicEncryptionManager,
#                         encryptor_id: str,
#                         operand1: Any, operand2: Any) -> Optional[Any]:
#     """
#     Perform homomorphic addition

#     Args:
#         manager: Homomorphic encryption manager
#         encryptor_id: ID of encryptor to use
#         operand1: First operand
#         operand2: Second operand

#     Returns:
#         Decrypted result
#     """
#     # Encrypt operands
ciphertext1 = await manager.encrypt_data(encryptor_id, operand1)
ciphertext2 = await manager.encrypt_data(encryptor_id, operand2)

#     if not ciphertext1 or not ciphertext2:
#         return None

#     # Perform addition
result = await manager.evaluate_operation(encryptor_id, OperationType.ADDITION, [ciphertext1, ciphertext2])

#     if not result or not result.ciphertext:
#         return None

#     # Decrypt result
    return await manager.decrypt_data(encryptor_id, result.ciphertext)


# async def homomorphic_multiply(manager: HomomorphicEncryptionManager,
#                           encryptor_id: str,
#                           operand1: Any, operand2: Any) -> Optional[Any]:
#     """
#     Perform homomorphic multiplication

#     Args:
#         manager: Homomorphic encryption manager
#         encryptor_id: ID of encryptor to use
#         operand1: First operand
#         operand2: Second operand

#     Returns:
#         Decrypted result
#     """
#     # Encrypt operands
ciphertext1 = await manager.encrypt_data(encryptor_id, operand1)
ciphertext2 = await manager.encrypt_data(encryptor_id, operand2)

#     if not ciphertext1 or not ciphertext2:
#         return None

#     # Perform multiplication
result = await manager.evaluate_operation(encryptor_id, OperationType.MULTIPLICATION, [ciphertext1, ciphertext2])

#     if not result or not result.ciphertext:
#         return None

#     # Decrypt result
    return await manager.decrypt_data(encryptor_id, result.ciphertext)