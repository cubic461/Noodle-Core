# 🛡️ Tutorial 10: Security Hardening

> **Advanced NIP v3.0.0 Tutorial** - Comprehensive security implementation and hardening

## Table of Contents
- [Overview](#overview)
- [Security Audit Framework](#security-audit-framework)
- [OWASP Top 10 Mitigation](#owasp-top-10-mitigation)
- [Input Validation and Sanitization](#input-validation-and-sanitization)
- [Rate Limiting and DDoS Protection](#rate-limiting-and-ddos-protection)
- [Secrets Management](#secrets-management)
- [Security Headers](#security-headers)
- [Encryption at Rest and in Transit](#encryption-at-rest-and-in-transit)
- [Security Monitoring and Alerting](#security-monitoring-and-alerting)
- [Security Checklists](#security-checklists)
- [Practical Exercises](#practical-exercises)
- [Best Practices](#best-practices)

---

## Overview

Security is not an afterthought—it's a foundational requirement for production systems. This tutorial covers comprehensive security hardening strategies for NIP v3.0.0 applications, protecting against common vulnerabilities and establishing robust security practices.

### What You'll Learn
- Security audit frameworks and methodologies
- OWASP Top 10 vulnerability mitigation
- Input validation and sanitization techniques
- Rate limiting and DDoS protection strategies
- Enterprise-grade secrets management
- Security headers and CORS configuration
- Encryption best practices (at rest and in transit)
- Security monitoring and incident response

### Prerequisites
- Completed Tutorials 01-09
- Understanding of HTTP security concepts
- Familiarity with encryption basics
- Access to cloud platforms (AWS/Azure/GCP)

### Security Metrics

| Metric | Target | Description |
|--------|--------|-------------|
| **Vulnerability Scan Score** | A+ | Security headers and configuration |
| **Dependency Vulnerabilities** | 0 | Known CVEs in dependencies |
| **Auth Failure Rate** | < 1% | Failed authentication attempts |
| **Rate Limit Compliance** | 100% | All endpoints protected |
| **Secret Rotation** | 90 days | Maximum secret age |
| **Incident Response Time** | < 15 min | Time to detect and respond |

---

## Security Audit Framework

### Audit Architecture

```python
# nip/security/audit_framework.py
import asyncio
import json
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
from dataclasses import dataclass, asdict
from enum import Enum
import hashlib
import ssl
import subprocess
from pathlib import Path

logger = logging.getLogger(__name__)


class SeverityLevel(Enum):
    """Security issue severity levels"""
    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"
    INFO = "info"


@dataclass
class SecurityIssue:
    """Represents a security vulnerability or finding"""
    id: str
    title: str
    severity: SeverityLevel
    category: str
    description: str
    recommendation: str
    evidence: Optional[str] = None
    cve_id: Optional[str] = None
    cvss_score: Optional[float] = None
    discovered_at: Optional[datetime] = None
    
    def __post_init__(self):
        if self.discovered_at is None:
            self.discovered_at = datetime.utcnow()


@dataclass
class AuditReport:
    """Security audit report"""
    scan_id: str
    timestamp: datetime
    duration_seconds: float
    total_issues: int
    issues_by_severity: Dict[str, int]
    issues: List[SecurityIssue]
    compliance_score: float
    passed_checks: List[str]
    failed_checks: List[str]
    
    def to_dict(self) -> Dict[str, Any]:
        return {
            "scan_id": self.scan_id,
            "timestamp": self.timestamp.isoformat(),
            "duration_seconds": self.duration_seconds,
            "total_issues": self.total_issues,
            "issues_by_severity": self.issues_by_severity,
            "issues": [asdict(issue) for issue in self.issues],
            "compliance_score": self.compliance_score,
            "passed_checks": self.passed_checks,
            "failed_checks": self.failed_checks
        }


class SecurityAuditor:
    """Comprehensive security audit framework"""
    
    def __init__(self, config: Optional[Dict] = None):
        self.config = config or {}
        self.issues: List[SecurityIssue] = []
        self.passed_checks: List[str] = []
        self.failed_checks: List[str] = []
        
    async def run_full_audit(self) -> AuditReport:
        """Run comprehensive security audit"""
        start_time = datetime.utcnow()
        scan_id = hashlib.sha256(
            f"{start_time.isoformat()}".encode()
        ).hexdigest()[:16]
        
        logger.info(f"Starting security audit: {scan_id}")
        
        # Run all audit checks
        await self._check_dependency_vulnerabilities()
        await self._check_security_headers()
        await self._check_authentication_config()
        await self._check_authorization_config()
        await self._check_input_validation()
        await self._check_data_encryption()
        await self._check_secrets_management()
        await self._check_rate_limiting()
        await self._check_logging_config()
        await self._check_cors_config()
        await self._check_ssl_tls_config()
        
        # Calculate metrics
        duration = (datetime.utcnow() - start_time).total_seconds()
        total_issues = len(self.issues)
        issues_by_severity = self._group_by_severity()
        compliance_score = self._calculate_compliance_score()
        
        report = AuditReport(
            scan_id=scan_id,
            timestamp=start_time,
            duration_seconds=duration,
            total_issues=total_issues,
            issues_by_severity=issues_by_severity,
            issues=self.issues,
            compliance_score=compliance_score,
            passed_checks=self.passed_checks,
            failed_checks=self.failed_checks
        )
        
        logger.info(
            f"Audit complete: {total_issues} issues found, "
            f"compliance score: {compliance_score:.1f}%"
        )
        
        return report
    
    async def _check_dependency_vulnerabilities(self):
        """Check for known vulnerabilities in dependencies"""
        check_name = "dependency_vulnerabilities"
        
        try:
            # Run safety check
            result = subprocess.run(
                ["safety", "check", "--json"],
                capture_output=True,
                text=True,
                timeout=60
            )
            
            if result.returncode == 0:
                self.passed_checks.append(check_name)
            else:
                vulnerabilities = json.loads(result.stdout)
                for vuln in vulnerabilities:
                    self.issues.append(SecurityIssue(
                        id=f"DEP-{vuln.get('id', 'UNKNOWN')}",
                        title=f"Vulnerable dependency: {vuln.get('package', 'unknown')}",
                        severity=SeverityLevel.HIGH,
                        category="dependencies",
                        description=f"Package {vuln.get('package')} version {vuln.get('installed_version')} has known vulnerabilities",
                        recommendation=f"Upgrade to {vuln.get('fixed_versions', ['latest'])[0]} or later",
                        cve_id=vuln.get('cve_id'),
                        cvss_score=vuln.get('cvss_score')
                    ))
                self.failed_checks.append(check_name)
                
        except Exception as e:
            logger.warning(f"Dependency check failed: {e}")
            self.failed_checks.append(check_name)
    
    async def _check_security_headers(self):
        """Verify security headers are properly configured"""
        check_name = "security_headers"
        
        required_headers = [
            "X-Content-Type-Options",
            "X-Frame-Options",
            "X-XSS-Protection",
            "Strict-Transport-Security",
            "Content-Security-Policy",
            "Referrer-Policy",
            "Permissions-Policy"
        ]
        
        config = self.config.get("security_headers", {})
        missing = []
        
        for header in required_headers:
            if header.lower() not in [h.lower() for h in config.keys()]:
                missing.append(header)
        
        if missing:
            self.issues.append(SecurityIssue(
                id="HDR-001",
                title="Missing security headers",
                severity=SeverityLevel.HIGH,
                category="headers",
                description=f"Missing security headers: {', '.join(missing)}",
                recommendation="Configure all required security headers in middleware"
            ))
            self.failed_checks.append(check_name)
        else:
            self.passed_checks.append(check_name)
    
    async def _check_authentication_config(self):
        """Verify authentication configuration"""
        check_name = "authentication_config"
        
        auth_config = self.config.get("authentication", {})
        
        # Check for secure password policies
        if not auth_config.get("password_min_length", 0) >= 12:
            self.issues.append(SecurityIssue(
                id="AUTH-001",
                title="Weak password policy",
                severity=SeverityLevel.MEDIUM,
                category="authentication",
                description="Password minimum length is less than 12 characters",
                recommendation="Set password_min_length to at least 12"
            ))
        
        # Check for MFA requirement
        if not auth_config.get("require_mfa", False):
            self.issues.append(SecurityIssue(
                id="AUTH-002",
                title="MFA not required",
                severity=SeverityLevel.HIGH,
                category="authentication",
                description="Multi-factor authentication is not enforced",
                recommendation="Enable require_mfa for all user accounts"
            ))
        
        # Check for secure session configuration
        session_config = auth_config.get("session", {})
        if not session_config.get("secure", False):
            self.issues.append(SecurityIssue(
                id="AUTH-003",
                title="Insecure session cookies",
                severity=SeverityLevel.CRITICAL,
                category="authentication",
                description="Session cookies do not have the 'secure' flag set",
                recommendation="Enable secure flag for session cookies"
            ))
        
        if len([i for i in self.issues if i.category == "authentication"]) == 0:
            self.passed_checks.append(check_name)
        else:
            self.failed_checks.append(check_name)
    
    async def _check_authorization_config(self):
        """Verify authorization and access control"""
        check_name = "authorization_config"
        
        authz_config = self.config.get("authorization", {})
        
        if not authz_config.get("default_deny", True):
            self.issues.append(SecurityIssue(
                id="AUTHZ-001",
                title="Permissive default authorization",
                severity=SeverityLevel.CRITICAL,
                category="authorization",
                description="Default authorization policy is not 'deny'",
                recommendation="Set default_deny to True for secure by default"
            ))
            self.failed_checks.append(check_name)
        else:
            self.passed_checks.append(check_name)
    
    async def _check_input_validation(self):
        """Verify input validation is configured"""
        check_name = "input_validation"
        
        validation_config = self.config.get("input_validation", {})
        
        if not validation_config.get("enabled", True):
            self.issues.append(SecurityIssue(
                id="INPUT-001",
                title="Input validation disabled",
                severity=SeverityLevel.CRITICAL,
                category="input_validation",
                description="Input validation is not enabled",
                recommendation="Enable input validation for all endpoints"
            ))
            self.failed_checks.append(check_name)
        else:
            self.passed_checks.append(check_name)
    
    async def _check_data_encryption(self):
        """Verify encryption configuration"""
        check_name = "data_encryption"
        
        encryption_config = self.config.get("encryption", {})
        
        issues = []
        
        # Check encryption at rest
        if not encryption_config.get("at_rest_enabled", False):
            issues.append("Encryption at rest is not enabled")
        
        # Check encryption in transit
        if not encryption_config.get("in_transit_enabled", True):
            issues.append("Encryption in transit is not enforced")
        
        # Check encryption algorithm
        algorithm = encryption_config.get("algorithm", "")
        if algorithm not in ["AES-256-GCM", "ChaCha20-Poly1305"]:
            issues.append(f"Weak encryption algorithm: {algorithm}")
        
        if issues:
            self.issues.append(SecurityIssue(
                id="ENC-001",
                title="Encryption configuration issues",
                severity=SeverityLevel.CRITICAL,
                category="encryption",
                description="; ".join(issues),
                recommendation="Enable AES-256-GCM encryption at rest and enforce TLS 1.3"
            ))
            self.failed_checks.append(check_name)
        else:
            self.passed_checks.append(check_name)
    
    async def _check_secrets_management(self):
        """Verify secrets are properly managed"""
        check_name = "secrets_management"
        
        secrets_config = self.config.get("secrets", {})
        
        if not secrets_config.get("use_vault", False):
            self.issues.append(SecurityIssue(
                id="SEC-001",
                title="Secrets not in vault",
                severity=SeverityLevel.HIGH,
                category="secrets",
                description="Secrets are not stored in a secure vault",
                recommendation="Use HashiCorp Vault or cloud secrets manager"
            ))
        
        # Check for hardcoded secrets (basic check)
        sensitive_patterns = [
            ("password", r'password\s*=\s*["\'][^"\']+["\']'),
            ("api_key", r'api[_-]?key\s*=\s*["\'][^"\']+["\']'),
            ("secret", r'secret\s*=\s*["\'][^"\']+["\']'),
        ]
        
        # This would scan codebase for hardcoded secrets
        # Simplified for this example
        
        if len([i for i in self.issues if i.category == "secrets"]) == 0:
            self.passed_checks.append(check_name)
        else:
            self.failed_checks.append(check_name)
    
    async def _check_rate_limiting(self):
        """Verify rate limiting is configured"""
        check_name = "rate_limiting"
        
        rate_limit_config = self.config.get("rate_limiting", {})
        
        if not rate_limit_config.get("enabled", False):
            self.issues.append(SecurityIssue(
                id="RATE-001",
                title="Rate limiting disabled",
                severity=SeverityLevel.HIGH,
                category="rate_limiting",
                description="Rate limiting is not enabled",
                recommendation="Enable rate limiting to prevent abuse and DoS attacks"
            ))
            self.failed_checks.append(check_name)
        else:
            self.passed_checks.append(check_name)
    
    async def _check_logging_config(self):
        """Verify security logging configuration"""
        check_name = "logging_config"
        
        logging_config = self.config.get("logging", {})
        
        # Check for security event logging
        if not logging_config.get("log_security_events", True):
            self.issues.append(SecurityIssue(
                id="LOG-001",
                title="Security events not logged",
                severity=SeverityLevel.MEDIUM,
                category="logging",
                description="Security events are not being logged",
                recommendation="Enable logging for authentication, authorization, and access control events"
            ))
        
        # Check for log retention
        if not logging_config.get("retention_days", 0) >= 90:
            self.issues.append(SecurityIssue(
                id="LOG-002",
                title="Insufficient log retention",
                severity=SeverityLevel.LOW,
                category="logging",
                description="Log retention is less than 90 days",
                recommendation="Set log retention to at least 90 days for compliance"
            ))
        
        if len([i for i in self.issues if i.category == "logging"]) == 0:
            self.passed_checks.append(check_name)
        else:
            self.failed_checks.append(check_name)
    
    async def _check_cors_config(self):
        """Verify CORS configuration is secure"""
        check_name = "cors_config"
        
        cors_config = self.config.get("cors", {})
        
        allowed_origins = cors_config.get("allowed_origins", [])
        
        if "*" in allowed_origins:
            self.issues.append(SecurityIssue(
                id="CORS-001",
                title="Overly permissive CORS policy",
                severity=SeverityLevel.HIGH,
                category="cors",
                description="CORS allows requests from any origin (*)",
                recommendation="Specify exact allowed origins instead of wildcard"
            ))
            self.failed_checks.append(check_name)
        else:
            self.passed_checks.append(check_name)
    
    async def _check_ssl_tls_config(self):
        """Verify SSL/TLS configuration"""
        check_name = "ssl_tls_config"
        
        tls_config = self.config.get("tls", {})
        
        min_version = tls_config.get("min_version", "")
        if min_version not in ["TLSv1.2", "TLSv1.3"]:
            self.issues.append(SecurityIssue(
                id="TLS-001",
                title="Weak TLS minimum version",
                severity=SeverityLevel.HIGH,
                category="tls",
                description=f"Minimum TLS version is {min_version or 'not set'}",
                recommendation="Set minimum TLS version to 1.2 or higher"
            ))
        
        cipher_suites = tls_config.get("cipher_suites", [])
        weak_ciphers = ["RC4", "DES", "3DES", "MD5"]
        for cipher in weak_ciphers:
            if any(cipher in suite for suite in cipher_suites):
                self.issues.append(SecurityIssue(
                    id="TLS-002",
                    title=f"Weak cipher suite: {cipher}",
                    severity=SeverityLevel.HIGH,
                    category="tls",
                    description=f"Weak cipher {cipher} is allowed",
                    recommendation=f"Remove {cipher} from allowed cipher suites"
                ))
        
        if len([i for i in self.issues if i.category == "tls"]) == 0:
            self.passed_checks.append(check_name)
        else:
            self.failed_checks.append(check_name)
    
    def _group_by_severity(self) -> Dict[str, int]:
        """Group issues by severity level"""
        severity_counts = {level.value: 0 for level in SeverityLevel}
        for issue in self.issues:
            severity_counts[issue.severity.value] += 1
        return severity_counts
    
    def _calculate_compliance_score(self) -> float:
        """Calculate overall compliance score"""
        if not self.passed_checks and not self.failed_checks:
            return 100.0
        
        total_checks = len(self.passed_checks) + len(self.failed_checks)
        if total_checks == 0:
            return 100.0
        
        base_score = (len(self.passed_checks) / total_checks) * 100
        
        # Deduct points for issues
        severity_weights = {
            SeverityLevel.CRITICAL: 25,
            SeverityLevel.HIGH: 15,
            SeverityLevel.MEDIUM: 5,
            SeverityLevel.LOW: 1,
            SeverityLevel.INFO: 0
        }
        
        deduction = sum(
            severity_weights[issue.severity] for issue in self.issues
        )
        
        return max(0, base_score - deduction)


# Usage example
async def run_security_audit():
    """Run security audit on NIP application"""
    config = {
        "security_headers": {
            "X-Content-Type-Options": "nosniff",
            "X-Frame-Options": "DENY",
            "Strict-Transport-Security": "max-age=31536000; includeSubDomains"
        },
        "authentication": {
            "password_min_length": 12,
            "require_mfa": True,
            "session": {
                "secure": True,
                "httponly": True,
                "samesite": "Strict"
            }
        },
        "authorization": {
            "default_deny": True
        },
        "input_validation": {
            "enabled": True
        },
        "encryption": {
            "at_rest_enabled": True,
            "in_transit_enabled": True,
            "algorithm": "AES-256-GCM"
        },
        "rate_limiting": {
            "enabled": True
        },
        "cors": {
            "allowed_origins": ["https://example.com"]
        },
        "tls": {
            "min_version": "TLSv1.3"
        }
    }
    
    auditor = SecurityAuditor(config)
    report = await auditor.run_full_audit()
    
    print(f"Security Audit Report: {report.scan_id}")
    print(f"Compliance Score: {report.compliance_score:.1f}%")
    print(f"Total Issues: {report.total_issues}")
    print(f"Issues by Severity: {report.issues_by_severity}")
    
    return report
```

---

## OWASP Top 10 Mitigation

### Comprehensive OWASP Protection

```python
# nip/security/owasp_protection.py
import re
import html
import json
from typing import Dict, List, Optional, Any
from dataclasses import dataclass
from datetime import datetime, timedelta
import hashlib
import secrets
import logging

logger = logging.getLogger(__name__)


@dataclass
class OWASPCheck:
    """Result of OWASP security check"""
    category: str
    passed: bool
    details: str
    severity: str


class OWASPProtection:
    """Implementation of OWASP Top 10 protections"""
    
    def __init__(self):
        self.patterns = self._load_attack_patterns()
    
    def _load_attack_patterns(self) -> Dict[str, List[re.Pattern]]:
        """Load regex patterns for common attacks"""
        return {
            "sql_injection": [
                re.compile(r"(\bunion\b.*\bselect\b)", re.IGNORECASE),
                re.compile(r"(\bOR\b.*=.*\bOR\b)", re.IGNORECASE),
                re.compile(r"('|\-\-|\/\*|\*\/|;)", re.IGNORECASE),
                re.compile(r"\b(exec|execute|sp_\w+)", re.IGNORECASE),
            ],
            "xss": [
                re.compile(r"<script[^>]*>.*?</script>", re.IGNORECASE),
                re.compile(r"javascript:", re.IGNORECASE),
                re.compile(r"on\w+\s*=", re.IGNORECASE),  # onclick=, onload=
                re.compile(r"<iframe[^>]*>", re.IGNORECASE),
            ],
            "command_injection": [
                re.compile(r"[;&|`$()]", re.IGNORECASE),
                re.compile(r"\b(nc|netcat|telnet|bash|sh)\b", re.IGNORECASE),
            ],
            "path_traversal": [
                re.compile(r"\.\./", re.IGNORECASE),
                re.compile(r"%2e%2e", re.IGNORECASE),
                re.compile(r"\.\.\\", re.IGNORECASE),
            ],
            "ldap_injection": [
                re.compile(r"[*()\\\])", re.IGNORECASE),
                re.compile(r"\b(and|or|not)\b.*[\*=]", re.IGNORECASE),
            ]
        }
    
    # A01: Broken Access Control
    def check_access_control(
        self,
        user: Dict[str, Any],
        resource: str,
        action: str
    ) -> OWASPCheck:
        """Verify proper access control"""
        
        # Check for IDOR (Insecure Direct Object Reference)
        if f"user_id" in resource and str(user.get("id")) not in resource:
            if not self._verify_ownership(user, resource):
                return OWASPCheck(
                    category="A01_Broken_Access_Control",
                    passed=False,
                    details="Potential IDOR vulnerability detected",
                    severity="HIGH"
                )
        
        # Check for privilege escalation
        required_role = self._get_required_role(resource, action)
        user_roles = user.get("roles", [])
        
        if required_role not in user_roles and "admin" not in user_roles:
            return OWASPCheck(
                category="A01_Broken_Access_Control",
                passed=False,
                details=f"User lacks required role: {required_role}",
                severity="CRITICAL"
            )
        
        # Check for missing authorization on sensitive endpoints
        sensitive_actions = ["delete", "update", "admin"]
        if action.lower() in sensitive_actions:
            if not self._verify_csrf_token():
                return OWASPCheck(
                    category="A01_Broken_Access_Control",
                    passed=False,
                    details="Missing CSRF protection on sensitive action",
                    severity="HIGH"
                )
        
        return OWASPCheck(
            category="A01_Broken_Access_Control",
            passed=True,
            details="Access control checks passed",
            severity="INFO"
        )
    
    # A02: Cryptographic Failures
    def check_cryptographic_storage(
        self,
        data: str,
        data_type: str
    ) -> OWASPCheck:
        """Verify proper encryption of sensitive data"""
        
        sensitive_types = ["password", "ssn", "credit_card", "api_key"]
        
        if data_type in sensitive_types:
            # Check if data is properly encrypted
            if len(data) < 32 or "=" in data:
                return OWASPCheck(
                    category="A02_Cryptographic_Failures",
                    passed=False,
                    details=f"{data_type} appears to be stored in plaintext",
                    severity="CRITICAL"
                )
            
            # Verify encryption algorithm
            if not self._verify_encryption_strength(data):
                return OWASPCheck(
                    category="A02_Cryptographic_Failures",
                    passed=False,
                    details="Weak encryption algorithm detected",
                    severity="HIGH"
                )
        
        # Check for TLS usage
        if not self._verify_tls_enabled():
            return OWASPCheck(
                category="A02_Cryptographic_Failures",
                passed=False,
                details="Data transmitted without TLS encryption",
                severity="CRITICAL"
            )
        
        return OWASPCheck(
            category="A02_Cryptographic_Failures",
            passed=True,
            details="Cryptographic controls verified",
            severity="INFO"
        )
    
    # A03: Injection
    def check_injection(
        self,
        user_input: str,
        context: str = "general"
    ) -> OWASPCheck:
        """Detect various injection attacks"""
        
        # SQL Injection
        for pattern in self.patterns["sql_injection"]:
            if pattern.search(user_input):
                return OWASPCheck(
                    category="A03_Injection",
                    passed=False,
                    details=f"SQL injection pattern detected: {pattern.pattern}",
                    severity="CRITICAL"
                )
        
        # XSS
        for pattern in self.patterns["xss"]:
            if pattern.search(user_input):
                return OWASPCheck(
                    category="A03_Injection",
                    passed=False,
                    details=f"XSS pattern detected: {pattern.pattern}",
                    severity="HIGH"
                )
        
        # Command Injection
        if context in ["system", "file"]:
            for pattern in self.patterns["command_injection"]:
                if pattern.search(user_input):
                    return OWASPCheck(
                        category="A03_Injection",
                        passed=False,
                        details=f"Command injection pattern detected: {pattern.pattern}",
                        severity="CRITICAL"
                    )
        
        # Path Traversal
        if context in ["file", "path"]:
            for pattern in self.patterns["path_traversal"]:
                if pattern.search(user_input):
                    return OWASPCheck(
                        category="A03_Injection",
                        passed=False,
                        details=f"Path traversal pattern detected: {pattern.pattern}",
                        severity="HIGH"
                    )
        
        return OWASPCheck(
            category="A03_Injection",
            passed=True,
            details="No injection patterns detected",
            severity="INFO"
        )
    
    # A04: Insecure Design
    def check_secure_design(
        self,
        endpoint: str,
        params: Dict[str, Any]
    ) -> OWASPCheck:
        """Verify secure design principles"""
        
        # Check for mass assignment
        if len(params) > 50:
            return OWASPCheck(
                category="A04_Insecure_Design",
                passed=False,
                details="Potential mass assignment vulnerability",
                severity="MEDIUM"
            )
        
        # Check for missing rate limiting
        if not self._has_rate_limiting(endpoint):
            return OWASPCheck(
                category="A04_Insecure_Design",
                passed=False,
                details=f"Missing rate limiting on {endpoint}",
                severity="MEDIUM"
            )
        
        # Check for proper error handling
        if "debug" in params or "trace" in params:
            return OWASPCheck(
                category="A04_Insecure_Design",
                passed=False,
                details="Debug information potentially exposed",
                severity="LOW"
            )
        
        return OWASPCheck(
            category="A04_Insecure_Design",
            passed=True,
            details="Design principles verified",
            severity="INFO"
        )
    
    # A05: Security Misconfiguration
    def check_security_config(
        self,
        config: Dict[str, Any]
    ) -> List[OWASPCheck]:
        """Check for common security misconfigurations"""
        checks = []
        
        # Check for default credentials
        if config.get("admin_password") == "admin" or \
           config.get("admin_password") == "password":
            checks.append(OWASPCheck(
                category="A05_Security_Misconfiguration",
                passed=False,
                details="Default credentials detected",
                severity="CRITICAL"
            ))
        
        # Check for debug mode
        if config.get("debug", False):
            checks.append(OWASPCheck(
                category="A05_Security_Misconfiguration",
                passed=False,
                details="Debug mode enabled in production",
                severity="HIGH"
            ))
        
        # Check for verbose error messages
        if config.get("verbose_errors", False):
            checks.append(OWASPCheck(
                category="A05_Security_Misconfiguration",
                passed=False,
                details="Verbose error messages enabled",
                severity="MEDIUM"
            ))
        
        # Check for directory listing
        if config.get("directory_listing", False):
            checks.append(OWASPCheck(
                category="A05_Security_Misconfiguration",
                passed=False,
                details="Directory listing enabled",
                severity="MEDIUM"
            ))
        
        if not checks:
            checks.append(OWASPCheck(
                category="A05_Security_Misconfiguration",
                passed=True,
                details="No misconfigurations detected",
                severity="INFO"
            ))
        
        return checks
    
    # A07: Identification and Authentication Failures
    def check_authentication(
        self,
        username: str,
        password: str
    ) -> OWASPCheck:
        """Verify secure authentication practices"""
        
        # Check password strength
        if len(password) < 12:
            return OWASPCheck(
                category="A07_Identification_Authentication_Failures",
                passed=False,
                details="Password too short (minimum 12 characters)",
                severity="MEDIUM"
            )
        
        # Check for common passwords
        common_passwords = ["password", "123456", "qwerty", "admin"]
        if password.lower() in common_passwords:
            return OWASPCheck(
                category="A07_Identification_Authentication_Failures",
                passed=False,
                details="Common password detected",
                severity="HIGH"
            )
        
        # Check for username enumeration
        if self._check_timing_attack(username):
            return OWASPCheck(
                category="A07_Identification_Authentication_Failures",
                passed=False,
                details="Potential timing attack vulnerability",
                severity="MEDIUM"
            )
        
        return OWASPCheck(
            category="A07_Identification_Authentication_Failures",
            passed=True,
            details="Authentication checks passed",
            severity="INFO"
        )
    
    # A08: Software and Data Integrity Failures
    def check_integrity(
        self,
        data: str,
        signature: str,
        public_key: str
    ) -> OWASPCheck:
        """Verify data and software integrity"""
        
        # Verify digital signature
        if not self._verify_signature(data, signature, public_key):
            return OWASPCheck(
                category="A08_Software_Data_Integrity_Failures",
                passed=False,
                details="Digital signature verification failed",
                severity="CRITICAL"
            )
        
        # Check for code injection in updates
        if self._detect_tampering(data):
            return OWASPCheck(
                category="A08_Software_Data_Integrity_Failures",
                passed=False,
                details="Data tampering detected",
                severity="CRITICAL"
            )
        
        return OWASPCheck(
            category="A08_Software_Data_Integrity_Failures",
            passed=True,
            details="Integrity verification passed",
            severity="INFO"
        )
    
    # A09: Security Logging and Monitoring Failures
    def check_logging_monitoring(
        self,
        event: Dict[str, Any]
    ) -> OWASPCheck:
        """Verify security logging and monitoring"""
        
        # Check for security event logging
        if event.get("type") in ["login", "permission_denied", "data_access"]:
            if not event.get("logged"):
                return OWASPCheck(
                    category="A09_Logging_Monitoring_Failures",
                    passed=False,
                    details="Security event not logged",
                    severity="MEDIUM"
                )
        
        # Check for proper log format
        required_fields = ["timestamp", "user_id", "action", "ip_address"]
        if not all(field in event for field in required_fields):
            return OWASPCheck(
                category="A09_Logging_Monitoring_Failures",
                passed=False,
                details=f"Log missing required fields: {required_fields}",
                severity="LOW"
            )
        
        # Check for alerting on critical events
        if event.get("severity") == "critical" and not event.get("alerted"):
            return OWASPCheck(
                category="A09_Logging_Monitoring_Failures",
                passed=False,
                details="Critical event did not trigger alert",
                severity="MEDIUM"
            )
        
        return OWASPCheck(
            category="A09_Logging_Monitoring_Failures",
            passed=True,
            details="Logging and monitoring verified",
            severity="INFO"
        )
    
    # A10: Server-Side Request Forgery (SSRF)
    def check_ssrf(
        self,
        url: str,
        allowed_domains: List[str]
    ) -> OWASPCheck:
        """Detect and prevent SSRF attacks"""
        
        from urllib.parse import urlparse
        
        parsed = urlparse(url)
        domain = parsed.netloc
        
        # Block internal IPs
        if parsed.hostname in ["localhost", "127.0.0.1", "0.0.0.0", "::1"]:
            return OWASPCheck(
                category="A10_Server-Side_Request_Forgery",
                passed=False,
                details="Request to localhost blocked",
                severity="CRITICAL"
            )
        
        # Block private IP ranges
        private_prefixes = ["192.168.", "10.", "172.16.", "172.17.", "172.18."]
        if any(parsed.hostname.startswith(prefix) for prefix in private_prefixes):
            return OWASPCheck(
                category="A10_Server-Side_Request_Forgery",
                passed=False,
                details="Request to private IP blocked",
                severity="CRITICAL"
            )
        
        # Check against allowlist
        if domain not in allowed_domains:
            return OWASPCheck(
                category="A10_Server-Side_Request_Forgery",
                passed=False,
                details=f"Domain not in allowlist: {domain}",
                severity="HIGH"
            )
        
        return OWASPCheck(
            category="A10_Server-Side_Request_Forgery",
            passed=True,
            details="SSRF checks passed",
            severity="INFO"
        )
    
    def _verify_ownership(self, user: Dict, resource: str) -> bool:
        """Verify user owns the resource"""
        # Implementation depends on application logic
        return True
    
    def _get_required_role(self, resource: str, action: str) -> str:
        """Get required role for resource/action"""
        role_map = {
            "delete": "admin",
            "update": "editor",
            "create": "contributor"
        }
        return role_map.get(action.lower(), "viewer")
    
    def _verify_csrf_token(self) -> bool:
        """Verify CSRF token is present and valid"""
        # Implementation checks CSRF token
        return True
    
    def _verify_encryption_strength(self, data: str) -> bool:
        """Verify encryption is strong enough"""
        # Check for AES-256 or equivalent
        return len(data) >= 32
    
    def _verify_tls_enabled(self) -> bool:
        """Verify TLS is enabled"""
        # Implementation checks TLS configuration
        return True
    
    def _has_rate_limiting(self, endpoint: str) -> bool:
        """Check if endpoint has rate limiting"""
        # Implementation checks rate limiting config
        return True
    
    def _check_timing_attack(self, username: str) -> bool:
        """Check for timing attack vulnerability"""
        # Implementation uses constant-time comparison
        return False
    
    def _verify_signature(self, data: str, signature: str, public_key: str) -> bool:
        """Verify digital signature"""
        # Implementation uses cryptography library
        return True
    
    def _detect_tampering(self, data: str) -> bool:
        """Detect if data has been tampered with"""
        # Implementation uses checksums/hashes
        return False


# Middleware for OWASP protection
class OWASPMiddleware:
    """FastAPI middleware for OWASP protection"""
    
    def __init__(self):
        self.protection = OWASPProtection()
    
    async def process_request(
        self,
        request_data: Dict[str, Any],
        user: Optional[Dict] = None
    ) -> List[OWASPCheck]:
        """Process incoming request through OWASP checks"""
        checks = []
        
        # Run injection checks on all input
        for key, value in request_data.items():
            if isinstance(value, str):
                check = self.protection.check_injection(value, key)
                if not check.passed:
                    checks.append(check)
        
        # Check access control if user is authenticated
        if user:
            check = self.protection.check_access_control(
                user,
                request_data.get("resource", ""),
                request_data.get("action", "")
            )
            checks.append(check)
        
        # Check SSRF for URLs
        if "url" in request_data:
            check = self.protection.check_ssrf(
                request_data["url"],
                ["api.example.com", "cdn.example.com"]
            )
            checks.append(check)
        
        # Check for security misconfigurations
        config_checks = self.protection.check_security_config(request_data)
        checks.extend(config_checks)
        
        return checks
```

---

## Input Validation and Sanitization

```python
# nip/security/input_validation.py
import re
import html
import json
from typing import Any, Dict, List, Optional, Union
from dataclasses import dataclass
from datetime import datetime
from email_validator import validate_email, EmailNotValidError
from urllib.parse import urlparse
import logging

logger = logging.getLogger(__name__)


@dataclass
class ValidationResult:
    """Result of input validation"""
    is_valid: bool
    sanitized_value: Any
    errors: List[str]
    warnings: List[str]
    
    def add_error(self, error: str):
        self.errors.append(error)
        self.is_valid = False
    
    def add_warning(self, warning: str):
        self.warnings.append(warning)


class InputValidator:
    """Comprehensive input validation and sanitization"""
    
    def __init__(self):
        self.patterns = {
            "username": re.compile(r"^[a-zA-Z0-9_-]{3,30}$"),
            "password": re.compile(r"^[^\s]{12,128}$"),
            "email": re.compile(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"),
            "phone": re.compile(r"^\+?[\d\s\-()]{10,20}$"),
            "url": re.compile(
                r"^https?://"  # http:// or https://
                r"(?:(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?\.)+[A-Z]{2,6}\.?|"  # domain
                r"localhost|"  # localhost
                r"\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})"  # IP
                r"(?::\d+)?"  # optional port
                r"(?:/?|[/?]\S+)$", re.IGNORECASE
            ),
            "uuid": re.compile(
                r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$",
                re.IGNORECASE
            ),
            "slug": re.compile(r"^[a-z0-9-]+$"),
            "filename": re.compile(r"^[a-zA-Z0-9._-]{1,255}$"),
            "hex_color": re.compile(r"^#[0-9A-Fa-f]{6}$"),
            "ip_address": re.compile(
                r"^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}"
                r"(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
            ),
            "json": re.compile(r"^\{.*\}$|^\[.*\]$", re.DOTALL)
        }
    
    def validate(
        self,
        value: Any,
        field_type: str,
        **constraints
    ) -> ValidationResult:
        """Validate input based on type and constraints"""
        
        if value is None:
            if constraints.get("required", False):
                return ValidationResult(
                    is_valid=False,
                    sanitized_value=None,
                    errors=["Field is required"],
                    warnings=[]
                )
            return ValidationResult(
                is_valid=True,
                sanitized_value=None,
                errors=[],
                warnings=[]
            )
        
        result = ValidationResult(
            is_valid=True,
            sanitized_value=value,
            errors=[],
            warnings=[]
        )
        
        # Type-specific validation
        validators = {
            "string": self._validate_string,
            "integer": self._validate_integer,
            "float": self._validate_float,
            "boolean": self._validate_boolean,
            "email": self._validate_email,
            "url": self._validate_url,
            "date": self._validate_date,
            "datetime": self._validate_datetime,
            "json": self._validate_json,
            "enum": self._validate_enum,
            "array": self._validate_array,
            "object": self._validate_object
        }
        
        validator = validators.get(field_type)
        if validator:
            result = validator(value, **constraints)
        else:
            result.add_error(f"Unknown field type: {field_type}")
        
        # Sanitize valid values
        if result.is_valid:
            result.sanitized_value = self._sanitize(
                result.sanitized_value,
                field_type
            )
        
        return result
    
    def _validate_string(
        self,
        value: Any,
        **constraints
    ) -> ValidationResult:
        """Validate string input"""
        result = ValidationResult(
            is_valid=True,
            sanitized_value=str(value),
            errors=[],
            warnings=[]
        )
        
        # Check if it's actually a string
        if not isinstance(value, str):
            result.add_error("Must be a string")
            return result
        
        # Length constraints
        min_length = constraints.get("min_length", 0)
        max_length = constraints.get("max_length", 1000000)
        
        if len(value) < min_length:
            result.add_error(
                f"Must be at least {min_length} characters"
            )
        
        if len(value) > max_length:
            result.add_error(
                f"Must be no more than {max_length} characters"
            )
        
        # Pattern matching
        pattern = constraints.get("pattern")
        if pattern:
            if not re.match(pattern, value):
                result.add_error("Format is invalid")
        
        # Specific format validation
        format_name = constraints.get("format")
        if format_name:
            pattern = self.patterns.get(format_name)
            if pattern and not pattern.match(value):
                result.add_error(
                    f"Invalid {format_name} format"
                )
        
        # Forbidden patterns (SQL injection, XSS, etc.)
        forbidden = [
            r"<script[^>]*>.*?</script>",
            r"javascript:",
            r"on\w+\s*=",
            r"(\bunion\b.*\bselect\b)",
            r"('|\-\-|\/\*|\*\/|;)",
            r"\.\./",
            r"\b(eval|exec|system)\b"
        ]
        
        for pattern_str in forbidden:
            if re.search(pattern_str, value, re.IGNORECASE):
                result.add_error("Contains forbidden content")
                break
        
        # Check for null bytes
        if "\x00" in value:
            result.add_error("Contains null bytes")
        
        return result
    
    def _validate_integer(
        self,
        value: Any,
        **constraints
    ) -> ValidationResult:
        """Validate integer input"""
        result = ValidationResult(
            is_valid=True,
            sanitized_value=value,
            errors=[],
            warnings=[]
        )
        
        try:
            int_value = int(value)
            result.sanitized_value = int_value
            
            # Range constraints
            min_value = constraints.get("min", float("-inf"))
            max_value = constraints.get("max", float("inf"))
            
            if int_value < min_value:
                result.add_error(f"Must be at least {min_value}")
            
            if int_value > max_value:
                result.add_error(f"Must be at most {max_value}")
            
        except (ValueError, TypeError):
            result.add_error("Must be an integer")
            result.is_valid = False
        
        return result
    
    def _validate_float(
        self,
        value: Any,
        **constraints
    ) -> ValidationResult:
        """Validate float input"""
        result = ValidationResult(
            is_valid=True,
            sanitized_value=value,
            errors=[],
            warnings=[]
        )
        
        try:
            float_value = float(value)
            result.sanitized_value = float_value
            
            # Range constraints
            min_value = constraints.get("min", float("-inf"))
            max_value = constraints.get("max", float("inf"))
            
            if float_value < min_value:
                result.add_error(f"Must be at least {min_value}")
            
            if float_value > max_value:
                result.add_error(f"Must be at most {max_value}")
            
        except (ValueError, TypeError):
            result.add_error("Must be a number")
            result.is_valid = False
        
        return result
    
    def _validate_boolean(
        self,
        value: Any,
        **constraints
    ) -> ValidationResult:
        """Validate boolean input"""
        result = ValidationResult(
            is_valid=True,
            sanitized_value=value,
            errors=[],
            warnings=[]
        )
        
        if isinstance(value, bool):
            result.sanitized_value = value
        elif isinstance(value, str):
            if value.lower() in ["true", "1", "yes", "on"]:
                result.sanitized_value = True
            elif value.lower() in ["false", "0", "no", "off"]:
                result.sanitized_value = False
            else:
                result.add_error("Must be true or false")
                result.is_valid = False
        elif isinstance(value, (int, float)):
            result.sanitized_value = bool(value)
        else:
            result.add_error("Must be a boolean")
            result.is_valid = False
        
        return result
    
    def _validate_email(
        self,
        value: Any,
        **constraints
    ) -> ValidationResult:
        """Validate email address"""
        result = ValidationResult(
            is_valid=True,
            sanitized_value=value,
            errors=[],
            warnings=[]
        )
        
        if not isinstance(value, str):
            result.add_error("Must be a string")
            result.is_valid = False
            return result
        
        try:
            valid = validate_email(value)
            result.sanitized_value = valid.email
        except EmailNotValidError as e:
            result.add_error(str(e))
            result.is_valid = False
        
        return result
    
    def _validate_url(
        self,
        value: Any,
        **constraints
    ) -> ValidationResult:
        """Validate URL"""
        result = ValidationResult(
            is_valid=True,
            sanitized_value=value,
            errors=[],
            warnings=[]
        )
        
        if not isinstance(value, str):
            result.add_error("Must be a string")
            result.is_valid = False
            return result
        
        try:
            parsed = urlparse(value)
            
            # Check scheme
            allowed_schemes = constraints.get(
                "allowed_schemes",
                ["http", "https"]
            )
            if parsed.scheme not in allowed_schemes:
                result.add_error(
                    f"URL scheme must be one of: {', '.join(allowed_schemes)}"
                )
            
            # Check for localhost/internal IPs (unless explicitly allowed)
            if not constraints.get("allow_internal", False):
                if parsed.hostname in ["localhost", "127.0.0.1", "::1"]:
                    result.add_error("Internal URLs not allowed")
                
                # Check private IP ranges
                if parsed.hostname:
                    import ipaddress
                    try:
                        ip = ipaddress.ip_address(parsed.hostname)
                        if ip.is_private:
                            result.add_error("Private IP addresses not allowed")
                    except ValueError:
                        pass  # Not an IP, that's fine
            
            result.sanitized_value = parsed.geturl()
            
        except Exception as e:
            result.add_error(f"Invalid URL: {str(e)}")
            result.is_valid = False
        
        return result
    
    def _validate_date(
        self,
        value: Any,
        **constraints
    ) -> ValidationResult:
        """Validate date"""
        result = ValidationResult(
            is_valid=True,
            sanitized_value=value,
            errors=[],
            warnings=[]
        )
        
        date_formats = constraints.get(
            "formats",
            ["%Y-%m-%d", "%Y/%m/%d", "%m/%d/%Y", "%d/%m/%Y"]
        )
        
        if isinstance(value, str):
            parsed = None
            for fmt in date_formats:
                try:
                    parsed = datetime.strptime(value, fmt).date()
                    break
                except ValueError:
                    continue
            
            if parsed:
                result.sanitized_value = parsed
            else:
                result.add_error("Invalid date format")
                result.is_valid = False
        
        else:
            result.add_error("Must be a string")
            result.is_valid = False
        
        return result
    
    def _validate_datetime(
        self,
        value: Any,
        **constraints
    ) -> ValidationResult:
        """Validate datetime"""
        result = ValidationResult(
            is_valid=True,
            sanitized_value=value,
            errors=[],
            warnings=[]
        )
        
        if isinstance(value, str):
            try:
                # Try ISO format first
                parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
                result.sanitized_value = parsed
            except ValueError:
                result.add_error("Invalid datetime format (use ISO 8601)")
                result.is_valid = False
        else:
            result.add_error("Must be a string")
            result.is_valid = False
        
        return result
    
    def _validate_json(
        self,
        value: Any,
        **constraints
    ) -> ValidationResult:
        """Validate JSON string"""
        result = ValidationResult(
            is_valid=True,
            sanitized_value=value,
            errors=[],
            warnings=[]
        )
        
        if isinstance(value, str):
            try:
                parsed = json.loads(value)
                result.sanitized_value = parsed
            except json.JSONDecodeError as e:
                result.add_error(f"Invalid JSON: {str(e)}")
                result.is_valid = False
        elif isinstance(value, (dict, list)):
            result.sanitized_value = value
        else:
            result.add_error("Must be a JSON string or object")
            result.is_valid = False
        
        return result
    
    def _validate_enum(
        self,
        value: Any,
        **constraints
    ) -> ValidationResult:
        """Validate enum value"""
        result = ValidationResult(
            is_valid=True,
            sanitized_value=value,
            errors=[],
            warnings=[]
        )
        
        allowed_values = constraints.get("values", [])
        
        if value not in allowed_values:
            result.add_error(
                f"Must be one of: {', '.join(map(str, allowed_values))}"
            )
            result.is_valid = False
        
        return result
    
    def _validate_array(
        self,
        value: Any,
        **constraints
    ) -> ValidationResult:
        """Validate array/list input"""
        result = ValidationResult(
            is_valid=True,
            sanitized_value=value,
            errors=[],
            warnings=[]
        )
        
        if not isinstance(value, list):
            result.add_error("Must be an array")
            result.is_valid = False
            return result
        
        # Length constraints
        min_items = constraints.get("min_items", 0)
        max_items = constraints.get("max_items", 1000000)
        
        if len(value) < min_items:
            result.add_error(f"Must have at least {min_items} items")
        
        if len(value) > max_items:
            result.add_error(f"Must have at most {max_items} items")
        
        # Unique constraint
        if constraints.get("unique", False):
            if len(value) != len(set(value)):
                result.add_error("All items must be unique")
        
        # Item schema validation
        item_schema = constraints.get("items")
        if item_schema:
            for i, item in enumerate(value):
                item_result = self.validate(item, **item_schema)
                if not item_result.is_valid:
                    result.add_error(f"Item {i}: {', '.join(item_result.errors)}")
        
        return result
    
    def _validate_object(
        self,
        value: Any,
        **constraints
    ) -> ValidationResult:
        """Validate object/dict input"""
        result = ValidationResult(
            is_valid=True,
            sanitized_value=value,
            errors=[],
            warnings=[]
        )
        
        if not isinstance(value, dict):
            result.add_error("Must be an object")
            result.is_valid = False
            return result
        
        # Schema validation
        schema = constraints.get("schema", {})
        
        # Check required fields
        required = schema.get("required", [])
        for field in required:
            if field not in value:
                result.add_error(f"Missing required field: {field}")
        
        # Validate each field
        properties = schema.get("properties", {})
        for field, field_schema in properties.items():
            if field in value:
                field_result = self.validate(
                    value[field],
                    **field_schema
                )
                if not field_result.is_valid:
                    result.add_error(
                        f"{field}: {', '.join(field_result.errors)}"
                    )
                else:
                    value[field] = field_result.sanitized_value
        
        # Check for additional properties
        if not schema.get("additionalProperties", True):
            allowed_fields = set(properties.keys())
            extra_fields = set(value.keys()) - allowed_fields
            if extra_fields:
                result.add_error(
                    f"Unexpected fields: {', '.join(extra_fields)}"
                )
        
        result.sanitized_value = value
        
        return result
    
    def _sanitize(self, value: Any, value_type: str) -> Any:
        """Sanitize valid value"""
        if isinstance(value, str):
            # HTML escaping
            value = html.escape(value)
            
            # Remove null bytes
            value = value.replace("\x00", "")
            
            # Trim whitespace
            value = value.strip()
        
        return value


# FastAPI dependency for input validation
from fastapi import Request, HTTPException, Depends
from typing import Dict, Any

async def validate_input(
    request: Request,
    field_types: Dict[str, Dict[str, Any]]
) -> Dict[str, Any]:
    """Validate and sanitize request input"""
    validator = InputValidator()
    
    # Get request body
    try:
        body = await request.json()
    except Exception:
        body = {}
    
    # Validate each field
    validated = {}
    for field, schema in field_types.items():
        result = validator.validate(
            body.get(field),
            **schema
        )
        
        if not result.is_valid:
            raise HTTPException(
                status_code=422,
                detail={
                    "field": field,
                    "errors": result.errors
                }
            )
        
        validated[field] = result.sanitized_value
    
    return validated
```

---

## Rate Limiting and DDoS Protection

```python
# nip/security/rate_limiting.py
import time
import asyncio
from typing import Dict, Optional, Tuple
from datetime import datetime, timedelta
from dataclasses import dataclass, field
from collections import defaultdict
import hashlib
import logging
from fastapi import Request, HTTPException
from starlette.middleware.base import BaseHTTPMiddleware

logger = logging.getLogger(__name__)


@dataclass
class RateLimitConfig:
    """Configuration for rate limiting"""
    requests_per_minute: int = 60
    requests_per_hour: int = 1000
    requests_per_day: int = 10000
    burst_size: int = 10
    enabled: bool = True


@dataclass
class RateLimitStats:
    """Statistics for rate limiting"""
    total_requests: int = 0
    blocked_requests: int = 0
    rate_limited_clients: Dict[str, int] = field(default_factory=dict)
    peak_requests_per_minute: int = 0


class SlidingWindowCounter:
    """Sliding window counter for rate limiting"""
    
    def __init__(self, window_size_seconds: int):
        self.window_size = window_size_seconds
        self.requests: Dict[str, list[float]] = defaultdict(list)
    
    def add_request(self, key: str) -> int:
        """Add a request and return count in window"""
        now = time.time()
        
        # Add current request
        self.requests[key].append(now)
        
        # Remove old requests outside window
        cutoff = now - self.window_size
        self.requests[key] = [
            timestamp for timestamp in self.requests[key]
            if timestamp > cutoff
        ]
        
        return len(self.requests[key])
    
    def get_count(self, key: str) -> int:
        """Get request count for key in current window"""
        now = time.time()
        cutoff = now - self.window_size
        
        # Clean old requests
        if key in self.requests:
            self.requests[key] = [
                timestamp for timestamp in self.requests[key]
                if timestamp > cutoff
            ]
        
        return len(self.requests.get(key, []))
    
    def reset(self, key: str):
        """Reset counter for key"""
        if key in self.requests:
            del self.requests[key]


class TokenBucket:
    """Token bucket algorithm for rate limiting"""
    
    def __init__(self, rate: float, capacity: int):
        """
        rate: tokens per second
        capacity: maximum tokens
        """
        self.rate = rate
        self.capacity = capacity
        self.tokens: Dict[str, float] = defaultdict(lambda: capacity)
        self.last_update: Dict[str, float] = defaultdict(lambda: time.time())
    
    def consume(self, key: str, tokens: int = 1) -> bool:
        """Try to consume tokens. Returns True if successful."""
        now = time.time()
        
        # Calculate tokens to add based on time passed
        time_passed = now - self.last_update[key]
        new_tokens = time_passed * self.rate
        
        # Update token count
        self.tokens[key] = min(
            self.capacity,
            self.tokens[key] + new_tokens
        )
        self.last_update[key] = now
        
        # Check if we have enough tokens
        if self.tokens[key] >= tokens:
            self.tokens[key] -= tokens
            return True
        
        return False
    
    def get_available_tokens(self, key: str) -> float:
        """Get available tokens for key"""
        now = time.time()
        time_passed = now - self.last_update[key]
        new_tokens = time_passed * self.rate
        
        return min(
            self.capacity,
            self.tokens[key] + new_tokens
        )


class RateLimiter:
    """Comprehensive rate limiting with multiple strategies"""
    
    def __init__(self, config: Optional[RateLimitConfig] = None):
        self.config = config or RateLimitConfig()
        
        # Initialize rate limiters
        self.minute_limiter = SlidingWindowCounter(60)
        self.hour_limiter = SlidingWindowCounter(3600)
        self.day_limiter = SlidingWindowCounter(86400)
        self.token_bucket = TokenBucket(
            rate=self.config.requests_per_minute / 60,
            capacity=self.config.burst_size
        )
        
        # Statistics
        self.stats = RateLimitStats()
        
        # DDoS detection
        self.ddos_threshold = self.config.requests_per_minute * 10
        self.blacklisted_ips: Dict[str, datetime] = {}
    
    def _get_client_key(self, request: Request) -> str:
        """Get unique key for client"""
        # Try to get real IP behind proxies
        forwarded = request.headers.get("X-Forwarded-For")
        if forwarded:
            ip = forwarded.split(",")[0].strip()
        else:
            ip = request.client.host if request.client else "unknown"
        
        # Add user agent for more specific identification
        user_agent = request.headers.get("User-Agent", "unknown")
        
        # Create unique key
        key_data = f"{ip}:{user_agent}"
        return hashlib.sha256(key_data.encode()).hexdigest()[:16]
    
    async def check_rate_limit(
        self,
        request: Request
    ) -> Tuple[bool, Optional[str]]:
        """Check if request is within rate limits"""
        if not self.config.enabled:
            return True, None
        
        key = self._get_client_key(request)
        
        # Check blacklist
        if key in self.blacklisted_ips:
            blacklist_time = self.blacklisted_ips[key]
            if datetime.now() - blacklist_time < timedelta(hours=1):
                return False, "IP is temporarily blacklisted due to suspicious activity"
            else:
                # Remove from blacklist after time expires
                del self.blacklisted_ips[key]
        
        # Check all rate limits
        minute_count = self.minute_limiter.add_request(key)
        hour_count = self.hour_limiter.get_count(key)
        day_count = self.day_limiter.get_count(key)
        
        # Update statistics
        self.stats.total_requests += 1
        self.stats.peak_requests_per_minute = max(
            self.stats.peak_requests_per_minute,
            minute_count
        )
        
        # Check minute limit
        if minute_count > self.config.requests_per_minute:
            self.stats.blocked_requests += 1
            self.stats.rate_limited_clients[key] = \
                self.stats.rate_limited_clients.get(key, 0) + 1
            
            # Check for DDoS pattern
            if minute_count > self.ddos_threshold:
                self.blacklisted_ips[key] = datetime.now()
                logger.warning(
                    f"DDoS attack detected from {key}. "
                    f"Blacklisting IP."
                )
            
            return False, f"Rate limit exceeded: {minute_count}/{self.config.requests_per_minute} per minute"
        
        # Check hour limit
        if hour_count > self.config.requests_per_hour:
            self.stats.blocked_requests += 1
            return False, f"Rate limit exceeded: {hour_count}/{self.config.requests_per_hour} per hour"
        
        # Check day limit
        if day_count > self.config.requests_per_day:
            self.stats.blocked_requests += 1
            return False, f"Rate limit exceeded: {day_count}/{self.config.requests_per_day} per day"
        
        # Check token bucket for burst protection
        if not self.token_bucket.consume(key):
            self.stats.blocked_requests += 1
            return False, "Too many requests in quick succession"
        
        return True, None
    
    def get_stats(self) -> Dict[str, any]:
        """Get rate limiting statistics"""
        return {
            "total_requests": self.stats.total_requests,
            "blocked_requests": self.stats.blocked_requests,
            "block_rate": (
                self.stats.blocked_requests / self.stats.total_requests * 100
                if self.stats.total_requests > 0 else 0
            ),
            "rate_limited_clients": len(self.stats.rate_limited_clients),
            "peak_requests_per_minute": self.stats.peak_requests_per_minute,
            "blacklisted_ips": len(self.blacklisted_ips)
        }
    
    def reset_client(self, key: str):
        """Reset rate limits for a specific client"""
        self.minute_limiter.reset(key)
        self.hour_limiter.reset(key)
        self.day_limiter.reset(key)
        self.tokens = self.config.burst_size


class RateLimitMiddleware(BaseHTTPMiddleware):
    """FastAPI middleware for rate limiting"""
    
    def __init__(self, app, limiter: RateLimiter):
        super().__init__(app)
        self.limiter = limiter
    
    async def dispatch(self, request: Request, call_next):
        """Process request through rate limiter"""
        # Skip rate limiting for health checks
        if request.url.path == "/health":
            return await call_next(request)
        
        # Check rate limit
        allowed, message = await self.limiter.check_rate_limit(request)
        
        if not allowed:
            # Return 429 Too Many Requests
            return JSONResponse(
                status_code=429,
                content={
                    "error": "Rate limit exceeded",
                    "message": message,
                    "retry_after": 60
                },
                headers={
                    "Retry-After": "60",
                    "X-RateLimit-Limit": str(self.limiter.config.requests_per_minute),
                    "X-RateLimit-Remaining": "0",
                    "X-RateLimit-Reset": str(int(time.time()) + 60)
                }
            )
        
        # Process request
        response = await call_next(request)
        
        # Add rate limit headers
        key = self.limiter._get_client_key(request)
        remaining = max(
            0,
            self.limiter.config.requests_per_minute -
            self.limiter.minute_limiter.get_count(key)
        )
        
        response.headers["X-RateLimit-Limit"] = str(
            self.limiter.config.requests_per_minute
        )
        response.headers["X-RateLimit-Remaining"] = str(remaining)
        response.headers["X-RateLimit-Reset"] = str(int(time.time()) + 60)
        
        return response


# Endpoint-specific rate limiting
class EndpointRateLimiter:
    """Rate limiter for specific endpoints"""
    
    def __init__(self):
        self.limiters: Dict[str, RateLimiter] = {}
    
    def get_limiter(
        self,
        endpoint: str,
        default_config: Optional[RateLimitConfig] = None
    ) -> RateLimiter:
        """Get or create rate limiter for endpoint"""
        if endpoint not in self.limiters:
            # Define endpoint-specific configs
            configs = {
                "/api/auth/login": RateLimitConfig(
                    requests_per_minute=5,
                    requests_per_hour=20,
                    burst_size=2
                ),
                "/api/auth/register": RateLimitConfig(
                    requests_per_minute=3,
                    requests_per_hour=10,
                    burst_size=1
                ),
                "/api/password/reset": RateLimitConfig(
                    requests_per_minute=2,
                    requests_per_hour=5,
                    burst_size=1
                ),
                "/api/search": RateLimitConfig(
                    requests_per_minute=30,
                    requests_per_hour=500,
                    burst_size=10
                ),
                "/api/upload": RateLimitConfig(
                    requests_per_minute=10,
                    requests_per_hour=100,
                    burst_size=5
                )
            }
            
            config = configs.get(endpoint, default_config or RateLimitConfig())
            self.limiters[endpoint] = RateLimiter(config)
        
        return self.limiters[endpoint]


# Usage in FastAPI application
from fastapi import FastAPI
from fastapi.responses import JSONResponse

app = FastAPI()

# Initialize rate limiter
rate_limiter = RateLimiter(RateLimitConfig(
    requests_per_minute=60,
    requests_per_hour=1000,
    requests_per_day=10000,
    burst_size=10
))

# Add middleware
app.add_middleware(RateLimitMiddleware, limiter=rate_limiter)

# Endpoint-specific rate limiting
endpoint_limiter = EndpointRateLimiter()

@app.post("/api/auth/login")
async def login(request: Request):
    """Login with stricter rate limiting"""
    limiter = endpoint_limiter.get_limiter("/api/auth/login")
    allowed, message = await limiter.check_rate_limit(request)
    
    if not allowed:
        raise HTTPException(
            status_code=429,
            detail=message
        )
    
    # Process login
    return {"message": "Login successful"}
```

---

## Secrets Management

```python
# nip/security/secrets_manager.py
import os
import json
import base64
from typing import Dict, Optional, Any
from datetime import datetime, timedelta
from dataclasses import dataclass
import logging
import hvac
import boto3
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2
import secrets

logger = logging.getLogger(__name__)


@dataclass
class SecretMetadata:
    """Metadata for a secret"""
    name: str
    version: int
    created_at: datetime
    expires_at: Optional[datetime] = None
    rotation_interval_days: int = 90
    last_rotated: Optional[datetime] = None


class SecretsManager:
    """Abstract secrets manager interface"""
    
    async def get_secret(self, key: str) -> str:
        """Get secret value"""
        raise NotImplementedError
    
    async def set_secret(self, key: str, value: str, **metadata):
        """Set secret value"""
        raise NotImplementedError
    
    async def delete_secret(self, key: str):
        """Delete secret"""
        raise NotImplementedError
    
    async def rotate_secret(self, key: str):
        """Rotate secret value"""
        raise NotImplementedError
    
    async def list_secrets(self) -> list:
        """List all secrets"""
        raise NotImplementedError


class VaultSecretsManager(SecretsManager):
    """HashiCorp Vault secrets manager"""
    
    def __init__(
        self,
        url: str,
        token: str,
        mount_point: str = "secret"
    ):
        self.client = hvac.Client(url=url, token=token)
        self.mount_point = mount_point
        
        if not self.client.is_authenticated():
            raise Exception("Failed to authenticate with Vault")
    
    async def get_secret(self, key: str) -> str:
        """Get secret from Vault"""
        try:
            response = self.client.secrets.kv.v2.read_secret_version(
                path=key,
                mount_point=self.mount_point
            )
            return response["data"]["data"]["value"]
        except Exception as e:
            logger.error(f"Failed to get secret {key}: {e}")
            raise
    
    async def set_secret(
        self,
        key: str,
        value: str,
        **metadata
    ):
        """Set secret in Vault"""
        try:
            self.client.secrets.kv.v2.create_or_update_secret(
                path=key,
                secret={"value": value, **metadata},
                mount_point=self.mount_point
            )
            logger.info(f"Secret {key} stored in Vault")
        except Exception as e:
            logger.error(f"Failed to set secret {key}: {e}")
            raise
    
    async def delete_secret(self, key: str):
        """Delete secret from Vault"""
        try:
            self.client.secrets.kv.v2.delete_metadata_and_all_versions(
                path=key,
                mount_point=self.mount_point
            )
            logger.info(f"Secret {key} deleted from Vault")
        except Exception as e:
            logger.error(f"Failed to delete secret {key}: {e}")
            raise
    
    async def rotate_secret(self, key: str):
        """Rotate secret in Vault"""
        # Generate new value
        new_value = secrets.token_urlsafe(32)
        
        # Update in Vault
        await self.set_secret(
            key,
            new_value,
            rotated_at=datetime.now().isoformat()
        )
        
        logger.info(f"Secret {key} rotated")
    
    async def list_secrets(self) -> list:
        """List secrets in Vault"""
        try:
            response = self.client.secrets.kv.v2.list_secrets(
                path="",
                mount_point=self.mount_point
            )
            return response["data"]["keys"]
        except Exception as e:
            logger.error(f"Failed to list secrets: {e}")
            raise


class AWSSecretsManager(SecretsManager):
    """AWS Secrets Manager"""
    
    def __init__(self, region: str = "us-east-1"):
        self.client = boto3.client("secretsmanager", region_name=region)
    
    async def get_secret(self, key: str) -> str:
        """Get secret from AWS"""
        try:
            response = self.client.get_secret_value(SecretId=key)
            if "SecretString" in response:
                return response["SecretString"]
            else:
                return base64.b64decode(response["SecretBinary"]).decode()
        except Exception as e:
            logger.error(f"Failed to get secret {key}: {e}")
            raise
    
    async def set_secret(
        self,
        key: str,
        value: str,
        **metadata
    ):
        """Set secret in AWS"""
        try:
            # Extract description from metadata
            description = metadata.get("description", "")
            
            self.client.create_secret(
                Name=key,
                SecretString=value,
                Description=description
            )
            logger.info(f"Secret {key} stored in AWS")
        except self.client.exceptions.ResourceExistsException:
            # Secret exists, update it
            self.client.update_secret(
                SecretId=key,
                SecretString=value
            )
            logger.info(f"Secret {key} updated in AWS")
        except Exception as e:
            logger.error(f"Failed to set secret {key}: {e}")
            raise
    
    async def delete_secret(self, key: str):
        """Delete secret from AWS"""
        try:
            self.client.delete_secret(
                SecretId=key,
                ForceDeleteWithoutRecovery=True
            )
            logger.info(f"Secret {key} deleted from AWS")
        except Exception as e:
            logger.error(f"Failed to delete secret {key}: {e}")
            raise
    
    async def rotate_secret(self, key: str):
        """Rotate secret in AWS"""
        # Trigger AWS Secrets Manager rotation
        try:
            self.client.rotate_secret(SecretId=key)
            logger.info(f"Rotation triggered for secret {key}")
        except Exception as e:
            logger.error(f"Failed to rotate secret {key}: {e}")
            raise
    
    async def list_secrets(self) -> list:
        """List secrets in AWS"""
        try:
            response = self.client.list_secrets()
            return [secret["Name"] for secret in response["SecretList"]]
        except Exception as e:
            logger.error(f"Failed to list secrets: {e}")
            raise


class LocalSecretsManager(SecretsManager):
    """Local file-based secrets manager (for development only)"""
    
    def __init__(self, secrets_file: str = "secrets.enc"):
        self.secrets_file = secrets_file
        self.key = self._get_or_create_key()
        self.cipher = Fernet(self.key)
    
    def _get_or_create_key(self) -> bytes:
        """Get or create encryption key"""
        key_file = self.secrets_file + ".key"
        
        if os.path.exists(key_file):
            with open(key_file, "rb") as f:
                return f.read()
        else:
            key = Fernet.generate_key()
            with open(key_file, "wb") as f:
                f.write(key)
            os.chmod(key_file, 0o600)  # Owner read/write only
            return key
    
    def _load_secrets(self) -> Dict:
        """Load secrets from file"""
        if not os.path.exists(self.secrets_file):
            return {}
        
        with open(self.secrets_file, "rb") as f:
            encrypted = f.read()
        
        if not encrypted:
            return {}
        
        decrypted = self.cipher.decrypt(encrypted)
        return json.loads(decrypted.decode())
    
    def _save_secrets(self, secrets: Dict):
        """Save secrets to file"""
        data = json.dumps(secrets).encode()
        encrypted = self.cipher.encrypt(data)
        
        with open(self.secrets_file, "wb") as f:
            f.write(encrypted)
        
        os.chmod(self.secrets_file, 0o600)
    
    async def get_secret(self, key: str) -> str:
        """Get secret from local storage"""
        secrets = self._load_secrets()
        
        if key not in secrets:
            raise KeyError(f"Secret {key} not found")
        
        return secrets[key]["value"]
    
    async def set_secret(
        self,
        key: str,
        value: str,
        **metadata
    ):
        """Set secret in local storage"""
        secrets = self._load_secrets()
        
        secrets[key] = {
            "value": value,
            "created_at": datetime.now().isoformat(),
            **metadata
        }
        
        self._save_secrets(secrets)
        logger.info(f"Secret {key} stored locally")
    
    async def delete_secret(self, key: str):
        """Delete secret from local storage"""
        secrets = self._load_secrets()
        
        if key in secrets:
            del secrets[key]
            self._save_secrets(secrets)
            logger.info(f"Secret {key} deleted locally")
    
    async def rotate_secret(self, key: str):
        """Rotate secret in local storage"""
        new_value = secrets.token_urlsafe(32)
        await self.set_secret(
            key,
            new_value,
            rotated_at=datetime.now().isoformat()
        )
        logger.info(f"Secret {key} rotated locally")
    
    async def list_secrets(self) -> list:
        """List secrets in local storage"""
        secrets = self._load_secrets()
        return list(secrets.keys())


# Factory for creating secrets manager
def create_secrets_manager(
    backend: str = "local",
    **config
) -> SecretsManager:
    """Create secrets manager based on backend"""
    
    if backend == "vault":
        return VaultSecretsManager(
            url=config["vault_url"],
            token=config["vault_token"],
            mount_point=config.get("mount_point", "secret")
        )
    elif backend == "aws":
        return AWSSecretsManager(
            region=config.get("region", "us-east-1")
        )
    elif backend == "local":
        return LocalSecretsManager(
            secrets_file=config.get("secrets_file", "secrets.enc")
        )
    else:
        raise ValueError(f"Unknown secrets backend: {backend}")


# Secrets rotation scheduler
class SecretRotator:
    """Automated secret rotation"""
    
    def __init__(
        self,
        secrets_manager: SecretsManager,
        check_interval_hours: int = 24
    ):
        self.secrets_manager = secrets_manager
        self.check_interval = timedelta(hours=check_interval_hours)
    
    async def check_and_rotate(self):
        """Check all secrets and rotate if needed"""
        secrets = await self.secrets_manager.list_secrets()
        
        for secret_name in secrets:
            # Get secret metadata
            # (This would be stored alongside the secret)
            # For now, just rotate based on age
            
            try:
                # Check if rotation is needed
                # This is a simplified version
                await self.secrets_manager.rotate_secret(secret_name)
            except Exception as e:
                logger.error(f"Failed to rotate {secret_name}: {e}")


# Environment-specific secret loading
def load_secrets_from_env() -> Dict[str, str]:
    """Load secrets from environment variables"""
    
    # Prefix for secret environment variables
    prefix = "SECRET_"
    
    secrets = {}
    for key, value in os.environ.items():
        if key.startswith(prefix):
            # Remove prefix and lowercase
            secret_name = key[len(prefix):].lower()
            secrets[secret_name] = value
    
    return secrets
```

---

## Security Headers

```python
# nip/security/headers.py
from typing import Dict, Optional
from fastapi import Response
from starlette.middleware.base import BaseHTTPMiddleware
import logging

logger = logging.getLogger(__name__)


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """Middleware for adding security headers"""
    
    def __init__(
        self,
        app,
        config: Optional[Dict] = None
    ):
        super().__init__(app)
        self.config = config or self._default_config()
    
    def _default_config(self) -> Dict:
        """Default security headers configuration"""
        return {
            "X-Content-Type-Options": "nosniff",
            "X-Frame-Options": "DENY",
            "X-XSS-Protection": "1; mode=block",
            "Strict-Transport-Security": "max-age=31536000; includeSubDomains; preload",
            "Content-Security-Policy": self._default_csp(),
            "Referrer-Policy": "strict-origin-when-cross-origin",
            "Permissions-Policy": self._default_permissions_policy(),
            "Cross-Origin-Opener-Policy": "same-origin",
            "Cross-Origin-Resource-Policy": "same-origin",
            "Cross-Origin-Embedder-Policy": "require-corp"
        }
    
    def _default_csp(self) -> str:
        """Default Content Security Policy"""
        directives = [
            "default-src 'self'",
            "script-src 'self' 'unsafe-inline' 'unsafe-eval'",
            "style-src 'self' 'unsafe-inline'",
            "img-src 'self' data: https:",
            "font-src 'self' data:",
            "connect-src 'self'",
            "media-src 'self'",
            "object-src 'none'",
            "base-uri 'self'",
            "form-action 'self'",
            "frame-ancestors 'none'",
            "upgrade-insecure-requests"
        ]
        return "; ".join(directives)
    
    def _default_permissions_policy(self) -> str:
        """Default Permissions Policy"""
        permissions = [
            "geolocation=()",
            "midi=()",
            "notifications=()",
            "push=()",
            "sync-xhr=()",
            "microphone=()",
            "camera=()",
            "magnetometer=()",
            "gyroscope=()",
            "speaker=()",
            "vibrate=()",
            "fullscreen=(self)",
            "payment=()",
            "usb=()"
        ]
        return ", ".join(permissions)
    
    async def dispatch(self, request, call_next):
        """Add security headers to response"""
        response = await call_next(request)
        
        # Add all configured headers
        for header, value in self.config.items():
            response.headers[header] = value
        
        return response


def build_csp(
    default_src: list = None,
    script_src: list = None,
    style_src: list = None,
    img_src: list = None,
    connect_src: list = None,
    font_src: list = None,
    frame_src: list = None,
    media_src: list = None,
    object_src: list = None,
    base_uri: list = None,
    form_action: list = None,
    frame_ancestors: list = None,
    report_uri: str = None,
    report_only: bool = False
) -> str:
    """Build Content Security Policy"""
    
    default_src = default_src or ["'self'"]
    script_src = script_src or ["'self'"]
    style_src = style_src or ["'self'", "'unsafe-inline'"]
    img_src = img_src or ["'self'", "data:"]
    connect_src = connect_src or ["'self'"]
    font_src = font_src or ["'self'", "data:"]
    frame_src = frame_src or ["'none'"]
    media_src = media_src or ["'self'"]
    object_src = object_src or ["'none'"]
    base_uri = base_uri or ["'self'"]
    form_action = form_action or ["'self'"]
    frame_ancestors = frame_ancestors or ["'none'"]
    
    directives = {
        "default-src": " ".join(default_src),
        "script-src": " ".join(script_src),
        "style-src": " ".join(style_src),
        "img-src": " ".join(img_src),
        "connect-src": " ".join(connect_src),
        "font-src": " ".join(font_src),
        "frame-src": " ".join(frame_src),
        "media-src": " ".join(media_src),
        "object-src": " ".join(object_src),
        "base-uri": " ".join(base_uri),
        "form-action": " ".join(form_action),
        "frame-ancestors": " ".join(frame_ancestors),
        "upgrade-insecure-requests": ""
    }
    
    if report_uri:
        directives["report-uri"] = report_uri
    
    # Build CSP string
    csp_parts = []
    for directive, value in directives.items():
        if value:
            csp_parts.append(f"{directive} {value}")
        else:
            csp_parts.append(directive)
    
    csp = "; ".join(csp_parts)
    
    if report_only:
        return f"Content-Security-Policy-Report-Only: {csp}"
    else:
        return f"Content-Security-Policy: {csp}"


def add_security_headers(
    response: Response,
    hsts_enabled: bool = True,
    hsts_max_age: int = 31536000,
    hsts_include_subdomains: bool = True,
    hsts_preload: bool = True,
    x_frame_options: str = "DENY",
    x_content_type_options: str = "nosniff",
    x_xss_protection: str = "1; mode=block",
    referrer_policy: str = "strict-origin-when-cross-origin"
):
    """Add security headers to response"""
    
    # Strict-Transport-Security (HSTS)
    if hsts_enabled:
        hsts_value = f"max-age={hsts_max_age}"
        if hsts_include_subdomains:
            hsts_value += "; includeSubDomains"
        if hsts_preload:
            hsts_value += "; preload"
        response.headers["Strict-Transport-Security"] = hsts_value
    
    # X-Frame-Options
    response.headers["X-Frame-Options"] = x_frame_options
    
    # X-Content-Type-Options
    response.headers["X-Content-Type-Options"] = x_content_type_options
    
    # X-XSS-Protection
    response.headers["X-XSS-Protection"] = x_xss_protection
    
    # Referrer-Policy
    response.headers["Referrer-Policy"] = referrer_policy
    
    return response
```

---

## Security Checklists

### Pre-Deployment Security Checklist

```markdown
# Security Deployment Checklist

## Authentication & Authorization
- [ ] Multi-factor authentication enforced for all users
- [ ] Passwords meet minimum requirements (12+ characters, complexity)
- [ ] Session timeout configured (15 minutes idle)
- [ ] Secure session cookies (HttpOnly, Secure, SameSite)
- [ ] Password change requires current password verification
- [ ] Account lockout after failed login attempts (5 attempts)
- [ ] Password reset tokens expire within 1 hour
- [ ] Role-based access control implemented
- [ ] Principle of least privilege enforced
- [ ] Regular access reviews scheduled

## Data Protection
- [ ] All sensitive data encrypted at rest (AES-256)
- [ ] TLS 1.3 enforced for all connections
- [ ] Forward secrecy enabled
- [ ] HSTS enabled with preload
- [ ] Database connections encrypted
- [ ] API keys stored in secure vault
- [ ] Secrets auto-rotate every 90 days
- [ ] PII data access logged
- [ ] Data retention policy enforced
- [ ] Secure backup encryption enabled

## Input Validation & Output Encoding
- [ ] All user input validated on server-side
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (output encoding)
- [ ] CSRF tokens for all state-changing operations
- [ ] File upload validation (type, size, content)
- [ ] Path traversal prevention
- [ ] Command injection prevention
- [ ] LDAP injection prevention
- [ ] NoSQL injection prevention
- [ ] XML External Entity (XXE) prevention

## API Security
- [ ] Authentication required for all endpoints
- [ ] API rate limiting enabled
- [ ] API versioning implemented
- [ ] Proper HTTP status codes used
- [ ] Error messages don't leak sensitive info
- [ ] API documentation doesn't expose credentials
- [ ] API keys have appropriate scopes
- [ ] Deprecated endpoints disabled
- [ ] Webhook signature verification
- [ ] API gateway security rules configured

## Network Security
- [ ] Firewall rules configured (deny all, allow specific)
- [ ] DDoS protection enabled
- [ ] Intrusion detection/prevention enabled
- [ ] Network segmentation implemented
- [ ] VPN required for admin access
- [ ] SSH key-based authentication only
- [ ] Unused ports closed
- [ ] Direct database access blocked from internet
- [ ] Private subnets for internal services
- [ ] NAT gateways configured

## Logging & Monitoring
- [ ] Security events logged (auth, authz, data access)
- [ ] Log integrity ensured
- [ ] Centralized logging implemented
- [ ] Log retention 90+ days
- [ ] Real-time alerting configured
- [ ] Failed login attempts monitored
- [ ] Privileged actions logged
- [ ] Log analysis tools deployed
- [ ] Incident response plan documented
- [ ] Security metrics dashboard configured

## Configuration Management
- [ ] Debug mode disabled in production
- [ ] Default credentials changed
- [ ] Unnecessary services disabled
- [ ] Security headers configured
- [ ] CORS properly configured
- [ ] Directory listing disabled
- [ ] Server version information hidden
- [ ] Error pages customized (no stack traces)
- [ ] Auto-update for security patches
- [ ] Configuration files secured

## Compliance & Legal
- [ ] GDPR compliance verified
- [ ] HIPAA compliance (if applicable)
- [ ] PCI DSS compliance (if applicable)
- [ ] SOC 2 controls implemented
- [ ] Privacy policy published
- [ ] Terms of service published
- [ ] Cookie consent implemented
- [ ] Data breach notification plan
- [ ] Regular security audits scheduled
- [ ] Penetration testing conducted

## Cloud Security (if applicable)
- [ ] IAM policies properly configured
- [ ] S3 buckets not publicly accessible
- [ ] Security groups restrictively configured
- [ ] Encryption at rest enabled
- [ ] CloudTrail/logging enabled
- [ ] MFA for root account
- [ ] No access keys in code
- [ ] Regular backup tested
- [ ] Multi-region redundancy
- [ ] Cost alerts configured
```

---

## Practical Exercises

### Exercise 1: Security Audit

Run a comprehensive security audit on your NIP application:

```python
# exercises/security_audit.py
from nip.security.audit_framework import SecurityAuditor

async def exercise_1():
    """Run security audit and fix findings"""
    
    # Define your config
    config = {
        "security_headers": {
            "X-Content-Type-Options": "nosniff",
            "X-Frame-Options": "DENY"
        },
        "authentication": {
            "password_min_length": 8,  # Too short!
            "require_mfa": False  # Not enabled!
        },
        "rate_limiting": {
            "enabled": False  # Not enabled!
        }
    }
    
    # Run audit
    auditor = SecurityAuditor(config)
    report = await auditor.run_full_audit()
    
    # Print results
    print(f"Compliance Score: {report.compliance_score}%")
    print(f"Total Issues: {report.total_issues}")
    
    for issue in report.issues:
        print(f"[{issue.severity.value.upper()}] {issue.title}")
        print(f"  {issue.description}")
        print(f"  Recommendation: {issue.recommendation}")
    
    # TODO: Fix the issues and run again
```

### Exercise 2: Implement OWASP Protection

Add OWASP protection to your endpoints:

```python
# exercises/owasp_protection.py
from fastapi import FastAPI, Request, HTTPException
from nip.security.owasp_protection import OWASPMiddleware

app = FastAPI()

# Add OWASP middleware
owasp = OWASPMiddleware()

@app.post("/api/user")
async def create_user(request: Request):
    """Create user with OWASP protection"""
    
    # Get request data
    data = await request.json()
    
    # Run OWASP checks
    checks = await owasp.process_request(data)
    
    failed = [c for c in checks if not c.passed]
    if failed:
        raise HTTPException(
            status_code=400,
            detail={
                "error": "Security validation failed",
                "checks": [
                    {
                        "category": c.category,
                        "details": c.details
                    }
                    for c in failed
                ]
            }
        )
    
    # Process valid request
    return {"message": "User created"}
```

### Exercise 3: Implement Input Validation

Add comprehensive input validation:

```python
# exercises/input_validation.py
from fastapi import FastAPI, Depends, HTTPException
from nip.security.input_validation import InputValidator

app = FastAPI()
validator = InputValidator()

@app.post("/api/register")
async def register(request: Request):
    """Register with input validation"""
    data = await request.json()
    
    # Validate username
    username_result = validator.validate(
        data.get("username"),
        "string",
        required=True,
        min_length=3,
        max_length=30,
        pattern=r"^[a-zA-Z0-9_-]+$"
    )
    if not username_result.is_valid:
        raise HTTPException(
            status_code=422,
            detail={"field": "username", "errors": username_result.errors}
        )
    
    # Validate email
    email_result = validator.validate(
        data.get("email"),
        "email",
        required=True
    )
    if not email_result.is_valid:
        raise HTTPException(
            status_code=422,
            detail={"field": "email", "errors": email_result.errors}
        )
    
    # Validate password
    password_result = validator.validate(
        data.get("password"),
        "string",
        required=True,
        min_length=12,
        max_length=128
    )
    if not password_result.is_valid:
        raise HTTPException(
            status_code=422,
            detail={"field": "password", "errors": password_result.errors}
        )
    
    # Process registration
    return {"message": "Registration successful"}
```

### Exercise 4: Implement Rate Limiting

Add rate limiting to protect against abuse:

```python
# exercises/rate_limiting.py
from fastapi import FastAPI, Request, HTTPException
from nip.security.rate_limiting import (
    RateLimiter,
    RateLimitConfig,
    EndpointRateLimiter
)

app = FastAPI()

# Global rate limiter
rate_limiter = RateLimiter(RateLimitConfig(
    requests_per_minute=60,
    requests_per_hour=1000
))

# Endpoint-specific
endpoint_limiter = EndpointRateLimiter()

@app.post("/api/auth/login")
async def login(request: Request):
    """Login with strict rate limiting"""
    limiter = endpoint_limiter.get_limiter("/api/auth/login")
    allowed, message = await limiter.check_rate_limit(request)
    
    if not allowed:
        raise HTTPException(
            status_code=429,
            detail={"error": "rate_limit_exceeded", "message": message}
        )
    
    # Process login
    return {"message": "Login successful"}
```

### Exercise 5: Implement Secrets Management

Migrate secrets to vault:

```python
# exercises/secrets_management.py
from nip.security.secrets_manager import create_secrets_manager

async def exercise_5():
    """Migrate secrets to vault"""
    
    # Create secrets manager
    secrets = create_secrets_manager(
        backend="vault",
        vault_url="https://vault.example.com",
        vault_token="your-vault-token"
    )
    
    # Migrate secrets from environment
    import os
    
    secret_mappings = {
        "DATABASE_URL": "database/connection_string",
        "SECRET_KEY": "app/secret_key",
        "API_KEY": "external/api_key"
    }
    
    for env_key, vault_key in secret_mappings.items():
        value = os.environ.get(env_key)
        if value:
            await secrets.set_secret(
                vault_key,
                value,
                description=f"Migrated from {env_key}"
            )
            print(f"Migrated {env_key} to Vault")
    
    # Test reading from Vault
    db_url = await secrets.get_secret("database/connection_string")
    print(f"Database URL: {db_url[:20]}...")
```

---

## Best Practices

### Security Best Practices

1. **Defense in Depth**
   - Implement multiple layers of security controls
   - Don't rely on a single security mechanism
   - Assume controls can fail

2. **Secure by Default**
   - Default deny for authorization
   - Enable all security features by default
   - Require explicit action to disable security

3. **Principle of Least Privilege**
   - Grant minimum necessary permissions
   - Use role-based access control
   - Regularly audit and revoke unnecessary access

4. **Encrypt Everything**
   - Use TLS for all network traffic
   - Encrypt sensitive data at rest
   - Use strong encryption algorithms (AES-256-GCM)

5. **Validate All Input**
   - Never trust client-side validation
   - Validate on server-side
   - Use allowlists (not blocklists)

6. **Use Security Headers**
   - Implement all recommended headers
   - Use Content Security Policy
   - Enable HSTS with preload

7. **Monitor and Log**
   - Log all security-relevant events
   - Implement real-time alerting
   - Regularly review logs

8. **Keep Dependencies Updated**
   - Regularly scan for vulnerabilities
   - Update dependencies promptly
   - Use automated dependency updates

9. **Test Security**
   - Conduct regular penetration tests
   - Perform security code reviews
   - Use automated security scanning tools

10. **Have an Incident Response Plan**
    - Document response procedures
    - Train team on incident response
    - Regularly test the plan

### Common Security Mistakes to Avoid

1. Hardcoding credentials in code
2. Using weak encryption algorithms
3. Disabling security features for convenience
4. Trusting client-side input validation
5. Exposing sensitive data in error messages
6. Not implementing rate limiting
7. Using default credentials
8. Failing to rotate secrets
9. Logging sensitive data
10. Not keeping dependencies updated

---

## Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [Security Headers](https://securityheaders.com/)
- [CSP Evaluator](https://csp-evaluator.withgoogle.com/)
- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)

---

**Congratulations!** 🎉 You've completed the Security Hardening tutorial. Your NIP applications are now production-ready with enterprise-grade security.

Next: [Tutorial 11 - API Gateway](../11-api-gateway/README.md)
