# 🔐 Enterprise Authentication with NIP v3.0.0

Advanced authentication and authorization strategies for enterprise deployments.

## Table of Contents
- [Introduction](#introduction)
- [OAuth2 Implementation](#oauth2-implementation)
- [SAML Integration](#saml-integration)
- [LDAP/Active Directory](#ldapactive-directory)
- [JWT Tokens and Refresh](#jwt-tokens-and-refresh)
- [Role-Based Access Control (RBAC)](#role-based-access-control-rbac)
- [Multi-Factor Authentication (MFA)](#multi-factor-authentication-mfa)
- [Single Sign-On (SSO)](#single-sign-on-sso)
- [Security Best Practices](#security-best-practices)
- [Practical Exercises](#practical-exercises)

---

## Introduction

Enterprise authentication requires robust, scalable, and secure identity management. This tutorial covers implementing comprehensive authentication solutions with NIP v3.0.0, supporting modern enterprise requirements.

### Key Objectives
- Implement industry-standard authentication protocols
- Secure token management and refresh strategies
- Granular authorization and role management
- Multi-factor authentication support
- Single sign-on across applications

---

## OAuth2 Implementation

OAuth 2.0 is the industry-standard protocol for authorization. NIP provides built-in support for OAuth2 flows.

### Basic OAuth2 Setup

```python
from nip.auth import OAuth2Provider, OAuth2Flow
from nip.config import AuthConfig

# Configure OAuth2 provider
oauth_config = AuthConfig(
    client_id="your_client_id",
    client_secret="your_client_secret",
    redirect_uri="https://yourapp.com/callback",
    scopes=["openid", "profile", "email"],
    authorization_endpoint="https://auth.example.com/oauth/authorize",
    token_endpoint="https://auth.example.com/oauth/token"
)

oauth = OAuth2Provider(config=oauth_config)
```

### Authorization Code Flow

```python
from nip import NIP
from nip.auth import OAuth2Flow

app = NIP(__name__)

@app.route("/login")
async def login():
    """Initiate OAuth2 authorization code flow"""
    flow = OAuth2Flow(
        provider=oauth,
        state="random_state_string"  # CSRF protection
    )
    
    # Redirect user to authorization page
    authorization_url = flow.get_authorization_url()
    return {"redirect": authorization_url}

@app.route("/callback")
async def callback(code: str, state: str):
    """Handle OAuth2 callback"""
    # Validate state to prevent CSRF attacks
    if not validate_state(state):
        raise ValueError("Invalid state parameter")
    
    # Exchange authorization code for access token
    flow = OAuth2Flow(provider=oauth)
    tokens = await flow.exchange_code_for_token(code)
    
    # Get user info with access token
    user_info = await flow.get_user_info(tokens["access_token"])
    
    # Create session and issue JWT
    session = await create_user_session(user_info)
    return {"token": session.token, "user": user_info}
```

### Client Credentials Flow (Machine-to-Machine)

```python
from nip.auth import ClientCredentialsFlow

@app.route("/service-token")
async def get_service_token():
    """Get OAuth2 token for service-to-service communication"""
    flow = ClientCredentialsFlow(provider=oauth)
    
    tokens = await flow.get_client_credentials_token(
        scope="api:read api:write"
    )
    
    return {
        "access_token": tokens["access_token"],
        "expires_in": tokens["expires_in"],
        "token_type": tokens["token_type"]
    }
```

---

## SAML Integration

Security Assertion Markup Language (SAML) enables federated identity management, commonly used in enterprise environments.

### SAML Configuration

```python
from nip.auth import SAMLProvider, SAMLConfig

saml_config = SAMLConfig(
    # Service Provider (your app) configuration
    sp_entity_id="https://yourapp.com/metadata",
    sp_acs_url="https://yourapp.com/saml/acs",
    sp_slo_url="https://yourapp.com/saml/slo",
    
    # Identity Provider configuration
    idp_entity_id="https://idp.example.com/entityid",
    idp_sso_url="https://idp.example.com/sso",
    idp_slo_url="https://idp.example.com/slo",
    idp_x509_cert="base64_encoded_certificate",
    
    # Security settings
    want_assertions_signed=True,
    want_assertions_encrypted=True,
    want_messages_signed=True,
    
    # Certificate for signing requests (optional)
    sp_x509_cert="your_sp_certificate",
    sp_private_key="your_sp_private_key"
)

saml = SAMLProvider(config=saml_config)
```

### SAML Authentication Flow

```python
from nip.auth import SAMLAuth

app = NIP(__name__)

@app.route("/saml/login")
async def saml_login():
    """Initiate SAML authentication request"""
    auth = SAMLAuth(provider=saml)
    
    # Generate SAML authentication request
    auth_request = auth.create_auth_request()
    
    # Redirect to IdP with SAML request
    return {"redirect": auth_request.redirect_url}

@app.route("/saml/acs", methods=["POST"])
async def saml_acs():
    """Handle SAML Assertion Consumer Service callback"""
    from fastapi import Request
    
    # Get SAML response from form data
    saml_response = request.form.get("SAMLResponse")
    
    auth = SAMLAuth(provider=saml)
    
    # Validate and process SAML response
    assertion = auth.process_response(saml_response)
    
    # Extract user attributes from assertion
    user_info = {
        "email": assertion.get_attribute("email"),
        "name": assertion.get_attribute("name"),
        "department": assertion.get_attribute("department"),
        "roles": assertion.get_attribute("roles")
    }
    
    # Create local session
    session = await create_user_session(user_info)
    return {"token": session.token}

@app.route("/saml/metadata")
async def saml_metadata():
    """Generate SP metadata for IdP configuration"""
    auth = SAMLAuth(provider=saml)
    metadata = auth.generate_metadata()
    return Response(content=metadata, media_type="application/xml")
```

---

## LDAP/Active Directory

LDAP provides direct integration with enterprise directory services for authentication and user management.

### LDAP Configuration

```python
from nip.auth import LDAPProvider, LDAPConfig

ldap_config = LDAPConfig(
    server="ldap://corp.example.com",
    bind_dn="cn=admin,dc=example,dc=com",
    bind_password="admin_password",
    search_base="dc=example,dc=com",
    search_filter="(sAMAccountName={username})",
    
    # Active Directory specific settings
    use_ssl=True,
    use_tls=True,
    active_directory=True,
    
    # Attribute mappings
    attribute_mapping={
        "email": "mail",
        "name": "displayName",
        "department": "department",
        "title": "title",
        "phone": "telephoneNumber"
    }
)

ldap = LDAPProvider(config=ldap_config)
```

### LDAP Authentication

```python
from nip.auth import LDAPAuth

app = NIP(__name__)

@app.route("/auth/ldap", methods=["POST"])
async def ldap_login(username: str, password: str):
    """Authenticate user against LDAP/Active Directory"""
    auth = LDAPAuth(provider=ldap)
    
    try:
        # Authenticate user
        user_info = await auth.authenticate(
            username=username,
            password=password
        )
        
        # Extract user groups for role assignment
        groups = await auth.get_user_groups(username)
        
        # Map groups to roles
        roles = map_groups_to_roles(groups)
        
        # Create session with roles
        session = await create_user_session(user_info, roles=roles)
        
        return {
            "token": session.token,
            "user": user_info,
            "roles": roles
        }
        
    except LDAPAuthError as e:
        return {"error": str(e)}, 401

def map_groups_to_roles(groups: list[str]) -> list[str]:
    """Map LDAP groups to application roles"""
    role_mapping = {
        "CN=Admins,OU=Groups,DC=example,DC=com": "admin",
        "CN=Developers,OU=Groups,DC=example,DC=com": "developer",
        "CN=Users,OU=Groups,DC=example,DC=com": "user"
    }
    
    roles = []
    for group in groups:
        if group in role_mapping:
            roles.append(role_mapping[group])
    
    return roles
```

---

## JWT Tokens and Refresh

JSON Web Tokens provide stateless authentication with secure token management and refresh capabilities.

### JWT Configuration

```python
from nip.auth import JWTConfig, JWTManager

jwt_config = JWTConfig(
    secret_key="your-256-bit-secret-key",
    algorithm="HS256",
    
    # Token expiration
    access_token_expire_minutes=15,
    refresh_token_expire_days=7,
    
    # Token issuer and audience
    issuer="https://yourapp.com",
    audience="https://yourapp.com/api"
)

jwt = JWTManager(config=jwt_config)
```

### Token Generation and Validation

```python
from datetime import datetime, timedelta
from nip.auth import TokenPayload

@app.route("/auth/token", methods=["POST"])
async def create_token(username: str, password: str):
    """Generate JWT access and refresh tokens"""
    # Authenticate user (using any method above)
    user = await authenticate_user(username, password)
    
    # Create token payload
    payload = TokenPayload(
        sub=user.id,
        email=user.email,
        roles=user.roles,
        permissions=user.permissions,
        issued_at=datetime.utcnow()
    )
    
    # Generate tokens
    access_token = jwt.create_access_token(payload)
    refresh_token = jwt.create_refresh_token(payload)
    
    # Store refresh token securely (database or Redis)
    await store_refresh_token(user.id, refresh_token)
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "Bearer",
        "expires_in": 900  # 15 minutes
    }

@app.route("/auth/refresh", methods=["POST"])
async def refresh_token(refresh_token: str):
    """Refresh access token using refresh token"""
    try:
        # Validate refresh token
        payload = jwt.decode_refresh_token(refresh_token)
        
        # Verify token is stored and not revoked
        if not await verify_refresh_token(payload["sub"], refresh_token):
            raise ValueError("Invalid refresh token")
        
        # Get fresh user data
        user = await get_user(payload["sub"])
        
        # Create new access token
        new_payload = TokenPayload(
            sub=user.id,
            email=user.email,
            roles=user.roles,
            permissions=user.permissions,
            issued_at=datetime.utcnow()
        )
        
        access_token = jwt.create_access_token(new_payload)
        
        return {
            "access_token": access_token,
            "token_type": "Bearer",
            "expires_in": 900
        }
        
    except JWTError as e:
        return {"error": "Invalid refresh token"}, 401

@app.route("/auth/logout", methods=["POST"])
async def logout(refresh_token: str):
    """Revoke refresh token"""
    payload = jwt.decode_refresh_token(refresh_token)
    await revoke_refresh_token(payload["sub"], refresh_token)
    return {"message": "Logged out successfully"}
```

### Token Middleware

```python
from nip.auth import JWTAuthMiddleware

# Add JWT authentication middleware
app.add_middleware(
    JWTAuthMiddleware,
    jwt_manager=jwt,
    exclude_paths=["/login", "/auth/token", "/docs"]
)

# Access user in protected routes
@app.route("/api/profile")
async def get_profile(user: TokenPayload = Depends(get_current_user)):
    """Get current user profile (protected)"""
    return {
        "user_id": user.sub,
        "email": user.email,
        "roles": user.roles,
        "permissions": user.permissions
    }
```

---

## Role-Based Access Control (RBAC)

RBAC provides granular access control based on user roles and permissions.

### Define Roles and Permissions

```python
from nip.auth import RBACManager, Role, Permission

rbac = RBACManager()

# Define permissions
permissions = {
    "user:read": Permission(id="user:read", description="Read user information"),
    "user:write": Permission(id="user:write", description="Create/modify users"),
    "user:delete": Permission(id="user:delete", description="Delete users"),
    "content:read": Permission(id="content:read", description="Read content"),
    "content:write": Permission(id="content:write", description="Create content"),
    "content:publish": Permission(id="content:publish", description="Publish content"),
    "admin:all": Permission(id="admin:all", description="Full administrative access")
}

# Define roles with permissions
roles = {
    "viewer": Role(
        id="viewer",
        permissions=["user:read", "content:read"]
    ),
    "editor": Role(
        id="editor",
        permissions=["user:read", "content:read", "content:write"]
    ),
    "publisher": Role(
        id="publisher",
        permissions=["user:read", "content:read", "content:write", "content:publish"]
    ),
    "admin": Role(
        id="admin",
        permissions=["admin:all"]  # Admin has all permissions
    )
}

# Register roles with RBAC manager
for role in roles.values():
    rbac.register_role(role)
```

### Permission Checking

```python
from nip.auth import require_permission, require_role

@app.route("/api/content", methods=["GET"])
@require_permission("content:read")
async def get_content(user: TokenPayload = Depends(get_current_user)):
    """Get content - requires content:read permission"""
    # User has permission, execute logic
    content = await fetch_content()
    return {"content": content}

@app.route("/api/content", methods=["POST"])
@require_permission("content:write")
async def create_content(
    content_data: dict,
    user: TokenPayload = Depends(get_current_user)
):
    """Create content - requires content:write permission"""
    content = await create_new_content(content_data, user.sub)
    return {"content": content, "created_by": user.sub}

@app.route("/api/admin/users", methods=["DELETE"])
@require_role("admin")
async def delete_user(
    user_id: str,
    user: TokenPayload = Depends(get_current_user)
):
    """Delete user - requires admin role"""
    await remove_user(user_id)
    return {"message": f"User {user_id} deleted"}

# Check permissions manually
@app.route("/api/check-permission")
async def check_permission(
    permission: str,
    user: TokenPayload = Depends(get_current_user)
):
    """Check if user has specific permission"""
    has_permission = rbac.check_permission(
        user_roles=user.roles,
        required_permission=permission
    )
    
    return {
        "permission": permission,
        "granted": has_permission
    }
```

---

## Multi-Factor Authentication (MFA)

MFA adds an extra layer of security by requiring multiple forms of verification.

### TOTP-Based MFA (Time-based One-Time Password)

```python
from nip.auth import MFAManager, TOTPProvider

mfa = MFAManager()

@app.route("/auth/mfa/setup", methods=["POST"])
async def setup_mfa(user: TokenPayload = Depends(get_current_user)):
    """Setup MFA for user"""
    # Generate TOTP secret
    totp_provider = TOTPProvider()
    secret = totp_provider.generate_secret()
    
    # Generate QR code for authenticator app
    qr_code_url = totp_provider.get_qr_code_url(
        secret=secret,
        username=user.email,
        issuer="YourApp"
    )
    
    # Temporarily store secret (verify before activating)
    await store_pending_mfa_secret(user.sub, secret)
    
    return {
        "qr_code_url": qr_code_url,
        "backup_codes": await generate_backup_codes()
    }

@app.route("/auth/mfa/verify", methods=["POST"])
async def verify_mfa_setup(
    code: str,
    user: TokenPayload = Depends(get_current_user)
):
    """Verify MFA setup and activate"""
    # Get pending secret
    secret = await get_pending_mfa_secret(user.sub)
    
    # Verify code
    totp_provider = TOTPProvider()
    is_valid = totp_provider.verify_code(secret, code)
    
    if is_valid:
        # Activate MFA for user
        await enable_mfa_for_user(user.sub, secret)
        return {"message": "MFA enabled successfully"}
    else:
        return {"error": "Invalid code"}, 400

@app.route("/auth/mfa/validate", methods=["POST"])
async def validate_mfa(username: str, password: str, code: str):
    """Validate login with MFA code"""
    # First, authenticate with username/password
    user = await authenticate_user(username, password)
    
    # Check if MFA is enabled
    mfa_secret = await get_user_mfa_secret(user.id)
    if mfa_secret:
        # Verify TOTP code
        totp_provider = TOTPProvider()
        if not totp_provider.verify_code(mfa_secret, code):
            return {"error": "Invalid MFA code"}, 401
    
    # MFA verified, create session
    session = await create_user_session(user)
    return {"token": session.token}
```

### SMS-Based MFA

```python
from nip.auth import SMSProvider

sms_provider = SMSProvider(
    api_key="your_sms_api_key",
    service_name="YourApp"
)

@app.route("/auth/mfa/sms/send", methods=["POST"])
async def send_sms_code(phone: str):
    """Send MFA code via SMS"""
    # Generate 6-digit code
    code = generate_random_code(length=6)
    
    # Store code temporarily (5 minute expiry)
    await store_sms_code(phone, code, expiry_minutes=5)
    
    # Send SMS
    await sms_provider.send_code(
        phone_number=phone,
        code=code
    )
    
    return {"message": "Code sent"}

@app.route("/auth/mfa/sms/verify", methods=["POST"])
async def verify_sms_code(phone: str, code: str):
    """Verify SMS code"""
    stored_code = await get_sms_code(phone)
    
    if stored_code and stored_code == code:
        # Code valid, proceed with authentication
        await delete_sms_code(phone)
        return {"message": "Code verified"}
    else:
        return {"error": "Invalid or expired code"}, 400
```

---

## Single Sign-On (SSO)

SSO enables users to authenticate once and access multiple applications.

### SSO Session Management

```python
from nip.auth import SSOSessionManager, SSOConfig

sso_config = SSOConfig(
    domain="yourapp.com",
    cookie_name="sso_session",
    cookie_secure=True,
    cookie_http_only=True,
    cookie_same_site="lax",
    session_expire_hours=24
)

sso = SSOSessionManager(config=sso_config)

@app.route("/sso/login")
async def sso_login():
    """Central SSO login endpoint"""
    # Use any auth method (OAuth2, SAML, LDAP)
    # After successful auth:
    
    # Create SSO session
    session_id = await sso.create_session(user_info={
        "id": user.id,
        "email": user.email,
        "roles": user.roles
    })
    
    # Set SSO cookie
    response = RedirectResponse(url="/dashboard")
    response.set_cookie(
        key="sso_session",
        value=session_id,
        domain=".yourapp.com",  # Works across subdomains
        secure=True,
        httponly=True,
        samesite="lax"
    )
    
    return response

@app.middleware("http")
async def sso_middleware(request, call_next):
    """SSO middleware to validate session across apps"""
    # Get SSO cookie
    session_id = request.cookies.get("sso_session")
    
    if session_id:
        # Validate session
        session = await sso.get_session(session_id)
        if session:
            # Add user to request state
            request.state.user = session
            request.state.sso_session = session_id
    
    response = await call_next(request)
    return response
```

### SSO Logout

```python
@app.route("/sso/logout")
async def sso_logout():
    """Central SSO logout - logs out from all apps"""
    session_id = request.cookies.get("sso_session")
    
    if session_id:
        # Invalidate session
        await sso.invalidate_session(session_id)
        
        # Optionally notify all connected apps
        await broadcast_logout_event(session_id)
    
    response = RedirectResponse(url="/login")
    response.delete_cookie("sso_session", domain=".yourapp.com")
    
    return response
```

---

## Security Best Practices

### Token Security

```python
# ✅ DO: Use strong, random secret keys
jwt_config = JWTConfig(
    secret_key=secrets.token_urlsafe(32),  # 256-bit random key
    algorithm="HS256"
)

# ✅ DO: Set appropriate token expiration
access_token_expire_minutes=15  # Short-lived access tokens
refresh_token_expire_days=7     # Longer-lived refresh tokens

# ✅ DO: Validate token claims
payload = jwt.decode_token(token)
if payload["iss"] != "https://yourapp.com":
    raise ValueError("Invalid issuer")

# ❌ DON'T: Store tokens in localStorage (use httpOnly cookies)
# ❌ DON'T: Use weak algorithms like "none"
# ❌ DON'T: Share secrets across environments
```

### Password Security

```python
import bcrypt
from nip.auth import PasswordHasher

hasher = PasswordHasher()

# ✅ DO: Use strong hashing algorithms
hashed_password = await hasher.hash(
    password=user_password,
    algorithm="bcrypt",
    rounds=12  # Computational cost factor
)

# ✅ DO: Verify passwords safely
is_valid = await hasher.verify(
    password=user_password,
    hashed_hash=stored_hash
)

# ✅ DO: Enforce password complexity
def validate_password_strength(password: str) -> bool:
    """Enforce strong password requirements"""
    if len(password) < 12:
        return False
    if not re.search(r"[A-Z]", password):
        return False
    if not re.search(r"[a-z]", password):
        return False
    if not re.search(r"\d", password):
        return False
    if not re.search(r"[!@#$%^&*(),.?\":{}|<>]", password):
        return False
    return True
```

### Rate Limiting

```python
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter

@app.route("/auth/token", methods=["POST"])
@limiter.limit("5 per minute")  # Limit to 5 attempts per minute
async def create_token(username: str, password: str):
    """Rate-limited login endpoint"""
    # Implement login logic
    pass

# Track failed attempts
from collections import defaultdict

failed_attempts = defaultdict(int)

async def check_failed_attempts(identifier: str):
    """Check if too many failed attempts"""
    if failed_attempts[identifier] >= 5:
        # Lock account for 15 minutes
        await lock_account_temporarily(identifier, minutes=15)
        raise ValueError("Account temporarily locked")
    
    failed_attempts[identifier] += 1
```

### HTTPS and Secure Headers

```python
from starlette.middleware.httpsredirect import HTTPSRedirectMiddleware
from starlette.middleware.trustedhost import TrustedHostMiddleware
from nip.security import SecurityHeadersMiddleware

# Force HTTPS in production
app.add_middleware(HTTPSRedirectMiddleware)

# Restrict allowed hosts
app.add_middleware(
    TrustedHostMiddleware,
    allowed_hosts=["yourapp.com", "*.yourapp.com"]
)

# Add security headers
app.add_middleware(
    SecurityHeadersMiddleware,
    hsts_max_age=31536000,  # 1 year
    frame_options="DENY",
    content_type_options="nosniff",
    xss_protection="1; mode=block"
)
```

---

## Practical Exercises

### Exercise 1: OAuth2 Integration

**Task**: Implement OAuth2 authentication with Google as the identity provider.

**Requirements**:
1. Create Google OAuth app in Google Cloud Console
2. Configure OAuth2 provider in NIP
3. Implement authorization code flow
4. Handle token exchange and user info retrieval

**Starter Code**:
```python
from nip.auth import OAuth2Provider

# TODO: Configure Google OAuth2
google_oauth = OAuth2Provider(config=...)

# TODO: Implement login flow
@app.route("/login/google")
async def google_login():
    pass

# TODO: Implement callback handler
@app.route("/callback/google")
async def google_callback(code: str):
    pass
```

**Expected Outcome**: User can authenticate with Google account and receive JWT token.

---

### Exercise 2: RBAC Implementation

**Task**: Create a complete RBAC system with custom roles and permissions.

**Requirements**:
1. Define at least 5 permissions
2. Create 4 roles with different permission sets
3. Implement permission checking middleware
4. Create protected routes for each permission level

**Starter Code**:
```python
from nip.auth import RBACManager

rbac = RBACManager()

# TODO: Define permissions
permissions = {}

# TODO: Define roles
roles = {}

# TODO: Create protected route
@app.route("/api/admin/...")
@require_permission("...")
async def protected_route():
    pass
```

**Expected Outcome**: Users can only access routes matching their assigned permissions.

---

### Exercise 3: MFA Implementation

**Task**: Implement TOTP-based MFA with backup codes.

**Requirements**:
1. Setup MFA with QR code generation
2. Verify TOTP codes during login
3. Generate and validate backup codes
4. Allow MFA disable with password confirmation

**Starter Code**:
```python
from nip.auth import MFAManager, TOTPProvider

# TODO: Implement MFA setup
@app.route("/auth/mfa/setup")
async def setup_mfa():
    pass

# TODO: Implement MFA verification during login
@app.route("/auth/login")
async def login_with_mfa(username, password, mfa_code):
    pass

# TODO: Implement backup code generation
async def generate_backup_codes():
    pass
```

**Expected Outcome**: Users can enable MFA and login with TOTP code or backup code.

---

## Summary

This tutorial covered comprehensive enterprise authentication strategies with NIP v3.0.0:

- **OAuth2**: Industry-standard authorization with support for multiple flows
- **SAML**: Federated identity management for enterprise SSO
- **LDAP**: Integration with Active Directory and other directory services
- **JWT**: Secure, stateless token management with refresh tokens
- **RBAC**: Granular role-based access control
- **MFA**: Multi-factor authentication with TOTP and SMS
- **SSO**: Single sign-on across multiple applications

### Next Steps

- Implement logging and monitoring for authentication events
- Set up account recovery processes
- Configure user provisioning and deprovisioning
- Implement audit trails for compliance
- Test security with penetration testing

### Additional Resources

- [OAuth 2.0 Specification](https://oauth.net/2/)
- [SAML Technical Overview](https://www.oasis-open.org/committees/security/)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)
- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [NIP Documentation](https://noodle-framework.com/docs)

---

**Tutorial Version**: 1.0  
**NIP Version**: 3.0.0  
**Last Updated**: 2025-01-17
