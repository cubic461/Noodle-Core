"""
Noodlenet::Alerting - alerting.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Real-time alerting system for NoodleNet distributed systems.

This module provides comprehensive real-time alerting including alert routing,
notification channels, escalation policies, and alert management.
"""

import asyncio
import time
import logging
import json
import smtplib
from typing import Dict, List, Optional, Set, Tuple, Any, Callable, Union
from dataclasses import dataclass, field
from enum import Enum
from collections import defaultdict, deque
import uuid
from email.mime.text import MimeText
from email.mime.multipart import MimeMultipart
from .config import NoodleNetConfig
from .monitoring import Alert, AlertSeverity, AlertManager

logger = logging.getLogger(__name__)


class NotificationChannel(Enum):
    """Types of notification channels"""
    EMAIL = "email"
    SMS = "sms"
    SLACK = "slack"
    WEBHOOK = "webhook"
    LOG = "log"
    DATABASE = "database"


class EscalationLevel(Enum):
    """Alert escalation levels"""
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"
    CRITICAL = "critical"


class AlertStatus(Enum):
    """Alert status in the alerting system"""
    OPEN = "open"
    ACKNOWLEDGED = "acknowledged"
    SUPPRESSED = "suppressed"
    RESOLVED = "resolved"


@dataclass
class NotificationConfig:
    """Configuration for a notification channel"""
    
    channel_type: NotificationChannel
    enabled: bool = True
    config: Dict[str, Any] = field(default_factory=dict)
    
    # Rate limiting
    max_notifications_per_hour: int = 10
    max_notifications_per_day: int = 50
    
    # Filtering
    min_severity: AlertSeverity = AlertSeverity.WARNING
    allowed_alert_names: Set[str] = field(default_factory=set)
    blocked_alert_names: Set[str] = field(default_factory=set)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary"""
        return {
            'channel_type': self.channel_type.value,
            'enabled': self.enabled,
            'config': self.config,
            'max_notifications_per_hour': self.max_notifications_per_hour,
            'max_notifications_per_day': self.max_notifications_per_day,
            'min_severity': self.min_severity.value,
            'allowed_alert_names': list(self.allowed_alert_names),
            'blocked_alert_names': list(self.blocked_alert_names)
        }


@dataclass
class EscalationPolicy:
    """Escalation policy for alerts"""
    
    policy_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    name: str = ""
    description: str = ""
    
    # Escalation rules
    rules: List[Dict[str, Any]] = field(default_factory=list)
    
    # Timing
    escalation_interval: float = 300.0  # 5 minutes
    max_escalations: int = 3
    
    # Conditions
    conditions: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary"""
        return {
            'policy_id': self.policy_id,
            'name': self.name,
            'description': self.description,
            'rules': self.rules,
            'escalation_interval': self.escalation_interval,
            'max_escalations': self.max_escalations,
            'conditions': self.conditions
        }


@dataclass
class AlertNotification:
    """Represents an alert notification"""
    
    notification_id: str = field(default_factory=lambda: str(uuid.uuid4()))
    alert_id: str = ""
    channel: NotificationChannel = NotificationChannel.LOG
    recipient: str = ""
    
    # Status
    status: AlertStatus = AlertStatus.OPEN
    sent_at: Optional[float] = None
    acknowledged_at: Optional[float] = None
    resolved_at: Optional[float] = None
    
    # Content
    subject: str = ""
    message: str = ""
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary"""
        return {
            'notification_id': self.notification_id,
            'alert_id': self.alert_id,
            'channel': self.channel.value,
            'recipient': self.recipient,
            'status': self.status.value,
            'sent_at': self.sent_at,
            'acknowledged_at': self.acknowledged_at,
            'resolved_at': self.resolved_at,
            'subject': self.subject,
            'message': self.message,
            'metadata': self.metadata
        }


class NotificationSender:
    """Base class for notification senders"""
    
    def __init__(self, config: Dict[str, Any]):
        """
        Initialize notification sender
        
        Args:
            config: Sender configuration
        """
        self.config = config
    
    async def send_notification(self, notification: AlertNotification) -> bool:
        """
        Send a notification
        
        Args:
            notification: Notification to send
            
        Returns:
            True if successfully sent
        """
        raise NotImplementedError


class EmailNotificationSender(NotificationSender):
    """Email notification sender"""
    
    def __init__(self, config: Dict[str, Any]):
        """
        Initialize email sender
        
        Args:
            config: Email configuration
        """
        super().__init__(config)
        
        self.smtp_server = config.get('smtp_server', 'localhost')
        self.smtp_port = config.get('smtp_port', 587)
        self.username = config.get('username', '')
        self.password = config.get('password', '')
        self.from_address = config.get('from_address', 'alerts@noodlenet.local')
        self.use_tls = config.get('use_tls', True)
    
    async def send_notification(self, notification: AlertNotification) -> bool:
        """Send email notification"""
        try:
            # Create message
            msg = MimeMultipart()
            msg['From'] = self.from_address
            msg['To'] = notification.recipient
            msg['Subject'] = notification.subject
            
            # Add body
            body = MimeText(notification.message, 'html')
            msg.attach(body)
            
            # Send email
            with smtplib.SMTP(self.smtp_server, self.smtp_port) as server:
                if self.use_tls:
                    server.starttls()
                
                if self.username and self.password:
                    server.login(self.username, self.password)
                
                server.send_message(msg)
            
            logger.info(f"Email notification sent to {notification.recipient}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to send email notification: {e}")
            return False


class SlackNotificationSender(NotificationSender):
    """Slack notification sender"""
    
    def __init__(self, config: Dict[str, Any]):
        """
        Initialize Slack sender
        
        Args:
            config: Slack configuration
        """
        super().__init__(config)
        
        self.webhook_url = config.get('webhook_url', '')
        self.channel = config.get('channel', '#alerts')
        self.username = config.get('username', 'NoodleNet Alert')
    
    async def send_notification(self, notification: AlertNotification) -> bool:
        """Send Slack notification"""
        try:
            import aiohttp
            
            # Create Slack message
            slack_message = {
                'channel': self.channel,
                'username': self.username,
                'text': notification.subject,
                'attachments': [
                    {
                        'color': self._get_color_by_severity(notification.metadata.get('severity', 'warning')),
                        'text': notification.message
                    }
                ]
            }
            
            # Send to Slack
            async with aiohttp.ClientSession() as session:
                async with session.post(
                    self.webhook_url,
                    json=slack_message,
                    headers={'Content-Type': 'application/json'}
                ) as response:
                    if response.status == 200:
                        logger.info(f"Slack notification sent to {self.channel}")
                        return True
                    else:
                        logger.error(f"Slack notification failed: {response.status}")
                        return False
            
        except Exception as e:
            logger.error(f"Failed to send Slack notification: {e}")
            return False
    
    def _get_color_by_severity(self, severity: str) -> str:
        """Get Slack color by alert severity"""
        colors = {
            'info': '#36a64f',      # green
            'warning': '#ff9500',   # orange
            'error': '#ff0000',     # red
            'critical': '#8b0000'   # dark red
        }
        return colors.get(severity, '#ff9500')


class WebhookNotificationSender(NotificationSender):
    """Webhook notification sender"""
    
    def __init__(self, config: Dict[str, Any]):
        """
        Initialize webhook sender
        
        Args:
            config: Webhook configuration
        """
        super().__init__(config)
        
        self.url = config.get('url', '')
        self.method = config.get('method', 'POST')
        self.headers = config.get('headers', {})
        self.auth = config.get('auth', {})
    
    async def send_notification(self, notification: AlertNotification) -> bool:
        """Send webhook notification"""
        try:
            import aiohttp
            
            # Create payload
            payload = {
                'notification_id': notification.notification_id,
                'alert_id': notification.alert_id,
                'subject': notification.subject,
                'message': notification.message,
                'metadata': notification.metadata
            }
            
            # Send webhook
            async with aiohttp.ClientSession() as session:
                async with session.request(
                    self.method,
                    self.url,
                    json=payload,
                    headers=self.headers,
                    auth=aiohttp.BasicAuth(
                        self.auth.get('username', ''),
                        self.auth.get('password', '')
                    ) if self.auth else None
                ) as response:
                    if 200 <= response.status < 300:
                        logger.info(f"Webhook notification sent to {self.url}")
                        return True
                    else:
                        logger.error(f"Webhook notification failed: {response.status}")
                        return False
            
        except Exception as e:
            logger.error(f"Failed to send webhook notification: {e}")
            return False


class LogNotificationSender(NotificationSender):
    """Log notification sender"""
    
    def __init__(self, config: Dict[str, Any]):
        """
        Initialize log sender
        
        Args:
            config: Log configuration
        """
        super().__init__(config)
        
        self.log_level = config.get('log_level', 'WARNING')
        self.logger_name = config.get('logger_name', 'alerting')
    
    async def send_notification(self, notification: AlertNotification) -> bool:
        """Send log notification"""
        try:
            # Get logger
            log_logger = logging.getLogger(self.logger_name)
            
            # Log message
            log_message = f"[ALERT] {notification.subject}: {notification.message}"
            
            # Log at appropriate level
            if self.log_level.upper() == 'DEBUG':
                log_logger.debug(log_message)
            elif self.log_level.upper() == 'INFO':
                log_logger.info(log_message)
            elif self.log_level.upper() == 'WARNING':
                log_logger.warning(log_message)
            elif self.log_level.upper() == 'ERROR':
                log_logger.error(log_message)
            elif self.log_level.upper() == 'CRITICAL':
                log_logger.critical(log_message)
            else:
                log_logger.warning(log_message)
            
            return True
            
        except Exception as e:
            logger.error(f"Failed to send log notification: {e}")
            return False


class RealTimeAlertManager:
    """Real-time alert management system"""
    
    def __init__(self, alert_manager: AlertManager, config: Optional[NoodleNetConfig] = None):
        """
        Initialize real-time alert manager
        
        Args:
            alert_manager: Base alert manager
            config: NoodleNet configuration
        """
        self.alert_manager = alert_manager
        self.config = config or NoodleNetConfig()
        
        # Notification channels
        self._notification_configs: Dict[str, NotificationConfig] = {}
        self._notification_senders: Dict[NotificationChannel, NotificationSender] = {}
        
        # Escalation policies
        self._escalation_policies: Dict[str, EscalationPolicy] = {}
        
        # Alert tracking
        self._alert_notifications: Dict[str, List[AlertNotification]] = defaultdict(list)
        self._notification_history: Dict[str, deque] = defaultdict(lambda: deque(maxlen=1000))
        
        # Rate limiting
        self._notification_counts: Dict[str, Dict[str, int]] = defaultdict(lambda: defaultdict(int))
        self._last_reset_time: Dict[str, float] = defaultdict(float)
        
        # Background tasks
        self._processing_task: Optional[asyncio.Task] = None
        self._escalation_task: Optional[asyncio.Task] = None
        self._cleanup_task: Optional[asyncio.Task] = None
        self._running = False
        
        # Statistics
        self._stats = {
            'alerts_processed': 0,
            'notifications_sent': 0,
            'notifications_failed': 0,
            'escalations_triggered': 0,
            'active_alerts': 0
        }
        
        # Setup default notification senders
        self._setup_default_senders()
        
        # Setup alert handlers
        self._setup_alert_handlers()
    
    async def start(self):
        """Start real-time alert manager"""
        if self._running:
            return
        
        self._running = True
        self._processing_task = asyncio.create_task(self._processing_loop())
        self._escalation_task = asyncio.create_task(self._escalation_loop())
        self._cleanup_task = asyncio.create_task(self._cleanup_loop())
        
        logger.info("Real-time alert manager started")
    
    async def stop(self):
        """Stop real-time alert manager"""
        if not self._running:
            return
        
        self._running = False
        
        # Cancel background tasks
        for task in [self._processing_task, self._escalation_task, self._cleanup_task]:
            if task and not task.done():
                task.cancel()
                try:
                    await task
                except asyncio.CancelledError:
                    pass
        
        logger.info("Real-time alert manager stopped")
    
    def add_notification_channel(self, name: str, channel_config: NotificationConfig):
        """
        Add a notification channel
        
        Args:
            name: Channel name
            channel_config: Channel configuration
        """
        self._notification_configs[name] = channel_config
        logger.info(f"Added notification channel: {name}")
    
    def remove_notification_channel(self, name: str) -> bool:
        """
        Remove a notification channel
        
        Args:
            name: Channel name
            
        Returns:
            True if successfully removed
        """
        if name in self._notification_configs:
            del self._notification_configs[name]
            logger.info(f"Removed notification channel: {name}")
            return True
        return False
    
    def add_escalation_policy(self, policy: EscalationPolicy):
        """
        Add an escalation policy
        
        Args:
            policy: Escalation policy
        """
        self._escalation_policies[policy.policy_id] = policy
        logger.info(f"Added escalation policy: {policy.name}")
    
    def remove_escalation_policy(self, policy_id: str) -> bool:
        """
        Remove an escalation policy
        
        Args:
            policy_id: Policy ID
            
        Returns:
            True if successfully removed
        """
        if policy_id in self._escalation_policies:
            del self._escalation_policies[policy_id]
            logger.info(f"Removed escalation policy: {policy_id}")
            return True
        return False
    
    def get_notification_channels(self) -> Dict[str, NotificationConfig]:
        """Get all notification channels"""
        return self._notification_configs.copy()
    
    def get_escalation_policies(self) -> Dict[str, EscalationPolicy]:
        """Get all escalation policies"""
        return self._escalation_policies.copy()
    
    def get_alert_notifications(self, alert_id: str) -> List[AlertNotification]:
        """Get notifications for an alert"""
        return self._alert_notifications.get(alert_id, [])
    
    def get_notification_history(self, channel: str = None, limit: int = 100) -> List[AlertNotification]:
        """Get notification history"""
        if channel:
            history_key = channel
        else:
            history_key = "all"
        
        history = list(self._notification_history[history_key])
        
        # Return most recent notifications
        return history[-limit:] if limit > 0 else history
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get alerting statistics"""
        stats = self._stats.copy()
        
        # Add channel statistics
        stats['notification_channels'] = len(self._notification_configs)
        stats['escalation_policies'] = len(self._escalation_policies)
        
        # Add rate limiting statistics
        stats['rate_limits'] = {
            channel: {
                'hourly': counts.get('hourly', 0),
                'daily': counts.get('daily', 0)
            }
            for channel, counts in self._notification_counts.items()
        }
        
        return stats
    
    def _setup_default_senders(self):
        """Setup default notification senders"""
        self._notification_senders[NotificationChannel.EMAIL] = EmailNotificationSender({})
        self._notification_senders[NotificationChannel.SLACK] = SlackNotificationSender({})
        self._notification_senders[NotificationChannel.WEBHOOK] = WebhookNotificationSender({})
        self._notification_senders[NotificationChannel.LOG] = LogNotificationSender({})
    
    def _setup_alert_handlers(self):
        """Setup alert handlers"""
        # Register handlers with the base alert manager
        self.alert_manager.set_alert_triggered_handler(self._on_alert_triggered)
        self.alert_manager.set_alert_resolved_handler(self._on_alert_resolved)
    
    async def _on_alert_triggered(self, alert: Alert):
        """Handle alert triggered event"""
        try:
            # Update statistics
            self._stats['alerts_processed'] += 1
            self._stats['active_alerts'] += 1
            
            # Process alert
            await self._process_alert(alert)
            
        except Exception as e:
            logger.error(f"Failed to handle alert triggered: {e}")
    
    async def _on_alert_resolved(self, alert: Alert):
        """Handle alert resolved event"""
        try:
            # Update statistics
            self._stats['active_alerts'] = max(0, self._stats['active_alerts'] - 1)
            
            # Send resolution notifications
            await self._send_resolution_notifications(alert)
            
        except Exception as e:
            logger.error(f"Failed to handle alert resolved: {e}")
    
    async def _process_alert(self, alert: Alert):
        """Process an alert and send notifications"""
        # Check if alert should be notified
        if not self._should_notify(alert):
            return
        
        # Find applicable escalation policies
        applicable_policies = self._find_applicable_policies(alert)
        
        # Send initial notifications
        await self._send_initial_notifications(alert, applicable_policies)
    
    def _should_notify(self, alert: Alert) -> bool:
        """Check if alert should be notified"""
        # Check if alert is already being processed
        if alert.alert_id in self._alert_notifications:
            return False
        
        # Check if alert is in suppression period
        # (This would be implemented with actual suppression logic)
        
        return True
    
    def _find_applicable_policies(self, alert: Alert) -> List[EscalationPolicy]:
        """Find escalation policies that apply to an alert"""
        applicable_policies = []
        
        for policy in self._escalation_policies.values():
            # Check if policy conditions match alert
            if self._policy_matches_alert(policy, alert):
                applicable_policies.append(policy)
        
        # Sort by priority (if implemented)
        return applicable_policies
    
    def _policy_matches_alert(self, policy: EscalationPolicy, alert: Alert) -> bool:
        """Check if an escalation policy matches an alert"""
        conditions = policy.conditions
        
        # Check alert name
        if 'alert_names' in conditions:
            allowed_names = set(conditions['alert_names'])
            if alert.name not in allowed_names:
                return False
        
        # Check alert severity
        if 'min_severity' in conditions:
            min_severity = conditions['min_severity']
            severity_levels = {
                'info': 1,
                'warning': 2,
                'error': 3,
                'critical': 4
            }
            
            if severity_levels.get(alert.severity.value, 0) < severity_levels.get(min_severity, 0):
                return False
        
        # Check alert labels
        if 'labels' in conditions:
            required_labels = conditions['labels']
            for key, value in required_labels.items():
                # This would check if alert has matching labels
                pass
        
        return True
    
    async def _send_initial_notifications(self, alert: Alert, policies: List[EscalationPolicy]):
        """Send initial notifications for an alert"""
        # Get notification channels for initial alert
        channels = self._get_notification_channels_for_alert(alert, policies, 0)
        
        # Send notifications
        for channel_name, channel_config in channels.items():
            if not channel_config.enabled:
                continue
            
            # Check rate limiting
            if not self._check_rate_limit(channel_name):
                continue
            
            # Create notification
            notification = self._create_notification(alert, channel_config)
            
            # Send notification
            success = await self._send_notification(notification)
            
            if success:
                self._stats['notifications_sent'] += 1
            else:
                self._stats['notifications_failed'] += 1
            
            # Track notification
            self._alert_notifications[alert.alert_id].append(notification)
            self._notification_history[channel_name].append(notification)
            self._notification_history["all"].append(notification)
    
    async def _send_resolution_notifications(self, alert: Alert):
        """Send notifications when an alert is resolved"""
        # Get notification channels that were used for this alert
        alert_notifications = self._alert_notifications.get(alert.alert_id, [])
        
        # Group by channel
        channels_used = set()
        for notification in alert_notifications:
            channels_used.add(notification.channel.value)
        
        # Send resolution notifications
        for channel_name in channels_used:
            channel_config = self._notification_configs.get(channel_name)
            if not channel_config or not channel_config.enabled:
                continue
            
            # Check rate limiting
            if not self._check_rate_limit(channel_name):
                continue
            
            # Create resolution notification
            notification = self._create_resolution_notification(alert, channel_config)
            
            # Send notification
            success = await self._send_notification(notification)
            
            if success:
                self._stats['notifications_sent'] += 1
            else:
                self._stats['notifications_failed'] += 1
            
            # Track notification
            self._alert_notifications[alert.alert_id].append(notification)
            self._notification_history[channel_name].append(notification)
            self._notification_history["all"].append(notification)
    
    def _get_notification_channels_for_alert(self, alert: Alert, policies: List[EscalationPolicy], escalation_level: int) -> Dict[str, NotificationConfig]:
        """Get notification channels for an alert at a specific escalation level"""
        channels = {}
        
        # Add channels from escalation policies
        for policy in policies:
            if escalation_level < len(policy.rules):
                rule = policy.rules[escalation_level]
                
                # Get channels from rule
                rule_channels = rule.get('channels', [])
                for channel_name in rule_channels:
                    if channel_name in self._notification_configs:
                        channels[channel_name] = self._notification_configs[channel_name]
        
        # If no channels from policies, use default channels
        if not channels:
            for name, config in self._notification_configs.items():
                # Check if alert severity meets minimum
                severity_levels = {
                    'info': 1,
                    'warning': 2,
                    'error': 3,
                    'critical': 4
                }
                
                alert_level = severity_levels.get(alert.severity.value, 0)
                min_level = severity_levels.get(config.min_severity.value, 0)
                
                if alert_level >= min_level and config.enabled:
                    channels[name] = config
        
        return channels
    
    def _check_rate_limit(self, channel_name: str) -> bool:
        """Check if channel is within rate limits"""
        if channel_name not in self._notification_configs:
            return False
        
        config = self._notification_configs[channel_name]
        current_time = time.time()
        
        # Reset counters if needed
        last_reset = self._last_reset_time[channel_name]
        
        # Reset hourly counter
        if current_time - last_reset > 3600:  # 1 hour
            self._notification_counts[channel_name]['hourly'] = 0
            self._last_reset_time[channel_name] = current_time
        
        # Reset daily counter
        if current_time - last_reset > 86400:  # 24 hours
            self._notification_counts[channel_name]['daily'] = 0
        
        # Check limits
        hourly_count = self._notification_counts[channel_name]['hourly']
        daily_count = self._notification_counts[channel_name]['daily']
        
        if hourly_count >= config.max_notifications_per_hour:
            logger.warning(f"Hourly rate limit exceeded for channel {channel_name}")
            return False
        
        if daily_count >= config.max_notifications_per_day:
            logger.warning(f"Daily rate limit exceeded for channel {channel_name}")
            return False
        
        # Increment counters
        self._notification_counts[channel_name]['hourly'] += 1
        self._notification_counts[channel_name]['daily'] += 1
        
        return True
    
    def _create_notification(self, alert: Alert, channel_config: NotificationConfig) -> AlertNotification:
        """Create a notification for an alert"""
        # Create subject and message based on channel type
        if channel_config.channel_type == NotificationChannel.EMAIL:
            subject = f"[NoodleNet Alert] {alert.name} ({alert.severity.value.upper()})"
            message = self._create_email_message(alert)
        elif channel_config.channel_type == NotificationChannel.SLACK:
            subject = f"Alert: {alert.name}"
            message = self._create_slack_message(alert)
        elif channel_config.channel_type == NotificationChannel.WEBHOOK:
            subject = f"Alert: {alert.name}"
            message = self._create_webhook_message(alert)
        else:  # LOG
            subject = f"Alert: {alert.name}"
            message = self._create_log_message(alert)
        
        # Determine recipient
        recipient = channel_config.config.get('recipient', '')
        
        # Create notification
        notification = AlertNotification(
            alert_id=alert.alert_id,
            channel=channel_config.channel_type,
            recipient=recipient,
            subject=subject,
            message=message,
            metadata={
                'alert_name': alert.name,
                'severity': alert.severity.value,
                'description': alert.description,
                'condition': alert.condition,
                'triggered_at': alert.triggered_at
            }
        )
        
        return notification
    
    def _create_resolution_notification(self, alert: Alert, channel_config: NotificationConfig) -> AlertNotification:
        """Create a resolution notification for an alert"""
        # Create subject and message based on channel type
        if channel_config.channel_type == NotificationChannel.EMAIL:
            subject = f"[NoodleNet Resolved] {alert.name}"
            message = self._create_email_resolution_message(alert)
        elif channel_config.channel_type == NotificationChannel.SLACK:
            subject = f"Resolved: {alert.name}"
            message = self._create_slack_resolution_message(alert)
        elif channel_config.channel_type == NotificationChannel.WEBHOOK:
            subject = f"Resolved: {alert.name}"
            message = self._create_webhook_resolution_message(alert)
        else:  # LOG
            subject = f"Resolved: {alert.name}"
            message = self._create_log_resolution_message(alert)
        
        # Determine recipient
        recipient = channel_config.config.get('recipient', '')
        
        # Create notification
        notification = AlertNotification(
            alert_id=alert.alert_id,
            channel=channel_config.channel_type,
            recipient=recipient,
            subject=subject,
            message=message,
            metadata={
                'alert_name': alert.name,
                'severity': alert.severity.value,
                'description': alert.description,
                'resolved_at': alert.resolved_at,
                'resolution': True
            }
        )
        
        return notification
    
    def _create_email_message(self, alert: Alert) -> str:
        """Create email message for alert"""
        return f"""
        <html>
        <body>
            <h2>Alert: {alert.name}</h2>
            <p><strong>Severity:</strong> {alert.severity.value.upper()}</p>
            <p><strong>Description:</strong> {alert.description}</p>
            <p><strong>Condition:</strong> {alert.condition}</p>
            <p><strong>Triggered at:</strong> {time.ctime(alert.triggered_at) if alert.triggered_at else 'Unknown'}</p>
            <p><strong>Trigger count:</strong> {alert.trigger_count}</p>
            <hr>
            <p><small>This alert was generated by NoodleNet distributed system.</small></p>
        </body>
        </html>
        """
    
    def _create_slack_message(self, alert: Alert) -> str:
        """Create Slack message for alert"""
        return f"""
        *Alert: {alert.name}*
        
        *Severity:* {alert.severity.value.upper()}
        *Description:* {alert.description}
        *Condition:* {alert.condition}
        *Triggered at:* {time.ctime(alert.triggered_at) if alert.triggered_at else 'Unknown'}
        *Trigger count:* {alert.trigger_count}
        """
    
    def _create_webhook_message(self, alert: Alert) -> str:
        """Create webhook message for alert"""
        return json.dumps({
            'alert_name': alert.name,
            'severity': alert.severity.value,
            'description': alert.description,
            'condition': alert.condition,
            'triggered_at': alert.triggered_at,
            'trigger_count': alert.trigger_count
        })
    
    def _create_log_message(self, alert: Alert) -> str:
        """Create log message for alert"""
        return f"ALERT [{alert.severity.value.upper()}] {alert.name}: {alert.description} (Condition: {alert.condition}, Triggered: {time.ctime(alert.triggered_at) if alert.triggered_at else 'Unknown'})"
    
    def _create_email_resolution_message(self, alert: Alert) -> str:
        """Create email resolution message"""
        return f"""
        <html>
        <body>
            <h2>Alert Resolved: {alert.name}</h2>
            <p><strong>Severity:</strong> {alert.severity.value.upper()}</p>
            <p><strong>Description:</strong> {alert.description}</p>
            <p><strong>Resolved at:</strong> {time.ctime(alert.resolved_at) if alert.resolved_at else 'Unknown'}</p>
            <p><strong>Duration:</strong> {alert.resolved_at - alert.triggered_at:.2f} seconds</p>
            <hr>
            <p><small>This resolution was generated by NoodleNet distributed system.</small></p>
        </body>
        </html>
        """
    
    def _create_slack_resolution_message(self, alert: Alert) -> str:
        """Create Slack resolution message"""
        return f"""
        *Alert Resolved: {alert.name}*
        
        *Severity:* {alert.severity.value.upper()}
        *Description:* {alert.description}
        *Resolved at:* {time.ctime(alert.resolved_at) if alert.resolved_at else 'Unknown'}
        *Duration:* {alert.resolved_at - alert.triggered_at:.2f} seconds
        """
    
    def _create_webhook_resolution_message(self, alert: Alert) -> str:
        """Create webhook resolution message"""
        return json.dumps({
            'alert_name': alert.name,
            'severity': alert.severity.value,
            'description': alert.description,
            'resolved_at': alert.resolved_at,
            'duration': alert.resolved_at - alert.triggered_at if alert.resolved_at and alert.triggered_at else None,
            'resolution': True
        })
    
    def _create_log_resolution_message(self, alert: Alert) -> str:
        """Create log resolution message"""
        return f"ALERT RESOLVED [{alert.severity.value.upper()}] {alert.name}: {alert.description} (Resolved: {time.ctime(alert.resolved_at) if alert.resolved_at else 'Unknown'})"
    
    async def _send_notification(self, notification: AlertNotification) -> bool:
        """Send a notification"""
        try:
            # Get sender for channel
            sender = self._notification_senders.get(notification.channel)
            if not sender:
                logger.error(f"No sender found for channel {notification.channel}")
                return False
            
            # Update status
            notification.status = AlertStatus.OPEN
            notification.sent_at = time.time()
            
            # Send notification
            success = await sender.send_notification(notification)
            
            if success:
                notification.status = AlertStatus.OPEN
            else:
                notification.status = AlertStatus.SUPPRESSED
            
            return success
            
        except Exception as e:
            logger.error(f"Failed to send notification: {e}")
            notification.status = AlertStatus.SUPPRESSED
            return False
    
    async def _processing_loop(self):
        """Main processing loop for alerts"""
        while self._running:
            try:
                # Process any pending alerts
                # (This would check for new alerts from the base alert manager)
                
                await asyncio.sleep(1)  # Check every second
                
            except Exception as e:
                logger.error(f"Error in alert processing loop: {e}")
                await asyncio.sleep(5)
    
    async def _escalation_loop(self):
        """Escalation loop for alerts"""
        while self._running:
            try:
                # Check for alerts that need escalation
                current_time = time.time()
                
                for alert_id, notifications in self._alert_notifications.items():
                    if not notifications:
                        continue
                    
                    # Get the alert
                    alert = self.alert_manager.get_alert(alert_id)
                    if not alert or not alert.active:
                        continue
                    
                    # Find applicable policies
                    policies = self._find_applicable_policies(alert)
                    
                    # Check if escalation is needed
                    for policy in policies:
                        await self._check_escalation(alert, policy, current_time)
                
                await asyncio.sleep(60)  # Check every minute
                
            except Exception as e:
                logger.error(f"Error in escalation loop: {e}")
                await asyncio.sleep(30)
    
    async def _check_escalation(self, alert: Alert, policy: EscalationPolicy, current_time: float):
        """Check if an alert should be escalated"""
        # Check if alert has been active long enough
        if not alert.triggered_at:
            return
        
        time_active = current_time - alert.triggered_at
        
        # Calculate current escalation level
        escalation_level = int(time_active / policy.escalation_interval)
        
        # Check if we've exceeded max escalations
        if escalation_level >= policy.max_escalations:
            return
        
        # Check if we've already escalated to this level
        notifications = self._alert_notifications.get(alert.alert_id, [])
        
        # Count notifications by escalation level
        escalation_notifications = 0
        for notification in notifications:
            if notification.metadata.get('escalation_level') == escalation_level:
                escalation_notifications += 1
        
        if escalation_notifications > 0:
            return  # Already escalated to this level
        
        # Escalate alert
        await self._escalate_alert(alert, policy, escalation_level)
    
    async def _escalate_alert(self, alert: Alert, policy: EscalationPolicy, escalation_level: int):
        """Escalate an alert to the next level"""
        try:
            # Update statistics
            self._stats['escalations_triggered'] += 1
            
            # Get notification channels for this escalation level
            channels = self._get_notification_channels_for_alert(alert, [policy], escalation_level)
            
            # Send escalation notifications
            for channel_name, channel_config in channels.items():
                if not channel_config.enabled:
                    continue
                
                # Check rate limiting
                if not self._check_rate_limit(channel_name):
                    continue
                
                # Create escalation notification
                notification = self._create_escalation_notification(alert, channel_config, escalation_level)
                
                # Send notification
                success = await self._send_notification(notification)
                
                if success:
                    self._stats['notifications_sent'] += 1
                else:
                    self._stats['notifications_failed'] += 1
                
                # Track notification
                self._alert_notifications[alert.alert_id].append(notification)
                self._notification_history[channel_name].append(notification)
                self._notification_history["all"].append(notification)
            
            logger.info(f"Escalated alert {alert.name} to level {escalation_level}")
            
        except Exception as e:
            logger.error(f"Failed to escalate alert {alert.name}: {e}")
    
    def _create_escalation_notification(self, alert: Alert, channel_config: NotificationConfig, escalation_level: int) -> AlertNotification:
        """Create an escalation notification"""
        # Create subject and message based on channel type
        if channel_config.channel_type == NotificationChannel.EMAIL:
            subject = f"[NoodleNet Escalation {escalation_level}] {alert.name} ({alert.severity.value.upper()})"
            message = self._create_email_escalation_message(alert, escalation_level)
        elif channel_config.channel_type == NotificationChannel.SLACK:
            subject = f"Escalation {escalation_level}: {alert.name}"
            message = self._create_slack_escalation_message(alert, escalation_level)
        elif channel_config.channel_type == NotificationChannel.WEBHOOK:
            subject = f"Escalation {escalation_level}: {alert.name}"
            message = self._create_webhook_escalation_message(alert, escalation_level)
        else:  # LOG
            subject = f"Escalation {escalation_level}: {alert.name}"
            message = self._create_log_escalation_message(alert, escalation_level)
        
        # Determine recipient
        recipient = channel_config.config.get('recipient', '')
        
        # Create notification
        notification = AlertNotification(
            alert_id=alert.alert_id,
            channel=channel_config.channel_type,
            recipient=recipient,
            subject=subject,
            message=message,
            metadata={
                'alert_name': alert.name,
                'severity': alert.severity.value,
                'description': alert.description,
                'escalation_level': escalation_level,
                'triggered_at': alert.triggered_at
            }
        )
        
        return notification
    
    def _create_email_escalation_message(self, alert: Alert, escalation_level: int) -> str:
        """Create email escalation message"""
        return f"""
        <html>
        <body>
            <h2>Alert Escalation (Level {escalation_level}): {alert.name}</h2>
            <p><strong>Severity:</strong> {alert.severity.value.upper()}</p>
            <p><strong>Description:</strong> {alert.description}</p>
            <p><strong>Condition:</strong> {alert.condition}</p>
            <p><strong>Triggered at:</strong> {time.ctime(alert.triggered_at) if alert.triggered_at else 'Unknown'}</p>
            <p><strong>Trigger count:</strong> {alert.trigger_count}</p>
            <p><strong>Escalation level:</strong> {escalation_level}</p>
            <hr>
            <p><small>This escalation was generated by NoodleNet distributed system.</small></p>
        </body>
        </html>
        """
    
    def _create_slack_escalation_message(self, alert: Alert, escalation_level: int) -> str:
        """Create Slack escalation message"""
        return f"""
        *Alert Escalation (Level {escalation_level}): {alert.name}*
        
        *Severity:* {alert.severity.value.upper()}
        *Description:* {alert.description}
        *Condition:* {alert.condition}
        *Triggered at:* {time.ctime(alert.triggered_at) if alert.triggered_at else 'Unknown'}
        *Trigger count:* {alert.trigger_count}
        *Escalation level:* {escalation_level}
        """
    
    def _create_webhook_escalation_message(self, alert: Alert, escalation_level: int) -> str:
        """Create webhook escalation message"""
        return json.dumps({
            'alert_name': alert.name,
            'severity': alert.severity.value,
            'description': alert.description,
            'condition': alert.condition,
            'triggered_at': alert.triggered_at,
            'trigger_count': alert.trigger_count,
            'escalation_level': escalation_level
        })
    
    def _create_log_escalation_message(self, alert: Alert, escalation_level: int) -> str:
        """Create log escalation message"""
        return f"ALERT ESCALATION [{alert.severity.value.upper()}] Level {escalation_level} {alert.name}: {alert.description} (Condition: {alert.condition}, Triggered: {time.ctime(alert.triggered_at) if alert.triggered_at else 'Unknown'})"
    
    async def _cleanup_loop(self):
        """Cleanup loop for old notifications"""
        while self._running:
            try:
                # Clean up old notifications
                current_time = time.time()
                
                # Clean up resolved alert notifications after 24 hours
                for alert_id, notifications in list(self._alert_notifications.items()):
                    # Check if alert is resolved
                    alert = self.alert_manager.get_alert(alert_id)
                    if alert and not alert.active:
                        # Check if resolved more than 24 hours ago
                        if alert.resolved_at and (current_time - alert.resolved_at) > 86400:
                            del self._alert_notifications[alert_id]
                
                await asyncio.sleep(3600)  # Check every hour
                
            except Exception as e:
                logger.error(f"Error in cleanup loop: {e}")
                await asyncio.sleep(300)  # Retry after 5 minutes

