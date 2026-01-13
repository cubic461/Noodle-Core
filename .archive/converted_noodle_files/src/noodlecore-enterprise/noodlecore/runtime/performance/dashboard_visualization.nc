# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Performance Dashboard Visualization System for Noodle

# This module implements a comprehensive web-based dashboard for visualizing performance metrics,
# system health, and resource utilization with interactive charts, customizable layouts,
# and real-time updates.
# """

import asyncio
import json
import logging
import os
import sqlite3
import threading
import time
import uuid
import collections.defaultdict,
import dataclasses.asdict,
import datetime.datetime,
import enum.Enum
import pathlib.Path
import typing.Any,

import aiofiles
import aiohttp
import dash
import dash_bootstrap_components as dbc
import numpy as np
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import plotly.utils
import redis
import dash.Input,
import flask.Flask,
import plotly.subplots.make_subplots
import sklearn.cluster.DBSCAN
import sklearn.preprocessing.StandardScaler

logger = logging.getLogger(__name__)


class ChartType(Enum)
    #     """Supported chart types for dashboard visualization"""

    LINE = "line"
    BAR = "bar"
    SCATTER = "scatter"
    HEATMAP = "heatmap"
    PIE = "pie"
    GAUGE = "gauge"
    OHLC = "ohlc"
    VIOLIN = "violin"
    BOX = "box"


class TimeRange(Enum)
    #     """Time range options for dashboard data"""

    REAL_TIME = "realtime"
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


# @dataclass
class DashboardWidget
    #     """Configuration for a dashboard widget"""

    #     id: str
    #     title: str
    #     chart_type: ChartType
    #     metric_names: List[str]
    #     position: Dict[str, int]  # row, col
    #     size: Dict[str, int]  # width, height
    time_range: TimeRange = TimeRange.LAST_HOUR
    refresh_interval: int = 30  # seconds
    options: Dict[str, Any] = field(default_factory=dict)
    visible: bool = True


# @dataclass
class DashboardLayout
    #     """Configuration for a dashboard layout"""

    #     id: str
    #     name: str
    #     description: str
    #     widgets: List[DashboardWidget]
    created_at: datetime = field(default_factory=datetime.now)
    updated_at: datetime = field(default_factory=datetime.now)
    is_default: bool = False


# @dataclass
class AlertRule
    #     """Configuration for alert rules"""

    #     id: str
    #     name: str
    #     metric_name: str
    condition: str  # e.g., ">", "<", "> = ", "<=", "==", "!="
    #     threshold: float
    #     severity: str  # "low", "medium", "high", "critical"
    #     message: str
    enabled: bool = True
    last_triggered: Optional[datetime] = None


# @dataclass
class Alert
    #     """Alert instance"""

    #     id: str
    #     rule_id: str
    #     metric_name: str
    #     value: float
    #     threshold: float
    #     severity: str
    #     message: str
    #     timestamp: datetime
    acknowledged: bool = False


class DashboardDataSource
    #     """Data source abstraction for dashboard metrics"""

    #     def __init__(self, storage_path: str = "dashboard_data"):
    self.storage_path = Path(storage_path)
    self.storage_path.mkdir(parents = True, exist_ok=True)
    self.redis_client = redis.Redis(
    host = "localhost", port=6379, db=0, decode_responses=True
    #         )
    self.db_path = self.storage_path / "dashboard.db"
            self._init_database()

    #     def _init_database(self):
    #         """Initialize SQLite database for dashboard data"""
    #         with sqlite3.connect(self.db_path) as conn:
                conn.execute(
    #                 """
                    CREATE TABLE IF NOT EXISTS dashboard_metrics (
    #                     id INTEGER PRIMARY KEY AUTOINCREMENT,
    #                     timestamp DATETIME NOT NULL,
    #                     metric_name TEXT NOT NULL,
    #                     value REAL NOT NULL,
    #                     unit TEXT,
    #                     tags TEXT,
    #                     metadata TEXT
    #                 )
    #             """
    #             )

                conn.execute(
    #                 """
                    CREATE TABLE IF NOT EXISTS alerts (
    #                     id INTEGER PRIMARY KEY AUTOINCREMENT,
    #                     rule_id TEXT NOT NULL,
    #                     metric_name TEXT NOT NULL,
    #                     value REAL NOT NULL,
    #                     threshold REAL NOT NULL,
    #                     severity TEXT NOT NULL,
    #                     message TEXT NOT NULL,
    #                     timestamp DATETIME NOT NULL,
    #                     acknowledged BOOLEAN DEFAULT FALSE
    #                 )
    #             """
    #             )

                conn.execute(
    #                 """
    #                 CREATE INDEX IF NOT EXISTS idx_metrics_timestamp
                    ON dashboard_metrics(timestamp)
    #             """
    #             )

                conn.execute(
    #                 """
    #                 CREATE INDEX IF NOT EXISTS idx_metrics_name
                    ON dashboard_metrics(metric_name)
    #             """
    #             )

                conn.execute(
    #                 """
    #                 CREATE INDEX IF NOT EXISTS idx_alerts_timestamp
                    ON alerts(timestamp)
    #             """
    #             )

                conn.commit()

    #     async def get_metrics(
    #         self, metric_names: List[str], start_time: datetime, end_time: datetime
    #     ) -> pd.DataFrame:
    #         """Retrieve metrics for specified time range"""
    query = """
    #             SELECT timestamp, metric_name, value, unit, tags, metadata
    #             FROM dashboard_metrics
                WHERE metric_name IN ({}) AND timestamp BETWEEN ? AND ?
    #             ORDER BY timestamp
            """.format(
                ",".join(["?"] * len(metric_names))
    #         )

    params = math.add(metric_names, [start_time.isoformat(), end_time.isoformat()])

    #         with sqlite3.connect(self.db_path) as conn:
    df = pd.read_sql_query(query, conn, params=params)

    #         if not df.empty:
    df["timestamp"] = pd.to_datetime(df["timestamp"])
    df["tags"] = df["tags"].apply(json.loads)
    df["metadata"] = df["metadata"].apply(json.loads)

    #         return df

    #     async def get_latest_metrics(
    self, metric_names: List[str], count: int = 100
    #     ) -> pd.DataFrame:
    #         """Get latest metrics for specified metrics"""
    query = """
    #             SELECT timestamp, metric_name, value, unit, tags, metadata
    #             FROM dashboard_metrics
                WHERE metric_name IN ({})
    #             ORDER BY timestamp DESC
    #             LIMIT ?
            """.format(
                ",".join(["?"] * len(metric_names))
    #         )

    params = math.add(metric_names, [count])

    #         with sqlite3.connect(self.db_path) as conn:
    df = pd.read_sql_query(query, conn, params=params)

    #         if not df.empty:
    df["timestamp"] = pd.to_datetime(df["timestamp"])
    df = df.sort_values("timestamp")
    df["tags"] = df["tags"].apply(json.loads)
    df["metadata"] = df["metadata"].apply(json.loads)

    #         return df

    #     async def store_metrics(self, metrics: List[Dict[str, Any]]) -> None:
    #         """Store metrics in database"""
    #         with sqlite3.connect(self.db_path) as conn:
    #             for metric in metrics:
                    conn.execute(
    #                     """
    #                     INSERT INTO dashboard_metrics
                        (timestamp, metric_name, value, unit, tags, metadata)
                        VALUES (?, ?, ?, ?, ?, ?)
    #                 """,
                        (
                            metric["timestamp"].isoformat(),
    #                         metric["name"],
    #                         metric["value"],
                            metric.get("unit", ""),
                            json.dumps(metric.get("tags", {})),
                            json.dumps(metric.get("metadata", {})),
    #                     ),
    #                 )
                conn.commit()

    #     async def store_alert(self, alert: Alert) -> None:
    #         """Store alert in database"""
    #         with sqlite3.connect(self.db_path) as conn:
                conn.execute(
    #                 """
    #                 INSERT INTO alerts
                    (rule_id, metric_name, value, threshold, severity, message, timestamp, acknowledged)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    #             """,
                    (
    #                     alert.rule_id,
    #                     alert.metric_name,
    #                     alert.value,
    #                     alert.threshold,
    #                     alert.severity,
    #                     alert.message,
                        alert.timestamp.isoformat(),
    #                     alert.acknowledged,
    #                 ),
    #             )
                conn.commit()

    #     async def get_alerts(
    #         self,
    severity: Optional[str] = None,
    acknowledged: Optional[bool] = None,
    limit: int = 100,
    #     ) -> List[Alert]:
    #         """Get alerts from database"""
    query = "SELECT * FROM alerts WHERE 1=1"
    params = []

    #         if severity:
    query + = " AND severity = ?"
                params.append(severity)

    #         if acknowledged is not None:
    query + = " AND acknowledged = ?"
                params.append(acknowledged)

    query + = " ORDER BY timestamp DESC LIMIT ?"
            params.append(limit)

    #         with sqlite3.connect(self.db_path) as conn:
    conn.row_factory = sqlite3.Row
    cursor = conn.execute(query, params)
    rows = cursor.fetchall()

    alerts = []
    #         for row in rows:
    alert = Alert(
    id = str(row["id"]),
    rule_id = row["rule_id"],
    metric_name = row["metric_name"],
    value = row["value"],
    threshold = row["threshold"],
    severity = row["severity"],
    message = row["message"],
    timestamp = datetime.fromisoformat(row["timestamp"]),
    acknowledged = bool(row["acknowledged"]),
    #             )
                alerts.append(alert)

    #         return alerts


class ChartGenerator
    #     """Generate various types of charts for dashboard visualization"""

    #     def __init__(self, data_source: DashboardDataSource):
    self.data_source = data_source

    #     async def create_line_chart(
    #         self,
    #         metric_names: List[str],
    #         time_range: TimeRange,
    options: Dict[str, Any] = None,
    #     ) -> str:
    #         """Create a line chart for specified metrics"""
    end_time = datetime.now()

    #         # Calculate start time based on time range
    time_range_map = {
    TimeRange.REAL_TIME: end_time - timedelta(minutes = 5),
    TimeRange.LAST_5_MINUTES: end_time - timedelta(minutes = 5),
    TimeRange.LAST_15_MINUTES: end_time - timedelta(minutes = 15),
    TimeRange.LAST_30_MINUTES: end_time - timedelta(minutes = 30),
    TimeRange.LAST_HOUR: end_time - timedelta(hours = 1),
    TimeRange.LAST_3_HOURS: end_time - timedelta(hours = 3),
    TimeRange.LAST_6_HOURS: end_time - timedelta(hours = 6),
    TimeRange.LAST_12_HOURS: end_time - timedelta(hours = 12),
    TimeRange.LAST_24_HOURS: end_time - timedelta(hours = 24),
    TimeRange.LAST_7_DAYS: end_time - timedelta(days = 7),
    TimeRange.LAST_30_DAYS: end_time - timedelta(days = 30),
    #         }

    start_time = math.subtract(time_range_map.get(time_range, end_time, timedelta(hours=1)))

    #         # Get data
    df = await self.data_source.get_metrics(metric_names, start_time, end_time)

    #         if df.empty:
                return self._create_empty_chart("No data available")

    #         # Create figure
    fig = go.Figure()

    #         # Add traces for each metric
    #         for metric_name in metric_names:
    metric_data = df[df["metric_name"] == metric_name]
    #             if not metric_data.empty:
                    fig.add_trace(
                        go.Scatter(
    x = metric_data["timestamp"],
    y = metric_data["value"],
    mode = "lines",
    name = metric_name,
    line = dict(width=2),
    #                     )
    #                 )

    #         # Update layout
            fig.update_layout(
    title = "Performance Metrics",
    xaxis_title = "Time",
    yaxis_title = "Value",
    hovermode = "x unified",
    legend = dict(
    orientation = "h", yanchor="bottom", y=1.02, xanchor="right", x=1
    #             ),
    #             height=options.get("height", 400) if options else 400,
    margin = dict(l=50, r=50, t=50, b=50),
    #         )

    return fig.to_html(include_plotlyjs = "cdn", div_id="line-chart")

    #     async def create_heatmap(
    #         self,
    #         metric_names: List[str],
    #         time_range: TimeRange,
    options: Dict[str, Any] = None,
    #     ) -> str:
    #         """Create a heatmap for system resource utilization"""
    end_time = datetime.now()
    #         start_time = end_time - timedelta(hours=24)  # Default to 24 hours for heatmap

    #         # Get data
    df = await self.data_source.get_metrics(metric_names, start_time, end_time)

    #         if df.empty:
                return self._create_empty_chart("No data available")

    #         # Pivot data for heatmap
    df_pivot = df.pivot_table(
    index = "metric_name",
    columns = pd.Grouper(key="timestamp", freq="H"),
    values = "value",
    aggfunc = "mean",
    #         )

    #         # Create heatmap
    fig = go.Figure(
    data = go.Heatmap(
    z = df_pivot.values,
    x = df_pivot.columns,
    y = df_pivot.index,
    colorscale = "Viridis",
    hoverongaps = False,
    #             )
    #         )

    #         # Update layout
            fig.update_layout(
    title = "Resource Utilization Heatmap",
    xaxis_title = "Time",
    yaxis_title = "Resource",
    #             height=options.get("height", 500) if options else 500,
    margin = dict(l=50, r=50, t=50, b=50),
    #         )

    return fig.to_html(include_plotlyjs = "cdn", div_id="heatmap-chart")

    #     async def create_gauge_chart(
    self, metric_name: str, current_value: float, options: Dict[str, Any] = None
    #     ) -> str:
    #         """Create a gauge chart for a single metric"""
    #         # Determine gauge ranges based on metric type
    ranges = self._get_gauge_ranges(metric_name, current_value)

    #         # Create gauge
    fig = go.Figure(
                go.Indicator(
    mode = "gauge+number+delta",
    value = current_value,
    domain = {"x": [0, 1], "y": [0, 1]},
    title = {"text": metric_name},
    delta = {"reference": ranges["target"]},
    gauge = {
    #                     "axis": {"range": [None, ranges["max"]]},
    #                     "bar": {"color": "darkblue"},
    #                     "steps": [
    #                         {"range": [0, ranges["warning"]], "color": "lightgray"},
    #                         {
    #                             "range": [ranges["warning"], ranges["critical"]],
    #                             "color": "gray",
    #                         },
    #                     ],
    #                     "threshold": {
    #                         "line": {"color": "red", "width": 4},
    #                         "thickness": 0.75,
    #                         "value": ranges["critical"],
    #                     },
    #                 },
    #             )
    #         )

    #         # Update layout
            fig.update_layout(
    #             height=options.get("height", 300) if options else 300,
    margin = dict(l=50, r=50, t=50, b=50),
    #         )

    return fig.to_html(include_plotlyjs = "cdn", div_id="gauge-chart")

    #     async def create_bar_chart(
    #         self,
    #         metric_names: List[str],
    #         time_range: TimeRange,
    options: Dict[str, Any] = None,
    #     ) -> str:
    #         """Create a bar chart for specified metrics"""
    end_time = datetime.now()
    #         start_time = end_time - timedelta(hours=1)  # Default to 1 hour for bar chart

    #         # Get data
    df = await self.data_source.get_metrics(metric_names, start_time, end_time)

    #         if df.empty:
                return self._create_empty_chart("No data available")

    #         # Aggregate data by metric name
    df_agg = df.groupby("metric_name")["value"].mean().reset_index()

    #         # Create bar chart
    fig = go.Figure(
    data = go.Bar(
    x = df_agg["metric_name"], y=df_agg["value"], marker_color="skyblue"
    #             )
    #         )

    #         # Update layout
            fig.update_layout(
    title = "Average Metric Values",
    xaxis_title = "Metric",
    yaxis_title = "Value",
    #             height=options.get("height", 400) if options else 400,
    margin = dict(l=50, r=50, t=50, b=50),
    #         )

    return fig.to_html(include_plotlyjs = "cdn", div_id="bar-chart")

    #     def _get_gauge_ranges(
    #         self, metric_name: str, current_value: float
    #     ) -> Dict[str, float]:
    #         """Determine appropriate ranges for gauge chart based on metric type"""
    metric_lower = metric_name.lower()

    #         if "cpu" in metric_lower or "usage" in metric_lower:
    #             return {"min": 0, "max": 100, "target": 50, "warning": 70, "critical": 90}
    #         elif "memory" in metric_lower:
    #             return {"min": 0, "max": 100, "target": 50, "warning": 75, "critical": 90}
    #         elif "disk" in metric_lower:
    #             return {"min": 0, "max": 100, "target": 60, "warning": 80, "critical": 95}
    #         else:
    #             # Default ranges for unknown metrics
    #             return {
    #                 "min": 0,
                    "max": max(100, current_value * 2),
    #                 "target": current_value * 0.7,
    #                 "warning": current_value * 1.2,
    #                 "critical": current_value * 1.5,
    #             }

    #     def _create_empty_chart(self, message: str) -> str:
    #         """Create an empty chart with a message"""
    fig = go.Figure()
            fig.add_annotation(
    text = message,
    xref = "paper",
    yref = "paper",
    x = 0.5,
    y = 0.5,
    showarrow = False,
    font = dict(size=16),
    #         )
            fig.update_layout(
    xaxis = dict(showgrid=False, showticklabels=False, zeroline=False),
    yaxis = dict(showgrid=False, showticklabels=False, zeroline=False),
    plot_bgcolor = "white",
    #         )
    return fig.to_html(include_plotlyjs = "cdn", div_id="empty-chart")


class AlertManager
    #     """Manage alerts and notifications for dashboard"""

    #     def __init__(self, data_source: DashboardDataSource):
    self.data_source = data_source
    self.alert_rules: Dict[str, AlertRule] = {}
    self.alert_history: deque = deque(maxlen=1000)
    self.lock = threading.Lock()

    #     def add_alert_rule(self, rule: AlertRule) -> None:
    #         """Add an alert rule"""
    #         with self.lock:
    self.alert_rules[rule.id] = rule

    #     def remove_alert_rule(self, rule_id: str) -> None:
    #         """Remove an alert rule"""
    #         with self.lock:
    #             if rule_id in self.alert_rules:
    #                 del self.alert_rules[rule_id]

    #     def update_alert_rule(self, rule: AlertRule) -> None:
    #         """Update an alert rule"""
    #         with self.lock:
    #             if rule.id in self.alert_rules:
    self.alert_rules[rule.id] = rule

    #     async def check_alerts(self, metrics: List[Dict[str, Any]]) -> List[Alert]:
    #         """Check metrics against alert rules and generate alerts if needed"""
    new_alerts = []

    #         with self.lock:
    #             for metric in metrics:
    metric_name = metric["name"]
    metric_value = metric["value"]

    #                 for rule in self.alert_rules.values():
    #                     if not rule.enabled or rule.metric_name != metric_name:
    #                         continue

    #                     # Check condition
    triggered = False
    #                     if rule.condition == ">" and metric_value > rule.threshold:
    triggered = True
    #                     elif rule.condition == "<" and metric_value < rule.threshold:
    triggered = True
    #                     elif rule.condition == ">=" and metric_value >= rule.threshold:
    triggered = True
    #                     elif rule.condition == "<=" and metric_value <= rule.threshold:
    triggered = True
    #                     elif rule.condition == "==" and metric_value == rule.threshold:
    triggered = True
    #                     elif rule.condition == "!=" and metric_value != rule.threshold:
    triggered = True

    #                     if triggered:
    #                         # Create alert
    alert = Alert(
    id = str(uuid.uuid4()),
    rule_id = rule.id,
    metric_name = metric_name,
    value = metric_value,
    threshold = rule.threshold,
    severity = rule.severity,
    message = rule.message,
    timestamp = datetime.now(),
    #                         )

    #                         # Store alert
                            await self.data_source.store_alert(alert)
                            new_alerts.append(alert)

    #                         # Update rule last triggered time
    rule.last_triggered = datetime.now()

    #         return new_alerts

    #     async def get_active_alerts(self, severity: Optional[str] = None) -> List[Alert]:
            """Get active (unacknowledged) alerts"""
    return await self.data_source.get_alerts(severity = severity, acknowledged=False)

    #     async def get_alert_history(self, limit: int = 100) -> List[Alert]:
    #         """Get alert history"""
    return await self.data_source.get_alerts(limit = limit)

    #     async def acknowledge_alert(self, alert_id: str) -> bool:
    #         """Acknowledge an alert"""
    #         with sqlite3.connect(self.data_source.db_path) as conn:
    cursor = conn.execute(
    #                 """
    UPDATE alerts SET acknowledged = TRUE WHERE id = ?
    #             """,
                    (alert_id,),
    #             )
                conn.commit()
    #             return cursor.rowcount > 0


class DashboardApp
    #     """Main dashboard application"""

    #     def __init__(self, storage_path: str = "dashboard_data"):
    self.storage_path = Path(storage_path)
    self.storage_path.mkdir(parents = True, exist_ok=True)

    #         # Initialize components
    self.data_source = DashboardDataSource(str(self.storage_path))
    self.chart_generator = ChartGenerator(self.data_source)
    self.alert_manager = AlertManager(self.data_source)

    #         # Default layouts
    self.layouts: Dict[str, DashboardLayout] = {}
    self.current_layout_id: Optional[str] = None
            self._init_default_layouts()

    #         # Dash app
    self.app = dash.Dash(__name__, external_stylesheets=[dbc.themes.BOOTSTRAP])
            self._setup_layout()
            self._setup_callbacks()

    #         # Background thread for real-time updates
    self.running = False
    self.update_thread = None

    #     def _init_default_layouts(self):
    #         """Initialize default dashboard layouts"""
    #         # System Overview Layout
    system_overview_widgets = [
                DashboardWidget(
    id = "cpu-gauge",
    title = "CPU Usage",
    chart_type = ChartType.GAUGE,
    metric_names = ["cpu_usage_percent"],
    position = {"row": 1, "col": 1},
    size = {"width": 6, "height": 3},
    time_range = TimeRange.REAL_TIME,
    refresh_interval = 10,
    #             ),
                DashboardWidget(
    id = "memory-gauge",
    title = "Memory Usage",
    chart_type = ChartType.GAUGE,
    metric_names = ["memory_usage_percent"],
    position = {"row": 1, "col": 2},
    size = {"width": 6, "height": 3},
    time_range = TimeRange.REAL_TIME,
    refresh_interval = 10,
    #             ),
                DashboardWidget(
    id = "disk-usage",
    title = "Disk Usage",
    chart_type = ChartType.GAUGE,
    metric_names = ["disk_usage_percent"],
    position = {"row": 2, "col": 1},
    size = {"width": 6, "height": 3},
    time_range = TimeRange.REAL_TIME,
    refresh_interval = 30,
    #             ),
                DashboardWidget(
    id = "network-traffic",
    title = "Network Traffic",
    chart_type = ChartType.LINE,
    metric_names = ["network_bytes_sent", "network_bytes_recv"],
    position = {"row": 2, "col": 2},
    size = {"width": 6, "height": 3},
    time_range = TimeRange.LAST_HOUR,
    refresh_interval = 30,
    #             ),
                DashboardWidget(
    id = "resource-heatmap",
    title = "Resource Utilization",
    chart_type = ChartType.HEATMAP,
    metric_names = [
    #                     "cpu_usage_percent",
    #                     "memory_usage_percent",
    #                     "disk_usage_percent",
    #                 ],
    position = {"row": 3, "col": 1},
    size = {"width": 6, "height": 3},
    time_range = TimeRange.LAST_24_HOURS,
    refresh_interval = 300,
    #             ),
                DashboardWidget(
    id = "performance-trends",
    title = "Performance Trends",
    chart_type = ChartType.LINE,
    metric_names = ["response_time", "throughput", "error_rate"],
    position = {"row": 3, "col": 2},
    size = {"width": 6, "height": 3},
    time_range = TimeRange.LAST_24_HOURS,
    refresh_interval = 60,
    #             ),
    #         ]

    system_overview_layout = DashboardLayout(
    id = "system-overview",
    name = "System Overview",
    description = "High-level system performance metrics",
    widgets = system_overview_widgets,
    is_default = True,
    #         )

    self.layouts[system_overview_layout.id] = system_overview_layout
    self.current_layout_id = system_overview_layout.id

    #     def _setup_layout(self):
    #         """Setup the Dash app layout"""
    self.app.layout = dbc.Container(
    #             [
    #                 # Header
                    dbc.Row(
    #                     [
                            dbc.Col(
    #                             [
                                    html.H1(
    #                                     "Noodle Performance Dashboard",
    className = "text-primary mb-4",
    #                                 ),
                                    html.Hr(),
    #                             ]
    #                         )
    #                     ]
    #                 ),
    #                 # Control Panel
                    dbc.Row(
    #                     [
                            dbc.Col(
    #                             [
                                    dbc.Card(
    #                                     [
                                            dbc.CardBody(
    #                                             [
                                                    html.H4(
    #                                                     "Dashboard Controls",
    className = "card-title",
    #                                                 ),
                                                    dbc.Row(
    #                                                     [
                                                            dbc.Col(
    #                                                             [
                                                                    html.Label("Layout:"),
                                                                    dcc.Dropdown(
    id = "layout-dropdown",
    options = [
    #                                                                         {
    #                                                                             "label": layout.name,
    #                                                                             "value": layout.id,
    #                                                                         }
    #                                                                         for layout in self.layouts.values()
    #                                                                     ],
    value = self.current_layout_id,
    clearable = False,
    #                                                                 ),
    #                                                             ],
    width = 6,
    #                                                         ),
                                                            dbc.Col(
    #                                                             [
                                                                    html.Label(
    #                                                                     "Time Range:"
    #                                                                 ),
                                                                    dcc.Dropdown(
    id = "time-range-dropdown",
    options = [
    #                                                                         {
    #                                                                             "label": time_range.value,
    #                                                                             "value": time_range.value,
    #                                                                         }
    #                                                                         for time_range in TimeRange
    #                                                                     ],
    value = TimeRange.LAST_HOUR.value,
    clearable = False,
    #                                                                 ),
    #                                                             ],
    width = 6,
    #                                                         ),
    #                                                     ],
    className = "mb-3",
    #                                                 ),
                                                    dbc.Row(
    #                                                     [
                                                            dbc.Col(
    #                                                             [
                                                                    html.Label(
                                                                        "Refresh Interval (seconds):"
    #                                                                 ),
                                                                    dcc.Slider(
    id = "refresh-slider",
    min = 5,
    max = 300,
    step = 5,
    value = 30,
    marks = {
                                                                            i: str(i)
    #                                                                         for i in range(
    #                                                                             0, 301, 60
    #                                                                         )
    #                                                                     },
    tooltip = {
    #                                                                         "placement": "bottom",
    #                                                                         "always_visible": True,
    #                                                                     },
    #                                                                 ),
    #                                                             ],
    width = 6,
    #                                                         ),
                                                            dbc.Col(
    #                                                             [
                                                                    dbc.Button(
    #                                                                     "Refresh Dashboard",
    id = "refresh-button",
    color = "primary",
    className = "mt-4",
    #                                                                 ),
                                                                    dbc.Button(
    #                                                                     "Export Data",
    id = "export-button",
    color = "success",
    className = "mt-4 ms-2",
    #                                                                 ),
    #                                                             ],
    width = 6,
    #                                                         ),
    #                                                     ]
    #                                                 ),
    #                                             ]
    #                                         )
    #                                     ]
    #                                 )
    #                             ]
    #                         )
    #                     ],
    className = "mb-4",
    #                 ),
    #                 # Alert Panel
                    dbc.Row(
    #                     [
                            dbc.Col(
    #                             [
                                    dbc.Alert(
    #                                     [
                                            html.H5(
    "Active Alerts", className = "alert-heading"
    #                                         ),
    html.Div(id = "alert-content"),
    #                                     ],
    color = "danger",
    id = "alert-panel",
    className = "mb-4",
    #                                 )
    #                             ]
    #                         )
    #                     ]
    #                 ),
    #                 # Dashboard Grid
    dbc.Row([dbc.Col([html.Div(id = "dashboard-grid")])]),
    #                 # Hidden div for storing component IDs
    html.Div(id = "component-ids", style={"display": "none"}),
    #                 # Interval component for auto-refresh
                    dcc.Interval(
    id = "interval-component",
    interval = math.multiply(30, 1000,  # 30 seconds)
    n_intervals = 0,
    #                 ),
    #                 # Store component for caching
    dcc.Store(id = "dashboard-store"),
    #             ],
    fluid = True,
    #         )

    #     def _setup_callbacks(self):
    #         """Setup Dash callbacks"""

            @self.app.callback(
    #             [
                    Output("dashboard-grid", "children"),
                    Output("alert-panel", "is_open"),
                    Output("alert-content", "children"),
    #             ],
    #             [
                    Input("interval-component", "n_intervals"),
                    Input("layout-dropdown", "value"),
                    Input("time-range-dropdown", "value"),
                    Input("refresh-slider", "value"),
                    Input("refresh-button", "n_clicks"),
    #             ],
                [State("dashboard-store", "data")],
    #         )
    #         def update_dashboard(
    #             n_intervals,
    #             layout_id,
    #             time_range_value,
    #             refresh_interval,
    #             n_clicks,
    #             stored_data,
    #         ):
    #             """Update dashboard components"""
    ctx = callback_context
    triggered_id = (
    #                 ctx.triggered[0]["prop_id"].split(".")[0] if ctx.triggered else None
    #             )

    #             # Get current layout
    layout = self.layouts.get(layout_id, self.layouts[self.current_layout_id])

    #             # Parse time range
    time_range = next(
    #                 (tr for tr in TimeRange if tr.value == time_range_value),
    #                 TimeRange.LAST_HOUR,
    #             )

    #             # Create dashboard grid
    grid_children = []

    #             # Create widgets grid
    widget_grid = {}
    #             for widget in layout.widgets:
    #                 if not widget.visible:
    #                     continue

    widget_key = f"{widget.id}-{widget.chart_type.value}"
    widget_grid[widget_key] = widget

    #             # Generate charts for each widget
    charts = []
    #             for widget in layout.widgets:
    #                 if not widget.visible:
    #                     continue

    #                 try:
    #                     if widget.chart_type == ChartType.LINE:
    chart_html = asyncio.run(
                                self.chart_generator.create_line_chart(
    #                                 widget.metric_names, time_range, widget.options
    #                             )
    #                         )
    #                     elif widget.chart_type == ChartType.HEATMAP:
    chart_html = asyncio.run(
                                self.chart_generator.create_heatmap(
    #                                 widget.metric_names, time_range, widget.options
    #                             )
    #                         )
    #                     elif widget.chart_type == ChartType.GAUGE:
    #                         # Get latest value for gauge
    latest_metrics = asyncio.run(
                                self.data_source.get_latest_metrics(widget.metric_names, 1)
    #                         )
    #                         if not latest_metrics.empty:
    current_value = latest_metrics.iloc[-1]["value"]
    #                         else:
    current_value = 0

    chart_html = asyncio.run(
                                self.chart_generator.create_gauge_chart(
    #                                 widget.metric_names[0], current_value, widget.options
    #                             )
    #                         )
    #                     elif widget.chart_type == ChartType.BAR:
    chart_html = asyncio.run(
                                self.chart_generator.create_bar_chart(
    #                                 widget.metric_names, time_range, widget.options
    #                             )
    #                         )
    #                     else:
    chart_html = self.chart_generator._create_empty_chart(
    #                             "Chart type not supported"
    #                         )

    #                     # Create card for widget
    card = dbc.Card(
    #                         [
                                dbc.CardHeader(widget.title),
                                dbc.CardBody(
    #                                 [
                                        html.Div(
    dangerously_set_html = True,
    content = chart_html,
    style = {"height": "100%"},
    #                                     )
    #                                 ]
    #                             ),
    #                         ],
    className = "mb-3",
    #                     )

                        charts.append((widget.position, card))

    #                 except Exception as e:
    #                     logger.error(f"Error creating chart for widget {widget.id}: {e}")
    error_card = dbc.Card(
    #                         [
                                dbc.CardHeader(widget.title),
                                dbc.CardBody(
    #                                 [
                                        html.Div(
    #                                         [
    html.H5("Error", className = "text-danger"),
                                                html.P(f"Failed to load chart: {str(e)}"),
    #                                         ]
    #                                     )
    #                                 ]
    #                             ),
    #                         ],
    className = "mb-3",
    #                     )
                        charts.append((widget.position, error_card))

    #             # Sort charts by position and create grid
    charts.sort(key = lambda x: (x[0]["row"], x[0]["col"]))

    #             # Create responsive grid
    current_row = 1
    row_children = []

    #             for position, card in charts:
    #                 if position["row"] > current_row:
    #                     # Add completed row to grid
                        grid_children.append(dbc.Row(row_children))
    row_children = []
    current_row = position["row"]

    #                 # Add card to current row
    row_children.append(dbc.Col(card, width = 6))

    #             # Add last row to grid
    #             if row_children:
                    grid_children.append(dbc.Row(row_children))

    #             # Get alerts
    #             try:
    active_alerts = asyncio.run(self.alert_manager.get_active_alerts())
    alert_is_open = len(active_alerts) > 0

    alert_content = []
    #                 for alert in active_alerts[:5]:  # Show max 5 alerts
    alert_severity_color = {
    #                         "low": "info",
    #                         "medium": "warning",
    #                         "high": "danger",
    #                         "critical": "danger",
                        }.get(alert.severity, "secondary")

    alert_card = dbc.Alert(
    #                         [
                                html.H6(
    #                                 f"{alert.metric_name}: {alert.message}",
    className = "alert-heading",
    #                             ),
                                html.P(
                                    f"Value: {alert.value:.2f} (Threshold: {alert.threshold:.2f})"
    #                             ),
                                html.Small(
                                    f"Triggered: {alert.timestamp.strftime('%Y-%m-%d %H:%M:%S')}"
    #                             ),
    #                         ],
    color = alert_severity_color,
    className = "mb-2",
    #                     )

                        alert_content.append(alert_card)

    #                 if len(active_alerts) > 5:
                        alert_content.append(
                            html.P(f"... and {len(active_alerts) - 5} more alerts")
    #                     )

    #             except Exception as e:
                    logger.error(f"Error loading alerts: {e}")
    alert_is_open = False
    alert_content = html.P("Error loading alerts")

    #             return grid_children, alert_is_open, alert_content

            @self.app.callback(
                Output("dashboard-store", "data"),
                [Input("export-button", "n_clicks")],
                [State("layout-dropdown", "value"), State("time-range-dropdown", "value")],
    #         )
    #         def export_data(n_clicks, layout_id, time_range_value):
    #             """Export dashboard data"""
    #             if not n_clicks:
    #                 return {}

    #             # Parse time range
    time_range = next(
    #                 (tr for tr in TimeRange if tr.value == time_range_value),
    #                 TimeRange.LAST_HOUR,
    #             )

    #             # Get current layout
    layout = self.layouts.get(layout_id, self.layouts[self.current_layout_id])

    #             # Calculate time range
    end_time = datetime.now()
    time_range_map = {
    TimeRange.REAL_TIME: end_time - timedelta(minutes = 5),
    TimeRange.LAST_5_MINUTES: end_time - timedelta(minutes = 5),
    TimeRange.LAST_15_MINUTES: end_time - timedelta(minutes = 15),
    TimeRange.LAST_30_MINUTES: end_time - timedelta(minutes = 30),
    TimeRange.LAST_HOUR: end_time - timedelta(hours = 1),
    TimeRange.LAST_3_HOURS: end_time - timedelta(hours = 3),
    TimeRange.LAST_6_HOURS: end_time - timedelta(hours = 6),
    TimeRange.LAST_12_HOURS: end_time - timedelta(hours = 12),
    TimeRange.LAST_24_HOURS: end_time - timedelta(hours = 24),
    TimeRange.LAST_7_DAYS: end_time - timedelta(days = 7),
    TimeRange.LAST_30_DAYS: end_time - timedelta(days = 30),
    #             }

    start_time = math.subtract(time_range_map.get(time_range, end_time, timedelta(hours=1)))

    #             # Get data for all metrics in layout
    all_metrics = []
    #             for widget in layout.widgets:
    #                 if widget.visible:
    #                     try:
    metrics_df = asyncio.run(
                                self.data_source.get_metrics(
    #                                 widget.metric_names, start_time, end_time
    #                             )
    #                         )
    #                         if not metrics_df.empty:
                                all_metrics.append(metrics_df)
    #                     except Exception as e:
    #                         logger.error(f"Error getting metrics for export: {e}")

    #             # Combine all metrics
    #             if all_metrics:
    export_data = pd.concat(all_metrics).to_dict("records")
    #             else:
    export_data = []

    #             return {
                    "export_timestamp": datetime.now().isoformat(),
    #                 "layout_id": layout_id,
    #                 "time_range": time_range_value,
    #                 "data": export_data,
    #             }

    #     def start(self, host: str = "127.0.0.1", port: int = 8050, debug: bool = False):
    #         """Start the dashboard application"""
    self.app.run_server(host = host, port=port, debug=debug)

    #     def add_layout(self, layout: DashboardLayout):
    #         """Add a new dashboard layout"""
    self.layouts[layout.id] = layout
    #         if not self.current_layout_id or layout.is_default:
    self.current_layout_id = layout.id

    #     def remove_layout(self, layout_id: str):
    #         """Remove a dashboard layout"""
    #         if layout_id in self.layouts:
    #             del self.layouts[layout_id]
    #             if self.current_layout_id == layout_id:
    self.current_layout_id = next(iter(self.layouts), None)

    #     def get_layout(self, layout_id: str) -> Optional[DashboardLayout]:
    #         """Get a dashboard layout by ID"""
            return self.layouts.get(layout_id)

    #     def list_layouts(self) -> List[DashboardLayout]:
    #         """List all dashboard layouts"""
            return list(self.layouts.values())

    #     async def add_metrics(self, metrics: List[Dict[str, Any]]):
    #         """Add metrics to the dashboard data source"""
    #         # Store metrics
            await self.data_source.store_metrics(metrics)

    #         # Check for alerts
            await self.alert_manager.check_alerts(metrics)

    #     def add_alert_rule(self, rule: AlertRule):
    #         """Add an alert rule"""
            self.alert_manager.add_alert_rule(rule)

    #     def remove_alert_rule(self, rule_id: str):
    #         """Remove an alert rule"""
            self.alert_manager.remove_alert_rule(rule_id)

    #     def update_alert_rule(self, rule: AlertRule):
    #         """Update an alert rule"""
            self.alert_manager.update_alert_rule(rule)

    #     async def get_alerts(
    self, severity: Optional[str] = None, acknowledged: Optional[bool] = None
    #     ) -> List[Alert]:
    #         """Get alerts"""
    #         if acknowledged is False:
                return await self.alert_manager.get_active_alerts(severity)
    #         else:
    return await self.alert_manager.get_alert_history(limit = 100)


# Global instance
_global_dashboard: Optional[DashboardApp] = None


def get_dashboard_app(storage_path: str = "dashboard_data") -> DashboardApp:
#     """Get global dashboard application instance"""
#     global _global_dashboard

#     if _global_dashboard is None:
_global_dashboard = DashboardApp(storage_path)

#     return _global_dashboard


def start_dashboard(
host: str = "127.0.0.1",
port: int = 8050,
debug: bool = False,
storage_path: str = "dashboard_data",
# ) -> DashboardApp:
#     """Start the dashboard application"""
dashboard = get_dashboard_app(storage_path)
dashboard.start(host = host, port=port, debug=debug)
#     return dashboard


function stop_dashboard()
    #     """Stop the dashboard application"""
    #     global _global_dashboard
    _global_dashboard = None
