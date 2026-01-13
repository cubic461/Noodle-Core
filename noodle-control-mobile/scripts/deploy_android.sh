#!/bin/bash

# NoodleControl Android Deployment Script
# This script builds and deploys the Android app to various environments

set -e

# Configuration
APP_NAME="NoodleControl"
PACKAGE_NAME="com.noodlecontrol.app"
BUILD_DIR="build/app/outputs/flutter-apk"
BUNDLE_DIR="build/app/outputs/bundle/release"

# Environment variables
ENVIRONMENT=${1:-"development"}
FLAVOR=${2:-"development"}

 echo "========================================"
 echo "  NoodleControl Android Deployment"
 echo "========================================"
 echo "Environment: $ENVIRONMENT"
 echo "Flavor: $FLAVOR"
 echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Check if Android SDK is installed
if [ -z "$ANDROID_HOME" ]; then
    echo "ANDROID_HOME is not set. Please set up Android SDK first."
    exit 1
fi

# Clean previous builds
echo "Cleaning previous builds..."
flutter clean

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build the app
echo "Building $FLAVOR flavor for $ENVIRONMENT environment..."
case $FLAVOR in
    "development")
        flutter build apk --debug --flavor development
        ;;
    "staging")
        flutter build apk --release --flavor staging
        ;;
    "production")
        flutter build apk --release --flavor production
        flutter build appbundle --release --flavor production
        ;;
    *)
        echo "Unknown flavor: $FLAVOR"
        echo "Available flavors: development, staging, production"
        exit 1
        ;;
esac

# Deploy based on environment
echo "Deploying to $ENVIRONMENT environment..."
case $ENVIRONMENT in
    "development")
        # Install on connected device
        echo "Installing on connected device..."
        adb install -r $BUILD_DIR/app-$FLAVOR-debug.apk
        echo "App installed successfully on device."
        ;;
    "staging")
        # Upload to staging distribution platform
        echo "Uploading to staging distribution platform..."
        # Add your staging distribution platform commands here
        # For example, Firebase App Distribution:
        # firebase appdistribution:distribute $BUILD_DIR/app-$FLAVOR-release.apk \
        #   --app $FIREBASE_APP_ID \
        #   --groups "staging-testers"
        echo "Staging deployment completed."
        ;;
    "production")
        # Upload to Google Play Console
        echo "Uploading to Google Play Console..."
        # This would typically use fastlane or the Google Play Console API
        # For example, with fastlane:
        # cd android && fastlane deploy
        echo "Production deployment completed."
        ;;
    *)
        echo "Unknown environment: $ENVIRONMENT"
        echo "Available environments: development, staging, production"
        exit 1
        ;;
esac

echo ""
echo "========================================"
echo "  Deployment completed successfully!"
echo "========================================"