# Converted from Python to NoodleCore
# Original file: src

# """
# Test Suite for AI Guard Module
# ------------------------------
# This module contains unit tests for the AI Guard module and its components.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import pytest
import time
import unittest.mock.Mock

import noodlecore.ai.guard.(
#     AIGuard, GuardMode, GuardConfig, GuardResult, GuardAction, GuardException
# )
import noodlecore.ai.output_interceptor.(
#     OutputInterceptor, InterceptionPoint, InterceptionMode, InterceptionConfig
# )
import noodlecore.ai.syntax_validator.(
#     SyntaxValidator, ValidationLevel, ValidationStrategy, ValidationConfig
# )
import noodlecore.ai.linter_bridge.(
#     LinterBridge, CommunicationMode, ValidationPriority, LinterBridgeConfig
# )
import noodlecore.ai.compliance_tracker.(
#     ComplianceTracker, ComplianceLevel, IssueCategory, IssueSeverity
# )
import noodlecore.linter.linter.LinterError


class TestGuardConfig
    #     """Test cases for GuardConfig"""

    #     def test_default_config(self):""Test default configuration"""
    config = GuardConfig()

    assert config.mode == GuardMode.ADAPTIVE
    assert config.action_on_failure == GuardAction.REQUEST_CORRECTION
    assert config.max_correction_attempts = 3
    assert config.timeout_ms = 5000
    #         assert config.enable_logging is True
    #         assert config.cache_enabled is True
    #         assert config.strict_file_extension is True
    #         assert ".nc" in config.allowed_extensions
    #         assert ".noodle" in config.allowed_extensions

    #     def test_config_to_dict(self):
    #         """Test configuration to dictionary conversion"""
    config = GuardConfig()
    config_dict = config.to_dict()

    #         assert "mode" in config_dict
    #         assert "action_on_failure" in config_dict
    #         assert "max_correction_attempts" in config_dict
    #         assert "timeout_ms" in config_dict
    assert config_dict["mode"] = = GuardMode.ADAPTIVE.value
    assert config_dict["action_on_failure"] = = GuardAction.REQUEST_CORRECTION.value


class TestGuardResult
    #     """Test cases for GuardResult"""

    #     def test_empty_result(self):""Test empty result"""
    result = GuardResult(
    success = False,
    is_valid = False,
    original_output = "test"
    #         )

    #         assert result.success is False
    #         assert result.is_valid is False
    assert result.original_output = = "test"
            assert result.has_errors() is False
            assert result.has_warnings() is False
    assert len(result.get_all_issues()) = = 0

    #     def test_result_with_errors(self):
    #         """Test result with errors"""
    error = LinterError(
    code = "E104",
    message = "Syntax error",
    severity = "error",
    category = "syntax"
    #         )

    result = GuardResult(
    success = False,
    is_valid = False,
    original_output = "test",
    errors = [error]
    #         )

            assert result.has_errors() is True
            assert result.has_warnings() is False
    assert len(result.get_all_issues()) = = 1

    #     def test_result_to_dict(self):
    #         """Test result to dictionary conversion"""
    result = GuardResult(
    success = True,
    is_valid = True,
    original_output = "test"
    #         )

    result_dict = result.to_dict()

    #         assert "requestId" in result_dict
    #         assert "success" in result_dict
    #         assert "isValid" in result_dict
    #         assert "originalOutput" in result_dict
    #         assert result_dict["success"] is True
    #         assert result_dict["isValid"] is True


class TestAIGuard
    #     """Test cases for AIGuard"""

    #     @pytest.fixture
    #     def guard_config(self):""Create a test guard configuration"""
            return GuardConfig(
    mode = GuardMode.ADAPTIVE,
    action_on_failure = GuardAction.WARN,
    max_correction_attempts = 2,
    timeout_ms = 1000,
    enable_logging = False
    #         )

    #     @pytest.fixture
    #     def ai_guard(self, guard_config):
    #         """Create a test AI guard"""
            return AIGuard(guard_config)

    #     def test_guard_initialization(self, guard_config):
    #         """Test guard initialization"""
    guard = AIGuard(guard_config)

    assert guard.config == guard_config
    #         assert guard.linter is not None
    assert guard.stats["total_validations"] = = 0

    #     def test_validate_valid_code(self, ai_guard):
    #         """Test validation of valid code"""
    valid_code = "// Simple NoodleCore code\nprint('Hello, World!');"

    #         with patch.object(ai_guard.linter, 'lint_source') as mock_lint:
    mock_result = Mock()
    mock_result.errors = []
    mock_result.warnings = []
    mock_lint.return_value = mock_result

    result = ai_guard.validate_output(valid_code)

    #             assert result.success is True
    #             assert result.is_valid is True
    assert result.original_output == valid_code
                assert result.has_errors() is False

    #     def test_validate_invalid_code(self, ai_guard):
    #         """Test validation of invalid code"""
    invalid_code = "invalid syntax"

    #         with patch.object(ai_guard.linter, 'lint_source') as mock_lint:
    mock_result = Mock()
    mock_result.errors = [
                    LinterError(
    code = "E104",
    message = "Syntax error",
    severity = "error",
    category = "syntax"
    #                 )
    #             ]
    mock_result.warnings = []
    mock_lint.return_value = mock_result

    result = ai_guard.validate_output(invalid_code)

    #             assert result.success is True  # WARN mode allows it
    #             assert result.is_valid is False
                assert result.has_errors() is True

    #     def test_validate_with_correction(self, ai_guard):
    #         """Test validation with correction callback"""
    invalid_code = "invalid syntax"
    corrected_code = "print('Hello, World!');"

    #         def correction_callback(original, errors):
    #             return corrected_code

    #         with patch.object(ai_guard.linter, 'lint_source') as mock_lint:
    #             # First call returns errors
    mock_result_invalid = Mock()
    mock_result_invalid.errors = [
                    LinterError(
    code = "E104",
    message = "Syntax error",
    severity = "error",
    category = "syntax"
    #                 )
    #             ]
    mock_result_invalid.warnings = []

    #             # Second call returns no errors
    mock_result_valid = Mock()
    mock_result_valid.errors = []
    mock_result_valid.warnings = []

    mock_lint.side_effect = [mock_result_invalid, mock_result_valid]

    result = ai_guard.validate_output(
    #                 invalid_code,
    correction_callback = correction_callback
    #             )

    #             assert result.success is True
    #             assert result.is_valid is True
    assert result.corrected_output == corrected_code
    assert result.correction_attempts = 1

    #     def test_get_statistics(self, ai_guard):
    #         """Test getting statistics"""
    stats = ai_guard.get_statistics()

    #         assert "total_validations" in stats
    #         assert "successful_validations" in stats
    #         assert "failed_validations" in stats
    #         assert "success_rate" in stats
    #         assert "total_time_ms" in stats
    #         assert "average_time_ms" in stats
    #         assert "cache_size" in stats
    #         assert "config" in stats

    #     def test_clear_cache(self, ai_guard):
    #         """Test clearing cache"""
            ai_guard.clear_cache()
    #         # No exception should be raised


class TestOutputInterceptor
    #     """Test cases for OutputInterceptor"""

    #     @pytest.fixture
    #     def mock_guard(self):""Create a mock guard"""
    guard = Mock()
    guard.validate_output.return_value = Mock(
    success = True,
    is_valid = True,
    original_output = "test",
    corrected_output = None,
    errors = [],
    warnings = []
    #         )
    #         return guard

    #     @pytest.fixture
    #     def interceptor_config(self):
    #         """Create a test interceptor configuration"""
            return InterceptionConfig(
    mode = InterceptionMode.BLOCKING,
    enable_logging = False
    #         )

    #     @pytest.fixture
    #     def output_interceptor(self, mock_guard, interceptor_config):
    #         """Create a test output interceptor"""
            return OutputInterceptor(mock_guard, interceptor_config)

    #     def test_interceptor_initialization(self, mock_guard, interceptor_config):
    #         """Test interceptor initialization"""
    interceptor = OutputInterceptor(mock_guard, interceptor_config)

    assert interceptor.guard == mock_guard
    assert interceptor.config == interceptor_config
    assert interceptor.stats["total_interceptions"] = = 0

    #     def test_intercept_valid_output(self, output_interceptor):
    #         """Test intercepting valid output"""
    content = "print('Hello, World!');"
    source = "test_ai"

    is_valid, final_content, guard_result = output_interceptor.intercept(
    #             content, source
    #         )

    #         assert is_valid is True
    assert final_content == content
    #         assert guard_result is not None

    #     def test_intercept_file_write(self, output_interceptor):
    #         """Test intercepting file write"""
    content = "print('Hello, World!');"
    file_path = "test.nc"
    source = "test_ai"

    is_valid, final_content, guard_result = output_interceptor.intercept_file_write(
    #             file_path, content, source
    #         )

    #         assert is_valid is True
    assert final_content == content
    #         assert guard_result is not None

    #     def test_register_hook(self, output_interceptor):
    #         """Test registering a hook"""
    #         def test_hook(intercepted):
    #             return intercepted

            output_interceptor.register_hook(InterceptionPoint.IDE_INTEGRATION, test_hook)

    #         assert test_hook in output_interceptor._hooks[InterceptionPoint.IDE_INTEGRATION]

    #     def test_get_statistics(self, output_interceptor):
    #         """Test getting statistics"""
    stats = output_interceptor.get_statistics()

    #         assert "total_interceptions" in stats
    #         assert "successful_validations" in stats
    #         assert "failed_validations" in stats
    #         assert "bypassed_interceptions" in stats
    #         assert "success_rate" in stats
    #         assert "total_time_ms" in stats
    #         assert "average_time_ms" in stats
    #         assert "cache_size" in stats
    #         assert "config" in stats


class TestSyntaxValidator
    #     """Test cases for SyntaxValidator"""

    #     @pytest.fixture
    #     def validator_config(self):""Create a test validator configuration"""
            return ValidationConfig(
    level = ValidationLevel.STANDARD,
    strategy = ValidationStrategy.COLLECT_ALL,
    enable_logging = False
    #         )

    #     @pytest.fixture
    #     def syntax_validator(self, validator_config):
    #         """Create a test syntax validator"""
            return SyntaxValidator(validator_config)

    #     def test_validator_initialization(self, validator_config):
    #         """Test validator initialization"""
    validator = SyntaxValidator(validator_config)

    assert validator.config == validator_config
    #         assert validator.linter is not None
    assert validator.stats["total_validations"] = = 0

    #     def test_validate_valid_code(self, syntax_validator):
    #         """Test validation of valid code"""
    valid_code = "print('Hello, World!');"

    #         with patch.object(syntax_validator.linter, 'lint_source') as mock_lint:
    mock_result = Mock()
    mock_result.errors = []
    mock_result.warnings = []
    mock_lint.return_value = mock_result

    result = syntax_validator.validate(valid_code)

    #             assert result.is_valid is True
                assert result.has_errors() is False
                assert result.has_warnings() is False

    #     def test_validate_invalid_code(self, syntax_validator):
    #         """Test validation of invalid code"""
    invalid_code = "invalid syntax"

    #         with patch.object(syntax_validator.linter, 'lint_source') as mock_lint:
    mock_result = Mock()
    mock_result.errors = [
                    LinterError(
    code = "E104",
    message = "Syntax error",
    severity = "error",
    category = "syntax"
    #                 )
    #             ]
    mock_result.warnings = []
    mock_lint.return_value = mock_result

    result = syntax_validator.validate(invalid_code)

    #             assert result.is_valid is False
                assert result.has_errors() is True
                assert len(result.suggestions) 0

    #     def test_validate_basic_syntax(self, syntax_validator)):
    #         """Test basic syntax validation"""
    valid_code = "print('Hello, World!');"

    #         with patch.object(syntax_validator.linter, 'lint_source') as mock_lint:
    mock_result = Mock()
    mock_result.errors = []
    mock_result.warnings = []
    mock_lint.return_value = mock_result

    result = syntax_validator.validate_basic_syntax(valid_code)

    #             assert result.is_valid is True

    #     def test_get_statistics(self, syntax_validator):
    #         """Test getting statistics"""
    stats = syntax_validator.get_statistics()

    #         assert "total_validations" in stats
    #         assert "successful_validations" in stats
    #         assert "failed_validations" in stats
    #         assert "success_rate" in stats
    #         assert "total_time_ms" in stats
    #         assert "average_time_ms" in stats
    #         assert "cache_size" in stats
    #         assert "config" in stats


class TestLinterBridge
    #     """Test cases for LinterBridge"""

    #     @pytest.fixture
    #     def bridge_config(self):""Create a test bridge configuration"""
            return LinterBridgeConfig(
    mode = CommunicationMode.DIRECT,
    priority = ValidationPriority.NORMAL,
    enable_logging = False
    #         )

    #     @pytest.fixture
    #     def linter_bridge(self, bridge_config):
    #         """Create a test linter bridge"""
            return LinterBridge(bridge_config)

    #     def test_bridge_initialization(self, bridge_config):
    #         """Test bridge initialization"""
    bridge = LinterBridge(bridge_config)

    assert bridge.config == bridge_config
    #         assert bridge.linter is not None
    assert bridge.stats["total_requests"] = = 0

    #     def test_validate_code(self, linter_bridge):
    #         """Test validating code"""
    code = "print('Hello, World!');"

    #         with patch.object(linter_bridge.linter, 'lint_source') as mock_lint:
    mock_result = Mock()
    mock_result.errors = []
    mock_result.warnings = []
    mock_result.success = True
    mock_result.to_dict.return_value = {}
    mock_lint.return_value = mock_result

    response = linter_bridge.validate(code)

    #             assert response.success is True
    #             assert response.result is not None

    #     def test_get_statistics(self, linter_bridge):
    #         """Test getting statistics"""
    stats = linter_bridge.get_statistics()

    #         assert "total_requests" in stats
    #         assert "successful_requests" in stats
    #         assert "failed_requests" in stats
    #         assert "success_rate" in stats
    #         assert "total_time_ms" in stats
    #         assert "average_time_ms" in stats
    #         assert "cache_size" in stats
    #         assert "batch_queue_size" in stats
    #         assert "config" in stats


class TestComplianceTracker
    #     """Test cases for ComplianceTracker"""

    #     @pytest.fixture
    #     def compliance_tracker(self):""Create a test compliance tracker"""
    return ComplianceTracker(enable_metrics = True)

    #     def test_tracker_initialization(self, compliance_tracker):
    #         """Test tracker initialization"""
    #         assert compliance_tracker.enable_metrics is True
    assert len(compliance_tracker.records) = = 0
    assert compliance_tracker.metrics.total_validations = 0

    #     def test_track_validation(self, compliance_tracker):
    #         """Test tracking a validation"""
    #         # Create a mock guard result
    guard_result = Mock()
    guard_result.original_output = "print('Hello, World!');"
    guard_result.corrected_output = None
    guard_result.correction_attempts = 0
    guard_result.execution_time_ms = 100
    guard_result.success = True
    guard_result.has_errors.return_value = False
    guard_result.has_warnings.return_value = False
    guard_result.errors = []
    guard_result.warnings = []
    guard_result.metadata = {}

    record = compliance_tracker.track_validation(guard_result, "test_ai")

    assert record.ai_source = = "test_ai"
    assert record.original_output = = "print('Hello, World!');"
    assert record.compliance_level == ComplianceLevel.COMPLIANT
    assert len(compliance_tracker.records) = = 1
    assert compliance_tracker.metrics.total_validations = 1

    #     def test_get_compliance_report(self, compliance_tracker):
    #         """Test getting compliance report"""
    #         # Add a record first
    guard_result = Mock()
    guard_result.original_output = "print('Hello, World!');"
    guard_result.corrected_output = None
    guard_result.correction_attempts = 0
    guard_result.execution_time_ms = 100
    guard_result.success = True
    guard_result.has_errors.return_value = False
    guard_result.has_warnings.return_value = False
    guard_result.errors = []
    guard_result.warnings = []
    guard_result.metadata = {}

            compliance_tracker.track_validation(guard_result, "test_ai")

    report = compliance_tracker.get_compliance_report()

    #         assert "period" in report
    #         assert "filters" in report
    #         assert "summary" in report
    #         assert "compliance_levels" in report
    #         assert "corrections" in report
    #         assert "issue_statistics" in report
    #         assert "top_issues" in report
    #         assert "metrics" in report

    #     def test_get_metrics(self, compliance_tracker):
    #         """Test getting metrics"""
    metrics = compliance_tracker.get_metrics()

    assert metrics.total_validations = 0
    assert metrics.compliance_rate = 0.0

    #     def test_get_issue_statistics(self, compliance_tracker):
    #         """Test getting issue statistics"""
    stats = compliance_tracker.get_issue_statistics()

    #         assert "syntax" in stats
    #         assert "semantic" in stats
    #         assert "style" in stats
    #         assert "security" in stats
    #         assert "performance" in stats
    #         assert "best_practice" in stats
    #         assert "forbidden_structure" in stats

    #     def test_clear_records(self, compliance_tracker):
    #         """Test clearing records"""
            compliance_tracker.clear_records()

    assert len(compliance_tracker.records) = = 0
    assert compliance_tracker.metrics.total_validations = 0


if __name__ == "__main__"
        pytest.main([__file__])