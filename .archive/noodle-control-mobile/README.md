# NoodleControl Mobile App

A Flutter mobile application for managing the Noodle AI development environment remotely.

## Features

- **Authentication**: Secure login and device registration
- **Dashboard**: Overview of system status and quick actions
- **IDE Control**: Manage IDE projects and open them remotely
- **Node Management**: Monitor and control compute nodes
- **Reasoning Monitoring**: Track AI tasks and performance metrics
- **Settings**: Configure app preferences and server connections

## Project Structure

```
lib/
├── main.dart                     # App entry point
├── src/
│   ├── core/                     # Core app functionality
│   │   ├── app.dart              # App configuration and utilities
│   │   └── app_router.dart       # Navigation and routing
│   ├── features/                 # Feature modules
│   │   ├── auth/                 # Authentication screens
│   │   ├── dashboard/            # Dashboard screen
│   │   ├── ide_control/          # IDE control screens
│   │   ├── node_management/      # Node management screens
│   │   ├── reasoning_monitoring/ # Reasoning monitoring screens
│   │   └── settings/             # Settings screens
│   └── shared/                   # Shared components and utilities
│       ├── models/               # Data models
│       ├── theme/                # App theme and styling
│       ├── utils/                # Utility functions
│       └── widgets/              # Reusable UI components
```

## Architecture

The app follows a clean architecture pattern with clear separation of concerns:

- **Presentation Layer**: UI screens and widgets
- **Business Logic Layer**: State management and business rules
- **Data Layer**: Models and data sources

### State Management

The app uses Riverpod for state management, providing a reactive and scalable way to manage app state.

### Navigation

Navigation is handled using Go Router, which provides type-safe routing and deep linking support.

### Theming

The app implements Material Design 3 with a custom color scheme based on the Noodle brand identity. It supports light, dark, and system themes.

## Key Components

### Authentication System

- Login screen with server URL configuration
- Device registration with automatic device information collection
- Secure token storage using Flutter Secure Storage

### Dashboard

- Real-time status overview with system metrics
- Quick action cards for easy navigation
- Recent tasks and active nodes display

### IDE Control

- Project listing with search and filtering
- Open/close project functionality
- Project details with language-specific icons

### Node Management

- Node status monitoring with real-time updates
- Resource usage visualization (CPU, memory)
- Node control actions (start, stop, restart)

### Reasoning Monitoring

- Task tracking with progress indicators
- Performance charts using FL Chart
- Task management (cancel, retry)

### Settings

- Server configuration
- Theme selection
- Connection settings
- Account management

## Getting Started

### Prerequisites

- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code with Flutter extensions
- A physical device or emulator for testing

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd noodle_control_mobile_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate code (if needed):
   ```bash
   flutter packages pub run build_runner build
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Configuration

### Server Connection

Configure the server URL in the settings screen or during login. The default URL is `ws://localhost:8080`.

### Authentication

The app supports both login with existing credentials and device registration for new devices.

## Dependencies

Key dependencies include:

- `flutter_riverpod`: State management
- `go_router`: Navigation and routing
- `fl_chart`: Charting and data visualization
- `shared_preferences`: Local storage
- `flutter_secure_storage`: Secure storage
- `device_info_plus`: Device information
- `package_info_plus`: Package information

## Platform Support

The app supports both Android and iOS platforms. Platform-specific configurations are handled in their respective directories.

## Development

### Code Style

The project follows Flutter's official style guide with additional linting rules defined in `analysis_options.yaml`.

### Testing

Unit tests should be placed in the `test/` directory and follow the naming convention `test_*.dart`.

### Build

To build the app for release:

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and ensure they pass
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Demo Application

For a fully functional web demo showcasing the NoodleControl mobile app interface, see the [demo directory](demo/).

The demo includes:
- Responsive web interface that mimics the mobile app
- Real-time WebSocket integration
- Progressive Web App (PWA) capabilities
- Docker deployment support
- Comprehensive documentation

### Demo Documentation

The demo includes detailed documentation:
- [README.md](demo/README.md) - Demo overview and quick start
- [DEVELOPMENT.md](demo/DEVELOPMENT.md) - Development setup and guidelines
- [DEPLOYMENT.md](demo/DEPLOYMENT.md) - Deployment instructions
- [CHANGELOG.md](demo/CHANGELOG.md) - Version history and release notes
- [README_API.md](demo/README_API.md) - API documentation
- [README_DOCKER.md](demo/README_DOCKER.md) - Docker deployment guide

## Future Enhancements

- Real-time WebSocket integration (implemented in demo)
- Push notifications for task completion
- Offline mode support (implemented in demo)
- Biometric authentication
- Advanced analytics and reporting