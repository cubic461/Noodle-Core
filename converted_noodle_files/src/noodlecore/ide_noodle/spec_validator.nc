# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# NoodleCore Spec Validator
# Pure-Python validation for .nc specifications without external dependencies
# """

import os
import re
import typing.Dict,


def load_all_specs(spec_dir: str = None) -> Dict[str, Any]:
#     """Load all .nc specification files"""
#     if spec_dir is None:
spec_dir = os.path.dirname(__file__)

specs = {
#         'attributes': {},
#         'commands': {},
#         'sequences': {},
#         'providers': {},
#         'roles': {}
#     }

#     # Load attributes.nc
attributes_path = os.path.join(spec_dir, "attributes.nc")
#     if os.path.exists(attributes_path):
#         with open(attributes_path, 'r', encoding='utf-8') as f:
content = f.read()
specs['attributes'] = _parse_nc_file(content, 'attribute')

#     # Load commands.nc
commands_path = os.path.join(spec_dir, "commands.nc")
#     if os.path.exists(commands_path):
#         with open(commands_path, 'r', encoding='utf-8') as f:
content = f.read()
specs['commands'] = _parse_nc_file(content, 'command')

#     # Load scenarios.nc
scenarios_path = os.path.join(spec_dir, "scenarios.nc")
#     if os.path.exists(scenarios_path):
#         with open(scenarios_path, 'r', encoding='utf-8') as f:
content = f.read()
specs['sequences'] = _parse_nc_file(content, 'sequence')

#     # Load providers.nc
providers_path = os.path.join(spec_dir, "providers.nc")
#     if os.path.exists(providers_path):
#         with open(providers_path, 'r', encoding='utf-8') as f:
content = f.read()

#         # Parse providers
specs['providers'] = _parse_nc_file(content, 'provider')
#         # Parse roles
specs['roles'] = _parse_nc_file(content, 'role')

#     return specs


def _parse_nc_file(content: str, block_type: str) -> Dict[str, Any]:
#     """Parse a .nc file and extract blocks of specified type"""
pattern = rf'{block_type}\s+(\w+)\s*\{{([^}}]+)\}}'
matches = re.findall(pattern, content, re.DOTALL)

result = {}
#     for name, block_content in matches:
parsed = _parse_block_content(block_content)
#         # Use the id field from the block if available, otherwise use the name
block_id = parsed.get('id', name)
result[block_id] = parsed

#     return result


def _parse_block_content(content: str) -> Dict[str, Any]:
#     """Parse key-value content from .nc blocks"""
data = {}

#     # Parse simple key: "value" pairs
simple_pattern = r'(\w+):\s*"([^"]+)"'
#     for key, value in re.findall(simple_pattern, content):
data[key] = value

#     # Parse boolean values
bool_pattern = r'(\w+):\s*(true|false)'
#     for key, value in re.findall(bool_pattern, content):
data[key] = value == 'true'

#     # Parse number values
number_pattern = r'(\w+):\s*(\d+)'
#     for key, value in re.findall(number_pattern, content):
data[key] = int(value)

#     # Parse array values
array_pattern = r'(\w+):\s*\[([^\]]+)\]'
#     for key, value in re.findall(array_pattern, content):
#         # Clean up array items and remove quotes
#         items = [item.strip().strip('"') for item in value.split(',')]
data[key] = items

    # Parse nested blocks (inputs, outputs, capabilities)
nested_pattern = r'(\w+)\s*\{([^}]+)\}'
#     for key, nested_content in re.findall(nested_pattern, content, re.DOTALL):
data[key] = _parse_block_content(nested_content)

#     return data


def validate_specs(specs: Dict[str, Any] = None) -> Dict[str, Any]:
#     """Validate all .nc specifications for consistency"""
#     if specs is None:
specs = load_all_specs()

errors = []
warnings = []

#     # Extract data for easier access
attributes = specs.get('attributes', {})
commands = specs.get('commands', {})
sequences = specs.get('sequences', {})
providers = specs.get('providers', {})
roles = specs.get('roles', {})

#     # 1. Check that every command feature exists in attributes
#     for cmd_id, cmd_data in commands.items():
feature = cmd_data.get('feature')
#         if feature and feature not in attributes:
            errors.append(f"Command '{cmd_id}' references unknown feature '{feature}'")

#     # 2. Check that type: ai commands reference valid provider/role ids
#     for cmd_id, cmd_data in commands.items():
#         if cmd_data.get('type') == 'ai':
#             # AI commands don't need explicit provider/role in the command spec
#             # They use the AI client which manages providers/roles
#             pass

#     # 3. Check that scenarios reference only existing command ids
#     for seq_id, seq_data in sequences.items():
seq_commands = seq_data.get('commands', [])
#         for cmd_ref in seq_commands:
#             if cmd_ref not in commands:
                errors.append(f"Sequence '{seq_id}' references unknown command '{cmd_ref}'")

#     # 4. Check for duplicate ids across commands and sequences
all_command_ids = set(commands.keys())
all_sequence_ids = set(sequences.keys())

duplicates = all_command_ids.intersection(all_sequence_ids)
#     if duplicates:
#         for dup_id in duplicates:
            errors.append(f"Duplicate ID '{dup_id}' found in both commands and sequences")

#     # 5. Check provider configuration
#     for provider_id, provider_data in providers.items():
auth_env = provider_data.get('auth_env')
#         if auth_env and not auth_env.startswith('NOODLE_'):
            warnings.append(f"Provider '{provider_id}' uses non-standard auth env '{auth_env}' (should use NOODLE_ prefix)")

#     # 6. Check role configuration
#     for role_id, role_data in roles.items():
provider = role_data.get('provider')
#         if provider and provider != 'any' and provider not in providers:
            errors.append(f"Role '{role_id}' references unknown provider '{provider}'")

#     # 7. Check that all attributes have required fields
#     for attr_id, attr_data in attributes.items():
#         if 'id' not in attr_data:
            errors.append(f"Attribute '{attr_id}' missing required field 'id'")
#         if 'description' not in attr_data:
            warnings.append(f"Attribute '{attr_id}' missing recommended field 'description'")

#     # 8. Check that all commands have required fields
#     for cmd_id, cmd_data in commands.items():
#         if 'feature' not in cmd_data:
            errors.append(f"Command '{cmd_id}' missing required field 'feature'")
#         if 'handler' not in cmd_data and cmd_data.get('type') != 'ai':
            errors.append(f"Non-AI command '{cmd_id}' missing required field 'handler'")

#     return {
"ok": len(errors) = = 0,
#         "errors": errors,
#         "warnings": warnings
#     }