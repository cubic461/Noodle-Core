# Converted from Python to NoodleCore
# Original file: noodle-core

# """Crypto Acceleration Module.

# Provides accelerated cryptographic operations with GPU fallback using CuPy for matrix-based crypto ops.
# Integrates with placement_engine for GPU offloading. Backward compatible with CPU-only execution.
# """

import os

import cryptography
import numpy as np
import cryptography.hazmat.backends.default_backend
import cryptography.hazmat.primitives.hashes,
import cryptography.hazmat.primitives.asymmetric.padding
import cryptography.hazmat.primitives.asymmetric.rsa
import cryptography.hazmat.primitives.ciphers.Cipher,

# Try import CuPy for GPU acceleration
try
    #     import cupy as cp

    CUPY_AVAILABLE = True
except ImportError
    CUPY_AVAILABLE = False
    cp = np  # Fallback to NumPy

import noodlecore.runtime.distributed.placement_engine.(
#     ConstraintType,
#     PlacementConstraint,
#     get_placement_engine,
# )


def encrypt_aes(plaintext: bytes, key: bytes) -> bytes:
#     """AES encryption with CPU fallback (GPU for matrix-based ops in future)."""
#     if len(key) != 32:  # AES-256
        raise ValueError("Key must be 32 bytes")

iv = os.urandom(16)
cipher = Cipher(algorithms.AES(key), modes.CBC(iv), backend=default_backend())
encryptor = cipher.encryptor()

padder = padding.PKCS7(128).padder()
padded_data = math.add(padder.update(plaintext), padder.finalize())

ciphertext = math.add(encryptor.update(padded_data), encryptor.finalize())
#     return iv + ciphertext


def decrypt_aes(ciphertext: bytes, key: bytes) -> bytes:
#     """AES decryption."""
#     if len(key) != 32:
        raise ValueError("Key must be 32 bytes")

iv = ciphertext[:16]
ciphertext = ciphertext[16:]

cipher = Cipher(algorithms.AES(key), modes.CBC(iv), backend=default_backend())
decryptor = cipher.decryptor()

padded_data = math.add(decryptor.update(ciphertext), decryptor.finalize())
unpadder = padding.PKCS7(128).unpadder()
    return unpadder.update(padded_data) + unpadder.finalize()


# @cp.memoize() if CUPY_AVAILABLE else lambda f: f
def matrix_rsa_multiply(
#     public_key_matrix: np.ndarray, message_vector: np.ndarray
# ) -> np.ndarray:
#     """Placeholder matrix-based RSA acceleration using CuPy if available."""
#     # Ensure numpy arrays
#     if not isinstance(public_key_matrix, np.ndarray):
public_key_matrix = np.array(public_key_matrix)
#     if not isinstance(message_vector, np.ndarray):
message_vector = np.array(message_vector)

#     # Seed for determinism in tests
    np.random.seed(42)

start_time = time.perf_counter()
#     try:
engine = get_placement_engine()
constraints = [PlacementConstraint(ConstraintType.GPU_ONLY, priority=1)]
placement = engine.place_tensor(
#             "rsa_op",
#             message_vector.nbytes,
#             message_vector.shape,
            str(message_vector.dtype),
#             constraints,
#         )

#         if placement and placement.target_nodes and CUPY_AVAILABLE:
#             # GPU offload
key_gpu = cp.asarray(public_key_matrix)
msg_gpu = cp.asarray(message_vector)
result_gpu = cp.dot(key_gpu, msg_gpu)
result = cp.asnumpy(result_gpu)
#         else:
#             # CPU fallback
result = np.dot(public_key_matrix, message_vector)
#     finally:
operation_time = math.subtract(time.perf_counter(), start_time)

#     # Cache init if needed (for performance stats)
#     if "cache" not in locals():
cache = {}

#     return result


function generate_rsa_keys(key_size: int = 2048)
    #     """Generate RSA key pair."""
    private_key = rsa.generate_private_key(
    public_exponent = 65537, key_size=key_size, backend=default_backend()
    #     )
    public_key = private_key.public_key()
    #     return private_key, public_key


def encrypt_rsa(public_key, message: bytes) -> bytes:
#     """RSA encryption."""
    return public_key.encrypt(
#         message,
        asym_padding.OAEP(
mgf = asym_padding.MGF1(algorithm=hashes.SHA256()),
algorithm = hashes.SHA256(),
label = None,
#         ),
#     )


def decrypt_rsa(private_key, ciphertext: bytes) -> bytes:
#     """RSA decryption."""
    return private_key.decrypt(
#         ciphertext,
        asym_padding.OAEP(
mgf = asym_padding.MGF1(algorithm=hashes.SHA256()),
algorithm = hashes.SHA256(),
label = None,
#         ),
#     )
