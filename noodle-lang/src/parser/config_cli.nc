# Converted from Python to NoodleCore
# Original file: src

# """
# Configuration CLI Module

# This module implements the CLI interface for configuration management.
# """

import asyncio
import json
import sys
import logging
import typing.Dict
import pathlib.Path
import argparse
import os

import .config_manager.ConfigManager
import .profile_manager.ProfileType
import .secure_storage.SecureStorage


class ConfigCLI
    #     """Configuration CLI interface."""

    #     def __init__(self):""Initialize the configuration CLI."""
    self.logger = logging.getLogger(__name__)
    self.config_manager: Optional[ConfigManager] = None

    #     async def initialize(self, config_dir: Optional[str] = None, profile: Optional[str] = None):
    #         """Initialize the configuration manager."""
    #         try:
    self.config_manager = ConfigManager(
    config_dir = config_dir,
    profile_name = profile,
    #                 hot_reload=False  # Disable for CLI
    #             )
                self.logger.info("Configuration CLI initialized")
    #         except Exception as e:
                self.logger.error(f"Failed to initialize configuration CLI: {str(e)}")
                print(f"Error: Failed to initialize configuration: {str(e)}")
                sys.exit(1)

    #     async def cleanup(self):
    #         """Cleanup resources."""
    #         if self.config_manager:
                await self.config_manager.cleanup()

    #     def create_parser(self) -argparse.ArgumentParser):
    #         """Create the argument parser."""
    parser = argparse.ArgumentParser(
    prog = 'noodle-config',
    description = 'NoodleCore Configuration Management CLI'
    #         )

            parser.add_argument(
    #             '--config-dir',
    help = 'Configuration directory',
    default = None
    #         )

            parser.add_argument(
    #             '--profile',
    help = 'Configuration profile to use',
    default = None
    #         )

            parser.add_argument(
    #             '--verbose', '-v',
    help = 'Enable verbose output',
    action = 'store_true'
    #         )

            parser.add_argument(
    #             '--format',
    choices = ['json', 'text'],
    help = 'Output format',
    default = 'text'
    #         )

    subparsers = parser.add_subparsers(dest='command', help='Available commands')

    #         # Show command
    show_parser = subparsers.add_parser('show', help='Show configuration')
    show_parser.add_argument('key', nargs = '?', help='Configuration key (supports dot notation)')
    show_parser.add_argument('--all', '-a', help = 'Show all configuration', action='store_true')

    #         # Set command
    set_parser = subparsers.add_parser('set', help='Set configuration value')
    set_parser.add_argument('key', help = 'Configuration key (supports dot notation)')
    set_parser.add_argument('value', help = 'Configuration value')
    set_parser.add_argument('--no-save', help = 'Don\'t persist to file', action='store_true')
    set_parser.add_argument('--type', choices = ['string', 'int', 'float', 'bool', 'json'],
    help = 'Value type', default='string')

    #         # Delete command
    delete_parser = subparsers.add_parser('delete', help='Delete configuration key')
    delete_parser.add_argument('key', help = 'Configuration key (supports dot notation)')
    delete_parser.add_argument('--no-save', help = 'Don\'t persist to file', action='store_true')

    #         # Validate command
    validate_parser = subparsers.add_parser('validate', help='Validate configuration')
    validate_parser.add_argument('--category', help = 'Validation category to run')

    #         # Profile commands
    profile_parser = subparsers.add_parser('profile', help='Profile management')
    profile_subparsers = profile_parser.add_subparsers(dest='profile_command')

    #         # Profile list
    profile_subparsers.add_parser('list', help = 'List profiles')

    #         # Profile show
    profile_show_parser = profile_subparsers.add_parser('show', help='Show profile')
    profile_show_parser.add_argument('name', help = 'Profile name')
    profile_show_parser.add_argument('--resolve', help = 'Resolve inheritance', action='store_true')

    #         # Profile activate
    profile_activate_parser = profile_subparsers.add_parser('activate', help='Activate profile')
    profile_activate_parser.add_argument('name', help = 'Profile name')

    #         # Profile create
    profile_create_parser = profile_subparsers.add_parser('create', help='Create profile')
    profile_create_parser.add_argument('name', help = 'Profile name')
    profile_create_parser.add_argument('--type', choices = ['system', 'user', 'project'],
    help = 'Profile type', default='user')
    profile_create_parser.add_argument('--description', help = 'Profile description')
    profile_create_parser.add_argument('--inherits', help = 'Parent profiles (comma-separated)')

    #         # Profile delete
    profile_delete_parser = profile_subparsers.add_parser('delete', help='Delete profile')
    profile_delete_parser.add_argument('name', help = 'Profile name')
    profile_delete_parser.add_argument('--force', help = 'Force deletion', action='store_true')

    #         # Environment commands
    env_parser = subparsers.add_parser('env', help='Environment variable management')
    env_subparsers = env_parser.add_subparsers(dest='env_command')

    #         # Environment list
    env_list_parser = env_subparsers.add_parser('list', help='List environment variables')
    env_list_parser.add_argument('--sensitive', help = 'Include sensitive variables', action='store_true')

    #         # Environment get
    env_get_parser = env_subparsers.add_parser('get', help='Get environment variable')
    env_get_parser.add_argument('key', help = 'Environment variable name')

    #         # Environment set
    env_set_parser = env_subparsers.add_parser('set', help='Set environment variable')
    env_set_parser.add_argument('key', help = 'Environment variable name')
    env_set_parser.add_argument('value', help = 'Environment variable value')
    env_set_parser.add_argument('--no-persist', help = 'Don\'t persist to .env file', action='store_true')

    #         # Migration commands
    migration_parser = subparsers.add_parser('migrate', help='Configuration migration')
    migration_subparsers = migration_parser.add_subparsers(dest='migration_command')

    #         # Migration status
    migration_subparsers.add_parser('status', help = 'Show migration status')

    #         # Migration up
    migration_up_parser = migration_subparsers.add_parser('up', help='Migrate up')
    migration_up_parser.add_argument('--target', help = 'Target version')
    migration_up_parser.add_argument('--no-backup', help = 'Don\'t create backup', action='store_true')

    #         # Migration down
    migration_down_parser = migration_subparsers.add_parser('down', help='Migrate down')
    migration_down_parser.add_argument('version', help = 'Target version')
    migration_down_parser.add_argument('--no-backup', help = 'Don\'t create backup', action='store_true')

    #         # Secure storage commands
    secure_parser = subparsers.add_parser('secure', help='Secure storage management')
    secure_subparsers = secure_parser.add_subparsers(dest='secure_command')

    #         # Secure store
    secure_store_parser = secure_subparsers.add_parser('store', help='Store sensitive data')
    secure_store_parser.add_argument('key', help = 'Storage key')
    secure_store_parser.add_argument('value', help = 'Value to store (or read from stdin)')
    secure_store_parser.add_argument('--from-file', help = 'Read value from file')
    secure_store_parser.add_argument('--from-stdin', help = 'Read value from stdin', action='store_true')

    #         # Secure retrieve
    secure_retrieve_parser = secure_subparsers.add_parser('retrieve', help='Retrieve sensitive data')
    secure_retrieve_parser.add_argument('key', help = 'Storage key')

    #         # Secure delete
    secure_delete_parser = secure_subparsers.add_parser('delete', help='Delete sensitive data')
    secure_delete_parser.add_argument('key', help = 'Storage key')

    #         # Secure list
    secure_subparsers.add_parser('list', help = 'List stored keys')

    #         # Export/Import commands
    export_parser = subparsers.add_parser('export', help='Export configuration')
    export_parser.add_argument('file', help = 'Export file path')
    export_parser.add_argument('--format', choices = ['json', 'msgpack'], help='Export format', default='json')
    export_parser.add_argument('--include-sensitive', help = 'Include sensitive data', action='store_true')

    import_parser = subparsers.add_parser('import', help='Import configuration')
    import_parser.add_argument('file', help = 'Import file path')
    #         import_parser.add_argument('--merge', help='Merge with existing configuration', action='store_true')
    import_parser.add_argument('--overwrite', help = 'Overwrite existing configuration', action='store_true')

    #         # Info command
    subparsers.add_parser('info', help = 'Show configuration system information')

    #         # Setup wizard
    subparsers.add_parser('setup', help = 'Run interactive setup wizard')

    #         return parser

    #     def format_output(self, data: Any, format_type: str = 'text') -str):
    #         """Format output data."""
    #         if format_type == 'json':
    return json.dumps(data, indent = 2, default=str)
    #         else:
    #             if isinstance(data, dict):
    #                 if 'success' in data:
    #                     if data['success']:
    output = data.get('message', 'Operation successful')
    #                         if 'data' in data:
    output + = f"\n{json.dumps(data['data'], indent=2)}"
    #                         return output
    #                     else:
                            return f"Error: {data.get('error', 'Unknown error')}"
    #                 else:
    return json.dumps(data, indent = 2, default=str)
    #             else:
                    return str(data)

    #     def parse_value(self, value: str, value_type: str) -Any):
    #         """Parse value according to type."""
    #         if value_type == 'int':
                return int(value)
    #         elif value_type == 'float':
                return float(value)
    #         elif value_type == 'bool':
                return value.lower() in ('true', '1', 'yes', 'on')
    #         elif value_type == 'json':
                return json.loads(value)
    #         else:
    #             return value

    #     async def cmd_show(self, args) -str):
    #         """Handle show command."""
    #         if args.all:
    info = await self.config_manager.get_config_info()
    config = await self.config_manager.get('')  # Get all config
                return self.format_output({
    #                 'config': config,
    #                 'info': info
    #             }, args.format)
    #         elif args.key:
    value = await self.config_manager.get(args.key)
    #             if value is not None:
                    return self.format_output({
    #                     'key': args.key,
    #                     'value': value
    #                 }, args.format)
    #             else:
    #                 return f"Configuration key '{args.key}' not found"
    #         else:
    #             # Show current profile and basic info
    info = await self.config_manager.get_config_info()
                return self.format_output(info, args.format)

    #     async def cmd_set(self, args) -str):
    #         """Handle set command."""
    value = self.parse_value(args.value, args.type)
    persist = not args.no_save

    result = await self.config_manager.set(args.key, value, persist=persist)
            return self.format_output(result, args.format)

    #     async def cmd_delete(self, args) -str):
    #         """Handle delete command."""
    #         # For now, we'll set the value to None
    persist = not args.no_save

    result = await self.config_manager.set(args.key, None, persist=persist)
            return self.format_output(result, args.format)

    #     async def cmd_validate(self, args) -str):
    #         """Handle validate command."""
    #         if args.category:
    #             # Validate specific category
    #             from .config_validator import ValidationCategory
    categories = [ValidationCategory(args.category)]
    result = await self.config_manager._validator.validate(
                    await self.config_manager.get(''), categories
    #             )
    #         else:
    #             # Validate all
    result = await self.config_manager.validate_config()

            return self.format_output(result, args.format)

    #     async def cmd_profile(self, args) -str):
    #         """Handle profile commands."""
    #         if args.profile_command == 'list':
    result = await self.config_manager._profile_manager.list_profiles()
                return self.format_output(result, args.format)

    #         elif args.profile_command == 'show':
    result = await self.config_manager._profile_manager.get_profile(
    args.name, resolve_inheritance = args.resolve
    #             )
                return self.format_output(result, args.format)

    #         elif args.profile_command == 'activate':
    result = await self.config_manager.switch_profile(args.name)
                return self.format_output(result, args.format)

    #         elif args.profile_command == 'create':
    profile_type = ProfileType(args.type)
    #             inherits = args.inherits.split(',') if args.inherits else []

    #             # Start with current configuration
    current_config = await self.config_manager.get('')

    result = await self.config_manager._profile_manager.create_profile(
    #                 args.name, current_config, profile_type, args.description, inherits
    #             )
                return self.format_output(result, args.format)

    #         elif args.profile_command == 'delete':
    result = await self.config_manager._profile_manager.delete_profile(
    args.name, force = args.force
    #             )
                return self.format_output(result, args.format)

    #         else:
    #             return "Unknown profile command"

    #     async def cmd_env(self, args) -str):
    #         """Handle environment commands."""
    #         if args.env_command == 'list':
    result = await self.config_manager._environment_manager.list(
    include_sensitive = args.sensitive
    #             )
                return self.format_output(result, args.format)

    #         elif args.env_command == 'get':
    value = await self.config_manager._environment_manager.get(args.key)
    #             if value is not None:
                    return self.format_output({
    #                     'key': args.key,
    #                     'value': value
    #                 }, args.format)
    #             else:
    #                 return f"Environment variable '{args.key}' not found"

    #         elif args.env_command == 'set':
    persist = not args.no_persist
    result = await self.config_manager._environment_manager.set(
    args.key, args.value, persist = persist
    #             )
                return self.format_output(result, args.format)

    #         else:
    #             return "Unknown environment command"

    #     async def cmd_migrate(self, args) -str):
    #         """Handle migration commands."""
    #         if args.migration_command == 'status':
    info = await self.config_manager._migration.get_migration_info()
                return self.format_output(info, args.format)

    #         elif args.migration_command == 'up':
    create_backup = not args.no_backup
    result = await self.config_manager._migration.migrate_up(
    target_version = args.target, create_backup=create_backup
    #             )
                return self.format_output(result, args.format)

    #         elif args.migration_command == 'down':
    create_backup = not args.no_backup
    result = await self.config_manager._migration.migrate_down(
    args.version, create_backup = create_backup
    #             )
                return self.format_output(result, args.format)

    #         else:
    #             return "Unknown migration command"

    #     async def cmd_secure(self, args) -str):
    #         """Handle secure storage commands."""
    #         if not self.config_manager._secure_storage:
    #             return "Secure storage is not enabled"

    #         if args.secure_command == 'store':
    #             if args.from_file:
    #                 with open(args.from_file, 'r') as f:
    value = f.read()
    #             elif args.from_stdin:
    value = sys.stdin.read()
    #             else:
    value = args.value

    result = await self.config_manager._secure_storage.store(args.key, value)
                return self.format_output(result, args.format)

    #         elif args.secure_command == 'retrieve':
    result = await self.config_manager._secure_storage.retrieve(args.key)
                return self.format_output(result, args.format)

    #         elif args.secure_command == 'delete':
    result = await self.config_manager._secure_storage.delete(args.key)
                return self.format_output(result, args.format)

    #         elif args.secure_command == 'list':
    result = await self.config_manager._secure_storage.list_entries()
                return self.format_output(result, args.format)

    #         else:
    #             return "Unknown secure storage command"

    #     async def cmd_export(self, args) -str):
    #         """Handle export command."""
    result = await self.config_manager.export_config(
    #             args.file, args.format, args.include_sensitive
    #         )
            return self.format_output(result, args.format)

    #     async def cmd_import(self, args) -str):
    #         """Handle import command."""
    #         if not Path(args.file).exists():
    #             return f"Import file '{args.file}' not found"

    #         # Load import file
    #         with open(args.file, 'r') as f:
    imported_config = json.load(f)

    #         if args.overwrite:
    #             # Replace entire configuration
    self.config_manager._config = imported_config
    result = await self.config_manager.save_config()
    #         else:
    #             # Merge with existing configuration
    #             for key, value in imported_config.items():
    await self.config_manager.set(key, value, persist = False)
    result = await self.config_manager.save_config()

            return self.format_output(result, args.format)

    #     async def cmd_info(self, args) -str):
    #         """Handle info command."""
    info = await self.config_manager.get_config_info()
            return self.format_output(info, args.format)

    #     async def cmd_setup(self, args) -str):
    #         """Handle setup wizard."""
            print("NoodleCore Configuration Setup Wizard")
    print(" = " * 40)

    #         # Ask for basic configuration
            print("\n1. AI Configuration")
    ai_provider = input("AI provider (zai/openrouter) [zai]: ").strip() or "zai"

    #         if ai_provider == "zai":
    api_key = input("ZAI API key (or press Enter to use NOODLE_ZAI_API_KEY): ").strip()
    #             if not api_key:
    api_key = "env:NOODLE_ZAI_API_KEY"
    #         else:
    api_key = input("OpenRouter API key (or press Enter to use NOODLE_OPENROUTER_API_KEY): ").strip()
    #             if not api_key:
    api_key = "env:NOODLE_OPENROUTER_API_KEY"

            print("\n2. Sandbox Configuration")
    sandbox_timeout = input("Sandbox timeout in seconds [30]: ").strip() or "30"
    memory_limit = input("Memory limit [2GB]: ").strip() or "2GB"

            print("\n3. Logging Configuration")
    log_level = input("Log level (DEBUG/INFO/WARNING/ERROR) [INFO]: ").strip() or "INFO"

    #         # Create configuration
    config = {
    #             "ai": {
    #                 "default_model": f"{ai_provider}_glm" if ai_provider == "zai" else "openrouter",
    #                 "models": {
    #                     f"{ai_provider}_glm": {
    #                         "provider": ai_provider,
    #                         "api_key": api_key,
    #                         "model_name": "glm-4-6" if ai_provider == "zai" else "meta-llama/llama-3.1-70b-instruct"
    #                     }
    #                 }
    #             },
    #             "sandbox": {
                    "execution_timeout": int(sandbox_timeout),
    #                 "memory_limit": memory_limit
    #             },
    #             "logging": {
    #                 "level": log_level
    #             }
    #         }

    #         # Save configuration
    #         for key, value in config.items():
    await self.config_manager.set(key, value, persist = False)

    result = await self.config_manager.save_config()

    #         if result['success']:
                print("\n✓ Configuration setup completed successfully!")
                print(f"Configuration saved to: {self.config_manager.config_file}")
    #         else:
                print(f"\n✗ Setup failed: {result.get('error', 'Unknown error')}")

            return self.format_output(result, args.format)

    #     async def run(self, args: List[str] = None) -str):
    #         """Run the CLI with the given arguments."""
    parser = self.create_parser()
    parsed_args = parser.parse_args(args)

    #         # Setup logging
    #         if parsed_args.verbose:
    logging.basicConfig(level = logging.DEBUG)
    #         else:
    logging.basicConfig(level = logging.WARNING)

    #         # Initialize configuration manager
            await self.initialize(parsed_args.config_dir, parsed_args.profile)

    #         try:
    #             # Route to appropriate command handler
    #             if parsed_args.command == 'show':
                    return await self.cmd_show(parsed_args)
    #             elif parsed_args.command == 'set':
                    return await self.cmd_set(parsed_args)
    #             elif parsed_args.command == 'delete':
                    return await self.cmd_delete(parsed_args)
    #             elif parsed_args.command == 'validate':
                    return await self.cmd_validate(parsed_args)
    #             elif parsed_args.command == 'profile':
                    return await self.cmd_profile(parsed_args)
    #             elif parsed_args.command == 'env':
                    return await self.cmd_env(parsed_args)
    #             elif parsed_args.command == 'migrate':
                    return await self.cmd_migrate(parsed_args)
    #             elif parsed_args.command == 'secure':
                    return await self.cmd_secure(parsed_args)
    #             elif parsed_args.command == 'export':
                    return await self.cmd_export(parsed_args)
    #             elif parsed_args.command == 'import':
                    return await self.cmd_import(parsed_args)
    #             elif parsed_args.command == 'info':
                    return await self.cmd_info(parsed_args)
    #             elif parsed_args.command == 'setup':
                    return await self.cmd_setup(parsed_args)
    #             else:
                    parser.print_help()
    #                 return ""

    #         except Exception as e:
                self.logger.error(f"Command failed: {str(e)}")
                return f"Error: {str(e)}"

    #         finally:
                await self.cleanup()


# async def main():
#     """Main CLI entry point."""
cli = ConfigCLI()
result = await cli.run()
#     if result:
        print(result)


if __name__ == '__main__'
        asyncio.run(main())