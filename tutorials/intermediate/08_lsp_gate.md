# Tutorial 08: LSP Gate

## 📚 Table of Contents
1. [Introduction](#introduction)
2. [What is LSP Gate?](#what-is-lsp-gate)
3. [Supported Language Servers](#supported-language-servers)
4. [Configuration](#configuration)
5. [Gate Types](#gate-types)
6. [Advanced Features](#advanced-features)
7. [Practical Examples](#practical-examples)
8. [Troubleshooting](#troubleshooting)
9. [Best Practices](#best-practices)

---

## Introduction

**LSP Gate** provides IDE-quality syntax and semantic checking as a quality gate in your Noodle Improvement Pipeline. Before any candidate can be merged, it must pass validation through Language Server Protocol (LSP) servers.

### Why LSP Gate?

Traditional CI/CD uses linters and compilers, but they often:
- ❌ Run too late in the pipeline
- ❌ Provide generic feedback
- ❌ Don't understand your project context
- ❌ Are slow to configure

**LSP Gate solves these problems by:**
- ✅ Validating **before** merge consideration
- ✅ Using **IDE-quality** analysis
- ✅ Understanding your **project structure**
- ✅ Providing **instant feedback**

### Real-World Impact

```
Without LSP Gate:
┌─────────────────────────────────────────┐
│ Build → Test → Deploy → Runtime Error  │
│         ↑                               │
│     Syntax error found here!            │
│     (Wasted 30+ minutes)                │
└─────────────────────────────────────────┘

With LSP Gate:
┌─────────────────────────────────────────┐
│ LSP Check → Build → Test → Deploy      │
│    ↑                                    │
│ Error caught instantly!                 │
│ (Saved 30+ minutes)                     │
└─────────────────────────────────────────┘
```

---

## What is LSP Gate?

LSP Gate integrates Language Server Protocol servers into Noodle's quality validation pipeline. Each language server provides:

### Core Capabilities

| Capability | Description | Example |
|------------|-------------|---------|
| **Syntax Validation** | Parse errors and syntax issues | Missing semicolons, unmatched brackets |
| **Semantic Analysis** | Type checking, undefined symbols | Using undefined variables, type mismatches |
| **Code Quality** | Style, complexity, best practices | Unused imports, long functions |
| **Refactoring** | Safe automated code changes | Rename symbol, extract function |
| **IntelliSense** | Code completion and documentation | Auto-complete suggestions |

### How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                    NIP Pipeline Stage                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Candidate (Modified Files)                                 │
│       │                                                     │
│       ▼                                                     │
│  ┌─────────────────┐                                        │
│  │  LSP Gate 1     │  ← TypeScript Server                  │
│  │  (Syntax Check) │                                        │
│  └────────┬────────┘                                        │
│           │ Pass?                                           │
│           ▼                                                 │
│  ┌─────────────────┐                                        │
│  │  LSP Gate 2     │  ← Python Server (pylsp)              │
│  │  (Type Check)   │                                        │
│  └────────┬────────┘                                        │
│           │ Pass?                                           │
│           ▼                                                 │
│  ┌─────────────────┐                                        │
│  │  LSP Gate 3     │  ← Go Server (gopls)                  │
│  │  (Quality Check)│                                        │
│  └────────┬────────┘                                        │
│           │ Pass All?                                       │
│           ▼                                                 │
│     ✓ Candidate Proceeds                                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Supported Language Servers

### Officially Supported

| Language | Server | Installation | Features |
|----------|--------|--------------|----------|
| **TypeScript/JavaScript** | `typescript-language-server` | `npm install -g typescript-language-server` | Full type checking, IntelliSense |
| **Python** | `pylsp` (python-lsp-server) | `pip install python-lsp-server` | Type checking, linting, refactoring |
| **Go** | `gopls` | `go install golang.org/x/tools/gopls@latest` | Native Go support, fast |
| **Rust** | `rust-analyzer` | Included with Rust | Full Rust analysis |
| **Java** | `eclipse-jdtls` | Eclipse JDT LS | Java ecosystem support |
| **C#** | `omnisharp` | `.NET SDK` | .NET languages |
| **C/C++** | `clangd` | LLVM | C/C++ analysis |
| **PHP** | `intelephense` | NPM | PHP IntelliSense |
| **Ruby** | `solargraph` | `gem install solargraph` | Ruby type checking |

### Adding New Language Servers

Noodle supports any LSP-compliant server. Add to `noodle.json`:

```json
{
  "lspGate": {
    "servers": {
      "yourlang": {
        "command": "yourlang-lsp",
        "args": ["--stdio"],
        "filePatterns": ["**/*.yourlang"],
        "timeoutMs": 30000
      }
    }
  }
}
```

---

## Configuration

### Basic Setup

Enable LSP Gate in `noodle.json`:

```json
{
  "improve": {
    "lspGate": {
      "enabled": true,
      "failOnError": true,
      "servers": {
        "typescript": {
          "command": "typescript-language-server",
          "args": ["--stdio"],
          "filePatterns": ["**/*.ts", "**/*.tsx", "**/*.js", "**/*.jsx"],
          "rootPatterns": ["tsconfig.json", "package.json"],
          "timeoutMs": 30000,
          "settings": {
            "typescript": {
              "format": {
                "enable": true
              }
            }
          }
        },
        "python": {
          "command": "pylsp",
          "args": ["--stdio"],
          "filePatterns": ["**/*.py"],
          "rootPatterns": ["pyproject.toml", "setup.py", ".git"],
          "timeoutMs": 30000,
          "settings": {
            "plugins": {
              "pycodestyle": {
                "enabled": true,
                "maxLineLength": 100
              },
              "pyflakes": {
                "enabled": true
              },
              "mccabe": {
                "enabled": true,
                "threshold": 15
              }
            }
          }
        }
      }
    }
  }
}
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enabled` | boolean | `false` | Enable LSP Gate globally |
| `failOnError` | boolean | `true` | Fail validation if any error found |
| `failOnWarning` | boolean | `false` | Fail validation if any warning found |
| `timeoutMs` | number | `30000` | Per-file timeout in milliseconds |
| `maxConcurrentFiles` | number | `5` | Parallel file processing limit |
| `cacheResults` | boolean | `true` | Cache validation results |

---

## Gate Types

### 1. Syntax Gate

Validates that code can be parsed:

```json
{
  "gates": [
    {
      "name": "syntax",
      "level": "error",
      "rules": {
        "requireNoParseErrors": true
      }
    }
  ]
}
```

**Example Error Caught:**
```typescript
// ❌ Syntax Error
function broken() {
  if (true) {
    console.log("missing brace"
}
```

**Output:**
```
[LSP Gate] Syntax validation failed:
  src/app.ts:3:1 - SyntaxError: Unexpected token
```

### 2. Type Gate

Validates type correctness:

```json
{
  "gates": [
    {
      "name": "types",
      "level": "error",
      "rules": {
        "strictNullChecks": true,
        "noImplicitAny": true
      }
    }
  ]
}
```

**Example Error Caught:**
```typescript
// ❌ Type Error
function greet(name: string) {
  return `Hello ${name}`;
}
greet(123); // Error: Argument of type 'number' not assignable to 'string'
```

### 3. Quality Gate

Validates code quality metrics:

```json
{
  "gates": [
    {
      "name": "quality",
      "level": "warning",
      "rules": {
        "maxFunctionLength": 50,
        "maxComplexity": 10,
        "noUnusedImports": true,
        "noConsoleLog": false
      }
    }
  ]
}
```

**Example Warning:**
```typescript
// ⚠️ Quality Warning
function veryLongFunction() {
  // 100+ lines of code...
  // Quality Gate: Function exceeds max length (50)
}
```

### 4. Security Gate

Validates security best practices:

```json
{
  "gates": [
    {
      "name": "security",
      "level": "error",
      "rules": {
        "noEval": true,
        "noHardcodedSecrets": true,
        "noDangerousImports": true
      }
    }
  ]
}
```

**Example Error Caught:**
```typescript
// ❌ Security Error
const code = "alert('XSS')";
eval(code); // Error: Use of eval is not allowed
```

---

## Advanced Features

### 1. Project Context Awareness

LSP servers automatically discover project configuration:

```
project/
├── tsconfig.json           ← TypeScript server reads this
├── pyproject.toml          ← Python server reads this
├── go.mod                  ← Go server reads this
└── src/
    ├── app.ts              ← Validated with tsconfig.json rules
    └── utils.py            ← Validated with pyproject.toml rules
```

### 2. Incremental Validation

Only changed files are validated:

```json
{
  "lspGate": {
    "incremental": true,
    "validateOnlyChanged": true,
    "fallbackToFull": true
  }
}
```

**Performance Impact:**
```
Full Repository (1000 files):    45 seconds
Incremental (5 changed files):    3 seconds
Speedup: 15x faster ⚡
```

### 3. Multi-Language Projects

Different languages in one project:

```json
{
  "lspGate": {
    "servers": {
      "typescript": {
        "filePatterns": ["frontend/**/*.ts"]
      },
      "python": {
        "filePatterns": ["backend/**/*.py"]
      },
      "proto": {
        "filePatterns": ["api/**/*.proto"]
      }
    }
  }
}
```

### 4. Custom Diagnostics

Filter which diagnostics to care about:

```json
{
  "lspGate": {
    "diagnosticFilters": {
      "typescript": {
        "include": ["semantic-error", "type-error"],
        "exclude": ["suggestion", "hint"]
      },
      "python": {
        "include": ["error"],
        "exclude": ["warning", "information"]
      }
    }
  }
}
```

### 5. Auto-Fix Integration

Automatically apply quick fixes:

```json
{
  "lspGate": {
    "autoFix": {
      "enabled": true,
      "fixOnSave": false,
      "rules": [
        "organize-imports",
        "remove-unused",
        "format-document"
      ]
    }
  }
}
```

---

## Practical Examples

### Example 1: Catching Type Errors

**Scenario:** TypeScript project with strict mode

**Configuration:**
```json
{
  "lspGate": {
    "servers": {
      "typescript": {
        "command": "typescript-language-server",
        "args": ["--stdio"],
        "settings": {
          "typescript": {
            "strict": true,
            "strictNullChecks": true
          }
        }
      }
    }
  }
}
```

**Bad Code (Candidate):**
```typescript
interface User {
  name: string;
  age: number;
}

function greet(user: User) {
  console.log(`Hello ${user.name}, you are ${user.age} years old`);
}

// ❌ Missing required field
const invalidUser = { name: "Alice" };
greet(invalidUser);
```

**LSP Gate Output:**
```
❌ LSP Gate Failed: Type Errors
  src/user.ts:11:3 - Type '{ name: string; }' is missing property 'age'
  
Candidate rejected. Fix type errors before proceeding.
```

**Fixed Code:**
```typescript
// ✅ All required fields
const validUser: User = { name: "Alice", age: 30 };
greet(validUser);
```

### Example 2: Python Type Checking with Pylsp

**Configuration:**
```json
{
  "lspGate": {
    "servers": {
      "python": {
        "command": "pylsp",
        "args": ["--stdio"],
        "settings": {
          "plugins": {
            "pylsp_plugins": {
              "pyls_isort": { "enabled": true },
              "pyls_black": { "enabled": true }
            }
          }
        }
      }
    }
  }
}
```

**Bad Code:**
```python
from typing import List

def process_numbers(nums: List[int]) -> int:
    return sum(nums)

# ❌ Type error: passing strings to int parameter
result = process_numbers(["hello", "world"])
```

**LSP Gate Output:**
```
❌ LSP Gate Failed: Type Mismatch
  src/processor.py:7:20 - Argument 1 has incompatible type "List[str]"; 
                          expected "List[int]"
```

### Example 3: Go Validation with Gopls

**Configuration:**
```json
{
  "lspGate": {
    "servers": {
      "go": {
        "command": "gopls",
        "args": ["serve"],
        "filePatterns": ["**/*.go"],
        "env": {
          "GOPATH": "/home/user/go"
        }
      }
    }
  }
}
```

**Bad Code:**
```go
package main

import "fmt"

func main() {
    message := "Hello"
    // ❌ Undefined variable
    fmt.Println(messsage)  // Typo!
}
```

**LSP Gate Output:**
```
❌ LSP Gate Failed: Undefined Variable
  main.go:7:14 - undefined: messsage
  Did you mean: message?
```

### Example 4: Multi-Language Project

**Project Structure:**
```
monorepo/
├── frontend/  (TypeScript)
├── backend/   (Python)
└── shared/    (Protocol Buffers)
```

**Configuration:**
```json
{
  "lspGate": {
    "enabled": true,
    "servers": {
      "typescript": {
        "command": "typescript-language-server",
        "filePatterns": ["frontend/**/*.ts"],
        "rootPatterns": ["frontend/tsconfig.json"]
      },
      "python": {
        "command": "pylsp",
        "filePatterns": ["backend/**/*.py"],
        "rootPatterns": ["backend/pyproject.toml"]
      },
      "proto": {
        "command": "protobuf-language-server",
        "filePatterns": ["shared/**/*.proto"],
        "rootPatterns": ["shared/buf.yaml"]
      }
    }
  }
}
```

**Run Validation:**
```bash
noodle improve --lsp-gate
```

**Output:**
```
✓ TypeScript: 12 files validated (0 errors)
✓ Python: 8 files validated (0 errors)
✓ Proto: 5 files validated (0 errors)

✅ LSP Gate Passed - All languages valid
```

---

## Troubleshooting

### Problem: LSP Server Not Found

**Error:**
```
Failed to start LSP server: Command not found: typescript-language-server
```

**Solution:**
```bash
# Install the missing server
npm install -g typescript-language-server

# Or for Python
pip install python-lsp-server

# Or for Go
go install golang.org/x/tools/gopls@latest
```

### Problem: Timeout on Large Files

**Error:**
```
LSP validation timeout after 30000ms for file: large-file.ts
```

**Solution:**
```json
{
  "lspGate": {
    "timeoutMs": 60000,  // Increase to 60 seconds
    "maxConcurrentFiles": 2  // Reduce parallelization
  }
}
```

### Problem: False Positives

**Issue:** LSP reports errors that aren't actually errors

**Solution:**
```json
{
  "lspGate": {
    "diagnosticFilters": {
      "typescript": {
        "exclude": ["unused-local-variable"]  // Ignore this specific warning
      }
    }
  }
}
```

### Problem: Slow Performance

**Symptoms:** LSP validation takes too long

**Solutions:**

1. **Enable incremental validation:**
```json
{
  "lspGate": {
    "incremental": true,
    "validateOnlyChanged": true
  }
}
```

2. **Reduce concurrency:**
```json
{
  "lspGate": {
    "maxConcurrentFiles": 2
  }
}
```

3. **Enable caching:**
```json
{
  "lspGate": {
    "cacheResults": true,
    "cacheDir": ".noodle/cache/lsp"
  }
}
```

### Problem: Project Configuration Not Detected

**Symptoms:** LSP doesn't respect tsconfig.json or similar

**Solution:**
```json
{
  "lspGate": {
    "servers": {
      "typescript": {
        "rootPatterns": [
          "tsconfig.json",
          "package.json",
          ".git"
        ],
        "workspaceFolders": ["./"]
      }
    }
  }
}
```

---

## Best Practices

### 1. Start with Syntax Gate Only

**Phase 1:** Enable basic syntax checking
```json
{
  "lspGate": {
    "gates": ["syntax"]
  }
}
```

**Phase 2:** Add type checking once stable
```json
{
  "lspGate": {
    "gates": ["syntax", "types"]
  }
}
```

**Phase 3:** Add quality checks
```json
{
  "lspGate": {
    "gates": ["syntax", "types", "quality"]
  }
}
```

### 2. Use Appropriate Severity Levels

```json
{
  "gates": [
    {
      "name": "syntax",
      "level": "error"      // Always fail
    },
    {
      "name": "types",
      "level": "error"      // Usually fail
    },
    {
      "name": "quality",
      "level": "warning"    // Maybe fail
    },
    {
      "name": "style",
      "level": "info"       // Just notify
    }
  ]
}
```

### 3. Configure Realistic Timeouts

```json
{
  "lspGate": {
    "servers": {
      "typescript": {
        "timeoutMs": 30000  // 30 seconds for TS files
      },
      "python": {
        "timeoutMs": 15000  // 15 seconds for Python files
      },
      "go": {
        "timeoutMs": 10000  // 10 seconds for Go files (faster)
      }
    }
  }
}
```

### 4. Exclude Generated Code

```json
{
  "lspGate": {
    "servers": {
      "typescript": {
        "excludePatterns": [
          "**/*.generated.ts",
          "**/node_modules/**/*.ts",
          "**/dist/**/*.ts"
        ]
      }
    }
  }
}
```

### 5. Combine with Other Gates

```json
{
  "improve": {
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
    },
    "gateOrder": ["lsp", "test", "benchmark"]  // Fast → Slow
  }
}
```

**Why this order?**
1. **LSP Gate** (3 seconds) - Fast feedback loop
2. **Test Gate** (30 seconds) - Medium feedback loop
3. **Benchmark Gate** (2 minutes) - Slow feedback loop

### 6. Monitor LSP Performance

```bash
# Check LSP Gate statistics
noodle stats --lsp-gate

# Output:
# LSP Gate Performance:
#   Average time: 2.3s per file
#   Total time: 34.5s for 15 files
#   Cache hit rate: 73%
#   Most common errors:
#     - type-error: 12
#     - unused-import: 8
```

### 7. Use Auto-Fix Judiciously

```json
{
  "lspGate": {
    "autoFix": {
      "enabled": true,
      "rules": [
        "organize-imports",      // ✅ Safe
        "remove-unused"          // ⚠️ Review manually
      ],
      "skipRules": [
        "format-document"        // ❌ Use formatter instead
      ]
    }
  }
}
```

---

## Quick Start

### Step 1: Install Language Servers

```bash
# TypeScript/JavaScript
npm install -g typescript-language-server

# Python
pip install python-lsp-server

# Go
go install golang.org/x/tools/gopls@latest
```

### Step 2: Configure Noodle

Create `noodle.json`:
```json
{
  "improve": {
    "lspGate": {
      "enabled": true,
      "failOnError": true,
      "servers": {
        "typescript": {
          "command": "typescript-language-server",
          "args": ["--stdio"],
          "filePatterns": ["**/*.ts"]
        }
      }
    }
  }
}
```

### Step 3: Run Validation

```bash
noodle improve
```

**Output:**
```
Running NIP v3.0.0...

[1/6] LSP Gate (TypeScript)
  ✓ src/app.ts - No errors
  ✓ src/utils.ts - No errors
  ✓ config/noodle.json - No errors

✅ LSP Gate Passed - 3 files validated
```

---

## Summary

✅ **LSP Gate provides:**
- IDE-quality validation in CI/CD
- Multi-language support via LSP
- Incremental validation for speed
- Customizable gate types and severity

🎯 **Best for:**
- Projects with multiple languages
- Teams valuing code quality
- Fast feedback loops
- Type-safe development

📚 **Next Steps:**
- Tutorial 09: Automatic Rollback
- Tutorial 10: Analytics Dashboard
- Tutorial 11: Advanced Configuration
