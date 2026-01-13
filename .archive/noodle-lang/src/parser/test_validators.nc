# Converted from Python to NoodleCore
# Original file: src

# """
# Unit tests for Validator Components

# This module contains comprehensive unit tests for all validator components,
# testing validation logic, error detection, performance, caching, and integration.
# """

import pytest
import sys
import os
import time
import tempfile
import pathlib.Path
import unittest.mock.Mock
import typing.Dict

# Add src to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

import noodlecore.cli.validators.validator_base.(
#     ValidatorBase,
#     ValidationSeverity,
#     ValidationStatus,
#     ValidationIssue,
#     ValidationResult
# )

import noodlecore.cli.validators.syntax_validator.SyntaxValidator


class TestValidationSeverity
    #     """Test the ValidationSeverity enum."""

    #     def test_validation_severity_values(self):""Test that ValidationSeverity has the expected values."""
    assert ValidationSeverity.ERROR.value = = "error"
    assert ValidationSeverity.WARNING.value = = "warning"
    assert ValidationSeverity.INFO.value = = "info"


class TestValidationStatus
    #     """Test the ValidationStatus enum."""

    #     def test_validation_status_values(self):""Test that ValidationStatus has the expected values."""
    assert ValidationStatus.PASSED.value = = "PASSED"
    assert ValidationStatus.FAILED.value = = "FAILED"
    assert ValidationStatus.SKIPPED.value = = "SKIPPED"


class TestValidationIssue
    #     """Test the ValidationIssue class."""

    #     def test_validation_issue_initialization(self):""Test that ValidationIssue initializes correctly."""
    issue = ValidationIssue(
    line = 10,
    column = 5,
    message = "Test issue",
    severity = ValidationSeverity.ERROR,
    code = "2001",
    rule = "test_rule",
    suggestion = "Fix the issue"
    #         )

    assert issue.line = 10
    assert issue.column = 5
    assert issue.message = = "Test issue"
    assert issue.severity == ValidationSeverity.ERROR
    assert issue.code = = "2001"
    assert issue.rule = = "test_rule"
    assert issue.suggestion = = "Fix the issue"

    #     def test_validation_issue_defaults(self):
    #         """Test ValidationIssue with default values."""
    issue = ValidationIssue()

    #         assert issue.line is None
    #         assert issue.column is None
    assert issue.message = = ""
    assert issue.severity == ValidationSeverity.ERROR
    assert issue.code = = ""
    #         assert issue.rule is None
    #         assert issue.suggestion is None


class TestValidationResult
    #     """Test the ValidationResult class."""

    #     def test_validation_result_initialization(self):""Test that ValidationResult initializes correctly."""
    result = ValidationResult(
    status = ValidationStatus.FAILED,
    issues = [],
    metrics = {"test": "value"},
    request_id = "test-request-id",
    validator_name = "TestValidator",
    file_path = "/test/file.nc"
    #         )

    assert result.status == ValidationStatus.FAILED
    assert result.issues = = []
    assert result.metrics["test"] = = "value"
    assert result.request_id = = "test-request-id"
    assert result.validator_name = = "TestValidator"
    assert result.file_path = = "/test/file.nc"

    #     def test_validation_result_add_error(self):
    #         """Test adding an error issue to ValidationResult."""
    result = ValidationResult()

    error_issue = ValidationIssue(
    message = "Error message",
    severity = ValidationSeverity.ERROR
    #         )

            result.add_issue(error_issue)

    assert result.status == ValidationStatus.FAILED
    assert len(result.issues) = = 1
    assert len(result.errors) = = 1
    assert len(result.warnings) = = 0
    assert result.error_count = 1
    assert result.warning_count = 0

    #     def test_validation_result_add_warning(self):
    #         """Test adding a warning issue to ValidationResult."""
    result = ValidationResult()

    warning_issue = ValidationIssue(
    message = "Warning message",
    severity = ValidationSeverity.WARNING
    #         )

            result.add_issue(warning_issue)

    assert result.status == ValidationStatus.PASSED
    assert len(result.issues) = = 1
    assert len(result.errors) = = 0
    assert len(result.warnings) = = 1
    assert result.error_count = 0
    assert result.warning_count = 1

    #     def test_validation_result_to_dict(self):
    #         """Test converting ValidationResult to dictionary."""
    result = ValidationResult(
    validator_name = "TestValidator",
    file_path = "/test/file.nc"
    #         )

            result.add_issue(ValidationIssue(
    line = 10,
    message = "Test error",
    severity = ValidationSeverity.ERROR,
    code = "2001"
    #         ))

    result_dict = result.to_dict()

    assert result_dict["status"] = = "FAILED"
    assert result_dict["error_count"] = = 1
    assert result_dict["warning_count"] = = 0
    assert len(result_dict["issues"]) = = 1
    assert result_dict["issues"][0]["line"] = = 10
    assert result_dict["issues"][0]["message"] = = "Test error"
    assert result_dict["issues"][0]["severity"] = = "error"
    assert result_dict["issues"][0]["code"] = = "2001"
    assert result_dict["validator"] = = "TestValidator"
    assert result_dict["file_path"] = = "/test/file.nc"
    #         assert "request_id" in result_dict
    #         assert "timestamp" in result_dict


class MockValidator(ValidatorBase)
    #     """Mock validator for testing ValidatorBase."""

    #     async def validate(self, code: str, **kwargs) -ValidationResult):
    #         """Mock validation method."""
    result = ValidationResult(validator_name=self.name)

    #         # Simple validation logic for testing
    #         if "error" in code:
                result.add_issue(ValidationIssue(
    message = "Mock error",
    severity = ValidationSeverity.ERROR,
    code = "2001"
    #             ))

    #         if "warning" in code:
                result.add_issue(ValidationIssue(
    message = "Mock warning",
    severity = ValidationSeverity.WARNING,
    code = "2002"
    #             ))

    #         return result


class TestValidatorBase
    #     """Test the ValidatorBase class."""

    #     def test_validator_base_initialization(self):""Test that ValidatorBase initializes correctly."""
    validator = MockValidator("TestValidator", {"test": "config"})

    assert validator.name = = "TestValidator"
    assert validator.config["test"] = = "config"
    assert validator._cache = = {}
    assert validator._metrics["validations_performed"] = = 0
    assert validator._metrics["total_validation_time"] = = 0.0
    assert validator._metrics["cache_hits"] = = 0
    assert validator._metrics["cache_misses"] = = 0

    #     @pytest.mark.asyncio
    #     async def test_validator_validate_success(self):
    #         """Test successful validation."""
    validator = MockValidator("TestValidator")

    result = await validator.validate("valid code")

    assert result.validator_name = = "TestValidator"
    assert result.status == ValidationStatus.PASSED
    assert len(result.issues) = = 0

    #     @pytest.mark.asyncio
    #     async def test_validator_validate_with_error(self):
    #         """Test validation with error."""
    validator = MockValidator("TestValidator")

    #         result = await validator.validate("code with error")

    assert result.validator_name = = "TestValidator"
    assert result.status == ValidationStatus.FAILED
    assert len(result.issues) = = 1
    assert result.issues[0].severity == ValidationSeverity.ERROR

    #     @pytest.mark.asyncio
    #     async def test_validator_validate_with_warning(self):
    #         """Test validation with warning."""
    validator = MockValidator("TestValidator")

    #         result = await validator.validate("code with warning")

    assert result.validator_name = = "TestValidator"
    assert result.status == ValidationStatus.PASSED
    assert len(result.issues) = = 1
    assert result.issues[0].severity == ValidationSeverity.WARNING

    #     @pytest.mark.asyncio
    #     async def test_validator_validate_file_success(self):
    #         """Test successful file validation."""
    validator = MockValidator("TestValidator")

    #         # Create a temporary file
    #         with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.nc') as f:
                f.write("valid code")
    temp_file = f.name

    #         try:
    result = await validator.validate_file(temp_file)

    assert result.validator_name = = "TestValidator"
    assert result.file_path == temp_file
    assert result.status == ValidationStatus.PASSED
    assert len(result.issues) = = 0
    #         finally:
                os.unlink(temp_file)

    #     @pytest.mark.asyncio
    #     async def test_validator_validate_file_not_found(self):
    #         """Test file validation with file not found."""
    validator = MockValidator("TestValidator")

    result = await validator.validate_file("/nonexistent/file.nc")

    assert result.validator_name = = "TestValidator"
    assert result.file_path = = "/nonexistent/file.nc"
    assert result.status == ValidationStatus.FAILED
    assert len(result.issues) = = 1
    assert result.issues[0].message = = "File not found: /nonexistent/file.nc"
    assert result.issues[0].code = = "2001"

    #     @pytest.mark.asyncio
    #     async def test_validator_validate_multiple_files(self):
    #         """Test validating multiple files."""
    validator = MockValidator("TestValidator")

    #         # Create temporary files
    temp_files = []
    #         try:
    #             for i, content in enumerate(["valid code", "code with error", "code with warning"]):
    #                 with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.nc') as f:
                        f.write(content)
                        temp_files.append(f.name)

    results = await validator.validate_multiple_files(temp_files)

    assert len(results) = = 3
    assert results[0].status == ValidationStatus.PASSED
    assert results[1].status == ValidationStatus.FAILED
    assert results[2].status == ValidationStatus.PASSED
    #         finally:
    #             for temp_file in temp_files:
                    os.unlink(temp_file)

    #     def test_validator_cache_key(self):
    #         """Test cache key generation."""
    validator = MockValidator("TestValidator")

    key1 = validator._get_cache_key("test code", param1="value1")
    key2 = validator._get_cache_key("test code", param1="value1")
    key3 = validator._get_cache_key("test code", param1="value2")
    key4 = validator._get_cache_key("different code", param1="value1")

    assert key1 == key2  # Same content and params
    assert key1 != key3  # Different params
    assert key1 != key4  # Different content

    #     def test_validator_cache_operations(self):
    #         """Test cache operations."""
    validator = MockValidator("TestValidator")

    result = ValidationResult(validator_name="TestValidator")
    cache_key = "test_key"

    #         # Test cache miss
    cached_result = validator._get_cached_result(cache_key)
    #         assert cached_result is None
    assert validator._metrics["cache_misses"] = = 1
    assert validator._metrics["cache_hits"] = = 0

    #         # Test cache store and hit
            validator._cache_result(cache_key, result)
    cached_result = validator._get_cached_result(cache_key)
    #         assert cached_result is result
    assert validator._metrics["cache_misses"] = = 1
    assert validator._metrics["cache_hits"] = = 1

    #     def test_validator_metrics(self):
    #         """Test validator metrics."""
    validator = MockValidator("TestValidator")

    #         # Initial metrics
    metrics = validator.get_metrics()
    assert metrics["validations_performed"] = = 0
    assert metrics["total_validation_time"] = = 0.0
    assert metrics["average_validation_time"] = = 0.0
    assert metrics["cache_hit_rate"] = = 0.0

    #         # Update metrics
    start_time = time.time()
            time.sleep(0.01)  # Small delay to ensure non-zero time
            validator._update_metrics(start_time)

    metrics = validator.get_metrics()
    assert metrics["validations_performed"] = = 1
    #         assert metrics["total_validation_time"] 0.0
    #         assert metrics["average_validation_time"] > 0.0

    #     def test_validator_reset_metrics(self)):
    #         """Test resetting validator metrics."""
    validator = MockValidator("TestValidator")

    #         # Update metrics
            validator._update_metrics(time.time())
    validator._metrics["cache_hits"] = 5
    validator._metrics["cache_misses"] = 5

    #         # Reset metrics
            validator.reset_metrics()

    metrics = validator.get_metrics()
    assert metrics["validations_performed"] = = 0
    assert metrics["total_validation_time"] = = 0.0
    assert metrics["cache_hits"] = = 0
    assert metrics["cache_misses"] = = 0

    #     def test_validator_clear_cache(self):
    #         """Test clearing validator cache."""
    validator = MockValidator("TestValidator")

    #         # Add to cache
    result = ValidationResult(validator_name="TestValidator")
            validator._cache_result("test_key", result)

    #         # Verify cache has content
    assert len(validator._cache) = = 1

    #         # Clear cache
            validator.clear_cache()

    #         # Verify cache is empty
    assert len(validator._cache) = = 0

    #     def test_validator_supported_extensions(self):
    #         """Test getting supported file extensions."""
    validator = MockValidator("TestValidator")

    extensions = validator.get_supported_extensions()

    #         assert ".nc" in extensions
    #         assert ".noodlecore" in extensions

    #     @pytest.mark.asyncio
    #     async def test_validator_get_info(self):
    #         """Test getting validator information."""
    validator = MockValidator("TestValidator", {"test": "config"})

    info = await validator.get_validator_info()

    assert info["name"] = = "TestValidator"
    assert info["config"]["test"] = = "config"
    #         assert ".nc" in info["supported_extensions"]
    #         assert "metrics" in info


class TestSyntaxValidator
    #     """Test the SyntaxValidator class."""

    #     def test_syntax_validator_initialization(self):""Test that SyntaxValidator initializes correctly."""
    validator = SyntaxValidator()

    assert validator.name = = "SyntaxValidator"
    #         assert validator.grammar is not None
    #         assert 'module_declaration' in validator.required_constructs
    #         assert 'entry_point' in validator.required_constructs
            assert len(validator.error_codes) 0
    #         assert 'invalid_token' in validator.error_codes

    #     def test_syntax_validator_custom_config(self)):
    #         """Test SyntaxValidator with custom configuration."""
    config = {"strict_mode": True}
    validator = SyntaxValidator(config)

    #         assert validator.config["strict_mode"] is True

    #     @pytest.mark.asyncio
    #     async def test_syntax_validator_valid_code(self):
    #         """Test validating valid NoodleCore code."""
    validator = SyntaxValidator()

    #         # Mock the grammar methods
    #         with patch.object(validator.grammar, 'tokenize_only', return_value=[]), \
    patch.object(validator.grammar, 'parse', return_value = ([], Mock(node_type="Program", children=[]))):

    code = """
    #             module test.module:

                entry main(args):
                    print("Hello, World!")
    #             end
    #             """

    result = await validator.validate(code)

    assert result.validator_name = = "SyntaxValidator"
    assert result.status == ValidationStatus.PASSED
    assert len(result.issues) = = 0

    #     @pytest.mark.asyncio
    #     async def test_syntax_validator_invalid_code(self):
    #         """Test validating invalid NoodleCore code."""
    validator = SyntaxValidator()

    #         # Mock the grammar methods to return invalid tokens
    #         from noodlecore.cli.validators.grammar import Token, TokenType

    invalid_token = Token(
    type = TokenType.UNKNOWN,
    value = "@@invalid@@",
    line = 1,
    column = 1
    #         )

    #         with patch.object(validator.grammar, 'tokenize_only', return_value=[invalid_token]), \
    patch.object(validator.grammar, 'parse', return_value = ([], Mock(node_type="Program", children=[]))):

    code = "@@invalid@@"

    result = await validator.validate(code)

    assert result.validator_name = = "SyntaxValidator"
    assert result.status == ValidationStatus.FAILED
                assert len(result.issues) 0
    #             assert any("Unknown token" in issue.message for issue in result.issues)

    #     @pytest.mark.asyncio
    #     async def test_syntax_validator_strict_mode(self)):
    #         """Test validating in strict mode."""
    validator = SyntaxValidator()

    #         # Mock the grammar methods
    #         with patch.object(validator.grammar, 'tokenize_only', return_value=[]), \
    patch.object(validator.grammar, 'parse', return_value = ([], Mock(node_type="Program", children=[]))):

    code = """
    #             # No module declaration or entry point
                print("Hello, World!")
    #             """

    #             # Non-strict mode should pass
    result = await validator.validate(code, strict_mode=False)
    assert result.status == ValidationStatus.PASSED

    #             # Strict mode should fail
    result = await validator.validate(code, strict_mode=True)
    assert result.status == ValidationStatus.FAILED
    #             assert any("Missing module declaration" in issue.message for issue in result.issues)

    #     @pytest.mark.asyncio
    #     async def test_syntax_validator_caching(self):
    #         """Test that validation results are cached."""
    validator = SyntaxValidator()

    #         # Mock the grammar methods
    #         with patch.object(validator.grammar, 'tokenize_only', return_value=[]), \
    patch.object(validator.grammar, 'parse', return_value = ([], Mock(node_type="Program", children=[]))):

    code = "module test: entry main(): print('Hello') end"

    #             # First validation
    start_time = time.time()
    result1 = await validator.validate(code)
    first_validation_time = time.time() - start_time

    #             # Second validation should use cache
    start_time = time.time()
    result2 = await validator.validate(code)
    second_validation_time = time.time() - start_time

    #             # Results should be identical
    assert result1.request_id == result2.request_id
    assert result1.issues == result2.issues

                # Second validation should be faster (cache hit)
    #             assert second_validation_time < first_validation_time

    #             # Verify cache metrics
    metrics = validator.get_metrics()
    #             assert metrics["cache_hits"] 0

    #     def test_syntax_validator_is_valid_string_literal(self)):
    #         """Test string literal validation."""
    validator = SyntaxValidator()

    #         # Valid string literals
            assert validator._is_valid_string_literal('"test"') is True
            assert validator._is_valid_string_literal("'test'") is True

    #         # Invalid string literals
            assert validator._is_valid_string_literal('"test') is False
            assert validator._is_valid_string_literal('test"') is False
            assert validator._is_valid_string_literal('test') is False
            assert validator._is_valid_string_literal('') is False

    #     def test_syntax_validator_is_valid_identifier(self):
    #         """Test identifier validation."""
    validator = SyntaxValidator()

    #         # Valid identifiers
            assert validator._is_valid_identifier("test") is True
            assert validator._is_valid_identifier("_test") is True
            assert validator._is_valid_identifier("test123") is True
            assert validator._is_valid_identifier("test_123") is True

    #         # Invalid identifiers
            assert validator._is_valid_identifier("123test") is False
            assert validator._is_valid_identifier("test-name") is False
            assert validator._is_valid_identifier("test name") is False
            assert validator._is_valid_identifier("") is False

    #     def test_syntax_validator_count_ast_nodes(self):
    #         """Test AST node counting."""
    validator = SyntaxValidator()

    #         # Create a mock AST node
    root = Mock(node_type="Program")
    child1 = Mock(node_type="Function")
    child2 = Mock(node_type="Variable")
    grandchild = Mock(node_type="Parameter")

    root.children = [child1, child2]
    child1.children = [grandchild]
    child2.children = []
    grandchild.children = []

    count = validator._count_ast_nodes(root)

    #         # Should count all nodes: root, child1, child2, grandchild
    assert count = 4

    #     @pytest.mark.asyncio
    #     async def test_syntax_validator_get_syntax_info(self):
    #         """Test getting syntax information."""
    validator = SyntaxValidator()

    #         # Mock grammar methods
    #         with patch.object(validator.grammar, 'get_keywords', return_value=["module", "entry", "func"]), \
    patch.object(validator.grammar, 'get_operators', return_value = ["+", "-", "*"]):

    info = await validator.get_syntax_info()

    assert info["language"] = = "NoodleCore"
    assert info["version"] = = "1.0"
    #             assert "module_declaration" in info["supported_constructs"]
    assert info["validator"] = = "SyntaxValidator"
    #             assert "module" in info["keywords"]
    #             assert "+" in info["operators"]
                assert len(info["features"]) 0
    #             assert "error_codes" in info


class TestValidatorIntegration
    #     """Test integration scenarios for validators."""

    #     @pytest.mark.asyncio
    #     async def test_multiple_validators(self)):
    #         """Test using multiple validators."""
    syntax_validator = SyntaxValidator()
    mock_validator = MockValidator("MockValidator")

    #         # Mock the grammar methods
    #         with patch.object(syntax_validator.grammar, 'tokenize_only', return_value=[]), \
    patch.object(syntax_validator.grammar, 'parse', return_value = ([], Mock(node_type="Program", children=[]))):

    code = "module test: entry main(): print('Hello') end"

    #             # Run both validators
    syntax_result = await syntax_validator.validate(code)
    mock_result = await mock_validator.validate(code)

    #             # Both should pass
    assert syntax_result.status == ValidationStatus.PASSED
    assert mock_result.status == ValidationStatus.PASSED

    #     @pytest.mark.asyncio
    #     async def test_validator_error_propagation(self):
    #         """Test error propagation in validators."""
    validator = MockValidator("TestValidator")

    #         # Mock an exception during validation
    #         with patch.object(validator, 'validate', side_effect=Exception("Test error")):
    #             with pytest.raises(Exception):
                    await validator.validate("test code")

    #     @pytest.mark.asyncio
    #     async def test_validator_performance(self, performance_monitor):
    #         """Test validator performance."""
    validator = SyntaxValidator()

    #         # Mock the grammar methods
    #         with patch.object(validator.grammar, 'tokenize_only', return_value=[]), \
    patch.object(validator.grammar, 'parse', return_value = ([], Mock(node_type="Program", children=[]))):

    code = "module test: entry main(): print('Hello') end"

                performance_monitor.start_timing("validation")
    result = await validator.validate(code)
    duration = performance_monitor.end_timing("validation")

    assert result.status == ValidationStatus.PASSED
    #             assert duration < 1.0  # Should complete within 1 second

    #     @pytest.mark.asyncio
    #     async def test_concurrent_validation(self):
    #         """Test concurrent validation."""
    #         import asyncio

    validator = SyntaxValidator()

    #         # Mock the grammar methods
    #         with patch.object(validator.grammar, 'tokenize_only', return_value=[]), \
    patch.object(validator.grammar, 'parse', return_value = ([], Mock(node_type="Program", children=[]))):

    codes = [
                    "module test1: entry main(): print('Hello1') end",
                    "module test2: entry main(): print('Hello2') end",
                    "module test3: entry main(): print('Hello3') end"
    #             ]

    #             # Validate concurrently
    #             tasks = [validator.validate(code) for code in codes]
    results = await asyncio.gather( * tasks)

    #             # All should pass
    assert len(results) = = 3
    #             assert all(result.status == ValidationStatus.PASSED for result in results)

    #     @pytest.mark.asyncio
    #     async def test_validator_file_validation_integration(self):
    #         """Test file validation integration."""
    validator = SyntaxValidator()

    #         # Create a temporary file
    #         with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.nc') as f:
                f.write("module test.file: entry main(): print('Hello') end")
    temp_file = f.name

    #         try:
    #             # Mock the grammar methods
    #             with patch.object(validator.grammar, 'tokenize_only', return_value=[]), \
    patch.object(validator.grammar, 'parse', return_value = ([], Mock(node_type="Program", children=[]))):

    result = await validator.validate_file(temp_file)

    assert result.validator_name = = "SyntaxValidator"
    assert result.file_path == temp_file
    assert result.status == ValidationStatus.PASSED
    assert len(result.issues) = = 0
    #         finally:
                os.unlink(temp_file)