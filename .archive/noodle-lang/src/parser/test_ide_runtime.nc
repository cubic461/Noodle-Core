# Converted from Python to NoodleCore
# Original file: src

# """
# Tests for IDE Runtime Module
# ----------------------------
# Tests for the IDE runtime integration module.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import os
import time
import unittest
import unittest.mock.Mock

import src.noodlecore.ide.runtime.(
#     IDERuntime,
#     RuntimeConfig,
#     RuntimeAction,
#     RuntimeActionType,
#     RuntimeResult,
#     RuntimeError,
#     BufferManager,
#     ActionValidator,
#     ValidationPipeline,
#     RuntimeLogger,
#     get_runtime,
#     process_action,
# )


class TestRuntimeConfig(unittest.TestCase)
    #     """Test RuntimeConfig class"""

    #     def test_default_config(self):""Test default configuration"""
    config = RuntimeConfig()

            self.assertTrue(config.enable_syntax_validation)
            self.assertTrue(config.enable_semantic_validation)
            self.assertTrue(config.enable_ai_guard)
            self.assertTrue(config.enable_compliance_tracking)
            self.assertTrue(config.enable_incremental_validation)
            self.assertEqual(config.validation_timeout_ms, 5000)
            self.assertEqual(config.max_concurrent_validations, 5)
            self.assertEqual(config.cache_size, 100)
            self.assertTrue(config.auto_save_validation_results)
            self.assertEqual(config.log_level, "INFO")
            self.assertIsNone(config.cmdb_connection_string)
            self.assertIsNone(config.project_database_path)

    #     def test_config_to_dict(self):
    #         """Test configuration to dictionary conversion"""
    config = RuntimeConfig()
    config_dict = config.to_dict()

            self.assertIsInstance(config_dict, dict)
            self.assertTrue(config_dict["enable_syntax_validation"])
            self.assertEqual(config_dict["validation_timeout_ms"], 5000)


class TestRuntimeAction(unittest.TestCase)
    #     """Test RuntimeAction class"""

    #     def test_action_creation(self):""Test action creation"""
    action = RuntimeAction(
    action_type = RuntimeActionType.BUFFER_CHANGE,
    buffer_id = "test-buffer",
    file_path = "/test/file.nc",
    content = "func test() { return 42; }"
    #         )

            self.assertEqual(action.action_type, RuntimeActionType.BUFFER_CHANGE)
            self.assertEqual(action.buffer_id, "test-buffer")
            self.assertEqual(action.file_path, "/test/file.nc")
            self.assertEqual(action.content, "func test() { return 42; }")
            self.assertIsNotNone(action.action_id)
            self.assertIsInstance(action.timestamp, float)

    #     def test_action_to_dict(self):
    #         """Test action to dictionary conversion"""
    action = RuntimeAction(
    action_type = RuntimeActionType.BUFFER_CHANGE,
    buffer_id = "test-buffer",
    content = "func test() { return 42; }"
    #         )

    action_dict = action.to_dict()

            self.assertIsInstance(action_dict, dict)
            self.assertEqual(action_dict["actionType"], "buffer_change")
            self.assertEqual(action_dict["bufferId"], "test-buffer")
            self.assertEqual(action_dict["content"], "func test() { return 42; }")
            self.assertIn("actionId", action_dict)
            self.assertIn("timestamp", action_dict)


class TestRuntimeResult(unittest.TestCase)
    #     """Test RuntimeResult class"""

    #     def test_result_creation(self):""Test result creation"""
    result = RuntimeResult(
    action_id = "test-action",
    success = True
    #         )

            self.assertEqual(result.action_id, "test-action")
            self.assertTrue(result.success)
            self.assertIsNone(result.syntax_result)
            self.assertIsNone(result.linter_result)
            self.assertIsNone(result.ai_guard_result)
            self.assertIsNone(result.parse_result)
            self.assertIsNone(result.compliance_record)
            self.assertEqual(result.execution_time_ms, 0)
            self.assertIsNone(result.error_message)
            self.assertIsInstance(result.timestamp, float)

    #     def test_result_to_dict(self):
    #         """Test result to dictionary conversion"""
    result = RuntimeResult(
    action_id = "test-action",
    success = True,
    execution_time_ms = 100
    #         )

    result_dict = result.to_dict()

            self.assertIsInstance(result_dict, dict)
            self.assertEqual(result_dict["actionId"], "test-action")
            self.assertTrue(result_dict["success"])
            self.assertEqual(result_dict["executionTimeMs"], 100)
            self.assertIsNone(result_dict["errorMessage"])


class TestRuntimeError(unittest.TestCase)
    #     """Test RuntimeError class"""

    #     def test_error_creation(self):""Test error creation"""
    error = RuntimeError("Test error", 2001, {"detail": "test"})

            self.assertEqual(error.message, "Test error")
            self.assertEqual(error.code, 2001)
            self.assertEqual(error.details, {"detail": "test"})
            self.assertEqual(str(error), "RuntimeError[2001]: Test error")


class TestBufferManager(unittest.TestCase)
    #     """Test BufferManager class"""

    #     def setUp(self):""Set up test fixtures"""
    self.buffer_manager = BufferManager()

    #     def test_create_buffer(self):
    #         """Test buffer creation"""
    result = self.buffer_manager.create_buffer("test-buffer", "/test/file.nc")

            self.assertTrue(result)

    buffer_info = self.buffer_manager.get_buffer("test-buffer")
            self.assertIsNotNone(buffer_info)
            self.assertEqual(buffer_info["id"], "test-buffer")
            self.assertEqual(buffer_info["file_path"], "/test/file.nc")
            self.assertEqual(buffer_info["content"], "")
            self.assertFalse(buffer_info["is_noodlecore"])
            self.assertFalse(buffer_info["has_external_fragments"])
            self.assertEqual(buffer_info["ai_interventions"], [])
            self.assertEqual(buffer_info["validation_results"], [])

    #     def test_create_duplicate_buffer(self):
    #         """Test creating duplicate buffer"""
            self.buffer_manager.create_buffer("test-buffer")

    result = self.buffer_manager.create_buffer("test-buffer")

            self.assertFalse(result)

    #     def test_update_buffer(self):
    #         """Test buffer update"""
            self.buffer_manager.create_buffer("test-buffer")

    result = self.buffer_manager.update_buffer("test-buffer", "func test() { return 42; }")

            self.assertTrue(result)

    buffer_info = self.buffer_manager.get_buffer("test-buffer")
            self.assertEqual(buffer_info["content"], "func test() { return 42; }")
            self.assertTrue(buffer_info["is_noodlecore"])
            self.assertFalse(buffer_info["has_external_fragments"])

    #     def test_update_nonexistent_buffer(self):
    #         """Test updating nonexistent buffer"""
    result = self.buffer_manager.update_buffer("nonexistent", "content")

            self.assertFalse(result)

    #     def test_delete_buffer(self):
    #         """Test buffer deletion"""
            self.buffer_manager.create_buffer("test-buffer")

    result = self.buffer_manager.delete_buffer("test-buffer")

            self.assertTrue(result)
            self.assertIsNone(self.buffer_manager.get_buffer("test-buffer"))

    #     def test_delete_nonexistent_buffer(self):
    #         """Test deleting nonexistent buffer"""
    result = self.buffer_manager.delete_buffer("nonexistent")

            self.assertFalse(result)

    #     def test_add_ai_intervention(self):
    #         """Test adding AI intervention"""
            self.buffer_manager.create_buffer("test-buffer")

    intervention = {"type": "completion", "content": "test"}
    result = self.buffer_manager.add_ai_intervention("test-buffer", intervention)

            self.assertTrue(result)

    buffer_info = self.buffer_manager.get_buffer("test-buffer")
            self.assertEqual(len(buffer_info["ai_interventions"]), 1)
            self.assertEqual(buffer_info["ai_interventions"][0], intervention)

    #     def test_add_validation_result(self):
    #         """Test adding validation result"""
            self.buffer_manager.create_buffer("test-buffer")

    result = RuntimeResult(action_id="test-action", success=True)
    add_result = self.buffer_manager.add_validation_result("test-buffer", result)

            self.assertTrue(add_result)

    buffer_info = self.buffer_manager.get_buffer("test-buffer")
            self.assertEqual(len(buffer_info["validation_results"]), 1)
            self.assertEqual(buffer_info["validation_results"][0], result)

    #     def test_is_noodlecore_content(self):
    #         """Test NoodleCore content detection"""
    #         # Test with NoodleCore keyword
            self.assertTrue(self.buffer_manager._is_noodlecore_content("func test() { return 42; }"))

    #         # Test with NoodleCore file extension comment
            self.assertTrue(self.buffer_manager._is_noodlecore_content("// .nc file"))

    #         # Test with non-NoodleCore content
            self.assertFalse(self.buffer_manager._is_noodlecore_content("console.log('test');"))

    #     def test_has_external_fragments(self):
    #         """Test external fragment detection"""
    #         # Test with code block
            self.assertTrue(self.buffer_manager._has_external_fragments("```python\ncode\n```"))

    #         # Test with script tag
            self.assertTrue(self.buffer_manager._has_external_fragments("<script>code</script>"))

    #         # Test with import statement
            self.assertTrue(self.buffer_manager._has_external_fragments("import something"))

    #         # Test with plain NoodleCore code
            self.assertFalse(self.buffer_manager._has_external_fragments("func test() { return 42; }"))


class TestActionValidator(unittest.TestCase)
    #     """Test ActionValidator class"""

    #     def setUp(self):""Set up test fixtures"""
    self.config = RuntimeConfig()
    self.validator = ActionValidator(self.config)

    #     def test_validate_noodlecore_buffer_change(self):
    #         """Test validating NoodleCore buffer change"""
    action = RuntimeAction(
    action_type = RuntimeActionType.BUFFER_CHANGE,
    buffer_id = "test-buffer"
    #         )

    buffer_info = {
    #             "is_noodlecore": True,
                "content": "func test() { return 42; }"
    #         }

    result = self.validator.validate_action(action, buffer_info)

            self.assertTrue(result)

    #     def test_validate_non_noodlecore_buffer(self):
    #         """Test validating non-NoodleCore buffer"""
    action = RuntimeAction(
    action_type = RuntimeActionType.BUFFER_CHANGE,
    buffer_id = "test-buffer"
    #         )

    buffer_info = {
    #             "is_noodlecore": False,
                "content": "console.log('test');"
    #         }

    result = self.validator.validate_action(action, buffer_info)

            self.assertFalse(result)

    #     def test_validate_ai_intervention(self):
    #         """Test validating AI intervention"""
    action = RuntimeAction(
    action_type = RuntimeActionType.AI_INTERVENTION,
    buffer_id = "test-buffer"
    #         )

    buffer_info = {
    #             "is_noodlecore": True,
                "content": "func test() { return 42; }"
    #         }

    result = self.validator.validate_action(action, buffer_info)

            self.assertTrue(result)

    #     def test_validate_cursor_move(self):
            """Test validating cursor move (should be skipped)"""
    action = RuntimeAction(
    action_type = RuntimeActionType.CURSOR_MOVE,
    buffer_id = "test-buffer"
    #         )

    buffer_info = {
    #             "is_noodlecore": True,
                "content": "func test() { return 42; }"
    #         }

    result = self.validator.validate_action(action, buffer_info)

            self.assertFalse(result)


class TestRuntimeLogger(unittest.TestCase)
    #     """Test RuntimeLogger class"""

    #     def setUp(self):""Set up test fixtures"""
    self.config = RuntimeConfig()
    self.logger = RuntimeLogger(self.config)

    #     def test_log_action(self):
    #         """Test logging an action"""
    action = RuntimeAction(
    action_type = RuntimeActionType.BUFFER_CHANGE,
    buffer_id = "test-buffer"
    #         )

    result = RuntimeResult(action_id=action.action_id, success=True)

            self.logger.log_action(action, result)

    log_entries = self.logger.get_log_entries(1)
            self.assertEqual(len(log_entries), 1)
            self.assertEqual(log_entries[0]["action"]["actionId"], action.action_id)
            self.assertEqual(log_entries[0]["result"]["actionId"], action.action_id)

    #     def test_get_log_entries(self):
    #         """Test getting log entries"""
    action = RuntimeAction(
    action_type = RuntimeActionType.BUFFER_CHANGE,
    buffer_id = "test-buffer"
    #         )

    result = RuntimeResult(action_id=action.action_id, success=True)

    #         # Log multiple actions
    #         for i in range(5):
    action.action_id = f"test-action-{i}"
    result.action_id = action.action_id
                self.logger.log_action(action, result)

    #         # Get all entries
    all_entries = self.logger.get_log_entries()
            self.assertEqual(len(all_entries), 5)

    #         # Get limited entries
    limited_entries = self.logger.get_log_entries(3)
            self.assertEqual(len(limited_entries), 3)

    patch("builtins.open", create = True)
        patch("json.dump")
    #     def test_export_logs(self, mock_json_dump, mock_open):
    #         """Test exporting logs"""
    action = RuntimeAction(
    action_type = RuntimeActionType.BUFFER_CHANGE,
    buffer_id = "test-buffer"
    #         )

    result = RuntimeResult(action_id=action.action_id, success=True)
            self.logger.log_action(action, result)

            self.logger.export_logs("/test/export.json")

    mock_open.assert_called_once_with("/test/export.json", 'w', encoding = 'utf-8')
            mock_json_dump.assert_called_once()


class TestIDERuntime(unittest.TestCase)
    #     """Test IDERuntime class"""

    #     def setUp(self):""Set up test fixtures"""
    self.config = RuntimeConfig()
    self.runtime = IDERuntime(self.config)

    #     def tearDown(self):
    #         """Clean up after tests"""
            self.runtime.shutdown()

    #     def test_initialization(self):
    #         """Test runtime initialization"""
            self.assertEqual(self.runtime.status, RuntimeStatus.READY)
            self.assertIsNotNone(self.runtime.buffer_manager)
            self.assertIsNotNone(self.runtime.action_validator)
            self.assertIsNotNone(self.runtime.validation_pipeline)
            self.assertIsNotNone(self.runtime.runtime_logger)
            self.assertEqual(self.runtime.stats["total_actions"], 0)

    #     def test_register_buffer(self):
    #         """Test buffer registration"""
    result = self.runtime.register_buffer("test-buffer", "/test/file.nc")

            self.assertTrue(result)

    buffer_info = self.runtime.get_buffer_info("test-buffer")
            self.assertIsNotNone(buffer_info)
            self.assertEqual(buffer_info["id"], "test-buffer")
            self.assertEqual(buffer_info["file_path"], "/test/file.nc")

    #     def test_unregister_buffer(self):
    #         """Test buffer unregistration"""
            self.runtime.register_buffer("test-buffer")

    result = self.runtime.unregister_buffer("test-buffer")

            self.assertTrue(result)
            self.assertIsNone(self.runtime.get_buffer_info("test-buffer"))

    #     def test_process_action_success(self):
    #         """Test successful action processing"""
            self.runtime.register_buffer("test-buffer")

    action = RuntimeAction(
    action_type = RuntimeActionType.BUFFER_CHANGE,
    buffer_id = "test-buffer",
    content = "func test() { return 42; }"
    #         )

    #         with patch.object(self.runtime.validation_pipeline, 'validate') as mock_validate:
    mock_result = RuntimeResult(action_id=action.action_id, success=True)
    mock_validate.return_value = mock_result

    result = self.runtime.process_action(action)

                self.assertTrue(result.success)
                self.assertEqual(result.action_id, action.action_id)
                mock_validate.assert_called_once()

    #     def test_process_action_buffer_not_found(self):
    #         """Test processing action with nonexistent buffer"""
    action = RuntimeAction(
    action_type = RuntimeActionType.BUFFER_CHANGE,
    buffer_id = "nonexistent-buffer"
    #         )

    result = self.runtime.process_action(action)

            self.assertFalse(result.success)
            self.assertIn("not found", result.error_message)

    #     def test_get_buffer_validation_history(self):
    #         """Test getting buffer validation history"""
            self.runtime.register_buffer("test-buffer")

    #         # Process some actions
    #         for i in range(5):
    action = RuntimeAction(
    action_type = RuntimeActionType.BUFFER_CHANGE,
    buffer_id = "test-buffer",
    content = f"func test{i}() {{ return {i}; }}"
    #             )

    #             with patch.object(self.runtime.validation_pipeline, 'validate') as mock_validate:
    mock_result = RuntimeResult(action_id=action.action_id, success=True)
    mock_validate.return_value = mock_result
                    self.runtime.process_action(action)

    #         # Get validation history
    history = self.runtime.get_buffer_validation_history("test-buffer")
            self.assertEqual(len(history), 5)

    #         # Get limited history
    limited_history = self.runtime.get_buffer_validation_history("test-buffer", 3)
            self.assertEqual(len(limited_history), 3)

    #     def test_add_action_callback(self):
    #         """Test adding action callback"""
    callback = Mock()

            self.runtime.add_action_callback(callback)

            self.assertIn(callback, self.runtime._action_callbacks)

    #     def test_remove_action_callback(self):
    #         """Test removing action callback"""
    callback = Mock()

            self.runtime.add_action_callback(callback)
            self.runtime.remove_action_callback(callback)

            self.assertNotIn(callback, self.runtime._action_callbacks)

    #     def test_get_statistics(self):
    #         """Test getting runtime statistics"""
    stats = self.runtime.get_statistics()

            self.assertIsInstance(stats, dict)
            self.assertEqual(stats["status"], "ready")
            self.assertEqual(stats["total_actions"], 0)
            self.assertEqual(stats["validated_actions"], 0)
            self.assertEqual(stats["successful_validations"], 0)
            self.assertEqual(stats["failed_validations"], 0)
            self.assertEqual(stats["buffer_count"], 0)
            self.assertIn("config", stats)

        patch("os.path.join")
        patch.object(RuntimeLogger, 'export_logs')
    #     def test_shutdown(self, mock_export_logs, mock_join):
    #         """Test runtime shutdown"""
    mock_join.return_value = "/test/ide_runtime_logs.json"

            self.runtime.shutdown()

            self.assertEqual(self.runtime.status, RuntimeStatus.SHUTTING_DOWN)


class TestGlobalFunctions(unittest.TestCase)
    #     """Test global functions"""

    #     def test_get_runtime(self):""Test getting global runtime instance"""
    runtime1 = get_runtime()
    runtime2 = get_runtime()

            self.assertIs(runtime1, runtime2)

    #     def test_process_action(self):
    #         """Test global process_action function"""
    #         with patch('src.noodlecore.ide.runtime.get_runtime') as mock_get_runtime:
    mock_runtime = Mock()
    mock_result = RuntimeResult(action_id="test-action", success=True)
    mock_runtime.process_action.return_value = mock_result
    mock_get_runtime.return_value = mock_runtime

    result = process_action(
    action_type = RuntimeActionType.BUFFER_CHANGE,
    buffer_id = "test-buffer",
    content = "func test() { return 42; }"
    #             )

                self.assertTrue(result.success)
                mock_runtime.process_action.assert_called_once()


if __name__ == "__main__"
        unittest.main()