# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Trigger Configuration Management for NoodleCore AI Triggers

# This module provides comprehensive configuration management for triggers,
# including dynamic updates, validation, and safety checks.
# """

import os
import json
import logging
import time
import threading
import uuid
import hashlib
import typing.Any,
import dataclasses.dataclass,
import enum.Enum

# Import trigger system components
import .trigger_system.(
#     TriggerType, TriggerPriority, TriggerStatus, TriggerConfig,
#     TriggerCondition, TriggerSchedule, TriggerValidationError
# )

# Configure logging
logger = logging.getLogger(__name__)

# Environment variables
NOODLE_DEBUG = os.environ.get("NOODLE_DEBUG", "0") == "1"
NOODLE_CONFIG_AUTO_SAVE = os.environ.get("NOODLE_CONFIG_AUTO_SAVE", "1") == "1"
NOODLE_CONFIG_BACKUP_COUNT = int(os.environ.get("NOODLE_CONFIG_BACKUP_COUNT", "5"))
NOODLE_CONFIG_VALIDATION_STRICT = os.environ.get("NOODLE_CONFIG_VALIDATION_STRICT", "1") == "1"


class ConfigChangeType(Enum)
    #     """Types of configuration changes."""
    CREATE = "create"
    UPDATE = "update"
    DELETE = "delete"
    ENABLE = "enable"
    DISABLE = "disable"
    BULK_UPDATE = "bulk_update"


class ConfigValidationLevel(Enum)
    #     """Validation levels for configuration."""
    NONE = "none"
    BASIC = "basic"
    STRICT = "strict"
    COMPREHENSIVE = "comprehensive"


# @dataclass
class ConfigChange
    #     """Record of a configuration change."""
    #     change_id: str
    #     change_type: ConfigChangeType
    #     trigger_id: Optional[str]
    #     old_config: Optional[Dict[str, Any]]
    #     new_config: Optional[Dict[str, Any]]
    #     timestamp: float
    #     user_id: Optional[str]
    #     reason: Optional[str]
    #     validation_result: Optional[Dict[str, Any]]
    applied: bool = False
    error_message: Optional[str] = None


# @dataclass
class ConfigValidationResult
    #     """Result of configuration validation."""
    #     valid: bool
    #     errors: List[str]
    #     warnings: List[str]
    #     validation_level: ConfigValidationLevel
    checksum: Optional[str] = None
    metadata: Dict[str, Any] = None


class TriggerConfigManager
    #     """
    #     Configuration manager for AI trigger system.

    #     This class provides comprehensive configuration management including
    #     validation, safety checks, dynamic updates, and audit logging.
    #     """

    #     def __init__(self, config_path: str = "trigger_config.json"):
    #         """Initialize configuration manager."""
    #         if NOODLE_DEBUG:
                logger.setLevel(logging.DEBUG)

    self.config_path = config_path
    self.backup_path = f"{config_path}.backup"

    #         # Configuration storage
    self.triggers: Dict[str, TriggerConfig] = {}
    self.config_version = 1
    self.last_modified = 0.0
    self.config_checksum = ""

    #         # Change tracking
    self.change_history: List[ConfigChange] = []
    self.pending_changes: List[ConfigChange] = []

    #         # Validation settings
    #         self.validation_level = ConfigValidationLevel.STRICT if NOODLE_CONFIG_VALIDATION_STRICT else ConfigValidationLevel.BASIC

    #         # Threading
    self._lock = threading.RLock()
    self._auto_save_enabled = NOODLE_CONFIG_AUTO_SAVE

    #         # Load existing configuration
            self._load_configuration()

    #         logger.info(f"Trigger configuration manager initialized with {len(self.triggers)} triggers")

    #     def _load_configuration(self):
    #         """Load configuration from file."""
    #         try:
    #             if os.path.exists(self.config_path):
    #                 with open(self.config_path, 'r') as f:
    config_data = json.load(f)

    #                 # Load metadata
    self.config_version = config_data.get('version', 1)
    self.last_modified = config_data.get('last_modified', 0.0)
    self.config_checksum = config_data.get('checksum', '')

    #                 # Load triggers
    #                 for trigger_data in config_data.get('triggers', []):
    config = self._parse_trigger_config(trigger_data)
    #                     if config:
    self.triggers[config.trigger_id] = config

    #                 # Load change history
    #                 for change_data in config_data.get('change_history', []):
    change = self._parse_config_change(change_data)
    #                     if change:
                            self.change_history.append(change)

                    logger.info(f"Loaded configuration: {len(self.triggers)} triggers, {len(self.change_history)} changes")
    #             else:
    #                 logger.info("No existing configuration found, starting with empty config")
                    self._create_empty_config()

    #         except Exception as e:
                logger.error(f"Error loading configuration: {str(e)}")
                self._create_empty_config()

    #     def _create_empty_config(self):
    #         """Create empty configuration."""
    self.triggers = {}
    self.change_history = []
    self.config_version = 1
    self.last_modified = time.time()
    self.config_checksum = ""

    #     def _parse_trigger_config(self, trigger_data: Dict[str, Any]) -> Optional[TriggerConfig]:
    #         """Parse trigger configuration from dictionary."""
    #         try:
    #             # Validate required fields
    required_fields = ['trigger_id', 'name', 'trigger_type', 'priority']
    #             for field in required_fields:
    #                 if field not in trigger_data:
                        raise ValueError(f"Missing required field: {field}")

    #             # Parse basic fields
    trigger_id = trigger_data['trigger_id']
    name = trigger_data['name']
    description = trigger_data.get('description', '')
    trigger_type = TriggerType(trigger_data['trigger_type'])
    priority = TriggerPriority[trigger_data['priority'].upper()]
    enabled = trigger_data.get('enabled', True)

    #             # Parse conditions
    conditions = []
    #             for condition_data in trigger_data.get('conditions', []):
    condition = TriggerCondition(
    metric_name = condition_data['metric_name'],
    operator = condition_data['operator'],
    threshold_value = float(condition_data['threshold_value']),
    duration_seconds = condition_data.get('duration_seconds'),
    evaluation_window = condition_data.get('evaluation_window')
    #                 )
                    conditions.append(condition)

    #             # Parse schedule
    schedule = None
    #             if 'schedule' in trigger_data:
    schedule_data = trigger_data['schedule']
    #                 from datetime import datetime

    schedule = TriggerSchedule(
    schedule_type = ScheduleType(schedule_data['schedule_type']),
    #                     start_time=datetime.fromisoformat(schedule_data['start_time']) if schedule_data.get('start_time') else None,
    #                     end_time=datetime.fromisoformat(schedule_data['end_time']) if schedule_data.get('end_time') else None,
    interval_seconds = schedule_data.get('interval_seconds'),
    cron_expression = schedule_data.get('cron_expression'),
    timezone = schedule_data.get('timezone', 'UTC'),
    blackout_periods = schedule_data.get('blackout_periods', [])
    #                 )

                return TriggerConfig(
    trigger_id = trigger_id,
    name = name,
    description = description,
    trigger_type = trigger_type,
    priority = priority,
    enabled = enabled,
    conditions = conditions,
    schedule = schedule,
    target_components = trigger_data.get('target_components', []),
    max_executions_per_hour = trigger_data.get('max_executions_per_hour'),
    cooldown_period_seconds = trigger_data.get('cooldown_period_seconds'),
    timeout_seconds = trigger_data.get('timeout_seconds'),
    retry_count = trigger_data.get('retry_count', 3),
    metadata = trigger_data.get('metadata', {}),
    created_at = trigger_data.get('created_at', time.time()),
    updated_at = trigger_data.get('updated_at', time.time()),
    last_executed = trigger_data.get('last_executed'),
    execution_count = trigger_data.get('execution_count', 0),
    success_count = trigger_data.get('success_count', 0),
    failure_count = trigger_data.get('failure_count', 0)
    #             )

    #         except Exception as e:
                logger.error(f"Error parsing trigger config: {str(e)}")
    #             return None

    #     def _parse_config_change(self, change_data: Dict[str, Any]) -> Optional[ConfigChange]:
    #         """Parse configuration change from dictionary."""
    #         try:
    change_id = change_data['change_id']
    change_type = ConfigChangeType(change_data['change_type'])
    trigger_id = change_data.get('trigger_id')
    old_config = change_data.get('old_config')
    new_config = change_data.get('new_config')
    timestamp = change_data['timestamp']
    user_id = change_data.get('user_id')
    reason = change_data.get('reason')
    validation_result = change_data.get('validation_result')
    applied = change_data.get('applied', False)
    error_message = change_data.get('error_message')

                return ConfigChange(
    change_id = change_id,
    change_type = change_type,
    trigger_id = trigger_id,
    old_config = old_config,
    new_config = new_config,
    timestamp = timestamp,
    user_id = user_id,
    reason = reason,
    validation_result = validation_result,
    applied = applied,
    error_message = error_message
    #             )

    #         except Exception as e:
                logger.error(f"Error parsing config change: {str(e)}")
    #             return None

    #     def validate_trigger_config(self, config: Union[TriggerConfig, Dict[str, Any]],
    validation_level: ConfigValidationLevel = math.subtract(None), > ConfigValidationResult:)
    #         """Validate trigger configuration."""
    #         if validation_level is None:
    validation_level = self.validation_level
    #         else:
    validation_level = validation_level

    errors = []
    warnings = []

    #         try:
    #             # Convert dict to TriggerConfig if needed
    #             if isinstance(config, dict):
    config_obj = self._parse_trigger_config(config)
    #                 if not config_obj:
                        return ConfigValidationResult(
    valid = False,
    errors = ["Failed to parse trigger configuration"],
    warnings = [],
    validation_level = validation_level
    #                     )
    config = config_obj

    #             # Basic validation
    #             if not config.trigger_id or not config.trigger_id.strip():
                    errors.append("Trigger ID is required and cannot be empty")

    #             if not config.name or not config.name.strip():
                    errors.append("Trigger name is required and cannot be empty")

    #             if not config.trigger_type:
                    errors.append("Trigger type is required")

    #             # Validate trigger type specific requirements
    type_errors, type_warnings = self._validate_trigger_type_specific(config, validation_level)
                errors.extend(type_errors)
                warnings.extend(type_warnings)

    #             # Validate target components
    #             if not config.target_components:
                    errors.append("Target components are required")
    #             else:
    #                 for component in config.target_components:
    #                     if not component or not component.strip():
                            warnings.append(f"Empty component name in target components: {component}")

    #             # Validate numeric values
    #             if config.cooldown_period_seconds is not None and config.cooldown_period_seconds < 0:
                    errors.append("Cooldown period cannot be negative")

    #             if config.timeout_seconds is not None and config.timeout_seconds <= 0:
                    errors.append("Timeout must be positive")

    #             if config.max_executions_per_hour is not None and config.max_executions_per_hour <= 0:
                    errors.append("Max executions per hour must be positive")

    #             if config.retry_count < 0:
                    errors.append("Retry count cannot be negative")

    #             # Advanced validation for strict mode
    #             if validation_level in [ConfigValidationLevel.STRICT, ConfigValidationLevel.COMPREHENSIVE]:
    advanced_errors, advanced_warnings = self._validate_advanced_requirements(config)
                    errors.extend(advanced_errors)
                    warnings.extend(advanced_warnings)

    #             # Calculate checksum
    config_dict = asdict(config)
    config_json = json.dumps(config_dict, sort_keys=True, default=str)
    checksum = hashlib.sha256(config_json.encode()).hexdigest()

                return ConfigValidationResult(
    valid = len(errors) == 0,
    errors = errors,
    warnings = warnings,
    validation_level = validation_level,
    checksum = checksum,
    metadata = {
                        'validation_timestamp': time.time(),
                        'config_size': len(config_json)
    #                 }
    #             )

    #         except Exception as e:
                return ConfigValidationResult(
    valid = False,
    errors = [f"Validation error: {str(e)}"],
    warnings = [],
    validation_level = validation_level
    #             )

    #     def _validate_trigger_type_specific(self, config: TriggerConfig,
    #                                    validation_level: ConfigValidationLevel) -> tuple[List[str], List[str]]:
    #         """Validate trigger type specific requirements."""
    errors = []
    warnings = []

    #         if config.trigger_type == TriggerType.PERFORMANCE_DEGRADATION:
    #             if not config.conditions:
                    errors.append("Performance degradation trigger requires conditions")
    #             else:
    valid_metrics = ['execution_time', 'memory_usage', 'cpu_usage', 'error_rate']
    #                 for condition in config.conditions:
    #                     if condition.metric_name not in valid_metrics:
    #                         errors.append(f"Invalid metric for performance degradation: {condition.metric_name}")

    #         elif config.trigger_type == TriggerType.TIME_BASED:
    #             if not config.schedule:
                    errors.append("Time-based trigger requires schedule configuration")
    #             elif config.schedule and not config.schedule.interval_seconds and not config.schedule.cron_expression:
                    errors.append("Time-based trigger requires interval or cron expression")

    #         elif config.trigger_type == TriggerType.THRESHOLD_BASED:
    #             if not config.conditions:
                    errors.append("Threshold-based trigger requires conditions")
    #             else:
    valid_metrics = ['memory_usage', 'cpu_usage', 'disk_usage', 'network_usage']
    #                 for condition in config.conditions:
    #                     if condition.metric_name not in valid_metrics:
    #                         errors.append(f"Invalid metric for threshold trigger: {condition.metric_name}")

    #         elif config.trigger_type == TriggerType.MANUAL:
    #             # Manual triggers have minimal requirements
    #             if config.conditions and validation_level == ConfigValidationLevel.STRICT:
                    warnings.append("Manual triggers typically don't need conditions")

    #         return errors, warnings

    #     def _validate_advanced_requirements(self, config: TriggerConfig) -> tuple[List[str], List[str]]:
    #         """Validate advanced configuration requirements."""
    errors = []
    warnings = []

    #         # Check for potential infinite loops
    #         if (config.cooldown_period_seconds and config.cooldown_period_seconds < 60 and
    #             config.max_executions_per_hour and config.max_executions_per_hour > 10):
    #             warnings.append("High execution frequency with short cooldown may cause system overload")

    #         # Check for very long timeouts
    #         if config.timeout_seconds and config.timeout_seconds > 3600:  # 1 hour
                warnings.append("Very long timeout may cause resource issues")

    #         # Check for dangerous combinations
    #         if (config.trigger_type == TriggerType.THRESHOLD_BASED and
    config.priority = = TriggerPriority.CRITICAL and
    #             config.retry_count > 5):
    #             errors.append("Critical threshold triggers with high retry count may cause system instability")

    #         # Check schedule conflicts
    #         if config.schedule and config.schedule.blackout_periods:
    current_time = time.time()
    #             for period in config.schedule.blackout_periods:
    #                 try:
    #                     from datetime import datetime
    start_time = datetime.fromisoformat(period['start'])
    end_time = datetime.fromisoformat(period['end'])

    #                     if start_time >= end_time:
                            errors.append(f"Invalid blackout period: start time must be before end time")
    #                 except Exception as e:
                        errors.append(f"Invalid blackout period format: {str(e)}")

    #         return errors, warnings

    #     def add_trigger(self, config: Union[TriggerConfig, Dict[str, Any]],
    user_id: str = math.subtract(None, reason: str = None), > ConfigValidationResult:)
    #         """Add a new trigger configuration."""
    #         with self._lock:
    #             # Validate configuration
    validation_result = self.validate_trigger_config(config)

    #             if not validation_result.valid:
                    logger.error(f"Invalid trigger configuration: {validation_result.errors}")
    #                 return validation_result

    #             # Convert to TriggerConfig if needed
    #             if isinstance(config, dict):
    config_obj = self._parse_trigger_config(config)
    #                 if not config_obj:
    validation_result.valid = False
                        validation_result.errors.append("Failed to parse trigger configuration")
    #                     return validation_result
    config = config_obj

    #             # Check for duplicate ID
    #             if config.trigger_id in self.triggers:
    validation_result.valid = False
                    validation_result.errors.append(f"Trigger ID already exists: {config.trigger_id}")
    #                 return validation_result

    #             # Create change record
    change = ConfigChange(
    change_id = str(uuid.uuid4()),
    change_type = ConfigChangeType.CREATE,
    trigger_id = config.trigger_id,
    old_config = None,
    new_config = asdict(config),
    timestamp = time.time(),
    user_id = user_id,
    reason = reason,
    validation_result = asdict(validation_result),
    applied = False
    #             )

    #             # Add to pending changes
                self.pending_changes.append(change)

    #             # Apply change
    #             if self._apply_change(change):
    #                 # Add trigger to configuration
    self.triggers[config.trigger_id] = config

    #                 # Update configuration metadata
                    self._update_config_metadata()

    #                 # Save configuration
    #                 if self._auto_save_enabled:
                        self._save_configuration()

                    logger.info(f"Added trigger: {config.name} ({config.trigger_id})")

    #             return validation_result

    #     def update_trigger(self, trigger_id: str, config: Union[TriggerConfig, Dict[str, Any]],
    user_id: str = math.subtract(None, reason: str = None), > ConfigValidationResult:)
    #         """Update an existing trigger configuration."""
    #         with self._lock:
    #             # Validate configuration
    validation_result = self.validate_trigger_config(config)

    #             if not validation_result.valid:
                    logger.error(f"Invalid trigger configuration: {validation_result.errors}")
    #                 return validation_result

    #             # Convert to TriggerConfig if needed
    #             if isinstance(config, dict):
    config_obj = self._parse_trigger_config(config)
    #                 if not config_obj:
    validation_result.valid = False
                        validation_result.errors.append("Failed to parse trigger configuration")
    #                     return validation_result
    config = config_obj

    #             # Check if trigger exists
    #             if trigger_id not in self.triggers:
    validation_result.valid = False
                    validation_result.errors.append(f"Trigger not found: {trigger_id}")
    #                 return validation_result

    #             # Get old configuration for change record
    old_config = asdict(self.triggers[trigger_id])

    #             # Create change record
    change = ConfigChange(
    change_id = str(uuid.uuid4()),
    change_type = ConfigChangeType.UPDATE,
    trigger_id = trigger_id,
    old_config = old_config,
    new_config = asdict(config),
    timestamp = time.time(),
    user_id = user_id,
    reason = reason,
    validation_result = asdict(validation_result),
    applied = False
    #             )

    #             # Add to pending changes
                self.pending_changes.append(change)

    #             # Apply change
    #             if self._apply_change(change):
    #                 # Update trigger in configuration
    self.triggers[trigger_id] = config

    #                 # Update configuration metadata
                    self._update_config_metadata()

    #                 # Save configuration
    #                 if self._auto_save_enabled:
                        self._save_configuration()

                    logger.info(f"Updated trigger: {config.name} ({trigger_id})")

    #             return validation_result

    #     def remove_trigger(self, trigger_id: str, user_id: str = None,
    reason: str = math.subtract(None), > ConfigValidationResult:)
    #         """Remove a trigger configuration."""
    #         with self._lock:
    #             # Check if trigger exists
    #             if trigger_id not in self.triggers:
                    return ConfigValidationResult(
    valid = False,
    errors = [f"Trigger not found: {trigger_id}"],
    warnings = [],
    validation_level = self.validation_level
    #                 )

    #             # Get old configuration for change record
    old_config = asdict(self.triggers[trigger_id])

    #             # Create change record
    change = ConfigChange(
    change_id = str(uuid.uuid4()),
    change_type = ConfigChangeType.DELETE,
    trigger_id = trigger_id,
    old_config = old_config,
    new_config = None,
    timestamp = time.time(),
    user_id = user_id,
    reason = reason,
    validation_result = {'valid': True, 'errors': [], 'warnings': []},
    applied = False
    #             )

    #             # Add to pending changes
                self.pending_changes.append(change)

    #             # Apply change
    #             if self._apply_change(change):
    #                 # Remove trigger from configuration
    #                 del self.triggers[trigger_id]

    #                 # Update configuration metadata
                    self._update_config_metadata()

    #                 # Save configuration
    #                 if self._auto_save_enabled:
                        self._save_configuration()

                    logger.info(f"Removed trigger: {trigger_id}")

                return ConfigValidationResult(
    valid = True,
    errors = [],
    warnings = [],
    validation_level = self.validation_level
    #             )

    #     def enable_trigger(self, trigger_id: str, user_id: str = None,
    reason: str = math.subtract(None), > ConfigValidationResult:)
    #         """Enable a trigger."""
            return self._set_trigger_enabled(trigger_id, True, user_id, reason)

    #     def disable_trigger(self, trigger_id: str, user_id: str = None,
    reason: str = math.subtract(None), > ConfigValidationResult:)
    #         """Disable a trigger."""
            return self._set_trigger_enabled(trigger_id, False, user_id, reason)

    #     def _set_trigger_enabled(self, trigger_id: str, enabled: bool,
    user_id: str = math.subtract(None, reason: str = None), > ConfigValidationResult:)
    #         """Set trigger enabled status."""
    #         with self._lock:
    #             # Check if trigger exists
    #             if trigger_id not in self.triggers:
                    return ConfigValidationResult(
    valid = False,
    errors = [f"Trigger not found: {trigger_id}"],
    warnings = [],
    validation_level = self.validation_level
    #                 )

    #             # Get current configuration
    config = self.triggers[trigger_id]
    old_config = asdict(config)

    #             # Check if already in desired state
    #             if config.enabled == enabled:
                    return ConfigValidationResult(
    valid = True,
    errors = [],
    #                     warnings=[f"Trigger already {'enabled' if enabled else 'disabled'}"],
    validation_level = self.validation_level
    #                 )

    #             # Create change record
    #             change_type = ConfigChangeType.ENABLE if enabled else ConfigChangeType.DISABLE
    change = ConfigChange(
    change_id = str(uuid.uuid4()),
    change_type = change_type,
    trigger_id = trigger_id,
    old_config = old_config,
    new_config = {**old_config, 'enabled': enabled},
    timestamp = time.time(),
    user_id = user_id,
    reason = reason,
    validation_result = {'valid': True, 'errors': [], 'warnings': []},
    applied = False
    #             )

    #             # Add to pending changes
                self.pending_changes.append(change)

    #             # Apply change
    #             if self._apply_change(change):
    #                 # Update trigger
    config.enabled = enabled

    #                 # Update configuration metadata
                    self._update_config_metadata()

    #                 # Save configuration
    #                 if self._auto_save_enabled:
                        self._save_configuration()

    #                 logger.info(f"{'Enabled' if enabled else 'Disabled'} trigger: {trigger_id}")

                return ConfigValidationResult(
    valid = True,
    errors = [],
    warnings = [],
    validation_level = self.validation_level
    #             )

    #     def _apply_change(self, change: ConfigChange) -> bool:
    #         """Apply a configuration change with safety checks."""
    #         try:
    #             # Additional safety checks can be added here
    #             # For now, just mark as applied
    change.applied = True

    #             # Move from pending to history
    #             if change in self.pending_changes:
                    self.pending_changes.remove(change)
                self.change_history.append(change)

    #             # Keep only recent changes
    #             if len(self.change_history) > 1000:
    self.change_history = math.subtract(self.change_history[, 1000:])

    #             return True

    #         except Exception as e:
                logger.error(f"Error applying change: {str(e)}")
    change.error_message = str(e)
    change.applied = False
    #             return False

    #     def _update_config_metadata(self):
    #         """Update configuration metadata."""
    self.last_modified = time.time()
    self.config_version + = 1

    #         # Calculate new checksum
    config_data = {
    #             'triggers': [asdict(config) for config in self.triggers.values()],
    #             'version': self.config_version,
    #             'last_modified': self.last_modified
    #         }
    config_json = json.dumps(config_data, sort_keys=True, default=str)
    self.config_checksum = hashlib.sha256(config_json.encode()).hexdigest()

    #     def _save_configuration(self):
    #         """Save configuration to file with backup."""
    #         try:
    #             # Create backup if file exists
    #             if os.path.exists(self.config_path):
                    self._create_backup()

    #             # Prepare configuration data
    config_data = {
    #                 'version': self.config_version,
    #                 'last_modified': self.last_modified,
    #                 'checksum': self.config_checksum,
    #                 'triggers': [],
    #                 'change_history': []
    #             }

    #             # Add triggers
    #             for config in self.triggers.values():
    trigger_dict = asdict(config)

    #                 # Convert datetime objects to strings
    #                 if trigger_dict.get('schedule') and trigger_dict['schedule'].get('start_time'):
    trigger_dict['schedule']['start_time'] = trigger_dict['schedule']['start_time'].isoformat()
    #                 if trigger_dict.get('schedule') and trigger_dict['schedule'].get('end_time'):
    trigger_dict['schedule']['end_time'] = trigger_dict['schedule']['end_time'].isoformat()

                    config_data['triggers'].append(trigger_dict)

    #             # Add change history
    #             for change in self.change_history:
    change_dict = asdict(change)
                    config_data['change_history'].append(change_dict)

    #             # Save configuration
    #             with open(self.config_path, 'w') as f:
    json.dump(config_data, f, indent = 2, default=str)

    #             if NOODLE_DEBUG:
                    logger.debug(f"Configuration saved to {self.config_path}")

    #         except Exception as e:
                logger.error(f"Error saving configuration: {str(e)}")

    #     def _create_backup(self):
    #         """Create backup of current configuration."""
    #         try:
    #             if not os.path.exists(self.backup_path):
                    os.makedirs(self.backup_path)

    #             # Create backup filename with timestamp
    timestamp = int(time.time())
    backup_file = os.path.join(self.backup_path, f"trigger_config_{timestamp}.json")

    #             # Copy current config to backup
    #             if os.path.exists(self.config_path):
    #                 import shutil
                    shutil.copy2(self.config_path, backup_file)

    #             # Clean old backups
                self._cleanup_old_backups()

    #             if NOODLE_DEBUG:
                    logger.debug(f"Created backup: {backup_file}")

    #         except Exception as e:
                logger.error(f"Error creating backup: {str(e)}")

    #     def _cleanup_old_backups(self):
    #         """Clean up old backup files."""
    #         try:
    #             if not os.path.exists(self.backup_path):
    #                 return

    #             # List backup files
    backup_files = []
    #             for filename in os.listdir(self.backup_path):
    #                 if filename.startswith('trigger_config_') and filename.endswith('.json'):
    filepath = os.path.join(self.backup_path, filename)
                        backup_files.append((filepath, os.path.getmtime(filepath)))

                # Sort by modification time (newest first)
    backup_files.sort(key = lambda x: x[1], reverse=True)

    #             # Keep only the specified number of backups
    #             if len(backup_files) > NOODLE_CONFIG_BACKUP_COUNT:
    #                 for filepath, _ in backup_files[NOODLE_CONFIG_BACKUP_COUNT:]:
    #                     try:
                            os.remove(filepath)
    #                         if NOODLE_DEBUG:
                                logger.debug(f"Removed old backup: {filepath}")
    #                     except Exception as e:
                            logger.error(f"Error removing old backup {filepath}: {str(e)}")

    #         except Exception as e:
                logger.error(f"Error cleaning up old backups: {str(e)}")

    #     def get_trigger(self, trigger_id: str) -> Optional[TriggerConfig]:
    #         """Get trigger configuration by ID."""
    #         with self._lock:
                return self.triggers.get(trigger_id)

    #     def get_all_triggers(self) -> Dict[str, TriggerConfig]:
    #         """Get all trigger configurations."""
    #         with self._lock:
                return self.triggers.copy()

    #     def get_change_history(self, trigger_id: str = None, limit: int = 100) -> List[ConfigChange]:
    #         """Get configuration change history."""
    #         with self._lock:
    history = self.change_history.copy()

    #             # Filter by trigger ID if specified
    #             if trigger_id:
    #                 history = [change for change in history if change.trigger_id == trigger_id]

    #             # Limit results
    history = math.subtract(history[, limit:])

    #             return history

    #     def get_pending_changes(self) -> List[ConfigChange]:
    #         """Get pending configuration changes."""
    #         with self._lock:
                return self.pending_changes.copy()

    #     def get_config_status(self) -> Dict[str, Any]:
    #         """Get configuration manager status."""
    #         with self._lock:
    #             return {
    #                 'config_path': self.config_path,
    #                 'backup_path': self.backup_path,
    #                 'version': self.config_version,
    #                 'last_modified': self.last_modified,
    #                 'checksum': self.config_checksum,
                    'total_triggers': len(self.triggers),
    #                 'enabled_triggers': sum(1 for config in self.triggers.values() if config.enabled),
    #                 'disabled_triggers': sum(1 for config in self.triggers.values() if not config.enabled),
    #                 'validation_level': self.validation_level.value,
    #                 'auto_save_enabled': self._auto_save_enabled,
                    'change_history_count': len(self.change_history),
                    'pending_changes_count': len(self.pending_changes),
    #                 'backup_count': len(os.listdir(self.backup_path)) if os.path.exists(self.backup_path) else 0
    #             }

    #     def export_configuration(self, export_path: str, include_history: bool = False) -> bool:
    #         """Export configuration to file."""
    #         try:
    #             with self._lock:
    config_data = {
    #                     'version': self.config_version,
    #                     'last_modified': self.last_modified,
    #                     'checksum': self.config_checksum,
    #                     'triggers': [],
                        'export_timestamp': time.time(),
    #                     'exported_by': 'trigger_config_manager'
    #                 }

    #                 # Add triggers
    #                 for config in self.triggers.values():
    trigger_dict = asdict(config)

    #                     # Convert datetime objects to strings
    #                     if trigger_dict.get('schedule') and trigger_dict['schedule'].get('start_time'):
    trigger_dict['schedule']['start_time'] = trigger_dict['schedule']['start_time'].isoformat()
    #                     if trigger_dict.get('schedule') and trigger_dict['schedule'].get('end_time'):
    trigger_dict['schedule']['end_time'] = trigger_dict['schedule']['end_time'].isoformat()

                        config_data['triggers'].append(trigger_dict)

    #                 # Add change history if requested
    #                 if include_history:
    config_data['change_history'] = []
    #                     for change in self.change_history:
                            config_data['change_history'].append(asdict(change))

    #                 # Export configuration
    #                 with open(export_path, 'w') as f:
    json.dump(config_data, f, indent = 2, default=str)

                    logger.info(f"Configuration exported to {export_path}")
    #                 return True

    #         except Exception as e:
                logger.error(f"Error exporting configuration: {str(e)}")
    #             return False

    #     def import_configuration(self, import_path: str, merge_strategy: str = 'replace') -> ConfigValidationResult:
    #         """Import configuration from file."""
    #         try:
    #             with open(import_path, 'r') as f:
    import_data = json.load(f)

    #             with self._lock:
    #                 # Validate imported configuration
    validation_result = self._validate_import_data(import_data)

    #                 if not validation_result.valid:
    #                     return validation_result

    #                 # Apply merge strategy
    #                 if merge_strategy == 'replace':
                        self.triggers.clear()
                        self.change_history.clear()

    #                 # Import triggers
    #                 for trigger_data in import_data.get('triggers', []):
    config = self._parse_trigger_config(trigger_data)
    #                     if config:
    self.triggers[config.trigger_id] = config

    #                 # Import change history
    #                 for change_data in import_data.get('change_history', []):
    change = self._parse_config_change(change_data)
    #                     if change:
                            self.change_history.append(change)

    #                 # Update metadata
    self.config_version = import_data.get('version', self.config_version)
    self.last_modified = import_data.get('last_modified', time.time())
    self.config_checksum = import_data.get('checksum', '')

    #                 # Save configuration
    #                 if self._auto_save_enabled:
                        self._save_configuration()

                    logger.info(f"Configuration imported from {import_path}")
                    return ConfigValidationResult(
    valid = True,
    errors = [],
    warnings = [],
    validation_level = self.validation_level
    #                 )

    #         except Exception as e:
                return ConfigValidationResult(
    valid = False,
    errors = [f"Import error: {str(e)}"],
    warnings = [],
    validation_level = self.validation_level
    #             )

    #     def _validate_import_data(self, import_data: Dict[str, Any]) -> ConfigValidationResult:
    #         """Validate imported configuration data."""
    errors = []
    warnings = []

    #         # Check required fields
    #         if 'triggers' not in import_data:
                errors.append("Missing triggers field in import data")

    #         # Validate each trigger
    #         for trigger_data in import_data.get('triggers', []):
    trigger_validation = self.validate_trigger_config(trigger_data, ConfigValidationLevel.BASIC)
    #             if not trigger_validation.valid:
                    errors.extend([f"Trigger {trigger_data.get('trigger_id', 'unknown')}: {err}"
    #                              for err in trigger_validation.errors])

            return ConfigValidationResult(
    valid = len(errors) == 0,
    errors = errors,
    warnings = warnings,
    validation_level = self.validation_level
    #         )