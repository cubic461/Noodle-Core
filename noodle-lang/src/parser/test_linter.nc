# Converted from Python to NoodleCore
# Original file: src

# """
# Tests for the NoodleCore Linter Module
# --------------------------------------
# This module contains tests for the NoodleCore linter components.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import os
import tempfile
import unittest
import unittest.mock.Mock

import noodlecore.linter.(
#     NoodleLinter, LinterConfig, LinterResult, LinterMode,
#     SyntaxChecker, SemanticAnalyzer, ValidationRules, RuleSeverity,
#     LinterAPI, LinterAPIConfig, IntegrationMode, create_ide_linter, create_ai_guard_linter
# )
import noodlecore.compiler.parser_ast_nodes.ProgramNode


class TestLinterConfig(unittest.TestCase)
    #     """Test the LinterConfig class"""

    #     def test_default_config(self):""Test default configuration"""
    config = LinterConfig()

            self.assertEqual(config.mode, LinterMode.REAL_TIME)
            self.assertTrue(config.enable_syntax_check)
            self.assertTrue(config.enable_semantic_check)
            self.assertTrue(config.enable_validation_rules)
            self.assertTrue(config.enable_forbidden_structure_check)
            self.assertEqual(config.max_errors, 100)
            self.assertEqual(config.max_warnings, 50)
            self.assertEqual(config.timeout_ms, 5000)
            self.assertTrue(config.cache_enabled)
            self.assertFalse(config.strict_mode)
            self.assertEqual(config.custom_rules, [])
            self.assertEqual(config.disabled_rules, set())
            self.assertEqual(config.disabled_categories, set())

    #     def test_config_to_dict(self):
    #         """Test converting configuration to dictionary"""
    config = LinterConfig(
    mode = LinterMode.STRICT,
    max_errors = 50,
    strict_mode = True,
    disabled_rules = {"rule1", "rule2"},
    #         )

    config_dict = config.to_dict()

            self.assertEqual(config_dict["mode"], LinterMode.STRICT.value)
            self.assertEqual(config_dict["max_errors"], 50)
            self.assertTrue(config_dict["strict_mode"])
            self.assertIn("rule1", config_dict["disabled_rules"])
            self.assertIn("rule2", config_dict["disabled_rules"])


class TestSyntaxChecker(unittest.TestCase)
    #     """Test the SyntaxChecker class"""

    #     def setUp(self):""Set up test fixtures"""
    self.syntax_checker = SyntaxChecker()

    #     def test_check_empty_program(self):
    #         """Test checking an empty program"""
    program = ProgramNode()
    result = self.syntax_checker.check(program)

            self.assertTrue(result.success)
            self.assertEqual(len(result.errors), 0)
    #         # Should have one warning about empty program
            self.assertGreater(len(result.warnings), 0)

    #     def test_check_program_with_statements(self):
    #         """Test checking a program with statements"""
    program = ProgramNode()

    #         # Create a mock statement
    statement = Mock()
    statement.node_type = NodeType.ASSIGNMENT
    statement.get_children.return_value = []
            program.add_child(statement)

    result = self.syntax_checker.check(program)

    #         # Should not fail for a basic program
            self.assertTrue(result.success)

    #     def test_check_function_definition(self):
    #         """Test checking a function definition"""
    #         function_def = Mock()
    function_def.node_type = NodeType.FUNCTION_DEF
    function_def.name = "test_function"
    function_def.body = [Mock()]
    function_def.get_children.return_value = []

    result = self.syntax_checker._check_function_definition(function_def, LinterResult(), None)

    #         # Should not fail for a valid function
            self.assertEqual(len(result.errors), 0)

    #     def test_check_function_without_name(self):
    #         """Test checking a function without a name"""
    #         function_def = Mock()
    function_def.node_type = NodeType.FUNCTION_DEF
    function_def.name = None
    function_def.body = [Mock()]
    function_def.get_children.return_value = []

    result = self.syntax_checker._check_function_definition(function_def, LinterResult(), None)

    #         # Should fail for a function without a name
            self.assertGreater(len(result.errors), 0)

    #     def test_check_function_without_body(self):
    #         """Test checking a function without a body"""
    #         function_def = Mock()
    function_def.node_type = NodeType.FUNCTION_DEF
    function_def.name = "test_function"
    function_def.body = None
    function_def.get_children.return_value = []

    result = self.syntax_checker._check_function_definition(function_def, LinterResult(), None)

    #         # Should fail for a function without a body
            self.assertGreater(len(result.errors), 0)

    #     def test_check_source_code_forbidden_patterns(self):
    #         """Test checking source code for forbidden patterns"""
    #         source_code = "def my_function():\n    print('hello')"
    result = self.syntax_checker.check_source_code(source_code)

    #         # Should detect Python-style function definition
            self.assertGreater(len(result.errors), 0)

    #     def test_check_source_code_valid_patterns(self):
    #         """Test checking source code with valid patterns"""
    source_code = "function myFunction() {\n    print('hello');\n}"
    result = self.syntax_checker.check_source_code(source_code)

    #         # Should not fail for valid NoodleCore syntax
            self.assertEqual(len(result.errors), 0)


class TestSemanticAnalyzer(unittest.TestCase)
    #     """Test the SemanticAnalyzer class"""

    #     def setUp(self):""Set up test fixtures"""
    self.semantic_analyzer = SemanticAnalyzer()

    #     def test_analyze_empty_program(self):
    #         """Test analyzing an empty program"""
    program = ProgramNode()
    result = self.semantic_analyzer.analyze(program)

            self.assertTrue(result.success)
            self.assertEqual(len(result.errors), 0)

    #     def test_collect_function_declaration(self):
    #         """Test collecting a function declaration"""
    #         function_def = Mock()
    function_def.node_type = NodeType.FUNCTION_DEF
    function_def.name = "test_function"
    function_def.parameters = []
    function_def.return_type = None
    function_def.get_children.return_value = []

    position = Mock()
    position.line = 1
    position.column = 1
    function_def.position = position

    result = LinterResult()
            self.semantic_analyzer._collect_function_declaration(function_def, result, None)

    #         # Should not fail for a valid function
            self.assertEqual(len(result.errors), 0)

    #         # Function should be in symbol table
    symbol = self.semantic_analyzer.symbol_table.lookup("test_function")
            self.assertIsNotNone(symbol)

    #     def test_collect_variable_declaration(self):
    #         """Test collecting a variable declaration"""
    assignment = Mock()
    assignment.node_type = NodeType.ASSIGNMENT

    target = Mock()
    target.name = "test_variable"
    assignment.target = target

    value = Mock()
    value.node_type = NodeType.LITERAL
    value.value = 42
    assignment.value = value

    position = Mock()
    position.line = 1
    position.column = 1
    assignment.position = position

    result = LinterResult()
            self.semantic_analyzer._collect_variable_declaration(assignment, result, None)

    #         # Should not fail for a valid variable
            self.assertEqual(len(result.errors), 0)

    #         # Variable should be in symbol table
    symbol = self.semantic_analyzer.symbol_table.lookup("test_variable")
            self.assertIsNotNone(symbol)

    #     def test_validate_variable_usage_undeclared(self):
    #         """Test validating usage of an undeclared variable"""
    variable = Mock()
    variable.node_type = NodeType.VARIABLE
    variable.name = "undeclared_variable"

    position = Mock()
    position.line = 1
    position.column = 1
    variable.position = position

    result = LinterResult()
            self.semantic_analyzer._validate_variable_usage(variable, result, None)

    #         # Should fail for an undeclared variable
            self.assertGreater(len(result.errors), 0)

    #     def test_validate_function_call_undeclared(self):
    #         """Test validating a call to an undeclared function"""
    call = Mock()
    call.node_type = NodeType.CALL

    function = Mock()
    function.name = "undeclared_function"
    call.function = function

    call.arguments = []

    position = Mock()
    position.line = 1
    position.column = 1
    call.position = position

    result = LinterResult()
            self.semantic_analyzer._validate_function_call(call, result, None)

    #         # Should fail for an undeclared function
            self.assertGreater(len(result.errors), 0)

    #     def test_infer_type_literal(self):
    #         """Test inferring the type of a literal"""
    literal = Mock()
    literal.node_type = NodeType.LITERAL
    literal.literal_type = Mock()
    literal.literal_type.value = "NUMBER"
    literal.value = 42

    inferred_type = self.semantic_analyzer._infer_type(literal)

            self.assertIsNotNone(inferred_type)
            self.assertEqual(inferred_type.name, "int")

    #     def test_infer_type_variable(self):
    #         """Test inferring the type of a variable"""
    #         # First, add a variable to the symbol table
    symbol_info = Mock()
    symbol_info.type = Mock()
    symbol_info.type.name = "string"
            self.semantic_analyzer.symbol_table.insert("test_var", symbol_info)

    variable = Mock()
    variable.node_type = NodeType.VARIABLE
    variable.name = "test_var"

    inferred_type = self.semantic_analyzer._infer_type(variable)

            self.assertIsNotNone(inferred_type)
            self.assertEqual(inferred_type.name, "string")

    #     def test_is_type_compatible(self):
    #         """Test type compatibility checking"""
    int_type = Mock()
    int_type.name = "int"

    float_type = Mock()
    float_type.name = "float"

    string_type = Mock()
    string_type.name = "string"

    #         # int should be compatible with int
            self.assertTrue(self.semantic_analyzer._is_type_compatible(int_type, int_type))

    #         # float should be compatible with int
            self.assertTrue(self.semantic_analyzer._is_type_compatible(float_type, int_type))

    #         # int should not be compatible with string
            self.assertFalse(self.semantic_analyzer._is_type_compatible(int_type, string_type))


class TestValidationRules(unittest.TestCase)
    #     """Test the ValidationRules class"""

    #     def setUp(self):""Set up test fixtures"""
    self.validation_rules = ValidationRules()

    #     def test_validate_empty_program(self):
    #         """Test validating an empty program"""
    program = ProgramNode()
    result = self.validation_rules.validate(program)

            self.assertTrue(result.success)
            self.assertEqual(len(result.errors), 0)

    #     def test_check_naming_convention_valid(self):
    #         """Test checking naming convention with valid names"""
    variable = Mock()
    variable.node_type = NodeType.VARIABLE
    variable.name = "valid_variable_name"

    position = Mock()
    position.line = 1
    position.column = 1
    variable.position = position

    errors = self.validation_rules._check_naming_convention(variable, None)

    #         # Should not fail for a valid name
            self.assertEqual(len(errors), 0)

    #     def test_check_naming_convention_invalid(self):
    #         """Test checking naming convention with invalid names"""
    variable = Mock()
    variable.node_type = NodeType.VARIABLE
    variable.name = "invalidVariableName"

    position = Mock()
    position.line = 1
    position.column = 1
    variable.position = position

    errors = self.validation_rules._check_naming_convention(variable, None)

    #         # Should fail for an invalid name
            self.assertGreater(len(errors), 0)

    #     def test_check_magic_numbers(self):
    #         """Test checking for magic numbers"""
    literal = Mock()
    literal.node_type = NodeType.LITERAL
    literal.value = 42  # Magic number

    position = Mock()
    position.line = 1
    position.column = 1
    literal.position = position

    errors = self.validation_rules._check_magic_numbers(literal, None)

    #         # Should detect magic number
            self.assertGreater(len(errors), 0)

    #     def test_check_magic_numbers_common_values(self):
    #         """Test checking for magic numbers with common values"""
    literal = Mock()
    literal.node_type = NodeType.LITERAL
    literal.value = 1  # Common value

    position = Mock()
    position.line = 1
    position.column = 1
    literal.position = position

    errors = self.validation_rules._check_magic_numbers(literal, None)

    #         # Should not detect common values as magic numbers
            self.assertEqual(len(errors), 0)

    #     def test_configure_disabled_rules(self):
    #         """Test configuring disabled rules"""
            self.validation_rules.configure(
    disabled_rules = {"naming_convention"},
    disabled_categories = {"style"}
    #         )

            self.assertIn("naming_convention", self.validation_rules.disabled_rules)
            self.assertIn("style", self.validation_rules.disabled_categories)

    #     def test_validate_source_code(self):
    #         """Test validating source code directly"""
    source_code = "x = 42; // This is a comment\n" * 150  # Long line

    result = LinterResult()
            self.validation_rules._validate_source_code(source_code, result, None)

    #         # Should detect long lines
            self.assertGreater(len(result.warnings), 0)


class TestNoodleLinter(unittest.TestCase)
    #     """Test the NoodleLinter class"""

    #     def setUp(self):""Set up test fixtures"""
    self.linter = NoodleLinter()

    #     def test_lint_empty_source(self):
    #         """Test linting empty source code"""
    result = self.linter.lint_source("")

            self.assertTrue(result.success)
            self.assertEqual(len(result.errors), 0)

    #     def test_lint_source_with_config(self):
    #         """Test linting source code with configuration"""
    config = LinterConfig(
    mode = LinterMode.STRICT,
    max_errors = 10,
    strict_mode = True
    #         )

    self.linter.config = config
    result = self.linter.lint_source("")

            self.assertTrue(result.success)
            self.assertEqual(len(result.errors), 0)

    #     def test_lint_nonexistent_file(self):
    #         """Test linting a nonexistent file"""
    result = self.linter.lint_file("/nonexistent/file.nc")

            self.assertFalse(result.success)
            self.assertGreater(len(result.errors), 0)

    #     def test_get_statistics(self):
    #         """Test getting linter statistics"""
    stats = self.linter.get_statistics()

            self.assertIn("files_processed", stats)
            self.assertIn("total_errors", stats)
            self.assertIn("total_warnings", stats)
            self.assertIn("total_time_ms", stats)
            self.assertIn("config", stats)

    #     def test_clear_cache(self):
    #         """Test clearing the cache"""
            self.linter.clear_cache()

    #         # Should not raise an exception
            self.assertTrue(True)

    #     def test_reset_statistics(self):
    #         """Test resetting statistics"""
            self.linter.reset_statistics()

    stats = self.linter.get_statistics()
            self.assertEqual(stats["files_processed"], 0)
            self.assertEqual(stats["total_errors"], 0)
            self.assertEqual(stats["total_warnings"], 0)
            self.assertEqual(stats["total_time_ms"], 0)


class TestLinterAPI(unittest.TestCase)
    #     """Test the LinterAPI class"""

    #     def setUp(self):""Set up test fixtures"""
    self.api = LinterAPI()

    #     def test_process_unknown_request(self):
    #         """Test processing an unknown request"""
    response = self.api.process_request("unknown_request", {})

            self.assertFalse(response.success)
            self.assertIsNotNone(response.error_message)

    #     def test_process_lint_source_request(self):
    #         """Test processing a lint source request"""
    request_data = {
    #             "requestId": "test-request-id",
    "sourceCode": "x = 42;",
    #         }

    response = self.api.process_request("lint_source", request_data)

            self.assertTrue(response.success)
            self.assertIsNotNone(response.result)

    #     def test_process_lint_file_request(self):
    #         """Test processing a lint file request"""
    #         # Create a temporary file
    #         with tempfile.NamedTemporaryFile(mode='w', suffix='.nc', delete=False) as f:
    f.write("x = 42;")
    temp_file = f.name

    #         try:
    request_data = {
    #                 "requestId": "test-request-id",
    #                 "filePath": temp_file,
    #             }

    response = self.api.process_request("lint_file", request_data)

                self.assertTrue(response.success)
                self.assertIsNotNone(response.result)
    #         finally:
    #             # Clean up the temporary file
                os.unlink(temp_file)

    #     def test_process_get_statistics_request(self):
    #         """Test processing a get statistics request"""
    request_data = {
    #             "requestId": "test-request-id",
    #         }

    response = self.api.process_request("get_statistics", request_data)

            self.assertTrue(response.success)
            self.assertIsNotNone(response.result)
            self.assertIn("linter", response.result)
            self.assertIn("api", response.result)

    #     def test_process_clear_cache_request(self):
    #         """Test processing a clear cache request"""
    request_data = {
    #             "requestId": "test-request-id",
    #         }

    response = self.api.process_request("clear_cache", request_data)

            self.assertTrue(response.success)
            self.assertIsNotNone(response.result)

    #     def test_process_configure_request(self):
    #         """Test processing a configure request"""
    request_data = {
    #             "requestId": "test-request-id",
    #             "config": {
    #                 "enable_real_time": False,
    #                 "max_concurrent_requests": 5,
    #             },
    #         }

    response = self.api.process_request("configure", request_data)

            self.assertTrue(response.success)
            self.assertIsNotNone(response.result)

    #     def test_lint_source(self):
    #         """Test the lint_source convenience method"""
    response = self.api.lint_source("x = 42;")

            self.assertTrue(response.success)
            self.assertIsNotNone(response.result)

    #     def test_get_statistics(self):
    #         """Test the get_statistics convenience method"""
    response = self.api.get_statistics()

            self.assertTrue(response.success)
            self.assertIsNotNone(response.result)

    #     def test_clear_cache(self):
    #         """Test the clear_cache convenience method"""
    response = self.api.clear_cache()

            self.assertTrue(response.success)
            self.assertIsNotNone(response.result)

    #     def test_configure(self):
    #         """Test the configure convenience method"""
    config = {
    #             "enable_real_time": False,
    #             "max_concurrent_requests": 5,
    #         }

    response = self.api.configure(config)

            self.assertTrue(response.success)
            self.assertIsNotNone(response.result)

    #     def test_to_json(self):
    #         """Test converting a response to JSON"""
    response = LintResponse(
    request_id = "test-request-id",
    success = True,
    #         )

    json_str = self.api.to_json(response)

            self.assertIsInstance(json_str, str)
            self.assertIn("requestId", json_str)
            self.assertIn("success", json_str)

    #     def test_from_json(self):
    #         """Test converting JSON to a response"""
    json_str = '{"requestId": "test-request-id", "success": true}'

    response = self.api.from_json(json_str)

            self.assertEqual(response.request_id, "test-request-id")
            self.assertTrue(response.success)


class TestConvenienceFunctions(unittest.TestCase)
    #     """Test convenience functions"""

    #     def test_create_ide_linter(self):""Test creating an IDE linter"""
    api = create_ide_linter()

            self.assertIsInstance(api, LinterAPI)
            self.assertEqual(api.config.integration_mode, IntegrationMode.IDE)
            self.assertTrue(api.config.enable_real_time)

    #     def test_create_ai_guard_linter(self):
    #         """Test creating an AI guard linter"""
    api = create_ai_guard_linter()

            self.assertIsInstance(api, LinterAPI)
            self.assertEqual(api.config.integration_mode, IntegrationMode.AI_GUARD)
            self.assertTrue(api.config.enable_real_time)


if __name__ == "__main__"
        unittest.main()