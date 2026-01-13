# Noodle VS Code Extension Test Suite Documentation

## Overview

This document provides comprehensive information about the test suite for the Noodle VS Code extension. The test suite is designed to ensure the reliability, functionality, and performance of the extension across different scenarios and environments.

## Test Structure

The test suite is organized into the following categories:

### 1. Unit Tests (`test/unit/`)

- **Language Providers**: Tests for completion, diagnostic, hover, definition, and signature help providers
- **Workspace Management**: Tests for project creation, template management, and workspace features
- **AI Assistant**: Tests for AI-powered code generation, analysis, and optimization features
- **Core Features**: Tests for extension activation, configuration, and basic functionality

### 2. Integration Tests (`test/integration/`)

- **End-to-End Workflow**: Complete user scenarios from project creation to code execution
- **Backend Integration**: Tests for communication with NoodleCore services
- **API Communication**: Tests for request/response handling and error scenarios
- **Error Handling**: Tests for recovery mechanisms and error reporting

### 3. UI/UX Tests (`test/ui/`)

- **Command Registration**: Tests for command execution and menu integration
- **Webview Panels**: Tests for custom UI components and interactive features
- **Context Menus**: Tests for right-click context menu functionality
- **Settings Management**: Tests for configuration and preference handling

### 4. Performance Tests (`test/performance/`)

- **Large Projects**: Tests with extensive codebases and complex files
- **Memory Usage**: Tests for memory leak detection and resource monitoring
- **Response Time**: Tests for provider performance under load
- **Concurrent Operations**: Tests for multiple simultaneous operations

## Test Frameworks

### Primary Framework: Jest

- **Configuration**: `jest.config.js` for unit tests
- **Integration**: `jest.integration.config.js` for integration tests
- **UI Tests**: `jest.ui.config.js` for UI/UX tests
- **Performance**: `jest.performance.config.js` for performance tests

### Assertion Library: Chai

- **Expectations**: `chai.expect` for readable assertions
- **Matchers**: Custom matchers for VS Code specific objects
- **Plugins**: `chai-as-promised` for async operations

## Running Tests

### Prerequisites

```bash
# Install dependencies
npm install

# Compile TypeScript
npm run compile

# Run all tests
npm test

# Run specific test categories
npm run test:unit          # Unit tests only
npm run test:integration   # Integration tests only
npm run test:ui            # UI/UX tests only
npm run test:performance   # Performance tests only
npm run test:coverage      # Tests with coverage report
```

### Environment Variables

- `NOODLE_TEST_MODE`: Set to 'mock' for testing with mocked services
- `NOODLE_TEST_TIMEOUT`: Override default test timeout (default: 30000ms)
- `NOODLE_TEST_WORKSPACE`: Path to test workspace directory
- `NOODLE_TEST_DATA`: Path to test data directory

### Test Data Management

Test data is automatically managed by the test utilities:

- **Creation**: Test workspaces and files are created before each test
- **Cleanup**: All test artifacts are cleaned up after each test
- **Isolation**: Each test runs in a clean environment

## Mock Services

### VS Code API Mock

The test suite includes a comprehensive mock of the VS Code API:

- **Window Methods**: `showErrorMessage`, `showInformationMessage`, `createOutputChannel`
- **Workspace Methods**: `getConfiguration`, `getWorkspaceFolder`, `openTextDocument`
- **Command Methods**: `registerCommand`, `executeCommand`
- **Language Methods**: `registerCompletionItemProvider`, `registerHoverProvider`
- **Debug Methods**: `registerDebugConfigurationProvider`, `startDebugging`

### NoodleCore Backend Stub

For isolated testing, the suite includes stub implementations:

- **HTTP Server**: Mock server listening on `0.0.0.0:8080`
- **AI Services**: Mock AI model training and inference endpoints
- **Database**: In-memory database for testing data persistence
- **File System**: Virtual file system for isolated testing

## Coverage Requirements

### Minimum Coverage Targets

- **Statements**: 85% overall coverage
- **Branches**: 80% branch coverage
- **Functions**: 90% function coverage
- **Lines**: 85% line coverage

### Coverage Exclusions

- Test files and test utilities
- Configuration and setup files
- Mock implementations

### Coverage Reporting

Coverage reports are generated in multiple formats:

- **HTML**: Interactive coverage report for detailed analysis
- **LCOV**: Machine-readable format for CI/CD integration
- **Text**: Summary coverage in console output
- **JSON**: Machine-readable format for custom processing

## CI/CD Integration

### GitHub Actions

```yaml
name: Noodle VS Code Extension Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16.x, 18.x]
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
      - run: npm ci
      - run: npm run test:coverage
      - uses: codecov/codecov-action@v3
        with:
          file: ./coverage/lcov.info
```

### Azure DevOps

```yaml
trigger:
  - main
  - pull_request

pool:
  vmImage: 'ubuntu-latest'

steps:
  - task: NodeTool@4
    inputs:
      versionSpec: '16.x'

  - script: |
      npm ci
      npm run test:coverage

  - task: PublishTestResults@2
    condition: succeeded()
    inputs:
      testResultsFiles: '**/*.trx'
      testRunTitle: 'Noodle VS Code Extension Tests'
```

## Test Categories Detail

### Language Provider Tests

#### Completion Provider Tests

- **Basic Completions**: Keywords, variables, and function names
- **AI Completions**: AI-specific commands and model names
- **Context Awareness**: Completions based on current cursor position
- **Performance**: Completion response time under 100ms
- **Cancellation**: Proper handling of cancellation tokens

#### Diagnostic Provider Tests

- **Syntax Validation**: Detection of syntax errors and warnings
- **Semantic Analysis**: Type checking and variable usage
- **Real-time Updates**: Diagnostic updates as user types
- **Error Recovery**: Graceful handling of malformed code
- **Performance**: Diagnostic processing time under 50ms per file

#### Hover Provider Tests

- **Keyword Information**: Hover details for language keywords
- **Function Documentation**: Hover information for function signatures
- **AI Command Info**: Hover details for AI commands
- **Type Information**: Hover details for variable types
- **Performance**: Hover response time under 50ms

#### Definition Provider Tests

- **Go to Definition**: Navigation to function and variable definitions
- **Cross-file References**: Definitions in separate files
- **AI Model Definitions**: Navigation to AI model definitions
- **Performance**: Definition resolution time under 100ms
- **Multiple Definitions**: Handling of ambiguous references

#### Signature Help Provider Tests

- **Function Signatures**: Parameter information for functions
- **AI Command Signatures**: Parameter details for AI commands
- **Overload Resolution**: Handling of multiple function signatures
- **Parameter Highlighting**: Active parameter indication
- **Performance**: Signature help response time under 75ms

### AI Assistant Tests

#### Code Generation Tests

- **Template Generation**: Creation of code from natural language prompts
- **Code Quality**: Generated code follows Noodle coding standards
- **Context Awareness**: Generation based on current file and cursor position
- **Error Handling**: Graceful failure when generation is not possible
- **Performance**: Generation response time under 5 seconds

#### Code Analysis Tests

- **Syntax Analysis**: Detection of code issues and improvements
- **Performance Analysis**: Identification of bottlenecks and optimizations
- **Security Analysis**: Detection of potential security vulnerabilities
- **Refactoring Suggestions**: Code improvement recommendations
- **Performance**: Analysis response time under 3 seconds

#### Model Training Tests

- **Training Workflow**: End-to-end model training process
- **Data Validation**: Proper handling of training datasets
- **Hyperparameter Tuning**: Optimization of model parameters
- **Progress Tracking**: Training progress reporting
- **Performance**: Training completion time under 30 seconds

### Workspace Management Tests

#### Project Creation Tests

- **Template Selection**: Available project templates
- **Directory Structure**: Proper project organization
- **Configuration Files**: Generation of project settings
- **Dependencies**: Installation of required packages
- **Validation**: Project name and path validation

#### Workspace Features Tests

- **File Operations**: Create, read, update, delete operations
- **Folder Management**: Directory creation and navigation
- **Search Functionality**: File and content search
- **Settings Management**: Configuration persistence and updates
- **Multi-root Workspaces**: Handling of multiple project folders

### Integration Tests

#### End-to-End Workflow Tests

- **Project Creation**: Complete workflow from template to running code
- **Code Editing**: File creation, editing, and saving
- **Build Process**: Compilation and error handling
- **Debug Session**: Setting breakpoints and stepping through code
- **AI Integration**: Using AI features within the complete workflow

#### Backend Integration Tests

- **Service Discovery**: Automatic detection of NoodleCore services
- **Authentication**: Secure connection to backend services
- **Data Synchronization**: Workspace state synchronization
- **Offline Mode**: Functionality without backend connection
- **Error Recovery**: Handling of service unavailability

#### API Communication Tests

- **Request Validation**: Proper request format and parameters
- **Response Handling**: Processing of different response types
- **Error Scenarios**: Network errors, timeouts, and service failures
- **Retry Logic**: Automatic retry with exponential backoff
- **Rate Limiting**: Respect for API rate limits

### UI/UX Tests

#### Command Registration Tests

- **Command Discovery**: Commands appear in command palette
- **Command Execution**: Proper command handling and results
- **Keyboard Shortcuts**: Default and custom key bindings
- **Context Menus**: Right-click menu integration
- **Menu Visibility**: Commands show/hide based on context

#### Webview Panel Tests

- **Panel Creation**: Proper webview initialization
- **Message Passing**: Communication between extension and webview
- **Content Rendering**: HTML/CSS rendering and updates
- **User Interaction**: Button clicks, form submissions, and input handling
- **Panel Lifecycle**: Proper show, hide, and disposal

#### Settings Management Tests

- **Configuration UI**: Settings panel functionality
- **Settings Validation**: Input validation and error handling
- **Settings Persistence**: Configuration saving and loading
- **Default Values**: Proper initialization of settings
- **Settings Synchronization**: Cross-session configuration sync

### Performance Tests

#### Large Project Tests

- **File Count**: Handling of projects with 1000+ files
- **File Size**: Processing of large files (>1MB)
- **Memory Usage**: Monitoring of memory consumption
- **Response Time**: Provider performance under load
- **Concurrent Operations**: Multiple simultaneous file operations

#### Memory Leak Tests

- **Provider Disposal**: Proper cleanup of event listeners
- **Resource Management**: Memory usage tracking
- **Long-running Tests**: Extended operation monitoring
- **Garbage Collection**: Forced cleanup verification
- **Memory Profiling**: Detailed memory usage analysis

## Troubleshooting

### Common Issues

1. **Test Timeout**: Increase `NOODLE_TEST_TIMEOUT` for slow tests
2. **Mock Failures**: Check mock setup in `test/setup.ts`
3. **Import Errors**: Verify TypeScript compilation and module resolution
4. **Coverage Gaps**: Use `npm run test:coverage --verbose` for details

### Debug Mode

Run tests with additional debugging:

```bash
# Debug unit tests
NOODLE_TEST_MODE=debug npm run test:unit

# Debug integration tests
NOODLE_TEST_MODE=debug npm run test:integration

# Debug with VS Code extension host
npm run test:e2e --debug
```

## Best Practices

### Test Writing

1. **Descriptive Names**: Clear test names that describe the scenario
2. **Arrange-Act-Assert**: Structure tests for clarity
3. **Test Isolation**: Each test should be independent
4. **Mock Verification**: Verify mock behavior matches expectations
5. **Error Testing**: Test both success and failure scenarios

### Test Data

1. **Realistic Data**: Use representative sample code
2. **Edge Cases**: Test boundary conditions and invalid inputs
3. **Performance Data**: Include large files and complex scenarios
4. **Privacy**: No sensitive information in test data

### CI/CD

1. **Parallel Execution**: Run tests in parallel for faster feedback
2. **Fail Fast**: Configure CI to fail immediately on test failures
3. **Coverage Gates**: Prevent merges with decreased coverage
4. **Artifact Retention**: Keep test artifacts for debugging

## Contributing

When adding new tests:

1. Follow the existing test structure and naming conventions
2. Update this documentation with new test categories
3. Ensure adequate test coverage for new features
4. Add performance tests for any new functionality
5. Update CI/CD configuration as needed

For detailed implementation examples, see the test files in the respective directories:

- `test/unit/` for unit test implementations
- `test/integration/` for integration test implementations
- `test/ui/` for UI/UX test implementations
- `test/performance/` for performance test implementations
