# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Performance Alert System for Noodle

# This module implements a comprehensive system for monitoring performance metrics and triggering alerts
# when they exceed predefined thresholds or when anomalies are detected. It includes configurable
# alert thresholds, rule engine with complex conditions, multi-channel delivery, escalation policies,
# suppression mechanisms, history tracking, dashboard integration, testing framework, and remediation.
# """

import asyncio
import gzip
import json
import logging
import math
import pickle
import smtplib
import sqlite3
import statistics
import threading
import time
import uuid
import abc.ABC,
import collections.defaultdict,
import concurrent.futures.ThreadPoolExecutor
import dataclasses.dataclass,
import datetime.datetime,
import email.mime.multipart.MIMEMultipart
import email.mime.text.MIMEText
import enum.Enum
import pathlib.Path
import typing.Any,

import aiohttp
import numpy as np
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import redis
import requests
import scipy.stats

logger = logging.getLogger(__name__)


class AlertSeverity(Enum)
    #     """Alert severity levels"""

    INFO = "info"
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class AlertStatus(Enum)
    #     """Alert status states"""

    ACTIVE = "active"
    ACKNOWLEDGED = "acknowledged"
    RESOLVED = "resolved"
    SUPPRESSED = "suppressed"
    ESCALATED = "escalated"


class AlertConditionType(Enum)
    #     """Types of alert conditions"""

    THRESHOLD = "threshold"
    TREND = "trend"
    CHANGE_RATE = "change_rate"
    ANOMALY = "anomaly"
    COMPOSITE = "composite"


class TimeWindow(Enum)
    #     """Time windows for analysis"""

    LAST_1_MINUTE = "1m"
    LAST_5_MINUTES = "5m"
    LAST_15_MINUTES = "15m"
    LAST_30_MINUTES = "30m"
    LAST_HOUR = "1h"
    LAST_3_HOURS = "3h"
    LAST_6_HOURS = "6h"
    LAST_12_HOURS = "12h"
    LAST_24_HOURS = "24h"
    LAST_7_DAYS = "7d"
    LAST_30_DAYS = "30d"


class NotificationChannel(Enum)
    #     """Types of notification channels"""

    EMAIL = "email"
    SLACK = "slack"
    WEBHOOK = "webhook"
    SMS = "sms"
    DASHBOARD = "dashboard"
    CUSTOM = "custom"


# @dataclass
class AlertThreshold
    #     """Configuration for alert thresholds"""

    #     metric_name: str
    #     condition_type: AlertConditionType
    #     operator: str  # "gt", "lt", "gte", "lte", "eq", "ne"
    #     threshold_value: float
    #     time_window: TimeWindow
    #     severity: AlertSeverity
    enabled: bool = True
    tags: Dict[str, str] = field(default_factory=dict)


# @dataclass
class AlertRule
    #     """Configuration for alert rules"""

    #     id: str
    #     name: str
    #     description: str
    #     conditions: List[AlertThreshold]
    composite_operator: str = "AND"  # "AND" or "OR"
    cooldown_seconds: int = 300
    enabled: bool = True
    tags: Dict[str, str] = field(default_factory=dict)
    callback: Optional[Callable[[str, Dict[str, Any]], None]] = None


# @dataclass
class NotificationConfig
    #     """Configuration for notifications"""

    #     channel: NotificationChannel
    #     recipients: List[str]
    template: Optional[str] = None
    headers: Optional[Dict[str, str]] = None
    retry_count: int = 3
    retry_delay: int = 60
    enabled: bool = True
    custom_handler: Optional[Callable[[Dict[str, Any]], None]] = None


# @dataclass
class EscalationPolicy
    #     """Configuration for alert escalation"""

    #     rule_id: str
    #     severity_levels: List[AlertSeverity]
    #     notification_configs: List[NotificationConfig]
    #     escalation_minutes: List[int]
    max_escalations: int = 3


# @dataclass
class AlertSuppression
    #     """Configuration for alert suppression"""

    metric_name: Optional[str] = None
    condition_type: Optional[AlertConditionType] = None
    time_window: Optional[TimeWindow] = None
    suppression_minutes: int = 60
    reason: str = ""
    enabled: bool = True


# @dataclass
class AlertGrouping
    #     """Configuration for alert grouping"""

    #     group_by: List[str]  # Fields to group alerts by
    max_alerts_per_group: int = 10
    group_window_minutes: int = 5
    summary_template: str = (
    #         "Multiple alerts triggered: {count} alerts for {metric_name}"
    #     )


# @dataclass
class AlertEvent
    #     """Represents an alert event"""

    #     id: str
    #     rule_id: str
    #     rule_name: str
    #     metric_name: str
    #     condition_type: AlertConditionType
    #     severity: AlertSeverity
    #     current_value: float
    #     threshold_value: float
    #     deviation_percent: float
    #     timestamp: datetime
    #     time_window: TimeWindow
    #     status: AlertStatus
    #     description: str
    suggested_actions: List[str] = field(default_factory=list)
    metadata: Dict[str, Any] = field(default_factory=dict)
    acknowledged_by: Optional[str] = None
    acknowledged_at: Optional[datetime] = None
    resolved_at: Optional[datetime] = None
    escalation_count: int = 0
    notification_attempts: List[Dict[str, Any]] = field(default_factory=list)


# @dataclass
class RemediationAction
    #     """Configuration for automated remediation actions"""

    #     id: str
    #     name: str
    #     description: str
    #     trigger_conditions: List[AlertThreshold]
    #     action_type: str  # "script", "api_call", "config_change", "restart"
    #     action_config: Dict[str, Any]
    enabled: bool = True
    dry_run: bool = True
    timeout_seconds: int = 300
    rollback_enabled: bool = True
    rollback_config: Optional[Dict[str, Any]] = None


class AlertStorage
    #     """Manages persistent storage for alerts"""

    #     def __init__(self, storage_path: str = "alerts"):
    self.storage_path = Path(storage_path)
    self.storage_path.mkdir(parents = True, exist_ok=True)
    self.lock = threading.Lock()

    #         # Initialize SQLite database for persistent storage
    self.db_path = self.storage_path / "alerts.db"
            self._init_database()

    #     def _init_database(self):
    #         """Initialize SQLite database for alert storage"""
    #         with sqlite3.connect(self.db_path) as conn:
                conn.execute(
    #                 """
                    CREATE TABLE IF NOT EXISTS alerts (
    #                     id TEXT PRIMARY KEY,
    #                     rule_id TEXT NOT NULL,
    #                     rule_name TEXT NOT NULL,
    #                     metric_name TEXT NOT NULL,
    #                     condition_type TEXT NOT NULL,
    #                     severity TEXT NOT NULL,
    #                     current_value REAL NOT NULL,
    #                     threshold_value REAL NOT NULL,
    #                     deviation_percent REAL NOT NULL,
    #                     timestamp TIMESTAMP NOT NULL,
    #                     time_window TEXT NOT NULL,
    #                     status TEXT NOT NULL,
    #                     description TEXT,
    #                     suggested_actions TEXT,
    #                     metadata TEXT,
    #                     acknowledged_by TEXT,
    #                     acknowledged_at TIMESTAMP,
    #                     resolved_at TIMESTAMP,
    #                     escalation_count INTEGER DEFAULT 0,
    #                     notification_attempts TEXT
    #                 )
    #             """
    #             )

                conn.execute(
    #                 """
                    CREATE TABLE IF NOT EXISTS alert_history (
    #                     id INTEGER PRIMARY KEY AUTOINCREMENT,
    #                     alert_id TEXT NOT NULL,
    #                     status_change TEXT NOT NULL,
    #                     timestamp TIMESTAMP NOT NULL,
    #                     user TEXT,
    #                     notes TEXT,
                        FOREIGN KEY (alert_id) REFERENCES alerts(id)
    #                 )
    #             """
    #             )

                conn.execute(
    #                 """
    #                 CREATE INDEX IF NOT EXISTS idx_alerts_timestamp
                    ON alerts(timestamp, status)
    #             """
    #             )

                conn.execute(
    #                 """
    #                 CREATE INDEX IF NOT EXISTS idx_alerts_metric
                    ON alerts(metric_name, severity)
    #             """
    #             )

                conn.commit()

    #     def save_alert(self, alert: AlertEvent) -> bool:
    #         """Save an alert to storage"""
    #         try:
    #             with sqlite3.connect(self.db_path) as conn:
                    conn.execute(
    #                     """
    #                     INSERT OR REPLACE INTO alerts
                        (id, rule_id, rule_name, metric_name, condition_type, severity,
    #                      current_value, threshold_value, deviation_percent, timestamp,
    #                      time_window, status, description, suggested_actions, metadata,
    #                      acknowledged_by, acknowledged_at, resolved_at, escalation_count,
    #                      notification_attempts)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    #                 """,
                        (
    #                         alert.id,
    #                         alert.rule_id,
    #                         alert.rule_name,
    #                         alert.metric_name,
    #                         alert.condition_type.value,
    #                         alert.severity.value,
    #                         alert.current_value,
    #                         alert.threshold_value,
    #                         alert.deviation_percent,
                            alert.timestamp.isoformat(),
    #                         alert.time_window.value,
    #                         alert.status.value,
    #                         alert.description,
                            json.dumps(alert.suggested_actions),
                            json.dumps(alert.metadata),
    #                         alert.acknowledged_by,
                            (
                                alert.acknowledged_at.isoformat()
    #                             if alert.acknowledged_at
    #                             else None
    #                         ),
    #                         alert.resolved_at.isoformat() if alert.resolved_at else None,
    #                         alert.escalation_count,
                            json.dumps(alert.notification_attempts),
    #                     ),
    #                 )
                    conn.commit()
    #             return True
    #         except Exception as e:
                logger.error(f"Failed to save alert: {e}")
    #             return False

    #     def get_alert(self, alert_id: str) -> Optional[AlertEvent]:
    #         """Retrieve an alert from storage"""
    #         try:
    #             with sqlite3.connect(self.db_path) as conn:
    cursor = conn.execute(
    #                     """
    #                     SELECT id, rule_id, rule_name, metric_name, condition_type, severity,
    #                            current_value, threshold_value, deviation_percent, timestamp,
    #                            time_window, status, description, suggested_actions, metadata,
    #                            acknowledged_by, acknowledged_at, resolved_at, escalation_count,
    #                            notification_attempts
    FROM alerts WHERE id = ?
    #                 """,
                        (alert_id,),
    #                 )

    row = cursor.fetchone()
    #                 if row:
                        return AlertEvent(
    id = row[0],
    rule_id = row[1],
    rule_name = row[2],
    metric_name = row[3],
    condition_type = AlertConditionType(row[4]),
    severity = AlertSeverity(row[5]),
    current_value = row[6],
    threshold_value = row[7],
    deviation_percent = row[8],
    timestamp = datetime.fromisoformat(row[9]),
    time_window = TimeWindow(row[10]),
    status = AlertStatus(row[11]),
    description = row[12] or "",
    #                         suggested_actions=json.loads(row[13]) if row[13] else [],
    #                         metadata=json.loads(row[14]) if row[14] else {},
    acknowledged_by = row[15],
    acknowledged_at = (
    #                             datetime.fromisoformat(row[16]) if row[16] else None
    #                         ),
    resolved_at = (
    #                             datetime.fromisoformat(row[17]) if row[17] else None
    #                         ),
    escalation_count = row[18],
    #                         notification_attempts=json.loads(row[19]) if row[19] else [],
    #                     )
    #             return None
    #         except Exception as e:
                logger.error(f"Failed to retrieve alert: {e}")
    #             return None

    #     def get_alerts(
    #         self,
    status: Optional[AlertStatus] = None,
    metric_name: Optional[str] = None,
    start_time: Optional[datetime] = None,
    end_time: Optional[datetime] = None,
    limit: int = 100,
    #     ) -> List[AlertEvent]:
    #         """Retrieve alerts from storage with optional filtering"""
    alerts = []

    #         try:
    #             with sqlite3.connect(self.db_path) as conn:
    query = """
    #                     SELECT id, rule_id, rule_name, metric_name, condition_type, severity,
    #                            current_value, threshold_value, deviation_percent, timestamp,
    #                            time_window, status, description, suggested_actions, metadata,
    #                            acknowledged_by, acknowledged_at, resolved_at, escalation_count,
    #                            notification_attempts
    #                     FROM alerts
    #                 """

    conditions = []
    params = []

    #                 if status:
    conditions.append("status = ?")
                        params.append(status.value)

    #                 if metric_name:
    conditions.append("metric_name = ?")
                        params.append(metric_name)

    #                 if start_time:
    conditions.append("timestamp > = ?")
                        params.append(start_time.isoformat())

    #                 if end_time:
    conditions.append("timestamp < = ?")
                        params.append(end_time.isoformat())

    #                 if conditions:
    query + = " WHERE " + " AND ".join(conditions)

    query + = " ORDER BY timestamp DESC LIMIT ?"
                    params.append(limit)

    cursor = conn.execute(query, params)

    #                 for row in cursor.fetchall():
                        alerts.append(
                            AlertEvent(
    id = row[0],
    rule_id = row[1],
    rule_name = row[2],
    metric_name = row[3],
    condition_type = AlertConditionType(row[4]),
    severity = AlertSeverity(row[5]),
    current_value = row[6],
    threshold_value = row[7],
    deviation_percent = row[8],
    timestamp = datetime.fromisoformat(row[9]),
    time_window = TimeWindow(row[10]),
    status = AlertStatus(row[11]),
    description = row[12] or "",
    #                             suggested_actions=json.loads(row[13]) if row[13] else [],
    #                             metadata=json.loads(row[14]) if row[14] else {},
    acknowledged_by = row[15],
    acknowledged_at = (
    #                                 datetime.fromisoformat(row[16]) if row[16] else None
    #                             ),
    resolved_at = (
    #                                 datetime.fromisoformat(row[17]) if row[17] else None
    #                             ),
    escalation_count = row[18],
    notification_attempts = (
    #                                 json.loads(row[19]) if row[19] else []
    #                             ),
    #                         )
    #                     )

    #             return alerts
    #         except Exception as e:
                logger.error(f"Failed to retrieve alerts: {e}")
    #             return []

    #     def update_alert_status(
    #         self,
    #         alert_id: str,
    #         status: AlertStatus,
    user: Optional[str] = None,
    notes: Optional[str] = None,
    #     ) -> bool:
    #         """Update the status of an alert"""
    #         try:
    #             with sqlite3.connect(self.db_path) as conn:
    #                 # Update alert status
                    conn.execute(
    #                     """
    #                     UPDATE alerts
    SET status = ?, acknowledged_by = ?, acknowledged_at = ?
    WHERE id = ?
    #                 """,
                        (
    #                         status.value,
    #                         user,
                            (
                                datetime.now().isoformat()
    #                             if status == AlertStatus.ACKNOWLEDGED
    #                             else None
    #                         ),
    #                         alert_id,
    #                     ),
    #                 )

    #                 # Record status change in history
                    conn.execute(
    #                     """
                        INSERT INTO alert_history (alert_id, status_change, timestamp, user, notes)
                        VALUES (?, ?, ?, ?, ?)
    #                 """,
                        (alert_id, status.value, datetime.now().isoformat(), user, notes),
    #                 )

                    conn.commit()
    #             return True
    #         except Exception as e:
                logger.error(f"Failed to update alert status: {e}")
    #             return False


class NotificationHandler(ABC)
    #     """Abstract base class for notification handlers"""

    #     @abstractmethod
    #     async def send_notification(
    #         self, alert: AlertEvent, config: NotificationConfig
    #     ) -> bool:
    #         """Send a notification for an alert"""
    #         pass


class EmailNotificationHandler(NotificationHandler)
    #     """Handler for email notifications"""

    #     def __init__(
    #         self,
    #         smtp_server: str,
    #         smtp_port: int,
    #         username: str,
    #         password: str,
    use_tls: bool = True,
    #     ):
    self.smtp_server = smtp_server
    self.smtp_port = smtp_port
    self.username = username
    self.password = password
    self.use_tls = use_tls

    #     async def send_notification(
    #         self, alert: AlertEvent, config: NotificationConfig
    #     ) -> bool:
    #         """Send email notification for an alert"""
    #         try:
    #             # Create message
    msg = MIMEMultipart()
    msg["From"] = self.username
    msg["To"] = ", ".join(config.recipients)
    msg["Subject"] = f"[{alert.severity.value.upper()}] {alert.rule_name}"

    #             # Create body
    body = f"""
# Alert Details:
# - Rule: {alert.rule_name}
# - Metric: {alert.metric_name}
# - Severity: {alert.severity.value}
# - Current Value: {alert.current_value}
# - Threshold: {alert.threshold_value}
# - Deviation: {alert.deviation_percent:.2f}%
# - Time: {alert.timestamp}
# - Status: {alert.status.value}

# Description: {alert.description}

# Suggested Actions:
# {chr(10).join(f"- {action}" for action in alert.suggested_actions)}
#             """

            msg.attach(MIMEText(body, "plain"))

#             # Send email
#             with smtplib.SMTP(self.smtp_server, self.smtp_port) as server:
#                 if self.use_tls:
                    server.starttls()
                server.login(self.username, self.password)
                server.send_message(msg)

#             logger.info(f"Email notification sent for alert {alert.id}")
#             return True
#         except Exception as e:
            logger.error(f"Failed to send email notification: {e}")
#             return False


class SlackNotificationHandler(NotificationHandler)
    #     """Handler for Slack notifications"""

    #     def __init__(self, webhook_url: str):
    self.webhook_url = webhook_url

    #     async def send_notification(
    #         self, alert: AlertEvent, config: NotificationConfig
    #     ) -> bool:
    #         """Send Slack notification for an alert"""
    #         try:
    #             # Create Slack message
    color = {
    #                 AlertSeverity.INFO: "good",
    #                 AlertSeverity.LOW: "warning",
    #                 AlertSeverity.MEDIUM: "warning",
    #                 AlertSeverity.HIGH: "danger",
    #                 AlertSeverity.CRITICAL: "danger",
                }.get(alert.severity, "warning")

    payload = {
    #                 "attachments": [
    #                     {
    #                         "color": color,
                            "title": f"[{alert.severity.value.upper()}] {alert.rule_name}",
    #                         "fields": [
    #                             {
    #                                 "title": "Metric",
    #                                 "value": alert.metric_name,
    #                                 "short": True,
    #                             },
    #                             {
    #                                 "title": "Current Value",
                                    "value": str(alert.current_value),
    #                                 "short": True,
    #                             },
    #                             {
    #                                 "title": "Threshold",
                                    "value": str(alert.threshold_value),
    #                                 "short": True,
    #                             },
    #                             {
    #                                 "title": "Deviation",
    #                                 "value": f"{alert.deviation_percent:.2f}%",
    #                                 "short": True,
    #                             },
    #                             {
    #                                 "title": "Time",
                                    "value": alert.timestamp.isoformat(),
    #                                 "short": True,
    #                             },
    #                             {
    #                                 "title": "Status",
    #                                 "value": alert.status.value,
    #                                 "short": True,
    #                             },
    #                             {
    #                                 "title": "Description",
    #                                 "value": alert.description,
    #                                 "short": False,
    #                             },
    #                         ],
    #                         "footer": "Noodle Alert System",
                            "ts": int(alert.timestamp.timestamp()),
    #                     }
    #                 ]
    #             }

    #             # Send to Slack
    #             async with aiohttp.ClientSession() as session:
    #                 async with session.post(self.webhook_url, json=payload) as response:
    #                     if response.status == 200:
    #                         logger.info(f"Slack notification sent for alert {alert.id}")
    #                         return True
    #                     else:
                            logger.error(f"Slack notification failed: {response.status}")
    #                         return False
    #         except Exception as e:
                logger.error(f"Failed to send Slack notification: {e}")
    #             return False


class WebhookNotificationHandler(NotificationHandler)
    #     """Handler for webhook notifications"""

    #     def __init__(self, timeout: int = 30):
    self.timeout = timeout

    #     async def send_notification(
    #         self, alert: AlertEvent, config: NotificationConfig
    #     ) -> bool:
    #         """Send webhook notification for an alert"""
    #         try:
    #             # Create webhook payload
    payload = {
    #                 "alert_id": alert.id,
    #                 "rule_id": alert.rule_id,
    #                 "rule_name": alert.rule_name,
    #                 "metric_name": alert.metric_name,
    #                 "condition_type": alert.condition_type.value,
    #                 "severity": alert.severity.value,
    #                 "current_value": alert.current_value,
    #                 "threshold_value": alert.threshold_value,
    #                 "deviation_percent": alert.deviation_percent,
                    "timestamp": alert.timestamp.isoformat(),
    #                 "time_window": alert.time_window.value,
    #                 "status": alert.status.value,
    #                 "description": alert.description,
    #                 "suggested_actions": alert.suggested_actions,
    #                 "metadata": alert.metadata,
    #             }

    #             # Send webhook
    #             async with aiohttp.ClientSession() as session:
    #                 async with session.post(
    #                     config.recipients[0],  # First recipient is the webhook URL
    json = payload,
    headers = config.headers or {},
    timeout = self.timeout,
    #                 ) as response:
    #                     if response.status < 400:
    #                         logger.info(f"Webhook notification sent for alert {alert.id}")
    #                         return True
    #                     else:
                            logger.error(f"Webhook notification failed: {response.status}")
    #                         return False
    #         except Exception as e:
                logger.error(f"Failed to send webhook notification: {e}")
    #             return False


class AlertEngine
    #     """Core alert processing engine"""

    #     def __init__(self, storage: AlertStorage):
    self.storage = storage
    self.rules: Dict[str, AlertRule] = {}
    self.suppressions: List[AlertSuppression] = []
    self.grouping_config: Optional[AlertGrouping] = None
    self.escalation_policies: Dict[str, EscalationPolicy] = {}
    self.remediation_actions: Dict[str, RemediationAction] = {}
    self.last_alerts: Dict[str, datetime] = {}
    self.alert_groups: Dict[str, List[AlertEvent]] = defaultdict(list)
    self.lock = threading.Lock()

    #         # Initialize notification handlers
    self.notification_handlers: Dict[NotificationChannel, NotificationHandler] = {}

    #         # Initialize thread pool for async operations
    self.executor = ThreadPoolExecutor(max_workers=5)

    #     def add_rule(self, rule: AlertRule):
    #         """Add an alert rule"""
    #         with self.lock:
    self.rules[rule.id] = rule
                logger.info(f"Added alert rule: {rule.name}")

    #     def remove_rule(self, rule_id: str):
    #         """Remove an alert rule"""
    #         with self.lock:
    #             if rule_id in self.rules:
    #                 del self.rules[rule_id]
                    logger.info(f"Removed alert rule: {rule_id}")

    #     def add_suppression(self, suppression: AlertSuppression):
    #         """Add an alert suppression"""
    #         with self.lock:
                self.suppressions.append(suppression)
                logger.info(
    #                 f"Added alert suppression for: {suppression.metric_name or 'all metrics'}"
    #             )

    #     def remove_suppression(self, index: int):
    #         """Remove an alert suppression"""
    #         with self.lock:
    #             if 0 <= index < len(self.suppressions):
    removed = self.suppressions.pop(index)
                    logger.info(
    #                     f"Removed alert suppression: {removed.metric_name or 'all metrics'}"
    #                 )

    #     def set_grouping_config(self, config: AlertGrouping):
    #         """Set alert grouping configuration"""
    #         with self.lock:
    self.grouping_config = config
                logger.info(f"Set alert grouping config: {config.group_by}")

    #     def add_escalation_policy(self, policy: EscalationPolicy):
    #         """Add an escalation policy"""
    #         with self.lock:
    self.escalation_policies[policy.rule_id] = policy
    #             logger.info(f"Added escalation policy for rule: {policy.rule_id}")

    #     def add_remediation_action(self, action: RemediationAction):
    #         """Add a remediation action"""
    #         with self.lock:
    self.remediation_actions[action.id] = action
                logger.info(f"Added remediation action: {action.name}")

    #     def add_notification_handler(
    #         self, channel: NotificationChannel, handler: NotificationHandler
    #     ):
    #         """Add a notification handler"""
    self.notification_handlers[channel] = handler
            logger.info(f"Added notification handler for: {channel.value}")

    #     def is_suppressed(self, alert: AlertEvent) -> bool:
    #         """Check if an alert is suppressed"""
    #         for suppression in self.suppressions:
    #             if not suppression.enabled:
    #                 continue

    #             # Check metric name
    #             if suppression.metric_name and alert.metric_name != suppression.metric_name:
    #                 continue

    #             # Check condition type
    #             if (
    #                 suppression.condition_type
    and alert.condition_type ! = suppression.condition_type
    #             ):
    #                 continue

    #             # Check time window
    #             if suppression.time_window and alert.time_window != suppression.time_window:
    #                 continue

    #             # Check if within suppression period
    suppression_cutoff = math.subtract(alert.timestamp, timedelta()
    minutes = suppression.suppression_minutes
    #             )

    #             # Check if similar alert was recently suppressed
    #             with self.lock:
    #                 for last_alert in self.last_alerts.values():
    #                     if (
    last_alert > = suppression_cutoff
    and last_alert < = alert.timestamp
                            and self._is_similar_alert(alert, last_alert)
    #                     ):
                            logger.info(
    #                             f"Alert {alert.id} suppressed: {suppression.reason}"
    #                         )
    #                         return True

    #         return False

    #     def _is_similar_alert(self, alert: AlertEvent, timestamp: datetime) -> bool:
    #         """Check if an alert is similar to one at the given timestamp"""
    #         # This is a simplified similarity check
    #         # In a real implementation, you might want more sophisticated logic
    #         return True

    #     def evaluate_condition(
    #         self, condition: AlertThreshold, current_value: float
    #     ) -> bool:
    #         """Evaluate an alert condition"""
    #         if not condition.enabled:
    #             return False

    #         if condition.operator == "gt":
    #             return current_value > condition.threshold_value
    #         elif condition.operator == "lt":
    #             return current_value < condition.threshold_value
    #         elif condition.operator == "gte":
    return current_value > = condition.threshold_value
    #         elif condition.operator == "lte":
    return current_value < = condition.threshold_value
    #         elif condition.operator == "eq":
    return current_value = = condition.threshold_value
    #         elif condition.operator == "ne":
    return current_value ! = condition.threshold_value

    #         return False

    #     def process_metrics(self, metrics: List[Dict[str, Any]]) -> List[AlertEvent]:
    #         """Process metrics and generate alerts"""
    alerts = []

    #         for metric in metrics:
    metric_name = metric["name"]  # Assuming metric has 'name' key
