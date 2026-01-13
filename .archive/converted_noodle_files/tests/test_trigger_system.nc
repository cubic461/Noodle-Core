# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Tests for AI Trigger System

# This module contains tests for the AI trigger system components,
# including trigger system, intelligent scheduler, and configuration manager.
# """

import pytest
import time
import json
import uuid
import unittest.mock.Mock,
import typing.Dict,

# Import trigger system components
import noodlecore.self_improvement.trigger_system.(
#     TriggerSystem, TriggerType, TriggerPriority, TriggerStatus,
#     TriggerConfig, TriggerCondition, TriggerSchedule, TriggerExecution,
#     get_trigger_system
# )
import noodlecore.self_improvement.intelligent_scheduler.(
#     IntelligentScheduler, SchedulingStrategy, SystemLoadLevel,
#     get_intelligent_scheduler
# )
import noodlecore.self_improvement.trigger_config_manager.(
#     TriggerConfigManager, ConfigChangeType, ConfigValidationLevel,
#     get_trigger_config_manager
# )


class TestTriggerSystem
    #     """Test class for trigger system."""

    #     def setup_method(self):
    #         """Setup method for pytest fixtures."""
    #         # Create trigger system
    self.trigger_system = get_trigger_system()

    #         # Create intelligent scheduler
    self.scheduler = get_intelligent_scheduler(self.trigger_system)

    #         # Create configuration manager
    self.config_manager = get_trigger_config_manager()

    #     def teardown_method(self):
    #         """Teardown method for pytest fixtures."""
    #         # Deactivate components
    #         if self.trigger_system:
                self.trigger_system.deactivate()

    #         if self.scheduler:
                self.scheduler.deactivate()


class TestTriggerConfig
    #     """Test class for trigger configuration."""

    #     def create_performance_trigger_config(self) -> Dict[str, Any]:
    #         """Create a performance degradation trigger configuration."""
    #         return {
    #             'trigger_id': 'test_performance_trigger',
    #             'name': 'Test Performance Trigger',
    #             'description': 'Test trigger for performance degradation',
    #             'trigger_type': 'performance_degradation',
    #             'priority': 'high',
    #             'enabled': True,
    #             'conditions': [{
    #                 'metric_name': 'execution_time',
    #                 'operator': '>',
    #                 'threshold_value': 500.0,
    #                 'duration_seconds': 60.0
    #             }],
    #             'target_components': ['compiler', 'optimizer'],
    #             'cooldown_period_seconds': 300.0,
    #             'timeout_seconds': 60.0,
    #             'retry_count': 3,
    #             'metadata': {},
                'created_at': time.time(),
                'updated_at': time.time(),
    #             'last_executed': None,
    #             'execution_count': 0,
    #             'success_count': 0,
    #             'failure_count': 0
    #         }

    #     def create_time_based_trigger_config(self) -> Dict[str, Any]:
    #         """Create a time-based trigger configuration."""
    #         return {
    #             'trigger_id': 'test_time_trigger',
    #             'name': 'Test Time Trigger',
    #             'description': 'Test trigger for time-based execution',
    #             'trigger_type': 'time_based',
    #             'priority': 'medium',
    #             'enabled': True,
    #             'schedule': {
    #                 'schedule_type': 'recurring',
    #                 'interval_seconds': 3600.0,  # 1 hour
    #                 'timezone': 'UTC'
    #             },
    #             'target_components': ['runtime'],
    #             'cooldown_period_seconds': 1800.0,  # 30 minutes
    #             'timeout_seconds': 300.0,
    #             'retry_count': 2,
    #             'metadata': {},
                'created_at': time.time(),
                'updated_at': time.time(),
    #             'last_executed': None,
    #             'execution_count': 0,
    #             'success_count': 0,
    #             'failure_count': 0
    #         }

    #     def create_manual_trigger_config(self) -> Dict[str, Any]:
    #         """Create a manual trigger configuration."""
    #         return {
    #             'trigger_id': 'test_manual_trigger',
    #             'name': 'Test Manual Trigger',
    #             'description': 'Test trigger for manual execution',
    #             'trigger_type': 'manual',
    #             'priority': 'medium',
    #             'enabled': True,
    #             'target_components': ['optimizer'],
    #             'cooldown_period_seconds': 0.0,
    #             'timeout_seconds': 120.0,
    #             'retry_count': 1,
    #             'metadata': {},
                'created_at': time.time(),
                'updated_at': time.time(),
    #             'last_executed': None,
    #             'execution_count': 0,
    #             'success_count': 0,
    #             'failure_count': 0
    #         }

    #     def create_threshold_trigger_config(self) -> Dict[str, Any]:
    #         """Create a threshold-based trigger configuration."""
    #         return {
    #             'trigger_id': 'test_threshold_trigger',
    #             'name': 'Test Threshold Trigger',
    #             'description': 'Test trigger for resource thresholds',
    #             'trigger_type': 'threshold_based',
    #             'priority': 'critical',
    #             'enabled': True,
    #             'conditions': [{
    #                 'metric_name': 'memory_usage',
    #                 'operator': '>',
    #                 'threshold_value': 80.0
    #             }],
    #             'target_components': ['memory_manager'],
    #             'cooldown_period_seconds': 600.0,  # 10 minutes
    #             'timeout_seconds': 60.0,
    #             'retry_count': 3,
    #             'metadata': {},
                'created_at': time.time(),
                'updated_at': time.time(),
    #             'last_executed': None,
    #             'execution_count': 0,
    #             'success_count': 0,
    #             'failure_count': 0
    #         }


# @pytest.fixture
function trigger_system()
    #     """Create a trigger system instance for testing."""
    system = TriggerSystem()
    #     return system


# @pytest.fixture
function trigger_config()
    #     """Create a trigger configuration manager instance for testing."""
    manager = TriggerConfigManager()
    #     return manager


class TestTriggerSystemCreation
    #     """Test class for trigger system creation."""

    #     def test_trigger_system_creation(self, trigger_system):
    #         """Test trigger system creation."""
    #         assert trigger_system is not None
    assert trigger_system.triggers = = {}
    assert trigger_system.execution_history = = []
    assert trigger_system._running = = False

    #     def test_trigger_addition(self, trigger_system, trigger_config):
    #         """Test adding a trigger to the system."""
    #         # Add trigger
    success = trigger_system.add_trigger(trigger_config)
    #         assert success is True

    #         # Verify trigger was added
    #         assert trigger_config.trigger_id in trigger_system.triggers
    assert trigger_system.trigger_configs[trigger_config.trigger_id] = = trigger_config

    #     def test_trigger_removal(self, trigger_system, trigger_id):
    #         """Test removing a trigger from the system."""
    #         # Get trigger before removal
    trigger_before = trigger_system.get_trigger(trigger_id)
    #         assert trigger_before is not None

    #         # Remove trigger
    success = trigger_system.remove_trigger(trigger_id)
    #         assert success is True

    #         # Verify trigger was removed
    trigger_after = trigger_system.get_trigger(trigger_id)
    #         assert trigger_after is None

    #     def test_trigger_execution(self, trigger_system, trigger_id, context=None):
    #         """Test trigger execution."""
    #         # Execute trigger
    execution = trigger_system.execute_manual_trigger(trigger_id, context)

    #         # Verify execution
    #         assert execution is not None
    assert execution.trigger_id = = trigger_id
    assert execution.status = = TriggerStatus.ACTIVE
    #         assert execution.start_time > 0
    #         assert execution.end_time > execution.start_time

    #         # Verify trigger was updated
    trigger = trigger_system.get_trigger(trigger_id)
    #         assert trigger.last_executed is not None
    #         assert trigger.execution_count > 0


class TestTriggerSystemActivation
    #     """Test class for trigger system activation."""

    #     def test_trigger_system_activation(self, trigger_system):
    #         """Test trigger system activation."""
    #         # Add a trigger
    trigger_config = TestTriggerConfig().create_performance_trigger_config()
            trigger_system.add_trigger(trigger_config)

    #         # Activate system
    success = trigger_system.activate()
    #         assert success is True
    #         assert trigger_system._running is True

    #         # Verify trigger is active
    trigger = trigger_system.get_trigger(trigger_config.trigger_id)
    assert trigger.status = = TriggerStatus.ACTIVE

    #     def test_trigger_system_deactivation(self, trigger_system):
    #         """Test trigger system deactivation."""
    #         # Activate system
    trigger_config = TestTriggerConfig().create_performance_trigger_config()
            trigger_system.add_trigger(trigger_config)
            trigger_system.activate()

    #         # Deactivate system
    success = trigger_system.deactivate()
    #         assert success is True
    #         assert trigger_system._running is False

    #         # Verify trigger is inactive
    trigger = trigger_system.get_trigger(trigger_config.trigger_id)
    assert trigger.status = = TriggerStatus.INACTIVE


class TestTriggerSystemStatus
    #     """Test class for trigger system status."""

    #     def test_trigger_system_status(self, trigger_system):
    #         """Test trigger system status."""
    #         # Get status
    status = trigger_system.get_trigger_status()

    #         # Verify status structure
    #         assert 'system_running' in status
    #         assert 'total_triggers' in status
    #         assert 'active_triggers' in status
    #         assert 'triggers' in status

    #     def test_trigger_system_execution_history(self, trigger_system):
    #         """Test trigger system execution history."""
    #         # Add a trigger
    trigger_config = TestTriggerConfig().create_performance_trigger_config()
            trigger_system.add_trigger(trigger_config)

    #         # Execute trigger
    context = {'test': True}
    execution = trigger_system.execute_manual_trigger(trigger_config.trigger_id, context)

    #         # Get execution history
    history = trigger_system.get_execution_history(limit=10)

    #         # Verify execution history
            assert len(history) > 0
    assert history[0].execution_id = = execution.execution_id
    assert history[0].trigger_id = = trigger_config.trigger_id


class TestIntelligentScheduler
    #     """Test class for intelligent scheduler."""

    #     def test_scheduler_creation(self, scheduler, trigger_system):
    #         """Test intelligent scheduler creation."""
    #         assert scheduler is not None
    assert scheduler.trigger_system = = trigger_system
    assert scheduler._running = = False

    #     def test_scheduler_activation(self, scheduler):
    #         """Test intelligent scheduler activation."""
    #         # Activate scheduler
    success = scheduler.activate()
    #         assert success is True
    #         assert scheduler._running is True

    #     def test_scheduler_deactivation(self, scheduler):
    #         """Test intelligent scheduler deactivation."""
    #         # Activate scheduler
            scheduler.activate()

    #         # Deactivate scheduler
    success = scheduler.deactivate()
    #         assert success is True
    #         assert scheduler._running is False

    #     def test_scheduler_status(self, scheduler):
    #         """Test intelligent scheduler status."""
    #         # Get status
    status = scheduler.get_scheduling_status()

    #         # Verify status structure
    #         assert 'active' in status
    #         assert 'current_load' in status
    #         assert 'active_schedules' in status


class TestTriggerConfigManager
    #     """Test class for trigger configuration manager."""

    #     def test_config_manager_creation(self, config_manager):
    #         """Test configuration manager creation."""
    #         assert config_manager is not None
    assert config_manager.triggers = = {}
    assert config_manager.change_history = = []
    assert config_manager.pending_changes = = []

    #     def test_config_addition(self, config_manager, trigger_config):
    #         """Test adding a trigger configuration."""
    #         # Add trigger
    validation_result = config_manager.add_trigger(
    trigger_config, user_id = 'test', reason='Test addition'
    #         )

    #         # Verify validation result
    #         assert validation_result.valid is True
    #         assert trigger_config.trigger_id in config_manager.triggers

    #     def test_config_update(self, config_manager, trigger_id, trigger_config):
    #         """Test updating a trigger configuration."""
    #         # Update trigger
    validation_result = config_manager.update_trigger(
    trigger_id, trigger_config, user_id = 'test', reason='Test update'
    #         )

    #         # Verify validation result
    #         assert validation_result.valid is True
    assert config_manager.triggers[trigger_id] = = trigger_config

    #     def test_config_removal(self, config_manager, trigger_id):
    #         """Test removing a trigger configuration."""
    #         # Remove trigger
    validation_result = config_manager.remove_trigger(
    trigger_id, user_id = 'test', reason='Test removal'
    #         )

    #         # Verify validation result
    #         assert validation_result.valid is True
    #         assert trigger_id not in config_manager.triggers

    #     def test_config_validation(self, config_manager):
    #         """Test configuration validation."""
    #         # Create invalid trigger config
    invalid_config = {
    #             'trigger_id': '',  # Missing required field
    #             'name': 'Test Invalid Trigger',
    #             'description': 'Test invalid trigger',
    #             'trigger_type': 'invalid_type',  # Invalid trigger type
    #             'priority': 'invalid_priority',  # Invalid priority
    #             'enabled': True,
    #             'target_components': [],  # Missing required field
                'created_at': time.time(),
                'updated_at': time.time()
    #         }

    #         # Validate invalid config
    validation_result = config_manager.validate_trigger_config(
    invalid_config, validation_level = ConfigValidationLevel.STRICT
    #         )

    #         # Verify validation result
    #         assert validation_result.valid is False
            assert len(validation_result.errors) > 0

    #         # Create valid trigger config
    valid_config = TestTriggerConfig().create_performance_trigger_config()

    #         # Validate valid config
    validation_result = config_manager.validate_trigger_config(
    valid_config, validation_level = ConfigValidationLevel.STRICT
    #         )

    #         # Verify validation result
    #         assert validation_result.valid is True
    assert len(validation_result.errors) = = 0


class TestTriggerSystemIntegration
    #     """Test class for trigger system integration."""

    #     def test_integration_workflow(self, trigger_system, scheduler, config_manager):
    #         """Test integration workflow between components."""
    #         # Create a trigger
    trigger_config = TestTriggerConfig().create_performance_trigger_config()
            config_manager.add_trigger(trigger_config)

    #         # Activate system
            trigger_system.activate()
            scheduler.activate()

    #         # Verify integration
    #         assert trigger_system._running is True
    #         assert scheduler._running is True
            assert len(trigger_system.triggers) > 0
            assert len(config_manager.triggers) > 0

    #         # Execute trigger
    context = {'test': True}
    execution = trigger_system.execute_manual_trigger(trigger_config.trigger_id, context)

    #         # Verify execution
    #         assert execution is not None
    assert execution.status = = TriggerStatus.ACTIVE

    #         # Deactivate system
            trigger_system.deactivate()
            scheduler.deactivate()

    #         # Verify deactivation
    #         assert trigger_system._running is False
    #         assert scheduler._running is False


# Test cases
class TestTriggerSystemBasic
    #     """Basic tests for trigger system."""

    #     def test_trigger_system_initialization(self, trigger_system):
    #         """Test trigger system initialization."""
            TestTriggerSystemCreation().test_trigger_system_creation(trigger_system)

    #     def test_trigger_configuration_management(self, trigger_system, config_manager):
    #         """Test trigger configuration management."""
            TestTriggerConfigManager().test_config_manager_creation(config_manager)

    #         # Test adding triggers
    trigger_config = TestTriggerConfig().create_performance_trigger_config()
            TestTriggerConfigManager().test_config_addition(config_manager, trigger_config)

    #         # Test updating triggers
            TestTriggerConfigManager().test_config_update(
    #             config_manager, trigger_config.trigger_id, trigger_config
    #         )

    #         # Test removing triggers
            TestTriggerConfigManager().test_config_removal(config_manager, trigger_config.trigger_id)

    #         # Test validation
            TestTriggerConfigManager().test_config_validation(config_manager)

    #     def test_trigger_system_lifecycle(self, trigger_system):
    #         """Test trigger system lifecycle."""
            TestTriggerSystemActivation().test_trigger_system_activation(trigger_system)
            TestTriggerSystemStatus().test_trigger_system_status(trigger_system)
            TestTriggerSystemStatus().test_trigger_system_execution_history(trigger_system)
            TestTriggerSystemActivation().test_trigger_system_deactivation(trigger_system)


class TestIntelligentSchedulerBasic
    #     """Basic tests for intelligent scheduler."""

    #     def test_scheduler_initialization(self, scheduler, trigger_system):
    #         """Test intelligent scheduler initialization."""
            TestIntelligentScheduler().test_scheduler_creation(scheduler, trigger_system)

    #     def test_scheduler_lifecycle(self, scheduler):
    #         """Test intelligent scheduler lifecycle."""
            TestIntelligentScheduler().test_scheduler_activation(scheduler)
            TestIntelligentScheduler().test_scheduler_deactivation(scheduler)
            TestIntelligentScheduler().test_scheduler_status(scheduler)


class TestTriggerConfigManagerBasic
    #     """Basic tests for trigger configuration manager."""

    #     def test_config_manager_initialization(self, config_manager):
    #         """Test configuration manager initialization."""
            TestTriggerConfigManager().test_config_manager_creation(config_manager)

    #     def test_config_manager_operations(self, config_manager):
    #         """Test configuration manager operations."""
            TestTriggerConfigManager().test_config_manager_creation(config_manager)

    #         # Test adding triggers
    trigger_config = TestTriggerConfig().create_performance_trigger_config()
            TestTriggerConfigManager().test_config_addition(config_manager, trigger_config)

    #         # Test updating triggers
            TestTriggerConfigManager().test_config_update(
    #             config_manager, trigger_config.trigger_id, trigger_config
    #         )

    #         # Test removing triggers
            TestTriggerConfigManager().test_config_removal(config_manager, trigger_config.trigger_id)

    #         # Test validation
            TestTriggerConfigManager().test_config_validation(config_manager)


class TestTriggerSystemIntegrationBasic
    #     """Basic tests for trigger system integration."""

    #     def test_integration_initialization(self, trigger_system, scheduler, config_manager):
    #         """Test integration initialization."""
            TestTriggerSystemCreation().test_trigger_system_creation(trigger_system)
            TestIntelligentScheduler().test_scheduler_initialization(scheduler, trigger_system)
            TestTriggerConfigManager().test_config_manager_initialization(config_manager)

    #     def test_integration_workflow(self, trigger_system, scheduler, config_manager):
    #         """Test integration workflow."""
            TestTriggerSystemIntegration().test_integration_workflow(
    #             trigger_system, scheduler, config_manager
    #         )


# Pytest test functions
function test_trigger_system_initialization()
    #     """Test trigger system initialization."""
    trigger_system = trigger_system()
    test_instance = TestTriggerSystemBasic()
        test_instance.test_trigger_system_initialization(trigger_system)


function test_trigger_configuration_management()
    #     """Test trigger configuration management."""
    trigger_system = trigger_system()
    config_manager = trigger_config()
    test_instance = TestTriggerConfigManagerBasic()
        test_instance.test_trigger_configuration_management(trigger_system, config_manager)


function test_intelligent_scheduler()
    #     """Test intelligent scheduler."""
    trigger_system = trigger_system()
    scheduler = intelligent_scheduler(trigger_system)
    test_instance = TestIntelligentSchedulerBasic()
        test_instance.test_scheduler_initialization(scheduler, trigger_system)
        test_instance.test_scheduler_lifecycle(scheduler)


function test_trigger_config_manager()
    #     """Test trigger configuration manager."""
    trigger_system = trigger_system()
    config_manager = trigger_config()
    test_instance = TestTriggerConfigManagerBasic()
        test_instance.test_config_manager_initialization(config_manager)
        test_instance.test_config_manager_operations(trigger_system, config_manager)


function test_trigger_system_integration()
    #     """Test trigger system integration."""
    trigger_system = trigger_system()
    scheduler = intelligent_scheduler(trigger_system)
    config_manager = trigger_config()
    test_instance = TestTriggerSystemIntegrationBasic()
        test_instance.test_integration_initialization(trigger_system, scheduler, config_manager)
        test_instance.test_integration_workflow(trigger_system, scheduler, config_manager)


function test_trigger_system_full_lifecycle()
    #     """Test full trigger system lifecycle."""
    trigger_system = trigger_system()
    test_instance = TestTriggerSystemBasic()
        test_instance.test_trigger_system_lifecycle(trigger_system)


function test_trigger_system_with_mocks()
    #     """Test trigger system with mocked components."""
    #     # Create trigger system with mocked components
    #     with patch('noodlecore.self_improvement.trigger_system.get_self_improvement_manager') as mock_manager:
    #         with patch('noodlecore.self_improvement.trigger_system.get_performance_monitoring_system') as mock_monitoring:
    #             with patch('noodlecore.self_improvement.trigger_system.get_ai_decision_engine') as mock_ai_engine:
    trigger_system = TriggerSystem()

    #                 # Test trigger system with mocks
    test_instance = TestTriggerSystemBasic()
                    test_instance.test_trigger_system_initialization(trigger_system)

    #                 # Verify mocks were called
    #                 assert mock_manager.called
    #                 assert mock_monitoring.called
    #                 assert mock_ai_engine.called


function test_trigger_config_validation_levels()
    #     """Test trigger configuration validation levels."""
    trigger_system = trigger_system()
    config_manager = trigger_config()
    test_instance = TestTriggerConfigManager()

    #     # Test basic validation
    valid_config = TestTriggerConfig().create_performance_trigger_config()
    result = config_manager.validate_trigger_config(valid_config, ConfigValidationLevel.BASIC)
    #     assert result.valid is True
    assert len(result.errors) = = 0

    #     # Test strict validation
    result = config_manager.validate_trigger_config(valid_config, ConfigValidationLevel.STRICT)
    #     assert result.valid is True
    assert len(result.errors) = = 0

    #     # Test comprehensive validation
    result = config_manager.validate_trigger_config(valid_config, ConfigValidationLevel.COMPREHENSIVE)
    #     assert result.valid is True
    assert len(result.errors) = = 0


function test_trigger_execution_context()
    #     """Test trigger execution with different contexts."""
    trigger_system = trigger_system()
    trigger_config = TestTriggerConfig().create_manual_trigger_config()
        trigger_system.add_trigger(trigger_config)

    #     # Test execution with no context
    execution = trigger_system.execute_manual_trigger(trigger_config.trigger_id)
    #     assert execution is not None
    assert execution.status = = TriggerStatus.ACTIVE

    #     # Test execution with context
    context = {'test': True, 'custom_param': 'test_value'}
    execution = trigger_system.execute_manual_trigger(trigger_config.trigger_id, context)
    #     assert execution is not None
    assert execution.status = = TriggerStatus.ACTIVE
    assert execution.metadata = = context


function test_trigger_types()
    #     """Test different trigger types."""
    trigger_system = trigger_system()

    #     # Test performance trigger
    perf_config = TestTriggerConfig().create_performance_trigger_config()
        trigger_system.add_trigger(perf_config)
    #     assert perf_config.trigger_id in trigger_system.triggers

    #     # Test time-based trigger
    time_config = TestTriggerConfig().create_time_based_trigger_config()
        trigger_system.add_trigger(time_config)
    #     assert time_config.trigger_id in trigger_system.triggers

    #     # Test manual trigger
    manual_config = TestTriggerConfig().create_manual_trigger_config()
        trigger_system.add_trigger(manual_config)
    #     assert manual_config.trigger_id in trigger_system.triggers

    #     # Test threshold trigger
    threshold_config = TestTriggerConfig().create_threshold_trigger_config()
        trigger_system.add_trigger(threshold_config)
    #     assert threshold_config.trigger_id in trigger_system.triggers


function test_trigger_conditions()
    #     """Test trigger conditions."""
    trigger_system = trigger_system()

    #     # Test condition with different operators
    conditions = [
    #         {'metric_name': 'execution_time', 'operator': '>', 'threshold_value': 500.0},
    #         {'metric_name': 'memory_usage', 'operator': '<', 'threshold_value': 80.0},
    {'metric_name': 'cpu_usage', 'operator': '> = ', 'threshold_value': 90.0},
    {'metric_name': 'error_rate', 'operator': ' = =', 'threshold_value': 0.05},
    {'metric_name': 'error_rate', 'operator': '! = ', 'threshold_value': 0.1}
    #     ]

    #     for i, condition in enumerate(conditions):
    trigger_config = {
    #             'trigger_id': f'test_condition_trigger_{i}',
    #             'name': f'Test Condition Trigger {i}',
    #             'description': f'Test trigger with condition {condition}',
    #             'trigger_type': 'performance_degradation',
    #             'priority': 'medium',
    #             'enabled': True,
    #             'conditions': [condition],
    #             'target_components': ['test_component'],
                'created_at': time.time(),
                'updated_at': time.time()
    #         }

            trigger_system.add_trigger(trigger_config)
    #         assert trigger_config.trigger_id in trigger_system.triggers


function test_trigger_schedules()
    #     """Test trigger schedules."""
    trigger_system = trigger_system()

    #     # Test recurring schedule
    recurring_schedule = {
    #         'schedule_type': 'recurring',
    #         'interval_seconds': 3600.0,  # 1 hour
    #         'timezone': 'UTC'
    #     }

    #     # Test once schedule
    once_schedule = {
    #         'schedule_type': 'once',
    #         'start_time': '2024-01-01T00:00:00',
    #         'timezone': 'UTC'
    #     }

    #     # Test interval schedule
    interval_schedule = {
    #         'schedule_type': 'interval',
    #         'interval_seconds': 1800.0,  # 30 minutes
    #         'timezone': 'UTC'
    #     }

    #     # Test schedule with blackout periods
    schedule_with_blackout = {
    #         'schedule_type': 'recurring',
    #         'interval_seconds': 3600.0,
    #         'timezone': 'UTC',
    #         'blackout_periods': [
    #             {
    #                 'start': '2024-01-01T08:00:00',
    #                 'end': '2024-01-01T18:00:00'
    #             }
    #         ]
    #     }

    #     # Create triggers with schedules
    schedules = [recurring_schedule, once_schedule, interval_schedule, schedule_with_blackout]
    #     for i, schedule in enumerate(schedules):
    trigger_config = {
    #             'trigger_id': f'test_schedule_trigger_{i}',
    #             'name': f'Test Schedule Trigger {i}',
    #             'description': f'Test trigger with schedule {i}',
    #             'trigger_type': 'time_based',
    #             'priority': 'medium',
    #             'enabled': True,
    #             'schedule': schedule,
    #             'target_components': ['test_component'],
                'created_at': time.time(),
                'updated_at': time.time()
    #         }

            trigger_system.add_trigger(trigger_config)
    #         assert trigger_config.trigger_id in trigger_system.triggers


if __name__ == "__main__"
    #     # Run tests
        pytest.main([__file__])