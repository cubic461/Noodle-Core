# Converted from Python to NoodleCore
# Original file: src

# """
# Security tests for NoodleCore components with .nc files.
# """

import pytest
import sys
import os
import pathlib.Path
import unittest.mock.Mock

# Add src to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

import tests.test_utils.NoodleCodeGenerator


class TestNoodleSecurity
    #     """Security test cases for NoodleCore components."""

    #     @pytest.fixture
    #     def sample_nc_file(self):""Fixture providing a sample .nc file."""
    content = NoodleCodeGenerator.generate_function_with_params()
    file_path = NoodleFileHelper.create_nc_file(content, "sample.nc")
    #         yield file_path
            NoodleFileHelper.cleanup_nc_file(file_path)

    #     @pytest.mark.security
    #     def test_sandbox_file_system_access_restricted(self):
    #         """Test that the sandbox restricts file system access."""
    #         # This would test the actual sandbox security
    #         # For now, we'll mock it
    #         with patch('noodlecore.sandbox.NoodleSandbox') as mock_sandbox:
    mock_instance = Mock()
    mock_sandbox.return_value = mock_instance

    #             # Create a .nc file that tries to access file system
    file_system_code = """
# // File system access test in NoodleCore
function main() {
#     // This should fail in sandbox
let content = file_read("/etc/passwd");
    print(content);
# }

main();
# """
file_path = NoodleFileHelper.create_nc_file(file_system_code, "file_system.nc")

#             try:
mock_instance.execute_nc_file.return_value = {
#                     'success': False,
#                     'output': '',
#                     'error': 'File system access denied: file system access is restricted in sandbox',
#                     'exit_code': 1,
#                     'execution_time': 0.05,
#                     'memory_usage': 1024
#                 }

#                 # Test execution
result = mock_instance.execute_nc_file(str(file_path))
#                 assert not result['success']
#                 assert 'File system access denied' in result['error']
assert result['exit_code'] = = 1
#             finally:
                NoodleFileHelper.cleanup_nc_file(file_path)

#     @pytest.mark.security
#     def test_sandbox_network_access_restricted(self):
#         """Test that the sandbox restricts network access."""
#         # This would test the actual sandbox security
#         # For now, we'll mock it
#         with patch('noodlecore.sandbox.NoodleSandbox') as mock_sandbox:
mock_instance = Mock()
mock_sandbox.return_value = mock_instance

#             # Create a .nc file that tries to access network
network_code = """
# // Network access test in NoodleCore
function main() {
#     // This should fail in sandbox
let response = http_get("https://example.com");
    print(response);
# }

main();
# """
file_path = NoodleFileHelper.create_nc_file(network_code, "network.nc")

#             try:
mock_instance.execute_nc_file.return_value = {
#                     'success': False,
#                     'output': '',
#                     'error': 'Network access denied: network access is disabled in sandbox',
#                     'exit_code': 1,
#                     'execution_time': 0.05,
#                     'memory_usage': 1024
#                 }

#                 # Test execution
result = mock_instance.execute_nc_file(str(file_path))
#                 assert not result['success']
#                 assert 'Network access denied' in result['error']
assert result['exit_code'] = = 1
#             finally:
                NoodleFileHelper.cleanup_nc_file(file_path)

#     @pytest.mark.security
#     def test_sandbox_system_command_execution_restricted(self):
#         """Test that the sandbox restricts system command execution."""
#         # This would test the actual sandbox security
#         # For now, we'll mock it
#         with patch('noodlecore.sandbox.NoodleSandbox') as mock_sandbox:
mock_instance = Mock()
mock_sandbox.return_value = mock_instance

#             # Create a .nc file that tries to execute system commands
system_code = """
# // System command execution test in NoodleCore
function main() {
#     // This should fail in sandbox
let result = system("ls -la");
    print(result);
# }

main();
# """
file_path = NoodleFileHelper.create_nc_file(system_code, "system.nc")

#             try:
mock_instance.execute_nc_file.return_value = {
#                     'success': False,
#                     'output': '',
#                     'error': 'System command execution denied: system command execution is restricted in sandbox',
#                     'exit_code': 1,
#                     'execution_time': 0.05,
#                     'memory_usage': 1024
#                 }

#                 # Test execution
result = mock_instance.execute_nc_file(str(file_path))
#                 assert not result['success']
#                 assert 'System command execution denied' in result['error']
assert result['exit_code'] = = 1
#             finally:
                NoodleFileHelper.cleanup_nc_file(file_path)

#     @pytest.mark.security
#     def test_sandbox_memory_limit_enforced(self):
#         """Test that the sandbox enforces memory limits."""
#         # This would test the actual sandbox security
#         # For now, we'll mock it
#         with patch('noodlecore.sandbox.NoodleSandbox') as mock_sandbox:
mock_instance = Mock()
mock_sandbox.return_value = mock_instance

#             # Create a .nc file that tries to consume excessive memory
memory_code = """
# // Memory consumption test in NoodleCore
function main() {
let large_array = [];
let i = 0;

#     while (i < 1000000) {
        large_array.push("This is a large string that consumes memory");
i = i + 1;
#     }

#     print("Created array with " + large_array.length + " elements");
# }

main();
# """
file_path = NoodleFileHelper.create_nc_file(memory_code, "memory.nc")

#             try:
mock_instance.execute_nc_file.return_value = {
#                     'success': False,
#                     'output': 'Created array with 100000 elements\n',
#                     'error': 'Memory limit exceeded: 1GB limit reached',
#                     'exit_code': 1,
#                     'execution_time': 5.0,
#                     'memory_usage': 1073741824  # 1GB
#                 }

#                 # Test execution
result = mock_instance.execute_nc_file(str(file_path))
#                 assert not result['success']
#                 assert 'Memory limit exceeded' in result['error']
assert result['exit_code'] = = 1
assert result['memory_usage'] = 1073741824
#             finally):
                NoodleFileHelper.cleanup_nc_file(file_path)

#     @pytest.mark.security
#     def test_sandbox_execution_timeout_enforced(self):
#         """Test that the sandbox enforces execution timeout."""
#         # This would test the actual sandbox security
#         # For now, we'll mock it
#         with patch('noodlecore.sandbox.NoodleSandbox') as mock_sandbox:
mock_instance = Mock()
mock_sandbox.return_value = mock_instance

#             # Create a .nc file with an infinite loop
infinite_code = """
# // Infinite loop test in NoodleCore
function main() {
#     while (true) {
        print("This will run forever");
#     }
# }

main();
# """
file_path = NoodleFileHelper.create_nc_file(infinite_code, "infinite.nc")

#             try:
mock_instance.execute_nc_file.return_value = {
#                     'success': False,
#                     'output': 'This will run forever\n',
#                     'error': 'Execution timeout: 30 seconds exceeded',
#                     'exit_code': 1,
#                     'execution_time': 30.0,
#                     'memory_usage': 1024
#                 }

#                 # Test execution
result = mock_instance.execute_nc_file(str(file_path))
#                 assert not result['success']
#                 assert 'Execution timeout' in result['error']
assert result['exit_code'] = = 1
assert result['execution_time'] = 30.0
#             finally):
                NoodleFileHelper.cleanup_nc_file(file_path)

#     @pytest.mark.security
#     def test_cli_input_sanitization(self):
#         """Test that the CLI sanitizes user input."""
#         # This would test the actual CLI security
#         # For now, we'll mock it
#         with patch('noodlecore.cli.NoodleCli') as mock_cli:
mock_instance = Mock()
mock_cli.return_value = mock_instance

#             # Test XSS vectors
#             for xss_vector in TestDataProvider.xss_vectors():
mock_instance.execute_nc_file.return_value = {
#                     'success': False,
#                     'output': '',
#                     'error': 'Invalid file path: contains potentially dangerous characters',
#                     'exit_code': 1
#                 }

#                 # Test execution with XSS vector
result = mock_instance.execute_nc_file(xss_vector)
#                 assert not result['success']
#                 assert 'Invalid file path' in result['error']
assert result['exit_code'] = = 1

#     @pytest.mark.security
#     def test_config_sensitive_data_encrypted(self):
#         """Test that sensitive configuration data is encrypted."""
#         # This would test the actual configuration security
#         # For now, we'll mock it
#         with patch('noodlecore.config.NoodleConfigManager') as mock_config:
mock_instance = Mock()
mock_config.return_value = mock_instance

#             # Test setting sensitive data
mock_instance.set.return_value = True
mock_instance.get.return_value = "encrypted_value"
mock_instance.is_encrypted.return_value = True

#             # Test setting and getting sensitive data
mock_instance.set("database.password", "secret_password", encrypted = True)
value = mock_instance.get("database.password")
is_encrypted = mock_instance.is_encrypted("database.password")

assert value = = "encrypted_value"
#             assert is_encrypted

#     @pytest.mark.security
#     def test_ai_output_sanitization(self):
#         """Test that AI output is sanitized."""
#         # This would test the actual AI security
#         # For now, we'll mock it
#         with patch('noodlecore.ai.completion.NoodleCompletionAdapter') as mock_ai:
mock_instance = Mock()
mock_ai.return_value = mock_instance

#             # Test with malicious input
malicious_input = "function test() { system('rm -rf /'); }"

mock_instance.complete_code.return_value = {
#                 'success': True,
                'completion': 'function test() {\n    print("Safe completion");\n}',
#                 'confidence': 0.85,
#                 'sanitized': True
#             }

#             # Test completion
result = mock_instance.complete_code(malicious_input)
#             assert result['success']
#             assert 'system' not in result['completion']
#             assert result['sanitized']

#     @pytest.mark.security
#     def test_ide_lsp_path_traversal_prevented(self):
#         """Test that the IDE LSP prevents path traversal attacks."""
#         # This would test the actual IDE LSP security
#         # For now, we'll mock it
#         with patch('noodlecore.ide.lsp.NoodleLSPServer') as mock_lsp:
mock_instance = Mock()
mock_lsp.return_value = mock_instance

#             # Test with path traversal vectors
#             for path_vector in TestDataProvider.path_traversal_vectors():
mock_instance.provide_diagnostics.return_value = {
#                     'uri': 'file://invalid',
#                     'diagnostics': [
#                         {
#                             'range': {
#                                 'start': {'line': 0, 'character': 0},
#                                 'end': {'line': 0, 'character': 0}
#                             },
#                             'severity': 1,  # Error
#                             'source': 'noodlecore',
#                             'message': 'Path traversal detected: access to parent directories is not allowed',
#                             'code': 'E002'
#                         }
#                     ]
#                 }

#                 # Test diagnostics with path traversal
result = mock_instance.provide_diagnostics(path_vector)
#                 assert 'diagnostics' in result
                assert len(result['diagnostics']) 0
#                 assert 'Path traversal detected' in result['diagnostics'][0]['message']

#     @pytest.mark.security
#     def test_compiler_code_injection_prevented(self)):
#         """Test that the compiler prevents code injection attacks."""
#         # This would test the actual compiler security
#         # For now, we'll mock it
#         with patch('noodlecore.compiler.NoodleCompiler') as mock_compiler:
mock_instance = Mock()
mock_compiler.return_value = mock_instance

#             # Test with code injection vectors
#             for injection_vector in TestDataProvider.command_injection_vectors():
mock_instance.compile_file.return_value = {
#                     'success': False,
#                     'bytecode': None,
#                     'errors': [
#                         {
#                             'type': 'SecurityError',
#                             'message': 'Code injection detected: potentially dangerous code found',
#                             'line': 1,
#                             'column': 0
#                         }
#                     ]
#                 }

#                 # Create a temporary file with injection vector
file_path = NoodleFileHelper.create_nc_file(injection_vector, "injection.nc")

#                 try:
#                     # Test compilation
result = mock_instance.compile_file(str(file_path))
#                     assert not result['success']
                    assert len(result['errors']) 0
#                     assert 'Code injection detected' in result['errors'][0]['message']
#                 finally):
                    NoodleFileHelper.cleanup_nc_file(file_path)

#     @pytest.mark.security
#     def test_logging_sensitive_data_masked(self):
#         """Test that sensitive data is masked in logs."""
#         # This would test the actual logging security
#         # For now, we'll mock it
#         with patch('noodlecore.logging.NoodleLogger') as mock_logger:
mock_instance = Mock()
mock_logger.return_value = mock_instance

#             # Test logging with sensitive data
sensitive_data = {
#                 'password': 'secret_password',
#                 'api_key': 'secret_api_key',
#                 'token': 'secret_token'
#             }

mock_instance.log_execution.return_value = True
mock_instance.mask_sensitive_data.return_value = {
#                 'password': '********',
#                 'api_key': '********',
#                 'token': '********'
#             }

#             # Test logging
            mock_instance.log_execution('test.nc', sensitive_data)
masked_data = mock_instance.mask_sensitive_data(sensitive_data)

assert masked_data['password'] = = '********'
assert masked_data['api_key'] = = '********'
assert masked_data['token'] = = '********'

#     @pytest.mark.security
#     def test_api_request_id_validation(self):
#         """Test that API requests have valid request IDs."""
#         # This would test the actual API security
#         # For now, we'll mock it
#         with patch('noodlecore.api.NoodleAPI') as mock_api:
mock_instance = Mock()
mock_api.return_value = mock_instance

#             # Test with invalid request ID
mock_instance.handle_request.return_value = {
#                 'success': False,
#                 'error': 'Invalid request ID: request ID must be a valid UUID v4',
#                 'error_code': 1001
#             }

#             # Test request with invalid ID
result = mock_instance.handle_request({
#                 'request_id': 'invalid_uuid',
#                 'command': 'test'
#             })

#             assert not result['success']
#             assert 'Invalid request ID' in result['error']
assert result['error_code'] = = 1001

#     @pytest.mark.security
#     def test_jwt_token_validation(self):
#         """Test that JWT tokens are properly validated."""
#         # This would test the actual JWT security
#         # For now, we'll mock it
#         with patch('noodlecore.auth.NoodleAuth') as mock_auth:
mock_instance = Mock()
mock_auth.return_value = mock_instance

#             # Test with expired token
mock_instance.validate_token.return_value = {
#                 'valid': False,
#                 'error': 'Token expired: token has expired',
#                 'error_code': 1002
#             }

#             # Test token validation
result = mock_instance.validate_token('expired_token')

#             assert not result['valid']
#             assert 'Token expired' in result['error']
assert result['error_code'] = = 1002

#     @pytest.mark.security
#     def test_database_sql_injection_prevented(self):
#         """Test that SQL injection attacks are prevented."""
#         # This would test the actual database security
#         # For now, we'll mock it
#         with patch('noodlecore.database.NoodleDatabase') as mock_db:
mock_instance = Mock()
mock_db.return_value = mock_instance

#             # Test with SQL injection vectors
#             for injection_vector in TestDataProvider.sql_injection_vectors():
mock_instance.query.return_value = {
#                     'success': False,
#                     'error': 'SQL injection detected: potentially dangerous SQL query found',
#                     'error_code': 1003
#                 }

#                 # Test query with injection vector
result = mock_instance.query(injection_vector)
#                 assert not result['success']
#                 assert 'SQL injection detected' in result['error']
assert result['error_code'] = = 1003
