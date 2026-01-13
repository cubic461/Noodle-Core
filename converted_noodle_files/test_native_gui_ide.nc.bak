# Converted from Python to NoodleCore
# Original file: noodle-core

# NoodleCore converted from Python
# """
# Comprehensive Test Suite for Native NoodleCore IDE

# This script tests all components of the Native GUI IDE including:
# - AI provider management
# - Code editor functionality
# - Project explorer
# - Terminal console
# - GUI framework
# - Integration between components
# """

import sys
import os
import unittest
import tempfile
import json
import logging
import pathlib.Path

# Add the NoodleCore source path
sys.path.insert(0, str(Path(__file__).parent / "src"))

# Setup logging for tests
logging.basicConfig(level = logging.WARNING)  # Reduce noise during testing

class TestAIManager(unittest.TestCase)
    #     """Test AI provider management functionality."""

    #     def setUp(self):
    #         from noodlecore.desktop.ide.native_ide import AIProviderManager
    self.ai_manager = AIProviderManager()

    #     def test_provider_initialization(self):
    #         """Test that AI providers are properly initialized."""
    providers = self.ai_manager.get_available_providers()
            self.assertGreater(len(providers), 0)

    #         provider_names = [p.name for p in providers]
            self.assertIn("openai", provider_names)
            self.assertIn("anthropic", provider_names)
            self.assertIn("openrouter", provider_names)
            self.assertIn("lm_studio", provider_names)
            self.assertIn("ollama", provider_names)

    #     def test_model_listing(self):
    #         """Test that models are correctly listed for each provider."""
    openai_models = self.ai_manager.get_provider_models("openai")
            self.assertIn("gpt-4", openai_models)
            self.assertIn("gpt-3.5-turbo", openai_models)

    ollama_models = self.ai_manager.get_provider_models("ollama")
            self.assertIn("llama3", ollama_models)

    #     def test_role_configuration(self):
    #         """Test that AI roles are properly configured."""
    roles = self.ai_manager.get_available_roles()
            self.assertGreater(len(roles), 0)

    #         role_names = [r.name for r in roles]
            self.assertIn("code_analyst", role_names)
            self.assertIn("code_generator", role_names)
            self.assertIn("debugger", role_names)
            self.assertIn("documentator", role_names)

    #     def test_provider_instance_creation(self):
    #         """Test creating AI provider instances."""
    instance = self.ai_manager.create_provider_instance("openai", "gpt-3.5-turbo")
            self.assertIsNotNone(instance)
            self.assertEqual(instance.provider_config.name, "openai")
            self.assertEqual(instance.selected_model, "gpt-3.5-turbo")
            self.assertTrue(instance.is_active)


class TestCodeEditor(unittest.TestCase)
    #     """Test code editor functionality."""

    #     def setUp(self):
    #         from noodlecore.desktop.ide.native_ide import NoodleCoreCodeEditor
    self.editor = NoodleCoreCodeEditor()

    #     def test_code_analysis(self):
    #         """Test code analysis functionality."""
    code = '''
define hello = "Hello World"
function greet(name):
#     return hello + ", " + name
# end

greet("Developer")
#         '''

analysis = self.editor.analyze_code(code)
        self.assertIn("issues", analysis)
        self.assertIn("metrics", analysis)
        self.assertIn("ai_analysis", analysis)

#         # Check that metrics are calculated
        self.assertGreater(analysis["metrics"]["lines_of_code"], 0)
        self.assertGreaterEqual(analysis["metrics"]["complexity"], 0)

#     def test_auto_completion(self):
#         """Test auto-completion functionality."""
#         code = "def "
position = (1, 5)
completions = self.editor.get_completions(code, position)

#         # Should find "define" and "function" completions
        self.assertGreater(len(completions), 0)

#         # Check for NoodleCore-specific keywords
#         completion_texts = [c["text"] for c in completions]
        self.assertIn("define", completion_texts)

#     def test_code_formatting(self):
#         """Test code formatting functionality."""
unformatted_code = '''
define test = 1
function func():
if True
return test
# end
# end
#         '''

formatted = self.editor.format_code(unformatted_code)
lines = formatted.split('\n')

#         # Should have proper indentation
#         for line in lines:
#             if line.strip() and not line.startswith('#'):
                self.assertTrue(line.startswith(' ') or line.startswith('def'))


class TestProjectExplorer(unittest.TestCase)
    #     """Test project explorer functionality."""

    #     def setUp(self):
    #         from noodlecore.desktop.ide.native_ide import ProjectExplorer
    self.explorer = ProjectExplorer()

    #         # Create a temporary test project
    self.test_project = tempfile.mkdtemp()
            self.create_test_files()

    #     def create_test_files(self):
    #         """Create test files for the project."""
    #         # Create test NoodleCore file
    nc_content = '''
define result = 42
function calculate():
#     return result * 2
# end
#         '''

#         with open(os.path.join(self.test_project, "main.nc"), 'w') as f:
            f.write(nc_content)

#         # Create test Python file
py_content = '''
function hello_world()
        print("Hello from Python!")
    #         '''

    #         with open(os.path.join(self.test_project, "hello.py"), 'w') as f:
                f.write(py_content)

    #     def test_project_loading(self):
    #         """Test loading a project."""
    success = self.explorer.open_project(self.test_project)
            self.assertTrue(success)
            self.assertIsNotNone(self.explorer.current_project)

    #     def test_file_icons(self):
    #         """Test file icon detection."""
    nc_icon = self.explorer.get_file_icon("main.nc")
            self.assertEqual(nc_icon, "🚀 NoodleCore")

    py_icon = self.explorer.get_file_icon("script.py")
            self.assertEqual(py_icon, "🐍 Python")

    #     def test_file_creation(self):
    #         """Test creating new files."""
    success = self.explorer.create_new_file("test.nc", "# New file")
            self.assertTrue(success)

    test_file_path = os.path.join(self.test_project, "test.nc")
            self.assertTrue(os.path.exists(test_file_path))

    #     def tearDown(self):
    #         # Clean up test files
    #         import shutil
    shutil.rmtree(self.test_project, ignore_errors = True)


class TestTerminalConsole(unittest.TestCase)
    #     """Test terminal console functionality."""

    #     def setUp(self):
    #         from noodlecore.desktop.ide.native_ide import TerminalConsole
    self.terminal = TerminalConsole()

    #     def test_noodle_commands(self):
    #         """Test NoodleCore-specific commands."""
    #         # Test noodle-help command
    result = self.terminal.execute_command("noodle-help")
            self.assertTrue(result["success"])
            self.assertIn("NoodleCore", result["output"])

    #     def test_system_commands(self):
    #         """Test system command execution."""
    #         # Test simple system command
    result = self.terminal.execute_command("echo 'Hello World'")
            self.assertTrue(result["success"])
            self.assertIn("Hello World", result["output"])

    #     def test_noodle_file_analysis(self):
    #         """Test analyzing NoodleCore files."""
    #         # Create test file
    #         with tempfile.NamedTemporaryFile(mode='w', suffix='.nc', delete=False) as f:
                f.write('''
define value = 100
function process():
#     return value + 50
# end
#             ''')
test_file = f.name

#         try:
result = self.terminal.execute_command(f"noodle-analyze {test_file}")
            self.assertTrue(result["success"])
            self.assertIn("Analyzing NoodleCore file", result["output"])
            self.assertIn("Analysis completed", result["output"])
#         finally:
            os.unlink(test_file)


class TestGUIFramework(unittest.TestCase)
    #     """Test GUI framework functionality."""

    #     def setUp(self):
    #         from noodlecore.desktop.ide.native_ide import NativeGUIFramework
    self.gui = NativeGUIFramework()

    #     def test_layout_initialization(self):
    #         """Test GUI layout initialization."""
    success = self.gui.initialize_layout(1400, 900)
            self.assertTrue(success)

    #         # Check that panel sizes are calculated
            self.assertIn("file_explorer", self.gui.panel_sizes)
            self.assertIn("code_editor", self.gui.panel_sizes)
            self.assertIn("ai_panel", self.gui.panel_sizes)
            self.assertIn("terminal", self.gui.panel_sizes)

    #     def test_panel_resizing(self):
    #         """Test panel resizing functionality."""
            self.gui.initialize_layout(1400, 900)

    success = self.gui.resize_panel("file_explorer", (400, 600))
            self.assertTrue(success)

    size = self.gui.panel_sizes["file_explorer"]
            self.assertEqual(size, (400, 600))

    #     def test_panel_information(self):
    #         """Test getting panel information."""
            self.gui.initialize_layout(1400, 900)

    info = self.gui.get_panel_info("file_explorer")
            self.assertIsNotNone(info)
            self.assertEqual(info["name"], "file_explorer")
            self.assertIn("title", info)
            self.assertIn("size", info)
            self.assertIn("visible", info)
            self.assertIn("position", info)

    #     def test_panel_toggling(self):
    #         """Test panel visibility toggling."""
            self.gui.initialize_layout(1400, 900)

    success = self.gui.toggle_panel("file_explorer")
            self.assertTrue(success)

    info = self.gui.get_panel_info("file_explorer")
            self.assertFalse(info["visible"])


class TestNativeIDEIntegration(unittest.TestCase)
    #     """Test integration of all IDE components."""

    #     def setUp(self):
    #         from noodlecore.desktop.ide.native_ide import NativeNoodleCoreIDE
    self.ide = NativeNoodleCoreIDE()

    #     def test_ide_initialization(self):
    #         """Test IDE initialization."""
    success = self.ide.initialize()
            self.assertTrue(success)

    #     def test_ai_provider_configuration(self):
    #         """Test configuring AI providers through IDE."""
    providers = self.ide.get_ai_providers()
            self.assertGreater(len(providers), 0)

    #         # Test configuring a provider
    success = self.ide.configure_ai_provider("openai", "gpt-3.5-turbo")
            self.assertTrue(success)

    #         # Check status
    status = self.ide.get_status()
            self.assertEqual(status["active_ai_provider"], "openai")

    #     def test_ai_request_execution(self):
    #         """Test executing AI requests."""
    #         # First configure a provider
            self.ide.configure_ai_provider("openai", "gpt-3.5-turbo")

    #         # Test executing a request
    response = self.ide.execute_ai_request("code_analyst", "Analyze this code", "Sample context")
            self.assertIsNotNone(response)
            self.assertTrue(response["success"])
            self.assertIn("content", response)

    #     def test_project_operations(self):
    #         """Test project-related operations."""
    #         # Create a temporary test project
    test_project = tempfile.mkdtemp()

    #         # Test opening project
    success = self.ide.open_project(test_project)
            self.assertTrue(success)

    #         # Test status
    status = self.ide.get_status()
            self.assertEqual(status["current_project"], test_project)

    #         # Clean up
    #         import shutil
    shutil.rmtree(test_project, ignore_errors = True)

    #     def test_file_operations(self):
    #         """Test file operations."""
    #         # Create a temporary test file
    #         with tempfile.NamedTemporaryFile(mode='w', suffix='.nc', delete=False) as f:
    f.write("define test = 42")
    test_file = f.name

    #         try:
    #             # Test opening file
    success = self.ide.open_file(test_file)
                self.assertTrue(success)

    #             # Test status
    status = self.ide.get_status()
                self.assertIn(test_file, status["open_files"])

    #             # Test closing file
    success = self.ide.close_file(test_file)
                self.assertTrue(success)

    #         finally:
                os.unlink(test_file)

    #     def test_terminal_operations(self):
    #         """Test terminal operations."""
    result = self.ide.get_terminal_output("echo 'Hello from terminal'")
            self.assertTrue(result["success"])
            self.assertIn("Hello from terminal", result["output"])

    #     def test_noodle_file_execution(self):
    #         """Test running NoodleCore files."""
    #         # Create a test NoodleCore file
    #         with tempfile.NamedTemporaryFile(mode='w', suffix='.nc', delete=False) as f:
                f.write('''
define value = 100
function process():
#     return value * 2
# end
#             ''')
test_file = f.name

#         try:
result = self.ide.run_noodle_file(test_file)
            self.assertTrue(result["success"])
            self.assertIn("Executing NoodleCore file", result["output"])
#         finally:
            os.unlink(test_file)


function run_comprehensive_tests()
    #     """Run all test suites."""
        print("🧪 Running Native NoodleCore IDE Test Suite")
    print(" = " * 60)

    #     # Create test suite

    test_suite = unittest.TestSuite()

    #     # Add test cases
    test_classes = [
    #         TestAIManager,
    #         TestCodeEditor,
    #         TestProjectExplorer,
    #         TestTerminalConsole,
    #         TestGUIFramework,
    #         TestNativeIDEIntegration
    #     ]

    #     for test_class in test_classes:
    tests = unittest.TestLoader().loadTestsFromTestCase(test_class)
            test_suite.addTests(tests)

    #     # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(test_suite)

    #     # Print summary
    print("\n" + " = " * 60)
        print("📊 TEST SUMMARY")
        print(f"Tests run: {result.testsRun}")
        print(f"Failures: {len(result.failures)}")
        print(f"Errors: {len(result.errors)}")
        print(f"Success rate: {((result.testsRun - len(result.failures) - len(result.errors)) / result.testsRun * 100):.1f}%")

    #     if result.wasSuccessful():
            print("🎉 All tests passed! Native NoodleCore IDE is ready to use.")
    #         return True
    #     else:
            print("❌ Some tests failed. Please check the output above.")
    #         return False


if __name__ == "__main__"
    #     try:
    success = run_comprehensive_tests()
    #         exit(0 if success else 1)
    #     except Exception as e:
            print(f"❌ Error running tests: {e}")
            exit(1)
