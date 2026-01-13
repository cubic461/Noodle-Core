# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Error Monitoring Integration Module
# ----------------------------------

# This module provides integration between the error_handler.py metrics and
# external monitoring systems. It enables real-time error tracking, alerting,
# and dashboard integration for the Noodle runtime.

# Key features:
# - REST API for error metrics access
# - WebSocket support for real-time error notifications
# - Prometheus metrics endpoint
# - Dashboard integration endpoints
# - Alert management system
# """

import json
import threading
import time
import datetime.datetime,
import typing.Any,

import flask.Flask,

try
    #     from flask_socketio import SocketIO, emit

    FLASK_SOCKETIO_AVAILABLE = True
except (ImportError, AttributeError) as e
    #     # Handle compatibility issues with flask_socketio
    FLASK_SOCKETIO_AVAILABLE = False
    SocketIO = None
    emit = None
        print(
    #         f"Warning: flask_socketio import failed with error: {e}. WebSocket functionality will be disabled."
    #     )
import logging

import prometheus_client
import prometheus_client.Counter,
import prometheus_client.core.CollectorRegistry

import noodlecore.error_handler.error_metrics,

# Remove circular import - import noodlecorecoreCompiler only when needed

# Configure logging
logger = logging.getLogger(__name__)

# Flask app for monitoring API
app = Flask(__name__)
app.config["SECRET_KEY"] = "noodle-monitoring-secret-key"
# socketio = SocketIO(app, cors_allowed_origins="*") if FLASK_SOCKETIO_AVAILABLE else None

# Prometheus metrics
registry = CollectorRegistry()

# Error counters by type
ERROR_COUNT = Counter(
#     "noodle_errors_total",
#     "Total number of errors by type",
#     ["error_type", "severity"],
registry = registry,
# )

# Error latency histogram
ERROR_LATENCY = Histogram(
#     "noodle_error_processing_seconds",
#     "Time spent processing errors",
#     ["error_type"],
registry = registry,
# )

# Current error gauge
CURRENT_ERRORS = Gauge(
"noodle_current_errors", "Current number of errors in system", registry = registry
# )

# Alert status gauge
ALERT_STATUS = Gauge(
#     "noodle_alert_status",
"Current alert status (0 = normal, 1=warning, 2=critical)",
registry = registry,
# )


class AlertManager
    #     """Manages error alerts and notifications"""

    #     def __init__(self):
    self.alerts = {}
    self.alert_handlers = []
    self.lock = threading.Lock()
    self.last_alert_time = {}

    #     def add_alert_handler(self, handler: Callable):
    #         """Add a custom alert handler"""
            self.alert_handlers.append(handler)

    #     def check_and_alert(self, error_type: str, severity: str):
    #         """Check if alert conditions are met and trigger notifications"""
    #         with self.lock:
    alert_key = f"{error_type}_{severity}"
    now = time.time()

                # Rate limit alerts (max 1 per minute per error type/severity)
    #             if alert_key in self.last_alert_time:
    #                 if now - self.last_alert_time[alert_key] < 60:
    #                     return

    self.last_alert_time[alert_key] = now

    #             # Check if we should alert
    threshold = error_metrics.alert_thresholds.get(severity, {})
    #             if threshold:
    recent_errors = error_metrics.get_error_frequency(
    #                     error_type, threshold["time_window"]
    #                 )
    #                 if recent_errors >= threshold["count"]:
    alert = {
    #                         "error_type": error_type,
    #                         "severity": severity,
    #                         "count": recent_errors,
    #                         "threshold": threshold["count"],
    #                         "time_window": threshold["time_window"],
                            "timestamp": datetime.utcnow().isoformat(),
    #                     }

    self.alerts[alert_key] = alert
                        self._trigger_alerts(alert)

    #                     # Update Prometheus gauge
    #                     ALERT_STATUS.set(2 if severity == "CRITICAL" else 1)

    #     def _trigger_alerts(self, alert: Dict[str, Any]):
    #         """Trigger all registered alert handlers"""
    #         # Log the alert
            secure_logger(
                f"Alert triggered: {alert['error_type']} ({alert['severity']}) - "
    #             f"{alert['count']} errors in {alert['time_window']}s",
    #             logging.WARNING,
    error_type = "Alert",
    severity = alert["severity"],
    #         )

    #         # WebSocket notification (only if available)
    #         if socketio:
                socketio.emit("error_alert", alert)

    #         # Custom handlers
    #         for handler in self.alert_handlers:
    #             try:
                    handler(alert)
    #             except Exception as e:
                    logger.error(f"Error in alert handler: {e}")

    #     def clear_alert(self, error_type: str, severity: str):
    #         """Clear an alert"""
    #         with self.lock:
    alert_key = f"{error_type}_{severity}"
    #             if alert_key in self.alerts:
    #                 del self.alerts[alert_key]
                    ALERT_STATUS.set(0)

    #     def get_active_alerts(self) -> List[Dict[str, Any]]:
    #         """Get all active alerts"""
    #         with self.lock:
                return list(self.alerts.values())


# Global alert manager
alert_manager = AlertManager()


class MonitoringDashboard
    #     """Provides integration with monitoring dashboards"""

    #     def __init__(self):
    self.dashboard_url = "http://localhost:3000"  # Default dashboard URL
    self.api_key = None

    #     def set_dashboard_config(self, url: str, api_key: Optional[str] = None):
    #         """Configure dashboard connection settings"""
    self.dashboard_url = url
    self.api_key = api_key

    #     def send_metrics(self, metrics: Dict[str, Any]):
    #         """Send metrics to configured dashboard"""
    #         try:
    #             import requests

    headers = {"Content-Type": "application/json"}
    #             if self.api_key:
    headers["Authorization"] = f"Bearer {self.api_key}"

    response = requests.post(
    #                 f"{self.dashboard_url}/api/metrics",
    json = metrics,
    headers = headers,
    timeout = 5,
    #             )

    #             if response.status_code == 200:
                    secure_logger("Metrics sent to dashboard successfully", logging.INFO)
    #             else:
                    secure_logger(
    #                     f"Failed to send metrics to dashboard: {response.status_code}",
    #                     logging.WARNING,
    #                 )

    #         except Exception as e:
                secure_logger(
                    f"Error sending metrics to dashboard: {str(e)}", logging.ERROR
    #             )

    #     def get_dashboard_url(self) -> str:
    #         """Get the configured dashboard URL"""
    #         return self.dashboard_url


# Global dashboard instance
dashboard = MonitoringDashboard()


# API Routes
@app.route("/api/metrics", methods = ["GET"])
function get_metrics()
    #     """Get current error metrics"""
    #     try:
    start_time = time.time()

    metrics = error_metrics.get_metrics_summary()
    metrics["timestamp"] = datetime.utcnow().isoformat()
    metrics["uptime"] = (
    #             time.time() - app.start_time if hasattr(app, "start_time") else 0
    #         )

    #         # Update Prometheus metrics
            CURRENT_ERRORS.set(len(metrics["error_counts"]))

    #         # Process latency
            ERROR_LATENCY.observe(time.time() - start_time)

            return jsonify(metrics)
    #     except Exception as e:
            return jsonify({"error": str(e)}), 500


@app.route("/api/alerts", methods = ["GET"])
function get_alerts()
    #     """Get active alerts"""
    #     try:
            return jsonify(
    #             {
                    "alerts": alert_manager.get_active_alerts(),
                    "timestamp": datetime.utcnow().isoformat(),
    #             }
    #         )
    #     except Exception as e:
            return jsonify({"error": str(e)}), 500


@app.route("/api/alerts/<error_type>/<severity>", methods = ["POST"])
function clear_alert(error_type: str, severity: str)
    #     """Clear a specific alert"""
    #     try:
            alert_manager.clear_alert(error_type, severity)
            return jsonify({"status": "cleared"})
    #     except Exception as e:
            return jsonify({"error": str(e)}), 500


@app.route("/api/metrics/prometheus", methods = ["GET"])
function prometheus_metrics()
    #     """Serve metrics in Prometheus format"""
        return generate_latest(registry)


@app.route("/api/config/alert-threshold", methods = ["POST"])
function set_alert_threshold()
    #     """Set custom alert threshold"""
    #     try:
    data = request.get_json()
    severity = data.get("severity")
    count = data.get("count")
    time_window = data.get("time_window", 300)

    #         if not severity or count is None:
                return jsonify({"error": "Missing required parameters"}), 400

    #         from .error_handler import error_metrics

    error_metrics.alert_thresholds[severity] = {
    #             "count": count,
    #             "time_window": time_window,
    #         }

            return jsonify({"status": "threshold_set"})
    #     except Exception as e:
            return jsonify({"error": str(e)}), 500


@app.route("/api/dashboard/config", methods = ["POST"])
function configure_dashboard()
    #     """Configure dashboard connection"""
    #     try:
    data = request.get_json()
    url = data.get("url")
    api_key = data.get("api_key")

    #         if not url:
                return jsonify({"error": "Dashboard URL is required"}), 400

            dashboard.set_dashboard_config(url, api_key)
            return jsonify({"status": "dashboard_configured"})
    #     except Exception as e:
            return jsonify({"error": str(e)}), 500


@app.route("/api/test-error", methods = ["POST"])
function test_error()
    #     """Endpoint to test error tracking (for development)"""
    #     try:
    data = request.get_json()
    error_type = data.get("error_type", "TestError")
    severity = data.get("severity", "LOW")

    #         # Record test error
            error_metrics.record_error(error_type, severity)

    #         # Check for alerts
            alert_manager.check_and_alert(error_type, severity)

            return jsonify({"status": "error_recorded"})
    #     except Exception as e:
            return jsonify({"error": str(e)}), 500


# WebSocket events (only if flask_socketio is available)
if socketio

        @socketio.on("connect")
    #     def handle_connect():
    #         """Handle new WebSocket connection"""
            secure_logger("Monitoring dashboard connected", logging.INFO)

    #         # Send current metrics
    metrics = error_metrics.get_metrics_summary()
            emit("initial_metrics", metrics)

        @socketio.on("disconnect")
    #     def handle_disconnect():
    #         """Handle WebSocket disconnection"""
            secure_logger("Monitoring dashboard disconnected", logging.INFO)

        @socketio.on("subscribe_alerts")
    #     def handle_subscribe_alerts():
    #         """Handle subscription to real-time alerts"""
            secure_logger("Client subscribed to real-time alerts", logging.INFO)
            emit("subscribed", {"status": "subscribed"})


# Background thread for periodic metrics collection
function metrics_collection_thread()
    #     """Background thread to periodically collect and send metrics"""
    #     while True:
    #         try:
                time.sleep(30)  # Collect metrics every 30 seconds

    #             # Get current metrics
    metrics = error_metrics.get_metrics_summary()
    metrics["timestamp"] = datetime.utcnow().isoformat()

    #             # Update Prometheus counters
    #             for error_type, count in metrics["error_counts"].items():
    ERROR_COUNT.labels(error_type = error_type, severity="LOW").inc(count)

    #             # Send to dashboard if configured
    #             if dashboard.get_dashboard_url() != "http://localhost:3000":
                    dashboard.send_metrics(metrics)

    #         except Exception as e:
                secure_logger(
                    f"Error in metrics collection thread: {str(e)}", logging.ERROR
    #             )


# Initialize monitoring
def init_monitoring(
host: str = "0.0.0.0", port: int = 5001, dashboard_url: Optional[str] = None
# ):
#     """Initialize the monitoring system"""
#     global app

#     # Set app start time
app.start_time = time.time()

#     # Configure dashboard if URL provided
#     if dashboard_url:
        dashboard.set_dashboard_config(dashboard_url)

#     # Start background thread
metrics_thread = threading.Thread(target=metrics_collection_thread, daemon=True)
    metrics_thread.start()

    # Add default alert handler (email, Slack, etc. could be added here)
#     def default_alert_handler(alert: Dict[str, Any]):
        secure_logger(
#             f"ALERT: {alert['error_type']} reached {alert['count']} errors "
            f"in {alert['time_window']} seconds (severity: {alert['severity']})",
#             logging.ERROR,
error_type = "SystemAlert",
severity = "HIGH",
#         )

    alert_manager.add_alert_handler(default_alert_handler)

#     # Start Flask app in a separate thread
#     def run_flask():
app.run(host = host, port=port, debug=False, threaded=True)

flask_thread = threading.Thread(target=run_flask, daemon=True)
    flask_thread.start()

    secure_logger(f"Error monitoring system initialized on {host}:{port}", logging.INFO)


# Integration with error_handler
function record_error_with_metrics(error_type: str, severity: str = "LOW")
    #     """Record error and update monitoring metrics"""
        error_metrics.record_error(error_type, severity)

    #     # Check for alerts
        alert_manager.check_and_alert(error_type, severity)

    #     # Update Prometheus metrics
    ERROR_COUNT.labels(error_type = error_type, severity=severity).inc(1)


# Error reporting function for compiler integration
function report_errors(error_type: str, error_message: str, severity: str = "MEDIUM")
    #     """Report errors from compiler to monitoring system"""
        error_metrics.record_error(error_type, severity)
        secure_logger(
    #         f"Compiler error: {error_type} - {error_message}",
    #         logging.ERROR,
    error_type = error_type,
    severity = severity,
    #     )

    #     # Check for alerts
        alert_manager.check_and_alert(error_type, severity)

    #     # Update Prometheus metrics
    ERROR_COUNT.labels(error_type = error_type, severity=severity).inc(1)


# Export functions for integration
__all__ = [
#     "init_monitoring",
#     "record_error_with_metrics",
#     "report_errors",
#     "alert_manager",
#     "dashboard",
#     "app",
# ]

# Only export socketio if it's available
if socketio is not None
        __all__.append("socketio")

if __name__ == "__main__"
    #     # Example usage
    init_monitoring(dashboard_url = "http://localhost:3000")

    #     # Test recording an error
        record_error_with_metrics("TestError", "HIGH")

    #     # Keep the main thread alive
    #     try:
    #         while True:
                time.sleep(1)
    #     except KeyboardInterrupt:
            print("Monitoring stopped")
