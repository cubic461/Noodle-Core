"""
Test Suite::Noodle Core - test_penetration_testing.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleCore Penetration Testing Framework Test Suite

Comprehensive test suite for the penetration testing framework.
Tests all vulnerability scanners, authentication bypass techniques,
rate limiting bypass methods, and integration with existing security components.
"""

import os
import sys
import json
import asyncio
import unittest
import tempfile
import shutil
from unittest.mock import Mock, patch, AsyncMock
from datetime import datetime
import uuid

# Add the project root to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.security.penetration_testing import (
    PenetrationTestingFramework,
    SQLInjectionScanner,
    XSSScanner,
    PortScanner,
    AuthenticationBypassTester,
    RateLimitBypassTester,
    SecurityHeaderValidator,
    Vulnerability,
    VulnerabilityType,
    VulnerabilitySeverity,
    create_penetration_testing_framework
)
from noodlecore.security.audit_logger import AuditLogger, EventType, AuditLevel
from noodlecore.database.database_manager import get_database_manager, DatabaseManager
from noodlecore.database.connection_pool import DatabaseConnectionPool


class TestPenetrationTestingFramework(unittest.TestCase):
    """Test cases for penetration testing framework"""
    
    def setUp(self):
        """Set up test environment"""
        self.temp_dir = tempfile.mkdtemp()
        self.config_path = os.path.join(self.temp_dir, 'test_config.json')
        
        # Create test configuration
        self.test_config = {
            "penetration_testing": {
                "enabled": True,
                "environment": "testing",
                "target_host": "127.0.0.1",
                "target_port": 8080,
                "target_base_url": "http://127.0.0.1:8080",
                "max_concurrent_requests": 10,
                "request_timeout": 30,
                "retry_attempts": 3,
                "delay_between_requests": 0.1,
                
                "vulnerability_scanning": {
                    "sql_injection": {
                        "enabled": True,
                        "payloads": ["' OR '1'='1", "admin'--"],
                        "endpoints": ["/api/auth/login", "/api/users"]
                    },
                    "xss": {
                        "enabled": True,
                        "payloads": ["<script>alert('XSS')</script>"],
                        "endpoints": ["/api/search", "/api/comments"]
                    }
                },
                
                "network_security": {
                    "port_scanning": {
                        "enabled": True,
                        "common_ports": [80, 443, 8080],
                        "scan_range": "127.0.0.1/32",
                        "timeout": 5
                    }
                },
                
                "authentication_testing": {
                    "enabled": True,
                    "bypass_attempts": {
                        "sql_injection": True,
                        "no_auth": True,
                        "weak_tokens": True,
                        "brute_force": {
                            "enabled": True,
                            "common_usernames": ["admin", "test"],
                            "common_passwords": ["password", "123456"],
                            "max_attempts": 10
                        }
                    }
                },
                
                "rate_limiting": {
                    "enabled": True,
                    "bypass_attempts": {
                        "request_bursting": True,
                        "header_manipulation": True,
                        "ip_rotation": True
                    },
                    "test_endpoints": ["/api/auth/login", "/api/data"]
                },
                
                "security_headers": {
                    "enabled": True,
                    "required_headers": [
                        "X-Frame-Options",
                        "X-Content-Type-Options",
                        "Strict-Transport-Security"
                    ],
                    "test_endpoints": ["/", "/api/"]
                },
                
                "database": {
                    "store_results": True,
                    "table_name": "test_penetration_results",
                    "retention_days": 90
                },
                
                "logging": {
                    "level": "INFO",
                    "file_path": os.path.join(self.temp_dir, "test.log")
                }
            }
        }
        
        with open(self.config_path, 'w') as f:
            json.dump(self.test_config, f)
        
        # Mock database manager
        self.mock_db_manager = Mock(spec=DatabaseManager)
        self.mock_db_manager.table_exists.return_value = False
        self.mock_db_manager.create_table.return_value = None
        self.mock_db_manager.insert.return_value = None
        self.mock_db_manager.select.return_value = []
        
        # Mock audit logger
        self.mock_audit_logger = Mock(spec=AuditLogger)
        self.mock_audit_logger.log_event = AsyncMock()
        
        # Initialize framework
        self.framework = PenetrationTestingFramework(
            config_path=self.config_path,
            database_manager=self.mock_db_manager,
            audit_logger=self.mock_audit_logger
        )
    
    def tearDown(self):
        """Clean up test environment"""
        if os.path.exists(self.temp_dir):
            shutil.rmtree(self.temp_dir)
    
    def test_framework_initialization(self):
        """Test framework initialization"""
        # Test that framework initializes correctly
        self.assertIsNotNone(self.framework)
        self.assertEqual(self.framework.config.get('target_host'), '127.0.0.1')
        self.assertEqual(self.framework.config.get('target_port'), 8080)
        
        # Test that scanners are initialized
        self.assertIsNotNone(self.framework.sql_scanner)
        self.assertIsNotNone(self.framework.xss_scanner)
        self.assertIsNotNone(self.framework.port_scanner)
        self.assertIsNotNone(self.framework.auth_tester)
        self.assertIsNotNone(self.framework.rate_limit_tester)
        self.assertIsNotNone(self.framework.header_validator)
    
    def test_sql_injection_scanner(self):
        """Test SQL injection scanner"""
        scanner = self.framework.sql_scanner
        
        # Test scanner properties
        self.assertIn("' OR '1'='1", scanner.payloads)
        self.assertIn("/api/auth/login", scanner.endpoints)
        
        # Mock HTTP response
        with patch('requests.get') as mock_get:
            mock_response = Mock()
            mock_response.status_code = 200
            mock_response.text = "SQL syntax error near 'OR'"
            mock_response.elapsed.total_seconds.return_value = 0.5
            mock_get.return_value = mock_response
            
            # Run scan
            vulnerabilities = asyncio.run(scanner.scan("http://127.0.0.1:8080", max_requests=5))
            
            # Should detect SQL injection
            self.assertGreater(len(vulnerabilities), 0)
            
            # Check vulnerability properties
            vuln = vulnerabilities[0]
            self.assertEqual(vuln.type, VulnerabilityType.SQL_INJECTION)
            self.assertEqual(vuln.severity, VulnerabilitySeverity.HIGH)
            self.assertIn("SQL Injection", vuln.title)
            self.assertEqual(vuln.endpoint, "/api/auth/login")
            self.assertEqual(vuln.payload, "' OR '1'='1")
    
    def test_xss_scanner(self):
        """Test XSS scanner"""
        scanner = self.framework.xss_scanner
        
        # Test scanner properties
        self.assertIn("<script>alert('XSS')</script>", scanner.payloads)
        self.assertIn("/api/search", scanner.endpoints)
        
        # Mock HTTP response with reflected XSS
        with patch('requests.get') as mock_get:
            mock_response = Mock()
            mock_response.status_code = 200
            mock_response.text = "Search results for: <script>alert('XSS')</script>"
            mock_get.return_value = mock_response
            
            # Run scan
            vulnerabilities = asyncio.run(scanner.scan("http://127.0.0.1:8080", max_requests=5))
            
            # Should detect XSS
            self.assertGreater(len(vulnerabilities), 0)
            
            # Check vulnerability properties
            vuln = vulnerabilities[0]
            self.assertEqual(vuln.type, VulnerabilityType.XSS)
            self.assertEqual(vuln.severity, VulnerabilitySeverity.HIGH)
            self.assertIn("XSS", vuln.title)
            self.assertEqual(vuln.endpoint, "/api/search")
            self.assertEqual(vuln.payload, "<script>alert('XSS')</script>")
    
    def test_port_scanner(self):
        """Test port scanner"""
        scanner = self.framework.port_scanner
        
        # Test scanner properties
        self.assertIn(80, scanner.common_ports)
        self.assertIn(443, scanner.common_ports)
        self.assertEqual(scanner.scan_range, "127.0.0.1/32")
        
        # Mock socket connection
        with patch('socket.socket') as mock_socket:
            mock_sock = Mock()
            mock_sock.connect_ex.return_value = 0  # Port is open
            mock_socket.return_value = mock_sock
            
            # Run scan
            vulnerabilities = asyncio.run(scanner.scan("127.0.0.1"))
            
            # Should detect open ports
            self.assertGreater(len(vulnerabilities), 0)
            
            # Check vulnerability properties
            vuln = vulnerabilities[0]
            self.assertEqual(vuln.type, VulnerabilityType.OPEN_PORT)
            self.assertIn("Open Port", vuln.title)
            self.assertEqual(vuln.endpoint, "127.0.0.1:80")
            self.assertEqual(vuln.payload, "")
    
    def test_authentication_bypass_tester(self):
        """Test authentication bypass tester"""
        tester = self.framework.auth_tester
        
        # Test tester properties
        self.assertTrue(tester.bypass_attempts.get('sql_injection', False))
        self.assertTrue(tester.bypass_attempts.get('no_auth', False))
        self.assertTrue(tester.bypass_attempts.get('weak_tokens', False))
        
        # Test SQL bypass
        with patch('requests.post') as mock_post:
            mock_response = Mock()
            mock_response.status_code = 200
            mock_response.text = '{"token": "fake_jwt_token"}'
            mock_post.return_value = mock_response
            
            # Run test
            vulnerabilities = asyncio.run(tester.test("http://127.0.0.1:8080", max_requests=10))
            
            # Should detect authentication bypass
            self.assertGreater(len(vulnerabilities), 0)
            
            # Check vulnerability properties
            vuln = vulnerabilities[0]
            self.assertEqual(vuln.type, VulnerabilityType.AUTHENTICATION_BYPASS)
            self.assertEqual(vuln.severity, VulnerabilitySeverity.CRITICAL)
            self.assertIn("Authentication Bypass", vuln.title)
            self.assertEqual(vuln.endpoint, "/api/auth/login")
    
    def test_rate_limit_bypass_tester(self):
        """Test rate limiting bypass tester"""
        tester = self.framework.rate_limit_tester
        
        # Test tester properties
        self.assertTrue(tester.bypass_attempts.get('request_bursting', False))
        self.assertTrue(tester.bypass_attempts.get('header_manipulation', False))
        
        # Test request bursting
        with patch('requests.get') as mock_get:
            mock_response = Mock()
            mock_response.status_code = 200  # All requests succeed
            mock_get.return_value = mock_response
            
            # Run test
            vulnerabilities = asyncio.run(tester.test("http://127.0.0.1:8080", max_requests=50))
            
            # Should detect weak rate limiting
            self.assertGreater(len(vulnerabilities), 0)
            
            # Check vulnerability properties
            vuln = vulnerabilities[0]
            self.assertEqual(vuln.type, VulnerabilityType.RATE_LIMIT_BYPASS)
            self.assertEqual(vuln.severity, VulnerabilitySeverity.MEDIUM)
            self.assertIn("Weak Rate Limiting", vuln.title)
    
    def test_security_header_validator(self):
        """Test security header validator"""
        validator = self.framework.header_validator
        
        # Test validator properties
        self.assertIn("X-Frame-Options", validator.required_headers)
        self.assertIn("X-Content-Type-Options", validator.required_headers)
        self.assertIn("/", validator.endpoints)
        
        # Mock HTTP response missing security headers
        with patch('requests.get') as mock_get:
            mock_response = Mock()
            mock_response.status_code = 200
            mock_response.headers = {
                'Content-Type': 'text/html',
                'Server': 'nginx/1.0'
            }
            mock_get.return_value = mock_response
            
            # Run validation
            vulnerabilities = asyncio.run(validator.validate("http://127.0.0.1:8080"))
            
            # Should detect missing headers
            self.assertGreater(len(vulnerabilities), 0)
            
            # Check vulnerability properties
            vuln = vulnerabilities[0]
            self.assertEqual(vuln.type, VulnerabilityType.MISSING_SECURITY_HEADER)
            self.assertEqual(vuln.severity, VulnerabilitySeverity.MEDIUM)
            self.assertIn("Missing Security Headers", vuln.title)
            self.assertIn("X-Frame-Options", vuln.description)
    
    def test_vulnerability_dataclass(self):
        """Test Vulnerability dataclass"""
        vuln = Vulnerability(
            id="test-123",
            type=VulnerabilityType.SQL_INJECTION,
            severity=VulnerabilitySeverity.HIGH,
            title="Test SQL Injection",
            description="Test vulnerability",
            endpoint="/api/test",
            payload="' OR '1'='1",
            request_data={'param': 'test'},
            response_data={'status': 200},
            evidence="SQL error in response",
            recommendation="Fix input validation",
            cvss_score=7.5,
            discovered_at=datetime.utcnow(),
            request_id="req-123"
        )
        
        # Test all properties
        self.assertEqual(vuln.id, "test-123")
        self.assertEqual(vuln.type, VulnerabilityType.SQL_INJECTION)
        self.assertEqual(vuln.severity, VulnerabilitySeverity.HIGH)
        self.assertEqual(vuln.title, "Test SQL Injection")
        self.assertEqual(vuln.endpoint, "/api/test")
        self.assertEqual(vuln.payload, "' OR '1'='1")
        self.assertEqual(vuln.cvss_score, 7.5)
    
    def test_database_integration(self):
        """Test database integration"""
        # Test table creation
        self.framework._create_database_table()
        self.mock_db_manager.create_table.assert_called_once()
        
        # Test result storage
        test_vulns = [
            Vulnerability(
                id="test-1",
                type=VulnerabilityType.SQL_INJECTION,
                severity=VulnerabilitySeverity.HIGH,
                title="Test SQL Injection",
                description="Test vulnerability",
                endpoint="/api/test",
                payload="' OR '1'='1",
                request_data={},
                response_data={},
                evidence="Test evidence",
                recommendation="Fix it",
                discovered_at=datetime.utcnow(),
                request_id="req-1"
            )
        ]
        
        asyncio.run(self.framework._store_results("test-123", test_vulns))
        
        # Verify database calls
        self.assertEqual(self.mock_db_manager.insert.call_count, 1)
        call_args = self.mock_db_manager.insert.call_args
        self.assertEqual(call_args[0][0], "test_penetration_results")  # table name
        self.assertEqual(call_args[0][1]['id'], "test-1")  # vulnerability data
    
    def test_report_generation(self):
        """Test report generation"""
        # Mock database results
        mock_results = [
            {
                'id': 'test-1',
                'vulnerability_type': 'sql_injection',
                'severity': 'high',
                'title': 'SQL Injection',
                'description': 'SQL injection vulnerability',
                'endpoint': '/api/login',
                'payload': "' OR '1'='1",
                'cvss_score': 7.5
            }
        ]
        
        self.mock_db_manager.select.return_value = mock_results
        
        # Test JSON report
        json_report = asyncio.run(self.framework.generate_report("test-123", "json"))
        self.assertIn("test-123", json_report)
        self.assertIn("SQL Injection", json_report)
        self.assertIn("sql_injection", json_report)
        
        # Test HTML report
        html_report = asyncio.run(self.framework.generate_report("test-123", "html"))
        self.assertIn("Penetration Test Report", html_report)
        self.assertIn("test-123", html_report)
        self.assertIn("SQL Injection", html_report)
    
    def test_comprehensive_test_execution(self):
        """Test comprehensive test execution"""
        # Mock individual scanners
        with patch.object(self.framework.sql_scanner, 'scan') as mock_sql_scan, \
             patch.object(self.framework.xss_scanner, 'scan') as mock_xss_scan, \
             patch.object(self.framework.port_scanner, 'scan') as mock_port_scan, \
             patch.object(self.framework.auth_tester, 'test') as mock_auth_test, \
             patch.object(self.framework.rate_limit_tester, 'test') as mock_rate_test, \
             patch.object(self.framework.header_validator, 'validate') as mock_header_validate:
            
            # Setup mock returns
            mock_sql_scan.return_value = []
            mock_xss_scan.return_value = []
            mock_port_scan.return_value = []
            mock_auth_test.return_value = []
            mock_rate_test.return_value = []
            mock_header_validate.return_value = []
            
            # Run comprehensive test
            result = asyncio.run(self.framework.run_comprehensive_test())
            
            # Verify test execution
            self.assertIsNotNone(result)
            self.assertEqual(result.test_type, "comprehensive")
            self.assertEqual(result.target_host, "127.0.0.1")
            self.assertEqual(result.target_port, 8080)
            self.assertEqual(result.status, "completed")
            
            # Verify scanners were called
            mock_sql_scan.assert_called_once()
            mock_xss_scan.assert_called_once()
            mock_port_scan.assert_called_once()
            mock_auth_test.assert_called_once()
            mock_rate_test.assert_called_once()
            mock_header_validate.assert_called_once()
    
    def test_audit_logging_integration(self):
        """Test audit logging integration"""
        # Test that audit events are logged
        with patch.object(self.framework.audit_logger, 'log_event') as mock_log:
            mock_log.return_value = None
            
            # Run a test that should log events
            asyncio.run(self.framework.run_comprehensive_test())
            
            # Verify audit logging was called
            self.assertGreater(mock_log.call_count, 0)
            
            # Check for specific event types
            call_args_list = [call[0] for call in mock_log.call_args_list]
            event_types = [args[1] for args in call_args_list]
            self.assertIn(EventType.SECURITY_VIOLATION, event_types)
    
    def test_factory_function(self):
        """Test factory function"""
        # Test factory function creates framework
        framework = create_penetration_testing_framework(
            config_path=self.config_path,
            database_manager=self.mock_db_manager,
            audit_logger=self.mock_audit_logger
        )
        
        self.assertIsNotNone(framework)
        self.assertIsInstance(framework, PenetrationTestingFramework)
        self.assertEqual(framework.config.get('target_host'), '127.0.0.1')
    
    def test_error_handling(self):
        """Test error handling in framework"""
        # Test with invalid config file
        with self.assertRaises(Exception):
            PenetrationTestingFramework(config_path="/nonexistent/config.json")
        
        # Test network error handling
        with patch('requests.get', side_effect=Exception("Network error")):
            vulnerabilities = asyncio.run(self.framework.sql_scanner.scan(
                "http://127.0.0.1:8080", 
                max_requests=5
            ))
            
            # Should handle errors gracefully
            self.assertIsInstance(vulnerabilities, list)
    
    def test_configuration_validation(self):
        """Test configuration validation"""
        # Test with missing required config
        invalid_config = {
            "penetration_testing": {
                "enabled": True,
                # Missing target_host
                "vulnerability_scanning": {}
            }
        }
        
        with open(self.config_path, 'w') as f:
            json.dump(invalid_config, f)
        
        # Framework should still initialize with defaults
        framework = PenetrationTestingFramework(
            config_path=self.config_path,
            database_manager=self.mock_db_manager,
            audit_logger=self.mock_audit_logger
        )
        
        # Should use default values
        self.assertIsNotNone(framework.config.get('target_host', '0.0.0.0'))
    
    def test_concurrent_request_limiting(self):
        """Test concurrent request limiting"""
        # Test that framework respects max concurrent requests
        scanner = self.framework.sql_scanner
        
        with patch('requests.get') as mock_get:
            mock_response = Mock()
            mock_response.status_code = 200
            mock_response.text = "OK"
            mock_get.return_value = mock_response
            
            # Run scan with max_requests limit
            vulnerabilities = asyncio.run(scanner.scan(
                "http://127.0.0.1:8080", 
                max_requests=3
            ))
            
            # Should limit requests to max_requests
            self.assertLessEqual(mock_get.call_count, 3 * len(scanner.endpoints))
    
    def test_vulnerability_severity_classification(self):
        """Test vulnerability severity classification"""
        # Test port severity classification
        scanner = self.framework.port_scanner
        
        # Critical ports
        critical_severity = scanner._get_port_severity(21)
        self.assertEqual(critical_severity, VulnerabilitySeverity.CRITICAL)
        
        # High ports
        high_severity = scanner._get_port_severity(80)
        self.assertEqual(high_severity, VulnerabilitySeverity.HIGH)
        
        # Medium ports
        medium_severity = scanner._get_port_severity(445)
        self.assertEqual(medium_severity, VulnerabilitySeverity.MEDIUM)
        
        # Low ports
        low_severity = scanner._get_port_severity(3000)
        self.assertEqual(low_severity, VulnerabilitySeverity.LOW)
    
    def test_xss_encoding_detection(self):
        """Test XSS encoding detection"""
        scanner = self.framework.xss_scanner
        
        # Test proper encoding detection
        payload = "<script>alert('XSS')</script>"
        encoded_response = "Search for: <script>alert('XSS')</script>"
        
        # Should detect proper encoding
        self.assertTrue(scanner._is_properly_encoded(payload, encoded_response))
        
        # Test unencoded response
        unencoded_response = "Search for: <script>alert('XSS')</script>"
        
        # Should detect lack of encoding
        self.assertFalse(scanner._is_properly_encoded(payload, unencoded_response))


class TestPenetrationTestingIntegration(unittest.TestCase):
    """Test integration with existing security components"""
    
    def setUp(self):
        """Set up integration test environment"""
        self.temp_dir = tempfile.mkdtemp()
        
        # Create integration configuration
        self.integration_config = {
            "penetration_testing": {
                "enabled": True,
                "target_host": "0.0.0.0",
                "target_port": 8080,
                
                "vulnerability_scanning": {
                    "sql_injection": {"enabled": True},
                    "xss": {"enabled": True}
                },
                
                "authentication_testing": {
                    "enabled": True,
                    "bypass_attempts": {
                        "sql_injection": True,
                        "weak_tokens": True
                    }
                },
                
                "database": {
                    "store_results": True,
                    "table_name": "integration_test_results"
                }
            }
        }
        
        self.config_path = os.path.join(self.temp_dir, 'integration_config.json')
        with open(self.config_path, 'w') as f:
            json.dump(self.integration_config, f)
    
    def tearDown(self):
        """Clean up integration test environment"""
        if os.path.exists(self.temp_dir):
            shutil.rmtree(self.temp_dir)
    
    def test_input_validator_integration(self):
        """Test integration with input validator"""
        from noodlecore.security.input_validator import InputValidator, ValidationRule, InputType
        
        # Create framework with input validator integration
        framework = create_penetration_testing_framework(
            config_path=self.config_path
        )
        
        # Test that payloads are validated
        validator = InputValidator()
        rule = ValidationRule(
            input_type=InputType.STRING,
            max_length=100,
            forbidden_patterns=["<script>", "javascript:"]
        )
        
        # Test malicious payload
        result = validator.validate("<script>alert('XSS')</script>", rule)
        self.assertFalse(result.is_valid)
        self.assertGreater(len(result.errors), 0)
    
    def test_rate_limiter_integration(self):
        """Test integration with rate limiter"""
        from noodlecore.security.rate_limiter import RateLimitManager, RateLimitConfig
        
        # Create framework with rate limiter integration
        framework = create_penetration_testing_framework(
            config_path=self.config_path
        )
        
        # Test that rate limiting is considered during testing
        rate_limit_config = RateLimitConfig(
            requests_per_window=10,
            window_size_seconds=60
        )
        
        rate_limiter = RateLimitManager()
        status = rate_limiter.check_rate_limit("test_ip", rate_limit_config)
        
        # Should allow test requests
        self.assertTrue(status.requests_remaining >= 0)
    
    def test_security_headers_integration(self):
        """Test integration with security headers"""
        from noodlecore.security.security_headers import WebApplicationFirewall, SecurityLevel
        
        # Create framework with WAF integration
        framework = create_penetration_testing_framework(
            config_path=self.config_path
        )
        
        # Test that WAF rules are considered
        waf = WebApplicationFirewall(SecurityLevel.MEDIUM)
        
        # Mock request for WAF analysis
        mock_request = Mock()
        mock_request.url = "http://127.0.0.1:8080/api/test"
        mock_request.headers = {"User-Agent": "test"}
        mock_request.query_params = {"param": "test"}
        
        # Analyze request
        result = waf.analyze_request(mock_request)
        
        # Should return analysis result
        self.assertIsNotNone(result)
    
    def test_oauth_jwt_integration(self):
        """Test integration with OAuth/JWT manager"""
        from noodlecore.security.oauth_jwt_manager import JWTManager, JWTConfig
        
        # Create framework with JWT integration
        framework = create_penetration_testing_framework(
            config_path=self.config_path
        )
        
        # Test JWT token validation
        jwt_config = JWTConfig(
            secret_key="test_secret",
            algorithm="HS256"
        )
        
        jwt_manager = JWTManager(jwt_config)
        
        # Generate test token
        user_data = {"user_id": "test", "email": "test@example.com"}
        tokens = jwt_manager.generate_tokens(user_data)
        
        # Should generate valid tokens
        self.assertIn("access_token", tokens)
        self.assertIn("refresh_token", tokens)
    
    def test_audit_logger_integration(self):
        """Test integration with audit logger"""
        from noodlecore.security.audit_logger import AuditLogger, EventType, AuditLevel
        
        # Create framework with audit logger
        framework = create_penetration_testing_framework(
            config_path=self.config_path
        )
        
        # Test audit logging during penetration testing
        audit_logger = AuditLogger()
        
        # Log security event
        asyncio.run(audit_logger.log_event(
            EventType.SECURITY_VIOLATION,
            AuditLevel.HIGH,
            "Test security event",
            details={"test": True}
        ))
        
        # Should log without errors
        self.assertIsNotNone(audit_logger)
    
    def test_database_integration(self):
        """Test database integration through pooled helpers"""
        from noodlecore.database.database_manager import DatabaseManager
        
        # Create framework with database integration
        framework = create_penetration_testing_framework(
            config_path=self.config_path
        )
        
        # Test database operations
        self.assertIsNotNone(framework.database_manager)
        
        # Should use pooled connections
        self.assertIsInstance(framework.database_manager, DatabaseManager)
    
    def test_environment_variables(self):
        """Test environment variable support"""
        # Set environment variables
        os.environ['NOODLE_PENTEST_ENABLED'] = 'true'
        os.environ['NOODLE_PENTEST_TARGET_HOST'] = 'test.example.com'
        os.environ['NOODLE_PENTEST_TARGET_PORT'] = '9090'
        
        # Create framework
        framework = create_penetration_testing_framework()
        
        # Should use environment variables
        self.assertTrue(framework.config.get('enabled', False))
        self.assertEqual(framework.config.get('target_host'), 'test.example.com')
        self.assertEqual(framework.config.get('target_port'), 9090)
        
        # Clean up
        del os.environ['NOODLE_PENTEST_ENABLED']
        del os.environ['NOODLE_PENTEST_TARGET_HOST']
        del os.environ['NOODLE_PENTEST_TARGET_PORT']


def run_tests():
    """Run all penetration testing tests"""
    # Create test suite
    suite = unittest.TestSuite()
    
    # Add test cases
    suite.addTest(unittest.makeSuite(TestPenetrationTestingFramework))
    suite.addTest(unittest.makeSuite(TestPenetrationTestingIntegration))
    
    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    # Return success status
    return result.wasSuccessful()


if __name__ == '__main__':
    print("Running NoodleCore Penetration Testing Framework Tests")
    print("=" * 60)
    
    success = run_tests()
    
    if success:
        print("\nâœ… All tests passed successfully!")
        sys.exit(0)
    else:
        print("\nâŒ Some tests failed!")
        sys.exit(1)

