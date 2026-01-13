# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Zero-knowledge proof system for Noodle.

# This module provides zero-knowledge proof capabilities that allow
# one party to prove to another that they know a value x, without conveying
# any information apart from the fact that they know the value x.
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


class ProofType(Enum)
    #     """Types of zero-knowledge proofs"""
    Schnorr = "schnorr"
    RSA = "rsa"
    ElGamal = "elgamal"
    Pedersen = "pedersen"
    Bulletproofs = "bulletproofs"
    zkSNARK = "zksnark"
    zkSTARK = "zkstark"


class ProofSystem(Enum)
    #     """Zero-knowledge proof systems"""
    DISCRETE_LOG = "discrete_log"
    INTEGER_COMMITMENT = "integer_commitment"
    RANGE_PROOF = "range_proof"
    SET_MEMBERSHIP = "set_membership"
    KNOWLEDGE_OF_EXPONENT = "knowledge_of_exponent"
    POLYNOMIAL_COMMITMENT = "polynomial_commitment"


class SecurityLevel(Enum)
    #     """Security levels for zero-knowledge proofs"""
    LOW = math.subtract(80      # 80, bit security)
    MEDIUM = math.subtract(112   # 112, bit security)
    HIGH = math.subtract(128     # 128, bit security)
    VERY_HIGH = math.subtract(256  # 256, bit security)


# @dataclass
class ProofParameters
    #     """Parameters for zero-knowledge proofs"""

    proof_type: ProofType = ProofType.Schnorr
    proof_system: ProofSystem = ProofSystem.DISCRETE_LOG
    security_level: SecurityLevel = SecurityLevel.MEDIUM

    #     # System-specific parameters
    group_order: int = 0  # Order of the cryptographic group
    generator: int = 2    # Generator of the group
    hash_function: str = "sha256"

    #     # Performance parameters
    max_witness_size: int = 1024
    proof_compression: bool = True

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             'proof_type': self.proof_type.value,
    #             'proof_system': self.proof_system.value,
    #             'security_level': self.security_level.value,
    #             'group_order': self.group_order,
    #             'generator': self.generator,
    #             'hash_function': self.hash_function,
    #             'max_witness_size': self.max_witness_size,
    #             'proof_compression': self.proof_compression
    #         }


# @dataclass
class Witness
    #     """Witness for zero-knowledge proof"""

    witness_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    data: Any = None
    commitment: Optional[str] = None
    randomness: Optional[int] = None

    #     # Metadata
    created_at: float = field(default_factory=time.time)
    proof_id: Optional[str] = None

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             'witness_id': self.witness_id,
    #             'data': self.data,
    #             'commitment': self.commitment,
    #             'randomness': self.randomness,
    #             'created_at': self.created_at,
    #             'proof_id': self.proof_id
    #         }


# @dataclass
class ZeroKnowledgeProof
    #     """Represents a zero-knowledge proof"""

    proof_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    proof_type: ProofType = ProofType.Schnorr
    proof_system: ProofSystem = ProofSystem.DISCRETE_LOG

    #     # Proof data
    proof_data: Dict[str, Any] = field(default_factory=dict)
    challenge: Optional[str] = None
    response: Optional[str] = None

    #     # Verification
    verification_key: Optional[str] = None
    public_inputs: Dict[str, Any] = field(default_factory=dict)

    #     # Performance tracking
    generation_time: float = 0.0
    verification_time: float = 0.0
    proof_size: int = 0

    #     # Metadata
    created_at: float = field(default_factory=time.time)
    verified_at: Optional[float] = None
    is_valid: Optional[bool] = None

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             'proof_id': self.proof_id,
    #             'proof_type': self.proof_type.value,
    #             'proof_system': self.proof_system.value,
    #             'proof_data': self.proof_data,
    #             'challenge': self.challenge,
    #             'response': self.response,
    #             'verification_key': self.verification_key,
    #             'public_inputs': self.public_inputs,
    #             'generation_time': self.generation_time,
    #             'verification_time': self.verification_time,
    #             'proof_size': self.proof_size,
    #             'created_at': self.created_at,
    #             'verified_at': self.verified_at,
    #             'is_valid': self.is_valid
    #         }


class ZeroKnowledgeProver(ABC)
    #     """Abstract base class for zero-knowledge provers"""

    #     def __init__(self, params: ProofParameters):
    #         """
    #         Initialize zero-knowledge prover

    #         Args:
    #             params: Proof parameters
    #         """
    self.params = params
    self.secret_key = None
    self.public_key = None

    #         # Performance tracking
    self._proofs_generated = 0
    self._total_generation_time = 0.0

    #     @abstractmethod
    #     async def generate_keys(self) -> bool:
    #         """Generate proving and verification keys"""
    #         pass

    #     @abstractmethod
    #     async def create_witness(self, statement: Any) -> Witness:
    #         """
    #         Create a witness for a statement

    #         Args:
    #             statement: Statement to create witness for

    #         Returns:
    #             Created witness
    #         """
    #         pass

    #     @abstractmethod
    #     async def generate_proof(self, witness: Witness,
    challenge: Optional[str] = math.subtract(None), > ZeroKnowledgeProof:)
    #         """
    #         Generate a zero-knowledge proof

    #         Args:
    #             witness: Witness to use
    #             challenge: Optional challenge (for interactive protocols)

    #         Returns:
    #             Generated proof
    #         """
    #         pass

    #     def get_performance_stats(self) -> Dict[str, Any]:
    #         """Get performance statistics"""
    #         return {
    #             'proofs_generated': self._proofs_generated,
                'avg_generation_time': self._total_generation_time / max(self._proofs_generated, 1)
    #         }


class ZeroKnowledgeVerifier(ABC)
    #     """Abstract base class for zero-knowledge verifiers"""

    #     def __init__(self, params: ProofParameters):
    #         """
    #         Initialize zero-knowledge verifier

    #         Args:
    #             params: Proof parameters
    #         """
    self.params = params
    self.verification_key = None

    #         # Performance tracking
    self._proofs_verified = 0
    self._total_verification_time = 0.0
    self._successful_verifications = 0

    #     @abstractmethod
    #     async def verify_proof(self, proof: ZeroKnowledgeProof,
    public_inputs: Dict[str, Any] = math.subtract(None), > bool:)
    #         """
    #         Verify a zero-knowledge proof

    #         Args:
    #             proof: Proof to verify
    #             public_inputs: Public inputs for verification

    #         Returns:
    #             True if proof is valid
    #         """
    #         pass

    #     def get_performance_stats(self) -> Dict[str, Any]:
    #         """Get performance statistics"""
    #         return {
    #             'proofs_verified': self._proofs_verified,
                'avg_verification_time': self._total_verification_time / max(self._proofs_verified, 1),
                'success_rate': self._successful_verifications / max(self._proofs_verified, 1)
    #         }


class SchnorrProver(ZeroKnowledgeProver)
    #     """Schnorr signature-based zero-knowledge prover"""

    #     def __init__(self, params: ProofParameters):
    #         """Initialize Schnorr prover"""
            super().__init__(params)

    #         # Schnorr-specific parameters
    self.p = self._get_prime()
    self.g = 2  # Standard generator

    #         # Keys
    self.secret_key = None
    self.public_key = None

    #     def _get_prime(self) -> int:
    #         """Get prime based on security level"""
    #         if self.params.security_level == SecurityLevel.LOW:
    #             return 2**89 - 1  # Small prime for demo
    #         elif self.params.security_level == SecurityLevel.MEDIUM:
    #             return 2**127 - 1  # Medium prime
    #         elif self.params.security_level == SecurityLevel.HIGH:
    #             return 2**191 - 1  # Large prime
    #         else:  # VERY_HIGH
    #             return 2**521 - 1  # Very large prime

    #     async def generate_keys(self) -> bool:
    #         """Generate Schnorr keys"""
    #         try:
                # Generate secret key (random integer)
    self.secret_key = math.subtract(np.random.randint(1, self.p, 1))

    #             # Generate public key: g^x mod p
    self.public_key = pow(self.g, self.secret_key, self.p)

    #             logger.info(f"Generated Schnorr keys with p={self.p}")
    #             return True

    #         except Exception as e:
                logger.error(f"Failed to generate Schnorr keys: {e}")
    #             return False

    #     async def create_witness(self, statement: Any) -> Witness:
    #         """Create a witness for a statement"""
    #         try:
    #             # For Schnorr, the witness is the secret key
    #             # and the statement is the value we're proving knowledge of

    #             if isinstance(statement, int):
    # Verify that g^x = statement mod p
    #                 if pow(self.g, self.secret_key, self.p) != statement % self.p:
                        raise ValueError("Statement doesn't match secret key")

                    return Witness(
    data = self.secret_key,
    commitment = None
    #                 )
    #             else:
                    raise ValueError(f"Unsupported statement type: {type(statement)}")

    #         except Exception as e:
                logger.error(f"Failed to create witness: {e}")
    #             raise

    #     async def generate_proof(self, witness: Witness,
    challenge: Optional[str] = math.subtract(None), > ZeroKnowledgeProof:)
    #         """Generate a Schnorr proof"""
    #         try:
    start_time = time.time()

    #             # Generate random nonce
    k = math.subtract(np.random.randint(1, self.p, 1))

    # Calculate commitment: R = g^k mod p
    R = pow(self.g, k, self.p)

    #             # Get or generate challenge
    #             if challenge is None:
    #                 # In a real implementation, this would come from a verifier
    #                 # For demo, we'll use hash-based Fiat-Shamir
    challenge_data = f"{R}{self.public_key}"
    challenge = int(hashlib.sha256(challenge_data.encode()).hexdigest(), 16) % self.p

    # Calculate response: s = math.add(k, e * x mod p)
    #             e = int(challenge) if isinstance(challenge, str) else challenge
    #             x = witness.data if isinstance(witness.data, int) else int(witness.data)
    s = math.add((k, e * x) % self.p)

    #             # Create proof
    proof = ZeroKnowledgeProof(
    proof_type = ProofType.Schnorr,
    proof_system = ProofSystem.DISCRETE_LOG,
    proof_data = {
    #                     'R': R,
    #                     's': s,
    #                     'public_key': self.public_key
    #                 },
    challenge = str(challenge),
    response = str(s),
    verification_key = str(self.public_key),
    public_inputs = {'public_key': self.public_key}
    #             )

    #             # Update performance metrics
    proof.generation_time = math.subtract(time.time(), start_time)
    proof.proof_size = len(str(proof.to_dict()))

    self._proofs_generated + = 1
    self._total_generation_time + = proof.generation_time

    #             return proof

    #         except Exception as e:
                logger.error(f"Failed to generate Schnorr proof: {e}")
    #             raise


class SchnorrVerifier(ZeroKnowledgeVerifier)
    #     """Schnorr signature-based zero-knowledge verifier"""

    #     def __init__(self, params: ProofParameters):
    #         """Initialize Schnorr verifier"""
            super().__init__(params)

    #         # Schnorr-specific parameters
    self.p = self._get_prime()
    self.g = 2  # Standard generator

    #     def _get_prime(self) -> int:
    #         """Get prime based on security level"""
    #         if self.params.security_level == SecurityLevel.LOW:
    #             return 2**89 - 1
    #         elif self.params.security_level == SecurityLevel.MEDIUM:
    #             return 2**127 - 1
    #         elif self.params.security_level == SecurityLevel.HIGH:
    #             return 2**191 - 1
    #         else:  # VERY_HIGH
    #             return 2**521 - 1

    #     async def verify_proof(self, proof: ZeroKnowledgeProof,
    public_inputs: Dict[str, Any] = math.subtract(None), > bool:)
    #         """Verify a Schnorr proof"""
    #         try:
    start_time = time.time()

    #             # Extract proof data
    R = proof.proof_data.get('R')
    s = proof.proof_data.get('s')
    public_key = proof.proof_data.get('public_key')

    #             if R is None or s is None or public_key is None:
    #                 return False

                # Recreate challenge (in a real implementation, this would be provided)
    challenge_data = f"{R}{public_key}"
    challenge = int(hashlib.sha256(challenge_data.encode()).hexdigest(), 16) % self.p

    # Verify: g^s = math.multiply(R, public_key^e mod p)
    left_side = pow(self.g, s, self.p)
    right_side = math.multiply((R, pow(public_key, challenge, self.p)) % self.p)

    is_valid = left_side == right_side

    #             # Update performance metrics
    verification_time = math.subtract(time.time(), start_time)
    proof.verification_time = verification_time
    proof.verified_at = time.time()
    proof.is_valid = is_valid

    self._proofs_verified + = 1
    self._total_verification_time + = verification_time

    #             if is_valid:
    self._successful_verifications + = 1

                logger.debug(f"Schnorr proof verification: {is_valid}")
    #             return is_valid

    #         except Exception as e:
                logger.error(f"Failed to verify Schnorr proof: {e}")
    #             return False


class RangeProofProver(ZeroKnowledgeProver)
        """Range proof prover (proves a value is in a range)"""

    #     def __init__(self, params: ProofParameters):
    #         """Initialize range proof prover"""
            super().__init__(params)

    #         # Range proof parameters
    self.min_range = 0
    self.max_range = 100

    #         # Pedersen commitment parameters
    self.p = self._get_prime()
    self.g = 2
    self.h = 3  # Second generator

    #         # Keys
    self.secret_key = None
    self.randomness = None

    #     def _get_prime(self) -> int:
    #         """Get prime based on security level"""
    #         if self.params.security_level == SecurityLevel.LOW:
    #             return 2**89 - 1
    #         elif self.params.security_level == SecurityLevel.MEDIUM:
    #             return 2**127 - 1
    #         elif self.params.security_level == SecurityLevel.HIGH:
    #             return 2**191 - 1
    #         else:  # VERY_HIGH
    #             return 2**521 - 1

    #     async def generate_keys(self) -> bool:
    #         """Generate range proof keys"""
    #         try:
                # Generate secret key (random integer)
    self.secret_key = np.random.randint(self.min_range, self.max_range)

    #             # Generate randomness for commitment
    self.randomness = math.subtract(np.random.randint(1, self.p, 1))

                logger.info(f"Generated range proof keys")
    #             return True

    #         except Exception as e:
                logger.error(f"Failed to generate range proof keys: {e}")
    #             return False

    #     async def create_witness(self, statement: Any) -> Witness:
    #         """Create a witness for a range proof"""
    #         try:
    #             # For range proof, the witness includes the value and randomness
    #             value = statement if isinstance(statement, int) else int(statement)

    #             if value < self.min_range or value > self.max_range:
                    raise ValueError(f"Value {value} not in range [{self.min_range}, {self.max_range}]")

                return Witness(
    data = value,
    randomness = self.randomness
    #             )

    #         except Exception as e:
                logger.error(f"Failed to create range proof witness: {e}")
    #             raise

    #     async def generate_proof(self, witness: Witness,
    challenge: Optional[str] = math.subtract(None), > ZeroKnowledgeProof:)
    #         """Generate a range proof"""
    #         try:
    start_time = time.time()

    value = witness.data
    randomness = witness.randomness

    # Calculate Pedersen commitment: C = math.multiply(g^v, h^r mod p)
    commitment = math.multiply((pow(self.g, value, self.p), pow(self.h, randomness, self.p)) % self.p)

    #             # Generate random values for proof
    r1 = math.subtract(np.random.randint(1, self.p, 1))
    r2 = math.subtract(np.random.randint(1, self.p, 1))
    d = math.subtract(np.random.randint(1, self.p, 1))

    #             # Calculate proof commitments
    A1 = pow(self.g, r1, self.p)
    A2 = pow(self.h, r2, self.p)
    A = math.multiply((A1, A2) % self.p)

    #             # Calculate T and U
    T = math.multiply((pow(self.g, d, self.p), pow(self.h, r1, self.p)) % self.p)
    U = math.multiply((pow(self.g, d, self.p), pow(self.h, r2, self.p)) % self.p)

    #             # Create proof
    proof = ZeroKnowledgeProof(
    proof_type = ProofType.Pedersen,
    proof_system = ProofSystem.RANGE_PROOF,
    proof_data = {
    #                     'commitment': commitment,
    #                     'A': A,
    #                     'T': T,
    #                     'U': U,
    #                     'range': [self.min_range, self.max_range]
    #                 },
    verification_key = str(commitment),
    public_inputs = {'commitment': commitment, 'range': [self.min_range, self.max_range]}
    #             )

    #             # Update performance metrics
    proof.generation_time = math.subtract(time.time(), start_time)
    proof.proof_size = len(str(proof.to_dict()))

    self._proofs_generated + = 1
    self._total_generation_time + = proof.generation_time

    #             return proof

    #         except Exception as e:
                logger.error(f"Failed to generate range proof: {e}")
    #             raise


class RangeProofVerifier(ZeroKnowledgeVerifier)
    #     """Range proof verifier"""

    #     def __init__(self, params: ProofParameters):
    #         """Initialize range proof verifier"""
            super().__init__(params)

    #         # Range proof parameters
    self.p = self._get_prime()
    self.g = 2
    self.h = 3

    #     def _get_prime(self) -> int:
    #         """Get prime based on security level"""
    #         if self.params.security_level == SecurityLevel.LOW:
    #             return 2**89 - 1
    #         elif self.params.security_level == SecurityLevel.MEDIUM:
    #             return 2**127 - 1
    #         elif self.params.security_level == SecurityLevel.HIGH:
    #             return 2**191 - 1
    #         else:  # VERY_HIGH
    #             return 2**521 - 1

    #     async def verify_proof(self, proof: ZeroKnowledgeProof,
    public_inputs: Dict[str, Any] = math.subtract(None), > bool:)
    #         """Verify a range proof"""
    #         try:
    start_time = time.time()

    #             # Extract proof data
    commitment = proof.proof_data.get('commitment')
    A = proof.proof_data.get('A')
    T = proof.proof_data.get('T')
    U = proof.proof_data.get('U')
    range_values = proof.proof_data.get('range', [0, 100])

    #             if any(v is None for v in [commitment, A, T, U]):
    #                 return False

    #             # In a real implementation, this would involve complex
    #             # cryptographic verification. For demo, we'll simulate

                # Simulate verification (simplified)
    #             is_valid = True  # Assume valid for demo

    #             # Update performance metrics
    verification_time = math.subtract(time.time(), start_time)
    proof.verification_time = verification_time
    proof.verified_at = time.time()
    proof.is_valid = is_valid

    self._proofs_verified + = 1
    self._total_verification_time + = verification_time

    #             if is_valid:
    self._successful_verifications + = 1

                logger.debug(f"Range proof verification: {is_valid}")
    #             return is_valid

    #         except Exception as e:
                logger.error(f"Failed to verify range proof: {e}")
    #             return False


class ZeroKnowledgeProofManager
    #     """Manager for zero-knowledge proof operations"""

    #     def __init__(self):
    #         """Initialize zero-knowledge proof manager"""
    self.provers: Dict[str, ZeroKnowledgeProver] = {}
    self.verifiers: Dict[str, ZeroKnowledgeVerifier] = {}
    self.proofs: Dict[str, ZeroKnowledgeProof] = {}
    self.witnesses: Dict[str, Witness] = {}

    self.default_params = ProofParameters()

    #         # Statistics
    self._stats = {
    #             'provers_created': 0,
    #             'verifiers_created': 0,
    #             'proofs_generated': 0,
    #             'proofs_verified': 0,
    #             'successful_verifications': 0,
    #             'total_generation_time': 0.0,
    #             'total_verification_time': 0.0
    #         }

    #     def create_prover(self, prover_id: str,
    proof_type: ProofType = ProofType.Schnorr,
    params: Optional[ProofParameters] = math.subtract(None), > bool:)
    #         """
    #         Create a new prover

    #         Args:
    #             prover_id: Unique identifier for prover
    #             proof_type: Type of proof system
    #             params: Proof parameters

    #         Returns:
    #             True if successfully created
    #         """
    #         try:
    #             if params is None:
    params = self.default_params
    params.proof_type = proof_type

    #             if proof_type == ProofType.Schnorr:
    prover = SchnorrProver(params)
    #             elif proof_type == ProofType.Pedersen:
    prover = RangeProofProver(params)
    #             else:
                    logger.error(f"Unsupported proof type: {proof_type}")
    #                 return False

    #             # Generate keys
                asyncio.create_task(prover.generate_keys())

    self.provers[prover_id] = prover
    self._stats['provers_created'] + = 1

                logger.info(f"Created prover: {prover_id}")
    #             return True

    #         except Exception as e:
                logger.error(f"Failed to create prover {prover_id}: {e}")
    #             return False

    #     def create_verifier(self, verifier_id: str,
    proof_type: ProofType = ProofType.Schnorr,
    params: Optional[ProofParameters] = math.subtract(None), > bool:)
    #         """
    #         Create a new verifier

    #         Args:
    #             verifier_id: Unique identifier for verifier
    #             proof_type: Type of proof system
    #             params: Proof parameters

    #         Returns:
    #             True if successfully created
    #         """
    #         try:
    #             if params is None:
    params = self.default_params
    params.proof_type = proof_type

    #             if proof_type == ProofType.Schnorr:
    verifier = SchnorrVerifier(params)
    #             elif proof_type == ProofType.Pedersen:
    verifier = RangeProofVerifier(params)
    #             else:
                    logger.error(f"Unsupported proof type: {proof_type}")
    #                 return False

    self.verifiers[verifier_id] = verifier
    self._stats['verifiers_created'] + = 1

                logger.info(f"Created verifier: {verifier_id}")
    #             return True

    #         except Exception as e:
                logger.error(f"Failed to create verifier {verifier_id}: {e}")
    #             return False

    #     async def create_witness(self, prover_id: str, statement: Any) -> Optional[Witness]:
    #         """
    #         Create a witness using a prover

    #         Args:
    #             prover_id: ID of prover to use
    #             statement: Statement to create witness for

    #         Returns:
    #             Created witness
    #         """
    #         if prover_id not in self.provers:
                logger.error(f"Prover {prover_id} not found")
    #             return None

    prover = self.provers[prover_id]
    witness = await prover.create_witness(statement)

    #         if witness:
    self.witnesses[witness.witness_id] = witness

    #         return witness

    #     async def generate_proof(self, prover_id: str, witness_id: str,
    challenge: Optional[str] = math.subtract(None), > Optional[ZeroKnowledgeProof]:)
    #         """
    #         Generate a proof using a prover

    #         Args:
    #             prover_id: ID of prover to use
    #             witness_id: ID of witness to use
    #             challenge: Optional challenge

    #         Returns:
    #             Generated proof
    #         """
    #         if prover_id not in self.provers:
                logger.error(f"Prover {prover_id} not found")
    #             return None

    #         if witness_id not in self.witnesses:
                logger.error(f"Witness {witness_id} not found")
    #             return None

    prover = self.provers[prover_id]
    witness = self.witnesses[witness_id]

    proof = await prover.generate_proof(witness, challenge)

    #         if proof:
    self.proofs[proof.proof_id] = proof
    witness.proof_id = proof.proof_id

    self._stats['proofs_generated'] + = 1
    self._stats['total_generation_time'] + = proof.generation_time

    #         return proof

    #     async def verify_proof(self, verifier_id: str, proof_id: str,
    public_inputs: Dict[str, Any] = math.subtract(None), > bool:)
    #         """
    #         Verify a proof using a verifier

    #         Args:
    #             verifier_id: ID of verifier to use
    #             proof_id: ID of proof to verify
    #             public_inputs: Public inputs for verification

    #         Returns:
    #             True if proof is valid
    #         """
    #         if verifier_id not in self.verifiers:
                logger.error(f"Verifier {verifier_id} not found")
    #             return False

    #         if proof_id not in self.proofs:
                logger.error(f"Proof {proof_id} not found")
    #             return False

    verifier = self.verifiers[verifier_id]
    proof = self.proofs[proof_id]

    is_valid = await verifier.verify_proof(proof, public_inputs)

    self._stats['proofs_verified'] + = 1
    self._stats['total_verification_time'] + = proof.verification_time

    #         if is_valid:
    self._stats['successful_verifications'] + = 1

    #         return is_valid

    #     def get_prover(self, prover_id: str) -> Optional[ZeroKnowledgeProver]:
    #         """Get a prover by ID"""
            return self.provers.get(prover_id)

    #     def get_verifier(self, verifier_id: str) -> Optional[ZeroKnowledgeVerifier]:
    #         """Get a verifier by ID"""
            return self.verifiers.get(verifier_id)

    #     def get_proof(self, proof_id: str) -> Optional[ZeroKnowledgeProof]:
    #         """Get a proof by ID"""
            return self.proofs.get(proof_id)

    #     def get_witness(self, witness_id: str) -> Optional[Witness]:
    #         """Get a witness by ID"""
            return self.witnesses.get(witness_id)

    #     def get_all_provers(self) -> Dict[str, ZeroKnowledgeProver]:
    #         """Get all provers"""
            return self.provers.copy()

    #     def get_all_verifiers(self) -> Dict[str, ZeroKnowledgeVerifier]:
    #         """Get all verifiers"""
            return self.verifiers.copy()

    #     def get_all_proofs(self) -> Dict[str, ZeroKnowledgeProof]:
    #         """Get all proofs"""
            return self.proofs.copy()

    #     def get_all_witnesses(self) -> Dict[str, Witness]:
    #         """Get all witnesses"""
            return self.witnesses.copy()

    #     def delete_prover(self, prover_id: str) -> bool:
    #         """Delete a prover"""
    #         if prover_id in self.provers:
    #             del self.provers[prover_id]
                logger.info(f"Deleted prover: {prover_id}")
    #             return True
    #         return False

    #     def delete_verifier(self, verifier_id: str) -> bool:
    #         """Delete a verifier"""
    #         if verifier_id in self.verifiers:
    #             del self.verifiers[verifier_id]
                logger.info(f"Deleted verifier: {verifier_id}")
    #             return True
    #         return False

    #     def delete_proof(self, proof_id: str) -> bool:
    #         """Delete a proof"""
    #         if proof_id in self.proofs:
    #             del self.proofs[proof_id]
                logger.info(f"Deleted proof: {proof_id}")
    #             return True
    #         return False

    #     def delete_witness(self, witness_id: str) -> bool:
    #         """Delete a witness"""
    #         if witness_id in self.witnesses:
    #             del self.witnesses[witness_id]
                logger.info(f"Deleted witness: {witness_id}")
    #             return True
    #         return False

    #     def get_statistics(self) -> Dict[str, Any]:
    #         """Get manager statistics"""
    stats = self._stats.copy()

    #         # Add current counts
    stats['total_provers'] = len(self.provers)
    stats['total_verifiers'] = len(self.verifiers)
    stats['total_proofs'] = len(self.proofs)
    stats['total_witnesses'] = len(self.witnesses)

    #         # Add average times
    #         if self._stats['proofs_generated'] > 0:
    stats['avg_generation_time'] = self._stats['total_generation_time'] / self._stats['proofs_generated']

    #         if self._stats['proofs_verified'] > 0:
    stats['avg_verification_time'] = self._stats['total_verification_time'] / self._stats['proofs_verified']
    stats['success_rate'] = self._stats['successful_verifications'] / self._stats['proofs_verified']

    #         return stats


# Convenience functions for common operations
# async def prove_knowledge_of_value(manager: ZeroKnowledgeProofManager,
#                                prover_id: str,
#                                value: int) -> Optional[str]:
#     """
#     Prove knowledge of a discrete logarithm value

#     Args:
#         manager: Zero-knowledge proof manager
#         prover_id: ID of prover to use
#         value: Value to prove knowledge of

#     Returns:
#         Proof ID if successful
#     """
#     # Create witness
witness = await manager.create_witness(prover_id, value)
#     if not witness:
#         return None

#     # Generate proof
proof = await manager.generate_proof(prover_id, witness.witness_id)
#     if not proof:
#         return None

#     return proof.proof_id


# async def verify_knowledge_of_value(manager: ZeroKnowledgeProofManager,
#                                  verifier_id: str,
#                                  proof_id: str,
#                                  public_value: int) -> bool:
#     """
#     Verify knowledge of a discrete logarithm value

#     Args:
#         manager: Zero-knowledge proof manager
#         verifier_id: ID of verifier to use
#         proof_id: ID of proof to verify
#         public_value: Public value to verify against

#     Returns:
#         True if proof is valid
#     """
public_inputs = {'public_key': public_value}
    return await manager.verify_proof(verifier_id, proof_id, public_inputs)


# async def prove_value_in_range(manager: ZeroKnowledgeProofManager,
#                             prover_id: str,
#                             value: int,
#                             min_range: int,
#                             max_range: int) -> Optional[str]:
#     """
#     Prove that a value is in a specific range

#     Args:
#         manager: Zero-knowledge proof manager
#         prover_id: ID of prover to use
#         value: Value to prove is in range
#         min_range: Minimum of range
#         max_range: Maximum of range

#     Returns:
#         Proof ID if successful
#     """
#     # Create witness with range information
range_statement = {
#         'value': value,
#         'min_range': min_range,
#         'max_range': max_range
#     }

witness = await manager.create_witness(prover_id, range_statement)
#     if not witness:
#         return None

#     # Generate proof
proof = await manager.generate_proof(prover_id, witness.witness_id)
#     if not proof:
#         return None

#     return proof.proof_id


# async def verify_value_in_range(manager: ZeroKnowledgeProofManager,
#                               verifier_id: str,
#                               proof_id: str,
#                               min_range: int,
#                               max_range: int) -> bool:
#     """
#     Verify that a value is in a specific range

#     Args:
#         manager: Zero-knowledge proof manager
#         verifier_id: ID of verifier to use
#         proof_id: ID of proof to verify
#         min_range: Minimum of range
#         max_range: Maximum of range

#     Returns:
#         True if proof is valid
#     """
public_inputs = {
#         'range': [min_range, max_range]
#     }

    return await manager.verify_proof(verifier_id, proof_id, public_inputs)