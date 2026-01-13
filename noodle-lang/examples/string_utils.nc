# Converted from Python to NoodleCore
# Original file: src

# """
# String Utilities Module

# This module provides string utility functions for NoodleCore CLI.
# """

import re
import typing.Dict


class StringUtils
    #     """String utility functions for NoodleCore CLI."""

    #     def __init__(self):""Initialize the string utilities."""
    self.name = "StringUtils"

    #     def escape_html(self, text: str) -Dict[str, Any]):
    #         """
    #         Escape HTML characters in a string.

    #         Args:
    #             text: Text to escape

    #         Returns:
    #             Dictionary containing escaped text
    #         """
    #         try:
    html_escape_table = {
    #                 "&": "&",
    #                 '"': """,
    #                 "'": "&#x27;",
    #                 ">": ">",
    #                 "<": "<",
    #             }

    #             escaped_text = "".join(html_escape_table.get(c, c) for c in text)

    #             return {
    #                 'success': True,
    #                 'original_text': text,
    #                 'escaped_text': escaped_text
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': f"Error escaping HTML: {str(e)}",
    #                 'error_code': 11001
    #             }

    #     def unescape_html(self, text: str) -Dict[str, Any]):
    #         """
    #         Unescape HTML characters in a string.

    #         Args:
    #             text: Text to unescape

    #         Returns:
    #             Dictionary containing unescaped text
    #         """
    #         try:
    html_unescape_table = {
    #                 "&": "&",
    #                 """: '"',
    #                 "&#x27;": "'",
    #                 ">": ">",
    #                 "<": "<",
    #             }

    #             # Replace HTML entities
    unescaped_text = text
    #             for entity, char in html_unescape_table.items():
    unescaped_text = unescaped_text.replace(entity, char)

    #             return {
    #                 'success': True,
    #                 'original_text': text,
    #                 'unescaped_text': unescaped_text
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': f"Error unescaping HTML: {str(e)}",
    #                 'error_code': 11002
    #             }

    #     def snake_to_camel(self, text: str) -Dict[str, Any]):
    #         """
    #         Convert snake_case to camelCase.

    #         Args:
    #             text: Text to convert

    #         Returns:
    #             Dictionary containing converted text
    #         """
    #         try:
    components = text.split('_')
    #             camel_case = components[0] + ''.join(x.title() for x in components[1:])

    #             return {
    #                 'success': True,
    #                 'original_text': text,
    #                 'converted_text': camel_case,
    #                 'from_case': 'snake_case',
    #                 'to_case': 'camelCase'
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': f"Error converting snake_case to camelCase: {str(e)}",
    #                 'error_code': 11003
    #             }

    #     def snake_to_pascal(self, text: str) -Dict[str, Any]):
    #         """
    #         Convert snake_case to PascalCase.

    #         Args:
    #             text: Text to convert

    #         Returns:
    #             Dictionary containing converted text
    #         """
    #         try:
    #             pascal_case = ''.join(x.title() for x in text.split('_'))

    #             return {
    #                 'success': True,
    #                 'original_text': text,
    #                 'converted_text': pascal_case,
    #                 'from_case': 'snake_case',
    #                 'to_case': 'PascalCase'
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': f"Error converting snake_case to PascalCase: {str(e)}",
    #                 'error_code': 11004
    #             }

    #     def camel_to_snake(self, text: str) -Dict[str, Any]):
    #         """
    #         Convert camelCase to snake_case.

    #         Args:
    #             text: Text to convert

    #         Returns:
    #             Dictionary containing converted text
    #         """
    #         try:
    #             # Insert underscore before capital letters
    snake_case = re.sub(r'(?<!^)(?=[A-Z])', '_', text).lower()

    #             return {
    #                 'success': True,
    #                 'original_text': text,
    #                 'converted_text': snake_case,
    #                 'from_case': 'camelCase',
    #                 'to_case': 'snake_case'
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': f"Error converting camelCase to snake_case: {str(e)}",
    #                 'error_code': 11005
    #             }

    #     def pascal_to_snake(self, text: str) -Dict[str, Any]):
    #         """
    #         Convert PascalCase to snake_case.

    #         Args:
    #             text: Text to convert

    #         Returns:
    #             Dictionary containing converted text
    #         """
    #         try:
    #             # Insert underscore before capital letters
    snake_case = re.sub(r'(?<!^)(?=[A-Z])', '_', text).lower()

    #             return {
    #                 'success': True,
    #                 'original_text': text,
    #                 'converted_text': snake_case,
    #                 'from_case': 'PascalCase',
    #                 'to_case': 'snake_case'
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': f"Error converting PascalCase to snake_case: {str(e)}",
    #                 'error_code': 11006
    #             }

    #     def kebab_to_snake(self, text: str) -Dict[str, Any]):
    #         """
    #         Convert kebab-case to snake_case.

    #         Args:
    #             text: Text to convert

    #         Returns:
    #             Dictionary containing converted text
    #         """
    #         try:
    snake_case = text.replace('-', '_')

    #             return {
    #                 'success': True,
    #                 'original_text': text,
    #                 'converted_text': snake_case,
    #                 'from_case': 'kebab-case',
    #                 'to_case': 'snake_case'
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': f"Error converting kebab-case to snake_case: {str(e)}",
    #                 'error_code': 11007
    #             }

    #     def snake_to_kebab(self, text: str) -Dict[str, Any]):
    #         """
    #         Convert snake_case to kebab-case.

    #         Args:
    #             text: Text to convert

    #         Returns:
    #             Dictionary containing converted text
    #         """
    #         try:
    kebab_case = text.replace('_', '-')

    #             return {
    #                 'success': True,
    #                 'original_text': text,
    #                 'converted_text': kebab_case,
    #                 'from_case': 'snake_case',
    #                 'to_case': 'kebab-case'
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': f"Error converting snake_case to kebab-case: {str(e)}",
    #                 'error_code': 11008
    #             }

    #     def truncate(self, text: str, max_length: int, suffix: str = '...') -Dict[str, Any]):
    #         """
    #         Truncate a string to a maximum length.

    #         Args:
    #             text: Text to truncate
    #             max_length: Maximum length
    #             suffix: Suffix to add if truncated

    #         Returns:
    #             Dictionary containing truncated text
    #         """
    #         try:
    #             if len(text) <= max_length:
    #                 return {
    #                     'success': True,
    #                     'original_text': text,
    #                     'truncated_text': text,
    #                     'truncated': False
    #                 }

    truncated_text = text[:max_length - len(suffix)] + suffix

    #             return {
    #                 'success': True,
    #                 'original_text': text,
    #                 'truncated_text': truncated_text,
    #                 'truncated': True,
                    'original_length': len(text),
                    'truncated_length': len(truncated_text),
    #                 'max_length': max_length
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': f"Error truncating text: {str(e)}",
    #                 'error_code': 11009
    #             }

    #     def pad_left(self, text: str, length: int, fill_char: str = ' ') -Dict[str, Any]):
    #         """
    #         Pad a string on the left.

    #         Args:
    #             text: Text to pad
    #             length: Target length
    #             fill_char: Character to pad with

    #         Returns:
    #             Dictionary containing padded text
    #         """
    #         try:
    padded_text = text.ljust(length, fill_char)

    #             return {
    #                 'success': True,
    #                 'original_text': text,
    #                 'padded_text': padded_text,
                    'original_length': len(text),
                    'padded_length': len(padded_text),
    #                 'target_length': length,
    #                 'fill_char': fill_char
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': f"Error padding text: {str(e)}",
    #                 'error_code': 11010
    #             }

    #     def pad_right(self, text: str, length: int, fill_char: str = ' ') -Dict[str, Any]):
    #         """
    #         Pad a string on the right.

    #         Args:
    #             text: Text to pad
    #             length: Target length
    #             fill_char: Character to pad with

    #         Returns:
    #             Dictionary containing padded text
    #         """
    #         try:
    padded_text = text.rjust(length, fill_char)

    #             return {
    #                 'success': True,
    #                 'original_text': text,
    #                 'padded_text': padded_text,
                    'original_length': len(text),
                    'padded_length': len(padded_text),
    #                 'target_length': length,
    #                 'fill_char': fill_char
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': f"Error padding text: {str(e)}",
    #                 'error_code': 11011
    #             }

    #     def is_empty(self, text: str) -Dict[str, Any]):
    #         """
    #         Check if a string is empty or contains only whitespace.

    #         Args:
    #             text: Text to check

    #         Returns:
    #             Dictionary containing check result
    #         """
    #         try:
    is_empty = not text.strip()

    #             return {
    #                 'success': True,
    #                 'text': text,
    #                 'is_empty': is_empty,
                    'length': len(text)
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
    #                 'error': f"Error checking if text is empty: {str(e)}",
    #                 'error_code': 11012
    #             }

    #     def extract_numbers(self, text: str) -Dict[str, Any]):
    #         """
    #         Extract all numbers from a string.

    #         Args:
    #             text: Text to extract numbers from

    #         Returns:
    #             Dictionary containing extracted numbers
    #         """
    #         try:
    numbers = re.findall(r'\d+\.?\d*', text)

    #             # Convert to appropriate types
    extracted_numbers = []
    #             for num in numbers:
    #                 if '.' in num:
                        extracted_numbers.append(float(num))
    #                 else:
                        extracted_numbers.append(int(num))

    #             return {
    #                 'success': True,
    #                 'text': text,
    #                 'numbers': extracted_numbers,
                    'count': len(extracted_numbers)
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': f"Error extracting numbers: {str(e)}",
    #                 'error_code': 11013
    #             }

    #     def extract_emails(self, text: str) -Dict[str, Any]):
    #         """
    #         Extract all email addresses from a string.

    #         Args:
    #             text: Text to extract email addresses from

    #         Returns:
    #             Dictionary containing extracted email addresses
    #         """
    #         try:
    email_pattern = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'
    emails = re.findall(email_pattern, text)

    #             return {
    #                 'success': True,
    #                 'text': text,
    #                 'emails': emails,
                    'count': len(emails)
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': f"Error extracting emails: {str(e)}",
    #                 'error_code': 11014
    #             }

    #     def extract_urls(self, text: str) -Dict[str, Any]):
    #         """
    #         Extract all URLs from a string.

    #         Args:
    #             text: Text to extract URLs from

    #         Returns:
    #             Dictionary containing extracted URLs
    #         """
    #         try:
    url_pattern = r'http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+'
    urls = re.findall(url_pattern, text)

    #             return {
    #                 'success': True,
    #                 'text': text,
    #                 'urls': urls,
                    'count': len(urls)
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': f"Error extracting URLs: {str(e)}",
    #                 'error_code': 11015
    #             }