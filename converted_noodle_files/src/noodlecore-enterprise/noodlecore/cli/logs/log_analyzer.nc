# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Log Analyzer Module

# This module implements comprehensive log analysis and parsing capabilities for the NoodleCore CLI,
# including log searching, pattern detection, anomaly identification, and correlation analysis.
# """

import asyncio
import json
import re
import gzip
import collections.defaultdict,
import dataclasses.dataclass,
import datetime.datetime,
import enum.Enum
import pathlib.Path
import typing.Dict,
import statistics
import hashlib

import ..cli_config.get_cli_config


# Error codes for log analyzer (5401-5500)
class LogAnalyzerErrorCodes
    ANALYZER_INIT_FAILED = 5401
    PARSING_FAILED = 5402
    PATTERN_DETECTION_FAILED = 5403
    ANOMALY_DETECTION_FAILED = 5404
    CORRELATION_FAILED = 5405
    SEARCH_FAILED = 5406
    EXPORT_FAILED = 5407
    ALERTING_FAILED = 5408
    VISUALIZATION_FAILED = 5409
    INTEGRATION_FAILED = 5410


class LogLevel(Enum)
    #     """Log levels for analysis."""
    DEBUG = "DEBUG"
    INFO = "INFO"
    WARNING = "WARNING"
    ERROR = "ERROR"
    CRITICAL = "CRITICAL"


class LogFormat(Enum)
    #     """Supported log formats."""
    JSON = "json"
    TEXT = "text"
    STRUCTURED = "structured"
    SYSLOG = "syslog"
    CUSTOM = "custom"


class AnomalyType(Enum)
    #     """Types of anomalies that can be detected."""
    SPIKE_IN_ERRORS = "spike_in_errors"
    UNUSUAL_PATTERN = "unusual_pattern"
    PERFORMANCE_DEGRADATION = "performance_degradation"
    MISSING_HEARTBEAT = "missing_heartbeat"
    REPEATED_FAILURES = "repeated_failures"
    UNAUTHORIZED_ACCESS = "unauthorized_access"
    RESOURCE_EXHAUSTION = "resource_exhaustion"


# @dataclass
class LogEntry
    #     """Parsed log entry."""
    #     timestamp: datetime
    #     level: LogLevel
    #     message: str
    #     component: str
    request_id: Optional[str] = None
    details: Optional[Dict[str, Any]] = None
    raw_line: str = ""
    file_path: str = ""
    line_number: int = 0


# @dataclass
class LogPattern
    #     """Log pattern definition."""
    #     name: str
    #     pattern: str
    #     regex: Pattern
    #     description: str
    #     severity: str
    #     category: str
    enabled: bool = True


# @dataclass
class LogAnomaly
    #     """Detected log anomaly."""
    #     timestamp: datetime
    #     anomaly_type: AnomalyType
    #     severity: str
    #     description: str
    #     affected_entries: List[LogEntry]
    #     confidence: float
    #     details: Dict[str, Any]


# @dataclass
class LogCorrelation
    #     """Correlated log entries."""
    #     correlation_id: str
    #     entries: List[LogEntry]
    #     pattern: str
    #     timeline: Dict[str, datetime]
    #     summary: Dict[str, Any]


class LogAnalyzerException(Exception)
    #     """Base exception for log analyzer errors."""

    #     def __init__(self, message: str, error_code: int):
    self.error_code = error_code
            super().__init__(message)


class LogAnalyzer
    #     """Comprehensive log analysis system."""

    #     def __init__(self, config_dir: Optional[str] = None):
    #         """
    #         Initialize the log analyzer.

    #         Args:
    #             config_dir: Directory for analyzer configuration and data
    #         """
    self.config = get_cli_config()
    self.config_dir = Path(config_dir or '.project/.noodle/logs')
    self.config_dir.mkdir(parents = True, exist_ok=True)

    #         # Analysis data storage
    self.patterns_file = self.config_dir / 'log_patterns.json'
    self.anomalies_file = self.config_dir / 'log_anomalies.json'
    self.correlations_file = self.config_dir / 'log_correlations.json'
    self.analysis_cache_file = self.config_dir / 'analysis_cache.json'

    #         # Log sources
    self.log_sources: List[Path] = []
            self._discover_log_sources()

    #         # Pattern definitions
    self.patterns: Dict[str, LogPattern] = {}
            self._initialize_patterns()

    #         # Analysis cache
    self.analysis_cache: Dict[str, Any] = {}
            self._load_analysis_cache()

    #         # Anomaly detection thresholds
    self.anomaly_thresholds = {
    #             'error_spike_threshold': 5.0,  # 5x normal error rate
    #             'performance_degradation_threshold': 2.0,  # 2x slower
    #             'missing_heartbeat_minutes': 5,
    #             'repeated_failure_count': 3,
    #             'unusual_pattern_min_occurrences': 10
    #         }

    #         # Analysis state
    self._analyzing = False
    self._analysis_task = None

    #         # Alert callbacks
    self._alert_callbacks: List[Callable[[LogAnomaly], None]] = []

    #         # Statistics
    self._stats = {
    #             'total_entries_analyzed': 0,
    #             'patterns_detected': 0,
    #             'anomalies_detected': 0,
    #             'correlations_found': 0,
    #             'last_analysis': None
    #         }

    #     def _discover_log_sources(self) -> None:
    #         """Discover available log sources."""
    log_dir = self.config_dir

    #         # Add standard log files
    standard_logs = [
    #             'cli.log',
    #             'audit.log',
    #             'performance.log',
    #             'ai_audit.log',
    #             'performance_alerts.log'
    #         ]

    #         for log_file in standard_logs:
    log_path = math.divide(log_dir, log_file)
    #             if log_path.exists():
                    self.log_sources.append(log_path)

    #         # Add archived logs
    archive_dir = log_dir / 'archive'
    #         if archive_dir.exists():
                self.log_sources.extend(archive_dir.glob('*.log'))
                self.log_sources.extend(archive_dir.glob('*.log.gz'))

    #     def _initialize_patterns(self) -> None:
    #         """Initialize default log patterns."""
    default_patterns = [
    #             # Error patterns
                LogPattern(
    #                 "database_connection_error",
    #                 r"database.*connection.*error|failed.*to.*connect.*database",
                    re.compile(r"database.*connection.*error|failed.*to.*connect.*database", re.IGNORECASE),
    #                 "Database connection failure",
    #                 "high",
    #                 "database"
    #             ),
                LogPattern(
    #                 "authentication_failure",
    #                 r"authentication.*failed|login.*failed|unauthorized|access.*denied",
                    re.compile(r"authentication.*failed|login.*failed|unauthorized|access.*denied", re.IGNORECASE),
    #                 "Authentication or authorization failure",
    #                 "high",
    #                 "security"
    #             ),
                LogPattern(
    #                 "file_not_found",
    #                 r"file.*not.*found|no.*such.*file|directory.*not.*found",
                    re.compile(r"file.*not.*found|no.*such.*file|directory.*not.*found", re.IGNORECASE),
    #                 "File or directory not found",
    #                 "medium",
    #                 "filesystem"
    #             ),
                LogPattern(
    #                 "timeout_error",
    #                 r"timeout|timed.*out|connection.*timeout",
                    re.compile(r"timeout|timed.*out|connection.*timeout", re.IGNORECASE),
    #                 "Operation timeout",
    #                 "medium",
    #                 "performance"
    #             ),
                LogPattern(
    #                 "memory_error",
    #                 r"out.*of.*memory|memory.*error|cannot.*allocate.*memory",
                    re.compile(r"out.*of.*memory|memory.*error|cannot.*allocate.*memory", re.IGNORECASE),
    #                 "Memory allocation failure",
    #                 "high",
    #                 "system"
    #             ),
                LogPattern(
    #                 "ai_provider_error",
    #                 r"ai.*provider.*error|model.*error|api.*error.*ai",
                    re.compile(r"ai.*provider.*error|model.*error|api.*error.*ai", re.IGNORECASE),
    #                 "AI provider error",
    #                 "medium",
    #                 "ai"
    #             ),
                LogPattern(
    #                 "sandbox_error",
    #                 r"sandbox.*error|execution.*error|sandbox.*failed",
                    re.compile(r"sandbox.*error|execution.*error|sandbox.*failed", re.IGNORECASE),
    #                 "Sandbox execution error",
    #                 "medium",
    #                 "sandbox"
    #             ),
    #             # Performance patterns
                LogPattern(
    #                 "slow_query",
    #                 r"slow.*query|query.*took.*\d+.*seconds|database.*slow",
                    re.compile(r"slow.*query|query.*took.*\d+.*seconds|database.*slow", re.IGNORECASE),
    #                 "Slow database query detected",
    #                 "medium",
    #                 "performance"
    #             ),
                LogPattern(
    #                 "high_response_time",
    #                 r"response.*time.*\d+.*ms|request.*took.*\d+.*seconds",
                    re.compile(r"response.*time.*\d+.*ms|request.*took.*\d+.*seconds", re.IGNORECASE),
    #                 "High response time detected",
    #                 "low",
    #                 "performance"
    #             ),
    #             # Security patterns
                LogPattern(
    #                 "suspicious_activity",
    #                 r"suspicious.*activity|unusual.*access|potential.*attack",
                    re.compile(r"suspicious.*activity|unusual.*access|potential.*attack", re.IGNORECASE),
    #                 "Suspicious activity detected",
    #                 "high",
    #                 "security"
    #             ),
                LogPattern(
    #                 "privilege_escalation",
    #                 r"privilege.*escalation|admin.*access|sudo.*access",
                    re.compile(r"privilege.*escalation|admin.*access|sudo.*access", re.IGNORECASE),
    #                 "Privilege escalation attempt",
    #                 "critical",
    #                 "security"
    #             )
    #         ]

    #         for pattern in default_patterns:
    self.patterns[pattern.name] = pattern

    #         # Save patterns to file
            self._save_patterns()

    #     def _save_patterns(self) -> None:
    #         """Save patterns to file."""
    #         try:
    patterns_data = {}
    #             for name, pattern in self.patterns.items():
    patterns_data[name] = {
    #                     'name': pattern.name,
    #                     'pattern': pattern.pattern,
    #                     'description': pattern.description,
    #                     'severity': pattern.severity,
    #                     'category': pattern.category,
    #                     'enabled': pattern.enabled
    #                 }

    #             with open(self.patterns_file, 'w', encoding='utf-8') as f:
    json.dump(patterns_data, f, indent = 2)

    #         except Exception as e:
                raise LogAnalyzerException(
                    f"Failed to save patterns: {str(e)}",
    #                 LogAnalyzerErrorCodes.PARSING_FAILED
    #             )

    #     def _load_patterns(self) -> None:
    #         """Load patterns from file."""
    #         try:
    #             if self.patterns_file.exists():
    #                 with open(self.patterns_file, 'r', encoding='utf-8') as f:
    patterns_data = json.load(f)

    #                 for name, pattern_data in patterns_data.items():
    pattern = LogPattern(
    name = pattern_data['name'],
    pattern = pattern_data['pattern'],
    regex = re.compile(pattern_data['pattern'], re.IGNORECASE),
    description = pattern_data['description'],
    severity = pattern_data['severity'],
    category = pattern_data['category'],
    enabled = pattern_data.get('enabled', True)
    #                     )
    self.patterns[name] = pattern

    #         except Exception as e:
    #             # Use default patterns if loading fails
    #             pass

    #     def _load_analysis_cache(self) -> None:
    #         """Load analysis cache from file."""
    #         try:
    #             if self.analysis_cache_file.exists():
    #                 with open(self.analysis_cache_file, 'r', encoding='utf-8') as f:
    self.analysis_cache = json.load(f)

    #         except Exception:
    self.analysis_cache = {}

    #     def _save_analysis_cache(self) -> None:
    #         """Save analysis cache to file."""
    #         try:
    #             with open(self.analysis_cache_file, 'w', encoding='utf-8') as f:
    json.dump(self.analysis_cache, f, indent = 2, default=str)

    #         except Exception:
    #             pass  # Don't let cache saving failures break analysis

    #     async def parse_log_file(
    #         self,
    #         file_path: Path,
    log_format: LogFormat = LogFormat.JSON,
    since: Optional[datetime] = None,
    until: Optional[datetime] = None,
    limit: Optional[int] = None
    #     ) -> List[LogEntry]:
    #         """
    #         Parse a log file and extract structured entries.

    #         Args:
    #             file_path: Path to log file
    #             log_format: Format of the log file
    #             since: Filter by start time
    #             until: Filter by end time
    #             limit: Maximum number of entries to parse

    #         Returns:
    #             List of parsed log entries
    #         """
    #         try:
    entries = []

    #             # Determine if file is compressed
    #             open_func = gzip.open if file_path.suffix == '.gz' else open

    #             with open_func(file_path, 'rt', encoding='utf-8', errors='ignore') as f:
    line_number = 0

    #                 for line in f:
    line_number + = 1
    line = line.strip()

    #                     if not line or line.startswith('#'):
    #                         continue

    #                     try:
    entry = await self._parse_log_line(line, log_format, file_path, line_number)

    #                         if entry:
    #                             # Apply time filters
    #                             if since and entry.timestamp < since:
    #                                 continue
    #                             if until and entry.timestamp > until:
    #                                 continue

                                entries.append(entry)

    #                             # Apply limit
    #                             if limit and len(entries) >= limit:
    #                                 break

    #                     except Exception:
    #                         # Skip malformed lines but continue parsing
    #                         continue

    self._stats['total_entries_analyzed'] + = len(entries)
    #             return entries

    #         except Exception as e:
                raise LogAnalyzerException(
                    f"Failed to parse log file {file_path}: {str(e)}",
    #                 LogAnalyzerErrorCodes.PARSING_FAILED
    #             )

    #     async def _parse_log_line(
    #         self,
    #         line: str,
    #         log_format: LogFormat,
    #         file_path: Path,
    #         line_number: int
    #     ) -> Optional[LogEntry]:
    #         """Parse a single log line."""
    #         try:
    #             if log_format == LogFormat.JSON:
    data = json.loads(line)

    timestamp = datetime.fromisoformat(data.get('timestamp', '').replace('Z', '+00:00'))
    level = LogLevel(data.get('level', 'INFO'))
    message = data.get('message', '')
    component = data.get('component', 'unknown')
    request_id = data.get('request_id')
    #                 details = {k: v for k, v in data.items()
    #                           if k not in ['timestamp', 'level', 'message', 'component', 'request_id']}

    #             elif log_format == LogFormat.TEXT:
    #                 # Parse standard text log format
    #                 # Example: "2025-10-20T18:58:34.980Z - INFO - component - message"
    match = re.match(r'(\S+?)\s*-\s*(\w+)\s*-\s*(\S+)\s*-\s*(.+)', line)
    #                 if match:
    timestamp_str, level_str, component, message = match.groups()
    timestamp = datetime.fromisoformat(timestamp_str.replace('Z', '+00:00'))
    level = LogLevel(level_str)
    details = {}
    request_id = None
    #                 else:
    #                     # Fallback parsing
    timestamp = datetime.now()
    level = LogLevel.INFO
    component = 'unknown'
    message = line
    details = {}
    request_id = None
    #             else:
    #                 # For other formats, try JSON parsing first
    #                 try:
    data = json.loads(line)
    timestamp = datetime.fromisoformat(data.get('timestamp', '').replace('Z', '+00:00'))
    level = LogLevel(data.get('level', 'INFO'))
    message = data.get('message', line)
    component = data.get('component', 'unknown')
    request_id = data.get('request_id')
    #                     details = {k: v for k, v in data.items()
    #                               if k not in ['timestamp', 'level', 'message', 'component', 'request_id']}
    #                 except:
    #                     # Final fallback
    timestamp = datetime.now()
    level = LogLevel.INFO
    component = 'unknown'
    message = line
    details = {}
    request_id = None

                return LogEntry(
    timestamp = timestamp,
    level = level,
    message = message,
    component = component,
    request_id = request_id,
    details = details,
    raw_line = line,
    file_path = str(file_path),
    line_number = line_number
    #             )

    #         except Exception:
    #             return None

    #     async def search_logs(
    #         self,
    #         query: str,
    filters: Optional[Dict[str, Any]] = None,
    limit: int = 1000
    #     ) -> Dict[str, Any]:
    #         """
    #         Search logs with query and filters.

    #         Args:
                query: Search query (supports regex)
                filters: Additional filters (level, component, since, until, etc.)
    #             limit: Maximum number of results

    #         Returns:
    #             Dictionary containing search results
    #         """
    #         try:
    #             # Parse filters
    #             level_filter = filters.get('level') if filters else None
    #             component_filter = filters.get('component') if filters else None
    #             since = filters.get('since') if filters else None
    #             until = filters.get('until') if filters else None

    #             # Compile search regex
    search_pattern = re.compile(query, re.IGNORECASE)

    results = []
    total_entries = 0

    #             # Search through all log sources
    #             for log_source in self.log_sources:
    #                 try:
    entries = await self.parse_log_file(
    #                         log_source,
    #                         LogFormat.JSON,  # Try JSON first
    since = since,
    until = until,
    #                         limit=limit * 2  # Get more to account for filtering
    #                     )

    #                     for entry in entries:
    total_entries + = 1

    #                         # Apply filters
    #                         if level_filter and entry.level.value != level_filter:
    #                             continue
    #                         if component_filter and entry.component != component_filter:
    #                             continue

    #                         # Apply search query
    #                         if search_pattern.search(entry.message) or \
                               search_pattern.search(entry.raw_line):
                                results.append(entry)

    #                             if len(results) >= limit:
    #                                 break

    #                     if len(results) >= limit:
    #                         break

    #                 except Exception:
    #                     # Try text format if JSON fails
    #                     try:
    entries = await self.parse_log_file(
    #                             log_source,
    #                             LogFormat.TEXT,
    since = since,
    until = until,
    limit = math.multiply(limit, 2)
    #                         )

    #                         for entry in entries:
    total_entries + = 1

    #                             if level_filter and entry.level.value != level_filter:
    #                                 continue
    #                             if component_filter and entry.component != component_filter:
    #                                 continue

    #                             if search_pattern.search(entry.message) or \
                                   search_pattern.search(entry.raw_line):
                                    results.append(entry)

    #                                 if len(results) >= limit:
    #                                     break

    #                         if len(results) >= limit:
    #                             break

    #                     except Exception:
    #                         continue

    #             # Convert results to dict format
    results_data = []
    #             for entry in results:
    entry_dict = asdict(entry)
    entry_dict['timestamp'] = entry.timestamp.isoformat()
    entry_dict['level'] = entry.level.value
                    results_data.append(entry_dict)

    #             return {
    #                 'success': True,
    #                 'results': results_data,
                    'count': len(results_data),
    #                 'total_entries_searched': total_entries,
    #                 'query': query,
    #                 'filters': filters or {}
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': str(e),
    #                 'error_code': LogAnalyzerErrorCodes.SEARCH_FAILED
    #             }

    #     async def detect_patterns(
    #         self,
    #         entries: List[LogEntry],
    custom_patterns: Optional[List[LogPattern]] = None
    #     ) -> Dict[str, Any]:
    #         """
    #         Detect patterns in log entries.

    #         Args:
    #             entries: Log entries to analyze
    #             custom_patterns: Additional patterns to check

    #         Returns:
    #             Dictionary containing detected patterns
    #         """
    #         try:
    patterns_to_check = list(self.patterns.values())
    #             if custom_patterns:
                    patterns_to_check.extend(custom_patterns)

    detected_patterns = defaultdict(list)

    #             for entry in entries:
    #                 for pattern in patterns_to_check:
    #                     if not pattern.enabled:
    #                         continue

    #                     if pattern.regex.search(entry.message) or pattern.regex.search(entry.raw_line):
                            detected_patterns[pattern.name].append({
                                'timestamp': entry.timestamp.isoformat(),
    #                             'level': entry.level.value,
    #                             'component': entry.component,
    #                             'message': entry.message,
    #                             'file_path': entry.file_path,
    #                             'line_number': entry.line_number
    #                         })

    #             # Convert to final format
    results = {}
    #             for pattern_name, matches in detected_patterns.items():
    pattern = self.patterns.get(pattern_name)
    #                 if pattern:
    results[pattern_name] = {
    #                         'description': pattern.description,
    #                         'severity': pattern.severity,
    #                         'category': pattern.category,
                            'count': len(matches),
    #                         'matches': matches
    #                     }

    #             self._stats['patterns_detected'] += sum(len(matches) for matches in detected_patterns.values())

    #             return {
    #                 'success': True,
    #                 'patterns': results,
                    'total_patterns_found': len(results),
    #                 'total_matches': sum(len(matches) for matches in detected_patterns.values())
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': str(e),
    #                 'error_code': LogAnalyzerErrorCodes.PATTERN_DETECTION_FAILED
    #             }

    #     async def detect_anomalies(
    #         self,
    #         entries: List[LogEntry],
    time_window: int = 3600  # 1 hour
    #     ) -> Dict[str, Any]:
    #         """
    #         Detect anomalies in log entries.

    #         Args:
    #             entries: Log entries to analyze
    #             time_window: Time window for analysis in seconds

    #         Returns:
    #             Dictionary containing detected anomalies
    #         """
    #         try:
    anomalies = []

    #             if not entries:
    #                 return {
    #                     'success': True,
    #                     'anomalies': [],
    #                     'total_anomalies': 0
    #                 }

    #             # Sort entries by timestamp
    entries.sort(key = lambda x: x.timestamp)

    #             # Detect error spikes
    error_anomalies = await self._detect_error_spikes(entries, time_window)
                anomalies.extend(error_anomalies)

    #             # Detect performance degradation
    performance_anomalies = await self._detect_performance_degradation(entries, time_window)
                anomalies.extend(performance_anomalies)

    #             # Detect repeated failures
    failure_anomalies = await self._detect_repeated_failures(entries, time_window)
                anomalies.extend(failure_anomalies)

    #             # Detect unusual patterns
    pattern_anomalies = await self._detect_unusual_patterns(entries, time_window)
                anomalies.extend(pattern_anomalies)

    #             # Detect missing heartbeats
    heartbeat_anomalies = await self._detect_missing_heartbeats(entries, time_window)
                anomalies.extend(heartbeat_anomalies)

    #             # Detect security anomalies
    security_anomalies = await self._detect_security_anomalies(entries, time_window)
                anomalies.extend(security_anomalies)

    #             # Sort anomalies by timestamp and severity
    severity_order = {'critical': 0, 'high': 1, 'medium': 2, 'low': 3}
    anomalies.sort(key = lambda x: (x.timestamp, severity_order.get(x.severity, 3)))

    self._stats['anomalies_detected'] + = len(anomalies)

    #             # Convert to dict format
    anomalies_data = []
    #             for anomaly in anomalies:
    anomaly_dict = asdict(anomaly)
    anomaly_dict['timestamp'] = anomaly.timestamp.isoformat()
    anomaly_dict['anomaly_type'] = anomaly.anomaly_type.value
    anomaly_dict['affected_entries'] = [
    #                     asdict(entry) for entry in anomaly.affected_entries
    #                 ]
    #                 for entry_dict in anomaly_dict['affected_entries']:
    entry_dict['timestamp'] = entry_dict['timestamp'].isoformat()
    entry_dict['level'] = entry_dict['level'].value
                    anomalies_data.append(anomaly_dict)

    #             return {
    #                 'success': True,
    #                 'anomalies': anomalies_data,
                    'total_anomalies': len(anomalies),
    #                 'time_window': time_window
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': str(e),
    #                 'error_code': LogAnalyzerErrorCodes.ANOMALY_DETECTION_FAILED
    #             }

    #     async def _detect_error_spikes(
    #         self,
    #         entries: List[LogEntry],
    #         time_window: int
    #     ) -> List[LogAnomaly]:
    #         """Detect spikes in error rates."""
    anomalies = []

    #         # Calculate baseline error rate
    total_entries = len(entries)
    #         error_entries = [e for e in entries if e.level in [LogLevel.ERROR, LogLevel.CRITICAL]]

    #         if total_entries < 10:  # Not enough data
    #             return anomalies

    baseline_error_rate = math.divide(len(error_entries), total_entries)

    #         # Check for spikes in time windows
    current_time = math.subtract(entries[, 1].timestamp)
    window_start = math.subtract(current_time, timedelta(seconds=time_window))

    #         recent_entries = [e for e in entries if e.timestamp >= window_start]
    #         recent_errors = [e for e in recent_entries if e.level in [LogLevel.ERROR, LogLevel.CRITICAL]]

    #         if recent_entries:
    recent_error_rate = math.divide(len(recent_errors), len(recent_entries))

    #             # Check if error rate spiked
    #             if recent_error_rate > baseline_error_rate * self.anomaly_thresholds['error_spike_threshold']:
    anomaly = LogAnomaly(
    timestamp = current_time,
    anomaly_type = AnomalyType.SPIKE_IN_ERRORS,
    severity = 'high',
    description = f"Error rate spike detected: {recent_error_rate:.2%} vs baseline {baseline_error_rate:.2%}",
    affected_entries = recent_errors,
    confidence = math.subtract(min(1.0, recent_error_rate / baseline_error_rate, 1.0),)
    details = {
    #                         'baseline_error_rate': baseline_error_rate,
    #                         'recent_error_rate': recent_error_rate,
    #                         'time_window': time_window,
                            'error_count': len(recent_errors),
                            'total_count': len(recent_entries)
    #                     }
    #                 )
                    anomalies.append(anomaly)

    #         return anomalies

    #     async def _detect_performance_degradation(
    #         self,
    #         entries: List[LogEntry],
    #         time_window: int
    #     ) -> List[LogAnomaly]:
    #         """Detect performance degradation from log entries."""
    anomalies = []

    #         # Look for performance-related entries
    perf_entries = []
    #         for entry in entries:
    #             if any(keyword in entry.message.lower() for keyword in
    #                    ['response time', 'execution time', 'latency', 'slow', 'timeout']):
                    perf_entries.append(entry)

    #         if len(perf_entries) < 5:  # Not enough performance data
    #             return anomalies

    #         # Extract timing information
    times = []
    #         for entry in perf_entries:
    #             # Look for time patterns in messages
    time_match = re.search(r'(\d+(?:\.\d+)?)\s*(ms|seconds?|s)', entry.message.lower())
    #             if time_match:
    value = float(time_match.group(1))
    unit = time_match.group(2)

    #                 # Convert to seconds
    #                 if unit == 'ms':
    value = math.divide(value, 1000)

                    times.append((entry.timestamp, value))

    #         if len(times) < 5:
    #             return anomalies

    #         # Calculate baseline and recent performance
    times.sort(key = lambda x: x[0])
    baseline_times = math.divide(times[:len(times), /2])
    recent_times = math.divide(times[len(times), /2:])

    #         baseline_avg = statistics.mean(t for _, t in baseline_times)
    #         recent_avg = statistics.mean(t for _, t in recent_times)

    #         # Check for degradation
    #         if recent_avg > baseline_avg * self.anomaly_thresholds['performance_degradation_threshold']:
    #             affected_entries = [entry for entry in perf_entries
    #                               if any(keyword in entry.message.lower() for keyword in ['slow', 'timeout'])]

    anomaly = LogAnomaly(
    timestamp = math.subtract(recent_times[, 1][0],)
    anomaly_type = AnomalyType.PERFORMANCE_DEGRADATION,
    severity = 'medium',
    description = f"Performance degradation detected: recent avg {recent_avg:.3f}s vs baseline {baseline_avg:.3f}s",
    affected_entries = affected_entries,
    confidence = math.subtract(min(1.0, recent_avg / baseline_avg, 1.0),)
    details = {
    #                     'baseline_avg': baseline_avg,
    #                     'recent_avg': recent_avg,
    #                     'degradation_factor': recent_avg / baseline_avg,
    #                     'time_window': time_window
    #                 }
    #             )
                anomalies.append(anomaly)

    #         return anomalies

    #     async def _detect_repeated_failures(
    #         self,
    #         entries: List[LogEntry],
    #         time_window: int
    #     ) -> List[LogAnomaly]:
    #         """Detect repeated failure patterns."""
    anomalies = []

    #         # Group error entries by message similarity
    #         error_entries = [e for e in entries if e.level in [LogLevel.ERROR, LogLevel.CRITICAL]]

    #         if len(error_entries) < self.anomaly_thresholds['repeated_failure_count']:
    #             return anomalies

    #         # Simple message grouping (could be enhanced with better similarity detection)
    message_groups = defaultdict(list)
    #         for entry in error_entries:
    #             # Normalize message for grouping
    normalized = re.sub(r'\d+', 'N', entry.message.lower())  # Replace numbers
    normalized = re.sub(r'\s+', ' ', normalized).strip()
                message_groups[normalized].append(entry)

    #         # Check for repeated failures
    #         for message, group_entries in message_groups.items():
    #             if len(group_entries) >= self.anomaly_thresholds['repeated_failure_count']:
    #                 # Check if failures occurred within time window
    group_entries.sort(key = lambda x: x.timestamp)
    time_span = math.subtract((group_entries[, 1].timestamp - group_entries[0].timestamp).total_seconds())

    #                 if time_span <= time_window:
    anomaly = LogAnomaly(
    timestamp = math.subtract(group_entries[, 1].timestamp,)
    anomaly_type = AnomalyType.REPEATED_FAILURES,
    severity = 'high',
    description = f"Repeated failure detected: '{message}' occurred {len(group_entries)} times in {time_span:.0f}s",
    affected_entries = group_entries,
    confidence = math.divide(min(1.0, len(group_entries), 10.0),)
    details = {
    #                             'message_pattern': message,
                                'occurrence_count': len(group_entries),
    #                             'time_span': time_span,
    #                             'time_window': time_window
    #                         }
    #                     )
                        anomalies.append(anomaly)

    #         return anomalies

    #     async def _detect_unusual_patterns(
    #         self,
    #         entries: List[LogEntry],
    #         time_window: int
    #     ) -> List[LogAnomaly]:
    #         """Detect unusual patterns in log entries."""
    anomalies = []

    #         # This is a simplified implementation
    #         # In practice, you'd use more sophisticated anomaly detection

    #         # Look for unusual log levels in components
    component_levels = defaultdict(lambda: defaultdict(int))
    #         for entry in entries:
    component_levels[entry.component][entry.level.value] + = 1

    #         for component, levels in component_levels.items():
    total = sum(levels.values())
    #             if total < 10:  # Not enough data
    #                 continue

    #             # Check for unusual error rates in components
    error_rate = (levels.get('ERROR', 0) + levels.get('CRITICAL', 0)) / total

    #             if error_rate > 0.5:  # More than 50% errors
    #                 component_errors = [e for e in entries if e.component == component
    #                                   and e.level in [LogLevel.ERROR, LogLevel.CRITICAL]]

    anomaly = LogAnomaly(
    #                     timestamp=component_errors[-1].timestamp if component_errors else datetime.now(),
    anomaly_type = AnomalyType.UNUSUAL_PATTERN,
    severity = 'medium',
    description = f"Unusual error pattern in component '{component}': {error_rate:.2%} error rate",
    affected_entries = component_errors,
    confidence = min(1.0, error_rate),
    details = {
    #                         'component': component,
    #                         'error_rate': error_rate,
    #                         'total_entries': total,
                            'error_count': len(component_errors)
    #                     }
    #                 )
                    anomalies.append(anomaly)

    #         return anomalies

    #     async def _detect_missing_heartbeats(
    #         self,
    #         entries: List[LogEntry],
    #         time_window: int
    #     ) -> List[LogAnomaly]:
    #         """Detect missing heartbeat messages."""
    anomalies = []

    #         # Look for heartbeat patterns
    heartbeat_entries = []
    #         for entry in entries:
    #             if any(keyword in entry.message.lower() for keyword in
    #                    ['heartbeat', 'ping', 'alive', 'health', 'status']):
                    heartbeat_entries.append(entry)

    #         if len(heartbeat_entries) < 2:  # Not enough heartbeat data
    #             return anomalies

    #         # Sort by timestamp
    heartbeat_entries.sort(key = lambda x: x.timestamp)

    #         # Check for gaps
    #         for i in range(1, len(heartbeat_entries)):
    gap = math.subtract((heartbeat_entries[i].timestamp, heartbeat_entries[i-1].timestamp).total_seconds())

    #             if gap > self.anomaly_thresholds['missing_heartbeat_minutes'] * 60:
    anomaly = LogAnomaly(
    timestamp = heartbeat_entries[i].timestamp,
    anomaly_type = AnomalyType.MISSING_HEARTBEAT,
    severity = 'medium',
    description = f"Missing heartbeat detected: gap of {gap:.0f}s between heartbeats",
    affected_entries = math.subtract([heartbeat_entries[i, 1], heartbeat_entries[i]],)
    confidence = min(1.0, gap / (self.anomaly_thresholds['missing_heartbeat_minutes'] * 60)),
    details = {
    #                         'gap_seconds': gap,
                            'previous_heartbeat': heartbeat_entries[i-1].timestamp.isoformat(),
                            'current_heartbeat': heartbeat_entries[i].timestamp.isoformat()
    #                     }
    #                 )
                    anomalies.append(anomaly)

    #         return anomalies

    #     async def _detect_security_anomalies(
    #         self,
    #         entries: List[LogEntry],
    #         time_window: int
    #     ) -> List[LogAnomaly]:
    #         """Detect security-related anomalies."""
    anomalies = []

    #         # Look for security-related patterns
    security_patterns = [
                (r'unauthorized|access.denied', AnomalyType.UNAUTHORIZED_ACCESS),
                (r'privilege.escalation|sudo|admin', AnomalyType.UNAUTHORIZED_ACCESS),
                (r'brute.force|multiple.failed.login', AnomalyType.UNAUTHORIZED_ACCESS),
                (r'suspicious.activity|potential.attack', AnomalyType.UNAUTHORIZED_ACCESS)
    #         ]

    #         for pattern, anomaly_type in security_patterns:
    matching_entries = []
    #             for entry in entries:
    #                 if re.search(pattern, entry.message, re.IGNORECASE):
                        matching_entries.append(entry)

    #             if len(matching_entries) >= 3:  # Threshold for security anomalies
    anomaly = LogAnomaly(
    timestamp = math.subtract(matching_entries[, 1].timestamp,)
    anomaly_type = anomaly_type,
    severity = 'high',
    description = f"Security anomaly detected: pattern '{pattern}' found {len(matching_entries)} times",
    affected_entries = matching_entries,
    confidence = math.divide(min(1.0, len(matching_entries), 10.0),)
    details = {
    #                         'pattern': pattern,
                            'occurrence_count': len(matching_entries),
    #                         'time_window': time_window
    #                     }
    #                 )
                    anomalies.append(anomaly)

    #         return anomalies

    #     async def correlate_logs(
    #         self,
    #         entries: List[LogEntry],
    correlation_patterns: Optional[List[str]] = None
    #     ) -> Dict[str, Any]:
    #         """
    #         Correlate log entries based on patterns and relationships.

    #         Args:
    #             entries: Log entries to correlate
    #             correlation_patterns: Patterns to use for correlation

    #         Returns:
    #             Dictionary containing log correlations
    #         """
    #         try:
    correlations = []

    #             # Default correlation strategies
    #             if not correlation_patterns:
    correlation_patterns = [
    #                     'request_id',  # Correlate by request ID
    #                     'component',   # Correlate by component
    #                     'error_chain', # Correlate error chains
    #                     'time_sequence'  # Correlate by time sequence
    #                 ]

    #             # Correlate by request ID
    #             if 'request_id' in correlation_patterns:
    request_groups = defaultdict(list)
    #                 for entry in entries:
    #                     if entry.request_id:
                            request_groups[entry.request_id].append(entry)

    #                 for request_id, group_entries in request_groups.items():
    #                     if len(group_entries) > 1:
    group_entries.sort(key = lambda x: x.timestamp)

    correlation = LogCorrelation(
    correlation_id = request_id,
    entries = group_entries,
    pattern = 'request_id',
    timeline = {
    #                                 'start': group_entries[0].timestamp,
    #                                 'end': group_entries[-1].timestamp,
                                    'duration': (group_entries[-1].timestamp - group_entries[0].timestamp).total_seconds()
    #                             },
    summary = {
                                    'entry_count': len(group_entries),
    #                                 'components': list(set(e.component for e in group_entries)),
    #                                 'levels': [e.level.value for e in group_entries],
    #                                 'has_errors': any(e.level in [LogLevel.ERROR, LogLevel.CRITICAL] for e in group_entries)
    #                             }
    #                         )
                            correlations.append(correlation)

    #             # Correlate by component
    #             if 'component' in correlation_patterns:
    component_groups = defaultdict(list)
    #                 for entry in entries:
                        component_groups[entry.component].append(entry)

    #                 for component, group_entries in component_groups.items():
    #                     if len(group_entries) > 5:  # Only correlate components with significant activity
    group_entries.sort(key = lambda x: x.timestamp)

    correlation = LogCorrelation(
    correlation_id = f"component_{component}_{int(group_entries[0].timestamp.timestamp())}",
    entries = group_entries,
    pattern = 'component',
    timeline = {
    #                                 'start': group_entries[0].timestamp,
    #                                 'end': group_entries[-1].timestamp,
                                    'duration': (group_entries[-1].timestamp - group_entries[0].timestamp).total_seconds()
    #                             },
    summary = {
    #                                 'component': component,
                                    'entry_count': len(group_entries),
    #                                 'levels': Counter(e.level.value for e in group_entries),
    #                                 'error_rate': sum(1 for e in group_entries if e.level in [LogLevel.ERROR, LogLevel.CRITICAL]) / len(group_entries)
    #                             }
    #                         )
                            correlations.append(correlation)

    #             # Correlate error chains
    #             if 'error_chain' in correlation_patterns:
    #                 error_entries = [e for e in entries if e.level in [LogLevel.ERROR, LogLevel.CRITICAL]]

                    # Simple error chain detection (could be enhanced)
    #                 for i, error_entry in enumerate(error_entries):
    chain_entries = [error_entry]

    #                     # Look for related entries within a short time window
    time_window = timedelta(minutes=5)
    #                     for other_entry in entries:
    #                         if (other_entry != error_entry and
    abs((other_entry.timestamp - error_entry.timestamp)) < = time_window and
    other_entry.component = = error_entry.component):
                                chain_entries.append(other_entry)

    #                     if len(chain_entries) > 2:
    chain_entries.sort(key = lambda x: x.timestamp)

    correlation = LogCorrelation(
    correlation_id = f"error_chain_{int(error_entry.timestamp.timestamp())}",
    entries = chain_entries,
    pattern = 'error_chain',
    timeline = {
    #                                 'start': chain_entries[0].timestamp,
    #                                 'end': chain_entries[-1].timestamp,
                                    'duration': (chain_entries[-1].timestamp - chain_entries[0].timestamp).total_seconds()
    #                             },
    summary = {
    #                                 'trigger_error': error_entry.message,
                                    'entry_count': len(chain_entries),
    #                                 'components': list(set(e.component for e in chain_entries)),
    #                                 'error_count': sum(1 for e in chain_entries if e.level in [LogLevel.ERROR, LogLevel.CRITICAL])
    #                             }
    #                         )
                            correlations.append(correlation)

    self._stats['correlations_found'] + = len(correlations)

    #             # Convert to dict format
    correlations_data = []
    #             for correlation in correlations:
    correlation_dict = asdict(correlation)
    correlation_dict['timeline']['start'] = correlation.timeline['start'].isoformat()
    correlation_dict['timeline']['end'] = correlation.timeline['end'].isoformat()
    correlation_dict['entries'] = [
    #                     asdict(entry) for entry in correlation.entries
    #                 ]
    #                 for entry_dict in correlation_dict['entries']:
    entry_dict['timestamp'] = entry_dict['timestamp'].isoformat()
    entry_dict['level'] = entry_dict['level'].value
                    correlations_data.append(correlation_dict)

    #             return {
    #                 'success': True,
    #                 'correlations': correlations_data,
                    'total_correlations': len(correlations),
    #                 'correlation_patterns': correlation_patterns
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': str(e),
    #                 'error_code': LogAnalyzerErrorCodes.CORRELATION_FAILED
    #             }

    #     async def generate_report(
    #         self,
    time_window: int = 86400,  # 24 hours
    include_patterns: bool = True,
    include_anomalies: bool = True,
    include_correlations: bool = True
    #     ) -> Dict[str, Any]:
    #         """
    #         Generate comprehensive log analysis report.

    #         Args:
    #             time_window: Time window for analysis in seconds
    #             include_patterns: Include pattern detection
    #             include_anomalies: Include anomaly detection
    #             include_correlations: Include correlation analysis

    #         Returns:
    #             Dictionary containing analysis report
    #         """
    #         try:
    #             # Get log entries for analysis
    since = math.subtract(datetime.now(), timedelta(seconds=time_window))
    all_entries = []

    #             for log_source in self.log_sources:
    #                 try:
    entries = await self.parse_log_file(log_source, LogFormat.JSON, since=since)
                        all_entries.extend(entries)
    #                 except:
    #                     try:
    entries = await self.parse_log_file(log_source, LogFormat.TEXT, since=since)
                            all_entries.extend(entries)
    #                     except:
    #                         continue

    #             if not all_entries:
    #                 return {
    #                     'success': False,
    #                     'error': 'No log entries found for analysis',
    #                     'error_code': LogAnalyzerErrorCodes.PARSING_FAILED
    #                 }

    #             # Generate report sections
    report = {
                    'generated_at': datetime.now().isoformat(),
    #                 'time_window': time_window,
    #                 'analysis_period': {
                        'start': since.isoformat(),
                        'end': datetime.now().isoformat()
    #                 },
    #                 'summary': {
                        'total_entries': len(all_entries),
                        'log_sources': len(self.log_sources),
    #                     'components': list(set(e.component for e in all_entries)),
    #                     'levels': Counter(e.level.value for e in all_entries)
    #                 }
    #             }

    #             # Pattern detection
    #             if include_patterns:
    pattern_results = await self.detect_patterns(all_entries)
    report['patterns'] = pattern_results

    #             # Anomaly detection
    #             if include_anomalies:
    anomaly_results = await self.detect_anomalies(all_entries, time_window)
    report['anomalies'] = anomaly_results

    #             # Correlation analysis
    #             if include_correlations:
    correlation_results = await self.correlate_logs(all_entries)
    report['correlations'] = correlation_results

    #             # Add statistics
    report['statistics'] = self._stats.copy()
    report['statistics']['last_analysis'] = datetime.now().isoformat()

    #             # Save report
                await self._save_analysis_report(report)

    #             return {
    #                 'success': True,
    #                 'report': report
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': str(e),
    #                 'error_code': LogAnalyzerErrorCodes.ANALYZER_INIT_FAILED
    #             }

    #     async def _save_analysis_report(self, report: Dict[str, Any]) -> None:
    #         """Save analysis report to file."""
    #         try:
    report_file = self.config_dir / f'analysis_report_{int(datetime.now().timestamp())}.json'
    #             with open(report_file, 'w', encoding='utf-8') as f:
    json.dump(report, f, indent = 2, default=str)

    #         except Exception:
    #             pass  # Don't let report saving failures break analysis

    #     def add_pattern(self, pattern: LogPattern) -> None:
    #         """Add a custom log pattern."""
    self.patterns[pattern.name] = pattern
            self._save_patterns()

    #     def remove_pattern(self, pattern_name: str) -> None:
    #         """Remove a log pattern."""
    #         if pattern_name in self.patterns:
    #             del self.patterns[pattern_name]
                self._save_patterns()

    #     def add_alert_callback(self, callback: Callable[[LogAnomaly], None]) -> None:
    #         """Add a callback for anomaly alerts."""
            self._alert_callbacks.append(callback)

    #     def get_analysis_stats(self) -> Dict[str, Any]:
    #         """Get analysis statistics."""
            return self._stats.copy()

    #     async def export_analysis(
    #         self,
    #         file_path: str,
    format_type: str = 'json',
    time_window: int = 86400
    #     ) -> Dict[str, Any]:
    #         """
    #         Export analysis results to file.

    #         Args:
    #             file_path: Path to export file
                format_type: Export format ('json', 'csv', 'html')
    #             time_window: Time window for analysis

    #         Returns:
    #             Dictionary containing export result
    #         """
    #         try:
    #             # Generate analysis report
    report_result = await self.generate_report(time_window)

    #             if not report_result['success']:
    #                 return report_result

    report = report_result['report']

    #             if format_type == 'json':
    #                 with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(report, f, indent = 2, default=str)

    #             elif format_type == 'csv':
    #                 import csv

    #                 # Export anomalies as CSV
    #                 if 'anomalies' in report and report['anomalies'].get('anomalies'):
    #                     with open(file_path, 'w', newline='', encoding='utf-8') as f:
    fieldnames = ['timestamp', 'anomaly_type', 'severity', 'description', 'confidence']
    writer = csv.DictWriter(f, fieldnames=fieldnames)
                            writer.writeheader()

    #                         for anomaly in report['anomalies']['anomalies']:
                                writer.writerow({
    #                                 'timestamp': anomaly['timestamp'],
    #                                 'anomaly_type': anomaly['anomaly_type'],
    #                                 'severity': anomaly['severity'],
    #                                 'description': anomaly['description'],
    #                                 'confidence': anomaly['confidence']
    #                             })
    #             elif format_type == 'html':
    html_content = self._generate_html_report(report)
    #                 with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(html_content)
    #             else:
    #                 return {
    #                     'success': False,
    #                     'error': f"Unsupported format: {format_type}",
    #                     'error_code': LogAnalyzerErrorCodes.EXPORT_FAILED
    #                 }

    #             return {
    #                 'success': True,
    #                 'message': f"Analysis exported to {file_path}",
    #                 'format': format_type,
    #                 'file_path': file_path
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': f"Error exporting analysis: {str(e)}",
    #                 'error_code': LogAnalyzerErrorCodes.EXPORT_FAILED
    #             }

    #     def _generate_html_report(self, report: Dict[str, Any]) -> str:
    #         """Generate HTML report from analysis data."""
    html = f"""
    #         <!DOCTYPE html>
    #         <html>
    #         <head>
    #             <title>NoodleCore Log Analysis Report</title>
    #             <style>
    #                 body {{ font-family: Arial, sans-serif; margin: 20px; }}
    #                 .header {{ background-color: #f0f0f0; padding: 20px; border-radius: 5px; }}
    #                 .section {{ margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }}
    #                 .anomaly {{ background-color: #ffe6e6; margin: 10px 0; padding: 10px; border-radius: 3px; }}
    #                 .pattern {{ background-color: #e6f3ff; margin: 10px 0; padding: 10px; border-radius: 3px; }}
    #                 .correlation {{ background-color: #f0f8e6; margin: 10px 0; padding: 10px; border-radius: 3px; }}
    #                 table {{ border-collapse: collapse; width: 100%; }}
    #                 th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
    #                 th {{ background-color: #f2f2f2; }}
    #             </style>
    #         </head>
    #         <body>
    <div class = "header">
    #                 <h1>NoodleCore Log Analysis Report</h1>
    #                 <p>Generated: {report['generated_at']}</p>
    #                 <p>Analysis Period: {report['analysis_period']['start']} to {report['analysis_period']['end']}</p>
    #             </div>

    <div class = "section">
    #                 <h2>Summary</h2>
    #                 <p>Total Entries: {report['summary']['total_entries']}</p>
    #                 <p>Log Sources: {report['summary']['log_sources']}</p>
                    <p>Components: {', '.join(report['summary']['components'])}</p>
    #             </div>
    #         """

    #         # Add anomalies section
    #         if 'anomalies' in report:
    html + = """
    <div class = "section">
    #                 <h2>Anomalies Detected</h2>
    #             """
    #             for anomaly in report['anomalies'].get('anomalies', []):
    html + = f"""
    <div class = "anomaly">
                        <h3>{anomaly['anomaly_type'].replace('_', ' ').title()}</h3>
    #                     <p><strong>Severity:</strong> {anomaly['severity']}</p>
    #                     <p><strong>Time:</strong> {anomaly['timestamp']}</p>
    #                     <p><strong>Description:</strong> {anomaly['description']}</p>
    #                     <p><strong>Confidence:</strong> {anomaly['confidence']:.2f}</p>
    #                 </div>
    #                 """
    html + = "</div>"

    #         # Add patterns section
    #         if 'patterns' in report:
    html + = """
    <div class = "section">
    #                 <h2>Patterns Detected</h2>
    #             """
    #             for pattern_name, pattern_data in report['patterns'].get('patterns', {}).items():
    html + = f"""
    <div class = "pattern">
    #                     <h3>{pattern_name}</h3>
    #                     <p><strong>Description:</strong> {pattern_data['description']}</p>
    #                     <p><strong>Severity:</strong> {pattern_data['severity']}</p>
    #                     <p><strong>Count:</strong> {pattern_data['count']}</p>
    #                 </div>
    #                 """
    html + = "</div>"

    html + = """
    #         </body>
    #         </html>
    #         """

    #         return html