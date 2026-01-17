# Tutorial 10: Analytics Dashboard

## 📚 Table of Contents
1. [Introduction](#introduction)
2. [What is Analytics Dashboard?](#what-is-analytics-dashboard)
3. [Dashboard Components](#dashboard-components)
4. [Metrics Collection](#metrics-collection)
5. [Visualization Options](#visualization-options)
6. [Configuration](#configuration)
7. [Pre-built Dashboards](#pre-built-dashboards)
8. [Custom Dashboards](#custom-dashboards)
9. [Data Export](#data-export)
10. [Best Practices](#best-practices)

---

## Introduction

**Analytics Dashboard** provides real-time visibility into your Noodle Improvement Pipeline's performance, health, and trends. It transforms raw metrics into actionable insights through interactive visualizations.

### Why Analytics Dashboard?

Without analytics:
- ❌ No visibility into pipeline performance
- ❌ Can't identify bottlenecks
- ❌ No trend analysis
- ❌ Difficult to make data-driven decisions

**With Analytics Dashboard:**
- ✅ **Real-time metrics** at your fingertips
- ✅ **Identify bottlenecks** instantly
- ✅ **Track trends** over time
- ✅ **Data-driven decisions** made easy

### Real-World Impact

```
Without Dashboard:
┌─────────────────────────────────────┐
│ "Something feels slow..."           │
│ ↓                                    │
│ Manual investigation (hours)         │
│ ↓                                    │
│ Found bottleneck in testing phase   │
│                                      │
│ Time to insight: 4 hours 🐌           │
└─────────────────────────────────────┘

With Dashboard:
┌─────────────────────────────────────┐
│ Open dashboard → See testing phase  │
│ taking 85% of pipeline time          │
│                                      │
│ Time to insight: 30 seconds ⚡        │
└─────────────────────────────────────┘
```

---

## What is Analytics Dashboard?

The Analytics Dashboard is a web-based interface that displays:
- Pipeline performance metrics
- Candidate success rates
- Resource utilization
- Test trends
- Rollback statistics
- LLM usage and costs

### Dashboard Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Analytics Dashboard                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌───────────────┐  ┌───────────────┐  ┌──────────────┐  │
│  │ Pipeline      │  │ Candidate     │  │ Performance  │  │
│  │ Performance   │  │ Success Rate  │  │ Trends       │  │
│  │               │  │               │  │              │  │
│  │ [Line Chart]  │  │ [Pie Chart]   │  │ [Bar Chart]  │  │
│  └───────────────┘  └───────────────┘  └──────────────┘  │
│                                                             │
│  ┌───────────────┐  ┌───────────────┐  ┌──────────────┐  │
│  │ Resource      │  │ Rollback      │  │ LLM Usage    │  │
│  │ Utilization   │  │ Statistics    │  │ & Costs      │  │
│  │               │  │               │  │              │  │
│  │ [Gauge Chart] │  │ [Heatmap]     │  │ [Table]      │  │
│  └───────────────┘  └───────────────┘  └──────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐ │
│  │                    Timeline                            │ │
│  │  ─────────────────────────────────────────────────    │ │
│  │  [00:00] --- [01:00] --- [02:00] --- [03:00]         │ │
│  │     ✓          ✗          ✓          ✓                │ │
│  └──────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Key Features

| Feature | Description | Benefit |
|---------|-------------|---------|
| **Real-time Updates** | Metrics update every 5 seconds | Always current data |
| **Interactive Charts** | Hover, zoom, filter | Deep exploration |
| **Custom Dashboards** | Build your own views | Tailored to your needs |
| **Alerts** | Threshold-based notifications | Proactive monitoring |
| **Export** | CSV, JSON, PNG | Reporting and sharing |
| **REST API** | Programmatic access | Integrations |

---

## Dashboard Components

### 1. Pipeline Performance Panel

Shows overall pipeline health and performance:

```
┌─────────────────────────────────────┐
│      Pipeline Performance           │
├─────────────────────────────────────┤
│                                     │
│  Total Runs:     1,247              │
│  Success Rate:   94.3% ✓            │
│  Avg Duration:   3m 24s             │
│  Last Run:       2 min ago          │
│                                     │
│  Duration Trend (Last 24h)          │
│   8m │                              │
│   6m │    ╱╲╱╲╱╲                  │
│   4m │  ╱╲╱╲╱╲╱╲                  │
│   2m │╱╲╱╲╱╲╱╲╱╲                  │
│   0m └────────────────────          │
│      00  06  12  18  24             │
│                                     │
└─────────────────────────────────────┘
```

**Metrics Collected:**
- Total pipeline runs
- Success/failure rate
- Average duration
- P50, P95, P99 latencies
- Bottleneck identification

### 2. Candidate Success Rate Panel

Tracks which candidates succeed:

```
┌─────────────────────────────────────┐
│      Candidate Success Rate         │
├─────────────────────────────────────┤
│                                     │
│        ╭─────╮                     │
│       ╱       ╲                    │
│      │  73.2%  │  Success          │
│       ╲       ╱                    │
│        ╰─────╯                     │
│                                     │
│  Refactor    ════ 82%  ████████████│
│  Performance  ════ 68%  ██████████  │
│  Feature     ════ 71%  ██████████  │
│  Bugfix      ════ 89%  ████████████│
│                                     │
└─────────────────────────────────────┘
```

**Breakdown by:**
- Candidate type (refactor, performance, feature, bugfix)
- LLM provider used
- Time of day
- Developer

### 3. Performance Trends Panel

Shows performance improvements/degradations:

```
┌─────────────────────────────────────┐
│        Performance Trends           │
├─────────────────────────────────────┤
│                                     │
│  Response Time (ms)                 │
│   200 │                              │
│   150 │    ┌───┐                    │
│   100 │ ┌─┘   └─┐ ┌───┐             │
│    50 │ │       │ │   │             │
│     0 └─┴───────┴─┴───┴────────     │
│       W1  W2  W3  W4  W5           │
│                                     │
│  Throughput (req/s)                 │
│  2000 │  ┌───┐                      │
│  1500 │  │   │ ┌───┐                │
│  1000 │┌─┘   └─┘   └─┐              │
│   500 ││             │              │
│     0 └┴─────────────┴──────        │
│       W1  W2  W3  W4  W5           │
│                                     │
└─────────────────────────────────────┘
```

**Metrics:**
- Response time
- Throughput
- Memory usage
- CPU utilization
- Error rates

### 4. Resource Utilization Panel

Monitors system resource usage:

```
┌─────────────────────────────────────┐
│       Resource Utilization          │
├─────────────────────────────────────┤
│                                     │
│  CPU    ════════════ 73%            │
│  Memory ═════════ 58%               │
│  Disk   ═══ 23%                     │
│  Network ████ 42%                   │
│                                     │
│  Worktrees: 3 active                │
│  Snapshots: 12 stored               │
│  Cache: 1.2 GB used                 │
│                                     │
└─────────────────────────────────────┘
```

### 5. Rollback Statistics Panel

Tracks rollback frequency and reasons:

```
┌─────────────────────────────────────┐
│       Rollback Statistics           │
├─────────────────────────────────────┤
│                                     │
│  Last 30 Days: 23 rollbacks         │
│                                     │
│  Most Common Triggers:              │
│  ┌─────────────────────────────┐   │
│  │ Performance Regression  ███ │ 12│
│  │ Test Failure           ██  │  8│
│  │ Build Failure          █   │  3│
│  └─────────────────────────────┘   │
│                                     │
│  Avg Recovery Time: 45s            │
│  Fastest: 12s                      │
│  Slowest: 3m 15s                   │
│                                     │
└─────────────────────────────────────┘
```

### 6. LLM Usage & Costs Panel

Tracks LLM API usage and spending:

```
┌─────────────────────────────────────┐
│         LLM Usage & Costs           │
├─────────────────────────────────────┤
│                                     │
│  This Month: $127.43                │
│  Budget: $200.00                    │
│  Remaining: $72.57                  │
│                                     │
│  Provider Breakdown:                │
│  ┌─────────────────────────────┐   │
│  │ Z.ai GLM-4.7      ████████ │$85 │
│  │ OpenAI GPT-4       ███      │$30 │
│  │ Anthropic Claude  █        │$12 │
│  └─────────────────────────────┘   │
│                                     │
│  Total Requests: 8,432              │
│  Avg Tokens/Request: 1,247          │
│                                     │
└─────────────────────────────────────┘
```

---

## Metrics Collection

### Automatic Collection

Metrics are collected automatically during pipeline runs:

```json
{
  "analytics": {
    "collection": {
      "enabled": true,
      "interval": 5000,
      "metrics": [
        "pipeline_duration",
        "candidate_success_rate",
        "test_results",
        "performance_metrics",
        "resource_usage",
        "llm_usage"
      ]
    }
  }
}
```

### Metric Types

| Category | Metrics | Collection Method |
|----------|---------|-------------------|
| **Pipeline** | Duration, status, stages | Pipeline hooks |
| **Candidate** | Type, success, score | Candidate evaluation |
| **Test** | Pass/fail, duration | Test runner output |
| **Performance** | Response time, throughput | Benchmark framework |
| **Resource** | CPU, memory, disk | System monitoring |
| **LLM** | Tokens, cost, latency | API tracking |

### Metrics Storage

Metrics stored in time-series database:

```
.noodle/analytics/
├── metrics/
│   ├── pipeline_duration.json
│   ├── candidate_success_rate.json
│   ├── test_results.json
│   ├── performance_metrics.json
│   └── resource_usage.json
├── rollups/
│   ├── hourly/
│   ├── daily/
│   └── weekly/
└── snapshots/
    └── dashboard_state.json
```

---

## Visualization Options

### 1. Line Charts

Trends over time:

```json
{
  "type": "line",
  "title": "Pipeline Duration Over Time",
  "xAxis": "timestamp",
  "yAxis": "duration_ms",
  "series": ["p50", "p95", "p99"],
  "options": {
    "smooth": true,
    "fillArea": false
  }
}
```

### 2. Bar Charts

Categorical comparisons:

```json
{
  "type": "bar",
  "title": "Success Rate by Candidate Type",
  "xAxis": "candidate_type",
  "yAxis": "success_rate",
  "groupBy": "llm_provider"
}
```

### 3. Pie Charts

Distribution analysis:

```json
{
  "type": "pie",
  "title": "Rollback Trigger Distribution",
  "segments": [
    {"label": "Performance", "value": 12},
    {"label": "Test Failure", "value": 8},
    {"label": "Build Failure", "value": 3}
  ]
}
```

### 4. Gauge Charts

Single value with range:

```json
{
  "type": "gauge",
  "title": "CPU Utilization",
  "value": 73,
  "min": 0,
  "max": 100,
  "ranges": [
    {"min": 0, "max": 50, "color": "green"},
    {"min": 50, "max": 80, "color": "yellow"},
    {"min": 80, "max": 100, "color": "red"}
  ]
}
```

### 5. Heatmaps

Time-based patterns:

```json
{
  "type": "heatmap",
  "title": "Pipeline Runs by Hour",
  "xAxis": "hour_of_day",
  "yAxis": "day_of_week",
  "value": "run_count"
}
```

### 6. Tables

Detailed data view:

```json
{
  "type": "table",
  "title": "Recent Pipeline Runs",
  "columns": [
    "timestamp",
    "duration",
    "status",
    "candidate_type"
  ],
  "sortable": true,
  "filterable": true
}
```

---

## Configuration

### Basic Dashboard Setup

```json
{
  "analytics": {
    "enabled": true,
    "dashboard": {
      "enabled": true,
      "host": "localhost",
      "port": 3001,
      "refreshInterval": 5000
    }
  }
}
```

### Full Configuration

```json
{
  "analytics": {
    "enabled": true,
    
    "collection": {
      "enabled": true,
      "interval": 5000,
      "retentionDays": 90,
      "metrics": [
        "pipeline_duration",
        "candidate_success_rate",
        "test_results",
        "performance_metrics",
        "resource_usage",
        "llm_usage",
        "rollback_stats"
      ]
    },
    
    "dashboard": {
      "enabled": true,
      "host": "0.0.0.0",
      "port": 3001,
      "refreshInterval": 5000,
      "auth": {
        "enabled": false
      }
    },
    
    "storage": {
      "type": "file",
      "path": ".noodle/analytics",
      "rotation": "daily",
      "compression": true
    },
    
    "alerts": {
      "enabled": true,
      "channels": ["console", "slack"],
      "rules": [
        {
          "metric": "pipeline_duration",
          "threshold": 300000,
          "comparison": "greater_than",
          "severity": "warning"
        },
        {
          "metric": "candidate_success_rate",
          "threshold": 0.8,
          "comparison": "less_than",
          "severity": "critical"
        }
      ]
    },
    
    "export": {
      "formats": ["csv", "json"],
      "autoExport": false,
      "exportInterval": 86400000
    }
  }
}
```

---

## Pre-built Dashboards

### Dashboard 1: Overview

High-level system health:

```json
{
  "name": "Overview",
  "layout": "grid",
  "panels": [
    {
      "type": "stat",
      "title": "Total Runs",
      "metric": "pipeline_runs_total",
      "size": "small"
    },
    {
      "type": "stat",
      "title": "Success Rate",
      "metric": "candidate_success_rate",
      "size": "small"
    },
    {
      "type": "stat",
      "title": "Avg Duration",
      "metric": "pipeline_duration_avg",
      "size": "small"
    },
    {
      "type": "stat",
      "title": "LLM Cost (MTD)",
      "metric": "llm_cost_month_to_date",
      "size": "small"
    },
    {
      "type": "line",
      "title": "Pipeline Duration",
      "metric": "pipeline_duration",
      "size": "large"
    },
    {
      "type": "pie",
      "title": "Candidate Types",
      "metric": "candidate_type_distribution",
      "size": "medium"
    }
  ]
}
```

### Dashboard 2: Performance

Deep dive into performance metrics:

```json
{
  "name": "Performance",
  "panels": [
    {
      "type": "line",
      "title": "Response Time (P50, P95, P99)",
      "metrics": ["response_time_p50", "response_time_p95", "response_time_p99"]
    },
    {
      "type": "line",
      "title": "Throughput",
      "metric": "throughput"
    },
    {
      "type": "gauge",
      "title": "Current Response Time",
      "metric": "response_time_current",
      "thresholds": [100, 200, 500]
    },
    {
      "type": "bar",
      "title": "Performance by Candidate Type",
      "metric": "performance_by_candidate_type"
    }
  ]
}
```

### Dashboard 3: Testing

Test analysis and trends:

```json
{
  "name": "Testing",
  "panels": [
    {
      "type": "stat",
      "title": "Test Pass Rate",
      "metric": "test_pass_rate"
    },
    {
      "type": "line",
      "title": "Test Duration Trend",
      "metric": "test_duration"
    },
    {
      "type": "table",
      "title": "Slowest Tests",
      "metric": "test_duration_by_name",
      "limit": 10
    },
    {
      "type": "bar",
      "title": "Test Failures by Suite",
      "metric": "test_failures_by_suite"
    }
  ]
}
```

---

## Custom Dashboards

### Creating Custom Dashboards

Define your own dashboard layout:

```json
{
  "name": "My Custom Dashboard",
  "description": "Focus on what matters to me",
  "panels": [
    {
      "id": "panel-1",
      "type": "line",
      "title": "My Metric",
      "gridPos": { "x": 0, "y": 0, "w": 12, "h": 8 },
      "query": {
        "metric": "custom_metric",
        "aggregation": "avg",
        "groupby": ["candidate_type"]
      }
    }
  ]
}
```

### Custom Metrics

Define your own metrics:

```json
{
  "customMetrics": [
    {
      "name": "business_value_delivered",
      "type": "counter",
      "description": "Business value delivered by improvements"
    },
    {
      "name": "team_velocity",
      "type": "gauge",
      "description": "Team velocity in story points per week"
    }
  ]
}
```

### Custom Queries

Write custom queries for dashboards:

```sql
-- Example: Success rate by LLM provider
SELECT 
  llm_provider,
  COUNT(*) as total,
  SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) as successes,
  SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as success_rate
FROM pipeline_runs
WHERE timestamp > NOW() - INTERVAL '7 days'
GROUP BY llm_provider
ORDER BY success_rate DESC;
```

---

## Data Export

### Export Formats

```json
{
  "export": {
    "formats": ["csv", "json", "png"],
    "csv": {
      "delimiter": ",",
      "includeHeader": true
    },
    "json": {
      "pretty": true
    },
    "png": {
      "width": 1920,
      "height": 1080,
      "dpi": 150
    }
  }
}
```

### Export via CLI

```bash
# Export all metrics to CSV
noodle analytics export --format csv --output metrics.csv

# Export specific time range
noodle analytics export --start 2024-01-01 --end 2024-01-31 --output january.csv

# Export dashboard as PNG
noodle analytics export-dashboard --name "Overview" --format png --output overview.png
```

### Export via API

```bash
# REST API endpoint
curl http://localhost:3001/api/metrics/export?format=json&start=2024-01-01

# Output:
{
  "metrics": [
    {
      "timestamp": "2024-01-15T14:30:00Z",
      "pipeline_duration_ms": 204000,
      "candidate_success_rate": 0.943,
      "llm_cost_usd": 1.27
    }
  ]
}
```

---

## Best Practices

### 1. Set Up Alerts

Get notified of important events:

```json
{
  "alerts": {
    "enabled": true,
    "rules": [
      {
        "name": "High Pipeline Duration",
        "metric": "pipeline_duration_avg",
        "threshold": 300000,
        "comparison": "greater_than",
        "severity": "warning",
        "notification": ["slack"]
      },
      {
        "name": "Low Success Rate",
        "metric": "candidate_success_rate",
        "threshold": 0.8,
        "comparison": "less_than",
        "severity": "critical",
        "notification": ["slack", "email"]
      }
    ]
  }
}
```

### 2. Use Appropriate Time Ranges

Choose the right time window for your analysis:

| Purpose | Time Range |
|---------|-----------|
| Real-time monitoring | Last 5-15 minutes |
| Debugging recent issues | Last 1-24 hours |
| Daily operations | Last 7 days |
| Trend analysis | Last 30-90 days |
| Long-term planning | Last 6-12 months |

### 3. Create Focused Dashboards

Don't show everything at once:

```
❌ Bad: Single dashboard with 50 panels
✅ Good: Multiple focused dashboards:
  - Overview (5-10 key metrics)
  - Performance (detailed performance metrics)
  - Testing (test-specific metrics)
  - Costs (LLM spending analysis)
```

### 4. Regular Review Schedule

Review analytics regularly:

```
Daily:   Check overview dashboard
Weekly:  Review performance trends
Monthly: Analyze cost patterns and optimization opportunities
```

### 5. Export for Reporting

Save regular exports for stakeholders:

```bash
# Weekly export script
#!/bin/bash
DATE=$(date +%Y-%m-%d)
noodle analytics export \
  --start $(date -d '7 days ago' +%Y-%m-%d) \
  --format csv \
  --output "reports/weekly-$DATE.csv"

# Send to stakeholders
mail -s "Weekly Noodle Analytics" team@example.com < "reports/weekly-$DATE.csv"
```

### 6. Monitor Costs

Keep track of LLM spending:

```json
{
  "alerts": {
    "rules": [
      {
        "name": "Budget Alert",
        "metric": "llm_cost_month_to_date",
        "threshold": 150,
        "comparison": "greater_than",
        "severity": "warning",
        "message": "LLM cost exceeded $150 this month"
      }
    ]
  }
}
```

### 7. Use Annotations

Mark important events on charts:

```json
{
  "annotations": [
    {
      "timestamp": "2024-01-15T10:00:00Z",
      "title": "Deployed v3.0.0",
      "description": "Major version upgrade with NIP v3"
    },
    {
      "timestamp": "2024-01-20T14:30:00Z",
      "title": "Added 5 new tutorials",
      "description": "Tutorial progress: 21% → 50%"
    }
  ]
}
```

---

## Quick Start

### Step 1: Enable Analytics

```json
{
  "analytics": {
    "enabled": true,
    "dashboard": {
      "enabled": true
    }
  }
}
```

### Step 2: Start Dashboard

```bash
noodle analytics dashboard
```

**Output:**
```
Analytics Dashboard running at http://localhost:3001
Press Ctrl+C to stop
```

### Step 3: Open in Browser

Navigate to `http://localhost:3001`

### Step 4: Explore

- Browse pre-built dashboards
- Create custom views
- Set up alerts
- Export data

---

## Summary

✅ **Analytics Dashboard provides:**
- Real-time pipeline visibility
- Interactive visualizations
- Custom dashboard builder
- Alert notifications
- Data export capabilities
- REST API access

🎯 **Best for:**
- Monitoring pipeline health
- Identifying bottlenecks
- Tracking trends over time
- Cost optimization
- Data-driven decision making

📚 **Next Steps:**
- Tutorial 11: Advanced Configuration
- Tutorial 12: Error Handling
- Tutorial 13: Optimization Strategies
