# Contributing to Noodle VS Code Extension

Thank you for your interest in contributing to the Noodle VS Code Extension! This document provides guidelines and information for contributors.

## 🚀 Getting Started

### Prerequisites

- Node.js 16+
- npm 8+
- TypeScript 4.5+
- VS Code 1.74+
- Git

### Setup Development Environment

1. Fork the repository
2. Clone your fork locally
   ```bash
   git clone https://github.com/YOUR_USERNAME/vscode-extension.git
   cd vscode-extension
   ```
3. Install dependencies
   ```bash
   npm install
   ```
4. Create a new branch for your feature
   ```bash
   git checkout -b feature/your-feature-name
   ```

## 📝 Development Workflow

### Running the Extension in Development

```bash
# Compile TypeScript
npm run compile

# Start development mode
npm run watch

# Run tests
npm test

# Package the extension
npm run package
```

### Project Structure

```
noodle-vscode-extension/
├── 📄 package.json                    # Extension manifest
├── 📄 tsconfig.json                   # TypeScript configuration
├── 📄 webpack.config.js                # Webpack configuration
├── 📂 src/                            # Source code
│   ├── 📄 extension.ts                 # Main extension entry
│   ├── 📂 providers/                   # Language providers
│   │   ├── 📄 noodleLanguageProvider.ts
│   │   ├── 📄 completionProvider.ts
│   │   └── 📄 definitionProvider.ts
│   └── 📂 features/                    # Core features
│       ├── 📄 aiAssistant.ts
│       └── 📄 workspaceManager.ts
├── 📂 resources/                       # Resources
│   ├── 📂 icons/                      # Extension icons
│   ├── 📂 themes/                      # Color themes
│   └── 📂 syntax/                      # Syntax highlighting
├── 📂 snippets/                        # Code snippets
├── 📂 test/                            # Test files
└── 📂 out/                             # Compiled output
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
npm test

# Run unit tests only
npm run test:unit

# Run integration tests only
npm run test:integration

# Run E2E tests
npm run test:e2e

# Run tests with coverage
npm run test:coverage
```

### Test Structure

```
test/
├── 📄 setup.ts                        # Test setup
├── 📂 unit/                           # Unit tests
│   └── 📂 providers/                   # Provider tests
├── 📂 integration/                     # Integration tests
└── 📂 e2e/                            # End-to-end tests
```

### Writing Tests

- Use Jest for unit and integration tests
- Use VS Code Test Runner for E2E tests
- Test files should follow the naming convention: `*.test.ts`
- Aim for 80%+ code coverage for new features

```typescript
// Example test
import { CompletionProvider } from '../../src/providers/completionProvider';

describe('CompletionProvider', () => {
    let provider: CompletionProvider;

    beforeEach(() => {
        provider = new CompletionProvider();
    });

    it('should provide completion items', async () => {
        const result = await provider.provideCompletionItems(
            mockDocument,
            mockPosition
        );
        expect(result).toBeDefined();
        expect(result.length).toBeGreaterThan(0);
    });
});
```

## 📋 Code Style Guidelines

### TypeScript/JavaScript

- Use TypeScript for all new code
- Follow the existing code style and patterns
- Use meaningful variable and function names
- Add JSDoc comments for all public APIs
- Use ES6+ features when appropriate

### Formatting

- Use 4 spaces for indentation
- Use single quotes for strings
- Add trailing commas where appropriate
- Keep lines under 120 characters

### Example Code Style

```typescript
/**
 * Provides AI-powered code completion for Noodle language
 */
export class NoodleCompletionProvider implements vscode.CompletionItemProvider {
    /**
     * Provide completion items for the given position
     * @param document The document to provide completions for
     * @param position The position to provide completions at
     * @returns Promise resolving to completion items
     */
    async provideCompletionItems(
        document: vscode.TextDocument,
        position: vscode.Position
    ): Promise<vscode.CompletionItem[]> {
        // Implementation here
        return [];
    }
}
```

## 🐛 Bug Reports

### Reporting Bugs

1. Check existing issues to avoid duplicates
2. Use the bug report template
3. Include:
   - VS Code version
   - Extension version
   - Operating system
   - Steps to reproduce
   - Expected behavior
   - Actual behavior
   - Screenshots if applicable

### Bug Report Template

```markdown
## Bug Description
A clear and concise description of what the bug is.

## To Reproduce
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

## Expected Behavior
A clear and concise description of what you expected to happen.

## Actual Behavior
A clear and concise description of what actually happened.

## Screenshots
If applicable, add screenshots to help explain your problem.

## Environment
- VS Code version: [e.g. 1.74.0]
- Extension version: [e.g. 1.0.0]
- OS: [e.g. Windows 11, macOS 13.0, Ubuntu 22.04]
```

## 💡 Feature Requests

### Requesting Features

1. Check existing issues and feature requests
2. Use the feature request template
3. Provide:
   - Clear description of the feature
   - Use case and motivation
   - Implementation suggestions (optional)

### Feature Request Template

```markdown
## Feature Description
A clear and concise description of the feature you'd like to see added.

## Use Case
Describe the use case for this feature and why it would be useful.

## Implementation Suggestions
If you have ideas on how this could be implemented, please describe them here.
```

## 📤 Submitting Changes

### Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Update documentation if needed
7. Commit your changes with clear messages
8. Push to your fork
9. Create a pull request

### Commit Message Format

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test changes
- `chore`: Maintenance tasks

Examples:
```
feat(completion): add AI-powered code completion

Add intelligent code completion using OpenAI API for Noodle language
support. Includes context-aware suggestions and error handling.

Closes #123
```

### Pull Request Template

```markdown
## Description
A clear description of the changes made.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] E2E tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] Ready for review
```

## 🏷️ Release Process

### Version Management

- Follow semantic versioning (semver)
- Update package.json version
- Update CHANGELOG.md
- Create a git tag

### Publishing

1. Ensure all tests pass
2. Update version numbers
3. Build the extension
4. Test the packaged extension
5. Create release on GitHub
6. Publish to VS Code Marketplace

## 📚 Documentation

### Updating Documentation

- Keep README.md up to date
- Update API documentation for public changes
- Add examples for new features
- Document configuration options

### Documentation Structure

```
docs/
├── 📄 README.md                       # Main documentation
├── 📄 API.md                          # API reference
├── 📄 CONFIGURATION.md               # Configuration options
└── 📄 EXAMPLES.md                     # Usage examples
```

## 🤝 Code of Conduct

### Our Pledge

We are committed to providing a friendly, safe, and welcoming environment for all contributors.

### Expected Behavior

- Be respectful and inclusive
- Use welcoming and inclusive language
- Focus on what is best for the community
- Show empathy towards other community members

### Unacceptable Behavior

- Harassment, discrimination, or derogatory language
- Personal attacks or political discussions
- Publishing private information
- Spam or irrelevant content

## 🔧 Development Tools

### Recommended Extensions

- TypeScript and JavaScript Language Features
- ESLint
- Prettier
- Jest
- GitLens

### VS Code Settings

```json
{
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.fixAll.eslint": true
    },
    "typescript.preferences.importModuleSpecifier": "relative"
}
```

## 📞 Getting Help

### Communication Channels

- GitHub Issues: For bug reports and feature requests
- GitHub Discussions: For general questions and discussions
- Email: dev@noodle.ai for security concerns

### Resources

- [VS Code Extension API](https://code.visualstudio.com/api)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [Webpack Guide](https://webpack.js.org/guides/)

---

Thank you for contributing to the Noodle VS Code Extension! 🎉