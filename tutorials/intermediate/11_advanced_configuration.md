# Tutorial 11: Advanced Configuration

## 📚 Table of Contents
1. [Introduction](#introduction)
2. [Configuration Structure](#configuration-structure)
3. [Environment Variables](#environment-variables)
4. [Configuration Profiles](#configuration-profiles)
5. [Overrides and Inheritance](#overrides-and-inheritance)
6. [Validation and Schemas](#validation-and-schemas)
7. [Secret Management](#secret-management)
8. [Conditional Configuration](#conditional-configuration)
9. [Best Practices](#best-practices)

---

## Introduction

**Advanced Configuration** enables you to customize every aspect of Noodle's behavior through powerful, flexible configuration management. From simple environment variables to complex conditional logic, you can tailor Noodle to your exact needs.

### Why Advanced Configuration?

Without advanced configuration:
- ❌ Hardcoded values scattered everywhere
- ❌ Difficult to switch between environments
- ❌ Secrets exposed in config files
- ❌ Repetitive configuration across projects

**With advanced configuration:**
- ✅ **Centralized** configuration management
- ✅ **Environment-aware** settings
- ✅ **Secure** secret handling
- ✅ **Reusable** configuration profiles
- ✅ **Validated** settings with schemas

### Real-World Impact

```
❌ Before: Hardcoded in multiple files
  .env file, docker-compose.yml, k8s manifest
  API keys everywhere, different values
  "Which config is correct?" 🤔

✅ After: Single source of truth
  noodle.json with profiles
  Secrets in vault
  "One config to rule them all" 🎯
```

---

## Configuration Structure

### noodle.json Overview

The complete configuration structure:

```
noodle.json
├── $schema                    // JSON Schema validation
├── version                    // Config version
├── extends                    // Base config to inherit
├── profiles                   // Environment profiles
│   ├── development
│   ├── staging
│   └── production
├── project                    // Project metadata
├── improve                    // NIP configuration
│   ├── llm                   // LLM settings
│   ├── gates                 // Quality gates
│   ├── rollback              // Rollback config
│   └── ...                   // Other NIP settings
├── analytics                  // Analytics config
├── cache                      // Cache settings
└── logging                    // Logging config
```

### Minimal Configuration

```json
{
  "$schema": "./schema.json",
  "version": "3.0.0",
  "project": {
    "name": "my-project"
  },
  "improve": {
    "llm": {
      "provider": "z_ai",
      "model": "glm-4.7"
    }
  }
}
```

### Complete Configuration Example

```json
{
  "$schema": "./schema.json",
  "version": "3.0.0",
  "extends": "./base-config.json",
  "profiles": {
    "development": {
      "improve": {
        "llm": {
          "temperature": 0.7
        },
        "parallelExecution": false
      }
    },
    "production": {
      "improve": {
        "llm": {
          "temperature": 0.3
        },
        "parallelExecution": true,
        "rollback": {
          "enabled": true
        }
      }
    }
  },
  "project": {
    "name": "my-project",
    "version": "1.0.0",
    "description": "My awesome project"
  },
  "improve": {
    "llm": {
      "provider": "z_ai",
      "model": "glm-4.7",
      "apiBase": "${ZAI_API_BASE}",
      "apiKey": "${ZAI_API_KEY}",
      "temperature": 0.5,
      "maxTokens": 4096,
      "timeout": 30000
    },
    "parallelExecution": {
      "enabled": true,
      "maxParallelWorktrees": 3
    },
    "gates": {
      "lsp": {
        "enabled": true
      },
      "test": {
        "enabled": true,
        "framework": "jest"
      },
      "benchmark": {
        "enabled": true,
        "threshold": 0.15
      }
    },
    "rollback": {
      "enabled": true,
      "strategy": "git_revert"
    }
  },
  "analytics": {
    "enabled": true,
    "dashboard": {
      "port": 3001
    }
  },
  "cache": {
    "enabled": true,
    "dir": ".noodle/cache",
    "maxSizeMB": 1024
  },
  "logging": {
    "level": "info",
    "format": "json",
    "outputs": ["console", "file"]
  }
}
```

---

## Environment Variables

### Variable Substitution

Use `${VAR_NAME}` syntax to reference environment variables:

```json
{
  "improve": {
    "llm": {
      "provider": "${LLM_PROVIDER:-z_ai}",
      "apiKey": "${LLM_API_KEY}",
      "apiBase": "${LLM_API_BASE:-https://open.bigmodel.cn/api/paas/v4/chat/completions}"
    }
  }
}
```

### Default Values

Provide defaults using `${VAR:-default}` syntax:

```json
{
  "improve": {
    "llm": {
      "temperature": "${LLM_TEMPERATURE:-0.5}",
      "maxTokens": "${LLM_MAX_TOKENS:-4096}"
    }
  }
}
```

### Required Variables

Fail if variable is missing using `${VAR?error message}`:

```json
{
  "improve": {
    "llm": {
      "apiKey": "${LLM_API_KEY?LLM_API_KEY environment variable is required}"
    }
  }
}
```

### Common Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `NOODLE_PROFILE` | Active profile | `production` |
| `LLM_PROVIDER` | LLM provider | `z_ai`, `openai`, `anthropic` |
| `LLM_API_KEY` | API key | `sk-...` |
| `LLM_API_BASE` | API base URL | `https://api.openai.com/v1` |
| `NOODLE_CACHE_DIR` | Cache directory | `.noodle/cache` |
| `NOODLE_LOG_LEVEL` | Log level | `debug`, `info`, `warn`, `error` |
| `NOODLE_PARALLEL` | Enable parallel | `true`, `false` |

### Loading from .env File

Create `.env` file:

```bash
# .env
NOODLE_PROFILE=development
LLM_PROVIDER=z_ai
LLM_API_KEY=sk-your-key-here
LLM_TEMPERATURE=0.7
NOODLE_LOG_LEVEL=debug
```

Noodle automatically loads `.env` if present:

```
.noodle/
├── .env                  ← Environment variables (gitignored)
├── .env.example          ← Template (committed to git)
└── noodle.json           ← Main config
```

### .env.example Template

```bash
# .env.example
NOODLE_PROFILE=development
LLM_PROVIDER=z_ai
LLM_API_KEY=your-api-key-here
LLM_TEMPERATURE=0.5
NOODLE_LOG_LEVEL=info
```

---

## Configuration Profiles

### What Are Profiles?

Profiles allow you to maintain multiple configurations for different environments:

```
noodle.json
├── profiles
│   ├── development    ← Local development
│   ├── staging        ← Pre-production testing
│   ├── production     ← Live production
│   └── ci             ← Continuous integration
```

### Profile Structure

```json
{
  "profiles": {
    "development": {
      "improve": {
        "llm": {
          "temperature": 0.7,
          "maxTokens": 2048
        },
        "parallelExecution": false,
        "gates": {
          "test": {
            "enabled": false
          }
        }
      },
      "logging": {
        "level": "debug"
      }
    },
    "staging": {
      "improve": {
        "llm": {
          "temperature": 0.5,
          "maxTokens": 4096
        },
        "parallelExecution": true
      },
      "logging": {
        "level": "info"
      }
    },
    "production": {
      "improve": {
        "llm": {
          "temperature": 0.3,
          "maxTokens": 4096
        },
        "parallelExecution": true,
        "rollback": {
          "enabled": true
        },
        "gates": {
          "lsp": {
            "enabled": true
          },
          "test": {
            "enabled": true
          },
          "benchmark": {
            "enabled": true
          }
        }
      },
      "logging": {
        "level": "warn"
      }
    }
  }
}
```

### Activating Profiles

**Via Environment Variable:**
```bash
export NOODLE_PROFILE=production
noodle improve
```

**Via Command Line:**
```bash
noodle improve --profile production
```

**Via Config File:**
```json
{
  "activeProfile": "production"
}
```

### Profile Inheritance

Profiles inherit from base configuration:

```json
{
  "improve": {
    "llm": {
      "provider": "z_ai",
      "model": "glm-4.7",
      "temperature": 0.5
    }
  },
  "profiles": {
    "development": {
      "improve": {
        "llm": {
          "temperature": 0.7  // Overrides base
        }
      }
    }
  }
}
```

**Result in development profile:**
```json
{
  "improve": {
    "llm": {
      "provider": "z_ai",
      "model": "glm-4.7",
      "temperature": 0.7  // Overridden value
    }
  }
}
```

### Profile-Specific Files

Create profile-specific config files:

```
.noodle/
├── noodle.json              ← Base config
├── profiles/
│   ├── development.json
│   ├── staging.json
│   └── production.json
```

**profile/production.json:**
```json
{
  "improve": {
    "llm": {
      "temperature": 0.3
    },
    "rollback": {
      "enabled": true
    }
  }
}
```

### Common Profile Patterns

| Profile | Use Case | Key Settings |
|---------|----------|--------------|
| **development** | Local development | High temp, no gates, debug logging |
| **testing** | Unit/integration tests | Medium temp, test gates enabled |
| **staging** | Pre-production | Production-like settings |
| **production** | Live environment | Low temp, all gates enabled |
| **ci** | Continuous integration | Fast execution, no interaction |

---

## Overrides and Inheritance

### Configuration Inheritance Chain

Noodle resolves configuration in this order:

```
1. Base config (noodle.json)
2. Profile config (profiles/<name>.json)
3. Environment variables
4. Command-line overrides
```

Later settings override earlier ones.

### Using `extends`

Inherit from another config file:

```json
{
  "extends": "./base-config.json",
  "improve": {
    "llm": {
      "temperature": 0.7  // Override base
    }
  }
}
```

**base-config.json:**
```json
{
  "improve": {
    "llm": {
      "provider": "z_ai",
      "model": "glm-4.7",
      "temperature": 0.5
    }
  }
}
```

### Multiple Extends

Chain multiple configs:

```json
{
  "extends": [
    "./base-config.json",
    "./company-config.json"
  ]
}
```

### Command-Line Overrides

Override settings via CLI:

```bash
# Override LLM temperature
noodle improve --llm.temperature 0.9

# Override multiple settings
noodle improve \
  --llm.temperature 0.9 \
  --parallelExecution.enabled false \
  --logging.level debug

# Use different profile
noodle improve --profile staging
```

### Nested Overrides

Override nested properties using dot notation:

```bash
noodle improve --improve.llm.temperature 0.9
noodle improve --improve.gates.test.enabled false
noodle improve --analytics.dashboard.port 3002
```

### Temporary Overrides

Use `--override` for one-time changes:

```bash
noodle improve --override '{"improve":{"llm":{"temperature":0.9}}}'
```

---

## Validation and Schemas

### JSON Schema Validation

Noodle validates configuration against JSON Schema:

```json
{
  "$schema": "./noodle-schema.json",
  "improve": {
    "llm": {
      "provider": "z_ai",
      "temperature": 0.5
    }
  }
}
```

### Schema Example

**noodle-schema.json:**
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Noodle Configuration",
  "type": "object",
  "required": ["improve"],
  "properties": {
    "improve": {
      "type": "object",
      "required": ["llm"],
      "properties": {
        "llm": {
          "type": "object",
          "required": ["provider", "model"],
          "properties": {
            "provider": {
              "type": "string",
              "enum": ["z_ai", "openai", "anthropic"]
            },
            "model": {
              "type": "string"
            },
            "temperature": {
              "type": "number",
              "minimum": 0,
              "maximum": 2
            },
            "maxTokens": {
              "type": "integer",
              "minimum": 1,
              "maximum": 128000
            }
          }
        }
      }
    }
  }
}
```

### Validation Errors

Invalid configuration produces clear errors:

```bash
$ noodle improve

❌ Configuration Error:
  File: noodle.json
  Property: improve.llm.temperature
  Error: Value must be between 0 and 2
  Received: 3.5
```

### Custom Validation Rules

Define custom validation in config:

```json
{
  "validation": {
    "rules": [
      {
        "property": "improve.llm.temperature",
        "condition": "<= 1.0",
        "message": "Temperature must be <= 1.0 for production"
      },
      {
        "property": "improve.parallelExecution.maxParallelWorktrees",
        "condition": ">= 1 && <= 10",
        "message": "Max parallel worktrees must be between 1 and 10"
      }
    ]
  }
}
```

### Validation On Load

Validate config before running:

```bash
noodle config validate

✅ Configuration is valid
```

---

## Secret Management

### Why Secret Management?

❌ **Bad:** Secrets in config files
```json
{
  "improve": {
    "llm": {
      "apiKey": "sk-abc123..."  // Exposed in git!
    }
  }
}
```

✅ **Good:** Secrets from environment
```json
{
  "improve": {
    "llm": {
      "apiKey": "${LLM_API_KEY}"  // Safe!
    }
  }
}
```

### Environment Variables (Recommended)

Store secrets in environment variables:

```bash
# .env (gitignored)
LLM_API_KEY=sk-abc123...
DATABASE_URL=postgresql://user:pass@host/db
SLACK_WEBHOOK=https://hooks.slack.com/services/...
```

### Secret File

Use encrypted secret file:

```json
// .noodle/secrets.json (encrypted, gitignored)
{
  "llm": {
    "apiKey": "sk-abc123..."
  },
  "integrations": {
    "slack": {
      "webhook": "https://hooks.slack.com/services/..."
    }
  }
}
```

Reference secrets in config:

```json
{
  "improve": {
    "llm": {
      "apiKey": "${secrets.llm.apiKey}"
    }
  }
}
```

### Vault Integration

Integrate with secret vaults:

```json
{
  "secrets": {
    "provider": "hashicorp-vault",
    "address": "${VAULT_ADDR}",
    "token": "${VAULT_TOKEN}",
    "path": "secret/noodle"
  }
}
```

### AWS Secrets Manager

```json
{
  "secrets": {
    "provider": "aws-secrets-manager",
    "region": "us-east-1",
    "secretName": "noodle/prod"
  }
}
```

### Secret Loading Priority

1. Environment variables (highest priority)
2. Secret file
3. Vault/secrets manager
4. Default values (lowest priority)

---

## Conditional Configuration

### Conditional Based on Environment

```json
{
  "improve": {
    "llm": {
      "temperature": "${NODE_ENV:-development === 'production' ? 0.3 : 0.7}"
    }
  }
}
```

### Conditional Based on Platform

```json
{
  "cache": {
    "dir": "${platform === 'windows' ? 'C:\\\\noodle\\\\cache' : '.noodle/cache'}"
  }
}
```

### Conditional Gates

Enable gates based on conditions:

```json
{
  "improve": {
    "gates": {
      "benchmark": {
        "enabled": "${NODE_ENV === 'production'}"
      }
    }
  }
}
```

### Conditional Logic

Use simple expressions:

```json
{
  "improve": {
    "parallelExecution": {
      "maxParallelWorktrees": "${CI ? 1 : 3}"
    }
  }
}
```

### Feature Flags

Enable/disable features:

```json
{
  "features": {
    "experimentalLLM": "${ENABLE_EXPERIMENTAL_LLM:-false}",
    "newRankingStrategy": "${USE_NEW_RANKING:-true}"
  }
}
```

---

## Best Practices

### 1. Use Profiles for Environments

```
✅ Good: Separate profiles
  profiles/development.json
  profiles/production.json

❌ Bad: Comments in config
  "temperature": 0.7  // TODO: Change to 0.3 for prod
```

### 2. Never Commit Secrets

```bash
# .gitignore
.env
.noodle/secrets.json
*.key
*.pem
```

### 3. Provide Example Configs

```bash
# Commit .env.example
# Gitignore .env
```

### 4. Validate Configuration

```bash
noodle config validate
```

### 5. Use Versioned Schemas

```json
{
  "$schema": "./schema-v3.0.0.json",
  "version": "3.0.0"
}
```

### 6. Document Overrides

```bash
# Document required environment variables in README.md
# Provide example commands
```

### 7. Use Configuration Drift Detection

```bash
noodle config diff --profile production
```

---

## Quick Start

### Step 1: Create Base Config

```json
{
  "improve": {
    "llm": {
      "provider": "z_ai",
      "model": "glm-4.7",
      "apiKey": "${LLM_API_KEY}"
    }
  }
}
```

### Step 2: Create Profiles

```bash
mkdir -p profiles
cat > profiles/development.json << EOF
{
  "improve": {
    "llm": {
      "temperature": 0.7
    }
  }
}
EOF
```

### Step 3: Create .env File

```bash
cat > .env << EOF
LLM_API_KEY=your-key-here
NOODLE_PROFILE=development
EOF
```

### Step 4: Validate

```bash
noodle config validate
```

### Step 5: Run

```bash
noodle improve
```

---

## Summary

✅ **Advanced Configuration provides:**
- Environment variable substitution
- Profile-based configuration
- Configuration inheritance
- JSON Schema validation
- Secure secret management
- Conditional logic

🎯 **Best for:**
- Multi-environment projects
- Team collaboration
- Production deployments
- Security-conscious teams

📚 **Next Steps:**
- Tutorial 12: Error Handling
- Tutorial 13: Optimization Strategies
- Tutorial 14: Production Deployment
