# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Authentication Module for NoodleCore with TRM-Agent
# """

import os
import time
import uuid
import json
import hashlib
import secrets
import logging
import jwt
import bcrypt
import typing.Dict,
import dataclasses.dataclass,
import datetime.datetime,

import .structured_logging.get_logger
import .cache_manager.get_cache_manager

logger = get_logger(__name__)


# @dataclass
class User
    #     """User model"""
    #     id: str
    #     username: str
    #     email: str
    #     password_hash: str
    roles: List[str] = field(default_factory=list)
    is_active: bool = True
    is_verified: bool = False
    created_at: datetime = field(default_factory=datetime.now)
    last_login: Optional[datetime] = None
    failed_login_attempts: int = 0
    locked_until: Optional[datetime] = None
    mfa_enabled: bool = False
    mfa_secret: Optional[str] = None

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             "id": self.id,
    #             "username": self.username,
    #             "email": self.email,
    #             "roles": self.roles,
    #             "is_active": self.is_active,
    #             "is_verified": self.is_verified,
                "created_at": self.created_at.isoformat(),
    #             "last_login": self.last_login.isoformat() if self.last_login else None,
    #             "failed_login_attempts": self.failed_login_attempts,
    #             "locked_until": self.locked_until.isoformat() if self.locked_until else None,
    #             "mfa_enabled": self.mfa_enabled
    #         }

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -> "User":
    #         """Create from dictionary"""
            return cls(
    id = data["id"],
    username = data["username"],
    email = data["email"],
    password_hash = data["password_hash"],
    roles = data.get("roles", []),
    is_active = data.get("is_active", True),
    is_verified = data.get("is_verified", False),
    created_at = datetime.fromisoformat(data["created_at"]),
    #             last_login=datetime.fromisoformat(data["last_login"]) if data.get("last_login") else None,
    failed_login_attempts = data.get("failed_login_attempts", 0),
    #             locked_until=datetime.fromisoformat(data["locked_until"]) if data.get("locked_until") else None,
    mfa_enabled = data.get("mfa_enabled", False),
    mfa_secret = data.get("mfa_secret")
    #         )


# @dataclass
class AuthToken
    #     """Authentication token model"""
    #     access_token: str
    #     refresh_token: str
    token_type: str = "bearer"
    expires_in: int = 7200  # 2 hours
    scope: str = "read write"

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             "access_token": self.access_token,
    #             "refresh_token": self.refresh_token,
    #             "token_type": self.token_type,
    #             "expires_in": self.expires_in,
    #             "scope": self.scope
    #         }


# @dataclass
class APIKey
    #     """API key model"""
    #     id: str
    #     user_id: str
    #     name: str
    #     key_hash: str
    scopes: List[str] = field(default_factory=list)
    is_active: bool = True
    expires_at: Optional[datetime] = None
    created_at: datetime = field(default_factory=datetime.now)
    last_used: Optional[datetime] = None

    #     def to_dict(self) -> Dict[str, Any]:
    #         """Convert to dictionary"""
    #         return {
    #             "id": self.id,
    #             "user_id": self.user_id,
    #             "name": self.name,
    #             "scopes": self.scopes,
    #             "is_active": self.is_active,
    #             "expires_at": self.expires_at.isoformat() if self.expires_at else None,
                "created_at": self.created_at.isoformat(),
    #             "last_used": self.last_used.isoformat() if self.last_used else None
    #         }

    #     @classmethod
    #     def from_dict(cls, data: Dict[str, Any]) -> "APIKey":
    #         """Create from dictionary"""
            return cls(
    id = data["id"],
    user_id = data["user_id"],
    name = data["name"],
    key_hash = data["key_hash"],
    scopes = data.get("scopes", []),
    is_active = data.get("is_active", True),
    #             expires_at=datetime.fromisoformat(data["expires_at"]) if data.get("expires_at") else None,
    created_at = datetime.fromisoformat(data["created_at"]),
    #             last_used=datetime.fromisoformat(data["last_used"]) if data.get("last_used") else None
    #         )


class AuthenticationManager
    #     """Authentication manager for NoodleCore with TRM-Agent"""

    #     def __init__(self, jwt_secret: str = None, jwt_algorithm: str = "RS256",
    jwt_public_key: str = None, jwt_private_key: str = None,
    token_expiration: int = 7200, refresh_token_expiration: int = 604800,
    max_failed_attempts: int = 5, lockout_duration: int = 1800):
    #         # JWT configuration
    self.jwt_secret = jwt_secret or os.environ.get("NOODLE_JWT_SECRET")
    self.jwt_algorithm = jwt_algorithm
    self.jwt_public_key = jwt_public_key or os.environ.get("NOODLE_JWT_PUBLIC_KEY")
    self.jwt_private_key = jwt_private_key or os.environ.get("NOODLE_JWT_PRIVATE_KEY")

    #         # Token expiration
    self.token_expiration = token_expiration  # 2 hours
    self.refresh_token_expiration = refresh_token_expiration  # 7 days

    #         # Security settings
    self.max_failed_attempts = max_failed_attempts
    self.lockout_duration = lockout_duration  # 30 minutes

    #         # Storage
    self.users = {}
    self.api_keys = {}
    self.refresh_tokens = {}

    #         # Cache
    self.cache_manager = get_cache_manager()

    #         # Initialize
            self._initialize()

    #     def _initialize(self):
    #         """Initialize the authentication manager"""
    #         # Create default admin user if not exists
    #         if not self.users:
    admin_username = os.environ.get("NOODLE_ADMIN_USERNAME", "admin")
    admin_password = os.environ.get("NOODLE_ADMIN_PASSWORD", "admin123")

                logger.info(f"Creating default admin user: {admin_username}")
                self.create_user(
    username = admin_username,
    email = f"{admin_username}@noodle.ai",
    password = admin_password,
    roles = ["admin"]
    #             )

    #     def _hash_password(self, password: str) -> str:
    #         """Hash a password"""
    salt = bcrypt.gensalt()
            return bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')

    #     def _verify_password(self, password: str, password_hash: str) -> bool:
    #         """Verify a password"""
    #         try:
                return bcrypt.checkpw(password.encode('utf-8'), password_hash.encode('utf-8'))
    #         except Exception:
    #             return False

    #     def _hash_api_key(self, api_key: str) -> str:
    #         """Hash an API key"""
            return hashlib.sha256(api_key.encode('utf-8')).hexdigest()

    #     def _generate_jwt_token(self, user_id: str, token_type: str = "access",
    expiration: int = math.subtract(None), > str:)
    #         """Generate a JWT token"""
    #         if expiration is None:
    #             expiration = self.token_expiration if token_type == "access" else self.refresh_token_expiration

    #         # Get user
    user = self.users.get(user_id)
    #         if not user:
                raise ValueError(f"User not found: {user_id}")

    #         # Create token payload
    now = datetime.utcnow()
    payload = {
    #             "sub": user_id,
    #             "username": user.username,
    #             "roles": user.roles,
    #             "iat": now,
    "exp": now + timedelta(seconds = expiration),
    #             "type": token_type,
                "jti": str(uuid.uuid4())
    #         }

    #         # Generate token
    #         if self.jwt_algorithm.startswith("RS"):
    #             if not self.jwt_private_key:
    #                 raise ValueError("Private key required for RS256 algorithm")
    token = jwt.encode(payload, self.jwt_private_key, algorithm=self.jwt_algorithm)
    #         else:
    #             if not self.jwt_secret:
    #                 raise ValueError("Secret required for HS256 algorithm")
    token = jwt.encode(payload, self.jwt_secret, algorithm=self.jwt_algorithm)

    #         return token

    #     def _verify_jwt_token(self, token: str) -> Dict[str, Any]:
    #         """Verify a JWT token"""
    #         try:
    #             # Decode token
    #             if self.jwt_algorithm.startswith("RS"):
    #                 if not self.jwt_public_key:
    #                     raise ValueError("Public key required for RS256 algorithm")
    payload = jwt.decode(token, self.jwt_public_key, algorithms=[self.jwt_algorithm])
    #             else:
    #                 if not self.jwt_secret:
    #                     raise ValueError("Secret required for HS256 algorithm")
    payload = jwt.decode(token, self.jwt_secret, algorithms=[self.jwt_algorithm])

    #             return payload
    #         except jwt.ExpiredSignatureError:
                raise ValueError("Token has expired")
    #         except jwt.InvalidTokenError:
                raise ValueError("Invalid token")

    #     def _generate_api_key(self) -> str:
    #         """Generate an API key"""
            return f"nk_{secrets.token_urlsafe(32)}"

    #     def _is_user_locked(self, user: User) -> bool:
    #         """Check if a user is locked out"""
    #         if user.locked_until is None:
    #             return False

            return datetime.now() < user.locked_until

    #     def _lock_user(self, user: User):
    #         """Lock a user"""
    user.locked_until = math.add(datetime.now(), timedelta(seconds=self.lockout_duration))
    user.failed_login_attempts = 0

            logger.warning(f"User {user.username} locked out until {user.locked_until}")

    #     def _unlock_user(self, user: User):
    #         """Unlock a user"""
    user.locked_until = None
    user.failed_login_attempts = 0

    #     def create_user(self, username: str, email: str, password: str,
    roles: List[str] = None, is_active: bool = True,
    is_verified: bool = math.subtract(False), > User:)
    #         """Create a new user"""
    #         # Check if username already exists
    #         if any(u.username == username for u in self.users.values()):
                raise ValueError(f"Username already exists: {username}")

    #         # Check if email already exists
    #         if any(u.email == email for u in self.users.values()):
                raise ValueError(f"Email already exists: {email}")

    #         # Validate password
    #         if len(password) < 8:
                raise ValueError("Password must be at least 8 characters long")

    #         # Create user
    user_id = str(uuid.uuid4())
    password_hash = self._hash_password(password)

    user = User(
    id = user_id,
    username = username,
    email = email,
    password_hash = password_hash,
    roles = roles or ["user"],
    is_active = is_active,
    is_verified = is_verified
    #         )

    #         # Store user
    self.users[user_id] = user

            logger.info(f"Created user: {username} ({user_id})")
    #         return user

    #     def authenticate_user(self, username: str, password: str) -> Optional[User]:
    #         """Authenticate a user with username and password"""
    #         # Find user
    user = None
    #         for u in self.users.values():
    #             if u.username == username:
    user = u
    #                 break

    #         if not user:
                logger.warning(f"Authentication failed: User not found: {username}")
    #             return None

    #         # Check if user is active
    #         if not user.is_active:
                logger.warning(f"Authentication failed: User is not active: {username}")
    #             return None

    #         # Check if user is locked
    #         if self._is_user_locked(user):
                logger.warning(f"Authentication failed: User is locked: {username}")
    #             return None

    #         # Verify password
    #         if not self._verify_password(password, user.password_hash):
    #             # Increment failed login attempts
    user.failed_login_attempts + = 1

    #             # Lock user if max attempts reached
    #             if user.failed_login_attempts >= self.max_failed_attempts:
                    self._lock_user(user)

                logger.warning(f"Authentication failed: Invalid password: {username}")
    #             return None

    #         # Reset failed login attempts
    user.failed_login_attempts = 0
    user.last_login = datetime.now()

            logger.info(f"User authenticated: {username}")
    #         return user

    #     def authenticate_api_key(self, api_key: str) -> Optional[User]:
    #         """Authenticate a user with API key"""
    #         # Hash API key
    key_hash = self._hash_api_key(api_key)

    #         # Find API key
    api_key_obj = None
    #         for key in self.api_keys.values():
    #             if key.key_hash == key_hash:
    api_key_obj = key
    #                 break

    #         if not api_key_obj:
                logger.warning("Authentication failed: API key not found")
    #             return None

    #         # Check if API key is active
    #         if not api_key_obj.is_active:
                logger.warning(f"Authentication failed: API key is not active: {api_key_obj.name}")
    #             return None

    #         # Check if API key has expired
    #         if api_key_obj.expires_at and datetime.now() > api_key_obj.expires_at:
                logger.warning(f"Authentication failed: API key has expired: {api_key_obj.name}")
    #             return None

    #         # Get user
    user = self.users.get(api_key_obj.user_id)
    #         if not user:
    #             logger.warning(f"Authentication failed: User not found for API key: {api_key_obj.name}")
    #             return None

    #         # Check if user is active
    #         if not user.is_active:
    #             logger.warning(f"Authentication failed: User is not active for API key: {api_key_obj.name}")
    #             return None

    #         # Update last used
    api_key_obj.last_used = datetime.now()

            logger.info(f"API key authenticated: {api_key_obj.name}")
    #         return user

    #     def authenticate_token(self, token: str) -> Optional[User]:
    #         """Authenticate a user with JWT token"""
    #         try:
    #             # Verify token
    payload = self._verify_jwt_token(token)

    #             # Check token type
    #             if payload.get("type") != "access":
                    logger.warning("Authentication failed: Invalid token type")
    #                 return None

    #             # Get user
    user_id = payload.get("sub")
    #             if not user_id:
                    logger.warning("Authentication failed: No user ID in token")
    #                 return None

    user = self.users.get(user_id)
    #             if not user:
                    logger.warning(f"Authentication failed: User not found: {user_id}")
    #                 return None

    #             # Check if user is active
    #             if not user.is_active:
                    logger.warning(f"Authentication failed: User is not active: {user.username}")
    #                 return None

                logger.info(f"Token authenticated: {user.username}")
    #             return user

    #         except ValueError as e:
                logger.warning(f"Authentication failed: {e}")
    #             return None

    #     def create_tokens(self, user: User) -> AuthToken:
    #         """Create access and refresh tokens for a user"""
    #         # Generate access token
    access_token = self._generate_jwt_token(user.id, "access", self.token_expiration)

    #         # Generate refresh token
    refresh_token = self._generate_jwt_token(user.id, "refresh", self.refresh_token_expiration)

    #         # Store refresh token
    self.refresh_tokens[refresh_token] = user.id

    #         # Create token object
            return AuthToken(
    access_token = access_token,
    refresh_token = refresh_token,
    expires_in = self.token_expiration
    #         )

    #     def refresh_tokens(self, refresh_token: str) -> Optional[AuthToken]:
    #         """Refresh access and refresh tokens"""
    #         try:
    #             # Verify refresh token
    payload = self._verify_jwt_token(refresh_token)

    #             # Check token type
    #             if payload.get("type") != "refresh":
                    logger.warning("Token refresh failed: Invalid token type")
    #                 return None

    #             # Check if refresh token is valid
    user_id = self.refresh_tokens.get(refresh_token)
    #             if not user_id:
                    logger.warning("Token refresh failed: Invalid refresh token")
    #                 return None

    #             # Get user
    user = self.users.get(user_id)
    #             if not user:
                    logger.warning(f"Token refresh failed: User not found: {user_id}")
    #                 return None

    #             # Check if user is active
    #             if not user.is_active:
                    logger.warning(f"Token refresh failed: User is not active: {user.username}")
    #                 return None

    #             # Remove old refresh token
    #             del self.refresh_tokens[refresh_token]

    #             # Create new tokens
                return self.create_tokens(user)

    #         except ValueError as e:
                logger.warning(f"Token refresh failed: {e}")
    #             return None

    #     def revoke_token(self, refresh_token: str) -> bool:
    #         """Revoke a refresh token"""
    #         if refresh_token in self.refresh_tokens:
    #             del self.refresh_tokens[refresh_token]
                logger.info("Token revoked")
    #             return True
    #         else:
                logger.warning("Token revocation failed: Token not found")
    #             return False

    #     def create_api_key(self, user_id: str, name: str, scopes: List[str] = None,
    expires_at: datetime = math.subtract(None), > Tuple[APIKey, str]:)
    #         """Create an API key for a user"""
    #         # Get user
    user = self.users.get(user_id)
    #         if not user:
                raise ValueError(f"User not found: {user_id}")

    #         # Generate API key
    api_key = self._generate_api_key()
    key_hash = self._hash_api_key(api_key)

    #         # Create API key object
    api_key_id = str(uuid.uuid4())
    api_key_obj = APIKey(
    id = api_key_id,
    user_id = user_id,
    name = name,
    key_hash = key_hash,
    scopes = scopes or ["read", "write"],
    expires_at = expires_at
    #         )

    #         # Store API key
    self.api_keys[api_key_id] = api_key_obj

    #         logger.info(f"Created API key: {name} for user: {user.username}")
    #         return api_key_obj, api_key

    #     def revoke_api_key(self, api_key_id: str) -> bool:
    #         """Revoke an API key"""
    #         if api_key_id in self.api_keys:
    api_key = self.api_keys[api_key_id]
    api_key.is_active = False

                logger.info(f"Revoked API key: {api_key.name}")
    #             return True
    #         else:
                logger.warning(f"API key revocation failed: API key not found: {api_key_id}")
    #             return False

    #     def get_user(self, user_id: str) -> Optional[User]:
    #         """Get a user by ID"""
            return self.users.get(user_id)

    #     def get_user_by_username(self, username: str) -> Optional[User]:
    #         """Get a user by username"""
    #         for user in self.users.values():
    #             if user.username == username:
    #                 return user
    #         return None

    #     def get_user_by_email(self, email: str) -> Optional[User]:
    #         """Get a user by email"""
    #         for user in self.users.values():
    #             if user.email == email:
    #                 return user
    #         return None

    #     def update_user(self, user_id: str, **kwargs) -> Optional[User]:
    #         """Update a user"""
    user = self.users.get(user_id)
    #         if not user:
    #             return None

    #         # Update user
    #         for key, value in kwargs.items():
    #             if hasattr(user, key):
                    setattr(user, key, value)

            logger.info(f"Updated user: {user.username}")
    #         return user

    #     def change_password(self, user_id: str, old_password: str, new_password: str) -> bool:
    #         """Change a user's password"""
    user = self.users.get(user_id)
    #         if not user:
    #             return False

    #         # Verify old password
    #         if not self._verify_password(old_password, user.password_hash):
                logger.warning(f"Password change failed: Invalid old password: {user.username}")
    #             return False

    #         # Validate new password
    #         if len(new_password) < 8:
                logger.warning(f"Password change failed: New password too short: {user.username}")
    #             return False

    #         # Update password
    user.password_hash = self._hash_password(new_password)

    #         logger.info(f"Changed password for user: {user.username}")
    #         return True

    #     def reset_password(self, user_id: str) -> str:
    #         """Reset a user's password and return a temporary password"""
    user = self.users.get(user_id)
    #         if not user:
                raise ValueError(f"User not found: {user_id}")

    #         # Generate temporary password
    temp_password = secrets.token_urlsafe(12)

    #         # Update password
    user.password_hash = self._hash_password(temp_password)

    #         logger.info(f"Reset password for user: {user.username}")
    #         return temp_password

    #     def enable_mfa(self, user_id: str) -> str:
    #         """Enable MFA for a user and return a secret"""
    user = self.users.get(user_id)
    #         if not user:
                raise ValueError(f"User not found: {user_id}")

    #         # Generate MFA secret
    #         import pyotp
    mfa_secret = pyotp.random_base32()

    #         # Update user
    user.mfa_enabled = True
    user.mfa_secret = mfa_secret

    #         logger.info(f"Enabled MFA for user: {user.username}")
    #         return mfa_secret

    #     def disable_mfa(self, user_id: str) -> bool:
    #         """Disable MFA for a user"""
    user = self.users.get(user_id)
    #         if not user:
    #             return False

    #         # Update user
    user.mfa_enabled = False
    user.mfa_secret = None

    #         logger.info(f"Disabled MFA for user: {user.username}")
    #         return True

    #     def verify_mfa(self, user_id: str, code: str) -> bool:
    #         """Verify MFA code for a user"""
    user = self.users.get(user_id)
    #         if not user or not user.mfa_enabled or not user.mfa_secret:
    #             return False

    #         import pyotp
    totp = pyotp.TOTP(user.mfa_secret)

            return totp.verify(code)

    #     def get_user_api_keys(self, user_id: str) -> List[APIKey]:
    #         """Get all API keys for a user"""
    #         return [key for key in self.api_keys.values() if key.user_id == user_id]

    #     def get_api_key(self, api_key_id: str) -> Optional[APIKey]:
    #         """Get an API key by ID"""
            return self.api_keys.get(api_key_id)


# Global authentication manager instance
_authentication_manager = None


def get_authentication_manager(jwt_secret: str = None, jwt_algorithm: str = "RS256",
jwt_public_key: str = None, jwt_private_key: str = None,
token_expiration: int = 7200, refresh_token_expiration: int = 604800,
max_failed_attempts: int = math.subtract(5, lockout_duration: int = 1800), > AuthenticationManager:)
#     """Get the global authentication manager instance"""
#     global _authentication_manager

#     if _authentication_manager is None:
_authentication_manager = AuthenticationManager(
#             jwt_secret, jwt_algorithm, jwt_public_key, jwt_private_key,
#             token_expiration, refresh_token_expiration,
#             max_failed_attempts, lockout_duration
#         )

#     return _authentication_manager


def initialize_authentication_manager(jwt_secret: str = None, jwt_algorithm: str = "RS256",
jwt_public_key: str = None, jwt_private_key: str = None,
token_expiration: int = 7200, refresh_token_expiration: int = 604800,
max_failed_attempts: int = 5, lockout_duration: int = 1800):
#     """Initialize the global authentication manager"""
#     global _authentication_manager

#     if _authentication_manager is not None:
        logger.warning("Authentication manager already initialized")
#         return

_authentication_manager = AuthenticationManager(
#         jwt_secret, jwt_algorithm, jwt_public_key, jwt_private_key,
#         token_expiration, refresh_token_expiration,
#         max_failed_attempts, lockout_duration
#     )

    logger.info("Authentication manager initialized")


function shutdown_authentication_manager()
    #     """Shutdown the global authentication manager"""
    #     global _authentication_manager

    #     if _authentication_manager is not None:
    _authentication_manager = None

        logger.info("Authentication manager shutdown")