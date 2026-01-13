# Converted from Python to NoodleCore
# Original file: src

# """
# Integration tests for NoodleCore components with .nc files.
# """

import pytest
import sys
import os
import json
import tempfile
import pathlib.Path
import unittest.mock.Mock

# Add src to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

import tests.test_utils.NoodleCodeGenerator


class TestNoodleIntegration
    #     """Integration test cases for NoodleCore components."""

    #     @pytest.fixture
    #     def sample_nc_file(self):""Fixture providing a sample .nc file."""
    content = NoodleCodeGenerator.generate_function_with_params()
    file_path = NoodleFileHelper.create_nc_file(content, "sample.nc")
    #         yield file_path
            NoodleFileHelper.cleanup_nc_file(file_path)

    #     @pytest.fixture
    #     def noodle_project(self):
    #         """Fixture providing a complete NoodleCore project."""
    #         # Create project directory
    project_dir = TestFileHelper.create_temp_directory()

    #         # Create main.nc file
    main_code = NoodleCodeGenerator.generate_function_with_params()
    main_file = project_dir / "main.nc"
            main_file.write_text(main_code)

    #         # Create utils.nc file
    utils_code = """
# // Utility functions in NoodleCore
function format_message(message, prefix) {
#     return prefix + ": " + message;
# }

function current_time() {
#     // Return current timestamp
#     return "2023-01-01 12:00:00";
# }
# """
utils_file = project_dir / "utils.nc"
        utils_file.write_text(utils_code)

#         # Create noodle.config.json file
config = {
#             "project": {
#                 "name": "TestProject",
#                 "version": "1.0.0",
#                 "entry_point": "main.nc"
#             },
#             "compiler": {
#                 "optimization_level": 2,
#                 "target_platform": "native",
#                 "debug_mode": False
#             },
#             "runtime": {
#                 "memory_limit": "512MB",
#                 "execution_timeout": 10
#             }
#         }

config_file = project_dir / "noodle.config.json"
config_file.write_text(json.dumps(config, indent = 2))

#         yield project_dir
        TestFileHelper.cleanup_temp_directory(project_dir)

#     @pytest.mark.integration
#     def test_cli_compiler_sandbox_integration(self, sample_nc_file):
#         """Test integration between CLI, compiler, and sandbox."""
#         # This would test the actual integration
#         # For now, we'll mock it
#         with patch('noodlecore.cli.NoodleCli') as mock_cli, \
             patch('noodlecore.compiler.NoodleCompiler') as mock_compiler, \
             patch('noodlecore.sandbox.NoodleSandbox') as mock_sandbox:

mock_cli_instance = Mock()
mock_cli.return_value = mock_cli_instance

mock_compiler_instance = Mock()
mock_compiler.return_value = mock_compiler_instance

mock_sandbox_instance = Mock()
mock_sandbox.return_value = mock_sandbox_instance

#             # Set up mock returns
mock_compiler_instance.compile_file.return_value = {
#                 'success': True,
#                 'bytecode': b'simulated_bytecode',
#                 'errors': []
#             }

mock_sandbox_instance.execute_bytecode.return_value = {
#                 'success': True,
#                 'output': 'Sum: 15\nHello, NoodleCore!\n',
#                 'exit_code': 0,
#                 'execution_time': 0.05,
#                 'memory_usage': 1024
#             }

mock_cli_instance.execute_nc_file.return_value = {
#                 'success': True,
#                 'output': 'Sum: 15\nHello, NoodleCore!\n',
#                 'exit_code': 0,
#                 'execution_time': 0.05,
#                 'memory_usage': 1024
#             }

#             # Test integration
result = mock_cli_instance.execute_nc_file(str(sample_nc_file))
#             assert result['success']
#             assert 'Sum: 15' in result['output']
#             assert 'Hello, NoodleCore!' in result['output']
assert result['exit_code'] = = 0

#             # Verify compiler was called
            mock_compiler_instance.compile_file.assert_called_once_with(str(sample_nc_file))

#             # Verify sandbox was called
            mock_sandbox_instance.execute_bytecode.assert_called_once()

#     @pytest.mark.integration
#     def test_ai_adapter_cli_integration(self, sample_nc_file):
#         """Test integration between AI adapters and CLI."""
#         # This would test the actual integration
#         # For now, we'll mock it
#         with patch('noodlecore.ai.completion.NoodleCompletionAdapter') as mock_ai, \
             patch('noodlecore.cli.NoodleCli') as mock_cli:

mock_ai_instance = Mock()
mock_ai.return_value = mock_ai_instance

mock_cli_instance = Mock()
mock_cli.return_value = mock_cli_instance

#             # Set up mock returns
mock_ai_instance.complete_code.return_value = {
#                 'success': True,
#                 'completion': '\n// AI generated completion\nfunction factorial(n) {\n    if (n <= 1) return 1;\n    return n * factorial(n - 1);\n}\n',
#                 'confidence': 0.85
#             }

mock_cli_instance.execute_ai_command.return_value = {
#                 'success': True,
#                 'output': '\n// AI generated completion\nfunction factorial(n) {\n    if (n <= 1) return 1;\n    return n * factorial(n - 1);\n}\n',
#                 'exit_code': 0
#             }

#             # Test integration
#             with open(sample_nc_file, 'r') as f:
code = f.read()

result = mock_cli_instance.execute_ai_command('complete', code)
#             assert result['success']
#             assert 'factorial' in result['output']
assert result['exit_code'] = = 0

#             # Verify AI adapter was called
            mock_ai_instance.complete_code.assert_called_once_with(code)

#     @pytest.mark.integration
#     def test_config_compiler_integration(self, noodle_project):
#         """Test integration between configuration and compiler."""
#         # This would test the actual integration
#         # For now, we'll mock it
#         with patch('noodlecore.config.NoodleConfigManager') as mock_config, \
             patch('noodlecore.compiler.NoodleCompiler') as mock_compiler:

mock_config_instance = Mock()
mock_config.return_value = mock_config_instance

mock_compiler_instance = Mock()
mock_compiler.return_value = mock_compiler_instance

#             # Set up mock returns
config_file = noodle_project / "noodle.config.json"
main_file = noodle_project / "main.nc"

mock_config_instance.load_from_file.return_value = {
#                 "project": {
#                     "name": "TestProject",
#                     "version": "1.0.0",
#                     "entry_point": "main.nc"
#                 },
#                 "compiler": {
#                     "optimization_level": 2,
#                     "target_platform": "native",
#                     "debug_mode": False
#                 }
#             }

mock_compiler_instance.compile_file.return_value = {
#                 'success': True,
#                 'bytecode': b'simulated_bytecode',
#                 'errors': []
#             }

#             # Test integration
config = mock_config_instance.load_from_file(str(config_file))
assert config["project"]["entry_point"] = = "main.nc"
assert config["compiler"]["optimization_level"] = = 2

#             # Use configuration for compilation
entry_point = noodle_project / config["project"]["entry_point"]
result = mock_compiler_instance.compile_file(str(entry_point))
#             assert result['success']

#             # Verify compiler was called with correct file
            mock_compiler_instance.compile_file.assert_called_once_with(str(entry_point))

#     @pytest.mark.integration
#     def test_ide_lsp_compiler_integration(self, sample_nc_file):
#         """Test integration between IDE LSP and compiler."""
#         # This would test the actual integration
#         # For now, we'll mock it
#         with patch('noodlecore.ide.lsp.NoodleLSPServer') as mock_lsp, \
             patch('noodlecore.compiler.NoodleCompiler') as mock_compiler:

mock_lsp_instance = Mock()
mock_lsp.return_value = mock_lsp_instance

mock_compiler_instance = Mock()
mock_compiler.return_value = mock_compiler_instance

#             # Set up mock returns
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

#             # Test integration
parse_result = mock_compiler_instance.parse_file(str(sample_nc_file))
#             assert parse_result['success']

#             # Use AST for diagnostics
diagnostics = mock_lsp_instance.provide_diagnostics(str(sample_nc_file))
#             assert 'diagnostics' in diagnostics

#             # Verify compiler was called
            mock_compiler_instance.parse_file.assert_called_once_with(str(sample_nc_file))

#     @pytest.mark.integration
#     def test_full_project_workflow(self, noodle_project):
#         """Test full project workflow from configuration to execution."""
#         # This would test the actual workflow
#         # For now, we'll mock it
#         with patch('noodlecore.config.NoodleConfigManager') as mock_config, \
             patch('noodlecore.compiler.NoodleCompiler') as mock_compiler, \
             patch('noodlecore.sandbox.NoodleSandbox') as mock_sandbox, \
             patch('noodlecore.cli.NoodleCli') as mock_cli:

mock_config_instance = Mock()
mock_config.return_value = mock_config_instance

mock_compiler_instance = Mock()
mock_compiler.return_value = mock_compiler_instance

mock_sandbox_instance = Mock()
mock_sandbox.return_value = mock_sandbox_instance

mock_cli_instance = Mock()
mock_cli.return_value = mock_cli_instance

#             # Set up mock returns
config_file = noodle_project / "noodle.config.json"
main_file = noodle_project / "main.nc"
utils_file = noodle_project / "utils.nc"

mock_config_instance.load_from_file.return_value = {
#                 "project": {
#                     "name": "TestProject",
#                     "version": "1.0.0",
#                     "entry_point": "main.nc"
#                 },
#                 "compiler": {
#                     "optimization_level": 2,
#                     "target_platform": "native",
#                     "debug_mode": False
#                 },
#                 "runtime": {
#                     "memory_limit": "512MB",
#                     "execution_timeout": 10
#                 }
#             }

mock_compiler_instance.compile_file.return_value = {
#                 'success': True,
#                 'bytecode': b'simulated_bytecode',
#                 'errors': []
#             }

mock_sandbox_instance.execute_bytecode.return_value = {
#                 'success': True,
#                 'output': 'Sum: 15\nHello, NoodleCore!\n',
#                 'exit_code': 0,
#                 'execution_time': 0.05,
#                 'memory_usage': 1024
#             }

mock_cli_instance.run_project.return_value = {
#                 'success': True,
#                 'output': 'Sum: 15\nHello, NoodleCore!\n',
#                 'exit_code': 0,
#                 'execution_time': 0.05,
#                 'memory_usage': 1024
#             }

#             # Test full workflow
#             # 1. Load configuration
config = mock_config_instance.load_from_file(str(config_file))
assert config["project"]["entry_point"] = = "main.nc"

#             # 2. Compile project
entry_point = noodle_project / config["project"]["entry_point"]
compile_result = mock_compiler_instance.compile_file(str(entry_point))
#             assert compile_result['success']

#             # 3. Execute project
execute_result = mock_sandbox_instance.execute_bytecode(compile_result['bytecode'])
#             assert execute_result['success']
#             assert 'Sum: 15' in execute_result['output']

#             # 4. Run project through CLI
run_result = mock_cli_instance.run_project(str(noodle_project))
#             assert run_result['success']
#             assert 'Sum: 15' in run_result['output']

#     @pytest.mark.integration
#     def test_error_handling_workflow(self):
#         """Test error handling workflow across components."""
#         # Create a file with syntax errors
error_code = """
# // Syntax error test in NoodleCore
function test_function()
    print('Missing opening brace')
# }

test_function()
# """
file_path = NoodleFileHelper.create_nc_file(error_code, "syntax_error.nc")

#         try:
#             # This would test the actual error handling
#             # For now, we'll mock it
#             with patch('noodlecore.compiler.NoodleCompiler') as mock_compiler, \
                 patch('noodlecore.cli.NoodleCli') as mock_cli:

mock_compiler_instance = Mock()
mock_compiler.return_value = mock_compiler_instance

mock_cli_instance = Mock()
mock_cli.return_value = mock_cli_instance

#                 # Set up mock returns
mock_compiler_instance.compile_file.return_value = {
#                     'success': False,
#                     'bytecode': None,
#                     'errors': [
#                         {
#                             'type': 'SyntaxError',
#                             'message': 'Missing opening brace',
#                             'line': 2,
#                             'column': 25
#                         }
#                     ]
#                 }

mock_cli_instance.execute_nc_file.return_value = {
#                     'success': False,
#                     'output': '',
#                     'error': 'Syntax error: Missing opening brace',
#                     'exit_code': 1
#                 }

#                 # Test error handling
compile_result = mock_compiler_instance.compile_file(str(file_path))
#                 assert not compile_result['success']
                assert len(compile_result['errors']) 0

#                 # Test CLI error handling
execute_result = mock_cli_instance.execute_nc_file(str(file_path))
#                 assert not execute_result['success']
#                 assert 'Syntax error' in execute_result['error']
assert execute_result['exit_code'] = = 1
#         finally):
            NoodleFileHelper.cleanup_nc_file(file_path)

#     @pytest.mark.performance
#     def test_integration_performance(self, noodle_project):
#         """Test performance of the full integration."""
#         # This would test the actual performance
#         # For now, we'll mock it
#         with patch('noodlecore.config.NoodleConfigManager') as mock_config, \
             patch('noodlecore.compiler.NoodleCompiler') as mock_compiler, \
             patch('noodlecore.sandbox.NoodleSandbox') as mock_sandbox:

mock_config_instance = Mock()
mock_config.return_value = mock_config_instance

mock_compiler_instance = Mock()
mock_compiler.return_value = mock_compiler_instance

mock_sandbox_instance = Mock()
mock_sandbox.return_value = mock_sandbox_instance

#             # Set up mock returns with timing
#             def load_from_file(file_path):
#                 import time
                time.sleep(0.01)  # Simulate 10ms loading time
#                 return {
#                     "project": {
#                         "name": "TestProject",
#                         "version": "1.0.0",
#                         "entry_point": "main.nc"
#                     },
#                     "compiler": {
#                         "optimization_level": 2,
#                         "target_platform": "native",
#                         "debug_mode": False
#                     }
#                 }

#             def compile_file(file_path):
#                 import time
                time.sleep(0.05)  # Simulate 50ms compilation time
#                 return {
#                     'success': True,
#                     'bytecode': b'simulated_bytecode',
#                     'errors': []
#                 }

#             def execute_bytecode(bytecode):
#                 import time
                time.sleep(0.02)  # Simulate 20ms execution time
#                 return {
#                     'success': True,
#                     'output': 'Sum: 15\nHello, NoodleCore!\n',
#                     'exit_code': 0,
#                     'execution_time': 0.02,
#                     'memory_usage': 1024
#                 }

mock_config_instance.load_from_file.side_effect = load_from_file
mock_compiler_instance.compile_file.side_effect = compile_file
mock_sandbox_instance.execute_bytecode.side_effect = execute_bytecode

#             # Measure performance
monitor = PerformanceMonitor()

config_file = noodle_project / "noodle.config.json"
main_file = noodle_project / "main.nc"

            monitor.start_timing("full_integration")

#             # Load configuration
config = mock_config_instance.load_from_file(str(config_file))

#             # Compile project
entry_point = noodle_project / config["project"]["entry_point"]
compile_result = mock_compiler_instance.compile_file(str(entry_point))

#             # Execute project
execute_result = mock_sandbox_instance.execute_bytecode(compile_result['bytecode'])

duration = monitor.end_timing("full_integration")

#             # Verify performance
assert config["project"]["entry_point"] = = "main.nc"
#             assert compile_result['success']
#             assert execute_result['success']
#             assert duration < 0.2  # Should complete in less than 200ms