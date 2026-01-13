# NoodleControl Mobile App Deployment Guide

This guide provides comprehensive instructions for building and deploying the NoodleControl mobile app to various environments and platforms.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Project Structure](#project-structure)
3. [Environment Configuration](#environment-configuration)
4. [Building the App](#building-the-app)
5. [Android Deployment](#android-deployment)
6. [iOS Deployment](#ios-deployment)
7. [Docker Deployment](#docker-deployment)
8. [CI/CD Pipeline](#cicd-pipeline)
9. [Code Signing](#code-signing)
10. [Troubleshooting](#troubleshooting)

## Prerequisites

### Common Requirements

- Flutter SDK 3.16.0 or later
- Dart SDK compatible with Flutter version
- Git for version control

### Android-Specific Requirements

- Android Studio or Android SDK Command-line Tools
- Java Development Kit (JDK) 17 or later
- Android SDK (API level 33 or higher)
- Android Build Tools 33.0.0 or higher

### iOS-Specific Requirements

- macOS with Xcode 14.0 or later
- iOS SDK 16.0 or higher
- CocoaPods 1.11.0 or later
- Apple Developer Account (for App Store distribution)

### Docker Requirements

- Docker 20.10 or later
- Docker Compose 2.0 or later

## Project Structure

```
noodle_control_mobile_app/
├── android/                 # Android-specific code and configuration
│   ├── app/
│   │   ├── build.gradle     # Android app build configuration
│   │   └── src/main/
│   │       └── AndroidManifest.xml
│   ├── key.properties.example  # Example signing configuration
│   └── settings.gradle
├── ios/                     # iOS-specific code and configuration
│   ├── Runner/
│   │   ├── Info.plist       # iOS app configuration
│   │   └── Assets.xcassets/ # App icons and launch images
│   ├── ExportOptions.plist.example  # Example export configuration
│   ├── fastlane/           # Fastlane configuration
│   └── Gemfile              # Ruby dependencies for Fastlane
├── lib/                     # Dart source code
├── scripts/                 # Deployment scripts
│   ├── deploy_android.sh
│   ├── deploy_android.bat
│   └── deploy_ios.sh
├── .github/workflows/       # GitHub Actions CI/CD
│   ├── android-ci.yml
│   └── ios-ci.yml
├── Dockerfile               # Docker configuration
├── docker-compose.yml       # Docker Compose configuration
└── pubspec.yaml             # Flutter dependencies
```

## Environment Configuration

### Environment Variables

The app supports multiple environments through environment variables:

- `NOODLE_ENV`: Environment (development, staging, production)
- `NOODLE_PORT`: Port for development server (default: 8080)

### Environment-Specific Configuration

#### Development Environment

- Debug builds
- Local API endpoints
- Verbose logging
- Hot reload enabled

#### Staging Environment

- Release builds
- Staging API endpoints
- Warning-level logging
- Crash reporting enabled

#### Production Environment

- Release builds with optimizations
- Production API endpoints
- Error-level logging only
- Full crash reporting and analytics

## Building the App

### Local Development Build

```bash
# Get dependencies
flutter pub get

# Run the app in development mode
flutter run
```

### Create Release Build

#### Android

```bash
# APK for all architectures
flutter build apk --release

# APK for specific architecture
flutter build apk --release --target-platform android-arm64

# App Bundle (required for Google Play Store)
flutter build appbundle --release
```

#### iOS

```bash
# iOS build (requires macOS)
flutter build ios --release

# Create IPA file
cd ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -destination generic/platform=iOS \
  -archivePath build/Runner.xcarchive \
  archive
  
xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath build
```

## Android Deployment

### Using Deployment Scripts

#### Linux/macOS

```bash
# Development build and install
./scripts/deploy_android.sh development development

# Staging build
./scripts/deploy_android.sh staging staging

# Production build
./scripts/deploy_android.sh production production
```

#### Windows

```batch
REM Development build and install
scripts\deploy_android.bat development development

REM Staging build
scripts\deploy_android.bat staging staging

REM Production build
scripts\deploy_android.bat production production
```

### Manual Deployment Steps

1. **Generate a keystore** (if not already created):
   ```bash
   keytool -genkey -v -keystore ~/noodlecontrol-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias noodlecontrol
   ```

2. **Configure signing**:
   - Copy `android/key.properties.example` to `android/key.properties`
   - Fill in the keystore information

3. **Build the app**:
   ```bash
   flutter build appbundle --release
   ```

4. **Upload to Google Play Console**:
   - Sign in to Google Play Console
   - Create a new release
   - Upload the AAB file from `build/app/outputs/bundle/release/`

## iOS Deployment

### Using Deployment Scripts

```bash
# Development build and install on simulator
./scripts/deploy_ios.sh development development

# Staging build
./scripts/deploy_ios.sh staging staging

# Production build
./scripts/deploy_ios.sh production production
```

### Using Fastlane

1. **Install dependencies**:
   ```bash
   cd ios
   bundle install
   ```

2. **Run tests**:
   ```bash
   bundle exec fastlane test
   ```

3. **Build and deploy to TestFlight**:
   ```bash
   bundle exec fastlane beta
   ```

4. **Build and deploy to App Store**:
   ```bash
   bundle exec fastlane release
   ```

### Manual Deployment Steps

1. **Configure signing**:
   - Copy `ios/ExportOptions.plist.example` to `ios/ExportOptions.plist`
   - Update with your Team ID and signing information

2. **Build the app**:
   ```bash
   flutter build ios --release --no-codesign
   ```

3. **Archive and export**:
   ```bash
   cd ios
   xcodebuild -workspace Runner.xcworkspace \
     -scheme Runner \
     -configuration Release \
     -destination generic/platform=iOS \
     -archivePath build/Runner.xcarchive \
     archive
   
   xcodebuild -exportArchive \
     -archivePath build/Runner.xcarchive \
     -exportOptionsPlist ExportOptions.plist \
     -exportPath build
   ```

4. **Upload to App Store Connect**:
   - Sign in to App Store Connect
   - Create a new version
   - Upload the IPA file from `ios/build/`

## Docker Deployment

### Building the Docker Image

```bash
# Build the image
docker build -t noodlecontrol-mobile-app .

# Run the container
docker run -p 8080:8080 noodlecontrol-mobile-app
```

### Using Docker Compose

```bash
# Build and run with Docker Compose
docker-compose up --build

# Run in detached mode
docker-compose up -d --build

# Stop the container
docker-compose down
```

### Custom Build Arguments

```bash
# Build with custom arguments
docker build \
  --build-arg FLUTTER_BUILD_MODE=release \
  --build-arg FLUTTER_TARGET_PLATFORM=android-arm64 \
  -t noodlecontrol-mobile-app .
```

## CI/CD Pipeline

### GitHub Actions

The project includes GitHub Actions workflows for automated building and testing:

- `android-ci.yml`: Android build, test, and deployment
- `ios-ci.yml`: iOS build, test, and deployment

### Pipeline Triggers

The pipelines are triggered by:

- Push to `main` or `develop` branches
- Pull requests to `main` branch
- Manual dispatch

### Environment Variables for CI/CD

Configure the following repository secrets in GitHub:

- `ANDROID_KEYSTORE_BASE64`: Base64-encoded Android keystore
- `ANDROID_KEY_PROPERTIES`: Android signing properties
- `IOS_CERTIFICATE_BASE64`: Base64-encoded iOS certificate
- `IOS_PROVISIONING_PROFILE_BASE64`: Base64-encoded iOS provisioning profile
- `APP_STORE_CONNECT_API_KEY_ID`: App Store Connect API key ID
- `APP_STORE_CONNECT_ISSUER_ID`: App Store Connect issuer ID
- `APP_STORE_CONNECT_KEY_CONTENT`: App Store Connect API key content

## Code Signing

### Android Code Signing

1. **Generate a keystore** (if not already created):
   ```bash
   keytool -genkey -v -keystore noodlecontrol-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias noodlecontrol
   ```

2. **Configure signing**:
   - Copy `android/key.properties.example` to `android/key.properties`
   - Fill in the keystore information

3. **Reference in build.gradle**:
   The `android/app/build.gradle` file already references the key.properties file for signing.

### iOS Code Signing

1. **Create provisioning profiles**:
   - Sign in to Apple Developer Portal
   - Create development, ad-hoc, and distribution provisioning profiles
   - Download and install them in Xcode

2. **Configure export options**:
   - Copy `ios/ExportOptions.plist.example` to `ios/ExportOptions.plist`
   - Update with your Team ID and signing information

3. **Use Fastlane Match** (recommended):
   ```bash
   # Install Fastlane
   cd ios
   bundle install
   
   # Set up Match
   bundle exec fastlane match init
   
   # Generate certificates and profiles
   bundle exec fastlane match development
   bundle exec fastlane match appstore
   ```

## Troubleshooting

### Common Build Issues

#### Flutter Build Failures

1. **Clean and rebuild**:
   ```bash
   flutter clean
   flutter pub get
   flutter build <platform>
   ```

2. **Check Flutter version**:
   ```bash
   flutter --version
   flutter doctor
   ```

3. **Update dependencies**:
   ```bash
   flutter pub upgrade
   ```

#### Android Build Issues

1. **Check Android SDK path**:
   ```bash
   echo $ANDROID_HOME
   ```

2. **Update Gradle wrapper**:
   ```bash
   cd android
   ./gradlew wrapper --gradle-version=7.4
   ```

3. **Check Java version**:
   ```bash
   java -version
   ```

#### iOS Build Issues

1. **Clean Xcode build cache**:
   ```bash
   cd ios
   xcodebuild clean
   rm -rf build
   ```

2. **Update CocoaPods**:
   ```bash
   cd ios
   pod repo update
   pod install
   ```

3. **Check Xcode version**:
   ```bash
   xcodebuild -version
   ```

### Deployment Issues

#### Google Play Console Upload Failures

1. **Check app bundle version**:
   - Ensure version code is higher than previous release
   - Check version name format

2. **Verify signing configuration**:
   - Ensure correct keystore is used
   - Check signing certificate validity

#### App Store Connect Upload Failures

1. **Check app metadata**:
   - Ensure all required metadata is complete
   - Verify app privacy information

2. **Verify provisioning profile**:
   - Ensure correct bundle identifier
   - Check profile expiration date

### Docker Issues

1. **Build failures**:
   ```bash
   # Check Docker version
   docker --version
   
   # Check available disk space
   df -h
   ```

2. **Container startup issues**:
   ```bash
   # Check container logs
   docker logs <container-id>
   ```

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Android App Bundle Guide](https://developer.android.com/guide/app-bundle)
- [App Store Connect Guide](https://help.apple.com/app-store-connect/)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Docker Documentation](https://docs.docker.com/)