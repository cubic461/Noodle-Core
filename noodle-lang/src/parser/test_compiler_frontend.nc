# Converted from Python to NoodleCore
# Original file: src

# """
# Test suite for the Compiler Frontend module
# ------------------------------------------

# This test suite verifies the functionality of the real-time compiler frontend
# for NoodleCore, including parsing, caching, and integration capabilities.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import pytest
import time
import uuid
import unittest.mock.Mock

import noodlecore.compiler.frontend.(
#     CompilerFrontend, FrontendConfig, FrontendError, ParseRequest, ParseResult,
#     ParsingMode, CacheStrategy, get_frontend, parse_code, parse_file, parse_snippet
# )
import noodlecore.compiler.parser.ParserError
import noodlecore.ai.guard.GuardMode
import noodlecore.ai.linter_bridge.ValidationRequest


class TestFrontendConfig
    #     """Test cases for FrontendConfig"""

    #     def test_default_config(self):""Test default configuration"""
    config = FrontendConfig()

    assert config.parsing_mode == ParsingMode.INCREMENTAL
    assert config.cache_strategy == CacheStrategy.MEMORY
    assert config.cache_size = 100
    assert config.timeout_ms = 5000
    #         assert config.enable_error_recovery is True
    #         assert config.enable_incremental_parsing is True
    #         assert config.enable_position_tracking is True
    #         assert config.enable_symbol_table is True
    #         assert config.enable_type_inference is True
    assert config.max_concurrent_parsers = 5
    assert config.retry_attempts = 3
    #         assert config.debug_mode is False

    #     def test_config_to_dict(self):
    #         """Test configuration to dictionary conversion"""
    config = FrontendConfig(
    parsing_mode = ParsingMode.FULL,
    cache_strategy = CacheStrategy.LRU,
    cache_size = 200
    #         )

    config_dict = config.to_dict()

    assert config_dict["parsing_mode"] = = "full"
    assert config_dict["cache_strategy"] = = "lru"
    assert config_dict["cache_size"] = = 200


class TestParseRequest
    #     """Test cases for ParseRequest"""

    #     def test_parse_request_creation(self):""Test parse request creation"""
    code = "print('Hello, World!')"
    request = ParseRequest(code=code)

    assert request.code == code
    #         assert request.file_path is None
    assert request.mode == ParsingMode.INCREMENTAL
    assert request.metadata = = {}
            assert isinstance(request.request_id, str)
            assert isinstance(request.timestamp, float)

    #     def test_parse_request_to_dict(self):
    #         """Test parse request to dictionary conversion"""
    code = "print('Hello, World!')"
    request = ParseRequest(
    code = code,
    file_path = "test.nc",
    mode = ParsingMode.FULL,
    metadata = {"test": True}
    #         )

    request_dict = request.to_dict()

    assert request_dict["code"] = = code
    assert request_dict["filePath"] = = "test.nc"
    assert request_dict["mode"] = = "full"
    #         assert request_dict["metadata"]["test"] is True


class TestParseResult
    #     """Test cases for ParseResult"""

    #     def test_parse_result_creation(self):""Test parse result creation"""
    result = ParseResult(
    request_id = "test-id",
    success = True
    #         )

    assert result.request_id = = "test-id"
    #         assert result.success is True
    #         assert result.ast is None
    assert result.errors = = []
    assert result.warnings = = []
    assert result.execution_time_ms = 0
    #         assert result.cache_hit is False
            assert isinstance(result.timestamp, float)

    #     def test_parse_result_to_dict(self):
    #         """Test parse result to dictionary conversion"""
    result = ParseResult(
    request_id = "test-id",
    success = False,
    errors = [ParserError("Test error", 1, 5)],
    warnings = ["Test warning"],
    execution_time_ms = 100
    #         )

    result_dict = result.to_dict()

    assert result_dict["requestId"] = = "test-id"
    #         assert result_dict["success"] is False
    assert len(result_dict["errors"]) = = 1
    assert result_dict["errors"][0]["message"] = = "Test error"
    assert result_dict["errors"][0]["line"] = = 1
    assert result_dict["errors"][0]["column"] = = 5
    assert result_dict["warnings"] = = ["Test warning"]
    assert result_dict["executionTimeMs"] = = 100


class TestFrontendError
    #     """Test cases for FrontendError"""

    #     def test_frontend_error_creation(self):""Test frontend error creation"""
    error = FrontendError("Test error", 1001)

    assert str(error) = = "FrontendError[1001]: Test error"
    assert error.message = = "Test error"
    assert error.code = 1001
    assert error.details = = {}

    #     def test_frontend_error_with_details(self):
    #         """Test frontend error with details"""
    details = {"file": "test.nc", "line": 10}
    error = FrontendError("Test error", 1002, details)

    assert error.details == details


class TestCompilerFrontend
    #     """Test cases for CompilerFrontend"""

    #     def test_frontend_initialization(self):""Test frontend initialization"""
    config = FrontendConfig(cache_strategy=CacheStrategy.NONE)
    frontend = CompilerFrontend(config)

    assert frontend.config == config
    assert frontend.stats["total_requests"] = = 0
    assert frontend.stats["successful_requests"] = = 0
    assert frontend.stats["failed_requests"] = = 0
    assert frontend.stats["cache_hits"] = = 0
    assert frontend.stats["total_time_ms"] = = 0
    assert frontend._ast_cache = = {}
    #         assert frontend._linter_callback is None
    #         assert frontend._ai_guard_callback is None
    #         assert frontend._ide_callback is None

    #     def test_parse_simple_code(self):
    #         """Test parsing simple code"""
    frontend = CompilerFrontend()
    code = "print('Hello, World!')"

    result = frontend.parse(code)

    #         assert result.success is True
    #         assert result.request_id is not None
    assert result.execution_time_ms = 0
    #         assert result.cache_hit is False

    #     def test_parse_with_file_path(self)):
    #         """Test parsing with file path"""
    frontend = CompilerFrontend()
    code = "print('Hello, World!')"
    file_path = "test.nc"

    result = frontend.parse(code, file_path)

    #         assert result.success is True
    #         assert result.request_id is not None

    #     def test_parse_with_different_modes(self):
    #         """Test parsing with different modes"""
    frontend = CompilerFrontend()
    code = "print('Hello, World!')"

    #         # Test FULL mode
    result = frontend.parse(code, mode=ParsingMode.FULL)
    #         assert result.success is True

    #         # Test PARTIAL mode
    result = frontend.parse(code, mode=ParsingMode.PARTIAL)
    #         assert result.success is True

    #         # Test INCREMENTAL mode
    result = frontend.parse(code, mode=ParsingMode.INCREMENTAL)
    #         assert result.success is True

    #     def test_parse_with_caching(self):
    #         """Test parsing with caching"""
    config = FrontendConfig(cache_strategy=CacheStrategy.MEMORY)
    frontend = CompilerFrontend(config)
    code = "print('Hello, World!')"

    #         # First parse
    result1 = frontend.parse(code)
    #         assert result1.success is True
    #         assert result1.cache_hit is False

            # Second parse (should hit cache)
    result2 = frontend.parse(code)
    #         assert result2.success is True
    #         assert result2.cache_hit is True

    #     def test_parse_with_lru_cache(self):
    #         """Test parsing with LRU cache"""
    config = FrontendConfig(cache_strategy=CacheStrategy.LRU, cache_size=2)
    frontend = CompilerFrontend(config)

    #         # Parse first code
    result1 = frontend.parse("print('Code 1')")
    #         assert result1.success is True
    #         assert result1.cache_hit is False

    #         # Parse second code
    result2 = frontend.parse("print('Code 2')")
    #         assert result2.success is True
    #         assert result2.cache_hit is False

            # Parse third code (should evict first)
    result3 = frontend.parse("print('Code 3')")
    #         assert result3.success is True
    #         assert result3.cache_hit is False

            # Parse first code again (should miss cache)
    result4 = frontend.parse("print('Code 1')")
    #         assert result4.success is True
    #         assert result4.cache_hit is False

            # Parse second code again (should hit cache)
    result5 = frontend.parse("print('Code 2')")
    #         assert result5.success is True
    #         assert result5.cache_hit is True

    #     def test_parse_snippet(self):
    #         """Test parsing a code snippet"""
    frontend = CompilerFrontend()
    code = "x = 5"

    result = frontend.parse_snippet(code)

    #         assert result.success is True
    #         assert result.request_id is not None

    #     def test_reparse_with_changes(self):
    #         """Test reparsing with changes"""
    frontend = CompilerFrontend()
    original_code = "x = 5"
    changes = [(5, 5, " + 3")]  # Insert " + 3" at position 5

    result = frontend.reparse_with_changes(original_code, changes)

    #         assert result.success is True
    #         assert result.request_id is not None

    #     def test_set_linter_callback(self):
    #         """Test setting linter callback"""
    frontend = CompilerFrontend()
    callback = Mock()

            frontend.set_linter_callback(callback)

    assert frontend._linter_callback == callback

    #     def test_set_ai_guard_callback(self):
    #         """Test setting AI guard callback"""
    frontend = CompilerFrontend()
    callback = Mock()

            frontend.set_ai_guard_callback(callback)

    assert frontend._ai_guard_callback == callback

    #     def test_set_ide_callback(self):
    #         """Test setting IDE callback"""
    frontend = CompilerFrontend()
    callback = Mock()

            frontend.set_ide_callback(callback)

    assert frontend._ide_callback == callback

    #     def test_trigger_callbacks(self):
    #         """Test triggering callbacks"""
    frontend = CompilerFrontend()

    #         # Set up mocks
    linter_callback = Mock()
    ai_guard_callback = Mock()
    ide_callback = Mock()

            frontend.set_linter_callback(linter_callback)
            frontend.set_ai_guard_callback(ai_guard_callback)
            frontend.set_ide_callback(ide_callback)

    #         # Parse code to trigger callbacks
    code = "print('Hello, World!')"
            frontend.parse(code)

    #         # Verify callbacks were called
            linter_callback.assert_called_once()
            ai_guard_callback.assert_called_once()
            ide_callback.assert_called_once()

    #     def test_get_statistics(self):
    #         """Test getting statistics"""
    frontend = CompilerFrontend()

    #         # Parse some code
            frontend.parse("print('Test 1')")
            frontend.parse("print('Test 2')")

    stats = frontend.get_statistics()

    assert stats["total_requests"] = = 2
    assert stats["successful_requests"] = = 2
    assert stats["failed_requests"] = = 0
    assert stats["success_rate"] = = 1.0
    assert stats["total_time_ms"] = 0
    assert stats["average_time_ms"] > = 0
    #         assert "config" in stats

    #     def test_clear_cache(self)):
    #         """Test clearing cache"""
    config = FrontendConfig(cache_strategy=CacheStrategy.MEMORY)
    frontend = CompilerFrontend(config)

    #         # Parse code to populate cache
            frontend.parse("print('Test')")
            assert len(frontend._ast_cache) 0

    #         # Clear cache
            frontend.clear_cache()
    assert len(frontend._ast_cache) = = 0

    #     def test_reset_statistics(self)):
    #         """Test resetting statistics"""
    frontend = CompilerFrontend()

    #         # Parse some code
            frontend.parse("print('Test')")
    #         assert frontend.stats["total_requests"] 0

    #         # Reset statistics
            frontend.reset_statistics()
    assert frontend.stats["total_requests"] = = 0
    assert frontend.stats["successful_requests"] = = 0
    assert frontend.stats["failed_requests"] = = 0
    assert frontend.stats["cache_hits"] = = 0
    assert frontend.stats["total_time_ms"] = = 0

    patch('builtins.open', side_effect = IOError("File not found"))
    #     def test_parse_file_error(self, mock_open)):
    #         """Test parsing a file with error"""
    frontend = CompilerFrontend()

    #         with pytest.raises(FrontendError) as exc_info:
                frontend.parse_file("nonexistent.nc")

    assert exc_info.value.code = 1002
            assert "Failed to read file" in str(exc_info.value)


class TestGlobalFunctions
    #     """Test cases for global functions"""

    #     def test_get_frontend(self):""Test getting global frontend instance"""
    #         # Clear global instance
    #         import noodlecore.compiler.frontend
    noodlecore.compiler.frontend._frontend_instance = None

    #         # Get frontend
    frontend = get_frontend()

            assert isinstance(frontend, CompilerFrontend)

            # Get again (should return same instance)
    frontend2 = get_frontend()

    #         assert frontend is frontend2

    #     def test_parse_code_function(self):
    #         """Test global parse_code function"""
    code = "print('Hello, World!')"

    result = parse_code(code)

    #         assert result.success is True
    #         assert result.request_id is not None

    #     def test_parse_snippet_function(self):
    #         """Test global parse_snippet function"""
    code = "x = 5"

    result = parse_snippet(code)

    #         assert result.success is True
    #         assert result.request_id is not None


if __name__ == "__main__"
        pytest.main([__file__])