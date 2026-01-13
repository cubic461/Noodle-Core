# Converted from Python to NoodleCore
# Original file: src

# """
# Unit tests for CLI Configuration

# This module contains comprehensive unit tests for the CLI configuration system,
# testing environment variable handling, validation, and profile management.
# """

import pytest
import os
import json
import tempfile
import pathlib.Path
import unittest.mock.patch

# Add src to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

import noodlecore.cli.cli_config.(
#     CliConfig,
#     get_cli_config,
#     reload_cli_config,
#     ConfigurationError
# )


class TestCliConfig
    #     """Test the CliConfig class."""

    #     def test_cli_config_initialization(self):""Test that CliConfig initializes with default values."""
    config = CliConfig()

    #         # Check that default values are loaded
    assert config.get('NOODLE_ENV') = = 'development'
    assert config.get('NOODLE_PORT') = = '8080'
    assert config.get('NOODLE_LOG_LEVEL') = = 'INFO'
    assert config.get('NOODLE_DEBUG') = = '0'

    #     def test_cli_config_with_environment_variables(self):
    #         """Test that environment variables override defaults."""
    #         # Set environment variables
    #         with patch.dict(os.environ, {
    #             'NOODLE_ENV': 'production',
    #             'NOODLE_PORT': '9090',
    #             'NOODLE_DEBUG': '1'
    #         }):
    config = CliConfig()

    assert config.get('NOODLE_ENV') = = 'production'
    assert config.get('NOODLE_PORT') = = '9090'
    assert config.get('NOODLE_DEBUG') = = '1'

    #     def test_cli_config_with_config_file(self):
    #         """Test that configuration file overrides defaults."""
    config_data = {
    #             'env': 'testing',
    #             'port': '7070',
    #             'debug': '1'
    #         }

    #         with patch("builtins.open", mock_open(read_data=json.dumps(config_data))):
    #             with patch("pathlib.Path.exists", return_value=True):
    config = CliConfig("test_config.json")

    assert config.get('NOODLE_ENV') = = 'testing'
    assert config.get('NOODLE_PORT') = = '7070'
    assert config.get('NOODLE_DEBUG') = = '1'

    #     def test_cli_config_get_methods(self):
    #         """Test the various get methods."""
    config = CliConfig()

    #         # Test get method
    assert config.get('NOODLE_ENV') = = 'development'
    assert config.get('NON_EXISTENT_KEY', 'default') = = 'default'

    #         # Test get_int method
    assert config.get_int('NOODLE_PORT') = = 8080
    assert config.get_int('NON_EXISTENT_KEY', 123) = = 123

    #         # Test get_bool method
            assert config.get_bool('NOODLE_DEBUG') is False
            assert config.get_bool('NON_EXISTENT_KEY', True) is True

    #         # Test get_path method
    path = config.get_path('NOODLE_CONFIG_DIR')
            assert isinstance(path, Path)

    #     def test_cli_config_set_method(self):
    #         """Test the set method."""
    config = CliConfig()

            config.set('TEST_KEY', 'test_value')
    assert config.get('TEST_KEY') = = 'test_value'

    #         # Test with NOODLE_ prefix
            config.set('CUSTOM_KEY', 'custom_value')
    assert config.get('NOODLE_CUSTOM_KEY') = = 'custom_value'

    #     def test_cli_config_get_all(self):
    #         """Test the get_all method."""
    config = CliConfig()

    all_config = config.get_all()
            assert isinstance(all_config, dict)
    #         assert 'NOODLE_ENV' in all_config
    #         assert 'NOODLE_PORT' in all_config

    #     def test_cli_config_profile_config(self):
    #         """Test profile-specific configuration."""
    config = CliConfig()

    #         # Test development profile
    dev_config = config.get_profile_config('development')
    assert dev_config['NOODLE_ENV'] = = 'development'
    assert dev_config['NOODLE_DEBUG'] = = '1'
    assert dev_config['NOODLE_LOG_LEVEL'] = = 'DEBUG'

    #         # Test production profile
    prod_config = config.get_profile_config('production')
    assert prod_config['NOODLE_ENV'] = = 'production'
    assert prod_config['NOODLE_DEBUG'] = = '0'
    assert prod_config['NOODLE_LOG_LEVEL'] = = 'WARNING'

    #         # Test testing profile
    test_config = config.get_profile_config('testing')
    assert test_config['NOODLE_ENV'] = = 'testing'
    assert test_config['NOODLE_DEBUG'] = = '1'
    assert test_config['NOODLE_LOG_LEVEL'] = = 'DEBUG'

    #     def test_cli_config_helper_methods(self):
    #         """Test helper methods."""
    config = CliConfig()

    #         # Test is_development
            assert config.is_development() is True
            assert config.is_production() is False

    #         # Test is_debug_enabled
            assert config.is_debug_enabled() is False

    #         # Test is_tracing_enabled
            assert config.is_tracing_enabled() is False

    #     def test_cli_config_validation(self):
    #         """Test configuration validation."""
    #         # Test invalid environment
    #         with patch.dict(os.environ, {'NOODLE_ENV': 'invalid'}):
    #             with pytest.raises(ConfigurationError):
                    CliConfig()

    #         # Test invalid log level
    #         with patch.dict(os.environ, {'NOODLE_LOG_LEVEL': 'invalid'}):
    #             with pytest.raises(ConfigurationError):
                    CliConfig()

    #         # Test invalid output format
    #         with patch.dict(os.environ, {'NOODLE_OUTPUT_FORMAT': 'invalid'}):
    #             with pytest.raises(ConfigurationError):
                    CliConfig()

    #         # Test invalid numeric value
    #         with patch.dict(os.environ, {'NOODLE_PORT': 'invalid'}):
    #             with pytest.raises(ConfigurationError):
                    CliConfig()

    #         # Test invalid boolean value
    #         with patch.dict(os.environ, {'NOODLE_DEBUG': 'invalid'}):
    #             with pytest.raises(ConfigurationError):
                    CliConfig()

    #     def test_cli_config_numeric_validation(self):
    #         """Test numeric validation with bounds."""
    #         # Test port bounds
    #         with patch.dict(os.environ, {'NOODLE_PORT': '0'}):
    #             with pytest.raises(ConfigurationError):
                    CliConfig()

    #         with patch.dict(os.environ, {'NOODLE_PORT': '70000'}):
    #             with pytest.raises(ConfigurationError):
                    CliConfig()

    #         # Test valid port
    #         with patch.dict(os.environ, {'NOODLE_PORT': '8080'}):
    config = CliConfig()
    assert config.get_int('NOODLE_PORT') = = 8080

    #     def test_cli_config_boolean_validation(self):
    #         """Test boolean validation."""
    #         # Test various boolean representations
    boolean_values = [
                ('1', True), ('true', True), ('yes', True), ('on', True),
                ('0', False), ('false', False), ('no', False), ('off', False)
    #         ]

    #         for value, expected in boolean_values:
    #             with patch.dict(os.environ, {'NOODLE_DEBUG': value}):
    config = CliConfig()
    assert config.get_bool('NOODLE_DEBUG') = = expected

    #     def test_cli_config_file_error(self):
    #         """Test handling of configuration file errors."""
    #         # Test invalid JSON
    #         with patch("builtins.open", mock_open(read_data="invalid json")):
    #             with patch("pathlib.Path.exists", return_value=True):
    #                 with pytest.raises(ConfigurationError):
                        CliConfig("invalid_config.json")

    #         # Test file not found error
    #         with patch("builtins.open", side_effect=IOError("File not found")):
    #             with patch("pathlib.Path.exists", return_value=True):
    #                 with pytest.raises(ConfigurationError):
                        CliConfig("missing_config.json")


class TestGlobalConfigFunctions
    #     """Test global configuration functions."""

    #     def test_get_cli_config(self):""Test the get_cli_config function."""
    #         # Clear any existing global config
    #         import noodlecore.cli.cli_config as cli_config_module
    cli_config_module._cli_config = None

    config = get_cli_config()
            assert isinstance(config, CliConfig)

    #         # Test that it returns the same instance
    config2 = get_cli_config()
    #         assert config is config2

    #     def test_reload_cli_config(self):
    #         """Test the reload_cli_config function."""
    #         # Clear any existing global config
    #         import noodlecore.cli.cli_config as cli_config_module
    cli_config_module._cli_config = None

    config = reload_cli_config()
            assert isinstance(config, CliConfig)

    #         # Test that it creates a new instance
    config2 = reload_cli_config()
    #         assert config is not config2


class TestCliConfigIntegration
    #     """Test integration scenarios for CLI configuration."""

    #     def test_environment_precedence(self):""Test that environment variables take precedence over config files."""
    config_data = {
    #             'env': 'production',
    #             'port': '9090',
    #             'debug': '1'
    #         }

    #         with patch.dict(os.environ, {
    #             'NOODLE_ENV': 'testing',  # Override config file
    #             'NOODLE_PORT': '7070'     # Override config file
    #         }):
    #             with patch("builtins.open", mock_open(read_data=json.dumps(config_data))):
    #                 with patch("pathlib.Path.exists", return_value=True):
    config = CliConfig("test_config.json")

    #                     # Environment variables should override config file
    assert config.get('NOODLE_ENV') = = 'testing'
    assert config.get('NOODLE_PORT') = = '7070'
    #                     # Config file value should be used for non-overridden key
    assert config.get('NOODLE_DEBUG') = = '1'

    #     def test_config_file_key_conversion(self):
    #         """Test that config file keys are properly converted to NOODLE_ format."""
    config_data = {
    #             'env': 'production',
    #             'NOODLE_PORT': '9090',
    #             'custom_key': 'custom_value'
    #         }

    #         with patch("builtins.open", mock_open(read_data=json.dumps(config_data))):
    #             with patch("pathlib.Path.exists", return_value=True):
    config = CliConfig("test_config.json")

    assert config.get('NOODLE_ENV') = = 'production'
    assert config.get('NOODLE_PORT') = = '9090'
    assert config.get('NOODLE_CUSTOM_KEY') = = 'custom_value'

    #     def test_path_expansion(self):
    #         """Test that paths with ~ are expanded to home directory."""
    config = CliConfig()

    #         with patch.dict(os.environ, {'NOODLE_CONFIG_DIR': '~/test'}):
    #             with patch("os.path.expanduser", return_value="/home/user/test"):
    config = CliConfig()
    path = config.get_path('NOODLE_CONFIG_DIR')
    assert str(path) = = "/home/user/test"


class TestCliConfigPerformance
    #     """Test performance characteristics of CLI configuration."""

    #     def test_config_loading_performance(self, performance_monitor):""Test that configuration loading is performant."""
            performance_monitor.start_timing("config_loading")

    config = CliConfig()
            config.get('NOODLE_ENV')
            config.get_int('NOODLE_PORT')
            config.get_bool('NOODLE_DEBUG')

    duration = performance_monitor.end_timing("config_loading")
    #         assert duration < 0.1  # Should complete within 100ms

    #     def test_config_memory_usage(self, performance_monitor):
    #         """Test that configuration doesn't use excessive memory."""
            performance_monitor.start_timing("config_memory")

    config = CliConfig()
    all_config = config.get_all()

            performance_monitor.end_timing("config_memory")
            performance_monitor.assert_memory_usage(10)  # Should use less than 10MB


class TestCliConfigErrorHandling
    #     """Test error handling in CLI configuration."""

    #     def test_configuration_error_message(self):""Test that ConfigurationError has informative messages."""
    #         with patch.dict(os.environ, {'NOODLE_ENV': 'invalid'}):
    #             try:
                    CliConfig()
    #                 assert False, "Should have raised ConfigurationError"
    #             except ConfigurationError as e:
                    assert "Invalid NOODLE_ENV" in str(e)
                    assert "development, production, testing" in str(e)

    #     def test_partial_config_loading(self):
    #         """Test that partial configuration loading works."""
    #         # Set only some environment variables
    #         with patch.dict(os.environ, {
    #             'NOODLE_ENV': 'production',
    #             'NOODLE_PORT': '9090'
    #             # Leave other variables as defaults
    #         }):
    config = CliConfig()

    assert config.get('NOODLE_ENV') = = 'production'
    assert config.get('NOODLE_PORT') = = '9090'
    assert config.get('NOODLE_LOG_LEVEL') = = 'INFO'  # Default value
    assert config.get('NOODLE_DEBUG') = = '0'        # Default value