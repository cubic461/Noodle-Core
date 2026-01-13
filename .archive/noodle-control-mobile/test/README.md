# Test Suite for NoodleControl Mobile App

This directory contains the comprehensive test suite for the NoodleControl mobile application. The test suite includes unit tests, widget tests, and integration tests to ensure the quality and reliability of the application.

## Test Structure

```
test/
├── integration/                    # Integration tests
│   └── authentication_flow_test.dart
├── src/                           # Source-relative test files
│   ├── core/                      # Core module tests
│   │   ├── repositories/          # Repository tests
│   │   └── network/               # Network layer tests
│   ├── features/                  # Feature module tests
│   │   ├── task_management/       # Task management tests
│   │   ├── settings/              # Settings tests
│   │   └── reasoning_monitoring/  # Reasoning monitoring tests
│   └── shared/                    # Shared module tests
│       ├── widgets/               # Widget tests
│       └── models/                # Model tests
├── test_utils/                    # Test utilities
│   ├── test_helpers.dart          # Helper functions
│   ├── mock_data.dart             # Mock data
│   ├── mock_providers.dart       # Mock providers
│   └── test_config.dart          # Test configuration
├── test_config.yaml              # Test configuration file
├── test_runner.dart               # Test runner script
└── README.md                      # This file
```

## Running Tests

### Using the Test Runner

The recommended way to run tests is using the provided test runner script:

```bash
# Run all tests
dart test/test_runner.dart

# Run only unit tests
dart test/test_runner.dart --unit

# Run only widget tests
dart test/test_runner.dart --widget

# Run only integration tests
dart test/test_runner.dart --integration

# Run tests with coverage report
dart test/test_runner.dart --coverage

# Show help
dart test/test_runner.dart --help
```

### Using Flutter Test

You can also use the standard Flutter test command:

```bash
# Run all tests
flutter test

# Run tests for a specific file
flutter test test/src/core/repositories/auth_repository_test.dart

# Run tests with coverage
flutter test --coverage
```

### Running Tests in VS Code

If you're using VS Code, you can run tests directly from the editor:

1. Open the test file you want to run
2. Click on the "Run" button above the test group or test case
3. View the results in the debug console

## Test Configuration

The test configuration is defined in `test_config.yaml`. This file contains settings for:

- Test environment configuration
- Timeout settings
- Coverage configuration
- Test groups
- Mock configuration
- Reporting configuration
- CI/CD configuration
- Device configuration

## Mock Data and Providers

Mock data is defined in `test/src/test_utils/mock_data.dart` and includes:

- User data
- Device data
- Node data
- Task data
- Project data
- Error responses
- And more...

Mock providers are defined in `test/src/test_utils/mock_providers.dart` and include:

- Repository mocks
- Service mocks
- Network layer mocks
- Shared preference mocks
- Theme mode notifier mocks

## Generating Mock Files

Mock files are generated using the `build_runner` package. To generate mock files:

```bash
# Generate all mock files
flutter packages pub run build_runner build

# Generate mock files with deletion of conflicting outputs
flutter packages pub run build_runner build --delete-conflicting-outputs

# Watch for changes and regenerate automatically
flutter packages pub run build_runner watch
```

## Coverage Reports

To generate coverage reports:

```bash
# Generate coverage using the test runner
dart test/test_runner.dart --coverage

# Generate coverage using flutter test
flutter test --coverage

# Convert coverage to HTML (requires lcov)
genhtml coverage/lcov.info -o coverage/html
```

The coverage report will be generated in the `coverage` directory.

## Test Groups

Tests are organized into the following groups:

- **unit**: Core business logic tests (repositories, services, network layer)
- **widget**: UI component tests (widgets, screens)
- **integration**: End-to-end flow tests (authentication, navigation, etc.)
- **performance**: Performance tests for key components

## Writing Tests

When writing new tests, follow these guidelines:

1. Place test files in the appropriate directory structure
2. Use descriptive test names and descriptions
3. Follow the Arrange-Act-Assert pattern
4. Use mock objects for external dependencies
5. Test both success and failure scenarios
6. Include edge cases and error conditions
7. Use the provided test utilities and mock data
8. Update the mock files if you add new mocks

## Test Descriptions

Test descriptions are defined in `test/src/test_utils/test_config.dart` and include:

- `TestDescriptions.loginSuccess`: "should login successfully with valid credentials"
- `TestDescriptions.loginFailure`: "should show error message with invalid credentials"
- `TestDescriptions.registerDeviceSuccess`: "should register device successfully"
- `TestDescriptions.refreshTokenSuccess`: "should refresh token successfully"
- And more...

Use these descriptions in your tests to maintain consistency.

## Debugging Tests

To debug tests:

1. Set breakpoints in your test code
2. Run the test in debug mode
3. Use the VS Code debugger or your IDE's debugger
4. Use `print` statements for simple debugging
5. Check the test output for error messages

## CI/CD Integration

The test suite is designed to work with CI/CD pipelines. The test configuration includes settings for:

- Parallel execution
- Fail-fast behavior
- Retry failed tests
- Coverage reporting
- Test result reporting

## Troubleshooting

### Common Issues

1. **Mock files not found**: Run `flutter packages pub run build_runner build`
2. **Tests failing with missing dependencies**: Run `flutter packages get`
3. **Tests timing out**: Check the timeout configuration in `test_config.yaml`
4. **Coverage report not generating**: Ensure you have the necessary tools installed

### Getting Help

If you encounter issues with the test suite:

1. Check the Flutter documentation for testing
2. Review the test files for similar test cases
3. Ask for help in the project's communication channels
4. Create an issue in the project's issue tracker

## Best Practices

1. Write tests before writing code (TDD)
2. Keep tests small and focused
3. Use descriptive test names
4. Test one thing at a time
5. Use mocks for external dependencies
6. Keep test data separate from test logic
7. Run tests frequently during development
8. Maintain high test coverage
9. Review test coverage reports regularly
10. Keep tests up to date with code changes