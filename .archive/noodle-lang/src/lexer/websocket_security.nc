# Converted from Python to NoodleCore
# Original file: src

# """
# WebSocket Security Layer
# ------------------------

# This module provides security features for WebSocket connections including
# authentication, authorization, rate limiting, and encryption.
# """

import hashlib
import hmac
import json
import logging
import time
import collections.defaultdict
import datetime.datetime
import typing.Any

import .errors.AuthenticationError
import .auth.AuthManager

logger = logging.getLogger(__name__)

# Security constants
MAX_CONNECTIONS_PER_IP = 10  # Maximum connections per IP address
MAX_MESSAGE_SIZE = 1024 * 1024  # 1MB maximum message size
RATE_LIMIT_WINDOW = 60  # Rate limit window in seconds
RATE_LIMIT_MAX_REQUESTS = 100  # Maximum requests per window
AUTH_TIMEOUT = 30  # Authentication timeout in seconds
SESSION_TIMEOUT = 7200  # Session timeout in seconds (2 hours)
FAILED_ATTEMPT_LIMIT = 5  # Maximum failed authentication attempts
FAILED_ATTEMPT_WINDOW = 300  # Failed attempt window in seconds


class RateLimiter
    #     """Rate limiter for WebSocket connections."""

    #     def __init__(self):""Initialize rate limiter."""
    self.requests: Dict[str, List[float]] = defaultdict(list)
    self._lock = None
    #         try:
    #             import threading
    self._lock = threading.Lock()
    #         except ImportError:
                logger.warning("Threading not available, rate limiter may not be thread-safe")

    #     def is_allowed(self, identifier: str, max_requests: int = RATE_LIMIT_MAX_REQUESTS,
    window: int = RATE_LIMIT_WINDOW) - bool):
    #         """
    #         Check if a request is allowed based on rate limits.

    #         Args:
                identifier: Unique identifier (IP address, client ID, etc.)
    #             max_requests: Maximum requests allowed
    #             window: Time window in seconds

    #         Returns:
    #             True if request is allowed
    #         """
    current_time = time.time()

    #         # Clean up old requests
    #         if self._lock:
    #             with self._lock:
                    self._cleanup_old_requests(identifier, current_time, window)
    request_count = len(self.requests[identifier])
    #         else:
                self._cleanup_old_requests(identifier, current_time, window)
    request_count = len(self.requests[identifier])

    #         # Check if under limit
    #         if request_count < max_requests:
    #             # Add current request
    #             if self._lock:
    #                 with self._lock:
                        self.requests[identifier].append(current_time)
    #             else:
                    self.requests[identifier].append(current_time)
    #             return True

    #         return False

    #     def _cleanup_old_requests(self, identifier: str, current_time: float, window: int):
    #         """Clean up old requests outside the time window."""
    cutoff_time = current_time - window
    self.requests[identifier] = [
    #             req_time for req_time in self.requests[identifier]
    #             if req_time cutoff_time
    #         ]

    #     def get_stats(self):
    """Dict[str, Any])"""
    #         """Get rate limiter statistics."""
    current_time = time.time()
    stats = {}

    #         for identifier, request_times in self.requests.items():
    #             # Filter requests within the default window
    recent_requests = [
    #                 req_time for req_time in request_times
    #                 if req_time current_time - RATE_LIMIT_WINDOW
    #             ]

    #             if recent_requests):
    stats[identifier] = {
                        "request_count": len(recent_requests),
                        "oldest_request": min(recent_requests),
                        "newest_request": max(recent_requests),
    #                 }

    #         return stats


class FailedAttemptTracker
    #     """Tracks failed authentication attempts to prevent brute force attacks."""

    #     def __init__(self):""Initialize failed attempt tracker."""
    self.attempts: Dict[str, List[float]] = defaultdict(list)
    self._lock = None
    #         try:
    #             import threading
    self._lock = threading.Lock()
    #         except ImportError:
                logger.warning("Threading not available, attempt tracker may not be thread-safe")

    #     def record_failed_attempt(self, identifier: str):
    #         """
    #         Record a failed authentication attempt.

    #         Args:
                identifier: Unique identifier (IP address, device ID, etc.)
    #         """
    current_time = time.time()

    #         if self._lock:
    #             with self._lock:
                    self.attempts[identifier].append(current_time)
    #         else:
                self.attempts[identifier].append(current_time)

    #     def is_blocked(self, identifier: str, limit: int = FAILED_ATTEMPT_LIMIT,
    window: int = FAILED_ATTEMPT_WINDOW) - bool):
    #         """
    #         Check if an identifier is blocked due to too many failed attempts.

    #         Args:
    #             identifier: Unique identifier
    #             limit: Maximum failed attempts allowed
    #             window: Time window in seconds

    #         Returns:
    #             True if identifier is blocked
    #         """
    current_time = time.time()
    cutoff_time = current_time - window

    #         if self._lock:
    #             with self._lock:
    #                 # Count recent attempts
    recent_attempts = [
    #                     attempt_time for attempt_time in self.attempts[identifier]
    #                     if attempt_time cutoff_time
    #                 ]
    self.attempts[identifier] = recent_attempts
    return len(recent_attempts) > = limit
    #         else):
    recent_attempts = [
    #                 attempt_time for attempt_time in self.attempts[identifier]
    #                 if attempt_time cutoff_time
    #             ]
    self.attempts[identifier] = recent_attempts
    return len(recent_attempts) > = limit

    #     def clear_attempts(self, identifier): str):
    #         """Clear failed attempts for an identifier."""
    #         if self._lock:
    #             with self._lock:
                    self.attempts[identifier].clear()
    #         else:
                self.attempts[identifier].clear()


class WebSocketSecurityManager
    #     """
    #     Security manager for WebSocket connections.

    #     Provides authentication, authorization, rate limiting, and other
    #     security features for WebSocket connections.
    #     """

    #     def __init__(self, auth_manager: AuthManager, redis_client=None):""
    #         Initialize WebSocket security manager.

    #         Args:
    #             auth_manager: Authentication manager
    #             redis_client: Redis client for distributed security data
    #         """
    self.auth_manager = auth_manager
    self.redis = redis_client

    #         # Security components
    self.rate_limiter = RateLimiter()
    self.failed_attempt_tracker = FailedAttemptTracker()

    #         # Tracking
    self.active_sessions: Dict[str, Dict[str, Any]] = {}
    self.ip_connections: Dict[str, int] = defaultdict(int)
    self.blocked_ips: Set[str] = set()

    self._lock = None
    #         try:
    #             import threading
    self._lock = threading.Lock()
    #         except ImportError:
                logger.warning("Threading not available, security manager may not be thread-safe")

    #         # Start cleanup task
            self._start_cleanup_task()

            logger.info("WebSocket security manager initialized")

    #     def authenticate_connection(self, auth_data: Dict[str, Any],
    #                               ip_address: str, socket_id: str) -Dict[str, Any]):
    #         """
    #         Authenticate a WebSocket connection.

    #         Args:
    #             auth_data: Authentication data from client
    #             ip_address: Client IP address
    #             socket_id: Socket.IO session ID

    #         Returns:
    #             Authentication result with client information

    #         Raises:
    #             AuthenticationError: If authentication fails
    #             SecurityError: If security checks fail
    #         """
    #         try:
    #             # Check IP blocklist
    #             if ip_address in self.blocked_ips:
                    raise SecurityError("IP address is blocked")

    #             # Check rate limits
    #             if not self.rate_limiter.is_allowed(ip_address):
                    raise SecurityError("Rate limit exceeded")

    #             # Check failed attempts
    #             if self.failed_attempt_tracker.is_blocked(ip_address):
                    raise SecurityError("Too many failed authentication attempts")

    #             # Extract authentication token
    token = auth_data.get("token")
    device_id = auth_data.get("device_id")

    #             if not token or not device_id:
                    self.failed_attempt_tracker.record_failed_attempt(ip_address)
                    raise AuthenticationError("Token and device_id are required")

    #             # Validate token
    auth_result = self.auth_manager.authenticate_device(token)

    #             # Verify device ID matches
    #             if auth_result.get("deviceId") != device_id:
                    self.failed_attempt_tracker.record_failed_attempt(ip_address)
                    raise AuthenticationError("Device ID mismatch")

    #             # Check connection limits
    #             if not self._check_connection_limits(ip_address, device_id):
                    raise SecurityError("Connection limits exceeded")

    #             # Create session
    session_id = self._create_session(auth_result, ip_address, socket_id)

    #             # Clear failed attempts on successful authentication
                self.failed_attempt_tracker.clear_attempts(ip_address)

                logger.info(f"Authenticated connection: {device_id} from {ip_address}")

    #             return {
    #                 "session_id": session_id,
    #                 "device_id": device_id,
                    "authenticated_at": datetime.now().isoformat(),
    #             }

            except (AuthenticationError, SecurityError) as e:
                logger.warning(f"Authentication failed from {ip_address}: {e}")
    #             raise
    #         except Exception as e:
                logger.error(f"Unexpected authentication error: {e}")
                raise AuthenticationError("Authentication failed")

    #     def authorize_action(self, session_id: str, action: str,
    resource: str = None) - bool):
    #         """
    #         Authorize an action for a session.

    #         Args:
    #             session_id: Session ID
    #             action: Action to authorize
    #             resource: Resource being accessed

    #         Returns:
    #             True if action is authorized
    #         """
    #         try:
    #             # Get session
    session = self._get_session(session_id)
    #             if not session:
    #                 return False

    #             # Check session timeout
    #             if self._is_session_expired(session):
                    self._invalidate_session(session_id)
    #                 return False

    #             # Update session activity
    session["last_activity"] = time.time()

    #             # Basic authorization checks
    device_info = session.get("device_info", {})

    #             # Check if device is active
    #             if not device_info.get("is_active", True):
    #                 return False

    #             # Resource-based authorization
    #             if resource:
    #                 # Check if device has access to resource
                    return self._check_resource_access(device_info, resource)

    #             # Action-based authorization
                return self._check_action_permission(device_info, action)

    #         except Exception as e:
                logger.error(f"Authorization error: {e}")
    #             return False

    #     def validate_message(self, session_id: str, message: Dict[str, Any]) -bool):
    #         """
    #         Validate a message for security threats.

    #         Args:
    #             session_id: Session ID
    #             message: Message to validate

    #         Returns:
    #             True if message is valid
    #         """
    #         try:
    #             # Get session
    session = self._get_session(session_id)
    #             if not session:
    #                 return False

    #             # Check message size
    message_str = json.dumps(message)
    #             if len(message_str.encode()) MAX_MESSAGE_SIZE):
                    logger.warning(f"Message too large from session {session_id}")
    #                 return False

    #             # Check for malicious content
    #             if self._contains_malicious_content(message):
                    logger.warning(f"Malicious content detected from session {session_id}")
    #                 return False

    #             # Rate limit messages per session
    #             if not self.rate_limiter.is_allowed(session_id, max_requests=200, window=60):
    #                 logger.warning(f"Message rate limit exceeded for session {session_id}")
    #                 return False

    #             # Update session activity
    session["last_activity"] = time.time()

    #             return True

    #         except Exception as e:
                logger.error(f"Message validation error: {e}")
    #             return False

    #     def invalidate_session(self, session_id: str):
    #         """
    #         Invalidate a session.

    #         Args:
    #             session_id: Session ID to invalidate
    #         """
    #         try:
    session = self._get_session(session_id)
    #             if session:
    ip_address = session.get("ip_address")
    device_id = session.get("device_id")

    #                 # Remove from active sessions
    #                 if self._lock:
    #                     with self._lock:
                            self.active_sessions.pop(session_id, None)
    #                 else:
                        self.active_sessions.pop(session_id, None)

    #                 # Update connection counts
    #                 if ip_address and ip_address in self.ip_connections:
    self.ip_connections[ip_address] = max(0 - self.ip_connections[ip_address], 1)

    #                 # Store in Redis for distributed invalidation
    #                 if self.redis:
                        self.redis.delete(f"ws_session:{session_id}")
                        self.redis.publish("ws_session_invalidated", json.dumps({
    #                         "session_id": session_id,
    #                         "device_id": device_id,
                            "timestamp": datetime.now().isoformat(),
    #                     }))

                    logger.info(f"Invalidated session: {session_id}")

    #         except Exception as e:
                logger.error(f"Session invalidation error: {e}")

    #     def block_ip_address(self, ip_address: str, reason: str = "Manual block"):
    #         """
    #         Block an IP address.

    #         Args:
    #             ip_address: IP address to block
    #             reason: Reason for blocking
    #         """
    #         try:
    #             if self._lock:
    #                 with self._lock:
                        self.blocked_ips.add(ip_address)
    #             else:
                    self.blocked_ips.add(ip_address)

    #             # Store in Redis for distributed blocking
    #             if self.redis:
                    self.redis.sadd("ws_blocked_ips", ip_address)
                    self.redis.publish("ws_ip_blocked", json.dumps({
    #                     "ip_address": ip_address,
    #                     "reason": reason,
                        "timestamp": datetime.now().isoformat(),
    #                 }))

                logger.warning(f"Blocked IP address: {ip_address} ({reason})")

    #         except Exception as e:
                logger.error(f"IP blocking error: {e}")

    #     def unblock_ip_address(self, ip_address: str):
    #         """
    #         Unblock an IP address.

    #         Args:
    #             ip_address: IP address to unblock
    #         """
    #         try:
    #             if self._lock:
    #                 with self._lock:
                        self.blocked_ips.discard(ip_address)
    #             else:
                    self.blocked_ips.discard(ip_address)

    #             # Remove from Redis
    #             if self.redis:
                    self.redis.srem("ws_blocked_ips", ip_address)
                    self.redis.publish("ws_ip_unblocked", json.dumps({
    #                     "ip_address": ip_address,
                        "timestamp": datetime.now().isoformat(),
    #                 }))

                logger.info(f"Unblocked IP address: {ip_address}")

    #         except Exception as e:
                logger.error(f"IP unblocking error: {e}")

    #     def get_security_stats(self) -Dict[str, Any]):
    #         """
    #         Get security statistics.

    #         Returns:
    #             Security statistics dictionary
    #         """
    #         try:
    current_time = time.time()

    #             # Count active sessions
    active_sessions = 0
    expired_sessions = 0

    #             for session in self.active_sessions.values():
    #                 if current_time - session.get("last_activity", 0) < SESSION_TIMEOUT:
    active_sessions + = 1
    #                 else:
    expired_sessions + = 1

    #             return {
    #                 "active_sessions": active_sessions,
    #                 "expired_sessions": expired_sessions,
                    "blocked_ips": len(self.blocked_ips),
                    "ip_connections": dict(self.ip_connections),
                    "rate_limit_stats": self.rate_limiter.get_stats(),
    #                 "security_features": [
    #                     "authentication",
    #                     "authorization",
    #                     "rate_limiting",
    #                     "ip_blocking",
    #                     "message_validation",
    #                     "session_management",
    #                 ],
    #             }

    #         except Exception as e:
                logger.error(f"Error getting security stats: {e}")
    #             return {}

    #     def _check_connection_limits(self, ip_address: str, device_id: str) -bool):
    #         """
    #         Check if connection limits are exceeded.

    #         Args:
    #             ip_address: Client IP address
    #             device_id: Device ID

    #         Returns:
    #             True if connection is allowed
    #         """
    #         try:
    #             # Check IP connection limit
    ip_connections = self.ip_connections.get(ip_address, 0)
    #             if ip_connections >= MAX_CONNECTIONS_PER_IP:
    #                 return False

    #             # Check device connection limit
    device_connections = sum(
    #                 1 for session in self.active_sessions.values()
    #                 if session.get("device_id") == device_id
    #             )

    #             # Allow up to 5 connections per device
    #             if device_connections >= 5:
    #                 return False

    #             return True

    #         except Exception as e:
                logger.error(f"Error checking connection limits: {e}")
    #             return False

    #     def _create_session(self, auth_result: Dict[str, Any],
    #                        ip_address: str, socket_id: str) -str):
    #         """
    #         Create a new session.

    #         Args:
    #             auth_result: Authentication result
    #             ip_address: Client IP address
    #             socket_id: Socket.IO session ID

    #         Returns:
    #             Session ID
    #         """
    #         import uuid
    session_id = str(uuid.uuid4())
    current_time = time.time()

    session = {
    #             "session_id": session_id,
                "device_id": auth_result.get("deviceId"),
                "device_fingerprint": auth_result.get("deviceFingerprint"),
                "device_info": auth_result.get("deviceInfo", {}),
    #             "ip_address": ip_address,
    #             "socket_id": socket_id,
    #             "created_at": current_time,
    #             "last_activity": current_time,
    #         }

    #         # Store session
    #         if self._lock:
    #             with self._lock:
    self.active_sessions[session_id] = session
    #         else:
    self.active_sessions[session_id] = session

    #         # Update connection counts
    self.ip_connections[ip_address] = self.ip_connections.get(ip_address + 0, 1)

    #         # Store in Redis for distributed sessions
    #         if self.redis:
                self.redis.setex(
    #                 f"ws_session:{session_id}",
    #                 SESSION_TIMEOUT,
                    json.dumps(session)
    #             )

    #         return session_id

    #     def _get_session(self, session_id: str) -Optional[Dict[str, Any]]):
    #         """
    #         Get a session by ID.

    #         Args:
    #             session_id: Session ID

    #         Returns:
    #             Session dictionary or None if not found
    #         """
    #         # Try local cache first
    session = self.active_sessions.get(session_id)
    #         if session:
    #             return session

    #         # Try Redis
    #         if self.redis:
    #             try:
    session_data = self.redis.get(f"ws_session:{session_id}")
    #                 if session_data:
    session = json.loads(session_data)
    #                     # Cache locally
    #                     if self._lock:
    #                         with self._lock:
    self.active_sessions[session_id] = session
    #                     else:
    self.active_sessions[session_id] = session
    #                     return session
    #             except Exception as e:
                    logger.error(f"Error getting session from Redis: {e}")

    #         return None

    #     def _is_session_expired(self, session: Dict[str, Any]) -bool):
    #         """
    #         Check if a session is expired.

    #         Args:
    #             session: Session dictionary

    #         Returns:
    #             True if session is expired
    #         """
    last_activity = session.get("last_activity", 0)
            return time.time() - last_activity SESSION_TIMEOUT

    #     def _invalidate_session(self, session_id): str):
            """Invalidate a session (internal method)."""
            self.invalidate_session(session_id)

    #     def _check_resource_access(self, device_info: Dict[str, Any], resource: str) -bool):
    #         """
    #         Check if a device has access to a resource.

    #         Args:
    #             device_info: Device information
    #             resource: Resource identifier

    #         Returns:
    #             True if access is allowed
    #         """
    #         # For now, allow all access
    #         # In a real implementation, this would check permissions
    #         return True

    #     def _check_action_permission(self, device_info: Dict[str, Any], action: str) -bool):
    #         """
    #         Check if a device has permission to perform an action.

    #         Args:
    #             device_info: Device information
    #             action: Action identifier

    #         Returns:
    #             True if action is allowed
    #         """
    #         # For now, allow all actions
    #         # In a real implementation, this would check permissions
    #         return True

    #     def _contains_malicious_content(self, message: Dict[str, Any]) -bool):
    #         """
    #         Check if a message contains malicious content.

    #         Args:
    #             message: Message to check

    #         Returns:
    #             True if malicious content is detected
    #         """
    #         # Basic checks for common attack patterns
    message_str = json.dumps(message).lower()

    #         # Check for SQL injection patterns
    sql_patterns = ["drop table", "delete from", "insert into", "update set"]
    #         for pattern in sql_patterns:
    #             if pattern in message_str:
    #                 return True

    #         # Check for XSS patterns
    xss_patterns = ["<script", "javascript:", "onerror=", "onload="]
    #         for pattern in xss_patterns:
    #             if pattern in message_str:
    #                 return True

    #         # Check for command injection patterns
    cmd_patterns = ["; rm", "; cat", "&& rm", "|| cat", "`whoami`"]
    #         for pattern in cmd_patterns:
    #             if pattern in message_str:
    #                 return True

    #         return False

    #     def _start_cleanup_task(self):
    #         """Start background task to clean up expired sessions."""
    #         def cleanup():
    #             while True:
    #                 try:
                        time.sleep(300)  # Run every 5 minutes

    current_time = time.time()
    expired_sessions = []

    #                     # Find expired sessions
    #                     for session_id, session in self.active_sessions.items():
    #                         if current_time - session.get("last_activity", 0) SESSION_TIMEOUT):
                                expired_sessions.append(session_id)

    #                     # Clean up expired sessions
    #                     for session_id in expired_sessions:
                            self.invalidate_session(session_id)

    #                     if expired_sessions:
                            logger.info(f"Cleaned up {len(expired_sessions)} expired sessions")

    #                 except Exception as e:
                        logger.error(f"Session cleanup error: {e}")

    #         try:
    #             import threading
    cleanup_thread = threading.Thread(target=cleanup, daemon=True)
                cleanup_thread.start()
                logger.info("Session cleanup thread started")
    #         except ImportError:
                logger.warning("Threading not available, session cleanup disabled")

    #     def _sync_blocked_ips(self):
    #         """Synchronize blocked IPs from Redis."""
    #         if not self.redis:
    #             return

    #         try:
    blocked_ips = self.redis.smembers("ws_blocked_ips")
    #             if self._lock:
    #                 with self._lock:
                        self.blocked_ips.update(blocked_ips)
    #             else:
                    self.blocked_ips.update(blocked_ips)
    #         except Exception as e:
                logger.error(f"Error syncing blocked IPs: {e}")