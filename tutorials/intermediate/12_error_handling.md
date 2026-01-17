# Tutorial 12: Error Handling

## 📚 Table of Contents
1. [Introduction](#introduction)
2. [Error Types](#error-types)
3. [Error Detection](#error-detection)
4. [Retry Mechanisms](#retry-mechanisms)
5. [Graceful Degradation](#graceful-degradation)
6. [Error Recovery](#error-recovery)
7. [Error Reporting](#error-reporting)
8. [Best Practices](#best-practices)

---

## Introduction

**Error Handling** ensures your Noodle Improvement Pipeline remains robust and reliable even when things go wrong. From API failures to network timeouts, proper error handling keeps your system running smoothly.

### Why Error Handling?

Without proper error handling:
- ❌ Pipeline fails completely on minor errors
- ❌ No recovery from transient failures
- ❌ Poor error messages make debugging hard
- ❌ Lost work and wasted time

**With proper error handling:**
- ✅ **Resilient** to transient failures
- ✅ **Automatic retry** with exponential backoff
- ✅ **Graceful degradation** when possible
- ✅ **Clear error messages** for debugging
- ✅ **Recovery strategies** for common failures

### Real-World Impact

```
❌ Without Error Handling:
API Timeout → Pipeline Fails → Lost 2 Hours of Work
💸 Wasted LLM costs: $15
😰 Developer stress: High

✅ With Error Handling:
API Timeout → Auto Retry (3x) → Success → Pipeline Continues
⏱️ Time lost: 45 seconds
😊 Developer stress: None
```

---

## Error Types

### 1. Transient Errors

Temporary failures that resolve themselves:

| Error Type | Description | Example | Retry Strategy |
|------------|-------------|---------|----------------|
| **Network Timeout** | Request takes too long | API call > 30s | Retry with backoff |
| **Rate Limit** | Too many requests | `429 Too Many Requests` | Retry after delay |
| **Service Unavailable** | API temporarily down | `503 Service Unavailable` | Retry with backoff |
| **Connection Reset** | Network connection lost | `ECONNRESET` | Retry immediately |

### 2. Permanent Errors

Failures that won't resolve with retries:

| Error Type | Description | Example | Action |
|------------|-------------|---------|--------|
| **Authentication** | Invalid credentials | `401 Unauthorized` | Fix API key |
| **Not Found** | Resource doesn't exist | `404 Not Found` | Check resource path |
| **Permission Denied** | Insufficient permissions | `403 Forbidden` | Update permissions |
| **Invalid Input** | Bad request format | `400 Bad Request` | Fix input data |
| **Quota Exceeded** | Out of quota/credits | `402 Payment Required` | Add credits |

### 3. Application Errors

Errors in application logic:

| Error Type | Description | Example |
|------------|-------------|---------|
| **Validation Error** | Input validation fails | Invalid JSON schema |
| **Configuration Error** | Invalid config settings | Missing required field |
| **Dependency Error** | Missing dependencies | Node modules not installed |
| **Resource Error** | Out of resources | Disk full, OOM |

### 4. LLM-Specific Errors

Errors from LLM providers:

| Error Type | Description | Example |
|------------|-------------|---------|
| **Token Limit** | Request too large | `max_tokens` exceeded |
| **Content Filter** | Content policy violation | Safety filter triggered |
| **Model Unavailable** | Model temporarily down | `model_not_found` |
| **Timeout** | LLM processing too long | Generation > 60s |

---

## Error Detection

### Automatic Error Detection

Noodle automatically detects errors:

```json
{
  "errorHandling": {
    "detection": {
      "enabled": true,
      "checkInterval": 5000,
      "errorPatterns": [
        "ECONNRESET",
        "ETIMEDOUT",
        "ENOTFOUND",
        "503 Service Unavailable",
        "429 Too Many Requests"
      ]
    }
  }
}
```

### Error Detection Hooks

Detect errors at pipeline stages:

```json
{
  "improve": {
    "hooks": {
      "onError": {
        "llm": {
          "enabled": true,
          "actions": ["log", "retry", "notify"]
        },
        "test": {
          "enabled": true,
          "actions": ["log", "snapshot"]
        },
        "benchmark": {
          "enabled": true,
          "actions": ["log", "rollback"]
        }
      }
    }
  }
}
```

### Custom Error Detection

Define custom error patterns:

```json
{
  "errorHandling": {
    "customErrors": [
      {
        "name": "database-connection-lost",
        "pattern": "connection.*terminated",
        "severity": "critical",
        "action": "retry"
      },
      {
        "name": "out-of-memory",
        "pattern": "JavaScript heap out of memory",
        "severity": "critical",
        "action": "restart"
      }
    ]
  }
}
```

---

## Retry Mechanisms

### Basic Retry Configuration

```json
{
  "errorHandling": {
    "retry": {
      "enabled": true,
      "maxRetries": 3,
      "initialDelayMs": 1000,
      "backoffMultiplier": 2
    }
  }
}
```

### Retry Timeline

```
Attempt 1:  Fails
             ↓
Attempt 2:  Retry after 1s (initialDelay)
             ↓
Attempt 3:  Retry after 2s (1s × 2)
             ↓
Attempt 4:  Retry after 4s (2s × 2)
             ↓
Final:      Give up after 4 attempts
```

### Exponential Backoff

Increasing delay between retries:

```json
{
  "retry": {
    "strategy": "exponential",
    "maxRetries": 5,
    "initialDelayMs": 1000,
    "backoffMultiplier": 2,
    "maxDelayMs": 30000
  }
}
```

**Delay calculation:**
```
Retry 1: 1s
Retry 2: 2s (1s × 2)
Retry 3: 4s (2s × 2)
Retry 4: 8s (4s × 2)
Retry 5: 16s (8s × 2)
Max delay: 30s
```

### Linear Backoff

Fixed delay between retries:

```json
{
  "retry": {
    "strategy": "linear",
    "maxRetries": 3,
    "delayMs": 2000
  }
}
```

**Delay calculation:**
```
Retry 1: 2s
Retry 2: 2s
Retry 3: 2s
Total wait time: 6s
```

### Retry for Specific Errors

Only retry certain error types:

```json
{
  "retry": {
    "retryableErrors": [
      "ECONNRESET",
      "ETIMEDOUT",
      "ECONNREFUSED",
      "503",
      "429"
    ],
    "nonRetryableErrors": [
      "401",
      "403",
      "404"
    ]
  }
}
```

### Jitter (Randomized Delay)

Add randomness to prevent thundering herd:

```json
{
  "retry": {
    "strategy": "exponential",
    "jitter": true,
    "jitterRangeMs": 1000
  }
}
```

**With jitter:**
```
Retry 1: 1s + 0.3s = 1.3s
Retry 2: 2s + 0.7s = 2.7s
Retry 3: 4s + 0.2s = 4.2s
```

### Circuit Breaker Pattern

Stop retrying after consecutive failures:

```json
{
  "retry": {
    "circuitBreaker": {
      "enabled": true,
      "failureThreshold": 5,
      "successThreshold": 2,
      "timeoutMs": 60000
    }
  }
}
```

**How it works:**
```
Normal State: Requests pass through
    ↓
5 consecutive failures
    ↓
Open State: Requests fail immediately (no retries)
    ↓
After 60s timeout
    ↓
Half-Open State: Allow 1 request to test
    ↓
If success → Close circuit (resume normal)
If failure → Open circuit again
```

---

## Graceful Degradation

### What is Graceful Degradation?

Continue operating with reduced functionality instead of failing completely.

### LLM Fallback

Use backup LLM if primary fails:

```json
{
  "improve": {
    "llm": {
      "primary": {
        "provider": "z_ai",
        "model": "glm-4.7",
        "apiKey": "${ZAI_API_KEY}"
      },
      "fallbacks": [
        {
          "provider": "openai",
          "model": "gpt-4",
          "apiKey": "${OPENAI_API_KEY}"
        },
        {
          "provider": "anthropic",
          "model": "claude-3-opus",
          "apiKey": "${ANTHROPIC_API_KEY}"
        }
      ]
    }
  }
}
```

**Flow:**
```
Try: Z.ai GLM-4.7
  ↓ Fails
Fallback 1: OpenAI GPT-4
  ↓ Fails
Fallback 2: Anthropic Claude
  ↓ Fails
Give up: Log error, notify user
```

### Reduced Functionality Mode

Operate with limited features:

```json
{
  "improve": {
    "degradedMode": {
      "enabled": true,
      "triggerErrors": ["timeout", "rate_limit"],
      "settings": {
        "parallelExecution": false,
        "maxCandidates": 1,
        "skipGates": ["benchmark", "lsp"],
        "simpleRanking": true
      }
    }
  }
}
```

### Partial Success

Accept partial results:

```json
{
  "improve": {
    "multiCandidate": {
      "acceptPartial": true,
      "minSuccessCount": 2,
      "totalCandidates": 5
    }
  }
}
```

**Scenario:**
```
Generate 5 candidates
  ✅ Candidate 1: Success
  ✅ Candidate 2: Success
  ❌ Candidate 3: Failed (LLM error)
  ✅ Candidate 4: Success
  ❌ Candidate 5: Failed (timeout)

Result: 3/5 successful (≥ 2 minimum)
Action: Continue with 3 successful candidates
```

### Cache Fallback

Use cached results if API fails:

```json
{
  "cache": {
    "fallbackOnError": true,
    "maxAge": 86400000
  }
}
```

---

## Error Recovery

### Automatic Recovery

Recover automatically from errors:

```json
{
  "errorHandling": {
    "recovery": {
      "strategies": [
        {
          "error": "network_timeout",
          "action": "increase_timeout",
          "params": {
            "newTimeout": 60000
          }
        },
        {
          "error": "rate_limit",
          "action": "reduce_concurrency",
          "params": {
            "newConcurrency": 1
          }
        },
        {
          "error": "out_of_memory",
          "action": "restart_worker",
          "params": {
            "memoryLimit": "4GB"
          }
        }
      ]
    }
  }
}
```

### Snapshot Recovery

Recover from last good state:

```json
{
  "errorHandling": {
    "snapshots": {
      "enabled": true,
      "autoRestore": true,
      "keepSnapshots": 5
    }
  }
}
```

**Recovery process:**
```
Error occurs
  ↓
Create snapshot of current state
  ↓
Restore to last known good state
  ↓
Continue from snapshot
```

### Checkpoint Recovery

Resume from checkpoints:

```json
{
  "improve": {
    "checkpoints": {
      "enabled": true,
      "interval": 300000,
      "onError": "resume_from_checkpoint"
    }
  }
}
```

**Timeline:**
```
Start pipeline
  ↓ (5 min)
Checkpoint 1: Candidate generation complete
  ↓ (5 min)
Checkpoint 2: Testing complete
  ↓ (ERROR during benchmarking)
  ↓
Resume from Checkpoint 2
  ↓
Continue from benchmarking
```

### Manual Recovery

Provide manual recovery options:

```json
{
  "errorHandling": {
    "manualRecovery": {
      "enabled": true,
      "prompt": "Error occurred. Choose action:",
      "options": [
        {
          "label": "Retry",
          "action": "retry"
        },
        {
          "label": "Skip failed step",
          "action": "skip"
        },
        {
          "label": "Restore from snapshot",
          "action": "restore_snapshot"
        },
        {
          "label": "Abort",
          "action": "abort"
        }
      ]
    }
  }
}
```

---

## Error Reporting

### Error Logging

Comprehensive error logging:

```json
{
  "logging": {
    "level": "error",
    "errorLog": {
      "file": ".noodle/logs/errors.log",
      "format": "json",
      "includeStack": true,
      "includeContext": true
    }
  }
}
```

**Error log format:**
```json
{
  "timestamp": "2024-01-15T14:30:22Z",
  "level": "error",
  "error": {
    "type": "network_timeout",
    "message": "Request timeout after 30000ms",
    "code": "ETIMEDOUT",
    "stack": "Error: Request timeout\n    at LLMClient.request..."
  },
  "context": {
    "pipeline": "improve",
    "stage": "candidate_generation",
    "attempt": 2,
    "llm": {
      "provider": "z_ai",
      "model": "glm-4.7"
    }
  }
}
```

### Error Notifications

Send notifications on errors:

```json
{
  "errorHandling": {
    "notifications": {
      "enabled": true,
      "channels": [
        {
          "type": "slack",
          "webhook": "${SLACK_WEBHOOK}",
          "severity": ["critical", "error"]
        },
        {
          "type": "email",
          "recipients": ["devops@example.com"],
          "severity": ["critical"]
        }
      ]
    }
  }
}
```

### Error Dashboard

Visual error tracking:

```json
{
  "analytics": {
    "errorTracking": {
      "enabled": true,
      "dashboard": "errors",
      "metrics": [
        "error_count",
        "error_rate",
        "error_type_distribution",
        "recovery_rate"
      ]
    }
  }
}
```

### Error Reports

Generate detailed error reports:

```bash
noodle errors report --last 24h --format json

# Output:
{
  "period": {
    "start": "2024-01-15T00:00:00Z",
    "end": "2024-01-16T00:00:00Z"
  },
  "summary": {
    "total_errors": 23,
    "critical": 2,
    "error_rate": 0.023,
    "recovery_rate": 0.87
  },
  "top_errors": [
    {
      "type": "network_timeout",
      "count": 12,
      "percentage": 52
    },
    {
      "type": "rate_limit",
      "count": 8,
      "percentage": 35
    }
  ]
}
```

---

## Best Practices

### 1. Always Use Retry for Transient Errors

```json
{
  "retry": {
    "enabled": true,
    "retryableErrors": ["timeout", "rate_limit", "5xx"]
  }
}
```

### 2. Don't Retry Permanent Errors

```json
{
  "retry": {
    "nonRetryableErrors": ["401", "403", "404"]
  }
}
```

### 3. Use Exponential Backoff with Jitter

```json
{
  "retry": {
    "strategy": "exponential",
    "jitter": true
  }
}
```

### 4. Implement Circuit Breaker

```json
{
  "retry": {
    "circuitBreaker": {
      "enabled": true,
      "failureThreshold": 5
    }
  }
}
```

### 5. Provide Clear Error Messages

```
❌ Bad: "Error occurred"
✅ Good: "API request timeout: Failed to connect to Z.ai API after 30s. Retry attempt 2/3"
```

### 6. Log Errors with Context

```json
{
  "logging": {
    "includeContext": true
  }
}
```

### 7. Monitor Error Rates

```bash
noodle errors stats --period 24h
```

### 8. Set Up Alerts

```json
{
  "alerts": {
    "rules": [
      {
        "metric": "error_rate",
        "threshold": 0.05,
        "severity": "critical"
      }
    ]
  }
}
```

---

## Quick Start

### Step 1: Enable Basic Retry

```json
{
  "errorHandling": {
    "retry": {
      "enabled": true,
      "maxRetries": 3
    }
  }
}
```

### Step 2: Add LLM Fallback

```json
{
  "improve": {
    "llm": {
      "fallbacks": [
        {
          "provider": "openai",
          "model": "gpt-4"
        }
      ]
    }
  }
}
```

### Step 3: Enable Error Logging

```json
{
  "logging": {
    "errorLog": {
      "file": ".noodle/logs/errors.log"
    }
  }
}
```

### Step 4: Test Error Handling

```bash
noodle improve --dry-run --simulate-errors
```

---

## Summary

✅ **Error Handling provides:**
- Automatic retry with backoff
- LLM provider fallbacks
- Graceful degradation
- Comprehensive error logging
- Circuit breaker pattern
- Error recovery strategies

🎯 **Best for:**
- Production deployments
- Unreliable networks
- Rate-limited APIs
- High-availability systems

📚 **Next Steps:**
- Tutorial 13: Optimization Strategies
- Tutorial 14: Production Deployment
