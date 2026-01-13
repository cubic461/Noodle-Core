"""
Test Suite::Noodle Core - test_compiler_security.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test Suite for NoodleCore Compiler Security Integration

Comprehensive test suite covering all security aspects of the compiler
including authentication, authorization, input validation, security scanning,
audit logging, and rate limiting.
"""

import os
import sys
import unittest
import asyncio
import uuid
import tempfile
import time
from unittest.mock import Mock, patch, AsyncMock
from pathlib import Path

# Add the src directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

from noodlecore.compiler.security_integration import (
    CompilerSecurityManager, CompilerSecurityConfig, CompilationContext,
    CompilationResult, SecurityLevel, CompilationPermission
)
from noodlecore.compiler.bytecode_generator import create_bytecode_generator, BytecodeGeneratorConfig
from noodlecore.compiler.enhanced_parser import EnhancedParser
from noodlecore.compiler.ast_nodes import EnhancedProgramNode, EnhancedLetStatementNode, EnhancedLiteralNode

from noodlecore.security.oauth_jwt_manager import SecurityManager, JWTConfig
from noodlecore.security.input_validator import InputValidator, ValidationRule, InputType
from noodlecore.security.rate_limiter import RateLimitManager, RateLimitConfig, RateLimitStrategy
from noodlecore.security.audit_logger import AuditLogger, EventType, AuditLevel
from noodlecore.security.vulnerability_scanning import VulnerabilityScanningSystem, VulnerabilityAssessment, RiskLevel
from noodlecore.database.database_manager import get_database_manager, DatabaseManager


class TestCompilerSecurityIntegration(unittest.TestCase):
    """Test cases for compiler security integration"""
    
    def setUp(self):
        """Set up test environment"""
        self.temp_dir = tempfile.mkdtemp()
        self.test_source = """
        // Simple Noodle program for testing
        let x: int = 42
        let y: string = "Hello, World!"
        function add(a: int, b: int): int {
            return a + b
        }
        let result = add(x, 10)
        """
        
        # Create test configuration
        self.config = CompilerSecurityConfig(
            security_enabled=True,
            auth_required=True,
            security_level=SecurityLevel.STANDARD,
            rate_limit_per_minute=10,
            max_source_size_bytes=1024 * 1024,  # 1MB
            scan_bytecode=True,
            require_code_signing=False,
            allowed_file_extensions=['.nc', '.noodle'],
            forbidden_patterns=['eval\\s*\\(', 'exec\\s*\\('],
            required_permissions=[CompilationPermission.COMPILE],
            timeout_seconds=30,
            memory_limit_mb=512
        )
        
        # Create mock security components
        self.mock_security_manager = Mock(spec=SecurityManager)
        self.mock_audit_logger = Mock(spec=AuditLogger)
        self.mock_vulnerability_scanner = Mock(spec=VulnerabilityScanningSystem)
        self.mock_database_manager = Mock(spec=DatabaseManager)
        
        # Create compiler security manager
        self.compiler_security = CompilerSecurityManager(
            config=self.config,
            security_manager=self.mock_security_manager,
            audit_logger=self.mock_audit_logger,
            vulnerability_scanner=self.mock_vulnerability_scanner,
            database_manager=self.mock_database_manager
        )
    
    def tearDown(self):
        """Clean up test environment"""
        import shutil
        shutil.rmtree(self.temp_dir, ignore_errors=True)
    
    def test_authentication_success(self):
        """Test successful authentication"""
        async def test_auth():
            # Mock successful authentication
            self.mock_security_manager.jwt_manager.verify_token.return_value = {
                "sub": "test_user",
                "roles": ["developer"],
                "permissions": ["compile"]
            }
            
            # Test authentication
            is_auth, user_id, permissions = await self.compiler_security.authenticate_compilation_request(
                token="valid_token"
            )
            
            self.assertTrue(is_auth)
            self.assertEqual(user_id, "test_user")
            self.assertIn(CompilationPermission.COMPILE, permissions)
            
            # Verify audit log was called
            self.mock_audit_logger.log_event.assert_called()
        
        asyncio.run(test_auth())
    
    def test_authentication_failure(self):
        """Test authentication failure"""
        async def test_auth():
            # Mock failed authentication
            self.mock_security_manager.jwt_manager.verify_token.side_effect = Exception("Invalid token")
            
            # Test authentication
            is_auth, user_id, permissions = await self.compiler_security.authenticate_compilation_request(
                token="invalid_token"
            )
            
            self.assertFalse(is_auth)
            self.assertIsNone(user_id)
            self.assertEqual(permissions, [])
            
            # Verify audit log was called
            self.mock_audit_logger.log_event.assert_called()
        
        asyncio.run(test_auth())
    
    def test_rate_limit_check(self):
        """Test rate limiting functionality"""
        async def test_rate_limit():
            # Test rate limit within bounds
            is_allowed, retry_after = await self.compiler_security.check_rate_limit(
                user_id="test_user"
            )
            
            self.assertTrue(is_allowed)
            self.assertIsNone(retry_after)
            
            # Test rate limit exceeded (mock implementation)
            with patch.object(self.compiler_security.rate_limiter, 'check_rate_limit') as mock_check:
                mock_status = Mock()
                mock_status.is_limited = True
                mock_status.window_reset_time = time.time() + 60
                mock_check.return_value = mock_status
                
                is_allowed, retry_after = await self.compiler_security.check_rate_limit(
                    user_id="test_user"
                )
                
                self.assertFalse(is_allowed)
                self.assertIsNotNone(retry_after)
        
        asyncio.run(test_rate_limit())
    
    def test_source_code_validation(self):
        """Test source code validation"""
        async def test_validation():
            # Test valid source code
            result = await self.compiler_security.validate_source_code(
                self.test_source,
                file_path="test.nc"
            )
            
            self.assertTrue(result.is_valid)
            self.assertEqual(len(result.errors), 0)
            
            # Test source code with forbidden pattern
            malicious_source = "let x = eval('malicious code')"
            result = await self.compiler_security.validate_source_code(
                malicious_source,
                file_path="test.nc"
            )
            
            self.assertFalse(result.is_valid)
            self.assertGreater(len(result.errors), 0)
            
            # Test oversized source code
            large_source = "x" * (self.config.max_source_size_bytes + 1)
            result = await self.compiler_security.validate_source_code(
                large_source,
                file_path="test.nc"
            )
            
            self.assertFalse(result.is_valid)
            self.assertIn("too large", result.errors[0].lower())
            
            # Test invalid file extension
            result = await self.compiler_security.validate_source_code(
                self.test_source,
                file_path="test.exe"
            )
            
            self.assertFalse(result.is_valid)
            self.assertIn("not allowed", result.errors[0].lower())
        
        asyncio.run(test_validation())
    
    def test_authorization_check(self):
        """Test authorization functionality"""
        async def test_authz():
            # Create context with sufficient permissions
            context = CompilationContext(
                request_id=str(uuid.uuid4()),
                user_id="test_user",
                permissions=[CompilationPermission.COMPILE, CompilationPermission.READ]
            )
            
            # Test successful authorization
            is_authorized, error = await self.compiler_security.authorize_compilation(
                context,
                required_permissions=[CompilationPermission.COMPILE]
            )
            
            self.assertTrue(is_authorized)
            self.assertIsNone(error)
            
            # Test insufficient permissions
            context.permissions = [CompilationPermission.READ]
            is_authorized, error = await self.compiler_security.authorize_compilation(
                context,
                required_permissions=[CompilationPermission.COMPILE]
            )
            
            self.assertFalse(is_authorized)
            self.assertIsNotNone(error)
            self.assertIn("Insufficient permissions", error)
        
        asyncio.run(test_authz())
    
    def test_secure_compilation(self):
        """Test secure compilation process"""
        async def test_compilation():
            # Mock successful authentication
            self.mock_security_manager.jwt_manager.verify_token.return_value = {
                "sub": "test_user",
                "roles": ["developer"],
                "permissions": ["compile"]
            }
            
            # Mock rate limit check
            with patch.object(self.compiler_security, 'check_rate_limit') as mock_rate_limit:
                mock_rate_limit.return_value = (True, None)
                
                # Mock vulnerability scanner
                self.mock_vulnerability_scanner.run_scan.return_value = Mock(
                    vulnerabilities=[]
                )
                
                # Create compilation context
                context = CompilationContext(
                    request_id=str(uuid.uuid4()),
                    user_id="test_user",
                    source_code=self.test_source,
                    file_path="test.nc",
                    permissions=[CompilationPermission.COMPILE]
                )
                
                # Test secure compilation
                result = await self.compiler_security.secure_compile(
                    self.test_source,
                    file_path="test.nc",
                    context=context
                )
                
                self.assertTrue(result.success)
                self.assertIsNotNone(result.bytecode)
                self.assertEqual(len(result.errors), 0)
                self.assertEqual(result.request_id, context.request_id)
                self.assertGreater(result.compilation_time_ms, 0)
                
                # Verify audit logging
                self.mock_audit_logger.log_event.assert_called()
                
                # Verify vulnerability scanning was called
                if self.config.scan_bytecode:
                    self.mock_vulnerability_scanner.run_scan.assert_called()
        
        asyncio.run(test_compilation())
    
    def test_compilation_with_security_violations(self):
        """Test compilation with security violations"""
        async def test_compilation():
            # Mock successful authentication
            self.mock_security_manager.jwt_manager.verify_token.return_value = {
                "sub": "test_user",
                "roles": ["developer"],
                "permissions": ["compile"]
            }
            
            # Mock rate limit check
            with patch.object(self.compiler_security, 'check_rate_limit') as mock_rate_limit:
                mock_rate_limit.return_value = (True, None)
                
                # Mock vulnerability scanner with findings
                mock_vulnerability = VulnerabilityAssessment(
                    id="vuln_1",
                    type="code_vulnerability",
                    title="Test Vulnerability",
                    description="Test security issue",
                    severity=RiskLevel.HIGH,
                    status="detected",
                    discovered_at=time.time(),
                    source="security_scanner",
                    target="test.nc"
                )
                self.mock_vulnerability_scanner.run_scan.return_value = Mock(
                    vulnerabilities=[mock_vulnerability]
                )
                
                # Create compilation context
                context = CompilationContext(
                    request_id=str(uuid.uuid4()),
                    user_id="test_user",
                    source_code=self.test_source,
                    file_path="test.nc",
                    permissions=[CompilationPermission.COMPILE]
                )
                
                # Test compilation with security issues
                result = await self.compiler_security.secure_compile(
                    self.test_source,
                    file_path="test.nc",
                    context=context
                )
                
                self.assertTrue(result.success)  # Still succeeds but with warnings
                self.assertIsNotNone(result.bytecode)
                self.assertGreater(len(result.security_issues), 0)
                
                # Verify vulnerability was included in result
                self.assertEqual(len(result.security_issues), 1)
                self.assertEqual(result.security_issues[0].id, "vuln_1")
        
        asyncio.run(test_compilation())
    
    def test_compilation_metrics(self):
        """Test compilation metrics collection"""
        async def test_metrics():
            # Get metrics
            metrics = await self.compiler_security.get_compilation_metrics()
            
            # Verify metrics structure
            self.assertIn('total_compilations', metrics)
            self.assertIn('blocked_compilations', metrics)
            self.assertIn('security_violations', metrics)
            self.assertIn('rate_limit_blocks', metrics)
            self.assertIn('auth_failures', metrics)
            self.assertIn('last_24_hours', metrics)
            self.assertIn('active_compilations', metrics)
            
            # Verify metric types
            self.assertIsInstance(metrics['total_compilations'], int)
            self.assertIsInstance(metrics['blocked_compilations'], int)
            self.assertIsInstance(metrics['security_violations'], int)
        
        asyncio.run(test_metrics())
    
    def test_compilation_cancellation(self):
        """Test compilation cancellation"""
        async def test_cancellation():
            # Create compilation context
            context = CompilationContext(
                request_id=str(uuid.uuid4()),
                user_id="test_user",
                permissions=[CompilationPermission.COMPILE]
            )
            
            # Add to active compilations
            self.compiler_security.active_compilations[context.request_id] = {
                'context': context,
                'started_at': time.time()
            }
            
            # Test cancellation
            result = await self.compiler_security.cancel_compilation(
                context.request_id,
                user_id="test_user"
            )
            
            self.assertTrue(result)
            self.assertNotIn(context.request_id, self.compiler_security.active_compilations)
            
            # Verify audit logging
            self.mock_audit_logger.log_event.assert_called()
        
        asyncio.run(test_cancellation())
    
    def test_security_levels(self):
        """Test different security levels"""
        # Test minimal security level
        minimal_config = CompilerSecurityConfig(
            security_enabled=True,
            security_level=SecurityLevel.MINIMAL,
            auth_required=False,
            scan_bytecode=False
        )
        
        minimal_compiler = CompilerSecurityManager(
            config=minimal_config,
            security_manager=self.mock_security_manager,
            audit_logger=self.mock_audit_logger,
            vulnerability_scanner=self.mock_vulnerability_scanner,
            database_manager=self.mock_database_manager
        )
        
        # Test paranoid security level
        paranoid_config = CompilerSecurityConfig(
            security_enabled=True,
            security_level=SecurityLevel.PARANOID,
            auth_required=True,
            scan_bytecode=True,
            require_code_signing=True
        )
        
        paranoid_compiler = CompilerSecurityManager(
            config=paranoid_config,
            security_manager=self.mock_security_manager,
            audit_logger=self.mock_audit_logger,
            vulnerability_scanner=self.mock_vulnerability_scanner,
            database_manager=self.mock_database_manager
        )
        
        # Verify configurations are applied
        self.assertEqual(minimal_compiler.config.security_level, SecurityLevel.MINIMAL)
        self.assertEqual(paranoid_compiler.config.security_level, SecurityLevel.PARANOID)
    
    def test_bytecode_generator_security_integration(self):
        """Test bytecode generator security integration"""
        # Create bytecode generator with security manager
        generator = create_bytecode_generator(
            config=BytecodeGeneratorConfig(),
            security_manager=self.compiler_security
        )
        
        # Verify security manager is attached
        self.assertEqual(generator.security_manager, self.compiler_security)
        
        # Verify security validation pass is in pipeline
        security_pass_found = False
        for pass_ in generator.optimization_pipeline:
            if pass_.__class__.__name__ == 'SecurityValidationPass':
                security_pass_found = True
                break
        
        self.assertTrue(security_pass_found, "SecurityValidationPass not found in optimization pipeline")


class TestSecurityValidationPass(unittest.TestCase):
    """Test cases for SecurityValidationPass"""
    
    def setUp(self):
        """Set up test environment"""
        from noodlecore.compiler.bytecode_generator import SecurityValidationPass, BytecodeGeneratorConfig
        
        self.config = BytecodeGeneratorConfig()
        self.mock_security_manager = Mock()
        self.security_pass = SecurityValidationPass(self.config, self.mock_security_manager)
    
    def test_dangerous_function_detection(self):
        """Test detection of dangerous function calls"""
        # Create mock AST node with dangerous function
        mock_node = Mock()
        mock_node.function = Mock()
        mock_node.function.name = "eval"
        
        # Apply security validation
        result = self.security_pass.apply(mock_node)
        
        # Verify violation was detected
        violations = self.security_pass.get_security_violations()
        self.assertGreater(len(violations), 0)
        self.assertTrue(any("eval" in v for v in violations))
    
    def test_malicious_string_detection(self):
        """Test detection of malicious string literals"""
        # Create mock AST node with malicious string
        mock_node = Mock()
        mock_node.value = "eval('malicious code')"
        
        # Apply security validation
        result = self.security_pass.apply(mock_node)
        
        # Verify violation was detected
        violations = self.security_pass.get_security_violations()
        self.assertGreater(len(violations), 0)
        self.assertTrue(any("dangerous" in v.lower() for v in violations))


class TestCompilerSecurityConfiguration(unittest.TestCase):
    """Test cases for compiler security configuration"""
    
    def test_default_configuration(self):
        """Test default security configuration"""
        config = CompilerSecurityConfig()
        
        # Verify default values
        self.assertTrue(config.security_enabled)
        self.assertTrue(config.auth_required)
        self.assertEqual(config.security_level, SecurityLevel.STANDARD)
        self.assertEqual(config.rate_limit_per_minute, 100)
        self.assertEqual(config.max_source_size_bytes, 10 * 1024 * 1024)  # 10MB
        self.assertTrue(config.scan_bytecode)
        self.assertFalse(config.require_code_signing)
        self.assertIn('.nc', config.allowed_file_extensions)
        self.assertIn('.noodle', config.allowed_file_extensions)
    
    def test_environment_variable_configuration(self):
        """Test configuration from environment variables"""
        # Set environment variables
        with patch.dict(os.environ, {
            'NOODLE_COMPILER_SECURITY_ENABLED': 'false',
            'NOODLE_COMPILER_AUTH_REQUIRED': 'false',
            'NOODLE_COMPILER_RATE_LIMIT': '50',
            'NOODLE_COMPILER_MAX_SOURCE_SIZE': '2048',
            'NOODLE_COMPILER_SCAN_BYTECODE': 'false'
        }):
            # Import after setting environment variables
            from noodlecore.compiler.security_integration import (
                NOODLE_COMPILER_SECURITY_ENABLED,
                NOODLE_COMPILER_AUTH_REQUIRED,
                NOODLE_COMPILER_RATE_LIMIT,
                NOODLE_COMPILER_MAX_SOURCE_SIZE,
                NOODLE_COMPILER_SCAN_BYTECODE
            )
            
            # Verify environment variables are read
            self.assertFalse(NOODLE_COMPILER_SECURITY_ENABLED)
            self.assertFalse(NOODLE_COMPILER_AUTH_REQUIRED)
            self.assertEqual(NOODLE_COMPILER_RATE_LIMIT, 50)
            self.assertEqual(NOODLE_COMPILER_MAX_SOURCE_SIZE, 2048)
            self.assertFalse(NOODLE_COMPILER_SCAN_BYTECODE)


class TestCompilerSecurityPerformance(unittest.TestCase):
    """Test cases for compiler security performance"""
    
    def setUp(self):
        """Set up test environment"""
        self.config = CompilerSecurityConfig(
            security_enabled=True,
            auth_required=True,
            security_level=SecurityLevel.STANDARD
        )
        
        self.compiler_security = CompilerSecurityManager(config=self.config)
    
    def test_authentication_performance(self):
        """Test authentication performance"""
        async def test_perf():
            start_time = time.time()
            
            # Test multiple authentications
            for _ in range(100):
                await self.compiler_security.authenticate_compilation_request(
                    token="test_token"
                )
            
            elapsed_time = time.time() - start_time
            
            # Verify performance (should be under 1 second for 100 auths)
            self.assertLess(elapsed_time, 1.0)
        
        asyncio.run(test_perf())
    
    def test_validation_performance(self):
        """Test validation performance"""
        async def test_perf():
            test_source = """
            let x: int = 42
            let y: string = "Hello, World!"
            function add(a: int, b: int): int {
                return a + b
            }
            """ * 100  # Larger source for performance testing
            
            start_time = time.time()
            
            # Test multiple validations
            for _ in range(10):
                await self.compiler_security.validate_source_code(test_source)
            
            elapsed_time = time.time() - start_time
            
            # Verify performance (should be under 1 second for 10 validations)
            self.assertLess(elapsed_time, 1.0)
        
        asyncio.run(test_perf())


def run_tests():
    """Run all tests using unified testing framework"""
    try:
        # Import unified testing framework
        from noodlecore.compiler.testing_framework import (
            UnifiedTestingFramework, TestConfiguration, TestCategory, TestPriority,
            create_test_configuration, create_test_suite, create_test_case
        )
        
        # Create test configuration
        config = create_test_configuration(
            max_parallel_tests=4,
            enable_performance_benchmarks=True,
            enable_security_testing=True,
            enable_regression_testing=True,
            enable_coverage_analysis=True,
            verbose_output=True,
            generate_reports=True,
            test_categories=[TestCategory.UNIT, TestCategory.INTEGRATION, TestCategory.SECURITY],
            test_priorities=[TestPriority.HIGH, TestPriority.MEDIUM]
        )
        
        # Create unified testing framework
        framework = UnifiedTestingFramework(config)
        
        # Create test suite
        test_suite = create_test_suite(
            name="compiler_security",
            description="Test suite for NoodleCore compiler security integration",
            category=TestCategory.SECURITY
        )
        
        # Add test cases from existing test classes
        test_classes = [
            TestCompilerSecurityIntegration,
            TestSecurityValidationPass,
            TestCompilerSecurityConfiguration,
            TestCompilerSecurityPerformance
        ]
        
        # Convert unittest test cases to unified framework format
        for test_class in test_classes:
            tests = unittest.TestLoader().loadTestsFromTestCase(test_class)
            for test_group in tests:
                for test in test_group:
                    if hasattr(test, '_testMethodName'):
                        test_case = create_test_case(
                            test_id=f"{test_class.__name__}.{test._testMethodName}",
                            name=f"{test_class.__name__}.{test._testMethodName}",
                            description=f"Test case for {test_class.__name__}.{test._testMethodName}",
                            category=TestCategory.SECURITY,
                            priority=TestPriority.HIGH,
                            test_method=test,
                            setup_method=getattr(test_class, 'setUp', None),
                            teardown_method=getattr(test_class, 'tearDown', None)
                        )
                        test_suite.add_test_case(test_case)
        
        # Add test suite to framework
        framework.add_test_suite(test_suite)
        
        # Run tests
        summary = framework.run_all_tests()
        
        # Print summary
        print(f"\nCompiler Security Test Summary:")
        print(f"Total Tests: {summary.total_tests}")
        print(f"Passed: {summary.total_passed}")
        print(f"Failed: {summary.total_failed}")
        print(f"Errors: {summary.total_errors}")
        print(f"Success Rate: {(summary.total_passed/summary.total_tests)*100:.1f}%")
        print(f"Execution Time: {summary.total_execution_time:.2f}s")
        
        # Return success status
        return summary.total_passed == summary.total_tests
        
    except ImportError:
        # Fallback to traditional unittest if unified framework is not available
        print("Warning: Unified testing framework not available, falling back to unittest")
        
        # Run all tests
        unittest.main(verbosity=2)
        return True


if __name__ == '__main__':
    success = run_tests()
    sys.exit(0 if success else 1)

