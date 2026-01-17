# Tutorial 13: Monitoring & Observability 👁️

**NIP v3.0.0 - Advanced Tutorial Series**

Learn how to implement comprehensive monitoring, observability, and alerting strategies for production NIP deployments.

## Table of Contents

1. [Introduction](#introduction)
2. [Metrics Collection](#metrics-collection)
3. [Distributed Tracing](#distributed-tracing)
4. [Logging Strategies](#logging-strategies)
5. [Health Checks](#health-checks)
6. [Alerting and Incident Response](#alerting-and-incident-response)
7. [SLI/SLO Definitions](#slislo-definitions)
8. [Error Budget Management](#error-budget-management)
9. [Observability Dashboards](#observability-dashboards)
10. [Practical Exercises](#practical-exercises)
11. [Best Practices](#best-practices)

---

## Introduction

Monitoring and observability are critical for maintaining reliable production systems. This tutorial covers implementing a comprehensive observability stack for NIP v3.0.0 applications.

### Key Concepts

- **Observability**: Understanding system behavior through external outputs
- **Monitoring**: Collecting and analyzing metrics
- **Tracing**: Following requests through distributed systems
- **Logging**: Recording events and debugging information

---

## Metrics Collection

### Prometheus Integration

Prometheus is the industry standard for metrics collection. Here's how to integrate it with NIP:

#### Installation

```bash
# Install Prometheus
go install github.com/prometheus/prometheus/cmd/prometheus@latest

# Or using Docker
docker run -d \
  --name prometheus \
  -p 9090:9090 \
  -v /path/to/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus:latest
```

#### NIP Metrics Exporter

Create `internal/monitoring/prometheus.go`:

```go
package monitoring

import (
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promauto"
    "github.com/prometheus/client_golang/prometheus/promhttp"
    "net/http"
)

var (
    // HTTP request metrics
    RequestsTotal = promauto.NewCounterVec(
        prometheus.CounterOpts{
            Name: "nip_http_requests_total",
            Help: "Total number of HTTP requests",
        },
        []string{"method", "endpoint", "status"},
    )

    RequestDuration = promauto.NewHistogramVec(
        prometheus.HistogramOpts{
            Name:    "nip_http_request_duration_seconds",
            Help:    "HTTP request latency",
            Buckets: prometheus.DefBuckets,
        },
        []string{"method", "endpoint"},
    )

    // Business logic metrics
    ProcessingErrors = promauto.NewCounterVec(
        prometheus.CounterOpts{
            Name: "nip_processing_errors_total",
            Help: "Total processing errors",
        },
        []string{"operation", "error_type"},
    )

    ActiveConnections = promauto.NewGauge(
        prometheus.GaugeOpts{
            Name: "nip_active_connections",
            Help: "Current number of active connections",
        },
    )

    // Database metrics
    DBQueryDuration = promauto.NewHistogramVec(
        prometheus.HistogramOpts{
            Name:    "nip_db_query_duration_seconds",
            Help:    "Database query duration",
            Buckets: []float64{.001, .005, .01, .025, .05, .1, .25, .5, 1},
        },
        []string{"query_type", "table"},
    )

    // Cache metrics
    CacheHits = promauto.NewCounterVec(
        prometheus.CounterOpts{
            Name: "nip_cache_hits_total",
            Help: "Total cache hits",
        },
        []string{"cache_type"},
    )

    CacheMisses = promauto.NewCounterVec(
        prometheus.CounterOpts{
            Name: "nip_cache_misses_total",
            Help: "Total cache misses",
        },
        []string{"cache_type"},
    )
)

// Middleware to track HTTP requests
func PrometheusMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        start := time.Now()
        
        // Wrap response writer to capture status code
        wrapped := &responseWriter{ResponseWriter: w, status: 200}
        
        next.ServeHTTP(wrapped, r)
        
        duration := time.Since(start).Seconds()
        
        RequestsTotal.WithLabelValues(
            r.Method,
            r.URL.Path,
            fmt.Sprintf("%d", wrapped.status),
        ).Inc()
        
        RequestDuration.WithLabelValues(
            r.Method,
            r.URL.Path,
        ).Observe(duration)
    })
}

type responseWriter struct {
    http.ResponseWriter
    status int
}

func (w *responseWriter) WriteHeader(status int) {
    w.status = status
    w.ResponseWriter.WriteHeader(status)
}

// Start metrics server
func StartMetricsServer(addr string) {
    http.Handle("/metrics", promhttp.Handler())
    go func() {
        log.Printf("Starting metrics server on %s", addr)
        if err := http.ListenAndServe(addr, nil); err != nil {
            log.Fatalf("Metrics server failed: %v", err)
        }
    }()
}
```

#### Prometheus Configuration

Create `prometheus.yml`:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: 'nip-production'
    environment: 'production'

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - 'alertmanager:9093'

# Rule files
rule_files:
  - '/etc/prometheus/rules/*.yml'

# Scrape configurations
scrape_configs:
  # NIP application metrics
  - job_name: 'nip-app'
    static_configs:
      - targets: ['localhost:9090']
        labels:
          service: 'nip'
          component: 'app'
    scrape_interval: 10s
    metrics_path: '/metrics'

  # Node exporter for system metrics
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
        labels:
          service: 'nip'
          component: 'system'

  # PostgreSQL exporter
  - job_name: 'postgres-exporter'
    static_configs:
      - targets: ['localhost:9187']
        labels:
          service: 'postgres'

  # Redis exporter
  - job_name: 'redis-exporter'
    static_configs:
      - targets: ['localhost:9121']
        labels:
          service: 'redis'
```

### Grafana Dashboards

#### Installation

```bash
# Install Grafana
docker run -d \
  --name grafana \
  -p 3000:3000 \
  -v /path/to/grafana:/var/lib/grafana \
  grafana/grafana:latest
```

#### Pre-configured Dashboard

Create `config/grafana-dashboards/nip-overview.json`:

```json
{
  "dashboard": {
    "title": "NIP Application Overview",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(nip_http_requests_total[5m])",
            "legendFormat": "{{method}} {{endpoint}}"
          }
        ]
      },
      {
        "title": "Request Latency",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(nip_http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "p95"
          },
          {
            "expr": "histogram_quantile(0.99, rate(nip_http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "p99"
          }
        ]
      },
      {
        "title": "Error Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(nip_processing_errors_total[5m])",
            "legendFormat": "{{operation}}: {{error_type}}"
          }
        ]
      },
      {
        "title": "Cache Performance",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(nip_cache_hits_total[5m])",
            "legendFormat": "hits"
          },
          {
            "expr": "rate(nip_cache_misses_total[5m])",
            "legendFormat": "misses"
          }
        ]
      }
    ]
  }
}
```

---

## Distributed Tracing

### OpenTelemetry Integration

Create `internal/monitoring/tracing.go`:

```go
package monitoring

import (
    "context"
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/attribute"
    "go.opentelemetry.io/otel/exporters/jaeger"
    "go.opentelemetry.io/otel/sdk/resource"
    "go.opentelemetry.io/otel/sdk/trace"
    semconv "go.opentelemetry.io/otel/semconv/v1.4.0"
    "go.opentelemetry.io/otel/trace"
)

var tracer trace.Tracer

// InitTracing initializes distributed tracing with Jaeger
func InitTracing(serviceName, jaegerEndpoint string) error {
    // Create Jaeger exporter
    exporter, err := jaeger.New(jaeger.WithCollectorEndpoint(
        jaeger.WithEndpoint(jaegerEndpoint),
    ))
    if err != nil {
        return fmt.Errorf("failed to create Jaeger exporter: %w", err)
    }

    // Create trace provider
    tp := trace.NewTracerProvider(
        trace.WithBatcher(exporter),
        trace.WithResource(resource.NewWithAttributes(
            semconv.SchemaURL,
            semconv.ServiceNameKey.String(serviceName),
            semconv.ServiceVersionKey.String("3.0.0"),
        )),
    )

    // Register as global tracer provider
    otel.SetTracerProvider(tp)
    tracer = otel.Tracer(serviceName)

    return nil
}

// TraceFunction wraps a function with tracing
func TraceFunction(ctx context.Context, name string, attrs ...attribute.KeyValue) (context.Context, trace.Span) {
    return tracer.Start(ctx, name, trace.WithAttributes(attrs...))
}

// TraceHTTPMiddleware adds tracing to HTTP requests
func TraceHTTPMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // Extract trace context from incoming request
        ctx := r.Context()
        
        attrs := []attribute.KeyValue{
            semconv.HTTPMethodKey.String(r.Method),
            semconv.HTTPURLKey.String(r.URL.String()),
            semconv.HTTPSchemeKey.String(r.URL.Scheme),
        }

        ctx, span := tracer.Start(
            ctx,
            r.URL.Path,
            trace.WithAttributes(attrs...),
        )
        defer span.End()

        // Add custom attributes
        span.SetAttributes(
            attribute.String("user_agent", r.UserAgent()),
            attribute.String("remote_addr", r.RemoteAddr),
        )

        // Call next handler
        next.ServeHTTP(w, r.WithContext(ctx))
    })
}

// TraceDatabaseCall wraps database operations
func TraceDatabaseCall(ctx context.Context, queryType, table string) (context.Context, trace.Span) {
    return tracer.Start(ctx, "db."+queryType,
        trace.WithAttributes(
            attribute.String("db.type", queryType),
            attribute.String("db.table", table),
        ),
    )
}

// TraceCacheCall wraps cache operations
func TraceCacheCall(ctx context.Context, operation, key string) (context.Context, trace.Span) {
    return tracer.Start(ctx, "cache."+operation,
        trace.WithAttributes(
            attribute.String("cache.key", key),
        ),
    )
}
```

#### Jaeger Setup

```bash
# Run Jaeger all-in-one
docker run -d \
  --name jaeger \
  -p 5775:5775/udp \
  -p 6831:6831/udp \
  -p 6832:6832/udp \
  -p 5778:5778 \
  -p 16686:16686 \
  -p 14268:14268 \
  -p 14250:14250 \
  -p 9411:9411 \
  jaegertracing/all-in-one:latest
```

#### Usage Example

```go
// In your HTTP handlers
func handleCreateUser(w http.ResponseWriter, r *http.Request) {
    ctx, span := TraceFunction(r.Context(), "CreateUser")
    defer span.End()

    // Add business logic attributes
    span.SetAttributes(
        attribute.String("user.id", userID),
        attribute.String("user.email", email),
    )

    // Trace database call
    dbCtx, dbSpan := TraceDatabaseCall(ctx, "insert", "users")
    err := db.CreateUser(dbCtx, user)
    dbSpan.End()
    if err != nil {
        span.RecordError(err)
        span.SetStatus(codes.Error, "Failed to create user")
        return
    }

    // Trace cache update
    cacheCtx, cacheSpan := TraceCacheCall(ctx, "set", "user:"+userID)
    cache.Set(cacheCtx, "user:"+userID, user)
    cacheSpan.End()

    span.SetStatus(codes.Ok, "User created successfully")
}
```

---

## Logging Strategies

### Structured Logging with Loki

Create `internal/monitoring/logging.go`:

```go
package logging

import (
    "context"
    "fmt"
    "time"
    "go.uber.org/zap"
    "go.uber.org/zap/zapcore"
)

var logger *zap.Logger

// InitLogger initializes structured logging
func InitLogger(level, environment string) error {
    config := zap.Config{
        Level:            zap.NewAtomicLevelAt(getLogLevel(level)),
        Development:      environment == "development",
        Encoding:         "json",
        EncoderConfig: zapcore.EncoderConfig{
            TimeKey:        "timestamp",
            LevelKey:       "level",
            NameKey:        "logger",
            CallerKey:      "caller",
            FunctionKey:    zapcore.OmitKey,
            MessageKey:     "message",
            StacktraceKey:  "stacktrace",
            LineEnding:     zapcore.DefaultLineEnding,
            EncodeLevel:    zapcore.LowercaseLevelEncoder,
            EncodeTime:     zapcore.ISO8601TimeEncoder,
            EncodeDuration: zapcore.SecondsDurationEncoder,
            EncodeCaller:   zapcore.ShortCallerEncoder,
        },
        OutputPaths:      []string{"stdout"},
        ErrorOutputPaths: []string{"stderr"},
    }

    var err error
    logger, err = config.Build()
    if err != nil {
        return fmt.Errorf("failed to initialize logger: %w", err)
    }

    return nil
}

func getLogLevel(level string) zapcore.Level {
    switch level {
    case "debug":
        return zapcore.DebugLevel
    case "info":
        return zapcore.InfoLevel
    case "warn":
        return zapcore.WarnLevel
    case "error":
        return zapcore.ErrorLevel
    default:
        return zapcore.InfoLevel
    }
}

// LogWithRequest adds request context to logs
func LogWithRequest(r *http.Request) *zap.Logger {
    return logger.With(
        zap.String("request_id", getRequestID(r)),
        zap.String("method", r.Method),
        zap.String("path", r.URL.Path),
        zap.String("remote_addr", r.RemoteAddr),
        zap.String("user_agent", r.UserAgent()),
    )
}

// LogError logs errors with context
func LogError(ctx context.Context, msg string, fields ...zap.Field) {
    logger.Error(msg, append(getContextFields(ctx), fields...)...)
}

// LogInfo logs info messages with context
func LogInfo(ctx context.Context, msg string, fields ...zap.Field) {
    logger.Info(msg, append(getContextFields(ctx), fields...)...)
}

func getRequestID(r *http.Request) string {
    if id := r.Header.Get("X-Request-ID"); id != "" {
        return id
    }
    return generateRequestID()
}

func getContextFields(ctx context.Context) []zap.Field {
    fields := []zap.Field{}
    
    if traceID := getTraceID(ctx); traceID != "" {
        fields = append(fields, zap.String("trace_id", traceID))
    }
    
    if userID := getUserID(ctx); userID != "" {
        fields = append(fields, zap.String("user_id", userID))
    }
    
    return fields
}
```

#### Loki Configuration

```yaml
# config/loki-config.yml
server:
  http_listen_port: 3100

common:
  path_prefix: /loki
  storage:
    filesystem:
      chunks_directory: /loki/chunks
      rules_directory: /loki/rules
  replication_factor: 1
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: inmemory

query_range:
  results_cache:
    cache:
      embedded_cache:
        enabled: true
        max_size_mb: 100

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

ruler:
  alertmanager_url: http://localhost:9093

limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h
```

---

## Health Checks

### Health Check Implementation

Create `internal/monitoring/health.go`:

```go
package monitoring

import (
    "context"
    "database/sql"
    "encoding/json"
    "net/http"
    "sync"
    "time"
)

type HealthChecker struct {
    checks map[string]CheckFunc
    mu     sync.RWMutex
}

type CheckFunc func(ctx context.Context) error

type HealthStatus struct {
    Status   string            `json:"status"`
    Checks   map[string]string `json:"checks"`
    Version  string            `json:"version"`
    Timestamp string           `json:"timestamp"`
}

func NewHealthChecker() *HealthChecker {
    return &HealthChecker{
        checks: make(map[string]CheckFunc),
    }
}

func (h *HealthChecker) RegisterCheck(name string, check CheckFunc) {
    h.mu.Lock()
    defer h.mu.Unlock()
    h.checks[name] = check
}

func (h *HealthChecker) CheckHealth(ctx context.Context) HealthStatus {
    h.mu.RLock()
    defer h.mu.RUnlock()

    status := HealthStatus{
        Checks:   make(map[string]string),
        Version:  "3.0.0",
        Timestamp: time.Now().UTC().Format(time.RFC3339),
    }

    overallHealthy := true

    for name, check := range h.checks {
        checkCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
        defer cancel()

        if err := check(checkCtx); err != nil {
            status.Checks[name] = "unhealthy: " + err.Error()
            overallHealthy = false
        } else {
            status.Checks[name] = "healthy"
        }
    }

    if overallHealthy {
        status.Status = "healthy"
    } else {
        status.Status = "unhealthy"
    }

    return status
}

func (h *HealthChecker) Handler() http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
        defer cancel()

        status := h.CheckHealth(ctx)

        w.Header().Set("Content-Type", "application/json")
        if status.Status == "healthy" {
            w.WriteHeader(http.StatusOK)
        } else {
            w.WriteHeader(http.StatusServiceUnavailable)
        }

        json.NewEncoder(w).Encode(status)
    }
}

// Common health checks
func CheckDatabase(db *sql.DB) CheckFunc {
    return func(ctx context.Context) error {
        return db.PingContext(ctx)
    }
}

func CheckRedis(client *redis.Client) CheckFunc {
    return func(ctx context.Context) error {
        return client.Ping(ctx).Err()
    }
}

func CheckHTTP(url string) CheckFunc {
    return func(ctx context.Context) error {
        req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
        if err != nil {
            return err
        }

        resp, err := http.DefaultClient.Do(req)
        if err != nil {
            return err
        }
        defer resp.Body.Close()

        if resp.StatusCode >= 400 {
            return fmt.Errorf("unexpected status code: %d", resp.StatusCode)
        }

        return nil
    }
}
```

#### Readiness Probes

```go
// Readiness check for Kubernetes
func (h *HealthChecker) ReadinessHandler() http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
        defer cancel()

        // Only check critical dependencies
        criticalChecks := []string{"database", "redis"}
        allReady := true

        for _, name := range criticalChecks {
            if check, ok := h.checks[name]; ok {
                if err := check(ctx); err != nil {
                    allReady = false
                    break
                }
            }
        }

        if allReady {
            w.WriteHeader(http.StatusOK)
            fmt.Fprintf(w, "Ready")
        } else {
            w.WriteHeader(http.StatusServiceUnavailable)
            fmt.Fprintf(w, "Not Ready")
        }
    }
}
```

---

## Alerting and Incident Response

### Alert Rules

Create `config/prometheus/alerts.yml`:

```yaml
groups:
  - name: nip_alerts
    interval: 30s
    rules:
      # High error rate
      - alert: HighErrorRate
        expr: rate(nip_processing_errors_total[5m]) > 10
        for: 5m
        labels:
          severity: critical
          service: nip
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} errors/sec for the last 5 minutes"

      # High latency
      - alert: HighLatency
        expr: histogram_quantile(0.95, rate(nip_http_request_duration_seconds_bucket[5m])) > 1
        for: 5m
        labels:
          severity: warning
          service: nip
        annotations:
          summary: "High request latency"
          description: "p95 latency is {{ $value }}s"

      # Service down
      - alert: ServiceDown
        expr: up{job="nip-app"} == 0
        for: 2m
        labels:
          severity: critical
          service: nip
        annotations:
          summary: "NIP service is down"
          description: "NIP service has been down for more than 2 minutes"

      # Database connection pool exhausted
      - alert: DatabasePoolExhausted
        expr: nip_db_connections_active / nip_db_connections_max > 0.9
        for: 5m
        labels:
          severity: warning
          service: nip
        annotations:
          summary: "Database connection pool nearly exhausted"
          description: "Using {{ $value | humanizePercentage }} of connection pool"

      # Cache hit rate low
      - alert: LowCacheHitRate
        expr: rate(nip_cache_hits_total[5m]) / (rate(nip_cache_hits_total[5m]) + rate(nip_cache_misses_total[5m])) < 0.7
        for: 10m
        labels:
          severity: info
          service: nip
        annotations:
          summary: "Low cache hit rate"
          description: "Cache hit rate is {{ $value | humanizePercentage }}"
```

### PagerDuty Integration

```go
// internal/monitoring/alerting.go
package monitoring

import (
    "bytes"
    "encoding/json"
    "net/http"
)

type PagerDutyClient struct {
    integrationKey string
    baseURL        string
}

type PagerDutyEvent struct {
    RoutingKey  string            `json:"routing_key"`
    EventAction string            `json:"event_action"`
    DedupKey    string            `json:"dedup_key,omitempty"`
    Payload     PagerDutyPayload  `json:"payload"`
}

type PagerDutyPayload struct {
    Summary   string            `json:"summary"`
    Severity  string            `json:"severity"`
    Source    string            `json:"source"`
    Timestamp string            `json:"timestamp"`
    CustomDetails map[string]interface{} `json:"custom_details,omitempty"`
}

func NewPagerDutyClient(integrationKey string) *PagerDutyClient {
    return &PagerDutyClient{
        integrationKey: integrationKey,
        baseURL:       "https://events.pagerduty.com/v2/enqueue",
    }
}

func (p *PagerDutyClient) TriggerAlert(summary, severity, dedupKey string, details map[string]interface{}) error {
    event := PagerDutyEvent{
        RoutingKey:  p.integrationKey,
        EventAction: "trigger",
        DedupKey:    dedupKey,
        Payload: PagerDutyPayload{
            Summary:   summary,
            Severity:  severity,
            Source:    "nip",
            Timestamp: time.Now().UTC().Format(time.RFC3339),
            CustomDetails: details,
        },
    }

    body, err := json.Marshal(event)
    if err != nil {
        return err
    }

    req, err := http.NewRequest("POST", p.baseURL, bytes.NewReader(body))
    if err != nil {
        return err
    }

    req.Header.Set("Content-Type", "application/json")
    req.Header.Set("Accept", "application/json")

    resp, err := http.DefaultClient.Do(req)
    if err != nil {
        return err
    }
    defer resp.Body.Close()

    if resp.StatusCode != http.StatusAccepted {
        return fmt.Errorf("PagerDuty returned status %d", resp.StatusCode)
    }

    return nil
}
```

---

## SLI/SLO Definitions

### Service Level Indicators

Create `internal/monitoring/sli.go`:

```go
package monitoring

import (
    "time"
)

// SLI represents a Service Level Indicator
type SLI struct {
    Name         string
    Description  string
    Query        string
    Target       float64
    RollingWindow time.Duration
}

// Common SLIs for NIP
var StandardSLIs = []SLI{
    {
        Name:         "availability",
        Description:  "Percentage of successful requests",
        Query:        "sum(rate(nip_http_requests_total{status!~\"5..\"}[5m])) / sum(rate(nip_http_requests_total[5m]))",
        Target:       0.999,  // 99.9%
        RollingWindow: 30 * 24 * time.Hour, // 30 days
    },
    {
        Name:         "latency",
        Description:  "95th percentile request latency",
        Query:        "histogram_quantile(0.95, rate(nip_http_request_duration_seconds_bucket[5m]))",
        Target:       0.5,    // 500ms
        RollingWindow: 7 * 24 * time.Hour, // 7 days
    },
    {
        Name:         "error_rate",
        Description:  "Percentage of requests returning errors",
        Query:        "sum(rate(nip_http_requests_total{status=~\"5..\"}[5m])) / sum(rate(nip_http_requests_total[5m]))",
        Target:       0.001,  // 0.1%
        RollingWindow: 24 * time.Hour, // 1 day
    },
    {
        Name:         "throughput",
        Description:  "Requests per second",
        Query:        "sum(rate(nip_http_requests_total[5m]))",
        Target:       1000,   // 1000 req/s
        RollingWindow: 1 * time.Hour, // 1 hour
    },
}

// SLO represents Service Level Objective
type SLO struct {
    SLI          SLI
    Objective    float64
    ErrorBudget  ErrorBudget
}

type ErrorBudget struct {
    TargetPercentage  float64
    CurrentPercentage float64
    Remaining        float64
    BurnRate         float64
}

func CalculateSLOCompliance(sli SLI, currentValue float64) float64 {
    if sli.Name == "latency" || sli.Name == "error_rate" {
        // Lower is better
        if currentValue <= sli.Target {
            return 1.0
        }
        return sli.Target / currentValue
    }
    // Higher is better (availability, throughput)
    if currentValue >= sli.Target {
        return 1.0
    }
    return currentValue / sli.Target
}
```

---

## Error Budget Management

### Error Budget Calculator

```go
package monitoring

import (
    "math"
    "time"
)

type ErrorBudget struct {
    TargetSLO          float64
    TimeWindow         time.Duration
    AllowedDowntime    time.Duration
    UsedDowntime       time.Duration
    RemainingBudget    float64
    BurnRate           float64
}

func CalculateErrorBudget(targetSLO float64, window time.Duration) ErrorBudget {
    // Calculate allowed downtime
    totalSeconds := float64(window.Seconds())
    allowedDowntimeSeconds := totalSeconds * (1 - targetSLO)
    
    return ErrorBudget{
        TargetSLO:       targetSLO,
        TimeWindow:      window,
        AllowedDowntime: time.Duration(allowedDowntimeSeconds) * time.Second,
    }
}

func (eb *ErrorBudget) UpdateWithActuals(uptimeSeconds, downtimeSeconds float64) {
    eb.UsedDowntime = time.Duration(downtimeSeconds) * time.Second
    
    totalSeconds := uptimeSeconds + downtimeSeconds
    if totalSeconds > 0 {
        actualUptimePercentage := uptimeSeconds / totalSeconds
        eb.RemainingBudget = (actualUptimePercentage - eb.TargetSLO) / (1 - eb.TargetSLO)
    }
    
    // Calculate burn rate
    elapsedSeconds := float64(eb.TimeWindow.Seconds())
    if elapsedSeconds > 0 {
        eb.BurnRate = downtimeSeconds / elapsedSeconds / (1 - eb.TargetSLO)
    }
}

func (eb *ErrorBudget) ShouldDeprecateFeature() bool {
    // If burn rate > 2, deprecate non-essential features
    return eb.BurnRate > 2.0
}

func (eb *ErrorBudget) IsExhausted() bool {
    return eb.RemainingBudget <= 0
}
```

---

## Observability Dashboards

### Comprehensive Dashboard Configuration

```go
// Create dashboards programmatically
package monitoring

import (
    "encoding/json"
    "os"
)

type Dashboard struct {
    Title       string        `json:"title"`
    Description string        `json:"description"`
    Panels      []Panel       `json:"panels"`
    Variables   []Variable    `json:"variables"`
}

type Panel struct {
    Title   string `json:"title"`
    Type    string `json:"type"`
    Query   string `json:"query"`
    Span    int    `json:"span"`
    Height  int    `json:"height"`
}

type Variable struct {
    Name  string `json:"name"`
    Query string `json:"query"`
}

func CreateNIPOverviewDashboard() Dashboard {
    return Dashboard{
        Title:       "NIP Production Overview",
        Description: "Comprehensive monitoring dashboard for NIP production environment",
        Panels: []Panel{
            {
                Title: "Request Rate (req/s)",
                Type:  "graph",
                Query: "sum(rate(nip_http_requests_total[5m])) by (endpoint)",
                Span:  6,
                Height: 300,
            },
            {
                Title: "Error Rate (%)",
                Type:  "graph",
                Query: "sum(rate(nip_http_requests_total{status=~\"5..\"}[5m])) / sum(rate(nip_http_requests_total[5m])) * 100",
                Span:  6,
                Height: 300,
            },
            {
                Title: "P95 Latency",
                Type:  "graph",
                Query: "histogram_quantile(0.95, sum(rate(nip_http_request_duration_seconds_bucket[5m])) by (le, endpoint))",
                Span:  6,
                Height: 300,
            },
            {
                Title: "P99 Latency",
                Type:  "graph",
                Query: "histogram_quantile(0.99, sum(rate(nip_http_request_duration_seconds_bucket[5m])) by (le, endpoint))",
                Span:  6,
                Height: 300,
            },
            {
                Title: "Active Connections",
                Type:  "stat",
                Query: "nip_active_connections",
                Span:  3,
                Height: 200,
            },
            {
                Title: "Database Connection Pool",
                Type:  "stat",
                Query: "nip_db_connections_active",
                Span:  3,
                Height: 200,
            },
            {
                Title: "Cache Hit Rate",
                Type:  "stat",
                Query: "rate(nip_cache_hits_total[5m]) / (rate(nip_cache_hits_total[5m]) + rate(nip_cache_misses_total[5m])) * 100",
                Span:  3,
                Height: 200,
            },
            {
                Title: "Memory Usage",
                Type:  "stat",
                Query: "process_resident_memory_bytes / 1024 / 1024 / 1024",
                Span:  3,
                Height: 200,
            },
        },
        Variables: []Variable{
            {
                Name:  "environment",
                Query: "label_values(up, environment)",
            },
            {
                Name:  "instance",
                Query: "label_values(up{environment=\"$environment\"}, instance)",
            },
        },
    }
}

func (d *Dashboard) SaveToFile(path string) error {
    data, err := json.MarshalIndent(d, "", "  ")
    if err != nil {
        return err
    }
    return os.WriteFile(path, data, 0644)
}
```

---

## Practical Exercises

### Exercise 1: Setup Basic Metrics Collection

**Objective**: Set up Prometheus and expose basic NIP metrics

1. Implement the Prometheus middleware in your application
2. Add custom business metrics
3. Create Prometheus configuration
4. Verify metrics are being collected
5. Create a simple Grafana dashboard

**Expected Outcome**: You should see request metrics flowing into Prometheus and visualized in Grafana

### Exercise 2: Implement Distributed Tracing

**Objective**: Add end-to-end request tracing

1. Set up Jaeger locally
2. Add OpenTelemetry tracing to your application
3. Add spans for database and cache operations
4. Trace a complete request flow
5. Analyze the trace in Jaeger UI

**Expected Outcome**: Visual trace graphs showing request latency breakdown

### Exercise 3: Setup Alerting

**Objective**: Create meaningful alerts

1. Define alert rules for:
   - High error rate
   - High latency
   - Service unavailability
2. Test alerts by simulating failures
3. Configure PagerDuty integration
4. Verify alert delivery

**Expected Outcome**: Working alert system that notifies on issues

### Exercise 4: Implement SLO Tracking

**Objective**: Track and visualize SLO compliance

1. Define SLOs for your service
2. Implement SLO calculation logic
3. Create SLO dashboard
4. Set up error budget tracking
5. Create alerts for SLO breaches

**Expected Outcome**: Clear visibility into service performance against objectives

---

## Best Practices

### Metrics

1. **Use RED Method**: Focus on Rate, Errors, and Duration
2. **Prevent Label Cardinality Explosion**: Limit label values
3. **Use Histograms for Latency**: Better than averages
4. **Track Business Metrics**: Not just technical metrics
5. **Aggregate Appropriately**: Balance detail and overview

### Logging

1. **Structured Logging**: Use JSON format
2. **Log Correlation IDs**: Link logs to traces
3. **Appropriate Log Levels**: Don't log everything as INFO
4. **Sanitize Sensitive Data**: Never log credentials
5. **Log Key Events**: Not every function call

### Tracing

1. **Propagate Context**: Pass trace context across services
2. **Add Business Attributes**: Make traces meaningful
3. **Set Proper Sampling**: Avoid performance impact
4. **Span Naming**: Use consistent, descriptive names
5. **Handle Async Operations**: Use context properly

### Alerting

1. **Alert on Symptoms**: Not on causes
2. **Make Alerts Actionable**: Include runbooks
3. **Avoid Alert Fatigue**: Reduce noise
4. **Use Severity Levels**: Prioritize appropriately
5. **Test Alerts Regularly**: Verify they work

### SLOs

1. **Be Realistic**: Set achievable targets
2. **Measure What Matters**: Track user-facing metrics
3. **Use Rolling Windows**: Smooth out fluctuations
4. **Plan for Growth**: Build capacity for scale
5. **Review Regularly**: Adjust as needed

---

## Conclusion

This tutorial covered comprehensive monitoring and observability for NIP v3.0.0 applications. You've learned:

- How to implement Prometheus metrics collection
- Setting up distributed tracing with OpenTelemetry
- Structured logging strategies
- Health check and readiness probe implementations
- Alerting and incident response setup
- SLI/SLO definitions and tracking
- Error budget management
- Dashboard creation and configuration

### Next Steps

1. Implement these patterns in your production environment
2. Continuously monitor and refine your observability stack
3. Build custom dashboards for your specific needs
4. Establish incident response procedures
5. Regularly review and update SLOs

For more information, see:
- [Prometheus Documentation](https://prometheus.io/docs/)
- [OpenTelemetry Guide](https://opentelemetry.io/docs/)
- [Grafana Dashboards](https://grafana.com/grafana/dashboards/)
- [SRE Workbook](https://sre.google/workbook/)

---

**Tutorial Complete!** 🎉

You now have a comprehensive monitoring and observability setup for NIP v3.0.0.
