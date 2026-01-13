"""
Logs::Alert Manager - alert_manager.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Alert Manager Module

This module implements comprehensive alerting system for the NoodleCore CLI,
including multiple alert types, notification channels, and escalation policies.
"""

import asyncio
import json
import smtplib
import time
from abc import ABC, abstractmethod
from dataclasses import dataclass, asdict
from datetime import datetime, timedelta
from enum import Enum
from email.mime.text import MimeText
from email.mime.multipart import MimeMultipart
from pathlib import Path
from typing import Dict, Any, Optional, List, Union, Callable
import requests
import hashlib

from ..cli_config import get_cli_config


# Error codes for alert manager (5501-5600)
class AlertErrorCodes:
    ALERT_MANAGER_INIT_FAILED = 5501
    ALERT_CREATION_FAILED = 5502
    NOTIFICATION_FAILED = 5503
    ESCALATION_FAILED = 5504
    CHANNEL_CONFIG_FAILED = 5505
    SCHEDULING_FAILED = 5506
    DEDUPLICATION_FAILED = 5507
    HISTORY_FAILED = 5508
    INTEGRATION_FAILED = 5509
    MAINTENANCE_MODE_FAILED = 5510


class AlertSeverity(Enum):
    """Alert severity levels."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class AlertStatus(Enum):
    """Alert status values."""
    ACTIVE = "active"
    ACKNOWLEDGED = "acknowledged"
    RESOLVED = "resolved"
    SUPPRESSED = "suppressed"


class AlertType(Enum):
    """Types of alerts."""
    PERFORMANCE = "performance"
    SECURITY = "security"
    SYSTEM = "system"
    APPLICATION = "application"
    AI_PROVIDER = "ai_provider"
    SANDBOX = "sandbox"
    CUSTOM = "custom"


class NotificationChannel(Enum):
    """Notification channel types."""
    EMAIL = "email"
    WEBHOOK = "webhook"
    SLACK = "slack"
    CONSOLE = "console"
    LOG = "log"


@dataclass
class Alert:
    """Alert data structure."""
    id: str
    title: str
    description: str
    severity: AlertSeverity
    alert_type: AlertType
    status: AlertStatus
    source: str
    timestamp: datetime
    details: Dict[str, Any]
    tags: Dict[str, str]
    acknowledged_by: Optional[str] = None
    acknowledged_at: Optional[datetime] = None
    resolved_at: Optional[datetime] = None
    escalation_level: int = 0
    notification_sent: bool = False


@dataclass
class AlertRule:
    """Alert rule definition."""
    name: str
    alert_type: AlertType
    condition: str  # Python expression
    severity: AlertSeverity
    enabled: bool = True
    cooldown_period: int = 300  # seconds
    max_alerts_per_hour: int = 10
    escalation_policy: Optional[str] = None
    notification_channels: List[NotificationChannel] = None


@dataclass
class NotificationConfig:
    """Notification channel configuration."""
    channel_type: NotificationChannel
    enabled: bool = True
    config: Dict[str, Any] = None
    rate_limit: int = 10  # notifications per minute
    retry_attempts: int = 3
    retry_delay: int = 60  # seconds


class AlertException(Exception):
    """Base exception for alert manager errors."""
    
    def __init__(self, message: str, error_code: int):
        self.error_code = error_code
        super().__init__(message)


class NotificationProvider(ABC):
    """Abstract base class for notification providers."""
    
    @abstractmethod
    async def send_notification(self, alert: Alert, config: NotificationConfig) -> bool:
        """Send notification for an alert."""
        pass
    
    @abstractmethod
    def validate_config(self, config: Dict[str, Any]) -> bool:
        """Validate notification configuration."""
        pass


class EmailNotificationProvider(NotificationProvider):
    """Email notification provider."""
    
    async def send_notification(self, alert: Alert, config: NotificationConfig) -> bool:
        """Send email notification."""
        try:
            smtp_config = config.config or {}
            
            # Create email message
            msg = MimeMultipart()
            msg['From'] = smtp_config.get('from', 'noodlecore@example.com')
            msg['To'] = ', '.join(smtp_config.get('to', []))
            msg['Subject'] = f"[NoodleCore Alert] {alert.title}"
            
            # Create email body
            body = self._create_email_body(alert)
            msg.attach(MimeText(body, 'html'))
            
            # Send email
            with smtplib.SMTP(
                smtp_config.get('smtp_server', 'localhost'),
                smtp_config.get('smtp_port', 587)
            ) as server:
                if smtp_config.get('use_tls', True):
                    server.starttls()
                
                if smtp_config.get('username') and smtp_config.get('password'):
                    server.login(
                        smtp_config['username'],
                        smtp_config['password']
                    )
                
                server.send_message(msg)
            
            return True
            
        except Exception as e:
            return False
    
    def validate_config(self, config: Dict[str, Any]) -> bool:
        """Validate email configuration."""
        required_fields = ['smtp_server', 'from', 'to']
        return all(field in config for field in required_fields)
    
    def _create_email_body(self, alert: Alert) -> str:
        """Create HTML email body."""
        return f"""
        <html>
        <body>
            <h2>NoodleCore Alert</h2>
            <table border="1" style="border-collapse: collapse;">
                <tr><td><strong>Title:</strong></td><td>{alert.title}</td></tr>
                <tr><td><strong>Severity:</strong></td><td>{alert.severity.value.upper()}</td></tr>
                <tr><td><strong>Type:</strong></td><td>{alert.alert_type.value}</td></tr>
                <tr><td><strong>Status:</strong></td><td>{alert.status.value}</td></tr>
                <tr><td><strong>Source:</strong></td><td>{alert.source}</td></tr>
                <tr><td><strong>Time:</strong></td><td>{alert.timestamp.isoformat()}</td></tr>
                <tr><td><strong>Description:</strong></td><td>{alert.description}</td></tr>
            </table>
            
            <h3>Details</h3>
            <pre>{json.dumps(alert.details, indent=2)}</pre>
            
            <h3>Tags</h3>
            <pre>{json.dumps(alert.tags, indent=2)}</pre>
        </body>
        </html>
        """


class WebhookNotificationProvider(NotificationProvider):
    """Webhook notification provider."""
    
    async def send_notification(self, alert: Alert, config: NotificationConfig) -> bool:
        """Send webhook notification."""
        try:
            webhook_config = config.config or {}
            
            # Prepare webhook payload
            payload = {
                'alert_id': alert.id,
                'title': alert.title,
                'description': alert.description,
                'severity': alert.severity.value,
                'type': alert.alert_type.value,
                'status': alert.status.value,
                'source': alert.source,
                'timestamp': alert.timestamp.isoformat(),
                'details': alert.details,
                'tags': alert.tags
            }
            
            # Send webhook
            response = requests.post(
                webhook_config.get('url'),
                json=payload,
                headers=webhook_config.get('headers', {}),
                timeout=30
            )
            
            return response.status_code == 200
            
        except Exception:
            return False
    
    def validate_config(self, config: Dict[str, Any]) -> bool:
        """Validate webhook configuration."""
        return 'url' in config


class SlackNotificationProvider(NotificationProvider):
    """Slack notification provider."""
    
    async def send_notification(self, alert: Alert, config: NotificationConfig) -> bool:
        """Send Slack notification."""
        try:
            slack_config = config.config or {}
            
            # Create Slack message
            color = {
                AlertSeverity.LOW: 'good',
                AlertSeverity.MEDIUM: 'warning',
                AlertSeverity.HIGH: 'danger',
                AlertSeverity.CRITICAL: 'danger'
            }.get(alert.severity, 'warning')
            
            payload = {
                'attachments': [
                    {
                        'color': color,
                        'title': f"NoodleCore Alert: {alert.title}",
                        'text': alert.description,
                        'fields': [
                            {'title': 'Severity', 'value': alert.severity.value.upper(), 'short': True},
                            {'title': 'Type', 'value': alert.alert_type.value, 'short': True},
                            {'title': 'Status', 'value': alert.status.value, 'short': True},
                            {'title': 'Source', 'value': alert.source, 'short': True},
                            {'title': 'Time', 'value': alert.timestamp.isoformat(), 'short': False}
                        ],
                        'footer': 'NoodleCore',
                        'ts': int(alert.timestamp.timestamp())
                    }
                ]
            }
            
            # Send to Slack
            response = requests.post(
                slack_config.get('webhook_url'),
                json=payload,
                timeout=30
            )
            
            return response.status_code == 200
            
        except Exception:
            return False
    
    def validate_config(self, config: Dict[str, Any]) -> bool:
        """Validate Slack configuration."""
        return 'webhook_url' in config


class ConsoleNotificationProvider(NotificationProvider):
    """Console notification provider."""
    
    async def send_notification(self, alert: Alert, config: NotificationConfig) -> bool:
        """Print alert to console."""
        try:
            severity_symbol = {
                AlertSeverity.LOW: 'ðŸŸ¢',
                AlertSeverity.MEDIUM: 'ðŸŸ¡',
                AlertSeverity.HIGH: 'ðŸŸ ',
                AlertSeverity.CRITICAL: 'ðŸ”´'
            }.get(alert.severity, 'âšª')
            
            print(f"\n{severity_symbol} NOODLECORE ALERT [{alert.severity.value.upper()}]")
            print(f"   Title: {alert.title}")
            print(f"   Type: {alert.alert_type.value}")
            print(f"   Source: {alert.source}")
            print(f"   Time: {alert.timestamp.isoformat()}")
            print(f"   Description: {alert.description}")
            if alert.details:
                print(f"   Details: {json.dumps(alert.details, indent=6)}")
            print()
            
            return True
            
        except Exception:
            return False
    
    def validate_config(self, config: Dict[str, Any]) -> bool:
        """Console provider doesn't need configuration."""
        return True


class LogNotificationProvider(NotificationProvider):
    """Log notification provider."""
    
    def __init__(self, logger=None):
        self.logger = logger
    
    async def send_notification(self, alert: Alert, config: NotificationConfig) -> bool:
        """Log alert notification."""
        try:
            if self.logger:
                log_method = {
                    AlertSeverity.LOW: self.logger.info,
                    AlertSeverity.MEDIUM: self.logger.warning,
                    AlertSeverity.HIGH: self.logger.error,
                    AlertSeverity.CRITICAL: self.logger.critical
                }.get(alert.severity, self.logger.info)
                
                log_method(
                    f"Alert: {alert.title} - {alert.description}",
                    extra={
                        'alert_id': alert.id,
                        'alert_type': alert.alert_type.value,
                        'severity': alert.severity.value,
                        'source': alert.source,
                        'details': alert.details,
                        'tags': alert.tags
                    }
                )
            
            return True
            
        except Exception:
            return False
    
    def validate_config(self, config: Dict[str, Any]) -> bool:
        """Log provider doesn't need configuration."""
        return True


class AlertManager:
    """Comprehensive alert management system."""
    
    def __init__(self, config_dir: Optional[str] = None):
        """
        Initialize the alert manager.
        
        Args:
            config_dir: Directory for alert configuration and data
        """
        self.config = get_cli_config()
        self.config_dir = Path(config_dir or '.project/.noodle/logs')
        self.config_dir.mkdir(parents=True, exist_ok=True)
        
        # Alert storage
        self.alerts_file = self.config_dir / 'alerts.json'
        self.rules_file = self.config_dir / 'alert_rules.json'
        self.history_file = self.config_dir / 'alert_history.json'
        self.notifications_file = self.config_dir / 'notifications.json'
        
        # In-memory storage
        self.active_alerts: Dict[str, Alert] = {}
        self.alert_rules: Dict[str, AlertRule] = {}
        self.notification_configs: Dict[NotificationChannel, NotificationConfig] = {}
        self.alert_history: List[Dict[str, Any]] = []
        
        # Notification providers
        self.providers: Dict[NotificationChannel, NotificationProvider] = {
            NotificationChannel.EMAIL: EmailNotificationProvider(),
            NotificationChannel.WEBHOOK: WebhookNotificationProvider(),
            NotificationChannel.SLACK: SlackNotificationProvider(),
            NotificationChannel.CONSOLE: ConsoleNotificationProvider(),
            NotificationChannel.LOG: LogNotificationProvider()
        }
        
        # Rate limiting
        self.notification_rates: Dict[str, List[datetime]] = defaultdict(list)
        
        # Maintenance windows
        self.maintenance_windows: List[Dict[str, Any]] = []
        
        # Alert state
        self._running = False
        self._processing_task = None
        
        # Statistics
        self._stats = {
            'total_alerts': 0,
            'alerts_by_severity': defaultdict(int),
            'alerts_by_type': defaultdict(int),
            'notifications_sent': 0,
            'notifications_failed': 0,
            'start_time': datetime.now()
        }
        
        # Initialize components
        self._initialize_default_rules()
        self._initialize_notification_configs()
        self._load_alert_data()
    
    def _initialize_default_rules(self) -> None:
        """Initialize default alert rules."""
        default_rules = [
            AlertRule(
                name="high_error_rate",
                alert_type=AlertType.APPLICATION,
                condition="error_rate > 0.1",  # 10% error rate
                severity=AlertSeverity.HIGH,
                notification_channels=[NotificationChannel.EMAIL, NotificationChannel.CONSOLE]
            ),
            AlertRule(
                name="performance_degradation",
                alert_type=AlertType.PERFORMANCE,
                condition="response_time > 1.0",  # 1 second response time
                severity=AlertSeverity.MEDIUM,
                notification_channels=[NotificationChannel.CONSOLE]
            ),
            AlertRule(
                name="security_breach",
                alert_type=AlertType.SECURITY,
                condition="security_event == True",
                severity=AlertSeverity.CRITICAL,
                notification_channels=[NotificationChannel.EMAIL, NotificationChannel.SLACK, NotificationChannel.CONSOLE]
            ),
            AlertRule(
                name="system_resource_exhaustion",
                alert_type=AlertType.SYSTEM,
                condition="memory_usage > 0.9 or cpu_usage > 0.9",  # 90% usage
                severity=AlertSeverity.HIGH,
                notification_channels=[NotificationChannel.EMAIL, NotificationChannel.CONSOLE]
            ),
            AlertRule(
                name="ai_provider_failure",
                alert_type=AlertType.AI_PROVIDER,
                condition="ai_error_rate > 0.2",  # 20% error rate
                severity=AlertSeverity.MEDIUM,
                notification_channels=[NotificationChannel.CONSOLE]
            )
        ]
        
        for rule in default_rules:
            self.alert_rules[rule.name] = rule
        
        self._save_alert_rules()
    
    def _initialize_notification_configs(self) -> None:
        """Initialize default notification configurations."""
        # Console notifications (always enabled)
        self.notification_configs[NotificationChannel.CONSOLE] = NotificationConfig(
            channel_type=NotificationChannel.CONSOLE,
            enabled=True
        )
        
        # Log notifications (always enabled)
        self.notification_configs[NotificationChannel.LOG] = NotificationConfig(
            channel_type=NotificationChannel.LOG,
            enabled=True
        )
        
        # Load other configurations from environment or config
        email_config = {
            'smtp_server': self.config.get('NOODLE_SMTP_SERVER', 'localhost'),
            'smtp_port': self.config.get_int('NOODLE_SMTP_PORT', 587),
            'use_tls': self.config.get_bool('NOODLE_SMTP_TLS', True),
            'username': self.config.get('NOODLE_SMTP_USERNAME'),
            'password': self.config.get('NOODLE_SMTP_PASSWORD'),
            'from': self.config.get('NOODLE_ALERT_FROM', 'noodlecore@example.com'),
            'to': self.config.get('NOODLE_ALERT_TO', '').split(',') if self.config.get('NOODLE_ALERT_TO') else []
        }
        
        if email_config['to']:
            self.notification_configs[NotificationChannel.EMAIL] = NotificationConfig(
                channel_type=NotificationChannel.EMAIL,
                enabled=True,
                config=email_config
            )
        
        # Slack configuration
        slack_webhook = self.config.get('NOODLE_SLACK_WEBHOOK')
        if slack_webhook:
            self.notification_configs[NotificationChannel.SLACK] = NotificationConfig(
                channel_type=NotificationChannel.SLACK,
                enabled=True,
                config={'webhook_url': slack_webhook}
            )
        
        self._save_notification_configs()
    
    def _load_alert_data(self) -> None:
        """Load alert data from files."""
        try:
            # Load alerts
            if self.alerts_file.exists():
                with open(self.alerts_file, 'r', encoding='utf-8') as f:
                    alerts_data = json.load(f)
                
                for alert_data in alerts_data:
                    alert = self._dict_to_alert(alert_data)
                    if alert.status == AlertStatus.ACTIVE:
                        self.active_alerts[alert.id] = alert
            
            # Load alert rules
            if self.rules_file.exists():
                with open(self.rules_file, 'r', encoding='utf-8') as f:
                    rules_data = json.load(f)
                
                for rule_data in rules_data:
                    rule = self._dict_to_alert_rule(rule_data)
                    self.alert_rules[rule.name] = rule
            
            # Load alert history
            if self.history_file.exists():
                with open(self.history_file, 'r', encoding='utf-8') as f:
                    self.alert_history = json.load(f)
                    
        except Exception:
            # Start with empty state if loading fails
            pass
    
    def _save_alert_data(self) -> None:
        """Save alert data to files."""
        try:
            # Save active alerts
            alerts_data = [self._alert_to_dict(alert) for alert in self.active_alerts.values()]
            with open(self.alerts_file, 'w', encoding='utf-8') as f:
                json.dump(alerts_data, f, indent=2, default=str)
            
            # Save alert history
            with open(self.history_file, 'w', encoding='utf-8') as f:
                json.dump(self.alert_history, f, indent=2, default=str)
                
        except Exception:
            pass  # Don't let saving failures break alerting
    
    def _save_alert_rules(self) -> None:
        """Save alert rules to file."""
        try:
            rules_data = [self._alert_rule_to_dict(rule) for rule in self.alert_rules.values()]
            with open(self.rules_file, 'w', encoding='utf-8') as f:
                json.dump(rules_data, f, indent=2)
        except Exception:
            pass
    
    def _save_notification_configs(self) -> None:
        """Save notification configurations to file."""
        try:
            configs_data = {}
            for channel, config in self.notification_configs.items():
                configs_data[channel.value] = {
                    'channel_type': config.channel_type.value,
                    'enabled': config.enabled,
                    'config': config.config,
                    'rate_limit': config.rate_limit,
                    'retry_attempts': config.retry_attempts,
                    'retry_delay': config.retry_delay
                }
            
            with open(self.notifications_file, 'w', encoding='utf-8') as f:
                json.dump(configs_data, f, indent=2)
        except Exception:
            pass
    
    def _alert_to_dict(self, alert: Alert) -> Dict[str, Any]:
        """Convert alert to dictionary."""
        data = asdict(alert)
        data['severity'] = alert.severity.value
        data['alert_type'] = alert.alert_type.value
        data['status'] = alert.status.value
        data['timestamp'] = alert.timestamp.isoformat()
        if alert.acknowledged_at:
            data['acknowledged_at'] = alert.acknowledged_at.isoformat()
        if alert.resolved_at:
            data['resolved_at'] = alert.resolved_at.isoformat()
        return data
    
    def _dict_to_alert(self, data: Dict[str, Any]) -> Alert:
        """Convert dictionary to alert."""
        data = data.copy()
        data['severity'] = AlertSeverity(data['severity'])
        data['alert_type'] = AlertType(data['alert_type'])
        data['status'] = AlertStatus(data['status'])
        data['timestamp'] = datetime.fromisoformat(data['timestamp'])
        if data.get('acknowledged_at'):
            data['acknowledged_at'] = datetime.fromisoformat(data['acknowledged_at'])
        if data.get('resolved_at'):
            data['resolved_at'] = datetime.fromisoformat(data['resolved_at'])
        return Alert(**data)
    
    def _alert_rule_to_dict(self, rule: AlertRule) -> Dict[str, Any]:
        """Convert alert rule to dictionary."""
        data = asdict(rule)
        data['alert_type'] = rule.alert_type.value
        data['severity'] = rule.severity.value
        if rule.notification_channels:
            data['notification_channels'] = [ch.value for ch in rule.notification_channels]
        return data
    
    def _dict_to_alert_rule(self, data: Dict[str, Any]) -> AlertRule:
        """Convert dictionary to alert rule."""
        data = data.copy()
        data['alert_type'] = AlertType(data['alert_type'])
        data['severity'] = AlertSeverity(data['severity'])
        if data.get('notification_channels'):
            data['notification_channels'] = [NotificationChannel(ch) for ch in data['notification_channels']]
        return AlertRule(**data)
    
    async def start_processing(self) -> None:
        """Start alert processing."""
        if self._running:
            return
        
        self._running = True
        self._processing_task = asyncio.create_task(self._processing_loop())
    
    async def stop_processing(self) -> None:
        """Stop alert processing."""
        self._running = False
        
        if self._processing_task:
            self._processing_task.cancel()
            try:
                await self._processing_task
            except asyncio.CancelledError:
                pass
        
        self._save_alert_data()
    
    async def _processing_loop(self) -> None:
        """Main alert processing loop."""
        while self._running:
            try:
                # Check for alert rule evaluations
                await self._evaluate_alert_rules()
                
                # Process pending notifications
                await self._process_notifications()
                
                # Check for alert escalations
                await self._check_escalations()
                
                # Clean up old alerts
                await self._cleanup_old_alerts()
                
                await asyncio.sleep(30)  # Process every 30 seconds
                
            except asyncio.CancelledError:
                break
            except Exception as e:
                # Log error but continue processing
                print(f"Alert processing error: {str(e)}")
                await asyncio.sleep(30)
    
    async def create_alert(
        self,
        title: str,
        description: str,
        severity: AlertSeverity,
        alert_type: AlertType,
        source: str,
        details: Optional[Dict[str, Any]] = None,
        tags: Optional[Dict[str, str]] = None
    ) -> Alert:
        """
        Create a new alert.
        
        Args:
            title: Alert title
            description: Alert description
            severity: Alert severity
            alert_type: Type of alert
            source: Alert source
            details: Additional details
            tags: Alert tags
            
        Returns:
            Created alert
        """
        try:
            # Check for duplicate alerts
            alert_id = self._generate_alert_id(title, source, details)
            
            if alert_id in self.active_alerts:
                existing_alert = self.active_alerts[alert_id]
                # Update existing alert if more severe
                if self._compare_severity(severity, existing_alert.severity) > 0:
                    existing_alert.severity = severity
                    existing_alert.timestamp = datetime.now()
                    existing_alert.details.update(details or {})
                    return existing_alert
                else:
                    return existing_alert
            
            # Check maintenance windows
            if self._is_in_maintenance_window():
                return None
            
            # Create new alert
            alert = Alert(
                id=alert_id,
                title=title,
                description=description,
                severity=severity,
                alert_type=alert_type,
                status=AlertStatus.ACTIVE,
                source=source,
                timestamp=datetime.now(),
                details=details or {},
                tags=tags or {}
            )
            
            # Add to active alerts
            self.active_alerts[alert_id] = alert
            
            # Update statistics
            self._stats['total_alerts'] += 1
            self._stats['alerts_by_severity'][severity.value] += 1
            self._stats['alerts_by_type'][alert_type.value] += 1
            
            # Add to history
            self.alert_history.append({
                'action': 'created',
                'alert_id': alert_id,
                'timestamp': alert.timestamp.isoformat(),
                'details': self._alert_to_dict(alert)
            })
            
            # Save alert data
            self._save_alert_data()
            
            return alert
            
        except Exception as e:
            raise AlertException(
                f"Failed to create alert: {str(e)}",
                AlertErrorCodes.ALERT_CREATION_FAILED
            )
    
    def _generate_alert_id(self, title: str, source: str, details: Optional[Dict[str, Any]]) -> str:
        """Generate unique alert ID."""
        content = f"{title}:{source}:{json.dumps(details or {}, sort_keys=True)}"
        return hashlib.md5(content.encode()).hexdigest()[:16]
    
    def _compare_severity(self, severity1: AlertSeverity, severity2: AlertSeverity) -> int:
        """Compare two severity levels."""
        severity_order = {
            AlertSeverity.LOW: 0,
            AlertSeverity.MEDIUM: 1,
            AlertSeverity.HIGH: 2,
            AlertSeverity.CRITICAL: 3
        }
        return severity_order[severity1] - severity_order[severity2]
    
    def _is_in_maintenance_window(self) -> bool:
        """Check if current time is in a maintenance window."""
        now = datetime.now()
        
        for window in self.maintenance_windows:
            start = datetime.fromisoformat(window['start'])
            end = datetime.fromisoformat(window['end'])
            
            if start <= now <= end:
                return True
        
        return False
    
    async def acknowledge_alert(self, alert_id: str, acknowledged_by: str) -> bool:
        """
        Acknowledge an alert.
        
        Args:
            alert_id: Alert ID
            acknowledged_by: User acknowledging the alert
            
        Returns:
            True if successful
        """
        try:
            if alert_id not in self.active_alerts:
                return False
            
            alert = self.active_alerts[alert_id]
            alert.status = AlertStatus.ACKNOWLEDGED
            alert.acknowledged_by = acknowledged_by
            alert.acknowledged_at = datetime.now()
            
            # Add to history
            self.alert_history.append({
                'action': 'acknowledged',
                'alert_id': alert_id,
                'timestamp': alert.acknowledged_at.isoformat(),
                'acknowledged_by': acknowledged_by
            })
            
            self._save_alert_data()
            return True
            
        except Exception:
            return False
    
    async def resolve_alert(self, alert_id: str, resolved_by: str) -> bool:
        """
        Resolve an alert.
        
        Args:
            alert_id: Alert ID
            resolved_by: User resolving the alert
            
        Returns:
            True if successful
        """
        try:
            if alert_id not in self.active_alerts:
                return False
            
            alert = self.active_alerts[alert_id]
            alert.status = AlertStatus.RESOLVED
            alert.resolved_at = datetime.now()
            
            # Remove from active alerts
            del self.active_alerts[alert_id]
            
            # Add to history
            self.alert_history.append({
                'action': 'resolved',
                'alert_id': alert_id,
                'timestamp': alert.resolved_at.isoformat(),
                'resolved_by': resolved_by
            })
            
            self._save_alert_data()
            return True
            
        except Exception:
            return False
    
    async def _evaluate_alert_rules(self) -> None:
        """Evaluate alert rules and create alerts if conditions are met."""
        # This would typically integrate with metrics and monitoring systems
        # For now, it's a placeholder for rule evaluation
        pass
    
    async def _process_notifications(self) -> None:
        """Process pending notifications for active alerts."""
        for alert in self.active_alerts.values():
            if alert.notification_sent:
                continue
            
            # Find matching rules
            matching_rules = [
                rule for rule in self.alert_rules.values()
                if (rule.enabled and 
                    rule.alert_type == alert.alert_type and
                    self._should_notify_for_alert(alert, rule))
            ]
            
            if matching_rules:
                # Send notifications
                await self._send_alert_notifications(alert, matching_rules)
                alert.notification_sent = True
    
    def _should_notify_for_alert(self, alert: Alert, rule: AlertRule) -> bool:
        """Check if alert should trigger notification based on rule."""
        # Check cooldown period
        if rule.cooldown_period > 0:
            recent_notifications = [
                h for h in self.alert_history
                if (h['action'] == 'notification_sent' and
                    h['alert_id'] == alert.id and
                    (datetime.now() - datetime.fromisoformat(h['timestamp'])).total_seconds() < rule.cooldown_period)
            ]
            
            if recent_notifications:
                return False
        
        # Check rate limit
        if rule.max_alerts_per_hour > 0:
            hour_ago = datetime.now() - timedelta(hours=1)
            recent_alerts = [
                h for h in self.alert_history
                if (h['action'] == 'created' and
                    h['alert_id'] == alert.id and
                    datetime.fromisoformat(h['timestamp']) > hour_ago)
            ]
            
            if len(recent_alerts) >= rule.max_alerts_per_hour:
                return False
        
        return True
    
    async def _send_alert_notifications(self, alert: Alert, rules: List[AlertRule]) -> None:
        """Send notifications for an alert."""
        # Collect all notification channels from matching rules
        channels = set()
        for rule in rules:
            if rule.notification_channels:
                channels.update(rule.notification_channels)
        
        # Send notifications
        for channel in channels:
            config = self.notification_configs.get(channel)
            if not config or not config.enabled:
                continue
            
            # Check rate limiting
            if not self._check_rate_limit(channel, config):
                continue
            
            # Send notification
            provider = self.providers.get(channel)
            if provider:
                success = await provider.send_notification(alert, config)
                
                if success:
                    self._stats['notifications_sent'] += 1
                else:
                    self._stats['notifications_failed'] += 1
                
                # Add to history
                self.alert_history.append({
                    'action': 'notification_sent',
                    'alert_id': alert.id,
                    'timestamp': datetime.now().isoformat(),
                    'channel': channel.value,
                    'success': success
                })
    
    def _check_rate_limit(self, channel: NotificationChannel, config: NotificationConfig) -> bool:
        """Check if notification is within rate limits."""
        now = datetime.now()
        rate_key = channel.value
        
        # Clean old entries
        self.notification_rates[rate_key] = [
            timestamp for timestamp in self.notification_rates[rate_key]
            if (now - timestamp).total_seconds() < 60  # Keep last minute
        ]
        
        # Check rate limit
        if len(self.notification_rates[rate_key]) >= config.rate_limit:
            return False
        
        # Add current timestamp
        self.notification_rates[rate_key].append(now)
        return True
    
    async def _check_escalations(self) -> None:
        """Check for alert escalations."""
        now = datetime.now()
        
        for alert in self.active_alerts.values():
            # Check if alert needs escalation
            if alert.status == AlertStatus.ACTIVE:
                time_since_creation = (now - alert.timestamp).total_seconds()
                
                # Simple escalation: increase level every 30 minutes
                escalation_interval = 1800  # 30 minutes
                if time_since_creation > (alert.escalation_level + 1) * escalation_interval:
                    alert.escalation_level += 1
                    
                    # Add to history
                    self.alert_history.append({
                        'action': 'escalated',
                        'alert_id': alert.id,
                        'timestamp': now.isoformat(),
                        'escalation_level': alert.escalation_level
                    })
    
    async def _cleanup_old_alerts(self) -> None:
        """Clean up old resolved alerts."""
        cutoff_time = datetime.now() - timedelta(days=7)  # Keep 7 days
        
        # Clean history
        self.alert_history = [
            entry for entry in self.alert_history
            if datetime.fromisoformat(entry['timestamp']) > cutoff_time
        ]
        
        # Limit history size
        if len(self.alert_history) > 10000:
            self.alert_history = self.alert_history[-10000:]
    
    def add_alert_rule(self, rule: AlertRule) -> None:
        """Add an alert rule."""
        self.alert_rules[rule.name] = rule
        self._save_alert_rules()
    
    def remove_alert_rule(self, rule_name: str) -> bool:
        """Remove an alert rule."""
        if rule_name in self.alert_rules:
            del self.alert_rules[rule_name]
            self._save_alert_rules()
            return True
        return False
    
    def add_notification_config(self, config: NotificationConfig) -> None:
        """Add notification configuration."""
        self.notification_configs[config.channel_type] = config
        self._save_notification_configs()
    
    def add_maintenance_window(
        self,
        start: datetime,
        end: datetime,
        description: str = ""
    ) -> None:
        """Add a maintenance window."""
        window = {
            'start': start.isoformat(),
            'end': end.isoformat(),
            'description': description
        }
        self.maintenance_windows.append(window)
    
    def get_active_alerts(
        self,
        severity: Optional[AlertSeverity] = None,
        alert_type: Optional[AlertType] = None,
        source: Optional[str] = None
    ) -> List[Alert]:
        """Get active alerts with optional filtering."""
        alerts = list(self.active_alerts.values())
        
        if severity:
            alerts = [a for a in alerts if a.severity == severity]
        
        if alert_type:
            alerts = [a for a in alerts if a.alert_type == alert_type]
        
        if source:
            alerts = [a for a in alerts if a.source == source]
        
        return sorted(alerts, key=lambda x: x.timestamp, reverse=True)
    
    def get_alert_history(
        self,
        limit: int = 1000,
        since: Optional[datetime] = None
    ) -> List[Dict[str, Any]]:
        """Get alert history."""
        history = self.alert_history.copy()
        
        if since:
            history = [
                entry for entry in history
                if datetime.fromisoformat(entry['timestamp']) >= since
            ]
        
        return sorted(history, key=lambda x: x['timestamp'], reverse=True)[:limit]
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get alert manager statistics."""
        uptime = datetime.now() - self._stats['start_time']
        
        return {
            'running': self._running,
            'total_alerts': self._stats['total_alerts'],
            'active_alerts': len(self.active_alerts),
            'alerts_by_severity': dict(self._stats['alerts_by_severity']),
            'alerts_by_type': dict(self._stats['alerts_by_type']),
            'notifications_sent': self._stats['notifications_sent'],
            'notifications_failed': self._stats['notifications_failed'],
            'uptime_seconds': uptime.total_seconds(),
            'start_time': self._stats['start_time'].isoformat(),
            'alert_rules': len(self.alert_rules),
            'notification_configs': len(self.notification_configs),
            'maintenance_windows': len(self.maintenance_windows)
        }

