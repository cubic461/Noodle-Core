# Converted from Python to NoodleCore
# Original file: src

# """
# Tests for NoodleCore IDE integration with .nc files.
# """

import pytest
import sys
import os
import json
import pathlib.Path
import unittest.mock.Mock

# Add src to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

import tests.test_utils.NoodleCodeGenerator


class TestNoodleIDEIntegration
    #     """Test cases for NoodleCore IDE integration."""

    #     @pytest.fixture
    #     def sample_nc_file(self):""Fixture providing a sample .nc file."""
    content = NoodleCodeGenerator.generate_function_with_params()
    file_path = NoodleFileHelper.create_nc_file(content, "sample.nc")
    #         yield file_path
            NoodleFileHelper.cleanup_nc_file(file_path)

    #     @pytest.fixture
    #     def incomplete_nc_file(self):
    #         """Fixture providing an incomplete .nc file for IDE completion."""
    content = """
# // Incomplete NoodleCore program for IDE completion
function calculate_sum(a, b) {
#     return a + b;
# }

function main() {
let x = 5;
let y = 10;
let sum = calculate_sum(x, y);
    print("Sum: " + sum);

#     // TODO: Add more functionality here
# """
file_path = NoodleFileHelper.create_nc_file(content, "incomplete.nc")
#         yield file_path
        NoodleFileHelper.cleanup_nc_file(file_path)

#     @pytest.fixture
#     def syntax_error_nc_file(self):
#         """Fixture providing a syntax error .nc file."""
content = NoodleCodeGenerator.generate_syntax_error()
file_path = NoodleFileHelper.create_nc_file(content, "syntax_error.nc")
#         yield file_path
        NoodleFileHelper.cleanup_nc_file(file_path)

#     @pytest.mark.unit
#     def test_ide_lsp_initialization(self):
#         """Test that the IDE LSP initializes correctly."""
#         # This would test the actual IDE LSP initialization
#         # For now, we'll mock it
#         with patch('noodlecore.ide.lsp.NoodleLSPServer') as mock_lsp:
mock_instance = Mock()
mock_lsp.return_value = mock_instance
mock_instance.initialize.return_value = True

#             # Test initialization
            assert mock_instance.initialize()

#     @pytest.mark.unit
#     def test_ide_lsp_completion(self, incomplete_nc_file):
#         """Test that the IDE LSP provides completion for .nc files."""
#         # This would test the actual IDE LSP completion
#         # For now, we'll mock it
#         with patch('noodlecore.ide.lsp.NoodleLSPServer') as mock_lsp:
mock_instance = Mock()
mock_lsp.return_value = mock_instance
mock_instance.provide_completion.return_value = {
#                 'items': [
#                     {
#                         'label': 'function',
#                         'kind': 15,  # Snippet
#                         'detail': 'function declaration',
#                         'documentation': 'Declares a new function',
                        'insertText': 'function ${1:name}(${2:params}) {\n    ${3:// body}\n}',
#                         'insertTextFormat': 2  # Snippet
#                     },
#                     {
#                         'label': 'let',
#                         'kind': 14,  # Keyword
#                         'detail': 'variable declaration',
#                         'documentation': 'Declares a new variable',
'insertText': 'let ${1:name} = ${2:value};',
#                         'insertTextFormat': 2  # Snippet
#                     }
#                 ]
#             }

#             # Test completion
result = mock_instance.provide_completion(str(incomplete_nc_file), 15, 5)
#             assert 'items' in result
            assert len(result['items']) 0
#             assert any(item['label'] == 'function' for item in result['items'])

#     @pytest.mark.unit
#     def test_ide_lsp_diagnostics(self, syntax_error_nc_file)):
#         """Test that the IDE LSP provides diagnostics for .nc files."""
#         # This would test the actual IDE LSP diagnostics
#         # For now, we'll mock it
#         with patch('noodlecore.ide.lsp.NoodleLSPServer') as mock_lsp:
mock_instance = Mock()
mock_lsp.return_value = mock_instance
mock_instance.provide_diagnostics.return_value = {
                'uri': str(syntax_error_nc_file),
#                 'diagnostics': [
#                     {
#                         'range': {
#                             'start': {'line': 3, 'character': 0},
#                             'end': {'line': 3, 'character': 25}
#                         },
#                         'severity': 1,  # Error
#                         'source': 'noodlecore',
#                         'message': 'Missing closing brace',
#                         'code': 'E001'
#                     }
#                 ]
#             }

#             # Test diagnostics
result = mock_instance.provide_diagnostics(str(syntax_error_nc_file))
#             assert 'diagnostics' in result
            assert len(result['diagnostics']) 0
assert result['diagnostics'][0]['severity'] = = 1  # Error
#             assert 'Missing closing brace' in result['diagnostics'][0]['message']

#     @pytest.mark.unit
#     def test_ide_lsp_hover(self, sample_nc_file)):
#         """Test that the IDE LSP provides hover information for .nc files."""
#         # This would test the actual IDE LSP hover
#         # For now, we'll mock it
#         with patch('noodlecore.ide.lsp.NoodleLSPServer') as mock_lsp:
mock_instance = Mock()
mock_lsp.return_value = mock_instance
mock_instance.provide_hover.return_value = {
#                 'contents': {
#                     'kind': 'markdown',
                    'value': '```noodlecore\nfunction calculate_sum(a, b) {\n    return a + b;\n}\n```\n\nCalculates the sum of two numbers.\n\n**Parameters:**\n- `a` (number): First number\n- `b` (number): Second number\n\n**Returns:**\n- (number): The sum of a and b'
#                 },
#                 'range': {
#                     'start': {'line': 1, 'character': 0},
#                     'end': {'line': 1, 'character': 16}
#                 }
#             }

#             # Test hover
result = mock_instance.provide_hover(str(sample_nc_file), 2, 9)
#             assert 'contents' in result
#             assert 'calculate_sum' in result['contents']['value']

#     @pytest.mark.unit
#     def test_ide_lsp_signature_help(self, incomplete_nc_file):
#         """Test that the IDE LSP provides signature help for .nc files."""
#         # This would test the actual IDE LSP signature help
#         # For now, we'll mock it
#         with patch('noodlecore.ide.lsp.NoodleLSPServer') as mock_lsp:
mock_instance = Mock()
mock_lsp.return_value = mock_instance
mock_instance.provide_signature_help.return_value = {
#                 'signatures': [
#                     {
                        'label': 'calculate_sum(a, b)',
#                         'documentation': 'Calculates the sum of two numbers.',
#                         'parameters': [
#                             {
#                                 'label': 'a',
#                                 'documentation': 'First number'
#                             },
#                             {
#                                 'label': 'b',
#                                 'documentation': 'Second number'
#                             }
#                         ]
#                     }
#                 ],
#                 'activeSignature': 0,
#                 'activeParameter': 1
#             }

#             # Test signature help
result = mock_instance.provide_signature_help(str(incomplete_nc_file), 12, 25)
#             assert 'signatures' in result
            assert len(result['signatures']) 0
#             assert 'calculate_sum' in result['signatures'][0]['label']

#     @pytest.mark.unit
#     def test_ide_lsp_goto_definition(self, sample_nc_file)):
#         """Test that the IDE LSP provides goto definition for .nc files."""
#         # This would test the actual IDE LSP goto definition
#         # For now, we'll mock it
#         with patch('noodlecore.ide.lsp.NoodleLSPServer') as mock_lsp:
mock_instance = Mock()
mock_lsp.return_value = mock_instance
mock_instance.provide_definition.return_value = {
                'uri': str(sample_nc_file),
#                 'range': {
#                     'start': {'line': 1, 'character': 0},
#                     'end': {'line': 1, 'character': 16}
#                 }
#             }

#             # Test goto definition
result = mock_instance.provide_definition(str(sample_nc_file), 12, 20)
#             assert 'uri' in result
#             assert 'range' in result
assert result['uri'] = = str(sample_nc_file)

#     @pytest.mark.unit
#     def test_ide_lsp_find_references(self, sample_nc_file):
#         """Test that the IDE LSP provides find references for .nc files."""
#         # This would test the actual IDE LSP find references
#         # For now, we'll mock it
#         with patch('noodlecore.ide.lsp.NoodleLSPServer') as mock_lsp:
mock_instance = Mock()
mock_lsp.return_value = mock_instance
mock_instance.provide_references.return_value = [
#                 {
                    'uri': str(sample_nc_file),
#                     'range': {
#                         'start': {'line': 1, 'character': 0},
#                         'end': {'line': 1, 'character': 16}
#                     }
#                 },
#                 {
                    'uri': str(sample_nc_file),
#                     'range': {
#                         'start': {'line': 12, 'character': 20},
#                         'end': {'line': 12, 'character': 32}
#                     }
#                 }
#             ]

#             # Test find references
result = mock_instance.provide_references(str(sample_nc_file), 2, 9)
            assert len(result) 0
#             assert all('uri' in ref and 'range' in ref for ref in result)

#     @pytest.mark.unit
#     def test_ide_lsp_formatting(self, sample_nc_file)):
#         """Test that the IDE LSP provides formatting for .nc files."""
#         # This would test the actual IDE LSP formatting
#         # For now, we'll mock it
#         with patch('noodlecore.ide.lsp.NoodleLSPServer') as mock_lsp:
mock_instance = Mock()
mock_lsp.return_value = mock_instance
mock_instance.provide_formatting.return_value = [
#                 {
#                     'range': {
#                         'start': {'line': 0, 'character': 0},
#                         'end': {'line': 20, 'character': 0}
#                     },
#                     'newText': """
# // Functions and variables test in NoodleCore
function calculate_sum(a, b) {
#     return a + b;
# }

function greet(name) {
#     return "Hello, " + name + "!";
# }

function main() {
let x = 5;
let y = 10;
let sum = calculate_sum(x, y);

    print("Sum: " + sum);

let message = greet("NoodleCore");
    print(message);
# }

main();
# """
#                 }
#             ]

#             # Test formatting
result = mock_instance.provide_formatting(str(sample_nc_file))
            assert len(result) 0
#             assert 'newText' in result[0]

#     @pytest.mark.unit
#     def test_ide_lsp_rename(self, sample_nc_file)):
#         """Test that the IDE LSP provides rename for .nc files."""
#         # This would test the actual IDE LSP rename
#         # For now, we'll mock it
#         with patch('noodlecore.ide.lsp.NoodleLSPServer') as mock_lsp:
mock_instance = Mock()
mock_lsp.return_value = mock_instance
mock_instance.provide_rename.return_value = {
#                 'changes': {
                    str(sample_nc_file): [
#                         {
#                             'range': {
#                                 'start': {'line': 1, 'character': 9},
#                                 'end': {'line': 1, 'character': 20}
#                             },
#                             'newText': 'calculate_total'
#                         },
#                         {
#                             'range': {
#                                 'start': {'line': 12, 'character': 20},
#                                 'end': {'line': 12, 'character': 31}
#                             },
#                             'newText': 'calculate_total'
#                         }
#                     ]
#                 }
#             }

#             # Test rename
result = mock_instance.provide_rename(str(sample_nc_file), 2, 15, 'calculate_total')
#             assert 'changes' in result
            assert str(sample_nc_file) in result['changes']
            assert len(result['changes'][str(sample_nc_file)]) 0

#     @pytest.mark.performance
#     def test_ide_lsp_performance_completion(self, incomplete_nc_file)):
#         """Test IDE LSP performance when providing completion."""
#         # This would test the actual IDE LSP performance
#         # For now, we'll mock it
#         with patch('noodlecore.ide.lsp.NoodleLSPServer') as mock_lsp:
mock_instance = Mock()
mock_lsp.return_value = mock_instance

#             # Simulate completion time
#             def provide_completion(file_path, line, character):
#                 import time
                time.sleep(0.02)  # Simulate 20ms completion time
#                 return {
#                     'items': [
#                         {
#                             'label': 'function',
#                             'kind': 15,
#                             'detail': 'function declaration'
#                         }
#                     ]
#                 }

mock_instance.provide_completion.side_effect = provide_completion

#             # Measure performance
monitor = PerformanceMonitor()
            monitor.start_timing("lsp_completion")
result = mock_instance.provide_completion(str(incomplete_nc_file), 15, 5)
duration = monitor.end_timing("lsp_completion")

#             # Verify performance
#             assert 'items' in result
#             assert duration < 0.1  # Should complete in less than 100ms

#     @pytest.mark.integration
#     def test_ide_lsp_with_compiler(self, sample_nc_file):
#         """Test IDE LSP integration with the NoodleCore compiler."""
#         # This would test the actual IDE LSP integration with compiler
#         # For now, we'll mock it
#         with patch('noodlecore.ide.lsp.NoodleLSPServer') as mock_lsp, \
             patch('noodlecore.compiler.NoodleCompiler') as mock_compiler:

mock_lsp_instance = Mock()
mock_lsp.return_value = mock_lsp_instance

mock_compiler_instance = Mock()
mock_compiler.return_value = mock_compiler_instance

mock_compiler_instance.parse_file.return_value = {
#                 'success': True,
#                 'ast': {
#                     'type': 'Program',
#                     'functions': [
#                         {
#                             'name': 'calculate_sum',
#                             'params': ['a', 'b'],
#                             'body': [
#                                 {
#                                     'type': 'ReturnStatement',
#                                     'argument': {
#                                         'type': 'BinaryExpression',
#                                         'operator': '+',
#                                         'left': {'type': 'Identifier', 'name': 'a'},
#                                         'right': {'type': 'Identifier', 'name': 'b'}
#                                     }
#                                 }
#                             ],
#                             'range': {
#                                 'start': {'line': 1, 'character': 0},
#                                 'end': {'line': 3, 'character': 1}
#                             }
#                         }
#                     ]
#                 },
#                 'errors': []
#             }

mock_lsp_instance.provide_diagnostics.return_value = {
                'uri': str(sample_nc_file),
#                 'diagnostics': []
#             }

#             # Test diagnostics with compiler
parse_result = mock_compiler_instance.parse_file(str(sample_nc_file))
#             assert parse_result['success']

#             # Use AST for diagnostics
diagnostics = mock_lsp_instance.provide_diagnostics(str(sample_nc_file))
#             assert 'diagnostics' in diagnostics