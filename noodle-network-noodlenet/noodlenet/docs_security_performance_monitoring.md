# NoodleVision Security and Performance Monitoring Guide

This guide provides comprehensive instructions for implementing security measures and performance monitoring in NoodleVision deployments.

## Table of Contents

1. [Security Considerations](#security-considerations)
2. [Authentication and Authorization](#authentication-and-authorization)
3. [Input Validation](#input-validation)
4. [Data Protection](#data-protection)
5. [Performance Monitoring](#performance-monitoring)
6. [Load Testing](#load-testing)
7. [Resource Optimization](#resource-optimization)
8. [Incident Response](#incident-response)
9. [Compliance and Auditing](#compliance-and-auditing)

## Security Considerations

### 1. Security Overview

NoodleVision processes sensitive audio data and requires robust security measures:

- **Data Confidentiality**: Protect audio content from unauthorized access
- **Data Integrity**: Ensure audio data is not tampered with during processing
- **Availability**: Maintain service availability for legitimate users
- **Compliance**: Meet regulatory requirements for data processing

### 2. Threat Model Analysis

Identify potential security threats:

```python
# threat_analysis.py
class ThreatAnalysis:
    def __init__(self):
        self.threats = {
            'unauthorized_access': {
                'description': 'Unauthorized access to audio data',
                'impact': 'HIGH',
                'likelihood': 'MEDIUM',
                'mitigation': 'Authentication and authorization'
            },
            'data_injection': {
                'description': 'Malicious audio data injection',
                'impact': 'HIGH',
                'likelihood': 'MEDIUM',
                'mitigation': 'Input validation and sanitization'
            },
            'dosing_attacks': {
                'description': 'Denial of service through resource exhaustion',
                'impact': 'HIGH',
                'likelihood': 'MEDIUM',
                'mitigation': 'Rate limiting and resource management'
            },
            'data_leakage': {
                'description': 'Unauthorized exfiltration of processed audio features',
                'impact': 'HIGH',
                'likelihood': 'LOW',
                'mitigation': 'Access controls and encryption'
            }
        }
    
    def get_risk_level(self, threat: str) -> str:
        """Calculate risk level for a threat"""
        if threat not in self.threats:
            return 'UNKNOWN'
        
        threat_data = self.threats[threat]
        impact_score = {'HIGH': 3, 'MEDIUM': 2, 'LOW': 1}[threat_data['impact']]
        likelihood_score = {'HIGH': 3, 'MEDIUM': 2, 'LOW': 1}[threat_data['likelihood']]
        
        risk_score = impact_score * likelihood_score
        
        if risk_score >= 6:
            return 'HIGH'
        elif risk_score >= 3:
            return 'MEDIUM'
        else:
            return 'LOW'
    
    def generate_security_report(self):
        """Generate security analysis report"""
        report = {
            'threats': [],
            'overall_risk': 'LOW',
            'recommendations': []
        }
        
        for threat, data in self.threats.items():
            risk_level = self.get_risk_level(threat)
            report['threats'].append({
                'threat': threat,
                'description': data['description'],
                'impact': data['impact'],
                'likelihood': data['likelihood'],
                'risk_level': risk_level,
                'mitigation': data['mitigation']
            })
            
            if risk_level == 'HIGH':
                report['overall_risk'] = 'HIGH'
        
        # Generate recommendations
        for threat in self.threats:
            if self.get_risk_level(threat) == 'HIGH':
                report['recommendations'].append(
                    f"Implement {self.threats[threat]['mitigation']} for {threat}"
                )
        
        return report

# Usage
threat_analyzer = ThreatAnalysis()
report = threat_analyzer.generate_security_report()
print(f"Security Report: {report}")
```

### 3. Security Configuration

Implement security configuration for NoodleVision:

```python
# security_config.py
import os
import ssl
import secrets
from typing import Dict, Any
import logging
from datetime import datetime, timedelta

class NoodleVisionSecurityConfig:
    def __init__(self):
        self.config = {
            'authentication': {
                'enabled': True,
                'method': 'token',  # 'token', 'oauth', 'api_key'
                'token_expiry': 3600,  # seconds
                'refresh_token_expiry': 86400  # seconds
            },
            'authorization': {
                'enabled': True,
                'role_based': True,
                'roles': {
                    'admin': ['read', 'write', 'delete', 'manage'],
                    'user': ['read', 'write'],
                    'guest': ['read']
                }
            },
            'input_validation': {
                'max_audio_size': 100 * 1024 * 1024,  # 100MB
                'allowed_formats': ['wav', 'mp3', 'flac', 'aac'],
                'max_duration': 3600,  # 1 hour
                'sample_rate_limits': [8000, 192000]
            },
            'data_protection': {
                'encryption_enabled': True,
                'encryption_algorithm': 'AES-256-GCM',
                'key_rotation_days': 90,
                'anonymization_enabled': True
            },
            'rate_limiting': {
                'enabled': True,
                'requests_per_minute': 100,
                'requests_per_hour': 1000,
                'burst_limit': 10
            },
            'audit_logging': {
                'enabled': True,
                'log_level': 'INFO',
                'retention_days': 365,
                'log_rotation': True
            }
        }
        
        # Generate security tokens
        self.api_key = self.generate_api_key()
        self.secret_key = self.generate_secret_key()
        
        # Setup logging
        self.setup_logging()
    
    def generate_api_key(self) -> str:
        """Generate secure API key"""
        return secrets.token_urlsafe(32)
    
    def generate_secret_key(self) -> str:
        """Generate secret key for encryption"""
        return secrets.token_urlsafe(64)
    
    def setup_logging(self):
        """Setup security logging"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('security.log'),
                logging.StreamHandler()
            ]
        )
        
        self.logger = logging.getLogger('noodlevision.security')
    
    def log_security_event(self, event_type: str, details: Dict[str, Any]):
        """Log security events"""
        log_entry = {
            'timestamp': datetime.utcnow().isoformat(),
            'event_type': event_type,
            'details': details,
            'api_key_used': self.api_key[:8] + '...'  # Mask for security
        }
        
        self.logger.info(f"Security Event: {json.dumps(log_entry)}")
        
        # Alert for critical events
        if event_type in ['unauthorized_access', 'data_breach', 'system_compromise']:
            self.send_security_alert(event_type, details)
    
    def send_security_alert(self, event_type: str, details: Dict[str, Any]):
        """Send security alerts"""
        # Implementation would integrate with your alerting system
        alert = {
            'event_type': event_type,
            'severity': 'CRITICAL',
            'details': details,
            'timestamp': datetime.utcnow().isoformat()
        }
        
        # Send to security monitoring system
        print(f"🚨 SECURITY ALERT: {json.dumps(alert, indent=2)}")
    
    def validate_input(self, audio_data: bytes, metadata: Dict[str, Any]) -> bool:
        """Validate audio input for security"""
        # Check file size
        if len(audio_data) > self.config['input_validation']['max_audio_size']:
            self.log_security_event('size_violation', {
                'attempted_size': len(audio_data),
                'max_allowed': self.config['input_validation']['max_audio_size']
            })
            return False
        
        # Check format
        file_format = metadata.get('format', '').lower()
        if file_format not in self.config['input_validation']['allowed_formats']:
            self.log_security_event('format_violation', {
                'attempted_format': file_format,
                'allowed_formats': self.config['input_validation']['allowed_formats']
            })
            return False
        
        # Check duration
        duration = metadata.get('duration', 0)
        if duration > self.config['input_validation']['max_duration']:
            self.log_security_event('duration_violation', {
                'attempted_duration': duration,
                'max_allowed': self.config['input_validation']['max_duration']
            })
            return False
        
        # Check sample rate
        sample_rate = metadata.get('sample_rate', 0)
        min_rate, max_rate = self.config['input_validation']['sample_rate_limits']
        if not (min_rate <= sample_rate <= max_rate):
            self.log_security_event('sample_rate_violation', {
                'attempted_rate': sample_rate,
                'allowed_range': self.config['input_validation']['sample_rate_limits']
            })
            return False
        
        return True
    
    def encrypt_data(self, data: bytes) -> bytes:
        """Encrypt data for storage"""
        if not self.config['data_protection']['encryption_enabled']:
            return data
        
        # Implementation would use proper encryption
        # This is a placeholder
        return f"ENCRYPTED:{len(data)}:{self.secret_key[:8]}".encode()
    
    def decrypt_data(self, encrypted_data: bytes) -> bytes:
        """Decrypt data for processing"""
        if not self.config['data_protection']['encryption_enabled']:
            return encrypted_data
        
        # Implementation would use proper decryption
        # This is a placeholder
        return encrypted_data.decode().split(':', 2)[2].encode()

# Usage
security_config = NoodleVisionSecurityConfig()
print(f"API Key: {security_config.api_key}")
print(f"Config: {security_config.config}")
```

## Authentication and Authorization

### 1. Authentication System

Implement secure authentication for NoodleVision:

```python
# authentication.py
import jwt
import bcrypt
from datetime import datetime, timedelta
from typing import Optional, Dict, Any
import hashlib
import secrets

class NoodleVisionAuth:
    def __init__(self, secret_key: str):
        self.secret_key = secret_key
        self.algorithm = "HS256"
        self.token_expiry = timedelta(hours=1)
        self.refresh_token_expiry = timedelta(days=7)
        
        # In-memory user store (in production, use database)
        self.users = {}
        self.api_keys = {}
        self.active_tokens = set()
        
        # Create default admin user
        self.create_default_admin()
    
    def create_default_admin(self):
        """Create default admin user"""
        admin_password = self.hash_password("admin123")
        self.users['admin'] = {
            'password': admin_password,
            'role': 'admin',
            'email': 'admin@noodlevision.com',
            'created_at': datetime.utcnow().isoformat()
        }
    
    def hash_password(self, password: str) -> str:
        """Hash password using bcrypt"""
        salt = bcrypt.gensalt()
        return bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')
    
    def verify_password(self, password: str, hashed_password: str) -> bool:
        """Verify password against hash"""
        return bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8'))
    
    def generate_token(self, user_id: str, user_role: str) -> Dict[str, str]:
        """Generate JWT access token"""
        payload = {
            'user_id': user_id,
            'role': user_role,
            'exp': datetime.utcnow() + self.token_expiry,
            'iat': datetime.utcnow(),
            'jti': secrets.token_urlsafe(16)  # JWT ID for revocation
        }
        
        token = jwt.encode(payload, self.secret_key, algorithm=self.algorithm)
        self.active_tokens.add(payload['jti'])
        
        return {
            'access_token': token,
            'token_type': 'Bearer',
            'expires_in': int(self.token_expiry.total_seconds()),
            'refresh_token': self.generate_refresh_token(user_id)
        }
    
    def generate_refresh_token(self, user_id: str) -> str:
        """Generate refresh token"""
        payload = {
            'user_id': user_id,
            'exp': datetime.utcnow() + self.refresh_token_expiry,
            'iat': datetime.utcnow(),
            'type': 'refresh'
        }
        
        return jwt.encode(payload, self.secret_key, algorithm=self.algorithm)
    
    def verify_token(self, token: str) -> Optional[Dict[str, Any]]:
        """Verify JWT token"""
        try:
            payload = jwt.decode(token, self.secret_key, algorithms=[self.algorithm])
            
            # Check if token is revoked
            if payload.get('jti') not in self.active_tokens:
                return None
            
            return payload
        except jwt.ExpiredSignatureError:
            return None
        except jwt.InvalidTokenError:
            return None
    
    def revoke_token(self, token: str) -> bool:
        """Revoke token"""
        payload = self.verify_token(token)
        if payload and 'jti' in payload:
            self.active_tokens.discard(payload['jti'])
            return True
        return False
    
    def create_api_key(self, user_id: str, permissions: list) -> str:
        """Create API key with specific permissions"""
        api_key = secrets.token_urlsafe(32)
        key_hash = hashlib.sha256(api_key.encode()).hexdigest()
        
        self.api_keys[key_hash] = {
            'user_id': user_id,
            'permissions': permissions,
            'created_at': datetime.utcnow().isoformat(),
            'last_used': None,
            'revoked': False
        }
        
        return api_key
    
    def verify_api_key(self, api_key: str) -> Optional[Dict[str, Any]]:
        """Verify API key"""
        key_hash = hashlib.sha256(api_key.encode()).hexdigest()
        
        if key_hash not in self.api_keys:
            return None
        
        key_data = self.api_keys[key_hash]
        if key_data['revoked']:
            return None
        
        # Update last used timestamp
        key_data['last_used'] = datetime.utcnow().isoformat()
        
        return key_data
    
    def create_user(self, username: str, password: str, email: str, role: str = 'user') -> bool:
        """Create new user"""
        if username in self.users:
            return False
        
        hashed_password = self.hash_password(password)
        self.users[username] = {
            'password': hashed_password,
            'email': email,
            'role': role,
            'created_at': datetime.utcnow().isoformat(),
            'active': True
        }
        
        return True
    
    def authenticate_user(self, username: str, password: str) -> Optional[Dict[str, str]]:
        """Authenticate user and return tokens"""
        if username not in self.users:
            return None
        
        user_data = self.users[username]
        if not user_data['active']:
            return None
        
        if not self.verify_password(password, user_data['password']):
            return None
        
        return self.generate_token(username, user_data['role'])
    
    def has_permission(self, token: str, required_permission: str) -> bool:
        """Check if user has required permission"""
        payload = self.verify_token(token)
        if not payload:
            return False
        
        user_role = payload.get('role', 'guest')
        
        # Define role permissions
        role_permissions = {
            'admin': ['read', 'write', 'delete', 'manage'],
            'user': ['read', 'write'],
            'guest': ['read']
        }
        
        return required_permission in role_permissions.get(user_role, [])

# Usage
auth = NoodleVisionAuth(secret_key="your-secret-key")

# Create user
auth.create_user("john_doe", "password123", "john@example.com", "user")

# Authenticate user
tokens = auth.authenticate_user("john_doe", "password123")
print(f"Tokens: {tokens}")

# Check permission
has_permission = auth.has_permission(tokens['access_token'], 'write')
print(f"Has write permission: {has_permission}")
```

### 2. OAuth2 Integration

Implement OAuth2 for third-party authentication:

```python
# oauth2_integration.py
from authlib.integrations.flask_client import OAuth
from flask import Flask, redirect, url_for, session, request
import jwt
from datetime import datetime, timedelta

class NoodleVisionOAuth:
    def __init__(self, app: Flask, client_id: str, client_secret: str):
        self.app = app
        self.oauth = OAuth(app)
        
        # Configure OAuth providers
        self.google = self.oauth.register(
            'google',
            client_id=client_id,
            client_secret=client_secret,
            server_metadata_url='https://accounts.google.com/.well-known/openid-configuration',
            client_kwargs={'scope': 'openid email profile'}
        )
        
        self.github = self.oauth.register(
            'github',
            client_id=client_id,
            client_secret=client_secret,
            client_kwargs={'scope': 'user:email'}
        )
        
        # Session configuration
        @app.before_request
        def make_session_permanent():
            session.permanent = True
    
    def create_google_login_url(self):
        """Create Google login URL"""
        return self.google.authorize_redirect(url_for('google_callback'))
    
    def create_github_login_url(self):
        """Create GitHub login URL"""
        return self.github.authorize_redirect(url_for('github_callback'))
    
    def handle_google_callback(self):
        """Handle Google OAuth callback"""
        token = self.google.authorize_access_token()
        user_info = self.google.parse_id_token(token)
        
        # Create or update user
        user = self.get_or_create_user(
            provider='google',
            provider_id=user_info['sub'],
            email=user_info['email'],
            name=user_info.get('name', ''),
            picture=user_info.get('picture', '')
        )
        
        # Create JWT token
        return self.create_jwt_token(user)
    
    def handle_github_callback(self):
        """Handle GitHub OAuth callback"""
        token = self.github.authorize_access_token()
        response = self.github.get('user')
        user_info = response.json()
        
        # Get user email
        email = user_info.get('email', '')
        if not email:
            # Get primary email from GitHub
            emails_response = self.github.get('user/emails')
            emails = emails_response.json()
            email = next((e['email'] for e in emails if e['primary']), '')
        
        # Create or update user
        user = self.get_or_create_user(
            provider='github',
            provider_id=str(user_info['id']),
            email=email,
            name=user_info.get('name', ''),
            picture=user_info.get('avatar_url', '')
        )
        
        # Create JWT token
        return self.create_jwt_token(user)
    
    def get_or_create_user(self, provider: str, provider_id: str, email: str, 
                          name: str, picture: str) -> Dict[str, Any]:
        """Get existing user or create new one"""
        # In production, this would query your database
        user = {
            'provider': provider,
            'provider_id': provider_id,
            'email': email,
            'name': name,
            'picture': picture,
            'created_at': datetime.utcnow().isoformat(),
            'role': 'user'  # Default role
        }
        
        return user
    
    def create_jwt_token(self, user: Dict[str, Any]) -> Dict[str, str]:
        """Create JWT token for user"""
        payload = {
            'user_id': user['email'],
            'name': user['name'],
            'email': user['email'],
            'role': user['role'],
            'exp': datetime.utcnow() + timedelta(hours=1),
            'iat': datetime.utcnow()
        }
        
        token = jwt.encode(payload, 'your-secret-key', algorithm='HS256')
        
        return {
            'access_token': token,
            'token_type': 'Bearer',
            'expires_in': 3600,
            'user_info': {
                'name': user['name'],
                'email': user['email'],
                'picture': user['picture']
            }
        }

# Usage with Flask
app = Flask(__name__)
app.secret_key = 'your-session-secret-key'

oauth = NoodleVisionOAuth(
    app=app,
    client_id="your-google-client-id",
    client_secret="your-google-client-secret"
)

@app.route('/login/google')
def login_google():
    return oauth.create_google_login_url()

@app.route('/login/github')
def login_github():
    return oauth.create_github_login_url()

@app.route('/callback/google')
def google_callback():
    tokens = oauth.handle_google_callback()
    return f"Logged in! Token: {tokens['access_token']}"

@app.route('/callback/github')
def github_callback():
    tokens = oauth.handle_github_callback()
    return f"Logged in! Token: {tokens['access_token']}"

if __name__ == '__main__':
    app.run(debug=True)
```

## Input Validation

### 1. Comprehensive Input Validation

Implement robust input validation for audio data:

```python
# input_validation.py
import numpy as np
import wave
import io
from typing import Dict, Any, Tuple, Optional
import hashlib
import magic  # python-magic library for file type detection

class AudioValidator:
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.logger = logging.getLogger('noodlevision.validation')
    
    def validate_audio_file(self, audio_data: bytes, metadata: Dict[str, Any]) -> Tuple[bool, Dict[str, Any]]:
        """Validate audio file comprehensively"""
        validation_result = {
            'valid': True,
            'errors': [],
            'warnings': [],
            'processed_metadata': {}
        }
        
        try:
            # Basic validation
            if not self._validate_basic(audio_data, validation_result):
                validation_result['valid'] = False
                return validation_result, validation_result
            
            # File type validation
            if not self._validate_file_type(audio_data, validation_result):
                validation_result['valid'] = False
                return validation_result, validation_result
            
            # Audio format validation
            audio_info = self._get_audio_info(audio_data)
            if not self._validate_audio_format(audio_info, validation_result):
                validation_result['valid'] = False
                return validation_result, validation_result
            
            # Content validation
            if not self._validate_audio_content(audio_data, audio_info, validation_result):
                validation_result['valid'] = False
                return validation_result, validation_result
            
            # Security validation
            if not self._validate_security(audio_data, validation_result):
                validation_result['valid'] = False
                return validation_result, validation_result
            
            # Update processed metadata
            validation_result['processed_metadata'] = audio_info
            
        except Exception as e:
            validation_result['valid'] = False
            validation_result['errors'].append(f"Validation error: {str(e)}")
            self.logger.error(f"Audio validation failed: {e}")
        
        return validation_result, validation_result
    
    def _validate_basic(self, audio_data: bytes, result: Dict[str, Any]) -> bool:
        """Basic validation checks"""
        # Check size
        if len(audio_data) > self.config.get('max_file_size', 100 * 1024 * 1024):
            result['errors'].append(f"File size too large: {len(audio_data)} bytes")
            return False
        
        # Check minimum size
        if len(audio_data) < 44:  # WAV header minimum size
            result['errors'].append("File too small to be valid audio")
            return False
        
        # Check for empty data
        if not audio_data:
            result['errors'].append("Empty audio data")
            return False
        
        return True
    
    def _validate_file_type(self, audio_data: bytes, result: Dict[str, Any]) -> bool:
        """Validate file type using magic numbers"""
        try:
            # Use python-magic to detect file type
            file_type = magic.from_buffer(audio_data, mime=True)
            
            allowed_types = self.config.get('allowed_mime_types', [
                'audio/wav',
                'audio/mpeg',
                'audio/flac',
                'audio/aac',
                'audio/ogg'
            ])
            
            if file_type not in allowed_types:
                result['errors'].append(f"Unsupported file type: {file_type}")
                return False
            
            # Verify file type matches extension if provided
            if 'extension' in result.get('processed_metadata', {}):
                expected_type = self._extension_to_mime_type(
                    result['processed_metadata']['extension']
                )
                if file_type != expected_type:
                    result['warnings'].append(f"File type mismatch: {file_type} vs {expected_type}")
            
        except Exception as e:
            result['errors'].append(f"File type validation failed: {str(e)}")
            return False
        
        return True
    
    def _get_audio_info(self, audio_data: bytes) -> Dict[str, Any]:
        """Extract audio information from file"""
        info = {
            'size': len(audio_data),
            'hash': hashlib.sha256(audio_data).hexdigest(),
            'format': 'unknown',
            'duration': 0,
            'sample_rate': 0,
            'channels': 0,
            'bits_per_sample': 0,
            'duration_seconds': 0
        }
        
        try:
            # Try to parse as WAV
            if audio_data.startswith(b'RIFF'):
                wav_info = self._parse_wav_header(audio_data)
                info.update(wav_info)
            
            # Try to parse as MP3
            elif audio_data.startswith(b'ID3') or audio_data.startswith(b'\xFF\xFB'):
                mp3_info = self._parse_mp3_header(audio_data)
                info.update(mp3_info)
            
            # Try to parse as FLAC
            elif audio_data.startswith(b'fLaC'):
                flac_info = self._parse_flac_header(audio_data)
                info.update(flac_info)
            
        except Exception as e:
            self.logger.warning(f"Audio info extraction failed: {e}")
        
        return info
    
    def _parse_wav_header(self, audio_data: bytes) -> Dict[str, Any]:
        """Parse WAV file header"""
        try:
            # Read RIFF header
            if audio_data[:4] != b'RIFF':
                raise ValueError("Not a WAV file")
            
            # Read chunk sizes
            chunk_size = int.from_bytes(audio_data[4:8], 'little')
            if audio_data[8:12] != b'WAVE':
                raise ValueError("Invalid WAV format")
            
            # Find fmt chunk
            pos = 12
            while pos < len(audio_data):
                chunk_id = audio_data[pos:pos+4]
                chunk_size = int.from_bytes(audio_data[pos+4:pos+8], 'little')
                
                if chunk_id == b'fmt ':
                    # Parse fmt chunk
                    audio_format = int.from_bytes(audio_data[pos+8:pos+10], 'little')
                    channels = int.from_bytes(audio_data[pos+10:pos+12], 'little')
                    sample_rate = int.from_bytes(audio_data[pos+12:pos+16], 'little')
                    byte_rate = int.from_bytes(audio_data[pos+16:pos+20], 'little')
                    block_align = int.from_bytes(audio_data[pos+20:pos+22], 'little')
                    bits_per_sample = int.from_bytes(audio_data[pos+22:pos+24], 'little')
                    
                    # Calculate duration
                    data_pos = pos + 8 + chunk_size
                    if data_pos + 4 <= len(audio_data):
                        data_size = int.from_bytes(audio_data[data_pos+4:data_pos+8], 'little')
                        duration_seconds = data_size / byte_rate if byte_rate > 0 else 0
                    
                    return {
                        'format': 'WAV',
                        'audio_format': audio_format,
                        'channels': channels,
                        'sample_rate': sample_rate,
                        'bits_per_sample': bits_per_sample,
                        'duration_seconds': duration_seconds
                    }
                
                pos += 8 + chunk_size
                if pos % 2 != 0:
                    pos += 1  # Align to 2-byte boundary
        
        except Exception as e:
            self.logger.warning(f"WAV header parsing failed: {e}")
        
        return {}
    
    def _parse_mp3_header(self, audio_data: bytes) -> Dict[str, Any]:
        """Parse MP3 file header"""
        try:
            info = {'format': 'MP3'}
            
            # Look for MP3 frame headers
            for i in range(0, min(len(audio_data) - 4, 1024)):
                header = audio_data[i:i+4]
                
                # Check for MP3 frame header
                if (header[0] == 0xFF and (header[1] & 0xE0) == 0xE0):
                    version = (header[1] >> 3) & 0x03
                    layer = (header[1] >> 1) & 0x03
                    bitrate_index = (header[2] >> 4) & 0x0F
                    sampling_rate_index = (header[2] >> 2) & 0x03
                    
                    # Map indices to actual values
                    bitrate_table = [0, 32, 64, 96, 128, 160, 192, 224, 256, 288, 320, 352, 384, 416, 448, 0]
                    sample_rate_table = [
                        [44100, 22050, 11025, 0],
                        [48000, 24000, 12000, 0],
                        [32000, 16000, 8000, 0]
                    ]
                    
                    if version == 3:  # MPEG 1
                        version_index = 0
                    elif version == 2:  # MPEG 2
                        version_index = 1
                    else:  # MPEG 2.5
                        version_index = 2
                    
                    bitrate = bitrate_table[bitrate_index] * 1000 if bitrate_index < 15 else 0
                    sample_rate = sample_rate_table[version_index][sampling_rate_index] if sampling_rate_index < 4 else 0
                    
                    info.update({
                        'sample_rate': sample_rate,
                        'bitrate': bitrate,
                        'duration_seconds': len(audio_data) * 8 / bitrate if bitrate > 0 else 0
                    })
                    
                    break
            
        except Exception as e:
            self.logger.warning(f"MP3 header parsing failed: {e}")
        
        return info
    
    def _parse_flac_header(self, audio_data: bytes) -> Dict[str, Any]:
        """Parse FLAC file header"""
        try:
            if audio_data[:4] != b'fLaC':
                raise ValueError("Not a FLAC file")
            
            pos = 4
            sample_rate = 0
            channels = 0
            bits_per_sample = 0
            
            while pos < len(audio_data):
                block_type = audio_data[pos]
                block_size = int.from_bytes(audio_data[pos+1:pos+4], 'big')
                
                if block_type == 0x00:  # STREAMINFO
                    if pos + 4 + block_size <= len(audio_data):
                        # Extract info
                        total_samples = int.from_bytes(audio_data[pos+13:pos+17], 'big')
                        sample_rate = int.from_bytes(audio_data[pos+10:pos+14], 'big')
                        channels = (audio_data[pos+12] & 0xF0) >> 4
                        bits_per_sample = ((audio_data[pos+12] & 0x0F) << 1) | ((audio_data[pos+13] & 0x80) >> 7)
                        
                        # Calculate duration
                        duration_seconds = total_samples / sample_rate if sample_rate > 0 else 0
                        
                        return {
                            'format': 'FLAC',
                            'sample_rate': sample_rate,
                            'channels': channels,
                            'bits_per_sample': bits_per_sample,
                            'duration_seconds': duration_seconds
                        }
                
                pos += 4 + block_size
                if block_type & 0x80:  # Last block bit
                    break
        
        except Exception as e:
            self.logger.warning(f"FLAC header parsing failed: {e}")
        
        return {}
    
    def _validate_audio_format(self, audio_info: Dict[str, Any], result: Dict[str, Any]) -> bool:
        """Validate audio format parameters"""
        # Sample rate validation
        min_sample_rate = self.config.get('min_sample_rate', 8000)
        max_sample_rate = self.config.get('max_sample_rate', 192000)
        
        if audio_info.get('sample_rate', 0) < min_sample_rate:
            result['errors'].append(f"Sample rate too low: {audio_info.get('sample_rate', 0)} Hz")
            return False
        
        if audio_info.get('sample_rate', 0) > max_sample_rate:
            result['errors'].append(f"Sample rate too high: {audio_info.get('sample_rate', 0)} Hz")
            return False
        
        # Channels validation
        min_channels = self.config.get('min_channels', 1)
        max_channels = self.config.get('max_channels', 8)
        
        channels = audio_info.get('channels', 0)
        if channels < min_channels:
            result['errors'].append(f"Too few channels: {channels}")
            return False
        
        if channels > max_channels:
            result['errors'].append(f"Too many channels: {channels}")
            return False
        
        # Duration validation
        min_duration = self.config.get('min_duration', 0)
        max_duration = self.config.get('max_duration', 3600)  # 1 hour
        
        duration = audio_info.get('duration_seconds', 0)
        if duration < min_duration:
            result['errors'].append(f"Audio too short: {duration} seconds")
            return False
        
        if duration > max_duration:
            result['errors'].append(f"Audio too long: {duration} seconds")
            return False
        
        # Bit depth validation
        min_bits = self.config.get('min_bits_per_sample', 8)
        max_bits = self.config.get('max_bits_per_sample', 32)
        
        bits = audio_info.get('bits_per_sample', 0)
        if bits < min_bits:
            result['errors'].append(f"Bit depth too low: {bits} bits")
            return False
        
        if bits > max_bits:
            result['errors'].append(f"Bit depth too high: {bits} bits")
            return False
        
        return True
    
    def _validate_audio_content(self, audio_data: bytes, audio_info: Dict[str, Any], result: Dict[str, Any]) -> bool:
        """Validate audio content for anomalies"""
        try:
            # Check for silence
            if self._is_silent(audio_data, audio_info):
                result['warnings'].append("Audio appears to be silent")
            
            # Check for clipping
            if self._has_clipping(audio_data, audio_info):
                result['warnings'].append("Audio contains clipping distortion")
            
            # Check for excessive noise
            if self._has_excessive_noise(audio_data, audio_info):
                result['warnings'].append("Audio contains excessive noise")
            
            # Check for correlation issues (stereo)
            if audio_info.get('channels', 1) > 1:
                if self._has_correlation_issues(audio_data, audio_info):
                    result['warnings'].append("Audio channel correlation issues detected")
            
            # Check for metadata consistency
            if not self._validate_metadata_consistency(audio_data, audio_info):
                result['warnings'].append("Metadata inconsistencies detected")
            
        except Exception as e:
            result['errors'].append(f"Content validation error: {str(e)}")
            return False
        
        return True
    
    def _is_silent(self, audio_data: bytes, audio_info: Dict[str, Any]) -> bool:
        """Check if audio is silent"""
        try:
            # Extract audio samples
            if audio_info.get('format') == 'WAV':
                samples = self._extract_wav_samples(audio_data)
            else:
                # For other formats, use a simplified approach
                return False
            
            # Check if all samples are near zero
            threshold = 0.001  # Adjust based on bit depth
            max_amplitude = np.max(np.abs(samples))
            
            return max_amplitude < threshold
            
        except Exception:
            return False
    
    def _has_clipping(self, audio_data: bytes, audio_info: Dict[str, Any]) -> bool:
        """Check for audio clipping"""
        try:
            # Extract audio samples
            if audio_info.get('format') == 'WAV':
                samples = self._extract_wav_samples(audio_data)
            else:
                return False
            
            # Check for samples at maximum amplitude
            bits_per_sample = audio_info.get('bits_per_sample', 16)
            max_value = 2 ** (bits_per_sample - 1) - 1
            
            clipped_samples = np.sum(np.abs(samples) >= max_value)
            total_samples = len(samples)
            clipping_ratio = clipped_samples / total_samples
            
            return clipping_ratio > 0.01  # More than 1% clipped
            
        except Exception:
            return False
    
    def _has_excessive_noise(self, audio_data: bytes, audio_info: Dict[str, Any]) -> bool:
        """Check for excessive noise"""
        try:
            # Extract audio samples
            if audio_info.get('format') == 'WAV':
                samples = self._extract_wav_samples(audio_data)
            else:
                return False
            
            # Calculate signal-to-noise ratio
            signal_power = np.mean(samples ** 2)
            noise_power = np.var(samples - np.mean(samples))
            
            if noise_power == 0:
                return False
            
            snr = 10 * np.log10(signal_power / noise_power)
            
            # Low SNR indicates excessive noise
            return snr < 10  # 10 dB threshold
            
        except Exception:
            return False
    
    def _has_correlation_issues(self, audio_data: bytes, audio_info: Dict[str, Any]) -> bool:
        """Check for stereo channel correlation issues"""
        try:
            if audio_info.get('channels', 1) != 2:
                return False
            
            # Extract stereo samples
            samples = self._extract_wav_samples(audio_data)
            
            # Split channels
            left_channel = samples[0::2]
            right_channel = samples[1::2]
            
            # Calculate correlation
            correlation = np.corrcoef(left_channel, right_channel)[0, 1]
            
            # Low correlation indicates issues
            return abs(correlation) < 0.5
            
        except Exception:
            return False
    
    def _validate_metadata_consistency(self, audio_data: bytes, audio_info: Dict[str, Any]) -> bool:
        """Validate metadata consistency"""
        try:
            # Check that calculated duration matches metadata
            if 'duration_seconds' in audio_info and audio_info['duration_seconds'] > 0:
                # For WAV files, verify duration matches file size
                if audio_info.get('format') == 'WAV':
                    byte_rate = audio_info.get('sample_rate', 0) * \
                               audio_info.get('channels', 1) * \
                               (audio_info.get('bits_per_sample', 16) // 8)
                    
                    if byte_rate > 0:
                        calculated_duration = len(audio_data) / byte_rate
                        duration_diff = abs(calculated_duration - audio_info['duration_seconds'])
                        
                        if duration_diff > 1.0:  # More than 1 second difference
                            return False
            
            return True
            
        except Exception:
            return False
    
    def _validate_security(self, audio_data: bytes, result: Dict[str, Any]) -> bool:
        """Validate audio for security issues"""
        try:
            # Check for potential steganography
            if self._detect_steganography(audio_data):
                result['warnings'].append("Potential steganography detected")
            
            # Check for malicious content patterns
            if self._detect_malicious_patterns(audio_data):
                result['errors'].append("Malicious content patterns detected")
                return False
            
            # Check for embedded executables
            if self._detect_embedded_executables(audio_data):
                result['errors'].append("Embedded executables detected")
                return False
            
            return True
            
        except Exception as e:
            result['errors'].append(f"Security validation error: {str(e)}")
            return False
    
    def _detect_steganography(self, audio_data: bytes) -> bool:
        """Detect potential steganography"""
        try:
            # Check for unusual entropy patterns
            entropy = self._calculate_entropy(audio_data)
            
            # High entropy might indicate steganography
            return entropy > 7.5
            
        except Exception:
            return False
    
    def _detect_malicious_patterns(self, audio_data: bytes) -> bool:
        """Detect malicious content patterns"""
        try:
            # Check for suspicious sequences
            suspicious_patterns = [
                b'\x00\x00\x00\x00\x00\x00\x00\x00',  # Null sequences
                b'\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF',  # Max value sequences
                b'\x00\xFF\x00\xFF\x00\xFF\x00\xFF',  # Alternating patterns
            ]
            
            for pattern in suspicious_patterns:
                if pattern in audio_data:
                    return True
            
            return False
            
        except Exception:
            return False
    
    def _detect_embedded_executables(self, audio_data: bytes) -> bool:
        """Detect embedded executables"""
        try:
            # Check for executable headers
            executable_signatures = [
                b'MZ',  # DOS executable
                b'\x7FELF',  # ELF executable
                b'BM',  # Windows bitmap (sometimes used in malware)
            ]
            
            for signature in executable_signatures:
                if audio_data.startswith(signature):
                    return True
            
            return False
            
        except Exception:
            return False
    
    def _calculate_entropy(self, data: bytes) -> float:
        """Calculate Shannon entropy"""
        try:
            import math
            
            # Count byte frequencies
            byte_counts = [0] * 256
            for byte in data:
                byte_counts[byte] += 1
            
            # Calculate entropy
            entropy = 0.0
            for count in byte_counts:
                if count > 0:
                    probability = count / len(data)
                    entropy -= probability * math.log2(probability)
            
            return entropy
            
        except Exception:
            return 0.0
    
    def _extract_wav_samples(self, audio_data: bytes) -> np.ndarray:
        """Extract audio samples from WAV file"""
        try:
            # Find data chunk
            pos = 12  # Skip RIFF header
            
            while pos < len(audio_data):
                chunk_id = audio_data[pos:pos+4]
                chunk_size = int.from_bytes(audio_data[pos+4:pos+8], 'little')
                
                if chunk_id == b'data':
                    # Extract samples
                    bits_per_sample = int.from_bytes(audio_data[pos+22:pos+24], 'little)
                    bytes_per_sample = bits_per_sample // 8
                    
                    samples = np.frombuffer(audio_data[pos+8:pos+8+chunk_size], 
                                          dtype=np.int16 if bits_per_sample == 16 else np.int32)
                    
                    # Normalize to [-1, 1]
                    if bits_per_sample == 16:
                        samples = samples.astype(np.float32) / 32768.0
                    elif bits_per_sample == 32:
                        samples = samples.astype(np.float32) / 2147483648.0
                    
                    return samples
                
                pos += 8 + chunk_size
                if pos % 2 != 0:
                    pos += 1  # Align to 2-byte boundary
            
            return np.array([])
            
        except Exception:
            return np.array([])

# Usage
validator_config = {
    'max_file_size': 100 * 1024 * 1024,  # 100MB
    'min_sample_rate': 8000,
    'max_sample_rate': 192000,
    'min_channels': 1,
    'max_channels': 8,
    'min_duration': 0,
    'max_duration': 3600,
    'allowed_mime_types': [
        'audio/wav',
        'audio/mpeg',
        'audio/flac',
        'audio/aac'
    ]
}

validator = AudioValidator(validator_config)

# Example usage
with open('test_audio.wav', 'rb') as f:
    audio_data = f.read()

metadata = {'filename': 'test_audio.wav'}
result, details = validator.validate_audio_file(audio_data, metadata)

print(f"Validation result: {result['valid']}")
print(f"Errors: {result['errors']}")
print(f"Warnings: {result['warnings']}")
```

## Data Protection

### 1. Encryption and Anonymization

Implement data protection measures for NoodleVision:

```python
# data_protection.py
import hashlib
import hmac
import os
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import base64
import json
from typing import Dict, Any, Optional
import tempfile
import shutil

class NoodleVisionDataProtection:
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.encryption_key = self._generate_or_load_key()
        self.cipher = Fernet(self.encryption_key)
        
        # Anonymization patterns
        self.anonymization_patterns = {
            'email': r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
            'phone': r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b',
            'ssn': r'\b\d{3}[-]?\d{2}[-]?\d{4}\b',
            'credit_card': r'\b\d{4}[- ]?\d{4}[- ]?\d{4}[- ]?\d{4}\b'
        }
    
    def _generate_or_load_key(self) -> bytes:
        """Generate or load encryption key"""
        key_file = self.config.get('key_file', 'noodlevision.key')
        
        if os.path.exists(key_file):
            with open(key_file, 'rb') as f:
                return f.read()
        else:
            key = Fernet.generate_key()
            with open(key_file, 'wb') as f:
                f.write(key)
            os.chmod(key_file, 0o600)  # Restrict permissions
            return key
    
    def encrypt_data(self, data: Any) -> bytes:
        """Encrypt data for storage"""
        if isinstance(data, str):
            data = data.encode('utf-8')
        elif isinstance(data, dict):
            data = json.dumps(data).encode('utf-8')
        
        return self.cipher.encrypt(data)
    
    def decrypt_data(self, encrypted_data: bytes) -> Any:
        """Decrypt data for processing"""
        try:
            decrypted = self.cipher.decrypt(encrypted_data)
            
            # Try to parse as JSON first
            try:
                return json.loads(decrypted.decode('utf-8'))
            except json.JSONDecodeError:
                return decrypted.decode('utf-8')
        except Exception:
            return None
    
    def hash_data(self, data: Any, algorithm: str = 'sha256') -> str:
        """Hash data for secure storage"""
        if isinstance(data, str):
            data = data.encode('utf-8')
        
        hash_func = getattr(hashlib, algorithm)()
        hash_func.update(data)
        return hash_func.hexdigest()
    
    def create_secure_temp_file(self, data: bytes) -> str:
        """Create secure temporary file"""
        # Create temporary file with restricted permissions
        fd, temp_path = tempfile.mkstemp(dir=self.config.get('temp_dir', '/tmp'))
        os.close(fd)
        os.chmod(temp_path, 0o600)
        
        # Write data
        with open(temp_path, 'wb') as f:
            f.write(data)
        
        return temp_path
    
    def secure_delete_file(self, file_path: str):
        """Securely delete file by overwriting"""
        if not os.path.exists(file_path):
            return
        
        file_size = os.path.getsize(file_path)
        
        # Overwrite with random data
        with open(file_path, 'wb') as f:
            for _ in range(3):  # 3 passes
                f.write(os.urandom(file_size))
        
        # Remove file
        os.unlink(file_path)
    
    def anonymize_audio_features(self, features: Dict[str, np.ndarray]) -> Dict[str, np.ndarray]:
        """Anonymize audio features to remove identifiable information"""
        anonymized_features = {}
        
        for feature_name, feature_data in features.items():
            if feature_name in ['mfcc', 'chroma', 'tonnetz']:
                # Apply anonymization techniques
                anonymized = self._anonymize_feature(feature_data)
                anonymized_features[feature_name] = anonymized
            else:
                anonymized_features[feature_name] = feature_data
        
        return anonymized_features
    
    def _anonymize_feature(self, feature_data: np.ndarray) -> np.ndarray:
        """Anonymize individual feature data"""
        # Apply noise to make it harder to identify
        noise_level = 0.01
        noise = np.random.normal(0, noise_level, feature_data.shape)
        anonymized = feature_data + noise
        
        # Clip to valid range
        anonymized = np.clip(anonymized, -1, 1)
        
        return anonymized
    
    def create_access_token(self, user_id: str, permissions: list, expiry_hours: int = 24) -> str:
        """Create secure access token"""
        payload = {
            'user_id': user_id,
            'permissions': permissions,
            'exp': time.time() + expiry_hours * 3600,
            'iat': time.time(),
            'jti': self.generate_uuid()
        }
        
        # Sign with HMAC
        signature = hmac.new(
            self.config.get('secret_key', '').encode(),
            json.dumps(payload).encode(),
            hashlib.sha256
        ).hexdigest()
        
        token_data = {
            'payload': payload,
            'signature': signature
        }
        
        return base64.b64encode(json.dumps(token_data).encode()).decode()
    
    def verify_access_token(self, token: str) -> Optional[Dict[str, Any]]:
        """Verify access token"""
        try:
            # Decode token
            token_data = json.loads(base64.b64decode(token.encode()).decode())
            payload = token_data['payload']
            signature = token_data['signature']
            
            # Verify signature
            expected_signature = hmac.new(
                self.config.get('secret_key', '').encode(),
                json.dumps(payload).encode(),
                hashlib.sha256
            ).hexdigest()
            
            if not hmac.compare_digest(signature, expected_signature):
                return None
            
            # Check expiry
            if payload.get('exp', 0) < time.time():
                return None
            
            return payload
            
        except Exception:
            return None
    
    def generate_audit_log(self, action: str, user_id: str, details: Dict[str, Any]) -> Dict[str, Any]:
        """Generate secure audit log entry"""
        audit_entry = {
            'timestamp': time.time(),
            'action': action,
            'user_id': self.hash_data(user_id),
            'details': details,
            'session_id': self.generate_uuid(),
            'ip_hash': self.hash_data(details.get('ip_address', ''))
        }
        
        # Encrypt sensitive information
        encrypted_entry = self.encrypt_data(audit_entry)
        
        return encrypted_entry
    
    def export_encrypted_data(self, data: Any, output_path: str, passphrase: str):
        """Export data with encryption"""
        # Derive key from passphrase
        salt = os.urandom(16)
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
        )
        key = base64.urlsafe_b64encode(kdf.derive(passphrase.encode()))
        cipher = Fernet(key)
        
        # Encrypt data
        encrypted_data = cipher.encrypt(json.dumps(data).encode())
        
        # Save with salt
        with open(output_path, 'wb') as f:
            f.write(salt + encrypted_data)
    
    def import_encrypted_data(self, input_path: str, passphrase: str) -> Any:
        """Import encrypted data"""
        with open(input_path, 'rb') as f:
            data = f.read()
        
        # Extract salt and encrypted data
        salt = data[:16]
        encrypted_data = data[16:]
        
        # Derive key
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
        )
        key = base64.urlsafe_b64encode(kdf.derive(passphrase.encode()))
        cipher = Fernet(key)
        
        # Decrypt data
        decrypted_data = cipher.decrypt(encrypted_data)
        return json.loads(decrypted_data.decode())
    
    def generate_uuid(self) -> str:
        """Generate secure UUID"""
        return str(uuid.uuid4())

# Usage
protection_config = {
    'key_file': 'noodlevision.key',
    'temp_dir': '/tmp',
    'secret_key': 'your-secret-key-here'
}

protection = NoodleVisionDataProtection(protection_config)

# Example usage
features = {
    'mfcc': np.random.rand(13, 100),
    'chroma': np.random.rand(12, 100),
    'spectrogram': np.random.rand(128, 100)
}

# Anonymize features
anonymized = protection.anonymize_audio_features(features)

# Create access token
token = protection.create_access_token('user123', ['read', 'write'])

# Verify token
payload = protection.verify_access_token(token)
print(f"Token payload: {payload}")
```

## Performance Monitoring

### 1. Advanced Performance Monitoring

Implement comprehensive performance monitoring:

```python
# performance_monitoring.py
import time
import psutil
import threading
import queue
import numpy as np
from typing import Dict, Any, List, Optional
from dataclasses import dataclass
from datetime import datetime, timedelta
import json
import os
from collections import defaultdict, deque

@dataclass
class PerformanceMetrics:
    timestamp: float
    cpu_percent: float
    memory_percent: float
    disk_usage: float
    network_io: Dict[str, int]
    process_info: Dict[str, float]
    noodlevision_metrics: Dict[str, Any]

class NoodleVisionPerformanceMonitor:
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.metrics_history = deque(maxlen=config.get('history_size', 1000))
        self.alerts = []
        self.is_running = False
        
        # Performance queues
        self.metrics_queue = queue.Queue()
        self.alert_queue = queue.Queue()
        
        # Alert thresholds
        self.thresholds = config.get('thresholds', {
            'cpu_percent': 80.0,
            'memory_percent': 85.0,
            'disk_usage': 90.0,
            'response_time': 5.0,
            'error_rate': 0.05
        })
        
        # Start monitoring thread
        self.monitor_thread = threading.Thread(target=self._monitor_loop, daemon=True)
        self.monitor_thread.start()
        
        # Start alert processor
        self.alert_thread = threading.Thread(target=self._alert_processor, daemon=True)
        self.alert_thread.start()
    
    def _monitor_loop(self):
        """Main monitoring loop"""
        self.is_running = True
        
        while self.is_running:
            try:
                # Collect metrics
                metrics = self._collect_metrics()
                self.metrics_queue.put(metrics)
                
                # Check for alerts
                self._check_alerts(metrics)
                
                # Sleep for interval
                time.sleep(self.config.get('interval', 5))
                
            except Exception as e:
                print(f"Monitoring error: {e}")
                time.sleep(1)
    
    def _alert_processor(self):
        """Process alerts in background"""
        while self.is_running:
            try:
                alert = self.alert_queue.get(timeout=1)
                self._handle_alert(alert)
            except queue.Empty:
                continue
    
    def _collect_metrics(self) -> PerformanceMetrics:
        """Collect system and application metrics"""
        timestamp = time.time()
        
        # System metrics
        cpu_percent = psutil.cpu_percent(interval=1)
        memory_percent = psutil.virtual_memory().percent
        disk_usage = psutil.disk_usage('/').percent
        
        network_io = psutil.net_io_counters()._asdict()
        
        # Process metrics
        process = psutil.Process()
        process_info = {
            'memory_rss': process.memory_info().rss,
            'cpu_percent': process.cpu_percent(),
            'num_threads': process.num_threads(),
            'open_files': len(process.open_files())
        }
        
        # NoodleVision specific metrics
        noodlevision_metrics = self._collect_noodlevision_metrics()
        
        return PerformanceMetrics(
            timestamp=timestamp,
            cpu_percent=cpu_percent,
            memory_percent=memory_percent,
            disk_usage=disk_usage,
            network_io=network_io,
            process_info=process_info,
            noodlevision_metrics=noodlevision_metrics
        )
    
    def _collect_noodlevision_metrics(self) -> Dict[str, Any]:
        """Collect NoodleVision specific metrics"""
        try:
            # Import NoodleVision modules
            import sys
            import os
            sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'vision'))
            
            from memory import MemoryManager, MemoryPolicy
            
            # Get memory manager statistics
            if hasattr(self, 'memory_manager'):
                stats = self.memory_manager.get_statistics()
                return {
                    'memory_usage': stats,
                    'cache_stats': stats.get('cache_stats', {}),
                    'feature_extraction_count': getattr(self, 'feature_extraction_count', 0),
                    'avg_processing_time': getattr(self, 'avg_processing_time', 0.0)
                }
            
        except Exception as e:
            return {'error': str(e)}
        
        return {}
    
    def _check_alerts(self, metrics: PerformanceMetrics):
        """Check for alert conditions"""
        alerts = []
        
        # CPU alerts
        if metrics.cpu_percent > self.thresholds['cpu_percent']:
            alerts.append({
                'type': 'cpu_high',
                'message': f"CPU usage high: {metrics.cpu_percent:.1f}%",
                'severity': 'WARNING',
                'metrics': metrics
            })
        
        # Memory alerts
        if metrics.memory_percent > self.thresholds['memory_percent']:
            alerts.append({
                'type': 'memory_high',
                'message': f"Memory usage high: {metrics.memory_percent:.1f}%",
                'severity': 'WARNING',
                'metrics': metrics
            })
        
        # Disk alerts
        if metrics.disk_usage > self.thresholds['disk_usage']:
            alerts.append({
                'type': 'disk_high',
                'message': f"Disk usage high: {metrics.disk_usage:.1f}%",
                'severity': 'CRITICAL',
                'metrics': metrics
            })
        
        # Network alerts
        if metrics.network_io['bytes_sent'] > 100 * 1024 * 1024:  # 100MB/s
            alerts.append({
                'type': 'network_high',
                'message': f"High network traffic: {metrics.network_io['bytes_sent'] / 1024 / 1024:.1f}MB/s",
                'severity': 'WARNING',
                'metrics': metrics
            })
        
        # NoodleVision specific alerts
        noodlevision_metrics = metrics.noodlevision_metrics
        if 'cache_stats' in noodlevision_metrics:
            cache_stats = noodlevision_metrics['cache_stats']
            if cache_stats.get('cache_efficiency', 0) < 0.1:  # Less than 10% hit rate
                alerts.append({
                    'type': 'cache_inefficient',
                    'message': f"Cache efficiency low: {cache_stats.get('cache_efficiency', 0):.2f}",
                    'severity': 'WARNING',
                    'metrics': metrics
                })
        
        # Add alerts to queue
        for alert in alerts:
            self.alert_queue.put(alert)
            self.alerts.append(alert)
        
        # Keep only recent alerts
        if len(self.alerts) > 100:
            self.alerts = self.alerts[-100:]
    
    def _handle_alert(self, alert: Dict[str, Any]):
        """Handle alert"""
        # Log alert
        self._log_alert(alert)
        
        # Send notification (implementation would depend on your system)
        self._send_alert_notification(alert)
        
        # Take action for critical alerts
        if alert['severity'] == 'CRITICAL':
            self._handle_critical_alert(alert)
    
    def _log_alert(self, alert: Dict[str, Any]):
        """Log alert to file"""
        log_entry = {
            'timestamp': datetime.fromtimestamp(alert['metrics'].timestamp).isoformat(),
            'type': alert['type'],
            'message': alert['message'],
            'severity': alert['severity'],
            'metrics': alert['metrics'].__dict__
        }
        
        with open('performance_alerts.log', 'a') as f:
            f.write(json.dumps(log_entry) + '\n')
    
    def _send_alert_notification(self, alert: Dict[str, Any]):
        """Send alert notification"""
        # Implementation would integrate with your notification system
        print(f"🚨 ALERT: {alert['severity']} - {alert['message']}")
    
    def _handle_critical_alert(self, alert: Dict[str, Any]):
        """Handle critical alerts"""
        # Implementation would take appropriate action
        print(f"🔥 CRITICAL ALERT HANDLED: {alert['type']}")
    
    def get_performance_report(self, hours: int = 24) -> Dict[str, Any]:
        """Generate performance report"""
        cutoff_time = time.time() - (hours * 3600)
        
        # Filter recent metrics
        recent_metrics = [m for m in self.metrics_history if m.timestamp > cutoff_time]
        
        if not recent_metrics:
            return {'error': 'No metrics available for the specified time period'}
        
        # Calculate statistics
        cpu_stats = self._calculate_statistics([m.cpu_percent for m in recent_metrics])
        memory_stats = self._calculate_statistics([m.memory_percent for m in recent_metrics])
        disk_stats = self._calculate_statistics([m.disk_usage for m in recent_metrics])
        
        # Generate report
        report = {
            'period_hours': hours,
            'metrics_count': len(recent_metrics),
            'timestamp': datetime.fromtimestamp(time.time()).isoformat(),
            'statistics': {
                'cpu': cpu_stats,
                'memory': memory_stats,
                'disk': disk_stats
            },
            'alerts': {
                'total': len(self.alerts),
                'recent': [a for a in self.alerts if a['metrics'].timestamp > cutoff_time],
                'by_type': self._count_alerts_by_type()
            },
            'recommendations': self._generate_recommendations()
        }
        
        return report
    
    def _calculate_statistics(self, values: List[float]) -> Dict[str, float]:
        """Calculate statistics for a list of values"""
        if not values:
            return {}
        
        return {
            'min': min(values),
            'max': max(values),
            'mean': np.mean(values),
            'median': np.median(values),
            'std': np.std(values),
            'p95': np.percentile(values, 95),
            'p99': np.percentile(values, 99)
        }
    
    def _count_alerts_by_type(self) -> Dict[str, int]:
        """Count alerts by type"""
        alert_counts = defaultdict(int)
        
        for alert in self.alerts:
            alert_counts[alert['type']] += 1
        
        return dict(alert_counts)
    
    def _generate_recommendations(self) -> List[str]:
        """Generate performance recommendations"""
        recommendations = []
        
        # Analyze recent metrics
        if self.metrics_history:
            recent_cpu = [m.cpu_percent for m in self.metrics_history[-100:]]
            recent_memory = [m.memory_percent for m in self.metrics_history
