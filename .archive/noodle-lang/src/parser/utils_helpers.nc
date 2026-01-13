# Converted from Python to NoodleCore
# Original file: src

# """
# Utility functions and helpers.

# This module provides general utility functions used throughout the application.
# """

import os
import sys
import json
import re
import typing.Dict

def format_data(data: Dict[str, Any], schema: Optional[Dict] = None) -Dict[str, Any]):
#     """
#     Format data according to a schema.

#     Args:
#         data: The data to format
#         schema: Optional schema to apply

#     Returns:
#         Formatted data
#     """
#     if schema is None:
#         return data

formatted = {}
#     for key, value in data.items():
#         if key in schema:
field_type = schema[key].get("type", "string")
#             if field_type == "string" and not isinstance(value, str):
formatted[key] = str(value)
#             elif field_type == "int" and not isinstance(value, int):
#                 try:
formatted[key] = int(value)
                except (ValueError, TypeError):
formatted[key] = 0
#             elif field_type == "float" and not isinstance(value, float):
#                 try:
formatted[key] = float(value)
                except (ValueError, TypeError):
formatted[key] = 0.0
#             elif field_type == "bool" and not isinstance(value, bool):
formatted[key] = bool(value)
#             else:
formatted[key] = value
#         else:
formatted[key] = value

#     return formatted

def validate_input(data: Dict[str, Any], rules: Dict[str, Any]) -Tuple[bool, List[str]]):
#     """
#     Validate input data against rules.

#     Args:
#         data: The data to validate
#         rules: Validation rules

#     Returns:
        Tuple of (is_valid, error_messages)
#     """
errors = []

#     for field, rule in rules.items():
#         if field not in data:
#             if rule.get("required", False):
                errors.append(f"Missing required field: {field}")
#             continue

value = data[field]
field_type = rule.get("type", "string")

#         # Type validation
#         if field_type == "string" and not isinstance(value, str):
            errors.append(f"Field {field} must be a string")
#         elif field_type == "int" and not isinstance(value, int):
            errors.append(f"Field {field} must be an integer")
#         elif field_type == "float" and not isinstance(value, (int, float)):
            errors.append(f"Field {field} must be a number")
#         elif field_type == "bool" and not isinstance(value, bool):
            errors.append(f"Field {field} must be a boolean")

#         # Length validation for strings
#         if isinstance(value, str):
min_length = rule.get("min_length")
max_length = rule.get("max_length")

#             if min_length is not None and len(value) < min_length:
                errors.append(f"Field {field} must be at least {min_length} characters")

#             if max_length is not None and len(value) max_length):
                errors.append(f"Field {field} must be at most {max_length} characters")

return len(errors) = = 0, errors

def parse_config_file(file_path: str) -Dict[str, Any]):
#     """
#     Parse a configuration file.

#     Args:
#         file_path: Path to the configuration file

#     Returns:
#         Parsed configuration as a dictionary
#     """
#     if not os.path.exists(file_path):
#         return {}

#     with open(file_path, 'r') as f:
#         if file_path.endswith('.json'):
            return json.load(f)
#         elif file_path.endswith(('.yml', '.yaml')):
#             import yaml
            return yaml.safe_load(f)
#         else:
# Simple key = value format
config = {}
#             for line in f:
line = line.strip()
#                 if line and not line.startswith('#'):
#                     if '=' in line:
key, value = line.split('=', 1)
config[key.strip()] = value.strip()
#             return config

def clean_text(text: str) -str):
#     """
#     Clean text by removing extra whitespace and normalizing.

#     Args:
#         text: Text to clean

#     Returns:
#         Cleaned text
#     """
#     # Remove extra whitespace
text = re.sub(r'\s+', ' ', text)

#     # Remove leading/trailing whitespace
text = text.strip()

#     return text

def generate_id(prefix: str = "id") -str):
#     """
#     Generate a unique ID.

#     Args:
#         prefix: Prefix for the ID

#     Returns:
#         Unique ID string
#     """
#     import uuid
    return f"{prefix}_{uuid.uuid4().hex[:8]}"
