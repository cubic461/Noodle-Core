# Converted from Python to NoodleCore
# Original file: src

# """
# Mobile API Authentication Module
# --------------------------------

# Handles device registration, JWT token management, and authentication
# for the NoodleControl mobile app.
# """

import hashlib
import hmac
import json
import logging
import os
import time
import uuid
import datetime.datetime
import typing.Any

import jwt
import cryptography.hazmat.primitives.hashes
import cryptography.hazmat.primitives.asymmetric.rsa
import cryptography.hazmat.primitives.kdf.pbkdf2.PBKDF2HMAC
import flask.request

import .errors.(
#     AuthenticationError,
#     AuthorizationError,
#     DeviceRegistrationError,
#     TokenExpiredError,
#     ValidationError,
# )

logger = logging.getLogger(__name__)

# JWT Configuration
JWT_ALGORITHM = "RS256"
JWT_EXPIRATION_DELTA = timedelta(hours=2)  # As per security constraints
REFRESH_TOKEN_EXPIRATION_DELTA = timedelta(days=30)

# Device fingerprinting
DEVICE_FINGERPRINT_SALT = os.environ.get("NOODLE_DEVICE_FINGERPRINT_SALT", "default_salt").encode()


class AuthManager
    #     """
    #     Manages authentication for mobile API clients including device registration
    #     and JWT token management.
    #     """

    #     def __init__(self, db_connection=None, redis_client=None):""
    #         Initialize AuthManager.

    #         Args:
    #             db_connection: Database connection for storing auth data
    #             redis_client: Redis client for token caching and session management
    #         """
    self.db = db_connection
    self.redis = redis_client
    self._private_key = None
    self._public_key = None
            self._load_or_generate_keys()

    #     def _load_or_generate_keys(self):
    #         """Load RSA keys from environment or generate new ones."""
    private_key_path = os.environ.get("NOODLE_JWT_PRIVATE_KEY_PATH")
    public_key_path = os.environ.get("NOODLE_JWT_PUBLIC_KEY_PATH")

    #         if private_key_path and public_key_path and os.path.exists(private_key_path) and os.path.exists(public_key_path):
    #             try:
    #                 with open(private_key_path, "rb") as f:
    self._private_key = serialization.load_pem_private_key(
                            f.read(),
    password = None
    #                     )

    #                 with open(public_key_path, "rb") as f:
    self._public_key = serialization.load_pem_public_key(f.read())

                    logger.info("Loaded RSA keys from files")
    #                 return
    #             except Exception as e:
                    logger.error(f"Failed to load RSA keys: {e}")

    #         # Generate new keys if loading fails
            self._generate_keys()

    #     def _generate_keys(self):
    #         """Generate new RSA key pair for JWT signing."""
    #         try:
    self._private_key = rsa.generate_private_key(
    public_exponent = 65537,
    key_size = 2048
    #             )
    self._public_key = self._private_key.public_key()

    #             # Store keys for future use
    private_key_path = os.environ.get("NOODLE_JWT_PRIVATE_KEY_PATH", "jwt_private.pem")
    public_key_path = os.environ.get("NOODLE_JWT_PUBLIC_KEY_PATH", "jwt_public.pem")

    #             with open(private_key_path, "wb") as f:
                    f.write(self._private_key.private_bytes(
    encoding = serialization.Encoding.PEM,
    format = serialization.PrivateFormat.PKCS8,
    encryption_algorithm = serialization.NoEncryption()
    #                 ))

    #             with open(public_key_path, "wb") as f:
                    f.write(self._public_key.public_bytes(
    encoding = serialization.Encoding.PEM,
    format = serialization.PublicFormat.SubjectPublicKeyInfo
    #                 ))

    #             logger.info("Generated new RSA key pair for JWT")
    #         except Exception as e:
                logger.error(f"Failed to generate RSA keys: {e}")
                raise DeviceRegistrationError(f"Key generation failed: {e}")

    #     def generate_device_fingerprint(self, device_info: Dict[str, Any]) -str):
    #         """
    #         Generate a unique device fingerprint from device information.

    #         Args:
    #             device_info: Dictionary containing device information

    #         Returns:
    #             Unique device fingerprint string
    #         """
    #         try:
    #             # Extract relevant device properties
    fingerprint_data = {
                    "deviceId": device_info.get("deviceId", ""),
                    "deviceName": device_info.get("deviceName", ""),
                    "platform": device_info.get("platform", ""),
                    "osVersion": device_info.get("osVersion", ""),
                    "appVersion": device_info.get("appVersion", ""),
    #             }

    #             # Create fingerprint using HMAC-SHA256
    fingerprint_string = json.dumps(fingerprint_data, sort_keys=True)
    fingerprint = hmac.new(
    #                 DEVICE_FINGERPRINT_SALT,
                    fingerprint_string.encode(),
    #                 hashlib.sha256
                ).hexdigest()

    #             return fingerprint
    #         except Exception as e:
                logger.error(f"Failed to generate device fingerprint: {e}")
                raise ValidationError(f"Invalid device information: {e}")

    #     def register_device(self, device_info: Dict[str, Any]) -Dict[str, Any]):
    #         """
    #         Register a new mobile device.

    #         Args:
    #             device_info: Device information including ID, name, platform, etc.

    #         Returns:
    #             Dictionary containing device registration result
    #         """
    #         try:
    #             # Validate device information
    required_fields = ["deviceId", "deviceName", "platform"]
    #             for field in required_fields:
    #                 if not device_info.get(field):
                        raise ValidationError(f"Missing required field: {field}")

    #             # Generate device fingerprint
    device_fingerprint = self.generate_device_fingerprint(device_info)

    #             # Check if device already exists
    device_id = device_info.get("deviceId")
    #             if self._device_exists(device_id):
                    logger.warning(f"Device already registered: {device_id}")
    #                 # Update existing device record
                    self._update_device(device_id, device_info, device_fingerprint)
    #             else:
    #                 # Register new device
                    self._create_device(device_id, device_info, device_fingerprint)

    #             # Generate tokens for the device
    access_token, refresh_token = self._generate_tokens(device_id, device_fingerprint)

    #             return {
    #                 "deviceId": device_id,
    #                 "deviceFingerprint": device_fingerprint,
    #                 "accessToken": access_token,
    #                 "refreshToken": refresh_token,
                    "expiresIn": int(JWT_EXPIRATION_DELTA.total_seconds()),
                    "registeredAt": datetime.now().isoformat(),
    #             }
    #         except Exception as e:
                logger.error(f"Device registration failed: {e}")
                raise DeviceRegistrationError(f"Failed to register device: {e}")

    #     def authenticate_device(self, token: str) -Dict[str, Any]):
    #         """
    #         Authenticate a device using JWT token.

    #         Args:
    #             token: JWT access token

    #         Returns:
    #             Dictionary containing device authentication information
    #         """
    #         try:
    #             # Decode and verify token
    payload = self._decode_token(token)

    #             # Check if token is expired
    #             if payload.get("exp", 0) < time.time():
                    raise TokenExpiredError("Token has expired")

    #             # Get device information
    device_id = payload.get("sub")
    device_fingerprint = payload.get("device_fingerprint")

    #             if not device_id or not device_fingerprint:
                    raise AuthenticationError("Invalid token payload")

    #             # Verify device exists and is active
    device_info = self._get_device(device_id)
    #             if not device_info:
                    raise AuthenticationError("Device not found")

    #             if device_info.get("device_fingerprint") != device_fingerprint:
                    raise AuthenticationError("Device fingerprint mismatch")

    #             if not device_info.get("is_active", True):
                    raise AuthorizationError("Device is inactive")

    #             return {
    #                 "deviceId": device_id,
    #                 "deviceFingerprint": device_fingerprint,
    #                 "deviceInfo": device_info,
                    "authenticatedAt": datetime.now().isoformat(),
    #             }
    #         except jwt.InvalidTokenError as e:
                logger.error(f"Invalid token: {e}")
                raise AuthenticationError(f"Invalid token: {e}")
    #         except Exception as e:
                logger.error(f"Authentication failed: {e}")
                raise AuthenticationError(f"Authentication failed: {e}")

    #     def refresh_token(self, refresh_token: str) -Dict[str, Any]):
    #         """
    #         Refresh an access token using a refresh token.

    #         Args:
    #             refresh_token: JWT refresh token

    #         Returns:
    #             Dictionary containing new access token
    #         """
    #         try:
    #             # Decode and verify refresh token
    payload = self._decode_token(refresh_token)

    #             # Check if token type is refresh
    #             if payload.get("type") != "refresh":
                    raise AuthenticationError("Invalid token type")

    #             # Check if token is expired
    #             if payload.get("exp", 0) < time.time():
                    raise TokenExpiredError("Refresh token has expired")

    #             # Get device information
    device_id = payload.get("sub")
    device_fingerprint = payload.get("device_fingerprint")

    #             if not device_id or not device_fingerprint:
                    raise AuthenticationError("Invalid refresh token payload")

    #             # Verify device exists and is active
    device_info = self._get_device(device_id)
    #             if not device_info:
                    raise AuthenticationError("Device not found")

    #             if device_info.get("device_fingerprint") != device_fingerprint:
                    raise AuthenticationError("Device fingerprint mismatch")

    #             if not device_info.get("is_active", True):
                    raise AuthorizationError("Device is inactive")

    #             # Generate new tokens
    new_access_token, new_refresh_token = self._generate_tokens(device_id, device_fingerprint)

    #             return {
    #                 "accessToken": new_access_token,
    #                 "refreshToken": new_refresh_token,
                    "expiresIn": int(JWT_EXPIRATION_DELTA.total_seconds()),
                    "refreshedAt": datetime.now().isoformat(),
    #             }
    #         except jwt.InvalidTokenError as e:
                logger.error(f"Invalid refresh token: {e}")
                raise AuthenticationError(f"Invalid refresh token: {e}")
    #         except Exception as e:
                logger.error(f"Token refresh failed: {e}")
                raise AuthenticationError(f"Token refresh failed: {e}")

    #     def revoke_device(self, device_id: str) -bool):
    #         """
    #         Revoke device access by deactivating it.

    #         Args:
    #             device_id: ID of the device to revoke

    #         Returns:
    #             True if device was successfully revoked
    #         """
    #         try:
    #             # Update device status to inactive
    success = self._deactivate_device(device_id)

    #             if success:
    #                 # Invalidate all tokens for this device in Redis
    #                 if self.redis:
    pattern = f"token:{device_id}:*"
    tokens = self.redis.keys(pattern)
    #                     if tokens:
                            self.redis.delete(*tokens)
    #                         logger.info(f"Invalidated {len(tokens)} tokens for device {device_id}")

                    logger.info(f"Device {device_id} revoked successfully")
    #                 return True
    #             else:
                    logger.warning(f"Failed to revoke device {device_id}")
    #                 return False
    #         except Exception as e:
                logger.error(f"Device revocation failed: {e}")
    #             return False

    #     def _device_exists(self, device_id: str) -bool):
    #         """Check if device exists in database."""
    #         if not self.db:
    #             # For development without database, return False
    #             return False

    #         try:
    cursor = self.db.cursor()
                cursor.execute(
    "SELECT 1 FROM mobile_devices WHERE device_id = %s",
                    (device_id,)
    #             )
                return cursor.fetchone() is not None
    #         except Exception as e:
                logger.error(f"Failed to check device existence: {e}")
    #             return False

    #     def _create_device(self, device_id: str, device_info: Dict[str, Any], device_fingerprint: str):
    #         """Create new device record in database."""
    #         if not self.db:
    #             # For development without database, just log
                logger.info(f"Created device {device_id} (no database)")
    #             return

    #         try:
    cursor = self.db.cursor()
                cursor.execute(
    #                 """
    #                 INSERT INTO mobile_devices
                    (device_id, device_name, platform, os_version, app_version,
    #                  device_fingerprint, is_active, created_at, updated_at)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
    #                 """,
                    (
    #                     device_id,
                        device_info.get("deviceName"),
                        device_info.get("platform"),
                        device_info.get("osVersion"),
                        device_info.get("appVersion"),
    #                     device_fingerprint,
    #                     True,
                        datetime.now(),
                        datetime.now(),
    #                 )
    #             )
                self.db.commit()
    #         except Exception as e:
                logger.error(f"Failed to create device: {e}")
                raise DeviceRegistrationError(f"Failed to create device record: {e}")

    #     def _update_device(self, device_id: str, device_info: Dict[str, Any], device_fingerprint: str):
    #         """Update existing device record in database."""
    #         if not self.db:
    #             # For development without database, just log
                logger.info(f"Updated device {device_id} (no database)")
    #             return

    #         try:
    cursor = self.db.cursor()
                cursor.execute(
    #                 """
    #                 UPDATE mobile_devices
    SET device_name = %s, platform = %s, os_version = %s,
    app_version = %s, device_fingerprint = %s,
    is_active = %s, updated_at = %s
    WHERE device_id = %s
    #                 """,
                    (
                        device_info.get("deviceName"),
                        device_info.get("platform"),
                        device_info.get("osVersion"),
                        device_info.get("appVersion"),
    #                     device_fingerprint,
    #                     True,
                        datetime.now(),
    #                     device_id,
    #                 )
    #             )
                self.db.commit()
    #         except Exception as e:
                logger.error(f"Failed to update device: {e}")
                raise DeviceRegistrationError(f"Failed to update device record: {e}")

    #     def _get_device(self, device_id: str) -Optional[Dict[str, Any]]):
    #         """Get device information from database."""
    #         if not self.db:
    #             # For development without database, return mock data
    #             return {
    #                 "device_id": device_id,
    #                 "device_name": "Mock Device",
    #                 "platform": "mock",
    #                 "is_active": True,
    #                 "device_fingerprint": "mock_fingerprint"
    #             }

    #         try:
    cursor = self.db.cursor(dictionary=True)
                cursor.execute(
    "SELECT * FROM mobile_devices WHERE device_id = %s",
                    (device_id,)
    #             )
                return cursor.fetchone()
    #         except Exception as e:
                logger.error(f"Failed to get device: {e}")
    #             return None

    #     def _deactivate_device(self, device_id: str) -bool):
    #         """Deactivate device in database."""
    #         if not self.db:
    #             # For development without database, just log
                logger.info(f"Deactivated device {device_id} (no database)")
    #             return True

    #         try:
    cursor = self.db.cursor()
                cursor.execute(
    "UPDATE mobile_devices SET is_active = %s, updated_at = %s WHERE device_id = %s",
                    (False, datetime.now(), device_id)
    #             )
                self.db.commit()
    #             return cursor.rowcount 0
    #         except Exception as e):
                logger.error(f"Failed to deactivate device: {e}")
    #             return False

    #     def _generate_tokens(self, device_id: str, device_fingerprint: str) -Tuple[str, str]):
    #         """Generate access and refresh tokens for a device."""
    now = int(time.time())

    #         # Access token payload
    access_payload = {
    #             "sub": device_id,
    #             "device_fingerprint": device_fingerprint,
    #             "iat": now,
                "exp": now + int(JWT_EXPIRATION_DELTA.total_seconds()),
    #             "type": "access",
                "jti": str(uuid.uuid4()),
    #         }

    #         # Refresh token payload
    refresh_payload = {
    #             "sub": device_id,
    #             "device_fingerprint": device_fingerprint,
    #             "iat": now,
                "exp": now + int(REFRESH_TOKEN_EXPIRATION_DELTA.total_seconds()),
    #             "type": "refresh",
                "jti": str(uuid.uuid4()),
    #         }

    #         # Generate tokens
    access_token = jwt.encode(access_payload, self._private_key, algorithm=JWT_ALGORITHM)
    refresh_token = jwt.encode(refresh_payload, self._private_key, algorithm=JWT_ALGORITHM)

    #         # Cache tokens in Redis if available
    #         if self.redis:
    token_key = f"token:{device_id}:{access_payload['jti']}"
                self.redis.setex(
    #                 token_key,
    #                 JWT_EXPIRATION_DELTA,
                    json.dumps({"type": "access", "device_id": device_id})
    #             )

    refresh_key = f"token:{device_id}:{refresh_payload['jti']}"
                self.redis.setex(
    #                 refresh_key,
    #                 REFRESH_TOKEN_EXPIRATION_DELTA,
                    json.dumps({"type": "refresh", "device_id": device_id})
    #             )

    #         return access_token, refresh_token

    #     def _decode_token(self, token: str) -Dict[str, Any]):
    #         """Decode and verify JWT token."""
    #         try:
    payload = jwt.decode(
    #                 token,
    #                 self._public_key,
    algorithms = [JWT_ALGORITHM]
    #             )
    #             return payload
    #         except jwt.ExpiredSignatureError:
                raise TokenExpiredError("Token has expired")
    #         except jwt.InvalidTokenError as e:
                raise AuthenticationError(f"Invalid token: {e}")