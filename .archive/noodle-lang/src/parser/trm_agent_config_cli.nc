# Converted from Python to NoodleCore
# Original file: src

# """
# TRM-Agent Configuration CLI Commands

# This module provides CLI commands for managing TRM-Agent configuration.
# """

import os
import sys
import json
import click
import logging
import typing.Dict
import pathlib.Path

# Import TRM-Agent settings
try
        from ..settings import (         SettingsManager,
    #         TRMAgentSettingsManager,
    #         SettingsError,
    #         get_settings_manager
    #     )
    _SETTINGS_AVAILABLE = True
except ImportError
    _SETTINGS_AVAILABLE = False
    SettingsManager = None
    TRMAgentSettingsManager = None
    SettingsError = Exception

# Import TRM-Agent configuration adapter
try
        from ..config.trm_agent_config import (         get_config_adapter,
    #         load_trm_agent_config,
    #         ConfigurationError
    #     )
    _CONFIG_AVAILABLE = True
except ImportError
    _CONFIG_AVAILABLE = False
    get_config_adapter = None
    load_trm_agent_config = None
    ConfigurationError = Exception

logger = logging.getLogger(__name__)


def get_trm_settings_manager() -TRMAgentSettingsManager):
#     """
#     Get the TRM-Agent settings manager.

#     Returns:
#         TRMAgentSettingsManager: The settings manager

#     Raises:
#         click.ClickException: If settings manager is not available
#     """
#     if not _SETTINGS_AVAILABLE:
        raise click.ClickException("TRM-Agent settings module not available")

#     try:
#         # Get global settings manager
settings_manager = get_settings_manager()

#         # Create TRM-Agent settings manager
trm_settings_manager = TRMAgentSettingsManager(settings_manager)

#         return trm_settings_manager
#     except Exception as e:
        raise click.ClickException(f"Failed to get TRM-Agent settings manager: {str(e)}")


def format_output(data: Any, output_format: str = "table") -str):
#     """
#     Format output data.

#     Args:
#         data: Data to format
        output_format: Output format (table, json, yaml)

#     Returns:
#         str: Formatted output
#     """
#     if output_format == "json":
return json.dumps(data, indent = 2)
#     elif output_format == "yaml":
#         try:
#             import yaml
return yaml.dump(data, default_flow_style = False)
#         except ImportError:
#             return "YAML format not available. Install PyYAML to use this format."
#     elif output_format == "table":
#         # Simple table formatting for dicts
#         if isinstance(data, dict):
lines = []
#             max_key_len = max(len(str(key)) for key in data.keys()) if data else 0

#             for key, value in data.items():
                lines.append(f"{str(key).ljust(max_key_len)} : {value}")

            return "\n".join(lines)
#         else:
            return str(data)
#     else:
        return str(data)


click.group()
# @click.pass_context
function trm_config(ctx)
    #     """Manage TRM-Agent configuration."""
    #     # Ensure context object exists
        ctx.ensure_object(dict)


trm_config.command()
click.option('--config-file', '-c', help = 'TRM-Agent configuration file path')
click.option('--format', '-f', default = 'table', type=click.Choice(['table', 'json', 'yaml']),
help = 'Output format')
# @click.pass_context
function get(ctx, config_file, format)
    #     """Get TRM-Agent configuration values."""
    #     try:
    #         # Get settings manager
    trm_settings_manager = get_trm_settings_manager()

    #         # Load settings
    #         if config_file:
    settings = trm_settings_manager.load_trm_agent_settings(config_file)
    #         else:
    settings = trm_settings_manager.get_trm_agent_settings()

    #         # Format output
            click.echo(format_output(settings.to_dict(), format))

    #     except SettingsError as e:
            raise click.ClickException(f"Settings error: {str(e)} (Error code: {e.error_code})")
    #     except Exception as e:
            raise click.ClickException(f"Failed to get TRM-Agent configuration: {str(e)}")


trm_config.command()
click.option('--config-file', '-c', help = 'TRM-Agent configuration file path')
click.option('--format', '-f', default = 'table', type=click.Choice(['table', 'json', 'yaml']),
help = 'Output format')
# @click.pass_context
function list(ctx, config_file, format)
    #     """List all TRM-Agent configuration values."""
    #     try:
    #         # Get settings manager
    trm_settings_manager = get_trm_settings_manager()

    #         # Load settings
    #         if config_file:
    settings = trm_settings_manager.load_trm_agent_settings(config_file)
    #         else:
    settings = trm_settings_manager.get_trm_agent_settings()

    #         # Format output
            click.echo(format_output(settings.to_dict(), format))

    #     except SettingsError as e:
            raise click.ClickException(f"Settings error: {str(e)} (Error code: {e.error_code})")
    #     except Exception as e:
            raise click.ClickException(f"Failed to list TRM-Agent configuration: {str(e)}")


trm_config.command()
click.option('--key', '-k', required = True, help='Configuration key')
click.option('--value', '-v', required = True, help='Configuration value')
click.option('--config-file', '-c', help = 'TRM-Agent configuration file path')
click.option('--save', is_flag = True, help='Save configuration to file')
# @click.pass_context
function set(ctx, key, value, config_file, save)
    #     """Set a TRM-Agent configuration value."""
    #     try:
    #         # Get settings manager
    trm_settings_manager = get_trm_settings_manager()

    #         # Load settings
    #         if config_file:
    settings = trm_settings_manager.load_trm_agent_settings(config_file)
    #         else:
    settings = trm_settings_manager.get_trm_agent_settings()

    #         # Parse value
    parsed_value = value
    #         if value.lower() in ('true', 'false'):
    parsed_value = value.lower() == 'true'
    #         elif value.isdigit():
    parsed_value = int(value)
    #         elif value.replace('.', '', 1).isdigit():
    parsed_value = float(value)

    #         # Update settings
    updates = {key: parsed_value}
            trm_settings_manager.update_trm_agent_settings(updates)

    #         # Save to file if requested
    #         if save and config_file:
                trm_settings_manager.save_trm_agent_settings(config_file)
                click.echo(f"Configuration saved to {config_file}")

    click.echo(f"Configuration set: {key} = {parsed_value}")

    #     except SettingsError as e:
            raise click.ClickException(f"Settings error: {str(e)} (Error code: {e.error_code})")
    #     except Exception as e:
            raise click.ClickException(f"Failed to set TRM-Agent configuration: {str(e)}")


trm_config.command()
click.option('--config-file', '-c', required = True, help='TRM-Agent configuration file path')
click.option('--format', '-f', default = 'table', type=click.Choice(['table', 'json', 'yaml']),
help = 'Output format')
# @click.pass_context
function load(ctx, config_file, format)
    #     """Load TRM-Agent configuration from file."""
    #     try:
    #         # Get settings manager
    trm_settings_manager = get_trm_settings_manager()

    #         # Load settings
    settings = trm_settings_manager.load_trm_agent_settings(config_file)

    #         # Format output
            click.echo(format_output(settings.to_dict(), format))
            click.echo(f"Configuration loaded from {config_file}")

    #     except SettingsError as e:
            raise click.ClickException(f"Settings error: {str(e)} (Error code: {e.error_code})")
    #     except Exception as e:
            raise click.ClickException(f"Failed to load TRM-Agent configuration: {str(e)}")


trm_config.command()
click.option('--config-file', '-c', required = True, help='TRM-Agent configuration file path')
# @click.pass_context
function save(ctx, config_file)
    #     """Save TRM-Agent configuration to file."""
    #     try:
    #         # Get settings manager
    trm_settings_manager = get_trm_settings_manager()

    #         # Save settings
            trm_settings_manager.save_trm_agent_settings(config_file)

            click.echo(f"Configuration saved to {config_file}")

    #     except SettingsError as e:
            raise click.ClickException(f"Settings error: {str(e)} (Error code: {e.error_code})")
    #     except Exception as e:
            raise click.ClickException(f"Failed to save TRM-Agent configuration: {str(e)}")


trm_config.command()
click.option('--confirm', is_flag = True, help='Confirm reset without prompting')
# @click.pass_context
function reset(ctx, confirm)
    #     """Reset TRM-Agent configuration to defaults."""
    #     if not confirm:
    #         if not click.confirm("Are you sure you want to reset TRM-Agent configuration to defaults?"):
                click.echo("Reset cancelled")
    #             return

    #     try:
    #         # Get settings manager
    trm_settings_manager = get_trm_settings_manager()

    #         # Reset settings
            trm_settings_manager.reset_trm_agent_settings()

            click.echo("TRM-Agent configuration reset to defaults")

    #     except SettingsError as e:
            raise click.ClickException(f"Settings error: {str(e)} (Error code: {e.error_code})")
    #     except Exception as e:
            raise click.ClickException(f"Failed to reset TRM-Agent configuration: {str(e)}")


trm_config.command()
click.option('--config-file', '-c', required = True, help='TRM-Agent configuration file path')
# @click.pass_context
function create_default(ctx, config_file)
    #     """Create a default TRM-Agent configuration file."""
    #     try:
    #         # Get settings manager
    trm_settings_manager = get_trm_settings_manager()

    #         # Create default configuration file
            trm_settings_manager.create_default_config_file(config_file)

            click.echo(f"Default TRM-Agent configuration file created at {config_file}")

    #     except SettingsError as e:
            raise click.ClickException(f"Settings error: {str(e)} (Error code: {e.error_code})")
    #     except Exception as e:
            raise click.ClickException(f"Failed to create default configuration file: {str(e)}")


trm_config.command()
click.option('--config-file', '-c', help = 'TRM-Agent configuration file path')
# @click.pass_context
function validate(ctx, config_file)
    #     """Validate TRM-Agent configuration."""
    #     try:
    #         # Get settings manager
    trm_settings_manager = get_trm_settings_manager()

    #         # Load settings
    #         if config_file:
    settings = trm_settings_manager.load_trm_agent_settings(config_file)
    #         else:
    settings = trm_settings_manager.get_trm_agent_settings()

    #         # Validate settings
            trm_settings_manager._validate_settings(settings)

            click.echo("TRM-Agent configuration is valid")

    #     except SettingsError as e:
            raise click.ClickException(f"Configuration validation failed: {str(e)} (Error code: {e.error_code})")
    #     except Exception as e:
            raise click.ClickException(f"Failed to validate TRM-Agent configuration: {str(e)}")


trm_config.command()
# @click.pass_context
function sections(ctx)
    #     """List available TRM-Agent configuration sections."""
    #     try:
    #         # Get settings manager
    trm_settings_manager = get_trm_settings_manager()

    #         # Get settings
    settings = trm_settings_manager.get_trm_agent_settings()

    #         # List sections
    sections = {
    #             'model_config': 'Model configuration settings',
    #             'optimization_config': 'Optimization configuration settings',
    #             'feedback_config': 'Feedback configuration settings',
    #             'fallback_config': 'Fallback configuration settings',
    #             'general': 'General configuration settings'
    #         }

    #         # Format output
            click.echo(format_output(sections, "table"))

    #     except SettingsError as e:
            raise click.ClickException(f"Settings error: {str(e)} (Error code: {e.error_code})")
    #     except Exception as e:
            raise click.ClickException(f"Failed to list TRM-Agent configuration sections: {str(e)}")


trm_config.command()
click.option('--section', '-s', required = True, help='Configuration section')
click.option('--config-file', '-c', help = 'TRM-Agent configuration file path')
click.option('--format', '-f', default = 'table', type=click.Choice(['table', 'json', 'yaml']),
help = 'Output format')
# @click.pass_context
function get_section(ctx, section, config_file, format)
    #     """Get a specific TRM-Agent configuration section."""
    #     try:
    #         # Get settings manager
    trm_settings_manager = get_trm_settings_manager()

    #         # Load settings
    #         if config_file:
    settings = trm_settings_manager.load_trm_agent_settings(config_file)
    #         else:
    settings = trm_settings_manager.get_trm_agent_settings()

    #         # Get section data
    settings_dict = settings.to_dict()
    #         if section not in settings_dict:
                raise click.ClickException(f"Unknown section: {section}")

    #         # Format output
            click.echo(format_output(settings_dict[section], format))

    #     except SettingsError as e:
            raise click.ClickException(f"Settings error: {str(e)} (Error code: {e.error_code})")
    #     except Exception as e:
            raise click.ClickException(f"Failed to get TRM-Agent configuration section: {str(e)}")


trm_config.command()
# @click.pass_context
function env_vars(ctx)
    #     """List environment variables that affect TRM-Agent configuration."""
    env_vars = {
    #         'NOODLE_TRM_MODEL_PATH': 'Path to TRM-Agent model',
            'NOODLE_TRM_QUANTIZATION': 'Model quantization level (16bit, 8bit, 4bit, 1bit)',
            'NOODLE_TRM_DEVICE': 'Model device (cpu, cuda, mps)',
            'NOODLE_TRM_ENABLE_FALLBACK': 'Enable model fallback (true/false)',
    #         'NOODLE_TRM_MAX_MEMORY': 'Maximum memory usage in bytes',
    #         'NOODLE_TRM_CACHE_DIR': 'Model cache directory',
    #         'NOODLE_TRM_MODEL_VERSION': 'Model version',
            'NOODLE_TRM_OPTIMIZATION_THRESHOLD': 'Optimization threshold (0.0-1.0)',
    #         'NOODLE_TRM_MAX_OPTIMIZATION_TIME': 'Maximum optimization time in seconds',
    #         'NOODLE_TRM_FEEDBACK_INTERVAL': 'Feedback collection interval',
            'NOODLE_TRM_ENABLE_MODEL_UPDATES': 'Enable model updates (true/false)',
            'NOODLE_TRM_FALLBACK_MODE': 'Fallback mode (automatic, manual, disabled, forced)',
    #         'NOODLE_TRM_TIMEOUT_THRESHOLD': 'Timeout threshold in seconds',
            'NOODLE_TRM_MEMORY_LIMIT_THRESHOLD': 'Memory limit threshold (0.0-1.0)',
            'NOODLE_TRM_LOG_LEVEL': 'Log level (DEBUG, INFO, WARNING, ERROR)',
            'NOODLE_TRM_DEBUG_MODE': 'Enable debug mode (true/false)',
            'NOODLE_TRM_ENABLE_PROFILING': 'Enable profiling (true/false)'
    #     }

    #     # Format output
        click.echo(format_output(env_vars, "table"))