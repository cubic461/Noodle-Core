# Converted from Python to NoodleCore
# Original file: src

# """
# Mobile API Notifications Module
# --------------------------------

# Handles notification endpoints for push notifications and event streaming
from the NoodleControl mobile app.
# """

import json
import logging
import os
import time
import uuid
import datetime.datetime
import typing.Any

import .errors.(
#     InvalidRequestError,
#     ValidationError,
# )

logger = logging.getLogger(__name__)


class NotificationManager
    #     """
    #     Manages notifications for mobile API including push notifications,
    #     event streaming, and alert management.
    #     """

    #     def __init__(self, redis_client=None, push_service_config: Optional[Dict[str, Any]] = None):""
    #         Initialize NotificationManager.

    #         Args:
    #             redis_client: Redis client for pub/sub and caching
    #             push_service_config: Configuration for push notification services
    #         """
    self.redis = redis_client
    self.push_service_config = push_service_config or {}
    self.notification_queue: List[Dict[str, Any]] = []
    self.event_subscribers: Dict[str, List[str]] = {}  # event_type - [device_ids]
    self.alert_rules): List[Dict[str, Any]] = []

    #         # Load default alert rules
            self._load_default_alert_rules()

    #     def send_notification(self, device_id: str, notification: Dict[str, Any]) -Dict[str, Any]):
    #         """
    #         Send a notification to a specific device.

    #         Args:
    #             device_id: Target device ID
    #             notification: Notification content

    #         Returns:
    #             Dictionary containing notification result
    #         """
    #         try:
    #             # Validate notification
                self._validate_notification(notification)

    #             # Create notification object
    notification_obj = {
                    "id": str(uuid.uuid4()),
    #                 "device_id": device_id,
                    "title": notification.get("title", ""),
                    "body": notification.get("body", ""),
                    "data": notification.get("data", {}),
                    "type": notification.get("type", "info"),
                    "priority": notification.get("priority", "normal"),
                    "created_at": datetime.now().isoformat(),
    #                 "read": False,
    #             }

    #             # Send via push notification service
    push_result = self._send_push_notification(device_id, notification_obj)

    #             # Store notification
                self._store_notification(notification_obj)

    #             # Publish to Redis for real-time updates
    #             if self.redis:
                    self.redis.publish(f"notifications:{device_id}", json.dumps(notification_obj))

    #             return {
    #                 "notification_id": notification_obj["id"],
    #                 "device_id": device_id,
    #                 "status": "sent",
    #                 "push_result": push_result,
    #                 "sent_at": notification_obj["created_at"],
    #             }
    #         except Exception as e:
                logger.error(f"Failed to send notification: {e}")
                raise InvalidRequestError(f"Failed to send notification: {e}")

    #     def broadcast_notification(self, notification: Dict[str, Any], device_filter: Optional[Dict[str, Any]] = None) -Dict[str, Any]):
    #         """
    #         Broadcast a notification to multiple devices.

    #         Args:
    #             notification: Notification content
    #             device_filter: Optional filter to target specific devices

    #         Returns:
    #             Dictionary containing broadcast result
    #         """
    #         try:
    #             # Validate notification
                self._validate_notification(notification)

    #             # Get target devices
    target_devices = self._get_target_devices(device_filter)

    #             if not target_devices:
                    raise ValidationError("No target devices found")

    #             # Create notification object
    notification_obj = {
                    "id": str(uuid.uuid4()),
                    "title": notification.get("title", ""),
                    "body": notification.get("body", ""),
                    "data": notification.get("data", {}),
                    "type": notification.get("type", "info"),
                    "priority": notification.get("priority", "normal"),
                    "created_at": datetime.now().isoformat(),
    #                 "broadcast": True,
    #             }

    #             # Send to all target devices
    results = []
    #             for device_id in target_devices:
    device_notification = notification_obj.copy()
    device_notification["device_id"] = device_id

    #                 # Send via push notification service
    push_result = self._send_push_notification(device_id, device_notification)

    #                 # Store notification
                    self._store_notification(device_notification)

    #                 # Publish to Redis for real-time updates
    #                 if self.redis:
                        self.redis.publish(f"notifications:{device_id}", json.dumps(device_notification))

                    results.append({
    #                     "device_id": device_id,
    #                     "status": "sent",
    #                     "push_result": push_result,
    #                 })

    #             return {
    #                 "notification_id": notification_obj["id"],
                    "target_devices": len(target_devices),
    #                 "results": results,
    #                 "broadcast_at": notification_obj["created_at"],
    #             }
    #         except Exception as e:
                logger.error(f"Failed to broadcast notification: {e}")
                raise InvalidRequestError(f"Failed to broadcast notification: {e}")

    #     def get_notifications(self, device_id: str, limit: int = 50, offset: int = 0, unread_only: bool = False) -Dict[str, Any]):
    #         """
    #         Get notifications for a specific device.

    #         Args:
    #             device_id: Device ID
    #             limit: Maximum number of notifications to return
    #             offset: Number of notifications to skip
    #             unread_only: Whether to return only unread notifications

    #         Returns:
    #             Dictionary containing notifications and metadata
    #         """
    #         try:
    #             # Get notifications from storage
    notifications = self._get_device_notifications(device_id)

    #             # Filter by unread status if requested
    #             if unread_only:
    #                 notifications = [n for n in notifications if not n.get("read", False)]

                # Sort by creation time (newest first)
    notifications.sort(key = lambda x: x.get("created_at", ""), reverse=True)

    #             # Apply pagination
    total = len(notifications)
    paginated_notifications = notifications[offset:offset + limit]

    #             return {
    #                 "device_id": device_id,
    #                 "notifications": paginated_notifications,
    #                 "total": total,
    #                 "unread_count": sum(1 for n in notifications if not n.get("read", False)),
    #                 "limit": limit,
    #                 "offset": offset,
    #             }
    #         except Exception as e:
                logger.error(f"Failed to get notifications: {e}")
                raise InvalidRequestError(f"Failed to get notifications: {e}")

    #     def mark_notification_read(self, device_id: str, notification_id: str) -bool):
    #         """
    #         Mark a notification as read.

    #         Args:
    #             device_id: Device ID
    #             notification_id: Notification ID

    #         Returns:
    #             True if notification was successfully marked as read
    #         """
    #         try:
    #             # Update notification in storage
    success = self._update_notification_status(device_id, notification_id, True)

    #             if success and self.redis:
    #                 # Publish update to Redis
    update_data = {
    #                     "notification_id": notification_id,
    #                     "device_id": device_id,
    #                     "read": True,
                        "updated_at": datetime.now().isoformat(),
    #                 }
                    self.redis.publish(f"notification_updates:{device_id}", json.dumps(update_data))

    #             return success
    #         except Exception as e:
                logger.error(f"Failed to mark notification as read: {e}")
    #             return False

    #     def mark_all_notifications_read(self, device_id: str) -int):
    #         """
    #         Mark all notifications for a device as read.

    #         Args:
    #             device_id: Device ID

    #         Returns:
    #             Number of notifications marked as read
    #         """
    #         try:
    #             # Get all unread notifications
    notifications = self._get_device_notifications(device_id)
    #             unread_notifications = [n for n in notifications if not n.get("read", False)]

    #             # Mark each as read
    count = 0
    #             for notification in unread_notifications:
    #                 if self._update_notification_status(device_id, notification["id"], True):
    count + = 1

    #             if count 0 and self.redis):
    #                 # Publish update to Redis
    update_data = {
    #                     "device_id": device_id,
    #                     "all_read": True,
    #                     "count": count,
                        "updated_at": datetime.now().isoformat(),
    #                 }
                    self.redis.publish(f"notification_updates:{device_id}", json.dumps(update_data))

    #             return count
    #         except Exception as e:
                logger.error(f"Failed to mark all notifications as read: {e}")
    #             return 0

    #     def delete_notification(self, device_id: str, notification_id: str) -bool):
    #         """
    #         Delete a notification.

    #         Args:
    #             device_id: Device ID
    #             notification_id: Notification ID

    #         Returns:
    #             True if notification was successfully deleted
    #         """
    #         try:
    #             # Delete notification from storage
    success = self._delete_notification(device_id, notification_id)

    #             if success and self.redis:
    #                 # Publish deletion to Redis
    delete_data = {
    #                     "notification_id": notification_id,
    #                     "device_id": device_id,
    #                     "deleted": True,
                        "deleted_at": datetime.now().isoformat(),
    #                 }
                    self.redis.publish(f"notification_updates:{device_id}", json.dumps(delete_data))

    #             return success
    #         except Exception as e:
                logger.error(f"Failed to delete notification: {e}")
    #             return False

    #     def subscribe_to_events(self, device_id: str, event_types: List[str]) -Dict[str, Any]):
    #         """
    #         Subscribe a device to specific event types.

    #         Args:
    #             device_id: Device ID
    #             event_types: List of event types to subscribe to

    #         Returns:
    #             Dictionary containing subscription result
    #         """
    #         try:
    #             # Validate event types
    valid_event_types = [
    #                 "execution_started", "execution_completed", "execution_failed",
    #                 "node_joined", "node_left", "node_error",
    #                 "reasoning_started", "reasoning_completed", "reasoning_failed",
    #                 "system_alert", "performance_warning", "security_alert"
    #             ]

    #             for event_type in event_types:
    #                 if event_type not in valid_event_types:
                        raise ValidationError(f"Invalid event type: {event_type}")

    #             # Add device to subscriber lists
    #             for event_type in event_types:
    #                 if event_type not in self.event_subscribers:
    self.event_subscribers[event_type] = []

    #                 if device_id not in self.event_subscribers[event_type]:
                        self.event_subscribers[event_type].append(device_id)

    #             # Store subscription in Redis if available
    #             if self.redis:
    #                 for event_type in event_types:
                        self.redis.sadd(f"event_subscribers:{event_type}", device_id)

    #             return {
    #                 "device_id": device_id,
    #                 "subscribed_events": event_types,
                    "subscribed_at": datetime.now().isoformat(),
    #             }
    #         except Exception as e:
                logger.error(f"Failed to subscribe to events: {e}")
                raise InvalidRequestError(f"Failed to subscribe to events: {e}")

    #     def unsubscribe_from_events(self, device_id: str, event_types: List[str]) -Dict[str, Any]):
    #         """
    #         Unsubscribe a device from specific event types.

    #         Args:
    #             device_id: Device ID
    #             event_types: List of event types to unsubscribe from

    #         Returns:
    #             Dictionary containing unsubscription result
    #         """
    #         try:
    #             # Remove device from subscriber lists
    #             for event_type in event_types:
    #                 if event_type in self.event_subscribers:
    #                     if device_id in self.event_subscribers[event_type]:
                            self.event_subscribers[event_type].remove(device_id)

    #             # Remove subscription from Redis if available
    #             if self.redis:
    #                 for event_type in event_types:
                        self.redis.srem(f"event_subscribers:{event_type}", device_id)

    #             return {
    #                 "device_id": device_id,
    #                 "unsubscribed_events": event_types,
                    "unsubscribed_at": datetime.now().isoformat(),
    #             }
    #         except Exception as e:
                logger.error(f"Failed to unsubscribe from events: {e}")
                raise InvalidRequestError(f"Failed to unsubscribe from events: {e}")

    #     def trigger_alert(self, alert_type: str, message: str, data: Optional[Dict[str, Any]] = None, severity: str = "warning") -Dict[str, Any]):
    #         """
    #         Trigger an alert that will be sent to subscribed devices.

    #         Args:
    #             alert_type: Type of alert
    #             message: Alert message
    #             data: Additional alert data
                severity: Alert severity (info, warning, error, critical)

    #         Returns:
    #             Dictionary containing alert result
    #         """
    #         try:
    #             # Validate alert
    #             if not alert_type or not message:
                    raise ValidationError("Alert type and message are required")

    valid_severities = ["info", "warning", "error", "critical"]
    #             if severity not in valid_severities:
                    raise ValidationError(f"Invalid severity. Valid values: {', '.join(valid_severities)}")

    #             # Create alert object
    alert = {
                    "id": str(uuid.uuid4()),
    #                 "type": alert_type,
    #                 "message": message,
    #                 "data": data or {},
    #                 "severity": severity,
                    "created_at": datetime.now().isoformat(),
    #             }

    #             # Get subscribers for system_alert events
    subscribers = self.event_subscribers.get("system_alert", [])

    #             # Send alert to subscribers
    results = []
    #             for device_id in subscribers:
    notification = {
    #                     "title": f"System Alert: {alert_type}",
    #                     "body": message,
    #                     "data": alert,
    #                     "type": "alert",
    #                     "priority": "high" if severity in ["error", "critical"] else "normal",
    #                 }

    #                 try:
    result = self.send_notification(device_id, notification)
                        results.append(result)
    #                 except Exception as e:
                        logger.error(f"Failed to send alert to device {device_id}: {e}")
                        results.append({
    #                         "device_id": device_id,
    #                         "status": "failed",
                            "error": str(e),
    #                     })

    #             return {
    #                 "alert_id": alert["id"],
    #                 "type": alert_type,
    #                 "severity": severity,
                    "subscribers_notified": len(subscribers),
    #                 "results": results,
    #                 "triggered_at": alert["created_at"],
    #             }
    #         except Exception as e:
                logger.error(f"Failed to trigger alert: {e}")
                raise InvalidRequestError(f"Failed to trigger alert: {e}")

    #     def _validate_notification(self, notification: Dict[str, Any]):
    #         """Validate notification content."""
    #         if not notification.get("title") and not notification.get("body"):
                raise ValidationError("Notification must have either title or body")

    valid_types = ["info", "success", "warning", "error", "alert"]
    notification_type = notification.get("type", "info")
    #         if notification_type not in valid_types:
                raise ValidationError(f"Invalid notification type. Valid values: {', '.join(valid_types)}")

    valid_priorities = ["low", "normal", "high", "urgent"]
    priority = notification.get("priority", "normal")
    #         if priority not in valid_priorities:
                raise ValidationError(f"Invalid priority. Valid values: {', '.join(valid_priorities)}")

    #     def _send_push_notification(self, device_id: str, notification: Dict[str, Any]) -Dict[str, Any]):
    #         """Send push notification via push service."""
    #         # This would integrate with actual push notification services
    #         # like Firebase Cloud Messaging, Apple Push Notification Service, etc.

    #         # For now, return a mock result
    #         return {
    #             "service": "mock_push_service",
    #             "status": "success",
                "message_id": f"msg_{uuid.uuid4().hex[:8]}",
    #         }

    #     def _store_notification(self, notification: Dict[str, Any]):
    #         """Store notification in database or cache."""
    #         # Store in Redis if available
    #         if self.redis:
    key = f"notifications:{notification['device_id']}:{notification['id']}"
                self.redis.setex(
    #                 key,
    #                 timedelta(days=30),  # Keep for 30 days
                    json.dumps(notification)
    #             )

    #             # Add to device notification list
    list_key = f"notification_list:{notification['device_id']}"
                self.redis.lpush(list_key, notification["id"])
                self.redis.ltrim(list_key, 0, 999)  # Keep only last 1000 notifications
    #         else:
    #             # Fallback to in-memory storage
                self.notification_queue.append(notification)

    #     def _get_device_notifications(self, device_id: str) -List[Dict[str, Any]]):
    #         """Get notifications for a device from storage."""
    notifications = []

    #         # Get from Redis if available
    #         if self.redis:
    list_key = f"notification_list:{device_id}"
    notification_ids = self.redis.lrange(list_key - 0,, 1)

    #             for notification_id in notification_ids:
    notification_id = notification_id.decode('utf-8')
    key = f"notifications:{device_id}:{notification_id}"
    notification_data = self.redis.get(key)

    #                 if notification_data:
    #                     try:
    notification = json.loads(notification_data.decode('utf-8'))
                            notifications.append(notification)
    #                     except json.JSONDecodeError:
                            logger.error(f"Failed to parse notification {notification_id}")
    #         else:
    #             # Fallback to in-memory storage
    #             notifications = [n for n in self.notification_queue if n.get("device_id") == device_id]

    #         return notifications

    #     def _update_notification_status(self, device_id: str, notification_id: str, read: bool) -bool):
    #         """Update notification read status."""
    #         try:
    #             # Update in Redis if available
    #             if self.redis:
    key = f"notifications:{device_id}:{notification_id}"
    notification_data = self.redis.get(key)

    #                 if notification_data:
    notification = json.loads(notification_data.decode('utf-8'))
    notification["read"] = read
    notification["updated_at"] = datetime.now().isoformat()

                        self.redis.setex(
    #                         key,
    timedelta(days = 30),
                            json.dumps(notification)
    #                     )
    #                     return True
    #             else:
    #                 # Fallback to in-memory storage
    #                 for notification in self.notification_queue:
    #                     if (notification.get("device_id") == device_id and
    notification.get("id") = = notification_id):
    notification["read"] = read
    notification["updated_at"] = datetime.now().isoformat()
    #                         return True

    #             return False
    #         except Exception as e:
                logger.error(f"Failed to update notification status: {e}")
    #             return False

    #     def _delete_notification(self, device_id: str, notification_id: str) -bool):
    #         """Delete a notification."""
    #         try:
    #             # Delete from Redis if available
    #             if self.redis:
    key = f"notifications:{device_id}:{notification_id}"
    result = self.redis.delete(key)

    #                 if result 0):
    #                     # Remove from notification list
    list_key = f"notification_list:{device_id}"
                        self.redis.lrem(list_key, 0, notification_id)
    #                     return True
    #             else:
    #                 # Fallback to in-memory storage
    #                 for i, notification in enumerate(self.notification_queue):
    #                     if (notification.get("device_id") == device_id and
    notification.get("id") = = notification_id):
    #                         del self.notification_queue[i]
    #                         return True

    #             return False
    #         except Exception as e:
                logger.error(f"Failed to delete notification: {e}")
    #             return False

    #     def _get_target_devices(self, device_filter: Optional[Dict[str, Any]]) -List[str]):
    #         """Get target devices based on filter."""
    #         # This would typically query the database for devices
    #         # For now, return mock device IDs
    #         return ["device-001", "device-002", "device-003"]

    #     def _load_default_alert_rules(self):
    #         """Load default alert rules."""
    self.alert_rules = [
    #             {
    #                 "name": "High CPU Usage",
    #                 "condition": "cpu_usage 80",
    #                 "severity"): "warning",
    #                 "enabled": True,
    #             },
    #             {
    #                 "name": "High Memory Usage",
    #                 "condition": "memory_usage 90",
    #                 "severity"): "error",
    #                 "enabled": True,
    #             },
    #             {
    #                 "name": "Node Down",
    "condition": "node_status = = 'down'",
    #                 "severity": "critical",
    #                 "enabled": True,
    #             },
    #         ]