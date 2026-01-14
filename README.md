# Noodle-Core

Noodle-Core is a foundational execution and intelligence platform for AI-augmented software systems, built around the **NoodleCore language**.

It provides a compiler and runtime, an agent framework, an integrated data layer, and multi-language LSP support to reason about, transform, and execute software across languages and environments.

---

## What is NoodleCore?

NoodleCore is a symbolic programming language designed to act as a stable interface between humans, AI systems, and executable software.

Rather than focusing on syntax alone, NoodleCore emphasizes:
- semantic structure
- intent-driven representation
- explicit execution and transformation rules

This allows software to be:
- reasoned about programmatically
- transformed across languages
- partially generated or modified by AI systems
- executed within a controlled and inspectable runtime

In Noodle-Core, the language is not an add-on — it is the organizing principle.
Everything in the system ultimately becomes NoodleCore.

---

## Platform Overview

Noodle-Core combines several tightly integrated components:

- **NoodleCore Compiler**  
  Translates NoodleCore programs into executable representations.

- **Runtime**  
  Executes NoodleCore programs with explicit control over execution flow and state.

- **Agent Framework**  
  Enables AI-assisted and autonomous processes to operate within defined symbolic boundaries.

- **Data Layer**  
  Provides persistent, inspectable state for programs, agents, and transformations.

- **Multi-language LSP Support**  
  Allows Noodle-Core to interface with existing codebases across 40+ programming languages.

Together, these components form a coherent execution and reasoning substrate rather than a collection of independent tools.

---

## Project Status

Noodle-Core is under active development.

The architecture and language are evolving, and stability guarantees are not yet provided.
Expect breaking changes as the core concepts are refined.

---

## Licensing

Noodle-Core is released under the **PolyForm Noncommercial License 1.0.0**.

- Non-commercial use, including research, education, and personal experimentation, is free and encouraged.
- Commercial use requires a separate commercial license agreement.

This licensing model is intended to support sustainable long-term development while allowing open exploration of the project.

If you are unsure whether your use case qualifies as commercial, feel free to get in touch.

See the `LICENSE` file for the full license text.

---

## Security & API Keys

### ⚠️ IMPORTANT: Never Commit API Keys!

This repository has multiple security measures in place to prevent accidental upload of sensitive information:

#### 🔒 Automated Protection
- **`.gitignore`** - Prevents sensitive files from being tracked
- **Pre-commit hook** - Automatically scans for API keys before commits
- **`.vscode/settings.json`** - Ignored (may contain API keys)

#### 📝 How to Configure AI Providers

When using the Noodle VSCode extension with AI providers (OpenAI, Anthropic, z.ai, etc.), **NEVER** hardcode API keys in your code or commit them to the repository.

**Safe Methods:**

1. **Environment Variable (Recommended):**
   ```bash
   # PowerShell
   $env:NOODLE_AI_API_KEY = "your-api-key-here"
   
   # Windows System Environment Variables:
   # Name: NOODLE_AI_API_KEY
   # Value: your-api-key-here
   ```

2. **VSCode Settings (Local Only):**
   - Settings are stored in `.vscode/settings.json` (ignored by Git)
   - These settings stay on your machine only

3. **Temporary Environment:**
   ```bash
   # For current session only
   set NOODLE_AI_API_KEY=your-api-key-here
   ```

**❌ NEVER DO THIS:**
```typescript
// DON'T: Hardcoded API keys
const apiKey = "sk-1234567890abcdefghijklmnopqrstuvwxyz";

// DON'T: Commit .env files with real keys
// .env files are ignored for a reason!
```

**✅ INSTEAD DO THIS:**
```typescript
// DO: Use environment variables
const apiKey = process.env.NOODLE_AI_API_KEY;

// DO: Use VSCode settings (not committed)
const config = vscode.workspace.getConfiguration('noodle.ai');
const apiKey = config.get('apiKey', '');
```

#### 🛡️ If You Accidentally Committed a Key

If you accidentally commit an API key:
1. **Immediately rotate the key** - Generate a new API key from your provider
2. **Remove from Git history:**
   ```bash
   git filter-branch --tree-filter 'git rm -f path/to/file' HEAD
   ```
3. **Force push:**
   ```bash
   git push origin --force --all
   ```
4. **Contact support** of the API provider to invalidate the old key

---

## Contributing

Contributions are welcome for non-commercial purposes.
Guidelines will be added as the project matures.

---

## Philosophy

Noodle-Core is built with the belief that:
- programming languages are contracts, not just syntax
- AI systems should operate within explicit symbolic structures
- execution, reasoning, and transformation belong in the same system

The goal is not to replace existing languages, but to provide a stable core that can connect them.

